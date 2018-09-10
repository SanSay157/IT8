'----------------------------------------------------------
'	Утилитарные функции
Option Explicit

Dim g_oUserProfile			' As UserProfileClass - глобальный экземпляр описания профиля юзера. 
							' Используется отложенная инициализация. Для обращения использоваться GetCurrentUserProfile

'==============================================================================
' Профиль текущего пользователя
Class UserProfileClass
	Public EmployeeID			' Идентификатор сотрудника (Employee.ObjectID)
	Public SystemUserID			' Идентификатор пользователя приложения (SystemUser.ObjectID)
	Public WorkdayDuration		' Количество МИНУТ в рабочем дне
	
	'==============================================================================
	' Загружает данные с сервера использую команду GetCurrentUserClientProfile
	Public Sub Load()
		Dim oResponse
		On Error Resume Next
		With New XRequest
		    .m_sName = "GetCurrentUserClientProfile"
		    Set oResponse = X_ExecuteCommand( .Self )
	    End With
		If Err Then
			If Not X_HandleError Then
				MsgBox "Ошибка при получении описания текущего пользователя" & vbCr & Err.Description, vbCritical
			End If
		End If
		EmployeeID   = oResponse.m_sEmployeeID
		SystemUserID = oResponse.m_sSystemUserID
		WorkdayDuration = oResponse.m_nWorkdayDuration
	End Sub
	
	
	'==============================================================================
	Function Serialize()
		Serialize = "WD:" & WorkdayDuration & ",EmpID:" & EmployeeID & ",SUID:" & SystemUserID
	End Function


	'==============================================================================
	' 	[in] sSerializedData
	Function Deserialize(sSerializedData)
	    Const AMOUNT_OF_ELEMENTS = 2		' количество элементов в массиве aPairs
	
		Dim aPairs		' массив пар значений свойств
		Dim asPair		' массив из двух элементов: наименование свойства и его значение
		Dim nCount		' Индекс последнего элемента в массиве aPairs
		Dim i
		Deserialize = False
		aPairs = Split(sSerializedData, ",")
		nCount = UBound(aPairs)
		If nCount <> AMOUNT_OF_ELEMENTS Then Exit Function
		For i = 0 To nCount
			asPair = Split( aPairs(i), ":")
			If UBound(asPair) <> 1 Then Exit Function
			Select Case asPair(0)
				Case "WD"	: WorkdayDuration = asPair(1)
				Case "EmpID": EmployeeID = asPair(1)
				Case "SUID" : SystemUserID = asPair(1)
			End Select
		Next
		Deserialize = True
	End Function
End Class


'==============================================================================
' Возвращает закэшированный профиль текущего юзера - экземпляр UserProfileClass
' Если объект не создан, создает и инициализирует его закэшированным данными из кук ("десериализует").
' Если не получилось десериализовать или куки отсутствуют - загружает профиль с помощью команды GetCurrentUserClientProfile
'	[retval] As UserProfileClass
Function GetCurrentUserProfile
	Dim bNeedLoad
	Dim vValue

	bNeedLoad = False
	If IsEmpty(g_oUserProfile) Then
		Set g_oUserProfile = New UserProfileClass
		vValue = GetCachedParameter("UserProfile")
		If Not hasValue(vValue) Then
			bNeedLoad = True
		Else
			If Not g_oUserProfile.Deserialize(vValue) Then
				bNeedLoad
			End If
		End If
		If bNeedLoad Then
			g_oUserProfile.Load()
			vValue = g_oUserProfile.Serialize()
			Document.Cookie = "UserProfile=" & vValue
		End If
	End If
	Set GetCurrentUserProfile = g_oUserProfile
End Function



'==============================================================================
' Возвращает значение параметра, закэшированное в куках документа
'	[retval] Значение параметра или "", или Null, если параметра нет
Function GetCachedParameter(sParamName)
	Dim asCookies		' массив строковых элементов Cookies
	Dim asPair			' массив строковых значений, в который разбивается один элемент массива a_sCookies.
						' Первый элменет этого массива всегда название параметра, второй - его значение.
	Dim i

	GetCachedParameter = Null

	' разобъём строку Cookies на элементы вида: Имя=Значение
	' -1 - число возвращаемых функцией Split значений. Значит, что будут возвращены все.
	asCookies = Split( Document.Cookie, ";", -1, vbTextCompare )

	' в цикле
	For i = 0 To UBound(asCookies)
		' разобьем одно значение по знаку "=".
		asPair = Split( asCookies(i), "=", -1, vbTextCompare )
		' Если имя параметра = имени полученного параметра, возвращаем найденное значение.
		' Trim используется потому, что строка Cookie содержит также разделяющие пробелы
		If Trim( asPair(0) ) = sParamName Then
			If 0=UBound(asPair) Then	' параметр есть, но значения у него нет => возвращаем пустую строку
				GetCachedParameter = ""
				Exit Function
			End If
			GetCachedParameter = Trim ( asPair(1) )
			Exit Function
		End If
	Next
