using System;
using System.Collections;
using System.Security.Principal;
using Croc.IncidentTracker.Storage;

namespace Croc.XmlFramework.Data.Security
{
	/// <summary>
	/// Интерфейс Security-provider'a. 
	/// </summary>
	public interface IXSecurityProvider
	{
		/// <summary>
		/// Конструирует описание пользователя по наименованию.
		/// Если пользователя с таким наименованием не найдено, то возвращает null
		/// </summary>
		/// <param name="sUserName">Наименование пользователя</param>
		/// <returns></returns>
		XUser CreateUser(string sUserName);
		
		/// <summary>
		/// Возвращает экземпляр-описатель анонимного пользователя
		/// </summary>
		/// <returns></returns>
		XUser CreateAnonymousUser();
		
		/// <summary>
		/// Обновляет описание пользователя, которое было сброшено
		/// </summary>
		/// <param name="user">Экземпляр XUser или производный, у которого свойство IsFlushed=true</param>
		void UpdateUser(XUser user);
		
		/// <summary>
		/// Возвращает наименование пользователя по реализации IPrincipal.
		/// </summary>
		/// <remarks>
		/// Занимается только отображением IPrincipal на наименование пользователя. 
		/// Проверяет наличие пользователя приложения уже CreateUser, которому будет передан результат.
		/// </remarks>
		/// <param name="originalPrincipal">principal</param>
		/// <returns>Наименование пользователя приложения</returns>
		string GetUserNameByPrincipal(IPrincipal originalPrincipal);
		
		/// <summary>
		/// Проверка на сохранение объекта в БД, поступившего от клиента, в рамках датаграммы
		/// </summary>
		/// <param name="user">Пользователь, сохраняющий объект</param>
		/// <param name="ex">Описание запрета</param>
		bool HasSaveObjectPrivilege(XUser user, DomainObjectData xobj, out Exception ex);
		
		/// <summary>
		/// Запрос разрешенных действий пользователя над объектом.
		/// Объект уже может содержать данные. Этим данным следует доверять, они получены на стороне сервера.
		/// </summary>
		/// <param name="user">Пользователь</param>
		/// <param name="xobj">Объект, права на который запрашиваются</param>
		/// <returns></returns>
		XObjectRights GetObjectRights(XUser user, DomainObjectData xobj);
		
		/// <summary>
		/// Запрос разрешенных действий при создании объекта
		/// </summary>
		/// <param name="user">Пользователь</param>
		/// <param name="xobj"></param>
		/// <returns></returns>
		XNewObjectRights GetRightsOnNewObject(XUser user, DomainObjectData xobj);

		/// <summary>
		/// Уведомление со стороны XSecurityManager'a об изменившихся объектах
		/// </summary>
		/// <param name="dataSet">Сохраняемое множество объектов</param>
		void TrackModifiedObjects(DomainObjectDataSet dataSet);
		
		/// <summary>
		/// Запрос со стороны XSecurityManager'a наименований пользователей, 
		/// кэш описаний которых должен быть сброшен в результате сохранения переденной коллекции объектов
		/// </summary>
		/// <param name="dataSet">Сохраняемое множество объектов</param>
		/// <param name="users">Коллекция описаний пользователей (IList<XUser>)</param>
		/// <returns>Массив наименований пользователей или null</returns>
		string[] GetAffectedUserNames(DomainObjectDataSet dataSet, ICollection users);
	}
}