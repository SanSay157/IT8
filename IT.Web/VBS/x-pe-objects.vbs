'*******************************************************************************
' ����������:	
' ����������:	����������� ���������� ������������ UI-������������� ����������
'				���������� �������� (��� �������� vt: array, collection)
'*******************************************************************************
Option Explicit

Const PE_MENU_STYLE_BUTTON_WITH_POPUP = "op-button"
Const PE_MENU_STYLE_VERTICAL_BUTTONS = "vertical-buttons"
Const PE_MENU_STYLE_HORIZONAL_BUTTONS = "horizontal-buttons"

'==============================================================================
' ����� ��������� ��������� ������� � ���� ListView � ����������.
' �������:
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
'������� DoCreate ��������� �������:
'	BeforeCreate,Create,AfterCreate - ��.XPropertyEditorObjectBaseClass
'������� DoEdit ��������� �������:
'	BeforeEdit,Edit,AfterEdit - ��.XPropertyEditorObjectBaseClass
'������� DoMarkDelete ��������� �������:
'	BeforeMarkDelete,MarkDelete,AfterMarkDelete - ��.XPropertyEditorObjectBaseClass
'������� DoUnLink ��������� �������:
'	BeforeUnlink,Unlink,AfterUnlink - ��.XPropertyEditorObjectBaseClass
'Accel - ������� ���������� ������ � ������ (���� ����������� ����������)
'SelChanged - ��������� ���������� ������ � ������ (� ��� ����� ��� �������� ����� ������)
'SelLost - �������� ��������� ������ � ������ (� ��� ����� ��� �������� ����� ������)

