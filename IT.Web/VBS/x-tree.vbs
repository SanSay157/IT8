'===============================================================================
'@@!!FILE_x-tree
'<GROUP !!SYMREF_VBS>
'<TITLE x-tree - ������� ������������ �������� ��������>
':����������:
'	����� ����� �������, �������� � �������, ������������ � ���������� 
'	����������� �������� ��������.
'===============================================================================
'@@!!CONSTANTS_x-tree
'<GROUP !!FILE_x-tree><TITLE ���������>
'@@!!FUNCTIONS_x-tree
'<GROUP !!FILE_x-tree><TITLE ������� � ���������>
'@@!!CLASSES_x-tree
'<GROUP !!FILE_x-tree><TITLE ������>

Option Explicit

'@@PANEL_MIN_WIDTH
'<GROUP !!CONSTANTS_x-tree>
':����������:   ���������� ���������� ������ ������ (�������� ��� ����)
const PANEL_MIN_WIDTH		= 5		' ���������� ���������� ������ ������  

'@@XTreePageClass
'<GROUP !!CLASSES_x-tree><TITLE XTreePageClass>
':����������:   ������������� ������ ������ �������� �������� ��������
'
'@@!!MEMBERTYPE_Methods_XTreePageClass
'<GROUP XTreePageClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_XTreePageClass
'<GROUP XTreePageClass><TITLE ��������>
Class XTreePageClass

	'@@XTreePageClass.HelpPage
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE HelpPage>
	':����������:	URL �������� ������
	':����������:	�������� �� ��������� - vbNullString
	':���������:	Public HelpPage [As String]
	Public HelpPage					' �������� ������

	'@@XTreePageClass.HelpAvailiabe
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE HelpAvailiabe>
	':����������:	������� ����������� ������ ��� ������ ��������
	':����������:	�������� �� ��������� - False
	':���������:	Public HelpAvailiabe [As Boolean]
	Public HelpAvailiabe

	'@@XTreePageClass.OffLoad
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE OffLoad>
	':����������:	������ �������� ������ ����� ����� ������������� ��������
	':����������:	�������� �� ��������� - False
	':���������:	Public OffLoad [As Boolean]
	Public OffLoad

	'@@XTreePageClass.OffShowReload
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE OffShowReload>
	':����������:	������ ������ ������ "��������"
	':����������:	�������� �� ��������� - False
	':���������:	Public OffShowReload [As Boolean]
	Public OffShowReload

	'@@XTreePageClass.AllowDragDrop
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE AllowDragDrop>
	':����������:	������� ����������� �������� �������� ����� ������ �����
	':����������:	�������� �� ��������� - False
	':���������:	Public AllowDragDrop [As Boolean]
    Public AllowDragDrop

	Public m_sLoading				' ������, � ������� �������� ��������� � ��������
	Public m_dSplitterPos			' ��������� ��������� � % (!!! �� �� ����� !!!)
	Public m_oMenuXSLCollection		' ��� XMLDOMDocument'�� XSL ������� ���� ����. ���� - ������������ level'a (����)
	Public m_oMenu					' ������ ����
	Public m_oMenuHTTP				' ������ MSXML2.XMLHTTP, ������������ ��� �������� ���� � �������
	Public m_oMenuCache				' ��� ����. ������ Dictionary
	Public m_sMenuXslDefault		' ������������ ����-��������� �� �������
	Public m_oMenuXslDefault		' XMLDOMDocument ����������� ��������� ����
	Public m_bMenuIsReady			' ������� ����������(�������������) ����
	Public m_bPendingRunDefaultMenuItem		' ������� ������������� ��������� ����� ���� �� ���������
	Public m_bPendingShowPopup		' ������� ������������� �������� PopUp ����
	Private m_bPendingShowPopupNearActiveNode	' ������� ���������� PopUp ����, ����� ��� ����������, ����� � �������� �����
	Public m_oXmlStatesPersist		' XMLDOMDocument ��� ���������� ��������� ����
	Public m_nTimeout				' ������� �������������� ��� ������ ���� �������
	Public m_oTreeMD				' ���������� ������
	Public m_oMenuSect				' ������ QueryString, � ������� �������� ��������� ������ ����

	Public m_sTreePath				' ���� � ���� ������  ���� type;id, ����������� "|" 
									'  ������������ ���� �� �����  �� ������� ����
	Public m_sTreeInitPath			' ���� � ���� ������, �������� � ������� ��������� INITPATH ��������

    Private m_oPageParams			' ������ QueryString, ���������� ��������� ��������
	Private m_sMetaName				' ��� �������� � ����������
	Private m_sMenuLoaderUrl		' ��� ������������� ������ (��. use-menu � ����������)
	Private m_oTreeView				' As CROC.IXTreeView - ������� ������
	Private EVENTS					' ������ �������������� �������
	Private m_oEventEngine			' As EventEngineClass
	Private m_bMayBeInterrupted 		' As Boolean - ������� ���������� �������� ��������
	Private m_oRequestingMenuTreeNode	' As IXTreeNode - �������� ���� �� ������ _������_ ������ ����
	Private m_bOffFilterViewState		' As Boolean	- ������� "�� ��������� ��������� �������"
	Private m_bAccessDenied			' ������� ������ "� ������� ��������"
	Private m_oEventEngineFilter	' As EventEngine - EventEngine ��� ��������� ������� �� ������� (���������� � x-filter.htc)
	Private m_oDragDropController   ' As TreeViewNodeDragDropController - ���������� �������� �������� ����� ������
	
	' HTML Controls
	Private xPaneFilter				' As IHTMLElement - ��������� �������
	Private xPaneHeader				' As IHTMLElement - ��������� ���������� � ������
	Private xPaneCaption			' As IHTMLElement - ���������
	Private xPaneSpecialCaption		' As IHTMLElement - �������������� ���������
	Private cmdHideFilter			' As IHTMLElement - ������ "������"/"��������" (������)
	Private cmdRefresh				' As IHTMLElement - ������ "��������"
	Private cmdClearFilter			' As IHTMLElement - ������ "��������" (������)
	Private idNormalTreeBody		' As IHTMLElement - TD - ������ � �������, ���� � ��������
	Private xPaneAccessDenied		' As IHTMLElement - TD - ������ � �������� �� ���������� �������
	Private TreeHolderCell			' As IHTMLElement - 
	Private TreeHolder				' As IHTMLElement - ��������� ��� ������ (CROC.IXTreeView)
	Private MenuHolder				' As IHTMLElement - ��������� ��� MenuHtml
	Private MenuHtml				' ������ �� DHTML Behavior XMenuHtml (x-menu-html.htc)
	
	'==============================================================================
	' "�����������" (���������� ������� ��������������� ������)
	Private Sub Class_Initialize
		Dim oQS					' ���� QueryString
		
		' ������������� ����������
		m_bAccessDenied = X_ACCESS_DENIED 
		'�������� ������� ����������� �������
		HelpAvailiabe = X_MD_HELP_AVAILABLE 
		' � URL �������� �������
		HelpPage = X_MD_HELP_PAGE_URL
		' ������� ���������� ��������
		OffLoad = TREE_MD_OFF_LOAD
		' ������� ���������� ������ ������ "��������"
		OffShowReload = TREE_MD_OFF_RELOAD
		' �������� �������� ��������� ���������
		m_dSplitterPos = TREE_MD_WIDTH
		' ������� ����������� �������� �������� �����
		AllowDragDrop = TREE_MD_ALLOW_DRAG_DROP

		m_bMayBeInterrupted = true
		
		' ��� ��� ������� �� ��� ��� ������ ������ 
		If m_bAccessDenied Then
			Exit Sub
		End If

		If IsObject(g_oXTreePage) Then _
			If Not g_oXTreePage Is Nothing Then _
				Err.Raise -1, "XTreePageClass::Class_Initialize", "��������� ������������� ������ ������ ���������� XTreePageClass"
		' �������������� ������ �� XTreeView. � html-�������� ������ ����� id oTreeView
		Set m_oTreeView = document.all("oTreeView")
		EVENTS = "BeforeEdit,Edit,AfterEdit," & _
			"BeforeCreate,Create,AfterCreate," & _
			"BeforeDelete,Delete,AfterDelete," & _
			"MenuBeforeShow,MenuUnLoad,MenuRendered,Load,Unload," & _
			"BeforeMove,Move,AfterMove,SelectParent," & _
			"SetInitPath"
		Set m_oEventEngine = X_CreateEventEngine
		' �������������� ��������� ������������ �������
		m_oEventEngine.InitHandlers EVENTS, "usrXTree_On"
		m_oEventEngine.InitHandlersEx EVENTS, "stdXTree_On", True, False
		
		m_sMetaName = X_PAGE_METANAME		
		
		Set m_oDragDropController = Nothing

        If AllowDragDrop Then
		    ' ������������� ����������� �������� ��������
		    Set m_oDragDropController = New TreeNodeDragDropController
		    m_oDragDropController.EventEngine.InitHandlers XTREENODEDRAGDROPCONTROLLER_EVENTS, "usrXTree_On"
		    m_oDragDropController.EventEngine.InitHandlersEx XTREENODEDRAGDROPCONTROLLER_EVENTS, "stdXTree_On", True, False
		End If
		
		'  ��������� ������� ���������� ��������
		Set m_oPageParams = X_GetQueryString()
		' ������ ��������� ���� ������
		m_sTreeInitPath = m_oPageParams.GetValue("INITPATH","")
		' ����������� ��������� �������� � ��������� ����������, ������� ��������
		Set oQS = m_oPageParams.Clone
		oQS.Remove "RET"
		oQS.Remove "HOME"
		oQS.Remove "INITPATH"
		m_bMenuIsReady = False
		m_bPendingRunDefaultMenuItem = False
		
		' ��������� ���������
		m_oTreeView.Loader = "x-tree-loader.aspx" & "?" & oQS.QueryString
		m_sLoading = "��������..."

		' �������� ���������� xsl-�������� ��� ���� ���� (����������)
		m_sMenuXslDefault = TREE_MD_MENUSTYLESHEET
		Set m_oMenuXslDefault = XService.XMLGetDocument()
		m_oMenuXslDefault.async = true
		m_oMenuXslDefault.load(XService.BaseURL() & "XSL\" & m_sMenuXslDefault)
		
		' �������� ������ � ��������� ���� (� m_oXmlStatesPersist)
		LoadMenuStates
		'�������� ��� ������������� ����
		m_sMenuLoaderUrl = "x-tree-menu.aspx?METANAME=" & m_sMetaName
		' ��������� ���������� ����
		Set m_oMenuXSLCollection = CreateObject("Scripting.Dictionary")
		' ��������� �������������� ����
		Set m_oMenuCache = CreateObject("Scripting.Dictionary")
		Set m_oMenu = Nothing
	End Sub

	'==============================================================================
	' �������������� ������
	Public Sub Internal_InitFilter
		Dim oFilterXmlState	' As XMLDOMElement - ��������������� ��������� �������
		Dim oParams 		' ��������� ������������� �������

		If X_ACCESS_DENIED Then Exit Sub		
		Set oParams = New FilterObjectInitializationParamsClass
		Set oParams.QueryString = QueryString
		Set oParams.OuterContainerPage = Me
		oParams.DisableContentScrolling = True
		
		m_bOffFilterViewState = X_MD_FILTER_OFF_VIEWSTATE

		' ����������� ��������� �������, ���� ��� �� ���������
		If m_bOffFilterViewState=False Then
			If X_GetDataCache( GetCacheFileName("FilterXmlState"), oFilterXmlState) Then
				Set oParams.XmlState = oFilterXmlState
			End If
		End If
		' �������������� ������
		Set m_oEventEngineFilter = X_CreateEventEngine
		m_oEventEngineFilter.AddHandlerForEvent "EnableControls", Me, "Internal_On_Filter_EnableControls"
		m_oEventEngineFilter.AddHandlerForEvent "Accel", Me, "Internal_On_Filter_Accel"
		m_oEventEngineFilter.AddHandlerForEvent "Apply", Me, "Internal_On_Filter_Apply"		
		g_oFilterObject.Init m_oEventEngineFilter, oParams
	End Sub

	'==============================================================================
	' ��������� ������������� ��������
	Public Sub Internal_InitPageFinal
		If X_ACCESS_DENIED Then Exit Sub
		EnableControls True
		Internal_FireEvent "Load", Nothing	
		ResizePanels()
		If Not OffLoad Then
			XService.DoEvents 
			MenuHtml.SetStatus "&nbsp;"
			Reload() 
			Internal_FireEvent "SetInitPath", Nothing
		Else
			MenuHtml.SetStatus "&nbsp;"
		End If
	End Sub

	'==========================================================================
	' �������������� ������ �� HTML ��������
	Public Sub Internal_InitializeHtmlControls
		If X_MD_PAGE_HAS_FILTER Then
			Set xPaneFilter = document.all("XTree_xPaneFilter")
		End If
		Set xPaneHeader = document.all("XTree_xPaneHeader")
		Set xPaneCaption = document.all("XTree_xPaneCaption")
		Set xPaneSpecialCaption = document.all("XTree_xPaneSpecialCaption")
		
		If Not TREE_MD_OFF_RELOAD Then _
			Set cmdRefresh = document.all("XTree_cmdRefresh")
		If Not X_MD_OFF_CLEARFILTER Then _
			Set cmdClearFilter = document.all("XTree_cmdClearFilter")
		If Not X_MD_OFF_HIDEFILTER Then _
			Set cmdHideFilter = document.all("XTree_cmdHideFilter")
		
		Set idNormalTreeBody = document.all("XTree_idNormalTreeBody")
		Set xPaneAccessDenied = document.all("XTree_xPaneAccessDenied")
		Set TreeHolderCell = document.all("XTree_TreeHolderCell")
		Set TreeHolder = document.all("TreeHolder")
		Set MenuHolder = document.all("XTree_MenuHolder")
		Set MenuHtml = document.all("MenuHtml")
	End Sub
	
	'==========================================================================
	' ���������� �������� ������
	'	[in] sEventName As String - ������������ �������
	'	[in] oEventArgs As Object - ��������� �������
	Public Sub Internal_FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub
	
	'==============================================================================
	' ��������� ������ � ��������� ����
	Private Sub LoadMenuStates
		Dim sMenuStates ' ������ ��������� ��������� ��������� ����
		Set m_oMenuSect = X_GetEmptyQueryString()
		If X_GetViewStateCache( GetCacheFileName("MenuStates"), sMenuStates) Then _
			m_oMenuSect.QueryString = sMenuStates
	End Sub

	'==============================================================================
	' ��������� ������ � ��������� ���� � �������
	Public Sub Internal_SaveStateOnUnload
		Dim oXmlFilterState ' As IXMLDOMElement, ��������� �������
		' �������� �� IsObject() ����� �� ������ �������� ������������� ��������
		' � ������ ������� ��� �������� ��������
		If IsObject(m_oMenuSect) Then _
			X_SaveViewStateCache GetCacheFileName("MenuStates"), m_oMenuSect.QueryString 
		
		If X_MD_PAGE_HAS_FILTER Then
			' �������� ������
			If m_bOffFilterViewState=False Then
				Set oXmlFilterState = g_oFilterObject.GetXmlState()
				If Not oXmlFilterState Is Nothing Then _
					X_SaveDataCache GetCacheFileName("FilterXmlState"), oXmlFilterState
			End If
		End If
	End Sub
	
	'==============================================================================
	'@@XTreePageClass.GetUserData
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE GetUserData>
	':����������:	��������� ������ �� ����������� ��������� �� ��������� �����
	':���������:
	'	[in] sKey As String   - ����
	'	[in] vData As Variant - ��������� 
	':���������:
	'	True - ������ �������, False - ���� �� ������
	':���������:	Public Function GetUserData(sKey, vData) [As Boolean]
	Public Function GetUserData(sKey, vData)
		GetUserData = XService.GetUserData( GetCacheFileName(sKey), vData)
	End Function 

	'==============================================================================
	'@@XTreePageClass.SetUserData
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE SetUserData>
	':����������:	��������� ������ � ���������� ��������� �� ��������� �����
	':���������:
	'	[in] sKey As String   - ����
	'	[in] vData As Variant - ������ ��� ���������� � ���������
	':���������:	Public Sub SetUserData(sKey, vData)
	Public Sub SetUserData(sKey, vData)
		XService.SetUserData GetCacheFileName(sKey), vData
	End Sub

	'==============================================================================
	' ���������� ��� ����� ��� ���������� ���������������� ������
	'	[in] sSuffix - ������ �����
	'	[retval] ������������ �����
	Private Function GetCacheFileName(sSuffix)
		GetCacheFileName = "XT." & MetaName & "." & sSuffix
	End Function

	'==============================================================================
	' ���������� popup-���� ��� �������� ���� ������
	' � ������� �������� �� ������������ ��� ������ �� ����������� ����
	Public Sub ShowPopupMenu
		If m_bMenuIsReady = False Then Exit Sub
		m_oMenu.ShowPopupMenu Me
	End Sub
	
	'==============================================================================
	' ���������� popup-���� ����� � �������� �����
	Public Sub Internal_ShowPopupMenuNearActiveNode
		Dim nPosLeft, nPosTop, nPosRight, nPosBottom	' ������������� ���������� ��������� ������ ������
		Dim nTreeViewPosX, nTreeViewPosY	' �������� ���������� TreeView
		Dim nPendingMenuPosX				'- �������� �-���������� ����� ������ PopUp ����, ����� ���� ��� ��� ����� ���������
		Dim nPendingMenuPosY				'- �������� Y-���������� ����� ������ PopUp ����, ����� ���� ��� ��� ����� ���������
		
		If TreeView.ActiveNode.GetCoords(nPosLeft, nPosTop, nPosRight, nPosBottom) Then
			X_GetHtmlElementScreenPos TreeView, nTreeViewPosX, nTreeViewPosY
			nPendingMenuPosX = nTreeViewPosX+nPosLeft
			nPendingMenuPosY = nTreeViewPosY+nPosBottom
		End If
		m_oMenu.ShowPopupMenuWithPos Me, nPendingMenuPosX, nPendingMenuPosY
	End Sub
	
	'==============================================================================
	' ����� ������ ���� �� ���������...
	' � ������� �������� �� ������������ ��� ������ �� ����������� ����
	Public Sub CallMenuDefaultItem
		Dim oMenuAction		' ����� ���� �� ���������

		If m_bMenuIsReady = False Then Exit Sub
		m_bPendingRunDefaultMenuItem = False
		' ������ �������, �� ��������������� ����� ����, ���������� ������ "����� �� ���������"
		Set oMenuAction = m_oMenu.XmlMenu.selectSingleNode("//i:menu-item[@default=1 and not(@hidden) and not(@disabled)]")
		If oMenuAction Is Nothing Then
			' ���� �� ����� ����� ���� ���������� ��� ����������, �� ������ ������� ������
			Set oMenuAction = m_oMenu.XmlMenu.selectSingleNode("//i:menu-item[not(@hidden) and not(@disabled)]")
		End If
		If Not oMenuAction Is Nothing Then
			' ����� - ��������
			m_oMenu.RunExecutionHandlers Me, oMenuAction.getAttribute("n")
		End If
	End Sub
	
	'==============================================================================
	' �������� ��������� �������� ����. ���������� ������� "MenuUnLoad" � �� �������� �������� ShowMenuNow.
	' ������� ����� ��� ����, ����� ��� ������� ������������ ����� ���� �� ���������.
	' � ������� �������� �� ������������ ��� ������ �� ����������� ����.
	Public Sub ShowMenu()
		Const MENU_TIMEOUT  = 1000  ' ����� ����� ������� ����
		m_bPendingRunDefaultMenuItem = False
		m_bMenuIsReady = False
		If False=IsEmpty(m_nTimeout) Then
			clearTimeout m_nTimeout
			m_nTimeout=Empty
			Internal_FireEvent "MenuUnLoad", Nothing
		End If	
		m_nTimeout = setTimeout( "g_oXTreePage.BeginShowMenu()", MENU_TIMEOUT, "VBScript")
		MenuHtml.SetStatus m_sLoading
	End Sub

	'==============================================================================
	' ������� � ���������� Xml-������ �� ��������� ���� (��� x-tree-menu.aspx).
	' � ������� �������� �� ������������ ��� ������ �� ����������� ����.
	Public Function CreateMenuRequest	' As XMLDOMElement
		Dim oNode			'  XMLDOMNode
		Dim oMenuPostData	'  ������, ���������� ����
		Dim aPath			'  ���� �� ����
		Dim i
		' �������� ������ ��� ������� ������
		Set oMenuPostData = XService.XMLGetDocument
		oMenuPostData.async = False
		oMenuPostData.appendChild oMenuPostData.createProcessingInstruction("xml","version=""1.0"" encoding=""windows-1251""") 
		oMenuPostData.appendChild oMenuPostData.createElement("tree-menu-request")
		Set oNode = oMenuPostData.documentElement
		aPath = Split( m_sTreePath, "|")
		For i=0 To UBound(aPath) Step 2
			set oNode = oNode.appendChild(oMenuPostData.createElement("n"))
			oNode.setAttribute "ot", aPath(i)
			oNode.setAttribute "id", aPath(i+1)
		Next
		Set oNode = oMenuPostData.documentElement.appendChild(oMenuPostData.createElement("restrictions"))
		
		internal_TreeInsertRestrictions oNode, GetRestrictions
		Set CreateMenuRequest = oMenuPostData
	End Function

	'==============================================================================
	' �������� ��������� ����. ���������� �� ����-����, �������������� � ShowMenu. 
	' ����� �� ������ ���������� ��������.
	Public Sub BeginShowMenu()
		Dim sMenuLoaderUrl		' ��� �������� ��������� ���� (x-tree-menu.aspx)
		Dim aPath				' ���� �� ����
		Dim oMenuCached			' �������������� ����
		Dim oMenuPostData		' ���� tree-menu-request ��� ������� �� ������
		Dim sKeyPath			' ���� � ���� ���� - ���� �� ����� �� �������� ����
		Dim sKeyType			' ���� � ���� ���� - ��� �������� ����
		Dim bIsEmptyMenu		' ������� ������� ����
		
		' ��� ������������� ������� �� ����-���� �� ShowMenu?
		If IsEmpty(m_nTimeout) Then Exit Sub
		clearTimeout m_nTimeout
		Set m_oRequestingMenuTreeNode = m_oTreeView.ActiveNode
		' �������� URL ����
		aPath = Split( m_sTreePath,"|")
		If UBound(aPath) < 1 Then 
			MenuHtml.SetStatus "&nbsp;"
			bIsEmptyMenu = (0 = m_oTreeView.Root.Count)
		Else
			bIsEmptyMenu = false
		End If	

		m_bMenuIsReady = False
		' ���� ���������� ���� �� �����������, ������� ���
		If IsObject(m_oMenuHTTP) Then m_oMenuHTTP.abort
		' ��������, ��� ���� �������� ���� �����������, ���� ���, �� ������� �� ���� � ������� EndShowMenu
		If Not m_oTreeView.ActiveNode Is Nothing Then
			Set oMenuCached = Nothing
			sKeyPath = "path:" & GetPathOfTypes()
			sKeyType = "type:" & m_oTreeView.ActiveNode.Type
			If m_oMenuCache.Exists(sKeyPath ) Then
				Set oMenuCached = m_oMenuCache.Item( sKeyPath )
			ElseIf m_oMenuCache.Exists( sKeyType ) Then
				Set oMenuCached = m_oMenuCache.Item( sKeyType )
			End If
			If Not oMenuCached Is Nothing Then
				' ����� �������������� ����
				EndShowMenu oMenuCached
				Exit Sub
			End If
		End If
		' ��������������� ���� ���
		' �������� xml-������ ���������� ����
		Set oMenuPostData = CreateMenuRequest()
		If(bIsEmptyMenu) Then
			' ��������� ������� ����, ��� ��������� ���� ��� ������� ������
			oMenuPostData.documentElement.setAttribute "for-empty-tree", "1"
		End If		
		' �������� ������ ��� ����������� �������� xml
		Set m_oMenuHTTP = CreateObject( "Msxml2.XMLHTTP")
		' ��������� URL ����
		sMenuLoaderUrl = m_sMenuLoaderUrl & "&tm=" & CDbl(Now)
		' ������ ������ �� ������ ���������� (true � 3-� ���������)
		m_oMenuHTTP.open "POST", sMenuLoaderUrl, true
		' �� ��������� ������ ������� ProcessMenuXML
		m_oMenuHTTP.onreadystatechange = GetRef("ProcessMenuXML")
		m_oMenuHTTP.send oMenuPostData 		
	End Sub

	'==============================================================================
	' ����������� ������������ ����. �� ���� ��������� �������� ���� menu xml-����.
	' ������� ��������� ������ MenuClass, ������������� ����������� �����������, 
	' ��������� ���������������� ����� �������� � ���������
	'	[in] oMenuXML - xml-���� (��������������, ���� ���������� � ������� �� m_oMenuHTTP)
	' � ������� �������� �� ������������ ��� ������ �� ����������� ����
	Public Sub EndShowMenu(oMenuXML)
		Dim sKey		' ���� � ���� ����
		Dim oMenuXSL	' XMLDOMDocument Xslt-���������

		If IsObject(m_oRequestingMenuTreeNode) Then
			 If Not (m_oRequestingMenuTreeNode Is m_oTreeView.ActiveNode) Then Exit Sub
		End If
		' �������� ������ ���� � ��������� ����������� �����������
		Set m_oMenu = New MenuClass		
		m_oMenu.SetMacrosResolver X_CreateDelegate(Me, "MenuMacrosResolver")
		m_oMenu.SetVisibilityHandler X_CreateDelegate(Me, "MenuVisibilityHandler")
		m_oMenu.SetExecutionHandler X_CreateDelegate(Me, "MenuExecutionHandler")
		m_oMenu.Init oMenuXML
		' ���� ����� ���������� ����. ���������� ��������� cache-for �������� �������� menu
		If Not IsNull(oMenuXML.getAttribute("cache-for")) And Not m_oTreeView.ActiveNode Is Nothing Then
			If oMenuXML.getAttribute("cache-for") = "type" Then
				sKey = "type:" & m_oTreeView.ActiveNode.Type
			ElseIf oMenuXML.getAttribute("cache-for") = "level" Then
				sKey = "path:" & GetPathOfTypes()
			End If
			Set m_oMenuCache.Item(sKey) = oMenuXML
		End If
		' �������������, ��� � ��������� ���� ���������������� ����� ����������: ObjectID, ObjectType
		If Not m_oMenu.Macros.Exists("ObjectID") Then _
			m_oMenu.Macros.Add "ObjectID", Null
		If Not m_oMenu.Macros.Exists("ObjectType") Then _
			m_oMenu.Macros.Add "ObjectType", Null
			
		' ������� ������ XSLT-�������� ��� ���������� �� ��� ������������
		' ���� m_oMenu.MenuXslTemplate ������ ������, �� GetXsl ������ ������ �� ���������
		Set oMenuXSL = GetXsl( m_oMenu.MenuXslTemplate )
		
		' ����������� ������� ����� ���������� ����, ������� ���� ������ �� ���� � xsl-������
		' ���������� ��� ����� �������������� ������ ���� �/��� ������������ ������ ��� ����������
		If m_oEventEngine.IsHandlerExists("MenuBeforeShow") Then
			With New TreeMenuEventArgsClass
				Set .Menu = m_oMenu
				Set .MenuXsl = oMenuXSL
				Internal_FireEvent "MenuBeforeShow", .Self
				Set oMenuXSL = .MenuXsl
			End With
		End If
		
		' ���������� ���� � HTML. 
		MenuHtml.Render Me, m_oMenu, oMenuXSL
		
		m_bMenuIsReady = True
		' �������������� ����� ��������� ���� � HTML
		ProcessMenuHTML
		
		' ����� ������ ���� ����������� �������, 
		' ����� ���������� ��� ��� ���������� ��� ���������� ������������� ����������
		If m_oEventEngine.IsHandlerExists("MenuRendered") Then
			With New TreeMenuEventArgsClass
				Set .Menu = m_oMenu
				Internal_FireEvent "MenuRendered", .Self
			End With
		End If
		
		PostProcessMenu
	End Sub

	'==============================================================================
	' ������������� ����, �������������� HTML
	Private Sub ProcessMenuHTML()
		Dim aIDs				' ������ ��������������� ������ ����
		Dim sID					' ������������� ������ ����
		Dim sMode				' ������� ���������� ������
		Dim oSectionTHEAD	    ' ��������� ������ ���� (HTML_THEAD_Element) 	

		' ������������ ������ ���� (��������/����������) � ����������� �� ���������
		aIDs = m_oMenuSect.Names()
		' �� ���� ���������� � m_oMenuSect
		For Each sID In aIDs
			' �������� �������� ������ ����		
			Set oSectionTHEAD = MenuHtml.Html.all(sID)
			If Not (oSectionTHEAD Is Nothing) Then
				'� � ������ ������ ���������� ��� �������� ������ ������
				sMode = CStr(m_oMenuSect.GetValue(sID, oSectionTHEAD.ExtendedIsCollapsed))
				SetMenuSectionState oSectionTHEAD, sMode
			End If	
		Next
	End Sub

	'==============================================================================
	' ������������� ����. ������������ ����-����� � ����� ������������ ����, ������� ���� ������� ����� ���� ��� �� ���� ������������
	Private Sub PostProcessMenu
		Const MENU_ITEM_DELAY  = 10		' �������� ����� ����������� ������ ���� "�� ���������"

		If m_bPendingRunDefaultMenuItem Then
			' ��� �������� �� �������� �������� - ���� ��������� ����� �� ���������
			m_bPendingRunDefaultMenuItem = False 
			' �������� �� ����������� ��������� ��������� IXMLDomDocument ��������� ��� ������ !!!
			' ������� ������� ���������� �� ��������� ���������� � �������� ����� �� ����� �����������...
			window.setTimeout "g_oXTreePage.CallMenuDefaultItem", MENU_ITEM_DELAY, "VBScript"
		ElseIf m_bPendingShowPopup Then
			' �������� ������ ������ ���� - ������� �� popup-����
			m_bPendingShowPopup = False
			' �������� �� ����������� ��������� ��������� IXMLDomDocument ��������� ��� ������ !!!
			' ������� ������� ���������� �� ��������� ���������� � �������� ����� �� ����� �����������...
			If m_bPendingShowPopupNearActiveNode Then
				m_bPendingShowPopupNearActiveNode = False
				window.setTimeout "g_oXTreePage.Internal_ShowPopupMenuNearActiveNode", MENU_ITEM_DELAY, "VBScript"
			Else
				window.setTimeout "g_oXTreePage.ShowPopupMenu", MENU_ITEM_DELAY, "VBScript"
			End If
		End If	
	End Sub

	'==============================================================================
	'@@XTreePageClass.GetPathOfTypes
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE GetPathOfTypes>
	':����������:	���������� ���� �� �������� ����, � ������� ����������� ������ ���� �����. 
	':���������:	Public Function GetPathOfTypes()	' As String
	Public Function GetPathOfTypes()	' As String
		Dim aPath	' ������ ������ ����
		Dim sPath	' ����������� ����
		Dim i
		
		aPath = Split( m_sTreePath,"|")
		For i=0 To Ubound(aPath) Step 2
			If Len(sPath) > 0 Then sPath = sPath & "|"
			sPath = sPath & aPath(i)
		Next
		GetPathOfTypes = sPath
	End Function

	'==============================================================================
	'@@XTreePageClass.RunMenuExecutionHandlers
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE RunMenuExecutionHandlers>
	':����������:	��������� ����������� ������ ������ ���� ��� ��������� action'a
	':���������:
	'	[in] sCmd As String	- ������������ ������ ���� (menu-item/@n)
	':���������:	Public Sub RunMenuExecutionHandlers(sCmd)
	Public Sub RunMenuExecutionHandlers(sCmd)
		if Not m_oMenu Is Nothing Then
			m_oMenu.RunExecutionHandlers Me, sCmd
		End If
	End Sub

	'==============================================================================
	' ���������� ���� ��� ������� ������
	' � ������� �������� �� ������������ ��� ������ �� ����������� ����, ��� �������� ������������� � ������ �����.
	Public Sub ShowMenuForEmptyTree
		ShowMenu
	End Sub

	'==============================================================================
	'@@XTreePageClass.TreeView
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE TreeView>
	':����������:	���������� ��������� CROC.IXTreeView
	':���������:	Public Property Get TreeView [As IXTreeView]
	Public Property Get TreeView
		Set TreeView = m_oTreeView
	End Property
	
	'==============================================================================
	'@@XTreePageClass.DragDropController
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE DragDropController>
	':����������:	���������� ���������� �������� �������� ����� ������
	':����������:	���� � �������� ��������� �������� �������� ����� ����� (AllowDragDrop = false), �������� ������ Nothing
	':���������:	Public Property Get DragDropController [As TreeNodeDragDropController]
	Public Property Get DragDropController
		Set DragDropController = m_oDragDropController
	End Property
	
	'==============================================================================
	'@@XTreePageClass.XmlMenu
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE XmlMenu>
	':����������:	���������� XML ���� ���� ������
	':����������:	���� � ������� ������ ���� ����������, �������� ������ Nothing
	':���������:	Public Property Get XmlMenu [As IXMLDOMElement]
	Public Property Get XmlMenu
		If Not m_oMenu Is Nothing Then
			Set XmlMenu = m_oMenu.XmlMenu
		Else
			Set XmlMenu = Nothing
		End If
	End Property

	'==============================================================================
	'@@XTreePageClass.MenuDefaultStylesheet
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE MenuDefaultStylesheet>
	':����������:	���������� XSLT-������ �� ��������� ��� ���������� ����
	':���������:	Public Property Get MenuDefaultStylesheet [As XMLDOMDocument]
	Public Property Get MenuDefaultStylesheet
		Set MenuDefaultStylesheet = m_oMenuXslDefault
	End Property
	
	'==============================================================================
	'@@XTreePageClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE QueryString>
	':����������:	���������� ������ � ����������� ��������
	':���������:	Public Property Get QueryString [As QueryStringClass]
	Public Property Get QueryString
		Set QueryString = m_oPageParams
	End Property

	'==============================================================================
	'@@XTreePageClass.MetaName
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE MetaName>
	':����������:	���������� ������� ������
	':���������:	Public Property Get MetaName [As String]
	Public Property Get MetaName
		MetaName = m_sMetaName
	End Property
	
	'==============================================================================
	' ���������� ���������� ������
	' ��� ������ ������ �������� ��������� �������� ��������� ���������� � �������� ���������
	' ����������: ��� �������� ���������������� ������ ���������� �� �����, ������� �� ������ ��� ��� ���������� �������� �� ����������
	Public Function GetTreeMD	' As IXMLDOMElement
		If IsEmpty(m_oTreeMD) Then
			Set m_oTreeMD = X_GetTreeMD(m_sMetaname)
		End If
		Set GetTreeMD = m_oTreeMD
	End Function

	'==============================================================================
	'@@XTreePageClass.MayBeInterrupted
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE MayBeInterrupted>
	':����������:	���������� ������� ���������� �������� ��������
	':���������:	Public Property Get MayBeInterrupted [As Boolean]
	Public Property Get MayBeInterrupted
		If true=m_bMayBeInterrupted Then
			If X_MD_PAGE_HAS_FILTER Then
				MayBeInterrupted = not g_oFilterObject.IsBusy
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
	'@@XTreePageClass.OffFilterViewState
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE OffFilterViewState>
	':����������:	����������/������������� ������� ���������� ���������� ��������� �������
	':���������:	Public Property Get/Let OffFilterViewState [As Boolean]
	Public Property Get OffFilterViewState 	' As Boolean
		OffFilterViewState = m_bOffFilterViewState
	End Property
	Public Property Let OffFilterViewState(sValue)
		m_bOffFilterViewState = sValue=True
	End Property

	'==============================================================================
	'@@XTreePageClass.Reload
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE Reload>
	':����������:	����/��������� ������
	':���������:	Public Sub Reload
	Public Sub Reload
		If m_bAccessDenied Then Exit Sub
		MenuHtml.SetStatus "&nbsp;"
		on error resume next	
		EnableControls False
		m_oTreeView.Reload
		If Err Then
			MayBeInterrupted = True
			X_SetLastServerError m_oTreeView.XClientService.LastServerError, Err.number, Err.Source, Err.Description
			If X_IsSecurityException(m_oTreeView.XClientService.LastServerError) Then
				idNormalTreeBody.style.display = "none"
				xPaneAccessDenied.style.display = "block"
				ReportStatus "� ������� ��������..."
				TreeHolder.style.display = "none"
				m_bAccessDenied = True
				Err.Clear
			Else
				X_HandleError
			End If
			EnableControls True
			Exit Sub
		End If
		If 0<>len( m_sTreePath) Then
			m_oTreeView.SetNearestPath m_sTreePath, False, True
		End If
		EnableControls True
		m_oTreeView.focus
		Err.Clear
	End Sub

	'==============================================================================
	'@@XTreePageClass.MenuMacrosResolver
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE MenuMacrosResolver>
	':����������: ����������� �������� �������� ����.
	':����������: ����������� �������� ��������� ��������:
	'	ObjectID	- ������������� ���������� ����; 
	'	ObjectType	- ������������ ���� ���������� ����; 
	'	RefreshFlags- ����� ���������� ���� ����� �������� ��� ���; 
	'	IsLeaf		- ������� ��������� ����; 
	'	Title		- ������������ ����; 
	'	��� ������� �� ApplicationData ���������� ����
	':���������: Public Sub MenuMacrosResolver(
	'               oSender [as MenuClass], 
	'               oEventArgs [as MenuEventArgsClass])
	':���������: 
	'   oSender -
	'       [in] ������, ��������������� �������, ��������� ������ MenuClass
	'   oEventArgs - 
	'       [in] ��������� �������, ��������� MenuEventArgsClass
	Public Sub MenuMacrosResolver(oSender, oEventArgs)
		Dim oNode	' xml-���� ���������������� ���������� �� ApplicationData ��������� ���� ������
		If Not m_oTreeView.ActiveNode Is Nothing Then
			m_oMenu.Macros.Item("ObjectID") = m_oTreeView.ActiveNode.ID
			m_oMenu.Macros.Item("ObjectType") = m_oTreeView.ActiveNode.Type
			m_oMenu.Macros.Item("RefreshFlags") = Empty
			m_oMenu.Macros.Item("IsLeaf") = m_oTreeView.ActiveNode.IsLeaf
			m_oMenu.Macros.Item("Title") = m_oTreeView.ActiveNode.text
			If Not m_oTreeView.ActiveNode.ApplicationData Is Nothing Then
				For Each oNode In m_oTreeView.ActiveNode.ApplicationData.selectNodes("ud/*")
					m_oMenu.Macros.Item(oNode.tagName) = oNode.text
				Next
			End If
		End If
	End Sub
	 
	'==============================================================================
	'@@XTreePageClass.MenuVisibilityHandler
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE MenuVisibilityHandler>
	':����������: ����������� ���������� ��������� �����������/��������� ������� ����. ����������� �������� ����������� ����������� ������� ����. 
	':���������: Public Sub MenuVisibilityHandler(
	'       oSender [as MenuClass], 
	'       oEventArgs [as MenuEventArgsClass]
	'       )
	':���������: 
	'    oSender -
	'       [in] ������, ��������������� �������, ��������� ������ MenuClass
	'    oEventArgs - 
	'       [in] ��������� �������, ��������� MenuEventArgsClass
	Public Sub MenuVisibilityHandler(oSender, oEventArgs)
		Dim oMenu			' As MenuClass
		Dim sGUID			' ������������� ���������� �������
		Dim sType			' ��� ���������� �������
		Dim bDisabled		' ������� ����������������� ������
		Dim bHidden			' ������� �������� ������
		Dim oNode			' ������� menu-item
		Dim oList			' As ObjectArrayListClass - ������ �������� XObjectPermission
		Dim oParam			' As IXMLDOMElement - ���� param � ���������� ���� 
		Dim bProcess		' As Boolean - ������� ��������� �������� ������
		Dim bTrustworthy	' ������� "�������������� �������" ���� - ��� ��� ������ �� ���� ��������� �������� ����
		
		Set oMenu = oEventArgs.Menu
		Set oList = New ObjectArrayListClass
		bTrustworthy = Not IsNull(oMenu.XmlMenu.getAttribute("trustworthy"))
		' ���������� ������ ��������� ��� ��������
		For Each oNode In oEventArgs.ActiveMenuItems
			bHidden = Empty
			bDisabled = Empty
			bProcess = False
			sGUID = oMenu.Macros.item("ObjectID")
			sType = oMenu.Macros.item("ObjectType")
			' �� ���� ���������� ������ ����
			For Each oParam In oNode.selectNodes("*[local-name()='params']/*[local-name()='param']")
				' ���� ����� ��������� ObjectType �/��� ObjectID, �� ������������� ��� �/��� OID (��� �������� ����)
				If StrComp(oParam.getAttribute("n"), "ObjectType", vbTextCompare)=0 Then
					sType = oParam.text
				ElseIf StrComp(oParam.getAttribute("n"), "ObjectID", vbTextCompare)=0 Then
					sGUID = oParam.text
				End If
			Next
			' ��������� �������� �� ������ ����, ����� oMenu.SetMenuItemsAccessRights ���� ������� ������� �� �������� ���� � ������ ���� (��� ������������ ����� disabled)
			' ���� ���� "����������� �������", �� ������ �������� ��� ����������
			If Not bTrustworthy Then 
				If Not IsNull(sType) Then _
					oNode.setAttribute "type", sType
				If Not IsNull(sGUID) Then _
					oNode.setAttribute "oid", sGUID
			End If
			
			Select Case oNode.getAttribute("action")
				Case CMD_ADD: 			' "DoCreate"
					If Not bTrustworthy Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CREATE, sType, Empty)
					bProcess = True
				Case CMD_VIEW: 			' "DoView"
					bHidden = IsNull(sGUID)
					bProcess = True
				Case CMD_EDIT: 			' "DoEdit"
					bHidden = IsNull(sGUID)
					If Not bHidden And Not bTrustworthy Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CHANGE, sType, sGUID)
					bProcess = True
				Case CMD_DELETE: 		' "DoDelete"
					bHidden = IsNull(sGUID)
					If Not bHidden And Not bTrustworthy Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_DELETE, sType, sGUID)
					bProcess = True
				Case CMD_HELP 			' "DoHelp"
					bHidden = Not HelpAvailiabe
					bProcess = True
				Case CMD_MOVE 			' "DoMove"
					bHidden = IsNull(sGUID)
					bProcess = True
				Case CMD_NODEREFRESH 	' "DoNodeRefresh"
					bHidden = IsNull(sGUID)
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
			oMenu.SetMenuItemsAccessRights oList.GetArray()
		End If
		If X_IsDebugMode Then
			Set oNode = oMenu.XmlMenu.ownerDocument.createElement("menu-item")
			oNode.setAttribute "action", "DebugShowMenuXml"
			oNode.setAttribute "t", "Debug: XmlMenu"
			oNode.setAttribute "n", "DebugShowMenuXml"
			oMenu.XmlMenu.appendChild oNode
			Set oNode = oMenu.XmlMenu.ownerDocument.createElement("menu-item")
			oNode.setAttribute "action", "DebugActiveNodeType"
			oNode.setAttribute "t", "Debug: ��� ���������� ����"
			oNode.setAttribute "n", "DebugActiveNodeType"
			oMenu.XmlMenu.appendChild oNode
			Set oNode = oMenu.XmlMenu.ownerDocument.createElement("menu-item")
			oNode.setAttribute "action", "DebugActiveNodeOID"
			oNode.setAttribute "t", "Debug: ���������� ������������� ���������� ���� � ����� ������"
			oNode.setAttribute "n", "DebugActiveNodeOID"
			oMenu.XmlMenu.appendChild oNode
			Set oNode = oMenu.XmlMenu.ownerDocument.createElement("menu-item")
			oNode.setAttribute "action", "DebugActiveNodeIconSelector"
			oNode.setAttribute "t", "Debug: �������� ������"
			oNode.setAttribute "n", "DebugActiveNodeIconSelector"
			oMenu.XmlMenu.appendChild oNode
			Set oNode = oMenu.XmlMenu.ownerDocument.createElement("menu-item")
			oNode.setAttribute "action", "DebugActiveNodeAppData"
			oNode.setAttribute "t", "Debug: �������������� ������ ���������� ����"
			oNode.setAttribute "n", "DebugActiveNodeAppData"
			oMenu.XmlMenu.appendChild oNode
			Set oNode = oMenu.XmlMenu.ownerDocument.createElement("menu-item")
			oNode.setAttribute "action", "DebugActiveNodePath"
			oNode.setAttribute "t", "Debug: ���� �� ���������� ����"
			oNode.setAttribute "n", "DebugActiveNodePath"
			oMenu.XmlMenu.appendChild oNode
		End If
	End Sub
	
	'==============================================================================
	'@@XTreePageClass.MenuExecutionHandler
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE MenuExecutionHandler>
	':����������: ����������� ���������� ���������� ��������� ������� ����.
	':���������: Public Sub MenuExecutionHandler(
	'       oSender [as MenuClass], 
	'       oEventArgs [as MenuExecuteEventArgsClass]
	'       )
	':���������: 
	'    oSender -
	'       [in] ������, ��������������� �������, ��������� ������ MenuClass
	'    oEventArgs - 
	'       [in] ��������� �������, ��������� MenuExecuteEventArgsClass
	Public Sub MenuExecutionHandler(oSender, oEventArgs)
		Dim oMenu		' As MenuClass
		Dim sGUID		' ������������� ���������� �������
		
		Set oMenu = oEventArgs.Menu
		sGUID = oMenu.Macros.item("ObjectID")
		' ��������� ����� ���������� ����� ����������� �������� �� ��������� (�.�. ���� ����� �� ������ � i:params)
		If Not hasValue(oMenu.Macros.Item("RefreshFlags")) Then
			Select Case oEventArgs.Action
				Case CMD_ADD:
					oMenu.Macros.Item("RefreshFlags") = TRM_PARENT
				Case CMD_EDIT:
					oMenu.Macros.Item("RefreshFlags") = TRM_NODE
				Case CMD_DELETE:
					oMenu.Macros.Item("RefreshFlags") = TRM_PARENTNODE
				Case Else
					oMenu.Macros.Item("RefreshFlags") = TRM_NONE
			End Select
		End If
		
		Select Case oEventArgs.Action
			Case CMD_EDIT:			OnEdit oMenu.Macros
			Case CMD_ADD:			OnCreate oMenu.Macros
			Case CMD_DELETE:		
				If Not hasValue(oMenu.Macros.Item("Prompt")) Then
					oMenu.Macros.Item("Prompt") = "�� ������������� ������ ������� ������?"
				End If
				OnDelete oMenu.Macros
			Case CMD_VIEW:			X_OpenReport oMenu.Macros.Item("ReportURL")
			Case CMD_HELP:			X_OpenHelp HelpPage 
			Case CMD_MOVE:			OnMove oMenu.Macros
			Case CMD_NODEREFRESH:	OnNodeRefresh oMenu.Macros
			Case "DebugShowMenuXml"		: X_DebugShowXML oMenu.XmlMenu
			Case "DebugActiveNodeType"	: Alert m_oTreeView.ActiveNode.Type
			Case "DebugActiveNodeOID" 	: window.clipboardData.setData "Text", m_oTreeView.ActiveNode.ID
			Case "DebugActiveNodeIconSelector" 	: Alert m_oTreeView.ActiveNode.IconSelector
			Case "DebugActiveNodeAppData"		: 
				If Not m_oTreeView.ActiveNode.ApplicationData Is Nothing Then
					X_DebugShowXML m_oTreeView.ActiveNode.ApplicationData
				Else
					Alert "���� �� �������� �������������� ������"
				End If
			Case "DebugActiveNodePath":	Alert m_oTreeView.ActiveNode.Path
		End Select
	End Sub
	
	'==========================================================================
	' �������������� �������
	' � ������� �������� �� ������������ ��� ������ �� ����������� ����
	Public Sub OnEdit(oValues)
		Dim sGUID	' ������������� �������� �������
		
		sGUID = oValues.Item("ObjectID")
		If 0 = Len(sGUID) Then Exit Sub
		With X_CreateControlsDisabler(Me)
			With New CommonEventArgsClass
				.ObjectID = sGUID
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = False
				' ��������� ������� ���������. ��� ������ ���� ������ � ��������� ��������
				.Metaname = oValues.Item("MetanameForEdit")
				Set .Values = oValues
				' ���������� � ��������������
				Internal_FireEvent "BeforeEdit", .Self()
				' ����������� ����� ��������� ���� "�������� ����������"
				If .ReturnValue Then Exit Sub
				' ��������������
				Internal_FireEvent "Edit", .Self()
				' �� ���������� ��������������
				Internal_FireEvent "AfterEdit", .Self()
			End With
		End With
	End Sub

	'==========================================================================
	' �������� ������ �������
	' � ������� �������� �� ������������ ��� ������ �� ����������� ����
	Public Sub OnCreate(oValues)
		With X_CreateControlsDisabler(Me)
			With New CommonEventArgsClass
				.ObjectID = Null
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = Empty
				' ��������� ������� �������. ��� ������ ���� ������ � ��������� ��������
				.Metaname = oValues.Item("MetanameForCreate")
				Set .Values = oValues
				' ���������� � ��������
				Internal_FireEvent "BeforeCreate", .Self()
				' ����������� ����� ��������� ���� "�������� ����������"
				If .ReturnValue Then Exit Sub
				' ��������
				Internal_FireEvent "Create", .Self()
				' �������������
				Internal_FireEvent "AfterCreate", .Self()			
			End With	
		End With
	End Sub

	'==========================================================================
	' ��������  �������
	' � ������� �������� �� ������������ ��� ������ �� ����������� ����
	Public Sub OnDelete(oValues)
		Dim sGUID		' ������������� ���������� �������
		
		' ������� ������������� ���������� �������
		sGUID = oValues.Item("ObjectID")
		If 0=Len(sGUID) Then Exit Sub
		With X_CreateControlsDisabler(Me)
			With New DeleteObjectEventArgsClass
				.ObjectID = sGUID
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = True
				Set .Values = oValues
				' ���������� � ��������
				Internal_FireEvent "BeforeDelete", .Self()
				' ����������� ����� ��������� ���� "�������� ����������"
				If .ReturnValue = False Then Exit Sub
				' �������� �������
				Internal_FireEvent "Delete", .Self()
				' ����������� ����� ��������� ���� "�������� ����������"
				If .ReturnValue = False Then Exit Sub
				' �������������
				Internal_FireEvent "AfterDelete", .Self()
			End With
		End With
	End Sub
	
	'==============================================================================
	' ������� ����. ���������� �������� CMD_MOVE
	' � ������� �������� �� ������������ ��� ������ �� ����������� ����
	Public Sub OnMove(oValues)
		With X_CreateControlsDisabler(Me)
			With New CommonEventArgsClass
				.ObjectID = oValues.Item("ObjectID")
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = True
				.Metaname = oValues.Item("Metaname")
				Set .AddEventArgs = New MoveTreeNodeEventArgsClass
				.AddEventArgs.ParentPropName = oValues.Item("ParentPropName")
				' �������� ������������ ���� ������
				Set .AddEventArgs.MovingNode = m_oTreeView.ActiveNode
				Set .Values = oValues
				' ���������� � ��������
				Internal_FireEvent "BeforeMove", .Self()
				' ����������� ����� ��������� ���� "�������� ����������"
				If .ReturnValue = False Then Exit Sub
				' ������� ���� �� ������ ��������...
				Internal_FireEvent "SelectParent", .Self()
				If .ReturnValue = False Or IsEmpty(.AddEventArgs.ParentObjectType) Or IsEmpty(.AddEventArgs.ParentObjectID) Then Exit Sub
				' ���������� �������
				Internal_FireEvent "Move", .Self()
				' �������������
				Internal_FireEvent "AfterMove", .Self()			
			End With	
		End With
	End Sub
	
	'==============================================================================
	' ��������� ������� (���������) ���� ������, �.�. �������� ������� GET_NODE ����������.
	' � ������� �������� �� ������������ ��� ������ �� ����������� ����
	Public Sub OnNodeRefresh(oValues)
		ReloadNode m_oTreeView.ActiveNode
	End Sub
	
	'==============================================================================
	'@@XTreePageClass.ReloadNode
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE ReloadNode>
	':����������:	����������� ���� ������ � ���������� �������������� ��������� IXTreeNode
	':���������:
	'	[in] oNode As IXTreeNode - ���� ������, ������� ���������� �����������
	':���������:	Public Function ReloadNode(oNode)
	':���������:
	'	�������������� ��������� IXTreeNode
	Public Function ReloadNode(oNode) ' As IXTreeNode
		Dim sPath	' ����
		sPath = oNode.Path
		On Error Resume Next
		oNode.Reload 
		If Err Then MsgBox Err.Description, vbCritical
		On Error GoTo 0
		Set ReloadNode = m_oTreeView.FindNode(sPath, True, False)
	End Function

	'==============================================================================
	'@@XTreePageClass.Title
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE Title>
	':����������:	����������/������������� ��������� ��������
	':���������:	Public Property Get/Let Title [As String]
	Public Property Get Title
		Title = xPaneCaption.innerText
	End Property
	Public Property Let Title(sText)
		xPaneCaption.innerText = sText
	End Property

	'==============================================================================
	'@@XTreePageClass.SpecialCaption
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE SpecialCaption>
	':����������:	����������/������������� "�����������" ��������� ��������
	':����������:   "�����������" ��������� �������� ���������� ���� "������������" ���������, ������������ ��� ������ �������������� ����������
	':���������:	Public Property Get/Let SpecialCaption [As String]
 	Public Property Get SpecialCaption		' As String
		SpecialCaption = xPaneSpecialCaption.innerHtml
	End Property
	Public Property Let SpecialCaption(sText)
		xPaneSpecialCaption.innerHtml = sText
	End Property
	
	'==========================================================================
	'@@XTreePageClass.EnableControls
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE EnableControls>
	':����������:	����������/���������� ����������� ��������� ��������
	':���������:
	'	[in] bEnable As Boolean  - ������� ����������� ���������
	':���������:	Sub EnableControls(bEnable)
	Sub EnableControls(bEnable)
		If Not TREE_MD_OFF_RELOAD Then _
			cmdRefresh.disabled = Not bEnable
		If Not X_MD_OFF_CLEARFILTER Then _
			cmdClearFilter.disabled = Not bEnable
		If Not X_MD_OFF_HIDEFILTER Then _
			cmdHideFilter.disabled = Not bEnable
		If X_MD_PAGE_HAS_FILTER Then
			g_oFilterObject.Enabled = bEnable
		End If
		MenuHtml.HTML.style.display = iif(bEnable, "block", "none")
		g_oXTreePage.TreeView.Enabled = bEnable
		XService.DoEvents
	End Sub
	
	'==============================================================================
	'@@XTreePageClass.SwitchFilter
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE SwitchFilter>
	':����������:	�������� ��������� �������: ������ ��� ��������
	':���������:	Public Sub SwitchFilter()
	Public Sub SwitchFilter()
		If X_MD_PAGE_HAS_FILTER Then
			If UCase(xPaneFilter.style.display) = "NONE" Then
				xPaneFilter.style.display = "block"
				g_oFilterObject.SetVisibility True
				cmdHideFilter.innerText = "������"
				cmdHideFilter.title = "������ ������"
			Else
				cmdHideFilter.focus
				xPaneFilter.style.display = "none"
				g_oFilterObject.SetVisibility False
				cmdHideFilter.innerText = "��������"
				cmdHideFilter.title = "�������� ������"
			End If
		End If
	End Sub

	'==============================================================================
	'@@XTreePageClass.ResizePanels
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE ResizePanels>
	':����������:	������ � ��������� �������� ������ � ���� � ����������� �� ��������� ���������
	':���������:	Sub ResizePanels()
	Sub ResizePanels()
		Const WINDOW_MIN_WIDTH  = 20	'- ���������� ���������� ������ ����, 
										' ��� ������� ��� ����� ������������� ������� �������
										
		Dim nWidth		' ����������� ������
		Dim nMAX		' ������������ ���������� ������
		Dim nDiff		' ������� � �������
		
		' ��� ��� ������� �� ��� ��� ������ ������ 
		If m_bAccessDenied Then
			Exit Sub
		End If
		
		nMAX = document.body.clientWidth
		If nMAX < WINDOW_MIN_WIDTH Then
			Exit Sub ' ��� ���������� ������ ���� ����� �� �������
		End If

		If IsNumeric(TreeHolder.offsetWidth) And (0<>Len(TreeHolder.offsetWidth)) And IsNumeric(TreeView.clientWidth) And (0<>len(TreeView.clientWidth)) Then
			nDiff = TreeHolder.offsetWidth - TreeView.clientWidth
			If nDiff < 0 Then nDiff = 0
		Else
			nDiff = 0
		End If
		
		' ��������� �� ��������� � ��������
		nWidth = Int( m_dSplitterPos * nMAX /100 )

		'!!! ����� ���� ������� ����� ����� � ������ � ���� !!!
		If nWidth < (PANEL_MIN_WIDTH + nDiff + Splitter.offsetWidth ) Then
			nWidth = PANEL_MIN_WIDTH + nDiff + Splitter.offsetWidth
		End If
		If nMAX - nWidth - Splitter.offsetWidth < PANEL_MIN_WIDTH Then
			nWidth = nMAX - Splitter.offsetWidth - PANEL_MIN_WIDTH
		End If
		' ��������� �� �������� � ���������
		m_dSplitterPos = nWidth*100/nMAX
		' � ������������� ����� ������
		nMAX = nMAX - nWidth - Splitter.offsetWidth
		
		MenuHolder.style.width = nMAX & "px"
		TreeHolder.style.width = (nWidth - nDiff) & "px"
		MenuHtml.style.width=nMAX&"px"

		' ������������ ������
		nDiff = TreeHolderCell.clientWidth - nWidth
		If nDiff>0 Then
			nMAX = nMAX + nDiff
			MenuHolder.style.width = nMAX & "px"
		End If

	End Sub

	'==============================================================================
	'@@XTreePageClass.RefreshCurrentNode
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE RefreshCurrentNode>
	':����������: ��������� ������ �������� ������������ �������� ���� � ������������ �� ������� ����������
	':���������: Public Sub RefreshCurrentNode(nOps)
	':���������: 
	'   nOps - [in] ����� ���������� (TRM_xxxx)
	Public Sub RefreshCurrentNode(nOps)
		Dim oParentNode		' ������������ ���� ������������ ����
		Dim oCurrentNode	' ������� ���� ������

		If TRM_NONE = nOps Then Exit Sub ' ������ �� ������
		
		Set oCurrentNode = TreeView.ActiveNode
		If oCurrentNode Is Nothing Then
			Set oParentNode = Nothing
		Else
			Set oParentNode = oCurrentNode.parent
		End If
		
		DoRefreshTree nOps, oCurrentNode, oParentNode  
	End Sub
	
	'==============================================================================
	' ���������� ������� EnableControls, ���������������� �������� (x-filter.htc)
	'	[in] oEventArgs - EnableControlsEventArgs
	Public Sub Internal_On_Filter_EnableControls(oSender, oEventArgs)
		EnableControls oEventArgs.Enable
	End Sub

	'==============================================================================
	' ���������� ������� Accel, ���������������� �������� (x-filter.htc)
	'	[in] oEventArgs - AccelerationEventArgsClass
	Public Sub Internal_On_Filter_Accel(oSender, oEventArgs)
		If oEventArgs.keyCode = VK_ENTER Then
			Reload
		End If
	End Sub


	'==============================================================================
	' ���������� ������� "Apply", ���������������� �������� (x-filter.htc)
	'	[in] oEventArgs - AccelerationEventArgsClass
	Public Sub Internal_On_Filter_Apply(oSender, oEventArgs)
		Reload
	End Sub

	'==============================================================================
	' ���������� ActiveX-������� onKeyUp ���������� TreeView
	' �� ������������ ��� ������������� ���������� �����
	Public Sub OnKeyUp(nKeyCode, nFlags)
		Dim oActiveNode						' As IXTreeNode - ������� ����
				
		' ������������ ������ ������ APPS/MENU (����� �� ������� Control)
		If nKeyCode = VK_APPS Then
			' ���� ��� �������� ���� �� ����� ������ ������
			Set oActiveNode = TreeView.ActiveNode
			If Not oActiveNode Is Nothing Then
				' ���� ���� ������, �� ������� ���, ����� �������� ���� ������� ������ � ������� ���� �����, ����� ������� ��� � �������
				If m_bMenuIsReady Then
					Internal_ShowPopupMenuNearActiveNode
				Else
					m_bPendingShowPopupNearActiveNode = True
					m_bPendingShowPopup = True
				End If
			End If
		Else			
			' ���� ���� ������
			If m_bMenuIsReady Then
                                m_oMenu.ExecuteHotkey Me, CreateAccelerationEventArgsForActiveXEvent(nKeyCode, nFlags)
			End If	
		End If
	End Sub
