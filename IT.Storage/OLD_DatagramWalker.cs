using System;
using System.Data;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Storage
{
	public interface IXObjectWalker
	{
		// {obj_id.ObjectType}��������1.���2.��������2
		Guid GetScalarObjectPropValue(XStorageConnection con, IXObjectIdentity xobj_id, string sOPath);
	}

	public class XObjectWalkerDB: IXObjectWalker
	{
		protected string getObjectValueTypeName(string sObjectType, string sPropName, XStorageConnection con)
		{
			XPropInfoBase xprop_base = con.MetadataManager.GetTypeInfo(sObjectType).GetProp(sPropName);
			if (!(xprop_base is XPropInfoObject))
				throw new ArgumentException("�������������� ������ ��������� ��������");
			return ((XPropInfoObject)xprop_base).ReferedType.Name;
		}
		protected Guid GetScalarObjectPropValueFromDB(XStorageConnection con, string sObjectType, Guid ObjectID, string[] aPathParts, int nStartIndex)
		{
			string sObjectType_cur = sObjectType;
			Guid oid_cur = ObjectID;
			string sQuery = "@ObjectID";
			object vPropValue;								// �������� ��������

			for(int nIndex = nStartIndex;nIndex<aPathParts.Length; ++nIndex)
			{
				sQuery = String.Format("SELECT {0} FROM {1} WHERE ObjectID = ({2})",
					con.ArrangeSqlName(aPathParts[nIndex]),	// 0 - ��������-�������
					con.GetTableQName(sObjectType_cur),		// 1 - ���-�������
					sQuery									// 2 - ��������� �������
					);
				sObjectType_cur = getObjectValueTypeName(sObjectType_cur, aPathParts[nIndex], con);
			}
			XDbCommand cmd = con.CreateCommand(sQuery);
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, oid_cur);
			vPropValue = cmd.ExecuteScalar();
			if (vPropValue == null)
				return Guid.Empty;
			else if (vPropValue is DBNull)
				return Guid.Empty;
			return (Guid)vPropValue;
		}
		public virtual Guid GetScalarObjectPropValue(XStorageConnection con, IXObjectIdentity xobj_id, string sOPath)
		{
			string[] aPathParts = sOPath.Split('.');
			return GetScalarObjectPropValueFromDB(con, xobj_id.ObjectType, xobj_id.ObjectID, aPathParts, 0);
		}
	}

	public class XDatagramWalker: XObjectWalkerDB
	{
		private XDatagram m_datagram;
		public XDatagramWalker(XDatagram dg)
		{
			m_datagram = dg;
		}

		public override Guid GetScalarObjectPropValue(XStorageConnection con, IXObjectIdentity xobj_id, string sOPath)
		{
			XStorageObjectToSave xobj;
			object vPropValue;			// �������� ��������
			Guid oid_cur = xobj_id.ObjectID;
			string sObjectType_cur = xobj_id.ObjectType;
			string[] aPathParts = sOPath.Split('.');
			bool bLoad;
			for(int i=0; i<aPathParts.Length; ++i)
			{
				xobj = m_datagram.GetObjectToSave(sObjectType_cur, oid_cur);
				bLoad = false;
				if (xobj == null)
				{
					// ������� ��� � ����������, �������� �� �� ��� � ��� �����������
					bLoad = true;
				}
				else
				{
					string sPropName = aPathParts[i];
					if (sPropName == "ObjectID")
					{
						oid_cur = xobj.ObjectID;
					}
					else if (xobj.Props.Contains(sPropName))
					{
						vPropValue = xobj.Props[sPropName];
						if (vPropValue == null)
							return Guid.Empty;
						oid_cur = (Guid)vPropValue;
						sObjectType_cur = getObjectValueTypeName(sObjectType_cur, sPropName, con);
					}
					else
					{
						// ������ ���� � ����������, �� �������� ��� - �������� ��� �� �� � ��� �����������
						bLoad = true;
					}
				}
				if (bLoad)
				{
					return GetScalarObjectPropValueFromDB(con, sObjectType_cur, oid_cur, aPathParts, i);
				}
			}
			return oid_cur;
		}
	}
}
