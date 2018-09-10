Option Explicit

'==============================================================================
' ����� PE ������������ �������� ��� ����������� ������ ����� �����������
' �������:
'	BeforeShowMenu - ��� ������� ������ "��������", ���� ������ ������������ ���� ����� ������� MenuClass
'������� DoCreate ��������� �������:
'	BeforeCreate,Create,AfterCreate - ��.XPropertyEditorObjectBaseClass
'������� DoEdit ��������� �������:
'	BeforeEdit,Edit,AfterEdit - ��.XPropertyEditorObjectBaseClass
'������� DoMarkDelete ��������� �������:
'	BeforeMarkDelete,MarkDelete,AfterMarkDelete - ��.XPropertyEditorObjectBaseClass
'Accel - ������� ���������� ������ � ������ (���� ����������� ����������)
Class PEIncidentLinksClass
	Private m_oMenu						' As MenuClass	- ���� ��������
	Private EVENTS						' As String		- ������ ������� ��������
	Private m_sViewStateCacheFileName	' As String - ������������ ����� � �������������� ��������������
	Private m_oPropertyEditorMD
	Private m_sOrderBy					' As String		- ��������� order-by ��� ���������� �������� � ��������
	Private m_bOrderByAsc				' As Boolean	- True - ����������� �� �����������, False - �� ��������
	
	Public ParentPage			' As EditorPageClass	- ������ �� ��������� ��������
	Public ObjectEditor			' As ObjectEditorClass	- ������ �� ��������� ��������
	Public HtmlElement			' As IHtmlElement	- ������ �� ������� Html-�������
	Public EventEngine			' As EventEngineClass
	Public XmlPropertyXPath		' As String - XPath - ������ ��� ��������� �������� � Pool'e
	Public ObjectType			' As String - ������������ ���� ������� ��������� ��������
	Public ObjectID				' As String - ������������� ������� ��������� ��������
	Public PropertyName			' As String - ������������ ��������
	Public ValueObjectTypeName	' As String - ������������ ���� ������� �������� ��������
	Public SelectorMetaname		' As String	- ������� ���������
	Public SelectorType			' As String	- ��� ��������� ��� ������: list ��� tree
	Public PropertyDescription	' As String
	
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "BeforeShowMenu," & _
			"BeforeCreate,AfterCreate," & _
			"BeforeEdit,AfterEdit," & _
			"BeforeMarkDelete,AfterMarkDelete," & _
			"Accel"
	End Sub
	

	'==========================================================================
	' IPropertyEdior: �������������
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim oMenuMD				' As IXMLDOMElement - ���������� ���� (i:menu)
		Dim oDoc
		
		Set EventEngine 	= X_CreateEventEngine
		Set ParentPage  	= oEditorPage
		Set ObjectEditor	= oEditorPage.ObjectEditor
		ObjectType			= oXmlProperty.parentNode.tagName
		ObjectID			= oXmlProperty.parentNode.getAttribute("oid")
		PropertyName		= oXmlProperty.tagName
		XmlPropertyXPath	= ObjectType & "[@oid='" & ObjectID & "']/" & PropertyName
		ValueObjectTypeName = "IncidentLink"
		Set HtmlElement		= oHtmlElement
		PropertyDescription = oHtmlElement.GetAttribute("X_DESCR")
		' ����������� �������
		If Len("" & EVENTS) > 0 Then
			EventEngine.InitHandlers EVENTS, "usr_" & ObjectType & "_" & PropertyName & "_On"
		End If
		EventEngine.AddHandlerForEventWeakly "Create", Me, "OnCreate"
		EventEngine.AddHandlerForEventWeakly "Edit", Me, "OnEdit"
		EventEngine.AddHandlerForEventWeakly "MarkDelete", Me, "OnMarkDelete"
		EventEngine.AddHandlerForEventWeakly "Accel", Me, "OnAccel"
		
		' ��������� ��� ��������� � ��� ������/������ �� ��������� ���������� �� xsl � ����������
		SelectorType = "list"
		SelectorMetaname = Null
		If hasValue( HtmlElement.getAttribute("ListSelectorMetaname") ) Then
			SelectorType = "list"
			SelectorMetaname = HtmlElement.getAttribute("ListSelectorMetaname")
		ElseIf hasValue( HtmlElement.getAttribute("TreeSelectorMetaname") ) Then
			SelectorType = "tree"
			SelectorMetaname = HtmlElement.getAttribute("TreeSelectorMetaname")
		End If		
	
		Set m_oMenu = New MenuClass
		
		Set oDoc = XService.XMLGetDocument()
		'getIconSelectorForIncidentLink(item())
		oDoc.loadXml _
			"<i:elements-list xmlns:i=""http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"" off-rownumbers=""1"">" & _
			"	<i:icon-selector>iif(item.RoleA.ObjectID = """ & ObjectID & """, ""from"",""to"")</i:icon-selector>" & _
			"	<i:column width=""100"" t=""�"">IncidentLink_getNumber(pool(), item(),""" & ObjectID & """)</i:column>" & _
			"	<i:column width=""100"" t=""���������"">IncidentLink_getState(pool(), item(),""" & ObjectID & """)</i:column>" & _
			"	<i:column width=""600"" t=""������������"">IncidentLink_getName(pool(), item(),""" & ObjectID & """)</i:column>" & _
			"	<i:prop-menu>" & _
			"		<i:menu>" & _
			"			<i:menu-item action=""DoCreate"" hotkey=""VK_INS""  t=""������� ������ �� �������� ���������"">" & _
			"				<i:params><i:param n=""URLParams"">.RoleA=" & ObjectID & "</i:param>" & _
			"							<i:param n=""RealPropName"">LinksFromRoleA</i:param>" & _
			"				</i:params>" & _
			"			</i:menu-item>" & _
			"			<i:menu-item action=""DoCreate"" t=""������� ����� �������� �� ������� �� ��������"">" & _
			"				<i:params><i:param n=""ObjectType"">Incident</i:param>" & _
			"							<i:param n=""RealPropName"">LinksFromRoleA</i:param>" & _
			"				</i:params>" & _
			"			</i:menu-item>" & _
			"			<i:menu-item action=""DoCreate"" t=""������� ������ �� ������� ��������"" separator-before=""1"">" & _
			"				<i:params><i:param n=""URLParams"">.RoleB=" & ObjectID & "</i:param>" & _
			"							<i:param n=""RealPropName"">LinksFromRoleB</i:param>" & _
			"				</i:params>" & _
			"			</i:menu-item>" & _
			"			<i:menu-item action=""DoCreate"" t=""������� ����� �������� �� ������� �� �������"">" & _
			"				<i:params><i:param n=""ObjectType"">Incident</i:param>" & _
			"							<i:param n=""RealPropName"">LinksFromRoleB</i:param>" & _
			"				</i:params>" & _
			"			</i:menu-item>" & _
			"			<i:menu-item action=""DoEdit"" t=""������������� ������"" separator-before=""1""/>" & _
			"			<i:menu-item action=""DoMarkDelete"" hotkey=""VK_DEL"" t=""������� ������"" separator-after=""1""/>" & _
			"			<i:menu-item action=""DoEdit"" hotkey=""VK_ENTER,VK_DBLCLICK""  t=""������������� ��������"">" & _
			"				<i:params><i:param n=""ObjectType"">Incident</i:param></i:params>" & _
			"			</i:menu-item>" & _
			"			<i:menu-item action=""DoIncidentView"" t=""�������� ���������"" />" & _
			"		</i:menu>" & _
			"	</i:prop-menu>" & _
			"</i:elements-list>"
		XService.XmlSetSelectionNamespaces oDoc
		Set m_oPropertyEditorMD = oDoc.documentElement
		
		Dim oXmlOrderBy
		Set oXmlOrderBy = m_oPropertyEditorMD.selectSingleNode("i:order-by")
		If Not oXmlOrderBy Is Nothing Then
			m_sOrderBy = oXmlOrderBy.text
			m_bOrderByAsc = X_GetAttributeDef(oXmlOrderBy, "desc", "0") <> "1"
		End If
		
		' �������������� ����: ������� ��� ����������, ������� ����������� ����������� 
		Set oMenuMD = m_oPropertyEditorMD.selectSingleNode( "i:prop-menu/i:menu")
		If Not oMenuMD Is Nothing Then
			m_oMenu.Init oMenuMD	
			m_oMenu.AddMacrosResolver X_CreateDelegate(Me, "Internal_MenuMacrosResolver") 
			' ����� ������������������: ����� XPEObjectsElementsListClass_MenuVisibilityHandler, ����� Internal_MenuVisibilityHandler
			' ������, ��� � Internal_MenuVisibilityHandler ���������������� ��������� ������������ ������ DoEdit ��� ������ �� ����� ��������
			m_oMenu.AddVisibilityHandler X_CreateDelegate(Nothing, "XPEObjectsElementsListClass_MenuVisibilityHandler")
			m_oMenu.AddVisibilityHandler X_CreateDelegate(Me, "Internal_MenuVisibilityHandler")
			m_oMenu.AddExecutionHandler X_CreateDelegate(Me, "Internal_MenuExecutionHandler") 
		End If
		m_sViewStateCacheFileName = ObjectEditor.Signature() & "XArrayProp." + oXmlProperty.parentNode.tagName & "." & oXmlProperty.tagName & "." & m_oPropertyEditorMD.getAttribute("n")
		InitXListViewInterface HtmlElement, m_oPropertyEditorMD, m_sViewStateCacheFileName, True
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: ����� ���������� ��� ���������� �������� ���������, ����� ������������� ���� PE �� ��������
	Public Sub FillData()
		' Nothing to do...
	End Sub
	
	
	
	'==========================================================================
	' IPropertyEdior: ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = ObjectEditor.Pool.GetXmlObject(ObjectType, ObjectID, Null).SelectSingleNode(PropertyName)
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
		FillXListViewEx2 HtmlElement, Me, oXmlProperty, m_oPropertyEditorMD, HideIf, False
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
		ExtraHtmlElement("ButtonOperation").disabled = Not( bEnabled )
	End Property
	
	
	'==========================================================================
	' IPropertyEdior: ��������� ������
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function
	

	'==========================================================================
	' IPropertyEdior: ���������� IHTMLElement ������ � ���������
	Public Property Get ButtonOperation
		Set ButtonOperation = ExtraHtmlElement("ButtonOperation")
	End Property

	
	'==========================================================================
	' ���������� �������������� ������� IHTMLElement
	Private Function ExtraHtmlElement(sName)
		Set ExtraHtmlElement = ParentPage.HtmlDivElement.all( HtmlElement.id & sName)
	End Function

	
	'==========================================================================
	' IDisposable
	Public Sub Dispose
	End Sub	


	'==========================================================================
	' ���������� �������
	'	[in] sEventName - ������������ �������
	'	[in] oEventArgs - ��������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent EventEngine, sEventName, Me, oEventArgs
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
			Set Value = ObjectEditor.Pool.GetXmlObjectsByXmlNodeList( oXmlProperty.ChildNodes, Null )
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
	' ������������
	
	'==========================================================================
	' ���������� ������� ������� � ������
	Sub OnKeyUp(ByVal nKeyCode, ByVal nFlags)
		With New AccelerationEventArgsClass
			.keyCode	= nKeyCode
			.altKey		= nFlags and KF_ALTLTMASK
			.ctrlKey	= nFlags and KF_CTRLMASK
			.shiftKey	= nFlags and KF_SHIFTMASK
			FireEvent "Accel", .Self()
			Set .HtmlSource = HtmlElement
			Set .Source = Me
			' HtmlElement.CancelEventBubble = True
			If Not .Processed Then
				' ���� ������� ���������� �� ���������� - ��������� �� � ������ ��������
				ObjectEditor.OnKeyUp Me, .Self()
			End If
		End With
	End Sub


	'==========================================================================
	' ���������� �������� ����� � ������
	Sub OnDblClick(ByVal nIndex , ByVal nColumn, ByVal sID)
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
		If Not m_oMenu.Initialized Then Exit Sub
		' ������� ������� ���������� � ���� ������ - ����� ��� ��� ��� ���������� hotkey'�
		m_oMenu.ExecuteHotkey Me, oEventArgs
	End Sub


	'==========================================================================
	' ���������� ����� ������ ������� ���� 
	Public Sub OnContextMenu()
		If Not m_oMenu.Initialized Then Exit Sub
		With New MenuEventArgsClass
			Set .Menu = m_oMenu
			.ReturnValue = True
			FireEvent "BeforeShowMenu", .Self()
			If .ReturnValue <> True Then Exit Sub
			m_oMenu.ShowPopupMenu Me
		End With	
	End Sub
	
	
	'==========================================================================
	' �������� ����������� ���� ��������
	Public Sub ShowMenu
		Dim oHtmlElement	' ������ ������ "��������"
		Dim nPosX			'
		Dim nPosY			'
		With New MenuEventArgsClass
			Set .Menu = m_oMenu
			.ReturnValue = True
			FireEvent "BeforeShowMenu", .Self()
			If .ReturnValue <> True Then Exit Sub
			Set oHtmlElement = ExtraHtmlElement("ButtonOperation")
			X_GetHtmlElementScreenPos oHtmlElement, nPosX, nPosY
			'nPosX = nPosX + window.screenLeft
			'nPosY = nPosY + window.screenTop + oHtmlElement.offsetHeight
			m_oMenu.ShowPopupMenuWithPosEx Me, nPosX, nPosY, True
		End With	
	End Sub	

	
	'==========================================================================
	' ����������� ���������� ���������/�����������
	'	[in] oEventArgs As MenuEventArgsClass
	Sub Internal_MenuVisibilityHandler(oSender, oEventArgs)
		Dim oNode			' ������� menu-item
		Dim bHidden			' ������� �������� ������
		Dim oParam
		Dim sObjectID

		For Each oNode In oEventArgs.ActiveMenuItems
			If oNode.getAttribute("action") = "DoIncidentView" Then
				bHidden = Len("" & oEventArgs.Menu.Macros.Item("ObjectID")) = 0 

				If bHidden Then 
					oNode.setAttribute "hidden", "1"
				Else
					oNode.removeAttribute "hidden"
				End If
			ElseIf oNode.getAttribute("action") = "DoEdit" Then
				Set oParam = oNode.selectSingleNode("i:params/i:param[@n='ObjectType']")
				If Not oParam Is Nothing Then
					If oParam.text = "Incident" Then
						' �������������� ��������� - 
						' - ��������, ���� �� ����� (��� ��� ������, ��� ��� ������� �� ����)
						sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
						If Len("" & sObjectID) > 0 Then
							If Not IsNull(getOtherIncident(sObjectID).getAttribute("new")) Then
								oNode.setAttribute "disabled", "1"
							Else
								oNode.removeAttribute "disabled"
							End If
						End If
					End If
				End If
			End If
		Next
	End Sub


	'==========================================================================
	' ����������� �������� ������� ����
	'	[in] oEventArgs As MenuEventArgsClass
	Sub Internal_MenuMacrosResolver(oSender, oEventArgs)
		oEventArgs.Menu.Macros.Item("ObjectID") = HtmlElement.Rows.SelectedID
		If Len("" & oEventArgs.Menu.Macros.Item("ObjectType")) = 0 Then
			oEventArgs.Menu.Macros.Item("ObjectType") = ValueObjectTypeName
		End If	
	End Sub

	
	'==========================================================================
	' ����������� ���������� ������ ������ ����
	'	[in] oMenuExecuteEventArgs As MenuExecuteEventArgsClass
	Sub Internal_MenuExecutionHandler(oSender, oEventArgs)
		Dim oSourceElement		' �������� ������� �� ������ ��������
		Set oSourceElement = document.activeElement
		
		oEventArgs.Cancel = True
		Select Case oEventArgs.Action
			Case "DoCreate"
				' ������� � ������� ����������
				DoCreate m_oMenu.Macros
			Case "DoEdit"
				' ������������� � ������� ���������
				DoEdit m_oMenu.Macros
			Case "DoMarkDelete"
				' �������� ������ ��� ��������� � ������� ������ �� ���� �� ��������
				DoMarkDelete m_oMenu.Macros
			Case "DoIncidentView"
				DoOpenIncidentView oEventArgs.Menu.Macros.Item("ObjectID")
			Case Else
				oEventArgs.Cancel = False
		End Select
		If Nothing Is oSourceElement Then Exit Sub 
		On Error Resume Next
		oSourceElement.setActive
		oSourceElement.focus
		On Error GoTo 0  
	End Sub

	
	'==========================================================================
	' ���������� xml-������ ���������, � ������� ����������� �������� ������ �� �������� ���������
	'	[in] sIncidentLinkID
	Private Function getOtherIncident(sIncidentLinkID)
		Dim oIncidentLink
		Dim oOtherIncident
		' ������� ������� ������ IncidentLink
		Set oIncidentLink = ObjectEditor.Pool.GetXmlObjectByXmlElement( _
			ObjectEditor.XmlObject.selectSingleNode("LinksFromRoleA/*[@oid='" & sIncidentLinkID & "'] | LinksFromRoleB/*[@oid='" & sIncidentLinkID & "']"), Null )
		' ������� ��������������� ��������
		Set getOtherIncident = ObjectEditor.Pool.GetXmlObjectByXmlElement( oIncidentLink.selectSingleNode("RoleA/*[@oid!='" & ObjectID & "'] | RoleB/*[@oid!='" & ObjectID & "']"), Null )
	End Function


	'==========================================================================
	' ���������� ������� "DoIncidentView" - �������� ���������
	Sub DoOpenIncidentView(sIncidentLinkID)
		X_RunReport "Incident", "IncidentID=" & getOtherIncident(sIncidentLinkID).getAttribute("oid")
	End Sub

	
	'==========================================================================
	' ����������� ���������� ������� DoCreate & DoCreateAndSave
	'	[in] oValues	- ��������� ���������� �������� ����
	'	[in] bSeparateTransaction As Boolean - ������� ���������� �������� � ��������� ����������
	Public Sub DoCreate(oValues)
		With New OpenEditorEventArgsClass
			Set .OperationValues = oValues
			.Metaname = HtmlElement.GetAttribute("EditorMetanameForCreating")
			If Not hasValue(.Metaname) And oValues.Exists("Metaname") Then
				.Metaname = oValues.Item("Metaname")
			End If
			.IsSeparateTransaction = False
			If oValues.Exists("UrlParams") Then
				.UrlArguments = oValues.Item("UrlParams")
			End If
			.ReturnValue = True
			FireEvent "BeforeCreate", .Self()
			If .ReturnValue <> True Then Exit Sub
			OnCreate .Self()
			FireEvent "AfterCreate", .Self()
		End With
	End Sub


	'==========================================================================
	' ����������� ���������� ������� DoEdit & DoEditAndSave
	'	[in] oValues	- ��������� ���������� �������� ����
	'	[in] bSeparateTransaction As Boolean - ������� ���������� �������� � ��������� ����������
	Public Sub DoEdit(oValues)
		With New OpenEditorEventArgsClass
			Set .OperationValues = oValues
			.Metaname = HtmlElement.GetAttribute("EditorMetanameForEditing")
			If Not hasValue(.Metaname) And oValues.Exists("Metaname") Then
				.Metaname = oValues.Item("Metaname")
			End If
			.IsSeparateTransaction = False
			If oValues.Exists("UrlParams") Then
				.UrlArguments = oValues.Item("UrlParams")
			End If
			.ReturnValue = True
			.ObjectID = oValues.Item("ObjectID")
			FireEvent "BeforeEdit", .Self()
			If .ReturnValue <> True Then Exit Sub
			OnEdit .Self()
			FireEvent "AfterEdit", .Self()
		End With
	End Sub


	'==============================================================================
	' ����������� ���������� ������� DoMarkDelete
	'	[in] oValues	- ��������� ���������� �������� ����
	Public Sub DoMarkDelete( oValues )
		With New OperationEventArgsClass
			Set .OperationValues = oValues
			.ReturnValue = True
			.ObjectID = oValues.Item("ObjectID")
			.Prompt = "�� ������������� ������ ������� ������?"
			FireEvent "BeforeMarkDelete", .Self()
			If .ReturnValue <> True Then Exit Sub
			OnMarkDelete .Self()
			FireEvent "AfterMarkDelete", .Self()
		End With	
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
	Public Sub OnCreate(oEventArgs)
		Dim oXmlProperty		' xml-��������
		Dim oNewObject			' ����� ������-��������
		Dim oNewObjectInProp	' �������� �������-�������� � ��������
		Dim oRealProp
		Dim oTempObject         '��������� ������ ���� MultiChoiceIncident - ������������ ������������� ��� ����������� ������ ���������� ����������,
		                        'c �������� ����� ������ �������

		With oEventArgs
			If oEventArgs.OperationValues.Item("ObjectType") = "Incident" Then
				Dim sIncidentID
				sIncidentID = X_OpenObjectEditor( "Incident", Null, "WizardWithSelectFolder", "")
				If hasValue(sIncidentID) Then
					Set oXmlProperty = XmlProperty
					' �������� ����� ������ � �������� ��� � ���
					Set oNewObject = ObjectEditor.Pool.CreateXmlObjectInPool(ValueObjectTypeName)
					' ������� ���� ����� ������-�������� � ����������� ��������
					Set oNewObjectInProp = oXmlProperty.appendChild( X_CreateStubFromXmlObject(oNewObject) )
					If IsOrdered Then
						' ���� �������� ����������� - ������� ���������� � �������� � ������ ����������
						OrderObjectInPropEx oXmlProperty, oNewObjectInProp
					End If
					' � �������� ��������, � ������� �� ������� ������, ������� ������ �� ��������� ������ IncidentLink
					' ��� ����� ���������������� �������� �������� (RoleA ��� RoleB)
					ObjectEditor.Pool.AddRelation ObjectEditor.XmlObject, .OperationValues.Item("RealPropName"), X_CreateStubFromXmlObject(oNewObject)
					' �������� �������� � ��������� ������ IncidentLink ������ �� ��������� ��������
					' ������� ��������� �������� �� RoleA � ROleB - � ���� � ������� (������ ����� ������ ������� �� ������� ��������)
					Set oRealProp = oNewObject.selectSingleNode("RoleA[not(*)] | RoleB[not(*)]")
					ObjectEditor.Pool.AddRelation oNewObject, oRealProp, X_CreateObjectStub("Incident", sIncidentID) 
					' ������� ������������� PE
					SetDataEx oXmlProperty
				End If
			Else
			    Dim sUrlParams '������ �� ��������� ��������� RealPropName, ������� ��������� ��������  LinksFromRoleA ���� LinksFromRoleB
			    Dim resultSelection '������ ������,������� �������� �������� ��������� ����(���������)
			    Dim oNode ' ��������� ������� � ������ ����������
			     
				' ������ �������������� ����������
				ObjectEditor.Pool.BeginTransaction True
				' ������� �������� �������� �������
				Set oRealProp = ObjectEditor.XmlObject.selectSingleNode( .OperationValues.Item("RealPropName") )
				' �����: ������ oXmlProperty �������� ����� ������ BeginTransaction, ������� �� ����� ������������ � ����� CommitTransaction
				Set oXmlProperty = XmlProperty
				
				' ��������  ��������� ������ ���� MultiChoiceIncident � �������� ��� � ���
				'���� ����� ��������� ������ ��� ����,�� �������� ��� �� �������
				 Set oTempObject = ObjectEditor.Pool.Xml.selectSingleNode("MultiChoiceIncident")
				 If oTempObject Is Nothing Then
				    Set oTempObject = ObjectEditor.Pool.CreateXmlObjectInPool("MultiChoiceIncident")
			     End If
			   				
										
                sUrlParams= "RealPropName=" & .OperationValues.Item("RealPropName")
				
				'������� �������� ���������� �������, ����� ����� ���� ������� ��������� (��.�������� Incidents ����.�������)	
				'O�������� �������� � ��������� EnlistInCurrentTransaction=True, �.�. ���� �������� �� ����� ��������� ����� ����������			
				resultSelection =ObjectEditor.OpenEditor(oTempObject, Null, Null, .Metaname, True, oRealProp, Not .IsSeparateTransaction, True,sUrlParams)
				
				If  IsEmpty(resultSelection)  Then
					' ������ ������ - ������� ����������
					ObjectEditor.Pool.RollbackTransaction
				Else
					' ������� ������� ��������� - �������� ��� ������� ���������� ���-�� ������ IncidentLink � ��������� ��� ������ ������ � ������� 
					'���� ��������										
					For Each oNode In resultSelection(0).ChildNodes
                       CreateIncidentLink oNode.getAttribute("id"),.OperationValues.Item("RealPropName")
                    Next
					
					'��������� ����������
					ObjectEditor.Pool.CommitTransaction
					' ������� ������������� PE
					SetDataEx oXmlProperty
				End If		
			End If	
		End With
	End Sub
	
    '==========================================================================
    '��������������� ���������, ������� ������� ������  IncidentLink � ������� ���� �������� � ������������� ����������� ������ ����� ���������.
    '	[in] sIncidentID    - ������������� ���������, �� �������/�� �������� ������ ������ ������������ �������� ��-�� 
    '	[in] sRealPropName  - ������������ �������� � ���� Incident, ���� ����� �������� ������ �� ����������� ������ ���� IncidentLink
    ' ��� ���� LinksFromRoleA ��� LinksFromRoleB                            
     
    Public Sub CreateIncidentLink(sIncidentID,sRealPropName)
        Dim oXmlProperty		' xml-��������
		Dim oNewObject			' ����� ������-Incident
		Dim oNewObjectInProp	' �������� �������-�������� � ��������
		Dim oRealProp           '�������� RoleA ��� RoleB � ����������� ������� IncidentLink
		
		Set oXmlProperty = XmlProperty '����������� ��������
		' �������� ����� ������  IncidentLink � �������� ��� � ���
		Set oNewObject = ObjectEditor.Pool.CreateXmlObjectInPool(ValueObjectTypeName)
		' ������� ���� ����� ������-�������� � ����������� ��������
		Set oNewObjectInProp = oXmlProperty.appendChild( X_CreateStubFromXmlObject(oNewObject) )
		If IsOrdered Then
					' ���� �������� ����������� - ������� ���������� � �������� � ������ ����������
					OrderObjectInPropEx oXmlProperty, oNewObjectInProp
		End If
		' � �������� ��������, � ������� �� ������� ������, ������� ������ �� ��������� ������ IncidentLink
		' ��� ����� ���������������� �������� �������� (RoleA ��� RoleB)
		ObjectEditor.Pool.AddRelation ObjectEditor.XmlObject, sRealPropName, X_CreateStubFromXmlObject(oNewObject)
		' �������� �������� � ��������� ������ IncidentLink ������ �� ��������� ��������
		' ������� ��������� �������� �� RoleA � ROleB - � ���� � ������� (������ ����� ������ ������� �� ������� ��������)
		Set oRealProp = oNewObject.selectSingleNode("RoleA[not(*)] | RoleB[not(*)]")
		ObjectEditor.Pool.AddRelation oNewObject, oRealProp, X_CreateObjectStub("Incident", sIncidentID) 
			 
    End Sub
	
	'==============================================================================
	' ����������� ���������� ������� Edit
	'	[in] oEventArgs As OpenEditorEventArgsClass
	Public Sub OnEdit(oEventArgs)
		Dim oXmlProperty		' ����������� xml-��������
		Dim oRealXmlProp		' �������� xml-��������
		Dim oIncidentLink		' As IXMLDOMElement - xml-������ IncidentLink
		Dim oOtherIncident		' As IXMLDOMElement - xml-������ Incident, � ������� ������ ������� �� ��������� ������� IncidentLink

		With oEventArgs
			' � ����������� ���...
			Set oRealXmlProp = getRealXmlProp(.ObjectID)
			If oRealXmlProp Is Nothing Then Err.Raise -1, "OnEdit", "�� ������� ����� �������� ��������"

			If oEventArgs.OperationValues.Item("ObjectType") = "Incident" Then

				Set oIncidentLink = ObjectEditor.Pool.GetXmlObjectByXmlElement( oRealXmlProp.selectSingleNode("IncidentLink[@oid='" & .ObjectID & "']"), Null)
				Set oOtherIncident = oIncidentLink.selectSingleNode("RoleA/*[@oid!='" & ObjectID & "'] | RoleB/*[@oid!='" & ObjectID & "']")
				.ReturnValue = ObjectEditor.OpenEditor(Null, "Incident", oOtherIncident.getAttribute("oid"), Null, False, oOtherIncident.parentNode, Not .IsSeparateTransaction, False, .UrlArguments)
				If IsEmpty( .ReturnValue ) Then Exit Sub
				' ����� �������������� ��������� ������ (IncidentLink) ����� ��������
				Set oRealXmlProp = getRealXmlProp(.ObjectID)
				If oRealXmlProp Is Nothing Then
					' �������, ������ �������� �� ������������ ��������
					XmlProperty.selectNodes("*[@oid='" & .ObjectID & "']").removeAll
				End If
				SetDataEx XmlProperty
			Else
				.ReturnValue = ObjectEditor.OpenEditor(Null, ValueObjectTypeName, .ObjectID, .Metaname, False, oRealXmlProp, Not .IsSeparateTransaction, False, .UrlArguments)
				If IsEmpty( .ReturnValue ) Then Exit Sub
				Set oXmlProperty = XmlProperty
				If IsOrdered Then
					' ���� �������� ����������� - ���������� ����������������� ������ � ������ ����������
					OrderObjectInPropEx oXmlProperty, oXmlProperty.selectSingleNode(ValueObjectTypeName & "[@oid='" & .ObjectID & "']")
				End If
				' ������� ������������� PE
				SetDataEx oXmlProperty
			End If	
		End With
	End Sub


	'==============================================================================
	' ����������� ���������� ������� MarkDelete
	'	[in] oEventArgs As OperationEventEventArgs
	Public Sub OnMarkDelete(oEventArgs)
		Dim oXmlProperty	' xml-��������
		Dim nButtonFlag		' ����� MsgBox
		Dim oRealXmlProp		' �������� xml-��������
		
		With oEventArgs
			' ���� ����� ����� ������� ������������, �� ������� �������
			If hasValue(.Prompt) Then
				' ����������, ����� �������� ���������� �������������� ������� OnKeyUp �� ������� Enter � �������
				HtmlElement.object.Enabled = False
				nButtonFlag = iif(StrComp(.OperationValues.Item("DefaultButton"), "No")=0, vbDefaultButton2, vbDefaultButton1)
				If vbNo = MsgBox(.Prompt, vbYesNo + vbInformation + nButtonFlag) Then
					HtmlElement.object.Enabled = True
					Exit Sub
				End If
				HtmlElement.object.Enabled = True
			End If
			
			' ����������: MarkObjectAsDeleted �� ���������� ��������� ����, ������� ����� ������������� ��������� ������ �� XmlProperty
			Set oXmlProperty = XmlProperty
			Set oRealXmlProp = getRealXmlProp(.ObjectID)
			If oRealXmlProp Is Nothing Then Err.Raise -1, "OnEdit", "�� ������� ����� �������� ��������"
			' ObjectEditor.Pool.MarkObjectAsDeleted ����� �������� �� �����, �.�. � ��� ���� ������ �� ��������� ������ � �
			oEventArgs.ReturnValue = ObjectEditor.Pool.MarkObjectAsDeleted( ValueObjectTypeName, .ObjectID, oRealXmlProp, False, Nothing )
			If oEventArgs.ReturnValue Then
				' � ������ ������ ������ �� ������������ ��������
				oXmlProperty.selectNodes(ValueObjectTypeName & "[@oid='" & .ObjectID & "']").removeAll
				' ������� ������������� ��������
				SetDataEx oXmlProperty
			End If
		End With
	End Sub
	
	
	'==============================================================================
	Private Function getRealXmlProp(ValueObjectID)
		Set getRealXmlProp = ObjectEditor.XmlObject.selectSingleNode("LinksFromRoleA[*[@oid='" & ValueObjectID & "']] | LinksFromRoleB[*[@oid='" & ValueObjectID & "']]")
	End Function
End Class


'==============================================================================
Function IncidentLink_getLinkedIncident(oPool, oIncidentLink, sOwnderOID)
	Set IncidentLink_getLinkedIncident = oPool.GetXmlObjectByXmlElement(oIncidentLink, "RoleA.State;RoleB.State").selectSingleNode("RoleA/Incident[@oid!='" & sOwnderOID & "'] | RoleB/Incident[@oid!='" & sOwnderOID & "']")
End Function


'==============================================================================
Function IncidentLink_getNumber(oPool, oIncidentLink, sOwnderOID)
	Dim oIncident
	Set oIncident = IncidentLink_getLinkedIncident(oPool, oIncidentLink, sOwnderOID)
	IncidentLink_getNumber = oPool.GetPropertyValue(oIncident, "Number")
End Function

Function IncidentLink_getState(oPool, oIncidentLink, sOwnderOID)
	Dim oIncident
	Set oIncident = IncidentLink_getLinkedIncident(oPool, oIncidentLink, sOwnderOID)
	IncidentLink_getState = oPool.GetPropertyValue(oIncident, "State.Name")
End Function

Function IncidentLink_getName(oPool, oIncidentLink, sOwnderOID)
	Dim oIncident
	Set oIncident = IncidentLink_getLinkedIncident(oPool, oIncidentLink, sOwnderOID)
	IncidentLink_getName = oPool.GetPropertyValue(oIncident, "Name")
End Function
