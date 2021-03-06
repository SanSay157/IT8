Option Explicit

'==============================================================================
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	'Dim uidSelectedTender	' ������������� ���������� �������
	'Dim oResp				' ����� �� �������
	'Dim xmlCompany, xmlOrganization
	
	' �������� ��������� ������ (���� ������� ����)
	'uidSelectedTender = GetSelectedTender()

	' �������� ������ � �������
	'With New GetFilterTendersInfoRequest
	'	.m_sName = "GetFilterTendersInfo"
	'	.m_sSelectedTenderID = uidSelectedTender
	'	Set oResp = X_ExecuteCommand( .Self )
	'End With	

	' ������������� �������� ������ ����������
	'If uidSelectedTender = GUID_EMPTY Or IsEmpty(oResp.m_dtDocFeedingDate) Then
	'	oSender.XmlObject.selectSingleNode("DocFeedingBegin").nodeTypedValue = DateAdd("m", -1, Date())
	'	oSender.XmlObject.selectSingleNode("DocFeedingEnd").nodeTypedValue = ""
	'Else
	'	oSender.XmlObject.selectSingleNode("DocFeedingBegin").nodeTypedValue = DateAdd("m", -1, oResp.m_dtDocFeedingDate)
	'	oSender.XmlObject.selectSingleNode("DocFeedingEnd").nodeTypedValue = DateAdd("m", 1, oResp.m_dtDocFeedingDate)
	'End If
End Sub

'==============================================================================
' ���������� ������������� �������, ������������ ����� URL � ������� 
' ��������� SelectedTender (��� GUID_EMPTY ���� ������ ��������� ���)
Function GetSelectedTender()
	Dim sUrlParams			' ������ ����������, ������������ ����� URL
	Dim oRegExp, aMatches	' ������� ��� ������ � ����������� �����������

	sUrlParams = window.parent.location.search
	
	Set oRegExp = New RegExp
	oRegExp.Pattern = "SelectedTender=(([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})|([0-9a-fA-F]{32}))"
	oRegExp.IgnoreCase = True
	
	Set aMatches = oRegExp.Execute(sUrlParams)
	
	If aMatches.count = 0 Then
		GetSelectedTender = GUID_EMPTY
	Else
		GetSelectedTender = aMatches(0).SubMatches(0)
	End If
End Function