End Function


'==============================================================================
' Возвращает экземпляр XConfigClass с загруженной секцией it:app-data
Function ITConfig()
	Set ITConfig = XConfig("it:app-data")
End Function


'==============================================================================
' Возвращает количество работчих часов в сутках для текущего пользователя
Function GetHoursInDay()
    Const MINUNTES_IN_ONE_HOUR = 60		' число минут в одном часе
	' Примечание: в UserProfileClass::WorkdayDuration содержиться количество минут, поэтому разделем на количество минут в часе
	GetHoursInDay = CLng(GetCurrentUserProfile().WorkdayDuration /MINUNTES_IN_ONE_HOUR)
End Function


'==============================================================================
' Строковое представление часов
' Параметры:
'	[in] nTime - число минут
' Результат:
'	Строка вида "DD дней HH часов MM минут", соответствующая переданному числу минут nTime
Function FormatTimeString(nTime)
	Const MINUNTES_IN_ONE_HOUR = 60		' число минут в одном часе

	Dim sOut			' формируемая строка
	Dim nHours			' число часов
	Dim nDays			' число дней
	Dim nMinutes		' число минут
	Dim nMinsInDay		' число минут в дне
	
	if nTime = 0 then 
		FormatTimeString = "0 часов"
		exit function
	end if		
	
	nMinsInDay = GetHoursInDay() * MINUNTES_IN_ONE_HOUR
	nMinutes = ABS( nTime)
	nDays = Int(nMinutes/nMinsInDay)
	nHours = Int((nMinutes Mod nMinsInDay)/MINUNTES_IN_ONE_HOUR)
	nMinutes = nMinutes Mod MINUNTES_IN_ONE_HOUR


	if nDays > 0 then sOut = nDays & " " & XService.GetUnitForm(nDays, array("дней","день","дня"))
	if nHours > 0 then 
		if not IsEmpty(sOut)  then sOut = sOut & ", "
		sOut = sOut & nHours & " " & XService.GetUnitForm(nHours, array("часов","час","часа"))
	end if
	if nMinutes > 0 then 
		if not IsEmpty(sOut)  then sOut = sOut & ", "
		sOut = sOut & nMinutes & " " & XService.GetUnitForm(nMinutes, array("минут","минута","минуты"))
	end if
	if nTime < 0 then sOut = "- " & sOut	
	
	FormatTimeString =   sOut 
End function



'==============================================================================
' Выполняет источник данных с заданным наименованием (используя команду ExecuteDataSource) 
' с переданными параметрами и возвращает значение первой колонки первой строки результата
'	[in] sDataSourceName 
'	[in] aParamNames
'	[in] aParamValues
Function GetScalarValueFromDataSource(sDataSourceName, aParamNames, aParamValues)
	Dim aValues			' массив значений
	
	aValues = GetFirstRowValuesFromDataSource(sDataSourceName, aParamNames, aParamValues)
	If UBound(aValues) >= 0 Then
		GetScalarValueFromDataSource = aValues(0)
	End If
End Function


'==============================================================================
' Выполняет источник данных с заданным наименованием (используя команду ExecuteDataSource) 
' с переданными параметрами и возвращает массив полей первой строки результата
' (количество и порядок колонок определяются источником данных).
' В случае пустого результата возвращается пустой массив.
'	[in] sDataSourceName 
'	[in] aParamNames
'	[in] aParamValues
'	[retval] Array
Function GetFirstRowValuesFromDataSource(sDataSourceName, aParamNames, aParamValues)
	Dim oParamsBuilder
	Dim oResponse
	Dim oRow
	Dim i
	Dim aValues			' массив значений
	Dim nCount          ' количество значений
	Dim oXmlFields		' As IXMLDOMNodeList
	Dim oParamsCollection
	Set oParamsBuilder = New XmlParamCollectionBuilderClass
	If Not IsNull(aParamNames) Then
		If UBound(aParamNames) <> UBound(aParamValues) Then
			Err.Raise -1, "GetScalarValueFromDataSource", "Размерности массива с наименованием параметров и массива со значениями параметров должны совпадать"
		End If
		' сформируем коллекцию параметров для выполнения источника данных	
		For i=0 To UBound(aParamNames)
			oParamsBuilder.AppendParameter aParamNames(i), aParamValues(i)
		Next
	End If

	On Error Resume Next
    Set oParamsCollection = New XParamsCollection
    Set oParamsCollection.m_oXmlParams = oParamsBuilder.XmlParametersRoot
	With New XExecuteDataSourceRequest
		.m_sName = "ExecuteDataSource"
		.m_sDataSourceName = sDataSourceName
		Set .m_oParams = oParamsCollection
		Set oResponse = X_ExecuteCommand( .Self )
	End With
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
	'	On Error GoTo 0
		Set oRow = oResponse.m_oDataWrapped.m_oXmlDataTable.selectSingleNode("RS/R")
		If Not oRow Is Nothing Then
			Set oXmlFields = oRow.selectNodes("F")
			nCount = oXmlFields.length
			ReDim aValues(nCount-1)
			For i = 0 To nCount-1
				aValues(i) = oXmlFields.item(i).text
			Next
		Else
			aValues = Array()
		End If
	End If
	GetFirstRowValuesFromDataSource = aValues
