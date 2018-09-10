//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Security.Principal;
using System.Threading;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Public;
namespace Croc.XmlFramework.Data.Security
{
	/// <summary>
	/// ����������, ������� ���������� XSecurityManager, ���� ��������� ������������ ���������� IXSecurityProvider'a
	/// </summary>
	public class XSecurityProviderErrorImplementationException: Exception
	{
		public XSecurityProviderErrorImplementationException(): base()
		{}
		public XSecurityProviderErrorImplementationException(string sMessage): base(sMessage)
		{}
		public XSecurityProviderErrorImplementationException(string sMessage, Exception innerException): base(sMessage, innerException)
		{}
	}

	public class XSecurityManager
	{
		/// <summary>
		/// "���������" ������������ ������������, ����������� SecurityManager'�� ��� "��� ������������"
		/// </summary>
		public static string USERNAME_ALLUSERS = "Everyone";
		/// <summary>
		/// ������� ������������������� ������������� ���������� (���). 
		/// ���� - ������������ ������������, �������� - ��������� XUser ��� �����������
		/// </summary>
		protected IDictionary m_AuthenticatedUsers;
		/// <summary>
		/// ��������� ���������� ���������� �������. �� ��������� ������������ ���������, ������� ��������� ��� ����
		/// </summary>
		protected IXSecurityProvider m_SecurityProvider = new XSecurityProviderDummy();
		/// <summary>
		/// ���� ��� ����������� �������� ���������� ������������ 
		/// (���������� ������ ����, ���� ��������� ������������ ��������� �������������)
		/// </summary>
		protected XUser m_anonymusUser;

		#region Singleton pattern
		private static XSecurityManager m_Instance = new XSecurityManager();

		private XSecurityManager()
		{
			m_AuthenticatedUsers = new HybridDictionary(true);
		}

		/// <summary>
		/// ���������� ������������ ��������� XSecurityManager 
		/// </summary>
		public static XSecurityManager Instance
		{
			get { return m_Instance; }
		}
		#endregion
		
		/// <summary>
		/// ��������� ���������� ���������� �������
		/// </summary>
		public IXSecurityProvider SecurityProvider
		{
			get { return m_SecurityProvider; }
			set { m_SecurityProvider = value; }
		}


		/// <summary>
		/// ���������� �������� ������������ �� ��� ������������
		/// </summary>
		/// <param name="sUserName">������������ ������������ ����������</param>
		/// <remarks>
		/// ���� �������� ���� �������� (Flush), �� ��� ����� ������������ �� SecurityProvider'a
		/// </remarks> 
		/// <returns></returns>
		public XUser GetXUser(string sUserName)
		{
			XUser user = (XUser)m_AuthenticatedUsers[sUserName];
			if (user == null)
			{
				user = m_SecurityProvider.CreateUser(sUserName);
				Debug.Assert(user != null);
				if (user == null)
					throw new XSecurityProviderErrorImplementationException("SecurityProvider.CreateUser ������ null!");
				m_AuthenticatedUsers[sUserName] = user;
			}
			else if (user.IsFlushed)
			{
				m_SecurityProvider.UpdateUser(user);
				user.SetFlushed(false);
			}
			return user;
		}

		/// <summary>
		/// ���������� "��������" ������������ ���������� �� ��������� ���������� �������� ������
		/// </summary>
		/// <remarks>
		/// ���� �������� ���� �������� (Flush), �� ��� ����� ������������ �� SecurityProvider'a
		/// </remarks> 
		/// <returns></returns>
		public XUser GetCurrentUser()
		{
			XUser user;
			IPrincipal originalPrincipal = Thread.CurrentPrincipal;
			if (originalPrincipal == null)
			{
				user = getAnonymousUser();
				if (user == null)
					throw new XSecurityException("������ � ������� ��������������������� ������������� ��������");
                    
			
			}
			else
			{
				string sName = m_SecurityProvider.GetUserNameByPrincipal(originalPrincipal);
				if (sName == null)
					throw new XSecurityProviderErrorImplementationException("SecurityProvider.GetUserNameByPrincipal ������ null!");
				user = GetXUser(sName);
				Debug.Assert(user != null);
				user.OriginalPrincipal = originalPrincipal;
				//if (!user.AccessPermitted)
				//	throw new XSecurityException("������ ������������ " + sName + " � ������� ��������");
                    	
             }
			return user;
		}

		/// <summary>
		/// ���������� �������� ���������� ������������
		/// </summary>
		/// <returns></returns>
		private XUser getAnonymousUser()
		{
			if (m_anonymusUser == null)
				m_anonymusUser = m_SecurityProvider.CreateAnonymousUser();
			return m_anonymusUser;
		}

		/// <summary>
		/// ������� �������������� �������� ������������ � �������� �������������
		/// </summary>
		/// <param name="sUserName"></param>
		public void FlushUser(string sUserName)
		{
			XUser user = (XUser) m_AuthenticatedUsers[sUserName];
			if (user != null)
				user.SetFlushed(true);
		}

		/// <summary>
		/// ������� �������������� �������� ���� �������������
		/// </summary>
		public void FlushAllUsers()
		{
			foreach (XUser user in m_AuthenticatedUsers.Values)
			{
				user.SetFlushed(true);
			}
		}

