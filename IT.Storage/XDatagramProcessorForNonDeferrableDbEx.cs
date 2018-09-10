using System;
using System.Collections;
using System.Data;
using System.Diagnostics;
using System.Text;
using System.Xml;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.FlowChartProcessing;
using Croc.XmlFramework.XUtils;
using System.Collections.Generic;

namespace Croc.IncidentTracker.Storage
{
	/// <summary>
	/// Реализация XDatagramProcessor для RDBMS не поддерживающих DEFERED CONSTRAINTS.
	/// </summary>
	public abstract class XDatagramProcessorForNonDeferrableDbEx: XDatagramProcessorEx
	{
		/// <summary>
		/// Делегат для передачи в метод cacheTempTableCreationScripts.GetValue
		/// </summary>
		protected XThreadSafeCacheCreateValue<object,object> dlgCreateTempTableCreationScript;

		/// <summary>
		/// Закрытый конструктор
		/// </summary>
		protected XDatagramProcessorForNonDeferrableDbEx()
		{
			// инициализируем делегат для метода получения скрипта создания временной таблицы для апдейтов.
			// данный делегат будет передаваться как параметр в объект cacheTempTableCreationScripts
            dlgCreateTempTableCreationScript = new XThreadSafeCacheCreateValue<object, object>(createFieldsListForTempTableCreationScript);
		} 

		#region Сохранение объектов

		/// <summary>
		/// Сохранение (вставка, обновление, удаление) множества объектов
		/// Не оборачивается ни транзакцией, ни savepoint'ами.
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="datagram">множество объектов</param>
		public override void DoSave(XStorageConnection xs, XDatagram datagram)
		{
			preProcessDatagram(xs, datagram);
			// вставим новые объекты (без массивных, бинарных и длинных текстовых свойств). 
			// Всем вставленным объектам поле MagicBit устанавливаем в 1, кроме случая, когда
			// у нас нет объектов подлежащих обновлению и удалению.
			bool bSuppressMagicBitForInsert = (datagram.ObjectsToDelete.Count + datagram.ObjectsToUpdate.Count)==0;

			XDbStatementDispatcher disp = xs.CreateStatementDispatcher();
			insertObjects(xs, disp, datagram, bSuppressMagicBitForInsert);
			// если обновлять нечего, то выполним накопившийся батч сразу
			if (datagram.ObjectsToUpdate.Count==0)
				disp.ExecutePendingStatementsAndReturnTotalRowsAffected();
			// вычислим признак игнорирования Magicbit'a для обновляемых объектов
			bool bSuppressMagicBitForUpdate = (datagram.ObjectsToDelete.Count==0);
			// обновим существующие объекты (без массивных, бинарных и длинных текстовых свойств)
			updateObjects(xs, disp, datagram, bSuppressMagicBitForUpdate);
			// обновим массивные свойства (коллекции и массивы)
			updateCrossTables(xs, datagram);
			// запишем бинарные и длинные текстовые свойства
			updateBinAndLongData(xs, datagram);
			// удалим объекты помеченные к удалению
			deleteObjectsFromSaveMethod(xs, datagram.ObjectsToDelete);
			// сбросим поле MagicBit в 0 всех вставленных/обновленных ранее объектов, если мы его устанавливали в 1
			resetObjectMagicBit(xs, datagram, bSuppressMagicBitForInsert, bSuppressMagicBitForUpdate);
		}

		/// <summary>
		/// Обрабатывает XDatagram перед сохранением
		/// </summary>
		/// <param name="xs"></param>
		/// <param name="datagram"></param>
		protected void preProcessDatagram(XStorageConnection xs, XDatagram datagram)
		{
			if (datagram.ObjectsToInsert.Count > 1)
			{
				foreach(XStorageObjectBase xobj in datagram.ObjectsToInsert)
					xobj.InitReferences(datagram.ObjectsToInsertDictionary);
				// создадим и запустим граф-процессор для получения упорядоченного списка объектов и поиска колец
                FlowChartProcessor<XStorageObjectBase, XObjectDependency<XStorageObjectBase>> fcp = new FlowChartProcessor<XStorageObjectBase, XObjectDependency<XStorageObjectBase>>(datagram.ObjectsToInsert);
			
                try
				{
					// true - значит первыми идут объекты, которые не зависят от других объектов
					fcp.Solve(true);
				}
				catch(FlowChartCycleException ex)
				{
					// найдено неразрываемое кольцо в графе
					throw new XCycleReferencingException(ex);
				}
				if (fcp.OriginalReferencesToBreak.Length > 0)
				{
					// найдены разрываемые кольца в графе 
					// - для каждой ссылке в списке разрываемых ссылок сформируем объект и перенесем его в список на обновление
                    foreach (XObjectDependency<XStorageObjectBase> dep in fcp.OriginalReferencesToBreak)
					{
						XStorageObjectToSave xobjNew = detachObjectWithRingReference(xs, dep);
						Debug.Assert(xobjNew!=null, "detachObjectForUpdate вернула null");
						// добавим объект в список обновляемых объектов. если он уже там есть, выполним слияние
						datagram.AddUpdated( xobjNew  );
					}
				}
				// переустановим список вставляемых объектов массивом объектов, отсортированным граф-процессором в порядке зависимости
				datagram.ObjectsToInsert.Clear();
				datagram.ObjectsToInsert.AddRange(fcp.ObjectList);
			}
			//	Список обновляемых объектов отсортируем по типу и идентификатору
			if (datagram.ObjectsToUpdate.Count > 0)
				datagram.ObjectsToUpdate.Sort( XObjectComparerByTypeAndObjectID<XStorageObjectBase>.Instance );
		}

		/// <summary>
		/// Создает объект для отложенного обновления, перенося в него свойство, соответствующее ссылке,
		/// которую граф-процессор выбраз для разрыва кольца.
		/// </summary>
		/// <param name="xs">XStorage</param>
		/// <param name="dep">Ссылка</param>
		/// <returns>Объект с перенесенным свойством, для помещения в список обновляемых объектов</returns>
        protected XStorageObjectToSave detachObjectWithRingReference(XStorageConnection xs, XObjectDependency<XStorageObjectBase> dep)
		{
			XStorageObjectToSave xobjOwner;		// объект-владелец ссылки
			XStorageObjectToSave xobjDetached;	//

			xobjOwner = (XStorageObjectToSave)dep.ObjectOwner;
			// создадим копию объекта-владельца ссылки
			xobjDetached = new XStorageObjectToSave(xobjOwner.TypeInfo, xobjOwner.ObjectID, -1, false);
			// перенесем свойство из объекта-владельца ссылки в его копию
			xobjDetached.Props.Add( dep.PropertyInfo.Name, xobjOwner.Props[dep.PropertyInfo.Name] );
			xobjOwner.Props.Remove(dep.PropertyInfo.Name);
			// т.к. созданный объект является копией текущего для отложенного обновления
			// то анализировать и инкрементировать ts не надо!
			xobjDetached.UpdateTS = false;
			return xobjDetached;
		}