End Class

Dim g_oXTreePage		' ���������� ��������� XTreePageClass - ���������
Dim g_oFilterObject		' ������ �������� �������� - ��������� ������ XFilterObjectClass

'<������������� ��������>
'==============================================================================
' ������������� ��������
Sub Window_OnLoad()	
	X_WaitForTrue "Init()" , "X_IsDocumentReadyEx( null, ""XFilter"")"
End Sub

'==============================================================================
' ������������� �������� ����� �������� ���� ��������� �� ��������
Sub Init
	Set g_oXTreePage = New XTreePageClass

	g_oXTreePage.Internal_InitializeHtmlControls
    ' ����������� �������:
    If X_MD_PAGE_HAS_FILTER Then
		Set g_oFilterObject = X_GetFilterObject( document.all( "FilterFrame") )
	    g_oXTreePage.Internal_InitFilter
	    ' ������� �������� ������a � ���������� FilterObject
	    X_WaitForTrue  "g_oXTreePage.Internal_InitPageFinal", "g_oFilterObject.IsReady"
	Else
		g_oXTreePage.Internal_InitPageFinal
	End If		
End Sub

'</������������� ��������>

'<����������� ��������>
'==============================================================================
' ������� �������� ��������
Sub Window_onBeforeUnload
	If Not IsObject(g_oXTreePage) Then Exit Sub
	If Nothing Is g_oXTreePage Then Exit Sub
	If g_oXTreePage.MayBeInterrupted Then Exit Sub
	window.event.returnValue="��������!" & vbNewLine & "�������� �������� � ������ ������ ����� �������� � ������������� ������!"
