//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
// Код формирования отчета "Затраты в разрезе направлений"
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.IO;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Types;
using Croc.XmlFramework.ReportService.Layouts;

using Croc.IncidentTracker.Utility;

namespace Croc.IncidentTracker.ReportService.Reports
{
	/// <summary>
	/// Затраты по департаментам
	/// </summary>
	public class CostsByDepartments: CustomITrackerReport 
	{
		/// <summary>
		/// Параметры отчета
		/// </summary>
		public class ThisReportParams
		{
			public PeriodType PeriodType;
			public DateTime? IntervalBegin;
			public DateTime? IntervalEnd;
			public Quarter? Quarter;
			public Guid Folder;
			public string FolderName;
			public bool ShowDetalization;
			public TimeMeasureUnits TimeMeasureUnits;
			public ReportDepartmentCostSort SortBy;
			public bool ShowRestrictions;

			public ThisReportParams(ReportParams ps)
			{
				PeriodType = (PeriodType)((int)ps["PeriodType"]);
				if (!ps.GetParam("IntervalBegin").IsNull) IntervalBegin = (DateTime)ps["IntervalBegin"];
				if (!ps.GetParam("IntervalEnd").IsNull) IntervalEnd = (DateTime)ps["IntervalEnd"];
				if (!ps.GetParam("Quarter").IsNull) Quarter = (Quarter)((int)ps["Quarter"]);
				Folder = (Guid)ps["Folder"];
				ShowDetalization = (bool)((int)ps["ShowDetalization"] != 0);
				TimeMeasureUnits = (TimeMeasureUnits)((int)ps["TimeMeasureUnits"]);
				SortBy = (ReportDepartmentCostSort)((int)ps["SortBy"]);
				ShowRestrictions = (bool)((int)ps["ShowRestrictions"] != 0);

				//if (PeriodType != PeriodType.DateInterval && (IntervalBegin.HasValue || IntervalEnd.HasValue))
				//	throw new ApplicationException("Заданы даты интервала при типе периода отличном от Интервал дат");

				//if (PeriodType != PeriodType.SelectedQuarter && Quarter.HasValue)
				//	throw new ApplicationException("Задан квартал при типе периода отличном от Квартал");
			}
		}

		/// <summary>
		/// Построение отчета
		/// </summary>
		/// <param name="data">Контекст</param>
        protected override void buildReport(ReportLayoutData data)
        {
			XslFOProfileWriter foWriter = data.RepGen;

			ThisReportParams ps = new ThisReportParams(data.Params);

			ps.FolderName = data.DataProvider.GetValue("Header", null) as string;

			OverallData report = null;

			// получим данные
			using (IDataReader reader = data.DataProvider.GetDataReader("Main", null))
			{
				if (reader.Read())
				{
					IOverallDeserializer deserializer = new OverallDeserializer(
					new DepartmentDataDeserializer(
						new DepartmentDetailDataDeserializer()
						)
					);

					report = deserializer.Deserialize(new DataReaderWrapper(reader));
				}
				else
					report = new OverallData(new List<DepartmentData>());
			}

			// сконфигурируем компонент, отвечающий за формирование отчета
			IReportWriter writer = 
				new ReportWriter(
					ps.ShowRestrictions ? new WithParamsHeaderWriter(ps) as IHeaderWriter : new SimpleHeaderWriter() as IHeaderWriter,
					new BodyWriter(
						new BaseDataWriter(
							new SimpleIntIndexGenerator(1, 1),
							ps.TimeMeasureUnits == TimeMeasureUnits.Days
							? new DHMCostsFormatter() as ICostsFormatter
							: new HourCostsFormatter() as ICostsFormatter
							),
						report,
						ps.ShowDetalization ? new DetailReportSerializer() as IReportSerializer : new MainReportSerializer() as IReportSerializer
						)
					) as IReportWriter;

			writer.Write(foWriter);
        }

