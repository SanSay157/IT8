//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Класс запроса для команды FolderLocatorInTreeCommand
	/// </summary>
	[Serializable]
	public class FolderLocatorInTreeRequest: XRequest
	{
		/// <summary>
		/// Идентификатор искомой папки
		/// </summary>
		public Guid FolderOID;

        /// <summary>
        /// Код проекта
        /// </summary>
        public string FolderExID;

		public FolderLocatorInTreeRequest()
			: base("FolderLocatorInTree")
		{}
	}
}