End Sub

'==============================================================================
' �������� ��������
Sub window_onUnLoad()
	on error resume next
	If IsNothing(g_oXTreePage) Then Exit Sub
	g_oXTreePage.Internal_FireEvent "UnLoad", Nothing
	' �������� ��������� ����������� ������ ���� � �������
	g_oXTreePage.Internal_SaveStateOnUnload
End Sub
'</����������� ��������>

'<����������� ������>

'==============================================================================
' ��������� ������� ������� �������...
Sub XTree_cmdClearFilter_OnClick()
	If X_MD_PAGE_HAS_FILTER Then 
		g_oFilterObject.ClearRestrictions()
	End If
End Sub

'==============================================================================
' ���������� ������ "������"/"��������" ������
Sub XTree_cmdHideFilter_onClick()
	g_oXTreePage.SwitchFilter()
End Sub

'==============================================================================
' ���������� ������� OnClick ��� cmdRefresh
Sub XTree_cmdRefresh_OnClick()
   g_oXTreePage.Reload()
End Sub

'==============================================================================
' ���������� ������� �� ������ "�������"
Sub XTree_cmdOpenHelp_OnClick
	Document_onHelp
End Sub
'</����������� ������>

'==============================================================================
' ����/�������� ������. �������� �� ������ XTreePageClass, �.�. ���������� GetRef'��
Sub Reload()
	g_oXTreePage.Reload
