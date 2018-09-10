using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Класс запроса для команды IncidentLocatorInTreeCommand
	/// </summary>
	[Serializable]
	public class IncidentLocatorInTreeRequest: XRequest
	{
		/// <summary>
		/// Идентификатор инцидента
		/// </summary>
		public Guid IncidentOID;
		/// <summary>
		/// Номер инцидента
		/// </summary>
		public int IncidentNumber;

		public IncidentLocatorInTreeRequest()
			:base("IncidentLocatorInTree")
		{}

		/// <summary>
		/// Проверка параметров команды
		/// </summary>
		public override void Validate()
		{
			// если IncidentOID и IncidentNumber оба не заданы или оба заданы
			if (IncidentOID == Guid.Empty && IncidentNumber == 0 || IncidentOID != Guid.Empty && IncidentNumber > 0)
				throw new ArgumentException("Должен быть задан либо идентификатор инцидента, либо номер инцидента");
		}

	}
}
