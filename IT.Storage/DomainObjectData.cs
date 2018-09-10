//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
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
		/// Признак - объект новый (для вставки). Влияет на свойство HasNewData
		/// </summary>
		protected bool m_bIsNew;
		/// <summary>
		/// Признак - объект предназначен для удаления. НЕ влияет на свойство HasNewData
		/// </summary>
		protected bool m_bToDelete;
		/// <summary>
		/// Загруженные значения свойств
		/// </summary>
		protected HybridDictionary m_propsLoadedValues = new HybridDictionary(true);
		/// <summary>
		/// Массив размеров LOB-свойств. Размерность массива совпадает с количеством LOB-свойств типа
		/// </summary>
		protected Hashtable m_loadedLOBPropsDataSizes = new Hashtable();
		/// <summary>
		/// Обновленные значения свойств (для сохранения в БД). Влияет на свойство HasNewData
		/// </summary>
		protected HybridDictionary m_propsUpdatedValues = new HybridDictionary(true);
		/// <summary>
		/// словарь свойств, для которых были загружены кусочные данные. Ключ: наименование свойства, значение - идентификатор цепочки
		/// </summary>
		protected HybridDictionary m_propertiesWithChunkedData = new HybridDictionary(true);

		internal DomainObjectData(XTypeInfo typeInfo, Guid objectID, bool bIsNew, bool bToDelete)
			: base(typeInfo, objectID)
		{
			if (bIsNew && bToDelete)
				throw new ArgumentException("Признаки 'новый объект' и 'удаляемый объект' не могут быть заданы одновременно");
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
		/// Возвращает признак "Полностью загруженный объект", т.е. содержит данные из БД всех свойств, кроме LOB и массивных
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
					// все остальные должны быть
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
		/// Возвращает признак наличия загруженного свойства с заданным именем
		/// </summary>
		/// <param name="sPropName"></param>
		/// <returns></returns>
		public bool HasLoadedProp(string sPropName)
		{
			return m_propsLoadedValues.Contains(sPropName);
		}

		/// <summary>
		/// Возвращает значение загруженного свойства.
		/// Для массивных свойств возвращает DomainObjectDataArrayPropHandle, 
		/// для LOB - DomainObjectDataBinPropHandle или DomainObjectDataTextPropHandle
		/// для объектных склярных - Guid или DBNull
		/// </summary>
		/// <param name="sPropName">Наименование свойства</param>
		/// <returns>Значение свойства, в том числе DBNull.Value. Если свойство не загружено - null</returns>
		public object GetLoadedPropValue(string sPropName)
		{
			return m_propsLoadedValues[sPropName];
		}

		/// <summary>
		/// Возвращает значение загруженного свойства. 
		/// Если свойство не загружено - загружает его
		/// Возвращает то же, что и метод GetLoadedPropValue
		/// </summary>
		/// <param name="con"></param>
		/// <param name="sPropName"></param>
		/// <returns></returns>
		public object GetLoadedPropValueOrLoad(XStorageConnection con, string sPropName)
		{
			object vValue = m_propsLoadedValues[sPropName];
			// если значения свойства нет и объект неновый - зачитаем свойство из БД
			if (vValue == null && !IsNew)
			{
				if (m_context == null)
					throw new InvalidOperationException("Метод может использоваться только в случае установленной связи с DomainObjectDataSet");
				m_context.LoadProperty(con, this, sPropName);
				vValue = GetLoadedPropValue(sPropName);
			}
			return vValue;
		}

		/// <summary>
		/// Устанавливает значение свойства
		/// </summary>
		/// <param name="sPropName"></param>
		/// <param name="vPropValue"></param>
		public void SetLoadedPropValue(string sPropName, object vPropValue)
		{
			if (vPropValue == null)
				vPropValue = DBNull.Value;
			if (IsNew)
				throw new InvalidOperationException("Новый объект не может содержать загруженных данных");
			XPropInfoBase propInfo = TypeInfo.GetProp(sPropName);
			if (propInfo == null)
				throw new ArgumentException("Неизвестное наименование свойства: " +sPropName);
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
				throw new ArgumentException("Задано не LOB-свойство: " + sPropName + " (" + propInfo.VarType +")");
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
		/// Возвращает коллекцию наименований загруженных свойств
		/// Примечание: коллекция наименований создается отдельно и не препятствует модификации значений свойств
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
		/// Возвращает значение обновляемого свойства.
		/// Для text/bin (LOB) также возвращается значение (в т.ч. DBNull), либо null, если св-во отсутствует или непрогружено
		/// </summary>
		/// <param name="sPropName">Наименование свойства</param>
		/// <returns>Значение свойства, в том числе DBNull.Value. Если свойство не сохраняется - null</returns>
		public object GetUpdatedPropValue(string sPropName)
		{
			return m_propsUpdatedValues[sPropName];
		}

		/// <summary>
		/// Устанавливает новое (обновляемое) значение свойства.
		/// Проверяет тип значения на соответствие типу свойства
		/// </summary>
		/// <param name="sPropName">Наименование свойства</param>
		/// <param name="vPropValue">Значение свойства</param>
		public void SetUpdatedPropValue(string sPropName, object vPropValue)
		{
			XPropInfoBase propInfo = TypeInfo.GetProp(sPropName);
			if (propInfo == null)
				throw new ArgumentException("Неизвестное наименование свойства: " +sPropName);
			if (vPropValue == null)
				vPropValue = DBNull.Value;
			if (vPropValue != DBNull.Value)
			{
				if (propInfo is XPropInfoObjectScalar || propInfo.VarType == XPropType.vt_uuid)
				{
					if (!(vPropValue is Guid))
						throw new ArgumentException("Некорректное значение свойства " +sPropName + " типа " + propInfo.VarType + " : " + vPropValue);
				} 
				else if (propInfo is XPropInfoObjectArray || propInfo is XPropInfoObjectLink)
				{
					// массивное объектное свойство - значение массив гуидов
					if (!(vPropValue is Guid[]))
						throw new ArgumentException("Некорректное значение свойства " + sPropName + " типа " + propInfo.VarType + " : " + vPropValue);
				}
                else if (propInfo is XPropInfoDatetime)
                {
                    if (!(vPropValue is DateTime) && !(vPropValue is TimeSpan))
                        throw new ArgumentException("Некорректное значение date/time/dateTime свойства " + sPropName + " : " + vPropValue);
                    if (propInfo.VarType == XPropType.vt_date)
                    {
                        if (!(vPropValue is DateTime))
                            throw new ArgumentException("Некорректное значение date/time/dateTime свойства " + sPropName + " : " + vPropValue);
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
						throw new ArgumentException("Некорректный тип значения бинарного свойства " +sPropName);
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
		/// Возвращает коллекцию наименований обновляемых свойств
		/// Примечание: коллекция наименований создается отдельно и не препятствует модификации значений свойств
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
				throw new ArgumentException("Неизвестное наименование свойства: " +sPropName);
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
			// если не удалось получить данные свойства и стратегия нам разрешает использовать загруженные из БД данные, то загрузим свойство
			if (!IsNew && vPropValue == null && strategy != DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps)
			{
				m_context.LoadProperty(con, this, sPropName);
				vPropValue = GetLoadedPropValue(sPropName);
			}
			return vPropValue;
		}

		/// <summary>
		/// Очищает объект от данных
		/// </summary>
		public void RejectNewData()
		{
			m_propsUpdatedValues.Clear();
		}

		/// <summary>
		/// Загружает объект
		/// </summary>
		/// <param name="con"></param>
		public void Load(XStorageConnection con)
		{
			if (m_context == null)
				throw new InvalidOperationException("Метод может использоваться только в случае установленной связи с DomainObjectDataSet");
			if (!IsNew)
				m_context.loadInternal(con, ObjectType, ObjectID, this);
		}

		/// <summary>
		/// Наследие от XObjectBase - не используется!
		/// </summary>
        /*public override XObjectDependency[] References
		{
			get { throw new NotSupportedException(); }
		}*/

		/// <summary>
		/// Устанавливает или снимает признак удаляемого объекта. Применим только для загруженных объектов
		/// </summary>
		/// <param name="bToDelete"></param>
		public void SetDeleted(bool bToDelete)
		{
			if (IsNew)
				throw new InvalidOperationException("Новый объект не может быть помечен как удаляемый");
			m_bToDelete = bToDelete;
		}
		
		public override string ToString()
		{
			return ObjectType + "[" + ObjectID + "]";
		}

		/// <summary>
		/// Устанавливает новый идентификатор объекту
		/// </summary>
		/// <param name="newOID"></param>
		
	}

	/// <summary>
	/// Варианты поведения DomainObjectDataSet/DomainObjectData при навигации по списку свойств
	/// </summary>
	public enum DomainObjectDataSetWalkingStrategies
	{
		/// <summary>
		/// Использовать только новые значения свойств
		/// </summary>
		UseOnlyUpdatedProps,
		/// <summary>
		/// Использовать только загруженные значения свойств
		/// </summary>
		UseOnlyLoadedProps,
		/// <summary>
		/// Использовать только новые значения, а если они отсутствуют, то загруженные значения
		/// </summary>
		UseUpdatedPropsThanLoadedProps,
	}

	public class DomainObjectDataSet
	{
		/// <summary>
		/// Стратегии поведения DomainObjectDataSet при загрузке объекта из БД, часть данных которого уже содержится в множестве
		/// </summary>
		public enum PartialObjectMergeStrategies
		{
			/// <summary>
			/// Добавлять отсутствующие свойства, остальные не трогать
			/// </summary>
			AddMissingProps,
			/// <summary>
			/// Заменять все свойства, т.е. объект полностью перегружается данными из БД
			/// </summary>
			ReplaceAllProps,
			/// <summary>
			/// Добавлять отсутствующие свойства, существующие сравнивать с загруженными и в случае расхождения генеировать исключение
			/// </summary>
			UpdatePropsWithCheck
		}

		/// <summary>
		/// Варианты поведения DomainObjectDataSet/DomainObjectData при необходимости подгрузки отсутствующего в контексте значения свойства.
		/// Для массивных и LOB-свойств всегда неявно используется значене LoadOnlyRequiredProp.
		/// </summary>
		public enum PartialObjectPropLoadStrategies
		{
			/// <summary>
			/// Загружать весь объект
			/// </summary>
			LoadEntireObject,
			/// <summary>
			/// Загружать только значение требуемого свойства
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
				throw new ArgumentException("Множество уже содержит данный объект: " + xobj.ToString());
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
		/// Ищет в контексте объект с заданными типов и идентификатором, и, если не находит, создает болванку
		/// Создаваемая болванка свойств не содержит.
		/// К БД обращений не производит.
		/// </summary>
		/// <param name="sObjectType">Тип объекта</param>
		/// <param name="ObjectID">Идентификатор объекта</param>
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
		/// Создает в текущем контексте заглушку объекта из БД
		/// ВНИМАНИЕ: если в контексте уже содержится объект с таким идентификатором возникает исключение
		/// К БД обращений не производит.
		/// </summary>
		/// <param name="sObjectType">Тип объекта</param>
		/// <param name="ObjectID">Идентификатор объекта</param>
		/// <param name="nTS">timespamp объекта</param>
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
			// TOTHING: почему здесь не устанавливаем значения по умолчанию ?
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
		/// Создает новый объект со свойствами, устанавливая значения по умолчанию
		/// LOB-свойства не добавляет
		/// </summary>
		/// <param name="sObjectType">Наименование типа объекта</param>
		/// <param name="bCreatePropHandlers">true - создавать для свойств объекты-описатели</param>
		/// <returns></returns>
		public DomainObjectData CreateNew(string sObjectType, bool bCreatePropHandlers)
		{
			DomainObjectData xobj = CreateStubNew(sObjectType);
			foreach(XPropInfoBase propInfo in xobj.TypeInfo.Properties)
			{
				// если для свойств требуются объекты-описатели
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
						// если значение по умолчанию задано, то для временных типов может использоваться макрос "текущее время/дата"
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
		/// Загружает в контекст объект заданного типа и идентификатора
		/// Если запрошенный объект уже есть, но загружен не полностью, он загружается и производиться слияние в соответствии с текущей стратегией DomainObjectDataSetPartialObjectUpdateStrategies
		/// Если объект загружен полностью, то он более не загружается
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
		/// Внутренний метод. Тот же Load, но не выполняет Find(sObjectType, ObjectID)
		/// </summary>
		/// <param name="con"></param>
		/// <param name="sObjectType"></param>
		/// <param name="ObjectID"></param>
		/// <param name="xobjOriginal">Существующий объект (если отсутствует, то null)</param>
		/// <returns></returns>
		internal DomainObjectData loadInternal(XStorageConnection con, string sObjectType, Guid ObjectID, DomainObjectData xobjOriginal)
		{
			DomainObjectData xobjToLoad = null;
			DomainObjectData xobjResult;
			bool bNeedMerge = false;
			bool bNeedLoad;

			if (xobjOriginal == null)
			{
				// объекта такого нет - создим болванку и загрузим данные свойств
				bNeedLoad = true;
				xobjToLoad = GetLoadedStub(sObjectType, ObjectID);
				xobjResult = xobjToLoad;
			}
			else if (!xobjOriginal.IsFullyLoaded)
			{
				// объект есть, но загружен не полностью - будем грузить, а потом выполним слияние
				bNeedLoad = true;
				bNeedMerge = true;
				// создадим объект без связи с кентекстом (DomainObjectDataSet'ом)
                xobjToLoad = new DomainObjectData(m_xmodel.FindTypeByName(sObjectType), ObjectID, false, false);
				xobjResult  = xobjOriginal;
			}
			else
			{
				// уже есть полностью загруженный объект - ничего делать не будем
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
								// свойство было и надо проверить на совпадение
								if (xobjOriginal.GetLoadedPropValue(sPropName) != xobjToLoad.GetLoadedPropValue(sPropName))
									throw new ApplicationException("Значения свойства " + sPropName + " отличаются");
							}
							else if (m_strategy == PartialObjectMergeStrategies.ReplaceAllProps)
							{
								// свойство было и надо заменить
								xobjOriginal.SetLoadedPropValue(sPropName, xobjToLoad.GetLoadedPropValue(sPropName));
							}
						}
						else
						{
							// свойства ранее не было
							xobjOriginal.SetLoadedPropValue(sPropName, xobjToLoad.GetLoadedPropValue(sPropName));
						}
					}
				}
			}
			return xobjResult;
		}

		/// <summary>
		/// Загружает данные переданного объекта
		/// Действия: формирует запрос, выполняет его и вызывает fillObjectPropertiesFromDataReader
		/// Примечание: все существующие загруженные данные перезаписываются (в отличии от Load)
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">Загружаемый объект</param>
		/// <exception cref="XObjectNotFoundException">Объект не обнаружен в БД</exception>
		public void LoadObject(XStorageConnection con, DomainObjectData xobj)
		{
			XTypeInfo typeInfo = xobj.TypeInfo;		// Метаданные типа
			if (typeInfo.IsTemporary)
				throw new ArgumentException("Невозможно загрузить данные временного объекта" + typeInfo.Name);
			// критерий отбора объекта: доформировываем запрос фразой o.ObjectID = <заданный GUID>	
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
						// зачитаем все свойства объекта из dataReader'a
						fillObjectPropertiesFromDataReader(dataReader, xobj);
					}
					else
					{
						// если объект не найден - генерируем исключение
						throw new XObjectNotFoundException( xobj.ObjectType, xobj.ObjectID );
					}
				}
				// ловим ошибки выполнения запроса. Обычно такое может быть, если метаданные не соответствуют структуре БД
				catch(XDbException ex)
				{
					// Примечание XObjectNotFoundException не порожден от XDbException, поэтому здесь мы его не поймаем
					throw new XDbException("Ошибка при загрузке объекта " + xobj.ToString() + ": " + ex.Message, ex);
				}
				finally
				{
					if (dataReader != null)
						dataReader.Close();
				}
			}
		}

		/// <summary>
		/// Наполняет объект xobj данными скалярных свойств.
		/// Для LOB-свойств зачитываются размер данных.
		/// </summary>
		/// <param name="dataReader">reader с данными. 1-ое поле ObjectID, 2-ое ts, далее колонки всех скалярных свойств. 
		/// LOB-свойства присутствуют, но для них зачитываются размер данных</param>
		/// <param name="xobj">объект-владелец свойств</param>
		protected void fillObjectPropertiesFromDataReader(IXDataReader dataReader, DomainObjectData xobj)
		{
			string sPropName;
			XPropInfoBase propInfo;
			object vValue;
			long nTS = -1;
			if (!dataReader.IsDBNull(1))			// есть ли ts
			{
				nTS = dataReader.GetInt64(1);
			}
			xobj.SetTS(nTS);
			// 0 - ObjectID, 1 - TS, свойства начинаются с индекса 2
			for(int i=2;i<dataReader.FieldCount;++i)
			{
				sPropName = dataReader.GetName(i);
				propInfo = xobj.TypeInfo.GetProp(sPropName);
				if (propInfo is IXPropInfoScalar)
				{
					// скалярное свойство
					vValue = readPropValueFromDB(dataReader, propInfo.VarType, i);
					if (propInfo.VarType == XPropType.vt_bin || propInfo.VarType == XPropType.vt_text)
					{
						// для LOB-свойств readPropValueFromDB возвращает размер данных!
						Debug.Assert(vValue is Int32, "Для LOB-свойств readPropValueFromDB должен возвращать размер данных");
						xobj.SetLoadedPropDataSize(sPropName, (int)vValue);
					}
					else
					{
						xobj.SetLoadedPropValue(sPropName, vValue);
					}
				}
				else
					throw new ArgumentException("В DomainObjectDataSet.fillObjectPropertiesFromDataReader должен передаваться IXDataReader только с колонками скалярных свойств объекта");
			}
		}

		/// <summary>
		/// Считывает значение скалярного свойства из поля DataReader'a.
		/// Для LOB-свойств ожидается и возвращается размер данных
		/// </summary>
		/// <param name="dataReader">Текущий спозиционированный DataReader</param>
		/// <param name="vt">Тип свойства</param>
		/// <param name="i">Индекс колонки свойства</param>
		/// <returns>Значение свойства или DBNull.Value для NULL-полей, для LOB-свойств - размер данных (Int32)</returns>
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
		/// Ищет в контексте объект с заданными типом и идентификатором
		/// </summary>
		/// <param name="sObjectType">Тип объекта</param>
		/// <param name="ObjectID">Идентификатор объекта</param>
		/// <returns>Экземпляр DomainObjectData или null, если объект не найден</returns>
		public DomainObjectData Find(string sObjectType, Guid ObjectID)
		{
			return (DomainObjectData)m_objects[getKey(sObjectType, ObjectID)];
		}

		/// <summary>
		/// Возвращает экземпляр DomainObjectData объекта с заданными типом и идентификатором
		/// Если объект находится в контексте, то возвращается он, иначе загружается из БД
		/// </summary>
		/// <param name="con"></param>
		/// <param name="sObjectType">Тип объекта</param>
		/// <param name="ObjectID">Идентификатор объекта</param>
		/// <returns>Экземпляр DomainObjectData</returns>
		/// <exception cref="XObjectNotFoundException">Объект не найден ни в контексте, ни в БД</exception>
		public DomainObjectData Get(XStorageConnection con, string sObjectType, Guid ObjectID)
		{
			DomainObjectData xobj = Find(sObjectType, ObjectID);
			if (xobj == null)
				xobj = loadInternal(con, sObjectType, ObjectID, xobj);
			return xobj;
		}

		/// <summary>
		/// Возвращает наименование типа объекта значения заданного свойства заданного типа
		/// </summary>
		/// <param name="sObjectType">Наименование типа</param>
		/// <param name="sPropName">Наименование свойства</param>
		/// <param name="con"></param>
		/// <returns>Наименование типа объекта значения свойства</returns>
		private string getObjectValueTypeName(string sObjectType, string sPropName, XStorageConnection con)
		{
			XPropInfoBase xprop_base = con.MetadataManager.GetTypeInfo(sObjectType).GetProp(sPropName);
			if (!(xprop_base is XPropInfoObject))
				throw new ArgumentException("Поддерживаются только объектные свойства");
			return ((XPropInfoObject)xprop_base).ReferedType.Name;
		}

		/// <summary>
		/// Возвращает объект-значение свойства, заданного ObjectPath'ом объектных скалярных свойств относительно заданного объекта.
		/// Загружает объекты, лежащие на пути свойств, полностью.
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">Объект, относительно которого применяется OPath</param>
		/// <param name="sOPath">Цепочка объектных скалярных свойств</param>
		/// <param name="strategy">Стретегия использования свойств объекта: новые данные или загруженные</param>
		/// <param name="bAllowLoad">Разрешение загружать отсутствующие в контексте объекты из БД</param>
		/// <returns>Объект-значение или null</returns>
		public DomainObjectData Get(XStorageConnection con, DomainObjectData xobj, string sOPath, DomainObjectDataSetWalkingStrategies strategy, bool bAllowLoad)
		{
			return Get(con, xobj, sOPath, strategy, bAllowLoad, PartialObjectPropLoadStrategies.LoadEntireObject);
		}

		/// <summary>
		/// Возвращает объект-значение свойства, заданного ObjectPath'ом объектных скалярных свойств относительно заданного объекта.
		/// Позволяет контролировать стретегию загрузки объектов, лежащих на пути свойств: 
		/// либо загружать необходимое объектое свойство, либо загружать объект полностью
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">Объект, относительно которого применяется OPath</param>
		/// <param name="sOPath">Цепочка объектных скалярных свойств</param>
		/// <param name="strategy">Стретегия использования свойств объекта: новые данные или загруженные</param>
		/// <param name="bAllowLoad">Разрешение загружать отсутствующие в контексте объекты из БД</param>
		/// <param name="propLoadStrategy">Стратегия загрузки отсутствующих объектов, лежащих на пути свойств</param>
		/// <returns>Объект-значение или null</returns>
		public DomainObjectData Get(XStorageConnection con, DomainObjectData xobj, string sOPath, DomainObjectDataSetWalkingStrategies strategy, bool bAllowLoad, PartialObjectPropLoadStrategies propLoadStrategy)
		{
			string[] aPathParts = sOPath.Split('.');
			string cur_ObjectType = xobj.ObjectType; 
			Guid cur_ObjectID = xobj.ObjectID;
			string sPropName;							// наименование свойства
			object vPropValue;							// значение свойства
			bool bLoadObject;							// признак необходимости загрузки объект
			bool bLoadProp;								// признак необходимости загрузки свойства

			for(int i=0; i<aPathParts.Length; ++i)
			{
				vPropValue = null;
				xobj = Find(cur_ObjectType, cur_ObjectID);
				sPropName = aPathParts[i];
				// проверим что текущее свойство текущего объекта - объектное скалярное
                if (!(m_xmodel.FindTypeByName(cur_ObjectType).GetProp(sPropName) is XPropInfoObjectScalar))
					throw new ArgumentException("Свойство " + sPropName + " в цепочке свойств " + sOPath + " не является объектным скалярным");
				bLoadObject = false;
				bLoadProp   = false;
				if (xobj == null)
				{
					// текущий объект отсутствует в контексте - будем грузить, если можно
					if (!bAllowLoad || strategy == DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps)
						return null;
					bLoadObject = true;
				}
				else
				{
					// объект есть: получим значение свойства и признак необходимости загрузки объекта из БД
					vPropValue = getPropValue(xobj, sPropName, strategy, bAllowLoad, out bLoadProp);
					// если свойство надо грузить, но стратегия указывает грузить весь объект в случае отсутствия св-ва..
					if (bLoadProp && propLoadStrategy == PartialObjectPropLoadStrategies.LoadEntireObject)
					{
						bLoadObject = true;
						bLoadProp   = false;	// - на всякий случай
					}
				}
				// если здесь, то либо свойства нет и надо грузить (bLoad=true) и можно, либо свойство есть (в vPropValue)

				if (bLoadObject)
				{
					// надо загрузить объект целиком
					xobj = Load(con, cur_ObjectType, cur_ObjectID);
					// а теперь можно получить значение свойства (Оно уже будет только загруженным, иначе незачем было бы грузить)
					vPropValue = xobj.GetLoadedPropValue(sPropName);
				}
				else if (bLoadProp)
				{
					// объект есть, надо загрузить только одно свойство
					vPropValue = loadScalarNonLOBProp(con, xobj, sPropName);
				}

				// у нас есть значение объектного скалярного свойства (sPropName) в vPropValue
				if (vPropValue == null || vPropValue is DBNull)
					return null;
				cur_ObjectID = (Guid)vPropValue;
				// получим наименование типа объекта-значения свойства
				cur_ObjectType = getObjectValueTypeName(cur_ObjectType, sPropName, con);
			}

			// если здесь, значит нам известен идентификатор объекта-значения последнего свойства - cur_ObjectID, вернем объект
			// если объект есть в контексте его и вернем
			xobj = Find(cur_ObjectType, cur_ObjectID);
			if (xobj != null)
				return xobj;
			// иначе загрузим объект, но только в случае если можно грузить и можно грузить объект целиком
			if (bAllowLoad && propLoadStrategy == PartialObjectPropLoadStrategies.LoadEntireObject)
				return Load(con, cur_ObjectType, cur_ObjectID);
			// иначе вернем болванку
			return GetLoadedStub(cur_ObjectType, cur_ObjectID);
		}

		/// <summary>
		/// Возвращает значение заданного свойства заданного объекта с учетом стратегии получения и разрешения загружать данные из БД
		/// Если свойство отсутствует, и стратегия и разрешение загрузки из БД позволяют, возвращается признак необходимости загрузить объект (bLoad)
		/// </summary>
		/// <param name="xobj">Объект</param>
		/// <param name="sPropName">Наименование свойства</param>
		/// <param name="strategy">Стратегия получения значения свойства (новое значение или из БД или сначала 1-ое, потом 2-ое)</param>
		/// <param name="bAllowLoad">Признак разрешения загрузки данных из БД</param>
		/// <param name="bLoad">Признак необходимости загрузить объект, т.к. заданное св-во отсутствует</param>
		/// <returns>Значение свойства, как оно храниться в DomainObjectData</returns>
		protected object getPropValue(DomainObjectData xobj, string sPropName, DomainObjectDataSetWalkingStrategies strategy, bool bAllowLoad, out bool bLoad)
		{
			object vPropValue = null;						// значение свойства
			bLoad = false;
			
			if (xobj.IsNew)
			{
				// если объект новый и свойство отсутствует (оно может быть только обновляемым), то продолжать нет смысла
				// Примечание: для новых объектов всегда используем обновляемые свойства, т.к. у них других нет
				if (xobj.HasUpdatedProp(sPropName))
					vPropValue = xobj.GetUpdatedPropValue(sPropName);
				else
					return null;
			}
			else
			{
				// объект есть и он не новый:

				// если требуется использовать только обновленные свойства
				if (strategy == DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps)
				{
					if (xobj.HasUpdatedProp(sPropName))
						vPropValue = xobj.GetUpdatedPropValue(sPropName);
					else
						// свойства нет, а грузить нельзя (т.к. просили только UseOnlyUpdatedProps) -  продолжать нет смысла
						return null;
				}
				else
				{
					// если требуется использовать только загруженные свойства, а его нет или 
					// требуется использовать обновляемые или загруженные, а нет ни того, ни другого
					if (strategy == DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps && !xobj.HasLoadedProp(sPropName) ||
						strategy == DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps && !xobj.HasUpdatedProp(sPropName) && !xobj.HasLoadedProp(sPropName)
						)
					{
						// Нужного свойства нет - если можно буджем грузить, иначе продолжать нет смысла
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
		/// Возвращает значение объектного скалярного свойства относительно заданного объекта, заданного ObjectPath'ом.
		/// Возвращается значение последнего свойства. 
		/// В случае NULL-значения любого из свойств в цепочке возвращает Guid.Empty.
		/// Загружает объекты, лежащие на пути свойств, полностью
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">Объект, относительно которого вычиляются свойства</param>
		/// <param name="sOPath">Цепочка свойств</param>
		/// <param name="strategy">Стратегия получения значения свойства (новое значение или из БД или сначала 1-ое, потом 2-ое)</param>
		/// <param name="bAllowLoad">Признак возможности загружать объект из БД, если значение св-ва отсутстует и стратегия позволяет использовать значение из БД</param>
		/// <returns>Если свойство NULL (Любое из цепочки), возвращается Guid.Empty</returns>
		public Guid GetScalarObjectPropValue(XStorageConnection con, DomainObjectData xobj, string sOPath, DomainObjectDataSetWalkingStrategies strategy, bool bAllowLoad)
		{
			return GetScalarObjectPropValue(con, xobj, sOPath, strategy, bAllowLoad, PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);
		}

		/// <summary>
		/// Возвращает значение объектного скалярного свойства относительно заданного объекта, заданного ObjectPath'ом.
		/// Возвращается значение последнего свойства. 
		/// В случае NULL-значения любого из свойств в цепочке возвращает Guid.Empty.
		/// Позволяет контролировать стретегию загрузки объектов, лежащих на пути свойств: 
		/// либо загружать необходимое объектое свойство, либо загружать объект полностью
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">Объект, относительно которого вычиляются свойства</param>
		/// <param name="sOPath">Цепочка свойств</param>
		/// <param name="strategy">Стратегия получения значения свойства (новое значение или из БД или сначала 1-ое, потом 2-ое)</param>
		/// <param name="bAllowLoad">Признак возможности загружать объект из БД, если значение св-ва отсутстует и стратегия позволяет использовать значение из БД</param>
		/// <param name="propLoadStrategy">Стратегия загрузки отсутствующих объектов, лежащих на пути свойств</param>
		/// <returns>Если свойство NULL (Любое из цепочки), возвращается Guid.Empty</returns>
		public Guid GetScalarObjectPropValue(XStorageConnection con, DomainObjectData xobj, string sOPath, DomainObjectDataSetWalkingStrategies strategy, bool bAllowLoad, PartialObjectPropLoadStrategies propLoadStrategy)
		{
			if (sOPath == null)
				throw new ArgumentNullException("sOPath");
			string[] aPathParts = sOPath.Split('.');
			DomainObjectData xobj_target;
			object vPropValue;							// значение свойства
			string sPropName;							// наименование свойства

			// получим объект, владеющий последним свойством в цепочке
			if (aPathParts.Length > 1)
			{
				// создадим новый массив без последнего свойства в пути
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
			// если свойства в объекте нет, значит он загружен частично - перезагрузим его целиком, либо одно свойство (в зав-ти от loadPropStrategy)
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
		/// Прогружает все объекты, лежащие на цепочке свойств применительно к заданному объекту.
		/// Объекты лежащие на пути из свойств загружаются полностью
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">Объект владелец свойства</param>
		/// <param name="sOPath">Цепочка прогружаемых свойсвтв. Все свойства кроме последнего должны быть объектыми скалярными</param>
		public void PreloadProperty(XStorageConnection con, DomainObjectData xobj, string sOPath)
		{
			string[] aPathParts = sOPath.Split('.');
			xobj = Get(con, xobj.ObjectType, xobj.ObjectID);
			preloadPropertyInternal(con, xobj, aPathParts, 0, PartialObjectPropLoadStrategies.LoadEntireObject);
		}

		/// <summary>
		/// Загружает свойство объекта. Если значение свойства уже присутствует, то повторно оно уже не загружается.
		/// Если объект отсутствует, то загружается только значение запрошенного свойства
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">Объект владелец свойства</param>
		/// <param name="sPropName">Наименование загружаемого свойства</param>
		public void LoadProperty(XStorageConnection con, DomainObjectData xobj, string sPropName)
		{
			preloadPropertyInternal(con, xobj, new string[] {sPropName}, 0, PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);
		}

		/// <summary>
		/// Внутренний метод загрузки свойства или цепочкки свойств (вместе со всеми промежуточными объектами).
		/// Рекурсия!
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">Объект, чье свойство находится в цепочке aPathParts под индексом nIndex</param>
		/// <param name="aPathParts">Цепочка свойств</param>
		/// <param name="nIndex">Текущий индекс в aPathParts</param>
		/// <param name="propLoadStrategy">Стратегия загрузки отсутствующих объектов, лежащих на пути свойств</param>
		private void preloadPropertyInternal(XStorageConnection con, DomainObjectData xobj, string[] aPathParts, int nIndex, PartialObjectPropLoadStrategies propLoadStrategy)
		{
			string sPropName = aPathParts[nIndex];		// наименование свойства
			// если кто-то просит прогрузить ObjectID, то оно у объекта есть всегда и может быть только последним
			if (sPropName == "ObjectID")
				return;
			XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
			if (propInfo == null)
				throw new ArgumentException("Неизвестное наименование свойства \"" + sPropName + "\" объекта \"" + xobj.ObjectType + "\", указанное для прогрузки данных (цепочка свойства: " + String.Join(".", aPathParts) + ")");

			if (propInfo is XPropInfoObjectScalar)
			{
				// Объектное скалярное свойство - получим объект значение. 
				xobj = Get(con, xobj, sPropName, DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true, propLoadStrategy);
				// если свойство не последнее и объект значение загружен (св-во not null), то рекурсивно пойдем дальше
				if (xobj != null && nIndex < aPathParts.Length - 1)
					preloadPropertyInternal(con, xobj, aPathParts, nIndex + 1, propLoadStrategy);
			}
			else if (propInfo is XPropInfoObject)
			{
				// Объектное, но не скалярное свойство, т.е. любое массивное (коллекция, массив, линк)
				Guid[] values;
				// если свойство уже загружено, то повторно грузить его не будем
				if (xobj.HasLoadedProp(sPropName))
					values = (Guid[])xobj.GetLoadedPropValue(sPropName);
				else
					values = loadArrayProp(con, xobj, sPropName);
				// если свойство не последнее..
				if (nIndex < aPathParts.Length - 1)
				{
					string sValueObjectType = ((XPropInfoObject)propInfo).ReferedType.Name;
					// ..пройдемся по объектам-значениям
					foreach(Guid valueOID in values)
					{
						preloadPropertyInternal(con, Get(con, sValueObjectType , valueOID), aPathParts, nIndex+1, propLoadStrategy);
					}
				}
			}
			else if (propInfo.VarType == XPropType.vt_bin || propInfo.VarType == XPropType.vt_text)
			{
				// LOB - свойство. Его можно прогружать, но в цепочке свойств оно должно быть последним, т.к. св-во не содержит объектов
				if (nIndex != aPathParts.Length - 1)
					throw new ArgumentException("LOB-свойство " + sPropName + " в цепочке прогружаемых свойств не последнее");
				loadLOBProp(con, xobj, sPropName);
			}
			else
			{
				// любое другое скалярное свойство - онo должно быть последним в цепочке
				if (nIndex != aPathParts.Length - 1)
					throw new ArgumentException("Необъектное свойство " + sPropName + " в цепочке прогружаемых свойств не последнее");
				// будем грузить, только если его нет
				if (!xobj.HasLoadedProp(sPropName))
					loadScalarNonLOBProp(con, xobj, sPropName);
			}
		}

		/// <summary>
		/// Загружает массивное объектное свойство в объекте
		/// Для этого формирует WHERE условие в зависимости от емкости свойства и вызывает doLoadArrayProp
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">Объект владелей-свойства</param>
		/// <param name="sPropName">Наименование свойства</param>
		/// <returns>Экземпляр DomainObjectDataArrayPropHandle</returns>
		private Guid[] loadArrayProp(XStorageConnection con, DomainObjectData xobj, string sPropName)
		{
			XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
			if (propInfo.VarType != XPropType.vt_object)
				throw new InvalidOperationException("Метод должен вызываться для объектных массивных свойств");
			XPropInfoObject propInfoObj = (XPropInfoObject)propInfo;
			string sLinkOrder;						// Порядок выборки элементов линка
			Guid[] values;
			switch(propInfoObj.Capacity)
			{
				case XPropCapacity.Scalar:
					throw new ArgumentException("Метод должен вызываться для массивных свойств");
				case XPropCapacity.Link:
				case XPropCapacity.LinkScalar:
					// Получаем имя свойства, задающего порядок в связи
					XPropInfoObjectLink xpropLink = (XPropInfoObjectLink)propInfoObj;
					sLinkOrder = String.Empty;
					if (xpropLink.OrderByProp != null)
						sLinkOrder = " ORDER BY o." + con.ArrangeSqlName(xpropLink.OrderByProp.Name);
					// Загружаем подобъекты
					values = doLoadArrayProp(con, propInfoObj,
						// дописываем в SELECT фразу 
						// WHERE o.{built-on-свойство}='{гуид_базового_объекта}' [ORDER BY o.{свойство_порядка_связи}]
						String.Format(" WHERE o.{0}={1}{2}", 
							con.ArrangeSqlName( xpropLink.ReverseProp.Name ),	// 0
							con.GetParameterName("ObjectID"),					// 1
							sLinkOrder											// 2
						), xobj );
					break;
				case XPropCapacity.Array:
					// Загружаем подобъекты
					values = doLoadArrayProp(con, propInfoObj,
						// дописываем в SELECT фразу:
						// , схема.тип_массив a WHERE o.ObjectID=a.Value AND a.ObjectID='гуид базового объекта'
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
					// Загружаем подобъекты
					values = doLoadArrayProp(con, propInfoObj,
						// дописываем в SELECT фразу: 
						// , схема.тип_коллекция a WHERE o.ObjectID=a.Value AND a.ObjectID='гуид базового объекта'
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
					Debug.Assert(xpropRev != null, "Обратное свойство для array-membership/collection-membership не найдено");
					// Загружаем подобъекты
					values = doLoadArrayProp(con, propInfoObj,
						// дописываем в SELECT фразу:
						// , схема владельца коллекции (или массива).тип владельца коллекции (или массива)_коллекция a WHERE o.ObjectID=a.ObjectID AND a.Value='гуид базового объекта'
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
		/// Выполняет SQL-запрос на получения объектов-значений свойства, считывает данные объектов-значений, 
		/// добавляет отсутствующие объекты в контекст, а уже присутствующие перезаписывает.
		/// Инициализирует свойство массивом идентификаторов, который и возвращает
		/// </summary>
		/// <param name="con"></param>
		/// <param name="propInfo">Свойство</param>
		/// <param name="sSelectSuffix">Окончание SQL запроса</param>
		/// <param name="xobj">Объект-владелец свойства</param>
		private Guid[] doLoadArrayProp(XStorageConnection con, XPropInfoObject propInfo, string sSelectSuffix, DomainObjectData xobj)
		{
			string		sSQL;								// текст оператора SELECT
			XTypeInfo	xtypeRef = propInfo.ReferedType;	// описание типа-значения свойства
			ArrayList	aValues = new ArrayList();			// коллекция для формирования значения свойства - массива гуидов

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
						// создадим заглушку объекта-значения
						// (без дефолтных значений - последний параметр false)
						Guid ObjectID = dataReader.GetGuid(0);
						// получим экземпляр объекта значения в контексте
						DomainObjectData xobjValue = Find(xtypeRef.Name, ObjectID);
						if (xobjValue == null)
							xobjValue = GetLoadedStub(xtypeRef.Name, ObjectID);
						// и зачитаем из dateReader'а значения свойств (если объект уже был, то значения загруженных свойств перезатрутся)
						fillObjectPropertiesFromDataReader(dataReader, xobjValue);
						// добавим объект в свойство
						aValues.Add(ObjectID);
					}
				}
				// ловим ошибки выполнения запроса. Обычно такое может быть, если метаданные не соответствуют структуре БД
				catch(XDbException ex)
				{
					// Примечание XObjectNotFoundException не порожден от XDbException, поэтому здесь мы его не поймаем
					throw new XDbException("Ошибка при загрузке объекта " + xobj.ToString() + ": " + ex.Message, ex);
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
		/// Метод загрузки значения заданного LOB-свойства
		/// </summary>
		/// <param name="con"></param>
		/// <param name="xobj">объект-владелец свойства</param>
		/// <param name="sPropName">Наименование загружаемого LOB-свойства</param>
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
				throw new ArgumentException("Свойство " + sPropName +  " неподдерживаемого типа: " + propInfo.VarType);

			xobj.SetLoadedPropValue(sPropName, vData);
		}

		/// <summary>
		/// Загружает значение скалярного не-LOB свойства (в т.ч. объектного скалярного).
		/// Наличие загруженного значения не проверяет, всегда выполняет select-запрос и перезаписывает (если есть) существующее значение
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
						throw new ArgumentException("Неизвестное свойство: " + sPropName);
					if (!(propInfo is IXPropInfoScalar))
						throw new ArgumentException("Для загрузки задано нескалярное свойство: " + sPropName );
					if (propInfo.VarType == XPropType.vt_bin || propInfo.VarType == XPropType.vt_text)
						throw new ArgumentException("Для загрузки задано LOB-свойство: " + sPropName);
					vValue = readPropValueFromDB(reader, propInfo.VarType, 0);
					xobj.SetLoadedPropValue(sPropName, vValue );
				}
				else
				{
					// если объект не найден - генерируем исключение
					throw new XObjectNotFoundException( xobj.ObjectType, xobj.ObjectID );
				}
			}
			// ловим ошибки выполнения запроса. Обычно такое может быть, если метаданные не соответствуют структуре БД
			catch(XDbException ex)
			{
				// Примечание XObjectNotFoundException не порожден от XDbException, поэтому здесь мы его не поймаем
				throw new XDbException("Ошибка при загрузке объекта " + xobj.ToString() + ": " + ex.Message);
			}
			finally
			{
				if (reader != null)
					reader.Close();
			}
			return vValue;
		}

		/// <summary>
		/// Удаляет новые данные всех объектов
		/// </summary>
		public void RejectNewData()
		{
			foreach(DomainObjectData xobj in m_objects.Values)
				xobj.RejectNewData();
		}

	    /// <summary>
		/// Возвращает список объектов, подлежащих сохранения/удалению, заданного типа
		/// TODO: переделать на generic
		/// </summary>
		/// <param name="sObjectType">Тип требуемых объектов</param>
		/// <param name="bOnlyToSave">Признак: только объекты для сохранения, если false, то все модифицированные включая удаленные</param>
		/// <returns>Если объектов заданного типа нет в контексте, то ArrayList - пустой</returns>
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
		/// Возвращает список объектов, подлежащих сохранения/удалению, заданных типов
		/// TODO: переделать на generic
		/// </summary>
		/// <param name="aObjectTypes">Типы требуемых объектов</param>
		/// <param name="bOnlyToSave">Признак: только объекты для сохранения, если false, то все модифицированные включая удаленные</param>
		/// <returns>Если объектов заданного типа нет в контексте, то ArrayList - пустой</returns>
		public ArrayList GetModifiedObjectsByType(string[] aObjectTypes, bool bOnlyToSave)
		{
			if (aObjectTypes == null)
				throw new ArgumentNullException("aObjectTypes");
			if (aObjectTypes.Length == 0)
				throw new ArgumentException("Массив наименований типов требуемых объектов пустой");
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

		/// <summary>Enumerator для перебора объектов текущего множества, содержащих данные для обновления, а также удаляемые объекты
		/// Возвращает 
		/// </summary>
		/// <returns></returns>
		public IEnumerator GetModifiedObjectsEnumerator(bool bOnlyToSave)
		{
			return new DomainObjectDataSetEnumerator(this, bOnlyToSave);
		}

		/// <summary>
		/// Enumerator модифицированных объектов
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
