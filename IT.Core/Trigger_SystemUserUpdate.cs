//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using System.Data;
using Croc.IncidentTracker.Storage;
using Croc.IncidentTracker.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;


namespace Croc.IncidentTracker.Core.Triggers
{
    /// <summary>
    /// Триггер на изменение "Пользователь приложения"
    /// </summary>
    [XTriggerDefinitionAttribute(XTriggerActions.Update, XTriggerFireTimes.Before, XTriggerFireTypes.ForEachObject, "SystemUser")]
    class Trigger_SystemUserUpdate: FolderTriggerBase
    {
        public override void Execute(XTriggerArgs args, IXExecutionContext context)
        {
            DomainObjectData xobjEmployeeHistory = args.DataSet.CreateNew("EmployeeHistory", true);
            ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
            Guid uidEmployeeID = getEmployeeID(context.Connection, args.TriggeredObject.ObjectID);
            xobjEmployeeHistory.SetUpdatedPropValue("Employee", uidEmployeeID);
            xobjEmployeeHistory.SetUpdatedPropValue("Event", EmployeeHistoryEvents.ChangeSecurity);
            xobjEmployeeHistory.SetUpdatedPropValue("SystemUser", user.SystemUserID);
            xobjEmployeeHistory.SetUpdatedPropValue("EventDate", DateTime.Now);
        }
        /// <summary>
        /// Метод получения идентификатора объекта "Сотрудник" по идентификатору объекта "Пользователь приложения"
        /// </summary>
        private Guid getEmployeeID(XStorageConnection con, Guid objectID)
        {
            Guid uidEmployeeID =  Guid.Empty; // идентификатор сотрудника
            // Зачитаем идентификатор
            XDbCommand cmd = con.CreateCommand(@"SELECT e.ObjectID
                    FROM [dbo].[Employee] e
	                JOIN [dbo].[SystemUser] su ON e.SystemUser = su.ObjectID
                    WHERE su.ObjectID = @ObjectID
            ");
            cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, objectID);
            using (IDataReader reader = cmd.ExecuteReader())
            {
                if (reader.Read())
                {
                    uidEmployeeID = reader.GetGuid(0);
                }
            }
            return uidEmployeeID;

        }
    }
}
