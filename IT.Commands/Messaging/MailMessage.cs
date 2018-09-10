using System;
using System.Collections;
using System.IO;
using System.Net;
using System.Text;
using System.Xml;

namespace Croc.Exchange.WebDAV
{
	/// <summary>
	/// ������
	/// </summary>
	public sealed class MailMessage
	{
		private class WebDAVMethods
		{
			public static readonly string PROPPATCH = "PROPPATCH";
			public static readonly string BMOVE = "BMOVE";
		}
        /// <summary>
        /// �����, ����������� ������������ � �������� http-�������� ��� ������� ������
        /// </summary>
		private class WebDAVRequest
		{
			protected HttpWebRequest m_httpRequest;
			public WebDAVRequest(HttpWebRequest httpRequest)
			{
				m_httpRequest = httpRequest;
			}

            /// <summary>
            /// ����� ������� http-�������
            /// </summary>
			public void Send()
			{
				m_httpRequest.GetResponse().Close();
			}

            /// <summary>
            /// ������ ������������ http-�������
            /// </summary>
            public static WebDAVRequest Create(string sMethod, string sUrl, byte[] data,ICredentials credentials)
			{
				WebDAVRequest req = Create(sMethod, sUrl, credentials);
				req.WriteContent(data);
				return req;
			}
			public static WebDAVRequest Create(string sMethod, string sUrl, ICredentials credentials)
			{
				HttpWebRequest webRequest = (HttpWebRequest)HttpWebRequest.Create(sUrl);
				webRequest.Credentials = credentials;
				webRequest.Method = sMethod;
				webRequest.ContentType = "text/xml";
				return new WebDAVRequest(webRequest);
			}

            /// <summary>
            /// ����� ���������� ��������� �������
            /// </summary>
			public void AddHeader(string sParam, string sValue)
			{
				m_httpRequest.Headers.Add(sParam, sValue);
			}

            /// <summary>
            /// ����� ������ ����������� �������
            /// </summary>
			public void WriteContent(byte[] data)
			{
				m_httpRequest.ContentLength = data.Length;
				using(Stream stream = m_httpRequest.GetRequestStream())
				{
					stream.Write(data, 0, data.Length);
				}
			}

            /// <summary>
            /// ����� ��������� �������� ������� � �������������
            /// </summary>
            /// <param name="nTimeout"></param>
			public void SetTimeout(int nTimeout)
			{
				m_httpRequest.Timeout = nTimeout*1000;
			}
		}
		private class StringList: ArrayList
		{
			public string Join(string separator)
			{
				return string.Join(separator, (string[]) this.ToArray(typeof(string)));
			}
		}
		private class RecipientsList: StringList
		{
			public override string ToString()
			{
				return Join(";");
			}
		}

		// TODO: ��������
		// TODO: ���������������

        //�������� �������������� ��������� (������������ xml-����) � xml-������������� ������ 
        const string MailURI_e = "http://schemas.microsoft.com/exchange/";
        const string MailURI_mapi = "http://schemas.microsoft.com/mapi/";
        const string MailURI_mapit = "http://schemas.microsoft.com/mapi/proptag/";
        const string MailURI_dt = "urn:uuid:c2f41010-65b3-11d1-a29f-00aa00c14882/";
        const string MailURI_h = "urn:schemas:mailheader:";
        const string MailURI_m = "urn:schemas:httpmail:";

		private RecipientsList m_to;
		private RecipientsList m_cc;
		private RecipientsList m_bcc;
		private RecipientsList m_replyTo;
		private string m_subject;
		private string m_htmlBody;
		private string m_from;

        /// <summary>
        /// email ����������� ������
        /// </summary>
		public string RcptFrom
		{
			get{return m_from;}
			set{m_from=normalizeString(value);}
		}

        /// <summary>
        /// ������ email-������� ����������� ������
        /// </summary>
		public IList RcptTo
		{
			get {return m_to;}
		}

        /// <summary>
        /// ������ email-������� ����������� ������,������� � �����
        /// </summary>
		public IList RcptCc
		{
			get {return m_cc;}
		}

		public IList RcptBcc
		{
			get {return m_bcc;}
		}

        /// <summary>
        /// ������ email-������� ��� ������ �� ������
        /// </summary>
		public IList ReplyTo
		{
			get {return m_replyTo;}
		}

        /// <summary>
        /// ���� ������
        /// </summary>
		public string Subject
		{
			get{return m_subject;}
			set
			{
				m_subject = normalizeString(value);
			}
		}

        /// <summary>
        /// Html-���������� ������
        /// </summary>
		public string HtmlBody
		{
			get{return m_htmlBody;}
			set{m_htmlBody = normalizeString(value);}
		}

        /// <summary>
        /// ��������������� �����,��������� ������� � ������ � ����� ������
        /// </summary>
        /// <param name="stringValue"></param>
        /// <returns></returns>
		private string normalizeString(string stringValue)
		{
			if(stringValue!=null)
			{
				if(0!=stringValue.Trim().Length)
				{
					return stringValue.Trim();
				}
			}
			return null;
		}

