//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Xml;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Операция получения XML-документа с данными набора заданных ds-объектов
	/// Помимо логики, реализованной во фреймворковской команде данная реализация проверяет права на объекты и их свойства
	/// и расставляется на объектах и свойства атрибуты ограничения доступа
	/// <seealso cref="XGetObjectsRequest"/>
	/// <seealso cref="XGetObjectsResponse"/>
	/// </summary>
    [Serializable]
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetObjectsCommand : XCommand
	{
		/// <summary>
		/// Операция получения XML-документа с данными набора заданных ds-объектов
		/// ТИПИЗИРОВАННАЯ ВЕРСИЯ МЕТОДА
		/// АВТОМАТИЧЕСКИ ВЫЗЫВАЕТСЯ ЯДРОМ
		/// </summary>
		/// <param name="request">Запрос на вполнение операции</param>
		/// <param name="context">Контекст выоленения операции</param>
		/// <returns>Результат выполенения операции</returns>
		public XGetObjectsResponse Execute(XGetObjectsRequest request, IXExecutionContext context) 
		{
			// Проверка праметров - массив с перечнем идентификационных данных
			// объектов должен быть задан, и не должен быть пустым:
			if ( null==request.List )
				throw new ArgumentNullException("request.List");
			if ( 0==request.List.Length )
				throw new ArgumentException("request.List");

			XmlDocument xmlDoc = new XmlDocument();
			XmlElement xmlRootElement = xmlDoc.CreateElement("root");
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			DomainObjectDataXmlFormatter formatter = new DomainObjectDataXmlFormatter(context.Connection.MetadataManager);
			DomainObjectData xobj;

			foreach(XObjectIdentity i in request.List)
			{
				if (i.ObjectID== Guid.Empty)
				{
					xmlRootElement.AppendChild(context.Connection.Create(i.ObjectType, xmlDoc));
				}
				else
				{
					try
					{
						xobj = dataSet.Load(context.Connection, i.ObjectType, i.ObjectID);
						xmlRootElement.AppendChild( formatter.SerializeObject(xobj, xmlDoc) );
					}
					catch(XObjectNotFoundException)
					{
						XmlElement xmlStub = (XmlElement) xmlRootElement.AppendChild(
							context.Connection.CreateStub(i.ObjectType, i.ObjectID, xmlDoc) );
						xmlStub.SetAttribute("not-found", "1");
					}
				}
			}
			// по всем запрошенным объектам
			foreach(XmlElement xmlObject in xmlRootElement.SelectNodes("*[*]"))
			{
				// обработаем объект и все вложенные объекты в прогруженных свойства, расставим атрибуты ограничения доступа
				if (!xmlObject.HasAttribute("new"))
				{
					DomainObjectData xobjValue = dataSet.Find(xmlObject.LocalName, new Guid(xmlObject.GetAttribute("oid")));
					if (xobjValue == null)
						throw new ApplicationException("Не удалось найти в контексте типизированного объекта DomainObjectData для xml объекта: " + xmlObject.OuterXml);
					
					XmlObjectRightsProcessor.ProcessObject(xobjValue, xmlObject);
				}
			}

			return new XGetObjectsResponse(xmlRootElement);
		}
	}
}
