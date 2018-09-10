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
	/// Команда загрузки значения свойства
	/// Помимо логики, реализованной во фреймворковской команде данная реализация проверяет права на объекты и их свойства
	/// и расставляется на объектах и свойства атрибуты ограничения доступа
	/// </summary>
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetPropertyCommand : XCommand
	{
		/// <summary>
		/// Выполнение команды
		/// </summary>
		/// <param name="request">Запрос команды, должен иметь тип XGetPropertyRequest</param>
		/// <param name="context">Контекст выполнения команды</param>
		/// <returns>XGetPropertyResponse</returns>
		public override XResponse Execute( XRequest request, IXExecutionContext context )
		{
			request.ValidateRequestType( typeof( XGetPropertyRequest));

			return this.Execute ( (XGetPropertyRequest)request, context );
		}

		/// <summary>
		/// Выполнение команды - типизированный вариант
		/// </summary>
		/// <param name="request">Запрос команды, должен иметь тип XGetPropertyRequest</param>
		/// <param name="context">Контекст выполнения команды</param>
		/// <returns>XGetPropertyResponse</returns>
		public new XGetPropertyResponse Execute( XGetPropertyRequest request, IXExecutionContext context )
		{
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			// создадим болванку объекта
			DomainObjectData xobj = dataSet.GetLoadedStub(request.TypeName, request.ObjectID);
			// загрузим свойства
			dataSet.LoadProperty(context.Connection, xobj, request.PropName);
			// создадим форматировщик
			DomainObjectDataXmlFormatter formatter = new DomainObjectDataXmlFormatter(context.Connection.MetadataManager);
			// и сериализуем свойство в XML
			XmlElement xmlProperty = formatter.SerializeProperty(xobj, request.PropName);
			// по всем объектам в свойстве (LoadProperty вызывается не только для объектных свойств - еще для bin и text)
			// обработаем объект и все вложенные объекты в прогруженных свойства, расставим атрибуты ограничения доступа
			foreach(XmlElement xmlObject in xmlProperty.SelectNodes("*[*]"))
			{
				DomainObjectData xobjValue = xobj.Context.Find(xmlObject.LocalName, new Guid(xmlObject.GetAttribute("oid")));
				if (xobjValue == null)
					throw new ApplicationException("Не удалось найти в контексте типизированного объекта DomainObjectData для xml-объекта-значения свойства " + xmlProperty.LocalName + " объекта " + xmlObject.LocalName);
				XmlObjectRightsProcessor.ProcessObject(xobjValue, xmlObject);
			}
			XGetPropertyResponse response = new XGetPropertyResponse(xmlProperty);
			return response;
		}
	}
}
