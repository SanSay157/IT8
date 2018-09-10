//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Xml;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Класс рекурсивно устанавливает на xml-объекте атрибуты разделеybz доступа
	/// Права на чтение, изменение и удаление. Свойства, недоступные для чтения, удаляются из xml-объекта.
	/// Свойства, недоступные для изменения, помечаются атрибутом read-only. 
	/// Объекты недоступные для удаления помечаются атрибутом deny-delete. 
	/// Объекты, недостпуные для изменения, помечаются атрибутом deny-change.
	/// </summary>
	public class XmlObjectRightsProcessor
	{
		public const string ATTR_READONLY	= "read-only";		// атрибут свойства - запрещено изменять
		public const string ATTR_DELETE_RIGHT = "delete-right";	// атрибут объекта - запрещено удалять
		public const string ATTR_CHANGE_RIGHT = "change-right";	// атрибут объекта - запрещено изменять весь объект

		public static void ProcessObject(DomainObjectData xobj, XmlElement xmlObject)
		{
			if (xobj == null)
				throw new ArgumentNullException("xobj", "Не задано типизированное представление объекта");
			if (xmlObject == null)
				throw new ArgumentNullException("xmlObject");
			if (xobj.Context == null)
				throw new ArgumentException("Экземпляр DomainObjectData должен находиться в контексте (DomainObjectDataSet)");
			XmlElement xmlProp;
			
			// получим права текущего пользователя приложения на загруженный объект
			XObjectRights rights = XSecurityManager.Instance.GetObjectRights(xobj);
			if (!rights.AllowParticalOrFullRead)
				throw new XSecurityException("Чтение объекта " + xobj.ObjectType + "[" + xobj.ObjectID.ToString() + "] запрещено");
			// право на удаление объекта
			xmlObject.SetAttribute(ATTR_DELETE_RIGHT, rights.AllowDelete ? "1" : "0");
			// если объект запрещено изменять (хотя бы одно свойство) - поменям атрибутом
			xmlObject.SetAttribute(ATTR_CHANGE_RIGHT, rights.AllowParticalOrFullChange ? "1" : "0");
			if (rights.AllowParticalOrFullChange && rights.HasReadOnlyProps)
			{
				// можно изменять объект, но есть read-only свойства
				foreach(string sProp in rights.GetReadOnlyPropNames())
				{
					xmlProp = (XmlElement)xmlObject.SelectSingleNode(sProp);
					/* Убрано за ненадобностью 
                      if (xmlProp == null)
						throw new ApplicationException("Подсистема ограничения доступа вернула в описании прав на объект " + xmlObject.LocalName + " read-only свойство, которое отсутствует в xml-объекте: " + sProp); */
                    if (xmlProp != null)
                    xmlProp.SetAttribute(ATTR_READONLY, "1");
				}
			}

			if (rights.HasHiddenProps)
			{
				foreach(string sProp in rights.GetHiddenPropNames())
				{
					xmlProp = (XmlElement)xmlObject.SelectSingleNode(sProp);
					if (xmlProp != null)
						xmlObject.RemoveChild(xmlProp);
				}
			}
			// по всем объектам-значениям в прогруженных свойствах 
			foreach(XmlElement xmlObjectValue in xmlObject.SelectNodes("*/*[*]"))
			{
				DomainObjectData xobjValue = xobj.Context.Find(xmlObjectValue.LocalName, new Guid(xmlObjectValue.GetAttribute("oid")));
				if (xobjValue == null)
					throw new ApplicationException("Не удалось найти в контексте типизированного объекта DomainObjectData для xml-объекта-значения свойства " + xmlObjectValue.ParentNode.LocalName + " объекта " + xmlObject.LocalName);
				ProcessObject(xobjValue, xmlObjectValue);
			}
		}
	}
}
