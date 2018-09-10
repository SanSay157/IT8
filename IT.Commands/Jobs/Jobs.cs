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
	/// �������� �������
	/// </summary>
	internal class JobDescription
	{
		private DateTime m_dtStartTime;
		private TimeSpan m_tsPeriod;
		private string m_sCommandName;
		private string m_sDescription;

		/// <summary>
		/// ����� ������ ���������� �������
		/// </summary>
		public DateTime StartTime
		{
			get { return this.m_dtStartTime; }
		}

		/// <summary>
		/// ������ ���������� �������
		/// </summary>
		public TimeSpan Period
		{
			get { return this.m_tsPeriod; }
		}

		/// <summary>
		/// ������������ ��������� ������� ��� ����������
		/// </summary>
		public string CommandName
		{
			get { return this.m_sCommandName; }
		}

		/// <summary>
		/// ��������
		/// </summary>
		public string Description
		{
			get { return this.m_sDescription; }
		}

		/// <summary>
		/// �����������
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
	/// ������������ �������
	/// </summary>
	internal class JobsConfig : XConfigurationFile
	{
		private JobDescription[] m_aJobDescriptions;

		/// <summary>
		/// �������� �������
		/// </summary>
		public JobDescription[] JobDescriptions
		{
			get { return this.m_aJobDescriptions; }
		}

		/// <summary>
		/// �����������
		/// </summary>
		public JobsConfig()
			: base()
		{
			// ������� �������� ����������������� �����
			string sBasePath = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
			string sFileName = ConfigurationSettings.AppSettings[XConfig.DEF_APPCONFIG_KEYNAME];
			if (sFileName == null)
			{
				throw new ConfigurationException( String.Format(
					"� ���������������� ����� �� ������ �������� ��� �������� \"{0}\"",
					XConfig.DEF_APPCONFIG_KEYNAME) );
			}

			// �������� ������������� ����������������� �����
			string sFullFileName = Path.Combine(sBasePath, sFileName);
			if (!File.Exists(sFullFileName))
			{
				throw new FileNotFoundException(
					"�������� ���������������� ���� ���������� �� ������" );
			}
			
			// ������ XML � ������� ������ �������� ������
			base.load(sFullFileName);

			// ������ XML � ������� ��������� �������			
			ArrayList jobDescriptionList = new ArrayList();
			XmlNodeList xmlDescriptions = SelectNodes(@"it:app-data/it:jobs/it:job");

			foreach (XmlElement xmlDescr in xmlDescriptions)
			{
				JobDescription jobDescr = new JobDescription(xmlDescr);
				jobDescriptionList.Add(jobDescr);
			}

			// ���������� �������� ������� � �������
			this.m_aJobDescriptions = (JobDescription[]) jobDescriptionList.ToArray(typeof(JobDescription));
		}
	}

	/// <summary>
	/// ����� ���������� � ���������� �������
	/// </summary>
	internal class JobInfo
	{
		private JobDescription m_oDescription;
		private DateTime m_dtNextStartTime;

		/// <summary>
		/// �������� �������
		/// </summary>
		public JobDescription Description
		{
			get { return this.m_oDescription; }
		}

		/// <summary>
		/// ����� ���������� ������� �������
		/// </summary>
		public DateTime NextStartTime
		{
			get { return this.m_dtNextStartTime; }
		}

		/// <summary>
		/// �����������
		/// </summary>
		/// <param name="description"></param>
		public JobInfo(JobDescription description)
		{
			this.m_oDescription = description;

			// ��������� ����� ���������� ������� �������
			TimeSpan startTime = this.m_oDescription.StartTime.TimeOfDay;
			DateTime now = DateTime.Now;
			this.m_dtNextStartTime = now.Date + startTime;
			while (this.m_dtNextStartTime < now)
			{
				this.m_dtNextStartTime += this.m_oDescription.Period;
			}
		}

		/// <summary>
		/// ��������� �������
		/// </summary>
		public void RunJob()
		{
			// ����������� ����� ���������� �������
			this.m_dtNextStartTime += this.Description.Period;

			// ��������� ������� XFW
			XRequest request = new XRequest();
			request.Name = this.Description.CommandName;
			XFacade.Instance.ExecCommand(request);
		}
	}
	
	/// <summary>
	/// ���� ��������� �������
	/// </summary>
	internal class JobsLoop
	{
		/// <summary>
		/// �������, ����������� ������������ ������� �����
		/// </summary>
		private static Mutex m_RunMutex = new Mutex();

		private bool m_bStopped = false;
		private JobsConfig m_oConfig;
		private JobInfo[] m_Jobs;

		/// <summary>
		/// �����������
		/// </summary>
		public JobsLoop()
		{
			// ������ ������������
			this.m_oConfig = new JobsConfig();
		}

		/// <summary>
		/// ��������� ���� ���������� �������
		/// </summary>
		/// <remarks>��������!!! ������ ����� �������� "�����������". �������� ������ ����� ���������� ������ �� ���������� ������</remarks>
		/// <returns>true, ���� ���� ����������; false, ���� � ������ ������� ��� ������� ������ ��������� ����� ��� �� ���������� �� ���� �������</returns>
		public bool Run()
		{
			// ������� ��������� �������
			if (!m_RunMutex.WaitOne(TimeSpan.FromTicks(0), false))
				return false;

			// ���� �� ���������� �� ���� �������, ������ �� ������
			if (this.m_oConfig.JobDescriptions.Length == 0)
				return false;

			// ��������� ������ �������
			ArrayList jobs = new ArrayList();
			foreach (JobDescription descr in this.m_oConfig.JobDescriptions)
			{
				jobs.Add(new JobInfo(descr));
			}
			this.m_Jobs = (JobInfo[]) jobs.ToArray(typeof(JobInfo));

			// ��������, ��� ���� �������
			lock (this)
			{
				this.m_bStopped = false;	
			}

			// ������ ����, ���� �� ����� �������� �����
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

			// ����������� �������, ����� ����� ���� ����������� �����
			m_RunMutex.ReleaseMutex();

			return true;
		}

		/// <summary>
		/// ������������� ���� ���������� �������
		/// </summary>
		public void Stop()
		{
			lock (this)
			{
				this.m_bStopped = true;
			}
		}

		/// <summary>
		/// ���������, ���������� �� ���� ��� ���
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
		/// ���������� ������ �������, ������� ����� ��������� � ������� ������
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
		/// ���������� ����� ���������� ���������� (����������) �������
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
