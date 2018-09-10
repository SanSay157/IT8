//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Public;
namespace Croc.IncidentTracker.Commands
{
    [Serializable]
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetCurrentUserNavInfoCommand : XCommand
	{
		/// <summary>
		/// Константное наименование источника данных
		/// </summary>
		const string DEF_DATASOURCE_NAME = "GetEmployeeUsersProfileID";

		/// <summary>
		/// Метод запуска операции на выполнение, <входная> точка операции
		/// ПЕРЕГРУЖЕННЫЙ, СТРОГО ТИПИЗИРОВАННЫЙ МЕТОД 
		/// ВЫЗЫВАЕТСЯ ЯДРОМ АВТОМАТИЧЕСКИ
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		public GetCurrentUserNavInfoResponse Execute( XRequest request, IXExecutionContext context ) 
		{
			// Результат:
			GetCurrentUserNavInfoResponse response = new GetCurrentUserNavInfoResponse();
			// Сразу зададим значения по умолчанию:
			response.NavigationInfo.ShowExpensesPanel = true;
			response.NavigationInfo.ExpensesPanelAutoUpdateDelay = 0;
			response.NavigationInfo.UseOwnStartPage = false;

			// Описание пользлователя:
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			// ... если пользователь НЕ аутентифицирован или если это СИСТЕМНЫЙ 
			// СЕРВИС, то возвращаем "пустые" данные; Web-сторона анализирует 
			// это отдельно:
			if (!user.IsAuthenticated || user.IsServiceAccount)
				return response;

			// #1: НАСТРОЙКИ ПРОФИЛЯ ПОЛЬЗОВАТЕЛЯ
			//	-- если пользователь аутентифицирован
			//	-- если это не системный сервис
			DomainObjectData dodUserProfile = getUserProfile( user.SystemUserID, context.Connection );
			if ( null!=dodUserProfile )
			{
				// Зачитаем значения свойств объекта профиля и перепишем значения 
				// в объект-опсатель, но только если они отличны от NULL (иначе 
				// будут действовать значения по умолчанию, заданые выше):
				object oValue = dodUserProfile.GetLoadedPropValue("ShowExpensesPanel");
				if (DBNull.Value!=oValue)
					response.NavigationInfo.ShowExpensesPanel = (bool)oValue;

				oValue = dodUserProfile.GetLoadedPropValue("ExpensesPanelAutoUpdateDelay");
				if (DBNull.Value!=oValue)
					response.NavigationInfo.ExpensesPanelAutoUpdateDelay = (int)oValue;

				oValue = dodUserProfile.GetLoadedPropValue("StartPage");
				if (DBNull.Value!=oValue)
				{
					response.NavigationInfo.UseOwnStartPage = true;
					response.NavigationInfo.OwnStartPage = (StartPages)oValue;
				}
			}
			else
			{
				// Данные по "своей" странице не заданы - по умолчанию 
				// идем на страницу "мои инциденты"
				response.NavigationInfo.UseOwnStartPage = true;
				response.NavigationInfo.OwnStartPage = StartPages.CurrentTaskList;
			}

			
			// #2: АНАЛИЗ ПРИВИЛЕГИЙ ПОЛЬЗОВАТЕЛЯ - формирование доступных элементов навигационной панели:
			//	-- если пользователь аутентифицирован
			//	-- если это не системный сервис
			
			// Добавляем идентификаторы доступных элементов навигационной панели:
			// ...домашняя станица - доступна всегда
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_HomePage, String.Empty );
			// ...иерархия "Клиенты-проекты" - доступна всегда
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_CustomerActivityTree, String.Empty );
			// ...список проектов - доступен всегда
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_ActivityList, String.Empty );
			// ...список "мои инциденты" - доступен всегда
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_CurrentTasks, String.Empty );
			// ...список "поиск инцидентов" - доступен всегда
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_IncidentList, String.Empty );
			// ...список "списания" - доступен всегда, но для разных привилегий открывает разные URL:
			if ( user.HasPrivilege( SystemPrivilegesItem.ManageTimeLoss.Name ) || user.IsUnrestricted )
				response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_TimeLossSearchingList, "x-list.aspx?OT=TimeLoss&METANAME=TimeLossSearchingListAdm" );
			else
				response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_TimeLossSearchingList, "x-list.aspx?OT=TimeLoss&METANAME=TimeLossSearchingList" );
			// ...отчеты - доступны всем:
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_Reports, String.Empty );
			// ...иерархия "структура компаний" - доступна всем:
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_OrgStructure, String.Empty );
			// ...функция "поиск инцидента" - доступна всем:
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_FindIncident, String.Empty );

			// навигационные элементы СУТа доступны только если есть привилегия "доступ в СУТ"
			if ( user.HasPrivilege( SystemPrivilegesItem.AccessIntoTMS.Name ) || user.IsUnrestricted )
			{
				// ...домашняя страница СУТ
				response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.TMS_HomePage, String.Empty );
				// ...список тендеров
				response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.TMS_TenderList, String.Empty );
			}

			// ...административный интерфейс доступен только "неограниченному" пользователю
			if ( user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name) || user.IsUnrestricted)
				response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_Administation, String.Empty );


			// #3: Корреция стартовой страницы: если заданная страница недоступна,
			// то сбросим указание "собственной" старотовой страницы (пользователь
			// попадет на "домашнюю":
			if (response.NavigationInfo.UseOwnStartPage)
			{
				string sOwnStartPageID = UserNavigationInfo.StartPage2NavItemID( response.NavigationInfo.OwnStartPage );
				if ( null != sOwnStartPageID )
					if ( null == response.NavigationInfo.UsedNavigationItems.GetValues(sOwnStartPageID) )
						sOwnStartPageID = null;
				if ( null == sOwnStartPageID )
					response.NavigationInfo.UseOwnStartPage = false;
			}

			return response;
		}


		/// <summary>
		/// Внутренний метод получения данных объекта UserProfile для пользователя
		/// системы, заданного идентификатором (SystemUser.ObjectID).
		/// </summary>
		/// <param name="uidSystemUserID">Идентификатор пользователя</param>
		/// <returns>
		/// -- Инифиализированный объект DomainObjectData, описывающий данные UserProfile
		/// -- null, если профиля пользователя нет (что, в принципе возможно)
		/// </returns>
		protected DomainObjectData getUserProfile( Guid uidSystemUserID, XStorageConnection connection ) 
		{
			// Получим идентификатор объекта UserProfile, соответствующего 
			// указанному пользователю; для этого воспользуемся запросом, 
			// "зашитым" в data-source:

			// ...параметр запроса - идентификатор пользователя:
			XParamsCollection datasourceParams = new XParamsCollection();
			datasourceParams.Add( "UserID", uidSystemUserID );
			// ...получение и выполнение источника данных:
			XDataSource dataSource = connection.GetDataSource( DEF_DATASOURCE_NAME );
			dataSource.SubstituteNamedParams( datasourceParams, true );
			dataSource.SubstituteOrderBy();
			object oResult = dataSource.ExecuteScalar();
			
			// Ожидается, что в результате мы получаем GUID: если в результате 
			// получили null - что говорит об отсутствии профиля - возвращаем null:
			Guid uidResult = Guid.Empty;
			if (null!=oResult && DBNull.Value!=oResult)
				uidResult = connection.Behavior.CastGuidValueFromDB( oResult );
			if (Guid.Empty == uidResult)
				return null;
			
			// Загрузка данных профиля пользователя:
			DomainObjectDataSet dataSet = new DomainObjectDataSet( connection.MetadataManager.XModel );
			DomainObjectData xobj = dataSet.Load( connection, "UserProfile", uidResult );
			return xobj;			
		}
	}
}