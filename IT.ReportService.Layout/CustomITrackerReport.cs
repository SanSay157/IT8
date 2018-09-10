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
		/// ��������������� ������������ �������� �������, ������������ 
		/// � it-rs-config, ������������ ��� ��������� �������������� ������� 
		/// �������. 
		/// ��������! ��� ��������� / ���������� / �������� ����������� ������ 
		/// ��������� ����������� ��������������� ��������������� ����������� 
		/// � ������!
		/// </summary>
		internal class ITRepStyles 
		{
			/// <summary>
			/// ����� ��� ����������� ���������� (header-layout)
			/// </summary>
			public static readonly string APPNAME = "APPNAME";

			/// <summary>
			/// ����� ����������� ������������� (sub-header)
			/// </summary>
			public static readonly string TITLES = "TITLES";
			
			/// <summary>
			/// ����� ������� ������
			/// </summary>
			public static readonly string EMPTY = "EMPTY";

			/// <summary>
			/// ����� ����������� ��� ���� ������� ��-���������
			/// </summary>
			public static readonly string TABLE = "TABLE";
		
			/// <summary>
			/// ����� ����������� ����� ���������� (headers) ������
			/// </summary>
			public static readonly string TABLE_HEADER = "TABLE_HEADER";

			/// <summary>
			/// ����� ����������� ����� "��������" (footer) ������
			/// </summary>
			public static readonly string TABLE_FOOTER = "TABLE_FOOTER";

			/// <summary>
			/// ����� ����������� ������ ������� � ���������� (header) ������
			/// </summary>
			public static readonly string GROUP_HEADER = "GROUP_HEADER";

			/// <summary>
			/// ����� ����������� ������ ������� � "��������" ������ (� ������� ���-������)
			/// </summary>
			public static readonly string GROUP_FOOTER = "GROUP_FOOTER";

			/// <summary>
			/// ����� ����������� ������ ������� � "��������" ������ 
			/// (� ������� ���-������), ���������� ������
			/// </summary>
			public static readonly string GROUP_FOOTER_COLOR = "GROUP_FOOTER_COLOR";

			/// <summary>
			/// ����� ����������� ����� ������� (����������!)
			/// </summary>
			[Obsolete]
			public static readonly string CELL_CLASS = "CELL_CLASS";

			/// <summary>
			/// ����� ����������� ����� �������
			/// </summary>
			public static readonly string TABLE_CELL = "TABLE_CELL";

			/// <summary>
			/// ����� ����������� ����� �������; ������ ����� 
			/// </summary>
			public static readonly string TABLE_CELL_BOLD = "TABLE_CELL_BOLD";

			/// <summary>
			/// ����� ����������� ������ ������� ��� ������ (� ������� 
			/// ���� "��� ������"); ������-����� ���� ������
			/// </summary>
			public static readonly string TABLE_CELL_ND = "TABLE_CELL_ND";

			/// <summary>
			/// ����� ��� ����������� ������� ������� (����������!)
			/// </summary>
			[Obsolete]
			public static readonly string CAPTION_CLASS = "CAPTION_CLASS";

			/// <summary>
			/// ����� ��� ����������� ������� ������� (����������!)
			/// </summary>
			public static readonly string TABLE_CELL_ROWNUM = "TABLE_CELL_ROWNUM";

			/// <summary>
			/// ����� "������������" ������ ������: ������-������� ���
			/// </summary>
			public static readonly string TABLE_CELL_COLOR_GREEN = "TABLE_CELL_COLOR_GREEN";

			/// <summary>
			/// ����� "������������" ������ ������: ������-������� ���
			/// </summary>
			public static readonly string TABLE_CELL_COLOR_RED = "TABLE_CELL_COLOR_RED";
            /// <summary>
            /// ����� "������������" ������ ������: ������-������� ���
            /// </summary>
            public static readonly string TABLE_CELL_COLOR_ORANGE = "TABLE_CELL_COLOR_ORANGE";
            /// <summary>
            /// ����� "������������" ������ ������: ������-������� ���
            /// </summary>
            public static readonly string TABLE_CELL_COLOR_YELLOW = "TABLE_CELL_COLOR_YELLOW";
            /// <summary>
            /// ����� ����������� ������� ���-��������� 
            /// </summary>
            [Obsolete]
			public static readonly string SUBTITLE = "SUBTITLE";

			/// <summary>
			/// ����� ����������� ��� �������� ������
			/// </summary>
			[Obsolete]
			public static readonly string SUBTOTAL = "SUBTOTAL";

			/// <summary>
			/// ����� ��� master-data-header �������� � ��������� master-data-layout
			/// </summary>
			public static readonly string MASTER_DATA_HEADER_CLASS = "MASTER-DATA-HEADER-CLASS";

			/// <summary>
			/// ����� ��� master-data-footer �������� � ��������� master-data-layout
			/// </summary>
			public static readonly string MASTER_DATA_FOOTER_CLASS = "MASTER-DATA-FOOTER-CLASS";

			#region ����� ������� �������������� ���������� 
			// ����� ������ ��� ����������� ����������� ������� ����������� 
			// �������������� ���������� � ���� ��������� ���������.
			// NB! ��� ������� � ���� �� �������� ��������� ����� (� �� - �� ��������!)

			/// <summary>
			/// ����� ������� ���. ����������: ����� ��� ����� �������
			/// </summary>
			public static readonly string TABLE_NOTE = "TABLE_NOTE";

			/// <summary>
			/// ����� ������� ���. ����������: ����� ��� ������ ���������
			/// </summary>
			public static readonly string TABLE_NOTE_HEADER = "TABLE_NOTE_HEADER";

			/// <summary>
			/// ����� ������� ���. ����������: ����� ��� ������ �������
			/// </summary>
			public static readonly string TABLE_NOTE_CELL = "TABLE_NOTE_CELL";

			/// <summary>
			/// ����� ������� ���. ����������: ����� ��� ������ "�������"
			/// (��������� ������)
			/// </summary>
			public static readonly string TABLE_NOTE_FOOTER = "TABLE_NOTE_FOOTER";

			#endregion
		}

        /// <summary>
        /// ������� ����������� ".�" ��� �������������� �������� ������
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
			// ������������� ���������� � IT �� �����: ��� ����� ������ �������
			// ������ �� ����� mailto (� ��, ���� ����� �������� �����)
			if ( Guid.Empty == EmployeeID )
			{
				if ( mail==null || mail.ToString().Length==0 )
					return xmlEncode(stringRepresentation);
				else
					return "<fo:basic-link external-destination=\"mailto:" + mail + "\">" + xmlEncode(stringRepresentation) + "</fo:basic-link>";
			}
			else
			{
				// ����. ������, ��� ����� �� ������� ����������� ���������� ���, �����������
				// ����������� ���� � ���������� (�������, ��������������, �������� ������) � 
				// �������� ������ ������� �� ����������; 
				// ��������! ��� ���������� ������ � ����� �.�. ��������� ���������� ������
				// s-it-reports.vbs (����� r:script, � ������� ������)
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


        //���������� ������ ���������� � ������
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
		/// ����������� ���� � ������
		/// </summary>
		/// <param name="dt"></param>
		/// <returns></returns>
		protected static string _FormatLongDate(object dt)
		{
			return dt==null ? "" : ((DateTime)dt).ToLongDateString();
		}

		/// <summary>
		/// ����������� ����/����� � ������
		/// </summary>
		/// <param name="dt"></param>
		/// <returns></returns>
		protected static string _FormatLongDateTime(object dt)
		{
			return dt==null ? "" : ((DateTime)dt).ToLongDateString()
				+ " " + ((DateTime)dt).ToLongTimeString();
		}

		/// <summary>
		/// ��������� ������ �������
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="cells"></param>
		protected void _WriteTR(XslFOProfileWriter foWriter, params object[] cells)
		{
			_WriteTR(foWriter, false, cells);
		}

		/// <summary>
		/// ��������� ������ �������
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
		/// ��������� � ������ FO ���� ������ ������� � ��������� �������. 
		/// ��� ������ �������� ������������� ��� "string" � �������� �����
		/// ITRepStyles.TABLE_CELL.
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="data">������; ���� ���������� � ������</param>
		protected void _WriteCell( XslFOProfileWriter foWriter, object data ) 
		{
			_WriteCell( foWriter, data, "string", ITRepStyles.TABLE_CELL );
		}

		/// <summary>
		/// ��������� � ������ FO ���� ������ ������� � ��������� ������� � �����.
		/// ��� ������ �������� ������������� �������� ����� ITRepStyles.TABLE_CELL.
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="data">������; ���� ���������� � ������</param>
		/// <param name="sType">��� ������ � ������</param>
		protected void _WriteCell( XslFOProfileWriter foWriter, object data, string sType ) 
		{
			_WriteCell( foWriter, data, sType, ITRepStyles.TABLE_CELL );
		}

		/// <summary>
		/// ��������� � ������ FO ���� ������ ������� � ��������� �������, ����� 
		/// � ��������� �������� �������.
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="data">������; ���� ���������� � ������</param>
		/// <param name="sType">��� ������ � ������</param>
		/// <param name="sCellClass">������������ ��������� ������ ��� ������</param>
		protected void _WriteCell( XslFOProfileWriter foWriter, object data, string sType, string sCellClass ) 
		{
			_WriteCell( foWriter, data, sType, sCellClass, true );
		}

		/// <summary>
		/// ��������� � ������ FO ���� ������ ������� � ��������� �������, ����� 
		/// � ��������� �������� �������. 
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="data">������; ���� ���������� � ������</param>
		/// <param name="sType">��� ������ � ������</param>
		/// <param name="sCellClass">������������ ��������� ������ ��� ������</param>
		/// <param name="trackEmptyValAsND">
		/// ������ ����� ����� ������ "������" ��������: ���� ����� � true � ��������
		/// data ���� null ��� DBNull.Value, �� ������� ����� "��� ������" � �������
		/// �������� �������� ����� �� ITRepStyles.TABLE_CELL_ND;
		/// </param>
		protected void _WriteCell( XslFOProfileWriter foWriter, object data, string sType, string sCellClass, bool trackEmptyValAsND ) 
		{
			string sValue = String.Empty;
			if (null!=data && DBNull.Value!=data)
				sValue = data.ToString();

			if (String.Empty==sValue && trackEmptyValAsND )
			{
				sValue = "( ��� ������ )";
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
        /// ���������� �����, ��������� ����� XSL-FO ����� ������������� ���������,
        /// �������������� ���� "������������ ���������" � "�������� ���������".
        /// ������������ ��� ������������ XSL-FO-������ � �������� �������� ����������
        /// </summary>
        /// <param name="sParamName">������������ ���������</param>
        /// <param name="sParamValueText">����� �� ��������� ���������</param>
        /// <returns>������ � ������� XSL-FO �����</returns>
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
            return @"<fo:block text-align=""left""><fo:block font-weight=""bold"">��������� ������:</fo:block>" + sb.ToString() + @"</fo:block>";
        }

        protected String _FormatShortDate(String d)
        {
            DateTime min = DateTime.Parse("1900-01-01");
            DateTime max = DateTime.Parse("9999-01-01");
            DateTime curr = DateTime.Parse(d);
            if (min == curr || max == curr)
                return "�� ������";
            else
                return xmlEncode(DateTime.Parse(d).ToShortDateString());
        }
        /// <summary>
        /// ����������� �������� ������ 
        /// </summary>
        /// <param name="dbMoney">������������� ������</param>
        /// <returns></returns>
        protected String _FormatMoney(Object dbMoney)
        {
            //�������������� ������
            String sResult = dbMoney.ToString();
            
            // ��������� ����������� ��� �������� ������ �� ��
            CultureInfo culture = new CultureInfo("ru-RU");
            
            //����������� �������� ������
            sResult = (Utils.ParseDBString(sResult)).ToString("C2", culture);
            
            //���� ����� ����������� "�."
            return bFormatMoneyWithCurrencySymbol ? sResult : sResult.Remove(sResult.Length - 2);
        }
	}
}