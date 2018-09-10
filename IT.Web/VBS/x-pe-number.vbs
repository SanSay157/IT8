'*******************************************************************************
' ����������:	
' ����������:	����������� ���������� ������������ UI-������������� ��������� 
'				���������� �������� (��� �������� vt: ui1 i2 i4 r4 r8 fixed.14.4)
'*******************************************************************************

'==============================================================================
' �������:
'	Accel (EventArg: AccelerationEventArgsClass)
'		- ������� ���������� ������ 
'	BeforeDeactivate (EventArg: EventArgsClass)
'		- ������ ������
Class XPENumberClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_sTypeCastFunc				' As String			- ������������
	Private m_sFormatFunc				' As String			- ������������
	Private m_sParseFunc				' As String			- ������������
	Private m_nDecimalPlaces			' As Long			- ���������� ���������� ������ ����� ,
	Private m_bIsInteger				' As Boolean		
	Private m_sPropType					' As String	- ��� ��������
	Private m_bKeyUpEventProcessing		' As Boolean - ������� ��������� ActiveX-������� OnKeyUp ��� "����������" �����
	
	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Accel,BeforeDeactivate", "Number"
		' � ����������� �� ���� ��������, ��������� ������������ VBS-������� ��� ���������� ����
		m_sPropType = oHtmlElement.GetAttribute("X_TYPE")
		m_sTypeCastFunc = X_GetVbsTypeCaseFunc(m_sPropType)
		m_bIsInteger = CBool(m_sPropType = "ui1" Or m_sPropType = "i2" Or m_sPropType = "i4")
		m_sFormatFunc = Trim("" & oHtmlElement.GetAttribute("X_FORMAT_FUNCTION"))
		m_sParseFunc =  Trim("" & oHtmlElement.GetAttribute("X_PARSE_FUNCTION"))
		m_nDecimalPlaces = Trim("" & oHtmlElement.GetAttribute("X_DECIMAL_PLACES"))		
		If 0<>Len(m_nDecimalPlaces) Then
			m_nDecimalPlaces = SafeCLng(m_nDecimalPlaces)
		Else
			m_nDecimalPlaces = Null	
		End If
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
	' ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property


	'==========================================================================
	' ���������� ��������� �������� �� input'a
	Public Property Get Value
		Dim vValue
		vValue = Trim(HtmlElement.Value)
		If Len(vValue)>0 Then
			Value = vValue
		Else
			Value = Null
		End If
	End Property


	'==========================================================================
	' ������������� �������� � �������� � � xml-��������
	Public Property Let Value(vValue)
		SetFieldValue vValue
		With New GetDataArgsClass
			.SilentMode = True
			GetData .Self
		End With
	End Property
	

	'==========================================================================
	' ������������� �������������� �������� � �������� � � xml-��������
	Public Sub SetTypedValue(ByVal vValue)
		Value = ConvertTypedValueToStringRepresentation(vValue)
	End Sub
	
	'==========================================================================
	' ������������� �������������� �������� � ��������
	Public Sub SetTypedFieldValue(ByVal vValue)
		SetFieldValue ConvertTypedValueToStringRepresentation(vValue)
	End Sub

	'==========================================================================
	' ������������� �������� � ��������� ��������
	Public Sub SetData
		SetTypedFieldValue XmlProperty.nodeTypedValue
	End Sub


	'==========================================================================
	' ������������� �������� � Html ���� input
	Private Sub SetFieldValue(vValue)
		If hasValue(vValue) Then
			HtmlElement.value = vValue
		Else
			HtmlElement.value = vbNullString
		End If
	End Sub


	'==========================================================================
	' ���� � ��������� ������
	Public Sub GetData(oGetDataArgs)
		Dim vValue			' �������������� ��������
		Dim vTypedValue		' �������������� ��������
		
		vValue = Value
		If Not ValueTypeCast(vValue, vTypedValue) Then 
			SetInvalidPropertyValueErrorInfo oGetDataArgs, PropertyDescription
			Exit Sub
		End If
		' ��������� �� NOT NULL: 
		If Not ValueCheckOnNullForPropertyEditor( vTypedValue, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then 
			Exit Sub
		End If
		If Not IsNull(vTypedValue) Then
			' ��������� �� ��������� � ���������� ��������:
			If Not ValueCheckRangeForPropertyEditor(vTypedValue, m_oPropertyEditorBase, oGetDataArgs) Then 
				Exit Sub
			End If
		End If
		' ���� ������
		GetDataFromPropertyEditor vTypedValue, m_oPropertyEditorBase, oGetDataArgs
	End Sub


	'==========================================================================
	' ������ �������� ������ "������������� ��������" � ���������� ��������� GetDataArgsClass
	Private Sub SetInvalidPropertyValueErrorInfo( oGetDataArgs, sPropertyDescription  )
		With oGetDataArgs
			.ReturnValue = False
			.ErrorMessage = "������������ �������� ��������� """ & sPropertyDescription & """"
		End With
	End Sub

	
	'==========================================================================
	' �������� �������� � ������
	Public Function ConvertTypedValueToStringRepresentation(ByVal vValue)
		If 0<Len(m_sFormatFunc) Then
			Dim f: Set f = GetRef(m_sFormatFunc)
			vValue = f(vValue)	
		ElseIf (Not m_bIsInteger) and (Not IsNull(m_nDecimalPlaces)) and (Not IsNull(vValue)) Then
			vValue = Round(vValue,m_nDecimalPlaces)
			vValue = FormatNumber(vValue,m_nDecimalPlaces)
		End If
		ConvertTypedValueToStringRepresentation = "" & vValue
	End Function


	'==========================================================================
	' ������� "�����������" ���������� ���� �������� ��������
	' True ��� �������� ��������������� ��������, ����� - False;
	'	[in] vValue - ���������� �������� 
	'	[out] vTypedValue - ������������ �������������� ��������
	Public Function ValueTypeCast( ByVal vValue, ByRef vTypedValue )
		Dim bDefaultProcessing: bDefaultProcessing = True
		ValueTypeCast = False
		If 0<Len(m_sParseFunc) Then
			bDefaultProcessing = False
			Dim f: Set f = GetRef(m_sParseFunc)
			On Error Resume Next
			vValue = f(vValue)	
			If 0 <> Err.Number Then
				Err.Clear
				Exit Function
			End If
		End If
		
		If HasValue(vValue) Then		
			If Not IsNumeric(vValue) Then
				Exit Function
			End If
			
			On Error Resume Next
			vTypedValue = Eval(m_sTypeCastFunc & "(vValue)")
			If 0 = Err.Number Then
				If bDefaultProcessing Then
					If m_bIsInteger Then
						' ��������, ��� ����� �� ������� 
						' (CDlb, CLng ������������� �� ����� ������������)
						If CDbl(vValue) <> CLng(vValue) Then 
							Exit Function
						End If
					Else
						If m_sTypeCastFunc = "CCur" Then
							If Not IsCurrency(vValue) Then 
								Exit Function
							End If
						End If
						' ������ �� ������������� �������� ����������
						If	Not IsNull(m_nDecimalPlaces) Then
							vTypedValue = Round(vTypedValue,m_nDecimalPlaces)
						End If
					End If					
				End If
				ValueTypeCast = True
			End If
			On Error GoTo 0
		Else
			ValueTypeCast = True
			vTypedValue = Null
		End If	
	End Function


	'==========================================================================
	' �������������/���������� (��)�������������� ��������
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			HtmlElement.removeAttribute "X_MAYBENULL"
			HtmlElement.className = "x-editor-control-notnull x-editor-numeric-field"
		Else
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
			HtmlElement.className = "x-editor-control x-editor-numeric-field"
		End If			
	End Property


	'==========================================================================
	' �������������/���������� (��)����������� ��������� ��������
	Public Property Get Enabled
		Enabled = Not (HtmlElement.disabled)
	End Property
	Public Property Let Enabled(bEnabled)
		 HtmlElement.disabled = Not( bEnabled )
	End Property


	'==========================================================================
	' ��������� ������
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function


	'==========================================================================
	' ���������� Html �������
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
	' ���������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
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

	'==========================================================================
	' ���������� Html-������� OnBeforeDeactivate.
	' ��������: ��� ����������� �������������.
	Public Sub Internal_OnBeforeDeactivate
		With New EventArgsClass
			FireEvent "BeforeDeactivate", .Self			
		End With
		' ������������ ��������
		Dim v: v=Value
		If ValueTypeCast(v,v) Then
			SetTypedFieldValue v
		End If			
	End Sub
	
End Class
