'===============================================================================
'���������� ��� ��������� ������� ������ "������ �����������"
Option Explicit

Dim g_bPeriodSelectorInited '������� ���������� ������������ �������, ��������� � �������� ������� 
Dim g_oObjectEditor '�������� ������� - ���� FilterReportActivityList (������ ������)

'==============================================================================
' ���������� ������� Load
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Set g_oObjectEditor = oSender
	
	setUpXmlObjectOfFoldersTreeFilter oSender
End Sub

'==============================================================================
'���������� ������� PageStart
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
' ���������� ������� OnValidate
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim dtIntervalBegin, dtIntervalEnd ' ���� ������ � ����� �������� �������, �� �������� �������� �����
	Dim bLargeInterval ' ������� ����, ��� ����� ������� �������� ���
	Dim bAllFolders ' ������� ����, ��� ����� �������� ��� �� ���� �����������
	Dim sMsg ' ����� ����������� ���������
	
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