End Function


'==============================================================================
' Выполняет источник данных с заданным наименованием (используя команду ExecuteDataSource) 
' с переданными параметрами и возвращает массив значений: массив строк-массивов с значениями колонок
' (количество и порядок колонок определяются источником данных).
' В случае пустого результата возвращается пустой массив.
'	[in] sDataSourceName 
'	[in] aParamNames
'	[in] aParamValues
'	[retval] Array
Function GetValuesFromDataSource(sDataSourceName, aParamNames, aParamValues)
	Dim oParamsBuilder
	Dim oResponse
	Dim oRow
	Dim i
	Dim aValues			' массив значений
	Dim oXmlFields		' As IXMLDOMNodeList
	Dim oParams
	Set oParamsBuilder = New XmlParamCollectionBuilderClass
	If Not IsNull(aParamNames) Then
		If UBound(aParamNames) <> UBound(aParamValues) Then
			Err.Raise -1, "GetValuesFromDataSource", "Размерности массива с наименованием параметров и массива со значениями параметров должны совпадать"
		End If
		' сформируем коллекцию параметров для выполнения источника данных	
		For i=0 To UBound(aParamNames)
			oParamsBuilder.AppendParameter aParamNames(i), aParamValues(i)
		Next
	End If

	On Error Resume Next
	Set oParams = New XParamsCollection
	Set oParams.m_oXmlParams = oParamsBuilder.XmlParametersRoot
	With New XExecuteDataSourceRequest
		.m_sName = "ExecuteDataSource"
		.m_sDataSourceName = sDataSourceName
		Set .m_oParams = oParams
		Set oResponse = X_ExecuteCommand( .Self )
	End With
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
		On Error GoTo 0
		Dim oRows ' массив xml-узлов с результатами выполнения источника данных
		Dim nColumnsCount 'количество колонок
		Dim aFieldValues  'массив значений колонок
		Dim nRow 'номер обрабатываемого xml-узла
		
		Set oRows = oResponse.m_oDataWrapped.m_oXmlDataTable.selectNodes("RS/R")
		ReDim aValues(oRows.length-1)
		If oRows.length > 0 Then
			nColumnsCount = oRows.item(0).selectNodes("F").length
		End If
		nRow = 0
		For Each oRow In oRows
			Set oXmlFields = oRow.selectNodes("F")
			ReDim aFieldValues(nColumnsCount-1)
			For i = 0 To nColumnsCount-1
				aFieldValues(i) = oXmlFields.item(i).text
			Next
			aValues(nRow) = aFieldValues
			nRow = nRow + 1
		Next
	End If
	GetValuesFromDataSource = aValues
End Function


'==============================================================================
' Создаёт новое письмо для отправки людям, имеющим отношение к инциденту.
' [in] sIncidentID - ObjectID инцидента
' ВНИМАНИЕ! Использование этой функции требует наличие файла x-create-outlook-letter.vbs
Function MailIncidentLinkToAll(sIncidentID)
	MailTo "Incident", sIncidentID, Null, Null
End Function


'==============================================================================
' Создаёт новое письмо для отправки конкретному юзеру, имеющему отношение к инциденту.
' [in] sIncidentID - ID инцидента
' [in] sEmployeeID - ID сотрудника
' [in] sAuxInfo	- дополнительная информация для вставки в тело письма
' ВНИМАНИЕ! Использование этой функции требует наличие файла x-create-outlook-letter.vbs
Function MailIncidentLinkToUser(sIncidentID, sEmployeeID, sAuxInfo)
	MailTo "Incident", sIncidentID, Array(sEmployeeID), sAuxInfo
End Function


'==============================================================================
' Создаёт новое письмо для отправки конкретному юзеру, имеющему отношение к инциденту.
' [in] sIncidentID - ID инцидента
' [in] sEmployeeID - ID сотрудника
' [in] sAuxInfo	- дополнительная информация для вставки в тело письма
' ВНИМАНИЕ! Использование этой функции требует наличие файла x-create-outlook-letter.vbs
Function MailIncidentLinkToUsers(sIncidentID, aEmployeeIDs, sAuxInfo)
	MailTo "Incident", sIncidentID, aEmployeeIDs, sAuxInfo
End Function


'==============================================================================
' Создаёт новое письмо для отправки заданному сотруднику (менеджеру проекта)
' [in] sProjectID 	- ID проекта
' [in] sEmployeeID - ID сотрудника
' ВНИМАНИЕ! Использование этой функции требует наличие файла x-create-outlook-letter.vbs
Function MailFolderLinkToUser(sProjectID, sEmployeeID, sAuxInfo)
	MailTo "Folder", sProjectID, Array(sEmployeeID), sAuxInfo
