Option Explicit

'==============================================================================
Dim bLotMainPageInited		' �������� "�������� ���������"	�������������������

'==============================================================================
' ������� � ���� ��������� ���� �� ���
' [in] oXmlLot - XML-������� ����
' [out] - XML-������� ���������� �������� ���� �� ���
Function CreateLotParticipantOwn( oXmlLot )
	Dim oXmlLotParticipantOwn	' XML-�������, ��������������� ������� "�������� ����" (�� ���)
	Dim oXmlLotParticipantsProp	' XML-�������, ��������������� �������� "��������� ����"
	Dim oXmlTemp
	
	' �������� �������� "��������� ����"
	Set oXmlLotParticipantsProp = Pool.GetXmlProperty( oXmlLot, "LotParticipants")
	
	' ����������� ��������� ����
	If oXmlLotParticipantsProp.firstChild Is Nothing Then
		Set oXmlLotParticipantOwn = Pool.CreateXmlObjectInPool("LotParticipant")
		Pool.SetPropertyValue _
			Pool.GetXmlProperty(oXmlLotParticipantOwn, "ParticipationType"), _
			PARTICIPATIONS_PARTICIPANT
		Pool.AddRelation oXmlLot, oXmlLotParticipantsProp, oXmlLotParticipantOwn
	Else
		Set oXmlLotParticipantOwn = Nothing
		For Each oXmlTemp In Pool.GetXmlObjectsByOPath(oXmlLot, "LotParticipants")
			If Pool.GetPropertyValue(oXmlTemp, "ParticipationType") = PARTICIPATIONS_PARTICIPANT Then
				Set oXmlLotParticipantOwn = oXmlTemp
				Exit For
			End If			
		Next
	End If
	
	Set CreateLotParticipantOwn = oXmlLotParticipantOwn
End Function

'==============================================================================
' ���������� ��������� ���� �� ���
' [in] oXmlLot - XML-������� ����
' [out] - XML-������� ���������� �������� ���� �� ���
Function GetLotParticipantOwn( oXmlLot )
	Dim oXmlTemp

	For Each oXmlTemp In Pool.GetXmlObjectsByOPath(oXmlLot, "LotParticipants")
		If Pool.GetPropertyValue(oXmlTemp, "ParticipationType") = PARTICIPATIONS_PARTICIPANT Then
			Set GetLotParticipantOwn = oXmlTemp
			Exit Function
		End If			
	Next
End Function

'==============================================================================
' �������������� ��������� ������� �� ������� ��������
' [in] oXmlLot - XML-������� ����
Sub LotEditor_InitMainPage( oXmlLot )
	' ���� �������� ��� �� �������������������
	If Not bLotMainPageInited Then
		' �������������� ��������� ������� "�������� �������",
		' "�������� �����������" � "���� ��������� ���������� ����������"
		TMS_InitAcquaintedEmployeeHandler _
			TMS_GetPropertyEditor( ObjectEditor, oXmlLot, "Manager" ), _
			TMS_GetPropertyEditor( ObjectEditor, oXmlLot, "MgrIsAcquaint" ), _
			TMS_GetPropertyEditor( ObjectEditor, oXmlLot, "MgrDocsGettingDate" )

		bLotMainPageInited = True
	End If
End Sub

