'********************************************************************************
'C������� ������ ������ ��� ���������� �������� �� ������,
' ������ ����������� � ��������� ����.
'
' ��� �������� � ��������� ���������� ������������ ��������� ������ SelectFromTreeDialogClass.
' ��� ��������� ��������������� � ���������� ����� ���� �����. �������� ������� ������������� � ������� ������ Show.
' ��������� ������ SelectFromTreeDialogClass ���������� ����� DialogArguments.
' ������� �������� �������� ����������� ������� CROC.XTreeView (��� �� �������� - "oTreeView")
'
'********************************************************************************

Option Explicit
' ���������� ����������
Dim g_XTreeSelectorInstance
Dim FilterObject				' ��������� �������

Function XTreeSelector
	' ����������� Singleton
	If IsObject(g_XTreeSelectorInstance) Then
		If Nothing Is g_XTreeSelectorInstance Then
			Set g_XTreeSelectorInstance = New TreeSelectorClass
		End If
	Else
		Set g_XTreeSelectorInstance = New TreeSelectorClass
	End If
	Set  XTreeSelector = g_XTreeSelectorInstance
End Function


'==============================================================================
'	�������:
'	Load	- ���������� ����� ��������� �������� ���� ��������� �������� � ������, �� ����� ���������� ���� � ������. (EventArgs: Nothing)
'	Select	- ���������� ����� ������ ����� ����� �������� ����. ���� ���� ReturnValue ���������� � False, ���� �� �����������. (EventArgs: SelectEventArgsClass)
'	UnLoad	- ���������� ��� �������� ���� (����� �������) (EventArgs: Nothing)
Class TreeSelectorClass
	Private m_oTreeView				' As CROC.IXTreeView
	Private m_sLoader				' URL ���������a ������		
	Private m_sTreeInitPath			' ��������� ���� � ���� ������, �������� ������� ��� ������ ��������
	Private m_sSelectionMode		' ����� ������: TSM_LEAFNODE, TSM_LEAFNODES, TSM_ANYNODE, TSM_ANYNODES
	Private m_sSelectableTypes		' ���� �����, ������� ����� �������. 
	Private m_bSelectionCanBeEmpty	' ������������ ������� ���������
	Private m_sSelectionEmptyMsg	' ���������, ���������� ������������, � ������, ���� �� �� ������ �������� ���� � SelectionCanBeEmpty<>True
	Private m_oSelected				' ��, ��� ��� ��������
	Private m_sHelpPage				' �������� ������
	Private m_vDone					' ������� ���� ��� �������� ��e �������������������
	Private m_sMetaName				' �������� ��������
	Private m_sLoaderParams			' ��������� ����������
	Private m_oUrlArguments			' As QueryString - �������������� ���������, ������������ � ���������
	Private m_sExcludeNodes			' As String - ������ ����������� ����� - ��. [x-utils.vbs]SelectFromTreeDialogClass.ExcludeNodes
	Private m_oEventEngine			' As EventEngine
	Private m_oEventEngineFilter	' As EventEngine - EventEngine ��� ��������� ������� �� ������� (���������� � x-filter.htc)
	Private EVENTS					' As String -������ ������� ����������
	Private m_bOffFilterViewState	' As Boolean - ������� "�� ��������� ��������� �������"
	Private m_bMayBeInterrupted 	' As Boolean - ������� ���������� �������� ��������

	' HTML Controls
	Private xPaneFilter
	Private xPaneHeader
	Private xPaneCaption
	Private xPaneSpecialCaption
	Private cmdRefresh
	Private cmdClearFilter
	Private cmdHideFilter
	Private cmdOK
	Private cmdCancel
	Private xPaneAccessDenied
	Private TreeHolder
	Private NoDataMsg
	
	'==========================================================================
	'- �������������� ���������
	Public Property Get UrlArguments	' As QueryStringClass
		Set UrlArguments = m_oUrlArguments
	End Property
	
	'==========================================================================
	'- ������� ��������
	Public Property Get MetaName
		MetaName = X_PAGE_METANAME
	End Property

	
	'==========================================================================
	'- �������� ������
	Public Property Get HelpPage
		HelpPage = m_sHelpPage
	End Property

	
	'==========================================================================
	'- ����� ������
	Public Property Get SelectionMode
		SelectionMode = m_sSelectionMode
	End Property

	
	'==========================================================================
	'-- ��������� ���� � ������
	Public Property Get InitialTreePath
		InitialTreePath = m_sTreeInitPath
	End Property


	'==========================================================================
	Public Property Let InitialTreePath(sNewValue)
		If True=m_vDone Then
			err.Raise -1, "public property let InitialTreePath(sNewValue)", "������ ������ ��� ��������!"	
		end if
		m_sTreeInitPath = sNewValue
	End Property

	
	'==========================================================================
	' �����������
	Private Sub Class_Initialize
		m_bMayBeInterrupted = True
		' ����������� Singleton
		If IsObject(g_XTreeSelectorInstance) Then
			If Not (Nothing Is g_XTreeSelectorInstance) Then
				Err.Raise -1, "TreeSelectorClass::Class_Initialize", "Singleton"
			End If
		End if
		EVENTS = "Load,UnLoad,Select,SetInitPath"
		Set m_oEventEngine = X_CreateEventEngine
	End Sub


	'==============================================================================
	' ��������� ������ � ���������� ��������� �� �������� ������
	'	[in] sKey As String   - ����
	'	[in] vData As Variant - ��������� 
	'	[retval] True - ������ ��������, False - ���� �� ������
	Public Function GetUserData(sKey, vData)
		GetUserData = XService.GetUserData( GetUserDataName(sKey), vData)
	End Function 


	'==============================================================================
	' ��������� ������ �� ����������� ��������� �� �������� ������
	'	[in] sKey As String   - ����
	'	[in] vData As Variant - �����-�� ������ 
	Public Sub SetUserData(sKey, vData)
		XService.SetUserData GetUserDataName(sKey), vData
	End Sub


	'==============================================================================
	' ���������� ��� ����� ��� ���������� ���������������� ������
	'	[in] sSuffix - ������ �����
	'	[retval] ������������ �����
	Private Function GetUserDataName(sSuffix)
		GetUserDataName = "XSFT." & m_sMetaName & "." & sSuffix
	End Function


	'==============================================================================
	' ��������� ��������� ������� � ����
	Public Sub SaveFilterState
		Dim oXmlFilterState		' As IXMLDOMElement - ��������� �������
		
		If X_MD_PAGE_HAS_FILTER Then
			' �������� ������
			If m_bOffFilterViewState=False Then
				Set oXmlFilterState = FilterObject.GetXmlState()
				If Not oXmlFilterState Is Nothing Then _
					X_SaveDataCache GetUserDataName("FilterXmlState"), oXmlFilterState
			End If
		End If
	End Sub
	
	
	'==========================================================================
	' ������������� ��������
	' ���������� �� ���������� �������� (X_IsDocumentReady), � ��� ����� �������.
	Public Sub InitPage
		Dim aSuitableSelectionModes		' As Array - ������ �������������� �������
		Dim i
		'**************************************************************
		'  ��������� ������� ���������� ��������
		'**************************************************************
		' � DialogArguments ������� ��������� ������ SelectFromTreeDialogClass
		With X_GetDialogArguments(Null) 
			' ��������� ��� ���� �� ���������� ��������
			m_sLoader = "x-tree-loader.aspx?METANAME=" & .Metaname
			m_sMetaName 			= .Metaname
			Set x_oRightsCache 		= .GetRightsCache
			m_sTreeInitPath 		= .InitialPath
			Set m_oSelected 		= .InitialSelection
			Set m_oUrlArguments		= .UrlArguments
			m_sLoaderParams 		= .LoaderParams
			m_sExcludeNodes			= .ExcludeNodes
			m_sSelectionMode		= .SelectionMode
			m_sSelectableTypes 		= .SelectableTypes
			m_bSelectionCanBeEmpty	= .SelectionCanBeEmpty
			m_sSelectionEmptyMsg	= .SelectionEmptyMsg
			aSuitableSelectionModes = .SuitableSelectionModes
		End With
		m_oEventEngine.InitHandlers EVENTS, "usrXTreeSelector_On"
		' ����������� ����������� ��������� ������, ���� �� ����� ����������
		m_oEventEngine.InitHandlersEx EVENTS, "stdXTreeSelector_On", True, False

		m_sHelpPage = X_MD_HELP_PAGE_URL

		' ��������� ����� ��������. �� ����� ���� ����� ����������� �����������, ���� � ��������� ������ ����� ��������� (����������� ������)
		' �� ������ ������, �������� ��� ����� ������������ ������� �������������� caller'�� �������
		If Not hasValue(m_sSelectionMode) Then
			m_sSelectionMode = Empty
			If IsArray(aSuitableSelectionModes) Then
				For i=0 To UBound(aSuitableSelectionModes)
					If aSuitableSelectionModes(i) = TREE_SELECTOR_MODE Then
						m_sSelectionMode = TREE_SELECTOR_MODE
						Exit For
					End If
				Next
				If IsEmpty(m_sSelectionMode) And UBound(aSuitableSelectionModes) > -1 Then m_sSelectionMode = aSuitableSelectionModes(0)
			End If
			If IsEmpty(m_sSelectionMode) Then m_sSelectionMode = TREE_SELECTOR_MODE
		End If

		If IsEmpty(m_sSelectableTypes) Then
			m_sSelectableTypes = TREE_SELECTOR_NODETYPES
		End If
		If IsEmpty(m_bSelectionCanBeEmpty) Then
			m_bSelectionCanBeEmpty  = TREE_SELECTOR_SELECTION_CAN_BE_EMPTY
		End If
		If IsEmpty(m_sSelectionEmptyMsg) Then
			m_sSelectionEmptyMsg = TREE_SELECTOR_SELECTION_EMPTY_MSG
		End If
		
		Internal_InitializeHtmlControls
		m_oTreeView.Loader = m_sLoader
		m_oTreeView.SelectableTypes = m_sSelectableTypes
		Select Case m_sSelectionMode
			Case TSM_LEAFNODE
				m_oTreeView.IsOnlyLeafSel = true
				m_oTreeView.IsMultipleSel = false
			Case TSM_LEAFNODES
				m_oTreeView.IsOnlyLeafSel = true
				m_oTreeView.IsMultipleSel = true
			Case TSM_ANYNODE
				m_oTreeView.IsOnlyLeafSel = false
				m_oTreeView.IsMultipleSel = false
			Case TSM_ANYNODES 
				m_oTreeView.IsOnlyLeafSel = false
				m_oTreeView.IsMultipleSel = true
			Case Else
				Err.Raise -1, "TreeSelectorClass::InitPage", "����������� ����� �����������"
		End Select

		' ����������� �������:
		If X_MD_PAGE_HAS_FILTER Then
			' ���������������� ������ ����� ����� ������ ���� ������� ������
			m_oTreeView.AutoReloading = True
			
			InitFilters
		Else
			XTreeSelector.InitPageFinal
		End If
	End Sub


	'==========================================================================
	' �������������� ������ �� HTML ��������
	Public Sub Internal_InitializeHtmlControls
		Set m_oTreeView = document.all("oTreeView")
		If X_MD_PAGE_HAS_FILTER Then
			Set FilterObject = X_GetFilterObject( document.all( "FilterFrame") )
			Set xPaneFilter = document.all("XTree_xPaneFilter")
		End If
		Set NoDataMsg = document.all("XTree_ContentPlaceHolderForTree_NoDataMsg")
		Set TreeHolder = document.all("XTree_ContentPlaceHolderForTree_TreeHolder")
		Set xPaneHeader = document.all("XTree_xPaneHeader")
		Set xPaneCaption = document.all("XTree_xPaneCaption")
		Set xPaneSpecialCaption = document.all("XTree_xPaneSpecialCaption")
		
		If Not TREE_MD_OFF_RELOAD Then _
			Set cmdRefresh = document.all("XTree_cmdRefresh")
		If Not X_MD_OFF_CLEARFILTER Then _
			Set cmdClearFilter = document.all("XTree_cmdClearFilter")
		If Not X_MD_OFF_HIDEFILTER Then _
			Set cmdHideFilter = document.all("XTree_cmdHideFilter")
		Set cmdOK = document.all("XTree_cmdOk")
		Set cmdCancel = document.all("XTree_cmdCancel")
		Set xPaneAccessDenied = document.all("XTree_xPaneAccessDenied")
	End Sub
	
	
	'==========================================================================
	' ������������� ������� ��������
	Sub InitFilters()
		Dim oFilterXmlState		' As XMLDOMElement - ��������������� ��������� �������
		
		Dim oParams ' ��������� ������������� �������
		Set oParams = New FilterObjectInitializationParamsClass
		Set oParams.QueryString = UrlArguments
		Set oParams.OuterContainerPage = Me
		oParams.DisableContentScrolling = True
		m_bOffFilterViewState = X_MD_FILTER_OFF_VIEWSTATE
		
		If false = m_bOffFilterViewState Then
			If X_GetDataCache( GetUserDataName("FilterXmlState"), oFilterXmlState ) Then
				Set oParams.XmlState = oFilterXmlState
			End If
		End If
		
		Set m_oEventEngineFilter = X_CreateEventEngine
		m_oEventEngineFilter.AddHandlerForEvent "EnableControls", Me, "OnEnableControls"
		m_oEventEngineFilter.AddHandlerForEvent "Accel", Me, "OnAccel"
		' �������������� ������
		FilterObject.Init m_oEventEngineFilter, oParams
		' ������� �������� �������� � ���������� FilterObject
		X_WaitForTrue  "XTreeSelector.InitPageFinal", "FilterObject.IsReady"
	End Sub


	'==========================================================================
	' ���������� �������� ��������
	Public Sub InitPageFinal
		If (X_MD_PAGE_HAS_FILTER And TREE_MD_OFF_LOAD) Then
			NoDataMsg.innerHTML = "������� ������ &quot;<span title='������� ����� ��� ��������...' style='cursor: default;font-weight: bold;' language='VBSCript' onclick='ReloadTree'>��������</span>&quot; ��� ��������."
		End If
	
		m_oTreeView.Enabled = True
		' ���� �� ��������� ��������� ��������, �� ������ ������
		If Not TREE_MD_OFF_LOAD Then
			Reload
			Internal_FireEvent "SetInitPath", Nothing
		End If
		
		m_vDone = True
		
		EnableControls true
		
		' ����� �������� � ������������� ����� ��������� �����
		If UCase(TreeHolder.style.display) = "BLOCK" Then
			SetFocus
		Else
			NoDataMsg.focus
		End If
	End Sub


	'==========================================================================
	' ������������ ������
	Public Sub Reload
		' ��������� ���������� ����� URl-�������� RESTR ����������� ��������� �� ������� (�� GetRestrictions)
		m_oTreeView.Loader = m_sLoader & "&RESTR=" & XService.UrlEncode(m_sLoaderParams)
		m_bMayBeInterrupted = False
		With X_CreateControlsDisabler(Me)
			TreeHolder.style.display = "NONE"
			NoDataMsg.style.display = "BLOCK"
			NoDataMsg.innerText = "�������� ������..."
			XService.DoEvents
			
			On Error Resume Next
			m_oTreeView.Reload
			If Err Then
				X_SetLastServerError m_oTreeView.XClientService.LastServerError, Err.number, Err.Source, Err.Description
				If X_IsSecurityException(m_oTreeView.XClientService.LastServerError) Then
					NoDataMsg.innerText = "� ������� ��������..."
					Err.Clear
					MayBeInterrupted = True
					Exit Sub
				Else
					X_HandleError
				End If
			End If
			On Error GoTo 0
			
			If m_oTreeView.Root.Count = 0 Then
				NoDataMsg.innerText = "��� ������"
				Internal_FireEvent "Load", Nothing
				NoDataMsg.focus
			Else
				NoDataMsg.style.display = "NONE"
				TreeHolder.style.display = "BLOCK"
				XService.DoEvents
				If Not (m_oSelected Is Nothing) Then
					Set m_oTreeView.Selection =  m_oSelected
					m_oTreeView.ExpandSelection True
				End If
				Internal_FireEvent "Load", Nothing
				SetFocus
			End If
		End With
		m_bMayBeInterrupted = True
	End Sub
	
	
	'==========================================================================
	' ������������� ����� �� ������� ������
	Public Sub SetFocus
		window.focus
		X_SafeFocus(m_oTreeView)
	End Sub


	'==========================================================================
	' ���������� �������� ������� � ����������� �����������
	Public Sub Internal_FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub


	'==========================================================================
	' ������������� ��������� ��������
	'	[in] sCaption As String - ����� ���������. ����� ��������� HTML-��������������.
	Public Sub SetCaption(sCaption)
		Dim aCaption	' ����� ��������� � ���� ������� �����
		
		' ������ HTML-��� ���������...
		xPaneCaption.innerHTML = sCaption
		' ������� ��� "������" ����� � ���o���� �� ������ 
		aCaption = Split( "" & xPaneCaption.innerText, vbCr)
		' �������� ��������� ���� = ������ ������ ���������
		If UBound(aCaption)>=0 Then
			document.title = aCaption(0) 
		Else
			document.title = ""
		End If	
	End Sub
	
	
	'==========================================================================
	' ��������� ���������� ������ ������������
	' [in] bSlient - ������� "���������" ������ 
	Public Sub ProcessSelection(bSlient)
		Dim oSelection  '��������� �� ������
		
		Set oSelection = m_oTreeView.Selection
		If Not oSelection.hasChildNodes Then
			If  Not m_bSelectionCanBeEmpty Then
				If Not bSlient Then Alert m_sSelectionEmptyMsg
				Exit Sub 
			End If
		End If
		With New SelectEventArgsClass
			Set .Selection = oSelection
			.Silent = bSlient
			.ReturnValue = True
			Internal_FireEvent "Select", .Self()
			If .ReturnValue <> True Then Exit Sub
		End With
		With X_GetDialogArguments(Null) 
			Set .Selection = oSelection
			.Path = m_oTreeView.Path
			X_SetDialogWindowReturnValue True
		End With
		window.close
	End Sub	
	
	
	'==============================================================================
	' ����������/������������� ������� ���������� ���������� ��������� �������
	Public Property Get OffFilterViewState 	' As Boolean
		OffFilterViewState = m_bOffFilterViewState
	End Property
	Public Property Let OffFilterViewState(sValue)
		m_bOffFilterViewState = sValue=True
	End Property
	
	'==============================================================================
	' ����������/������������� ������ ����������� �����
	Public Property Get ExcludeNodes 	' As String
		ExcludeNodes = m_sExcludeNodes
	End Property
	Public Property Let ExcludeNodes(sValue)
		m_sExcludeNodes = sValue
	End Property
	
	
	'==============================================================================
	' ���������� ��������� CROC.IXTreeView
	Public Property Get TreeView
		Set TreeView = m_oTreeView
	End Property
	
	
	'==============================================================================
	' ������� ���������� �������� ��������	
	Public Property Get MayBeInterrupted
		If True = m_bMayBeInterrupted Then
			If X_MD_PAGE_HAS_FILTER Then
				MayBeInterrupted = not FilterObject.IsBusy
			Else
				MayBeInterrupted = True
			End If		
		Else
			MayBeInterrupted = False
		End If
	End Property
	Public Property Let MayBeInterrupted(bValue)
		m_bMayBeInterrupted = (true=bValue)
	End Property


	'==============================================================================
	'	��������� ����������� ��������� ����������
	Public Sub EnableControls(bEnable)
		m_oTreeView.Enabled = bEnable
		cmdOk.disabled = Not bEnable
		cmdCancel.disabled = Not bEnable
		If Not X_MD_OFF_CLEARFILTER Then _
			cmdClearFilter.disabled = Not bEnable
		If Not TREE_MD_OFF_RELOAD Then _
			cmdRefresh.disabled = Not bEnable
		If Not X_MD_OFF_HIDEFILTER Then _
			cmdHideFilter.disabled = Not bEnable
		If X_MD_PAGE_HAS_FILTER Then _
			FilterObject.Enabled = bEnable
	End Sub
	
	
	'==============================================================================
	' �������� ��������� �������: ������ ��� ��������
	Public Sub SwitchFilter()
		If X_MD_PAGE_HAS_FILTER Then
			If UCase(xPaneFilter.style.display) = "NONE" Then
				xPaneFilter.style.display = "block"
				FilterObject.SetVisibility True
				cmdHideFilter.innerText = "������"
				cmdHideFilter.title = "������ ������"
			Else
				xPaneFilter.style.display = "none"
				FilterObject.SetVisibility False
				cmdHideFilter.innerText = "��������"
				cmdHideFilter.title = "�������� ������"
			End If
		End If
	End Sub


	'==============================================================================
	' ���������� ������� EnableControls, ���������������� �������� (x-filter.htc)
	'	[in] oEventArgs - EnableControlsEventArgs
	Public Sub OnEnableControls(oSender, oEventArgs)
		EnableControls oEventArgs.Enable
	End Sub


	'==============================================================================
	' ���������� ������� Accel, ���������������� �������� (x-filter.htc)
	'	[in] oEventArgs - AccelerationEventArgsClass
	Public Sub OnAccel(oSender, oEventArgs)
		If oEventArgs.keyCode = VK_ENTER Then
			Reload
		End If
	End Sub
