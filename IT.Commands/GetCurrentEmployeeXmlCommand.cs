//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System.Xml;
using Croc.IncidentTracker.Core;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������� ��������� �������� ������������
	/// </summary>
	public class GetCurrentEmployeeXmlCommand: XCommand
	{
		/// <summary>
		/// ����� ������� �������� �� ����������, <�������> ����� ��������
		/// �������������, ������ �������������� ����� 
		/// ���������� ����� �������������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public override XResponse Execute(XRequest request, IXExecutionContext context)
		{
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			XmlElement xmlCurrentEmployee = context.Connection.Load( "Employee", user.EmployeeID );
			context.Connection.LoadProperty( xmlCurrentEmployee, "SystemUser" );
			return new XGetObjectResponse( xmlCurrentEmployee ) ;
		}
	}
}