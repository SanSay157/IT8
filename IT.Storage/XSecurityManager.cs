//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
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
	/// Исключение, которое генерирует XSecurityManager, если встречает некорректную реализацию IXSecurityProvider'a
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
		/// "Волшебное" наименование пользователя, понимаемого SecurityManager'ом как "все пользователи"
		/// </summary>
		public static string USERNAME_ALLUSERS = "Everyone";
		/// <summary>
		/// Словарь аутентифицированных пользователей приложения (кэш). 
		/// Ключ - наименование пользователя, значение - экземпляр XUser или производный
		/// </summary>
		protected IDictionary m_AuthenticatedUsers;
		/// <summary>
		/// Провайдер подсистемы разделения доступа. По умолчанию используется провайдер, который разрешает все всем
		/// </summary>
		protected IXSecurityProvider m_SecurityProvider = new XSecurityProviderDummy();
		/// <summary>
		/// Поле для кэширования описания анонимного пользователя 
		/// (существует только одно, если провайдер поддерживает анонимных пользователей)
		/// </summary>
		protected XUser m_anonymusUser;

		#region Singleton pattern
		private static XSecurityManager m_Instance = new XSecurityManager();

		private XSecurityManager()
		{
			m_AuthenticatedUsers = new HybridDictionary(true);
		}

		/// <summary>
		/// Возвращает единственный экземпляр XSecurityManager 
		/// </summary>
		public static XSecurityManager Instance
		{
			get { return m_Instance; }
		}
		#endregion
		
		/// <summary>
		/// Провайдер подсистемы разделения доступа
		/// </summary>
		public IXSecurityProvider SecurityProvider
		{
			get { return m_SecurityProvider; }
			set { m_SecurityProvider = value; }
		}


		/// <summary>
		/// Возвращает описание пользователя по его наименованию
		/// </summary>
		/// <param name="sUserName">Наименование пользователя приложения</param>
		/// <remarks>
		/// Если описание было сброшено (Flush), то оно будет переполучено от SecurityProvider'a
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
					throw new XSecurityProviderErrorImplementationException("SecurityProvider.CreateUser вернул null!");
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
		/// Возвращает "текущего" пользователя приложения на основании принципала текущего потока
		/// </summary>
		/// <remarks>
		/// Если описание было сброшено (Flush), то оно будет переполучено от SecurityProvider'a
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
					throw new XSecurityException("Доступ в систему неаутентифицированным пользователям запрещен");
                    
			
			}
			else
			{
				string sName = m_SecurityProvider.GetUserNameByPrincipal(originalPrincipal);
				if (sName == null)
					throw new XSecurityProviderErrorImplementationException("SecurityProvider.GetUserNameByPrincipal вернул null!");
				user = GetXUser(sName);
				Debug.Assert(user != null);
				user.OriginalPrincipal = originalPrincipal;
				//if (!user.AccessPermitted)
				//	throw new XSecurityException("Доступ пользователя " + sName + " в систему запрещен");
                    	
             }
			return user;
		}

		/// <summary>
		/// Возвращает описание анонимного пользователя
		/// </summary>
		/// <returns></returns>
		private XUser getAnonymousUser()
		{
			if (m_anonymusUser == null)
				m_anonymusUser = m_SecurityProvider.CreateAnonymousUser();
			return m_anonymusUser;
		}

		/// <summary>
		/// Удаляет закешированное описание пользователя с заданным наименованием
		/// </summary>
		/// <param name="sUserName"></param>
		public void FlushUser(string sUserName)
		{
			XUser user = (XUser) m_AuthenticatedUsers[sUserName];
			if (user != null)
				user.SetFlushed(true);
		}

		/// <summary>
		/// Удаляет закэшированные описания всех пользователей
		/// </summary>
		public void FlushAllUsers()
		{
			foreach (XUser user in m_AuthenticatedUsers.Values)
			{
				user.SetFlushed(true);
			}
		}

		/// <summary>
		/// Возвращает словарь описаний пользователей, описания которых были затребованы в процессе работы приложения : 
		/// ключ - наименование пользователя приложения, 
		/// значение - экземпляр класса XUser или наследника
		/// </summary>
		public IDictionary Users
		{
			get { return m_AuthenticatedUsers; }
		}

		/// <summary>
		/// Возвращает наименование текущего пользователя, не создавая объект-описания (XUser)
		/// Возвращает null, если свойство Thread.CurrentPrincipal не инициализировано
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
				throw new ApplicationException("Ошибка во время проверки прав на изменение объекта: " + xobj.ObjectType + " [" + xobj.ObjectID + "]:\n" + ex.Message, ex);
			}
			if (!bAllow)
				throw new XSecurityException("Недостаточно прав");
                
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
				throw new ApplicationException("Ошибка во время проверки прав на удаление объекта: " + xobj.ObjectType + " [" + xobj.ObjectID + "]" + ex.Message, ex);
			}
			if (!bAllow)
				throw new XSecurityException("Недостаточно прав");
               
		}

		public XObjectRights GetObjectRights(DomainObjectData xobj)
		{
			XUser user = GetCurrentUser();
            if (user == null || xobj==null)
            {
                throw new ApplicationException("Ошибка в процессе проверки прав:\n");
            }
			if (user.IsUnrestricted)
				return XObjectRights.FullRights;
			try
			{
				XObjectRights rights = m_SecurityProvider.GetObjectRights(user, xobj);
				if (rights == null)
					throw new XSecurityProviderErrorImplementationException("Метод GetObjectRights провайдера безопасности вернул null для объекта: " + xobj.ToString());
				return rights;
			}
			catch(Exception ex)
			{
				throw new ApplicationException("Ошибка в процессе проверки прав:\n" + ex.Message, ex);
			}
		}

		/// <summary>
		/// Проверка на сохранение объекта в БД, поступившего от клиента, в рамках датаграммы
		/// </summary>
		/// <param name="xobj">Сохраняемый объект</param>
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
				throw new ApplicationException("Ошибка в процессе проверки прав:\n" + ex.Message, ex);
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
				throw new ApplicationException("Ошибка во время проверки прав на сохранение объекта: " + xobj.ObjectType + " [" + xobj.ObjectID + "]:\n" + ex.Message, ex);
			}
			if (!bAllow)
			{
				if (exOut != null)
					throw new XSecurityException(exOut.Message);
                else
					throw new XSecurityException("Недостаточно прав");
                    
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
					throw new XSecurityProviderErrorImplementationException("Метод GetRightsOnNewObject провайдера безопасности вернул null для объекта: " + xobj.ToString());
				return rights;
			}
			catch(Exception ex)
			{
				throw new ApplicationException("Ошибка в процессе проверки прав:\n" + ex.Message, ex);
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
