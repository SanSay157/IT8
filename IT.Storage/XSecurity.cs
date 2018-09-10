//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Security.Principal;
using Croc.IncidentTracker.Storage;

namespace Croc.XmlFramework.Data.Security
{
	/// <summary>
	/// Роль пользователя.
	/// </summary>
	public class XRole
	{
		public string Name;
		public string Description;
		public XRole(string sName): this(sName, null) 
		{}
		public XRole(string sName, string sDescription)
		{
			if (sName == null)
				throw new ArgumentNullException("sName");
			if (sName.Length == 0)
				throw new ArgumentException("sName");
			Name = sName;
			Description = sDescription;
		}

		public override bool Equals(object obj)
		{
			if (!(obj is XRole))
				return false;
			return Name == ((XRole)obj).Name;
		}
		public override int GetHashCode()
		{
			return Name.GetHashCode();
		}

	}

	/// <summary>
	/// Привилегия пользователя.
	/// </summary>
	public class XPrivilege
	{
		public string Name;
		public string Description;
		public XPrivilege(string sName): this(sName, null) 
		{}
		public XPrivilege(string sName, string sDescription)
		{
			if (sName == null)
				throw new ArgumentNullException("sName");
			if (sName.Length == 0)
				throw new ArgumentException("sName");
			Name = sName;
			Description = sDescription;
		}

		public override bool Equals(object obj)
		{
			if (!(obj is XPrivilege))
				return false;
			return Name == ((XPrivilege)obj).Name;
		}
		public override int GetHashCode()
		{
			return Name.GetHashCode();
		}

	}

	/// <summary>
	/// Множество привилегий. Хранит объекты XPrivilege. Привилегии идентифицируются по наименованию
	/// </summary>
	public class XPrivilegeSet: IEnumerable
	{
		protected IDictionary m_privileges = new HybridDictionary(true);
		private static XPrivilegeSet m_EmptySet;

		public void Add(XPrivilege privil)
		{
			m_privileges.Add(privil.Name, privil);
		}
		public bool Contains(string sName)
		{
			return m_privileges.Contains(sName);
		}

		public bool ContainsAll(XPrivilegeSet right_set)
		{
			foreach(XPrivilege priv in right_set)
				if (!Contains(priv.Name))
					return false;
			return true;
		}

		public bool ContainsAny(XPrivilegeSet right_set)
		{
			if (right_set.Count == 0)
				return true;
			foreach(XPrivilege priv in right_set)
				if (Contains(priv.Name))
					return true;
			return false;
		}

		public XPrivilege Get(string sName)
		{
			return (XPrivilege)m_privileges[sName];
		}
		public void Remove(string sName)
		{
			m_privileges.Remove(sName);
		}
		public XPrivilegeSet Union(XPrivilegeSet right_set)
		{
			XPrivilegeSet new_set = Clone();
			foreach(XPrivilege priv in right_set)
				if (!new_set.Contains(priv.Name))
					new_set.Add(priv);
			return new_set;
		}

		public XPrivilegeSet Intersect(XPrivilegeSet right_set)
		{
			XPrivilegeSet new_set = new XPrivilegeSet();
			foreach(XPrivilege priv in right_set)
				if (Contains(priv.Name))
					new_set.Add(priv);
			return new_set;
		}					  

		public XPrivilegeSet Subtract(XPrivilegeSet right_set)
		{
			XPrivilegeSet new_set = new XPrivilegeSet();
			foreach(XPrivilege priv in right_set)
				if (!Contains(priv.Name))
					new_set.Add(priv);
			return new_set;
		}

		public XPrivilegeSet Clone()
		{
			XPrivilegeSet new_set = new XPrivilegeSet();
			foreach(XPrivilege priv in m_privileges.Values)
				new_set.Add(priv);
			return new_set;
		}

		public int Count
		{
			get { return m_privileges.Count; }
		}

		public static XPrivilegeSet Empty
		{
			get
			{
				if (m_EmptySet == null)
					m_EmptySet = new XPrivilegeSet();
				return m_EmptySet;
			}
		}
		public static XPrivilegeSet Create(XPrivilege[] privils)
		{
			XPrivilegeSet set = new XPrivilegeSet();
			foreach(XPrivilege priv in privils)
				set.Add(priv);
			return set;
		}
		#region IEnumerable Members

		public IEnumerator GetEnumerator()
		{
			return m_privileges.Values.GetEnumerator();
		}

