Option Explicit

Dim g_bPeriodSelectorInited

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	If oSender.CurrentPage.PageTitle = "ќсновные параметры" And Not g_bPeriodSelectorInited Then
		' »нициализируем обработку свойств, св€занных с периодом времени
		InitPeriodSelector oSender
		g_bPeriodSelectorInited = True
	End If
End Sub

'==============================================================================
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim oFolder, oCustomer
	Dim dtIntervalBegin, dtIntervalEnd
	Dim nDateDetalization
	Dim bLargeInterval
	Dim sMsg
	
	Set oFolder = oSender.Pool.GetXmlObjectByOPath(oSender.XmlObject, "Folder")
	Set oCustomer = oSender.Pool.GetXmlObjectByOPath(oSender.XmlObject, "Customer")
	If (oFolder Is Nothing And oCustomer Is Nothing) Or _
		(Not oFolder Is Nothing And Not oCustomer Is Nothing) Then
		sMsg = "¬ы должны указать либо активность, либо клиента."
		alert sMsg
		oEventArgs.ReturnValue = False
		Exit Sub
	End If
		
	dtIntervalBegin = oSender.XmlObject.selectSingleNode("IntervalBegin").nodeTypedValue
	dtIntervalEnd = oSender.XmlObject.selectSingleNode("IntervalEnd").nodeTypedValue
	
	bLargeInterval = IsNull(dtIntervalBegin) Or IsNull(dtIntervalEnd) _
		Or DateDiff("m", dtIntervalBegin, dtIntervalEnd) >= 3
		
	If bLargeInterval Then
		nDateDetalization = oSender.XmlObject.selectSingleNode("DateDetalization").nodeTypedValue
		If (nDateDetalization = DATEDETALIZATION_ALLDATE) Or (nDateDetalization = DATEDETALIZATION_EXPENCESDATE) Then
			sMsg = "«адан большой диапазон дат. ѕри таком диапазоне детализаци€ по всем датам не будет работать." _
				& vbNewLine & "»змените детализацию по датам."
			alert sMsg
			oEventArgs.ReturnValue = False
		Else
			sMsg = "«адан большой диапазон дат. ¬озможно, отчет будет строитьс€ длительное врем€." _
				& vbNewLine & "¬ы уверены, что хотите продолжить?"
			If Not confirm(sMsg) Then
				oEventArgs.ReturnValue = False
			End If
		End If
	End If
End Sub