Class XPEObjectsElementsListClass
	Public m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_sOrderBy					' As String		- ��������� order-by ��� ���������� �������� � ��������
	Private m_bOrderByAsc				' As Boolean	- True - ����������� �� �����������, False - �� ��������
	Private EVENTS						' As String		- ������ ������� ��������
	Private m_sViewStateCacheFileName	' As String - ������������ ����� � �������������� ��������������
	Private m_bKeyUpEventProcessing		' As Boolean - ������� ��������� ActiveX-������� OnKeyUp ��� �������������� ������������ �����
	Private m_sMenuStyle				' ����� ����������� ���� ��������
	Private m_bMenuAsButtons			' As Boolean - ������� ����, ��� ���� ������������ � ���� ������ (����� ������� ��������� �������� �� ������ "���� �� ������ ��������")
	Private m_oMenuHolder				' HTC-��������� x-menu-html-pe.htc
	
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = _
			"BeforeSelect,GetRestrictions,Select,ValidateSelection,BindSelectedData,AfterSelect," & _
			"BeforeSelectXml,SelectXml,AfterSelectXml," & _
			"BeforeCreate,Create,AfterCreate," & _
			"BeforeEdit,Edit,AfterEdit," & _
			"BeforeMarkDelete,MarkDelete,AfterMarkDelete," & _
			"BeforeUnlink,Unlink,AfterUnlink," & _
			"Accel,SelectConflict,SelChanged,SelLost"
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
	' IPropertyEdior: �������������
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim oMenuMD				' As IXMLDOMElement - ���������� ���� (i:menu)
		Dim oXmlOrderBy			' As IXMLDOMElement - xml-���� i:order-by
		
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectsElementsList"
		' �������� ����������� ����������� ����� �������
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Select", Me, "OnSelect"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "BindSelectedData", Me, "OnBindSelectedData"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "AfterSelect", Me, "OnAfterSelect"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Create", Me, "OnCreate"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "AfterCreate", Me, "OnAfterCreate"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Edit", Me, "OnEdit"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "AfterEdit", Me, "OnAfterEdit"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "MarkDelete", Me, "OnMarkDelete"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Unlink", Me, "OnUnlink"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Accel", Me, "OnAccel"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "SelectXml", Me, "OnSelectXml"
		
		' �������������� ����: ������� ��� ����������, ������� ����������� ����������� 
		Set oMenuMD = m_oPropertyEditorBase.PropertyEditorMD.selectSingleNode("i:prop-menu")
		If Not oMenuMD Is Nothing Then
			m_sMenuStyle = oMenuMD.getAttribute("menu-style")
			If not hasValue(m_sMenuStyle) Then m_sMenuStyle = PE_MENU_STYLE_BUTTON_WITH_POPUP
			m_bMenuAsButtons = (m_sMenuStyle = PE_MENU_STYLE_HORIZONAL_BUTTONS Or m_sMenuStyle = PE_MENU_STYLE_VERTICAL_BUTTONS)
		End If
		
		Set m_oMenuHolder = ExtraHtmlElement("Menu")
		m_oMenuHolder.Init Me, X_CreateDelegate(Me, "Internal_MenuMacrosResolver"), X_CreateDelegate(Me, "Internal_MenuVisibilityHandler"), X_CreateDelegate(Me, "Internal_MenuExecutionHandler")

		With m_oPropertyEditorBase
			If Not .PropertyMD.getAttribute("cp") = "array" And IsNull(.PropertyMD.getAttribute("order-by")) Then
				Set oXmlOrderBy = .PropertyEditorMD.selectSingleNode("i:order-by")
				If Not oXmlOrderBy Is Nothing Then
					m_sOrderBy = oXmlOrderBy.text
					m_bOrderByAsc = X_GetAttributeDef(oXmlOrderBy, "desc", "0") <> "1"
				End If
			End If
		End With
		m_sViewStateCacheFileName = ObjectEditor.Signature() & "XArrayProp." + oXmlProperty.parentNode.tagName & "." & oXmlProperty.tagName & "." & m_oPropertyEditorBase.PropertyEditorMD.getAttribute("n")
		InitXListViewInterface HtmlElement, m_oPropertyEditorBase.PropertyEditorMD, m_sViewStateCacheFileName, True
		' ����������� ������� � ��������
		SortProperty ObjectEditor, XmlProperty, m_sOrderBy, m_bOrderByAsc
	End Sub

	
	'==========================================================================
	' IPropertyEdior: ����� ���������� ��� ���������� �������� ���������, ����� ������������� ���� PE �� ��������
	Public Sub FillData()
		' ��������� ����������� ����
		m_oMenuHolder.UpdateMenuState True
	End Sub

	Private m_nTimeoutHandle ' - ������
	Private m_nPrevRow ' - ������ ����� ���������� ������ (��� -1, ���� ��������� ���������).

	'==========================================================================
	' ���������� ActiveX-������� OnSelChange ������
	' 	[in] sSelf - ������ � ��������������� ������� ���������� �������
	'	[in] nPrevRow	- ������ ����� ���������� ������ (��� -1, ���� ��������� ���������).
	'	[in] nNewRow	- ������ ����� ���������� ������ (��� -1, ���� ��������� ���������).
	Public Sub Internal_DispatchOnSelChange(sSelf, nPrevRow, nNewRow)
		const DELAY_VALUE = 100 ' �������� � ������������
		If IsEmpty(m_nTimeoutHandle) Then	
			m_nPrevRow = nPrevRow
		Else
			clearTimeout m_nTimeoutHandle
		End If
		m_nTimeoutHandle = setTimeout("Dim o: Set o=" & sSelf & ": If Not o Is Nothing Then : o.Internal_OnSelChange " & nNewRow & ": End If", DELAY_VALUE, "VBScript")
	End Sub

	'==========================================================================
	' ���������� ActiveX-������� OnSelChange ������
	'	[in] nNewRow	- ������ ����� ���������� ������ (��� -1, ���� ��������� ���������).
	Public Sub Internal_OnSelChange(nNewRow)
		clearTimeout m_nTimeoutHandle
		m_nTimeoutHandle = Empty
		' ������� ��������� ����
		m_oMenuHolder.UpdateMenuState True
		' ����������� ������� ����������� ����
		fireEventAboutSelChanging m_nPrevRow, nNewRow
	End Sub

	'==========================================================================
	' ��������� ������� SelChanged � SelLost
	'	[in] nPrevRow	- ������ ����� ���������� ������ (��� -1, ���� ��������� �� ����).
	'	[in] nNewRow	- ������ ����� ���������� ������ (��� -1, ���� ��������� ���������).
	Private Sub fireEventAboutSelChanging(nPrevRow, nNewRow)
		If nNewRow > -1 Then
			If m_oPropertyEditorBase.EventEngine.IsHandlerExists("SelChanged") Then
				With New ListViewSelChangeEventArgsClass
					.UnselectedRowIndex = nPrevRow
					.SelectedRowIndex = nNewRow
					FireEvent "SelChanged", .Self()
				End With
			End If
		Else
			If m_oPropertyEditorBase.EventEngine.IsHandlerExists("SelLost") Then
				With New ListViewSelChangeEventArgsClass
					.UnselectedRowIndex = nPrevRow
					.SelectedRowIndex = -1
					FireEvent "SelLost", .Self()
				End With
			End If
		End If
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property
	
	
	'==========================================================================
	' IPropertyEdior: ������������� �������� � ����������
	Public Sub SetData
		SetDataEx XmlProperty
	End Sub
	
	'==========================================================================
	' ������������� ��������. ������������ ��� �����������, �.�. �� �������� XmlProperty ����������� ����������
	'	[in] oXmlProperty As IXMLDOMElement - �������������� ������ �� ������� xml-��������
	Private Sub SetDataEx(oXmlProperty)
		' �������� ������ ���������� ���������� ��������:
		FillXListViewEx HtmlElement, m_oPropertyEditorBase, oXmlProperty, m_oPropertyEditorBase.PropertyEditorMD, HideIf
	End Sub
	
	'==========================================================================
	' ���������� ������� HideIf
	Public Property Get HideIf
		HideIf = HtmlElement.GetAttribute("HIDE_IF")
		If Not HasValue(HideIf) Then HideIf = Null
	End Property
	
	'==========================================================================
	' IPropertyEdior: ���� ������
	Public Sub GetData(oGetDataArgs)
		' �������� �������
		X_SaveViewStateCache m_sViewStateCacheFileName, HtmlElement.Columns.Xml
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: ��������� (��)��������������
	Public Property Get Mandatory
		Mandatory = False
	End Property
	Public Property Let Mandatory(bMandatory)
	End Property
	
	
	'==========================================================================
	' IPropertyEdior: ��������� (��)�����������
	Public Property Get Enabled
		Enabled = HtmlElement.object.Enabled 
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.object.Enabled = bEnabled

		m_oMenuHolder.SetEnableState bEnabled
		
		' ���������� ������������ ������ �����/����
		If Not IsNull(HtmlElement.GetAttribute("X_SHIFT_OPERATIONS")) Then
			ExtraHtmlElement("ButtonUp").disabled = Not( bEnabled )
			ExtraHtmlElement("ButtonDown").disabled = Not( bEnabled )
		End If
	End Property
	
	
	'==========================================================================
	' IPropertyEdior: ��������� ������ (����������)
	Public Sub SetFocus
		window.setTimeout ObjectEditor.UniqueID & ".CurrentPage.GetPropertyEditorByFullHtmlID(""" & HtmlElement.id & """).Internal_SetFocus", 1, "VBScript"		
	End Sub
	
	'==========================================================================
	' ��������� ������
	Public Sub Internal_SetFocus
		' �����! ��� window.focus ����� ������ �� ���������������
		window.focus
		X_SafeFocus( HtmlElement )
	End Sub
	
	'==========================================================================
	' IPropertyEdior: ���������� IHTMLElement ������
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property
	
	
	'==========================================================================
	' ���������� �������������� ������� IHTMLElement
	Public Function ExtraHtmlElement(sName)
		Set ExtraHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.id & sName)
	End Function


	'==========================================================================
	' ����������/������������� �������� ��������
	Public Property Get PropertyDescription
		PropertyDescription = m_oPropertyEditorBase.PropertyDescription
	End Property	
	Public Property Let PropertyDescription(sValue)
		m_oPropertyEditorBase.PropertyDescription = sValue
	End Property


	'==========================================================================
	' IDisposable
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
		Set m_oPropertyEditorBase = Nothing
	End Sub	


	'==========================================================================
	' ���������� �������
	'	[in] sEventName - ������������ �������
	'	[in] oEventArgs - ��������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	
	
	
	'==========================================================================
	' ���������� xml-�������-�������� xml-��������
	'	[retval] IXMLDOMNodeList �������� � ����, �� ������� ����������� ������ � ��������, ���� Nothing, ���� ��-�� ������
	Public Property Get Value
		Dim oXmlProperty		' As IXMLDOMElement
		
		Set oXmlProperty = XmlProperty
		If oXmlProperty.FirstChild Is Nothing Then
			Set Value = Nothing
		Else	
			' �������� ������-��������
			Set Value = m_oPropertyEditorBase.ObjectEditor.Pool.GetXmlObjectsByXmlNodeList( oXmlProperty.ChildNodes, Null )
		End If
	End Property
	
	
	'==========================================================================
	' ���������� �������������� ��������-�������� xml-��������
	Public Property Get ValueID
		Dim sRetVal		' As String - ������������ ��������
		Dim oNode		' As IXMLDOMElement - xml-�������� ������� �������� ��������
		For Each oNode In XmlProperty.ChildNodes
			If Not IsEmpty(sRetVal) Then
				sRetVal = sRetVal & ";"
			End If
			sRetVal = sRetVal & oNode.getAttribute("oid")
		Next
		ValueID = sRetVal
	End Property


	'==========================================================================
	' IPropertyEditorObject: ���������� ������������ ���� ������� �������� ��������
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyEditorBase.ValueObjectTypeName
	End Property

	
	'==========================================================================
	' IPropertyEditorObject: ���������� ��� ��������� ��� ������: list ��� tree
	Public Property Get SelectorType
		SelectorType = m_oPropertyEditorBase.SelectorType
	End Property
	Public Property Let SelectorType(sValue)
		m_oPropertyEditorBase.SelectorType = sValue
	End Property

	
	'==========================================================================
	' IPropertyEditorObject: ������� ���������
	Public Property Get SelectorMetaname
		SelectorMetaname = m_oPropertyEditorBase.SelectorMetaname
	End Property
	Public Property Let SelectorMetaname(sValue)
		m_oPropertyEditorBase.SelectorMetaname = sValue
	End Property


	'==========================================================================
	' ���������� ������� ����, ��� PE ������������ ���������� �������� � �������� �� ��������� VBS-���������
	Public Property Get IsOrdered
		IsOrdered = Len("" & m_sOrderBy) > 0
	End Property

	
	'==========================================================================
	' ����������/������������� VBS-���������, ������������ ��� ���������� �������� � ��������
	Public Property Get OrderByExpression	' As String
		OrderByExpression = m_sOrderBy
	End Property
	Public Property Let OrderByExpression(sExpr)
		m_sOrderBy = sExpr
	End Property

	
	'==========================================================================
	' ����������/������������� ����� ����������: True - ����������� �� �����������, False - �� ��������
	' ���� PE �� �����������, �� �������� �� ����������
	Public Property Get OrderByAsc		' As Boolean
		OrderByAsc = m_bOrderByAsc
	End Property
	Public Property Let OrderByAsc(bValue)
		m_bOrderByAsc = bValue
	End Property

	
	'==========================================================================
	' ������������� ���������� �������� � �������� � ����� �������� ���������� ��������
	' ���������� ������������� PE �� �����������
	'	[in] sOrderByExpression - VBS-���������, ������������ ��� ���������� �������� � ��������
	'	[in] bAsc - True - ����������� �� �����������, False - �� ��������
	Public Sub SetPropertySorting(sOrderByExpression, bAsc)
		m_sOrderBy = sOrderByExpression
		m_bOrderByAsc = CBool(bAsc = True)
		' ����������� ������� � ��������
		SortProperty ObjectEditor, XmlProperty, m_sOrderBy, m_bOrderByAsc
	End Sub

	
	'==========================================================================
	' "���������" ���������� �������� � ��������. ��������� �������� � �������� �� ����������
	Public Sub DisablePropertySorting
		m_bOrderByAsc = vbNullString
	End Sub

	
	'==========================================================================
	' ������������
	
	'==========================================================================
	' ���������� ������� ������� � ������
	Sub Internal_OnKeyUpAsync(ByVal nKeyCode, ByVal nFlags)
		Dim oEventArgs		' As AccelerationEventArgsClass
		Dim nPosLeft, nPosTop, nPosRight, nPosBottom	' ������������� ���������� ��������� ������ ������
		Dim nListPosX, nListPosY	' �������� ���������� ������ (ListView)
		Dim nRow					' ������ ��������� ������
		
		If m_bKeyUpEventProcessing Then Exit Sub
		m_bKeyUpEventProcessing = True
		
		' ������� ���������� ������ ������
		nRow = m_oPropertyEditorBase.HtmlElement.Rows.SelectedPosition
		If nRow > -1 Then
			m_oPropertyEditorBase.HtmlElement.GetRowCoords nRow, nPosLeft, nPosTop, nPosRight, nPosBottom
		Else
			m_oPropertyEditorBase.HtmlElement.GetRowCoords 0, nPosLeft, nPosTop, nPosRight, nPosBottom
		End If
		X_GetHtmlElementScreenPos m_oPropertyEditorBase.HtmlElement, nListPosX, nListPosY
		If nRow < 0 Then nListPosY = nListPosY + 16
		nListPosY = nListPosY + nPosBottom
		
		If nKeyCode = VK_APPS Then
			m_oMenuHolder.ShowPopupMenuWithPos nListPosX, nListPosY
		Else
			Set oEventArgs = CreateAccelerationEventArgsForActiveXEvent(nKeyCode, nFlags)
			Set oEventArgs.Source = Me
			Set oEventArgs.HtmlSource = HtmlElement
			oEventArgs.MenuPosX = nListPosX
			oEventArgs.MenuPosY = nListPosY
			FireEvent "Accel", oEventArgs
			If Not oEventArgs.Processed Then
				' ��������� ������� ���������� � ��������
				ObjectEditor.OnKeyUp Me, oEventArgs
			End If
		End If
		m_bKeyUpEventProcessing = False
	End Sub


	'==========================================================================
	' ���������� �������� ����� � ������
	Sub Internal_OnDblClickAsync(ByVal nIndex , ByVal nColumn, ByVal sID)
		' ����-���� ���������� � ������� �����
		With New AccelerationEventArgsClass
			.keyCode	= VK_ENTER
			.altKey		= False
			.ctrlKey	= False
			.shiftKey	= False
			.DblClick	= True
			FireEvent "Accel", .Self()
		End With
	End Sub

		
	'==========================================================================
	' ����������� ���������� ������� "Accel"
	'	[in] oEventArgs As AccelerationEventArgsClass
	Public Sub OnAccel(oSender, oEventArgs)
		' ������� ������� ���������� � ���� ������ - ����� ��� ��� ��� ���������� hotkey'�
		m_oMenuHolder.ExecuteHotkey oEventArgs
	End Sub


	'==========================================================================
	' ���������� ����� ������ ������� ���� 
	Public Sub Internal_OnContextMenuAsync()
		m_oMenuHolder.ShowPopupMenu 
	End Sub


	'==========================================================================
	' ����������� �������� ������� ����
	'	[in] oEventArgs As MenuEventArgsClass
	Sub Internal_MenuMacrosResolver(oSender, oEventArgs)
		oEventArgs.Menu.Macros.Item("ObjectID") = HtmlElement.Rows.SelectedID
		oEventArgs.Menu.Macros.Item("ObjectType") = ValueObjectTypeName
	End Sub

	
	'==========================================================================
	' ����������� ���������� ���������/�����������
	'	[in] oEventArgs As MenuEventArgsClass
	Sub Internal_MenuVisibilityHandler(oSender, oEventArgs)
		Dim bDisabled		' ������� ����������������� ������
		Dim bHidden			' ������� �������� ������
		Dim oNode			' ������� menu-item
		Dim sType			' ��� ������� � ��������
		Dim sObjectID		' ������������� ���������� �������
		Dim oObjectValue	' As IXMLDOMElement - xml-������ ��������
		Dim oList			' As ObjectArrayListClass - ������ �������� XObjectPermission
		Dim bIsLoaded		' As Boolean - ������� ����,��� ������-�������� �������� �� ��
		Dim bProcess		' As Boolean - ������� ��������� �������� ������
		
		sType = m_oPropertyEditorBase.PropertyMD.getAttribute("ot")
		sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
		If 0=Len("" & sObjectID) Then
			sObjectID = Empty
		End If 
		If Not IsEmpty(sObjectID) Then
			Set oObjectValue = ObjectEditor.Pool.GetXmlObject(sType, sObjectID, Null)
			If Not oObjectValue Is Nothing Then
				bIsLoaded = IsNull(oObjectValue.getAttribute("new"))
			End If
		End If	
		
		Set oList = New ObjectArrayListClass
		' ���������� ������ ��������� ��� ��������
		For Each oNode In oEventArgs.ActiveMenuItems
			' ��������� �������� �� ������ ����, ����� oMenu.SetMenuItemsAccessRights ���� ������� ������� �� �������� ���� � ������ ���� (��� ������������ ����� disabled)
			oNode.setAttribute "type", sType
			If Not IsNull(sObjectID) Then _
				oNode.setAttribute "oid",  sObjectID
				
			bHidden = Empty
			bDisabled = Empty
			bProcess = False
			Select Case oNode.getAttribute("action")
				Case "DoSelectFromDb", "DoSelectFromXml"
					bHidden = HasValue(HtmlElement.getAttribute("OFF_SELECT"))
					bProcess = True
				Case "DoCreate"
					bHidden = HasValue(HtmlElement.getAttribute("OFF_CREATE"))
					If Not bHidden Then
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CREATE, sType, Empty)
					End If
					bProcess = True
				Case "DoEdit"
					If m_bMenuAsButtons Then
						bHidden = HasValue(HtmlElement.getAttribute("OFF_EDIT"))
						bDisabled = IsEmpty(sObjectID)
					Else
						bHidden = IsEmpty(sObjectID) Or HasValue(HtmlElement.getAttribute("OFF_EDIT"))
					End If
					If (Not bHidden Or Not bDisabled) And bIsLoaded Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CHANGE, sType, sObjectID)
					bProcess = True
				Case "DoMarkDelete"
					If m_bMenuAsButtons Then
						bHidden = HasValue(HtmlElement.getAttribute("OFF_DELETE"))
						bDisabled = IsEmpty(sObjectID)
					Else
						bHidden = IsEmpty(sObjectID) Or HasValue(HtmlElement.getAttribute("OFF_DELETE"))
					End If
					If (Not bHidden Or Not bDisabled) And bIsLoaded Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_DELETE, sType, sObjectID)
					bProcess = True
				Case "DoUnlink"
					' ���� ���� � �������� ��������� ��������� �������� (�� �������� ������� �������� � ������)
					' �������������, �� �������� "��������� �����" ������ ���� ������������ ������
					If m_oPropertyEditorBase.PropertyMD.getAttribute("cp") = "link" Then
						If IsNull(ObjectEditor.Pool.GetReversePropertyMD(XmlProperty).getAttribute("maybenull")) Then
							bHidden = True
						End If
					End If
					If Not bHidden Then
						If m_bMenuAsButtons Then
							bDisabled = IsEmpty(sObjectID)
							bHidden = HasValue(HtmlElement.getAttribute("OFF_UNLINK"))
						Else
							bHidden = IsEmpty(sObjectID) Or HasValue(HtmlElement.getAttribute("OFF_UNLINK"))
						End If
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
			oEventArgs.Menu.SetMenuItemsAccessRights oList.GetArray()
		End If
	End Sub

	
	'==========================================================================
	' ����������� ���������� ������ ������ ����
	'	[in] oMenuExecuteEventArgs As MenuExecuteEventArgsClass
	Sub Internal_MenuExecutionHandler(oSender, oEventArgs)
		oEventArgs.Cancel = True
		Select Case oEventArgs.Action
			Case "DoSelectFromDb"
				' ����� �� ��
				m_oPropertyEditorBase.DoSelectFromDb oEventArgs.Menu.Macros
			Case "DoSelectFromXml"
				' ����� �� Xml
				m_oPropertyEditorBase.DoSelectFromXml oEventArgs.Menu.Macros
			Case "DoCreate"
				' ������� � ������� ����������
				m_oPropertyEditorBase.DoCreate oEventArgs.Menu.Macros, False
			Case "DoEditAndSave"
				' ������������� � ��������� � ��
				m_oPropertyEditorBase.DoEdit oEventArgs.Menu.Macros, True
			Case "DoEdit"
				' ������������� � ������� ���������
				m_oPropertyEditorBase.DoEdit oEventArgs.Menu.Macros, False
			Case "DoMarkDelete"
				' �������� ������ ��� ��������� � ������� ������ �� ���� �� ��������
				m_oPropertyEditorBase.DoMarkDelete oEventArgs.Menu.Macros
			Case "DoUnlink"
				' ������� ������ �� ������ �� ��������
				m_oPropertyEditorBase.DoUnlink oEventArgs.Menu.Macros
			Case Else
				oEventArgs.Cancel = False
		End Select
		SetFocus
	End Sub

	
	'==========================================================================
	' ����������� ���������� ������� "Select"
	'	[in] oEventArgs As SelectEventArgsClass
	Public Sub OnSelect(oSender, oEventArgs)
		Dim sType					' As String		- ��� �������-��������
		Dim sParams					' As String		- ��������� ��� data-source (Param1=Value1&Param2=Value2)
		Dim sUrlArguments			' As String		- ��������� ���������
		Dim sExcludeNodes			' As String		- ������ ����������� ����� ��� ������ �� ������
		Dim vRet					' As String		- ��������� ������
		Dim oXmlProperty			' As XMLDOMElement	- xml-��������
		Dim vTemp
		Dim i
		
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
		If SelectorType="list" Then
			' ����� ������������ �� ������
			vRet = X_SelectFromList(SelectorMetaname, sType, LM_MULTIPLE, sParams, sUrlArguments)
		Else
			' ������� ������ � ������� ��������� ��������
			With New SelectFromTreeDialogClass
				.Metaname = SelectorMetaname
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
				.SuitableSelectionModes = Array(TSM_ANYNODES, TSM_LEAFNODES)
				
				' ���� ������ ��������� ��� �� ����, �� �� ����� ��� ������� ���� � ����������� ������
				If Not hasValue(sExcludeNodes) And sType = oXmlProperty.parentNode.tagName Then
					sExcludeNodes = sType & "|" & oXmlProperty.parentNode.GetAttribute("oid")
				End If
				.ExcludeNodes = sExcludeNodes 
				
				' ������� ������ � ������� ������� ����� ��� �� ��������� SelectFromTreeDialogClass
				SelectFromTreeDialogClass_Show .Self()
				
				vRet = Empty
				If .ReturnValue Then
					With .Selection.selectNodes("n[@ot='" & sType & "']")
						If .length = 0 Then
							vRet = Empty
						Else
							ReDim vRet(.length-1)
							For i=0 To .length-1
								vRet(i) =  .item(i).getAttribute("id")
							Next
						End If
					End With
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
		    .Selection = X_SelectFromXmlList(ObjectEditor, .SelectorMetaname, .ObjectValueType, LM_MULTIPLE, .Objects, .UrlArguments)
		    .ReturnValue = hasValue(.Selection)
		End With
	End Sub

	
	'==========================================================================
	' ����������� ���������� ������� "BindSelectedData"
	'	[in] oEventArgs As SelectEventArgsClass
	Public Sub OnBindSelectedData(oSender, oEventArgs)
		Dim oXmlProperty		' xml-��������
		Dim vSelection			' ������ ���������������
		Dim i
		Dim oNewItem			' ��������� ������
		Dim bObjectNotFound		' ������� ��� ��������� ������ �� ��� �������
		
		Set oXmlProperty = XmlProperty
		vSelection = oEventArgs.Selection
		If IsEmpty(vSelection) Then Exit Sub
		If Not IsArray(vSelection) Then Exit Sub
		With m_oPropertyEditorBase.ObjectEditor.Pool
			bObjectNotFound = False
			For i=0 To UBound(vSelection)
				If Nothing Is oXmlProperty.selectSingleNode("*[@oid='" & vSelection(i) & "']") Then
					' ������� �� ���� � �������� - �������
					Set oNewItem = .GetXmlObject(ValueObjectTypeName, vSelection(i), Null)
					If X_WasErrorOccured Then
						' �������� ������ ��� �������� ������� � ���
						If X_GetLastError.IsObjectNotFoundException Then
							bObjectNotFound = True
						ElseIf X_GetLastError.IsSecurityException or X_GetLastError.IsBusinessLogicException Then
							' � ���������� ������� �������� ������ - ������� ��� �������
							MsgBox "� ���������� ������� '" & vSelection(i) & "' �������� ������." & vbCr & X_GetLastError.LastServerError.getAttribute("user-msg")
						End If
						vSelection(i) = " "
					Else
						If IsNothing(oNewItem) Then Exit Sub	' �����-�� ������ ������
						' ��������� ������ ������� �������� � ��� - ������� � ��������
						AppendXmlObjectEx oXmlProperty, oNewItem
					End If
				Else
					' ������ ��� � �������� - �������� ������������� �� ������
					vSelection(i) = " "
				End If
			Next
			If bObjectNotFound Then
				' ���� ��� ����������� ������� ���������
				If EventEngine.IsHandlerExists("SelectConflict") Then
					' TODO: �������� ���� EventArgs �� ������ ��������������� ��������� ��������, ������� ��� �����������
					FireEvent "SelectConflict", Nothing
				Else
					MsgBox "��������� ��������� ������� �� ���� ��������� � ������, �.�. ���� ������� ������ �������������", vbOKOnly + vbInformation
				End If
			End If
		End With	
		' ���������� ������ ��������������� ��������, ������� ����������� � ��������
		vSelection = Split(Replace(Replace(Join(vSelection, ","), ", ", ""), " ,", ""),",")
		oEventArgs.ReturnValue = vSelection
		If UBound(vSelection) = -1 Then Exit Sub ' ������ �� ����������!
		' ������� ������
		SetDataEx oXmlProperty
	End Sub


	'==========================================================================
	' ����������� ���������� ������� "AfterSelect"
	'	[in] oEventArgs As SelectEventArgsClass
	Public Sub OnAfterSelect(oSender, oEventArgs)
		If UBound(oEventArgs.ReturnValue) = -1 Then Exit Sub ' ������ �� ����������!
		SelectRowForObject oEventArgs.ReturnValue(0)
	End Sub
	
	
	'==========================================================================
	' ��������� ������ � ��������. 
	'	[in] oNewItem - ����������� ������.
	Public Sub AppendXmlObject(oNewItem)
		AppendXmlObjectEx XmlProperty, oNewItem
	End Sub


	'==========================================================================
	' ��������� ������ � ��������. 
	'	[in] oXmlProperty - �������� (��� �����������)
	'	[in] oNewItem - ����������� ������.
	Public Sub AppendXmlObjectEx(oXmlProperty, oNewItem)
		If IsOrdered Then
			' ������ ��������� ��� ���������� �������� � ��������
			InsertXmlObject oXmlProperty, oNewItem
		Else
			' �� ������ ��������� ��� ���������� - ������� ������ � ����� ��������
			m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, oNewItem
		End If
	End Sub

	
	'==========================================================================
	' ��������� ������ � �������� � ������ ����������, �������� ��������� i:order-by ������
	'	[in] oXmlProperty - ��������
	'	[in] oNewItem - ����������� ������.
	Private Sub InsertXmlObject(oXmlProperty, oNewItem)
		Dim sNewItemOrderBy		' ����������� ��������� ��� ���������� ���������� �������
		Dim sItemOrderBy		' ����������� ��������� ��� ����������
		Dim oItem				' ������ � ��������
		Dim bFound				' ������� ���������� �������, ����� ������� ��������� �����
		
		If IsOrdered = False Then Err.Raise -1, "InsertXmlObject", "����� ������ ���������� ������ ��� ����������� �������"
		' ������ �������� � ���, �������� ��������� ��� ����������
		sNewItemOrderBy = ObjectEditor.ExecuteStatement( oNewItem, m_sOrderBy)
		For Each oItem In oXmlProperty.SelectNodes("*")
			' �� ���� �������� � ��������, ������ ������ ����� ������� ���� �������� ��������� ������
			sItemOrderBy = ObjectEditor.ExecuteStatement( oItem, m_sOrderBy)
			bFound = False
			If m_bOrderByAsc Then
				' ��������� �� �����������
				If sNewItemOrderBy < sItemOrderBy Then bFound = True
			Else
				' ��������� �� ��������
				If sNewItemOrderBy > sItemOrderBy Then bFound = True
			End If
			If bFound Then
				' ����� ����, ����� ������� ���� ��������
				m_oPropertyEditorBase.ObjectEditor.Pool.AddRelationWithOrder Nothing, oXmlProperty, oNewItem, oItem
				Exit For
			End If
		Next
		If Not bFound Then
			' ���� �� ����� ���� (���� �����, �� bFound �������� ���� �������� True) -
			' ������� � �����
			m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, oNewItem
		End If
	End Sub


	'==========================================================================
	' ������������� ������� ������� � �������� � ������ �������� ���������� (i:order-by)
	' �������� ������ ��� �������, ��� ������� ����� ������� order-by.
	'	[in] oNewObjectInProp - ������ ��� �������� ������� � ��������, ��� �������� ���� ���������� 
	' ������� � �������� � ������ order-by
	Public Sub OrderObjectInProp( ByVal oNewObjectInProp )
		Dim oXmlProperty	' xml-��������
		
		If IsOrdered = False Then Err.Raise -1, "", "����� ������ ���������� ������ ��� ����������� �������"
		Set oXmlProperty = XmlProperty
		' ���� ���������� ������ �� �������� � �������� - �������
		If Not oNewObjectInProp.parentNode Is oXmlProperty Then
			Set oNewObjectInProp = oXmlProperty.appendChild( X_CreateStubFromXmlObject(oNewObjectInProp) )
		End If
		OrderObjectInPropEx oXmlProperty, oNewObjectInProp
	End Sub
	
	
	'==========================================================================
	' ������������� ������� ������� � �������� � ������ �������� ���������� (i:order-by)
	' �������� ������ ��� �������, ��� ������� ����� ������� order-by.
	'	[in] oXmlProperty - xml-�������� (��� �����������)
	'	[in] oNewObjectInProp - �������� ������� � ��������, ��� �������� ���� ���������� ���������� ���������
	Private Sub OrderObjectInPropEx( oXmlProperty, oNewObjectInProp )
		Dim sNewItemOrderBy		' ����������� ��������� ��� ���������� ���������� �������
		Dim sItemOrderBy		' ����������� ��������� ��� ����������
		Dim oItem				' ������ � ��������
		Dim bFound				' ������� ���������� �������, ����� ������� ��������� �����
		
		' ���� � �������� ������ 2-� ��������, �� ����������� ������
		If oXmlProperty.childNodes.length < 2 Then Exit Sub
		' ������ �������� � ���, �������� ��������� ��� ����������
		sNewItemOrderBy = ObjectEditor.ExecuteStatement( oNewObjectInProp, m_sOrderBy )
		For Each oItem In oXmlProperty.SelectNodes("*")
			' �� ���� �������� � ��������, ������ ������ ����� ������� ���� �������� ��������� ������
			sItemOrderBy = ObjectEditor.ExecuteStatement( oItem, m_sOrderBy)
			bFound = False
			If m_bOrderByAsc Then
				' ��������� �� �����������
				If sNewItemOrderBy < sItemOrderBy Then bFound = True
			Else
				' ��������� �� ��������
				If sNewItemOrderBy > sItemOrderBy Then bFound = True
			End If
			If bFound Then
				' ����� ����, ����� ������� ���� ��������
				oXmlProperty.insertBefore oNewObjectInProp, oItem
				Exit Sub
			End If
		Next
		' �� ����� � �������� ������, ����� ������� ���� �������� ���������� ������, ������� ���������� ��� � �����/������ (���� �� ��� �� ���)
		If m_bOrderByAsc Then
			If Not oXmlProperty.lastChild Is oNewObjectInProp Then
				oXmlProperty.insertBefore oNewObjectInProp, Null
			End If
		Else
			If Not oXmlProperty.firstChild Is oNewObjectInProp Then
				oXmlProperty.insertBefore oNewObjectInProp, oXmlProperty.firstChild
			End If
		End If
	End Sub


	'==========================================================================
	' ����������� ���������� ������� "Create"
	'	[in] oEventArgs As OpenEditorEventArgsClass
	Public Sub OnCreate(oSender, oEventArgs)
		Dim oXmlProperty		' xml-��������
		Dim oNewObject			' ����� ������-��������
		Dim oNewObjectInProp	' �������� �������-�������� � ��������
		
		With oEventArgs
			' ������ �������������� ����������
			m_oPropertyEditorBase.ObjectEditor.Pool.BeginTransaction True
			' �����: ������ oXmlProperty �������� ����� ������ BeginTransaction, ������� �� ����� ������������ � ����� CommitTransaction
			Set oXmlProperty = XmlProperty
			' ������� ����� ������ � �������� ��� � ���
			Set oNewObject = m_oPropertyEditorBase.ObjectEditor.Pool.CreateXmlObjectInPool(ValueObjectTypeName)
			' ������� ���� ����� ������-�������� � ��������
			Set oNewObjectInProp = m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation( Nothing, oXmlProperty, oNewObject )
			' ������� ��������� �������� � ��������� EnlistInCurrentTransaction=True, �.�. ���� �������� �� ����� ��������� ����� ���������� 
			.ReturnValue  = m_oPropertyEditorBase.ObjectEditor.OpenEditor(oNewObject, Null, Null, .Metaname, True, oXmlProperty,Not .IsSeparateTransaction, True, .UrlArguments)
			If IsEmpty( .ReturnValue  ) Then
				' ������ ������ - ������� ����������
				m_oPropertyEditorBase.ObjectEditor.Pool.RollbackTransaction
			Else
				' ������ �� - ���������
				If IsOrdered Then
					' ���� �������� ����������� - ������� ���������� � �������� � ������ ����������
					' �.�. �� �������� ������� ���������� ����� ���������� �� ��������� ���������, 
					' ���������� ������������ ������ �� �������� � ��������
					Set oXmlProperty = XmlProperty
					Set oNewObjectInProp = oXmlProperty.selectSingleNode(oNewObjectInProp.tagName & "[@oid='" & oNewObjectInProp.getAttribute("oid") & "']")
					OrderObjectInPropEx oXmlProperty, oNewObjectInProp
				End If
				m_oPropertyEditorBase.ObjectEditor.Pool.CommitTransaction
				' ������� ������������� PE
				SetData
			End If		
		End With
	End Sub

	
	'==========================================================================
	' ����������� ���������� ������� "AfterCreate"
	'	[in] oEventArgs As OpenEditorEventArgsClass
	Public Sub OnAfterCreate(oSender, oEventArgs)
		If hasValue(oEventArgs.ReturnValue) Then
			SelectRowForObject oEventArgs.ReturnValue
		End If
	End Sub
	
	
	'==============================================================================
	' ����������� ���������� ������� Edit
	'	[in] oEventArgs As OpenEditorEventArgsClass
	Public Sub OnEdit(oSender, oEventArgs)
		Dim oXmlProperty		' xml-��������

		With oEventArgs
			' � ����������� ���...
			.ReturnValue = m_oPropertyEditorBase.ObjectEditor.OpenEditor(Null, ValueObjectTypeName, .ObjectID, .Metaname, False, XmlProperty, Not .IsSeparateTransaction, False, .UrlArguments)
			If IsEmpty( .ReturnValue ) Then Exit Sub
			Set oXmlProperty = XmlProperty
			If IsOrdered Then
				' ���� �������� ����������� - ���������� ����������������� ������ � ������ ����������
				OrderObjectInPropEx oXmlProperty, oXmlProperty.selectSingleNode(ValueObjectTypeName & "[@oid='" & .ObjectID & "']")
			End If
			' ������� ������������� PE
			SetDataEx oXmlProperty
		End With
	End Sub


	'==========================================================================
	' ����������� ���������� ������� "AfterEdit"
	'	[in] oEventArgs As OpenEditorEventArgsClass
	Public Sub OnAfterEdit(oSender, oEventArgs)
		If hasValue(oEventArgs.ReturnValue) Then
			SelectRowForObject oEventArgs.ReturnValue
		End If
	End Sub


	'==============================================================================
	' ����������� ���������� ������� MarkDelete
	'	[in] oEventArgs As OperationEventArgsClass
	Public Sub OnMarkDelete(oSender, oEventArgs)
		Dim oXmlProperty	' xml-��������
		Dim nButtonFlag		' ����� MsgBox
		
		With oEventArgs
			.ReturnValue = False
			' ���� ����� ����� ������� ������������, �� ������� �������
			If hasValue(.Prompt) Then
				' ����������, ����� �������� ���������� �������������� ������� OnKeyUp �� ������� Enter � �������
				HtmlElement.object.Enabled = False
				nButtonFlag = iif(StrComp(.OperationValues.Item("DefaultButton"), "No")=0, vbDefaultButton2, vbDefaultButton1)
				If vbNo = MsgBox(.Prompt, vbYesNo + vbInformation + nButtonFlag) Then
					HtmlElement.object.Enabled = True
					SetFocus
					Exit Sub
				End If
				HtmlElement.object.Enabled = True
			End If
			
			' ����������: MarkObjectAsDeleted �� ���������� ��������� ����, ������� ����� ������������� ��������� ������ �� XmlProperty
			Set oXmlProperty = XmlProperty
			.ReturnValue = m_oPropertyEditorBase.ObjectEditor.MarkObjectAsDeleted( ValueObjectTypeName, .ObjectID, oXmlProperty)
			If .ReturnValue Then
				updateListAfterObjectRemoving .ObjectID
			End If
		End With
	End Sub
	
	
	'==============================================================================
	' ����������� ���������� ������� UnLink
	'	[in] oEventArgs As OperationEventArgsClass
	Public Sub OnUnlink(oSender, oEventArgs)
		Dim oXmlProperty	' xml-��������
		Dim nButtonFlag		' ����� MsgBox
		Dim oXmlValueObject		' As IXMLDOMElement - ������-��������
		
		' ���� ����� ����� ������� ������������, �� ������� �������
		With oEventArgs
			If hasValue(.Prompt) Then
				' ����������, ����� �������� ���������� �������������� ������� OnKeyUp �� ������� Enter � �������
				HtmlElement.object.Enabled = False
				nButtonFlag = iif(StrComp(.OperationValues.Item("DefaultButton"), "No")=0, vbDefaultButton2, vbDefaultButton1)
				If vbNo = MsgBox(.Prompt, vbYesNo + vbInformation + nButtonFlag) Then
					HtmlElement.object.Enabled = True
					SetFocus
					Exit Sub
				End If
				HtmlElement.object.Enabled = True
			End If
		End With
		
		' ����������: RemoveRelation �� ���������� ��������� ����, ������� ����� ������������� ��������� ������ �� XmlProperty
		Set oXmlProperty = XmlProperty
		' ������� ������ ��������
		Set oXmlValueObject = oXmlProperty.selectSingleNode("*[@oid='" & oEventArgs.ObjectID &"']")
		
		If m_oPropertyEditorBase.DoUnlinkImplementation( oXmlProperty, oXmlValueObject ) Then
			updateListAfterObjectRemoving oEventArgs.ObjectID
		End If
	End Sub


	'==========================================================================
	' ���������� ������ ����� �������� ������� �� ����
	'	[in] sObjectID - ������������� ���������� ������� (�� �� ������������� ��������� ������)
	Private Sub updateListAfterObjectRemoving(sObjectID)	
		Dim oRow		' ������ CROC.IXListRow, ��������������� ��������� ������
		Dim oRows		' CROC.IXListRows
		Dim nRowIndex	' ������ ��������� ������
		Dim nRowPos		' ������� ��������� ������
		Dim nCount		' ���������� �����, ����� ��������

		Set oRows = m_oPropertyEditorBase.HtmlElement.Rows
		Set oRow = oRows.FindRowByID(sObjectID)
		
		If oRow Is Nothing Then 
			SetData
		Else
			nRowIndex = oRow.Index
			nRowPos = oRows.Idx2Pos(nRowIndex)
			' ����������� ��������� �������, ����� �� ��������������� ������� onSelChange ��� �������� ������.
			' ��� �� ����, �.�. ����� �� ������� ��������� ��������� ������. 
			' ������ ����, ���� ��� �� �������, �� ����� stack overflow, ���� ���� "���������" � ������
			m_oPropertyEditorBase.HtmlElement.LockEvents = True
			oRows.Remove nRowIndex
			m_oPropertyEditorBase.HtmlElement.LockEvents = False
			nCount = oRows.Count
			If nRowPos = nCount And nCount > 0 Then
				' ������� ��������� ������ - ������� �� ����������, ���� ��� ����
				oRows.SelectedPosition = nRowPos - 1
			ElseIf nRowPos > 0 Then
				' ���� ��������� ��������� ������ ���� � ������ �� ������, �� �������� ����� �� ������ ����� ���
				oRows.SelectedPosition  = nRowPos
			ElseIf nCount > 0 Then
				' �����, ���� ���� ������ � ������ �� ����, �� �������� ����� �� ������ ������
				oRows.SelectedPosition = 0
			Else
				' ���� ������� ��������� ������ - ���� �������� ���� 
				' (�.�. SelectedPosition, �� OnSelChange �� ���������, ������� ������� ��� ����)
				m_oMenuHolder.UpdateMenuState True
				' ����������� ������� ����������� ���� (SelLost)
				fireEventAboutSelChanging nRowIndex, -1
			End If
		End If
		SetFocus
	End Sub
	
	
	'==========================================================================
	' ����������� (��������� �������) ������� � ������ (�������)
	'	[in] bShiftDirection - ����������� ��������: True - �����, False - ����
	Sub DoItemShift(bShiftDirection)
		Dim oProp				' xml-��������
		Dim nSelected			' ������ ��������� ������
		Dim nRow1, nRow2		' ������� �������������� ���������
		Dim sID1,sID2			' �������������� �������������� ���������
		Dim oItem1, oItem2		' �������������� �������� (XMLDOMElement)
		Dim nOrder				' ���� ��� ����������
		
		Set oProp = XmlProperty
		With HtmlElement.Rows
			' ��������� ���������� �� ������� � ��������
			HtmlElement.Columns.GetColumn(0).Order = CORDER_ASC
			nSelected = .Selected
			If nSelected < 0 Then Exit Sub
			' �������� � ����������� �� ����������� ������ � 
			' ��������� �������� ���������
			If bShiftDirection Then
				nRow1 =	 nSelected
				nRow2 =	 .idx2pos(nRow1) - 1
				If nRow2 < 0 Then Exit Sub
				nRow2 = .pos2idx( nRow2) 
			Else
				nRow2 = nSelected
				nRow1 =	.idx2pos(nRow2) + 1
				If nRow1 >= .Count Then Exit Sub
				nRow1 = .pos2idx( nRow1) 
			End If
			
			' ��������� ���������������
			sID1 = .GetRow(nRow1).ID
			sID2 = .GetRow(nRow2).ID
			
			' �������� �������������� �������
			Set oItem1 = oProp.selectSingleNode("*[@oid='" & sID1 & "']")
			Set oItem2 = oProp.selectSingleNode("*[@oid='" & sID2 & "']")
		
			' ������������ �������� � XML-��������
			oProp.insertBefore oItem1, oItem2 
		
			' ������������ ������ ������ ��������� ����������� ����������� �������� ����
			nOrder = .GetRow(nRow1).GetField(0).value
			.GetRow(nRow1).GetField(0).value = .GetRow(nRow2).GetField(0 ).value
			.GetRow(nRow2).GetField(0).value = nOrder
			' ������� ��-�� ��� ����������, �.�. ��������� �������
			m_oPropertyEditorBase.ObjectEditor.SetXmlPropertyDirty oProp
		End With	
	End Sub
	
	
	'==========================================================================
	' �������� ������ � ������, ��������������� ������� � �������� ���������������
	' ��������: ����� ������ �������� � ���������� ����
	'	[in] sObjectID - ������������� ����������� �������
	Public Sub SelectRowForObject(sObjectID)
		Dim oRow		' ������ CROC.IXListRow, ��������������� ��������� ������
		Dim oRows		' CROC.IXListRows
		
		Set oRows = m_oPropertyEditorBase.HtmlElement.Rows
		Set oRow = oRows.FindRowByID( sObjectID )
		If Not oRow Is Nothing Then
			oRows.Selected = oRow.Index
		End If
	End Sub
End Class


'==============================================================================
' �������������� ������������� XListView-������ �� ��������� ����������
'	[in] oListView As XListView 	- ������� ������ (CROC.XListView)
'	[in] oInterfaceMD As XMLDOMELement - ���������� ������ (���� i:elements-list ��� i:objects-list)
'	[in] sCacheKey As String 		- ���� � ��������������� �������� ������� �� ���������� ����������
'	[in] bCreateColumns as Boolean 	- True - ��������� ������� ������, ����� �� ��������
Function InitXListViewInterface( oListView, oInterfaceMD, sCacheKey, bCreateColumns )
	Dim oColumnsFromMetadata	' As XMLDOMNodeList - ������ ������� �� ����������
	Dim oColumnFromMetadata		' As XMLDOMElement - ���������� ����� ������� - ���� i:column
	Dim oXmlColumns				' As XMLDOMElement - ���� CS xml'�� � ������������ �������
	Dim vVal
	Dim i
	Dim oCachedColumns			' As XMLDOMElement - �������������� �������� ������� (������� CS)
	Dim oCachedColumn			' As XMLDOMElement - �������������� �������� ������� (������� C)
	Dim nWidth
	Dim bShowIcons				' As Boolean - ������� ������ ������
	
	InitXListViewInterface = False
	' ������� ����������
	If Nothing Is oInterfaceMD Then Exit Function
	' ������� ������ ������� �� ����������
	Set oColumnsFromMetadata = oInterfaceMD.selectNodes("i:column")
	' ���� ������� �� ������, �������
	If 0 = oColumnsFromMetadata.length Then Exit Function
	' ������� �������� ������� �� ������
	Set oCachedColumns = Nothing
	Set oCachedColumn = Nothing
	If HasValue(sCacheKey) Then
		X_GetViewStateCache sCacheKey, oCachedColumns
		If 0 <> StrComp( TypeName(oCachedColumns), "IXMLDOMElement", vbTextCompare) Then
			Set oCachedColumns = Nothing
		End If
	End If
	
	' ���� �����, ��������� ����� ������� �����
	oListView.LineNumbers = IsNull( oInterfaceMD.getAttribute("off-rownumbers"))
	
	' ������������� �������
	If bCreateColumns Then
		' �������� XML �������� ���������� ����������� �������� � ������� CROC.XListView
		With XService.XmlGetDocument
			Set oXmlColumns = .createElement("CS")
			i = 0
			
			' ������� ��������� �������
			With oXmlColumns.appendChild(.createElement("C"))
				.text = "X_ORDER_990D331EBEAD454EAC32DCF76E06167A"
				.setAttribute "name", "X_ORDER_990D331EBEAD454EAC32DCF76E06167A"
				.setAttribute "hidden", 1
				.setAttribute "vt", "i4"
			End With
			
			' ����������� ������� �� ����������
			For Each oColumnFromMetadata In oColumnsFromMetadata
				With oXmlColumns.appendChild(.createElement("C"))
					.text =	vbNullString & oColumnFromMetadata.getAttribute("t")
					
					vVal = oColumnFromMetadata.getAttribute("n")
					If IsNull(vVal) Then vVal = "NONAME__" & i
					.setAttribute "name", vVal
					If Not oCachedColumns Is Nothing Then
						Set oCachedColumn = oCachedColumns.selectSingleNode("C[@name='" & vVal & "']")
					End If
					nWidth = oColumnFromMetadata.getAttribute("width") 
					If Not oCachedColumn Is Nothing Then
						vVal = oCachedColumn.getAttribute("width")
						If Not IsNull(vVal) Then _
							nWidth = vVal
						vVal = oCachedColumn.getAttribute("order")
						If Not IsNull(vVal) Then _
							.setAttribute "order", vVal
					End If
					nWidth = SafeCLng(nWidth)
					If nWidth > 0 Then
						.setAttribute "width", nWidth
					Else
						.setAttribute "hidden", 1
					End If
					If Not oCachedColumn Is Nothing Then
						vVal = oCachedColumn.getAttribute("display-index")
						If Not IsNull(vVal) Then _
							.setAttribute "display-index", vVal
					End If					
						
					vVal = oColumnFromMetadata.getAttribute("align")  	
					If Not IsNull(vVal) Then .setAttribute "align", vVal
					
					vVal = oColumnFromMetadata.getAttribute("vt")  	
					' ������������� ��� �������� � XDR-��� xml
					If Not IsNull(vVal) Then 
						Select Case vVal
							Case "fixed":	vVal = "fixed.14.4"
							Case "time":	vVal = "time.tz"
							Case "dateTime":vVal = "dateTime.tz"
							Case "smallBin":vVal = "bin.base64"
						End Select
						.setAttribute "vt", vVal
					End If
					
					vVal = oColumnFromMetadata.getAttribute("order-by")  	
					If Not IsNull(vVal) Then .setAttribute "order-by", vVal
				End With
				i = i + 1
			Next
			With .appendChild(.createElement("LIST"))
				.appendChild oXmlColumns
				Set oXmlColumns = .ownerDocument
				.appendChild oXmlColumns.createElement("RS") 
			End With
		End With
		' ����������������� ������� ������ ��������� �� XML-�
		oListView.XmlFillList oXmlColumns, -1, True
		Set oXmlColumns = Nothing
	Else
	    ' ����� ��� �������, ����������� � �������
	    If Not Nothing Is oCachedColumns Then
		    If Not Nothing Is oCachedColumns.selectSingleNode("C") Then
			    With XService.XmlGetDocument
				    .appendChild .createElement("LIST")
				    .documentElement.appendChild oCachedColumns
				    .documentElement.appendChild .createElement("RS")
			    End With
			    oListView.XMLFillList oCachedColumns.ownerDocument, -1, True
		    End If
		End If 
	End If
	
	' �������� ����� ������, ���� ���� �� ���������
	If IsNull( oInterfaceMD.getAttribute("off-icons") ) Then
		' ������ ���������� ���� ���� ����� icon-selector, ���� ���� ��� ���� ��������-�������� ���� ��� icons (�.�. ������ ���� ������ �� ���������)
		' ��������� ������������ ���� ������� �� ���������� PE: elements-list ������ � �������� (ds:prop), � �������� ������������ ���� � �������� ot;
		' objects-list ������ ��������������� � ������ ���
		bShowIcons = False
		If Not oInterfaceMD.selectSingleNode("i:icon-selector") Is Nothing Then
			bShowIcons = True
		Else
			If oInterfaceMD.baseName = "elements-list" Then
				If Not X_GetTypeMD(oInterfaceMD.parentNode.getAttribute("ot")).selectSingleNode("i:icons") Is Nothing Then
					bShowIcons = True
				End If
			ElseIf oInterfaceMD.baseName = "objects-list" Then
				If Not oInterfaceMD.parentNode.selectSingleNode("i:icons") Is Nothing Then
					bShowIcons = True
				End If
			End If
		End If
		If bShowIcons Then
			oListView.ShowIcons = True
			oListView.XImageList.IconTemplate = "x-get-icon.aspx?OT={T}&SL={S}&BIN=1"
		End If
	End If
	' ��� ������������� ������� ����������� �����
	If IsNull(oInterfaceMD.getAttribute("off-gridlines")) Then oListView.gridLines = True
	
	InitXListViewInterface = True
End Function

'==============================================================================
' ��������� ������ �� ��������� ������������ � ������ ��������
'	[in] oListView As IXListView
'	[in] oPropertyEditorBase As IPropertyEditor
'	[in] oXmlProperty As IXMLDOMElement - xml-��������
'	[in] oInterfaceMD As IXMLDOMElement - ���� � �� � ��������� ������ (i:element-list ��� i:list-selector)
Sub FillXListView(oListView, oPropertyEditorBase, oXmlProperty, oInterfaceMD)
	FillXListViewEx oListView, oPropertyEditorBase, oXmlProperty, oInterfaceMD,  X_GetChildValueDef( oInterfaceMD, "i:hide-if", Null)
End Sub


'==============================================================================
' ��������� ������ �� ��������� ������������ � ������ ��������
'	[in] oListView As IXListView
'	[in] oPropertyEditorBase As IPropertyEditor
'	[in] oXmlProperty As IXMLDOMElement - xml-��������
'	[in] oInterfaceMD As IXMLDOMElement - ���� � �� � ��������� ������ (i:element-list ��� i:list-selector)
'	[in] vHideIf  As String - ��������� hide-if ��� ����������� �������� ������
Sub FillXListViewEx(oListView, oPropertyEditorBase, oXmlProperty, oInterfaceMD, ByVal vHideIf)
	Dim bOrderedHard			' ������� �������������� �������� (������/������������� ����)
	
	bOrderedHard = oPropertyEditorBase.PropertyMD.getAttribute("cp") = "array" Or Not IsNull(oPropertyEditorBase.PropertyMD.getAttribute("order-by"))
	FillXListViewEx2 oListView, oPropertyEditorBase, oXmlProperty, oInterfaceMD, vHideIf, bOrderedHard
End Sub


'==============================================================================
' ��������� ������ �� ��������� ������������ � ������ ��������
' ����������: ������� ���� ���������� �������������
'	[in] oListView As IXListView
'	[in] oPropertyEditorBase As IPropertyEditor
'	[in] oXmlProperty As IXMLDOMElement - xml-��������
'	[in] oInterfaceMD As IXMLDOMElement - ���� � �� � ��������� ������ (i:element-list ��� i:list-selector)
'	[in] vHideIf  As String - ��������� hide-if ��� ����������� �������� ������
'	[in] bOrderedHard - ������� �������������� �������� (������/������������� ����)
Sub FillXListViewEx2(oListView, oPropertyEditorBase, oXmlProperty, oInterfaceMD, ByVal vHideIf, bOrderedHard)
	Dim oObjectEditor			' As oObjectEditor
	Dim oObjects                ' As IXMLDOMNodeList
	
    Set oObjectEditor = oPropertyEditorBase.ObjectEditor
    Set oObjects = oXmlProperty.selectNodes( "*[(@oid)]" )
    
    FillXListViewEx3 oListView, oObjectEditor, oObjects, oInterfaceMD, vHideIf, bOrderedHard
End Sub


'==============================================================================
' ��������� ������ �� ��������� ������������ � ��������� ��������
' ����������: ������� ���� ���������� �������������
'	[in] oListView As IXListView
'	[in] oObjectEditor As oObjectEditor
'	[in] oObjects As IXMLDOMNodeList - ��������� ������������ ��������
'	[in] oInterfaceMD As IXMLDOMElement - ���� � �� � ��������� ������ (i:element-list ��� i:list-selector)
'	[in] vHideIf  As String - ��������� hide-if ��� ����������� �������� ������
'	[in] bOrderedHard - ������� �������������� �������� (������/������������� ����)
Sub FillXListViewEx3(oListView, oObjectEditor, oObjects, oInterfaceMD, ByVal vHideIf, bOrderedHard)
	Dim oColumnsFromMetadata	' As IXMLDOMNodeList - ������ ������� �� ����������
	Dim oColumnFromMetadata		' As IXMLDOMElement - ������� �� ���������� (i:column)
	Dim nUpper					' As Interger - ������ ��������� �������
	Dim oItem
	Dim aStatements				' As Array - ������ ��������� ��� ���������� �������� �������
	Dim sVisibleObjectIDList	' As String - ������ ��������������� ����� �������, ������������ � ������
	Dim oXRows					' As Croc.IXListViewRows - ��������� ����� ������
	Dim vIconSelector			' As String - �������� ������
	Dim oXImageList				' As Croc.XImageList
	Dim aRowData				' As Array - ������ ��������� �� ���������� ����� ������
	Dim oXRow
	Dim bVisible				' As Boolean - ������� ����, ��� ������ ������������ � ������
	Dim vVal
	Dim nObjectIndex			' As Integer - ������� ������� � ��������
	Dim i, j
	Dim bOrderedSoft			' ������� ���������������� ��������, �� � ���������� ����������� ������ (� ������� �������� i:order-by)
	
	Set oXRows = oListView.Rows
	
	If Not HasValue(vHideIf) Then vHideIf = Null

	' ������� ������ ������� �� ����������
	Set oColumnsFromMetadata = oInterfaceMD.selectNodes("i:column")
	nUpper = oColumnsFromMetadata.Length - 1
	' ������������ ������ ��� ����������� ���������
	Redim aStatements( nUpper)
	' �������� ���������
	i = 0
	For Each oColumnFromMetadata  In oColumnsFromMetadata
		aStatements(i) = oColumnFromMetadata.nodeTypedValue
		i = i + 1
	Next
	vIconSelector = X_GetChildValueDef( oInterfaceMD, "i:icon-selector", Null )

	' ������ ������������ ��������
	
	' ���������� ������
	' ������� ����� ��� ������ ������	
	ReDim aRowData(nUpper+1) 

	bOrderedSoft = Not oInterfaceMD.selectSingleNode("i:order-by") Is Nothing
	' ���� ��-�� �������������, �� ������� ���������� �� �������� ����
	If bOrderedHard Then
		oListView.Columns.GetColumn(0).Order = CORDER_ASC
	End If
	nObjectIndex = 0
	' ��������� ������������� � ������ ������, ���������� �����������
	For Each oItem In oObjects
		If IsNull(vHideIf) Then
			bVisible = True 
		Else
			' ���� ������ ��������� hide-if, �� �������� ���
			bVisible = (True <> oObjectEditor.ExecuteStatement( oItem,vHideIf)) 
		End If 
		If bVisible Then
			sVisibleObjectIDList = sVisibleObjectIDList & " " & oItem.GetAttribute("oid")
			aRowData(0) = nObjectIndex
			' �������� �� ���� ����������, ��������� ��, � ��������� ������ ������
			For i=0 To nUpper
				' �������� ��������
				vVal = oObjectEditor.ExecuteStatement( oItem, aStatements(i) )
				' ...������ � ���� ������
				If IsEmpty(vVal) Then vVal = Null  
				aRowData(i+1) = vVal
			Next
			' ������ � ������ ������ � ��������������� �������� �������
			Set oXRow  = oXRows.FindRowByID(oItem.GetAttribute("oid"))
			If Nothing Is oXRow Then
				' ����� ������ ���, ���� ��������:
				' ��������� ������ � ������
				If bOrderedSoft Then
					' ���� ������ � order-by, �� ������ ���� �������� ��� �������� ����������� � �������� ������� � ��������.
					' ��� ���� ��� ����, ����� ��� ������ ���������� ������ ���� � ��������� ������� (�.�. � ������� �� ���������� � ��-��).
					' ��� �������/������������� ����� ������ �� �����, �.�. ��� ������ ������� ���������� �� 0-�� �������, 
					' � ������� �� ������ ������ ������� � ��������.
					Set oXRow = oXRows.Insert( nObjectIndex, aRowData, oItem.GetAttribute("oid") )
				Else
					Set oXRow = oXRows.Insert(-1, aRowData, oItem.GetAttribute("oid") )
				End If
			Else
				' ������ ��� ����
				' ��� �������������� �������� ��������� ���� �������, �� �������� ����������� ������
				If bOrderedHard Then
					oXRow.GetField(0).value = nObjectIndex
				End If
				For j=1 To UBound(aRowData)
					oXRow.GetField(j).value = aRowData(j)
				Next
				If bOrderedSoft Then
					If oXRow.Index <> nObjectIndex Then
						' ������ ������ �� ����� ������� ������� � ��������
						oXRows.Remove oXRow.Index
						Set oXRow = oXRows.Insert( nObjectIndex, aRowData, oItem.GetAttribute("oid") )
					End If
				End If
			End If
			' �������� �������� ������
			If Not IsNull(vIconSelector) Then
				vVal = ToString( oObjectEditor.ExecuteStatement( oItem, vIconSelector ) )
				oXRow.IconURL = oListView.XImageList.MakeIconUrl( oItem.nodeName, 0, vVal ) 
			ElseIf oListView.ShowIcons Then
				oXRow.IconURL = oListView.XImageList.MakeIconUrl( oItem.nodeName, "", "")
			End If
			nObjectIndex = nObjectIndex + 1
		End if
	Next
	' ��������� ������ �� �������� � ������ ������������
	If IsEmpty(sVisibleObjectIDList) Then
		oXRows.RemoveAll		 
	Else
		' �� ���� ������� � ������: 
		For i=oXRows.Count-1 To 0 Step -1
			' ���� �������������� ������� ������ ��� � ������ ������������ ��������, �� ������ ������
			If 0=InStr( sVisibleObjectIDList,  oXRows.GetRow(i).ID) Then
				oXRows.Remove i
			End If 
		Next
	End If
End Sub


'==========================================================================
' ��������� ������ � �������� �� ��������� ������������ � ��� vbs-���������
'	[in] ObjectEditor - ��������
'	[in] oXmlPropert As IXMLDOMElement - xml-��������
'	[in] sOrderBy As String  - ��������� (ObjectPath)
'	[in] bAsc As Boolean - ���� True ��������� �� �����������, ����� �� ��������.
Public Sub SortProperty( ObjectEditor, oXmlProperty, sOrderBy, bAsc )
	Dim oNodes				' ��������� ��������-�������� � �������� oXmlProperty
	Dim nCount				' ���������� �������� � ��������� oNodes
	Dim sCurItemOrderBy		' ����������� ��������� order-by �������� �������
	Dim sPrevItemOrderBy	' ����������� ��������� order-by ����������� �������
	Dim bFound				' ������� ���������� �������, ����� ������� ��������� �������
	Dim i, j

	If Len("" & sOrderBy) = 0 Then Exit Sub
	Set oNodes = oXmlProperty.ChildNodes
	nCount = oNodes.length
	For i=1 To nCount-1
		sCurItemOrderBy = ObjectEditor.ExecuteStatement( oNodes.item(i), sOrderBy)
		For j=0 To i-1
			sPrevItemOrderBy = ObjectEditor.ExecuteStatement( oNodes.item(j), sOrderBy)
			bFound = False
			If bAsc Then
				' ��������� �� �����������
				If sCurItemOrderBy < sPrevItemOrderBy Then bFound = True
			Else
				' ��������� �� ��������
				If sCurItemOrderBy > sPrevItemOrderBy Then bFound = True
			End If
			If bFound Then
				oXmlProperty.insertBefore oNodes.item(i), oNodes.item(j)
				Exit For
			End If
		Next
	Next
End Sub


'===============================================================================
'@@ListViewSelChangeEventArgsClass
'<GROUP !!CLASSES_x-pe-objects><TITLE ListViewSelChangeEventArgsClass>
':����������:	����� ���������� ������� SelChanged, SelLost, ����������� ActiveX-�������� XListView OnSelChange
'@@!!MEMBERTYPE_Methods_ListViewSelChangeEventArgsClass
'<GROUP ListViewSelChangeEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_ListViewSelChangeEventArgsClass
'<GROUP ListViewSelChangeEventArgsClass><TITLE ��������>
Class ListViewSelChangeEventArgsClass

	'@@ListViewSelChangeEventArgsClass.UnselectedRowIndex
	'<GROUP !!MEMBERTYPE_Properties_ListViewSelChangeEventArgsClass><TITLE UnselectedRowIndex>
	':����������:	������ ������ (�� 0), ������� ���� ���������� �� ��������� �������� ������
	':���������:	Public UnselectedRowIndex [As Integer]
	Public UnselectedRowIndex
	
	'@@ListViewSelChangeEventArgsClass.SelectedRowIndex
	'<GROUP !!MEMBERTYPE_Properties_ListViewSelChangeEventArgsClass><TITLE SelectedRowIndex>
	':����������:	������ ������ (�� 0), ������� ����� ����������
	':���������:	Public SelectedRowIndex [As Integer]
	Public SelectedRowIndex
	
	'@@EventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_EventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel				
	
	'@@EventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_EventArgsClass><TITLE ReturnValue>
	':����������:	������, ������������ ������������ �������.
	':���������:	Public ReturnValue [As Variant]
	Public ReturnValue
	
	'@@EventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_EventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As EventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class