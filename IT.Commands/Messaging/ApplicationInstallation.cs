using System;

namespace Croc.IncidentTracker.Messaging
{
	/// <summary>
	/// Summary description for ApplicationInstallation.
	/// </summary>
	public class ApplicationInstallation
	{
		private string m_sTitle;
		private string m_sBaseUrl;

		public string Title
		{
			get
			{
				return m_sTitle;
			}
		}

		public string BaseUrl
		{
			get
			{
				return m_sBaseUrl;
			}
		}


		/// <summary>
		/// 
		/// </summary>
		/// <param name="sTitle"></param>
		/// <param name="sUrl"></param>
		public ApplicationInstallation(string sTitle, string sUrl)
		{
			m_sTitle = sTitle;
			m_sBaseUrl = sUrl;
		}
	}
}
