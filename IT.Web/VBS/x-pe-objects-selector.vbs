Option Explicit

'==========================================================================
' ����� ��������� ��������� ������� � ���� read-only-������  � ����������.
' ��� ��������� ������� �� ��������� � ��������, ��� ������ - ���������.
' �������:
'	LoadList	- �������� ������ (LoadListEventArgsClass), ���� ����������� ����������
'	Selected	- ����� ��������, ��������� ������� � �������� (SelectedEventArgsClass)
'	UnSelected	- ������ ��������� � ��������, �������� ������� �� �������� (SelectedEventArgsClass)
Class XPEObjectsSelectorClass
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
	Private m_bOffIcons					' As Boolean - ������� ���������� ������ ������
	Private m_bKeyUpEventProcessing		' As Boolean - ������� ��������� ActiveX-������� OnKeyUp ��� �������������� ������������ �����
	
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "LoadList,Selected,UnSelected,GetRestrictions,Accel"
	End Sub


	'==========================================================================
	' IPropertyEdior: ������������� ��������� ��������
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim vMetaName		' ������� ������ ��� ���������� ListView
		Dim sXPath			' XPAth -������
		
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectsSelector"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEvent "LoadList", Me, "OnLoadList"
		
		' i:list-selector ��������� �� i:objects-list � ���� ������� �������� ��������
		' ���������� xpath ��� ������ objects-list'a � ��
		vMetaName = HtmlElement.GetAttribute("ListMetaname")
		
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
		m_sViewStateCacheFileName = ObjectEditor.Signature() & "XArrayProp." + oXmlProperty.parentNode.tagName & "." & oXmlProperty.tagName & "." & m_oPropertyEditorBase.PropertyEditorMD.getAttribute("n")
		InitXListViewInterface HtmlElement, X_GetTypeMD(ValueObjectTypeName).selectSingleNode(sXPath), m_sViewStateCacheFileName, False
		
		If Not IsNull( HtmlElement.getAttribute("off-rownumbers")) Then ListView.LineNumbers = False
		m_bOffIcons = Not IsNull(HtmlElement.getAttribute("off-icons"))
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
				.style.height = ExtraHtmlElement("SelectAll").offsetHeight
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
			If m_bOffIcons Then
				HtmlElement.ShowIcons = False
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
		Dim sVisibleObjectIDList	' As String - ������ ��������������� ����� �������, ������������ � ������
		Dim oXmlObject
		Dim oXmlProperty
		Dim sObjectID
		
		ListView.LockEvents = True
		For i=0 To HtmlElement.Rows.Count-1
			Set oRow = HtmlElement.Rows.GetRow(i)
			If XmlProperty.selectSingleNode("*[@oid='" & oRow.ID & "']") Is Nothing Then
				oRow.Checked = False
			Else
				oRow.Checked = True
				sVisibleObjectIDList = sVisibleObjectIDList & " " & oRow.ID
			End If
		Next
		' � ���� �� � �������� �������, ��� ������� ��� ��������������� ������ � ������?
		Set oXmlProperty = XmlProperty
		For Each oXmlObject In oXmlProperty.selectNodes("*")
			sObjectID = oXmlObject.getAttribute("oid")
			If 0=InStr( sVisibleObjectIDList, sObjectID ) Then
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
		Next
		ListView.LockEvents = False
	End Sub


	'==========================================================================
	' IPropertyEdior: ���� ������
	Public Sub GetData(oGetDataArgs)
		' �������� �������
		X_SaveViewStateCache m_sViewStateCacheFileName, HtmlElement.Columns.Xml
	End Sub


	'==========================================================================
	' IPropertyEdior: 
	Public Property Get Mandatory
		Mandatory = False
	End Property
	Public Property Let Mandatory(bMandatory)
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
		ExtraHtmlElement("SelectAll").disabled = Not( bEnabled )
		ExtraHtmlElement("InvertSelection").disabled = Not( bEnabled )
		ExtraHtmlElement("DeselectAll").disabled = Not( bEnabled )
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
	' ���������� ������������ ���� ������� �������� ��������
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyEditorBase.ValueObjectTypeName
	End Property
	
	
	'==========================================================================
	' ���������� ActiveX ������� OnChechChange, ������������� � xslt-�������.
	' ��� ����������� �������������
	Public Sub Internal_OnCheckChange( nRow, sRowID, bPrevState, bNewState )
		Dim i
		Dim oRowBefore		' xml-�������� ������� � ��������, ��������������� ��������� ���������� ������ � ������
		Dim oXmlProperty	' As IXMLDOMElement - xml-��������

		Set oXmlProperty = XmlProperty
		With New SelectedEventArgsClass
			.RowIndex = nRow
			If bPrevState And Not bNewState Then
				' ����������� ������ - ������� ������� �� ���� �� ��������
				m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.selectSingleNode("*[@oid='" & sRowID &"']")
				.OldValue = sRowID
				FireEvent "UnSelected", .Self()
			ElseIf bNewState And Not bPrevState Then
				' �������� ������ - ������� ������ �� ���� � ��������
				' ���� �������� �������������, �� ������� �������� � ������ �������, ����� ������ � �����
				If m_oPropertyEditorBase.PropertyMD.getAttribute("cp") = "array" Then
					For i=nRow+1 To HtmlElement.Rows.Count-1
						If HtmlElement.Rows.GetRow(i).Checked Then
							Set oRowBefore = oXmlProperty.selectSingleNode("*[@oid='" & HtmlElement.Rows.GetRow(i).ID & "']")
							Exit For
						End If
					Next
					m_oPropertyEditorBase.ObjectEditor.Pool.AddRelationWithOrder Nothing, oXmlProperty, X_CreateObjectStub(ValueObjectTypeName, sRowID), oRowBefore
				Else
					m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, X_CreateObjectStub(ValueObjectTypeName, sRowID)
				End If
				.NewValue = sRowID
				FireEvent "Selected", .Self()
			End If
		End With
	End Sub


	'==========================================================================
	' ���������� ������ "������� ���"
	Public Sub SelectAll
		Dim i
		For i=0 To HtmlElement.Rows.Count-1
			If HtmlElement.Rows.GetRow(i).Checked = False Then
				HtmlElement.Rows.GetRow(i).Checked = True
			End If
		Next
	End Sub
	

	'==========================================================================
	' ���������� ������ "����� ���������" 	
	Public Sub DeselectAll
		Dim i
		For i=0 To HtmlElement.Rows.Count-1
			If HtmlElement.Rows.GetRow(i).Checked = True Then
				HtmlElement.Rows.GetRow(i).Checked = False
			End If
		Next
	End Sub
	
	
	'==========================================================================
	' ���������� ������ "�������� ���������"
	Public Sub InvertSelection
		Dim i
		For i=0 To HtmlElement.Rows.Count-1
			HtmlElement.Rows.GetRow(i).Checked = Not HtmlElement.Rows.GetRow(i).Checked
		Next
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


