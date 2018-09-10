using System;
using System.Collections;
using System.Collections.Specialized;
using System.Xml;

namespace Croc.IncidentTracker.Hierarchy
{
	/// <summary>
	/// ������� ����� ��� �������, ����������� ������ ����.
	/// </summary>                                         
	public abstract class XMenuItemBase
	{
		/// <summary>
		/// ���������� ������������� �������� ����
		/// </summary>
		private Guid m_uniqueID;

		/// <summary>
		/// ����������� �� ���������. 
		/// </summary>                
		public XMenuItemBase()
		{
			m_uniqueID = Guid.NewGuid();
		}

		/// <summary>
		/// ���������� ������������� �������� ����, ���������� ��� ��������. 
		/// </summary>                                                       
		public Guid UniqueID
		{
			get { return m_uniqueID; }
		}

		/// <summary>
		/// ����� ��������� XML-������������� ������ ����. ������ ���������������
		/// ���� ������������.
		/// </summary>
		/// <param name="doc">��������� XmlDocument, � ��������� ��������
		///                   ����� ����������� XML\-������������� ������
		///                   ����.</param>
		/// <param name="nsManager">��������� XmlNamespaceManager, ������������
		///                         ��� ��������� URI\-������������ ���� ���
		///                         �������� &quot;i&quot;. </param>
		/// <returns>
		/// XML-���� ������ ���� (������� �� ����������). 
		/// </returns>                                                           
		public abstract XmlElement ToXml(XmlDocument doc, XmlNamespaceManager nsManager);
		/// <summary>
		/// ����� ���������� ������ ����� �������� (������ ����� - ��� ����� ������
		/// ������ ��������, � ����� ���� ��������� � ���� ���������). 
		/// </summary>                                                             
		public abstract XMenuItemBase Clone();
	}

	/// <summary>
	/// ������� ����� ��� �������� �������� ����, ����������� ����������� ����
	/// (���� ���� � ������).
	/// </summary>
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuItemBase"/>            
	public abstract class XMenuSectionBase: XMenuItemBase
	{
		/// <summary>
		/// ��������� ����
		/// </summary>
		protected string m_sCaption;
		/// <summary>
		/// �������� ����
		/// </summary>
		protected XMenuItemCollection m_items = new XMenuItemCollection();

		/// <summary>
		/// ������������������� �����������.
		/// </summary>
		/// <param name="sCaption">��������� ����.</param>
		public XMenuSectionBase(string sCaption)
		{
			Caption = sCaption;
		}

		/// <summary>
		/// ��������� ����. 
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
		/// �������� ����. 
		/// </summary>     
		public XMenuItemCollection Items
		{
			get { return m_items; }
		}
	}

	/// <summary>
	/// ��������� �����, ����������� ����. 
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuItemBase"/>
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuSectionBase"/>
	/// </summary>                          
	public class XMenu : XMenuSectionBase
	{
		/// <summary>
		/// ������������ �� ��������� ������������ ���� ��� �������� "i"
		/// </summary>
		private const string NAMESPACE_URI = "http://www.croc.ru/Schemas/XmlFramework/Interface/1.0";
		/// <summary>
		/// �������, ��� ������ ���� "����������� �������", � �������� ���� � ������� ��� ���� �� �����
		/// </summary>
		private bool m_bTrustworthy;
		/// <summary>
		/// ��� �������� � XSLT ��������, ������������ ��� ���������� ���� � HTML
		/// </summary>
		private string m_sStylesheet;

		/// <summary>
		/// ������������������� �����������.
		/// </summary>
		/// <param name="sCaption">��������� ����. �������� NULL � ������ ������
		///                        ���������.</param>                           
		public XMenu(string sCaption) : base(sCaption)
		{
			m_bTrustworthy = false;
		}
	
		/// <summary>
		/// ������������������� �����������.
		/// </summary>
		/// <param name="sCaption">��������� ����. �������� NULL � ������
		///                        ������ ���������.</param>
		/// <param name="bTrustworthy">������� ����, ��� ����������� ����
		///                            ������������ ��������, �.�. ���������
		///                            �������� ���� � ������� ��� �������������.</param>
		public XMenu(string sCaption, bool bTrustworthy): base(sCaption)
		{
			m_bTrustworthy = bTrustworthy;
		}

