Option Explicit
'*******************************************************************************
' ����������:	
' ����������:	����������� ���������� ������������ UI-������������� ��������� 
'				���������� ��������, ����������� ����� �� ������ ��������
'				(��� �������� vt: ui1 i2 i4 boolean fixed.14.4 r4 r8 )
'*******************************************************************************

'==============================================================================
' ����� ��������� �������� ��� ������������� ���������� ������������ �������� � ���� ���������.
' Xslt: ���� x-pe-selector.xsl, ������ std-template-selector
' �������:
' Changing - (EventArgs: ChangeEventArgsClass) ������������ ����� ����� ������ ��������, 
'			�� ����� ���������� �������� ��������. ���� �������� ���� ReturnValue �� True, �� ��������� ��-�� �� ����������.
' Changed (EventArgs: ChangeEventArgsClass) - ������������ ����� ������ �������� � ��������� �������� ��������
Class XPESelectorComboClass
	Private m_oPropertyEditorBase	' As XPropertyEditorBaseClass
	Private m_bIsActiveX			' As Boolean - ������� ActiveX-����������
	Private m_vPrevValue			' As Variant - ���������� �������� ����������
	Private m_sTypeCastFunc			' As String	 - ������������
	Private m_bNoEmptyValue			' As Boolean - ������� ���������� ������� ��������
	Private m_sDropdownText			' As String  - ����� ������� ��������
	Private m_bKeyUpEventProcessing		' As Boolean - ������� ��������� ActiveX-������� OnKeyUp ��� �������������� ������������ �����
	
	'==========================================================================
	' IPropertyEditor: �������������
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Changing,Changed,Accel", "SelectorCombo"
		m_bIsActiveX = False
		If UCase(oHtmlElement.tagName) = "OBJECT" Then
			m_bIsActiveX = True
		End If
		' � ����������� �� ���� ��������, ��������� ������������ VBS-������� ��� ���������� ����
		m_sTypeCastFunc = X_GetVbsTypeCaseFunc(m_oPropertyEditorBase.PropertyMD.getAttribute("vt"))
		m_bNoEmptyValue = HtmlElement.getAttribute("NoEmptyValue") = "1"
		m_sDropdownText = HtmlElement.getAttribute("EmptyValueText")
		If m_bIsActiveX Then InitActiveXCombo
	End Sub


	'==========================================================================
	' IPropertyEdior: ����� ���������� ��� ���������� �������� ���������, ����� ������������� ���� PE �� ��������
	Public Sub FillData()
		' Nothing to do...
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
	' �������������� ActiveX ��������� - ��������� ������ �� �������� select'� � �������
	Private Sub InitActiveXCombo
		Dim oHiddenData			' ������� ����� ��������
		Dim oOption				' �����
		Dim oSelectorRows		' ��������� ������ � ���������
		
		Set oHiddenData = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.getAttribute("HiddenDataID") )
		Set oSelectorRows = HtmlElement.Rows
		For Each oOption In oHiddenData.options
			oSelectorRows.Add Array(oOption.innerText, oOption.value), CStr(Eval(m_sTypeCastFunc & "(Eval(oOption.value))"))
		Next
		' ����� ����� (������ ShowEmptySelection �� � PropertyBag), ������� ������������� �����, � �� � xsl
		HtmlElement.ShowEmptySelection = Not m_bNoEmptyValue
	End Sub


	'==========================================================================
	' IPropertyEditor: ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property


	'==========================================================================
	' ���������� �������������� �������� �� input'a
	Public Property Get Value
		Dim vValue
		If m_bIsActiveX Then
			vValue = HtmlElement.Rows.SelectedID
		Else
			vValue = HtmlElement.Value
		End If
		If Len(vValue)>0 Then
			If m_sTypeCastFunc = "CStr" Then
				' ��� ����� �������� ���������� ���� �� �����
				Value = vValue
			Else
				Value = Eval( m_sTypeCastFunc & "(" & vValue & ")" )
			End If
		Else
			Value = Null
		End If
	End Property


	'==========================================================================
	' ������������� �������� � �������� � � xml-��������
	Public Property Let Value(vValue)
		If GetDataFromPropertyEditor( vValue, m_oPropertyEditorBase, Null) Then
			SetData
		End If
	End Property


	'==========================================================================
	' IPropertyEditor: ������������� �������� � ��������� ��������
	Public Sub SetData
		Dim vVal		' �������� ��������
		vVal = XmlProperty.nodeTypedValue
		If SetComboBoxValue(vVal) > -1 Then
			m_vPrevValue = vVal
		End if
	End Sub


	'==========================================================================
	' IPropertyEditor: ���� � ��������� ������
	Public Sub GetData(oGetDataArgs)
		' ��������� �� NOT NULL: 
		If Not ValueCheckOnNullForPropertyEditor( Value, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then Exit Sub
	End Sub


	'==========================================================================
	' IPropertyEditor: �������������/���������� (��)�������������� ��������
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			HtmlElement.removeAttribute "X_MAYBENULL"
			HtmlElement.className = "x-editor-control-notnull x-editor-const-selector"
		Else
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
			HtmlElement.className = "x-editor-control x-editor-const-selector"
		End If			
	End Property


	'==========================================================================
	' IPropertyEditor: �������������/���������� (��)����������� ��������� ��������
	Public Property Get Enabled
		If m_bIsActiveX Then
			 Enabled = HtmlElement.object.Enabled
		Else
			 Enabled = Not (HtmlElement.disabled)
		End If
	End Property
	Public Property Let Enabled(bEnabled)
		If m_bIsActiveX Then
			 HtmlElement.object.Enabled = bEnabled
		Else
			 HtmlElement.disabled = Not( bEnabled )
		End If
	End Property


	'==========================================================================
	' IPropertyEditor: ��������� ������
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function


	'==========================================================================
	' IPropertyEditor: ���������� Html �������
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
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
	' IDisposable: ��������� ������
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
		Set m_oPropertyEditorBase = Nothing
	End Sub	


	'==========================================================================
	' ��������� ������� � ���������� ������
	'	[in] vVal - ��������, ��������������� ��������
	'	[in] sLabel - ����� ��������
	Public Sub AddComboBoxItem( vVal, sLabel)
		If m_bIsActiveX Then
			X_AddActiveXComboBoxItem HtmlElement, vVal, sLabel
		Else
			X_AddComboBoxItem HtmlElement, vVal, sLabel
		End If
	End Sub


	'==========================================================================
	' ������� ��������� � ���������� �������� �������� � Null
	Public Sub Clear
		ClearComboBox
		Value = Null
	End Sub
	

	'==========================================================================
	' ������� ��� �������� ����������. �������� �������� ��� ���� �� ��������!
	' ��� ������������� ����������� ������ �������� (�������� � �������)
	Private Sub ClearComboBox
		If m_bIsActiveX Then
			HtmlElement.Clear
		Else
			' ������� ������� ��������
			If m_bNoEmptyValue Then
				' ������� �������� ���
				HtmlElement.innerHTML = ""
			Else
				' ������ �������� ������ ����
				HtmlElement.innerHTML = "<option>" & m_sDropdownText & "</option>"
			End If
		End If
	End Sub


	'==========================================================================
	' ������������� �������� ����� � �������� ���������
	'	[in]		vVal - ��������, ��������������� ��������
	'   [retval]	����� ������ ��������� ��� -1
	Private Function SetComboBoxValue(vVal)
		If m_bIsActiveX Then
			SetComboBoxValue = X_SetActiveXComboBoxValue( HtmlElement, vVal )
		Else
			SetComboBoxValue = X_SetComboBoxTypedValue( HtmlElement, vVal, m_sTypeCastFunc )
			If SetComboBoxValue = -1 And Not m_bNoEmptyValue Then
				' ���� �� ������� ����� �������� � ����� ������ ������� ��������, ��������� ��� (�� ������ ���� ������)
				HtmlElement.SelectedIndex = 0
			End If
		End If
	End Function


	'==========================================================================
	' ���������� Html ������� OnChange. ��� ����������� �������������!
	Public Sub Internal_OnChange
		Dim vValue		' ��������� �������� ����������
		
		vValue = Value
		With New ChangeEventArgsClass
			.OldValue = m_vPrevValue
			.NewValue = vValue
			.ReturnValue = True
			FireEvent "Changing", .Self()
			If Not (.ReturnValue = True) Then
				' ���� � ����������� ��������� ����, �� ������ ���������� �������� � ������� ���������
				SetComboBoxValue m_vPrevValue
				Exit Sub
			End If
			' ������� ��������� �������� � xml-��������
			GetDataFromPropertyEditor vValue, m_oPropertyEditorBase, Nothing
			' �������� ������� �������� ��� ���������� ���������
			m_vPrevValue = vValue
			FireEvent "Changed", .Self()
		End With
	End Sub


	'==========================================================================
	' ���������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	
	
	
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



'==============================================================================
' ����� ��������� �������� ��� ������������� ���������� ������������ �������� � ���� �����-������.
' Xslt: ���� x-pe-selector.xsl, ������ std-template-selector
Class XPESelectorRadioClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_bEnabled					' As Boolean - ������� (��)����������� ��������� ��������
	Private m_sTypeCastFunc				' As String - ������������ VBS-������� ��� ���������� ����
	
	'==========================================================================
	' IPropertyEditor: 
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Changed,Accel", "Selector"
		' � ����������� �� ���� ��������, ��������� ������������ VBS-������� ��� ���������� ����
		m_sTypeCastFunc = X_GetVbsTypeCaseFunc(m_oPropertyEditorBase.PropertyMD.getAttribute("vt"))
	End Sub

	
	'==========================================================================
	' IPropertyEdior: ����� ���������� ��� ���������� �������� ���������, ����� ������������� ���� PE �� ��������
	Public Sub FillData()
		' Nothing to do...
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
	' IPropertyEditor: ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property
	
	
	'==========================================================================
	' ���������� �������������� �������� �� input'a
	' ���� ������ �� ������� ��� ������� ������ �������� - ������������ Null
	Public Property Get Value
		Dim oHtmlRadioElement	' ���� HTML-������� �����-������ �������������
		Value = Null
		For Each oHtmlRadioElement In HtmlElement.all.tags("INPUT")
			If "RADIO" = UCase(oHtmlRadioElement.Type) Then
				If oHtmlRadioElement.Checked Then
					Value = oHtmlRadioElement.value
					If Len(Value)=0 Then Value = Null
					Exit For
				End If
			End If 
		Next
		If Not IsNull(Value) Then
			' ��� ����� �������� ���������� ���� �� �����
			If m_sTypeCastFunc <> "CStr" Then
				Value = Eval( m_sTypeCastFunc & "(Eval(" & Value & "))" )
			End If
		End If
	End Property
	
	
	'==========================================================================
	' ������������� �������� � �������� � � xml-��������
	Public Property Let Value(vValue)
		If GetDataFromPropertyEditor( vValue, m_oPropertyEditorBase, Null) Then
			SetData
		End If
	End Property


	'==========================================================================
	' IPropertyEditor: ������������� �������� � ��������� ��������
	Public Sub SetData
		SetRadioValue XmlProperty.nodeTypedValue 
	End Sub


	'==========================================================================
	' ������������� �������� � ����� �������
	Private Sub SetRadioValue(ByVal vValue)
		Dim oHtmlRadioElement	' Html ������� input
		
		' ���� ��������������� ��������
		If hasValue(vValue) Then
			vValue = Eval( m_sTypeCastFunc & "(vValue)") ' �� ������ ������
		End If
		For Each oHtmlRadioElement In HtmlElement.All.Tags("input")
			If Len(oHtmlRadioElement.value) = 0 Then
				' ������ �������� � input'e
				If Not hasValue(vValue) Then
					' ���� � vValue ���� ������ �������� - ������ �����
					oHtmlRadioElement.Checked = True
					Exit Sub
				Else
					oHtmlRadioElement.Checked = False
				End If
			ElseIf hasValue(vValue) Then
				If m_sTypeCastFunc = "CStr" Then
					If vValue = oHtmlRadioElement.value Then
						oHtmlRadioElement.Checked = True
					Else
						oHtmlRadioElement.Checked = False
					End If
				Else
					' �������� �������� � input'e � � vValue - ������� �������������� ��������
					If (Eval( m_sTypeCastFunc & "(Eval(oHtmlRadioElement.value))") = vValue) Then
						oHtmlRadioElement.Checked = True
						Exit Sub
					Else
						oHtmlRadioElement.Checked = False
					End If		
				End If		
			Else
				' �������� �������� � input'e � ������ �������� � vValue - ����� �� �����
				oHtmlRadioElement.Checked = False
			End If		
		Next
	End Sub
	
	
	'==========================================================================
	' IPropertyEditor: ���� � ��������� ������
	Public Sub GetData(oGetDataArgs)
		Dim vValue			' �������������� ��������
	
		vValue = Value
		' ��������� �� NOT NULL: 
		If Not ValueCheckOnNullForPropertyEditor( vValue, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then Exit Sub
		' ������ �������� � XML:
		GetDataFromPropertyEditor vValue, m_oPropertyEditorBase, oGetDataArgs
	End Sub
	
	
	'==========================================================================
	' IPropertyEditor: �������������/���������� (��)�������������� ��������
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			HtmlElement.removeAttribute "X_MAYBENULL"
			HtmlElement.className = "x-editor-control-notnull x-editor-string-lookup-field"
		Else
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
			HtmlElement.className = "x-editor-control x-editor-string-lookup-field"
		End If			
	End Property
	
	
	'==========================================================================
	' IPropertyEditor: �������������/���������� (��)����������� ��������� ��������
	Public Property Get Enabled
		 Enabled = m_bEnabled
	End Property
	Public Property Let Enabled(bEnabled)
		Dim oRadioElement	' Html ������� input'a
		For Each oRadioElement In HtmlElement.all.tags("INPUT")
			oRadioElement.disabled = Not( bEnabled )
		Next
		m_bEnabled = bEnabled
	End Property
	
	
	'==========================================================================
	' IPropertyEditor: ��������� ������
	Public Function SetFocus
		Dim oRadioElement	' Html ������� input'a
		
		SetFocus = False
		' ������� ���������� ����� �� ���� �� �����-������;
		' ���� ����������� �� ��� ���, ���� ����� �� ����� ����������
		For Each oRadioElement In HtmlElement.all.tags("INPUT")
			If X_SafeFocus( oRadioElement ) Then
				SetFocus = True
				Exit For
			End If
		Next
	End Function
	
	
	'==========================================================================
	' IPropertyEditor: ���������� Html �������
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property


	'==========================================================================
	' IDisposable: ��������� ������
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
	End Sub	
	
	
	'==========================================================================
	' ���������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	


	'==========================================================================
	' ���������� Html-������� OnClick �� radio-������. ��������: ��� ����������� �������������.
	'	[in] sID - ������������� ��������� radio-������
	Public Sub Internal_OnClick(sID)
		Dim vValue		' ������� �������� radio-������
		vValue = Value
		With New ChangeEventArgsClass
			.OldValue = XmlProperty.nodeTypedValue
			.NewValue = vValue
			' ������� ��������� �������� � xml-��������
			GetDataFromPropertyEditor vValue, m_oPropertyEditorBase, Nothing
			FireEvent "Changed", .Self()
		End With
	End Sub
	
	
	'==========================================================================
	' ���������� Html-������� OnKeyUp �� ��������. ��������: ��� ����������� �������������.
	Public Sub Internal_OnKeyUp()
		Dim oEventArgs		' As AccelerationEventArgsClass
		
		If window.event Is Nothing Then Exit Sub
		window.event.cancelBubble = True
		Set oEventArgs = CreateAccelerationEventArgsForHtmlEvent()
		Set oEventArgs.Source = Me
		FireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' ���� ������� ���������� �� ���������� - ��������� �� � ��������
			ObjectEditor.OnKeyUp Me, oEventArgs
		End If
	End Sub
End Class
