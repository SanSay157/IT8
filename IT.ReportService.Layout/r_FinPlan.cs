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
    // ����� "���������� ����-����"
    public class r_FinPlan : CustomITrackerReport
    {
        // ���������� ����������� ReportService
        public r_FinPlan(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName) {}

        public class ThisReportParams
        {
            public Guid PrjGroup;                       //������ ��������
            public Guid DateRatio;                      //������� ���

            public ThisReportParams(ReportParams Params)
            {
                PrjGroup = (Guid)Params.GetParam("Group").Value;
                DateRatio = (Guid)Params.GetParam("DateRatio").Value;
            }
        }

        internal class ThisReportData
        {
            public IDictionary MainDateRatio = null;                            //������� ������ �� ��������
            public IDictionary MainPrjGroup = null;                             //�������� ������ �� ������ ��������
            public ArrayList DateRatio = null;                                  //������� ����������
            public ArrayList PrjGroup = null;                                   //������� ��������� ��������

            public ArrayList GenOutSum = null;                                  //����� ����� �������� �� ���������
            public ArrayList AOSum = null;                                      //����� ����� �������� �� �� �� ���������
            public ArrayList LoansSumFinData = null;                             //������� �������� ���������� ����������� �� ������

            public ArrayList GroupPreFinData = null;                            //������� �������� ���������� ����������� �� ������ �������
            public ArrayList GroupAfterFinData = null;                          //������� �������� ���������� ����������� �� ������ ����� ���������
            public ArrayList GroupAllFinData = null;                            //������� �������� ���������� �����������
            public ArrayList GroupFinData = null;                               //������� �������� �����������
            public ArrayList ProjectsPreFinData = null;                         //������� ����������� �������� ������ �� ������ �������
            public ArrayList ProjectsAfterFinData = null;                       //������� ����������� �������� ������ �� ������ ����� ���������
            public ArrayList ProjectsAllFinData = null;                         //������� ������ �� ����������� �������� ������
            public ArrayList ProjectsFinData = null;                            //������� ����������� �������� ������
            public ArrayList GroupSumFinData = null;                            //������� �������� ��������� �����������
            public ArrayList ProjectsSumFinData = null;                         //������� ��������� ����������� �������� ������

            public ThisReportData(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
            {
                //������ �� ���������� � ��������
                using (IDataReader reader = reportData.DataProvider.GetDataReader("IntervalSaldoDS", reportData.CustomData))
                {
                    if (reader.Read())
                        MainDateRatio = _GetDataFromDataRow(reader);
                    if (reader.NextResult())
                        DateRatio = _GetDataAsArrayList(reader);
                }
                using (IDataReader reader = reportData.DataProvider.GetDataReader("PrjGroupDS", reportData.CustomData))
                {
                    if (reader.Read())
                        MainPrjGroup = _GetDataFromDataRow(reader);
                    if (reader.NextResult())
                        PrjGroup = _GetDataAsArrayList(reader);
                }

                //����� �������, ������� �� �� � ������
                using (IDataReader reader = reportData.DataProvider.GetDataReader("GenSumOutDS", reportData.CustomData))
                {
                    GenOutSum = _GetDataAsArrayList(reader);
                    if (reader.NextResult())
                        AOSum = _GetDataAsArrayList(reader);
                    if (reader.NextResult())
                        LoansSumFinData = _GetDataAsArrayList(reader);
                }

                //���������� ���������� �� ��������
                using (IDataReader reader = reportData.DataProvider.GetDataReader("PrjGroupPreFinDataDS", reportData.CustomData))
                {
                    GroupPreFinData = _GetDataAsArrayList(reader);
                }
                using (IDataReader reader = reportData.DataProvider.GetDataReader("PrjGroupAfterFinDataDS", reportData.CustomData))
                {
                    GroupAfterFinData = _GetDataAsArrayList(reader);
                }
                using (IDataReader reader = reportData.DataProvider.GetDataReader("PrjGroupAllFinDataDS", reportData.CustomData))
                {
                    GroupAllFinData = _GetDataAsArrayList(reader);
                }
                using (IDataReader reader = reportData.DataProvider.GetDataReader("PrjGroupFinDataDS", reportData.CustomData))
                {
                    GroupFinData = _GetDataAsArrayList(reader);
                }
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectsPreFinDataDS", reportData.CustomData))
                {
                    ProjectsPreFinData = _GetDataAsArrayList(reader);
                }
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectsAfterFinDataDS", reportData.CustomData))
                {
                    ProjectsAfterFinData = _GetDataAsArrayList(reader);
                }
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectsAllFinDataDS", reportData.CustomData))
                {
                    ProjectsAllFinData = _GetDataAsArrayList(reader);
                }
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectsFinDataDS", reportData.CustomData))
                {
                    ProjectsFinData = _GetDataAsArrayList(reader);
                }
                using (IDataReader reader = reportData.DataProvider.GetDataReader("PrjGroupSumFinDataDS", reportData.CustomData))
                {
                    GroupSumFinData = _GetDataAsArrayList(reader);
                }
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectsSumFinDataDS", reportData.CustomData))
                {
                    ProjectsSumFinData = _GetDataAsArrayList(reader);
                }
            }
        }

        // �����, ����������� �����; ���������� ����������� ReportService
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
        {
            ThisReportData data = new ThisReportData(reportData);
            reportData.RepGen.WriteLayoutMaster();
            reportData.RepGen.StartPageSequence();
            reportData.RepGen.StartPageBody();
            reportData.RepGen.Header(xmlEncode(String.Format("���������� ����-����. {0}. ({1})", data.MainPrjGroup["Name"], data.MainDateRatio["Name"])));
           
            // ����������� ������ �������:
            writeMainData(reportData.RepGen, data, reportData.Params);
            reportData.RepGen.EndPageBody();
            reportData.RepGen.EndPageSequence();
        }

        /// ����������� �������� ������ ������
        private void writeMainData(XslFOProfileWriter fo, ThisReportData data, ReportParams Params)
        {
            _TableSeparator(fo);
            fo.TStart(true, ITRepStyles.TABLE, false);

            #region ����� ������

            fo.TAddColumn("", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "1%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("�� ������", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            //����� ���������� ������� � ������� ������
            int i = 4;

            //��������� �������
            foreach (IDictionary Interval in data.DateRatio)
            {
                fo.TAddColumn(xmlEncode(Interval["Name"].ToString()), align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                i++;
            }
            fo.TAddColumn("�����", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("�������", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("�����", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            i++;

            #endregion

            #region ����� ������� � ������� �� ��

            fo.TRStart();
            fo.TRAddCell("����E �������", "string", i, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();
            writeGenDataRow(fo, data.GenOutSum);
            
            fo.TRStart();
            fo.TRAddCell("����� ��", "string", i, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();
            writeGenDataRow(fo, data.AOSum);

            #endregion
                                                        
            #region �������� ���������� �� ������

            fo.TRStart();
            fo.TRAddCell("����� �� ������", "string", i, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();

            writeLoansIncOutDataRow(fo, data, 0, Params);                   //������� �� ������
            writeLoansIncOutDataRow(fo, data, 1, Params);                   //������� �� ������

            // ������ �� ������
            fo.TRStart();
            _WriteCell(fo, "C");
            writeEmptyValueCell(fo, 1);
            foreach (IDictionary fd in data.LoansSumFinData)
                _WriteCell(fo, xmlEncode(fd["SaldoSum"]));
            writeEmptyValueCell(fo, 3);
            fo.TREnd();              

            #endregion

            #region �������� ���������� �� ������ ��������
            fo.TRStart();
            fo.TRAddCell("����� �� ��������", "string", i, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();

            writeSumProjectDataRow(fo, data, "�", "IncSum");                // ������� �� ������ ��������
            writeSumProjectDataRow(fo, data, "�", "OutSum");                // ������� �� ������ ��������
            writeSumProjectDataRow(fo, data, "�", "SaldoSum");              // ������ �� ������ ��������

            // ������ �� ������ ����������� ������
            fo.TRStart();
            _WriteCell(fo, "��");
            writeEmptyValueCell(fo, 1);
            foreach (IDictionary fd in data.GroupFinData)
                _WriteCell(fo, xmlEncode(fd["SaldoSumProg"]));
            writeEmptyValueCell(fo, 3);
            fo.TREnd();
            #endregion

            #region ���������� �� ��������
            if ((int)Params.GetParam("IsPrjData").Value != 0)
                foreach (IDictionary Project in data.PrjGroup)
                {
                    //��������� �������
                    fo.TRStart();
                    fo.TRAddCell(xmlEncode(Project["Name"]), "string", i, 1, ITRepStyles.GROUP_HEADER);
                    fo.TREnd();

                    writeProjectsIncOutDataRow(fo, data, Project, 0, Params);                   //������� �� �������
                    writeProjectsIncOutDataRow(fo, data, Project, 1, Params);                   //������� �� �������

                    // ������ �� �������
                    fo.TRStart();
                    _WriteCell(fo, "�");
                
                    foreach (IDictionary fd in data.ProjectsPreFinData)         //�� ������ �������
                        if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                            _WriteCell(fo, xmlEncode(fd["SaldoSum"]));
                    foreach (IDictionary fd in data.ProjectsFinData)            //�� ����������
                        if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                            _WriteCell(fo, xmlEncode(fd["SaldoSum"]));
                    foreach (IDictionary fd in data.ProjectsSumFinData)         //����� ������
                        if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                            _WriteCell(fo, xmlEncode(fd["SaldoSum"]));
                    foreach (IDictionary fd in data.ProjectsAfterFinData)       //�������
                        if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                            _WriteCell(fo, xmlEncode(fd["SaldoSum"]));
                    foreach (IDictionary fd in data.ProjectsAllFinData)         //�����
                        if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                            _WriteCell(fo, xmlEncode(fd["SaldoSum"]));
                    fo.TREnd();

                    // ������ ����������� ������
                    fo.TRStart();
                    _WriteCell(fo, "��");
                    writeEmptyValueCell(fo, 1);
                    foreach (IDictionary fd in data.ProjectsFinData)
                        if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                            _WriteCell(fo, xmlEncode(fd["SaldoSumProg"]));
                    writeEmptyValueCell(fo, 3);
                    fo.TREnd();
                }
            #endregion

            fo.TEnd();
        }

        //������� �������� ���-�� "������" ����� �����������
        private void writeEmptyValueCell(XslFOProfileWriter fo, int j)
        {
            for (int i = 1; i <= j; i++ )
                _WriteCell(fo, "-");
        }

        // ������� ����� ���������� ������
        private void writeGenDataRow(XslFOProfileWriter fo, ArrayList al)
        {
            fo.TRStart();
            writeEmptyValueCell(fo, 2);
            foreach (IDictionary fd in al)
                _WriteCell(fo, xmlEncode(fd["Sum"].ToString()));
            writeEmptyValueCell(fo, 3);
            fo.TREnd();
        }

        // ������� �������� ���������� ������ �� ��������
        private void writeSumProjectDataRow(XslFOProfileWriter fo, ThisReportData data, string sLabel, string sCol)
        {
            fo.TRStart();
            _WriteCell(fo, sLabel);
            foreach (IDictionary fd in data.GroupPreFinData)
                _WriteCell(fo, xmlEncode(fd[sCol]));
            foreach (IDictionary fd in data.GroupFinData)
                _WriteCell(fo, xmlEncode(fd[sCol]));
            foreach (IDictionary fd in data.GroupSumFinData)
                _WriteCell(fo, xmlEncode(fd[sCol]));
            foreach (IDictionary fd in data.GroupAfterFinData)
                _WriteCell(fo, xmlEncode(fd[sCol]));
            foreach (IDictionary fd in data.GroupAllFinData)
                _WriteCell(fo, xmlEncode(fd[sCol]));
            fo.TREnd();
        }

        // ������� ������� � ������� �� ������ � ����������
        private void writeLoansIncOutDataRow(XslFOProfileWriter fo, ThisReportData data, int iType, ReportParams Params)
        {
            string sCol = "OutSum";
            fo.TRStart();
            if (iType == 0)
            {
                sCol = "IncSum";
                _WriteCell(fo, "�");
            }
            else
                _WriteCell(fo, "�");

            //�� ������ �������
            writeEmptyValueCell(fo, 1);

            //������� - �������
            foreach (IDictionary fd in data.LoansSumFinData)

                //���� ���� ������� ��� �������, �� ��������� ������ �� ����� � ������������
                if ((String)fd[sCol] != "0.00")
                {
                    StringBuilder sbDetailRef = new StringBuilder();
                    _StartReportURL(sbDetailRef, "r-LoansIncOut");
                    _AppendParamURL(sbDetailRef, "Type", iType);
                    _AppendParamURL(sbDetailRef, "PrjGroup", (Guid)Params.GetParam("Group").Value);
                    _AppendParamURL(sbDetailRef, "DateIntervalID", (Guid)fd["DateIntervalID"]);
                    _AppendParamURL(sbDetailRef, "IsSeparate", Params.GetParam("IsSeparate").Value);
                    _AppendParamURL(sbDetailRef, "Sum", fd[sCol].ToString());
                    _EndReportURL(sbDetailRef, "�����������", fd[sCol]);
                    _WriteCell(fo, sbDetailRef.ToString());
                }
                else
                    _WriteCell(fo, xmlEncode(fd[sCol]));

            //
            writeEmptyValueCell(fo, 3);
            fo.TREnd();
        }

        // ������� ������� � ������� �� �������� � ����������
        private void writeProjectsIncOutDataRow(XslFOProfileWriter fo, ThisReportData data, IDictionary Project, int iType, ReportParams Params)
        {
            string sCol = "OutSum";
            fo.TRStart();
            if (iType == 0)
            {
                sCol = "IncSum";
                _WriteCell(fo, "�");
            }
            else
                _WriteCell(fo, "�");

            //�� ������ �������
            foreach (IDictionary fd in data.ProjectsPreFinData)
                if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                    _WriteCell(fo, xmlEncode(fd[sCol]));

            //�������
            foreach (IDictionary fd in data.ProjectsFinData)
                if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])

                    //���� ���� ������� ��� �������, �� ��������� ������ �� ����� � ������������
                    if ((String)fd[sCol] != "0.00")
                    {
                        StringBuilder sbDetailRef = new StringBuilder();
                        _StartReportURL(sbDetailRef, "r-ProjectIncOut");
                        _AppendParamURL(sbDetailRef, "Type", iType);            
                        _AppendParamURL(sbDetailRef, "InContract", (Guid)fd["ObjectID"]);
                        _AppendParamURL(sbDetailRef, "DateIntervalID", (Guid)fd["DateIntervalID"]);
                        _AppendParamURL(sbDetailRef, "IsSeparate", Params.GetParam("IsSeparate").Value);
                        _AppendParamURL(sbDetailRef, "Sum", fd[sCol].ToString());
                        _EndReportURL(sbDetailRef, "�����������", fd[sCol]);
                        _WriteCell(fo, sbDetailRef.ToString());
                    }
                    else
                        _WriteCell(fo, xmlEncode(fd[sCol]));

            //����� ��������
            foreach (IDictionary fd in data.ProjectsSumFinData)
                if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                    _WriteCell(fo, xmlEncode(fd[sCol]));

            //�������
            foreach (IDictionary fd in data.ProjectsAfterFinData)
                if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                    _WriteCell(fo, xmlEncode(fd[sCol]));
            
            //�����
            foreach (IDictionary fd in data.ProjectsAllFinData)
                if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                    _WriteCell(fo, xmlEncode(fd[sCol]));
            fo.TREnd();
        }
    }
}