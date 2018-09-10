using System;
using System.Collections;

namespace Croc.IncidentTracker.Messaging
{
	/// <summary>
	/// Summary description for EventNotificationMessage.
	/// </summary>
	public class EventNotificationMessage
	{

		public string Subject		= "No Subject";
		public string HtmlBody		= "Body";
		private ArrayList m_aRecipients	= new ArrayList();
		public string ReplyTo		= "";

		public EventNotificationMessage()
		{
			//
			// TODO: Add constructor logic here
			//
		}

		public void AddRecipient(string s)
		{
			m_aRecipients.Add(s);
		}

		public void AddRecipients(ICollection c)
		{
			m_aRecipients.AddRange(c);
		}

		public IList ListOfRecipients
		{
			get
			{
				return m_aRecipients;
			}
		}

		public string Recipients
		{
			get
			{
				return String.Join(";",((string[])m_aRecipients.ToArray(typeof(string))));
			}
		}
	}
}
