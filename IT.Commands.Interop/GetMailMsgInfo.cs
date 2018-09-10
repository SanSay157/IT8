//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	[Serializable]
	public class GetMailMsgInfoRequest: XRequest
	{
		/// <summary>
		/// Идентификатор объекта (Инцидента/Папки)
		/// </summary>
		public Guid ObjectID;
		/// <summary>
		/// Наименование типа объекта
		/// </summary>
		public string ObjectType;
		/// <summary>
		/// Список идентификаторов сотрудников, которым будет посылаться письмо
		/// </summary>
		public Guid[] EmployeeIDs;
	}

	[Serializable]
	public class GetMailMsgInfoResponse: XResponse
	{
		/// <summary>
		/// Список email'ов сотрудников из массива EmployeeIDs запроса
		/// </summary>
		public string To;
		/// <summary>
		/// Тема письма
		/// </summary>
		public string Subject;
		/// <summary>
		/// Строка пути папки
		/// </summary>
		public string FolderPath;
		/// <summary>
		/// Список URL'ов операций над папкой
		/// </summary>
		public string ProjectLinks;
		/// <summary>
		/// Список URL'ов операций над инцидентом (может быть не задан, если ObjectType запроса равно "Folder")
		/// </summary>
		public string IncidentLinks;
	}

}
