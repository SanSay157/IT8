using System.Collections;
using System.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Layouts;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Layouts
{
	/// <summary>
	/// Table-layout с переменным числом столбцов
	/// </summary>
	public class VarColTableLayout : TableLayout
	{
		/// <summary>
		/// Рисует колонки таблицы лэйаута
		/// </summary>
		/// <param name="LayoutProfile">профиль отчета</param>
		/// <param name="RepGen">репорт-райтер</param>
		/// <param name="oTable">ридер с данными</param>
		/// <param name="Columns">описание колонок лэйаута</param>
		/// <param name="Params">параметры</param>
		/// <param name="CustomData">пользовательские данные</param>
		/// <param name="Vars">переменные фрагмента отчета</param>		
        protected override void WriteColumns(tablelayoutClass LayoutProfile, ReportLayoutData LayoutData, DataTable oTable, TableLayout.LayoutColumns Columns)
        {
			// строка с номерами скрытых колонок
			string HiddenColumns = string.Empty;

			if(LayoutProfile.hiddencolumnsparamname!=null && LayoutProfile.hiddencolumnsparamname!="")
                HiddenColumns = LayoutData.Params[LayoutProfile.hiddencolumnsparamname].ToString();

			// приписываем с начала и с конца строки запятые для облегчения последующего поиска
			if(!HiddenColumns.StartsWith(","))
				HiddenColumns = "," + HiddenColumns;
			if(!HiddenColumns.EndsWith(","))
				HiddenColumns += ",";

			// xml-узел с профилями дефолтных для лэйаута эвалуаторов/форматтеров
			abstractformatterClass[] FormattersNode = LayoutProfile.formatters;		
			
			if(LayoutProfile.col == null)
			{
				// если в профиле явно не описаны колонки отчета
				for(int i = 0; i < oTable.Columns.Count; i++)
				{
					// добавляем колонку в коллекцию
					Columns.Add(new LayoutColumn("{#" + oTable.Columns[i].ColumnName + "}", FormattersNode));
					// добавлем колонку в отчет
                    LayoutData.RepGen.TAddColumn(oTable.Columns[i].ColumnName, align.ALIGN_CENTER, valign.VALIGN_MIDDLE, "TABLE_HEADER");
				}
			}
			else
			{
				// добавляем явно описанные колонки
				foreach (colClass ColNode in LayoutProfile.col)
				{
					// рекурсивно добавляем колонки
                
                    InsertColumn(ColNode, null, LayoutProfile, LayoutData, Columns, HiddenColumns, FormattersNode);
				}

				// добавляем неявно описанные колонки
				foreach (DataColumn oDataColumn in oTable.Columns)
				{
                    WriteVarColumn(LayoutProfile, LayoutData.RepGen, oTable, Columns, LayoutData.Params, LayoutData.CustomData, LayoutData.Vars, oDataColumn, HiddenColumns, FormattersNode);
                }
			}
		}

		/// <summary>
		/// Проверяет, нужно ли выводить дополнительный столбец
		/// и выводит его в случае необходимости
		/// </summary>
		/// <param name="LayoutProfile">профиль отчета</param>
		/// <param name="RepGen">репорт-райтер</param>
		/// <param name="oTable">ридер с данными</param>
		/// <param name="Columns">описание колонок лэйаута</param>
		/// <param name="Params">параметры</param>
		/// <param name="CustomData">пользовательские данные</param>
		/// <param name="Vars">переменные фрагмента отчета</param>
		/// <param name="oDataColumn">дополнительный столбец, который нужно вывести</param>
		/// <param name="HiddenColumns">скрытые столбцы</param>
		/// <param name="FormattersNode">форматтеры для лэйаута по умолчанию</param>
        protected virtual void WriteVarColumn(tablelayoutClass LayoutProfile, XslFOProfileWriter RepGen, DataTable oTable, TableLayout.LayoutColumns Columns, ReportParams Params, object CustomData, IDictionary Vars, DataColumn oDataColumn, string HiddenColumns, abstractformatterClass[] FormattersNode)
		{
		}
	}
}
