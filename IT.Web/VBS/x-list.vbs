'===============================================================================
'@@!!FILE_x-list
'<GROUP !!SYMREF_VBS>
'<TITLE x-list - ������������ ������ �� ������� �������>
':����������:	������������ ������ �� ������� �������.
'===============================================================================
'@@!!CONSTANTS_x-list
'<GROUP !!FILE_x-list><TITLE ���������>
'@@!!CLASSES_x-list
'<GROUP !!FILE_x-list><TITLE ������>
Option Explicit
 
'@@DEFAULT_MAXROWS
'<GROUP !!CONSTANTS_x-list>
':��������:	������������ ����� ����� ������ �� ���������. �������� ��������� - <B>500</B>.
const DEFAULT_MAXROWS = 500

'===============================================================================
'@@XListClass
'<GROUP !!CLASSES_x-list><TITLE XListClass>
':����������:	��������� ������ � ���� �� ������ CROC.IXListView.
'				�������� ������ �� ������� ���������� ������ - ListView.
' �������� ������� ������ ��������� � ������� <LINK points_wc1_03-1, �������>
'@@!!MEMBERTYPE_Methods_XListClass
'<GROUP XListClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_XListClass
'<GROUP XListClass><TITLE ��������>
'
Class XListClass
    '@@XListClass.ListView
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE ListView>
	':����������:	������� ���������� CROC.IXListView	
	Public ListView				' ������� CROC.IXListView
	'@@XListClass.ObjectType
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE ObjectType>
	':����������:	��� ���� �������������� ��������
	':���������:	Public ObjectType [String]
	Public ObjectType			' ��� ���� �������������� ��������
	'@@XListClass.TypedBy
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE TypedBy>
	':����������:	��� �������/�������, ������� ���������� ��� �������
	':���������:	Public TypedBy [String]
	Public TypedBy				' ��� �������/�������, ������� ���������� ��� ������� 
	'@@XListClass.IdentifiedBy
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE IdentifiedBy>
	':����������:	��� �������/�������, ������� ���������� ������������� �������
	':���������:	Public IdentifiedBy [Sring]
	Public IdentifiedBy			' ��� �������/�������, ������� ���������� ������������� �������
	'@@XListClass.UseEditor
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE UseEditor>
	':����������:	��� ������������� ��������� � ���������� ��� Null (��������������� �����������)
	':���������:	Public UseEditor [String]
	Public UseEditor			' ��� ������������� ��������� � ���������� ��� Null (��������������� �����������)
	'@@XListClass.UseWizard
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE UseWizard>
	':����������:	��� ������������� ������� � ���������� ��� Null (��������������� �����������)
	':���������:	Public UseWizard [String]
	Public UseWizard			' ��� ������������� ������� � ���������� ��� Null (��������������� �����������)
	'@@XListClass.MaxRows
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE MaxRows>
	':����������:	������������ ���-�� ����� (��������������� �����������)
	':���������:	Public MaxRows [Integer]
	Public MaxRows				' ������������ ���-�� ����� (��������������� �����������)
	'@@XListClass.GridLines
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE GridLines>
	':����������:	������� ����������� �������� ���������� ������������� (����� ������)
	':���������:	Public GridLines [Boolean]
	Public GridLines			' ������� ����������� ���������� (��������������� �����������)
	'@@XListClass.CheckBoxes
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE CheckBoxes>
	':����������:	������� ������ ����� ������ (��������������� �����������)
	':���������:	Public CheckBoxes [Boolean]
	Public CheckBoxes			' ������� ������ checkbox'�� (��������������� �����������)
	'@@XListClass.ShowLineNumbers
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE ShowLineNumbers>
	':����������:	������� ������ ������� ����� (��������������� �����������)
	':���������:	Public ShowLineNumbers [Boolean]
	Public ShowLineNumbers		' ������� ������ ������� ����� (��������������� �����������)

    '@@XListClass.Loader
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE Loader>
	':����������:	URL ���������� ������ (��������������� �����������)
	':���������:	Public Loader [String]
	Public Loader				' URL ���������� ������ (��������������� �����������)
	'@@XListClass.Restrictions
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE Restrictions>
	':����������:	�������������� ��������� ����������, ��������������� ����������� (���������� ���������� ���������� RESTR)
	':���������:	Public Restrictions [String]
	Public Restrictions			' �������������� ��������� ����������, ��������������� ����������� (���������� ���������� ���������� RESTR)
	'@@XListClass.ValueObjectIDs
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE ValueObjectIDs>
	':����������:	������ ��������������� ��������, ������� ������ �������������� � ������� (���������� ���������� ���������� VALUEOBJECTID)
	':���������:	Public ValueObjectIDs [String]
	Public ValueObjectIDs		' ������ ��������������� ��������, ������� ������ �������������� � ������ (���������� ���������� ���������� VALUEOBJECTID)
	
	'@@XListClass.OffCreate
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE OffCreate>
	':����������:	������� ������������� �������� �������� ��������
	':���������:	Public OffCreate [Boolean]
	Public OffCreate			
	'@@XListClass.OffEdit
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE OffEdit>
	':����������:	������� ������������� �������� ��������������
	':���������:	Public OffEdit [Boolean]
	Public OffEdit				
	'@@XListClass.OffClear
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE OffClear>
	':����������:	������� ������������� �������� ��������
	':���������:	Public OffClear [Boolean]
	Public OffClear				
	'@@XListClass.OffReport
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE OffReport>
	':����������:	������� ���������� ������� ������ ������, ����������� ������ ��������
	':���������:	Public OffReport [Boolean]
	Public OffReport			 
	'@@XListClass.AccelProcessing
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE AccelProcessing>
	':����������:	������� ����, ��� ���� ��������� ���������� "�������" ������
	':���������:	Public AccelProcessing [Boolean]
	Public AccelProcessing		' ������� ����, ��� ���� ��������� ������
	
	Private EVENTS				' ������ �������������� �������
	Private m_sXListPageVarName	' As String	- ������������ ���������� � ����������� ����������
	Private m_oMenu				' As MenuClass - ����
	Private m_oEventEngine		' As EventEngineClass	

	Private m_sCaption			' ��������� ������
	Private m_bInTrackContextMenu	' ������� ����, ��� ����������� ���� ��� �������� � �� ���� ������� ��� ��������
	Private m_bMayBeInterrupted	' ������� ����, ��� ��������� ����� �� ������ � ���� �� �������� �� ������� ���������� �����������
	Private m_sOldSelectedID	' ������������� ���������� ������ �� ������������ ������
	
	'==========================================================================
	'@@XListClass.MayBeInterrupted
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE MayBeInterrupted>
	':����������:	������� ����, ��� ��������� ����� �� ������ � ���� �� �������� �� ������� ���������� �����������
	':���������:	Public Property Get MayBeInterrupted [Boolean]
	Public Property Get MayBeInterrupted
		MayBeInterrupted = (m_bMayBeInterrupted=True And m_bInTrackContextMenu<>True)
	End Property
	Private Property Let MayBeInterrupted(bValue)
		m_bMayBeInterrupted = bValue=true
	End Property
	
	
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "BeforeEdit,Edit,AfterEdit," & _
				"BeforeCreate,Create,AfterCreate," & _
				"BeforeDelete,Delete,AfterDelete," & _
				"BeforeListReload,AfterListReload,GetRestrictions," & _
				"ListColumnWidthChange,MenuBeforeShow,Accel,SetDefaultFocus"
		MayBeInterrupted = true
		m_bInTrackContextMenu = False
		Set m_oEventEngine = X_CreateEventEngine
		' �������������� ��������� ������������ �������
		m_oEventEngine.InitHandlers EVENTS, "usrXList_On"
		' ����������� ����������� ������� ������, ���� �� ����� ����������������
		' 3-�� True ��������: ��������� ���������� ������ � ������ ���������� ��� ������� ������� ������ ������������
		' 4-�� False ��������: �� �������������� ��������� ������������, � ��������� � ���
		m_oEventEngine.InitHandlersEx EVENTS, "stdXList_On", True, False
		Set m_oMenu = New MenuClass
	End Sub
	

	'==========================================================================
	' ������������� �������� ������ �� ���������
	Sub Internal_SetContainer(sContainerVarName)
		m_sXListPageVarName = sContainerVarName
	End Sub


	'==========================================================================
	'@@XListClass.InitMenu
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE InitMenu>
	':����������: ������������� ����.
	':���������: Public Sub InitMenu(oMenuXmlMD [as XMLDOMElement])
	':���������: 
	'	oMenuXmlMD - 
	'       [in] ���������� ����.
	Public Sub InitMenu(oMenuXmlMD)
		' �������� ������ ���� � ��������� ����������� �����������
		m_oMenu.SetMacrosResolver X_CreateDelegate(Me, "MenuMacrosResolver")
		m_oMenu.SetVisibilityHandler X_CreateDelegate(Me, "MenuVisibilityHandler")
		m_oMenu.SetExecutionHandler X_CreateDelegate(Me, "MenuExecutionHandler")
		If Not oMenuXmlMD Is Nothing Then
			' ���������������� ���� ����� ����� ���� ��� ������ � ��
			m_oMenu.Init oMenuXmlMD
		End If
		' �������������, ��� � ��������� ���� ���������������� ����� ����������: ObjectID, ObjectType
		m_oMenu.Macros.Item("OBJECTID") = Null
		m_oMenu.Macros.Item("OBJECTTYPE") = ObjectType
	End Sub


	'==========================================================================
	'@@XListClass.Container
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE Container>
	':����������:	���������� ��������� ���������� XListPage, ��������� ��� �������� ���������� XList
	':���������:	Public Property Get Container [As XListPage]
	Public Property Get Container
		Set Container = Eval(m_sXListPageVarName)
	End Property


	'==========================================================================
	'@@XListClass.Menu
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE Menu>
	':����������:	���������� ��������� ����
	':���������:	Public Property Get Menu [As MenuClass]	
	Public Property Get Menu
		Set Menu = m_oMenu
	End Property


	'==========================================================================
	'@@XListClass.EventEngine
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE EventEngine>
	':����������:	���������� ��������� <LINK Client_EventEngine, EventEngineClass>, ������������ ��� ��������� �������
	':���������:	Public Property Get EventEngine [As <LINK �lient_EventEngine, EventEngineClass>]	
	Public Property Get EventEngine
		Set EventEngine = m_oEventEngine
	End Property
	
	
	'==========================================================================
	' ���������� �������
	'	[in] sEventName As String
	'	[in] oEventArgs As Object 
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub
	
	'==========================================================================
	'@@XListClass.SetCaption
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SetCaption>
	':����������: ��������� ��������� ������.
	':���������: Public Sub SetCaption(sCaption [as Sting])
	':���������: 
	'	sCaption - 
	'       [in] ������ � ������� ��������� ������.
	'
	Public Sub SetCaption(sCaption)
		m_sCaption = sCaption
	End Sub


	'==========================================================================
	'@@XListClass.GetRestrictions
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetRestrictions>
	':����������: ���������� ������ ����������� �������, ���������� �� ����������.
	':���������: Public Function GetRestrictions() [as String]
	Public Function GetRestrictions()
        With New GetRestrictionsEventArgsClass
            .StayOnCurrentPage = False
            .ReturnValue = vbNullString
            .UrlParams = vbNullString
            FireEvent "GetRestrictions", .Self()
            GetRestrictions = .ReturnValue
        End With
	End Function

	
	'==========================================================================
	'@@XListClass.Reload
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE Reload>
	':����������:  ������������� ������ � ������������ � ������������� �������.
	':���������: Public Sub Reload()
	Public Sub Reload()
		ReloadEx False
	End Sub
	
	'==========================================================================
	'@@XListClass.ReloadEx
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE ReloadEx>
	':����������:  ������������� ������ � ������������ � ������������� �������.
	':���������: Public Sub ReloadEx( bStayOnCurrentPage [As Boolean])
	':���������: 
	'	bStayOnCurrentPage - 
	'       [in] �������, �������� ������������� �������� �� ������� �������� 
	'			(��� ������������� ���������).
	Public Sub ReloadEx(bStayOnCurrentPage)
		Dim bMoreRows		' ������� ����, ��� ���� ������ ��������, ��� ��������
		Dim sWhere			' ����������� �������
		Dim sUrlParams      ' �������������� ���������, ������������ � ���������
		Dim dtTime

		MayBeInterrupted = false
		
		m_sOldSelectedID = ListView.Rows.SelectedID
		FireEvent "BeforeListReload", Nothing
		
		With X_CreateControlsDisabler(Me)
			Container.ShowProcessMessage "��������� �����������..."

			' #259932 - ������ ��� ��������� hotkey � ������, ���� � ���� � ������� ������� ������������ ��������.
			' �������� ������ ��� ���������� �������� side-��������
			' ������ ��� � ��� �� ������������� �������� ��������� ��� �������� �������� ��������� 
			' �������� ������
			ListView.Rows.RemoveAll()
				
		    ' �������� ����������� �������
		    ' ����������: �� ���������� ����� GetRestrictions, �.�. ��� ��� ���� �������� UrlParams
            With New GetRestrictionsEventArgsClass
                .ReturnValue = vbNullString
                .UrlParams = vbNullString
                .StayOnCurrentPage = bStayOnCurrentPage
                FireEvent "GetRestrictions", .Self()
                sWhere = .ReturnValue
                sUrlParams = .UrlParams
            End With
            If 0<>Len(sUrlParams) Then
                sUrlParams = "&" & sUrlParams
            End If    
        
			If False = sWhere Then
				' ��������� ������ ����� ������. False ������ ���������� ����������, ����������� ���������� ���������� x-list-page ��� � ������
				Container.ShowProcessMessage "����������� ��������� �����������..."
				' ������ � ������� - �������!
				MayBeInterrupted = true
				Exit Sub
			End If

			Container.ShowProcessMessage "�������� ������..."

			ListView.ShowBorder = False
			' ������ ����� ����������, ���� ��� �� ��������� ��������� off-rownumbers
			ListView.LineNumbers = ShowLineNumbers
			' ����� ��������� ������ ��������� ����� - ��� ��������...
			ListView.GridLines = False

			If 0=ListView.Columns.Count Then
				RestoreColumnsFromUserData
			End If
			
			' ����� ������ ������������
			On Error Resume Next
			dtTime = Now()
			bMoreRows = ListView.XMLLoad( Loader & "&TM=" & ListView.XClientService.NewGuidString() ,"WHERE=" & ListView.XClientService.URLEncode(sWhere) & "&RESTR=" &  ListView.XClientService.URLEncode(Restrictions) & "&VALUEOBJECTID=" & ListView.XClientService.URLEncode(ValueObjectIDs) & sUrlParams , MaxRows , True)	
			If Err Then
				X_SetLastServerError ListView.XClientService.LastServerError, Err.number, Err.Source, Err.Description
				If X_IsSecurityException(ListView.XClientService.LastServerError) Then
					Container.ShowProcessMessage "� ������� ��������..."
					Err.Clear
					MayBeInterrupted=true
					Exit Sub
				Else
					X_HandleError
					ReportStatus "������ �� ��������: " & Err.description
				End If
			Else
				dtTime = Now() - dtTime
				ReportStatus "������ �������� ("	& CStr(DatePart("n",dtTime) * 60 + DatePart("s",dtTime)) & " ���.)"
			End If
			On Error GoTo 0
			' ����� ������ �� ������������
			If 0 = ListView.Rows.Count Then
				If Len( sWhere) = 0 Then
					Container.ShowProcessMessage "����������� ������ ��� ����������� � ������."
				Else
					Container.ShowProcessMessage "��� ����������, ��������������� �������."
				End If
			Else
				ListView.GridLines = GridLines
				Container.HideProcessMassage
				' TODO:
				' ����� ����: ListView.Rows.SelectedPosition=0
				' ��������� ListView.Rows.SelectedPosition ��� ���������������
				' ��������� ������ �������� � ������� ���������� �������� � ������ -
				' ������� ������ ����������������
			End If
		End With
		ListView.CheckBoxes = CheckBoxes
		
		With New AfterListReloadEventArgsClass
			.HasMoreRows = bMoreRows
			.MaxRows = MaxRows
			.Restrictions = sWhere
			FireEvent "AfterListReload", .Self()
		End With
			
		MayBeInterrupted = true
	End Sub


	'==============================================================================
	'@@XListClass.TrackContextMenu
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE TrackContextMenu>
	':����������: ��������� ������������ ����.
	':���������: Public Sub TrackContextMenu()
	
	Public Sub TrackContextMenu()
		Internal_showContextMenu Null, Null
	End Sub


	'==============================================================================
	' ���������� ���������� ���� ������ ���� � �������� �����, ���� � ������� ������� ������� ����
	'	[in] nPosX - �������� X-��������� ��� ����������� ���� ��� Null
	'	[in] nPosY - �������� Y-��������� ��� ����������� ���� ��� Null
	Private Sub Internal_showContextMenu(nPosX, nPosY)
		If m_bInTrackContextMenu = True Then Exit Sub
		m_bInTrackContextMenu = True

		' ������� ������ �� ���� ��� ������
		If m_oMenu Is Nothing Then m_bInTrackContextMenu = False: Exit Sub: End If
		If Not m_oMenu.Initialized Then m_bInTrackContextMenu = False: Exit Sub: End If
		
		With X_CreateControlsDisabler(Me)
			prepareMenuBeforeShow
			' ��������� ����
			If IsNull(nPosX) Or IsNull(nPosY) Then
				m_oMenu.ShowPopupMenu Me
			Else
				m_oMenu.ShowPopupMenuWithPos Me, nPosX, nPosY
			End If
		End With
		m_bInTrackContextMenu = False
	End Sub


	'==============================================================================
	' �������������� ���� � �����������
	Private Sub prepareMenuBeforeShow
		' TODO: ����� ���� ������� ������ �������� load-cmd ���� list-menu ���������� ������ � �������� ���� � �������, 
		' ���� �� �����. ���� �������� ����� � �������, �� ������ ���� ���� ��������������������.
		
		' ������� ���������������� ����������
		' ��������, ���� ���������������� ���������� ������� ������ ����, �� �� ������ ���������� �� �������� n
		With New MenuEventArgsClass
			Set .Menu = m_oMenu
			FireEvent "MenuBeforeShow", .Self()
		End With
	End Sub
	
	
	'==============================================================================
	'@@XListClass.MenuMacrosResolver
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE MenuMacrosResolver>
	':����������: ����������� �������� �������� ���� ObjectType � ObjectID.
	':���������: Public Sub MenuMacrosResolver(
	'               oSender [as MenuClass], 
	'               oEventArgs [as MenuEventArgsClass])
	':���������: 
	'   oSender -
	'       [in] ������, ��������������� �������, ��������� ������ MenuClass
	'   oEventArgs - 
	'       [in] ��������� �������, ��������� MenuEventArgsClass
	Public Sub MenuMacrosResolver(oSender, oEventArgs)
		Dim oRow			' ��������� ������ ������ IXListRow
		Dim sKey			' ���� � ���-�������
		Dim i

		' ������� ������� ��� �������� ��������
		For Each sKey In m_oMenu.Macros.Keys
			m_oMenu.Macros.Item(sKey) = Null
		Next
		' �������� �������� ���������������� �������� - ������������ ���� � ��������� ������������� (��� ���� ������)
		
		m_oMenu.Macros.item("ObjectType") = ObjectType
		' ��������� �������� ��������, ��� ����� ��������� � �������������� �������
		' ��������� ������� ����� ������ �� ����������� ��������� ������ � �������, ������������ ������� ��������� � ������ �������
		If ListView.Rows.Selected>=0 Then
			Set oRow = ListView.Rows.GetRow( ListView.Rows.Selected )
			For i=0 To ListView.Columns.Count-1
				sKey = UCase(ListView.Columns.GetColumn(i).Name)
				If sKey<>"OBJECTID" And sKey<>"OBJECTTYPE" Then
					m_oMenu.Macros.Item(sKey) = oRow.GetField(i).Value
				End If
				If UCase(IdentifiedBy) = sKey Then
					' ������� ������� ������������ ��� ������������� �������
					m_oMenu.Macros.item("ObjectID") = oRow.GetField(i).Value
				End If
				If UCase(TypedBy) = sKey Then
					m_oMenu.Macros.item("ObjectType") = oRow.GetField(i).Value
				End If
			Next
			If IsNull( m_oMenu.Macros.item("ObjectID") ) Then
				' � ������ ���������� �������������, ���� ���� ������� ��������� � identified-by �� �����, ����� id ������� ������
				m_oMenu.Macros.item("ObjectID") = GetSelectedRowID()
			End if
		End If
	End Sub
	
	
	'==============================================================================
	'@@XListClass.MenuVisibilityHandler
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE MenuVisibilityHandler>
	':����������: ����������� ���������� ��������� �����������/��������� ������� ����. ����������� �������� ����������� ����������� ������� ����. 
	'      ��� � ������������� �������, ��� �������� ����������� ����������� ��������, ������� �� ������� �������� ���� (� �� �� ��������� ������).
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
		Dim sGUID			' As String - ������������� ���������� �������
		Dim sType			' As String - ������������ ���� ���������� �������
		Dim bDisabled		' As Boolean - ������� ����������������� ������
		Dim bHidden			' As Boolean - ������� �������� ������
		Dim oNode			' As XMLDOMElement - ������� menu-item
		Dim oParam			' As IXMLDOMElement - ���� param � ���������� ���� 
		Dim oList			' As ObjectArrayListClass - ������ �������� XObjectPermission
		Dim sAction			' As String - ������������ ��������(action'a) ������ ����
		Dim bProcess		' As Boolean - ������� ��������� �������� ������
		Dim bTrustworthy	' As Boolean - ������� "�������������� �������" ���� - ��� ��� ������ �� ���� ��������� �������� ����

		sType = m_oMenu.Macros.item("ObjectType")
		sGUID = m_oMenu.Macros.item("ObjectID")
		Set oList = New ObjectArrayListClass
		bTrustworthy = Not IsNull(m_oMenu.XmlMenu.getAttribute("trustworthy"))
		' ���������� ������ ��������� ��� ��������
		For Each oNode In oEventArgs.ActiveMenuItems
			bHidden = Empty
			bDisabled = Empty
			bProcess = False
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
			If Not bTrustworthy Then 
				oNode.setAttribute "type", sType
				If hasValue(sGUID) Then _
					oNode.setAttribute "oid",  sGUID
			End If

			sAction = oNode.getAttribute("action")
			Select Case sAction
				Case CMD_ADD
					bHidden = OffCreate
					If Not bTrustworthy Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CREATE, sType, Empty)
					bProcess = True
				Case CMD_VIEW
					bHidden = IsNull(sGUID)
					bProcess = True
				Case CMD_EDIT
					bHidden = IsNull(sGUID) Or OffEdit
					If Not bHidden And Not bTrustworthy Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CHANGE, sType, sGUID)
					bProcess = True
				Case CMD_DELETE
					bHidden = IsNull(sGUID) Or OffClear
					If Not bHidden And Not bTrustworthy Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_DELETE, sType, sGUID)
					bProcess = True
				Case Else
					With New SetMenuItemVisibilityEventArgsClass
						Set .Menu = m_oMenu
						Set .MenuItemNode = oNode
						.Action = sAction
						FireEvent "SetMenuItemVisibility", .Self()
						bHidden		= .Hidden
						bDisabled	= .Disabled
					End With
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
			m_oMenu.SetMenuItemsAccessRights oList.GetArray()
		End If
	End Sub
	
	
	'==========================================================================
	'@@XListClass.MenuExecutionHandler
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE MenuExecutionHandler>
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
		Dim sGUID		' ������������� ���������� �������

		sGUID = m_oMenu.Macros.item("ObjectID")
		Select Case oEventArgs.Action
			Case CMD_EDIT:
				' ���� ������� ��������� �� ������ ����� ��������� ����, ��������� ��� �� ��������� �������� use-for-editing objects-list'a
				If Not hasValue(m_oMenu.Macros.Item("MetanameForEdit")) Then
					m_oMenu.Macros.Item("MetanameForEdit") = UseEditor
				End If
				oEventArgs.Cancel = Not DoEdit(m_oMenu.Macros)
			Case CMD_ADD:			
				' ���� ������� ������� �� ������ ����� ��������� ����, ��������� ��� �� ��������� �������� use-for-creation objects-list'a
				If Not hasValue(m_oMenu.Macros.Item("MetanameForCreate")) Then
					m_oMenu.Macros.Item("MetanameForCreate") = UseWizard
				End If
				oEventArgs.Cancel = Not DoCreate(m_oMenu.Macros)
			Case CMD_DELETE:
				If Not hasValue(m_oMenu.Macros.Item("Prompt")) Then
					m_oMenu.Macros.Item("Prompt") = "�� ������������� ������ ������� ������?"
				End If
				oEventArgs.Cancel = Not DoDelete(m_oMenu.Macros)
			Case CMD_VIEW:			
				X_OpenReport m_oMenu.Macros.Item("ReportURL")
		End Select
	End Sub
	
	'==========================================================================
	'@@XListClass.DoEdit
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE DoEdit>
	':����������: �������������� ������� ������. ���������� True, ���� �������� ���������.
	':���������: Public Function DoEdit(oValues [as Scripting.Dictionary]) [As Boolean]
	':���������: 
	'    oValues -
	'       [in] ��������� ���������� �������� ����
	Public Function DoEdit(oValues)
		Dim sGUID	' ������������� �������� �������
		DoEdit = False
		sGUID = oValues.Item("ObjectID")
		If 0 = Len(sGUID) Then Exit Function
		With X_CreateControlsDisabler(Me)
			With New CommonEventArgsClass
				.ObjectID = sGUID
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = False
				' ��������� ������� ���������. ��� ������ ���� ������ � ��������� ��������
				.Metaname = oValues.Item("MetanameForEdit")
				Set .Values = oValues
				' ���������� � ��������������
				FireEvent "BeforeEdit", .Self()
				' ����������� ����� ��������� ���� "�������� ����������"
				If .ReturnValue Then Exit Function
				' ��������������
				FireEvent "Edit", .Self()
				' �� ���������� ��������������
				FireEvent "AfterEdit", .Self()
			End With
		End With
		DoEdit = True
	End Function

	'==========================================================================
	'@@XListClass.DoCreate
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE DoCreate>
	':����������: �������� ������ ������� ������. ���������� True, ���� �������� ���������.
	':���������: Public Function DoCreate(oValues [as Scripting.Dictionary]) [As Boolean]
	':���������: 
	'    oValues -
	'       [in] ��������� ���������� �������� ����
	Public Function DoCreate(oValues)
		DoCreate = False
		With X_CreateControlsDisabler(Me)
			With New CommonEventArgsClass
				.ObjectID = Null
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = Empty
				' ��������� ������� �������. ��� ������ ���� ������ � ��������� ��������
				.Metaname = oValues.Item("MetanameForCreate")
				Set .Values = oValues
				' ���������� � ��������
				FireEvent "BeforeCreate", .Self()
				' ����������� ����� ��������� ���� "�������� ����������"
				If .ReturnValue Then Exit Function
				' ��������
				FireEvent "Create", .Self()
				' �������������
				FireEvent "AfterCreate", .Self()			
			End With	
		End With
		DoCreate = True
	End Function

	'==========================================================================
	'@@XListClass.DoDelete
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE DoDelete>
	':����������: ��������  ������� ������. ���������� True, ���� �������� ���������.
	':���������: Public Function DoDelete(oValues [as Scripting.Dictionary]) [As Boolean]
	':���������: 
	'    oValues -
	'       [in] ��������� ���������� �������� ����
	Public Function DoDelete(oValues)
		Dim sGUID		' ������������� ���������� �������		
		DoDelete = False
		' ������� ������������� ���������� �������
		sGUID = oValues.Item("ObjectID")
		If 0=Len(sGUID) Then Exit Function
		With X_CreateControlsDisabler(Me)
			With New DeleteObjectEventArgsClass
				.ObjectID = sGUID
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = True
				Set .Values = oValues
				' ���������� � ��������
				FireEvent "BeforeDelete", .Self()
				' ����������� ����� ��������� ���� "�������� ����������"
				If .ReturnValue = False Then Exit Function
				' ��������
				FireEvent "Delete", .Self()
				' ����������� ����� ��������� ���� "�������� ����������"
				If .ReturnValue = False Then Exit Function
				' �������������
				FireEvent "AfterDelete", .Self()
			End With
		End With
		DoDelete = True
	End Function
	
	
	'==========================================================================	
	'@@XListClass.EnableControlsInternal
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE EnableControlsInternal>
	':����������: ������������/��������������� ��������� ����������. ���������� ������� (�� ����������). �������� ���������� ����������.
	':���������: Public Sub EnableControlsInternal( 
	'                   ByVal bEnable [as Boolean])
	':���������: 
	'    bEnable - 
	'       [in] ������� ����������/������������� ��������� ����������.
	Public Sub EnableControlsInternal( ByVal bEnable)
		ListView.LockEvents = not bEnable
	End Sub


	'==========================================================================	
	'@@XListClass.EnableControls
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE EnableControls>
	':����������: ������������/��������������� ��������� ����������. ���������� ������� (� ������� X_CreateControlsDisabler).
	' �������� ���������� ����������.
	':���������: Public Sub EnableControls (ByVal bEnable [as Boolean])	
	':���������: 
	'    bEnable - 
	'       [in] ������� ����������/������������� ��������� ����������.
	Public Sub EnableControls( ByVal bEnable)
		EnableControlsInternal bEnable
		Container.EnableControls bEnable
	End Sub


	'==========================================================================
	' ����� ������ ������� ��������
	'	[In] sMsg - ��������� ������
	Private Sub ReportStatus( sMsg)
		Container.ReportStatus sMsg
	End Sub
	
	'==========================================================================
	'@@XListClass.RestoreColumnsFromUserData
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE RestoreColumnsFromUserData>
	':����������: ��������������� ������������� ������ �� xml-�����, ������������ � ������� SaveUserData.
	':���������: Public Sub RestoreColumnsFromUserData
	Public Sub RestoreColumnsFromUserData
		Dim oListColumns	' IXMLDOMElement, ���������� �� ��������� �������
		
		If Container.GetViewStateCache( "columns", oListColumns) Then
			If IsObject(oListColumns) Then
				If Not Nothing Is oListColumns.selectSingleNode("C") Then
					With XService.XmlGetDocument
						.appendChild .createElement("LIST")
						.documentElement.appendChild oListColumns
						.documentElement.appendChild .createElement("RS")
					End With
					ListView.XMLFillList oListColumns.ownerDocument, -1, True
				End If
				Set oListColumns = Nothing
			End If	
		End If
	End Sub


	'==========================================================================
	'@@XListClass.SaveColumnsInUserData
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SaveColumnsInUserData>
	':����������: ��������� ������������� ������ � xml-����.
	':���������: Public Sub SaveColumnsInUserData
	Public Sub SaveColumnsInUserData
		If 0=ListView.Columns.Count Then Exit Sub
		Container.SaveViewStateCache "columns", ListView.Columns.Xml
	End Sub
	
	
	'==========================================================================
	'@@XListClass.SetListFocus
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SetListFocus>
	':����������: ������������� ����� �� ������
	':���������: Public Sub SetListFocus()
	Public Sub SetListFocus()
		window.Focus()
		' ��������� ������ ����������� ��� ��������� ������ - �.�. ��� ������
		' � ���� ������� ������ (���������� ����, ���������� ���������� ������������ 
		' � �.�.) ����� ���� ���������� ��� �����
		on error resume next
		ListView.Focus()
		on error goto 0
	End Sub	


	'==============================================================================
	'@@XListClass.SetDefaultFocus
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SetDefaultFocus>
	':����������: �������� ��������� �� ��������� ������ ����� ���������� ������.
	'   ������������ ������� SetDefaultFocus ���� ���� ����������, ����� �������� 
	'   ����������� ����������.
	':���������:  Public Sub SetDefaultFocus(oFilterObject [as XFilterObjectClass])
	':���������: 
	'   oFilterObject - 
	'           [in] htc-������ �������
	Public Sub SetDefaultFocus(oFilterObject)
		' ��� ��������� ����� ����������� �������� ���������	
		If m_oEventEngine.IsHandlerExists("SetDefaultFocus") Then
			With New SetDefaultFocusEventArgsClass
				Set .FilterObject = toObject(oFilterObject)
				FireEvent "SetDefaultFocus", .Self()
			End With
		Else
			SetDefaultFocusImpl(oFilterObject)
		End If
	End Sub
	
	'==============================================================================
	'@@XListClass.SetDefaultFocusImpl
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SetDefaultFocusImpl>
	':����������: ����������� ���������� ��������� ������ ����� ���������� ������. 
	'       ���� ���� ������, �� ����� ��������������� �� ������, ������� ���� �� ������������. ���� ������� ���, ����� ��������������� �� ������.
	':���������: Public Sub SetDefaultFocusImpl(oFilterObject [as XFilterObjectClass])
	':���������: 
	'   oFilterObject - 
	'           [in]  htc-������ �������
	Public Sub SetDefaultFocusImpl(oFilterObject)
		If ListView.Rows.Count > 0 Then
			SetListFocus
			
			If Len(m_sOldSelectedID) > 0 Then
				If Not ListView.Rows.FindRowByID(m_sOldSelectedID) Is Nothing Then
					ListView.Rows.SelectedID = m_sOldSelectedID
				ElseIf ListView.Rows.Count > 0 Then
					ListView.Rows.SelectedPosition = 0
				End If
			Else
				ListView.Rows.SelectedPosition = 0
			End If
		ElseIf hasValue(oFilterObject) Then
			oFilterObject.SetFocus
		End If
	End Sub
	
	'==============================================================================
	'@@XListClass.GetRowObjectTypeName
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetRowObjectTypeName>
	':����������: ���������� ������������ ���� ������� �������� ������
	':���������: Public Function GetRowObjectTypeName(oRow [as IXListRow]) [as String]
	':���������: 
	'   oRow - 
	'   	[in] ������ ������
	Public Function GetRowObjectTypeName(oRow)
		Dim i
		Dim sColumnName		' ������������ �������
		
		For i=0 To ListView.Columns.Count-1
			sColumnName = UCase(ListView.Columns.GetColumn(i).Name)
			If UCase(TypedBy) = sColumnName Then
				GetRowObjectTypeName = oRow.GetField(i).Value
				Exit Function
			End If
		Next
		GetRowObjectTypeName = ObjectType
	End Function
	
	
	'==============================================================================
	'@@XListClass.GetSelectedRowObjectTypeName
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetSelectedRowObjectTypeName>
	':����������: ���������� ������������ ���� ������� ������� ��������� ������.
	':���������: Public Function GetSelectedRowObjectTypeName() [as String]	
	Public Function GetSelectedRowObjectTypeName()
		If ListView.Rows.Selected >= 0 Then
			GetSelectedRowObjectTypeName = GetRowObjectTypeName( ListView.Rows.GetRow(ListView.Rows.Selected) )
		End If
	End Function

		
	'==========================================================================
	'@@XListClass.GetTypeName
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetTypeName>
	':����������: ���������� ��� ��������, ����������� � ������.
	':���������: Public Function GetTypeName() [as String]
	Public Function GetTypeName()
		GetTypeName = ObjectType
	End Function

	'==========================================================================
	'@@XListClass.GetSelectedRowID
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetSelectedRowID>
	':����������: ���������� ������������� ��������� ������ ��� ������ ������.
	':���������: Public Function GetSelectedRowID() [as Variant]
	Public Function GetSelectedRowID()
		GetSelectedRowID = ListView.Rows.SelectedID
	End Function

	'==========================================================================
	'@@XListClass.GetSelectedObjectID
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetSelectedObjectID>
	':����������: ���������� ������������� ���������� ������� ��� ������ ������.
	':���������: Public Function GetSelectedObjectID() [as String]
	Public Function GetSelectedObjectID()
		Dim oRow
		If not hasValue( IdentifiedBy) Then
			GetSelectedObjectID = GetSelectedRowID()
		ElseIf ListView.Rows.Selected >= 0 Then
			Set oRow = ListView.Rows.GetRow( ListView.Rows.Selected )
			GetSelectedObjectID = oRow.GetFieldByName(IdentifiedBy)
		End If
	End Function
	
	'==========================================================================
	'@@XListClass.GetSelectedRow
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetSelectedRow>
	':����������: ���������� ������ ��������� ������.
	':���������: Public Function GetSelectedRow() [as Integer]
	Public Function GetSelectedRow()
		GetSelectedRow = ListView.Rows.Selected
	End Function

	'==========================================================================
	'@@XListClass.GetCheckedObjectIDs
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetCheckedObjectIDs>
	':����������: ���������� ������ ��������������� ���������� �����.
	':���������: Public Function GetCheckedObjectIDs [as Variant]
	Public Function GetCheckedObjectIDs
		Dim vSel
		Dim nIdx
		Dim i
		
		ReDim vSel(ListView.Rows.Count - 1)	' ������������ ������ �� ���������� ����� � ������
		nIdx = 0
		With ListView.Rows
			For i=0 To .count -1
				With .GetRow(i)
					If .Checked Then
						vSel( nIdx) = .ID	' ������� �������������� ���������� ����� � ������
						nIdx = nIdx + 1
					End If
				End With
			Next
		End With
		ReDim Preserve vSel(nIdx - 1)	' ��������� � ������� ������ ��������������
		GetCheckedObjectIDs = vSel
	End Function


	'==========================================================================
	'@@XListClass.SelectRowByID
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SelectRowByID>
	':����������: ���������� ������ ��������������� ���������� �����. ������������� ������� ������ �� ID ������ (�� �� ID �������, ���� �� ������������ ��������� ������������� ����� ������� identified-by ����) sGUID - ������������� �������.
	' <b>��������!</b> ������ ����� ����� �������������� ������������� ���������.
	':���������: Public Sub SelectRowByID (sGUID [as String])
	':���������: 
	'       sGUID - 
	'           [in] ������������� �������
	Public Sub SelectRowByID( sGUID)
		Dim oRow ' ������ ������
		Set oRow = ListView.Rows.FindRowByID(sGUID) 
		If Nothing Is oRow Then Exit Sub
		ListView.Rows.SelectedID = sGUID
	End Sub


	'==========================================================================	
	'@@XListClass.SelectRowByObjectID
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SelectRowByObjectID>
	':����������: �������� ������ �� �������������� �������.
	':���������: Public Sub SelectRowByObjectID(sObjectID [as String])
	':���������: 
	'       sObjectID - 
	'           [in] ������������� �������
	Public Sub SelectRowByObjectID(sObjectID)
		If Not hasValue(IdentifiedBy) Then
			SelectRowByID sObjectID
		Else
			SelectRowByFieldValue IdentifiedBy, sObjectID
		End If
	End Sub

	'==============================================================================
	'@@XListClass.SelectAll
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SelectAll>
	':����������: � ������ �������������� ������ �������� ��� ������.
	':���������: Public Sub SelectAll
	Public Sub SelectAll
		Dim i
		If Not CheckBoxes Then Exit Sub
		For i=0 to ListView.Rows.Count -1
			ListView.Rows.GetRow(i).Checked = True
		Next
	End Sub


	'==============================================================================
	'@@XListClass.DeselectAll
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE DeselectAll>
	':����������: � ������ �������������� ������ ������� ������� �� ���� ��������� �����
	':���������: Public Sub DeselectAll
	Public Sub DeselectAll
		Dim i
		If Not CheckBoxes Then Exit Sub
		For i=0 to ListView.Rows.count -1
			ListView.Rows.GetRow(i).Checked = false
		Next
	End Sub


	'==============================================================================
	'@@XListClass.InvertSelection
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE InvertSelection>
	':����������: � ������ �������������� ������ ����������� ��������� ��������� �����.
	':���������: Public Sub InvertSelection
	Public Sub InvertSelection
		Dim i
		If Not CheckBoxes Then Exit Sub
		For i=0 To ListView.Rows.count -1
			With ListView.Rows.GetRow(i)
				.Checked = NOT .Checked
			End With
		Next
	End Sub


	'==============================================================================
	'@@XListClass.ChangeSelectedRowState
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE ChangeSelectedRowState>
	':����������: ��� ������ ������ � �������������� ������ �������� ��������� ��������� ������
	':���������: Public Sub ChangeSelectedRowState
	Public Sub ChangeSelectedRowState
		Dim nRow	' ������ ��������� ������
		
		If Not CheckBoxes Then Exit Sub
		nRow = ListView.Rows.Selected
		If nRow>=0 Then
			ListView.Rows.GetRow(nRow).Checked = Not ListView.Rows.GetRow(nRow).Checked 
		End If
	End Sub
	
	
	'==============================================================================
	'@@XListClass.OnWidthChange
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE OnWidthChange>
	':����������: ���������� ������� ��������� ������� ������.
	':���������: Public Sub OnWidthChange(nColIndex [as Integer], nWidth [as Integer])
	':���������: 
	'   nColIndex - 
	'       [in] ��������� ������������� ������� (���������� ����� �� ���������� �������������)
	'   nWidth - 
	'       [in] ������ ������� � ��������
	Public Sub OnWidthChange(nColIndex, nWidth)
		If m_oEventEngine.IsHandlerExists("ListColumnWidthChange") Then
			With New ListColumnWidthChangeEventArgsClass
				Set .SenderObject = ListView
				.ColumnIndex = nColIndex
				.ColumnWidth = nWidth		
				FireEvent "ListColumnWidthChange", .Self()
			End With 
		End If
	End Sub


	'==============================================================================
	'@@XListClass.OnKeyUp
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE OnKeyUp>
	':����������: ���������� ������� ������� ������� � ������, ���������� ����������� XListPage.
	':���������: Public Sub OnKeyUp(oAccelerationEventArgs [as AccelerationEventArgsClass])
	':���������:	
	'   oAccelerationEventArgs - 
	'       [in] ��� �������
	Public Sub OnKeyUp(oAccelerationEventArgs)
		Dim nPosLeft, nPosTop, nPosRight, nPosBottom	' ������������� ���������� ��������� ������ ������
		Dim nListPosX, nListPosY	' �������� ���������� ������ (ListView)
		Dim nRow					' ������ ��������� ������
		
		If AccelProcessing Then Exit Sub
		
		With oAccelerationEventArgs
			If .KeyCode = VK_UP Or .KeyCode = VK_DOWN Or .KeyCode = VK_PAGEUP Or .KeyCode = VK_PAGEDOWN Then Exit Sub
			
			AccelProcessing = True
			If .KeyCode = VK_APPS Then
				' ������� ���������� ������ ������
				nRow = ListView.Rows.SelectedPosition
				If nRow > -1 Then
					ListView.GetRowCoords nRow, nPosLeft, nPosTop, nPosRight, nPosBottom
					X_GetHtmlElementScreenPos ListView, nListPosX, nListPosY
					Internal_showContextMenu nListPosX, nListPosY + nPosBottom
				End If
			Else		
				FireEvent "Accel", oAccelerationEventArgs
			End If
		End With
		AccelProcessing = False
	End Sub


	'==============================================================================
	'@@XListClass.OnDblClick
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE OnDblClick>
	':����������: ���������� �������� ������ ���� � ������.
	':���������: Public Sub OnDblClick(
	'               ByVal nIndex [as Integer], 
	'               ByVal nColumn [as Integer], 
	'               ByVal sID [as String]
	'               )
	
	Public Sub OnDblClick(ByVal nIndex , ByVal nColumn, ByVal sID)
		If AccelProcessing Then Exit Sub
		AccelProcessing = True
		' ����-���� ���������� � ������� �����
		With New AccelerationEventArgsClass
			.keyCode	= VK_ENTER
			.altKey		= False
			.ctrlKey	= False
			.shiftKey	= False
			.DblClick	= True
			FireEvent "Accel", .Self()
		End With
		AccelProcessing = False
	End Sub


	'==============================================================================
	'@@XListClass.OnUnLoad
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE OnUnLoad>
	':����������: ���������� �������� ������.
	':���������: Public Sub OnUnLoad
	Public Sub OnUnLoad
		' �������� �������� �����. ������� ������, �.�. ������ ����� �� ����
		On Error Resume Next
		SaveColumnsInUserData
		If 0 <> Err.number Then
			Err.Clear 
		End If
	End Sub
	
	
	'==============================================================================
	'@@XListClass.UpdateRow
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE UpdateRow>
	':����������: ��������� �������� ������ ������� � ������� x-list-loader.
	':���������: Public Sub UpdateRow(oRow [as IXListRow], oXmlRowData [as IXMLDOMElement])
	':���������:
	'	oRow - 
	'       [in] ������ ������
	'	oXmlRowData - 
	'       [in] xml-���� LIST � ������� ������ � ������� ���������� ������
	Public Sub UpdateRow(oRow, oXmlRowData)
		Dim i
		Dim oXmlFields
		Dim oXmlField
		Dim sVarType
		
		oRow.IconURL = ListView.XImageList.MakeIconUrl(GetRowObjectTypeName(oRow), "", oXmlRowData.getAttribute("s"))
		Set oXmlFields = oXmlRowData.selectNodes("F")
		For i=0 To ListView.Columns.Count-1
			Set oXmlField = oXmlFields.item(i)
			sVarType = ListView.Columns.GetColumn(i).Type
			If Len("" & sVarType) > 0 Then
				' ��� ������� ����� ���, ���� ������� �������������� ��������
				On Error Resume Next
				oXmlField.dataType = sVarType
				If Err Then Alert "�� ������� �������� �������� ������ '" & oXmlField.text & "' � ���� " & sVarType
				On Error GoTo 0
				oRow.GetField(i).Value = oXmlField.nodeTypedValue
			Else
				oRow.GetField(i).Value = oXmlField.text
			End If
		Next
	End Sub
