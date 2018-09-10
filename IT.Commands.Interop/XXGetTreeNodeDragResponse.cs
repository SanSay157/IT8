using System;
using System.Xml;
using Croc.XmlFramework.Public;

namespace Croc.XmlFramework.Extension.Commands
{
	/// <summary>
	/// ������, �������������� ������ ���������� ���������� �������� ��������� 
	/// XML-�������� �������� �������� ��� ���� �������� <b>GetTreeNodeDrag</b> 
	/// (��. ���������� �������� XGetTreeNodeDragCommand).
	/// </summary>
	[Serializable]
	public class XXGetNodeDragResponse: XResponse 
	{
		/// <summary>
		/// XML-�������� ����. 
		/// </summary>
		private XSerializableXml m_xmlNodeDrag;
		
		/// <summary>
		/// ����������� �� ���������, �������������� �������� 
		/// XmlNodeDrag ��������� null.
		/// </summary>
		public XXGetNodeDragResponse() 
		{
			XmlNodeDrag = null;
		}
		
		
		/// <summary>
		/// ������������������� �����������.
		/// </summary>
		/// <param name="xmlNodeDrag">
		/// ������� ��������� XML (System.Xml.XmlElement), �������������� 
		/// XML-�������� �������� �������� ��� ���� ��������.
		/// </param>
		public XXGetNodeDragResponse( XmlElement xmlNodeDrag ) 
		{
			XmlNodeDrag = xmlNodeDrag;
		}

		
		/// <summary>
		/// ������� ��������� XML (System.Xml.XmlElement), �������������� 
		/// XML-�������� ���� ��������, ���������� ��������� <b>GetTreeNodeDrag</b> 
        /// (��. ���������� �������� XGetTreeNodeDragCommand) � ������������ � ��������� ����������� �������. 
		/// <para/>
		/// �������� null, ���������� ��� ��������, ���������������� ��� 
		/// XML-�������� �������� ����.
		/// </summary>
		public XmlElement XmlNodeDrag 
		{
			get { return m_xmlNodeDrag; }
			set
			{
				if (null==value)
					m_xmlNodeDrag = new XmlDocument().CreateElement( "i", "node-drag", "urn:x-net-interface-schema.xml" );
				else
					m_xmlNodeDrag = value;
			}
		}
	}
}
