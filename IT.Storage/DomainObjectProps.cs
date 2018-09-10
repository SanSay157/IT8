using System;
using System.Collections;
using System.Diagnostics;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Storage
{
	public abstract class DomainPropBase
	{
		protected DomainObject m_objParent;
		protected XPropInfoBase m_xpropInfo;
		protected bool m_bIsDirty;
		public DomainPropBase(DomainObject obj, XPropInfoBase xpropInfo)
		{
			m_objParent = obj;
			m_xpropInfo = xpropInfo;
		}
		public DomainObject Parent 
		{
			get { return m_objParent; }
		}
		public string PropName
		{
			get { return m_xpropInfo.Name; }
		}
		public virtual void SetDirty()
		{
			if (m_objParent.IsGhost)
				throw new InvalidOperationException("Объект не загружен!");
			m_bIsDirty = true;
		}
		public bool IsDirty
		{
			get { return m_bIsDirty || isModified; }
		}
		protected abstract bool isModified { get; }
		public virtual void AcceptChanges()
		{
			m_bIsDirty = false;
		}
		protected void loadParent()
		{
			m_objParent.Load();
		}
		public XPropInfoBase PropInfo
		{
			get { return m_xpropInfo; }
		}
	}
	public interface IDomainPropScalar
	{
		bool IsNull { get; }
		void SetNull();
	}
	public abstract class DomainPropSimpleBase: DomainPropBase, IDomainPropScalar
	{
		public DomainPropSimpleBase(DomainObject obj, XPropInfoSimple xpropInfo)
			: base(obj, xpropInfo)
		{}
		protected object m_vValue;
		protected object m_vOldValue;
		protected bool m_bIsNull;
		public object ValueUnstrict
		{
			get
			{
				loadParent();
				return m_vValue;
			}
			set
			{
				loadParent();
				m_vValue = value;
				if (value == null)
					m_bIsNull = true;
			}
		}

		public bool IsNull
		{
			get 
			{ 
				loadParent();
				return m_bIsNull; 
			}
		}
		public void SetNull()
		{
			loadParent();
			m_bIsNull = true;
			m_vValue = null;
		}
		public override string ToString()
		{
			return m_vValue == null ? "NULL" : m_vValue.ToString();
		}

		protected override bool isModified
		{
			get 
			{
				if (m_objParent.IsGhost)
					return false;
				return (m_vValue==null && m_vOldValue!=null) || (m_vValue!= null && !m_vValue.Equals(m_vOldValue));
			}
		}
		public override void AcceptChanges()
		{
			base.AcceptChanges();
			m_vOldValue = m_vValue;
		}
		public void internal_Init(object value)
		{
			m_vOldValue = m_vValue = value;
		}
	}
	public abstract class DomainPropNumeric: DomainPropSimpleBase
	{
		public DomainPropNumeric(DomainObject obj, XPropInfoNumeric xpropInfo)
			: base(obj, xpropInfo)
		{}
		public new XPropInfoNumeric PropInfo
		{
			get
			{
				return (XPropInfoNumeric)base.PropInfo;
			}
		}
	}
	public class DomainPropNumericInt: DomainPropNumeric
	{
		public DomainPropNumericInt(DomainObject obj, XPropInfoNumeric xpropInfo)
			: base(obj, xpropInfo)
		{}
		public Int32 Value
		{
			get
			{
				loadParent();
				return System.Convert.ToInt32(m_vValue);
			}
			set
			{
				loadParent();
				int nValue;
				switch(PropInfo.VarType)
				{
					case XPropType.vt_ui1:
						nValue = Convert.ToByte(value);
						break;
					case XPropType.vt_i2:
						nValue = Convert.ToInt16(value);
						break;
					case XPropType.vt_i4:
						nValue = Convert.ToInt32(value);
						break;
					default:
						throw new ApplicationException();
				}
				m_vValue = nValue;
				if (PropInfo.HasMaxValue && nValue > PropInfo.MaxValue)
					throw new ArgumentException("Значение " + nValue + " превышает максимально допустимое: " + PropInfo.MaxValue);
				if (PropInfo.HasMinValue && nValue < PropInfo.MinValue)
					throw new ArgumentException("Значение " + nValue + " меньше минимально допустимого: " + PropInfo.MaxValue);
			}
		}
	}
	public class DomainPropNumericDecimal: DomainPropNumeric
	{
		public DomainPropNumericDecimal(DomainObject obj, XPropInfoNumeric xpropInfo)
			: base(obj, xpropInfo)
		{}
		public Decimal Value
		{
			get
			{
				loadParent();
				return System.Convert.ToDecimal(m_vValue);
			}
			set
			{
				loadParent();
				m_vValue = value;
			}
		}
	}
	public class DomainPropNumericSingle: DomainPropNumeric
	{
		public DomainPropNumericSingle(DomainObject obj, XPropInfoNumeric xpropInfo)
			: base(obj, xpropInfo)
		{}
		public Single Value
		{
			get
			{
				loadParent();
				return System.Convert.ToSingle(m_vValue);
			}
			set
			{
				loadParent();
				m_vValue = value;
			}
		}
	}
	public class DomainPropNumericDouble: DomainPropNumeric
	{
		public DomainPropNumericDouble(DomainObject obj, XPropInfoNumeric xpropInfo)
			: base(obj, xpropInfo)
		{}
		public Double Value
		{
			get
			{
				loadParent();
				return System.Convert.ToDouble(m_vValue);
			}
			set
			{
				loadParent();
				m_vValue = value;
			}
		}
	}
	public class DomainPropDateTime: DomainPropSimpleBase
	{
		public DomainPropDateTime(DomainObject obj, XPropInfoDatetime xpropInfo)
			: base(obj, xpropInfo)
		{}
		public DateTime Value
		{
			get 
			{
				loadParent();
				return (DateTime)m_vValue;
			}
			set
			{
				loadParent();
				switch (PropInfo.VarType)
				{
					case XPropType.vt_time:
						m_vValue = new DateTime(1900, 1, 1, value.Hour, value.Minute, value.Second, value.Millisecond);
						break;
					case XPropType.vt_date:
						m_vValue = new DateTime(value.Year, value.Month, value.Day, 0, 0, 0, 0);
						break;
					default:
						m_vValue = value;
						break;
				}
			}
		}
		public new XPropInfoDatetime PropInfo
		{
			get
			{
				return (XPropInfoDatetime)base.PropInfo;
			}
		}
	}
	public class DomainPropBoolean: DomainPropSimpleBase
	{
		public DomainPropBoolean(DomainObject obj, XPropInfoBoolean xpropInfo)
			: base(obj, xpropInfo)
		{}
		public Boolean Value
		{
			get 
			{
				loadParent();
				return (Boolean)m_vValue;
			}
			set
			{
				loadParent();
				m_vValue = value;
			}
		}
		public new XPropInfoBoolean PropInfo
		{
			get
			{
				return (XPropInfoBoolean)base.PropInfo;
			}
		}
	}
	public class DomainPropString: DomainPropSimpleBase
	{
		public DomainPropString(DomainObject obj, XPropInfoString xpropInfo)
			: base(obj, xpropInfo)
		{}
		public String Value
		{
			get 
			{
				loadParent();
				return (String)m_vValue;
			}
			set
			{
				loadParent();
				m_vValue = value;
			}
		}
		public new XPropInfoString PropInfo
		{
			get
			{
				return (XPropInfoString)base.PropInfo;
			}
		}
	}
	public class DomainPropSmallBin: DomainPropSimpleBase
	{
		public DomainPropSmallBin(DomainObject obj, XPropInfoSmallBin xpropInfo)
			: base(obj, xpropInfo)
		{}
		public byte[] Value
		{
			get 
			{
				loadParent();
				return (byte[])m_vValue;
			}
			set
			{
				loadParent();
				m_vValue = value;
			}
		}
		public new XPropInfoSmallBin PropInfo
		{
			get
			{
				return (XPropInfoSmallBin)base.PropInfo;
			}
		}
		protected override bool isModified
		{
			get { return !compareArray((byte[])m_vValue, (byte[])m_vOldValue); }
		}
		private bool compareArray(byte[] l, byte[] r)
		{
			if (l == r)
				return true;
			if (l == null || r == null)
				return false;
			if (l.Length != r.Length)
				return false;
			for(int i=0; i<l.Length; ++i)
				if (l[i] != r[i])
					return false;
			return true;
		}
	}
	public class DomainPropUUID: DomainPropSimpleBase
	{
		public DomainPropUUID(DomainObject obj, XPropInfoSimple xpropInfo)
			: base(obj, xpropInfo)
		{}
		public Guid Value
		{
			get 
			{
				loadParent();
				return (Guid)m_vValue;
			}
			set
			{
				loadParent();
				m_vValue = value;
			}
		}
		public new XPropInfoUUID PropInfo
		{
			get
			{
				return (XPropInfoUUID)base.PropInfo;
			}
		}
	}

	public enum DomainPropLoadableState
	{
		Ghost,
		Loaded
	}
	public interface IDomainPropLoadable
	{
		void Load();
		DomainPropLoadableState State
		{
			get;
			set;
		}
	}
	public abstract class DomainPropObjectBase: DomainPropBase
	{
		public DomainPropObjectBase(DomainObject obj, XPropInfoBase xpropInfo)
			: base(obj, xpropInfo)
		{}
		protected DomainPropObjectBase getReverseProp(DomainObject obj)
		{
			XPropInfoBase xprop = PropInfo.ReverseProp;
			if (xprop != null)
			{
				// задано обратное свойства
				return (DomainPropObjectBase)obj.Props[xprop.Name];
			}
			return null;
		}
		public new XPropInfoObject PropInfo
		{
			get { return (XPropInfoObject)m_xpropInfo; }
		}
		public abstract Guid[] GetValueOIDS();
		protected static Guid[] emptyArrayOfGuids = new Guid[0];
	}

	public class DomainPropObjectScalar: DomainPropObjectBase, IDomainPropScalar
	{
		protected DomainObject m_objRef;
		protected Guid m_OldValue;
		protected bool m_bIsNull;
		protected DomainPropPendingAction m_pendingAction;
		public DomainPropObjectScalar(DomainObject obj, XPropInfoObject xpropInfo)
			: base(obj, xpropInfo)
		{}
		public DomainObject Value
		{
			get 
			{ 
				loadParent();
				return m_objRef; 
			}
			set 
			{ 
				loadParent();
				// синхронизируем обратное свойство
				if (m_objRef != null)
				{
					// предыдущее значение не NULL - удалим ссылку на текущий объект из обратного линка объекта-значения
					DomainPropSetBase propRev = (DomainPropSetBase)getReverseProp(m_objRef);
					if (propRev != null)
						propRev.internal_AddPendingAction(DomainPropPendingActionMode.Remove, m_objParent);
							
				}
				if (value != null)
				{
					// новое значение не NULL - добавим ссылку на текущий объект в обратный линк объекта-значения
					DomainPropSetBase propRev = (DomainPropSetBase)getReverseProp(value);
					if (propRev != null)
						propRev.internal_AddPendingAction(DomainPropPendingActionMode.Add, m_objParent);
				}
				m_objRef = value;
			}
		}

		public bool IsNull
		{
			get 
			{ 
				loadParent();
				return m_objRef==null; 
			}
		}

		public void SetNull()
		{
			loadParent();
			m_objRef = null;
		}

		public bool HasReferedOn(Guid oid)
		{
			if (IsNull)
				return false;
			return m_objRef.ObjectID == oid;
		}
		public void internal_SetValue(DomainObject obj)
		{
			m_objRef = obj;
			initOldValue(obj);
		}
		public void internal_SetPendingAction(DomainPropPendingActionMode action, DomainObject objValue)
		{
			if (m_objParent.IsDeleted)
				return;
			if (m_objParent.IsGhost)
			{
				// объект владелец не загружен - подпишемся на событие и загрузки и сохраним отложенное изменение свойства
				m_objParent.ObjectLoaded += new EventHandler(parentObjectLoadedHandler);
				m_pendingAction = new DomainPropPendingAction(action, objValue);
			}
			else
			{
				// объект-владелец прогружен - можно не откладывать изменения
				applyPendingAction(action, objValue);
			}
		}
		protected void applyPendingAction(DomainPropPendingActionMode action, DomainObject objValue)
		{
			switch(action)
			{
				case DomainPropPendingActionMode.Set:
					m_objRef = objValue;
					break;
				case DomainPropPendingActionMode.Clear:
					m_objRef = null;
					break;
				default:
					throw new InvalidOperationException("Неподдерживаемое действие");
			}
		}
		/// <summary>
		/// Обработчик события ObjectLoaded объекта владельца свойства
		/// </summary>
		protected void parentObjectLoadedHandler(object sender, EventArgs e)
		{
			applyPendingAction(m_pendingAction.Action, m_pendingAction.ValueObject);
			// т.к. отложенное изменение применено, отпишемся от события
			m_objParent.ObjectLoaded -= new EventHandler(parentObjectLoadedHandler);
		}
		public new XPropInfoObjectScalar PropInfo
		{
			get { return (XPropInfoObjectScalar)m_xpropInfo; }
		}
		public override string ToString()
		{
			return m_objRef == null ? "NULL" : 
				m_objRef.IsGhost ? m_objRef.ObjectType + " (" + m_objRef.ObjectID.ToString() + ")" : m_objRef.ToString();
		}

		protected override bool isModified
		{
			get 
			{
				if (m_objParent.IsGhost)
					return false;
				return m_objRef==null && m_OldValue!=Guid.Empty || m_objRef!=null && m_OldValue==Guid.Empty || (m_objRef!= null && m_objRef.ObjectID != m_OldValue); 
			}
		}
		public override void AcceptChanges()
		{
			base.AcceptChanges();
			initOldValue(m_objRef);
		}
		protected void initOldValue(DomainObject obj)
		{
			if (obj == null)
				m_OldValue = Guid.Empty;
			else
				m_OldValue = obj.ObjectID;
		}

		public override Guid[] GetValueOIDS()
		{
			if (IsNull)
				return emptyArrayOfGuids;
			else
				return new Guid[] {Value.ObjectID};
		}
	}

	public abstract class DomainPropSetBase: DomainPropObjectBase, IDomainPropLoadable, IEnumerable
	{
		protected DomainPropLoadableState m_state;
		protected ArrayList m_objects = new ArrayList();
		protected ArrayList m_object_original_ids = new ArrayList();		// массив гуидов объектов значений
		protected ArrayList m_pendingActions;
		public DomainPropSetBase(DomainObject objParent, XPropInfoObject xpropInfo)
			: base(objParent, xpropInfo)
		{
			if (m_objParent.IsNew)
				// свойство нового объекта всегда "прогружено"
				m_state = DomainPropLoadableState.Loaded;
			else
				m_state = DomainPropLoadableState.Ghost;
		}
		public virtual void Add(DomainObject obj)
		{
			checkAddingObject(obj);
			Load();
			synchronizeAdd(obj);
			m_objects.Add(obj);
		}
		public void Remove(DomainObject obj)
		{
			Remove(obj.ObjectID);
		}
		public virtual void Remove(Guid oid)
		{
			Load();
			DomainObject objValue = FindObjectValue(oid);
			if (objValue == null)
				throw new InvalidOperationException("Заданный объект отсутствует в свойстве");
			synchronizeRemove(objValue);
			m_objects.Remove(objValue);
		}
		public virtual void Clear()
		{
			Load();
			synchronizeClear();
			m_objects.Clear();
		}
		public virtual void Replace(DomainObject objOld, DomainObject objNew)
		{
			if (objOld == null)
				throw new ArgumentNullException("objOld");
			if (objNew == null)
				throw new ArgumentNullException("objNew");
			if (objOld.ObjectID == objNew.ObjectID)
				return;
			Load();
			for(int i=0;i<m_objects.Count;++i)
			{
				DomainObject objValue = (DomainObject)m_objects[i];
				if (objOld.ObjectID == objValue.ObjectID)
				{
					synchronizeRemove(objValue);
					m_objects[i] = objNew;
					checkAddingObject(objNew);
					synchronizeAdd(objNew);
					return;
				}
			}
			throw new InvalidOperationException("Заданный объект отсутствует в свойстве");
		}

		protected void checkAddingObject(DomainObject obj)
		{
			if (obj == null)
				throw new ArgumentNullException("obj");
			if (obj.ObjectType != PropInfo.ReferedType.Name)
				throw new ArgumentException("Некорректный тип объекта: " + obj.ObjectType);
			if (obj.IsDeleted)
				throw new InvalidOperationException("Удаленный объект не допустимо добавлять в свойство");
			DomainObject objValue = FindObjectValue(obj.ObjectID);
			if (objValue != null)
				throw new InvalidOperationException("Объект с идентификатором " + obj.ObjectID.ToString() + " уже присутствует в свойстве");
		}
		protected abstract void synchronizeAdd(DomainObject objValue);
		protected abstract void synchronizeRemove(DomainObject objValue);
		protected abstract void synchronizeClear();
		public DomainObject FindObjectValue(Guid oid)
		{
			foreach(DomainObject objValue in m_objects)
				if (objValue.ObjectID == oid)
					return objValue;
			return null;
		}
		public ArrayList Internal_Values
		{
			get { return m_objects; }
		}
		public void internal_AddPendingAction(DomainPropPendingActionMode action, DomainObject objValue)
		{
			if (State == DomainPropLoadableState.Loaded)
			{
				// свойство уже загружено - можно не откладывать изменения
				applyPendingAction(action, objValue);
			}
			else
			{
				if (m_pendingActions == null)
					m_pendingActions = new ArrayList();
				DomainPropPendingActionMode actionReverse = (action == DomainPropPendingActionMode.Add) ? DomainPropPendingActionMode.Remove : DomainPropPendingActionMode.Add;
				foreach(DomainPropPendingAction record in m_pendingActions)
					if (record.Action == actionReverse || record.ValueObject.ObjectType == objValue.ObjectType || record.ValueObject.ObjectID == objValue.ObjectID)
					{
						// нашли действие, для которого текущее будет компенсирующим
						m_pendingActions.Remove(record);
						return;
					}
				m_pendingActions.Add( new DomainPropPendingAction(action, objValue) );
			}
		}

		protected void applyPendingAction(DomainPropPendingActionMode action, DomainObject objValue)
		{
			Debug.Assert(State == DomainPropLoadableState.Loaded);
			DomainPropPendingAction.Check(action, objValue);
			switch(action)
			{
				case DomainPropPendingActionMode.Add:
					checkAddingObject(objValue);
					m_objects.Add(objValue);
					break;
				case DomainPropPendingActionMode.Remove:
					DomainObject objLocal = FindObjectValue(objValue.ObjectID);
					if (objLocal != null)
					{
						m_objects.Remove(objLocal);
					}
					break;
				case DomainPropPendingActionMode.Clear:
					m_objects.Clear();
					break;
				default:
					throw new InvalidOperationException("Неподдерживаемое действие");
			}
		}

		public void Load()
		{
			if (m_objParent.IsNew)
				return;
			if (m_state == DomainPropLoadableState.Ghost)
			{
				m_objects.Clear();
				// если не загружено - загрузим
				m_objParent.UoW.loadProperty(this);
				m_state = DomainPropLoadableState.Loaded;
				// применим отложенные действия
				if (m_pendingActions != null && m_pendingActions.Count > 0)
				{
					foreach(DomainPropPendingAction action in m_pendingActions)
						applyPendingAction(action.Action, action.ValueObject);
					m_pendingActions.Clear();
				}
				if (PropInfo.Capacity != XPropCapacity.ArrayMembership)
				{
					// для членства в массиве не надо отслеживать изменения, т.к. это св-во немодифицируемо
					m_object_original_ids.Clear();
					foreach(DomainObject obj in m_objects)
						m_object_original_ids.Add(obj.ObjectID);
				}
			}
		}

		public DomainPropLoadableState State
		{
			get { return m_state; }
			set { m_state = value; }
		}

		protected override bool isModified
		{
			get 
			{
				if (m_objParent.IsGhost)
					return false;
				if (m_objects.Count != m_object_original_ids.Count)
					return true;
				for(int i=0;i<m_objects.Count;++i)
				{
					if (m_object_original_ids.IndexOf(((DomainObject)m_objects[i]).ObjectID)==-1)
						return true;
				}
				return false;
			}
		}

		public override void AcceptChanges()
		{
			base.AcceptChanges();
			m_object_original_ids.Clear();
		}

		public DomainObject this[int i]
		{
			get { return (DomainObject)m_objects[i]; }
			set 
			{ 
				DomainObject objOld = (DomainObject)m_objects[i];
				DomainObject objNew = value;
				Replace(objOld, objNew);
			}
		}

		public DomainObject this[Guid oid]
		{
			get { return FindObjectValue(oid); }
		}

		public override Guid[] GetValueOIDS()
		{
			Guid[] oids = new Guid[m_objects.Count];
			int i = -1;
			foreach(DomainObject objValue in m_objects)
				oids[++i] = objValue.ObjectID;
			return oids;
		}

		public override string ToString()
		{
			return ((XPropInfoObject)m_xpropInfo).ReferedType.Name + " {" + m_objects.Count.ToString() + "}";
		}

		public int Count
		{
			get { return m_objects.Count; }
		}

		public bool IsLoaded
		{
			get { return m_state == DomainPropLoadableState.Loaded; }
		}

		public new XPropInfoObject PropInfo
		{
			get { return (XPropInfoObject)m_xpropInfo; }
		}

		public IEnumerator GetEnumerator()
		{
			return m_objects.GetEnumerator();
		}
	}
 
	public class DomainPropLink: DomainPropSetBase
	{
		public DomainPropLink(DomainObject objParent, XPropInfoObjectLink xpropInfo)
			: base(objParent, xpropInfo)
		{}
		protected override void synchronizeAdd(DomainObject obj)
		{
			// синхронизируем обратное свойство
			DomainPropObjectScalar propRev = (DomainPropObjectScalar)getReverseProp(obj);
			if (propRev != null)
				// переставим обратную объектную ссылку на текущий объект
				propRev.internal_SetPendingAction(DomainPropPendingActionMode.Set, m_objParent);
		}
		protected override void synchronizeRemove(DomainObject objValue)
		{
			Debug.Assert(objValue!=null);
			// синхронизируем обратное свойство
			DomainPropObjectScalar propRev = (DomainPropObjectScalar)getReverseProp(objValue);
			if (propRev != null)
				propRev.internal_SetPendingAction(DomainPropPendingActionMode.Clear, null);
		}
		protected override void synchronizeClear()
		{
			DomainPropObjectScalar propRev;
			// синхронизируем обратные свойства
			foreach(DomainObject objValue in m_objects)
			{
				// очистим ссылку на текущий объект в каждом объекте-значении свойства
				propRev = (DomainPropObjectScalar)getReverseProp(objValue);
				if (propRev != null)
					propRev.internal_SetPendingAction(DomainPropPendingActionMode.Clear, null);
			}
		}
		public new XPropInfoObjectLink PropInfo
		{
			get { return (XPropInfoObjectLink)m_xpropInfo; }
		}
	}
	public abstract class DomainPropCollectionBase: DomainPropSetBase
	{
		public DomainPropCollectionBase(DomainObject objParent, XPropInfoObjectArray xpropInfo)
			: base(objParent, xpropInfo)
		{}
		protected override void synchronizeAdd(DomainObject obj)
		{
			// синхронизируем обратное свойство
			DomainPropCollectionBase propRev = (DomainPropCollectionBase)getReverseProp(obj);
			if (propRev != null)
				// переставим обратную объектную ссылку на текущий объект
				propRev.internal_AddPendingAction(DomainPropPendingActionMode.Add, m_objParent);
		}
		protected override void synchronizeRemove(DomainObject objValue)
		{
			Debug.Assert(objValue!=null);
			// синхронизируем обратное свойство
			DomainPropCollection propRev = (DomainPropCollection)getReverseProp(objValue);
			if (propRev != null)
				propRev.internal_AddPendingAction(DomainPropPendingActionMode.Remove, m_objParent);
		}
		protected override void synchronizeClear()
		{
			DomainPropCollection propRev;
			// синхронизируем обратные свойства
			foreach(DomainObject objValue in m_objects)
			{
				// очистим ссылку на текущий объект в каждом объекте-значении свойства
				propRev = (DomainPropCollection)getReverseProp(objValue);
				if (propRev != null)
					propRev.internal_AddPendingAction(DomainPropPendingActionMode.Clear, null);
			}
		}
		public new XPropInfoObjectArray PropInfo
		{
			get { return (XPropInfoObjectArray)m_xpropInfo; }
		}
	}

	public class DomainPropCollection: DomainPropCollectionBase
	{
		public DomainPropCollection(DomainObject objParent, XPropInfoObjectArray xpropInfo) : base(objParent, xpropInfo)
		{}
	}

	public class DomainPropArray: DomainPropCollectionBase
	{
		public DomainPropArray(DomainObject objParent, XPropInfoObjectArray xpropInfo) : base(objParent, xpropInfo)
		{}

		protected override bool isModified
		{
			get 
			{
				if (m_objParent.IsGhost)
					return false;
				if (m_objects.Count != m_object_original_ids.Count)
					return true;
				for(int i=0;i<m_objects.Count;++i)
				{
					if ( (Guid)m_object_original_ids[i] != ((DomainObject)m_objects[i]).ObjectID)
						return true;
				}
				return false;
			}
		}

		public bool ShiftUp(Guid oid)
		{
			throw new NotImplementedException();
		}
		public bool ShiftDown(Guid oid)
		{
			throw new NotImplementedException();
		}
	}

	public class DomainPropArrayMembership: DomainPropCollectionBase
	{
		public DomainPropArrayMembership(DomainObject objParent, XPropInfoObjectArray xpropInfo) : base(objParent, xpropInfo)
		{}

		public override void Add(DomainObject obj)
		{
			throw new InvalidOperationException("Свойства вида \"членство в массиве\" не может модифицироваться");
		}

		public override void Remove(Guid oid)
		{
			throw new InvalidOperationException("Свойства вида \"членство в массиве\" не может модифицироваться");
		}

		public override void Clear()
		{
			throw new InvalidOperationException("Свойства вида \"членство в массиве\" не может модифицироваться");
		}

		public override void SetDirty()
		{
			throw new InvalidOperationException("Свойства вида \"членство в массиве\" не может модифицироваться");
		}

		protected override bool isModified
		{
			get { return false; }
		}
	}

	public abstract class DomainPropLOB: DomainPropBase, IDomainPropLoadable, IDomainPropScalar
	{
		protected DomainPropLoadableState m_state;
		protected int m_nDataSize;
		protected bool m_bIsModified = false;
		public DomainPropLOB(DomainObject objParent, XPropInfoBase xpropInfo) : base(objParent, xpropInfo)
		{
			m_state = DomainPropLoadableState.Ghost;
		}
		public void Load()
		{
			
			if (m_objParent.IsNew)
				return;
			if (m_state != DomainPropLoadableState.Loaded)
			{
				m_objParent.UoW.loadProperty(this);
				m_state = DomainPropLoadableState.Loaded;
			}
		}
		public DomainPropLoadableState State
		{
			get { return m_state; }
			set { m_state = value; }
		}
		public int DataSize
		{
			get 
			{
				loadParent();
				return m_nDataSize; 
			}
			set 
			{
				loadParent();
				m_nDataSize = value;
			}
		}

		protected override bool isModified
		{
			get 
			{
				if (m_objParent.IsGhost)
					return false;
				return m_bIsModified; 
			}
		}
		public abstract bool IsNull { get; }
		public abstract void SetNull();
		public override string ToString()
		{
			return IsNull ? "NULL" : "DateSize=" + m_nDataSize;
		}
	}

	public class DomainPropBinary: DomainPropLOB
	{
		public DomainPropBinary(DomainObject objParent, XPropInfoBase xpropInfo)
			: base(objParent, xpropInfo)
		{}
		private byte[] m_value;
		public byte[] Value
		{
			get 
			{
				Load();
				return m_value;
			}
			set
			{
				m_bIsModified = true;
				internal_SetValue(value);
			}
		}
		public new XPropInfoBin PropInfo
		{
			get
			{
				return (XPropInfoBin)base.PropInfo;
			}
		}
		public override bool IsNull
		{
			get 
			{ 
				loadParent();
				return m_value==null; 
			}
		}
		public override void SetNull()
		{
			loadParent();
			if (m_value != null)
			{
				SetDirty();
				m_value = null;
			}
			DataSize = 0;
		}
		public void internal_SetValue(byte[] data)
		{
			m_value = data;
			if (m_value != null)
				DataSize = m_value.Length;
		}

	}

	public class DomainPropText: DomainPropLOB
	{
		public DomainPropText(DomainObject objParent, XPropInfoBase xpropInfo)
			: base(objParent, xpropInfo)
		{}
		private string m_value;
		public string Value
		{
			get
			{
				Load();
				return m_value;
			}
			set
			{
				m_bIsModified = true;
				internal_SetValue(value);
			}
		}
		public new XPropInfoText PropInfo
		{
			get
			{
				return (XPropInfoText)base.PropInfo;
			}
		}
		public override bool IsNull
		{
			get 
			{ 
				loadParent();
				return m_value==null; 
			}
		}
		public override void SetNull()
		{
			loadParent();
			if (m_value != null)
			{
				SetDirty();
				m_value = null;
			}
			DataSize = 0;
		}
		public void internal_SetValue(string data)
		{
			m_value = data;
			if (m_value != null)
				DataSize = m_value.Length;
		}
	}


	public enum DomainPropPendingActionMode
	{
		Add,
		Remove,
		Clear,
		Set
	}

	public class DomainPropPendingAction
	{
		private DomainPropPendingActionMode m_action;
		private DomainObject m_objValue;
		public DomainPropPendingAction(DomainPropPendingActionMode action, DomainObject objValue)
		{
			Check(action, objValue);
			m_action = action;
			m_objValue = objValue;
		}
		public DomainPropPendingActionMode Action
		{
			get { return m_action; }
		}
		public DomainObject ValueObject
		{
			get { return m_objValue; }
		}
		public static void Check(DomainPropPendingActionMode action, DomainObject obj)
		{
			if ((action == DomainPropPendingActionMode.Add || 
				action == DomainPropPendingActionMode.Remove ||
				action == DomainPropPendingActionMode.Set) && obj == null)
				throw new InvalidOperationException("Не задан объект для действия " + action);
			if (action == DomainPropPendingActionMode.Clear && obj != null)
				throw new InvalidOperationException("Задан объект для действия Clear");
		}
	}

}