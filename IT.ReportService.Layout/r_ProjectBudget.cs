//Отчет "Сальдо ДС по сотрудникам"
using System;
using System.Collections;
using System.Data;
using System.Text;
using System.Globalization;
using System.IO;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Types;
using Croc.IncidentTracker.Utility;

namespace Croc.IncidentTracker.ReportService.Reports
{
    /// <summary>
    /// Бюджет Доходов и Расходов Проекта
    /// </summary>
    public class r_ProjectBudget : CustomITrackerReport
    {
        // Параметризированный конструктор. Вызывается подсистемой ReportService
        public r_ProjectBudget(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        { }
        internal class ThisReportData
        {
            public IDictionary Contract = null;
            public ArrayList OutLimits, ExtOutLimits, AOLimits, ExtAOLimits, Incomes, Outcomes = null;

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
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectBudgetForBDRReportDS", reportData.CustomData))
                {
                    Outcomes = _GetDataAsArrayList(reader);
                }

                //Данные по лимитированным расходам проекта
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectOutLimitForBDRReportDS", reportData.CustomData))
                {
                    OutLimits = _GetDataAsArrayList(reader);
                }

                //Данные по "расширенным" лимитированным расходам проекта
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectOutLimitExtForBDRReportDS", reportData.CustomData))
                {
                    ExtOutLimits = _GetDataAsArrayList(reader);
                }

                //Данные по  "расширенным" лимитам АО проекта
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectAOLimitExtForBDRReportDS", reportData.CustomData))
                {
                    ExtAOLimits = _GetDataAsArrayList(reader);
                }
                //Данные по  лимитам АО проекта
                using (IDataReader reader = reportData.DataProvider.GetDataReader("ProjectAOLimitForBDRReportDS", reportData.CustomData))
                {
                    AOLimits = _GetDataAsArrayList(reader);
                }
            }
        }

