'==============================================================================
Sub usrXList_OnBeforeListReload( oSender, oEventArgs )
	'убираем предупреждения об инервале дат 
    'Dim xmlFilter
	'Dim dtDocFeedingBegin, dtDocFeedingEnd
	'Dim FilterObject
	'Set FilterObject = X_GetFilterObject( document.all( "FilterFrame") )
	'Set xmlFilter =FilterObject.GetXmlState()
    'dtDocFeedingBegin = xmlFilter.selectSingleNode("FilterTendersList/DocFeedingBegin").nodeTypedValue
	'dtDocFeedingEnd = xmlFilter.selectSingleNode("FilterTendersList/DocFeedingEnd").nodeTypedValue
    ' заданы обе даты
	'If Not IsNull(dtDocFeedingBegin) And Not IsNull(dtDocFeedingEnd) Then
    '	If DateDiff("m", dtDocFeedingBegin, dtDocFeedingEnd) > 3 Then
	'		DateAlert()
	'	End If
	' задана только дата начала
	'ElseIf Not IsNull(dtDocFeedingBegin) And IsNull(dtDocFeedingEnd) Then
	'	If DateDiff("m", dtDocFeedingBegin, Now()) > 3 Then
	'		DateAlert()
	'	End If
	' не задана дата начала
	'ElseIf IsNull(dtDocFeedingBegin) Then
	'	DateAlert()
	'End If
End Sub

'==============================================================================
' Выводит предупреждающее сообщение
Sub DateAlert()
	alert "Задан большой диапазон дат. Возможно замедление работы системы!"
End Sub

'==============================================================================
Sub usrXList_OnAccel1(oXList, oAccelerationArgs)
	' отдадим нажатую комбинацию в меню списка - может для нее там определены hotkey'и
	'oXList.Menu.ExecuteHotkey oXList, oAccelerationArgs
	alert oXList.Menu.Macros.Item("ObjectID")
	alert oXList.Menu.Macros.Item("IsSingleLot")
End Sub

'==============================================================================
Sub TendersList_MenuVisibilityHandler(oSender, oMenuEventArgs)
	'Dim oMenuItem		' текущий menu-item
	'Dim bIsSingleLot	' признак однолотового тендера
	
	'Set oMenuItem = oMenuEventArgs.Menu.XmlMenu.selectSingleNode("i:menu-item[@n='EditAsSingleLot']")
	'If Not oMenuItem Is Nothing Then
	'	bIsSingleLot = CBool(nvl(oMenuEventArgs.Menu.Macros.Item("IsSingleLot"), False))
		' Если тендер многолотовый, то редактировать его как однолотовый нельзя.
		' Спрячем соответствующий пункт меню
	'	If Not bIsSingleLot Then
	'		oMenuItem.setAttribute "hidden", "1"
	'	Else
	'		oMenuItem.removeAttribute "hidden"
	'	End If 
	'End If
End Sub

