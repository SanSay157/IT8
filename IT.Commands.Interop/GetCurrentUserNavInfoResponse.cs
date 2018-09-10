//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	[Serializable]
	public class GetCurrentUserNavInfoResponse : XResponse
	{
		protected UserNavigationInfo m_NavigationInfo = null;
		
		/// <summary>
		/// Конструктор по умолчанию
		/// Используется для корректной XML-де-сериализации
		/// </summary>
		public GetCurrentUserNavInfoResponse()
		{
			m_NavigationInfo = new UserNavigationInfo();
		}

		public UserNavigationInfo NavigationInfo
		{
			get { return m_NavigationInfo; }
			set
			{
				if (null==value)
					throw new ArgumentNullException("NavigationInfo", "Описание пользовательских настроек навигационной панели не может быть задано в null");
				m_NavigationInfo = value;
			}
		}
	}
}