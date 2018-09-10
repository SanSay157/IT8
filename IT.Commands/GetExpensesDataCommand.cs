//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using Croc.IncidentTracker.Core;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ��������� ������ ������ �������� ������������ �� ��� ������� - ���������� 
	/// �����, ������� ����� � ������� ����. ��� ������� ������� � ���������� 
	/// ������������� (�) ���������� ��������, (�) �������� �������, (�) �������
	/// ����� ���������� � ��������� ���������. 
	/// <seealso cref="GetExpensesDataResponse"/>
	/// </summary>
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetExpensesDataCommand : XCommand
	{
		/// <summary>
		/// ����� ������� �������� �� ����������, <�������> ����� ��������
		/// �������������, ������ �������������� ����� 
		/// ���������� ����� �������������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public new GetExpensesDataResponse Execute( XRequest request, IXExecutionContext context ) 
		{
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			
			Hashtable dictionaryParams = new Hashtable();
			dictionaryParams.Add( "EmployeeID", user.EmployeeID );

			// ������� �������� ������, ��������� ���������� ��������� � �������� ���:
			XDataSource dataSource = context.Connection.GetDataSource( "GetEmployeeCurrentSummaryExpenses" );
			dataSource.SubstituteNamedParams( dictionaryParams, true );
			dataSource.SubstituteOrderBy();

			DataTable resultDataTable = dataSource.ExecuteDataTable();
			// � �������������� ������� ������ ���� ����� �������, ��� ������:
			if ( resultDataTable.Columns.Count != 6 && resultDataTable.Rows.Count != 3 )
				throw new ApplicationException( "������������ ��������� ��������� ������ ������ ����������" ); // TODO: ��������� ����� ���������!
			
			// ��������� ���������:
			GetExpensesDataResponse response = new GetExpensesDataResponse();
			response.EmployeeID = user.EmployeeID;
			for( int nRow=0; nRow<resultDataTable.Rows.Count; nRow++ )
			{
				PeriodExpensesInfo infoExpenses;
				switch ((int)resultDataTable.Rows[nRow]["RowCode"])
				{
					case 1: infoExpenses = response.PreviousMonth; break;
					case 2: infoExpenses = response.CurrentMonth; break;
					case 3: (infoExpenses = response.CurrentDay).IsOneDayPeriod = true; break;
					default:
						throw new ApplicationException("����������� ������!");
				}

				// ���������� ������:
				// ...������� �������:
				infoExpenses.PeriodStartDate = (DateTime)resultDataTable.Rows[nRow]["PeriodStartDate"];
				if (!infoExpenses.IsOneDayPeriod)
					infoExpenses.PerionEndDate = (DateTime)resultDataTable.Rows[nRow]["PeriodEndDate"];
				// ...������ � ����������������� �������� ��� (��� ����������� �������� ���-�� ���� � �������)
				infoExpenses.ExpectedExpense.WorkDayDuration = (int)resultDataTable.Rows[nRow]["WorkDayDuration"];
				infoExpenses.RealExpense.WorkDayDuration = infoExpenses.ExpectedExpense.WorkDayDuration;
				infoExpenses.RemainsExpense.WorkDayDuration = infoExpenses.ExpectedExpense.WorkDayDuration;
				// ...���������� ������ � ��������:
				infoExpenses.ExpectedExpense.Duration = (int)resultDataTable.Rows[nRow]["ExpectedExpense"];
				infoExpenses.RealExpense.Duration = (int)resultDataTable.Rows[nRow]["RealExpense"];
				// ...������� �������� ����� ����� ������ ���� �������� ������� ������ ���������
				// (� ��������� ������� ������� ������� ������ ����):
				if (infoExpenses.ExpectedExpense.Duration > infoExpenses.RealExpense.Duration)
					infoExpenses.RemainsExpense.Duration = infoExpenses.ExpectedExpense.Duration - infoExpenses.RealExpense.Duration;

				// ����������� ��������:
				// ...������������ �������:
				if (infoExpenses.IsOneDayPeriod)
					infoExpenses.PeriodName = "�������";
				else
					infoExpenses.PeriodName = getMonthName(infoExpenses.PeriodStartDate);
				
				// ..."����" �������: ��� ������� ������������������ � ����� 
				// � ����������� �������� ����������� �� �������:
				if (infoExpenses.IsOneDayPeriod)
				{
					// "�������", ���� �������� ������� ������ ��� ����� ���������:
					if (infoExpenses.RealExpense.Duration >= infoExpenses.ExpectedExpense.Duration)
						infoExpenses.Completeness = ExpensesCompleteness.GreenZone;
					// "�����", ���� �������� ������� ������ ��������� ����� ��� �� ��� (60 �����):
					else if (infoExpenses.ExpectedExpense.Duration - infoExpenses.RealExpense.Duration <= 60)
						infoExpenses.Completeness = ExpensesCompleteness.BlueZone;
					// "�������" ���� - �� ���� ��������� �������:
					else
						infoExpenses.Completeness = ExpensesCompleteness.RedZone;
				}
				else
				{
					// "�������", ���� �������� ������� ������ ��� ����� ���������:
					if (infoExpenses.RealExpense.Duration >= infoExpenses.ExpectedExpense.Duration)
						infoExpenses.Completeness = ExpensesCompleteness.GreenZone;
					// "�����", ���� �������� ������� ������ ��������� ����� ��� �� ������� ���� (60 �����):
					else if (infoExpenses.ExpectedExpense.Duration - infoExpenses.RealExpense.Duration <= infoExpenses.RealExpense.WorkDayDuration)
						infoExpenses.Completeness = ExpensesCompleteness.BlueZone;
					// "�������" ���� - �� ���� ��������� �������:
					else
						infoExpenses.Completeness = ExpensesCompleteness.RedZone;
				}
			}
						
			return response;
		}

		/// <summary>
		/// ���������� �������, ��� �������� ���� ���������� ������ � ������������� 
		/// ������ �� ������� �����
		/// </summary>
		/// <param name="dtDate">�������� ����</param>
		/// <returns>������ � ������������� ������</returns>
		private string getMonthName( DateTime dtDate ) 
		{
			string sResultMonthName; 
			switch (dtDate.Month)
			{
				case 1: sResultMonthName = "������"; break;
				case 2: sResultMonthName = "�������"; break;
				case 3: sResultMonthName = "����"; break;
				case 4: sResultMonthName = "������"; break;
				case 5: sResultMonthName = "���"; break;
				case 6: sResultMonthName = "����"; break;
				case 7: sResultMonthName = "����"; break;
				case 8: sResultMonthName = "������"; break;
				case 9: sResultMonthName = "��������"; break;
				case 10: sResultMonthName = "�������"; break;
				case 11: sResultMonthName = "������"; break;
				case 12: sResultMonthName = "�������"; break;
				default:
					throw new ArgumentException( 
						String.Format(
							"������ ��������� ������������ ������: ������������ �������� ���� ({0})", 
							dtDate.ToString()
						), "dtDate" );
			}
			return sResultMonthName;
		}
	}
}