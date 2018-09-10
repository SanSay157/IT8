//Отчет "Сальдо ДС по сотрудникам"
using System;
using System.Collections;
using System.Data;
using System.Text;
using System.Collections.Specialized;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Types;
using Croc.IncidentTracker.Utility;
using Croc.XmlFramework.ReportService.Layouts;

namespace Croc.IncidentTracker.ReportService.Reports
{
    /// <summary>
    /// Фин-план проекта
    /// </summary>
    public class r_ProjectBDDS : ProjectFinanceReport
    {
        // Параметризированный конструктор. Вызывается подсистемой ReportService
        public r_ProjectBDDS(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        {   }

        /// <summary>
        /// Определяет строим ли мы отчет с привязкой к статьям бюджета или контрагентам
        /// </summary>
        private bool bIsBudgetBindedReport = false;

        /// <summary>
        /// Расчитывает фин показателей проекта
        /// Реализует базовый метод
        /// </summary>
        protected override void CalcProjectFinanceData()
        {
            int i = 0;
            //Расчитаем сальдо за каждый период
            foreach (IDictionary interval in FinanceData.DateIntervals)
            {
                HybridDictionary totalIncome = (HybridDictionary)FinanceData.Incomes[i];
                HybridDictionary totalOutcome = (HybridDictionary)FinanceData.IntervalOutcomes[i];

                //double dIncSum, dOutSum = 0;
                FinanceData.IncomeSum += Utils.ParseDBString(totalIncome["IncomeSum"].ToString());
                FinanceData.OutcomeSum += Utils.ParseDBString(totalOutcome["PaymentSum"].ToString());

                Double dSaldo = Utils.ParseDBString(totalIncome["IncomeSum"].ToString()) - Utils.ParseDBString(totalOutcome["PaymentSum"].ToString());
                FinanceData.IntervalSaldo[interval["ObjectID"]] = dSaldo;
                i++;
            }

            //Расчитаем суммы платежей по каждой статье бюджета за отчетный период. Столбец "Итого"
            foreach (IDictionary Outcome in FinanceData.Outcomes)
                if (bIsBudgetBindedReport)
                    FinanceData.BudgetOutOutcomeSum[Outcome["BudgetOutID"]] = (double)FinanceData.BudgetOutOutcomeSum[Outcome["BudgetOutID"]] + Utils.ParseDBString(Outcome["PaymentSum"].ToString());
                else
                {
                    if (!FinanceData.SupplierOutcomeSum.Contains(Outcome["SupplierID"]))
                        FinanceData.SupplierOutcomeSum.Add(Outcome["SupplierID"], new double());
                    FinanceData.SupplierOutcomeSum[Outcome["SupplierID"]] = (double)FinanceData.SupplierOutcomeSum[Outcome["SupplierID"]] + Utils.ParseDBString(Outcome["PaymentSum"].ToString());
                }

            //Также расчитаем суммарное сальдо за весь отчетный период
            FinanceData.TotalSaldo = FinanceData.IncomeSum - FinanceData.OutcomeSum;

            if (bIsBudgetBindedReport)
            {
                //Расчитаем общую сумму буджетных расходов
                foreach (IDictionary budgetOut in FinanceData.Budget)
                    FinanceData.BudgetOutSum += Utils.ParseDBString(budgetOut["BudgetOutSum"].ToString());

                //Расчитаем данные на конец отчетного периода - столбец "Всего"
                foreach (IDictionary outcomeBefore in FinanceData.OutcomesBefore)
                    FinanceData.OutcomesAfter[outcomeBefore["BudgetOutID"]] = (double)FinanceData.BudgetOutOutcomeSum[outcomeBefore["BudgetOutID"]] + Utils.ParseDBString(outcomeBefore["PaymentSum"].ToString());

                //Расчитаем остаток по бюджетным статьям с учетом отчетного периода - столбец "Остаток"
                foreach (IDictionary budget in FinanceData.Budget)
                    FinanceData.BudgetBalance[budget["BudgetOutID"]] = Utils.ParseDBString(budget["BudgetOutSum"].ToString()) - (double)FinanceData.OutcomesAfter[budget["BudgetOutID"]];
            }
            else
            {
                //Расчитаем данные на конец отчетного периода - столбец "Всего"
                foreach (IDictionary outcomeBefore in FinanceData.OutcomesBefore)
                {
                    if (!FinanceData.OutcomesAfter.Contains(outcomeBefore["SupplierID"]))
                        FinanceData.OutcomesAfter.Add(outcomeBefore["SupplierID"], new double());
                    FinanceData.OutcomesAfter[outcomeBefore["SupplierID"]] = (double)FinanceData.SupplierOutcomeSum[outcomeBefore["SupplierID"]] + Utils.ParseDBString(outcomeBefore["PaymentSum"].ToString());
                }
            }


        }

        /// <summary>
        /// Инициализация финансовых данных по проекту из БД
        /// </summary>
        /// <param name="reportData">Параметры отчета</param>
        protected override void InitializeFinanceData(ReportLayoutData reportData)
        {
 
            FinanceData = new ProjectFinanceData();

            //определяем необходимость привязки к статьям бюджета
            bIsBudgetBindedReport = (int)reportData.Params.GetParam("IsBudgetBinded").Value == 1;

            //Данные контракта
            using (IDataReader reader = reportData.DataProvider.GetDataReader("ContractInfoDS", reportData.CustomData))
            {
                if (reader.Read())
                    FinanceData.Contract = (HybridDictionary)_GetDataFromDataRow(reader);
                if(null != FinanceData.Contract)
                    FinanceData.ContractSum = Utils.ParseDBString(FinanceData.Contract["ContractSum"].ToString());
            }

            //Данные по временному масштабу
            using (IDataReader reader = reportData.DataProvider.GetDataReader("IntervalSaldoDS", reportData.CustomData))
            {
                if (reader.Read())
                    FinanceData.DateRatio = (HybridDictionary)_GetDataFromDataRow(reader);
            }

            //Данные по интервалам
            using (IDataReader reader = reportData.DataProvider.GetDataReader("DateRatioIntervalsDS", reportData.CustomData))
            {
                FinanceData.DateIntervals = _GetDataAsArrayList(reader);

                //Сразу инициализируем массив "Сальдо по временным интервалам"
                if (null != FinanceData.DateIntervals)
                    foreach (IDictionary interval in FinanceData.DateIntervals)
                        if (true != FinanceData.IntervalSaldo?.Contains(interval["ObjectID"]))
                            FinanceData.IntervalSaldo?.Add(interval["ObjectID"], new double());
            }

            //Бюджет проекта
            if(bIsBudgetBindedReport)
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectBudgetForBDDSReportDS", reportData.CustomData))
                {
                    FinanceData.Budget = _GetDataAsArrayList(reader);
                    //Сразу инициализируем массив 
                    if (null != FinanceData.Budget)
                        foreach (IDictionary BudgetOut in FinanceData.Budget)
                        {
                            if (!FinanceData.BudgetOutOutcomeSum.Contains(BudgetOut["BudgetOutID"]))
                                FinanceData.BudgetOutOutcomeSum.Add(BudgetOut["BudgetOutID"], new double());
                            if (!FinanceData.BudgetBalance.Contains(BudgetOut["BudgetOutID"]))
                                FinanceData.BudgetBalance.Add(BudgetOut["BudgetOutID"], new double());
                        }

                }
            //Данные по приходам проекта
            using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectIncomesForBDDSReportDS", reportData.CustomData))
            {
                FinanceData.Incomes = _GetDataAsArrayList(reader);
            }
            //Данные по расходам проекта
            //В зависимости от необходимости привязки к бюджету или контрагентам используем соответствующий источник данных
            if (bIsBudgetBindedReport)
            {
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectBudgetBindedOutcomesForBDDSReportDS", reportData.CustomData))
                {
                    FinanceData.Outcomes = _GetDataAsArrayList(reader);
                }
                //Расходы на начало периода
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectBudgetBindedOutcomesBeforeForBDDSReportDS", reportData.CustomData))
                {
                    FinanceData.OutcomesBefore = _GetDataAsArrayList(reader);
                    //Сразу инициализируем массив 
                    if (null != FinanceData.Budget)
                        foreach (IDictionary BudgetOut in FinanceData.Budget)
                            if (!FinanceData.OutcomesAfter.Contains(BudgetOut["BudgetOutID"]))
                                FinanceData.OutcomesAfter.Add(BudgetOut["BudgetOutID"], new double());
                }
                //Суммарные расходы по каждому временному интервалу
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectTotalBudgetBindedOutcomesForBDDSReportDS", reportData.CustomData))
                {
                    FinanceData.IntervalOutcomes = _GetDataAsArrayList(reader);
                }
            }
            else
            {
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectSupplierBindedOutcomesForBDDSReportDS", reportData.CustomData))
                {
                    FinanceData.Outcomes = _GetDataAsArrayList(reader);
                }
                //Расходы на начало периода
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectSupplierBindedOutcomesBeforeForBDDSReportDS", reportData.CustomData))
                {
                    FinanceData.OutcomesBefore = _GetDataAsArrayList(reader);
                }
                //Суммарные расходы по каждому временному интервалу
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectTotalSupplierBindedOutcomesForBDDSReportDS", reportData.CustomData))
                {
                    FinanceData.IntervalOutcomes = _GetDataAsArrayList(reader);
                }
            }

        }

        // Метод, формирующий отчет; вызывается подсистемой ReportService
        protected override void buildReport(ReportLayoutData reportData)
        {
            //Инициализируем фин. данные по проекту из БД
            InitializeFinanceData(reportData);
            
            //Расчитаем остальные фин показатели
            CalcProjectFinanceData();
            
            //Непосредственно построение отчета
            reportData.RepGen.WriteLayoutMaster();
            reportData.RepGen.StartPageSequence();
            reportData.RepGen.StartPageBody();

            reportData.RepGen.Header(xmlEncode("Финансовый план по проекту (БДДС)"));

            //Формируем и выводим подзаголовок
            StringBuilder sbBlock = new StringBuilder();
            sbBlock.Append(_GetParamValueAsFoBlock("Контракт", FinanceData.Contract["Name"].ToString()));
            sbBlock.Append(_GetParamValueAsFoBlock("Сумма контракта", _FormatMoney(FinanceData.ContractSum)));
            reportData.RepGen.AddSubHeader(_MakeSubHeader(sbBlock));

           

            //Отрисовка основного тела отчета
            if (bIsBudgetBindedReport)
                writeBudgetBindedReport(reportData.RepGen);
            else
                writeSupplierBindedReport(reportData.RepGen);

            reportData.RepGen.EndPageBody();
            reportData.RepGen.EndPageSequence();

            //Освободим ресурсы
            FinanceData.Dispose();
        }

        /// <summary>
        /// Построение отчета с привязкой к контрагентам
        /// </summary>
        /// <param name="fo"></param>
        private void writeSupplierBindedReport(XslFOProfileWriter fo)
        {
            _TableSeparator(fo);

            fo.TStart(true, ITRepStyles.TABLE, false);
            #region Шапка отчета

            fo.TAddColumn("Контрагент", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_CELL_BOLD, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("На начало периода", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "2%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            //Общее фиксированное количество колонок в таблице отчета
            int i = 4;

            //Заголовки колонок. Формируются соответственно временного масштаба выбранного пользователем
            foreach (IDictionary Interval in FinanceData.DateIntervals)
            {
                fo.TAddColumn(xmlEncode(Interval["Name"].ToString()), align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                i++;
            }

            fo.TAddColumn("Итого", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("На конец периода", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
           
            int nRowCount = i++;

            #endregion

            fo.TRStart();
            fo.TRAddCell("ВСЕГО ПО ПРОЕКТУ", "string", nRowCount + 1, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();

            //Итого Сальдо по временному интервалу
            writeIntervalSaldoDataRow(fo, 1, "Сальдо");

            //Итого приходы по проекту
            writeTotalIncomeDataRow(fo, 1, "Приход");

            //Итого расходы по проекту
            writeTotalOutcomeDataRow(fo, 1, "Расход");

            //TODO: Добавить Итого, Остаток, Всего




            if (bIsBudgetBindedReport)
            {
                fo.TRStart();
                fo.TRAddCell("ПО КАЖДОЙ СТАТЬЕ БЮДЖЕТА", "string", nRowCount + 1, 1, ITRepStyles.GROUP_HEADER);
                fo.TREnd();
                //Платежи по каждой статье бюджета в разрезе временной шкалы
                writeProjectBudgetBindedOutcomesData(fo);
            }
            else
            {
                fo.TRStart();
                fo.TRAddCell("ПО КАЖДОМУ КОНТРАГЕНТУ", "string", nRowCount + 1, 1, ITRepStyles.GROUP_HEADER);
                fo.TREnd();
                writeProjectSupplierBindedOutcomesData(fo);
            }
            fo.TEnd();
        }

        /// <summary>
        /// Построение отчета с привязкой к бюджету
        /// </summary>
        /// <param name="fo"></param>
        private void writeBudgetBindedReport(XslFOProfileWriter fo)
        {
            _TableSeparator(fo);

            fo.TStart(true, ITRepStyles.TABLE, false);
            #region Шапка отчета

            fo.TAddColumn("Контрагент", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_CELL_BOLD, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Статья бюджета", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "3%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Сумма в бюджете", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_CELL_BOLD, "2%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("На начало периода", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "2%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            //Общее количество колонок в таблице отчета
            int i = 6;

            //Заголовки колонок
            foreach (IDictionary Interval in FinanceData.DateIntervals)
            {
                fo.TAddColumn(xmlEncode(Interval["Name"].ToString()), align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                i++;
            }
            fo.TAddColumn("Итого", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("На конец периода", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "4%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Остаток", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "5%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            int nRowCount = i++;
            
            #endregion 
            
            fo.TRStart();
            fo.TRAddCell("ВСЕГО ПО ПРОЕКТУ", "string", nRowCount+1, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();

            //Итого Сальдо по временному интервалу
            writeIntervalSaldoDataRow(fo, 2, "Сальдо");

            //Итого приходы по проекту
            writeTotalIncomeDataRow(fo,2, "Приход");

            //Итого расходы по проекту
            writeTotalOutcomeDataRow(fo,2, "Расход");

            //TODO: Добавить Итого, Остаток, Всего

            

            fo.TRStart();
            fo.TRAddCell("ПО КАЖДОЙ СТАТЬЕ БЮДЖЕТА", "string", nRowCount + 1, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();

            //Платежи по каждой статье бюджета в разрезе временной шкалы
            writeProjectBudgetBindedOutcomesData(fo);
            
            fo.TEnd();

        }
        //Выводит заданное кол-во "пустых" ячеек показателей
        private void writeEmptyValueCell(XslFOProfileWriter fo, int j)
        {
            for (int i = 1; i <= j; i++)
                _WriteCell(fo, "","string", ITRepStyles.TABLE_CELL_ND, false);
        }

        // Выводит сальдо по проекту в разрезе временной шкалы
        private void writeIntervalSaldoDataRow(XslFOProfileWriter fo, int nColSpan, string sLabel)
        {
            if (null == FinanceData)
                throw new Exception("Не инициализированы финансовые показатели по проекту");
            fo.TRStart(ITRepStyles.TABLE_CELL_COLOR_YELLOW);
            fo.TRAddCell(sLabel, "string", nColSpan, 1);

            if(bIsBudgetBindedReport)
                //Планируемая валовая прибыль (Сальдо по бюджету)
                _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData.ContractSum - FinanceData.BudgetOutSum)));

            writeEmptyValueCell(fo, 1);

            foreach (IDictionary interval in FinanceData?.DateIntervals)
                _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData?.IntervalSaldo[interval["ObjectID"]])));

            _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData.IncomeSum - FinanceData.OutcomeSum)));

            writeEmptyValueCell(fo, nColSpan);
            fo.TREnd();
        }
        // Выводит суммарный приход по проекту в разрезе временной шкалы
        private void writeTotalIncomeDataRow(XslFOProfileWriter fo, int nColSpan,  string sLabel)
        {
            if (null == FinanceData)
                throw new Exception("Не инициализированы финансовые показатели по проекту");

            fo.TRStart(ITRepStyles.TABLE_CELL_COLOR_GREEN);
            fo.TRAddCell(sLabel, "string", nColSpan, 1);

            if(bIsBudgetBindedReport)
                //Общий планируемый приход равен сумме контракта
                _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData.ContractSum)));

            writeEmptyValueCell(fo, 1);
            foreach (IDictionary income in FinanceData?.Incomes)
                _WriteCell(fo, xmlEncode(_FormatMoney(income["IncomeSum"])));

            _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData.IncomeSum)));
            if (bIsBudgetBindedReport)
                _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData.ContractSum - FinanceData.IncomeSum)));

            writeEmptyValueCell(fo, 1);

            fo.TREnd();
            
        }

        // Выводит суммарные расходы по проекту в разрезе временной шкалы
        private void writeTotalOutcomeDataRow(XslFOProfileWriter fo, int nColSpan, string sLabel)
        {
            if (null == FinanceData)
                throw new Exception("Не инициализированы финансовые показатели по проекту");

            fo.TRStart(ITRepStyles.TABLE_CELL_COLOR_ORANGE);
            fo.TRAddCell(sLabel, "string", nColSpan, 1);
            if(bIsBudgetBindedReport)
                _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData.BudgetOutSum.ToString())));

            writeEmptyValueCell(fo, 1);

            foreach (IDictionary totalOutcome in FinanceData?.IntervalOutcomes)
                _WriteCell(fo, xmlEncode(_FormatMoney(totalOutcome["PaymentSum"])));

            _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData.OutcomeSum)));

            if (bIsBudgetBindedReport)
                _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData.BudgetOutSum - FinanceData.OutcomeSum)));
            writeEmptyValueCell(fo, 1);
            fo.TREnd();
            
        }


        /// <summary>
        /// Выводит расходы по проекту в разрезе временной шкалы по каждому контрагенту
        /// </summary>
        private void writeProjectSupplierBindedOutcomesData(XslFOProfileWriter fo)
        {
            if (null == FinanceData)
                throw new ApplicationException("Не инициализированы финансовые показатели по проекту");

            object oCurrentSupplierID = null;

            foreach (IDictionary Outcome in FinanceData?.Outcomes)
            {
                // Проверяем перешли ли к следующему контрагенту, если да, выводим данные о нем
                if (!Outcome["SupplierID"].Equals(oCurrentSupplierID))
                {
                    //Если не первая строка, закроем предыдущую
                    if (null != oCurrentSupplierID)
                    {
                        //выведем столбцы "Итого","Всего","Остаток"
                        _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData?.SupplierOutcomeSum[oCurrentSupplierID])), "string", ITRepStyles.TABLE_CELL_BOLD);
                        _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData?.OutcomesAfter[oCurrentSupplierID])), "string", ITRepStyles.TABLE_CELL_BOLD);
                        fo.TREnd();
                    }
                    fo.TRStart();

                    //Наименование контрагента
                    _WriteCell(fo, xmlEncode(Outcome["OrgName"]), "string", ITRepStyles.TABLE_CELL_BOLD);

                    oCurrentSupplierID = Outcome["SupplierID"];

                    //Выведем показатели на начало периода
                    if (null != FinanceData.OutcomesBefore)
                        foreach (IDictionary outcomeBefore in FinanceData?.OutcomesBefore)
                        {
                            if (outcomeBefore["SupplierID"].Equals(oCurrentSupplierID))
                                _WriteCell(fo, xmlEncode(_FormatMoney(outcomeBefore["PaymentSum"])));
                        }
                    else
                        writeEmptyValueCell(fo, 1);


                }
                //непосредственно сам фин показатель по текущему временному интервалу
                _WriteCell(fo, xmlEncode(_FormatMoney(Outcome["PaymentSum"].ToString())));
            }
            //Закроем последнюю строку
            //выведем столбцы "Итого","Всего","Остаток"
            _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData?.SupplierOutcomeSum[oCurrentSupplierID])), "string", ITRepStyles.TABLE_CELL_BOLD);
            _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData?.OutcomesAfter[oCurrentSupplierID])), "string", ITRepStyles.TABLE_CELL_BOLD);
            fo.TREnd();

        }

        /// <summary>
        /// Выводит расходы по проекту в разрезе временной шкалы по каждой статье бюджета
        /// </summary>
        private void writeProjectBudgetBindedOutcomesData(XslFOProfileWriter fo)
        {
            if (null == FinanceData)
                throw new ApplicationException("Не инициализированы финансовые показатели по проекту");

            object oCurrentBudgetOutID = null;

            foreach (IDictionary Outcome in FinanceData?.Outcomes)
            {
                // Проверяем перешли ли к следующей бюджетной строке, если да, выводим данные о ней
                if (!Outcome["BudgetOutID"].Equals(oCurrentBudgetOutID))
                {
                    //Если не первая строка, закроем предыдущую
                    if (null != oCurrentBudgetOutID)
                    {
                        //выведем столбцы "Итого","Всего","Остаток"
                        _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData?.BudgetOutOutcomeSum[oCurrentBudgetOutID])), "string", ITRepStyles.TABLE_CELL_BOLD);
                        _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData?.OutcomesAfter[oCurrentBudgetOutID])), "string", ITRepStyles.TABLE_CELL_BOLD);
                        _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData?.BudgetBalance[oCurrentBudgetOutID])), "string", ITRepStyles.TABLE_CELL_BOLD); 
                        fo.TREnd();
                    }
                    fo.TRStart();
                    
                    //Если указан контрагент, то выводим сначала его наименование потом название строки бюджета
                    if (null != Outcome["BudgetOutOrg"])
                    {
                        _WriteCell(fo, xmlEncode(Outcome["BudgetOutOrg"]), "string", ITRepStyles.TABLE_CELL_BOLD);
                        _WriteCell(fo, xmlEncode(Outcome["BudgetOutName"]));

                    }
                    //Иначе сначало выводим название строки бюджета
                    else
                    {
                        _WriteCell(fo, xmlEncode(Outcome["BudgetOutName"]), "string", ITRepStyles.TABLE_CELL_BOLD);
                        writeEmptyValueCell(fo, 1);
                    }
                    _WriteCell(fo, xmlEncode(_FormatMoney(Outcome["BudgetOutSum"])));
                    oCurrentBudgetOutID = Outcome["BudgetOutID"];

                    //Выведем показатели на начало периода
                    if(null != FinanceData.OutcomesBefore)
                        foreach (IDictionary outcomeBefore in FinanceData?.OutcomesBefore)
                        {
                            if (outcomeBefore["BudgetOutID"].Equals(oCurrentBudgetOutID))
                                _WriteCell(fo, xmlEncode(_FormatMoney(outcomeBefore["PaymentSum"])));
                        }
                    else
                        writeEmptyValueCell(fo, 1);


                }
                //непосредственно сам фин показатель по текущему временному интервалу
                _WriteCell(fo, xmlEncode(_FormatMoney(Outcome["PaymentSum"].ToString())));
            }
            //Закроем последнюю строку
            //выведем столбцы "Итого","Всего","Остаток"
            _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData?.BudgetOutOutcomeSum[oCurrentBudgetOutID])), "string", ITRepStyles.TABLE_CELL_BOLD);
            _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData?.OutcomesAfter[oCurrentBudgetOutID])), "string", ITRepStyles.TABLE_CELL_BOLD);
            _WriteCell(fo, xmlEncode(_FormatMoney(FinanceData?.BudgetBalance[oCurrentBudgetOutID])), "string", ITRepStyles.TABLE_CELL_BOLD);
            fo.TREnd();
            
        }

        // Выводит итоговые финансовые данные по проектам
        private void writeProjectIncomeDataRow(XslFOProfileWriter fo, string sLabel)
        {
            fo.TRStart();
            _WriteCell(fo, sLabel);
            foreach (IDictionary income in FinanceData?.Incomes)
                _WriteCell(fo, xmlEncode(income["IncomeSum"]));
            fo.TREnd();
        }
    }
}