End Class


'===============================================================================
'@@ListColumnWidthChangeEventArgsClass
'<GROUP !!CLASSES_x-list><TITLE ListColumnWidthChangeEventArgsClass>
':����������:	��������� ������� ����������� ��������� ������ ������.
'
'@@!!MEMBERTYPE_Methods_ListColumnWidthChangeEventArgsClass
'<GROUP ListColumnWidthChangeEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_ListColumnWidthChangeEventArgsClass
'<GROUP ListColumnWidthChangeEventArgsClass><TITLE ��������>
Class ListColumnWidthChangeEventArgsClass
	'@@ListColumnWidthChangeEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_ListColumnWidthChangeEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@ListColumnWidthChangeEventArgsClass.SenderObject
	'<GROUP !!MEMBERTYPE_Properties_ListColumnWidthChangeEventArgsClass><TITLE SenderObject>
	':����������:	������ - �������� �������
	':���������:	Public SenderObject [As IXListView]
	Public SenderObject
	
	'@@ListColumnWidthChangeEventArgsClass.ColumnIndex
	'<GROUP !!MEMBERTYPE_Properties_ListColumnWidthChangeEventArgsClass><TITLE ColumnIndex>
	':����������:	������ �������, ��� ������ ����������
	':���������:	Public ColumnIndex [As Integer]
	Public ColumnIndex
	
	'@@ListColumnWidthChangeEventArgsClass.ColumnWidth
	'<GROUP !!MEMBERTYPE_Properties_ListColumnWidthChangeEventArgsClass><TITLE ColumnWidth>
	':����������:	������ �������
	':���������:	Public ColumnWidth [As Integer]
	Public ColumnWidth
	
	'@@ListColumnWidthChangeEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_ListColumnWidthChangeEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As ListColumnWidthChangeEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@AfterListReloadEventArgsClass
