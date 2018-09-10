//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
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
	/// ������� ����� ��� ��������� �� ����� (Folder)
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
	/// ������� �� ��������� ��������� �����
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
			// ���� ����� ������ ���������� ���� �� ���� �� �����: ��������� (State), ���� ������������ �������� (BlockDate)
			// ������ ���� �������� ���������� �������� �� ��, �� ������ ��� �������, ������� �����������
			preloadProps(xobj, bUpdatedState, bUpdateIsLocked, context);
			if( bUpdateIsLocked)
			{
				bool oldValue = (bool)xobj.GetLoadedPropValue("IsLocked");
				bool newValue = (bool)xobj.GetUpdatedPropValue("IsLocked");
				if(oldValue!=newValue)
				{
					// ��������� �������� ������������ ��������
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
					// ��������� ���������� 
					//	- �������� �� ����������� ��������
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

					// ���������� ������� � ��������� "�������":
					if (!xobj.IsNew && (stateNew == FolderStates.Closed || stateNew == FolderStates.WaitingToClose))
					{
						//	1. ��������, ��� ��� ��������� (�� ���� ��������� ������) ��������� � �������� ����������
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
							throw new XBusinessLogicException("����� �� ����� ���� ���������� � ��������� \"�������\" ��� \"�������� ��������\", ��� ��� �������� ������������� ���������");
                   	}

					// ������� � ���������� ����������� ����� � ������������� ���������� ����� ���������
					// ��������� ����� ������� �� ������ ���������
					fillDataSetWithChildFoldersWithUpdatedState(context.Connection, args.DataSet, xobj.ObjectID, stateNew);
				}
			}
		}

		/// <summary>
		/// ��������� ���� State, BlockDate � ������, ���� ��� ��� �� ��������� � ���� ��� �����������.
		/// </summary>
		/// <param name="xobj"></param>
		/// <param name="bUpdatedState">������� ���������� ���� State</param>
		/// <param name="bUpdatedBlockDate">������� ���������� ���� BlockDate</param>
		/// <param name="context"></param>
		private void preloadProps(DomainObjectData xobj, bool bUpdatedState, bool bUpdateIsLocked, IXExecutionContext context)
		{
			bool bLoadState = bUpdatedState && !xobj.HasLoadedProp("State");
			bool bLoadIsLocked = bUpdateIsLocked && !xobj.HasLoadedProp("IsLocked");
	
			// ���� ���� �������� ���� �� ���� ��������
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
			// TODO: ��������� ��������� ����� ��������� ��������� �����
			if (stateOld == FolderStates.Frozen && stateNew != FolderStates.Open && stateNew != FolderStates.WaitingToClose)
				throw new XBusinessLogicException("����� �� ��������� \"" + FolderStatesItem.Frozen.Description + "\" ����� ������� ������ � ��������� \"" + FolderStatesItem.Open.Description + "\" ��� \"" + FolderStatesItem.WaitingToClose.Description + "\"");
			if (stateNew == FolderStates.Frozen && stateOld != FolderStates.Open && stateOld != FolderStates.WaitingToClose)
				throw new XBusinessLogicException("� ��������� \"" + FolderStatesItem.Frozen.Description + "\" ����� ����� ������� ������ �� ��������� \"" + FolderStatesItem.Open.Description + "\" ��� \"" + FolderStatesItem.WaitingToClose.Description + "\"");
		}

		private void fillDataSetWithChildFoldersWithUpdatedState(XStorageConnection con, DomainObjectDataSet dataSet, Guid objectID, FolderStates folderState)
		{
			// �������� �������������� ���� ����������� �����, ��������� ������� ���������� �� ����������
			XDbCommand cmd = con.CreateCommand(@"
				SELECT f.ObjectID
				FROM Folder f_s WITH(NOLOCK)
					JOIN Folder f  WITH(NOLOCK) ON f.LIndex > f_s.LIndex AND f.RIndex < f_s.RIndex AND f.Customer = f_s.Customer
				WHERE f_s.ObjectID = @ObjectID AND f.State <> @TargetState
				");
			// �������� ��������� ��� ��������� ����� ��� ����� �� ���������:
			// if (folderState == FolderStates.Closed) - Nothing to do

			// ������������� ������������ �������� � ��������� ��������
			if (folderState == FolderStates.Frozen)
				cmd.CommandText = cmd.CommandText + " AND f.State IN (" + FolderStatesItem.Open.IntValue + "," + FolderStatesItem.WaitingToClose.IntValue + ")";
			// ������� � "�������� ��������" �������� ������ ��� �������� (�.�. ������������ � �������� �� ���������)
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