//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Specialized;
using System.Data;
using System.Diagnostics;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Storage
{
    public class DomainObjectData : XObjectBase
	{
		internal DomainObjectDataSet m_context;
		/// <summary>
		/// ������� - ������ ����� (��� �������). ������ �� �������� HasNewData
		/// </summary>
		protected bool m_bIsNew;
		/// <summary>
		/// ������� - ������ ������������ ��� ��������. �� ������ �� �������� HasNewData
		/// </summary>
		protected bool m_bToDelete;
		/// <summary>
		/// ����������� �������� �������
		/// </summary>
		protected HybridDictionary m_propsLoadedValues = new HybridDictionary(true);
		/// <summary>
		/// ������ �������� LOB-�������. ����������� ������� ��������� � ����������� LOB-������� ����
		/// </summary>
		protected Hashtable m_loadedLOBPropsDataSizes = new Hashtable();
		/// <summary>
		/// ����������� �������� ������� (��� ���������� � ��). ������ �� �������� HasNewData
		/// </summary>
		protected HybridDictionary m_propsUpdatedValues = new HybridDictionary(true);
		/// <summary>
		/// ������� �������, ��� ������� ���� ��������� �������� ������. ����: ������������ ��������, �������� - ������������� �������
		/// </summary>
		protected HybridDictionary m_propertiesWithChunkedData = new HybridDictionary(true);

		internal DomainObjectData(XTypeInfo typeInfo, Guid objectID, bool bIsNew, bool bToDelete)
			: base(typeInfo, objectID)
		{
			if (bIsNew && bToDelete)
				throw new ArgumentException("�������� '����� ������' � '��������� ������' �� ����� ���� ������ ������������");
			m_bIsNew = bIsNew;
			m_bToDelete = bToDelete;
		}

		internal DomainObjectData(XTypeInfo typeInfo, Guid objectID, bool bIsNew, bool bToDelete, DomainObjectDataSet context)
			: this(typeInfo, objectID, bIsNew, bToDelete)
		{
			m_context = context;
		}
        internal DomainObjectData(XTypeInfo typeInfo, Guid objectID, bool bIsNew, bool bToDelete, DomainObjectDataSet context, Int64 ts)
            : this(typeInfo, objectID, bIsNew, bToDelete, context)
        {
            this.TS = ts;
        }
        internal void attach(DomainObjectDataSet dataSet)
		{
			m_context = dataSet;
		}
		internal void detach()
		{
			m_context = null;
		}
        public void SetTS(Int64 ts)
        {
            this.TS = ts;
        }
		public DomainObjectDataSet Context
		{
			get { return m_context; }
		}
        
		/// <summary>
		/// ���������� ������� "��������� ����������� ������", �.�. �������� ������ �� �� ���� �������, ����� LOB � ���������
		/// </summary>
		public bool IsFullyLoaded
		{
			get
			{
				foreach(XPropInfoBase propInfo in  TypeInfo.Properties)
				{
					if (propInfo.VarType == XPropType.vt_bin || propInfo.VarType == XPropType.vt_text)
						continue;
					if (propInfo is XPropInfoObject && ((XPropInfoObject)propInfo).Capacity != XPropCapacity.Scalar)
						continue;
					// ��� ��������� ������ ����
					if (!HasLoadedProp(propInfo.Name))
						return false;
				}
				return true;
			}
		}

		public bool IsNew
		{
			get { return m_bIsNew; }
		}

		public bool ToDelete
		{
			get { return m_bToDelete; }
		}

		public bool HasLoadedData
		{
			get { return m_propsLoadedValues.Count > 0; }
		}

		public bool HasNewData
		{
			get { return m_propsUpdatedValues.Count > 0 || IsNew; }
		}

		public IDictionary PropertiesWithChunkedData
		{
			get { return m_propertiesWithChunkedData; }
		}

		public static DomainObjectData CreateStubNew(XStorageConnection con, string sObjectType)
		{
			DomainObjectDataSet dataSet = createDomainObjectDataSet(con);
			return dataSet.CreateStubNew(sObjectType);
		}

		public static DomainObjectData CreateStubLoaded(XStorageConnection con, string sObjectType, Guid ObjectID)
		{
			DomainObjectDataSet dataSet = createDomainObjectDataSet(con);
			return dataSet.GetLoadedStub(sObjectType, ObjectID);
		}

		public static DomainObjectData CreateToDelete(XStorageConnection con, string sObjectType, Guid ObjectID)
		{
			DomainObjectDataSet dataSet = createDomainObjectDataSet(con);
			return dataSet.CreateToDelete(sObjectType, ObjectID);
		}
		private static DomainObjectDataSet createDomainObjectDataSet(XStorageConnection con)
		{
			return new DomainObjectDataSet(con.MetadataManager.XModel);
		}

		/// <summary>
		/// ���������� ������� ������� ������������ �������� � �������� ������
		/// </summary>
		/// <param name="sPropName"></param>
		/// <returns></returns>
		public bool HasLoadedProp(string sPropName)
		{
			return m_propsLoadedValues.Contains(sPropName);
		}

		/// <summary>
		/// ���������� �������� ������������ ��������.
		/// ��� ��������� ������� ���������� DomainObjectDataArrayPropHandle, 
		/// ��� LOB - DomainObjectDataBinPropHandle ��� DomainObjectDataTextPropHandle
		/// ��� ��������� �������� - Guid ��� DBNull
		/// </summary>
		/// <param name="sPropName">������������ ��������</param>
		/// <returns>�������� ��������, � ��� ����� DBNull.Value. ���� �������� �� ��������� - null</returns>
		public object GetLoadedPropValue(string sPropName)
		{
			return m_propsLoadedValues[sPropName];
		}

		/// <summary>
		/// ���������� �������� ������������ ��������. 
		/// ���� �������� �� ��������� - ��������� ���
		/// ���������� �� ��, ��� � ����� GetLoadedPropValue
		/// </summary>
		/// <param name="con"></param>
		/// <param name="sPropName"></param>
		/// <returns></returns>
		public object GetLoadedPropValueOrLoad(XStorageConnection con, string sPropName)
		{
			object vValue = m_propsLoadedValues[sPropName];
			// ���� �������� �������� ��� � ������ ������� - �������� �������� �� ��
			if (vValue == null && !IsNew)
			{
				if (m_context == null)
					throw new InvalidOperationException("����� ����� �������������� ������ � ������ ������������� ����� � DomainObjectDataSet");
				m_context.LoadProperty(con, this, sPropName);
				vValue = GetLoadedPropValue(sPropName);
			}
			return vValue;
		}

		/// <summary>
		/// ������������� �������� ��������
		/// </summary>
		/// <param name="sPropName"></param>
		/// <param name="vPropValue"></param>
		public void SetLoadedPropValue(string sPropName, object vPropValue)
		{
			if (vPropValue == null)
				vPropValue = DBNull.Value;
			if (IsNew)
				throw new InvalidOperationException("����� ������ �� ����� ��������� ����������� ������");
			XPropInfoBase propInfo = TypeInfo.GetProp(sPropName);
			if (propInfo == null)
				throw new ArgumentException("����������� ������������ ��������: " +sPropName);
			if (propInfo.VarType == XPropType.vt_bin || propInfo.VarType == XPropType.vt_text)
			{
				if (vPropValue == DBNull.Value)
					m_loadedLOBPropsDataSizes[sPropName] = 0;
				else if (propInfo.VarType == XPropType.vt_bin)
					m_loadedLOBPropsDataSizes[sPropName] = ((byte[])vPropValue).Length;
				else // propInfo.VarType == XPropType.vt_text
					m_loadedLOBPropsDataSizes[sPropName] = ((string)vPropValue).Length;
			}
			m_propsLoadedValues[sPropName] = vPropValue;

		}

		public void SetLoadedPropDataSize(string sPropName, int nDataSize)
		{
			XPropInfoBase propInfo = TypeInfo.GetProp(sPropName);
			if (propInfo.VarType != XPropType.vt_bin && propInfo.VarType != XPropType.vt_text)
				throw new ArgumentException("������ �� LOB-��������: " + sPropName + " (" + propInfo.VarType +")");
			m_loadedLOBPropsDataSizes[sPropName] = nDataSize;
			if (nDataSize == 0)
				m_propsLoadedValues[sPropName] = DBNull.Value;
		}

		public int GetLoadedPropDataSize(string sPropName)
		{
			int nDataSize = -1;
			if (m_loadedLOBPropsDataSizes.Contains(sPropName))
				nDataSize = (int)m_loadedLOBPropsDataSizes[sPropName];
			return nDataSize;
		}

		/// <summary>
		/// ���������� ��������� ������������ ����������� �������
		/// ����������: ��������� ������������ ��������� �������� � �� ������������ ����������� �������� �������
		/// </summary>
		public ICollection LoadedPropNames
		{
			get
			{
				ArrayList aNames = new ArrayList(m_propsLoadedValues.Keys);
				return aNames;
			}
		}

		public bool HasUpdatedProp(string sPropName)
		{
			return m_propsUpdatedValues.Contains(sPropName);
		}

		/// <summary>
		/// ���������� �������� ������������ ��������.
		/// ��� text/bin (LOB) ����� ������������ �������� (� �.�. DBNull), ���� null, ���� ��-�� ����������� ��� ������������
		/// </summary>
		/// <param name="sPropName">������������ ��������</param>
		/// <returns>�������� ��������, � ��� ����� DBNull.Value. ���� �������� �� ����������� - null</returns>
		public object GetUpdatedPropValue(string sPropName)
		{
			return m_propsUpdatedValues[sPropName];
		}

		/// <summary>
		/// ������������� ����� (�����������) �������� ��������.
		/// ��������� ��� �������� �� ������������ ���� ��������
		/// </summary>
		/// <param name="sPropName">������������ ��������</param>
		/// <param name="vPropValue">�������� ��������</param>
		public void SetUpdatedPropValue(string sPropName, object vPropValue)
		{
			XPropInfoBase propInfo = TypeInfo.GetProp(sPropName);
			if (propInfo == null)
				throw new ArgumentException("����������� ������������ ��������: " +sPropName);
			if (vPropValue == null)
				vPropValue = DBNull.Value;
			if (vPropValue != DBNull.Value)
			{
				if (propInfo is XPropInfoObjectScalar || propInfo.VarType == XPropType.vt_uuid)
				{
					if (!(vPropValue is Guid))
						throw new ArgumentException("������������ �������� �������� " +sPropName + " ���� " + propInfo.VarType + " : " + vPropValue);
				} 
				else if (propInfo is XPropInfoObjectArray || propInfo is XPropInfoObjectLink)
				{
					// ��������� ��������� �������� - �������� ������ ������
					if (!(vPropValue is Guid[]))
						throw new ArgumentException("������������ �������� �������� " + sPropName + " ���� " + propInfo.VarType + " : " + vPropValue);
				}
                else if (propInfo is XPropInfoDatetime)
                {
                    if (!(vPropValue is DateTime) && !(vPropValue is TimeSpan))
                        throw new ArgumentException("������������ �������� date/time/dateTime �������� " + sPropName + " : " + vPropValue);
                    if (propInfo.VarType == XPropType.vt_date)
                    {
                        if (!(vPropValue is DateTime))
                            throw new ArgumentException("������������ �������� date/time/dateTime �������� " + sPropName + " : " + vPropValue);
                        DateTime dt = (DateTime)vPropValue;
                        if (dt.Hour != 0 || dt.Minute != 0 || dt.Second != 0 || dt.Millisecond != 0)
                            vPropValue = new DateTime(dt.Year, dt.Month, dt.Day);
                    }
                    else if (propInfo.VarType == XPropType.vt_time)
                    {
                        if (vPropValue is TimeSpan)
                        {
                            TimeSpan timeSpan = (TimeSpan)vPropValue;
                            vPropValue = new DateTime(1900, 1, 1, timeSpan.Hours, timeSpan.Minutes, timeSpan.Seconds, timeSpan.Milliseconds);
                        }
                        else
                        {
                            DateTime dt = (DateTime)vPropValue;
                            if (dt.Year != 1900 || dt.Month != 1 || dt.Day != 1)
                                vPropValue = new DateTime(1900, 1, 1, dt.Hour, dt.Minute, dt.Second, dt.Millisecond);
                        }

                    }
                }
				else if (propInfo.VarType == XPropType.vt_smallBin || propInfo.VarType == XPropType.vt_bin)
				{
					if (!(vPropValue is byte[]))
						throw new ArgumentException("������������ ��� �������� ��������� �������� " +sPropName);
				}
				else if (propInfo.VarType == XPropType.vt_r4)
					vPropValue = Convert.ToSingle(vPropValue);
				else if (propInfo.VarType == XPropType.vt_r8)
					vPropValue = Convert.ToDouble(vPropValue);
				else if (propInfo.VarType == XPropType.vt_i4)
					vPropValue = Convert.ToInt32(vPropValue);
				else if (propInfo.VarType == XPropType.vt_i2)
					vPropValue = Convert.ToInt16(vPropValue);
				else if (propInfo.VarType == XPropType.vt_ui1)
					vPropValue = Convert.ToByte(vPropValue);
				else if (propInfo.VarType == XPropType.vt_fixed)
					vPropValue = Convert.ToDecimal(vPropValue);
				else if (propInfo.VarType == XPropType.vt_boolean)
					vPropValue = Convert.ToBoolean(vPropValue);
			}
			m_propsUpdatedValues[sPropName] = vPropValue;
		}

		/// <summary>
		/// ���������� ��������� ������������ ����������� �������
		/// ����������: ��������� ������������ ��������� �������� � �� ������������ ����������� �������� �������
		/// </summary>
		public ICollection UpdatedPropNames
		{
			get
			{
				ArrayList aNames = new ArrayList(m_propsUpdatedValues.Keys);
				return aNames;
			}
		}

		public object GetPropValue(string sPropName, DomainObjectDataSetWalkingStrategies strategy)
		{
			object vPropValue;
			XPropInfoBase propInfo = TypeInfo.GetProp(sPropName);
			if (propInfo == null)
				throw new ArgumentException("����������� ������������ ��������: " +sPropName);
			if (IsNew || strategy == DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps)
				vPropValue = m_propsUpdatedValues[sPropName];
			else if (strategy == DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps)
				vPropValue = m_propsLoadedValues[sPropName];
			else
			{
				vPropValue = m_propsUpdatedValues[sPropName];
				if (vPropValue == null)
					vPropValue = m_propsLoadedValues[sPropName];
			}
			return vPropValue;
		}

		public object GetPropValueAnyhow(string sPropName, DomainObjectDataSetWalkingStrategies strategy, XStorageConnection con)
		{
			object vPropValue = GetPropValue(sPropName, strategy);
			// ���� �� ������� �������� ������ �������� � ��������� ��� ��������� ������������ ����������� �� �� ������, �� �������� ��������
			if (!IsNew && vPropValue == null && strategy != DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps)
			{
				m_context.LoadProperty(con, this, sPropName);
				vPropValue = GetLoadedPropValue(sPropName);
			}
			return vPropValue;
		}

		/// <summary>
		/// ������� ������ �� ������
		/// </summary>
		public void RejectNewData()
		{
			m_propsUpdatedValues.Clear();
		}

		/// <summary>
		/// ��������� ������
		/// </summary>
		/// <param name="con"></param>
		public void Load(XStorageConnection con)
		{
			if (m_context == null)
				throw new InvalidOperationException("����� ����� �������������� ������ � ������ ������������� ����� � DomainObjectDataSet");
			if (!IsNew)
				m_context.loadInternal(con, ObjectType, ObjectID, this);
		}

		/// <summary>
		/// �������� �� XObjectBase - �� ������������!
		/// </summary>
        /*public override XObjectDependency[] References
		{
			get { throw new NotSupportedException(); }
		}*/

		/// <summary>
		/// ������������� ��� ������� ������� ���������� �������. �������� ������ ��� ����������� ��������
		/// </summary>
		/// <param name="bToDelete"></param>
		public void SetDeleted(bool bToDelete)
		{
			if (IsNew)
				throw new InvalidOperationException("����� ������ �� ����� ���� ������� ��� ���������");
			m_bToDelete = bToDelete;
		}
		
		public override string ToString()
		{
			return ObjectType + "[" + ObjectID + "]";
		}

		/// <summary>
		/// ������������� ����� ������������� �������
		/// </summary>
		/// <param name="newOID"></param>
		
	}

	/// <summary>
	/// �������� ��������� DomainObjectDataSet/DomainObjectData ��� ��������� �� ������ �������
	/// </summary>
	public enum DomainObjectDataSetWalkingStrategies
	{
		/// <summary>
		/// ������������ ������ ����� �������� �������
		/// </summary>
		UseOnlyUpdatedProps,
		/// <summary>
		/// ������������ ������ ����������� �������� �������
		/// </summary>
		UseOnlyLoadedProps,
		/// <summary>
		/// ������������ ������ ����� ��������, � ���� ��� �����������, �� ����������� ��������
		/// </summary>
		UseUpdatedPropsThanLoadedProps,
	}

	public class DomainObjectDataSet
	{
		/// <summary>
		/// ��������� ��������� DomainObjectDataSet ��� �������� ������� �� ��, ����� ������ �������� ��� ���������� � ���������
		/// </summary>
		public enum PartialObjectMergeStrategies
		{
			/// <summary>
			/// ��������� ������������� ��������, ��������� �� �������
			/// </summary>
			AddMissingProps,
			/// <summary>
			/// �������� ��� ��������, �.�. ������ ��������� ������������� ������� �� ��
			/// </summary>
			ReplaceAllProps,
			/// <summary>
			/// ��������� ������������� ��������, ������������ ���������� � ������������ � � ������ ����������� ����������� ����������
			/// </summary>
			UpdatePropsWithCheck
		}

		/// <summary>
		/// �������� ��������� DomainObjectDataSet/DomainObjectData ��� ������������� ��������� �������������� � ��������� �������� ��������.
		/// ��� ��������� � LOB-������� ������ ������ ������������ ������� LoadOnlyRequiredProp.
		/// </summary>
		public enum PartialObjectPropLoadStrategies
		{
			/// <summary>
			/// ��������� ���� ������
			/// </summary>
			LoadEntireObject,
			/// <summary>
			/// ��������� ������ �������� ���������� ��������
			/// </summary>
			LoadOnlyRequiredProp
		}


		private XModel m_xmodel;
		private IDictionary m_objects = new HybridDictionary();
		private PartialObjectMergeStrategies m_strategy = PartialObjectMergeStrategies.AddMissingProps;

		public DomainObjectDataSet(XModel xmodel)
		{
			m_xmodel = xmodel;
		}

		public void Add(DomainObjectData xobj)
		{
			string sKey = getKey(xobj);
			if (m_objects.Contains(sKey))
				throw new ArgumentException("��������� ��� �������� ������ ������: " + xobj.ToString());
			m_objects.Add(sKey, xobj);
			xobj.attach(this);
		}

		public bool Remove(DomainObjectData xobj)
		{
			return Remove(xobj.ObjectType, xobj.ObjectID);
		}

		public bool Remove(string sObjectType, Guid ObjectID)
		{
			
			string sKey = getKey(sObjectType, ObjectID);
			if (m_objects.Contains(sKey))
			{
				DomainObjectData xobj = (DomainObjectData)m_objects[sKey];
				xobj.detach();
				m_objects.Remove(sKey);
				return true;
			}
			return false;
		}
		private string getKey(string sObjectType, Guid ObjectID)
		{
			return sObjectType + ":" + ObjectID.ToString();
		}

		private string getKey(DomainObjectData xobj)
		{
			return getKey(xobj.ObjectType,  xobj.ObjectID);
		}

		/// <summary>
		/// ���� � ��������� ������ � ��������� ����� � ���������������, �, ���� �� �������, ������� ��������
		/// ����������� �������� ������� �� ��������.
		/// � �� ��������� �� ����������.
		/// </summary>
		/// <param name="sObjectType">��� �������</param>
		/// <param name="ObjectID">������������� �������</param>
		/// <returns></returns>
		public DomainObjectData GetLoadedStub(string sObjectType, Guid ObjectID)
		{
			DomainObjectData xobj = Find(sObjectType, ObjectID);
			if (xobj == null)
			{
				xobj = new DomainObjectData (m_xmodel.FindTypeByName(sObjectType), ObjectID, false, false, this);
				Add(xobj);
			}
			return xobj;
		}

		/// <summary>
		/// ������� � ������� ��������� �������� ������� �� ��
		/// ��������: ���� � ��������� ��� ���������� ������ � ����� ��������������� ��������� ����������
		/// � �� ��������� �� ����������.
		/// </summary>
		/// <param name="sObjectType">��� �������</param>
		/// <param name="ObjectID">������������� �������</param>
		/// <param name="nTS">timespamp �������</param>
		/// <returns></returns>
		public DomainObjectData CreateStubLoaded(string sObjectType, Guid ObjectID, Int64 nTS)
		{
            DomainObjectData xobj = new DomainObjectData(m_xmodel.FindTypeByName(sObjectType), ObjectID, false, false, this, nTS);
			Add(xobj);
			return xobj;
		}

		public DomainObjectData CreateStubNew(string sObjectType)
		{
            DomainObjectData xobj = new DomainObjectData(m_xmodel.FindTypeByName(sObjectType), Guid.NewGuid(), true, false, this);
			// TOTHING: ������ ����� �� ������������� �������� �� ��������� ?
			Add(xobj);
			return xobj;
		}

		public DomainObjectData CreateToDelete(string sObjectType, Guid ObjectID)
		{
            DomainObjectData xobj = new DomainObjectData(m_xmodel.FindTypeByName(sObjectType), ObjectID, false, true, this);
			Add(xobj);
			return xobj;
		}

		public DomainObjectData CreateToDelete(string sObjectType, Guid ObjectID, Int64 nTS)
		{
            DomainObjectData xobj = new DomainObjectData(m_xmodel.FindTypeByName(sObjectType), ObjectID, false, true, this, nTS);
			Add(xobj);
			return xobj;
		}

		public DomainObjectData CreateStub(string sObjectType, Guid ObjectID, bool bIsNew)
		{
            DomainObjectData xobj = new DomainObjectData(m_xmodel.FindTypeByName(sObjectType), ObjectID, bIsNew, false);
			Add(xobj);
			return xobj;
		}

		/// <summary>
		/// ������� ����� ������ �� ����������, ������������ �������� �� ���������
		/// LOB-�������� �� ���������
		/// </summary>
		/// <param name="sObjectType">������������ ���� �������</param>
		/// <param name="bCreatePropHandlers">true - ��������� ��� ������� �������-���������</param>
		/// <returns></returns>
		public DomainObjectData CreateNew(string sObjectType, bool bCreatePropHandlers)
		{
			DomainObjectData xobj = CreateStubNew(sObjectType);
			foreach(XPropInfoBase propInfo in xobj.TypeInfo.Properties)
			{
				// ���� ��� ������� ��������� �������-���������
				if (bCreatePropHandlers)
				{
					if (propInfo is XPropInfoObjectArray || propInfo is XPropInfoObjectLink)
					{
						xobj.SetUpdatedPropValue(propInfo.Name, new Guid[0]);
					}
					else
						xobj.SetUpdatedPropValue(propInfo.Name, DBNull.Value);
				}
				if (propInfo is IXPropWithDefaultValue)
				{
					if (((propInfo as IXPropWithDefaultValue).DefaultType & XPropDefaultType.Xml) > 0)
					{
						// ���� �������� �� ��������� ������, �� ��� ��������� ����� ����� �������������� ������ "������� �����/����"
						if (propInfo.VarType == XPropType.vt_date || propInfo.VarType == XPropType.vt_time || propInfo.VarType == XPropType.vt_dateTime )
						{
							if ((propInfo as XPropInfoDatetime).IsCurrentDateDefault)
								xobj.SetUpdatedPropValue(propInfo.Name, DateTime.Now);
						}
						else if (propInfo is XPropInfoString)
							xobj.SetUpdatedPropValue(propInfo.Name, ((XPropInfoString)propInfo).DefaultValue);
						else if (propInfo is XPropInfoNumeric)
							xobj.SetUpdatedPropValue(propInfo.Name, ((XPropInfoNumeric)propInfo).DefaultValue);
						else if (propInfo is XPropInfoBoolean)
							xobj.SetUpdatedPropValue(propInfo.Name, ((XPropInfoBoolean)propInfo).DefaultValue);
					}
				}
			}
			return xobj;
		}

		/// <summary>
		/// ��������� � �������� ������ ��������� ���� � ��������������
		/// ���� ����������� ������ ��� ����, �� �������� �� ���������, �� ����������� � ������������� ������� � ������������ � ������� ���������� DomainObjectDataSetPartialObjectUpdateStrategies
		/// ���� ������ �������� ���������, �� �� ����� �� �����������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="sObjectType"></param>
		/// <param name="ObjectID"></param>
		/// <returns></returns>
		public DomainObjectData Load(XStorageConnection con, string sObjectType, Guid ObjectID)
		{
			DomainObjectData xobjOriginal = Find(sObjectType, ObjectID);
			return loadInternal(con, sObjectType, ObjectID, xobjOriginal);
		}

		/// <summary>
		/// ���������� �����. ��� �� Load, �� �� ��������� Find(sObjectType, ObjectID)
		/// </summary>
		/// <param name="con"></param>
		/// <param name="sObjectType"></param>
		/// <param name="ObjectID"></param>
		/// <param name="xobjOriginal">������������ ������ (���� �����������, �� null)</param>
		/// <returns></returns>
		internal DomainObjectData loadInternal(XStorageConnection con, string sObjectType, Guid ObjectID, DomainObjectData xobjOriginal)
		{
			DomainObjectData xobjToLoad = null;
			DomainObjectData xobjResult;
			bool bNeedMerge = false;
			bool bNeedLoad;

			if (xobjOriginal == null)
			{
				// ������� ������ ��� - ������ �������� � �������� ������ �������
				bNeedLoad = true;
				xobjToLoad = GetLoadedStub(sObjectType, ObjectID);
				xobjResult = xobjToLoad;
			}
			else if (!xobjOriginal.IsFullyLoaded)
			{
				// ������ ����, �� �������� �� ��������� - ����� �������, � ����� �������� �������
				bNeedLoad = true;
				bNeedMerge = true;
				// �������� ������ ��� ����� � ���������� (DomainObjectDataSet'��)
                xobjToLoad = new DomainObjectData(m_xmodel.FindTypeByName(sObjectType), ObjectID, false, false);
				xobjResult  = xobjOriginal;
			}
			else
			{
				// ��� ���� ��������� ����������� ������ - ������ ������ �� �����
				bNeedLoad = false;
				xobjResult  = xobjOriginal;
			}

			if (bNeedLoad)
			{
				LoadObject(con, xobjToLoad);
				if (bNeedMerge)
				{
					xobjOriginal.SetTS(xobjToLoad.TS);
					foreach(string sPropName in xobjToLoad.LoadedPropNames)
					{
						if (xobjOriginal.HasLoadedProp(sPropName))
						{
							if (m_strategy == PartialObjectMergeStrategies.UpdatePropsWithCheck)
							{
								// �������� ���� � ���� ��������� �� ����������
								if (xobjOriginal.GetLoadedPropValue(sPropName) != xobjToLoad.GetLoadedPropValue(sPropName))
									throw new ApplicationException("�������� �������� " + sPropName + " ����������");
							}
							else if (m_strategy == PartialObjectMergeStrategies.ReplaceAllProps)
							{
								// �������� ���� � ���� ��������
								xobjOriginal.SetLoadedPropValue(sPropName, xobjToLoad.GetLoadedPropValue(sPropName));
							}
						}
						else
						{
							// �������� ����� �� ����
							xobjOriginal.SetLoadedPropValue(sPropName, xobjToLoad.GetLoadedPropValue(sPropName));
						}
					}
				}
			}
			return xobjResult;
		}

		/// <summary>
		/// ��������� ������ ����������� �������
		/// ��������: ��������� ������, ��������� ��� � �������� fillObjectPropertiesFromDataReader
		/// ����������: ��� ������������ ����������� ������ ���������������� (� ������� �� Load)
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">����������� ������</param>
		/// <exception cref="XObjectNotFoundException">������ �� ��������� � ��</exception>
		public void LoadObject(XStorageConnection con, DomainObjectData xobj)
		{
			XTypeInfo typeInfo = xobj.TypeInfo;		// ���������� ����
			if (typeInfo.IsTemporary)
				throw new ArgumentException("���������� ��������� ������ ���������� �������" + typeInfo.Name);
			// �������� ������ �������: ��������������� ������ ������ o.ObjectID = <�������� GUID>	
			using(XDbCommand cmd = con.CreateCommand(
					  String.Format("{0} WHERE o.{1}={2}", 
					  con.GetSelectSqlQueryForType(typeInfo),		// 0
					  con.ArrangeSqlName("ObjectID"),				// 1
					  con.GetParameterName("ObjectID"))				// 2
					  ))
			{
				cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);					
				cmd.CommandType = CommandType.Text;
				Trace.WriteLine("LoadObject. Execute query: " + cmd.CommandText, "ExecuteSQL");

				IXDataReader dataReader = null;
				try
				{
					dataReader = cmd.ExecuteXReader();
					if (dataReader.Read())
					{
						// �������� ��� �������� ������� �� dataReader'a
						fillObjectPropertiesFromDataReader(dataReader, xobj);
					}
					else
					{
						// ���� ������ �� ������ - ���������� ����������
						throw new XObjectNotFoundException( xobj.ObjectType, xobj.ObjectID );
					}
				}
				// ����� ������ ���������� �������. ������ ����� ����� ����, ���� ���������� �� ������������� ��������� ��
				catch(XDbException ex)
				{
					// ���������� XObjectNotFoundException �� �������� �� XDbException, ������� ����� �� ��� �� �������
					throw new XDbException("������ ��� �������� ������� " + xobj.ToString() + ": " + ex.Message, ex);
				}
				finally
				{
					if (dataReader != null)
						dataReader.Close();
				}
			}
		}

		/// <summary>
		/// ��������� ������ xobj ������� ��������� �������.
		/// ��� LOB-������� ������������ ������ ������.
		/// </summary>
		/// <param name="dataReader">reader � �������. 1-�� ���� ObjectID, 2-�� ts, ����� ������� ���� ��������� �������. 
		/// LOB-�������� ������������, �� ��� ��� ������������ ������ ������</param>
		/// <param name="xobj">������-�������� �������</param>
		protected void fillObjectPropertiesFromDataReader(IXDataReader dataReader, DomainObjectData xobj)
		{
			string sPropName;
			XPropInfoBase propInfo;
			object vValue;
			long nTS = -1;
			if (!dataReader.IsDBNull(1))			// ���� �� ts
			{
				nTS = dataReader.GetInt64(1);
			}
			xobj.SetTS(nTS);
			// 0 - ObjectID, 1 - TS, �������� ���������� � ������� 2
			for(int i=2;i<dataReader.FieldCount;++i)
			{
				sPropName = dataReader.GetName(i);
				propInfo = xobj.TypeInfo.GetProp(sPropName);
				if (propInfo is IXPropInfoScalar)
				{
					// ��������� ��������
					vValue = readPropValueFromDB(dataReader, propInfo.VarType, i);
					if (propInfo.VarType == XPropType.vt_bin || propInfo.VarType == XPropType.vt_text)
					{
						// ��� LOB-������� readPropValueFromDB ���������� ������ ������!
						Debug.Assert(vValue is Int32, "��� LOB-������� readPropValueFromDB ������ ���������� ������ ������");
						xobj.SetLoadedPropDataSize(sPropName, (int)vValue);
					}
					else
					{
						xobj.SetLoadedPropValue(sPropName, vValue);
					}
				}
				else
					throw new ArgumentException("� DomainObjectDataSet.fillObjectPropertiesFromDataReader ������ ������������ IXDataReader ������ � ��������� ��������� ������� �������");
			}
		}

		/// <summary>
		/// ��������� �������� ���������� �������� �� ���� DataReader'a.
		/// ��� LOB-������� ��������� � ������������ ������ ������
		/// </summary>
		/// <param name="dataReader">������� ������������������ DataReader</param>
		/// <param name="vt">��� ��������</param>
		/// <param name="i">������ ������� ��������</param>
		/// <returns>�������� �������� ��� DBNull.Value ��� NULL-�����, ��� LOB-������� - ������ ������ (Int32)</returns>
		protected object readPropValueFromDB(IXDataReader dataReader, XPropType vt, int i)
		{
			object vValue = DBNull.Value;
			switch(vt)
			{
				case XPropType.vt_bin:
				case XPropType.vt_text:
					if (dataReader.IsDBNull(i))
						vValue = 0;
					else
						vValue = dataReader.GetInt32(i);
					break;
				case XPropType.vt_string		:
					if (!dataReader.IsDBNull(i))
						vValue = dataReader.GetString(i);
					break;
				case XPropType.vt_object		:
					if (!dataReader.IsDBNull(i))
						vValue = dataReader.GetGuid(i);
					break;
				default:
					if (!dataReader.IsDBNull(i))
						vValue = dataReader.GetValue(i, vt);
					break;
			}
			return vValue;
		}

		/// <summary>
		/// ���� � ��������� ������ � ��������� ����� � ���������������
		/// </summary>
		/// <param name="sObjectType">��� �������</param>
		/// <param name="ObjectID">������������� �������</param>
		/// <returns>��������� DomainObjectData ��� null, ���� ������ �� ������</returns>
		public DomainObjectData Find(string sObjectType, Guid ObjectID)
		{
			return (DomainObjectData)m_objects[getKey(sObjectType, ObjectID)];
		}

		/// <summary>
		/// ���������� ��������� DomainObjectData ������� � ��������� ����� � ���������������
		/// ���� ������ ��������� � ���������, �� ������������ ��, ����� ����������� �� ��
		/// </summary>
		/// <param name="con"></param>
		/// <param name="sObjectType">��� �������</param>
		/// <param name="ObjectID">������������� �������</param>
		/// <returns>��������� DomainObjectData</returns>
		/// <exception cref="XObjectNotFoundException">������ �� ������ �� � ���������, �� � ��</exception>
		public DomainObjectData Get(XStorageConnection con, string sObjectType, Guid ObjectID)
		{
			DomainObjectData xobj = Find(sObjectType, ObjectID);
			if (xobj == null)
				xobj = loadInternal(con, sObjectType, ObjectID, xobj);
			return xobj;
		}

		/// <summary>
		/// ���������� ������������ ���� ������� �������� ��������� �������� ��������� ����
		/// </summary>
		/// <param name="sObjectType">������������ ����</param>
		/// <param name="sPropName">������������ ��������</param>
		/// <param name="con"></param>
		/// <returns>������������ ���� ������� �������� ��������</returns>
		private string getObjectValueTypeName(string sObjectType, string sPropName, XStorageConnection con)
		{
			XPropInfoBase xprop_base = con.MetadataManager.GetTypeInfo(sObjectType).GetProp(sPropName);
			if (!(xprop_base is XPropInfoObject))
				throw new ArgumentException("�������������� ������ ��������� ��������");
			return ((XPropInfoObject)xprop_base).ReferedType.Name;
		}

		/// <summary>
		/// ���������� ������-�������� ��������, ��������� ObjectPath'�� ��������� ��������� ������� ������������ ��������� �������.
		/// ��������� �������, ������� �� ���� �������, ���������.
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">������, ������������ �������� ����������� OPath</param>
		/// <param name="sOPath">������� ��������� ��������� �������</param>
		/// <param name="strategy">��������� ������������� ������� �������: ����� ������ ��� �����������</param>
		/// <param name="bAllowLoad">���������� ��������� ������������� � ��������� ������� �� ��</param>
		/// <returns>������-�������� ��� null</returns>
		public DomainObjectData Get(XStorageConnection con, DomainObjectData xobj, string sOPath, DomainObjectDataSetWalkingStrategies strategy, bool bAllowLoad)
		{
			return Get(con, xobj, sOPath, strategy, bAllowLoad, PartialObjectPropLoadStrategies.LoadEntireObject);
		}

		/// <summary>
		/// ���������� ������-�������� ��������, ��������� ObjectPath'�� ��������� ��������� ������� ������������ ��������� �������.
		/// ��������� �������������� ��������� �������� ��������, ������� �� ���� �������: 
		/// ���� ��������� ����������� �������� ��������, ���� ��������� ������ ���������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">������, ������������ �������� ����������� OPath</param>
		/// <param name="sOPath">������� ��������� ��������� �������</param>
		/// <param name="strategy">��������� ������������� ������� �������: ����� ������ ��� �����������</param>
		/// <param name="bAllowLoad">���������� ��������� ������������� � ��������� ������� �� ��</param>
		/// <param name="propLoadStrategy">��������� �������� ������������� ��������, ������� �� ���� �������</param>
		/// <returns>������-�������� ��� null</returns>
		public DomainObjectData Get(XStorageConnection con, DomainObjectData xobj, string sOPath, DomainObjectDataSetWalkingStrategies strategy, bool bAllowLoad, PartialObjectPropLoadStrategies propLoadStrategy)
		{
			string[] aPathParts = sOPath.Split('.');
			string cur_ObjectType = xobj.ObjectType; 
			Guid cur_ObjectID = xobj.ObjectID;
			string sPropName;							// ������������ ��������
			object vPropValue;							// �������� ��������
			bool bLoadObject;							// ������� ������������� �������� ������
			bool bLoadProp;								// ������� ������������� �������� ��������

			for(int i=0; i<aPathParts.Length; ++i)
			{
				vPropValue = null;
				xobj = Find(cur_ObjectType, cur_ObjectID);
				sPropName = aPathParts[i];
				// �������� ��� ������� �������� �������� ������� - ��������� ���������
                if (!(m_xmodel.FindTypeByName(cur_ObjectType).GetProp(sPropName) is XPropInfoObjectScalar))
					throw new ArgumentException("�������� " + sPropName + " � ������� ������� " + sOPath + " �� �������� ��������� ���������");
				bLoadObject = false;
				bLoadProp   = false;
				if (xobj == null)
				{
					// ������� ������ ����������� � ��������� - ����� �������, ���� �����
					if (!bAllowLoad || strategy == DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps)
						return null;
					bLoadObject = true;
				}
				else
				{
					// ������ ����: ������� �������� �������� � ������� ������������� �������� ������� �� ��
					vPropValue = getPropValue(xobj, sPropName, strategy, bAllowLoad, out bLoadProp);
					// ���� �������� ���� �������, �� ��������� ��������� ������� ���� ������ � ������ ���������� ��-��..
					if (bLoadProp && propLoadStrategy == PartialObjectPropLoadStrategies.LoadEntireObject)
					{
						bLoadObject = true;
						bLoadProp   = false;	// - �� ������ ������
					}
				}
				// ���� �����, �� ���� �������� ��� � ���� ������� (bLoad=true) � �����, ���� �������� ���� (� vPropValue)

				if (bLoadObject)
				{
					// ���� ��������� ������ �������
					xobj = Load(con, cur_ObjectType, cur_ObjectID);
					// � ������ ����� �������� �������� �������� (��� ��� ����� ������ �����������, ����� ������� ���� �� �������)
					vPropValue = xobj.GetLoadedPropValue(sPropName);
				}
				else if (bLoadProp)
				{
					// ������ ����, ���� ��������� ������ ���� ��������
					vPropValue = loadScalarNonLOBProp(con, xobj, sPropName);
				}

				// � ��� ���� �������� ���������� ���������� �������� (sPropName) � vPropValue
				if (vPropValue == null || vPropValue is DBNull)
					return null;
				cur_ObjectID = (Guid)vPropValue;
				// ������� ������������ ���� �������-�������� ��������
				cur_ObjectType = getObjectValueTypeName(cur_ObjectType, sPropName, con);
			}

			// ���� �����, ������ ��� �������� ������������� �������-�������� ���������� �������� - cur_ObjectID, ������ ������
			// ���� ������ ���� � ��������� ��� � ������
			xobj = Find(cur_ObjectType, cur_ObjectID);
			if (xobj != null)
				return xobj;
			// ����� �������� ������, �� ������ � ������ ���� ����� ������� � ����� ������� ������ �������
			if (bAllowLoad && propLoadStrategy == PartialObjectPropLoadStrategies.LoadEntireObject)
				return Load(con, cur_ObjectType, cur_ObjectID);
			// ����� ������ ��������
			return GetLoadedStub(cur_ObjectType, cur_ObjectID);
		}

		/// <summary>
		/// ���������� �������� ��������� �������� ��������� ������� � ������ ��������� ��������� � ���������� ��������� ������ �� ��
		/// ���� �������� �����������, � ��������� � ���������� �������� �� �� ���������, ������������ ������� ������������� ��������� ������ (bLoad)
		/// </summary>
		/// <param name="xobj">������</param>
		/// <param name="sPropName">������������ ��������</param>
		/// <param name="strategy">��������� ��������� �������� �������� (����� �������� ��� �� �� ��� ������� 1-��, ����� 2-��)</param>
		/// <param name="bAllowLoad">������� ���������� �������� ������ �� ��</param>
		/// <param name="bLoad">������� ������������� ��������� ������, �.�. �������� ��-�� �����������</param>
		/// <returns>�������� ��������, ��� ��� ��������� � DomainObjectData</returns>
		protected object getPropValue(DomainObjectData xobj, string sPropName, DomainObjectDataSetWalkingStrategies strategy, bool bAllowLoad, out bool bLoad)
		{
			object vPropValue = null;						// �������� ��������
			bLoad = false;
			
			if (xobj.IsNew)
			{
				// ���� ������ ����� � �������� ����������� (��� ����� ���� ������ �����������), �� ���������� ��� ������
				// ����������: ��� ����� �������� ������ ���������� ����������� ��������, �.�. � ��� ������ ���
				if (xobj.HasUpdatedProp(sPropName))
					vPropValue = xobj.GetUpdatedPropValue(sPropName);
				else
					return null;
			}
			else
			{
				// ������ ���� � �� �� �����:

				// ���� ��������� ������������ ������ ����������� ��������
				if (strategy == DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps)
				{
					if (xobj.HasUpdatedProp(sPropName))
						vPropValue = xobj.GetUpdatedPropValue(sPropName);
					else
						// �������� ���, � ������� ������ (�.�. ������� ������ UseOnlyUpdatedProps) -  ���������� ��� ������
						return null;
				}
				else
				{
					// ���� ��������� ������������ ������ ����������� ��������, � ��� ��� ��� 
					// ��������� ������������ ����������� ��� �����������, � ��� �� ����, �� �������
					if (strategy == DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps && !xobj.HasLoadedProp(sPropName) ||
						strategy == DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps && !xobj.HasUpdatedProp(sPropName) && !xobj.HasLoadedProp(sPropName)
						)
					{
						// ������� �������� ��� - ���� ����� ������ �������, ����� ���������� ��� ������
						if (bAllowLoad)
							bLoad = true;
						else
							return null;
					}
					else if (strategy == DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps)
					{
						vPropValue = xobj.GetLoadedPropValue(sPropName);
					}
					else if (strategy == DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps)
					{
						if (xobj.HasUpdatedProp(sPropName))
							vPropValue = xobj.GetUpdatedPropValue(sPropName);
						else
							vPropValue = xobj.GetLoadedPropValue(sPropName);
					}
				}
			}			
			return vPropValue;
		}

		/// <summary>
		/// ���������� �������� ���������� ���������� �������� ������������ ��������� �������, ��������� ObjectPath'��.
		/// ������������ �������� ���������� ��������. 
		/// � ������ NULL-�������� ������ �� ������� � ������� ���������� Guid.Empty.
		/// ��������� �������, ������� �� ���� �������, ���������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">������, ������������ �������� ���������� ��������</param>
		/// <param name="sOPath">������� �������</param>
		/// <param name="strategy">��������� ��������� �������� �������� (����� �������� ��� �� �� ��� ������� 1-��, ����� 2-��)</param>
		/// <param name="bAllowLoad">������� ����������� ��������� ������ �� ��, ���� �������� ��-�� ���������� � ��������� ��������� ������������ �������� �� ��</param>
		/// <returns>���� �������� NULL (����� �� �������), ������������ Guid.Empty</returns>
		public Guid GetScalarObjectPropValue(XStorageConnection con, DomainObjectData xobj, string sOPath, DomainObjectDataSetWalkingStrategies strategy, bool bAllowLoad)
		{
			return GetScalarObjectPropValue(con, xobj, sOPath, strategy, bAllowLoad, PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);
		}

		/// <summary>
		/// ���������� �������� ���������� ���������� �������� ������������ ��������� �������, ��������� ObjectPath'��.
		/// ������������ �������� ���������� ��������. 
		/// � ������ NULL-�������� ������ �� ������� � ������� ���������� Guid.Empty.
		/// ��������� �������������� ��������� �������� ��������, ������� �� ���� �������: 
		/// ���� ��������� ����������� �������� ��������, ���� ��������� ������ ���������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">������, ������������ �������� ���������� ��������</param>
		/// <param name="sOPath">������� �������</param>
		/// <param name="strategy">��������� ��������� �������� �������� (����� �������� ��� �� �� ��� ������� 1-��, ����� 2-��)</param>
		/// <param name="bAllowLoad">������� ����������� ��������� ������ �� ��, ���� �������� ��-�� ���������� � ��������� ��������� ������������ �������� �� ��</param>
		/// <param name="propLoadStrategy">��������� �������� ������������� ��������, ������� �� ���� �������</param>
		/// <returns>���� �������� NULL (����� �� �������), ������������ Guid.Empty</returns>
		public Guid GetScalarObjectPropValue(XStorageConnection con, DomainObjectData xobj, string sOPath, DomainObjectDataSetWalkingStrategies strategy, bool bAllowLoad, PartialObjectPropLoadStrategies propLoadStrategy)
		{
			if (sOPath == null)
				throw new ArgumentNullException("sOPath");
			string[] aPathParts = sOPath.Split('.');
			DomainObjectData xobj_target;
			object vPropValue;							// �������� ��������
			string sPropName;							// ������������ ��������

			// ������� ������, ��������� ��������� ��������� � �������
			if (aPathParts.Length > 1)
			{
				// �������� ����� ������ ��� ���������� �������� � ����
				string[] aPathPartsNew = new string[aPathParts.Length-1];
				Array.Copy(aPathParts, aPathPartsNew, aPathParts.Length-1);
				sOPath = String.Join(".", aPathPartsNew );
				sPropName = aPathParts[aPathParts.Length-1];
				xobj_target = Get(con, xobj, sOPath, strategy, bAllowLoad, propLoadStrategy);
				if (xobj_target == null)
					return Guid.Empty;
			}
			else
			{
				sPropName = aPathParts[0];
				xobj_target = xobj;
			}
			// ���� �������� � ������� ���, ������ �� �������� �������� - ������������ ��� �������, ���� ���� �������� (� ���-�� �� loadPropStrategy)
			bool bLoad;
			vPropValue = getPropValue(xobj_target, sPropName, strategy, bAllowLoad, out bLoad);
			if (bLoad)
			{
				if (propLoadStrategy == PartialObjectPropLoadStrategies.LoadEntireObject)
				{
					xobj_target.Load(con);
					vPropValue = xobj_target.GetLoadedPropValue(sPropName);
				}
				else
					vPropValue = loadScalarNonLOBProp(con, xobj_target, sPropName);
			}
			if (vPropValue == null || vPropValue is DBNull)
				return Guid.Empty;
			return (Guid)vPropValue;
		}

		/// <summary>
		/// ���������� ��� �������, ������� �� ������� ������� ������������� � ��������� �������.
		/// ������� ������� �� ���� �� ������� ����������� ���������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">������ �������� ��������</param>
		/// <param name="sOPath">������� ������������ ��������. ��� �������� ����� ���������� ������ ���� ��������� ����������</param>
		public void PreloadProperty(XStorageConnection con, DomainObjectData xobj, string sOPath)
		{
			string[] aPathParts = sOPath.Split('.');
			xobj = Get(con, xobj.ObjectType, xobj.ObjectID);
			preloadPropertyInternal(con, xobj, aPathParts, 0, PartialObjectPropLoadStrategies.LoadEntireObject);
		}

		/// <summary>
		/// ��������� �������� �������. ���� �������� �������� ��� ������������, �� �������� ��� ��� �� �����������.
		/// ���� ������ �����������, �� ����������� ������ �������� ������������ ��������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">������ �������� ��������</param>
		/// <param name="sPropName">������������ ������������ ��������</param>
		public void LoadProperty(XStorageConnection con, DomainObjectData xobj, string sPropName)
		{
			preloadPropertyInternal(con, xobj, new string[] {sPropName}, 0, PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);
		}

		/// <summary>
		/// ���������� ����� �������� �������� ��� �������� ������� (������ �� ����� �������������� ���������).
		/// ��������!
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">������, ��� �������� ��������� � ������� aPathParts ��� �������� nIndex</param>
		/// <param name="aPathParts">������� �������</param>
		/// <param name="nIndex">������� ������ � aPathParts</param>
		/// <param name="propLoadStrategy">��������� �������� ������������� ��������, ������� �� ���� �������</param>
		private void preloadPropertyInternal(XStorageConnection con, DomainObjectData xobj, string[] aPathParts, int nIndex, PartialObjectPropLoadStrategies propLoadStrategy)
		{
			string sPropName = aPathParts[nIndex];		// ������������ ��������
			// ���� ���-�� ������ ���������� ObjectID, �� ��� � ������� ���� ������ � ����� ���� ������ ���������
			if (sPropName == "ObjectID")
				return;
			XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
			if (propInfo == null)
				throw new ArgumentException("����������� ������������ �������� \"" + sPropName + "\" ������� \"" + xobj.ObjectType + "\", ��������� ��� ��������� ������ (������� ��������: " + String.Join(".", aPathParts) + ")");

			if (propInfo is XPropInfoObjectScalar)
			{
				// ��������� ��������� �������� - ������� ������ ��������. 
				xobj = Get(con, xobj, sPropName, DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true, propLoadStrategy);
				// ���� �������� �� ��������� � ������ �������� �������� (��-�� not null), �� ���������� ������ ������
				if (xobj != null && nIndex < aPathParts.Length - 1)
					preloadPropertyInternal(con, xobj, aPathParts, nIndex + 1, propLoadStrategy);
			}
			else if (propInfo is XPropInfoObject)
			{
				// ���������, �� �� ��������� ��������, �.�. ����� ��������� (���������, ������, ����)
				Guid[] values;
				// ���� �������� ��� ���������, �� �������� ������� ��� �� �����
				if (xobj.HasLoadedProp(sPropName))
					values = (Guid[])xobj.GetLoadedPropValue(sPropName);
				else
					values = loadArrayProp(con, xobj, sPropName);
				// ���� �������� �� ���������..
				if (nIndex < aPathParts.Length - 1)
				{
					string sValueObjectType = ((XPropInfoObject)propInfo).ReferedType.Name;
					// ..��������� �� ��������-���������
					foreach(Guid valueOID in values)
					{
						preloadPropertyInternal(con, Get(con, sValueObjectType , valueOID), aPathParts, nIndex+1, propLoadStrategy);
					}
				}
			}
			else if (propInfo.VarType == XPropType.vt_bin || propInfo.VarType == XPropType.vt_text)
			{
				// LOB - ��������. ��� ����� ����������, �� � ������� ������� ��� ������ ���� ���������, �.�. ��-�� �� �������� ��������
				if (nIndex != aPathParts.Length - 1)
					throw new ArgumentException("LOB-�������� " + sPropName + " � ������� ������������ ������� �� ���������");
				loadLOBProp(con, xobj, sPropName);
			}
			else
			{
				// ����� ������ ��������� �������� - ��o ������ ���� ��������� � �������
				if (nIndex != aPathParts.Length - 1)
					throw new ArgumentException("����������� �������� " + sPropName + " � ������� ������������ ������� �� ���������");
				// ����� �������, ������ ���� ��� ���
				if (!xobj.HasLoadedProp(sPropName))
					loadScalarNonLOBProp(con, xobj, sPropName);
			}
		}

		/// <summary>
		/// ��������� ��������� ��������� �������� � �������
		/// ��� ����� ��������� WHERE ������� � ����������� �� ������� �������� � �������� doLoadArrayProp
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">������ ��������-��������</param>
		/// <param name="sPropName">������������ ��������</param>
		/// <returns>��������� DomainObjectDataArrayPropHandle</returns>
		private Guid[] loadArrayProp(XStorageConnection con, DomainObjectData xobj, string sPropName)
		{
			XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
			if (propInfo.VarType != XPropType.vt_object)
				throw new InvalidOperationException("����� ������ ���������� ��� ��������� ��������� �������");
			XPropInfoObject propInfoObj = (XPropInfoObject)propInfo;
			string sLinkOrder;						// ������� ������� ��������� �����
			Guid[] values;
			switch(propInfoObj.Capacity)
			{
				case XPropCapacity.Scalar:
					throw new ArgumentException("����� ������ ���������� ��� ��������� �������");
				case XPropCapacity.Link:
				case XPropCapacity.LinkScalar:
					// �������� ��� ��������, ��������� ������� � �����
					XPropInfoObjectLink xpropLink = (XPropInfoObjectLink)propInfoObj;
					sLinkOrder = String.Empty;
					if (xpropLink.OrderByProp != null)
						sLinkOrder = " ORDER BY o." + con.ArrangeSqlName(xpropLink.OrderByProp.Name);
					// ��������� ����������
					values = doLoadArrayProp(con, propInfoObj,
						// ���������� � SELECT ����� 
						// WHERE o.{built-on-��������}='{����_��������_�������}' [ORDER BY o.{��������_�������_�����}]
						String.Format(" WHERE o.{0}={1}{2}", 
							con.ArrangeSqlName( xpropLink.ReverseProp.Name ),	// 0
							con.GetParameterName("ObjectID"),					// 1
							sLinkOrder											// 2
						), xobj );
					break;
				case XPropCapacity.Array:
					// ��������� ����������
					values = doLoadArrayProp(con, propInfoObj,
						// ���������� � SELECT �����:
						// , �����.���_������ a WHERE o.ObjectID=a.Value AND a.ObjectID='���� �������� �������'
						// ORDER BY a.k
						String.Format(",{0} a WHERE o.{1}=a.{2} AND a.{1}={3} ORDER BY a.{4}",
							con.GetTableQName( xobj.TypeInfo.Schema, xobj.TypeInfo.GetPropCrossTableName(sPropName)),	// 0
							con.ArrangeSqlName( "ObjectID" ),			// 1
							con.ArrangeSqlName( "Value" ),				// 2
							con.GetParameterName("ObjectID"),			// 3
							con.ArrangeSqlName("k")						// 4
						), xobj );
					break;
				case XPropCapacity.Collection:
					// ��������� ����������
					values = doLoadArrayProp(con, propInfoObj,
						// ���������� � SELECT �����: 
						// , �����.���_��������� a WHERE o.ObjectID=a.Value AND a.ObjectID='���� �������� �������'
						String.Format(",{0} a WHERE o.{1}=a.{2} AND a.{1}={3}",
							con.GetTableQName( xobj.TypeInfo.Schema, xobj.TypeInfo.GetPropCrossTableName(sPropName)),	// 0
							con.ArrangeSqlName( "ObjectID"),				// 1
							con.ArrangeSqlName( "Value"),					// 2
							con.GetParameterName("ObjectID")				// 3
						), xobj );
					break;
				default:
					// XPropCapacity.ArrayMembership, XPropCapacity.CollectionMembership
					XPropInfoObjectArray xpropRev = (XPropInfoObjectArray)propInfoObj.ReverseProp;
					Debug.Assert(xpropRev != null, "�������� �������� ��� array-membership/collection-membership �� �������");
					// ��������� ����������
					values = doLoadArrayProp(con, propInfoObj,
						// ���������� � SELECT �����:
						// , ����� ��������� ��������� (��� �������).��� ��������� ��������� (��� �������)_��������� a WHERE o.ObjectID=a.ObjectID AND a.Value='���� �������� �������'
						String.Format(",{0} a WHERE o.{1}=a.{1} AND a.{2}={3}",
							con.GetTableQName( xpropRev.ReferedType.Schema, xobj.TypeInfo.GetPropCrossTableName(sPropName)),	// 0
							con.ArrangeSqlName("ObjectID"),				// 1
							con.ArrangeSqlName("Value"),				// 2
							con.GetParameterName("ObjectID")			// 3
						), xobj );
					break;
			}
			return values;
		}

		/// <summary>
		/// ��������� SQL-������ �� ��������� ��������-�������� ��������, ��������� ������ ��������-��������, 
		/// ��������� ������������� ������� � ��������, � ��� �������������� ��������������.
		/// �������������� �������� �������� ���������������, ������� � ����������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="propInfo">��������</param>
		/// <param name="sSelectSuffix">��������� SQL �������</param>
		/// <param name="xobj">������-�������� ��������</param>
		private Guid[] doLoadArrayProp(XStorageConnection con, XPropInfoObject propInfo, string sSelectSuffix, DomainObjectData xobj)
		{
			string		sSQL;								// ����� ��������� SELECT
			XTypeInfo	xtypeRef = propInfo.ReferedType;	// �������� ����-�������� ��������
			ArrayList	aValues = new ArrayList();			// ��������� ��� ������������ �������� �������� - ������� ������

			sSQL = con.GetSelectSqlQueryForType(xtypeRef) + (null != sSelectSuffix ? sSelectSuffix : String.Empty);
	
			using(XDbCommand cmd = con.CreateCommand(sSQL))
			{
				Trace.WriteLine("doLoadArrayProp. Execute query: " + sSQL, "ExecuteSQL");
				cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
				cmd.CommandType = CommandType.Text;
				IXDataReader dataReader = null;
				try
				{
					dataReader = cmd.ExecuteXReader();
					while (dataReader.Read())
					{
						// �������� �������� �������-��������
						// (��� ��������� �������� - ��������� �������� false)
						Guid ObjectID = dataReader.GetGuid(0);
						// ������� ��������� ������� �������� � ���������
						DomainObjectData xobjValue = Find(xtypeRef.Name, ObjectID);
						if (xobjValue == null)
							xobjValue = GetLoadedStub(xtypeRef.Name, ObjectID);
						// � �������� �� dateReader'� �������� ������� (���� ������ ��� ���, �� �������� ����������� ������� ������������)
						fillObjectPropertiesFromDataReader(dataReader, xobjValue);
						// ������� ������ � ��������
						aValues.Add(ObjectID);
					}
				}
				// ����� ������ ���������� �������. ������ ����� ����� ����, ���� ���������� �� ������������� ��������� ��
				catch(XDbException ex)
				{
					// ���������� XObjectNotFoundException �� �������� �� XDbException, ������� ����� �� ��� �� �������
					throw new XDbException("������ ��� �������� ������� " + xobj.ToString() + ": " + ex.Message, ex);
				}
				finally
				{
					if (dataReader != null)
						dataReader.Close();
				}
			}
			Guid[] values = new Guid[aValues.Count];
			aValues.CopyTo(values);
			xobj.SetLoadedPropValue(propInfo.Name, values);
			return values;
		}

		/// <summary>
		/// ����� �������� �������� ��������� LOB-��������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">������-�������� ��������</param>
		/// <param name="sPropName">������������ ������������ LOB-��������</param>
		private void loadLOBProp(XStorageConnection con, DomainObjectData xobj, string sPropName)
		{
			XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
			XDbParameter param = con.CreateCommand().CreateParameter("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
			string sWhereClause = con.ArrangeSqlName("ObjectID") + "=" + con.GetParameterName("ObjectID");
			object vData;
			if (propInfo.VarType == XPropType.vt_bin)
			{
				vData = con.LoadBinData(
					con.GetTableQName(xobj.TypeInfo.Schema, xobj.TypeInfo.Name), 
					sPropName, 
					sWhereClause, 
					new XDbParameter[] {param} 
					);
			}
			else if (propInfo.VarType == XPropType.vt_text)
			{
				vData = con.LoadTextData(xobj.TypeInfo.Schema, xobj.TypeInfo.Name, sPropName, sWhereClause, new XDbParameter[] {param} );
			}
			else
				throw new ArgumentException("�������� " + sPropName +  " ����������������� ����: " + propInfo.VarType);

			xobj.SetLoadedPropValue(sPropName, vData);
		}

		/// <summary>
		/// ��������� �������� ���������� ��-LOB �������� (� �.�. ���������� ����������).
		/// ������� ������������ �������� �� ���������, ������ ��������� select-������ � �������������� (���� ����) ������������ ��������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj"></param>
		/// <param name="sPropName"></param>
		/// <returns></returns>
		private object loadScalarNonLOBProp(XStorageConnection con, DomainObjectData xobj, string sPropName)
		{
			XDbCommand cmd = con.CreateCommand(
				String.Format(
				"SELECT {0} FROM {1} WHERE ObjectID = @ObjectID",
				con.ArrangeSqlName(sPropName),
				con.GetTableQName(xobj.SchemaName, xobj.ObjectType)
				));
			cmd.Parameters.Add("ObjectID", DbType.Guid,  ParameterDirection.Input, false, xobj.ObjectID);
			object vValue = null;
			Trace.WriteLine("loadScalarNonLOBProp. Execute query: " + cmd.CommandText, "ExecuteSQL");
			IXDataReader reader = null;
			try
			{
				reader = cmd.ExecuteXReader();
				if (reader.Read())
				{
					XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
					if (propInfo == null)
						throw new ArgumentException("����������� ��������: " + sPropName);
					if (!(propInfo is IXPropInfoScalar))
						throw new ArgumentException("��� �������� ������ ����������� ��������: " + sPropName );
					if (propInfo.VarType == XPropType.vt_bin || propInfo.VarType == XPropType.vt_text)
						throw new ArgumentException("��� �������� ������ LOB-��������: " + sPropName);
					vValue = readPropValueFromDB(reader, propInfo.VarType, 0);
					xobj.SetLoadedPropValue(sPropName, vValue );
				}
				else
				{
					// ���� ������ �� ������ - ���������� ����������
					throw new XObjectNotFoundException( xobj.ObjectType, xobj.ObjectID );
				}
			}
			// ����� ������ ���������� �������. ������ ����� ����� ����, ���� ���������� �� ������������� ��������� ��
			catch(XDbException ex)
			{
				// ���������� XObjectNotFoundException �� �������� �� XDbException, ������� ����� �� ��� �� �������
				throw new XDbException("������ ��� �������� ������� " + xobj.ToString() + ": " + ex.Message);
			}
			finally
			{
				if (reader != null)
					reader.Close();
			}
			return vValue;
		}

		/// <summary>
		/// ������� ����� ������ ���� ��������
		/// </summary>
		public void RejectNewData()
		{
			foreach(DomainObjectData xobj in m_objects.Values)
				xobj.RejectNewData();
		}

	    /// <summary>
		/// ���������� ������ ��������, ���������� ����������/��������, ��������� ����
		/// TODO: ���������� �� generic
		/// </summary>
		/// <param name="sObjectType">��� ��������� ��������</param>
		/// <param name="bOnlyToSave">�������: ������ ������� ��� ����������, ���� false, �� ��� ���������������� ������� ���������</param>
		/// <returns>���� �������� ��������� ���� ��� � ���������, �� ArrayList - ������</returns>
		public ArrayList GetModifiedObjectsByType(string sObjectType, bool bOnlyToSave)
		{
			ArrayList objects = new ArrayList();
			foreach(DomainObjectData xobj in m_objects.Values)
			{
				if ( (xobj.HasNewData || xobj.ToDelete && !bOnlyToSave) && xobj.ObjectType == sObjectType )
					objects.Add(xobj);
			}
			return objects;
		}
		/// <summary>
		/// ���������� ������ ��������, ���������� ����������/��������, �������� �����
		/// TODO: ���������� �� generic
		/// </summary>
		/// <param name="aObjectTypes">���� ��������� ��������</param>
		/// <param name="bOnlyToSave">�������: ������ ������� ��� ����������, ���� false, �� ��� ���������������� ������� ���������</param>
		/// <returns>���� �������� ��������� ���� ��� � ���������, �� ArrayList - ������</returns>
		public ArrayList GetModifiedObjectsByType(string[] aObjectTypes, bool bOnlyToSave)
		{
			if (aObjectTypes == null)
				throw new ArgumentNullException("aObjectTypes");
			if (aObjectTypes.Length == 0)
				throw new ArgumentException("������ ������������ ����� ��������� �������� ������");
			ArrayList objects = new ArrayList();
			foreach(DomainObjectData xobj in m_objects.Values)
			{
				if ( (xobj.HasNewData || xobj.ToDelete && !bOnlyToSave))
				{
					foreach(string sObjectType in aObjectTypes)
						if (xobj.ObjectType == sObjectType)
						{
							objects.Add(xobj);
							break;
						}
				}
			}
			return objects;
		}

		/// <summary>Enumerator ��� �������� �������� �������� ���������, ���������� ������ ��� ����������, � ����� ��������� �������
		/// ���������� 
		/// </summary>
		/// <returns></returns>
		public IEnumerator GetModifiedObjectsEnumerator(bool bOnlyToSave)
		{
			return new DomainObjectDataSetEnumerator(this, bOnlyToSave);
		}

		/// <summary>
		/// Enumerator ���������������� ��������
		/// </summary>
		public class DomainObjectDataSetEnumerator: IEnumerator
		{
			private ArrayList m_objects;
			private IEnumerator m_enumerator;

			public DomainObjectDataSetEnumerator(DomainObjectDataSet dataSet, bool bOnlyToSave)
			{
				m_objects = new ArrayList(dataSet.m_objects.Count);
				foreach(DomainObjectData xobj in dataSet.m_objects.Values)
				{
					if (xobj.HasNewData || xobj.ToDelete && !bOnlyToSave)
						m_objects.Add(xobj);
				}
				m_enumerator = m_objects.GetEnumerator();
			}

			public bool MoveNext()
			{
				return m_enumerator.MoveNext();
			}

			public void Reset()
			{
				m_enumerator.Reset();
			}

			public object Current
			{
				get { return m_enumerator.Current; }
			}
		}
	}
}