'<GROUP !!CLASSES_x-list><TITLE AfterListReloadEventArgsClass>
':����������:	��������� ������� "OnAfterListReload".
'
'@@!!MEMBERTYPE_Methods_AfterListReloadEventArgsClass
'<GROUP AfterListReloadEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_AfterListReloadEventArgsClass
'<GROUP AfterListReloadEventArgsClass><TITLE ��������>
Class AfterListReloadEventArgsClass

	'@@AfterListReloadEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_AfterListReloadEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel

	'@@AfterListReloadEventArgsClass.HasMoreRows
	'<GROUP !!MEMBERTYPE_Properties_AfterListReloadEventArgsClass><TITLE HasMoreRows>
	':����������:	
	'	������� ���������� ����������� �� ������������ ���������� ����� � ������.
	'	�.�. ������ ������ �� ������ �����, ���� �� �� ����������� MaxRows.
	':��. �����:	AfterListReloadEventArgsClass.MaxRows
	':���������:	Public HasMoreRows [As Boolean]
	Public HasMoreRows

	'@@AfterListReloadEventArgsClass.MaxRows
	'<GROUP !!MEMBERTYPE_Properties_AfterListReloadEventArgsClass><TITLE MaxRows>
	':����������:	������������ ���������� ����� � ������.
	':��. �����:	AfterListReloadEventArgsClass.HasMoreRows
	':���������:	Public MaxRows [As Int]
	Public MaxRows

	'@@AfterListReloadEventArgsClass.Restrictions
	'<GROUP !!MEMBERTYPE_Properties_AfterListReloadEventArgsClass><TITLE Restrictions>
	':����������:	�����������, � �������� ���������� ������ �� ��������� ������.
	':���������:	Public Restrictions [As String]
	Public Restrictions
	
	'@@AfterListReloadEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_AfterListReloadEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As AfterListReloadEventArgsClass]
	Public Function Self()
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@SetDefaultFocusEventArgsClass
'<GROUP !!CLASSES_x-list><TITLE SetDefaultFocusEventArgsClass>
':����������:	��������� ������� "SetDefaultFocus".
'
'@@!!MEMBERTYPE_Methods_SetDefaultFocusEventArgsClass
'<GROUP SetDefaultFocusEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_SetDefaultFocusEventArgsClass
'<GROUP SetDefaultFocusEventArgsClass><TITLE ��������>
Class SetDefaultFocusEventArgsClass
	'@@SetDefaultFocusEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_SetDefaultFocusEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@SetDefaultFocusEventArgsClass.FilterObject
	'<GROUP !!MEMBERTYPE_Properties_SetDefaultFocusEventArgsClass><TITLE FilterObject>
	':����������:	C����� �� ������ �������.
	':���������:	Public FilterObject [As XFilterObjectClass]
	Public FilterObject
	
	'@@SetDefaultFocusEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SetDefaultFocusEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As SetDefaultFocusEventArgsClass]
	Public Function Self()
		Set Self = Me
	End Function
