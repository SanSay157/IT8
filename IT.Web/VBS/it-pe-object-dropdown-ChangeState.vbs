Option Explicit

'==============================================================================
'	OBJECT-DROPDOWN (���������) 
'==============================================================================
' �������:
'	GetRestrictions (EventArgs: GetRestrictionsEventArgsClass)
'		��������� ��� ���������� ������ ������� � �������
'	LoadList (EventArgs: LoadListEventArgsClass)
'		��������� ��� ���������� ������ ������� � �������
'	Changing (EventArgs: ChangeEventArgsClass)
'		��������� � �������� ��������� ��������
'	Changed (EventArgs: ChangeEventArgsClass)
'		��������� ����� ��������� ��������
Class PEObjectDropdownChangeStateClass
	Private m_bIsInitialized	' As Boolean - ������� ���������� ������������ ��������� ��������
	Private m_oEditorPage		' As EditorPageClass
	Private m_oObjectEditor		' As ObjectEditorClass
	Private m_oHtmlElement		' As IHtmlElement	- ������ �� ������� Html-�������
	Private m_oPropertyMD		' As XMLDOMElement	- ���������� xml-��������
	Private m_oEventEngine		' As EventEngineClass
	Private m_vPrevValue		' As Variant		- ���������� �������� ����������
	Private EVENTS				' As String - ������ ������� ��������
	Private m_sXmlPropertyXPath	' As String - XPAth - ������ ��� ��������� �������� � Pool'e
	Private m_sObjectType		' As String - ������������ ���� ������� ��������� ��������
	Private m_sObjectID			' As String - ������������� ������� ��������� ��������
	Private m_sPropertyName		' As String - ������������ ��������
	Private m_sDropdownText		' As String - ����� ������� ��������
	Private m_sListMetaname		' As String - ���������������� ������ ��� ���������� ����������
	
	Private m_bUseCache			' As Boolean - ������� ������������� ���� ��� �������� ������ 
								'	� ������� (�� ��������� �� ������������)
	Private m_sCacheSalt		' As String - ��������� �� VBS, ���� ������ �� ������������ ��� 
								'	�������������� ���� ��� ������������ �������� ����
	Private m_bHasMoreRows		' As Boolean - ������� ����, ��� � ������ �������� �� ������� ��� 
								'	��������� �������� MAXROWS
	Private m_oInitialValue		' ��������� ��������
	Private m_sInitialValueTitleStmt
	Private m_oInitialValueTitleElement	' HTML-������� � ��������� �������������� ���������� ��������
	
	'==========================================================================
	' �����������
	Private Sub Class_Initialize
		Set m_oEventEngine = X_CreateEventEngine
		EVENTS = "GetRestrictions,LoadList,Changing,Changed"
		m_vPrevValue = Null
		m_bIsInitialized = False
	End Sub
	

	'==========================================================================
	' ���������� ��������� ObjectEditorClass - ���������,
	' � ������ �������� �������� ������ �������� ��������
	Public Property Get ObjectEditor
		Set ObjectEditor = m_oObjectEditor
	End Property


	'==========================================================================
	' ���������� ��������� EditorPageClass - �������� ���������,
	' �� ������� ����������� ������ �������� ��������
	Public Property Get ParentPage
		Set ParentPage = m_oEditorPage
	End Property


	'==========================================================================
	' ������������� ��������� ��������.
	' ��. IPropertyEditor::Init
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Set m_oEditorPage	= oEditorPage
		Set m_oObjectEditor = m_oEditorPage.ObjectEditor
		m_sObjectType		= oXmlProperty.parentNode.tagName
		m_sObjectID			= oXmlProperty.parentNode.getAttribute("oid")
		m_sPropertyName		= oXmlProperty.tagName
		m_sXmlPropertyXPath	= m_sObjectType & "[@oid='" & m_sObjectID & "']/" & m_sPropertyName
		Set m_oPropertyMD	= m_oObjectEditor.PropMD(oXmlProperty)
		Set m_oHtmlElement  = oHtmlElement
		' oInitialValueTitleElement - ������������� �� XSLT
		'Set m_oInitialValueTitleElement = document.all.items("oInitialValueTitleElement")
		' ����������� ������� ������������ �������:
		m_oEventEngine.InitHandlers EVENTS, "usr_" & oXmlProperty.parentNode.tagName & "_" & oXmlProperty.tagName & "_ObjectDropDown_On"
		m_oEventEngine.InitHandlers EVENTS, "usr_" & oXmlProperty.parentNode.tagName & "_" & oXmlProperty.tagName & "_On"
		m_oEventEngine.InitHandlers EVENTS, "usr_" & oXmlProperty.tagName & "_ObjectDropDown_On"
		m_oEventEngine.InitHandlers EVENTS, "usr_ObjectDropDown_On"
		m_oEventEngine.InitHandlers "GetRestriction", "usr_PE_On"
		m_oEventEngine.AddHandlerForEvent "LoadList", Me, "OnLoadList"
		m_sDropdownText = m_oHtmlElement.getAttribute("EmptyValueText")
		m_sListMetaname = m_oHtmlElement.getAttribute("ListMetaname")
		m_sInitialValueTitleStmt = m_oHtmlElement.getAttribute("InitialValueTitleStmt")

		Set m_oInitialValue = Value
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: ����� ���������� ��� ���������� �������� ���������, ����� 
	'	������������� ���� PE �� ��������
	Public Sub FillData()
		ReloadInternal
	End Sub

	
	'==========================================================================
	' ��������� ������, ��������� ������� "GetRestrictions". 
	' ������� �������� xml-�������� ������������� � ������, ���� ��� ��� ����. 
	' ���� �������� ��-�� � ������ ���, �� ��-�� ��������� � ��������� � ������ 
	'	������������ �� �������������� �������� - ��. ���������� SetData
	Public Sub Load()
		ReloadInternal
		SetData
	End Sub
	
	
	'==========================================================================
	' ��������� ������
	' ������� �������� xml-�������� ������������� � ������, ���� ��� ��� ����. 
	' ���� �������� ��-�� � ������ ���, �� ��-�� ��������� � ��������� � ������ 
	'	������������ �� �������������� �������� - ��. ���������� SetData
	Public Sub ReLoad()
		ReloadInternal
		SetData
	End Sub

	
	'==========================================================================
	' ������������� ������, ��������� ������� "GetRestrictions". 
	Private Sub ReloadInternal( )
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass - ��������� ������� "GetRestrictions"
		Dim vVal					' As String - �������� ��������
		
		' �������� ����������� - ���������� ������� GetRestrictions
		Set oSelectorRestrictions = new GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions

		' ����������� ������ ������ - ���������� ������� LoadList
		With New LoadListEventArgsClass
			.TypeName = ValueObjectTypeName
			.ListMetaname = m_sListMetaname
			Set .Restrictions = oSelectorRestrictions
			FireEvent "LoadList", .Self()
			m_bHasMoreRows = .HasMoreRows
		End With
	End Sub
	

	'==========================================================================
	' ����������� ���������� ������� "LoadList"
	' ������� � ����� ��������� ������
	' ���������� �������� ������� �� �������������� �������� (� �������� -1)
	'	[in] oEventArgs As LoadListEventArgsClass
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
			' ���������� ���������
			.HasMoreRows = X_LoadComboBox(m_oHtmlElement, .TypeName, .ListMetaname, sRestrictions, .RequiredValues)
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

	
	'==========================================================================
	' ���������� Xml-��������
	' ��������� ��. IPropertyEditor::XmlProperty
	Public Property Get XmlProperty
		Set XmlProperty = m_oObjectEditor.XmlObjectPool.selectSingleNode( m_sXmlPropertyXPath )
		If XmlProperty Is Nothing Then
			Set XmlProperty = m_oObjectEditor.Pool.GetXmlObject(m_sObjectType, m_sObjectID, Null).SelectSingleNode(m_sPropertyName)
		End If
		If XmlProperty Is Nothing Then _
			Err.Raise -1, "XPropertyEditorBaseClass::XmlProperty", "�� ������� �������� " & PropertyName & " � xml-�������"
		If Not IsNull(XmlProperty.getAttribute("loaded")) Then
			Set XmlProperty = m_oObjectEditor.LoadXmlProperty( Nothing, XmlProperty)
		End If		
	End Property
	
	
	'==========================================================================
	' ���������� xml-������ ��������� �������e xml-��������. 
	Public Property Get InitialValue
		Set InitialValue = m_oInitialValue
	End Property
	

	'==========================================================================
	' ���������� xml-������ ��������� �������e xml-��������. 
	Public Property Get InitialValueID
		If Not m_oInitialValue Is Nothing Then
			InitialValueID = m_oInitialValue.getAttribute("oid")
		Else
			InitialValueID = Null
		End If
	End Property
	

	'==========================================================================
	' ���������� xml-������-�������e xml-��������. ���� ��������� ������ ������
	' ���������� Nothing
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
	

	'==========================================================================
	' ������������� ����������� xml-������-�������e xml-�������� � �������� 
	' ������ �����������, ��� ���������������
	' [in] oObject - ��������������� � �������� �������� Xml-������
	' ���� oObject Is Nothing �������� ���������
	Public Property Set Value(oObject)
		Dim oXmlProperty		' As IXMLDOMElement - ������� ��������
		
		Set oXmlProperty = XmlProperty
		' ������ ������� ��������
		If Not oXmlProperty.firstChild Is Nothing Then
			' ���� ��-�� �������� - ������� ���
			m_oObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
		End If
		' ��������� �������� ��������
		If Not IsNothing(oObject) Then
			m_oObjectEditor.Pool.AddRelation Nothing, oXmlProperty, oObject
		End If
		' ��������� �������� � ����������
		SetData
	End Property

	
	'==========================================================================
	' ���������� ������������� �������-�������� xml-��������
	' ���� �������� ������ ���������� Null
	Public Property Get ValueID
		' ������� ID ������� - �������� ��������
		If XmlProperty.FirstChild Is Nothing Then
			ValueID = Null
		Else
			' �������� ������-��������
			ValueID = XmlProperty.FirstChild.getAttribute("oid") 
		End If
	End Property
	
	
	'==========================================================================
	' ������������� �������� �������� � �������� ���������� �� �������������� ������� ��������
	' [in] sObjectID - ������������� ���������������� � �������� �������� Xml-�������
	' ���� sObjectID Is Null �������� ���������
	Public Property Let ValueID(sObjectID)
		If Len("" & sObjectID) = 0 Then
			Set Value = Nothing
		Else
			Set Value = X_CreateObjectStub(ValueObjectTypeName, sObjectID)
		End If
	End Property

	
	'==========================================================================
	' ���������� ������ �������� ������������� �� ������ ���������
	Public Property Get FirstNonEmptyValueID
		Dim sValue	' ��������
		Dim i
		
		For i=0 To m_oHtmlElement.Options.Length-1
			sValue = m_oHtmlElement.Options.Item(i).value
			If HasValue(sValue) Then
				FirstNonEmptyValueID = sValue
				Exit Property
			End If
		Next
	End Property


	'==========================================================================
	' ���������� ������������ ���� ������� �������� ��������
	' ��������� ��. IObjectPropertyEditor::ValueObjectTypeName 
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyMD.GetAttribute("ot")
	End Property
		

	'==========================================================================
	' ���������� ������� �������� ComboBox'a. ���� ������� ������ ������, �� ������������ Null
	Private Property Get ComboboxValue
		Dim vValue
		vValue = m_oHtmlElement.Value
		If Len(vValue)>0 Then
			ComboboxValue = vValue
		Else
			ComboboxValue = Null
		End If
	End Property
	
	
	'==========================================================================
	' ��������� ������� � ���������� ������
	'	[in] vVal - ��������, ��������������� ��������
	'	[in] sLabel - ����� ��������
	Public Sub AddComboBoxItem( vVal, sLabel)
		X_AddComboBoxItem m_oHtmlElement, vVal, sLabel
	End Sub
	
	
	'==========================================================================
	' ������������� �������� ����� � �������� ���������. �������� ��� ���� �� ����������!
	'	[in]		vVal - ��������, ��������������� ��������
	'   [retval]	����� ������ ��������� ��� -1
	Private Function SetComboBoxValue(vVal)
		SetComboBoxValue = X_SetComboBoxValue( m_oHtmlElement, vVal )
	End Function


	'==========================================================================
	' ������������� �������� � ����������
	' ��. IPropertyEditor::SetData	
	Public Sub SetData
		Dim vVal		' �������� ��������
		
		InitialValueTitleElement.value = ObjectEditor.ExecuteStatement( m_oInitialValue, m_sInitialValueTitleStmt )
		vVal = ValueID
		If vVal = InitialValueID Then
			HtmlElement.selectedIndex = 0
		ElseIf SetComboBoxValue(vVal) > -1 Or IsNull(vVal) Then
			m_vPrevValue = vVal
		Else
			If m_bHasMoreRows Then
				m_oEditorPage.EnablePropertyEditor Me, False
				MsgBox _
					"��������! �������� ��������� """ & PropertyDescription & """ " & _
					"�� ����� ���� ���������� ���������, ��� ��� ���������� ������ " & _
					"�������� ��������� �������� �� ������������ ���������� �����.", _
					vbExclamation, "�������� - ���������� ��������� ������"
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
		
		' ������ ����� SetData (�� ����, ��� ����� �� ��������� ��� �������������
		' ��������) ��������� ������� ������������� PE
		m_bIsInitialized = True
	End Sub
	
	
	'==========================================================================
	' �������� � ���� ������
	' ��������� ��. IPropertyEditor::GetDataArgsClass
	Public Sub GetData(oGetDataArgs)
		' ���� ������ ���������� ��������������� ��� ������ ��������
		' ������, ���� ������� �������� �� ���������� �� ����������, �� ������� ������� ����������������� ��-��, 
		' �.�. �� ���� ��� �� ����������
		If ValueID = InitialValueID Then
			XmlProperty.removeAttribute "dirty"
		End If
	End Sub
	
	
	'==========================================================================
	' ������� ��������� � ���������� �������� �������� � Null
	Public Sub Clear
		ClearComboBox
		ValueID = Null
	End Sub

	
	'==========================================================================
	' ������� ��� �������� ����������. �������� �������� ��� ���� �� ��������!
	' ��� ������������� ����������� ������ �������� (��������� � �������)
	Public Sub ClearComboBox
		' ������ �������� ������ ����
		m_oHtmlElement.innerHTML = ""
		X_AddComboBoxItem m_oHtmlElement, Empty, m_sDropdownText
	End Sub

	
	'==========================================================================
	' ���������� ������� (��)�������������� ��������
	' ��������� ��. IPropertyEditor::Mandatory
	Public Property Get Mandatory
		Mandatory = IsNull( m_oHtmlElement.GetAttribute("X_MAYBENULL"))
	End Property

	'==========================================================================
	' ��������� (��)��������������
	' ��������� ��. IPropertyEditor::Mandatory
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			m_oHtmlElement.removeAttribute "X_MAYBENULL"
			m_oHtmlElement.className = "x-editor-control-notnull x-editor-dropdown"
		Else
			m_oHtmlElement.setAttribute "X_MAYBENULL", "YES"
			m_oHtmlElement.className = "x-editor-control x-editor-dropdown"
		End If			
	End Property
	

	'==========================================================================
	' ��������� (��)�����������
	' ��������� ��. IPropertyEditor::Enabled
	Public Property Get Enabled
		 Enabled = Not (m_oHtmlElement.disabled)
	End Property

	'==========================================================================
	' ��������� (��)�����������
	' ��������� ��. IPropertyEditor::Enabled
	Public Property Let Enabled(bEnabled)
		 m_oHtmlElement.disabled = Not( bEnabled )
	End Property
	
	
	'==========================================================================
	' ��������� ������
	' ��������� ��. IPropertyEditor::SetFocus
	Public Function SetFocus
		SetFocus = X_SafeFocus( m_oHtmlElement )
	End Function
	
	
	'==========================================================================
	' ��������� ��������� HTML-�������� ��������� ��������
	' ��������� ��. IPropertyEditor::HtmlElement
	Public Property Get HtmlElement
		Set HtmlElement = m_oHtmlElement
	End Property

	
	'==========================================================================
	' ���������� ������� inputbox'a � ��������� ����������
	Public Property Get InitialValueTitleElement
		Set InitialValueTitleElement = document.all.item("oInitialValueTitleElement")
	End Property


	'==========================================================================
	' ������ ������ � ������� ���������
	' ��������� ��. IDisposable::Dispose
	Public Sub Dispose
		Set m_oObjectEditor = Nothing
		Set m_oEditorPage = Nothing
	End Sub	

	
	'==========================================================================
	' ���������� Html ������� OnChange. ��� ����������� �������������!
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
				Internal_ValueChange ComboboxValue
				FireEvent "Changed", .Self()
			End With
		End if
	End Sub
	
	
	'==========================================================================
	' ��������� ��������� �������� ���������� - ��������� �������� � Xml
	Private Sub Internal_ValueChange(vSelectedValue)
		Dim vValue			' �������� ��������
		Dim oXmlProperty	' xml-��������
		
		Set oXmlProperty = XmlProperty
		With m_oObjectEditor.Pool
			.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
			If IsNull(vSelectedValue) Then 
				' ������� ������ �������� - ������ ��������� �������� �������� �������� ��� ���������
				If IsNull(ValueID) Then
					.AddRelation Nothing, oXmlProperty, InitialValue
					oXmlProperty.removeAttribute "dirty"
				End If
			Else
				.AddRelation Nothing, oXmlProperty, X_CreateObjectStub(ValueObjectTypeName, vSelectedValue)
			End If
		End With
	End Sub
	
	
	'==========================================================================
	' ���������� �������� ��������
	' ��������� ��. IPropertyEditor::PropertyDescription
	Public Property Get PropertyDescription
		PropertyDescription = m_oHtmlElement.GetAttribute("X_DESCR")
	End Property

	
	'==========================================================================
	' ���������� �������
	' [in] sEventName - ������������ �������
	' [in] oEventArgs - ��������� ������� EventArgsClass, �������
	' �������� ����������� ����� EventEngine, ��������� ��� � ��������
	' ��������� ������ �� ���� 
	Private Sub FireEvent(sEventName, oEventArgs)
	    XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub	
	
	
	'==========================================================================
	' ����������/������������� ����� ������� ��������
	' ��. i:object-dropdown
	Public Property Get DropdownText
		DropdownText = m_sDropdownText
	End Property
	Public Property Let DropdownText(vValue)
		m_sDropdownText = vValue
	End Property
End Class