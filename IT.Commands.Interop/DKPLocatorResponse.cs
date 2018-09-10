//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Класс ответа для команд FolderLocatorInTreeCommand и IncidentLocatorInTreeCommand
	/// </summary>
	[Serializable]
	public class DKPLocatorResponse: XResponse
	{
		/// <summary>
		/// Строка пути в дереве "Клиенты и проекты" до заданного объекта в формате ActiveX CROC.IXTreeView
		/// </summary>
		public string Path;
		/// <summary>
		/// Идентификатор искомого объекта (полезен, если поиск производится не по идентификатору)
		/// </summary>
		public Guid ObjectID;
	}
}