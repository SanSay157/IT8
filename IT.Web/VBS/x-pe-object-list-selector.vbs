Option Explicit

'==========================================================================
' ����� ��������� ��������� ������� � ���� read-only-������  � ���������� � ��������� �������
' ��� ��������� ������� �� ��������� � ��������, ��� ������ - ���������.
' �������:
'	LoadList	- �������� ������ (LoadListEventArgsClass), ���� ����������� ����������
'	Selected	- ����� ��������, ��������� ������� � �������� (SelectedEventArgsClass)
'	UnSelected	- ������ ��������� � ��������, �������� ������� �� �������� (SelectedEventArgsClass)
'   �������, ����������� � ������ �������� �� ������/������ � ���������� ����:
'	BeforeSelect
'	GetSelectorRestrictions
'	Select
'	ValidateSelection
'	BindSelectedData
'	AfterSelect
Class XPEObjectListSelectorClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private EVENTS						' As String		- ������ ������� ��������
	
	Private m_oRefreshButton			' As IHTMLElement - ������ �������� ���������� ����
	Private m_bUseCache					' As Boolean - ������� ������������� ���� ��� �������� ������ � ������� (�� ��������� �� ������������)
	Private m_sCacheSalt				' As String - ��������� �� VBS, ���� ������ �� ������������ ��� �������������� ���� ��� ������������ �������� ����
										'	������:
										'	cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;)" - ������ ���� ���������� ����������������� ��� ����� ����������
										'	cache-salt="clng(date())" - ������ ���� ���������� ����������������� ��� � �����
										'	cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;) &amp; &quot;-&quot; &amp; clng(date())" - ������ ���� ���������� ����������������� ��� � ����� ��� ��� ����� ����������
										'	cache-salt="MyVbsFunctionName()" - ���������� ���������� �������
	Private m_bHasMoreRows				' As Boolean - ������� ����, ��� � ������ �������� �� ������� ��� ��������� �������� MAXROWS
	Private m_sViewStateCacheFileName	' As String - ������������ ����� � �������������� ��������������
	Private m_sListSelectorMetaname
	Private m_sTreeSelectorMetaname
	Private m_bKeyUpEventProcessing		' As Boolean - ������� ��������� ActiveX-������� OnKeyUp ��� "����������" �����

		
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "LoadList,Selected,UnSelected,GetRestrictions," & _
			"BeforeSelect,GetSelectorRestrictions,Select,ValidateSelection,BindSelectedData,AfterSelect,Accel"
	End Sub


	'==========================================================================
	' IPropertyEdior: ������������� ��������� ��������
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim vMetaName		' ������� ������ ��� ���������� ListView
		Dim sXPath			' XPAth -������
		
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectListSelector"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEvent "LoadList", Me, "OnLoadList"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Select", Me, "OnSelect"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "BindSelectedData", Me, "OnBindSelectedData"
		
		' i:list-selector ��������� �� i:objects-list � ���� ������� �������� ��������
		' ���������� xpath ��� ������ objects-list'a � ��
		vMetaName = HtmlElement.getAttribute("ListMetaname")
		
		m_sListSelectorMetaname = HtmlElement.getAttribute("ListSelectorMetaname")
		m_sTreeSelectorMetaname = HtmlElement.getAttribute("TreeSelectorMetaname")
		
		' ���� ������� ������ �������� ������������ � ���� ��������� �����������: 
		Set m_oRefreshButton = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.GetAttribute("RefreshButtonID"), 0 ) 
		m_bUseCache = "" & HtmlElement.getAttribute("UseCache") = "1"
		m_sCacheSalt = "" & HtmlElement.getAttribute("CacheSalt")
		If m_bUseCache AND (Not hasValue(m_sCacheSalt)) Then
			m_sCacheSalt = "0"
		End If
		
		sXPath = "i:objects-list"
		If Not IsNull(vMetaName) Then
			sXPath = sXPath & "[@n='" & vMetaName & "']"
		End If
		ListView.CheckBoxes = True
		
		m_sViewStateCacheFileName = ObjectEditor.Signature() & "XOLS." + oXmlProperty.parentNode.tagName & "." & oXmlProperty.tagName 
		If Not m_oPropertyEditorBase.PropertyEditorMD Is Nothing Then _
			m_sViewStateCacheFileName = m_sViewStateCacheFileName & "." & m_oPropertyEditorBase.PropertyEditorMD.getAttribute("n")
		InitXListViewInterface HtmlElement, X_GetTypeMD(ValueObjectTypeName).selectSingleNode(sXPath), m_sViewStateCacheFileName, False
		ViewInitialize
	End Sub

	
	'==========================================================================
	' ��������� ������������ �������� ������ ��������, 
	' � ������������ � �������� ���� ����������� ������������� �������.
	Private Sub ViewInitialize( )
		' ��������� ������������� ������ �������� 
		' (�������� � HTML, ���� ������������ use-cache � ��� off-reload)
		If Not m_oRefreshButton Is Nothing Then 
			' ������������ �������� ������ �������� ����������� �� ��������� � ��������
			' ���� ����������� ������������� �������: �������� ������ �� �����. HTML-�������
			With RefreshButton 
				.style.height = ExtraHtmlElement("Deselect").offsetHeight
				.style.width = .style.height
				.style.lineHeight = (.offsetHeight \ 2) & "px"
			End With
		End If
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: ����� ���������� ��� ���������� �������� ���������, ����� ������������� ���� PE �� ��������
	Public Sub FillData()
		LoadInternal iif(UseCache, CACHE_BEHAVIOR_USE, CACHE_BEHAVIOR_NOT_USE)
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
	' ��������� ������ � �������, ������������� ���, ���� ������� ����� �����������
	Public Sub ReLoad()
		Dim oData				' �������������� ������
		Dim oRestrictions		' As GetRestrictionsEventArgsClass
		Dim sRestrictions		' URL ����������� ���������� ������. ��� �� ���� ��������� � ������������ ����� � ����
		Dim sFilePefix			' ������� ����� �����
		Dim sDataName			' ��� ����� � �������

		' �������� ���������� ����, �.�. ����� ���������� ������, � SetData �� ����� ������� ������� �� ��������, 
		' ���� �� �� �������� � ��������� � ������� ������. � ������� � �������� ������ �� ��� � ����, �������
		' �������� � ����� �������� ���� (����� ��� ����������� �� � X_LoadXListViewUseCache)
		If UseCache Then 
			ClearCache False
		End If
		' �� ���������� LoadInternal ��� ����, ����� �� �������� ��� ���� ����������� ����� ������� "GetRestrictions"
		' ������� ������� �����������
		Set oRestrictions = New GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oRestrictions
		With New LoadListEventArgsClass
			.TypeName = ValueObjectTypeName
			.ListMetaname = HtmlElement.GetAttribute("ListMetaname")
			.RequiredValues = ValueID
			.Cache = CACHE_BEHAVIOR_NOT_USE
			.CacheSalt = CacheSalt
			Set .Restrictions = oRestrictions
			FireEvent "LoadList", .Self()
			m_bHasMoreRows = .HasMoreRows
			' ��������� ��������� ������ � ������������ � ����������� ��������
			SetData
			If UseCache Then
				' ���������� URL �� �����������
				sRestrictions = X_CreateListLoaderRestrictions(oRestrictions.ReturnValue, oRestrictions.UrlParams, .RequiredValues)
				' ���������� ������������ ����� � �����
				sFilePefix = X_GetListCacheFileNameCommonPart(.TypeName, .ListMetaname, sRestrictions)
				sDataName =  sFilePefix & Eval(CacheSalt)
				' ������������ ����� ���
				Set oData = XService.XmlGetDocument()
				Set oData = oData.appendChild( oData.CreateElement("root") )
				With oData.AppendChild( oData.ownerDocument.createElement("entry") )
					.SetAttribute "restr", sRestrictions
					.AppendChild HtmlElement.xml
				End With
				' ��������� �������� ������� � ���������� ����
				X_SaveDataCache sDataName, oData
			End If
		End With
	End Sub


	'==========================================================================
	' ��������� ������
	' [in] nCacheBehavior - ����� ������������� ���� (��������� CACHE_BEHAVIOR_*)
	Private Sub LoadInternal(nCacheBehavior)
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass
		
		Set oSelectorRestrictions = new GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions

		With New LoadListEventArgsClass
			.TypeName = ValueObjectTypeName
			.ListMetaname = HtmlElement.GetAttribute("ListMetaname")
			.RequiredValues = ValueID
			.Cache = nCacheBehavior
			.CacheSalt = CacheSalt
			Set .Restrictions = oSelectorRestrictions
			FireEvent "LoadList", .Self()
			m_bHasMoreRows = .HasMoreRows
		End With
	End Sub


	'==========================================================================
	' ������� ��� 
	' [in] bOnlyForCurrentRestrictions - ������� ������� �� ���� ��� ������
	'		� ������ ��� ��� ������� �����������, 
	'		���������� � ���������� ���������� ����������� ������� GetRestrictions
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
		X_ClearListDataCache ValueObjectTypeName, HtmlElement.GetAttribute("ListMetaname"), vRestrictions
	End Sub


	'==========================================================================
	' ����������� ���������� ������� "LoadList"
	' [in] oEventArgs As LoadListEventArgsClass
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
			' �������� ������ (����������� � ������ ���������� �������� � X_LoadXListViewUseCache)
			On Error Resume Next
			ListView.LockEvents = True
			' ����������
			.HasMoreRows = X_LoadXListViewUseCache( .Cache, HtmlElement, .TypeName, .ListMetaname, sRestrictions, sUrlParams, .RequiredValues, .CacheSalt )
			If Err Then
				X_SetLastServerError XService.LastServerError, Err.number, Err.Source, Err.Description
				With X_GetLastError
					If .IsServerError Then
						On Error Goto 0
						' �� ������� ��������� ������
						If .IsSecurityException Then
							' ��������� ������ ��� ������ ��������
							ClearComboBox
							m_oEditorPage.EnablePropertyEditor Me, False
						End If
						.Show
					Else
						' ������ ��������� �� ������� - ��� ������ � XFW
						aErr = Array(Err.Number, Err.Source, Err.Description)
						On Error Goto 0
						Err.Raise aErr(0), aErr(1), aErr(2)				
					End If
				End With
			End If
		End With
		UpdateXListViewColumnsFromCache HtmlElement, m_sViewStateCacheFileName
		HtmlElement.LockEvents = False
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property


	'==========================================================================
	' IPropertyEdior: ������������� �������� � ������
	Public Sub SetData
		Dim i
		Dim oRow					' IXListRow - ������ ������
		Dim oXmlObject
		Dim oXmlProperty
		Dim sObjectID
		Dim bFound
		
		ListView.LockEvents = True
		Set oXmlObject = Value
		If oXmlObject Is Nothing Then
			' �������� �� ����������� - ������ ��� ��������
			HtmlElement.Rows.UnCheckAll
		Else
			bFound = False
			For i=0 To HtmlElement.Rows.Count-1
				Set oRow = HtmlElement.Rows.GetRow(i)
				If oRow.ID = oXmlObject.getAttribute("oid") Then
					oRow.Checked = True
					bFound = True
				Else
					oRow.Checked = False
				End If
			Next
			If Not bFound Then
				' � ������ ��� ������, ��������������� �������� �������
				If m_bHasMoreRows Then
					' ���� �������� �� ��� ������, ������� ����������� ��������
					ParentPage.EnablePropertyEditor Me, False
					MsgBox "��������! �������� ��������� """ & PropertyDescription & """ �� ����� ���� ���������� ���������, " & vbCr & _
						"�.�. ���������� ������ �������� � ������� ��� ��������� �������� �� ������������ ���������� �����.", vbExclamation
					Exit Sub
				Else
					' ������ ������
					m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.selectSingleNode("*[@oid='" & sObjectID &"']")
				End If
			End If
		End If
		
		ListView.LockEvents = False
	End Sub


	'==========================================================================
	' IPropertyEdior: ���� ������
	Public Sub GetData(oGetDataArgs)
		' �������� �������
		X_SaveViewStateCache m_sViewStateCacheFileName, HtmlElement.Columns.Xml
		' �� ������ �������� - �������� �� ������������ NULL'a
		ValueCheckOnNullForPropertyEditor ValueID, m_oPropertyEditorBase, oGetDataArgs, Mandatory
	End Sub


	'==========================================================================
	' IPropertyEdior: 
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
	' IPropertyEdior: ���������/��������� (��)����������� ��������
	Public Property Get Enabled
		Enabled = HtmlElement.object.Enabled 
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.object.Enabled = bEnabled
		' �� ������� ��� ������ �������� ���������� ����:
		If Not IsNothing(RefreshButton) Then RefreshButton.disabled = Not( bEnabled )
		ExtraHtmlElement("Deselect").disabled = Not( bEnabled )
		If Not IsNothing(ExtraHtmlElement("Select")) Then ExtraHtmlElement("Select").disabled = Not (bEnabled)
	End Property


	'==========================================================================
	' IPropertyEdior: ��������� ������
	Public Function SetFocus
		' �����! ��� window.focus ����� ������ �� ���������������
		window.focus	
		SetFocus = X_SafeFocus( HtmlElement )
		window.focus	
	End Function


	'==========================================================================
	' IPropertyEdior: ���������� IHTMLObjectElement
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property


	'==========================================================================
	' ���������� �������������� ������� IHTMLElement
	Private Function ExtraHtmlElement(sName)
		Set ExtraHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.id & sName)
	End Function

	
	'==========================================================================
	' ���������� XListView
	Public Property Get ListView
		Set ListView = m_oPropertyEditorBase.HtmlElement.object
	End Property

	
	'==========================================================================
	' ���������� HTML-������� ������ ���������� ������
	Public Property Get RefreshButton
		Set RefreshButton = m_oRefreshButton
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
	' ���������� xml-�������-�������� xml-��������
	'	[retval] IXMLDOMNodeList �������� � ����, �� ������� ����������� ������ � ��������, ���� Nothing, ���� ��-�� ������
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
	' ���������� �������������� ��������-�������� xml-��������
	Public Property Get ValueID
		Dim oXmlProperty
		Set oXmlProperty = XmlProperty
		ValueID = Null
		If Not oXmlProperty.FirstChild Is Nothing Then
			ValueID = oXmlProperty.FirstChild.getAttribute("oid")
		End If
	End Property
	
	
	'==========================================================================
	' ���������� ������������ ���� ������� �������� ��������
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyEditorBase.ValueObjectTypeName
	End Property
	
	
	'==========================================================================
	' ���������� ActiveX ������� OnChechChange, ������������� � xslt-�������.
	' ��� ����������� �������������
	' ����������: ���������� ������ ���������� ���������, 
	' �.�. ���������� �������� ���� ����� ��������� �������� ��������, ������� �������� ��� ������������!
	Public Sub Internal_OnCheckChange( nRow, sRowID, bPrevState, bNewState )
		Dim oXmlProperty	' As IXMLDOMElement - xml-��������
		Dim oOldValue
		Dim oRow
		
		Set oXmlProperty = XmlProperty
		With New SelectedEventArgsClass
			.RowIndex = nRow
			If bPrevState And Not bNewState Then
				' ����������� ������ - ������� ������� �� ���� �� ��������
				m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.selectSingleNode("*[@oid='" & sRowID &"']")
				.OldValue = sRowID
				FireEvent "UnSelected", .Self()
			ElseIf bNewState And Not bPrevState Then
				' �������� ������ - ������ ������� �������� ��-�� � ������� ����� ��������
				Set oOldValue = oXmlProperty.firstChild
				If Not oOldValue Is Nothing Then
					' ������ ������� �� ������, ��������������� ������� � ��������
					Set oRow = HtmlElement.Rows.GetRowByID( oOldValue.getAttribute("oid") )
					' ��� ������� ����������� �����, �� ������� ��� � ���������� if
					oRow.Checked = False
				End If
				m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, X_CreateObjectStub(ValueObjectTypeName, sRowID)
				.NewValue = sRowID
				FireEvent "Selected", .Self()
			End If
		End With
	End Sub


	'==========================================================================
	' ���������� �������� ����� �� ������
	Public Sub Internal_OnDblClick( nIndex, nColumn, sID )
		Dim oRow
		If Len("" & sID) > 0 Then
			Set oRow = HtmlElement.Rows.GetRowByID(sID)
			oRow.Checked = Not oRow.Checked
		End If
	End Sub
	
	'==========================================================================
	' ���������� ������ "����� ���������" 	
	Public Sub Deselect
		Dim i
		For i=0 To HtmlElement.Rows.Count-1
			If HtmlElement.Rows.GetRow(i).Checked = True Then
				HtmlElement.Rows.GetRow(i).Checked = False
			End If
		Next
	End Sub
	

	'==========================================================================
	' ���������� ������� ������ "�������"
	Public Sub Internal_OnSelectClick
		Dim oValues
		Set oValues = CreateObject("Scripting.Dictionary")
		oValues.item("ListSelectorMetaname") = m_sListSelectorMetaname
		oValues.item("TreeSelectorMetaname") = m_sTreeSelectorMetaname
		m_oPropertyEditorBase.DoSelectFromDb oValues
	End Sub

		
	'==========================================================================
	' ����������� ���������� ������� "Select"
	'	[in] oEventArgs As SelectEventArgsClass
	Public Sub OnSelect(oSender, oEventArgs)
		Dim sType					' As String		- ��� �������-��������
		Dim sParams					' As String		- ��������� ��� data-source (Param1=Value1&Param2=Value2)
		Dim sUrlArguments			' As String		- ��������� ���������
		Dim sExcludeNodes			' As String		- ������ ����������� ����� ��� ������ �� ������
		Dim vRet					' As String		- ��������� ������
		Dim oXmlProperty			' As XMLDOMElement	- xml-��������
		
		Set oXmlProperty = XmlProperty
		' �������� ��� �������-��������
		sType = m_oPropertyEditorBase.ValueObjectTypeName
		' ������� ���������������� ����������� ��� ��������� ����� ������� GetSelectorRestrictions 
		' (������� GetRestrictions ������������ ��� ���������� ��������� ������)
		With New GetRestrictionsEventArgsClass
			FireEvent "GetSelectorRestrictions", .Self()
			sParams = .ReturnValue
			' ��������� � �������� �� ���������� ������ ����
			sUrlArguments = oEventArgs.UrlArguments
			' � ������� ��������� � �������� �� ������������ ������� "GetSelectorRestrictions"
			If Len(.UrlParams) Then
				If Left(.UrlParams, 1) <> "&" And Len(sUrlArguments) Then sUrlArguments = sUrlArguments & "&"
				sUrlArguments = sUrlArguments & .UrlParams
			End If
			sExcludeNodes = .ExcludeNodes
		End With

		' �������� ������
		If oEventArgs.SelectorType="list" Then
			' ����� ������������ �� ������
			vRet = X_SelectFromList(oEventArgs.SelectorMetaname , sType, LM_SINGLE, sParams, sUrlArguments)
		Else
			' ������� ������ � ������� ��������� ��������
			With New SelectFromTreeDialogClass
				.Metaname = oEventArgs.SelectorMetaname
				.LoaderParams = sParams
				If hasValue(sUrlArguments) Then
					.UrlArguments.QueryString = sUrlArguments
				End If
				
				' ���� ������ ��������� ��� �� ����, �� �� ����� ��� ������� ���� � ����������� ������
				If Not hasValue(sExcludeNodes) And sType = oXmlProperty.parentNode.tagName Then
					sExcludeNodes = sType & "|" & oXmlProperty.parentNode.GetAttribute("oid")
				End If
				.ExcludeNodes = sExcludeNodes
				
				SelectFromTreeDialogClass_Show .Self
				
				If .ReturnValue Then
					vRet = .Selection.selectSingleNode("n").getAttribute("id")
				End If				
			End With
		End If
		oEventArgs.Selection = vRet
	End Sub

	
	'==========================================================================
	' ����������� ���������� ������� "BindSelectedData"
	' [in] oSender - ��������� XPEObjectListSelectorClass, �������� �������.
	' [in] oEventArgs - ��������� SelectEventArgsClass, ��������� �������.
	' ������ ���������� ���������� ������ �������� �������� ��������� ������
	' �� ���������� � ���������� ��������� ������� "OnSelect".
	' ����� ����������� ��������� ������������� �������
	Public Sub OnBindSelectedData(oSender, oEventArgs)
		Dim oXmlProperty		' xml-��������
		Dim sObjectID			' ������������� ���������� �������
		Dim oListData
		Dim oFields
		Dim oField
		Dim aRowData
		Dim oRow
		Dim i
		
		Set oXmlProperty = XmlProperty
		sObjectID = oEventArgs.Selection

		If HtmlElement.Rows.FindRowByID(sObjectID) Is Nothing Then
			' ���� ��������� ������� ��� ��� � ������
			Set oListData = X_GetListDataFromServer(ValueObjectTypeName, HtmlElement.GetAttribute("ListMetaname"), X_CreateListLoaderRestrictions(Empty, Empty, sObjectID))
			Set oRow = oListData.selectSingleNode("//RS/R")
			If Not oRow Is Nothing Then
				Set oFields = oRow.selectNodes("F")
				ReDim aRowData(oFields.length)
				i = 0
				For Each oField In oFields
					aRowData(i) = oField.nodeTypedValue
					i = i + 1
				Next
				
				' � ������ ������ ������� ������ � ������ � ��������� �� checkbox
				Set oRow = HtmlElement.Rows.Insert(-1, aRowData, sObjectID )
				oRow.IconURL = HtmlElement.XImageList.MakeIconUrl( ValueObjectTypeName, "", "")
				oRow.Checked = True
			End If
		Else
			MsgBox "��������� ������ ��� ��������� � ������", vbOkOnly + vbInformation 
		End If
	End Sub
	
	
	'==========================================================================
	' ����������/������������� ������� ����������� 
	' ��. i:list-selector/@use-cache
	Public Property Get UseCache
		UseCache = (m_bUseCache=True)
	End Property
	Public Property Let UseCache(vValue)
		m_bUseCache = (vValue=True)
	End Property


	'==========================================================================
	' ����������/������������� �������� �����������
	' ��. i:list-selector/@cache-salt
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
End Class
