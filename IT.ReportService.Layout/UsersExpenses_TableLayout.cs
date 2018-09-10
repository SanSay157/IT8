using System;
using System.Collections;
using System.Data;
using Croc.IncidentTracker.ReportService.Layouts.Formatters;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Layouts;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Layouts
{
	/// <summary>
	/// Table-layout ��� ������ "�������� ������ �����������"
	/// </summary>
	public sealed class UsersExpensesTableLayout : CustomTotalTableLayout
	{
		private LayoutColumns m_TotalColumns = null;
		
		/// <summary>
		/// ��������� �������� ��� ���������� ������ ������
		/// �� ��������, ��� NoTotals = 0 ��� �� �����
		/// </summary>
		protected override LayoutColumns TotalColumns
		{
			get { return this.m_TotalColumns; }
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
		/// <param name="LayoutProfile">������� ������</param>
		/// <param name="RepGen">������-������</param>
		/// <param name="oTable">����� � �������</param>
		/// <param name="Columns">�������� ������� �������</param>
		/// <param name="Params">���������</param>
		/// <param name="CustomData">���������������� ������</param>
		/// <param name="Vars">���������� ��������� ������</param>	
        protected override void WriteColumns(tablelayoutClass LayoutProfile, ReportLayoutData LayoutData, DataTable oTable, TableLayout.LayoutColumns Columns)
        {
			// ������ � �������� ������� �������
			string HiddenColumns = string.Empty;

			if(LayoutProfile.hiddencolumnsparamname!=null && LayoutProfile.hiddencolumnsparamname!="")
                HiddenColumns = LayoutData.Params[LayoutProfile.hiddencolumnsparamname].ToString();

			// ����������� � ������ � � ����� ������ ������� ��� ���������� ������������ ������
			if(!HiddenColumns.StartsWith(","))
				HiddenColumns = "," + HiddenColumns;
			if(!HiddenColumns.EndsWith(","))
				HiddenColumns += ",";

			// xml-���� � ��������� ��������� ��� ������� �����������/�����������
			abstractformatterClass[] FormattersNode = LayoutProfile.formatters;		
			
			if(LayoutProfile.col == null)
			{
				// ���� � ������� ���� �� ������� ������� ������
				for(int i = 0; i < oTable.Columns.Count; i++)
				{
					// ��������� ������� � ���������
					Columns.Add(new LayoutColumn("{#" + oTable.Columns[i].ColumnName + "}", FormattersNode));
					// �������� ������� � �����
                    LayoutData.RepGen.TAddColumn(oTable.Columns[i].ColumnName, align.ALIGN_CENTER, valign.VALIGN_MIDDLE, "TABLE_HEADER");
				}
			}
			else
			{
				// ��������� ���� ��������� �������
				foreach (colClass ColNode in LayoutProfile.col)
				{
					// ���������� ��������� �������
                    InsertColumn(ColNode, null, LayoutProfile, LayoutData, Columns, HiddenColumns, FormattersNode);
					//InsertColumn(ColNode, null, LayoutProfile, RepGen, Columns, Params, HiddenColumns, FormattersNode, CustomData, Vars);
				}

				// ��������� ������ ��������� �������
				foreach (DataColumn oDataColumn in oTable.Columns)
				{
					writeVarColumn(LayoutProfile, LayoutData, Columns, oDataColumn, HiddenColumns, FormattersNode);
				}
			}

			// ������� ����� ������������ ��������
			// ��� ���������� ����� ������ ������ �� ���������� �������
			m_TotalColumns = cloneLayoutColumns(Columns);
		}

		/// <summary>
		/// ���������, ����� �� �������� �������������� �������
		/// � ������� ��� � ������ �������������
		/// </summary>
		/// <param name="LayoutProfile">������� ������</param>
		/// <param name="RepGen">������-������</param>
		/// <param name="Columns">�������� ������� �������</param>
		/// <param name="Params">���������</param>
		/// <param name="CustomData">���������������� ������</param>
		/// <param name="Vars">���������� ��������� ������</param>
		/// <param name="oDataColumn">�������������� �������, ������� ����� �������</param>
		/// <param name="HiddenColumns">������� �������</param>
		/// <param name="FormattersNode">���������� ��� ������� �� ���������</param>
        private void writeVarColumn(tablelayoutClass LayoutProfile, ReportLayoutData LayoutData, TableLayout.LayoutColumns Columns, DataColumn oDataColumn, string HiddenColumns, abstractformatterClass[] FormattersNode)
		{
			// ��� ���������� ������ ������� � ���������� ���� Expenses_yyyyMMdd
			// ��������� ������� ����������
			if (oDataColumn.ColumnName.IndexOf("Expenses_") < 0)
				return;

			colClass ColNode = new colClass();
			ColNode.aggregationfunction = aggregationfunctiontype.sum;
			ColNode.aggregationfunctionSpecified = true;
			ColNode.data = "{#" + oDataColumn.ColumnName + "}";
			ColNode.t = DateTime.ParseExact(oDataColumn.ColumnName.Substring(9), "yyyyMMdd", null).ToShortDateString();
			
			// �������� ����������
			emptyvalueevaluatorClass formatter1 = new emptyvalueevaluatorClass();
			formatter1.value = "0";
			durationevaluatorClass formatter2 = new durationevaluatorClass();
			formatter2.format = "{@TimeMeasureUnits}";
			formatter2.workdayDuration = "{#WorkdayDuration}";
			ColNode.formatters = new abstractformatterClass[] { formatter1, formatter2 };

            InsertColumn(ColNode, null, LayoutProfile, LayoutData, Columns, HiddenColumns, FormattersNode);
		}
	}
}