End Class


'==============================================================================
' ��������� ������� "Select"
Class SelectEventArgsClass
	Public Cancel				' As Boolean - ������� �������� ������� ��������� �������.
	Public ReturnValue			' As Booleab - ���� False, �� �������� �� �����������.
	Public Selection			' As IXMLDOMElement - IXTreeView::Selection
	Public Silent				' As Boolean - ������� ����� ������ (����� �� Enter'� ��� ���������)
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'<����������� window � document>
'==============================================================================
' ��������� ����������
Sub Document_onKeyPress()
	Select Case window.event.keyCode
		Case VK_ENTER	'Enter
			XTree_cmdOk_OnClick
		Case VK_ESC		'Esc
			XTree_cmdCancel_OnClick
	End Select
End Sub


'==============================================================================
' ������� �������� ��������
Sub window_OnBeforeUnload
	If IsNothing(g_XTreeSelectorInstance) Then Exit Sub
	If XTreeSelector.MayBeInterrupted Then Exit Sub
	window.event.returnValue = "��������!" & vbNewLine & "�������� �������� � ������ ������ ����� �������� � ������������� ������!"
End Sub


'==============================================================================
' ������������� ��������
Sub window_OnLoad
	X_WaitForTrue "XTreeSelector.InitPage()" , "X_IsDocumentReadyEx( null, ""XFilter"")"
