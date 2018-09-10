Option Explicit

'==============================================================================
Const MSG_NO_PARTICIPANT = "�������� ������� �� ��� ����������� � �������� ����"
Const MSG_NO_PARTICIPANT_SINGLELOT = "� ����������� ������� �������� �� ��� ����������� � �������� �������"

Const WRNG_LOTGAINED_WINNER_NOTOWN = "� ���������� ���� ��� ��������� �� �� ��� ��������������� ������ ""����������"""
Const WRNG_LOTGAINED_LOSER_OWN = "� ���������� ���� ��� ��������� �� ��� ��������������� ������ ""�����������"""
Const WRNG_LOTLOSED_WINNER_OWN = "� ����������� ���� ��� ��������� �� ��� ��������������� ������ ""����������"""

Const SELECTOR_VALUE_WINNER	= "winner"	' �������� ������ ��������� "����������"
Const SELECTOR_VALUE_LOSER	= "loser"	' �������� ������ ��������� "�����������"

'==============================================================================
Dim IsSingleLot		' �������� ��������� �� ������������ �������

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	' �������������� ���������� ����������
	InitGlobals oSender
	
	' �������� ������� ����, ��� �������� ��������� �� ������������ �������
	IsSingleLot = CBool(ObjectEditor.QueryString.GetValue("SingleLot", False))
End Sub

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	Dim oOrganizationEditor
	
	' ���� �������� ��������� �� ������������ �������,
	' "����������" ���������� � ������� � ����
	If IsSingleLot Then
		trLotInfo.style.display = "none"
		captionTenderInfo.innerText = "���������� � �������/����"
	' ����� ���������� ���������� � ������� � ���� ���������
	Else
		trLotInfo.style.display = "inline"
	End If
	
	' ���� ��� �������� ������� �� ���
	If getParticipationType() = PARTICIPATIONS_PARTICIPANT Then
		enablePropertyEditor "ParticipantOrganization", False
		enablePropertyEditor "ParticipationType", False
		enablePropertyEditor "Declined", False
	End If
	
	enableCompetitorEditors()

	' ��������������� ��������� �������� "������ ���������� �������� ����������� ����������"
	Set oOrganizationEditor = TMS_GetPropertyEditor( ObjectEditor, Nothing, "ParticipantOrganization" )
	oOrganizationEditor.EventEngine.AddHandlerForEvent "BeforeChangeTempOrgOnConst", Nothing, "OnBeforeChangeTempOrgOnConst"

End Sub

'==============================================================================
Sub OnBeforeChangeTempOrgOnConst(oSender, oMenuEventArgs)
	oMenuEventArgs.Menu.Macros.Item("LotParticipantID") = oSender.ObjectEditor.XmlObject.getAttribute("oid")
	oMenuEventArgs.Menu.Macros.Item("TenderID") = Pool.GetXmlObjectByOPath(ObjectEditor.XmlObject, "Lot.Tender").getAttribute("oid")
End Sub

'==============================================================================
' ���������� ��� ������� ��� ������� �������, ����� ��� �� ����
Function getParticipationType()
	getParticipationType = Pool.GetPropertyValue(ObjectEditor.XmlObject, "ParticipationType")
End Function

'==============================================================================
' ���������� ��������� ���� ��� ������� �������, ����� ��� �� ����
Function getLotState()
	getLotState = Pool.GetPropertyValue(ObjectEditor.XmlObject, "Lot.State")
End Function

'==============================================================================
' ���������/��������� �������� ��������
' [in] sPropName	- ������������ ��������
' [in] bEnable		- ������� ����������� ��������� ��������
Sub enablePropertyEditor(sPropName, bEnable)
	Dim oPropEditor		' �������� ��������

	Set oPropEditor = TMS_GetPropertyEditor( ObjectEditor, Nothing, sPropName )

	TMS_EnablePropertyEditor oPropEditor, bEnable
End Sub

'==============================================================================
Sub usr_LotParticipant_ParticipationType_SelectorCombo_OnChanging( oSender, oEventArgs)
	Dim oPropEditor		' �������� ��������
	' ������ �������� ��� ������� "��������" - �� ������ ����������
	' � ��������� ���� (��� ������������ �������)
	If oEventArgs.NewValue = PARTICIPATIONS_PARTICIPANT Then
		If IsSingleLot Then
			alert MSG_NO_PARTICIPANT_SINGLELOT
		Else
			alert MSG_NO_PARTICIPANT
		End If
       
       	' ����������� ������ �������� � ���������
      	Set oPropEditor = TMS_GetPropertyEditor( ObjectEditor, Nothing, "ParticipationType" )
		oPropEditor.SetData
		' ������ ��������� ��������
		oEventArgs.ReturnValue = False
	End If
