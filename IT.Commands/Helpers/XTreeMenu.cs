using System;
using System.Collections;
using System.Reflection;
using System.Xml;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Hierarchy
{
	/// <summary>
	/// Описание прикладного клиентского обработчика
	/// </summary>
	public class XUserCodeWeb
	{
		/// <summary>
		/// клиентский код
		/// </summary>
		private string m_sCode;
		/// <summary>
		/// значение mode="replace"
		/// </summary>
		private bool m_bReplace;

		public XUserCodeWeb(string sCode, bool bReplace)
		{
			m_sCode = sCode;
			m_bReplace = bReplace;
		}
		public XUserCodeWeb(string sCode) 
			: this(sCode, false)
		{}

		public string Code
		{
			get { return m_sCode; }
		}

		public bool Replace
		{
			get { return m_bReplace; }
		}
	}

	/// <summary>
	/// Описание меню для Web-клиента
	/// </summary>
	public class XMenuWeb: XMenu
	{
		protected const string NAMESPACE_URI = "http://www.croc.ru/Schemas/XmlFramework/Interface/1.0";
		/// <summary>
		/// Коллекция visibility-handler'ов
		/// </summary>
		protected ArrayList m_visibilityHandlers;		// List<XUserCodeWeb>
		/// <summary>
		/// Коллекция macro-resolver'ов
		/// </summary>
		protected ArrayList m_macroResolvers;			// List<XUserCodeWeb>
		/// <summary>
		/// Коллекция execution-handler'ов
		/// </summary>
		protected ArrayList m_executionHandlers;		// List<XUserCodeWeb>
		/// <summary>
		/// Имя страницы с XSLT шаблоном, используемым для рендеринга меню в HTML
		/// </summary>
		protected string m_sStylesheet;

		/// <summary>
		/// Коллекция visibility-handler'ов
		/// List<XUserCodeWeb>
		/// </summary>
		public ArrayList VisibilityHandlers
		{
			get { return m_visibilityHandlers; }
			set
			{
				if (value == null)
					m_visibilityHandlers = new ArrayList();
				else
					m_visibilityHandlers = value;
			}
		}

		/// <summary>
		/// Коллекция macro-resolver'ов
		/// List<XUserCodeWeb>
		/// </summary>
		public ArrayList MacroResolvers
		{
			get { return m_macroResolvers; }
			set
			{
				if (value == null)
					m_macroResolvers = new ArrayList();
				else
					m_macroResolvers = value;
			}
		}

		/// <summary>
		/// Коллекция execution-handler'ов
		/// List<XUserCodeWeb>
		/// </summary>
		public ArrayList ExecutionHandlers
		{
			get { return m_executionHandlers; }
			set
			{
				if (value == null)
					m_executionHandlers = new ArrayList();
				else
					m_executionHandlers = value;
			}
		}

		/// <summary>
		/// Имя страницы с XLST шаблоном, используемым для рендеринга меню в HTML
		/// TODO: убрать new когда одноименное свойство исчезнет из XMenu
		/// </summary>
		public new string Stylesheet
		{
			get { return m_sStylesheet; }
			set
			{
				if (value != null && value.Length == 0)
					value = null;
				m_sStylesheet = value;
			}
		}


		public XMenuWeb(string sCaption) 
			: this(sCaption, false)
		{}
		public XMenuWeb(string sCaption, bool bTrustworthy)
			: base(sCaption, bTrustworthy)
		{
			m_visibilityHandlers = new ArrayList();
			m_macroResolvers = new ArrayList();
			m_executionHandlers = new ArrayList();
		}

		public override XmlElement ToXml(XmlDocument doc, XmlNamespaceManager nsManager)
		{
			XmlElement xmlRoot = doc.CreateElement("i:menu", NAMESPACE_URI);
			if (Trustworthy)
				xmlRoot.SetAttribute("trustworthy", "1");
			doc.AppendChild(xmlRoot);
			xmlRoot.AppendChild( doc.CreateElement("i:caption", NAMESPACE_URI) ).InnerText = Caption;
			if (MacroResolvers.Count > 0)
				foreach(XUserCodeWeb code in MacroResolvers)
					writeUserCodeRef("i:macros-resolver", code, xmlRoot);
				
			if (VisibilityHandlers.Count > 0)
				foreach(XUserCodeWeb code in VisibilityHandlers)
					writeUserCodeRef("i:visibility-handler", code, xmlRoot);
				
			if (ExecutionHandlers.Count > 0)
				foreach(XUserCodeWeb code in ExecutionHandlers)
					writeUserCodeRef("i:execution-handler", code, xmlRoot);

			foreach(XMenuItemBase item in Items)
			{
				xmlRoot.AppendChild(item.ToXml(doc, nsManager));
			}
			return xmlRoot;
		}

		/// <summary>
		/// Создает xml-элемет с определением прикладного обработчика
		/// </summary>
		/// <param name="sElementName">наименование элемента (fully qualified)</param>
		/// <param name="code">описание кода</param>
		/// <param name="xmlParent">родительский элемент для создаваемого</param>
		private void writeUserCodeRef(string sElementName, XUserCodeWeb code, XmlElement xmlParent)
		{
			XmlElement xml = (XmlElement)xmlParent.AppendChild(xmlParent.OwnerDocument.CreateElement(sElementName, NAMESPACE_URI));
			xml.InnerText = code.Code;
			if (code.Replace)
				xml.SetAttribute("mode", "replace");	
		}
	}

	/// <summary>
	/// Описание меню иерархии
	/// </summary>
	public class XTreeMenuInfo : XMenuWeb
	{
		/// <summary>
		/// Метод кеширования
		/// </summary>
		protected XTreeMenuCacheMode m_cacheMode;

		public XTreeMenuInfo(string sCaption) 
			: base(sCaption)
		{}
		public XTreeMenuInfo(string sCaption, bool bTrustworthy)
			: base(sCaption, bTrustworthy)
		{}

		/// <summary>
		/// Возвращает режим кешируемости меню
		/// </summary>
		public XTreeMenuCacheMode CacheMode
		{
			get { return m_cacheMode; }
			set { m_cacheMode = value; }
		}


		public override XmlElement ToXml(XmlDocument doc, XmlNamespaceManager nsManager)
		{
			XmlElement xmlRoot = base.ToXml(doc, nsManager);
			XTreeMenuCacheMode cacheMode = CacheMode;
			if ( cacheMode == XTreeMenuCacheMode.Unknow)
				cacheMode = XTreeMenuCacheMode.Level;
			xmlRoot.SetAttribute("cache-for", XTreeMenuCacheModeParser.ToString(cacheMode));
			return xmlRoot;
		}

		public override XMenuItemBase Clone()
		{
			XTreeMenuInfo menu = new XTreeMenuInfo(this.Caption, this.Trustworthy);
			menu.CacheMode = this.CacheMode;
			menu.ExecutionHandlers.AddRange(this.ExecutionHandlers);
			menu.VisibilityHandlers.AddRange(this.VisibilityHandlers);
			menu.MacroResolvers.AddRange(this.MacroResolvers);
			menu.Stylesheet = this.Stylesheet;
			foreach(XMenuItemBase item in this.Items)
				menu.Items.Add(item.Clone());
			return menu;
		}
	}

	
	/// <summary>
	/// Обработчик меню иерархии. 
	/// Содержит описание меню из метаданных (если оно было) и ссылку на провайдена получения данных меню (если он задан)
	/// Если не задано ни метаописание, ни провайдер, меню считается пустым - 
	/// для получения обработчика такого меню следует использовать статическое свойство Empty.
	/// В runtime вызывается метод GetMenu. Объект создается и заполняется провайдером конструирования меню (IXTreeMenuProvider)
	/// </summary>
	public class XTreeMenuHandler
	{
		/// <summary>
		/// Метаописание меню (или null)
		/// </summary>
		protected XTreeMenuInfo m_menuMD;
		/// <summary>
		/// Провайдер-загрузчик меню (или null)
		/// </summary>
		protected IXTreeLevelMenuDataProvider m_dataProvider;
		/// <summary>
		/// Признак неизменности экземпляра (для гарантирования неизменяемости "пустого" меню
		/// </summary>
		protected bool m_bImmutable;

		public XTreeMenuHandler()
		{}
		public XTreeMenuHandler(XTreeMenuInfo menuMD, IXTreeLevelMenuDataProvider dataProvider)
		{
			m_menuMD = menuMD;
			m_dataProvider = dataProvider;
		}

		/// <summary>
		/// Возвращает меню в runtime'e. Если определен провайдер запрашивает меню у него, иначе возвращает метаописание
		/// </summary>
		/// <param name="treeLevelInfo">Уровень для которого требуется меню или null, если меню строиться для пустой иерархии</param>
		/// <param name="request">параметры с клиента</param>
		/// <param name="context"></param>
		/// <returns>Данные меню или null</returns>
		public XTreeMenuInfo GetMenu(XTreeLevelInfoIT treeLevelInfo, XGetTreeMenuRequest request, IXExecutionContext context)
		{
			if (m_dataProvider != null)
				return m_dataProvider.GetMenu(treeLevelInfo, request, context);
			if (m_menuMD != null)
			{
				// вернем копию метаописания меню (копию для того, чтобы нам ее не испортили)
				// В данном случае метаописание меню - это просто заготовка
				return (XTreeMenuInfo)m_menuMD.Clone();
			}
			return null;
		}

		/// <summary>
		/// Метаописание меню (или null)
		/// </summary>
		public XTreeMenuInfo MenuMetadata
		{
			get { return m_menuMD; }
			set
			{
				if (m_bImmutable)
					throw new InvalidOperationException("Данные экземпляра XTreeMenuHandler не могут быть изменены");
				m_menuMD = value;
			}
		}

		/// <summary>
		/// Провайдер-загрузчик меню (или null)
		/// </summary>
		public IXTreeLevelMenuDataProvider DataProvider
		{
			get { return m_dataProvider; }
			set
			{
				if (m_bImmutable)
					throw new InvalidOperationException("Данные экземпляра XTreeMenuHandler не могут быть изменены");
				m_dataProvider = value;
			}
		}

		
		/// <summary>
		/// единственный экземпляр описателя пустого меню (отложенная инциализация)
		/// </summary>
		private static XTreeMenuHandler m_emptyMenuHandler;
		/// <summary>
		/// Возвращает единственный экземпляр описателя пустого меню
		/// </summary>
		public static XTreeMenuHandler Empty
		{
			get
			{
				if (m_emptyMenuHandler == null)
				{
					m_emptyMenuHandler = new XTreeMenuHandler(null, null);
					m_emptyMenuHandler.m_bImmutable = true;
				}
				return m_emptyMenuHandler;
			}
		}
	}


	/// <summary>
	/// Интерфейс провайдера данных меню для уровня. 
	/// Наименование класса-реализации интерфейса может задаваться в атрибуте data-provider элементов level-menu, empty-tree-menu, default-level-menu.
	/// "Стандартная" реализация отсутствует.
	/// </summary>
	public interface IXTreeLevelMenuDataProvider
	{
		/// <summary>
		/// Получение меню в runtime для уровня (treeLevelInfo задан) или пустой иерархии (treeLevelInfo равен null)
		/// </summary>
		/// <param name="treeLevelInfo">описание уровня, для которого запрашивается меню, или null</param>
		/// <param name="request">параметры с клиента</param>
		/// <param name="context"></param>
		/// <returns></returns>
		XTreeMenuInfo GetMenu(XTreeLevelInfoIT treeLevelInfo, XGetTreeMenuRequest request, IXExecutionContext context);
	}


	/// <summary>
	/// Интерфейс построителя меню из метаданных
	/// </summary>
	public interface IXTreeMenuHandlerFactory
	{
		/// <summary>
		/// Конструирует обработчик меню на основании xml-узла метаописнаия
		/// </summary>
		/// <param name="xmlLevelMenu">xml-узел level-menu или empty-tree-menu или default-level-menu</param>
		/// <returns>Обработчик меню. Никогда не null</returns>
		XTreeMenuHandler CreateMenuHandler(XmlElement xmlLevelMenu);
	}

	/// <summary>
	/// Стандартный построитель меню из метаописания
	/// </summary>
	public class XTreeMenuHandlerFactoryStd : IXTreeMenuHandlerFactory
	{
		protected XMetadataManager m_mdManager;
			
		public XTreeMenuHandlerFactoryStd(XMetadataManager mdManager)
		{
			m_mdManager = mdManager;
		}

		public XTreeMenuHandler CreateMenuHandler(XmlElement xmlLevelMenu)
		{
			XTreeMenuHandler menuHandler;
			if (xmlLevelMenu == null)
				menuHandler = XTreeMenuHandler.Empty;
			else
			{
				XTreeMenuInfo menuInfo = createMenuInfo(xmlLevelMenu);
				IXTreeLevelMenuDataProvider prv = getTreeLevelMenuDataProvider(xmlLevelMenu);
				if (menuInfo == null && prv == null)
					menuHandler = XTreeMenuHandler.Empty;
				else
					menuHandler = new XTreeMenuHandler( menuInfo, prv);
			}
			return menuHandler;
		}

		/// <summary>
		/// Возвращает описатель меню по метаданным
		/// </summary>
		/// <param name="xmlMenu">xml-узел i:level-menu,i:empty-tree-menu,i:default-level-menu</param>
		/// <returns>Объект меню или null, если метаописание меню не содержит структуры (i:menu)</returns>
		protected XTreeMenuInfo createMenuInfo(XmlElement xmlMenu)
		{
			XTreeMenuInfo menu = null;
			XmlNamespaceManager nsMan = m_mdManager.NamespaceManager;
			XTreeMenuCacheMode cacheMode;
			string sValue = xmlMenu.GetAttribute("cache-for");
			if (sValue.Length > 0)
				cacheMode = XTreeMenuCacheModeParser.Parse(sValue);
			else
				cacheMode = XTreeMenuCacheMode.Unknow;

			xmlMenu = (XmlElement)xmlMenu.SelectSingleNode("i:menu", nsMan);
			if (xmlMenu != null)
			{
				string sCaption;
				XmlNode node = xmlMenu.SelectSingleNode("i:caption/text() | @t", nsMan);
				if (node != null)
					sCaption = node.InnerText;
				else
					sCaption = String.Empty;
				menu = new XTreeMenuInfo(sCaption);

				// заполним коллекции обрабочиков
				foreach(XmlElement xmlNode in xmlMenu.SelectNodes("i:macros-resolver", nsMan))
					menu.MacroResolvers.Add( new XUserCodeWeb(xmlNode.InnerText, xmlNode.GetAttribute("mode") == "replace"));
				
				foreach(XmlElement xmlNode in xmlMenu.SelectNodes("i:visibility-handler", nsMan))
					menu.VisibilityHandlers.Add( new XUserCodeWeb(xmlNode.InnerText, xmlNode.GetAttribute("mode") == "replace"));

				foreach(XmlElement xmlNode in xmlMenu.SelectNodes("i:execution-handler", nsMan))
					menu.ExecutionHandlers.Add( new XUserCodeWeb(xmlNode.InnerText, xmlNode.GetAttribute("mode") == "replace"));

				buildMenuItems(menu, xmlMenu);
				menu.CacheMode = cacheMode;
			}

			return menu;
		}

		protected void buildMenuItems(XMenuSectionBase menu, XmlElement xmlMenu)
		{
			XmlNamespaceManager nsMan = m_mdManager.NamespaceManager;
			XmlNode node;
			string sCaption;
			string sValue;
			XMenuActionItem actionItem;
			foreach(XmlElement xmlMenuItem in xmlMenu.SelectNodes("i:menu-item-info | i:menu-item-separ | i:menu-item | i:menu-section", nsMan))
			{
				switch(xmlMenuItem.LocalName)
				{
					case "menu-item-info":
						node = xmlMenuItem.SelectSingleNode("i:caption/text() | @t", nsMan);
						sCaption = node != null ? node.InnerText : String.Empty;
						node = xmlMenuItem.SelectSingleNode("i:value", nsMan);
						sValue = node != null ? node.InnerText : String.Empty;
						menu.Items.AddInfoItem(sCaption, sValue);
						break;
					case "menu-item-separ":
						menu.Items.AddSeparatorItem();
						break;
					case "menu-item":
						node = xmlMenuItem.SelectSingleNode("i:caption/text() | @t", nsMan);
						sCaption = node != null ? node.InnerText : String.Empty;
						actionItem = menu.Items.AddActionItem(sCaption, xmlMenuItem.GetAttribute("action"));
						actionItem.SeparatorBefore = xmlMenuItem.HasAttribute("separator-before");
						actionItem.SeparatorAfter = xmlMenuItem.HasAttribute("separator-after");
						actionItem.Hint = xmlMenuItem.GetAttribute("hint");
						actionItem.Hotkey = xmlMenuItem.GetAttribute("hotkey");
						actionItem.Hidden = xmlMenuItem.HasAttribute("hidden");
						actionItem.Disabled = xmlMenuItem.HasAttribute("disabled");
						actionItem.Default = xmlMenuItem.HasAttribute("default");
						actionItem.MayBeDefault = xmlMenuItem.HasAttribute("may-be-default");
						foreach(XmlElement xmlParam in xmlMenuItem.SelectNodes("i:params/i:param", nsMan))
						{
							actionItem.Parameters.Add(xmlParam.GetAttribute("n"), xmlParam.InnerText);
						}
						break;
					case "menu-section":
						node = xmlMenuItem.SelectSingleNode("i:caption/text() | @t", nsMan);
						sCaption = node != null ? node.InnerText : String.Empty;
						XMenuSection menu_sec = menu.Items.AddSection(sCaption);
						buildMenuItems(menu_sec, xmlMenuItem);
						break;
				}
			}
		}
		protected IXTreeLevelMenuDataProvider getTreeLevelMenuDataProvider(XmlElement xmlLevelMenu)
		{
			if (xmlLevelMenu.HasAttribute("data-provider", XTreeController.NAMESPACE_URI))
			{
				string sTypeName = xmlLevelMenu.GetAttribute("data-provider", XTreeController.NAMESPACE_URI);
				Type type = Type.GetType(sTypeName, false, true);
				if (type == null)
					throw new XInvalidMetadataException("Не удалось создать экземпляр data-provider'a меню: " + sTypeName );
				if (!type.IsSubclassOf(typeof(IXTreeLevelMenuDataProvider)))
				if (type.GetInterface(typeof(IXTreeLevelMenuDataProvider).FullName,true) == null)
					throw new XInvalidMetadataException("data-provider меню " + sTypeName  + " не реализует интерфейс " + typeof(IXTreeLevelMenuDataProvider).FullName);
				ConstructorInfo ctor = type.GetConstructor(Type.EmptyTypes);
				if (ctor == null)
					throw new XInvalidMetadataException("data-provider меню " + sTypeName  + " не содержит конструктора ctor()" );
				// вызовем конструктор
				// TODO: try-catch
				return (IXTreeLevelMenuDataProvider)ctor.Invoke(new object[0]);
			}
			return null;
		}
	}


	/// <summary>
	/// Интерфейс загрузчика меню для всей иерархии
	/// </summary>
	public interface IXTreeMenuDataProvider
	{
		XTreeMenuInfo GetMenu(XGetTreeMenuRequest request, IXExecutionContext context, XTreePageInfoStd treePage);
		XTreeMenuInfo GetMenuForEmptyTree(XGetTreeMenuRequest request, IXExecutionContext context, XTreePageInfoStd treePage);
	}

	/// <summary>
	/// "Стандартная" реализация. Запрашивает меню у текущего уровня, если у него отсутсвует меню, то использует дефолтное меню иерархии
	/// </summary>
	public class XTreeMenuDataProviderStd: IXTreeMenuDataProvider
	{
		public virtual XTreeMenuInfo GetMenu(XGetTreeMenuRequest request, IXExecutionContext context, XTreePageInfoStd treePage)
		{
			XTreeStructInfo treeStructInfo = treePage.TreeStruct;
			XTreeLevelInfoIT treelevel = treeStructInfo.Executor.GetTreeLevel(treeStructInfo, request.Params, request.Path);
			XTreeMenuInfo treemenu = treelevel.GetMenu(request, context);
			if (treemenu == null)
				treemenu = treePage.DefaultLevelMenu.GetMenu(treelevel, request, context);
			return treemenu;
		}

		public virtual XTreeMenuInfo GetMenuForEmptyTree(XGetTreeMenuRequest request, IXExecutionContext context, XTreePageInfoStd treePage)
		{
			return treePage.EmptyTreeMenu.GetMenu(null, request, context);
		}
	}
}