End Class


'==============================================================================
' ����������� ���������� ������� OnEdit
'	[in] oEventArg AS CommonEventArgsClass - ��������� �������
Sub stdXList_OnEdit(oXList, oEventArg)
	oEventArg.ObjectID = X_OpenObjectEditor(oEventArg.ObjectType, oEventArg.ObjectID, oEventArg.Metaname, oEventArg.Values.Item("URLPARAMS"))
	oEventArg.ReturnValue = Not IsEmpty(oEventArg.ObjectID)
End Sub


'==============================================================================
' ����������� ���������� ������� OnAfterEdit
'	[in] oEventArg AS CommonEventArgsClass - ��������� �������
Sub stdXList_OnAfterEdit(oXList, oEventArg)
	' ReturnValue ������� �� ������
	' ObjectID - ������������� �������
	With oEventArg
		If .ReturnValue Then
			oXList.ReloadEx True
			' ��������� ������ �� ����������������� ������
			oXList.SelectRowByObjectID .ObjectID
		End If
	End With
	oXList.SetListFocus
End Sub


'==============================================================================
' ����������� ���������� ������� OnCreate
'	[in] oEventArg AS CommonEventArgsClass - ��������� �������
Sub stdXList_OnCreate( oXList, oEventArg )
	oEventArg.ReturnValue = X_OpenObjectEditor(oEventArg.ObjectType, oEventArg.ObjectID, oEventArg.Metaname, oEventArg.Values.Item("URLPARAMS"))
