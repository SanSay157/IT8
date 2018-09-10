Option Explicit

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	' Инициализируем обработку свойств, связанных с периодом времени
	InitPeriodSelector oSender
End Sub

'==============================================================================
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim dtIntervalBegin, dtIntervalEnd
	Dim sMsg
	
	dtIntervalBegin = oSender.XmlObject.selectSingleNode("IntervalBegin").nodeTypedValue
	dtIntervalEnd = oSender.XmlObject.selectSingleNode("IntervalEnd").nodeTypedValue
	
	If IsNull(dtIntervalBegin) Or IsNull(dtIntervalEnd) _
		Or DateDiff("m", dtIntervalBegin, dtIntervalEnd) >= 3 Then
		sMsg = "Задан большой диапазон дат. Возможно, отчет будет строиться длительное время." _
			& vbNewLine & "Вы уверены, что хотите продолжить?"
		If Not confirm(sMsg) Then
			oEventArgs.ReturnValue = False
		End If
	End If
End Sub
