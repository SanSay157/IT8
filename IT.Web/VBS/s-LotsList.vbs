'==============================================================================
Sub usrXList_OnBeforeListReload( oSender, oEventArgs )
	'Dim xmlFilter
	'Dim dtDocFeedingBegin, dtDocFeedingEnd
	'Dim FilterObject
	'Set FilterObject = X_GetFilterObject( document.all( "FilterFrame") )
	'Set xmlFilter = FilterObject.GetXmlState()

	'dtDocFeedingBegin = xmlFilter.selectSingleNode("FilterLotsList/DocFeedingBegin").nodeTypedValue

	'dtDocFeedingEnd = xmlFilter.selectSingleNode("FilterLotsList/DocFeedingEnd").nodeTypedValue

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