End Sub


'==============================================================================
' ����������� ���������� ������� OnAfterCreate
'	[in] oEventArg AS CommonEventArgsClass - ��������� �������
Sub stdXList_OnAfterCreate( oXList, oEventArg )
	If Not IsEmpty(oEventArg.ReturnValue) Then
		oXList.Reload()
		' ��������� ������ �� ����������������� ������
		oXList.SelectRowByObjectID oEventArg.ReturnValue
	End If
	oXList.SetListFocus()
End Sub


'==============================================================================
' ����������� ���������� ������� OnBeforeDelete
'	[in] oEventArg AS DeleteObjectEventArgsClass - ��������� �������.
Sub stdXList_OnBeforeDelete( oXList, oEventArg )
	' �������� ������������� ��������� ������
	oEventArg.AddEventArgs = oXList.GetSelectedRowID()
End Sub


'==============================================================================
' ����������� ���������� ������� OnDelete (�������� ���������� �������)
'	[in] oEventArg AS DeleteObjectEventArgsClass - ��������� �������
' ������������ ��������:
'	false - ����� �� �������� (������� Cancel) 
'	true - ������ ������
Sub stdXList_OnDelete( oXList, oEventArg )
	Dim nButtonFlag		' ����� ��� MsgBox
	Dim nDeleteCount	' ���������� ��������� ��������
	
	oXList.ListView.Enabled = False
	oEventArg.ReturnValue = False
	nButtonFlag = iif(StrComp(oEventArg.Values.Item("DefaultButton"), "Yes")=0, vbDefaultButton1, vbDefaultButton2)
	If vbYes = MsgBox(oEventArg.Values.Item("Prompt"), vbYesNo + vbInformation + nButtonFlag, "�������� �������") Then
		' ������ ������
		nDeleteCount = X_DeleteObject( oEventArg.ObjectType, oEventArg.ObjectID )
		If X_HandleError Then
			' ���� ������
			oXList.ListView.object.Enabled = True
			oXList.SetListFocus()
			Exit Sub
		End If
		oEventArg.Count = nDeleteCount
		oEventArg.ReturnValue = True
		oXList.ListView.XClientService.DoEvents
		oXList.ListView.Enabled = True
	Else
		oXList.ListView.Enabled = True
		oXList.SetListFocus()
	End If
