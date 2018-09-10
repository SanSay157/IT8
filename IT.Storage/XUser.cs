using System;
using System.Security.Principal;

namespace Croc.XmlFramework.Data.Security
{
	/// <summary>
	/// Пользователь приложения
	/// </summary>
	public class XUser: IPrincipal, IIdentity
	{
		#region Fields
		/// <summary>
		/// Уникальное наименование пользователя приложения
		/// </summary>
		protected string m_sName;
		/// <summary>
		/// Признак аутентифицированного пользователя. 
		/// При создании объекта устанавливается в true
		/// </summary>
		protected bool m_bIsAuthenticated;
		/// <summary>
		/// Тип аутентификации/
		/// Устанавливается  как m_OriginalPrincipal.Identity.AuthenticationType при изменении свойства OriginalPrincipal
		/// </summary>
		protected string m_sAuthenticationType;
		/// <summary>
		/// Исходный IPrincipal, идентифицирующий пользователя
		/// </summary>
		protected IPrincipal m_OriginalPrincipal;
		/// <summary>
		/// Признак анонимного пользователя
		/// </summary>
		protected bool m_bIsAnonymus;
		/// <summary>
		/// Признак "неограниченного" пользователя
		/// </summary>
		protected bool m_bIsUnrestricted;
		/// <summary>
		/// Массив ролей пользователя
		/// </summary>
		protected XRole[] m_roles;
		/// <summary>
		/// Множество привилегий пользователя
		/// </summary>
		protected XPrivilegeSet m_privileges;
		/// <summary>
		/// Флаг сброса описания пользователя
		/// </summary>
		protected bool m_bFlushed;
		/// <summary>
		/// Признак разрешения доступа пользователя в систему
		/// </summary>
		protected bool m_bAccessPermitted;
		#endregion
		
		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="sName">Уникальное наименование пользователя приложения</param>
		/// <param name="roles">Массив ролей пользователя</param>
		/// <param name="privilege_set"> Множество привилегий пользователя</param>
		public XUser(string sName, XRole[] roles, XPrivilegeSet privilege_set)
		{
			m_sName = sName;
			m_bIsAuthenticated = true;
			// инициализируем массив ролей
			SetRoles(roles);
			// инициализируем массив привилегий
			SetPrivileges(privilege_set);
		}

		/// <summary>
		/// Устанавливает роли пользователя
		/// </summary>
		/// <param name="roles"></param>
		public void SetRoles(XRole[] roles)
		{
			if (roles != null)
			{
				m_roles = new XRole[roles.Length];
				Array.Copy(roles, m_roles, roles.Length);
			}
			else
				m_roles = new XRole[0];
		}
		/// <summary>
		/// Устанавливает множество привилегий пользователя
		/// </summary>
		/// <param name="privilege_set"></param>
		public void SetPrivileges(XPrivilegeSet privilege_set)
		{
			if (privilege_set == null)
				m_privileges = XPrivilegeSet.Empty;
			else 
				m_privileges = privilege_set;
		}
		
		/// <summary>
		/// Возвращает множество ролей пользователя
		/// </summary>
		/// <returns></returns>
		public XRole[] GetRoles()
		{
			XRole[] roles = new XRole[m_roles.Length];
			Array.Copy(m_roles, roles, m_roles.Length);
			return roles;
		}
		
		/// <summary>
		/// Возвращает множество привилегий пользователя
		/// </summary>
		public XPrivilegeSet PrivilegeSet
		{
			get { return m_privileges; }
		}
		
		/// <summary>
		/// Вовзарает факт наличия привилегии с заданныи наименованием
		/// </summary>
		/// <param name="sPrivName">Наименование привилегии</param>
		/// <returns>true - привилегия есть, иначе false</returns>
		public bool HasPrivilege(string sPrivName)
		{
			if (m_bIsUnrestricted)
				return true;
			foreach(XPrivilege privilege in m_privileges)
				if (privilege.Name == sPrivName)
					return true;
			return false;
		}

		/// <summary>
		/// Исходный IPrincipal, идентифицирующий пользователя
		/// </summary>
		public IPrincipal OriginalPrincipal
		{
			get { return m_OriginalPrincipal; }
			set
			{
				m_OriginalPrincipal = value;
				if (m_OriginalPrincipal != null)
					m_sAuthenticationType = m_OriginalPrincipal.Identity.AuthenticationType;
			}
		}

		/// <summary>
		/// Признак анонимного пользователя
		/// </summary>
		public bool IsAnonymus
		{
			get { return m_bIsAnonymus; }
			set { m_bIsAnonymus = value; }
		}

		/// <summary>
		/// Признак "неограниченного" пользователя
		/// </summary>
		public bool IsUnrestricted
		{
			get { return m_bIsUnrestricted; }
			set { m_bIsUnrestricted = value; }
		}

		/// <summary>
		/// Признак разрешения доступа пользователя в систему
		/// </summary>
		public bool AccessPermitted
		{
			get { return m_bAccessPermitted; }
			set { m_bAccessPermitted = value; }
		}

		/// <summary>
		/// Устанавливает флаг сброса описания пользователя
		/// </summary>
		public void SetFlushed(bool bFlushed)
		{
			m_bFlushed = bFlushed;
		}

		/// <summary>
		/// Признак сброшенности описания пользователя
		/// </summary>
		public bool IsFlushed
		{
			get { return m_bFlushed; }
		}
		
		
		#region IPrincipal Members

		public IIdentity Identity
		{
			get { return this; }
		}

		public bool IsInRole(string sRoleName)
		{
			foreach(XRole role in m_roles)
				if (role.Name == sRoleName)
					return true;
			return false;
		}

		#endregion

		#region IIdentity Members

		public bool IsAuthenticated
		{
			get { return m_bIsAuthenticated; }
			set { m_bIsAuthenticated = value; }
		}

		public string Name
		{
			get { return m_sName; }
		}

		public string AuthenticationType
		{
			get { return m_sAuthenticationType; }
		}

		#endregion
	}
}