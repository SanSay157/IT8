using System;
using System.Collections;
using System.Collections.Specialized;
using System.Xml;

namespace Croc.IncidentTracker.Hierarchy
{
	/// <summary>
	/// Базовый класс для классов, описывающих пункты меню.
	/// </summary>                                         
	public abstract class XMenuItemBase
	{
		/// <summary>
		/// Уникальный идентификатор элемента меню
		/// </summary>
		private Guid m_uniqueID;

		/// <summary>
		/// Конструктор по умолчанию. 
		/// </summary>                
		public XMenuItemBase()
		{
			m_uniqueID = Guid.NewGuid();
		}

		/// <summary>
		/// Уникальный идентификатор элемента меню, полученный при создании. 
		/// </summary>                                                       
		public Guid UniqueID
		{
			get { return m_uniqueID; }
		}

		/// <summary>
		/// Метод формирует XML-представление пункта меню. Должен реализовываться
		/// всем наследниками.
		/// </summary>
		/// <param name="doc">Экземпляр XmlDocument, в контексте которого
		///                   будет создаваться XML\-представление пункта
		///                   меню.</param>
		/// <param name="nsManager">Экземпляр XmlNamespaceManager, используемый
		///                         для получения URI\-пространства имен для
		///                         префикса &quot;i&quot;. </param>
		/// <returns>
		/// XML-узел пункта меню (зависит от реализации). 
		/// </returns>                                                           
		public abstract XmlElement ToXml(XmlDocument doc, XmlNamespaceManager nsManager);
		/// <summary>
		/// Метод возвращает полную копию элемента (полная копия - это копия данных
		/// самого элемента, а также всех вложенных в него элементов). 
		/// </summary>                                                             
		public abstract XMenuItemBase Clone();
	}

	/// <summary>
	/// Базовый класс для описания сущности меню, содержащего подчиненные узлы
	/// (само меню и секция).
	/// </summary>
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuItemBase"/>            
	public abstract class XMenuSectionBase: XMenuItemBase
	{
		/// <summary>
		/// Заголовок меню
		/// </summary>
		protected string m_sCaption;
		/// <summary>
		/// Элементы меню
		/// </summary>
		protected XMenuItemCollection m_items = new XMenuItemCollection();

		/// <summary>
		/// Параметризированный конструктор.
		/// </summary>
		/// <param name="sCaption">Заголовок меню.</param>
		public XMenuSectionBase(string sCaption)
		{
			Caption = sCaption;
		}

		/// <summary>
		/// Заголовок меню. 
		/// </summary>      
		public string Caption
		{
			get { return m_sCaption; }
			set
			{
				m_sCaption = value;
				if (m_sCaption == null)
					m_sCaption = String.Empty;
			}
		}

		/// <summary>
		/// Элементы меню. 
		/// </summary>     
		public XMenuItemCollection Items
		{
			get { return m_items; }
		}
	}

	/// <summary>
	/// «Корневой» класс, описывающий меню. 
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuItemBase"/>
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuSectionBase"/>
	/// </summary>                          
	public class XMenu : XMenuSectionBase
	{
		/// <summary>
		/// Используемое по умолчанию пространство имен для префикса "i"
		/// </summary>
		private const string NAMESPACE_URI = "http://www.croc.ru/Schemas/XmlFramework/Interface/1.0";
		/// <summary>
		/// Признак, что состав меню "заслуживает доверия", и проверка прав с клиента для него не нужна
		/// </summary>
		private bool m_bTrustworthy;
		/// <summary>
		/// Имя страницы с XSLT шаблоном, используемым для рендеринга меню в HTML
		/// </summary>
		private string m_sStylesheet;

		/// <summary>
		/// Параметризированный конструктор.
		/// </summary>
		/// <param name="sCaption">Заголовок меню. Значение NULL и пустая строка
		///                        допустимы.</param>                           
		public XMenu(string sCaption) : base(sCaption)
		{
			m_bTrustworthy = false;
		}
	
		/// <summary>
		/// Параметризированный конструктор.
		/// </summary>
		/// <param name="sCaption">Заголовок меню. Значение NULL и пустая
		///                        строка допустимы.</param>
		/// <param name="bTrustworthy">Признак того, что формируемое меню
		///                            «заслуживает доверия», т.е. выполнять
		///                            проверку прав с клиента нет необходимости.</param>
		public XMenu(string sCaption, bool bTrustworthy): base(sCaption)
		{
			m_bTrustworthy = bTrustworthy;
		}

