//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2007
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������ ������������� ������������� �������, ��� ��������� ������ 
	/// � ��������� ������������� �� ������.
	/// </summary>
	[Serializable]
	public enum IdentificationMethod 
	{
		/// <summary>
		/// ������������� �� ����������� GUID-�������������� ������ ������������ � IT;
		/// </summary>
		ByTrackerEmployeeID = 0,
		/// <summary>
		/// ������������� �� ������ ����������� �����;
		/// </summary>
		ByEmail = 1,
		/// <summary>
		/// ������������� �� ������ (���, ��� �� ����� � ������ ������������ � IT);
		/// </summary>
		ByLogin = 2
	}
		
		
	/// <summary>
	/// ������ �������� ��������� ������ � ��������� ��������� ������������� 
	/// ������� � �������� ������ �������
	/// </summary>
	[Serializable]
	public class GetEmployeesExpensesRequest : XRequest
	{
		/// <summary>
		/// ������������ �������� � ������� �������� �� ���������
		/// </summary>
		private static readonly string DEF_COMMAND_NAME = "GetEmployeesExpenses";
		
		/// <summary>
		/// ����������� �� ���������, ��� ���������� (��)������������
		/// </summary>
		public GetEmployeesExpensesRequest() 
		{
			Name = DEF_COMMAND_NAME;
		}
		
		
		/// <summary>
		/// ����� ������������� �����������, ��� ������� ���������� ������;
		/// ���������� ������ ���������������, �������� � ������ EmployeesIDsList.
		/// </summary>
		public IdentificationMethod IdentificationMethod;
		/// <summary>
		/// ������ �� ������� ��������������� �����������, ��� ������� ����������
		/// ������ � ���������. ������ ��������������� ������������ � ������������
		/// � ������������ ������� �������������, ��. IdentificationMethod.
		/// �������������� � ������ ������������� ����� �������. 
		/// �������� ��������� �����������, �� ����� ���� ������ �������.
		/// </summary>
		public string EmployeesIDsList;
		/// <summary>
		/// ������ �� ������� ��������������� ������������� (Department.ObjectID),
		/// ���������� ������� �� ��������� ����� � �������. NB: ����������� 
		/// ������������� ������ ����������� � ������ ����������. �������������� 
		/// � ������ ������������� ����� �������.
		/// </summary>
		public string ExceptDepartmentIDsList;
		/// <summary>
		/// ���� ������ ��������� �������.
		/// </summary>
		public DateTime PeriodBegin;
		/// <summary>
		/// ���� ��������� ��������� �������.
		/// </summary>
		public DateTime PeriodEnd;
		
		/// <summary>
		/// ��������� ������������ ���������� ������ �������
		/// </summary>
		public override void Validate() 
		{
			// ����������� �������� ������� ���������� - ��� �����������
			// ��������, ������������ ������� �� ����������� 
			base.Validate();

			// ������ ��������������� ����������� ������ ���� �����:
			ValidateRequiredArgument( EmployeesIDsList, "EmployeesIDsList" );
		}
	}
}
