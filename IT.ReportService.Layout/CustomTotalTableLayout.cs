using System;
using System.Collections;
using System.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Layouts;
using Croc.XmlFramework.ReportService.Layouts.Formatters;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Layouts
{
	/// <summary>
	/// Table-layout ��� �������� ������ ������ �� ���������� �������
	/// </summary>
	/// <remarks>����� ����������� ������ �� ������� ����������, � �������
	/// ������� NoTotals = 0. ���� ������ ������� ��� ��� ��� �������� �� �����
	/// ���� ������������ � �������� ����, �� ����� ������������� ��� ������.</remarks>
	public class CustomTotalTableLayout : TableLayout
	{
		private const string NOTOTALS_COLUMN_NAME = "NoTotals";
		
		private LayoutColumns m_TotalColumns = null;
		
		/// <summary>
		/// ��������� �������� ��� ���������� ������ ������
		/// �� ��������, ��� NoTotals = 0 ��� �� �����
		/// </summary>
		protected virtual LayoutColumns TotalColumns
		{
			get { return this.m_TotalColumns; }
		}

		/// <summary>
		/// ��������� �������� �������
		/// </summary>
		/// <param name="column"></param>
		/// <returns></returns>
		protected static LayoutColumn cloneLayoutColumn(LayoutColumn column)
		{
			return new LayoutColumn(
				null,
				column.Title,
				column.RSFileldName,
				column.IsHidden,
				column.Align,
				column.VAlign,
				column.Width,
				column.CellCssClass,
				column.HeaderCssClass,
				column.TotalCssClass,
				column.SubTitleCssClass,
				column.SubTotalCssClass,
				column.ColumnIsCounter,
				column.CounterStart,
				column.CounterIncrement,
				column.AggregationFunction,
				column.AggregationString,
				column.AggregationStringSubTitle,
				column.AggregationStringSubTotals,
				column.AggregationColspan,
				column.RowspanBy,
				column.Encoding,
				vartypes.@string, 
				column.Formatters
			);
		}

		/// <summary>
		/// ��������� ��������� �������� ��������
		/// </summary>
		/// <param name="columns"></param>
		/// <returns></returns>
		protected static LayoutColumns cloneLayoutColumns(LayoutColumns columns)
		{
			LayoutColumns cloneColumns = new LayoutColumns();
			for (int i = 0; i<columns.Count; i++)
			{
				if (!columns[i].ColumnIsCounter)
				{
					// ���� ������� �� �������, ��������� ������������� �������
					// ��� ���������� ��������� ������ �� ���������� �������
					cloneColumns.Add(cloneLayoutColumn(columns[i]));
				}
				else
				{
					// ���� ������� - �������, ��������� ��� �������,
					// ����� �� ��������� ���������
					cloneColumns.Add(columns[i]);
				}
			}
			return cloneColumns;
		}

		/// <summary>
		/// ��������� ���������� ������������� ������ �� ��������� ��������
		/// </summary>
		/// <param name="LayoutProfile">xml-������� �������</param>
		/// <param name="LayoutData">���������</param>
		/// <remarks>�������������� ����������� �����</remarks>
		protected override void DoMake(abstractlayoutClass LayoutProfile, ReportLayoutData LayoutData)
		{
			base.DoMake(LayoutProfile, LayoutData);

			// ������� ������� ������
			m_TotalColumns = null;
		}
		
		/// <summary>
		/// ������ ������� ������� �������
		/// </summary>
		/// <remarks>�������������� ����������� �����</remarks>
        protected override void WriteColumns(tablelayoutClass LayoutProfile, ReportLayoutData LayoutData, DataTable oTable, TableLayout.LayoutColumns Columns)
        {
            base.WriteColumns(LayoutProfile, LayoutData, oTable, Columns);
            // ������� ����� ������������ ��������
            // ��� ���������� ����� ������ ������ �� ���������� �������
            m_TotalColumns = cloneLayoutColumns(Columns);
        }
        // ����������� ������
        /*protected override void WriteColumns(tablelayoutClass LayoutProfile, XslFOProfileWriter RepGen, DataTable oTable, LayoutColumns Columns, ReportParams Params, object CustomData, IDictionary Vars)
		{
			base.WriteColumns(LayoutProfile, RepGen, oTable, Columns, Params, CustomData, Vars);

			// ������� ����� ������������ ��������
			// ��� ���������� ����� ������ ������ �� ���������� �������
			m_TotalColumns = cloneLayoutColumns(Columns);
		} */
        
		/// <summary>
		/// ��������� ������ ������ ������� �������
		/// </summary>
		/// <remarks>�������������� ����������� �����</remarks>
        
        protected override ReportFormatterData CalculateCellValue(ReportLayoutData LayoutData, TableLayout.LayoutColumns Columns, int RowNum, int ColumnNum, DataRow CurrentRow, int RowSpan)
		{
			// �������� � ������
            object CurrentValue = null;
            // �������� ������, � ������� �������� ���������� � ����������
            ReportFormatterData FormatterData = new ReportFormatterData(
                LayoutData,
                CurrentValue,
                null,
                CurrentRow,
                RowNum,
                ColumnNum);
			if (string.Empty == Columns[ColumnNum].RSFileldName) // ���� ������� �������� �� ������������ ������� ������� ����������
			{					
				if (Columns[ColumnNum].ColumnIsCounter) // ���� ������� - �������
				{
					// ������� �������� ��������
					CurrentValue = Columns[ColumnNum].CounterCurrent.ToString();
					// �������������� �������
					Columns[ColumnNum].IncrementCounter();					
				}
				else // null �����
				{
					CurrentValue = null;	
				}
			}	
			else // ��������
			{
                CurrentValue = new Croc.XmlFramework.ReportService.Utility.MacroProcessor(FormatterData).Process(Columns[ColumnNum].RSFileldName);
            }
			// Encoding
			if(Columns[ColumnNum].Encoding == encodingtype.text)
				CurrentValue = System.Web.HttpUtility.HtmlEncode(CurrentValue.ToString());
            FormatterData.CurrentValue = CurrentValue;
			// �������� �� ����������� � �����������
			if (Columns[ColumnNum].Formatters!=null)
			{
				foreach(abstractformatterClass FormatterNode in Columns[ColumnNum].Formatters)
				{
					if(!FormatterNode.useSpecified || FormatterNode.use!=usetype.totalcell)
					{
						// ������ ������ � �������
          				IReportFormatter Formatter = (IReportFormatter)ReportObjectFactory.GetInstance(FormatterNode.GetAssembly(), FormatterNode.GetClass());

						// ������ ���-��
						Formatter.Execute(FormatterNode, FormatterData);
					}
				}
			}

			if (string.Empty != Columns[ColumnNum].AggregationFunction)
			{
				Columns[ColumnNum].UpdateTotals(CurrentValue);

				// ����������� ����� �� ���������� �������
				bool bNoTotals;
				try
				{
					// ����� �� ������ ��������� ������� NoTotals
					bNoTotals = Convert.ToBoolean(CurrentRow[NOTOTALS_COLUMN_NAME]);
				}
				catch (Exception)
				{
					// ����, ���-�� ����� �� ���, �������, ��� �����
					// ������������� ����� (��� ������)
					bNoTotals = false;
				}

				// ����������� �����, ���� �����
				if (!bNoTotals)
				{
					TotalColumns[ColumnNum].UpdateTotals(CurrentValue);
				}
			}
            
			if(FormatterData.ClassName==null || FormatterData.ClassName==string.Empty)
			{
				FormatterData.ClassName = Columns[ColumnNum].CellCssClass;
			}

			return FormatterData;
		}
		/// <summary>
		/// ������ ������ ���������� ������. ��� ����� ���� ��� ������ � ������ �������, ��� � � ��������������
		/// </summary>
		/// <remarks>�������������� ����������� �����</remarks>
        protected override void WriteTotalRow(tablelayoutClass LayoutProfile, ReportLayoutData LayoutData, TableLayout.LayoutColumns Columns, int CurrentRowNum, int CurrentColumnNum, bool SubTotals, DataTable oTable, int[] ColumnsRowspan, int nGroupedCellsCount, DataRow PreviousRow)
		{
			if (SubTotals)
			{
				// ���� �� ������� ��������, �� ������ �������� ������� �����
				base.WriteTotalRow(LayoutProfile, LayoutData, Columns, CurrentRowNum, CurrentColumnNum, SubTotals,  oTable, ColumnsRowspan, nGroupedCellsCount, PreviousRow);
			}
			else
			{
				// ���� �� ������� ����� �����, �� �������� ������� �����, ��
				// �������� ��� ������� ��� ���������� ������ ������ �� ���������� �������
				base.WriteTotalRow(LayoutProfile, LayoutData, TotalColumns, CurrentRowNum, CurrentColumnNum, SubTotals,  oTable, ColumnsRowspan, nGroupedCellsCount, PreviousRow);
			}
		}
	}
}
