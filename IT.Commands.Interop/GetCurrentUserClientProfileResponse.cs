//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using System.Xml;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������ ��� ������� GetCurrentUserClientProfile - 
	/// ��������e ������� �������� ������������ ��� Web-�������
	/// </summary>
	[Serializable]
	public class GetCurrentUserClientProfileResponse: XResponse
	{
		/// <summary>
		/// ���������� ����� � ������� ������
		/// </summary>
		public int WorkdayDuration;
		/// <summary>
		/// ������������� �������� ������������ ����������
		/// </summary>
		public Guid SystemUserID;
		/// <summary>
		/// ������������� �������� ����������
		/// </summary>
		public Guid EmployeeID;
	}
}