		#endregion
	}


	public class XInvalidSecurityRulesException: Exception
	{
		public XInvalidSecurityRulesException(string sMessage): base(sMessage)
		{}
	}

	public class XSecurityProviderDummy: IXSecurityProvider
	{
		private static XUser userDummy = new XUser("Dummy", null, null);
		#region IXSecurityProvider Members

		public XUser CreateUser(string sUserName)
		{
			return userDummy;
		}

		public XUser CreateAnonymousUser()
		{
			return userDummy;
		}

		/// <summary>
		/// Обновляет описание пользователя, которое было сброшено
		/// </summary>
		/// <param name="user">Экземпляр XUser или производный, у которого свойство IsFlushed=true</param>
		public void UpdateUser(XUser user)
		{}

		public string GetUserNameByPrincipal(IPrincipal originalPrincipal)
		{
			return "Dummy";
		}

		public bool HasSaveObjectPrivilege(XUser user, DomainObjectData xobj, out Exception ex)
		{
			ex = null;
			return true;
		}

		public XObjectRights GetObjectRights(XUser user, DomainObjectData xobj)
		{
			return XObjectRights.FullRights;
		}

		public XNewObjectRights GetRightsOnNewObject(XUser user, DomainObjectData xobj)
		{
			return XNewObjectRights.FullRights;
		}

		public void TrackModifiedObjects(DomainObjectDataSet dataSet)
		{}

		public string[] GetAffectedUserNames(DomainObjectDataSet dataSet, ICollection users)
		{
			return null;
		}

		#endregion
	}

	public class XUserNotAssignedException: Exception
	{}
	
	/// <summary>
	/// Служебное перечисление для описателей прав (XObjectRights и XNewObjectRights)
	/// Описывает факт наличия одного права: есть, нет, есть частично
	/// </summary>
	internal enum ObjectActionMode
	{
		/// <summary>
		/// Права нет
		/// </summary>
		None,
		/// <summary>
		/// Есть полное право
		/// </summary>
		Full,
		/// <summary>
		/// Право есть частично
		/// </summary>
		Partial
	}

	/// <summary>
	/// Базовый класс описания прав на объект
	/// </summary>
	public abstract class XObjectRightsBase
	{
		/// <summary>
		/// Словарь наименований свойство только для чтения
		/// </summary>
		protected HybridDictionary m_readOnlyProps;

		/// <summary>
		/// Конструктор
		/// </summary>
		protected XObjectRightsBase()
		{
			m_readOnlyProps = new HybridDictionary(true);
		}

		/// <summary>
		/// Возвращает новый экземпляр коллекции с наименованиями read-only свойств
		/// </summary>
		/// <returns></returns>
		public ICollection GetReadOnlyPropNames()
		{
			return new ArrayList(m_readOnlyProps.Keys);
		}

		/// <summary>
		/// Возвращает признак является ли заданное свойство read-only.
		/// Внимание: проверяется только наличие в списке read-only свойства. 
		/// Если этот список пуст, но AllowParticalOrFullChange=false (т.е. модификация объекта запрещена), то все равно вернется false.
		/// </summary>
		/// <param name="sPropName"></param>
		/// <returns></returns>
		public bool HasReadOnlyProp(string sPropName)
		{
			return m_readOnlyProps.Contains(sPropName);
		}

		/// <summary>
		/// Возвращает признак наличия свойств только для чтения
		/// </summary>
		public bool HasReadOnlyProps
		{
			get { return m_readOnlyProps.Count > 0; }
		}
	}

	/// <summary>
	/// Описание прав на объект
	/// </summary>
	public sealed class XObjectRights: XObjectRightsBase
	{
		private static XObjectRights m_FullRights;
		private static XObjectRights m_ReadOnlyRights;
		private static XObjectRights m_DeleteOrReadRights;
		private static XObjectRights m_noAccessRights;
		public static XObjectRights FullRights
		{
			get 
			{
				if (m_FullRights == null)
				{
					m_FullRights = new XObjectRights();
					m_FullRights.setRights(true, true);
				}
				return m_FullRights;
			}
		}
		public static XObjectRights ReadOnlyRights
		{
			get
			{
				if (m_ReadOnlyRights == null)
				{
					m_ReadOnlyRights = new XObjectRights();
				}
				return m_ReadOnlyRights;
			}
		}
		public static XObjectRights DeleteOrReadRights
		{
			get
			{
				if (m_DeleteOrReadRights == null)
				{
					m_DeleteOrReadRights = new XObjectRights();
					m_DeleteOrReadRights.setRights(true, false);
				}
				return m_DeleteOrReadRights;
			}
		}
		public static XObjectRights NoAccess
		{
			get
			{
				if (m_noAccessRights == null)
				{
					m_noAccessRights  = new XObjectRights();
					m_noAccessRights.m_readMode = ObjectActionMode.None;
				}
				return m_noAccessRights;
			}
		}
		private HybridDictionary m_hiddenProps;
		private ObjectActionMode m_changeMode;
		private ObjectActionMode m_readMode;
		private bool m_bAllowDelete;