		/// <summary>
		/// Обновляет существующие объекты
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="disp">диспетчер запросов</param>
		/// <param name="datagram">Множество обрабатываемых объектов</param>
		/// <param name="bSuppressMagicBit">признак того, что надо исключить обработку поля MagicBit</param>
		protected virtual void updateObjects(XStorageConnection xs, XDbStatementDispatcher disp, XDatagram datagram, bool bSuppressMagicBit)
		{
			const string SAVEPOINT = "SP_XS_UPDATE";
			IList aUptObject;			// отсортированный список объектов подлежащий обновлению
			int nBatchIndex=0;			// индекс типа
			XDbCommand cmd;				// команда с батчем update'ов
			int nAffectedRows;			// количество обновленных записей
			int nTotalUpdateObjects=0;	// общее количество объектов, для которых послан update в БД
			bool bAlgorithmFound;		// Признак того, что алгоритм выбран
			bool bSavePointSet;			// Признак того, что был установлен SAVEPOINT транзакции

			// получим список объектов для обновления, отсортированный по типу и идентификатору
			aUptObject = datagram.ObjectsToUpdate;
			if (aUptObject.Count==0) return;	// обновлять нечего
			// создадим SAVEPOINT, чтобы к нему откатится в случае, 
			// если количество обновленных записей не совпадает с ожидаемым количеством
			bSavePointSet = xs.IsSavePointAllowed;
			if (bSavePointSet)
				disp.DispatchStatement(xs.Behavior.GetSavePointExpr(SAVEPOINT), false);

			cmd = xs.CreateCommand();
			// пойдем по группам однотипных объектов
			IEnumerator enumerator = XDatagram.GetEnumerator(aUptObject);
			while(enumerator.MoveNext())
			{
				++nBatchIndex;		// индекс группы, т.е. типа
				// получим список объектов одного типа
				ArrayList aGroup = (ArrayList)enumerator.Current;
				Debug.Assert( aGroup!=null, "XObjectGroupedByTypeEnumerator.Current вернул null", "Ошибка в MoveNext");
				Debug.Assert( aGroup.Count>0, "XObjectGroupedByTypeEnumerator вернул пустую группу объектов", "Ошибка в MoveNext");
				bAlgorithmFound = false;
				if (aGroup.Count == 1)
				{
					bAlgorithmFound = true;
					if ( updateObject(xs, disp ,(XStorageObjectToSave)aGroup[0], nBatchIndex, 1, cmd, bSuppressMagicBit))
						++nTotalUpdateObjects;
				}
				else if (aGroup.Count <= xs.MaxObjectsPerUpdate)
				{
					bAlgorithmFound = true;
					updateSameTypeObjects(xs, disp, aGroup, nBatchIndex, cmd, bSuppressMagicBit, ref nTotalUpdateObjects);
				}

				if (!bAlgorithmFound)
				{
					bool bUniqueIndexAffected = false;
					// если в текущем типе есть уникальные индексы и хотя бы в двух объектах есть свойство,
					// участвующее в уникальном индексе, то вызовем виртуальную функцию, которая должна 
					// сформировать команду для такого случая.
					if ((aGroup[0] as XStorageObjectToSave).TypeInfo.HasUniqueIndexes)
					{
						// в текущем типе есть уникальные индексы..
						int nPropInUniqueIndexCount = 0;
						foreach(XStorageObjectToSave xobj in aGroup)
							if (xobj.ParticipateInUniqueIndex)
								if (++nPropInUniqueIndexCount == 2)
								{
									bUniqueIndexAffected = true;
									break;
								}
					}
					if (bUniqueIndexAffected)
					{
						// хотя бы два объекта в текущем множестве однотипных объектов затрагивают уникальный индекс,
						// это означает, что в общем случае нельзя сформировать множество независимых update'ов, 
						// т.к. это может привести к нарушению уникальных индексов. Сформировать один большой UPDATE
						// нам не позволило ограничение на количество объектов в одном операторе update,которое было 
						// превышено.
						// Реализация данного случая остается полностью на усмотрение конкретной реализации XStorageConnection.
						updateLargeNumberOfSameTypeObjects(xs, disp, aGroup, nBatchIndex, cmd, bSuppressMagicBit, ref nTotalUpdateObjects);
					}
					else
					{
						// все текущее множество однотипных объектов (aGroup) не затрагивает ниодного уникального индекса,
						// (либо всего лишь один объект имеет св-во, участвующее в индексе)
						// поэтому для каждого объекта можно сформировать отдельный оператор UPDATE (по аналогии с INSERT'ами)
						int nIndex = 0;
						foreach(XStorageObjectToSave  xobj in aGroup)
						{
							if (updateObject(xs, disp, xobj, nBatchIndex, ++nIndex, cmd, bSuppressMagicBit))
								++nTotalUpdateObjects;
						}
					}
				}
			}

			// подчистим ссылки объектов, удаленных из линков
			purgeLinks(xs, disp, datagram);

			nAffectedRows = disp.ExecutePendingStatementsAndReturnTotalRowsAffected();
			if (nAffectedRows != nTotalUpdateObjects)
			{
				#region Проверка корректности сохранения
				if (!bSavePointSet)
					throw new XOutdatedTimestampException();
				else
				{
					// был установлен SAVEPOINT, откатимся к нему
					xs.CreateCommand( xs.Behavior.GetRollbackToSavePointExpr(SAVEPOINT) ).ExecuteNonQuery();
					ArrayList objects_obsolete;		// список устаревших объектов
					ArrayList objects_deleted;		// список удаленных объектов
					getOutdatedObjects(xs, aUptObject, out objects_obsolete, out objects_deleted);
					Debug.Assert(objects_obsolete.Count + objects_deleted.Count > 0, "nAffectedRows != nTotalUpdateObjects, однако устаревшие и/или удаленные объекты не найдены");
					throw new XOutdatedTimestampException();
				}
				#endregion
			}
		}

