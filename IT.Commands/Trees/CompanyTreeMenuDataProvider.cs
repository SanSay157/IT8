//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using System.Data;
using Croc.IncidentTracker.Commands.Trees;
using Croc.IncidentTracker.Hierarchy;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using XTreeLevelInfoIT = Croc.IncidentTracker.Hierarchy.XTreeLevelInfoIT;

namespace Croc.IncidentTracker.Trees
{
	/// <summary>
	/// Загрузчик меню для иерархии "Структура компаний"
	/// </summary>
	public class CompanyTreeMenuDataProvider : XTreeMenuDataProviderStd
	{
		public override XTreeMenuInfo GetMenu(XGetTreeMenuRequest request, IXExecutionContext context, XTreePageInfoStd treePage)
		{
			XTreeStructInfo treeStructInfo = treePage.TreeStruct;
			XTreeLevelInfoIT levelinfo = treeStructInfo.Executor.GetTreeLevel(treeStructInfo, request.Params, request.Path);

			XTreeMenuInfo treemenu = null;
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			// получим идентификатор объекта, для которого строится меню
			Guid ObjectID = request.Path.PathNodes[0].ObjectID;
			switch(levelinfo.ObjectType)
			{
				case "Organization":
					treemenu = getMenuForOrganization(ObjectID, dataSet, context);
					break;
				case "Department":
					treemenu = getMenuForDepartment(ObjectID, dataSet, context);
					break;
				case "Employee":
					treemenu = getMenuForEmployee(ObjectID, dataSet, context);
					break;
				default:
					treemenu = levelinfo.GetMenu(request, context);
					break;
			}
			if (treemenu == null)
				treemenu = treePage.DefaultLevelMenu.GetMenu(levelinfo, request, context);

			if (treemenu != null)
			{
				if (context.Config.IsDebugMode)
					treemenu.Items.AddActionItem("Обновить", StdActions.DoNodeRefresh).SeparatorBefore = true;
			}

			return treemenu;
		}

		public override XTreeMenuInfo GetMenuForEmptyTree(XGetTreeMenuRequest request, IXExecutionContext context, XTreePageInfoStd treePage)
		{
			XTreeMenuInfo menu = new XTreeMenuInfo("", true);
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			DomainObjectData xobj = dataSet.CreateNew("Organization", true);
			xobj.SetUpdatedPropValue("Home", true);
			XNewObjectRights create_right = XSecurityManager.Instance.GetRightsOnNewObject(xobj);
			if (create_right.AllowCreate)
			{
				XMenuActionItem item = menu.Items.AddActionItem("Создать организацию-владельца системы", StdActions.DoCreate);
				item.Parameters.Add("ObjectType", "Organization");
				item.Parameters.Add("URLPARAMS", ".Home=1");
			}
			return menu;
		}

		internal static bool fillEmployeeInfoSection(XMenuSection sec, Guid EmployeeID, XStorageConnection cn)
		{
			using(XDbCommand cmd = cn.CreateCommand(
					  "SELECT " +
					  "	emp.EMail, emp.Phone, emp.PhoneExt, p.Name AS PositionName, o.Home " +
					  "FROM Employee emp " +
					  "	LEFT JOIN Position p ON emp.Position = p.ObjectID " +
					  "	JOIN Organization o ON emp.Organization = o.ObjectID " +
					  "WHERE emp.ObjectID = @ObjectID"
					  ))
			{
				cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, EmployeeID);
				bool bIsHome;
				string sEMail = null;
				string sPhone = null;
				string sPhoneExt = null;
				string sPositionName = null;
				using(IXDataReader reader = cmd.ExecuteXReader())
				{
					if (reader.Read())
					{
						bIsHome = reader.GetBoolean(reader.GetOrdinal("Home"));
						if (!reader.IsDBNull(reader.GetOrdinal("EMail")))
							sEMail = reader.GetString(reader.GetOrdinal("EMail"));
						if (!reader.IsDBNull(reader.GetOrdinal("Phone")))
							sPhone = reader.GetString(reader.GetOrdinal("Phone"));
						if (!reader.IsDBNull(reader.GetOrdinal("PhoneExt")))
							sPhoneExt = reader.GetString(reader.GetOrdinal("PhoneExt"));
						if (!reader.IsDBNull(reader.GetOrdinal("PositionName")))
							sPositionName = reader.GetString(reader.GetOrdinal("PositionName"));
				
						sec.Items.AddInfoItem("EMail", sEMail);
						if (bIsHome && sPhoneExt != null)
							sec.Items.AddInfoItem("Внутренний телефон", sPhoneExt);
						else
						{
							sec.Items.AddInfoItem("Телефон", 
								(sPhone != null && sPhone.Length >0 ? sPhone : "")+ 
								(sPhoneExt!=null && sPhoneExt.Length>0 ? "(" + sPhoneExt+ ")" : "")
								);
						}
						if (sPositionName != null)
							sec.Items.AddInfoItem("Должность", sPositionName);
						return true;
					}
				}
				return false;
			}
		}

