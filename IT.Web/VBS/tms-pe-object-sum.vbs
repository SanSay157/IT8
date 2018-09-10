Option Explicit

'==============================================================================
'	���������� ��������� �������� ���� "�����"
'==============================================================================
' ������� (� ������� ������������ ������ ���������� �������):
'	MenuBeforeShow  - ����� ������� ���� (MenuEventArgs)
'	ShowMenu		- ����� ���� (MenuEventArgs). ���� ����������� ����������
'	BeforeCreate	- ����� ��������� ������� (EventArgsClass, ���� ��������� ������ �����; OpenEditorEventArgs, ���� ��������� ������ ������). 
'	Create			- �������� ������� (EventArgsClass, ���� ��������� ������ �����; OpenEditorEventArgs, ���� ��������� ������ ������). ���� ����������� ����������
'	AfterCreate		- ����� �������� ������� (EventArgsClass, ���� ��������� ������ �����; OpenEditorEventArgs, ���� ��������� ������ ������).
' ������� DoEdit:
'	BeforeEdit		- ����� �������������� ������� (OpenEditorEventArgs). ���� ReturnValue=False, ������� ������� �����������
'	Edit			- �������������� ������� (OpenEditorEventArgs). ���� ����������� ����������
'	AfterEdit		- ����� �������������� ������� (OpenEditorEventArgs).
'	BeforeMarkDelete- ����� �������� ������� ��� ���������� (EventArgsClass)
'	MarkDelete		- ��������� ������� ��� ���������� (EventArgsClass). ���� ����������� ����������
'	AfterMarkDelete	- ����� ������� ������� ��� ���������� (EventArgsClass)
'	BeforeLink		- ����� ����������� ������� � �������� (EventArgsClass).
'	Link			- ���������� ������� � �������� (EventArgsClass). ���� ����������� ����������
'	AfterLink		- ����� ���������� ������� � �������� (EventArgsClass).
'	BeforeUnlink	- ����� �������� �������� (EventArgsClass). ���� ReturnValue=False, ������� ������� �����������
'	Unlink			- ������� �������� (EventArgsClass). ���� ����������� ����������
'	AfterUnlink		- ����� ������� �������� (EventArgsClass).
Class PEObjectSumClass
	Private EVENTS						' ������ �������
	Private m_oPropertyEditorBase		' As XPropertyEditorObjectBaseClass
	Private m_oSumValuePropertyEditor	' As XPENumberClass
	Private m_oCurrencyPropertyEditor	' As XPEObjectDropdownClass
	Private m_oExchangePropertyEditor	' As XPENumberClass
	Private m_oFocusedPropertyEditor
	Private m_bCreateTempValue			' As Boolean - ���������� ��������� ������-�������� ��������
	Private m_sTempValueID				' As Guid - ������������� ���������� �������
	Private m_oMenu						' As MenuClass		- ���� ��������
	
	'==========================================================================
	' �����������
	Private Sub Class_Initialize
		EVENTS = "MenuBeforeShow,ShowMenu," & _
			"BeforeEdit,Edit,AfterEdit," & _
			"BeforeCreate,Create,AfterCreate," & _
			"BeforeMarkDelete,MarkDelete,AfterMarkDelete," & _
			"BeforeLink,Link,AfterLink," & _
			"BeforeUnlink,Unlink,AfterUnlink"			
	End Sub

	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim oMenuMD				' ���������� ���� (i:menu)
		Dim oTempValue			' ��������� ������-��������

		Set m_oMenu = New MenuClass
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectSum"
		
		Set m_oFocusedPropertyEditor = Me
		
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Create", Me, "OnCreate"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Link", Me, "OnLink"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Unlink", Me, "OnUnlink"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "MarkDelete", Me, "OnMarkDelete"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Edit", Me, "OnEdit"
      
		' �������������� ����: ������� ��� ����������, (��������� ������� MetadataLocator ������ i:object-presentation), ������� ����������� ����������� 
		Set oMenuMD = m_oPropertyEditorBase.PropertyEditorMD.selectSingleNode( "i:prop-menu/i:menu")
		If Not oMenuMD Is Nothing Then
			m_oMenu.AddMacrosResolver X_CreateDelegate(Me, "Internal_MenuMacrosResolver") 
			m_oMenu.AddVisibilityHandler X_CreateDelegate(Me, "Internal_MenuVisibilityHandler")
			m_oMenu.AddExecutionHandler X_CreateDelegate(Me, "Internal_MenuExecutionHandler") 
			m_oMenu.Init oMenuMD
		End If
		
		' ���� ������-�������� �������� ��� �� ������, �� �������� ���������
		Set oTempValue = Value
		If oTempValue Is Nothing Then
			DoCreate()
			m_bCreateTempValue = True
			Set oTempValue = TempValue()
		Else
			m_bCreateTempValue = False
			m_sTempValueID = oTempValue.getAttribute("oid")
		End If

		Set m_oSumValuePropertyEditor = New XPENumberClass
		m_oSumValuePropertyEditor.Init ParentPage, GetSumValueXmlProperty(oTempValue), SumValueHtmlElement
		
		Set m_oCurrencyPropertyEditor = New XPEObjectDropdownClass
		m_oCurrencyPropertyEditor.Init ParentPage, GetCurrencyXmlProperty(oTempValue), CurrencyHtmlElement

		Set m_oExchangePropertyEditor = New XPENumberClass
		m_oExchangePropertyEditor.Init ParentPage, GetExchangeXmlProperty(oTempValue), ExchangeHtmlElement
	End Sub


	'==========================================================================
	' IPropertyEdior: ����� ���������� ��� ���������� �������� ���������, ����� ������������� ���� PE �� ��������
	Public Sub FillData()
		CurrencyPropertyEditor.FillData				
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
	' ���������� ��������� EventEngineClass - �������, ���������������
	' ���������� ������ ��� ������� ��������� ��������
	Public Property Get EventEngine
		Set EventEngine = m_oPropertyEditorBase.EventEngine
	End Property


	'==========================================================================
	' ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property


	'==========================================================================
	' ���������� Xml-�������� �������� �����
	Public Property Get SumValueXmlProperty
		SumValueXmlProperty = SumValueXmlPropertyEx(Value)
	End Property
	
	'==========================================================================
	' ���������� Xml-�������� �������� ����� �� Xml-�������� ������� �����
	' ������������ ��� �����������, �.�. �� �������� Value ����������� ����������
	Private Function GetSumValueXmlProperty(oValue)
		If oValue Is Nothing Then
			Set GetSumValueXmlProperty = Nothing
		Else	
			Set GetSumValueXmlProperty = oValue.selectSingleNode("SumValue")
		End If
	End Function
	

	'==========================================================================
	' ���������� Xml-�������� ������
	Public Property Get CurrencyXmlProperty
		SumValueXmlProperty = SumValueXmlPropertyEx(Value)
	End Property
	
	'==========================================================================
	' ���������� Xml-�������� ������ �� Xml-�������� ������� �����
	' ������������ ��� �����������, �.�. �� �������� Value ����������� ����������
	Private Function GetCurrencyXmlProperty(oValue)
		If oValue Is Nothing Then
			Set GetCurrencyXmlProperty = Nothing
		Else	
			Set GetCurrencyXmlProperty = oValue.selectSingleNode("Currency")
		End If
	End Function
	

	'==========================================================================
	' ���������� Xml-�������� �������� ����� ��������
	Public Property Get ExchangeXmlProperty
		ExchangeXmlProperty = ExchangeXmlPropertyEx(Value)
	End Property
	
	'==========================================================================
	' ���������� Xml-�������� �������� ����� �������� �� Xml-�������� ������� �����
	' ������������ ��� �����������, �.�. �� �������� Value ����������� ����������
	Private Function GetExchangeXmlProperty(oValue)
		If oValue Is Nothing Then
			Set GetExchangeXmlProperty = Nothing
		Else	
			Set GetExchangeXmlProperty = oValue.selectSingleNode("ExchangeRate")
		End If
	End Function
	

	'==========================================================================
	' ���������� xml-������-�������e xml-��������. ���� ��������� ������ ������
	' ���������� Nothing
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
	' ���������� ��������� xml-������-�������e xml-��������. ���� ���������
	' ������ �� ����������, ���������� Value
	Public Property Get TempValue
		Set TempValue = m_oPropertyEditorBase.ObjectEditor.Pool.GetXmlObject(ValueObjectTypeName, TempValueID, Nothing)
	End Property

	'==========================================================================
	' ���������� ������������� ���������� �������-�������� xml-��������
	' ���� �������� ������ ���������� Null
	Public Property Get TempValueID
		TempValueID = m_sTempValueID
	End Property	 


	'==========================================================================
	' ������������� �������� � ��������� ��������
	Public Sub SetData
		SumValuePropertyEditor.SetData
		CurrencyPropertyEditor.SetData
		ExchangePropertyEditor.SetData
	End Sub


	'==========================================================================
	' ���� � ��������� ������
	Public Sub GetData(oGetDataArgs)
		Dim oSumValuePropertyEditor '�������� �������� Sum ������� ���� "�����"
		Dim oCurrencyPropertyEditor '�������� �������� Currency ������� ���� "�����"
		Dim oExchangePropertyEditor '�������� �������� Exchange ������� ���� "�����"
		Dim bHasSomeData '���������� ������� ��������, ��� ������ �������� ���� �� ������ �� ���� ���� ��������� �������
		
		' ���������� ������ �� ��������� � ��������� ����������
		Set oSumValuePropertyEditor = SumValuePropertyEditor
		Set oCurrencyPropertyEditor = CurrencyPropertyEditor
		Set oExchangePropertyEditor = ExchangePropertyEditor
				
		' �������� ������ �� ��������� �����
		oSumValuePropertyEditor.GetData oGetDataArgs
		If Not oGetDataArgs.ReturnValue Then
			Set m_oFocusedPropertyEditor = oSumValuePropertyEditor
			Exit Sub		
		End If
		' �������� ������ �� ��������� ������
		oCurrencyPropertyEditor.GetData oGetDataArgs
		If Not oGetDataArgs.ReturnValue Then
			Set m_oFocusedPropertyEditor = oCurrencyPropertyEditor
			Exit Sub		
		End If
		' �������� ������ �� ��������� ����� ������
		oExchangePropertyEditor.GetData oGetDataArgs
		If Not oGetDataArgs.ReturnValue Then
			Set m_oFocusedPropertyEditor = oExchangePropertyEditor
			Exit Sub		
		End If

		Set m_oFocusedPropertyEditor = Me

		bHasSomeData = HasSomeDataEx(oSumValuePropertyEditor, oCurrencyPropertyEditor, oExchangePropertyEditor)
		
		' ���� ���� �� ���� ���� ���������
		If bHasSomeData Then
			' ���������, ��� ������ �������� �����
			If Not hasValue(oSumValuePropertyEditor.Value) Then
				oGetDataArgs.ReturnValue = False
				oGetDataArgs.ErrorMessage = "��� �������� """ & PropertyDescription & """ �� ������ �������� �����." & vbNewLine & "�� ������ ������ �������� ����� ���� �������� ��� ��������� ������� ��������."
				Set m_oFocusedPropertyEditor = oSumValuePropertyEditor
				Exit Sub
			End If

			' ���������, ��� ������ ������
			If Not hasValue(oCurrencyPropertyEditor.Value) Then
				oGetDataArgs.ReturnValue = False
				oGetDataArgs.ErrorMessage = "��� �������� """ & PropertyDescription & """ �� ������ ������." & vbNewLine & "�� ������ ������ ��� ������ ���� �������� ��� ��������� ������� ��������."
				Set m_oFocusedPropertyEditor = oCurrencyPropertyEditor
				Exit Sub
			End If

			DoLink()
		End If
		
		' ���� �� ���� ���� �� ���������
		If Not bHasSomeData Then
			DoUnlink()
		End If 

		' �������� �������������� ��������
		ValueCheckOnNullForPropertyEditor Value, Me, oGetDataArgs, Mandatory
	End Sub

	
	'==========================================================================
	' ���������, ��� ���� �� ���� ���� ���������
	Public Function HasSomeData()
		HasSomeData = HasSomeDataEx( _
			SumValuePropertyEditor, _
			CurrencyPropertyEditor, _
			ExchangePropertyEditor)
	End Function

	'==========================================================================
	' ���������, ��� ���� �� ���� ���� ���������
	Public Function HasSomeDataEx(oSumValuePropertyEditor, oCurrencyPropertyEditor, oExchangePropertyEditor)
		HasSomeDataEx = hasValue(oSumValuePropertyEditor.Value) _
			Or hasValue(oCurrencyPropertyEditor.Value) _
			Or hasValue(oExchangePropertyEditor.Value)
	End Function


	'==========================================================================
	' �������������/���������� (��)�������������� ��������
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If (bMandatory) Then
			HtmlElement.removeAttribute "X_MAYBENULL"
			
			SumValueHtmlElement.removeAttribute "X_MAYBENULL"
			SumValueHtmlElement.className = "x-editor-control-notnull x-editor-numeric-field"

			CurrencyHtmlElement.removeAttribute "X_MAYBENULL"
			CurrencyHtmlElement.className = "x-editor-control-notnull x-editor-dropdown"
		Else	
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
			
			SumValueHtmlElement.setAttribute "X_MAYBENULL", "YES"
			SumValueHtmlElement.className = "x-editor-control x-editor-numeric-field"
			
			CurrencyHtmlElement.setAttribute "X_MAYBENULL", "YES"
			CurrencyHtmlElement.className = "x-editor-control x-editor-dropdown"
		End If
	End Property
	

	'==========================================================================
	' �������������/���������� (��)����������� ��������� ��������
	Public Property Get Enabled
		Enabled = Not (HtmlElement.disabled)
	End Property
	Public Property Let Enabled(bEnabled)
		 HtmlElement.disabled = Not( bEnabled )
		 SumValueHtmlElement.disabled = Not( bEnabled )
		 CurrencyHtmlElement.disabled = Not( bEnabled )
		 ExchangeHtmlElement.disabled = Not( bEnabled )
	End Property


	'==========================================================================
	' ��������� ������
	Public Function SetFocus
		If m_oFocusedPropertyEditor Is Nothing Or _
		   m_oFocusedPropertyEditor Is Me Then
			SetFocus = X_SafeFocus( HtmlElement )
		Else
			SetFocus = m_oFocusedPropertyEditor.SetFocus()
		End If
	End Function


	'==========================================================================
	' ���������� Html �������
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property


	'==========================================================================
	' ���������� Html ������� ���������� ���� ����� �����
	Public Property Get SumValueHtmlElement
		Set SumValueHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all(HtmlElement.GetAttribute("SumValueID"), 0)
	End Property


	'==========================================================================
	' ���������� Html ������� ����������� ������ �����
	Public Property Get CurrencyHtmlElement
		Set CurrencyHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all(HtmlElement.GetAttribute("CurrencyID"), 0)
	End Property


	'==========================================================================
	' ���������� Html ������� ���������� ���� ����� ����� ��������
	Public Property Get ExchangeHtmlElement
		Set ExchangeHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all(HtmlElement.GetAttribute("ExchangeID"), 0)
	End Property

	'==========================================================================
	' ������� ��������� ������, ���� �� ����������� � ����
	Private Sub DoCreateIfNotExists()
		Dim sTempObjectXPath 'XPath -������, �� �������� ������ ������ � ����
		Dim oTempObject '��������� ������
		
		sTempObjectXPath = ValueObjectTypeName & "[@oid='" & TempValueID & "']"
		Set oTempObject = m_oPropertyEditorBase.ObjectEditor.XmlObjectPool.selectSingleNode(sTempObjectXPath)
		If oTempObject Is Nothing Then
			DoCreate()
		End If		
	End Sub
	
	'==========================================================================
	' ���������� �������� �������� �����
	Public Property Get SumValuePropertyEditor
		DoCreateIfNotExists()
		Set SumValuePropertyEditor = m_oSumValuePropertyEditor
	End Property


	'==========================================================================
	' ���������� �������� ���������� �������� ������
	Public Property Get CurrencyPropertyEditor
		DoCreateIfNotExists()
		Set CurrencyPropertyEditor = m_oCurrencyPropertyEditor
	End Property


	'==========================================================================
	' ���������� �������� �������� ����� ��������
	Public Property Get ExchangePropertyEditor
		DoCreateIfNotExists()
		Set ExchangePropertyEditor = m_oExchangePropertyEditor
	End Property


	'==========================================================================
	' ���������� �������� ��������
	' ��������� ��. IPropertyEditor::PropertyDescription
	Public Property Get PropertyDescription
		PropertyDescription = m_oPropertyEditorBase.PropertyDescription
	End Property	


	'==========================================================================
	' ���������� ������������ ���� ������� �������� ��������
	' ��������� ��. IObjectPropertyEditor::ValueObjectTypeName 
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyEditorBase.ValueObjectTypeName
	End Property


	'==========================================================================
	' IDisposable: ��������� ������
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
		Set m_oPropertyEditorBase = Nothing
		
		m_oSumValuePropertyEditor.Dispose
		Set m_oSumValuePropertyEditor = Nothing
	End Sub	

	'==========================================================================
	' ���������� �������
	' [in] sEventName - ������������ �������
	' [in] oEventArgs - ��������� ������� EventArgsClass, �������
	' �������� ����������� ����� EventEngine, ��������� ��� � ��������
	' ��������� ������ �� ���� 
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub
	
	
	'==========================================================================
	Public Sub DoCreate()
		With New EventArgsClass
			FireEvent "BeforeCreate", .Self()
			FireEvent "Create", .Self()
			FireEvent "AfterCreate", .Self()
		End With
	End Sub

	'==========================================================================
	Public Sub DoLink()
		If XmlProperty.selectSingleNode(ValueObjectTypeName) Is Nothing Then
			With New EventArgsClass
				FireEvent "BeforeLink", .Self()
				FireEvent "Link", .Self()
				FireEvent "AfterLink", .Self()
			End With
		End If
	End Sub

	'==========================================================================
	Public Sub DoUnlink()
		With New EventArgsClass
			If Not XmlProperty.selectSingleNode(ValueObjectTypeName) Is Nothing Then
				FireEvent "BeforeUnlink", .Self()
				FireEvent "Unlink", .Self()
				FireEvent "AfterUnlink", .Self()
			End If

			FireEvent "BeforeMarkDelete", .Self()
			FireEvent "MarkDelete", .Self()
			FireEvent "AfterMarkDelete", .Self()
		End With
	End Sub


	'==========================================================================
	'	[in] oValues	- ��������� ���������� �������� ����
	Public Sub DoCreateCurrency(oValues)
		With New OpenEditorEventArgsClass
			Set .OperationValues = oValues
			.Metaname = CurrencyHtmlElement.GetAttribute("EditorMetanameForCreating")
			If Not hasValue(.Metaname) And .OperationValues.Exists("Metaname") Then
				.Metaname = .OperationValues.Item("Metaname")
			End If
			.IsSeparateTransaction = False
			If .OperationValues.Exists("UrlParams") Then
				.UrlArguments = .OperationValues.Item("UrlParams")
			End If
			.ReturnValue = True
			FireEvent "BeforeCreate", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "Create", .Self()
			FireEvent "AfterCreate", .Self()
		End With
	End Sub


	'==========================================================================
	' ����������� ���������� ������� "Create"
	' [in] oSender - ��������� PEObjectSumClass, �������� �������
	' [in] oEventArgs - ��������� EventArgsClass, ��������� �������
	Public Sub OnCreate(oSender, oEventArgs)
		Dim oTempValue		' ��������� ������-��������
		Dim oXmlProperty	' xml-��������
		Dim oNewObject		' ����� ������-��������
	
		' ���� �� ������� ������ �����
		If TypeName(oEventArgs) <> "OpenEditorEventArgsClass" Then
			Set oTempValue = m_oPropertyEditorBase.ObjectEditor.Pool.CreateXmlObjectInPool(ValueObjectTypeName)
			oTempValue.removeAttribute "new"
			oTempValue.removeAttribute "transaction-id"
			If Not hasValue(m_sTempValueID) Then
				' ���� ������������� ���������� ������� ��� �� ���������, ���������� ���
				m_sTempValueID = oTempValue.getAttribute("oid")
			Else
				' ���� ������������� ���������� ������ ��� ��� ���������, ��
				' ��������� ��� ��� ����� ���������� �������
				' ���������. ����� ����� ���� �������� ��� �������������
				' RollbackTransaction � ���� (��������, � ������� �
				'  wizard-mode = "undo-chenges")
				oTempValue.setAttribute "oid", m_sTempValueID
			End If
			m_bCreateTempValue = True
		
		' ���� �� ������� ����� ������
		Else
			' ���������� ��������� ������-��������
			Set oTempValue = TempValue()
			' ������ �������������� ����������
			m_oPropertyEditorBase.ObjectEditor.Pool.BeginTransaction True
			Set oXmlProperty = oTempValue.selectSingleNode("Currency")
			' ������ ������-�������� �� ��������, ���� �� ��� ����
			m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
			' ������� ����� ������ � �������� ��� � ���
			Set oNewObject = m_oPropertyEditorBase.ObjectEditor.Pool.CreateXmlObjectInPool("Currency")
			' ������� ���� ����� ������-�������� � ��������
			m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation oTempValue, oXmlProperty, oNewObject
			' ������� ��������� �������� � ��������� EnlistInCurrentTransaction=True, �.�. ���� �������� �� ����� ��������� ����� ����������
			oEventArgs.ReturnValue  = m_oPropertyEditorBase.ObjectEditor.OpenEditor(oNewObject, Null, Null, oEventArgs.Metaname, True, oXmlProperty, True, True, oEventArgs.UrlArguments)
			If IsEmpty( oEventArgs.ReturnValue ) Then
				' ������ ������ - ������� ����������
				m_oPropertyEditorBase.ObjectEditor.Pool.RollbackTransaction
			Else
				' ������ �� - ���������
				m_oPropertyEditorBase.ObjectEditor.Pool.CommitTransaction

				' ������� �������� � ���������� ������
				CurrencyPropertyEditor.AddComboBoxItem oNewObject.getAttribute("oid"), oNewObject.selectSingleNode("Code").nodeTypedValue
				' ������� ����� ��������� ������
				Set CurrencyPropertyEditor.Value = oNewObject
				' �������� �������� ���������� �������� � ������ ��������
				DoLink()
			End If
		End If
	End Sub
	
	'==========================================================================
	' ����������� ���������� ������� "Link"
	' [in] oSender - ��������� PEObjectSumClass, �������� �������
	' [in] oEventArgs - ��������� EventArgsClass, ��������� �������
	Public Sub OnLink(oSender, oEventArgs)
		Dim oTempValue		' ��������� ������-��������

		' ���������� ��������� ������-��������
		Set oTempValue = TempValue()

		m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, XmlProperty, oTempValue
		If m_bCreateTempValue Then
			oTempValue.setAttribute "new", "1"
			oTempValue.setAttribute "transaction-id", m_oPropertyEditorBase.ObjectEditor.Pool.TransactionID
		Else
			oTempValue.removeAttribute "delete"
		End If
	End Sub

	'==========================================================================
	' ����������� ���������� ������� "UnLink"
	' [in] oSender - ��������� PEObjectSumClass, �������� �������
	' [in] oEventArgs - ��������� EventArgsClass, ��������� �������
	Public Sub OnUnlink(oSender, oEventArgs)
		m_oPropertyEditorBase.ObjectEditor.Pool.RemoveAllRelations Nothing, XmlProperty
	End Sub
	
	'==========================================================================
	' ����������� ���������� ������� "MarkDelete"
	' [in] oSender - ��������� PEObjectSumClass, �������� �������
	' [in] oEventArgs - ��������� EventArgsClass, ��������� �������
	Public Sub OnMarkDelete(oSender, oEventArgs)
		Dim oTempValue		' ��������� ������-��������

		' ���������� ��������� ������-��������
		Set oTempValue = TempValue()

		If m_bCreateTempValue Then
			oTempValue.removeAttribute "new"
			oTempValue.removeAttribute "transaction-id"
		Else
			m_oPropertyEditorBase.ObjectEditor.MarkXmlObjectAsDeleted  oTempValue, Nothing
		End If
	End Sub


	'==========================================================================
	' ����������� ���������� ������� "Edit"
	' [in] oSender - ��������� PEObjectSumClass, �������� �������
	' [in] oEventArgs - ��������� OpenEditorEventArgsClass, ��������� �������
	' ������ ���������� ���������� ����� ��������� � ������ ��������������
	' ������ �������.
	Public Sub OnEdit(oSender, oEventArgs)
		Dim oXmlProperty	' xml-��������

		' ��-������ �������� ������ �� ��������� ����������
		With New GetDataArgsClass
			.SilentMode = True
			SumValuePropertyEditor.GetData .Self()
			CurrencyPropertyEditor.GetData .Self()
			ExchangePropertyEditor.GetData .Self()
		End With
		
		With oEventArgs
			Set oXmlProperty = XmlProperty
			.ReturnValue = m_oPropertyEditorBase.ObjectEditor.OpenEditor(oXmlProperty.firstChild, Null, Null, .Metaname, False, oXmlProperty, Not .IsSeparateTransaction, False, .UrlArguments)
			If IsEmpty( .ReturnValue ) Then Exit Sub
			' oXmlProperty ������������ ��� ������
			SetData
		End With
	End Sub

	'==========================================================================
	' ���������� ����, ������������ ����������� ������������ ������� OnShowMenu
	Public Property Get Menu
		Set Menu = m_oMenu
	End Property	


	'==========================================================================
	' ���������� ����� ������ "...". �������� ����� ���� ��������.
	Public Sub ShowMenu
		Dim nPosX		' ���������� x ��� ������ ����
		Dim nPosY		' ���������� y ��� ������ ����
		
		With New MenuEventArgsClass
			Set .Menu = m_oMenu
			.ReturnValue = True
			FireEvent "MenuBeforeShow", .Self()
			If .ReturnValue <> True Then Exit Sub
		End With
		If Not m_oMenu.Initialized Then Exit Sub
		X_GetHtmlElementScreenPos HtmlElement, nPosX, nPosY
		'nPosX = nPosX + window.screenLeft
		nPosY = nPosY + HtmlElement.offsetHeight
		m_oMenu.ShowPopupMenuWithPosEx Me, nPosX, nPosY, True
	End Sub

	'==========================================================================
	' ����������� �������� �������� ����
	'	[in] oMenuEventArgs As MenuEventArgsClass
	' ��������� ��. �������� MenuClass 
	Sub Internal_MenuMacrosResolver(oSender, oMenuEventArgs)
		Dim sObjectID		' ������������� �������-��������
		sObjectID = Null
		With XmlProperty
			If Not .firstChild Is Nothing Then
				sObjectID = .firstChild.getAttribute("oid")
			End If
		End With
		oMenuEventArgs.Menu.Macros.Item("ObjectID")   = sObjectID
		oMenuEventArgs.Menu.Macros.Item("ObjectType") = m_oPropertyEditorBase.ValueObjectTypeName
	End Sub
	
	
	'==========================================================================
	' ����������� ���������� ���������/����������� ������� ����
	'	[in] oMenuEventArgs As MenuEventArgsClass
	' ��������� ��. �������� MenuClass 
	Sub Internal_MenuVisibilityHandler(oSender, oMenuEventArgs)
		Dim bDisabled		' ������� ����������������� ������
		Dim bHidden			' ������� �������� ������
		Dim oNode			' ������� menu-item
		Dim sType			' ��� ������� � ��������
		Dim sObjectID		' ������������� �������-��������
		Dim oList			' As ObjectArrayListClass - ������ �������� XObjectPermission
		Dim bHasChild		' �������, ��� � �������� ���� ������-��������
		Dim oXmlProperty	' xml-��������
		Dim oObjectValue	' As IXMLDOMElement - xml-������ ��������
		Dim bIsLoaded		' As Boolean - ������� ����,��� ������-�������� �������� �� ��
		Dim bProcess		' As Boolean - ������� ��������� �������� ������

		Set oXmlProperty = XmlProperty		
		sType = ValueObjectTypeName
		sObjectID = TempValueID
		If Not IsNull(sObjectID) Then
			Set oObjectValue = ObjectEditor.Pool.GetXmlObject(sType, sObjectID, Null)
			If Not oObjectValue Is Nothing Then
				bIsLoaded = IsNull(oObjectValue.getAttribute("new"))
			End If
		End If	

		Set oList = New ObjectArrayListClass
		' ���������� ������ ��������� ��� ��������
		For Each oNode In oMenuEventArgs.Menu.XmlMenu.selectNodes("i:menu-item")
			' ��������� �������� �� ������ ����, ����� oMenu.SetMenuItemsAccessRights ���� ������� ������� �� �������� ���� � ������ ���� (��� ������������ ����� disabled)
			oNode.setAttribute "type", sType
			If Not IsNull(sObjectID) Then _
				oNode.setAttribute "oid",  sObjectID
				
			bHidden = Empty
			bDisabled = Empty
			bProcess = False
			Select Case oNode.getAttribute("action")
				Case "DoEdit"
					bHidden = Len( HtmlElement.getAttribute("OFF_EDIT") )>0
					If Not bHidden Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CHANGE, sType, sObjectID)
					bProcess = True
				Case "DoUnlink"
					bHidden = Not HasSomeData() Or Len( HtmlElement.getAttribute("OFF_UNLINK") )>0
					If Not bHidden Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_DELETE, sType, sObjectID)
					bProcess = True
				Case "DoCreateCurrency"
					bHidden = Len( HtmlElement.getAttribute("OFF_CREATE_CURRENCY") )>0
					If Not bHidden Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CREATE, "Currency", Null)
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
			oMenuEventArgs.Menu.SetMenuItemsAccessRights oList.GetArray()
		End If
	End Sub
	
	
	'==========================================================================
	' ����������� ���������� ���������� ������ ����
	' [in] oMenuExecuteEventArgs As MenuExecuteEventArgsClass
	' ��������� ��. �������� MenuClass 
	Sub Internal_MenuExecutionHandler(oSender, oMenuExecuteEventArgs)
		oMenuExecuteEventArgs.Cancel = True
		Select Case oMenuExecuteEventArgs.Action
			' ��������������� � ������� ����������
			Case "DoEdit"
				DoLink()
				m_oPropertyEditorBase.DoEdit oMenuExecuteEventArgs.Menu.Macros, False
			' ��������� �����
			Case "DoUnlink"
				SumValuePropertyEditor.Value = Null
				CurrencyPropertyEditor.ValueID = Null
				ExchangePropertyEditor.Value = Null
				DoUnlink()
			' ������� ����� ������
			Case "DoCreateCurrency"
				DoCreateCurrency oMenuExecuteEventArgs.Menu.Macros
			Case Else
				oMenuExecuteEventArgs.Cancel = False
		End Select
	End Sub
	
End Class
