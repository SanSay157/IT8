//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Commands;
namespace Croc.IncidentTracker.Commands 
{
	/// <summary>
	/// Запрос операции получения данных ds-объекта, заданного значениями 
	/// своих реквизитов
	/// </summary>
	[Serializable]
	public class GetObjectByExKeyRequest : GetObjectIdByExKeyRequest
	{
		/// <summary>
		/// Наименование операции в перечне операций по умолчанию
		/// </summary>
		private static readonly string DEF_COMMAND_NAME = "GetObjectByExKey";
			
		/// <summary>
		/// Конструктор по умолчанию, для корректной (де)сериализации
		/// </summary>
		public GetObjectByExKeyRequest() 
		{
			Name = DEF_COMMAND_NAME;
		}

		
		/// <summary>
		/// Параметризированный конструктор
		/// </summary>
		/// <param name="sTypeName">Наименование ds-типа</param>
		/// <param name="paramsCollection">
		/// Коллекция параметров, задающих значения свойств, по которым 
		/// определяется загружаемый экземпляр ds-объекта
		/// </param>
		public GetObjectByExKeyRequest( string sTypeName, XParamsCollection paramsCollection ) 
		{
			Name = DEF_COMMAND_NAME;
			TypeName = sTypeName;
			Params = paramsCollection;
		}

		
		/// <summary>
		/// Проверяет корректность заполнения данных запроса
		/// </summary>
		public override void Validate() 
		{
			// Обязательно вызываем базовую реализацию - там проверяются
			// свойства, определяемые базовой же реализацией 
            XRequest.ValidateOptionalArgument(SessionID, "SessionID");

			// В отличие от запроса типа GetObjectIdByExKeyRequest, здесь
			// наименование ds-типа должно быть задано ВСЕГДА. При этом допустимо
			// задание наименование источника данных наряду с указанием ds-типа -
			// тогда именно источник будет использоваться для определения 
			// идентификатора
			ValidateRequiredArgument( TypeName, "TypeName" );
		}
	}
}