		/// <summary>
		/// Признак «меню заслуживает доверия» - дополнительная проверка прав с
		/// клиента не требуется. 
		/// </summary>                                                         
		public bool Trustworthy
		{
			get { return m_bTrustworthy; }
			set { m_bTrustworthy = value; }
		}

		/// <summary>
		/// Наименование страницы с XSLT-шаблоном, используемым для рендеринга меню
		/// в HTML. 
		/// </summary>                                                             
		public string Stylesheet
		{
			get { return m_sStylesheet; }
			set { m_sStylesheet = value; }
		}

		/// <summary>
		/// Метод производит «сериализацию» меню со всеми вложенными объектами в
		/// формате, описываемом схемой x-net-interface-schema.xsd.
		/// </summary>
		/// <param name="doc">Экземпляр XmlDocument, в контексте которого
		///                   будет создаваться XML\-представление меню.</param>
		/// <param name="nsManager">Экземпляр XmlNamespaceManager, используемый
		///                         для получения URI\-пространства имен для
		///                         префикса &quot;i&quot;, используемого для
		///                         формируемых узлов XML\-представления меню.
		///                         Если менеджер не задан, то используется
		///                         «http\://www.croc.ru/Schemas/XmlFramework/Interface/1.0».</param>
		/// <returns>
		/// XML-узел <b>i:menu</b>. 
		/// </returns>                                                                               
		public override XmlElement ToXml(XmlDocument doc, XmlNamespaceManager nsManager)
		{
			doc.LoadXml( String.Format(
				"<i:menu xmlns:i='{0}'{1}>" +
				"<i:caption>{2}</i:caption>" +
				"</i:menu>", 
				NAMESPACE_URI,	// 0
				m_bTrustworthy ? " trustworthy=\"1\"" : "",	// 1
				Caption			// 2
				) );
			foreach(XMenuItemBase item in Items)
			{
				doc.DocumentElement.AppendChild(item.ToXml(doc, nsManager));
			}
			return doc.DocumentElement;
		}

		/// <summary>
		/// Метод возвращает копию элемента.
		/// </summary>
		public override XMenuItemBase Clone()
		{
			XMenu menu = new XMenu(Caption, Trustworthy);
			menu.Stylesheet = Stylesheet;
			foreach(XMenuItemBase item in Items)
				menu.Items.Add(item.Clone());
			return menu;
		}

		/// <summary>
		/// Метод производит «сериализацию» меню со всеми вложенными объектами в
		/// формате, описываемом схемой x-net-interface-schema.xsd.
		/// </summary>
		/// <returns>
		/// XML-узел <b>i:menu</b>.
		/// </returns>
		/// <remarks>
		/// Метод вызывает виртуальный метод <see cref="Croc.XmlFramework.Commands.XMenu.ToXml@XmlDocument@XmlNamespaceManager" text="ToXml" />
		/// для каждого экземпляра описателя пункта меню (производного от <see cref="Croc.XmlFramework.Commands.XMenuItemBase" text="XMenuItemBase" />)
		/// из своей коллекции элементов (<see cref="Croc.XmlFramework.Commands.XMenuSectionBase.Items" text="Items" />,
		/// свойство базового класса). 
		/// </remarks>                                                                                                                                 
		public XmlElement ToXml()
		{
			XmlDocument doc = new XmlDocument();
			XmlNamespaceManager nsManager = new XmlNamespaceManager(doc.NameTable);
			nsManager.AddNamespace("i", NAMESPACE_URI);
			return ToXml(doc, nsManager);
		}
	}

	/// <summary>
	/// Класс описывает коллекцию элементов пунктов меню. Экземпляры этого
	/// класса содержат классы <see cref="Croc.XmlFramework.Commands.XMenu" text="XMenu" />
	/// и <see cref="Croc.XmlFramework.Commands.XMenuSection" text="XMenuSection" />.
	/// <seealso cref="Croc.XmlFramework.Commands.XMenu"/>
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuSection"/>
	/// </summary>                                                                         
	public class XMenuItemCollection: IEnumerable
	{
		/// <summary>
		/// Коллекция пунктов меню
		/// </summary>
		ArrayList m_items = new ArrayList();

