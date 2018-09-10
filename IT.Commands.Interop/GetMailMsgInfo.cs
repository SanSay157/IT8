//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	[Serializable]
	public class GetMailMsgInfoRequest: XRequest
	{
		/// <summary>
		/// ������������� ������� (���������/�����)
		/// </summary>
		public Guid ObjectID;
		/// <summary>
		/// ������������ ���� �������
		/// </summary>
		public string ObjectType;
		/// <summary>
		/// ������ ��������������� �����������, ������� ����� ���������� ������
		/// </summary>
		public Guid[] EmployeeIDs;
	}

	[Serializable]
	public class GetMailMsgInfoResponse: XResponse
	{
		/// <summary>
		/// ������ email'�� ����������� �� ������� EmployeeIDs �������
		/// </summary>
		public string To;
		/// <summary>
		/// ���� ������
		/// </summary>
		public string Subject;
		/// <summary>
		/// ������ ���� �����
		/// </summary>
		public string FolderPath;
		/// <summary>
		/// ������ URL'�� �������� ��� ������
		/// </summary>
		public string ProjectLinks;
		/// <summary>
		/// ������ URL'�� �������� ��� ���������� (����� ���� �� �����, ���� ObjectType ������� ����� "Folder")
		/// </summary>
		public string IncidentLinks;
	}

}
