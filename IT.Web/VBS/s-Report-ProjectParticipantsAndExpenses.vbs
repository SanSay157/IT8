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
	
	Set oXmlFilter = g_oFilterObject.GetXmlState().selectSingleNode("FilterReportProjectParticipantsAndExpenses")

	' Определяем, нужно ли показывать объединяющий столбец "Задания"
	If oXmlFilter.selectSingleNode("ShowColumnTasksDone").nodeTypedValue Or _
		oXmlFilter.selectSingleNode("ShowColumnTasksLeft").nodeTypedValue Then
		oEventArgs.QueryStringParamCollectionBuilder.AppendParameter "ShowColumnsTasks", "1"
	Else
		oEventArgs.QueryStringParamCollectionBuilder.AppendParameter "ShowColumnsTasks", "0"
	End If
	
	' Определяем, нужно ли показывать объединяющий столбец "Затраты времени"
	If oXmlFilter.selectSingleNode("ShowColumnLostTime").nodeTypedValue Or _
		oXmlFilter.selectSingleNode("ShowColumnSpentTime").nodeTypedValue Or _
		oXmlFilter.selectSingleNode("ShowColumnPlannedTime").nodeTypedValue Or _
		oXmlFilter.selectSingleNode("ShowColumnSummaryTime").nodeTypedValue Or _
		oXmlFilter.selectSingleNode("ShowColumnLeftTime").nodeTypedValue Then
		oEventArgs.QueryStringParamCollectionBuilder.AppendParameter "ShowColumnsTimes", "1"
	Else
		oEventArgs.QueryStringParamCollectionBuilder.AppendParameter "ShowColumnsTimes", "0"
	End If
	
End Sub

