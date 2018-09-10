//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Data;
using System.Text;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Core.Triggers
{
	/// <summary>
	/// Базовый класс для триггеров на Папку (Folder)
	/// </summary>
	abstract class FolderTriggerBase: XTrigger
	{
		protected DomainObjectData getFolderHistoryObject(DomainObjectDataSet dataSet, DomainObjectData xobjFolder)
		{
			DomainObjectData xobjHistory = dataSet.CreateNew("FolderHistory", true);
			xobjHistory.SetUpdatedPropValue("Folder", xobjFolder.ObjectID);
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			xobjHistory.SetUpdatedPropValue("SystemUser", user.SystemUserID);
			xobjHistory.SetUpdatedPropValue("EventDate", DateTime.Now);
			return xobjHistory;
		}
	}
									  
	/// <summary>
	/// Триггер на изменение состояния папки
	/// </summary>
	class Folder_TrackChangeState: FolderTriggerBase
	{
		public override void Execute(XTriggerArgs args, Croc.XmlFramework.Core.IXExecutionContext context)
		{
			DomainObjectData xobj = args.TriggeredObject;
			bool bUpdatedState = xobj.HasUpdatedProp("State");
			bool bUpdateIsLocked =  xobj.HasUpdatedProp("IsLocked");
			if (!bUpdatedState && !bUpdateIsLocked)
				return;
			// если здесь значит изменилось хотя бы одно из полей: Состояние (State), Дата блокирования списаний (BlockDate)
			// Теперь надо зачитать предыдущие значения из БД, но только тех свойств, которые обновляются
			preloadProps(xobj, bUpdatedState, bUpdateIsLocked, context);
			if( bUpdateIsLocked)
			{
				bool oldValue = (bool)xobj.GetLoadedPropValue("IsLocked");
				bool newValue = (bool)xobj.GetUpdatedPropValue("IsLocked");
				if(oldValue!=newValue)
				{
					// изменение признака допустимости списания
					DomainObjectData xobjHistory = getFolderHistoryObject(args.DataSet, xobj);
					xobjHistory.SetUpdatedPropValue("Event", newValue?FolderHistoryEvents.IsLockedSetToTrue:FolderHistoryEvents.IsLockedSetToFalse);

				}
			}

			if (bUpdatedState)
			{
				FolderStates stateOld = (FolderStates)xobj.GetLoadedPropValue("State");
				FolderStates stateNew = (FolderStates)xobj.GetUpdatedPropValue("State");
				if (stateOld != stateNew)
				{
					// состояние изменилось 
					//	- проверим на запрещенные переходы
					checkFolderStateChanging(stateOld, stateNew);
					DomainObjectData xobjHistory = getFolderHistoryObject(args.DataSet, xobj);
					FolderHistoryEvents eventType;
					if (stateNew == FolderStates.Closed)
						eventType = FolderHistoryEvents.Closing;
					else if (stateNew == FolderStates.Frozen)
						eventType = FolderHistoryEvents.Frozing;
					else if (stateNew == FolderStates.WaitingToClose)
						eventType = FolderHistoryEvents.WaitingToClose;
					else	// if (stateNew == FolderStates.Open)
						eventType = FolderHistoryEvents.Opening;
					xobjHistory.SetUpdatedPropValue("Event", eventType);

					// обработаем переход в состояние "Закрыто":
					if (!xobj.IsNew && (stateNew == FolderStates.Closed || stateNew == FolderStates.WaitingToClose))
					{
						//	1. Проверим, что все инциденты (во всех вложенных папках) находятся в конечных состояниях
						XDbCommand cmd = context.Connection.CreateCommand(@"
							SELECT 1 
							FROM Folder f_s WITH(NOLOCK)
								JOIN Folder f WITH(NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer
									JOIN Incident i WITH(NOLOCK) ON f.ObjectID = i.Folder
										JOIN IncidentState i_st WITH(NOLOCK) ON i.State = i_st.ObjectID AND i_st.Category IN (1,2)	
							WHERE f_s.ObjectID = @ObjectID
							");
						cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
						if (cmd.ExecuteScalar() != null)
							throw new XBusinessLogicException("Папка не может быть переведена в состояние \"Закрыто\" или \"Ожидание закрытия\", так как содержит незавершенные инциденты");
                   	}

					// добавим в датаграмму подчиненные папки с установленным состоянием новым состояние
					// Обработка папок зависит от нового состояния
					fillDataSetWithChildFoldersWithUpdatedState(context.Connection, args.DataSet, xobj.ObjectID, stateNew);
				}
			}
		}

		/// <summary>
		/// Загружает поля State, BlockDate в случае, если они еще не загружены и если они обновлялись.
		/// </summary>
		/// <param name="xobj"></param>
		/// <param name="bUpdatedState">Признак обновления поля State</param>
		/// <param name="bUpdatedBlockDate">Признак обновления поля BlockDate</param>
		/// <param name="context"></param>
		private void preloadProps(DomainObjectData xobj, bool bUpdatedState, bool bUpdateIsLocked, IXExecutionContext context)
		{
			bool bLoadState = bUpdatedState && !xobj.HasLoadedProp("State");
			bool bLoadIsLocked = bUpdateIsLocked && !xobj.HasLoadedProp("IsLocked");
	
			// если надо зачитать хотя бы одно свойство
			if (bLoadState ||  bLoadIsLocked)
			{
				XDbCommand cmd = context.Connection.CreateCommand();
				StringBuilder cmdTextBuilder = new StringBuilder();
				cmdTextBuilder.Append("SELECT ");
				if (bLoadState)
					cmdTextBuilder.Append("[State]");
			    if(bLoadIsLocked)
				{
					if (bLoadState)
						cmdTextBuilder.Append(", ");
					cmdTextBuilder.Append("[IsLocked]");

				}
				cmdTextBuilder.Append(" FROM ");
				cmdTextBuilder.Append(context.Connection.GetTableQName(xobj.TypeInfo));
				cmdTextBuilder.Append(" WHERE ObjectID = @ObjectID");
				cmd.CommandText = cmdTextBuilder.ToString();
				cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
				using(IXDataReader reader = cmd.ExecuteXReader())
				{
					if (reader.Read())
					{
						if (bLoadState)
							xobj.SetLoadedPropValue("State", reader.GetInt16( reader.GetOrdinal("State") ));
						if (bLoadIsLocked)
							xobj.SetLoadedPropValue("IsLocked", reader.GetBoolean( reader.GetOrdinal("IsLocked"))) ;

					}
				}
			}
		}

		private void checkFolderStateChanging(FolderStates stateOld, FolderStates stateNew)
		{
			// TODO: требуется уточнение графа переходов состояний Папки
			if (stateOld == FolderStates.Frozen && stateNew != FolderStates.Open && stateNew != FolderStates.WaitingToClose)
				throw new XBusinessLogicException("Папка из состояния \"" + FolderStatesItem.Frozen.Description + "\" может перейти только в состояния \"" + FolderStatesItem.Open.Description + "\" или \"" + FolderStatesItem.WaitingToClose.Description + "\"");
			if (stateNew == FolderStates.Frozen && stateOld != FolderStates.Open && stateOld != FolderStates.WaitingToClose)
				throw new XBusinessLogicException("В состояние \"" + FolderStatesItem.Frozen.Description + "\" папка может перейти только из состояний \"" + FolderStatesItem.Open.Description + "\" или \"" + FolderStatesItem.WaitingToClose.Description + "\"");
		}

		private void fillDataSetWithChildFoldersWithUpdatedState(XStorageConnection con, DomainObjectDataSet dataSet, Guid objectID, FolderStates folderState)
		{
			// зачитаем идентификаторы всех подчиненных папок, состояние которых отличается от требуемого
			XDbCommand cmd = con.CreateCommand(@"
				SELECT f.ObjectID
				FROM Folder f_s WITH(NOLOCK)
					JOIN Folder f  WITH(NOLOCK) ON f.LIndex > f_s.LIndex AND f.RIndex < f_s.RIndex AND f.Customer = f_s.Customer
				WHERE f_s.ObjectID = @ObjectID AND f.State <> @TargetState
				");
			// закрытие закрывает все вложенные папки без учета их состояния:
			// if (folderState == FolderStates.Closed) - Nothing to do

			// замораживание замораживает открытые и ожидающие закрытия
			if (folderState == FolderStates.Frozen)
				cmd.CommandText = cmd.CommandText + " AND f.State IN (" + FolderStatesItem.Open.IntValue + "," + FolderStatesItem.WaitingToClose.IntValue + ")";
			// перевод в "ожидание закрытие" применим только для открытых (т.е. замороженные и закрытые не трогаются)
			//else if (folderState == FolderStates.WaitingToClose)
				//cmd.CommandText = cmd.CommandText + " AND f.State = " + FolderStatesItem.Open.IntValue;

			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, objectID);
			cmd.Parameters.Add("TargetState", DbType.Int16, ParameterDirection.Input, false, (Int16)folderState);
			using(IDataReader reader = cmd.ExecuteReader())
			{
				DomainObjectData xobjSubFolder;
				while(reader.Read())
				{
					xobjSubFolder = dataSet.GetLoadedStub("Folder", reader.GetGuid(0));
					xobjSubFolder.SetUpdatedPropValue("State", folderState);
				}
			}
		}
	}
}