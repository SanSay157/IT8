//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Data;
using System.Diagnostics;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.XUtils;

namespace Croc.IncidentTracker.Core
{
	abstract class ContainerPrivilegesCacheBase
	{
		protected XThreadSafeCache<object,object> m_cache;
        protected XThreadSafeCacheCreateValue<object, object> dlgReadPrivileges;

		public ContainerPrivilegesCacheBase()
		{
			m_cache = new XThreadSafeCache<object,object>();
            dlgReadPrivileges = new XThreadSafeCacheCreateValue<object, object>(readPrivileges);
		}

		protected string packKey(Guid EmployeeID, Guid HolderID)
		{
			return EmployeeID.ToString() + ":" + HolderID.ToString();
		}

		protected void upackKey(string sKey, out Guid EmployeeID, out Guid HolderID)
		{
			if (sKey == null || sKey.Length == 0)
				throw new ArgumentException("Некорректное значение ключа кэша: " + sKey);
			int nDelIndex = sKey.IndexOf(':');
			if (nDelIndex < -1)
				throw new ArgumentException("Некорректное значение ключа кэша: " + sKey);
			string sLeftValue = sKey.Substring(0, nDelIndex);
			string sRightValue = sKey.Substring(nDelIndex+1, sKey.Length - nDelIndex - 1);
			EmployeeID = new Guid(sLeftValue);
			HolderID = new Guid(sRightValue);
		}

		protected abstract object readPrivileges(object key, object value);
		public void Clear()
		{
			m_cache.Clear();
		}
	}

	/// <summary>
	/// Кэш привилегий на папку для пользователей
	/// </summary>
	class FolderPrivilegesCache: ContainerPrivilegesCacheBase
	{
		public int GetPrivilege(ITUser user, Guid FolderID, XStorageConnection con)
		{
			return (int)m_cache.GetValue(packKey(user.EmployeeID, FolderID), dlgReadPrivileges, con);
		}

		protected override object readPrivileges(object key, object value)
		{
			XStorageConnection con = (XStorageConnection)value;
			XDbCommand cmd;
			int privileges = 0;		// маска привелегий

			// зачитаем из БД привилегии пользователя и ролей пользователя для заданной и всех вышестоящих папок (условие на LIndex/RIndex с "равно")
			cmd = con.CreateCommand();
			cmd.CommandText = 
				@"SELECT f_i.ObjectID as FolderID, pp.Privileges, roles.Privileges AS RolePrivileges 
					FROM Folder f 
						JOIN Folder f_i ON f_i.LIndex <= f.LIndex AND f_i.RIndex >= f.RIndex AND f_i.Customer = f.Customer
							JOIN ProjectParticipant pp ON pp.Folder = f_i.ObjectID
							LEFT JOIN (ProjectParticipant_Roles pp_r 
								JOIN UserRoleInProject roles ON pp_r.Value = roles.ObjectID) ON pp.ObjectID = pp_r.ObjectID
					WHERE f.ObjectID = @FolderID AND pp.Employee = @EmployeeID
					ORDER BY f_i.LRLevel DESC
					";
			Guid EmployeeID;
			Guid FolderID;
			upackKey((string)key, out EmployeeID, out FolderID);
			cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, FolderID );
			cmd.Parameters.Add("EmployeeID", DbType.Guid, ParameterDirection.Input, false, EmployeeID);
			using(IDataReader reader = cmd.ExecuteReader())
			{
				if (reader.Read())
					privileges = readFolderPrivilegeMask(reader);
			}
			return privileges;
		}