		private XTreeMenuInfo getMenuForEmployee(Guid ObjectID, DomainObjectDataSet dataSet, IXExecutionContext context)
		{
			XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;
			menu.ExecutionHandlers.Add( new XUserCodeWeb("CompanyTree_Menu_ExecutionHandler"));

			// просмотр
            // Раскоментировать после удаления ссылок на НСИ
			//menu.Items.AddActionItem("Просмотр", StdActions.DoView).Parameters.Add("ReportURL", StdMenuUtils.GetEmployeeReportURL(context.Config,  ObjectID));
            
            DomainObjectData xobj = dataSet.GetLoadedStub("Employee", ObjectID);
			XObjectRights rights = XSecurityManager.Instance.GetObjectRights(xobj);
             
            // Редактировать
			if (rights.AllowParticalOrFullChange)
				menu.Items.AddActionItem("Редактировать", StdActions.DoEdit).Default = true;
			// Удалить
			if (rights.AllowDelete)
				menu.Items.AddActionItem("Удалить", StdActions.DoDelete);

			// Секция "Отчеты"
			//XMenuActionItem item;
			//XMenuSection sec = menu.Items.AddSection("Отчеты");
            //item = sec.Items.AddActionItem("Сальдо ДС", "DoView");
            //item.Parameters.Add("ReportURL", "x-get-report.aspx?name=r-EmployeeSaldoDS.xml&amp;EmployeeID=@@ObjectID");
			
            /*
            item = sec.Items.AddActionItem("Инциденты и списания времени сотрудника", "DoRunReport");
			item.Parameters.Add("ReportName", "ReportEmployeeExpensesList");
			item.Parameters.Add("UrlParams", ".Employee=" + ObjectID);
			item = sec.Items.AddActionItem("Баланс списаний сотрудника", "DoRunReport");
			item.Parameters.Add("ReportName", "EmployeeExpensesBalance");
			item.Parameters.Add("UrlParams", ".Employee=" + ObjectID);
            item = sec.Items.AddActionItem("Плановая занятость сотрудников", "DoRunReport");
            item.Parameters.Add("ReportName", "Employment");
            item.Parameters.Add("UrlParams", ".Employees=" + ObjectID + "&.Organizations=&.Departments=");
            */
          	
            // Секция "Информация"
            XMenuSection sec = menu.Items.AddSection("Информация");
			fillEmployeeInfoSection(sec,ObjectID, context.Connection);
			return menu;
		}

		private XTreeMenuInfo getMenuForDepartment(Guid ObjectID, DomainObjectDataSet dataSet, IXExecutionContext context)
		{
			XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;
            menu.ExecutionHandlers.Add(new XUserCodeWeb("CompanyTree_Menu_ExecutionHandler"));
			XMenuActionItem item;

			// Создать подчиненый отдел
			DomainObjectData xobj = dataSet.CreateNew("Department", true);
			xobj.SetUpdatedPropValue("Parent", ObjectID);
			XNewObjectRights create_right = XSecurityManager.Instance.GetRightsOnNewObject(xobj);
			if (create_right.AllowCreate)
			{
				item = menu.Items.AddActionItem("Создать подчиненый отдел", StdActions.DoCreate);
				item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
				item.Parameters.Add("URLPARAMS", ".Parent=@@ObjectID&.Organization=@@OrgID&IsHomeOrg=@@IsHomeOrg");
			}

			// Создать направление
			xobj = dataSet.CreateNew("Direction", true);
			xobj.SetUpdatedPropValue("Department", ObjectID);
			create_right = XSecurityManager.Instance.GetRightsOnNewObject(xobj);
			if (create_right.AllowCreate)
			{
				item = menu.Items.AddActionItem("Создать направление", StdActions.DoCreate);
				item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
				item.Parameters.Add("ObjectType", "Direction");
				item.Parameters.Add("URLPARAMS", ".Department=@@ObjectID");
			}

			// Создать сотрудника
			xobj = dataSet.CreateNew("Employee", true);
			xobj.SetUpdatedPropValue("Department", ObjectID);
			create_right = XSecurityManager.Instance.GetRightsOnNewObject(xobj);
			if (create_right.AllowCreate)
			{
				item = menu.Items.AddActionItem("Создать сотрудника", StdActions.DoCreate);
				item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
				item.Parameters.Add("ObjectType", "Employee");
				item.Parameters.Add("URLPARAMS", ".Department=@@ObjectID&IsHomeOrg=@@IsHomeOrg&.Organization=@@OrgID");
			}

			if (menu.Items.Count > 0)
				menu.Items.AddSeparatorItem();

			DomainObjectData xobjDep = dataSet.GetLoadedStub("Department", ObjectID);
			XObjectRights rights = XSecurityManager.Instance.GetObjectRights(xobjDep);
			// Редактировать
			if (rights.AllowParticalOrFullChange)
			{
				item = menu.Items.AddActionItem("Редактировать отдел", StdActions.DoEdit);
				item.Default = true;
				item.Hotkey = "VK_ENTER";
				item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
			}

			// Удалить
			if (rights.AllowDelete)
				menu.Items.AddActionItem("Удалить отдел", StdActions.DoDelete).SeparatorBefore = true;
            // Секция "Отчеты"
            /*
            XMenuSection sec = menu.Items.AddSection("Отчеты");
            item = sec.Items.AddActionItem("Норма рабочего времени", "DoRunReport");
            item.Parameters.Add("ReportName", "EmployeesRate");
            item.Parameters.Add("UrlParams", ".Organization=" + Guid.Empty + "&.Department=" + ObjectID);
            item = sec.Items.AddActionItem("Плановая занятость сотрудников", "DoRunReport");
            item.Parameters.Add("ReportName", "Employment");
            item.Parameters.Add("UrlParams", ".Employees=&.Organizations=&.Departments=" + ObjectID);
             */
			return menu;
		}