		public XObjectRights()
		{
			m_hiddenProps	= new HybridDictionary(true);
			m_changeMode	= ObjectActionMode.None;
			m_readMode		= ObjectActionMode.Full;
		}
		public XObjectRights(bool bAllowDelete, bool bAllowChange): this()
		{
			setRights(bAllowDelete, bAllowChange);
		}
		public XObjectRights(bool bAllowDelete, ICollection readOnlyProps): this()
		{
			setRights(bAllowDelete, readOnlyProps);
		}
		public XObjectRights(bool bAllowDelete, ICollection readOnlyProps, ICollection hiddenProps): this()
		{
			setRights(bAllowDelete, readOnlyProps, hiddenProps);
		}

		public ICollection GetHiddenPropNames()
		{
			return new ArrayList(m_hiddenProps.Keys);
		}
		public bool AllowDelete
		{
			get { return m_bAllowDelete; }
			set { m_bAllowDelete = value; }
		}
		public bool AllowFullChange
		{
			get { return m_changeMode == ObjectActionMode.Full; }
		}
		public bool AllowParticalOrFullChange
		{
			get { return m_changeMode != ObjectActionMode.None; }
		}
		public bool AllowFullRead
		{
			get { return m_readMode == ObjectActionMode.Full; }
		}
		public bool AllowParticalOrFullRead
		{
			get { return m_readMode != ObjectActionMode.None; }
		}
		public bool HasHiddenProps
		{
			get { return m_hiddenProps.Count > 0; }
		}
		private void setRights(bool bAllowDelete, bool bAllowChange)
		{
			m_bAllowDelete = bAllowDelete;
			if (bAllowChange)
				m_changeMode = ObjectActionMode.Full;
			else
				m_changeMode = ObjectActionMode.None;
		}
		private void setRights(bool bAllowDelete, ICollection readOnlyProps)
		{
			m_bAllowDelete = bAllowDelete;
			setReadOnlyProps(readOnlyProps);
		}
		private void setRights(bool bAllowDelete, ICollection readOnlyProps, ICollection hiddenProps)
		{
			setRights(bAllowDelete, readOnlyProps);
			setHiddenProps(hiddenProps);
		}
		private void setReadOnlyProps(ICollection readOnlyProps)
		{
			if (readOnlyProps == null || readOnlyProps.Count == 0)
				m_changeMode = ObjectActionMode.Full;
			else
			{
				m_changeMode = ObjectActionMode.Partial;
				m_readOnlyProps.Clear();
				foreach(string sProp in readOnlyProps)
					m_readOnlyProps.Add(sProp, null);
			}
		}

		private void setHiddenProps(ICollection hiddenProps)
		{
			if (hiddenProps == null || hiddenProps.Count == 0)
				m_readMode = ObjectActionMode.Full;
			else
			{
				m_readMode = ObjectActionMode.Partial;
				m_hiddenProps.Clear();
				foreach(string sProp in hiddenProps)
					m_hiddenProps.Add(sProp, null );
			}
		}
		
		/// <summary>
		/// Возвращает признак наличия прав на изменение заданного свойства
		/// </summary>
		/// <param name="sPropName">Наименование свойства</param>
		/// <returns>Можно ли изменять свойство</returns>
		public bool HasPropChangeRight(string sPropName)
		{
			if (AllowFullChange)
				return true;
			if (AllowParticalOrFullChange && !m_readOnlyProps.Contains(sPropName))
				return true;
			return false;
		}
	}

