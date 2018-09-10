'*******************************************************************************
' ���������� ������� � ������� ��������� ���������� �������.
' ������ "�����" �� ������, ������� �������� � x-filter.htc
' ��������: ��������� �� ���� ���������� ���������� ������ ����������� � ������� parent
'*******************************************************************************
Option Explicit

'==============================================================================
' ����������:	���������� IObjectContainerEventsClass
'				��� ������������� � ��������� � ������� �������
' ��������� ������� ������ ����������, �.�. ������������ ����������� ObjectEditorClass
Class ObjectEditorScriptletContainerEventsClass
	' ��������� ������ ���������� ����-��������, �.�. �������� ���������� � ���������������� ��������� FilterObject
	' � x-list - ��� XListPageClass
	' � x-tree - ��� XTreePageClass
	Public OuterContainerPage

	' ������� EventEngine - ��� ��������� ������� � ��������, �� ������� ������������� ������ 
	'	���� ������������ �������:
	'		EnableControls (EventArgs - EnableControlsEventArgs) - (���)������������ ���������
	'		Accel (EventArg: AccelerationEventArgsClass) - ������� �������-������������
	'		Apply (EventArg: Nothing) - ���������� ������� ���������� (XFW �� ����������, �� ����� ������������ ���������� ���)
	'		SetCaption (EventArg: SetCaptionEventArgsClass) - ��������� ��������� �������
	Public ExternalEventEngine
		
	'==========================================================================
	' �������� ����������� �� ��������� ���������
	'	[in] oObjectEditor
	'	[in] sEditorCaption As String - ��������� ���������. ����� ��������� HTML-��������������.
	'	[in] sPageCaption As String - ��������� ��������. ����� ��������� HTML-��������������.
	Public Sub OnSetCaption(oObjectEditor, sEditorCaption, sPageCaption)
		If ExternalEventEngine.IsHandlerExists("SetCaption") Then 
			With New SetCaptionEventArgsClass
				.EditorCaption = sEditorCaption
				.PageTitle = sPageCaption
				XEventEngine_FireEvent ExternalEventEngine, "SetCaption", oObjectEditor, .Self()				
			End With
		End If
	End Sub


	'==========================================================================
	' �������� ������ �������� ��������� ����������� ��������� ����������
	Public Sub OnEnableControls(oObjectEditor, bEnable, vReserved)
		' �� ������ ��������� � ��� ������ �����, �� �� ����� ���� �����
		If oObjectEditor.IsMultipageEditor Then
			Tabs.Enabled = bEnable
		End If
		' ��� DoEvents ������ "������", �� ����� ������ �� �������
		XService.DoEvents
		' ����������� ������� "EnableControls" �����
		With New EnableControlsEventArgsClass
			.Enable = bEnable
			XEventEngine_FireEvent ExternalEventEngine, "EnableControls", Me, .Self()
		End With
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
		If oObjectEditor.IsEditor Then
			If oObjectEditor.IsMultipageEditor Then
				'TODO: �� ����� ����������: TabsRow.style.display = "block"
				XEditor_xPaneTabs.style.display = "block"
				Tabs.style.display = "block"
				XService.DoEvents
			End If
		Else
			err.Raise -1, "SetUiByMode", "Wizard not supported for filters!"	
		End If
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
	' �������� �������� �� ��������� ������� ��������
	'	[in] oArgs As SetWizardOperationsArgsClass
	Public Sub OnSetWizardOperations(oObjectEditor, oArgs)
		' � �������� ������� �� ����������
	End Sub

	
	'==========================================================================
	' �������� �������� �� ��������� ������� ��������
	'	[in] oArgs As SetWizardOperationsArgsClass
	Public Sub OnSetEditorOperations(oObjectEditor, oArgs)
		' Nothing To Do
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
	' ���������� ������� ���������� ������
	'	[in] oSender As �������� �������
	'	[in] oEventArgs As AccelerationEventArgsClass
	Public Sub OnKeyUp(oSender, oEventArgs)
		' ������� ��������� ������ (��������, ����� ������������ ���������� ������/������ �� ������� ������)
		XEventEngine_FireEvent ExternalEventEngine, "Accel", Me, oEventArgs
	End Sub
