//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System.Xml;
using Croc.IncidentTracker.Core;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда получения текущего пользователя
	/// </summary>
	public class GetCurrentEmployeeXmlCommand: XCommand
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
			XmlElement xmlCurrentEmployee = context.Connection.Load( "Employee", user.EmployeeID );
			context.Connection.LoadProperty( xmlCurrentEmployee, "SystemUser" );
			return new XGetObjectResponse( xmlCurrentEmployee ) ;
		}
	}
}