	/// <summary>
	/// Конструктор объекта XObjectRights
	/// </summary>
	public class XObjectRightsBuilder
	{
		private bool m_bAllowDelete;
		private bool m_bAllowChangeDeleteRight;
		private bool m_bChangeRightRestricted;
		private ObjectActionMode m_changeModeIncremental;
		private ObjectActionMode m_changeModeRestricted;
		protected HybridDictionary m_readOnlyProps;
		protected HybridDictionary m_readOnlyPropsFinal;

		public XObjectRightsBuilder()
		{
			m_bAllowChangeDeleteRight = true;
			m_bChangeRightRestricted = false;
			m_changeModeIncremental = ObjectActionMode.None;
			m_changeModeRestricted = ObjectActionMode.None;
		}

		#region Права на удаление
		public void SetDeleteRights(bool bAllow)
		{
			if (m_bAllowChangeDeleteRight)
				m_bAllowDelete = bAllow;
		}
		public void SetDenyDelete()
		{
			SetDeleteRights(false);
		}
		public void SetAllowDelete()
		{
			SetDeleteRights(true);
		}

		public void SetDeleteRightsFinal(bool bAllow)
		{
			if (m_bAllowChangeDeleteRight)
			{
				m_bAllowDelete = bAllow;
				m_bAllowChangeDeleteRight = false;
			}
		}
		public void SetDenyDeleteFinal()
		{
			SetDeleteRightsFinal(false);
		}
		public void SetAllowDeleteFinal()
		{
			SetDeleteRightsFinal(true);
		}
		#endregion

		public void SetAllowFullChange()
		{
			m_changeModeIncremental = ObjectActionMode.Full;
			clearPropCollection(ref m_readOnlyProps);
		}

		public void SetAllowFullChangeFinal()
		{
			m_changeModeRestricted = ObjectActionMode.Full;
			m_bChangeRightRestricted = true;
		}

		public void SetDenyChange()
		{
			m_changeModeIncremental = ObjectActionMode.None;
		}

		public void SetDenyChangeFinal()
		{
			m_changeModeRestricted = ObjectActionMode.None;
			m_bChangeRightRestricted = true;
		}

		public void SetAllowChangeExcept(ICollection propNames)
		{
			if (propNames == null)
				throw new ArgumentNullException("propNames");
			// SetReadOnlyProps
			if (propNames.Count == 0)
				m_changeModeIncremental = ObjectActionMode.Full;
			else
			{
				m_changeModeIncremental = ObjectActionMode.Partial;
				clearPropCollection(ref m_readOnlyProps);
				foreach(string sProp in propNames)
					m_readOnlyProps.Add(sProp, null);
			}
		}

		/// <summary>
		/// Устанавливает "неизменяемый" запрет на изменение заданных свойств
		/// </summary>
		/// <param name="restrictedProps">коллекция наименования свойств</param>
		public void SetReadOnlyPropsFinal(ICollection restrictedProps)
		{
			if (restrictedProps == null)
				throw new ArgumentNullException("restrictedProps");
			clearPropCollection(ref m_readOnlyPropsFinal);
			foreach(string sPropName in restrictedProps)
				m_readOnlyPropsFinal.Add(sPropName, null);
			m_changeModeRestricted = ObjectActionMode.Partial;
			m_bChangeRightRestricted = true;
		}

		/// <summary>
		/// Добавляет свойств в "неизменяемый" список read-only свойств
		/// </summary>
		/// <param name="sPropName"></param>
		public void AddReadOnlyPropFinal(string sPropName)
		{
			if (sPropName == null)
				throw new ArgumentNullException("sPropName");
			clearPropCollection(ref m_readOnlyPropsFinal);
			m_readOnlyPropsFinal.Add(sPropName, null);
			m_changeModeRestricted = ObjectActionMode.Partial;
			m_bChangeRightRestricted = true;
		}