End Sub

'==============================================================================
' ���������� ������� OnReadyStateChange ��� g_oXTreePage.m_oMenuHTTP
Sub ProcessMenuXML
	Const XML_DOM_COMPLETE = 4		' ������� ����� �������� ��������� � XMLDomDocument
	Dim oMenuXML			' IXMLDOMDocument ���������� ����
	' ��������� ���������� ����
	If g_oXTreePage.m_oMenuHTTP.readyState <> XML_DOM_COMPLETE Then Exit Sub
	' ��������� ������������ ���������� ������
	Set oMenuXML = CheckMenuRequestResponse(g_oXTreePage.m_oMenuHTTP) 
	' ���� � ������ �� Nothing, ������ �������� ���������� ����
	If Not oMenuXML Is Nothing Then
		g_oXTreePage.EndShowMenu oMenuXML
	End If
End Sub

'==============================================================================
' ��������� �� ������������ ����� �� ���������� ���� (�� ��������� x-tree-menu.aspx)
'	[in] oXmlHttp - ������ XMLHTTP, ����� �� �������� ���������
'	[retval] - ���� ����� ����������, xml-���������� ���������� ����� (IXMLDOMElement ��������� ���� - menu)
Function CheckMenuRequestResponse(oXmlHttp)	' As XMLDOMElement
	Const vbByteArray = &h2011		' ������������ ��� ��������, ������� ������������
	Dim sMenuHTML				' ������������ ���������� ����
	Dim oMenuXML				' IXMLDOMDocument ���������� ����
	
	Set CheckMenuRequestResponse = Nothing
	' 400 - ������������ ����������� ������ �������
	If oXmlHttp.status > 400 Then
		sMenuHTML = "<h2>������ �� �������</h2><br/>" & oXmlHttp.status & "<br/>" & XService.HTMLEncodeLite(  oXmlHttp.statusText) & "<hr/><h3>���������� ��� ��������������:</h3><div style=""background-color:white;"">" & XService.HTMLEncodeLite(XService.ByteArrayToText(oXmlHttp.responseBody)) & "</div>"
		MenuHtml.SetStatus sMenuHTML
		Exit Function 
	End If
			
	' ����� ������ ������ ����
	If vbByteArray <> VarType( oXmlHttp.responseBody) Then
		sMenuHTML = "<h2>������ �� �������</h2><BR/>TypeName(oXmlHttp.responseBody)=" & VarType( oXmlHttp.responseBody) & "<br>http status:" & oXmlHttp.status & "<hr/>"
		On Error Resume Next
		sMenuHTML = sMenuHTML & "<h3>���������� ��� ��������������:</h3><div style=""background-color:white;"">" & XService.HTMLEncodeLite(XService.ByteArrayToText(oXmlHttp.responseBody))
		On Error GoTo 0
		MenuHtml.SetStatus sMenuHTML
		Exit Function 
	End If
	
	' ����� ������ ������ ����
	If 0 > UBound( oXmlHttp.responseBody) Then
		sMenuHTML = "<h2>������ �� �������</h2><BR>UBound=" & UBound( oXmlHttp.responseBody)
		MenuHtml.SetStatus sMenuHTML
		Exit Function 
	End If
	
	Set oMenuXML = XService.XmlFromString(XService.ByteArrayToText(oXmlHttp.responseBody ))	
	' � ������ �� ��� ���������� XML?
	If oMenuXML Is Nothing Then
		sMenuHTML = "<h2>������ �� ������� - ������ �������� XML</h2><br/>" & XService.HTMLEncodeLite(XService.ByteArrayToText(oXmlHttp.responseBody) )
		MenuHtml.SetStatus sMenuHTML
		Exit Function
	End If
	If oMenuXML.nodeName = "x-res" Then
		' xml ������ ����������, �� ��� ��������� �� ������ - ���������� ��� ���������� �� ���������
		sMenuHTML = oMenuXML.transformNode( GetXsl("") )
		MenuHtml.SetStatus sMenuHTML
		Exit Function
	End If
	' ���� ����� �� ����, ������ ��� ������	
	Set CheckMenuRequestResponse = oMenuXML
