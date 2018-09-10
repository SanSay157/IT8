//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2007
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	
	/// <summary>
	/// Запрос операции получения данных о суммарных списаниях пользователей 
	/// Системы в заданный период времени
	/// </summary>
	[Serializable]
	public class FactorizeProjectOutcomeRequest : XRequest
	{
		/// <summary>
		/// Наименование операции в перечне операций по умолчанию
		/// </summary>
		private static readonly string DEF_COMMAND_NAME = "FactorizeProjectOutcome";
		
		/// <summary>
		/// Конструктор по умолчанию, для корректной (де)сериализации
		/// </summary>
		public FactorizeProjectOutcomeRequest() 
		{
			Name = DEF_COMMAND_NAME;
		}

        /// <summary>
        /// Идентификатор приходного договора
        /// </summary>
        public Guid ContractID;

        /// <summary>
        /// Проверяет корректность заполнения данных запроса
        /// </summary>
        public override void Validate() 
		{
			// Обязательно вызываем базовую реализацию - там проверяются
			// свойства, определяемые базовой же реализацией 
			base.Validate();

			// Список идентификаторов сотрудников должен быть задан:
			ValidateRequiredArgument(ContractID, "ContractID");
		}
	}
}