		private int readFolderPrivilegeMask(IDataReader reader)
		{
			int privileges = 0;
			privileges = privileges | reader.GetInt32( reader.GetOrdinal("Privileges") );
			// RolePrivileges может быть NULL
			int nRolePrivilegesColIndex = reader.GetOrdinal("RolePrivileges");
			if (!reader.IsDBNull(nRolePrivilegesColIndex))
			{
				privileges = privileges | reader.GetInt32( nRolePrivilegesColIndex );

				Guid initFolderID = reader.GetGuid( reader.GetOrdinal("FolderID") );
				Guid curFolderID;
				while(reader.Read())
				{
					curFolderID = reader.GetGuid( reader.GetOrdinal("FolderID") );
					if (curFolderID != initFolderID )
						break;
					if (!reader.IsDBNull(nRolePrivilegesColIndex))
						privileges = privileges | reader.GetInt32(nRolePrivilegesColIndex);
				}
			}
			return privileges;
		}

	}

	public class FolderPrivilegesDefinitionContainer
	{
		private FolderPrivilegesCache m_cache;

		public FolderPrivilegesDefinitionContainer()
		{
			m_cache = new FolderPrivilegesCache();
		}

		public XPrivilegeSet GetPrivileges(ITUser user, Guid FolderID, XStorageConnection con)
		{
			Debug.Assert(con != null);
			Debug.Assert(FolderID != Guid.Empty);

			int privileges = m_cache.GetPrivilege(user, FolderID, con);
			return PrivilegesHelper.CreatePrivilegeSet((FolderPrivileges)privileges);
		}

		public void FlushCache()
		{
			m_cache.Clear();
		}
	}

	public class FolderPrivilegeManager
	{
		private FolderPrivilegesDefinitionContainer m_folderPrivilegesDefinitionContainer;

		public FolderPrivilegeManager(SecurityProvider provider)
		{
			m_folderPrivilegesDefinitionContainer = (FolderPrivilegesDefinitionContainer)provider.ObjectPrivilegeContainers["Folder"];
		}

		public bool HasFolderPrivilege(ITUser user, FolderPrivileges privilege, DomainObjectData xobjFolder, XStorageConnection con)
		{
			// т.к. компонент может использоваться не только через методы XSecurityManager: GetObjectRights, HasSaveObjectRights, etc.
			if (user.IsUnrestricted)
				return true;
			string sPrivilege = FolderPrivilegesItem.GetItem(privilege).Name;

			Guid orgID;
			Guid activityTypeID;
			FolderStates folderState;
			if (xobjFolder.IsNew)
			{
				if (!xobjFolder.HasUpdatedProp("Customer") || xobjFolder.GetUpdatedPropValue("Customer") == DBNull.Value)
					return false;
				orgID = (Guid)xobjFolder.GetUpdatedPropValue("Customer");

				if (!xobjFolder.HasUpdatedProp("ActivityType") || xobjFolder.GetUpdatedPropValue("ActivityType") == DBNull.Value)
					return false;
				activityTypeID = (Guid)xobjFolder.GetUpdatedPropValue("ActivityType");

				if (!xobjFolder.HasUpdatedProp("State") || xobjFolder.GetUpdatedPropValue("State") == DBNull.Value)
					return false;
				folderState = (FolderStates)xobjFolder.GetUpdatedPropValue("State");
			}
			else
			{
				if (!xobjFolder.HasLoadedProp("Customer") || !xobjFolder.HasLoadedProp("ActivityType") || !xobjFolder.HasLoadedProp("Parent") || !xobjFolder.HasLoadedProp("State"))
					xobjFolder.Load(con);

				orgID = (Guid)xobjFolder.GetLoadedPropValue("Customer");
				activityTypeID = (Guid)xobjFolder.GetLoadedPropValue("ActivityType");
				folderState = (FolderStates)xobjFolder.GetLoadedPropValue("State");
			}

			// в закрытой папке ни у кого нет никаких привилегий
			if ( folderState == FolderStates.Closed)
				return false;

			if (user.ManageOrganization(orgID) || user.ManageActivityType(activityTypeID))
				return true;

			if (!xobjFolder.IsNew)
			{
				// для объекта из БД, проверим определение привилегий для участника проекта заданной и вышестоящих папок
				if (m_folderPrivilegesDefinitionContainer.GetPrivileges(user, xobjFolder.ObjectID, con).Contains(sPrivilege))
					return true;
			}
			else
			{
				// Для нового объекта зачитывать привилегии из БД бессмысленно - 
				// проверим ссылку на родителя, если она задана, то зачитаем его привилегии
				object vValue = xobjFolder.GetUpdatedPropValue("Parent");
				if (vValue is Guid)
					if (m_folderPrivilegesDefinitionContainer.GetPrivileges(user, (Guid)vValue, con).Contains(sPrivilege))
						return true;
			}

			return false;
		}
	}
}
