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
		/// Создает или возвращает экземпляр некоторого провайдера с заданным наименованием CLR-класса.
		/// </summary>
		/// <param name="providersCache">Кэш, к котором ищутся экземпляры провайдеров</param>
		/// <param name="defaultProvider">Провайдер по умолчанию</param>
		/// <param name="sProviderClassName">Полное наименование класса провайдера, может быть null/String.Empty</param>
		/// <param name="sTreePageName">Наименование иерархии</param>
		/// <param name="sProviderName">Описательное наименование провайдера</param>
		/// <param name="requiredInterface">Интерфейс, который должен реализовывать провайдер</param>
		/// <param name="ctorArgTypes">Массив типов параметров конструктора</param>
		/// <param name="ctorArgValues">Массив значение параметров конструктора</param>
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
						throw new XInvalidMetadataException("Для описания иерархии " + sTreePageName + " не удалось создать " + sProviderName + ": " + sProviderClassName);
					if (type.GetInterface(requiredInterface.FullName, true) == null)
						throw new XInvalidMetadataException("Для описания иерархии " + sTreePageName + " задан " + requiredInterface + " " + sProviderClassName + ", не реализующий " + requiredInterface.FullName);
					ConstructorInfo ctor = type.GetConstructor(ctorArgTypes);
					// вызовем конструктор provider'a
					// TODO: try-catch
					try
					{
						provider = ctor.Invoke(ctorArgValues);
					}
					catch(Exception ex)
					{
						throw new ApplicationException("Ошибка при вызове конструктора класса " + sProviderClassName + " (" + sProviderName + " описания иерархии " + sTreePageName + ": " + ex.Message, ex);
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
	/// Стандартная реализация XTreePageInfo, использующая описание структуры иерархии и меню в метаданных.
	/// Использует провайдеры: 
	///	 IXTreeDataLoadProvider - загрузка данных
	///	 IXTreeMenuLoadProvider - загрузка меню (формирование в runtime)
	///	Провайдеры устанавливаеются XTreePageInfoStdProvider'ом. Также он инициализирует и устанавливает описание структуры XTreeStructInfo
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
		/// Провайдер загрузки данных иерархии
		/// </summary>
		public IXTreeDataLoadProvider DataLoadProvider
		{
			get { return m_dataLoadProvider; }
			set { m_dataLoadProvider = value; }
		}

		/// <summary>
		/// Провайдер загрузки меню
		/// </summary>
		public IXTreeMenuDataProvider MenuDataProvider
		{
			get { return m_menuDataProvider; }
			set { m_menuDataProvider = value; }
		}

		/// <summary>
		/// Описание структуры иерархии
		/// </summary>
		public XTreeStructInfo TreeStruct
		{
			get { return m_treeStruct; }
			set { m_treeStruct = value; }
		}

		/// <summary>
		/// Описание меню пустой иерархии
		/// </summary>
		public XTreeMenuHandler EmptyTreeMenu
		{
			get { return m_emptyTreeMenu; }
			set { m_emptyTreeMenu = value; }
		}

		/// <summary>
		/// Описание меню по умолчанию используемое как меню уровня (если он не содержит свое меню)
		/// </summary>
		public XTreeMenuHandler DefaultLevelMenu
		{
			get { return m_defaultLevelMenu; }
			set { m_defaultLevelMenu = value; }
		}

		/// <summary>
		/// Коллекция параметров, определенная в desing-time (в метаданных).
		/// Данные параметры подставляются автоматически в коллекцию параметров, пришедших с клиента
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
				throw new XInvalidMetadataException("Иерархия '" + treePage.Name + "' не содержит описания структуры");
			//treePage.TreeLoadCommandName = xmlTreePage.GetAttribute("load-cmd");
			//treePage.MenuLoadCommandName = xmlTreePage.GetAttribute("menu-load-cmd");
			treePage.IconTemplateURI = xmlTreePage.GetAttribute("icon-template");
			if (treePage.IconTemplateURI.Length == 0)
				treePage.IconTemplateURI = "x-get-icon.aspx?OT={T}&SL={S}&BIN=1";
			treePage.OffShowIcons = xmlTreePage.GetAttribute("off-icons") == "1";

			// установим провайдер загрузки данных
			treePage.DataLoadProvider = getTreeDataLoadProvider(xmlTreePage.GetAttribute(ATTR_TreeDataLoadProvider, XTreeController.NAMESPACE_URI), treePage.Name);

			// установим провайдер конструироания меню
			IXTreeMenuHandlerFactory menuFactory = getTreeMenuHandlerFactory(xmlTreePage.GetAttribute(ATTR_TreeMenuHandlerFactory, XTreeController.NAMESPACE_URI), treePage.Name);
			//treePage.MenuProvider = menu_prv;
			XmlElement xmlTreeMenu = (XmlElement)xmlTreePage.SelectSingleNode(sCustomPrefix + ":empty-tree-menu", m_mdManager.NamespaceManager);
			// Не нашли кастомное меню - поищем стандартное меню в описании структуры
			if (xmlTreeMenu == null)
			{
				xmlTreeMenu = (XmlElement)xmlTreeStruct.SelectSingleNode("i:empty-tree-menu", m_mdManager.NamespaceManager);
			}
			treePage.EmptyTreeMenu = menuFactory.CreateMenuHandler(xmlTreeMenu);
			xmlTreeMenu = (XmlElement)xmlTreePage.SelectSingleNode(sCustomPrefix + ":default-level-menu", m_mdManager.NamespaceManager);
			// Не нашли кастомное меню - поищем стандартное меню в описании структуры
			if (xmlTreeMenu == null)
			{
				xmlTreeMenu = (XmlElement)xmlTreeStruct.SelectSingleNode("i:default-level-menu", m_mdManager.NamespaceManager);
			}
			treePage.DefaultLevelMenu = menuFactory.CreateMenuHandler(xmlTreeMenu);

			// установим провайдер загрузки меню
			treePage.MenuDataProvider = getTreeMenuDataProvider(xmlTreePage.GetAttribute(ATTR_TreeMenuDataProvider, XTreeController.NAMESPACE_URI), treePage.Name);

			// получим провайдер формирования метаописания структуры иерархии..
			IXTreeStructInfoProvider prv = getTreeStructInfoProvider(xmlTreeStruct.GetAttribute("provider", XTreeController.NAMESPACE_URI), treePage.Name);
			// .. и запросим у него описание структуры
			treePage.TreeStruct = prv.CreateTreeStructInfo(xmlTreeStruct, menuFactory);

			XmlElement xmlParams = (XmlElement)xmlTreePage.SelectSingleNode( String.Format("i:params | {0}:params", sCustomPrefix), m_mdManager.NamespaceManager);
			if (xmlParams != null)
				xmlParams = Croc.XmlFramework.XUtils.XmlUtils.RemoveSchemaLinksAndPrefixes(xmlParams);
            treePage.DesignParams = XParamsCollectionBuilder.AppendFromXml(treePage.DesignParams, xmlParams, true);
    	}

		protected IXTreeStructInfoProvider getTreeStructInfoProvider(string sProviderClassName, string sTreePageName)
		{
			return (IXTreeStructInfoProvider)TreeConfigurationHelper.getProvider(m_treeStructInfoProviders, m_treeStructInfoDefaultProvider, sProviderClassName, sTreePageName, "провайдер структуры иерархии", typeof(IXTreeStructInfoProvider), new Type[] {typeof(XMetadataManager)}, new object[] {m_mdManager});
		}

		protected IXTreeDataLoadProvider getTreeDataLoadProvider(string sProviderClassName, string sTreePageName)
		{
			return (IXTreeDataLoadProvider)TreeConfigurationHelper.getProvider(m_treeLoadProviders, m_treeDataLoadDefaultProvider, sProviderClassName, sTreePageName, "провайдер данных иерархии", typeof(IXTreeDataLoadProvider), Type.EmptyTypes, new object[0]);
		}

		protected IXTreeMenuHandlerFactory getTreeMenuHandlerFactory(string sProviderClassName, string sTreePageName)
		{
			return (IXTreeMenuHandlerFactory)TreeConfigurationHelper.getProvider(m_treeMenuProviders, m_treeMenuDefaultHandlerFactory, sProviderClassName, sTreePageName, "провайдер формирования меню", typeof(IXTreeMenuHandlerFactory), new Type[] {typeof(XMetadataManager)}, new object[] {m_mdManager});
		}

		protected IXTreeMenuDataProvider getTreeMenuDataProvider(string sProviderClassName, string sTreePageName)
		{
			return (IXTreeMenuDataProvider)TreeConfigurationHelper.getProvider(m_treeMenuDataProviders, m_treeMenuDataDefaultProvider, sProviderClassName, sTreePageName, "провайдер загрузки данных меню", typeof(IXTreeMenuDataProvider), Type.EmptyTypes, new object[0]);
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
		//			// заполним библиотеку уровней
		//			foreach(XmlElement xmlTreeLevel in m_mdManager.SelectNodes("i:tree-level"))
		//			{
		//				if (xmlTreeLevel.Attributes["n"] == null)
		//					throw new XInvalidMetadataException("Для корневого элемента tree-level не задано наименование (атрибут n): " + xmlTreeLevel.OuterXml.Substring(0, 100) + "...");
		//				XTreeLevelInfoIT treeLevelInfo = CreateTreeLevelInfo(xmlTreeLevel);
		//				m_levels.Add(xmlTreeLevel.Attributes["n"].Value, treeLevelInfo);
		//			}
		//
		//			// заполним библиотеку деревьев
		//			foreach(XmlElement xmlTreeStruct in m_mdManager.SelectNodes("i:tree-struct"))
		//			{
		//				if (xmlTreeStruct.Attributes["n"] == null)
		//					throw new XInvalidMetadataException("Для корневого элемента tree-struct не задано наименование (атрибут n): " + xmlTreeStruct.OuterXml.Substring(0, 100) + "...");
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
					throw new XInvalidMetadataException("Для описания структуры иерархии не удалось создать экземпляр класса descriptor'a: " + xmlTreeStruct.GetAttribute("descriptor"));
				if (!type.IsSubclassOf(typeof(XTreeStructInfo)))
					throw new XInvalidMetadataException("Для описания структуры иерархии задан класса descriptor'a, не производный от " + typeof(XTreeStructInfo).FullName);
				// TODO: уточнить сигнатуру конструктора
				ConstructorInfo ctor = type.GetConstructor(new Type[] {typeof(string), typeof(XTreeLevelInfoIT[]), typeof(IXTreeStructExecutor)});
				if (ctor == null)
					throw new XInvalidMetadataException("Для описания структуры иерархии задан класса descriptor'a, не содержащий конструктора с сигнатурой ctor(string,XTreeLevelInfoIT[],XTreeStructExecutor): " + type.FullName);
				// вызовем конструктор описателя структуры иерархии
				// TOD: try-catch
				treeStruct = (XTreeStructInfo)ctor.Invoke(new object[] {xmlTreeStruct, m_mdManager, this});
			}
			else
				treeStruct = new XTreeStructInfo(xmlTreeStruct.GetAttribute("n"), roots, executor);
			return treeStruct;
		}

		protected XTreeLevelInfoIT[] getRoots(XmlElement xmlTreeStruct, IXTreeMenuHandlerFactory menuHandlerFactory)
		{
			// Формируем массив объектных представлений описаний корневых уровней:
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
			// Создадим массив источников данных (data-source), и поместим его 
			// под сгенерированным наименованием в реестр data-source'ов, 
			// в XModel (у него хранится кеш всех источников):
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

			// инициализируем меню
			XmlElement xmlLevelMenu = (XmlElement)xmlTreeLevel.SelectSingleNode("i:level-menu", m_mdManager.NamespaceManager);
			levelInfo.MenuHandler = menuHandlerFactory.CreateMenuHandler(xmlLevelMenu);

			// Выбираем описания всех подчиненных уровней - для каждого 
			// создаем соотв. объектное описание и сохраняем в массиве:
			XmlNodeList xmlLevels = xmlTreeLevel.SelectNodes( "i:tree-level", m_mdManager.NamespaceManager );
			XTreeLevelInfoIT[] childTreeLevels = getTreeLevels(xmlLevels, menuHandlerFactory);
			levelInfo.ChildTreeLevelsInfoMetadata = childTreeLevels;
			return levelInfo;
		}
	}


	/// <summary>
	/// Данные одного узла дерева
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
	/// Данные множества узлов дерева (результат команды загрузки данных дерева)
	/// </summary>
	[Serializable]
	public class XTreeLoadData
	{
        public List<XTreeNode> Nodes = new List<XTreeNode>();		// List<XTreeNodeLoadData>

		/// <summary>
		/// Возвращает количество узлов
		/// </summary>
		public int NodesCount
		{
			get { return Nodes.Count; }
		}

		/// <summary>
		/// Переносит описания узлов из переданного множества в текущее
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
	/// Интерфейс провайдера загрузки данных иерархии. Используется XTreePageInfoStd и XTreeStructInfoProvider
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
				// сформируем xml в формате CROC.XTreeView
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
			// TODO: post-processor'ы данных

			return treeData;
		}

		#region Подготовка XDataSource (copy-paste из XGetTreeDataCommand)
		/// <summary>
		/// Создает описание источника данных для уровня иерархии.
		/// Для команд загрузчика GETROOT и GETCHILDREN вызывает стандартную 
		/// обработку параметров data-source'a XDataSource.SubstituteNamedParams
		/// Обработка команды GETNODE немного отличается от команд GETROOT/GETCHILDREN
		/// </summary>
		/// <param name="treelevel">источник данных</param>
		/// <param name="con">соединение с БД</param>
		/// <param name="treeRequest">Исходный запрос</param>
		protected virtual XDataSource createTreeLevelDataSource(XTreeLevelInfoIT treelevel, XStorageConnection con, XGetTreeDataRequest treeRequest )
		{
			string sCmdText;				// текст команды
			string sValue;					// значение функции/макроса
			string sAlias = String.Empty;	// алиас/наименование таблицы
			int nRecursiveLevel;			// уровень рекурсии (от 0)
			Guid requestObjectID;			// идентификатор запрошенного узла для GETNODE или Guid.Empty для GETROOT/GETCHILDREN

			XDataSource datasource = treelevel.GetDataSource(con);
			sCmdText = datasource.DbCommand.CommandText.Trim();
			requestObjectID = Guid.Empty;
			if (treeRequest.Action == XTreeAction.GetNode)
			{
				// для команды получения узла особенная обработка.
				if (treelevel.IsVirtual)
				{
					// Если узел виртуальный.
					// Т.к. виртуальные узлы ничем однозначно не идентифицируются, то вырежем макросы SEARCH_CONDITIONS/WHERE_CLAUSE
					sCmdText.Replace("WHERE_CLAUSE", "").Replace("SEARCH_CONDITIONS", " 0=0 ");
				}
				else
				{
					// Если узел не виртуальный, то нам надо сформировать условие 
					// WHERE table.ObjectID = 'идентификатор в treeRequest.NodeID(0)'
					// При этом сделать остальные условия невалидными.
					if (sCmdText.IndexOf("@@OBJECT_ID")>0)
					{
						// если есть макрос @@OBJECT_ID, то все хорошо
						sCmdText = sCmdText.Replace("@@OBJECT_ID", con.GetParameterName("RequestedOID") );
						// остальные условия сделаем невалидными, чтоб не мешались
						// Если нет макроса SEARCH_CONDITIONS, то это гарантировано ошибка, т.к. получается условие типа:
						// WHERE какое-то_условие OR Object = @@OBJECT_ID, здесь мы не может сделать "какое-то_условие" невалидным,
						// т.е. это ошибка разработчика - скажем ему об этом
						if (sCmdText.IndexOf("SEARCH_CONDITIONS") == -1)
							throw new XTreeStructException("Ошибочное условие запроса для data-source: если задан функция @@OBJECT_ID, то должен быть также задан макрос SEARCH_CONDITIONS, иначе невозможно сформировать условие для команды получения выбранного узла");
						// (OBJECT_ID должен быть соединен через OR с остальными условиями)
						sCmdText = sCmdText.Replace("SEARCH_CONDITIONS", " 1=0 ");
						// Примечание: Макроса WHERE_CLAUSE здесь быть не может
					}
                       
					else if (!datasource.DataSourceInfo.Params.ContainsKey("RequestedOID"))
					{
						// макрос @@OBJECT_ID не задан и не задекларирован параметр RequestedOID, куда мы бы подставили ид. запрошеного узла, 
						// поэтому попробуем сформировать условие <тип>.ObjectID = 'идентификатор_выбранного_объекта' вместо макроса WHERE_CLAUSE,
						// а если этого макроса нет, то следовательно запрос некорректный - генерируем искючение

						// Для идентификации таблицы возьмем алиас или имя типа
						sAlias = treelevel.Alias;
						if (sAlias.Length == 0)
							sAlias = treelevel.ObjectType;
						// сформируем условие на получение объекта, соответствующего заданному узлу дерева (первый в пути)
						sValue = String.Format("{0}.ObjectID = {1}", sAlias, con.GetParameterName("RequestedOID") );
						// если макроса WHERE_CLAUSE нет, то будем ругаться во избежание возможных ошибок
						if (sCmdText.IndexOf("WHERE_CLAUSE") == -1)
							throw new XTreeStructException("Ошибочное условие запроса для data-source: если не задан макрос @@ObjectID, то должен быть задан макрос WHERE_CLAUSE, иначе невозможно сформировать условие для команды получения выбранного узла");
						// если здесь, значит WHERE_CLAUSE есть.
						sCmdText = sCmdText.Replace("WHERE_CLAUSE", " WHERE " + sValue);
					}
					requestObjectID = treeRequest.Path[0].ObjectID;
					// добавим в ADO-команду параметр с идентификатором запрошенного объекта
					datasource.DbCommand.Parameters.Add("RequestedOID", DbType.Guid, ParameterDirection.Input, false, requestObjectID);
				}
			}
			else
			{
				// заменим функцию @@OBJECT_ID на нулевой гуид - он нужен только для команды получения узла (GET_NODE)
				// Примечание: макроса @@OBJECT_ID может в тексте запроса и не быть, поэтому не используем параметры
				// ВНИМАНИЕ: в качестве значения макроса добавляем строку: '00000000-0000-0000-0000-000000000000' AND 1=0,
				// условие 1=0 добавляется из-за соображений производительности для отсечения всего условия, соединенного через OR
				sCmdText = sCmdText.Replace("@@OBJECT_ID", con.ArrangeSqlGuid(Guid.Empty) + " AND 1=0");
			}
			// добавим в ADO-команду параметр с идентификатором запрошенного объекта
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
			// Важно: param-selector могут содержать макросы и функции, разрешаемые далее
			// вызовем стандартную обработку параметров
			if (treeRequest.Params != null)
                datasource.SubstituteNamedParams(XParamsCollection.ToHashtable(treeRequest.Params), true);
			else
				datasource.SubstituteNamedParams(new Hashtable(), true);
			
			// установим порядок сортировки
			datasource.SubstituteOrderBy();
           
			nRecursiveLevel = getRecurrenceLevel(treelevel, treeRequest);
			// вычислим макрос @@ISLEAF - признак листового узла
			evaluateIsLeafMacro(treelevel, datasource, treeRequest);
			// Вычислим функцию @@RecursiveExp - формирование условия образования рекурсии. 
			// ВАЖНО: функция должна вычисляться перед вычислением @@ParentID, 
			// т.к. для уровня рекурсии больше 0 подставляет в запрос выражением с @@ParentID
			evaluateRecursiveExp(treelevel, datasource.DbCommand, nRecursiveLevel);
			// Вычислим функцию @@PARENTID - возвращает идентификатор объекта на заданом уровне от текущего (1-папа,2-дед,и т.д.)
			evaluateParentIdFunc(datasource.DbCommand, treeRequest);
			// Вычислим функцию @@ParentIDByType - возвращает идентификатор объекта заданого типа - 
			// первого, встретившегося при проходе по пути от запрошенного узла до корня
			evaluateParentIDByTypeFunc(datasource.DbCommand, treeRequest);
			// вычислим макрос @@RC - уровень рекурсии
			// ВАЖНО: подставлять значение @@RC надо после подстановки order-by, т.к. выражение сортировки может содержать @@RC
			evaluateRecurLevelMacro(datasource.DbCommand, nRecursiveLevel );
			return datasource;
		}

		/// <summary>
		/// Подставляет в команду (запрос) условие на вычисление признака листового узла (макрос @@ISLEAF).
		/// Если макрос отсутствует, то текст команды не модифицируется.
		/// </summary>
		/// <param name="treelevel"></param>
		/// <param name="datasource"></param>
		/// <param name="treeRequest">запрос</param>
		protected virtual void evaluateIsLeafMacro(XTreeLevelInfoIT treelevel, XDataSource datasource, XGetTreeDataRequest treeRequest)
		{
			string sCmdIsLeafText;	// текст команлы (запроса) для вычисления условия терминальности узла (ISLEAF)
			string sCmdInnerText;	// текст команды вложенного tree-level'а в текущий
			string sValue;			// значение функции/макроса
			Regex RegExp;			// для поиска @@ISLEAF
			Regex RegExpInner;		// для поиска @@ISLEAF в подзапросах
			int nRecurLevel;		// уровень рекурсии
			string sParentTable;	// ссылка на таблицу текущего типа во вложенном подзапросе
			int nRecurLevelCurrent;	// уровень рекурсии вложенного data-source'a
			XStorageConnection con;	// соединение

			// вычислим признак листового узла - функция @@ISLEAF. 
			// Для этого надо собрать запросы data-source'ов всех подчиненных текущему tree-level'ов
			// (текущий tree-level - это родитель переданного data-source'а (xmlDataSource))
			// Делаеть это имеет смысл в случае, если в текущем data-source есть функция-макрос @@ISLEAF 
			// (ее может не быть, если разработчик сам написал условие для IsLeaf)
			RegExp = new Regex("@@ISLEAF", RegexOptions.IgnoreCase);
			Match match = RegExp.Match(datasource.DbCommand.CommandText);
			if (match.Success)
			{
				sCmdIsLeafText = String.Empty;
				// надо вычислить уровень рекурсии вложенного data-source'a.
				// получим уровень рекурсии текущего уровня
				nRecurLevelCurrent = getRecurrenceLevel( treelevel, treeRequest );
				con = datasource.DbCommand.Connection;
				// по всем tree-level'ам подчиненным текущему уровню (их может быть несколько)
				foreach(XTreeLevelInfoIT treelevel_child in treelevel.GetChildTreeLevelsAffected(treeRequest.Params))
				{
					XDataSource datasource_child = treelevel_child.GetDataSource(con);
					datasource_child.SubstituteNamedParams((Hashtable)treeRequest.Params, true);
					// ВНИМАНИЕ: для подчиненных узлов нам не нужен признак терминальности (ISLEAF), 
					// кроме того надо предотвратить рекурсию. Поэтому заменим макрос-функцию @@ISLEAF на 0.
					RegExpInner = new Regex("@@ISLEAF", RegexOptions.IgnoreCase);
					datasource_child.DbCommand.CommandText = RegExpInner.Replace(datasource_child.DbCommand.CommandText, "0 AS IS_LEAF");

					// обработаем функцию @RC
					nRecurLevel = nRecurLevelCurrent;
					// если тип вложенного уровня такой же, как текущий, то увеличим значение уровня рекурсии на 1
					// Это потому, что в treeRequest'e не содержится уровня xmlDataSourceChild
					if (treelevel_child.ObjectType == treelevel.ObjectType)
					{
						nRecurLevel ++;
					}
					evaluateRecurLevelMacro(datasource_child.DbCommand, nRecurLevel);
					evaluateRecursiveExp(treelevel_child, datasource_child.DbCommand, nRecurLevel);
					// обработаем ф-цию @@PARENTID. Если вложенный data-source используется @@ParentID(1), значит он
					// ссылается на текущий уровень.
					RegExpInner = new Regex(@"@@PARENTID\s*\(\s*(\d+)\s*\)", RegexOptions.IgnoreCase);
					foreach(Match matchInner in RegExpInner.Matches(datasource_child.DbCommand.CommandText))
					{
						GroupCollection groups = matchInner.Groups;
						int nArg = Int32.Parse( groups[1].Value );
						if (!(nArg > 0))
							throw new XTreeStructException("Значение аргумента функции @@ParentID должно быть больше 0");
						// скорректируем аргумент функции @@ParentID т.о., чтобы он стал индексом узла в пути, переданным с запросом
						if (treeRequest.Action == XTreeAction.GetChildren)
							nArg -= 2;
						else if (treeRequest.Action == XTreeAction.GetNode)
							nArg -= 1;
						else if (nArg > 1)
							// узел подчиненный корневому (т.е. treeRequest.Action == TreeAction.GET_ROOT) 
							// ссылается на что-то по @@ParentID(2)
							throw new XTreeStructException("Функция @@ParentID имеет некорректный аргумент: " + nArg.ToString());
						if (nArg >= 0 && treeRequest.Action != XTreeAction.GetRoot)
						{
							// Мы уже знаем необходимый идентификатор
							sValue = con.ArrangeSqlGuid(treeRequest.Path[nArg].ObjectID);
						}
						else
						{
							// подчиненный data-source ссылается на текущий.
							// Идентификаторов мы еще не знает, поэтому сошлемся на родителя по алиасу, либо по имени таблицы.
							sParentTable = treelevel.Alias;
							if (sParentTable.Length==0)
								sParentTable = treelevel.ObjectType;
							if (treelevel.IsRecursive)
							{
								// если текущий уровень (т.е. тот уровень, для которого мы вычисляем макрос @IS_LEAF) рекурсивный,
								// то значит в запросе для ссылки на него надо добавить индекс рекурсии.
								if (nRecurLevelCurrent > 0)
									sParentTable = sParentTable + nRecurLevelCurrent.ToString();
							}
							sValue = sParentTable + ".ObjectID";
						}
						datasource_child.DbCommand.CommandText = datasource_child.DbCommand.CommandText.Replace(matchInner.Value, sValue);
					}

					// теперь обработаем макросы @@OBJECT_ID, SEARCH_CONDITIONS, WHERE_CLAUSE:
					// в данном случае они нам не нужны - @@OBJECT_ID заменим на нулевой гуид, а SEARCH_CONDITIONS, WHERE_CLAUSE просто удалим
					RegExpInner = new Regex("@@OBJECT_ID", RegexOptions.IgnoreCase);
					sCmdInnerText = datasource_child.DbCommand.CommandText;
					// ВНИМАНИЕ: в качестве значения макроса @@OBJECT_ID добавляем строку: '00000000-0000-0000-0000-000000000000' AND 1=0,
					// условие 1=0 добавляется из-за соображений производительности для отсечения всего условия, соединенного через OR
					sCmdInnerText = RegExpInner.Replace( sCmdInnerText, con.ArrangeSqlGuid(Guid.Empty) + " AND 1=0");
					sCmdInnerText = sCmdInnerText.Replace("SEARCH_CONDITIONS", " 1=1 ");
					sCmdInnerText = sCmdInnerText.Replace("WHERE_CLAUSE", String.Empty);
					// объединим условие с предыдущим
					if (sCmdIsLeafText != String.Empty)
						sCmdIsLeafText = String.Format("{0} OR EXISTS ({1})", sCmdIsLeafText, sCmdInnerText);
					else
						sCmdIsLeafText = String.Format(" EXISTS ({0}) ", sCmdInnerText);
					datasource_child.DbCommand.CommandText = sCmdInnerText;
					// перенесем параметры из datasource'a подчиненного уровня в основной, если их там уже нет (!)
					foreach(XDbParameter p in datasource_child.DbCommand.Parameters)
						if (!datasource.DbCommand.Parameters.Contains(p.ParameterName))
							datasource.DbCommand.Parameters.Add(p.Clone());
				}
				if (sCmdIsLeafText.Length > 0)
				{
					// теперь у нас есть сформированный подзапрос. 
					// Заменим макрос @@ISLEAF на выражение CASE WHEN {подзапрос} THEN 0 ELSE 1 END AS IS_LEAF
					datasource.DbCommand.CommandText = RegExp.Replace(datasource.DbCommand.CommandText, String.Format("CASE WHEN {0}THEN 0 ELSE 1 END AS IS_LEAF", sCmdIsLeafText));
				}
				else
				{
					// подзапрос не сформировали, просто заменим @@ISLEAF на 1 (т.е. будем считать, что узел терминальный)
					datasource.DbCommand.CommandText = RegExp.Replace(datasource.DbCommand.CommandText, "1 AS IS_LEAF");
				}
			}
		}

		/// <summary>
		/// Вычислим функцию @@PARENTID - возвращает идентификатор объекта на 
		/// заданом уровне от текущего (1-папа,2-дед,и т.д.)
		/// Подставляет результат в текст команды (запроса)
		/// </summary>
		/// <param name="cmd">DB-команда загрузки данных</param>
		/// <param name="treeRequest">запрос</param>
		protected virtual void evaluateParentIdFunc( XDbCommand cmd, XGetTreeDataRequest treeRequest ) 
		{
			string sValue;			// значение функции/макроса
			Regex RegExp;			// для поиска @@ParentID

			RegExp = new Regex(@"@@PARENTID\s*\(\s*(\d+)\s*\)", RegexOptions.IgnoreCase);
			foreach(Match matchInner in RegExp.Matches(cmd.CommandText))
			{
				GroupCollection groups = matchInner.Groups;
				int nArg = Int32.Parse( groups[1].Value );
				if (!(nArg > 0))
					throw new XTreeStructException("Значение аргумента функции @@ParentID должен быть больше 0");
				if (treeRequest.Action == XTreeAction.GetChildren)
				{
					// если команда получения детей, то data-source вычисляется не для текущего узла, а для потомков
					// Поэтому 0-вым элементом в NODEPATH'е будет родительский элемент. Элементы в data-source'е
					// ссылаются на родителя под индексом 1. Поэтому сдвинем индекс.
					nArg -= 1;
				}
				if (nArg > treeRequest.Path.Length-1)
					throw new XTreeStructException("Значение аргумента функции @@ParentID превышает уровень узла в дереве");
				sValue = cmd.Connection.ArrangeSqlGuid(treeRequest.Path[nArg].ObjectID);
				
				cmd.CommandText = cmd.CommandText.Replace(matchInner.Value, sValue);
			}
		}

		/// <summary>
		/// Вычисляет и подставляет функцию-макрос @@RecursiveExp.
		/// Функция должна вычисляться ПЕРЕД вычислением @@ParentID
		/// </summary>
		/// <param name="treelevel">описание уровня</param>
		/// <param name="cmd">DB-команда загрузки данных</param>
		/// <param name="nRecurLevel">Уровень рекурсии (начиная с 0)</param>
		protected void evaluateRecursiveExp(XTreeLevelInfoIT treelevel, XDbCommand cmd, int nRecurLevel)
		{
			string sParam;			// аргумент @@RecursiveExp
			string sValue;			// значение функции/макроса
			string sEnterCondition;	// условие для 1-го уровня рекурсии (условие вхождения в рекурсию)
			Regex re;				// для поиска @@RecursiveExp
			Match match;
			int nRecursiveExpStart = 0;		// индекс начала выражения @@RecursiveExp(...)

			match = Regex.Match(cmd.CommandText, @"@@RecursiveExp\s*\(", RegexOptions.IgnoreCase);
			if (match.Success)
			{
				if (!treelevel.IsRecursive)
					throw new ApplicationException("Некорректное описание иерархии: Функция @@RecursiveExp может использоваться только в источниках данных рекурсивных уровней");
				// определим границы для поиска аргументов функции @@RecursiveExp
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
					throw new ApplicationException("Не найдена закрывающая скобка вызова функции @@RecursiveExp");
				re = new Regex("(?<param>[^,]+)(,(?<entercondition>.+))?");
				match = re.Match(cmd.CommandText, nStart, nEnd - nStart);
				if (match.Success)
				{
					sParam = match.Result("${param}");
					if (sParam == null || sParam.Trim().Length == 0)
						throw new ApplicationException("Не задан аргумент функции @@RecursiveExp");
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
		/// Подставляет макрос @@RC (уровень рекурсии) в тексте запроса
		/// </summary>
		/// <param name="cmd">DB-команда загрузки данных</param>
		/// <param name="nRecurLevel">Уровень рекурсии (начиная с 0)</param>
		/// <returns>Модифицированный текст команды(запроса)</returns>
		protected virtual void evaluateRecurLevelMacro( XDbCommand cmd, int nRecurLevel ) 
		{
			string sValue;		// значение макроса @@RC
			string sCmdText = cmd.CommandText;

			sValue = nRecurLevel > 0 ? nRecurLevel.ToString() : String.Empty;
			Regex re = new Regex(@"@@RC", RegexOptions.IgnoreCase);
			cmd.CommandText = re.Replace(sCmdText, sValue);
		}

		/// <summary>
		/// Возвращает уровень рекурсии текущего запроса; 0 - если рекурсии нет.
		/// </summary>
		/// <param name="treelevel">Текущий уровень</param>
		/// <param name="treeRequest">запрос команды</param>
		/// <returns>
		/// Количество элементов с совпадающим значением от начала, минус один;
		/// Ноль - если рекурсии нет
		/// </returns>
		protected virtual int getRecurrenceLevel( XTreeLevelInfoIT treelevel, XGetTreeDataRequest treeRequest ) 
		{
			// для корневых уровней не может быть рекурсии
			if (treeRequest.Action == XTreeAction.GetRoot)
				return 0;
			int nRecurLevel = 0;
			string[] aNodeTypes = treeRequest.Path.GetNodeTypes();	// путь в дереве до текущего узла
			if (treelevel.ObjectType == aNodeTypes[0])
			{
				for(int i=1; i<aNodeTypes.Length; i++)
				{
					if ( aNodeTypes[i] == aNodeTypes[i-1] )
						nRecurLevel++;
					else
						break;
				}
				// для команды GET_CHILDREN путь до текущего уровня не учитывает уровень, даныне которого формируются (treelevel),
				// поэтому номер рекурсии увеличим на 1
				if (treeRequest.Action == XTreeAction.GetChildren)
					nRecurLevel++;
			}
			return nRecurLevel;
		}

		/// <summary>
		/// Вычислим функцию @@ParentIDByType - возвращает идентификатор объекта заданого типа - 
		// первого, встретившегося при проходе по пути от запрошенного узла до корня
		/// Подставляет результат в текст команды (запроса)
		/// </summary>
		/// <param name="cmd">DB-команда загрузки данных</param>
		/// <param name="treeRequest">запрос</param>
		protected virtual void evaluateParentIDByTypeFunc(XDbCommand cmd, XGetTreeDataRequest treeRequest)
		{
			string sValue;			// значение функции/макроса
			Regex RegExp;			// для поиска "@@ParentIDByType"
			int nStart;				// индекс, с которого начинается просмотр пути (0 - getchildren, 1 - getnode)

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
					throw new XInvalidMetadataException("Некорректно составленный data-source одного из уровней иерархии " + treeRequest.MetaName + 
						". Макрос @@ParentIDByType ссылается на тип " +  sTypeName + ", не найденный в пути: " + treeRequest.Path.ToString());
			}
		}

		#endregion

		protected XTreeLoadData readTreeData(XTreeLoadData treeData, XDataSource datasource, XTreeLevelInfoIT treelevel, XGetTreeDataRequest treeRequest)
		{
			string sFieldName;						// наименование колонки
			HybridDictionary excludedNodes = null;	// словарь игнорируемых узлов
			// Наименования колонок в командах(запросах) построения уровней дерева:
			/// <summary>
			/// Идентификатор объекта
			/// </summary>
			const string FIELD_OBJECTID = "OBJECTID";
			/// <summary>
			/// Текст, отображаемый для узла в иерархии
			/// </summary>
			const string FIELD_TITLE = "TITLE";
			/// <summary>
			/// Селектор иконки
			/// </summary>
			const string FIELD_ICONSELECTOR = "ICON_SELECTOR";
			/// <summary>
			/// Признак листового узла (1-листовой,0-нелистовой)
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
									// идентификатор (для виртуальных узлов может быть не задан)
								case FIELD_OBJECTID:
									if (!reader.IsDBNull(i))
									{
										nodeData.ObjectID = reader.GetGuid(i);
										if (excludedNodes != null && excludedNodes.Contains(treelevel.ObjectType + ":" + nodeData.ObjectID))
											continue;
									}
									break;
									// заголовок узла
								case FIELD_TITLE:
									if (!reader.IsDBNull(i))
										nodeData.Title= reader.GetString(i);
									break;
									// селектор иконки, при условии, что отображение иконок не отключено
								case FIELD_ICONSELECTOR:
									if (!reader.IsDBNull(i))
										nodeData.Icon = reader.GetValue(i).ToString();
									break;
									// признак листового узла
								case FIELD_ISLEAF:
									if (!reader.IsDBNull(i))
										nodeData.IsLeafNode = reader.GetInt32(i) == 1;
									break;
									// пользовательские данные
								default:
									if (!reader.IsDBNull(i))
									{
										// получим значение с учетом типа колонки, который может быть задан для источника данных
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
							throw new ApplicationException("Некорректный формат колонки " + sFieldName + ".\nIDataRecord::GetFieldType: " + reader.GetFieldType(i).FullName + "\nIDataRecord.GetValue: " + reader.GetValue(i).ToString(), ex);
						}
					}
                    if (nodeData!= null)
					treeData.Nodes.Add(nodeData);
				}
			}
			return treeData;
		}

		/// <summary>
		/// Возвращает массив типизированных метаописаний уровней иерархии, соответствующих команде и пути
		/// </summary>
		/// <param name="action">команда дерева (получить узел, получить детей, получить корни)</param>
		/// <param name="treeParams">runtime параметры дерева</param>
		/// <param name="treePath">путь от текущего узла до корня</param>
		/// <returns></returns>
		protected XTreeLevelInfoIT[] getTreeLevels(XTreeStructInfo treeStructInfo, XTreeAction action, XParamsCollection treeParams, XTreePath treePath) 
		{
			XTreeLevelInfoIT[] treelevels;
			switch (action)
			{
				case XTreeAction.GetRoot:
					// "Команда" на получение данных корневых узлов иерархии
					treelevels = treeStructInfo.Executor.GetRoots(treeStructInfo, treeParams);
					break;

				case XTreeAction.GetNode:
					// "Команда" на получение данных узла, заданного в запросе
					treelevels = new XTreeLevelInfoIT[] { treeStructInfo.Executor.GetTreeLevel(treeStructInfo, treeParams, treePath) };
					break;

				case XTreeAction.GetChildren:
					// "Команда" на получение данных узлов, подчиненных узлу, заданному в запросе
					treelevels = treeStructInfo.Executor.GetTreeLevel(treeStructInfo, treeParams, treePath).GetChildTreeLevelsAffected(treeParams);
					break;

				default:
					// Других случаев "команд" быть не может - это ошибка:
					throw new ArgumentException("Неизвестная команда загрузки данных");
			}
			return treelevels;
		}
	}
    
    
}