//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
// Код формирования отчета "Структура затрат подразделения"
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
	/// Реализация отчета "Структура затрат подразделения"
	/// </summary>
	public class r_EmployeeExpensesBalance: CustomITrackerReport 
	{
       protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data)
        {
            buildThisReport(data.RepGen, data.Params, data.DataProvider, data.CustomData);
        }
		#region Константы 
			
		/// <summary>
		/// Форматная строка для задания параметров ссылки (тега fo:link) 
		/// отчета "Инциденты и затраты сотрудника", для конкретного сотрудника,
		/// за один заданный день; Параметры:
		///		{0} - Guid сотрудника,
		///		{1} - дата, на которую формируется отчет, в формате YYYY-MM-DD,
		///		{2} - форма представления времени (0/1)
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
			"')\" show-destination=\"new\" target=\"_blank\" title=\"Отчет 'Инциденты и затраты сотрудника'\"";
			
		#endregion

		/// <summary>
		/// Внутренний класс, представляющий все актуальные параметры отчета
		/// </summary>
		public class ThisReportParams 
		{
			#region Параметры отчета
			
			/// <summary>
			/// Идентификатор сотрудника, для которого рассчитывается баланс списаний
			/// </summary>
			public Guid EmployeeID;

			/// <summary>
			/// Дата начала отчетного периода (включительно)
			/// </summary>
			public object IntervalBegin;
			/// <summary>
			/// Признак, что дата начала отчетного периода задана
			/// </summary>
			public bool IsSpecifiedIntervalBegin;
			/// <summary>
			/// Дата конца отчетного периода (включительно)
			/// </summary>
			public object IntervalEnd;
			/// <summary>
			/// Признак, что дата конца отчетного периода задана
			/// </summary>
			public bool IsSpecifiedIntervalEnd; 

			/// <summary>
			/// Признак отображения данных выходных дней, для которых нет списаний
			/// </summary>
			public bool ShowFreeWeekends;
			/// <summary>
			/// Форма представления времени: 0 - Дни, часы, минуты; 1 - Часы. 
			/// Имеет смысл, если DataFormat задает отображение затрат в виде
			/// времени.
			/// </summary>
			public TimeMeasureUnits TimeMeasure;
			/// <summary>
			/// Признак включения в заголовок отчета заданных параметров
			/// </summary>
			public bool ShowRestrictions;

			#endregion

			#region Доп. данные по сотруднику
			// Все данные прогружаются в момент создания экземпляра

			/// <summary>
			/// Полные фамилия, имя сотрудника
			/// </summary>
			public string FullName;
			/// <summary>
			/// Дата начала работы сотрудника в компании
			/// </summary>
			public DateTime WorkBeginDate;
			/// <summary>
			/// Дата завершения работы сотрудника в компании
			/// </summary>
			public DateTime WorkEndDate;
			/// <summary>
			/// Норма рабочего времени в один день для сотрудника
			/// </summary>
			public int WorkdayDuration;

			#endregion

			/// <summary>
			/// Параметризированный конструктор. Инициализирует свойства класса на 
			/// основании данных параметров, представленных в коллекции ReportParams. 
			/// </summary>
			/// <param name="Params">Данные параметов, передаваемые в отчет</param>
			/// <param name="cn">Соединение с БД (для подгрузки данных)</param>
			/// <remarks>
			/// При необходимости выполняет коррекцию значений параметров
			/// </remarks>
			public ThisReportParams( ReportParams Params, IReportDataProvider provider) 
			{
				// #1: ЗАЧИТЫВАЕМ ПАРАМЕТРЫ, ЗАДАННЫЕ ЯВНО
				// Идентификатор сотрудника
				EmployeeID = (Guid)Params.GetParam("Employee").Value;

				// Задание дат начала и конца отчетного периода
				IsSpecifiedIntervalBegin = !Params.GetParam("IntervalBegin").IsNull;
				IntervalBegin = ( IsSpecifiedIntervalBegin? Params.GetParam("IntervalBegin").Value : DBNull.Value );
				IsSpecifiedIntervalEnd = !Params.GetParam("IntervalEnd").IsNull;
				IntervalEnd = ( IsSpecifiedIntervalEnd? Params.GetParam("IntervalEnd").Value : DBNull.Value );

				// Признак "Показывть выходные дни без списаний"
				ShowFreeWeekends = ( 0!= (int)Params.GetParam("ShowFreeWeekends").Value );
				// Представление времени
				TimeMeasure = (TimeMeasureUnits)((int)Params.GetParam("TimeMeasureUnits").Value);
				// Признак отображения параметров отчета в заголовке
				ShowRestrictions = ( 0 != (int)Params.GetParam("ShowRestrictions").Value );

				// #2: ДОГРУЖАЕМ ВСЕ ДАННЫЕ ПО СОТРУДНИКУ
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
			/// Формирует текст XSL-FO, представляющий данные заданных параметров, и 
			/// записывает его как текст подзаголовка формируемого отчета
			/// </summary>
			/// <param name="foWriter"></param>
			public void WriteParamsInHeader( XslFOProfileWriter foWriter ) 
			{
				// XSL-FO с перечнем параметров будем собирать сюда:
				StringBuilder sbBlock = new StringBuilder();
				string sParamValue;		// временная строка с представлением значения параметра
				
				// #1: Сотрудник:
				sbBlock.Append( getParamValueAsFoBlock( "Сотрудник", FullName ) );

				// #2: Дата начала и окончания отчетного периода. 
				// Любая из этих дат может быть не задана; если это так, то 
				// в заголовке отчета выводится соответствующие указание:
				if ( IsSpecifiedIntervalBegin )
					sParamValue = ((DateTime)IntervalBegin).ToString("dd.MM.yyyy");
				else
					sParamValue = "не задана, используется текущая - " + DateTime.Now.ToString("dd.MM.yyyy");
				sbBlock.Append( getParamValueAsFoBlock( "Дата начала периода", sParamValue ) );
				
				if ( IsSpecifiedIntervalEnd )
					sParamValue = ((DateTime)IntervalEnd).ToString("dd.MM.yyyy");
				else
					sParamValue = "не задана, используется текущая - " + DateTime.Now.ToString("dd.MM.yyyy");
				sbBlock.Append( getParamValueAsFoBlock( "Дата окончания периода", sParamValue ) );

				// #3: Единицы представления времени: 
				sParamValue = TimeMeasureUnitsItem.GetItem(TimeMeasure).Description;
				sbBlock.Append( getParamValueAsFoBlock( "Единицы изменения времени", sParamValue ) );

				// #4: Признак "Показывть выходные дни без списаний"
				sParamValue = ShowFreeWeekends? "Да" : "Нет";
				sbBlock.Append( getParamValueAsFoBlock( "Отображать выходные без списаний", sParamValue ));

				
				// ВЫВОД ПОДЗАГОЛОВКА:
				foWriter.AddSubHeader( 
					@"<fo:block text-align=""left"" font-weight=""bold"">Параметры отчета:</fo:block>" + 
					sbBlock.ToString()
				);
			}


			/// <summary>
			/// Внутренний метод, формирует текст XSL-FO блока фиксированной структуры,
			/// представляющий пару "наименование параметра" и "значение параметра".
			/// Используется при формировании XSL-FO-текста с перечнем заданных параметров
			/// </summary>
			/// <param name="sParamName">Наименование параметра</param>
			/// <param name="sParamValueText">Текст со значением параметра</param>
			/// <returns>Строка с текстом XSL-FO блока</returns>
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
		/// Все параметры данного отчета
		/// </summary>
		private ThisReportParams m_oParams;

		/// <summary>
		/// Параметризованный конструктор, вызваемый подсистемой ReportService
		/// </summary>
		/// <param name="ReportProfile"></param>
		/// <param name="ReportName"></param>
		public r_EmployeeExpensesBalance( reportClass ReportProfile, string ReportName ) 
			: base(ReportProfile, ReportName) 
		{}


		/// <summary>
		/// Метод формирования отчета. Вызывается из ReportService
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="Params"></param>
		/// <param name="Provider"></param>
		/// <param name="cn"></param>
		/// <param name="CustomData"></param>
        protected void buildThisReport(XslFOProfileWriter foWriter, ReportParams Params, IReportDataProvider Provider, object CustomData) 
		{
			// Получим параметры:
			m_oParams = new ThisReportParams( Params, Provider);
			
			// ФОРМИРОВАНИЕ ОТЧЕТА
            foWriter.WriteLayoutMaster();
			foWriter.StartPageSequence();
			foWriter.StartPageBody();

			// ЗАГОЛОВОК
			foWriter.Header( "Баланс списаний сотрудника" );
			// Параметры отчета в заголовке?
			if (m_oParams.ShowRestrictions)
				m_oParams.WriteParamsInHeader( foWriter );

            writeBody(foWriter, Provider);

			foWriter.EndPageBody();
			foWriter.EndPageSequence();
		}
	
	
		/// <summary>
		/// Формирование шапки таблицы отчета
		/// </summary>
		/// <param name="fo"></param>
		/// <returns>Кол-во сформированных колонок</returns>
		private void writeHeader( XslFOProfileWriter fo ) 
		{
            fo.TAddColumn("Дата", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
            fo.TAddColumn("Трудозатраты<fo:block font-weight='normal'>(всего, по инцидентам / по списаниям)</fo:block>", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "30%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
			int nColIndex = fo.TAddColumn( "Баланс списаний", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, "TABLE_HEADER" );
            fo.TAddSubColumn(nColIndex, "за день", align.ALIGN_CENTER, valign.VALIGN_TOP, null, "25%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
            fo.TAddSubColumn(nColIndex, "за период, накопительно", align.ALIGN_CENTER, valign.VALIGN_TOP, null, "25%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
		}

		
		/// <summary>
		/// Фомрирование "тела" отчета 
		/// </summary>
		/// <param name="fo"></param>
		/// <param name="cn"></param>
		private void writeBody( XslFOProfileWriter fo, IReportDataProvider Provider ) 
		{
			// Запускаем процесс расчета данных: 
			IDataReader reader;
            reader = Provider.GetDataReader("dsMain", m_oParams);
			if ( !reader.Read() )
			{
				writeEmptyBody( fo, "Нет данных" );
				return;
			}

			// Формируем заголовок отчета:
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
				// Данные результата, текущая строка
				DateTime dtCalendarDate = reader.GetDateTime(nOrd_CalendarDate);
				bool bIsWorkDay = reader.GetBoolean(nOrd_IsWorkday);
				int nSpentForIncidents = reader.GetInt32(nOrd_SpentForIncidents);
				int nSpentForProcesses = reader.GetInt32(nOrd_SpentForProcesses);
                int nDayRate = reader.GetInt16(nOrd_Rate);
				string sCellLinkParams = String.Format(
					DEF_FMT_ReportRef,
					m_oParams.EmployeeID.ToString(),			// 0 - Идентификатор сотрудника
					dtCalendarDate.ToString("yyyy-MM-dd"),		// 1 - Дата начала периода, она же - дата окончания
					((int)m_oParams.TimeMeasure).ToString() );	// 2 - Форма представления времени

				string sFullDayName = String.Format( 
					"<fo:basic-link {0}>{1}</fo:basic-link>" + 
					"<fo:block font-weight='normal'>{2}</fo:block>",
					sCellLinkParams, dtCalendarDate.ToString("dd.MM.yyyy"), 
					reader.GetString(nOrd_DayName) );

				// Вычисляемые значения:
				bool bIsWorkingPeriod = (dtCalendarDate >= m_oParams.WorkBeginDate && dtCalendarDate <= m_oParams.WorkEndDate);
				int nDayBalance = (nSpentForIncidents + nSpentForProcesses);
                if (bIsWorkDay && bIsWorkingPeriod) nDayBalance -= nDayRate;
				nSumBalance += nDayBalance;
				nQntDays += 1;
				nQntWorkDays += (bIsWorkingPeriod && bIsWorkDay ? 1 : 0);

				// Выводим данные: если это 
				//	(а) рабочий день;
				//	(б) не рабочий, но есть списания,
				//	(в) не рабочий, но включен режим отображения не-рабочих:
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
							sCellData = "( списания не требуются )";
					}

					fo.TRStart();
					fo.TRAddCell( sFullDayName, "string", 1, 1, sInfoTestStyle );
					fo.TRAddCell( sCellData,  "string", 1, 1, sInfoTestStyle );
					fo.TRAddCell( formatExpenseValue(nDayBalance), "string", 1, 1, sDayBalanceStyle );
					fo.TRAddCell( formatExpenseValue(nSumBalance), "string", 1, 1, sSumBalanceStyle );
					fo.TREnd();
				}
			}

			// Подвал: итоговое количество дней (вообще и рабочих), итоговый баланс за период:
			fo.TRStart();
			fo.TRAddCell(
				String.Format(
					"<fo:block font-weight='bold' text-align='left'>Итого, за период: " +
					"<fo:block font-weight='normal' padding-left='15px'> календарных дней: <fo:inline font-weight='bold'>{0}</fo:inline>, </fo:block>" +
					"<fo:block font-weight='normal' padding-left='15px'> из них рабочих: <fo:inline font-weight='bold'>{1}</fo:inline></fo:block>" +
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
		/// Форматирует представление затрат времени, в зависимости от 
		/// формата, задаваемого параметром (m_oParams.TimeMeasure)
		/// </summary>
		/// <param name="nValue">затраты времени, в минутах</param>
		/// <returns>Строка с форматированным представлением</returns>
		protected string formatExpenseValue( int nValue ) 
		{
			return 
				TimeMeasureUnits.Days == m_oParams.TimeMeasure ?
					Utils.FormatTimeDuration( nValue, (0==nValue && 0==m_oParams.WorkdayDuration? 1 : m_oParams.WorkdayDuration) ) :
				(nValue/60.0).ToString("0.00");
		}
	}
}
