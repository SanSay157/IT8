//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Core.Triggers
{
	/// <summary>
	/// Триггер на объект "Подписка на событие" (EventSubscription)
	/// Устанавливает свойство Сотрудник (User) для новых объектов, если пустое свойство "Группа рассылки"
	/// </summary>
	[XTriggerDefinitionAttribute(XTriggerActions.Insert , XTriggerFireTimes.Before, XTriggerFireTypes.ForEachObject, "EventSubscription")]
	public class Trigger_EventSubscription_Insert: XTrigger
	{
		public override void Execute(XTriggerArgs args, IXExecutionContext context)
		{
			DomainObjectData xobjEventSubscription = args.TriggeredObject;
			// для нового объекта если не задана группа рассылки проставим текущего пользователя
			if (args.Action == XTriggerActions.Insert &&  !(xobjEventSubscription.GetUpdatedPropValue("Group") is Guid))
			{
				xobjEventSubscription.SetUpdatedPropValue("User", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).EmployeeID );
			}
		}
	}
}