		/// <summary>
		/// ������� ����� ����������� �������� - �������������� �������� ���� �
		/// ������� �� ���������. 
		/// </summary>                                                         
		public bool Trustworthy
		{
			get { return m_bTrustworthy; }
			set { m_bTrustworthy = value; }
		}

		/// <summary>
		/// ������������ �������� � XSLT-��������, ������������ ��� ���������� ����
		/// � HTML. 
		/// </summary>                                                             
		public string Stylesheet
		{
			get { return m_sStylesheet; }
			set { m_sStylesheet = value; }
		}

		/// <summary>
		/// ����� ���������� �������������� ���� �� ����� ���������� ��������� �
		/// �������, ����������� ������ x-net-interface-schema.xsd.
		/// </summary>
		/// <param name="doc">��������� XmlDocument, � ��������� ��������
		///                   ����� ����������� XML\-������������� ����.</param>
		/// <param name="nsManager">��������� XmlNamespaceManager, ������������
		///                         ��� ��������� URI\-������������ ���� ���
		///                         �������� &quot;i&quot;, ������������� ���
		///                         ����������� ����� XML\-������������� ����.
		///                         ���� �������� �� �����, �� ������������
		///                         �http\://www.croc.ru/Schemas/XmlFramework/Interface/1.0�.</param>
		/// <returns>
		/// XML-���� <b>i:menu</b>. 
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
		/// ����� ���������� ����� ��������.
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
		/// ����� ���������� �������������� ���� �� ����� ���������� ��������� �
		/// �������, ����������� ������ x-net-interface-schema.xsd.
		/// </summary>
		/// <returns>
		/// XML-���� <b>i:menu</b>.
		/// </returns>
		/// <remarks>
		/// ����� �������� ����������� ����� <see cref="Croc.XmlFramework.Commands.XMenu.ToXml@XmlDocument@XmlNamespaceManager" text="ToXml" />
		/// ��� ������� ���������� ��������� ������ ���� (������������ �� <see cref="Croc.XmlFramework.Commands.XMenuItemBase" text="XMenuItemBase" />)
		/// �� ����� ��������� ��������� (<see cref="Croc.XmlFramework.Commands.XMenuSectionBase.Items" text="Items" />,
		/// �������� �������� ������). 
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
	/// ����� ��������� ��������� ��������� ������� ����. ���������� �����
	/// ������ �������� ������ <see cref="Croc.XmlFramework.Commands.XMenu" text="XMenu" />
	/// � <see cref="Croc.XmlFramework.Commands.XMenuSection" text="XMenuSection" />.
	/// <seealso cref="Croc.XmlFramework.Commands.XMenu"/>
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuSection"/>
	/// </summary>                                                                         
	public class XMenuItemCollection: IEnumerable
	{
		/// <summary>
		/// ��������� ������� ����
		/// </summary>
		ArrayList m_items = new ArrayList();

		/// <summary>
		/// ����� ������������ ���������� ������������ ������ ���� � ����� ������
		/// ���������.
		/// </summary>
		/// <param name="sTitle">��������� ������ ����.</param>
		/// <param name="sAction">������������ ��������.</param>
		/// <returns>
		/// ��������� �����.
		/// </returns>                                                           
		public XMenuActionItem AddActionItem(string sTitle, string sAction)
		{
			XMenuActionItem item = new XMenuActionItem(sTitle, sAction);
			Add(item);
			return item;
		}

		/// <summary>
		/// ����� ������������ ���������� ��������������� ������ ���� � �����
		/// ������ ���������.
		/// </summary>
		/// <param name="sCaption">��������� ������ ����.</param>
		/// <param name="sValue">�������� ������ ����.</param>
		/// <returns>
		/// ��������� �����.
		/// </returns>                                                       
		public XMenuInfoItem AddInfoItem(string sCaption, string sValue)
		{
			XMenuInfoItem item = new XMenuInfoItem(sCaption, sValue);
			Add(item);
			return item;
		}

