using System;

using System.Net;
using System.Net.Mail;
using System.Net.Mime;

using System.Text;

/*using Croc.Exchange.WebDAV;*/

namespace Croc.IncidentTracker.Messaging
{
	/// <summary>
	/// Отправляет сообщения по EMail
	/// </summary>
	public class MessageMailer: MessageSender
	{
		private string m_sMailFrom;
		private string m_sTestEmail;
		private SmtpClient m_SmtpClient = null;

		/// <summary>
		/// Конструктор
		/// </summary>
		public MessageMailer(string sHost, int nPort, int nTimeout, string sMailFrom, string sTestEmail)
			: this(new SmtpClient(sHost, nPort) { Timeout = nTimeout }, sMailFrom, sTestEmail)
		{
		}

		/// <summary>
		/// Конструктор
		/// </summary>
		public MessageMailer(SmtpClient SmtpClient, string sMailFrom, string sTestEmail)
		{
			m_sTestEmail = sTestEmail;
			m_sMailFrom = sMailFrom;
			m_SmtpClient = SmtpClient;
		}

		public override void Send(EventNotificationMessage[] messages)
		{
			foreach(EventNotificationMessage m in messages)
			{
				MailMessage e = new MailMessage() 
				{ 
					From = new MailAddress(m_sMailFrom),
					Subject = m.Subject,
					Body = m.HtmlBody,
					IsBodyHtml = true
				};

				if(!string.IsNullOrEmpty(m_sTestEmail))
				{
					foreach(string sTestEmail in m_sTestEmail.Split(';'))
						e.To.Add(sTestEmail);
					foreach(string sRecipientEmail in m.ListOfRecipients)
						e.Subject += " " + sRecipientEmail;
				}
				else
				{
					foreach(string sRecipientEmail in m.ListOfRecipients)
						e.To.Add(sRecipientEmail);
				}

				if (!string.IsNullOrEmpty(m.ReplyTo))
					e.ReplyTo = new MailAddress(m.ReplyTo);

				m_SmtpClient.Send(e);
			}
		}
	}
}
 