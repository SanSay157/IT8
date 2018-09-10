//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Specialized;
using System.Data;
using System.Reflection;
using System.Security.Principal;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Core
{
	#region ����� FolderRightsManager - ��������� ����������� ���������� ������������� �� �����
	/*
	internal class FolderRightsManager
	{
		/// <summary>
		/// �������� ����� � ���� ������������� �� ���
		/// </summary>
		class FolderInfo
		{
			/// <summary>
			/// ������������� �����
			/// </summary>
			public Guid ObjectID;
			/// <summary>
			/// ������������� �����������
			/// </summary>
			public Guid OrganizationID;
			public int LIndex;
			public int RIndex;
			public int Level;
			/// <summary>
			/// ���� - SystemUser.ObjectID, �������� - ����� ����������
			/// </summary>
			private Hashtable UsersRights = new Hashtable();

			public FolderInfo() {}
			public FolderInfo(Guid oid, Guid orgID, int nLIndex, int nRIndex, int nLevel)
			{
				ObjectID = oid;
				OrganizationID = orgID;
				LIndex = nLIndex;
				RIndex = nRIndex;
				Level = nLevel;
			}
			public bool HasPrivilegesOfUser(Guid userID)
			{
				return UsersRights.Contains(userID);
			}

			public int GetUserPrivileges(Guid userID)
			{
				return (int)UsersRights[userID];
			}
			public void SetUserPrivileges(Guid userID, int privileges)
			{
				UsersRights[userID] = privileges;
			}
		}

		/// <summary>
		/// ���� - ������������� �����, �������� - ��������� FolderInfo
		/// </summary>
		Hashtable m_hashUserRightsOnFolders = new Hashtable();

		/// <summary>
		/// ���������� �������� ����� �� ����, ���� � ������ ���������� ��� ���, ���������� �� ��
		/// </summary>
		/// <param name="FolderID">������������� �����</param>
		/// <param name="xs">���������� � ��</param>
		private FolderInfo getOrLoadFolderInfo(Guid FolderID, XStorageConnection xs)
		{
			FolderInfo folderInfo = (FolderInfo)m_hashUserRightsOnFolders[FolderID];
			if (folderInfo == null)
			{
				XDbCommand cmd = xs.CreateCommand(@"SELECT LIndex, RIndex, Level, Customer FROM Folder WHERE ObjectID = @FolderID");
				cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, FolderID );
				using(IDataReader reader = cmd.ExecuteReader())
				{
					if (reader.Read())
					{
						int nLIndex = reader.GetInt32( reader.GetOrdinal("LIndex") );
						int nRIndex = reader.GetInt32( reader.GetOrdinal("RIndex") );
						int nLevel  = reader.GetInt32( reader.GetOrdinal("Level") );
						Guid OrganizationID = reader.GetGuid( reader.GetOrdinal("Customer") );
						folderInfo = new FolderInfo(FolderID, OrganizationID, nLIndex, nRIndex, nLevel);
					}
					else
						throw new ApplicationException("��������� ����� �� �������������� ����� (ObjectID = " + FolderID.ToString());
				}
				m_hashUserRightsOnFolders[FolderID] = folderInfo;
			}
			return folderInfo;
		}

		/// <summary>
		/// ���������� �������� ����� �� ����, ���� � ������ ���������� ��� ���, ������� ����� ���������
		/// </summary>
		/// <param name="FolderID">������������� �����</param>
		/// <param name="OrganizationID">������������� �����������</param>
		/// <param name="LIndex"></param>
		/// <param name="RIndex"></param>
		/// <param name="Level"></param>
		private FolderInfo getOrCreateFolderInfo(Guid FolderID, Guid OrganizationID, int LIndex, int RIndex, int Level)
		{
			FolderInfo folderInfo = (FolderInfo)m_hashUserRightsOnFolders[FolderID];
			if (folderInfo == null)
			{
				folderInfo = new FolderInfo(FolderID, OrganizationID, LIndex, RIndex, Level);
				m_hashUserRightsOnFolders[FolderID] = folderInfo;
			}
			return folderInfo;			
		}

		/// <summary>
		/// ���������� ����� ���������� ��������� ������������ �� ����� � �������� ���������������
		/// </summary>
		/// <param name="xs">���������� � ��</param>
		/// <param name="user">������������, ���������� ������ ����������</param>
		/// <param name="FolderID">������������� �����</param>
		/// <returns>�������� ����� ����������</returns>
		public int GetPrivilegesOnFolder(XStorageConnection xs, ITUser user, Guid FolderID)
		{
			Debug.Assert(xs != null);
			Debug.Assert(user != null);
			Debug.Assert(FolderID != Guid.Empty);
			FolderInfo folderInfo;
			XDbCommand cmd;
			int privileges = 0;		// ������������ ��������� - ����� ����������

			// ������� �� ���� ��� �������� �� �� �������� �����
			folderInfo = getOrLoadFolderInfo(FolderID, xs);
			// ����������: folderInfo �� ���� ���������� ������ ������������ �����, ��� ������� ��������� ����� (FolderID)
			Guid OrganizationID = folderInfo.OrganizationID;
			if (folderInfo.HasPrivilegesOfUser(user.SystemUserID))
				// ������� ����� �������� �������� ���������� ��� ��������� ������������ - ������ ��
				privileges = folderInfo.GetUserPrivileges(user.SystemUserID);
			else
			{
				// �������� �� �� �������� ���� ������������ ����� ��� �������� �����, ������� �� ���� (������� � WHERE �� "�����")
				cmd = xs.CreateCommand();
				cmd.CommandText = 
@"SELECT ObjectID, [Level], LIndex, RIndex
FROM Folder
WHERE LIndex <= @LIndex AND RIndex >= @RIndex AND Customer = @OrgID
ORDER BY [Level] DESC
";
				cmd.Parameters.Add("LIndex", DbType.Int32,ParameterDirection.Input, false, folderInfo.LIndex);
				cmd.Parameters.Add("RIndex", DbType.Int32,ParameterDirection.Input, false, folderInfo.RIndex);
				cmd.Parameters.Add("OrgID", DbType.Int32,ParameterDirection.Input, false, folderInfo.OrganizationID);
				DataTable dtFolders = new DataTable();		// ������� ��� �������� ����������� �������
				// ACHTUNG! ����-��������� � ����� XStorage!
				SqlDataAdapter da = new SqlDataAdapter((SqlCommand)cmd.Command);
				da.Fill(dtFolders);

				// �������� �������� ����� (����������� � ������������), 
				// �� ��� ����������� � ���������� ���������� ��� ������������ ������������.
				// ��� ����, ��-�� JOIN'� ����� (��� ���) ����� ����� �� ������� � �������
				cmd.CommandText = 
@"SELECT f.ObjectID as FolderID, pp.SystemUser, pp.Privileges, roles.Privileges AS RolePrivileges 
FROM Folder f 
	JOIN ProjectParticipant pp ON pp.Folder=f.ObjectID
		JOIN Employee emp ON pp.Employee = emp.ObjectID
	LEFT JOIN (ProjectParticipant_Roles pp_r 
		JOIN UserRoleInProject roles ON pp_r.Value = roles.ObjectID) ON pp.ObjectID=pp_r.ObjectID
WHERE f.LIndex <= @LIndex AND f.RIndex >= @RIndex AND f.Customer = @OrgID AND emp.[SystemUser] = @UserID
ORDER BY f.[Level] DESC
";
				// ������� �������� - ������������� ������������, � ������� � ������������
				cmd.Parameters.Add("UserID", DbType.Guid, ParameterDirection.Input, false, user.SystemUserID);
				Guid curFolderID;				// ������������� ������� �����, ���������� �� ������� ������� �� DataReader'a
				Guid prevFolderID = FolderID;	// ������������� �����, ��� ������� ���� ���������� ���������� � ���������� ���
				using(IDataReader reader = cmd.ExecuteReader())
				{
					privileges = 0;
					while (reader.Read())
					{
						curFolderID = reader.GetGuid( reader.GetOrdinal("FolderID") );
						// �������� ��� ���������� ��� �������� ��������
						privileges = readPrivileges(reader);

						if (curFolderID == FolderID)
							// ������� ������� - ��� ����������� ������� (FolderInfo ��� ���� �� ������������ �����)
							folderInfo.SetUserPrivileges(user.SystemUserID, privileges);
						else
						{
							// �������� ����� ��� ��������, ����������� ������������ ������������. 
							// ������ ���� �������������� ���������� ���������� �� ����������� ������� �� �����������, 
							// ��� �������� ���� ��������� ����� � ���������� ���. 
							// �� ����������� ���� ����� �� ����, ����� ������������� �� ������������ ��������

							// ���������� ����� ���� ��������, ���� ������� - ��� ������, ��� ������� ���������� ����� 
							// (� ���� ������ "����������" - ��� ����� ��� ������� ����� ��������� - ������� "prevFolderID == FolderID"), 
							// ����� ��� "����������" ����� ����� ��� ��������� � �������� �� �� ����.
							bool bIncludeStartFolder = prevFolderID == FolderID;	
							DataRow rowStart = dtFolders.Rows.Find(prevFolderID);
							DataRow rowEnd = dtFolders.Rows.Find(curFolderID);
							// ������� ��������� �����, ��������������� �����, ��� ������� ���� ���������� ����������� ���������� (privileges) ��� �������� �����
							DataRow[] folders = dtFolders.Select( 
								String.Format("LIndex {4} {0} AND LIndex <= {1} AND RIndex {4} {2} AND RIndex <={3}", 
									rowStart["LIndex"], rowEnd["LIndex"], 
									rowStart["RIndex"], rowEnd["RIndex"],
									bIncludeStartFolder ? ">=" : ">"
								), 
								"Level"
								);
							// �� ���� ���������� ������.
							// ������ �� ���� ����� ��������� ����� ��� �������� ����� ������ ������ �� ������� �����
							FolderInfo curFolderInfo;
							foreach(DataRow row in folders)
							{
								// ������� �� ���� ��� �������� �������� ����� 
								// (��� ������ � ��� ����, ������� ��������� ���-���� �� �� ��� �������������)
								curFolderInfo = getOrCreateFolderInfo((Guid)row["ObjectID"], OrganizationID , (int)row["LIndex"], (int)row["RIndex"], (int)row["Level"]);
								curFolderInfo.SetUserPrivileges(user.SystemUserID, privileges);
							}
						}
						prevFolderID = curFolderID;
					}
				}
				// � folderInfo � ��� ����������� �������� ����� ��� ������������ ��������
				Debug.Assert(folderInfo.HasPrivilegesOfUser(user.SystemUserID), "� ���������� ���� ���������� ����� �� ����������� ����� ��� � �� ����������");
				if (!folderInfo.HasPrivilegesOfUser(user.SystemUserID))
					throw new ApplicationException("�� ������� ��������� ����� �� ����������� �����, ������ � ���������");
				privileges = folderInfo.GetUserPrivileges(user.SystemUserID);
			}
			return privileges;
		}

		/// <summary>
		/// ���������� ����� �� ������� ����� � IDataReader'e. Read ������ ���� ������ ����� �������.
		/// ��� ������ ����������� ����� ����� ������ ������������
		/// </summary>
		/// <param name="reader"></param>
		/// <returns>����� ���������� �� ������� � reader'e �����</returns>
		private int readPrivileges(IDataReader reader)
		{
			int privileges = 0;
			privileges = privileges | reader.GetInt32( reader.GetOrdinal("Privileges") );
			// TODO: RolePrivileges ����� ���� NULL
			privileges = privileges | reader.GetInt32( reader.GetOrdinal("RolePrivileges") );
			Guid initFolderID = reader.GetGuid( reader.GetOrdinal("FolderID") );
			Guid curFolderID;
			while(reader.Read())
			{
				curFolderID = reader.GetGuid( reader.GetOrdinal("FolderID") );
				if (curFolderID != initFolderID )
					break;
				privileges = privileges | reader.GetInt32( reader.GetOrdinal("RolePrivileges") );
			}
			return privileges;
		}
	}

	*/
	#endregion

	/// <summary>
	/// �������, � ������� �������� ���������� ����� rights-checker'�� (����������� ����)
	/// </summary>
	[AttributeUsage(AttributeTargets.Class)]
	public class SecurityRightsCheckerAttribute: Attribute
	{
		private string[] m_aObjectTypes;

		public SecurityRightsCheckerAttribute(params string[] aObjectTypes)
		{
			m_aObjectTypes = aObjectTypes;
		}

		public string[] ObjectTypes
		{
			get { return m_aObjectTypes; }
		}
	}

	/// <summary>
	/// ���������� IXSecurityProvider ��� ������� IT6
	/// </summary>
	public class SecurityProvider: IXSecurityProvider
	{
		private XStorageFactory m_xsFactory;
		private IDictionary m_ObjectRightCheckers;
		private IDictionary m_ObjectPrivilegeContainers;
		private CoveringPrivilegesManager m_coveringPrivilegesManager;
		private FolderPrivilegeManager m_folderPrivilegeManager;

		public SecurityProvider(XStorageFactory xsFactory)
		{
			m_xsFactory = xsFactory;
			m_ObjectRightCheckers = new HybridDictionary();
			// ������ ��� ������ � ������� ������ ���������� ��������� [SecurityRightsChecker]
			Type typeLookingFor = typeof(SecurityRightsCheckerAttribute);
			foreach(Type type in Assembly.GetExecutingAssembly().GetTypes())
			{
				Attribute[] attrs = (Attribute[])type.GetCustomAttributes(typeLookingFor, false);
				foreach(Attribute attr in attrs)
				{
					// ���� ������� ����� ������� ����� ���������, �� ������� ��� � ��������� ������� ����
					if (attr is SecurityRightsCheckerAttribute)
					{
						SecurityRightsCheckerAttribute attrChecker = (SecurityRightsCheckerAttribute)attr;
						foreach(string sObjectType in attrChecker.ObjectTypes)
						{
							ConstructorInfo ctor = type.GetConstructor(new Type[] {typeof(SecurityProvider)});
							if (ctor == null)
								throw new ApplicationException("����� " + type.FullName + ", ���������� ��������� " + attr.GetType().Name + ", �� �������� ������������ � ���������� ���� " + typeof(SecurityProvider).Name);
							m_ObjectRightCheckers.Add(sObjectType, ctor .Invoke(new object[] {this}));
						}
					}
				}
			}
			m_coveringPrivilegesManager = new CoveringPrivilegesManager(this);

			m_ObjectPrivilegeContainers = new Hashtable();
			m_ObjectPrivilegeContainers.Add("Folder", new FolderPrivilegesDefinitionContainer());

			m_folderPrivilegeManager = new FolderPrivilegeManager(this);
		}

		protected XStorageConnection getConnection()
		{
            XStorageConnection xcon = m_xsFactory.CreateConnection();
            xcon.ConnectionString = m_xsFactory.ConnectionString;
			return xcon ;
		}

		/// <summary>
		/// ������������ �������� ������������ �� ������������.
		/// ���� ������������ � ����� ������������� �� �������, �� ���������� null
		/// </summary>
		/// <param name="sUserName">������������ ������������</param>
		/// <returns></returns>
		public XUser CreateUser(string sUserName)
		{
			ITUser user;
			using(XStorageConnection con = getConnection())
			{
				con.Open();
				XDbCommand cmd = con.CreateCommand();
				cmd.CommandText = 
					/* ������� �������� ������������ (������� ����� ���� �����������), 
					 * ��������� ���������� (��� �������� ����, ��� � ���������� ����� ����).
					 * ����������:	- ������������ ���������� ����� �� ���� �����������.
					 *				- ��� ������������ ���������� ����� ���� �� ������ ����
					 *				- GetWorkdayDuration ���������� ���������� �����
					 *  */
@"SELECT su.ObjectID AS SysUserID, su.IsAdmin, su.IsServiceAccount,
	emp.ObjectID AS EmpID, emp.LastName, emp.FirstName, emp.EMail, 
	su.SystemPrivileges, 
	sr.Name as RoleName, 
	sr.Description as RoleDescription, 
	sr.Priviliges as RolePrivileges,
	dbo.GetWorkdayGlobalDuration() as WorkingMinutesInDay,
	CASE WHEN emp.WorkEndDate < getDate() THEN 0 ELSE 1 END as AccessPermitted
FROM SystemUser su WITH (nolock)
	LEFT JOIN Employee emp WITH (nolock) ON emp.SystemUser = su.ObjectID
	LEFT JOIN (SystemUser_SystemRoles su_sr WITH (nolock)
		JOIN SystemRole sr WITH (nolock) ON su_sr.Value = sr.ObjectID
	) ON su.ObjectID = su_sr.ObjectID
WHERE su.Login = @UserLogin";
				cmd.Parameters.Add("UserLogin", DbType.String, ParameterDirection.Input, false, sUserName);
				using(IDataReader reader = cmd.ExecuteReader())
				{
					XRole[] roles;					// ������ ��������� �����
					Guid SystemUserID;				// ������������� ������������
					Guid EmployeeID = Guid.Empty;	// ������������� ����������
					string sLastName = null;		// ������� ����������
					string sFirstName = null;		// ��� ����������
					string sEMail = null;			// email ����������
					bool bIsAdmin;					// ������� ������ (���������������� ������������)
					bool bIsServiceAccount;			// ������� ���������� ��������
					int nIndex;						// ��������� - ������ �������
					int nPrivileges;				// �������� ����� ���������� (� �� ���������� ����� ��� �����)
					int nWorkingMinutesInDay;		// ���������� ������� ����� � ������
					bool bAccesssPermitted = true;
					
					if (reader.Read())
					{
						// ������� ����� ����������, �������� ������������ ����
						nPrivileges = reader.GetInt32( reader.GetOrdinal("SystemPrivileges") );		// ���� SystemPrivileges - not null
						SystemUserID= reader.GetGuid( reader.GetOrdinal("SysUserID") );
						bIsAdmin	= reader.GetBoolean( reader.GetOrdinal("IsAdmin") );
						bIsServiceAccount = reader.GetBoolean( reader.GetOrdinal("IsServiceAccount") );
						nWorkingMinutesInDay = reader.GetInt32( reader.GetOrdinal("WorkingMinutesInDay") );
						nIndex = reader.GetOrdinal("EmpID");
						if (!reader.IsDBNull(nIndex))
						{
							// ���� ������������ �������� �����������
							EmployeeID	= reader.GetGuid( nIndex );
							sLastName	= reader.GetString( reader.GetOrdinal("LastName") );
							sFirstName	= reader.GetString( reader.GetOrdinal("FirstName") );
							bAccesssPermitted = reader.GetInt32(reader.GetOrdinal("AccessPermitted")) == 1;
							nIndex = reader.GetOrdinal("EMail");
							if (!reader.IsDBNull(nIndex))
								sEMail	= reader.GetString(nIndex);
						}
					}
					else
					{
						// �� ����� ������������
						return CreateAnonymousUser();
					}
					
					// �������� ��� ���� �������� �����
					ArrayList aRoles = new ArrayList();		// ������ �������� XRole - ���� ������������
					int nIndex_RoleName = reader.GetOrdinal("RoleName");
					int nIndex_RoleDescription = reader.GetOrdinal("RoleDescription");
					int nIndex_RolePrivileges = reader.GetOrdinal("RolePrivileges");
					if (!reader.IsDBNull(nIndex_RoleName))
					{
						// �� ���� ����� ������������
						do
						{
							string sDescription = String.Empty;
							if (!reader.IsDBNull(nIndex_RoleDescription))
								sDescription = reader.GetString(nIndex_RoleDescription);
							// ��������� ����� ���������� � ������������ ������� ����
							nPrivileges = nPrivileges | reader.GetInt32(nIndex_RolePrivileges);
							aRoles.Add( new XRole( reader.GetString(nIndex_RoleName), sDescription) );
						} while(reader.Read());
					}
					roles = new XRole[aRoles.Count];
					aRoles.CopyTo(roles);
					// ��������� ����� ���������� � ������ ��������
					XPrivilegeSet privilege_set = PrivilegesHelper.CreatePrivilegeSet((SystemPrivileges)nPrivileges);
					
					// �������� �������� ������������ � �������� ��������, ����������� ��� ������ ����������
					user = new ITUser(sUserName, roles, privilege_set);
					user.SystemUserID = SystemUserID;
					user.IsUnrestricted = bIsAdmin;
					user.IsServiceAccount = bIsServiceAccount;
					user.AccessPermitted = bAccesssPermitted;
					if (EmployeeID != Guid.Empty)
					{
						// ���� ������������ - ���������
						user.EmployeeID = EmployeeID;
						user.LastName = sLastName;
						user.FirstName = sFirstName;
						user.EMail = sEMail;
						user.WorkdayDuration = nWorkingMinutesInDay;
					}
				}
				readUserActivityTypes(user, con);
				readUserManagedOrganizations(user, con);
			}
			return user;
		}

		private void readUserActivityTypes(ITUser user, XStorageConnection con)
		{
			XDbCommand cmd = con.CreateCommand();
			cmd.CommandText = @"
				SELECT at.ObjectID, at.Name, at.Code, at.AccountRelated, at.FolderType, at.StartDate, at.EndDate 
				FROM dbo.SystemUser_ActivityTypes su_at WITH (nolock)
					JOIN dbo.ActivityType at WITH (nolock) ON su_at.Value = at.ObjectID
				WHERE su_at.ObjectID = @ObjectID
				UNION
				SELECT at.ObjectID, at.Name, at.Code, at.AccountRelated, at.FolderType, at.StartDate, at.EndDate 
				FROM dbo.SystemUser_SystemRoles su_sr WITH (nolock)
					JOIN dbo.SystemRole_ActivityTypes sr_at WITH (nolock) ON su_sr.Value = sr_at.ObjectID
						JOIN dbo.ActivityType at WITH (nolock) ON sr_at.Value = at.ObjectID
				WHERE su_sr.ObjectID = @ObjectID
				";
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, user.SystemUserID);
			using(IXDataReader reader = cmd.ExecuteXReader())
			{
				user.ActivityTypes = new Hashtable();
				while (reader.Read())
				{
					DomainObject_ActivityType xobj = new DomainObject_ActivityType();
					xobj.ObjectID = reader.GetGuid(reader.GetOrdinal("ObjectID"));
					xobj.Name = reader.GetString(reader.GetOrdinal("Name"));
					xobj.Code = reader.GetString(reader.GetOrdinal("Code"));
					xobj.AccountRelated = reader.GetBoolean(reader.GetOrdinal("AccountRelated"));
					xobj.FolderType = (FolderTypeFlags)reader.GetInt16(reader.GetOrdinal("FolderType"));
					xobj.StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate"));
					if (!reader.IsDBNull(reader.GetOrdinal("EndDate")))
						xobj.EndDate = reader.GetDateTime(reader.GetOrdinal("EndDate"));
					user.ActivityTypes.Add(xobj.ObjectID, xobj);
				}
			}
		}

		private void readUserManagedOrganizations(ITUser user, XStorageConnection con)
		{
			XDbCommand cmd = con.CreateCommand();
			cmd.CommandText = @"
				SELECT o.ObjectID
				FROM Organization o WITH (nolock)
					JOIN Organization o_p WITH (nolock) ON o_p.LIndex <= o.LIndex AND o_p.RIndex >= o.RIndex and o_p.Director = @EmployeeID		
			";
			cmd.Parameters.Add("EmployeeID", DbType.Guid, ParameterDirection.Input, false, user.EmployeeID);
			using(IXDataReader reader = cmd.ExecuteXReader())
			{
				ArrayList aOrgIDs = new ArrayList();
				while (reader.Read())
					aOrgIDs.Add(reader.GetGuid(0));
				user.ManagedOrganizations = new Guid[aOrgIDs.Count];
				aOrgIDs.CopyTo(user.ManagedOrganizations);
			}
		}

		/// <summary>
		/// ���������� ���������-��������� ���������� ������������
		/// </summary>
		/// <returns></returns>
		public XUser CreateAnonymousUser()
		{
			throw new XSecurityException("������ � ������� �������� ������ ������������� ����������. ���������� ������� ������� ������ ��� ������������. ���������� � ������ ����������� ���������.");
		}

		/// <summary>
		/// ��������� �������� ������������, ������� ���� ��������
		/// </summary>
		/// <remarks>
		/// �� ������ � ���������� ��������� IsFlushed �������� XSecurityManager.
		/// </remarks>
		/// <param name="user">��������� XUser ��� �����������, � �������� �������� IsFlushed=true</param>
		public void UpdateUser(XUser user)
		{
			ITUser userLoaded = (ITUser)CreateUser(user.Name);
			userLoaded.CopyTo((ITUser)user);
		}
		
		/// <summary>
		/// ���������� ������������ ������������ �� ���������� IPrincipal.
		/// </summary>
		/// <remarks>
		/// ���������� ������ ������������ IPrincipal �� ������������ ������������. 
		/// ��������� ������� ������������ ���������� ��� CreateUser, �������� ����� ������� ���������.
		/// </remarks>
		/// <param name="originalPrincipal">principal</param>
		/// <returns>������������ ������������ ����������</returns>
		public string GetUserNameByPrincipal(IPrincipal originalPrincipal)
		{
			string sName = originalPrincipal.Identity.Name;
			int nSlashIndex = sName.IndexOf('\\');
			if (nSlashIndex == -1)
				nSlashIndex = sName.IndexOf('/');
			if (nSlashIndex > -1)
				sName = sName.Substring(nSlashIndex +1);
			return sName;
		}


		/// <summary>
		/// �������� �� ���������� ������� � ��, ������������ �� �������, � ������ ����������
		/// </summary>
		/// <param name="xuser">������������, ����������� ������</param>
		/// <param name="ex">�������� �������</param>
		public bool HasSaveObjectPrivilege(XUser xuser, DomainObjectData xobj, out Exception ex)
		{
			ex = null;
			ITUser user = (ITUser)xuser;

			using(XStorageConnection con = getConnection())
			{
				ObjectRightsCheckerBase checker = (ObjectRightsCheckerBase)m_ObjectRightCheckers[xobj.ObjectType];
				bool bAllow;
				string sErrorDescription;
				if (checker != null)
					bAllow = checker.HasSaveObjectRight(user, xobj, con, out sErrorDescription);
				else
					bAllow = m_coveringPrivilegesManager.HasSaveObjectRight(user, xobj, con, out sErrorDescription);
				if (sErrorDescription != null && sErrorDescription.Length > 0)
					ex = new XSecurityException(sErrorDescription);
				return bAllow;
			}
		}

		/// <summary>
		/// ������ ����������� �������� ������������ ��� ��������.
		/// ������ ��� ����� ��������� ������. ���� ������ ������� ��������, ��� �������� �� ������� �������.
		/// </summary>
		/// <param name="xuser">������������</param>
		/// <param name="xobj">������, ����� �� ������� �������������</param>
		/// <returns></returns>
		public XObjectRights GetObjectRights(XUser xuser, DomainObjectData xobj)
		{
			ITUser user = (ITUser)xuser;
			using(XStorageConnection con = getConnection())
			{
				ObjectRightsCheckerBase checker = (ObjectRightsCheckerBase)m_ObjectRightCheckers[xobj.ObjectType];
				if (checker != null)
					return checker.GetObjectRights(user, xobj, con);
				return m_coveringPrivilegesManager.GetObjectRights(user, xobj, con);
			}
		}

		/// <summary>
		/// ������ ����������� �������� ��� �������� �������
		/// </summary>
		/// <param name="xuser">������������</param>
		/// <param name="xobj"></param>
		/// <returns></returns>
		public XNewObjectRights GetRightsOnNewObject(XUser xuser, DomainObjectData xobj)
		{
			ITUser user = (ITUser)xuser;
			using(XStorageConnection con = getConnection())
			{
				ObjectRightsCheckerBase checker = (ObjectRightsCheckerBase)m_ObjectRightCheckers[xobj.ObjectType];
				if (checker != null)
					return checker.GetRightsOnNewObject(user, xobj, con);
				return m_coveringPrivilegesManager.GetRightsOnNewObject(user, xobj, con);
			}
		}

		/// <summary>
		/// ����������� �� ������� XSecurityManager'a �� ������������ ��������
		/// </summary>
		/// <param name="dataSet">����������� ��������� ��������</param>
		public void TrackModifiedObjects(DomainObjectDataSet dataSet)
		{
			IEnumerator enumerator = dataSet.GetModifiedObjectsEnumerator(false);
			while(enumerator.MoveNext())
			{
				DomainObjectData xobj = (DomainObjectData)enumerator.Current;
				if (xobj.ObjectType == "ProjectParticipant" || xobj.ObjectType == "UserRoleInProject")
				{
					FolderPrivilegesDefinitionContainer container = (FolderPrivilegesDefinitionContainer)ObjectPrivilegeContainers["Folder"];
					container.FlushCache();
					break;
				}
			}
		}

		/// <summary>
		/// ���������� ������ ������������ ������������� ����������, 
		/// ��� �������� ������� ������� �������� ��-�� ��������� �������� � ���������� (���������� �� �������) ���������
		/// </summary>
		/// <param name="dataSet">��������� ���������������� ��������</param>
		/// <param name="users">��������� (���) �������� ������������� ���������� (ITUser)</param>
		/// <returns>������ ������������ �������������, �������� ������� ���� ��������</returns>
		public string[] GetAffectedUserNames(DomainObjectDataSet dataSet, ICollection users)
		{
			string[] affectedUserNames = null;
			ArrayList affectedUserNamesList = null;
			bool bFlushAllUsers = false;	// ������� "�������� �������� ���� �������������"
			foreach(DomainObjectData xobj in dataSet.GetModifiedObjectsByType(new string[] {"SystemUser","Employee", "ActivityType", "Organization"}, true))
			{
				// ��� ��������� ����� ��������� ������ ������� �������� ���� �������������
				if (xobj.ObjectType == "ActivityType")
				{
					bFlushAllUsers = true;
				}
				else if (xobj.ObjectType == "Organization")
				{
					bFlushAllUsers = true;
				}
				else if (xobj.ObjectType == "SystemUser" ||  xobj.ObjectType == "Employee")
				{
					foreach(ITUser user in users)
					{
						if (user.SystemUserID == xobj.ObjectID && xobj.ObjectType == "SystemUser" ||
						    user.EmployeeID == xobj.ObjectID && xobj.ObjectType == "Employee"
							)
						{
							if (affectedUserNamesList == null)
								affectedUserNamesList = new ArrayList();
							affectedUserNamesList.Add(user.Name);
							break;
						}
					}
				}
				if (bFlushAllUsers)
				{
					if (affectedUserNamesList == null)
						affectedUserNamesList = new ArrayList();
					else
						affectedUserNamesList.Clear();
					affectedUserNamesList.Add(XSecurityManager.USERNAME_ALLUSERS);
					break;
				}
			}
			if (affectedUserNamesList != null)
			{
				affectedUserNames = new string[affectedUserNamesList.Count];
				affectedUserNamesList.CopyTo(affectedUserNames);
			}
			return affectedUserNames;
		}

		
		public IDictionary ObjectPrivilegeContainers
		{
			get { return m_ObjectPrivilegeContainers; }
		}

		public IDictionary ObjectRightCheckers
		{
			get { return m_ObjectRightCheckers; }
		}

		public FolderPrivilegeManager FolderPrivilegeManager
		{
			get { return m_folderPrivilegeManager; }
		}
	}
}