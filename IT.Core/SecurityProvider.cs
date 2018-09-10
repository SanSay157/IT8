//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
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
	#region Класс FolderRightsManager - реализует кеширование привилегий пользователей на папки
	/*
	internal class FolderRightsManager
	{
		/// <summary>
		/// Описание папки и прав пользователей на нее
		/// </summary>
		class FolderInfo
		{
			/// <summary>
			/// Идентификатор папки
			/// </summary>
			public Guid ObjectID;
			/// <summary>
			/// Идентификатор организации
			/// </summary>
			public Guid OrganizationID;
			public int LIndex;
			public int RIndex;
			public int Level;
			/// <summary>
			/// ключ - SystemUser.ObjectID, значение - маска привилегий
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
		/// Ключ - идентификатор папки, значение - экземпляр FolderInfo
		/// </summary>
		Hashtable m_hashUserRightsOnFolders = new Hashtable();

		/// <summary>
		/// Возвращает описание папки из кеша, либо в случае отсутствия его там, зачитывает из БД
		/// </summary>
		/// <param name="FolderID">Идентификатор папки</param>
		/// <param name="xs">Соединение с БД</param>
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
						throw new ApplicationException("Запрошены права на несуществующую папку (ObjectID = " + FolderID.ToString());
				}
				m_hashUserRightsOnFolders[FolderID] = folderInfo;
			}
			return folderInfo;
		}

		/// <summary>
		/// Возвращает описание папки из кеша, либо в случае отсутствия его там, создает новый экземпляр
		/// </summary>
		/// <param name="FolderID">Идентификатор папки</param>
		/// <param name="OrganizationID">Идентификатор организации</param>
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
		/// Возвращает маску привилегий заданного пользователя на папку с заданным идентификатором
		/// </summary>
		/// <param name="xs">Соединение с БД</param>
		/// <param name="user">Пользователь, привелегии котого интересуют</param>
		/// <param name="FolderID">Идентификатор папки</param>
		/// <returns>Числовая маска привелегий</returns>
		public int GetPrivilegesOnFolder(XStorageConnection xs, ITUser user, Guid FolderID)
		{
			Debug.Assert(xs != null);
			Debug.Assert(user != null);
			Debug.Assert(FolderID != Guid.Empty);
			FolderInfo folderInfo;
			XDbCommand cmd;
			int privileges = 0;		// возвращаемый результат - маска привелегий

			// получим из кеша или загрузим из БД описание папки
			folderInfo = getOrLoadFolderInfo(FolderID, xs);
			// Примечание: folderInfo на всем протяжении метода соответсвует папке, для которой запрошены права (FolderID)
			Guid OrganizationID = folderInfo.OrganizationID;
			if (folderInfo.HasPrivilegesOfUser(user.SystemUserID))
				// текущая папка содержит описание привилегий для заданного пользователя - вернем их
				privileges = folderInfo.GetUserPrivileges(user.SystemUserID);
			else
			{
				// зачитаем из БД описания всех родительских папок для заданной папки, включая ее саму (условие в WHERE на "равно")
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
				DataTable dtFolders = new DataTable();		// таблица для хранения результатов запроса
				// ACHTUNG! СУБД-специфика в обход XStorage!
				SqlDataAdapter da = new SqlDataAdapter((SqlCommand)cmd.Command);
				da.Fill(dtFolders);

				// зачитаем описания папок (запрошенной и родительских), 
				// но уже соединенных с описаниями привилегий для запрошенного пользователя.
				// При этом, из-за JOIN'а часть (или все) папку могут не попасть в выборку
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
				// добавим параметр - идентификатор пользователя, в добавок к существующим
				cmd.Parameters.Add("UserID", DbType.Guid, ParameterDirection.Input, false, user.SystemUserID);
				Guid curFolderID;				// идентификатор текущей папки, привилегии на которую считаны из DataReader'a
				Guid prevFolderID = FolderID;	// идентификатор папки, для которой были вычисленны привилегии в предыдущий раз
				using(IDataReader reader = cmd.ExecuteReader())
				{
					privileges = 0;
					while (reader.Read())
					{
						curFolderID = reader.GetGuid( reader.GetOrdinal("FolderID") );
						// зачитаем все привилегии для текущего каталога
						privileges = readPrivileges(reader);

						if (curFolderID == FolderID)
							// текущий каталог - это запрошенный каталог (FolderInfo для него мы сформировали ранее)
							folderInfo.SetUserPrivileges(user.SystemUserID, privileges);
						else
						{
							// зачитали права для каталога, являющегося родительским запрошенному. 
							// Теперь надо распространить полученный привилегии на нижележащие проекты до предыдущего, 
							// для которого были зачитанны права в предыдущий раз. 
							// Но предыдущего раза могло не быть, тогда распространим до запрошенного каталога

							// Предыдущую папку надо включать, если текущая - это первая, для которой вычисленны права 
							// (в этом случае "предыдущая" - это папка для которой права запрошены - условие "prevFolderID == FolderID"), 
							// иначе для "предыдущей" папки права уже вычислены и включать ее не надо.
							bool bIncludeStartFolder = prevFolderID == FolderID;	
							DataRow rowStart = dtFolders.Rows.Find(prevFolderID);
							DataRow rowEnd = dtFolders.Rows.Find(curFolderID);
							// получим множество строк, соответствующих папка, для которых надо установить вычисленные привилегии (privileges) для текущего юзера
							DataRow[] folders = dtFolders.Select( 
								String.Format("LIndex {4} {0} AND LIndex <= {1} AND RIndex {4} {2} AND RIndex <={3}", 
									rowStart["LIndex"], rowEnd["LIndex"], 
									rowStart["RIndex"], rowEnd["RIndex"],
									bIncludeStartFolder ? ">=" : ">"
								), 
								"Level"
								);
							// По всем полученным папкам.
							// Каждой из этих папок проставим права для текущего юзера равные правам на текущую папку
							FolderInfo curFolderInfo;
							foreach(DataRow row in folders)
							{
								// получим из кеша или создадим описание папки 
								// (все данные у нас есть, поэтому считывать что-либо из БД нет необходимости)
								curFolderInfo = getOrCreateFolderInfo((Guid)row["ObjectID"], OrganizationID , (int)row["LIndex"], (int)row["RIndex"], (int)row["Level"]);
								curFolderInfo.SetUserPrivileges(user.SystemUserID, privileges);
							}
						}
						prevFolderID = curFolderID;
					}
				}
				// в folderInfo у нас обязательно окажутся права для запрошенного каталога
				Debug.Assert(folderInfo.HasPrivilegesOfUser(user.SystemUserID), "В результате всех вычислений права на запрошенную папку так и не вычисленны");
				if (!folderInfo.HasPrivilegesOfUser(user.SystemUserID))
					throw new ApplicationException("Не удалось вычислить права на запрошенную папку, ошибка в алгоритме");
				privileges = folderInfo.GetUserPrivileges(user.SystemUserID);
			}
			return privileges;
		}

		/// <summary>
		/// Зачитывает права на текущую папку в IDataReader'e. Read должен быть вызван перед началом.
		/// Как только встречается новая папка чтение прекращается
		/// </summary>
		/// <param name="reader"></param>
		/// <returns>Маска привилегий на текущую в reader'e папку</returns>
		private int readPrivileges(IDataReader reader)
		{
			int privileges = 0;
			privileges = privileges | reader.GetInt32( reader.GetOrdinal("Privileges") );
			// TODO: RolePrivileges может быть NULL
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
	/// Атрибут, с помощью которого отмечаются класс rights-checker'ов (проверщиков прав)
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
	/// Реализация IXSecurityProvider для проекта IT6
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
			// найдем все классы в текущей сборке помеченные атрибутом [SecurityRightsChecker]
			Type typeLookingFor = typeof(SecurityRightsCheckerAttribute);
			foreach(Type type in Assembly.GetExecutingAssembly().GetTypes())
			{
				Attribute[] attrs = (Attribute[])type.GetCustomAttributes(typeLookingFor, false);
				foreach(Attribute attr in attrs)
				{
					// если текущий класс помечен таким атрибутом, то добавим его в коллекцию чекеров прав
					if (attr is SecurityRightsCheckerAttribute)
					{
						SecurityRightsCheckerAttribute attrChecker = (SecurityRightsCheckerAttribute)attr;
						foreach(string sObjectType in attrChecker.ObjectTypes)
						{
							ConstructorInfo ctor = type.GetConstructor(new Type[] {typeof(SecurityProvider)});
							if (ctor == null)
								throw new ApplicationException("Класс " + type.FullName + ", помеченный атрибутом " + attr.GetType().Name + ", не содержит конструктора с параметром типа " + typeof(SecurityProvider).Name);
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
		/// Конструирует описание пользователя по наименованию.
		/// Если пользователя с таким наименованием не найдено, то возвращает null
		/// </summary>
		/// <param name="sUserName">Наименование пользователя</param>
		/// <returns></returns>
		public XUser CreateUser(string sUserName)
		{
			ITUser user;
			using(XStorageConnection con = getConnection())
			{
				con.Open();
				XDbCommand cmd = con.CreateCommand();
				cmd.CommandText = 
					/* Получим описание пользователя (который может быть сотрудником), 
					 * системные привилегии (как выданные явно, так и полученные через роли).
					 * Примечания:	- пользователь приложения может не быть сотрудником.
					 *				- для пользователя приложения могут быть не заданы роли
					 *				- GetWorkdayDuration возвращает количество минут
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
					XRole[] roles;					// массив системных ролей
					Guid SystemUserID;				// идентификатор пользователя
					Guid EmployeeID = Guid.Empty;	// идентификатор сотрудника
					string sLastName = null;		// фамилия сотрудника
					string sFirstName = null;		// имя сотрудника
					string sEMail = null;			// email сотрудника
					bool bIsAdmin;					// признак админа (необграниченного пользователя)
					bool bIsServiceAccount;			// признак сервисного аккаунта
					int nIndex;						// временная - индекс колонки
					int nPrivileges;				// числовая маска привилегий (в БД привилегии лежат как флаги)
					int nWorkingMinutesInDay;		// количество рабочих часов в сутках
					bool bAccesssPermitted = true;
					
					if (reader.Read())
					{
						// получим маску привилегий, выданных пользователю явно
						nPrivileges = reader.GetInt32( reader.GetOrdinal("SystemPrivileges") );		// поле SystemPrivileges - not null
						SystemUserID= reader.GetGuid( reader.GetOrdinal("SysUserID") );
						bIsAdmin	= reader.GetBoolean( reader.GetOrdinal("IsAdmin") );
						bIsServiceAccount = reader.GetBoolean( reader.GetOrdinal("IsServiceAccount") );
						nWorkingMinutesInDay = reader.GetInt32( reader.GetOrdinal("WorkingMinutesInDay") );
						nIndex = reader.GetOrdinal("EmpID");
						if (!reader.IsDBNull(nIndex))
						{
							// если пользователь является сотрудником
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
						// не нашли пользователя
						return CreateAnonymousUser();
					}
					
					// зачитаем все роли текущего юзера
					ArrayList aRoles = new ArrayList();		// список объектов XRole - роли пользователя
					int nIndex_RoleName = reader.GetOrdinal("RoleName");
					int nIndex_RoleDescription = reader.GetOrdinal("RoleDescription");
					int nIndex_RolePrivileges = reader.GetOrdinal("RolePrivileges");
					if (!reader.IsDBNull(nIndex_RoleName))
					{
						// по всем ролям пользователя
						do
						{
							string sDescription = String.Empty;
							if (!reader.IsDBNull(nIndex_RoleDescription))
								sDescription = reader.GetString(nIndex_RoleDescription);
							// объединим маску привилегий с привилегиями текущей роли
							nPrivileges = nPrivileges | reader.GetInt32(nIndex_RolePrivileges);
							aRoles.Add( new XRole( reader.GetString(nIndex_RoleName), sDescription) );
						} while(reader.Read());
					}
					roles = new XRole[aRoles.Count];
					aRoles.CopyTo(roles);
					// превратим маску привилегий в массив объектов
					XPrivilegeSet privilege_set = PrivilegesHelper.CreatePrivilegeSet((SystemPrivileges)nPrivileges);
					
					// создадим описание пользователя и дополним атрибуты, специфичные для нашего приложения
					user = new ITUser(sUserName, roles, privilege_set);
					user.SystemUserID = SystemUserID;
					user.IsUnrestricted = bIsAdmin;
					user.IsServiceAccount = bIsServiceAccount;
					user.AccessPermitted = bAccesssPermitted;
					if (EmployeeID != Guid.Empty)
					{
						// если пользователь - сотрудник
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
		/// Возвращает экземпляр-описатель анонимного пользователя
		/// </summary>
		/// <returns></returns>
		public XUser CreateAnonymousUser()
		{
			throw new XSecurityException("Доступ к системе разрешен только пользователям приложения. Необходимо создать учетную запись для пользователя. Обратитесь в службу технической поддержки.");
		}

		/// <summary>
		/// Обновляет описание пользователя, которое было сброшено
		/// </summary>
		/// <remarks>
		/// За анализ и управление свойством IsFlushed отвечает XSecurityManager.
		/// </remarks>
		/// <param name="user">Экземпляр XUser или производный, у которого свойство IsFlushed=true</param>
		public void UpdateUser(XUser user)
		{
			ITUser userLoaded = (ITUser)CreateUser(user.Name);
			userLoaded.CopyTo((ITUser)user);
		}
		
		/// <summary>
		/// Возвращает наименование пользователя по реализации IPrincipal.
		/// </summary>
		/// <remarks>
		/// Занимается только отображением IPrincipal на наименование пользователя. 
		/// Проверяет наличие пользователя приложения уже CreateUser, которому будет передан результат.
		/// </remarks>
		/// <param name="originalPrincipal">principal</param>
		/// <returns>Наименование пользователя приложения</returns>
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
		/// Проверка на сохранение объекта в БД, поступившего от клиента, в рамках датаграммы
		/// </summary>
		/// <param name="xuser">Пользователь, сохраняющий объект</param>
		/// <param name="ex">Описание запрета</param>
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
		/// Запрос разрешенных действий пользователя над объектом.
		/// Объект уже может содержать данные. Этим данным следует доверять, они получены на стороне сервера.
		/// </summary>
		/// <param name="xuser">Пользователь</param>
		/// <param name="xobj">Объект, права на который запрашиваются</param>
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
		/// Запрос разрешенных действий при создании объекта
		/// </summary>
		/// <param name="xuser">Пользователь</param>
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
		/// Уведомление со стороны XSecurityManager'a об изменившихся объектах
		/// </summary>
		/// <param name="dataSet">Сохраняемое множество объектов</param>
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
		/// Возвращает массив наименований пользователей приложения, 
		/// кэш описаний которых следует сбросить из-за изменений объектов в переданном (полученном от клиента) множестве
		/// </summary>
		/// <param name="dataSet">Множество модифицированных объектов</param>
		/// <param name="users">Коллекция (кэш) описаний пользователей приложения (ITUser)</param>
		/// <returns>массив наименований пользователей, описание которых надо сбросить</returns>
		public string[] GetAffectedUserNames(DomainObjectDataSet dataSet, ICollection users)
		{
			string[] affectedUserNames = null;
			ArrayList affectedUserNamesList = null;
			bool bFlushAllUsers = false;	// признак "сбросить описания всех пользователей"
			foreach(DomainObjectData xobj in dataSet.GetModifiedObjectsByType(new string[] {"SystemUser","Employee", "ActivityType", "Organization"}, true))
			{
				// при изменении типов проектных затрат сбросим описание всех пользователей
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