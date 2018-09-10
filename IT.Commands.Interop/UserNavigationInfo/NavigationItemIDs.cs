//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Перечисление идентификаторов возможных навигационных элементов систем
	/// Incident Tracker и Системы Учета Тендеров
	/// </summary>
	[Serializable]
	public class NavigationItemIDs 
	{
		/// <summary>
		/// "Домашняя" страница системы Incident Tracker 
		/// </summary>
		public const string IT_HomePage = "toolBtn-Home";

		/// <summary>
		/// Иерархия "Клиенты и Проекты" (ДКП)
		/// </summary>
		public const string IT_CustomerActivityTree = "toolBtn-ActivityTree";

		/// <summary>
		/// Список Проектов (c поиском)
		/// </summary>
		public const string IT_ActivityList = "toolBtn-ActivityList";

		/// <summary>
		/// Список "Мои инциденты" (текущие задачи)
		/// </summary>
		public const string IT_CurrentTasks = "toolBtn-CurrentTasks";
		
		/// <summary>
		/// Список инцидентов (поиск инцидентов)
		/// </summary>
		public const string IT_IncidentList = "toolBtn-IncidentList";
		
		/// <summary>
		/// Список "Списания времени"
		/// </summary>
		public const string IT_TimeLossSearchingList = "toolBtn-TimeLossSearchingList";
		
		/// <summary>
		/// Страница "Отчеты" (меню вызова всех отчетов, представленных в системах)
		/// </summary>
		public const string IT_Reports = "toolBtn-Reports";
		
		/// <summary>
		/// Иерархия организационной структуры (Организации, подразделения, сотрудники)
		/// </summary>
		public const string IT_OrgStructure = "toolBtn-OrgStructure";
		
		/// <summary>
		/// Вызов инструмента поиска заданного инцидента
		/// </summary>
		public const string IT_FindIncident = "toolBtn-FindIncident";

		/// <summary>
		/// "Домашняя" страница Системы Учета Тендеров (СУТ)
		/// </summary>
		public const string TMS_HomePage = "toolBtn-TMS";
		
		/// <summary>
		/// Список тендеров (СУТ)
		/// </summary>
		public const string TMS_TenderList = "toolBtn-TMS-TenderList";

		/// <summary>
		/// Страница административных интерфейсов (все объекты системы и пр.)
		/// </summary>
		public const string IT_Administation = "toolBtn-Administration";
	}
}

