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
    public class r_ProjectIncOut : CustomITrackerReport
    {
        // Параметризированный конструктор. Вызывается подсистемой ReportService
        public r_ProjectIncOut(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        { }
        internal class ThisReportData
        {
            public IDictionary Contract = null;
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
                
                //Данные контракта
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ContractDS", reportData.CustomData))
                {
                    if (reader.Read())
                        Contract = _GetDataFromDataRow(reader);
                }

                //В зависимости от типа получаем приходы или расходы
                String DS = "ProjectIncomesDS";
                if ((int)reportData.Params.GetParam("Type").Value != 0)
                    DS = "ProjectOutcomesDS";
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
                reportData.RepGen.Header(xmlEncode("Детализация приходов по проекту"));
            else
                reportData.RepGen.Header(xmlEncode("Детализация расходов по проекту"));

            //Формируем и выводим подзаголовок
            StringBuilder sbBlock = new StringBuilder();
            sbBlock.Append(_GetParamValueAsFoBlock("Контракт", data.Contract["Name"].ToString()));
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
            fo.TAddColumn("Дата", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Сумма", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Тип", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Назначение", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "22%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            if(Type == 1)
                fo.TAddColumn("Организация/Сотрудник", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "23%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            
            fo.TAddColumn("Документ", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Дата документа", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            
            foreach (IDictionary IO in data.IncOut)
            {
                fo.TRStart();
                _WriteCell(fo, _FormatShortDate(IO["Date"].ToString()));
                _WriteCell(fo, xmlEncode(IO["Sum"]));
                _WriteCell(fo, xmlEncode(IO["Type"]));
                _WriteCell(fo, xmlEncode(IO["Reason"]));
                if (Type == 1)
                    _WriteCell(fo, xmlEncode(IO["Org"]));     
                _WriteCell(fo, xmlEncode(IO["Document"]));
                _WriteCell(fo, _FormatShortDate(IO["DocDate"].ToString()));
                fo.TREnd();
            }
            fo.TEnd();
            #endregion
        }
    }
}