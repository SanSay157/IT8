//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Specialized;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Storage
{
	public class XDatagram
	{
		/// <summary>
		/// ���������� �������
		/// </summary>
		protected XModel m_xmodel;	
		/// <summary>
		/// �������, "������������" �� XML-�������� ��� ��������, ��� ������ �������� 
		/// ��������� �� ������ ���������� ���������� "�� ������". ���������� �������� -
		/// �������������, ������������ ������� ����� � "�������" (chunk-���) ������ 
		/// �� ��������� �������
		/// </summary>
		public static readonly string ATTR_CHUNCK_CHAIN_ID = "chunked-chain-id";
		/// <summary>
		/// ������ ����������� ��������
		/// </summary>
        protected List<XStorageObjectBase> m_aObjectsToUpdate = new List<XStorageObjectBase>();
        protected Hashtable m_hashObjectsToUpdate = new Hashtable();
		/// <summary>
		/// ������ ����� (�����������) ��������
		/// </summary>
        protected List<XStorageObjectBase> m_aObjectsToInsert = new List<XStorageObjectBase>() ;
		protected Hashtable m_hashObjectsToInsert = new Hashtable();
        
		/// <summary>
		/// ������ ��������� ��������
		/// </summary>
        protected List<object> m_aObjectsToDelete = new List<object>();
		protected Hashtable m_hashObjectsToDelete = new Hashtable();
		/// <summary>
		/// ������ ����������� ��������
		/// </summary>
        public List<XStorageObjectBase> ObjectsToUpdate
		{
			get { return m_aObjectsToUpdate; }
		}

		public IDictionary ObjectsToUpdateDictionary
		{
			get { return m_hashObjectsToUpdate; }
		}
		/// <summary>
		/// ������ ����� (�����������) ��������
		/// </summary>
        public List<XStorageObjectBase> ObjectsToInsert
		{
			get { return m_aObjectsToInsert; }
		}
		public IDictionary ObjectsToInsertDictionary
		{
			get { return m_hashObjectsToInsert; }
		}

		/// <summary>
		/// ������ ��������� ��������
		/// </summary>
        public List<object> ObjectsToDelete
		{
			get { return m_aObjectsToDelete; }
		}

		public IDictionary ObjectsToDeleteDictionary
		{
			get { return m_hashObjectsToDelete; }
		}

		/// <summary>
		/// ���������� ���������� �������
		/// </summary>
		public XModel XModel
		{
			get { return m_xmodel; }
		}


		/// <summary>
		/// ���������� ���� ��� ������� ������ ��������� � �������
		/// </summary>
		/// <param name="xobj"></param>
		/// <returns>���� ��� �������� � �������</returns>
		protected string getKey(XStorageObjectBase xobj)
		{
			return xobj.ObjectType + ":" + xobj.ObjectID;
		}

		/// <summary>
		/// ���������� ������� � ��������� ����������� ��������. ��������� ��������� ���� � ��� �� ������ ��������� ���.
		/// � ������� �� ����� � ��������� ��������, ����������� ����� ����������� ����, �.�. ��� ��������� ��� "����������� ����������".
		/// ��� ������ ����� ������ ����������� ��� SQL ���������: ������� INSERT, � ����� UPDATE. 
		/// ���������� ���������� ��������� ��� ���������� ����� �������� (��������, � ��������� �� �, � � ��������� �� �)
		/// </summary>
		/// <param name="xobj">������ ��� ��������� � ������ �����������</param>
		public void AddUpdated(XStorageObjectToSave xobj)
		{
			XStorageObjectToSave xobjExists = (XStorageObjectToSave)m_hashObjectsToUpdate[getKey(xobj)];
			if (xobjExists == null)
			{
				m_aObjectsToUpdate.Add(xobj);
				m_hashObjectsToUpdate.Add(getKey(xobj), xobj);
			}
			else
				xobjExists.Merge(xobj);
		}

		/// <summary>
		/// ���������� ������� � ��������� ����������� ��������
		/// </summary>
		/// <param name="xobj"></param>
		public void AddInserted(XStorageObjectToSave xobj)
		{
			m_aObjectsToInsert.Add(xobj);
			m_hashObjectsToInsert.Add(getKey(xobj), xobj);
		}

		/// <summary>
		/// ���������� ������� � ��������� ��������� ��������
		/// </summary>
		/// <param name="xobj"></param>
		public void AddDeleted(XStorageObjectToDelete xobj)
		{
			m_aObjectsToDelete.Add(xobj);
			m_hashObjectsToDelete.Add(getKey(xobj), xobj);
		}

		public static IEnumerator GetEnumerator(IList objects)
		{
			return new XStorageObjectBaseGroupedByTypeEnumerator(objects);
		}
	}

	public class XDatagramBuilder
	{
		protected HybridDictionary m_objects = new HybridDictionary(false);

		public XStorageObjectBase createXStorageObject(DomainObjectData obj)
		{
			XStorageObjectBase xobj;
			object vPropValue;
			if (obj.ToDelete)
				xobj = new XStorageObjectToDelete(obj.TypeInfo, obj.ObjectID, obj.TS, true);
			else
			{
				xobj = new XStorageObjectToSave(obj.TypeInfo, obj.ObjectID, obj.TS, obj.IsNew);
				((XStorageObjectToSave)xobj).PropertiesWithChunkedData = obj.PropertiesWithChunkedData;
			}
			bool bNeedTrackUniqueIndexParticipation = xobj.TypeInfo.HasUniqueIndexes && xobj.TypeInfo.DeferrableIndexes && !obj.ToDelete;
			foreach(string sPropName in obj.UpdatedPropNames)
			{
				vPropValue = obj.GetUpdatedPropValue(sPropName);
				XPropInfoBase propInfo = obj.TypeInfo.GetProp(sPropName);
				if (propInfo is XPropInfoNumeric)
				{
					if (((XPropInfoSimpleEnumerable)propInfo).IsEnum)
					{
						// � �������� �������� �������� ����� ���� ��c�� ������������, ���� �������� ��� � ������������� ����
						if (vPropValue.GetType().IsEnum)
						{
							if (propInfo.VarType == XPropType.vt_i4)
								vPropValue = (Int32)vPropValue;
							else if (propInfo.VarType == XPropType.vt_i2)
								vPropValue = (Int16)vPropValue;
							else // if (propInfo.VarType == XPropType.vt_ui1)
								vPropValue = (byte)vPropValue;
						}
					}
				}
				if (vPropValue != null)
					xobj.Props[sPropName] = vPropValue;
				// ���� �������� ��������� � ���������� �������, �������� ���
				if (bNeedTrackUniqueIndexParticipation)
					if (xobj.TypeInfo.IsPropIncludedIntoUniqueIndex(sPropName))
						((XStorageObjectToSave)xobj).ParticipateInUniqueIndex = true;
			}
			return xobj;
		}

		public XDatagram GetDatagram(DomainObjectDataSet dataSet)
		{
			XDatagram dg = new XDatagram();
			IEnumerator enumerator = dataSet.GetModifiedObjectsEnumerator(false);
			while(enumerator.MoveNext())
			{
				XStorageObjectBase xobj = createXStorageObject((DomainObjectData)enumerator.Current);
				add(xobj);
				createObjectsFromLinks(xobj);	
			}
			fillDatagram(dg);
			return dg;
		}

		/// <summary>
		/// ���������� ������� � ����������. ���� ������ � ����� ����� � ��������������� ��� ����������
		/// </summary>
		/// <param name="xobj"></param>
		protected XStorageObjectBase add(XStorageObjectBase xobj)
		{
			XStorageObjectBase xobjExists = (XStorageObjectBase)m_objects[xobj];
			if (xobjExists == null)
			{
				m_objects.Add(xobj, xobj);
				xobjExists = xobj;
			}
			else
			{
				xobjExists.Merge(xobj);
			}
			return xobjExists;
		}

		/// <summary>
		/// �������� ������� �� ������ m_objects �� 3-� ������ � ���������� ����������: 
		/// ������ ���������, �����������, �����������
		/// </summary>
		protected void fillDatagram(XDatagram dg)
		{
			foreach(XStorageObjectBase xobj in m_objects.Values)
			{
				if (xobj.State == XStorageObjectState.ToDelete)
					dg.AddDeleted((XStorageObjectToDelete)xobj);
				else if (xobj.State == XStorageObjectState.ToInsert)
					dg.AddInserted((XStorageObjectToSave)xobj);
				else
					dg.AddUpdated((XStorageObjectToSave)xobj);
			}
		}

		private void createObjectsFromLinks(XStorageObjectBase xobj)
		{
			// TODO: ����� ������: ��������� ������� ����� ��������� ����� � �������� �, ���� ��, �� ���� �� �� ������������ ?
			if (xobj is XStorageObjectToDelete)
				return;
			XStorageObjectToSave xobjSave = (XStorageObjectToSave)xobj;
			
			foreach(DictionaryEntry entry in xobjSave.GetPropsByCapacity(XPropCapacity.Link, XPropCapacity.LinkScalar))
			{
				Guid[] valueOIDs = (Guid[])entry.Value;
				if (valueOIDs.Length == 0)
					continue;
				string sPropName = (string)entry.Key;
				XPropInfoObjectLink propInfo = (XPropInfoObjectLink)xobj.TypeInfo.GetProp(sPropName);
				
				int nIndex = 0;
				foreach(Guid valueOID in valueOIDs)
				{
					XStorageObjectBase xobjValue = new XStorageObjectToSave(propInfo.ReferedType, valueOID, -1, false);
					xobjValue.Props[propInfo.ReverseProp.Name] = xobj.ObjectID;
					// ������� �������� ����������� ���������, ����� ��� ���� �� ����������� �������� �� ���������� ����������� ��� ������
					xobjValue.SetPropMergeMode(propInfo.ReverseProp.Name, XStorageObjectPropMergeModes.Weak);
					xobjValue = add(xobjValue);
					// ������������� ���� ? - ��������� ��������� ��������
					if (propInfo.OrderByProp != null)
					{
						xobjValue.Props[propInfo.OrderByProp.Name] = nIndex++;
						// ������� �������� ����������� ���������, ��������� � ��� ��� ��� Merge'� ������ �������� ������ ������ ��������
						xobjValue.SetPropMergeMode(propInfo.OrderByProp.Name, XStorageObjectPropMergeModes.Replace);
					}
				}
			}
		}
	}

	public class XStorageObjectCollection: ICollection
	{
		public class XStorageObjectCollectionSimpleEnumerator: IEnumerator
		{
			private XStorageObjectCollection m_collection;
			private int m_version;
			private XStorageObjectBase m_currentElement;

			public XStorageObjectCollectionSimpleEnumerator(XStorageObjectCollection collection)
			{
				m_collection = collection;
				m_version = collection.m_version;
				m_currentElement = null;
			}
			#region IEnumerator Members

			public void Reset()
			{
				if (m_version != m_collection.m_version)
					throw new InvalidOperationException("Collection was modified; enumeration operation may not execute");
				m_currentElement = null;
				
			}

			public object Current
			{
				get
				{
					if (m_currentElement != null)
						return m_currentElement;
					throw new InvalidOperationException("InvalidOperation_EnumEnded");
				}
			}

			public bool MoveNext()
			{
				if (m_version != m_collection.m_version)
					throw new InvalidOperationException("Collection was modified; enumeration operation may not execute");

				return false;
			}

			#endregion
		}

		private Hashtable m_types = new Hashtable();
		private int m_version;

		#region ICollection Members

		public bool IsSynchronized
		{
			get
			{
				// TODO:  Add XStorageObjectCollection.IsSynchronized getter implementation
				return false;
			}
		}

		public int Count
		{
			get
			{
				// TODO:  Add XStorageObjectCollection.Count getter implementation
				return 0;
			}
		}

		public void CopyTo(Array array, int index)
		{
			// TODO:  Add XStorageObjectCollection.CopyTo implementation
		}

		public object SyncRoot
		{
			get
			{
				// TODO:  Add XStorageObjectCollection.SyncRoot getter implementation
				return null;
			}
		}

		#endregion

		#region IEnumerable Members

		public IEnumerator GetEnumerator()
		{
			// TODO:  Add XStorageObjectCollection.GetEnumerator implementation
			return null;
		}

		#endregion

		public XStorageObjectBase GetObject(string sTypeName, Guid ObjectID)
		{
			IDictionary objects = (IDictionary)m_types[sTypeName];
			if (objects == null)
				return null;
			return (XStorageObjectBase)objects[ObjectID];
		}

		public void Add(XStorageObjectBase xobj)
		{
			IDictionary objects = (IDictionary)m_types[xobj.ObjectType];
			if (objects == null)
			{
				objects = new Hashtable(1);
				m_types.Add(xobj.ObjectType, objects);
			}
			objects.Add(xobj.ObjectID, xobj);
			++m_version;
		}
	}

	public enum XStorageObjectState
	{
		ToInsert,
		ToUpdate,
		ToDelete
	}

	/// <summary>
	/// ������ ��������� ������� 2-� ��������, ���� �������� ������������� ��������� �������
	/// </summary>
	public enum XStorageObjectPropMergeModes
	{
		/// <summary>
		/// ��������� ��������, ���� ��-�� �����������, ����� (���� ������������) ��������� �� ����������
		/// </summary>
		Normal,
		/// <summary>
		/// �������������� ���������� ��������
		/// </summary>
		Replace,
		/// <summary>
		/// ������������ ����������� �������� �������
		/// </summary>
		Weak
	}

    public abstract class XStorageObjectBase : XObjectBaseGeneric<XStorageObjectBase>
	{
		/// <summary>
		/// ����� ��� ��������� �������� XStorageObjectBase �� ������������ ����
		/// ������������ � ����-���������� ��� ���������� �������� � ���������� �������� ����������� 
		/// (��� �������������� ����������)
		/// </summary>
        public class ComparerByTypeName : IComparer<XStorageObjectBase>
		{
			/// <summary>
			/// ����� ���������. ��. IComparer.Compare
			/// </summary>
			/// <param name="l"></param>
			/// <param name="r"></param>
            public int Compare(XStorageObjectBase l, XStorageObjectBase r)
			{
				if (l!=null && (!(l is XStorageObjectBase)) || r!=null && (!(r is XStorageObjectBase)))
				{
					throw new InvalidOperationException("�� ��������� ������������ ������ ��� ��������� �������� �����, �������� �� XStorageObjectBase");
				}
				// �� ������������ �� IComparer ��������� ���������� ������ � null. null ������ ������.
				if (l==null)
					return -1;
				if (r==null)
					return 1;
				return ((XStorageObjectBase)l).ObjectType.CompareTo( ((XStorageObjectBase)r).ObjectType );
			}
		}

		protected HybridDictionary m_propValues = new HybridDictionary(true);
		/// <summary>���������: ����������� ��� ����������</summary>
		protected XStorageObjectState m_state;
        protected XObjectDependency<XStorageObjectBase>[] m_References;
		/// <summary>
		/// ������ ������� �������� �������
		/// </summary>
		protected HybridDictionary m_propsMergeModes;

		protected XStorageObjectBase(XTypeInfo typeInfo, Guid oid, Int64 ts)
			: base(typeInfo, oid, ts)
		{}

		public IDictionary Props
		{
			get 
			{ 
				return m_propValues; 
			}
		}
		public Boolean AnalyzeTS
		{
			get { return (TS > -1);}
		}
		public XStorageObjectState State
		{
			get { return m_state; }
		}
        public override XObjectDependency<XStorageObjectBase>[] References
		{
			get { return m_References; }
		}

		/// <summary>
		/// ������������� ������ ������������ �������� ������� �� �������, �������� ��������
		/// </summary>
		/// <param name="objects">������� ��������: ���� - {ObjectType}+":"+{ObjectID}, �������� - ��������� XStorageObjectBase</param>
		public void InitReferences(IDictionary objects)
		{
			ArrayList aReferences = new ArrayList();
			foreach(XPropInfoObjectScalar propInfo in TypeInfo.GetPropsByCapacity(XPropCapacity.Scalar))
			{
				object vValue = Props[propInfo.Name];
				if (vValue != null && vValue != DBNull.Value)
				{
					Debug.Assert(vValue is Guid, "� ��������� ��������� �� NULL �������� �������� GUID");
					XStorageObjectBase xobjRef = (XStorageObjectBase)objects[propInfo.ReferedType.Name + ":" + (Guid)vValue];
					if (xobjRef != null) 
					{
                        aReferences.Add(new XObjectDependency<XStorageObjectBase>(this, xobjRef, propInfo));
					}
				}
			}
            m_References = new XObjectDependency<XStorageObjectBase>[aReferences.Count];
			aReferences.CopyTo(m_References, 0);
		}

		public override string ToString()
		{
			return ObjectType + "[" + ObjectID.ToString() + "]";
		}
		public virtual void Merge(XStorageObjectBase xobj)
		{
			if (xobj.State == XStorageObjectState.ToDelete && State != XStorageObjectState.ToDelete ||
				xobj.State != XStorageObjectState.ToDelete && State == XStorageObjectState.ToDelete
				)
				throw new XMergeConflictException("���������� ��� ���������� ������� " + xobj.ToString() + ", ���� �� ������� ������� ��� ���������, � ������ ���");
			if (this.AnalyzeTS && xobj.AnalyzeTS)
				if (this.TS != xobj.TS)
					throw new XMergeConflictException("���������� ��� ���������� ������� " + xobj.ToString() + " � ������� ts:" + this.TS + ", " + xobj.TS);
			TS = Math.Max(this.TS,  xobj.TS);
		}

		public void SetPropMergeMode(string sPropName, XStorageObjectPropMergeModes mergeMode)
		{
			if (m_propsMergeModes == null)
				m_propsMergeModes = new HybridDictionary(1);
			m_propsMergeModes[sPropName] = mergeMode;
		}

		public XStorageObjectPropMergeModes GetPropMergeMode(string sPropName)
		{
			if (m_propsMergeModes == null)
				return XStorageObjectPropMergeModes.Normal;
			object vValue = m_propsMergeModes[sPropName];
			if (vValue == null)
				return XStorageObjectPropMergeModes.Normal;
			else
				return (XStorageObjectPropMergeModes)vValue;
		}

	}

	public class XStorageObjectToSave: XStorageObjectBase
	{
		/// <summary>������� ����, ��� ���� update'��� ts</summary>
		protected bool m_bUpdateTS;
		/// <summary>������� ����, ��� ��� ������� ������������� MagicBit</summary>
		protected bool m_bMagicBitAffected;
		/// <summary>������� ����, ��� � ������� ���� ��������, ����������� � ���������� ��������</summary>
		protected bool m_bParticipateInUniqueIndex;
		/// <summary>
		/// ������� �������, ��� ������� ���� ��������� �������� ������. ����: ������������ ��������, �������� - ������������� �������
		/// </summary>
		protected IDictionary m_propertiesWithChunkedData;

		public XStorageObjectToSave(XTypeInfo typeInfo, Guid oid, Int64 ts, bool bNew)
			: base(typeInfo, oid, ts)
		{
			if (bNew)
				m_state = XStorageObjectState.ToInsert;
			else
				m_state = XStorageObjectState.ToUpdate;
			m_bUpdateTS = true;
		}


		private XStorageObjectState state
		{
			get { return m_state; }
		}

		public bool ParticipateInUniqueIndex
		{
			get { return m_bParticipateInUniqueIndex; }
			set { m_bParticipateInUniqueIndex = value; }
		}

		public bool MagicBitAffected
		{
			get { return m_bMagicBitAffected; }
			set { m_bMagicBitAffected = value; }
		}
		public Boolean UpdateTS
		{
			get { return m_bUpdateTS; }
			set { m_bUpdateTS = value; }
		}
		public bool IsToInsert
		{
			get { return state == XStorageObjectState.ToInsert; }
		}
		public bool IsToUpdate
		{
			get { return state == XStorageObjectState.ToUpdate; }
		}

		/// <summary>
		/// Dictionary<string,Guid> - ������� ������� �������� ������ �������
		/// </summary>
		public IDictionary PropertiesWithChunkedData	
		{
			get
			{
				if (m_propertiesWithChunkedData == null)
					m_propertiesWithChunkedData = new HybridDictionary();
				return m_propertiesWithChunkedData;
			}
			set { m_propertiesWithChunkedData = value; }
		}

		public IDictionary GetPropsByCapacity(params XPropCapacity[] propCapacities)
		{
			XPropInfoObject[] propInfos = TypeInfo.GetPropsByCapacities(propCapacities);
			HybridDictionary props = new HybridDictionary(propInfos.Length);
			foreach(XPropInfoObject propInfo in propInfos)
			{
				if (Props.Contains(propInfo.Name))
					props.Add(propInfo.Name, Props[propInfo.Name]);
			}
			return props;
		}
		public IDictionary GetPropsByType(params XPropType[] propTypes)
		{
			HybridDictionary props = new HybridDictionary();
			foreach(XPropInfoBase propInfo in TypeInfo.Properties)
				foreach(XPropType propType in propTypes)
					if (propType == propInfo.VarType)
					{
						if (Props.Contains(propInfo.Name))
							props.Add(propInfo.Name, Props[propInfo.Name]);
						break;
					}
			return props;
		}

		public override void Merge(XStorageObjectBase p_xobj)
		{
			base.Merge(p_xobj);
			XStorageObjectToSave xobj = p_xobj as XStorageObjectToSave;
			if (xobj == null)
			{
				Debug.Fail("������������ ���������� XStorageObjectBase::Merge");
				throw new ArgumentException();
			}
			UpdateTS = UpdateTS | xobj.UpdateTS;
			if (xobj.IsToInsert)
				m_state = XStorageObjectState.ToInsert;
			foreach(string sPropName in xobj.Props.Keys)
				if (!Props.Contains(sPropName))
				{
					// �������� �� ���� - �������
					Props[sPropName] = xobj.Props[sPropName];
				}
				else
				{
					XStorageObjectPropMergeModes mergeModeThis = GetPropMergeMode(sPropName);
					XStorageObjectPropMergeModes mergeModeForeign  = xobj.GetPropMergeMode(sPropName);
					// ���� ���� �� ��� ������ �������� ����� ���� "������" ��������, �� ��������� �������� �� ���������� �������� �������
					if (mergeModeThis == XStorageObjectPropMergeModes.Replace)
					{
						Debug.Assert(mergeModeForeign != XStorageObjectPropMergeModes.Replace, "��� �������� � ��������� ���������� - ��� ������������ ��������");
						// � �������� ��-�� ����� ������� ����������, ������� ��������� ��� � ������������������ (���� �������� �� ������)
					}
					else if (mergeModeForeign == XStorageObjectPropMergeModes.Replace)
					{
						Props[sPropName] = xobj.Props[sPropName];
					}
					else
					{
						if (!isPropsEquals(Props[sPropName], xobj.Props[sPropName]))
							throw new XMergeConflictException("�������� ������� " + sPropName + " ����������: '" + Props[sPropName] + "' � '" + xobj.Props[sPropName] + "'");
					}
				}

			// �������� ������� �������, ������ ������� ��������� ���������� ��������� ����������
			if (xobj.PropertiesWithChunkedData.Count > 0)
				foreach(string sPropName in xobj.PropertiesWithChunkedData.Keys)
					PropertiesWithChunkedData[sPropName] = xobj.PropertiesWithChunkedData[sPropName];

			ParticipateInUniqueIndex = xobj.ParticipateInUniqueIndex | ParticipateInUniqueIndex;
		}

		private bool isPropsEquals(object oLPropValue, object oRPropValue)
		{
			if (oLPropValue == null || oRPropValue == null)
				throw new ArgumentNullException();
			if (oLPropValue == DBNull.Value && oRPropValue != DBNull.Value || oLPropValue != DBNull.Value && oRPropValue == DBNull.Value)
				return false;
			if (oLPropValue is Guid[] && oRPropValue is Guid[])
			{
				Guid[] aLValues = (Guid[])oLPropValue;
				Guid[] aRValues = (Guid[])oRPropValue;
				if (aLValues.Length != aRValues.Length)
					return false;
				for(int i=0;i<aLValues.Length;++i)
					if (aLValues[i] != aRValues[i])
						return false;
				return true;
			}
			else if (oLPropValue is Guid[] || oRPropValue is Guid[])
			{
				Debug.Fail("���� �������� �������� ���� Guid[], � ������ �� Guid[]");
				return false;
			}
			else
			{
				return oLPropValue.Equals(oRPropValue);
			}
		}
	}

	public class XStorageObjectToDelete: XStorageObjectBase
	{
		private bool m_bIsRoot;

		public XStorageObjectToDelete(XTypeInfo typeInfo, Guid oid, Int64 ts, bool bIsRoot)
			: base(typeInfo, oid, ts)
		{
			m_bIsRoot = bIsRoot;
			m_state = XStorageObjectState.ToDelete;
		}

		public bool IsRoot
		{
			get { return m_bIsRoot; }
		}

		/// <summary>
		/// ���������� ��������� ������ ������� �� DataReader'�
		/// � DataReader'e ������� �� StartIndex'a ��������� ���� �������: ����-������� ����; ��� �������, �� ������� ������
		/// </summary>
		/// <param name="reader">DataReader</param>
		/// <param name="nStartIndex">������, ������� � �������� �������� ���������� �������</param>
		public void ReadObjectDependencesFromDataReader(IDataReader reader, int nStartIndex)
		{
			string sPropName;					// ������������ ��������
			Guid oid;							// ������������� �������
			// �� ���� ������� �������
			for(int nField=nStartIndex; nField < reader.FieldCount; nField++)
			{
				if (!reader.IsDBNull(nField))
				{
					oid = reader.GetGuid(nField);	// �������� �������� �����
					sPropName = reader.GetName(nField);		// ������������ ������� - ��� ������������ ��������
					Props[sPropName] = oid;
				}
			}
		}
		public override void Merge(XStorageObjectBase p_xobj)
		{
			base.Merge(p_xobj);
			XStorageObjectToDelete xobj = p_xobj as XStorageObjectToDelete;
			if (xobj == null)
			{
				Debug.Fail("������������ ���������� XStorageObjectBase::Merge");
				throw new ArgumentException();
			}
		}
	}

	/// <summary>
	/// Enumerator ��� ������ ������ �������� (XStorageObjectBase) ��������������� �� ���� (FullName)
	/// </summary>
	public class XStorageObjectBaseGroupedByTypeEnumerator: IEnumerator
	{	
		private IList _aXObjects;		// ������ � ������, ������� ����� ��������
		private int _nIndexStart;			// ������ � ������ ������ ������� ������
		private int _nIndexEnd;				// ������ � ������ ��������� ������� ������


		/// <summary>
		/// �����������
		/// </summary>
		/// <param name="aXObjects">������ �������� �� ������� ����� ����������� ����������</param>
		public XStorageObjectBaseGroupedByTypeEnumerator(IList aXObjects)
		{
			_aXObjects = aXObjects;
			(this as IEnumerator).Reset();
		}
		#region IEnumerator Members

		/// <summary>
		/// ��. ������������ �� IEnumerator
		/// </summary>
		/// <returns></returns>
		void IEnumerator.Reset()
		{
			_nIndexStart = -1;
			_nIndexEnd = -1;
		}

		/// <summary>
		/// ��. ������������ �� IEnumerator
		/// </summary>
		/// <returns></returns>
		object IEnumerator.Current
		{
			get
			{
				if (_nIndexEnd >= _nIndexStart)
				{
					ArrayList aGroup = new ArrayList( _nIndexEnd - _nIndexStart + 1);
					for(int i=_nIndexStart; i<=_nIndexEnd && i<_aXObjects.Count; i++)
					{
						aGroup.Add( _aXObjects[i] );
					}
					return aGroup;
				}
				else
				{
					return null;
				}
			}
		}


		/// <summary>
		/// ��. ������������ �� IEnumerator
		/// </summary>
		/// <returns></returns>
		bool IEnumerator.MoveNext()
		{
			if (_nIndexEnd + 1 >= _aXObjects.Count) 
			{
				// ������ ��������� �� ���������� ��������� ������ �� �������
				_nIndexEnd = _nIndexStart = -1;
				return false;
			}
			_nIndexStart = _nIndexEnd + 1;
			string sCurType = ((XStorageObjectBase)_aXObjects[_nIndexStart]).ObjectType;
            string sSchemaName = ((XStorageObjectBase)_aXObjects[_nIndexStart]).SchemaName;
			for(int i=_nIndexStart; i< _aXObjects.Count; i++)
			{
                if ((sCurType != ((XStorageObjectBase)_aXObjects[i]).ObjectType) || (sSchemaName !=((XStorageObjectBase)_aXObjects[i]).SchemaName))
				{
					_nIndexEnd = i-1;
					break;
				}
			}
			if (_nIndexEnd < _nIndexStart)
				_nIndexEnd = _aXObjects.Count;
			return true;
		}

		#endregion
	}


}