End Sub

'==============================================================================
Sub usr_LotParticipant_ParticipationType_SelectorCombo_OnChanged( oSender, oEventArgs)
	enableCompetitorEditors()
End Sub

'==============================================================================
' ���������/��������� ��������� ������� "������� ������" � "���������� ����������"
' � ����������� �� ���� �������
Sub enableCompetitorEditors()
	Dim nParticipationType	' ��� �������
	
	nParticipationType = getParticipationType()

	' ���� ��� ������� "����������"
	If nParticipationType = PARTICIPATIONS_HELPER Then
		enablePropertyEditor "LossReason", True
		enablePropertyEditor "HelperContactInfo", True
	Else
		enablePropertyEditor "LossReason", False
		enablePropertyEditor "HelperContactInfo", False
	End If
End Sub

'==============================================================================
' ���������� ��������� ��������� ������� ���������
Sub OnStateChanged()
	Dim xmlWinnerProp		' XML-������� �������� "����������"
	Dim nLotState			' ��������� ����
	Dim nParticipationType	' ��� �������
	Dim sSelectorValue		' ��������� �������� � ���������
	Dim xmlLotParticipants	' As IXMLDOMNodeList, ��� ��������� ����
	Dim xmlLotParticipant	' As IXMLDOMNode, �������� ����
	Dim xmlLot
	
	sSelectorValue = document.all("StateSelector").Value
	nLotState = getLotState()
	nParticipationType = getParticipationType()
	
	' ������ ��������������
	If nLotState = LOTSTATE_WASGAIN _
		And sSelectorValue = SELECTOR_VALUE_WINNER _
		And nParticipationType <> PARTICIPATIONS_PARTICIPANT Then
		alert WRNG_LOTGAINED_WINNER_NOTOWN
	ElseIf nLotState = LOTSTATE_WASGAIN _
		And sSelectorValue <> SELECTOR_VALUE_WINNER _
		And nParticipationType = PARTICIPATIONS_PARTICIPANT Then
		alert WRNG_LOTGAINED_LOSER_OWN
	ElseIf nLotState = LOTSTATE_WASLOSS _
		And sSelectorValue = SELECTOR_VALUE_WINNER _
		And nParticipationType = PARTICIPATIONS_PARTICIPANT Then
		alert WRNG_LOTLOSED_WINNER_OWN
	End If	
	
	' �������� XML-������� �������� "����������"
	Set xmlWinnerProp = Pool.GetXmlProperty(ObjectEditor.XmlObject, "Winner")
	
	' � ����������� �� ���������� �������� � ���������
	' ������������� �������� �������� "����������"
	If sSelectorValue <> SELECTOR_VALUE_WINNER Then
		Pool.SetPropertyValue xmlWinnerProp, False
	Else
		' ������� ��� ���� ���������� ���� ������� ��������
		' ������� "����������" � False
		Set xmlLotParticipants = Pool.GetXmlObjectsByOPath(ObjectEditor.XmlObject, "Lot.LotParticipants")
		For Each xmlLotParticipant In xmlLotParticipants
			Pool.SetPropertyValue Pool.GetXmlProperty(xmlLotParticipant, "Winner"), False
		Next
		' ��� �������������� ��������� ���� ���������
		' �������� �������� "����������" � True
		Pool.SetPropertyValue xmlWinnerProp, True
	End If
	Set xmlLot  = Pool.GetXmlObjectByOPath(ObjectEditor.XmlObject, "Lot")
	If (nParticipationType = PARTICIPATIONS_PARTICIPANT) Then
	    If (sSelectorValue = SELECTOR_VALUE_WINNER) Then
            Pool.SetPropertyValue Pool.GetXmlProperty(xmlLot, "State"), LOTSTATE_WASGAIN   
        Else
            Pool.SetPropertyValue Pool.GetXmlProperty(xmlLot, "State"), LOTSTATE_WASLOSS
        End If
    Else
        If (sSelectorValue = SELECTOR_VALUE_WINNER) Then
            Pool.SetPropertyValue Pool.GetXmlProperty(xmlLot, "State"), LOTSTATE_WASLOSS  
        End If
    End If
    
	' �������� ���� ���� ������ � ����������� �� �������� ���������
	Select Case sSelectorValue
		Case SELECTOR_VALUE_WINNER
			tblParticipantInfo.className = "x-editor-subtable-green"
		Case SELECTOR_VALUE_LOSER
			tblParticipantInfo.className = "x-editor-subtable-red"
		Case Else
			tblParticipantInfo.className = "x-editor-subtable-blue"
	End Select
		
End Sub

