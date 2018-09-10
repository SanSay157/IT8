//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2007
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Методы идентификации пользователей Системы, при получении данных 
	/// о списаниях пользователей за период.
	/// </summary>
	[Serializable]
	public enum IdentificationMethod 
	{
		/// <summary>
		/// Идентификация по внутреннему GUID-идентификатору записи пользователя в IT;
		/// </summary>
		ByTrackerEmployeeID = 0,
		/// <summary>
		/// Идентификация по адресу электронной почты;
		/// </summary>
		ByEmail = 1,
		/// <summary>
		/// Идентификация по логину (так, как он задан в записи пользователя в IT);
		/// </summary>
		ByLogin = 2
	}
		
		
	/// <summary>
	/// Запрос операции получения данных о суммарных списаниях пользователей 
	/// Системы в заданный период времени
	/// </summary>
	[Serializable]
	public class GetEmployeesExpensesRequest : XRequest
	{
		/// <summary>
		/// Наименование операции в перечне операций по умолчанию
		/// </summary>
		private static readonly string DEF_COMMAND_NAME = "GetEmployeesExpenses";
		
		/// <summary>
		/// Конструктор по умолчанию, для корректной (де)сериализации
		/// </summary>
		public GetEmployeesExpensesRequest() 
		{
			Name = DEF_COMMAND_NAME;
		}
		
		
		/// <summary>
		/// Метод идентификации сотрудников, для которых получаются данные;
		/// определяет формат идентификаторов, заданных в списке EmployeesIDsList.
		/// </summary>
		public IdentificationMethod IdentificationMethod;
		/// <summary>
		/// Строка со списком идентификаторов сотрудников, для которых получаются
		/// данные о списаниях. Формат идентификаторов определяется в соответствии
		/// с используемым методом идентификации, см. IdentificationMethod.
		/// Идентификаторы в списке перечисляются через запятую. 
		/// Значение параметра обязательно, не может быть пустой строкой.
		/// </summary>
		public string EmployeesIDsList;
		/// <summary>
		/// Строка со списком идентификаторов подразделений (Department.ObjectID),
		/// сотрудники которых не списывают время в Системе. NB: подчиненные 
		/// подразделения должны выключаться в список независимо. Идентификаторы 
		/// в списке перечисляются через запятую.
		/// </summary>
		public string ExceptDepartmentIDsList;
		/// <summary>
		/// Дата начала отчетного периода.
		/// </summary>
		public DateTime PeriodBegin;
		/// <summary>
		/// Дата окончания отчетного периода.
		/// </summary>
		public DateTime PeriodEnd;
		
		/// <summary>
		/// Проверяет корректность заполнения данных запроса
		/// </summary>
		public override void Validate() 
		{
			// Обязательно вызываем базовую реализацию - там проверяются
			// свойства, определяемые базовой же реализацией 
			base.Validate();

			// Список идентификаторов сотрудников должен быть задан:
			ValidateRequiredArgument( EmployeesIDsList, "EmployeesIDsList" );
		}
	}
}
