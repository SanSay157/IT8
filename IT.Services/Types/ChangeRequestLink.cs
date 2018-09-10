//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
// Структура, представляющая результат вызова метода создания заявки на обучение
// (создание инцидента типа "Задание на обучение" в специальной папке)
// См. также реализацию метода CreateEducationRequest сервиса CommonService
using System;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// Структура, представляющая данные внешней ссылки, добавляемой в инцидент,
	/// который создается при вызове метода создания заявки на изменение системы 
	/// CMDB <seealso cref="CommonService.CreateChangeRequest"/>
	/// </summary>
	[Serializable]
	public class ChangeRequestLink 
	{
		/// <summary>
		/// Полный URL-адрес объекта CMDB
		/// </summary>
		public string URL = String.Empty;
		
		/// <summary>
		/// Комментарий к ссылке
		/// </summary>
		public string Description = String.Empty;
	}
}
