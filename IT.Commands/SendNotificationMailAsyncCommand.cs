//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Xml;
using Croc.IncidentTracker.Messaging;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{

	/// <summary>
	/// ������� �������� ��������� (�� ����� ���� ������ �� ������)
	/// </summary>
	[XTransaction(XTransactionRequirement.NotSupported)]
	public class FakeSendNotificationMailAsyncCommand : XCommand
	{			 
		/// <summary>
		/// ���������� �������
		/// </summary>
		public override XResponse Execute( XRequest request, IXExecutionContext context )
		{
			return new XResponse();
		}
	}


	/// <summary>
	/// ������� �������� ���������
	/// </summary>
	[XTransaction(XTransactionRequirement.NotSupported)]
	public class SendNotificationMailAsyncCommand : XCommand
	{
		private static readonly BooleanSwitch mySwitch=new BooleanSwitch("MessagingErrors", "MessagingErrors switch");
		private static int runningInstanceCount=0;

		/// <summary>
		/// ���������� �������
		/// </summary>
		public override XResponse Execute( XRequest request, IXExecutionContext context)
		{
			Trace.WriteLine("SendNotificationMailAsyncCommand::Enter");
			try
			{
				if(!context.AsyncExecutionMode)
					throw new ApplicationException("��� ������� ������ ����������� ������ � ����������� ������");
				// ������ ���� ������������
				string sSMTPHost = context.Config.SelectNodeTextValue("it:app-data/it:messaging/it:smtp-host");
				int nSMTPPort = 25;
				if (!string.IsNullOrEmpty(context.Config.SelectNodeTextValue("it:app-data/it:messaging/it:smtp-port")))
					nSMTPPort = int.Parse(context.Config.SelectNodeTextValue("it:app-data/it:messaging/it:smtp-port"));
				int nSMTPTimeout = 300;
				if (!string.IsNullOrEmpty(context.Config.SelectNodeTextValue("it:app-data/it:messaging/it:smtp-timeout")))
					nSMTPTimeout = int.Parse(context.Config.SelectNodeTextValue("it:app-data/it:messaging/it:smtp-timeout"));
				string sMailFrom = context.Config.SelectNodeTextValue("it:app-data/it:messaging/it:mail-from");
				string sAppInternalUri = context.Config.SelectNodeTextValue("it:app-data/it:system-location/it:internal-base-uri");
				string sAppExternalUri = context.Config.SelectNodeTextValue("it:app-data/it:system-location/it:external-base-uri");
				string sXslFileName = context.Config.SelectNodeTextValue("it:app-data/it:messaging/it:stylesheet");
				sXslFileName = Path.Combine(context.Config.BaseConfigPath, sXslFileName );
				int nDigestInterval = XmlConvert.ToInt32(context.Config.SelectNodeTextValue("it:app-data/it:messaging/it:digest-interval")); 
				int nMaxMessagesPerDigest = XmlConvert.ToInt32(context.Config.SelectNodeTextValue("it:app-data/it:messaging/it:max-messages-per-digest")); 
				int nMaxMessagesPerOnce = XmlConvert.ToInt32(context.Config.SelectNodeTextValue("it:app-data/it:messaging/it:max-messages-per-once")); 
				int nIdleTime = XmlConvert.ToInt32(context.Config.SelectNodeTextValue("it:app-data/it:messaging/it:idle-time")); 
				string sTestEmail = context.Config.SelectNodeTextValue("it:app-data/it:messaging/it:test-email");


				Croc.IncidentTracker.Messaging.MessageGenerator gen = new MessageGenerator( 
					new ApplicationInstallation[]
				{
					new ApplicationInstallation("Internal", sAppInternalUri), 
					new ApplicationInstallation("External", sAppExternalUri)
				} ,
					sXslFileName, 
					nDigestInterval, 
					nMaxMessagesPerDigest, 
					nMaxMessagesPerOnce, 
					context.Connection.Connection as SqlConnection, 
					new MessageMailer(
						sSMTPHost, nSMTPPort, nSMTPTimeout, sMailFrom, sTestEmail
						)
					);

				try
				{
					// ����� ������� ����� ����������� ������ ����!
					if(Interlocked.Increment(ref runningInstanceCount)>1)
						throw new ApplicationException("������� �������� ��������� ����� ���� �������� ������ � ����� ����������");

					Trace.WriteLine("SendNotificationMailAsyncCommand::Start");

					// ����� ����
					for(;;)
					{
						int nSentMessages=0;
						try
						{
							nSentMessages = gen.Run();
						}
						catch(Exception e)
						{
							if(e is ThreadAbortException)
							{
								break;
							}
							else
							{
								if(mySwitch.Enabled)
									Trace.WriteLine(DateTime.Now + " - ������ ��� �������� ��������� " + Environment.NewLine + e);
							}
						}
						try
						{
                           
						//	context.Suspend(new XResponse(), new TimeSpan(0,0, nSentMessages>0?0:nIdleTime,1,0));
						}
						catch{};
					}
				}
				finally
				{
					Interlocked.Decrement(ref runningInstanceCount);
				}
			}
			catch(Exception ex)
			{
				Trace.WriteLine(ex.ToString());
				throw;
			}

			return new XResponse();
		}
	}
}
