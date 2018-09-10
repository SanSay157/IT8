Option Explicit

'==============================================================================
' ���������� XML-�������, ��������������� ������� "���"
Function XmlLot()
	Set XmlLot = ObjectEditor.XmlObject
End Function

'==============================================================================
' ���������� XML-�������, ��������������� ������� ����
Function XmlTender()
	Set XmlTender = Pool.GetXmlObjectByOPath(XmlLot, "Tender")
End Function

'==============================================================================
' ���������� XML-�������, ��������������� ��������� ���� �� ���
Function XmlLotParticipantOwn()
	Set XmlLotParticipantOwn = GetLotParticipantOwn(XmlLot)
End Function

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	' �������������� ���������� ����������
	InitGlobals oSender

	' �������������� ��������� ���� �� ���
	CreateLotParticipantOwn(XmlLot)
	
	' ����������� ����������� �� ���
	If Pool.GetXmlProperty(XmlLotParticipantOwn, "ParticipantOrganization").firstChild Is Nothing Then
		SetCompany()
	End If
	
	' ��������� ������ "����������� ���"
	TMS_CreateDataCalcButton()
	
	' ������������� �������� ������������� �������
	bLotMainPageInited = False
End Sub

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	Select Case oSender.CurrentPage.PageTitle
		Case "�������� ��������������"
			LotEditor_InitMainPage XmlLot
		Case "����������"
			LotEditor_InitResultsPage XmlLot
	End Select
End Sub

'==============================================================================
' ����������� ����������� ��� ��������� ���� �� ���
Sub SetCompany()
	Dim oXmlCompany				' ����������� �� ���
	Dim bSingleCompany			' ��� ���� ����� ����� ���� ����������� �� ���
	Dim sTenderCompanyID		' ������������� ��������, ������������ �� ��������� �������
	
	bSingleCompany = TMS_IsTenderParticipantOrganizationSingle(Pool, XmlTender, oXmlCompany) 
	' ���� ��� ����� ������ ���� � �� �� ����������� �� ���, ��
	' ��������� �� � ��� ��������� �� ��� � ������� ����
	If bSingleCompany Then
		' ���� ����������� �� ��� ��� �� ����������, ��������� ��������
		' �� �� ���������� URL
		If oXmlCompany Is Nothing Then
			sTenderCompanyID = ObjectEditor.QueryString.GetValue("TenderCompanyID", Null)
			' ���� �� ��������� ������� ������� ������������� ��������,
			' ��������� XML-������ ���� ����������� �� ����
			If hasValue(sTenderCompanyID) Then
				Set oXmlCompany = Pool.GetXmlObject("Organization", sTenderCompanyID, Empty)
			End If			
		End If

		' ���� � ����� ������� �������� ����������� �� ���, �� ��������� ��
		If Not oXmlCompany Is Nothing Then
			Pool.AddRelation XmlLotParticipantOwn, "ParticipantOrganization", oXmlCompany
		End If
	End If
End Sub

'==============================================================================
' ���������� ��������� ��������� "����������"
Sub OnWinnerSelectorChanged()
	LotEditor_OnWinnerSelectorChanged XmlLot
End Sub