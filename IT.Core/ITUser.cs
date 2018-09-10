//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Core
{
	/// <summary>
	/// �������� ������������ ���������� IncidentTracker
	/// </summary>
	public class ITUser: XUser
	{
		/// <summary>
		/// ������������� ������������ ���������� (SystemUser.ObjectID)
		/// </summary>
		public Guid SystemUserID;
		/// <summary>
		/// ������������� ���������� (Employee.ObjectID).
		/// ��� ��������� ��������� - Guid.Empty
		/// </summary>
		public Guid EmployeeID;
		/// <summary>
		/// ������� ����������
		/// </summary>
		public string LastName;
		/// <summary>
		/// ��� ����������
		/// </summary>
		public string FirstName;
		/// <summary>
		/// EMail ����������
		/// </summary>
		public string EMail;
		/// <summary>
		/// �������: ������� ������������ ���������� - ��������� ������� 
		/// (��� ���� �� ���������� ������ ��������� (Employee), ������ ������������ (SystemUser)
		/// </summary>
		public bool IsServiceAccount;
		/// <summary>
		/// ���������� ������� ����� � ������
		/// </summary>
		public int WorkdayDuration;
		/// <summary>
		/// ������ �������� �������� ActivityType (��� ��������� ������), 
		/// ��������� ��� ������������ ��� ���� ������, �� ����� ������� ������������ ����� �������������� ������
		/// </summary>
		public IDictionary ActivityTypes;	// Dictionary<Guid, DomainObject_ActivityType>
		/// <summary>
		/// ������ ��������������� �����������, ��� ������� ������������ �������� "���������� �������"
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
		/// �������� ������ �������� ������� � ���������� ���������
		/// ��������: ����������� ������������� (���������� ������ �� ActivityTypes � ManagedOrganizations)
		/// </summary>
		/// <remarks>
		/// �� �������� ������ ���������� ���� m_privileges, m_roles, m_bIsUnrestricted, m_OriginalPrincipal
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