		private XTreeMenuInfo getMenuForOrganization(Guid ObjectID, DomainObjectDataSet dataSet, IXExecutionContext context)
		{
			XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
			XMenuActionItem item;
			menu.CacheMode = XTreeMenuCacheMode.NoCache;
            menu.ExecutionHandlers.Add(new XUserCodeWeb("CompanyTree_Menu_ExecutionHandler"));

			// Создать отдел
            DomainObjectData xobjDep = dataSet.CreateNew("Department", true);
            xobjDep.SetUpdatedPropValue("Organization", ObjectID);
            XNewObjectRights create_right = XSecurityManager.Instance.GetRightsOnNewObject(xobjDep);
			if (create_right.AllowCreate)
			{
				item = menu.Items.AddActionItem("Создать отдел", StdActions.DoCreate);
				item.Parameters.Add("ObjectType", "Department");
				item.Parameters.Add("URLPARAMS", ".Organization=@@ObjectID&IsHomeOrg=@@IsHomeOrg");
				item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
			}

			// Создать сотрудника
            DomainObjectData xobj = dataSet.CreateNew("Employee", true);
			xobj.SetUpdatedPropValue("Organization", ObjectID);
			create_right = XSecurityManager.Instance.GetRightsOnNewObject(xobj);
			if (create_right.AllowCreate)
			{
				item = menu.Items.AddActionItem("Создать сотрудника", StdActions.DoCreate);
				item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
				item.Parameters.Add("ObjectType", "Employee");
				item.Parameters.Add("URLPARAMS", ".Organization=@@ObjectID&IsHomeOrg=@@IsHomeOrg");
			}

			if (menu.Items.Count > 0)
				menu.Items.AddSeparatorItem();
            xobj = dataSet.GetLoadedStub("Organization", ObjectID);
            XObjectRights rights = XSecurityManager.Instance.GetObjectRights(xobj);
			// Редактировать
			if (rights.AllowParticalOrFullChange)
			{
				item = menu.Items.AddActionItem("Редактировать", StdActions.DoEdit);
				item.Default = true;
				item.Hotkey = "VK_ENTER";
				item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
			}

			// Удалить
			if (rights.AllowDelete)
				menu.Items.AddActionItem("Удалить отдел", StdActions.DoDelete).SeparatorBefore = true;

			// Секция "Информация"
			/*
            XMenuSection sec = menu.Items.AddSection("Информация");
			sec.Items.AddInfoItem("", "@@IsTemporary");
            sec = menu.Items.AddSection("Отчеты");
            item = sec.Items.AddActionItem("Норма рабочего времени", "DoRunReport");
            item.Parameters.Add("ReportName", "EmployeesRate");
            item.Parameters.Add("UrlParams", ".Department=" + Guid.Empty + "&.Organization=" + ObjectID);
            item = sec.Items.AddActionItem("Плановая занятость сотрудников", "DoRunReport");
            item.Parameters.Add("ReportName", "Employment");
            item.Parameters.Add("UrlParams", ".Employees=&.Departments=&.Organizations=" + ObjectID);
             */
			return menu;
		}
	}
}