		/// <summary>
		/// Создает и возвращает заготовку команды с одним оператором UPDATE для всех объектов в списке aGroup.
		/// Объекты в списке должны быть одного типа.
		/// Оператор UPDATE содержит выражение SET для всех свойств, встретившихся хотя бы у одного объекта
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="disp">диспетчер запросов</param>
		/// <param name="aGroup">список однотипных объектов</param>
		/// <param name="nBatchIndex">Индекс группы типов (для создания уникальных наименования параметров)</param>
		/// <param name="cmdParamFactory">команда, как фабрика параметров</param>
		/// <param name="bSuppressMagicBit">признак того, что надо исключить обработку поля MagicBit</param>
		/// <param name="nTotalUpdateObjects">Общее количество объектов, которые должны быть затронуты update'ом</param>
		/// <returns>заготовка команды с оператором UPDATE всех объектов из списка, либо null</returns>
		protected bool updateSameTypeObjects(XStorageConnection xs, XDbStatementDispatcher disp, IList aGroup, int nBatchIndex, XDbCommand cmdParamFactory, bool bSuppressMagicBit, ref int nTotalUpdateObjects)
		{
			StringBuilder columnBuilder;// построитель текста части update-команды для одной колонки
			StringBuilder cmdBuilder;	// построитель текста одной команды update
			string sPropName;			// наименование свойства, колонки и параметра
			string sParamName;			// наименование параметра команды
			int nIndex;					// индекс объекта
			bool bCmdConstructed;		// признак того, что команда update сформирована
			object vValue;				// значение параметра
			bool bUseParam;				// признак того, что поля (свойства) используются параметры (для float, дат и строк)
			XStorageObjectToSave xobjFirst;			// первый объект из группы однотипных объектов
            List<XDbParameter> aParameters = new List<XDbParameter>();	// коллекция параметров формируемой команды
			bool bNeedUpdateMagicBit;	// признак, что надо апдейтить поле MagicBit
			XPropType vt;				// тип свойства

			if (aGroup.Count==0) return false;
			cmdBuilder = new StringBuilder();
			// возьмем первый объект из группы однотипных для получения метаданных типа
			Debug.Assert(aGroup[0] is XStorageObjectToSave, "В списке aGroup содержаться объекты неподдерживаемого типа");
			xobjFirst = (XStorageObjectToSave)aGroup[0];
			bCmdConstructed = false;
			// начнем формирование команды update текущего типа (таблицы)
			cmdBuilder.AppendFormat("UPDATE {0} SET ", 
				xs.GetTableQName(xobjFirst.SchemaName, xobjFirst.ObjectType) );
	
			#region формирование UPDATE поля ts
			bNeedUpdateMagicBit = false;
			// выражение для update'а ts
			columnBuilder = new StringBuilder();
			columnBuilder.AppendFormat("{1}{0} = CASE{1}", 
				xs.ArrangeSqlName("ts"),		// 0
				xs.Behavior.SqlNewLine );		// 1
			foreach(XStorageObjectToSave xobj in aGroup)
			{
				if (xobj.UpdateTS)
				{
					// надо update'ить ts
					columnBuilder.AppendFormat("WHEN {0}={1} THEN CASE WHEN {2}<{3} THEN {2}+1 ELSE 1 END{4}", 
						xs.ArrangeSqlName("ObjectID"),		// 0
						xs.ArrangeSqlGuid(xobj.ObjectID),	// 1
						xs.ArrangeSqlName("ts"),			// 2
						Int64.MaxValue,						// 3
						xs.Behavior.SqlNewLine );			// 4
					// сами параметры мы добавим потом, когда будем формирвоать WHERE условие
					bCmdConstructed = true;
				}
				if (xobj.ParticipateInUniqueIndex)
					bNeedUpdateMagicBit = true;
			}
			if (bCmdConstructed)
			{
				// если хотя бы для одного объекта надо апдейтить ts, значит добавим апдейт ts в команду
				columnBuilder.AppendFormat("ELSE {0}{1} END ",
					xs.ArrangeSqlName("ts"),	// 0
					xs.Behavior.SqlNewLine);	// 1
				cmdBuilder.Append(columnBuilder.ToString());
			}
			#endregion
	
			#region Формирование UPDATE всех свойств
			// по всем скалярным метасвойствам типа объектов текущей группы (исключая bin и text)
			foreach(XmlElement xmlPropMD in xobjFirst.XmlTypeMD.SelectNodes("ds:prop[@cp='scalar' and @vt!='bin' and @vt!='text']", xs.MetadataManager.NamespaceManager))
			{
				sPropName = xmlPropMD.GetAttribute("n");
				vt = XPropTypeParser.Parse( xmlPropMD.GetAttribute("vt") );
				nIndex = -1;		// сбросим индекс объекта
				// начнем формировать update колонки текущего свойства
				columnBuilder.Length = 0;
				columnBuilder.AppendFormat("{1}{0} = CASE{1}", xs.ArrangeSqlName(sPropName), xs.Behavior.SqlNewLine);
				// признак, что надо формировать команду апдейта для текущего свойства 
				// (будет истинным, если хотя бы у одного объекта в группе присутствует текущее свойство)
				bool bPropNeedUpdate = false;
				// вычислим надо ли использовать ADO-параметры для текущего свойства
				bUseParam = xs.DangerXmlTypes.ContainsKey( vt );
				// по всем объектам текущей группы (типа)
				foreach(XStorageObjectToSave xobj in aGroup)
				{
					++nIndex;
					// если текущее свойство есть, то будем апдейтить, даже если оно пустое
					if (!xobj.Props.Contains(sPropName))
						continue;
					bPropNeedUpdate = true;
					// получим типизированное значение
					vValue = xobj.Props[sPropName];
					xobj.TypeInfo.CheckPropValue(sPropName, vt, vValue);
					
					if (bUseParam) 
					{
						// сформируем имя параметра как: имя_колонки + t + индекс типа + o + индекс объекта.
						sParamName = xs.GetParameterName( String.Format("{0}t{1}o{2}", sPropName, nBatchIndex, nIndex) );
						// в качестве значение идентификатора используем параметр, который мы добавим ниже, при формировании WHERE
						columnBuilder.AppendFormat("WHEN {0}={1} THEN {2}{3}", 
							xs.ArrangeSqlName("ObjectID"),		// 0
							xs.ArrangeSqlGuid(xobj.ObjectID),	// 1
							sParamName,							// 2
							xs.Behavior.SqlNewLine );			// 3
						aParameters.Add( cmdParamFactory.CreateParameter(sParamName, vt, ParameterDirection.Input, true, vValue) );
					}
					else
					{
						// "безопасный" тип свойства - запишем его значение прям в текст запроса
						columnBuilder.AppendFormat("WHEN {0}={1} THEN {2}{3}", 
							xs.ArrangeSqlName("ObjectID"),			// 0
							xs.ArrangeSqlGuid(xobj.ObjectID),		// 1
							xs.ArrangeSqlValue(vValue, vt),			// 2
							xs.Behavior.SqlNewLine );				// 3
					}
				}
				if (bPropNeedUpdate)
				{
					// т.к. мы апдетим текущее свойство не у всех объектов затронутых update'ом, 
					// то обязательно(!): ELSE {имя_свойства} - типа апдейт на себя же.
					columnBuilder.AppendFormat("ELSE {0}{1}END", xs.ArrangeSqlName(sPropName), xs.Behavior.SqlNewLine);
					// если хотя бы у одного объекта текущее свойство присутствует, то 
					// внесем сформированое выражение апдейта текущего свойства в команду
					if (bCmdConstructed)
						cmdBuilder.Append(",");		// текущая колонка уже не первая - добавим запятую
					cmdBuilder.Append(columnBuilder.ToString());
					// раз есть Update хотя бы одной колонки, то считаем текущий Sql оператор сформированным (т.е. он будет выполнен)
					bCmdConstructed = true;
				}
			}
			#endregion
	
			// если в результате обработки всех однотипных объектов текущей группы, выяснилось, что апдейтить нечего
			// (скалярные свойства у них все отсутсвуют и ts апдейтить не надо), то перейдем к следующей группе
			if (!bCmdConstructed)
				return false;
			// Установаим MagicBit в 1 для предотвращения конфликтов со вставляемыми и/или удаляемым записыми
			if (bNeedUpdateMagicBit && !bSuppressMagicBit)
			{
				cmdBuilder.AppendFormat(", {0}=1", xs.ArrangeSqlName("MagicBit") );
				// теперь всем объектам переданной группы установим признак, что MagicBit для них был использован
				foreach(XStorageObjectToSave xobj in aGroup)
					xobj.MagicBitAffected = true;
			}
			cmdBuilder.Append(xs.Behavior.SqlNewLine);

			// сформируем условие WHERE, для каждого объекта добавим условие: (ObjectID={@oid} AND ts={@ts}),
			// однако условие AND ts={@ts} добавим только если у объекта установлен признак AnalizeTS
			cmdBuilder.Append("WHERE ");
			foreach(XStorageObjectToSave xobj in aGroup)
			{
				cmdBuilder.AppendFormat("({0}={1}", 
					xs.ArrangeSqlName("ObjectID"),
					xs.ArrangeSqlGuid(xobj.ObjectID) );
				if (xobj.AnalyzeTS)
				{
					cmdBuilder.AppendFormat(" AND {0}={1}", 
						xs.ArrangeSqlName("ts"),	// 0
						xobj.TS);					// 1
				}
				cmdBuilder.Append(") OR ");
				// увеличим счетчик количества объектов, которые ДОЛЖНЫ быть затронуты апдейтом
				nTotalUpdateObjects++;
			}
			// отрежем последний " OR "
			cmdBuilder.Length -= 4;
			disp.DispatchStatement(cmdBuilder.ToString(), aParameters, true);
			return true;
		}