End Sub


'==============================================================================
' �������� ����
Sub Window_OnUnLoad
	If IsNothing(g_XTreeSelectorInstance) Then Exit Sub
	' ��� ������������� ������� ���������������� ����������...
	XTreeSelector.Internal_FireEvent "UnLoad", Nothing
	XTreeSelector.SaveFilterState
End Sub


'==============================================================================
' ���������� ������ �������
Sub Document_OnHelp
	If IsNothing(g_XTreeSelectorInstance) Then Exit Sub
	If X_MD_HELP_AVAILABLE Then
		window.event.returnValue = False
		X_OpenHelp XTreeSelector.HelpPage
	End If
End Sub
'</����������� window � document>


'<����������� �������� TREEVIEW>
'==============================================================================
' ���������� ENTER
Sub	TreeView_OnKeyPress(oSender, nKeyAscii)
	If nKeyAscii <> VK_ENTER then exit sub
	If Not (XTreeSelector.SelectionMode = TSM_LEAFNODE or XTreeSelector.SelectionMode = TSM_ANYNODE) Then Exit Sub
	If Nothing Is oSender.ActiveNode Then Exit Sub
	If Not oSender.ActiveNode.IsLeaf Then Exit Sub
	If Not oSender.ActiveNode.IsSelectable Then Exit Sub
	' ���� ��� ����� Enter �� �������� ���������� ���� � ������ TSM_LEAFNODE ��� TSM_ANYNODE:
	XTreeSelector.ProcessSelection true	