		/// <summary>
		/// Метод осуществляет добавление исполняемого пункта меню в конец списка
		/// элементов.
		/// </summary>
		/// <param name="sTitle">Заголовок пункта меню.</param>
		/// <param name="sAction">Наименование действия.</param>
		/// <returns>
		/// Созданный пункт.
		/// </returns>                                                           
		public XMenuActionItem AddActionItem(string sTitle, string sAction)
		{
			XMenuActionItem item = new XMenuActionItem(sTitle, sAction);
			Add(item);
			return item;
		}

		/// <summary>
		/// Метод осуществляет добавление информационного пункта меню в конец
		/// списка элементов.
		/// </summary>
		/// <param name="sCaption">Заголовок пункта меню.</param>
		/// <param name="sValue">Значение пункта меню.</param>
		/// <returns>
		/// Созданный пункт.
		/// </returns>                                                       
		public XMenuInfoItem AddInfoItem(string sCaption, string sValue)
		{
			XMenuInfoItem item = new XMenuInfoItem(sCaption, sValue);
			Add(item);
			return item;
		}

		/// <summary>
		/// Метод осуществляет добавление секции (подменю) в конец списка
		/// элементов.
		/// </summary>
		/// <param name="sTitle">Заголовок секции (подменю).</param>
		/// <returns>
		/// Созданная секция.
		/// </returns>                                                   
		public XMenuSection AddSection(string sTitle)
		{
			XMenuSection item = new XMenuSection(null, sTitle);
			Add(item);
			return item;
		}

		/// <summary>
		/// Метод осуществляет добавление разделителя в конец списка элементов.
		/// </summary>
		/// <returns>
		/// Созданный разделитель. 
		/// </returns>                                                         
		public XMenuSeparatorItem AddSeparatorItem()
		{
			XMenuSeparatorItem item = new XMenuSeparatorItem();
			Add(item);
			return item;
		}

		/// <summary>
		/// Свойство-индексатор, представляет элемент коллекции по его индексу. 
		/// </summary>                                                          
		public XMenuItemBase this[int i]
		{
			get
			{
				return (XMenuItemBase)m_items[i];
			}
			set
			{
				m_items[i] = value;
			}
		}

		/// <summary>
		/// Метод осуществляет добавление инициализированного пункта меню в конец
		/// списка элементов.
		/// </summary>
		/// <param name="item">Пункт меню, который необходимо добавить.</param>  
		public void Add(XMenuItemBase item)
		{
			m_items.Add(item);
		}

		/// <summary>
		/// Метод осуществляет вставку инициализированного пункта меню перед
		/// указанным элементом.
		/// </summary>
		/// <param name="item_new">Добавляемый пункт меню.</param>
		/// <param name="item_before">Пункт меню, перед которым происходит вставка.</param>
		/// <exception cref="ArgumentException">Если элемент, переданный в
		///                                     параметре <b><i>item_before</i></b>,
		///                                     не найден в коллекции элементов.</exception>
		public void InsertBefore(XMenuItemBase item_new, XMenuItemBase item_before)
		{
			int nIndex = GetItemIndex(item_before);
			if (nIndex > -1)
				m_items.Insert(nIndex, item_new);
			else
				throw new ArgumentException("Элемент item_before не найден в коллекции");
		}

		/// <summary>
		/// Метод осуществляет вставку инициализированного пункта меню после
		/// указанного элемента.
		/// </summary>
		/// <param name="item_new">Добавляемый пункт меню.</param>
		/// <param name="item_after">Пункт меню, после которого происходит
		///                          вставка.</param>
		/// <exception cref="ArgumentException">Если элемент, переданный в
		///                                     параметре <b><i>item_after</i></b>,
		///                                     не найден в коллекции элементов.</exception>
		public void InsertAfter(XMenuItemBase item_new, XMenuItemBase item_after)
		{
			int nIndex = GetItemIndex(item_after);
			if (nIndex > -1)
				m_items.Insert(nIndex+1, item_new);
			else
				throw new ArgumentException("Элемент item_after не найден в коллекции");
		}

		/// <summary>
		/// Метод вставляет инициализированный пункт меню под заданным индексом.
		/// </summary>
		/// <param name="nIndex">Индекс добавляемого пункта меню.</param>
		/// <param name="item">Добавляемый пункт меню.</param>                  
		public void Insert(int nIndex, XMenuItemBase item)
		{
			m_items.Insert(nIndex, item);
		}