End Function

'==============================================================================
' ���������� XMLDocument Xsl-������� ��� ���� � �������� ������. �������� �� ������ XTreePageClass, �.�. ���������� GetRef'��
'	[in] sXslFileName - ������������ ����� XSLT-���������. ���� "" ��� Null, �� ���������� ������ �� ���������
Function GetXsl(sXslFileName)
	Dim oMenuXsl
	If g_oXTreePage.m_sMenuXslDefault = sXslFileName Or IsNull(sXslFileName) Or Len(sXslFileName)=0 Then
		' ���� �������� �� ����� ��� �������� ��� ��������� �� ���������, �� ������� �������� ������� �������� �� ���������
		Set oMenuXsl = g_oXTreePage.MenuDefaultStylesheet
		' �������� ��������� ������ �������� ���������
		while Not X_IsObjectReady(oMenuXsl)
			' waiting...
		wend
		Set GetXsl = oMenuXsl
	Else
		' ����� ����� ������ � ���� ���������� (���� - ��� ���������)
		If g_oXTreePage.m_oMenuXSLCollection.Exists(sXslFileName) Then
			' �������� ��� ���� - ������ ���
			Set GetXsl = g_oXTreePage.m_oMenuXSLCollection.Item(sXslFileName)
		Else
			' �������� ����������� ������ ��� - �������� ��� � �������� � ���� (���� - ��� ���������)
			Set oMenuXsl = XService.XMLGetDocument("XSL\" & sXslFileName) 
			g_oXTreePage.m_oMenuXSLCollection.Add sXslFileName, oMenuXsl
			Set GetXsl = oMenuXsl
		End If
	End If
End Function

'<����������� ���������>

Dim g_xSplitter ' document.all("XTree_Splitter")

'==============================================================================
' ���������� ������ ���������
Function Splitter
	If IsEmpty(g_xSplitter) Then
		Set g_xSplitter = document.all("XTree_Splitter")
	End If
	Set Splitter = g_xSplitter 
End Function

'==============================================================================
' �������� ��������� ��������� �����������
Sub XTree_Splitter_OnMouseDown()
	If Not IsObject(g_oXTreePage) Then Exit Sub
	
	Splitter.LeftButton = "1"
	Splitter.SetCapture
End Sub

'==============================================================================
' ��������� ��������� �����������
Sub XTree_Splitter_OnMouseMove()
	If Not IsObject(g_oXTreePage) Then Exit Sub

	Dim nNewX	' ����� ��������� �����������
	Dim nMAX	' ����������� ���������� ���������
	nMAX = document.body.clientwidth 
	If Splitter.LeftButton="1" And window.event.button=1 Then ' ���� ������ ��� ���� ������, ���������� �������
		nNewX=window.event.clientX
		If nNewX<PANEL_MIN_WIDTH Then 
		  nNewX=PANEL_MIN_WIDTH
		End If  
		If nMAX<PANEL_MIN_WIDTH Then 
		  nNewX= nMAX-PANEL_MIN_WIDTH
		End If 
		' ��������� ��  �������� � ��������� 
        g_oXTreePage.m_dSplitterPos = nNewX*100/nMAX
        ' � �������� ������� �������
        g_oXTreePage.ResizePanels()
	End If
	If Splitter.LeftButton="1" And window.event.button<>1 Then	'���� ������ ����� ������ ������������� �������
		Splitter_OnMouseUp
	End If
End Sub

'==============================================================================
' ��������� ��������� ��������� �����������
Sub XTree_Splitter_OnMouseUp()
	If Not IsObject(g_oXTreePage) Then Exit Sub

	If Splitter.LeftButton="1" Then
		Splitter.LeftButton="0"
		Splitter.releaseCapture()
	End If
End Sub
'</����������� ���������>


'<����������� �������� ���������>
'==============================================================================
' ���������� ��������� �������� ����
Sub window_OnResize()
	If Not IsObject(g_oXTreePage) Then Exit Sub
	g_oXTreePage.ResizePanels()
End Sub
'</����������� �������� ���������>

'==============================================================================
' ���������� ������ �������
Sub Document_OnHelp
	If Not IsObject(g_oXTreePage) Then Exit Sub
	If g_oXTreePage.HelpAvailiabe Then
		window.event.returnValue = False
		X_OpenHelp g_oXTreePage.HelpPage
	End If
End Sub

'<����������� �������� TREEVIEW>
'==============================================================================
' ���������� ������� OnDataLoading ��� oTreeView.
'	������������ ��� ��������� � ������ �� ��������� ������
'	�������� ���������� �������.
Sub TreeView_OnDataLoading( oSender,  nQuerySet,  sNodePath,  sObjectType,  sObjectID,  oRestrictions)
	Dim sRestrictions		' ����������� �������
	Dim sSpecialCaption		' ���������
	
	g_oXTreePage.MayBeInterrupted = False
	sRestrictions = GetRestrictions
	internal_TreeInsertRestrictions oRestrictions, sRestrictions
	If Len(sRestrictions) > 0 Then
		sSpecialCaption = "<NOBR>������ �������</NOBR>"
	Else
		sSpecialCaption = ""
	End If
	g_oXTreePage.SpecialCaption = sSpecialCaption
End Sub

'==============================================================================
' ���������� ������� OnDataLoaded ��� oTreeView
'	������������ ��� ����������� ������ "������" ��������,
'	��� ������� �������� ���������� ������������ ���� 
'	�������� ������� ��������� ��������. 
' ��������! ������� ��������� ���� ����������� �� ����� 
'	�����������, �.�. ������ � ���� ����� ����� 
'	������������� ��, ��� ������ � �������� �����������.
Sub TreeView_OnDataLoaded( oSender, nQuerySet, sNodePath, sObjectType, sObjectID )
	g_oXTreePage.MayBeInterrupted = True
	If 0<>nQuerySet Then Exit Sub
	If 0<>oSender.Root.Count Then Exit Sub
	g_oXTreePage.ShowMenu
End Sub

'==============================================================================
' ���������� ������� ������ ������ ����
Sub TreeView_OnMouseUp(oSender, oTreeNode, nFlags)
	Const	KEYFLG_RBUTTON = 16 ' ��� ������ ������ ����
	Dim oCurrentNode	' ��������� ���� ������
	
	If nFlags <> KEYFLG_RBUTTON Then Exit Sub
	
	If Nothing Is oTreeNode Then Exit Sub
	
	Set oCurrentNode = oSender.ActiveNode
	If Nothing Is oCurrentNode Then
		oSender.Path = oTreeNode.Path 
	ElseIf oCurrentNode.nodeUID <> oTreeNode.nodeUID Then
		oSender.Path = oTreeNode.Path 
	End If
	If g_oXTreePage.m_bMenuIsReady Then
		window.setTimeout "g_oXTreePage.ShowPopupMenu", 0, "VBScript"
	Else
		g_oXTreePage.m_bPendingShowPopup = True
	End If
End Sub

'==============================================================================
' ���������� ������ ������������ ����
Sub TreeView_OnKeyUp(oSender, nKeyCode, nFlags)
	g_oXTreePage.OnKeyUp nKeyCode, nFlags
End Sub

'==============================================================================
' ���������� ������� DoubleClick
Sub TreeView_OnDblClick(oSender, oTreeNode)
	Dim oCurrentNode	' ������� ���� ������

	If Nothing Is oTreeNode Then Exit Sub

	If Not oTreeNode.IsLeaf Then Exit Sub
	
	Set oCurrentNode = oSender.ActiveNode
	If Nothing Is oCurrentNode Then
		oSender.Path = oTreeNode.Path 
	ElseIf oCurrentNode.nodeUID <> oTreeNode.nodeUID Then
		oSender.Path = oTreeNode.Path 
	End If
	' ���� ���� ������, �� �������� �����, ����������� ������� �� ���������, ����� ��������
	If g_oXTreePage.m_bMenuIsReady Then   
		window.setTimeout "g_oXTreePage.CallMenuDefaultItem", 0, "VBScript"
	Else
		g_oXTreePage.m_bPendingRunDefaultMenuItem = True
	End if		
End Sub

'==============================================================================
'���������� ��������� ��������� ����
Sub TreeView_OnPathChange(oSender, oCurrent, oNew)
	If oNew Is Nothing Then Exit Sub
	g_oXTreePage.m_sTreePath = oNew.Path
	g_oXTreePage.ShowMenu
End Sub

'==============================================================================
' ������ �������� - ����� ��������
Sub TreeView_OnBeforeNodeDrag(oTreeView, oSourceNode, nKeyFlags, bCanDrag)
	g_oXTreePage.DragDropController.OnBeforeNodeDrag g_oXTreePage, oTreeView, oSourceNode, nKeyFlags, bCanDrag
End Sub

'==============================================================================
' ������ �������� - ������ �������������
Sub TreeView_OnNodeDrag(oTreeView, oSourceNode, nKeyFlags)
	g_oXTreePage.DragDropController.OnNodeDrag g_oXTreePage, oTreeView, oSourceNode, nKeyFlags
End Sub

'==============================================================================
' �������� ��� ������ �����
Sub TreeView_OnNodeDragOver(oTreeView, oSourceNode, oTargetNode, nKeyFlags, bCanDrog)
	g_oXTreePage.DragDropController.OnNodeDragOver g_oXTreePage, oTreeView, oSourceNode, oTargetNode, nKeyFlags, bCanDrog
End Sub
'==============================================================================
' ������� ���������
Sub TreeView_OnNodeDragDrop(oTreeView, oSourceNode, oTargetNode, nKeyFlags)
	g_oXTreePage.DragDropController.OnNodeDragDrop g_oXTreePage, oTreeView, oSourceNode, oTargetNode, nKeyFlags
End Sub

'==============================================================================
' �������� �������
Sub TreeView_OnNodeDragCanceled(oTreeView, oSourceNode, nKeyFlags)
	g_oXTreePage.DragDropController.OnNodeDragCanceled g_oXTreePage, oTreeView, oSourceNode, nKeyFlags
End Sub

'</����������� �������� TREEVIEW>

'==============================================================================
'@@FilterObject
'<GROUP !!FUNCTIONS_x-tree><TITLE FilterObject>
':����������:
'	���������� ������ ������� �������� �������� - ��������� ������ XFilterObjectClass
':���������:
'	��������� ������ XFilterObjectClass ��� Empty, ���� � �������� ��� �������.
':���������:
'	Function FilterObject()
Function FilterObject() ' As XFilterObjectClass
    Set FilterObject = g_oFilterObject
End Function

'==============================================================================
'@@GetRestrictions
'<GROUP !!FUNCTIONS_x-tree><TITLE GetRestrictions>
':����������:
'	���������� ��������� ������� (������ �����������) � ������� Name1=Value1&Name2=Value2&...&NameY=ValueY
':���������:
'	������ � ������������� ��� vbNullString, ���� � �������� ��� �������.
':���������:
'	Function GetRestrictions()
Function GetRestrictions() ' As String
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
'@@MenuSectionClick
'<GROUP !!FUNCTIONS_x-tree><TITLE MenuSectionClick>
':����������:
'	���������� ������ ����� �� ��������� ������ ���� - ��������� �����������/�������������
':���������:
'	oSectionTHEAD - [in] ��������� ������ ���� (HTML_THEAD_Element)
':���������:
'	Sub MenuSectionClick( oSectionTHEAD)
Sub MenuSectionClick( oSectionTHEAD)
	Dim sMode				' ������� ���������� ������
	Dim sID					' ������������� ������ ����
	
	' ������� ������� ��������� ������ � ����������� ���
	sMode = iif(CStr(oSectionTHEAD.ExtendedIsCollapsed) = "0", "1", "0")
	SetMenuSectionState oSectionTHEAD, sMode
	
	sID = oSectionTHEAD.ID
	' ���� ������ ���� ����������� - ��������� � ��������� � m_oMenuSect
	If Len(sID)>0 Then
		g_oXTreePage.m_oMenuSect.SetValue sID, sMode
	End If
End Sub

'==============================================================================
'@@SetMenuSectionState
'<GROUP !!FUNCTIONS_x-tree><TITLE SetMenuSectionState>
':����������:
'	������������� ��������� ������ ����: ���������/�����������
':���������:
'	oSectionTHEAD - [in] ��������� ������ ���� (HTML_THEAD_Element)
'	sMode - [in] ������ ��������� ������: 1 - ����������, 0 - ���������
':���������:
'	SetMenuSectionState(oSectionTHEAD, sMode)
Sub SetMenuSectionState(oSectionTHEAD, sMode)
	Dim oSubItemsTBODY		'TBODY �������, ���������� ����� ������ 
	Dim oMenuSectionStateTD	'TD ������� c ��������� �������� ( ������������� ������/����)
	Dim oMenuSectionCaptTD	'TD ������� c ���������� ������

	Set oSubItemsTBODY = oSectionTHEAD.nextSibling
	With oSectionTHEAD.childNodes.item(0).childNodes.item(0).childNodes.item(0).childNodes.item(0).childNodes.item(0)
		Set oMenuSectionStateTD = .childNodes.item(0)
		Set oMenuSectionCaptTD  = .childNodes.item(1)
	End With
		
	If sMode = "1" Then
		' ����������� ������
		oSubItemsTBODY.className = "x-tree-menu-section-content-expanded"
		oMenuSectionStateTD.className = "x-tree-menu-section-state-expanded"
		oMenuSectionCaptTD.className = "x-tree-menu-section-caption-expanded"
	Else
		' ��������� ������ 
		oSubItemsTBODY.className = "x-tree-menu-section-content-collapsed"
		oMenuSectionStateTD.className = "x-tree-menu-section-state-collapsed"
		oMenuSectionCaptTD.className = "x-tree-menu-section-caption-collapsed"
	End If
	
	oSectionTHEAD.ExtendedIsCollapsed = sMode
End Sub

'==============================================================================
' ����� "����������" �������
' ���������� �� PopUp-���� � CTRL (���� � �������-CTRL-�� �����������) �� ��������� 
Sub OnDebugEvent()
	const DEB_ALL_METADATA		= 1001	'����������
	const DEB_TREE_METADATA		= 1002	'���������� ������
	const DEB_SYSINFO			= 1009	'��������� ����������
	const DEB_RESTRICTIONS		= 1012	'����������� �������
	const DEB_MENU_XML			= 1014	'����: XML
	const DEB_MENU_HTML			= 1015	'����: HTML
	const DEB_RESET				= 1016	'����� ������
	const DEB_XDEFAULT			= 1017	'x-default.aspx
	const DEB_ISDEBUGMODE		= 1018	'���������� �����
	const DEB_FILTERMENU		= 1019	' ���������� ���� �������
	
	dim sTempStr						'��������������� ������
	dim PopUp
	Set PopUp = XService.CreateObject("CROC.XPopUpMenu")
	
	'��������� ��������� ����������...
	If  window.event.ctrlKey Or X_IsDebugMode Then
		' ������ ����
		PopUp.Clear
		PopUp.Add "����������",				DEB_ALL_METADATA,		true
		PopUp.Add "���������� ������",		DEB_TREE_METADATA,		true
		PopUp.AddSeparator
		PopUp.Add "����: XML",				DEB_MENU_XML,			g_oXTreePage.m_bMenuIsReady
		PopUp.Add "����: HTML",				DEB_MENU_HTML,			true
		PopUp.AddSeparator
		PopUp.Add "��������� ����������",	DEB_SYSINFO,			true
		PopUp.AddSeparator
		PopUp.Add "����������� �������",	DEB_RESTRICTIONS,		X_MD_PAGE_HAS_FILTER
		PopUp.AddSeparator
		PopUp.Add "���������� ���� �������...", DEB_FILTERMENU,		X_MD_PAGE_HAS_FILTER
		PopUp.AddSeparator
		PopUp.Add "����� ������...", 		DEB_RESET, true
		PopUp.AddSeparator
		PopUp.Add "���������� �����",		DEB_ISDEBUGMODE, true, iif(X_IsDebugMode, 1, 0)
		PopUp.AddSeparator
		PopUp.Add "x-default.aspx", 		DEB_XDEFAULT, true	
		select case PopUp.Show()
			case DEB_XDEFAULT
				navigate XService.BaseURL( location.href) & "X-DEFAULT.ASPX?ALL=1&TM="  & CDbl(Now)
			case DEB_RESET
				X_ResetSession
			case DEB_MENU_XML
				X_DebugShowXML  g_oXTreePage.XmlMenu
			case DEB_MENU_HTML
				X_DebugShowHTML  MenuHtml.Html.InnerHTML
			case DEB_RESTRICTIONS
				on error resume next
				sTempStr = GetRestrictions()
				if Err then
					Alert "������ � �������:" & vbNewLine & Err.Source & vbNewLine  & Err.Description
					exit sub
				end if
				on error goto 0
				InputBox sTempStr ,"������� ����������� �������", sTempStr 
			case DEB_FILTERMENU
				FilterObject.ShowDebugMenu
			case DEB_ALL_METADATA
				X_DebugShowXML X_GetMD()
			case DEB_TREE_METADATA
				X_DebugShowXML g_oXTreePage.GetTreeMD()
			case DEB_SYSINFO
				' ��������� ������ � ��������� �����������...
				sTempStr =	"����:			X-TREE.ASPX" & vbNewLine &_
							"������:			" & document.fileSize & vbNewLine & _
							"�������:		"  & FormatDateTime( document.lastModified, vbShortDate ) & " " & FormatDateTime( document.lastModified, vbLongTime ) & vbNewLine & vbNewLine & _
							"�������:			" & g_oXTreePage.MetaName & vbNewLine &_
							"������ �������:		" & g_oXTreePage.QueryString.QueryString
				
				if not Nothing Is g_oXTreePage.TreeView.ActiveNode then
					sTempStr = sTempStr & vbNewLine & vbNewLine & "��� ����:			" & g_oXTreePage.TreeView.ActiveNode.type 
					sTempStr = sTempStr & vbNewLine & "�������������:		" & g_oXTreePage.TreeView.ActiveNode.ID 
					sTempStr = sTempStr & vbNewLine & "��������:		" & g_oXTreePage.TreeView.ActiveNode.IconSelector 
					sTempStr = sTempStr & vbNewLine & "������:			" & g_oXTreePage.TreeView.ActiveNode.IconURL
				end if			
							 							
				' � ������ �			
				MsgBox sTempStr, vbOKOnly , "��������� ����������"
			case DEB_ISDEBUGMODE
				X_SetDebugMode Not X_IsDebugMode
		end select
		window.event.returnValue = false
	end if
End Sub

'==============================================================================
' ����������� ���������� "SetInitPath" - ��������� ��������� ���� � ������, ��������� ���������� ��������
Sub stdXTree_OnSetInitPath(oSender, oEventArgs)
	oSender.TreeView.SetNearestPath oSender.m_sTreeInitPath, False, True
End Sub

'===============================================================================
'@@TreeMenuEventArgsClass
'<GROUP !!CLASSES_x-tree><TITLE TreeMenuEventArgsClass>
':����������:	��������� ������� ��������� � ������� ���� �������� (MenuBeforeShow, MenuRendered).
':����������:	���� <LINK TreeMenuEventArgsClass.MenuXsl, MenuXsl /> ������������ ������ ��� ������� MenuBeforeShow.
'
'@@!!MEMBERTYPE_Methods_TreeMenuEventArgsClass
'<GROUP TreeMenuEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_TreeMenuEventArgsClass
'<GROUP TreeMenuEventArgsClass><TITLE ��������>
Class TreeMenuEventArgsClass
	'@@TreeMenuEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_TreeMenuEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel				
	
	'@@TreeMenuEventArgsClass.Menu
	'<GROUP !!MEMBERTYPE_Properties_TreeMenuEventArgsClass><TITLE Menu>
	':����������:	���������� ������ �� ��������� MenuClass.
	':���������:	Public Menu [As MenuClass]
	Public Menu
	
	'@@TreeMenuEventArgsClass.MenuXsl
	'<GROUP !!MEMBERTYPE_Properties_TreeMenuEventArgsClass><TITLE MenuXsl>
	':����������:	���������� ������ �� ��������� XMLDOMDocument Xslt-������� ��� ���������� ����.
	':���������:	Public MenuXsl [As IXMLDOMDocument]
	Public MenuXsl
	
	'@@TreeMenuEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_TreeMenuEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As TreeMenuEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class
