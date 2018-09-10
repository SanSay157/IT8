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
    /// Карточка просмотра тендера
    /// </summary>
    public class r_LoansIncOut : CustomITrackerReport
    {
        // Параметризированный конструктор. Вызывается подсистемой ReportService
        public r_LoansIncOut(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        { }
        internal class ThisReportData
        {
            public IDictionary DateInterval = null;
            public ArrayList IncOut = null;
            
            public ThisReportData(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
            {
                //Данные временного интевала
                using (IDataReader reader = reportData.DataProvider.GetDataReader("DateIntervalDS", reportData.CustomData))
                {
                    if (reader.Read())
                        DateInterval = _GetDataFromDataRow(reader);
                }

                //В зависимости от типа получаем приходы или расходы
                String DS = null;
                if ((int)reportData.Params.GetParam("Type").Value == 0)
                    DS = "LoansIncomesDS";
                else
                    DS = "LoansOutcomesDS";
                using (IDataReader reader = reportData.DataProvider.GetDataReader(DS, reportData.CustomData))
                {
                    IncOut = _GetDataAsArrayList(reader);
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
            if ((int)reportData.Params.GetParam("Type").Value == 0)
                reportData.RepGen.Header(xmlEncode("Детализация приходов по займам"));
            else
                reportData.RepGen.Header(xmlEncode("Детализация расходов по займам"));

            //Формируем и выводим подзаголовок
            StringBuilder sbBlock = new StringBuilder();
            sbBlock.Append(_GetParamValueAsFoBlock("Интервал времени", data.DateInterval["Name"].ToString() + 
                " (" + _FormatShortDate(data.DateInterval["DateFrom"].ToString()) + " - " + _FormatShortDate(data.DateInterval["DateTo"].ToString()) + ")"));
            sbBlock.Append(_GetParamValueAsFoBlock("Сумма", reportData.Params.GetParam("Sum").ToString()));
            reportData.RepGen.AddSubHeader(_MakeSubHeader(sbBlock));

            writeMainData(reportData.RepGen, data, (int)reportData.Params.GetParam("Type").Value);
            reportData.RepGen.EndPageBody();
            reportData.RepGen.EndPageSequence();
        }

        private void writeMainData(XslFOProfileWriter fo, ThisReportData data, int Type)
        {
            #region #1: Основные данные

            _TableSeparator(fo);

            fo.TStart(true, ITRepStyles.TABLE, false);
            fo.TAddColumn("Займ №", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "15%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Тип займа", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "15%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Целевая компания/Сотрудник", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "30%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Дата", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "15%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Сумма", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "15%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            
            foreach (IDictionary IO in data.IncOut)
            {
                fo.TRStart();
                _WriteCell(fo, xmlEncode(IO["Number"]));
                _WriteCell(fo, xmlEncode(IO["LoanType"]));
                _WriteCell(fo, xmlEncode(IO["LoanTarget"]));
                _WriteCell(fo, _FormatShortDate(IO["Date"].ToString()));
                _WriteCell(fo, xmlEncode(IO["Sum"]));
                fo.TREnd();
            }
            fo.TEnd();
            #endregion
        }
    }
}