		/// <summary>
		/// Параметризованный конструктор, вызваемый подсистемой ReportService
		/// </summary>
		/// <param name="ReportProfile"></param>
		/// <param name="ReportName"></param>
		public CostsByDepartments(reportClass ReportProfile, string ReportName) 
			: base(ReportProfile, ReportName) 
		{ }

		#region Данные отчета

		/// <summary>
		/// Базовый класс для представления данных отчета
		/// </summary>
		public abstract class BaseData
		{
			public abstract string Name { get; }
			public abstract int Costs { get; }
		}

		/// <summary>
		/// Данные по подразделениям - не департаментам
		/// </summary>
		public class DepartmentDetailData : BaseData
		{
			private string name;
			private int costs;

			public DepartmentDetailData(string name, int costs)
			{
				this.name = name;
				this.costs = costs;
			}

			public override string Name
			{
				get { return name; }
			}

			public override int Costs
			{
				get { return costs; }
			}
		}

		/// <summary>
		/// Данные по департаментам
		/// </summary>
		public class DepartmentData : BaseData
		{
			private string name;
			private int costs;
			private List<DepartmentDetailData> children = null;

			public IEnumerable<DepartmentDetailData> Children
			{
				get
				{
					return children;
				}
			}

			public DepartmentData(string name, IEnumerable<DepartmentDetailData> children)
			{
				if (name == null) throw new ArgumentNullException("name");
				this.name = name;
				if (children == null) throw new ArgumentNullException("children");
				this.children = new List<DepartmentDetailData>(children);

				costs = 0;
				foreach (DepartmentDetailData child in Children)
				{
					costs += child.Costs;
				}
			}

			public override string Name
			{
				get { return name; }
			}

			public override int Costs
			{
				get { return costs; }
			}
		}

		/// <summary>
		/// Итоговые данные
		/// </summary>
		public class OverallData : BaseData
		{
			private int costs;
			private List<DepartmentData> children = null;

			public IEnumerable<DepartmentData> Children
			{
				get
				{
					return children;
				}
			}

			public OverallData(IEnumerable<DepartmentData> children)
			{
				if (children == null) throw new ArgumentNullException("children");
				this.children = new List<DepartmentData>(children);

				costs = 0;
				foreach (DepartmentData child in Children)
				{
					costs += child.Costs;
				}
			}

			public override string Name
			{
				get { return string.Empty; }
			}

			public override int Costs
			{
				get { return costs; }
			}
		}

		#endregion

		#region Десериализация данных

		public interface IDataReaderWithState : IDataReader
		{
			bool IsBeforeFirstRead { get; }
			bool LastRead { get; }
			bool LastNextResult { get; }
		}

		public class DataReaderWrapper : IDataReaderWithState
		{
			private IDataReader reader = null;

			private bool isBeforeFirstRead = true;

			private bool lastRead = false;
			
			private bool lastNextResult = false;

			public DataReaderWrapper(IDataReader reader)
			{
				if (reader == null) throw new ArgumentNullException("reader");
				this.reader = reader;
			}

			#region IDataReaderWithState Members

			public bool IsBeforeFirstRead
			{
				get { return isBeforeFirstRead; }
			}

			public bool LastRead
			{
				get { return lastRead; }
			}

			public bool LastNextResult
			{
				get { return lastNextResult; }
			}

			#endregion

			#region IDataReader Members

			public void Close()
			{
				reader.Close();
			}

			public int Depth
			{
				get { return reader.Depth; }
			}

			public DataTable GetSchemaTable()
			{
				return reader.GetSchemaTable();
			}

			public bool IsClosed
			{
				get { return reader.IsClosed; }
			}

			public bool NextResult()
			{
				lastNextResult = reader.NextResult();
				isBeforeFirstRead = true;
				lastRead = false;
				return lastNextResult;
			}

			public bool Read()
			{
				lastRead = !reader.Read();
				isBeforeFirstRead = false;
				return !lastRead;
			}

