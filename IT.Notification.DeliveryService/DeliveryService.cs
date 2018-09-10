using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using System.Configuration;
using System.IO;

using System.Threading;

using Croc.IncidentTracker.Commands;
using Croc.IncidentTracker.Messaging;

namespace Croc.IncidentTracker.Notification.DeliveryService
{
	/// <summary>
	/// Класс сервиса рассылки уведомлений
	/// </summary>
	public partial class DeliveryService : ServiceBase
	{
		private const int shutdownTimeout = 60 * 1000;

		// лок для организации режима бездействия
		private readonly object idleLock = new object();
		// рабочий поток
		private Thread worker = null;
		// флаг остановки
		private bool stopped = true;

		public DeliveryService()
		{
			InitializeComponent();
		}

		protected override void OnStart(string[] args)
		{
			if (worker != null) OnStop();
			stopped = false;
			try
			{
				worker = new Thread(Process);
				worker.Start();
			}
			catch { stopped = true; throw; }
		}

		protected override void OnStop()
		{
			stopped = true;
			if (worker != null)
			{
				this.RequestAdditionalTime(shutdownTimeout);
				lock (idleLock) { Monitor.Pulse(idleLock); }
				if (!worker.Join(shutdownTimeout)) worker.Abort();
				worker = null;
			}
		}

		/// <summary>
		/// Рабочий поток
		/// </summary>
		public void Process()
		{
			var traceSource = new TraceSource("DeliveryService");

			while (!stopped)
				try
				{
					// откроем подключение к БД
					using (var connection
						= new SqlConnection(
							ConfigurationManager.ConnectionStrings[
								"Croc.IncidentTracker.Notification.DeliveryService.Properties.Settings.IT"
								].ConnectionString))
					{
						connection.Open();

						// создадим экземпляр рассылщика уведомлений
						var messageGenerator = new MessageGenerator(
							new ApplicationInstallation[]
						{
							new ApplicationInstallation("Internal", Properties.Settings.Default.InternalUri.ToString()),	
							new ApplicationInstallation("External", Properties.Settings.Default.ExternalUri.ToString())	
						},
							Path.Combine(AppDomain.CurrentDomain.BaseDirectory, Properties.Settings.Default.XslFormatterFilePath),
							Properties.Settings.Default.DigestInterval,
							Properties.Settings.Default.MaxMessagesPerDigest,
							Properties.Settings.Default.MaxMessagesPerOnce,
							connection,
							new MessageMailer(
								Properties.Settings.Default.SMTPHost,
								Properties.Settings.Default.SMTPPort,
								Properties.Settings.Default.SMTPTimeout,
								Properties.Settings.Default.MailFrom,
								Properties.Settings.Default.TestMail
								)
							);

						try { while (!stopped && messageGenerator.Run() > 0); }
						catch (ThreadAbortException) { }
						catch (Exception e)
						{
							traceSource.TraceEvent(
							TraceEventType.Error, 0,
							"Во время работы сервиса возникло исключение:\n{0}",
							e);
						}
						if (!stopped) lock (idleLock) { Monitor.Wait(idleLock, Properties.Settings.Default.DeliveryIdle); }
					}
				}
				catch (ThreadAbortException) { }
				catch (Exception e)
				{
					traceSource.TraceEvent(
						TraceEventType.Error, 0,
						"Во время работы сервиса возникло исключение:\n{0}",
						e);
					if (!stopped) lock (idleLock) { Monitor.Wait(idleLock, Properties.Settings.Default.DeliveryIdle); }
				}
		}
	}
}
