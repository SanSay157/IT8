using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Класс запроса для команды IncidentLocatorInTreeCommand
	/// </summary>
	[Serializable]
	public class ContractLocatorInTreeRequest: XRequest
	{
		/// <summary>
		/// Идентификатор договора
		/// </summary>
		public Guid ContractOID;
		/// <summary>
		/// код проекта
		/// </summary>
		public string ExternalID;

        public ContractLocatorInTreeRequest()
            : base("ContractLocatorInTreeRequest")
		{}

		/// <summary>
		/// Проверка параметров команды
		/// </summary>
		public override void Validate()
		{
			// если IncidentOID и IncidentNumber оба не заданы или оба заданы
			if (ContractOID == Guid.Empty && ExternalID == string.Empty || ContractOID != Guid.Empty && ExternalID != string.Empty)
				throw new ArgumentException("Должен быть задан либо код проекта, либо идентификатор приходного договора");
		}

	}
}
