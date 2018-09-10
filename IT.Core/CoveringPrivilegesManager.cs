//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System.Collections;
using System.Collections.Specialized;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Core
{
	/// <summary>
	/// ���������� ���������� rights-checker'a ��� �����, ��������� �������� ������� ����������� �������� ����� ����������
	/// </summary>
	public class CoveringPrivilegesManager : ObjectRightsCheckerBase
	{
		private IDictionary m_requiredPrivilegesForTypes;	// Dictionary<string, string>

		/// <summary>
		/// ctor
		/// </summary>
		public CoveringPrivilegesManager(SecurityProvider provider) : base(provider, false)
		{
			m_requiredPrivilegesForTypes = new HybridDictionary();

			// ������� SetUpIncidentWorkflow ���������� ������ � ��������, ���������� �� workflow ����������
			m_requiredPrivilegesForTypes.Add("IncidentType", SystemPrivilegesItem.SetUpIncidentWorkflow.Name);
			m_requiredPrivilegesForTypes.Add("IncidentState", SystemPrivilegesItem.SetUpIncidentWorkflow.Name);
			m_requiredPrivilegesForTypes.Add("UserRoleInIncident", SystemPrivilegesItem.SetUpIncidentWorkflow.Name);
			m_requiredPrivilegesForTypes.Add("Transition", SystemPrivilegesItem.SetUpIncidentWorkflow.Name);
            m_requiredPrivilegesForTypes.Add("IncidentCategory", SystemPrivilegesItem.SetUpIncidentWorkflow.Name);

			// ������� SetUpGlobalBlockPeriod ���������� ������ � ������� "������ ������������ ��������"
			m_requiredPrivilegesForTypes.Add("TimeSpentBlockPeriod", SystemPrivilegesItem.SetUpGlobalBlockPeriod.Name);

			// ������� ManageRefObjects ���������� ������ � ���������� ��������, �� "����������" ������������ ������������ (���� SetUpIncidentWorkflow � ManageUsers)
			/*
			 *  Service(��� �����), Position(���������), FolderTypeDependences(����������� ����� �����), 
			 *  WorkCalendarExceptions (��������� ���������� � ������� ������),
			 *  WorkHoursDayRate (����� �������� ���), 
			 *  TimeLossCause (������� ��������), ExternalLinkType(��� ������� ������), ActivityType (��� ��������� ������)
			 *  EventType (��� �������)
			 */
			string[] aTypesManagedByManageRefObjectsPrivilege = new string[] {
				"Service", "Position", "FolderTypeDependences", "WorkCalendarExceptions", 
				"WorkHoursDayRate", "TimeLossCause", 
				"ExternalLinkType", "ActivityType","EventType"
			};
			foreach(string sTypeName in aTypesManagedByManageRefObjectsPrivilege)
				m_requiredPrivilegesForTypes.Add(sTypeName, SystemPrivilegesItem.ManageRefObjects.Name);

			// ������� ManageRefObjectsInTMS ���������� ������ � ���������� �������� ������� ����� ��������:
			/*	Currency (������), InfoSource(�������� ����������), Branch(�������), 
			 *	LossReason(������� ���������), InfoSourceType(��� ��������� ����������)
			 */
			m_requiredPrivilegesForTypes.Add("Currency", SystemPrivilegesItem.ManageRefObjectsInTMS.Name);
			m_requiredPrivilegesForTypes.Add("InfoSource", SystemPrivilegesItem.ManageRefObjectsInTMS.Name);
			m_requiredPrivilegesForTypes.Add("Branch", SystemPrivilegesItem.ManageRefObjectsInTMS.Name);
			m_requiredPrivilegesForTypes.Add("LossReason", SystemPrivilegesItem.ManageRefObjectsInTMS.Name);
			m_requiredPrivilegesForTypes.Add("InfoSourceType", SystemPrivilegesItem.ManageRefObjectsInTMS.Name);
		}

		/// <summary>
		/// ������ ���� �� ������������ � �� ������. � �.�. ������������ ��� ���������� ����������� �������
		/// </summary>
		public override XObjectRights GetObjectRights(ITUser xuser, DomainObjectData xobj, XStorageConnection con)
		{
			string sPrivilege = (string)m_requiredPrivilegesForTypes[xobj.ObjectType];
			if (sPrivilege != null)
			{
				if (xuser.PrivilegeSet.Contains(sPrivilege))
					return XObjectRights.FullRights;
				else
					return XObjectRights.ReadOnlyRights;
			}
			return XObjectRights.FullRights;
		}

		/// <summary>
		/// �������� ����� ��������� ������� (�����������)
		/// </summary>
		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			string sPrivilege = (string)m_requiredPrivilegesForTypes[xobj.ObjectType];
			if (sPrivilege != null)
			{
				if (user.PrivilegeSet.Contains(sPrivilege))
					return XNewObjectRights.FullRights;
				else
					return XNewObjectRights.EmptyRights;
			}
			return XNewObjectRights.FullRights;
		}

		/// <summary>
		/// �������� ��� ���������� ������ �������
		/// </summary>
		protected override bool hasInsertObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			string sPrivilege = (string)m_requiredPrivilegesForTypes[xobj.ObjectType];
			if (sPrivilege != null)
			{
				if (user.PrivilegeSet.Contains(sPrivilege))
					return true;
				else
				{
					sErrorDescription = "��� ����� �������� ������� ���������� ���������� \"" + SystemPrivilegesItem.GetItem(sPrivilege).Description + "\"";
					return false;
				}
			}
			return true;
		}

	}
}