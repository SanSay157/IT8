using System;
using System.Diagnostics;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.XUtils;

namespace Croc.IncidentTracker.Storage
{
	/// <summary>
	/// ���������� ����������� ������ �������� (���)
	/// ������� ������������ ��� ���������� ��������
	/// </summary>
	public class DomainObjectRegistry
	{
		private static DomainObjectRegistry m_instance = new DomainObjectRegistry();
        private XThreadSafeCache<object, object> m_registry = new XThreadSafeCache<object, object>();
        private static XThreadSafeCacheCreateValue<object, object> m_dlgCreateCacheValue = new XThreadSafeCacheCreateValue<object, object>(loadObject);

		private DomainObjectRegistry()
		{}

		/// <summary>
		/// ���������� ������ ������� �� ����.
		/// � ������ ���������� � ���� ��������� �� ��. � ���� ������ ������������ ������ � ����� ���������� DomainObjectDataSet
		/// </summary>
		/// <param name="sObjectType">������������ ���� �������</param>
		/// <param name="objectID">������������� �������</param>
		/// <param name="con"></param>
		/// <returns></returns>
		public static DomainObjectData Get(string sObjectType, Guid objectID, XStorageConnection con)
		{
			return (DomainObjectData)m_instance.m_registry.GetValue(new XObjectIdentity(sObjectType, objectID), m_dlgCreateCacheValue, con);
		}

		/// <summary>
		/// �������� �������� CreateCacheValue - �������� ��� ���������� ������������ ������� � ����
		/// </summary>
		/// <param name="key">���� � ���� - ���������� IXObjectIdentity (XObjectIdentity ��� ���������� XObjectBase)</param>
		/// <param name="param">��������� XStorageConnection</param>
		/// <returns>������ ������������ ������� - ��������� DomainObjectData</returns>
		private static object loadObject(object key, object param)
		{
			Debug.Assert(key != null);
			Debug.Assert(param != null);
			if (param == null)
				throw new ArgumentNullException("param");

			IXObjectIdentity obj_id = (IXObjectIdentity)key;
			XStorageConnection con = (XStorageConnection)param;
			DomainObjectDataSet dataSet = new DomainObjectDataSet(con.MetadataManager.XModel);
			return dataSet.Load(con, obj_id.ObjectType, obj_id.ObjectID);
		}

		/// <summary>
		/// ������� �������������� ������ �������
		/// </summary>
		/// <param name="sObjectType">������������ ���� �������</param>
		/// <param name="objectID">������������� �������</param>
		public static void ResetObject(string sObjectType, Guid objectID)
		{
			m_instance.m_registry.ResetValue(new XObjectIdentity(sObjectType, objectID));
		}

		/// <summary>
		/// ������� �������������� ������ �������
		/// </summary>
		public static void ResetObject(IXObjectIdentity obj_id)
		{
			m_instance.m_registry.ResetValue(obj_id);
		}

		/// <summary>
		/// ��������� ������� ���
		/// </summary>
		public static void Reset()
		{
			m_instance.m_registry.Clear();
		}
	}
}
