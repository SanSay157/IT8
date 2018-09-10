//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Core.Triggers
{
	/// <summary>
	/// Триггер на создание Папки.
	/// Создает запись в истории папки с типом собятия "Создание"
	/// </summary>
	[XTriggerDefinitionAttribute(XTriggerActions.Insert, XTriggerFireTimes.Before, XTriggerFireTypes.ForEachObject, "Folder")]
	class Folder_Create: FolderTriggerBase
	{
		public override void Execute(XTriggerArgs args, IXExecutionContext context)
		{
			DomainObjectData xobjHistory = getFolderHistoryObject(args.DataSet, args.TriggeredObject);
			xobjHistory.SetUpdatedPropValue("Event", FolderHistoryEvents.Creating);
			// если не задан Инициатор, то установим текущего сотрудника
			if (!args.TriggeredObject.HasUpdatedProp("Initiator") || args.TriggeredObject.GetUpdatedPropValue("Initiator") == DBNull.Value)
				args.TriggeredObject.SetUpdatedPropValue("Initiator", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).EmployeeID);
		}
	}
}
