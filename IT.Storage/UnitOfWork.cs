//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2008-2009
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Specialized;
using System.Reflection;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Storage
{
    /// <summary>
    /// Вспомогательный класс-Mapper для работы с "фабрикой" объектов DomainObject
    /// </summary>
	public abstract class Mapper
	{
        protected XTypeInfo m_xtypeInfo; // Описание типа ds-объекта.
		protected DomainObjectFactory m_InstanceFactory; // "Фабрика" объектов

		public Mapper(XTypeInfo xtype, DomainObjectFactory factory)
		{
			m_xtypeInfo = xtype;
			if (m_InstanceFactory == null)
				m_InstanceFactory = new DomainObjectFactory(m_xtypeInfo);
			else
				m_InstanceFactory = factory;
		}

		public DomainObject CreateObjectTemplate(UnitOfWork uow, Guid oid, bool bWithDefault)
		{
			return m_InstanceFactory.CreateObject(uow, oid, bWithDefault);
		}

		public DomainObject CreateNewObject(UnitOfWork uow)
		{
			DomainObject obj = CreateObjectTemplate(uow, Guid.NewGuid(), true);
			obj.State = DomainObjectState.New;
			return obj;
		}

		public DomainObject LoadObject(UnitOfWork uow, Guid oid)
		{
			DomainObject obj = CreateObjectTemplate(uow, oid, false);
			if (m_xtypeInfo.IsTemporary)
			{
				obj.State = DomainObjectState.New;
				return obj;
			}
			LoadObject(uow, obj);
			return obj;
		}
		public void LoadObject(UnitOfWork uow, DomainObject obj)
		{
			if (obj.State == DomainObjectState.Loading)
				return;
			doLoad(uow, obj);
			obj.State = DomainObjectState.Loaded;
		}
		public DomainObject CreateGhost(UnitOfWork uow, Guid oid)
		{
			DomainObject obj = CreateObjectTemplate(uow, oid, false);
			obj.State = DomainObjectState.Ghost;
			obj.TS = -1;
			return obj;
		}
		protected abstract void doLoad(UnitOfWork uow, DomainObject obj);
		public abstract DomainPropSetBase LoadPropCollection(UnitOfWork uow, Guid ownerOID, string sPropName);
		public abstract void LoadPropLOB(UnitOfWork uow, DomainPropLOB prop);
	}
    /// <summary>
    /// Вспомогательный класс для работы с  Mapper-ами
    /// </summary>
	public class MapperRegistry
	{
		private Hashtable m_mappers = new Hashtable();
		public MapperRegistry()
		{}

		public Mapper GetMapper(string sTypeName)
		{
			return (Mapper)m_mappers[sTypeName];
		}

		public void SetMapper(string sTypeName, Mapper mapper)
		{
			if (m_mappers.Contains(sTypeName))
				m_mappers[sTypeName] = mapper;
			else
				m_mappers.Add(sTypeName, mapper);
		}

		public void AddMapper(string sTypeName, Mapper mapper)
		{
			m_mappers.Add(sTypeName, mapper);
		}
	}
    /// <summary>
    /// "Фабрика" реализаций класса <see cref="Croc.IncidentTracker.Storage.DomainObject" />.
    /// </summary>
	public class DomainObjectFactory
	{
		protected Type m_type; // Тип объекта
        protected XTypeInfo m_xtypeInfo; // Описание типа ds-объекта.

		public DomainObjectFactory(XTypeInfo xtypeInfo)
		{
			m_xtypeInfo = xtypeInfo;
		}

		public DomainObjectFactory(XTypeInfo xtypeInfo, Type type): this(xtypeInfo)
		{
			m_type = type;
		}

		protected virtual DomainObject createObjectInstace(UnitOfWork uow, Guid oid)
		{
			if (m_type == null)
				return new DomainObject(uow, m_xtypeInfo, oid, DomainObjectState.Unknown);
			else
			{
				ConstructorInfo ctorInfo = m_type.GetConstructor( new Type[] { typeof(UnitOfWork), typeof(XTypeInfo), typeof(Guid) } );
				return (DomainObject)ctorInfo.Invoke( new object[] {uow, m_xtypeInfo, oid} );
			}
		}

		protected virtual DomainPropBase createPropInstace(DomainObject obj, XPropInfoBase xpropInfo)
		{
			DomainPropBase prop;
			switch(xpropInfo.VarType)
			{
				case XPropType.vt_object:
					if (xpropInfo is XPropInfoObjectScalar)
						prop = new DomainPropObjectScalar(obj, (XPropInfoObject)xpropInfo);
					else if (xpropInfo is XPropInfoObjectArray)
						prop = new DomainPropCollection(obj, (XPropInfoObjectArray)xpropInfo);
					else if (xpropInfo is XPropInfoObjectLink)
						prop = new DomainPropLink(obj, (XPropInfoObjectLink)xpropInfo);
					else
						throw new ApplicationException();
					break;
				case XPropType.vt_text:
					prop = new DomainPropText(obj, xpropInfo);
					break;
				case XPropType.vt_bin:
					prop = new DomainPropBinary(obj, xpropInfo);
					break;
				case XPropType.vt_boolean:
					prop = new DomainPropBoolean(obj, (XPropInfoBoolean)xpropInfo);
					break;
				case XPropType.vt_string:
					prop = new DomainPropString(obj, (XPropInfoString)xpropInfo);
					break;
				case XPropType.vt_uuid:
					prop = new DomainPropUUID(obj, (XPropInfoSimple)xpropInfo);
					break;
				case XPropType.vt_smallBin:
					prop = new DomainPropSmallBin(obj, (XPropInfoSmallBin)xpropInfo);
					break;
				case XPropType.vt_r4:
					prop = new DomainPropNumericSingle(obj, (XPropInfoNumeric)xpropInfo);
					break;
				case XPropType.vt_r8:
					prop = new DomainPropNumericDouble(obj, (XPropInfoNumeric)xpropInfo);
					break;
				case XPropType.vt_fixed:
					prop = new DomainPropNumericDecimal(obj, (XPropInfoNumeric)xpropInfo);
					break;
				default:
					if (xpropInfo is XPropInfoNumeric)
						prop = new DomainPropNumericInt(obj, (XPropInfoNumeric)xpropInfo);
					else if (xpropInfo is XPropInfoDatetime)
						prop = new DomainPropDateTime(obj, (XPropInfoDatetime)xpropInfo);
					else
						throw new ApplicationException();
					break;
			}
			return prop;
		}

		public DomainObject CreateObject(UnitOfWork uow, Guid oid, bool bWithDefault)
		{
			DomainPropBase prop;
			DomainObject obj = createObjectInstace(uow, oid);
			foreach(XPropInfoBase xpropInfo in m_xtypeInfo.Properties)
			{
				prop = createPropInstace(obj, xpropInfo);

				if (bWithDefault && xpropInfo is IXPropWithDefaultValue)
				{
					if (((xpropInfo as IXPropWithDefaultValue).DefaultType & XPropDefaultType.Xml) > 0)
					{
						// если значение по умолчанию задано, то для временных типов может использоваться макрос "текущее время/дата"
						if (xpropInfo.VarType == XPropType.vt_date || xpropInfo.VarType == XPropType.vt_time || xpropInfo.VarType == XPropType.vt_dateTime )
						{
							if ((xpropInfo as XPropInfoDatetime).IsCurrentDateDefault)
								((DomainPropDateTime)prop).Value = DateTime.Now;
						}
						else if (xpropInfo is XPropInfoString)
							((DomainPropString)prop).Value = ((XPropInfoString)xpropInfo).DefaultValue;
						else if (xpropInfo is XPropInfoNumeric)
							((DomainPropSimpleBase)prop).ValueUnstrict = ((XPropInfoNumeric)xpropInfo).DefaultValue;
						else if (xpropInfo is XPropInfoBoolean)
							((DomainPropBoolean)prop).Value = ((XPropInfoBoolean)xpropInfo).DefaultValue;
					}
				}
				obj.Props[xpropInfo.Name] = prop;
			}	
			return obj;
		}
		public XTypeInfo TypeInfo
		{
			get { return m_xtypeInfo; }
		}
	}

	public class GetObjectConflictEventArgs: EventArgs
	{
		public DomainObject ObjectFromServer;
		public DomainObject ObjectLocal;
		public GetObjectConflictEventArgs(DomainObject objFromServer, DomainObject objLocal)
		{
			ObjectFromServer = objFromServer;
			ObjectLocal = objLocal;
		}
	}

	public class DeleteObjectConflictEventArgs: EventArgs
	{
		public DomainObject ObjectDeleted;
		public ArrayList AllReferences;
		public ArrayList MandatoryReferences;
		public DeleteObjectConflictEventArgs(DomainObject objDeleted, ArrayList aReferences, ArrayList aMandatoryReferences)
		{
			ObjectDeleted = objDeleted;
			AllReferences = aReferences;
			MandatoryReferences = aMandatoryReferences;
		}
	}

	public class DeletingObjectEventArgs: EventArgs
	{
		public DomainObject DeletingObject;
		public DeletingObjectEventArgs(DomainObject obj)
		{
			DeletingObject = obj;
		}
	}

	public class ObjectLoadedEventArgs: EventArgs
	{
		public DomainObject ObjectLoaded;
		public ObjectLoadedEventArgs(DomainObject objLoaded)
		{
			ObjectLoaded = objLoaded;
		}
	}

	public delegate void GetObjectConflictEventHandler(object sender, GetObjectConflictEventArgs e);
	public delegate void DeleteObjectConflictEventHandler(object sender, DeleteObjectConflictEventArgs e);
	public delegate void DeletingObjectEventHandler(object sender, DeletingObjectEventArgs e);
	public delegate void ObjectLoadedEventHandler(object sender, ObjectLoadedEventArgs e);

    /// <summary>
    /// Вспомогательный класс для работы DomainObject
    /// </summary>
	public abstract class UnitOfWork
	{
		protected bool m_bLazyLoadEnabled = true; // Признак включения загрузки объектов
		protected MapperRegistry m_mapperRigistry; // Mapper-ы 
		protected ObjectRegistry m_objects = new ObjectRegistry();
		public event GetObjectConflictEventHandler GetObjectConflict; // Событие возникновения конфликтов при получении объекта
        public event DeleteObjectConflictEventHandler DeleteObjectConflict; // Событие возникновения конфликтов при удалении объекта 
		public event DeletingObjectEventHandler DeletingObject; // Событие удаления объекта
		public event ObjectLoadedEventHandler ObjectLoaded; // Событие загрузки объекта
        
		protected virtual bool OnGetObjectConflict(GetObjectConflictEventArgs e)
		{
			if (GetObjectConflict != null)
			{
				GetObjectConflict(this,  e);
				return true;
			}
			return false;
		}
        /// <summary>
        /// Обработчик события DeleteObjectConflict
        /// </summary>
        /// <param name="e"></param>
		protected virtual bool OnDeleteObjectConflict(DeleteObjectConflictEventArgs e)
		{
			if (DeleteObjectConflict != null)
			{
				DeleteObjectConflict(this, e);
				return true;
			}
			return false;
		}
        /// <summary>
        /// Обработчик события DeletingObject
        /// </summary>
        /// <param name="e"></param>
        /// <returns></returns>
		protected virtual void OnDeletingObject(DeletingObjectEventArgs e)
		{
			if (DeletingObject != null)
				DeletingObject(this, e);
		}
        /// <summary>
        /// Обработчик события ObjectLoaded
        /// </summary>
        /// <param name="e"></param>
        /// <returns></returns>
		protected virtual void OnObjectLoaded(ObjectLoadedEventArgs e)
		{
			if (ObjectLoaded != null)
				ObjectLoaded(this, e );
		}
        /// <summary>
        /// Создание объекта
        /// </summary>
        /// <param name="sTypeName">Тип объекта</param>
        /// <returns>DomainObject</returns>
		public DomainObject Create(string sTypeName)
		{
			DomainObject obj = MapperRegistry.GetMapper(sTypeName).CreateNewObject(this);
			m_objects.Add(obj);
			return obj;
		}
        /// <summary>
        /// Создание объекта
        /// </summary>
        /// <param name="sTypeName">Тип объекта</param>
        /// <param name="oid">Идентификатор объекта</param>
        /// <returns>DomainObject</returns>
		public DomainObject GetObject(string sTypeName, Guid oid)
		{
			DomainObject obj = m_objects.Find(sTypeName, oid);
			if (obj != null)
			{
				loadObject(obj);
				return obj;
			}
			if (obj == null)
			{
				obj = MapperRegistry.GetMapper(sTypeName).LoadObject(this, oid);
			}
			m_objects.Add(obj);
			OnObjectLoaded(new ObjectLoadedEventArgs(obj) );
			return obj;
		}

		public void LoadObjects(XObjectIdentity[] objIdentities)
		{
			ArrayList objToLoad = new ArrayList();
			DomainObject obj;
			foreach(XObjectIdentity objId in objIdentities)
			{
				obj = m_objects.Find(objId.ObjectType, objId.ObjectID);
				if (obj == null)
					objToLoad.Add(objId);
			}
			throw new NotImplementedException();
		}

		public DomainObject GetGhost(string sTypeName, Guid oid)
		{
			DomainObject obj = m_objects.Find(sTypeName, oid);
			if (obj != null)
			{
				// TODO: а что делать если obj.IsDeleted ??? Наверное исключение надо
				if (obj.IsDeleted)
					throw new InvalidOperationException("Запрошенный объект (" + obj + ") помечен как удаленный в текущей транзакции");
				return obj;
			}
			obj = MapperRegistry.GetMapper(sTypeName).CreateGhost(this, oid);
			m_objects.Add(obj);
			return obj;
		}

		internal void loadObject(DomainObject obj)
		{
			if (obj.State != DomainObjectState.Ghost)
				return;
			if (!m_bLazyLoadEnabled)
				throw new InvalidOperationException("Загрузка объектов отключена");
			MapperRegistry.GetMapper(obj.ObjectType).LoadObject(this, obj);
			OnObjectLoaded(new ObjectLoadedEventArgs(obj));
		}

		internal void loadProperty(DomainPropSetBase prop)
		{
			if (!m_bLazyLoadEnabled)
				throw new InvalidOperationException("Загрузка объектов отключена");
			DomainPropSetBase objColLoaded = MapperRegistry.GetMapper(prop.Parent.ObjectType).LoadPropCollection(this, prop.Parent.ObjectID, prop.PropName);
			DomainObject objLocal;
			foreach(DomainObject obj in objColLoaded.Internal_Values)
			{
				objLocal = m_objects.Find(obj.ObjectType, obj.ObjectID );
				if (objLocal != null)
				{
					// уже загружался
					if (obj.TS != objLocal.TS)
					{
						if (!OnGetObjectConflict(new GetObjectConflictEventArgs(obj, objLocal)))
							// TODO: специальный тип исключения
							throw new ApplicationException();
					}
					prop.Internal_Values.Add(objLocal);
				}
				else
				{
					// не загружался
					m_objects.Add(obj);
					prop.Internal_Values.Add(obj);
				}
			}
		}

		internal void loadProperty(DomainPropLOB prop)
		{
			if (!m_bLazyLoadEnabled)
				throw new InvalidOperationException("Загрузка объектов отключена");
			m_mapperRigistry.GetMapper(prop.Parent.ObjectType).LoadPropLOB(this, prop);
		}

		internal void deleteObject(DomainObject obj)
		{
			OnDeletingObject(new DeletingObjectEventArgs(obj));
			// Сформируем список ссылок и список обязательных ссылок на текущий объект
			ArrayList aReferences = new ArrayList();
			ArrayList aMandatoryReferences = new ArrayList();
			// по всем свойствам Скаляр, Массив, Коллекция, ссылающиймся на тип текущего объекта
			foreach(XPropInfoObject propInfo in obj.TypeInfo.ReferencesOnMe)
			{
				// по всем объектам реестра, обладающим текущим свойством
				foreach(DomainObject objRef in m_objects.GetSameTypeObjects(propInfo.ParentType.Name).Values)
				{
					// ссылки со стороны заглушек и инвалиндых объектов нам не интересны
					if (!objRef.IsLoaded && !objRef.IsNew)
						continue;
					DomainPropBase prop = (DomainPropBase)objRef.Props[propInfo.Name];
					if (prop == null)
						continue;
					
					if (prop is DomainPropObjectScalar)
					{
						DomainPropObjectScalar propScalar = (DomainPropObjectScalar)prop;
						if (propScalar.HasReferedOn(obj.ObjectID))
						{
							aReferences.Add(propScalar);
							if (propScalar.PropInfo.NotNull)
								aMandatoryReferences.Add(propScalar);
						}
					}
					else if (prop is DomainPropCollectionBase)
					{
						DomainPropCollectionBase propCol = (DomainPropCollectionBase)prop;
						if (propCol.FindObjectValue(obj.ObjectID) != null)
						{
							aReferences.Add(prop);
							// если массив или коллекция без обратного свойства, значит свойство обязательное
							if (!(propCol.PropInfo.Capacity == XPropCapacity.Collection && propCol.PropInfo.ReverseProp == null))
								aMandatoryReferences.Add(prop);
						}
					}
				}
			}
			if (aReferences.Count > 0)
			{
				if ( OnDeleteObjectConflict(new DeleteObjectConflictEventArgs(obj, aReferences, aMandatoryReferences)) )
				{
					// TODO: а что делать дальше???
					return;
				}
				else
					throw new InvalidOperationException("Объект " + obj.ObjectType + " [" + obj.ObjectID.ToString() + "] не может быть удален, т.к. на него имеются обязательные ссылки" );
			}
			
			// раз объект можно удалять, вычистим ссылки на него из линков, членств в коллекции и массиве
			foreach(DomainPropBase prop in obj.Props.Values)
				if (prop is DomainPropObjectBase)
				{
					XPropInfoBase revPropInfo = ((DomainPropObjectBase)prop).PropInfo.ReverseProp;
					// синхронизируем "слабые" обратные свойства, т.е. удалим ссылки на текущий объект
					if (revPropInfo != null)
					{
						if (prop is DomainPropObjectScalar)
						{
							// удалим текущий объект из обратного линка
							DomainPropObjectScalar propScalar = (DomainPropObjectScalar)prop;
							if (!propScalar.IsNull)
							{
								((DomainPropLink)propScalar.Value.Props[revPropInfo.Name]).internal_AddPendingAction(DomainPropPendingActionMode.Remove, obj);
							}
						}
						else if (prop is DomainPropArray || prop is DomainPropCollection)
						{
							// удалим текущий объект из обратного членства в массиве или членства в коллекции
							DomainPropCollectionBase propArray = (DomainPropCollectionBase)prop;
							foreach(DomainObject objValue in propArray.Internal_Values)
								((DomainPropCollectionBase)objValue.Props[revPropInfo.Name]).internal_AddPendingAction(DomainPropPendingActionMode.Remove, obj);
						}
					}
				}
			if (obj.IsNew)
				m_objects.Remove(obj);
			obj.setDeleted();
		}

		public bool Commit()
		{
			doSave();
			foreach(DomainObject obj in m_objects.GetModifiedObjects())
			{
				if (obj.IsDeleted)
					// ссылок на удаленный объект быть не должно
					m_objects.Remove(obj);
				else
					obj.Expire();
			}
			return true;
		}

		protected abstract void doSave();
		public MapperRegistry MapperRegistry
		{
			get { return m_mapperRigistry; }
		}

		public bool LazyLoad
		{
			get { return m_bLazyLoadEnabled; }
			set { m_bLazyLoadEnabled = value; }
		}
	}
    /// <summary>
    /// Вспомогательный класс работы с коллекцией объектов  DomainObject
    /// </summary>
}	public class ObjectRegistry: IEnumerable
	{
		HybridDictionary m_objects = new HybridDictionary();

		public DomainObject Find(string sTypeName, Guid oid)
		{
			IDictionary item_objects = GetSameTypeObjects(sTypeName);
			return (DomainObject)item_objects[oid];
		}

		public void Add(DomainObject obj)
		{
			IDictionary item_objects = GetSameTypeObjects(obj.ObjectType);
			item_objects.Add(obj.ObjectID, obj);
		}
		public void Remove(DomainObject obj)
		{
			IDictionary item_objects = GetSameTypeObjects(obj.ObjectType);
			item_objects.Remove(obj.ObjectID);
		}
		public IDictionary GetSameTypeObjects(string sTypeName)
		{
			HybridDictionary item_objects = (HybridDictionary)m_objects[sTypeName];
			if (item_objects == null)
			{
				item_objects = new HybridDictionary();
				m_objects.Add(sTypeName, item_objects);
			}
			return item_objects;
		}
		public DomainObject[] GetAllObjects()
		{
			ArrayList aObjects = new ArrayList(16);
			foreach(HybridDictionary item_objects in m_objects.Values)
				foreach(DomainObject obj in item_objects.Values)
					aObjects.Add(obj);
			DomainObject[] objects = new DomainObject[aObjects.Count];
			aObjects.CopyTo(objects, 0);
			return objects;
		}
		public DomainObject[] GetModifiedObjects()
		{
			ArrayList aObjects = new ArrayList(16);
			foreach(HybridDictionary item_objects in m_objects.Values)
				foreach(DomainObject obj in item_objects.Values)
					if (obj.IsNew || obj.IsDeleted || obj.IsDirty)
						aObjects.Add(obj);
			DomainObject[] objects = new DomainObject[aObjects.Count];
			aObjects.CopyTo(objects, 0);
			return objects;
		}
		public IEnumerator GetEnumerator()
		{
			return GetAllObjects().GetEnumerator();
		}
	}

