//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Collections;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;
using System.Security.Principal;
using System.Threading;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда изменения состояния активности
	/// </summary>
    [Serializable]
	[XTransaction(XTransactionRequirement.Required)]
	public class UpdateActivityStateCommand : XCommand 
	{
		/// <summary>
		/// Метод запуска операции на выполнение, «входная» точка операции
		/// ПЕРЕГРУЖЕННЫЙ, СТРОГО ТИПИЗИРОВАННЫЙ МЕТОД 
		/// ВЫЗЫВАЕТСЯ ЯДРОМ АВТОМАТИЧЕСКИ
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		public override XResponse Execute(XRequest request, IXExecutionContext context ) 
		{
			return Execute((UpdateActivityStateRequest)request, context);
		}

		/// <summary>
		/// Типизированная реализация
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		public XResponse Execute(UpdateActivityStateRequest request, IXExecutionContext context)
		{
			//для того, чтобы изменение прошло от именя сотрудника, переданного в request.Initiator, 
			//прейдется подменить CurrentPrincipal 

			// для начала запомним текущий
			IPrincipal originalPrincipal = Thread.CurrentPrincipal;

			try
			{
				// если подсунули нам инициатора, вытащим имя пользователя и подменим CurrentPrincipal
				{
					var ds = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);

					if (request.Initiator != Guid.Empty)
					{
						var employee = ds.Load(context.Connection, "Employee", request.Initiator);
						var userID = employee.GetLoadedPropValue("SystemUser");
						if (userID == DBNull.Value) throw new XBusinessLogicException("Сотрудник не является пользователем системы");
						var user = ds.Load(context.Connection, "SystemUser", (Guid)userID);

						Thread.CurrentPrincipal = new GenericPrincipal(
							new GenericIdentity((string)user.GetLoadedPropValue("Login")),
							new string[] { "XUser" });
					}
				}

				// собственно внесем изменение
				{
					var ds = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);

					// Загрузим объект
					var activity = ds.Load(context.Connection, "Folder", request.Activity);
					
					activity.SetUpdatedPropValue("State", request.NewState);
					// Если задано, то и описание обновим
					if (!String.IsNullOrEmpty(request.Description))
					{
						var description = activity.GetLoadedPropValueOrLoad(context.Connection, "Description");

						activity.SetUpdatedPropValue(
							"Description", 
							description == DBNull.Value || string.IsNullOrEmpty((string)description)
								? request.Description
								: string.Format("{0}\n{1}", (string)description, request.Description)
							);
					}

					XStorageGateway.Save(context, ds, Guid.NewGuid());
				}
			}
			finally
			{
				// в любом случае вернем все как было
				Thread.CurrentPrincipal = originalPrincipal;
			}

			return new XResponse();
		}
	}
}
