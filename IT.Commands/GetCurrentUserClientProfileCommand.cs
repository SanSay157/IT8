//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System.Xml;
using Croc.IncidentTracker.Core;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;
using System;
namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������� ��������� ������� �������� ������������ ��� Web-�������
	/// </summary>
    [Serializable]
	public class GetCurrentUserClientProfileCommand: XCommand
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

			GetCurrentUserClientProfileResponse response = new GetCurrentUserClientProfileResponse();
			/*
			 * ���������������, �.�. ������ ��� ������������� � ��������� xml-������� �������� ����������, ���� �����������, �� ����������������
			XmlElement xmlCurrentEmployee = context.Connection.Load( "Employee", user.EmployeeID );
			context.Connection.LoadProperty( xmlCurrentEmployee, "SystemUser" );
			response.XmlEmployee = xmlCurrentEmployee;
			*/

			response.EmployeeID = user.EmployeeID;
			response.SystemUserID = user.SystemUserID;
			response.WorkdayDuration = user.WorkdayDuration;
			return response;
		}
	}
}