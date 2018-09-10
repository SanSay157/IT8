using System;
using Croc.IncidentTracker.Hierarchy;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда получения меню иерархии и меню узлов иерархии
	/// </summary>
	public class GetTreeMenuEntryCommand : XCommand
	{
		public XResponse Execute(XGetTreeMenuRequest request, IXExecutionContext context)
		{
			XTreePageInfo treePage = XTreeController.Instance.GetPageInfo(request.MetaName);

			XTreeMenuInfo treemenu;	 
			if (request.IsMenuForEmptyTree)
				treemenu = treePage.GetMenuForEmptyTree(request, context);
			else
			{
				treemenu = treePage.GetMenu(request, context);
			}
			if (treemenu != null)
				return new XGetMenuResponse(treemenu.ToXml());
			else
				return new XGetMenuResponse(null);
		}
	}
}
