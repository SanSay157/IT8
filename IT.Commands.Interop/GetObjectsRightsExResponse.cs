using System;
using System.Diagnostics;
using System.Xml.Serialization;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Структура описывающая права текущего пользователя над объектом (в том числе новым)
	/// для передачи на сторону клиента
	/// </summary>
	[Serializable]
	public class XObjectRightsDescr
	{
		/// <summary>
		/// Массив свойств, недоступных для изменения клиенту
		/// </summary>
		public string[] ReadOnlyProps;
		/// <summary>
		/// Запрет удаления объекта
		/// </summary>
		public bool DenyDelete;
		/// <summary>
		/// Запрет изменения объекта
		/// </summary>
		public bool DenyChange;
		/// <summary>
		/// Запрет создания (только для новых объектов)
		/// </summary>
		public bool DenyCreate;
	}

	[Serializable]
	public class GetObjectsRightsExResponse: XResponse
	{
		/// <summary>
		/// Права запрошенных объектов (в т.ч. новых)
		/// </summary>
		[XmlArrayItem(typeof(XObjectRightsDescr))]
		public XObjectRightsDescr[] ObjectsRights;

		/// <summary>
		/// ctor for XmlSerializer
		/// </summary>
		public GetObjectsRightsExResponse()
		{}

		/// <summary>
		/// Инициализирующий конструктов
		/// </summary>
		/// <param name="rights"></param>
		public GetObjectsRightsExResponse(XObjectRightsDescr[] rights)
		{
			if (rights != null)
			{
				foreach(XObjectRightsDescr descr in rights)
				{
					if (descr.ReadOnlyProps != null && descr.ReadOnlyProps.Length > 0)
					{
						foreach(string sPropName in descr.ReadOnlyProps)
							if (sPropName == null || sPropName.Length == 0)
							{
								Debugger.Break();
								throw new ApplicationException("Массив read-only свойств не должен содержать null и пустые строки");
							}
					}
				}
			}
			ObjectsRights = rights;
		}
	}
}