		/// <summary>
		/// ����� ������������ ���������� ������ (�������) � ����� ������
		/// ���������.
		/// </summary>
		/// <param name="sTitle">��������� ������ (�������).</param>
		/// <returns>
		/// ��������� ������.
		/// </returns>                                                   
		public XMenuSection AddSection(string sTitle)
		{
			XMenuSection item = new XMenuSection(null, sTitle);
			Add(item);
			return item;
		}

		/// <summary>
		/// ����� ������������ ���������� ����������� � ����� ������ ���������.
		/// </summary>
		/// <returns>
		/// ��������� �����������. 
		/// </returns>                                                         
		public XMenuSeparatorItem AddSeparatorItem()
		{
			XMenuSeparatorItem item = new XMenuSeparatorItem();
			Add(item);
			return item;
		}

		/// <summary>
		/// ��������-����������, ������������ ������� ��������� �� ��� �������. 
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
		/// ����� ������������ ���������� ������������������� ������ ���� � �����
		/// ������ ���������.
		/// </summary>
		/// <param name="item">����� ����, ������� ���������� ��������.</param>  
		public void Add(XMenuItemBase item)
		{
			m_items.Add(item);
		}

		/// <summary>
		/// ����� ������������ ������� ������������������� ������ ���� �����
		/// ��������� ���������.
		/// </summary>
		/// <param name="item_new">����������� ����� ����.</param>
		/// <param name="item_before">����� ����, ����� ������� ���������� �������.</param>
		/// <exception cref="ArgumentException">���� �������, ���������� �
		///                                     ��������� <b><i>item_before</i></b>,
		///                                     �� ������ � ��������� ���������.</exception>
		public void InsertBefore(XMenuItemBase item_new, XMenuItemBase item_before)
		{
			int nIndex = GetItemIndex(item_before);
			if (nIndex > -1)
				m_items.Insert(nIndex, item_new);
			else
				throw new ArgumentException("������� item_before �� ������ � ���������");
		}

		/// <summary>
		/// ����� ������������ ������� ������������������� ������ ���� �����
		/// ���������� ��������.
		/// </summary>
		/// <param name="item_new">����������� ����� ����.</param>
		/// <param name="item_after">����� ����, ����� �������� ����������
		///                          �������.</param>
		/// <exception cref="ArgumentException">���� �������, ���������� �
		///                                     ��������� <b><i>item_after</i></b>,
		///                                     �� ������ � ��������� ���������.</exception>
		public void InsertAfter(XMenuItemBase item_new, XMenuItemBase item_after)
		{
			int nIndex = GetItemIndex(item_after);
			if (nIndex > -1)
				m_items.Insert(nIndex+1, item_new);
			else
				throw new ArgumentException("������� item_after �� ������ � ���������");
		}

		/// <summary>
		/// ����� ��������� ������������������ ����� ���� ��� �������� ��������.
		/// </summary>
		/// <param name="nIndex">������ ������������ ������ ����.</param>
		/// <param name="item">����������� ����� ����.</param>                  
		public void Insert(int nIndex, XMenuItemBase item)
		{
			m_items.Insert(nIndex, item);
		}

		/// <summary>
		/// ����� ������������ ��������� ������� � ������ ��������� ����.
		/// </summary>
		/// <param name="item">���� ���� �� ���������.</param>
		/// <returns>
		/// ������ � �������.
		/// </returns>                                                   
		public int GetItemIndex(XMenuItemBase item)
		{
			for(int i=0;i<m_items.Count;++i)
				if ( ((XMenuItemBase)m_items[i]).UniqueID == item.UniqueID )
					return i;
			return -1;
		}

		/// <summary>
		/// ����� ���������� IEnumerable. ���������� �������� ���������.
		/// </summary>
		/// <returns>
		/// ���������� ArrayList::GetEnumerator. 
		/// </returns>                                                  
		public IEnumerator GetEnumerator()
		{
			return m_items.GetEnumerator();
		}

