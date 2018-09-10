Option Explicit

'==============================================================================
'	OBJECT-PRESENTATION (read-only-���� + ������ � ���� ��������)
'==============================================================================
' ������� (� ������� ������������ ������ ���������� �������):
'	MenuBeforeShow  - ����� ������� ���� (MenuEventArgs)
'	ShowMenu		- ����� ���� (MenuEventArgs). ���� ����������� ����������
'	Accel (EventArgs: AccelerationEventArgsClass)
'		������� ���������� ������
' ������� DoSelectFromDb ��������� ������� �������:
'	BeforeSelect	- ����� ������� ������� (SelectEventArgsClass)
'	Select			- ����� ������� (SelectEventArgsClass). ���� ����������� ����������
'	GetRestrictions	- ��������� ����������� ��� ������ (GetRestrictionsEventArgsClass). ������������� �� ������������ ����������� ������� Select
'	ValidateSelection	- �������� ������ - ���� ReturnValue ����� False, �� ��������� ������ � xml �� ����������� 
'						� AfterSelect �� ������������� (SelectEventArgsClass)
'	BindSelectedData	- ��������� ���������� ������� � xml � ���� ����� (SelectEventArgsClass). ���� ����������� ����������
'	AfterSelect 	- ������������ ����� ������ ������� (SelectEventArgsClass)
'	SelectConflict	- ������������ ����������� ������������ ������� BindSelectedData, ���� ��� �������� ���������� ������� �������� ���������� XObjectNotFound
' ������� DoSelectFromXml:
'	BeforeSelectXml	- ����� ������� ������� (SelectEventArgsClass)
'	SelectXml		- ����� ������� (SelectEventArgsClass). ���� ����������� ����������
'	ValidateSelection	- �������� ������ - ���� ReturnValue ����� False, �� ��������� ������ � xml �� ����������� 
'						� AfterSelect �� ������������� (SelectEventArgsClass)
'	BindSelectedData	- ��������� ���������� ������� � xml � ���� ����� (SelectEventArgsClass). ���� ����������� ����������
'	AfterSelectXml 	- ������������ ����� ������ ������� (SelectEventArgsClass)
'	SelectConflict	- ������������ ����������� ������������ ������� BindSelectedData, ���� ��� �������� ���������� ������� �������� ���������� XObjectNotFound
' ������� DoCreate:
'	BeforeCreate	- ����� �������� ������� (OpenEditorEventArgsClass). ���� ReturnValue=False, ������� ������� �����������
'	Create			- �������� ������� (OpenEditorEventArgsClass). ���� ����������� ����������
'	AfterCreate		- ����� �������� ������� (OpenEditorEventArgsClass).
' ������� DoEdit:
'	BeforeEdit		- ����� �������������� ������� (OpenEditorEventArgsClass). ���� ReturnValue=False, ������� ������� �����������
'	Edit			- �������������� ������� (OpenEditorEventArgsClass). ���� ����������� ����������
'	AfterEdit		- ����� �������������� ������� (OpenEditorEventArgsClass).
' ������� DoMarkDelete:
'	BeforeMarkDelete- (EventArgsClass)
'	MarkDelete		- ������� �������� � ��������� ������� ��� ���������� (EventArgsClass). ���� ����������� ����������
'	AfterMarkDelete	- (EventArgsClass)
' ������� DoUnLink:
'	BeforeUnlink	- ����� �������� �������� (EventArgsClass). ���� ReturnValue=False, ������� ������� �����������
'	Unlink			- ������� �������� (EventArgsClass). ���� ����������� ����������
'	AfterUnlink		- ����� ������� �������� (EventArgsClass).
Class XPEObjectPresentationClass
	Private m_oPropertyEditorBase 	' As XPropertyEditorObjectBaseClass
	Private m_oCaptionHtmlElement	' As IHtmlElement	- Html-������� ������ � ����������
	Private EVENTS					' ������ ������� ��������
	Private m_oMenu					' As MenuClass		- ���� ��������
	Private m_sExpression			' As String			- VBS-���������
	Private m_bAutoCaptionToolTip	' As Boolean		- ������� ��������������� ��������� ������� ���������� ����
	
	'==========================================================================
	' �����������
	Private Sub Class_Initialize
		EVENTS = "MenuBeforeShow," & _
			"BeforeSelect,GetRestrictions,Select,ValidateSelection,BindSelectedData,AfterSelect," & _
			"BeforeSelectXml,SelectXml,AfterSelectXml," & _
			"BeforeCreate,Create,AfterCreate," & _
			"BeforeEdit,Edit,AfterEdit," & _
			"BeforeMarkDelete,MarkDelete,AfterMarkDelete," & _
			"BeforeUnlink,Unlink,AfterUnlink,SelectConflict,Accel"
	End Sub

	
	'==========================================================================
	' ���������� ��������� ObjectEditorClass - ���������,
	' � ������ �������� �������� ������ �������� ��������
	Public Property Get ObjectEditor
		Set ObjectEditor = m_oPropertyEditorBase.ObjectEditor
	End Property

		
	'==========================================================================
	' ���������� ��������� EditorPageClass - �������� ���������,
	' �� ������� ����������� ������ �������� ��������
	Public Property Get ParentPage
		Set ParentPage = m_oPropertyEditorBase.EditorPage
	End Property
	
	
	'==========================================================================
	' ���������� ���������� ��������
	'	[retval] As IXMLDOMElement - ���� ds:prop
	Public Property Get PropertyMD
		Set PropertyMD = m_oPropertyEditorBase.PropertyMD
	End Property

		
	'==========================================================================
	' ���������� ��������� EventEngineClass - �������, ���������������
	' ���������� ������ ��� ������� ��������� ��������
	Public Property Get EventEngine
		Set EventEngine = m_oPropertyEditorBase.EventEngine
	End Property


	'==========================================================================
	' ������������� ��������� ��������.
	' ��. IPropertyEditor::Init
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim oMenuMD				' ���������� ���� (i:menu)
		
		Set m_oMenu = New MenuClass
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectPresentation"
		
		Set m_oCaptionHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all(HtmlElement.GetAttribute("INPUTID"), 0) 
		' �������� ����������� ����������� ����� �������
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Select", Me, "OnSelect"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "BindSelectedData", Me, "OnBindSelectedData"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Create", Me, "OnCreate"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Edit", Me, "OnEdit"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "MarkDelete", Me, "OnMarkDelete"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "UnLink", Me, "OnUnLink"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "SelectXml", Me, "OnSelectXml"
		
		' �������������� ����: ������� ��� ����������, (��������� ������� MetadataLocator ������ i:object-presentation), ������� ����������� ����������� 
		Set oMenuMD = m_oPropertyEditorBase.PropertyEditorMD.selectSingleNode( "i:prop-menu/i:menu")
		If Not oMenuMD Is Nothing Then
			m_oMenu.AddMacrosResolver X_CreateDelegate(Me, "Internal_MenuMacrosResolver") 
			m_oMenu.AddVisibilityHandler X_CreateDelegate(Me, "Internal_MenuVisibilityHandler")
			m_oMenu.AddExecutionHandler X_CreateDelegate(Me, "Internal_MenuExecutionHandler") 
			m_oMenu.Init oMenuMD
		End If
				
		m_sExpression = HtmlElement.GetAttribute("ObjectPresentationExpression")
		' ���� ������� ��������� ������������� �� ������ - ���������� ObjectID (����)
		If Not hasValue(m_sExpression) Then 
			m_sExpression = "item.ObjectID"
		End If
		ViewInitialize
		m_bAutoCaptionToolTip = CBool(HtmlElement.GetAttribute("AutoToolTip") = "1")
	End Sub

	
	'==========================================================================
	' IPropertyEdior: ����� ���������� ��� ���������� �������� ���������, ����� ������������� ���� PE �� ��������
	Public Sub FillData()
		' Nothing to do...
	End Sub

	
	'==========================================================================
	' ��������� �������� ��������� ��������.
	' ��. IPropertyEditor::SetData
	Public Sub SetData
		SetDataEx XmlProperty
	End Sub

	
	'==========================================================================
	' ������������� ��������. ������������ ��� �����������, 
	'	�.�. �� �������� XmlProperty ����������� ����������
	' ����� ������������� ������ ������������� ������� � ������������ ��
	'	��������� ���������� �������� � ���� 
	'	[in] oXmlProperty As IXMLDOMElement - �������������� ������ �� ������� xml-��������
	Private Sub SetDataEx(oXmlProperty)
		Dim oXmlItem		' As XMLDOMELement - ������-�������� ��������
		Dim sCaption		' As String - ��������� ������������� �������
		
		Set oXmlItem = oXmlProperty.firstChild
		' ��������� ������ � ������� ������������� �������:
		If Not(Nothing Is oXmlItem) Then
			' ������ ����� ������ - ����������� VBS-���������
			sCaption = vbNullString & m_oPropertyEditorBase.ObjectEditor.ExecuteStatement( oXmlItem, Expression )
		End if
		' ����������� ������ ������������� � UI:
		SetCaption sCaption
	End Sub
	
	
	'==========================================================================
	' ���� � �������� ������
	' ��������� ��. IPropertyEditor::GetDataArgsClass
	Public Sub GetData(oGetDataArgs)
		ValueCheckOnNullForPropertyEditor Value,  Me, oGetDataArgs, Mandatory
	End Sub
	
	
	'==========================================================================
	' ���������� ������� (��)�������������� ��������
	' ��������� ��. IPropertyEditor::Mandatory
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	
	
	'==========================================================================
	' ��������� (��)��������������
	' ��������� ��. IPropertyEditor::Mandatory
	Public Property Let Mandatory(bMandatory)
		If (bMandatory) Then
			HtmlElement.removeAttribute "X_MAYBENULL"
		Else	
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
		End If
		If (bMandatory) Then
			m_oCaptionHtmlElement.className = "x-editor-control-notnull x-editor-objectpresentation-text"
		Else
			m_oCaptionHtmlElement.className = "x-editor-control x-editor-objectpresentation-text"
		End If
	End Property
	
	
	'==========================================================================
	' ��������� (��)�����������
	' ��������� ��. IPropertyEditor::Enabled
	Public Property Get Enabled
		 Enabled = Not (HtmlElement.disabled)
	End Property

	'==========================================================================
	' ��������� (��)�����������
	' ��������� ��. IPropertyEditor::Enabled
	Public Property Let Enabled(bEnabled)
		' �����������/������������ ������
		HtmlElement.disabled = Not( bEnabled )
		' �����������/������������ read-only-����
		CaptionElement.disabled = Not( bEnabled )
	End Property
	
	
	'==========================================================================
	' ��������� ������
	' ��������� ��. IPropertyEditor::SetFocus
	Public Function SetFocus
		window.focus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function
	
	
	'==========================================================================
	' ��������� ��������� HTML-�������� ��������� ��������
	' ��������� ��. IPropertyEditor::HtmlElement
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property


	'==========================================================================
	' ����������/������������� �������� ��������
	Public Property Get PropertyDescription
		PropertyDescription = m_oPropertyEditorBase.PropertyDescription
	End Property	
	Public Property Let PropertyDescription(sValue)
		m_oPropertyEditorBase.PropertyDescription = sValue
	End Property

	
	'==========================================================================
	' ������ ������ � ������� ���������
	' ��������� ��. IDisposable::Dispose
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
		Set m_oPropertyEditorBase = Nothing
	End Sub

	
	'==========================================================================
	' ���������� Xml-��������
	' ��������� ��. IPropertyEditor::XmlProperty
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property

		
	'==========================================================================
	' ���������� xml-������-�������e xml-��������. ���� ��������� ������ ������
	' ���������� Nothing
	Public Property Get Value
		Dim oXmlProperty		' As IXMLDOMElement
		
		Set oXmlProperty = XmlProperty
		If oXmlProperty.FirstChild Is Nothing Then
			Set Value = Nothing
		Else	
			' �������� ������-��������
			Set Value = m_oPropertyEditorBase.ObjectEditor.Pool.GetXmlObjectByXmlElement( oXmlProperty.FirstChild, Null )
		End If
	End Property
	
	
	'==========================================================================
	' ������������� ����������� xml-������-�������e xml-�������� � �������� 
	' ������ �����������, ��� ���������������
	' [in] oObject - ��������������� � �������� �������� Xml-������
	' ���� oObject Is Nothing �������� ���������
	Public Property Set Value(oObject)
		Dim oXmlProperty		' As IXMLDOMElement - ������� ��������
		Set oXmlProperty = XmlProperty
		' ������ ������� ��������
		If Not oXmlProperty.firstChild Is Nothing Then
			' ���� ��-�� �������� - ������� ���
			m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
		End If
		' ��������� �������� ��������
		If Not IsNothing(oObject) Then
			m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, oObject
		End If
		' ��������� ��������
		SetDataEx oXmlProperty
	End Property


	'==========================================================================
	' ���������� ������������� �������-�������� xml-��������
	' ���� �������� ������ ���������� Null
	Public Property Get ValueID
		' ������� ID ������� - �������� ��������
		If XmlProperty.FirstChild Is Nothing Then
			ValueID = Null
		Else	
			' �������� ������-��������
			ValueID = XmlProperty.FirstChild.getAttribute("oid") 
		End If
	End Property
	 
	
	'==========================================================================
	' ������������� �������� �������� � ������ ����������� �� �������������� ������� ��������.
	' ��� ������� �������� �� ���������� ��������.
	' [in] sObjectID - ������������� ���������������� � �������� �������� Xml-�������
	' ���� sObjectID Is Null �������� ���������
	Public Property Let ValueID(sObjectID)
		If Len("" & sObjectID) = 0 Then
			Set Value = Nothing
		Else
			Set Value = X_CreateObjectStub(ValueObjectTypeName, sObjectID)
		End If
	End Property

	
	'==========================================================================
	' ���������� ������������ ���� ������� �������� ��������
	' ��������� ��. IObjectPropertyEditor::ValueObjectTypeName 
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyEditorBase.ValueObjectTypeName
	End Property
	
	
	'==========================================================================
	' ���������� IHtmlInputElement ������� ���������� ����, � ������� ������������ 
	' ������ ����������� ������
	Private Property Get CaptionElement
		Set CaptionElement = m_oCaptionHtmlElement
	End Property

	
	'==========================================================================
	' ���������� ���������� ���������� ����, � ������� ������������ ������ ����������� ������
	Public Property Get CaptionText
		CaptionText = CaptionElement.Value
	End Property

	
	'==========================================================================
	' �������������/���������� ������ ��� ���������� ����, � ������� ������������ ������ ����������� ������
	Public Property Let CaptionToolTip(sValue)
		CaptionElement.Title = sValue
	End Property
	Public Property Get CaptionToolTip
		CaptionToolTip = CaptionElement.Title
	End Property


	'==========================================================================
	' �������������/���������� ������� ��������������� ��������� ������� ���������� ����
	Public Property Let AutoToolTip(bValue)
		m_bAutoCaptionToolTip = bValue
	End Property
	Public Property Get AutoToolTip
		AutoToolTip = m_bAutoCaptionToolTip
	End Property


	'==========================================================================
	' ������������� ���������� ��������� ������ ����������� ������������� �������
	Private Sub SetCaption(sText)
		CaptionElement.Value = sText
		If m_bAutoCaptionToolTip Then
			CaptionToolTip = sText
		End If
	End Sub

	
	'==========================================================================
	' ���������� �������
	' [in] sEventName - ������������ �������
	' [in] oEventArgs - ��������� ������� EventArgsClass, �������
	' �������� ����������� ����� EventEngine, ��������� ��� � ��������
	' ��������� ������ �� ���� 
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub
	
	
	'==========================================================================
	' ��������� ������������ �������� ������ ��������, 
	' � ������������ � �������� ���� ����������� ������������� �������.
	Private Sub ViewInitialize( )
		' ����������: ���� ���������� ������������ ��������� - ��������� ������ object required ��� ��������� � CaptionElement, 
		' ��� ���� �������� ������� �����������.
		On Error Resume Next
		' ������������ �������� ������ �������� ����������� �� ��������� � ��������
		' ���� ����������� ������������� �������: �������� ������ �� �����. HTML-�������
		With HtmlElement
			.style.height = CaptionElement.offsetHeight
			.style.width = .style.height
			.style.lineHeight = (.offsetHeight \ 2) & "px"
		End With
		CaptionElement.style.width = CaptionElement.offsetWidth & "px"
		Err.Clear
	End Sub
	
	
	'==========================================================================
	' �������������/���������� Vbs-��������� ��� ���������� ������������� ��������
	' ��������� ��. i:object-presentation
	Public Property Get Expression
		Expression = m_sExpression
	End Property 
	Public Property Let Expression(value)
		m_sExpression = value
		SetData
	End Property 

	
	'==========================================================================
	' �������������/���������� ��� ���������, ������������� ��� ������� �������
	' ����� ��������� �������� "list" � "tree"
	' ��������� ��. IObjectPropertyEditor::SelectorType
	Public Property Get SelectorType
		SelectorType = m_oPropertyEditorBase.SelectorType
	End Property
	Public Property Let SelectorType(value)
		m_oPropertyEditorBase.SelectorType = value
	End Property
	
	
	'==========================================================================
	' �������������/���������� ������� ���������, ������������� ��� ������� �������
	' ��������� ��. IObjectPropertyEditor::SelectorMetaname
	Public Property Get SelectorMetaname
		SelectorMetaname = m_oPropertyEditorBase.SelectorMetaname
	End Property
	Public Property Let SelectorMetaname(value)
		m_oPropertyEditorBase.SelectorMetaname = value
	End Property
	
	
	'==========================================================================
	' ���������� ����, ������������ ����������� ������������ ������� OnShowMenu
	Public Property Get Menu
		Set Menu = m_oMenu
	End Property	

	
	'==========================================================================
	' ���������� ����� ������ "...". �������� ����� ���� ��������.
	Public Sub ShowMenu
		Dim nPosX		' ���������� x ��� ������ ����
		Dim nPosY		' ���������� y ��� ������ ����
		
		With New MenuEventArgsClass
			Set .Menu = m_oMenu
			.ReturnValue = True
			FireEvent "MenuBeforeShow", .Self()
			If .ReturnValue <> True Then Exit Sub
		End With
		If Not m_oMenu.Initialized Then Exit Sub
		X_GetHtmlElementScreenPos HtmlElement, nPosX, nPosY
		nPosY = nPosY + HtmlElement.offsetHeight
		m_oMenu.ShowPopupMenuWithPosEx Me, nPosX, nPosY, True
	End Sub
	
	
	'==========================================================================
	' ���������� Html-������� OnKeyUp �� ������.
	' ��������: ��� ����������� �������������.
	Public Sub Internal_OnKeyUp()
		Dim oEventArgs		' As AccelerationEventArgsClass
		
		If window.event Is Nothing Then Exit Sub
		window.event.cancelBubble = True
		Set oEventArgs = CreateAccelerationEventArgsForHtmlEvent()
		Set oEventArgs.Source = Me
		FireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' ���� ������� ���������� �� ���������� - ��������� �� � ��������
			ObjectEditor.OnKeyUp Me, oEventArgs
		End If
	End Sub
	
	
	'==========================================================================
	' ����������� �������� �������� ����
	'	[in] oMenuEventArgs As MenuEventArgsClass
	' ��������� ��. �������� MenuClass 
	Sub Internal_MenuMacrosResolver(oSender, oMenuEventArgs)
		Dim sObjectID		' ������������� �������-��������
		sObjectID = Null
		With XmlProperty
			If Not .firstChild Is Nothing Then
				sObjectID = .firstChild.getAttribute("oid")
			End If
		End With
		oMenuEventArgs.Menu.Macros.Item("ObjectID")   = sObjectID
		oMenuEventArgs.Menu.Macros.Item("ObjectType") = m_oPropertyEditorBase.ValueObjectTypeName
	End Sub
	
	
	'==========================================================================
	' ����������� ���������� ���������/����������� ������� ����
	'	[in] oMenuEventArgs As MenuEventArgsClass
	' ��������� ��. �������� MenuClass 
	Sub Internal_MenuVisibilityHandler(oSender, oMenuEventArgs)
		Dim bDisabled		' ������� ����������������� ������
		Dim bHidden			' ������� �������� ������
		Dim oNode			' ������� menu-item
		Dim sType			' ��� ������� � ��������
		Dim sObjectID		' ������������� �������-��������
		Dim oList			' As ObjectArrayListClass - ������ �������� XObjectPermission
		Dim oXmlProperty	' xml-��������
		Dim oObjectValue	' As IXMLDOMElement - xml-������ ��������
		Dim bIsLoaded		' As Boolean - ������� ����,��� ������-�������� �������� �� ��
		Dim bProcess		' As Boolean - ������� ��������� �������� ������

		Set oXmlProperty = XmlProperty		
		sType = oMenuEventArgs.Menu.Macros.Item("ObjectType")
		sObjectID = oMenuEventArgs.Menu.Macros.Item("ObjectID")
		If Not IsNull(sObjectID) Then
			Set oObjectValue = ObjectEditor.Pool.GetXmlObject(sType, sObjectID, Null)
			If Not oObjectValue Is Nothing Then
				bIsLoaded = IsNull(oObjectValue.getAttribute("new"))
			End If
		End If	

		Set oList = New ObjectArrayListClass
		' ���������� ������ ��������� ��� ��������
		For Each oNode In oMenuEventArgs.ActiveMenuItems
			' ��������� �������� �� ������ ����, ����� oMenu.SetMenuItemsAccessRights ���� ������� ������� �� �������� ���� � ������ ���� (��� ������������ ����� disabled)
			oNode.setAttribute "type", sType
			If Not IsNull(sObjectID) Then _
				oNode.setAttribute "oid",  sObjectID
				
			bHidden = Empty
			bDisabled = Empty
			bProcess = False
			Select Case oNode.getAttribute("action")
				Case "DoSelectFromDb"
					bHidden = Len( HtmlElement.getAttribute("OFF_SELECT") )>0
					bProcess = True
				Case "DoSelectFromXml"
					bHidden = Len( HtmlElement.getAttribute("OFF_SELECT") )>0
					bProcess = True
				Case "DoCreate"
					bHidden = Len( HtmlElement.getAttribute("OFF_CREATE") )>0
					oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CREATE, sType, Empty)
					bProcess = True
				Case "DoEdit"
					bHidden = IsNull(sObjectID) Or Len( HtmlElement.getAttribute("OFF_EDIT") )>0
					If Not bHidden And bIsLoaded Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CHANGE, sType, sObjectID)
					bProcess = True
				Case "DoMarkDelete"
					bHidden = IsNull(sObjectID) Or Len( HtmlElement.getAttribute("OFF_DELETE") )>0
					If Not bHidden And bIsLoaded Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_DELETE, sType, sObjectID)
					bProcess = True
				Case "DoUnlink"
					bHidden = IsNull(sObjectID) Or Len( HtmlElement.getAttribute("OFF_UNLINK") )>0
					If Not bHidden Then
						bDisabled = Mandatory
					End If
					bProcess = True
			End Select
			If bProcess Then
				If IsEmpty(bHidden) Then bHidden = False
				If IsEmpty(bDisabled) Then bDisabled = False
			End If
			If Not IsEmpty(bHidden) Then
				If bHidden Then 
					oNode.setAttribute "hidden", "1"
				Else
					oNode.removeAttribute "hidden"
				End If
			End If
			If Not IsEmpty(bDisabled) Then
				If bDisabled Then 
					oNode.setAttribute "disabled", "1"
				Else
					oNode.removeAttribute "disabled"
				End If
			End If
		Next
		If Not oList.IsEmpty Then
			oMenuEventArgs.Menu.SetMenuItemsAccessRights oList.GetArray()
		End If
	End Sub
	
	
	'==========================================================================
	' ����������� ���������� ���������� ������ ����
	' [in] oMenuExecuteEventArgs As MenuExecuteEventArgsClass
	' ��������� ��. �������� MenuClass 
	Sub Internal_MenuExecutionHandler(oSender, oMenuExecuteEventArgs)
		oMenuExecuteEventArgs.Cancel = True
		Select Case oMenuExecuteEventArgs.Action
			' ����� ������� �� ��
			Case "DoSelectFromDb"
				m_oPropertyEditorBase.DoSelectFromDb oMenuExecuteEventArgs.Menu.Macros
			' ����� ������� �� Xml
			Case "DoSelectFromXml"
				m_oPropertyEditorBase.DoSelectFromXml oMenuExecuteEventArgs.Menu.Macros
			' ������� � ������� ����������
			Case "DoCreate"
				m_oPropertyEditorBase.DoCreate oMenuExecuteEventArgs.Menu.Macros, False
			' ��������������� � ������� ����������
			Case "DoEdit"
				m_oPropertyEditorBase.DoEdit oMenuExecuteEventArgs.Menu.Macros, False
			' �������� ������ ��� ��������� � ��������� �����
			Case "DoMarkDelete"
				m_oPropertyEditorBase.DoMarkDelete oMenuExecuteEventArgs.Menu.Macros
			' ��������� �����
			Case "DoUnlink"
				m_oPropertyEditorBase.DoUnlink oMenuExecuteEventArgs.Menu.Macros
			Case Else
				oMenuExecuteEventArgs.Cancel = False
		End Select	
	End Sub
	
	
	'==========================================================================
	' ����������� ���������� ������� "Select"
	' [in] oSender - ��������� XPEObjectPresentationClass, �������� �������
	' [in] oEventArgs - ��������� SelectEventArgsClass, ��������� �������
	' ������ ���������� ���������� ��������� ������� GetRestrictions ���
	' ��������� �������������� ����������� ����� ���� ���������� ����� ���������
	' �������� ���� "SelectorType" � ���������� "SelectorMetaname"
	Public Sub OnSelect(oSender, oEventArgs)
		Dim sType					' As String		- ��� �������-��������
		Dim sParams					' As String		- ��������� ��� data-source (Param1=Value1&Param2=Value2)
		Dim sUrlArguments			' As String		- ��������� ���������
		Dim sExcludeNodes			' As String		- ������ ����������� ����� ��� ������ �� ������
		Dim vRet					' As String		- ��������� ������
		Dim oXmlProperty			' As XMLDOMElement	- xml-��������
		Dim vTemp                   ' As Variant    - ��������������� ���������� ��� ���������� SelectionMode
		
		Set oXmlProperty = XmlProperty
		' �������� ��� �������-��������
		sType = oEventArgs.ObjectValueType
		' ������� ���������������� ����������� ��� ��������� ����� ������� GetRestrictions
		With New GetRestrictionsEventArgsClass
			.ReturnValue = oEventArgs.OperationValues.item("DataSourceParams")
			FireEvent "GetRestrictions", .Self()
			sParams = .ReturnValue
			' ��������� � �������� �� ���������� ������ ����
			sUrlArguments = oEventArgs.UrlArguments
			' � ������� ��������� � �������� �� ������������ ������� "GetRestrictions"
			If Len(.UrlParams) Then
				If Left(.UrlParams, 1) <> "&" And Len(sUrlArguments) Then sUrlArguments = sUrlArguments & "&"
				sUrlArguments = sUrlArguments & .UrlParams
			End If
			sExcludeNodes = .ExcludeNodes
		End With
		
		' �������� ������
		If oEventArgs.SelectorType="list" Then
			' ����� ������������ �� ������
			vRet = X_SelectFromList(oEventArgs.SelectorMetaname , sType, LM_SINGLE, sParams, sUrlArguments)
			oEventArgs.ObjectValueType = sType
		Else
			' ������� ������ � ������� ��������� ��������
			With New SelectFromTreeDialogClass
				.Metaname = oEventArgs.SelectorMetaname
				.LoaderParams = sParams
				If Len("" & sUrlArguments) > 0 Then
					.UrlArguments.QueryString = sUrlArguments
				End If
				.SelectableTypes = sType
				If oEventArgs.OperationValues.Exists("SelectionMode") Then
					vTemp = oEventArgs.OperationValues.item("SelectionMode")
					If UCase(Mid(CStr(vTemp), 1, 4)) = "TSM_" Then 
						On Error Resume Next
						vTemp = Eval(vTemp)
						If Err Then 
							Alert "��� �������� DoSelectFromDb ��������� �������� '" & oXmlProperty.tagNane & "' ������ ������������ �������� ��������� SelectionMode (����� ��������): " & vTemp
							' �� ���� ����� �� ����� ���������� ������ ����������
							Err.Clear
						End If
						On Error GoTo 0
					End If
					.SelectionMode = vTemp
				End If
				.SuitableSelectionModes = Array(TSM_ANYNODE, TSM_LEAFNODE)

				' ���� ������ ��������� ��� �� ����, �� �� ����� ��� ������� ���� � ����������� ������
				If Not hasValue(sExcludeNodes) And sType = oXmlProperty.parentNode.tagName Then
					sExcludeNodes = sType & "|" & oXmlProperty.parentNode.GetAttribute("oid")
				End If
				.ExcludeNodes = sExcludeNodes
				
				SelectFromTreeDialogClass_Show .Self()
				
				If .ReturnValue Then
					vRet = .Selection.selectSingleNode("n").getAttribute("id")
					oEventArgs.ObjectValueType = .Selection.selectSingleNode("n").getAttribute("ot")
				End If
			End With
		End If
		oEventArgs.Selection = vRet
	End Sub


	'==========================================================================
	' ����������� ���������� ������� "SelectXml"
	' [in] oSender - ��������� XPEObjectPresentationClass, �������� �������
	' [in] oEventArgs - ��������� SelectXmlEventArgsClass, ��������� �������
	Public Sub OnSelectXml(oSender, oEventArgs)
		oEventArgs.ReturnValue = False
        If Not hasValue(oEventArgs.Objects) Then
            Alert "��� ��������� ��� ������ ��������"
            Exit Sub
        End If
        
		' ����� ������������ �� ������
		With oEventArgs
		    .Selection = X_SelectFromXmlList(ObjectEditor, .SelectorMetaname, .ObjectValueType, LM_SINGLE, .Objects, .UrlArguments)
		    .ReturnValue = hasValue(.Selection)
		End With
	End Sub


	'==========================================================================
	' ����������� ���������� ������� "BindSelectedData"
	' [in] oSender - ��������� XPEObjectPresentationClass, �������� �������.
	' [in] oEventArgs - ��������� SelectEventArgsClass, ��������� �������.
	' ������ ���������� ���������� ������ �������� �������� ��������� ������
	' �� ���������� � ���������� ��������� ������� "OnSelect".
	' ����� ����������� ��������� ������������� �������
	Public Sub OnBindSelectedData(oSender, oEventArgs)
		Dim oXmlProperty		' xml-��������
		Dim oNewItem			' ��������� ������
		Dim sObjectID			' ������������� ���������� �������
		
		Set oXmlProperty = XmlProperty
		sObjectID = oEventArgs.Selection
		' ���� �����, ������ ����-�� ������� � �������� ������ �� ��������� ���
		' ������� ������ ��������
		With m_oPropertyEditorBase.ObjectEditor.Pool
			.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
			' �������� ��������� ������ � ���, �����, ��-������, ��������� ��� �� ���� 
			' �, ��-������, ��� ����� �� ����� �������� ��� ��������� �������� � SetData
			Set oNewItem = .GetXmlObject(oEventArgs.ObjectValueType, sObjectID, Null)
			If X_WasErrorOccured Then
				If X_GetLastError.IsObjectNotFoundException Then
					' ��������� ������ �� ������
					If EventEngine.IsHandlerExists("SelectConflict") Then
						' TODO: �������� ���� EventArgs �� ������ ��������������� ��������� ��������, ������� ��� �����������
						FireEvent "SelectConflict", Nothing
					Else
						MsgBox "��������� ������ '" & sObjectID & "' �� ��� �������� � ��������, �.�. ��� ������ ������ �������������", vbOKOnly + vbInformation
					End If
				Else
					' ���� ���� ������ ��������� ������, ������� ���������
					X_GetLastError.Show
				End If
			Else
				.AddRelation Nothing, oXmlProperty, oNewItem
			End If
		End With	
		' ������� ������
		SetDataEx oXmlProperty
	End Sub
	
	
	'==========================================================================
	' ����������� ���������� ������� "Create"
	' [in] oSender - ��������� XPEObjectPresentationClass, �������� �������
	' [in] oEventArgs - ��������� OpenEditorEventArgsClass, ��������� �������
	' ������ ���������� ���������� ����� ��������� � ������ ��������
	' ������ �������.
	Public Sub OnCreate(oSender, oEventArgs)
		Dim oXmlProperty	' xml-��������
		Dim oNewObject		' ����� ������-��������
		
		With oEventArgs
			' ������ �������������� ����������
			m_oPropertyEditorBase.ObjectEditor.Pool.BeginTransaction True
			Set oXmlProperty = XmlProperty
			' ������ ������-�������� �� ��������, ���� �� ��� ����
			m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
			' ������� ����� ������ � �������� ��� � ���
			Set oNewObject = m_oPropertyEditorBase.ObjectEditor.Pool.CreateXmlObjectInPool(ValueObjectTypeName)
			' ������� ���� ����� ������-�������� � ��������
			m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, oNewObject
			' ������� ��������� �������� � ��������� EnlistInCurrentTransaction=True, �.�. ���� �������� �� ����� ��������� ����� ����������
			.ReturnValue  = m_oPropertyEditorBase.ObjectEditor.OpenEditor(oNewObject, Null, Null, .Metaname, True, oXmlProperty, Not .IsSeparateTransaction, True, .UrlArguments)
			If IsEmpty( .ReturnValue  ) Then
				' ������ ������ - ������� ����������
				m_oPropertyEditorBase.ObjectEditor.Pool.RollbackTransaction
			Else
				' ������ �� - ���������
				m_oPropertyEditorBase.ObjectEditor.Pool.CommitTransaction
				' ������� � ���� ����� ����� ������������� (oXmlProperty ������������ ��� ������)
				SetData
			End If		
		End With
	End Sub
	
	
	'==========================================================================
	' ����������� ���������� ������� "Edit"
	' [in] oSender - ��������� XPEObjectPresentationClass, �������� �������
	' [in] oEventArgs - ��������� OpenEditorEventArgsClass, ��������� �������
	' ������ ���������� ���������� ����� ��������� � ������ ��������������
	' ������ �������.
	Public Sub OnEdit(oSender, oEventArgs)
		Dim oXmlProperty	' xml-��������
		
		With oEventArgs
			Set oXmlProperty = XmlProperty
			.ReturnValue = m_oPropertyEditorBase.ObjectEditor.OpenEditor(oXmlProperty.firstChild, Null, Null, .Metaname, False, oXmlProperty, Not .IsSeparateTransaction, False, .UrlArguments)
			If IsEmpty( .ReturnValue ) Then Exit Sub
			' oXmlProperty ������������ ��� ������
			SetData
		End With
	End Sub

	
	'==============================================================================
	' ����������� ���������� ������� MarkDelete
	' [in] oSender - ��������� XPEObjectPresentationClass, �������� �������
	' [in] oEventArgs - ��������� DeleteEventArgsClass, ��������� �������
	' ������ ���������� ����������� ������������� � �����������, ����� ���� ���������
	' �������� ������� �� �������� ��������� �����. �������� ����.
	Public Sub OnMarkDelete(oSender, oEventArgs)
		Dim oXmlProperty	' xml-��������
		
		oEventArgs.ReturnValue = False
		' ���� ����� ����� ������� ������������, �� ������� �������
		If hasValue(oEventArgs.Prompt) Then
			If Not Confirm( oEventArgs.Prompt ) Then Exit Sub
		End If
		Set oXmlProperty = XmlProperty
		oEventArgs.ReturnValue = m_oPropertyEditorBase.ObjectEditor.MarkXmlObjectAsDeleted( oXmlProperty.firstChild, oXmlProperty )
		If oEventArgs.ReturnValue Then
			SetDataEx oXmlProperty
		End If
	End Sub

	
	'==============================================================================
	' ����������� ���������� ������� UnLink
	' [in] oSender - ��������� XPEObjectPresentationClass, �������� �������
	' [in] oEventArgs - ��������� DeleteEventArgsClass, ��������� �������
	' ������ ���������� ����������� ������������� � �����������, ����� ���� ���������
	' �������� ������� �������� ���������� �������� ��������� �����. �������� ����.
	Public Sub OnUnlink(oSender, oEventArgs)
		Dim oXmlProperty		' xml-��������
		
		' ���� ����� ����� ������� ������������, �� ������� �������
		If hasValue(oEventArgs.Prompt) Then
			If Not Confirm( oEventArgs.Prompt ) Then Exit Sub
		End If
		' ����������: RemoveRelation �� ���������� ��������� ����, ������� ����� ������������� ��������� ������ �� XmlProperty
		Set oXmlProperty = XmlProperty
		
		If m_oPropertyEditorBase.DoUnlinkImplementation( oXmlProperty, oXmlProperty.firstChild  ) Then
			SetDataEx oXmlProperty
		End If
	End Sub
End Class
