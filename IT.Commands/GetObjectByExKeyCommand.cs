//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Операция получения данных ds-объекта, заданного значениями своих реквизитов
	/// <seealso cref="GetObjectByExKeyRequest"/>
	/// </summary>
	/// <remarks>
	/// Использует стандартную операцию GetObject (должна быть определена в 
	/// конфигурации приложения), является функциональным аналогом этой стандартной 
	/// операции. В качестве результата возвращает стандартный же результат:
	/// <seealso cref="XGetObjectResponse"/>
	/// ВНИМАНИЕ - при вызове будет так же вызываться guard-объект, назначенный
	/// для операции GetObject!
	/// </remarks>
    [Serializable]
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetObjectByExKeyCommand : GetObjectIdByExKeyCommand
	{
		/// <summary>
		/// Метод запуска операции на выполнение, <входная> точка операции
		/// ПЕРЕГРУЖЕННЫЙ, СТРОГО ТИПИЗИРОВАННЫЙ МЕТОД 
		/// ВЫЗЫВАЕТСЯ ЯДРОМ АВТОМАТИЧЕСКИ
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		public XGetObjectResponse Execute( GetObjectByExKeyRequest request, IXExecutionContext context ) 
		{
			// ПЕРВОЕ: получим идентификатор объекта: воспользуемся логикой,
			// реализованной в базовом классе:
			Guid uidResultObjectID = Guid.Empty;

			// Если в запросе задано наименование источника данных, то для получения 
			// идентификатора объекта используем именно его:
			if (null!=request.DataSourceName && 0!=request.DataSourceName.Length)
				uidResultObjectID = processDataSource(
					request.DataSourceName,
					request.Params,
					context.Connection );
			else 
				// Иначе (наименование источника данных не задано) формируем явный 
				// запрос на получение ObjectID
				uidResultObjectID = processExplicitObjectIdRequest( 
					request.TypeName,
					request.Params,
					context.Connection );
			
			// Если в итоге идентификатор объекта НЕ получили - генерируем 
			// исключение, т.к. в этом случае невозможно загрузить данные объекта
			if (Guid.Empty==uidResultObjectID)
				throw new ArgumentException("Объект, заданный значениями своих свойств, не найден!");

			
			// ВТОРОЕ: вызываем стандартную операцию загрузки данных
			// ВНИМАНИЕ - при вызове будет так же вызываться guard-объект, назначенный
			// для операции GetObject!
			XGetObjectRequest requestGetObject = new XGetObjectRequest( request.TypeName, uidResultObjectID );
			// скопируем служебные атрибуты из исходного запроса
			requestGetObject.SessionID = request.SessionID;
			requestGetObject.Headers.Add( request.Headers );
			
			return (XGetObjectResponse)context.ExecCommand( requestGetObject, true );
		}
	}
}