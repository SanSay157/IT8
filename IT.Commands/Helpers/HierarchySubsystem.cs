using System;
using System.Collections;
using System.Collections.Specialized;
using System.Reflection;
using System.Xml;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Hierarchy
{
	public class PageFilterDescription
	{
		public string DirectURL;
		public string TypeName;
		public string EditorMetaname;
	}

	/// <summary>
	/// ������� ����� �������� �������� ��������
	/// </summary>
	public abstract class XTreePageInfo
	{
		/// <summary>
		/// ���������������� ��������
		/// </summary>
		public string Name;
		/// <summary>
		/// ��������� ��������
		/// </summary>
		public string Title;
		/// <summary>
		/// ������ ������������ ���������� ��������
		/// </summary>
		public string[] ClientScripts;
		/// <summary>
		/// ������������ stylesheet'a ��� ���������� ����
		/// </summary>
		public string MenuStylesheetFilename;
		/// <summary>
		/// �������� �������
		/// </summary>
		public PageFilterDescription FilterDescription;
		/// <summary>
		/// ������������ ���������� �������� �������� ������ ��������.
		/// ������������� �������� �������� load-cmd �������� �������� ��������
		/// ��������, objects-tree
		/// </summary>
//		public string TreeLoadCommandName = String.Empty;
		/// <summary>
		/// ������������ ���������� �������� �������� ����, �����������
		/// ��� ���� ���� �� ���� ��������. ������������� �������� �������� 
		/// menu-load-cmd �������� �������� �������� ��������, objects-tree
		/// </summary>
//		public string MenuLoadCommandName = String.Empty;
		/// <summary>
		/// ������ ���������� ������
		/// </summary>
		public string IconTemplateURI;
		/// <summary>
		/// ������� "�� ���������� ������"
		/// </summary>
		public bool OffShowIcons;

		public abstract XTreeLoadData GetData(XGetTreeDataRequest request, IXExecutionContext context);

		public abstract XTreeMenuInfo GetMenu(XGetTreeMenuRequest request, IXExecutionContext context);

		public abstract XTreeMenuInfo GetMenuForEmptyTree(XGetTreeMenuRequest request, IXExecutionContext context);
	}

	public interface IXTreePageInfoProvider
	{
		XTreePageInfo CreateTreePageInfo(XmlElement xmlTreePage);
	}

	public sealed class XTreeController
	{
		public static readonly string NAMESPACE_URI = "http://www.croc.ru/Schemas/IncidentTracker/Interface/1.0";
		private XMetadataManager m_mdManager;
		private HybridDictionary m_treePages = new HybridDictionary();
		private IXTreePageInfoProvider m_treePageInfoDefaultProvider;
		private IDictionary m_treePageInfoProviders;				// Dictionary<IXTreePageInfoProvider>

		private static XTreeController m_Instance;
		public static void Initialize(XMetadataManager mdManager)
		{
			m_Instance = new XTreeController();
			m_Instance.initialize(mdManager);
		}
		
		public static XTreeController Instance
		{
			get
			{
				if (m_Instance == null)
					throw new InvalidOperationException("������ XTreeController �� ��� ���������������");
				return m_Instance;
			}
		}

		private XTreeController()
		{}

		private void initialize(XMetadataManager mdManager)
		{
			m_mdManager = mdManager;
			m_treePageInfoDefaultProvider = new XTreePageInfoProviderStd(mdManager);
			m_treePageInfoProviders = new HybridDictionary();
			IXTreePageInfoProvider provider;
			XTreePageInfo treePage;
			string sName;
			foreach(XmlElement xmlTreePage in m_mdManager.SelectNodes("i:objects-tree | i:objects-tree-selector"))
			{
				sName = xmlTreePage.GetAttribute("n");
				if (sName.Length == 0)
					throw new XInvalidMetadataException("�� ������ ������������ ��������: " + xmlTreePage.OuterXml.Substring(0, 100));
				provider = getTreePageInfoProvider(xmlTreePage.GetAttribute("provider", NAMESPACE_URI), sName);
				treePage = provider.CreateTreePageInfo(xmlTreePage);
				m_treePages.Add(sName, treePage);
			}
		}

		public XTreePageInfo GetPageInfo(string sMetaname)
		{
			XTreePageInfo treePage = (XTreePageInfo)m_treePages[sMetaname];
			if (treePage == null)
				throw new ArgumentException("�� ������� �������� �������� � ������������� " + sMetaname);
			return treePage;
		}

		private IXTreePageInfoProvider getTreePageInfoProvider(string sProviderClassName, string sTreePageName)
		{
			IXTreePageInfoProvider provider;
			if (sProviderClassName != null && sProviderClassName.Length > 0)
			{
				if (m_treePageInfoProviders.Contains(sProviderClassName))
					provider = (IXTreePageInfoProvider)m_treePageInfoProviders[sProviderClassName];
				else
				{
					Type type = Type.GetType(sProviderClassName, false, true);
					if (type == null)
						throw new XInvalidMetadataException("��� �������� �������� " + sTreePageName + " �� ������� ������� ��������� ������ provider'a: " + sProviderClassName);
					if (type.GetInterface(typeof(IXTreePageInfoProvider).FullName, true) == null)
						throw new XInvalidMetadataException("��� �������� �������� " + sTreePageName + " ����� ����� provider'a, �� ����������� " + typeof(IXTreePageInfoProvider).FullName);
					ConstructorInfo ctor = type.GetConstructor(new Type[] {typeof(XMetadataManager)});
					// ������� ����������� provider'a
					// TODO: try-catch
					provider = (IXTreePageInfoProvider)ctor.Invoke(new object[] {m_mdManager});
					m_treePageInfoProviders.Add(sProviderClassName, provider);
				}
			}
			else
				provider = m_treePageInfoDefaultProvider;

			return provider;
		}

	}
}