		/// <summary>
		/// Метод осуществляет получение индекса в списке элементов меню.
		/// </summary>
		/// <param name="item">Пунк меню из коллекции.</param>
		/// <returns>
		/// Индекс в массиве.
		/// </returns>                                                   
		public int GetItemIndex(XMenuItemBase item)
		{
			for(int i=0;i<m_items.Count;++i)
				if ( ((XMenuItemBase)m_items[i]).UniqueID == item.UniqueID )
					return i;
			return -1;
		}

		/// <summary>
		/// Метод интерфейса IEnumerable. Возвращает итератор коллекции.
		/// </summary>
		/// <returns>
		/// Возвращает ArrayList::GetEnumerator. 
		/// </returns>                                                  
		public IEnumerator GetEnumerator()
		{
			return m_items.GetEnumerator();
		}

		/// <summary>
		/// Количество элементов меню.
		/// </summary>                
		public int Count
		{
			get { return m_items.Count; }
		}
	}


	/// <summary>
	/// Класс описывает исполняемый пункт меню.
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuParam"/>
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuItemBase"/>
	/// </summary>
	/// <remarks>
	/// Исполняемый пункт меню соответствует некоторому дейтсвию, запускаемому
	/// пользователем из интерфейса приложения. Само действие идентифицируется
	/// некоторой строкой – action. Меню может содержать несколько элементов с
	/// одинаковым action, но отличающиеся параметрами. Например, два действия
	/// &quot;DoCreate&quot;, запускающие создание объекта, с разными
	/// значениями параметра <b>ObjectType</b> (тип объекта). Наименование
	/// (name) <b>может</b> задаваться для пункта меню для того, чтобы
	/// различать пункты с одинаковым дейтсвием (action). Т.о. наименование
	/// (если оно задано) должно быть уникальным. 
	/// </remarks>                                                            
	public class XMenuActionItem: XMenuItemBase
	{
		#region Внутренни поля

		private string m_sTitle;
		private string m_sAction;
		private string m_sName;
		private string m_sHint;
		private string m_sHotkey;
		private bool m_bHidden;
		private bool m_bDisabled;
		private bool m_bSeparatorBefore;
		private bool m_bSeparatorAfter;
		private bool m_bMayBeDefault;
		private bool m_bDefault;
		private XMenuParamCollection m_parameter = new XMenuParamCollection();

		#endregion

		#region Публичные свойства

		/// <summary>
		/// Заголовок (отображаемый) пункта (атрибут <b>t</b>). 
		/// </summary>                                          
		public string Title
		{
			get { return m_sTitle; }
			set { m_sTitle = value; }
		}

		/// <summary>
		/// Наименование действия (атрибут <b>action</b>).
		/// </summary>                                    
		public string Action
		{
			get { return m_sAction; }
			set { m_sAction = value; }
		}

		/// <summary>
		/// Логическое наименование (атрибут <b>n</b>). Идентифицирует пункт меню
		/// на всех уровнях (клиент/сервер).
		/// </summary>                                                           
		public string Name
		{
			get { return m_sName; }
			set { m_sName = value; }
		}

		/// <summary>
		/// Всплывающая подсказка (атрибут <b>hint</b>).
		/// </summary>                                  
		public string Hint
		{
			get { return m_sHint; }
			set { m_sHint = value; }
		}

		/// <summary>
		/// Комбинация горячих клавиш для вызова пукнта меню (атрибут <b>hotkey</b>).
		/// </summary>                                                               
		public string Hotkey
		{
			get { return m_sHotkey; }
			set { m_sHotkey = value; }
		}

		/// <summary>
		/// Признак сокрытия пункта меню из интерфейса (атрибут <b>hidden=&quot;1&quot;</b>).
		/// </summary>                                                                       
		public bool Hidden
		{
			get { return m_bHidden; }
			set { m_bHidden = value; }
		}

		/// <summary>
		/// Признак заблокированности пункта меню (атрибут <b>disabled=&quot;1&quot;</b>).
		/// </summary>                                                                    
		public bool Disabled
		{
			get { return m_bDisabled; }
			set { m_bDisabled = value; }
		}

		/// <summary>
		/// Признак добавления разделителя перед пунктом меню. 
		/// </summary>                                         
		public bool SeparatorBefore
		{
			get { return m_bSeparatorBefore; }
			set { m_bSeparatorBefore = value; }
		}

		/// <summary>
		/// Признак добавления разделителя после пункта меню.
		/// </summary>                                       
		public bool SeparatorAfter
		{
			get { return m_bSeparatorAfter; }
			set { m_bSeparatorAfter = value; }
		}

