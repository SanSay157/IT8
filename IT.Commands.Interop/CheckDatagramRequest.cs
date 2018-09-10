using System;
using System.Xml;
using System.Xml.Serialization;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// 
	/// </summary>
	[Serializable]
	public class CheckDatagramRequest: XRequest
	{
		public XmlElement XmlDatagram;	
		[XmlArrayItem(typeof(XObjectIdentity))]
        public XObjectIdentity[] ObjectsToCheck;
	}
}
