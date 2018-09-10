using System;
using System.Collections;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Xsl;

namespace Croc.IncidentTracker.Messaging
{
	/// <summary>
	/// Summary description for MessageGenerator.
	/// </summary>
	public class MessageGenerator
	{
		private const string DEFAULT_SUBJECT = "Сообщение Incident Tracker";
		private int m_nMessagesPerOnce;
		private SqlConnection m_connection;
		private XmlResolver m_xmlResolver;
		private MessageSender m_messageSender;
		private XslTransform m_xslTransform;
		private int m_nMaxMessagesPerDigest;
		private static Regex m_titleExtractionRegex;
		private DateTime m_dtDigestSchedule = DateTime.Now;
		private int m_nDigestInterval;
		private static Regex m_titleCleanUpRegex;

		private static readonly string REGEX_TITLE_EXTRACTION_PATTERN = @"(?<=\<title[^>]*>)[^<]*(?=\<)";
		private static readonly string REGEX_TITLE_CLEANUP_PATTERN = @"[\f\v\t\n\r]+";
		private XsltArgumentList m_xsltArguments = new XsltArgumentList();

		static MessageGenerator()
		{
			m_titleExtractionRegex = new Regex(REGEX_TITLE_EXTRACTION_PATTERN, RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.Multiline);
			m_titleCleanUpRegex = new Regex(REGEX_TITLE_CLEANUP_PATTERN, RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.Multiline);
		}

		public MessageGenerator(ICollection applications, string sXsltFileName, int nDigestInterval, int nMaxMessagesPerDigest, int nMessagesPerOnce, SqlConnection conn, MessageSender messageSender)
		{
			XmlDocument doc = new XmlDocument();
			doc.AppendChild(doc.CreateElement("applications"));
			foreach(ApplicationInstallation a in applications)
			{
				XmlElement e = doc.CreateElement("app");
				e.SetAttribute("title", a.Title);
				e.SetAttribute("url", a.BaseUrl);
				doc.DocumentElement.AppendChild(e);
			}
			m_xsltArguments.AddParam("applications", string.Empty, (new XPathDocument(new XmlNodeReader(doc))).CreateNavigator().Select("*/*") );

			m_nDigestInterval = nDigestInterval;
			m_nMessagesPerOnce = nMessagesPerOnce;
			m_nMaxMessagesPerDigest = nMaxMessagesPerDigest;
			m_connection = conn;
			m_messageSender = messageSender;
			m_xslTransform = new XslTransform();
			m_xmlResolver = new XmlUrlResolver();
			m_xslTransform.Load(new XmlTextReader(sXsltFileName), m_xmlResolver , this.GetType().Assembly.Evidence) ;
		}

		private void fillMessageBodyAndSubject(EventNotificationMessage message, XmlDocument xmlMessage)
		{


			StringBuilder transformationResult = new StringBuilder();
			using(TextWriter w = new StringWriter(transformationResult))
			{
				m_xslTransform.Transform(xmlMessage, m_xsltArguments, w, m_xmlResolver);
			}

			//TODO: Надо как-то извлекать Subject!
			//		Один из вариантов - искать <title>	
			message.HtmlBody = transformationResult.ToString();
			// Извлечём Title:
			Match match = m_titleExtractionRegex.Match(message.HtmlBody);
			message.Subject = match.Success ? match.Value : DEFAULT_SUBJECT;
			// Почистим от пробелов и декодируем
			message.Subject = System.Web.HttpUtility.HtmlDecode(m_titleCleanUpRegex.Replace(message.Subject, " "));


		}

		private void reScheduleDigest()
		{
			m_dtDigestSchedule = DateTime.Now.AddHours(m_nDigestInterval);
		}

		private bool itsTimeToSendDigest
		{
			get
			{
				return DateTime.Now > m_dtDigestSchedule;
			}
		}

		/// <summary>
		/// Отсылает сообщения
		/// </summary>
		/// <returns>Количество отосланных писем</returns>
		public int Run()
		{
			int n = 0;
			if(itsTimeToSendDigest)
			{
				n = generateDigestMessages();
				if(n>0)
					return n;
				else
					reScheduleDigest();
			}
			return generateInstantMessages();
		}

