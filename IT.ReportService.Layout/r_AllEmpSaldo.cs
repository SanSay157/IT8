//����� "������ �� �� �����������"
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
    // �������� ��������� �������
    public class r_AllEmpSaldoDS : CustomITrackerReport
    {
        // ������������������� �����������. ���������� ����������� ReportService
        public r_AllEmpSaldoDS(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        { }


        public class ThisReportParams
        {
            public object IntervalBegin;                //���� ������ ��������� ������� (������������)
            public bool IsSpecifiedIntervalBegin;       //�������, ��� ���� ������ ��������� ������� ������
            public object IntervalEnd;                  //���� ����� ��������� ������� (������������)
            public bool IsSpecifiedIntervalEnd;         //�������, ��� ���� ����� ��������� ������� ������

            public ThisReportParams(ReportParams Params)
            {
                // ������� ��� ������ � ����� ��������� �������
                IsSpecifiedIntervalBegin = !Params.GetParam("IntervalBegin").IsNull;
                IntervalBegin = (IsSpecifiedIntervalBegin ? Params.GetParam("IntervalBegin").Value : DBNull.Value);
                IsSpecifiedIntervalEnd = !Params.GetParam("IntervalEnd").IsNull;
                IntervalEnd = (IsSpecifiedIntervalEnd ? Params.GetParam("IntervalEnd").Value : DBNull.Value);
            }
        }

        internal class ThisReportData
        {
            public ArrayList Main = null;
            
            public ThisReportData(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
            {
                // �������� ������ ������
                using (IDataReader reader = reportData.DataProvider.GetDataReader("AllEmpSaldoDS", reportData.CustomData))
                {
                    if (reader.Read())
                        Main = _GetDataAsArrayList(reader);
                }
            }
        }

        // �����, ����������� �����; ���������� ����������� ReportService
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
        {
            // �������� ��� ������ ��� ��������� ������:
            ThisReportData data = new ThisReportData(reportData);
            reportData.RepGen.WriteLayoutMaster();
            reportData.RepGen.StartPageSequence();
            reportData.RepGen.StartPageBody();
            reportData.RepGen.Header(xmlEncode("������ �� �� �����������"));

            // �������� ��� ������ ��� ��������� ������:
            ThisReportParams Params = new ThisReportParams(reportData.Params);

            //��������� � ������� ������������
            StringBuilder sbBlock = new StringBuilder();
            string sParamValue;
            if (Params.IsSpecifiedIntervalBegin)
                sParamValue = ((DateTime)Params.IntervalBegin).ToString("dd.MM.yyyy");
            else
                sParamValue = "�� ������";

            sbBlock.Append(_GetParamValueAsFoBlock("���� ������ ��������� �������", sParamValue));
            if (Params.IsSpecifiedIntervalEnd)
                sParamValue = ((DateTime)Params.IntervalEnd).ToString("dd.MM.yyyy");
            else
                sParamValue = "�� ������";
            sbBlock.Append(_GetParamValueAsFoBlock("���� ��������� ��������� �������", sParamValue));
            reportData.RepGen.AddSubHeader(_MakeSubHeader(sbBlock));

            writeMainData(reportData.RepGen, data, Params);
            reportData.RepGen.EndPageBody();
            reportData.RepGen.EndPageSequence();
        }

        // ����������� � ������ �������� ������� ���� � �������
        private void writeMainData(XslFOProfileWriter fo, ThisReportData data, ThisReportParams Params)
        {
            #region #1: �������� ������

            // ...�����������
            _TableSeparator(fo);

            fo.TStart(true, ITRepStyles.TABLE, false);

            fo.TAddColumn("���������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "13%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("������� ��", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("������� �� �� ������", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("������� �� �� ������", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("�������� � �����", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("����� �� ��", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("���������� � �����", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("�������� �� �����������", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("�������� �����������", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            
            foreach (IDictionary EmpDS in data.Main)
            {
                fo.TRStart();
                _WriteCell(fo, xmlEncode(EmpDS["EmpName"]));
                _WriteCell(fo, xmlEncode(EmpDS["EmpSaldoTotal"]));
                _WriteCell(fo, xmlEncode(EmpDS["EmpSaldoDSBegin"]));

                StringBuilder sbLotHRef = new StringBuilder();

                //���� ���������� �������� ���������� �� ������ ������ �� ����������
                if ((Int32)EmpDS["IsExistsEmpKassTrans"] == 1)
                {
                    //... �� ������ �� ������� � ������ �� ����� � ����������� �������� ����������
                    _StartReportURL(sbLotHRef, "r-EmployeeKassTrans");
                    _AppendParamURL(sbLotHRef, "EmpID", (Guid)EmpDS["EmpID"]);
                    _AppendParamURL(sbLotHRef, "EmpName", EmpDS["EmpName"]);
                    if (Params.IsSpecifiedIntervalBegin)
                    {
                        _AppendParamURL(sbLotHRef, "IntervalBegin", ((DateTime)Params.IntervalBegin).ToString("yyyy-MM-dd"));
                    }
                    if (Params.IsSpecifiedIntervalEnd)
                    {
                        _AppendParamURL(sbLotHRef, "IntervalEnd", ((DateTime)Params.IntervalEnd).ToString("yyyy-MM-dd"));
                    }
                    _EndReportURL(sbLotHRef, "����������� �������� ����������", EmpDS["EmpSaldoDS"]);
                }
                else
                    sbLotHRef.Append(xmlEncode(EmpDS["EmpSaldoDS"]));

                _WriteCell(fo, sbLotHRef, "string", ITRepStyles.TABLE_CELL_BOLD);
                _WriteCell(fo, xmlEncode(EmpDS["KassRecieved"]));
                _WriteCell(fo, xmlEncode(EmpDS["AOSended"]));
                _WriteCell(fo, xmlEncode(EmpDS["KassReturned"]));
                _WriteCell(fo, xmlEncode(EmpDS["EmpRecieved"]));
                _WriteCell(fo, xmlEncode(EmpDS["EmpSended"]));
                fo.TREnd();
            }
            fo.TEnd();
            #endregion
        }
    }
}