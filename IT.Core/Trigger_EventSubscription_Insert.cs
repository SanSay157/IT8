//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Core.Triggers
{
	/// <summary>
	/// ������� �� ������ "�������� �� �������" (EventSubscription)
	/// ������������� �������� ��������� (User) ��� ����� ��������, ���� ������ �������� "������ ��������"
	/// </summary>
	[XTriggerDefinitionAttribute(XTriggerActions.Insert , XTriggerFireTimes.Before, XTriggerFireTypes.ForEachObject, "EventSubscription")]
	public class Trigger_EventSubscription_Insert: XTrigger
	{
		public override void Execute(XTriggerArgs args, IXExecutionContext context)
		{
			DomainObjectData xobjEventSubscription = args.TriggeredObject;
			// ��� ������ ������� ���� �� ������ ������ �������� ��������� �������� ������������
			if (args.Action == XTriggerActions.Insert &&  !(xobjEventSubscription.GetUpdatedPropValue("Group") is Guid))
			{
				xobjEventSubscription.SetUpdatedPropValue("User", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).EmployeeID );
			}
		}
	}
}
