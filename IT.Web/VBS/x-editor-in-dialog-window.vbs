'*******************************************************************************
' ����������:	XEditor
' ����������:	������ ������������� ��������� � �������� ������������
'				� ���������� ���� ���������
'*******************************************************************************
Option Explicit
' ������ �� HTML-��������
Dim cmdCancel           ' ������ ������
Dim g_oMenuHolder		' ��������� x-menu-editor.htc - ��������� ���� (����� ���� Nothing, ���� ���� ��� ��������� �� ������)

'==============================================================================
' ���������� IObjectContainerEventsClass ��� � ���������� ���� � �������� ���������
Class ObjectEditorDialogWindowContainerEventsClass
	
	'==========================================================================
	' �������� ����������� �� ��������� ���������
	'	[in] oObjectEditor
	'	[in] sEditorCaption As String - ��������� ���������. ����� ��������� HTML-��������������.
	'	[in] sPageCaption As String - ��������� ��������. ����� ��������� HTML-��������������.
	Public Sub OnSetCaption(oObjectEditor, ByVal sEditorCaption, sPageCaption)
		Dim oCaption	' ������� � ��������������� "xPaneCaption"
		Dim aCaption	' ����� ��������� � ���� ������� �����
		
		If hasValue(sPageCaption) Then
			' ��������� ��������� ��������, ���� �����
			If oObjectEditor.IsMultipageEditor Then
				' ���������������� �������� - ������������ �������� ��������� �� �������� ��������
				Tabs.SetTabLabel Tabs.ActiveTabID, sPageCaption
			End If
		End If
		' ��������� ��������� ���������
		Set oCaption = document.all( "XEditor_xPaneCaption", 0)
		If Not oCaption Is Nothing Then
			' ������ HTML-��� ���������...
			oCaption.innerHTML = sEditorCaption
			' ������� ��� "������" ����� � ���o���� �� ������ 
			aCaption = Split( "" & oCaption.innerText, vbCr)
			' �������� ��������� ���� = ������ ������ ���������
			If UBound(aCaption)>=0 Then
				document.title = aCaption(0) 
			Else
				document.title = ""
			End If	
		End If
	End Sub


	'==========================================================================
	' �������� ������ �������� ��������� ����������� ��������� ����������
	Public Sub OnEnableControls(oObjectEditor, bEnable, vReserved)
		If oObjectEditor.IsEditor Then
			If oObjectEditor.IsMultipageEditor Then
				Tabs.Enabled = bEnable
			End If
		End If
		cmdCancel.disabled = Not bEnable
		If Not g_oMenuHolder Is Nothing Then _
		    g_oMenuHolder.SetEnableState bEnable
	End Sub


	'==========================================================================
	' ���������� ��������� HTMLDIV, � ������� �� ����� ��������� ���� ����������
	'	[in] oObjectEditor
	'	[in] vReserved
	Public Function OnGetPageDiv(oObjectEditor, vReserved)
		Set OnGetPageDiv = document.all("x_editor_content_div",0)
	End Function

	
	'==========================================================================
	' �������� �������� � ���, ��� ����� ���������� � ������������� ����������� ����������
	'	[in] oObjectEditor As ObjectEditorClass - ��������
	'	[in] vReserved
	Public Sub OnInitializeUI(oObjectEditor, vReserved)
		If g_bExiting Then Exit Sub
		If oObjectEditor.IsEditor Then
			If oObjectEditor.IsMultipageEditor Then
				' �������� ����������������
				Tabs.style.display = "block"
				If g_bExiting Then Exit Sub
				XService.DoEvents
				Exit Sub
			End If
		End If
		If g_bExiting Then Exit Sub
		XService.DoEvents
	End Sub

	
	'==========================================================================
	' �������� �������� � ���������� �������� ��������.
	'	[in] oObjectEditor As ObjectEditorClass - ��������
	'	[in] oPage As EditorPageClass - �������� ��������
	Public Sub OnAddEditorPage(oObjectEditor, oPage, vReserved)
		Dim nIndex		' ������ ����������� ��������
		If g_bExiting Then Exit Sub
		nIndex = Tabs.AddIdentified( oPage.PageName, oPage.PageTitle, oPage.PageHint, "" )
		' ���� ����������� �������� ������ ���� ������, �� ������ �������� �� ���������������
		If oPage.IsHidden Then
			Tabs.HideTab nIndex, True
		End If
	End Sub

	
	'==========================================================================
	' �������� ��� ����� ������� �� �������� ��������. 
	' ������ ��� ����������������� ���������!
	Public Sub OnActivateEditorPage(oObjectEditor, nPageIndex, vReserved)
		If g_bExiting Then Exit Sub
		Tabs.ActiveTab = nPageIndex
	End Sub
	
	
	'==========================================================================
	' �������� (� ������ �������) �������� �� ��������� ������� ��������
	' ������ ������ ���������� ����������������, �.�. ����� ����� ������ OnEnableControls
	'	[in] oArgs As SetWizardOperationsArgsClass
	Public Sub OnSetWizardOperations(oObjectEditor, oArgs)
		If Not g_oMenuHolder Is Nothing Then _
		    g_oMenuHolder.SetWizardButtonsState oArgs.bIsFirstPage, oArgs.bIsLastPage, oArgs.EditorPage
	End Sub


	'==========================================================================
	' �������� �������� �� ��������� ������� ��������. ���������� ��� ����������� ��������.
	' ������ ������ ���������� ����������������, �.�. ����� ����� ������ OnEnableControls
	'	[in] oArgs As SetWizardOperationsArgsClass
	Public Sub OnSetEditorOperations(oObjectEditor, oArgs)
		If Not g_oMenuHolder Is Nothing Then _
		    g_oMenuHolder.SetEditorButtonsState oArgs.EditorPage
	End Sub


	'==========================================================================
	Public Sub OnSetStatusMessage( oObjectEditor, sMsg, vReserved )
		StatusDiv.innerText = sMsg
		If Len(sMsg) > 0 Then
			StatusDiv.style.display = "block"
		Else
			StatusDiv.style.display = "none"
		End If
		XService.DoEvents
	End Sub


	'==========================================================================
	' ���������� ������ ��������� ������� �������� ����� ������� �� �����
	'	[in] nIndex As Integer - ������ �������� (�� 0)
	'	[retval As Integer - ����� ������ �������� (�� 0)
	Private Function getNextTabIndex(ByVal nIndex)
		If nIndex = Tabs.Count - 1 Then
			nIndex = 0
		Else
			nIndex = nIndex + 1
		End If
		If Tabs.IsTabHidden(nIndex) Then
			nIndex = getNextTabIndex(nIndex)
		End If
		getNextTabIndex = nIndex
	End Function

	'==========================================================================
	' ���������� ������ ��������� ������� �������� ������ ������ �� �����
	'	[in] nIndex As Integer - ������ �������� (�� 0)
	'	[retval As Integer - ����� ������ �������� (�� 0)
	Private Function getPrevTabIndex(ByVal nIndex)
		If nIndex = 0 Then
			nIndex = Tabs.Count - 1
		Else
			nIndex = nIndex - 1
		End If
		If Tabs.IsTabHidden(nIndex) Then
			nIndex = getPrevTabIndex(nIndex)
		End If
		getPrevTabIndex = nIndex
	End Function

	'==========================================================================
	' ���������� ������� ���������� ������. ���������� �� ObjectEditor'a
	'	[in] oEventArgs As AccelerationEventArgsClass
	Public Sub OnKeyUp(oObjectEditor, oEventArgs)
		Dim isList	' ������� ���������� �������� �������
		With oEventArgs
			If .keyCode	= VK_ESC Then
				XEditor_cmdCancel_onClick
			' ���� �������� ���������� �� �������, �� ������������ ������� �� ����
			ElseIf Not oObjectEditor.IsControlsEnabled Then 
				oEventArgs.Processed = True
				Exit Sub
			ElseIf oObjectEditor.IsMultipageEditor Then
				isList = False
				If Not IsEmpty(oEventArgs.HtmlSource) Then
					If (oEventArgs.HtmlSource.tagName = "SELECT" Or oEventArgs.HtmlSource.getAttribute("classid") = CLSID_LIST_VIEW) Then
						isList = True
					End If
				End If
				' ���� ������ Ctrl+Tab � ������� �� select ��� XListView, �� ������� ���� ���������� �� OnKeyDown - ������ �� ������
				If .ctrlKey = True And .keyCode = VK_TAB And isList = True Then
					oEventArgs.Processed = True
				ElseIf .ctrlKey = True And .shiftKey = False And .keyCode = VK_RIGHT Then
					If CheckTabNavigation(oEventArgs.HtmlSource) Then
						oEventArgs.Processed = True
						ActivateTabByIndex oObjectEditor, getNextTabIndex(Tabs.ActiveTab)
					End If
				ElseIf .ctrlKey = True And .shiftKey = False And .keyCode = VK_LEFT Then
					If CheckTabNavigation(oEventArgs.HtmlSource) Then
						oEventArgs.Processed = True
						ActivateTabByIndex oObjectEditor, getPrevTabIndex(Tabs.ActiveTab)
					End If
				ElseIf .ctrlKey = True And .shiftKey = False And .keyCode = VK_TAB Then 
					oEventArgs.Processed = True
					ActivateTabByIndex oObjectEditor, getNextTabIndex(Tabs.ActiveTab)
				ElseIf .ctrlKey = True And .shiftKey = True And .keyCode = VK_TAB Then 
					oEventArgs.Processed = True
					ActivateTabByIndex oObjectEditor, getPrevTabIndex(Tabs.ActiveTab)
				' ��������� ������� Ctrl+<����� ��������>
				ElseIf .ctrlKey = True And .keyCode >= VK_D1 And .keyCode <= VK_D9 Then
					oEventArgs.Processed = True
					ActivateTabByIndex oObjectEditor, .keyCode - VK_D1
				Else
					g_oMenuHolder.ExecuteHotkey oEventArgs
				End If
			Else
				If Not g_oMenuHolder Is Nothing Then _
				    g_oMenuHolder.ExecuteHotkey oEventArgs
			End If
		End With
	End Sub
	
	
	
	'==========================================================================
	' ���������� ������� ���������� ������. ���������� �� ObjectEditor'a
	'	[in] oEventArgs As AccelerationEventArgsClass
	Public Sub OnKeyDown(oObjectEditor, oEventArgs)
		' ���� �������� ���������� �� �������, �� ������������ ������� �� ����
		If Not oObjectEditor.IsControlsEnabled Then 
			oEventArgs.Processed = True
			Exit Sub
		End If
		With oEventArgs
			' ���� �������� ��������������� � ������� �������� ���������� - �������� ������� �� ��������� �������� �� Ctrl+Tab
			If oObjectEditor.IsMultipageEditor And oObjectEditor.CurrentPage.IsReady Then
				' ������� �� Ctrl+Tab �������������� �� OnKeyDown ������ ��� ��������� ��: select, XListView
				' ��� ��������� ������� �������������� � OnKeyUp
				If oEventArgs.HtmlSource.tagName = "SELECT" Or oEventArgs.HtmlSource.getAttribute("classid") = CLSID_LIST_VIEW Then
					If .ctrlKey = True And .keyCode = VK_TAB Then
						ActivateTabByIndex oObjectEditor, getNextTabIndex(Tabs.ActiveTab)
						oEventArgs.Processed = True
					End If
				End If
			End If
		End With
	End Sub
	
	'==========================================================================
	' ��������� ������������ ������� �������� ��������� �� �������� � ��������� ��������
	'	[in] nTabIndex - ������ ��������, ������� ���������� ������� ��������
	Private Sub ActivateTabByIndex(oObjectEditor, nTabIndex)
		Dim oEditorPage	' �������� ���������
		' ��������� ���������� �������
		If nTabIndex < oObjectEditor.Pages.Count Then
			' �������� �������� � ��������� ��������
			Set oEditorPage = oObjectEditor.GetPageByIndex(nTabIndex)
			' ���� ������� �������� �� ��������� � ���������
			If oEditorPage.PageName <> oObjectEditor.CurrentPage.PageName And oEditorPage.isHidden = False Then 
				' ��������� ����� �� ������ "��������"
				cmdCancel.Focus
				' ������� �������� ���������� �����������
				oObjectEditor.EnableControls False
				' ���������, ��� ������� �������� ��������� ���������
				If oObjectEditor.CanSwitchPage Then 
					' ����������� ��������
					window.setTimeout "g_oController.SetActiveTab """ & Tabs.ActiveTabID & """, """ & oEditorPage.PageName & """", 100, "VBScript"
				End If
			End If
		End If
	End Sub
	
	'==========================================================================
	' ��������� ����������� ������������ �������� ��������� � ����������� �� �������� ����������
	'	[in] nTabIndex - ������ ��������, ������� ���������� ������� ��������
	Function CheckTabNavigation(oHtmlSource)
		CheckTabNavigation = True
		If oHtmlSource.tagName = "INPUT" Then
			If oHtmlSource.type = "text" Then CheckTabNavigation = False
		End If
		If oHtmlSource.tagName = "TEXTAREA" Then CheckTabNavigation = False
	End Function
	
End Class


'==============================================================================
' ����������:	�����-��������� ��������� (ObjectEditor'a), ��������� ����������� �� Html-���������
' ����������:	��������� ������� ������ � ������� �� ObjectContainerEventsClass
'				�� �������� �������������...
' �����������:	
' ������: 	
Class ObjectEditorDialogWindowContainerClass
	Private m_oObjectEditor			' As ObjectEditorClass - ��������
    Private m_oContainerEvents		' As ObjectEditorDialogWindowContainerEventsClass
   
	'-------------------------------------------------------------------------------
	' ����������:	�������������
	' ���������:
	'	true ���� �� ������, ����� false 
	' ���������:	
	'	[in] oContainerEvents - ��������� ObjectContainerEventsClass
	Public Function Init(oContainerEvents)
		Dim sInitResult		' ��������� �� Init
		Dim oObjectEditor	' ObjectEditor
		Dim oParams			' As ObjectEditorInitializationParametersClass

		initializeHtmlControls		
		Set oObjectEditor = New ObjectEditorClass
		Set m_oContainerEvents = oContainerEvents
		Set oParams = getEditorInitializationParams()

		' ������������� ����
		Set g_oMenuHolder = document.all("oMenu")
		If Not g_oMenuHolder Is Nothing Then _
		    g_oMenuHolder.Init oObjectEditor.UniqueID, X_CreateDelegate(Me, "Internal_MenuExecutionHandler")

		' �������������� ��������
		sInitResult = oObjectEditor.Init(oContainerEvents, oParams)
		If Len("" & sInitResult) > 0 Then
			oContainerEvents.OnSetStatusMessage oObjectEditor, sInitResult, Null
			Init = False
		Else
			Set m_oObjectEditor = oObjectEditor
			Init = True
		End If
	End Function


	'-------------------------------------------------------------------------------
	' ������������� ������ �� HTML-��������
	Private Sub initializeHtmlControls()
		Set cmdCancel = document.all("XEditor_cmdCancel")
	End Sub


	'==========================================================================
	' ���������� ����������� ���������������� ��������� ��� ��������
	Private Function getEditorInitializationParams()
		Dim oObjectEditorDialog	' ��������� ������
		Dim oParams				' As ObjectEditorInitializationParametersClass
		
		Set oParams = New ObjectEditorInitializationParametersClass
		' �������������� ������ ���������/�������
		X_GetDialogArguments oObjectEditorDialog
		' ��������� ��� ���� � ������� �������� �� ��������� ����������� ������������� ����
		Set x_oRightsCache = oObjectEditorDialog.GetRightsCache
		' ��������� ���������� � ������� �������� �� ��������� ����������� ������������� ����
		Set x_oMD = oObjectEditorDialog.GetMetadataRoot()
		' ��������� ������� ����� ������������ � ������� �������� �� ��������� ����������� ������������� ����
		Set x_oConfig = oObjectEditorDialog.GetConfig()
		
		With oParams
			.ObjectType = X_PAGE_OBJECT_TYPE
			.MetaName = X_PAGE_METANAME
			.CreateNewObject = oObjectEditorDialog.IsNewObject
			.ObjectID = oObjectEditorDialog.ObjectID
			.IsAggregation = oObjectEditorDialog.IsAggregation
			Set .QueryString = oObjectEditorDialog.QueryString
			Set .XmlObject = oObjectEditorDialog.XmlObject
			Set .ParentObjectEditor = oObjectEditorDialog.ParentObjectEditor
			.ParentObjectID = oObjectEditorDialog.ParentObjectID
			.ParentObjectType = oObjectEditorDialog.ParentObjectType
			.ParentPropertyName = oObjectEditorDialog.ParentPropertyName
			.EnlistInCurrentTransaction = oObjectEditorDialog.EnlistInCurrentTransaction
			Set .InterfaceMD = XService.XmlFromString( document.all("oMetadata",0).value )
			Set .Pool = oObjectEditorDialog.Pool
			
			If hasValue(oObjectEditorDialog.SkipInitErrorAlerts) Then
				.SkipInitErrorAlerts = oObjectEditorDialog.SkipInitErrorAlerts
			Else
				.SkipInitErrorAlerts = False
			End If
		End With
		Set getEditorInitializationParams = oParams
	End Function


	'-------------------------------------------------------------------------------
	' ����������:	��������� ������� ������������ ����������� ��������
	' ����������:	���������� �� ����������� ������� OnBeforeSwitch ������� Tabs
	' ���������:	true ���� �� �����, ����� false 
	Public Function OnBeforeTabsSwitch()
		OnBeforeTabsSwitch = m_oObjectEditor.CanSwitchPage
	End Function


	'-------------------------------------------------------------------------------
	' ����������:	��������� ������������ ��������
	' ����������:	���������� �� ����������� ������� OnSwitch ������� Tabs
	Public Sub OnTabsSwitch()
		' ����������������� �������
		m_oObjectEditor.SwitchToPageByPageID Tabs.ActiveTabID
	End Sub


	'-------------------------------------------------------------------------------
	' ����������:	������� �� ��������� �������� �������
	Public Sub OnNextPage
		m_oObjectEditor.WizardGoToNextPage
	End Sub


	'-------------------------------------------------------------------------------
	' ����������:	������� �� ���������� �������� �������
	Public Sub OnPrevPage
		m_oObjectEditor.WizardGoToPrevPage
	End Sub


	'-------------------------------------------------------------------------------
	' ����������:	��������� ������ � ��������� ����
	Public Sub OnSaveAndClose
		Dim vResult		' Empty - ������, ����� ObjectID ������������ �������
		
		vResult = m_oObjectEditor.Save
		If IsEmpty(vResult) Then Exit Sub
		' �� ������������ - ������� �������� ����������������
		' ��������� ReturnValue
		X_SetDialogWindowReturnValue vResult 
		' � ������� ����
		g_bOkPressed = True
		g_bCancelPressed = Empty

		window.Close
	End Sub

	
	'-------------------------------------------------------------------------------
	' ����������:	��������� ������� ������ �� �������� �������� ������
	Public Sub OnSaveAndStartNew
		Dim vResult			' Empty - ������, ����� ObjectID ������������ �������
		Dim sStatusDivHtml	' HTML DIV'a � ����������
		Dim oContentDiv		' ������ DIV'a � ����������� ���������
        
        ' �������� ��������� � ������� ���������
		vResult = m_oObjectEditor.Save
		
		' ���� ��������� �� �������, �� ����������, �������� � ������� ���������
		If IsEmpty(vResult) Then Exit Sub
		
		' ��������� ������� ��������� ObjectEditor
		m_oObjectEditor.Dispose
		Set m_oObjectEditor = Nothing
		
		' ��������� ���������� �������� � ����������:
		sStatusDivHtml = StatusDiv.outerHtml

		' �������� ���������� ����� ���� ���������:
		Set oContentDiv = document.all("x_editor_content_div",0)
		oContentDiv.InnerHtml = ""
		
		' ...��� �����, ��� �� ������ ��� �������, ������������� 
		' �� ���������� ���������� ��������� � HTML-� � IE
		XService.DoEvents
		
		' ����������� ������� ��� ����������� ���������
		oContentDiv.InnerHtml = sStatusDivHtml
		
		' ��������� ��������� ���� �������������
		Init New ObjectEditorDialogWindowContainerEventsClass
	End Sub


	'-------------------------------------------------------------------------------
	' ����������:	�������� �������������� � ��������� ����
	Public Sub OnCancel
		' � ������� ������
		window.close
	End Sub


	'-------------------------------------------------------------------------------
	' ����������:	���������� ���������� ����������
	Public Sub OnHelp
		If m_oObjectEditor.IsHelpAvailiable Then
			X_OpenHelp m_oObjectEditor.HelpPage
		End If	
	End Sub


	'-------------------------------------------------------------------------------
	':����������:	���������� ������� �������� ���� ���������
	':���������:	bOkPressed - [in] ������� ����, ��� �������� ��������� ������� �������� ��/������
	Public Function OnBeforeWindowUnload(bOkPressed)
		If m_oObjectEditor.MayBeInterrupted Then
			OnBeforeWindowUnload = m_oObjectEditor.OnClosing(bOkPressed)
		Else	
			OnBeforeWindowUnload =  "��������!" & vbNewLine & "�������� ���� � ������ ������ ����� �������� � ������������� ������!"
		End If	
	End Function


	'-------------------------------------------------------------------------------
	' ����������:	���������� �������� ���� ���������
	Public Sub OnWindowUnload
		If g_bCancelPressed Then
			m_oObjectEditor.OnCancel
		End If
		m_oObjectEditor.OnClose
		Set m_oObjectEditor = Nothing
	End Sub


	'-------------------------------------------------------------------------------
	' ����������:	����� ���������� ���������
	Public Sub OnDebugEvent
		m_oObjectEditor.ShowDebugMenu
	End Sub


	'==========================================================================
	' ���������� ������� ���������� ������
	'	[in] oEventArgs As AccelerationEventArgsClass
	Public Sub OnKeyUp(oEventArgs)
		m_oObjectEditor.OnKeyUp Me, oEventArgs
	End Sub

	'==========================================================================
	' ���������� ������� ���������� ������
	'	[in] oEventArgs As AccelerationEventArgsClass
	Public Sub OnKeyDown(oEventArgs)
		m_oObjectEditor.OnKeyDown Me, oEventArgs
	End Sub

	'==========================================================================
	Public Sub Internal_MenuExecutionHandler(oSender, oEventArgs)
		Select Case oEventArgs.Action
			Case "DoSaveAndClose"
				OnSaveAndClose
			Case "DoNextPage"
				OnNextPage
			Case "DoPrevPage"
				OnPrevPage
			Case "DoSaveAndStartNew"
				OnSaveAndStartNew
		End Select
	End Sub
	
	'==========================================================================
	' ������������ ������� �������� ���������
	' ������������ ��� ����������� ������
	'	[in] sCurrentTab - ������� �������� ���������
	'	[in] sNewTab - �������� ���������, ������� ���� ������� ��������
	Public Sub SetActiveTab(sCurrentTab, sNewTab)
		' ���� ��������� � �������� ������� �������� ��������� �� ��������� � ������� ��������� ��������� - ������ �� ������
		' ���������, ���� ������������ ��������� �� ��������.
		If Tabs.ActiveTabID = sCurrentTab And sCurrentTab <> sNewTab Then _
			Tabs.ActiveTabID = sNewTab
	End Sub
	
End Class


Dim g_bExiting			' ������� �������� ����
Dim g_oController		' ��������� ��������� ��������� ObjectEditorScriptletContainerClass		
Dim g_bCancelPressed	' ������� ������� Cancel (������)
Dim g_bOkPressed		' ������� ������� OK (������)

Set g_oController = Nothing

'<����������� window � document>
'======================================================================
' ������������� ��������
Sub Window_OnLoad
	' ������ ������������ ���� Cancel...
	X_SetDialogWindowReturnValue Empty
	
	If X_ACCESS_DENIED Then 
		document.all("XEditor_cmdCancel").disabled = False
		Exit Sub
	End If
	' ���������� �������� ���� ������ ��������
	StatusDiv.innerText = "���������� �������� ��������..."
	X_WaitForTrue "XEditor_InitializeAndRun", "X_IsDocumentReady(Null)"
End Sub

'======================================================================
' ��������� ������ �������� ���� ���������
Sub Window_OnBeforeUnload
	Dim sUserString	' ������ ������������
	If X_ACCESS_DENIED Then Exit Sub
	If IsNothing(g_oController) Then Exit Sub
	sUserString =  vbNullString & g_oController.OnBeforeWindowUnload(g_bOkPressed)
	If 0 <> Len(sUserString) Then window.event.returnValue = sUserString
End Sub

'======================================================================
' ��������� �������� ��������
Sub Window_OnUnLoad
	' �������� ������� �������� ����
	g_bExiting = True
	If X_ACCESS_DENIED Then Exit Sub
	If IsNothing(g_oController) Then Exit Sub
	g_oController.OnWindowUnload
End Sub		

'======================================================================
' ���������� ������� F1
Sub Document_OnHelp
	If IsNothing(g_oController) Then Exit Sub
	If X_MD_HELP_AVAILABLE Then
		window.event.returnValue = False
		g_oController.OnHelp 
	End If
End Sub

'======================================================================
Sub Document_OnKeyUp
	If window.event Is Nothing Then Exit Sub
	If g_oController Is Nothing Then
		If window.event.KeyCode = VK_ESC Then XEditor_cmdCancel_onClick
		Exit Sub
	Else
		With window.event
			If Not .srcElement Is Nothing Then
				If Not IsNull(.srcElement.getAttribute("X_IgnoreHtmlEvents")) Then
					Exit Sub
				End If
			End If
			g_oController.OnKeyUp CreateAccelerationEventArgsForHtmlEvent()
		End With
	End If
End Sub

'======================================================================
Sub Document_OnKeyDown
	If window.event Is Nothing Then Exit Sub
	If g_oController Is Nothing Then Exit Sub
	With window.event
		If Not .srcElement Is Nothing Then
			If Not IsNull(.srcElement.getAttribute("X_IgnoreHtmlEvents")) Then Exit Sub
		End If
		g_oController.OnKeyDown CreateAccelerationEventArgsForHtmlEvent()
	End With
End Sub

'</����������� window � document>


'<����������� ������� XTabStrip>
'======================================================================
' ��������� ������� ������������ ����������� ��������
Sub Tabs_OnBeforeSwitch()
	If IsNothing(g_oController) Then Exit Sub
	window.event.returnValue = g_oController.OnBeforeTabsSwitch
End Sub

'======================================================================
' ��������� ������������ ��������
Sub Tabs_OnSwitch()
	If IsNothing(g_oController) Then Exit Sub
	g_oController.OnTabsSwitch
End Sub
'</����������� ������� XTabStrip>


'<����������� ������>
'======================================================================
' ��������� ������� ������ "��������"
Sub XEditor_cmdCancel_onClick
	g_bOkPressed = Empty
	g_bCancelPressed = True
	If IsNothing(g_oController) Then
		window.Close
	Else
		g_oController.OnCancel
	End If
End Sub

'======================================================================
' ���������� ������� �� ������ "�������"
Sub XEditor_cmdHelp_OnClick
	Document_OnHelp
End Sub
'</����������� ������>


'======================================================================
Sub XEditor_InitializeAndRun()
	Dim oController
	Set oController = New ObjectEditorDialogWindowContainerClass
	If oController.Init(New ObjectEditorDialogWindowContainerEventsClass) Then
		Set g_oController = oController 
	End If
End Sub


'======================================================================
' ����� "����������" �������
' ���������� �� PopUp-���� � CTRL (���� � �������-CTRL-�� �����������) �� ��������� 
Sub OnDebugEvent
	If IsNothing(g_oController) Then Exit Sub
	If Not( window.event.ctrlKey  Or X_IsDebugMode)Then Exit Sub
	window.event.returnValue = False
	window.event.cancelBubble = True
	g_oController.OnDebugEvent
End Sub
