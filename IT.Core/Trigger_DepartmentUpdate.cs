//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2009
//******************************************************************************
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Data;
using System.Data;
using Croc.XmlFramework.Public;
using System;

namespace Croc.IncidentTracker.Core.Triggers
{
    /// <summary>
    /// Триггер на объект Подразделение (Department)
    /// Отслеживает изменение признака "Архивный". (Признак архивного Подразделения может быть указан, только если Подразделение не имеет работающих сотрудников)
    /// </summary>
    [XTriggerDefinitionAttribute(XTriggerActions.Update, XTriggerFireTimes.Before, XTriggerFireTypes.ForEachObject, "Department")]
    public class Trigger_DepartmentUpdate : XTrigger
    {
        public override void Execute(XTriggerArgs args, IXExecutionContext context)
        {
            DomainObjectData xobj = args.TriggeredObject;
            // если изменилось значение признака "Архивное", проверим отсутствие у подразделения работающих сотрудников или не архивных департаментов.
            bool bUpdateIsArchive = xobj.HasUpdatedProp("IsArchive");

            if (bUpdateIsArchive)
            {
                bool newValue = (bool)xobj.GetUpdatedPropValue("IsArchive");
                if (!xobj.IsNew && newValue)
                {
                    //	1. Проверим, что все сотрудники (во всех вложенных департаментах) уволены
                    XDbCommand cmd = context.Connection.CreateCommand(@"
							SELECT 1 
							FROM dbo.Department d_s WITH(NOLOCK)
								JOIN dbo.Department d WITH(NOLOCK) ON d.LIndex >= d_s.LIndex AND d.RIndex <= d_s.RIndex AND d.Organization = d_s.Organization
									JOIN Employee e WITH(NOLOCK) ON (d.ObjectID = e.Department) and (e.WorkEndDate is null)
							WHERE d_s.ObjectID = @ObjectID
							");
                    cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
                    if (cmd.ExecuteScalar() != null)
                        throw new XBusinessLogicException("Департамент не может быть переведен с состояние \"Архивное\", так как содержит работающих сотрудников");
                }
                // добавим в датаграмму подчиненные департаменты 
                UpdateChildDepartments(context.Connection, args.DataSet, xobj.ObjectID, newValue);
            }
        }
        private void UpdateChildDepartments(XStorageConnection con, DomainObjectDataSet dataSet, Guid objectID, bool IsArchive)
        {
            // Обновляем вложенные департаменты, если мы меняем признак на "Архивный".
            // Если признак "Архивный" снимается, каскадной разархивации не происходит.
            // зачитаем идентификаторы всех подчиненных департаментов, состояние которых отличается от требуемого
            if (IsArchive)
            {
                XDbCommand cmd = con.CreateCommand(@"
				    SELECT d.ObjectID
				    FROM dbo.Department as d_s WITH(NOLOCK)
					    JOIN dbo.Department as d  WITH(NOLOCK) ON d.LIndex > d_s.LIndex AND d.RIndex < d_s.RIndex AND d.Organization = d_s.Organization
				    WHERE d_s.ObjectID = @ObjectID AND d.IsArchive <> @IsArchive
				    ");
                cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, objectID);
                cmd.Parameters.Add("IsArchive", DbType.Boolean, ParameterDirection.Input, false, IsArchive);
                using (IDataReader reader = cmd.ExecuteReader())
                {
                    DomainObjectData xobjSubDepartment;
                    while (reader.Read())
                    {
                        xobjSubDepartment = dataSet.GetLoadedStub("Department", reader.GetGuid(0));
                        xobjSubDepartment.SetUpdatedPropValue("IsArchive", IsArchive);
                    }
                }
            }
        }

    }
}
