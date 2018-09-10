//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
// Код формирования отчета "Структура затрат подразделения"
//******************************************************************************
using System;
using System.Collections;
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
	public class r_DepartmentExpensesStructure: CustomITrackerReport 
	{
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data)
        {
            buildThisReport(data.RepGen, data.Params, data.DataProvider, data.CustomData);
        }
		/// <summary>
		/// "Виды" списаний
		/// </summary>
		internal enum ExpTypes 
		{
			OnIncident = 0,			// Списания на инциденты, без разделения на "внешние" / "внутренние"
			OnIncidentExternal = 1,	// Списания на инциденты по "внешним" активностям
			OnIncidentInternal = 2,	// Списания на инциденты по "внутренним" активностям
			OnCauseFolder = 3,		// Списания на активности, без разделения на "внешние" / "внутренние"
			OnCauseExternal = 4,	// Списания на "внешние" активности
			OnCauseInternal = 5,	// Списания на "внутренние" активности
			OnCauseLoss = 6			// Внепроектные списания
		}
		
		
		/// <summary>
		/// Внутренний класс представления описаний причин списания. Используется при включении 
		/// режима детализации по причинам списания (а) для формирования заголовка,
		/// (б) для определения соответствия м/у колонкой и GUID-ом причины списания
		/// из результирующего набора.
		/// </summary>
		internal class ExpenseCausesMapper 
		{
			/// <summary>
			/// Описание одной причины списания
			/// </summary>
			private struct ExpenseCauseInfo 
			{
				/// <summary>
				/// Идентификатор причины списания;
				/// </summary>
				public Guid CauseID;
				/// <summary>
				/// "Тип" причины списания (требутся / разрешается / запрещено
				/// списывать с данной причиной на проект)
				/// </summary>
				public TimeLossCauseTypes CauseType;
				/// <summary>
				/// Наименование причины списания
				/// </summary>
				public string Name;
			}
			
			
			/// <summary>
			/// Описания "проектных" причин списаний (списания, привязанные к папкам)
			/// </summary>
			private ArrayList m_aActivityExpenses = new ArrayList();
			/// <summary>
			/// Описания "непроектных" причин списаний (списания, не привязанные к папкам)
			/// </summary>
			private ArrayList m_aNonActivityExpenses = new ArrayList();

			/// <summary>
			/// Процедура инициализации 
			/// </summary>
			/// <param name="cn">Соединение с БД</param>
			public void Init( IReportDataProvider dataProvider) 
			{
                using (IDataReader reader = dataProvider.GetDataReader("dsExpencesCauses", null))
					{
						if ( !reader.Read() )
							throw new ApplicationException("Ошибка получения перечня описаний причин списаний - получен пустой набор!");
						do
						{
							ExpenseCauseInfo info = new ExpenseCauseInfo();
							info.CauseID = reader.GetGuid( reader.GetOrdinal("ObjectID") );
							info.CauseType = (TimeLossCauseTypes)( (int)reader.GetValue(reader.GetOrdinal("Type")) );
							info.Name = reader.GetString( reader.GetOrdinal("Name") );

							ExpTypes enExpType = (ExpTypes)( (int)reader.GetValue(reader.GetOrdinal("CauseExpType")) );
							if ( ExpTypes.OnCauseFolder == enExpType )
								m_aActivityExpenses.Add( info );
							else if ( ExpTypes.OnCauseLoss == enExpType )
								m_aNonActivityExpenses.Add( info );
							else
								throw new ApplicationException("Ошибка определения вида списания (проектное / непроектное) - вид, не подлежащий обработке: " + enExpType.ToString() );
						}
						while( reader.Read());
					}
			}

			
			/// <summary>
			/// Получение перечня наименований колонок для группы причин списаний,
			/// в соответствии с указанным видом (проектные / непроектные)
			/// </summary>
			/// <param name="enExpType">Вид списаний</param>
			/// <returns>Массив строк с наименованием колонок</returns>
			public ArrayList GetColumnsNames( ExpTypes enExpType ) 
			{
				ArrayList aInfos = null;
				if ( ExpTypes.OnCauseFolder == enExpType )
					aInfos = m_aActivityExpenses;
				else if ( ExpTypes.OnCauseLoss == enExpType )
					aInfos = m_aNonActivityExpenses; 
				else
					throw new ArgumentException( 
						String.Format(
						"Некорректный вида списания enExpType (проектное/непроектное) - " + 
						"указанный вид {0} не подлежит обработке", enExpType ),
						"enExpType" );

				ArrayList aNames = new ArrayList();
				foreach( ExpenseCauseInfo item in aInfos )
					aNames.Add( item.Name );
				return aNames;
			}


			/// <summary>
			/// Возвращает стартовый индекс в общем массиве сумм списаний, разложенных
			/// по причинам, в зависимости от принадлежности "проектное / вне-проектное
			/// списание"
			/// </summary>
			/// <param name="enExpType">Вид списания</param>
			/// <returns>Стартовый индекс</returns>
			public int GetColumnsIndexesBase( ExpTypes enExpType ) 
			{
				if ( ExpTypes.OnCauseFolder == enExpType )
					return 0;
				else if ( ExpTypes.OnCauseLoss == enExpType )
					return m_aActivityExpenses.Count; 
				else
					throw new ArgumentException( 
						String.Format(
							"Некорректный вида списания enExpType (проектное/непроектное) - " + 
							"указанный вид {0} не подлежит обработке", enExpType ),
						"enExpType" );
			}
			
			
			/// <summary>
			/// Возвращает индекс в общем массиве сумм списаний, разложенных по причинам, 
			/// в зависимости от идентификатора причины списания и принадлежности в виду
			/// "проектное / вне-проектное списание"
			/// </summary>
			/// <param name="uidExpenseCauseID">идентификатор причины списания</param>
			/// <param name="enExpType">вид списания</param>
			/// <returns>индекс в массиве с суммами списаний</returns>
			public int GetColumnIndex( Guid uidExpenseCauseID, ExpTypes enExpType ) 
			{
				if ( ExpTypes.OnCauseExternal == enExpType || ExpTypes.OnCauseInternal == enExpType )
					enExpType = ExpTypes.OnCauseFolder;

				ArrayList aInfos = null;
				int nIndexBase = ( ExpTypes.OnCauseLoss == enExpType? m_aActivityExpenses.Count : 0 );
				if ( ExpTypes.OnCauseFolder == enExpType )
					aInfos = m_aActivityExpenses;
				else if ( ExpTypes.OnCauseLoss == enExpType )
					aInfos = m_aNonActivityExpenses;
				else 
					return -1;

				int nRetIndex=0; 
				foreach( ExpenseCauseInfo item in aInfos )
				{
					if ( item.CauseID == uidExpenseCauseID)
						return nIndexBase + nRetIndex;
					else
						nRetIndex++;
				}
				return -1;
			}
		
			
			/// <summary>
			/// Общее количество элементов в массиве сумм списаний, разложенных по причинам
			/// </summary>
			public int ColumnQnt 
			{
				get { return m_aActivityExpenses.Count + m_aNonActivityExpenses.Count; }
			}

		}
		
		
		/// <summary>
		/// Внутренний класс, представляющий все актуальные параметры отчета
		/// </summary>
		public class ThisReportParams 
		{
			#region Параметры отчета
			
			/// <summary>
			/// Форма отчета
			/// </summary>
			public RepDepartmentExpensesStructure_ReportForm ReportForm;
			
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
			/// Перечень идентификаторов организаций
			/// </summary>
			public string OrganizationIDs;
			/// <summary>
			/// Перечень идентификаторов подразделений
			/// </summary>
			public string DepartmentIDs;
			/// <summary>
			/// Объем анализируемых данных
			/// </summary>
			public RepDepartmentExpensesStructure_AnalysisDepth AnalysisDepth;

			/// <summary>
			/// Видимость опциональных колонок (колонка видна, если флаг задан)
			/// </summary>
			public RepDepartmentExpensesStructure_OptColsFlags ShownColumns;

			/// <summary>
			/// Признак исключения данных сотрудников, уволенных на конец заданного
			/// отчетного периода
			/// </summary>
			public bool PassRedundant;

            /// <summary>
            /// Признак исключения данных нетрудоспособных сотрудников
            /// </summary>
            public bool PassDisabled;

			/// <summary>
			/// Форма предствления данных
			/// </summary>
			public RepDepartmentExpensesStructure_DataFormat DataFormat;
			/// <summary>
			/// Сумма по колонке как база расчета процентов (сумма по колонке 
			/// берется за 100%; если флаг задан в False, то берется сумма по
			/// строке). Имеет смысл, если DataFormat задает отображение затрат
			/// в процентах.
			/// </summary>
			public bool ColumnSumAsPercentBase;
			/// <summary>
			/// Форма представления времени: 0 - Дни, часы, минуты; 1 - Часы. 
			/// Имеет смысл, если DataFormat задает отображение затрат в виде
			/// времени.
			/// </summary>
			public TimeMeasureUnits TimeMeasure;

			/// <summary>
			/// Перечень идентификаторов видов активностей (объекты ActivityType),
			/// затраты по которым будут рассматриваться как "внешние". Используется
			/// при рассчете значений колонки "Коэффициент утилизации" (см. ShownColumns)
			/// В этом случае должен быть задан хотя бы один вид активностей; иначе 
			/// значение параметра игнорируется.
			/// </summary>
			public string ActivityTypesAsExternalIDs;

			/// <summary>
			/// Признак группировки данных в отчете по подразделениям.
			/// </summary>
			public bool DoGroup;
			/// <summary>
			/// Сортировка данных в отчете. Сортировка ByDisbalance и ByUtilization имеет
			/// смысл только в случае включения в отчет соответствующих колонок; 
			/// </summary>
			public RepDepartmentExpensesStructure_SortingMode SortingMode;
			/// <summary>
			/// Признак включения в заголовок отчета заданных параметров
			/// </summary>
			public bool ShowRestrictions;

			#endregion

			/// <summary>
			/// Параметризированный конструктор. Инициализирует свойства класса на 
			/// основании данных параметров, представленных в коллекции ReportParams. 
			/// </summary>
			/// <param name="Params">Данные параметов, передаваемые в отчет</param>
			/// <remarks>
			/// При необходимости выполняет коррекцию значений параметров, полгаемых 
			/// по умолчанию, а так же расчет синтетических параметров (таких как 
			/// "Направление активности")
			/// </remarks>
			public ThisReportParams( ReportParams Params ) 
			{
				// #1: ЗАЧИТЫВАЕМ ПАРАМЕТРЫ

				ReportParams.ReportParam oParam;

				// Определение формы отчета
				ReportForm = (RepDepartmentExpensesStructure_ReportForm)((int)Params.GetParam("ReportForm").Value);
				
				// Задание дат начала и конца отчетного периода
				IsSpecifiedIntervalBegin = !Params.GetParam("IntervalBegin").IsNull;
				IntervalBegin = ( IsSpecifiedIntervalBegin? Params.GetParam("IntervalBegin").Value : DBNull.Value );
				IsSpecifiedIntervalEnd = !Params.GetParam("IntervalEnd").IsNull;
				IntervalEnd = ( IsSpecifiedIntervalEnd? Params.GetParam("IntervalEnd").Value : DBNull.Value );

				// Определение базового набора: идентификаторы организаций / подразделений
				OrganizationIDs = String.Empty;
				if ( Params.IsParamExists("Organizations") )
				{
					oParam = Params.GetParam("Organizations");
					OrganizationIDs = ( oParam.IsNull? String.Empty : oParam.Value.ToString().Trim() );
				}
				DepartmentIDs = String.Empty;
				if ( Params.IsParamExists("Departments") )
				{
					oParam = Params.GetParam("Departments");
					DepartmentIDs = ( oParam.IsNull? String.Empty : oParam.Value.ToString().Trim() );
				}
				// Объем анализируемых данных
				AnalysisDepth = (RepDepartmentExpensesStructure_AnalysisDepth)((int)Params.GetParam("AnalysisDepth").Value);

				// Видимость опциональных колонок:
				ShownColumns = (RepDepartmentExpensesStructure_OptColsFlags)((int)Params.GetParam("ShownColumns").Value);

				// Признак исключения данных уволенных сотрудников
				PassRedundant = ( 0!= (int)Params.GetParam("PassRedundant").Value );

                //Признак исключения данных нетрудоспособных сотрудников
			    PassDisabled = (0 != (int) Params.GetParam("PassDisabled").Value);

				// Форма предствления данных
				DataFormat = (RepDepartmentExpensesStructure_DataFormat)((int)Params.GetParam("DataFormat").Value);
				// Флаг, определяющий способ расчета процентных отношений
				ColumnSumAsPercentBase = ( 0 != (int)Params.GetParam("ExpensesSumAsPercentBase").Value );
				// Представление времени
				TimeMeasure = (TimeMeasureUnits)((int)Params.GetParam("TimeMeasureUnits").Value);

				// Виды активностей, затраты по которым рассматриваются как "внешние" 
				ActivityTypesAsExternalIDs = String.Empty;
				if ( Params.IsParamExists("ActivityTypesAsExternal") )
				{
					oParam = Params.GetParam("ActivityTypesAsExternal");
					ActivityTypesAsExternalIDs = ( oParam.IsNull? String.Empty : oParam.Value.ToString() );
				}

				// Сортировка
				SortingMode = (RepDepartmentExpensesStructure_SortingMode)((int)Params.GetParam("SortingMode").Value);
				// Признак группировки данных по подразделениям
				DoGroup = ( 0 != (int)Params.GetParam("DoGroup").Value );
				// Признак отображения параметров отчета в заголовке
				ShowRestrictions = ( 0 != (int)Params.GetParam("ShowRestrictions").Value );


				// #2: Проверка внутренней корректности заданных параметров:
				// TODO!
			}

			
			/// <summary>
			/// Вспомогательный метод -обертка: проверка "включенности" опциональной
			/// колонки отчета, заданного флагом 
			/// </summary>
			/// <param name="flag">Флаг, соотв. проверяемой колонке</param>
			/// <returns>1, если колонка включена, 0 - иначе</returns>
			public int IsShowColumn( RepDepartmentExpensesStructure_OptColsFlags flag ) 
			{
				return ( ((int)(ShownColumns & flag)) > 0? 1 : 0 );
			}
			
			
			/// <summary>
			/// Формирует текст XSL-FO, представляющий данные заданных параметров, и 
			/// записывает его как текст подзаголовка формируемого отчета
			/// </summary>
			/// <param name="foWriter"></param>
			/// <param name="cn"></param>
			public void WriteParamsInHeader( XslFOProfileWriter foWriter, IReportDataProvider dataProvider ) 
			{
				// XSL-FO с перечнем параметров будем собирать сюда:
				StringBuilder sbBlock = new StringBuilder();
				string sParamValue;				// временная строка с представлением значения параметра
				string sActivityTypesNames;		// строка с переченм наименований видов активностей

				// #1: Форма отчета:
				sbBlock.Append( getParamValueAsFoBlock( 
						"Форма отчета", 
						RepDepartmentExpensesStructure_ReportFormItem.GetItem(ReportForm).Description
					));
				
				// #2: Дата начала и окончания отчетного периода. 
				// Любая из этих дат может быть не задана; если это так, то 
				// в заголовке отчета выводится соответствующие указание:
				if ( IsSpecifiedIntervalBegin )
					sParamValue = ((DateTime)IntervalBegin).ToString("dd.MM.yyyy");
				else
					sParamValue = "(не задана)";
				sbBlock.Append( getParamValueAsFoBlock( "Дата начала отчетного периода", sParamValue ) );
				
				if ( IsSpecifiedIntervalEnd )
					sParamValue = ((DateTime)IntervalEnd).ToString("dd.MM.yyyy");
				else
					sParamValue = "(не задана)";
				sbBlock.Append( getParamValueAsFoBlock( "Дата окончания отчетного периода", sParamValue ) );
				
				// #3: Базовый набор: перечень организаций и подразделений
				// Заодно зачитаем наименования видов активностей
				sParamValue = String.Empty;
				sActivityTypesNames = String.Empty;

                using (IDataReader reader = dataProvider.GetDataReader("dsOrganizationAndDepartments", this))
						while( reader.Read() )
						{
							if ( 0 == reader.GetInt32(0) ) 
								sActivityTypesNames += reader.GetString(1) + ", ";
							else
								sParamValue += reader.GetString(1) + ", ";
						}
				if (sActivityTypesNames != String.Empty)
					sActivityTypesNames = sActivityTypesNames.TrimEnd( ',', ' ' );
				if (sParamValue != String.Empty)
					sParamValue = sParamValue.TrimEnd( ',', ' ' );
				sbBlock.Append( getParamValueAsFoBlock( "Анализируемые данные", sParamValue ) );

				// Указание глубины анализа (на форме оно как бы "безымянное"):
				sbBlock.Append( getParamValueAsFoBlock( 
						"Глубина анализа данных", 
						RepDepartmentExpensesStructure_AnalysisDepthItem.GetItem(AnalysisDepth).Description
					));

				
				// #4: Видимость опциональных колонок 
				sParamValue = RepDepartmentExpensesStructure_OptColsFlagsItem.ToStringOfDescriptions( ShownColumns );
				sbBlock.Append( getParamValueAsFoBlock( 
						"Отображаемые колонки",
						( sParamValue.Length > 0 ? sParamValue : "(все опциональные колонки скрыты)" )
					));

				
				// #5: Учет данных уволенных сотрудников:
				sbBlock.Append( getParamValueAsFoBlock(
                        "Исключить данные уволенных сотрудников",
						( PassRedundant ? "Да" : "Нет" )
					));

                // #6: Учет данных нетрудоспособных сотрудников:
                sbBlock.Append(getParamValueAsFoBlock(
                        "Исключить данные нетрудоспособных сотрудников",
                        (PassDisabled ? "Да" : "Нет")
                    ));

				// #7: Формат представления данных: 
				sbBlock.Append( getParamValueAsFoBlock( 
						"Представление данных",
						RepDepartmentExpensesStructure_DataFormatItem.GetItem(DataFormat).Description
					));
				// ...если форма представления данных не включает проценты, 
				// то определение процентной базы не используется:
				if ( RepDepartmentExpensesStructure_DataFormat.OnlyTime == DataFormat )
					sParamValue = "(не используется)";
				else
					sParamValue = ( ColumnSumAsPercentBase? "Сумму затрат по колонке" : "Сумму затрат по строке" );
				sbBlock.Append( getParamValueAsFoBlock( "За 100% брать", sParamValue ) ); 
				// ...аналогично, если форма представления времени не включает явное 
				// отображение времени, то форма его представления - не используется:
				if ( RepDepartmentExpensesStructure_DataFormat.OnlyPercent == DataFormat )
					sParamValue = "(не используется)";
				else
					sParamValue = TimeMeasureUnitsItem.GetItem(TimeMeasure).Description;
				sbBlock.Append( getParamValueAsFoBlock( "Представление времени", sParamValue ) );

				// #8: Если среди отображаемых опциональных колонок есть (включена)
				// "Коэффициент утилизации", то имеет место так же задание перечня
				// видов активностей (NB: сам перечень наименований получаем ранее 
				// вне зависимости от колонки - все равно выполняется запрос):
				if ( (int)(RepDepartmentExpensesStructure_OptColsFlags.ShowUtilization & ShownColumns) > 0 )
					sbBlock.Append( getParamValueAsFoBlock( "Виды проектных активностей", sActivityTypesNames ) );

				// #9: Общие параметры: 
				// ...сортировка:
				sbBlock.Append( getParamValueAsFoBlock( 
						"Сортировка", 
						RepDepartmentExpensesStructure_SortingModeItem.GetItem(SortingMode).Description
					));
				// ...группировка данных по подразделению:
				sbBlock.Append( getParamValueAsFoBlock( 
						"Группировать данные по подразделениям", 
						(DoGroup? "Да" : "Нет") 
					));

				
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
		/// Экземпляр представления описаний причин списания
		/// </summary>
		private ExpenseCausesMapper m_oMapper;

		/// <summary>
		/// Параметризованный конструктор, вызваемый подсистемой ReportService
		/// </summary>
		/// <param name="ReportProfile"></param>
		/// <param name="ReportName"></param>
		public r_DepartmentExpensesStructure( reportClass ReportProfile, string ReportName ) 
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
		protected  void buildThisReport( XslFOProfileWriter foWriter, ReportParams Params, IReportDataProvider Provider, object CustomData ) 
		{
			// Получим параметры:
			m_oParams = new ThisReportParams( Params);

			// Дозачитываем Описания причин списания - только если это необходимо:
			m_oMapper = new ExpenseCausesMapper();
			if ( m_oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) > 0 )
				m_oMapper.Init( Provider );
			
			// ФОРМИРОВАНИЕ ОТЧЕТА
            foWriter.WriteLayoutMaster();
			foWriter.StartPageSequence();
			foWriter.StartPageBody();

			// ЗАГОЛОВОК
			foWriter.Header( "Структура затрат подразделений" );
			// Параметры отчета в заголовке?
			if (m_oParams.ShowRestrictions)
				m_oParams.WriteParamsInHeader( foWriter, Provider );

            writeBody(foWriter, Provider);

			foWriter.EndPageBody();
			foWriter.EndPageSequence();
		}
	

		/// <summary>
		/// Фомрирование "тела" отчета 
		/// </summary>
		/// <param name="fo"></param>
		/// <param name="cn"></param>
		private void writeBody( XslFOProfileWriter fo, IReportDataProvider dataProvider ) 
		{
			// Запускаем процесс расчета данных: 
            IDataReader reader = getReportData(dataProvider, m_oParams);
			if ( !reader.Read() )
			{
				writeEmptyBody( fo, "Нет данных" );
				return;
			}

			fo.TStart( true, ITRepStyles.TABLE, false );

			// Формируем заголовок отчета:
			int nColumnQnt = writeHeader( fo );

			if (RepDepartmentExpensesStructure_ReportForm.ByEmployee == m_oParams.ReportForm ||
				RepDepartmentExpensesStructure_ReportForm.ByDepartment == m_oParams.ReportForm)
			{
				#region Форма-1 и Форма-2

				ThisReportRow_Form1 rowTotal = new ThisReportRow_Form1( reader, m_oParams, m_oMapper );
				rowTotal.FixedRowName = "ИТОГО";
				ThisReportRow_Form1 rowSubTotal = new ThisReportRow_Form1( reader, m_oParams, m_oMapper );
				rowSubTotal.FixedRowName = "Итого по подразделению (организации)";
				ThisReportRow_Form1 rowCurr = new ThisReportRow_Form1( reader, m_oParams, m_oMapper );

				int nOrdIsGroupRow = reader.GetOrdinal("IsGroupRow");

				int nRowNum = 1;
				bool bMoreRows = rowTotal.ReadRow(reader);
				for( ; bMoreRows; )
				{
					bool bIsGroupRow = reader.GetBoolean(nOrdIsGroupRow);
					
					if (bIsGroupRow)
					{
						// Рассматриваемая строка - группировочная
						if (m_oParams.DoGroup)
						{
							if (rowSubTotal.HasSome)
								rowSubTotal.WriteRow( fo, ITRepStyles.GROUP_FOOTER, ITRepStyles.GROUP_FOOTER_COLOR, rowTotal );
							
							rowSubTotal.Zeroing();
							bMoreRows = rowSubTotal.ReadRow(reader);
							
							// Заголовок следующей группы
							fo.TRStart();
							fo.TRAddCell( xmlEncode(rowSubTotal.RowName), "string", nColumnQnt, 1, ITRepStyles.GROUP_HEADER );
							fo.TREnd();
						}
						else
							throw new ApplicationException("Ошибка структуры данных: при отключенной группировке получены группировочные данные");
					}
					else
					{
						// Собираем данные одной строки и выводим в отчет:
						bMoreRows = rowCurr.ReadRow( reader );
						rowCurr.RowNum = nRowNum++;
						rowCurr.WriteRow( fo, ITRepStyles.TABLE_CELL, ITRepStyles.TABLE_CELL_COLOR_GREEN, m_oParams.DoGroup? rowSubTotal : rowTotal );
						rowCurr.Zeroing();
					}
				}
				if (m_oParams.DoGroup && rowSubTotal.HasSome)
					rowSubTotal.WriteRow( fo, ITRepStyles.GROUP_FOOTER, ITRepStyles.GROUP_FOOTER_COLOR, rowTotal );
				// Выводим строку с итогами:
				rowTotal.WriteRow( fo, ITRepStyles.TABLE_FOOTER, null, rowTotal );

				#endregion
			}
			else if (RepDepartmentExpensesStructure_ReportForm.ByEmployeeWithTasksDetali == m_oParams.ReportForm)
			{
				#region Форма-3 

				ThisReportRow_Form2 rowTotal = new ThisReportRow_Form2( reader, "EmpID", m_oParams.TimeMeasure );
				rowTotal.Name = "ИТОГО";
				ThisReportRow_Form2 rowSub = new ThisReportRow_Form2( reader, "EmpID", m_oParams.TimeMeasure );
				rowSub.Name = "Итого по подразделению";  
				ThisReportRow_Form2 rowCurr = new ThisReportRow_Form2( reader, "EmpID", m_oParams.TimeMeasure );
				rowCurr.NameColumn = "EmpName";

				int nTrackGroupID = -1;
				if ( m_oParams.DoGroup )
					nTrackGroupID = reader.GetInt32( reader.GetOrdinal("UnitID") );
                int nCurrGroupID = -1;

				int nRowNum = 1;
				for( bool bMoreRows = true; bMoreRows; )
				{
					// "Идентификаторы" группы попадают в результирующий набор 
					// при включенной группировке (иначе они просто не нужны):
                    if (m_oParams.DoGroup && ((nCurrGroupID != nTrackGroupID) || (nCurrGroupID==-1)))
					{
						// Заголовок след. группы:
						fo.TRStart();
						fo.TRAddCell( reader.GetString(reader.GetOrdinal("GrpName")), "string", nColumnQnt, 1, ITRepStyles.GROUP_HEADER );
						fo.TREnd();
                        if (nCurrGroupID != -1)
                        {
                            nTrackGroupID = nCurrGroupID;
                        }
					}

					// Собираем данные по одному сотруднику и выводим соотв. строку отчета:
					bMoreRows = rowCurr.ReadRow( reader );
					rowCurr.RowNum = nRowNum++;
					rowCurr.WriteRow( fo, ITRepStyles.TABLE_CELL, ITRepStyles.TABLE_CELL_COLOR_GREEN );

					// Подбивам итоги:
					if ( m_oParams.DoGroup )					
						rowSub.Summarize( rowCurr );
					rowTotal.Summarize( rowCurr );
					rowCurr.Zeroing();

					// Если (а) есть группировка, и (б.1) дошли до след. группы 
					// или (б.2) прошли весь набор, то -- выводим подитог:
					if ( m_oParams.DoGroup && bMoreRows )
						nCurrGroupID = reader.GetInt32( reader.GetOrdinal("UnitID") );	
					if ( m_oParams.DoGroup && (nCurrGroupID!=nTrackGroupID || !bMoreRows) )
					{
						rowSub.WriteRow( fo, ITRepStyles.GROUP_FOOTER, ITRepStyles.GROUP_FOOTER_COLOR );
						rowSub.Zeroing();
					}
				}
				// Выводим строку с итогами:
				rowTotal.WriteRow( fo, ITRepStyles.TABLE_FOOTER, null );

				#endregion
			}
			else 
				throw new ApplicationException("Неизвестная форма отчета " + m_oParams.ReportForm.ToString());

			fo.TEnd();
		}

		
		#region Классы представления одной строки отчета

		/// <summary>
		/// Общее, что есть в представлении строк отчетов всех форм
		/// </summary>
		internal abstract class ThisReportRow 
		{
			public bool HasSome = false;

			public int RowNum;
			public int DayRate; 

			protected int m_nOrdDayRate;
			
			protected TimeMeasureUnits m_enTimeMeasure;
			protected string m_sExpenseCellType;

			/// <summary>
			/// Параметризированный конструктор
			/// </summary>
			/// <param name="enTimeMeasure"></param>
			public ThisReportRow( TimeMeasureUnits enTimeMeasure ) 
			{
				m_enTimeMeasure = enTimeMeasure;
				m_sExpenseCellType = ( TimeMeasureUnits.Days==m_enTimeMeasure? "string" : "r8" );
			}
			
			protected int safeGetInt( IDataReader reader, int nOrdinal ) 
			{
				if ( reader.IsDBNull(nOrdinal) )
					return 0;
				else
					return reader.GetInt32(nOrdinal);
			}

			
			protected string formatExpenseValue( int nValue ) 
			{
				return 
					TimeMeasureUnits.Days == m_enTimeMeasure ?
						Utils.FormatTimeDuration( nValue, (0==nValue && 0==DayRate? 1 : DayRate) ) :
					(nValue/60.0).ToString("0.00");
			}


			protected void writeExpenseCell( XslFOProfileWriter fo, int nValue, string sCellClassName ) 
			{
				fo.TRAddCell( formatExpenseValue(nValue), m_sExpenseCellType, 1, 1, sCellClassName);
			}
		}

		
		/// <summary>
		/// Представление строки отчета первой и второй форм
		/// </summary>
		internal class ThisReportRow_Form1 : ThisReportRow 
		{
			public string FixedRowName = null;

			public bool IsGroupRow = false;
			public string TrackRowID;
			public string RowName;
			public string RowLinkInfo;

			public int PeriodRate;
			
			public int ExpOnTasksExt;
			public int ExpOnTasksInt;
			public int ExpOnCausesExt;
			public int ExpOnCausesInt;
			public int ExpOnCausesLoss;
			public int[] ExpsOnCausesDetail;

			private RepDepartmentExpensesStructure_OptColsFlags m_enShownColumn;
			private RepDepartmentExpensesStructure_DataFormat m_enDataFormat;
			private bool m_bColumnSumAsPercentBase = false;
			private ExpenseCausesMapper m_oMapper;

			private int m_nOrdIsGroupRow;
			private int m_nOrdTrackRowID;
			private int m_nOrdRowName;
			private int m_nOrdRowLinkInfo;

			private int m_nOrdPeriodRate;

			private int m_nOrdExpType;
			private int m_nOrdExpCause;
			private int m_nOrdExpenses;
			public int m_nDisbalance;
			public int Disbalance;
			public 	ThisReportRow_Form1( 
				IDataReader reader, 
				ThisReportParams oParams, 
				ExpenseCausesMapper oMapper ) : base(oParams.TimeMeasure)
			{
				m_enShownColumn = oParams.ShownColumns;
				m_enDataFormat = oParams.DataFormat;
				m_bColumnSumAsPercentBase = oParams.ColumnSumAsPercentBase;
				m_oMapper = oMapper;

				if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) )
					ExpsOnCausesDetail = new int[oMapper.ColumnQnt];

				// Получаем ординалы для всех значимых колонок результата:
				m_nOrdIsGroupRow = reader.GetOrdinal("IsGroupRow");
				m_nOrdTrackRowID = reader.GetOrdinal("RowID");
				m_nOrdRowName = reader.GetOrdinal("RowName");
				try { m_nOrdRowLinkInfo = reader.GetOrdinal("RowLinkInfo"); }
				catch( IndexOutOfRangeException ) { m_nOrdRowLinkInfo = -1; }

				m_nOrdDayRate = reader.GetOrdinal("DayRate");
				m_nOrdPeriodRate = reader.GetOrdinal("PeriodRate");
				m_nOrdExpType = reader.GetOrdinal("ExpType");
				m_nOrdExpCause = reader.GetOrdinal("ExpCause");
				m_nOrdExpenses = reader.GetOrdinal("Expenses");
				try { m_nDisbalance = reader.GetOrdinal("Disbalance"); }
				catch( IndexOutOfRangeException ) { m_nDisbalance = -1;}
				
			}

			
			/// <summary>
			/// Вся соль...
			/// </summary>
			/// <param name="reader"></param>
			/// <returns></returns>
			public bool ReadRow( IDataReader reader ) 
			{
				bool bGetCauseDetalization = isShowColumn( RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization );
				if ( bGetCauseDetalization && (null==ExpsOnCausesDetail || null==m_oMapper) ) 
					throw new ApplicationException( "Ошибка чтения данных детализации затрат по причинам: нет определения карты отношений!" );

				// Признак группировочных данных:
				IsGroupRow = reader.GetBoolean(m_nOrdIsGroupRow);

				// Идентификатор группы строк, относящихся к одной логической "строке" отчета:
				if ( !reader.IsDBNull(m_nOrdTrackRowID) )
					TrackRowID = reader.GetValue(m_nOrdTrackRowID).ToString();
				else
					TrackRowID = String.Empty;

				// Наименование для одного и того же подразделения / сотрудника - одинаковы:
				RowName = (reader.IsDBNull(m_nOrdRowName) ? String.Empty : reader.GetString(m_nOrdRowName));
				// ... как и ссылочные данные:
				if (-1!=m_nOrdRowLinkInfo)
					RowLinkInfo = (reader.IsDBNull(m_nOrdRowLinkInfo) ? null : reader.GetString(m_nOrdRowLinkInfo));
				// ... как и значения норм:
				DayRate = safeGetInt( reader, m_nOrdDayRate );
				PeriodRate = safeGetInt( reader, m_nOrdPeriodRate );
				
				bool bMoreRows = true;
				for( ; bMoreRows; )
				{
					int nValue = safeGetInt( reader, m_nOrdExpenses );
					if ( 0!=nValue && 0==DayRate )
						throw new ApplicationException( "Ошибка расчета данных отчета: получена отличная от нуля сумма списаний, при нулевой норме рабочего дня!" );

					// Если ExpType есть NULL, то интерпретация его как 0 дела не испортит, 
					// так как в этом случае и Expenses - NULL, т.е. 0
					ExpTypes enExpType = (ExpTypes)safeGetInt( reader, m_nOrdExpType ); 
					switch ( enExpType )
					{
						case ExpTypes.OnIncident:
						case ExpTypes.OnIncidentExternal:
							ExpOnTasksExt += nValue; break;
						
						case ExpTypes.OnIncidentInternal:
							ExpOnTasksInt += nValue; break;

						case ExpTypes.OnCauseFolder:
						case ExpTypes.OnCauseExternal:
							ExpOnCausesExt += nValue; break;

						case ExpTypes.OnCauseInternal:
							ExpOnCausesInt += nValue; break;

						case ExpTypes.OnCauseLoss:
							ExpOnCausesLoss += nValue; break;
					}
					if (m_nDisbalance!= -1)
					{
						
						Disbalance += safeGetInt(reader,m_nDisbalance);
						
					}
					// Выполняется ли детализация по причинам списаний?..
					if (bGetCauseDetalization)
					{
						Guid uidExpenseCauseId = Guid.Empty;
						if (!reader.IsDBNull(m_nOrdExpCause))
							uidExpenseCauseId = reader.GetGuid(m_nOrdExpCause);
						if (Guid.Empty!=uidExpenseCauseId)
							ExpsOnCausesDetail[ m_oMapper.GetColumnIndex(uidExpenseCauseId,enExpType) ] += nValue;
					}

					// Переходим к следующей строке набора:
					bMoreRows = reader.Read();
					if ( bMoreRows )
						if ( TrackRowID != reader.GetValue( m_nOrdTrackRowID ).ToString() )
							break;
				}

				HasSome = true;
				return bMoreRows;
			}


			public void Summarize( ThisReportRow_Form1 row ) 
			{
				// ЗАМЕЧАНИЕ:
				// По сути это, конечно, не суммирование. Но и решения вопроса
				// "что считать нормной рабочего дня" при суммировании затрат
				// времени нескольких сотрудников (у котороых, в теории, могут
				// быть разные нормы) - не решен в принципе. Пока всю ситуацию 
				// спасает то, что норма для всех одинаковая и фиксированная. 
				// Именно по этому при суммировании затрат сама норма - просто
				// копируется (вообще оставить ее нулевой тоже нельзя, т.к. 
				// при формировании строки отчета с суммарными данными надо 
				// как-то переводить затраты в "дни, часы, недели")
				DayRate = row.DayRate;

				PeriodRate += row.PeriodRate;

				ExpOnTasksExt += row.ExpOnTasksExt;
				ExpOnTasksInt += row.ExpOnTasksInt;
				ExpOnCausesExt += row.ExpOnCausesExt;
				ExpOnCausesInt += row.ExpOnCausesInt;
				ExpOnCausesLoss += row.ExpOnCausesLoss;

				if (null!=ExpsOnCausesDetail && null!=row.ExpsOnCausesDetail)
				{
					// ..."параноидальные" проверки:
					if (ExpsOnCausesDetail.Length != row.ExpsOnCausesDetail.Length) 
						throw new ApplicationException( "Ошибка суммирования занчений строк: размероность детализации причин списаний различается!" );
					
					for( int nIdx = 0; nIdx < ExpsOnCausesDetail.Length; nIdx++ )
						ExpsOnCausesDetail[nIdx] += row.ExpsOnCausesDetail[nIdx];
				}

				HasSome = true;
			}

			
			public void Zeroing() 
			{
				IsGroupRow = false;
				TrackRowID = null;
				RowName = null;
				RowLinkInfo = null;
				
				DayRate = 0;
				PeriodRate = 0;
				Disbalance = 0;
				ExpOnTasksExt = 0;
				ExpOnTasksInt = 0;
				ExpOnCausesExt = 0;
				ExpOnCausesInt = 0;
				ExpOnCausesLoss = 0;

				if (null!=ExpsOnCausesDetail)
					for( int nIdx = 0; nIdx < ExpsOnCausesDetail.Length; nIdx++ )
						ExpsOnCausesDetail[nIdx] = 0;
				
				HasSome = false;
			}

			
			public void WriteRow( 
				XslFOProfileWriter fo, 
				string sCellClassName, 
				string sEmphCellClassName, 
				ThisReportRow_Form1 oPercentBaseRow ) 
			{
				if (null==sCellClassName)
					throw new ArgumentNullException( "sCellClassName", "Не задано наименование стилевого класса" );
				if (null==sEmphCellClassName || String.Empty==sEmphCellClassName)
					sEmphCellClassName = sCellClassName;
				if (m_bColumnSumAsPercentBase && null==oPercentBaseRow)
					throw new ArgumentNullException( "oPercentBaseRow", "Данные базы расчета процентных значений не заданы" );

				// #1: ПОДГОТОВКА ДАННЫХ
				
				// Суммарные значения по затратам:
				int nExpOnTaskAll = ExpOnTasksExt + ExpOnTasksInt;				// все затраты по инцидентам
				int nExpOnCausesOnFolder = ExpOnCausesExt + ExpOnCausesInt;		// списания на папки
				int nExpOnActivity = nExpOnTaskAll + nExpOnCausesOnFolder;		// затраты проектные, всего
				int nExpOnCausesAll = nExpOnCausesOnFolder + ExpOnCausesLoss;	// списания все
				int nExpAll = nExpOnTaskAll + nExpOnCausesAll;					// все списания в сумме
				int nDisbalance = PeriodRate - nExpAll;							// значение дисбаланса 
				if (Disbalance < 0)
					Disbalance = 0;

				// Значения по затратам, используемые в кач. базы расчета процентов (=100%)
				int nPBExpOnTaskAll = 0;			// все затраты по инцидентам
				int nPBExpOnCausesOnFolder = 0;		// списания на папки
				int nPBExpOnActivity = 0;			// затраты проектые, всего
				int nPBExpOnCausesLoss = 0;			// внепроектные списания
				int nPBExpOnCausesAll = 0;			// списания все
				int nPBExpAll = 0;					// все списания в сумме
				int nPBDisbalance = 0;				// значение дисбаланса 
				int[] nPBExpCausesDetails = null;

				if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) )
					nPBExpCausesDetails = new int[m_oMapper.ColumnQnt];

				// ...рассчитаем эти значения: это имеет смысл, если проценты вообще отображаются
				if ( RepDepartmentExpensesStructure_DataFormat.OnlyTime != m_enDataFormat )
				{
					if (m_bColumnSumAsPercentBase)
					{
						// В качестве базы расчета процентов испольуется строка с (под)итогом:
						nPBExpOnTaskAll = oPercentBaseRow.ExpOnTasksExt + oPercentBaseRow.ExpOnTasksInt;
						nPBExpOnCausesOnFolder = oPercentBaseRow.ExpOnCausesExt + oPercentBaseRow.ExpOnCausesInt;
						nPBExpOnActivity = nPBExpOnTaskAll + nPBExpOnCausesOnFolder;
						nPBExpOnCausesLoss = oPercentBaseRow.ExpOnCausesLoss;
						nPBExpOnCausesAll = nPBExpOnCausesOnFolder + nPBExpOnCausesLoss;
						nPBExpAll = nPBExpOnTaskAll + nPBExpOnCausesAll;
						nPBDisbalance = oPercentBaseRow.Disbalance;

						// Включено отображение детализации по причинам списания?
						if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) )
							for( int nIdx=0; nIdx<m_oMapper.ColumnQnt; nIdx++ )
								nPBExpCausesDetails[nIdx] = oPercentBaseRow.ExpsOnCausesDetail[nIdx];
					}
					else
					{
						// В качестве базы расчета процентов испольуется сумма затрат в строке:
						nPBExpOnTaskAll = nExpAll;
						nPBExpOnCausesOnFolder = nExpAll;
						nPBExpOnActivity = nExpAll;
						nPBExpOnCausesLoss = nExpAll;
						nPBExpOnCausesAll = nExpAll;
						nPBExpAll = nExpAll;
						// ...%% дисбаланса в этом случае считаются от нормы в строке:
						nPBDisbalance = PeriodRate;

						// Включено отображение детализации по причинам списания?
						if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) )
							for( int nIdx=0; nIdx<m_oMapper.ColumnQnt; nIdx++ )
								nPBExpCausesDetails[nIdx] = nExpAll;
					}
					if (nPBDisbalance < 0)
						nPBDisbalance = 0;
				}


				// #2: ВЫВОД ДАННЫХ
				fo.TRStart();

				// Номер строки и колонка с наименованием:
				if ( RowNum > 0 )
					fo.TRAddCell( RowNum, "i4", 1, 1, sCellClassName );

				string sNameCellContent;
				if (null!=FixedRowName && String.Empty!=FixedRowName)
					sNameCellContent = xmlEncode(FixedRowName);
				else if (null!=RowLinkInfo && String.Empty!=RowLinkInfo && null!=TrackRowID && String.Empty!=TrackRowID)
				{
					Guid uidRowID = Guid.Empty;
					try { uidRowID = new Guid(TrackRowID); }
					catch(Exception) { uidRowID = Guid.Empty; }
					sNameCellContent = _GetUserMailAnchor( RowName, RowLinkInfo, uidRowID, Guid.Empty, Guid.Empty );
				}
				else
					sNameCellContent = xmlEncode(RowName);

				fo.TRAddCell( sNameCellContent, "string", (RowNum>0 ? 1 : 2), 1, sCellClassName );

				// Отображение нормы затрат; опциональная колонка, данные всегда в форме времени:
				if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowPeriodRate) )
					writeExpenseCell( fo, PeriodRate, sCellClassName );
				
				// Данные по дисбалансу списаний; опциональная колонка:
				if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowPeriodDisbalance) )
					writeExpenseCellEx( fo, Disbalance, nPBDisbalance, sEmphCellClassName );

				// Коэффициенты утилизации; опциональная группа колонок, все значения - проценты:
				if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowUtilization) ) 
				{
					int nExpExternal = ExpOnTasksExt + ExpOnCausesExt;	// затраты на "внешние" активности
					int nExpInternal = ExpOnTasksInt + ExpOnCausesInt;	// затраты на "внутренние" активности
					double fUtlization;

					// ...внешние проекты:
					fUtlization = ( 0==PeriodRate? 0 : (nExpExternal * 100.0) / (float)PeriodRate );
					fo.TRAddCell( fUtlization.ToString("0.0000"), "r8", 1, 1, sCellClassName );
					// ...внутренние проекты:
					fUtlization = ( 0==PeriodRate? 0 : (nExpInternal * 100.0) / (float)PeriodRate );
					fo.TRAddCell( fUtlization.ToString("0.0000"), "r8", 1, 1, sCellClassName );
					// ...общий:
					fUtlization = ( 0==PeriodRate? 0 : (nExpExternal + nExpInternal)*100.0 / (float)PeriodRate );
					fo.TRAddCell( fUtlization.ToString("0.0000"), "r8", 1, 1, sCellClassName );
				}

				// Затраты времени:
				// ...общие:
				writeExpenseCellEx( fo, nExpAll, nPBExpAll, sEmphCellClassName );
				// ...затрачено на задания:
				writeExpenseCellEx( fo, nExpOnTaskAll, nPBExpOnTaskAll, sCellClassName );
				// ...списано по причинам:
				writeExpenseCellEx( fo, nExpOnCausesAll, nPBExpOnCausesAll, sCellClassName );
				
				// Затраты проектные, итого:
				writeExpenseCellEx( fo, nExpOnActivity, nPBExpOnActivity, sCellClassName );

				if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) )
				{
					int nLossBaseIndex = m_oMapper.GetColumnsIndexesBase( ExpTypes.OnCauseLoss );
					int nColumnsQnt = m_oMapper.ColumnQnt;
					
					// Проектные списания
					writeExpenseCellEx( fo, nExpOnCausesOnFolder, nPBExpOnCausesOnFolder, sCellClassName );
					for( int nIndex = 0; nIndex < nLossBaseIndex; nIndex++ )
						writeExpenseCellEx( fo, ExpsOnCausesDetail[nIndex], nPBExpCausesDetails[nIndex], sCellClassName );

					// Непроектные списания
					writeExpenseCellEx( fo, ExpOnCausesLoss, nPBExpOnCausesLoss, sCellClassName );
					for( int nIndex = nLossBaseIndex; nIndex < nColumnsQnt; nIndex++ )
						writeExpenseCellEx( fo, ExpsOnCausesDetail[nIndex], nPBExpCausesDetails[nIndex], sCellClassName );
				}
				else
				{
					writeExpenseCellEx( fo, nExpOnCausesOnFolder, nPBExpOnCausesOnFolder, sCellClassName );
					writeExpenseCellEx( fo, ExpOnCausesLoss, nPBExpOnCausesLoss, sCellClassName );
				}

				fo.TREnd();
			}

			
			protected void writeExpenseCellEx( XslFOProfileWriter fo, int nValue, int nPercentBaseValue, string sCellClassName ) 
			{
				double dPercentValue = 0.0;
				if (RepDepartmentExpensesStructure_DataFormat.OnlyTime != m_enDataFormat && 0 != nPercentBaseValue)
					dPercentValue = ( nValue*100.0 ) / ((float)nPercentBaseValue);
				
				switch(m_enDataFormat)
				{
					case RepDepartmentExpensesStructure_DataFormat.OnlyTime:
						// Вывод только времени:
						base.writeExpenseCell( fo, nValue, sCellClassName );
						break;

					case RepDepartmentExpensesStructure_DataFormat.OnlyPercent:
						// Вывод только процентов:
						fo.TRAddCell( dPercentValue.ToString("0.0000"), "r8", 1, 1, sCellClassName );
						break;

					case RepDepartmentExpensesStructure_DataFormat.TimeAndPercent:
						// Вывод и времени и процентов:
						base.writeExpenseCell( fo, nValue, sCellClassName );
						fo.TRAddCell( dPercentValue.ToString("0.0000"), "r8", 1, 1, sCellClassName );
						break;

					default:
						throw new ApplicationException("Ошибка формирования данных строки отчета: нерподдерживаемая форма вывода данных " + m_enDataFormat.ToString());
				}
			}

			
			private bool isShowColumn( RepDepartmentExpensesStructure_OptColsFlags flagColumn ) 
			{
				return ( ((int)(m_enShownColumn & flagColumn)) > 0 );
			}

		}
		
		
		/// <summary>
		/// Представление строки отчета третьей формы
		/// </summary>
		internal class ThisReportRow_Form2 : ThisReportRow 
		{
			public string TrackId = null;
			
			public string Name = null;			//
			public string NameColumn = null;	//
			public string Mail = null;			//

			public int ExpOnTask = 0;			// Затраты на инциденты (задания)
			public int ExpOnActivity = 0;		// Списания на активности 
			public int ExpOnLoss = 0;			// Списания вне активностей
			public int ExpPlan = 0;				// Планируемое время по инцидентам
			public int ExpLeft = 0;				// Оставшееся время по инцидентам
			public int TaskDoneQnt = 0;			// Количество выполненных инцидентов (за период)
			public int TaskInWorkQnt = 0;		// Количество открытых инцидентов

			private int m_nOrdTrackId;

			private int m_nOrdName;				
			private int m_nOrdMail;				
			private int m_nOrdExpType;
			private int m_nOrdExpenses;
			private int m_nOrdExpPlan;
			private int m_nOrdExpLeft;
			private int m_nOrdTaskDoneQnt;
			private int m_nOrdTaskInWorkQnt;

			public ThisReportRow_Form2( IDataReader reader, string sTrackIdColumn, TimeMeasureUnits enTimeMeasure ) 
				: base( enTimeMeasure ) 
			{
				// Получаем ординалы для всех значимых колонок результата:
				m_nOrdTrackId = reader.GetOrdinal(sTrackIdColumn);

				m_nOrdName = ( null==NameColumn || String.Empty==NameColumn ? -1 : reader.GetOrdinal(NameColumn) );
				m_nOrdMail = reader.GetOrdinal("EmpMail");
				m_nOrdDayRate = reader.GetOrdinal("DayRate");
				m_nOrdExpType = reader.GetOrdinal("ExpType");
				m_nOrdExpenses = reader.GetOrdinal("Expenses");
				m_nOrdExpPlan = reader.GetOrdinal("ExpPlan");
				m_nOrdExpLeft = reader.GetOrdinal("ExpLeft");
				m_nOrdTaskDoneQnt = reader.GetOrdinal("TaskDoneQnt");
				m_nOrdTaskInWorkQnt = reader.GetOrdinal("TaskInWorkQnt");
			}

			
			/// <summary>
			/// Вся соль...
			/// </summary>
			/// <param name="reader"></param>
			public bool ReadRow( IDataReader reader ) 
			{
				if ( NameColumn==null || String.Empty==NameColumn )
					m_nOrdName = -1;
				else if (-1 == m_nOrdName )
					m_nOrdName = reader.GetOrdinal( NameColumn );
				
				if ( !reader.IsDBNull(m_nOrdTrackId) )
					TrackId = reader.GetValue( m_nOrdTrackId ).ToString();
				else
					TrackId = String.Empty;

				// Норма для всех строк, относящихся к одному и тому же сотруднику - одинаковая
				DayRate = safeGetInt( reader, m_nOrdDayRate );
				// ... как и наименование:
				if (-1!=m_nOrdName)
					Name = reader.GetString( m_nOrdName );	
				// Почтовый адрес зачитыаем, только если он есть в результирующем наборе:
				Mail = ( reader.IsDBNull(m_nOrdMail) ? null : reader.GetString(m_nOrdMail) );
				
				bool bMoreRows = true;
				for( ; bMoreRows; )
				{
					int nValue = safeGetInt( reader, m_nOrdExpenses );
					if ( 0!=nValue && 0==DayRate )
						throw new ApplicationException( "Ошибка расчета данных отчета: получена отличная от нуля сумма списаний, при нулевой норме рабочего дня!" );

					// Если ExpType есть NULL, то интерпретация его как 0 дела не испортит, 
					// так как в этом случае и Expenses - NULL, т.е. 0
					ExpTypes enExpType = (ExpTypes)safeGetInt( reader, m_nOrdExpType ); 
					switch ( enExpType )
					{
						case ExpTypes.OnIncident:
						case ExpTypes.OnIncidentExternal:
						case ExpTypes.OnIncidentInternal:
							ExpOnTask += nValue; 
							break;

						case ExpTypes.OnCauseFolder:
						case ExpTypes.OnCauseExternal:
						case ExpTypes.OnCauseInternal:
							ExpOnActivity += nValue; 
							break;

						case ExpTypes.OnCauseLoss:
							ExpOnLoss += nValue; 
							break;
					}
				
					ExpPlan += safeGetInt( reader, m_nOrdExpPlan );
					ExpLeft += safeGetInt( reader, m_nOrdExpLeft );
					TaskDoneQnt += safeGetInt( reader, m_nOrdTaskDoneQnt );
					TaskInWorkQnt += safeGetInt( reader, m_nOrdTaskInWorkQnt );
					
					// Переходим к следующей строке набора:
					bMoreRows = reader.Read();
					if ( bMoreRows )
						if ( TrackId != reader.GetValue( m_nOrdTrackId ).ToString() )
							break;
				}

				HasSome = true; 
				return bMoreRows;
			}

			
			/// <summary>
			/// 
			/// </summary>
			/// <param name="row"></param>
			public void Summarize( ThisReportRow_Form2 row ) 
			{
				// ЗАМЕЧАНИЕ:
				// По сути это, конечно, не суммирование. Но и решения вопроса
				// "что считать нормной рабочего дня" при суммировании затрат
				// времени нескольких сотрудников (у котороых, в теории, могут
				// быть разные нормы) - не решен в принципе. Пока всю ситуацию 
				// спасает то, что норма для всех одинаковая и фиксированная. 
				// Именно по этому при суммировании затрат сама норма - просто
				// копируется (вообще оставить ее нулевой тоже нельзя, т.к. 
				// при формировании строки отчета с суммарными данными надо 
				// как-то переводить затраты в "дни, часы, недели")
				DayRate = row.DayRate;
				
				ExpOnTask += row.ExpOnTask;
				ExpOnActivity += row.ExpOnActivity;
				ExpOnLoss += row.ExpOnLoss;
				ExpPlan += row.ExpPlan;
				ExpLeft += row.ExpLeft;
				TaskDoneQnt += row.TaskDoneQnt;
				TaskInWorkQnt += row.TaskInWorkQnt;

				HasSome = true;
			}

			
			/// <summary>
			/// 
			/// </summary>
			public void Zeroing() 
			{
				ExpOnTask = 0;
				ExpOnActivity = 0;
				ExpOnLoss = 0;
				ExpPlan = 0;
				ExpLeft = 0;
				TaskDoneQnt = 0;
				TaskInWorkQnt = 0;
				
				HasSome = false;
			}
			
			
			/// <summary>
			/// 
			/// </summary>
			/// <param name="fo"></param>
			/// <param name="sCellClassName"></param>
			/// <param name="sEmphCellClassName"></param>
			public void WriteRow( XslFOProfileWriter fo, string sCellClassName, string sEmphCellClassName ) 
			{
				int nLeadColSpan = ( RowNum>0 ? 1 : 2 );
				if (null==sEmphCellClassName || String.Empty==sEmphCellClassName)
					sEmphCellClassName = sCellClassName;
				
				string sNameCellContent;
				if (null!=TrackId && String.Empty!=TrackId) 
					sNameCellContent = _GetUserMailAnchor( Name, Mail, new Guid(TrackId), Guid.Empty, Guid.Empty );
				else
					sNameCellContent = xmlEncode(Name);

				fo.TRStart();
				
				if ( RowNum > 0 )
					fo.TRAddCell( RowNum, "i4", 1, 1, sCellClassName );
				fo.TRAddCell( sNameCellContent, "string", nLeadColSpan, 1, sCellClassName );
					
				fo.TRAddCell( TaskDoneQnt, "i4", 1, 1, sCellClassName );
				fo.TRAddCell( TaskInWorkQnt, "i4", 1, 1, sCellClassName ); 

				writeExpenseCell( fo, ExpOnTask + ExpOnActivity + ExpOnLoss, sEmphCellClassName );
				writeExpenseCell( fo, ExpOnTask, sCellClassName );
				writeExpenseCell( fo, ExpOnActivity + ExpOnLoss, sCellClassName );
				writeExpenseCell( fo, ExpOnActivity, sCellClassName );
				writeExpenseCell( fo, ExpOnLoss, sCellClassName );

				writeExpenseCell( fo, ExpPlan, sCellClassName );
				writeExpenseCell( fo, ExpOnTask, sCellClassName );
				writeExpenseCell( fo, ExpLeft, sCellClassName );

				fo.TREnd();
			}
		}


		#endregion
		
		/// <summary>
		/// Расчет и получение основного набора данных отчета.
		/// </summary>
		/// <param name="cn"></param>
		/// <param name="oParams"></param>
		/// <returns>
		/// Данные отчета, как IDataReader
		/// </returns>
		private IDataReader getReportData(IReportDataProvider dataProvider , ThisReportParams oParams ) 
		{
            return dataProvider.GetDataReader("dsMain", oParams);
		}

		
		/// <summary>
		/// Формирование шапки таблицы отчета
		/// </summary>
		/// <param name="fo"></param>
		/// <returns>Кол-во сформированных колонок</returns>
		private int writeHeader( XslFOProfileWriter fo ) 
		{
			string sColName;
			align enExpColAlign = ( TimeMeasureUnits.Days == m_oParams.TimeMeasure? align.ALIGN_LEFT : align.ALIGN_RIGHT );
			int nColL1;
			int nColL2;
			int nRetColumnsQnt = 0;

			if ( RepDepartmentExpensesStructure_ReportForm.ByEmployeeWithTasksDetali != m_oParams.ReportForm )
			{					
				#region Форма отчета - "Cуммарные данные по подразделению" или "Данные по каждому сотруднику"
				
				sColName = 
					RepDepartmentExpensesStructure_ReportForm.ByDepartment == m_oParams.ReportForm ?
					"Наименование подразделения" : 
					"Сотрудник / наименование подразделения";

                fo.TAddColumn("№", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "3%", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddColumn(sColName, align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "27%", align.ALIGN_NONE, valign.VALIGN_NONE, ITRepStyles.TABLE_HEADER);
				nRetColumnsQnt = 2;
				
				if ( m_oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowPeriodRate) > 0 )
				{
					fo.TAddColumn( "Норма рабочего времени", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px",align.ALIGN_NONE, valign.VALIGN_NONE , null );
					nRetColumnsQnt += 1;
				}
				
				if ( m_oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowPeriodDisbalance) > 0 )
					nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, 0, "Дисбаланс" );
				
				if ( m_oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowUtilization) > 0 )
				{
					nColL1 = fo.TAddColumn( "Коэффициент утилизации (%)", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
                    fo.TAddSubColumn(nColL1, "Внеш. проекты", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "80px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                    fo.TAddSubColumn(nColL1, "Внутр. проекты", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "80px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                    fo.TAddSubColumn(nColL1, "Общий", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "80px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
					nRetColumnsQnt += 3;
				}
				
				nColL1 = fo.TAddColumn( "Затраты времени", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
				nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL1, "Общие" );
				nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL1, "Затрачено на задания" );
				nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL1, "Списано по причинам" );
				nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL1, "Затраты проектные, всего" );

				nColL1 = fo.TAddColumn( "Детализация списаний", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
				nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL1, "Списания проектные, всего" );
				// Детализация проектных списаний по причинам (опционально):
				if ( m_oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) > 0 )
				{
					nColL2 = fo.TAddSubColumn( nColL1, "По причинам списания", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
					foreach( string sName in m_oMapper.GetColumnsNames(ExpTypes.OnCauseFolder) )
						nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL2, sName );
				}
					
				nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL1, "Списания не проектные, всего" );
				// Детализация не проектных списаний по причинам (опционально):
				if ( m_oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) > 0 )
				{
					nColL2 = fo.TAddSubColumn( nColL1, "По причинам списания", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
					foreach( string sName in m_oMapper.GetColumnsNames(ExpTypes.OnCauseLoss) )
						nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL2, sName );
				}

				#endregion
			}
			else
			{
				#region Форма отчета - "Данные по каждому сотруднику, с данными по заданиям"

                fo.TAddColumn("№", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "3%", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                fo.TAddColumn("Сотрудник", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "27%", align.ALIGN_NONE, valign.VALIGN_NONE, null);

				nColL1 = fo.TAddColumn( "Задания", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
                fo.TAddSubColumn(nColL1, "Выполнено", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                fo.TAddSubColumn(nColL1, "Осталось", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);

				nColL1 = fo.TAddColumn( "Затраты времени", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
                fo.TAddSubColumn(nColL1, "Всего", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nColL1, "Затрачено на задания", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
				nColL2 = fo.TAddSubColumn( nColL1, "Списано", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
                fo.TAddSubColumn(nColL2, "Всего", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                fo.TAddSubColumn(nColL2, "На проекты", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                fo.TAddSubColumn(nColL2, "Вне проектов", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);

				nColL1 = fo.TAddColumn( "Данные по заданиям", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
                fo.TAddSubColumn(nColL1, "Запланировано", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                fo.TAddSubColumn(nColL1, "Затрачено", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                fo.TAddSubColumn(nColL1, "Осталось", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);

				nRetColumnsQnt = 12;

				#endregion
			}

			return nRetColumnsQnt;
		}

		
		/// <summary>
		/// Вспомогательный метод формирования шапки таблицы отчета - включение
		/// описания шапки для колонки с затратами: в зависимости от заданного 
		/// представления (форматы времени, включение отображения %%) формирует
		/// нужный тип / описание / подчиенные колонки
		/// </summary>
		/// <param name="fo"></param>
		/// <param name="oParams">Параметры</param>
		/// <param name="nGenColIndex">Индекс вышестоящей колонки (если нет, то 0)</param>
		/// <param name="sName">Текст в шапке</param>
		/// <returns>Кол-во сформированных колонок</returns>
		private int writeHeadExpensesSubColumns( 
			XslFOProfileWriter fo, 
			ThisReportParams oParams, 
			int nGenColIndex, 
			string sName ) 
		{
			int nColumnIndex;
			int nRetColumnQnt = 0;
			align enExpColAlign = ( TimeMeasureUnits.Days == oParams.TimeMeasure? align.ALIGN_LEFT : align.ALIGN_RIGHT );

			switch( oParams.DataFormat )
			{
				case RepDepartmentExpensesStructure_DataFormat.TimeAndPercent:
                    nColumnIndex = fo.TAddSubColumn(nGenColIndex, sName, align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, String.Empty,align.ALIGN_NONE, valign.VALIGN_NONE, ITRepStyles.TABLE_HEADER);
                    fo.TAddSubColumn(nColumnIndex, "Время", enExpColAlign, valign.VALIGN_MIDDLE, null, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, ITRepStyles.TABLE_HEADER);
                    fo.TAddSubColumn(nColumnIndex, "%%", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "80px", align.ALIGN_NONE, valign.VALIGN_NONE, ITRepStyles.TABLE_HEADER);
					nRetColumnQnt = 2;
					break;

				case RepDepartmentExpensesStructure_DataFormat.OnlyTime:
                    fo.TAddSubColumn(nGenColIndex, sName, enExpColAlign, valign.VALIGN_MIDDLE, null, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, ITRepStyles.TABLE_HEADER);
					nRetColumnQnt = 1;
					break;

				case RepDepartmentExpensesStructure_DataFormat.OnlyPercent:
                    fo.TAddSubColumn(nGenColIndex, sName + " (%%)", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "80px", align.ALIGN_NONE, valign.VALIGN_NONE, ITRepStyles.TABLE_HEADER);
					nRetColumnQnt = 1;
					break;
			}

			return nRetColumnQnt;
		}
	}
}