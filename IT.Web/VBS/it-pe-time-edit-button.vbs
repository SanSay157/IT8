Class PETimeEditButtonClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_bMandatory
	
	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim sPropType		' ��� ��������
		
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Changed", "TimeEditButton"
		sPropType = m_oPropertyEditorBase.PropertyMD.getAttribute("vt")
		If Not CBool(sPropType = "ui1" Or sPropType = "i2" Or sPropType = "i4") Then
			Err.Raise -1, "", "PE ����� �������������� ������ ��� ����� ������� (ui1, i2, i4)"
		End If
'		If IsNull(Value) Then Value = 0
		m_bMandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
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
	' ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property

	
	'==========================================================================
	' ���������� �������������� �������� �� checkbox'a
	' ���� �� �������, ������������ 1, ����� 0
	Public Property Get Value
		Value = XmlProperty.nodeTypedValue
	End Property

	
	'==========================================================================
	' ������������� �������� � �������� � � xml-��������
	Public Property Let Value(vValue)
		
		With New ChangeEventArgsClass
			.OldValue = XmlProperty.nodeTypedValue
			.NewValue = vValue
			' ������� �������� � Html
			updateButtonTitle vValue
			ObjectEditor.SetPropertyValue XmlProperty, vValue
			FireEvent "Changed", .Self()
		End With
	End Property


	'==========================================================================
	' ������������� �������� � ��������� ��������
	Public Sub SetData
		updateButtonTitle XmlProperty.nodeTypedValue 
	End Sub


	'==========================================================================
	' ������������� ������������ ������
	Private Sub updateButtonTitle(ByVal vValue)
		If IsNull(vValue) Then vValue = 0
		HtmlElement.value = FormatTimeString(vValue)
	End Sub

	
	'==========================================================================
	' ���� � ��������� ������
	Public Sub GetData(oGetDataArgs)
		' ���� ������ ���������� ��� ��������� ��������
		
		' ��������� �� NOT NULL: 
		If ValueCheckOnNullForPropertyEditor( Value, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then 
			' ��������� �� ��������� � ���������� ��������:
			ValueCheckRangeForPropertyEditor Value, m_oPropertyEditorBase, oGetDataArgs
		End If
	End Sub

	
	'==========================================================================
	' �������������/���������� (��)�������������� ��������
	Public Property Get Mandatory
		Mandatory = m_bMandatory
	End Property
	Public Property Let Mandatory(bMandatory)
		m_bMandatory = bMandatory
	End Property

	
	'==========================================================================
	' �������������/���������� (��)����������� ��������� ��������
	Public Property Get Enabled
		 Enabled = Not HtmlElement.disabled
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.disabled = Not( bEnabled )
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
	' IDisposable: ��������� ������
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
	End Sub	


	'==========================================================================
	' ���������� Html-������� OnClick �� ��������. ��������: ��� ����������� �������������.
	Public Sub Internal_OnClick()
		Dim vOldValue		' ������� �������� 
		
		vOldValue = Value
		' ������� ������ � ������� ����, ����� � �����
		' � ������ �������� ������ �� 3-� ����������: ������� ��������, ���-�� ����� � ��� � �������� ��������
		vRet = X_ShowModalDialogEx( "p-TimeChange.aspx", _
			Array( vOldValue, GetHoursInDay(), m_oPropertyEditorBase.PropertyDescription), _
			"dialogWidth:400px;dialogHeight:200px;help:no;border:thin;center:yes;status:no")
		If Not HasValue(vRet) Then Exit Sub
		' ������� ��������� �������� � xml-��������
		ObjectEditor.SetPropertyValue XmlProperty, vRet
		' ������� �������������
		updateButtonTitle vRet
		
		With New ChangeEventArgsClass
			.OldValue = vOldValue 
			.NewValue = CLng(vRet)
			FireEvent "Changed", .Self()
		End With
	End Sub
	
	
	'==========================================================================
	' ���������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Nothing, oEventArgs
	End Sub	
End Class