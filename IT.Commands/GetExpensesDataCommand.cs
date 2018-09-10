//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
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
	/// Выполняет расчет затрат текущего пользователя за три периода - предыдущий 
	/// месяц, текущий месяц и текущий день. Для каждого периода в результате 
	/// расчитывается (А) ожидаемыве затрарты, (Б) реальные затраты, (В) разница
	/// между ожидаемыми и реальными затратами. 
	/// <seealso cref="GetExpensesDataResponse"/>
	/// </summary>
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetExpensesDataCommand : XCommand
	{
		/// <summary>
		/// Метод запуска операции на выполнение, <входная> точка операции
		/// ПЕРЕГРУЖЕННЫЙ, СТРОГО ТИПИЗИРОВАННЫЙ МЕТОД 
		/// ВЫЗЫВАЕТСЯ ЯДРОМ АВТОМАТИЧЕСКИ
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		public new GetExpensesDataResponse Execute( XRequest request, IXExecutionContext context ) 
		{
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			
			Hashtable dictionaryParams = new Hashtable();
			dictionaryParams.Add( "EmployeeID", user.EmployeeID );

			// Получим источник данных, подставим переданные параметры и выполним его:
			XDataSource dataSource = context.Connection.GetDataSource( "GetEmployeeCurrentSummaryExpenses" );
			dataSource.SubstituteNamedParams( dictionaryParams, true );
			dataSource.SubstituteOrderBy();

			DataTable resultDataTable = dataSource.ExecuteDataTable();
			// в результирующей таблице должно быть шесть колонок, три строки:
			if ( resultDataTable.Columns.Count != 6 && resultDataTable.Rows.Count != 3 )
				throw new ApplicationException( "Некорректный результат получения данных затрат сотрудника" ); // TODO: Поправить текст сообщения!
			
			// Формируем результат:
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
						throw new ApplicationException("Неожиданные данные!");
				}

				// Зачитываем данные:
				// ...границы периода:
				infoExpenses.PeriodStartDate = (DateTime)resultDataTable.Rows[nRow]["PeriodStartDate"];
				if (!infoExpenses.IsOneDayPeriod)
					infoExpenses.PerionEndDate = (DateTime)resultDataTable.Rows[nRow]["PeriodEndDate"];
				// ...данные о продолжительности рабочего дня (для корректного рассчета кол-ва дней в периоде)
				infoExpenses.ExpectedExpense.WorkDayDuration = (int)resultDataTable.Rows[nRow]["WorkDayDuration"];
				infoExpenses.RealExpense.WorkDayDuration = infoExpenses.ExpectedExpense.WorkDayDuration;
				infoExpenses.RemainsExpense.WorkDayDuration = infoExpenses.ExpectedExpense.WorkDayDuration;
				// ...собственно данные о затратах:
				infoExpenses.ExpectedExpense.Duration = (int)resultDataTable.Rows[nRow]["ExpectedExpense"];
				infoExpenses.RealExpense.Duration = (int)resultDataTable.Rows[nRow]["RealExpense"];
				// ...остаток списаний имеет смысл только если реальные затраты меньше ожидаемых
				// (в остальных случаях остаток считаем равным нулю):
				if (infoExpenses.ExpectedExpense.Duration > infoExpenses.RealExpense.Duration)
					infoExpenses.RemainsExpense.Duration = infoExpenses.ExpectedExpense.Duration - infoExpenses.RealExpense.Duration;

				// Вычисляемые значения:
				// ...наименование периода:
				if (infoExpenses.IsOneDayPeriod)
					infoExpenses.PeriodName = "Сегодня";
				else
					infoExpenses.PeriodName = getMonthName(infoExpenses.PeriodStartDate);
				
				// ..."цвет" периода: для периода продолжительностью в месяц 
				// и однодневных периодов вычисляется по разному:
				if (infoExpenses.IsOneDayPeriod)
				{
					// "Зеленый", если реальные затраты больше или равны ожидаемым:
					if (infoExpenses.RealExpense.Duration >= infoExpenses.ExpectedExpense.Duration)
						infoExpenses.Completeness = ExpensesCompleteness.GreenZone;
					// "Синий", если реальные затраты меньше ожидаемых менее чем на час (60 минут):
					else if (infoExpenses.ExpectedExpense.Duration - infoExpenses.RealExpense.Duration <= 60)
						infoExpenses.Completeness = ExpensesCompleteness.BlueZone;
					// "Красная" зона - во всех остальных случаях:
					else
						infoExpenses.Completeness = ExpensesCompleteness.RedZone;
				}
				else
				{
					// "Зеленый", если реальные затраты больше или равны ожидаемым:
					if (infoExpenses.RealExpense.Duration >= infoExpenses.ExpectedExpense.Duration)
						infoExpenses.Completeness = ExpensesCompleteness.GreenZone;
					// "Синий", если реальные затраты меньше ожидаемых менее чем на РАБОЧИЙ ДЕНЬ (60 минут):
					else if (infoExpenses.ExpectedExpense.Duration - infoExpenses.RealExpense.Duration <= infoExpenses.RealExpense.WorkDayDuration)
						infoExpenses.Completeness = ExpensesCompleteness.BlueZone;
					// "Красная" зона - во всех остальных случаях:
					else
						infoExpenses.Completeness = ExpensesCompleteness.RedZone;
				}
			}
						
			return response;
		}

		/// <summary>
		/// Внутренняя функция, для заданной даты возвращает строку с наименованием 
		/// месяца на русском языке
		/// </summary>
		/// <param name="dtDate">Исходная дата</param>
		/// <returns>Строка с наименованием месяца</returns>
		private string getMonthName( DateTime dtDate ) 
		{
			string sResultMonthName; 
			switch (dtDate.Month)
			{
				case 1: sResultMonthName = "Январь"; break;
				case 2: sResultMonthName = "Февраль"; break;
				case 3: sResultMonthName = "Март"; break;
				case 4: sResultMonthName = "Апрель"; break;
				case 5: sResultMonthName = "Май"; break;
				case 6: sResultMonthName = "Июнь"; break;
				case 7: sResultMonthName = "Июль"; break;
				case 8: sResultMonthName = "Август"; break;
				case 9: sResultMonthName = "Сентябрь"; break;
				case 10: sResultMonthName = "Октябрь"; break;
				case 11: sResultMonthName = "Ноябрь"; break;
				case 12: sResultMonthName = "Декабрь"; break;
				default:
					throw new ArgumentException( 
						String.Format(
							"Ошибка получения наименования месяца: некорректное значение даты ({0})", 
							dtDate.ToString()
						), "dtDate" );
			}
			return sResultMonthName;
		}
	}
}