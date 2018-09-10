//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
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
		/// метаданные системы
		/// </summary>
		protected XModel m_xmodel;	
		/// <summary>
		/// Атрибут, "навешиваемый" на XML-свойство для указания, что данные свойства 
		/// предеданы на сервер процедурой сохранения "по частям". Содержимое атрибута -
		/// идентификатор, объединяющий цепочку строк с "кусками" (chunk-ами) данных 
		/// из служебной таблицы
		/// </summary>
		public static readonly string ATTR_CHUNCK_CHAIN_ID = "chunked-chain-id";
		/// <summary>
		/// список обновляемых объектов
		/// </summary>
        protected List<XStorageObjectBase> m_aObjectsToUpdate = new List<XStorageObjectBase>();
        protected Hashtable m_hashObjectsToUpdate = new Hashtable();
		/// <summary>
		/// Список новый (вставляемых) объектов
		/// </summary>
        protected List<XStorageObjectBase> m_aObjectsToInsert = new List<XStorageObjectBase>() ;
		protected Hashtable m_hashObjectsToInsert = new Hashtable();
        
		/// <summary>
		/// Список удаляемых объектов
		/// </summary>
        protected List<object> m_aObjectsToDelete = new List<object>();
		protected Hashtable m_hashObjectsToDelete = new Hashtable();
		/// <summary>
		/// список обновляемых объектов
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
		/// Список новый (вставляемых) объектов
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
		/// Список удаляемых объектов
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
		/// Возвращает метаданные системы
		/// </summary>
		public XModel XModel
		{
			get { return m_xmodel; }
		}


		/// <summary>
		/// Возвращает ключ под которым объект храниться в словаре
		/// </summary>
		/// <param name="xobj"></param>
		/// <returns>Ключ для хранения в словаре</returns>
		protected string getKey(XStorageObjectBase xobj)
		{
			return xobj.ObjectType + ":" + xobj.ObjectID;
		}

		/// <summary>
		/// Добавление объекта в коллекцию обновляемых объектов. Позволяет добавлять один и тот же объект несколько раз.
		/// В отличии от новых и удаляемых объектов, обновляемые могут добавляться явно, т.к. это требуется для "отложенного обновления".
		/// Это случай когда объект сохраняется для SQL оператора: сначала INSERT, а потом UPDATE. 
		/// Отложенное обновление требуется для сохранения сетей объектов (Например, А ссылается на Б, а Б ссылается на А)
		/// </summary>
		/// <param name="xobj">Объект для помещения в список обновляемых</param>
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
		/// Добавление объекта в коллекцию вставляемых объектов
		/// </summary>
		/// <param name="xobj"></param>
		public void AddInserted(XStorageObjectToSave xobj)
		{
			m_aObjectsToInsert.Add(xobj);
			m_hashObjectsToInsert.Add(getKey(xobj), xobj);
		}

		/// <summary>
		/// Добавление объекта в коллекцию удаляемых объектов
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
						// в качестве значения свойства может быть поcле перечисления, надо привести его в элементарному типу
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
				// если свойство участвует в уникальном индексе, запомним это
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
		/// Добавление объекта в датаграмму. Если объект с таким типом и идентификатором уже существует
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
		/// Расносит объекты из списка m_objects по 3-м списка в переданной датаграмме: 
		/// списку удаляемых, обновляемых, вставляемых
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
			// TODO: Здесь вопрос: удаленные объекты могут содержать линки с ссылками и, если да, то надо ли их обрабатывать ?
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
					// пометим свойство специальным атрибутом, чтобы для него не выполнялась проверка на совпадение содержимого при мердже
					xobjValue.SetPropMergeMode(propInfo.ReverseProp.Name, XStorageObjectPropMergeModes.Weak);
					xobjValue = add(xobjValue);
					// упорядоченный линк ? - установим индексное свойство
					if (propInfo.OrderByProp != null)
					{
						xobjValue.Props[propInfo.OrderByProp.Name] = nIndex++;
						// пометим свойство специальным атрибутом, говорящим о том что при Merge'е данное значение затрет другое значение
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
	/// Режимы обработки свойств 2-х объектов, надо которыми производиться процедура слияния
	/// </summary>
	public enum XStorageObjectPropMergeModes
	{
		/// <summary>
		/// Добавлять значение, если св-во отсутствует, иначе (если присутствует) проверять на совпадение
		/// </summary>
		Normal,
		/// <summary>
		/// перезаписывать содержимое свойства
		/// </summary>
		Replace,
		/// <summary>
		/// игнорировать расхождение значений свойств
		/// </summary>
		Weak
	}

    public abstract class XStorageObjectBase : XObjectBaseGeneric<XStorageObjectBase>
	{
		/// <summary>
		/// Класс для сравнения объектов XStorageObjectBase по наименованию типа
		/// Используется в граф-процессоре для сортировки объектов с одинаковым индексом зависимости 
		/// (для предотвращения блокировок)
		/// </summary>
        public class ComparerByTypeName : IComparer<XStorageObjectBase>
		{
			/// <summary>
			/// Метод сравнения. См. IComparer.Compare
			/// </summary>
			/// <param name="l"></param>
			/// <param name="r"></param>
            public int Compare(XStorageObjectBase l, XStorageObjectBase r)
			{
				if (l!=null && (!(l is XStorageObjectBase)) || r!=null && (!(r is XStorageObjectBase)))
				{
					throw new InvalidOperationException("Не допустимо использовать объект для сравнение объектов типов, отличных от XStorageObjectBase");
				}
				// по спецификации на IComparer допустимо сравнивать объект с null. null всегда меньше.
				if (l==null)
					return -1;
				if (r==null)
					return 1;
				return ((XStorageObjectBase)l).ObjectType.CompareTo( ((XStorageObjectBase)r).ObjectType );
			}
		}

		protected HybridDictionary m_propValues = new HybridDictionary(true);
		/// <summary>Состояние: вставляемый или изменяемый</summary>
		protected XStorageObjectState m_state;
        protected XObjectDependency<XStorageObjectBase>[] m_References;
		/// <summary>
		/// Режимы слияния значений свойств
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
		/// Инциализирует список зависимостей текущего объекта на объекты, заданыне словарем
		/// </summary>
		/// <param name="objects">Словарь объектов: ключ - {ObjectType}+":"+{ObjectID}, значение - экземпляр XStorageObjectBase</param>
		public void InitReferences(IDictionary objects)
		{
			ArrayList aReferences = new ArrayList();
			foreach(XPropInfoObjectScalar propInfo in TypeInfo.GetPropsByCapacity(XPropCapacity.Scalar))
			{
				object vValue = Props[propInfo.Name];
				if (vValue != null && vValue != DBNull.Value)
				{
					Debug.Assert(vValue is Guid, "В объектном скалярном не NULL свойстве ожидался GUID");
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
				throw new XMergeConflictException("Обнаружено два экземпляра объекта " + xobj.ToString() + ", один из которых помечен как удаляемый, а другой нет");
			if (this.AnalyzeTS && xobj.AnalyzeTS)
				if (this.TS != xobj.TS)
					throw new XMergeConflictException("Обнаружено два экземпляра объекта " + xobj.ToString() + " с разными ts:" + this.TS + ", " + xobj.TS);
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
		/// <summary>признак того, что надо update'ить ts</summary>
		protected bool m_bUpdateTS;
		/// <summary>признак того, что для объекта использовался MagicBit</summary>
		protected bool m_bMagicBitAffected;
		/// <summary>признак того, что в объекте есть свойства, участвующие в уникальных индексах</summary>
		protected bool m_bParticipateInUniqueIndex;
		/// <summary>
		/// словарь свойств, для которых были загружены кусочные данные. Ключ: наименование свойства, значение - идентификатор цепочки
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
		/// Dictionary<string,Guid> - словарь цепочек кусочных данных свойств
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
				Debug.Fail("Некорректная реализация XStorageObjectBase::Merge");
				throw new ArgumentException();
			}
			UpdateTS = UpdateTS | xobj.UpdateTS;
			if (xobj.IsToInsert)
				m_state = XStorageObjectState.ToInsert;
			foreach(string sPropName in xobj.Props.Keys)
				if (!Props.Contains(sPropName))
				{
					// свойства не было - добавим
					Props[sPropName] = xobj.Props[sPropName];
				}
				else
				{
					XStorageObjectPropMergeModes mergeModeThis = GetPropMergeMode(sPropName);
					XStorageObjectPropMergeModes mergeModeForeign  = xobj.GetPropMergeMode(sPropName);
					// если хотя бы для одного свойства стоит флаг "слабой" проверки, то отключаем проверку на совпадание значений свойств
					if (mergeModeThis == XStorageObjectPropMergeModes.Replace)
					{
						Debug.Assert(mergeModeForeign != XStorageObjectPropMergeModes.Replace, "Два свойства с признаком перезаписи - это некорректная ситуация");
						// у текущего св-ва задан атрибут перезаписи, поэтому оставляем его в неприкосновенности (даже проверки не делаем)
					}
					else if (mergeModeForeign == XStorageObjectPropMergeModes.Replace)
					{
						Props[sPropName] = xobj.Props[sPropName];
					}
					else
					{
						if (!isPropsEquals(Props[sPropName], xobj.Props[sPropName]))
							throw new XMergeConflictException("Значения свойста " + sPropName + " отличаются: '" + Props[sPropName] + "' и '" + xobj.Props[sPropName] + "'");
					}
				}

			// смерджим словарь свойств, данные которых загружены механизмом кусочного сохранения
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
				Debug.Fail("Одно значение свойства типа Guid[], а другое не Guid[]");
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
		/// Зачитывает коллекцию ссылок объекта из DataReader'а
		/// В DataReader'e начиная со StartIndex'a ожидаются пары колонок: гуид-внешний ключ; имя объекта, на который ссылка
		/// </summary>
		/// <param name="reader">DataReader</param>
		/// <param name="nStartIndex">Индекс, начиная с которого начинаем перебирать колонки</param>
		public void ReadObjectDependencesFromDataReader(IDataReader reader, int nStartIndex)
		{
			string sPropName;					// наименование свойтсва
			Guid oid;							// идентификатор объекта
			// по всем ссылкам объекта
			for(int nField=nStartIndex; nField < reader.FieldCount; nField++)
			{
				if (!reader.IsDBNull(nField))
				{
					oid = reader.GetGuid(nField);	// значение внешнего ключа
					sPropName = reader.GetName(nField);		// наименование колонки - это наименование свойства
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
				Debug.Fail("Некорректная реализация XStorageObjectBase::Merge");
				throw new ArgumentException();
			}
		}
	}

	/// <summary>
	/// Enumerator для обхода списка объектов (XStorageObjectBase) сгруппированных по типу (FullName)
	/// </summary>
	public class XStorageObjectBaseGroupedByTypeEnumerator: IEnumerator
	{	
		private IList _aXObjects;		// ссылка в список, который будем обходить
		private int _nIndexStart;			// индекс в списке начала текущей группы
		private int _nIndexEnd;				// индекс в списке окончания текущей группы


		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="aXObjects">Список объектов по которым будет создаваться энуменатор</param>
		public XStorageObjectBaseGroupedByTypeEnumerator(IList aXObjects)
		{
			_aXObjects = aXObjects;
			(this as IEnumerator).Reset();
		}
		#region IEnumerator Members

		/// <summary>
		/// См. документацию на IEnumerator
		/// </summary>
		/// <returns></returns>
		void IEnumerator.Reset()
		{
			_nIndexStart = -1;
			_nIndexEnd = -1;
		}

		/// <summary>
		/// См. документацию на IEnumerator
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
		/// См. документацию на IEnumerator
		/// </summary>
		/// <returns></returns>
		bool IEnumerator.MoveNext()
		{
			if (_nIndexEnd + 1 >= _aXObjects.Count) 
			{
				// индекс следующий за предыдущим последним выходи за границу
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