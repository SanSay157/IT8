//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Storage
{
	/// <summary>
	/// ���� ���������� �������� (XStorage)
	/// </summary>
	/// <remarks>
	/// ���������� ���������� � �������� ��������, "����������" ���������: 
	/// ����� application-���������, ������� ���� ������ �������� (DomainObjectRegistry), 
	/// ����������� ���������� ������������ (XSecurityManager) �� ����������/��������� ��������.
	/// ��� ���������� �������������� �������� "���������" ����������.
	/// ��� �������: � ����������� XFW.NET 1.* ��� ����������� � ������� XSaveObjectCommand, 
	/// ������ ���������� ���� ������� � XFW.NET 1.* �����������
	/// </remarks>
	public class XStorageGateway
	{
		/// <summary>
		/// ���������� ������ ��������� ��������.
		/// </summary>
		/// <remarks>
		/// ���������� ����������� �������.
		/// </remarks>
		/// <param name="context"></param>
		/// <param name="dataSet"></param>
		/// <param name="transactionID"></param>
		public static void Save(IXExecutionContext context, DomainObjectDataSet dataSet, Guid transactionID)
		{
			// #1: ����� ��������� Before
			XTriggersController.Instance.FireTriggers(dataSet, XTriggerFireTimes.Before, context);

			// #2: ������� �������������� ������ ��������
			IEnumerator enumerator = dataSet.GetModifiedObjectsEnumerator(false);
			while (enumerator.MoveNext())
			{
				DomainObjectData xobj = (DomainObjectData)enumerator.Current;
				// ����������: ��� ����� �������� ���������� ��� ������������ - �� ��� ���
				if (!xobj.IsNew)
					DomainObjectRegistry.ResetObject(xobj);
			}

			// #3: ������ ������
			XDatagramProcessorEx dg_proc = XDatagramProcessorMsSqlEx.Instance;
			XDatagramBuilder dgBuilder = dg_proc.GetDatagramBuilder();
			XDatagram dg = dgBuilder.GetDatagram(dataSet);
			dg_proc.Save(context.Connection, dg);

			// #4: ���������� chunked-������
			saveChunkedData(transactionID, dg, context.Connection);

			// #5: ������������� Securitymanager, ��� ���������� ������ (��� ������� �����)
			XSecurityManager.Instance.TrackModifiedObjects(dataSet);

			// #6: ����� ��������� After
			XTriggersController.Instance.FireTriggers(dataSet, XTriggerFireTimes.After, context);
		}

		/// <summary>
		/// ��������� chunked-������ ���� �������� �� ����������
		/// </summary>
		/// <param name="transactionID">������������� ����������</param>
		/// <param name="datagram">����������</param>
		/// <param name="con">����������</param>
		protected static void saveChunkedData(Guid transactionID, XDatagram datagram, XStorageConnection con)
		{
			bool bChunkedDataFound = false;

			foreach( XStorageObjectToSave xobj in datagram.ObjectsToInsert  )
				bChunkedDataFound = saveObjectChunkedData(xobj, con);
			
			foreach(XStorageObjectToSave xobj in datagram.ObjectsToUpdate)
				bChunkedDataFound = bChunkedDataFound || saveObjectChunkedData(xobj, con);
			
			// ���� � �������� �����-���� "��������" ������ ���� ����������� 
			// � ���������� ������� - ������� ����� "�����":
			if (bChunkedDataFound)
				XChunkStorageGateway.RemoveTransactionData( transactionID, con);
		}

		/// <summary>
		/// ��������� chunked-������ ��������� �������
		/// </summary>
		/// <param name="xobj">������</param>
		/// <param name="con">���������� � ��</param>
		/// <returns>true - ������ �������� chunked ������, ����� false</returns>
		protected static bool saveObjectChunkedData(XStorageObjectToSave xobj, XStorageConnection con)
		{
			string sPropName;	// ������������ ��������
			Guid ownerID;		// ������������� ������� �������� ������ ��������
			bool bChunkedDataFound = false;

			// ������ ��������, ��� ������ ���� ���������� �� ������
			foreach(DictionaryEntry entry in xobj.PropertiesWithChunkedData)
			{
				sPropName = (string)entry.Key;
				ownerID = (Guid)entry.Value;
				bChunkedDataFound = true;
				XChunkStorageGateway.MergePropertyChunkedData(
					ownerID, 
					xobj.ObjectType, 
					sPropName, 
					xobj.ObjectID, 
					con );
			}
			return bChunkedDataFound;
		}

		/// <summary>
		/// �������� (forced) ������� � ��������� ����� � ���������������.
		/// </summary>
		/// <remarks>
		/// ������ ������ �������� �����������: ����� ��������� "��" � "�����", ������� ���� � DomainObjectRegistry, ����������� XSecurityManager
		/// ���������� ����������� �������.
		/// </remarks>
		/// <param name="context">������c� ����</param>
		/// <param name="sObjectType">������������ ���� �������</param>
		/// <param name="objectID">�������������</param>
		/// <returns>�������� ���������� ��������� ��������</returns>
		public static int Delete(IXExecutionContext context, string sObjectType, Guid objectID)
		{
			DomainObjectData xobj = DomainObjectData.CreateToDelete(context.Connection, sObjectType, objectID);
			// #1: ����� ��������� Before
			XTriggersController.Instance.FireTriggers(xobj.Context, XTriggerFireTimes.Before, context);

			// #2: ������� �������������� ������ ������a
			DomainObjectRegistry.ResetObject(xobj);

			// #3: �������� �������
			XDatagramProcessorEx dg_proc = XDatagramProcessorMsSqlEx.Instance;
			int nAffected = dg_proc.Delete(context.Connection, xobj);

			// #5: ������������� Securitymanager, ��� ���������� ������ (��� ������� �����)
			XSecurityManager.Instance.TrackModifiedObjects(xobj.Context);

			// #6: ����� ��������� After
			XTriggersController.Instance.FireTriggers(xobj.Context, XTriggerFireTimes.After, context);

			return nAffected;
		}
	}
}
