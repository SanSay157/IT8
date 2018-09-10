Option Explicit
'*******************************************************************************
' ����������:	
' ����������:	����������� ���������� ������������ UI-������������� ���������� 
'				�������� ����� ������ (i:bits)
'*******************************************************************************

' �������:
'	Changed (EventArg: ChangeEventArgsClass)
'		- ��������� ��������� (Checked/Unchecked) 
'	Accel (EventArg: AccelerationEventArgsClass)
'		- ������� ���������� ������ 
Class XPEFlagsClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_bEnabled					' As Boolean
	
	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Changed,Accel", "Flags"
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
	' ���������� �������������� �������� �� PE
	Public Property Get Value
		Dim nFlagsValue		' ��������� �������� ������� ������
		Dim oBitFlagElement	' ���� HTML-�������; ������, �����. �������� �����
		
		' �������� ���������, ������������� �������� �������, � ��� ������ ���� 
		' �� ���� ���� �� ����������, ��������� ������� (���������� ����� ��������
		' �������� ������ ��-NULL-����):
		nFlagsValue = 0
		' ���������� ��� check-box-� ������, �������� ��, ��� ������� ����������� 
		' ������
		For Each oBitFlagElement In HtmlElement.all.tags("INPUT")
			If oBitFlagElement.checked Then
				' ��������� �������� �����; ���� �������� �������� ����� Eval, �.�. ��� 
				' ����� ���� ��������� � ���������� ��� ����������� ���������:
				'		<i:bit n="����">MY_COOL_FLAG</i:bit>
				' ��� MY_COOL_FLAG �������� ���-�� � ���������� VBS, � ����� �� ���������� 
				' ��� �� �������� ����������� � ������� ExpBitValue
				nFlagsValue = CLng(nFlagsValue) Or CLng( Eval( oBitFlagElement.ExpBitValue ) )
			End If
		Next
		Value = nFlagsValue 
	End Property
	

	'==========================================================================
	' ������������� �������� � �������� � � xml-��������
	Public Property Let Value(vValue)
		SetFlags vValue
		With New GetDataArgsClass
			.SilentMode = True
			GetData .Self
		End With
	End Property

	
	'==========================================================================
	' ������������� �������� � ����������
	Public Sub SetData
		SetFlags XmlProperty.nodeTypedValue
	End Sub

	
	'==========================================================================
	Private Sub SetFlags(vValue)
		Dim oBitFlagElement	' ���� HTML-�������; ������, �����. �������� �����
		
		If Not HasValue(vValue) Then 
			vValue = CLng(0)
		Else
			vValue = CLng(vValue)
		End If		
		' ������� ������...
		For Each oBitFlagElement In HtmlElement.all.tags("INPUT")
			oBitFlagElement.Checked = (CLng(Eval(oBitFlagElement.ExpBitValue)) and vValue)
		Next
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
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			HtmlElement.removeAttribute "X_MAYBENULL"
		Else
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
		End If			
	End Property

	
	'==========================================================================
	' �������������/���������� (��)����������� ��������� ��������
	Public Property Get Enabled
		 Enabled = m_bEnabled
	End Property
	Public Property Let Enabled(bEnabled)
		m_bEnabled = bEnabled
		Dim oBitFlagElement		' HTML-������� ������ checkbox'a
		Dim oLabelElement		' HTML-������� ���������������� label'a 
		Dim sClasses
		
		' ��������� / ������ ���������� ��� ���� ������� �����
		For Each oBitFlagElement In HtmlElement.all.tags("INPUT")
			oBitFlagElement.disabled = Not( bEnabled )
			
			Set oLabelElement = HtmlElement.all( oBitFlagElement.ID & "Label")
			sClasses = " " & oLabelElement.className & " "
			If bEnabled Then
				If InStr(sClasses, " x-editor-flags-disabled ") > 0 Then
					sClasses = Replace(sClasses, " x-editor-flags-disabled ", "")
				End If
			Else
				If InStr(sClasses, " x-editor-flags-disabled ") = 0 Then
					sClasses = sClasses & " x-editor-flags-disabled"
				End If
			End If
			oLabelElement.className = sClasses
		Next
	End Property

	
	'==========================================================================
	' ��������� ������
	Public Function SetFocus
		Dim oBitFlagElement	' HTML-������� ������ ������ 
		
		' ���������� �������, ��� ����� �� ����������
		SetFocus= False
		
		' ������� ���������� ����� �� ���� �� ������� �����;
		' ���� ����������� �� ��� ���, ���� ����� �� ����� ����������
		For Each oBitFlagElement In HtmlElement.all.tags("INPUT")
			If X_SafeFocus( oBitFlagElement ) Then
				SetFocus = True
				Exit For
			End If
		Next
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
	' ���� ��� = 0, �� ���� ��������, ���� 1, �� ������������
	Public Sub ShowFlagsByMask(nMask)
		Dim oBitFlagElement	' HTML-������� ������ ������ 
		nMask = CLng(nMask)
		For Each oBitFlagElement In HtmlElement.all.tags("INPUT")
			If (CLng(Eval(oBitFlagElement.ExpBitValue)) And nMask) Then
				oBitFlagElement.parentNode.style.display = "block"
			Else
				oBitFlagElement.parentNode.style.display = "none"
			End If
		Next
	End Sub

	
	'==========================================================================
	' ���������� html-������� OnClick �� checkbox'�. ��������: ��� ����������� �������������!
	'	[in] sID - ������������� checkbox'a
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
	
	
	'==========================================================================
	' ���������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub
End Class
