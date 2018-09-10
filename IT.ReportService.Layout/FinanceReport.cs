using System;
using System.Collections;
using System.Collections.Specialized;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using System.Globalization;
using Croc.IncidentTracker.Utility;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Reports
{
    /// <summary>
    /// Прототип финансового отчета
    /// </summary>
    public abstract class FinanceReport : CustomITrackerReport
    {
        public FinanceReport(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
		{}
        
        protected override abstract void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data);
    }

    /// <summary>
    /// Прототип данных финансовых отчетов
    /// ВАЖНО!!! Необходимо самостоятельно высвобождать ресурсы после построения отчета,
    /// поскольку сборщик мусора делает это только по заверщении работы приложения
    /// и при повторном построении отчета, данные искажаются.
    /// </summary>
    public abstract class FinanceData:IDisposable
    {


        /// <summary>
        /// Расходы по проекту в разрезе временной шкалы
        /// </summary>
        public ArrayList Outcomes { get; set; }

        /// <summary>
        /// Приходы по проекту в разрезе временной шкалы
        /// </summary>
        public ArrayList Incomes { get; set; }

        /// <summary>
        /// Сумма текущих плановых и фактических расходов по проекту
        /// </summary>
        public double OutcomeSum { get; set; }

        /// <summary>
        /// Сумма приходов по проекту с учетом фактических поступлений на текущий момент
        /// </summary>
        public double IncomeSum { get; set; }


        #region IDisposable Support
        private bool disposedValue = false;
        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    Incomes.Clear();
                    Outcomes.Clear();
                }

                // TODO: освободить неуправляемые ресурсы (неуправляемые объекты) и переопределить ниже метод завершения.
                Incomes = null;
                Outcomes = null;
                IncomeSum = 0;
                OutcomeSum = 0;

                disposedValue = true;
            }
        }

        // Этот код добавлен для правильной реализации шаблона высвобождаемого класса.
        public void Dispose()
        {
            Dispose(true);
        }
        #endregion

    }

    /// <summary>
    /// Прототип проектного финансового отчета
    /// </summary>
    public abstract class ProjectFinanceReport : FinanceReport
    {
        /// <summary>
        /// Финансовые данные и показатели по проекту (расходы, приходы, бюджетные статьи, сальдо и пр.)
        /// </summary>
        protected ProjectFinanceData FinanceData;

        public ProjectFinanceReport(reportClass ReportProfile, string ReportName)
            : base(ReportProfile, ReportName)
        { }
        protected override abstract void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data);

        /// <summary>
        /// Инициализирует финансовые данные по проекту из БД
        /// </summary>
        /// <param name="data">Параметры отчета</param>
        protected abstract void InitializeFinanceData(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data);
        
        /// <summary>
        /// Расчитывает фин показатели проекта
        /// Должен быть переопределен в каждом конкретном отчете
        /// </summary>
        protected abstract void CalcProjectFinanceData();


    }

    /// <summary>
    /// Финнансовые данные по проекту
    /// </summary>
    public class ProjectFinanceData : FinanceData
    {
        #region входные данные
        /// <summary>
        /// Статьи бюджета проекта
        /// </summary>
        public ArrayList Budget { get; set; }
        /// <summary>
        /// Итого расходы по каждому временному интервалу
        /// </summary>
        public ArrayList IntervalOutcomes { get; set; }
        /// <summary>
        /// Временной масштаб отчета
        /// </summary>
        public HybridDictionary DateRatio { get; set; }
        /// <summary>
        /// Временные интервалы
        /// </summary>
        public ArrayList DateIntervals { get; set; }


        /// <summary>
        /// Расходы на начало отчетного периода
        /// </summary>
        public ArrayList OutcomesBefore { get; set; }

        /// <summary>
        /// Данные о контракте с заказчиком
        /// </summary>
        public HybridDictionary Contract { get; set; }
    #endregion

    #region расчитываемые показатели
        /// <summary>
        /// ID преокта
        /// </summary>
        public string ProjectID { get; set; }

        /// <summary>
        /// Остаток не израсходованных средств на конец отчетного периода по каждой статье бюджета
        /// </summary>
        public HybridDictionary BudgetBalance { get; set; }

        /// <summary>
        /// Расходы на конец отчетного периода
        /// </summary>
        public HybridDictionary OutcomesAfter { get; set; }
        /// <summary>
        /// Сумма расходов планируемых и фактических по каждой статье бюджета
        /// </summary>
        public HybridDictionary BudgetOutOutcomeSum { get; set; }
        /// <summary>
        /// Сумма расходов планируемых и фактических по каждому контрагенту
        /// </summary>
        public HybridDictionary SupplierOutcomeSum { get; set; }
        /// <summary>
        /// Сальдо за каждый период 
        /// Key - GUID DateInterval
        /// Value - Сальдо за период
        /// </summary>
        public HybridDictionary IntervalSaldo { get; set; }
        /// <summary>
        /// Кол-во временных интервалов
        /// </summary>
        public int IntervalCount { get; set; }

        /// <summary>
        /// Сумма расходов запланированнных в бюджете по проекту
        /// </summary>
        public double BudgetOutSum { get; set; }
        /// <summary>
        /// Сумма приходов запланированных в бюджете по проекту
        /// </summary>
        public double BudgetInSum { get; set; }

        /// <summary>
        /// Суммарное сальдо по проекту
        /// </summary>
        public double TotalSaldo { get; set; }

        /// <summary>
        /// Сумма контракта с заказчиком
        /// </summary>
        public double ContractSum { get; set; }
    #endregion

        public ProjectFinanceData()
        {
            IntervalSaldo = new HybridDictionary();
            BudgetOutOutcomeSum = new HybridDictionary();
            SupplierOutcomeSum = new HybridDictionary();
            OutcomesAfter = new HybridDictionary();
            BudgetBalance = new HybridDictionary();
        }

        #region IDisposable Support
        private bool disposedValue = false; // Для определения избыточных вызовов

        protected override void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {

                }

                // TODO: освободить неуправляемые ресурсы (неуправляемые объекты) и переопределить ниже метод завершения.
                Budget = null;
                DateIntervals = null;
                DateRatio = null;
                IntervalOutcomes = null;
                IntervalSaldo = null;
                OutcomesBefore = null;
                Contract = null;
                BudgetInSum = 0;
                BudgetOutSum = 0;
                ContractSum = 0;
                TotalSaldo = 0;
                IntervalCount = -1;
                ProjectID = String.Empty;
                BudgetOutOutcomeSum = null;
                SupplierOutcomeSum = null;
                OutcomesAfter = null;
                BudgetBalance = null;

                disposedValue = true;

                base.Dispose(true);
            }
        }

        // TODO: переопределить метод завершения, только если Dispose(bool disposing) выше включает код для освобождения неуправляемых ресурсов.
        ~ProjectFinanceData()
        {
           // Не изменяйте этот код. Разместите код очистки выше, в методе Dispose(bool disposing).
           Dispose(false);
        }
        #endregion
    }



}