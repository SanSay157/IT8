//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.IncidentTracker.Core;

namespace Croc.IncidentTracker.Core
{
	// Authorization Evaluation Layer

	class CommonRightsRules
	{
		/// <summary>
		/// ��������� �� �������� �� �������� ���� � ������ ������������ �������� (��� ����������, ��� � ��� �����)
		/// </summary>
		/// <param name="dtTimeSpentDate">�������� ���� ��������</param>
		/// <param name="xobjFolder">������ �����, ����� ���� �� ����� (null)</param>
		/// <returns>true - ��������, false - �� ��������</returns>
		public static bool IsRegDateInBlockPeriod(DateTime dtTimeSpentDate, DomainObjectData xobjFolder)
		{
			// RULE: ���������, ������������� � ������� �������� ���������, ���� ��� ���� �������� � ���������� �������� ������
			// ������� ���� ����������� ��������
			// ���� ���� �������� ������ ���� ����������� ������� ������������ ��������
			if (dtTimeSpentDate <= ApplicationSettings.GlobalBlockPeriodDate)
				return true;
			return false;
		}
        /// <summary>
        /// ������� �����������, ������ �� ������� ���������, �� ������������� ������ �������
        /// </summary>
        /// <param name="xobjFolderNew">�����, � ������� ����������� ��������</param>
        /// <param name="xobjFolderOld">�����, �� ������� ����������� ��������</param>
        /// <param name="con"></param>
        /// <returns></returns>
        public static bool CheckIncidentForBlockedPeriod(DomainObjectData xobjFolderNew, DomainObjectData xobjFolderOld, XStorageConnection con)
        {
            // ���� ���-� ����������� � ����� ����������, �� ��� ������ �� ������������� ������ �������
            if (!IsSameActivity(xobjFolderNew.ObjectID, xobjFolderOld.ObjectID, con))
                return true;
            int nDirectionCount = 0;
            nDirectionCount = DirectionsCount(con, (Guid)xobjFolderNew.ObjectID);
            // ���� ����������� � ������� ���� ��� �� ������, �� ������� ��������� �� ������ �� ������������� ������
            if (nDirectionCount == 1 || nDirectionCount == 0)
            {
                return false;
            }
            object vValue = null;
            XDbCommand cmd;
            // �������� �� �������������� ����������� � ������
            if ((xobjFolderOld.GetLoadedPropValue("Parent") is Guid) &&
                   (xobjFolderNew.GetLoadedPropValue("Parent") is Guid))
            {
                cmd = con.CreateCommand(@"SELECT TOP 1 1 
                                        FROM 
                                          (SELECT DISTINCT f.ObjectID,Direction
		                                        FROM Folder f (NOLOCK)
			                                        JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                        JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                        WHERE f.ObjectID = @FolderOld AND (f_s.Parent IS NOT NULL)
		                                        ) AS dirOld
                                          INNER 
                                          JOIN 
                                          (
                                          SELECT DISTINCT f.ObjectID,Direction
		                                        FROM Folder f (NOLOCK)
			                                        JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                        JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                        WHERE f.ObjectID = @FolderNew AND (f_s.Parent IS NOT NULL)
		                                        ) AS dirNew ON  dirOld.Direction = dirNew.Direction
                                                ");
                cmd.Parameters.Add("FolderOld", DbType.Guid, ParameterDirection.Input, false, xobjFolderNew.ObjectID);
                cmd.Parameters.Add("FolderNew", DbType.Guid, ParameterDirection.Input, false, xobjFolderOld.ObjectID);
                vValue = cmd.ExecuteScalar();
                // ���� ����������� � ������ �� ���������, �� ������� ���-�� ������ �� ������������� ������
                if (vValue == null)
                    return true;


            }
            vValue = null;
            cmd = con.CreateCommand(@"SELECT TOP 1 1
                                        FROM Folder f (NOLOCK)
                                          JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 
                                          JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
                                        WHERE f.ObjectID = @FolderID AND (f_s.Parent IS NOT NULL)");

            // RULE:  ���� ������� ���� �� ����� � ������ ���������� ��� ��������, 
            // �� � ����� �� ������ ���� ������ �� ���������
            if ((xobjFolderOld.GetLoadedPropValue("Parent") is Guid) &&
                    !(xobjFolderNew.GetLoadedPropValue("Parent") is Guid))
            {
                cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, xobjFolderOld.ObjectID);
            }
            else if ((xobjFolderNew.GetLoadedPropValue("Parent") is Guid) &&
                            !(xobjFolderOld.GetLoadedPropValue("Parent") is Guid))
            {
                cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, xobjFolderNew.ObjectID);
            }
            else
                return false;
            vValue = cmd.ExecuteScalar();
            if (vValue != null && (Convert.ToInt32(vValue) == 1))
                return true;
            return false;

        }
        /// <summary>
        /// ������� �����������, ������ �� ������� �����, �� ������������� ������ �������
        /// </summary>
        /// <param name="xobj"></param>
        /// <param name="con"></param>
        /// <returns></returns>
        public static bool CheckFolderForBlockedPeriod(DomainObjectData xobjFolderNew, DomainObjectData xobjFolder, XStorageConnection con)
        {
            // ���� ������ ����������� � ������, �� ��� ������ �� ������������� ������ �������
            if (xobjFolderNew == null)
                return true;
            // ���� ����� ����������� � ����� ����������, �� ��� ������ �� ������������� ������ �������
            if (!IsSameActivity(xobjFolderNew.ObjectID, xobjFolder.ObjectID, con))
                return true;
            int nDirectionCount =0;
            nDirectionCount = DirectionsCount(con, (Guid)xobjFolderNew.ObjectID);
            // ���� ����������� � ������� ���� ��� �� ������, �� ������� ��������� �� ������ �� ������������� ������
            if (nDirectionCount == 1 || nDirectionCount == 0)
            {
                return false;
            }
            object vValue = null;
            XDbCommand cmd;
            // �������� �� �������������� ����������� � ������
            cmd = con.CreateCommand(@"SELECT TOP 1 1 
                                        FROM 
                                          (SELECT DISTINCT f.ObjectID,Direction
		                                        FROM Folder f (NOLOCK)
			                                        JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                        JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                        WHERE f.ObjectID = @FolderOld AND (f_s.Parent IS NOT NULL)
		                                        UNION 
		                                        SELECT DISTINCT f.ObjectID,Direction
		                                        FROM Folder f (NOLOCK)
			                                        JOIN Folder f_s (NOLOCK) ON f.LIndex < f_s.LIndex AND f.RIndex > f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                        JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                        WHERE f.ObjectID = @FolderOld ) AS dirOld
                                          INNER 
                                          JOIN 
                                          (
                                          SELECT DISTINCT f.ObjectID,Direction
		                                        FROM Folder f (NOLOCK)
			                                        JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                        JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                        WHERE f.ObjectID = @FolderNew AND (f_s.Parent IS NOT NULL)
		                                        ) AS dirNew ON  dirOld.Direction = dirNew.Direction
                                         UNION  -- ������� ������, ����� ����������� ��� � ����� �����
                                         SELECT TOP 1 1
                                         WHERE NOT EXISTS (SELECT DISTINCT f.ObjectID,Direction
		                                                   FROM Folder f (NOLOCK)
			                                                    JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                                    JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                                   WHERE f.ObjectID = @FolderNew AND (f_s.Parent IS NOT NULL)
		                                                   UNION
		                                                   SELECT DISTINCT f.ObjectID,Direction
		                                                   FROM Folder f (NOLOCK)
			                                                    JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                                    JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                                   WHERE f.ObjectID = @FolderOld AND (f_s.Parent IS NOT NULL) 
		                                                                                    )       
                                            
                                        ");
            cmd.Parameters.Add("FolderOld", DbType.Guid, ParameterDirection.Input, false, xobjFolder.ObjectID);
            cmd.Parameters.Add("FolderNew", DbType.Guid, ParameterDirection.Input, false, xobjFolderNew.ObjectID);
            vValue = cmd.ExecuteScalar();
                // ���� ����������� � ������ �� ���������, �� ������� ���-�� ������ �� ������������� ������
            if (vValue == null)
                return true;
            return false;
        }

        /// <summary>
        /// ������� ���������� ���������� ����������� ��� �������, � ������� ���������� ������� � �������� ���������������
        /// </summary>
        /// <param name="con">XStorageConnection</param>
        /// <param name="FolderID">Guid ������������� ��������</param>
        /// <returns>���������� ����������� �������</returns>
        private static int DirectionsCount(XStorageConnection con, Guid FolderID)
        {
            object vValue;
            XDbCommand cmd = con.CreateCommand(@"SELECT COUNT(*)
                                                FROM [dbo].[FolderDirection] (NOLOCK)
                                                WHERE Folder =
		                                                (SELECT TOP 1 f.ObjectID
		                                                FROM Folder f (NOLOCK)
			                                                JOIN Folder f_s (NOLOCK) ON f.LIndex <= f_s.LIndex AND f.RIndex >= f_s.RIndex AND f.Customer = f_s.Customer AND f.Type != 16
		                                                WHERE f_s.ObjectID = @FolderID
		                                                ORDER BY f.LRLevel)");
            cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, FolderID);
            vValue = cmd.ExecuteScalar();
            return Convert.ToInt32(vValue);
        }

        /// <summary>
        /// ������� �����������, ��������� �� ����� � ����� ���������� 
        /// </summary>
        /// <param name="uidFolderNew">������������� ������ �����</param>
        /// <param name="uidFolderOld">������������� ������ �����</param>
        /// <param name="con"></param>
        /// <returns></returns>
        public static bool IsSameActivity(Guid uidFolderNew, Guid uidFolderOld, XStorageConnection con)
        {
            object vValue = null;
            XDbCommand cmd = con.CreateCommand(@"
								SELECT 1 WHERE
								(
									SELECT TOP 1 f.ObjectID
									FROM Folder f 
										JOIN Folder f_s ON f.LIndex <= f_s.LIndex AND f.RIndex >= f_s.RIndex AND f.Customer = f_s.Customer AND f.Type != 16
									WHERE f_s.ObjectID = @OldParent
									ORDER BY f.LRLevel DESC
								) =
								(
									SELECT TOP 1 f.ObjectID
									FROM Folder f 
										JOIN Folder f_s ON f.LIndex <= f_s.LIndex AND f.RIndex >= f_s.RIndex AND f.Customer = f_s.Customer AND f.Type != 16
									WHERE f_s.ObjectID = @NewParent
									ORDER BY f.LRLevel DESC
								)
							");
            cmd.Parameters.Add("OldParent", DbType.Guid, ParameterDirection.Input, false, uidFolderOld);
            cmd.Parameters.Add("NewParent", DbType.Guid, ParameterDirection.Input, false, uidFolderNew);
            vValue = cmd.ExecuteScalar();
            if (vValue != null && (Convert.ToInt32(vValue) == 1))
                return true;
            return false;
        }
        
	}

	public abstract class ObjectRightsCheckerBase
	{
		protected bool m_bAllowEverythingByDefault;
		protected SecurityProvider m_provider;

		public ObjectRightsCheckerBase(SecurityProvider provider, bool bAllowEverythingByDefault)
		{
			m_provider = provider;
			m_bAllowEverythingByDefault = bAllowEverythingByDefault;
		}

		public virtual XObjectRights GetObjectRights(ITUser xuser, DomainObjectData xobj, XStorageConnection con)
		{
			if (m_bAllowEverythingByDefault)
				return XObjectRights.FullRights;
			else
				return XObjectRights.ReadOnlyRights;
		}

		/// <summary>
		/// �������� ��� ���������� �������
		/// </summary>
		/// <param name="user"></param>
		/// <param name="xobj"></param>
		/// <param name="con"></param>
		/// <returns></returns>
		public virtual bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			if (xobj.IsNew)
				return hasInsertObjectRight(user, xobj, con, out sErrorDescription);
			else
			{
				XObjectRights rights = GetObjectRights(user, xobj, con);
				if (rights.AllowFullChange)
					return true;
				else if (rights.AllowParticalOrFullChange)
					// �������������� �����, �� �� ��� ��������
					return ! hasObjectChangedReadOnlyProps(xobj, rights, ref sErrorDescription);  
			}
			return false;
		}

		/// <summary>
		///  �������� ��� ������ ������� ��� ����������. 
		///  ���������� �� ObjectRightsCheckerBase::HasSaveObjectRight
		/// </summary>
		/// <param name="user"></param>
		/// <param name="xobj"></param>
		/// <param name="con"></param>
		/// <returns></returns>
		protected virtual bool hasInsertObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			XNewObjectRights rights = GetRightsOnNewObject(user, xobj, con);
			if (rights.IsUnrestricted)
				return true;
			else if (rights.HasReadOnlyProps)
				// �������������� �����, �� �� ��� ��������
				return ! hasObjectChangedReadOnlyProps(xobj, rights, ref sErrorDescription);
			return false;
		}