End Class


'==============================================================================
' ����������:	���� �� ���������� ObjectEditorContainerClass
' ����������:	��������� ������� ������ � ������� �� ObjectContainerEventsClass
'				�� �������� �������������...
Class ObjectEditorScriptletContainerClass
	Public m_oObjectEditor		' �������� (��������� ObjectEditorClass)
	Public XmlState				' IXMLDOMElement, ��������� �������
	Public QueryString			' ��������� QueryStringClass	
	
	'==========================================================================
	' ����������:	�������������
	' ���������:
	'	true ���� �� ������, ����� false 
	' ���������:	
	'	[in] oContainerEvents - ��������� ObjectContainerEventsClass
	' ����������:	
	' �����������:
	' ������: 		
	Public Function Init(oContainerEvents)
		Dim sInitResult		' ��������� �� Init
		Dim oObjectEditor	' ObjectEditor
		Dim oParams			' As ObjectEditorInitializationParametersClass

		Set oObjectEditor = New ObjectEditorClass
		Set oParams = getEditorInitializationParams()
		sInitResult = oObjectEditor.Init(oContainerEvents, oParams)
		If Len("" & sInitResult) > 0 Then
			oContainerEvents.OnSetStatusMessage oObjectEditor, sInitResult, Null
			Init = False
		Else
			Set m_oObjectEditor = oObjectEditor
			Init = True
		End If
	End Function


	'==========================================================================
	' ���������� ����������� ���������������� ��������� ��� ��������
	Private Function getEditorInitializationParams()
		Dim oParams				' As ObjectEditorInitializationParametersClass
		
		Set oParams = New ObjectEditorInitializationParametersClass
		' �������������� ������ ���������
		With oParams
			.ObjectType = X_PAGE_OBJECT_TYPE
			.MetaName = X_PAGE_METANAME
			.CreateNewObject = True
			If Not XmlState Is Nothing Then
				.ObjectID = XmlState.getAttribute("main-oid")
				Set .InitialObjectSet = XmlState
			End If
			Set .QueryString = QueryString
			Set .InterfaceMD = XService.XmlFromString( document.all("oMetadata",0).value )
			.SkipInitErrorAlerts = True
		End With	
		Set getEditorInitializationParams = oParams
	End Function


	'==========================================================================
	' ����������:	��������� ������� ������������ ����������� ��������
	' ���������:
	'	true ���� �� �����, ����� false 
	' ���������:	
	' ����������:	
	' �����������:
	' ������: 		
	Public Function OnBeforeTabsSwitch()
		OnBeforeTabsSwitch = m_oObjectEditor.CanSwitchPage
	End Function
	
	
	'==========================================================================
	' ����������:	��������� ������������ ��������
	' ���������� �� ����������� ������� OnSwitch ������� Tabs
	Public Sub OnTabsSwitch()
		' ����������������� �������
		m_oObjectEditor.SwitchToPageByPageID Tabs.ActiveTabID
	End Sub
	
	
	'==========================================================================
	' ����������:	����������� �������
	' ���������:
	' ���������:
	' ����������:	
	' �����������:
	' ������: 		
	Public Sub OnHelp
		If m_oObjectEditor.IsHelpAvailiable Then
			X_OpenHelp m_oObjectEditor.HelpPage
		End If	
	End Sub


	'==========================================================================
	' ����������:	�������� ��������
	' ���������:
	' ���������:
	' ����������:	
	' �����������:
	' ������: 		
	Public Sub OnWindowUnload
		Set m_oObjectEditor = Nothing
	End Sub
	
	
	'==========================================================================
	' ����������:	�������� "���������" ���������
	' ���������:
	' 	=true ���� �������� "�����", ����� false
	' ���������:
	' ����������:	
	' �����������:
	' ������: 		
	Public Function GetMayBeInterrupted
		GetMayBeInterrupted = m_oObjectEditor.MayBeInterrupted
	End Function
	
	
	'==========================================================================
	' ����������:	����� ����������� �������
	' ���������:
	' ���������:
	' ����������:	
	' �����������:
	Public Sub 	OnClearRestrictions
		m_oObjectEditor.Internal_RestartEditor
	End Sub
	
	
	'==========================================================================
	' ����������:	��������� ����������� �������
	' ���������:
	' ���������:
	'	[in] oFilterObjectGetRestrictionsParamsObject - ��������� FilterObjectGetRestrictionsParamsClass
	' ����������:	
	' �����������:
	Public Sub 	OnGetRestrictions(oFilterObjectGetRestrictionsParamsObject)
		Dim oXmlObject		' ������ �� �������� �� �������� �����������
		Dim oXmlProperty	' �������� �������
		Dim oXmlObjectRef	' ������ �� oXmlObject �� ������ ������
		' "��������" ��� ���������
		If Not m_oObjectEditor.FetchXmlObject(False) Then
			oFilterObjectGetRestrictionsParamsObject.ReturnValue = False 
			Exit Sub
		End If	
		' ������������ �������� �������
		Set oXmlObject = m_oObjectEditor.XmlObject
		For Each oXmlProperty In oXmlObject.SelectNodes("*")
			If IsNull(oXmlProperty.dataType) Then
				' ��������� �������� - ������ ��������������
				For Each oXmlObjectRef In oXmlProperty.selectNodes("*/@oid")
					oFilterObjectGetRestrictionsParamsObject.ParamCollectionBuilder.AppendParameter oXmlProperty.TagName, oXmlObjectRef.text
				Next 
			ElseIf 0<Len(oXmlProperty.Text) Then
				oFilterObjectGetRestrictionsParamsObject.ParamCollectionBuilder.AppendParameter oXmlProperty.TagName, oXmlProperty.Text
			End If	 
		Next
	End Sub	
	
	
	'==========================================================================
	' ���������� ���������� ����
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
	Public Sub SetFocus()
		window.focus
		m_oObjectEditor.SetDefaultFocus
	End Sub
