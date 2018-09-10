//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;

namespace Croc.IncidentTracker.Core
{
	/// <summary>
	/// Структура для инициализации экземпляра ApplicationSettings
	/// </summary>
	public struct ApplicationSettingsInitializationParams
	{
		/// <summary>
		/// Дата окончания глобального периода блокирования списаний
		/// </summary>
		public DateTime GlobalBlockPeriodDate;
	}

	/// <summary>
	/// Класс для хранения глобальных настроек приложения.
	/// Значения устанавливаеются в обработчике старта приложения (Handler_OnApplicationStart)
	/// </summary>
	public class ApplicationSettings
	{
		private static ApplicationSettings m_Instance = new ApplicationSettings();
		private bool m_bInitialized;
		private DateTime m_dtGlobalBlockPeriodDate;

		public static void Initialize(ApplicationSettingsInitializationParams initParams)
		{
			m_Instance.m_bInitialized = true;
			m_Instance.m_dtGlobalBlockPeriodDate = initParams.GlobalBlockPeriodDate;
		}

		/// <summary>
		/// Возвращает дату окончания глобального периода блокирования списаний
		/// </summary>
		public static DateTime GlobalBlockPeriodDate
		{
			get
			{
				if (!m_Instance.m_bInitialized)
					throw new InvalidOperationException("Экземпляр ApplicationSettings не был инициализирован");
				return m_Instance.m_dtGlobalBlockPeriodDate;
			}
		}
	}
}
