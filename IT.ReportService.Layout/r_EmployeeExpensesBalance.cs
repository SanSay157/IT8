//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
// ��� ������������ ������ "��������� ������ �������������"
//******************************************************************************
using System;
using System.Data;
using System.Text;
using Croc.IncidentTracker.Utility;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Reports
{
	/// <summary>
	/// ���������� ������ "��������� ������ �������������"
	/// </summary>
	public class r_EmployeeExpensesBalance: CustomITrackerReport 
	{
       protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data)
        {
            buildThisReport(data.RepGen, data.Params, data.DataProvider, data.CustomData);
        }
		#region ��������� 
			
		/// <summary>
		/// ��������� ������ ��� ������� ���������� ������ (���� fo:link) 
		/// ������ "��������� � ������� ����������", ��� ����������� ����������,
		/// �� ���� �������� ����; ���������:
		///		{0} - Guid ����������,
		///		{1} - ����, �� ������� ����������� �����, � ������� YYYY-MM-DD,
		///		{2} - ����� ������������� ������� (0/1)
		/// </summary>
		private static string DEF_FMT_ReportRef = 
			"font-weight=\"bold\" text-decoration=\"none\" color=\"#336699\" external-destination=\"url('" + 
			"x-get-report.aspx?name=r-EmployeeExpensesList.xml" +
			"&amp;Employee={0}" +
			"&amp;IntervalBegin={1}" +
			"&amp;IntervalEnd={1}" + 
			"&amp;TimeMeasureUnits={2}" +
			"&amp;IncludeParams=1" +
			"&amp;AnalysDirection=0" +
			"&amp;NonProjectExpences=0" +
			"&amp;TimeLossReason=1" +
			"&amp;ExepenseDetalization=1" +
			"&amp;SectionByActivity=0" +
			"&amp;ExpenseType=2" +
			"&amp;Sort=0&amp;SortOrder=1" +
			"')\" show-destination=\"new\" target=\"_blank\" title=\"����� '��������� � ������� ����������'\"";
			
		#endregion

		/// <summary>
		/// ���������� �����, �������������� ��� ���������� ��������� ������
		/// </summary>
		public class ThisReportParams 
		{
			#region ��������� ������
			
			/// <summary>
			/// ������������� ����������, ��� �������� �������������� ������ ��������
			/// </summary>
			public Guid EmployeeID;

			/// <summary>
			/// ���� ������ ��������� ������� (������������)
			/// </summary>
			public object IntervalBegin;
			/// <summary>
			/// �������, ��� ���� ������ ��������� ������� ������
			/// </summary>
			public bool IsSpecifiedIntervalBegin;
			/// <summary>
			/// ���� ����� ��������� ������� (������������)
			/// </summary>
			public object IntervalEnd;
			/// <summary>
			/// �������, ��� ���� ����� ��������� ������� ������
			/// </summary>
			public bool IsSpecifiedIntervalEnd; 

			/// <summary>
			/// ������� ����������� ������ �������� ����, ��� ������� ��� ��������
			/// </summary>
			public bool ShowFreeWeekends;
			/// <summary>
			/// ����� ������������� �������: 0 - ���, ����, ������; 1 - ����. 
			/// ����� �����, ���� DataFormat ������ ����������� ������ � ����
			/// �������.
			/// </summary>
			public TimeMeasureUnits TimeMeasure;
			/// <summary>
			/// ������� ��������� � ��������� ������ �������� ����������
			/// </summary>
			public bool ShowRestrictions;

			#endregion

			#region ���. ������ �� ����������
			// ��� ������ ������������ � ������ �������� ����������

			/// <summary>
			/// ������ �������, ��� ����������
			/// </summary>
			public string FullName;
			/// <summary>
			/// ���� ������ ������ ���������� � ��������
			/// </summary>
			public DateTime WorkBeginDate;
			/// <summary>
			/// ���� ���������� ������ ���������� � ��������
			/// </summary>
			public DateTime WorkEndDate;
			/// <summary>
			/// ����� �������� ������� � ���� ���� ��� ����������
			/// </summary>
			public int WorkdayDuration;

			#endregion

			/// <summary>
			/// ������������������� �����������. �������������� �������� ������ �� 
			/// ��������� ������ ����������, �������������� � ��������� ReportParams. 
			/// </summary>
			/// <param name="Params">������ ���������, ������������ � �����</param>
			/// <param name="cn">���������� � �� (��� ��������� ������)</param>
			/// <remarks>
			/// ��� ������������� ��������� ��������� �������� ����������
			/// </remarks>
			public ThisReportParams( ReportParams Params, IReportDataProvider provider) 
			{
				// #1: ���������� ���������, �������� ����
				// ������������� ����������
				EmployeeID = (Guid)Params.GetParam("Employee").Value;

				// ������� ��� ������ � ����� ��������� �������
				IsSpecifiedIntervalBegin = !Params.GetParam("IntervalBegin").IsNull;
				IntervalBegin = ( IsSpecifiedIntervalBegin? Params.GetParam("IntervalBegin").Value : DBNull.Value );
				IsSpecifiedIntervalEnd = !Params.GetParam("IntervalEnd").IsNull;
				IntervalEnd = ( IsSpecifiedIntervalEnd? Params.GetParam("IntervalEnd").Value : DBNull.Value );

				// ������� "��������� �������� ��� ��� ��������"
				ShowFreeWeekends = ( 0!= (int)Params.GetParam("ShowFreeWeekends").Value );
				// ������������� �������
				TimeMeasure = (TimeMeasureUnits)((int)Params.GetParam("TimeMeasureUnits").Value);
				// ������� ����������� ���������� ������ � ���������
				ShowRestrictions = ( 0 != (int)Params.GetParam("ShowRestrictions").Value );

				// #2: ��������� ��� ������ �� ����������
				    using (IDataReader reader = provider.GetDataReader("dsAdditionaly",null))
					{
						if ( reader.Read() )
						{
							int nOrdinal = reader.GetOrdinal("FullName");
							FullName = reader.IsDBNull(nOrdinal)? null : reader.GetString(nOrdinal);
							
							nOrdinal = reader.GetOrdinal("WorkBeginDate");
							WorkBeginDate = reader.IsDBNull(nOrdinal) ? DateTime.MinValue : reader.GetDateTime(nOrdinal);

							nOrdinal = reader.GetOrdinal("WorkEndDate");
							WorkEndDate = reader.IsDBNull(nOrdinal) ? DateTime.MaxValue : reader.GetDateTime(nOrdinal);
							
							nOrdinal = reader.GetOrdinal("WorkdayDuration");
							WorkdayDuration = reader.IsDBNull(nOrdinal) ? 0 : reader.GetInt32(nOrdinal);
						}
					}			
			}

			
			/// <summary>
			/// ��������� ����� XSL-FO, �������������� ������ �������� ����������, � 
			/// ���������� ��� ��� ����� ������������ ������������ ������
			/// </summary>
			/// <param name="foWriter"></param>
			public void WriteParamsInHeader( XslFOProfileWriter foWriter ) 
			{
				// XSL-FO � �������� ���������� ����� �������� ����:
				StringBuilder sbBlock = new StringBuilder();
				string sParamValue;		// ��������� ������ � �������������� �������� ���������
				
				// #1: ���������:
				sbBlock.Append( getParamValueAsFoBlock( "���������", FullName ) );

				// #2: ���� ������ � ��������� ��������� �������. 
				// ����� �� ���� ��� ����� ���� �� ������; ���� ��� ���, �� 
				// � ��������� ������ ��������� ��������������� ��������:
				if ( IsSpecifiedIntervalBegin )
					sParamValue = ((DateTime)IntervalBegin).ToString("dd.MM.yyyy");
				else
					sParamValue = "�� ������, ������������ ������� - " + DateTime.Now.ToString("dd.MM.yyyy");
				sbBlock.Append( getParamValueAsFoBlock( "���� ������ �������", sParamValue ) );
				
				if ( IsSpecifiedIntervalEnd )
					sParamValue = ((DateTime)IntervalEnd).ToString("dd.MM.yyyy");
				else
					sParamValue = "�� ������, ������������ ������� - " + DateTime.Now.ToString("dd.MM.yyyy");
				sbBlock.Append( getParamValueAsFoBlock( "���� ��������� �������", sParamValue ) );

				// #3: ������� ������������� �������: 
				sParamValue = TimeMeasureUnitsItem.GetItem(TimeMeasure).Description;
				sbBlock.Append( getParamValueAsFoBlock( "������� ��������� �������", sParamValue ) );

				// #4: ������� "��������� �������� ��� ��� ��������"
				sParamValue = ShowFreeWeekends? "��" : "���";
				sbBlock.Append( getParamValueAsFoBlock( "���������� �������� ��� ��������", sParamValue ));

				
				// ����� ������������:
				foWriter.AddSubHeader( 
					@"<fo:block text-align=""left"" font-weight=""bold"">��������� ������:</fo:block>" + 
					sbBlock.ToString()
				);
			}


			/// <summary>
			/// ���������� �����, ��������� ����� XSL-FO ����� ������������� ���������,
			/// �������������� ���� "������������ ���������" � "�������� ���������".
			/// ������������ ��� ������������ XSL-FO-������ � �������� �������� ����������
			/// </summary>
			/// <param name="sParamName">������������ ���������</param>
			/// <param name="sParamValueText">����� �� ��������� ���������</param>
			/// <returns>������ � ������� XSL-FO �����</returns>
			private string getParamValueAsFoBlock(   string sParamName, string sParamValueText ) 
			{
				return String.Format(
					"<fo:block text-align=\"left\"><fo:inline>{0}: </fo:inline><fo:inline font-weight=\"bold\">{1}</fo:inline></fo:block>",
					xmlEncode(sParamName),
					xmlEncode(sParamValueText)
				);
			}
		}

		
		/// <summary>
		/// ��� ��������� ������� ������
		/// </summary>
		private ThisReportParams m_oParams;

		/// <summary>
		/// ����������������� �����������, ��������� ����������� ReportService
		/// </summary>
		/// <param name="ReportProfile"></param>
		/// <param name="ReportName"></param>
		public r_EmployeeExpensesBalance( reportClass ReportProfile, string ReportName ) 
			: base(ReportProfile, ReportName) 
		{}


		/// <summary>
		/// ����� ������������ ������. ���������� �� ReportService
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="Params"></param>
		/// <param name="Provider"></param>
		/// <param name="cn"></param>
		/// <param name="CustomData"></param>
        protected void buildThisReport(XslFOProfileWriter foWriter, ReportParams Params, IReportDataProvider Provider, object CustomData) 
		{
			// ������� ���������:
			m_oParams = new ThisReportParams( Params, Provider);
			
			// ������������ ������
            foWriter.WriteLayoutMaster();
			foWriter.StartPageSequence();
			foWriter.StartPageBody();

			// ���������
			foWriter.Header( "������ �������� ����������" );
			// ��������� ������ � ���������?
			if (m_oParams.ShowRestrictions)
				m_oParams.WriteParamsInHeader( foWriter );

            writeBody(foWriter, Provider);

			foWriter.EndPageBody();
			foWriter.EndPageSequence();
		}
	
	
		/// <summary>
		/// ������������ ����� ������� ������
		/// </summary>
		/// <param name="fo"></param>
		/// <returns>���-�� �������������� �������</returns>
		private void writeHeader( XslFOProfileWriter fo ) 
		{
            fo.TAddColumn("����", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
            fo.TAddColumn("������������<fo:block font-weight='normal'>(�����, �� ���������� / �� ���������)</fo:block>", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "30%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
			int nColIndex = fo.TAddColumn( "������ ��������", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, "TABLE_HEADER" );
            fo.TAddSubColumn(nColIndex, "�� ����", align.ALIGN_CENTER, valign.VALIGN_TOP, null, "25%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
            fo.TAddSubColumn(nColIndex, "�� ������, ������������", align.ALIGN_CENTER, valign.VALIGN_TOP, null, "25%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
		}

		
		/// <summary>
		/// ������������ "����" ������ 
		/// </summary>
		/// <param name="fo"></param>
		/// <param name="cn"></param>
		private void writeBody( XslFOProfileWriter fo, IReportDataProvider Provider ) 
		{
			// ��������� ������� ������� ������: 
			IDataReader reader;
            reader = Provider.GetDataReader("dsMain", m_oParams);
			if ( !reader.Read() )
			{
				writeEmptyBody( fo, "��� ������" );
				return;
			}

			// ��������� ��������� ������:
			fo.TStart( true, "TABLE", false );
			writeHeader( fo );

			int nOrd_CalendarDate = reader.GetOrdinal("CalendarDate");
			int nOrd_DayName = reader.GetOrdinal("DayName");
			int nOrd_IsWorkday = reader.GetOrdinal("IsWorkday");
			int nOrd_SpentForIncidents = reader.GetOrdinal("SpentForIncidents");
			int nOrd_SpentForProcesses = reader.GetOrdinal("SpentForProcesses");
            int nOrd_Rate = reader.GetOrdinal("Rate");
			
			int nQntDays = 0;
			int nQntWorkDays = 0;
			int nSumBalance = 0;
			
			for(bool bHasMoreRows = true; bHasMoreRows; bHasMoreRows = reader.Read())
			{
				// ������ ����������, ������� ������
				DateTime dtCalendarDate = reader.GetDateTime(nOrd_CalendarDate);
				bool bIsWorkDay = reader.GetBoolean(nOrd_IsWorkday);
				int nSpentForIncidents = reader.GetInt32(nOrd_SpentForIncidents);
				int nSpentForProcesses = reader.GetInt32(nOrd_SpentForProcesses);
                int nDayRate = reader.GetInt16(nOrd_Rate);
				string sCellLinkParams = String.Format(
					DEF_FMT_ReportRef,
					m_oParams.EmployeeID.ToString(),			// 0 - ������������� ����������
					dtCalendarDate.ToString("yyyy-MM-dd"),		// 1 - ���� ������ �������, ��� �� - ���� ���������
					((int)m_oParams.TimeMeasure).ToString() );	// 2 - ����� ������������� �������

				string sFullDayName = String.Format( 
					"<fo:basic-link {0}>{1}</fo:basic-link>" + 
					"<fo:block font-weight='normal'>{2}</fo:block>",
					sCellLinkParams, dtCalendarDate.ToString("dd.MM.yyyy"), 
					reader.GetString(nOrd_DayName) );

				// ����������� ��������:
				bool bIsWorkingPeriod = (dtCalendarDate >= m_oParams.WorkBeginDate && dtCalendarDate <= m_oParams.WorkEndDate);
				int nDayBalance = (nSpentForIncidents + nSpentForProcesses);
                if (bIsWorkDay && bIsWorkingPeriod) nDayBalance -= nDayRate;
				nSumBalance += nDayBalance;
				nQntDays += 1;
				nQntWorkDays += (bIsWorkingPeriod && bIsWorkDay ? 1 : 0);

				// ������� ������: ���� ��� 
				//	(�) ������� ����;
				//	(�) �� �������, �� ���� ��������,
				//	(�) �� �������, �� ������� ����� ����������� ��-�������:
				if (bIsWorkDay || nDayBalance>0 || m_oParams.ShowFreeWeekends)
				{
					string sCellData = String.Format( 
						"<fo:inline font-weight='bold'>{0}</fo:inline>" + 
						"<fo:block font-weight='normal'>( {1} / {2} )</fo:block>",
						formatExpenseValue(nSpentForIncidents + nSpentForProcesses),
						formatExpenseValue(nSpentForIncidents), 
						formatExpenseValue(nSpentForProcesses)
					);
					string sInfoTestStyle; 
					string sDayBalanceStyle;
					string sSumBalanceStyle;

					if (bIsWorkingPeriod)
					{
						sInfoTestStyle = bIsWorkDay ? "TABLE_CELL" : "TABLE_CELL_COLOR_FREE";
						sDayBalanceStyle = nDayBalance < 0 ? "TABLE_CELL_COLOR_RED" : "TABLE_CELL_COLOR_GREEN";
						sSumBalanceStyle = nSumBalance < 0 ? "TABLE_CELL_COLOR_RED" : "TABLE_CELL_COLOR_GREEN";
					}
					else
					{
						sInfoTestStyle = bIsWorkDay ? "TABLE_CELL_COLOR_NOWORK" : "TABLE_CELL_COLOR_FREE";
						sDayBalanceStyle = nDayBalance > 0 ? "TABLE_CELL_COLOR_GREEN" : "TABLE_CELL_COLOR_NOWORK";
						sSumBalanceStyle = nSumBalance > 0 ? "TABLE_CELL_COLOR_GREEN" : "TABLE_CELL_COLOR_NOWORK";
						if (nSpentForIncidents + nSpentForProcesses <= 0)
							sCellData = "( �������� �� ��������� )";
					}

					fo.TRStart();
					fo.TRAddCell( sFullDayName, "string", 1, 1, sInfoTestStyle );
					fo.TRAddCell( sCellData,  "string", 1, 1, sInfoTestStyle );
					fo.TRAddCell( formatExpenseValue(nDayBalance), "string", 1, 1, sDayBalanceStyle );
					fo.TRAddCell( formatExpenseValue(nSumBalance), "string", 1, 1, sSumBalanceStyle );
					fo.TREnd();
				}
			}

			// ������: �������� ���������� ���� (������ � �������), �������� ������ �� ������:
			fo.TRStart();
			fo.TRAddCell(
				String.Format(
					"<fo:block font-weight='bold' text-align='left'>�����, �� ������: " +
					"<fo:block font-weight='normal' padding-left='15px'> ����������� ����: <fo:inline font-weight='bold'>{0}</fo:inline>, </fo:block>" +
					"<fo:block font-weight='normal' padding-left='15px'> �� ��� �������: <fo:inline font-weight='bold'>{1}</fo:inline></fo:block>" +
					"</fo:block>",
					nQntDays, nQntWorkDays
				), "string", 3, 1, "TABLE_FOOTER" );
			fo.TRAddCell(
				String.Format("<fo:inline font-weight='bold'>{0}</fo:inline>", formatExpenseValue(nSumBalance) ),
				"string", 1, 1, 
				nSumBalance < 0 ? "TABLE_CELL_COLOR_RED" : "TABLE_CELL_COLOR_GREEN" );
			fo.TREnd();

			fo.TEnd();
		}

		
		/// <summary>
		/// ����������� ������������� ������ �������, � ����������� �� 
		/// �������, ����������� ���������� (m_oParams.TimeMeasure)
		/// </summary>
		/// <param name="nValue">������� �������, � �������</param>
		/// <returns>������ � ��������������� ��������������</returns>
		protected string formatExpenseValue( int nValue ) 
		{
			return 
				TimeMeasureUnits.Days == m_oParams.TimeMeasure ?
					Utils.FormatTimeDuration( nValue, (0==nValue && 0==m_oParams.WorkdayDuration? 1 : m_oParams.WorkdayDuration) ) :
				(nValue/60.0).ToString("0.00");
		}
	}
}