			public int RecordsAffected
			{
				get { return reader.RecordsAffected; }
			}

			#endregion

			#region IDisposable Members

			public void Dispose()
			{
				reader.Dispose();
			}

			#endregion

			#region IDataRecord Members

			public int FieldCount
			{
				get { return reader.FieldCount; }
			}

			public bool GetBoolean(int i)
			{
				return reader.GetBoolean(i);
			}

			public byte GetByte(int i)
			{
				return reader.GetByte(i);
			}

			public long GetBytes(int i, long fieldOffset, byte[] buffer, int bufferoffset, int length)
			{
				return reader.GetBytes(i, fieldOffset, buffer, bufferoffset, length);
			}

			public char GetChar(int i)
			{
				return GetChar(i);
			}

			public long GetChars(int i, long fieldoffset, char[] buffer, int bufferoffset, int length)
			{
				return reader.GetChars(i, fieldoffset, buffer, bufferoffset, length);
			}

			public IDataReader GetData(int i)
			{
				return reader.GetData(i);
			}

			public string GetDataTypeName(int i)
			{
				return reader.GetDataTypeName(i);
			}

			public DateTime GetDateTime(int i)
			{
				return reader.GetDateTime(i);
			}

			public decimal GetDecimal(int i)
			{
				return reader.GetDecimal(i);
			}

			public double GetDouble(int i)
			{
				return reader.GetDouble(i);
			}

			public Type GetFieldType(int i)
			{
				return reader.GetFieldType(i);
			}

			public float GetFloat(int i)
			{
				return reader.GetFloat(i);
			}

			public Guid GetGuid(int i)
			{
				return reader.GetGuid(i);
			}

			public short GetInt16(int i)
			{
				return reader.GetInt16(i);
			}

			public int GetInt32(int i)
			{
				return reader.GetInt32(i);
			}

			public long GetInt64(int i)
			{
				return reader.GetInt64(i);
			}

			public string GetName(int i)
			{
				return reader.GetName(i);
			}

			public int GetOrdinal(string name)
			{
				return reader.GetOrdinal(name);
			}

			public string GetString(int i)
			{
				return reader.GetString(i);
			}

			public object GetValue(int i)
			{
				return reader.GetValue(i);
			}

			public int GetValues(object[] values)
			{
				return reader.GetValues(values);
			}

			public bool IsDBNull(int i)
			{
				return reader.IsDBNull(i);
			}

			public object this[string name]
			{
				get { return reader[name]; }
			}

			public object this[int i]
			{
				get { return reader[i]; }
			}

			#endregion
		}

		/// <summary>
		/// Компонент получения данных по подразделениям из ридера
		/// </summary>
		public interface IDepartmentDetailDataDeserializer
		{
			DepartmentDetailData Deserialize(IDataReaderWithState reader);
		}

		/// <summary>
		/// Компонент получения данных по подразделениям из ридера
		/// </summary>
		public class DepartmentDetailDataDeserializer : IDepartmentDetailDataDeserializer
		{
			public DepartmentDetailData Deserialize(IDataReaderWithState reader)
			{
				string name = reader["Name"] == DBNull.Value ? "<значение не определено>" : (string)reader["Name"];
				int costs = (int)reader["Costs"];
				return new DepartmentDetailData(name, costs);
			}
		}

		/// <summary>
		/// Компонент получения данных по департаментам из ридера
		/// </summary>
		public interface IDepartmentDataDeserializer
		{
			DepartmentData Deserialize(IDataReaderWithState reader);
		}

		/// <summary>
		/// Компонент получения данных по департаментам из ридера
		/// </summary>
		public class DepartmentDataDeserializer : IDepartmentDataDeserializer
		{
			private IDepartmentDetailDataDeserializer detDeserializer = null;

			public DepartmentDataDeserializer(IDepartmentDetailDataDeserializer detDeserializer)
			{
				if (detDeserializer == null)
					throw new ArgumentNullException("detDeserializer");
				this.detDeserializer = detDeserializer;
			}

