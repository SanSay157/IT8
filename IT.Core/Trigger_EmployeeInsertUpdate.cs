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
    /// Триггер на изменение свойств объекта "Сотрудник" .
    /// </summary>
    [XTriggerDefinitionAttribute(XTriggerActions.Update, XTriggerFireTimes.After, XTriggerFireTypes.ForEachObject, "Employee")]
    class Trigger_EmployeeInsertUpdate : FolderTriggerBase
    {
        /// <summary>
        /// Обнуление нормы в случае увольнения сотрудника, либо временной нетрудоспособности.
        /// </summary>
        private void setEmployeeRate(XTriggerArgs args, string sComment, DateTime dtDate)
        {
            DomainObjectData xobjEmployeeRate = args.DataSet.CreateNew("EmployeeRate", true);
            xobjEmployeeRate.SetUpdatedPropValue("Employee", args.TriggeredObject.ObjectID);
            xobjEmployeeRate.SetUpdatedPropValue("Rate", 0);
            xobjEmployeeRate.SetUpdatedPropValue("Date", dtDate);
            xobjEmployeeRate.SetUpdatedPropValue("Comment", sComment);
        }
        private void setEmployeeHistoryEvent(XTriggerArgs args, EmployeeHistoryEvents enumEvent)
        {
            DomainObjectData xobjEmployeeHistory = args.DataSet.CreateNew("EmployeeHistory", true);
            ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
            xobjEmployeeHistory.SetUpdatedPropValue("Employee", args.TriggeredObject.ObjectID);
            xobjEmployeeHistory.SetUpdatedPropValue("Event", enumEvent);
            xobjEmployeeHistory.SetUpdatedPropValue("SystemUser", user.SystemUserID);
            xobjEmployeeHistory.SetUpdatedPropValue("EventDate", DateTime.Now);
        }
        public override void Execute(XTriggerArgs args, IXExecutionContext context)
        {
            DomainObjectData xobj = args.TriggeredObject;
            // Признак изменения Временной нетрудоспособности
			bool bUpdatedTemporaryDisability = xobj.HasUpdatedProp("TemporaryDisability");
            // Признак изменения Даты начала работы 
			bool bUpdateWorkBeginDay =  xobj.HasUpdatedProp("WorkBeginDate");
            // Признак изменения Даты окончания работы 
            bool bUpdateWorkEndDay = xobj.HasUpdatedProp("WorkEndDate");
            
            // Если что-то менялось, то запишем это событие в историю
            if (bUpdatedTemporaryDisability)
            {
                bool oldValue = (bool)xobj.GetLoadedPropValueOrLoad(context.Connection, "TemporaryDisability");
                bool newValue = (bool)xobj.GetUpdatedPropValue("TemporaryDisability");
                // Если свойство действительно обновилось, то запишем в "историю"
                if (oldValue != newValue)
                {
                    setEmployeeHistoryEvent(args, EmployeeHistoryEvents.TemporaryDisability);
                    // Если сотрудник получил признак "Временная нетрудоспособность", то надо автоматически задать 
                    // норму рабочего времени 0
                    if (newValue)
                        setEmployeeRate(args, "Временная нетрудоспособность", DateTime.Now);
                }
            }
            if (bUpdateWorkBeginDay)
                setEmployeeHistoryEvent(args, EmployeeHistoryEvents.WorkBeginDay);
            if (bUpdateWorkEndDay)
            {
                setEmployeeHistoryEvent(args, EmployeeHistoryEvents.WorkEndDay);
                // Если для сотрудника задали "Дату окончания работы", то надо автоматически задать 
                // норму рабочего времени 0
                if (xobj.GetUpdatedPropValue("WorkEndDate") != DBNull.Value)
                {
                    setEmployeeRate(args, "Уволен", (DateTime)xobj.GetUpdatedPropValue("WorkEndDate"));
                }
            }
        }
    }
}
