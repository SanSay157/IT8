//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using System.Diagnostics;
using System.Text;
using System.Web;
using Croc.IncidentTracker.Commands.Security;
using Croc.IncidentTracker.Commands.Trees;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Hierarchy;
using Croc.IncidentTracker.Storage;
using Croc.IncidentTracker.Utility;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Core.Configuration;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.XUtils;
using XTreeLevelInfoIT = Croc.IncidentTracker.Hierarchy.XTreeLevelInfoIT;
using System.Globalization;

namespace Croc.IncidentTracker.Trees
{
	/// <summary>
	/// Реализация "загрузчика" меню для иерархии "Клиенты и Проекты" (ДКП)
	/// </summary>
	public class DKPTreeMenuLoadProvider : XTreeMenuDataProviderStd
	{
		/// <summary>
		/// Основной метод получения данных меню, "входная" точка. Вызывается 
		/// из инфраструкторы XFW / IT HierarchySubsystem
		/// </summary>
		/// <param name="request">Запрос операции получения меню GetTreeMenu</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <param name="treePage">Объектное описание данных страницы иерархии</param>
		/// <returns>Объектное описание меню</returns>
		public override XTreeMenuInfo GetMenu( XGetTreeMenuRequest request, IXExecutionContext context, XTreePageInfoStd treePage ) 
		{
			XTreeStructInfo treeStructInfo = treePage.TreeStruct;
			XTreeLevelInfoIT levelinfo = treeStructInfo.Executor.GetTreeLevel(treeStructInfo, request.Params, request.Path);

			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			// получим идентификатор объекта, для которого строится меню
			Guid ObjectID = request.Path.PathNodes[0].ObjectID;
			XTreeMenuInfo treemenu;
			if (levelinfo.ObjectType == "Organization" || levelinfo.ObjectType == "HomeOrganization")
			{
				treemenu = buildMenuForOrganization( ObjectID, request.Path, dataSet, context.Connection );
			}
			else if (levelinfo.ObjectType == "Folder")
			{
				treemenu = getMenuForFolder(request.Path, dataSet, context);
			}
			else if (levelinfo.ObjectType == "ActivityType" || levelinfo.ObjectType == "ActivityTypeInternal" || levelinfo.ObjectType == "ActivityTypeExternal")
			{
				treemenu = getMenuForActivityType(request.Path, dataSet, context.Connection);
			}
			else if (levelinfo.ObjectType == "Incident")
			{
				treemenu = getMenuForIncident(ObjectID, dataSet, context);
			}
            else if (levelinfo.ObjectType == "Stuff" || levelinfo.ObjectType == "UserRoleInProject")
			{
				// Для виртуальных узлов "Проектная команда" и "Все участники", и узлов с наименованиями проектной роли
				treemenu = getMenuForTeamAndRoleNode(request.Path, dataSet);
			}

            else if (levelinfo.ObjectType == "Contracts" /*|| levelinfo.ObjectType == "OutLimits" */ || levelinfo.ObjectType == "Incomes" /* || levelinfo.ObjectType == "Outcomes" */)
            {
                // Для виртуальных узлов "Договор", "Лимиты", "Приходы"
                treemenu = getMenuForContractsVirtualNode(request.Path, dataSet);
            }

            else if (levelinfo.ObjectType == "OutDoc")
            {
                // Для узлов "Расходный документ"
                treemenu = getMenuForOutDocument(request.Path, dataSet, context.Connection);
            }
            
            
            else if (levelinfo.ObjectType == "Contract")
            {
                treemenu = getMenuForContract(request.Path, dataSet, context.Connection);
            }
			else if (levelinfo.ObjectType == "ProjectParticipant")
			{
				treemenu = getMenuForProjectParticipant(request.Path, dataSet, context.Connection);
			}
            else if (levelinfo.ObjectType == "AOReason")
            {
                treemenu = getMenuForAO(request.Path, dataSet, context.Connection);
            }
			else
				treemenu = levelinfo.GetMenu(request, context);


			if (treemenu == null)
				treemenu = treePage.DefaultLevelMenu.GetMenu(levelinfo, request, context);

			if (treemenu != null)
			{
				if (context.Config.IsDebugMode)
				{
					XMenuActionItem item = treemenu.Items.AddActionItem("Обновить", StdActions.DoNodeRefresh);
					if (treemenu.Items.Count > 1)
						item.SeparatorBefore = true;
				}
			}
			return treemenu;
		}

        #region Меню для узлов типа "Приходный договор"

        private XTreeMenuInfo getMenuForContract(XTreePath path, DomainObjectDataSet dataSet, XStorageConnection con)
        {
            
            XMenuActionItem item;
            XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
            CultureInfo culture = new CultureInfo("ru-RU");
            IDictionary arDataRows = null;
            menu.CacheMode = XTreeMenuCacheMode.NoCache;
            
            try
            {
                // см. s-tree-DKP.vbs
                menu.ExecutionHandlers.Add(new XUserCodeWeb("DKP_ContractMenu_ExecutionHandler"));
                DomainObjectData xobj = dataSet.Load(con, "Contract", path[0].ObjectID);

                XObjectRights rights;
                rights = XSecurityManager.Instance.GetObjectRights(xobj);

                XMenuSection menu_sec;

                Guid contractID = path.PathNodes[0].ObjectID;

                if (rights.AllowParticalOrFullChange)
                {
                    item = menu.Items.AddActionItem("Редактировать", StdActions.DoEdit);
                    item.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_CHILDS");
                    item.Title = "Редактировать";
                }
                if (rights.AllowDelete)
                {
                    item = menu.Items.AddActionItem("Удалить", StdActions.DoDelete);
                    item.Parameters.Add("RefreshFlags", "TRM_NODE");
                    item.Title = "Удалить";
                }

                // Получение результирующего списка
                XDbCommand cmd = con.CreateCommand(@"
					SELECT
	                (SELECT dbo.GetSumString(SUM(oc.Sum), null)
	                 FROM dbo.OutContract oc 
		                inner join dbo.[Contract] c on oc.[Contract] = c.ObjectID
	                 WHERE c.ObjectID = @ContractID) as OutContractSum,
	                (SELECT dbo.GetSumString(SUM(o.Sum), null)
	                 FROM dbo.Outcome o 
	                   join dbo.[Contract] c on o.[Contract] = c.ObjectID
	                 WHERE c.ObjectID =  @ContractID) as OutcomesSum,
	                 (SELECT dbo.GetSumString(SUM(od.Sum), null)
	                 FROM dbo.OutDoc od 
	                   join dbo.[Contract] c on od.[Contract] = c.ObjectID
	                 WHERE c.ObjectID =  @ContractID) as OutDocSum
					");
                cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, false, contractID);

                using (IDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                       arDataRows = Utils._GetDataFromDataRow(reader);
                }
                menu_sec = menu.Items.AddSection("Расходы по проекту");

                string sOutContractSum = Utils.ParseDBString(arDataRows["OutContractSum"].ToString()).ToString("C2", culture) + " руб с НДС";
                menu_sec.Items.AddInfoItem("Общая сумма расходных договоров", sOutContractSum);
                string sOutcomesSum = Utils.ParseDBString(arDataRows["OutcomesSum"].ToString()).ToString("C2", culture) + " руб с НДС";
                menu_sec.Items.AddInfoItem("Общая сумма расходов без документа по проекту", sOutcomesSum);
                string sOutDocSum = Utils.ParseDBString(arDataRows["OutDocSum"].ToString()).ToString("C2", culture) + " руб с НДС";
                menu_sec.Items.AddInfoItem("Общая сумма расходных документов", sOutDocSum);
                menu_sec = menu.Items.AddSection("Отчеты");
                item = menu_sec.Items.AddActionItem("Плановый Буджет Доходов и Расходов проекта", "DoRunReport");
                item.Parameters.Add("ReportName", "ProjectBudget");
                item.Parameters.Add("UrlParams", ".InContract=@@ContractID");
                item = menu_sec.Items.AddActionItem("Фин-план по проекту", "DoRunReport");
                item.Parameters.Add("ReportName", "ProjectBDDS");
                item.Parameters.Add("UrlParams", ".InContract=@@ContractID");
            }
            catch(XObjectNotFoundException)
            {
                // объект не найден в БД
                menu.Items.AddInfoItem("", "Объект удален из БД");
            }
            return menu;
        }

        #endregion

        #region Меню для узлов типа "Расходный документ"

        private XTreeMenuInfo getMenuForOutDocument(XTreePath path, DomainObjectDataSet dataSet, XStorageConnection con)
        {
            XMenuActionItem item;
            XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);

            menu.CacheMode = XTreeMenuCacheMode.NoCache;

            try
            {
                DomainObjectData xobj = dataSet.Load(con, "OutDoc", path[0].ObjectID);

                XObjectRights rights;
                rights = XSecurityManager.Instance.GetObjectRights(xobj);

                Guid outDocumentID = path.PathNodes[0].ObjectID;

                if (rights.AllowParticalOrFullChange)
                {
                    item = menu.Items.AddActionItem("Редактировать", StdActions.DoEdit);
                    item.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_PARENTNODE");
                    item.Title = "Редактировать";
                }
                if (rights.AllowDelete)
                {
                    item = menu.Items.AddActionItem("Удалить", StdActions.DoDelete);
                    item.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_PARENTNODE");
                    item.Title = "Удалить";
                }


                // Получение списка расходов по текущему документу
                XDbCommand cmd = con.CreateCommand(@"
                    SELECT ot.Name as OutTypeName, 
	                       dbo.GetSumString(o.[Sum], null) as OutSum,
	                       CONVERT(varchar(10), o.[Date], 4) as OutDate,
	                       o.Fact as IsOutFact
                    FROM dbo.Outcome o
	                     join dbo.OutDoc od WITH (NOLOCK) on o.Document = od.ObjectID 
	                     join dbo.OutType ot WITH (NOLOCK) on o.[Type] = ot.ObjectID
                    WHERE od.ObjectID =  @OutDocumentID
					");
                cmd.Parameters.Add("OutDocumentID", DbType.Guid, ParameterDirection.Input, false, outDocumentID);

                using (IDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        XMenuSection menu_sec = menu.Items.AddSection("Расходы по документу");
                        
                        do
                        {
                            string sOutTypeName = reader.GetString(reader.GetOrdinal("OutTypeName"));
                            string sOutSum = reader.GetString(reader.GetOrdinal("OutSum"));
                            string sOutDate = reader.GetString(reader.GetOrdinal("OutDate"));
                            bool IsOutFact = reader.GetBoolean(reader.GetOrdinal("IsOutFact"));
                            string sIsOutFact = IsOutFact ? "Фактический" : "Плановый";
                            string sCaption = sOutTypeName + ": [" + sOutDate + "]  - " + sOutSum;

                            menu_sec.Items.AddInfoItem(sCaption, sIsOutFact);
                        }
                        while (reader.Read());

                    }
                }
            }
            catch (XObjectNotFoundException)
            {
                // объект не найден в БД
                menu.Items.AddInfoItem("", "Объект удален из БД");
            }
            return menu;
        }

