//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2007
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
	/// Реализация операции GetEmployeesExpenses - получение данных о суммарных 
	/// списаниях перечня сотрудников в Системе за заданный период времени.
	/// <see cref="GetEmployeesExpensesRequest"/>
	/// <see cref="GetEmployeesExpensesResponse"/>
	/// </summary>
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetEmployeesExpensesCommand : XCommand 
	{
		/// <summary>
		/// Максимальная длина параметра "список идентифкаторов сотрудников" 
		/// в хранимой процедуре в SQL
		/// </summary>
		private const int DEF_EmployeesIDsList_MaxLength = 3500;
		
		/// <summary>
		/// Метод запуска операции на выполнение, <входная> точка операции
		/// ПЕРЕГРУЖЕННЫЙ, СТРОГО ТИПИЗИРОВАННЫЙ МЕТОД 
		/// ВЫЗЫВАЕТСЯ ЯДРОМ АВТОМАТИЧЕСКИ
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		public GetEmployeesExpensesResponse Execute( GetEmployeesExpensesRequest request, IXExecutionContext context ) 
		{
			// Проверка / коррекция параметров
			if ( null == request.ExceptDepartmentIDsList )
				request.ExceptDepartmentIDsList = String.Empty;

			// Результат операции - массив экземпляров EmployeeExpenseInfo; все 
			// экземплряры, полученные в результате расчетов (таких итераций может
			// быть несколько - см. далее), будут накапливаться в общем "массиве":
			ArrayList arrResults = new ArrayList();
			
			// Собственно расчет данных выполняется на уровне БД; создаем команду:
			using( XDbCommand cmd = context.Connection.CreateCommand() )
			{
				// ... команда - вызов хранимой процедцуры. Процедура принимает 
				// список идентификаторов в том же виде - как строку; но ее длина,
				// в случае SQL, ограничена макс. размерностью. Вероятность передачи
				// строки с перечнем идентификаторов, общая длина которой превышает
				// размероность параметра, велика (скажем, для 1000 сотрудников со 
				// средней длиной логина в 10 символов длина строки списка - уже 
				// 10000, при том что макс. длина значения параметра - 4000). 
				//
				// Поэтому весь список разбивается на части, по длине соотв. макс.
				// длине значения параметра. Процедура, т.о., выполняется итеративно,
				// пока не будет обработан весь список идентификаторов. 
				
				cmd.CommandType = CommandType.StoredProcedure;
				cmd.CommandText = "[dbo].[app_GetEmployeesExpenses]";
				
				// Все остальные параметры при повторных вызовах не изменяются; 
				// поэтому задаются только один раз:
				cmd.Parameters.Add( "nIdentificationMethod", DbType.Int32, ParameterDirection.Input, false, (int)request.IdentificationMethod );
				cmd.Parameters.Add( "sExceptedDepIDs", DbType.String, ParameterDirection.Input, false, request.ExceptDepartmentIDsList );
				cmd.Parameters.Add( "dtPeriodBeginDate", DbType.Date, ParameterDirection.Input, false, request.PeriodBegin );
				cmd.Parameters.Add( "dtPeriodEndDate", DbType.Date, ParameterDirection.Input, false, request.PeriodEnd );
				// ... пустая строка - недопустимый параметр; здесь задается для 
				// того, чтоб сразу добавить параетр в коллекцию:
				cmd.Parameters.Add( "sEmployeesIDs", DbType.String, ParameterDirection.Input, false, String.Empty );
				
				// Далее - итерации по "частям" списка; до тех пор, пока не будет обработан весь список:
				string sSrcEmpIDsList = request.EmployeesIDsList;
				for( int nCurrPos = 0; nCurrPos < sSrcEmpIDsList.Length; )
				{
					// Выделение "части" списка:
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
									"Список идентификаторов включает идентификатор, длина которого недопустима (более {0})", 
									DEF_EmployeesIDsList_MaxLength ), 
								"[request].EmployeesIDsList" );
						
						sCurrIDsListPart = sSrcEmpIDsList.Substring( nCurrPos, nNextPartPos - nCurrPos );
						nCurrPos = nNextPartPos + 1;
					}
					// Выделенная "часть" задается как значение параметра:
					cmd.Parameters["sEmployeesIDs"].Value = sCurrIDsListPart;
				
					using( IDataReader reader = cmd.ExecuteReader() )
					{
						if ( 0 != reader.FieldCount )
						{
							if ( reader.FieldCount < 4 )
								throw new ApplicationException( "Некорректные данные расчета (SQL): недостататочное количество колонок в результирующем наборе (" + reader.FieldCount + ")" );
						
							// Результат выполнения процедуры - рекордсет, каждая строка 
							// которого содержит идентификатор сотрудника, требуемое время для
							// списания и реальное списанное время:
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
			
			// Итоговый результат операции:
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