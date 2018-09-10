//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Core.Triggers
{
	/// <summary>
	/// ������� �� �������� �����.
	/// ������� ������ � ������� ����� � ����� ������� "��������"
	/// </summary>
	[XTriggerDefinitionAttribute(XTriggerActions.Insert, XTriggerFireTimes.Before, XTriggerFireTypes.ForEachObject, "Folder")]
	class Folder_Create: FolderTriggerBase
	{
		public override void Execute(XTriggerArgs args, IXExecutionContext context)
		{
			DomainObjectData xobjHistory = getFolderHistoryObject(args.DataSet, args.TriggeredObject);
			xobjHistory.SetUpdatedPropValue("Event", FolderHistoryEvents.Creating);
			// ���� �� ����� ���������, �� ��������� �������� ����������
			if (!args.TriggeredObject.HasUpdatedProp("Initiator") || args.TriggeredObject.GetUpdatedPropValue("Initiator") == DBNull.Value)
				args.TriggeredObject.SetUpdatedPropValue("Initiator", ((ITUser)XSecurityManager.Instance.GetCurrentUser()).EmployeeID);
		}
	}
}
