using System.Collections;
using System.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Layouts;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Layouts
{
	/// <summary>
	/// Table-layout � ���������� ������ ��������
	/// </summary>
	public class VarColTableLayout : TableLayout
	{
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
				}

				// ��������� ������ ��������� �������
				foreach (DataColumn oDataColumn in oTable.Columns)
				{
                    WriteVarColumn(LayoutProfile, LayoutData.RepGen, oTable, Columns, LayoutData.Params, LayoutData.CustomData, LayoutData.Vars, oDataColumn, HiddenColumns, FormattersNode);
                }
			}
		}

		/// <summary>
		/// ���������, ����� �� �������� �������������� �������
		/// � ������� ��� � ������ �������������
		/// </summary>
		/// <param name="LayoutProfile">������� ������</param>
		/// <param name="RepGen">������-������</param>
		/// <param name="oTable">����� � �������</param>
		/// <param name="Columns">�������� ������� �������</param>
		/// <param name="Params">���������</param>
		/// <param name="CustomData">���������������� ������</param>
		/// <param name="Vars">���������� ��������� ������</param>
		/// <param name="oDataColumn">�������������� �������, ������� ����� �������</param>
		/// <param name="HiddenColumns">������� �������</param>
		/// <param name="FormattersNode">���������� ��� ������� �� ���������</param>
        protected virtual void WriteVarColumn(tablelayoutClass LayoutProfile, XslFOProfileWriter RepGen, DataTable oTable, TableLayout.LayoutColumns Columns, ReportParams Params, object CustomData, IDictionary Vars, DataColumn oDataColumn, string HiddenColumns, abstractformatterClass[] FormattersNode)
		{
		}
	}
}
