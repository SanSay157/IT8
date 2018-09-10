//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
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
	/// ������� ���������� ����������� ���� �������
	/// </summary>
	public class TreeDefaultMenuProvider: IXTreeLevelMenuDataProvider
	{
		/// <summary>
		/// ��������� ���� � runtime ��� ������ (treeLevelInfo �����) ��� ������ �������� (treeLevelInfo ����� null)
		/// </summary>
		/// <param name="treeLevelInfo">�������� ������, ��� �������� ������������� ����, ��� null</param>
		/// <param name="request">��������� � �������</param>
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
				item = menu.Items.AddActionItem("�������������", StdActions.DoEdit);
				item.Hotkey = "VK_ENTER";
                item.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_PARENTNODE");
			}

			XNewObjectRights create_rights = XSecurityManager.Instance.GetRightsOnNewObject( dataSet.CreateNew(xobj.ObjectType, true) );
			if (create_rights.AllowCreate)
			{
				item = menu.Items.AddActionItem("�������", StdActions.DoCreate);
				item.Hotkey = "VK_INS";
				item.Parameters.Add("RefreshFlags", "TRM_TREE");
				if (rights.AllowDelete)
					menu.Items.AddSeparatorItem();
			}

			if (rights.AllowDelete)
			{
				item = menu.Items.AddActionItem("�������", StdActions.DoDelete);
				item.Hotkey = "VK_DEL";
				item.Parameters.Add("RefreshFlags", "TRM_TREE");
			}

			return menu;
		}
	}
}