		/// <summary>
		/// Устанавливает доступ на изменение заданных свойств.
		/// Если изменение объекта было запрещено, то включает разрешение частичного изменение и 
		/// объявляет все свойствава кроме заданных как read-only.
		/// </summary>
		/// <param name="allPropsInfo">Описание всех свойств типа</param>
		/// <param name="accessableProps">Коллекция наименований свойств, доступ к которым должен быть открыт</param>
		public void SetAllowChangeProps(XPropInfoBase[] allPropsInfo, ICollection accessableProps)
		{
			if (m_changeModeIncremental == ObjectActionMode.Full)
				return;
			if (m_changeModeIncremental == ObjectActionMode.Partial)
			{
				Debug.Assert(m_readOnlyProps != null);
				// удалим все свойства из accessableProps из списка read-only, если они там были
				foreach(string sProp in accessableProps)
					if (m_readOnlyProps.Contains(sProp))
						m_readOnlyProps.Remove(sProp);
			}
			else // if (m_ChangeMode = ObjectActionMode.None)
			{
				// изменение объекта было запрещено - установим доступ частичного изменения 
				// (все свойства кроме accessableProps объявим read-only)
				m_changeModeIncremental = ObjectActionMode.Partial;
				bool bReadOnly;
				if (m_readOnlyProps == null)
					m_readOnlyProps = new HybridDictionary();
				foreach(XPropInfoBase propInfo in allPropsInfo)
				{
					bReadOnly = true;
					foreach(string sProp in accessableProps)
						if (sProp == propInfo.Name)
						{
							bReadOnly = false;
							break;
						}
					if (bReadOnly)
						m_readOnlyProps.Add(propInfo.Name, null);
				}
			}
		}

		private void clearPropCollection(ref HybridDictionary propCol)
		{
			if (propCol == null)
				propCol = new HybridDictionary();
			else
				propCol.Clear();
		}

		public void SetAllowFullControl()
		{
			SetAllowFullChange();
			SetAllowDelete();
		}
		public XObjectRights GetObjectRights()
		{
			HybridDictionary readonlyProps = null;
			if (m_bChangeRightRestricted)
			{
				if (m_changeModeRestricted == ObjectActionMode.None)
					return new XObjectRights(m_bAllowDelete, false);
				else if (m_changeModeRestricted == ObjectActionMode.Full)
					return new XObjectRights(m_bAllowDelete, true);
				else	// if (m_changeModeRestricted == ObjectActionMode.Partial)
				{
					Debug.Assert(m_changeModeRestricted == ObjectActionMode.Partial);
					Debug.Assert(m_readOnlyPropsFinal != null);
					readonlyProps = new HybridDictionary();
					foreach(string sPropName in m_readOnlyPropsFinal.Keys)
						readonlyProps[sPropName] = null;
				}
			}
			if (m_changeModeIncremental == ObjectActionMode.None)
				return new XObjectRights(m_bAllowDelete, false);
			else if (m_changeModeIncremental == ObjectActionMode.Full && readonlyProps == null)
				return new XObjectRights(m_bAllowDelete, true);
			else	// if (m_changeModeIncremental == ObjectActionMode.Partial)
			{
				Debug.Assert(m_readOnlyProps != null);
				if (readonlyProps == null)
					readonlyProps = new HybridDictionary();
				foreach(string sPropName in m_readOnlyProps.Keys)
					readonlyProps[sPropName] = null;
			}
			return new XObjectRights(m_bAllowDelete, readonlyProps.Keys);
		}
	}

	/// <summary>
	/// Описание права на создание объекта
	/// </summary>
	public sealed class XNewObjectRights: XObjectRightsBase
	{
		private static XNewObjectRights m_FullRights;
		private static XNewObjectRights m_EmptyRights;
		public static XNewObjectRights FullRights
		{
			get 
			{
				if (m_FullRights == null)
					m_FullRights = new XNewObjectRights(true);
				return m_FullRights;
			}
		}

		public static XNewObjectRights EmptyRights
		{
			get
			{
				if (m_EmptyRights == null)
					m_EmptyRights = new XNewObjectRights(false);
				return m_EmptyRights;
			}
		}


		private bool m_bAllowCreate;

		public XNewObjectRights(bool bAllowCreate)
		{
			m_bAllowCreate = bAllowCreate;
		}

		public XNewObjectRights(bool bAllowCreate, ICollection readOnlyProps)
		{
			m_bAllowCreate = bAllowCreate;
			setReadOnlyProps(readOnlyProps);
		}
		
		public bool AllowCreate
		{
			get { return m_bAllowCreate; }
			set { m_bAllowCreate = value; }
		}

		private void setReadOnlyProps(ICollection readOnlyProps)
		{
			m_readOnlyProps.Clear();
			foreach(string sProp in readOnlyProps)
				m_readOnlyProps.Add(sProp, null);
		}

		public bool IsUnrestricted
		{
			get
			{
				return m_bAllowCreate && !HasReadOnlyProps;
			}
		}
	}
}