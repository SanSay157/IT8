//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Core.Triggers
{
	/// <summary>
	/// Триггер на объект Задание (Task)
	/// Устанавливает свойство Планировщик (Planner) для новых объектов и изменненных, если изменилось св-во "Запланированное время"
	/// </summary>
	[XTriggerDefinitionAttribute(XTriggerActions.Insert | XTriggerActions.Update, XTriggerFireTimes.Before, XTriggerFireTypes.ForEachObject, "Task")]
	public class Task_InsertUpdate_Planner: XTrigger
	{
		public override void Execute(XTriggerArgs args, IXExecutionContext context)
		{
			DomainObjectData xobjTask = args.TriggeredObject;
			// для нового объекта, если не задан планировщик, или 
			// если изменилось запланированное время при обновлении установим планировщиком задания текущего сотрудника
			if (xobjTask.IsNew && xobjTask.GetUpdatedPropValue("Planner")==null || !xobjTask.IsNew && xobjTask.HasUpdatedProp("PlannedTime"))
			{
				xobjTask.SetUpdatedPropValue("Planner", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).EmployeeID );
			}
		}
	}
}