		/// <summary>
		/// Формирует и возвращает массив команд для UPDATE'а большого количества однотипных объектов (больше значения MaxObjectsPerUpdate)
		/// при том, что в переданном множестве (aGroup) есть хотя бы два объекта со свойствами, участвующими в уникальном индексе.
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="disp">диспетчер запросов</param>
		/// <param name="aGroup">список однотипных объектов</param>
		/// <param name="nBatchIndex">Индекс группы типов (для создания уникальных наименования параметров)</param>
		/// <param name="cmd">команда, как фабрика параметров</param>
		/// <param name="bSuppressMagicBit">признак того, что надо исключить обработку поля MagicBit</param>
		/// <param name="nTotalUpdateObjects">Общее количество объектов, которые должны быть затронуты update'ом</param>
		protected void updateLargeNumberOfSameTypeObjects(XStorageConnection xs, XDbStatementDispatcher disp, ArrayList aGroup, int nBatchIndex, XDbCommand cmd, bool bSuppressMagicBit, ref int nTotalUpdateObjects)
		{
			string sTempTableName;		// наименование временной таблицы
			XStorageObjectToSave xobjFirst;
			int nIndex = 0;

			if (aGroup.Count == 0) return;
			Debug.Assert(aGroup[0] is XStorageObjectToSave, "Объекты в переданном списке aGroup должны быть типа XStorageObjectToSave");
			xobjFirst = (XStorageObjectToSave)aGroup[0];
			// 1. Создать временную таблицу
			// Наименование установим уникальное, т.к. при возникновении ошибок при insert'ах временная таблица не удалится
			sTempTableName = getTempTableName();
			disp.DispatchStatement(getTempTableCreationScript(xs, sTempTableName, xobjFirst.TypeInfo), false);

			// 2. Сформировать insert'ы для каждого объекта в списке
			bool bNeedUpdateMagicBit = false;	// признак, что надо апдейтить поле MagicBit
			foreach(XStorageObjectToSave xobj in aGroup)
			{
				insertObjectIntoTempTable(xs, disp, xobj, sTempTableName, cmd, nBatchIndex, ++nIndex);
				++nTotalUpdateObjects;
				if(bNeedUpdateMagicBit || bSuppressMagicBit) 
					continue;
				if(xobj.ParticipateInUniqueIndex)
					bNeedUpdateMagicBit = true;
			}
			if(bNeedUpdateMagicBit)
				foreach(XStorageObjectToSave xobj in aGroup)
					xobj.MagicBitAffected = true;


			// 3. Сформировать update с join'ом со временной таблицей
			updateWithTempTable(xs, disp, sTempTableName, bSuppressMagicBit, xobjFirst.SchemaName, xobjFirst.ObjectType, xobjFirst.XmlTypeMD);

			// 4. Удалить временную таблицу
			disp.DispatchStatement("DROP TABLE " + sTempTableName , false);
		}

