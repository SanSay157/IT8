//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using System.Xml;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Запрос для команды GetCurrentUserClientProfile - 
	/// получениe профиля текущего пользователя для Web-клиента
	/// </summary>
	[Serializable]
	public class GetCurrentUserClientProfileResponse: XResponse
	{
		/// <summary>
		/// Количество часов в рабочих сутках
		/// </summary>
		public int WorkdayDuration;
		/// <summary>
		/// Идентификатор текущего пользователя приложения
		/// </summary>
		public Guid SystemUserID;
		/// <summary>
		/// Идентификатор текущего сотрудника
		/// </summary>
		public Guid EmployeeID;
	}
}