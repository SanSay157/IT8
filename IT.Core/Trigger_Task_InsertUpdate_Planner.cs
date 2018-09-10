//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Core.Triggers
{
	/// <summary>
	/// ������� �� ������ ������� (Task)
	/// ������������� �������� ����������� (Planner) ��� ����� �������� � �����������, ���� ���������� ��-�� "��������������� �����"
	/// </summary>
	[XTriggerDefinitionAttribute(XTriggerActions.Insert | XTriggerActions.Update, XTriggerFireTimes.Before, XTriggerFireTypes.ForEachObject, "Task")]
	public class Task_InsertUpdate_Planner: XTrigger
	{
		public override void Execute(XTriggerArgs args, IXExecutionContext context)
		{
			DomainObjectData xobjTask = args.TriggeredObject;
			// ��� ������ �������, ���� �� ����� �����������, ��� 
			// ���� ���������� ��������������� ����� ��� ���������� ��������� ������������� ������� �������� ����������
			if (xobjTask.IsNew && xobjTask.GetUpdatedPropValue("Planner")==null || !xobjTask.IsNew && xobjTask.HasUpdatedProp("PlannedTime"))
			{
				xobjTask.SetUpdatedPropValue("Planner", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).EmployeeID );
			}
		}
	}
}
