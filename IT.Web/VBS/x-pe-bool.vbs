'*******************************************************************************
' ����������:	
' ����������:	����������� ���������� ������������ UI-������������� ���������� 
'				����������� �������� (vt="boolean")
'*******************************************************************************
' �������:
'	Changed (EventArg: ChangeEventArgsClass)
'		- ��������� ��������� (Checked/Unchecked) 
'	Accel (EventArg: AccelerationEventArgsClass)
'		- ������� ���������� ������ 
Class XPEBoolClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	
	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Changed,Accel", "Bool"
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
	' ���������� �������������� �������� �� checkbox'a
	' ���� �� �������, ������������ 1, ����� 0
	Public Property Get Value
		Value = CBool(HtmlElement.checked)
	End Property

	
	'==========================================================================
	' ������������� �������� � �������� � � xml-��������
	Public Property Let Value(vValue)
		With New ChangeEventArgsClass
			.OldValue = XmlProperty.nodeTypedValue
			.NewValue = vValue
			' ������� �������� � Html
			SetChechBoxValue vValue
			' ������� �������� � XML-��������
			With New GetDataArgsClass
				.SilentMode = True
				GetData .Self
			End With
			FireEvent "Changed", .Self()
		End With
	End Property


	'==========================================================================
	' ������������� �������� � ��������� ��������
	Public Sub SetData
		SetChechBoxValue XmlProperty.nodeTypedValue 
	End Sub


	'==========================================================================
	' ������������� �������� � checkbox'e
	Private Sub SetChechBoxValue(vValue)
		If hasValue(vValue) Then
			HtmlElement.checked = vValue
		Else
			HtmlElement.checked = False
		End If
	End Sub

	
	'==========================================================================
	' ���� � ��������� ������
	Public Sub GetData(oGetDataArgs)
		' ������ �������� � XML:
		GetDataFromPropertyEditor Value, m_oPropertyEditorBase, oGetDataArgs
	End Sub

	
	'==========================================================================
	' �������������/���������� (��)�������������� ��������
	Public Property Get Mandatory
		Mandatory = True 
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory <> True Then _
			Err.Raise -1, "", "�������� ���� Boolean ������ ���� ������������"
	End Property

	
	'==========================================================================
	' �������������/���������� (��)����������� ��������� ��������
	Public Property Get Enabled
		 Enabled = Not HtmlElement.disabled
	End Property
	Public Property Let Enabled(bEnabled)
		Dim sClasses
		
		HtmlElement.disabled = Not( bEnabled )
		sClasses = " " & LabelElement.className & " "
		If bEnabled Then
			If InStr(sClasses, " x-editor-flags-disabled ") > 0 Then
				sClasses = Replace(sClasses, " x-editor-flags-disabled ", "")
			End If
		Else
			If InStr(sClasses, " x-editor-flags-disabled ") = 0 Then
				sClasses = sClasses & " x-editor-flags-disabled"
			End If
		End If
		LabelElement.className = sClasses
	End Property

	
	'==========================================================================
	' ��������� ������
	Public Function SetFocus
		SetFocus = X_SafeFocus(HtmlElement)
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
	End Sub	


	'==========================================================================
	' ���������� Html-������� OnClick �� ��������. ��������: ��� ����������� �������������.
	Public Sub Internal_OnClick()
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

	'==========================================================================
	' ���������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	
	
	
	'==========================================================================
	' ���������� Html-������� LABEL ��� ��������
	Public Property Get LabelElement
		Set LabelElement = HtmlElement.parentElement.all(HtmlElement.ID & "Caption")
	End Property

		
	'==========================================================================
	' ���������� ����� LABEL'a ��� ��������
	Public Property Get LabelText
		LabelText = LabelElement.innerText
	End Property

		
	'==========================================================================
	' ������������� ����� LABEL'a ��� ��������
	Public Property Let LabelText(sText)
		LabelElement.innerText = sText
	End Property
End Class