		/// <summary>
		/// Рассылает дайджест-сообщения
		/// </summary>
		/// <returns>Количество отосланных писем</returns>
		private int generateDigestMessages()
		{
			EventNotificationMessage msg = new EventNotificationMessage();
			XmlDocument digest = new XmlDocument();
			// Создадим элемент
			digest.AppendChild(digest.CreateElement("digest"));
			// Навесим дату
			digest.DocumentElement.SetAttribute("createdAt", XmlConvert.ToString(DateTime.Now));
			// let's start transaction
			using(SqlTransaction tran =	m_connection.BeginTransaction( IsolationLevel.Serializable))
			{
				try
				{
					using(SqlCommand cmd = m_connection.CreateCommand())
					{
						cmd.Transaction = tran;
						//TODO: А может это счастье в ХП вынести?
						cmd.CommandText =
                            @"
SET NOCOUNT ON
SET ROWCOUNT 0

SET DEADLOCK_PRIORITY LOW

-- Вход в критическую секцию
EXEC sp_getapplock @Resource = 'generateDigestMessages', @LockMode = 'Exclusive';

SELECT TOP " + m_nMaxMessagesPerDigest.ToString() + @"
d.[ObjectID], 
d.[EMail], 
d.[EventToDeliver] 
INTO #t
FROM 
dbo.[EventNotificationDelivery] d with (nolock)
INNER JOIN dbo.[EventLog] e  with (nolock) ON e.[ObjectID]=d.[EventToDeliver]
WHERE
d.[MustIncludeInDigest]!=0
AND d.[EMail] = (SELECT TOP 1 [EMail] FROM dbo.[EventNotificationDelivery] with (nolock) WHERE [MustIncludeInDigest]!=0)
ORDER BY
e.[Occured]


SELECT TOP 1 [EMail] FROM #t

SELECT 
e.[ObjectID], 
e.[EventType], 
e.[Occured], 
e.[CreatedBy],
u.[EMail],
u.LastName + ' ' +
u.FirstName +  
IsNull(' ' + u.MiddleName, '') [UserFIO],
e.[EventXML] 
FROM 
dbo.[EventLog] e with (nolock)
LEFT JOIN dbo.[Employee] u  with (nolock) ON u.[ObjectID]=e.[CreatedBy]
WHERE
e.[ObjectID] IN (
	SELECT
		[EventToDeliver]
	FROM
		#t
)
ORDER BY
e.[Occured]

UPDATE dbo.[EventNotificationDelivery]
SET [MustIncludeInDigest]=0
from dbo.[EventNotificationDelivery] as recE with (xlock)
inner join #t as recT on recT.ObjectID = recE.ObjectID
WHERE [MustSendImmediatly]!=0

DELETE 
From dbo.[EventNotificationDelivery]
From dbo.[EventNotificationDelivery] as recE
join #t as recT on recT.ObjectID = recE.ObjectID
where [MustSendImmediatly]=0
DROP TABLE #t
";


						//Guid current
						using(SqlDataReader r = cmd.ExecuteReader())
						{
							if(r.Read())
								msg.AddRecipient(r.GetString(0));
							else
								return 0;
							r.NextResult();
							while(r.Read())
							{
								XmlDocument doc = createEventXml(r);
								digest.DocumentElement.AppendChild(digest.ImportNode(doc.DocumentElement, true));
							}
						}
					}
					fillMessageBodyAndSubject(msg,digest);
					m_messageSender.Send(new EventNotificationMessage[]{msg});
					tran.Commit();
					return 1;
				}
				catch
				{
					try { tran.Rollback(); } catch { }
					throw;
				}
			}
		}

		private static XmlDocument createEventXml(SqlDataReader dataReader)
		{
			XmlDocument doc = new XmlDocument();
			doc.LoadXml(dataReader.GetString(dataReader.GetOrdinal("EventXML")));
			int nCreatedBy = dataReader.GetOrdinal("CreatedBy");
			if(!dataReader.IsDBNull(nCreatedBy))
			{
				doc.DocumentElement.SetAttribute("event-creator-id", XmlConvert.ToString(dataReader.GetGuid(nCreatedBy)));
				doc.DocumentElement.SetAttribute("event-creator-fio", dataReader.GetString(dataReader.GetOrdinal("UserFIO")));
				int nEMail = dataReader.GetOrdinal("EMail");
				if(!dataReader.IsDBNull(nEMail))
				{
					doc.DocumentElement.SetAttribute("event-creator-email", dataReader.GetString(nEMail));
				}				
			}
			doc.DocumentElement.SetAttribute("event-type", XmlConvert.ToString(dataReader.GetInt32(dataReader.GetOrdinal("EventType"))));
			doc.DocumentElement.SetAttribute("event-occured", XmlConvert.ToString(dataReader.GetDateTime(dataReader.GetOrdinal("Occured"))));
			return doc;
		}

