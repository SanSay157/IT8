Option Explicit

Dim g_bPeriodSelectorInited

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	Dim nDetalization
	
	If oSender.CurrentPage.PageTitle = "�������� ���������" And Not g_bPeriodSelectorInited Then
		' �������������� ��������� �������, ��������� � �������� �������
		InitPeriodSelector oSender
		g_bPeriodSelectorInited = True
	
	ElseIf oSender.CurrentPage.PageTitle = "������" Then
		nDetalization = oSender.XmlObject.selectSingleNode("LossDetalization").nodeTypedValue
		' ����������� �� �����
		If nDetalization = LOSSDETALIZATION_BYDATES Then
			enablePropertyEditor oSender, "ShowColumnTimeLossCause", False
			enablePropertyEditor oSender, "ShowColumnDescr", False
		' ����������� �� ��������� ���������
		Else
			enablePropertyEditor oSender, "ShowColumnTimeLossCause", True
			enablePropertyEditor oSender, "ShowColumnDescr", True
		End If

	End If
End Sub

'==============================================================================
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim dtIntervalBegin, dtIntervalEnd
	Dim sMsg
	
	dtIntervalBegin = oSender.XmlObject.selectSingleNode("IntervalBegin").nodeTypedValue
	dtIntervalEnd = oSender.XmlObject.selectSingleNode("IntervalEnd").nodeTypedValue
	
	If IsNull(dtIntervalBegin) Or IsNull(dtIntervalEnd) _
		Or DateDiff("m", dtIntervalBegin, dtIntervalEnd) >= 3 Then
		sMsg = "����� ������� �������� ���. ��������, ����� ����� ��������� ���������� �����." _
			& vbNewLine & "�� �������, ��� ������ ����������?"
		If Not confirm(sMsg) Then
			oEventArgs.ReturnValue = False
			Exit Sub
		End If
	End If
	
	' ���� ����������� �� �����, �� �� ����� ���������� �������������� �������
	If oSender.XmlObject.selectSingleNode("LossDetalization").nodeTypedValue = LOSSDETALIZATION_BYDATES Then
		setPropertyValue oSender, "ShowColumnTimeLossCause", False
		setPropertyValue oSender, "ShowColumnDescr", False
	End If
End Sub

'==============================================================================
' ���������/��������� �������� ��������
' [in] oObjectEditor	- ObjectEditorClass, �������� �������
' [in] sPropName		- String, OPath �������
' [in] bEnable		- As Boolean, ������� ����������� ���������
Sub enablePropertyEditor(oObjectEditor, sPropName, bEnable)
	Dim oPropEditor 
	
	Set oPropEditor = oObjectEditor.CurrentPage.GetPropertyEditor( _
		oObjectEditor.Pool.GetXmlProperty( oObjectEditor.XmlObject, sPropName) )
	
	If bEnable Then
		' �� ���������� "���� �����������", ��� ��� ���������� ����������
		' � ���������� ����� ���� �� �����
		oPropEditor.ParentPage.EnablePropertyEditorEx oPropEditor, True, True
	Else
		oPropEditor.ParentPage.EnablePropertyEditor oPropEditor, False
	End If
End Sub

'==============================================================================
' ������������� �������� �������� ��������
' [in] oObjectEditor	- ObjectEditorClass, �������� �������
' [in] sPropName		- String, OPath �������
' [in] vValue As Variant - �������� ��������
Sub setPropertyValue(oObjectEditor, sPropName, ByVal vValue)
	Dim oXmlProperty
	
	Set oXmlProperty = oObjectEditor.Pool.GetXmlProperty( _
		oObjectEditor.XmlObject, sPropName )
	
	oObjectEditor.Pool.SetPropertyValue oXmlProperty, vValue
End Sub