        /// <summary>
        /// ����������� ������
        /// </summary>
		public MailMessage()
		{
			m_to = new RecipientsList();
			m_cc = new RecipientsList();
			m_bcc = new RecipientsList();
			m_replyTo = new RecipientsList();
		}

		/// <summary>
		/// ����� �������� ��������� ����� 
		/// </summary>
		/// <param name="messages">��������� ����� ��� ��������  - �������� ���� MailMessage</param>
		/// <param name="sMailBoxUrl">url ������� ����� � �������� ������������ ������, �������� http://dm.croc.ru/exchange/DAlexandrov</param>
		public static void Send(ICollection messages, string sMailBoxUrl, int nTimeout, ICredentials credentials)
		{
			if(0==messages.Count) return;
			
			string draftsUrl = sMailBoxUrl + "/drafts/";
			StringBuilder mailToDeliver = new StringBuilder();

			mailToDeliver.Append("<?xml version=\"1.0\"?><D:move xmlns:D=\"DAV:\"><D:target>");
			WebDAVRequest req;
			foreach(MailMessage m in messages)
			{
				///
				string mailUrl = draftsUrl + Guid.NewGuid().ToString("N") + ".eml";
				req = WebDAVRequest.Create(WebDAVMethods.PROPPATCH, mailUrl, m.ToXmlByteArray(), credentials);
				req.SetTimeout(nTimeout);
				req.Send();
				mailToDeliver.AppendFormat("<D:href>{0}</D:href>", mailUrl);
				///
			}


			mailToDeliver.Append("</D:target></D:move>");

			///
			byte[] data = Encoding.UTF8.GetBytes(mailToDeliver.ToString());
			req = WebDAVRequest.Create(WebDAVMethods.BMOVE, draftsUrl, credentials);
			req.SetTimeout(nTimeout);
			req.AddHeader("Destination", sMailBoxUrl + "/##DavMailSubmissionURI##/");
			req.AddHeader("Saveinsent", "f");
			req.WriteContent(data);
			req.Send();
		}

        /// <summary>
        /// ����� ������������ xml-������������� ������
        /// </summary>
        /// <param name="xw"></param>
        /// <param name="m">�������� ������ - ������ ���� MailMessage</param>
		private static void writeMailToXml(XmlWriter xw, MailMessage m)
		{
		    xw.WriteStartElement("g","propertyupdate", "DAV:");
			xw.WriteAttributeString("xmlns", "e", null, MailURI_e);
			xw.WriteAttributeString("xmlns", "mapi", null, MailURI_mapi);
			xw.WriteAttributeString("xmlns", "mapit", null,MailURI_mapit);
			xw.WriteAttributeString("xmlns", "x", null, "xml:");
			xw.WriteAttributeString("xmlns", "dt", null, MailURI_dt);
			xw.WriteAttributeString("xmlns", "h", null,MailURI_h);
			xw.WriteAttributeString("xmlns", "m", null, MailURI_m);
			xw.WriteStartElement("g:set");
			xw.WriteStartElement("g:prop");
			xw.WriteStartElement("g:contentclass");
			xw.WriteString("urn:content-classes:message");
			xw.WriteEndElement();
			xw.WriteStartElement("e:outlookmessageclass");
			xw.WriteString("IPM.Note");
			xw.WriteEndElement();
	
			writeRecipientsToXml(xw, m.RcptTo, "h:to");
			writeRecipientsToXml(xw, m.RcptCc, "h:cc");
			writeRecipientsToXml(xw, m.RcptBcc, "h:bcc");
			writeRecipientsToXml(xw, m.ReplyTo, "h:reply-to");
	
			xw.WriteStartElement("m:subject");
			xw.WriteString(m.Subject==null?"No Subject":m.Subject);
			xw.WriteEndElement();
	
			xw.WriteStartElement("m:htmldescription");
			xw.WriteString(m.HtmlBody==null?"No Body":m.HtmlBody);
			xw.WriteEndElement();
	
			xw.WriteEndElement();
			xw.WriteEndElement();
			xw.WriteEndElement();
			xw.Flush();
		}

        /// <summary>
        /// ����� ������ ����������� � xml-������������� ������
        /// </summary>
        /// <param name="xw"></param>
        /// <param name="recipientsList">������ �����������</param>
        /// <param name="elementName">xml-����,���� ����� ����������� ������</param>
		private static void writeRecipientsToXml(XmlWriter xw, IList recipientsList, string elementName)
		{
			if(recipientsList.Count!=0)
			{
				xw.WriteStartElement(elementName);
				xw.WriteString(recipientsList.ToString());
				xw.WriteEndElement();
			}
		}

        /// <summary>
        /// ����� �������������� xml-��������� � ������ ������
        /// </summary>
        /// <returns></returns>
		public byte[] ToXmlByteArray()
		{
			using(Stream ms = new MemoryStream())
			{
				XmlTextWriter xw = new XmlTextWriter(ms, Encoding.UTF8);
				writeMailToXml(xw,this);
				byte[] result = new byte[ms.Length];
				ms.Seek(0, SeekOrigin.Begin);
				ms.Read(result,0,result.Length);
				return result;
			}
		}
	}
}
