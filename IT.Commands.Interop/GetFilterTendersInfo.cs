using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������ ��� ������� ��������� ������ ��� ������� ������ ��������
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
		/// ������������� ���������� �������
		/// </summary>
		/// <remarks>����� Guid.Empty, ���� ������ �� ������</remarks>
		public Guid SelectedTenderID
		{
			get { return this.m_uidSelectedTenderID; }
			set { this.m_uidSelectedTenderID = value; }
		}
	}


	/// <summary>
	/// ����� ��� ������� ��������� ������ ��� ������� ������ ��������
	/// </summary>
	[Serializable]
	public class GetFilterTendersInfoResponse: XResponse
	{
		private Guid m_uidOrganizationID = Guid.Empty;

		private DateTime m_dtDocFeedingDate = DateTime.MinValue;

		/// <summary>
		/// ������������� ��������
		/// </summary>
		public Guid OrganizationID
		{
			get { return this.m_uidOrganizationID; }
			set { this.m_uidOrganizationID = value; }
		}

		/// <summary>
		/// ���� ������ ���������� ���������� �������
		/// </summary>
		public DateTime DocFeedingDate
		{
			get { return this.m_dtDocFeedingDate; }
			set { this.m_dtDocFeedingDate = value; }
		}
	}
}
