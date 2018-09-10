//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;

namespace Croc.IncidentTracker.Core
{
	/// <summary>
	/// ��������� ��� ������������� ���������� ApplicationSettings
	/// </summary>
	public struct ApplicationSettingsInitializationParams
	{
		/// <summary>
		/// ���� ��������� ����������� ������� ������������ ��������
		/// </summary>
		public DateTime GlobalBlockPeriodDate;
	}

	/// <summary>
	/// ����� ��� �������� ���������� �������� ����������.
	/// �������� ���������������� � ����������� ������ ���������� (Handler_OnApplicationStart)
	/// </summary>
	public class ApplicationSettings
	{
		private static ApplicationSettings m_Instance = new ApplicationSettings();
		private bool m_bInitialized;
		private DateTime m_dtGlobalBlockPeriodDate;

		public static void Initialize(ApplicationSettingsInitializationParams initParams)
		{
			m_Instance.m_bInitialized = true;
			m_Instance.m_dtGlobalBlockPeriodDate = initParams.GlobalBlockPeriodDate;
		}

		/// <summary>
		/// ���������� ���� ��������� ����������� ������� ������������ ��������
		/// </summary>
		public static DateTime GlobalBlockPeriodDate
		{
			get
			{
				if (!m_Instance.m_bInitialized)
					throw new InvalidOperationException("��������� ApplicationSettings �� ��� ���������������");
				return m_Instance.m_dtGlobalBlockPeriodDate;
			}
		}
	}
}