'==============================================================================
' �������������� �������� "����������"
' [in] oXmlLot - XML-������� ����
Sub LotEditor_InitResultsPage( oXmlLot )
	Dim nLotState		' ��������� ����
	Dim bWinnerDisabled	' ������ "����������" �������������
	Dim bLoserDisabled	' ������ "�����������" �������������
	DIm bFolderDisabled	' ������ "����� � IT" �������������
	Dim oXmlTemp

	' �������� ��������� ����
	nLotState = Pool.GetPropertyValue(oXmlLot, "State")
	
	' ���� ��������� ���� "�������", �������� ����������� ������ 
	bWinnerDisabled = CBool(nLotState <> LOTSTATE_WASGAIN)
	tblWinner.disabled = bWinnerDisabled

	' ���� ��������� ���� "��������", �������� ����������� ������ 
	bLoserDisabled = CBool(nLotState <> LOTSTATE_WASLOSS)
	tblLoser.disabled = bLoserDisabled
	document.all("selectorWinner").disabled = bLoserDisabled
	TMS_EnablePropertyEditor _
		TMS_GetPropertyEditor(ObjectEditor, oXmlLot, "LossReason"), _
		Not bLoserDisabled
	TMS_EnablePropertyEditor _
		TMS_GetPropertyEditor(ObjectEditor, oXmlLot, "ResultNote"), _
		Not bLoserDisabled
	
	' ���� ��������� ���� "�������", "�������", "��������" ��� "�������", �������� ������ "����� � IT"
	
	' � ����������� �� ��������� ���� �������� ���� ����
	If Not bWinnerDisabled Then
		tblWinner.className = "x-editor-subtable-green"
		tdLotWasGain.style.display = "inline"
	Else
		tblWinner.className = ""
		tdLotWasGain.style.display = "none"
	End If
	If Not bLoserDisabled Then
		tblLoser.className = "x-editor-subtable-red"
	Else
		tblLoser.className = ""
	End If
	If bWinnerDisabled And bLoserDisabled Then
		trWrongState.style.display = "inline"
	Else
		trWrongState.style.display = "none"
	End If
	
	' ������������� �������� � ��������� "����������"
	For Each oXmlTemp In Pool.GetXmlObjectsByOPath(oXmlLot, "LotParticipants")
		If oXmlTemp.selectSingleNode("Winner").nodeTypedValue <> 0 Then
			document.all("selectorWinner").value = oXmlTemp.getAttribute("oid")
			Exit For
		End If
	Next
	' ���� �������� �� ��� ��� �� �����������, �������� ������ ������� 
	If document.all("selectorWinner").value = Empty Then 
		document.all("selectorWinner").selectedIndex = 0
	End If
End Sub

Dim g_nOldLotState	' ��������� ���� �� ���������

'==============================================================================
Sub usr_Lot_State_SelectorCombo_OnChanging( oSender, oEventArgs )
	Dim oXmlLot		' XML-������� ����
	
	Set oXmlLot = oSender.XmlProperty.parentNode
	g_nOldLotState = Pool.GetPropertyValue(oXmlLot, "State")
End Sub

'==============================================================================
Sub usr_Lot_State_SelectorCombo_OnChanged( oSender, oEventArgs )
	Dim oXmlTemp
	Dim oXmlLot		' XML-������� ����
	Dim oXmlResultNote
	Dim CurrState
	Set oXmlLot = oSender.XmlProperty.parentNode
	CurrState = Pool.GetPropertyValue(oXmlLot, "State")
	If g_nOldLotState = LOTSTATE_WASLOSS Then
		' ��� ���� ���������� ���� ���������� ������� "����������"
		For Each oXmlTemp In Pool.GetXmlObjectsByOPath(oXmlLot, "LotParticipants")
			Pool.SetPropertyValue Pool.GetXmlProperty(oXmlTemp, "Winner"), False
		Next 
		' ��� ���� ���������� ������� ���������
		Pool.RemoveAllRelations oXmlLot, "LossReason"
		' ��� ���� ���������� ����������� � ������� ���������
		Set oXmlResultNote =Pool.GetXmlProperty(oXmlLot, "ResultNote") 
		Pool.SetPropertyValue oXmlResultNote,Null
	End If
	If CurrState = LOTSTATE_WASLOSS Then
	   Set oXmlTemp = GetLotParticipantOwn( oXmlLot )
	   Pool.SetPropertyValue Pool.GetXmlProperty(oXmlTemp, "Winner"), False
	End If
    If CurrState = LOTSTATE_WASGAIN Then
        For Each oXmlTemp In Pool.GetXmlObjectsByOPath(oXmlLot, "LotParticipants")
			Pool.SetPropertyValue Pool.GetXmlProperty(oXmlTemp, "Winner"), False
		Next
		Set oXmlTemp = GetLotParticipantOwn( oXmlLot )
	    Pool.SetPropertyValue Pool.GetXmlProperty(oXmlTemp, "Winner"), True
    End If
End Sub

