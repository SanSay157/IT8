//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
// ��� ����� ��������� ������ ������� (����� "�������� �������")
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Reports
{
    /// <summary>
    /// �������� ��������� �������
    /// </summary>
    public class r_Tender : CustomITrackerReport
    {
        /// <summary>
        /// ������������������� �����������. ���������� ����������� ReportService
        /// </summary>
        /// <param name="ReportProfile"></param>
        /// <param name="ReportName"></param>
        public r_Tender(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        { }

        /// <summary>
        /// ���������� �����, �������������� �������� � ������������� ���� ������,
        /// ����������� ��� ���������� �����.
        /// </summary>
        internal class ThisReportData
        {

            /// <summary>
            /// �������� ������ �� �������
            /// </summary>
            public IDictionary Main = null;
            /// <summary>
            /// ����� "�������" ������
            /// </summary>
            public ArrayList Links = null;
            /// <summary>
            /// �������� ���������� ��������(����)
            /// </summary>
            public ArrayList Parts = null;
            /// <summary>
            /// �������� ���������� �� ��������������
            /// </summary>
            public ArrayList DepParts = null;
            /// <summary>
            /// ��� ������ (0 - ��� ������, 1 - ��� ���������)
            /// </summary>
            public Int32 ViewType = 0;

            /// <summary>
            /// ������������������� �����������: ��������� ��� ������ �������, 
            /// ����������� ��� ����������� ������
            /// </summary>
            /// <param name="connection">���������� � ��</param>
            /// <param name="TenderID">������������� �������</param>
            public ThisReportData(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData, Guid TenderID)
            {
                // #1: ��������� ������(�):
                using (IDataReader reader = reportData.DataProvider.GetDataReader("dsTender", reportData.CustomData))
                {
                    IDictionary row;

                    // �������� ������:
                    if (reader.Read())
                        Main = _GetDataFromDataRow(reader);

                    // ������ ������� ������
                    if (reader.NextResult())
                    {
                        ArrayList data = new ArrayList();
                        while (reader.Read())
                        {
                            row = _GetDataFromDataRow(reader);
                            data.Add(row);
                        }
                        if (0 != data.Count)
                            Links = data;
                    }

                    // ������ ������� ���������� �������
                    if (reader.NextResult())
                    {
                        ArrayList data = new ArrayList();
                        while (reader.Read())
                        {
                            row = _GetDataFromDataRow(reader);
                            data.Add(row);
                        }
                        if (0 != data.Count)
                            Parts = data;
                    }

                    // ������ ������� ���������� �� �������������
                    if (reader.NextResult())
                    {
                        ArrayList data = new ArrayList();
                        while (reader.Read())
                        {
                            row = _GetDataFromDataRow(reader);
                            data.Add(row);
                        }
                        if (0 != data.Count)
                            DepParts = data;
                    }
                }
            }
        }

        /// <summary>
        /// �����, ����������� �����; ���������� ����������� ReportService
        /// </summary>
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
        {
            // �������� ������������� ������ �� ���������� ����������
            Guid TenderID = (Guid)reportData.Params.GetParam("TenderID").Value;

            // �������� ��� ������ ��� ��������� ������:
            ThisReportData data = new ThisReportData(reportData, TenderID);
            data.ViewType = (Int32)reportData.Params.GetParam("ViewType").Value;
            if (null == data.Main)
            {
                writeEmptyBody(reportData.RepGen, String.Format(
                    "��������� �������� �������� � ������� �� ������ (�������� ������������� - {0})",
                    TenderID.ToString().ToUpper()));
                return;
            }
            reportData.RepGen.WriteLayoutMaster();
            reportData.RepGen.StartPageSequence();
            reportData.RepGen.StartPageBody();
            reportData.RepGen.Header(xmlEncode(String.Format(
                    "������� {0}\"{1}\"",
                    (null == data.Main["Number"] ? "" : "� " + data.Main["Number"] + ", "),
                    data.Main["Tender"]
                )));

            // ����������� ������ �������:
            writeMainData(reportData.RepGen, data);

            reportData.RepGen.EndPageBody();
            reportData.RepGen.EndPageSequence();
        }


        private void writeDataPair(XslFOProfileWriter fo, string sName, string sValue)
        {
            writeDataPair(fo, sName, sValue, ITRepStyles.TABLE_CELL);
        }

        private void writeDataPair(XslFOProfileWriter fo, string sName, string sValue, string sValueStyleClass)
        {
            fo.TRStart();
            _WriteCell(fo, sName, "string", ITRepStyles.TABLE_CELL_BOLD);
            _WriteCell(fo, sValue, "string", sValueStyleClass, true);
            fo.TREnd();
        }


        /// <summary>
        /// ����������� � ������ �������� ������� ���� � �������
        /// </summary>
        /// <param name="fo"></param>
        /// <param name="data">������ �������, ������ �������� ������������</param>
        private void writeMainData(XslFOProfileWriter fo, ThisReportData data)
        {
            string sValue;

            #region #1: �������� ������

            // ...�����������
            _TableSeparator(fo);

            fo.TStart(false, ITRepStyles.TABLE, false);
            fo.TAddColumn("��������������", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "30%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("��������", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "70%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            fo.TRStart();
            fo.TRAddCell("�������� ���������", "string", 2, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();
            if ((Int32)data.Main["CustEqOrg"] == 1)
                writeDataPair(fo, "��������/�����������", xmlEncode(data.Main["Customer"]));
            else
                writeDataPair(fo, "��������/�����������", xmlEncode(data.Main["Customer"]) + " / " + xmlEncode(data.Main["Organizer"]));
            writeDataPair(fo, "���� ������ ����������", _FormatLongDateTime(data.Main["DocFeedingDate"]));
            writeDataPair(fo, "���� ���������� ����������", _FormatLongDateTime(data.Main["DateTorg1"]));
            writeDataPair(fo, "���� ���������� 2� ����������", _FormatLongDateTime(data.Main["DateTorg2"]));

            // ...�������� �������:
            if(data.ViewType == 0)
                writeDataPair(fo, "�������� �������", _GetUserMailAnchor(data.Main["DirectorName"], data.Main["DirectorEMail"]));

            // ...c��������: ���� ���� � ����������� �� ���������
            LotState state = (LotState)(Int32.Parse(data.Main["State"].ToString()));
            if (LotState.WasGain == state)
                sValue = ITRepStyles.TABLE_CELL_COLOR_GREEN;
            else if (LotState.WasLoss == state)
                sValue = ITRepStyles.TABLE_CELL_COLOR_RED;
            else
                sValue = ITRepStyles.TABLE_CELL;
            writeDataPair(fo, "���������",
                "<fo:inline font-weight='bold'>" + xmlEncode(data.Main["StateName"]) + "</fo:inline>",
                sValue);

            // ...���������� ���� ���������� �������:
            fo.TRStart();
            fo.TRAddCell("���������� ���� ���������� �������", "string", 2, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();
            writeDataPair(fo, "�������, ���, �������� ", xmlEncode(data.Main["JuryContactName"]));
            writeDataPair(fo, "������� ", xmlEncode(data.Main["JuryContactPhone"]));
            writeDataPair(fo, "����� ����������� �����", _GetUserMailAnchor(data.Main["JuryContactEMail"], data.Main["JuryContactEMail"]));

            fo.TEnd();
            #endregion

            #region #2: ������ ���������� ��������:
			if (null != data.Parts)
			{
				// ...�����������
				_TableSeparator( fo );

				fo.TStart( true, ITRepStyles.TABLE, false );

				bool isFinalState = (LotState.WasGain == state || LotState.WasLoss == state);
                int nCol = fo.TAddColumn("��������� ��������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "�����������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "12%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "��� �������", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "��������", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "7%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
				if (isFinalState)
                    fo.TAddSubColumn(nCol, "�������� ������", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "����� ������, " + xmlEncode(data.Main["NDS"]), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "����� ����������, " + xmlEncode(data.Main["NDS"]), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "����� 2� ����������, " + xmlEncode(data.Main["NDS"]), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "����� ������ ��, " + xmlEncode(data.Main["NDS"]), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "����� ���������� ��, " + xmlEncode(data.Main["NDS"]), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "����� 2� ���������� ��, " + xmlEncode(data.Main["NDS"]), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

                fo.TAddSubColumn(nCol, "����������", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, (isFinalState ? "8%" : "13%"), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

				foreach (IDictionary orgData in data.Parts)
				{
					fo.TRStart();
					_WriteCell(fo, xmlEncode(orgData["ParticipantOrganization"]) );
					_WriteCell(fo, xmlEncode(orgData["ParticipationType"]) );
                    _WriteCell(fo, xmlEncode(orgData["DeclinedText"]));
					if (isFinalState)
					{
						bool isWinner = (null!=orgData["Winner"]);
						_WriteCell( fo, 
							"<fo:inline font-weight='bold'>" + (isWinner? "����������" : "�����������") + "</fo:inline>", 
							"string", 
							(isWinner? ITRepStyles.TABLE_CELL_COLOR_GREEN : ITRepStyles.TABLE_CELL_COLOR_RED) );
					}
                    _WriteCell(fo, xmlEncode(orgData["TenderParticipantPrice"]));
                    _WriteCell(fo, xmlEncode(orgData["SumTorg1"]));
                    _WriteCell(fo, xmlEncode(orgData["SumTorg2"]));
                    _WriteCell(fo, xmlEncode(orgData["TenderParticipantPriceAP"]));
                    _WriteCell(fo, xmlEncode(orgData["SumTorg1AP"]));
                    _WriteCell(fo, xmlEncode(orgData["SumTorg2AP"]));
                    _WriteCell(fo, xmlEncode(orgData["Note"]));
                    fo.TREnd();
				}
				fo.TEnd();
			}

			#endregion

            #region #3: ������� ������������� (���� ����� ������ ����)
            if (null != data.DepParts && data.ViewType == 0)
            {
                // ...�����������
                _TableSeparator(fo);

                fo.TStart(true, ITRepStyles.TABLE, false);

                int nCol = fo.TAddColumn("������� �������������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, null, align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "�����������", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "�����������", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "�����������", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "����������", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "40%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

                foreach (IDictionary depData in data.DepParts)
                {
                    fo.TRStart();
                    _WriteCell(fo, xmlEncode(depData["Department"]));

                    // ����������� �� �������������:
                    sValue = _GetUserMailAnchor(depData["ExecutorName"], depData["ExecutorEMail"]);
                    if (null != depData["DocsGettingDate"])
                        sValue = sValue + (String.Empty != sValue ? ", " : "") + "��������� �������(�) " + _FormatLongDate(depData["DocsGettingDate"]);
                    _WriteCell(fo, sValue);

                    _WriteCell(fo, xmlEncode(depData["ExecutorIsAcquaint"]));
                    _WriteCell(fo, xmlEncode(depData["Note"]));
                    fo.TREnd();
                }
                fo.TEnd();
            }

            #endregion

            #region #3: ������� ������ (���� ������� ����)
            if (null != data.Links && data.ViewType == 0)
            {
                // ...�����������
                _TableSeparator(fo);

                fo.TStart(false, ITRepStyles.TABLE, false);
                fo.TAddColumn("��� ������", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "15%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddColumn("������", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "85%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

                fo.TRStart();
                fo.TRAddCell("������� ������", "string", 2, 1, ITRepStyles.GROUP_HEADER);
                fo.TREnd();

                foreach (IDictionary linkData in data.Links)
                {
                    string sLinkHRef = String.Format(
                            "<fo:basic-link " +
                                "text-decoration=\"none\" " +
                                "external-destination=\"vbscript:window.OpenExternalLink({0},&quot;{1}&quot;)\">" +
                            "{2}</fo:basic-link> " +
                            "( ������ �����: <fo:basic-link " +
                                "text-decoration=\"none\" " +
                                "external-destination=\"vbscript:window.OpenExternalLink({0},&quot;{1}&quot;)\">" +
                            "{1}</fo:basic-link> )",
                            linkData["LinkServiceType"],		// {0}, ��� ������������� �������
                            xmlEncode(linkData["URI"]),			// {1}, URI ������
                            xmlEncode(linkData["LinkName"])		// {2}, ������������ �������� ������
                        );

                    fo.TRStart();
                    _WriteCell(fo, xmlEncode(linkData["ServiceTypeName"]));
                    _WriteCell(fo, sLinkHRef, "string");
                    fo.TREnd();
                }
                fo.TEnd();
            }
            #endregion

            #region #4: �������������� ������
            _TableSeparator(fo);

            fo.TStart(false, ITRepStyles.TABLE, false);
            fo.TAddColumn("��������������", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "30%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("��������", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "70%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            fo.TRStart();
            fo.TRAddCell("�������������", "string", 2, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();

            writeDataPair(fo, "� ����������", xmlEncode(data.Main["QualifyingRequirement"]));
            if (data.ViewType == 0)
            {
                writeDataPair(fo, "����������", xmlEncode(data.Main["Note"]));
                writeDataPair(fo, "����������", xmlEncode(data.Main["Discussion"]));
            }
            fo.TEnd();
            #endregion
        }
    }
}
