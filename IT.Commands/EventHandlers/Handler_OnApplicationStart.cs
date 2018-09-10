//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
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
	/// Обработчик старта приложения
	/// </summary>
	public class Handler_OnApplicationStart: IXEventHandler
	{
		public void HandleEvent(XEventArgs args, IXExecutionContextHandler context)
		{
			// Инициализируем подсистему безопасности
			SecurityProvider provider = new SecurityProvider(XFactory.Instance.StorageController["ROConnection"]);
			XSecurityManager.Instance.SecurityProvider = provider;

			// Инициализируем подсистему иерархий
			XTreeController.Initialize(context.Connection.MetadataManager);

			// Инициализируем подсистему application-триггеров
			// Примечание: обращение к классу вызовет срабатывание статического конструктора, в котором инициализируется подсистема
			object o = XTriggersController.Instance;
			
			// Инициализируем объект для хранения настроек приложения
			ApplicationSettingsInitializationParams initParam = new ApplicationSettingsInitializationParams();
			//	: Дата периода блокирования списаний
			object vValue = context.Connection.CreateCommand("SELECT Max(BlockDate) FROM TimeSpentBlockPeriod").ExecuteScalar();
			if (vValue != null && vValue != DBNull.Value)
				initParam.GlobalBlockPeriodDate = (DateTime)vValue;
			
			ApplicationSettings.Initialize(initParam);

			// получаем имя конфига для проверки наличия объектов в БД
			string sFileName = context.Config.SelectNodeTextValue("dbc:dbcheck/dbc:config-file");
			string sFullFileName = Path.Combine(context.Config.BaseConfigPath, sFileName);
			// проверяем наличие объектов в БД
			//DbCheckResult dbcResult = DbCheckFacade.Check(context.Connection, sFullFileName);
			//if (!dbcResult.Success)
			{
			//	throw new ApplicationException(dbcResult.ErrorsText);
			}
			// запускаем планировщик заданий
			JobsSheduler.Run();
			// запускаем команду рассылки
			//context.ExecCommandAsync(new XRequest("SendNotificationsAsync"),false);
		}
	}
}
