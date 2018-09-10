//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2007
//******************************************************************************
using System;
using System.Xml.Serialization;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������ �������� ������ ������������ ������� Incident Tracker �� ��������� 
	/// �������� ������ ������� (������� ������� �������� ��� ������).
	/// </summary>
	[Serializable]
	[XmlType( TypeName = "EI" )]
	public class EmployeeExpenseInfo 
	{
		/// <summary>
		/// ������������� ������������ ������� Incident Tracker.
		/// �����(�) �������� ������� �� ������ ������������� ������������, 
		/// ��������� ��� ��������� ���������� � ��������� �������������.
		/// </summary>
		[XmlAttribute( AttributeName = "id" )]
		public string EmployeeID;
		/// <summary>
		/// "�����" �������, ��������� � ��������: ����� �������, ������� 
		/// ������������ ������ ������� � ��������� ������. ���������� �������, 
		/// �������� � ����������� ���, ���� ������ �� ������ / ���� ����������. 
		/// ����� ���������� � �������.
		/// </summary>
		[XmlAttribute( AttributeName = "rq" )]
		public int RateExpense;
		/// <summary>
		/// ���������� �������, ������� ���������� ������������� � ������� � 
		/// �������� ������. ����� ���������� � �������.
		/// </summary>
		[XmlAttribute( AttributeName = "rl" )]
		public int RealExpense;
	}
		
	
	/// <summary>
	/// ��������� �������� ��������� ������ � ��������� ��������� ������������� 
	/// ������� � �������� ������ �������.
	/// </summary>
	[Serializable]
	public class GetEmployeesExpensesResponse : XResponse 
	{
		/// <summary>
		/// ���� ������ ��������� �������, ��� �������� ���� �������� ������ 
		/// (�� ��������� �������)
		/// </summary>
		public DateTime PeriodBegin;
		/// <summary>
		/// ���� ��������� ��������� �������, ��� �������� ���� �������� ������ 
		/// (�� ��������� �������)
		/// </summary>
		public DateTime PeriodEnd;
		
		/// <summary>
		/// ������ ������ ��������
		/// </summary>
		[XmlElement( ElementName = "EI" )]
		public EmployeeExpenseInfo[] Expenses;
	}
}
