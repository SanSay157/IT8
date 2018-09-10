//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using System.IO;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Jobs;
using Croc.IncidentTracker.Storage;
using Croc.IncidentTracker.Tools.DbCheck;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Core.Events;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;
using Croc.IncidentTracker.Hierarchy;
namespace Croc.IncidentTracker.EventHandlers
{
	/// <summary>
	/// ���������� ������ ����������
	/// </summary>
	public class Handler_OnApplicationStart: IXEventHandler
	{
		public void HandleEvent(XEventArgs args, IXExecutionContextHandler context)
		{
			// �������������� ���������� ������������
			SecurityProvider provider = new SecurityProvider(XFactory.Instance.StorageController["ROConnection"]);
			XSecurityManager.Instance.SecurityProvider = provider;

			// �������������� ���������� ��������
			XTreeController.Initialize(context.Connection.MetadataManager);

			// �������������� ���������� application-���������
			// ����������: ��������� � ������ ������� ������������ ������������ ������������, � ������� ���������������� ����������
			object o = XTriggersController.Instance;
			
			// �������������� ������ ��� �������� �������� ����������
			ApplicationSettingsInitializationParams initParam = new ApplicationSettingsInitializationParams();
			//	: ���� ������� ������������ ��������
			object vValue = context.Connection.CreateCommand("SELECT Max(BlockDate) FROM TimeSpentBlockPeriod").ExecuteScalar();
			if (vValue != null && vValue != DBNull.Value)
				initParam.GlobalBlockPeriodDate = (DateTime)vValue;
			
			ApplicationSettings.Initialize(initParam);

			// �������� ��� ������� ��� �������� ������� �������� � ��
			string sFileName = context.Config.SelectNodeTextValue("dbc:dbcheck/dbc:config-file");
			string sFullFileName = Path.Combine(context.Config.BaseConfigPath, sFileName);
			// ��������� ������� �������� � ��
			//DbCheckResult dbcResult = DbCheckFacade.Check(context.Connection, sFullFileName);
			//if (!dbcResult.Success)
			{
			//	throw new ApplicationException(dbcResult.ErrorsText);
			}
			// ��������� ����������� �������
			JobsSheduler.Run();
			// ��������� ������� ��������
			//context.ExecCommandAsync(new XRequest("SendNotificationsAsync"),false);
		}
	}
}
