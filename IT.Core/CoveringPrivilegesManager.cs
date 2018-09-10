//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System.Collections;
using System.Collections.Specialized;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Core
{
	/// <summary>
	/// Упрощенная реализация rights-checker'a для типов, изменение объектов которых управляется наличием одной привилегии
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

			// Наличие SetUpIncidentWorkflow определяет доступ к объектам, отвечающим за workflow инцидентов
			m_requiredPrivilegesForTypes.Add("IncidentType", SystemPrivilegesItem.SetUpIncidentWorkflow.Name);
			m_requiredPrivilegesForTypes.Add("IncidentState", SystemPrivilegesItem.SetUpIncidentWorkflow.Name);
			m_requiredPrivilegesForTypes.Add("UserRoleInIncident", SystemPrivilegesItem.SetUpIncidentWorkflow.Name);
			m_requiredPrivilegesForTypes.Add("Transition", SystemPrivilegesItem.SetUpIncidentWorkflow.Name);
            m_requiredPrivilegesForTypes.Add("IncidentCategory", SystemPrivilegesItem.SetUpIncidentWorkflow.Name);

			// Наличие SetUpGlobalBlockPeriod определяет доступ к объекту "Период блокирования списаний"
			m_requiredPrivilegesForTypes.Add("TimeSpentBlockPeriod", SystemPrivilegesItem.SetUpGlobalBlockPeriod.Name);

			// Наличие ManageRefObjects определяет доступ к справочным объектам, не "обложенных" специальными привилегиями (типа SetUpIncidentWorkflow и ManageUsers)
			/*
			 *  Service(Вид услуг), Position(Должность), FolderTypeDependences(Зависимости типов папок), 
			 *  WorkCalendarExceptions (Календарь исключений в рабочей неделе),
			 *  WorkHoursDayRate (Норма рабочего дня), 
			 *  TimeLossCause (Причина списания), ExternalLinkType(Тип внешней ссылки), ActivityType (Тип проектных затрат)
			 *  EventType (тип события)
			 */
			string[] aTypesManagedByManageRefObjectsPrivilege = new string[] {
				"Service", "Position", "FolderTypeDependences", "WorkCalendarExceptions", 
				"WorkHoursDayRate", "TimeLossCause", 
				"ExternalLinkType", "ActivityType","EventType"
			};
			foreach(string sTypeName in aTypesManagedByManageRefObjectsPrivilege)
				m_requiredPrivilegesForTypes.Add(sTypeName, SystemPrivilegesItem.ManageRefObjects.Name);

			// Наличие ManageRefObjectsInTMS определяет доступ к справочным объектам системы учета тендеров:
			/*	Currency (Валюта), InfoSource(Источник информации), Branch(Отрасль), 
			 *	LossReason(Причины проигрыша), InfoSourceType(Тип источника информации)
			 */
			m_requiredPrivilegesForTypes.Add("Currency", SystemPrivilegesItem.ManageRefObjectsInTMS.Name);
			m_requiredPrivilegesForTypes.Add("InfoSource", SystemPrivilegesItem.ManageRefObjectsInTMS.Name);
			m_requiredPrivilegesForTypes.Add("Branch", SystemPrivilegesItem.ManageRefObjectsInTMS.Name);
			m_requiredPrivilegesForTypes.Add("LossReason", SystemPrivilegesItem.ManageRefObjectsInTMS.Name);
			m_requiredPrivilegesForTypes.Add("InfoSourceType", SystemPrivilegesItem.ManageRefObjectsInTMS.Name);
		}

		/// <summary>
		/// Запрос прав на существующий в БД объект. В т.ч. используется при сохранении измененного объекта
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
		/// Проверка перед созданием объекта (упреждающая)
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
		/// Проверка при сохранении нового объекта
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
					sErrorDescription = "Для права создания объекта необходима привилегия \"" + SystemPrivilegesItem.GetItem(sPrivilege).Description + "\"";
					return false;
				}
			}
			return true;
		}

	}
}