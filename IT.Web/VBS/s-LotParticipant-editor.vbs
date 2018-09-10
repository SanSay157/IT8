Option Explicit

'==============================================================================
Const MSG_NO_PARTICIPANT = "Участник тендера от нас указывается в карточке лота"
Const MSG_NO_PARTICIPANT_SINGLELOT = "В однолотовом тендере участник от нас указывается в карточке тендера"

Const WRNG_LOTGAINED_WINNER_NOTOWN = "В выигранном лоте для участника не от нас устанавливается статус ""Победитель"""
Const WRNG_LOTGAINED_LOSER_OWN = "В выигранном лоте для участника от нас устанавливается статус ""Проигравший"""
Const WRNG_LOTLOSED_WINNER_OWN = "В проигранном лоте для участника от нас устанавливается статус ""Победитель"""

Const SELECTOR_VALUE_WINNER	= "winner"	' итоговый статус участника "Победитель"
Const SELECTOR_VALUE_LOSER	= "loser"	' итоговый статус участника "Проигравший"

'==============================================================================
Dim IsSingleLot		' Редактор вызывался из однолотового тендера

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	' инициализируем глобальные переменные
	InitGlobals oSender
	
	' получаем признак того, что редактор вызывался из однолотового тендера
	IsSingleLot = CBool(ObjectEditor.QueryString.GetValue("SingleLot", False))
End Sub

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	Dim oOrganizationEditor
	
	' если редактор вывывался из однолотового тендера,
	' "объединяем" информацию о тендере и лоте
	If IsSingleLot Then
		trLotInfo.style.display = "none"
		captionTenderInfo.innerText = "Информация о тендере/лоте"
	' иначе показываем информацию о тендере и лоте раздельно
	Else
		trLotInfo.style.display = "inline"
	End If
	
	' если это участник тендера от нас
	If getParticipationType() = PARTICIPATIONS_PARTICIPANT Then
		enablePropertyEditor "ParticipantOrganization", False
		enablePropertyEditor "ParticipationType", False
		enablePropertyEditor "Declined", False
	End If
	
	enableCompetitorEditors()

	' Инициалиазируем обработку операции "Замена временного описания организации постоянным"
	Set oOrganizationEditor = TMS_GetPropertyEditor( ObjectEditor, Nothing, "ParticipantOrganization" )
	oOrganizationEditor.EventEngine.AddHandlerForEvent "BeforeChangeTempOrgOnConst", Nothing, "OnBeforeChangeTempOrgOnConst"

End Sub

'==============================================================================
Sub OnBeforeChangeTempOrgOnConst(oSender, oMenuEventArgs)
	oMenuEventArgs.Menu.Macros.Item("LotParticipantID") = oSender.ObjectEditor.XmlObject.getAttribute("oid")
	oMenuEventArgs.Menu.Macros.Item("TenderID") = Pool.GetXmlObjectByOPath(ObjectEditor.XmlObject, "Lot.Tender").getAttribute("oid")
End Sub

'==============================================================================
' Возвращает тип участия для данного объекта, читая его из пула
Function getParticipationType()
	getParticipationType = Pool.GetPropertyValue(ObjectEditor.XmlObject, "ParticipationType")
End Function

'==============================================================================
' Возвращает состояние лота для данного объекта, читая его из пула
Function getLotState()
	getLotState = Pool.GetPropertyValue(ObjectEditor.XmlObject, "Lot.State")
End Function

'==============================================================================
' Блокирует/разрешает редактор свойства
' [in] sPropName	- наименование свойства
' [in] bEnable		- признак доступности редактора свойства
Sub enablePropertyEditor(sPropName, bEnable)
	Dim oPropEditor		' редактор свойства

	Set oPropEditor = TMS_GetPropertyEditor( ObjectEditor, Nothing, sPropName )

	TMS_EnablePropertyEditor oPropEditor, bEnable
End Sub

'==============================================================================
Sub usr_LotParticipant_ParticipationType_SelectorCombo_OnChanging( oSender, oEventArgs)
	Dim oPropEditor		' редактор свойства
	' нельзя выбирать тип участия "Участник" - он должен выбираться
	' в редакторе лота (или однолотового тендера)
	If oEventArgs.NewValue = PARTICIPATIONS_PARTICIPANT Then
		If IsSingleLot Then
			alert MSG_NO_PARTICIPANT_SINGLELOT
		Else
			alert MSG_NO_PARTICIPANT
		End If
       
       	' восстановим старое значение в редакторе
      	Set oPropEditor = TMS_GetPropertyEditor( ObjectEditor, Nothing, "ParticipationType" )
		oPropEditor.SetData
		' отмена изменения свойства
		oEventArgs.ReturnValue = False
	End If
End Sub

'==============================================================================
Sub usr_LotParticipant_ParticipationType_SelectorCombo_OnChanged( oSender, oEventArgs)
	enableCompetitorEditors()
End Sub

'==============================================================================
' Блокирует/разрешает редакторы свойств "Причина помощи" и "Контактная информация"
' в зависимости от типа участия
Sub enableCompetitorEditors()
	Dim nParticipationType	' тип участия
	
	nParticipationType = getParticipationType()

	' если тип участия "Помогающий"
	If nParticipationType = PARTICIPATIONS_HELPER Then
		enablePropertyEditor "LossReason", True
		enablePropertyEditor "HelperContactInfo", True
	Else
		enablePropertyEditor "LossReason", False
		enablePropertyEditor "HelperContactInfo", False
	End If
End Sub

'==============================================================================
' Обработчик изменения итогового статуса участника
Sub OnStateChanged()
	Dim xmlWinnerProp		' XML-элемент свойства "Победитель"
	Dim nLotState			' состояние лота
	Dim nParticipationType	' тип участия
	Dim sSelectorValue		' выбранное значение в селекторе
	Dim xmlLotParticipants	' As IXMLDOMNodeList, все участники лота
	Dim xmlLotParticipant	' As IXMLDOMNode, участник лота
	Dim xmlLot
	
	sSelectorValue = document.all("StateSelector").Value
	nLotState = getLotState()
	nParticipationType = getParticipationType()
	
	' выдаем предупреждение
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
	
	' получаем XML-элемент свойства "Победитель"
	Set xmlWinnerProp = Pool.GetXmlProperty(ObjectEditor.XmlObject, "Winner")
	
	' в зависимости от выбранного значения в селекторе
	' устанавливаем значение свойства "Победитель"
	If sSelectorValue <> SELECTOR_VALUE_WINNER Then
		Pool.SetPropertyValue xmlWinnerProp, False
	Else
		' сначала для всех участников лота сбросим значение
		' свойсва "Победитель" в False
		Set xmlLotParticipants = Pool.GetXmlObjectsByOPath(ObjectEditor.XmlObject, "Lot.LotParticipants")
		For Each xmlLotParticipant In xmlLotParticipants
			Pool.SetPropertyValue Pool.GetXmlProperty(xmlLotParticipant, "Winner"), False
		Next
		' для редактируемого участника лота установим
		' значение свойства "Победитель" в True
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
    
	' изменяем цвет фона группы в зависимости от значения селектора
	Select Case sSelectorValue
		Case SELECTOR_VALUE_WINNER
			tblParticipantInfo.className = "x-editor-subtable-green"
		Case SELECTOR_VALUE_LOSER
			tblParticipantInfo.className = "x-editor-subtable-red"
		Case Else
			tblParticipantInfo.className = "x-editor-subtable-blue"
	End Select
		
End Sub

