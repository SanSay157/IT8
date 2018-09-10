//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Xml;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Переопределенная команда GetObject.
	/// Помимо логики, реализованной во фреймворковской команде данная реализация проверяет права на объекты и их свойства
	/// и расставляется на объектах и свойства атрибуты ограничения доступа
	/// </summary>
	[XTransaction(XTransactionRequirement.Supported)]
    [Serializable]
	public class GetObjectCommand: XCommand
	{
		// Сообщение о наличии в массиве Request.PreloadProperties пустых строк
		private const string ERR_EMPTY_PRELOAD_PATH = "В массиве путей не должно быть пустых строк";

		/// <summary>
		/// Метод выполнения операции, реализация IXCommand.Execute
		/// </summary>
		///	<param name="request">Объект-запрос на выполнение операции</param>
		/// <param name="context">Представление контекста выполнения операции</param>
		/// <returns>
		/// Экземпляр объекта-результата выполнения операции
		/// </returns>
		public override XResponse Execute( XRequest request, IXExecutionContext context ) 
		{
			request.ValidateRequestType( typeof( XGetObjectRequest));

			// Вызывается частная, полностью типизированная реализация
			return this.Execute( (XGetObjectRequest)request, context );
		}

		/// <summary>
		/// Выполнение команды - типизированный вариант
		/// </summary>
		/// <param name="request">Запрос команды, должен иметь тип XGetPropertyRequest</param>
		/// <param name="context">Контекст выполнения команды</param>
		public XGetObjectResponse Execute( XGetObjectRequest request, IXExecutionContext context )
		{
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			DomainObjectData xobj;
			if (request.ObjectID != Guid.Empty)
			{
				xobj = dataSet.Load(context.Connection, request.TypeName, request.ObjectID);
				// Если заданы цепочки прогружаемых свойств, загрузим и эти данные:
				if (request.PreloadProperties != null)
				{
					// ...По каждому списку прогружаемых свойств
					foreach(string sPropList in request.PreloadProperties)
					{
						// Проверяем, что в массиве не передали null и пустые строки
						if( null == sPropList)
							throw new ArgumentNullException( "PreloadProperties");
						if( String.Empty == sPropList)
							throw new ArgumentException( ERR_EMPTY_PRELOAD_PATH, "PreloadProperties");

						dataSet.PreloadProperty(context.Connection, xobj, sPropList);
					}
				}
			}
			else
			{
				xobj = dataSet.CreateNew(request.TypeName, false);
			}
			// сериализуем датасет с загруженными объектами в формат для Web-клиента
			DomainObjectDataXmlFormatter formatter = new DomainObjectDataXmlFormatter(context.Connection.MetadataManager);
			XmlElement xmlObject = formatter.SerializeObject(xobj, request.PreloadProperties);
			if (request.ObjectID != Guid.Empty)
			{
				// ..обработаем объект и все вложенные объекты в прогруженных свойства, расставим атрибуты ограничения доступа
				XmlObjectRightsProcessor.ProcessObject(xobj, xmlObject);
			}
			return new XGetObjectResponse(xmlObject);
		}
	}
}