		/// <summary>
		/// ���������� ��������� ����.
		/// </summary>                
		public int Count
		{
			get { return m_items.Count; }
		}
	}


	/// <summary>
	/// ����� ��������� ����������� ����� ����.
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuParam"/>
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuItemBase"/>
	/// </summary>
	/// <remarks>
	/// ����������� ����� ���� ������������� ���������� ��������, ������������
	/// ������������� �� ���������� ����������. ���� �������� ����������������
	/// ��������� ������� � action. ���� ����� ��������� ��������� ��������� �
	/// ���������� action, �� ������������ �����������. ��������, ��� ��������
	/// &quot;DoCreate&quot;, ����������� �������� �������, � �������
	/// ���������� ��������� <b>ObjectType</b> (��� �������). ������������
	/// (name) <b>�����</b> ���������� ��� ������ ���� ��� ����, �����
	/// ��������� ������ � ���������� ��������� (action). �.�. ������������
	/// (���� ��� ������) ������ ���� ����������. 
	/// </remarks>                                                            
	public class XMenuActionItem: XMenuItemBase
	{
		#region ��������� ����

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

		#region ��������� ��������

		/// <summary>
		/// ��������� (������������) ������ (������� <b>t</b>). 
		/// </summary>                                          
		public string Title
		{
			get { return m_sTitle; }
			set { m_sTitle = value; }
		}

		/// <summary>
		/// ������������ �������� (������� <b>action</b>).
		/// </summary>                                    
		public string Action
		{
			get { return m_sAction; }
			set { m_sAction = value; }
		}

		/// <summary>
		/// ���������� ������������ (������� <b>n</b>). �������������� ����� ����
		/// �� ���� ������� (������/������).
		/// </summary>                                                           
		public string Name
		{
			get { return m_sName; }
			set { m_sName = value; }
		}

		/// <summary>
		/// ����������� ��������� (������� <b>hint</b>).
		/// </summary>                                  
		public string Hint
		{
			get { return m_sHint; }
			set { m_sHint = value; }
		}

		/// <summary>
		/// ���������� ������� ������ ��� ������ ������ ���� (������� <b>hotkey</b>).
		/// </summary>                                                               
		public string Hotkey
		{
			get { return m_sHotkey; }
			set { m_sHotkey = value; }
		}

		/// <summary>
		/// ������� �������� ������ ���� �� ���������� (������� <b>hidden=&quot;1&quot;</b>).
		/// </summary>                                                                       
		public bool Hidden
		{
			get { return m_bHidden; }
			set { m_bHidden = value; }
		}

		/// <summary>
		/// ������� ����������������� ������ ���� (������� <b>disabled=&quot;1&quot;</b>).
		/// </summary>                                                                    
		public bool Disabled
		{
			get { return m_bDisabled; }
			set { m_bDisabled = value; }
		}

		/// <summary>
		/// ������� ���������� ����������� ����� ������� ����. 
		/// </summary>                                         
		public bool SeparatorBefore
		{
			get { return m_bSeparatorBefore; }
			set { m_bSeparatorBefore = value; }
		}

		/// <summary>
		/// ������� ���������� ����������� ����� ������ ����.
		/// </summary>                                       
		public bool SeparatorAfter
		{
			get { return m_bSeparatorAfter; }
			set { m_bSeparatorAfter = value; }
		}

		/// <summary>
		/// ������� ����, ��� ����� ���� ����� ���� ��������� �� ���������, ���� ��
		/// �������� ������������ ����� ���������.
		/// </summary>                                                             
		public bool MayBeDefault
		{
			get { return m_bMayBeDefault; }
			set { m_bMayBeDefault = value; }
		}

		/// <summary>
		/// ������� ����, ��� ����� ���� �������� ��������� �� ��������� ���
		/// ��������. � ���� �������� ����� ���� � ������ ��������� �����������
		/// ������� ������ �� ��������� ���� ������. 
		/// </summary>                                                         
		public bool Default
		{
			get { return m_bDefault; }
			set { m_bDefault = value; }
		}

