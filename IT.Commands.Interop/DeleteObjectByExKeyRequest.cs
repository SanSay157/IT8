//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands 
{
	/// <summary>
	/// Запрос операции удаления данных ds-объекта, заданного значениями 
	/// своих реквизитов
	/// </summary>
	[Serializable]
	public class DeleteObjectByExKeyRequest : GetObjectIdByExKeyRequest 
	{
		/// <summary>
		/// Наименование операции в перечне операций по умолчанию
		/// </summary>
		private static readonly string DEF_COMMAND_NAME = "DeleteObjectByExKey";

		/// <summary>
		/// Логический флаг, управляющий интерпретацией отсутствия объекта.
		/// </summary>
		/// <remarks>
		/// Определяет реакцию операции в том случае, если объект, заданный как 
		/// удаляемый, не найден:
		///		-- если значение false - операция генерирует исключение;
		///		-- если значение true - операция успешно завершается, но в 
		///		результате выполнения в кол-ве удаленных объектов указывается 
		///		ноль (см. <see cref="XDeleteObjectResponse"/>)
		/// </remarks>
		public bool TreatNotExistsObjectAsDeleted = false;
			
		/// <summary>
		/// Конструктор по умолчанию, для корректной (де)сериализации
		/// </summary>
		public DeleteObjectByExKeyRequest() 
		{
			Name = DEF_COMMAND_NAME;
		}

		
		/// <summary>
		/// Параметризированный конструктор
		/// </summary>
		/// <param name="sTypeName">Наименование ds-типа</param>
		/// <param name="paramsCollection">
		/// Коллекция параметров, задающих значения свойств, по которым 
		/// определяется удаляемый экземпляр ds-объекта
		/// </param>
		public DeleteObjectByExKeyRequest( string sTypeName, XParamsCollection paramsCollection ) 
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
			base.Validate();

			// В отличие от запроса типа GetObjectIdByExKeyRequest, здесь
			// наименование ds-типа должно быть задано ВСЕГДА. При этом допустимо
			// задание наименование источника данных наряду с указанием ds-типа -
			// тогда именно источник будет использоваться для определения 
			// идентификатора удаляемого объекта
			ValidateRequiredArgument( TypeName, "TypeName" );
		}
	}
}