End Class

' ������� �������� ����
Dim g_bExiting

' ��������� ��������� ��������� ObjectEditorScriptletContainerClass		
Dim g_oController
g_oController = Empty

'==============================================================================
' ���������� ������� ���������� � ����������, ������� ������ ��������
' ���������: ������������ ������� "Apply" � EventEngine, ���������� ������� ��� �������������
Public Sub ApplyFilter
	XEventEngine_FireEvent g_oController.m_oObjectEditor.ObjectContainerEventsImp.ExternalEventEngine, "Apply", Nothing, Nothing
End Sub

'<����������� ������� window � document>
'==============================================================================
' ��������� �������� ��������
Sub Window_OnUnload
	g_bExiting = True
	If Not IsObject(g_oController) Then  Exit Sub
	g_oController.OnWindowUnload 
	Set g_oController = Nothing
	g_oController = Empty
End Sub

'==============================================================================
' ���������� ������� F1
Sub Document_OnHelp
	If g_bExiting Then Exit Sub
	If Not IsObject(g_oController) Then Exit Sub
	g_oController.OnHelp() 
End Sub

'==============================================================================
' ���������� Html-������� OnKeyUp ���������.
' ������������ ������� � ��������� ObjectEditorScriptletContainerClass
Sub document_OnKeyUp
	If window.event Is Nothing Then Exit Sub
	If g_oController Is Nothing Then Exit Sub
	With window.event
		If Not .srcElement Is Nothing Then
			If Not IsNull(.srcElement.getAttribute("X_IgnoreHtmlEvents")) Then
				Exit Sub
			End If
		End If
		window.event.cancelBubble = True
		window.event.returnValue = False
		
		g_oController.OnKeyUp CreateAccelerationEventArgsForHtmlEvent()
	End With
