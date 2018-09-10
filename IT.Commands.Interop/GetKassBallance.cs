using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Класс запроса для команды GetKassBallance
	/// </summary>
	[Serializable]
	public class GetKassBallanceRequest: XRequest
	{

        public GetKassBallanceRequest()
            : base("GetKassBallance")
		{}
	}

    [Serializable]
    public class GetKassBallanceResponse: XResponse
    {
        /// <summary>
        /// Балланс ДС в кассе, приведенный к строке
        /// </summary>
        public string sKassBallance;
    }
}