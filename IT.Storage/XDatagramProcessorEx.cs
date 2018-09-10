//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
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
		#region ���������� ��������

		public void Save(XStorageConnection xs, XDatagram datagram)
		{
			if (xs == null)
				throw new ArgumentNullException("xs");
			if (datagram == null)
				throw new ArgumentNullException("xobjSet");

			Debug.Assert(datagram.ObjectsToInsert!=null, "������ �������� �� ������� �� ��������� (null)");
			Debug.Assert(datagram.ObjectsToUpdate!=null, "������ �������� �� ���������� �� ��������� (null)");
			Debug.Assert(datagram.ObjectsToDelete!=null, "������ �������� �� �������� �� ��������� (null)");

			if(xs.Transaction==null)
				saveWithoutTransaction(xs, datagram);
			else
				saveWithinTransaction(xs, datagram);
		}

		/// <summary>
		/// ��������� ���������� ��� ���������� ������� ����������, ������� ���������� ������
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="datagram">��������� ��������</param>
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
				// ���� ��������� Dealock, �� �� ����� �������� �������� ����������, �.�. ��� ��� �� ����������
				throw;
			}
			catch
			{
				xs.RollbackTransaction();
				throw;
			}
		}

		/// <summary>
		/// ��������� ���������� � ������ ������� ����������.
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="datagram">��������� ��������</param>
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
				// ���� ��������� Dealock, �� �� ����� �������� �������� ����������, �.�. ��� ��� �� ����������
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
		/// ���������� (�������, ����������, ��������) ��������� ��������
		/// �� ������������� �� �����������, �� savepoint'���.
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="datagram">��������� ��������</param>
		public abstract void DoSave(XStorageConnection xs, XDatagram datagram);

		/// <summary>
		/// ��������� ����� �������
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="disp">��������� ��������</param>
		/// <param name="datagram">��������� �������������� ��������</param>
		/// <param name="bSuppressMagicBit">������� ����, ��� ���� ��������� ��������� ���� MagicBit</param>
		protected virtual void insertObjects(XStorageConnection xs, XDbStatementDispatcher disp, XDatagram datagram, bool bSuppressMagicBit)
		{
			int nIndex;						// ���������� ������ �������
			XDbCommand cmd;					// ������� ��� ������� ��� �������� ����������

			// ������� ������������� ������ ����� �������� ������������� �� ������� �����������
			IList aInsObjects = datagram.ObjectsToInsert;
			if (aInsObjects.Count==0) return;
			nIndex = -1;
			cmd = xs.CreateCommand();
			// ��� ������� ������� �������� ��������� ADO-������� � ���������� insert � ���������� ����������
			foreach(XStorageObjectToSave xobj in aInsObjects)
				insertObject(xs, disp, xobj, cmd, ++nIndex, bSuppressMagicBit);
		}
		
		/// <summary>
		/// ��������� ��������� ������� insert ��� ����������� �������.
		/// ����������� ����� ADO-�������, ��������� � �������������� ������ �������. 
		/// ��� ��������� ��������������� ��� ��� ������� + ������ ������� � ����� ������
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="disp">��������� ��������</param>
		/// <param name="xobj">������, ��� �������� ��������� ������������ insert-�������</param>
		/// <param name="cmd">�������</param>
		/// <param name="nIndex">������ ������� � ������</param>
		/// <param name="bSuppressMagicBit">������� ����, ��� ���� ��������� ��������� ���� MagicBit.
		/// ���� ������� false, �� � ������� insert ����������� ���� MagicBit ��������������� � 1. 
		/// ���� ������� true, �� � ������� insert ���� MagicBit �� ���������.
		/// </param>
		protected void insertObject(XStorageConnection xs, XDbStatementDispatcher disp , XStorageObjectToSave xobj, XDbCommand cmd, int nIndex, bool bSuppressMagicBit)
		{
			StringBuilder queryBuilder  = new StringBuilder();	// ����������� ���������� insert'a
			StringBuilder valuesBuilder = new StringBuilder();	// ����������� ������ ��������
			string sPropName;			// ������������ ��������, ������� � ���������
			string sParamName;			// ������������ ��������� �������
			object vValue;				// �������� ��������

			
            List<XDbParameter> Params = new List<XDbParameter>();
			queryBuilder.AppendFormat("INSERT INTO {0} ({1}, {2}", 
				xs.GetTableQName(xobj.SchemaName, xobj.ObjectType),	// 0
				xs.ArrangeSqlName("ObjectID"),						// 1
				xs.ArrangeSqlName("ts")								// 2
				);
			// ��������� �������� ObjectID, ts (� �������� ts ��������� 1)
			valuesBuilder.Append(xs.ArrangeSqlGuid(xobj.ObjectID) + ",1");
			// ���� �� ���������, �� �������� MagicBit = 1
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
						// ���������� ������������ ��������� (��� ��������) ��� ��� ������� + "o" + ���������� ������
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
			// ���������� ������� � ������� �� � ����� ����
			queryBuilder.AppendFormat(") values ({0})", valuesBuilder.ToString());
			disp.DispatchStatement(queryBuilder.ToString(),Params, false);
		}

		/// <summary>
		/// ��������� ��������� ������� update ��� ����������� �������.
		/// ����������� ����� ADO-�������, ��������� � �������������� ������ �������. 
		/// ��� ��������� ��������������� ��� ��� ������� + "t" +  nBatch + "o" + nIndex
		/// ��� ���� ������� ������������ ��������� (� ������� �� createUpdateCommandForSameTypeObjects).
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="disp">��������� ��������</param>
		/// <param name="xobj">������, ��� �������� ��������� ������������ insert-�������</param>
		/// <param name="nBatchIndex">������ ������ ��������</param>
		/// <param name="nIndex">������ ������� � ������</param>
		/// <param name="cmd">�������, ��� ������� ����������</param>
		/// <param name="bSuppressMagicBit">������� ����, ��� ���� ��������� ��������� ���� MagicBit.
		/// ���� ������� false, �� � ������� insert ����������� ���� MagicBit ��������������� � 1. 
		/// ���� ������� true, �� � ������� insert ���� MagicBit �� ���������.
		/// </param>
		/// <returns>��������� ������� � ���������� UPDATE ���� �������� �� ������, ���� null</returns>
		protected bool updateObject(XStorageConnection xs, XDbStatementDispatcher disp, XStorageObjectToSave xobj, int nBatchIndex, int nIndex, XDbCommand cmd, bool bSuppressMagicBit)
		{
			StringBuilder cmdBuilder;	// ����������� ������ ����� ������� update
			string sPropName;			// ������������ ��������, ������� � ���������
			string sParamName;			// ������������ ��������� �������
			object vValue;				// �������� ��������
            List<XDbParameter> aParameters = new List<XDbParameter>();	// ��������� ���������� ����������� �������
			bool bCmdConstructed=false;	// ������� ����, ��� ������� update ������������

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
					cmdBuilder.Append(",");		// ������� ������� ��� �� ������ - ������� �������
				bCmdConstructed = true;
				xobj.TypeInfo.CheckPropValue(sPropName, propInfo.VarType, vValue);
				sParamName = xs.GetParameterName(String.Format("{0}t{1}o{2}", sPropName, nBatchIndex, nIndex));
				cmdBuilder.Append(xs.ArrangeSqlName(sPropName) + "=" + sParamName + xs.Behavior.SqlNewLine);
				aParameters.Add( cmd.CreateParameter(sParamName, propInfo.VarType, ParameterDirection.Input, true, vValue));
			}

			if (!bCmdConstructed)
				return false ;
			// ���� ������ ��������� � ���������� �������� � ���� ������� � ������� �� ������� �/��� ��������, ��
			// ��������� MagicBit � 1 ��� �������������� ��������� ���������� ��������
			if (!bSuppressMagicBit && xobj.ParticipateInUniqueIndex)
			{
				xobj.MagicBitAffected = true;
				cmdBuilder.AppendFormat(", {0}=1", xs.ArrangeSqlName("MagicBit") );
			}
			// ���������� ������� WHERE: (ObjectID={@oid} AND ts={@ts}),
			// ������ ������� AND ts={@ts} ������� ������ ���� � ������� ���������� ������� AnalizeTS
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
		/// ��������� ������ ���������� � ������ ��������� �������� ����� ��������� ��������� ����������.
		/// ����� ������ ���������� � ������ ��������� ���������� ���������� �������� ����� ���������� �����������
		/// �������� � �� �� ������� � ��������� ����������. ��� ��������, ��� ��������� ������� (�� ������ aUptObjects)
		/// ���� "��������", ���� �������. ������ ����� ��� ��� �������� ��� �������
		/// ������ objects_obsolete � objects_deleted �������� ������� ����� XObjectIdentity.
		/// </summary>
		/// <param name="xs">��������� XStorageConnection</param>
		/// <param name="aUptObjects">������ ����������� ��������</param>
		/// <param name="objects_obsolete">������������ ������ ���������� ��������</param>
		/// <param name="objects_deleted">������������ ������ ��������� ��������</param>
		protected void getOutdatedObjects(XStorageConnection xs, IList aUptObjects, out ArrayList objects_obsolete, out ArrayList objects_deleted)
		{
			XDbCommand cmd;						// �������
			ArrayList objects_notdeleted = new ArrayList();	// ������ �� ��������� ��������
			objects_obsolete = new ArrayList();	// ������ ���������� ��������
			objects_deleted = new ArrayList();	// ������ ��������� ��������
			XStorageObjectToSave xobjFirst;					// ������ ������ ������ ���������� ��������
			// ������ �� ������� ���������� ��������
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
				// ������� ��������� " OR "
				cmdBuilder.Length -= 4;
				// ������� ������ ��������� ��������:
				// ��� ����� ������� ������� ������ ����������� ��������
				objects_notdeleted.Clear();
				cmd = xs.CreateCommand(cmdBuilder.ToString());
				using(IDataReader reader = cmd.ExecuteReader())
				{
					while(reader.Read())
					{
						// ��� �������� 0 ����� ObjectID �������, �� ������ NOT NULL, ������� IsDbNull �� ���������
						objects_notdeleted.Add( new XObjectIdentity(xobjFirst.ObjectType, reader.GetGuid(0), reader.GetInt64(1)) );
					}
				}
				// ������ � ��� ���� ����������� ������ ��������, � ������ ����������� ��������, �� �������� � ����� ������ ��������� ��������
				foreach(XStorageObjectToSave xobj in aGroup)
				{
					// ������ ��� ������
					XObjectIdentity xobjID = new XObjectIdentity(xobj.ObjectType, xobj.ObjectID);
					int nIndex = objects_notdeleted.IndexOf(xobjID);
					// ���� �������� ������� ��� � ������ ����������� ��������, ������ �� ���������
					if (nIndex == -1)
						objects_deleted.Add(xobjID);
						// �����, ���� � ����������� ������� ���������� ts �� ��������, ������ �� ����������
					else if ((objects_notdeleted[nIndex] as XObjectIdentity).TS != xobj.TS && xobj.AnalyzeTS)
						objects_obsolete.Add(xobjID);
				}
			}
		}

		/// <summary>
		/// ��������� �������� � ������� ��������� �������� � ���� �������� 
		/// (�� ������ ����� � ������ ����������� ��������)
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="datagram">��������� �������������� ��������</param>
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
		/// ��������� �������� � ������� ��������� �������� ��� ����������� �������
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="xobj">������, ��� �������� ��������� �������� ������� (�������� � ���������) ��������</param>
		protected virtual void updateBinAndLongDataForObject(XStorageConnection xs, XStorageObjectToSave xobj)
		{
			string sValue;
			// �� ���� ��������� ����� ����������� �������
			foreach(DictionaryEntry entry in xobj.GetPropsByType(XPropType.vt_text))
			{
				// ��������� � NULL ���������� ����� � insert/update'��
				if (entry.Value == DBNull.Value)
					sValue = null;
				else
					sValue = (string)entry.Value;
				xs.SaveTextData(xobj.SchemaName, xobj.ObjectType, xobj.ObjectID, (string)entry.Key, sValue);
			}
			
			byte[] aValue;
			// �� ���� �������� ����� ����������� �������
			foreach(DictionaryEntry entry in xobj.GetPropsByType(XPropType.vt_bin))
			{
				// ��������� � NULL ���������� ����� � insert/update'��
				if (entry.Value == DBNull.Value)
					aValue = null;
				else
					aValue = (byte[])entry.Value;
				xs.SaveBinData(xobj.SchemaName, xobj.ObjectType, xobj.ObjectID, (string)entry.Key, aValue );
			}
		}

		/// <summary>
		/// ��������� ������ ��������, ��������� �� ������
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="disp">��������� ��������</param>
		/// <param name="datagram">��������� �������������� ��������</param>
		protected void purgeLinks(XStorageConnection xs, XDbStatementDispatcher disp, XDatagram datagram)
		{
			StringBuilder queryBuilder;	// ����������� �������
			string sTypeName;		// ������������ ���� ������� ��������� ��������� ��������

			if (datagram.ObjectsToUpdate.Count==0) return;	// ��������� ������
			queryBuilder = new StringBuilder();
			// �� ���� �������� �� ������ �����������
			foreach(XStorageObjectToSave xobj in datagram.ObjectsToUpdate)
			{
				foreach(DictionaryEntry entry in xobj.GetPropsByCapacity(XPropCapacity.Link, XPropCapacity.LinkScalar))
				{
					XPropInfoObject propInfo = (XPropInfoObject)xobj.TypeInfo.GetProp((string)entry.Key);
					Guid[] values = (Guid[])entry.Value;
					queryBuilder.Length=0;
					sTypeName = propInfo.ReferedType.Name;
					// ���� �������� ����������� �� ������� ������ �� ��������� ������������ �������� ��������
					// ��NULL�� ������..
					queryBuilder.AppendFormat(
						"UPDATE {0} SET {1} = NULL, {2} = CASE WHEN {2}<{3} THEN {2}+1 ELSE 1 END {5}WHERE {1}={4} ", 
						xs.GetTableQName(xobj.TypeInfo.Schema, sTypeName),		// 0
						xs.ArrangeSqlName(propInfo.ReverseProp.Name),			// 1
						xs.ArrangeSqlName("ts"),								// 2
						Int64.MaxValue,											// 3
						xs.ArrangeSqlGuid(xobj.ObjectID),						// 4
						xs.Behavior.SqlNewLine									// 5
						);
					// ...��� �������, ��� �������������� ���� �������� �� ��������� � ��������
					if (values.Length > 0 )
					{
						// � ������� ��-�� ���� ������� (�� �������������� � values)
						queryBuilder.AppendFormat("AND NOT {0} IN (", xs.ArrangeSqlName("ObjectID") );
						foreach(Guid value in values)
						{
							queryBuilder.AppendFormat("{0},", xs.ArrangeSqlGuid(value) );
						}
						// ������� ��������� �������
						queryBuilder.Length--;
						queryBuilder.Append(") ");
					}
					// ��� �� �������� �������, �������������� � ������ ���������, 
					// �.�. ��� �������� ����������� ts, � ����������� update ��� �����������, �� � ������ �����������
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
							// ������� ��������� �������
							addWhereBuilder.Length--;
							queryBuilder.AppendFormat( "AND NOT {0} IN ({1}) ", 
								xs.ArrangeSqlName("ObjectID"),	// 0
								addWhereBuilder.ToString()		// 1	
								);
						}
					}
					disp.DispatchStatement(queryBuilder.ToString(),false);
				}	// ����� ����� �� ��������� ������� xobj
			}	// ����� ����� �� �������� �� ������ �����������
		}

		/// <summary>
		/// ��������� �����-������� ��� ��������� ������� (collection, collection-membership, array)
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="datagram">����������</param>
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
		/// ��������� �����-������� ��� ��������� ������� (collection, collection-membership, array) ��������� �������
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="disp">��������� ��������</param>
		/// <param name="xobj">ds-������</param>
		protected void updateCrossTablesForObject(XStorageConnection xs, XDbStatementDispatcher disp, XStorageObjectToSave xobj)
		{
			string sPropName;			// ������������ ��������
			string sDBCrossTableName;	// ������ ������������ �����-�������
			int nIndex;					// �������� ������� k
			string sKeyColumn;			// ������������ ������� ����� �������, �� ������� ����� �������
			string sValueColumn;		// 

			// �� ���� ��������� �������� ������� ����: ������, ���������, �������� � ���������:
			foreach(DictionaryEntry entry in xobj.GetPropsByCapacity(XPropCapacity.Collection, XPropCapacity.Array, XPropCapacity.CollectionMembership))
			{
				sPropName = (string)entry.Key;
				XPropInfoObject propInfo = (XPropInfoObject)xobj.TypeInfo.GetProp(sPropName);
				Debug.Assert(entry.Value is Guid[]);
				Guid[] values = (Guid[])entry.Value;

				// ���������� ������������ �����-������� �� ����, �� �������� ����� ������� �����-�������:
				sDBCrossTableName = xs.GetTableQName(xobj.SchemaName, xobj.TypeInfo.GetPropCrossTableName(sPropName));
				
				// ���������� �������: ������� �� ObjectID � ������� ��� �������� �� ��������
				if (propInfo.Capacity == XPropCapacity.Array)
				{
					StringBuilder cmdBuilder = new StringBuilder();
					// ���� ��������� ������ (array) ������ ������� (���������� ����������), �� DELETE ��������� �� �����
					if (!xobj.IsToInsert)
					{
						// ���������� ����������� �������� delete �� �����-�������:
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
					// ��� ������� �������� ���������� �������� ������� INSERT � �����-�������
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
				// ���������� ��������� � �������� � ���������
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
					// ���������� ����������� �������� delete �� �����-�������:
					StringBuilder cmdBuilder = new StringBuilder();
					cmdBuilder.AppendFormat(
						"DELETE FROM {0} WHERE {1}={2}",
						sDBCrossTableName,					// 0
						xs.ArrangeSqlName(sKeyColumn),		// 1
						xs.ArrangeSqlGuid(xobj.ObjectID)	// 2
						//xs.GetParameterName("ObjectID")		// 2
						);
					// ���� ���� ����� �������� ��������, �� �������� �� �� ��������
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
						// ������ ��������� �������
						cmdBuilder.Length--;
						cmdBuilder.Append(")");
					}
					disp.DispatchStatement(
						cmdBuilder.ToString(), 
						//new XDbParameter[] {xs.CreateCommand().CreateParameter("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID)},
						false 
						);

					// ��� ������� �������� ���������� �������� ������� INSERT � �����-�������
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

		#region �������� ��������

		/// <summary>
		/// �������� ������ �������
		/// </summary>
		/// <param name="xs">XStorage</param>
		/// <param name="xobj">��������� ������</param>
		/// <returns>���������� ��������� ��������</returns>
		public int Delete(XStorageConnection xs, IXObjectIdentity xobj)
		{
			return Delete(xs, new IXObjectIdentity[]{xobj});
		}

		/// <summary>
		/// �������� ��������� ��������
		/// </summary>
		/// <param name="xs">XStorage</param>
		/// <param name="aDelObjects">��������� �������</param>
		/// <returns>���������� ��������� ��������</returns>
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
		/// �������� ��������� ��������, ���������� �������� Delete
		/// </summary>
		/// <param name="xs">XStorage</param>
		/// <param name="aDelObjects">��������� �������</param>
		/// <returns>���������� ��������� ��������</returns>
		protected virtual int deleteObjectsFromDelete(XStorageConnection xs, XStorageObjectToDelete[] aDelObjects)
		{
			return internalDeleteObjects(xs, aDelObjects);
		}

		/// <summary>
		/// �������� ��������� ��������. ���������� � ������ ��������� ����������.
		/// </summary>
		/// <param name="xs">XStorageConnection</param>
		/// <param name="colObjectsToDelete">��������� �������� ��� �������� ����, ������������ �� XObjectBase</param>
		/// <returns>���������� ��������� ��������</returns>
		protected int deleteObjectsFromSaveMethod(XStorageConnection xs, List<object> colObjectsToDelete)
		{
			XStorageObjectToDelete[] aDelObjectsToDelete = new XStorageObjectToDelete[colObjectsToDelete.Count];
			colObjectsToDelete.CopyTo(aDelObjectsToDelete);
			return internalDeleteObjects(xs, aDelObjectsToDelete);
		}

		/// <summary>
		/// ������� ������� �� ����������� ������. ���������� �� ���� ��������� ������� Delete � ������ Save
		/// </summary>
		/// <param name="aObjectsToDeleteRoot">������ ��������� �������� (���� ObjectToDelete)</param>
		/// <param name="xs">��������� XStorageConection</param>
		/// <returns>���������� ��������� ��������</returns>
		protected virtual int internalDeleteObjects(XStorageConnection xs, XStorageObjectToDelete[] aObjectsToDeleteRoot)
		{
			return doDelete(xs, xs.CreateStatementDispatcher(), aObjectsToDeleteRoot);
		}

		/// <summary>
		/// ��������� �������� � �� �������� � ������ � ������� �� ���������� � ���
		/// </summary>
		/// <param name="xs">��������� XStorageConection</param>
		/// <param name="disp">��������� ��������</param>
		/// <param name="aDelObjects">������ �������� (���� ObjectToDelete), ��� ������� ���� ��������� delete � ��</param>
		protected virtual int doDelete(XStorageConnection xs, XDbStatementDispatcher disp, ICollection aDelObjects)
		{
			int nRowsAffected = 0;						// ���������� ��������� �������
			bool bForcedMode = false;					// ������� �������������� �������� (���� ���� �� ���� ������ � ���������� ts)
			string sTypeNamePrev = String.Empty;		// ������������ ���� ����������� ������� (� �����)
			StringBuilder queryTextBuilder = new StringBuilder();	// ����������� ��������� delete


			if(aDelObjects.Count==0) return 0;
			foreach(XStorageObjectToDelete obj in aDelObjects)
			{
				if (obj.TS == -1)
					bForcedMode = true;
				if (sTypeNamePrev != obj.ObjectType)
				{
					// ������ ������ ���� (� �.�. ������)
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
					// ���� ��� ������� ����� TS, ������� ������� �� ����
					if (obj.AnalyzeTS)
						queryTextBuilder.AppendFormat(" AND {0}={1}",
							xs.ArrangeSqlName("ts"),
							obj.TS
							);
				}
				else
				{
					// ��� ���� ������ ���� �� ����
					queryTextBuilder.AppendFormat( " OR {0}={1}", 
						xs.ArrangeSqlName( "ObjectID" ),	// 0
						xs.ArrangeSqlGuid( obj.ObjectID )	// 1
						);
					// ���� ��� ������� ����� TS, ������� ������� �� ����
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
					// ���������� ��������� �������� �� ��������� � ��������� ���-���.
					// ���� � �� ������� ���� �� ���� ������ �� ���, ������� �� �������, ��
					// ��� ��������, ��� � ���� "�������" ts, ������������� ����� ��������.
					// ����� (� �� ��� �������� ������ �� ���, ������� �� �������) ��� ������, ������
					// ��� ���-�� ��������, �� ������� ��������� - ��� ��������� ������� �������.
					sTypeNamePrev = String.Empty;
					queryTextBuilder = new StringBuilder();
					XDbCommand cmd = xs.CreateCommand();
					cmd.CommandType = CommandType.Text;
					foreach(XStorageObjectToDelete obj in aDelObjects)
					{
						if (sTypeNamePrev != obj.ObjectType)
						{
							// ������ ������ ���� (� �.�. ������)
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
							// ��� ���� ������ ���� �� ����
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
