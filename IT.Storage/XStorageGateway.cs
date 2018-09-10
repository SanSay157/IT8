//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Storage
{
	/// <summary>
	/// Шлюз подсистемы хранения (XStorage)
	/// </summary>
	/// <remarks>
	/// Выполяется сохранение и удаление объектов, "обвязанные" сервисами: 
	/// вызов application-триггеров, очистка кэша данных объектов (DomainObjectRegistry), 
	/// уведомление подсистемы безопасности (XSecurityManager) об измененных/удаленных объектов.
	/// Для сохранения поддерживается механизм "кусочного" сохранения.
	/// Для справки: в стандартном XFW.NET 1.* оно реализовано в соманде XSaveObjectCommand, 
	/// другие упомянутые выше сервисы в XFW.NET 1.* отсутствуют
	/// </remarks>
	public class XStorageGateway
	{
		/// <summary>
		/// Сохранение данных множества объектов.
		/// </summary>
		/// <remarks>
		/// Управление транзакцией внешнее.
		/// </remarks>
		/// <param name="context"></param>
		/// <param name="dataSet"></param>
		/// <param name="transactionID"></param>
		public static void Save(IXExecutionContext context, DomainObjectDataSet dataSet, Guid transactionID)
		{
			// #1: Вызов триггеров Before
			XTriggersController.Instance.FireTriggers(dataSet, XTriggerFireTimes.Before, context);

			// #2: Сбросим закэшированные данные объектов
			IEnumerator enumerator = dataSet.GetModifiedObjectsEnumerator(false);
			while (enumerator.MoveNext())
			{
				DomainObjectData xobj = (DomainObjectData)enumerator.Current;
				// Примечание: для новых объектов сбрасывать кэш бессмысленно - их там нет
				if (!xobj.IsNew)
					DomainObjectRegistry.ResetObject(xobj);
			}

			// #3: Запись данных
			XDatagramProcessorEx dg_proc = XDatagramProcessorMsSqlEx.Instance;
			XDatagramBuilder dgBuilder = dg_proc.GetDatagramBuilder();
			XDatagram dg = dgBuilder.GetDatagram(dataSet);
			dg_proc.Save(context.Connection, dg);

			// #4: Сохранение chunked-данных
			saveChunkedData(transactionID, dg, context.Connection);

			// #5: Сигнализируем Securitymanager, что обновились данные (для очистки кэшей)
			XSecurityManager.Instance.TrackModifiedObjects(dataSet);

			// #6: Вызов триггеров After
			XTriggersController.Instance.FireTriggers(dataSet, XTriggerFireTimes.After, context);
		}

		/// <summary>
		/// Сохраняет chunked-данные всех объектов из датаграммы
		/// </summary>
		/// <param name="transactionID">Идентификатор транзакции</param>
		/// <param name="datagram">датаграмма</param>
		/// <param name="con">соединение</param>
		protected static void saveChunkedData(Guid transactionID, XDatagram datagram, XStorageConnection con)
		{
			bool bChunkedDataFound = false;

			foreach( XStorageObjectToSave xobj in datagram.ObjectsToInsert  )
				bChunkedDataFound = saveObjectChunkedData(xobj, con);
			
			foreach(XStorageObjectToSave xobj in datagram.ObjectsToUpdate)
				bChunkedDataFound = bChunkedDataFound || saveObjectChunkedData(xobj, con);
			
			// Если в процессе какие-либо "кусочные" данные были перегружены 
			// в положенные таблицы - удаляем такие "куски":
			if (bChunkedDataFound)
				XChunkStorageGateway.RemoveTransactionData( transactionID, con);
		}

		/// <summary>
		/// Сохраняет chunked-данные заданного объекта
		/// </summary>
		/// <param name="xobj">объект</param>
		/// <param name="con">соединение с БД</param>
		/// <returns>true - объект содержал chunked данные, иначе false</returns>
		protected static bool saveObjectChunkedData(XStorageObjectToSave xobj, XStorageConnection con)
		{
			string sPropName;	// наименование свойтсва
			Guid ownerID;		// идентификатор цепочки кусочных данных свойства
			bool bChunkedDataFound = false;

			// найдем свойства, чьи данные были загруженны по частам
			foreach(DictionaryEntry entry in xobj.PropertiesWithChunkedData)
			{
				sPropName = (string)entry.Key;
				ownerID = (Guid)entry.Value;
				bChunkedDataFound = true;
				XChunkStorageGateway.MergePropertyChunkedData(
					ownerID, 
					xobj.ObjectType, 
					sPropName, 
					xobj.ObjectID, 
					con );
			}
			return bChunkedDataFound;
		}

		/// <summary>
		/// Удаление (forced) объекта с заданными типом и идентификатором.
		/// </summary>
		/// <remarks>
		/// Помимо самого удаления выполняется: вызов триггеров "до" и "после", очистка кэша в DomainObjectRegistry, уведомление XSecurityManager
		/// Управление транзакцией внешнее.
		/// </remarks>
		/// <param name="context">Контекcт ядра</param>
		/// <param name="sObjectType">Наименвоание типа объекта</param>
		/// <param name="objectID">Идентификатор</param>
		/// <returns>Реальное количество удаленных объектов</returns>
		public static int Delete(IXExecutionContext context, string sObjectType, Guid objectID)
		{
			DomainObjectData xobj = DomainObjectData.CreateToDelete(context.Connection, sObjectType, objectID);
			// #1: Вызов триггеров Before
			XTriggersController.Instance.FireTriggers(xobj.Context, XTriggerFireTimes.Before, context);

			// #2: Сбросим закэшированные данные объектa
			DomainObjectRegistry.ResetObject(xobj);

			// #3: Удаление объекта
			XDatagramProcessorEx dg_proc = XDatagramProcessorMsSqlEx.Instance;
			int nAffected = dg_proc.Delete(context.Connection, xobj);

			// #5: Сигнализируем Securitymanager, что обновились данные (для очистки кэшей)
			XSecurityManager.Instance.TrackModifiedObjects(xobj.Context);

			// #6: Вызов триггеров After
			XTriggersController.Instance.FireTriggers(xobj.Context, XTriggerFireTimes.After, context);

			return nAffected;
		}
	}
}
