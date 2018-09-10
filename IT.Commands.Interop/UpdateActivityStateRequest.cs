//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

using Croc.IncidentTracker;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Запрос команды изменения состояния активности
	/// </summary>
	[Serializable]
	public class UpdateActivityStateRequest : XRequest
	{
		public UpdateActivityStateRequest() : base("UpdateActivityState") { }

		/// <summary>
		/// Идентификатор активности
		/// </summary>
		public Guid Activity;
		/// <summary>
		/// Новое состояние
		/// </summary>
		public FolderStates NewState;
		/// <summary>
		/// Описание
		/// </summary>
		public string Description;
		/// <summary>
		/// Идентификатор сотрудника, инициатора изменения
		/// </summary>
		/// <remarks>
		/// Guid.Empty - значение не задано
		/// </remarks>
		public Guid Initiator;
	}
}
