//******************************************************************************
using System.Diagnostics;
using System.Xml;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Commands;

namespace Croc.XmlFramework.Extension.Commands
{
	/// <summary>
	/// ��������� �������� �������� ���� ������ �������� (��� ���� ��������). 
	/// </summary>                                          
	public sealed class XXTreeNodeDrag
	{
		/// <summary>
		/// ������ �� i:node-drag
		/// </summary>
		private XmlElement m_xmlNodeDrag;
		/// <summary>
		/// XmlNamespace-�������� ��� ����������� ���������� XPath-��������
		/// </summary>
		private XmlNamespaceManager m_xmlNSManager;
		/// <summary>
		/// ����� �����������
		/// </summary>
		private XTreeMenuCacheMode m_cacheMode;
		/// <summary>
		/// ������� ������� ��������
		/// </summary>
		private bool m_bIsEmpty;
		/// <summary>
		/// URL ����� ����������
		/// </summary>
		private const string m_sExtensionNamespace = "http://www.croc.ru/Schemas/XmlFramework/Interface/1.0/Extension";

		/// <summary>
		/// ����������� �������� �������� �� ��������� ������������ ������ ��������
		/// </summary>
		/// <param name="treeLevel">��������� ������ ��������</param>
		internal XXTreeNodeDrag(XTreeLevelInfo treeLevel, XMetadataManager manager)
		{
			m_xmlNSManager = treeLevel.NamespaceManager;

			string metaname = treeLevel.Xml.GetAttribute("node-drag", m_sExtensionNamespace);

			if (string.IsNullOrEmpty(metaname))
				metaname = treeLevel.TreeInfo.Xml.GetAttribute("node-drag", m_sExtensionNamespace);

			if (!string.IsNullOrEmpty(metaname))
			{
				string prefix = m_xmlNSManager.LookupPrefix(m_sExtensionNamespace);
				m_xmlNodeDrag = manager.SelectSingleNode(prefix + ":node-drag[@n=\"" + metaname + "\"]") as XmlElement;
			}
			if (m_xmlNodeDrag == null)
			{
				m_bIsEmpty = true;
			}
			else
			{
				m_bIsEmpty = false;
				string sValue = m_xmlNodeDrag.GetAttribute("cache-for");
				if (sValue.Length > 0)
					m_cacheMode = XTreeMenuCacheModeParser.Parse(sValue);
				else
					m_cacheMode = XTreeMenuCacheMode.Unknow;
			}
		}

		/// <summary>
		/// XML-���� �������� �������� (<b>ie:node-drag</b>). ����� ���� null.
		/// </summary>                                     
		public XmlElement XmlNodeDrag
		{
			get { return m_xmlNodeDrag; }
		}

		/// <summary>
		/// ������� ������� ��������. ���� true, ������ ��� ������ �������
		/// ����������� �������� ��������. 
		/// </summary>                                                       
		public bool IsEmpty
		{
			get { return m_bIsEmpty; }
		}

		/// <summary>
		/// ����� ������������ ����.
		/// </summary>              
		public XTreeMenuCacheMode CacheMode
		{
			get { return m_cacheMode; }
			set { m_cacheMode = value; }
		}
	}
}
