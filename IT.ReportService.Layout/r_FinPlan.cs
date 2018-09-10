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
    // Отчет "Финансовый план-факт"
    public class r_FinPlan : CustomITrackerReport
    {
        // Вызывается подсистемой ReportService
        public r_FinPlan(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName) {}

        public class ThisReportParams
        {
            public Guid PrjGroup;                       //Группа проектов
            public Guid DateRatio;                      //Масштаб дат

            public ThisReportParams(ReportParams Params)
            {
                PrjGroup = (Guid)Params.GetParam("Group").Value;
                DateRatio = (Guid)Params.GetParam("DateRatio").Value;
            }
        }

        internal class ThisReportData
        {
            public IDictionary MainDateRatio = null;                            //Осноные данные по масштабу
            public IDictionary MainPrjGroup = null;                             //Основные данные по группе проектов
            public ArrayList DateRatio = null;                                  //Таблица интервалов
            public ArrayList PrjGroup = null;                                   //Таблица контраков проектов

            public ArrayList GenOutSum = null;                                  //Сумма общих расходов по интервалу
            public ArrayList AOSum = null;                                      //Сумма общих расходов по АО по интервалу
            public ArrayList LoansSumFinData = null;                             //Таблица итоговых финансовых показателей по займам

            public ArrayList GroupPreFinData = null;                            //Таблица итоговых финансовых показателей на начало периода
            public ArrayList GroupAfterFinData = null;                          //Таблица итоговых финансовых показателей на период после отчетного
            public ArrayList GroupAllFinData = null;                            //Таблица итоговых финансовых показателей
            public ArrayList GroupFinData = null;                               //Таблица итоговых показателей
            public ArrayList ProjectsPreFinData = null;                         //Таблица показателей проектов группы на начало периода
            public ArrayList ProjectsAfterFinData = null;                       //Таблица показателей проектов группы на период после отчетного
            public ArrayList ProjectsAllFinData = null;                         //Таблица итогов по показателям проектов группы
            public ArrayList ProjectsFinData = null;                            //Таблица показателей проектов группы
            public ArrayList GroupSumFinData = null;                            //Таблица итоговых суммарных показателей
            public ArrayList ProjectsSumFinData = null;                         //Таблица суммарных показателей проектов группы

            public ThisReportData(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
            {
                //Данные по интервалам и проектам
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

                //Общие расходы, расходы по АО и займам
                using (IDataReader reader = reportData.DataProvider.GetDataReader("GenSumOutDS", reportData.CustomData))
                {
                    GenOutSum = _GetDataAsArrayList(reader);
                    if (reader.NextResult())
                        AOSum = _GetDataAsArrayList(reader);
                    if (reader.NextResult())
                        LoansSumFinData = _GetDataAsArrayList(reader);
                }

                //Финансовые показатели по проектам
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

        // Метод, формирующий отчет; вызывается подсистемой ReportService
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData reportData)
        {
            ThisReportData data = new ThisReportData(reportData);
            reportData.RepGen.WriteLayoutMaster();
            reportData.RepGen.StartPageSequence();
            reportData.RepGen.StartPageBody();
            reportData.RepGen.Header(xmlEncode(String.Format("Финансовый план-факт. {0}. ({1})", data.MainPrjGroup["Name"], data.MainDateRatio["Name"])));
           
            // Отображение данных тендера:
            writeMainData(reportData.RepGen, data, reportData.Params);
            reportData.RepGen.EndPageBody();
            reportData.RepGen.EndPageSequence();
        }

        /// Отображение основных данных отчета
        private void writeMainData(XslFOProfileWriter fo, ThisReportData data, ReportParams Params)
        {
            _TableSeparator(fo);
            fo.TStart(true, ITRepStyles.TABLE, false);

            #region Шапка отчета

            fo.TAddColumn("", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "1%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("На начало", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            //Общее количество колонок в таблице отчета
            int i = 4;

            //Заголовки колонок
            foreach (IDictionary Interval in data.DateRatio)
            {
                fo.TAddColumn(xmlEncode(Interval["Name"].ToString()), align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                i++;
            }
            fo.TAddColumn("Итого", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Остаток", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Всего", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            i++;

            #endregion

            #region Общие расходы и расходы по АО

            fo.TRStart();
            fo.TRAddCell("ОБЩИE РАСХОДЫ", "string", i, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();
            writeGenDataRow(fo, data.GenOutSum);
            
            fo.TRStart();
            fo.TRAddCell("ОБЩИЕ АО", "string", i, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();
            writeGenDataRow(fo, data.AOSum);

            #endregion
                                                        
            #region Итоговые показатели по займам

            fo.TRStart();
            fo.TRAddCell("ВСЕГО ПО ЗАЙМАМ", "string", i, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();

            writeLoansIncOutDataRow(fo, data, 0, Params);                   //Приходы по займам
            writeLoansIncOutDataRow(fo, data, 1, Params);                   //Расходы по займам

            // Сальдо по займам
            fo.TRStart();
            _WriteCell(fo, "C");
            writeEmptyValueCell(fo, 1);
            foreach (IDictionary fd in data.LoansSumFinData)
                _WriteCell(fo, xmlEncode(fd["SaldoSum"]));
            writeEmptyValueCell(fo, 3);
            fo.TREnd();              

            #endregion

            #region Итоговые показатели по группе проектов
            fo.TRStart();
            fo.TRAddCell("ВСЕГО ПО ПРОЕКТАМ", "string", i, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();

            writeSumProjectDataRow(fo, data, "П", "IncSum");                // Приходы по группе проектов
            writeSumProjectDataRow(fo, data, "Р", "OutSum");                // Расходы по группе проектов
            writeSumProjectDataRow(fo, data, "С", "SaldoSum");              // Сальдо по группе проектов

            // Сальдо по группе нарастающим итогом
            fo.TRStart();
            _WriteCell(fo, "НИ");
            writeEmptyValueCell(fo, 1);
            foreach (IDictionary fd in data.GroupFinData)
                _WriteCell(fo, xmlEncode(fd["SaldoSumProg"]));
            writeEmptyValueCell(fo, 3);
            fo.TREnd();
            #endregion

            #region Показатели по проектам
            if ((int)Params.GetParam("IsPrjData").Value != 0)
                foreach (IDictionary Project in data.PrjGroup)
                {
                    //Заголовок проекта
                    fo.TRStart();
                    fo.TRAddCell(xmlEncode(Project["Name"]), "string", i, 1, ITRepStyles.GROUP_HEADER);
                    fo.TREnd();

                    writeProjectsIncOutDataRow(fo, data, Project, 0, Params);                   //Приходы по проекту
                    writeProjectsIncOutDataRow(fo, data, Project, 1, Params);                   //Расходы по проекту

                    // Сальдо по проекту
                    fo.TRStart();
                    _WriteCell(fo, "С");
                
                    foreach (IDictionary fd in data.ProjectsPreFinData)         //На начало периода
                        if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                            _WriteCell(fo, xmlEncode(fd["SaldoSum"]));
                    foreach (IDictionary fd in data.ProjectsFinData)            //По интервалам
                        if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                            _WriteCell(fo, xmlEncode(fd["SaldoSum"]));
                    foreach (IDictionary fd in data.ProjectsSumFinData)         //Итого сальдо
                        if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                            _WriteCell(fo, xmlEncode(fd["SaldoSum"]));
                    foreach (IDictionary fd in data.ProjectsAfterFinData)       //Остаток
                        if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                            _WriteCell(fo, xmlEncode(fd["SaldoSum"]));
                    foreach (IDictionary fd in data.ProjectsAllFinData)         //Итого
                        if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                            _WriteCell(fo, xmlEncode(fd["SaldoSum"]));
                    fo.TREnd();

                    // Сальдо нарастающим итогом
                    fo.TRStart();
                    _WriteCell(fo, "НИ");
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

        //Выводит заданное кол-во "пустых" ячеек показателей
        private void writeEmptyValueCell(XslFOProfileWriter fo, int j)
        {
            for (int i = 1; i <= j; i++ )
                _WriteCell(fo, "-");
        }

        // Выводит общие финансовые данные
        private void writeGenDataRow(XslFOProfileWriter fo, ArrayList al)
        {
            fo.TRStart();
            writeEmptyValueCell(fo, 2);
            foreach (IDictionary fd in al)
                _WriteCell(fo, xmlEncode(fd["Sum"].ToString()));
            writeEmptyValueCell(fo, 3);
            fo.TREnd();
        }

        // Выводит итоговые финансовые данные по проектам
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

        // Выводит приходы и расходы по займам и интервалам
        private void writeLoansIncOutDataRow(XslFOProfileWriter fo, ThisReportData data, int iType, ReportParams Params)
        {
            string sCol = "OutSum";
            fo.TRStart();
            if (iType == 0)
            {
                sCol = "IncSum";
                _WriteCell(fo, "П");
            }
            else
                _WriteCell(fo, "Р");

            //На начало периода
            writeEmptyValueCell(fo, 1);

            //Расходы - приходы
            foreach (IDictionary fd in data.LoansSumFinData)

                //Если есть расходы или приходы, то формируем ссылку на отчет с детализацией
                if ((String)fd[sCol] != "0.00")
                {
                    StringBuilder sbDetailRef = new StringBuilder();
                    _StartReportURL(sbDetailRef, "r-LoansIncOut");
                    _AppendParamURL(sbDetailRef, "Type", iType);
                    _AppendParamURL(sbDetailRef, "PrjGroup", (Guid)Params.GetParam("Group").Value);
                    _AppendParamURL(sbDetailRef, "DateIntervalID", (Guid)fd["DateIntervalID"]);
                    _AppendParamURL(sbDetailRef, "IsSeparate", Params.GetParam("IsSeparate").Value);
                    _AppendParamURL(sbDetailRef, "Sum", fd[sCol].ToString());
                    _EndReportURL(sbDetailRef, "Детализация", fd[sCol]);
                    _WriteCell(fo, sbDetailRef.ToString());
                }
                else
                    _WriteCell(fo, xmlEncode(fd[sCol]));

            //
            writeEmptyValueCell(fo, 3);
            fo.TREnd();
        }

        // Выводит приходы и расходы по проектам и интервалам
        private void writeProjectsIncOutDataRow(XslFOProfileWriter fo, ThisReportData data, IDictionary Project, int iType, ReportParams Params)
        {
            string sCol = "OutSum";
            fo.TRStart();
            if (iType == 0)
            {
                sCol = "IncSum";
                _WriteCell(fo, "П");
            }
            else
                _WriteCell(fo, "Р");

            //На начало периода
            foreach (IDictionary fd in data.ProjectsPreFinData)
                if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                    _WriteCell(fo, xmlEncode(fd[sCol]));

            //Расходы
            foreach (IDictionary fd in data.ProjectsFinData)
                if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])

                    //Если есть расходы или приходы, то формируем ссылку на отчет с детализацией
                    if ((String)fd[sCol] != "0.00")
                    {
                        StringBuilder sbDetailRef = new StringBuilder();
                        _StartReportURL(sbDetailRef, "r-ProjectIncOut");
                        _AppendParamURL(sbDetailRef, "Type", iType);            
                        _AppendParamURL(sbDetailRef, "InContract", (Guid)fd["ObjectID"]);
                        _AppendParamURL(sbDetailRef, "DateIntervalID", (Guid)fd["DateIntervalID"]);
                        _AppendParamURL(sbDetailRef, "IsSeparate", Params.GetParam("IsSeparate").Value);
                        _AppendParamURL(sbDetailRef, "Sum", fd[sCol].ToString());
                        _EndReportURL(sbDetailRef, "Детализация", fd[sCol]);
                        _WriteCell(fo, sbDetailRef.ToString());
                    }
                    else
                        _WriteCell(fo, xmlEncode(fd[sCol]));

            //Итого расходов
            foreach (IDictionary fd in data.ProjectsSumFinData)
                if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                    _WriteCell(fo, xmlEncode(fd[sCol]));

            //Остаток
            foreach (IDictionary fd in data.ProjectsAfterFinData)
                if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                    _WriteCell(fo, xmlEncode(fd[sCol]));
            
            //Всего
            foreach (IDictionary fd in data.ProjectsAllFinData)
                if ((Guid)Project["ObjectID"] == (Guid)fd["ObjectID"])
                    _WriteCell(fo, xmlEncode(fd[sCol]));
            fo.TREnd();
        }
    }
}