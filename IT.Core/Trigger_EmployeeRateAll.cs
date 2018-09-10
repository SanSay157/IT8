//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using Croc.IncidentTracker.Storage;
using Croc.IncidentTracker.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Core.Triggers
{
    /// <summary>
    /// Триггер на создание, изменение или удаление объекта "Норма рабочего времени"
    /// Объект описывает связь между сотрудником и нормой рабочего дня.
    /// </summary>
    [XTriggerDefinitionAttribute(XTriggerActions.All, XTriggerFireTimes.Before, XTriggerFireTypes.ForEachObject, "EmployeeRate")]
    class Trigger_EmployeeRate: FolderTriggerBase
    {
        public override void Execute(XTriggerArgs args, IXExecutionContext context)
        {
            DomainObjectData xobj = args.TriggeredObject;
            Guid uidEmployeeID = Guid.Empty;
            // Если создается новая норма, то возьмем обновляемое свойство "Employee", иначе загрузим его
            if (xobj.IsNew)
            {
                uidEmployeeID = (Guid)xobj.GetUpdatedPropValue("Employee");
            }
            else
            {
                uidEmployeeID = (Guid)xobj.GetLoadedPropValueOrLoad(context.Connection, "Employee");
            }
            DomainObjectData xobjEmployeeHistory = args.DataSet.CreateNew("EmployeeHistory", true);
            ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
            xobjEmployeeHistory.SetUpdatedPropValue("Employee", uidEmployeeID);
            xobjEmployeeHistory.SetUpdatedPropValue("Event", EmployeeHistoryEvents.ChangeRate);
            xobjEmployeeHistory.SetUpdatedPropValue("SystemUser", user.SystemUserID);
            xobjEmployeeHistory.SetUpdatedPropValue("EventDate", DateTime.Now);
        }
    }
}
