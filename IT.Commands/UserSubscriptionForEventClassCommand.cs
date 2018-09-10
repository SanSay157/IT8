//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using System.Text;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;


namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Операция управления подпиской для текущего пользователя
	/// </summary>
	[XTransaction(XTransactionRequirement.Required)]
	public class UserSubscriptionForEventClassCommand:XCommand
	{
		/// <summary>
		/// Метод запуска операции на выполнение, «входная» точка операции
		/// ПЕРЕГРУЖЕННЫЙ, СТРОГО ТИПИЗИРОВАННЫЙ МЕТОД 
		/// ВЫЗЫВАЕТСЯ ЯДРОМ АВТОМАТИЧЕСКИ
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		public virtual XResponse Execute( UserSubscriptionForEventClassRequest request, IXExecutionContext context )
		{
			// Первым делом получим идентификатор пользователя
			Guid employeeID =((ITUser)XSecurityManager.Instance.GetCurrentUser()).EmployeeID;

			// Сформируем запрос
			using(XDbCommand cmd = context.Connection.CreateCommand())
			{
				string sParamEmployeeID = context.Connection.GetParameterName("emp");
				string sParamEventClass = context.Connection.GetParameterName("evt");

				// Отпишем
				StringBuilder sb = new StringBuilder();
				sb.AppendFormat(@"
SET NOCOUNT ON
SET ROWCOUNT 0

DELETE dbo.EventSubscription
WHERE [User]={0} 
	AND
	( 
		([EventCreationRule] IN (SELECT ObjectID FROM dbo.EventType WHERE EventType={1}))
		OR
		{1}=0
	)
", sParamEmployeeID, sParamEventClass);

				if( request.Action == UserSubscriptionForEventClassAction.SwitchToDigestOnly )
				{
					sb.AppendFormat(@"
INSERT INTO dbo.EventSubscription([User], [IncludeInDigest], [InstantDelivery], [EventCreationRule])
(
	SELECT {0}, 1, 0, ObjectID
	FROM dbo.EventType
	WHERE EventType={1} OR {1}=0
)
", sParamEmployeeID, sParamEventClass);
					
				}
				else if( request.Action == UserSubscriptionForEventClassAction.Unsubscribe )
				{
					sb.AppendFormat(@"
INSERT INTO dbo.EventSubscription([User], [IncludeInDigest], [InstantDelivery], [EventCreationRule])
(
	SELECT {0}, 0, 0, ObjectID
	FROM dbo.EventType
	WHERE EventType={1} OR {1}=0
)
", sParamEmployeeID, sParamEventClass);
				}

				cmd.CommandTimeout = int.MaxValue-128;
				cmd.CommandText = sb.ToString();
				cmd.Parameters.Add(sParamEmployeeID, employeeID);
				cmd.Parameters.Add(sParamEventClass, request.EventClass);

				cmd.ExecuteNonQuery();
			}
			return new XResponse();
		}
	}
}
