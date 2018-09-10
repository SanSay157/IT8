Option Explicit

Dim g_oObjectEditor
Dim g_bPeriodSelectorInited

'==============================================================================
' Обработчик события Load
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Set g_oObjectEditor = oSender
	
	setUpXmlObjectOfFoldersTreeFilter oSender
End Sub

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	If oSender.CurrentPage.PageTitle = "Основные параметры" And Not g_bPeriodSelectorInited Then
		' Инициализируем обработку свойств, связанных с периодом времени
		InitPeriodSelector oSender
		g_bPeriodSelectorInited = True
	ElseIf oSender.CurrentPage.PageTitle = "Клиенты/Активности" Then
		enableFolders
	End If
End Sub

'==============================================================================
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim oOrganizations, oDepartments, oEmployees
	Dim dtIntervalBegin, dtIntervalEnd
	Dim bLargeInterval ' Признак того, что задан большой интервал дат
	Dim bAllFolders ' Признак того, что отчет строится для по всем активностям
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
	'Будем считать, что у нас задан большой диапазон дат, если разница между датой начала и конца > 3
	bLargeInterval = IsNull(dtIntervalBegin) Or IsNull(dtIntervalEnd) _
		Or DateDiff("m", dtIntervalBegin, dtIntervalEnd) >= 3
	bAllFolders = oSender.XmlObject.selectSingleNode("AllFolders").nodeTypedValue
	
	If Not bLargeInterval And Not bAllFolders Then Exit Sub
	
	sMsg = ""
	' Если задан большой диапазон дат и режим "Все активности", то выдадим предупреждающее сообщение
	If bLargeInterval And bAllFolders Then
		sMsg = "Задан большой диапазон дат и не указана фильтрация по активностям."
	ElseIf bLargeInterval Then
		sMsg = "Задан большой диапазон дат."
	ElseIf bAllFolders Then
		sMsg = "Не задана фильтрация по активностям."
	End If
	
	sMsg = sMsg & " Возможно, отчет будет строиться длительное время." _
		& vbNewLine & "Вы уверены, что хотите продолжить?"
	If Not confirm(sMsg) Then
		oEventArgs.ReturnValue = False
	End If
End Sub
