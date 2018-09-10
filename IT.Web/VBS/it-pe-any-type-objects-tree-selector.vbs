Option Explicit

'==========================================================================
' ����� ��������� ���������� ��������� ������� � ���� read-only-������  � ����������.
' ��� ��������� ������� �� ��������� � ��������, ��� ������ - ���������.
' �������:
'	Load		- �������� (Nothing), ���� ����������� ����������
'	Selected	- ����� ��������, ��������� ������� � �������� (SelectedEventArgsClass)
'	UnSelected	- ������ ��������� � ��������, �������� ������� �� �������� (SelectedEventArgsClass)
Class XPEAnyTypeObjectsTreeSelectorClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private EVENTS						' As String	- ������ ������� ��������
	Private m_sLoader					' As String	- URL ���������� ������
	Private m_sMetaName					' As String	- ������� �������� PE (i:tree-selector)
	Private m_sTreeSelectorMetaName		' As String	- ������� �������� ��������� (i:objects-tree-selector)
	Private m_bLoading					' As Boolean - ������� ��������
	Private m_oTreeSelectorMD			' As IXMLDOMElement - ���� i:objects-tree-selector
	Private m_sSelectionMode			' As String - ����� ������ (��������� TSM_*)
	Private m_sViewStateCacheFileName	' As String - ������������ ����� � �������������� ��������������
	Private m_oPropertyNamesDictionary	' As Scripting.Dictionary - ������� ������������ ������������� �������:
										' ���� - ������������ ���������� ����, �������� - ������������ ��������
		
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "Load,Selected,UnSelected,GetRestrictions"
	End Sub
	
	
	'==========================================================================
	' IPropertyEditor: 
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim vMetaName		' ������� ������ ��� ���������� ListView
		Dim sXPath			' XPAth -������
		Dim oSelection		' As IXMLDOMElement - �������������� �������� ��������� �����
		Dim oNode			' As IXMLDOMElement - ���� "n" � �������� ��������� �����
		Dim sPropertyName	' As String			- ������������ �������������� ��������
		Dim sObjectType		' As String			- ������������ ���� ������� �������� ��������
		
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectsTreeSelector"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEvent "Load", Me, "OnLoad"
		m_sMetaName = HtmlElement.GetAttribute("Metaname")
		If m_oPropertyEditorBase.PropertyEditorMD Is Nothing Then Err.Raise -1, "XPEObjectsTreeSelectorClass::Init", "�� ������� �������� ��������� �������� (i:tree-selector) � ��"
		Set m_oTreeSelectorMD = m_oPropertyEditorBase.PropertyEditorMD.selectSingleNode("i:objects-tree-selector")
		If m_oTreeSelectorMD Is Nothing Then Err.Raise -1, "XPEObjectsTreeSelectorClass::Init", "�� ����� ���� i:objects-tree-selector ��� i:tree-selector"
		' ������� ����� ������, �� ��������� ��� ���� (��������������� ����)
		m_sSelectionMode  = X_GetAttributeDef(m_oTreeSelectorMD, "selection-mode", TSM_ANYNODES)
		' ������� ������� ���������
		m_sTreeSelectorMetaName = m_oTreeSelectorMD.GetAttribute("n")
		m_sLoader = "x-tree-loader.aspx?metaname=" & m_sTreeSelectorMetaName
		m_sViewStateCacheFileName = ObjectEditor.Signature() & "XTreeSelector." + oXmlProperty.parentNode.tagName & "." & oXmlProperty.tagName & "." & m_oPropertyEditorBase.PropertyEditorMD.getAttribute("n")
		
		' �������������� ������� ������������ ������������� �������
		Set m_oPropertyNamesDictionary = CreateObject("Scripting.Dictionary")
		For Each sPropertyName In PropertyNames
			sObjectType	= ObjectEditor.PropMD(sPropertyName).getAttribute("ot")
			m_oPropertyNamesDictionary.Add sObjectType, sPropertyName		
		Next
	End Sub

	
	'==========================================================================
	' IPropertyEdior: ����� ���������� ��� ���������� �������� ���������, ����� ������������� ���� PE �� ��������
	Public Sub FillData()
		Load
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
	' ���������� ��������� EventEngineClass - �������, ���������������
	' ���������� ������ ��� ������� ��������� ��������
	Public Property Get EventEngine
		Set EventEngine = m_oPropertyEditorBase.EventEngine
	End Property


	'==========================================================================
	' ���������� ���� � ������ � ������� ���|�������������|���|������������� �� xml-���� �������� ��������� ���� � �������
	' <n ot=".." id=".." t=".."><n ../></n>
	Public Function GetPathFromXml(oNode)
		Dim oSubNode
		Dim sPath
		For Each oSubNode In oNode.selectNodes("descendant-or-self::n")
			If Len(sPath)>0 Then sPath = sPath & "|" 
			sPath = sPath & oSubNode.getAttribute("ot") & "|" & oSubNode.getAttribute("id")
		Next
		GetPathFromXml = sPath
	End Function

	
	'==========================================================================
	' ��������� ������
	Public Sub Load()
		FireEvent "Load", Nothing
	End Sub
	
	
	'==========================================================================
	' ���������� ������� Load
	Public Sub OnLoad(oSender, oEventArgs)
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass
		Dim sUrlParams		' ��������� � �������� ��������� ������
		Dim sRestrictions	' ��������� � ������ �� �������� ������������
		
		' ������� ����������� �� ���������������� ��������
		Set oSelectorRestrictions = New GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions

		sUrlParams = oSelectorRestrictions.UrlParams
		sRestrictions = XService.URLEncode(oSelectorRestrictions.ReturnValue)

		' ��������� ������ �����������
		SelectionMode = m_sSelectionMode
		' �������� ����� ������ ����, ��� ��� ������������� ���� ������� ������-����
		' �������������� ��������.  ���� �� ������ �� ������ �������������� ��������,
		' �������� "_" (����� ��������, ��� ������ �������� ���)
		TreeView.SelectableTypes = nvl( Join(PropertyNamesDictionary.Keys, " "), "_" )
		TreeView.Loader = m_sLoader & "&RESTR=" & sRestrictions & sUrlParams
		TreeView.LockEvents = True
		On Error Resume Next
		TreeView.Reload
		TreeView.LockEvents = False
		If X_ErrOccured() Then
			X_ErrReport()
			Exit Sub
		End If
	End Sub

	
	'==========================================================================
	' �������������/���������� ������ ����������� ������ (������� �������������� ������ � ������� ������ ������ �������� �����)
	Public Property Let SelectionMode(sMode)
		m_sSelectionMode = sMode
		Select Case m_sSelectionMode 
			Case TSM_LEAFNODE
				TreeView.IsOnlyLeafSel = True
				TreeView.IsMultipleSel = False
			Case TSM_LEAFNODES
				TreeView.IsOnlyLeafSel = True
				TreeView.IsMultipleSel = True
			Case TSM_ANYNODE
				TreeView.IsOnlyLeafSel = False
				TreeView.IsMultipleSel = False
			Case TSM_ANYNODES 
				TreeView.IsOnlyLeafSel = False
				TreeView.IsMultipleSel = True
			Case Else
				Err.Raise -1, "::SelectionMode", "����������� ����� �����������"
		End Select
	End Property
	Public Property Get SelectionMode
		SelectionMode = m_sSelectionMode
	End Property

	
	'==========================================================================
	' IPropertyEditor: ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property


	'==========================================================================
	' IPropertyEditor: ������������� �������� � ������
	Public Sub SetData
		Dim oSelection
		Dim oNode

		Set TreeView.Selection = Nothing
		processNodes TreeView.Root
		' ��������� ������ �� ����� �� ���������� ����� ��� ���������� ���������������
		If X_GetDataCache( m_sViewStateCacheFileName, oSelection ) Then
			For Each oNode In oSelection.selectNodes("n[n]")
				TreeView.SetNearestPath GetPathFromXml(oNode), False
			Next
		End If
	End Sub
	
	'==========================================================================
	' IPropertyEditor: ���� ������
	Public Sub GetData(oGetDataArgs)
		Dim oSelection		' ���������� ���� ������
		' �������� ��������� ���� �� ��������� �����, ����� ��������
		Set oSelection = TreeView.Selection.cloneNode(true)
		oSelection.selectNodes("n[not(n)]").removeAll
		X_SaveDataCache m_sViewStateCacheFileName, oSelection
	End Sub

	
	'==========================================================================
	' IPropertyEditor: 
	Public Property Get Mandatory
	End Property
	Public Property Let Mandatory(bMandatory)
	End Property


	'==========================================================================
	' IPropertyEditor: ���������/��������� (��)����������� ��������
	Public Property Get Enabled
		Enabled = HtmlElement.object.Enabled
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.object.Enabled = bEnabled
		ExtraHtmlElement("Clear").disabled = Not( bEnabled )
		ExtraHtmlElement("ShowSelected").disabled = Not( bEnabled )
		ExtraHtmlElement("ExpandAll").disabled = Not( bEnabled )
		ExtraHtmlElement("CollapseAll").disabled = Not( bEnabled )
	End Property

	
	'==========================================================================
	' IPropertyEditor: ��������� ������
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function

	
	'==========================================================================
	' IPropertyEditor: ���������� IHTMLObjectElement
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property

	
	'==========================================================================
	' ���������� XTreeView
	Public Property Get TreeView
		Set TreeView = m_oPropertyEditorBase.HtmlElement.object
	End Property

	
	'==========================================================================
	' ������� ������
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
		Set m_oPropertyEditorBase = Nothing
		Set m_oPropertyNamesDictionary = Nothing
	End Sub	

	
	'==========================================================================
	' ����������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	

	
	'==========================================================================
	' ���������� �������������� ������� IHTMLElement
	Private Function ExtraHtmlElement(sName)
		Set ExtraHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.id & sName)
	End Function


	'==========================================================================
	' ���������� ������ ������������ ������������� �������
	Public Property Get PropertyNames
		PropertyNames = Split( HtmlElement.GetAttribute("X_PROP_NAMES"), " " )
	End Property


	'==========================================================================
	' ���������� ������� ������������ ������������� �������:
	' ���� - ������������ ���������� ����, �������� - ������������ ��������
	Public Property Get PropertyNamesDictionary
		Set PropertyNamesDictionary = m_oPropertyNamesDictionary
	End Property

	
	'==========================================================================
	' ���������� ������������ �������������� �������� �� ������������ ���� ������� �������� ��������
	' [in] sObjectType - ������������ ����
	Public Function PropertyNameByType(sObjectType)
		PropertyNameByType = PropertyNamesDictionary.Item(sObjectType)
	End Function
	

	'==========================================================================
	' ���������� Xml-�������� �� ������������ ����
	' [in] sObjectType - ������������ ����
	Public Function XmlPropertyByType(sObjectType)
		Dim sPropertyName
		sPropertyName = PropertyNameByType(sObjectType)
		Set XmlPropertyByType = XmlPropertyByPropertyName(sPropertyName)
	End Function


	'==========================================================================
	' ���������� Xml-�������� �� ������������ ��������
	' [in] - ������������ ��������
	Public Function XmlPropertyByPropertyName(sPropertyName)
		Dim sObjectType			' As String
		Dim sObjectID			' As String
		Dim sXmlPropertyXPath	' As String - XPath ��� ���������� �������� � ����
		
		' ���� �� �������� ��� ��������, �� ���������� Nothing
		If IsEmpty(sPropertyName) Then
			Set XmlPropertyByPropertyName = Nothing
			Exit Function
		End If
				
		sObjectType	= m_oPropertyEditorBase.ObjectType
		sObjectID	= m_oPropertyEditorBase.ObjectID
		sXmlPropertyXPath	= sObjectType & "[@oid='" & sObjectID & "']/" & sPropertyName
		Set XmlPropertyByPropertyName = ObjectEditor.XmlObjectPool.selectSingleNode( sXmlPropertyXPath )
		If XmlPropertyByPropertyName Is Nothing Then
			Set XmlPropertyByPropertyName = ObjectEditor.Pool.GetXmlObject(sObjectType, sObjectID, Null).SelectSingleNode(sPropertyName)
		End If
		If XmlPropertyByPropertyName Is Nothing Then _
			Err.Raise -1, "XPEAnyTypeObjectsTreeSelectorClass::XmlPropertyByPropertyName", "�� ������� �������� " & sPropertyName & " � xml-�������"
		If Not IsNull(XmlPropertyByPropertyName.getAttribute("loaded")) Then
			Set XmlPropertyByPropertyName = ObjectEditor.LoadXmlProperty( Nothing, XmlPropertyByPropertyName)
		End If
	End Function


	'==========================================================================
	' ���������� ������ �������� ������. ��������������� � xslt-�������. ��� ����������� �������������!
	'	[in] oNode - ��������� ����
	'	[in] bSelected - ��������� checkbox'a ����
	Public Sub Internal_OnSelChange( oNode, bSelected )
		Dim oXmlProperty	' As IXMLDOMElement - xml-��������

		If m_bLoading Then Exit Sub

		Set oXmlProperty = XmlPropertyByType(oNode.Type)
		If oXmlProperty Is Nothing Then Exit Sub

		With New NodeSelectedEventArgsClass
			Set .TreeNode = oNode
			.Checked = bSelected
			If bSelected Then
				' �������� ������ - ������� ������ �� ���� � ��������
				' �������� ������ ��������� � �����
				m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, X_CreateObjectStub(oNode.Type, oNode.ID)
				FireEvent "Selected", .Self()
			Else
				' ����������� ������ - ������� ������� �� ���� �� ��������
				m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.selectSingleNode("*[@oid='" & oNode.ID &"']")
				FireEvent "UnSelected", .Self()
			End If
		End With
	End Sub	

	
	'==========================================================================
	' ���������� �������� ������ ������. ��������������� � xslt-�������. ��� ����������� �������������!
	'	[in] nQuerySet - ��������, ��������� ������� (��������� QUERY_SET_*)
	'	[in] sNodePath - ���� �� ����, ������������ �������� ���� ��������� �������� �������� ��������� �������� ���������
	'	[in] sObjectType - 
	'	[in] sObjectID 
	Public Sub Internal_OnDataLoaded( nQuerySet, sNodePath, sObjectType, sObjectID )
		Dim oNodes			' As IXTreeNodes

		Set oNodes = Nothing
		If QUERY_SET_ROOT = nQuerySet Then
			' ��������� �������� ����
			Set oNodes = TreeView.Root
		ElseIf QUERY_SET_CHILD = nQuerySet Then
			Set oNodes = TreeView.GetNode(sNodePath).Children
		End If
		
		If oNodes Is Nothing Then Exit Sub
		
		processNodes oNodes
	End Sub


	'==========================================================================
	' ������������� checkbox'� �� ���� �� ��������� oNodes, ��������������� �������� � ��������
	'	[in] oNodes As CROC.IXTreeNodes
	Private Sub processNodes(oNodes)
		Dim oXmlProperty	' As IXMLDOMElement - xml-��������
		Dim sType			' As String - ��� ������� �������� ��������
		Dim oNode			' As IXTreeNode - ���� ������
		Dim oObject			' As IXMLDOMElement - xml-������
		Dim i
		Dim oChildren
		
		If oNodes.Count=0 Then Exit Sub
		m_bLoading = True
		For i=0 To oNodes.Count-1
			Set oNode = oNodes.GetNode(i)
			Set oXmlProperty = XmlPropertyByType(oNode.Type)
			If Not oXmlProperty Is Nothing Then
				For Each oObject In oXmlProperty.childNodes
					If oNode.ID = oObject.getAttribute("oid") Then
						HtmlElement.LockEvents = True
						oNode.Selected = True
						HtmlElement.LockEvents = False
						Exit For
					End If
				Next
			End If
			If oNode.Expanded Then
				Set oChildren = oNode.Children
				If oChildren.Count > 0 Then processNodes oChildren
			End If
		Next
		m_bLoading = False
	End Sub
	
	
	'==========================================================================
	' ���������� �������� "�������� ��"
	Public Sub Internal_OnCollapseAll
		Dim oNode	' As IXTreeNode
		Dim i
		' ������ ������� ��� �������� ����
		For i=0 To TreeView.Root.Count-1
			Set oNode = TreeView.Root.GetNode(i)
			oNode.Expanded = False
		Next
	End Sub
	
	
	'==========================================================================
	' ���������� �������� "���������� ��"
	Public Sub Internal_OnExpandAll
		m_oPropertyEditorBase.ObjectEditor.EnableControls False
		ExpandNode TreeView.Root
		m_oPropertyEditorBase.ObjectEditor.EnableControls True
	End Sub

	
	'==========================================================================
	' ���������� ����� ������������ �������������� �����
	'	[in] oTreeNodes As IXTreeNodes
	Private Sub ExpandNode(oTreeNodes)
		Dim oTreeNode	' As IXTreeNode
		Dim i
		
		If oTreeNodes Is Nothing Then Exit Sub
		If oTreeNodes.Count=0 Then Exit Sub
		For i=0 To oTreeNodes.Count-1
			Set oTreeNode = oTreeNodes.GetNode(i)
			oTreeNode.Expanded = True
			ExpandNode oTreeNode.Children
		Next
	End Sub
	
	'==========================================================================
	' ���������� �������� "�������� ���������"
	Public Sub Internal_OnClear
		Dim oNode			' As IXMLDOMELement
		Dim oTreeNode		' As IXTreeNode
		' ������� �� ��� ���������� ����� � ���������� ������ ��������� � ���
		For Each oNode In TreeView.Selection.ChildNodes
			Set oTreeNode = TreeView.GetNode( GetPathFromXml(oNode), False )
			oTreeNode.Selected = False
		Next
	End Sub
	
	
	'==========================================================================
	' ���������� �������� "�������� ���������"
	Public Sub Internal_OnShowSelected
		TreeView.ExpandSelection True
	End Sub
End Class
