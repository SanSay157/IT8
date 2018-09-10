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
	/// Операция удаления данных ds-объекта, заданного значениями своих реквизитов
	/// <seealso cref="DeleteObjectByExKeyRequest"/>
	/// </summary>
	/// <remarks>
	/// Использует стандартную операцию DeleteObject (должна быть определена в 
	/// конфигурации приложения), является функциональным аналогом этой стандартной 
	/// операции. В качестве результата возвращает стандартный же результат:
	/// <seealso cref="XDeleteObjectResponse"/>
	/// ВНИМАНИЕ!
	///		(1) При вызове будет так же вызываться guard-объект, назначенный
	///			для операции DeleteObject!
	///		(2) Операция требует начала новой транзакции (см. параметры атрибута
	///			XTransaction); при этом стандартная операция DeleteObject будет 
	///			вызвана в той же транзакции
	/// </remarks>
	[XTransaction(XTransactionRequirement.Required)]
    [Serializable]
	public class DeleteObjectByExKeyCommand : GetObjectIdByExKeyCommand
	{
		/// <summary>
		/// Метод запуска операции на выполнение, <входная> точка операции
		/// ПЕРЕГРУЖЕННЫЙ, СТРОГО ТИПИЗИРОВАННЫЙ МЕТОД 
		/// ВЫЗЫВАЕТСЯ ЯДРОМ АВТОМАТИЧЕСКИ
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		public XDeleteObjectResponse Execute( DeleteObjectByExKeyRequest request, IXExecutionContext context ) 
		{
			// ПЕРВОЕ: получим идентификатор удаляемого объекта: воспользуемся 
			// логикой, реализованной в базовом классе:
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
			
			// Проверяем, получили ли в итоге идентификатор объекта (объект уже 
			// удален или это просто некорректная идентификация через свойства):
			if (Guid.Empty==uidResultObjectID)
			{
				// Реакция операции зависит от управляющего флага в запросе:
				// если считается, что отсутствующий объект - это удаленный 
				// объект, то возвращаем честный результат, но с нулем в кач-ве
				// кол-ва реально удаленных объектов; иначе (когда так не считаем)
				// генерируем исключение:
				if (request.TreatNotExistsObjectAsDeleted)
					return new XDeleteObjectResponse( 0 );
				else
					throw new ArgumentException("Объект, заданный значениями своих свойств, не найден!");
			}

			// ВТОРОЕ: вызываем стандартную операцию удаления данных ds-объекта
			// ВНИМАНИЕ - при вызове будет так же вызываться guard-объект, назначенный
			// для операции DeleteObject!
			XDeleteObjectRequest requestDeleteObject = new XDeleteObjectRequest( request.TypeName, uidResultObjectID );
			// скопируем служебные атрибуты из исходного запроса
			requestDeleteObject.SessionID = request.SessionID;
			requestDeleteObject.Headers.Add( request.Headers );
			
			return (XDeleteObjectResponse)context.ExecCommand( requestDeleteObject, true );
		}
	}
}