		/// <summary>
		/// Признак того, что пункт меню может быть действием по умолчанию, если он
		/// является единственным среди доступных.
		/// </summary>                                                             
		public bool MayBeDefault
		{
			get { return m_bMayBeDefault; }
			set { m_bMayBeDefault = value; }
		}

		/// <summary>
		/// Признак того, что пункт меню является действием по умолчанию над
		/// объектом. В меню иерархии пункт меню с данным признаком запускается
		/// двойным кликом по листовому узлу дерева. 
		/// </summary>                                                         
		public bool Default
		{
			get { return m_bDefault; }
			set { m_bDefault = value; }
		}

		/// <summary>
		/// Коллекция параметров, описываемых классом <see cref="Croc.XmlFramework.Commands.XMenuParam" text="XMenuParam" />,
		/// пункта меню.
		/// </summary>                                                                                                       
		public XMenuParamCollection Parameters
		{
			get { return m_parameter; }
		}

		#endregion

		/// <summary>
		/// Параметризированный конструктор.
		/// </summary>
		/// <param name="sTitle">Заголовок пункта (отображаемый).</param>
		/// <param name="sAction">Наименование действия.</param>         
		public XMenuActionItem(string sTitle, string sAction) : base()
		{
			if (sTitle == null)
				throw new ArgumentNullException("sTitle");
			m_sTitle = sTitle;
			m_sAction = sAction;
		}

		/// <summary>
		/// Метод производит «сериализацию» исполняемого пункта меню в формате,
		/// описываемом схемой x-net-interface-schema.xsd.
		/// </summary>
		/// <param name="doc">Экземпляр XmlDocument, в контексте которого
		///                   будет создаваться XML\-представление
		///                   исполняемого пункта меню.</param>
		/// <param name="nsManager">Экземпляр XmlNamespaceManager, используемый
		///                         для получения URI\-пространства имен для
		///                         префикса &quot;i&quot;. </param>
		/// <returns>
		/// XML-узел <b>i:menu-item</b>. 
		/// </returns>                                                         
		public override XmlElement ToXml(XmlDocument doc, XmlNamespaceManager nsManager)
		{
			XmlElement xmlItem = doc.CreateElement("i:menu-item", nsManager.LookupNamespace("i"));
			if (Title != null)
				xmlItem.SetAttribute("t", Title);
			if (Action != null)
				xmlItem.SetAttribute("action", Action);
			if (Name != null)
				xmlItem.SetAttribute("n", Name);
			if (Hint != null)
				xmlItem.SetAttribute("hint", Hint);
			if (Hotkey != null)
				xmlItem.SetAttribute("hotkey", Hotkey);
			if (Hidden)
				xmlItem.SetAttribute("hidden", "1");
			if (Disabled)
				xmlItem.SetAttribute("disabled", "1");
			if (SeparatorBefore)
				xmlItem.SetAttribute("separator-before", "1");
			if (SeparatorAfter)
				xmlItem.SetAttribute("separator-after", "1");
			if (MayBeDefault)
				xmlItem.SetAttribute("may-be-default", "1");
			if (Default)
				xmlItem.SetAttribute("default", "1");
			if (Parameters.Count > 0)
			{
				XmlElement xmlParams = (XmlElement)xmlItem.AppendChild( doc.CreateElement("i:params", nsManager.LookupNamespace("i")) );
				foreach(XMenuParam param in Parameters)
				{
					xmlParams.AppendChild(param.ToXml(doc, nsManager));
				}
			}
			return xmlItem;
		}

		/// <summary>
		/// Метод возвращает копию элемента.
		/// </summary>
		public override XMenuItemBase Clone()
		{
			XMenuActionItem item = new XMenuActionItem(Title, Action);
			item.Default = Default;
			item.Disabled = Disabled;
			item.Hidden = Hidden;
			item.Hint = Hint;
			item.Hotkey = Hotkey;
			item.MayBeDefault = MayBeDefault;
			item.Name = Name;
			item.SeparatorAfter = SeparatorAfter;
			item.SeparatorBefore = SeparatorBefore;
			foreach(XMenuParam param in Parameters)
				item.Parameters.Add(param.Name, param.Value);
			return item;
		}

	}

	/// <summary>
	/// Класс описывает информационный пункт меню. 
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuItemBase"/>
	/// </summary>                                 
	public class XMenuInfoItem: XMenuItemBase
	{
		/// <summary>
		/// Заголовок
		/// </summary>
		private string m_sCaption;
		/// <summary>
		/// Значение
		/// </summary>
		private string m_sValue;

