//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System.Xml;
using Croc.IncidentTracker.Core;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;
using System;
namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда получения профиля текущего пользователя для Web-клиента
	/// </summary>
    [Serializable]
	public class GetCurrentUserClientProfileCommand: XCommand
	{
		/// <summary>
		/// Метод запуска операции на выполнение, <входная> точка операции
		/// ПЕРЕГРУЖЕННЫЙ, СТРОГО ТИПИЗИРОВАННЫЙ МЕТОД 
		/// ВЫЗЫВАЕТСЯ ЯДРОМ АВТОМАТИЧЕСКИ
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		public override XResponse Execute(XRequest request, IXExecutionContext context)
		{
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();

			GetCurrentUserClientProfileResponse response = new GetCurrentUserClientProfileResponse();
			/*
			 * Закоментировано, т.к. сейчас нет необходимости в получении xml-объекта текущего сотрудника, если понадобится, то раскоментировать
			XmlElement xmlCurrentEmployee = context.Connection.Load( "Employee", user.EmployeeID );
			context.Connection.LoadProperty( xmlCurrentEmployee, "SystemUser" );
			response.XmlEmployee = xmlCurrentEmployee;
			*/

			response.EmployeeID = user.EmployeeID;
			response.SystemUserID = user.SystemUserID;
			response.WorkdayDuration = user.WorkdayDuration;
			return response;
		}
	}
}