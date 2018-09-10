using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Запрос на поиск сотрудника в Дереве "Структура компаний"
	/// </summary>
	[Serializable]
	public class EmployeeLocatorInCompanyTreeRequest: XRequest
	{
		/// <summary>
		/// Фамилия
		/// </summary>
		public string LastName;
		/// <summary>
		/// Массив идентификаторов игнорируемых сотрудников
		/// </summary>
		public Guid[] IgnoredObjects;
		/// <summary>
		/// Учитывать архивных сотрудников
		/// </summary>
		public bool AllowArchive;
	}
}
