Option Explicit
'*******************************************************************************
' ����������:	
' ����������:	����������� ���������� ������������ UI-������������� ���������� 
'				�������� ����-������� (vt="datetime")
'*******************************************************************************

' �������:
'	Changed (EventArg: ChangeEventArgsClass)
'		- ��������� ��������� (Checked/Unchecked) 
'	Accel (EventArg: AccelerationEventArgsClass)
'		- ������� ���������� ������ 
Class XPEDateTimeClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_bKeyUpEventProcessing		' As Boolean - ������� ��������� ActiveX-������� OnKeyUp ��� "����������" �����
	
	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing  = False
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Changed,Accel", "DateTime"
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
	' ���������� �������������� �������� �� �������� ����
	Public Property Get Value
		Dim sDateType	' ������ ������������� ����-������� (date, dateTime, time)
		Dim dtValue		' �������� �������� - ����-�����
		
		dtValue = HtmlElement.value
		' �������� ������: ��������, ��������� � date-time-picker, � ��� ��������
		' DS-�������� (date, dateTime ��� time):
		sDateType = HtmlElement.GetAttribute("X_DATETYPE")
		' ��������� ��� DS-��������: ���� ��� "date" - ������ � �������� "���������" �����:
		If "date"=sDateType And hasValue(dtValue) Then  dtValue = GetDateValue( CDate(dtValue) )
		Value = dtValue
	End Property

		
	'==========================================================================
	' ������������� �������� � �������� � � xml-��������
	Public Property Let Value(vValue)
		HtmlElement.value = vValue
		With New GetDataArgsClass
			.SilentMode = True
			GetData .Self
		End With
	End Property

		
	'==========================================================================
	' ������������� �������� � ��������� ��������
	Public Sub SetData
		HtmlElement.value = XmlProperty.nodeTypedValue 
	End Sub
	

	'==========================================================================
	' ���� � ��������� ������
	Public Sub GetData(oGetDataArgs)
	    Dim vValue
	    vValue = Value
		' ��������� �� NOT NULL: 
		If ValueCheckOnNullForPropertyEditor( vValue, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then 
			' ������ �������� � XML:
			GetDataFromPropertyEditor vValue, m_oPropertyEditorBase, oGetDataArgs
		End If
	End Sub
	

	'==========================================================================
	' �������������/���������� (��)�������������� ��������
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			HtmlElement.removeAttribute "X_MAYBENULL"
			HtmlElement.className = "x-editor-control-notnull x-editor-datetime-field"
		Else
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
			HtmlElement.className = "x-editor-control x-editor-datetime-field"
		End If			
	End Property
	

	'==========================================================================
	' �������������/���������� (��)����������� ��������� ��������
	Public Property Get Enabled
		 Enabled = HtmlElement.object.Enabled
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.object.Enabled = bEnabled
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
	End Sub	


	'==========================================================================
	' ���������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	


	'==========================================================================
	' ���������� Html ������� OnDateTimeChange �� ��������. ����������� ��������� �� ��������
	' ��������: ��� ����������� �������������.
	Public Sub Internal_OnChangeAsync()
		With New GetDataArgsClass
			.SilentMode = True
			GetData .Self()
		End With
		FireEvent "Changed", New EventArgsClass
	End Sub


	'==========================================================================
	' ���������� ActiveX-������� onKeyUp (������� �������). ����������� ��������� �� �������� 
	' ��������: ��� ����������� �������������.
	Public Sub Internal_OnKeyUpAsync(nKeyCode, nFlags)
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