End Function


'==============================================================================
' Создаёт новое письмо для отправки всем участникам проектной команды
' [in] sProjectID 	- ID проекта
' ВНИМАНИЕ! Использование этой функции требует наличие файла x-create-outlook-letter.vbs
Function MailFolderLinkToAll(sProjectID)
	MailTo "Folder", sProjectID, Null, Null
End Function

Function Exec_GetMailMsgInfoRequest(sCommandName, sObjectID, sObjectType, aEmployeeIDs)
	With New GetMailMsgInfoRequest
		.m_sName = sCommandName
		.m_sObjectID = sObjectID
		.m_sObjectType = sObjectType
		.m_aEmployeeIDs = aEmployeeIDs
		Set Exec_GetMailMsgInfoRequest = X_ExecuteCommand( .Self )
	End With
End Function

'==============================================================================
' Создаёт новое письмо для отправки людям, имеющим отношение к инциденту или проекту.
' [in] sObjectType 	- Наименование типа объекта, к которому относится письмо: Folder или Incident
' [in] sObjectID	- ID инцидента / проекта
' [in] aEmployeeIDs - массив ID пользователей
' [in] sAuxInfo		- дополнительная информация для вставки в тело письма
' ВНИМАНИЕ! Использование этой функции требует наличие файла x-create-outlook-letter.vbs
Function MailTo( sObjectType, sObjectID, aEmployeeIDs, sAuxInfo)
    Dim oXml			' данные о письме с сервера	
    Dim sParams			' строка параметров для передачи на сервер
    Dim oResponse		' ответ сервеной операции
    Dim sBody			' текст письма
    
    If Len("" & sObjectID) = 0 Then Err.Raise -1, "", "sObjectID is not specified"
    
    if Not window.event Is Nothing Then
		If window.event.srcElement.tagName="A" Then
			window.event.returnValue = False
			window.event.cancelBubble = True
		End If
    End If

    On Error Resume Next
    Set oResponse = Exec_GetMailMsgInfoRequest("GetMailMsgInfo", sObjectID, sObjectType, aEmployeeIDs)
    If Err Then
		If Not X_HandleError Then 
			MsgBox Err.Description
		End If
	Else
		On Error Resume Next
		sBody = vbCr & vbCr & oResponse.m_sFolderPath & vbCr & vbCr & oResponse.m_sProjectLinks
		If hasValue(oResponse.m_sIncidentLinks) Then
			sBody = sBody & vbCr & vbCr & oResponse.m_sIncidentLinks
		End If
		X_CreateOutlookLetter oResponse.m_sTo, "", "", oResponse.m_sSubject, sBody, False, True, XService
	End If
End Function


Dim g_oNameCtrl		' As Name.NameCtrl

' Показывает смарттаг
' [in] sName - email пользователя 
' [in] nCorrectShiftLeft - Некое экспериментально устанавливаемое смещение картинки влево
Sub CrocUserOver(sName, nCorrectShiftLeft)
	' TODO: алгоритм был унаследован из it5 и работает некорректно,поэтому был удален
End Sub


'-------------------------------------------------------------------------
' Скрывает смарттаг
Sub CrocUserOut()
End Sub


'==============================================================================
' Показывает контекстное меню на сотруднике
Sub ShowContextMenuForEmployee(EmployeeID, oMenuMD)
	Dim oMenu 'объект класса MenuClass - меню операций
	Dim oMenuMDXml 'корневой элемент метаданных меню (i:menu), экземпляр IXMLDOMElement
	
	Set oMenuMDXml = XService.XMLFromString(oMenuMD.Value)
	Set oMenu = new MenuClass
	oMenu.Init oMenuMDXml
	oMenu.ShowPopupMenu Nothing
	' обнуляем события контекстного меню
	window.event.returnValue = False
End Sub


'==============================================================================
Sub EmployeeContextMenu_VisibilityHandler(oSender, oEventArgs)
End Sub


'==============================================================================
' ExecutionHandler контекстного меню сотрудника
Sub EmployeeContextMenu_ExecutionHandler(oSender, oEventArgs)
	Select Case oEventArgs.Action
		Case "DoMailAboutIncident"
			MailIncidentLinkToUser oEventArgs.Menu.Macros.item("IncidentID"), oEventArgs.Menu.Macros.item("EmployeeID"), ""
		Case "DoMailAboutFolder"
			MailFolderLinkToUser oEventArgs.Menu.Macros.item("FolderID"), oEventArgs.Menu.Macros.item("EmployeeID"), ""
		Case "DoView"
			X_OpenReport oEventArgs.Menu.Macros.item("ReportURL")
		Case "DoRunReport"
			X_RunReport oEventArgs.Menu.Macros.Item("ReportName"), oEventArgs.Menu.Macros.Item("UrlParams")
		Case Else
			MsgBox "EmployeeContextMenu_ExecutionHandler. Отсутствует обработка команды '" & oEventArgs.Action & "'"
	End Select
