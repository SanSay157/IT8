using System;
using System.Collections;
using System.Collections.Specialized;
using System.Collections.Generic;
using System.Data;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Xml;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Hierarchy
{
	sealed class TreeConfigurationHelper
	{
		private TreeConfigurationHelper()
		{}
		/// <summary>
		/// ������� ��� ���������� ��������� ���������� ���������� � �������� ������������� CLR-������.
		/// </summary>
		/// <param name="providersCache">���, � ������� ������ ���������� �����������</param>
		/// <param name="defaultProvider">��������� �� ���������</param>
		/// <param name="sProviderClassName">������ ������������ ������ ����������, ����� ���� null/String.Empty</param>
		/// <param name="sTreePageName">������������ ��������</param>
		/// <param name="sProviderName">������������ ������������ ����������</param>
		/// <param name="requiredInterface">���������, ������� ������ ������������� ���������</param>
		/// <param name="ctorArgTypes">������ ����� ���������� ������������</param>
		/// <param name="ctorArgValues">������ �������� ���������� ������������</param>
		/// <returns></returns>
		public static object getProvider(IDictionary providersCache, object defaultProvider, string sProviderClassName, string sTreePageName, string sProviderName, Type requiredInterface, Type[] ctorArgTypes, object[] ctorArgValues)
		{
			object provider;
			if (sProviderClassName != null && sProviderClassName.Length > 0)
			{
				if (providersCache.Contains(sProviderClassName))
					provider = providersCache[sProviderClassName];
				else
				{
					Type type = Type.GetType(sProviderClassName, false, true);
					if (type == null)
						throw new XInvalidMetadataException("��� �������� �������� " + sTreePageName + " �� ������� ������� " + sProviderName + ": " + sProviderClassName);
					if (type.GetInterface(requiredInterface.FullName, true) == null)
						throw new XInvalidMetadataException("��� �������� �������� " + sTreePageName + " ����� " + requiredInterface + " " + sProviderClassName + ", �� ����������� " + requiredInterface.FullName);
					ConstructorInfo ctor = type.GetConstructor(ctorArgTypes);
					// ������� ����������� provider'a
					// TODO: try-catch
					try
					{
						provider = ctor.Invoke(ctorArgValues);
					}
					catch(Exception ex)
					{
						throw new ApplicationException("������ ��� ������ ������������ ������ " + sProviderClassName + " (" + sProviderName + " �������� �������� " + sTreePageName + ": " + ex.Message, ex);
					}
					providersCache.Add(sProviderClassName, provider);
				}
			}
			else
				provider = defaultProvider;
			return provider;
		}		
	}

	/// <summary>
	/// ����������� ���������� XTreePageInfo, ������������ �������� ��������� �������� � ���� � ����������.
	/// ���������� ����������: 
	///	 IXTreeDataLoadProvider - �������� ������
	///	 IXTreeMenuLoadProvider - �������� ���� (������������ � runtime)
	///	���������� ���������������� XTreePageInfoStdProvider'��. ����� �� �������������� � ������������� �������� ��������� XTreeStructInfo
	/// </summary>
	public class XTreePageInfoStd: XTreePageInfo
	{
		protected IXTreeDataLoadProvider m_dataLoadProvider;
		protected IXTreeMenuDataProvider m_menuDataProvider;
		protected XTreeStructInfo m_treeStruct;
		protected XTreeMenuHandler m_emptyTreeMenu;
		protected XTreeMenuHandler m_defaultLevelMenu;
		protected XParamsCollection m_treeDesignParams;

		public override XTreeLoadData GetData(XGetTreeDataRequest request, IXExecutionContext context)
		{
			addDesignParams(request.Params);
			return m_dataLoadProvider.GetData(request, context, this);
		}

		public override XTreeMenuInfo GetMenu(XGetTreeMenuRequest request, IXExecutionContext context)
		{
			addDesignParams(request.Params);
			return m_menuDataProvider.GetMenu(request, context, this);
		}

		public override XTreeMenuInfo GetMenuForEmptyTree(XGetTreeMenuRequest request, IXExecutionContext context)
		{
			addDesignParams(request.Params);
			return m_menuDataProvider.GetMenuForEmptyTree(request, context, this);
		}

		protected void addDesignParams(XParamsCollection runtimeParams)
		{
			if (m_treeDesignParams != null && m_treeDesignParams.Count > 0)
			{
				foreach(DictionaryEntry entry in (Hashtable)m_treeDesignParams)
					runtimeParams.Add((string)entry.Key, entry.Value);
			}
		}

		/// <summary>
		/// ��������� �������� ������ ��������
		/// </summary>
		public IXTreeDataLoadProvider DataLoadProvider
		{
			get { return m_dataLoadProvider; }
			set { m_dataLoadProvider = value; }
		}

		/// <summary>
		/// ��������� �������� ����
		/// </summary>
		public IXTreeMenuDataProvider MenuDataProvider
		{
			get { return m_menuDataProvider; }
			set { m_menuDataProvider = value; }
		}

		/// <summary>
		/// �������� ��������� ��������
		/// </summary>
		public XTreeStructInfo TreeStruct
		{
			get { return m_treeStruct; }
			set { m_treeStruct = value; }
		}

		/// <summary>
		/// �������� ���� ������ ��������
		/// </summary>
		public XTreeMenuHandler EmptyTreeMenu
		{
			get { return m_emptyTreeMenu; }
			set { m_emptyTreeMenu = value; }
		}

		/// <summary>
		/// �������� ���� �� ��������� ������������ ��� ���� ������ (���� �� �� �������� ���� ����)
		/// </summary>
		public XTreeMenuHandler DefaultLevelMenu
		{
			get { return m_defaultLevelMenu; }
			set { m_defaultLevelMenu = value; }
		}

		/// <summary>
		/// ��������� ����������, ������������ � desing-time (� ����������).
		/// ������ ��������� ������������� ������������� � ��������� ����������, ��������� � �������
		/// </summary>
		public XParamsCollection DesignParams
		{
			get { return m_treeDesignParams; }
			set { m_treeDesignParams = value; }
		}
	}

	public class XTreePageInfoProviderStd: IXTreePageInfoProvider
	{
		private const string ATTR_TreeMenuHandlerFactory = "menu-factory";
		private const string ATTR_TreeDataLoadProvider = "load-provider";
		private const string ATTR_TreeMenuDataProvider = "menu-data-provider";
		protected XMetadataManager m_mdManager;
		protected IXTreeStructInfoProvider m_treeStructInfoDefaultProvider;
		protected IXTreeDataLoadProvider m_treeDataLoadDefaultProvider;
		protected IXTreeMenuHandlerFactory m_treeMenuDefaultHandlerFactory;
		protected IXTreeMenuDataProvider m_treeMenuDataDefaultProvider;
		protected IDictionary m_treeStructInfoProviders;					// Dictionary<IXTreeInfoProvider>
		protected IDictionary m_treeLoadProviders;							// Dictionary<IXTreeLoadProvider>
		protected IDictionary m_treeMenuProviders;							// Dictionary<IXTreeMenuProvider>
		protected IDictionary m_treeMenuDataProviders;						// Dictionary<IXTreeMenuLoadProvider>

		public XTreePageInfoProviderStd(XMetadataManager mdManager)
		{
			if (mdManager == null)
				throw new ArgumentNullException("mnManager");
			m_mdManager = mdManager;
			m_treeStructInfoDefaultProvider = new XTreeStructInfoProviderStd(mdManager);
			m_treeDataLoadDefaultProvider = new XTreeDataLoadProviderStd();
			m_treeMenuDefaultHandlerFactory = new XTreeMenuHandlerFactoryStd(mdManager);
			m_treeMenuDataDefaultProvider = new XTreeMenuDataProviderStd();
			m_treeStructInfoProviders = new HybridDictionary();
			m_treeLoadProviders = new HybridDictionary();
			m_treeMenuProviders = new HybridDictionary();
			m_treeMenuDataProviders = new HybridDictionary();
		}

		public virtual XTreePageInfo CreateTreePageInfo(XmlElement xmlTreePage)
		{
			XTreePageInfoStd treePage = new XTreePageInfoStd();
			initTreePageInfo(treePage, xmlTreePage);
			return treePage;
		}

		protected void initTreePageInfo(XTreePageInfoStd treePage, XmlElement xmlTreePage)
		{
			string sCustomPrefix = m_mdManager.NamespaceManager.LookupPrefix(String.Intern(XTreeController.NAMESPACE_URI));

			treePage.Name = xmlTreePage.GetAttribute("n");

			XmlElement xmlTreeStruct = (XmlElement)xmlTreePage.SelectSingleNode("i:tree-struct", m_mdManager.NamespaceManager);
			if (xmlTreeStruct == null)
				throw new XInvalidMetadataException("�������� '" + treePage.Name + "' �� �������� �������� ���������");
			//treePage.TreeLoadCommandName = xmlTreePage.GetAttribute("load-cmd");
			//treePage.MenuLoadCommandName = xmlTreePage.GetAttribute("menu-load-cmd");
			treePage.IconTemplateURI = xmlTreePage.GetAttribute("icon-template");
			if (treePage.IconTemplateURI.Length == 0)
				treePage.IconTemplateURI = "x-get-icon.aspx?OT={T}&SL={S}&BIN=1";
			treePage.OffShowIcons = xmlTreePage.GetAttribute("off-icons") == "1";

			// ��������� ��������� �������� ������
			treePage.DataLoadProvider = getTreeDataLoadProvider(xmlTreePage.GetAttribute(ATTR_TreeDataLoadProvider, XTreeController.NAMESPACE_URI), treePage.Name);

			// ��������� ��������� �������������� ����
			IXTreeMenuHandlerFactory menuFactory = getTreeMenuHandlerFactory(xmlTreePage.GetAttribute(ATTR_TreeMenuHandlerFactory, XTreeController.NAMESPACE_URI), treePage.Name);
			//treePage.MenuProvider = menu_prv;
			XmlElement xmlTreeMenu = (XmlElement)xmlTreePage.SelectSingleNode(sCustomPrefix + ":empty-tree-menu", m_mdManager.NamespaceManager);
			// �� ����� ��������� ���� - ������ ����������� ���� � �������� ���������
			if (xmlTreeMenu == null)
			{
				xmlTreeMenu = (XmlElement)xmlTreeStruct.SelectSingleNode("i:empty-tree-menu", m_mdManager.NamespaceManager);
			}
			treePage.EmptyTreeMenu = menuFactory.CreateMenuHandler(xmlTreeMenu);
			xmlTreeMenu = (XmlElement)xmlTreePage.SelectSingleNode(sCustomPrefix + ":default-level-menu", m_mdManager.NamespaceManager);
			// �� ����� ��������� ���� - ������ ����������� ���� � �������� ���������
			if (xmlTreeMenu == null)
			{
				xmlTreeMenu = (XmlElement)xmlTreeStruct.SelectSingleNode("i:default-level-menu", m_mdManager.NamespaceManager);
			}
			treePage.DefaultLevelMenu = menuFactory.CreateMenuHandler(xmlTreeMenu);

			// ��������� ��������� �������� ����
			treePage.MenuDataProvider = getTreeMenuDataProvider(xmlTreePage.GetAttribute(ATTR_TreeMenuDataProvider, XTreeController.NAMESPACE_URI), treePage.Name);

			// ������� ��������� ������������ ������������ ��������� ��������..
			IXTreeStructInfoProvider prv = getTreeStructInfoProvider(xmlTreeStruct.GetAttribute("provider", XTreeController.NAMESPACE_URI), treePage.Name);
			// .. � �������� � ���� �������� ���������
			treePage.TreeStruct = prv.CreateTreeStructInfo(xmlTreeStruct, menuFactory);

			XmlElement xmlParams = (XmlElement)xmlTreePage.SelectSingleNode( String.Format("i:params | {0}:params", sCustomPrefix), m_mdManager.NamespaceManager);
			if (xmlParams != null)
				xmlParams = Croc.XmlFramework.XUtils.XmlUtils.RemoveSchemaLinksAndPrefixes(xmlParams);
            treePage.DesignParams = XParamsCollectionBuilder.AppendFromXml(treePage.DesignParams, xmlParams, true);
    	}

		protected IXTreeStructInfoProvider getTreeStructInfoProvider(string sProviderClassName, string sTreePageName)
		{
			return (IXTreeStructInfoProvider)TreeConfigurationHelper.getProvider(m_treeStructInfoProviders, m_treeStructInfoDefaultProvider, sProviderClassName, sTreePageName, "��������� ��������� ��������", typeof(IXTreeStructInfoProvider), new Type[] {typeof(XMetadataManager)}, new object[] {m_mdManager});
		}

		protected IXTreeDataLoadProvider getTreeDataLoadProvider(string sProviderClassName, string sTreePageName)
		{
			return (IXTreeDataLoadProvider)TreeConfigurationHelper.getProvider(m_treeLoadProviders, m_treeDataLoadDefaultProvider, sProviderClassName, sTreePageName, "��������� ������ ��������", typeof(IXTreeDataLoadProvider), Type.EmptyTypes, new object[0]);
		}

		protected IXTreeMenuHandlerFactory getTreeMenuHandlerFactory(string sProviderClassName, string sTreePageName)
		{
			return (IXTreeMenuHandlerFactory)TreeConfigurationHelper.getProvider(m_treeMenuProviders, m_treeMenuDefaultHandlerFactory, sProviderClassName, sTreePageName, "��������� ������������ ����", typeof(IXTreeMenuHandlerFactory), new Type[] {typeof(XMetadataManager)}, new object[] {m_mdManager});
		}

		protected IXTreeMenuDataProvider getTreeMenuDataProvider(string sProviderClassName, string sTreePageName)
		{
			return (IXTreeMenuDataProvider)TreeConfigurationHelper.getProvider(m_treeMenuDataProviders, m_treeMenuDataDefaultProvider, sProviderClassName, sTreePageName, "��������� �������� ������ ����", typeof(IXTreeMenuDataProvider), Type.EmptyTypes, new object[0]);
		}
	}

	public interface IXTreeStructInfoProvider
	{
		XTreeStructInfo CreateTreeStructInfo(XmlElement xmlTreeStruct, IXTreeMenuHandlerFactory menuHandlerFactory);
	}
	
	public class XTreeStructInfoProviderStd : IXTreeStructInfoProvider
	{
		protected XMetadataManager m_mdManager;
		protected IDictionary m_allLevels;					// Dictionary<XTreeLevelInfoITRef>
		protected IXTreeStructExecutor m_treeStructDefaultExecutor;
		protected IXTreeLevelExecutor m_treeLevelDefaultExecutor;
		protected IDictionary m_treeStructExecutors;
		protected IDictionary m_treeLevelExecutors;

		public XTreeStructInfoProviderStd(XMetadataManager mdManager)
		{
			m_mdManager = mdManager;
			m_treeStructDefaultExecutor = new XTreeStructExecutorStd();
			m_treeLevelDefaultExecutor = new XTreeLevelExecutorStd();
			m_treeStructExecutors = new HybridDictionary();
			m_treeLevelExecutors = new HybridDictionary();
		}

		//		private void initialize()
		//		{
		//			// �������� ���������� �������
		//			foreach(XmlElement xmlTreeLevel in m_mdManager.SelectNodes("i:tree-level"))
		//			{
		//				if (xmlTreeLevel.Attributes["n"] == null)
		//					throw new XInvalidMetadataException("��� ��������� �������� tree-level �� ������ ������������ (������� n): " + xmlTreeLevel.OuterXml.Substring(0, 100) + "...");
		//				XTreeLevelInfoIT treeLevelInfo = CreateTreeLevelInfo(xmlTreeLevel);
		//				m_levels.Add(xmlTreeLevel.Attributes["n"].Value, treeLevelInfo);
		//			}
		//
		//			// �������� ���������� ��������
		//			foreach(XmlElement xmlTreeStruct in m_mdManager.SelectNodes("i:tree-struct"))
		//			{
		//				if (xmlTreeStruct.Attributes["n"] == null)
		//					throw new XInvalidMetadataException("��� ��������� �������� tree-struct �� ������ ������������ (������� n): " + xmlTreeStruct.OuterXml.Substring(0, 100) + "...");
		//				XTreeStructInfo treeStructInfo = createTreeInfo(xmlTreeStruct);
		//				m_treeStructs.Add(xmlTreeStruct.Attributes["n"].Value, treeStructInfo);
		//			}
		//		}

		public virtual XTreeStructInfo CreateTreeStructInfo(XmlElement xmlTreeStruct, IXTreeMenuHandlerFactory menuHandlerFactory)
		{
			XTreeStructInfo treeStruct;
			IXTreeStructExecutor executor = (IXTreeStructExecutor)TreeConfigurationHelper.getProvider(
					m_treeStructExecutors,
					m_treeStructDefaultExecutor,
					xmlTreeStruct.GetAttribute("executor", XTreeController.NAMESPACE_URI),
					xmlTreeStruct.GetAttribute("n"),
					"struct-executor",
					typeof(IXTreeStructExecutor),
					Type.EmptyTypes,
					new object[0]
				);
			m_allLevels = new HybridDictionary();
			XTreeLevelInfoIT[] roots = getRoots(xmlTreeStruct, menuHandlerFactory);
			treeStruct = createTreeStructInfoInternal(xmlTreeStruct, roots, executor);
			return treeStruct;
		}

		protected XTreeStructInfo createTreeStructInfoInternal(XmlElement xmlTreeStruct, XTreeLevelInfoIT[] roots, IXTreeStructExecutor executor)
		{
			XTreeStructInfo treeStruct;
			if (xmlTreeStruct.HasAttribute("descriptor", XTreeController.NAMESPACE_URI))
			{
				Type type = Type.GetType(xmlTreeStruct.GetAttribute("descriptor", XTreeController.NAMESPACE_URI), false, true);
				if (type == null)
					throw new XInvalidMetadataException("��� �������� ��������� �������� �� ������� ������� ��������� ������ descriptor'a: " + xmlTreeStruct.GetAttribute("descriptor"));
				if (!type.IsSubclassOf(typeof(XTreeStructInfo)))
					throw new XInvalidMetadataException("��� �������� ��������� �������� ����� ������ descriptor'a, �� ����������� �� " + typeof(XTreeStructInfo).FullName);
				// TODO: �������� ��������� ������������
				ConstructorInfo ctor = type.GetConstructor(new Type[] {typeof(string), typeof(XTreeLevelInfoIT[]), typeof(IXTreeStructExecutor)});
				if (ctor == null)
					throw new XInvalidMetadataException("��� �������� ��������� �������� ����� ������ descriptor'a, �� ���������� ������������ � ���������� ctor(string,XTreeLevelInfoIT[],XTreeStructExecutor): " + type.FullName);
				// ������� ����������� ��������� ��������� ��������
				// TOD: try-catch
				treeStruct = (XTreeStructInfo)ctor.Invoke(new object[] {xmlTreeStruct, m_mdManager, this});
			}
			else
				treeStruct = new XTreeStructInfo(xmlTreeStruct.GetAttribute("n"), roots, executor);
			return treeStruct;
		}

		protected XTreeLevelInfoIT[] getRoots(XmlElement xmlTreeStruct, IXTreeMenuHandlerFactory menuHandlerFactory)
		{
			// ��������� ������ ��������� ������������� �������� �������� �������:
			XmlNodeList xmlLevels = xmlTreeStruct.SelectNodes( "i:tree-level", m_mdManager.NamespaceManager);
			XTreeLevelInfoIT[] roots = getTreeLevels(xmlLevels, menuHandlerFactory);
			return roots;
		}

		protected XTreeLevelInfoIT[] getTreeLevels(XmlNodeList xmlLevels, IXTreeMenuHandlerFactory menuHandlerFactory)
		{
			XTreeLevelInfoIT[] levels = new XTreeLevelInfoIT[xmlLevels.Count];
			int i = -1;
			XTreeLevelInfoIT levelInfo;
			foreach ( XmlElement xmlTreeLevel in xmlLevels )
			{
				if (xmlTreeLevel.HasAttribute("treelevel-ref"))
					levelInfo = (XTreeLevelInfoIT)m_allLevels[xmlTreeLevel.GetAttribute("treelevel-ref")];
				else
					levelInfo = createTreeLevelInfo(xmlTreeLevel, menuHandlerFactory);
				levels[++i] = levelInfo;
				if (levelInfo.Name != null && levelInfo.Name.Length > 0 && !m_allLevels.Contains(levelInfo.Name))
					m_allLevels.Add(levelInfo.Name, levelInfo);
			}
			return levels;
		}

		protected XTreeLevelInfoIT createTreeLevelInfo(XmlElement xmlTreeLevel, IXTreeMenuHandlerFactory menuHandlerFactory)
		{
			string sLevelName = xmlTreeLevel.GetAttribute("n");
			if (sLevelName.Length == 0)
				sLevelName = Guid.NewGuid().ToString().ToLower();
			IXTreeLevelExecutor executor = (IXTreeLevelExecutor)TreeConfigurationHelper.getProvider(
				m_treeLevelExecutors,
				m_treeLevelDefaultExecutor,
				xmlTreeLevel.GetAttribute("executor", XTreeController.NAMESPACE_URI),
				String.Empty,
				"tree-level executor",
				typeof(IXTreeLevelExecutor),
				Type.EmptyTypes,
				new object[0]
				);

			string sDataSourceName = Guid.NewGuid().ToString().ToLower();
			// �������� ������ ���������� ������ (data-source), � �������� ��� 
			// ��� ��������������� ������������� � ������ data-source'��, 
			// � XModel (� ���� �������� ��� ���� ����������):
			XmlNodeList xmlDataSources = xmlTreeLevel.SelectNodes( "ds:data-source", m_mdManager.NamespaceManager );
			XDataSourceInfo[] dsInfoArray = new XDataSourceInfo[xmlDataSources.Count];
			int i = -1;
			foreach ( XmlElement xmlDS in xmlDataSources )
				dsInfoArray[++i] = new XDataSourceInfo( xmlDS, m_mdManager.NamespaceManager );
			m_mdManager.XModel.DataSources.Add( sDataSourceName, dsInfoArray );
			XTreeLevelInfoIT levelInfo = new XTreeLevelInfoIT(sLevelName, executor, m_mdManager.XModel.DataSources, sDataSourceName);

			levelInfo.IsRecursive = xmlTreeLevel.HasAttribute("recursive");
			levelInfo.ObjectType = xmlTreeLevel.GetAttribute("ot");
			levelInfo.IsVirtual = xmlTreeLevel.HasAttribute("virtual");
			levelInfo.Alias = xmlTreeLevel.GetAttribute("alias");

			// �������������� ����
			XmlElement xmlLevelMenu = (XmlElement)xmlTreeLevel.SelectSingleNode("i:level-menu", m_mdManager.NamespaceManager);
			levelInfo.MenuHandler = menuHandlerFactory.CreateMenuHandler(xmlLevelMenu);

			// �������� �������� ���� ����������� ������� - ��� ������� 
			// ������� �����. ��������� �������� � ��������� � �������:
			XmlNodeList xmlLevels = xmlTreeLevel.SelectNodes( "i:tree-level", m_mdManager.NamespaceManager );
			XTreeLevelInfoIT[] childTreeLevels = getTreeLevels(xmlLevels, menuHandlerFactory);
			levelInfo.ChildTreeLevelsInfoMetadata = childTreeLevels;
			return levelInfo;
		}
	}


	/// <summary>
	/// ������ ������ ���� ������
	/// </summary>
/*	[Serializable]
	public class XTreeNodeLoadData
	{
		public Guid ObjectID;
		public String ObjectType;
		public String Title;
		public String IconSelector;
		public bool IsLeaf;
		public IDictionary UserData = new HybridDictionary();
	} */
	
	/// <summary>
	/// ������ ��������� ����� ������ (��������� ������� �������� ������ ������)
	/// </summary>
	[Serializable]
	public class XTreeLoadData
	{
        public List<XTreeNode> Nodes = new List<XTreeNode>();		// List<XTreeNodeLoadData>

		/// <summary>
		/// ���������� ���������� �����
		/// </summary>
		public int NodesCount
		{
			get { return Nodes.Count; }
		}

		/// <summary>
		/// ��������� �������� ����� �� ����������� ��������� � �������
		/// </summary>
		/// <param name="data"></param>
		public void Append(XTreeLoadData data)
		{
			if (data == null)
				return;
			if (data.NodesCount == 0)
				return;
			foreach (XTreeNode nodeData in data.Nodes)
			{
				Nodes.Add(nodeData);
			}
		}
	}

	/// <summary>
	/// ��������� ���������� �������� ������ ��������. ������������ XTreePageInfoStd � XTreeStructInfoProvider
	/// </summary>
	public interface IXTreeDataLoadProvider
	{
		XTreeLoadData GetData(XGetTreeDataRequest request, IXExecutionContext context, XTreePageInfoStd treePage);
	}

	public class XTreeDataLoadProviderStd: IXTreeDataLoadProvider
	{
		public virtual XTreeLoadData GetData(XGetTreeDataRequest request, IXExecutionContext context, XTreePageInfoStd treePage)
		{
			XTreeStructInfo treeStructInfo = treePage.TreeStruct;
			XTreeLevelInfoIT[] treelevels = getTreeLevels(treeStructInfo, request.Action, request.Params, request.Path);
			XTreeLoadData treeData = new XTreeLoadData();
			foreach(XTreeLevelInfoIT treelevel in treelevels)
			{
				XDataSource datasource = createTreeLevelDataSource(treelevel, context.Connection, request);
				// ���������� xml � ������� CROC.XTreeView
                if (treeData == null)
                    throw new Exception("treeData");
                if (datasource == null)
                    throw new Exception("datasource");
                if (treelevel == null)
                    throw new Exception("treelevel");
                if (request == null)
                    throw new Exception("request");
				readTreeData(treeData, datasource, treelevel, request );
			}
			// TODO: post-processor'� ������

			return treeData;
		}

		#region ���������� XDataSource (copy-paste �� XGetTreeDataCommand)
		/// <summary>
		/// ������� �������� ��������� ������ ��� ������ ��������.
		/// ��� ������ ���������� GETROOT � GETCHILDREN �������� ����������� 
		/// ��������� ���������� data-source'a XDataSource.SubstituteNamedParams
		/// ��������� ������� GETNODE ������� ���������� �� ������ GETROOT/GETCHILDREN
		/// </summary>
		/// <param name="treelevel">�������� ������</param>
		/// <param name="con">���������� � ��</param>
		/// <param name="treeRequest">�������� ������</param>
		protected virtual XDataSource createTreeLevelDataSource(XTreeLevelInfoIT treelevel, XStorageConnection con, XGetTreeDataRequest treeRequest )
		{
			string sCmdText;				// ����� �������
			string sValue;					// �������� �������/�������
			string sAlias = String.Empty;	// �����/������������ �������
			int nRecursiveLevel;			// ������� �������� (�� 0)
			Guid requestObjectID;			// ������������� ������������ ���� ��� GETNODE ��� Guid.Empty ��� GETROOT/GETCHILDREN

			XDataSource datasource = treelevel.GetDataSource(con);
			sCmdText = datasource.DbCommand.CommandText.Trim();
			requestObjectID = Guid.Empty;
			if (treeRequest.Action == XTreeAction.GetNode)
			{
				// ��� ������� ��������� ���� ��������� ���������.
				if (treelevel.IsVirtual)
				{
					// ���� ���� �����������.
					// �.�. ����������� ���� ����� ���������� �� ����������������, �� ������� ������� SEARCH_CONDITIONS/WHERE_CLAUSE
					sCmdText.Replace("WHERE_CLAUSE", "").Replace("SEARCH_CONDITIONS", " 0=0 ");
				}
				else
				{
					// ���� ���� �� �����������, �� ��� ���� ������������ ������� 
					// WHERE table.ObjectID = '������������� � treeRequest.NodeID(0)'
					// ��� ���� ������� ��������� ������� �����������.
					if (sCmdText.IndexOf("@@OBJECT_ID")>0)
					{
						// ���� ���� ������ @@OBJECT_ID, �� ��� ������
						sCmdText = sCmdText.Replace("@@OBJECT_ID", con.GetParameterName("RequestedOID") );
						// ��������� ������� ������� �����������, ���� �� ��������
						// ���� ��� ������� SEARCH_CONDITIONS, �� ��� ������������� ������, �.�. ���������� ������� ����:
						// WHERE �����-��_������� OR Object = @@OBJECT_ID, ����� �� �� ����� ������� "�����-��_�������" ����������,
						// �.�. ��� ������ ������������ - ������ ��� �� ����
						if (sCmdText.IndexOf("SEARCH_CONDITIONS") == -1)
							throw new XTreeStructException("��������� ������� ������� ��� data-source: ���� ����� ������� @@OBJECT_ID, �� ������ ���� ����� ����� ������ SEARCH_CONDITIONS, ����� ���������� ������������ ������� ��� ������� ��������� ���������� ����");
						// (OBJECT_ID ������ ���� �������� ����� OR � ���������� ���������)
						sCmdText = sCmdText.Replace("SEARCH_CONDITIONS", " 1=0 ");
						// ����������: ������� WHERE_CLAUSE ����� ���� �� �����
					}
                       
					else if (!datasource.DataSourceInfo.Params.ContainsKey("RequestedOID"))
					{
						// ������ @@OBJECT_ID �� ����� � �� �������������� �������� RequestedOID, ���� �� �� ���������� ��. ����������� ����, 
						// ������� ��������� ������������ ������� <���>.ObjectID = '�������������_����������_�������' ������ ������� WHERE_CLAUSE,
						// � ���� ����� ������� ���, �� ������������� ������ ������������ - ���������� ���������

						// ��� ������������� ������� ������� ����� ��� ��� ����
						sAlias = treelevel.Alias;
						if (sAlias.Length == 0)
							sAlias = treelevel.ObjectType;
						// ���������� ������� �� ��������� �������, ���������������� ��������� ���� ������ (������ � ����)
						sValue = String.Format("{0}.ObjectID = {1}", sAlias, con.GetParameterName("RequestedOID") );
						// ���� ������� WHERE_CLAUSE ���, �� ����� �������� �� ��������� ��������� ������
						if (sCmdText.IndexOf("WHERE_CLAUSE") == -1)
							throw new XTreeStructException("��������� ������� ������� ��� data-source: ���� �� ����� ������ @@ObjectID, �� ������ ���� ����� ������ WHERE_CLAUSE, ����� ���������� ������������ ������� ��� ������� ��������� ���������� ����");
						// ���� �����, ������ WHERE_CLAUSE ����.
						sCmdText = sCmdText.Replace("WHERE_CLAUSE", " WHERE " + sValue);
					}
					requestObjectID = treeRequest.Path[0].ObjectID;
					// ������� � ADO-������� �������� � ��������������� ������������ �������
					datasource.DbCommand.Parameters.Add("RequestedOID", DbType.Guid, ParameterDirection.Input, false, requestObjectID);
				}
			}
			else
			{
				// ������� ������� @@OBJECT_ID �� ������� ���� - �� ����� ������ ��� ������� ��������� ���� (GET_NODE)
				// ����������: ������� @@OBJECT_ID ����� � ������ ������� � �� ����, ������� �� ���������� ���������
				// ��������: � �������� �������� ������� ��������� ������: '00000000-0000-0000-0000-000000000000' AND 1=0,
				// ������� 1=0 ����������� ��-�� ����������� ������������������ ��� ��������� ����� �������, ������������ ����� OR
				sCmdText = sCmdText.Replace("@@OBJECT_ID", con.ArrangeSqlGuid(Guid.Empty) + " AND 1=0");
			}
			// ������� � ADO-������� �������� � ��������������� ������������ �������
			if (datasource.DataSourceInfo.Params.ContainsKey("RequestedOID"))
				if (!treeRequest.Params.Contains("RequestedOID"))
				{
					if (requestObjectID == Guid.Empty )
						treeRequest.Params.Add("RequestedOID", null);
					else
						treeRequest.Params.Add("RequestedOID", requestObjectID);
				}
				else
				{
					if (requestObjectID == Guid.Empty)
						treeRequest.Params["RequestedOID"] = null;
					else
						treeRequest.Params["RequestedOID"] = requestObjectID;
				}

			datasource.DbCommand.CommandText = sCmdText;
			// �����: param-selector ����� ��������� ������� � �������, ����������� �����
			// ������� ����������� ��������� ����������
			if (treeRequest.Params != null)
                datasource.SubstituteNamedParams(XParamsCollection.ToHashtable(treeRequest.Params), true);
			else
				datasource.SubstituteNamedParams(new Hashtable(), true);
			
			// ��������� ������� ����������
			datasource.SubstituteOrderBy();
           
			nRecursiveLevel = getRecurrenceLevel(treelevel, treeRequest);
			// �������� ������ @@ISLEAF - ������� ��������� ����
			evaluateIsLeafMacro(treelevel, datasource, treeRequest);
			// �������� ������� @@RecursiveExp - ������������ ������� ����������� ��������. 
			// �����: ������� ������ ����������� ����� ����������� @@ParentID, 
			// �.�. ��� ������ �������� ������ 0 ����������� � ������ ���������� � @@ParentID
			evaluateRecursiveExp(treelevel, datasource.DbCommand, nRecursiveLevel);
			// �������� ������� @@PARENTID - ���������� ������������� ������� �� ������� ������ �� �������� (1-����,2-���,� �.�.)
			evaluateParentIdFunc(datasource.DbCommand, treeRequest);
			// �������� ������� @@ParentIDByType - ���������� ������������� ������� �������� ���� - 
			// �������, �������������� ��� ������� �� ���� �� ������������ ���� �� �����
			evaluateParentIDByTypeFunc(datasource.DbCommand, treeRequest);
			// �������� ������ @@RC - ������� ��������
			// �����: ����������� �������� @@RC ���� ����� ����������� order-by, �.�. ��������� ���������� ����� ��������� @@RC
			evaluateRecurLevelMacro(datasource.DbCommand, nRecursiveLevel );
			return datasource;
		}

		/// <summary>
		/// ����������� � ������� (������) ������� �� ���������� �������� ��������� ���� (������ @@ISLEAF).
		/// ���� ������ �����������, �� ����� ������� �� ��������������.
		/// </summary>
		/// <param name="treelevel"></param>
		/// <param name="datasource"></param>
		/// <param name="treeRequest">������</param>
		protected virtual void evaluateIsLeafMacro(XTreeLevelInfoIT treelevel, XDataSource datasource, XGetTreeDataRequest treeRequest)
		{
			string sCmdIsLeafText;	// ����� ������� (�������) ��� ���������� ������� �������������� ���� (ISLEAF)
			string sCmdInnerText;	// ����� ������� ���������� tree-level'� � �������
			string sValue;			// �������� �������/�������
			Regex RegExp;			// ��� ������ @@ISLEAF
			Regex RegExpInner;		// ��� ������ @@ISLEAF � �����������
			int nRecurLevel;		// ������� ��������
			string sParentTable;	// ������ �� ������� �������� ���� �� ��������� ����������
			int nRecurLevelCurrent;	// ������� �������� ���������� data-source'a
			XStorageConnection con;	// ����������

			// �������� ������� ��������� ���� - ������� @@ISLEAF. 
			// ��� ����� ���� ������� ������� data-source'�� ���� ����������� �������� tree-level'��
			// (������� tree-level - ��� �������� ����������� data-source'� (xmlDataSource))
			// ������� ��� ����� ����� � ������, ���� � ������� data-source ���� �������-������ @@ISLEAF 
			// (�� ����� �� ����, ���� ����������� ��� ������� ������� ��� IsLeaf)
			RegExp = new Regex("@@ISLEAF", RegexOptions.IgnoreCase);
			Match match = RegExp.Match(datasource.DbCommand.CommandText);
			if (match.Success)
			{
				sCmdIsLeafText = String.Empty;
				// ���� ��������� ������� �������� ���������� data-source'a.
				// ������� ������� �������� �������� ������
				nRecurLevelCurrent = getRecurrenceLevel( treelevel, treeRequest );
				con = datasource.DbCommand.Connection;
				// �� ���� tree-level'�� ����������� �������� ������ (�� ����� ���� ���������)
				foreach(XTreeLevelInfoIT treelevel_child in treelevel.GetChildTreeLevelsAffected(treeRequest.Params))
				{
					XDataSource datasource_child = treelevel_child.GetDataSource(con);
					datasource_child.SubstituteNamedParams((Hashtable)treeRequest.Params, true);
					// ��������: ��� ����������� ����� ��� �� ����� ������� �������������� (ISLEAF), 
					// ����� ���� ���� ������������� ��������. ������� ������� ������-������� @@ISLEAF �� 0.
					RegExpInner = new Regex("@@ISLEAF", RegexOptions.IgnoreCase);
					datasource_child.DbCommand.CommandText = RegExpInner.Replace(datasource_child.DbCommand.CommandText, "0 AS IS_LEAF");

					// ���������� ������� @RC
					nRecurLevel = nRecurLevelCurrent;
					// ���� ��� ���������� ������ ����� ��, ��� �������, �� �������� �������� ������ �������� �� 1
					// ��� ������, ��� � treeRequest'e �� ���������� ������ xmlDataSourceChild
					if (treelevel_child.ObjectType == treelevel.ObjectType)
					{
						nRecurLevel ++;
					}
					evaluateRecurLevelMacro(datasource_child.DbCommand, nRecurLevel);
					evaluateRecursiveExp(treelevel_child, datasource_child.DbCommand, nRecurLevel);
					// ���������� �-��� @@PARENTID. ���� ��������� data-source ������������ @@ParentID(1), ������ ��
					// ��������� �� ������� �������.
					RegExpInner = new Regex(@"@@PARENTID\s*\(\s*(\d+)\s*\)", RegexOptions.IgnoreCase);
					foreach(Match matchInner in RegExpInner.Matches(datasource_child.DbCommand.CommandText))
					{
						GroupCollection groups = matchInner.Groups;
						int nArg = Int32.Parse( groups[1].Value );
						if (!(nArg > 0))
							throw new XTreeStructException("�������� ��������� ������� @@ParentID ������ ���� ������ 0");
						// ������������� �������� ������� @@ParentID �.�., ����� �� ���� �������� ���� � ����, ���������� � ��������
						if (treeRequest.Action == XTreeAction.GetChildren)
							nArg -= 2;
						else if (treeRequest.Action == XTreeAction.GetNode)
							nArg -= 1;
						else if (nArg > 1)
							// ���� ����������� ��������� (�.�. treeRequest.Action == TreeAction.GET_ROOT) 
							// ��������� �� ���-�� �� @@ParentID(2)
							throw new XTreeStructException("������� @@ParentID ����� ������������ ��������: " + nArg.ToString());
						if (nArg >= 0 && treeRequest.Action != XTreeAction.GetRoot)
						{
							// �� ��� ����� ����������� �������������
							sValue = con.ArrangeSqlGuid(treeRequest.Path[nArg].ObjectID);
						}
						else
						{
							// ����������� data-source ��������� �� �������.
							// ��������������� �� ��� �� �����, ������� �������� �� �������� �� ������, ���� �� ����� �������.
							sParentTable = treelevel.Alias;
							if (sParentTable.Length==0)
								sParentTable = treelevel.ObjectType;
							if (treelevel.IsRecursive)
							{
								// ���� ������� ������� (�.�. ��� �������, ��� �������� �� ��������� ������ @IS_LEAF) �����������,
								// �� ������ � ������� ��� ������ �� ���� ���� �������� ������ ��������.
								if (nRecurLevelCurrent > 0)
									sParentTable = sParentTable + nRecurLevelCurrent.ToString();
							}
							sValue = sParentTable + ".ObjectID";
						}
						datasource_child.DbCommand.CommandText = datasource_child.DbCommand.CommandText.Replace(matchInner.Value, sValue);
					}

					// ������ ���������� ������� @@OBJECT_ID, SEARCH_CONDITIONS, WHERE_CLAUSE:
					// � ������ ������ ��� ��� �� ����� - @@OBJECT_ID ������� �� ������� ����, � SEARCH_CONDITIONS, WHERE_CLAUSE ������ ������
					RegExpInner = new Regex("@@OBJECT_ID", RegexOptions.IgnoreCase);
					sCmdInnerText = datasource_child.DbCommand.CommandText;
					// ��������: � �������� �������� ������� @@OBJECT_ID ��������� ������: '00000000-0000-0000-0000-000000000000' AND 1=0,
					// ������� 1=0 ����������� ��-�� ����������� ������������������ ��� ��������� ����� �������, ������������ ����� OR
					sCmdInnerText = RegExpInner.Replace( sCmdInnerText, con.ArrangeSqlGuid(Guid.Empty) + " AND 1=0");
					sCmdInnerText = sCmdInnerText.Replace("SEARCH_CONDITIONS", " 1=1 ");
					sCmdInnerText = sCmdInnerText.Replace("WHERE_CLAUSE", String.Empty);
					// ��������� ������� � ����������
					if (sCmdIsLeafText != String.Empty)
						sCmdIsLeafText = String.Format("{0} OR EXISTS ({1})", sCmdIsLeafText, sCmdInnerText);
					else
						sCmdIsLeafText = String.Format(" EXISTS ({0}) ", sCmdInnerText);
					datasource_child.DbCommand.CommandText = sCmdInnerText;
					// ��������� ��������� �� datasource'a ������������ ������ � ��������, ���� �� ��� ��� ��� (!)
					foreach(XDbParameter p in datasource_child.DbCommand.Parameters)
						if (!datasource.DbCommand.Parameters.Contains(p.ParameterName))
							datasource.DbCommand.Parameters.Add(p.Clone());
				}
				if (sCmdIsLeafText.Length > 0)
				{
					// ������ � ��� ���� �������������� ���������. 
					// ������� ������ @@ISLEAF �� ��������� CASE WHEN {���������} THEN 0 ELSE 1 END AS IS_LEAF
					datasource.DbCommand.CommandText = RegExp.Replace(datasource.DbCommand.CommandText, String.Format("CASE WHEN {0}THEN 0 ELSE 1 END AS IS_LEAF", sCmdIsLeafText));
				}
				else
				{
					// ��������� �� ������������, ������ ������� @@ISLEAF �� 1 (�.�. ����� �������, ��� ���� ������������)
					datasource.DbCommand.CommandText = RegExp.Replace(datasource.DbCommand.CommandText, "1 AS IS_LEAF");
				}
			}
		}

		/// <summary>
		/// �������� ������� @@PARENTID - ���������� ������������� ������� �� 
		/// ������� ������ �� �������� (1-����,2-���,� �.�.)
		/// ����������� ��������� � ����� ������� (�������)
		/// </summary>
		/// <param name="cmd">DB-������� �������� ������</param>
		/// <param name="treeRequest">������</param>
		protected virtual void evaluateParentIdFunc( XDbCommand cmd, XGetTreeDataRequest treeRequest ) 
		{
			string sValue;			// �������� �������/�������
			Regex RegExp;			// ��� ������ @@ParentID

			RegExp = new Regex(@"@@PARENTID\s*\(\s*(\d+)\s*\)", RegexOptions.IgnoreCase);
			foreach(Match matchInner in RegExp.Matches(cmd.CommandText))
			{
				GroupCollection groups = matchInner.Groups;
				int nArg = Int32.Parse( groups[1].Value );
				if (!(nArg > 0))
					throw new XTreeStructException("�������� ��������� ������� @@ParentID ������ ���� ������ 0");
				if (treeRequest.Action == XTreeAction.GetChildren)
				{
					// ���� ������� ��������� �����, �� data-source ����������� �� ��� �������� ����, � ��� ��������
					// ������� 0-��� ��������� � NODEPATH'� ����� ������������ �������. �������� � data-source'�
					// ��������� �� �������� ��� �������� 1. ������� ������� ������.
					nArg -= 1;
				}
				if (nArg > treeRequest.Path.Length-1)
					throw new XTreeStructException("�������� ��������� ������� @@ParentID ��������� ������� ���� � ������");
				sValue = cmd.Connection.ArrangeSqlGuid(treeRequest.Path[nArg].ObjectID);
				
				cmd.CommandText = cmd.CommandText.Replace(matchInner.Value, sValue);
			}
		}

		/// <summary>
		/// ��������� � ����������� �������-������ @@RecursiveExp.
		/// ������� ������ ����������� ����� ����������� @@ParentID
		/// </summary>
		/// <param name="treelevel">�������� ������</param>
		/// <param name="cmd">DB-������� �������� ������</param>
		/// <param name="nRecurLevel">������� �������� (������� � 0)</param>
		protected void evaluateRecursiveExp(XTreeLevelInfoIT treelevel, XDbCommand cmd, int nRecurLevel)
		{
			string sParam;			// �������� @@RecursiveExp
			string sValue;			// �������� �������/�������
			string sEnterCondition;	// ������� ��� 1-�� ������ �������� (������� ��������� � ��������)
			Regex re;				// ��� ������ @@RecursiveExp
			Match match;
			int nRecursiveExpStart = 0;		// ������ ������ ��������� @@RecursiveExp(...)

			match = Regex.Match(cmd.CommandText, @"@@RecursiveExp\s*\(", RegexOptions.IgnoreCase);
			if (match.Success)
			{
				if (!treelevel.IsRecursive)
					throw new ApplicationException("������������ �������� ��������: ������� @@RecursiveExp ����� �������������� ������ � ���������� ������ ����������� �������");
				// ��������� ������� ��� ������ ���������� ������� @@RecursiveExp
				nRecursiveExpStart = match.Index;
				int nStart = match.Index + match.Length;
				int nEnd = 0;
				int nBrackets = 0;
				for(int i = nStart; i<cmd.CommandText.Length; ++i)
				{
					if (cmd.CommandText[i] == '(')
						++nBrackets;
					else if (cmd.CommandText[i] == ')')
					{
						if (nBrackets == 0)
						{
							nEnd = i;
							break;
						}
						else
							--nBrackets;
					}
				}
				if (nEnd == 0)
					throw new ApplicationException("�� ������� ����������� ������ ������ ������� @@RecursiveExp");
				re = new Regex("(?<param>[^,]+)(,(?<entercondition>.+))?");
				match = re.Match(cmd.CommandText, nStart, nEnd - nStart);
				if (match.Success)
				{
					sParam = match.Result("${param}");
					if (sParam == null || sParam.Trim().Length == 0)
						throw new ApplicationException("�� ����� �������� ������� @@RecursiveExp");
					sEnterCondition = match.Result("${entercondition}");
					if (nRecurLevel == 0)
					{
						if (sEnterCondition != null && sEnterCondition.Trim().Length > 0)
							sValue = sEnterCondition;
						else
							sValue = sParam + " IS NULL";
					}
					else
						sValue = sParam + " = @@ParentID(1)";
					cmd.CommandText = cmd.CommandText.Replace( cmd.CommandText.Substring(nRecursiveExpStart,nEnd-nRecursiveExpStart+1), sValue);
				}
			}
		}
		
		/// <summary>
		/// ����������� ������ @@RC (������� ��������) � ������ �������
		/// </summary>
		/// <param name="cmd">DB-������� �������� ������</param>
		/// <param name="nRecurLevel">������� �������� (������� � 0)</param>
		/// <returns>���������������� ����� �������(�������)</returns>
		protected virtual void evaluateRecurLevelMacro( XDbCommand cmd, int nRecurLevel ) 
		{
			string sValue;		// �������� ������� @@RC
			string sCmdText = cmd.CommandText;

			sValue = nRecurLevel > 0 ? nRecurLevel.ToString() : String.Empty;
			Regex re = new Regex(@"@@RC", RegexOptions.IgnoreCase);
			cmd.CommandText = re.Replace(sCmdText, sValue);
		}

		/// <summary>
		/// ���������� ������� �������� �������� �������; 0 - ���� �������� ���.
		/// </summary>
		/// <param name="treelevel">������� �������</param>
		/// <param name="treeRequest">������ �������</param>
		/// <returns>
		/// ���������� ��������� � ����������� ��������� �� ������, ����� ����;
		/// ���� - ���� �������� ���
		/// </returns>
		protected virtual int getRecurrenceLevel( XTreeLevelInfoIT treelevel, XGetTreeDataRequest treeRequest ) 
		{
			// ��� �������� ������� �� ����� ���� ��������
			if (treeRequest.Action == XTreeAction.GetRoot)
				return 0;
			int nRecurLevel = 0;
			string[] aNodeTypes = treeRequest.Path.GetNodeTypes();	// ���� � ������ �� �������� ����
			if (treelevel.ObjectType == aNodeTypes[0])
			{
				for(int i=1; i<aNodeTypes.Length; i++)
				{
					if ( aNodeTypes[i] == aNodeTypes[i-1] )
						nRecurLevel++;
					else
						break;
				}
				// ��� ������� GET_CHILDREN ���� �� �������� ������ �� ��������� �������, ������ �������� ����������� (treelevel),
				// ������� ����� �������� �������� �� 1
				if (treeRequest.Action == XTreeAction.GetChildren)
					nRecurLevel++;
			}
			return nRecurLevel;
		}

		/// <summary>
		/// �������� ������� @@ParentIDByType - ���������� ������������� ������� �������� ���� - 
		// �������, �������������� ��� ������� �� ���� �� ������������ ���� �� �����
		/// ����������� ��������� � ����� ������� (�������)
		/// </summary>
		/// <param name="cmd">DB-������� �������� ������</param>
		/// <param name="treeRequest">������</param>
		protected virtual void evaluateParentIDByTypeFunc(XDbCommand cmd, XGetTreeDataRequest treeRequest)
		{
			string sValue;			// �������� �������/�������
			Regex RegExp;			// ��� ������ "@@ParentIDByType"
			int nStart;				// ������, � �������� ���������� �������� ���� (0 - getchildren, 1 - getnode)

			RegExp = new Regex(@"@@ParentIDByType\s*\(\s*([^)]+)\s*\)", RegexOptions.IgnoreCase);
			foreach(Match matchInner in RegExp.Matches(cmd.CommandText))
			{
				GroupCollection groups = matchInner.Groups;
				string sTypeName = groups[1].Value;
				nStart = 0;
				if (treeRequest.Action == XTreeAction.GetNode)
					nStart = 1;
				
				sValue = null;
				for(int i=nStart;i<treeRequest.Path.Length;i++)
					if (treeRequest.Path[i].ObjectType == sTypeName)
					{
						sValue = cmd.Connection.ArrangeSqlGuid(treeRequest.Path[i].ObjectID);
						break;
					}
				if (sValue != null)
					cmd.CommandText = cmd.CommandText.Replace(matchInner.Value, sValue);
				else
					throw new XInvalidMetadataException("����������� ������������ data-source ������ �� ������� �������� " + treeRequest.MetaName + 
						". ������ @@ParentIDByType ��������� �� ��� " +  sTypeName + ", �� ��������� � ����: " + treeRequest.Path.ToString());
			}
		}

		#endregion

		protected XTreeLoadData readTreeData(XTreeLoadData treeData, XDataSource datasource, XTreeLevelInfoIT treelevel, XGetTreeDataRequest treeRequest)
		{
			string sFieldName;						// ������������ �������
			HybridDictionary excludedNodes = null;	// ������� ������������ �����
			// ������������ ������� � ��������(��������) ���������� ������� ������:
			/// <summary>
			/// ������������� �������
			/// </summary>
			const string FIELD_OBJECTID = "OBJECTID";
			/// <summary>
			/// �����, ������������ ��� ���� � ��������
			/// </summary>
			const string FIELD_TITLE = "TITLE";
			/// <summary>
			/// �������� ������
			/// </summary>
			const string FIELD_ICONSELECTOR = "ICON_SELECTOR";
			/// <summary>
			/// ������� ��������� ���� (1-��������,0-����������)
			/// </summary>
			const string FIELD_ISLEAF = "IS_LEAF";

			if (treeRequest.ExcludedNodes != null && treeRequest.ExcludedNodes.Length > 0)
			{
				excludedNodes = new HybridDictionary(treeRequest.ExcludedNodes.Length);
				foreach(XObjectIdentity obj_id in treeRequest.ExcludedNodes)
					excludedNodes.Add(obj_id.ObjectType + ":" + obj_id.ObjectID, null);
			}

			using(IXDataReader reader = datasource.ExecuteReader())
			{
				while(reader.Read())
				{
					XTreeNode nodeData = new XTreeNode();
                    nodeData.AppData = new XParamsCollection();
                    if (treelevel.ObjectType!=null)
					nodeData.TypeName = treelevel.ObjectType;
					for(int i=0;i<reader.FieldCount;i++)
					{
						sFieldName = reader.GetName(i);
						try
						{
							switch (sFieldName.ToUpper())
							{
									// ������������� (��� ����������� ����� ����� ���� �� �����)
								case FIELD_OBJECTID:
									if (!reader.IsDBNull(i))
									{
										nodeData.ObjectID = reader.GetGuid(i);
										if (excludedNodes != null && excludedNodes.Contains(treelevel.ObjectType + ":" + nodeData.ObjectID))
											continue;
									}
									break;
									// ��������� ����
								case FIELD_TITLE:
									if (!reader.IsDBNull(i))
										nodeData.Title= reader.GetString(i);
									break;
									// �������� ������, ��� �������, ��� ����������� ������ �� ���������
								case FIELD_ICONSELECTOR:
									if (!reader.IsDBNull(i))
										nodeData.Icon = reader.GetValue(i).ToString();
									break;
									// ������� ��������� ����
								case FIELD_ISLEAF:
									if (!reader.IsDBNull(i))
										nodeData.IsLeafNode = reader.GetInt32(i) == 1;
									break;
									// ���������������� ������
								default:
									if (!reader.IsDBNull(i))
									{
										// ������� �������� � ������ ���� �������, ������� ����� ���� ����� ��� ��������� ������
                                        object vType = datasource.DataSourceInfo.ColumnTypes[sFieldName];
										object vValue;
										if (vType != null)
											vValue = reader.GetValue(i, (XPropType)vType);
										else
											vValue = reader.GetValue(i);
                                        if (nodeData.AppData != null)
                                        {
                                            if (nodeData.AppData.Contains(sFieldName))
                                            {

                                                sFieldName = sFieldName + "_" + i.ToString();
                                            }
                                        }
                                        nodeData.AppData.Add(sFieldName, vValue);
                                        
									}
									break;
							}
						}
						catch(InvalidCastException ex)
						{
							throw new ApplicationException("������������ ������ ������� " + sFieldName + ".\nIDataRecord::GetFieldType: " + reader.GetFieldType(i).FullName + "\nIDataRecord.GetValue: " + reader.GetValue(i).ToString(), ex);
						}
					}
                    if (nodeData!= null)
					treeData.Nodes.Add(nodeData);
				}
			}
			return treeData;
		}

		/// <summary>
		/// ���������� ������ �������������� ������������ ������� ��������, ��������������� ������� � ����
		/// </summary>
		/// <param name="action">������� ������ (�������� ����, �������� �����, �������� �����)</param>
		/// <param name="treeParams">runtime ��������� ������</param>
		/// <param name="treePath">���� �� �������� ���� �� �����</param>
		/// <returns></returns>
		protected XTreeLevelInfoIT[] getTreeLevels(XTreeStructInfo treeStructInfo, XTreeAction action, XParamsCollection treeParams, XTreePath treePath) 
		{
			XTreeLevelInfoIT[] treelevels;
			switch (action)
			{
				case XTreeAction.GetRoot:
					// "�������" �� ��������� ������ �������� ����� ��������
					treelevels = treeStructInfo.Executor.GetRoots(treeStructInfo, treeParams);
					break;

				case XTreeAction.GetNode:
					// "�������" �� ��������� ������ ����, ��������� � �������
					treelevels = new XTreeLevelInfoIT[] { treeStructInfo.Executor.GetTreeLevel(treeStructInfo, treeParams, treePath) };
					break;

				case XTreeAction.GetChildren:
					// "�������" �� ��������� ������ �����, ����������� ����, ��������� � �������
					treelevels = treeStructInfo.Executor.GetTreeLevel(treeStructInfo, treeParams, treePath).GetChildTreeLevelsAffected(treeParams);
					break;

				default:
					// ������ ������� "������" ���� �� ����� - ��� ������:
					throw new ArgumentException("����������� ������� �������� ������");
			}
			return treelevels;
		}
	}
    
    
}