Option Explicit

Dim g_bPeriodSelectorInited

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	If oSender.CurrentPage.PageTitle = "�������� ���������" And Not g_bPeriodSelectorInited Then
		' �������������� ��������� �������, ��������� � �������� �������
		InitPeriodSelector oSender
		g_bPeriodSelectorInited = True
	End If
End Sub

'==============================================================================
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim oFolder, oCustomer
	Dim dtIntervalBegin, dtIntervalEnd
	Dim nDateDetalization
	Dim bLargeInterval
	Dim sMsg
	
	Set oFolder = oSender.Pool.GetXmlObjectByOPath(oSender.XmlObject, "Folder")
	Set oCustomer = oSender.Pool.GetXmlObjectByOPath(oSender.XmlObject, "Customer")
	If (oFolder Is Nothing And oCustomer Is Nothing) Or _
		(Not oFolder Is Nothing And Not oCustomer Is Nothing) Then
		sMsg = "�� ������ ������� ���� ����������, ���� �������."
		alert sMsg
		oEventArgs.ReturnValue = False
		Exit Sub
	End If
		
	dtIntervalBegin = oSender.XmlObject.selectSingleNode("IntervalBegin").nodeTypedValue
	dtIntervalEnd = oSender.XmlObject.selectSingleNode("IntervalEnd").nodeTypedValue
	
	bLargeInterval = IsNull(dtIntervalBegin) Or IsNull(dtIntervalEnd) _
		Or DateDiff("m", dtIntervalBegin, dtIntervalEnd) >= 3
		
	If bLargeInterval Then
		nDateDetalization = oSender.XmlObject.selectSingleNode("DateDetalization").nodeTypedValue
		If (nDateDetalization = DATEDETALIZATION_ALLDATE) Or (nDateDetalization = DATEDETALIZATION_EXPENCESDATE) Then
			sMsg = "����� ������� �������� ���. ��� ����� ��������� ����������� �� ���� ����� �� ����� ��������." _
				& vbNewLine & "�������� ����������� �� �����."
			alert sMsg
			oEventArgs.ReturnValue = False
		Else
			sMsg = "����� ������� �������� ���. ��������, ����� ����� ��������� ���������� �����." _
				& vbNewLine & "�� �������, ��� ������ ����������?"
			If Not confirm(sMsg) Then
				oEventArgs.ReturnValue = False
			End If
		End If
	End If
End Sub
