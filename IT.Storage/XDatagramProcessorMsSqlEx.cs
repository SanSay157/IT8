//******************************************************************************
// Инструментальная среда CROC XML Framework .NET
// ЗАО КРОК инкорпорейтед, 2004
//******************************************************************************
using System;
using System.Text;
using System.Xml;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.XUtils;

namespace Croc.XmlFramework.Data
{
	/// <summary>
	/// Реализация процессора датаграмм, учитывающего специфику Microsoft SQL Server
	/// </summary>
	public class XDatagramProcessorMsSqlEx : XDatagramProcessorForNonDeferrableDbEx
	{
		/// <summary>
		/// Кеш скриптов создания временной таблицы, используемой для апдейтов. 
		/// Ключем является метаописание типа (узел ds:type метаданных)
		/// Значением является строка со скриптом.
		/// </summary>
        private static XThreadSafeCache<object, object> cacheTempTableCreationScripts = new XThreadSafeCache<object, object>();
		
		#region Реализация шаблона Singleton

		/// <summary>
		/// Экземпляр
		/// </summary>
		private static XDatagramProcessorEx m_Instance = new XDatagramProcessorMsSqlEx();

		/// <summary>
		/// Возвращает экземпляр
		/// </summary>
		public static XDatagramProcessorEx Instance
		{
			get { return m_Instance; }
		}
		#endregion

		/// <summary>
		/// Процедура, формирующая операцию UPDATE с использованием данных из временной таблицы
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="disp">XDbStatementDispatcher</param>
		/// <param name="sTempTableName">Имя временной таблице (уже заэнкоженное)</param>
		/// <param name="bUseMagicBit">Признак использование "магического бита"</param>
		/// <param name="sTypeName">Имя типа обновляемой группы объектов</param>
		/// <param name="sSchemaName">Наименование схемы</param>
		/// <param name="xmlTypeMD">Метаданные типа</param>
		protected override void updateWithTempTable(
			XStorageConnection xs, 
			XDbStatementDispatcher disp, 
			string sTempTableName, 
			bool bUseMagicBit, 
			string sSchemaName, 
			string sTypeName, 
			XmlElement xmlTypeMD )
		{
			StringBuilder cmdBuilder;
			cmdBuilder = new StringBuilder();
			cmdBuilder.AppendFormat(
				"UPDATE {0} SET {1}{2} = CASE WHEN s.{3} ='1' THEN CASE WHEN d.{2}<{3} THEN d.{2}+1 ELSE 1 END ELSE d.{2} END{1}",
				xs.GetTableQName(sSchemaName, sTypeName),	// 0
				xs.Behavior.SqlNewLine,			// 1
				xs.ArrangeSqlName("ts"),		// 2
				xs.ArrangeSqlName("x_ts"),		// 3
				Int64.MaxValue					// 4
				);
			// Для каждого скалярного свойства update на значение из временной таблице, если в колонке x_{имя_свойства} лежит 1, иначе само на себя
			foreach(XmlElement xmlPropMD in xmlTypeMD.SelectNodes("ds:prop[@cp='scalar' and @vt!='bin' and @vt!='text']", xs.MetadataManager.NamespaceManager))
			{
				cmdBuilder.AppendFormat(",[{0}] = CASE WHEN s.[x{0}]='1' THEN s.[c{0}] ELSE d.[{0}] END{1}",
					xmlPropMD.GetAttribute("n"),	// 0
					xs.Behavior.SqlNewLine			// 1
					);
			}
			if(bUseMagicBit)
				cmdBuilder.Append(",[MagicBit]=1" + xs.Behavior.SqlNewLine);
			cmdBuilder.AppendFormat("FROM {0} d JOIN {1} s ON d.ObjectID = s.ObjectID AND (d.ts = s.ts OR s.ts IS NULL)",
				xs.GetTableQName(sSchemaName, sTypeName),	// 0
				sTempTableName								// 1
				);
			disp.DispatchStatement(cmdBuilder.ToString(), true);
		}

		/// <summary>
		/// Возвращает имя временной таблицы
		/// </summary>
		/// <returns>имя временной таблицы</returns>
		protected override string getTempTableName()
		{
			return "##" + base.getTempTableName();
		}

		/// <summary>
		/// Возвращает текст скрипта создания временной таблицы для insert'ов.
		/// При первом (для типа) обращении вызывает createTempTableCreationScript и кеширует результат.
		/// Наименование временной таблицы {sTempTableName}
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="sTempTableName">Наименование временной таблицы</param>
		/// <param name="xtype">метаданные типа</param>
		/// <returns>текст скрипта</returns>
		protected override string getTempTableCreationScript( XStorageConnection xs, string sTempTableName, XTypeInfo xtype )
		{
			return	"CREATE TABLE " + sTempTableName + 
				"(" 
				+ cacheTempTableCreationScripts.GetValue(xtype, dlgCreateTempTableCreationScript, xs) +
				")";
		}
	}
}