End Sub


'==============================================================================
' ���������� DblClick
Sub TreeView_OnDblClick(oSender, oTreeNode)
	If Not (XTreeSelector.SelectionMode = TSM_LEAFNODE Or XTreeSelector.SelectionMode = TSM_ANYNODE) Then Exit Sub
	If Nothing Is oTreeNode Then Exit Sub
	If Not oTreeNode.IsLeaf Then Exit Sub
	If Not oTreeNode.IsSelectable Then Exit Sub
	XTreeSelector.ProcessSelection True
End Sub

'==============================================================================
' ���������� ������� OnDataLoading ��� TreeView.
'	������������ ��� ��������� � ������ �� ��������� ������
'	�������� ���������� �������.
Sub TreeView_OnDataLoading( oSender,  nQuerySet,  sNodePath,  sObjectType,  sObjectID,  oRestrictions)
	XTreeSelector.MayBeInterrupted = False
	internal_TreeInsertRestrictions oRestrictions, XTreeSelector.UrlArguments.QueryString
	internal_TreeInsertRestrictions oRestrictions, GetRestrictions
	internal_TreeSetExcludeNodes oRestrictions, XTreeSelector.ExcludeNodes
End Sub


'==============================================================================
' ���������� ������� OnDataLoaded ��� TreeView
Sub TreeView_OnDataLoaded( oSender, nQuerySet, sNodePath, sObjectType, sObjectID )
	XTreeSelector.MayBeInterrupted = True
