using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ����� ������� ��� ������� GetKassBallance
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
        /// ������� �� � �����, ����������� � ������
        /// </summary>
        public string sKassBallance;
    }
}