End Sub
'<����������� ������� window � document>


'<����������� ������� XTabStrip>
'==============================================================================
' ��������� ������� ������������ ����������� ��������
Sub Tabs_OnBeforeSwitch()
	If Not IsObject(g_oController) Then  Exit Sub
	window.event.returnValue = g_oController.OnBeforeTabsSwitch
End Sub


'==============================================================================
' ��������� ������������ ��������
Sub Tabs_OnSwitch()
	' ����������������� �������
	If Not IsObject(g_oController) Then  Exit Sub
	g_oController.OnTabsSwitch
End Sub
'</����������� ������� XTabStrip>


'<������ ���������� IFilterObject>
'==============================================================================
' ����������:	IFilterObject::Init
' ���������:    
' 	���������� ������� ��� �� � �������
' ���������:	
'	[in] oEventEngine As XEventEngine - �������� �������, � ������� ������ ����� ������������ ���� ������� ��� ����������� ����������
'	[in] oFilterObjectInitializationParamsObject	- ��������� ������������� �������
' ����������:	
'	���������� ������������� ������� ��������
Function public_Init(oEventEngine, oFilterObjectInitializationParamsObject)
	Dim oContainer		' As ObjectEditorScriptletContainerEventsClass - ���������� ���������� ��������� ���������
	Dim oController		' As ObjectEditorScriptletContainerClass - ������ ������ ���������
	Dim oReference		' ��������� ������ (��������)
	Dim aObjectIDs		' As ObjectIdentity() - ������ ��������������� ����������� ��������
	Dim i
	Dim sString			' As String	- 
	Dim aString			' As String() -
	Dim oGetObjectsResponse	' As XGetObjectsResponse - ����� ������� GetObjects
	
	' ��������� ��� ���� � ������� ��������
	Set x_oRightsCache = oFilterObjectInitializationParamsObject.GetRightsCache
	Set oController = New ObjectEditorScriptletContainerClass
	Set oController.XmlState =  oFilterObjectInitializationParamsObject.XmlState
	Set oController.QueryString =  toObject(oFilterObjectInitializationParamsObject.QueryString)
	Set oContainer = New ObjectEditorScriptletContainerEventsClass
	Set oContainer.OuterContainerPage = toObject(oFilterObjectInitializationParamsObject.OuterContainerPage)
	Set oContainer.ExternalEventEngine = oEventEngine
	
	If Not oController.XmlState Is Nothing Then
		If "" & X_GetMD().GetAttribute("md5")= "" & oController.XmlState.GetAttribute("metadataMD5") Then
			With oController.XmlState
				.RemoveAttribute "metadataMD5"
				' ������� �� ���� �������� � �������� �������, �� ������� ��������� �������� ������
				For Each oReference In .SelectNodes("*/*/*[@oid]")
					' ��������� ��� ������ ������� ���� � ����
					If Nothing Is .SelectSingleNode(oReference.nodeName & "[@oid='" & oReference.getAttribute("oid") & "']") Then
						' ���� ������ �� ���������, �� ����� ������� � �������
						If "temporary" <> ("" & X_GetTypeMD(oReference.nodeName).GetAttribute("tp")) Then
							If 0=InStr(1, sString, " " & oReference.nodeName & " " & oReference.GetAttribute("oid")) Then
								sString = sString & " " & oReference.nodeName & " " & oReference.GetAttribute("oid")
							End If
						Else
							' ����� (������ - ���������, �� ���� �����������) - ������� ������
							oReference.parentNode.removeChild oReference
						End If
					End If
				Next
				sString = Trim(sString)
				If 0<>Len(sString) Then
					aString = Split( sString, " ")
					ReDim aObjectIDs( (UBound(aString)+1)/2-1 )
					For i=0 To UBound(aObjectIDs)
						' ����������: 1-�� �������� ������������ ����, 2-�� - �������������
						Set aObjectIDs(i) = internal_New_XObjectIdentity( aString(i*2), aString(i*2+1) )
					Next

					With New XGetObjectsRequest
						.m_sName = "GetObjects"
						.m_aList = aObjectIDs
						Set oGetObjectsResponse = X_ExecuteCommand( .Self )
					End With
					
					For Each oReference In oGetObjectsResponse.m_oXmlObjectsList.SelectNodes("*")
						If IsNull(oReference.GetAttribute("not-found")) Then
							.AppendChild(oReference)
						Else
							.SelectNodes("//" & oReference.nodeName & "[@oid='" & oReference.GetAttribute("oid") & "']" ).removeAll
						End If
					Next
				End If	
			End With
		Else
			' ���������� � ���������� ���� ���������� - ������� ����a������ ������
			Set oController.XmlState = Nothing	
		End If
	End if

	If oFilterObjectInitializationParamsObject.DisableContentScrolling Then
		' DIV'�, � ������� ����������� ���������� ���� ������� �������� ������� ����� �.�. ����� ������� �� ��������� scrollbar.
		document.all("x_editor_content_div",0).style.overflow = "hidden"
	End If
	
	If False = oController.Init(oContainer) Then
		public_Init = False
		Exit Function
	End If
	
	Set g_oController = oController
	public_Init = True	