		/// <summary>
		/// ��������� ����������, ����������� ������� <see cref="Croc.XmlFramework.Commands.XMenuParam" text="XMenuParam" />,
		/// ������ ����.
		/// </summary>                                                                                                       
		public XMenuParamCollection Parameters
		{
			get { return m_parameter; }
		}

		#endregion

		/// <summary>
		/// ������������������� �����������.
		/// </summary>
		/// <param name="sTitle">��������� ������ (������������).</param>
		/// <param name="sAction">������������ ��������.</param>         
		public XMenuActionItem(string sTitle, string sAction) : base()
		{
			if (sTitle == null)
				throw new ArgumentNullException("sTitle");
			m_sTitle = sTitle;
			m_sAction = sAction;
		}

		/// <summary>
		/// ����� ���������� �������������� ������������ ������ ���� � �������,
		/// ����������� ������ x-net-interface-schema.xsd.
		/// </summary>
		/// <param name="doc">��������� XmlDocument, � ��������� ��������
		///                   ����� ����������� XML\-�������������
		///                   ������������ ������ ����.</param>
		/// <param name="nsManager">��������� XmlNamespaceManager, ������������
		///                         ��� ��������� URI\-������������ ���� ���
		///                         �������� &quot;i&quot;. </param>
		/// <returns>
		/// XML-���� <b>i:menu-item</b>. 
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
		/// ����� ���������� ����� ��������.
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
	/// ����� ��������� �������������� ����� ����. 
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuItemBase"/>
	/// </summary>                                 
	public class XMenuInfoItem: XMenuItemBase
	{
		/// <summary>
		/// ���������
		/// </summary>
		private string m_sCaption;
		/// <summary>
		/// ��������
		/// </summary>
		private string m_sValue;

		/// <summary>
		/// ��������� ������ ����.
		/// </summary>            
		public string Caption
		{
			get { return m_sCaption; }
			set { m_sCaption = value; }
		}

		/// <summary>
		/// �������� ������ ����.
		/// </summary>           
		public string Value
		{
			get { return m_sValue; }
			set { m_sValue = value; }
		}


		/// <summary>
		/// ������������������� �����������.
		/// </summary>
		/// <param name="sCaption">��������� ������ ����.</param>
		/// <param name="sValue">�������� ������ ����.</param>   
		public XMenuInfoItem(string sCaption, string sValue): base()
		{
			m_sCaption = sCaption;
			m_sValue = sValue;
		}

		/// <summary>
		/// ����� ���������� �������������� ��������������� ������ ���� � �������,
		/// ����������� ������ x-net-interface-schema.xsd.
		/// </summary>
		/// <param name="doc">��������� XmlDocument, � ��������� ��������
		///                   ����� ����������� XML\-�������������
		///                   ��������������� ������ ����.</param>
		/// <param name="nsManager">��������� XmlNamespaceManager, ������������
		///                         ��� ��������� URI\-������������ ���� ���
		///                         �������� &quot;i&quot;. </param>
		/// <returns>
		/// XML-���� <b>i:menu-item-info</b>. 
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
		/// ����� ���������� ����� ��������. 
		/// </summary>                       
		public override XMenuItemBase Clone()
		{
			return new XMenuInfoItem(Caption, Value);
		}

	}

	/// <summary>
	/// ����� ��������� ����� ���� � �����������.
	/// </summary>
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuItemBase"/>
	public class XMenuSeparatorItem: XMenuItemBase
	{
		/// <summary>
		/// �������: ����������� �������� �������������� �����
		/// </summary>
		private bool m_bHorizontalLine = true;

		/// <summary>
		/// ������� ����, ��� ����������� �������� �������������� ������. ���������
		/// ��������:
		///   * True - ����������� ������������ � ���� �������������� �����;
		///   * False - ����������� ������������ ��� ������.
		/// </summary>                                                             
		public bool HorizontalLine
		{
			get { return m_bHorizontalLine; }
			set { m_bHorizontalLine = value; }
		}

