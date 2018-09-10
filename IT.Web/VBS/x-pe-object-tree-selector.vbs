Option Explicit

'==========================================================================
' ����� ��������� ���������� �������� � ���� ������.
' ��������� ������ ��������� � �������� ��� ����� ������ (GetData).
' USE-CASE: ��� ������������� � ������� ��� ������� ���������� ���������� ��������. 
' ��������: ��� ������������� � ���������� ��� ����������� ������� �� ������������!
' �������:
'	Load	- �������� ������
'	GetRestrictions - ��������� ����������� ��� ���������� ������
Class XPEObjectTreeSelectorClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private EVENTS						' As String	- ������ ������� ��������
	Private m_sLoader					' As String	- URL ���������� ������
	Private m_sMetaName					' As String	- ������� �������� PE (i:tree-selector)
	Private m_sTreeSelectorMetaName		' As String	- ������� �������� ��������� (i:objects-tree-selector)
	Private m_oTreeSelectorMD			' As IXMLDOMElement - ���� i:objects-tree-selector
	Private m_sSelectionMode			' As String - ����� ������ (��������� TSM_*)
	Private m_sViewStateCacheFileName	' As String - ������������ ����� � �������������� ��������������
	Private m_bKeyUpEventProcessing		' As Boolean - ������� ��������� ActiveX-������� OnKeyUp ��� "����������" �����
	
	'���������� drag&drop ��� �� �����������, ����� ���� ������� �� ����������
	'Private m_oDragDropController       ' AS TreeViewNodeDragDropController - ���������� �������� �������� ����� ������
	
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "Load,GetRestrictions,Accel"
	End Sub
	
	'==========================================================================
	' IPropertyEditor: 
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectTreeSelector"
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
	End Sub
	
	'==========================================================================
	' IPropertyEdior: ����� ���������� ��� ���������� �������� ���������, ����� ������������� ���� PE �� ��������
	Public Sub FillData()
		Dim sPath
		Load
		' ��������� ������ �� ����� �� ���������� ����� ��� ���������� ���������������
		If X_GetDataCache( m_sViewStateCacheFileName, sPath ) Then
			TreeView.SetNearestPath sPath, False
		End If
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
	' ��������� ������
	Public Sub Load
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
		' ����������: ����������� ���������� ����������� � ����������� ������� OnDataLoading (Internal_OnDataLoading)
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
			Case TSM_LEAFNODES
				TreeView.IsOnlyLeafSel = True
			Case TSM_ANYNODE
				TreeView.IsOnlyLeafSel = False
			Case TSM_ANYNODES 
				TreeView.IsOnlyLeafSel = False
			Case Else
				Err.Raise -1, "::SelectionMode", "����������� ����� �����������"
		End Select
	End Property
	Public Property Get SelectionMode
		SelectionMode = m_sSelectionMode
	End Property

	
	'==========================================================================
	' ���������� xml-�������-�������� xml-��������
	'	[retval] IXMLDOMElement ������-�������� � ����, ���� Nothing, ���� ��-�� ������
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
	' ���������� ������������� ������a-������� xml-��������
	Public Property Get ValueID
		Dim oXmlProperty
		Set oXmlProperty = XmlProperty
		ValueID = Null
		If Not oXmlProperty.FirstChild Is Nothing Then
			ValueID = oXmlProperty.FirstChild.getAttribute("oid")
		End If
	End Property
	
	'==========================================================================
	' IPropertyEditor: ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property

	'==========================================================================
	' IPropertyEditor: ������������� �������� � ������
	Public Sub SetData
		' �.�. ������ � ��� ����������� � �������, �� ��� ���������� �� ������� �� ������ � ������� Xml,
		' ������� ����� ��������� ������������� �� �����.
	End Sub

	'==========================================================================
	' IPropertyEditor: ���� ������
	Public Sub GetData(oGetDataArgs)
		Dim oNode
		' �������� ��������� ���� �� ��������� �����, ����� ��������
		Set oNode = TreeView.ActiveNode
		If Not oNode Is Nothing Then
			XmlProperty.selectNodes("*").removeAll
			ObjectEditor.Pool.AddRelation Nothing, XmlProperty, X_CreateObjectStub(oNode.Type, oNode.ID)
			X_SaveDataCache m_sViewStateCacheFileName, oNode.Path
		Else
			' �� ������ �������� - �������� �� ������������ NULL'a
			ValueCheckOnNullForPropertyEditor ValueID, m_oPropertyEditorBase, oGetDataArgs, Mandatory
		End If
	End Sub
	
	'==========================================================================
	' IPropertyEditor: 
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If (bMandatory) Then
			HtmlElement.removeAttribute "X_MAYBENULL"
		Else	
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
		End If
	End Property

	'==========================================================================
	' IPropertyEditor: ���������/��������� (��)����������� ��������
	Public Property Get Enabled
		Enabled = HtmlElement.object.Enabled
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.object.Enabled = bEnabled
		ExtraHtmlElement("ExpandAll").disabled = Not( bEnabled )
		ExtraHtmlElement("CollapseAll").disabled = Not( bEnabled )
		ExtraHtmlElement("Reload").disabled = Not( bEnabled )
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
		Set ExtraHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.id & sName )
	End Function
	
	'==========================================================================
	' ���������� ������ "�������� ��"
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
	' ���������� ������ "���������� ��"
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
	' ���������� ������ "��������"
	Sub Internal_OnReload
		Load
	End Sub
	
	'==============================================================================
	' ���������� ������� OnDataLoading ��� oTreeView.
	'	������������ ��� ��������� � ������ �� ��������� ������
	'	�������� ���������� �������.
	Sub Internal_OnDataLoading( oSender,  nQuerySet,  sNodePath,  sObjectType,  sObjectID,  oRestrictions)
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass
		Dim sRestrictions	' ��������� � ������ �� �������� ������������
		
		' ������� ����������� �� ���������������� ��������
		Set oSelectorRestrictions = New GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions
		sRestrictions = oSelectorRestrictions.ReturnValue

		internal_TreeInsertRestrictions oRestrictions, sRestrictions
	End Sub
	
	'==========================================================================
	' ���������� ActiveX-������� onKeyUp (������� �������). ����������� ��������� �� �������� 
	' ��������: ��� ����������� �������������.
	Public Sub Internal_OnKeyUpAsync(ByVal nKeyCode, ByVal nFlags)
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
    
End Class
