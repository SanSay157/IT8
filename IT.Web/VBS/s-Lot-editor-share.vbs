Option Explicit

'==============================================================================
Dim bLotMainPageInited		' Страница "Основные реквизиты"	проинициализирована

'==============================================================================
' Создает в пуле участника лота от нас
' [in] oXmlLot - XML-элемент лота
' [out] - XML-элемент созданного участник лота от нас
Function CreateLotParticipantOwn( oXmlLot )
	Dim oXmlLotParticipantOwn	' XML-элемент, соответствующий объекту "Участник лота" (от нас)
	Dim oXmlLotParticipantsProp	' XML-элемент, соответствующий свойству "Участники лота"
	Dim oXmlTemp
	
	' получаем свойство "Участники лота"
	Set oXmlLotParticipantsProp = Pool.GetXmlProperty( oXmlLot, "LotParticipants")
	
	' привязываем участника лота
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
' Возвращает участника лота от нас
' [in] oXmlLot - XML-элемент лота
' [out] - XML-элемент созданного участник лота от нас
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
' Инициализирует редакторы свойств на главной странице
' [in] oXmlLot - XML-элемент лота
Sub LotEditor_InitMainPage( oXmlLot )
	' если страница еще не проинициализирована
	If Not bLotMainPageInited Then
		' инициализируем обработку свойств "Менеджер проекта",
		' "Менеджер ознакомился" и "Дата получения документов менеджером"
		TMS_InitAcquaintedEmployeeHandler _
			TMS_GetPropertyEditor( ObjectEditor, oXmlLot, "Manager" ), _
			TMS_GetPropertyEditor( ObjectEditor, oXmlLot, "MgrIsAcquaint" ), _
			TMS_GetPropertyEditor( ObjectEditor, oXmlLot, "MgrDocsGettingDate" )

		bLotMainPageInited = True
	End If
End Sub

'==============================================================================
' Инициализирует страницу "Результаты"
' [in] oXmlLot - XML-элемент лота
Sub LotEditor_InitResultsPage( oXmlLot )
	Dim nLotState		' Состояние лота
	Dim bWinnerDisabled	' Группа "Победитель" заблокирована
	Dim bLoserDisabled	' Группа "Проигравший" заблокирована
	DIm bFolderDisabled	' Группа "Связь с IT" заблокирована
	Dim oXmlTemp

	' Получаем состояние лота
	nLotState = Pool.GetPropertyValue(oXmlLot, "State")
	
	' Если состояние лота "Выигран", доступна одноименная группа 
	bWinnerDisabled = CBool(nLotState <> LOTSTATE_WASGAIN)
	tblWinner.disabled = bWinnerDisabled

	' Если состояние лота "Проигран", доступна одноименная группа 
	bLoserDisabled = CBool(nLotState <> LOTSTATE_WASLOSS)
	tblLoser.disabled = bLoserDisabled
	document.all("selectorWinner").disabled = bLoserDisabled
	TMS_EnablePropertyEditor _
		TMS_GetPropertyEditor(ObjectEditor, oXmlLot, "LossReason"), _
		Not bLoserDisabled
	TMS_EnablePropertyEditor _
		TMS_GetPropertyEditor(ObjectEditor, oXmlLot, "ResultNote"), _
		Not bLoserDisabled
	
	' Если состояние лота "Участие", "Выигран", "Проигран" или "Отменен", доступна группа "Связь с IT"
	
	' В зависимости от состояния лота изменяем цвет фона
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
	
	' Устанавливаем значение в селекторе "Победитель"
	For Each oXmlTemp In Pool.GetXmlObjectsByOPath(oXmlLot, "LotParticipants")
		If oXmlTemp.selectSingleNode("Winner").nodeTypedValue <> 0 Then
			document.all("selectorWinner").value = oXmlTemp.getAttribute("oid")
			Exit For
		End If
	Next
	' Если значение до сих пор не установлено, выбираем первый элемент 
	If document.all("selectorWinner").value = Empty Then 
		document.all("selectorWinner").selectedIndex = 0
	End If
End Sub

Dim g_nOldLotState	' Состояние лота до изменения

'==============================================================================
Sub usr_Lot_State_SelectorCombo_OnChanging( oSender, oEventArgs )
	Dim oXmlLot		' XML-элемент лота
	
	Set oXmlLot = oSender.XmlProperty.parentNode
	g_nOldLotState = Pool.GetPropertyValue(oXmlLot, "State")
End Sub

