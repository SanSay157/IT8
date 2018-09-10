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
	/// ���������� XDatagramProcessor ��� RDBMS �� �������������� DEFERED CONSTRAINTS.
	/// </summary>
	public abstract class XDatagramProcessorForNonDeferrableDbEx: XDatagramProcessorEx
	{
		/// <summary>
		/// ������� ��� �������� � ����� cacheTempTableCreationScripts.GetValue
		/// </summary>
		protected XThreadSafeCacheCreateValue<object,object> dlgCreateTempTableCreationScript;

		/// <summary>
		/// �������� �����������
		/// </summary>
		protected XDatagramProcessorForNonDeferrableDbEx()
		{
			// �������������� ������� ��� ������ ��������� ������� �������� ��������� ������� ��� ��������.
			// ������ ������� ����� ������������ ��� �������� � ������ cacheTempTableCreationScripts
            dlgCreateTempTableCreationScript = new XThreadSafeCacheCreateValue<object, object>(createFieldsListForTempTableCreationScript);
		} 

		#region ���������� ��������

		/// <summary>
		/// ���������� (�������, ����������, ��������) ��������� ��������
		/// �� ������������� �� �����������, �� savepoint'���.
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="datagram">��������� ��������</param>
		public override void DoSave(XStorageConnection xs, XDatagram datagram)
		{
			preProcessDatagram(xs, datagram);
			// ������� ����� ������� (��� ���������, �������� � ������� ��������� �������). 
			// ���� ����������� �������� ���� MagicBit ������������� � 1, ����� ������, �����
			// � ��� ��� �������� ���������� ���������� � ��������.
			bool bSuppressMagicBitForInsert = (datagram.ObjectsToDelete.Count + datagram.ObjectsToUpdate.Count)==0;

			XDbStatementDispatcher disp = xs.CreateStatementDispatcher();
			insertObjects(xs, disp, datagram, bSuppressMagicBitForInsert);
			// ���� ��������� ������, �� �������� ������������ ���� �����
			if (datagram.ObjectsToUpdate.Count==0)
				disp.ExecutePendingStatementsAndReturnTotalRowsAffected();
			// �������� ������� ������������� Magicbit'a ��� ����������� ��������
			bool bSuppressMagicBitForUpdate = (datagram.ObjectsToDelete.Count==0);
			// ������� ������������ ������� (��� ���������, �������� � ������� ��������� �������)
			updateObjects(xs, disp, datagram, bSuppressMagicBitForUpdate);
			// ������� ��������� �������� (��������� � �������)
			updateCrossTables(xs, datagram);
			// ������� �������� � ������� ��������� ��������
			updateBinAndLongData(xs, datagram);
			// ������ ������� ���������� � ��������
			deleteObjectsFromSaveMethod(xs, datagram.ObjectsToDelete);
			// ������� ���� MagicBit � 0 ���� �����������/����������� ����� ��������, ���� �� ��� ������������� � 1
			resetObjectMagicBit(xs, datagram, bSuppressMagicBitForInsert, bSuppressMagicBitForUpdate);
		}

		/// <summary>
		/// ������������ XDatagram ����� �����������
		/// </summary>
		/// <param name="xs"></param>
		/// <param name="datagram"></param>
		protected void preProcessDatagram(XStorageConnection xs, XDatagram datagram)
		{
			if (datagram.ObjectsToInsert.Count > 1)
			{
				foreach(XStorageObjectBase xobj in datagram.ObjectsToInsert)
					xobj.InitReferences(datagram.ObjectsToInsertDictionary);
				// �������� � �������� ����-��������� ��� ��������� �������������� ������ �������� � ������ �����
                FlowChartProcessor<XStorageObjectBase, XObjectDependency<XStorageObjectBase>> fcp = new FlowChartProcessor<XStorageObjectBase, XObjectDependency<XStorageObjectBase>>(datagram.ObjectsToInsert);
			
                try
				{
					// true - ������ ������� ���� �������, ������� �� ������� �� ������ ��������
					fcp.Solve(true);
				}
				catch(FlowChartCycleException ex)
				{
					// ������� ������������� ������ � �����
					throw new XCycleReferencingException(ex);
				}
				if (fcp.OriginalReferencesToBreak.Length > 0)
				{
					// ������� ����������� ������ � ����� 
					// - ��� ������ ������ � ������ ����������� ������ ���������� ������ � ��������� ��� � ������ �� ����������
                    foreach (XObjectDependency<XStorageObjectBase> dep in fcp.OriginalReferencesToBreak)
					{
						XStorageObjectToSave xobjNew = detachObjectWithRingReference(xs, dep);
						Debug.Assert(xobjNew!=null, "detachObjectForUpdate ������� null");
						// ������� ������ � ������ ����������� ��������. ���� �� ��� ��� ����, �������� �������
						datagram.AddUpdated( xobjNew  );
					}
				}
				// ������������� ������ ����������� �������� �������� ��������, ��������������� ����-����������� � ������� �����������
				datagram.ObjectsToInsert.Clear();
				datagram.ObjectsToInsert.AddRange(fcp.ObjectList);
			}
			//	������ ����������� �������� ����������� �� ���� � ��������������
			if (datagram.ObjectsToUpdate.Count > 0)
				datagram.ObjectsToUpdate.Sort( XObjectComparerByTypeAndObjectID<XStorageObjectBase>.Instance );
		}

		/// <summary>
		/// ������� ������ ��� ����������� ����������, �������� � ���� ��������, ��������������� ������,
		/// ������� ����-��������� ������ ��� ������� ������.
		/// </summary>
		/// <param name="xs">XStorage</param>
		/// <param name="dep">������</param>
		/// <returns>������ � ������������ ���������, ��� ��������� � ������ ����������� ��������</returns>
        protected XStorageObjectToSave detachObjectWithRingReference(XStorageConnection xs, XObjectDependency<XStorageObjectBase> dep)
		{
			XStorageObjectToSave xobjOwner;		// ������-�������� ������
			XStorageObjectToSave xobjDetached;	//

			xobjOwner = (XStorageObjectToSave)dep.ObjectOwner;
			// �������� ����� �������-��������� ������
			xobjDetached = new XStorageObjectToSave(xobjOwner.TypeInfo, xobjOwner.ObjectID, -1, false);
			// ��������� �������� �� �������-��������� ������ � ��� �����
			xobjDetached.Props.Add( dep.PropertyInfo.Name, xobjOwner.Props[dep.PropertyInfo.Name] );
			xobjOwner.Props.Remove(dep.PropertyInfo.Name);
			// �.�. ��������� ������ �������� ������ �������� ��� ����������� ����������
			// �� ������������� � ���������������� ts �� ����!
			xobjDetached.UpdateTS = false;
			return xobjDetached;
		}

		/// <summary>
		/// ��������� ������������ �������
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="disp">��������� ��������</param>
		/// <param name="datagram">��������� �������������� ��������</param>
		/// <param name="bSuppressMagicBit">������� ����, ��� ���� ��������� ��������� ���� MagicBit</param>
		protected virtual void updateObjects(XStorageConnection xs, XDbStatementDispatcher disp, XDatagram datagram, bool bSuppressMagicBit)
		{
			const string SAVEPOINT = "SP_XS_UPDATE";
			IList aUptObject;			// ��������������� ������ �������� ���������� ����������
			int nBatchIndex=0;			// ������ ����
			XDbCommand cmd;				// ������� � ������ update'��
			int nAffectedRows;			// ���������� ����������� �������
			int nTotalUpdateObjects=0;	// ����� ���������� ��������, ��� ������� ������ update � ��
			bool bAlgorithmFound;		// ������� ����, ��� �������� ������
			bool bSavePointSet;			// ������� ����, ��� ��� ���������� SAVEPOINT ����������

			// ������� ������ �������� ��� ����������, ��������������� �� ���� � ��������������
			aUptObject = datagram.ObjectsToUpdate;
			if (aUptObject.Count==0) return;	// ��������� ������
			// �������� SAVEPOINT, ����� � ���� ��������� � ������, 
			// ���� ���������� ����������� ������� �� ��������� � ��������� �����������
			bSavePointSet = xs.IsSavePointAllowed;
			if (bSavePointSet)
				disp.DispatchStatement(xs.Behavior.GetSavePointExpr(SAVEPOINT), false);

			cmd = xs.CreateCommand();
			// ������ �� ������� ���������� ��������
			IEnumerator enumerator = XDatagram.GetEnumerator(aUptObject);
			while(enumerator.MoveNext())
			{
				++nBatchIndex;		// ������ ������, �.�. ����
				// ������� ������ �������� ������ ����
				ArrayList aGroup = (ArrayList)enumerator.Current;
				Debug.Assert( aGroup!=null, "XObjectGroupedByTypeEnumerator.Current ������ null", "������ � MoveNext");
				Debug.Assert( aGroup.Count>0, "XObjectGroupedByTypeEnumerator ������ ������ ������ ��������", "������ � MoveNext");
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
					// ���� � ������� ���� ���� ���������� ������� � ���� �� � ���� �������� ���� ��������,
					// ����������� � ���������� �������, �� ������� ����������� �������, ������� ������ 
					// ������������ ������� ��� ������ ������.
					if ((aGroup[0] as XStorageObjectToSave).TypeInfo.HasUniqueIndexes)
					{
						// � ������� ���� ���� ���������� �������..
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
						// ���� �� ��� ������� � ������� ��������� ���������� �������� ����������� ���������� ������,
						// ��� ��������, ��� � ����� ������ ������ ������������ ��������� ����������� update'��, 
						// �.�. ��� ����� �������� � ��������� ���������� ��������. ������������ ���� ������� UPDATE
						// ��� �� ��������� ����������� �� ���������� �������� � ����� ��������� update,������� ���� 
						// ���������.
						// ���������� ������� ������ �������� ��������� �� ���������� ���������� ���������� XStorageConnection.
						updateLargeNumberOfSameTypeObjects(xs, disp, aGroup, nBatchIndex, cmd, bSuppressMagicBit, ref nTotalUpdateObjects);
					}
					else
					{
						// ��� ������� ��������� ���������� �������� (aGroup) �� ����������� �������� ����������� �������,
						// (���� ����� ���� ���� ������ ����� ��-��, ����������� � �������)
						// ������� ��� ������� ������� ����� ������������ ��������� �������� UPDATE (�� �������� � INSERT'���)
						int nIndex = 0;
						foreach(XStorageObjectToSave  xobj in aGroup)
						{
							if (updateObject(xs, disp, xobj, nBatchIndex, ++nIndex, cmd, bSuppressMagicBit))
								++nTotalUpdateObjects;
						}
					}
				}
			}

			// ��������� ������ ��������, ��������� �� ������
			purgeLinks(xs, disp, datagram);

			nAffectedRows = disp.ExecutePendingStatementsAndReturnTotalRowsAffected();
			if (nAffectedRows != nTotalUpdateObjects)
			{
				#region �������� ������������ ����������
				if (!bSavePointSet)
					throw new XOutdatedTimestampException();
				else
				{
					// ��� ���������� SAVEPOINT, ��������� � ����
					xs.CreateCommand( xs.Behavior.GetRollbackToSavePointExpr(SAVEPOINT) ).ExecuteNonQuery();
					ArrayList objects_obsolete;		// ������ ���������� ��������
					ArrayList objects_deleted;		// ������ ��������� ��������
					getOutdatedObjects(xs, aUptObject, out objects_obsolete, out objects_deleted);
					Debug.Assert(objects_obsolete.Count + objects_deleted.Count > 0, "nAffectedRows != nTotalUpdateObjects, ������ ���������� �/��� ��������� ������� �� �������");
					throw new XOutdatedTimestampException();
				}
				#endregion
			}
		}

		/// <summary>
		/// ������� � ���������� ��������� ������� � ����� ���������� UPDATE ��� ���� �������� � ������ aGroup.
		/// ������� � ������ ������ ���� ������ ����.
		/// �������� UPDATE �������� ��������� SET ��� ���� �������, ������������� ���� �� � ������ �������
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="disp">��������� ��������</param>
		/// <param name="aGroup">������ ���������� ��������</param>
		/// <param name="nBatchIndex">������ ������ ����� (��� �������� ���������� ������������ ����������)</param>
		/// <param name="cmdParamFactory">�������, ��� ������� ����������</param>
		/// <param name="bSuppressMagicBit">������� ����, ��� ���� ��������� ��������� ���� MagicBit</param>
		/// <param name="nTotalUpdateObjects">����� ���������� ��������, ������� ������ ���� ��������� update'��</param>
		/// <returns>��������� ������� � ���������� UPDATE ���� �������� �� ������, ���� null</returns>
		protected bool updateSameTypeObjects(XStorageConnection xs, XDbStatementDispatcher disp, IList aGroup, int nBatchIndex, XDbCommand cmdParamFactory, bool bSuppressMagicBit, ref int nTotalUpdateObjects)
		{
			StringBuilder columnBuilder;// ����������� ������ ����� update-������� ��� ����� �������
			StringBuilder cmdBuilder;	// ����������� ������ ����� ������� update
			string sPropName;			// ������������ ��������, ������� � ���������
			string sParamName;			// ������������ ��������� �������
			int nIndex;					// ������ �������
			bool bCmdConstructed;		// ������� ����, ��� ������� update ������������
			object vValue;				// �������� ���������
			bool bUseParam;				// ������� ����, ��� ���� (��������) ������������ ��������� (��� float, ��� � �����)
			XStorageObjectToSave xobjFirst;			// ������ ������ �� ������ ���������� ��������
            List<XDbParameter> aParameters = new List<XDbParameter>();	// ��������� ���������� ����������� �������
			bool bNeedUpdateMagicBit;	// �������, ��� ���� ��������� ���� MagicBit
			XPropType vt;				// ��� ��������

			if (aGroup.Count==0) return false;
			cmdBuilder = new StringBuilder();
			// ������� ������ ������ �� ������ ���������� ��� ��������� ���������� ����
			Debug.Assert(aGroup[0] is XStorageObjectToSave, "� ������ aGroup ����������� ������� ����������������� ����");
			xobjFirst = (XStorageObjectToSave)aGroup[0];
			bCmdConstructed = false;
			// ������ ������������ ������� update �������� ���� (�������)
			cmdBuilder.AppendFormat("UPDATE {0} SET ", 
				xs.GetTableQName(xobjFirst.SchemaName, xobjFirst.ObjectType) );
	
			#region ������������ UPDATE ���� ts
			bNeedUpdateMagicBit = false;
			// ��������� ��� update'� ts
			columnBuilder = new StringBuilder();
			columnBuilder.AppendFormat("{1}{0} = CASE{1}", 
				xs.ArrangeSqlName("ts"),		// 0
				xs.Behavior.SqlNewLine );		// 1
			foreach(XStorageObjectToSave xobj in aGroup)
			{
				if (xobj.UpdateTS)
				{
					// ���� update'��� ts
					columnBuilder.AppendFormat("WHEN {0}={1} THEN CASE WHEN {2}<{3} THEN {2}+1 ELSE 1 END{4}", 
						xs.ArrangeSqlName("ObjectID"),		// 0
						xs.ArrangeSqlGuid(xobj.ObjectID),	// 1
						xs.ArrangeSqlName("ts"),			// 2
						Int64.MaxValue,						// 3
						xs.Behavior.SqlNewLine );			// 4
					// ���� ��������� �� ������� �����, ����� ����� ����������� WHERE �������
					bCmdConstructed = true;
				}
				if (xobj.ParticipateInUniqueIndex)
					bNeedUpdateMagicBit = true;
			}
			if (bCmdConstructed)
			{
				// ���� ���� �� ��� ������ ������� ���� ��������� ts, ������ ������� ������ ts � �������
				columnBuilder.AppendFormat("ELSE {0}{1} END ",
					xs.ArrangeSqlName("ts"),	// 0
					xs.Behavior.SqlNewLine);	// 1
				cmdBuilder.Append(columnBuilder.ToString());
			}
			#endregion
	
			#region ������������ UPDATE ���� �������
			// �� ���� ��������� ������������� ���� �������� ������� ������ (�������� bin � text)
			foreach(XmlElement xmlPropMD in xobjFirst.XmlTypeMD.SelectNodes("ds:prop[@cp='scalar' and @vt!='bin' and @vt!='text']", xs.MetadataManager.NamespaceManager))
			{
				sPropName = xmlPropMD.GetAttribute("n");
				vt = XPropTypeParser.Parse( xmlPropMD.GetAttribute("vt") );
				nIndex = -1;		// ������� ������ �������
				// ������ ����������� update ������� �������� ��������
				columnBuilder.Length = 0;
				columnBuilder.AppendFormat("{1}{0} = CASE{1}", xs.ArrangeSqlName(sPropName), xs.Behavior.SqlNewLine);
				// �������, ��� ���� ����������� ������� ������� ��� �������� �������� 
				// (����� ��������, ���� ���� �� � ������ ������� � ������ ������������ ������� ��������)
				bool bPropNeedUpdate = false;
				// �������� ���� �� ������������ ADO-��������� ��� �������� ��������
				bUseParam = xs.DangerXmlTypes.ContainsKey( vt );
				// �� ���� �������� ������� ������ (����)
				foreach(XStorageObjectToSave xobj in aGroup)
				{
					++nIndex;
					// ���� ������� �������� ����, �� ����� ���������, ���� ���� ��� ������
					if (!xobj.Props.Contains(sPropName))
						continue;
					bPropNeedUpdate = true;
					// ������� �������������� ��������
					vValue = xobj.Props[sPropName];
					xobj.TypeInfo.CheckPropValue(sPropName, vt, vValue);
					
					if (bUseParam) 
					{
						// ���������� ��� ��������� ���: ���_������� + t + ������ ���� + o + ������ �������.
						sParamName = xs.GetParameterName( String.Format("{0}t{1}o{2}", sPropName, nBatchIndex, nIndex) );
						// � �������� �������� �������������� ���������� ��������, ������� �� ������� ����, ��� ������������ WHERE
						columnBuilder.AppendFormat("WHEN {0}={1} THEN {2}{3}", 
							xs.ArrangeSqlName("ObjectID"),		// 0
							xs.ArrangeSqlGuid(xobj.ObjectID),	// 1
							sParamName,							// 2
							xs.Behavior.SqlNewLine );			// 3
						aParameters.Add( cmdParamFactory.CreateParameter(sParamName, vt, ParameterDirection.Input, true, vValue) );
					}
					else
					{
						// "����������" ��� �������� - ������� ��� �������� ���� � ����� �������
						columnBuilder.AppendFormat("WHEN {0}={1} THEN {2}{3}", 
							xs.ArrangeSqlName("ObjectID"),			// 0
							xs.ArrangeSqlGuid(xobj.ObjectID),		// 1
							xs.ArrangeSqlValue(vValue, vt),			// 2
							xs.Behavior.SqlNewLine );				// 3
					}
				}
				if (bPropNeedUpdate)
				{
					// �.�. �� ������� ������� �������� �� � ���� �������� ���������� update'��, 
					// �� �����������(!): ELSE {���_��������} - ���� ������ �� ���� ��.
					columnBuilder.AppendFormat("ELSE {0}{1}END", xs.ArrangeSqlName(sPropName), xs.Behavior.SqlNewLine);
					// ���� ���� �� � ������ ������� ������� �������� ������������, �� 
					// ������ ������������� ��������� ������� �������� �������� � �������
					if (bCmdConstructed)
						cmdBuilder.Append(",");		// ������� ������� ��� �� ������ - ������� �������
					cmdBuilder.Append(columnBuilder.ToString());
					// ��� ���� Update ���� �� ����� �������, �� ������� ������� Sql �������� �������������� (�.�. �� ����� ��������)
					bCmdConstructed = true;
				}
			}
			#endregion
	
			// ���� � ���������� ��������� ���� ���������� �������� ������� ������, ����������, ��� ��������� ������
			// (��������� �������� � ��� ��� ���������� � ts ��������� �� ����), �� �������� � ��������� ������
			if (!bCmdConstructed)
				return false;
			// ���������� MagicBit � 1 ��� �������������� ���������� �� ������������ �/��� ��������� ��������
			if (bNeedUpdateMagicBit && !bSuppressMagicBit)
			{
				cmdBuilder.AppendFormat(", {0}=1", xs.ArrangeSqlName("MagicBit") );
				// ������ ���� �������� ���������� ������ ��������� �������, ��� MagicBit ��� ��� ��� �����������
				foreach(XStorageObjectToSave xobj in aGroup)
					xobj.MagicBitAffected = true;
			}
			cmdBuilder.Append(xs.Behavior.SqlNewLine);

			// ���������� ������� WHERE, ��� ������� ������� ������� �������: (ObjectID={@oid} AND ts={@ts}),
			// ������ ������� AND ts={@ts} ������� ������ ���� � ������� ���������� ������� AnalizeTS
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
				// �������� ������� ���������� ��������, ������� ������ ���� ��������� ��������
				nTotalUpdateObjects++;
			}
			// ������� ��������� " OR "
			cmdBuilder.Length -= 4;
			disp.DispatchStatement(cmdBuilder.ToString(), aParameters, true);
			return true;
		}

		/// <summary>
		/// ��������� � ���������� ������ ������ ��� UPDATE'� �������� ���������� ���������� �������� (������ �������� MaxObjectsPerUpdate)
		/// ��� ���, ��� � ���������� ��������� (aGroup) ���� ���� �� ��� ������� �� ����������, ������������ � ���������� �������.
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="disp">��������� ��������</param>
		/// <param name="aGroup">������ ���������� ��������</param>
		/// <param name="nBatchIndex">������ ������ ����� (��� �������� ���������� ������������ ����������)</param>
		/// <param name="cmd">�������, ��� ������� ����������</param>
		/// <param name="bSuppressMagicBit">������� ����, ��� ���� ��������� ��������� ���� MagicBit</param>
		/// <param name="nTotalUpdateObjects">����� ���������� ��������, ������� ������ ���� ��������� update'��</param>
		protected void updateLargeNumberOfSameTypeObjects(XStorageConnection xs, XDbStatementDispatcher disp, ArrayList aGroup, int nBatchIndex, XDbCommand cmd, bool bSuppressMagicBit, ref int nTotalUpdateObjects)
		{
			string sTempTableName;		// ������������ ��������� �������
			XStorageObjectToSave xobjFirst;
			int nIndex = 0;

			if (aGroup.Count == 0) return;
			Debug.Assert(aGroup[0] is XStorageObjectToSave, "������� � ���������� ������ aGroup ������ ���� ���� XStorageObjectToSave");
			xobjFirst = (XStorageObjectToSave)aGroup[0];
			// 1. ������� ��������� �������
			// ������������ ��������� ����������, �.�. ��� ������������� ������ ��� insert'�� ��������� ������� �� ��������
			sTempTableName = getTempTableName();
			disp.DispatchStatement(getTempTableCreationScript(xs, sTempTableName, xobjFirst.TypeInfo), false);

			// 2. ������������ insert'� ��� ������� ������� � ������
			bool bNeedUpdateMagicBit = false;	// �������, ��� ���� ��������� ���� MagicBit
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


			// 3. ������������ update � join'�� �� ��������� ��������
			updateWithTempTable(xs, disp, sTempTableName, bSuppressMagicBit, xobjFirst.SchemaName, xobjFirst.ObjectType, xobjFirst.XmlTypeMD);

			// 4. ������� ��������� �������
			disp.DispatchStatement("DROP TABLE " + sTempTableName , false);
		}

		/// <summary>
		/// ���������� ��� ��������� �������
		/// </summary>
		/// <returns>��� ��������� �������</returns>
		protected virtual string getTempTableName()
		{
			return "tmp" + Guid.NewGuid().ToString("N").ToUpper();
		}

		/// <summary>
		/// ���������� ����� ������� �������� ��������� ������� ��� insert'��.
		/// ��� ������ (��� ����) ��������� �������� createTempTableCreationScript � �������� ���������.
		/// ������������ ��������� ������� {sTempTableName}
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="sTempTableName">������������ ��������� �������</param>
		/// <param name="xtype">���������� ����</param>
		/// <returns>����� �������</returns>
		protected abstract string getTempTableCreationScript(XStorageConnection xs, string sTempTableName, XTypeInfo xtype);

		/// <summary>
		/// ������� ����� ������� �������� ��������� ������� ��� insert'��.
		/// ������ ������������ ������ �������� ������ ����������� ������� (��� ������ � create table..)
		/// ��� ������� ���������� �������� � ���� ������������ ��� �������:
		/// c{������������_��������} - ��� �������� ������ �������� ��������
		/// x{������������_��������} - ��� �������� �������� ������������� ��������� �������� (����� ���� CHAR(1))
		/// </summary>
		/// <param name="key">���������� ���� - ��������� XTypeInfo</param>
		/// <param name="param">XStorageConnectioMsSql</param>
		/// <returns>����� �������</returns>
		protected object createFieldsListForTempTableCreationScript(object key, object param)
		{
			XTypeInfo xtype = key as XTypeInfo;
			int nLength = 0;
			if (xtype == null)
				throw new ArgumentException("������������ ����, ��������� ������ ���� XTypeInfo");
			//XmlElement xmlTypeMD = key as XmlElement;
			XStorageConnection xs = param as XStorageConnection;
			Debug.Assert(xs!=null, "�� ������� ��������� XStorageConnection");
			StringBuilder scriptBuilder = new StringBuilder();
			scriptBuilder.Append( 
				xs.ArrangeSqlName("ObjectID") + " " + xs.Behavior.GetSqlType(XPropType.vt_uuid, 0) + " NOT NULL," +
				xs.ArrangeSqlName("ts") + " " + xs.Behavior.TSColumnSqlType + "," +
				xs.ArrangeSqlName("x_ts") + " CHAR(1)"
				);

			// �� ���� ��������� ���������, ����� �������. ��� ������� �������� ���������� ��� ������� ��
			// ��������� �������. ���� �� ���������, ������ - �������, ��� �������� ������ (�.�. ���� update'��� �� ��� ��������)
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
		/// ��������� ������ ������������ UPDATE � �������������� ������ �� ��������� �������
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="disp">XDbStatementDispatcher</param>
		/// <param name="sTempTableName">��� ��������� ������� (��� ������������)</param>
		/// <param name="bUseMagicBit">������� ������������� "����������� ����"</param>
		/// <param name="sTypeName">��� ���� ����������� ������ ��������</param>
		/// <param name="sSchemaName">������������ �����</param>
		/// <param name="xmlTypeMD">���������� ����</param>
		protected abstract void updateWithTempTable(XStorageConnection xs, XDbStatementDispatcher disp, string sTempTableName, bool bUseMagicBit, string sSchemaName, string sTypeName, XmlElement xmlTypeMD);

		/// <summary>
		/// ���������� ��������� ������� � ���������� INSERT �� ��������� ������� ��� ����������� ds-�������
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="xobj">ds-������</param>
		/// <param name="disp">��������� ��������</param>
		/// <param name="sTempTableName">������������ ��������� �������</param>
		/// <param name="cmd">�������, ��� ������� ����������</param>
		/// <param name="nBatchIndex">������ ������ ���������� �������� � ����� ������ ��������</param>
		/// <param name="nIndex">������ ������� xobj � ������</param>
		/// <returns>��������� ������� � ���������� insert</returns>
		private void insertObjectIntoTempTable(XStorageConnection xs, XDbStatementDispatcher disp, XStorageObjectToSave xobj, string sTempTableName, XDbCommand cmd, int nBatchIndex, int nIndex)
		{
			StringBuilder queryBuilder  = new StringBuilder();	// ����������� ���������� insert'a
			StringBuilder valuesBuilder = new StringBuilder();	// ����������� ������ ��������
			string sPropName;			// ������������ ��������, ������� � ���������
			string sParamName;			// ������������ ��������� �������
			object vValue;				// �������� ��������

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
			// �� ���� ��������� ��������� �������� ������� (�������� bin � text)
			foreach(DictionaryEntry entry in xobj.Props)
			{
				// ������� ������������ �������� ��������
				sPropName = (string)entry.Key;
				XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
				if (!(propInfo is IXPropInfoScalar))
					continue;
				vValue = entry.Value;
				if ((propInfo.VarType == XPropType.vt_text || propInfo.VarType == XPropType.vt_bin) /*&& vValue != DBNull.Value*/)
					continue;
				// � ����������� �� ���� �������� ����� ����������� insert-�������.
				// � ������� ����� ��������� ������ �������� ��������! �.�. NULL-�������� �� ���������, ��� �������, � ����� ������.
				// ��� ��������� ��������� ��������
				if (vValue != DBNull.Value)
				{
					xobj.TypeInfo.CheckPropValue(sPropName, propInfo.VarType, vValue);
					
					// �������, ��������������� �������� �������� +
					// ����������� �������, �������� 1 � ������� ������� � ���, ��� �������� ������� �������� ����������, �.�. ��� ���� ���������
					queryBuilder.AppendFormat( ",{0},{1}", 
						xs.ArrangeSqlName("c" + sPropName), 
						xs.ArrangeSqlName("x" + sPropName) );

					valuesBuilder.Append( ',' );
					if(xs.DangerXmlTypes.ContainsKey(propInfo.VarType))
					{
						// �������� ������� ��������
						sParamName = xs.GetParameterName( String.Format("{0}t{1}o{2}", sPropName, nBatchIndex, nIndex) );
						Params.Add( cmd.CreateParameter(sParamName, propInfo.VarType, ParameterDirection.Input, true, vValue) );
						valuesBuilder.Append( sParamName );
					}
					else
					{
						valuesBuilder.Append(xs.ArrangeSqlValue(vValue, propInfo.VarType));
					}
					// �������� ����. ������� ��� ��������, �������� ���� 1 ��� ������� ����, ��� ������� �������� ���� ���������
					valuesBuilder.Append( ",'1'" );
				}
			}	// foreach
			// ���������� ������� � ������� �� � ����� ����
			queryBuilder.AppendFormat(") values ({0})", valuesBuilder.ToString());
			disp.DispatchStatement(queryBuilder.ToString(),Params, false);
		}

		/// <summary>
		/// ���������� ���� MagicBit � 0 ��� ��������, ��� ������� ��� ���� ����������� � 1
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="datagram">��������� �������������� ��������</param>
		/// <param name="bSuppressMagicBitForInsert">������� ����, ��� ���� ��������� ��������� ���� MagicBit ��� ����������� �������� (�� ������ objSet.ObjectsToInsert)</param>
		/// <param name="bSuppressMagicBitForUpdate">������� ����, ��� ���� ��������� ��������� ���� MagicBit ��� ����������� �������� (�� ������ objSet.ObjectsToUpdate)</param>
		protected virtual void resetObjectMagicBit(XStorageConnection xs, XDatagram datagram, bool bSuppressMagicBitForInsert, bool bSuppressMagicBitForUpdate)
		{
			ArrayList updatedObjects;	// ������ �������� XStorageObjectToSave, ������������ �� datagram.ObjectsToInsert � datagram.ObjectsToUpdate
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
				Debug.Assert(aObjects.Count>0, "������ �������� ����� ������ �������� ����. ������ � ����������� ObjectSet'a.");

				// ������� ������ ������ ������, ����� �������� ������������ ��� ����
				XStorageObjectToSave xobjFirst = (XStorageObjectToSave)aObjects[0];
				queryBuilder.Length=0;
				queryBuilder.AppendFormat("UPDATE {0} SET {1}=0 WHERE {2} IN (",
					xs.GetTableQName(xobjFirst.SchemaName, xobjFirst.ObjectType),	// 0
					xs.ArrangeSqlName( "MagicBit" ),							// 1
					xs.ArrangeSqlName( "ObjectID" )								// 2
					);

				int nStartLen = queryBuilder.Length;
				int nAmount = 0;

				// �� ���� �������� � ������ (�.�. ������ ����)
				foreach(XStorageObjectToSave xobj in aObjects)
				{
					if(++nAmount > xs.MaxObjectsPerUpdate)
					{
						// ������� ��������� �������
						queryBuilder.Length--;
						queryBuilder.Append(")");
						disp.DispatchStatement(queryBuilder.ToString(), false);
						
						// �������
						queryBuilder.Length = nStartLen;
						nAmount=0;
					}
					queryBuilder.AppendFormat("{0},", xs.ArrangeSqlGuid(xobj.ObjectID) );
				}
				// ������� ��������� �������
				queryBuilder.Length--;
				queryBuilder.Append(")");
				disp.DispatchStatement(queryBuilder.ToString(), false);
			}	// while
			disp.ExecutePendingStatementsAndReturnTotalRowsAffected();
		}

		#endregion

		#region �������� ��������

		/// <summary>
		/// ������� ������� �� ����������� ������. ���������� �� ���� ��������� ������� Delete.
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="aObjectsToDeleteRoot">������ ��������� �������� (���� ObjectToDelete)</param>
		/// <returns>���������� ��������� ��������</returns>
		protected override int internalDeleteObjects(XStorageConnection xs, XStorageObjectToDelete[] aObjectsToDeleteRoot)
		{
			Debug.Assert(aObjectsToDeleteRoot != null, "aObjectsToDeleteRoot �� ������ ���� null");
			if (aObjectsToDeleteRoot.Length==0) return 0;
			Debug.Assert(aObjectsToDeleteRoot[0].GetType() == typeof(XStorageObjectToDelete), "� ������ aDelObject ������ ���� ������� ���� ObjectToDelete");
			// ������ ��������� �������� (������ ������������) ����� ������� � ���� ����������, ���
			// ���� - ObjectID, �������� XStorageObjectToDelete. 
			// �� �� ����� ������������ ��� ������ ��� ������������ ������ ����� ���������
            Hashtable aObjectsHash = new Hashtable(aObjectsToDeleteRoot.Length);
			// ��� ������� ����� �������� ���������� ������ ��������� ��������
			// ���������� �������, ���������� ������ �����������, ����� � ��������� ������ aObjectsHash.
			foreach(XStorageObjectToDelete xobj in aObjectsToDeleteRoot)
				if (!xobj.TypeInfo.IsTemporary)
					buildDependencyTree(xs, xobj, aObjectsHash, true);
			if (aObjectsHash.Count > 1)
			{
				// ��� ��� ������� �� �������� �������� � �������� ��� ������� ������� ��� ������, 
				// �� ������ � ������, ���� ��� ��� ��������� �� ���� ������ �������� � ������ �� ��������
				// �.�. �������� ������ ����������� ������ ��� �������� ��������, ���� �� ������� �� ����� �������� ��������
				foreach(XStorageObjectToDelete xobj in aObjectsToDeleteRoot)
					if (!xobj.TypeInfo.IsTemporary)
					{
						foreach(XStorageObjectToDelete xobjRef in aObjectsHash.Values)
							if (!Object.ReferenceEquals(xobj, xobjRef))
								if (xobj.TypeInfo.ReferenceTo(xobjRef.TypeInfo))
								{
									// ��� ������� xobj ��������� �� ��� ������� xobjRef, �������������,
									// ������ xobj _�����_ ��������� �� ������ xobjRef
									XDbCommand cmd;				// ADO.NET �������
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
											// Timestamp=-1 ���� � ��� ������������� ��������, ����� ��������� ts �� ����.
											if (xobj.TS>-1 && xobj.TS!=reader.GetInt64(0))
											{
												throw new XOutdatedTimestampException(xobj.ObjectType, xobj.ObjectID );
											}
											xobj.ReadObjectDependencesFromDataReader(reader, 1);
										}
										// ���� ������ ������, �� ������������ ��� �������� ����� ��� ���������� delete'��
									}
								}
					}
			}
			XDbStatementDispatcher disp = xs.CreateStatementDispatcher();
			if (aObjectsHash.Count==0)
			{
				// ������� ������
				return 0;
			}
			else if (aObjectsHash.Count == 1)
			{
				// ����� ���� ������, ����-��������� ����� �� ������������ (���������� �� ����, ����� ���� �� �����)
				return doDelete(xs, disp, aObjectsHash.Values);
			}
			else
			{
				// ��������� ����� ����� ��������� � ������ �� ��������
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
					// ������� ������������� ������ � �����
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
		/// ��������� ������ ��������� ������ ����� ���������� ���������
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="disp">��������� ��������</param>
		/// <param name="aDelObjectsToDelete">������ �������� �� ��������</param>
		protected void tearArrayRefsBetweenObjects(XStorageConnection xs, XDbStatementDispatcher disp, object[] aDelObjectsToDelete)
		{
			XStorageObjectToDelete xobj_ref;
			Debug.Assert(aDelObjectsToDelete != null, "aDelObjectsToDelete == null");
			Debug.Assert(aDelObjectsToDelete.Length > 1, "aDelObjectsToDelete.Length <= 1, �� ����� �������� ���� �����");
			// ��� ������� ������� �� ������:
			// ���� � ������ ���������� ������ �������� �� ��������, ����������� �� ������� �� ��������� ����:
			// ������ � ��������� ��� ��������� ��������, ��:
			//		������� ������ �� �����-�������, ��������������� ���������� ��������, �� ������� Value = OID �������� �������
			int nObjIndex = -1;		// ������ ������� � ������ �� ��������
			foreach(XStorageObjectToDelete xobj in aDelObjectsToDelete)
			{
				++nObjIndex;
				if (xobj.TypeInfo.ReferencesOnMe != null)
				{
					// �� ���� �������������, ������� ��������� _��_ ��� �������� �������
					foreach(XPropInfoObject xprop in xobj.TypeInfo.ReferencesOnMe)
					{
						// ���� �������� ������ ��� ��������� ��� ��������� ��������,
						// �.�. ��������� ��-�� ������� � ������� ������������ �������� �������
						if (xprop.Capacity == XPropCapacity.Array || 
							xprop.Capacity == XPropCapacity.Collection && xprop.ReverseProp == null)
						{
							// ����� ������ ������� ����� �������� �� ��������, ������� �������� ��������� xprop,
							// �� ������ ����� �������� ������� (xobj), 
							// �.�. ���� ������� � ���������� ���������� ����� � ������ ����� �������, 
							// �� �����-������� ��������� ����, � �������������� �������� ������ �� ����
							for(int i=nObjIndex+1; i<aDelObjectsToDelete.Length;++i)
							{
								xobj_ref = (XStorageObjectToDelete)aDelObjectsToDelete[i];
								if (xobj_ref.ObjectType == xprop.ParentType.Name)
								{
									// ���� ������ _�����_ ���������, �.�. ��� ��� ��������� �� ��� �������� �������.
									// ������ �����, ��� ����� ��������� ���� ����� ��� ����������� �����-������� �� �� �����,
									// ������� ������ ������� �����-������� �� ObjectID 
									// (������� �� Value ����� ��������, �.�. ��� ����� �� ObjectID ���� ��������� ��������, �� ��� �� �� ������� - ������ ��� �����):
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
		/// ������ ������ �������� ��������� ��������� ��������� ������� � ���������. �������� ���� ����������
		/// </summary>
		/// <param name="xs"></param>
		/// <param name="xobj">������� ������</param>
		/// <param name="aObjectsHash">������� ��������� ��������, � ������� ����������� �������: 
		/// ���� - {ObjectType} + ":" + {ObjectID}, �������� - ��������� ObjectToDelete</param>
		/// <param name="bIsRoot">������� ����, ��� ������� ������ ������ (true ��� ������ �� internalDeleteObjects, false ��� ����������� �������)</param>
		protected virtual void buildDependencyTree(XStorageConnection xs, XStorageObjectToDelete xobj, IDictionary aObjectsHash, bool bIsRoot)
		{
			XmlElement xmlChildObjTypeMD;		// ���������� ���� �������, ������������ �� �������
			string sTypeName;					// ������������ ����
			string sParamName;					// ������������ ���������
			// ������� ����� � DataReader'�
			const int IDX_OBJECTID	= 0;		// ������������� �������
			const int IDX_TS		= 1;		// ts �������
			string sObjectKey = xobj.ObjectType + ":" + xobj.ObjectID;
			// ���� ���������� ������ ��� ���� � ������ ���������, �� �� �����
			if (aObjectsHash.Contains(sObjectKey))
				return;
			// ��������� ������� ������ � ��������� ��������� ��������. 
			aObjectsHash.Add(sObjectKey, xobj);
			// ������� ��� �������, ������� ��������� �� ������� ������ �� �������� ����� � ��������� ���������� ��������.
			// ��� ������� ������� �������� ������ ��������, �� ������� �� ��������� (�� �������� ����� � ��������� ���������� ��������)
			// � ��� ������� ��������� ���������� ����.
			XmlNodeList lst = xs.MetadataManager.SelectNodes("ds:type/ds:prop[@ot='" + xobj.ObjectType + "' and @vt='object' and @cp='scalar' and @delete-cascade='1']");
			if(lst.Count!=0)
			{
				ArrayList children = new ArrayList();
				using(XDbCommand cmd = xs.CreateCommand())
				{
					sParamName = xs.GetParameterName("p");
					cmd.Parameters.Add(sParamName, DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
					cmd.CommandType = CommandType.Text;

					// ������� ��� ��������, � ����� �������� ��������, �.�. ������������ �� ����� ���������� ����� ���� ������ ���� reader
					foreach(XmlElement xmlChildObjPropMD in lst)
					{
						xmlChildObjTypeMD = (XmlElement)xmlChildObjPropMD.ParentNode;
						sTypeName = xmlChildObjTypeMD.GetAttribute("n");
						// ���������� ������, ������� �������� ������� ���������� ����, ����������� (FK � ��������� ���������) 
						// �� ������� ������ (obj) �� ���������� ��������.
						// ��������: ������������_����, �������������_�������, ts  [[,������_��_������������_������, ������������_����_�������������_�������]...]
						// ����������: "������������ ������" - ������, �� ������� ��������� ������� ����, �������������� ��������� ������ � ��������� ���������.
						cmd.CommandText = 
							"SELECT " + xs.ArrangeSqlName("ObjectID") + ", " + xs.ArrangeSqlName("ts") + getFKColumnsList(xs, xmlChildObjTypeMD) + 
							" FROM " + xs.GetTableQName(sTypeName) +" WHERE " + xs.ArrangeSqlName(xmlChildObjPropMD.GetAttribute("n")) + "=" + sParamName;
						using(IDataReader reader = cmd.ExecuteReader())
						{
							while (reader.Read())
							{
								// ����������: ObjectID � ts NOT NULL, ������� IDataReader.IsDbNull ����� GetGuid/GetInt64 �� ��������
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
				// ������ ��� ������� ����������� ������� ��������� ���������� ������
				foreach(XStorageObjectToDelete childObj in children)
				{
					buildDependencyTree(xs, childObj, aObjectsHash, false);
				}
			}
		}

		/// <summary>
		/// ���������� ������ ����� Sql-��������� �� ������� ���: ��� �������-�������� �����, ������������ �������, �� ������� ������
		/// ������� ������������� ��������� �������, ��� ������������ ��������.
		/// </summary>
		/// <param name="xs"></param>
		/// <param name="xmlTypeMD">���� ds:type � ��</param>
		/// <returns></returns>
		protected string getFKColumnsList(XStorageConnection xs, XmlElement xmlTypeMD)
		{
			StringBuilder columnListBuilder;	// ����������� ������ �������-������� ������ ���������� �������
			columnListBuilder = new StringBuilder();
			// ������� ������ ������� � ��������� ��������� ���� ����, ��� �������� ����������� �� ������� ������ �� ������������
			foreach(XmlElement xmlPropMD in xmlTypeMD.SelectNodes("ds:prop[@vt='object' and @cp='scalar']", xs.MetadataManager.NamespaceManager))
			{
				// ���������� ������ �������: ������� ����, ������������ ����, �� ������� ��������� (��� ����� �������� �� ���������� ��������� �������)
				columnListBuilder.Append("," + xs.ArrangeSqlName(xmlPropMD.GetAttribute("n")) );
			}
			return columnListBuilder.ToString();
		}


		#endregion
	}
}