End Sub


'==============================================================================
' Открывает диалог поиска инцидента по номеру или имени в дереве проектов
Sub OpenIncidentFinder()
	Dim vRes			' результат выбора в диалоге поиска
	Dim aRes			' массив после разьора результата
	Dim sURL			' адрес вызова странички ввода условий поиска

	sURL = XService.BaseURL & "dlg-IncidentFinder.htm?tm=" & cdbl(now())
	
	' показываем модальный диалог поиска
	vRes = X_ShowModalDialogEx( sURL, null, _
			"dialogHeight:180px;dialogWidth:300px;center:no;resizable:no;status:no;help:no;scroll:no")
	If "" = vRes Then Exit Sub

	' Разбираем результат - он должен состоять из ID инц-та и режима его открытия
	' chr(11) - символ вертикальной табуляции
	aRes = Split( vRes, chr(11) )
	
	' проверяем состав результата - должен поделиться на 2 части
	If UBound( aRes ) <> 1 Then
		Exit Sub
	End If
	Select Case aRes(1)
		Case "OPENINTREE": 	' открываем в дереве
			OpenFindIncidentInTreeByNumber aRes(0)
		Case "OPENINEDITOR": 	' открываем в редакторе
			OpenIncidentInEditorByNumber aRes(0)
		Case "OPENVIEW": 		' открываем на просмотр
			OpenIncidentViewByNumber aRes(0)
	End Select  
End Sub

'==============================================================================
' Открывает диалог поиска проекта по коду в дереве проектов
Sub OpenProjectFinder()
	Dim vRes			' результат выбора в диалоге поиска
	Dim aRes			' массив после разьора результата
	Dim sURL			' адрес вызова странички ввода условий поиска
   
	sURL = XService.BaseURL & "dlg-IncidentFinder.htm?tm=" & cdbl(now())
	
	' показываем модальный диалог поиска
	vRes = X_ShowModalDialogEx( sURL, null, _
			"dialogHeight:180px;dialogWidth:300px;center:no;resizable:no;status:no;help:no;scroll:no")
	If "" = vRes Then Exit Sub

	' Разбираем результат - он должен состоять из ID инц-та и режима его открытия
	' chr(11) - символ вертикальной табуляции
	aRes = Split( vRes, chr(11) )
	
	' проверяем состав результата - должен поделиться на 2 части
	If UBound( aRes ) <> 1 Then
		Exit Sub
	End If
	Select Case aRes(1)
		Case "OPENINTREE": 	' открываем в дереве
			OpenContractInTreeByExtID aRes(0)
		Case "OPENINEDITOR": 	' открываем в редакторе
			OpenContractInEditorByExtID aRes(0)
		Case "OPENVIEW": 		' открываем на просмотр
			'OpenIncidentViewByNumber aRes(0)
	End Select  
End Sub

'==============================================================================
' Открывает дерево ДКП и находит в нем инцидент с заданным идентификатором
Sub OpenFindIncidentInTreeByID(sObjectID)
	OpenFindIncidentInTree sObjectID, Null
End Sub 


'==============================================================================
' Открывает дерево ДКП и находит в нем инцидент с заданным номером
'	[in] sNumber - номер инцидента
Sub OpenFindIncidentInTreeByNumber(sNumber)
    ' Сначала проверим что ввели вместо номера
    If hasValue(sNumber) Then
	    If Not IsNumeric(sNumber) Then
	        MsgBox "Номером Инцидента должно быть целое число", vbExclamation
	        Exit Sub 
	   End If
	End If
	OpenFindIncidentInTree Null, sNumber
End Sub


