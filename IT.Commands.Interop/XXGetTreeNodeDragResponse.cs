using System;
using System.Xml;
using Croc.XmlFramework.Public;

namespace Croc.XmlFramework.Extension.Commands
{
	/// <summary>
	/// ќбъект, представл€ющий данные результата выполнени€ операции получени€ 
	/// XML-описани€ операции переноса дл€ узла иерархии <b>GetTreeNodeDrag</b> 
	/// (см. реализацию операции XGetTreeNodeDragCommand).
	/// </summary>
	[Serializable]
	public class XXGetNodeDragResponse: XResponse 
	{
		/// <summary>
		/// XML-описание меню. 
		/// </summary>
		private XSerializableXml m_xmlNodeDrag;
		
		/// <summary>
		///  онструктор по умолчанию, инициализирует свойство 
		/// XmlNodeDrag значением null.
		/// </summary>
		public XXGetNodeDragResponse() 
		{
			XmlNodeDrag = null;
		}
		
		
		/// <summary>
		/// ѕараметризированный конструктор.
		/// </summary>
		/// <param name="xmlNodeDrag">
		/// Ёлемент документа XML (System.Xml.XmlElement), представл€ющий 
		/// XML-описание операции переноса дл€ узла иерархии.
		/// </param>
		public XXGetNodeDragResponse( XmlElement xmlNodeDrag ) 
		{
			XmlNodeDrag = xmlNodeDrag;
		}

		
		/// <summary>
		/// Ёлемент документа XML (System.Xml.XmlElement), представл€ющий 
		/// XML-описание меню иерархии, получаемое операцией <b>GetTreeNodeDrag</b> 
        /// (см. реализацию операции XGetTreeNodeDragCommand) в соответствии с заданными параметрами запроса. 
		/// <para/>
		/// «начение null, задаваемое дл€ свойства, интерпретируетс€ как 
		/// XML-описание Ђпустогої меню.
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
