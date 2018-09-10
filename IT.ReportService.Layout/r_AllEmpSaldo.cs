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
    // Карточка просмотра тендера
    public class r_AllEmpSaldoDS : CustomITrackerReport
    {
        // Параметризированный конструктор. Вызывается подсистемой ReportService
        public r_AllEmpSaldoDS(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        { }


        public class ThisReportParams
        {
            public object IntervalBegin;                //Дата начала отчетного периода (включительно)
            public bool IsSpecifiedIntervalBegin;       //Признак, что дата начала отчетного периода задана
            public object IntervalEnd;                  //Дата конца отчетного периода (включительно)
            public bool IsSpecifiedIntervalEnd;         //Признак, что дата конца отчетного периода задана

            public ThisReportParams(ReportParams Params)
            {
                // Задание дат начала и конца отчетного периода
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
                // Основные данные отчета
                using (IDataReader reader = reportData.DataProvider.GetDataReader("AllEmpSaldoDS", reportData.CustomData))
                {
                    if (reader.Read())
                        Main = _GetDataAsArrayList(reader);
                }
            }
        }

        // Метод, формирующий отчет; вызывается подсистемой ReportService
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
        {
            // Получаем все данные для постоения отчета:
            ThisReportData data = new ThisReportData(reportData);
            reportData.RepGen.WriteLayoutMaster();
            reportData.RepGen.StartPageSequence();
            reportData.RepGen.StartPageBody();
            reportData.RepGen.Header(xmlEncode("Сальдо ДС по сотрудникам"));

            // Получаем все данные для постоения отчета:
            ThisReportParams Params = new ThisReportParams(reportData.Params);

            //Формируем и выводим подзаголовок
            StringBuilder sbBlock = new StringBuilder();
            string sParamValue;
            if (Params.IsSpecifiedIntervalBegin)
                sParamValue = ((DateTime)Params.IntervalBegin).ToString("dd.MM.yyyy");
            else
                sParamValue = "не задана";

            sbBlock.Append(_GetParamValueAsFoBlock("Дата начала отчетного периода", sParamValue));
            if (Params.IsSpecifiedIntervalEnd)
                sParamValue = ((DateTime)Params.IntervalEnd).ToString("dd.MM.yyyy");
            else
                sParamValue = "не задана";
            sbBlock.Append(_GetParamValueAsFoBlock("Дата окончания отчетного периода", sParamValue));
            reportData.RepGen.AddSubHeader(_MakeSubHeader(sbBlock));

            writeMainData(reportData.RepGen, data, Params);
            reportData.RepGen.EndPageBody();
            reportData.RepGen.EndPageSequence();
        }

        // Отображение в отчете основных свойств лота и тендера
        private void writeMainData(XslFOProfileWriter fo, ThisReportData data, ThisReportParams Params)
        {
            #region #1: Основные данные

            // ...разделитель
            _TableSeparator(fo);

            fo.TStart(true, ITRepStyles.TABLE, false);

            fo.TAddColumn("Сотрудник", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "13%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Балланс ДС", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Балланс ДС на начало", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Балланс ДС за период", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Получено в кассе", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Сдано по АО", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Возвращено в кассу", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Получено от сотрудников", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Передано сотрудникам", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            
            foreach (IDictionary EmpDS in data.Main)
            {
                fo.TRStart();
                _WriteCell(fo, xmlEncode(EmpDS["EmpName"]));
                _WriteCell(fo, xmlEncode(EmpDS["EmpSaldoTotal"]));
                _WriteCell(fo, xmlEncode(EmpDS["EmpSaldoDSBegin"]));

                StringBuilder sbLotHRef = new StringBuilder();

                //если существуют кассовые транзакции за данный период по сотруднику
                if ((Int32)EmpDS["IsExistsEmpKassTrans"] == 1)
                {
                    //... то сальдо ДС выводим с сылкой на отчет о детализации кассовых транзакций
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
                    _EndReportURL(sbLotHRef, "Детализация кассовых транзакций", EmpDS["EmpSaldoDS"]);
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