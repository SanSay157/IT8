using System;
using System.Collections;
using System.Collections.Specialized;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using System.Globalization;
using Croc.IncidentTracker.Utility;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Reports
{
	public abstract class CustomITrackerReport : CustomReport
	{
		/// <summary>
		/// Зафиксированные наименования стилевых классов, определенных 
		/// в it-rs-config, используемых для стилевого форматирования отчетов 
		/// Системы. 
		/// ВНИМАНИЕ! При изменении / добавлении / удалении определений стилей 
		/// требуется ОБЯЗАТЕЛЬНО скорректировать соответствующие определения 
		/// в классе!
		/// </summary>
		internal class ITRepStyles 
		{
			/// <summary>
			/// Стиль для отображения заголовков (header-layout)
			/// </summary>
			public static readonly string APPNAME = "APPNAME";

			/// <summary>
			/// Стиль отображения подзаголовков (sub-header)
			/// </summary>
			public static readonly string TITLES = "TITLES";
			
			/// <summary>
			/// Стиль пустого отчета
			/// </summary>
			public static readonly string EMPTY = "EMPTY";

			/// <summary>
			/// Стиль отображения для всей таблицы по-умолчанию
			/// </summary>
			public static readonly string TABLE = "TABLE";
		
			/// <summary>
			/// Стиль отображения ячеек заголовков (headers) таблиц
			/// </summary>
			public static readonly string TABLE_HEADER = "TABLE_HEADER";

			/// <summary>
			/// Стиль отображения ячеек "подвалов" (footer) таблиц
			/// </summary>
			public static readonly string TABLE_FOOTER = "TABLE_FOOTER";

			/// <summary>
			/// Стиль отображения строки таблицы с заголовком (header) группы
			/// </summary>
			public static readonly string GROUP_HEADER = "GROUP_HEADER";

			/// <summary>
			/// Стиль отображения строки таблицы с "подвалом" группы (с данными под-итогов)
			/// </summary>
			public static readonly string GROUP_FOOTER = "GROUP_FOOTER";

			/// <summary>
			/// Стиль отображения строки таблицы с "подвалом" группы 
			/// (с данными под-итогов), выделенных цветом
			/// </summary>
			public static readonly string GROUP_FOOTER_COLOR = "GROUP_FOOTER_COLOR";

			/// <summary>
			/// Стиль отображения ячеек таблицы (Устаревший!)
			/// </summary>
			[Obsolete]
			public static readonly string CELL_CLASS = "CELL_CLASS";

			/// <summary>
			/// Стиль отображения ячеек таблицы
			/// </summary>
			public static readonly string TABLE_CELL = "TABLE_CELL";

			/// <summary>
			/// Стиль отображения ячеек таблицы; жирный шрифт 
			/// </summary>
			public static readonly string TABLE_CELL_BOLD = "TABLE_CELL_BOLD";

			/// <summary>
			/// Стиль отображения ячейки таблицы без данных (с текстом 
			/// вида "нет данных"); светло-серый цвет текста
			/// </summary>
			public static readonly string TABLE_CELL_ND = "TABLE_CELL_ND";

			/// <summary>
			/// Стиль для отображения номеров колонок (Устаревший!)
			/// </summary>
			[Obsolete]
			public static readonly string CAPTION_CLASS = "CAPTION_CLASS";

			/// <summary>
			/// Стиль для отображения номеров колонок (Устаревший!)
			/// </summary>
			public static readonly string TABLE_CELL_ROWNUM = "TABLE_CELL_ROWNUM";

			/// <summary>
			/// Стиль "подсвеченной" ячейки отчета: светло-зеленый фон
			/// </summary>
			public static readonly string TABLE_CELL_COLOR_GREEN = "TABLE_CELL_COLOR_GREEN";

			/// <summary>
			/// Стиль "подсвеченной" ячейки отчета: светло-красный фон
			/// </summary>
			public static readonly string TABLE_CELL_COLOR_RED = "TABLE_CELL_COLOR_RED";
            /// <summary>
            /// Стиль "подсвеченной" ячейки отчета: светло-красный фон
            /// </summary>
            public static readonly string TABLE_CELL_COLOR_ORANGE = "TABLE_CELL_COLOR_ORANGE";
            /// <summary>
            /// Стиль "подсвеченной" ячейки отчета: светло-красный фон
            /// </summary>
            public static readonly string TABLE_CELL_COLOR_YELLOW = "TABLE_CELL_COLOR_YELLOW";
            /// <summary>
            /// стиль отображения строчки под-заголовка 
            /// </summary>
            [Obsolete]
			public static readonly string SUBTITLE = "SUBTITLE";

			/// <summary>
			/// Стиль отображения для итоговой строки
			/// </summary>
			[Obsolete]
			public static readonly string SUBTOTAL = "SUBTOTAL";

			/// <summary>
			/// Стиль для master-data-header элемента в раскладке master-data-layout
			/// </summary>
			public static readonly string MASTER_DATA_HEADER_CLASS = "MASTER-DATA-HEADER-CLASS";

			/// <summary>
			/// стиль для master-data-footer элемента в раскладке master-data-layout
			/// </summary>
			public static readonly string MASTER_DATA_FOOTER_CLASS = "MASTER-DATA-FOOTER-CLASS";

			#region Стили таблицы дополнительной информации 
			// Набор стилей для отображения специальной таблицы отображения 
			// дополнительной информации в виде текстовых замечаний.
			// NB! Для таблицы и всех ее элеметов отключены рамки (и их - не включать!)

			/// <summary>
			/// Стиль таблицы доп. информации: стиль для самой таблицы
			/// </summary>
			public static readonly string TABLE_NOTE = "TABLE_NOTE";

			/// <summary>
			/// Стиль таблицы доп. информации: стиль для строки заголовка
			/// </summary>
			public static readonly string TABLE_NOTE_HEADER = "TABLE_NOTE_HEADER";

			/// <summary>
			/// Стиль таблицы доп. информации: стиль для ячейки таблицы
			/// </summary>
			public static readonly string TABLE_NOTE_CELL = "TABLE_NOTE_CELL";

			/// <summary>
			/// Стиль таблицы доп. информации: стиль для строки "подвала"
			/// (выделение болдом)
			/// </summary>
			public static readonly string TABLE_NOTE_FOOTER = "TABLE_NOTE_FOOTER";

			#endregion
		}

        /// <summary>
        /// Признак отображения ".р" при форматировании денежной строки
        /// </summary>
        private bool bFormatMoneyWithCurrencySymbol = false;

        protected bool FormatMoneyWithCurrencySymbol
        {
            get { return bFormatMoneyWithCurrencySymbol; }
            set { bFormatMoneyWithCurrencySymbol = value; }
        }

		private static readonly Regex linkify = new Regex(@"(((http|ftp|https|file):\/\/)|(mailto:))[\w\-_]+(\.[\w\-_]+)?([\w\-\.,@?^=%&:/~\+#;]*[\w\-\@?^=%&/~\+#;])?", RegexOptions.Compiled);

		public CustomITrackerReport(reportClass ReportProfile, string ReportName) : base(ReportProfile, ReportName)
		{}
        protected override abstract void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data);
		protected void writeEmptyBody(XslFOProfileWriter foWriter, string message)
		{
			foWriter.StartPageSequence();
			foWriter.StartPageBody();
			foWriter.EmptyBody(message);
			foWriter.EndPageBody();
			foWriter.EndPageSequence();
		}


		protected string _GetIncidentAnchor(object stringRepresentation, Guid IncidentID, bool bShowView)
		{
			return string.Format("<fo:basic-link external-destination=\"vbscript:ShowContextForIncident(&quot;{0}&quot;,0,{1})\">{2}</fo:basic-link>" , IncidentID, bShowView?"true":"false", xmlEncode(stringRepresentation));
		}

		protected string _GetFolderAnchor(object stringRepresentation, Guid FolderID, Guid UserID, bool bShowView, DateTime start, DateTime stop)
		{
			return string.Format("<fo:basic-link external-destination=\"vbscript:ShowContextForFolderEx2(&quot;{0}&quot;,&quot;{3}&quot;,{1},{4},{5})\">{2}</fo:basic-link>" , FolderID, bShowView?"true":"false", xmlEncode(stringRepresentation), UserID,
				start==DateTime.MinValue?"null":start.ToString("#MM'/'dd'/'yyyy#"),
				stop==DateTime.MaxValue?"null":stop.ToString("#MM'/'dd'/'yyyy#")
				);
		}

		protected string _GetFolderAnchor(object stringRepresentation, Guid FolderID, Guid UserID, bool bShowView)
		{
			return this._GetFolderAnchor(stringRepresentation, FolderID, UserID, bShowView, DateTime.MinValue, DateTime.MaxValue );
		}


		protected string _GetFolderAnchor(object stringRepresentation, Guid FolderID, bool bShowView)
		{
			return this._GetFolderAnchor(stringRepresentation, FolderID, Guid.Empty, bShowView );
		}

		protected static string _GetUserMailAnchor(object stringRepresentation, object mail)
		{
			return _GetUserMailAnchor(stringRepresentation, mail, Guid.Empty, Guid.Empty, Guid.Empty);
		}

		protected static string _GetUserMailAnchor(object stringRepresentation, object mail, Guid EmployeeID, Guid IncidentID, Guid ProjectID)
		{
			// Идентификатор сотрудника в IT не задан: тут можно только вывести
			// ссылку на схему mailto (и то, если задан почтовый адрес)
			if ( Guid.Empty == EmployeeID )
			{
				if ( mail==null || mail.ToString().Length==0 )
					return xmlEncode(stringRepresentation);
				else
					return "<fo:basic-link external-destination=\"mailto:" + mail + "\">" + xmlEncode(stringRepresentation) + "</fo:basic-link>";
			}
			else
			{
				// Спец. ссылка, при клике на которую срабатывает клиентский код, показыающий
				// всплывающее меню с операциями (прсмотр, редактирование, написать письмо) и 
				// пунктами вызова отчетов по сотруднику; 
				// ВНИМАНИЕ! Для корректной работы в отчет д.б. подключен прикладной скрипт
				// s-it-reports.vbs (через r:script, в профиле отчета)
				return string.Format( 
					"<fo:basic-link external-destination=\"vbscript:ShowContextForEmployee(&quot;{1}&quot;,&quot;{0}&quot;,&quot;{3}&quot;,&quot;{4}&quot;)\">{2}</fo:basic-link>", 
					xmlEncode(mail), EmployeeID, xmlEncode(stringRepresentation), IncidentID, ProjectID );
			}
		}

		protected string _FormatTimeStringAtServer(int time, int duration)
		{
			return Utils.FormatTimeDuration(time, duration);
		}

		internal static string _LongText(object text)
		{
			return "<fo:block>" +	linkAutoDetect(xmlEncode(text)).Replace("\n","</fo:block><fo:block>") + "</fo:block>";
		}

		private static string linkAutoDetect(string s)
		{
			if(s==null) return null;
			return linkify.Replace(s,"<fo:basic-link external-destination=\"$&\">$&</fo:basic-link>");
		}

		protected static IDictionary _GetDataFromDataRow(IDataRecord r)
		{
			int max = r.FieldCount;
			HybridDictionary hd = new HybridDictionary(max, true);
			for(int i=0; i<max;i++)
				if(r.IsDBNull(i))
					hd.Add(r.GetName(i), null);
				else
					hd.Add(r.GetName(i), r.GetValue(i));
			return hd;
		}


        //зачитывает данные рекордсета в массив
        protected static ArrayList _GetDataAsArrayList(IDataReader reader)
        {
            ArrayList data = new ArrayList();
            IDictionary row;
            while (reader.Read())
            {
                row = _GetDataFromDataRow(reader);
                data.Add(row);
            }
            return (0 != data.Count ? data : null);
        }

		protected void _TableSeparator( XslFOProfileWriter objRepGen )
		{
			objRepGen.RawOutput("&#160;","TEMPTY");
		}

		/// <summary>
		/// Преобразует дату в строку
		/// </summary>
		/// <param name="dt"></param>
		/// <returns></returns>
		protected static string _FormatLongDate(object dt)
		{
			return dt==null ? "" : ((DateTime)dt).ToLongDateString();
		}

		/// <summary>
		/// Преобразует дату/время в строку
		/// </summary>
		/// <param name="dt"></param>
		/// <returns></returns>
		protected static string _FormatLongDateTime(object dt)
		{
			return dt==null ? "" : ((DateTime)dt).ToLongDateString()
				+ " " + ((DateTime)dt).ToLongTimeString();
		}

		/// <summary>
		/// Вставляет строку таблицы
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="cells"></param>
		protected void _WriteTR(XslFOProfileWriter foWriter, params object[] cells)
		{
			_WriteTR(foWriter, false, cells);
		}

		/// <summary>
		/// Вставляет строку таблицы
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="cells"></param>
		/// <param name="firstBold"></param>
		protected void _WriteTR(XslFOProfileWriter foWriter, bool firstBold, params object[] cells)
		{
			foWriter.TRStart();
			for (int i = 0; i<cells.Length; i++)
			{
				foWriter.TRAddCell( cells[i], null, 1, 1,
					(i==0 && firstBold) ? "CELL_BOLD_CLASS" : "CELL_CLASS");
			}
			foWriter.TREnd();
		}


		/// <summary>
		/// Формирует в потоке FO одну ячейку таблицы с заданными данными. 
		/// Для ячейки задается фиксированные тип "string" и стилевой класс
		/// ITRepStyles.TABLE_CELL.
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="data">Данные; явно приводятся к строке</param>
		protected void _WriteCell( XslFOProfileWriter foWriter, object data ) 
		{
			_WriteCell( foWriter, data, "string", ITRepStyles.TABLE_CELL );
		}

		/// <summary>
		/// Формирует в потоке FO одну ячейку таблицы с заданными данными и типом.
		/// Для ячейки задается фиксированный стилевой класс ITRepStyles.TABLE_CELL.
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="data">Данные; явно приводятся к строке</param>
		/// <param name="sType">Тип данных в ячейке</param>
		protected void _WriteCell( XslFOProfileWriter foWriter, object data, string sType ) 
		{
			_WriteCell( foWriter, data, sType, ITRepStyles.TABLE_CELL );
		}

		/// <summary>
		/// Формирует в потоке FO одну ячейку таблицы с заданными данными, типом 
		/// и указанным стилевым классом.
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="data">Данные; явно приводятся к строке</param>
		/// <param name="sType">Тип данных в ячейке</param>
		/// <param name="sCellClass">Наименование стилевого класса для ячейки</param>
		protected void _WriteCell( XslFOProfileWriter foWriter, object data, string sType, string sCellClass ) 
		{
			_WriteCell( foWriter, data, sType, sCellClass, true );
		}

		/// <summary>
		/// Формирует в потоке FO одну ячейку таблицы с заданными данными, типом 
		/// и указанным стилевым классом. 
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="data">Данные; явно приводятся к строке</param>
		/// <param name="sType">Тип данных в ячейке</param>
		/// <param name="sCellClass">Наименование стилевого класса для ячейки</param>
		/// <param name="trackEmptyValAsND">
		/// Задает режим явной замены "пустых" значений: если задан в true и значение
		/// data есть null или DBNull.Value, то выводит текст "нет данных" и заменят
		/// заданный стилевой класс на ITRepStyles.TABLE_CELL_ND;
		/// </param>
		protected void _WriteCell( XslFOProfileWriter foWriter, object data, string sType, string sCellClass, bool trackEmptyValAsND ) 
		{
			string sValue = String.Empty;
			if (null!=data && DBNull.Value!=data)
				sValue = data.ToString();

			if (String.Empty==sValue && trackEmptyValAsND )
			{
				sValue = "( нет данных )";
				sCellClass = ITRepStyles.TABLE_CELL_ND;
			}
			foWriter.TRAddCell(sValue, sType, 1, 1, sCellClass );
		}
        protected void _StartReportURL(StringBuilder sb, string sRepName)
        {
            sb.Append("<fo:basic-link text-decoration=\"none\" external-destination=\"url('x-get-report.aspx?name=" + sRepName + ".xml");
        }
        protected void _AppendParamURL(StringBuilder sb, string sParamName, object ParamValue)
        {
            sb.Append("&amp;");
            sb.Append(sParamName);
            sb.Append("=");
            sb.Append(ParamValue);
        }
        protected void _EndReportURL(StringBuilder sb, string sReportTitle, object CellValue)
        {
            sb.Append("')\" target=\"_blank\" show-destination=\"new\" title=\"" + sReportTitle + "\">");
            sb.Append(xmlEncode(CellValue));
            sb.Append("</fo:basic-link>");
        }
        protected void _WriteDataPair(XslFOProfileWriter fo, string sName, string sValue)
        {
            _WriteDataPair(fo, sName, sValue, ITRepStyles.TABLE_CELL);
        }

        protected void _WriteDataPair(XslFOProfileWriter fo, string sName, string sValue, string sValueStyleClass)
        {
            fo.TRStart();
            _WriteCell(fo, sName, "string", ITRepStyles.TABLE_CELL_BOLD);
            _WriteCell(fo, sValue, "string", sValueStyleClass, true);
            fo.TREnd();
        }

        /// <summary>
        /// Внутренний метод, формирует текст XSL-FO блока фиксированной структуры,
        /// представляющий пару "наименование параметра" и "значение параметра".
        /// Используется при формировании XSL-FO-текста с перечнем заданных параметров
        /// </summary>
        /// <param name="sParamName">Наименование параметра</param>
        /// <param name="sParamValueText">Текст со значением параметра</param>
        /// <returns>Строка с текстом XSL-FO блока</returns>
        protected string _GetParamValueAsFoBlock(string sParamName, string sParamValueText)
        {
            return String.Format(
                "<fo:block><fo:inline>{0}: </fo:inline><fo:inline font-weight=\"bold\">{1}</fo:inline></fo:block>",
                xmlEncode(sParamName),
                xmlEncode(sParamValueText)
            );
        }

        protected String _MakeSubHeader(StringBuilder sb)
        {
            return @"<fo:block text-align=""left""><fo:block font-weight=""bold"">Параметры отчета:</fo:block>" + sb.ToString() + @"</fo:block>";
        }

        protected String _FormatShortDate(String d)
        {
            DateTime min = DateTime.Parse("1900-01-01");
            DateTime max = DateTime.Parse("9999-01-01");
            DateTime curr = DateTime.Parse(d);
            if (min == curr || max == curr)
                return "не задана";
            else
                return xmlEncode(DateTime.Parse(d).ToShortDateString());
        }
        /// <summary>
        /// Форматирует денежную строку 
        /// </summary>
        /// <param name="dbMoney">форматируемая строка</param>
        /// <returns></returns>
        protected String _FormatMoney(Object dbMoney)
        {
            //Результирующая строка
            String sResult = dbMoney.ToString();
            
            // Определим локализацию для парсинга данных из БД
            CultureInfo culture = new CultureInfo("ru-RU");
            
            //Форматируем денежную строку
            sResult = (Utils.ParseDBString(sResult)).ToString("C2", culture);
            
            //Если нужно отбрасываем "р."
            return bFormatMoneyWithCurrencySymbol ? sResult : sResult.Remove(sResult.Length - 2);
        }
	}
}