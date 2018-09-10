//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
// Код формы просмотра данных тендера (отчет "Карточка тендера")
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
    /// Карточка просмотра тендера
    /// </summary>
    public class r_EmployeeSaldoDS : CustomITrackerReport
    {
        /// <summary>
        /// Параметризированный конструктор. Вызывается подсистемой ReportService
        /// </summary>
        /// <param name="ReportProfile"></param>
        /// <param name="ReportName"></param>
        public r_EmployeeSaldoDS(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        { }

        /// <summary>
        /// Внтуренний класс, обеспечивающий загрузку и представление всех данных,
        /// необходимых для построения формы.
        /// </summary>
        internal class ThisReportData
        {

            /// <summary>
            /// Основные данные
            /// </summary>
            public IDictionary Main = null;
            
            /// <summary>
            /// Параметризированный конструктор: загружает все данные тендера, 
            /// необходимые для отображения отчета
            /// </summary>
            /// <param name="connection">Соединение с БД</param>
            /// <param name="TenderID">Идентификатор тендера</param>
            public ThisReportData(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData, Guid TenderID)
            {
                // Основные данные отчета
                using (IDataReader reader = reportData.DataProvider.GetDataReader("EmployeeSaldoDS", reportData.CustomData))
                {
                    if (reader.Read())
                        Main = _GetDataFromDataRow(reader);
                }
            }
        }

        /// <summary>
        /// Метод, формирующий отчет; вызывается подсистемой ReportService
        /// </summary>
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
        {
            // Получаем идентификатор тендра из переданных параметров
            Guid EmployeeID = (Guid)reportData.Params.GetParam("EmployeeID").Value;

            // Получаем все данные для постоения отчета:
            ThisReportData data = new ThisReportData(reportData, EmployeeID);
            if (null == data.Main)
            {
                writeEmptyBody(reportData.RepGen, String.Format(
                    "Сотрудник в Системе не найден! (заданный идентификатор - {0})",
                    EmployeeID.ToString()));
                return;
            }
            reportData.RepGen.WriteLayoutMaster();
            reportData.RepGen.StartPageSequence();
            reportData.RepGen.StartPageBody();
            reportData.RepGen.Header(xmlEncode(String.Format("Сальдо ДС по сотруднику: {0} {1}", data.Main["LastName"], data.Main["FirstName"])));
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

            fo.TStart(false, ITRepStyles.TABLE, false);
            fo.TAddColumn("Характеристика", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "30%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Значение", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "70%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            writeDataPair(fo, "Получено в кассе", xmlEncode(data.Main["KassRecieved"]));
            writeDataPair(fo, "Сдано по АО (после 04/10/2013)", xmlEncode(data.Main["AOSended"]));
            writeDataPair(fo, "Возвращено в кассу", xmlEncode(data.Main["KassReturned"]));
            writeDataPair(fo, "Получено от других содрудников", xmlEncode(data.Main["EmpRecieved"]));
            writeDataPair(fo, "Передано другим сотрудникам", xmlEncode(data.Main["EmpSended"]));
            writeDataPair(fo, "Итоговое сальдо ДС", "<fo:inline font-weight='bold'>" + xmlEncode(data.Main["EmpSaldoDS"]) + "</fo:inline>");
            
            fo.TEnd();
            #endregion
        }
    }
}