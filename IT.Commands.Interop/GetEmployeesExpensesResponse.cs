//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2007
//******************************************************************************
using System;
using System.Xml.Serialization;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Данные списания одного пользователя системы Incident Tracker за некоторый 
	/// заданный период времени (границы периода задаются вне класса).
	/// </summary>
	[Serializable]
	[XmlType( TypeName = "EI" )]
	public class EmployeeExpenseInfo 
	{
		/// <summary>
		/// Идентификатор пользователя системы Incident Tracker.
		/// Форма(т) значения зависит от метода идентификации пользователя, 
		/// заданного при получении информации о списаниях пользователей.
		/// </summary>
		[XmlAttribute( AttributeName = "id" )]
		public string EmployeeID;
		/// <summary>
		/// "Норма" времени, требуемая к списанию: сумма времени, которую 
		/// пользователь ДОЛЖЕН списать в указанный период. Учитваются рабочие, 
		/// выходные и праздничные дни, дата выхода на работу / дата увольнения. 
		/// Время приводится в минутах.
		/// </summary>
		[XmlAttribute( AttributeName = "rq" )]
		public int RateExpense;
		/// <summary>
		/// Количество времени, реально списанного пользователем в Системе в 
		/// заданный период. Время приводится в минутах.
		/// </summary>
		[XmlAttribute( AttributeName = "rl" )]
		public int RealExpense;
	}
		
	
	/// <summary>
	/// Результат операции получения данных о суммарных списаниях пользователей 
	/// Системы в заданный период времени.
	/// </summary>
	[Serializable]
	public class GetEmployeesExpensesResponse : XResponse 
	{
		/// <summary>
		/// Дата начала отчетного периода, для которого были получены данные 
		/// (из исходного запроса)
		/// </summary>
		public DateTime PeriodBegin;
		/// <summary>
		/// Дата окончания отчетного периода, для которого были получены данные 
		/// (из исходного запроса)
		/// </summary>
		public DateTime PeriodEnd;
		
		/// <summary>
		/// Массив данных списаний
		/// </summary>
		[XmlElement( ElementName = "EI" )]
		public EmployeeExpenseInfo[] Expenses;
	}
}
