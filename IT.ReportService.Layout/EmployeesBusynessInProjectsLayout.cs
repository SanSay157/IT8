using System.Collections;
using System.Data;
using Croc.IncidentTracker.ReportService.Layouts.Formatters;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.Layouts.Formatters;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Layouts
{
	/// <summary>
	/// Лэйаут для отчета "Занятость сотрудников в проектах"
	/// </summary>
	public class EmployeesBusynessInProjectsLayout : CustomTotalTableLayout
	{
        
		/// <summary>
		/// Рисует строку подведения итогов. Это может быть как строка с общими итогами, так и с промежуточными
		/// </summary>
		/// <remarks>Переопределяем стандартный метод</remarks>
        protected override void WriteTotalRow(tablelayoutClass LayoutProfile, Croc.XmlFramework.ReportService.Layouts.ReportLayoutData LayoutData, Croc.XmlFramework.ReportService.Layouts.TableLayout.LayoutColumns Columns, int CurrentRowNum, int CurrentColumnNum, bool SubTotals, DataTable oTable, int[] ColumnsRowspan, int nGroupedCellsCount, DataRow PreviousRow)
        {
			// вызываем базовый метод, но передаем ему столбцы для накопления итогов
			// только по помеченным строкам
            base.WriteTotalRow(LayoutProfile, LayoutData, TotalColumns, CurrentRowNum, CurrentColumnNum, SubTotals, oTable, ColumnsRowspan, nGroupedCellsCount, PreviousRow);

			// если выводим общие итоги, то больше ничего делать не надо
			if (!SubTotals)
				return;
			
			// получаем объект, с которым работают форматтеры и эвалуаторы
            ReportFormatterData FormatterData = new ReportFormatterData(LayoutData , 
                            ((int)PreviousRow["Expected"] - (int)PreviousRow["TotalSpent"]).ToString(), 
                            null,
                            PreviousRow,
                            -1,
                            -1);
          
			durationevaluatorClass FormatterNode = new durationevaluatorClass();
			FormatterNode.workdayDuration = "{#WorkdayDuration}";
			FormatterNode.format = "{@TimeMeasureUnits}";

			// просим объект у фабрики
			IReportFormatter Formatter = (IReportFormatter)ReportObjectFactory.GetInstance(FormatterNode.GetAssembly(), FormatterNode.GetClass());

			// делаем что-то
			Formatter.Execute(FormatterNode, FormatterData);
			
			// далее добавляем строку для вывода дисбаланса по сотруднику
			LayoutTable.AddRow();
			
			LayoutTable.CurrentRow.AddCell("<fo:block text-align='right'>Дисбаланс по сотруднику:</fo:block>", "string", 1, 3, "SUBTOTAL");
			LayoutTable.CurrentRow.CurrentCell.StartsColumnspanedCells = true;
			LayoutTable.CurrentRow.CurrentCell.IsAggregated = true;

			LayoutTable.CurrentRow.AddCell(null, null, 1, 1);
			LayoutTable.CurrentRow.CurrentCell.IsFakeCell = true;
			LayoutTable.CurrentRow.CurrentCell.IsAggregated = true;
			
			LayoutTable.CurrentRow.AddCell(null, null, 1, 1);
			LayoutTable.CurrentRow.CurrentCell.IsFakeCell = true;
			LayoutTable.CurrentRow.CurrentCell.IsAggregated = true;

			LayoutTable.CurrentRow.AddCell(FormatterData.CurrentValue, "string", 1, 2, "SUBTOTAL");
			LayoutTable.CurrentRow.CurrentCell.StartsColumnspanedCells = true;
			LayoutTable.CurrentRow.CurrentCell.IsAggregated = true;

			LayoutTable.CurrentRow.AddCell(null, null, 1, 1);
			LayoutTable.CurrentRow.CurrentCell.IsFakeCell = true;
			LayoutTable.CurrentRow.CurrentCell.IsAggregated = true;
		}
	}
}