		/// <summary>
		/// Заголовок пункта меню.
		/// </summary>            
		public string Caption
		{
			get { return m_sCaption; }
			set { m_sCaption = value; }
		}

		/// <summary>
		/// Значение пункта меню.
		/// </summary>           
		public string Value
		{
			get { return m_sValue; }
			set { m_sValue = value; }
		}


		/// <summary>
		/// Параметризированный конструктор.
		/// </summary>
		/// <param name="sCaption">Заголовок пункта меню.</param>
		/// <param name="sValue">Значение пункта меню.</param>   
		public XMenuInfoItem(string sCaption, string sValue): base()
		{
			m_sCaption = sCaption;
			m_sValue = sValue;
		}

		/// <summary>
		/// Метод производит «сериализацию» информационного пункта меню в формате,
		/// описываемом схемой x-net-interface-schema.xsd.
		/// </summary>
		/// <param name="doc">Экземпляр XmlDocument, в контексте которого
		///                   будет создаваться XML\-представление
		///                   информационного пункта меню.</param>
		/// <param name="nsManager">Экземпляр XmlNamespaceManager, используемый
		///                         для получения URI\-пространства имен для
		///                         префикса &quot;i&quot;. </param>
		/// <returns>
		/// XML-узел <b>i:menu-item-info</b>. 
		/// </returns>                                                            
		public override XmlElement ToXml(XmlDocument doc, XmlNamespaceManager nsManager)
		{
			string uri = nsManager.LookupNamespace("i");
			XmlElement xmlItem = doc.CreateElement("i:menu-item-info", uri);
			xmlItem.AppendChild(doc.CreateElement("i:caption", uri)).InnerText = m_sCaption;
			xmlItem.AppendChild(doc.CreateElement("i:value", uri)).AppendChild( doc.CreateCDataSection(m_sValue) );
			return xmlItem;
		}

		/// <summary>
		/// Метод возвращает копию элемента. 
		/// </summary>                       
		public override XMenuItemBase Clone()
		{
			return new XMenuInfoItem(Caption, Value);
		}

	}

	/// <summary>
	/// Класс описывает пункт меню – разделитель.
	/// </summary>
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuItemBase"/>
	public class XMenuSeparatorItem: XMenuItemBase
	{
		/// <summary>
		/// Признак: разделитель содержит горизонтальную линию
		/// </summary>
		private bool m_bHorizontalLine = true;

		/// <summary>
		/// Признак того, что разделитель является горизонтальной линией. Возможные
		/// значения:
		///   * True - разделитель отображается в виде горизонтальной линии;
		///   * False - разделитель отображается как отступ.
		/// </summary>                                                             
		public bool HorizontalLine
		{
			get { return m_bHorizontalLine; }
			set { m_bHorizontalLine = value; }
		}

		/// <summary>
		/// Метод производит «сериализацию» разделителя в формате, описываемом
		/// схемой x-net-interface-schema.xsd.
		/// </summary>
		/// <param name="doc">Экземпляр XmlDocument, в контексте которого
		///                   будет создаваться XML\-представление
		///                   разделителя.</param>
		/// <param name="nsManager">Экземпляр XmlNamespaceManager, используемый
		///                         для получения URI\-пространства имен для
		///                         префикса &quot;i&quot;. </param>
		/// <returns>
		/// XML-узел <b>i:menu-item-separ</b>. 
		/// </returns>                                                         
		public override XmlElement ToXml(XmlDocument doc, XmlNamespaceManager nsManager)
		{
			string uri = nsManager.LookupNamespace("i");
			XmlElement xmlItem = doc.CreateElement("i:menu-item-separ", uri);
			if (m_bHorizontalLine)
				xmlItem.SetAttribute("horizontal-line", "1");
			return xmlItem;
		}

		/// <summary>
		/// Метод возвращает копию элемента.
		/// </summary>                      
		public override XMenuItemBase Clone()
		{
			XMenuSeparatorItem item = new XMenuSeparatorItem();
			item.HorizontalLine = HorizontalLine;
			return item;
		}

	}

	/// <summary>
	/// Класс описывает секцию или, по-другому, подменю. Секция меню имеет
	/// заголовок и коллекцию пунктов меню по аналогии с «главным» меню (см. <see cref="Croc.XmlFramework.Commands.XMenu" text="XMenu" />).
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuSectionBase"/>   
	/// <seealso cref="Croc.XmlFramework.Commands.XMenu"/>
	/// </summary>                                                                   
	public class XMenuSection: XMenuSectionBase
	{
		/// <summary>
		/// Наименование
		/// </summary>
		private string m_sName;

