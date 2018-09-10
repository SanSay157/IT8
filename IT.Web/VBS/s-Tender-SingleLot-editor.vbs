Option Explicit

'==============================================================================
' ���������� XML-�������, ��������������� ������� "������"
Function XmlTender()
	Set XmlTender = ObjectEditor.XmlObject
	
End Function

'==============================================================================
' ���������� XML-�������, ��������������� ������������� ���� �������
Function XmlLot()
	Set XmlLot = Pool.GetXmlObjectByOPath(XmlTender, "Lots")
End Function

'==============================================================================
' ���������� XML-�������, ��������������� ��������� ���� �� ���
Function XmlLotParticipantOwn()
	Set XmlLotParticipantOwn = GetLotParticipantOwn(XmlLot)
End Function

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Dim oXmlTenderLotsProp	' XML-�������, ��������������� �������� "����"
	Dim oXmlTender			' XML-������� �������
	Dim oXmlLot				' XML-������� ����

	' �������������� ���������� ����������
	InitGlobals oSender

	Set oXmlTender = XmlTender()
	
	' ����������� ���
	Set oXmlTenderLotsProp = Pool.GetXmlProperty(oXmlTender, "Lots")
	If oXmlTenderLotsProp.firstChild Is Nothing Then
		Set oXmlLot = Pool.CreateXmlObjectInPool("Lot")
		Pool.AddRelation oXmlTender, oXmlTenderLotsProp, oXmlLot
	End If
	
	' �������������� ��������� ���� �� ���
	CreateLotParticipantOwn XmlLot

	' ��������� ������ "����������� ���"
	TMS_CreateDataCalcButton()
	
	' ������������� �������� ������������� �������
	bLotMainPageInited = False
	bTenderMainPageInited = False
End Sub

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	Select Case oSender.CurrentPage.PageTitle
		Case "�������� ���������"
			LotEditor_InitMainPage XmlLot
			TenderEditor_InitMainPage XmlTender

		Case "����������"
			LotEditor_InitResultsPage XmlLot
	End Select
End Sub

'==============================================================================
Sub usrXEditor_OnPageEnd(oSender, oEventArgs)
	' XML-�������, ��������������� ������� "�����"
	Dim oXmlSum1, oXmlSum2
	' XML-�������, ��������������� �������� "����� ����������� ����������"
	Dim oXmlTenderParticipantPriceProp
	Dim oXmlTemp
	Dim oXmlTender				' XML-������� �������
	Dim oXmlLot					' XML-������� ����
	Dim oXmlLotParticipantOwn	' XML-������� ��������� ���� �� ���

	' �������� �������
	Set oXmlTender = XmlTender()
	Set oXmlLot = XmlLot()
	Set oXmlLotParticipantOwn = XmlLotParticipantOwn()
	
	If oSender.CurrentPage.PageTitle = "�������� ���������" Then
		' ����������� �������� "��������" ��� ����
		Pool.SetPropertyValue _
			Pool.GetXmlProperty(oXmlLot, "Name"), _
			Pool.GetPropertyValue(oXmlTender, "Name")
		
		' ����������� �������� "�����" ��� ����
		Pool.SetPropertyValue _
			Pool.GetXmlProperty(oXmlLot, "Number"), _
			Pool.GetPropertyValue(oXmlTender, "Number")
	End If
End Sub

'==============================================================================
Sub usr_Lot_LotParticipants_ObjectsElementsList_OnBeforeEdit( oSender, oEventArgs )
	' ��������, ��� �������� ���������� �� ������������ �������
	oEventArgs.UrlArguments = "SingleLot=1"
End Sub

'==============================================================================
Sub usr_Lot_LotParticipants_ObjectsElementsList_OnBeforeCreate( oSender, oEventArgs )
	' ��������, ��� �������� ���������� �� ������������ �������
	oEventArgs.UrlArguments = "SingleLot=1"
End Sub

'==============================================================================
' ���������� ��������� ��������� "����������"
Sub OnWinnerSelectorChanged()
	LotEditor_OnWinnerSelectorChanged XmlLot
End Sub