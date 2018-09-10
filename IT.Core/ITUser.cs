//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Core
{
	/// <summary>
	/// Описание пользователя приложения IncidentTracker
	/// </summary>
	public class ITUser: XUser
	{
		/// <summary>
		/// Идентификатор пользователя приложения (SystemUser.ObjectID)
		/// </summary>
		public Guid SystemUserID;
		/// <summary>
		/// Идентификатор сотрудника (Employee.ObjectID).
		/// Для сервисных аккаунтов - Guid.Empty
		/// </summary>
		public Guid EmployeeID;
		/// <summary>
		/// Фамилия сотрудника
		/// </summary>
		public string LastName;
		/// <summary>
		/// Имя сотрудника
		/// </summary>
		public string FirstName;
		/// <summary>
		/// EMail сотрудника
		/// </summary>
		public string EMail;
		/// <summary>
		/// Признак: текущий пользователь приложения - сервисный аккаунт 
		/// (для него не связанного объект Сотрудник (Employee), только Пользователь (SystemUser)
		/// </summary>
		public bool IsServiceAccount;
		/// <summary>
		/// Количество рабочих часов в сутках
		/// </summary>
		public int WorkdayDuration;
		/// <summary>
		/// Массив описаний объектов ActivityType (тип проектных затрат), 
		/// указанных для пользователя как типы затрат, на папки которых пользователь имеет неограниченный доступ
		/// </summary>
		public IDictionary ActivityTypes;	// Dictionary<Guid, DomainObject_ActivityType>
		/// <summary>
		/// Массив идентификаторов организаций, для которых пользователь является "директором клиента"
		/// </summary>
		public Guid[] ManagedOrganizations;

		public bool ManageOrganization(Guid orgID)
		{
			return Array.IndexOf(ManagedOrganizations, orgID) > -1;
		}

		public bool ManageActivityType(Guid activityTypeID)
		{
			return ActivityTypes.Contains(activityTypeID);
		}

		public ITUser(string sName, XRole[] roles, XPrivilegeSet privilege_set)
			: base(sName, roles, privilege_set)
		{}
		
		/// <summary>
		/// Копирует данные текущего объекта в переданный экземпляр
		/// ВНИМАНИЕ: копирование поверхностное (копируются ссылки на ActivityTypes и ManagedOrganizations)
		/// </summary>
		/// <remarks>
		/// Из базового класса копируются поля m_privileges, m_roles, m_bIsUnrestricted, m_OriginalPrincipal
		/// </remarks>
		/// <param name="user"></param>
		public void CopyTo(ITUser user)
		{
			user.SystemUserID = SystemUserID;
			user.EmployeeID = EmployeeID;
			user.LastName = LastName;
			user.FirstName = FirstName;
			user.EMail = EMail;
			user.IsServiceAccount = IsServiceAccount;
			user.WorkdayDuration = WorkdayDuration;
			user.ActivityTypes = ActivityTypes;
			user.ManagedOrganizations = ManagedOrganizations;
			user.m_privileges = m_privileges;
			user.m_roles = m_roles;
			user.m_bIsUnrestricted = m_bIsUnrestricted;
			user.m_OriginalPrincipal = m_OriginalPrincipal;
			user.m_bAccessPermitted = m_bAccessPermitted;
		}
	}

	public class DomainObject_ActivityType
	{
		public Guid ObjectID;
		public string Name;
		public string Code;
		public bool AccountRelated;
		public FolderTypeFlags FolderType;
		public DateTime StartDate;
		public DateTime EndDate;
	}
}