        #endregion

        #region Меню для узлов типа "Назначение авансового отчета"

        private XTreeMenuInfo getMenuForAO(XTreePath path, DomainObjectDataSet dataSet, XStorageConnection con)
        {
            XMenuActionItem item;
            XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);

            menu.CacheMode = XTreeMenuCacheMode.NoCache;
            

            try
            {   
                Guid AOReasonID = path.PathNodes[0].ObjectID;
                Guid ContractID = path.PathNodes[2].ObjectID;   
                
                DomainObjectData xobjNew = dataSet.CreateStubNew("AO");
                xobjNew.SetUpdatedPropValue("Contract", ContractID);
                xobjNew.SetUpdatedPropValue("Reason", AOReasonID);

                if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
                {
                    // Создать авансовый отчет по данному проекту
                    item = menu.Items.AddActionItem("Создать авансовый отчет", StdActions.DoCreate);
                    item.Parameters.Add("ObjectType", "AO");
                    item.Parameters.Add("URLPARAMS", ".Contract=" + ContractID.ToString());
                    item.Parameters.Add("RefreshFlags", "TRM_PARENT+TRM_NODE");
                }
                

                // Получение списка авансовых отчетов по текущему назаначению
                XDbCommand cmd = con.CreateCommand(@"
                    SELECT
	                    CONVERT(varchar(10), a.[Date], 4) as AODate,
	                    dbo.GetSumString(a.[Sum], NULL) AS AOSum,
	                    dbo.GetEmployeeString(a.Employee) as AOEmployee
                    FROM
	                    dbo.AO a
	                    join dbo.[Contract] c WITH (NOLOCK) on a.[Contract] = c.ObjectID
                    WHERE 
	                    c.ObjectID = @ContractID and a.Reason = @AOReasonID
                    ORDER BY a.[Date]
					");
                cmd.Parameters.Add("AOReasonID", DbType.Guid, ParameterDirection.Input, false, AOReasonID);
                cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, false, ContractID);

                using (IDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        XMenuSection menu_sec = menu.Items.AddSection("Авансовые отчеты");

                        do
                        {
                            string sAODate = reader.GetString(reader.GetOrdinal("AODate"));
                            string sAOSum = reader.GetString(reader.GetOrdinal("AOSum"));
                            string sAOEmployee = reader.GetString(reader.GetOrdinal("AOEmployee"));
                            string sCaption = "[" + sAODate + "]  - " + sAOSum;

                            menu_sec.Items.AddInfoItem(sCaption, sAOEmployee);
                        }
                        while (reader.Read());

                    }
                }
            }
            catch (XObjectNotFoundException)
            {
                // объект не найден в БД
                menu.Items.AddInfoItem("", "Объект удален из БД");
            }
            return menu;
        }

        #endregion

		private XTreeMenuInfo getMenuForProjectParticipant(XTreePath path, DomainObjectDataSet dataSet, XStorageConnection con)
		{
			XMenuActionItem item;
			XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);

			menu.CacheMode = XTreeMenuCacheMode.NoCache;
			// см. s-tree-DKP.vbs
			menu.ExecutionHandlers.Add( new XUserCodeWeb("DKP_FolderMenu_ExecutionHandler"));
			DomainObjectData xobj = dataSet.Load(con,"ProjectParticipant", path[0].ObjectID);
			Guid employeeID = (Guid) xobj.GetPropValue("Employee", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			Guid folderID = (Guid) xobj.GetPropValue("Folder",DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			menu.Items.AddActionItem("Просмотр карточки сотрудника", StdActions.DoView).Parameters.Add("ReportURL", StdMenuUtils.GetEmployeeReportURL(null, employeeID));
			bool bSep = true;

			// Редактировать/Удалить/Создать (только для состава)
			if ( "Stuff" == path[1].ObjectType)
			{
				XObjectRights rights;
				rights = XSecurityManager.Instance.GetObjectRights(xobj);
				xobj = dataSet.CreateStubNew(xobj.ObjectType);
				xobj.SetUpdatedPropValue("Folder", folderID);
				if(XSecurityManager.Instance.GetRightsOnNewObject(xobj).AllowCreate)
				{
					if( bSep ) 
						menu.Items.AddSeparatorItem();
					item = menu.Items.AddActionItem("Добавить участника", StdActions.DoCreate);
					item.Parameters.Add("ObjectType", "ProjectParticipant");
					item.Parameters.Add("URLParams", ".Folder=@@FolderID");
					item.Parameters.Add("RefreshFlags", "TRM_PARENTNODE");
					bSep = true;
				}

				if (rights.AllowParticalOrFullChange)
				{
					if( bSep ) 
						menu.Items.AddSeparatorItem();
					item = menu.Items.AddActionItem("Редактировать", StdActions.DoEdit);
					item.Title = "Редактировать участника";
					item.Parameters.Add("RefreshFlags", "TRM_NONE");
					bSep = true;
				}
				if (rights.AllowDelete)
				{
					if( bSep ) 
						menu.Items.AddSeparatorItem();
					item = menu.Items.AddActionItem("Удалить", StdActions.DoDelete);
					item.Parameters.Add("RefreshFlags", "TRM_NODE");
					item.Title = "Удалить участие сотрудника";
				}
			}

			// Теперь выведем общее меню отчётов
			// Отчеты
			XMenuSection menu_sec = menu.Items.AddSection("Отчеты");
			item = menu_sec.Items.AddActionItem("Список инцидентов и затрат проекта (по инцидентам)", "DoRunReport");
			item.Parameters.Add("ReportName", "ProjectIncidentsAndExpenses");
			item.Parameters.Add("UrlParams", ".Folder=@@FolderID&.Workers=@@EmployeeID&.WorkerOrganizations=&.WorkerDepartments=");
			item = menu_sec.Items.AddActionItem("Список инцидентов и затрат проекта (по сотрудникам)", "DoRunReport");
			item.Parameters.Add("ReportName", "ProjectParticipantsAndExpenses");
			item.Parameters.Add("UrlParams", ".Folder=@@FolderID&.Employees=@@EmployeeID&.Organizations=&.Departments=");
			item = menu_sec.Items.AddActionItem("Списание времени сотрудниками", "DoRunReport");
			item.Parameters.Add("ReportName", "TimeLosses");
			item.Parameters.Add("UrlParams", ".Folder=@@FolderID&.Employees=@@EmployeeID&.Organizations=&.Departments=");

			/*
			item = menu_sec.Items.AddActionItem("Динамика затрат сотрудников", "DoRunReport");
			item.Parameters.Add("ReportName", "ReportUsersExpences");
			item.Parameters.Add("UrlParams", ".Folder=@@FolderID&.Employees=@@EmployeeID");
			*/

			item = menu_sec.Items.AddActionItem("Инциденты и списания времени сотрудника", "DoRunReport");
			item.Parameters.Add("ReportName", "ReportEmployeeExpensesList");
			item.Parameters.Add("UrlParams", ".Employee=@@EmployeeID");

			menu_sec.Items.AddSeparatorItem();

			item = menu_sec.Items.AddActionItem("Баланс списаний сотрудника", "DoRunReport");
			item.Parameters.Add("ReportName", "EmployeeExpensesBalance");
			item.Parameters.Add("UrlParams", ".Employee=@@EmployeeID");
			item = menu_sec.Items.AddActionItem("Занятость сотрудника в проектах", "DoRunReport");
			item.Parameters.Add("ReportName", "EmployeesBusynessInProjects");
			item.Parameters.Add("UrlParams", ".Employees=@@EmployeeID&.Departments=&.Organizations=");

			menu_sec = menu.Items.AddSection("Информация");
			CompanyTreeMenuDataProvider.fillEmployeeInfoSection(menu_sec, employeeID, con);


			bool bFirst = true;
			//menu_sec = menu.Items.AddSection("Проектные роли");
			using(XDbCommand cmd= con.CreateCommand())
			{
				cmd.CommandText = @"SELECT 
	IsNull(r.Name, '<< Не определена >>')
FROM 
	dbo.view_FolderParticipantsAndRoles x
	LEFT JOIN dbo.UserRoleInProject r ON r.ObjectID=x.RoleID
WHERE
	x.FolderID=" + con.ArrangeSqlGuid(folderID) + @"
	AND
	x.EmployeeID=" + con.ArrangeSqlGuid(employeeID);
				using(IDataReader r = cmd.ExecuteReader())
				{
					while(r.Read())
					{
						menu_sec.Items.AddInfoItem(bFirst?"Проектные роли":null, r.GetString(0));
						bFirst=false;
					}
				}
			}

			return menu;
		}

		#region Меню для узлов типа "Организация"

		internal struct OrgInfo 
		{
			/// <summary>
			/// Данные Диретора Клиента (организации)
			/// </summary>
			internal struct OrgDirectorInfo 
			{
				public Guid DirectorID;	// Идентификатор сотрудника
				public string FullName;	// Полное имя, в виде "Фамилия Имя (#ВнутрТелефон)"
				public string EMail;	// Адрес электронной почты (если нет, то null)
			}
           	public bool IsOwnerOrg;		// Признак описания организации, владеющей системой
			public string FullName;		// Полное наименование организации
			public string ShortName;	// Краткое наименование организации (если нет, то null)
			public string NavisionCode;	// Идентификатор организации в Navision (если нет, то null)
			public OrgDirectorInfo[] DirectorsInfo;	// Данные всех директоров Клиента

			/// <summary>
			/// Получение данных заданной организации
			/// </summary>
			/// <param name="uidOrg">Идентификатор организации, данные которой загружаются</param>
			/// <param name="connection">Соединение с БД</param>
			/// <returns>Данные организации</returns>
			public static OrgInfo GetOrgInfo( Guid uidOrg, XStorageConnection connection ) 
			{
				OrgInfo info = new OrgInfo();

				XDbCommand cmd = connection.CreateCommand();
				cmd.CommandType = CommandType.Text;
				cmd.CommandText = @"
	/* Опорные данные и общая информация */
	SELECT
        o.Home,
		o.[Name] AS FullName,
		ISNULL(o.ShortName, '') AS [ShortName],
		ISNULL(o.ExternalID, '') AS [NavisionCode]
	FROM dbo.Organization o WITH(NOLOCK)
	WHERE o.ObjectID = @OrgID

	/* Директор(а) Клиента - рассматриваемой организации и всех вышестоящих */
	SELECT
		emp.ObjectID AS DirectorID,
		emp.LastName + ' ' + emp.FirstName + ISNULL( ' (#' + emp.PhoneExt + ')', '' ) AS FullName,
		ISNULL(emp.EMail, '') AS EMail
	FROM dbo.Organization o WITH(NOLOCK)
			JOIN dbo.Organization oUp WITH(NOLOCK) ON oUp.LIndex <= o.LIndex AND oUp.RIndex >= o.RIndex
			JOIN dbo.Employee emp WITH(NOLOCK) ON emp.ObjectID = oUp.Director
	WHERE o.ObjectID = @OrgID
	ORDER BY o.LRLevel DESC ";
				cmd.Parameters.Add( "OrgID", DbType.Guid, ParameterDirection.Input, false, uidOrg );

				using(IXDataReader reader = cmd.ExecuteXReader())
				{
					if (!reader.Read())
						throw new ApplicationException( "Ошибка получения опорных данных для организации (ID = " + uidOrg.ToString() + ")" );
			
					// ВНИМАНИЕ! При изменении запроса - проконтроллировать соответствие наименований ординалов!
					info.IsOwnerOrg = reader.GetBoolean(reader.GetOrdinal("Home"));
					info.FullName = reader.GetString(reader.GetOrdinal("FullName"));
					info.ShortName = reader.GetString(reader.GetOrdinal("ShortName"));
					info.NavisionCode = reader.GetString(reader.GetOrdinal("NavisionCode"));

					if (reader.NextResult())
					{
						ArrayList arrDirectorsInfo = new ArrayList();
						while( reader.Read() )
						{
							OrgDirectorInfo infoDir = new OrgDirectorInfo();
							infoDir.DirectorID = reader.GetGuid(reader.GetOrdinal("DirectorID"));
							infoDir.FullName = reader.GetString(reader.GetOrdinal("FullName"));
							infoDir.EMail = reader.GetString(reader.GetOrdinal("EMail"));
							arrDirectorsInfo.Add(infoDir);
						}
						info.DirectorsInfo = new OrgDirectorInfo[arrDirectorsInfo.Count];
						if (arrDirectorsInfo.Count > 0)
							arrDirectorsInfo.CopyTo(info.DirectorsInfo);
					}
					else
						info.DirectorsInfo = new OrgDirectorInfo[0];
				}

				return info;
			}
		}
		
		/// <summary>
		/// Построение меню для узлов типа "Организация" (в т.ч. временных организаций 
		/// и организации, владеющей системой).
		/// </summary>
		/// <param name="uidOrg">Идентификатор организации, для которой строится меню</param>
		/// <param name="path">Путь в иерархии до организации, для которой строится меню</param>
		/// <param name="dataSet"></param>
		/// <param name="connection"></param>
		/// <returns>Объектное описание меню</returns>
		private XTreeMenuInfo buildMenuForOrganization( Guid uidOrg, XTreePath path, DomainObjectDataSet dataSet, XStorageConnection connection ) 
		{
			// Получение данных по организации:
			OrgInfo infoOrg = OrgInfo.GetOrgInfo( uidOrg, connection );

			// Права на работу с данными организации:
			DomainObjectData xobj = dataSet.GetLoadedStub( "Organization", uidOrg );
			xobj.SetLoadedPropValue( "Home", infoOrg.IsOwnerOrg );
			XObjectRights rightsOnThisOrg = XSecurityManager.Instance.GetObjectRights(xobj);

			xobj = dataSet.CreateStubNew("Organization");
			xobj.SetUpdatedPropValue("Home",false);
			XNewObjectRights rightsOnNewTempOrg = XSecurityManager.Instance.GetRightsOnNewObject(xobj);
			XNewObjectRights rightsOnNewConstOrg = XSecurityManager.Instance.GetRightsOnNewObject(xobj);
			XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;
			menu.ExecutionHandlers.Add( new XUserCodeWeb("DKP_OrganizationMenu_ExecutionHandler")); // см. s-tree-DKP.vbs

			XMenuActionItem menuItem;
			XMenuSection menuSection;

			#region Секция операций

			// TODO: НУЖНА ОПЕРАЦИЯ ПРОСМОТРА!
			// menuItem = menu.Items.AddActionItem("Просмотр", StdActions.DoView);
			// menu.Items.AddSeparatorItem();

			// "Создать", всякие:
			// ...создание постоянного описания организации
			if (rightsOnNewConstOrg.AllowCreate)
			{
				menuItem = menu.Items.AddActionItem("Создать описание организации", StdActions.DoCreate);
				menuItem.Parameters.Add("ObjectType", "Organization");
				menuItem.Parameters.Add("MetanameForCreate", "CommonEditor");
				menuItem.Parameters.Add("RefreshFlags", "TRM_TREE");
			}
			
            /* Подчиненные организации в версии 8.0 отсутствуют
            
            // ...создание описания подчиненной организации - только в том случае, если 
			// рассматриваемая организация - сама постоянная, и при этом не является
			// организацией-владельцем (последний случай пока не поддерживается)
			
            if (!infoOrg.IsOwnerOrg && rightsOnNewConstOrg.AllowCreate)
			{
				xobj.SetUpdatedPropValue("Parent", uidOrg);
				if (XSecurityManager.Instance.GetRightsOnNewObject(xobj).AllowCreate)
				{
					menuItem = menu.Items.AddActionItem("Создать описание подчиненной организации", StdActions.DoCreate);
					menuItem.Parameters.Add("ObjectType", "Organization");
					menuItem.Parameters.Add("MetanameForCreate", "CommonEditor");
					menuItem.Parameters.Add("URLParams", ".Parent=@@ObjectID");
					menuItem.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_CHILDS");
				}
			}
            */

			// "Редактировать" и вариации редактирования:
			if (rightsOnThisOrg.AllowParticalOrFullChange)
			{
				menuItem = menu.Items.AddActionItem("Редактировать", "DoEdit");
				menuItem.Parameters.Add("ObjectType", "Organization");
				menuItem.Parameters.Add("MetanameForEdit", "CommonEditor");
				menuItem.Parameters.Add("RefreshFlags", "TRM_NODE");

                /* Подчиненные организации в версии 8.0 отсутствуют
				// ...операция изменения подчинения - представлена только в том случае, 
				// если рассматриваемая организация - постоянная и при этом не является
				// организацией-владельцем системы (такой случай пока не поддреживается):
				if (!infoOrg.IsOwnerOrg)
				{
					menuItem = menu.Items.AddActionItem("Изменить вышестоящую организацию", StdActions.DoMove);
					menuItem.Parameters.Add("RefreshFlags", "TRM_TREE");
					menuItem.Parameters.Add("ParentPropName", "Parent");
					menuItem.Parameters.Add("Metaname", "OrganizationSelector");
					menuItem.Parameters.Add("UrlParams", "selection-mode=anynode");

					// Если организация имеет родителя, то - "Сделать корневой"
					if (xobj.GetLoadedPropValue("Parent") is Guid)
					{
						// TODO!
						menu.Items.AddActionItem("Сделать корневой", "");
					}
				}
                */

			}
			// ...если рассматриваемая организация - временная, то для нее возможна 
			// операция замены на постоянное описание - если у пользователя есть соотв. 
			// системные права:
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			// Операции по созданию подчиненных узлов - активностей:
			// Только для (а) постоянной организации, (б) которая НЕ является владельцем системы:
			if (!infoOrg.IsOwnerOrg)
			{
				// Операции создания папок добавляем, только если над над огранизацией есть узел 
				// "внешнего" вида проектных затрат - именно такого вида создаем активность:
				Guid activityTypeID = Guid.Empty;
				for( int i=0; i<path.Length; ++i )
					if ( path[i].ObjectType == DKPTreeObjectLocator.TYPE_ActivityTypeExternalUnderHomeOrg )
					{
						activityTypeID = path[i].ObjectID;
						break;
					}

				if (activityTypeID != Guid.Empty)
					addMenuItem_CreateFolderByActivityTypeAndOrganization( connection, menu, dataSet, activityTypeID, uidOrg );
				else
				{
					// Операция создание активности (папки) на корневом уровне доступна 
					// пользователям с правами на организацию или хотя бы один вид проектных 
					// затрат (тогда пользователь может создать активность для этого вида):
					bool bAllow = false;
					if (user.ManageOrganization(uidOrg))
						bAllow = true;
					else
						foreach(DomainObject_ActivityType obj_at in user.ActivityTypes.Values)
							if (obj_at.AccountRelated)
							{
								bAllow = true;
								break;
							}

					if (bAllow)
					{
						menu.Items.AddSeparatorItem();
						menuItem = menu.Items.AddActionItem("Создать активность", StdActions.DoCreate);
						menuItem.Parameters.Add("ObjectType", "Folder");
						menuItem.Parameters.Add("MetanameForCreate", "Universal");
						menuItem.Parameters.Add("UrlParams", ".Customer=" + uidOrg.ToString());
						menuItem.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_CHILDS");
					}
				}
			}

			// "Удалить"
			if (rightsOnThisOrg.AllowDelete)
			{
				menu.Items.AddSeparatorItem();
				menuItem = menu.Items.AddActionItem("Удалить", "DoDelete");
				menuItem.Parameters.Add("ObjectType", "Organization");
				menuItem.Parameters.Add("RefreshFlags", "TRM_PARENT");
			}

			#endregion

			#region Секция "Отчеты" 
			menuSection = menu.Items.AddSection("Отчеты");
			
			// Отчет "Затраты в разрезе направлений":
			// для организации-Клиента в диалог задания параметров передается
			// идентификатор организации; при этом для организаци-владелицы 
			// системы отчет СПЕЦИАЛЬНО параметризуется так, чтобы в диалоге 
			// параметров был включен режим "Все организации". См. код 
			// обработки параметров в s-Report-ExpensesByDirections.vbs:
			menuItem = menuSection.Items.AddActionItem("Затраты в разрезе направлений", "DoRunReport");
			menuItem.Parameters.Add( "ReportName", "ExpensesByDirections" );
			menuItem.Parameters.Add( "UrlParams", ".Folder=&.Organization=" + (infoOrg.IsOwnerOrg? "" : uidOrg.ToString()) );
			
			#endregion

			#region Секция "Информация"
			menuSection = menu.Items.AddSection("Информация");
			if (infoOrg.IsOwnerOrg)
				menuSection.Items.AddInfoItem("", "<B STYLE='color:green;'>Организация - владелец Системы</B>" );

			menuSection.Items.AddInfoItem( "Полное наименование", infoOrg.FullName );
			menuSection.Items.AddInfoItem( "Краткое наименование",
				null!=infoOrg.ShortName && String.Empty!=infoOrg.ShortName ? 
				infoOrg.ShortName : "(не задано)" );
			
			
		    menuSection.Items.AddInfoItem( "Код",
			null!=infoOrg.NavisionCode && String.Empty!=infoOrg.NavisionCode ?
			infoOrg.NavisionCode : "(не задано)" );
		    menuSection.Items.AddSeparatorItem();
            string sDirsInfo = null;
			foreach( OrgInfo.OrgDirectorInfo infoDir in infoOrg.DirectorsInfo )
			sDirsInfo =	(null==sDirsInfo? "" : sDirsInfo + ",<BR/>") + infoDir.FullName;
			menuSection.Items.AddInfoItem( 
			(infoOrg.DirectorsInfo.Length > 1 ? "Директор Клиента" : "Директора Клиента"),
			(null==sDirsInfo? "(не задан)" : sDirsInfo) );
			#endregion

			return menu;
		}
		
		
		#endregion

        #region Меню для узлов типа "Папка"

        private XTreeMenuInfo getMenuForFolder(XTreePath path, DomainObjectDataSet dataSet, IXExecutionContext context)
		{
			XStorageConnection con = context.Connection;
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			Guid folderID = path.PathNodes[0].ObjectID;
			XMenuActionItem item;
			XTreeMenuInfo menu = new XTreeMenuInfo(GetFolderFullName(con, folderID), true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;
			// см. s-tree-DKP.vbs
			menu.ExecutionHandlers.Add( new XUserCodeWeb("DKP_FolderMenu_ExecutionHandler"));
			Guid organizationID;
			Guid activityTypeID;
			Guid parentFolderID = Guid.Empty;
			FolderTypeEnum nType;
			
			try
			{
				DomainObjectData xobjFolder = dataSet.Load(con, "Folder", folderID);
				// считаем поля Тип папки и Клиент (оба not null)
				nType = (FolderTypeEnum)xobjFolder.GetLoadedPropValue("Type");
				organizationID = (Guid)xobjFolder.GetLoadedPropValue("Customer");
				activityTypeID = (Guid)xobjFolder.GetLoadedPropValue("ActivityType");
				if (xobjFolder.GetLoadedPropValue("Parent") != DBNull.Value)
					parentFolderID = (Guid)xobjFolder.GetLoadedPropValue("Parent");

				// "Просмотр"
				item = menu.Items.AddActionItem("Просмотр", StdActions.DoView);
				item.Parameters.Add("ReportURL", "x-get-report.aspx?name=r-Folder.xml&amp;ID=@@ObjectID");

				// создадим новый объект для проверки прав
				DomainObjectData xobjNew = dataSet.CreateStubNew("Folder");
				xobjNew.SetUpdatedPropValue("Type", nType);
				xobjNew.SetUpdatedPropValue("Customer", organizationID);
				xobjNew.SetUpdatedPropValue("ActivityType", activityTypeID);
				if (parentFolderID != Guid.Empty)
					xobjNew.SetUpdatedPropValue("Parent", parentFolderID);
				string sNewFolderParamForDefaultIncidentType = null;
				if (xobjFolder.GetLoadedPropValue("DefaultIncidentType") != DBNull.Value)
					sNewFolderParamForDefaultIncidentType = "&.DefaultIncidentType=" + (Guid)xobjFolder.GetLoadedPropValue("DefaultIncidentType");

				if (path.Length > 1)
				{
					if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
					{
						// Создать папку такого же типа, что и выбранная, на том же уровне
						item = menu.Items.AddActionItem("Создать " + getFolderTypeNameByType(nType, false), StdActions.DoCreate);
						item.Parameters.Add("ObjectType", "Folder");
						item.Parameters.Add("URLPARAMS", ".Parent=@@ParentFolderID&.Customer=@@OrganizationID&.ActivityType=@@ActivityType&.Type=" + (int)nType + (sNewFolderParamForDefaultIncidentType!=null ? sNewFolderParamForDefaultIncidentType : String.Empty) );
						item.Parameters.Add("RefreshFlags", "TRM_PARENT+TRM_NODE");
					}
				}

                // Для проекта: Создать Договор если еще нет
                if (nType == FolderTypeEnum.Project)
                {
                    xobjNew = dataSet.CreateStubNew("Contract");
                    xobjNew.SetUpdatedPropValue("Project", folderID);
                    if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
                    {
                        using (XDbCommand cmd2 = con.CreateCommand())
                        {
                            cmd2.CommandText = @"SELECT 1 FROM dbo.Contract c WHERE c.Project = " + con.ArrangeSqlGuid(folderID);
                            using (IDataReader reader = cmd2.ExecuteReader())
                            {
                                if (!reader.Read())
                                {
                                    item = menu.Items.AddActionItem("Создать Договор", StdActions.DoCreate);
                                    item.Parameters.Add("ObjectType", "Contract");
                                    item.Parameters.Add("URLPARAMS", ".Project=@@ObjectID");
                                    item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
                                }

                            }
                        }
                    }
                }

				// Для каталога: Создать подкаталог соответственно
				if (nType == FolderTypeEnum.Directory)
				{
					xobjNew = dataSet.CreateStubNew("Folder");
					xobjNew.SetUpdatedPropValue("Parent", folderID);
                    xobjNew.SetUpdatedPropValue("Type", FolderTypeEnum.Directory);
					xobjNew.SetUpdatedPropValue("Customer", organizationID);
					xobjNew.SetUpdatedPropValue("ActivityType", activityTypeID);
					if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
					{
                        item = menu.Items.AddActionItem("Создать подкаталог", StdActions.DoCreate);
						item.Parameters.Add("ObjectType", "Folder");
						item.Parameters.Add("URLPARAMS", ".Parent=@@ObjectID&.Customer=@@OrganizationID&.ActivityType=@@ActivityType&.Type=" + (int)nType + (sNewFolderParamForDefaultIncidentType!=null ? sNewFolderParamForDefaultIncidentType : String.Empty));
                        item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
					}
				}

				// Для всех типов папок кроме Каталога - Создать папку
				if (nType != FolderTypeEnum.Directory)
				{
					xobjNew = dataSet.CreateStubNew("Folder");
					xobjNew.SetUpdatedPropValue("Parent", folderID);
					xobjNew.SetUpdatedPropValue("Type", FolderTypeEnum.Directory);
					xobjNew.SetUpdatedPropValue("Customer", organizationID);
					xobjNew.SetUpdatedPropValue("ActivityType", activityTypeID);
					if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
					{
						item = menu.Items.AddActionItem("Создать каталог", StdActions.DoCreate);
						item.Parameters.Add("ObjectType", "Folder");
						item.Parameters.Add("URLPARAMS", ".Parent=@@ObjectID&.Customer=@@OrganizationID&.ActivityType=@@ActivityType&.Type=" + (int)FolderTypeEnum.Directory);
						item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
					}
				}

				if (menu.Items.Count > 0)
					menu.Items.AddSeparatorItem();

				// Создать инцидент
				xobjNew = dataSet.CreateStubNew("Incident");
				xobjNew.SetUpdatedPropValue("Folder", folderID);
				if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
				{
					item = menu.Items.AddActionItem("Создать инцидент", StdActions.DoCreate);
					item.Parameters.Add("ObjectType", "Incident");
					item.Parameters.Add("URLPARAMS", ".Folder=@@ObjectID");
					item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
				}
				// Создать инцидент с выбором папки на первом шаге
				addMenuItem_CreateIncidentWithSelectFolder(menu);

				// получим права на выбранную папку (Редактировать и Удалить)
				XObjectRights rights = XSecurityManager.Instance.GetObjectRights(xobjFolder);
				// Редактировать
				// ВНИМАНИЕ: помимо проверки прав на изменение хотя бы одного св-ва явно проверим права на изменение св-во Name,
				// Это сделано потому, что при наличии привилигии "Перенос папок" юзеру будут доступны для изменения св-ва Parent, Customer, ActivityType,
				// однако из редактора их изменять нельзя, поэтому смысла в разрешении операции "Редактировать" в этом случае нет
			    if (rights.AllowParticalOrFullChange)
				{
					menu.Items.AddSeparatorItem();
					item = menu.Items.AddActionItem("Редактировать", StdActions.DoEdit);
					item.Default = true;
					item.Parameters.Add("RefreshFlags", "TRM_NODE");
				}
				/* Перенести
				if (rights.HasPropChangeRight("Parent"))
				{
					menu.Items.AddActionItem("Перенести", "DoMoveFolder");
				}*/

				// Списать время
				xobjNew = dataSet.CreateStubNew("TimeLoss");
				xobjNew.SetUpdatedPropValue("Folder", folderID);
				xobjNew.SetUpdatedPropValue("Worker", user.EmployeeID );
				XNewObjectRights create_rights = XSecurityManager.Instance.GetRightsOnNewObject(xobjNew);
				if (create_rights.AllowCreate)
				{
					item = menu.Items.AddActionItem("Списать время", StdActions.DoCreate);
					item.Parameters.Add("ObjectType", "TimeLoss");
					item.Parameters.Add("UrlParams", ".Folder=" + folderID + "&.Worker=" + user.EmployeeID );
					item.Parameters.Add("RefreshFlags", "TRM_NONE");
					MenuObjectRightsFormatter.Write(item, create_rights);
				}

				// Создать участника проектной команды
				xobjNew = dataSet.CreateStubNew("ProjectParticipant");
				xobjNew.SetUpdatedPropValue("Folder", folderID);
                if (!rights.HasReadOnlyProp("Participants"))
                {
                    if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
                    {
                        item = menu.Items.AddActionItem("Добавить участника", StdActions.DoCreate);
                        item.Parameters.Add("ObjectType", "ProjectParticipant");
                        item.Parameters.Add("UrlParams", ".Folder=" + folderID.ToString());
                        item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
                    }
                }
				// Перенести инциденты
                if (rights.HasPropChangeRight("Incidents"))
                {
                    if (user.HasPrivilege(SystemPrivilegesItem.MoveFoldersAndIncidents.Name) ||
                        ((SecurityProvider)XSecurityManager.Instance.SecurityProvider).FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageIncidents, xobjFolder, con)
                        )
                    {
                        menu.Items.AddActionItem("Перенести инциденты", "DoMoveIncidents");
                    }
				}

				//menu.Items.AddActionItem("Копировать структуру папок", "DoCopyFolderStructure");

				// Написать письмо проектной команде
				item = menu.Items.AddActionItem("Написать письмо проектной команде", "DoExecuteVbs");
				item.Parameters.Add("Script", "MailFolderLinkToAll \"" + folderID + "\"");

				// Операции с буфером обмена и Favorites
				menu.Items.AddActionItem("Добавить в избранное ссылку на папку", "DoAddFavorite");
				menu.Items.AddActionItem("Копировать в буфер обмена полный путь до папки", "DoCopyFolderPathToClipboard");
				menu.Items.AddActionItem("Копировать в буфер обмена ссылку на папку", "DoCopyFolderLinkToClipboard");

				// Удалить
				if ( rights.AllowDelete )
				{
					menu.Items.AddSeparatorItem();
					item = menu.Items.AddActionItem("Удалить", StdActions.DoDelete);
					item.Parameters.Add("RefreshFlags", "TRM_PARENTNODE");
           		}

				// Отчеты
				XMenuSection menu_sec = menu.Items.AddSection("Отчеты");
				item = menu_sec.Items.AddActionItem("Список инцидентов и затрат проекта (по инцидентам)", "DoRunReport");
				item.Parameters.Add("ReportName", "ProjectIncidentsAndExpenses");
				item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);
				
				item = menu_sec.Items.AddActionItem("Список инцидентов и затрат проекта (по сотрудникам)", "DoRunReport");
				item.Parameters.Add("ReportName", "ProjectParticipantsAndExpenses");
				item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);
				
				item = menu_sec.Items.AddActionItem("Списание времени сотрудниками", "DoRunReport");
				item.Parameters.Add("ReportName", "TimeLosses");
				item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);
				
				item = menu_sec.Items.AddActionItem("Хроника изменений инцидентов проекта", "DoRunReport");
				item.Parameters.Add("ReportName", "FolderIncidentsHistory");
				item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);
				
				item = menu_sec.Items.AddActionItem("Динамика затрат сотрудников", "DoRunReport");
				item.Parameters.Add("ReportName", "ReportUsersExpences");
				item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);

				// ...отчет "Затарты в разрезе направлений" - только активностей
				if (nType != FolderTypeEnum.Directory)
				{
					item = menu_sec.Items.AddActionItem("Затраты в разрезе направлений", "DoRunReport");
					item.Parameters.Add("ReportName", "ExpensesByDirections");
					item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);
				}

				item = menu_sec.Items.AddActionItem("Затраты в разрезе департаментов", "DoRunReport");
				item.Parameters.Add("ReportName", "CostsByDepartments");
				item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);

				// Информация
				menu_sec = menu.Items.AddSection("Информация");
				// Код проекта и код в Navision - только для активностей:
				if (nType != FolderTypeEnum.Directory)
				{
					// Код проекта:
					// Код проекта в Navision:
					if (xobjFolder.GetLoadedPropValue("ExternalID") != DBNull.Value)
						menu_sec.Items.AddInfoItem("Код", (string)xobjFolder.GetLoadedPropValue("ExternalID"));
					else
						menu_sec.Items.AddInfoItem("Код", "(не задан)" );
				}
				// Состояние
				FolderStates folderState = (FolderStates)xobjFolder.GetLoadedPropValue("State");
				menu_sec.Items.AddInfoItem("Состояние", FolderStatesItem.GetItem(folderState).Description);
				
				// Признак блокировки списания на папку
				bool bIsDirectExpensesBlocked = (bool)xobjFolder.GetLoadedPropValue( "IsLocked" );
				menu_sec.Items.AddInfoItem( 
					"Списания на папку", 
					bIsDirectExpensesBlocked ? 
						"<B STYLE='color:maroon;'>Заблокированы</B>" : 
						"<B STYLE='color:green;'>Разрешены</B>"
					);
				
				// Направления
				XDbCommand cmd = con.CreateCommand( @"
					SELECT d.[Name] AS DirectionName
					FROM dbo.FolderDirection fd WITH(NOLOCK) 
						JOIN dbo.Direction d WITH(NOLOCK) ON d.ObjectID = fd.Direction
					WHERE fd.Folder = @FolderID
					ORDER BY d.IsObsolete, d.[Name]
				" );
				cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, folderID);
				using(IDataReader reader = cmd.ExecuteReader())
				{
					if (reader.Read())
					{
						StringBuilder sbDirsList = new StringBuilder();
						sbDirsList.Append("<DIV STYLE='font-weight:normal;'>");
						sbDirsList.AppendFormat( "{0}", reader.GetString( reader.GetOrdinal("DirectionName") ) ); 
						for( ;reader.Read(); )
							sbDirsList.AppendFormat( ";<BR/>{0}", reader.GetString( reader.GetOrdinal("DirectionName") ) ); 
						sbDirsList.Append("</DIV>");

						menu_sec.Items.AddSeparatorItem();
						menu_sec.Items.AddInfoItem( "Направления", sbDirsList.ToString() );
					}
				}
				
				// Проектная команда - как отдельная секция
				// Получение результирующего списка
				cmd = con.CreateCommand(@"
					SELECT emp.LastName + ' ' + emp.FirstName AS EmployeeFullName, 
						x.Roles, 
						emp.ObjectID AS EmployeeID, 
						emp.EMail AS EmployeeEMail
					FROM dbo.GetAllFolderParticipants(@FolderID) x 
						JOIN dbo.Employee emp WITH(NOLOCK) ON emp.ObjectID = x.EmployeeID
					ORDER BY emp.LastName
					");
				cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, folderID);
				string sValue;
				using(IDataReader reader = cmd.ExecuteReader())
				{
					if (reader.Read())
					{
						menu_sec = menu.Items.AddSection("Проектная команда");
						do
						{
							Guid employeeID = reader.GetGuid( reader.GetOrdinal("EmployeeID"));
							string sEmployeeFullName = reader.GetString( reader.GetOrdinal("EmployeeFullName"));
							int nIndex = reader.GetOrdinal("EmployeeEMail");
							if (reader.IsDBNull(nIndex))
								sValue = sEmployeeFullName;
							else
							{
								string sEmployeeEmail = reader.GetString(nIndex);
								sValue = createEmployeeHTMLLinkWithContextMenu(employeeID, sEmployeeEmail, sEmployeeFullName, "Folder", folderID, context.Config);
							}
							nIndex = reader.GetOrdinal("Roles");
							string sRoles;
							if (reader.IsDBNull(nIndex))
								sRoles = "-- не определена --";
							else
								sRoles = reader.GetString(nIndex);
							menu_sec.Items.AddInfoItem(sRoles, sValue);
						} 
						while (reader.Read());
					}
				}
			}
			catch(XObjectNotFoundException)
			{
				// объект не найден в БД
				menu.Items.AddInfoItem("", "Объект удален из БД");
			}
						
			return menu;
		}

        private string getFolderTypeNameByType(FolderTypeEnum nType, bool bSub)
		{
			return getFolderTypeNameByType(nType, bSub, CASES.Nominative);
		}

		private string getFolderTypeNameByType(FolderTypeEnum nType, bool bSub, CASES nCase)
		{
			string sName;
			switch(nType)
			{
				case FolderTypeEnum.Directory:
					sName = bSub ? "подкаталог" : "каталог";
					break;
				case FolderTypeEnum.Presale:
					sName = "пресейл";
					break;
				case FolderTypeEnum.Project:
					sName = bSub ? "подпроект" : "проект";
					break;
				case FolderTypeEnum.Tender:
					sName = "тендер";
					break;
				default:
					throw new ArgumentException();
			}
			if (nCase == CASES.Prepositional)
				sName = sName + "е";	// проектЕ, тендерЕ, каталогЕ
			else if (nCase == CASES.Genitive)
				sName = sName + "а";	// проектА, тендерА, каталогА
			return sName;
		}

        #endregion

        private XTreeMenuInfo getMenuForActivityType(XTreePath path, DomainObjectDataSet dataSet, XStorageConnection con)
		{
			Guid organizationID = Guid.Empty;
			Guid activityTypeID = path[0].ObjectID;

			XTreeMenuInfo menu = new XTreeMenuInfo("Тип проектных затрат \"@@Title\"", true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;

			// найдем идентификатор организации, он всегда выше по пути
			for(int i=0;i<path.Length;++i)
				if (path[i].ObjectType == "Organization" || path[i].ObjectType == "HomeOrganization")
				{
					organizationID = path[i].ObjectID;
					break;
				}
			Debug.Assert(organizationID != Guid.Empty);
			if (organizationID == Guid.Empty)
				throw new ApplicationException("Не удалось найти вышестоящую организацию");

			// Если текущий тип проектных затрат - это тип проектных затрат в отношении клиента (и следовательно он находиться под организацией-владельцем),
			// то устаналивать ссылку на организацию-клиента при создании папки не надо, т.к. он еще не известен (будет выбран в мастере)
			if (path[0].ObjectType == DKPTreeObjectLocator.TYPE_ActivityTypeExternalUnderHomeOrg)
			{
				organizationID = Guid.Empty;
			}

			if (!addMenuItem_CreateFolderByActivityTypeAndOrganization(con, menu, dataSet, activityTypeID, organizationID))
				return menu;

			// Создать инцидент с выбором папки на первом шаге
			addMenuItem_CreateIncidentWithSelectFolder(menu);

			// Создадим секцию с перечнем сотрудников, обладающих правами на текущий тип проектных затрат
			XMenuSection menu_sec = new XMenuSection("Info", "Менеджеры");
			XDbCommand cmd = con.CreateCommand(@"
				SELECT emp.LastName + ' ' + emp.FirstName 
				FROM SystemUser_ActivityTypes su_at
					JOIN Employee emp ON emp.SystemUser = su_at.ObjectID
				WHERE su_at.Value = @ObjectID"
				);
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, activityTypeID);
			using(IDataReader reader = cmd.ExecuteReader())
			{
				while (reader.Read())
				{
					menu_sec.Items.AddInfoItem("", reader.GetString(0));
				}
				if (menu_sec.Items.Count > 0)
					menu.Items.Add(menu_sec);
			}
			return menu;
		}

		/// <summary>
		/// Создает пункт меню "Создать ХХХ", где ХХХ - наименование типа папки, поддерживаемого заданным типом проектных затрат
		/// </summary>
		/// <param name="con"></param>
		/// <param name="menu"></param>
		/// <param name="dataSet"></param>
		/// <param name="activityTypeID"></param>
		/// <param name="organizationID"></param>
		/// <returns></returns>
		private bool addMenuItem_CreateFolderByActivityTypeAndOrganization(XStorageConnection con, XTreeMenuInfo menu, DomainObjectDataSet dataSet, Guid activityTypeID, Guid organizationID)
		{
			FolderTypeEnum nType;
			DomainObjectData xobj;
			XMenuActionItem menuitem;
			// зачитаем из БД допустимые типы папок для выбранного вида активности
			XDbCommand cmd = con.CreateCommand("SELECT FolderType FROM " + con.GetTableQName("ActivityType") + " WHERE ObjectID = @ObjectID");
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, activityTypeID);

			using(IDataReader reader = cmd.ExecuteReader())
			{
				if (reader.Read())
				{
					nType = (FolderTypeEnum)reader.GetInt16( reader.GetOrdinal("FolderType") );
					// "выключим" "Каталог"
					nType = nType & (~FolderTypeEnum.Directory);
					xobj = dataSet.CreateStubNew("Folder");
					if (organizationID != Guid.Empty)
						xobj.SetUpdatedPropValue("Customer", organizationID);
					xobj.SetUpdatedPropValue("ActivityType", activityTypeID);
					foreach(FolderTypeEnumItem item in FolderTypeEnumItem.GetItems(nType))
					{
						xobj.SetUpdatedPropValue("Type", item.IntValue);
						if (XSecurityManager.Instance.GetRightsOnNewObject(xobj).AllowCreate)
						{
							menuitem = menu.Items.AddActionItem("Создать " + getFolderTypeNameByType(item.Value, false), StdActions.DoCreate);
							menuitem.Parameters.Add("ObjectType", "Folder");
							string sUrlParams = String.Empty;
							if (organizationID != Guid.Empty)
								sUrlParams = ".Customer=" + organizationID.ToString();
							sUrlParams = sUrlParams + "&.ActivityType=" + activityTypeID + "&.Type=" + item.IntValue;
							menuitem.Parameters.Add("UrlParams", sUrlParams);
							menuitem.Parameters.Add("RefreshFlags", "TRM_CHILDS");
						}
					}
					return true;
				}
				else
				{
					menu.Items.AddInfoItem(String.Empty, "Выбранный объект был удален");
					return false;
				}
			}
		}

		private XTreeMenuInfo getMenuForIncident(Guid ObjectID, DomainObjectDataSet dataSet, IXExecutionContext context)
		{
			XStorageConnection con = context.Connection;
			XMenuActionItem menuitem;
			DomainObjectData xobj;
			Guid FolderID;
			DomainObjectData xobjIncident;
			string sIncidentStateName;
			string sIncidentTypeName;
			string sIncidentInitiatorFIO;
			Guid initiatorID;
			string sInitiatorEMail;
			DateTime dtLastActivityDate;

			XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;
			// см. s-tree-DKP.vbs
			menu.ExecutionHandlers.Add( new XUserCodeWeb("DKP_FolderMenu_ExecutionHandler"));
			XDbCommand cmd = con.CreateCommand(@"
				SELECT i.Number, i.Name, i.Folder AS FolderID, 
					i.InputDate,
					i.Priority,
					i.DeadLine,
					i.State As IncidentStateID,
					st.Name AS StateName,
					it.Name AS TypeName,
					emp.ObjectID AS EmployeeID,
					emp.EMail AS UserEMail,
					emp.LastName + ' ' + emp.FirstName AS UserName,
					f.Type AS FolderType,
					(
						SELECT MAX(tmp.d)
						FROM 
							(
								SELECT /*дата заведения инцидента*/
									i2.InputDate d
								FROM dbo.Incident i2 WITH (NOLOCK) 
								WHERE i2.ObjectID = i.ObjectID 
								UNION 
								SELECT /*дата последнего списания времени по заданиям инцидента*/
									IsNull(Max(ts2.RegDate), 0) d
								FROM dbo.TimeSpent ts2 WITH (NOLOCK) 
									JOIN dbo.Task t2 WITH (NOLOCK) ON ts2.Task = t2.ObjectID
								WHERE t2.Incident = i.ObjectID 
								UNION 
								SELECT /*дата последнего изменения состояния инцидента*/
									IsNull(Max(h2.ChangeDate), 0) d  
								FROM dbo.IncidentStateHistory h2 WITH (NOLOCK) 
								WHERE h2.Incident = i.ObjectID 
							) tmp
					) AS LastActivityDate
				FROM Incident i WITH (NOLOCK)
					JOIN IncidentState st WITH (NOLOCK) ON i.State = st.ObjectID
					JOIN IncidentType it WITH (NOLOCK) ON i.Type = it.ObjectID
					JOIN SystemUser su WITH (NOLOCK) ON i.Initiator = su.ObjectID
						LEFT JOIN Employee emp WITH (NOLOCK) ON emp.SystemUser = su.ObjectID
					JOIN Folder f WITH (NOLOCK) ON i.Folder=f.ObjectID 
				WHERE i.ObjectID = @ObjectID"
				);
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, ObjectID);
			using(IDataReader reader = cmd.ExecuteReader())
			{
				if (reader.Read())
				{
					FolderID = reader.GetGuid( reader.GetOrdinal("FolderID") );
					FolderTypeEnum nFolderType = (FolderTypeEnum)reader.GetInt16( reader.GetOrdinal("FolderType") );
					sIncidentStateName = reader.GetString(reader.GetOrdinal("StateName"));
					sIncidentTypeName = reader.GetString(reader.GetOrdinal("TypeName"));
					sIncidentInitiatorFIO = reader.GetString(reader.GetOrdinal("UserName"));
					dtLastActivityDate = reader.GetDateTime(reader.GetOrdinal("LastActivityDate"));
					initiatorID = reader.GetGuid( reader.GetOrdinal("EmployeeID") );
					sInitiatorEMail = String.Empty;
					if (!reader.IsDBNull(reader.GetOrdinal("UserEMail")))
						sInitiatorEMail = reader.GetString(reader.GetOrdinal("UserEMail"));
					// Просмотр инцидента
					menuitem = menu.Items.AddActionItem("Просмотр", StdActions.DoView);
					menuitem.Parameters.Add("ReportURL", "x-get-report.aspx?name=r-Incident.xml&amp;DontCacheXslfo=true&amp;IncidentID=@@ObjectID");

					xobj = dataSet.CreateStubNew("Incident");
					xobj.SetUpdatedPropValue("Folder", FolderID);
					// Создать инцидент (в той же папке)
					if (XSecurityManager.Instance.GetRightsOnNewObject(xobj).AllowCreate)
					{
						menuitem = menu.Items.AddActionItem("Создать инцидент в текущем " + getFolderTypeNameByType(nFolderType,false,CASES.Prepositional), StdActions.DoCreate);
						menuitem.Parameters.Add("ObjectType", "Incident");
						menuitem.Parameters.Add("URLPARAMS", ".Folder=@@FolderID");
						menuitem.Parameters.Add("RefreshFlags", "TRM_PARENT");						
					}

					// Создать инцидент с выбором папки на первом шаге
					addMenuItem_CreateIncidentWithSelectFolder(menu);

					xobjIncident = dataSet.GetLoadedStub("Incident", ObjectID);
					xobjIncident.SetLoadedPropValue("Folder", FolderID);
					xobjIncident.SetLoadedPropValue("Name", reader.GetString( reader.GetOrdinal("Name")));
					xobjIncident.SetLoadedPropValue("Number", reader.GetInt32( reader.GetOrdinal("Number")));
					xobjIncident.SetLoadedPropValue("InputDate", reader.GetDateTime(reader.GetOrdinal("InputDate")));
					xobjIncident.SetLoadedPropValue("Priority", reader.GetInt16(reader.GetOrdinal("Priority")));
					xobjIncident.SetLoadedPropValue("State", reader.GetGuid(reader.GetOrdinal("IncidentStateID")));
					int i = reader.GetOrdinal("DeadLine");
					if (!reader.IsDBNull(i))
						xobjIncident.SetLoadedPropValue("DeadLine", reader.GetDateTime(i));
					XObjectRights rights = XSecurityManager.Instance.GetObjectRights(xobjIncident);

					// Редактировать
					// Примечание: возможно, что есть права на перенос инцидента, но нет прав на редактирование, 
					//		поэтому явно проверим права на свойство "Наименование"
					if ( rights.HasPropChangeRight("Name"))
					{
						menuitem = menu.Items.AddActionItem("Редактировать", StdActions.DoEdit);
						menuitem.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_CHILDS");
						menuitem.Default = true;
					}
					// Удалить
					if ( rights.AllowDelete )
					{
						menuitem = menu.Items.AddActionItem("Удалить", StdActions.DoDelete);
						menuitem.Parameters.Add("RefreshFlags", "TRM_PARENT");
					}

					// Переместить
					if (rights.HasPropChangeRight("Folder"))
					{
						menu.Items.AddActionItem("Перенести", "DoMoveIncident");
					}
					
					// Операции с буфером обмена
					menu.Items.AddActionItem("Копировать в буфер обмена ссылку на инцидент", "DoCopyIncidentLinkToClipboard");
					menu.Items.AddActionItem("Копировать в буфер обмена ссылку на форму просмотра", "DoCopyIncidentViewLinkToClipboard");

					// Изменить тип
					/* TODO: раскомментировать когда будет сделан редактор изменения типа.
					if (rights.HasPropChangeRight("Type"))
					{
						menuitem = menu.Items.AddActionItem("Изменить тип", StdActions.DoEdit);
						menuitem.Parameters.Add("MetanameForEdit", "ChangeType");
					}
					*/
				}
				else
				{
					menu.Items.AddInfoItem("Выбранный объект был удален", String.Empty);
					return menu;
				}
			}
			// Секция "Задания"
			addTaskList(con, ObjectID, menu, context, dataSet);
			// Секция "Информация":
			// Состояния, Дата регистрации, Зарегистрировал, Тип инцидента, Приоритет, Дата последней активности
			XMenuSection sec = menu.Items.AddSection("Информация");
			sec.Items.AddInfoItem("Состояния", sIncidentStateName);
			sec.Items.AddInfoItem("Дата регистрации", ((DateTime)xobjIncident.GetLoadedPropValue("InputDate")).ToString("dd.MM.yyyy HH:mm") );
			sec.Items.AddInfoItem("Зарегистрировал", 
				createEmployeeHTMLLinkWithContextMenu(initiatorID, sInitiatorEMail, sIncidentInitiatorFIO, "Incident", ObjectID, context.Config)
				);
			sec.Items.AddInfoItem("Тип инцидента", sIncidentTypeName);
			sec.Items.AddInfoItem("Приоритет", IncidentPriorityItem.GetItem((IncidentPriority)xobjIncident.GetLoadedPropValue("Priority")).Description );
			if (xobjIncident.HasLoadedProp("DeadLine"))
				sec.Items.AddInfoItem("Крайний срок", xobjIncident.GetLoadedPropValue("DeadLine").ToString());
			sec.Items.AddInfoItem("Дата последней активности", dtLastActivityDate.ToString("dd.MM.yyyy HH:mm"));

			addLinkedIncidents(con, ObjectID, menu);
			return menu;
		}

        /// <summary>
        /// Для виртуальных узлов "Договор", "Лимиты", "Приходы" и "Расходы"
        /// </summary>
        /// <param name="path"></param>
        /// <param name="dataSet"></param>
        /// <returns></returns>
        private XTreeMenuInfo getMenuForContractsVirtualNode(XTreePath path, DomainObjectDataSet dataSet)
        {
            string sObjectType = path[0].ObjectType;
            XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
            menu.CacheMode = XTreeMenuCacheMode.NoCache;
            if (sObjectType == "Contracts")
                menu.Caption = "Договор";
            if (sObjectType == "OutLimits")
                menu.Caption = "Лимиты по расходам ДС";
            if (sObjectType == "Incomes")
                menu.Caption = "Приходы ДС";
            if (sObjectType == "Outcomes")
                menu.Caption = "Расходы ДС";
            return menu;
        }

		/// <summary>
		/// Возвращает меню для виртуальных узлов "Договор", "Проектная команда", "Все участники" и объектов "Роль пользователя в папке" (ProjectParticipant)
		/// </summary>
		/// <param name="path"></param>
		/// <param name="dataSet"></param>
		/// <returns></returns>
		private XTreeMenuInfo getMenuForTeamAndRoleNode(XTreePath path, DomainObjectDataSet dataSet)
		{
			string sObjectType = path[0].ObjectType;
			XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;
			if (sObjectType == "UserRoleInProject")
				menu.Caption = "Проектная роль @@Title";
  
            XMenuActionItem item;
            Guid folderID = Guid.Empty;
            // найдем идентификатор папки - возьмем первую попавшующая папку вверх по пути (она всегда есть!)
            for (int i = 0; i < path.Length; ++i)
                if (path[i].ObjectType == "Folder")
                {
                    folderID = path[i].ObjectID;
                    break;
                }
            if (folderID == Guid.Empty)
                throw new ApplicationException("Не удалось найти идентификатор папки в пути: " + path.ToString());
            DomainObjectData xobjNew = dataSet.CreateStubNew("ProjectParticipant");
            xobjNew.SetUpdatedPropValue("Folder", folderID);
            if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
            {
                item = menu.Items.AddActionItem("Добавить участника", StdActions.DoCreate);
                item.Parameters.Add("ObjectType", "ProjectParticipant");
                item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
                if (sObjectType == "UserRoleInProject")
                {
                    item.Title = "Добавить участника в данной роли";
                    item.Parameters.Add("URLPARAMS", ".Folder=" + folderID.ToString() + "&.Roles=@@ObjectID");
                }
                else	// if (sObjectType == "Stuff")
                {
                    item.Parameters.Add("URLPARAMS", ".Folder=" + folderID.ToString());
                }
            }
            
            return menu;
		}

		/// <summary>
		/// Добавляет секцию Задания в меню со списком исполнителей инцидента (роль, ФИО, количество затраченного и оставшегося времени),
		/// а также, если срези заданий есть задание текущего пользователя, то в меню добавляется пункт "Списать время"
		/// </summary>
		/// <param name="con">соединение с БД</param>
		/// <param name="ObjectID">Идентификатор инцидента</param>
		/// <param name="menu">Текущее меню узла инцидента</param>
		/// <param name="context">контекст команды</param>
		private void addTaskList(XStorageConnection con, Guid ObjectID, XMenu menu, IXExecutionContext context, DomainObjectDataSet dataSet)
		{
			XDbCommand cmd;
			cmd = con.CreateCommand(@"
				SELECT t.ObjectID AS TaskID,
					SUM(IsNull(ts.Spent,0)) AS SpentTime, 
					ur.Name AS RoleName, 
					worker_emp.ObjectID AS EmployeeID,
					worker_emp.LastName + ISNULL(' ' + worker_emp.FirstName, '') AS UserFullName, 
					worker_emp.PhoneExt AS UserPhone,
					worker_emp.EMail AS UserEMail,
					dep.Name As DepName,
					t.LeftTime
				FROM Task t WITH (NOLOCK)
					JOIN UserRoleInIncident ur WITH (NOLOCK) ON t.Role = ur.ObjectID
					JOIN Employee worker_emp WITH (NOLOCK) ON t.Worker = worker_emp.ObjectID
						LEFT JOIN Department dep WITH (NOLOCK) ON dep.ObjectID = worker_emp.Department
					LEFT JOIN TimeSpent ts WITH (NOLOCK) ON ts.Task = t.ObjectID
				WHERE t.Incident = @IncidentID
				GROUP BY t.ObjectID, ur.Name, worker_emp.ObjectID, worker_emp.LastName, worker_emp.FirstName, worker_emp.PhoneExt, worker_emp.EMail, dep.Name, t.LeftTime
				ORDER BY UserFullName"
				);
			cmd.Parameters.Add("IncidentID", DbType.Guid, ParameterDirection.Input, false, ObjectID);
			using(IDataReader reader = cmd.ExecuteReader())
			{
				
				XMenuSection sec = new XMenuSection("TaskList", "Задания");
				string sValue;
				int nIndex;
				string sUserEMail;
				Guid EmployeeID;
				XMenuActionItem item;
				while (reader.Read())
				{
					// Пункт: {Роль} : {ФИО} ({Телефон})
					EmployeeID = reader.GetGuid( reader.GetOrdinal("EmployeeID") );
					sValue = reader.GetString(reader.GetOrdinal("UserFullName"));
					nIndex = reader.GetOrdinal("UserPhone");
					if (!reader.IsDBNull(nIndex))
						sValue = sValue + " (" + reader.GetString(nIndex) + ")";
					sUserEMail = null;
					nIndex = reader.GetOrdinal("UserEMail");
					if (!reader.IsDBNull(nIndex))
						sUserEMail = reader.GetString(nIndex);
					sec.Items.AddInfoItem(
						reader.GetString(reader.GetOrdinal("RoleName")), 
						"<span style='font-size:10pt;color:black;'>" + 
						createEmployeeHTMLLinkWithContextMenu(EmployeeID, sUserEMail, sValue, "Incident", ObjectID, context.Config) +
						"</span>"
						);

					// Пункт: Осталось/затрачено
					int nLeftTime = reader.GetInt32(reader.GetOrdinal("LeftTime"));
					int nSpentTime = reader.GetInt32(reader.GetOrdinal("SpentTime"));
					int nWorkdayDuration = ((ITUser)XSecurityManager.Instance.GetCurrentUser()).WorkdayDuration;
					sec.Items.AddInfoItem(String.Empty, 
						"<span style='font-size:8pt;color:navy;font-weight:normal;'>" +
							Utils.FormatTimeDuration(nLeftTime, nWorkdayDuration) + " / " + 
						Utils.FormatTimeDuration(nSpentTime, nWorkdayDuration) +
						"</span>"
						);

					// если текущее задание - это задание текущего сотрудника, то в меню (не в секцию Задания), добавим пункт "Затратить время"
					ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
					if (EmployeeID == user.EmployeeID)
					{
						Guid taskID = reader.GetGuid(reader.GetOrdinal("TaskID"));
						DomainObjectData xobj = dataSet.CreateStubNew("TimeSpent");
						xobj.SetUpdatedPropValue("Task", taskID);
						// Затратить время
						if (XSecurityManager.Instance.GetRightsOnNewObject(xobj).AllowCreate)
						{
							item = menu.Items.AddActionItem("Затратить время", StdActions.DoCreate);
							item.Parameters.Add("ObjectType", "TimeSpent");
							item.Parameters.Add("URLParams", ".Task=" + taskID + "&.RegDate=" + XmlConverter.GetXmlTypedValue(DateTime.Now, "dateTime.tz"));
							item.Parameters.Add("RefreshFlags", "TRM_NODE");
						}
					}
				}
				if (sec.Items.Count > 0)
				{
					// если есть список исполнителей, то дабвим пункт в основное меню "Написать всем участникам"
					item = menu.Items.AddActionItem("Написать всем участникам инцидента", "DoExecuteVbs");
					item.Parameters.Add("Script", "MailIncidentLinkToAll \"" + ObjectID + "\"");

					menu.Items.Add(sec);
				}
			}
		}

		
		#region Методы добавления общих/типовых пунктов меню

		/// <summary>
		/// Добавляет пункт "Создать инцидент с выбором папки"
		/// Права на доступность операции не проверяются
		/// </summary>
		/// <param name="menu">меню</param>
		/// <returns>созданный пункт</returns>
		private XMenuActionItem addMenuItem_CreateIncidentWithSelectFolder(XMenu menu)
		{
			// Т.к. мы не знаем, где будет создаваться инцидент, то операция доступна всегда
			XMenuActionItem menuitem;
			menuitem = menu.Items.AddActionItem("Создать инцидент с выбором папки", StdActions.DoCreate);
			menuitem.Parameters.Add("ObjectType", "Incident");
			menuitem.Parameters.Add("MetanameForCreate", "WizardWithSelectFolder");
			menuitem.Parameters.Add("RefreshFlags", "TRM_PARENT");
			return menuitem;
		}

		
		/// <summary>
		/// Создает HTML код для вставки в качестве значения информационного пункта меню.
		/// Создает ссылка (<A>) с контекстным меню из операций "Написать письмо" и "Просмотр"
		/// </summary>
		/// <param name="EmployeeID">Идентификатор сотрудника</param>
		/// <param name="sUserEMail">e-mail сотрудника (может быть null)</param>
		/// <param name="sTitle">Текст ссылки (not null)</param>
		/// <param name="sRelatedType">Наименование типа связанного объекта: Folder или Incident</param>
		/// <param name="relatedObjectID">Идентификатор связанного объекта</param>
		/// <param name="config">конифгурация</param>
		/// <returns>HTML-код</returns>
		private string createEmployeeHTMLLinkWithContextMenu(Guid EmployeeID, string sUserEMail, string sTitle, string sRelatedType, Guid relatedObjectID, XConfig config)
		{
			if (sRelatedType != "Incident" && sRelatedType != "Folder")
				throw new ArgumentException("Неподдерживаемое значение параметра sRelatedType: " + sRelatedType);

			string sMenuXml = String.Format(
				"<i:menu trustworthy='1' xmlns:i='http://www.croc.ru/Schemas/XmlFramework/Interface/1.0'>" +
				"<i:visibility-handler>EmployeeContextMenu_VisibilityHandler</i:visibility-handler>" +
				"<i:execution-handler>EmployeeContextMenu_ExecutionHandler</i:execution-handler>" +
				"<i:menu-item action='DoMailAbout{0}' t='Написать письмо' separator-after='1'>" +
				"	<i:params>" + 
				"		<i:param n='EmployeeID'>" + EmployeeID + "</i:param>" +
				"		<i:param n='{0}ID'>{1}</i:param>" +
				"	</i:params>" +
				"</i:menu-item>", 
				sRelatedType, 
				relatedObjectID);

			string sReportURL = StdMenuUtils.GetEmployeeReportURL(config, EmployeeID);
			if (sReportURL != null)
			{
				sMenuXml = sMenuXml +
					"<i:menu-item action='DoView' t='Просмотр'>" +
					"	<i:params><i:param n='ReportURL'>" + sReportURL + "</i:param></i:params>" +
					"</i:menu-item>";
			}

			// Отчеты
			sMenuXml = sMenuXml +
				"<i:menu-item action='DoRunReport' t='Инциденты и списания времени сотрудника' separator-before='1'>" +
				"	<i:params>" +
				"		<i:param n='ReportName'>ReportEmployeeExpensesList</i:param>" +
				"		<i:param n='UrlParams'>.Employee=" + EmployeeID + "</i:param>" + 
				"	</i:params>" +
				"</i:menu-item>" +
				"<i:menu-item action='DoRunReport' t='Баланс списаний сотрудника'>" +
				"	<i:params>" +
				"		<i:param n='ReportName'>EmployeeExpensesBalance</i:param>" +
				"		<i:param n='UrlParams'>.Employee=" + EmployeeID + "</i:param>" + 
				"	</i:params>" +
				"</i:menu-item>";

			sMenuXml = sMenuXml +
				"</i:menu>";

			// клиентский идентификатор элемента TEXTAREA c метаданными контекстного меню, открываемого на ссылке с именем сотрудника
			string sMenuMDDivID = "oMenuMD" + Guid.NewGuid().ToString().Replace("-","");
			StringBuilder htmlBuilder = new StringBuilder(32);
			htmlBuilder.Append("<A CLASS='menu-mail-to' HREF='' TITLE='Левая клавиша - написать письмо, правая - контекстное меню' onContextMenu=\"ShowContextMenuForEmployee '");
			htmlBuilder.Append(EmployeeID);
			htmlBuilder.Append("', ");
			htmlBuilder.Append(sMenuMDDivID);
			htmlBuilder.Append("\" language='VBScript' ");
			if (sRelatedType == "Incident")
			{
				htmlBuilder.Append(" onClick=\"MailIncidentLinkToUser '");
			}
			else
			{
				htmlBuilder.Append(" onClick=\"MailFolderLinkToUser '");
			}
			htmlBuilder.Append(relatedObjectID);
			htmlBuilder.Append("', '");
			htmlBuilder.Append(EmployeeID);
			htmlBuilder.Append("', Null\" ");
			if (sUserEMail != null)
			{
				htmlBuilder.Append(" onmouseover=\"CrocUserOver '");
				htmlBuilder.Append(sUserEMail.ToLower());
				htmlBuilder.Append("', 5\" onmouseout='CrocUserOut'");
			}
			htmlBuilder.Append(">");
			htmlBuilder.Append(sTitle);
			htmlBuilder.Append("</A><TEXTAREA style='display:none;' id='");
			htmlBuilder.Append(sMenuMDDivID);
			htmlBuilder.Append("'>");
			htmlBuilder.Append(HttpUtility.HtmlEncode( "<?xml version=\"1.0\" encoding=\"windows-1251\"?>" + sMenuXml ));
			htmlBuilder.Append("</TEXTAREA>");
			return htmlBuilder.ToString();
		}

		#endregion

		public override XTreeMenuInfo GetMenuForEmptyTree(XGetTreeMenuRequest request, IXExecutionContext context, XTreePageInfoStd treePage)
		{
			XTreeMenuInfo menu = new XTreeMenuInfo(String.Empty);
			menu.Items.AddActionItem("Создать организацию", "DoCreate").Parameters.Add("ObjectType", "Organization");
			return menu;
		}

		/// <summary>
		/// Добавляет секцию "Связанные инциденты" в меню инцидента
		/// </summary>
		/// <param name="con">Соединение с БД</param>
		/// <param name="incidentID">Идентификатор инцидента</param>
		/// <param name="menu">Меню</param>
		private void addLinkedIncidents(XStorageConnection con, Guid incidentID, XTreeMenuInfo menu)
		{
			XDbCommand cmd = con.CreateCommand(@"
				SELECT i.ObjectID, i.Number, i.Name, i_s.Name AS StateName, i_t.Name AS TypeName
				FROM IncidentLink il WITH(NOLOCK)
					JOIN Incident i WITH(NOLOCK) ON il.RoleB = i.ObjectID
						JOIN IncidentState i_s WITH(NOLOCK) ON i.State = i_s.ObjectID
						JOIN IncidentType i_t  WITH(NOLOCK) ON i.Type = i_t.ObjectID
				WHERE il.RoleA = @ObjectID 
				UNION
				SELECT i.ObjectID, i.Number, i.Name, i_s.Name, i_t.Name
				FROM IncidentLink il WITH(NOLOCK)
					JOIN Incident i WITH(NOLOCK) ON il.RoleA = i.ObjectID
						JOIN IncidentState i_s WITH(NOLOCK) ON i.State = i_s.ObjectID
						JOIN IncidentType i_t  WITH(NOLOCK) ON i.Type = i_t.ObjectID
				WHERE il.RoleB = @ObjectID 
				");
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, incidentID);
			XMenuSection menu_sec = new XMenuSection("", "Связанные инциденты");
			DKPTreeObjectLocator locator = new DKPTreeObjectLocator();
			ArrayList aLinkedIncidenObjectIDs = new ArrayList();
			using(IDataReader reader = cmd.ExecuteReader())
			{
				while(reader.Read())
				{
					// [{TypeName}][{StateName}]{Number} - {Name}
					StringBuilder bld = new StringBuilder(10);
					bld.Append("[");
					bld.Append(reader.GetString(reader.GetOrdinal("TypeName")));
					bld.Append("] [");
					bld.Append(reader.GetString(reader.GetOrdinal("StateName")));
					bld.Append("] №");
					bld.Append(reader.GetInt32(reader.GetOrdinal("Number")));
					bld.Append(" - ");
					bld.Append(reader.GetString(reader.GetOrdinal("Name")));
					aLinkedIncidenObjectIDs.Add(reader.GetGuid(reader.GetOrdinal("ObjectID")));
					
					menu_sec.Items.AddActionItem(bld.ToString(), "DoNavigate");
				}
			}
			if (menu_sec.Items.Count > 0)
			{
				for(int i = 0; i< menu_sec.Items.Count; ++i)
                    ((XMenuActionItem)menu_sec.Items[i]).Parameters.Add("Path", locator.GetIncidentFullPath(con, (Guid)aLinkedIncidenObjectIDs[i]).ToString());
				menu.Items.Add(menu_sec);
			}
		}
        /// <summary>
        /// Функция возвращает полный путь до папки
        /// </summary>
        /// <param name="con">текущее соединение </param>
        /// <param name="folderID"></param>
        /// <returns></returns>
        private string GetFolderFullName(XStorageConnection con, Guid folderID)
        {
            // Создадим команду, получающую полный путь к папке
            XDbCommand cmd = con.CreateCommand("SELECT dbo.GetFullFolderName( @uidFolderID,0)");
            // Добавляем идентификатор папки 
            cmd.Parameters.Add("uidFolderID", DbType.Guid, ParameterDirection.Input, false, folderID);
            return cmd.ExecuteScalar().ToString();
        }
	}
}
