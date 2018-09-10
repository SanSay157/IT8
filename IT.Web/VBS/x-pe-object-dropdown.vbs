'===============================================================================
'@@!!FILE_x-pe-object-dropdown
'<GROUP !!SYMREF_VBS>
'<TITLE x-pe-object-dropdown - ���������� ������������ ���� ����� ���� "���������� ������" ��� ��������� �������>
':����������:	����������� ���������� ������������ UI-������������� ����������
'               ���������� �������� � ���� ����������� ������.
'===============================================================================
'@@!!CLASSES_x-pe-object-dropdown
'<GROUP !!FILE_x-pe-object-dropdown><TITLE ������>

Option Explicit

'===============================================================================
'@@XPEObjectDropdownClass
'<GROUP !!CLASSES_x-pe-object-dropdown><TITLE XPEObjectDropdownClass>
':����������:	����� ������������ UI-������������� ����������
'               ���������� �������� � ���� ����������� ������. 
':����������:   �������� �������, ������������ �������, �������� � ������
'               "<LINK points_wc1_02-3-41, ������� />".
'@@!!MEMBERTYPE_Methods_XPEObjectDropdownClass
'<GROUP XPEObjectDropdownClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_XPEObjectDropdownClass
'<GROUP XPEObjectDropdownClass><TITLE ��������>
Class XPEObjectDropdownClass
' �������:
'	GetRestrictions (EventArgs: GetRestrictionsEventArgsClass)
'		��������� ��� ���������� ������ ������� � �������
'	LoadList (EventArgs: LoadListEventArgsClass)
'		��������� ��� ���������� ������ ������� � �������
'	BeforeSetData (EventArgs: BeforeSetDataEventArgsClass)
'		��������� ��� ��������� �������� (� SetData)
'	SetDataError (EventArgs: ChangeEventArgsClass)
'		��������� ��� ������������� ���������� � ���������� �������� ��������, ���� ������ ��������
'	Changing (EventArgs: ChangeEventArgsClass)
'		��������� � �������� ��������� ��������
'	Changed (EventArgs: ChangeEventArgsClass)
'		��������� ����� ��������� ��������
'	Accel (EventArgs: AccelerationEventArgsClass)
'		������� ���������� ������

	Private m_bIsInitialized	' As Boolean - ������� ���������� ������������ ��������� ��������
	Private m_oEditorPage		' As EditorPageClass
	Private m_oObjectEditor		' As ObjectEditorClass
	Private m_oHtmlElement		' As IHtmlElement	- ������ �� ������� Html-�������
	Private m_oPropertyMD		' As XMLDOMElement	- ���������� xml-��������
	Private m_bIsActiveX		' As Boolean		- ������� ActiveX-����������
	Private m_oEventEngine		' As EventEngineClass
	Private m_vPrevValue		' As Variant		- ���������� �������� ����������
	Private EVENTS				' As String - ������ ������� ��������
	Private m_sXmlPropertyXPath	' As String - XPAth - ������ ��� ��������� �������� � Pool'e
	Private m_sObjectType		' As String - ������������ ���� ������� ��������� ��������
	Private m_sObjectID			' As String - ������������� ������� ��������� ��������
	Private m_sPropertyName		' As String - ������������ ��������
	Private m_bNoEmptyValue		' As Boolean - ������� ���������� ������� ��������
	Private m_sDropdownText		' As String - ����� ������� ��������
	Private m_sListMetaname		' As String - ���������������� ������ ��� ���������� ����������
	Private m_sPropertyDescription	' As String - �������� ��������
	Private m_oRefreshButton	' As IHTMLElement - ������ �������� ���������� ����
	Private m_bUseCache			' As Boolean - ������� ������������� ���� ��� �������� ������ 
								'	� ������� (�� ��������� �� ������������)
	Private m_sCacheSalt		' As String - ��������� �� VBS, ���� ������ �� ������������ ��� 
								'	�������������� ���� ��� ������������ �������� ����
	Private m_bHasMoreRows		' As Boolean - ������� ����, ��� � ������ �������� �� ������� ��� 
								'	��������� �������� MAXROWS
	Private m_bKeyUpEventProcessing		' As Boolean - ������� ��������� ActiveX-������� OnKeyUp ��� "����������" �����
	
	Private m_oRestrictions		' As XMLDOMNodeList - �������� i:restriction, ����������� �����������
	Private m_arrDependDropds		' As XMLDOMElement - ��������� �������, � ������� � ����������
								' ������ ����������� i:restriction, ����������� ������ �������� � prop-name


	'==========================================================================
	' �����������
	Private Sub Class_Initialize
		Set m_oEventEngine = X_CreateEventEngine
		EVENTS = "GetRestrictions,LoadList,BeforeSetData,SetDataError,Changing,Changed,Accel"
		m_vPrevValue = Null
		m_bIsInitialized = False
	End Sub


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE ObjectEditor>
	':����������:	
	'	��������� ObjectEditorClass - ��������, � ������ �������� ��������
	'   ������ �������� ��������. 
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get ObjectEditor [As ObjectEditorClass]
	Public Property Get ObjectEditor
		Set ObjectEditor = m_oObjectEditor
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ParentPage
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE ParentPage>
	':����������:	
	'	��������� EditorPageClass - �������� ���������, �� ������� �����������
	'   ������ �������� ��������. 
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get ParentPage [As EditorPageClass]
	Public Property Get ParentPage
		Set ParentPage = m_oEditorPage
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.PropertyMD
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE PropertyMD>
	':����������:	
	'	���������� �������� (���� <b>ds:prop</b>). 
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get PropertyMD [As IXMLDOMElement]
	Public Property Get PropertyMD
		Set PropertyMD = m_oPropertyMD
	End Property

	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.EventEngine
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE EventEngine>
	':����������:	
	'	��������� EventEngineClass - ������, �������������� ���������� ������
	'   ��� ������� ��������� ��������.
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get EventEngine [As EventEngineClass]
	Public Property Get EventEngine
		Set EventEngine = m_oEventEngine
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Init
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE Init>
	':����������:	
	'	������������� ��������� �������� (���������� ������ XPEObjectDropdownClass).
	':���������:
	'	oEditorPage - 
	'       [in] ��������� ������ EditorPageClass, �� ������� ���������� ��������
	'       ��������.
	'	oXmlProperty - 
	'       [in] ������������� XML-��������.
	'	oHtmlElement - 
	'       [in] ������� ������� ��������� ��������.
	':���������:
	'	Public Sub Init ( 
	'		oEditorPage [As EditorPageClass], 
	'		oXmlProperty [As IXMLDOMElement], 
	'		oHtmlElement [As IHTMLDOMElement]
	'	)
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
		Set m_oEditorPage	= oEditorPage
		Set m_oObjectEditor = m_oEditorPage.ObjectEditor
		m_sObjectType		= oXmlProperty.parentNode.tagName
		m_sObjectID			= oXmlProperty.parentNode.getAttribute("oid")
		m_sPropertyName		= oXmlProperty.tagName
		m_sXmlPropertyXPath	= m_sObjectType & "[@oid='" & m_sObjectID & "']/" & m_sPropertyName
		Set m_oPropertyMD	= m_oObjectEditor.PropMD(oXmlProperty )
		Set m_oHtmlElement  = oHtmlElement
		m_bIsActiveX = False
		If UCase(oHtmlElement.tagName) = "OBJECT" Then
			m_bIsActiveX = True
		End If
		
		' ��������� �����������, �������� �� ������ ����������:
		Dim oRestriction, sErr, sProp, sConst
		Set m_oRestrictions = m_oPropertyMD.selectNodes(".//i:restriction")
		If m_oRestrictions.length > 0 Then
			' �������� ��������������� ����������� ���������:
			For Each oRestriction In m_oRestrictions
				With oRestriction
					sProp = .getAttribute("prop-name")
					sConst = .getAttribute("const-value")
					If Not hasValue(.getAttribute("param-name")) Then
						sErr = "������������ ��������� (@param-name) ��� ��������� ������ �� ������!"
					ElseIf Not hasValue(sProp) And Not hasValue(sConst) Then
						sErr = "��� ����������� �������� - �� ��������-��������� (@prop-name), �� ������������ �������� (@const-value)!"
					ElseIf hasValue(sProp) And hasValue(sConst) Then
						sErr = "��� ����������� �������� - �� ��������-��������� (@prop-name), �� ������������ �������� (@const-value)!"
					ElseIf hasValue(sProp) And UCase("" & sProp) = UCase(m_sPropertyName) Then
						sErr = "� �������� ��������-��������� (@prop-name) ������� ������������� ��������!"
					End If
					If hasValue(sErr) Then
						Err.Raise -1, "XPEObjectDropdownClass::Init", _
						"��������� ����������� i:object-dropdown/i:restriction ��� �������� " & m_sPropertyName & " ���� " & m_sObjectType & ": " & sErr
					End If
				End With
			Next
		Else
			Set m_oRestrictions = Nothing
		End If
		
		' ����������� ������� ������������ �������:
		m_oEventEngine.InitHandlers EVENTS, "usr_" & oXmlProperty.parentNode.tagName & "_" & oXmlProperty.tagName & "_ObjectDropDown_On"
		m_oEventEngine.InitHandlers EVENTS, "usr_" & oXmlProperty.parentNode.tagName & "_" & oXmlProperty.tagName & "_On"
		m_oEventEngine.InitHandlers EVENTS, "usr_" & oXmlProperty.tagName & "_ObjectDropDown_On"
		m_oEventEngine.InitHandlers EVENTS, "usr_ObjectDropDown_On"
		m_oEventEngine.InitHandlers "GetRestrictions", "usr_PE_On"
		' ����������� ���������� GetRestrictions �������������� ������ ���� � ���������� ���� �����������:
		If hasValue(m_oRestrictions) Then
			m_oEventEngine.AddHandlerForEvent "GetRestrictions", Me, "OnGetRestrictions"
		End If
		m_oEventEngine.AddHandlerForEvent "LoadList", Me, "OnLoadList"
		
		' ���������� ��������, ��� ������� ���������� ����������� i:restriction, ���������� 
		' �� ��������, ������������� ������ PE - ���� ����� ����, �� �� ������ ����� 
		' ������������� ������������� ��� ��������� �������� � ������ PE:
		m_arrDependDropds = Null
		Dim oDrivenProps, nIndex
		Set oDrivenProps = X_GetTypeMD(m_oObjectEditor.ObjectType).selectNodes("ds:prop[.//i:object-dropdown/i:restriction/@prop-name='" & m_sPropertyName & "']")
		If oDrivenProps.length > 0 Then
			ReDim m_arrDependDropds(oDrivenProps.length-1)
			For nIndex = 0 To oDrivenProps.length-1
				Set m_arrDependDropds(nIndex) = m_oObjectEditor.GetProp( oDrivenProps.item(nIndex).getAttribute("n") )
			Next
			' ...����������� ����������� ��������� ��������:
			m_oEventEngine.AddHandlerForEvent "Changed", Me, "OnChangedReloadDependant"
		End If
		
		m_bNoEmptyValue = m_oHtmlElement.getAttribute("NoEmptyValue") = "1"
		m_sDropdownText = m_oHtmlElement.getAttribute("EmptyValueText") 
		m_sListMetaname = m_oHtmlElement.GetAttribute("X_LISTMETANAME")
		
		' ���� ������� ������ �������� ������������ � ���� ��������� �����������: 
		Set m_oRefreshButton = m_oEditorPage.HtmlDivElement.all( oHtmlElement.GetAttribute("RefreshButtonID"), 0 ) 
		m_bUseCache = "" & m_oHtmlElement.getAttribute("UseCache") = "1"
		m_sCacheSalt = m_oHtmlElement.getAttribute("CacheSalt")
		If m_bUseCache And (Not hasValue(m_sCacheSalt)) Then
			m_sCacheSalt = "0"
		End If
		
		If m_bIsActiveX Then
			' �������� ShowEmptySelection �� ������ � PropertyBag, ������� 
			' ������������� ��� �������� �����, � �� � XSL
			m_oHtmlElement.ShowEmptySelection = Not m_bNoEmptyValue 
		End If
		m_sPropertyDescription = m_oHtmlElement.GetAttribute("X_DESCR")
		ViewInitialize
	End Sub

	
	'==========================================================================
	' ��������� ������������ �������� ������ ��������, 
	' � ������������ � �������� ���� ����������� ������������� �������.
	Private Sub ViewInitialize( )
		' ��������� ������������� ������ �������� (�������� � HTML, ���� ������������
		' use-cache � ��� off-reload:
		If RefreshButton Is Nothing Then Exit Sub
		' ������������ �������� ������ �������� ����������� �� ��������� � ��������
		' ���� ����������� ������������� �������: �������� ������ �� �����. HTML-�������
		With RefreshButton 
			.style.height = HtmlElement.offsetHeight
			.style.width = .style.height
			.style.lineHeight = (.offsetHeight \ 2) & "px"
		End With
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.FillData
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE FillData>
	':����������:	
	'	��������� ��������� ������, ��������� ������� <b>GetRestrictions</b>. 
	'   ���������� ��� ���������� �������� ���������, �����
	'   ������������� ���� ���������� ������� �� ��������.
	':���������:
	'	Public Sub FillData ()
	Public Sub FillData()
		ReloadInternal False
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Load
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE Load>
	':����������:	
	'	��������� ��������� ������, ��������� ������� <b>GetRestrictions</b>.<P/> 
	'   ������� �������� XML-�������� ������������� � ������, ���� ��� ��� ����.
	'   ���� �������� �������� � ������ ���, �� �������� ��������� � ���������
	'   � ������ ������������ �� �������������� �������� (��. �������� ���������
	'   <LINK XPEObjectDropdownClass.SetData, SetData />).
	':���������:
	'	Public Sub Load ()
	Public Sub Load()
		ReloadInternal False
		SetData
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ReLoad
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE ReLoad>
	':����������:	
	'	��������� ��������� ������.<P/> 
	'   ������� �������� XML-�������� ������������� � ������, ���� ��� ��� ����.
	'   ���� �������� �������� � ������ ���, �� �������� ��������� � ���������
	'   � ������ ������������ �� �������������� �������� (��. �������� ���������
	'   <LINK XPEObjectDropdownClass.SetData, SetData />).
	':���������:
	'	Public Sub ReLoad ()
	Public Sub ReLoad()
		ReloadInternal True
		SetData
	End Sub

	
	'==========================================================================
	' ������������� ������, ��������� ������� "GetRestrictions". 
	'	[in] bOverwriteCache - ������� ������ �������������� ��������
	Private Sub ReloadInternal( bOverwriteCache )
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass - ��������� ������� "GetRestrictions"
		
		' �������� ����������� - ���������� ������� GetRestrictions
		Set oSelectorRestrictions = new GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions

		' ����������� ������ ������ - ���������� ������� LoadList
		With New LoadListEventArgsClass
			.TypeName = ValueObjectTypeName
			.ListMetaname = m_sListMetaname
			if Not UseCache then
				.Cache = CACHE_BEHAVIOR_NOT_USE
			elseif bOverwriteCache then
				.Cache = CACHE_BEHAVIOR_ONLY_WRITE
			else
				.Cache = CACHE_BEHAVIOR_USE
			end if
			.CacheSalt = CacheSalt
			Set .Restrictions = oSelectorRestrictions
			.RequiredValues = ValueID
			FireEvent "LoadList", .Self()
			m_bHasMoreRows = .HasMoreRows
		End With
	End Sub
	

	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ClearCache
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE ClearCache>
	':����������:	
	'	��������� ������� ���.
	':���������:
	'	bOnlyForCurrentRestrictions - 
	'       [in] ������� �������� ���� ��� ������� �����������, ���������� � ����������
	'       ���������� ����������� ������� <b>GetRestrictions</b>.
	':���������:
	'	Public Sub ClearCache ( 
	'		bOnlyForCurrentRestrictions [As Boolean]
	'	)
	Public Sub ClearCache(bOnlyForCurrentRestrictions)
		Dim oSelectorRestrictions	' �������� ������� GetRestrictions
		Dim vRestrictions			' ���������������� �����������
		
		If Not m_bUseCache Then Exit Sub
		
		vRestrictions = Null
		If bOnlyForCurrentRestrictions Then
			Set oSelectorRestrictions = new GetRestrictionsEventArgsClass
			FireEvent "GetRestrictions", oSelectorRestrictions
			vRestrictions = X_CreateCommonRestrictions(oSelectorRestrictions.ReturnValue,oSelectorRestrictions.UrlParams,ValueID)
		End If
		X_ClearListDataCache ValueObjectTypeName, m_sListMetaname, vRestrictions
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.OnGetRestrictions
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE OnGetRestrictions>
	':����������:	
	'	����������� ���������� ������� <b>GetRestrictions</b>.<P/>
	'   ����������� � ������ �������������� ����������� ����������� � ����������
	'	(�������� i:restriction ��� i:object-dropdown). ��������� ������ �����������
	'	�� ��������� �����������, �������� � ����������.
	':���������:
	'	oSender - 
	'       [in] ������, ��������������� �������.
	'	oEventArgs - 
	'       [in] ��������� �������.
	':���������:
	'	Public Sub OnGetRestrictions ( 
	'		oSender [As XPEObjectDropdownClass],
	'       oEventArgs [As LoadListEventArgsClass]
	'	)
	Public Sub OnGetRestrictions(oSender, oEventArgs)
		If Not hasValue(m_oRestrictions) Then Exit Sub
		
		Dim oQuery		' ����������� ������ �����������
		Dim oRestr		' ��������� i:restriction, �������� ����� �� ���� ������������ m_oRestrictions
		Dim sParam		' ������������ ��������� ��� ��������� ������
		Dim sValue		' �������� ����������� - ��������� / ������������ ��������
		Dim oProp		' ������������� ��������, ������������� ��������� �����������
		Dim oElement	' ������ (���������� ��������)
		Dim bUseIfNull	' ������� ������������� if-null
		
		Set oQuery = new QueryStringParamCollectionBuilderClass
		
		For Each oRestr In m_oRestrictions
			sParam = oRestr.getAttribute("param-name")
			sValue = oRestr.getAttribute("prop-name")
			If hasValue(sValue) Then
				bUseIfNull = True
				' ������ �������� ����������� ����� ���, ��� �������� ��������� ������:
				Set oProp = oSender.ObjectEditor.Pool.GetXmlProperty(oSender.ObjectEditor.XmlObject, sValue)
				If hasValue(oProp) Then
					If oSender.ObjectEditor.PropMD(oProp).getAttribute("vt") = "object" Then
						For Each oElement In oProp.selectNodes(".//@oid")
							oQuery.AppendParameter sParam, oElement.nodeTypedValue
							bUseIfNull = False
						Next
					Else
						sValue = "" & oProp.text
						If hasValue(sValue) Then 
							oQuery.AppendParameter sParam, sValue
							bUseIfNull = False
						End If
					End If
				End If
				If bUseIfNull Then 
					sValue = oRestr.getAttribute("if-null")
					If hasValue(sValue) Then oQuery.AppendParameter sParam, sValue
				End If
			Else
				sValue = oRestr.getAttribute("const-value")
				If hasValue(sValue) Then oQuery.AppendParameter sParam, sValue
			End If
		Next
		oEventArgs.ReturnValue = oQuery.QueryString
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.OnChangedReloadDependant
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE OnChangedReloadDependant>
	':����������:	
	'	����������� ���������� ������� <b>OnChanged</b>.<P/>
	'   ����������� � ������ �������������� ����������� ����������� � ����������
	'	(�������� i:restriction ��� i:object-dropdown); ��������� �������������� 
	'	���������� ���� object-dropdown, ��������� �� �������.
	':���������:
	'	oSender - 
	'       [in] ������, ��������������� �������.
	'	oEventArgs - 
	'       [in] ��������� �������.
	':���������:
	'	Public Sub OnChangedReloadDependant ( 
	'		oSender [As XPEObjectDropdownClass],
	'       oEventArgs [As LoadListEventArgsClass]
	'	)
	Sub OnChangedReloadDependant(oSender, oEventArgs)
		If Not hasValue(m_arrDependDropds) Then Exit Sub
		Dim oDependProp, oDependPEs, oDependPE
		For Each oDependProp In m_arrDependDropds
			If hasValue(oDependProp) Then oDependPEs = oSender.ParentPage.GetPropertyEditors( oDependProp )
			If hasValue(oDependPEs) Then 
				For Each oDependPE In oDependPEs
					If hasValue(oDependPE) And TypeName(oDependPE) = "XPEObjectDropdownClass" Then
						If hasValue(oDependPE.ValueID) Then oDependPE.ValueID = Null
						oDependPE.Load()
					End If
				Next
			End If
		Next
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.OnLoadList
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE OnLoadList>
	':����������:	
	'	����������� ���������� ������� <b>LoadList</b>.<P/>
	'   ������� � ����� ��������� ������. ���������� �������� ������� �� ��������������
	'   �������� (� �������� -1).
	':���������:
	'	oSender - 
	'       [in] ������, ��������������� �������.
	'	oEventArgs - 
	'       [in] ��������� �������.
	':���������:
	'	Public Sub OnLoadList ( 
	'		oSender [As XPEObjectDropdownClass],
	'       oEventArgs [As LoadListEventArgsClass]
	'	)
	Public Sub OnLoadList(oSender, oEventArgs)
		Dim sUrlParams			' ��������� � �������� ��������� ������
		Dim sRestrictions		' ��������� � ������ �� �������� ������������
		Dim aErr				' As Array - ���� ������� Err
		
		With oEventArgs
			' ������� �����������
			If Not IsNothing(.Restrictions) Then
				sUrlParams = .Restrictions.UrlParams
				sRestrictions =  .Restrictions.ReturnValue
			End If
			' ������� ������� ��������
			ClearComboBox
			' �������� ������ (����������� � ������ ���������� �������� � X_Load*ComboBox)
			On Error Resume Next
			If m_bIsActiveX Then
				' ���������� ���������
				.HasMoreRows = X_LoadActiveXComboBoxUseCache( .Cache, m_oHtmlElement, .TypeName, .ListMetaname, sRestrictions, sUrlParams, .RequiredValues, .CacheSalt )
			Else
				' ���������� ���������
				.HasMoreRows = X_LoadComboBoxUseCache( .Cache, m_oHtmlElement, .TypeName, .ListMetaname, sRestrictions, sUrlParams, .RequiredValues, .CacheSalt )
			End If
			If Err Then
				X_SetLastServerError XService.LastServerError, Err.number, Err.Source, Err.Description
				With X_GetLastError
					If .IsServerError Then
						On Error Goto 0
						' �� ������� ��������� ������
						If .IsSecurityException Then
							' ��������� ������ ��� ������ ��������
							ClearComboBox
							Enabled = False
						Else
							.Show
						End If
					Else
						' ������ ��������� �� ������� - ��� ������ � XFW
						aErr = Array(Err.Number, Err.Source, Err.Description)
						On Error Goto 0
						Err.Raise aErr(0), aErr(1), aErr(2)				
					End If
				End With
			End If
		End With
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.XmlProperty
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE XmlProperty>
	':����������:	
	'	������������� XML-��������.
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get XmlProperty [As IXMLDOMElement]
	Public Property Get XmlProperty
		Set XmlProperty = m_oObjectEditor.XmlObjectPool.selectSingleNode( m_sXmlPropertyXPath )
		If XmlProperty Is Nothing Then
			Set XmlProperty = m_oObjectEditor.Pool.GetXmlObject(m_sObjectType, m_sObjectID, Null).SelectSingleNode(m_sPropertyName)
		End If
		If XmlProperty Is Nothing Then _
			Err.Raise -1, "XPropertyEditorBaseClass::XmlProperty", "�� ������� �������� " & m_sPropertyName & " � xml-�������"
		If Not IsNull(XmlProperty.getAttribute("loaded")) Then
			Set XmlProperty = m_oObjectEditor.LoadXmlProperty( Nothing, XmlProperty)
		End If		
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Value
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE Value>
	':����������:	
	'	XML-������-�������e XML-��������. ���� ��������� ������ ������, ��
	'   ���������� Nothing.
	':����������:	
	'	��� ��������� �������� (Set) ������������� ����������� XML-������-�������e 
	'   XML-�������� � �������� ������ �����������, ��� ���������������.
	'   ���� �������� ��������������� � Nothing, �� �������� ���������.
	':���������:	
	'	Public Property Get Value [As IXMLDOMElement]
	'   Public Property Set Value(oObject [As IXMLDOMElement])
	Public Property Get Value
		Dim oXmlProperty		' As IXMLDOMElement - ������� ��������
		
		Set oXmlProperty = XmlProperty
		If oXmlProperty.FirstChild Is Nothing Then
			Set Value = Nothing
		Else	
			' �������� ������-��������
			Set Value = m_oObjectEditor.Pool.GetXmlObjectByXmlElement( oXmlProperty.FirstChild, Null )
		End If
	End Property
	
	Public Property Set Value(oObject)
		Dim vVal	' ObjectID ������ �������-��������
		
		' ����������� �������
		With New ChangeEventArgsClass
			.OldValue = m_vPrevValue
			vVal = getValueFromObject(oObject)
			.NewValue = vVal
			' ��������� �������� � ����������
			' ����.: SetData �� ��������, �.�. ��� ���������� ������������� ������
			If SetComboBoxValue(vVal) > -1 Or IsNull(vVal) Then
				' ������� ���������� ����� �������� � ���������� - ������� �������� � ��������
				doChangeValueObject oObject
				FireEvent "Changed", .Self()
			Else
				' �� ������� ���������� ����� �������� � ����������  -
				' ����������� �������, ���� ���� ����������, ����� ����������� runtime ������
				If EventEngine.IsHandlerExists("SetDataError") Then
					' ���������� ������� � ������� ���������� ChangeEventArgsClass
					' (�������� .OldValue, NewValue ����������� ��� ����)
					FireEvent "SetDataError", .Self()
				Else
					Err.Raise -1, "XPEObjectDropdownClass::set_Value", "�� ������� ���������� �������� � ���������� ������ ��� ����������� �������� Value"
				End If
			End If	
		End With
	End Property

	'==========================================================================
	' ��������� �������� �������� ��������
	' ����������: �������� �������� m_vPrevValue
	'	[in] oObject As IXMLDOMElement - xml-�������� ������-��������
	Private Sub doChangeValueObject(oObject)
		Dim oXmlProperty		' As IXMLDOMElement - ������� ��������
		
		Set oXmlProperty = XmlProperty
		' ������� ������� ��������
		' ����������: �������� �� ������� �������� ���� � RemoveRelation 
		m_oObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
		' ��������� �������� ��������
		If Not IsNothing(oObject) Then
			m_oObjectEditor.Pool.AddRelation Nothing, oXmlProperty, oObject
			m_vPrevValue = oObject.getAttribute("oid")
		Else
			m_vPrevValue = Null
		End If
	End Sub

	
	'==========================================================================
	' ��������� �������� �������� ��������
	'	[in] vSelectedValue - ������������� �������-��������
	Private Sub doChangeValue(vSelectedValue)
		If hasValue(vSelectedValue) Then
			doChangeValueObject X_CreateObjectStub(ValueObjectTypeName, vSelectedValue)
		Else
			doChangeValueObject Nothing
		End If
	End Sub
	
	'==========================================================================
	' ���������� ������������� �������-��������, ����������� ������ Nothing 
	' - � ���� ������ ���������� Null
	Private Function getValueFromObject(oObject)
		If Not IsNothing(oObject) Then
			getValueFromObject = oObject.getAttribute("oid")
		Else
			getValueFromObject = Null
		End If
	End Function
	

	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ValueID
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE ValueID>
	':����������:	
	'	������������� �������-�������� XML-��������. 
	':����������:	
	'	���� ������-�������� - ������, �� �������� ���������� Null. ��������������, 
	'   ��� ��������� �������� � Null �������� ���������� �������� ���������.
	':���������:	
	'	Public Property Get ValueID [As String]
	'   Public Property Let ValueID(sObjectID [As String])
	Public Property Get ValueID
		' ������� ID ������� - �������� ��������
		If XmlProperty.FirstChild Is Nothing Then
			ValueID = Null
		Else	
			' �������� ������-��������
			ValueID = XmlProperty.FirstChild.getAttribute("oid") 
		End If
	End Property
	
	Public Property Let ValueID(sObjectID)
		If Len("" & sObjectID) = 0 Then
			Set Value = Nothing
		Else
			Set Value = X_CreateObjectStub(ValueObjectTypeName, sObjectID)
		End If
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.FirstNonEmptyValueID
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE FirstNonEmptyValueID>
	':����������:	
	'	������ �������� ������������� �� ������ ���������. 
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get FirstNonEmptyValueID [As String]
	Public Property Get FirstNonEmptyValueID
		Dim sValue	' ��������
		Dim i
		
		If m_bIsActiveX Then
			For i=0 To m_oHtmlElement.Rows.Count-1
				sValue = m_oHtmlElement.Rows.GetRow(i).ID
				If HasValue(sValue) Then
					FirstNonEmptyValueID = sValue
					Exit Property
				End If
			Next
		Else
			For i=0 To m_oHtmlElement.Options.Length-1
				sValue = m_oHtmlElement.Options.Item(i).value
				If HasValue(sValue) Then
					FirstNonEmptyValueID = sValue
					Exit Property
				End If
			Next
		End If
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ValueObjectTypeName
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE ValueObjectTypeName>
	':����������:	
	'	������������ ���� �������-�������� ��������. 
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get ValueObjectTypeName [As String]
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyMD.GetAttribute("ot")
	End Property
		

	'==========================================================================
	' ���������� ������� �������� ComboBox'a. ���� ������� ������ ������, �� ������������ Null
	Private Property Get ComboboxValue
		Dim vValue
		If m_bIsActiveX Then
			vValue = m_oHtmlElement.Rows.SelectedID
		Else
			vValue = m_oHtmlElement.Value
		End If
		If Len(vValue)>0 Then
			ComboboxValue = vValue
		Else
			ComboboxValue = Null
		End If
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.AddComboBoxItem
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE AddComboBoxItem>
	':����������:	
	'	��������� ��������� ������� � ���������� ������.
	':���������:
	'	vVal - 
	'       [in] ��������, ��������������� ��������.
	'	sLabel - 
	'       [in] ����� ��������.
	':���������:
	'	Public Sub AddComboBoxItem ( 
	'		vVal [As Variant],
	'       sLabel [As String]
	'	)
	Public Sub AddComboBoxItem( vVal, sLabel)
		If m_bIsActiveX Then
			X_AddActiveXComboBoxItem m_oHtmlElement, vVal, sLabel
		Else
			X_AddComboBoxItem m_oHtmlElement, vVal, sLabel
		End If
	End Sub
	
	
	'==========================================================================
	' ������������� �������� ����� � �������� ���������. �������� ��� ���� �� ����������!
	' ������� �� ������������!
	'	[in]		vVal - ��������, ��������������� ��������
	'   [retval]	����� ������ ��������� ��� -1
	Private Function SetComboBoxValue(vVal)
		If m_bIsActiveX Then
			SetComboBoxValue = X_SetActiveXComboBoxValue( m_oHtmlElement, vVal )
		Else
			SetComboBoxValue = X_SetComboBoxValue( m_oHtmlElement, vVal )
			If SetComboBoxValue = -1 And Not m_bNoEmptyValue Then
				' ���� �� ������� ����� �������� � ����� ������ ������� ��������, ��������� ��� (�� ������ ���� ������)
				HtmlElement.SelectedIndex = 0
			End If
		End If
	End Function
	

	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.SetData
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE SetData>
	':����������:	
	'	��������� ������������� �������� � ���������� ������.
	':���������:
	'	Public Sub SetData 
	Public Sub SetData
		Dim vVal		' As String - �������� ��������
		
		vVal = ValueID
		If EventEngine.IsHandlerExists("BeforeSetData") Then
			With New BeforeSetDataEventArgsClass
				.CurrentValue = vVal 
				FireEvent "BeforeSetData", .Self()
				' ���� ���������� ���������� ������� ��������, �� ������� �������� � ����
				If .CurrentValue <> vVal Or hasValue(.CurrentValue) <> hasValue(vVal) Then
					vVal = .CurrentValue
					doChangeValue vVal
				End If
			End With
		End If
		
		If SetComboBoxValue(vVal) > -1 Or IsNull(vVal) Then
			m_vPrevValue = vVal
		Else
			' �� ������� ���������� �������� �������� � ����������..
			If Not ObjectEditor.SkipInitErrorAlerts Then
				If EventEngine.IsHandlerExists("SetDataError") Then
					With New ChangeEventArgsClass
						.OldValue = m_vPrevValue
						.NewValue = vVal
						FireEvent "SetDataError", .Self()
					End With
				Else			
					If m_bHasMoreRows Then
						m_oEditorPage.EnablePropertyEditor Me, False
						MsgBox _
							"��������! �������� ��������� """ & PropertyDescription & """ " & _
							"�� ����� ���� ���������� ���������, ��� ��� ���������� ������ " & _
							"�������� ��������� �������� �� ������������ ���������� �����.", _
							vbExclamation, "�������� - ���������� ���������� ������"
					Else
						' � ����������� ������ ��� �������� �������� - ������� ��������;
						' ��� ���� ����������� ������������ � ���, ��� ����� ��������� 
						' �������� "�������" �� ���������:
						MsgBox _
							"��������! ��������� ����� �������� ��������� """ & PropertyDescription & """ ����� �� ����������; ��������, ��� ����" & vbCrLf & _
							"������� ��� �������� ������ �������������. �������� �������� ����� ��������." & vbCrLf & _
							"����������, �������� ����� ��������.", _
							vbExclamation, "�������� - ��������� ������"
						ValueID = Null
					End If
				End If
			End If
		End if
		
		' ������ ����� SetData (�� ����, ��� ����� �� ��������� ��� �������������
		' ��������) ��������� ������� ������������� PE
		m_bIsInitialized = True
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.GetData
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE GetData>
	':����������:	
	'	��������� ������������ �������� � ���� ������.
	':���������:
	'	oGetDataArgs - 
	'       [in] ��������� ������ GetDataArgsClass.
	':���������:
	'	Public Sub GetData ( 
	'       oGetDataArgs [As GetDataArgsClass]
	'	)
	Public Sub GetData(oGetDataArgs)
		' �������� �� Not Null
		ValueCheckOnNullForPropertyEditor ValueID, Me, oGetDataArgs, Mandatory
		' ���� ������ ���������� ��������������� ��� ������ ��������
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Clear
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE Clear>
	':����������:	
	'	��������� ������� ���������� ������ � ���������� �������� �������� � Null.
	':���������:
	'	Public Sub Clear 
	Public Sub Clear
		ClearComboBox
		ValueID = Null
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ClearComboBox
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE ClearComboBox>
	':����������:	
	'	��������� ������� ��� �������� ����������� ������. �������� �������� ��� ���� 
	'   �� ��������! ��� �������������, ����������� ������ �������� (�������� � �������).
	':���������:
	'	Public Sub ClearComboBox 
	Public Sub ClearComboBox
		If m_bIsActiveX Then
			' ������ ������ ������
			' ��������: ���� ������� m_oHtmlElement.Clear, ��� ������-�� ����� ���������, 
			' �� ��� �������� � ������������ ���������� � ��� ��������� ������ ������
			m_oHtmlElement.Rows.RemoveAll
		Else
			' ������� ������� ��������
			If m_bNoEmptyValue Then
				' ������� �������� ���
				m_oHtmlElement.innerHTML = ""
			Else
				' ������ �������� ������ ����
				m_oHtmlElement.innerHTML = ""
				X_AddComboBoxItem m_oHtmlElement, Empty, m_sDropdownText
			End If
		End If
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Mandatory
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE Mandatory>
	':����������:	
	'	������� (��)�������������� ��������. 
	':���������:	
	'	Public Property Get Mandatory [As Boolean]
	'   Public Property Let Mandatory(bMandatory [As Boolean])
	Public Property Get Mandatory
		Mandatory = IsNull( m_oHtmlElement.GetAttribute("X_MAYBENULL"))
	End Property

	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			m_oHtmlElement.removeAttribute "X_MAYBENULL"
			m_oHtmlElement.className = "x-editor-control-notnull x-editor-dropdown"
		Else
			m_oHtmlElement.setAttribute "X_MAYBENULL", "YES"
			m_oHtmlElement.className = "x-editor-control x-editor-dropdown"
		End If			
	End Property
	

	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Enabled
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE Enabled>
	':����������:	
	'	������� (��)����������� ��������. 
	':���������:	
	'	Public Property Get Enabled [As Boolean]
	'   Public Property Let Enabled(bEnabled [As Boolean])
	Public Property Get Enabled
		If m_bIsActiveX Then
			 Enabled = m_oHtmlElement.object.Enabled
		Else
			 Enabled = Not (m_oHtmlElement.disabled)
		End If
	End Property

	Public Property Let Enabled(bEnabled)
		If m_bIsActiveX Then
			 m_oHtmlElement.object.Enabled = bEnabled
		Else
			 m_oHtmlElement.disabled = Not( bEnabled )
		End If
		' �� ������� ��� ������ �������� ���������� ����:
		If Not IsNothing(RefreshButton) Then RefreshButton.disabled = Not( bEnabled )
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.SetFocus
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE SetFocus>
	':����������:	
	'	��������� ������.
	':���������:
	'	Public Function SetFocus [As IHTMLElement]
	Public Function SetFocus
		SetFocus = X_SafeFocus( m_oHtmlElement )
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.HtmlElement
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE HtmlElement>
	':����������:	
	'	�������� HTML-������� ��������� ��������. 
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get HtmlElement [As IHTMLElement]
	Public Property Get HtmlElement
		Set HtmlElement = m_oHtmlElement
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.RefreshButton
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE RefreshButton>
	':����������:	
	'	HTML-������� ������ ���������� ������. 
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get RefreshButton [As IHTMLElement]
	Public Property Get RefreshButton
		Set RefreshButton = m_oRefreshButton
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.PropertyDescription
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE PropertyDescription>
	':����������:	
	'	�������� ��������. 
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get PropertyDescription [As IHTMLElement]
	Public Property Get PropertyDescription
		PropertyDescription = m_sPropertyDescription
	End Property	
	Public Property Let PropertyDescription(sValue)
		m_sPropertyDescription = sValue
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Dispose
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE Dispose>
	':����������:	
	'	������ ������ � ������� ���������.
	':���������:
	'	Public Sub Dispose
	Public Sub Dispose
		Set m_oObjectEditor = Nothing
		Set m_oEditorPage = Nothing
	End Sub	

	
	'==========================================================================
	' ���������� Html ������� OnChange. 
	' ��������: ��� ����������� �������������.
	Public Sub Internal_OnChange
		If m_bIsInitialized Then
			With New ChangeEventArgsClass
				.OldValue = m_vPrevValue
				.NewValue = ComboboxValue
				.ReturnValue = True
				FireEvent "Changing", .Self()
				If Not .ReturnValue Then
					' ���� � ����������� ��������� ����, �� ������ ���������� �������� � ������� ���������
					SetComboBoxValue m_vPrevValue
					Exit Sub
				End If
				doChangeValue ComboboxValue
				FireEvent "Changed", .Self()
			End With
		End if
	End Sub
	
	
	'==========================================================================
	' ���������� �������
	' [in] sEventName - ������������ �������
	' [in] oEventArgs - ��������� ������� EventArgsClass, �������
	' �������� ����������� ����� EventEngine, ��������� ��� � ��������
	' ��������� ������ �� ���� 
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub	
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Enabled
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE Enabled>
	':����������:	
	'	������� ���������� ������� ��������. 
	':���������:	
	'	Public Property Get NoEmptyValue [As Boolean]
	'   Public Property Let NoEmptyValue(vValue [As Boolean])
	Public Property Get NoEmptyValue
		NoEmptyValue = m_bNoEmptyValue
	End Property
	Public Property Let NoEmptyValue(vValue)
		m_bNoEmptyValue = vValue
	End Property

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.DropdownText
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE DropdownText>
	':����������:	
	'	����� ������� ��������. 
	':���������:	
	'	Public Property Get DropdownText [As String]
	'   Public Property Let DropdownText(vValue [As String])
	Public Property Get DropdownText
		DropdownText = m_sDropdownText
	End Property
	Public Property Let DropdownText(vValue)
		m_sDropdownText = vValue
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.UseCache
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE UseCache>
	':����������:	
	'	������� �����������. 
	':���������:	
	'	Public Property Get UseCache [As Boolean]
	'   Public Property Let UseCache(vValue [As Boolean])
	Public Property Get UseCache
		UseCache = (m_bUseCache=True)
	End Property
	Public Property Let UseCache(vValue)
		m_bUseCache = (vValue=True)
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.CacheSalt
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE CacheSalt>
	':����������:	
	'	�������� �����������. 
	':���������:	
	'	Public Property Get CacheSalt [As String]
	'   Public Property Let CacheSalt(vValue [As String])
	Public Property Get CacheSalt
		CacheSalt = m_sCacheSalt
	End Property
	Public Property Let CacheSalt(vValue)
		m_sCacheSalt = vValue
	End Property
	
	
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


	'==========================================================================
	' ���������� Html-������� OnKeyUp . ���������� ���������� �� ����-����.
	' ��������: ��� ����������� �������������.
	Public Sub Internal_OnKeyUpHtmlAsync(keyCode, altKey, ctrlKey, shiftKey)
		Dim oEventArgs		' As AccelerationEventArgsClass

		If m_bKeyUpEventProcessing Then Exit Sub
		m_bKeyUpEventProcessing = True
		Set oEventArgs = CreateAccelerationEventArgs(keyCode, altKey, ctrlKey, shiftKey)
		Set oEventArgs.Source = Me
		Set oEventArgs.HtmlSource = HtmlElement
		FireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' ���� ������� ���������� �� ���������� - ��������� �� � ��������
			ObjectEditor.OnKeyUp Me, oEventArgs
		End If
		m_bKeyUpEventProcessing = False
	End Sub
End Class


'===============================================================================
'@@BeforeSetDataEventArgsClass
'<GROUP !!CLASSES_x-pe-object-dropdown><TITLE BeforeSetDataEventArgsClass>
':����������:	����� ���������� ������� BeforeSetData ��������� �������� XPEObjectDropdownClass. 
'
'@@!!MEMBERTYPE_Methods_BeforeSetDataEventArgsClass
'<GROUP BeforeSetDataEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_BeforeSetDataEventArgsClass
'<GROUP BeforeSetDataEventArgsClass><TITLE ��������>
Class BeforeSetDataEventArgsClass
	'@@BeforeSetDataEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_BeforeSetDataEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel				
	
	'@@BeforeSetDataEventArgsClass.CurrentValue
	'<GROUP !!MEMBERTYPE_Properties_BeforeSetDataEventArgsClass><TITLE CurrentValue>
	':����������:	������� �������� ��������, ���� ���������� ������� ������ ��������, 
	'				�� PE ��������� ����� �������� � ���� � � ��������
	':���������:	Public CurrentValue [As String]
	Public CurrentValue
	
	'@@BeforeSetDataEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_BeforeSetDataEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As BeforeSetDataEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class