'==============================================================================
Sub usr_Lot_State_SelectorCombo_OnChanged( oSender, oEventArgs )
	Dim oXmlTemp
	Dim oXmlLot		' XML-элемент лота
	Dim oXmlResultNote
	Dim CurrState
	Set oXmlLot = oSender.XmlProperty.parentNode
	CurrState = Pool.GetPropertyValue(oXmlLot, "State")
	If g_nOldLotState = LOTSTATE_WASLOSS Then
		' для всех участников лота сбрасываем признак "Победитель"
		For Each oXmlTemp In Pool.GetXmlObjectsByOPath(oXmlLot, "LotParticipants")
			Pool.SetPropertyValue Pool.GetXmlProperty(oXmlTemp, "Winner"), False
		Next 
		' для лота сбрасываем причину проигрыша
		Pool.RemoveAllRelations oXmlLot, "LossReason"
		' для лота сбрасываем комментарий к причине проигрыша
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
' Обработчик видимости/доступности пунктов меню
Sub LotParticipants_MenuVisibilityHandler(oSender, oMenuEventArgs)
	Dim oMenuItem				' текущий menu-item
	Dim sType					' тип объекта в свойстве
	Dim sObjectID				' идентификатор объекта-значения
	Dim oXmlLot					' XML-элемент лота
	Dim oXmlLotParticipantOwn	' XML-элемент участника лота от нас
	
	sType = oMenuEventArgs.Menu.Macros.Item("ObjectType")
	sObjectID = oMenuEventArgs.Menu.Macros.Item("ObjectID")

	Set oXmlLot = oSender.XmlProperty.parentNode
	Set oXmlLotParticipantOwn = GetLotParticipantOwn(oXmlLot) 

	' ищем все пункты "Удалить"
	For Each oMenuItem In oMenuEventArgs.Menu.XmlMenu.selectNodes("i:menu-item[@action='DoMarkDelete']")
		' если это участник тендера от нас, то блокируем
		If oXmlLotParticipantOwn.tagName = sType And _
			oXmlLotParticipantOwn.getAttribute("oid") = sObjectID Then
				oMenuItem.setAttribute "disabled", "1"
		End If
	Next
End Sub

'==============================================================================
' Обработчик кнопки "Создать проект"
Sub OnCreateProject()
	alert "Пока не реализовано"
End Sub

'==============================================================================
' Обработчик кнопки "Выбрать проект"
Sub OnSelectProject()
	alert "Пока не реализовано"
End Sub

'==============================================================================
' Обработчик изменения селектора "Победитель"
' [in] oXmlLot - XML-объект лота
Sub LotEditor_OnWinnerSelectorChanged( oXmlLot )
	Dim bWinnerExists	' флаг "Победитель" уже задан для какого-то участника
	Dim sOldWinnerID	' идентификатор текущего победителя
	Dim sOldWinnerName	' название текущей организации-победителя
	Dim sNewWinnerID	' идентификатор выбранного победителя
	Dim oXmlNewWinner	' XML-элемент выбранного победителя
	Dim oXmlTemp	
	Dim sMessage
	
	' получаем идентификатор текущего победителя
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

	' если признак "Победитель" уже был установлен для кого-либо
	If hasValue(sOldWinnerID) Then
		sMessage = "Для лота уже указана организация-победитель - " & sOldWinnerName & "." & vbNewLine & "Переназначить победителя?"
		If Not confirm(sMessage) Then
			document.all("selectorWinner").value = sOldWinnerID
			' если значение не установлено, выбираем первый элемент 
			If document.all("selectorWinner").value = Empty Then 
				document.all("selectorWinner").selectedIndex = 0
			End If
			Exit Sub
		End If
	End If
	
	' Если дошли до сюда, значит нужно изменить победителя
	sNewWinnerID = document.all("selectorWinner").value
	
	' получаем XML-элемент выбранного победителя
	Set oXmlNewWinner = Pool.GetXmlObject("LotParticipant", sNewWinnerID, Empty)
	
	' для выбранного победителя выставляем соответствующий признак
	Pool.SetPropertyValue Pool.GetXmlProperty(oXmlNewWinner, "Winner"), True
	' для всех остальных сбрасываем признак "Победитель"
	For Each oXmlTemp In Pool.GetXmlObjectsByOPath(oXmlLot, "LotParticipants")
		If Not oXmlTemp Is oXmlNewWinner Then
			Pool.SetPropertyValue Pool.GetXmlProperty(oXmlTemp, "Winner"), False
		End If
	Next 
End Sub