End Function


'==============================================================================
' ����������:	���������� ���������� � ������� �������� ��������
' ���������:	��������� ObjectEditorClass  
' ����������:	
Function public_get_ObjectEditor
	Set public_get_ObjectEditor = Nothing
	If g_bExiting Then Exit Function
	If Not IsObject(g_oController) Then Exit Function
	Set public_get_ObjectEditor = g_oController.m_oObjectEditor
End Function


'-------------------------------------------------------------------------------
' ����������:	IFilterObject::GetXmlState
' ���������:    ���� ���� �������� ���������, � ������� ��������� ��������� ���������������� �������
Function public_GetXmlState
	Dim oXmlPool	' ����� ���� ���������
	Dim oXmlObject	' ������ � ���������
	Set public_GetXmlState = Nothing
	If g_bExiting Then Exit Function
	If Not IsObject(g_oController) Then Exit Function
	' ���������� ���� ������ � ��������� "�����" ������
	g_oController.m_oObjectEditor.FetchXmlObject(True)
	Set oXmlPool = g_oController.m_oObjectEditor.Pool.Xml.CloneNode( true)
	For Each oXmlObject In oXmlPool.SelectNodes("*[local-name()!='x-pending-actions']")
		' ����� ������ ������ ���������� �������
		If "temporary" <> ("" & X_GetTypeMD(oXmlObject.nodeName).GetAttribute("tp")) Then
			' ������ ����������, ������ ��� �� ����...
			oXmlObject.ParentNode.removeChild oXmlObject
		End If
	Next
	' ������ ��� �������� dirty
	oXmlPool.selectNodes("//@dirty").removeAll
	' ��������� �������� MD5 �� ����������
	oXmlPool.setAttribute "metadataMD5", "" & X_GetMD.GetAttribute("md5")
	' ��������� ������������� "��������" �������, �.�. ����, ��� �������� ���������� ��������
	oXmlPool.setAttribute "main-oid", g_oController.m_oObjectEditor.ObjectID
	
	' ����� ��������
 	Set public_GetXmlState = oXmlPool
End Function


'-------------------------------------------------------------------------------
' ����������:	IFilterObject::IsComponentReady
' ���������:    ������� ������ ������������� �������
Function public_get_IsComponentReady()
	public_get_IsComponentReady = X_IsDocumentReady(Null)
