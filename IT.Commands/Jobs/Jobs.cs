using System;
using System.Collections;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Threading;
using System.Xml;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Core.Configuration;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.XUtils;

namespace Croc.IncidentTracker.Jobs
{
	/// <summary>
	/// Описание задания
	/// </summary>
	internal class JobDescription
	{
		private DateTime m_dtStartTime;
		private TimeSpan m_tsPeriod;
		private string m_sCommandName;
		private string m_sDescription;

		/// <summary>
		/// Время начала выполнения задания
		/// </summary>
		public DateTime StartTime
		{
			get { return this.m_dtStartTime; }
		}

		/// <summary>
		/// Период выполнения задания
		/// </summary>
		public TimeSpan Period
		{
			get { return this.m_tsPeriod; }
		}

		/// <summary>
		/// Наименование серверной команды для выполнения
		/// </summary>
		public string CommandName
		{
			get { return this.m_sCommandName; }
		}

		/// <summary>
		/// Описание
		/// </summary>
		public string Description
		{
			get { return this.m_sDescription; }
		}

		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="xmlDescription"></param>
		public JobDescription(XmlElement xmlDescription)
		{
			string sStartTime = xmlDescription.GetAttribute("start-time");
			this.m_dtStartTime = sStartTime.Length == 0 ?
				DateTime.Now :
				DateTime.Parse(sStartTime);
			
			string sPeriod = xmlDescription.GetAttribute("period");
			this.m_tsPeriod = sPeriod.Length == 0 ?
				TimeSpan.FromDays(1) :
				TimeSpan.FromMinutes( Double.Parse(sPeriod, NumberFormatInfo.InvariantInfo) );
			
			this.m_sCommandName = xmlDescription.GetAttribute("command-name");
			
			this.m_sDescription = xmlDescription.GetAttribute("description");
		}
	}
	
	/// <summary>
	/// Конфигурация заданий
	/// </summary>
	internal class JobsConfig : XConfigurationFile
	{
		private JobDescription[] m_aJobDescriptions;

		/// <summary>
		/// Описания заданий
		/// </summary>
		public JobDescription[] JobDescriptions
		{
			get { return this.m_aJobDescriptions; }
		}

		/// <summary>
		/// Конструктор
		/// </summary>
		public JobsConfig()
			: base()
		{
			// получим название конфигурационного файла
			string sBasePath = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
			string sFileName = ConfigurationSettings.AppSettings[XConfig.DEF_APPCONFIG_KEYNAME];
			if (sFileName == null)
			{
				throw new ConfigurationException( String.Format(
					"В конфигурационном файле не задано значение для элемента \"{0}\"",
					XConfig.DEF_APPCONFIG_KEYNAME) );
			}

			// проверим существование конфигурационного файла
			string sFullFileName = Path.Combine(sBasePath, sFileName);
			if (!File.Exists(sFullFileName))
			{
				throw new FileNotFoundException(
					"Основной конфигурационный файл приложения не найден" );
			}
			
			// читаем XML с помощью метода базового класса
			base.load(sFullFileName);

			// парсим XML и создаем описаниея заданий			
			ArrayList jobDescriptionList = new ArrayList();
			XmlNodeList xmlDescriptions = SelectNodes(@"it:app-data/it:jobs/it:job");

			foreach (XmlElement xmlDescr in xmlDescriptions)
			{
				JobDescription jobDescr = new JobDescription(xmlDescr);
				jobDescriptionList.Add(jobDescr);
			}

			// запоминаем описания заданий в массиве
			this.m_aJobDescriptions = (JobDescription[]) jobDescriptionList.ToArray(typeof(JobDescription));
		}
	}

	/// <summary>
	/// Класс информации о выполнении задания
	/// </summary>
	internal class JobInfo
	{
		private JobDescription m_oDescription;
		private DateTime m_dtNextStartTime;

		/// <summary>
		/// Описание задания
		/// </summary>
		public JobDescription Description
		{
			get { return this.m_oDescription; }
		}

