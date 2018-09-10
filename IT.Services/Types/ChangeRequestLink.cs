//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
// ���������, �������������� ��������� ������ ������ �������� ������ �� ��������
// (�������� ��������� ���� "������� �� ��������" � ����������� �����)
// ��. ����� ���������� ������ CreateEducationRequest ������� CommonService
using System;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// ���������, �������������� ������ ������� ������, ����������� � ��������,
	/// ������� ��������� ��� ������ ������ �������� ������ �� ��������� ������� 
	/// CMDB <seealso cref="CommonService.CreateChangeRequest"/>
	/// </summary>
	[Serializable]
	public class ChangeRequestLink 
	{
		/// <summary>
		/// ������ URL-����� ������� CMDB
		/// </summary>
		public string URL = String.Empty;
		
		/// <summary>
		/// ����������� � ������
		/// </summary>
		public string Description = String.Empty;
	}
}
