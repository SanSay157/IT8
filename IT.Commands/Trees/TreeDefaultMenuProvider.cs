//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
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
	/// Команда построения дефолтового меню иерахии
	/// </summary>
	public class TreeDefaultMenuProvider: IXTreeLevelMenuDataProvider
	{
		/// <summary>
		/// Получение меню в runtime для уровня (treeLevelInfo задан) или пустой иерархии (treeLevelInfo равен null)
		/// </summary>
		/// <param name="treeLevelInfo">описание уровня, для которого запрашивается меню, или null</param>
		/// <param name="request">параметры с клиента</param>
		/// <returns></returns>
		public XTreeMenuInfo GetMenu(XTreeLevelInfoIT treeLevelInfo, XGetTreeMenuRequest request, IXExecutionContext context)
		{
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			DomainObjectData xobj = dataSet.GetLoadedStub(request.Path.PathNodes[0].ObjectType, request.Path.PathNodes[0].ObjectID);

			XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;
			XMenuActionItem item;

			XObjectRights rights = XSecurityManager.Instance.GetObjectRights(xobj);
			if (rights.AllowParticalOrFullChange)
			{
				item = menu.Items.AddActionItem("Редактировать", StdActions.DoEdit);
				item.Hotkey = "VK_ENTER";
                item.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_PARENTNODE");
			}

			XNewObjectRights create_rights = XSecurityManager.Instance.GetRightsOnNewObject( dataSet.CreateNew(xobj.ObjectType, true) );
			if (create_rights.AllowCreate)
			{
				item = menu.Items.AddActionItem("Создать", StdActions.DoCreate);
				item.Hotkey = "VK_INS";
				item.Parameters.Add("RefreshFlags", "TRM_TREE");
				if (rights.AllowDelete)
					menu.Items.AddSeparatorItem();
			}

			if (rights.AllowDelete)
			{
				item = menu.Items.AddActionItem("Удалить", StdActions.DoDelete);
				item.Hotkey = "VK_DEL";
				item.Parameters.Add("RefreshFlags", "TRM_TREE");
			}

			return menu;
		}
	}
}
