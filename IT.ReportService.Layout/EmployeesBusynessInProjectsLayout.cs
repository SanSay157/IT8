using System.Collections;
using System.Data;
using Croc.IncidentTracker.ReportService.Layouts.Formatters;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.Layouts.Formatters;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Layouts
{
	/// <summary>
	/// ������ ��� ������ "��������� ����������� � ��������"
	/// </summary>
	public class EmployeesBusynessInProjectsLayout : CustomTotalTableLayout
	{
        
		/// <summary>
		/// ������ ������ ���������� ������. ��� ����� ���� ��� ������ � ������ �������, ��� � � ��������������
		/// </summary>
		/// <remarks>�������������� ����������� �����</remarks>
        protected override void WriteTotalRow(tablelayoutClass LayoutProfile, Croc.XmlFramework.ReportService.Layouts.ReportLayoutData LayoutData, Croc.XmlFramework.ReportService.Layouts.TableLayout.LayoutColumns Columns, int CurrentRowNum, int CurrentColumnNum, bool SubTotals, DataTable oTable, int[] ColumnsRowspan, int nGroupedCellsCount, DataRow PreviousRow)
        {
			// �������� ������� �����, �� �������� ��� ������� ��� ���������� ������
			// ������ �� ���������� �������
            base.WriteTotalRow(LayoutProfile, LayoutData, TotalColumns, CurrentRowNum, CurrentColumnNum, SubTotals, oTable, ColumnsRowspan, nGroupedCellsCount, PreviousRow);

			// ���� ������� ����� �����, �� ������ ������ ������ �� ����
			if (!SubTotals)
				return;
			
			// �������� ������, � ������� �������� ���������� � ����������
            ReportFormatterData FormatterData = new ReportFormatterData(LayoutData , 
                            ((int)PreviousRow["Expected"] - (int)PreviousRow["TotalSpent"]).ToString(), 
                            null,
                            PreviousRow,
                            -1,
                            -1);
          
			durationevaluatorClass FormatterNode = new durationevaluatorClass();
			FormatterNode.workdayDuration = "{#WorkdayDuration}";
			FormatterNode.format = "{@TimeMeasureUnits}";

			// ������ ������ � �������
			IReportFormatter Formatter = (IReportFormatter)ReportObjectFactory.GetInstance(FormatterNode.GetAssembly(), FormatterNode.GetClass());

			// ������ ���-��
			Formatter.Execute(FormatterNode, FormatterData);
			
			// ����� ��������� ������ ��� ������ ���������� �� ����������
			LayoutTable.AddRow();
			
			LayoutTable.CurrentRow.AddCell("<fo:block text-align='right'>��������� �� ����������:</fo:block>", "string", 1, 3, "SUBTOTAL");
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
