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
    public class r_Tender : CustomITrackerReport
    {
        /// <summary>
        /// Параметризированный конструктор. Вызывается подсистемой ReportService
        /// </summary>
        /// <param name="ReportProfile"></param>
        /// <param name="ReportName"></param>
        public r_Tender(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        { }

        /// <summary>
        /// Внтуренний класс, обеспечивающий загрузку и представление всех данных,
        /// необходимых для построения формы.
        /// </summary>
        internal class ThisReportData
        {

            /// <summary>
            /// Основные данные по тендеру
            /// </summary>
            public IDictionary Main = null;
            /// <summary>
            /// Набор "внешних" ссылок
            /// </summary>
            public ArrayList Links = null;
            /// <summary>
            /// Перечень участников конкурса(лота)
            /// </summary>
            public ArrayList Parts = null;
            /// <summary>
            /// Перечень участников от департамнентов
            /// </summary>
            public ArrayList DepParts = null;
            /// <summary>
            /// Тип отчета (0 - все данные, 1 - для заказчика)
            /// </summary>
            public Int32 ViewType = 0;

            /// <summary>
            /// Параметризированный конструктор: загружает все данные тендера, 
            /// необходимые для отображения отчета
            /// </summary>
            /// <param name="connection">Соединение с БД</param>
            /// <param name="TenderID">Идентификатор тендера</param>
            public ThisReportData(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData, Guid TenderID)
            {
                // #1: Выполняем запрос(ы):
                using (IDataReader reader = reportData.DataProvider.GetDataReader("dsTender", reportData.CustomData))
                {
                    IDictionary row;

                    // Основные данные:
                    if (reader.Read())
                        Main = _GetDataFromDataRow(reader);

                    // Данные внешних ссылок
                    if (reader.NextResult())
                    {
                        ArrayList data = new ArrayList();
                        while (reader.Read())
                        {
                            row = _GetDataFromDataRow(reader);
                            data.Add(row);
                        }
                        if (0 != data.Count)
                            Links = data;
                    }

                    // Данные перечня участников тендера
                    if (reader.NextResult())
                    {
                        ArrayList data = new ArrayList();
                        while (reader.Read())
                        {
                            row = _GetDataFromDataRow(reader);
                            data.Add(row);
                        }
                        if (0 != data.Count)
                            Parts = data;
                    }

                    // Данные перечня участников от департаментов
                    if (reader.NextResult())
                    {
                        ArrayList data = new ArrayList();
                        while (reader.Read())
                        {
                            row = _GetDataFromDataRow(reader);
                            data.Add(row);
                        }
                        if (0 != data.Count)
                            DepParts = data;
                    }
                }
            }
        }

        /// <summary>
        /// Метод, формирующий отчет; вызывается подсистемой ReportService
        /// </summary>
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
        {
            // Получаем идентификатор тендра из переданных параметров
            Guid TenderID = (Guid)reportData.Params.GetParam("TenderID").Value;

            // Получаем все данные для постоения отчета:
            ThisReportData data = new ThisReportData(reportData, TenderID);
            data.ViewType = (Int32)reportData.Params.GetParam("ViewType").Value;
            if (null == data.Main)
            {
                writeEmptyBody(reportData.RepGen, String.Format(
                    "Указанное описание конкурса в Системе не найдно (заданный идентификатор - {0})",
                    TenderID.ToString().ToUpper()));
                return;
            }
            reportData.RepGen.WriteLayoutMaster();
            reportData.RepGen.StartPageSequence();
            reportData.RepGen.StartPageBody();
            reportData.RepGen.Header(xmlEncode(String.Format(
                    "Конкурс {0}\"{1}\"",
                    (null == data.Main["Number"] ? "" : "№ " + data.Main["Number"] + ", "),
                    data.Main["Tender"]
                )));

            // Отображение данных тендера:
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
            string sValue;

            #region #1: Основные данные

            // ...разделитель
            _TableSeparator(fo);

            fo.TStart(false, ITRepStyles.TABLE, false);
            fo.TAddColumn("Характеристика", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "30%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Значение", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "70%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            fo.TRStart();
            fo.TRAddCell("Основные реквизиты", "string", 2, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();
            if ((Int32)data.Main["CustEqOrg"] == 1)
                writeDataPair(fo, "Заказчик/Организатор", xmlEncode(data.Main["Customer"]));
            else
                writeDataPair(fo, "Заказчик/Организатор", xmlEncode(data.Main["Customer"]) + " / " + xmlEncode(data.Main["Organizer"]));
            writeDataPair(fo, "Дата подачи документов", _FormatLongDateTime(data.Main["DocFeedingDate"]));
            writeDataPair(fo, "Дата проведения переторжки", _FormatLongDateTime(data.Main["DateTorg1"]));
            writeDataPair(fo, "Дата проведения 2й переторжки", _FormatLongDateTime(data.Main["DateTorg2"]));

            // ...Директор Клиента:
            if(data.ViewType == 0)
                writeDataPair(fo, "Директор Клиента", _GetUserMailAnchor(data.Main["DirectorName"], data.Main["DirectorEMail"]));

            // ...cостояние: цвет фона в зависимости от состояния
            LotState state = (LotState)(Int32.Parse(data.Main["State"].ToString()));
            if (LotState.WasGain == state)
                sValue = ITRepStyles.TABLE_CELL_COLOR_GREEN;
            else if (LotState.WasLoss == state)
                sValue = ITRepStyles.TABLE_CELL_COLOR_RED;
            else
                sValue = ITRepStyles.TABLE_CELL;
            writeDataPair(fo, "Состояние",
                "<fo:inline font-weight='bold'>" + xmlEncode(data.Main["StateName"]) + "</fo:inline>",
                sValue);

            // ...Контактное лицо конкурсной комисси:
            fo.TRStart();
            fo.TRAddCell("Контактное лицо конкурсной комисси", "string", 2, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();
            writeDataPair(fo, "Фамилия, имя, отчество ", xmlEncode(data.Main["JuryContactName"]));
            writeDataPair(fo, "Телефон ", xmlEncode(data.Main["JuryContactPhone"]));
            writeDataPair(fo, "Адрес электронной почты", _GetUserMailAnchor(data.Main["JuryContactEMail"], data.Main["JuryContactEMail"]));

            fo.TEnd();
            #endregion

            #region #2: Данные участников конкурса:
			if (null != data.Parts)
			{
				// ...разделитель
				_TableSeparator( fo );

				fo.TStart( true, ITRepStyles.TABLE, false );

				bool isFinalState = (LotState.WasGain == state || LotState.WasLoss == state);
                int nCol = fo.TAddColumn("Участники конкурса", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "Организация", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "12%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "Тип участия", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "Отклонен", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "7%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
				if (isFinalState)
                    fo.TAddSubColumn(nCol, "Итоговый статус", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "Сумма подачи, " + xmlEncode(data.Main["NDS"]), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "Сумма переторжки, " + xmlEncode(data.Main["NDS"]), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "Сумма 2й переторжки, " + xmlEncode(data.Main["NDS"]), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "Сумма подачи АП, " + xmlEncode(data.Main["NDS"]), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "Сумма переторжки АП, " + xmlEncode(data.Main["NDS"]), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "Сумма 2й переторжки АП, " + xmlEncode(data.Main["NDS"]), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "8%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

                fo.TAddSubColumn(nCol, "Примечание", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, (isFinalState ? "8%" : "13%"), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

				foreach (IDictionary orgData in data.Parts)
				{
					fo.TRStart();
					_WriteCell(fo, xmlEncode(orgData["ParticipantOrganization"]) );
					_WriteCell(fo, xmlEncode(orgData["ParticipationType"]) );
                    _WriteCell(fo, xmlEncode(orgData["DeclinedText"]));
					if (isFinalState)
					{
						bool isWinner = (null!=orgData["Winner"]);
						_WriteCell( fo, 
							"<fo:inline font-weight='bold'>" + (isWinner? "Победитель" : "Проигравший") + "</fo:inline>", 
							"string", 
							(isWinner? ITRepStyles.TABLE_CELL_COLOR_GREEN : ITRepStyles.TABLE_CELL_COLOR_RED) );
					}
                    _WriteCell(fo, xmlEncode(orgData["TenderParticipantPrice"]));
                    _WriteCell(fo, xmlEncode(orgData["SumTorg1"]));
                    _WriteCell(fo, xmlEncode(orgData["SumTorg2"]));
                    _WriteCell(fo, xmlEncode(orgData["TenderParticipantPriceAP"]));
                    _WriteCell(fo, xmlEncode(orgData["SumTorg1AP"]));
                    _WriteCell(fo, xmlEncode(orgData["SumTorg2AP"]));
                    _WriteCell(fo, xmlEncode(orgData["Note"]));
                    fo.TREnd();
				}
				fo.TEnd();
			}

			#endregion

            #region #3: Участие подразделений (если такие данные есть)
            if (null != data.DepParts && data.ViewType == 0)
            {
                // ...разделитель
                _TableSeparator(fo);

                fo.TStart(true, ITRepStyles.TABLE, false);

                int nCol = fo.TAddColumn("Участие департаментов", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, null, align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "Департамент", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "Исполнитель", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "Ознакомился", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nCol, "Примечание", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "40%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

                foreach (IDictionary depData in data.DepParts)
                {
                    fo.TRStart();
                    _WriteCell(fo, xmlEncode(depData["Department"]));

                    // Исполнитель от подразделения:
                    sValue = _GetUserMailAnchor(depData["ExecutorName"], depData["ExecutorEMail"]);
                    if (null != depData["DocsGettingDate"])
                        sValue = sValue + (String.Empty != sValue ? ", " : "") + "документы получил(а) " + _FormatLongDate(depData["DocsGettingDate"]);
                    _WriteCell(fo, sValue);

                    _WriteCell(fo, xmlEncode(depData["ExecutorIsAcquaint"]));
                    _WriteCell(fo, xmlEncode(depData["Note"]));
                    fo.TREnd();
                }
                fo.TEnd();
            }

            #endregion

            #region #3: Внешние ссылки (если таковые есть)
            if (null != data.Links && data.ViewType == 0)
            {
                // ...разделитель
                _TableSeparator(fo);

                fo.TStart(false, ITRepStyles.TABLE, false);
                fo.TAddColumn("Тип ссылки", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "15%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddColumn("Ссылка", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "85%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

                fo.TRStart();
                fo.TRAddCell("Внешние ссылки", "string", 2, 1, ITRepStyles.GROUP_HEADER);
                fo.TREnd();

                foreach (IDictionary linkData in data.Links)
                {
                    string sLinkHRef = String.Format(
                            "<fo:basic-link " +
                                "text-decoration=\"none\" " +
                                "external-destination=\"vbscript:window.OpenExternalLink({0},&quot;{1}&quot;)\">" +
                            "{2}</fo:basic-link> " +
                            "( полный адрес: <fo:basic-link " +
                                "text-decoration=\"none\" " +
                                "external-destination=\"vbscript:window.OpenExternalLink({0},&quot;{1}&quot;)\">" +
                            "{1}</fo:basic-link> )",
                            linkData["LinkServiceType"],		// {0}, тип обслуживающей системы
                            xmlEncode(linkData["URI"]),			// {1}, URI ссылки
                            xmlEncode(linkData["LinkName"])		// {2}, отображаемое значение ссылки
                        );

                    fo.TRStart();
                    _WriteCell(fo, xmlEncode(linkData["ServiceTypeName"]));
                    _WriteCell(fo, sLinkHRef, "string");
                    fo.TREnd();
                }
                fo.TEnd();
            }
            #endregion

            #region #4: Дополнительные данные
            _TableSeparator(fo);

            fo.TStart(false, ITRepStyles.TABLE, false);
            fo.TAddColumn("Характеристика", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "30%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Значение", align.ALIGN_LEFT, valign.VALIGN_TOP, null, "70%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            fo.TRStart();
            fo.TRAddCell("Дополнительно", "string", 2, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();

            writeDataPair(fo, "К обсуждению", xmlEncode(data.Main["QualifyingRequirement"]));
            if (data.ViewType == 0)
            {
                writeDataPair(fo, "Примечание", xmlEncode(data.Main["Note"]));
                writeDataPair(fo, "Обсуждения", xmlEncode(data.Main["Discussion"]));
            }
            fo.TEnd();
            #endregion
        }
    }
}
