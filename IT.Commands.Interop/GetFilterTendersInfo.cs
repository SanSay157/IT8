using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Запрос для команды получения данных для фильтра списка тендеров
	/// </summary>
	[Serializable]
	public class GetFilterTendersInfoRequest : XRequest
	{
		public GetFilterTendersInfoRequest() 
			: base("GetFilterTendersInfo")
		{
		}
		
		private Guid m_uidSelectedTenderID;

		/// <summary>
		/// Идентификатор выбранного тендера
		/// </summary>
		/// <remarks>Равен Guid.Empty, если тендер не указан</remarks>
		public Guid SelectedTenderID
		{
			get { return this.m_uidSelectedTenderID; }
			set { this.m_uidSelectedTenderID = value; }
		}
	}


	/// <summary>
	/// Ответ для команды получения данных для фильтра списка тендеров
	/// </summary>
	[Serializable]
	public class GetFilterTendersInfoResponse: XResponse
	{
		private Guid m_uidOrganizationID = Guid.Empty;

		private DateTime m_dtDocFeedingDate = DateTime.MinValue;

		/// <summary>
		/// Идентификатор компании
		/// </summary>
		public Guid OrganizationID
		{
			get { return this.m_uidOrganizationID; }
			set { this.m_uidOrganizationID = value; }
		}

		/// <summary>
		/// Дата подачи документов выбранного тендера
		/// </summary>
		public DateTime DocFeedingDate
		{
			get { return this.m_dtDocFeedingDate; }
			set { this.m_dtDocFeedingDate = value; }
		}
	}
}
