//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using System.Diagnostics;
using System.Text;
using System.Collections.Generic;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Storage
{
	/// <summary>
	/// Summary description for XDatagramProcessorEx.
	/// </summary>
	public abstract class XDatagramProcessorEx
	{
		#region Сохранение объектов

		public void Save(XStorageConnection xs, XDatagram datagram)
		{
			if (xs == null)
				throw new ArgumentNullException("xs");
			if (datagram == null)
				throw new ArgumentNullException("xobjSet");

			Debug.Assert(datagram.ObjectsToInsert!=null, "Массив объектов на вставку не определен (null)");
			Debug.Assert(datagram.ObjectsToUpdate!=null, "Массив объектов на обновление не определен (null)");
			Debug.Assert(datagram.ObjectsToDelete!=null, "Массив объектов на удаление не определен (null)");

			if(xs.Transaction==null)
				saveWithoutTransaction(xs, datagram);
			else
				saveWithinTransaction(xs, datagram);
		}

		/// <summary>
		/// Запускает сохранение при отсутствии внещней транзакции, создает транзакцию внутри
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="datagram">множество объектов</param>
		protected void saveWithoutTransaction(XStorageConnection xs, XDatagram datagram)
		{
			xs.BeginTransaction();
			try
			{
				DoSave(xs, datagram);
				xs.CommitTransaction();
			}
			catch(XDbDeadlockException)
			{
				// если произошел Dealock, то не будем пытаться откатить транзакцию, т.к. она уже не существует
				throw;
			}
			catch
			{
				xs.RollbackTransaction();
				throw;
			}
		}

		/// <summary>
		/// Запускает сохранение в рамках текущей трпнзакции.
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="datagram">множество объектов</param>
		protected void saveWithinTransaction(XStorageConnection xs, XDatagram datagram)
		{
			const string SAVEPOINT_NAME = "SP_XStorage_Save";
			bool bSavePointUsed = xs.IsSavePointAllowed;
			if (bSavePointUsed)
				xs.SetSavePoint(SAVEPOINT_NAME);
			try
			{
				DoSave(xs, datagram);
				if (bSavePointUsed)
					xs.ReleaseSavePoint();
			}
			catch(XDbDeadlockException)
			{
				// если произошел Dealock, то не будем пытаться откатить транзакцию, т.к. она уже не существует
				throw;
			}
			catch
			{
				if (bSavePointUsed)
					xs.RollbackToSavePoint();
				throw;
			}
		}

		/// <summary>
		/// Сохранение (вставка, обновление, удаление) множества объектов
		/// Не оборачивается ни транзакцией, ни savepoint'ами.
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="datagram">множество объектов</param>
		public abstract void DoSave(XStorageConnection xs, XDatagram datagram);

		/// <summary>
		/// Вставляет новые объекты
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="disp">диспетчер запросов</param>
		/// <param name="datagram">Множество обрабатываемых объектов</param>
		/// <param name="bSuppressMagicBit">признак того, что надо исключить обработку поля MagicBit</param>
		protected virtual void insertObjects(XStorageConnection xs, XDbStatementDispatcher disp, XDatagram datagram, bool bSuppressMagicBit)
		{
			int nIndex;						// порядковый индекс объекта
			XDbCommand cmd;					// команда как фабрика для создания параметров

			// получим упорядоченный список новых объектов упорядоченный по индексу зависимости
			IList aInsObjects = datagram.ObjectsToInsert;
			if (aInsObjects.Count==0) return;
			nIndex = -1;
			cmd = xs.CreateCommand();
			// для каждого объекта создадим заготовку ADO-команды с оператором insert и коллекцией параметров
			foreach(XStorageObjectToSave xobj in aInsObjects)
				insertObject(xs, disp, xobj, cmd, ++nIndex, bSuppressMagicBit);
		}
		
		/// <summary>
		/// Формирует заготовку команды insert для переданного объекта.
		/// Формирутеся текст ADO-команда, параметры и подсчитывается размер команды. 
		/// Имя параметра устанавливается как имя колонки + индекс объекта в общем списке
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="disp">диспетчер запросов</param>
		/// <param name="xobj">объект, для которого требуется сформировать insert-команду</param>
		/// <param name="cmd">команда</param>
		/// <param name="nIndex">индекс объекта в списке</param>
		/// <param name="bSuppressMagicBit">признак того, что надо исключить обработку поля MagicBit.
		/// Если передан false, то в команде insert добавляется поле MagicBit устанавливаемое в 1. 
		/// Если передан true, то в команде insert поле MagicBit не участвует.
		/// </param>
		protected void insertObject(XStorageConnection xs, XDbStatementDispatcher disp , XStorageObjectToSave xobj, XDbCommand cmd, int nIndex, bool bSuppressMagicBit)
		{
			StringBuilder queryBuilder  = new StringBuilder();	// построитель отдельного insert'a
			StringBuilder valuesBuilder = new StringBuilder();	// построитель списка значений
			string sPropName;			// наименование свойства, колонки и параметра
			string sParamName;			// наименование параметра команды
			object vValue;				// значение свойства

			
            List<XDbParameter> Params = new List<XDbParameter>();
			queryBuilder.AppendFormat("INSERT INTO {0} ({1}, {2}", 
				xs.GetTableQName(xobj.SchemaName, xobj.ObjectType),	// 0
				xs.ArrangeSqlName("ObjectID"),						// 1
				xs.ArrangeSqlName("ts")								// 2
				);
			// установим значения ObjectID, ts (в качастве ts установим 1)
			valuesBuilder.Append(xs.ArrangeSqlGuid(xobj.ObjectID) + ",1");
			// если не запрещено, то значение MagicBit = 1
			if (!bSuppressMagicBit && xobj.ParticipateInUniqueIndex)
			{
				queryBuilder.AppendFormat(",{0}", xs.ArrangeSqlName("MagicBit"));
				xobj.MagicBitAffected = true;
				valuesBuilder.Append(",1");
			}
			foreach(DictionaryEntry propDesc in xobj.Props)
			{
				sPropName = (String)propDesc.Key;
				vValue = propDesc.Value;
				if (vValue == null)
					continue;
				XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
				if (!(propInfo is IXPropInfoScalar))
					continue;
				if ((propInfo.VarType == XPropType.vt_bin || propInfo.VarType == XPropType.vt_text) /* && vValue != DBNull.Value*/ )
					continue;
				xobj.TypeInfo.CheckPropValue(sPropName, propInfo.VarType, vValue);
				if (vValue != DBNull.Value)
				{
					queryBuilder.Append( ',' );
					queryBuilder.Append( xs.ArrangeSqlName(sPropName) );
					valuesBuilder.Append( ',' );
					if(xs.DangerXmlTypes.ContainsKey(propInfo.VarType))
					{
						// сформируем наименование параметра (без префикса) как имя колонки + "o" + переданный индекс
						sParamName = xs.GetParameterName( sPropName + "o" + nIndex );
						Params.Add( cmd.CreateParameter(sParamName, propInfo.VarType, ParameterDirection.Input, false, vValue) );
						valuesBuilder.Append( sParamName );
					}
					else
					{
						valuesBuilder.Append(xs.ArrangeSqlValue(vValue, propInfo.VarType));
					}
				}
			}
			// сформируем команду и добавим ее в общий батч
			queryBuilder.AppendFormat(") values ({0})", valuesBuilder.ToString());
			disp.DispatchStatement(queryBuilder.ToString(),Params, false);
		}

		/// <summary>
		/// Формирует заготовку команды update для переданного объекта.
		/// Формируется текст ADO-команда, параметры и подсчитывается размер команды. 
		/// Имя параметра устанавливается как имя колонки + "t" +  nBatch + "o" + nIndex
		/// Для всех колонок используются параметры (в отличии от createUpdateCommandForSameTypeObjects).
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="disp">диспетчер запросов</param>
		/// <param name="xobj">объект, для которого требуется сформировать insert-команду</param>
		/// <param name="nBatchIndex">индекс группы объектов</param>
		/// <param name="nIndex">индекс объекта в списке</param>
		/// <param name="cmd">команда, как фабрика параметров</param>
		/// <param name="bSuppressMagicBit">признак того, что надо исключить обработку поля MagicBit.
		/// Если передан false, то в команде insert добавляется поле MagicBit устанавливаемое в 1. 
		/// Если передан true, то в команде insert поле MagicBit не участвует.
		/// </param>
		/// <returns>заготовка команды с оператором UPDATE всех объектов из списка, либо null</returns>
		protected bool updateObject(XStorageConnection xs, XDbStatementDispatcher disp, XStorageObjectToSave xobj, int nBatchIndex, int nIndex, XDbCommand cmd, bool bSuppressMagicBit)
		{
			StringBuilder cmdBuilder;	// построитель текста одной команды update
			string sPropName;			// наименование свойства, колонки и параметра
			string sParamName;			// наименование параметра команды
			object vValue;				// значение свойства
            List<XDbParameter> aParameters = new List<XDbParameter>();	// коллекция параметров формируемой команды
			bool bCmdConstructed=false;	// признак того, что команда update сформирована

			cmdBuilder = new StringBuilder();
			cmdBuilder.AppendFormat("UPDATE {0} SET ", 
				xs.GetTableQName(xobj.SchemaName, xobj.ObjectType) );
			if (xobj.UpdateTS)
			{
				cmdBuilder.AppendFormat("{0} = CASE WHEN {0}<{1} THEN {0}+1 ELSE 1 END{2}",
					xs.ArrangeSqlName("ts"),	// 0
					Int64.MaxValue,				// 1
					xs.Behavior.SqlNewLine );	// 2
				bCmdConstructed = true;
			}
			foreach(DictionaryEntry propDesc in xobj.Props)
			{
				sPropName = (String)propDesc.Key;
				vValue = propDesc.Value;
				XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
				if (!(propInfo is IXPropInfoScalar))
					continue;
				if ((propInfo.VarType == XPropType.vt_bin || propInfo.VarType == XPropType.vt_text) /*&& vValue != DBNull.Value */)
					continue;
				if (bCmdConstructed)
					cmdBuilder.Append(",");		// текущая колонка уже не первая - добавим запятую
				bCmdConstructed = true;
				xobj.TypeInfo.CheckPropValue(sPropName, propInfo.VarType, vValue);
				sParamName = xs.GetParameterName(String.Format("{0}t{1}o{2}", sPropName, nBatchIndex, nIndex));
				cmdBuilder.Append(xs.ArrangeSqlName(sPropName) + "=" + sParamName + xs.Behavior.SqlNewLine);
				aParameters.Add( cmd.CreateParameter(sParamName, propInfo.VarType, ParameterDirection.Input, true, vValue));
			}

			if (!bCmdConstructed)
				return false ;
			// если объект участвует в уникальных индексах и есть объекты в списках на вставку и/или удаление, то
			// установим MagicBit в 1 для предотвражения нарушения уникальных индексов
			if (!bSuppressMagicBit && xobj.ParticipateInUniqueIndex)
			{
				xobj.MagicBitAffected = true;
				cmdBuilder.AppendFormat(", {0}=1", xs.ArrangeSqlName("MagicBit") );
			}
			// сформируем условие WHERE: (ObjectID={@oid} AND ts={@ts}),
			// однако условие AND ts={@ts} добавим только если у объекта установлен признак AnalizeTS
			cmdBuilder.Append(" WHERE ");
			sParamName = xs.GetParameterName(String.Format("{0}t{1}o{2}", "ObjectID", nBatchIndex, nIndex));
			cmdBuilder.AppendFormat("({0}={1}", 
				xs.ArrangeSqlName("ObjectID"),
				sParamName );
			aParameters.Add( cmd.CreateParameter(sParamName, DbType.Guid, ParameterDirection.Input, true, xobj.ObjectID) );
			if (xobj.AnalyzeTS)
			{
				sParamName = xs.GetParameterName(String.Format("{0}t{1}o{2}", "ts", nBatchIndex, nIndex));
				cmdBuilder.AppendFormat(" AND {0}={1}", 
					xs.ArrangeSqlName("ts"),	// 0
					sParamName);				// 1
				aParameters.Add( cmd.CreateParameter(sParamName, DbType.Int64, ParameterDirection.Input, true, xobj.TS) );
			}
			cmdBuilder.Append(")");

			disp.DispatchStatement(cmdBuilder.ToString(),aParameters, true);
			return true;
		}

		/// <summary>
		/// Формирует список устаревших и список удаленных объектов после неудачной процедуры обновления.
		/// Метод должен вызываться в рамках процедуры обновления измененных объектов когда количество обновленных
		/// объектов в БД не совпало с ожидаемым количество. Это означает, что некоторые объекты (из списка aUptObjects)
		/// либо "устарели", либо удалены. Данный метод как раз выявляет эти объекты
		/// Списки objects_obsolete и objects_deleted содержат объекты типов XObjectIdentity.
		/// </summary>
		/// <param name="xs">Наследник XStorageConnection</param>
		/// <param name="aUptObjects">Список обновляемых объектов</param>
		/// <param name="objects_obsolete">Возвращаемый список устаревших объектов</param>
		/// <param name="objects_deleted">Возвращаемый список удаленных объектов</param>
		protected void getOutdatedObjects(XStorageConnection xs, IList aUptObjects, out ArrayList objects_obsolete, out ArrayList objects_deleted)
		{
			XDbCommand cmd;						// команда
			ArrayList objects_notdeleted = new ArrayList();	// список не удаленных объектов
			objects_obsolete = new ArrayList();	// список устаревших объектов
			objects_deleted = new ArrayList();	// список удаленных объектов
			XStorageObjectToSave xobjFirst;					// первый объект группы однотипных объектов
			// пойдем по группам однотипных объектов
			IEnumerator enumerator = XDatagram.GetEnumerator(aUptObjects);
			StringBuilder cmdBuilder = new StringBuilder();
			while(enumerator.MoveNext())
			{
				ArrayList aGroup = (ArrayList)enumerator.Current;
				xobjFirst = (XStorageObjectToSave)aGroup[0];
				cmdBuilder.Length = 0;
				cmdBuilder.AppendFormat("SELECT {0}, ts FROM {1} WHERE ",
					xs.ArrangeSqlName("ObjectID"),		// 0
					xs.GetTableQName(xobjFirst.SchemaName, xobjFirst.ObjectType)	// 1
					);
				foreach(XStorageObjectToSave xobj in aGroup)
				{
					cmdBuilder.AppendFormat("{0}={1} OR ", 
						xs.ArrangeSqlName("ObjectID"), xs.ArrangeSqlGuid(xobj.ObjectID) );
				}
				// отрежем последний " OR "
				cmdBuilder.Length -= 4;
				// получим список удаленных объектов:
				// для этого сначала получим список неудаленных объектов
				objects_notdeleted.Clear();
				cmd = xs.CreateCommand(cmdBuilder.ToString());
				using(IDataReader reader = cmd.ExecuteReader())
				{
					while(reader.Read())
					{
						// под индексом 0 здесь ObjectID объекта, он всегда NOT NULL, поэтому IsDbNull не проверяем
						objects_notdeleted.Add( new XObjectIdentity(xobjFirst.ObjectType, reader.GetGuid(0), reader.GetInt64(1)) );
					}
				}
				// теперь у нас есть изначальный список объектов, и список неудаленных объектов, их разность и будет список удаленных объектов
				foreach(XStorageObjectToSave xobj in aGroup)
				{
					// объект для поиска
					XObjectIdentity xobjID = new XObjectIdentity(xobj.ObjectType, xobj.ObjectID);
					int nIndex = objects_notdeleted.IndexOf(xobjID);
					// если текущего объекта нет в списке неудаленных объектов, значит он удаленный
					if (nIndex == -1)
						objects_deleted.Add(xobjID);
						// иначе, если у зачитанного объекта отличается ts от текущего, значит он устаревший
					else if ((objects_notdeleted[nIndex] as XObjectIdentity).TS != xobj.TS && xobj.AnalyzeTS)
						objects_obsolete.Add(xobjID);
				}
			}
		}

		/// <summary>
		/// Сохраняет бинарные и большие текстовые свойства у всех объектов 
		/// (из списка новых и списка обновляемых объектов)
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="datagram">Множество обрабатываемых объектов</param>
		protected void updateBinAndLongData(XStorageConnection xs, XDatagram datagram)
		{
			foreach(XStorageObjectToSave xobj in datagram.ObjectsToInsert)
			{
				updateBinAndLongDataForObject(xs, xobj);
			}
			foreach(XStorageObjectToSave xobj in datagram.ObjectsToUpdate)
			{
				updateBinAndLongDataForObject(xs, xobj);
			}
		}

		/// <summary>
		/// Сохраняет бинарные и большие текстовые свойства для переданного объекта
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="xobj">Объект, для которого требуется обновить большие (бинарные и текстовые) свойства</param>
		protected virtual void updateBinAndLongDataForObject(XStorageConnection xs, XStorageObjectToSave xobj)
		{
			string sValue;
			// по всем текстовым полям переданного объекта
			foreach(DictionaryEntry entry in xobj.GetPropsByType(XPropType.vt_text))
			{
				// установка в NULL происходит сразу в insert/update'ах
				if (entry.Value == DBNull.Value)
					sValue = null;
				else
					sValue = (string)entry.Value;
				xs.SaveTextData(xobj.SchemaName, xobj.ObjectType, xobj.ObjectID, (string)entry.Key, sValue);
			}
			
			byte[] aValue;
			// по всем бинарным полям переданного объекта
			foreach(DictionaryEntry entry in xobj.GetPropsByType(XPropType.vt_bin))
			{
				// установка в NULL происходит сразу в insert/update'ах
				if (entry.Value == DBNull.Value)
					aValue = null;
				else
					aValue = (byte[])entry.Value;
				xs.SaveBinData(xobj.SchemaName, xobj.ObjectType, xobj.ObjectID, (string)entry.Key, aValue );
			}
		}

		/// <summary>
		/// Подчищает ссылки объектов, удаленных из линков
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="disp">диспетчер запросов</param>
		/// <param name="datagram">Множество обрабатываемых объектов</param>
		protected void purgeLinks(XStorageConnection xs, XDbStatementDispatcher disp, XDatagram datagram)
		{
			StringBuilder queryBuilder;	// построитель запроса
			string sTypeName;		// наименование типа объекта владельца обратного свойства

			if (datagram.ObjectsToUpdate.Count==0) return;	// обновлять нечего
			queryBuilder = new StringBuilder();
			// по всем объектам из списка обновляемых
			foreach(XStorageObjectToSave xobj in datagram.ObjectsToUpdate)
			{
				foreach(DictionaryEntry entry in xobj.GetPropsByCapacity(XPropCapacity.Link, XPropCapacity.LinkScalar))
				{
					XPropInfoObject propInfo = (XPropInfoObject)xobj.TypeInfo.GetProp((string)entry.Key);
					Guid[] values = (Guid[])entry.Value;
					queryBuilder.Length=0;
					sTypeName = propInfo.ReferedType.Name;
					// всем объектам ссылающимся на текущуй объект по обратному относительно текущего свойству
					// обNULLим ссылку..
					queryBuilder.AppendFormat(
						"UPDATE {0} SET {1} = NULL, {2} = CASE WHEN {2}<{3} THEN {2}+1 ELSE 1 END {5}WHERE {1}={4} ", 
						xs.GetTableQName(xobj.TypeInfo.Schema, sTypeName),		// 0
						xs.ArrangeSqlName(propInfo.ReverseProp.Name),			// 1
						xs.ArrangeSqlName("ts"),								// 2
						Int64.MaxValue,											// 3
						xs.ArrangeSqlGuid(xobj.ObjectID),						// 4
						xs.Behavior.SqlNewLine									// 5
						);
					// ...при условии, что идентификаторы этих объектов не упомянуты в свойстве
					if (values.Length > 0 )
					{
						// в текущем св-ве есть объекты (их идентификаторы в values)
						queryBuilder.AppendFormat("AND NOT {0} IN (", xs.ArrangeSqlName("ObjectID") );
						foreach(Guid value in values)
						{
							queryBuilder.AppendFormat("{0},", xs.ArrangeSqlGuid(value) );
						}
						// отрежем последнюю запятую
						queryBuilder.Length--;
						queryBuilder.Append(") ");
					}
					// так же исключим объекты, присутствующие в списке удаляемых, 
					// т.к. при удалении проверяется ts, а формируемый update его увеличивает, да и вообще бессмыселен
					if (datagram.ObjectsToDelete.Count>0)
					{
						StringBuilder addWhereBuilder = new StringBuilder();
						foreach(XStorageObjectToDelete xobjDel in datagram.ObjectsToDelete)
						{
							if (xobjDel.ObjectType == sTypeName)
								addWhereBuilder.AppendFormat("{0},", xs.ArrangeSqlGuid(xobjDel.ObjectID) );
						}
						if (addWhereBuilder.Length>0)
						{
							// отрежем последнюю запятую
							addWhereBuilder.Length--;
							queryBuilder.AppendFormat( "AND NOT {0} IN ({1}) ", 
								xs.ArrangeSqlName("ObjectID"),	// 0
								addWhereBuilder.ToString()		// 1	
								);
						}
					}
					disp.DispatchStatement(queryBuilder.ToString(),false);
				}	// конец цикла по свойствам объекта xobj
			}	// конец цикла по объектам из списка обновляемых
		}

		/// <summary>
		/// Обновляет кросс-таблицы для массивных свойств (collection, collection-membership, array)
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="datagram">датаграмма</param>
		protected void updateCrossTables(XStorageConnection xs, XDatagram datagram)
		{
			XDbStatementDispatcher disp = xs.CreateStatementDispatcher();
			foreach(XStorageObjectToSave xobj in datagram.ObjectsToInsert)
				updateCrossTablesForObject(xs, disp, xobj);
			foreach(XStorageObjectToSave xobj in datagram.ObjectsToUpdate)
				updateCrossTablesForObject(xs, disp, xobj);
			disp.ExecutePendingStatementsAndReturnTotalRowsAffected();
		}

		/// <summary>
		/// Обновляет кросс-таблицы для массивных свойств (collection, collection-membership, array) заданного объекта
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="disp">диспетчер запросов</param>
		/// <param name="xobj">ds-Объект</param>
		protected void updateCrossTablesForObject(XStorageConnection xs, XDbStatementDispatcher disp, XStorageObjectToSave xobj)
		{
			string sPropName;			// наименование свойства
			string sDBCrossTableName;	// полное наименование кросс-таблицы
			int nIndex;					// значение колонки k
			string sKeyColumn;			// наименование колонки кросс таблицы, по которой будем очищать
			string sValueColumn;		// 

			// по всем свойствам текущего объекта вида: массив, коллекция, членство в коллекции:
			foreach(DictionaryEntry entry in xobj.GetPropsByCapacity(XPropCapacity.Collection, XPropCapacity.Array, XPropCapacity.CollectionMembership))
			{
				sPropName = (string)entry.Key;
				XPropInfoObject propInfo = (XPropInfoObject)xobj.TypeInfo.GetProp(sPropName);
				Debug.Assert(entry.Value is Guid[]);
				Guid[] values = (Guid[])entry.Value;

				// сформируем наименование кросс-таблицы по поля, по которому будем очищать кросс-таблицу:
				sDBCrossTableName = xs.GetTableQName(xobj.SchemaName, xobj.TypeInfo.GetPropCrossTableName(sPropName));
				
				// Сохранение массива: очистим по ObjectID и вставим все значения из свойства
				if (propInfo.Capacity == XPropCapacity.Array)
				{
					StringBuilder cmdBuilder = new StringBuilder();
					// если сохраняем массив (array) нового объекта (отложенное обновление), то DELETE выполнять не будем
					if (!xobj.IsToInsert)
					{
						// сформируем необходимый оператор delete на кросс-таблицу:
						cmdBuilder.AppendFormat(
							"DELETE FROM {0} WHERE {1}={2}",
							sDBCrossTableName,					// 0
							xs.ArrangeSqlName("ObjectID"),		// 1
							xs.GetParameterName("ObjectID")		// 2
							);
						disp.DispatchStatement(
							cmdBuilder.ToString(), 
							new XDbParameter[] {xs.CreateCommand().CreateParameter("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID)},
							false 
							);
					}
					nIndex = 0;
					// для каждого значения массивного свойства добавим INSERT в кросс-таблицу
					foreach(Guid value in values)
					{
						cmdBuilder.Length=0;
						cmdBuilder.AppendFormat("INSERT INTO {0} ({1}, {2}, {3}) values ({4}, {5}, {6})",
							sDBCrossTableName,					// 0
							xs.ArrangeSqlName("ObjectID"),		// 1
							xs.ArrangeSqlName("Value"),			// 2
							xs.ArrangeSqlName("k"),				// 3
							xs.ArrangeSqlGuid(xobj.ObjectID),	// 4
							xs.ArrangeSqlGuid(value),			// 5
							nIndex								// 6
							);
						disp.DispatchStatement(cmdBuilder.ToString(), false);
						++nIndex;
					}
				}
				// Сохранение коллекции и членства в коллекции
				else
				{
					if (propInfo.Capacity == XPropCapacity.CollectionMembership)
					{
						sKeyColumn = "Value";
						sValueColumn = "ObjectID";
					}
					else
					{
						sKeyColumn = "ObjectID";
						sValueColumn = "Value";
					}
					// сформируем необходимый оператор delete на кросс-таблицу:
					StringBuilder cmdBuilder = new StringBuilder();
					cmdBuilder.AppendFormat(
						"DELETE FROM {0} WHERE {1}={2}",
						sDBCrossTableName,					// 0
						xs.ArrangeSqlName(sKeyColumn),		// 1
						xs.ArrangeSqlGuid(xobj.ObjectID)	// 2
						//xs.GetParameterName("ObjectID")		// 2
						);
					// если есть новые значения свойства, то исключим их из удаления
					if (values.Length > 0)
					{
						cmdBuilder.AppendFormat(
							" AND NOT {0} IN (", xs.ArrangeSqlName(sValueColumn)
							);
						foreach(Guid oid in values)
						{
							cmdBuilder.Append(xs.ArrangeSqlGuid(oid));
							cmdBuilder.Append(",");
						}
						// удалим последнюю запятую
						cmdBuilder.Length--;
						cmdBuilder.Append(")");
					}
					disp.DispatchStatement(
						cmdBuilder.ToString(), 
						//new XDbParameter[] {xs.CreateCommand().CreateParameter("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID)},
						false 
						);

					// для каждого значения массивного свойства добавим INSERT в кросс-таблицу
					foreach(Guid value in values)
					{
						cmdBuilder.Length=0;
						cmdBuilder.AppendFormat("INSERT INTO {0} ({1}, {2}) SELECT {3}, {4} WHERE NOT EXISTS (SELECT 1 FROM {0} WHERE {1}={3} AND {2}={4})",
							sDBCrossTableName,					// 0
							xs.ArrangeSqlName(sKeyColumn),		// 1
							xs.ArrangeSqlName(sValueColumn),	// 2
							xs.ArrangeSqlGuid(xobj.ObjectID),	// 3
							xs.ArrangeSqlGuid(value)			// 4
							);
						disp.DispatchStatement(cmdBuilder.ToString(), false);
					}
				}
			}
		}

		#endregion

		#region Удаление объектов

		/// <summary>
		/// Удаление одного объекта
		/// </summary>
		/// <param name="xs">XStorage</param>
		/// <param name="xobj">Удаляемый объект</param>
		/// <returns>Количество удаленных объектов</returns>
		public int Delete(XStorageConnection xs, IXObjectIdentity xobj)
		{
			return Delete(xs, new IXObjectIdentity[]{xobj});
		}

		/// <summary>
		/// Удаление множества объектов
		/// </summary>
		/// <param name="xs">XStorage</param>
		/// <param name="aDelObjects">Удаляемые объекты</param>
		/// <returns>Количество удаленных объектов</returns>
		public int Delete(XStorageConnection xs, IXObjectIdentity[] aDelObjects)
		{
			if (aDelObjects==null)
				throw new ArgumentNullException("aDelObjects");
			if (aDelObjects.Length==0)
				return 0;
			XStorageObjectToDelete[] aDelObjectsToDelete = new XStorageObjectToDelete[aDelObjects.Length];
			int i = -1;
			foreach(IXObjectIdentity xobj in aDelObjects)
			{
				aDelObjectsToDelete[++i] = new XStorageObjectToDelete(xs.MetadataManager.GetTypeInfo(xobj.ObjectType), xobj.ObjectID, xobj.TS, true);
			}
			return deleteObjectsFromDelete(xs, aDelObjectsToDelete);
		}

		/// <summary>
		/// Удаление множества объектов, запущенное методами Delete
		/// </summary>
		/// <param name="xs">XStorage</param>
		/// <param name="aDelObjects">Удаляемые объекты</param>
		/// <returns>Количество удаленных объектов</returns>
		protected virtual int deleteObjectsFromDelete(XStorageConnection xs, XStorageObjectToDelete[] aDelObjects)
		{
			return internalDeleteObjects(xs, aDelObjects);
		}

		/// <summary>
		/// Удаление множества объектов. Вызывается в рамках процедуры сохранения.
		/// </summary>
		/// <param name="xs">XStorageConnection</param>
		/// <param name="colObjectsToDelete">Коллекция объектов для удаления типа, производного от XObjectBase</param>
		/// <returns>Количество удаленных объектов</returns>
		protected int deleteObjectsFromSaveMethod(XStorageConnection xs, List<object> colObjectsToDelete)
		{
			XStorageObjectToDelete[] aDelObjectsToDelete = new XStorageObjectToDelete[colObjectsToDelete.Count];
			colObjectsToDelete.CopyTo(aDelObjectsToDelete);
			return internalDeleteObjects(xs, aDelObjectsToDelete);
		}

		/// <summary>
		/// Удаляет объекты из переданного списка. Вызывается из всех публичных методов Delete и метода Save
		/// </summary>
		/// <param name="aObjectsToDeleteRoot">список удаляемых объектов (типа ObjectToDelete)</param>
		/// <param name="xs">Экземпляр XStorageConection</param>
		/// <returns>Количество удаленных объектов</returns>
		protected virtual int internalDeleteObjects(XStorageConnection xs, XStorageObjectToDelete[] aObjectsToDeleteRoot)
		{
			return doDelete(xs, xs.CreateStatementDispatcher(), aObjectsToDeleteRoot);
		}

		/// <summary>
		/// Выполняет удаление в БД объектов в списке в порядке их следования в нем
		/// </summary>
		/// <param name="xs">Экземпляр XStorageConection</param>
		/// <param name="disp">Диспетчер запросов</param>
		/// <param name="aDelObjects">список объектов (типа ObjectToDelete), для которых надо выполнить delete в БД</param>
		protected virtual int doDelete(XStorageConnection xs, XDbStatementDispatcher disp, ICollection aDelObjects)
		{
			int nRowsAffected = 0;						// количество удаленных записей
			bool bForcedMode = false;					// признак форсированного удаления (есть хотя бы один объект с незаданным ts)
			string sTypeNamePrev = String.Empty;		// наименование типа предыдущего объекта (в цикле)
			StringBuilder queryTextBuilder = new StringBuilder();	// построитель оператора delete


			if(aDelObjects.Count==0) return 0;
			foreach(XStorageObjectToDelete obj in aDelObjects)
			{
				if (obj.TS == -1)
					bForcedMode = true;
				if (sTypeNamePrev != obj.ObjectType)
				{
					// объект нового типа (в т.ч. первый)
					if (queryTextBuilder.Length > 0)
					{
						disp.DispatchStatement(queryTextBuilder.ToString(),true);
						queryTextBuilder.Length = 0;
					}
					queryTextBuilder.AppendFormat("DELETE FROM {0} WHERE {1}={2}", 
						xs.GetTableQName( obj.TypeInfo ),	// 0
						xs.ArrangeSqlName( "ObjectID" ),	// 1
						xs.ArrangeSqlGuid( obj.ObjectID )	// 2
						);
					// если для объекта задан TS, добавим условие на него
					if (obj.AnalyzeTS)
						queryTextBuilder.AppendFormat(" AND {0}={1}",
							xs.ArrangeSqlName("ts"),
							obj.TS
							);
				}
				else
				{
					// еще один объект того же типа
					queryTextBuilder.AppendFormat( " OR {0}={1}", 
						xs.ArrangeSqlName( "ObjectID" ),	// 0
						xs.ArrangeSqlGuid( obj.ObjectID )	// 1
						);
					// если для объекта задан TS, добавим условие на него
					if (obj.AnalyzeTS)
						queryTextBuilder.AppendFormat(" AND {0}={1}",
							xs.ArrangeSqlName("ts"),
							obj.TS
							);
				}
				sTypeNamePrev = obj.ObjectType;
			}
			if (queryTextBuilder.Length > 0)
			{
				disp.DispatchStatement(queryTextBuilder.ToString(),true);
			}

			nRowsAffected = disp.ExecutePendingStatementsAndReturnTotalRowsAffected();

			if (!bForcedMode)
			{
				if (nRowsAffected != aDelObjects.Count)
				{
					// количество удаленных объектов не совпадает с ожидаемым кол-вом.
					// если в БД остался хотя бы один объект из тех, которые мы удалили, то
					// это означает, что у него "устарел" ts, следовательно будем ругаться.
					// Иначе (в БД нет ниодного объект из тех, которые мы удаляли) все хорошо, просто
					// нас кто-то опередил, но главное результат - все требуемые объекты удалены.
					sTypeNamePrev = String.Empty;
					queryTextBuilder = new StringBuilder();
					XDbCommand cmd = xs.CreateCommand();
					cmd.CommandType = CommandType.Text;
					foreach(XStorageObjectToDelete obj in aDelObjects)
					{
						if (sTypeNamePrev != obj.ObjectType)
						{
							// объект нового типа (в т.ч. первый)
							if (queryTextBuilder.Length > 0)
							{
								cmd.CommandText = queryTextBuilder.ToString();
								if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
									throw new XOutdatedTimestampException();
								queryTextBuilder.Length = 0;
							}
							queryTextBuilder.AppendFormat("SELECT COUNT(1) FROM {0} WHERE {1}={2}", 
								xs.GetTableQName( obj.TypeInfo ),	// 0
								xs.ArrangeSqlName( "ObjectID" ),	// 1
								xs.ArrangeSqlGuid( obj.ObjectID )	// 2
								);
						}
						else
						{
							// еще один объект того же типа
							queryTextBuilder.AppendFormat( " OR {0}={1}", 
								xs.ArrangeSqlName( "ObjectID" ),	// 0
								xs.ArrangeSqlGuid( obj.ObjectID )	// 1
								);
						}
						sTypeNamePrev = obj.ObjectType;
					}
					cmd.CommandText = queryTextBuilder.ToString();
					if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
						throw new XOutdatedTimestampException();
				}
			}

			return nRowsAffected;
		}

		#endregion

		public virtual XDatagramBuilder GetDatagramBuilder()
		{
			return new XDatagramBuilder();
		}
	}
}