		/// <summary>
		/// ����� ���������� �������������� ����������� � �������, �����������
		/// ������ x-net-interface-schema.xsd.
		/// </summary>
		/// <param name="doc">��������� XmlDocument, � ��������� ��������
		///                   ����� ����������� XML\-�������������
		///                   �����������.</param>
		/// <param name="nsManager">��������� XmlNamespaceManager, ������������
		///                         ��� ��������� URI\-������������ ���� ���
		///                         �������� &quot;i&quot;. </param>
		/// <returns>
		/// XML-���� <b>i:menu-item-separ</b>. 
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
		/// ����� ���������� ����� ��������.
		/// </summary>                      
		public override XMenuItemBase Clone()
		{
			XMenuSeparatorItem item = new XMenuSeparatorItem();
			item.HorizontalLine = HorizontalLine;
			return item;
		}

	}

	/// <summary>
	/// ����� ��������� ������ ���, ��-�������, �������. ������ ���� �����
	/// ��������� � ��������� ������� ���� �� �������� � �������� ���� (��. <see cref="Croc.XmlFramework.Commands.XMenu" text="XMenu" />).
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuSectionBase"/>   
	/// <seealso cref="Croc.XmlFramework.Commands.XMenu"/>
	/// </summary>                                                                   
	public class XMenuSection: XMenuSectionBase
	{
		/// <summary>
		/// ������������
		/// </summary>
		private string m_sName;

		/// <summary>
		/// ������������������� �����������.
		/// </summary>
		/// <param name="sName">���������� ������������ ������.</param>
		/// <param name="sTitle">��������� (������������) ������.</param>
		public XMenuSection(string sName, string sTitle): base(sTitle)
		{
			m_sName = sName;
			if (sTitle == null)
				throw new ArgumentNullException("sTitle");
			if (sTitle.Length == 0)
				throw new ArgumentException("�� ����� ��������� ������ ����");
		}

		/// <summary>
		/// ��������� (������������) ������.
		/// </summary>                      
		[Obsolete("������� ������������ ������� Caption",true)]
		public string Title
		{
			get { return Caption; }
			set { Caption = value; }
		}

		/// <summary>
		/// ���������� ������������ ������. ���������� ������������ ������������
		/// ������. 
		/// </summary>                                                          
		public string Name
		{
			get { return m_sName; }
			set { m_sName = value; }
		}

		/// <summary>
		/// ����� ���������� �������������� ������ � �������, ����������� ������
		/// x-net-interface-schema.xsd.
		/// </summary>
		/// <param name="doc">��������� XmlDocument, � ��������� ��������
		///                   ����� ����������� XML\-������������� ������.</param>
		/// <param name="nsManager">��������� XmlNamespaceManager, ������������
		///                         ��� ��������� URI\-������������ ���� ���
		///                         �������� &quot;i&quot;. </param>
		/// <returns>
		/// XML-���� <b>i:menu-section</b>. 
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
		/// ����� ���������� ����� ��������. 
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
	/// ��������� ���������� ������������ ������ ����.
	/// <seealso cref="Croc.XmlFramework.Commands.XMenuParam"/>
	/// </summary>                                    
	public class XMenuParamCollection: IEnumerable, ICollection
	{
		private HybridDictionary m_parameters = new HybridDictionary();

		/// <summary>
		/// ����� ������������ ���������� � ��������� ���������, ���������
		/// ������������� � ���������.
		/// </summary>
		/// <param name="sName">������������ ���������.</param>
		/// <param name="sValue">�������� ���������.</param>
		/// <returns>
		/// ����������������� ��������, ����������� � ���������.
		/// </returns>                                                    
		public XMenuParam Add(string sName, string sValue)
		{
			XMenuParam param = new XMenuParam(sName, sValue);
			m_parameters.Add(sName, param);
			return param;
		}

		/// <summary>
		/// ����� ������������ �������� ��������� �� ������������.
		/// </summary>
		/// <param name="sName">������������ ���������.</param>   
		public void Remove(string sName)
		{
			m_parameters.Remove(sName);
		}

