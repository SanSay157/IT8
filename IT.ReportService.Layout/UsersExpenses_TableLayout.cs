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
	/// Table-layout для отчета "Динамика затрат сотрудников"
	/// </summary>
	public sealed class UsersExpensesTableLayout : CustomTotalTableLayout
	{
		private LayoutColumns m_TotalColumns = null;
		
		/// <summary>
		/// коллекция столбцов для накопления итогов только
		/// по сторокам, где NoTotals = 0 или не задан
		/// </summary>
		protected override LayoutColumns TotalColumns
		{
			get { return this.m_TotalColumns; }
		}

		/// <summary>
		/// Формирует визуальное представление отчета на основании описания
		/// </summary>
		/// <param name="LayoutProfile">xml-профиль лэйаута</param>
		/// <param name="LayoutData">параметры</param>
		/// <remarks>Переопределяем стандартный метод</remarks>
		protected override void DoMake(abstractlayoutClass LayoutProfile, ReportLayoutData LayoutData)
		{
			base.DoMake(LayoutProfile, LayoutData);

			// очищаем столбцы итогов
			m_TotalColumns = null;
		}
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
					//InsertColumn(ColNode, null, LayoutProfile, RepGen, Columns, Params, HiddenColumns, FormattersNode, CustomData, Vars);
				}

				// добавляем неявно описанные колонки
				foreach (DataColumn oDataColumn in oTable.Columns)
				{
					writeVarColumn(LayoutProfile, LayoutData, Columns, oDataColumn, HiddenColumns, FormattersNode);
				}
			}

			// создаем копию существующих столбцов
			// для накопления общих итогов только по помеченным строкам
			m_TotalColumns = cloneLayoutColumns(Columns);
		}

		/// <summary>
		/// Проверяет, нужно ли выводить дополнительный столбец
		/// и выводит его в случае необходимости
		/// </summary>
		/// <param name="LayoutProfile">профиль отчета</param>
		/// <param name="RepGen">репорт-райтер</param>
		/// <param name="Columns">описание колонок лэйаута</param>
		/// <param name="Params">параметры</param>
		/// <param name="CustomData">пользовательские данные</param>
		/// <param name="Vars">переменные фрагмента отчета</param>
		/// <param name="oDataColumn">дополнительный столбец, который нужно вывести</param>
		/// <param name="HiddenColumns">скрытые столбцы</param>
		/// <param name="FormattersNode">форматтеры для лэйаута по умолчанию</param>
        private void writeVarColumn(tablelayoutClass LayoutProfile, ReportLayoutData LayoutData, TableLayout.LayoutColumns Columns, DataColumn oDataColumn, string HiddenColumns, abstractformatterClass[] FormattersNode)
		{
			// нас интересуют только столбцы с названиями вида Expenses_yyyyMMdd
			// остальные столбцы пропускаем
			if (oDataColumn.ColumnName.IndexOf("Expenses_") < 0)
				return;

			colClass ColNode = new colClass();
			ColNode.aggregationfunction = aggregationfunctiontype.sum;
			ColNode.aggregationfunctionSpecified = true;
			ColNode.data = "{#" + oDataColumn.ColumnName + "}";
			ColNode.t = DateTime.ParseExact(oDataColumn.ColumnName.Substring(9), "yyyyMMdd", null).ToShortDateString();
			
			// пропишем форматтеры
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