		/// <summary>
		/// ���������� ������� �������� �������������, �������� ������� ���� ����������� � �������� ������ ���������� : 
		/// ���� - ������������ ������������ ����������, 
		/// �������� - ��������� ������ XUser ��� ����������
		/// </summary>
		public IDictionary Users
		{
			get { return m_AuthenticatedUsers; }
		}

		/// <summary>
		/// ���������� ������������ �������� ������������, �� �������� ������-�������� (XUser)
		/// ���������� null, ���� �������� Thread.CurrentPrincipal �� ����������������
		/// </summary>
		public string CurrentUserName
		{
			get
			{
				IPrincipal originalPrincipal = Thread.CurrentPrincipal;
				if (originalPrincipal == null)
					return null;
				else
					return m_SecurityProvider.GetUserNameByPrincipal(originalPrincipal);
			}
		}


		public void DemandChangeObjectPrivilege(DomainObjectData xobj)
		{
			XUser user = GetCurrentUser();
			if (user.IsUnrestricted)
				return;
			bool bAllow;
			try
			{
				bAllow = m_SecurityProvider.GetObjectRights(user, xobj).AllowParticalOrFullChange;
			}
			catch(Exception ex)
			{
				throw new ApplicationException("������ �� ����� �������� ���� �� ��������� �������: " + xobj.ObjectType + " [" + xobj.ObjectID + "]:\n" + ex.Message, ex);
			}
			if (!bAllow)
				throw new XSecurityException("������������ ����");
                
		}

		public void DemandDeleteObjectPrivilege(DomainObjectData xobj)
		{
			XUser user = GetCurrentUser();
			if (user.IsUnrestricted)
				return;
			bool bAllow;
			try
			{
				bAllow = m_SecurityProvider.GetObjectRights(user, xobj).AllowDelete;
			}
			catch(Exception ex)
			{
				throw new ApplicationException("������ �� ����� �������� ���� �� �������� �������: " + xobj.ObjectType + " [" + xobj.ObjectID + "]" + ex.Message, ex);
			}
			if (!bAllow)
				throw new XSecurityException("������������ ����");
               
		}

		public XObjectRights GetObjectRights(DomainObjectData xobj)
		{
			XUser user = GetCurrentUser();
            if (user == null || xobj==null)
            {
                throw new ApplicationException("������ � �������� �������� ����:\n");
            }
			if (user.IsUnrestricted)
				return XObjectRights.FullRights;
			try
			{
				XObjectRights rights = m_SecurityProvider.GetObjectRights(user, xobj);
				if (rights == null)
					throw new XSecurityProviderErrorImplementationException("����� GetObjectRights ���������� ������������ ������ null ��� �������: " + xobj.ToString());
				return rights;
			}
			catch(Exception ex)
			{
				throw new ApplicationException("������ � �������� �������� ����:\n" + ex.Message, ex);
			}
		}

		/// <summary>
		/// �������� �� ���������� ������� � ��, ������������ �� �������, � ������ ����������
		/// </summary>
		/// <param name="xobj">����������� ������</param>
		public bool HasSaveObjectPrivilege(DomainObjectData xobj)
		{
			XUser user = GetCurrentUser();
			if (user.IsUnrestricted)
				return true;
			try
			{
				Exception ex;
				return m_SecurityProvider.HasSaveObjectPrivilege(user, xobj, out ex);
			}
			catch(Exception ex)
			{
				throw new ApplicationException("������ � �������� �������� ����:\n" + ex.Message, ex);
			}
		}

		public void DemandSaveObjectPrivilege(DomainObjectData xobj)
		{
			XUser user = GetCurrentUser();
			if (user.IsUnrestricted)
				return;
			Exception exOut;
			bool bAllow;
			try
			{
				bAllow = m_SecurityProvider.HasSaveObjectPrivilege(user, xobj, out exOut);
			}
			catch(Exception ex)
			{
				throw new ApplicationException("������ �� ����� �������� ���� �� ���������� �������: " + xobj.ObjectType + " [" + xobj.ObjectID + "]:\n" + ex.Message, ex);
			}
			if (!bAllow)
			{
				if (exOut != null)
					throw new XSecurityException(exOut.Message);
                else
					throw new XSecurityException("������������ ����");
                    
			}
		}

		public XNewObjectRights GetRightsOnNewObject(DomainObjectData xobj)
		{
			XUser user = GetCurrentUser();
			if (user.IsUnrestricted)
				return XNewObjectRights.FullRights;
			try
			{
				XNewObjectRights rights = m_SecurityProvider.GetRightsOnNewObject(user, xobj);
				if (rights == null)
					throw new XSecurityProviderErrorImplementationException("����� GetRightsOnNewObject ���������� ������������ ������ null ��� �������: " + xobj.ToString());
				return rights;
			}
			catch(Exception ex)
			{
				throw new ApplicationException("������ � �������� �������� ����:\n" + ex.Message, ex);
			}
		}

		public virtual void TrackModifiedObjects(DomainObjectDataSet dataSet)
		{
			string[] userNames = m_SecurityProvider.GetAffectedUserNames(dataSet, m_AuthenticatedUsers.Values);
			if (userNames != null && userNames.Length > 0)
				foreach(string sUserName in userNames)
				{
					if (sUserName == USERNAME_ALLUSERS)
					{
						FlushAllUsers();
						break;
					}
					else
						FlushUser(sUserName);
				}
			m_SecurityProvider.TrackModifiedObjects(dataSet);
		}
	}
}
