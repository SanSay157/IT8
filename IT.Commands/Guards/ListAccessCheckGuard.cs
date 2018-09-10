//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using Croc.IncidentTracker.Core;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.XUtils;

namespace Croc.IncidentTracker.Commands.Guards
{
	/// <summary>
	/// �����, �������������� ������ � ������� �� ��������� �������������� ������� ������ ��������� ���������� ������������
	/// </summary>
	[XRequiredRequestType(typeof(XGetListDataRequest))]
	public class ListAccessCheckGuard: XGuard
	{
		public bool HasRightsToExecute(XGetListDataRequest request, IXExecutionContextGuard context)
		{
            ListInfoWithAccessCheck stdListInfo = XListWithAccessCheckController.Instance.GetListInfo(
				request.MetaName, 
				request.TypeName, 
				context.Connection);
            ListInfoWithAccessCheck listInfo = (ListInfoWithAccessCheck)stdListInfo;
            ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
            if (user.PrivilegeSet.ContainsAll(listInfo.AccessSecurity.RequiredPrivileges))
                return true;
            return false;
            }
	}
}
