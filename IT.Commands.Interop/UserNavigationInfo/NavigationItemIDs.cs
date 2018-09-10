//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������������ ��������������� ��������� ������������� ��������� ������
	/// Incident Tracker � ������� ����� ��������
	/// </summary>
	[Serializable]
	public class NavigationItemIDs 
	{
		/// <summary>
		/// "��������" �������� ������� Incident Tracker 
		/// </summary>
		public const string IT_HomePage = "toolBtn-Home";

		/// <summary>
		/// �������� "������� � �������" (���)
		/// </summary>
		public const string IT_CustomerActivityTree = "toolBtn-ActivityTree";

		/// <summary>
		/// ������ �������� (c �������)
		/// </summary>
		public const string IT_ActivityList = "toolBtn-ActivityList";

		/// <summary>
		/// ������ "��� ���������" (������� ������)
		/// </summary>
		public const string IT_CurrentTasks = "toolBtn-CurrentTasks";
		
		/// <summary>
		/// ������ ���������� (����� ����������)
		/// </summary>
		public const string IT_IncidentList = "toolBtn-IncidentList";
		
		/// <summary>
		/// ������ "�������� �������"
		/// </summary>
		public const string IT_TimeLossSearchingList = "toolBtn-TimeLossSearchingList";
		
		/// <summary>
		/// �������� "������" (���� ������ ���� �������, �������������� � ��������)
		/// </summary>
		public const string IT_Reports = "toolBtn-Reports";
		
		/// <summary>
		/// �������� ��������������� ��������� (�����������, �������������, ����������)
		/// </summary>
		public const string IT_OrgStructure = "toolBtn-OrgStructure";
		
		/// <summary>
		/// ����� ����������� ������ ��������� ���������
		/// </summary>
		public const string IT_FindIncident = "toolBtn-FindIncident";

		/// <summary>
		/// "��������" �������� ������� ����� �������� (���)
		/// </summary>
		public const string TMS_HomePage = "toolBtn-TMS";
		
		/// <summary>
		/// ������ �������� (���)
		/// </summary>
		public const string TMS_TenderList = "toolBtn-TMS-TenderList";

		/// <summary>
		/// �������� ���������������� ����������� (��� ������� ������� � ��.)
		/// </summary>
		public const string IT_Administation = "toolBtn-Administration";
	}
}

