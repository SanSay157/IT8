using System;
using Croc.IncidentTracker.Core;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Общая команда для подстановки параметра - идентификатора текущего сотрудника
	/// </summary>
    [Serializable]
	public class GetDataCommonCommand: XCommand
	{
		public XResponse Execute(XRequest request, IXExecutionContext context)
		{
			if (request is XGetTreeDataRequest)
			{
				request.Name = "XGetTreeData";
				((XGetTreeDataRequest)request).Params.Add("CurrentEmployeeID", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).EmployeeID);
				((XGetTreeDataRequest)request).Params.Add("CurrentSystemUserID", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).SystemUserID);
			}
			else if (request is XGetTreeMenuRequest)
			{
				request.Name = "XGetTreeMenu";
				((XGetTreeMenuRequest)request).Params.Add("CurrentEmployeeID", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).EmployeeID);
				((XGetTreeMenuRequest)request).Params.Add("CurrentSystemUserID", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).SystemUserID);
			}
			else if (request is XGetListDataRequest)
			{
				request.Name = "XGetListData";
				((XGetListDataRequest)request).Params.Add("CurrentEmployeeID", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).EmployeeID);
				((XGetListDataRequest)request).Params.Add("CurrentSystemUserID", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).SystemUserID);
			}
			else if (request is XExecuteDataSourceRequest)
			{
				request.Name = "XExecuteDataSource";
				((XExecuteDataSourceRequest)request).Params.Add("CurrentEmployeeID", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).EmployeeID);
				((XExecuteDataSourceRequest)request).Params.Add("CurrentSystemUserID", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).SystemUserID);
			}
			return context.ExecCommand(request, true);
		}
	}
}
