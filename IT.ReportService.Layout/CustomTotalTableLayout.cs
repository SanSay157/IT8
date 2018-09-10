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
	/// Table-layout для подсчета итогов только по помеченным строкам
	/// </summary>
	/// <remarks>Итоги вычисляются только по строкам рекордсета, в которых
	/// столбец NoTotals = 0. Если такого столбца нет или его значение не может
	/// быть преоразовано в булевому типу, то итоги накапливаются как обычно.</remarks>
	public class CustomTotalTableLayout : TableLayout
	{
		private const string NOTOTALS_COLUMN_NAME = "NoTotals";
		
		private LayoutColumns m_TotalColumns = null;
		
		/// <summary>
		/// коллекция столбцов для накопления итогов только
		/// по сторокам, где NoTotals = 0 или не задан
		/// </summary>
		protected virtual LayoutColumns TotalColumns
		{
			get { return this.m_TotalColumns; }
		}

		/// <summary>
		/// Клонирует описание столбца
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
		/// Клонирует коллекцию описаний столбцов
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
					// если столбец не счетчик, добавляем клонированный столбец
					// для накопления подитогов только по помеченным строков
					cloneColumns.Add(cloneLayoutColumn(columns[i]));
				}
				else
				{
					// если столбец - счетчик, добавляем сам столбец,
					// чтобы не сбивалась нумерация
					cloneColumns.Add(columns[i]);
				}
			}
			return cloneColumns;
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
		/// <remarks>Переопределяем стандартный метод</remarks>
        protected override void WriteColumns(tablelayoutClass LayoutProfile, ReportLayoutData LayoutData, DataTable oTable, TableLayout.LayoutColumns Columns)
        {
            base.WriteColumns(LayoutProfile, LayoutData, oTable, Columns);
            // создаем копию существующих столбцов
            // для накопления общих итогов только по помеченным строкам
            m_TotalColumns = cloneLayoutColumns(Columns);
        }
        // Закомментил старое
        /*protected override void WriteColumns(tablelayoutClass LayoutProfile, XslFOProfileWriter RepGen, DataTable oTable, LayoutColumns Columns, ReportParams Params, object CustomData, IDictionary Vars)
		{
			base.WriteColumns(LayoutProfile, RepGen, oTable, Columns, Params, CustomData, Vars);

			// создаем копию существующих столбцов
			// для накопления общих итогов только по помеченным строкам
			m_TotalColumns = cloneLayoutColumns(Columns);
		} */
        
		/// <summary>
		/// Вычисляет данные ячейки таблицы лэйаута
		/// </summary>
		/// <remarks>Переопределяем стандартный метод</remarks>
        
        protected override ReportFormatterData CalculateCellValue(ReportLayoutData LayoutData, TableLayout.LayoutColumns Columns, int RowNum, int ColumnNum, DataRow CurrentRow, int RowSpan)
		{
			// значение в ячейке
            object CurrentValue = null;
            // получаем объект, с которым работают форматтеры и эвалуаторы
            ReportFormatterData FormatterData = new ReportFormatterData(
                LayoutData,
                CurrentValue,
                null,
                CurrentRow,
                RowNum,
                ColumnNum);
			if (string.Empty == Columns[ColumnNum].RSFileldName) // если текущее значение не соответсвует никакой колонке рекордсета
			{					
				if (Columns[ColumnNum].ColumnIsCounter) // если колонка - счетчик
				{
					// текущее значение счетчика
					CurrentValue = Columns[ColumnNum].CounterCurrent.ToString();
					// инкрементируем счетчик
					Columns[ColumnNum].IncrementCounter();					
				}
				else // null иначе
				{
					CurrentValue = null;	
				}
			}	
			else // значение
			{
                CurrentValue = new Croc.XmlFramework.ReportService.Utility.MacroProcessor(FormatterData).Process(Columns[ColumnNum].RSFileldName);
            }
			// Encoding
			if(Columns[ColumnNum].Encoding == encodingtype.text)
				CurrentValue = System.Web.HttpUtility.HtmlEncode(CurrentValue.ToString());
            FormatterData.CurrentValue = CurrentValue;
			// проходим по эвалуаторам и форматтерам
			if (Columns[ColumnNum].Formatters!=null)
			{
				foreach(abstractformatterClass FormatterNode in Columns[ColumnNum].Formatters)
				{
					if(!FormatterNode.useSpecified || FormatterNode.use!=usetype.totalcell)
					{
						// просим объект у фабрики
          				IReportFormatter Formatter = (IReportFormatter)ReportObjectFactory.GetInstance(FormatterNode.GetAssembly(), FormatterNode.GetClass());

						// делаем что-то
						Formatter.Execute(FormatterNode, FormatterData);
					}
				}
			}

			if (string.Empty != Columns[ColumnNum].AggregationFunction)
			{
				Columns[ColumnNum].UpdateTotals(CurrentValue);

				// проапдейтим итоги по помеченным строкам
				bool bNoTotals;
				try
				{
					// берем из строки рекорсета столбец NoTotals
					bNoTotals = Convert.ToBoolean(CurrentRow[NOTOTALS_COLUMN_NAME]);
				}
				catch (Exception)
				{
					// если, что-то пошло не так, считаем, что нужно
					// пересчитывать итоги (как обычно)
					bNoTotals = false;
				}

				// пересчитаем итоги, если нужно
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
		/// Рисует строку подведения итогов. Это может быть как строка с общими итогами, так и с промежуточными
		/// </summary>
		/// <remarks>Переопределяем стандартный метод</remarks>
        protected override void WriteTotalRow(tablelayoutClass LayoutProfile, ReportLayoutData LayoutData, TableLayout.LayoutColumns Columns, int CurrentRowNum, int CurrentColumnNum, bool SubTotals, DataTable oTable, int[] ColumnsRowspan, int nGroupedCellsCount, DataRow PreviousRow)
		{
			if (SubTotals)
			{
				// если мы выводим подитоги, то просто вызываем базовый метод
				base.WriteTotalRow(LayoutProfile, LayoutData, Columns, CurrentRowNum, CurrentColumnNum, SubTotals,  oTable, ColumnsRowspan, nGroupedCellsCount, PreviousRow);
			}
			else
			{
				// если мы выводим общие итоги, то вызываем базовый метод, но
				// передаем ему столбцы для накопления итогов только по помеченным строкам
				base.WriteTotalRow(LayoutProfile, LayoutData, TotalColumns, CurrentRowNum, CurrentColumnNum, SubTotals,  oTable, ColumnsRowspan, nGroupedCellsCount, PreviousRow);
			}
		}
	}
}