'==============================================================================
' Открывает дерево ДКП и находит в нем инцидент с заданным идентификатором или номером
Sub OpenFindIncidentInTree(sObjectID, sNumber)
	Dim oResponse		' Ответ серверной операции
	Dim sPath			' Путь
	Dim sURL
	Dim sBaseURL        'Базовая часть адреса страницы
	Dim bIsLocal		'Признак нахождения на странице x-tree.aspx?METANAME=Main
	Dim oQS             'Объект класса QueryStringClass - строка запроса
	On Error Resume Next
	With New IncidentLocatorInTreeRequest
		.m_sName = "IncidentLocatorInTree"
		.m_sIncidentOID = sObjectID
		.m_nIncidentNumber = sNumber
		Set oResponse = X_ExecuteCommand( .Self )
	End With
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
    On Error Goto 0
		If Len("" & oResponse.m_sPath) = 0 Then
			If hasValue(sNumber) Then
				MsgBox "Инцидент с номером " & sNumber & " не найден", vbInformation
			Else
				MsgBox "Инцидент с идентификатором " & sObjectID & " не найден", vbInformation
			End If
		Else
			bIsLocal = False
			sPath = oResponse.m_sPath
			
			' Вычислим факт присутствия на странице дерева ДКП. 
			' Если мы там, то вызовем локальную процедуру LocateNodeInDKPTree, иначе перейдем на эту страницу
			
			' получим полный адрес текущей страницы
			sURL = window.location.protocol & "//" & window.location.host & window.location.pathname
			sBaseURL = XService.BaseURL 
			' уберем из него сервер и каталог, оставим имя файла
			sURL = Mid(sURL, Len(sBaseURL) + 1, Len(sURL) - Len(sBaseURL))
			If LCase(sURL) = "x-tree.aspx" Then
				sURL = window.location.search
				If Len(sURL) > 0 Then
					Set oQS = X_GetEmptyQueryString
					' отрежем первый символ "?", то есть 2 - начальная позиция возвращаемых знаков
					oQS.QueryString = Mid(sURL, 2, Len(sURL) - 1)
					If UCase(oQS.GetValue("metaname", "")) = "MAIN" Then
						bIsLocal = True
					End If
				End If
			End If
			
			If bIsLocal Then
				LocateNodeInDKPTree sPath, Null, Null
			Else
				' ВНИМАНИЕ: т.к. мы находимся в потоке выполнения обработчика меню, 
				' то свойство MayBeInterrapted XList'a будет false, 
				' поэтому синхронный уход со страницы вызовет показ предупреждающего диалога.
				' Чтобы этого избежать используем асинхронный вызов
				window.setTimeout "window.navigate """ & sBaseURL & "x-tree.aspx?METANAME=Main" & "&INITPATH=" & sPath & """", 50, "VBScript"
			End If
		End If
	End If
End Sub

Function Exec_GetObjectIdByExKeyRequest(sCommandName, sTypeName, sDataSourceName, oParams)
	With New GetObjectIdByExKeyRequest
		.m_sName = sCommandName
		.m_sTypeName = sTypeName
		.m_sDataSourceName = sDataSourceName
		Set .m_oParams = oParams
		Set Exec_GetObjectIdByExKeyRequest = X_ExecuteCommand( .Self )
	End With
End Function

'==============================================================================
' Открывает редактор инцидента с заданным номером
'	[in] sNumber - номер инцидента
Sub OpenIncidentInEditorByNumber(sNumber)
	Dim oXmlParams   'колллекция параметров в формате xml
	Dim oResponse    'объект - результат вызова операции
	Dim oParamCollection  'коллекция параметров
	' Сначала проверим что ввели вместо номера
	If hasValue(sNumber) Then
	    If Not IsNumeric(sNumber) Then
	        MsgBox "Номером Инцидента должно быть целое число", vbExclamation
	        Exit Sub 
	   End If
	End If
    On Error Resume Next
	Set oXmlParams = New XmlParamCollectionBuilderClass
	oXmlParams.AppendParameter "Number", sNumber
	Set oParamCollection = New XParamsCollection
	Set oParamCollection.m_oXmlParams = oXmlParams.XmlParametersRoot
	Set oResponse = Exec_GetObjectIdByExKeyRequest("GetObjectIdByExKey", "Incident", Null, oParamCollection)
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
		On Error Goto 0
		If (oResponse.m_sObjectID = GUID_EMPTY) Then
			MsgBox "Инцидент с номером " & sNumber & " не найден.", vbExclamation
	        Exit Sub 
		End If
		
		X_OpenObjectEditor "Incident", oResponse.m_sObjectID, "", ""
	End If
End Sub


'==============================================================================
' Открывает форму просмотр инцидента с заданным номером
'	[in] sNumber - номер инцидента
Sub OpenIncidentViewByNumber(sNumber)
' Сначала проверим что ввели вместо номера
    If hasValue(sNumber) Then
	    If Not IsNumeric(sNumber) Then
	        MsgBox "Номером Инцидента должно быть целое число", vbExclamation
	        Exit Sub 
	   End If
	End If
	X_RunReport "Incident", "IncidentNumber=" & sNumber
End Sub


'==============================================================================
' Проверяет тип и идентификатор текущего активного узла дерева на совпадение с заданными
'	[in] oTreeView As CROC.IXTreeView
'	[in] sObjectID - идентификатор искомого узла
'	[in] sType - тип искомого узла
'	[retval] Если заданный узел выбран True, иначе False
Function CheckActiveNode(oTreeView, sType, sObjectID)
	Dim oActiveNode		' As IXTreeNode
	
	CheckActiveNode = False
	Set oActiveNode = oTreeView.ActiveNode
	If Not oActiveNode Is Nothing Then
		If oActiveNode.ID = sObjectID And oActiveNode.Type = sType Then
			CheckActiveNode = True
		End If
	End If
End Function


'==============================================================================
' Производит открывает список диалоговым окном
'	[in] sMetaName	- имя списка в метаданных 
'	[in] sOT		- наименование типа, в метаданных которого располагается описание списка (i:objects-list)
'	[in] nMode		- Режим отбора (LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE)
'	[in] sParams	- Строка параметров для i:data-source. Строка из пар Param1=Value1, разделенных "&". 
'					Для получении строки параметров можно использовать класс QueryStringParamCollectionBuilderClass
'	[in] sAddURL	- Дополнительные параметры, передаваемые в УРЛ загрузчику списка...
'		Использование  параметров описано в файле x-list.aspx, x-list-page.vbs
Sub IT_OpenXListInDialog( byval sMetaName, sOT, nMode, sParams, sAddUrl, sHeght, sWidth)
	Dim sURL						' URL вызова
	'Получим URL диалога	
	sURL =  "OT=" & sOT & "&MODE=" & nMode
	If Len(sMetaName) Then  sURL = sURL & "&METANAME=" & sMetaName 
	If Len(sParams)   Then  sURL = sURL & "&RESTR=" & XService.UrlEncode(sParams)
	If Len(sAddUrl)   Then
		If Left(sAddUrl,1) <> "&" Then sURL = sURL & "&"
		sURL = sURL & sAddUrl
	End If
	With X_GetEmptyQueryString
		.QueryString = sUrl
		'Покажем диалог
		X_ShowModalDialogEx _
		    "x-list.aspx?OT=" & sOT & "&METANAME=" & sMetaname & "&MODE=" & nMode & "&TM=" & CDbl(Now), _
		    .Self , _
		    "dialogHeight:" & sHeght & ";dialogWidth:" & sWidth & ";help:no;center:yes;status:no"
	End With	
End Sub


'==============================================================================
' Показывает UI настройки подписки текущего пользователя на событие
Sub OpenUserEventTypeSubscriptionEditor()
	OpenUserEventTypeSubscriptionEditorEx 0
End Sub

Sub OpenUserEventTypeSubscriptionEditorEx(nEventClass)
	Dim sUrl
	sUrl = "METANAME=UserSubscription"
	If nEventClass>0 Then
		If nEventClass>15 Then
			sUrl = sUrl & "&INITPATH=EventType|0|EventClass|00000000-0000-0000-0000-0000000000" & LCase(Hex(nEventClass))
		Else
			sUrl = sUrl & "&INITPATH=EventType|0|EventClass|00000000-0000-0000-0000-00000000000" & LCase(Hex(nEventClass))
		End If
	End If
	X_ShowModalDialogEx _
		XService.BaseUrl & "x-tree.aspx?NONAVPANE=1&METANAME=UserSubscription", _
		sUrl, _
		"dialogHeight:600px; dialogWidth:750px; help:no; center:yes; status:no; resizable:yes;"
End Sub

'==============================================================================
' Открывает дерево ДКП и находит в нем папку с заданным идентификатором
Sub OpenFindFolderInTree(sObjectID)
	Dim oResponse		' Ответ серверной операции
	Dim sPath			' Путь
	Dim sURL
	Dim sBaseURL        'Базовая часть адреса страницы
	Dim bIsLocal		'Признак нахождения на странице x-tree.aspx?METANAME=Main
	Dim oQS             'Объект класса QueryStringClass - строка запроса
	On Error Resume Next
	With New FolderLocatorInTreeRequest
        .m_sName = "FolderLocatorInTree"
        .m_sFolderOID = sObjectID
        Set oResponse = X_ExecuteCommand( .Self )
    End With
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
    On Error Goto 0
		If Len("" & oResponse.m_sPath) = 0 Then
			MsgBox "Папка с идентификатором " & sObjectID & " не найдена", vbInformation
		Else
			bIsLocal = False
			sPath = oResponse.m_sPath
			
			' Вычислим факт присутствия на странице дерева ДКП. 
			' Если мы там, то вызовем локальную процедуру LocateNodeInDKPTree, иначе перейдем на эту страницу
			
			' получим полный адрес текущей страницы
			sURL = window.location.protocol & "//" & window.location.host & window.location.pathname
			sBaseURL = XService.BaseURL 
			' уберем из него сервер и каталог, оставим имя файла
			sURL = Mid(sURL, Len(sBaseURL) + 1, Len(sURL) - Len(sBaseURL))
			If LCase(sURL) = "x-tree.aspx" Then
				sURL = window.location.search
				If Len(sURL) > 0 Then
					Set oQS = X_GetEmptyQueryString
					' отрежем первый символ "?", то есть 2 - начальная позиция возвращаемых знаков
					oQS.QueryString = Mid(sURL, 2, Len(sURL) - 1)
					If UCase(oQS.GetValue("metaname", "")) = "MAIN" Then
						bIsLocal = True
					End If
				End If
			End If
			
			If bIsLocal Then
				LocateNodeInDKPTree sPath, Null, Null
			Else
				' ВНИМАНИЕ: т.к. мы находимся в потоке выполнения обработчика меню, 
				' то свойство MayBeInterrapted XList'a будет false, 
				' поэтому синхронный уход со страницы вызовет показ предупреждающего диалога.
				' Чтобы этого избежать используем асинхронный вызов
				window.setTimeout "window.navigate """ & sBaseURL & "x-tree.aspx?METANAME=Main" & "&INITPATH=" & sPath & """", 50, "VBScript"
			End If
		End If
	End If
End Sub

'==============================================================================
' Открывает редактор приходного договора по коду проекта
'	[in] sNumber - код проекта
Sub OpenContractInEditorByExtID(sExternalID)
	Dim oXmlParams   'колллекция параметров в формате xml
	Dim oResponse    'объект - результат вызова операции
	Dim oParamCollection  'коллекция параметров
	
    On Error Resume Next
	Set oXmlParams = New XmlParamCollectionBuilderClass
	oXmlParams.AppendParameter "ExternalID", sExternalID
	Set oParamCollection = New XParamsCollection
	Set oParamCollection.m_oXmlParams = oXmlParams.XmlParametersRoot
	Set oResponse = Exec_GetObjectIdByExKeyRequest("GetObjectIdByExKey", "Folder", Null, oParamCollection)
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
		On Error Goto 0
		If (oResponse.m_sObjectID = GUID_EMPTY) Then
			MsgBox "Проект с кодом " & sExternalID & " не найден.", vbExclamation
	        Exit Sub 
		End If
	End If
	
	Set oXmlParams = New XmlParamCollectionBuilderClass
	oXmlParams.AppendParameter "Project", oResponse.m_sObjectID
	Set oParamCollection = New XParamsCollection
	Set oParamCollection.m_oXmlParams = oXmlParams.XmlParametersRoot
	Set oResponse = Exec_GetObjectIdByExKeyRequest("GetObjectIdByExKey", "Contract", Null, oParamCollection)
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
		On Error Goto 0
		If (oResponse.m_sObjectID = GUID_EMPTY) Then
			MsgBox "Приходный договор с кодом проекта " & sExternalID & " не найден.", vbExclamation
	        Exit Sub 
		End If
		
		X_OpenObjectEditor "Contract", oResponse.m_sObjectID, "", ""
	End If
End Sub

'==============================================================================
' Открывает дерево ДКП и находит в нем папку с заданным идентификатором
Sub OpenContractInTreeByExtID(sExternalID)
	Dim oResponse		' Ответ серверной операции
	Dim sPath			' Путь
	Dim sURL
	Dim sBaseURL        'Базовая часть адреса страницы
	Dim bIsLocal		'Признак нахождения на странице x-tree.aspx?METANAME=Main
	Dim oQS             'Объект класса QueryStringClass - строка запроса
	On Error Resume Next
	With New ContractLocatorInTreeRequest
        .m_sName = "ContractLocatorInTree"
        .m_sExternalID = sExternalID
        Set oResponse = X_ExecuteCommand( .Self )
    End With
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
    On Error Goto 0
		If Len("" & oResponse.m_sPath) = 0 Then
			MsgBox "Папка с идентификатором " & sObjectID & " не найдена", vbInformation
		Else
			bIsLocal = False
			sPath = oResponse.m_sPath
			
			' Вычислим факт присутствия на странице дерева ДКП. 
			' Если мы там, то вызовем локальную процедуру LocateNodeInDKPTree, иначе перейдем на эту страницу
			
			' получим полный адрес текущей страницы
			sURL = window.location.protocol & "//" & window.location.host & window.location.pathname
			sBaseURL = XService.BaseURL 
			' уберем из него сервер и каталог, оставим имя файла
			sURL = Mid(sURL, Len(sBaseURL) + 1, Len(sURL) - Len(sBaseURL))
			If LCase(sURL) = "x-tree.aspx" Then
				sURL = window.location.search
				If Len(sURL) > 0 Then
					Set oQS = X_GetEmptyQueryString
					' отрежем первый символ "?", то есть 2 - начальная позиция возвращаемых знаков
					oQS.QueryString = Mid(sURL, 2, Len(sURL) - 1)
					If UCase(oQS.GetValue("metaname", "")) = "MAIN" Then
						bIsLocal = True
					End If
				End If
			End If
			
			If bIsLocal Then
				LocateNodeInDKPTree sPath, Null, Null
			Else
				' ВНИМАНИЕ: т.к. мы находимся в потоке выполнения обработчика меню, 
				' то свойство MayBeInterrapted XList'a будет false, 
				' поэтому синхронный уход со страницы вызовет показ предупреждающего диалога.
				' Чтобы этого избежать используем асинхронный вызов
				window.setTimeout "window.navigate """ & sBaseURL & "x-tree.aspx?METANAME=Main" & "&INITPATH=" & sPath & """", 50, "VBScript"
			End If
		End If
	End If
End Sub