End Sub


'==============================================================================
' ����������� ���������� ������� OnAfterDelete
'	[in] oEventArg AS DeleteObjectEventArgsClass - ��������� �������
Sub stdXList_OnAfterDelete( oXList, oEventArg )
	Dim sRowID		' ������������� ������ ���������� �������
	Dim bRet		' ������� �� ������� ��������
	Dim oRow		' ������ IXListRow, ��������������� ��������� ������
	Dim nRowIndex	' ������ ��������� ������
	Dim nRowPos		' ������� ��������� ������
	Dim oRows		' As IXListRows
	Dim nCount		' ���������� �����, ����� ��������
	
	With oEventArg
		' ���� ������� � ������� �������, �� ������ ������ �� ������
		If .ReturnValue And .Count > 0 Then
			' ���� ������ ��� ������..
			sRowID = .AddEventArgs
			Set oRows = oXList.ListView.Rows
			' ������ �� ������ ��� ������, ��������������� ������� � ��������������� sGUID
			Do
				Set oRow = oRows.FindRowByID(sRowID)
				If oRow Is Nothing Then Exit Do
				nRowIndex = oRow.Index
				nRowPos = oRows.Idx2Pos(nRowIndex)
				oRows.Remove nRowIndex
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
				End If
			Loop While True
		End If
	End With
	oXList.SetListFocus()
End Sub


'==============================================================================
' ������������ ������� � ����� � ����. �������� ������ ����...
Sub stdXList_OnAccel(oXList, oAccelerationArgs)
	' ������� ������� ���������� � ���� ������ - ����� ��� ��� ��� ���������� hotkey'�
	If oXList.Menu.Initialized Then
		oXList.Menu.ExecuteHotkey oXList, oAccelerationArgs
	End If
End Sub
