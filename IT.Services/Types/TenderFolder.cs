// Типы для сериализации данных о тендерах

namespace Croc.IncidentTracker.Services
{
	using System;

	/// <summary>
	/// Папка
	/// </summary>
	[Serializable]
	public class TenderInfo
	{
		/// <summary>
		/// Идентификатор объекта
		/// </summary>
		public Guid ObjectID;
		/// <summary>
		/// Предполагаемая дата окончания работ
		/// </summary>
		public DateTime? FinishDate;
		/// <summary>
		/// Наименование
		/// </summary>
		public string Name;
		/// <summary>
		/// Код проекта
		/// </summary>
		public string ProjectCode;
		/// <summary>
		/// Код Навиджен
		/// </summary>
		public string NavisionID;
		/// <summary>
		/// Предполагаемая дата начала работ
		/// </summary>
		public DateTime? StartDate;
		/// <summary>
		/// Состояние
		/// </summary>
		public TenderFolderStates State;

		/// <summary>
		/// Клиент
		/// </summary>
		public Guid Customer;
		/// <summary>
		/// Инициатор
		/// </summary>
		public Guid? Initiator;
		/// <summary>
		/// Вышестоящая
		/// </summary>
		public Guid? Parent;
	}

	/// <summary>
	/// Направление активности
	/// </summary>
	[Serializable]
	public class FolderDirectionInfo
	{
		/// <summary>
		/// Направление
		/// </summary>
		public Guid Direction;
		/// <summary>
		/// Папка
		/// </summary>
		public Guid Folder;
	}

	/// <summary>
	/// Определяет перечень значений, отражающих значимые состояния проектов, 
	/// описания которых представлены в системе Incident Tracker и системах НСИ
	/// </summary>
	[Serializable]
	public enum TenderFolderStates
	{
		/// <summary>
		/// Проект открыт. 
		/// По проекту ведутся работы. В системе Incident Tracker для проекта 
		/// разрешено выполнение всех операций, допустимых с учетом текущих 
		/// привилегий пользователей. 
		/// </summary>
		Open = 1,

		/// <summary>
		/// Проект на стадии "Ожидание закрытия"
		/// По сути то же, что и "Открыт" за одним исключением: по таким проектам
		/// Incident Tracker осуществяляет периодическую рассылку с напоминанием
		/// </summary>
		WaitingToClose = 2,

		/// <summary>
		/// Проект закрыт. 
		/// Для закрытого проекта в системе Incident Tracker запрещены какие-либо 
		/// операции, влияющие на реквизиты, структуру проекта, влияющие на объем или 
		/// структуру списаний, соотнесенных с проектом.
		/// </summary>
		Closed = 3,

		/// <summary>
		/// Проект заморожен
		/// Для замороженного проекта в системе Incident Tracker запрещены какие-либо 
		/// операции, влияющие на реквизиты, структуру проекта, влияющие на объем или 
		/// структуру списаний, соотнесенных с проектом; но при этом возможен перевод
		/// состояния проекта в любое состояние, отличное от "Заморожен".
		/// </summary>
		Frozen = 4
	}
}