		/// <summary>
		/// ����� ������������ �������� ���� ����������.
		/// </summary>                                  
		public void RemoveAll()
		{
			m_parameters.Clear();
		}

		/// <summary>
		/// ��������-����������, ������������ �������� �� ��������� �� ���
		/// ������������. 
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
		/// ����� ���������� ������� ����, ���������� �� �������� � ��������
		/// ������������� � ���������.
		/// </summary>
		/// <param name="sName">������������ ���������.</param>
		/// <returns>
		/// ������� ����, ���������� �� �������� � �������� ������������� �
		/// ���������.
		/// </returns>                                                      
		public bool Contains(string sName)
		{
			return m_parameters.Contains(sName);
		}

		/// <summary>
		/// ��������� �������� ���������� (������� - ��� ������, ��������� ������
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
		/// ��������� ������������ ���������� (������� - ��� ������, ���������
		/// ������ String). 
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
		/// ���������� �������, ������������, �������� �� ������ � ���������
		/// ��������� ������������������ (��������-����������). 
		/// </summary>                                                      
		public bool IsSynchronized
		{
			get
			{
				return m_parameters.IsSynchronized;
			}
		}

		/// <summary>
		/// ���������� ��������� � ���������. 
		/// </summary>                        
		public int Count
		{
			get
			{
				return m_parameters.Count;
			}
		}

		/// <summary>
		/// ����� �������� �������� ��������� � ������, ������� � ��������� �������
		/// �������.
		/// </summary>
		/// <param name="array">���������� ������, ���� ����� ����������� ��������
		///                     ���������. ������ ������ ��������������� � ����.</param>
		/// <param name="index">������ � �������, ������� � �������� �����
		///                     ��������� �������� ���������.</param>                   
		public void CopyTo(Array array, int index)
		{
			m_parameters.CopyTo(array, index);
		}

		/// <summary>
		/// ������, ������������ ��� ������������������� ������� � ���������
		/// ���������. 
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
		/// ����� ���������� IEnumerable. ���������� �������� ��������� ����������.
		/// </summary>
		/// <returns>
		/// IEnumerator.Current ���������� ��������� <see cref="Croc.XmlFramework.Commands.XMenuParam" text="XMenuParam" />.
		/// 
		/// </returns>                                                                                                      
		public IEnumerator GetEnumerator()
		{
			return m_parameters.Values.GetEnumerator();
		}

		#endregion
	}

	/// <summary>
	/// ����� ��������� �������� ������������ ������. 
	/// </summary>                                    
	public class XMenuParam
	{
		/// <summary>
		/// ������������
		/// </summary>
		private string m_sName;
		/// <summary>
		/// ��������
		/// </summary>
		private string m_sValue;

		/// <summary>
		/// ������������������� �����������.
		/// </summary>
		/// <param name="sName">������������ ���������.</param>
		/// <param name="sValue">�������� ���������.</param>   
		public XMenuParam(string sName, string sValue)
		{
			m_sName = sName;
			m_sValue = sValue;
		}

		/// <summary>
		/// ������������ ���������.
		/// </summary>             
		public string Name
		{
			get { return m_sName; }
			set { m_sName = value; }
		}

		/// <summary>
		/// �������� ���������.
		/// </summary>         
		public string Value
		{
			get { return m_sValue; }
			set { m_sValue = value; }
		}

		/// <summary>
		/// ����� ���������� �������������� ��������� ������������ ������ ���� �
		/// �������, ����������� ������ x-net-interface-schema.xsd.
		/// </summary>
		/// <param name="doc">��������� XmlDocument, � ��������� ��������
		///                   ����� ����������� XML\-������������� ���������
		///                   ������������ ������ ����.</param>
		/// <param name="nsManager">��������� XmlNamespaceManager, ������������
		///                         ��� ��������� URI\-������������ ���� ���
		///                         �������� &quot;i&quot;. </param>
		/// <returns>
		/// XML-����<b> i:param</b>. 
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