		/// <summary>
		/// Время следующего запуска задания
		/// </summary>
		public DateTime NextStartTime
		{
			get { return this.m_dtNextStartTime; }
		}

		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="description"></param>
		public JobInfo(JobDescription description)
		{
			this.m_oDescription = description;

			// вычисляем время следующего запуска задания
			TimeSpan startTime = this.m_oDescription.StartTime.TimeOfDay;
			DateTime now = DateTime.Now;
			this.m_dtNextStartTime = now.Date + startTime;
			while (this.m_dtNextStartTime < now)
			{
				this.m_dtNextStartTime += this.m_oDescription.Period;
			}
		}

		/// <summary>
		/// Выполняет задание
		/// </summary>
		public void RunJob()
		{
			// увеличиваем время следующего запуска
			this.m_dtNextStartTime += this.Description.Period;

			// запускаем команду XFW
			XRequest request = new XRequest();
			request.Name = this.Description.CommandName;
			XFacade.Instance.ExecCommand(request);
		}
	}
	
	/// <summary>
	/// Цикл обработки заданий
	/// </summary>
	internal class JobsLoop
	{
		/// <summary>
		/// Мьютекс, управляющий возможностью запуска цикла
		/// </summary>
		private static Mutex m_RunMutex = new Mutex();

		private bool m_bStopped = false;
		private JobsConfig m_oConfig;
		private JobInfo[] m_Jobs;

		/// <summary>
		/// Конструктор
		/// </summary>
		public JobsLoop()
		{
			// читаем конфигурацию
			this.m_oConfig = new JobsConfig();
		}

		/// <summary>
		/// Запускает цикл выполнения заданий
		/// </summary>
		/// <remarks>ВНИМАНИЕ!!! Данный метод является "бесконечным". Вызывать данный метод необходимо только из отдельного потока</remarks>
		/// <returns>true, если цикл запускался; false, если в момент запуска был запущен другой экземпляр цикла или не определено ни одно задание</returns>
		public bool Run()
		{
			// пробуем захватить мьютекс
			if (!m_RunMutex.WaitOne(TimeSpan.FromTicks(0), false))
				return false;

			// если не определено ни одно задание, ничего не делаем
			if (this.m_oConfig.JobDescriptions.Length == 0)
				return false;

			// формируем список заданий
			ArrayList jobs = new ArrayList();
			foreach (JobDescription descr in this.m_oConfig.JobDescriptions)
			{
				jobs.Add(new JobInfo(descr));
			}
			this.m_Jobs = (JobInfo[]) jobs.ToArray(typeof(JobInfo));

			// помечаем, что цикл запущен
			lock (this)
			{
				this.m_bStopped = false;	
			}

			// крутим цикл, пока не будет останова извне
			while (!IsStopped)
			{
				JobInfo[] jobsToRun = getJobsToRun();
				foreach (JobInfo job in jobsToRun)
				{
					job.RunJob();
				}

				DateTime next = getNextJobTime();
				DateTime now = DateTime.Now;
				if (next > now)
				{
					Thread.Sleep(next-now);
				}
			}

			// освобождаем мьютекс, чтобы можно было запускаться снова
			m_RunMutex.ReleaseMutex();

			return true;
		}

		/// <summary>
		/// Останавливает цикл выполнения заданий
		/// </summary>
		public void Stop()
		{
			lock (this)
			{
				this.m_bStopped = true;
			}
		}

		/// <summary>
		/// Проверяет, остановлен ли цикл или нет
		/// </summary>
		public bool IsStopped
		{
			get
			{
				bool bStopped;
				lock (this)
				{
					bStopped = this.m_bStopped;
				}
				return bStopped;
			}
		}
		
		/// <summary>
		/// Возвращает массив заданий, которые нужно выполнить в текущий момент
		/// </summary>
		/// <returns></returns>
		private JobInfo[] getJobsToRun()
		{
			ArrayList jobs = new ArrayList();
			foreach (JobInfo job in this.m_Jobs)
			{
				if (job.NextStartTime <= DateTime.Now)
				{
					jobs.Add(job);
				}
			}
			return (JobInfo[]) jobs.ToArray(typeof(JobInfo));
		}

		/// <summary>
		/// Возвращает время выполнения следующего (ближайшего) задания
		/// </summary>
		/// <returns></returns>
		private DateTime getNextJobTime()
		{
			DateTime dt = DateTime.MaxValue;
			foreach (JobInfo job in this.m_Jobs)
			{
				if (job.NextStartTime < dt)
				{
					dt = job.NextStartTime;
				}
			}
			return dt;
		}
	}
}