		/// <summary>
		/// Параметризированный конструктор.
		/// </summary>
		/// <param name="sName">Логическое наименование секции.</param>
		/// <param name="sTitle">Заголовок (отображаемый) секции.</param>
		public XMenuSection(string sName, string sTitle): base(sTitle)
		{
			m_sName = sName;
			if (sTitle == null)
				throw new ArgumentNullException("sTitle");
			if (sTitle.Length == 0)
				throw new ArgumentException("Не задан заголовок секции меню");
		}

		/// <summary>
		/// Заголовок (отображаемый) секции.
		/// </summary>                      
		[Obsolete("Следует использовать своство Caption",true)]
		public string Title
		{
			get { return Caption; }
			set { Caption = value; }
		}

		/// <summary>
		/// Логическое наименование секции. Аналогично наименованию исполняемого
		/// пункта. 
		/// </summary>                                                          
		public string Name
		{
			get { return m_sName; }
			set { m_sName = value; }
		}

		/// <summary>
		/// Метод производит «сериализацию» секции в формате, описываемом схемой
		/// x-net-interface-schema.xsd.
		/// </summary>
		/// <param name="doc">Экземпляр XmlDocument, в контексте которого
		///                   будет создаваться XML\-представление секции.</param>
		/// <param name="nsManager">Экземпляр XmlNamespaceManager, используемый
		///                         для получения URI\-пространства имен для
		///                         префикса &quot;i&quot;. </param>
		/// <returns>
		/// XML-узел <b>i:menu-section</b>. 
		/// </returns>                                                            
		public override XmlElement ToXml(XmlDocument doc, XmlNamespaceManager nsManager)
		{
			XmlElement xmlItem = doc.CreateElement("i:menu-section", nsManager.LookupNamespace("i"));
			xmlItem.SetAttribute("t", Caption);
			if (Name != null && Name.Length > 0)
				xmlItem.SetAttribute("n", Name);
			foreach(XMenuItemBase item in Items)
			{
				xmlItem.AppendChild(item.ToXml(doc, nsManager));
			}
			return xmlItem;
		}

		/// <summary>
		/// Метод возвращает копию элемента. 
		/// </summary>                       
		public override XMenuItemBase Clone()
		{
			XMenuSection menu_sec = new XMenuSection(Name, Caption);
			foreach(XMenuItemBase item in Items)
				menu_sec.Items.Add(item.Clone());
			return menu_sec;
		}

	}

	/// <summary>
	/// Коллекция параметров исполняемого пункта меню.
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuParam"/>
	/// </summary>                                    
	public class XMenuParamCollection: IEnumerable, ICollection
	{
		private HybridDictionary m_parameters = new HybridDictionary();

		/// <summary>
		/// Метод осуществляет добавление в коллекцию параметра, заданного
		/// наименованием и значением.
		/// </summary>
		/// <param name="sName">Наименование параметра.</param>
		/// <param name="sValue">Значение параметра.</param>
		/// <returns>
		/// Сконструированный параметр, добавленный в коллекцию.
		/// </returns>                                                    
		public XMenuParam Add(string sName, string sValue)
		{
			XMenuParam param = new XMenuParam(sName, sValue);
			m_parameters.Add(sName, param);
			return param;
		}

		/// <summary>
		/// Метод осуществляет удаление параметра по наименованию.
		/// </summary>
		/// <param name="sName">Наименование параметра.</param>   
		public void Remove(string sName)
		{
			m_parameters.Remove(sName);
		}

		/// <summary>
		/// Метод осуществляет удаление всех параметров.
		/// </summary>                                  
		public void RemoveAll()
		{
			m_parameters.Clear();
		}

		/// <summary>
		/// Свойство-индексатор, представляет параметр из коллекции по его
		/// наименованию. 
		/// </summary>                                                    
		public XMenuParam this[string sName]
		{
			get
			{
				return (XMenuParam)m_parameters[sName];
			}
			set
			{
				m_parameters[sName] = value;
			}
		}