		/// <summary>
		/// Рассылает мнгновенные сообщения
		/// </summary>
		/// <returns>Количество отосланных писем</returns>
		private int generateInstantMessages()
		{
			IDictionary ht = new Hashtable( m_nMessagesPerOnce);
			EventNotificationMessage[] messages;

			// let's start transaction
			using(SqlTransaction tran =	m_connection.BeginTransaction( IsolationLevel.Serializable))
			{
				try
				{
					using(SqlCommand cmd = m_connection.CreateCommand())
					{
						cmd.Transaction = tran;
						//TODO: А может это счастье в ХП вынести?
						cmd.CommandText =
                                @"
SET NOCOUNT ON
SET ROWCOUNT 0

SET DEADLOCK_PRIORITY LOW 

-- Вход в критическую секцию
EXEC sp_getapplock @Resource = 'generateInstantMessages', @LockMode = 'Exclusive';

-- Выберем несколько сообщений, подлежащих отправке
SELECT TOP " + m_nMessagesPerOnce.ToString() + @"
d.[ObjectID], 
d.[EMail], 
d.[EventToDeliver] 
INTO #t
FROM 
dbo.[EventNotificationDelivery] d with (nolock)
INNER JOIN dbo.[EventLog] e with (nolock) ON e.[ObjectID]=d.[EventToDeliver]
WHERE
d.[MustSendImmediatly]!=0
ORDER BY
e.[Occured], d.[EventToDeliver]

-- Вернем рекордсет
SELECT 	[EMail], [EventToDeliver] FROM #t

-- Вернем рекордсет из описаний сообщения
SELECT 
e.[ObjectID], 
e.[EventType], 
e.[Occured], 
e.[CreatedBy],
u.[EMail],
u.LastName + ' ' +
u.FirstName +  
IsNull(' ' + u.MiddleName, '') [UserFIO],
e.[EventXML] 
FROM 
dbo.[EventLog] e with (nolock)
LEFT JOIN dbo.[Employee] u with (nolock) ON u.[ObjectID]=e.[CreatedBy]
WHERE
e.[ObjectID] IN (
	SELECT [EventToDeliver] FROM #t
)
ORDER BY
e.[Occured]

-- Выполним сбросим флаг (т.к. мы уже отправляем)
UPDATE dbo.[EventNotificationDelivery]
SET [MustSendImmediatly]=0
from dbo.[EventNotificationDelivery] as recE with (xlock,rowlock)
inner join #t as recT on recT.ObjectID = recE.ObjectID
WHERE [MustIncludeInDigest]!=0

DELETE 
From dbo.[EventNotificationDelivery]
From dbo.[EventNotificationDelivery] as recE
inner join #t as recT on recT.ObjectID = recE.ObjectID
where [MustIncludeInDigest]=0

-- Почистим ненужные записи

-- Дропнем временную табличку
DROP TABLE #t
";


						//Guid current
						using(SqlDataReader r = cmd.ExecuteReader())
						{
							while(r.Read())
							{
								Guid eventID = r.GetGuid(1);
								if(ht.Contains(eventID))
									(ht[eventID] as ArrayList).Add(r.GetString(0));
								else
									ht.Add(eventID, new ArrayList(new string[]{r.GetString(0)}));
							}
							r.NextResult();
							messages = new EventNotificationMessage[ht.Count];
							int i=0;
							while(r.Read())
							{
								XmlDocument doc = createEventXml(r);
								EventNotificationMessage m = new EventNotificationMessage();
								m.AddRecipients(ht[r.GetGuid(0)] as ICollection);

								int nEMail = r.GetOrdinal("EMail");
								if(!r.IsDBNull(nEMail))
								{
									m.ReplyTo=r.GetString(nEMail);
								}
								fillMessageBodyAndSubject(m,doc);
								messages[i++]=m;
							}
						}
					}
					
					if(0!=messages.Length)
						m_messageSender.Send(messages);

					tran.Commit();

					return messages.Length;
				}
				catch
				{
					try { tran.Rollback(); } catch { }
					throw;
				}
			}
		}
	}
}