			public DepartmentData Deserialize(IDataReaderWithState reader)
			{
				string name = reader["Department"] == DBNull.Value ? "<значение не определено>" : (string)reader["Department"];

				return new DepartmentData(name, DeserializeChildren(reader, name));
			}

			private IEnumerable<DepartmentDetailData> DeserializeChildren(IDataReaderWithState reader, string name)
			{
				do
				{
					yield return detDeserializer.Deserialize(reader);
				}
				while (reader.Read() && (reader["Department"] == DBNull.Value ? "<значение не определено>" : (string)reader["Department"]) == name);
			}
		}

		/// <summary>
		/// Компонент получения итоговых данных из ридера
		/// </summary>
		public interface IOverallDeserializer
		{
			OverallData Deserialize(IDataReaderWithState reader);
		}

		/// <summary>
		/// Компонент получения итоговых данных из ридера
		/// </summary>
		public class OverallDeserializer : IOverallDeserializer
		{
			private IDepartmentDataDeserializer depDeserializer = null;

			public OverallDeserializer(IDepartmentDataDeserializer depDeserializer)
			{
				if (depDeserializer == null)
					throw new ArgumentNullException("depDeserializer");
				this.depDeserializer = depDeserializer;
			}

			public OverallData Deserialize(IDataReaderWithState reader)
			{
				if (reader.IsClosed) throw new ArgumentOutOfRangeException("reader");
				return new OverallData(DeserializeChildren(reader));
			}

			private IEnumerable<DepartmentData> DeserializeChildren(IDataReaderWithState reader)
			{
				do
				{
					yield return depDeserializer.Deserialize(reader);
				}
				while (!reader.LastRead);
			}
		}

		#endregion

		#region Формирование отчета

		/// <summary>
		/// Компонент для формирования индекса
		/// </summary>
		/// <typeparam name="T">Тип значения индекса</typeparam>
		public interface IIndexGenerator<T>
		{
			T Generate();
		}

		/// <summary>
		/// Компонент для формирования индекса
		/// </summary>
		public class SimpleIntIndexGenerator : IIndexGenerator<int>
		{
			private int current = 0;
			private int increment = 1;

			public SimpleIntIndexGenerator(int start, int increment)
			{
				current = start;
				this.increment = increment;
			}

			public int Generate()
			{
				int newValue = current;
				current += increment;
				return newValue;
			}
		}

		/// <summary>
		/// Компонент для отрисовки данных отчета
		/// </summary>
		public interface IBaseDataWriter
		{
			void Write(XslFOProfileWriter foWriter, IEnumerable<BaseData> values);
		}

		/// <summary>
		/// Компонент для отрисовки данных отчета
		/// </summary>
		public class BaseDataWriter : IBaseDataWriter
		{
			private IIndexGenerator<int> indexGenerator = null;

			private ICostsFormatter costsFormatter = null;

			public BaseDataWriter(IIndexGenerator<int> indexGenerator, ICostsFormatter costsFormatter)
			{
				if (indexGenerator == null) throw new ArgumentNullException("indexGenerator");
				if (costsFormatter == null) throw new ArgumentNullException("costsFormatter");
				this.indexGenerator = indexGenerator;
				this.costsFormatter = costsFormatter;
			}

