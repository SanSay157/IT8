//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Core.Triggers
{
	/// <summary>
	/// Триггер на создание, изменение или удаление объекта "Направление папки"
	/// Объект описывает связь между папкой и направлением, включая дополнительную
	/// информацию - данные о доле затрат по направлению. Любое изменение данных
	/// по направлениям порождает запись в систории папки, с типом события 
	/// "Изменение данных по направлениям"
	/// </summary>
	[XTriggerDefinitionAttribute( XTriggerActions.All, XTriggerFireTimes.Before, XTriggerFireTypes.ForEachObject, "FolderDirection" )]
	public class FolderDirctionAllActionsTrigger : XTrigger
	{
		/// <summary>
		/// Вызов триггера; метод вызывается Ядром треккера
		/// </summary>
		/// <param name="args"></param>
		/// <param name="context"></param>
		public override void Execute( XTriggerArgs args, IXExecutionContext context )
		{
			// Создаем новый элемент истории папки
			DomainObjectData xobjHistory = args.DataSet.CreateNew( "FolderHistory", true );

			// Триггер запускается и при удалении объекта - для загрузки информации по 
			// папке могут использоваться данные самого объекта, а если их нет - данные из БД
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