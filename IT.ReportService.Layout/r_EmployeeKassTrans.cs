//Отчет "Кассовые транзакции сотрудника"
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
    public class r_EmployeeKassTrans : CustomITrackerReport
    {
        /// <summary>
        /// Параметризированный конструктор. Вызывается подсистемой ReportService
        /// </summary>
        /// <param name="ReportProfile"></param>
        /// <param name="ReportName"></param>
        public r_EmployeeKassTrans(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        { }


        /// <summary>
        /// Внутренний класс, представляющий все актуальные параметры отчета
        /// </summary>
        public class ThisReportParams
        {

            /// <summary>
            /// ID сотрудника
            /// </summary>
            public Guid EmpID;
            /// <summary>
            /// Дата начала отчетного периода (включительно)
            /// </summary>
            public object IntervalBegin;
            /// <summary>
            /// Признак, что дата начала отчетного периода задана
            /// </summary>
            public bool IsSpecifiedIntervalBegin;
            /// <summary>
            /// Дата конца отчетного периода (включительно)
            /// </summary>
            public object IntervalEnd;
            /// <summary>
            /// Признак, что дата конца отчетного периода задана
            /// </summary>
            public bool IsSpecifiedIntervalEnd;

            /// <summary>
            /// Параметризированный конструктор. Инициализирует свойства класса на 
            /// основании данных параметров, представленных в коллекции ReportParams. 
            /// </summary>
            /// <param name="Params">Данные параметов, передаваемые в отчет</param>
            /// <remarks>
            /// При необходимости выполняет коррекцию значений параметров, полгаемых 
            /// по умолчанию, а так же расчет синтетических параметров (таких как 
            /// "Направление активности")
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
            /// Формирует текст XSL-FO, представляющий данные заданных параметров, и 
            /// записывает его как текст подзаголовка формируемого отчета
            /// </summary>
            /// <param name="foWriter"></param>
            /// <param name="cn"></param>
            public void WriteParamsInHeader(XslFOProfileWriter foWriter, IReportDataProvider Provider)
            {
                // XSL-FO с перечнем параметров будем собирать сюда:
                StringBuilder sbBlock = new StringBuilder();
                string sParamValue;



                if (IsSpecifiedIntervalBegin)
                    sParamValue = ((DateTime)IntervalBegin).ToString("dd.MM.yyyy");
                else
                    sParamValue = "не задана";
                sbBlock.Append(getParamValueAsFoBlock("Дата начала отчетного периода", sParamValue));

                if (IsSpecifiedIntervalEnd)
                    sParamValue = ((DateTime)IntervalEnd).ToString("dd.MM.yyyy");
                else
                    sParamValue = "не задана";
                sbBlock.Append(getParamValueAsFoBlock("Дата окончания отчетного периода", sParamValue));

                // ВЫВОД ПОДЗАГОЛОВКА:
                foWriter.AddSubHeader(
                    @"<fo:block text-align=""left""><fo:block font-weight=""bold"">Параметры отчета:</fo:block>" +
                    sbBlock.ToString() +
                    @"</fo:block>"
                );
            }

            /// <summary>
            /// Внутренний метод, формирует текст XSL-FO блока фиксированной структуры,
            /// представляющий пару "наименование параметра" и "значение параметра".
            /// Используется при формировании XSL-FO-текста с перечнем заданных параметров
            /// </summary>
            /// <param name="sParamName">Наименование параметра</param>
            /// <param name="sParamValueText">Текст со значением параметра</param>
            /// <returns>Строка с текстом XSL-FO блока</returns>
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
        /// Внтуренний класс, обеспечивающий загрузку и представление всех данных,
        /// необходимых для построения формы.
        /// </summary>
        internal class ThisReportData
        {

            /// <summary>
            /// Основные данные
            /// </summary>
            public ArrayList Main = null;

            /// <summary>
            /// Внутренний метод: зачитывает данные рекордсета в массив
            /// </summary>
            /// <param name="reader"></param>
            /// <returns>Если строк в рекордсете нет, возвращает null</returns>
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
            /// Параметризированный конструктор: загружает все данные тендера, 
            /// необходимые для отображения отчета
            /// </summary>
            /// <param name="connection">Соединение с БД</param>
            /// <param name="TenderID">Идентификатор тендера</param>
            public ThisReportData(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
            {
                // Основные данные отчета
                using (IDataReader reader = reportData.DataProvider.GetDataReader("EmployeeKassTransDS", reportData.CustomData))
                {
                    Main = loadDataAsArrayList(reader);
                }
            }
        }

        /// <summary>
        /// Метод, формирующий отчет; вызывается подсистемой ReportService
        /// </summary>
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
        {
            // Получаем все данные для постоения отчета:
            ThisReportData data = new ThisReportData(reportData);
            reportData.RepGen.WriteLayoutMaster();
            reportData.RepGen.StartPageSequence();
            reportData.RepGen.StartPageBody();
            reportData.RepGen.Header(String.Format("Кассовые транзакции сотрудника - {0}", xmlEncode((String)reportData.Params.GetParam("EmpName").Value)));

            // Получаем все данные для постоения отчета:
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
        /// Отображение в отчете основных свойств лота и тендера
        /// </summary>
        /// <param name="fo"></param>
        /// <param name="data">Данные тендера, данные которого отображаются</param>
        private void writeMainData(XslFOProfileWriter fo, ThisReportData data)
        {
            #region #1: Основные данные

            // ...разделитель
            _TableSeparator(fo);

            fo.TStart(true, ITRepStyles.TABLE, false);

            fo.TAddColumn("Тип транзакции", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "25%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Назначение", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "25%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Дата", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Сумма", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Примечание", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "30%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

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