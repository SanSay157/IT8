//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Collections.Specialized;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Данные, необходимые для построения навигационной панели, соответствующей
	/// текущим настройкам пользователя
	/// </summary>
	[Serializable]
	public class UserNavigationInfo 
	{
		/// <summary>
		/// Константная строка, может быть использована в качестве ключа 
		/// при сохранении UserNavigationInfo в коллекции переменных сессии
		/// </summary>
		public const string CURRENT_NAVIGATION_INFO = "CURRENT_NAVIGATION_INFO";
		
		#region Внутренние переменные и методы 

		/// <summary>
		/// Признак использования "собственной" стартовой страницы (отлчной
		/// от "домашней") - при старте сессии система выполнит автоматический
		/// redirect на заданную страницу (какую именно - определяет значение
		/// в m_enOwnStartPage)
		/// </summary>
		protected bool m_bUseOwnStartPage = false;
		/// <summary>
		/// Указание "собственной" стартовой старницы
		/// </summary>
		protected StartPages m_enOwnStartPage;
		/// <summary>
		/// Коллекция навигационных элементов, доступных текущему пользователю
		/// Ключ - идентификатор элемента (см. NavigationItem.ItemID), значение 
		/// URL страницы / операции, привязанной к данному навигационному 
		/// элементу (м.б. задан как String.Empty - в этом случае используется
		/// URL, заданный в NavigationItem)
		/// </summary>
		protected NameValueCollection m_UsedNavigationItems = null;
		/// <summary>
		/// Признак отображения панели с данными по затратам пользователя
		/// </summary>
		protected bool m_bDoShowExpensesPanel = false;
		/// <summary>
		/// Период автообновления данных в панели отображения затрат
		/// Значение 0 указывает на то, что автообновление отключено
		/// </summary>
		protected int m_nExpensesPanelAutoUpdateDelay = 0;

		#endregion

		/// <summary>
		/// Конструктор по умолчанию
		/// Требуется для корректной XML-де-сериализации
		/// </summary>
		public UserNavigationInfo() 
		{
			m_bUseOwnStartPage = false;
			m_UsedNavigationItems = new NameValueCollection();
			m_bDoShowExpensesPanel  = true;
			m_nExpensesPanelAutoUpdateDelay = 0;
		}

		
		/// <summary>
		/// Коллекция навигационных элементов, доступных текущему пользователю
		/// Ключ - идентификатор элемента (см. NavigationItem.ItemID), значение 
		/// URL страницы / операции, привязанной к данному навигационному 
		/// элементу (м.б. задан как String.Empty - в этом случае используется
		/// URL, заданный в NavigationItem)
		/// </summary>
		public NameValueCollection UsedNavigationItems 
		{
			get { return m_UsedNavigationItems; } 
			set
			{
				if (null==value)
					throw new ArgumentNullException("UsedNavigationItems", "Коллекция идентификаторов доступных навигационных элементов не может быть задана в null");
				m_UsedNavigationItems = value;
			}
		}
	
	
		/// <summary>
		/// Признак использования "собственной" стартовой страницы (отлчной
		/// от "домашней") - при старте сессии система выполнит автоматический
		/// redirect на заданную страницу (какую именно - определяет значение
		/// в OwnStartPage)
		/// </summary>
		public bool UseOwnStartPage 
		{
			get { return m_bUseOwnStartPage; }
			set { m_bUseOwnStartPage = value; }
		}

		
		/// <summary>
		/// Указание "собственной" стартовой старницы
		/// </summary>
		public StartPages OwnStartPage 
		{
			get { return m_enOwnStartPage; }
			set { m_enOwnStartPage = value; } // TODO: Надо бы проверять доступность указанной страницы
		}

	
		/// <summary>
		/// Признак отображения панели с данными по затратам пользователя
		/// </summary>
		public bool ShowExpensesPanel 
		{
			get { return m_bDoShowExpensesPanel; }
			set { m_bDoShowExpensesPanel = value; }
		}

		
		/// <summary>
		/// Период автообновления данных в панели отображения затрат
		/// Значение 0 указывает на то, что автообновление отключено
		/// </summary>
		public int ExpensesPanelAutoUpdateDelay 
		{
			get { return m_nExpensesPanelAutoUpdateDelay; }
			set { m_nExpensesPanelAutoUpdateDelay = value; }
		}


		/// <summary>
		/// Служебный метод получения соответствующего идентификатора навигационного 
		/// элемента для заданного значения типа StartPages
		/// </summary>
		/// <param name="enStartPage"></param>
		/// <returns></returns>
		public static string StartPage2NavItemID( StartPages enStartPage ) 
		{
			string sOwnStartPageID = null;
			switch (enStartPage)
			{
				// "Мои инциденты" (текущие задачи)
				case StartPages.CurrentTaskList:
					sOwnStartPageID = NavigationItemIDs.IT_CurrentTasks; 
					break;
				// Иерархия "Клиенты и проекты"
				case StartPages.DKP:
					sOwnStartPageID = NavigationItemIDs.IT_CustomerActivityTree; 
					break;
				// Страница отчетов
				case StartPages.Reports:
					sOwnStartPageID = NavigationItemIDs.IT_Reports; 
					break;
				// Стартовая страница Системы Учета Тендеров (СУТ)
				case StartPages.TMS:
					sOwnStartPageID = NavigationItemIDs.TMS_HomePage; 
					break;
				// Список тендкров (в СУТ)
				case StartPages.TenderList:
					sOwnStartPageID = NavigationItemIDs.TMS_TenderList; 
					break;
				default:
					sOwnStartPageID = null; 
					break;
			}
			return sOwnStartPageID;
		}

	}
}