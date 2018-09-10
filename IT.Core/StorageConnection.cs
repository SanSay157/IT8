using System;
using Croc.IncidentTracker.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Storage
{
	/// <summary>
	/// Summary description for StorageConnection.
	/// </summary>
	public class StorageConnection: XStorageConnectionMsSql
	{
		/// <summary>
		/// Признак "при открытии соединения вставлять во временную таблицу идентификатор пользователя"
		/// </summary>
		private bool m_bTrackUserLogin = false;

		/// <summary>
		/// Возвращает признак "при открытии соединения вставлять во временную таблицу идентификатор пользователя"
		/// </summary>
		public bool TrackUserLogin
		{
			get { return m_bTrackUserLogin; }
		}

		/// <summary>
		/// Обработка параметров из файла конфигурации
		/// </summary>
		/// <param name="sParamName"></param>
		/// <param name="sValue"></param>
		/// <returns></returns>
		public override bool SetParameter(string sParamName, string sValue)
		{
			if (sParamName == "XS_TrackUserLogin")
			{
				m_bTrackUserLogin = (sValue == "1");
				return true;
			}
			else
				return base.SetParameter(sParamName, sValue);
		}

		/// <summary>
		/// Переопределенный метод открытия соединения. 
		/// Если задан флаг TrackUserLogin, то во врменную таблицы #UserLogin добавляется запись 
		/// с информацией о текущем пользователе приложения
		/// </summary>
		public override void Open()
		{
			base.Open();
			if (TrackUserLogin)
			{
				string sUserName = XSecurityManager.Instance.CurrentUserName;
				// Внимание: здесь нельзя вызвать:
				// (ITUser)XSecurityManager.Instance.GetCurrentUser();
				// т.к. это приведет к рекурсии и исчерпанию всех кеннекшенов в пуле!, ибо 
				// GetCurrentUser обращает в свою очеред к БД через другой экземпляр StorageConnection
				ITUser user = (ITUser)XSecurityManager.Instance.Users[sUserName];
				if (user != null)
				{
					// ВНИМАНИЕ! Только в случае, если XSecurityManager уже содержит описание текущего пользователя, мы
					// получим его описание, т.к. только в этом случае не произойден доступ к БД и рекурсивное открытие соединения
					CreateCommand(
						String.Format(
							"SELECT '{0}' AS EmployeeID, '{1}' AS SystemUserID, '{2}' AS Login INTO #UserLogin",
							user.EmployeeID,
							user.SystemUserID,
							user.Name
							)
						).ExecuteNonQuery();
				}
			}
		}
	}
}
