//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������������, �������� "����", ��������������� ������� �������� ��� 
	/// ���������������� �������; ����� "����" - ����� �������� ���-�� 
	/// ������������ �������: ���� ��������� �����, ��"����" �������, ���� 
	/// �� ����� - �� �����; ���� ������� ��� - �� "�������". ���������� �� 
	/// �������� ���������� ������� � ������������ ��� ������� ������� �����
	/// </summary>
	[Serializable]
	public enum ExpensesCompleteness 
	{
		/// <summary>
		/// ������� - �������� ������ ������������
		/// </summary>
		RedZone = 1,
		
		/// <summary>
		/// ����� - �������� ���������� �������� 
		/// </summary>
		BlueZone = 2,
		
		/// <summary>
		/// ������� - ������ ���������� ��������
		/// </summary>
		GreenZone = 3
	}


	/// <summary>
	/// ������������� ����������������� ��������� �������
	/// ��������� ��������� ������������������ ����� ���������� �����, � ��� ��
	/// ������ ������ ���� / ����� / �����. ��������� ������ ��� ��������� 
	/// ���������� ������������� ������� � ���������������� ��������� (��������,
	/// "2 ��� 5 ����� 41 ������")
	/// </summary>
	[Serializable]
	public class DurationInfo 
	{
		/// <summary>
		/// ����������� ����� ��������� �� ������
		/// </summary>
		const string DEF_ERR_NULL_VALUE = "��������� �������� �� ����� ���� NULL";
		const string DEF_ERR_CANNOT_BE_SET = "�������� �������� �� ����� ���� �������� ����";
		
		#region ���������� ���������� � ������ ������
		
		/// <summary>
		/// ����������������� �������, � ������� (�.�. ����������� ��������� 
		/// ��� ��������� ������������� ������ � �������)
		/// </summary>
		private int m_nFullDuration = 0;
		
		/// <summary>
		/// ����������������� �������� ���: ���� ����� ��������� ������� ���� 
		/// (�.�. 8/10 �����), � ����� ������ ����� - 24 ���� - �������� �� 
		/// ���������; �������� �������� � �������, � � ����� ������ ����� 
		/// ����������� ��� ������� ����������
		/// </summary>
		private int m_nWorkDayDuration = 24 * 60; // 24 ���� �� 60 �����

		/// <summary>
		/// ������ ���������� ���� � �������� �������; ������ �������� ������� �� 
		/// "����������������� �������� ���": ���� ����� ��������� ������� ���� 
		/// (�.�. 8/10 �����), � ����� ������ ����� - 24 ����; 
		/// </summary>
		private int m_nDays;

		/// <summary>
		/// ������ ���������� ����� � �������� �������, �� ������� �����, 
		/// ������������ ������ ��� (�.�. �������� � m_nDays); �.�. �����������
		/// ���-�� ���� � �������� ������� ������� �� "����������������� �������� 
		/// ���", �� � ������� � ����� ��� �� �������
		/// </summary>
		private int m_nHours; 
		
		/// <summary>
		/// ���-�� ����� � �������� �������, ���������� ��� ������ ������� ����� 
		/// ���� (m_nDays) � ����� (m_nHours)
		/// </summary>
		private int m_nMinutes;

		/// <summary>
		/// ���������� �����, ��������������� �������� ���������� ��������� ������ �
		/// ����������� �� �������� ����������������� ������� (m_nFullDuration)
		/// � "����������������� �������� ���" (m_nWorkDayDuration)
		/// </summary>
		private void convertDuration() 
		{
			m_nDays = m_nHours = m_nMinutes = 0;

			m_nMinutes = m_nFullDuration % 60;
			m_nHours = ((m_nFullDuration - m_nMinutes) % m_nWorkDayDuration) / 60;
			m_nDays = (m_nFullDuration - m_nMinutes - 60 * m_nHours) / m_nWorkDayDuration;
		}
		

		/// <summary>
		/// ����� ������� ��� ���������� �������������� ��������
		/// </summary>
		/// <param name="nValue">�������� </param>
		/// <param name="sSingleNominativ">�������, � ��. �����, ������������ ����� (nominativus)</param>
		/// <param name="sSingleGenitiv">�������, � ��. �����, ����������� ����� (genitivus)</param>
		/// <param name="sPluralGenitiv">������� �� ����. �����, ����������� ����� (genitivus)</param>
		/// <returns>������ � ��������</returns>
		private string getLabelString( int nValue, string sSingleNominativ, string sSingleGenitiv, string sPluralGenitiv ) 
		{
			if ( null==sSingleNominativ )
				throw new ArgumentNullException( DEF_ERR_NULL_VALUE, "sSingleNominativ" );
			if ( null==sSingleGenitiv )
				throw new ArgumentNullException( DEF_ERR_NULL_VALUE, "sSingleGenitiv" );
			if ( null==sPluralGenitiv )
				throw new ArgumentNullException( DEF_ERR_NULL_VALUE, "sPluralGenitiv" );
			
			int nProbedValue = nValue % 100;
			
			if ( nProbedValue > 4 && nProbedValue < 20 )
				return sPluralGenitiv;
			else
			{
				nProbedValue = nProbedValue % 10;
				if ( 1 == nProbedValue )
					return sSingleNominativ;
				else if (nProbedValue > 1 && nProbedValue < 5)
					return sSingleGenitiv;
				else
					return sPluralGenitiv;
			}
		}
		
		#endregion

		/// <summary>
		/// ����������� �� ���������
		/// ��������� ��� ���������� ��-������������
		/// </summary>
		public DurationInfo() 
		{
			Duration = 0;
		}


		/// <summary>
		/// ����������������� �������, � ������� (�.�. ����������� ��������� 
		/// ��� ��������� ������������� ������ � �������). ��� ��������� ��������
		/// �������� ������������� ���������� �������� ������� Days, Hours, 
		/// Minutes, DaysString, HoursString, MinutesString � DurationString
		/// </summary>
		public int Duration 
		{
			get { return m_nFullDuration; }	
			set
			{
				m_nFullDuration = value;
				// ��������� �������� ���� ��������� ��������
				convertDuration();
			}
		}

		
		/// <summary>
		/// ����������������� �������� ���: ���� ����� ��������� ������� ���� 
		/// (�.�. 8/10 �����), � ����� ������ ����� - 24 ���� - �������� �� 
		/// ���������; �������� �������� � �������, � � ����� ������ ����� 
		/// ����������� ��� ������� ����������. 
		/// ��� ��������� �������� �������� ������������� ���������� �������� 
		/// ������� Days, Hours, Minutes, DaysString, HoursString, MinutesString
		/// � DurationString.
		/// ��������� �������� ������ ���� ������ 0 � ������ ��� ����� 24*60.
		/// </summary>
		public int WorkDayDuration 
		{
			get { return m_nWorkDayDuration; }
			set
			{
				if (0==value || value > 24*60)
					throw new ArgumentException( "�������� �������� WorkDayDuration ������ ���� ������ 0 � ������ ��� ����� 24*60", "WorkDayDuration");
				m_nWorkDayDuration = value;
				// ��������� �������� ���� ��������� ��������
				convertDuration();
			}
		}


		/// <summary>
		/// ������ ���������� ���� � �������� �������; ������ �������� ������� �� 
		/// "����������������� �������� ���": ���� ����� ��������� ������� ���� 
		/// (�.�. 8/10 �����), � ����� ������ ����� - 24 ����; 
		/// </summary>
		public int Days 
		{
			get { return m_nDays; }
			set
			{
				// ���������� ���� �������� ������; set-����������� ����������
				// ��� ����������� ��������������� ������� � XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}
		
		
		/// <summary>
		/// ������ ���������� ����� � �������� �������, �� ������� �����, 
		/// ������������ ������ ��� (�.�. �������� � Days); �.�. �����������
		/// ���-�� ���� � �������� ������� ������� �� "����������������� �������� 
		/// ���", �� � ������� � ����� ��� �� �������
		/// </summary>
		public int Hours 
		{
			get { return m_nHours; }
			set
			{
				// ���������� ���� �������� ������; set-����������� ����������
				// ��� ����������� ��������������� ������� � XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}

		
		/// <summary>
		/// ���-�� ����� � �������� �������, ���������� ��� ������ ������� ����� 
		/// ���� (Days) � ����� (Hours)
		/// </summary>
		public int Minutes 
		{
			get { return m_nMinutes; }
			set
			{
				// ���������� ���� �������� ������; set-����������� ����������
				// ��� ����������� ��������������� ������� � XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}

		
		/// <summary>
		/// ������� ��� ���������� ������������� ������� ���������� ����, ���� 
		/// "NNN ����"; ���� ���-�� ����������������� ��������� ������� ������ 
		/// ���, �������� ���������� ������ ������
		/// </summary>
		public string DaysLabel 
		{
			get
			{
				return (0 == m_nDays? String.Empty : getLabelString(m_nDays, "����", "���", "����") );
			}
			set
			{
				// ���������� ���� �������� ������; set-����������� ����������
				// ��� ����������� ��������������� ������� � XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}

		
		/// <summary>
		/// ������� ��� ���������� ������������� ������� ���������� �����, �� 
		/// ������� ������� ���-�� ����, ���� "NNN �����"; ���� ����������������� 
		/// ��������� ������� ������ ����, �������� ���������� ������ ������
		/// </summary>
		public string HoursLabel 
		{
			get 
			{ 
				return (0 == m_nHours? String.Empty : getLabelString(m_nHours, "���", "����", "�����") );
			}
			set
			{
				// ���������� ���� �������� ������; set-����������� ����������
				// ��� ����������� ��������������� ������� � XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}

		
		/// <summary>
		/// ������� ��� ���������� ������������� ���������� �����, �� ������� 
		/// ������� ���-�� ����� � ����, ���� "NNN �����"; ����������������� 
		/// ��������� ������� �� �������� "�������" � ������� (����� ������ 
		/// ���-�� ���� / �����), �������� ���������� ������ ������
		/// </summary>
		public string MinutesLabel 
		{
			get
			{
				return ( 0==m_nMinutes? String.Empty : getLabelString(m_nMinutes, "������", "������", "�����") );
			}	
			set
			{
				// ���������� ���� �������� ������; set-����������� ����������
				// ��� ����������� ��������������� ������� � XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}


		/// <summary>
		/// ���������� ��������� ������������� ����� �������. 
		/// ���� ������ ������� - ���������� ������ ������
		/// </summary>
		public string DurationString 
		{
			get
			{
				string sReturnValue = String.Empty;
				if (Days!=0)
					sReturnValue = Days.ToString() + " " + DaysLabel;
				if (Hours != 0)
					sReturnValue += (Days!=0? " " : "") + Hours.ToString() + " " + HoursLabel;
				if (Minutes != 0)
					sReturnValue += (Days!=0 || Hours!=0? " " : "") + Minutes.ToString() + " " + MinutesLabel;
				if (0 == sReturnValue.Length)
					sReturnValue = "0 ����";
				return sReturnValue;
			}
			set
			{
				// ���������� ���� �������� ������; set-����������� ����������
				// ��� ����������� ��������������� ������� � XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}
	}
	
	
	/// <summary>
	/// ������ �� �������� (�� ���������) ��� ������ ������� (� ����� 
	/// ��������������� ��� ������� - <seealso cref="GetExpensesDataResponse"/>)
	/// </summary>
	[Serializable]
	public class PeriodExpensesInfo 
	{
		/// <summary>
		/// ��������� ���� ������� (������������)
		/// </summary>
		public DateTime PeriodStartDate;
		
		/// <summary>
		/// �������� ���� ������� (������������); ��� ������� � ���� ���� ��������
		/// �� �������� (null)
		/// </summary>
		public DateTime PerionEndDate;

		/// <summary>
		/// ������� ������� ������� ������������������ � ���� ����; ��� ������ ��� 
		/// ���� ���� �������� ��� �������� �������� PeriodStartDate
		/// </summary>
		public bool IsOneDayPeriod;
		
		/// <summary>
		/// ������������ ������� - ��� ������������ ������������ ������ ��� "�������"
		/// </summary>
		public string PeriodName;		

		/// <summary>
		/// ��������� (���������) ���������� �������� ��� ���������������� �������
		/// </summary>
		public DurationInfo ExpectedExpense = new DurationInfo();

		/// <summary>
		/// �������� ���������� �������� ��� ���������������� �������
		/// </summary>
		public DurationInfo RealExpense = new DurationInfo();

		/// <summary>
		/// ������� �������� ��� ���������������� �������
		/// </summary>
		public DurationInfo RemainsExpense = new DurationInfo();

		/// <summary>
		/// "����", ��������������� ������� �������� ��� ���������������� �������
		/// </summary>
		public ExpensesCompleteness Completeness;
	}


	/// <summary>
	/// ��������� �������� ��������� ������, ������������ �� ������ �������� ��������
	/// (������������� HTC-����������� it-TimingPanel.htc)
	/// </summary>
	[Serializable]
	public class GetExpensesDataResponse : XResponse 
	{
		/// <summary>
		/// ������������� ���������� (�� ������������!) ��� �������� 
		/// ���� �������� ��� ������ �� ��������:
		/// </summary>
		public Guid EmployeeID;
		
		/// <summary>
		/// ���������� � �������� �� ���������� �����
		/// </summary>
		public PeriodExpensesInfo PreviousMonth = new PeriodExpensesInfo();
		
		/// <summary>
		/// ���������� � �������� �� ������� �����
		/// </summary>
		public PeriodExpensesInfo CurrentMonth = new PeriodExpensesInfo();
		
		/// <summary>
		/// ���������� � �������� �� ������� ����
		/// </summary>
		public PeriodExpensesInfo CurrentDay = new PeriodExpensesInfo();
	}
}
