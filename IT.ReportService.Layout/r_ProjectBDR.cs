//Отчет "Сальдо ДС по сотрудникам"
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
    /// Бюджет Доходов и Расходов Проекта
    /// </summary>
    public class r_ProjectBDR : CustomITrackerReport
    {
        // Параметризированный конструктор. Вызывается подсистемой ReportService
        public r_ProjectBDR(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        { }
        internal class ThisReportData
        {
            public IDictionary Contract = null;
            public ArrayList Incomes, Outcomes = null;

            public ThisReportData(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
            {
                //Данные контракта
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ContractDS", reportData.CustomData))
                {
                    if (reader.Read())
                        Contract = _GetDataFromDataRow(reader);
                }
                
                //Данные по приходам проекта
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectIncomesForBDRReportDS", reportData.CustomData))
                {
                    Incomes = _GetDataAsArrayList(reader);
                }
                
                //Данные по расходам проекта
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectOutcomesForBDRReportDS", reportData.CustomData))
                {
                    Outcomes = _GetDataAsArrayList(reader);
                }
            }
        }

        // Метод, формирующий отчет; вызывается подсистемой ReportService
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
        {
            ThisReportData data = new ThisReportData(reportData);
            reportData.RepGen.WriteLayoutMaster();
            reportData.RepGen.StartPageSequence();
            reportData.RepGen.StartPageBody();

            reportData.RepGen.Header(xmlEncode("Плановый Бюджет Доходов и Расходов по проекту"));

            //Формируем и выводим подзаголовок
            StringBuilder sbBlock = new StringBuilder();
            sbBlock.Append(_GetParamValueAsFoBlock("Контракт", data.Contract["Name"].ToString()));
            
            //sbBlock.Append(_GetParamValueAsFoBlock("Сумма", reportData.Params.GetParam("Sum").ToString()));
            reportData.RepGen.AddSubHeader(_MakeSubHeader(sbBlock));

            bool bIsExtendedReport = (int)reportData.Params.GetParam("Extended").Value == 1;
            if (bIsExtendedReport)
            {
                writeExtendedReport(reportData.RepGen, data);
            }
            else
            {
                writeCommonReport(reportData.RepGen, data);

            }
            reportData.RepGen.EndPageBody();
            reportData.RepGen.EndPageSequence();
        }


        private void writeCommonReport(XslFOProfileWriter fo, ThisReportData data)
        {
            _TableSeparator(fo);

            fo.TStart(true, ITRepStyles.TABLE, false);
            fo.TAddColumn("Статья расходов/Контрагент", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "45%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Назначение", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "35%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Сумма с НДС", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Сумма без НДС", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            foreach (IDictionary IO in data.Incomes)
            {
                if ((int)IO["IncType"] < 0)
                {
                    fo.TRStart();
                    _WriteCell(fo, xmlEncode(IO["Type"]));
                    _WriteCell(fo, xmlEncode(IO["Reason"]));
                    _WriteCell(fo, xmlEncode(IO["Sum"]));
                    _WriteCell(fo, xmlEncode(IO["SumNoNDS"]));
                    fo.TREnd();
                }
                else
                {
                    fo.TRStart();
                    fo.TRAddCell(xmlEncode(IO["Type"]), "string", 2, 1, ITRepStyles.GROUP_HEADER);
                    fo.TRAddCell(xmlEncode(IO["Sum"]), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                    fo.TRAddCell(xmlEncode(IO["SumNoNDS"]), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                    fo.TREnd();
                }
            }

            foreach (IDictionary IO in data.Outcomes)
            {
                if ((int)IO["OutType"] < 10)
                {
                    fo.TRStart();
                    //_WriteCell(fo, _FormatShortDate(IO["Date"].ToString()));
                    _WriteCell(fo, xmlEncode(IO["SupplierName"]));
                    _WriteCell(fo, xmlEncode(IO["Rem"]));
                    _WriteCell(fo, xmlEncode(IO["OutSum"]));
                    _WriteCell(fo, xmlEncode(IO["OutSumNoNDS"]));
                    fo.TREnd();
                }
                else
                {
                    fo.TRStart();
                    fo.TRAddCell(xmlEncode(IO["SupplierName"]), "string", 2, 1, ITRepStyles.GROUP_HEADER);
                    fo.TRAddCell(xmlEncode(IO["OutSum"]), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                    fo.TRAddCell(xmlEncode(IO["OutSumNoNDS"]), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                    fo.TREnd();


                }
            }
            fo.TEnd();
        }

        private void writeExtendedReport(XslFOProfileWriter fo, ThisReportData data)
        {
            _TableSeparator(fo);

            fo.TStart(true, ITRepStyles.TABLE, false);
            fo.TAddColumn("Статья расходов/Контрагент", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "40%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Назначение", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "30%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("С учетом комплектации", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Сумма с НДС", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Сумма без НДС", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            foreach (IDictionary IO in data.Incomes)
            {
                if ((int)IO["IncType"] < 0)
                {
                    fo.TRStart();
                    _WriteCell(fo, xmlEncode(IO["Type"]));
                    _WriteCell(fo, xmlEncode(IO["Reason"]));
                    _WriteCell(fo, xmlEncode(""));
                    _WriteCell(fo, xmlEncode(IO["Sum"]));
                    _WriteCell(fo, xmlEncode(IO["SumNoNDS"]));
                    fo.TREnd();
                }
                else
                {
                    fo.TRStart();
                    fo.TRAddCell(xmlEncode(IO["Type"]), "string", 3, 1, ITRepStyles.GROUP_HEADER);
                    fo.TRAddCell(xmlEncode(IO["Sum"]), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                    fo.TRAddCell(xmlEncode(IO["SumNoNDS"]), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                    fo.TREnd();
                }
            }

            foreach (IDictionary IO in data.Outcomes)
            {
                if ((int)IO["OutType"] < 10)
                {
                    fo.TRStart();
                    //_WriteCell(fo, _FormatShortDate(IO["Date"].ToString()));
                    _WriteCell(fo, xmlEncode(IO["SupplierName"]));
                    _WriteCell(fo, xmlEncode(IO["Rem"]));
                    _WriteCell(fo, xmlEncode(IO["OutSumExt"]));
                    _WriteCell(fo, xmlEncode(IO["OutSum"]));
                    _WriteCell(fo, xmlEncode(IO["OutSumNoNDS"]));
                    fo.TREnd();
                }
                else
                {
                    fo.TRStart();
                    fo.TRAddCell(xmlEncode(IO["SupplierName"]), "string", 2, 1, ITRepStyles.GROUP_HEADER);
                    fo.TRAddCell(xmlEncode(IO["OutSumExt"]), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                    fo.TRAddCell(xmlEncode(IO["OutSum"]), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                    fo.TRAddCell(xmlEncode(IO["OutSumNoNDS"]), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                    fo.TREnd();


                }
            }
            fo.TEnd();

        }
    }
}