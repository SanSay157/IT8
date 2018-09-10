//����� "�������� ���������� ����������"
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
    /// �������� ��������� �������
    /// </summary>
    public class r_EmployeeKassTrans : CustomITrackerReport
    {
        /// <summary>
        /// ������������������� �����������. ���������� ����������� ReportService
        /// </summary>
        /// <param name="ReportProfile"></param>
        /// <param name="ReportName"></param>
        public r_EmployeeKassTrans(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        { }


        /// <summary>
        /// ���������� �����, �������������� ��� ���������� ��������� ������
        /// </summary>
        public class ThisReportParams
        {

            /// <summary>
            /// ID ����������
            /// </summary>
            public Guid EmpID;
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
            /// ������������������� �����������. �������������� �������� ������ �� 
            /// ��������� ������ ����������, �������������� � ��������� ReportParams. 
            /// </summary>
            /// <param name="Params">������ ���������, ������������ � �����</param>
            /// <remarks>
            /// ��� ������������� ��������� ��������� �������� ����������, ��������� 
            /// �� ���������, � ��� �� ������ ������������� ���������� (����� ��� 
            /// "����������� ����������")
            /// </remarks>
            public ThisReportParams(ReportParams Params)
            {
                EmpID = (Guid)Params.GetParam("EmpID").Value;
                IsSpecifiedIntervalBegin = !Params.GetParam("IntervalBegin").IsNull;
                IntervalBegin = (IsSpecifiedIntervalBegin ? Params.GetParam("IntervalBegin").Value : DBNull.Value);
                IsSpecifiedIntervalEnd = !Params.GetParam("IntervalEnd").IsNull;
                IntervalEnd = (IsSpecifiedIntervalEnd ? Params.GetParam("IntervalEnd").Value : DBNull.Value);
            }

            /// <summary>
            /// ��������� ����� XSL-FO, �������������� ������ �������� ����������, � 
            /// ���������� ��� ��� ����� ������������ ������������ ������
            /// </summary>
            /// <param name="foWriter"></param>
            /// <param name="cn"></param>
            public void WriteParamsInHeader(XslFOProfileWriter foWriter, IReportDataProvider Provider)
            {
                // XSL-FO � �������� ���������� ����� �������� ����:
                StringBuilder sbBlock = new StringBuilder();
                string sParamValue;



                if (IsSpecifiedIntervalBegin)
                    sParamValue = ((DateTime)IntervalBegin).ToString("dd.MM.yyyy");
                else
                    sParamValue = "�� ������";
                sbBlock.Append(getParamValueAsFoBlock("���� ������ ��������� �������", sParamValue));

                if (IsSpecifiedIntervalEnd)
                    sParamValue = ((DateTime)IntervalEnd).ToString("dd.MM.yyyy");
                else
                    sParamValue = "�� ������";
                sbBlock.Append(getParamValueAsFoBlock("���� ��������� ��������� �������", sParamValue));

                // ����� ������������:
                foWriter.AddSubHeader(
                    @"<fo:block text-align=""left""><fo:block font-weight=""bold"">��������� ������:</fo:block>" +
                    sbBlock.ToString() +
                    @"</fo:block>"
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
            private string getParamValueAsFoBlock(string sParamName, string sParamValueText)
            {
                return String.Format(
                    "<fo:block><fo:inline>{0}: </fo:inline><fo:inline font-weight=\"bold\">{1}</fo:inline></fo:block>",
                    xmlEncode(sParamName),
                    xmlEncode(sParamValueText)
                );
            }
        }

        /// <summary>
        /// ���������� �����, �������������� �������� � ������������� ���� ������,
        /// ����������� ��� ���������� �����.
        /// </summary>
        internal class ThisReportData
        {

            /// <summary>
            /// �������� ������
            /// </summary>
            public ArrayList Main = null;

            /// <summary>
            /// ���������� �����: ���������� ������ ���������� � ������
            /// </summary>
            /// <param name="reader"></param>
            /// <returns>���� ����� � ���������� ���, ���������� null</returns>
            private static ArrayList loadDataAsArrayList(IDataReader reader)
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
            
            /// <summary>
            /// ������������������� �����������: ��������� ��� ������ �������, 
            /// ����������� ��� ����������� ������
            /// </summary>
            /// <param name="connection">���������� � ��</param>
            /// <param name="TenderID">������������� �������</param>
            public ThisReportData(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
            {
                // �������� ������ ������
                using (IDataReader reader = reportData.DataProvider.GetDataReader("EmployeeKassTransDS", reportData.CustomData))
                {
                    Main = loadDataAsArrayList(reader);
                }
            }
        }

        /// <summary>
        /// �����, ����������� �����; ���������� ����������� ReportService
        /// </summary>
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
        {
            // �������� ��� ������ ��� ��������� ������:
            ThisReportData data = new ThisReportData(reportData);
            reportData.RepGen.WriteLayoutMaster();
            reportData.RepGen.StartPageSequence();
            reportData.RepGen.StartPageBody();
            reportData.RepGen.Header(String.Format("�������� ���������� ���������� - {0}", xmlEncode((String)reportData.Params.GetParam("EmpName").Value)));

            // �������� ��� ������ ��� ��������� ������:
            ThisReportParams Params = new ThisReportParams(reportData.Params);
            Params.WriteParamsInHeader(reportData.RepGen, reportData.DataProvider);

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
            #region #1: �������� ������

            // ...�����������
            _TableSeparator(fo);

            fo.TStart(true, ITRepStyles.TABLE, false);

            fo.TAddColumn("��� ����������", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "25%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("����������", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "25%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("����", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("�����", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("����������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "30%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            foreach (IDictionary EmpKassTrans in data.Main)
            {
                fo.TRStart();
                _WriteCell(fo, xmlEncode(EmpKassTrans["TransType"]));
                _WriteCell(fo, xmlEncode(EmpKassTrans["Reason"]));
                _WriteCell(fo, xmlEncode(((DateTime)EmpKassTrans["Date"]).ToShortDateString()));
                _WriteCell(fo, xmlEncode(EmpKassTrans["TransSum"]));
                _WriteCell(fo, xmlEncode(EmpKassTrans["Rem"]));
                fo.TREnd();
            }
            fo.TEnd();
            #endregion
        }
    }
}