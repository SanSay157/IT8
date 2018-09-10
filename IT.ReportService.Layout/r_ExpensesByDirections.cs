//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
// Код формирования отчета "Затраты в разрезе направлений"
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using System.Text;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Reports
{
	/// <summary>
	/// </summary>
	public class r_ExpensesByDirections: CustomITrackerReport 
	{
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data)
        {
            buildThisReport(data.RepGen, data.Params, data.DataProvider, data.CustomData);
        }
        /// <summary>
		/// Внутренний класс, представляющий все актуальные параметры отчета
		/// </summary>
		public class ThisReportParams 
		{
			/// <summary>
			/// Вид направления анализа; перечень вариантов, определеяемых на основании
			/// задания значений параметров "Организация" (Organization) и "Активность"
			/// (Folder)
			/// </summary>
			public enum AnalysisDirectionEnum 
			{
				/// <summary>
				/// Направление анализа "Организации - Направления", все организации
				/// </summary>
				ByCustomer_AllCustomners = 0,

				/// <summary>
				/// Направление анализа "Организации - Направления", конкретная организация
				/// </summary>
				ByCustomer_TargetCustomer = 1,

				/// <summary>
				/// Направление анализа "Активность - Направления", конкретная активность
				/// </summary>
				ByActivity = 2
			}

			
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
			/// Направление анализа, вычисляемое значение
			/// </summary>
			public AnalysisDirectionEnum AnalysisDirection; 

			/// <summary>
			/// Идентификатор организации, при анализе "Организации - Направления"
			/// </summary>
			public object Organization;
			/// <summary>
			/// Идентификатор активности, при анализе "Активности - Направления"
			/// </summary>
			public object Folder;

			/// <summary>
			/// Флаги типов активностей, данные которых включаются в анализ
			/// (см. FolderTypesFlags) Нулевое значение == "Проект + Тендер + Пресейл"
			/// Имеет смысл только при направлении анализа "Организации - Направления".
			/// </summary>
			public int FolderType;
			/// <summary>
			/// Признак учета данных только открытых активностей, состояние которых есть
			/// "Открыто" и "Ожидание закрытия". Имеет смысл только при направлении 
			/// анализа "Организации - Направления".
			/// </summary>
			public bool OnlyActiveFolders;
			/// <summary>
			/// Признак включения данных о последнем изменении определения направления
			/// для заданной активности. Имеет смысл только при направлении анализа 
			/// "Активности - Направления".
			/// </summary>
			public bool ShowHistoryInfo;
			/// <summary>
			/// Признак включения режима детализации
			/// </summary>
			public bool ShowDetails;
			/// <summary>
			/// Форма представления времени
			///		0 - Дни, часы, минуты;
			///		1 - Часы
			/// </summary>
			public TimeMeasureUnits TimeMeasure;
			/// <summary>
			/// Тип сортмировки данных в отчете: 
			///		0 - по намименованию активности, 
			///		1 - по сумме затрат
			/// </summary>
			public int SortBy;

			
            /// <summary>
            /// Признак включения в заголовок отчета заданных параметров
            /// </summary>
			public bool ShowRestrictions;

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
				// Задание дат начала и конца отчетного периода
				IsSpecifiedIntervalBegin = !Params.GetParam("IntervalBegin").IsNull;
				IntervalBegin = ( IsSpecifiedIntervalBegin? Params.GetParam("IntervalBegin").Value : DBNull.Value );
				IsSpecifiedIntervalEnd = !Params.GetParam("IntervalEnd").IsNull;
				IntervalEnd = ( IsSpecifiedIntervalEnd? Params.GetParam("IntervalEnd").Value : DBNull.Value );
			
				// Вид направления анализа определяется на основании задания идентификаторов 
				// организации или активности; сразу корректируем значения параметров: если 
				// они не заданы, то используем в качестве значения DBNull:
				Organization = Guid.Empty;
				Folder = Guid.Empty;
				if ( !Params.GetParam("Folder").IsNull )
				{
					AnalysisDirection = AnalysisDirectionEnum.ByActivity;
					Folder = Params.GetParam("Folder").Value;
					Organization = DBNull.Value;
				}
				else if ( !Params.GetParam("Organization").IsNull )
				{
					AnalysisDirection = AnalysisDirectionEnum.ByCustomer_TargetCustomer;
					Organization = Params.GetParam("Organization").Value;
					Folder = DBNull.Value;
				}
				else
				{
					AnalysisDirection = AnalysisDirectionEnum.ByCustomer_AllCustomners;
					Organization = DBNull.Value;
					Folder = DBNull.Value;
				}

				// Типы активностей:
				FolderType = (int)Params.GetParam("FolderType").Value;
				if ( AnalysisDirectionEnum.ByActivity == AnalysisDirection )
					FolderType = 0;

				// Учет данных только открытых активностей
				OnlyActiveFolders = ( 0 != (int)Params.GetParam("OnlyActiveFolders").Value );
				if ( AnalysisDirectionEnum.ByActivity == AnalysisDirection )
					OnlyActiveFolders = false;
		
				// Отображение данных об истории изменения данных по направлениям для активности
				ShowHistoryInfo = ( 0 != (int)Params.GetParam("ShowHistoryInfo").Value );
				if ( AnalysisDirectionEnum.ByActivity != AnalysisDirection )
					ShowHistoryInfo = false;

				// Детализация данных в отчете
				ShowDetails = ( 0 != (int)Params.GetParam("ShowDetails").Value );
				// Форма представления времени;
				TimeMeasure = (TimeMeasureUnits)((int)Params.GetParam("TimeMeasureUnits").Value);
				// Тип сортировки (0 - по наименованию направления, 1 - по сумме)
				SortBy = (int)Params.GetParam("SortBy").Value;	
				// Признак отображения параметров отчета в заголовке
				ShowRestrictions = ( 0 != (int)Params.GetParam("ShowRestrictions").Value );
			}

			
			/// <summary>
			/// Формирует текст XSL-FO, представляющий данные заданных параметров, и 
			/// записывает его как текст подзаголовка формируемого отчета
			/// </summary>
			/// <param name="foWriter"></param>
			/// <param name="cn"></param>
			public void WriteParamsInHeader( XslFOProfileWriter foWriter, IReportDataProvider Provider ) 
			{
				// XSL-FO с перечнем параметров будем собирать сюда:
				StringBuilder sbBlock = new StringBuilder();
				string sParamValue;

				// #1: Дата начала и окончания отчетного периода. 
				// Любая из этих дат может быть не задана; если это так, то, с соответствии 
				// с требованиями, в заголовке отчета должны выводиться соответствующие 
				// расчетные даты - соответственно дата самого раннего и дата самого позднего
				// списаний (для множества проектов, получаемых в соотв. ограничениями, 
				// задаваемыми остальными парамитрами). Расчетные данные получаются при 
				// помощи специальной UDF; запрос будет выполняться только если необходимо:
				
				string sPossibleIntervalBegin = "нет данных";	// Строка с расчетной датой начала периода
				string sPossibleIntervalEnd = "нет данных"; 	// Строка с расчетной датой завершения периода

				if ( !IsSpecifiedIntervalBegin || !IsSpecifiedIntervalEnd )
				{
					// Для расчета самой возможных даты надо выполнить UDF dbo.GetMinimaxBoundingDates:
					
			
						using( IDataReader reader = Provider.GetDataReader("dsDates", this) )
						{
							if ( !reader.Read() )
								throw new ApplicationException("Ошибка получения дополнительных данных (расчетная дата начала периода)");
							
							// Расчетная дата начала периода (первый столбец в рекордсете):
							if ( !reader.IsDBNull(0) )
								sPossibleIntervalBegin = reader.GetDateTime(0).ToString("dd.MM.yyyy");
							
							// Расчетная дата завершения периода (второй столбец в рекордсете):
							if ( !reader.IsDBNull(1) )
								sPossibleIntervalEnd = reader.GetDateTime(1).ToString("dd.MM.yyyy");
						}
					
				}

				if ( IsSpecifiedIntervalBegin )
					sParamValue = ((DateTime)IntervalBegin).ToString("dd.MM.yyyy");
				else
					sParamValue = String.Format( "не задана (расчетная дата - {0})", sPossibleIntervalBegin );
				sbBlock.Append( getParamValueAsFoBlock( "Дата начала отчетного периода", sParamValue ) );
				
				if ( IsSpecifiedIntervalEnd )
					sParamValue = ((DateTime)IntervalEnd).ToString("dd.MM.yyyy");
				else
					sParamValue = String.Format( "не задана (расчетная дата - {0})", sPossibleIntervalEnd );
				sbBlock.Append( getParamValueAsFoBlock( "Дата окончания отчетного периода", sParamValue ) );


				// #2: Направление анализа:
				if (AnalysisDirectionEnum.ByActivity == AnalysisDirection)
					sParamValue = "Активности - Направления";
				else 
					sParamValue = "Организации - Направления";
				sbBlock.Append( getParamValueAsFoBlock( "Направление анализа", sParamValue ) );

				
				// #3: Организация-Клиент или Активность:
				// Если задано, то что-то одно (определимся на основании "направления анализа"),
				// возможно ни то, ни другое. Если задано, то полное наименование возьмем из БД:
				if (AnalysisDirectionEnum.ByCustomer_AllCustomners == AnalysisDirection)
					sbBlock.Append( getParamValueAsFoBlock( "Организация", "Все организации" ) );
				else
				{
					
				    sParamValue = (string)Provider.GetValue("dsParams",this);
					if (AnalysisDirectionEnum.ByActivity == AnalysisDirection)
						sbBlock.Append( getParamValueAsFoBlock( "Активность", sParamValue ) );
					else
						sbBlock.Append( getParamValueAsFoBlock( "Организация", sParamValue ) );
				}


				// #4: Доп. условия на типы активности и на отбор только открытых активностей -
				// работает только в случае направления анализа "Организации - Направления":
				if (AnalysisDirectionEnum.ByActivity != AnalysisDirection)
				{
					FolderTypeFlags flags = (0!=FolderType)? 
						(FolderTypeFlags)FolderType :
						(FolderTypeFlags.Project | FolderTypeFlags.Tender | FolderTypeFlags.Presale);
					sParamValue = FolderTypeFlagsItem.ToStringOfDescriptions( flags );
					sbBlock.Append( getParamValueAsFoBlock( "Включать данные активностей (по типам)", sParamValue ) );

					sbBlock.Append( getParamValueAsFoBlock( 
							"Включать данные только открытых активностей", 
							OnlyActiveFolders? 
								"Да (активности в состояниях \"Открыто\" и \"Ожидание закрытия\")" : 
								"Нет (активности во всех состояниях)" 
						));
				}
				else
					sbBlock.Append( getParamValueAsFoBlock( 
							"Отображать данные о последнем изменении определения направлений", 
							ShowHistoryInfo? "Да" : "Нет" 
						));

				
				// #5: Общие параметры: детализация:
				if (!ShowDetails) 
					sParamValue = "Нет";
				else
					sParamValue = (AnalysisDirectionEnum.ByCustomer_AllCustomners == AnalysisDirection)? "По организациям" : "По активностям";
				sbBlock.Append( getParamValueAsFoBlock( "Детализация", sParamValue ) );
				
				// ...форма представления времени
				sbBlock.Append( getParamValueAsFoBlock( 
						"Представление времени", 
						TimeMeasureUnitsItem.GetItem(TimeMeasure).Description 
					));
				
				// ...сортировка:
				sbBlock.Append( getParamValueAsFoBlock( "Сортировка", (0==SortBy? "По направлению" : "По сумме затрат") ) );

				// ВЫВОД ПОДЗАГОЛОВКА:
				foWriter.AddSubHeader( 
					@"<fo:block text-align=""left""><fo:block font-weight=""bold"">Параметры отчета:</fo:block>" + 
					sbBlock.ToString() +
					@"</fo:block>"
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
					"<fo:block><fo:inline>{0}: </fo:inline><fo:inline font-weight=\"bold\">{1}</fo:inline></fo:block>",
					xmlEncode(sParamName),
					xmlEncode(sParamValueText)
				);
			}
		}

		
		/// <summary>
		/// Параметризованный конструктор, вызваемый подсистемой ReportService
		/// </summary>
		/// <param name="ReportProfile"></param>
		/// <param name="ReportName"></param>
		public r_ExpensesByDirections( reportClass ReportProfile, string ReportName ) 
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
		protected void buildThisReport( XslFOProfileWriter foWriter, ReportParams Params, IReportDataProvider Provider, object CustomData ) 
		{
			// Получим параметры:
			ThisReportParams oParams = new ThisReportParams( Params );
			
			// ФОРМИРОВАНИЕ ОТЧЕТА
            foWriter.WriteLayoutMaster();
			foWriter.StartPageSequence();
			foWriter.StartPageBody();

			// ЗАГОЛОВОК
			foWriter.Header( "Затраты в разрезе направлений" );
			// Параметры отчета в заголовке?
			if (oParams.ShowRestrictions)
				oParams.WriteParamsInHeader( foWriter, Provider );

            writeBody(foWriter, oParams, Provider);

			foWriter.EndPageBody();
			foWriter.EndPageSequence();
		}


		/// <summary>
		/// Фомрирование "тела" отчета 
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="oParams"></param>
		/// <param name="cn"></param>
		private void writeBody( XslFOProfileWriter foWriter, ThisReportParams oParams, IReportDataProvider Provider )
		{
			
				using( IDataReader reader = Provider.GetDataReader("dsMain", oParams) )
				{
					// Вне зависимости от параметров в результате первым идет рекордсет с 
					// результатами анализа допустимости анализа - это будет или одна строка
					// с текстом "несоответствий не обрнаружено" или массированный рекордсет
					// с перечнем активностей, для которых обнаружены баги. 
					// NB! Если рекордсет пришел пустой - это ошибка!
					if ( !reader.Read() )
						throw new ApplicationException( "Ошибка получения данных отчета: запрос процедуры вернул пустой результирующий набор!");
					
					// ... проверим набор с данными первого рекордсета: если это строка 
					// в один столбец, то это хороший результат; иначе - это набор с перечнем
					// активностей, в которых найдены несоответствия
					IDictionary rowData = _GetDataFromDataRow(reader);
					if ( 1!=rowData.Count )
					{
						#region Отображение данных с ошибками

						// Обнаружены случаи недопустимости выполнения анализа.
						// В рекордсете идут:
						//	- CustomerID	- идентификатор организации, Guid
						//	- CustomerName	- наименование организации
						//	- FolderID		- иденетификатор активности, в котором обнаружена проблема
						//	- FullName		- полное наименование (путь) проекта
						//	- ErrorType		- "тип" проблемы, здесь:
						//					1 - нет направлений, 
						//					2 - не заданы доли, 
						//					3 - нарушения в задании направлений для подчиненных активностей/каталогов, 
						//					4 - что-то еще (ошибка в определении типа проблемы, по идее так быть не должно)

						// #1: Служебное сообщение об обнаружении ошибок
						foWriter.TStart( false, "WARNING_MESSAGE_TABLE", false );
						foWriter.TAddColumn( "Сообщение" );
						foWriter.TRStart();
						foWriter.TRAddCell( 
							"Внимание! Выполнение анализа затрат невозможно: обнаружены ошибки определения направлений для активностей!",
							null, 1, 1, "WARNING_MESSAGE" );
						foWriter.TREnd();
						foWriter.TEnd();

						// #2: Заголовок таблицы с перечнем активностей, в которых обнаружены нарушения
						foWriter.TStart( true, "TABLE", false );
						foWriter.TAddColumn( "Активность", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null,String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER"  );
                        foWriter.TAddColumn("Ошибка определения", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");

						// ... данные сгруппированы по организации-Клиенту: 
						string sCustomerName = rowData["CustomerName"].ToString();
						bool bIsNextCusomerData = true;

						for( bool bMoreRows = true; bMoreRows;  )
						{
							// ...если при последнем чтении строки обнаружено условие перехода
							// к данным следующей организации-Клиента, то выводим заголовок 
							// группы - наименование Клиента:
							if (bIsNextCusomerData)
							{
								foWriter.TRStart();
								foWriter.TRAddCell( xmlEncode(sCustomerName), null, 2, 1, "GROUP_HEADER" );
								foWriter.TREnd();
							}
							
							// Текстовое представление "типа" нарушения:
							string sErrorDescription;
							switch ((int)rowData["ErrorType"])
							{
								case 1: sErrorDescription = "(ТИП-1) Для активности не заданы направления"; break;
								case 2: sErrorDescription = "(ТИП-2) Для направления активности не заданы доли затрат"; break;
								case 3: sErrorDescription = "(ТИП-3) Для подчиненной активности / каталога указано направление, отличное от направлений, заданных для активности"; break;
								default: sErrorDescription = "(Ошибка определения типа несоответствия)"; break;
							}

							// Выводим данные по одной активности; при этом наименование активности
							// оформляется как анкер, при клике на который будет отображаться всплывающее
							// меню с доступными операциями - просмотр, редактирование, отчеты и т.д.
							foWriter.TRStart();
							foWriter.TRAddCell( _GetFolderAnchor( rowData["FullName"], (Guid)rowData["FolderID"], true ), null, 1, 1, "TABLE_CELL" );
							foWriter.TRAddCell( sErrorDescription, null, 1, 1, "TABLE_CELL" );
							foWriter.TREnd();

							// Читаем след. строку (если данные еще есть); при этом определяем 
							// условие перехода к следующей грппе данных, по след. Клиенту:
							bMoreRows = reader.Read();
							if (bMoreRows)
								rowData = _GetDataFromDataRow(reader);
							
							bIsNextCusomerData = ( sCustomerName != rowData["CustomerName"].ToString() );
							if (bIsNextCusomerData)
								sCustomerName = rowData["CustomerName"].ToString();
						}
						foWriter.TEnd();

						#endregion
						
						// На этом отчет заканчивается!
						return;
					}
					
					// Несоответствий нет - выводим данные:
					if ( !reader.NextResult() )
						throw new ApplicationException("Отсутствует основной результирующий набор! Текст запроса: ");

					// ЗАГОЛОВОК ОСНОВНОЙ ТАБЛИЦЫ
					string sDirsColumnName;
					bool bWithActivityQnt = ( ThisReportParams.AnalysisDirectionEnum.ByActivity != oParams.AnalysisDirection );

					if ( ThisReportParams.AnalysisDirectionEnum.ByCustomer_AllCustomners == oParams.AnalysisDirection && oParams.ShowDetails )
						sDirsColumnName = "Направления / организации";
					else if ( ThisReportParams.AnalysisDirectionEnum.ByActivity == oParams.AnalysisDirection && oParams.ShowDetails )
						sDirsColumnName = "Направления / активности";
					else
						sDirsColumnName = "Направления";

					foWriter.TStart( true, "TABLE", false );
                    foWriter.TAddColumn("№", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "5%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
                    foWriter.TAddColumn(sDirsColumnName, align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, (bWithActivityQnt ? "40%" : "55%"), align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
					if (bWithActivityQnt)
                        foWriter.TAddColumn("Количество активностей", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "15%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
                    foWriter.TAddColumn("Затраты", (TimeMeasureUnits.Days == oParams.TimeMeasure ? align.ALIGN_LEFT : align.ALIGN_RIGHT), valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
                    //foWriter.TAddColumn("Сумма затрат", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");

					// ПОКА - КОНСТАНТА! TODO!
					int nWorkDayDuration = 600;

					if ( oParams.ShowDetails )
					{
						#region ДАННЫЕ С ДЕТАЛИЗАЦИЕЙ
						//	- DirectionName - Наименование направления;
						//	- DetailID		- Идентификатор детализирующей сущности (Организация / Активность)
						//	- DetailName	- Наименование детализируюшей сущности 
						//	- ActivityQnt	- Количество активностей
						//	- ExpensesSum	- Сумма затрат

						string sDirectionName = null;
						int nSubTotalTime = 0;	// промежуточный итог по сумме затраченного времени
						int nTotalTime = 0;		// общий итог по сумме затраченного времени
						int nSubTotalQnt = 0;	// промежуточный итог по количеству активностей (по направлению)
						int nTotalQnt = 0;		// общий итог по количеству активностей
						int nRowNum = 0;		// сквозная нумерация строк детализации

						// Признак, что наименование детализирующей сущности есть гиперссылка:
						// Сейчас это единственный случай - при направлении анализа "Организации..",
						// в случае указания конкретной организации - когда в кач. детализации 
						// выводятся активности. Для них и формляем анкер с всплывающим меню операций:
						bool bIsDetailNameAsHref = ( ThisReportParams.AnalysisDirectionEnum.ByCustomer_TargetCustomer == oParams.AnalysisDirection );	
						
						while( reader.Read() )
						{
							IDictionary rec = _GetDataFromDataRow( reader );

							// Если очередная рассматриваемая строка относится уже к другой группе,
							// то сформируем строку отчета с данными подытога
							if ( null==sDirectionName || sDirectionName!=rec["DirectionName"].ToString() )
							{
								if ( null!=sDirectionName )
								{
									foWriter.TRStart();
									foWriter.TRAddCell( "Итого по направлению", "string", 2, 1, "GROUP_FOOTER" );
									
									if (bWithActivityQnt)
										foWriter.TRAddCell( nSubTotalQnt, "i4", 1, 1, "GROUP_FOOTER" );
									
									if (TimeMeasureUnits.Days == oParams.TimeMeasure)
										foWriter.TRAddCell( _FormatTimeStringAtServer(nSubTotalTime,nWorkDayDuration), "string", 1, 1, "GROUP_FOOTER" );
									else
										foWriter.TRAddCell( string.Format("{0:0.##}", nSubTotalTime/60.0), "r8", 1, 1, "GROUP_FOOTER" );
									
									//foWriter.TRAddCell( (nSubTotalSum / 100.0).ToString("F2"), "fixed.14.4", 1, 1, "GROUP_FOOTER" );
									foWriter.TREnd();
								}
								
								sDirectionName = rec["DirectionName"].ToString();
								nSubTotalTime = 0;
								nSubTotalQnt = 0;

								// Текст с "заголовком" следующей группы:
								foWriter.TRStart();
								foWriter.TRAddCell( xmlEncode(sDirectionName), "string", ( bWithActivityQnt ? 5 : 4 ), 1, "GROUP_HEADER" );
								foWriter.TREnd();
							}
							
							// Зачитываем данные
							int nTime = Int32.Parse( rec["ExpensesTime"].ToString() );
							nSubTotalTime += nTime;
							nTotalTime += nTime;

							/*int nSum = Int32.Parse( rec["ExpensesSum"].ToString() );
							nSubTotalSum += nSum;
							nTotalSum += nSum;*/

							int nQnt = Int32.Parse( rec["ActivityQnt"].ToString() );
							nSubTotalQnt += nQnt;
							nTotalQnt += nQnt;

							nRowNum += 1;

							// Формируем соответствующую строку отчета:
							foWriter.TRStart();
							foWriter.TRAddCell( nRowNum, "i4", 1, 1, "TABLE_CELL_ROWNUM" );
							
							if (bIsDetailNameAsHref)
								foWriter.TRAddCell( _GetFolderAnchor( rec["DetailName"].ToString(), (Guid)rec["DetailID"], true ), "string", 1, 1, "TABLE_CELL" );
							else
								foWriter.TRAddCell( xmlEncode(rec["DetailName"]), "string", 1, 1, "TABLE_CELL" );
							
							if (bWithActivityQnt)
								foWriter.TRAddCell( nQnt, "i4", 1, 1, "TABLE_CELL" );

							if (TimeMeasureUnits.Days == oParams.TimeMeasure)
								foWriter.TRAddCell( _FormatTimeStringAtServer(nTime,nWorkDayDuration), "string", 1, 1, "TABLE_CELL" );
							else
								foWriter.TRAddCell( string.Format("{0:0.##}",nTime/60.0), "r8", 1, 1, "TABLE_CELL" );

							//foWriter.TRAddCell( (nSum / 100.0).ToString("F2"), "fixed.14.4", 1, 1, "TABLE_CELL" );
							foWriter.TREnd();
						}

						// Строка с последним накопленным подитогом (если такой был)
						if (null!=sDirectionName)
						{
							foWriter.TRStart();
							foWriter.TRAddCell( "Итого по направлению", "string", 2, 1, "GROUP_FOOTER" );
							
							if (bWithActivityQnt)
								foWriter.TRAddCell( nSubTotalQnt, "i4", 1, 1, "GROUP_FOOTER" );

							if (TimeMeasureUnits.Days == oParams.TimeMeasure)
								foWriter.TRAddCell( _FormatTimeStringAtServer(nSubTotalTime,nWorkDayDuration), "string", 1, 1, "GROUP_FOOTER" );
							else
								foWriter.TRAddCell( string.Format("{0:0.##}", nSubTotalTime/60.0), "r8", 1, 1, "GROUP_FOOTER" );

							//foWriter.TRAddCell( (nSubTotalSum / 100.0).ToString("F2"), "fixed.14.4", 1, 1, "GROUP_FOOTER" );
							foWriter.TREnd();
						}

						// Строка с общим итогом по всему отчету
						foWriter.TRStart();
						foWriter.TRAddCell( "Итого", "string", 2, 1, "TABLE_FOOTER" );
						
						if (bWithActivityQnt)
							foWriter.TRAddCell( nTotalQnt, "i4", 1, 1, "TABLE_FOOTER" );

						if (TimeMeasureUnits.Days == oParams.TimeMeasure)
							foWriter.TRAddCell( _FormatTimeStringAtServer(nTotalTime,nWorkDayDuration), "string", 1, 1, "TABLE_FOOTER" );
						else
							foWriter.TRAddCell( string.Format("{0:0.##}", nTotalTime/60.0), "r8", 1, 1, "TABLE_FOOTER" );

						//foWriter.TRAddCell( (nTotalSum / 100.0).ToString("F2"), "fixed.14.4", 1, 1, "TABLE_FOOTER" );
						foWriter.TREnd();

						#endregion
					}
					else
					{
						#region ДАННЫЕ БЕЗ ДЕТАЛИЗАЦИИ
						//	- DirectionName - Наименование направления;
						//	- ActivityQnt	- Количество активностей
						//	- ExpensesSum	- Сумма затрат

						int nTotalTime = 0;
						int nTotalQnt = 0;
						int nRowNum = 0;
						
						while( reader.Read() )
						{
							// Зачитываем значения текущей строки:
							IDictionary rec = _GetDataFromDataRow( reader );

							int nTime = Int32.Parse( rec["ExpensesTime"].ToString() );
							nTotalTime += nTime;

							/* Убираем Фин данные из отчета
                             int nSum = Int32.Parse( rec["ExpensesSum"].ToString() );
							nTotalSum += nSum;*/

							int nQnt = Int32.Parse( rec["ActivityQnt"].ToString() );
							nTotalQnt += nQnt;

							nRowNum += 1;

							// Формируем представление строки в XSL-FO:
							foWriter.TRStart();
							foWriter.TRAddCell( nRowNum, "i4", 1, 1, "TABLE_CELL" );
							foWriter.TRAddCell( xmlEncode(rec["DirectionName"]), "string", 1, 1, "TABLE_CELL" );
							
							if (bWithActivityQnt)
								foWriter.TRAddCell( nQnt, "i4", 1, 1, "TABLE_CELL" );

							if (TimeMeasureUnits.Days == oParams.TimeMeasure)
								foWriter.TRAddCell( _FormatTimeStringAtServer(nTime,nWorkDayDuration), "string", 1, 1, "TABLE_CELL" );
							else
								foWriter.TRAddCell( string.Format("{0:0.##}", nTime/60.0), "r8", 1, 1, "TABLE_CELL" );
							
							//foWriter.TRAddCell( (nSum / 100.0).ToString("F2"), "fixed.14.4", 1, 1, "TABLE_CELL" );
							foWriter.TREnd();
						}

						foWriter.TRStart();
						foWriter.TRAddCell( "Итого", "string", 2, 1, "TABLE_FOOTER" );

						if (bWithActivityQnt)
							foWriter.TRAddCell( nTotalQnt, "i4", 1, 1, "TABLE_FOOTER" );

						if (TimeMeasureUnits.Days == oParams.TimeMeasure)
							foWriter.TRAddCell( _FormatTimeStringAtServer(nTotalTime,nWorkDayDuration), "string", 1, 1, "TABLE_FOOTER" );
						else
							foWriter.TRAddCell( string.Format("{0:0.##}", nTotalTime/60.0), "r8", 1, 1, "TABLE_FOOTER" );

						//foWriter.TRAddCell( (nTotalSum / 100.0).ToString("F2"), "fixed.14.4", 1, 1, "TABLE_FOOTER" );
																				 
						foWriter.TREnd();

						#endregion
					}

					foWriter.TEnd();
                }
				#region ДОПОЛНИТЕЛНЫЕ ДАННЫЕ
				// Если направление анализа - "Активность-Направления" и задан признак отображения
				// данных о последнем изменении определения направления для активности:
				if ( ThisReportParams.AnalysisDirectionEnum.ByActivity == oParams.AnalysisDirection && oParams.ShowHistoryInfo )
				{
					// Получение исторической информации - когда и кто последний раз изменил определение направлений
                    object oScalar = Provider.GetValue("dsHistory", oParams);
					string sNoteText = String.Format( 
							"<fo:inline>Последнее изменение определения направлений: </fo:inline><fo:inline font-weight=\"bold\">{0}</fo:inline>",
							(null!=oScalar? xmlEncode(oScalar.ToString()) : "(нет данных")
						);
					
					// Формируем таблицу с "исторической справкой":
					// NB! Заголовок здесь НЕ ОТОБРАЖАЕТСЯ!
					foWriter.TStart( false, "TABLE_NOTE", false );
                    foWriter.TAddColumn("Замечание", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "100%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_NOTE_HEADER");

					foWriter.TRStart();
					foWriter.TRAddCell( sNoteText, null, 1, 1, "TABLE_NOTE_CELL" );
					foWriter.TREnd();

					foWriter.TEnd();
				}
				#endregion
		}
	}
}