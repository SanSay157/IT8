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
	/// ������� �� ��������, ��������� ��� �������� ������� "����������� �����"
	/// ������ ��������� ����� ����� ������ � ������������, ������� ��������������
	/// ���������� - ������ � ���� ������ �� �����������. ����� ��������� ������
	/// �� ������������ ��������� ������ � �������� �����, � ����� ������� 
	/// "��������� ������ �� ������������"
	/// </summary>
	[XTriggerDefinitionAttribute( XTriggerActions.All, XTriggerFireTimes.Before, XTriggerFireTypes.ForEachObject, "FolderDirection" )]
	public class FolderDirctionAllActionsTrigger : XTrigger
	{
		/// <summary>
		/// ����� ��������; ����� ���������� ����� ��������
		/// </summary>
		/// <param name="args"></param>
		/// <param name="context"></param>
		public override void Execute( XTriggerArgs args, IXExecutionContext context )
		{
			// ������� ����� ������� ������� �����
			DomainObjectData xobjHistory = args.DataSet.CreateNew( "FolderHistory", true );

			// ������� ����������� � ��� �������� ������� - ��� �������� ���������� �� 
			// ����� ����� �������������� ������ ������ �������, � ���� �� ��� - ������ �� ��
			xobjHistory.SetUpdatedPropValue( "Folder", 
				args.TriggeredObject.GetPropValueAnyhow( 
					"Folder", 
					DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, 
					context.Connection ) );

			xobjHistory.SetUpdatedPropValue( "Event", FolderHistoryEvents.DirectionInfoChanging );

			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			xobjHistory.SetUpdatedPropValue( "SystemUser", user.SystemUserID );
			xobjHistory.SetUpdatedPropValue( "EventDate", DateTime.Now );
		}
	}
}