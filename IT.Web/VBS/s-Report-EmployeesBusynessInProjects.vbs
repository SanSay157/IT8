Option Explicit

Dim g_bPeriodSelectorInited

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	Dim nDetalization
	
	If oSender.CurrentPage.PageTitle = "Основные параметры" And Not g_bPeriodSelectorInited Then
		' Инициализируем обработку свойств, связанных с периодом времени
		InitPeriodSelector oSender
		g_bPeriodSelectorInited = True
	End If
End Sub

'==============================================================================
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim oOrganizations, oDepartments, oEmployees
	Dim dtIntervalBegin, dtIntervalEnd
	Dim sMsg

	Set oOrganizations = oSender.Pool.GetXmlObjectsByOPath(oSender.XmlObject, "Organizations")
	Set oDepartments = oSender.Pool.GetXmlObjectsByOPath(oSender.XmlObject, "Departments")
	Set oEmployees = oSender.Pool.GetXmlObjectsByOPath(oSender.XmlObject, "Employees")
	
	If	(oOrganizations Is Nothing) And _
		(oDepartments Is Nothing) And _
		(oEmployees Is Nothing) Then
		alert "Вы должны задать сотрудников."
		oEventArgs.ReturnValue = False
		Exit Sub
	End If
	
	dtIntervalBegin = oSender.XmlObject.selectSingleNode("IntervalBegin").nodeTypedValue
	dtIntervalEnd = oSender.XmlObject.selectSingleNode("IntervalEnd").nodeTypedValue
	
	If IsNull(dtIntervalBegin) Or IsNull(dtIntervalEnd) _
		Or DateDiff("m", dtIntervalBegin, dtIntervalEnd) >= 3 Then
		sMsg = "Задан большой диапазон дат. Возможно, отчет будет строиться длительное время." _
			& vbNewLine & "Вы уверены, что хотите продолжить?"
		If Not confirm(sMsg) Then
			oEventArgs.ReturnValue = False
			Exit Sub
		End If
	End If
End Sub
