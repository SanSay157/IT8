//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2007
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Core;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ���������� �������� GetEmployeesExpenses - ��������� ������ � ��������� 
	/// ��������� ������� ����������� � ������� �� �������� ������ �������.
	/// <see cref="GetEmployeesExpensesRequest"/>
	/// <see cref="GetEmployeesExpensesResponse"/>
	/// </summary>
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetEmployeesExpensesCommand : XCommand 
	{
		/// <summary>
		/// ������������ ����� ��������� "������ �������������� �����������" 
		/// � �������� ��������� � SQL
		/// </summary>
		private const int DEF_EmployeesIDsList_MaxLength = 3500;
		
		/// <summary>
		/// ����� ������� �������� �� ����������, <�������> ����� ��������
		/// �������������, ������ �������������� ����� 
		/// ���������� ����� �������������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public GetEmployeesExpensesResponse Execute( GetEmployeesExpensesRequest request, IXExecutionContext context ) 
		{
			// �������� / ��������� ����������
			if ( null == request.ExceptDepartmentIDsList )
				request.ExceptDepartmentIDsList = String.Empty;

			// ��������� �������� - ������ ����������� EmployeeExpenseInfo; ��� 
			// �����������, ���������� � ���������� �������� (����� �������� �����
			// ���� ��������� - ��. �����), ����� ������������� � ����� "�������":
			ArrayList arrResults = new ArrayList();
			
			// ���������� ������ ������ ����������� �� ������ ��; ������� �������:
			using( XDbCommand cmd = context.Connection.CreateCommand() )
			{
				// ... ������� - ����� �������� ����������. ��������� ��������� 
				// ������ ��������������� � ��� �� ���� - ��� ������; �� �� �����,
				// � ������ SQL, ���������� ����. ������������. ����������� ��������
				// ������ � �������� ���������������, ����� ����� ������� ���������
				// ������������ ���������, ������ (������, ��� 1000 ����������� �� 
				// ������� ������ ������ � 10 �������� ����� ������ ������ - ��� 
				// 10000, ��� ��� ��� ����. ����� �������� ��������� - 4000). 
				//
				// ������� ���� ������ ����������� �� �����, �� ����� �����. ����.
				// ����� �������� ���������. ���������, �.�., ����������� ����������,
				// ���� �� ����� ��������� ���� ������ ���������������. 
				
				cmd.CommandType = CommandType.StoredProcedure;
				cmd.CommandText = "[dbo].[app_GetEmployeesExpenses]";
				
				// ��� ��������� ��������� ��� ��������� ������� �� ����������; 
				// ������� �������� ������ ���� ���:
				cmd.Parameters.Add( "nIdentificationMethod", DbType.Int32, ParameterDirection.Input, false, (int)request.IdentificationMethod );
				cmd.Parameters.Add( "sExceptedDepIDs", DbType.String, ParameterDirection.Input, false, request.ExceptDepartmentIDsList );
				cmd.Parameters.Add( "dtPeriodBeginDate", DbType.Date, ParameterDirection.Input, false, request.PeriodBegin );
				cmd.Parameters.Add( "dtPeriodEndDate", DbType.Date, ParameterDirection.Input, false, request.PeriodEnd );
				// ... ������ ������ - ������������ ��������; ����� �������� ��� 
				// ����, ���� ����� �������� ������� � ���������:
				cmd.Parameters.Add( "sEmployeesIDs", DbType.String, ParameterDirection.Input, false, String.Empty );
				
				// ����� - �������� �� "������" ������; �� ��� ���, ���� �� ����� ��������� ���� ������:
				string sSrcEmpIDsList = request.EmployeesIDsList;
				for( int nCurrPos = 0; nCurrPos < sSrcEmpIDsList.Length; )
				{
					// ��������� "�����" ������:
					string sCurrIDsListPart;
					if ( sSrcEmpIDsList.Length - nCurrPos < DEF_EmployeesIDsList_MaxLength )
					{
						sCurrIDsListPart = ( 0 == nCurrPos ? sSrcEmpIDsList : sSrcEmpIDsList.Substring( nCurrPos ) );
						nCurrPos += sCurrIDsListPart.Length;
					}
					else
					{
						int nNextPartPos = sSrcEmpIDsList.LastIndexOf( ",", nCurrPos + DEF_EmployeesIDsList_MaxLength , DEF_EmployeesIDsList_MaxLength - 1 );
						if (-1 == nNextPartPos) 
							throw new ArgumentException( 
								String.Format(
									"������ ��������������� �������� �������������, ����� �������� ����������� (����� {0})", 
									DEF_EmployeesIDsList_MaxLength ), 
								"[request].EmployeesIDsList" );
						
						sCurrIDsListPart = sSrcEmpIDsList.Substring( nCurrPos, nNextPartPos - nCurrPos );
						nCurrPos = nNextPartPos + 1;
					}
					// ���������� "�����" �������� ��� �������� ���������:
					cmd.Parameters["sEmployeesIDs"].Value = sCurrIDsListPart;
				
					using( IDataReader reader = cmd.ExecuteReader() )
					{
						if ( 0 != reader.FieldCount )
						{
							if ( reader.FieldCount < 4 )
								throw new ApplicationException( "������������ ������ ������� (SQL): ��������������� ���������� ������� � �������������� ������ (" + reader.FieldCount + ")" );
						
							// ��������� ���������� ��������� - ���������, ������ ������ 
							// �������� �������� ������������� ����������, ��������� ����� ���
							// �������� � �������� ��������� �����:
							int nOrd_EmployeeID = reader.GetOrdinal( "EmployeeID" );
							int nOrd_RateExpenses = reader.GetOrdinal( "RateExpenses" );
							int nOrd_RealExpenses = reader.GetOrdinal( "RealExpenses" );
				
							while ( reader.Read() )
							{
								EmployeeExpenseInfo info = new EmployeeExpenseInfo();
								info.EmployeeID = reader.GetString( nOrd_EmployeeID );
								info.RateExpense = reader.GetInt32( nOrd_RateExpenses );
								info.RealExpense = reader.GetInt32( nOrd_RealExpenses );
								arrResults.Add( info );
							}
						}
					}
				}
			}
			
			// �������� ��������� ��������:
			GetEmployeesExpensesResponse response = new GetEmployeesExpensesResponse();
			response.PeriodBegin = request.PeriodBegin;
			response.PeriodEnd = request.PeriodEnd;
			response.Expenses = new EmployeeExpenseInfo[arrResults.Count];
			if (arrResults.Count > 0) 
				arrResults.CopyTo( 0, response.Expenses, 0, arrResults.Count );
			
			return response;	
		}
	}
}