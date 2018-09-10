//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Xml;
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
	/// Операция получения XML-данных обхекта "Настройки пользователя", 
	/// соответствующих ТЕКУЩЕМУ пользователю. Если объекта не существует, 
	/// операция возвращет шаблон, в котором сразу проставлена ссылка на 
	/// пользователя (SystemUser). Так же в результате представлены данные 
	/// Сотрудника (Employee, по скалярному линку - от SystemUser к Employee)
	/// 
	/// Тип результата - такой же, как и для операции GetObject,
	/// <seealso cref="XGetObjectResponse"/>
	/// </summary>
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetCurrentUserProfileCommand : XCommand 
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
		public XGetObjectResponse Execute( XRequest request, IXExecutionContext context ) 
		{
			// #1: Определяем идентификатор текущего пользователя 
			// Используем внутренние механизмы аутентификации
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			XParamsCollection datasourceParams = new XParamsCollection();
			datasourceParams.Add( "UserID", user.SystemUserID );

			
			// #2: Найдем идентификатор объекта - профиля, связанного с текущим 
			// пользователем: испоьзуем для этого тривиальный запрос, заданный 
			// в "источнике данных" 
			XDataSource dataSource = context.Connection.GetDataSource( DEF_DATASOURCE_NAME );
			dataSource.SubstituteNamedParams( datasourceParams, true );
			dataSource.SubstituteOrderBy();
			object oResult = dataSource.ExecuteScalar();
			// Ожидается, что в результате мы получаем GUID:
			Guid uidResult = Guid.Empty;
			if (null!=oResult && DBNull.Value!=oResult)
				uidResult = context.Connection.Behavior.CastGuidValueFromDB( oResult );

			
			// #3: Загрузка данных профиля и всех сопутствующих объектов:
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			DomainObjectData xobj;

			if (Guid.Empty != uidResult)
			{
				// Объект профиля уже есть; загружаем существующий
				xobj = dataSet.Load(context.Connection, "UserProfile", uidResult);
			}
			else
			{
				xobj = dataSet.CreateNew("UserProfile", false);
				// В новом объекте описания профиля сразу проставляем заглушку на текущего пользователя
				xobj.SetUpdatedPropValue( "SystemUser", user.SystemUserID );
				// Задаем "собственную" стартовую страницу по умолчанию - список текущих инцидентов
				xobj.SetUpdatedPropValue( "StartPage", StartPages.CurrentTaskList );
			}
			// Догружаем данные пользователя (SystemUser) и сотрудника (Employee)
			dataSet.PreloadProperty(context.Connection, xobj, "SystemUser.Employee");

			// Сериализуем датасет с загруженными объектами в формат для Web-клиента
			DomainObjectDataXmlFormatter formatter = new DomainObjectDataXmlFormatter(context.Connection.MetadataManager);
			// ... при этом учитываем, что в сериализованные данные должны так же попасть
			// данные с описанием пользователя и сотрудника:
			XmlElement xmlObject = formatter.SerializeObject( xobj, new string[]{"SystemUser.Employee"} );
			if (Guid.Empty!=uidResult)
			{
				// ..обработаем объект и все вложенные объекты в прогруженных свойства, расставим атрибуты ограничения доступа
				XmlObjectRightsProcessor.ProcessObject(xobj, xmlObject);
			}

			return new XGetObjectResponse(xmlObject);
		}
	}
}