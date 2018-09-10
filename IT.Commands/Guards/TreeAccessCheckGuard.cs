//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Hierarchy;
using Croc.IncidentTracker.Trees;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands.Guards
{
	/// <summary>
	/// Гвард, ограничивающий доступ к деревьям на основании декларативного задания списка требуемых привилегий пользователя
	/// </summary>
	[XRequiredRequestType(typeof(XGetTreeDataRequest))]
	public class TreeAccessCheckGuard: XGuard
	{
		public bool HasRightsToExecute(XGetTreeDataRequest request, IXExecutionContextGuard context)
		{
			XTreePageInfo treePage = XTreeController.Instance.GetPageInfo(request.MetaName);
			if (treePage is TreePageWithAccessCheckInfo)
			{
				TreePageWithAccessCheckInfo treePageSec = (TreePageWithAccessCheckInfo)treePage;
				ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
				if (user.PrivilegeSet.ContainsAll(treePageSec .AccessSecurity.RequiredPrivileges))
					return true;
				return false;
			}
			return true;
		}
	}

}