End Sub
'</����������� �������� TREEVIEW>


'<����������� ������>
'==============================================================================
' ��������� ������� ������ OK
Sub XTree_cmdOK_OnClick
	XTreeSelector.ProcessSelection False
End Sub


'==============================================================================
' ��������� ������� ������ Cancel
Sub XTree_cmdCancel_OnClick
	window.close
End Sub


'==============================================================================
' ���������� ������� �� ������ "�������"
Sub XTree_cmdOpenHelp_OnClick
	Document_OnHelp
End Sub


'==============================================================================
'	������������
Sub XTree_cmdRefresh_OnClick
	If IsNothing(g_XTreeSelectorInstance) Then Exit Sub
	XTreeSelector.Reload
End Sub


'==============================================================================
'	����� �������� �������
Sub XTree_cmdClearFilter_OnClick
	If X_MD_PAGE_HAS_FILTER Then FilterObject.ClearRestrictions()
End Sub


'==============================================================================
' ���������� ������ "������"/"��������" ������
Sub XTree_cmdHideFilter_onClick()
	XTreeSelector.SwitchFilter()
End Sub
'<����������� ������>


'==============================================================================
' ���������� ������.
' ����������: �������� ��
Sub ReloadTree
	If IsNothing(g_XTreeSelectorInstance) Then Exit Sub
	XTreeSelector.Reload
End Sub


'==============================================================================
' ���������� ��������� ������� (������ �����������)
Function GetRestrictions()
	Dim oArguments		' As FilterObjectGetRestrictionsParamsClass
	Dim oBuilder		' As IParamCollectionBuilder
	If X_MD_PAGE_HAS_FILTER Then
		Set oArguments = New FilterObjectGetRestrictionsParamsClass
		Set oBuilder = New QueryStringParamCollectionBuilderClass
		Set oArguments.ParamCollectionBuilder = oBuilder
		FilterObject.GetRestrictions(oArguments)
		If False=oArguments.ReturnValue Then
			GetRestrictions = vbNullString
		Else
			GetRestrictions = oBuilder.QueryString
		End If	 	
	Else
		GetRestrictions = vbNullString
	End If	
End Function


'==============================================================================
'	��������� ����������� ��������� ����������
Sub EnableControls(bEnable)
	XTreeSelector.EnableControls bEnable
End Sub


'==============================================================================
' ����������� ���������� "SetInitPath" - ��������� ��������� ���� � ������, ��������� ���������� ��������
Sub stdXTreeSelector_OnSetInitPath(oSender, oEventArgs)
	oSender.TreeView.SetNearestPath oSender.InitialTreePath, False, True
End Sub
