Option Explicit

Dim g_oObjectEditor
Dim g_bPeriodSelectorInited

'==============================================================================
' ���������� ������� Load
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Set g_oObjectEditor = oSender
	
	setUpXmlObjectOfFoldersTreeFilter oSender
End Sub

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	If oSender.CurrentPage.PageTitle = "�������� ���������" And Not g_bPeriodSelectorInited Then
		' �������������� ��������� �������, ��������� � �������� �������
		InitPeriodSelector oSender
		g_bPeriodSelectorInited = True
	ElseIf oSender.CurrentPage.PageTitle = "�������/����������" Then
		enableFolders
	End If
End Sub

'==============================================================================
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim oOrganizations, oDepartments, oEmployees
	Dim dtIntervalBegin, dtIntervalEnd
	Dim bLargeInterval ' ������� ����, ��� ����� ������� �������� ���
	Dim bAllFolders ' ������� ����, ��� ����� �������� ��� �� ���� �����������
	Dim sMsg

	Set oOrganizations = oSender.Pool.GetXmlObjectsByOPath(oSender.XmlObject, "Organizations")
	Set oDepartments = oSender.Pool.GetXmlObjectsByOPath(oSender.XmlObject, "Departments")
	Set oEmployees = oSender.Pool.GetXmlObjectsByOPath(oSender.XmlObject, "Employees")
	
	If	(oOrganizations Is Nothing) And _
		(oDepartments Is Nothing) And _
		(oEmployees Is Nothing) Then
		alert "�� ������ ������ �����������."
		oEventArgs.ReturnValue = False
		Exit Sub
	End If
	
	dtIntervalBegin = oSender.XmlObject.selectSingleNode("IntervalBegin").nodeTypedValue
	dtIntervalEnd = oSender.XmlObject.selectSingleNode("IntervalEnd").nodeTypedValue
	'����� �������, ��� � ��� ����� ������� �������� ���, ���� ������� ����� ����� ������ � ����� > 3
	bLargeInterval = IsNull(dtIntervalBegin) Or IsNull(dtIntervalEnd) _
		Or DateDiff("m", dtIntervalBegin, dtIntervalEnd) >= 3
	bAllFolders = oSender.XmlObject.selectSingleNode("AllFolders").nodeTypedValue
	
	If Not bLargeInterval And Not bAllFolders Then Exit Sub
	
	sMsg = ""
	' ���� ����� ������� �������� ��� � ����� "��� ����������", �� ������� ��������������� ���������
	If bLargeInterval And bAllFolders Then
		sMsg = "����� ������� �������� ��� � �� ������� ���������� �� �����������."
	ElseIf bLargeInterval Then
		sMsg = "����� ������� �������� ���."
	ElseIf bAllFolders Then
		sMsg = "�� ������ ���������� �� �����������."
	End If
	
	sMsg = sMsg & " ��������, ����� ����� ��������� ���������� �����." _
		& vbNewLine & "�� �������, ��� ������ ����������?"
	If Not confirm(sMsg) Then
		oEventArgs.ReturnValue = False
	End If
End Sub