		/// <summary>
		/// Метод возвращает признак того, содержится ли параметр с заданным
		/// наименованием в коллекции.
		/// </summary>
		/// <param name="sName">Наименование параметра.</param>
		/// <returns>
		/// Признак того, содержится ли параметр с заданным наименованием в
		/// коллекции.
		/// </returns>                                                      
		public bool Contains(string sName)
		{
			return m_parameters.Contains(sName);
		}

		/// <summary>
		/// Коллекция значений параметров (элемент - это строка, экземпляр класса
		/// String). 
		/// </summary>                                                           
		public ICollection ParamValues
		{
			get
			{
				return m_parameters.Values;
			}
		}

		/// <summary>
		/// Коллекция наименований параметров (элемент - это строка, экземпляр
		/// класса String). 
		/// </summary>                                                        
		public ICollection ParamNames
		{
			get
			{
				return m_parameters.Keys;
			}
		}

		
		#region ICollection Members

		/// <summary>
		/// Логический признак, показывающий, является ли доступ к элементам
		/// коллекции синхронизированным (потоково-безопасным). 
		/// </summary>                                                      
		public bool IsSynchronized
		{
			get
			{
				return m_parameters.IsSynchronized;
			}
		}

		/// <summary>
		/// Количество элементов в коллекции. 
		/// </summary>                        
		public int Count
		{
			get
			{
				return m_parameters.Count;
			}
		}

		/// <summary>
		/// Метод копирует элементы коллекции в массив, начиная с заданного индекса
		/// массива.
		/// </summary>
		/// <param name="array">Одномерный массив, куда будут скопированы элементы
		///                     коллекции. Массив должен индексироваться с нуля.</param>
		/// <param name="index">Индекс в массиве, начиная с которого будут
		///                     добавлены элементы коллекции.</param>                   
		public void CopyTo(Array array, int index)
		{
			m_parameters.CopyTo(array, index);
		}

		/// <summary>
		/// Объект, используемый для синхронизированного доступа к элементам
		/// коллекции. 
		/// </summary>                                                      
		public object SyncRoot
		{
			get
			{
				return m_parameters.SyncRoot;
			}
		}

		#endregion

		#region IEnumerable Members

		/// <summary>
		/// Метод интерфейса IEnumerable. Возвращает итератор коллекции параметров.
		/// </summary>
		/// <returns>
		/// IEnumerator.Current возвращает экземпляр <see cref="Croc.XmlFramework.Commands.XMenuParam" text="XMenuParam" />.
		/// 
		/// </returns>                                                                                                      
		public IEnumerator GetEnumerator()
		{
			return m_parameters.Values.GetEnumerator();
		}

		#endregion
	}

	/// <summary>
	/// Класс описывает параметр исполняемого пункта. 
	/// </summary>                                    
	public class XMenuParam
	{
		/// <summary>
		/// наименование
		/// </summary>
		private string m_sName;
		/// <summary>
		/// Значение
		/// </summary>
		private string m_sValue;

		/// <summary>
		/// Параметризированный конструктор.
		/// </summary>
		/// <param name="sName">Наименование параметра.</param>
		/// <param name="sValue">Значение параметра.</param>   
		public XMenuParam(string sName, string sValue)
		{
			m_sName = sName;
			m_sValue = sValue;
		}

		/// <summary>
		/// Наименование параметра.
		/// </summary>             
		public string Name
		{
			get { return m_sName; }
			set { m_sName = value; }
		}

		/// <summary>
		/// Значение параметра.
		/// </summary>         
		public string Value
		{
			get { return m_sValue; }
			set { m_sValue = value; }
		}

		/// <summary>
		/// Метод производит «сериализацию» параметра исполняемого пункта меню в
		/// формате, описываемом схемой x-net-interface-schema.xsd.
		/// </summary>
		/// <param name="doc">Экземпляр XmlDocument, в контексте которого
		///                   будет создаваться XML\-представление параметра
		///                   исполняемого пункта меню.</param>
		/// <param name="nsManager">Экземпляр XmlNamespaceManager, используемый
		///                         для получения URI\-пространства имен для
		///                         префикса &quot;i&quot;. </param>
		/// <returns>
		/// XML-узел<b> i:param</b>. 
		/// </returns>                                                          
		public virtual XmlElement ToXml(XmlDocument doc, XmlNamespaceManager nsManager)
		{
			XmlElement xmlParam = doc.CreateElement("i:param", nsManager.LookupNamespace("i"));
			xmlParam.SetAttribute("n", m_sName);
			xmlParam.InnerText = m_sValue;
			return xmlParam;
		}
	}
}