		public virtual XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			if (m_bAllowEverythingByDefault)
				return XNewObjectRights.FullRights;
			else
				return XNewObjectRights.EmptyRights;
		}

		/// <summary>
		/// ���������� ������� �������� �� ������ ���� �� ���� ���������������� read-only ��������
		/// </summary>
		/// <param name="xobj"></param>
		/// <param name="rights">�������� ���� �� ������</param>
		/// <returns>true - ��������, false - �� ��������</returns>
		protected bool hasObjectChangedReadOnlyProps(DomainObjectData xobj, XObjectRightsBase rights, ref string sErrorDescription)
		{
           	ICollection props = rights.GetReadOnlyPropNames();
			foreach(string sProp in props)
				if (xobj.HasUpdatedProp(sProp))
					// ������ �������������� read-only ��������
				{
                    sErrorDescription = "��� ���� �� ��������� �������� '" + xobj.TypeInfo.GetProp(sProp).Description + "'";
					return true;
				}
			return false;
		}

	}
    
	[SecurityRightsChecker("Organization")]
	public class OrganizationRightsChecker: ObjectRightsCheckerBase
	{
		public OrganizationRightsChecker(SecurityProvider provider): base(provider, false) 
		{}
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			XObjectRights rights = XObjectRights.ReadOnlyRights;
			Debug.Assert(con != null);
			// "�����������"
            if (user.ManageOrganization(xobj.ObjectID) || user.HasPrivilege(SystemPrivilegesItem.OrganizationManagement.Name))
                rights = XObjectRights.FullRights;
		
			return rights;
		}
        public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            // RULE: � ������� ����� ���� ������ ���� ����������� �� ��������� �������� �������� ������� (Home),������ true.
            if (xobj.HasUpdatedProp("Home"))
            {
                if ((bool)xobj.GetUpdatedPropValue("Home"))
                {
                    XDbCommand cmd = con.CreateCommand(@"	SELECT TOP 1 org.Name
			                                                    FROM Organization org 
			                                                    WHERE org.Home = 1
		                                           ");
                    object vValue = cmd.ExecuteScalar();
                    if (vValue != null)
                    {
                        sErrorDescription = @"���������� ������� ����������� � ������������� ��������� �������� - �������, ��� ��� � ������� ��� ���� �����������,
������� �������� ���������� �������  - " + "\"" + vValue.ToString() + "\"";
                        return false;
                    }
                }
            }
            return base.HasSaveObjectRight(user, xobj, con, out sErrorDescription);
            
        }

	    protected override bool hasInsertObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			bool bHasOrganizationManagementPrivilege = user.HasPrivilege(SystemPrivilegesItem.OrganizationManagement.Name);
			bool bHasTempOrganizationManagmentPrivilege = user.HasPrivilege(SystemPrivilegesItem.TempOrganizationManagment.Name);
            
            // RULE: ��������� ����������� ����� ������������, ���������� ����������� "���������� �������������" 
			if ( bHasOrganizationManagementPrivilege )
				return true;
			
			// RULE: ��������� ����������� ����������� ��������� ������ ����� ��������� ������������ �����������
			// ��� ���� �������� ������ ���� ��������� �� ���� ������� ����� ������� ���������� "���������� �������������"/
			// �� �.�. �� ������� ������������� ��������� �������� ����������� � �� ��� ��������� ����, 
			// ������������� ����� ����������� ����� ���� ������ ���������
			if (xobj.GetUpdatedPropValue("Parent") is Guid)			// ������ ������������ �����������
			{
				Guid parentID = (Guid)xobj.GetUpdatedPropValue("Parent");
				if (user.ManageOrganization(parentID))
					return true;
			}
            return false;
		}

		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			bool bHasOrganizationManagementPrivilege = user.HasPrivilege(SystemPrivilegesItem.OrganizationManagement.Name);
			if (bHasOrganizationManagementPrivilege)
			{
				return new XNewObjectRights(true);
			}
			else
				return new XNewObjectRights(false);
		}
	}

	[SecurityRightsChecker("Folder")]
	public class FolderRightsChecker: ObjectRightsCheckerBase
	{
		public FolderRightsChecker(SecurityProvider provider): base(provider, false)
		{}
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			Debug.Assert(con != null);
			FolderTypeEnum nType;
			Guid organizationID;
			Guid activityTypeID;
			FolderStates folderState;
			
			// ��������, ��� ������ ��������
			try
			{
				xobj.Load(con);
			}
			catch(XObjectNotFoundException)
			{
				// ������� ��� � ��, ��� �������� ��� ��� ���������
				return XObjectRights.ReadOnlyRights;
			}
			
			// ������� ��� ����� � ������������� �����������
			organizationID	= (Guid)xobj.GetLoadedPropValue("Customer");
			activityTypeID	= (Guid)xobj.GetLoadedPropValue("ActivityType");
			folderState		= (FolderStates)xobj.GetLoadedPropValue("State");
			nType = (FolderTypeEnum)xobj.GetLoadedPropValue("Type");
			FolderStates parentFolderState = 0;
			DomainObjectData xobjParent = null;
			if (xobj.GetLoadedPropValue("Parent") is Guid)
			{
				xobjParent = xobj.Context.GetLoadedStub("Folder", (Guid)xobj.GetLoadedPropValue("Parent"));
				parentFolderState = (FolderStates)xobjParent.GetLoadedPropValueOrLoad(con, "State");
			}
			
			// ����������� ����:

			XObjectRightsBuilder builder = new XObjectRightsBuilder();
			
			
			
			
			// RULE: ���� ���� ���������� ����� �� �����������-������� ��� ��� ��������� ������, 
			//		�� � ������ ����� ������ ���, ���� ��� �� �������, ����� ����� ������ ���, ����� ��������
			if (user.ManageOrganization(organizationID) || user.ManageActivityType(activityTypeID))
			{
				builder.SetAllowFullChange();
				builder.SetAllowDelete();
			}
			else
			{
				// ...���������� ���� �� ����� ���

				FolderPrivilegesDefinitionContainer def = (FolderPrivilegesDefinitionContainer)m_provider.ObjectPrivilegeContainers["Folder"];
				XPrivilegeSet priv_set = def.GetPrivileges(user, xobj.ObjectID, con);
				
				if (nType == FolderTypeEnum.Directory)
				{
					// ����� - �������: ��������, ���� ����� �� ���������� ���������� � ������� �������
					
					// RULE: ��� ������� ���������� "���������� ����������" � ������-��������� ����� ������ 
					//	����� ���: �������������, �������, ���������� (�� ����������� �������� ����������
					//	�������� - ������ if). ���������� - �������� �������: ��� ������ �������.
					if (priv_set.Contains(FolderPrivilegesItem.ManageCatalog.Name))
					{
						// RULE: �������� ���� "�������� �� ����� �������������" ����� ������ ��� �������
						//	���������� "�������������� ���������� ��������", ����� - ����� ������ ���, 
						//	����� �������� ������ �����:
						if (priv_set.Contains(FolderPrivilegesItem.ChangeFolder.Name))
							builder.SetAllowFullChange();
						else
							builder.SetAllowChangeExcept(new string[]{"IsLocked"});
						builder.SetAllowDelete();
					}
				}
				else
				{
					// ����� - �� �������
					// RULE: �������� ��������� ����� �����, ���� ���� ��������� ���������� "�������������� 
					//	���������� �����"; ��� ����� �������: Customer, ActivityType, Parent:
					if (priv_set.Contains(FolderPrivilegesItem.ChangeFolder.Name))
						builder.SetAllowChangeExcept(new string[] {"Customer", "ActivityType", "Parent"});
				}
			}
			// RULE: �������� �������� Customer, ActivityType, Parent ����� ��� ������� ���������� ���������� "������� �����"
			if (user.HasPrivilege(SystemPrivilegesItem.MoveFoldersAndIncidents.Name))
				builder.SetAllowChangeProps(xobj.TypeInfo.Properties, new string[] {"Customer", "ActivityType", "Parent"});
            // RULE: ���� ����� ������� ��� � �������� ��������, �� ������� �� ������ ������. ������ ����� ������ ���������

            // RULE: ���� ������������ ����� ��������� � ��������� "�������", �� ������ �������, �������� ��������� � 
            // ���������� (�.�. ������ ����� �� ��������:Customer, ActivityType, Parent)
            if (xobjParent != null)
            {
                if (parentFolderState == FolderStates.Closed)
                {
                    builder.SetReadOnlyPropsFinal(new string[] { "Incidents" });
                    builder.SetDenyDeleteFinal();
                    builder.SetDenyChangeFinal();
                }
				else
				{
					if (folderState == FolderStates.Closed)
                    {
                        builder.SetDenyDeleteFinal();
                        builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks","IsLocked",
                                                            "ExternalLink","DefaultIncidentType","Name",
                                                            "ExternalID","Description","FolderDirections"});
                    }
				}

				if (parentFolderState == FolderStates.WaitingToClose)
				{
					if (folderState != FolderStates.Closed)
					{
						builder.SetDenyDeleteFinal();
						builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks",
                                                            "ExternalLink","IsLocked","DefaultIncidentType"});
					}
				}
				else
				{
					if (folderState == FolderStates.WaitingToClose)
					{
						builder.SetDenyDeleteFinal();
						builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks","IsLocked",
                                                            "ExternalLink","DefaultIncidentType"});
					}
				}

				if (parentFolderState == FolderStates.Frozen)
				{
					builder.SetReadOnlyPropsFinal(new string[] { "Incidents" });
					builder.SetDenyDeleteFinal();
					builder.SetDenyChangeFinal();
				}
				else
				{
					if (folderState == FolderStates.Frozen)
					{
						builder.SetDenyDeleteFinal();
						builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks","IsLocked",
                                                            "ExternalLink","DefaultIncidentType","Name",
                                                            "ExternalID","Description","FolderDirections"});
					}
				}

                //�� ����, ���� ������������ ����� ������� ��� � ������� ��������, �� � �������� ������ ������ �� �����
                //builder.SetDenyChangeFinal();
            }
            else
            {
                if (folderState == FolderStates.WaitingToClose)
                {
                    builder.SetDenyDeleteFinal();
                    builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks","IsLocked",
                                                            "ExternalLink","DefaultIncidentType"});
                }
                else if (folderState == FolderStates.Closed)
                {
                    builder.SetDenyDeleteFinal();
                    builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks","IsLocked",
                                                            "ExternalLink","DefaultIncidentType","Name",
                                                            "ExternalID","Description","FolderDirections"});
				}
				else if (folderState == FolderStates.Frozen)
				{
					builder.SetDenyDeleteFinal();
					builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks","IsLocked",
                                                            "ExternalLink","DefaultIncidentType","Name",
                                                            "ExternalID","Description","FolderDirections"});
				}
            }
           	return builder.GetObjectRights();
		}

		public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			if (xobj.IsNew)
				return hasInsertObjectRight(user, xobj, con, out sErrorDescription);
			else
			{
                
				// ��������: ������ GetObjectRights ���������� �������� ������ ������ �������, ��� ������������ �����,
				//	�.�. ������ GetLoadedPropValue ���������
				XObjectRights rights = GetObjectRights(user, xobj, con);
				if (!rights.AllowParticalOrFullChange)
					return false;
				// �������������� �����, �� �� ��� ��������
				if (hasObjectChangedReadOnlyProps(xobj, rights, ref sErrorDescription))
					return false;

				FolderTypeEnum folderType = (FolderTypeEnum)xobj.GetLoadedPropValue("Type");
				// RULE: ������� �� ����� ���� ��������� �� �������� �������
				if (folderType == FolderTypeEnum.Directory && xobj.GetUpdatedPropValue("Parent") == DBNull.Value)
				{
					sErrorDescription = "������� �� ����� ���� ��������� �� �������� �������";
					return false;
				}

				// RULE: ���������� ���������� (�� �������) � ��������� "�������" ����� ������ ����, 
				//	������������ ��������� ����������� "�������� ��������� �����������" (CloseAnyFolder).
				//	��������! ��������������� ��������� ���������� "�������� ��������� ����������" 
				//	(CloseFolder) � ����������� ����� ���� �� ������������� - �� ������� ������� � ���
				//	��� ����� ����������������� ������ ���� ��������� ���������� (��������������, ��� 
				//	��������� ���������� ����� ������ ��, � ���� ���� ����������� ��������� ����������)
				if (xobj.HasUpdatedProp("State") && !xobj.IsNew && folderType != FolderTypeEnum.Directory)
				{
					FolderStates folderStateOld = (FolderStates) xobj.GetLoadedPropValue("State");
					FolderStates folderStateNew = (FolderStates) xobj.GetUpdatedPropValue("State");
					bool bIsCheckStateChanging = 
						( folderStateOld != FolderStates.Closed && folderStateNew == FolderStates.Closed ) ||
						( folderStateOld == FolderStates.Closed && folderStateNew != FolderStates.Closed );

					if (bIsCheckStateChanging)
						if (!user.HasPrivilege( SystemPrivilegesItem.CloseAnyFolder.Name ))
						{
							// TODO: ��������� ���������� - ���� �� ���������������  
							//	if (!m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.CloseFolder, xobj, con))
							{
								sErrorDescription = "������������ ���� ��� �������� ��������� ����������";
								return false;
							}
						}
				}
                // RULE: ��� �������� �����, ���� ���������, ���� �� ������������ � �������� ���������� �������
                if (xobj.HasUpdatedProp("Parent"))
                {
                    DomainObjectData xobjFolderNew = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, true);
                    // ���� ������� ����� ������ �� ������������� ������, �� ���� ��������� �� ������� ������ � �������� ���������� �������
                    if (ApplicationSettings.GlobalBlockPeriodDate != DateTime.MinValue)
                    {
                        if (CommonRightsRules.CheckFolderForBlockedPeriod(xobjFolderNew, xobj, con))
                        {
                            XDbCommand cmd = con.CreateCommand(@"SELECT TOP 1 * FROM
                                                            (
	                                                        SELECT TOP 1 1 AS ID
	                                                        FROM [dbo].[TimeSpent] ts (NOLOCK)
		                                                        JOIN dbo.Task tsk (NOLOCK) ON tsk.ObjectID = ts.[Task]
		                                                        JOIN dbo.Incident inc (NOLOCK) ON inc.ObjectID = tsk.Incident
		                                                        JOIN dbo.Folder f (NOLOCK) ON inc.Folder = f.ObjectID
		                                                        JOIN dbo.Folder AS FF (NOLOCK) ON FF.Customer = F.Customer
			                                                      AND FF.LIndex <= F.LIndex AND F.RIndex <= FF.RIndex 
	                                                        WHERE ts.[RegDate] <= @Date AND FF.ObjectID = @FolderID  
	                                                        UNION ALL
	                                                        SELECT TOP 1 1 AS ID
	                                                        FROM dbo.TimeLoss tls (NOLOCK)
		                                                        JOIN dbo.Folder f (NOLOCK) ON tls.Folder= f.ObjectID
		                                                        JOIN dbo.Folder AS FF (NOLOCK) ON FF.Customer = F.Customer
			                                                        AND FF.LIndex <= F.LIndex AND F.RIndex <= FF.RIndex 
	                                                        WHERE tls.[LossFixed] <= @Date AND FF.ObjectID = @FolderID) Res
                                                        ");
                            cmd.Parameters.Add("@Date", DbType.Date, ParameterDirection.Input, false, ApplicationSettings.GlobalBlockPeriodDate);
                            cmd.Parameters.Add("@FolderID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
                            using (IDataReader reader = cmd.ExecuteReader())
                            {
                                bool bHasTimeSpent = false;
                                if (reader.Read())
                                {
                                    bHasTimeSpent = reader.GetBoolean(0);
                                }
                                sErrorDescription = "����� �������� ������������, ������������������ � �������� ������";
                                if (bHasTimeSpent)
                                    return false;
                            }
                        }
                    }
                }
				// ���� � ����� ��������� ��������, ������ ��� ��� ��������� ������ (�������� �������� �����)
				// ����� �� ��� �����, ��� ������������ �������� ��������,������� �/��� ��� ��������� ������ �����, ��
				// ���� ��������� ������������ ����� ��������
				// ��������: ��� �������� ����� ��������, �� ��������� � Parent,Customer,ActivityType ���� ��������� �� ���������� �����,
				//			�.�. � ���, � ������ ������ ��������, �������� "return true"
				if (xobj.GetUpdatedPropValue("Parent") is Guid || xobj.GetUpdatedPropValue("Customer") is Guid || xobj.GetUpdatedPropValue("ActivityType") is Guid )
				{
					// RULE: ����� �� ����� ���� ���������� � �������� �����
					if (xobj.GetUpdatedPropValue("Parent") is Guid)
					{
						DomainObjectData xobjFolderNew = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, true);
						FolderStates parentFolderState = (FolderStates)xobjFolderNew.GetLoadedPropValue("State");
						if (parentFolderState == FolderStates.Closed || parentFolderState == FolderStates.WaitingToClose || parentFolderState == FolderStates.Frozen)
						{
							sErrorDescription = "������� ����� � �����, ����������� � ��������� \"�������\" ��� \"�������� ��������\", ��������";
							return false;
						}
					}
                    
					// RULE: ������������, ���������� ��������� ����������� "������� �����", ����� ���������� ����� ����� � ����� �����
					if (user.HasPrivilege(SystemPrivilegesItem.MoveFoldersAndIncidents.Name))
						return true;

					object vValue;
					vValue = xobj.GetUpdatedPropValue("ActivityType");
					if (vValue is Guid)
					{
						// ��������� ��� ��������� ������
						if (user.ManageActivityType((Guid)vValue))
							return true;
						// ���� �� ��� ���������� ���. �������, ���� �� ��������� ������������ �������� � ��, �� ��������� ������.  
						// � ��� "�����" �� �����.
						if (folderType != FolderTypeEnum.Directory && (Guid)xobj.GetLoadedPropValue("ActivityType") != (Guid)vValue)
						{
							sErrorDescription = "������������ ���� ��� ��������� ������ �� ��� ��������� ������";
							return false;
						}
					}
					else
					{
						// ��� ��������� ������ �� ���������. ���� ���� ����� �� "������", �� ����� ���������.
						if (user.ManageActivityType((Guid)xobj.GetLoadedPropValue("ActivityType")))
							return true;
					}

					vValue = xobj.GetUpdatedPropValue("Customer");
					if (vValue is Guid)
					{
						// ���������� ������ �� �������
						if (user.ManageOrganization((Guid)vValue))
							return true;
						// ���� �� ����������� ���. �������, ���� ������ �������a�� ������������ �������� � ��, �� ��������� ������
						// � ��� "�����" �� �����.
						if (folderType != FolderTypeEnum.Directory && (Guid)xobj.GetLoadedPropValue("Customer") != (Guid)vValue)
						{
							sErrorDescription = "������������ ���� ��� ��������� ������ �� �����������-�������";
							return false;
						}
					}
					else
					{
						// ������ �� ������� �� ����������. ���� ���� ����� �� "�������", �� ����� ���������
						if (user.ManageOrganization((Guid)xobj.GetLoadedPropValue("Customer")))
							return true;
					}

					if (folderType == FolderTypeEnum.Directory)
					{
						// RULE: ���� ������� ����� - �������, �� ���������� ��� � �������� ������� ����� ������������, 
						//		���������� ��������� ����������� "���������� ����������"
						// ����������: ��� ����� �������� �� �����, ������� ����� GetLoadedPropValue ���������
						if (xobj.GetUpdatedPropValue("Parent") is Guid)
						{
							// ��������: �.�. ��������� ���������� "������� �����" �� ���������, � ����� ����� �� ����������� � ��� ��������� ������,
							// �� ��� �� ����� GetObjectRights ������ ���, ��� �������� Parent �� read-only, 
							// ������ ������������ �������� �������� ����������� "���������� ����������" - ��� ��� ��������� ��� �� �����!
							// �������� ��, ��� � ����� ������� ���� ����� ��� ����������
							DomainObjectData xobjFolderNew = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, true);
							FolderPrivilegesDefinitionContainer def = (FolderPrivilegesDefinitionContainer)m_provider.ObjectPrivilegeContainers["Folder"];
							XPrivilegeSet priv_set = def.GetPrivileges(user, xobjFolderNew.ObjectID, con);
							if (!priv_set.Contains(FolderPrivilegesItem.ManageCatalog.Name))
							{
								sErrorDescription = "������������ ���� ��� �������� �����";
								return false;
							}
						}
						return true;
					}
					return false;
				}
				return true;
			}
		}

		/// <summary>
		/// �������� �� ����������� �������� �������
		/// </summary>
		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			DomainObjectData xobjParent = null;		// ������������ �����
			// RULE: ���� ������ ������ �� ��������, �� �������� ��� ���������. ���� �� "������", �� �������� ����� ���������
			if (xobj.GetUpdatedPropValue("Parent") is Guid)
			{
				xobjParent = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, true);
                if (
					((FolderStates)xobjParent.GetPropValue("State", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps) == FolderStates.Closed)
					|| ((FolderStates)xobjParent.GetPropValue("State", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps) == FolderStates.WaitingToClose)
					|| ((FolderStates)xobjParent.GetPropValue("State", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps) == FolderStates.Frozen)
					)
					return XNewObjectRights.EmptyRights;
			}
			Guid activityType = Guid.Empty;
			object vValue;
			vValue = xobj.GetUpdatedPropValue("ActivityType");
			if (vValue is Guid)
			{
				activityType = (Guid)vValue;
				if (user.ManageActivityType(activityType))
					return XNewObjectRights.FullRights;
			}
			Guid orgID = Guid.Empty;
			vValue = xobj.GetUpdatedPropValue("Customer");
			if (vValue is Guid)
			{
				orgID = (Guid)vValue;
				if (user.ManageOrganization(orgID))
					return XNewObjectRights.FullRights;
			}

			vValue = xobj.GetUpdatedPropValue("Type");
			if (vValue is Int16)
			{
				FolderTypeEnum nType = (FolderTypeEnum)vValue;
				if (xobjParent != null)
				{
					// RULE: ������� ������� � ������ ����� ����� ������������, ���������� � ��� ����������� "���������� ����������"
					// �� ��� �� ��������� � ����� ������
					if (nType == FolderTypeEnum.Directory)
					{
						if (xobjParent.IsNew)
							return XNewObjectRights.FullRights;
						else
						{
							FolderPrivilegesDefinitionContainer def = (FolderPrivilegesDefinitionContainer)m_provider.ObjectPrivilegeContainers["Folder"];
							XPrivilegeSet priv_set = def.GetPrivileges(user, xobjParent.ObjectID, con);
							if (priv_set.Contains(FolderPrivilegesItem.ManageCatalog.Name))
								return XNewObjectRights.FullRights;
						}
					}
					// RULE: ��������� ������� � �������� ����� ������ �� �������� ������
					else if (nType == FolderTypeEnum.Presale || nType == FolderTypeEnum.Tender)
						return XNewObjectRights.EmptyRights;
				}

				// RULE: ���� �� ����� ��� ��������� ������, �� ����� ��� ����� � ������ �� �������, ��
				//	��������� �������� ��� ��������� ������ � �� �������
				if (activityType == Guid.Empty && orgID != Guid.Empty && nType != FolderTypeEnum.Directory)
				{
					XDbCommand cmd = con.CreateCommand(@"
					SELECT
						at.ObjectID
					FROM dbo.ActivityType at
					WHERE at.FolderType & @FolderType > 0 AND at.AccountRelated = ABS(1-(SELECT Home FROM Organization WHERE ObjectID = @OrgID))
					");
					cmd.Parameters.Add("FolderType", DbType.Int16, ParameterDirection.Input, false, vValue);
					cmd.Parameters.Add("OrgID", DbType.Guid, ParameterDirection.Input, false, orgID);

					using(IDataReader reader = cmd.ExecuteReader())
					{
						if (reader.Read())
						{
							activityType = reader.GetGuid(0);
							// ���� ��� ���� ��������� ������
							if (!reader.Read())
							{
								if (user.ManageActivityType(activityType))
									return XNewObjectRights.FullRights;
							}
						}
					}
				}
			}

			return XNewObjectRights.EmptyRights;
		}
	}

	[SecurityRightsChecker("ExternalLink")]
	public class ExternalLinkRightsChecker : ObjectRightsCheckerBase
	{
		public ExternalLinkRightsChecker(SecurityProvider provider) : base(provider, true) { }

		public override XObjectRights GetObjectRights(ITUser xuser, DomainObjectData xobj, XStorageConnection con)
		{
			if (xobj.GetLoadedPropValue("Folder") is Guid)
			{
				DomainObjectData xobjFolder = xobj.Context.GetLoadedStub("Folder", (Guid)xobj.GetLoadedPropValue("Folder"));
				FolderStates folderState = (FolderStates)xobjFolder.GetLoadedPropValueOrLoad(con, "State");

				return folderState == FolderStates.Open ? XObjectRights.FullRights : XObjectRights.ReadOnlyRights;
			}

			return base.GetObjectRights(xuser, xobj, con);
		}
	}

	[SecurityRightsChecker("SystemUser", "Employee")]
	public class UserRightsChecker: ObjectRightsCheckerBase
	{
		public UserRightsChecker(SecurityProvider provider): base(provider, true)
		{}
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
            // RULE: ���� ��� ���������� "���������� ��������������" - ������ ������ �� ������
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageUsers.Name))
                return XObjectRights.ReadOnlyRights;

            return XObjectRights.FullRights;
        }

		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
            // RULE: ���� ��� ���������� "���������� ��������������" - ������� ���
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageUsers.Name))
                return XNewObjectRights.EmptyRights;

            return XNewObjectRights.FullRights;
		}
        public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            // RULE: ���� ��� ���������� "���������� ��������������" - ������� ���
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageUsers.Name))
            {
                sErrorDescription = "��������� ������������ ����������� ����� ������ ������������, ���������� ����������� '" + SystemPrivilegesItem.ManageUsers.Description + "'";
                return false;
            }
            

            return true;
        }
	}

    [SecurityRightsChecker("Direction")]
    public class DirectionRightsChecker : ObjectRightsCheckerBase
    {
        public DirectionRightsChecker(SecurityProvider provider)
            : base(provider, true)
        { }
        public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
        {
            // RULE: ���� ��� ���������� "���������� �������������" - ������ ������ �� ������
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name))
                return XObjectRights.ReadOnlyRights;

            if (xobj.GetUpdatedPropValue("Department") is Guid)
            {
                // RULE: ���� ����������� �������� - ������ ������ �� ������
                DomainObjectData xobjDepartment;
                xobjDepartment = xobj.Context.Get(con, xobj, "Department", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
                if (xobjDepartment != null)
                {
                    bool isArchive = (bool)xobjDepartment.GetLoadedPropValueOrLoad(con, "IsArchive");

                    if (isArchive)
                        return XObjectRights.ReadOnlyRights;
                }
            }
            return XObjectRights.FullRights;
        }

        public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
        {
            // RULE: ���� ��� ���������� "���������� �������������" - ������� ���
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name))
                return XNewObjectRights.EmptyRights;

            if (xobj.GetUpdatedPropValue("Department") is Guid)
            {

                // RULE: ���� ����������� �������� - ������ ������ �� ������
                DomainObjectData xobjDepartment;
                xobjDepartment = xobj.Context.Get(con, xobj, "Department", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true, DomainObjectDataSet.PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);
                Guid id = xobjDepartment.ObjectID;
                if (xobjDepartment != null)
                {
                    bool isArchive = (bool)xobjDepartment.GetPropValueAnyhow("IsArchive", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, con);

                    if (isArchive)
                        return XNewObjectRights.EmptyRights;
                }
            }
            return XNewObjectRights.FullRights;
        }
        public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            // RULE: ���� ��� ���������� "���������� ��������������" - ������� ���
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name))
            {
                sErrorDescription = "��������� ������������ ����� ������ ������������, ���������� ����������� '" + SystemPrivilegesItem.ManageRefObjects.Description + "'";
                return false;
            }

            if (xobj.GetLoadedPropValueOrLoad(con, "Department") is Guid)
            {
                // RULE: ���� ����������� �������� - ��������� ������
                DomainObjectData xobjDepartment;
                xobjDepartment = xobj.Context.Get(con, xobj, "Department", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true, DomainObjectDataSet.PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);
                if (xobjDepartment != null)
                {
                    bool isArchive = (bool)xobjDepartment.GetLoadedPropValueOrLoad(con, "IsArchive");

                    if (isArchive)
                    {
                        sErrorDescription = "����������� ��������. �������������� ���������.";
                        return false;
                    }
                }
            }
            return true;
        }
    }

    [SecurityRightsChecker("Department")]
    public class DepartmentRightsChecker : ObjectRightsCheckerBase
    {
        public DepartmentRightsChecker(SecurityProvider provider)
            : base(provider, true)
        { }
        public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
        {
            // RULE: ���� ��� ���������� "���������� �������������" - ������ ������ �� ������
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name))
                return XObjectRights.ReadOnlyRights;

            if (xobj.GetUpdatedPropValue("Parent") is Guid)
            {
                // RULE: ���� ����������� ����������� �������� - ������ ������ �� ������
                DomainObjectData xobjDepartment;
                xobjDepartment = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true, DomainObjectDataSet.PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);
                if (xobjDepartment != null)
                {
                    bool isArchive = (bool)xobjDepartment.GetLoadedPropValueOrLoad(con, "IsArchive");

                    if (isArchive)
                        return XObjectRights.ReadOnlyRights;
                }
            }
            return XObjectRights.FullRights;
        }

        public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
        {
            // RULE: ���� ��� ���������� "���������� �������������" - ������� ���
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name))
                return XNewObjectRights.EmptyRights;

            if (xobj.GetUpdatedPropValue("Parent") is Guid)
            {
                // RULE: ���� ����������� ����������� �������� - ������ ������ �� ������
                DomainObjectData xobjDepartment;
                xobjDepartment = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
                if (xobjDepartment != null)
                {
                        
                      bool isArchive = (bool)xobjDepartment.GetPropValueAnyhow("IsArchive",DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, con);
                      if (isArchive)
                        return XNewObjectRights.EmptyRights;
                }
                
            }
            return XNewObjectRights.FullRights;
        }
        public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            // RULE: ���� ��� ���������� "���������� ��������������" - ������� ���
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name))
            {
                sErrorDescription = "��������� ������������ ������������� ����� ������ ������������, ���������� ����������� '" + SystemPrivilegesItem.ManageRefObjects.Description + "'";
                return false;
            }

            if (xobj.GetLoadedPropValueOrLoad(con, "Parent") is Guid)
            {
                // RULE: ���� ����������� �������� - ��������� ������
                DomainObjectData xobjDepartment;
                xobjDepartment = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true, DomainObjectDataSet.PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);
                if (xobjDepartment != null)
                {
                    bool isArchive = (bool)xobjDepartment.GetLoadedPropValueOrLoad(con, "IsArchive");

                    if (isArchive)
                    {
                        sErrorDescription = "����������� ����������� ��������. �������������� ���������.";
                        return false;
                    }
                }
            }
            return true;
        }
    }

    [SecurityRightsChecker("EmployeeRate")]
    public class EmployeeRateRightsChecker : ObjectRightsCheckerBase
    {
        public EmployeeRateRightsChecker(SecurityProvider provider)
            : base(provider, false)
        { }
        public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
        {
            if (user.HasPrivilege(SystemPrivilegesItem.ManageUsers.Name))
            {
                DateTime dtRateDate = (DateTime)xobj.GetLoadedPropValueOrLoad(con,"Date");
                if (dtRateDate > ApplicationSettings.GlobalBlockPeriodDate)
                {
                    return XObjectRights.FullRights;
                }
            }
            return XObjectRights.ReadOnlyRights;
        }

        public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
        {
            if (user.HasPrivilege(SystemPrivilegesItem.ManageUsers.Name))
            {
               return XNewObjectRights.FullRights;
            }
            return XNewObjectRights.EmptyRights;
        }
        protected override bool hasInsertObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            DateTime dtRateDate = (DateTime)xobj.GetLoadedPropValueOrLoad(con, "Date");
            if (dtRateDate > ApplicationSettings.GlobalBlockPeriodDate)
            {  
                return true;
            }
            sErrorDescription = "���� ����� (" + dtRateDate + ") �������� � �������� ������";
            return false;
        }
        public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            DateTime dtRateDate = new DateTime();
            // ���� �������� ���� �����, ���� ���� ������� ����� �����, �� ���� ��������� ���� �� ��������� � �������� ������
            if (xobj.HasUpdatedProp("Date"))
            {
                dtRateDate = (DateTime)xobj.GetUpdatedPropValue("Date");
                if (dtRateDate > ApplicationSettings.GlobalBlockPeriodDate)
                {
                    return true;
                }
                sErrorDescription = "���� ����� (" + dtRateDate + ") �������� � �������� ������";
                return false;
            }
            return true;
        }
    }
	[SecurityRightsChecker("Incident")]
	public class IncidentRightsChecker: ObjectRightsCheckerBase
	{
		public IncidentRightsChecker(SecurityProvider provider): base(provider, true)
		{}
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			XObjectRightsBuilder rightsBuilder = new XObjectRightsBuilder();
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
            if (!xobjFolder.IsFullyLoaded) xobjFolder.Load(con);
			// RULE: � �������� ������� ������� � ��������� ��� �� � ����
            if (
				(FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Closed
				|| (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.WaitingToClose
				|| (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Frozen
				)
				return XObjectRights.ReadOnlyRights;

			// ������� ��� ��������: � ��������� ���� ������� � � ��������� ���� ������� ��� �������� �����
			XDbCommand cmd = con.CreateCommand(@"
				SELECT TOP 1
					1,
					CASE WHEN Worker = @EmployeeID THEN 1 ELSE 0 END AS HasOwnTask
				FROM Task t 
				WHERE t.Incident = @IncidentID
				ORDER BY 2 DESC
				");
			cmd.Parameters.Add("IncidentID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
			cmd.Parameters.Add("EmployeeID", DbType.Guid, ParameterDirection.Input, false, user.EmployeeID);
			using(IDataReader reader = cmd.ExecuteReader())
			{
				if (reader.Read())
				{
					// ���� ������ ���-�� ������, ������ � ��������� ���� ������� - �������� ��� ������
					rightsBuilder.AddReadOnlyPropFinal("Type");
					// ������� HasOwnTask � ���������� ����� ��-NULL, ���� ������� ���� ����� ������� � ���������
					if (reader.GetInt32(reader.GetOrdinal("HasOwnTask")) == 1)
					{
						// RULE: ������ �������������� �� �������� �������� ����, ��� �������� � ��������� ���� ������� (Task)
						//		�� �� �� ����� �������� �������o "Folder" (�.�. ���������� ��������)
						rightsBuilder.SetAllowChangeExcept(new string[] {"Folder"});
					}
				}
			}

			// RULE: ����� ������� �� ����� �������� �������� ����� � ����������� "���������� �����������" � �����
			//	(��� ������ ����������� ������� ���� �� ����������� � ��� ��������� ������)
			if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageIncidents, xobjFolder, con))
			{
				rightsBuilder.SetAllowFullChange();
				rightsBuilder.SetAllowDelete();
			}

			// RULE: ������������, ���������� ��������� ����������� "������� ����� � ����������", ����� ���������� ��������
			if (user.HasPrivilege(SystemPrivilegesItem.MoveFoldersAndIncidents.Name))
				rightsBuilder.SetAllowChangeProps(xobj.TypeInfo.Properties, new string[] {"Folder"});

			return rightsBuilder.GetObjectRights();

			// RULE: ���� �� ��������� ���� �������� (�.�. �� ���� �� �� ������ �������), �� ������� ��� ������
			// ���������������, �.�. �� ���� ����� �� ����� �������. �� ���� ���� � ��� �� ������ ������� ��������, ���� �� ���� ���� ��������
			/*
			cmd = con.CreateCommand("SELECT 1 FROM Task t JOIN TimeSpent ts ON ts.Task = t.ObjectID WHERE t.Incident = @ObjectID");
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
			bool bDenyDelete = false;
			if (cmd.ExecuteScalar() != null)
			{
				// ���-�� ������� - ������ �������� �� ����� ����
				bDenyDelete = true;
			}
			if (!bDenyDelete)
			{ }
			return new XObjectRights(!bDenyDelete, true);
			*/
		}

		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			// RULE: ���� ������ �� ����� ��� �� �����a, ������ �� �������� ��� ����� ����������� �������� - �������� 
			// (��������� ����� ��� ����������)
			if (!(xobj.GetUpdatedPropValue("Folder") is Guid))
				return XNewObjectRights.FullRights;
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, false);
			if (xobjFolder == null)
				return XNewObjectRights.FullRights;

			// RULE: �������� ��������� ��������� ����, �� ������, ���� ����� �� ��������� � ��������� "�������"
			FolderStates folderState = (FolderStates)xobjFolder.GetLoadedPropValueOrLoad(con, "State");
            if (folderState != FolderStates.Closed && folderState != FolderStates.WaitingToClose && folderState != FolderStates.Frozen)
				return XNewObjectRights.FullRights;
			
			return XNewObjectRights.EmptyRights;
		}

		public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			if (!base.HasSaveObjectRight(user, xobj, con, out sErrorDescription))
				return false;
			if (!xobj.IsNew)
			{	
				// RULE: ������ �������� ��� ��������a, ���� �� ���� ���� �������
				if (xobj.HasUpdatedProp("Type"))
				{
					if (xobj.HasUpdatedProp("Tasks"))
					{
						if (((Guid[])xobj.GetUpdatedPropValue("Tasks")).Length > 0)
						{
							sErrorDescription = "������ �������� ��� ��������a, ���� � ��� ��������� �����������";
							return false;
						}
					}
				}
				// ���������� ������ �� ����� - ������� ���������
				if (xobj.GetUpdatedPropValue("Folder") is Guid)
				{
                    DomainObjectData xobjFolderNew = xobj.Context.Get(con, xobj, "Folder",DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, true);
					xobjFolderNew.Load(con);
                    DomainObjectData xobjFolderOld = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
                    xobjFolderOld.Load(con);
                    if (ApplicationSettings.GlobalBlockPeriodDate != DateTime.MinValue)
                    {
                        if (CommonRightsRules.CheckIncidentForBlockedPeriod(xobjFolderNew, xobjFolderOld, con))
                        {
                            object vValue = null;
                            XDbCommand cmd = con.CreateCommand(@"
                            SELECT TOP 1 1
                                FROM [dbo].[TimeSpent] ts 
	                            JOIN dbo.Task tsk ON tsk.ObjectID = ts.[Task]
	                            JOIN dbo.Incident inc ON inc.ObjectID = tsk.Incident
                            WHERE ts.[RegDate] <= @Date AND inc.ObjectID = @ObjectID
                        ");
                            cmd.Parameters.Add("ObjectID", XPropType.vt_uuid, ParameterDirection.Input, false, xobj.ObjectID);
                            cmd.Parameters.Add("Date", XPropType.vt_dateTime, ParameterDirection.Input, false, ApplicationSettings.GlobalBlockPeriodDate);
                            vValue = cmd.ExecuteScalar();
                            if (vValue != null && (Convert.ToInt32(vValue) == 1))
                            {
                                sErrorDescription = "�������� �������� ������������, ������������������ � �������� ������";
                                return false;
                            }
                        }
                    }
					// RULE: � �������� ����� ���������� �������� ������
					if ((FolderStates)xobjFolderNew.GetLoadedPropValue("State") == FolderStates.Closed || (FolderStates)xobjFolderNew.GetLoadedPropValue("State") == FolderStates.WaitingToClose || (FolderStates)xobjFolderNew.GetLoadedPropValue("State") == FolderStates.Frozen)
					{
						sErrorDescription = "������� ��������� � �����, ����������� � ��������� \"�������\", \"�������� ��������\" ��� \"����������\", ��������";
						return false;
					}

					// RULE: ���������� �������� � ����� ����� (������� "�� �����" �� ��������� � GetObjectRights) ������������: 
					//		���������� ��������� ����������� "������� ����� � ����������", 
					//		���������� ��������� ����������� "���������� �����������"
					if (!user.HasPrivilege(SystemPrivilegesItem.MoveFoldersAndIncidents.Name))
						if (!m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageIncidents, xobjFolderNew, con))
						{
							// TODO: ������������ sErrorDescription
							return false;
						}

					// ���� �����, ��: ��������� �������� � ���������� ������ � ����� ���� ���������� ����� �� �������, 
					//	���� ����� � ������� �� ��������� �����������
				}
			}

			// TODO:
			// RULE: �������� ��������� ��������� ����� ������ � ������������ � workflow, 
			// ���� ��� ������� ���������� "���������� �����������" (ManageIncidents)
			return true;
		}

    }

	[SecurityRightsChecker("IncidentStateHistory")]
	public class IncidentStateHistoryRightsChecker: ObjectRightsCheckerBase
	{
		/// <summary>
		/// ������ � �������� ��������
		/// </summary>
		/// <param name="provider"></param>
		public IncidentStateHistoryRightsChecker(SecurityProvider provider): base(provider, false)
		{}
	}

	[SecurityRightsChecker("Task")]
	public class TaskRightsChecker: ObjectRightsCheckerBase
	{
		public TaskRightsChecker(SecurityProvider provider): base(provider, true)
		{}
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			Debug.Assert(con != null);
			DomainObjectDataSet dataSet = xobj.Context;
			// RULE: ������������� � ������� ����� ������� ����� ��������� � ����������� "���������� �������� ���������� ���������"
			// ������� ������������� �����, � ����� ������������� ������� � ���� ��������� ������, 
			// �.�. �� ��� ����������� ���������� ����� �� �����
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobj, "Incident.Folder", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, false);
			if (xobjFolder == null || !xobjFolder.HasLoadedProp("Customer") || !xobjFolder.HasLoadedProp("ActivityType") || !xobjFolder.HasLoadedProp("State"))
			{
				// ������� ��� � ���������, ���� ������ ����, �� ���� �� �������: Customer, ActivityType, State �� ���������
				// �������� ��� � ������� ������������ �������, �� ����������� ����������� (DataSet ������ �� �������� ���������� ���������)
				XDbCommand cmd = con.CreateCommand(String.Format(@"
					SELECT i.Folder, f.Customer, f.ActivityType, f.State, 
						t.Worker, t.Planner
					FROM {0} i 
						JOIN {1} t ON t.Incident = i.ObjectID 
						JOIN {2} f ON f.ObjectID = i.Folder
					WHERE t.ObjectID = @ObjectID",
					con.GetTableQName("Incident"),	// 0
					con.GetTableQName("Task"),		// 1
					con.GetTableQName("Folder")		// 2
					));
				cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
				using(IDataReader reader = cmd.ExecuteReader())
				{
					if (reader.Read())
					{
						if (xobjFolder == null)
							xobjFolder = dataSet.GetLoadedStub("Folder", reader.GetGuid(reader.GetOrdinal("Folder")) );
						xobjFolder.SetLoadedPropValue("Customer", reader.GetGuid( reader.GetOrdinal("Customer") ));
						xobjFolder.SetLoadedPropValue("ActivityType", reader.GetGuid( reader.GetOrdinal("ActivityType") ));
						xobjFolder.SetLoadedPropValue("State", (FolderStates)reader.GetInt16( reader.GetOrdinal("State") ));
						xobj.SetLoadedPropValue("Worker", reader.GetGuid(reader.GetOrdinal("Worker")));
						xobj.SetLoadedPropValue("Planner", reader.GetGuid(reader.GetOrdinal("Planner")));
					}
					else
						throw new XObjectNotFoundException("�� ������� ��������� ����� ��� ������� � ��������������� " + xobj.ObjectID);
				}
			}
		
			// ������ � ��� ���� �������� ����� (�� ��-���� Customer, ActivityType, State)
			if ( (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Closed)
				return XObjectRights.ReadOnlyRights;

			// ���� ���� �������� ����������� "���������� �������� ���������� ���������" � ����� 
			// (� ������ ���������� �� �����������-������� � ActivityType)
			if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageIncidentParticipants, xobjFolder, con))
				return XObjectRights.FullRights;
			
			// ���� �� �����, ������� ���� �� �������� ����������� "���������� �������� ���������� ���������" � �����

			// RULE: ������������� ������� ����� ��� �����������, ���� ������� �� ����� ������������� ������� "����������"
			// ������� ������������� ����������-����������� �������
			Guid workerID = (Guid)xobj.GetLoadedPropValue("Worker");
			// ���� ����������� - ��� ������� ���������, �� ������������� ������� �� �����, ����� ������� "����", "��������", "�����������"
			if (workerID == user.EmployeeID)
			{
				if (!(bool)xobj.GetLoadedPropValueOrLoad(con, "IsFrozen"))
				{
					// RULE: ���� ������� ������������ �������� ������������� ������� (�.�. �� ��� ����� ��������������� �����),
					//		���� �� ��������� �������� "����a���������� �����" � ���� ���, ����� ����
					string[] aReadOnlyProps;
					if ((Guid)xobj.GetLoadedPropValue("Planner") == user.EmployeeID)
						aReadOnlyProps = new string[] { "Role", "Incident", "Worker", "IsFrozen", "PlannedTime" };
					else
						aReadOnlyProps = new string[] { "Role", "Incident", "Worker", "IsFrozen" };
					
					return new XObjectRights(false, aReadOnlyProps);
				}
			}

			return XObjectRights.ReadOnlyRights;
		}

		/// <summary>
		/// ���������� ������ �������
		/// </summary>
		/// <param name="user"></param>
		/// <param name="xobj"></param>
		/// <param name="con"></param>
		/// <returns></returns>
		protected override bool hasInsertObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			DomainObjectData xobjIncident = xobj.Context.Get(con, xobj, "Incident", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, false);
			if (xobjIncident == null)
				return false;
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobjIncident, "Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, true);
			if (xobjFolder == null)
				return false;

			// RULE: ��������� ������� � ���������, ����������� � �������� �����, ������ ������
			if ((FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Closed)
			{
				sErrorDescription = "������ ������� ������� � �����, ����������� � ��������� '�������'";
				return false;
			}

			// RULE: ����� �� �������� � �������������� ������� ����� ���� ���������� � �����, � ������� ��������� ��������, ����������� "���������� �������� ���������� ���������"
			if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageIncidentParticipants, xobjFolder, con))
				return true;

			// ���������� "���������� �������� ���������� ���������" � ����� ���, ������
			// � ����� ��������� ��������� ������� ����� ��� ���� (����������� ����� �������������)
			if (xobj.HasUpdatedProp("Worker") && (Guid)xobj.GetUpdatedPropValue("Worker") != user.EmployeeID)
				return false;

			return true;
			// TODO: ��� ����� ���������, ��� ���� ����������
		}

		/// <summary>
		/// ��������� ���� �� �������� ������ �������
		/// </summary>
		/// <param name="user"></param>
		/// <param name="xobj"></param>
		/// <param name="con"></param>
		/// <returns></returns>
		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			DomainObjectData xobjIncident = xobj.Context.Get(con, xobj, "Incident", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, false);
			if (xobjIncident == null)
				return XNewObjectRights.EmptyRights;
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobjIncident, "Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, true);
			if (xobjFolder == null)
				return XNewObjectRights.EmptyRights;

			// RULE: ��������� ������� � ���������, ����������� � �������� �����, ������ ������
			if ((FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Closed)
				return XNewObjectRights.EmptyRights;

			// RULE: ����� �� �������� � �������������� ������� ����� ���� ���������� � �����, � ������� ��������� ��������, ����������� "���������� �������� ���������� ���������"
			if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageIncidentParticipants, xobjFolder, con))
				return XNewObjectRights.FullRights;

			// RULE: ��������� ������� ��� ���� ����� � ������� ��������� (����������� ������������� ���������� �������)
			// �� �.�. �� �� ����� ��� ���� ����� ����������� �������
			//if (xobjIncident.IsNew && xobj.HasUpdatedProp("Worker") && (Guid)xobj.GetUpdatedPropValue("Worker") == user.EmployeeID)
			return new XNewObjectRights(false, new string[] {"Role", "Incident", "Worker", "IsFrozen"});
		}
	}

	[SecurityRightsChecker("TimeSpent")]
	public class TimeSpentRightsChecker: ObjectRightsCheckerBase
	{
		public TimeSpentRightsChecker(SecurityProvider provider): base(provider, true)
		{}

		/// <summary>
		/// �������� ���� �� ������������ �, ��������, �� ����� ������.
		/// </summary>
		/// <param name="user"></param>
		/// <param name="xobj"></param>
		/// <param name="con"></param>
		/// <returns></returns>
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			string sDummy;
			return GetObjectRightsUniversal(user, xobj, con, out sDummy);
		}

		public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			if (!base.HasSaveObjectRight(user, xobj, con, out sErrorDescription))
				return false;

			// ������� �����. ��. GetObjectRights - ��� �� �� ��� ���������, ������� ����� �������� �� ����������
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobj, "Task.Incident.Folder", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
			// ���� ���������� ���� ��������, �� �������� �� ���������� � ������ ������������ ��������
			object vPropValue;
			vPropValue = xobj.GetUpdatedPropValue("RegDate");
			if (vPropValue is DateTime)
				if (CommonRightsRules.IsRegDateInBlockPeriod((DateTime)vPropValue, xobjFolder))
				{
					sErrorDescription = "�������� ���� �������� ������� �� ������� �������� � ��������������� ������";
					return false;
				}

			return true;
		}

		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			string sErrorDescription = null;
			XObjectRights rights = GetObjectRightsUniversal(user, xobj, con, out sErrorDescription );
			if (rights.AllowParticalOrFullChange)
				return XNewObjectRights.FullRights;

			return XNewObjectRights.EmptyRights;
		}

		protected override bool hasInsertObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			XObjectRights rights = GetObjectRightsUniversal(user, xobj, con, out sErrorDescription );
			if (rights.AllowParticalOrFullChange)
				return true;
			return false;
		}

		protected XObjectRights GetObjectRightsUniversal(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			DomainObjectDataSet dataSet = xobj.Context;
			xobj.Load(con);
			DomainObjectData xobjTask;
			DomainObjectData xobjIncident;
			DomainObjectData xobjFolder;

			// ������� �������, � �������� ��������� �������� (������ �� ������� ���������� �� �����)
			xobjTask = dataSet.Get(con, xobj, "Task", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
			if (xobjTask == null)
				return XObjectRights.NoAccess;
			// ������� ��������, � �������� ��������� ������� (������ �� �������� ���������� �� �����)
			xobjIncident = dataSet.Get(con, xobjTask, "Incident", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
			if (xobjIncident == null)
				return XObjectRights.NoAccess;
			// ������� �������� �����, � ������� ��������� ��������, � �������� ��������� �������, �� ������� ��������� ��������
			xobjFolder = dataSet.Get(con, xobjIncident, "Folder", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
			if (xobjFolder == null)
				return XObjectRights.NoAccess;

			// RULE: ���������, ������������� � ������� �������� � �������� ������� ��������� ����
			if ((FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Closed || (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.WaitingToClose || (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Frozen)
				return XObjectRights.ReadOnlyRights;

			// �������� ����� �� ��������� ���� �������� ������������ ������� �������� ��������
			// ����������: ������ ����� (GetObjectRights) ������������ � ��� ����� ��� �������� ���� �� ����������� ��������, 
			//	������� ������ ������������, ��� ������ ��� ��������.
			object vValue = xobj.GetPropValue("RegDate", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			if (vValue is DateTime)
			{
				DateTime dtTimeSpentDate = (DateTime)vValue;
				if (CommonRightsRules.IsRegDateInBlockPeriod(dtTimeSpentDate, xobjFolder))
				{
					sErrorDescription = "���� �������� (" + dtTimeSpentDate + ") �������� � �������� ������";
					return XObjectRights.ReadOnlyRights;
				}
			}

			// RULE: ���������, ������������� � ������� �������� ���������, ���� �������� ��������� � ����������� ���������,
			//
            vValue = xobjIncident.GetPropValue("State", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			if (vValue is Guid)
			{
				DomainObjectData xobjIncidentState = DomainObjectRegistry.Get("IncidentState", (Guid)vValue, con);
				IncidentStateCat incidentStateCat = (IncidentStateCat)xobjIncidentState.GetLoadedPropValue("Category");
                if (incidentStateCat == IncidentStateCat.Finished || incidentStateCat == IncidentStateCat.Declined || incidentStateCat == IncidentStateCat.Frozen)
                {
                    //���� ��� ���� ���������� ��������� ���������,�� ����� ��������� �������� �����
                    if ((xobj.IsNew) && (xobjIncident.HasUpdatedProp("State")))
                    {
                        Guid newStateValue = (Guid) xobjIncident.GetUpdatedPropValue("State");
                        if (newStateValue == (Guid) vValue)
                        {
                            sErrorDescription = "�������� ������� �� �������� � ��������� '" + xobjIncidentState.GetLoadedPropValue("Name").ToString() + "' ���������";
                            return XObjectRights.ReadOnlyRights;
                        }

                    }
                   else
                    {
                        return XObjectRights.ReadOnlyRights;
                    }
                }

			}
			
			// RULE: ��������� ����� ������������� � ������� �������� �� ���������� � ������, � ������� �� �������� ����������� "���������� ������ ����������".
			if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.EditIncidentTimeSpent, xobjFolder, con))
				return XObjectRights.FullRights;
		
			// RULE: ��������� ����� ���������, ������������� � ������� �������� ��� ������ �������, ���� � ���� �� ���������� ������� "����������"
			vValue = xobjTask.GetPropValue("Worker", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			if (vValue is Guid)
			{
				Guid userID = (Guid)vValue;
				// ����������: ��� ������ ������� ������� ������� "����������" ������ �� �����, �.�. �������, ��� �� �������
				vValue = xobjTask.GetPropValue("IsFrozen", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
				bool bIsFrozen = false;
				if (vValue is Boolean)
					bIsFrozen = (bool)vValue;
				if (userID == user.EmployeeID && !bIsFrozen)
					return XObjectRights.FullRights;
			}

			return XObjectRights.ReadOnlyRights;
		}
	}

	[SecurityRightsChecker("ProjectParticipant")]
	public class ProjectParticipantRightsChecker: ObjectRightsCheckerBase
	{
		public ProjectParticipantRightsChecker(SecurityProvider provider): base(provider, true)
		{}

		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			Guid employeeID = (Guid)xobj.GetLoadedPropValueOrLoad(con, "Employee");
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true, DomainObjectDataSet.PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);

			// RULE: ��������, �������������� � �������� ���������� ����� �������� �������������, ���������� ����������� 
			// "���������� ��������� ��������".
			// ����������: �.�. ��� �������� ���� �� ProjectParticipant, ����������� � ��, �� ����� ����� ��������� � ��
			if (xobjFolder == null)
			{
				if (hasAllRightsByGlobalPrivileges(user, xobj, con))
					return new XObjectRights(user.EmployeeID != employeeID, new string[] {"Employee"});
				return XObjectRights.ReadOnlyRights;
			}

			// �������� ������ �� ����� � ���������� ���������
			if (hasAllRightsByFolderPrivileges(user, xobjFolder, con))
				return new XObjectRights(user.EmployeeID != employeeID, new string[] { "Employee" });

			return XObjectRights.ReadOnlyRights;
		}

		/// <summary>
		/// �������� ���� �� ����� ������ (��� ���������� � �����������)
		/// </summary>
		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			object vValue = xobj.GetUpdatedPropValue("Employee");
            
            Guid employeeID = (vValue==null)? Guid.Empty:(Guid)vValue;
            
			DomainObjectData xobjFolder;
			// RULE: ����� �� ��������� ������� ��� ���� �������� �� ������� ���� � ������������ �����!
			// ����������: ����� ���������, ��� ����� ������������ ���������� "���������� ��������� ��������" 
			// �� ����� ��� ������ �������� - ���� �� ������ �������� ���� ����� ����������.
			if (employeeID == user.EmployeeID)
			{
				xobjFolder = xobj.Context.Get(con, xobj, "Folder.Parent", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, true);
			}
			else
			{
				// ����� ����� �� ��������� ��������� ������� ��������� �� ������� ���������� � ���� �� �������
				xobjFolder = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, true);
			}

			if (xobjFolder == null)
			{
				// �������� ��������� � �������� �����
				if (hasAllRightsByGlobalPrivileges(user, xobj, con))
					return XNewObjectRights.FullRights;
				return XNewObjectRights.EmptyRights;
			}
			if (hasAllRightsByFolderPrivileges(user, xobjFolder, con))
				return XNewObjectRights.FullRights;
			return XNewObjectRights.EmptyRights;
		}
        public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            if (xobj.IsNew)
                return hasInsertObjectRight(user, xobj, con, out sErrorDescription);
            else 
            {
                XObjectRights rights = GetObjectRights(user, xobj, con);
                if (rights.AllowFullChange)
                    return true;
                else if (rights.AllowParticalOrFullChange)
                {
                    // �������������� �����, �� �� ��� �������� (���� ������ ��� ���� �� ���������)
                    return !hasObjectChangedReadOnlyProps(xobj, rights, ref sErrorDescription);
                }
            }
            return false;
        }
		private bool hasAllRightsByFolderPrivileges(ITUser user, DomainObjectData xobjFolder, XStorageConnection con)
		{
            if (!xobjFolder.IsNew)
            {
                if ((FolderStates)xobjFolder.GetLoadedPropValueOrLoad(con, "State") == FolderStates.WaitingToClose ||
					(FolderStates)xobjFolder.GetLoadedPropValueOrLoad(con, "State") == FolderStates.Frozen ||
                    (FolderStates)xobjFolder.GetLoadedPropValueOrLoad(con, "State") == FolderStates.Closed)
                    return false;
            }
			if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageTeam, xobjFolder, con))
				return true;
			return false;
		}

		private bool hasAllRightsByGlobalPrivileges(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, true);

			if (xobjFolder == null)
				return false;
            if (!xobjFolder.IsFullyLoaded) xobjFolder.Load(con);
            if (!xobjFolder.IsNew)
            {
                if ((FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.WaitingToClose ||
					(FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Frozen ||
                    (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Closed)
                    return false;
            }
			Guid orgID = (Guid)xobjFolder.GetPropValue("Customer", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps);
			Guid activityTypeID = (Guid)xobjFolder.GetPropValue("ActivityType", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps);
			if (user.ManageOrganization(orgID) || user.ManageActivityType(activityTypeID))
				return true;
			return false;
		}
	}

	[SecurityRightsChecker("TimeLoss")]
	public class TimeLossRightsChecker: ObjectRightsCheckerBase
	{
		public TimeLossRightsChecker(SecurityProvider provider): base(provider, true)
		{}

		/// <summary>
		/// ����� �� ������������ ������
		/// </summary>
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			xobj.Load(con);
			DateTime dtLossFixedDate = DateTime.MinValue;
			object vValue = xobj.GetPropValue("LossFixed", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			if (vValue is DateTime)
			{
				dtLossFixedDate = (DateTime)vValue;
			}

			// RULE: ���� �������� ��������� � �������, ��
			if (xobj.GetLoadedPropValue("Folder") is Guid)
			{
				DomainObjectData xobjFolder = xobj.Context.Get(con, "Folder", (Guid)xobj.GetLoadedPropValue("Folder"));
				if (!xobjFolder.HasLoadedProp("State"))
					xobjFolder.Load(con);
				FolderStates folderState = (FolderStates)xobjFolder.GetLoadedPropValue("State");
				if (folderState == FolderStates.Closed || folderState == FolderStates.WaitingToClose || folderState == FolderStates.Frozen)
					return XObjectRights.ReadOnlyRights;
				if((bool)xobjFolder.GetLoadedPropValue("IsLocked"))
					return XObjectRights.DeleteOrReadRights;

				if (dtLossFixedDate > DateTime.MinValue)
					if (CommonRightsRules.IsRegDateInBlockPeriod(dtLossFixedDate, xobjFolder))
						return XObjectRights.ReadOnlyRights;
			}
			else
			{
				if (dtLossFixedDate > DateTime.MinValue)
					if (dtLossFixedDate <= ApplicationSettings.GlobalBlockPeriodDate)
						return XObjectRights.ReadOnlyRights;
			}

			// RULE: ��������� ����� ������������� � ������� ����� ��������, ���� �������� ��������� ����������� "���������� ������ ����������"
			if (user.HasPrivilege(SystemPrivilegesItem.ManageTimeLoss.Name))
                return new XObjectRights(true, new string[] { "Worker" });

			// RULE: ��������� ����� ������������� �������� � ������, � ������� � ���� ���� ��������� ���������� "���������� ������ ����������"
			if (xobj.GetLoadedPropValue("Folder") is Guid)
			{
				// ��������� ��� ���������� ������ ������������ ����������, ��������� � ��
				XDataSource ds = con.GetDataSource("CheckEmployeesFolderPrivilegesForFolder");
				ds.SubstituteNamedParams(
					new Dictionary<string, object>()
					{
						{ "Employee", user.EmployeeID },
						{ "Folder", xobj.GetLoadedPropValue("Folder") },
						{ "Privileges", (int)FolderPrivileges.EditIncidentTimeSpent }
					}, false);

				if ((int)ds.ExecuteScalar() == 1)
					return XObjectRights.FullRights;
			}

			// RULE: ��������� ����� ������������� � ������� ��� �������� �������
			Guid workerID = (Guid)xobj.GetPropValue("Worker", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			if (workerID == user.EmployeeID)
				return new XObjectRights(true, new string[] {"Worker"} );

			return XObjectRights.ReadOnlyRights;
		}

		/// <summary>
		/// ����� �� ����� ������, ����������� ��������
		/// </summary>
		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			if (xobj.GetUpdatedPropValue("Folder") is Guid)
			{
				DomainObjectData xobjFolder = xobj.Context.Get(con, "Folder", (Guid)xobj.GetUpdatedPropValue("Folder"));
				// RULE: ��������� �������� �� �������� ������ ������ ������
				FolderStates folderState = (FolderStates)xobjFolder.GetLoadedPropValueOrLoad(con, "State");
				if (folderState == FolderStates.Closed || folderState == FolderStates.WaitingToClose || folderState == FolderStates.Frozen)
					return XNewObjectRights.EmptyRights;
				// RULE: ��������� �������� �� "���������������" ����� ������ ������
				if((bool)xobjFolder.GetLoadedPropValueOrLoad(con, "IsLocked"))
					return XNewObjectRights.EmptyRights;

				if (user.HasPrivilege(SystemPrivilegesItem.ManageTimeLoss.Name))
					return XNewObjectRights.FullRights;

				// RULE: ���� �������� ��������� �� ������, �� ������������ ������ �������� � ������� ����������� "�������� �������� �� ������"
				if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.SpentTimeByProject, xobjFolder, con))
					return new XNewObjectRights(true, new string[] {"Worker"} );

				return XNewObjectRights.EmptyRights;
			}
			// RULE: ���� ������������ �� �������� ����������� "���������� ������ ����������", 
			// �� �������� �� ����� ��������� ������ ��� ����, �.�. ������ �� ���������� � ���������� ��� ���� ����������
			// ������ �� ����, �� ��������� � ������� ����������
			if (!user.HasPrivilege(SystemPrivilegesItem.ManageTimeLoss.Name))
				return new XNewObjectRights(true, new string[] {"Worker"} );

			return XNewObjectRights.FullRights;
		}

		/// <summary>
		/// �������� ������� ��� ���������� (��� ������, ��� � �����������)
		/// </summary>
		public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			bool bAllowPotentially = false;
            if (xobj.IsNew)
			{
				// RULE: ��������� �������� ����� ���� ��������� ��� ����, ���� ��������� ���������� ����������� "���������� ������ ����������"
				if (xobj.GetUpdatedPropValue("Worker") is Guid)
					if (user.EmployeeID == (Guid)xobj.GetUpdatedPropValue("Worker"))
						bAllowPotentially = true;
				if (!bAllowPotentially)
					if (user.HasPrivilege(SystemPrivilegesItem.ManageTimeLoss.Name))
						bAllowPotentially = true;
			}
			else
			{
				if (!base.HasSaveObjectRight(user, xobj, con, out sErrorDescription))
					return false;
				// ���� �����, ������ �������� ������ ����� ������,
				// ������ ��������, ��� ����� ������ ���������
				bAllowPotentially = true;
			}
			if (bAllowPotentially)
			{
				// ������� �����
                
				object vValue = xobj.GetPropValue("Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps);
				DomainObjectData xobjFolder = null;
				if (vValue is Guid)
				{
                 	xobjFolder = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, true);
					// �������� ������� � ����� ������������ ���������, ������������ ��������
					if((bool)xobjFolder.GetPropValue("IsLocked", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps))
					{
						sErrorDescription = "�������� � ������ ����� ���������. �� �������� �������� ����������� � ���������.";
						return false;
					}
					// RULE: ���� �������� ��������� �� ������, �� ������������ ������ �������� � ������� ����������� "�������� �������� �� ������"
					if (!m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.SpentTimeByProject, xobjFolder, con))
					{
						sErrorDescription = "������������ ������ �������� � ������� ����������� \"�������� ������� �� ������\". �� �������� �������� ����������� � ���������.";
						return false;
					}
				}
             	// �������� ����� ���� �������� �� �� ��������� � �������� ������ (��� ��� ������, ��� � ��� ����������� �������)
				if (xobj.GetUpdatedPropValue("LossFixed") is DateTime)
				{
					DateTime dtLossFixedDate = (DateTime)xobj.GetPropValue("LossFixed", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
					// ������� ���������� ������ �� ������ (��� ����� �������� ���� ������)

					if (CommonRightsRules.IsRegDateInBlockPeriod(dtLossFixedDate, xobjFolder))
					{
						sErrorDescription = "����� �������� ���� �������� �������� � �������� ������";
						return false;
					}
				}
				return true;
			}
			return false;
		}
	}

	#region �������� ���� �������� ���
	/// <summary>
	/// �������� ���� �� ������ ���
	/// </summary>
	[SecurityRightsChecker("Lot")]
	public class LotRightsChecker: ObjectRightsCheckerBase
	{
		public LotRightsChecker(SecurityProvider provider) : base(provider, true)
		{}

		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			// RULE: ���� � ����� ��� ���������� "������ � ���", �� ������ ������
			if (!user.HasPrivilege(SystemPrivilegesItem.AccessIntoTMS.Name))
				return XObjectRights.ReadOnlyRights;

			// RULE: ������������, �� ���������� ����������� "����������� �������" �� ����� �������� ��������� �������
			if (!user.HasPrivilege(SystemPrivilegesItem.DecidingManInTMS.Name))
				return new XObjectRights(true, new string[] {"State"});

			return XObjectRights.FullRights;
		}

		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			if (!user.HasPrivilege(SystemPrivilegesItem.AccessIntoTMS.Name))
				return XNewObjectRights.EmptyRights;

			if (!user.HasPrivilege(SystemPrivilegesItem.DecidingManInTMS.Name))
				return new XNewObjectRights(true, new string[] {"State"});

			return XNewObjectRights.FullRights;
		}

		protected override bool hasInsertObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			if (!user.HasPrivilege(SystemPrivilegesItem.AccessIntoTMS.Name))
				return false;

			// RULE: ���� ��� ���������� "����������� ������� � ���", �� �������� "���������" ����� ������ ����� �������� �� ��������� ("��������� ����������")
			if (!user.HasPrivilege(SystemPrivilegesItem.DecidingManInTMS.Name) && xobj.HasUpdatedProp("State"))
			{
				LotState state = (LotState)xobj.GetUpdatedPropValue("State");
				if (state != LotState.DocumentGetting)
					return false;
			}

			return true;
		}

	}

	#endregion
}