'==============================================================================
' ��������������� �� ���� �������
'	[in] oListView As XListView - ������
'	[in] sCacheKey As String - ���� � ��������������� �������� ������� �� ���������� ����������
Sub UpdateXListViewColumnsFromCache(oListView, sCacheKey)
	Dim oColumnsFromCache 	' �������������� xml-�������� �������
	Dim oColumns			' ������� xml-�������� �������
	Dim oColumnXml			' ���� C xml-�������� �������
	Dim oColumn				' CROC.IXListColumn
	Dim nWidth				' ������ �������
	Dim vOrder				' ���������� ������� (�������� �������� order)
	
	' ��������� ������������ ������ � ��������
	If HasValue(sCacheKey) Then
		If X_GetViewStateCache( sCacheKey, oColumnsFromCache) Then
			If Not IsObject(oColumnsFromCache) Then Exit Sub
			Set oColumns = oListView.Columns.Xml
			For Each oColumnXml In oColumnsFromCache.SelectNodes("C")
				Set oColumn = oListView.Columns.GetColumnByName(oColumnXml.getAttribute("name"))
				If Not oColumn Is Nothing Then
					' ������� �� ���� ������������ � ������
					' ����������� ������
					nWidth = oColumnXml.getAttribute("width")

					If Not IsNull(nWidth) Then
						nWidth = CLng("0" & nWidth)
					Else
						nWidth = 0
					End If
					
					If nWidth > 0 Then
						oColumn.Width = nWidth
					Else
						oColumn.Hidden = True
					End If
					' ����������� ����������
					vOrder = oColumnXml.getAttribute("order")
					If Not IsNull(vOrder) Then
						If vOrder = "asc" Then
							oColumn.Order = CORDER_ASC
						ElseIf vOrder = "desc" Then
							oColumn.Order = CORDER_DESC
						End If
					End If
				End If
			Next
		End If
	End If
End Sub


'==============================================================================
' ��������� ������� "Selected", "UnSelected"
Class SelectedEventArgsClass
	Public Cancel			' ������� ������ ��� ������� ������������. 
	Public OldValue			' ������ ��������, ���� ������, ������ ������ ����������� (����� �������)
	Public NewValue			' ����� ��������, ���� ������, ������ ������ �������� (���������� �������)
	Public RowIndex			' ������ ������ �������, ��� ������� ��������� ��������
	Public Function Self
		Set Self = Me
	End Function
End Class