End Function


'-------------------------------------------------------------------------------
' ����������:	IFilterObject::IsReady
' ���������:    
' 	���������� ������� ������ ���������� �������
Function public_get_IsReady()
	dim bReady
	bReady = public_get_IsComponentReady And IsObject(g_oController) 
	If bReady Then
		bReady = not public_get_IsBusy
	End If
	public_get_IsReady = bReady
End Function


'-------------------------------------------------------------------------------
' ����������:	IFilterObject::Enabled
'		���������� ������������
Function public_get_Enabled()
	public_get_Enabled =  True
	If g_bExiting Then Exit Function
	If Not IsObject(g_oController) Then Exit Function
	public_get_Enabled = g_oController.m_oObjectEditor.IsControlsEnabled
End Function

Sub public_put_Enabled( bEnabled)
	If g_bExiting Then Exit Sub
	If Not IsObject(g_oController) Then Exit Sub
	g_oController.m_oObjectEditor.EnableControlsInternal bEnabled, False
	' �� ������ ��������� � ��� ������ �����, �� �� ����� ���� �����
	If g_oController.m_oObjectEditor.IsMultipageEditor Then
		Tabs.Enabled = bEnabled
	End If
End Sub


'-------------------------------------------------------------------------------
' ����������:	IFilterObject::IsBusy
Function public_get_IsBusy()
	public_get_IsBusy = False
	If g_bExiting Then Exit Function
	If not IsObject(g_oController) then Exit Function
	public_get_IsBusy = Not g_oController.GetMayBeInterrupted
End Function


'-------------------------------------------------------------------------------
' ����������:	IFilterObject::ClearRestrictions
' ����������:
'	���������� ��������� ������� � ��������������...	
Sub public_ClearRestrictions()
	If g_bExiting Then Exit Sub
	If not IsObject(g_oController) Then Exit Sub
	g_oController.OnClearRestrictions
End Sub


'-------------------------------------------------------------------------------
' ����������:	IFilterObject::GetRestrictions
' ���������:	
Sub public_GetRestrictions(oFilterObjectGetRestrictionsParamsObject)
	If g_bExiting Then Exit Sub
	If not IsObject(g_oController) Then Exit Sub
	If Nothing Is g_oController Then Exit Sub
	g_oController.OnGetRestrictions(oFilterObjectGetRestrictionsParamsObject)  
End Sub

'-------------------------------------------------------------------------------
' ����������:	IFilterObject::ShowDebugMenu
Sub public_ShowDebugMenu()
	If g_bExiting Then Exit Sub
	If IsNothing(g_oController) Then Exit Sub
	g_oController.OnDebugEvent
End Sub


'-------------------------------------------------------------------------------
' ����������:	IFilterObject::OnKeyUp
' ���������� ���������� ������, ������� � ����������
'	[in] oEventArgs As AccelerationEventArgsClass
Sub public_OnKeyUp(oEventArgs)
	If g_bExiting Then Exit Sub
	If IsNothing(g_oController) Then Exit Sub
	g_oController.OnKeyUp oEventArgs
End Sub

'-------------------------------------------------------------------------------
' ����������:     IFilterObject::SetFocus
' ��������� ������
Sub public_SetFocus()
      If g_bExiting Then Exit Sub
      If IsNothing(g_oController) Then Exit Sub
      g_oController.SetFocus
End Sub

'</������ ���������� IFilterObject>


'======================================================================
' ���������� ������� oncontextmenu - ����� "����������" �������
' ���������� �� PopUp-���� � CTRL (���� � �������-CTRL-�� �����������) �� ��������� 
Sub OnDebugEvent
	If Not( window.event.ctrlKey  Or X_IsDebugMode)Then Exit Sub
	window.event.returnValue = False
	window.event.cancelBubble = True
	public_ShowDebugMenu()
End Sub