'==============================================================================
' ���������� ���������/����������� ������� ����
Sub LotParticipants_MenuVisibilityHandler(oSender, oMenuEventArgs)
	Dim oMenuItem				' ������� menu-item
	Dim sType					' ��� ������� � ��������
	Dim sObjectID				' ������������� �������-��������
	Dim oXmlLot					' XML-������� ����
	Dim oXmlLotParticipantOwn	' XML-������� ��������� ���� �� ���
	
	sType = oMenuEventArgs.Menu.Macros.Item("ObjectType")
	sObjectID = oMenuEventArgs.Menu.Macros.Item("ObjectID")

	Set oXmlLot = oSender.XmlProperty.parentNode
	Set oXmlLotParticipantOwn = GetLotParticipantOwn(oXmlLot) 

	' ���� ��� ������ "�������"
	For Each oMenuItem In oMenuEventArgs.Menu.XmlMenu.selectNodes("i:menu-item[@action='DoMarkDelete']")
		' ���� ��� �������� ������� �� ���, �� ���������
		If oXmlLotParticipantOwn.tagName = sType And _
			oXmlLotParticipantOwn.getAttribute("oid") = sObjectID Then
				oMenuItem.setAttribute "disabled", "1"
		End If
	Next
End Sub

'==============================================================================
' ���������� ������ "������� ������"
Sub OnCreateProject()
	alert "���� �� �����������"
End Sub

'==============================================================================
' ���������� ������ "������� ������"
Sub OnSelectProject()
	alert "���� �� �����������"
End Sub

'==============================================================================
' ���������� ��������� ��������� "����������"
' [in] oXmlLot - XML-������ ����
Sub LotEditor_OnWinnerSelectorChanged( oXmlLot )
	Dim bWinnerExists	' ���� "����������" ��� ����� ��� ������-�� ���������
	Dim sOldWinnerID	' ������������� �������� ����������
	Dim sOldWinnerName	' �������� ������� �����������-����������
	Dim sNewWinnerID	' ������������� ���������� ����������
	Dim oXmlNewWinner	' XML-������� ���������� ����������
	Dim oXmlTemp	
	Dim sMessage
	
	' �������� ������������� �������� ����������
	sOldWinnerID = Empty
	For Each oXmlTemp In Pool.GetXmlObjectsByOPath(oXmlLot, "LotParticipants")
		If oXmlTemp.selectSingleNode("Winner").nodeTypedValue <> 0 Then
			sOldWinnerID = oXmlTemp.getAttribute("oid")
			sOldWinnerName = Pool.GetPropertyValue(oXmlTemp, "ParticipantOrganization.ShortName")
			If Not hasValue(sOldWinnerName) Then
				sOldWinnerName = Pool.GetPropertyValue(oXmlTemp, "ParticipantOrganization.Name")
			End If 
			Exit For
		End If
	Next

	' ���� ������� "����������" ��� ��� ���������� ��� ����-����
	If hasValue(sOldWinnerID) Then
		sMessage = "��� ���� ��� ������� �����������-���������� - " & sOldWinnerName & "." & vbNewLine & "������������� ����������?"
		If Not confirm(sMessage) Then
			document.all("selectorWinner").value = sOldWinnerID
			' ���� �������� �� �����������, �������� ������ ������� 
			If document.all("selectorWinner").value = Empty Then 
				document.all("selectorWinner").selectedIndex = 0
			End If
			Exit Sub
		End If
	End If
	
	' ���� ����� �� ����, ������ ����� �������� ����������
	sNewWinnerID = document.all("selectorWinner").value
	
	' �������� XML-������� ���������� ����������
	Set oXmlNewWinner = Pool.GetXmlObject("LotParticipant", sNewWinnerID, Empty)
	
	' ��� ���������� ���������� ���������� ��������������� �������
	Pool.SetPropertyValue Pool.GetXmlProperty(oXmlNewWinner, "Winner"), True
	' ��� ���� ��������� ���������� ������� "����������"
	For Each oXmlTemp In Pool.GetXmlObjectsByOPath(oXmlLot, "LotParticipants")
		If Not oXmlTemp Is oXmlNewWinner Then
			Pool.SetPropertyValue Pool.GetXmlProperty(oXmlTemp, "Winner"), False
		End If
	Next 
End Sub
