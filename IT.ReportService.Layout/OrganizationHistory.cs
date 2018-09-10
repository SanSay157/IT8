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
	/// История организации
	/// </summary>
	public class OrganizationHistory: CustomITrackerReport 
	{
		/// <summary>
		/// Параметры отчета
		/// </summary>
		public class ThisReportParams
		{
			public Guid Organization;

			public ThisReportParams(ReportParams ps)
			{
				Organization = (Guid)ps["Organization"];
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

			string name = data.DataProvider.GetValue("Header", null) as string;

			List<BaseData> report = null;

			// получим данные
			using (IDataReader reader = data.DataProvider.GetDataReader("Main", null))
			{
				if (reader.Read())
				{
					IDataDeserializer deserializer = new DataDeserializer(
						new SnapDataDeserializer(),
						new StatusDataDeserializer()
					);

					report = new List<BaseData>(deserializer.Deserialize(new DataReaderWrapper(reader)));
				}
				else
					report = new List<BaseData>();
			}

			// сконфигурируем компонент, отвечающий за формирование отчета
			IReportWriter writer = 
				new ReportWriter(
					new HeaderWriter(name),
					new BodyWriter(
						new BaseDataWriter(
							new SimpleIntIndexGenerator(1, 1)),
						report,
						new ReportSerializer()
						)
					) as IReportWriter;

			writer.Write(foWriter);
        }

		/// <summary>
		/// Параметризованный конструктор, вызваемый подсистемой ReportService
		/// </summary>
		/// <param name="ReportProfile"></param>
		/// <param name="ReportName"></param>
		public OrganizationHistory(reportClass ReportProfile, string ReportName) 
			: base(ReportProfile, ReportName) 
		{ }

		#region Данные отчета

		/// <summary>
		/// Базовый класс для представления данных отчета
		/// </summary>
		public abstract class BaseData
		{
			public abstract DateTime DateTime { get; }
			public abstract string SystemUser { get; }
		}

		/// <summary>
		/// Данные по изменению статуса
		/// </summary>
		public class StatusData : BaseData
		{
			private DateTime dateTime;
			private string systemUser;
			private bool exists;

			public StatusData(DateTime dateTime, string systemUser, bool exists)
			{
				this.dateTime = dateTime;
				this.systemUser = systemUser;
				this.exists = exists; 
			}

			public override DateTime DateTime
			{
				get { return dateTime; }
			}

			public override string SystemUser
			{
				get { return systemUser; }
			}

			public bool Exists
			{
				get { return exists; } 
			}
		}

		/// <summary>
		/// Срез данных
		/// </summary>
		public class SnapData : BaseData
		{
			private DateTime dateTime;
			private string systemUser;
			private bool structureHasDefined;
	        private string externalID;
	        private string name;
			private string shortName;
			private string director;

			public SnapData(
				DateTime dateTime, 
				string systemUser,
				bool structureHasDefined,
				string externalID,
				string name,
				string shortName,
				string director)
			{
				this.dateTime = dateTime;
				this.systemUser = systemUser;
				this.structureHasDefined = structureHasDefined;
				this.externalID = externalID;
				this.name = name;
				this.shortName = shortName;
				this.director = director;
			}

			public override DateTime DateTime
			{
				get { return dateTime; }
			}

			public override string SystemUser
			{
				get { return systemUser; }
			}

			public bool StructureHasDefined
			{
				get { return structureHasDefined; }
			}

			public string ExternalID
			{
				get { return externalID; }
			}

			public string Name
			{
				get { return name; }
			}

			public string ShortName
			{
				get { return shortName; }
			}

			public string Director
			{
				get { return director; }
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
		/// Компонент получения данных по изменению статуса из ридера
		/// </summary>
		public interface IStatusDataDeserializer
		{
			StatusData Deserialize(IDataReaderWithState reader);
		}

		/// <summary>
		/// Компонент получения данных по изменению статуса из ридера
		/// </summary>
		public class StatusDataDeserializer : IStatusDataDeserializer
		{
			public StatusData Deserialize(IDataReaderWithState reader)
			{
				return new StatusData((DateTime)reader["DateTime"], (string)reader["SystemUser"], (byte)reader["Exists"] == 1);
			}
		}

		/// <summary>
		/// Компонент получения среза данных из ридера
		/// </summary>
		public interface ISnapDataDeserializer
		{
			SnapData Deserialize(IDataReaderWithState reader);
		}

		/// <summary>
		/// Компонент получения среза данных из ридера
		/// </summary>
		public class SnapDataDeserializer : ISnapDataDeserializer
		{
			public SnapData Deserialize(IDataReaderWithState reader)
			{
				return new SnapData(
					(DateTime)reader["DateTime"], (string)reader["SystemUser"],
					(byte)reader["StructureHasDefined"] == 1,
					reader["ExternalID"] == DBNull.Value ? string.Empty : (string)reader["ExternalID"],
					(string)reader["Name"],
					reader["ShortName"] == DBNull.Value ? string.Empty : (string)reader["ShortName"],
					reader["Director"] == DBNull.Value ? string.Empty : (string)reader["Director"]
					);
			}
		}

		/// <summary>
		/// Компонент получения данных из ридера
		/// </summary>
		public interface IDataDeserializer
		{
			IEnumerable<BaseData> Deserialize(IDataReaderWithState reader);
		}

		/// <summary>
		/// Компонент получения данных из ридера
		/// </summary>
		public class DataDeserializer : IDataDeserializer
		{
			private ISnapDataDeserializer snapDeserializer = null;
			private IStatusDataDeserializer statusDeserializer = null;

			public DataDeserializer(
				ISnapDataDeserializer snapDeserializer,
				IStatusDataDeserializer statusDeserializer
				)
			{
				if (snapDeserializer == null)
					throw new ArgumentNullException("snapDeserializer");
				this.snapDeserializer = snapDeserializer;
				if (statusDeserializer == null)
					throw new ArgumentNullException("statusDeserializer");
				this.statusDeserializer = statusDeserializer;
			}

			public IEnumerable<BaseData> Deserialize(IDataReaderWithState reader)
			{
				if (reader.IsClosed) throw new ArgumentOutOfRangeException("reader");
				do
				{
					if (reader["Exists"] == DBNull.Value)
						yield return snapDeserializer.Deserialize(reader);
					else
						yield return statusDeserializer.Deserialize(reader);
				}
				while (reader.Read());
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

			public BaseDataWriter(IIndexGenerator<int> indexGenerator)
			{
				if (indexGenerator == null) throw new ArgumentNullException("indexGenerator");
				this.indexGenerator = indexGenerator;
			}

			public void Write(XslFOProfileWriter foWriter, IEnumerable<BaseData> values)
			{
				foWriter.TStart(true, "TABLE", false);
				foWriter.TAddColumn("№", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "5%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
				foWriter.TAddColumn("Дата и время", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
				foWriter.TAddColumn("Пользователь", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
				foWriter.TAddColumn("Наименование", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
				foWriter.TAddColumn("Краткое наименование", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
				foWriter.TAddColumn("Директор клиента", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
				foWriter.TAddColumn("Структура организации определена", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
				foWriter.TAddColumn("Идентификатор внешней системы", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, "", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");

				foreach (BaseData value in values)
				{
					foWriter.TRStart();
					foWriter.TRAddCell(indexGenerator.Generate(), null);
					foWriter.TRAddCell(value.DateTime.ToString("dd.MM.yyyy hh.mm.ss"), null);
					foWriter.TRAddCell(value.SystemUser, null);

					if (value is StatusData)
					{
						StatusData typedValue = value as StatusData;
						foWriter.TRAddCell(typedValue.Exists ? "Создана новая организация" : "Организация удалена", null, 5, 1);
					}
					else
					{
						SnapData typedValue = value as SnapData;
						foWriter.TRAddCell(typedValue.Name, null);
						foWriter.TRAddCell(typedValue.ShortName, null);
						foWriter.TRAddCell(typedValue.Director, null);
						foWriter.TRAddCell(typedValue.StructureHasDefined ? "Да" : "Нет", null);
						foWriter.TRAddCell(typedValue.ExternalID, null);
					}
					foWriter.TREnd();
				}

				foWriter.TEnd();
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
		public class HeaderWriter : IHeaderWriter
		{
			private string name = null;

			public HeaderWriter(string name)
			{
				this.name = name;
			}

			public void Write(XslFOProfileWriter writer)
			{
				writer.Header("История организации");
				WriteParam(writer, "Наименование", name);
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

			private IEnumerable<BaseData> data = null;

			private IReportSerializer serializer = null;

			public BodyWriter(IBaseDataWriter baseDataWriter, IEnumerable<BaseData> data, IReportSerializer serializer)
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
			IEnumerable<BaseData> Serialize(IEnumerable<BaseData> data);
		}

		/// <summary>
		/// Компонент, определяющий последовательность отрисовки данных
		/// </summary>
		public class ReportSerializer : IReportSerializer
		{
			public IEnumerable<BaseData> Serialize(IEnumerable<BaseData> data)
			{
				return data;
			}
		}

		#endregion
	}
}