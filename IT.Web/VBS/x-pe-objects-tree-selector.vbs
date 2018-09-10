Option Explicit

'==========================================================================
' ����� ��������� ��������� ������� � ���� read-only-������  � ����������.
' ��� ��������� ������� �� ��������� � ��������, ��� ������ - ���������.
' �������:
'	Load		- �������� (Nothing), ���� ����������� ����������
'	Selected	- ����� ��������, ��������� ������� � �������� (SelectedEventArgsClass)
'	UnSelected	- ������ ��������� � ��������, �������� ������� �� �������� (SelectedEventArgsClass)
Class XPEObjectsTreeSelectorClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private EVENTS						' As String	- ������ ������� ��������
	Private m_sLoader					' As String	- URL ���������� ������
	Private m_sMetaName					' As String	- ������� �������� PE (i:tree-selector)
	Private m_sTreeSelectorMetaName		' As String	- ������� �������� ��������� (i:objects-tree-selector)
	Private m_bLoading					' As Boolean - ������� ��������
	Private m_oTreeSelectorMD			' As IXMLDOMElement - ���� i:objects-tree-selector
	Private m_sSelectionMode			' As String - ����� ������ (��������� TSM_*)
	Private m_sViewStateCacheFileName	' As String - ������������ ����� � �������������� ��������������
	Private m_bKeyUpEventProcessing		' As Boolean - ������� ��������� ActiveX-������� OnKeyUp ��� �������������� ������������ �����
	Private m_oDragDropController       ' AS TreeViewNodeDragDropController - ���������� �������� �������� ����� ������
	
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "Load,Selected,UnSelected,GetRestrictions,Accel"
	End Sub
 
	'==========================================================================
	' IPropertyEditor: 
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
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
		
		Set m_oDragDropController = Nothing

        If m_oPropertyEditorBase.PropertyEditorMD.GetAttribute("allow-drag-drop") = "1" Then
		    ' ������������� ����������� �������� ��������
		    Set m_oDragDropController = New TreeNodeDragDropController
		    m_oDragDropController.EventEngine.InitHandlers XTREENODEDRAGDROPCONTROLLER_EVENTS, "usr_" & oXmlProperty.ParentNode.tagName & "_" & oXmlProperty.tagName & "_ObjectsTreeSelector_On"
		    m_oDragDropController.EventEngine.InitHandlers XTREENODEDRAGDROPCONTROLLER_EVENTS, "usr_" & oXmlProperty.ParentNode.tagName & "_" & oXmlProperty.tagName & "_On"
		    m_oDragDropController.EventEngine.InitHandlers XTREENODEDRAGDROPCONTROLLER_EVENTS, "usr_" & oXmlProperty.tagName & "_ObjectsTreeSelector_On"
		    m_oDragDropController.EventEngine.InitHandlers XTREENODEDRAGDROPCONTROLLER_EVENTS, "usr_ObjectsTreeSelector_On"
		End If
		
		m_sLoader = "x-tree-loader.aspx?metaname=" & m_sTreeSelectorMetaName
		m_sViewStateCacheFileName = ObjectEditor.Signature() & "XTreeSelector." + oXmlProperty.parentNode.tagName & "." & oXmlProperty.tagName & "." & m_oPropertyEditorBase.PropertyEditorMD.getAttribute("n")
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
		' ��������� ������ �����������
		SelectionMode = m_sSelectionMode
		' �������� ����� ������ ����, ��� ���� ������������� ���� ������� �������� ��������
		TreeView.SelectableTypes = ValueObjectTypeName
		TreeView.Loader = m_sLoader 
		On Error Resume Next
		TreeView.Reload
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
	' IPropertyEditor: ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property


	'==========================================================================
	' IPropertyEditor: ������������� �������� � ������
	Public Sub SetData
		Dim oXmlProperty	' As IXMLDOMElement - xml-��������
		Dim oSelection
		Dim oNode

		Set TreeView.Selection = Nothing
		Set oXmlProperty = XmlProperty
		If Not oXmlProperty.hasChildNodes Then Exit Sub
		processNodes oXmlProperty
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
	' IPropertyEditor: Mandatory
	' ��������� �������� �������������� �� �����������
	Public Property Get Mandatory
		Mandatory = False
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
	' ����������/������������� �������� ��������
	Public Property Get PropertyDescription
		PropertyDescription = m_oPropertyEditorBase.PropertyDescription
	End Property	
	Public Property Let PropertyDescription(sValue)
		m_oPropertyEditorBase.PropertyDescription = sValue
	End Property


	'==========================================================================
	' ������� ������
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
		Set m_oPropertyEditorBase = Nothing
	End Sub	

	
	'==========================================================================
	' ����������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	

	
	'==========================================================================
	' ���������� ������������ ���� ������� �������� ��������
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyEditorBase.ValueObjectTypeName
	End Property

	
	'==========================================================================
	' ���������� �������������� ������� IHTMLElement
	Private Function ExtraHtmlElement(sName)
		Set ExtraHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.id & sName)
	End Function

	
	'==========================================================================
	' ���������� ������ �������� ������. ��������������� � xslt-�������. 
	' ��������� ���������� �� �������
	' ��� ����������� �������������!
	'	[in] oNode - ��������� ����
	'	[in] bSelected - ��������� checkbox'a ����
	Public Sub Internal_OnSelChange( oNode, bSelected )
		Dim oXmlProperty	' As IXMLDOMElement - xml-��������

		If m_bLoading Then Exit Sub
		Set oXmlProperty = XmlProperty
		With New NodeSelectedEventArgsClass
			Set .TreeNode = oNode
			.Checked = bSelected
			If bSelected Then
				' �������� ������ - ������� ������ �� ���� � ��������
				' �������� ������ ��������� � �����
				m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, X_CreateObjectStub(ValueObjectTypeName, oNode.ID)
				FireEvent "Selected", .Self()
			Else
				' ����������� ������ - ������� ������� �� ���� �� ��������
				m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.selectSingleNode("*[@oid='" & oNode.ID &"']")
				FireEvent "UnSelected", .Self()
			End If
		End With
	End Sub	

	
	'==========================================================================
	' ���������� ������ �������� ������ ������ (ActiveX-������� OnDataLoaded - ��. ������������ �� XControls). 
	' ��������������� � xslt-�������. ��� ����������� �������������!
	'	[in] nQuerySet - ��������, ��������� ������� (��������� QUERY_SET_*)
	'	[in] sNodePath - ���� �� ����, ������������ �������� ���� ��������� �������� �������� ��������� �������� ���������
	'	[in] sObjectType - 
	'	[in] sObjectID -
	'	[in] oRestrictions as IXMLDOMElement - xml-���� � ������������� (��������� �� ��������� internal_TreeInsertRestrictions)
	Public Sub Internal_OnDataLoading( nQuerySet, sNodePath, sObjectType, sObjectID, oRestrictions )
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass
		
		' ������� ����������� �� ���������������� ��������
		Set oSelectorRestrictions = New GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions
		' � ������� �� � xml-������ ���������� ������
		internal_TreeInsertRestrictions oRestrictions, oSelectorRestrictions.ReturnValue
	End Sub


	'==========================================================================
	' ���������� ��������� �������� ������ ������ (ActiveX-������� OnDataLoaded - ��. ������������ �� XControls). 
	' ��������������� � xslt-�������. ��� ����������� �������������!
	'	[in] nQuerySet - ��������, ��������� ������� (��������� QUERY_SET_*)
	'	[in] sNodePath - ���� �� ����, ������������ �������� ���� ��������� �������� �������� ��������� �������� ���������
	'	[in] sObjectType - 
	'	[in] sObjectID -
	Public Sub Internal_OnDataLoaded( nQuerySet, sNodePath, sObjectType, sObjectID )
		Dim oXmlProperty	' As IXMLDOMElement - xml-��������
		Dim oNodes			' As IXTreeNodes

		Set oXmlProperty = XmlProperty
		If Not oXmlProperty.hasChildNodes Then Exit Sub
		
		Set oNodes = Nothing
		If QUERY_SET_ROOT = nQuerySet Then
			' ��������� �������� ����
			Set oNodes = TreeView.Root
		ElseIf QUERY_SET_CHILD = nQuerySet Then
			Set oNodes = TreeView.GetNode(sNodePath).Children
		End If
		
		If oNodes Is Nothing Then Exit Sub
		
		processNodes oXmlProperty
	End Sub

	'==========================================================================
	' ������������� checkbox'� �� ����, ��������������� �������� � ��������
	'	[in] oXmlProperty As IXMLDOMElement
	Private Sub processNodes(oXmlProperty)
		Dim aNodes			' As Array - ������ ����������� IXTreeNode
		Dim oNode			' As IXTreeNode - ���� ������
		Dim oObject			' As IXMLDOMElement - xml-������
		
		m_bLoading = True
		For Each oObject In oXmlProperty.childNodes
			aNodes = HtmlElement.FindAnyNode(oObject.tagName, oObject.getAttribute("oid"))
			If UBound(aNodes) > -1 Then
				For Each oNode In aNodes
					HtmlElement.LockEvents = True
					oNode.Selected = True
					HtmlElement.LockEvents = False
				Next
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
			' ��������: ��������� � �������� Children �������� � ���������� ������� ���������� getchildren (���� ��� ��������� ����) !
			If Not oTreeNode.IsLeaf Then
				ExpandNode oTreeNode.Children
			End If
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
	' ���������� ActiveX-������� onKeyUp (������� �������). ����������� ��������� �� �������� 
	' ��������: ��� ����������� �������������.
	Public Sub Internal_OnKeyUp(ByVal nKeyCode, ByVal nFlags)
		Dim oEventArgs		' As AccelerationEventArgsClass
		If m_bKeyUpEventProcessing Then Exit Sub
		m_bKeyUpEventProcessing = True
		Set oEventArgs = CreateAccelerationEventArgsForActiveXEvent(nKeyCode, nFlags)
		Set oEventArgs.Source = Me
		Set oEventArgs.HtmlSource = HtmlElement
		FireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' ��������� ������� ���������� � ��������
			ObjectEditor.OnKeyUp Me, oEventArgs
		End If
		m_bKeyUpEventProcessing = False
	End Sub

    '==============================================================================
    ' ������ �������� - ����� ��������
    Public Sub Internal_OnBeforeNodeDrag(oTreeView, oSourceNode, nKeyFlags, bCanDrag)
	    m_oDragDropController.OnBeforeNodeDrag Me, oTreeView, oSourceNode, nKeyFlags, bCanDrag
    End Sub

    '==============================================================================
    ' ������ �������� - ������ �������������
    Public Sub Internal_OnNodeDrag(oTreeView, oSourceNode, nKeyFlags)
	    m_oDragDropController.OnNodeDrag Me, oTreeView, oSourceNode, nKeyFlags
    End Sub

    '==============================================================================
    ' �������� ��� ������ �����
    Public Sub Internal_OnNodeDragOver(oTreeView, oSourceNode, oTargetNode, nKeyFlags, bCanDrog)
	    m_oDragDropController.OnNodeDragOver Me, oTreeView, oSourceNode, oTargetNode, nKeyFlags, bCanDrog
    End Sub
    '==============================================================================
    ' ������� ���������
    Public Sub Internal_OnNodeDragDrop(oTreeView, oSourceNode, oTargetNode, nKeyFlags)
	    m_oDragDropController.OnNodeDragDrop Me, oTreeView, oSourceNode, oTargetNode, nKeyFlags
    End Sub

    '==============================================================================
    ' �������� �������
    Public Sub Internal_OnNodeDragCanceled(oTreeView, oSourceNode, nKeyFlags)
	    m_oDragDropController.OnNodeDragCanceled Me, oTreeView, oSourceNode, nKeyFlags
    End Sub
    
End Class


'==============================================================================
' ��������� ������� "Selected", "UnSelected"
Class NodeSelectedEventArgsClass
	Public Cancel			' As Boolean - ������� ������ ��� ������� ������������. 
	Public TreeNode			' As IXTreeNode
	Public Checked			' As Boolean
	
	Public Function Self
		Set Self = Me
	End Function
End Class
