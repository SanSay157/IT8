using System;
using System.Text;
using Croc.IncidentTracker.Commands.Trees;
using Croc.IncidentTracker.Hierarchy;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using XTreeLevelInfoIT = Croc.IncidentTracker.Hierarchy.XTreeLevelInfoIT;

namespace Croc.IncidentTracker.Trees
{
	/// <summary>
	/// 
	/// </summary>
	public class IncidentWorkflowManagerMenuDataProvider: XTreeMenuDataProviderStd
	{
		public override XTreeMenuInfo GetMenu(XGetTreeMenuRequest request, IXExecutionContext context, XTreePageInfoStd treePage)
		{
			XTreeStructInfo treeStructInfo = treePage.TreeStruct;
			XTreeLevelInfoIT levelinfo = treeStructInfo.Executor.GetTreeLevel(treeStructInfo, request.Params, request.Path);

			XTreeMenuInfo treemenu = null;
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			Guid ObjectID = request.Path[0].ObjectID;
			switch(levelinfo.ObjectType)
			{
				case "IncidentCategory":
					treemenu = getMenuForIncidentCategory(ObjectID, dataSet, context);
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
            DomainObjectData xobj = dataSet.CreateNew("IncidentType", true);
            XNewObjectRights create_right = XSecurityManager.Instance.GetRightsOnNewObject(xobj);
            if (create_right.AllowCreate)
            {
                XMenuActionItem item = menu.Items.AddActionItem("Создать тип инцидента", StdActions.DoCreate);
                item.Parameters.Add("ObjectType", "IncidentType");
            }
            return menu;
        }
		private XTreeMenuInfo getMenuForIncidentCategory(Guid objectID, DomainObjectDataSet dataSet, IXExecutionContext context)
		{
			// загрузим текущую категорию
			DomainObjectData xobj = dataSet.Load(context.Connection, "IncidentCategory", objectID);
			DomainObjectData xobjNew;
			XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;
			menu.ExecutionHandlers.Add(new XUserCodeWeb("IncidentCategoryMenu_ExecutionHandler"));
			XMenuActionItem item;
			Guid incidentTypeID = (Guid)xobj.GetLoadedPropValue("IncidentType");

			// Создать (на том же уровне, в том же типе инцидента)
			xobjNew = dataSet.CreateStubNew(xobj.ObjectType);
			xobjNew.SetUpdatedPropValue("IncidentType", incidentTypeID);
			xobjNew.SetUpdatedPropValue("Parent", xobj.GetLoadedPropValue("Parent"));
			XNewObjectRights create_rights = XSecurityManager.Instance.GetRightsOnNewObject( xobjNew );
			if (create_rights.AllowCreate)
			{
				item = menu.Items.AddActionItem("Создать", StdActions.DoCreate);
				item.Hotkey = "VK_INS";
				item.Parameters.Add("RefreshFlags", "TRM_PARENT");
				StringBuilder bld = new StringBuilder(".IncidentType=");
				bld.Append(incidentTypeID);
				if (xobj.GetLoadedPropValue("Parent") is Guid)
				{
					bld.Append("&.Parent=");
					bld.Append((Guid)xobj.GetLoadedPropValue("Parent"));
				}
				item.Parameters.Add("UrlParams", bld.ToString());
			}

			// Создать подчиненную (в том же типе инцидента)
			xobjNew = dataSet.CreateStubNew(xobj.ObjectType);
			xobjNew.SetUpdatedPropValue("IncidentType", incidentTypeID);
			xobjNew.SetUpdatedPropValue("Parent", xobj.ObjectID);
			create_rights = XSecurityManager.Instance.GetRightsOnNewObject( xobjNew );
			if (create_rights.AllowCreate)
			{
				item = menu.Items.AddActionItem("Создать подчиненную", StdActions.DoCreate);
				item.Hotkey = "VK_INS";
				item.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_CHILDS");
				item.Parameters.Add("UrlParams", ".IncidentType=" + incidentTypeID.ToString() + "&.Parent=" + xobj.ObjectID);
			}

			XObjectRights rights = XSecurityManager.Instance.GetObjectRights(xobj);
			// Редактировать
			if (rights.AllowParticalOrFullChange)
			{
				item = menu.Items.AddActionItem("Редактировать", StdActions.DoEdit);
				item.Hotkey = "VK_ENTER";
				item.Parameters.Add("RefreshFlags", "TRM_NODE");
				item.Default = true;
			}

			// Удалить
			if (rights.AllowDelete)
			{
				item = menu.Items.AddActionItem("Удалить", StdActions.DoDelete);
				item.Hotkey = "VK_DEL";
				item.Parameters.Add("RefreshFlags", "TRM_TREE");
			}

			// Для некорневых - "Сделать корневой"
			if (xobj.GetLoadedPropValue("Parent") is Guid)
			{
				item = menu.Items.AddActionItem("Сделать корневой", "DoMakeRoot");
				item.Parameters.Add("RefreshFlags", "TRM_TREE");
			}

			// Перенести
			if (rights.HasPropChangeRight("Parent"))
			{
				item = menu.Items.AddActionItem("Перенести", "DoMoveCategory");
			}
			return menu;
		}
	}
}