        //Переопределяем базовый метод, чтобы убрать в пустых ячейках надпись "(нет данных)"
        private string xmlEncode(object s=null)
        {
            return CustomReport.xmlEncode(s==null?"  ":s); 
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
            
            //В зависимости от параметра "расширенный" строим соответствующий отчет
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

        /// <summary>
        /// Построение стандартного отчета
        /// </summary>
        /// <param name="fo">xml-пул данных отчета</param>
        /// <param name="data">параметры отчета</param>
        private void writeCommonReport(XslFOProfileWriter fo, ThisReportData data)
        {
            // Определим локализацию для парсинга данных из БД
            CultureInfo culture = new CultureInfo("ru-RU");

            _TableSeparator(fo);

            // Шапка отчета
            fo.TStart(true, ITRepStyles.TABLE, false);
            fo.TAddColumn("Статья расходов", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "45%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Назначение/Контрагент", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "35%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Примечание", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Сумма с НДС", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);

            double fOutcomesSum = 0, fAOLimitSum = 0, fIncomeSum = 0;


            //Построение блока отчета по приходам

            if (data.Incomes != null)
            {
                IDictionary arIO = (IDictionary)data.Incomes[0];

                
                fIncomeSum = Utils.ParseDBString(arIO["Sum"].ToString());

                fo.TRStart();
                fo.TRAddCell(xmlEncode(arIO["Type"]), "string", 3, 1, ITRepStyles.GROUP_HEADER);
                fo.TRAddCell(xmlEncode(fIncomeSum.ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                fo.TREnd();
            };

            // Построение блока отчета по прямым расходам
            if (data.Outcomes != null)
            {
                foreach (IDictionary IO in data.Outcomes)
                {

                    fOutcomesSum += Utils.ParseDBString(IO["BudgetCost"].ToString());
                }
                // Выводим итоговую сумму прямых расходов
                fo.TRStart();
                fo.TRAddCell(xmlEncode("Прямые расходы"), "string", 3, 1, ITRepStyles.GROUP_HEADER);
                fo.TRAddCell(xmlEncode(fOutcomesSum.ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                fo.TREnd();
                // Показываем все расходы по-пунктно
                foreach (IDictionary IO in data.Outcomes)
                {
                        fo.TRStart();
                        _WriteCell(fo, xmlEncode(IO["BudgetItem"]));
                        _WriteCell(fo, xmlEncode(IO["ContractCompany"]));
                        _WriteCell(fo, xmlEncode(IO["Rem"]));
                        _WriteCell(fo, xmlEncode(Utils.ParseDBString(IO["BudgetCost"].ToString()).ToString("C2", culture)));
                        fo.TREnd();
                }
            }

            // Выводим лимитированные расходы по проекту.
            // На текущий момент определились в бухгалтерской 
            // форме показывать только Командировочные
            if (data.AOLimits != null)
            {
                foreach (IDictionary IO in data.AOLimits)
                {
                    // считаем сумму всех АО лимитов
                    fAOLimitSum += Utils.ParseDBString(IO["AOLimitSum"].ToString());
                }

                
            }
            if (data.OutLimits != null)
            {
                foreach (IDictionary IO in data.OutLimits)
                {
                    // считаем сумму всех лимитов
                    fAOLimitSum += Utils.ParseDBString(IO["OutLimitSum"].ToString());
                }
            }

            if (data.AOLimits != null || data.OutLimits != null)
            {
                fo.TRStart();
                fo.TRAddCell(xmlEncode("Лимитированные расходы"), "string", 3, 1, ITRepStyles.GROUP_HEADER);
                fo.TRAddCell(xmlEncode(fAOLimitSum.ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                fo.TREnd();
            }
            if (data.AOLimits != null)
            {
                foreach (IDictionary IO in data.AOLimits)
                {

                    fo.TRStart();
                    _WriteCell(fo, xmlEncode(IO["AOLimitName"]));
                    _WriteCell(fo, xmlEncode());
                    _WriteCell(fo, xmlEncode(IO["AOLimitRem"]));
                    _WriteCell(fo, xmlEncode(Utils.ParseDBString(IO["AOLimitSum"].ToString()).ToString("C2", culture)));
                    fo.TREnd();
                }
            }
            if (data.OutLimits != null)
            {
                foreach (IDictionary IO in data.OutLimits)
                {

                    fo.TRStart();
                    _WriteCell(fo, xmlEncode(IO["OutLimitName"]));
                    _WriteCell(fo, xmlEncode());
                    _WriteCell(fo, xmlEncode(IO["OutLimitRem"]));
                    _WriteCell(fo, xmlEncode(Utils.ParseDBString(IO["OutLimitSum"].ToString()).ToString("C2", culture)));
                    fo.TREnd();
                }
            }
            fo.TRStart();
            fo.TRAddCell(xmlEncode("ИТОГО Расходы"), "string", 3, 1, ITRepStyles.GROUP_HEADER);
            fo.TRAddCell(xmlEncode((fAOLimitSum + fOutcomesSum).ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();

            fo.TRStart();
            fo.TRAddCell(xmlEncode("Валовая прибыль"), "string", 3, 1, ITRepStyles.GROUP_HEADER);
            fo.TRAddCell(xmlEncode((fIncomeSum - (fAOLimitSum + fOutcomesSum)).ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();
            
            double fAllOutcomse = fAOLimitSum + fOutcomesSum;

            fo.TRStart();
            fo.TRAddCell(xmlEncode("Плановая рентабельность"), "string", 3, 1, ITRepStyles.GROUP_HEADER);
            if (fAllOutcomse != 0)
            {
                fo.TRAddCell(xmlEncode(((fIncomeSum - fAllOutcomse) * 100 / fAllOutcomse).ToString("N2") + "%"), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            }
            else
            {
                fo.TRAddCell(xmlEncode(), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            }
            fo.TREnd();

            fo.TEnd();
        }

        private void writeExtendedReport(XslFOProfileWriter fo, ThisReportData data)
        {
            _TableSeparator(fo);
            CultureInfo culture = new CultureInfo("ru-RU");

            fo.TStart(true, ITRepStyles.TABLE, false);
            fo.TAddColumn("Статья расходов", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "45%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Назначение/Контрагент", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "25%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Примечание", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("с учетом комплектации", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
            fo.TAddColumn("Сумма с НДС", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "10%", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
           

            double fOutcomesSum = 0, fAOLimitSum = 0, fIncomeSum = 0;
            double fExtOutcomesSum = 0, fExtOutLimit = 0;
            
            // Построение блока отчета по приходам
            if (data.Incomes != null)
            {
                IDictionary arIO = (IDictionary)data.Incomes[0];
              


                fIncomeSum = Utils.ParseDBString(arIO["Sum"].ToString());

                fo.TRStart();
                fo.TRAddCell(xmlEncode(arIO["Type"]), "string", 3, 1, ITRepStyles.GROUP_HEADER);
                fo.TRAddCell(xmlEncode(fIncomeSum.ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                fo.TRAddCell(xmlEncode(fIncomeSum.ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                fo.TREnd();
            };


            // расчет блока отчета по прямым расходам
            if (data.Outcomes != null)
            {
                foreach (IDictionary IO in data.Outcomes)
                {
                    string sBugetCost = IO["BudgetCost"].ToString();

                    fOutcomesSum += Utils.ParseDBString(sBugetCost);
                        
                    if (IO["SupplierSum"] != null)
                    {
                        fExtOutcomesSum += Utils.ParseDBString(IO["SupplierSum"].ToString());
                        fExtOutcomesSum += Utils.ParseDBString(IO["SupplierFee"].ToString());
                    }
                    else
                        fExtOutcomesSum += Utils.ParseDBString(IO["BudgetCost"].ToString());
                }
            }

            fo.TRStart();
            fo.TRAddCell(xmlEncode("Прямые расходы"), "string", 3, 1, ITRepStyles.GROUP_HEADER);
            fo.TRAddCell(xmlEncode(fExtOutcomesSum.ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            fo.TRAddCell(xmlEncode(fOutcomesSum.ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();

            // построение блока отчета по прямым расходам
            if (data.Outcomes != null)
            {
                foreach (IDictionary IO in data.Outcomes)
                {

                    string sBudgetCost = IO["BudgetCost"].ToString();
                    double fBugetCost = Utils.ParseDBString(sBudgetCost);
                    if (IO["SupplierSum"] == null)
                    {
                        fo.TRStart();
                        _WriteCell(fo, xmlEncode(IO["BudgetItem"]));
                        _WriteCell(fo, xmlEncode(IO["ContractCompany"]));
                        _WriteCell(fo, xmlEncode(IO["Rem"]));
                        _WriteCell(fo, xmlEncode(Utils.ParseDBString(sBudgetCost).ToString("C2", culture)));
                        _WriteCell(fo, xmlEncode(Utils.ParseDBString(sBudgetCost).ToString("C2", culture)));
                        fo.TREnd();
                    }
                    else
                    {
                        double fSupplierSum = Utils.ParseDBString(IO["SupplierSum"].ToString());
                        fo.TRStart();
                        fo.TRAddCell(xmlEncode(IO["BudgetItem"]), "string", 1, 2, ITRepStyles.TABLE_CELL_BOLD);
                        _WriteCell(fo, xmlEncode(IO["SupplierCompany"]));
                        _WriteCell(fo, xmlEncode(IO["Rem"]));
                        _WriteCell(fo, xmlEncode(fSupplierSum.ToString("C2", culture)));
                        _WriteCell(fo, xmlEncode(fBugetCost.ToString("C2", culture)));
                        fo.TREnd();

                        fo.TRStart();
                        _WriteCell(fo, xmlEncode("Комиссия " + IO["ContractCompany"]));
                        _WriteCell(fo, xmlEncode(IO["Percent"] + "%"));
                        _WriteCell(fo, xmlEncode(Utils.ParseDBString(IO["SupplierFee"].ToString()).ToString("C2", culture)));
                        _WriteCell(fo, xmlEncode());
                        fo.TREnd();
                    }
                }
            }
        

            // Расчитываем лимитированные расходы по проекту.
            // На текущий момент определились в бухгалтерской 
            // форме показывать только Командировочные

            //АО Лимиты
            if (data.AOLimits != null )
            {
                foreach (IDictionary IO in data.AOLimits)
                {
                    // считаем сумму всех АО лимитов
                    fAOLimitSum += Utils.ParseDBString(IO["AOLimitSum"].ToString());
                }
            }
            
            //АО лимиты с учетом "комплектации"
            if (data.ExtAOLimits != null)
            {
                foreach (IDictionary IO in data.ExtAOLimits)
                {

                    // считаем сумму всех лимитов
                    fExtOutLimit += Utils.ParseDBString(IO["AOLimitSum"].ToString());
                }
            }

            //Лимитированные расходы 
            if (data.OutLimits != null)
            {
                foreach (IDictionary IO in data.OutLimits)
                {
                    // считаем сумму всех лимитов
                    fAOLimitSum += Utils.ParseDBString(IO["OutLimitSum"].ToString());
                }
            }

            //Лимитированные расходы с учетом "комплектации"
            if (data.ExtOutLimits != null)
            {
                foreach (IDictionary IO in data.ExtOutLimits)
                {
                    // считаем сумму всех лимитов
                    fExtOutLimit += Utils.ParseDBString(IO["OutLimitSum"].ToString());
                }
            }

            //Итоговая строка расходов
            if (data.AOLimits != null || data.ExtAOLimits != null || data.OutLimits != null || data.ExtOutLimits != null)
            {
                fo.TRStart();
                fo.TRAddCell(xmlEncode("Лимитированные расходы"), "string", 3, 1, ITRepStyles.GROUP_HEADER);
                fo.TRAddCell(xmlEncode(fExtOutLimit.ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                fo.TRAddCell(xmlEncode(fAOLimitSum.ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
                fo.TREnd();
            }

            //Выводим лимитированные расходы
            //Лимиты по АО
            if (data.AOLimits != null)
            {
                foreach (IDictionary IO in data.AOLimits)
                {

                    fo.TRStart();
                    _WriteCell(fo, xmlEncode(IO["AOLimitName"]));
                    _WriteCell(fo, xmlEncode());
                    _WriteCell(fo, xmlEncode(IO["AOLimitRem"]));
                    _WriteCell(fo, xmlEncode(Utils.ParseDBString(IO["AOLimitSum"].ToString()).ToString("C2", culture)));
                    _WriteCell(fo, xmlEncode(Utils.ParseDBString(IO["AOLimitSum"].ToString()).ToString("C2", culture)));
                    fo.TREnd();
                }
            }
            //Лимиты по АО с "расширенные"
            if (data.ExtAOLimits != null)
            {
                foreach (IDictionary IO in data.ExtAOLimits)
                {
                    fo.TRStart();
                    _WriteCell(fo, xmlEncode(IO["AOLimitName"]));
                    _WriteCell(fo, xmlEncode());
                    _WriteCell(fo, xmlEncode(IO["AOLimitRem"]));
                    _WriteCell(fo, xmlEncode(Utils.ParseDBString(IO["AOLimitSum"].ToString()).ToString("C2", culture)));
                    _WriteCell(fo, xmlEncode());
                    fo.TREnd();
                }
            }

            //Лимиты по расходам
            if (data.OutLimits != null)
            {
                foreach (IDictionary IO in data.OutLimits)
                {
                    fo.TRStart();
                    _WriteCell(fo, xmlEncode(IO["OutLimitName"]));
                    _WriteCell(fo, xmlEncode());
                    _WriteCell(fo, xmlEncode(IO["OutLimitRem"]));
                    _WriteCell(fo, xmlEncode(Utils.ParseDBString(IO["OutLimitSum"].ToString()).ToString("C2", culture)));
                    _WriteCell(fo, xmlEncode(Utils.ParseDBString(IO["OutLimitSum"].ToString()).ToString("C2", culture)));
                    fo.TREnd();
                }
            }

            //Лимиты по расходам
            if (data.ExtOutLimits != null)
            {
                foreach (IDictionary IO in data.ExtOutLimits)
                {
                    fo.TRStart();
                    _WriteCell(fo, xmlEncode(IO["OutLimitName"]));
                    _WriteCell(fo, xmlEncode());
                    _WriteCell(fo, xmlEncode(IO["OutLimitRem"]));
                    _WriteCell(fo, xmlEncode(Utils.ParseDBString(IO["OutLimitSum"].ToString()).ToString("C2", culture)));
                    _WriteCell(fo, xmlEncode());
                    fo.TREnd();
                }
            }

            fo.TRStart();
            fo.TRAddCell(xmlEncode("ИТОГО Расходы"), "string", 3, 1, ITRepStyles.GROUP_HEADER);
            fo.TRAddCell(xmlEncode((fExtOutcomesSum + fExtOutLimit).ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            fo.TRAddCell(xmlEncode((fAOLimitSum + fOutcomesSum).ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();

            fo.TRStart();
            fo.TRAddCell(xmlEncode("Валовая прибыль"), "string", 3, 1, ITRepStyles.GROUP_HEADER);
            fo.TRAddCell(xmlEncode((fIncomeSum - (fExtOutcomesSum + fExtOutLimit)).ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            fo.TRAddCell(xmlEncode((fIncomeSum - (fAOLimitSum + fOutcomesSum)).ToString("C2", culture)), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            fo.TREnd();

            double fAllOutcomse = fAOLimitSum + fOutcomesSum;
            double fExtAllOutcomse = fExtOutcomesSum + fExtOutLimit;

            fo.TRStart();
            fo.TRAddCell(xmlEncode("Плановая рентабельность"), "string", 3, 1, ITRepStyles.GROUP_HEADER);

            if (fExtAllOutcomse != 0)
            {
                fo.TRAddCell(xmlEncode(((fIncomeSum - fExtAllOutcomse) * 100 / fExtAllOutcomse).ToString("N2") + "%"), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            }
            else
            {
                fo.TRAddCell(xmlEncode(), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            }
            
            if (fAllOutcomse != 0)
            {
                fo.TRAddCell(xmlEncode(((fIncomeSum - fAllOutcomse) * 100 / fAllOutcomse).ToString("N2") + "%"), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            }
            else
            {
                fo.TRAddCell(xmlEncode(), "string", 1, 1, ITRepStyles.GROUP_HEADER);
            }
            
            
            fo.TREnd();

            fo.TEnd();

        }
    }
}