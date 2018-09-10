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
    public class r_EmployeeSaldoDS : CustomITrackerReport
    {
        /// <summary>
        /// ������������������� �����������. ���������� ����������� ReportService
        /// </summary>
        /// <param name="ReportProfile"></param>
        /// <param name="ReportName"></param>
        public r_EmployeeSaldoDS(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        { }

        /// <summary>
        /// ���������� �����, �������������� �������� � ������������� ���� ������,
        /// ����������� ��� ���������� �����.
        /// </summary>
        internal class ThisReportData
        {

            /// <summary>
            /// �������� ������
            /// </summary>
            public IDictionary Main = null;
            
            /// <summary>
            /// ������������������� �����������: ��������� ��� ������ �������, 
            /// ����������� ��� ����������� ������
            /// </summary>
            /// <param name="connection">���������� � ��</param>
            /// <param name="TenderID">������������� �������</param>
            public ThisReportData(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData, Guid TenderID)
            {
                // �������� ������ ������
                using (IDataReader reader = reportData.DataProvider.GetDataReader("EmployeeSaldoDS", reportData.CustomData))
                {
                    if (reader.Read())
                        Main = _GetDataFromDataRow(reader);
                }
            }
        }

        /// <summary>
        /// �����, ����������� �����; ���������� ����������� ReportService
        /// </summary>
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
        {
            // �������� ������������� ������ �� ���������� ����������
            Guid EmployeeID = (Guid)reportData.Params.GetParam("EmployeeID").Value;

            // �������� ��� ������ ��� ��������� ������:
            ThisReportData data = new ThisReportData(reportData, EmployeeID);
            if (null == data.Main)
            {
                writeEmptyBody(reportData.RepGen, String.Format(
                    "��������� � ������� �� ������! (�������� ������������� - {0})",
                    EmployeeID.ToString()));
                return;
            }
            reportData.RepGen.WriteLayoutMaster();
            reportData.RepGen.StartPageSequence();
            reportData.RepGen.StartPageBody();
            reportData.RepGen.Header(xmlEncode(String.Format("������ �� �� ����������: {0} {1}", data.Main["LastName"], data.Main["FirstName"])));
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

            fo.TStart(false, ITRepStyles.TABLE, false);
            fo.TAddColumn("��������������", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "30%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("��������", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "70%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            writeDataPair(fo, "�������� � �����", xmlEncode(data.Main["KassRecieved"]));
            writeDataPair(fo, "����� �� �� (����� 04/10/2013)", xmlEncode(data.Main["AOSended"]));
            writeDataPair(fo, "���������� � �����", xmlEncode(data.Main["KassReturned"]));
            writeDataPair(fo, "�������� �� ������ �����������", xmlEncode(data.Main["EmpRecieved"]));
            writeDataPair(fo, "�������� ������ �����������", xmlEncode(data.Main["EmpSended"]));
            writeDataPair(fo, "�������� ������ ��", "<fo:inline font-weight='bold'>" + xmlEncode(data.Main["EmpSaldoDS"]) + "</fo:inline>");
            
            fo.TEnd();
            #endregion
        }
    }
}