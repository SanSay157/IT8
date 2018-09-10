Option Explicit

Dim g_bPeriodSelectorInited

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	If oSender.CurrentPage.PageTitle = "Основные параметры" And Not g_bPeriodSelectorInited Then
		' Инициализируем обработку свойств, связанных с периодом времени
		InitPeriodSelector oSender
		g_bPeriodSelectorInited = True
	End If
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

'==============================================================================
Sub usrXReportFilter_OnOpenReport(oSender, oEventArgs)
	Dim oXmlFilter
	
	Set oXmlFilter = g_oFilterObject.GetXmlState().selectSingleNode("FilterReportProjectIncidentsAndExpenses")

	' Определяем, нужно ли показывать объединяющий столбец "Даты"
	If oXmlFilter.selectSingleNode("ShowColumnDeadLine").nodeTypedValue Or _
		oXmlFilter.selectSingleNode("ShowColumnInputDate").nodeTypedValue Or _
		oXmlFilter.selectSingleNode("ShowColumnLastChange").nodeTypedValue Or _
		oXmlFilter.selectSingleNode("ShowColumnLastSpent").nodeTypedValue Then
		oEventArgs.QueryStringParamCollectionBuilder.AppendParameter "ShowColumnsDates", "1"
	Else
		oEventArgs.QueryStringParamCollectionBuilder.AppendParameter "ShowColumnsDates", "0"
	End If
	
	' Определяем, нужно ли показывать объединяющий столбец "Задействованы"
	If oXmlFilter.selectSingleNode("ShowColumnRole").nodeTypedValue Or _
		oXmlFilter.selectSingleNode("ShowColumnEmployee").nodeTypedValue Then
		oEventArgs.QueryStringParamCollectionBuilder.AppendParameter "ShowColumnsActors", "1"
	Else
		oEventArgs.QueryStringParamCollectionBuilder.AppendParameter "ShowColumnsActors", "0"
	End If
	
	' Определяем, нужно ли показывать объединяющий столбец "Затраты времени"
	If oXmlFilter.selectSingleNode("ShowColumnPlannedTime").nodeTypedValue Or _
		oXmlFilter.selectSingleNode("ShowColumnSpentTime").nodeTypedValue Or _
		oXmlFilter.selectSingleNode("ShowColumnLeftTime").nodeTypedValue Then
		oEventArgs.QueryStringParamCollectionBuilder.AppendParameter "ShowColumnsTimes", "1"
	Else
		oEventArgs.QueryStringParamCollectionBuilder.AppendParameter "ShowColumnsTimes", "0"
	End If

End Sub

