Option Explicit

'===============================================================================
'@@XListPageClass
'<GROUP !!CLASSES_x-list-page><TITLE XListPageClass>
':����������:	����� �������� ���������� ������ � �������.
'@@!!MEMBERTYPE_Methods_XListPageClass
'<GROUP XListPageClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_XListPageClass
'<GROUP XListPageClass><TITLE ��������>
'
'<Ignore>
' �������:
'	Load			- �������� �������� (EventArgs: Nothing)
'	UnLoad			- �������� �������� (EventArgs: Nothing)
'	Ok				- ������� �� �� � ������ ������ (EventArgs: ListSelectEventArgsClass)
'	ResetFilter		- ������� �� �������� ������ (EventArgs: Nothing)
'</Ignore>
Class XListPageClass
	Public QueryString			' As QueryString - ���������, ���������� ��������
	Public MetaName				' As String	- ��� ������ � ����������
	Public ObjectType			' As String	- ������������ ���� �������� � ������
	Public FilterObject			' As Object - ������ �������

	Private m_nMode					' As Byte - ����� ������ ������ (LM_LIST, LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE)
	Private m_oXList				' As XListClass	- ��������� ������
	Private m_oListMD				' As IXMLDOMElement - ���������� ������ (���������� � ������� ������ ��� �������������)
	Private EVENTS					' As String - ������ �������������� �������
	Private m_oEventEngine			' As CROC.XEventEngine
	Private m_oEventEngineFilter	' As CROC.XEventEngine - EventEngine ��� ��������� ������� �� ������� (���������� � x-filter.htc)
	Private m_bIsDialog				' As Boolean - ������� ����, ��� �������� ������� � ���������� ���� (��� ���� ������� ����� LM_LIST)
	Private m_bMayBeInterrupted		' As Boolean - ������� ����, ��� ������������ ����� ��������� �������� ������� ��������
	Private m_oReportXsl			' As XSL ��� ���������� ������
	Private m_bOffFilterViewState	' As Boolean	- ������� "�� ��������� ��������� �������"

	Private m_nServerMaxRows        ' As Long - ������������ ���������� ����� � ������, ������������ ��������
	Private m_nFirstRow             ' As Long - ����� ������ ������
	Private m_bPaging	            ' As Bool - ������� �������� � ������ ���������
	Private m_sRestrictions                  ' As String  - ��������� ���������� ���������� �������� �������
	Private m_sRestrictionsDescription      ' As String  - ��������� ���������� ���������� �������� �������� �������

	' HTML Controls
	Private NoDataMsg				' As IHTMLElement - DIV � ����������
	Private ListHolder				' As IHTMLElement - TD, � ������� ���������� ������ (XListView)
	Private xPaneFilter				' As IHTMLElement - TD - ��������� �������
	Private cmdHideFilter			' As IHTMLElement - ������ ������/�������� ������
	
	'==========================================================================
	' "�����������"
	Private Sub Class_Initialize
		m_nFirstRow = 1
		m_bPaging	= False
		m_bMayBeInterrupted = true
		If IsObject(g_oXListPage) Then _
			If Not g_oXListPage Is Nothing Then _
				Err.Raise -1, "XListPageClass::Class_Initialize", "��������� ������������� ������ ������ ���������� XListPageClass"
		' ��������� ������� ����������
		Set QueryString = X_GetQueryString()
		ObjectType = X_PAGE_OBJECT_TYPE
		MetaName = X_PAGE_METANAME
		m_nMode = LIST_MODE
		m_nServerMaxRows = iif( LIST_MD_MAXROWS > 0, LIST_MD_MAXROWS, DEFAULT_MAXROWS )	
		
		
		EVENTS = "Load,UnLoad,Ok,ResetFilter,Refresh"
		Set m_oEventEngine = X_CreateEventEngine
		' �������������� ���������������� ����������� ������� ����������� ��������� (�� ����� �����)
		m_oEventEngine.InitHandlers EVENTS, "usrXListPage_On"
		If Not m_oEventEngine.IsHandlerExists("Ok") Then
			m_oEventEngine.AddHandlerForEvent "Ok", Me, "OnOk"
		End If

		Set m_oXList = New XListClass
				
		m_oXList.ObjectType = ObjectType
		' ��������� ���������� ������ ��� ���������� �������� ����������
		m_oXList.Internal_SetContainer "g_oXListPage"
		' ���������� �� ������� "SetMenuItemVisibility" ��������� ���������/����������� ������� ����
		m_oXList.EventEngine.AddHandlerForEvent "SetMenuItemVisibility", Me, "OnSetMenuItemVisibility"
		' ���������� �� ������� "GetRestrictions" ������ ���������� XList
		m_oXList.EventEngine.AddHandlerForEvent "GetRestrictions", Me, "OnGetRestrictions"
		' ���������� �� ������� "AfterListReload" ������ ���������� XList
		m_oXList.EventEngine.AddHandlerForEvent "AfterListReload", Me, "OnAfterListReload"
	End Sub


	'==========================================================================
	' ������������� ��������
	'	[in] sMenuMDXml As String	- ���������� ����
	Sub Internal_Init( sMenuMDXml)
		Dim oMenuXml	' As IXMLDOMElement - ���������� ����
		
		m_bIsDialog = Not Eval("IsEmpty(dialogHeight)")
		
		' ���� ����� ������ ���������� ��������, ������� ����� �������
		If LM_MULTIPLE = Mode OR LM_MULTIPLE_OR_NONE = Mode Then
			m_oXList.CheckBoxes = True
		End If
		
		' ������������� ���������� �� ������ �������� ����������, ������������� ��������� ����� � ���������
		m_oXList.ShowLineNumbers = Not LIST_MD_OFF_ROWNUMBERS
		m_oXList.GridLines = Not LIST_MD_OFF_GRIDLINES
		m_oXList.OffCreate = LIST_MD_OFF_CREATE
		m_oXList.OffEdit = LIST_MD_OFF_EDIT
		m_oXList.OffClear = LIST_MD_OFF_CLEAR
		m_oXList.OffReport = LIST_MD_OFF_REPORT
		m_oXList.IdentifiedBy = LIST_MD_IDENTIFIED_BY
		m_oXList.TypedBy = LIST_MD_TYPED_BY		
		m_oXList.MaxRows = ServerMaxRows
		m_oXList.UseEditor = LIST_MD_USE_EDITOR
		m_oXList.UseWizard = LIST_MD_USE_WIZARD

		' ��������� URL ���������� ������
		m_oXList.Loader =  "x-list-loader.aspx?OT=" & ObjectType & "&MetaName=" & MetaName	
		m_oXList.Restrictions = QueryString.GetValue("RESTR","")
		m_oXList.ValueObjectIDs = QueryString.GetValue("VALUEOBJECTID","")
		
		' �������������� ����
		If Len(sMenuMDXml) > 0 Then
			Set oMenuXml = XService.XMLFromString(sMenuMDXml)
			If Not oMenuXml Is Nothing Then
				m_oXList.InitMenu oMenuXml
				' ������� ���� �����������
				m_oXList.Menu.AddExecutionHandler X_CreateDelegate(Me, "MenuExecutionHandler")
			End If
		End If

		Internal_InitializeHtmlControls
		' ������� ���������� ������ �������� ��������	
		window.status = "�������� �������� ������� �������..."
		
		Internal_Init2
	End Sub

	'==========================================================================
	' �������������� ������ �� HTML ��������
	' �� ����������� �������� ����� document.all, ��� ���
	' �������� ���������� ������ �����, ������� ASP.Net ���� ��������� ������������...
	Sub Internal_InitializeHtmlControls
		Set NoDataMsg = document.all("XList_ContentPlaceHolderForList_NoDataMsg")
		Set ListHolder = document.all("XList_ContentPlaceHolderForList_ListHolder")
		Set m_oXList.ListView = document.all( "List")

		If X_MD_PAGE_HAS_FILTER Then
			Set FilterObject = X_GetFilterObject( document.all( "FilterFrame") )
			Set xPaneFilter = document.all("XList_xPaneFilter")
		End If
		If Not X_MD_OFF_HIDEFILTER Then _
			Set cmdHideFilter = document.all("XList_cmdHideFilter")
	End Sub
	
	'==========================================================================
	' ������������� �������� - ���� 2
	' ���������� �� ��������� �������� ��������
	Sub Internal_Init2
		m_bMayBeInterrupted = false

		If X_MD_PAGE_HAS_FILTER Then
			' �������������� ������
			g_oXListPage.Internal_InitFilter()
		Else
			Internal_Init3 ' �������� ��� - ������ �� �����������
		End If	
	End Sub

	
	'==========================================================================
	' ������������� �������
	' ���������� �� ��������� �������� ����������� ������� (FilterObject.IsComponentReady = True)
	Sub Internal_InitFilter
		Dim oParams			' ��������� ��� ������������� �������
		Dim oFilterXmlState	' As XMLDOMElement - ��������������� ��������� �������
		Dim bInit			' AS Boolean - ������� �������������
		
		window.status = "������������� �������..."
		Set oParams = New FilterObjectInitializationParamsClass
		Set oParams.QueryString = g_oXListPage.QueryString
		Set oParams.OuterContainerPage = Me
		oParams.DisableContentScrolling = True
		m_bOffFilterViewState = X_MD_FILTER_OFF_VIEWSTATE
		If m_bOffFilterViewState = False Then
			If GetDataCache("FilterXmlState", oFilterXmlState) Then
				Set oParams.XmlState = oFilterXmlState
			End If
		End If
		On Error Resume Next
		
		Set m_oEventEngineFilter = X_CreateEventEngine
		m_oEventEngineFilter.AddHandlerForEvent "EnableControls", Me, "Internal_On_Filter_EnableControls"
		m_oEventEngineFilter.AddHandlerForEvent "Accel", Me, "Internal_On_Filter_Accel"
		m_oEventEngineFilter.AddHandlerForEvent "Apply", Me, "Internal_On_Filter_Apply"
		bInit = FilterObject.Init (m_oEventEngineFilter, oParams)

		If Err Then
			If Not X_HandleError Then
				X_ErrReportEx Err.Description, Err.Source
			End If
			bInit = False
		End If
		On Error GoTo 0
		If bInit Then
			' ������� ���������� ������������� ��������
			X_WaitForTrue "g_oXListPage.Internal_Init3()" , "g_oXListPage.FilterObject.IsReady"
		Else
			Alert "������ ������������� �������!"
			Internal_Init3
		End If
	End Sub


	'==========================================================================
	' ������������� �������� - ���� 3
	' ���������� �� ���������� ������������� ��������
	Sub Internal_Init3
		If (X_MD_PAGE_HAS_FILTER And LIST_MD_OFF_LOAD) Then
			NoDataMsg.innerHTML = "������� ������ &quot;<span title='������� ����� ��� �������� ������...' style='cursor: default;font-weight: bold;' language='VBSCript' onclick='ReloadList'>��������</span>&quot; ��� �������� ������."
		End If
		window.status = "������������� �������� ���������."

		Internal_FireEvent "Load", Nothing

		m_bMayBeInterrupted = true

		' ���������, ��� ��������� ��������� �������� ������
		If Not LIST_MD_OFF_LOAD Then
			ReloadList()
		Else
			EnableControls True
			XList.SetDefaultFocus(FilterObject)
		End If

		g_bFullLoad = True
	End Sub

	'==========================================================================
	' ��������� ���������� ���������� �������� �������
	Public Property Get CurrentRestrictions
		CurrentRestrictions = m_sRestrictions
	End Property

	'==========================================================================
	' ��������� �������� ���������� ���������� �������� �������
	Public Property Get CurrentRestrictionsDescription
		CurrentRestrictionsDescription = m_sRestrictionsDescription
	End Property

	'==========================================================================
	' ���������� ����� ������ ��������: LM_LIST, LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE
	Public Property Get Mode
		Mode = m_nMode
	End Property


	'==========================================================================
	' ���������� ��������� ������ ������
	Public Property Get XList
		Set XList = m_oXList
	End Property


	'==========================================================================
	' ������� ����, ��� �� �������� ����� ���� �������� ���������� ����
	' ������������ � window_OnBeforeUnload
	Public Property Get MayBeInterrupted
		If m_bMayBeInterrupted=true Then
			If IsObject(m_oXList) Then
				If Not m_oXList Is Nothing Then
					MayBeInterrupted = m_oXList.MayBeInterrupted
				Else
					MayBeInterrupted = True
				End If
			Else
				MayBeInterrupted = True
			End If
		Else
			MayBeInterrupted = False
		End If
		
		If MayBeInterrupted Then
			If X_MD_PAGE_HAS_FILTER Then
				MayBeInterrupted = not FilterObject.IsBusy
			End If
		End If	
	End Property


	'==============================================================================
	' ���������� ������� ����, ��� �������� ������� ��� ������
	Public Property Get IsDialog
		IsDialog = m_bIsDialog
	End Property


	'==========================================================================
	' ����������� �������
	Public Sub Internal_FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub


	'==========================================================================
	' ���������� ������� XList'a "SetMenuItemVisibility"
	Public Sub OnSetMenuItemVisibility( oSender, oEventArgs )
		Select Case oEventArgs.Action
			Case CMD_REPORT
				oEventArgs.Hidden = XList.OffReport
				oEventArgs.Disabled = XList.ListView.Rows.Count = 0
			Case CMD_EXCEL
				oEventArgs.Hidden = XList.OffReport
				oEventArgs.Disabled = XList.ListView.Rows.Count = 0
			Case CMD_REFRESH
				oEventArgs.Disabled = LIST_MD_OFF_RELOAD
			Case CMD_RESETFILTER
				oEventArgs.Disabled = X_MD_OFF_CLEARFILTER
			Case CMD_HELP
				oEventArgs.Hidden = Not X_MD_HELP_AVAILABLE
		End Select		
	End Sub


	'==========================================================================
	' ���������� ������ ����, ����������� � ����������
	'	[in] oEventArgs As MenuExecuteEventArgsClass
	Public Sub MenuExecutionHandler(oSender, oEventArgs)
		Select Case oEventArgs.Action
			Case CMD_REPORT:		ShowReport()
			Case CMD_EXCEL:			ShowExcel()
			Case CMD_REFRESH:		ReloadList()
			Case CMD_RESETFILTER:	XList_cmdClearFilter_OnClick()
			Case CMD_HELP:			XList_cmdOpenHelp_OnClick()
		End Select
	End Sub


	' <������, ���������� �� XList>
	'==============================================================================
	' ��������� ������ � ������������� � ���������� ���������
	'	[in] sKey As String   - ����
	'	[in] vData As Variant - �����-�� ������ 
	Public Sub SaveViewStateCache(sKey, vData)
		X_SaveViewStateCache GetCacheFileName(sKey), vData
	End Sub

	'==============================================================================
	' ��������� ������ � ���������� ���������
	'	[in] sKey As String   - ����
	'	[in] vData As Variant - ��������� 
	'	[retval] True - ������ ��������, False - ���� �� ������
	Public Function GetViewStateCache(sKey, vData)
		GetViewStateCache = X_GetViewStateCache( GetCacheFileName(sKey), vData )
	End Function
	
	
	'==========================================================================
	' ���������� ������ ���������
	Public Sub ReportStatus(sMsg)
		window.status = sMsg
	End Sub


	'==========================================================================
	' ������� ��������� � ���� ��������. ������� ������ (IXListVIew) ��������
	'	[in] sMessage - ����� ���������
	Public Sub ShowProcessMessage(sMessage)
		If UCase(ListHolder.style.display) = "BLOCK" Then
			ListHolder.style.display = "none"
			NoDataMsg.style.display = "block"
		End If
		NoDataMsg.innerText = sMessage
		ReportStatus sMessage
		XService.DoEvents
	End Sub

	
	'==========================================================================
	' ������ ������� ��� ������ ��������� � ���� ��������. ����������� ������� ������ (IXListVIew)
	Public Sub HideProcessMassage
		NoDataMsg.style.display = "none"
		ListHolder.style.display = "block"
	End Sub
	
	
	'==========================================================================
	' ����������/���������� ����������� ��������� ��������
	Sub EnableControls( bEnable)
		EnableControl "XList_cmdGoBack", bEnable
		EnableControl "XList_cmdGoHome", bEnable
		EnableControl "XList_cmdOpenHelp", bEnable
		EnableControl "XList_cmdRefresh", bEnable
		EnableControl "XList_cmdOperations", bEnable
		EnableControl "XList_cmdOk", bEnable
		EnableControl "XList_cmdCancel", bEnable
		EnableControl "XList_cmdClearFilter", bEnable
		EnableControl "XList_cmdHideFilter", bEnable
		EnableControl "XList_cmdSelectAll", bEnable
		EnableControl "XList_cmdInvertSelection", bEnable
		EnableControl "XList_cmdDeselect", bEnable
		XList.EnableControlsInternal bEnable
		If X_MD_PAGE_HAS_FILTER Then
			FilterObject.Enabled = bEnable
		End If
		XService.DoEvents
	End Sub
	' </������, ���������� �� XList>


	'==========================================================================
	' ����������/��������� ������������ �������� �� ����� ������������ ��������
	' � ���������, ��� ������� ���� �� ��������
	Sub EnableControl( sCtlName, bEnable)
		Dim oCtl
		Set oCtl = document.all( sCtlName)
		
		if not oCtl is nothing then
			oCtl.disabled = not bEnable
		end if
	End Sub


	'==============================================================================
	' ����������� ���������� ������� "OK"
	'	[in] oEventArg As ListSelectEventArgsClass
	Sub OnOk(oSender, oEventArg)
		Select Case Mode
			Case LM_MULTIPLE_OR_NONE
				X_SetDialogWindowReturnValue oEventArg.Selection
				window.close
			Case LM_SINGLE
				If 0<>Len(oEventArg.Selection) Then
					X_SetDialogWindowReturnValue oEventArg.Selection
					window.close
				Else
					Alert "����� ������� ������"
				End if
			Case LM_MULTIPLE
				If UBound(oEventArg.Selection)>=0 Then
					X_SetDialogWindowReturnValue oEventArg.Selection
					window.close
				Else
					Alert "����� �������� ���� �� ���� ������"
				End If
		End Select 
	End Sub



	'==============================================================================
	' ����������� ���������� ������� "GetRestrictions"
	'	[in] oSender As XListClass
	'	[in] oEventArg As GetRestrictionsEventArgsClass
	Public Sub OnGetRestrictions(oSender, oEventArg)
		Dim oArguments		' As FilterObjectGetRestrictionsParamsClass
		Dim oBuilder		' As IParamCollectionBuilder
		Dim bUsePaging		' ������������ ��������?
		
		bUsePaging = IsPagingProcess OR ( true = oEventArg.StayOnCurrentPage )
		If X_MD_PAGE_HAS_FILTER Then
			If bUsePaging AND (NOT IsEmpty(m_sRestrictions)) Then
				' � ������ ��������� �� �� �������� ����������� � ����������
				' ����������� � "������� ���"
				oEventArg.ReturnValue = m_sRestrictions
				oEventArg.Description = m_sRestrictionsDescription
			Else
				Set oArguments = New FilterObjectGetRestrictionsParamsClass
				Set oBuilder = New QueryStringParamCollectionBuilderClass
				Set oArguments.ParamCollectionBuilder = oBuilder
				FilterObject.GetRestrictions(oArguments)
				If False=oArguments.ReturnValue Then
					oEventArg.ReturnValue = False
					oEventArg.Description = vbNullString
				Else
					m_sRestrictions = oBuilder.QueryString
					m_sRestrictionsDescription = oArguments.Description
					oEventArg.ReturnValue = m_sRestrictions
					oEventArg.Description = m_sRestrictionsDescription
				End If
			End If
		End If
		
		If LIST_MD_USE_PAGING AND bUsePaging Then
			oEventArg.UrlParams = "X-FIRST-ROW=" & PagingFirstRow & "&X-LAST-ROW=" & PagingLastRow
		Else
			m_nFirstRow = 1 ' ������� ����� ������
			oEventArg.UrlParams = "X-FIRST-ROW=1&X-LAST-ROW=" & XList.MaxRows
		End If
	End Sub
	
	'==============================================================================
	' ����������� ��������� ���������� �����
	Public Property Get ServerMaxRows
		ServerMaxRows = m_nServerMaxRows
	End Property
	
	'==============================================================================
	' ������� ������������ ������ � ������ ������������ ��������
	Public Property Get IsPagingProcess
		IsPagingProcess = m_bPaging
	End Property

	'==============================================================================
	' ����� ������ ���������� ������
	Public Property Get PagingFirstRow
		PagingFirstRow = m_nFirstRow
	End Property
	
	'==============================================================================
	' ����� ��������� ���������� ������
	Public Property Get PagingLastRow
		PagingLastRow =  XList.MaxRows + PagingFirstRow - 1
	End Property

	'==============================================================================
	' ����������� ���������� ������� "AfterListReload".
	' ������� ������������ XList'�� ����� (����)�������� ������ � �������
	'	[in] oSender As XListClass
	'	[in] oEventArg As AfterListReloadEventArgsClass
	Public Sub OnAfterListReload(oSender, oEventArg)
		' ��������� ���������� ���������� ������� � ������� ��������� �������
		Dim sSpecialTitle: sSpecialTitle = vbNullString
		With oEventArg
			Dim nRowCount: nRowCount = oSender.ListView.Rows.Count
			If LIST_MD_USE_PAGING AND ((Mode=LM_SINGLE) OR (Mode=LM_LIST)) Then
				Dim nFirstRow
				Dim nLastRow
				
				nFirstRow = PagingFirstRow
				
				sSpecialTitle = "<NOBR>"
				
				If 1=nFirstRow AND NOT .HasMoreRows Then
					sSpecialTitle = sSpecialTitle & "����� " & nRowCount & XService.GetUnitForm(nRowCount, Array(" �������", " ������", " ������"))
				Else
					nLastRow = nFirstRow + nRowCount - 1
					If 1<>nFirstRow Then
						sSpecialTitle = sSpecialTitle & _
							"<span style='font-family:Webdings;cursor:hand;font-size:120%;' onclick='g_oXListPage.SetDataWindow " & (1) & ", " & (.MaxRows) & "' language=vbscript>9</span>" & _
							"<span style='font-family:Webdings;cursor:hand;font-size:120%;' onclick='g_oXListPage.SetDataWindow " & (nFirstRow - .MaxRows) & ", " & (nFirstRow - 1) & "' language=vbscript>7</span>"
					End If
					sSpecialTitle = sSpecialTitle & "&nbsp;" & nFirstRow & " - " & nLastRow & "&nbsp;"
					If .HasMoreRows Then
						sSpecialTitle = sSpecialTitle & _
							"<span style='font-family:Webdings;cursor:hand;font-size:120%;' onclick='g_oXListPage.SetDataWindow " & (nFirstRow + .MaxRows) & ", " & (nFirstRow + .MaxRows*2 - 1) & "' language=vbscript>8</span>"
					End If
				End If
				sSpecialTitle = sSpecialTitle & "</NOBR>"
			Else
				If .HasMoreRows Then
					sSpecialTitle = "<NOBR>������ " & .MaxRows & XService.GetUnitForm(.MaxRows, Array(" �������", " ������", " ������")) & "</NOBR>"
				Else
					sSpecialTitle = "<NOBR>����� " & nRowCount & XService.GetUnitForm(nRowCount, Array(" �������", " ������", " ������")) & "</NOBR>"
				End If
			End If    
			If Len(.Restrictions) > 0 Then
				If Len(sSpecialTitle) > 0 Then sSpecialTitle = sSpecialTitle & "<BR>"
				sSpecialTitle = sSpecialTitle & "<NOBR>������ �������</NOBR>"
			End If
			
		End With
		
		XList_SpecialCaption.innerHtml = sSpecialTitle
	End Sub
		
	'==============================================================================
	' ���������� ��������� ������
	Public Property Get Title		' As String
		Title = document.all("XList_Caption").innerText
	End Property

	'==============================================================================
	' ������������� ��������� ������
	Public Property Let Title(sText)
		document.all("XList_Caption").innerText = sText
	End Property
	
	'==============================================================================
	' ����� ��������� ������� QueryString � ����������� �������
	' ���� ������ � ������ �����������, ������������ ������ ��������� QueryStringClass.
	'	[retval] As QueryStringClass
	Public Function GetRestrictions()
		Set GetRestrictions = New QueryStringClass
		If X_MD_PAGE_HAS_FILTER Then
			With New GetRestrictionsEventArgsClass
				OnGetRestrictions Me, .Self()
				GetRestrictions.QueryString = .ReturnValue
			End With
		End If
	End Function

	'==============================================================================
	' ���������� ���������� �������� ��������
	Sub Internal_OnUnLoad
		Dim oXmlFilterState ' As IXMLDOMElement, ��������� �������
		' ��� ������������� ������� ���������������� ����������...
		Internal_FireEvent "UnLoad", Nothing
		If X_MD_PAGE_HAS_FILTER Then
			If m_bOffFilterViewState=False Then
				' ���� �� ��������� ��������� ��������� �������, �������� ���. �������, ��� ������ ��� ������.
				Set oXmlFilterState = FilterObject.GetXmlState()
				If Not oXmlFilterState Is Nothing Then _
					SaveDataCache "FilterXmlState", oXmlFilterState
			End If
		End If
		XList.OnUnLoad
	End Sub

	'==============================================================================
	' ��������� ���������� ������. ������������ ��� ������ �� scriptlet'�� ��������
	Public Sub ExecuteScript(sScript)
		ExecuteGlobal sScript
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
	' ��������� ������ � ���������� ���������
	'	[in] sKey As String   - ����
	'	[in] vData As Variant - �����-�� ������ 
	Public Sub SaveDataCache(sKey, vData)
		X_SaveDataCache GetCacheFileName(sKey), vData
	End Sub

	'==============================================================================
	' ��������� ������ � ���������� ���������
	'	[in] sKey As String   - ����
	'	[in] vData As Variant - ��������� 
	'	[retval] True - ������ �������, False - ���� �� ������
	Public Function GetDataCache(sKey, vData)
		GetDataCache = X_GetDataCache( GetCacheFileName(sKey), vData )
	End Function


	'==============================================================================
	' ���������� ��� ����� ��� ���������� ���������������� ������
	'	[in] sSuffix - ������ �����
	'	[retval] ������������ �����
	Private Function GetCacheFileName(sSuffix)
		GetCacheFileName = "XL." & ObjectType & "." & MetaName & "." & sSuffix
	End Function


	'==============================================================================
	' ���������� ���������� ������
	' ��� ������ ������ �������� ��������� �������� ��������� ���������� � �������� ���������
	' ����������: ��� �������� ���������������� ������ ���������� �� �����, ������� �� ������ ��� ��� ���������� �������� �� ����������
	Public Function GetListMD	' As IXMLDOMElement
		If IsEmpty(m_oListMD) Then
			Set m_oListMD = X_GetListMD(ObjectType, MetaName)
		End If
		Set GetListMD = m_oListMD
	End Function
	
	
	'==============================================================================
	' ���������� ���������� ����
	Public Sub ShowDebugMenu
		Dim oPopUp
		Set oPopUp = XService.CreateObject("CROC.XPopUpMenu")
		oPopUp.Clear
		
		oPopUp.Add "����������", "X_DebugShowXML X_GetMD()", true
		oPopUp.Add "���������� ���� '" & ObjectType & "'", "X_DebugShowXml X_GetTypeMD(""" & ObjectType & """)", true
		oPopUp.Add "���������� ������ '" & MetaName & "'", "X_DebugShowXml GetListMD()", true
		oPopUp.Add "��������� ����������", "ShowSystemInfo", true
		oPopUp.AddSeparator
		oPopUp.Add "������� �����������...", "ShowCurrentRestrictions", X_MD_PAGE_HAS_FILTER
		oPopUp.AddSeparator
		oPopUp.Add "���������� ���� �������...", "FilterObject.ShowDebugMenu", X_MD_PAGE_HAS_FILTER
		oPopUp.AddSeparator
		oPopUp.Add "����� ������", "X_ResetSession", true
		oPopUp.AddSeparator
		oPopUp.Add "���������� �����", "X_SetDebugMode Not X_IsDebugMode", true, iif(X_IsDebugMode, 1, 0)
		oPopUp.AddSeparator
		oPopUp.Add "x-default.aspx", "window.navigate XService.BaseURL( location.href) & ""X-DEFAULT.ASPX?ALL=1&TM="" & CDbl(Now)", true
		Execute 	oPopUp.Show & "' ��������� �����������"
		Window.event.cancelBubble=true
		Window.event.returnValue = false
	End Sub

	'==============================================================================
	' ���������� �����������
	Public Sub ShowCurrentRestrictions
		Alert CurrentRestrictions
	End Sub

	
	'==============================================================================
	' ���������� �������� ����������
	Public Sub ShowSystemInfo
		Alert _
			"��� �������: " & ObjectType & vbNewLine & _
			"����� ������ ������: " & Mode & vbNewLine & _
			"������� ������: " & MetaName & vbNewLine & _
			"������ ����������: " & Querystring.QueryString & vbNewLine & _
			"��������� �������������: " & XList.GetSelectedRowID
	End Sub
	
	'==========================================================================
	' ���������� ��������� ������
	Public Sub ShowReport()
		Dim sCaption		' �������� ����������� � ���� ������
		Dim oDataFromServer	' ������ � �������
		Dim oCaption		' �������� �����������, ����������� � IXMLDOMDocument
		
		' ������� ��������
		'!!! �������� !!!
		sCaption =	XService.HtmlEncodeLite(XList_Caption.innerText)

		if 0<>len( sCaption) then 
			sCaption = "<?xml version=""1.0"" encoding=""windows-1251""?><CAPTION>" & sCaption & "</CAPTION>"
			set oCaption = XService.XMLGetDocument()
			if not oCaption.LoadXml(sCaption) then
				X_ErrReportEx  "������ ��� ������� �������� ����������� �������!", "�������� ����������� �.�. � ���� XHTML" & vbNewLine & oCaption.parseError.reason
				exit sub
			end if
		end if	
		
		' ������� XSL
		If IsEmpty( m_oReportXsl ) Then
			On Error Resume Next
			Set m_oReportXsl = XService.XMLGetDocument( "xsl/x-list.xsl") 
			If 0<>err.number Then
				X_ErrReportEx "������ ��� ��������� �������� ����� ������!" & vbNewLine & Err.Description, Err.Source  
				Exit Sub
			End If
			On Error GoTo 0
		End If

		' ������� ������
		Set oDataFromServer = XList.ListView.Xml
		
		oDataFromServer.setAttribute "ot", ObjectType 
		
		' �������� ���������
		If Not IsEmpty( oCaption) Then
			with oDataFromServer
				.selectNodes("CAPTION").removeAll
				.appendChild oCaption.documentElement
			End With
		End If

		' �������� �����
		With X_OpenReport( vbNullString).document
			.open
			.write oDataFromServer.transformNode(m_oReportXsl)
			.close
		End With
	End Sub
	
	
	'==========================================================================
	' ������� ��������� ������ � Excel
	Public Sub ShowExcel()
		' ����������� ��������� ������ ������� 
		const  WIDTH_RATIO = 8
		' ������ ������ � ��������/�������
		const  HEAD_FONT_SIZE = 9
		' ������ ������ � ���� ���������
		const  BODY_FONT_SIZE = 7
		' ��� ������
		const  FONT_NAME = "Microsoft Sans Serif"
		' ���������������� ����������� �����������
		const  MULTIPLY_RATIO = 3
		
		const  xlWBATWorksheet = -4167
		const  xlNormal = -4143
		const  xlMinimized = -4140

		' �������������� � ������������ ������������
		const  xlHAlignCenter = -4108
		const  xlHAlignLeft = -4131
		const  xlHAlignRight = -4152
		const  xlVAlignCenter = -4108

		' ������� �����
		const  xlInsideHorizontal = 12
		const  xlInsideVertical = 11
		const  xlEdgeBottom = 9
		const  xlEdgeLeft = 7
		const  xlEdgeRight = 10
		const  xlEdgeTop = 8

		' ������� �����
		const  xlThin = 2

		' ����� �����
		const  xlContinuous = 1
		
		' ����������� ���������� ����� ������� � Excel
		const  xlMaxColCount = 254

		dim oExelApp		' ���������� Excel.Application
		dim oListData		' ������ ������ IXMLDomElement
		dim oRec			' ������ ������ IXMLDomElement
		dim oSheet			' ������� Excel.Sheet
		dim oBook			' ����� Excel.Workbook
		dim nColumns		' ����� �������� ��������
		dim nDataRows		' ����� ����� ������
		dim x,y				' "����������" �������������� ������ �������
		dim sCaption		' �������� ����������� � ���� ������
		dim oCaption		' �������� �����������, ����������� � IXMLDOMDocument
		dim vVal			' �������� ������
		dim sCellType		' ��� �������� ������
		dim i
		dim j
		
		' ���������� ���������
		' !!! �������� !!!
		sCaption =	XList_Caption.innerText
		if 0<>len( sCaption) then 
			' �������� �������� � XML
			sCaption = "<?xml version=""1.0"" encoding=""windows-1251""?><CAPTION>" & sCaption & "</CAPTION>"
			set oCaption = XService.XMLGetDocument()
			oCaption.preserveWhiteSpace = true
			on error resume next
			oCaption.loadXml sCaption
			If Err Then
				X_ErrReportEx  "������ ��� �������� ��������� � xml...", Err.Description 
				Exit Sub
			End If
			On Error GoTo 0
			with oCaption.documentElement
				' ������� �������� �� �����
				for each oRec in .selectNodes("//BR|//br|//Br|//bR")
					oRec.parentNode.replaceChild  oCaption.createTextNode(vbNewLine), oRec
				next
				' ������� ������
				sCaption = .text
				set oRec = Nothing
			end with
			set oCaption = Nothing
		end if	

		window.status = "�������� � ������� ������ ��� ������..."
		set oListData =	XList.ListView.xml
		nColumns=0
		for each oRec in oListData.selectNodes("CS/C[not(@hidden)]")
			oRec.setAttribute "i", nColumns
			nColumns=nColumns+1
		next
		nColumns = nColumns + 1
		 
		if nColumns > xlMaxColCount  then
			Alert "����� ������� � ������ ������ ������ ����������� ����������� � Excel"
			window.status = "������� � Excel ���������� ����� ����������� �� ���������� ����� �������� � ������."
			exit sub
		end if
		
		window.status = "������������ ����� � Microsoft Excel..."
		On Error Resume Next
		set oExelApp = XService.CreateObject("Excel.Application")
		if Err then
			X_ErrReportEx "���������� ���������� ����� � Microsoft Excel. �������� �� �� ����������, ���� ��������� ������������ ������������ �������������� � ���...", Err.Description  & " code: " & Hex(Err.Number)
			window.status = "��� ������� ���������� ����� � Microsoft Excel ��������� ������."
			exit sub
		end if
		On Error GoTo 0

		window.status = "������������� �������� ������� ����� Excel..."
		set oBook =  oExelApp.WorkBooks.Add( xlWBATWorksheet)
		set oSheet = oBook.Worksheets.Item( 1)
		oSheet.Name = "�����"
		oSheet.Activate

		' ��������� ���������
		window.status = "������������ ��������� ������..."
		oSheet.Rows("1:1").RowHeight = HEAD_FONT_SIZE * (UBound(Split(sCaption, vbNewLine ))+1) * MULTIPLY_RATIO
		with oSheet.Range(oSheet.Cells(1,1),oSheet.Cells(1,nColumns))
			.Merge
			.Value = sCaption 	' ���������
			.HorizontalAlignment = xlHAlignCenter 
			.VerticalAlignment = xlVAlignCenter
			with .Font
				.Bold = true
				.Size = HEAD_FONT_SIZE 
				.Name = FONT_NAME 
			end with
			.Interior.Color = RGB(252,253,225)
			with .Borders(xlEdgeBottom)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeRight)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeLeft)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeTop)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
		end with
		
		' ��������� ����� �������
		window.status = "������������ ����� ������� ������..."

		' ��������� ����� �������
		oSheet.Columns(1).ColumnWidth = 3 ' ��������� ������ ������� � ������� ������
		x = 2 ' ������ ������� ����� ������, ������ �������� ������ ���������� � 2
		y = 2 ' ����� ������� ������������� �� ������ ������ �������
		
		for i=0 to nColumns - 2
			set oRec = oListData.selectSingleNode("CS/C[number(@display-index)=" & i & "]")
			oSheet.Cells(y,x).Value = oRec.nodeTypedValue
			oSheet.Columns(x).ColumnWidth = Int(Int(oRec.getAttribute("width"))/ WIDTH_RATIO  )
			x=x+1
		next
		
		with oSheet.Range(oSheet.Cells(y,1),oSheet.Cells(y,nColumns))
			.HorizontalAlignment = xlHAlignCenter 
			.VerticalAlignment = xlVAlignCenter
			with .Font
				.Bold = true
				.Size = BODY_FONT_SIZE 
				.Name = FONT_NAME 
			end with
			.Interior.Color = RGB(220,220,220)
		end with
		
		' ��������� ���� �������
		window.status = "������������ ������� ������..."
		y = y + 1
		
		with oListData.selectSingleNode("RS")
			nDataRows = 0
			do
				set oRec = .selectSingleNode("R[number(@display-index)=" & nDataRows & "]")
				if not oRec is Nothing then
					nDataRows = nDataRows + 1
					window.status = "������������ ������� ������ (������ " & nDataRows & ")..."
					XService.DoEvents()
					oSheet.Cells(y+nDataRows-1,1).Value = nDataRows
					for j=2 to nColumns
						set vVal = oRec.selectSingleNode("F[not(@hidden)][1+number(./../../../CS/C[number(@display-index)=" & (j-2) & "]/@i)]")
						if not vVal is Nothing then
							vVal = vVal.nodeTypedValue
							if not IsNull( vVal) then
								if 0<>Len(CStr(vVal)) then
									vVal = CStr( vVal)
									set sCellType = oRec.selectSingleNode("F[not(@hidden)][1+number(./../../../CS/C[number(@display-index)=" & (j-2) & "]/@i)]/@dt:dt")
									if not sCellType is Nothing then
										sCellType = sCellType.Value
									else
										sCellType = ""
									end if
									select case sCellType
										case "i2", "i4", "fixed.14.4"
											oSheet.Cells(y+nDataRows-1,j).NumberFormat = "00"
											oSheet.Cells(y+nDataRows-1,j).Value = vVal
										case "r4", "r8"
											oSheet.Cells(y+nDataRows-1,j).NumberFormat = "00.0"
											oSheet.Cells(y+nDataRows-1,j).Value = vVal
										case "dateTime.tz"
											oSheet.Cells(y+nDataRows-1,j).NumberFormat = "dd.mm.yyyy h:mm:ss"
											oSheet.Cells(y+nDataRows-1,j).Value = "=DATE(" & Year(vVal) & "," & Month(vVal) & "," & Day(vVal) & ") + TIME(" & Hour(vVal) & "," & Minute(vVal) & "," & Second(vVal) & ")"
										case "time.tz"
											oSheet.Cells(y+nDataRows-1,j).Value = "=TIME(" & Hour(vVal) & "," & Minute(vVal) & "," & Second(vVal) & ")"
										case "date"
											oSheet.Cells(y+nDataRows-1,j).Value = "=DATE(" & Year(vVal) & "," & Month(vVal) & "," & Day(vVal) & ")"
										case else
											oSheet.Cells(y+nDataRows-1,j).Value = "'" &	vVal
									end select
								end if	
							end if 
						end if
					next
				end if
			loop until oRec is Nothing
		end with
		
		with oSheet.Range(oSheet.Cells(y,2),oSheet.Cells(y+nDataRows-1,nColumns))
			.HorizontalAlignment = xlHAlignLeft 
			.VerticalAlignment = xlVAlignCenter
			.WrapText = True
			with .Font
				.Bold = false
				.Size = BODY_FONT_SIZE 
				.Name = FONT_NAME 
			end with
		end with	
		
		' ��������� ����� � "�����" �����
		with oSheet.Range(oSheet.Cells(y,1),oSheet.Cells(y+nDataRows-1,1))
			.HorizontalAlignment = xlHAlignCenter 
			.VerticalAlignment = xlVAlignCenter
			with .Font
				.Bold = true
				.Size = BODY_FONT_SIZE 
				.Name = FONT_NAME 
			end with
			.Interior.Color = RGB(220,220,220)
		end with	
		
		' ������� ������� �������
		with oSheet.Range( oSheet.Cells(y-1,1), oSheet.Cells(y+nDataRows-1,nColumns) )
			with .Borders(xlEdgeBottom)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeRight)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeLeft)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeTop)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			' ���������� ����� ����� ����� �������������� ���� ������ ���� ���� 
			' �� ���� ������ ������;  � ��������� ������ ������� ��������� 
			' ���������� ����� �������� � runtime ������ Excel:
			if ( nDataRows>0 and nColumns>0 ) then
				with .Borders(xlInsideHorizontal)
					.LineStyle = xlContinuous
					.Weight = xlThin
				end with
				with .Borders(xlInsideVertical)
					.LineStyle = xlContinuous
					.Weight = xlThin
				end with
			end if
		end with	
		
		' ��������� �������
		window.status = "������������ ������� ������..."
		with oSheet.Range(oSheet.Cells(y+nDataRows,1),oSheet.Cells(y+nDataRows,nColumns))
			.Merge
			.Value = "����� ��������� " & FormatDateTime (Now(), vbLongDate) & " � " & FormatDateTime (Now(), vbShortTime)
			.HorizontalAlignment = xlHAlignRight
			.VerticalAlignment = xlVAlignCenter
			with .Font
				.Size = HEAD_FONT_SIZE 
				.Name = FONT_NAME 
			end with	
			.Interior.Color = RGB(252,253,225)
			with .Borders(xlEdgeBottom)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeRight)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeLeft)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeTop)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
		end with
		window.status = "������� � Excel ��������."
		' ���������� Excel
		oExelApp.Visible = true
		oExelApp.WindowState = xlMinimized
		oExelApp.WindowState = xlNormal
	End Sub

	
	'==============================================================================
	' �������� ��������� �������: ������ ��� ��������
	Public Sub SwitchFilter()
		If X_MD_PAGE_HAS_FILTER Then
			If UCase(xPaneFilter.style.display) = "NONE" Then
				xPaneFilter.style.display = "inline"
				FilterObject.SetVisibility True
				cmdHideFilter.innerText = "������"
				cmdHideFilter.title = "������ ������"
			Else
				cmdHideFilter.focus
				xPaneFilter.style.display = "none"
				FilterObject.SetVisibility False
				cmdHideFilter.innerText = "��������"
				cmdHideFilter.title = "�������� ������"
			End If
		End If
	End Sub
	
	
	'==============================================================================
	' ���������� ������� "EnableControls", ���������������� �������� (x-filter.htc)
	'	[in] oEventArgs - EnableControlsEventArgs
	Public Sub Internal_On_Filter_EnableControls(oSender, oEventArgs)
		EnableControls oEventArgs.Enable
	End Sub


	'==============================================================================
	' ���������� ������� "Accel", ���������������� �������� (x-filter.htc)
	'	[in] oEventArgs - AccelerationEventArgsClass
	Public Sub Internal_On_Filter_Accel(oSender, oEventArgs)
		If oEventArgs.keyCode = VK_ENTER Then
			ReloadList
		End If
	End Sub
	
	'==============================================================================
	' ���������� ������� "Apply", ���������������� �������� (x-filter.htc)
	'	[in] oEventArgs - AccelerationEventArgsClass
	Public Sub Internal_On_Filter_Apply(oSender, oEventArgs)
		ReloadList
	End Sub
	
	
	'==============================================================================
	' ���������� ���������, ������������� "����" ������������ ������
	'	[in] nFirstRow  - ����� ������ ������������ ������
	'	[in] nLastRow  - ����� ��������� ������������ ������
	Public Sub SetDataWindow(nFirstRow, nLastRow)
		Dim nMaxRows ' ���������� ����� ������� ���������� ����������
		
		If LIST_MD_USE_PAGING AND ((Mode=LM_SINGLE) OR (Mode=LM_LIST)) Then
			If m_bMayBeInterrupted Then
				If nFirstRow < 1 Then nFirstRow=1
				m_nFirstRow = nFirstRow
				If nLastRow >= nFirstRow Then
					nMaxRows = nLastRow - nFirstRow + 1
					If nMaxRows > ServerMaxRows Then
						nMaxRows = ServerMaxRows
					End If    
					XList.MaxRows = nMaxRows
				End If
				
				m_bPaging = true
				XList.Reload()
				m_bPaging = false
				
				XList.SetListFocus()
			End If
		Else
			Err.Raise -1, "XListPageClass::SetDataWindow", "������������ ������� ������������ ��������"        
		End If    
	End Sub
End Class


'==============================================================================

Dim g_oXListPage		' As XListPageClass
Dim g_nThisPageID		' ���������� ������������� ������� ��������
Dim g_bFullLoad			' ������� ������ �������� ��������

'==============================================================================
' ������������� ������� (���������� �� ������������� ��������)
'...�������� ������ ������...
g_bFullLoad = False
'...���������� ���������� ID...
g_nThisPageID = CLng( CDbl( Time()) * 1000000000 )

'==============================================================================
' ������������� ��������.
' ���������� �� ���������� ��������, � ��� ����� �������.
Sub Init()
	Dim vMenuMD		' ���������� ����
	
	If X_ACCESS_DENIED Then Exit Sub
	Set g_oXListPage = New XListPageClass
	Set vMenuMD = document.all("oListMenuMD",0)
	If Not vMenuMD Is Nothing Then 
		vMenuMD = vMenuMD.value
	Else
		vMenuMD = ""
	End If
	
	g_oXListPage.Internal_Init vMenuMD
End Sub


'==============================================================================
' ����� ���������� ������� ���������� ������.
' ���������� ��� �� Document_onkeyUp, ��� � �� 
':���������:	oAccelerationEventArgs - [in] AccelerationEventArgsClass
Sub Internal_OnKeyUp(oAccelerationEventArgs)
	' ������� ����� ���� ������ ��� �� ����, ��� ����� 
	' ������������������ ��������� g_oXListPage: ���� ��� ���,
	' �� ������ �� ������:
	If Not hasValue(g_oXListPage) Then Exit Sub
	With oAccelerationEventArgs
		If g_oXListPage.Mode <> LM_LIST  Then
			If .KeyCode = VK_ENTER Then
				' ������ Enter � ������ ������
				XList_cmdOk_OnClick()
			ElseIf .KeyCode = VK_ESC Then
				' ������ Escape � ������ ������
				XList_cmdCancel_OnClick
			Else
				g_oXListPage.XList.OnKeyUp oAccelerationEventArgs
			End If
		Else
			g_oXListPage.XList.OnKeyUp oAccelerationEventArgs
		End If
	End With
End Sub


'<����������� window � document>
'==============================================================================
' ������������� ��������
Sub Window_OnLoad()	
	X_WaitForTrue "Init()" , "X_IsDocumentReadyEx(null, ""XFilter"")"
End Sub

'==============================================================================
' ����������� ��������
Sub Window_OnUnLoad()
	g_nThisPageID = Empty	' ���������� �������������
	
	' ���� ������ ��� ���������� ������ ������ �� �����!
	If True <> g_bFullLoad Then Exit Sub
	
	g_oXListPage.Internal_OnUnLoad
End Sub

'==============================================================================
' ������� �������� ��������
Sub Window_onBeforeUnload
	If Not IsObject(g_oXListPage) Then Exit Sub
	If Nothing Is g_oXListPage Then Exit Sub
	If g_oXListPage.MayBeInterrupted Then Exit Sub
	window.event.returnValue="��������!" & vbNewLine & "�������� ���� � ������ ������ ����� �������� � ������������� ������!"
End Sub

Dim g_bKeyProcessing	' ������� ��������� ������� Document_onkeyUp

'==============================================================================
' ������� �������, �� ���������� ������� �������������
Sub Document_onkeyUp
	' ���� �������� ������� ������� ������, �� ���������� ������� - 
	' � ������ ���� ����������� ActiveX-������� onKeyUp (��. XListPage_OnKeyUp)
	If Not IsObject(g_oXListPage) Then Exit Sub
	If Nothing Is g_oXListPage Then Exit Sub
	If Not window.event.srcElement is g_oXListPage.XList.ListView Then
		If g_bKeyProcessing Then Exit Sub
		g_bKeyProcessing = True
		Internal_OnKeyUp CreateAccelerationEventArgsForHtmlEvent()
		g_bKeyProcessing = False
	End If
End Sub
 

'==============================================================================
' ���������� ������ �������
Sub Document_OnHelp
	If True <> g_bFullLoad Then Exit Sub
	If X_MD_HELP_AVAILABLE Then
		'� _���������_ ������� ��������� ������	
		'A Runtime Error has occurred.
		'Do you wish to Debug?
		'Line: 1243
		'Error: Object required: 'window.event'	
		'������� ������ "�������" � ���� �� ������ ;)
		On Error Resume Next
		window.event.returnValue = False
		On Error GoTo 0
		X_OpenHelp X_MD_HELP_PAGE_URL
	End If
End Sub
'<����������� window � document>


'<����������� ������>
'==============================================================================
' �������� ���� � ������ ������ �� ������ "OK"
Sub XList_cmdOk_OnClick()
	If document.all( "XList_cmdOk").disabled Then Exit Sub	' ���� ������ ������������� - ������ �� ��� ������!
	With New ListSelectEventArgsClass
		If LM_SINGLE = g_oXListPage.Mode Then
			' � ������ ������ ������ ������� �������� ������������� ����������
			.Selection = g_oXListPage.XList.GetSelectedObjectID()
		Else
			' � ������ ������ ���������� �������� ��������� ������ ���������������
			.Selection= g_oXListPage.XList.GetCheckedObjectIDs()		
		End If
		g_oXListPage.Internal_FireEvent "Ok", .Self()
	End With	
End Sub


'==============================================================================
' �������� ���� � ������ ������ �� ������ "��������"
Sub XList_cmdCancel_OnClick()
	window.close
End Sub


'==============================================================================
' ������� �� ������ "��������"
Sub XList_cmdOperations_onClick()
	g_oXListPage.XList.TrackContextMenu
End Sub


'==============================================================================
Sub XList_cmdRefresh_OnClick
	ReloadList()
End Sub

'==============================================================================
' ��������� �������: "�������� ������"
Sub XList_cmdClearFilter_OnClick()
	g_oXListPage.FilterObject.ClearRestrictions()
	g_oXListPage.Internal_FireEvent "ResetFilter", Nothing
End Sub


'==============================================================================
' ���������� ������ "������"/"��������" ������
Sub XList_cmdHideFilter_onCLick()
	g_oXListPage.SwitchFilter
End Sub


'==============================================================================
' ����� ���� �������� � ������
Sub XList_cmdSelectAll_OnClick
	g_oXListPage.XList.SelectAll
End Sub


'==============================================================================
' ������ ���������
Sub XList_cmdDeselect_OnClick
	g_oXListPage.XList.DeselectAll
End Sub


'==============================================================================
' �������� ���������
Sub XList_cmdInvertSelection_OnClick
	g_oXListPage.XList.InvertSelection
End Sub


'==============================================================================
' ���������� ������� �� ������ "�������"
Sub XList_cmdOpenHelp_OnClick
	Document_OnHelp
End Sub
'</����������� ������>

'<����������� ActiveX-������� ListVIew>
'==============================================================================
' ���������� ������� "OnWidthChange" ActiveX-���������� CROC.IXListView - c������ ��������� ������ �������
Sub XListPage_OnListWidthChange(oDispSender, nColIndex, nWidth)
	g_oXListPage.XList.OnWidthChange nColIndex, nWidth
End Sub


'==============================================================================
' ���������� ������� "OnDblClick" ActiveX-���������� CROC.IXListView - ������� ������� � ������ ������
Sub XListPage_OnDblClick(ByVal oSender, ByVal nIndex , ByVal nColumn, ByVal sID)
	If LM_LIST = g_oXListPage.Mode Then
		' ����������: ������-�� ���������� ����� ���� ��������� � ������� IE !!!
		window.setTimeout "g_oXListPage.XList.OnDblClick " & nIndex & "," & nColumn & ",""" & sID & """", 1 , "VBScript"
	ElseIf LM_SINGLE = g_oXListPage.Mode Then
		' ��� ������� ������ ������ �������� ��������� ������� ��	
		XList_cmdOk_OnClick
	Else
		' ��� ������� ������ ��������� ��������� (LM_MULTIPLE, LM_MULTIPLE_OR_NONE) ��������� ���� �� �������� ������
		g_oXListPage.XList.ChangeSelectedRowState
	End If	
End Sub


'==============================================================================
' ������� ������� � ������
Sub XListPage_OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)
	Internal_onKeyUp CreateAccelerationEventArgsForActiveXEvent(nKeyCode, nFlags)
End Sub
'</����������� ActiveX-������� ListVIew>


'==============================================================================
' ����� "����������" �������
' ���������� �� PopUp-���� � CTRL �� ��������� 
Sub OnDebugEvent()
	If Not IsObject(g_oXListPage) Then Exit Sub
	If Nothing Is g_oXListPage Then Exit Sub
	If Window.event.ctrlKey or X_IsDebugMode Then
		window.event.cancelBubble=true
		window.event.returnValue = false
		g_oXListPage.ShowDebugMenu
	End If
End Sub


'==============================================================================
' O��������� Html-������� oncontextmenu.
' ���������� ����������� ���� ������.
Sub TrackContextMenu()
	' ������ ��������� �������, ���� �� ������� ����������� ���� IE
	If Not window.event Is Nothing Then	
		window.event.cancelBubble = True
		window.event.returnValue = False
	End If
	' ����� ����� ������ �������� ������
	If g_bFullLoad = True Then 
		' � ������ ������ "�������" ����������� ���� �� ������ ����
		If g_oXListPage.Mode = LM_LIST Then 
			window.setTimeout "g_oXListPage.XList.TrackContextMenu", 0, "VBScript"
		End If
	End If
End Sub


'==============================================================================
' ����������� ������
' ����������: �������� �� XListPageClass, �.�. ���������� �� HTML-������������
Public Sub ReloadList
	g_oXListPage.XList.Reload()	
	g_oXListPage.XList.SetDefaultFocus(g_oXListPage.FilterObject)
End Sub
