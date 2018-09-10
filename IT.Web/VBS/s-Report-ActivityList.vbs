'===============================================================================
'Обработчик для редактора фильтра отчета "Список активностей"
Option Explicit

Dim g_bPeriodSelectorInited 'Признак завершения инциализации свойств, связанных с периодом времени 
Dim g_oObjectEditor 'Редактор объекта - типа FilterReportActivityList (фильтр отчета)

'==============================================================================
' Обработчик события Load
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Set g_oObjectEditor = oSender
	
	setUpXmlObjectOfFoldersTreeFilter oSender
End Sub

'==============================================================================
'Обработчик события PageStart
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
' Обработчик события OnValidate
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim dtIntervalBegin, dtIntervalEnd ' Дата начала и конца итервала времени, по которому строится отчет
	Dim bLargeInterval ' Признак того, что задан большой интервал дат
	Dim bAllFolders ' Признак того, что отчет строится для по всем активностям
	Dim sMsg ' Текст выдаваемого сообщения
	
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