			public void Write(XslFOProfileWriter foWriter, IEnumerable<BaseData> values)
			{
				foWriter.TStart(true, "TABLE", false);
				foWriter.TAddColumn("№", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "5%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
				foWriter.TAddColumn("Департамент", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "75%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
				foWriter.TAddColumn("Трудозатраты", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");

				Dictionary<Type, string> rowClasses = new Dictionary<Type, string>();
				rowClasses.Add(typeof(DepartmentData), "GROUP_HEADER");
				rowClasses.Add(typeof(DepartmentDetailData), "TABLE_CELL");
				rowClasses.Add(typeof(OverallData), "TABLE_FOOTER");

				foreach (BaseData value in values)
				{
					foWriter.TRStart();
					if (value is OverallData)
						foWriter.TRAddCell("Итого", null, 1, 1, rowClasses[value.GetType()]);
					else
						foWriter.TRAddCell(indexGenerator.Generate(), null, 1, 1, rowClasses[value.GetType()]);
					foWriter.TRAddCell(CustomReport.xmlEncode(value.Name), null, 1, 1, rowClasses[value.GetType()]);
					foWriter.TRAddCell(costsFormatter.Format(value.Costs), null, 1, 1, rowClasses[value.GetType()]);
					foWriter.TREnd();
				}

				foWriter.TEnd();
			}
		}

		/// <summary>
		/// Форматтер значения затрат
		/// </summary>
		public interface ICostsFormatter
		{
			string Format(int costsInMinutes);
		}

		/// <summary>
		/// Форматтер значения затрат, затраты выводятся в часах
		/// </summary>
		public class HourCostsFormatter : ICostsFormatter
		{
			public string Format(int costsInMinutes)
			{
				return string.Format("{0:0.##}", costsInMinutes / 60.0);
			}
		}

		/// <summary>
		/// Форматтер значения затрат, затраты выводятся в днях, часах, минутах
		/// </summary>
		public class DHMCostsFormatter : ICostsFormatter
		{
			public string Format(int costsInMinutes)
			{
				return Utils.FormatTimeDuration(costsInMinutes, 600);
			}
		}

		/// <summary>
		/// Отрисовщик отчета
		/// </summary>
		public interface IReportWriter
		{
			void Write(XslFOProfileWriter writer);
		}

		/// <summary>
		/// Отрисовщик отчета
		/// </summary>
		public class ReportWriter : IReportWriter
		{
			private IHeaderWriter headerWriter = null;
			private IBodyWriter bodyWriter = null;

			public ReportWriter(IHeaderWriter headerWriter, IBodyWriter bodyWriter)
			{
				if (headerWriter == null) throw new ArgumentNullException("headerWriter");
				if (bodyWriter == null) throw new ArgumentNullException("bodyWriter");

				this.headerWriter = headerWriter;
				this.bodyWriter = bodyWriter;
			}

			public void Write(XslFOProfileWriter writer)
			{
				writer.WriteLayoutMaster();
				writer.StartPageSequence();
				writer.StartPageBody();

				headerWriter.Write(writer);

				bodyWriter.Write(writer);

				writer.EndPageBody();
				writer.EndPageSequence();
			}
		}

		/// <summary>
		/// Отрисовщик пустого отчета
		/// </summary>
		public class EmptyReportWriter : IReportWriter
		{
			private IHeaderWriter headerWriter = null;
			private string message = null;

			public EmptyReportWriter(IHeaderWriter headerWriter, string message)
			{
				if (headerWriter == null) throw new ArgumentNullException("headerWriter");
				this.headerWriter = headerWriter;
				this.message = message;
			}

			public void Write(XslFOProfileWriter writer)
			{
				writer.WriteLayoutMaster();
				writer.StartPageSequence();
				writer.EmptyBody(message == null ? "Нет данных" : message);
				writer.EndPageSequence();
			}
		}

		/// <summary>
		/// Отрисовщик заголовка отчета
		/// </summary>
		public interface IHeaderWriter : IReportWriter { }

		/// <summary>
		/// Отрисовщик заголовка отчета
		/// </summary>
		public class SimpleHeaderWriter : IHeaderWriter
		{
			public void Write(XslFOProfileWriter writer)
			{
				writer.Header("Затраты в разрезе департаментов");
			}
		}

		/// <summary>
		/// Отрисовщик заголовка отчета с параметрами
		/// </summary>
		public class WithParamsHeaderWriter : IHeaderWriter
		{
			private ThisReportParams ps = null;

			public WithParamsHeaderWriter(ThisReportParams ps)
			{
				if (ps == null) throw new ArgumentNullException("ps");
				this.ps = ps;
			}

			public void Write(XslFOProfileWriter writer)
			{
				writer.Header("Затраты в разрезе департаментов");
				writer.AddSubHeader(@"<fo:block font-weight=""bold"" text-align=""left"">Параметры отчета:</fo:block>");

				WriteParam(writer, "Период времени", PeriodTypeItem.GetItem(ps.PeriodType).Description);
				if (ps.PeriodType == PeriodType.DateInterval)
				{
					WriteParam(writer, "С", ps.IntervalBegin.HasValue ? ps.IntervalBegin.Value.ToString("dd.MM.yyyy") : "Не задан");
					WriteParam(writer, "По", ps.IntervalEnd.HasValue ? ps.IntervalEnd.Value.ToString("dd.MM.yyyy") : "Не задан (используется текущая дата)");
				}
				else if (ps.PeriodType == PeriodType.SelectedQuarter)
				{
					WriteParam(writer, "Квартал", ps.Quarter.HasValue ? QuarterItem.GetItem(ps.Quarter.Value).Description : "Не задан");
				}

				WriteParam(writer, "Активность", ps.FolderName);
				WriteParam(writer, "Детализация по отделам и группам", ps.ShowDetalization ? "Да" : "Нет");
				WriteParam(writer, "Представление времени", TimeMeasureUnitsItem.GetItem(ps.TimeMeasureUnits).Description);
				WriteParam(writer, "Порядок сортировки", ReportDepartmentCostSortItem.GetItem(ps.SortBy).Description);
			}

			private void WriteParam<T>(XslFOProfileWriter writer, string name, T value) 
			{
				writer.AddSubHeader(String.Format(
					@"<fo:block text-align=""left""><fo:inline>{0}: </fo:inline><fo:inline font-weight=""bold"">{1}</fo:inline></fo:block>",
					xmlEncode(name),
					xmlEncode(value == null ? string.Empty : value.ToString()))
				);
			}
		}

		/// <summary>
		/// Отрисовщик тела отчета
		/// </summary>
		public interface IBodyWriter : IReportWriter { }

		/// <summary>
		/// Отрисовщик тела отчета
		/// </summary>
		public class BodyWriter : IBodyWriter
		{
			private IBaseDataWriter baseDataWriter = null;

			private OverallData data = null;

			private IReportSerializer serializer = null;

			public BodyWriter(IBaseDataWriter baseDataWriter, OverallData data, IReportSerializer serializer)
			{
				if (baseDataWriter == null) throw new ArgumentNullException("baseDataWriter");
				if (serializer == null) throw new ArgumentNullException("serializer");
				this.baseDataWriter = baseDataWriter;
				this.data = data;
				this.serializer = serializer;
			}

			public void Write(XslFOProfileWriter writer)
			{
				baseDataWriter.Write(writer, serializer.Serialize(data));
			}
		}

		/// <summary>
		/// Компонент, определяющий последовательность отрисовки данных
		/// </summary>
		public interface IReportSerializer
		{
			IEnumerable<BaseData> Serialize(OverallData overall);
		}

		/// <summary>
		/// Компонент, определяющий последовательность отрисовки данных
		/// </summary>
		public class MainReportSerializer : IReportSerializer
		{
			public IEnumerable<BaseData> Serialize(OverallData overall)
			{
				foreach (DepartmentData dep in overall.Children)
				{
					yield return dep;
				}

				yield return overall;
			}
		}

		/// <summary>
		/// Компонент, определяющий последовательность отрисовки данных, с детализацией
		/// </summary>
		public class DetailReportSerializer : IReportSerializer
		{
			public IEnumerable<BaseData> Serialize(OverallData overall)
			{
				foreach (DepartmentData dep in overall.Children)
				{
					yield return dep;

					foreach (DepartmentDetailData det in dep.Children)
					{
						yield return det;
					}
				}

				yield return overall;
			}
		}

		#endregion
	}
}