		/// <summary>
		/// Возвращает имя временной таблицы
		/// </summary>
		/// <returns>имя временной таблицы</returns>
		protected virtual string getTempTableName()
		{
			return "tmp" + Guid.NewGuid().ToString("N").ToUpper();
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
		protected abstract string getTempTableCreationScript(XStorageConnection xs, string sTempTableName, XTypeInfo xtype);

		/// <summary>
		/// Создает текст скрипта создания временной таблицы для insert'ов.
		/// Однако возвращаемый скрипт содержит только определение колонок (без скобок и create table..)
		/// Для каждого скалярного свойства в типе определяется две колонки:
		/// c{наименование_свойства} - для хранения нового значения свойства
		/// x{наименование_свойства} - для хранения признака необходимости обновлять свойство (всего типа CHAR(1))
		/// </summary>
		/// <param name="key">метаданные типа - экземпляр XTypeInfo</param>
		/// <param name="param">XStorageConnectioMsSql</param>
		/// <returns>текст скрипта</returns>
		protected object createFieldsListForTempTableCreationScript(object key, object param)
		{
			XTypeInfo xtype = key as XTypeInfo;
			int nLength = 0;
			if (xtype == null)
				throw new ArgumentException("Некорректный ключ, ожидается объект типа XTypeInfo");
			//XmlElement xmlTypeMD = key as XmlElement;
			XStorageConnection xs = param as XStorageConnection;
			Debug.Assert(xs!=null, "Не передан экземпляр XStorageConnection");
			StringBuilder scriptBuilder = new StringBuilder();
			scriptBuilder.Append( 
				xs.ArrangeSqlName("ObjectID") + " " + xs.Behavior.GetSqlType(XPropType.vt_uuid, 0) + " NOT NULL," +
				xs.ArrangeSqlName("ts") + " " + xs.Behavior.TSColumnSqlType + "," +
				xs.ArrangeSqlName("x_ts") + " CHAR(1)"
				);

			// по всем скалярным свойствам, кроме больших. Для каждого свойство сформируем две колонки во
			// временной таблице. Одна со значением, другая - признак, что значение задано (т.е. надо update'ить на это значение)
			foreach(XmlElement xmlPropMD in xtype.Xml.SelectNodes("ds:prop[@cp='scalar' and @vt!='bin' and @vt!='text']", xs.MetadataManager.NamespaceManager))
			{
				XPropInfoBase xprop = xtype.GetProp(xmlPropMD.GetAttribute("n"));
				if (xprop is XPropInfoString)
					nLength = (xprop as XPropInfoString).MaxLength;
				else if (xprop is XPropInfoSmallBin)
					nLength = (xprop as XPropInfoSmallBin).MaxLength;
				
				scriptBuilder.AppendFormat(",{0} {1}, {2} CHAR(1) default '0'",
					xs.ArrangeSqlName("c" + xprop.Name),
					xs.Behavior.GetSqlType( xprop.VarType, nLength),
					xs.ArrangeSqlName("x" + xprop.Name)
					);
			}
			return scriptBuilder.ToString();
		}

		/// <summary>
		/// Процедура должна сформировать UPDATE с использованием данных из временной таблицы
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="disp">XDbStatementDispatcher</param>
		/// <param name="sTempTableName">Имя временной таблице (уже заэнкоженное)</param>
		/// <param name="bUseMagicBit">Признак использование "магического бита"</param>
		/// <param name="sTypeName">Имя типа обновляемой группы объектов</param>
		/// <param name="sSchemaName">Наименование схемы</param>
		/// <param name="xmlTypeMD">Метаданные типа</param>
		protected abstract void updateWithTempTable(XStorageConnection xs, XDbStatementDispatcher disp, string sTempTableName, bool bUseMagicBit, string sSchemaName, string sTypeName, XmlElement xmlTypeMD);

		/// <summary>
		/// Возвращает заготовку команды с оператором INSERT во временную таблицу для переданного ds-объекта
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="xobj">ds-объект</param>
		/// <param name="disp">диспетчер запросов</param>
		/// <param name="sTempTableName">Наименование временной таблицы</param>
		/// <param name="cmd">команда, как фабрика параметров</param>
		/// <param name="nBatchIndex">индекс группы однотипных объектов в общем списке объектов</param>
		/// <param name="nIndex">индекс объекта xobj в группе</param>
		/// <returns>заготовка команды с оператором insert</returns>
		private void insertObjectIntoTempTable(XStorageConnection xs, XDbStatementDispatcher disp, XStorageObjectToSave xobj, string sTempTableName, XDbCommand cmd, int nBatchIndex, int nIndex)
		{
			StringBuilder queryBuilder  = new StringBuilder();	// построитель отдельного insert'a
			StringBuilder valuesBuilder = new StringBuilder();	// построитель списка значений
			string sPropName;			// наименование свойства, колонки и параметра
			string sParamName;			// наименование параметра команды
			object vValue;				// значение свойства

            List<XDbParameter> Params = new List<XDbParameter>();

			queryBuilder.AppendFormat("INSERT INTO {0}({1},{2},{3}",
				sTempTableName,
				xs.ArrangeSqlName("ObjectID"),
				xs.ArrangeSqlName("ts"),
				xs.ArrangeSqlName("x_ts"));
			valuesBuilder.AppendFormat("{0},{1},'{2}'", 
				xs.ArrangeSqlGuid(xobj.ObjectID),
				xobj.AnalyzeTS ? xobj.TS.ToString() : "NULL",
				xobj.UpdateTS ? 1 : 0
				);
			// по всем скалярным свойствам текущего объекта (исключая bin и text)
			foreach(DictionaryEntry entry in xobj.Props)
			{
				// получим наименование текущего свойства
				sPropName = (string)entry.Key;
				XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
				if (!(propInfo is IXPropInfoScalar))
					continue;
				vValue = entry.Value;
				if ((propInfo.VarType == XPropType.vt_text || propInfo.VarType == XPropType.vt_bin) /*&& vValue != DBNull.Value*/)
					continue;
				// в зависимости от типа свойства будем формировать insert-команду.
				// В команду будем добавлять только непустые свойства! Т.е. NULL-значения не вставляем, ибо незачем, а текст короче.
				// все остальные скалярные свойства
				if (vValue != DBNull.Value)
				{
					xobj.TypeInfo.CheckPropValue(sPropName, propInfo.VarType, vValue);
					
					// колонка, соответствующая текущему свойству +
					// специальная колонка, значение 1 в которой говорит о том, что значение колонки свойства изменилось, т.е. его надо апдейтить
					queryBuilder.AppendFormat( ",{0},{1}", 
						xs.ArrangeSqlName("c" + sPropName), 
						xs.ArrangeSqlName("x" + sPropName) );

					valuesBuilder.Append( ',' );
					if(xs.DangerXmlTypes.ContainsKey(propInfo.VarType))
					{
						// Значение колонки свойства
						sParamName = xs.GetParameterName( String.Format("{0}t{1}o{2}", sPropName, nBatchIndex, nIndex) );
						Params.Add( cmd.CreateParameter(sParamName, propInfo.VarType, ParameterDirection.Input, true, vValue) );
						valuesBuilder.Append( sParamName );
					}
					else
					{
						valuesBuilder.Append(xs.ArrangeSqlValue(vValue, propInfo.VarType));
					}
					// значение спец. колонки для свойства, поместим туда 1 как признак того, что колонку свойства надо апдейтить
					valuesBuilder.Append( ",'1'" );
				}
			}	// foreach
			// сформируем команду и добавим ее в общий батч
			queryBuilder.AppendFormat(") values ({0})", valuesBuilder.ToString());
			disp.DispatchStatement(queryBuilder.ToString(),Params, false);
		}

		/// <summary>
		/// Сбрасывает поле MagicBit в 0 для объектов, для которых оно было установлено в 1
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="datagram">Множество обрабатываемых объектов</param>
		/// <param name="bSuppressMagicBitForInsert">признак того, что надо исключить обработку поля MagicBit для вставленных объектов (из списка objSet.ObjectsToInsert)</param>
		/// <param name="bSuppressMagicBitForUpdate">признак того, что надо исключить обработку поля MagicBit для обновленных объектов (из списка objSet.ObjectsToUpdate)</param>
		protected virtual void resetObjectMagicBit(XStorageConnection xs, XDatagram datagram, bool bSuppressMagicBitForInsert, bool bSuppressMagicBitForUpdate)
		{
			ArrayList updatedObjects;	// список объектов XStorageObjectToSave, объединенный из datagram.ObjectsToInsert и datagram.ObjectsToUpdate
			XDbStatementDispatcher disp = xs.CreateStatementDispatcher();

			if (bSuppressMagicBitForInsert && bSuppressMagicBitForUpdate) return;
			StringBuilder queryBuilder = new StringBuilder();
			updatedObjects = new ArrayList();
			if (!bSuppressMagicBitForInsert)
			{
				foreach(XStorageObjectToSave xobj in datagram.ObjectsToInsert)
					if (xobj.MagicBitAffected)
						updatedObjects.Add(xobj);
			}
			if (!bSuppressMagicBitForUpdate)
			{
				foreach(XStorageObjectToSave xobj in datagram.ObjectsToUpdate)
					if (xobj.MagicBitAffected)
						updatedObjects.Add(xobj);
			}
			if (updatedObjects.Count==0) return;
			IEnumerator enumerator = XDatagram.GetEnumerator( updatedObjects );
			while(enumerator.MoveNext())
			{
				ArrayList aObjects = (ArrayList)enumerator.Current;
				Debug.Assert(aObjects.Count>0, "Массив объектов одной группы оказался пуст. Ошибка в энумераторе ObjectSet'a.");

				// позьмем первый объект группы, чтобы получить наименование его типа
				XStorageObjectToSave xobjFirst = (XStorageObjectToSave)aObjects[0];
				queryBuilder.Length=0;
				queryBuilder.AppendFormat("UPDATE {0} SET {1}=0 WHERE {2} IN (",
					xs.GetTableQName(xobjFirst.SchemaName, xobjFirst.ObjectType),	// 0
					xs.ArrangeSqlName( "MagicBit" ),							// 1
					xs.ArrangeSqlName( "ObjectID" )								// 2
					);

				int nStartLen = queryBuilder.Length;
				int nAmount = 0;

				// по всем объектам в группе (т.е. одного типа)
				foreach(XStorageObjectToSave xobj in aObjects)
				{
					if(++nAmount > xs.MaxObjectsPerUpdate)
					{
						// отрежем последнюю запятую
						queryBuilder.Length--;
						queryBuilder.Append(")");
						disp.DispatchStatement(queryBuilder.ToString(), false);
						
						// Сбросим
						queryBuilder.Length = nStartLen;
						nAmount=0;
					}
					queryBuilder.AppendFormat("{0},", xs.ArrangeSqlGuid(xobj.ObjectID) );
				}
				// отрежем последнюю запятую
				queryBuilder.Length--;
				queryBuilder.Append(")");
				disp.DispatchStatement(queryBuilder.ToString(), false);
			}	// while
			disp.ExecutePendingStatementsAndReturnTotalRowsAffected();
		}

		#endregion

		#region Удаление объектов

		/// <summary>
		/// Удаляет объекты из переданного списка. Вызывается из всех публичных методов Delete.
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="aObjectsToDeleteRoot">список удаляемых объектов (типа ObjectToDelete)</param>
		/// <returns>Количество удаленных объектов</returns>
		protected override int internalDeleteObjects(XStorageConnection xs, XStorageObjectToDelete[] aObjectsToDeleteRoot)
		{
			Debug.Assert(aObjectsToDeleteRoot != null, "aObjectsToDeleteRoot не должен быть null");
			if (aObjectsToDeleteRoot.Length==0) return 0;
			Debug.Assert(aObjectsToDeleteRoot[0].GetType() == typeof(XStorageObjectToDelete), "В списке aDelObject должны быть объекты типа ObjectToDelete");
			// список удаляемых объектов (дерево зависимостей) будем хранить в виде хештаблицы, где
			// ключ - ObjectID, значение XStorageObjectToDelete. 
			// Ее же будем использовать для поиска при проставлении ссылок между объектами
            Hashtable aObjectsHash = new Hashtable(aObjectsToDeleteRoot.Length);
			// для каждого корня запустим построение дерева зависимых объектов
			// складывать объекты, образующие дерево зависимости, будем в отдельный список aObjectsHash.
			foreach(XStorageObjectToDelete xobj in aObjectsToDeleteRoot)
				if (!xobj.TypeInfo.IsTemporary)
					buildDependencyTree(xs, xobj, aObjectsHash, true);
			if (aObjectsHash.Count > 1)
			{
				// еще раз пройдем по корневым объектам и зачитаем для каждого объекта его ссылки, 
				// но только в случае, если его тип ссылается на типы других объектов в списке на удаления
				// т.о. исключим лишнее зачитывание ссылок для корневых объектов, если их наличие не может помешать удалению
				foreach(XStorageObjectToDelete xobj in aObjectsToDeleteRoot)
					if (!xobj.TypeInfo.IsTemporary)
					{
						foreach(XStorageObjectToDelete xobjRef in aObjectsHash.Values)
							if (!Object.ReferenceEquals(xobj, xobjRef))
								if (xobj.TypeInfo.ReferenceTo(xobjRef.TypeInfo))
								{
									// тип объекта xobj ссылается на тип объекта xobjRef, следовательно,
									// объект xobj _может_ ссылаться на объект xobjRef
									XDbCommand cmd;				// ADO.NET команда
									cmd = xs.CreateCommand(
										String.Format("SELECT {0}{1} FROM {2} WHERE {3} = {4}",
										xs.ArrangeSqlName("ts"),							// 0
										getFKColumnsList( xs, xobj.XmlTypeMD ),				// 1
										xs.GetTableQName(xobj.SchemaName, xobj.ObjectType),	// 2
										xs.ArrangeSqlName("ObjectID"),						// 3
										xs.GetParameterName( "ObjectID" )					// 4
										)
										);
									cmd.CommandType = CommandType.Text;
									cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
									using(IDataReader reader = cmd.ExecuteReader())
									{
										if(reader.Read())
										{
											// Timestamp=-1 если у нас форсированное удаление, тогда проверять ts не надо.
											if (xobj.TS>-1 && xobj.TS!=reader.GetInt64(0))
											{
												throw new XOutdatedTimestampException(xobj.ObjectType, xobj.ObjectID );
											}
											xobj.ReadObjectDependencesFromDataReader(reader, 1);
										}
										// Если объект пропал, то обрабатывать эту ситуацию будем при выполнении delete'ов
									}
								}
					}
			}
			XDbStatementDispatcher disp = xs.CreateStatementDispatcher();
			if (aObjectsHash.Count==0)
			{
				// удалять нечего
				return 0;
			}
			else if (aObjectsHash.Count == 1)
			{
				// всего один объект, граф-процессор можно не использовать (сортировть не надо, колец быть не может)
				return doDelete(xs, disp, aObjectsHash.Values);
			}
			else
			{
				// проставим связи между объектами в списке на удаление
                List<XStorageObjectBase> aHashList = new List<XStorageObjectBase>();
				foreach(XStorageObjectToDelete xobj in aObjectsHash.Values)
                {
					xobj.InitReferences(aObjectsHash);
                    aHashList.Add(xobj);
                }
                FlowChartProcessor<XStorageObjectBase, XObjectDependency<XStorageObjectBase>> fcp = new FlowChartProcessor<XStorageObjectBase, XObjectDependency<XStorageObjectBase>>(aHashList);
				try
				{
					fcp.Solve(false, new XStorageObjectBase.ComparerByTypeName());
				}
				catch(FlowChartCycleException ex)
				{
					// найдено неразрываемое кольцо в графе
					throw new XCycleReferencingException(ex);
				}
				if (fcp.OriginalReferencesToBreak.Length > 0)
				{
                    foreach (XObjectDependency<XStorageObjectBase> objDep in fcp.OriginalReferencesToBreak)
						disp.DispatchStatement(
							String.Format("UPDATE {0} SET {1} = NULL WHERE {2} = {3}",
							xs.GetTableQName( objDep.ObjectOwner.ObjectType ),	// 0
							xs.ArrangeSqlName( objDep.PropertyInfo.Name ),		// 1
							xs.ArrangeSqlName( "ObjectID" ),					// 2
							xs.ArrangeSqlGuid( objDep.ObjectOwner.ObjectID )	// 3
							),
							false
							);
				}
				tearArrayRefsBetweenObjects(xs, disp, fcp.ObjectList);
				return doDelete(xs, disp, fcp.ObjectList);
			}
		}

		/// <summary>
		/// Выполняет разрыв массивных ссылок между удаляемыми объектами
		/// </summary>
		/// <param name="xs">Реализация XStorageConnection</param>
		/// <param name="disp">диспетчер запросов</param>
		/// <param name="aDelObjectsToDelete">Список объектов на удаление</param>
		protected void tearArrayRefsBetweenObjects(XStorageConnection xs, XDbStatementDispatcher disp, object[] aDelObjectsToDelete)
		{
			XStorageObjectToDelete xobj_ref;
			Debug.Assert(aDelObjectsToDelete != null, "aDelObjectsToDelete == null");
			Debug.Assert(aDelObjectsToDelete.Length > 1, "aDelObjectsToDelete.Length <= 1, не зачем вызывать этот метод");
			// Для каждого объекта из списка:
			// Если в списке существует объект отличный от текущего, ссылающийся на текущий по свойствам вида:
			// массив и коллекция без обратного свойства, то:
			//		удалить записи из кросс-таблицы, соответствующей объектному свойству, по условию Value = OID текущего объекта
			int nObjIndex = -1;		// индекс объекта в списке на удаление
			foreach(XStorageObjectToDelete xobj in aDelObjectsToDelete)
			{
				++nObjIndex;
				if (xobj.TypeInfo.ReferencesOnMe != null)
				{
					// по всем метасвойствам, которые ссылаются _на_ тип текущего объекта
					foreach(XPropInfoObject xprop in xobj.TypeInfo.ReferencesOnMe)
					{
						// если свойство массив или коллекция без обратного свойства,
						// т.е. массивные св-ва участие в которых препятствует удалению объекта
						if (xprop.Capacity == XPropCapacity.Array || 
							xprop.Capacity == XPropCapacity.Collection && xprop.ReverseProp == null)
						{
							// будем искать объекты среди объектов на удаление, которые обладают свойством xprop,
							// но только после текущего объекта (xobj), 
							// т.к. если объекты с массивными свойствами будут в списке перед текущим, 
							// то кросс-таблицы очистятся сами, и дополнительных действий делать не надо
							for(int i=nObjIndex+1; i<aDelObjectsToDelete.Length;++i)
							{
								xobj_ref = (XStorageObjectToDelete)aDelObjectsToDelete[i];
								if (xobj_ref.ObjectType == xprop.ParentType.Name)
								{
									// этот объект _может_ ссылаться, т.к. его тип ссылается на тип текущего объекта.
									// узнать точно, что между объектами есть связь без зачитывания кросс-таблицы мы не можем,
									// поэтому просто очистим кросс-таблицу по ObjectID 
									// (условие по Value можно опустить, т.к. все равно на ObjectID есть каскадное удаление, но раз уж мы удаляем - удалим все сразу):
									string sCrossTableName = xobj_ref.TypeInfo.GetPropCrossTableName(xprop.Name);
									disp.DispatchStatement(
										String.Format("DELETE FROM {0} WHERE {1} = {2}",
										xs.GetTableQName(xobj_ref.SchemaName, sCrossTableName),	// 0
										xs.ArrangeSqlName("ObjectID"),							// 1
										xs.ArrangeSqlGuid(xobj_ref.ObjectID)					// 2
										), false );
								}
							}
						}
					}
				}
			}
		}

		/// <summary>
		/// Строит дерево объектов связанных каскадным удалением начиная с заданного. Вызывает себя рекурсивно
		/// </summary>
		/// <param name="xs"></param>
		/// <param name="xobj">текущий объект</param>
		/// <param name="aObjectsHash">словарь удаляемых объектов, в который добавляются объекты: 
		/// ключ - {ObjectType} + ":" + {ObjectID}, значение - экземпляр ObjectToDelete</param>
		/// <param name="bIsRoot">признак того, что текущий объект корень (true при вызове из internalDeleteObjects, false при рекурсивных вызовах)</param>
		protected virtual void buildDependencyTree(XStorageConnection xs, XStorageObjectToDelete xobj, IDictionary aObjectsHash, bool bIsRoot)
		{
			XmlElement xmlChildObjTypeMD;		// метаданные типа объекта, ссылающегося на текущий
			string sTypeName;					// наименование типа
			string sParamName;					// наименование параметра
			// индексы полей в DataReader'е
			const int IDX_OBJECTID	= 0;		// идентификатор объекта
			const int IDX_TS		= 1;		// ts Объекта
			string sObjectKey = xobj.ObjectType + ":" + xobj.ObjectID;
			// если переданный объект уже есть в списке удаляемых, то на выход
			if (aObjectsHash.Contains(sObjectKey))
				return;
			// добавляем текущий объект в коллекцию удаляемых объектов. 
			aObjectsHash.Add(sObjectKey, xobj);
			// Находим все объекты, которые ссылаются на текущий объект по внешнему ключу с признаком каскадного удаления.
			// Для каждого объекта получаем список объектов, на которые он ссылается (по внешнему ключу с признаком каскадного удаления)
			// И для каждого запускаем рекурсивно себя.
			XmlNodeList lst = xs.MetadataManager.SelectNodes("ds:type/ds:prop[@ot='" + xobj.ObjectType + "' and @vt='object' and @cp='scalar' and @delete-cascade='1']");
			if(lst.Count!=0)
			{
				ArrayList children = new ArrayList();
				using(XDbCommand cmd = xs.CreateCommand())
				{
					sParamName = xs.GetParameterName("p");
					cmd.Parameters.Add(sParamName, DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
					cmd.CommandType = CommandType.Text;

					// сначала все зачитаем, а потом запустим рекурсию, т.к. одновременно на одном коннекшене может быть только один reader
					foreach(XmlElement xmlChildObjPropMD in lst)
					{
						xmlChildObjTypeMD = (XmlElement)xmlChildObjPropMD.ParentNode;
						sTypeName = xmlChildObjTypeMD.GetAttribute("n");
						// Сформируем запрос, который выбирает объекты некоторого типа, ссылающиеся (FK с каскадным удалением) 
						// на текущий объект (obj) по некоторому свойству.
						// Получаем: наименование_типа, идентификатор_объекта, ts  [[,ссылка_на_родительский_объект, наименование_типа_родительского_объекта]...]
						// Примечание: "Родительский объект" - объект, на который ссылается внешний ключ, соответсвующий скалярной ссылке с каскадным удалением.
						cmd.CommandText = 
							"SELECT " + xs.ArrangeSqlName("ObjectID") + ", " + xs.ArrangeSqlName("ts") + getFKColumnsList(xs, xmlChildObjTypeMD) + 
							" FROM " + xs.GetTableQName(sTypeName) +" WHERE " + xs.ArrangeSqlName(xmlChildObjPropMD.GetAttribute("n")) + "=" + sParamName;
						using(IDataReader reader = cmd.ExecuteReader())
						{
							while (reader.Read())
							{
								// Примечание: ObjectID и ts NOT NULL, поэтому IDataReader.IsDbNull перед GetGuid/GetInt64 не вызываем
								XStorageObjectToDelete childObj = new XStorageObjectToDelete( 
									xs.MetadataManager.GetTypeInfo(sTypeName), 
									reader.GetGuid(IDX_OBJECTID),
									reader.GetInt64(IDX_TS),
									false);
								childObj.ReadObjectDependencesFromDataReader(reader, 2);
								children.Add(childObj);
							}
						}
					}
				}
				// теперь для каждого зачитанного ребенка продолжим построение дерева
				foreach(XStorageObjectToDelete childObj in children)
				{
					buildDependencyTree(xs, childObj, aObjectsHash, false);
				}
			}
		}

		/// <summary>
		/// Возвращает строку часть Sql-выражения со списком пар: имя колонки-внешнего ключа, наименование объекта, на который ссылка
		/// Колонки соответствуют свойствам объекта, чье метаописание передано.
		/// </summary>
		/// <param name="xs"></param>
		/// <param name="xmlTypeMD">узле ds:type в МД</param>
		/// <returns></returns>
		protected string getFKColumnsList(XStorageConnection xs, XmlElement xmlTypeMD)
		{
			StringBuilder columnListBuilder;	// построитель списка колонок-внешних ключей зависимого объекта
			columnListBuilder = new StringBuilder();
			// получим список свойств с каскадным удалением того типа, чье свойство ссылающееся на текущий объект мы обрабатываем
			foreach(XmlElement xmlPropMD in xmlTypeMD.SelectNodes("ds:prop[@vt='object' and @cp='scalar']", xs.MetadataManager.NamespaceManager))
			{
				// сформируем список колонок: внешний ключ, наименование типа, на который ссылаемся (это чтобы повторно не перебирать коллекцию свойств)
				columnListBuilder.Append("," + xs.ArrangeSqlName(xmlPropMD.GetAttribute("n")) );
			}
			return columnListBuilder.ToString();
		}


		#endregion
	}
}