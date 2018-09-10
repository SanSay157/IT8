//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
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
		/// ����������� �� ���������
		/// ������������ ��� ���������� XML-��-������������
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
					throw new ArgumentNullException("NavigationInfo", "�������� ���������������� �������� ������������� ������ �� ����� ���� ������ � null");
				m_NavigationInfo = value;
			}
		}
	}
}