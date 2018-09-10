using System;
using System.Security.Principal;

namespace Croc.XmlFramework.Data.Security
{
	/// <summary>
	/// ������������ ����������
	/// </summary>
	public class XUser: IPrincipal, IIdentity
	{
		#region Fields
		/// <summary>
		/// ���������� ������������ ������������ ����������
		/// </summary>
		protected string m_sName;
		/// <summary>
		/// ������� �������������������� ������������. 
		/// ��� �������� ������� ��������������� � true
		/// </summary>
		protected bool m_bIsAuthenticated;
		/// <summary>
		/// ��� ��������������/
		/// ���������������  ��� m_OriginalPrincipal.Identity.AuthenticationType ��� ��������� �������� OriginalPrincipal
		/// </summary>
		protected string m_sAuthenticationType;
		/// <summary>
		/// �������� IPrincipal, ���������������� ������������
		/// </summary>
		protected IPrincipal m_OriginalPrincipal;
		/// <summary>
		/// ������� ���������� ������������
		/// </summary>
		protected bool m_bIsAnonymus;
		/// <summary>
		/// ������� "���������������" ������������
		/// </summary>
		protected bool m_bIsUnrestricted;
		/// <summary>
		/// ������ ����� ������������
		/// </summary>
		protected XRole[] m_roles;
		/// <summary>
		/// ��������� ���������� ������������
		/// </summary>
		protected XPrivilegeSet m_privileges;
		/// <summary>
		/// ���� ������ �������� ������������
		/// </summary>
		protected bool m_bFlushed;
		/// <summary>
		/// ������� ���������� ������� ������������ � �������
		/// </summary>
		protected bool m_bAccessPermitted;
		#endregion
		
		/// <summary>
		/// �����������
		/// </summary>
		/// <param name="sName">���������� ������������ ������������ ����������</param>
		/// <param name="roles">������ ����� ������������</param>
		/// <param name="privilege_set"> ��������� ���������� ������������</param>
		public XUser(string sName, XRole[] roles, XPrivilegeSet privilege_set)
		{
			m_sName = sName;
			m_bIsAuthenticated = true;
			// �������������� ������ �����
			SetRoles(roles);
			// �������������� ������ ����������
			SetPrivileges(privilege_set);
		}

		/// <summary>
		/// ������������� ���� ������������
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
		/// ������������� ��������� ���������� ������������
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
		/// ���������� ��������� ����� ������������
		/// </summary>
		/// <returns></returns>
		public XRole[] GetRoles()
		{
			XRole[] roles = new XRole[m_roles.Length];
			Array.Copy(m_roles, roles, m_roles.Length);
			return roles;
		}
		
		/// <summary>
		/// ���������� ��������� ���������� ������������
		/// </summary>
		public XPrivilegeSet PrivilegeSet
		{
			get { return m_privileges; }
		}
		
		/// <summary>
		/// ��������� ���� ������� ���������� � �������� �������������
		/// </summary>
		/// <param name="sPrivName">������������ ����������</param>
		/// <returns>true - ���������� ����, ����� false</returns>
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
		/// �������� IPrincipal, ���������������� ������������
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
		/// ������� ���������� ������������
		/// </summary>
		public bool IsAnonymus
		{
			get { return m_bIsAnonymus; }
			set { m_bIsAnonymus = value; }
		}

		/// <summary>
		/// ������� "���������������" ������������
		/// </summary>
		public bool IsUnrestricted
		{
			get { return m_bIsUnrestricted; }
			set { m_bIsUnrestricted = value; }
		}

		/// <summary>
		/// ������� ���������� ������� ������������ � �������
		/// </summary>
		public bool AccessPermitted
		{
			get { return m_bAccessPermitted; }
			set { m_bAccessPermitted = value; }
		}

		/// <summary>
		/// ������������� ���� ������ �������� ������������
		/// </summary>
		public void SetFlushed(bool bFlushed)
		{
			m_bFlushed = bFlushed;
		}

		/// <summary>
		/// ������� ������������ �������� ������������
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