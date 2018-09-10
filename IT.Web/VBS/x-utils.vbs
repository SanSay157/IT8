'<SCRIPT LANGUAGE="VBScript">
'===============================================================================
'@@!!FILE_x-utils
'<GROUP !!SYMREF_VBS>
'<TITLE x-utils - Общие функции Web-клиента XFW .NET >
':Назначение:
'	Набор общих функций, процедур и классов, используемых в реализации 
'	Web-клиента XFW .NET.
':См. также:
'	<LINK !!FILE_x-vbs, x-vbs - Общие утилитарные функции\, "расширение" VBScript />
'===============================================================================
'@@!!CONSTANTS_x-utils
'<GROUP !!FILE_x-utils><TITLE Константы>
'@@!!FUNCTIONS_x-utils
'<GROUP !!FILE_x-utils><TITLE Функции и процедуры>
'@@!!CLASSES_x-utils
'<GROUP !!FILE_x-utils><TITLE Классы>

Option Explicit

Dim x_nWaitForTrueID		' Уникальный в рамках данной страницы идентификатор, используемый функцией X_WaitForTrue	
Dim x_nErrNumber			' Номер ошибки
Dim x_sErrSrc				' Источник ошибки
Dim x_sErrDesc				' Описание ошибки
Dim x_oMD					' Метаданные на клиенте...
Dim x_bMD					' и признак их наличия...
Dim x_oLastServerError		' As ErrorInfoClass - описание последней ошибки при вызове серверной операции
Dim x_oRightsCache			' As ObjectRightsCacheClass - Кэш прав. Доступ должен осуществляться только через функцию-аксессор X_RightsCache!
Dim x_oConfig				' As ConfigClass - Клиентская обертка для доступа к файлу конфигурации. Доступ должен осуществляться только через функцию-аксессор X_Config!

Set x_oLastServerError = Nothing

'==============================================================================
' Константа - название хранилища - кэша метаданных и идентификатор 
' элемента DIV, используемого как контейнер для userData
const META_DATA_STORE = "XMetaDataStore"
const META_DATA_DEBUG_ATTR = "is-debug-mode"
const XCONFIG_STORE = "XConfigStore"	' наименование хранилища - кэша xconfig'a


'==============================================================================
'@@ACCESS_RIGHT_nnnn
'<GROUP !!CONSTANTS_x-utils><TITLE ACCESS_RIGHT_nnnn>
':Назначение:	Константы видов операций над объектами.

'@@ACCESS_RIGHT_CREATE
'<GROUP ACCESS_RIGHT_nnnn>
':Назначение:	Операция создания объекта (Create).
const ACCESS_RIGHT_CREATE	= "Create"

'@@ACCESS_RIGHT_CHANGE
'<GROUP ACCESS_RIGHT_nnnn>
':Назначение:	Операция модификации объекта (Edit).
const ACCESS_RIGHT_CHANGE	= "Edit"

'@@ACCESS_RIGHT_DELETE
'<GROUP ACCESS_RIGHT_nnnn>
':Назначение:	Операция удаления объекта (Delete).
const ACCESS_RIGHT_DELETE	= "Delete"

'==============================================================================
'@@CACHE_BEHAVIOR_nnnn
'<GROUP !!CONSTANTS_x-utils><TITLE CACHE_BEHAVIOR_nnnn>
':Назначение:	Константы видов взаимодействия с кэшем.

'@@CACHE_BEHAVIOR_NOT_USE
'<GROUP CACHE_BEHAVIOR_nnnn>
':Назначение:	Кэш не используется.
const CACHE_BEHAVIOR_NOT_USE	= 0

'@@CACHE_BEHAVIOR_USE
'<GROUP CACHE_BEHAVIOR_nnnn>
':Назначение:	Кэш используется.
const CACHE_BEHAVIOR_USE		= 1

'@@CACHE_BEHAVIOR_ONLY_WRITE
'<GROUP CACHE_BEHAVIOR_nnnn>
':Назначение:	Происходит безусловная перезапись кэша значениями с сервера.
const CACHE_BEHAVIOR_ONLY_WRITE	= 2

'===============================================================================
'@@X_CreateGuid
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CreateGuid>
':Назначение:	
'	Генерирует уникальный GUID и возвращает его строковое представление, 
'	приведенное в нижний регистр.
':Сигнатура:
'	Function X_CreateGuid() [As String]
Function X_CreateGuid()
	X_CreateGuid = LCase(XService.NewGuidString)
End Function

' Вариант X_CreateGuid(), оставленный для совместимости с старым кодом
' НЕ УДАЛЯТЬ! В НОВОМ КОДЕ НЕ ИСПОЛЬЗОВАТЬ!
Function CreateGuid()
	CreateGuid = LCase(XService.NewGuidString)
End Function

'===============================================================================
'@@ErrorInfoClass
'<GROUP !!CLASSES_x-utils><TITLE ErrorInfoClass>
':Назначение:	
'	Класс инкапсулирует описание ошибки, произошедшей в процессе вызова или
'	выполнения операции сервера приложения.
'
'@@!!MEMBERTYPE_Methods_ErrorInfoClass
'<GROUP ErrorInfoClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_ErrorInfoClass
'<GROUP ErrorInfoClass><TITLE Свойства>
Class ErrorInfoClass

	'------------------------------------------------------------------------------
	'@@ErrorInfoClass.LastServerError
	'<GROUP !!MEMBERTYPE_Properties_ErrorInfoClass><TITLE LastServerError>
	':Назначение:	
	'	Свойство CROC.XClientService.LastServerError. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public LastServerError [As IXMLDOMElement]
	Public LastServerError
	
	'------------------------------------------------------------------------------
	'@@ErrorInfoClass.ErrDescription
	'<GROUP !!MEMBERTYPE_Properties_ErrorInfoClass><TITLE ErrDescription>
	':Назначение:	
	'	Описание ошибки (Err.Description). 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ErrDescription [As String]
	Public ErrDescription
	
	'------------------------------------------------------------------------------
	'@@ErrorInfoClass.ErrSource
	'<GROUP !!MEMBERTYPE_Properties_ErrorInfoClass><TITLE ErrSource>
	':Назначение:	
	'	Источник ошибки (Err.Source). 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ErrSource [As String]
	Public ErrSource
	
	'------------------------------------------------------------------------------
	'@@ErrorInfoClass.ErrNumber
	'<GROUP !!MEMBERTYPE_Properties_ErrorInfoClass><TITLE ErrNumber>
	':Назначение:	
	'	Номер ошибки (Err.Number). 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ErrNumber [As Int]
	Public ErrNumber

	'---------------------------------------------------------------------------
	' Инициализация экземпляра
	Private Sub Class_Initialize
		Set LastServerError = Nothing
		ErrNumber = 0
	End Sub
	
	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.IsSecurityException
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE IsSecurityException>
	':Назначение:
	'   Возвращает True, если описываемая экземпляром ошибка есть экземпляр класса 
	'   <LINK Croc.XmlFramework.Public.XSecurityException, XSecurityException />, 
	'   сгенерированный сервером приложения.
	':См. также:	ErrorInfoClass.IsBusinessLogicException, 
	'				ErrorInfoClass.IsObjectNotFoundException, 
	'				ErrorInfoClass.IsOutdatedTimestampException, 
	'				ErrorInfoClass.IsServerError
	':Сигнатура:	Public Function IsSecurityException [As Boolean]
	Public Function IsSecurityException
		IsSecurityException = X_IsSecurityException(LastServerError)
	End Function 

	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.IsBusinessLogicException
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE IsBusinessLogicException>
	':Назначение:	
	'   Возвращает True, если описываемая экземпляром ошибка есть экземпляр класса
	'   <LINK Croc.XmlFramework.Public.XBusinessLogicException, XBusinessLogicException />, 
	'   сгенерированный сервером приложения.
	':См. также:	ErrorInfoClass.IsSecurityException, 
	'				ErrorInfoClass.IsObjectNotFoundException, 
	'				ErrorInfoClass.IsOutdatedTimestampException, 
	'				ErrorInfoClass.IsServerError
	':Сигнатура:	Public Function IsBusinessLogicException [As Boolean]
	Public Function IsBusinessLogicException
		IsBusinessLogicException = X_IsBusinessLogicException(LastServerError)
	End Function 

	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.IsObjectNotFoundException
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE IsObjectNotFoundException>
	':Назначение:	
	'   Возвращает True, если описываемая экземпляром ошибка есть экземпляр класса
	'	<LINK Croc.XmlFramework.Data.XObjectNotFoundException, XObjectNotFoundException />, 
	'   сгенерированный сервером приложения.
	':См. также:	ErrorInfoClass.IsSecurityException, 
	'				ErrorInfoClass.IsBusinessLogicException, 
	'				ErrorInfoClass.IsOutdatedTimestampException, 
	'				ErrorInfoClass.IsServerError	
	':Сигнатура:	Public Function IsObjectNotFoundException [As Boolean]
	Public Function IsObjectNotFoundException
		IsObjectNotFoundException = X_IsObjectNotFoundException(LastServerError)
	End Function 

	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.IsOutdatedTimestampException
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE IsOutdatedTimestampException>
	':Назначение:	
	'   Возвращает True, если описываемая экземпляром ошибка есть экземпляр класса
	'	<LINK Croc.XmlFramework.Data.XOutdatedTimestampException, XOutdatedTimestampException />, 
	'   сгенерированный сервером приложения.
	':См. также:	ErrorInfoClass.IsSecurityException, 
	'				ErrorInfoClass.IsBusinessLogicException, 
	'				ErrorInfoClass.IsObjectNotFoundException, 
	'				ErrorInfoClass.IsServerError
	':Сигнатура:	Public Function IsSecurityException [As Boolean]
	Public Function IsOutdatedTimestampException
		IsOutdatedTimestampException = X_IsOutdatedTimestampException(LastServerError)
	End Function
	
	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.IsServerError
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE IsServerError>
	':Назначение:	
	'   Возвращает True, если описываемая экземпляром ошибка есть исключение, 
	'   сгенерированное сервером приложения.
	':См. также:	ErrorInfoClass.IsSecurityException, 
	'				ErrorInfoClass.IsBusinessLogicException, 
	'				ErrorInfoClass.IsObjectNotFoundException, 
	'				ErrorInfoClass.IsOutdatedTimestampException
	':Сигнатура:	Public Function IsServerError [As Boolean]
	Public Function IsServerError
		IsServerError = Not LastServerError Is Nothing
	End Function
	
	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.RaiseError
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE RaiseError>
	':Назначение:	В соответствии с данными, описываемыми экземпляром, 
	'				генерирует ошибку времени исполнения VBScript.
	':См. также:	ErrorInfoClass.ShowDebugDialog
	':Сигнатура:	Public Sub RaiseError
	Public Sub RaiseError
		Err.Raise ErrNumber, ErrSource, ErrDescription
	End Sub
	
	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.ShowDebugDialog
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE ShowDebugDialog>
	':Назначение:	Отображает диалог сообщения об ошибке.
	':См. также:	ErrorInfoClass.Show
	':Сигнатура:	Public Sub ShowDebugDialog
	Public Sub ShowDebugDialog
		Dim oDlg	' As CROC.XErrorDialog
		If IsServerError Then
			Set oDlg = XService.CreateErrorDialog("", ERRDLG_ICON_ERROR, LastServerError.getAttribute("user-msg"), LastServerError.getAttribute("sys-msg"))
			oDlg.ShowModal
		Else
			Set oDlg = XService.CreateErrorDialog("", ERRDLG_ICON_ERROR, ErrDescription)
			oDlg.ShowModal
		End If
	End Sub
	
	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.Show
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE Show>
	':Назначение:	
	'	Отображает диалог с сообщением об ошибке. Вид диалога и текст сообщения 
	'	в диалоге определяются в зависимости от типа ошибки (типа исключения, 
	'	сгенерированного сервером приложения).
	':Примечание:	
	'	Зависимость вида диалога от типа ошибки:
	'	- <LINK Croc.XmlFramework.Public.XSecurityException, XSecurityException /> - предупреждение с фиксированным текстом "В доступе отказано";
	'	- <LINK Croc.XmlFramework.Public.XBusinessLogicException, XBusinessLogicException /> - сообщение, текст сообщения передается в исключении;
	'	- <LINK Croc.XmlFramework.Data.XObjectNotFoundException, XObjectNotFoundException /> - предупреждение с фиксированным текстом "Объект не найден";
	'	- <LINK Croc.XmlFramework.Data.XOutdatedTimestampException, XOutdatedTimestampException /> - предупреждение с указанием о том, что данные изменяемого объекта устарели, диалог включает системную часть (полный стек исключения).
	'   Во всех остальных случаях отображется диалог с ошибкой.
	':См. также:	ErrorInfoClass.ShowDebugDialog
	':Сигнатура:	Public Sub Show
	Public Sub Show
		Dim sMsg
		Dim oDlg	' As CROC.XErrorDialog
		
		If IsSecurityException Then
			sMsg = "" & LastServerError.getAttribute("user-msg")
			If Len(sMsg) = 0 Then
				sMsg = "В доступе отказано"
			End If
			Set oDlg = XService.CreateErrorDialog("", ERRDLG_ICON_SECURITY, sMsg)
			oDlg.ShowModal
		ElseIf IsObjectNotFoundException Then
			alert "Объект не найден, возможно он был удалён другим пользователем"
		ElseIf IsOutdatedTimestampException Then
			sMsg = "Другой пользователь изменил данные, которые Вы пытаетесь сохранить. Вам необходимо закрыть редактор без сохранения, и снова повторить все изменения."
			Set oDlg = XService.CreateErrorDialog("", ERRDLG_ICON_WARNING, sMsg, LastServerError.getAttribute("sys-msg"))
			oDlg.ShowModal
		ElseIf IsBusinessLogicException Then
			Set oDlg = XService.CreateErrorDialog("", ERRDLG_ICON_INFORMATION, LastServerError.getAttribute("user-msg"), LastServerError.getAttribute("sys-msg"))
			oDlg.ShowModal
		Else
			ShowDebugDialog
		End If
	End Sub
End Class

'===============================================================================
'@@X_SetLastServerError
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SetLastServerError>
':Назначение:
'	Процедура устанавливает описание серверной ошибки.
':Параметры:
'	oLastServerError - 
'       [in] узел <b>x-res</b>, возвращаемый CROC.XClientService.LastServerError.
'	nErrNumber - 
'       [in] номер ошибки.
'	sErrSource - 
'       [in] источник ошибки.
'	sErrDescription - 
'       [in] описание ошибки.
':Сигнатура:
'	Sub X_SetLastServerError(
'       oLastServerError [As IXMLDOMElement],
'       nErrNumber [As Int],
'       sErrSource [As String],
'       sErrDescription [As String]
'   )
Sub X_SetLastServerError(oLastServerError, nErrNumber, sErrSource, sErrDescription)
	If Not IsObject(oLastServerError) Then Err.Raise -1, "X_SetLastServerError", "oLastServerError должен быть объектом XMLDOMElement"
	Set x_oLastServerError = New ErrorInfoClass
	Set x_oLastServerError.LastServerError = oLastServerError
	x_oLastServerError.ErrNumber = nErrNumber
	x_oLastServerError.ErrSource = sErrSource
	x_oLastServerError.ErrDescription = sErrDescription
End Sub


'===============================================================================
'@@X_ClearLastServerError
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ClearLastServerError>
':Назначение:
'	Процедура сбрасывает описание ошибки последней серверной операции.
':Сигнатура:
'	Sub X_ClearLastServerError
Sub X_ClearLastServerError
	Set x_oLastServerError = Nothing
End Sub


'===============================================================================
'@@X_GetLastError
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetLastError>
':Назначение:
'	Функция возвращает описание серверной ошибки, установленное ранее с помощью
'   процедуры <LINK X_SetLastServerError, X_SetLastServerError />.
':Результат:
'	Узел <b>x-res</b>, возвращаемый CROC.XClientService.LastServerError.
':Сигнатура:
'	Function X_GetLastError () [As IXMLDOMElement]
Function X_GetLastError()
	Set X_GetLastError = x_oLastServerError 
End Function


'===============================================================================
'@@X_WasErrorOccured
'<GROUP !!FUNCTIONS_x-utils><TITLE X_WasErrorOccured>
':Назначение:
'	Функция возвращает признак того, что было установлено описание серверной ошибки 
'   (через процедуру <LINK X_SetLastServerError, X_SetLastServerError />).
':Результат:
'	True - было установлено описание серверной ошибки, False - в противном случае.
':Сигнатура:
'	Function X_WasErrorOccured [As Boolean]
Function X_WasErrorOccured
	X_WasErrorOccured = Not x_oLastServerError Is Nothing
End Function


'===============================================================================
'@@X_GetAttributeDef
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetAttributeDef>
':Назначение:
'	Функция возвращает значение атрибута элемента.
':Параметры:
'	oDOMElement - 
'       [in] элемент XML-документа, у которого запрашивается значение атрибута.
'	sAttrName - 
'       [in] имя атрибута.
'	vDefVal - 
'       [in] значение атрибута по умолчанию.
':Сигнатура:
'	Function X_GetAttributeDef (
'       oDOMElement [As IXMLDOMElement],
'       sAttrName [As String],
'       vDefVal [As Variant]
'   ) [As Variant]
Function X_GetAttributeDef( oDOMElement, sAttrName, vDefVal)
	Dim vVal	' Значение атрибута
	vVal = oDOMElement.getAttribute(sAttrName)
	If IsNull( vVal) Then
		X_GetAttributeDef = vDefVal
	Else
		X_GetAttributeDef = vVal
	End If
End Function


'===============================================================================
'@@X_GetChildValueDef
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetChildValueDef>
':Назначение:
'	Функция возвращает значение подчиненного узла элемента.
':Параметры:
'	oDOMElement - 
'       [in] элемент XML-документа, у которого запрашивается значение подчиненного 
'       узла элемента.
'	sChildName - 
'       [in] имя подчиненного узла элемента.
'	vDefVal - 
'       [in] значение атрибута по умолчанию.
':Сигнатура:
'	Function X_GetChildValueDef (
'       oDOMElement [As IXMLDOMElement],
'       sChildName [As String],
'       vDefVal [As Variant]
'   ) [As Variant]
Function X_GetChildValueDef( oDOMElement, sChildName, vDefVal)
	Dim oChild  'подчиненный узел
	Set oChild = oDOMElement.selectSingleNode(sChildName)
	If oChild Is Nothing Then
		X_GetChildValueDef = vDefVal
	Else
		X_GetChildValueDef = oChild.nodeTypedValue
	End If
End Function


'===============================================================================
'@@X_DisableWaitForTrue
'<GROUP !!FUNCTIONS_x-utils><TITLE X_DisableWaitForTrue>
':Назначение:
'	Процедура прерывает обработку процедуры <LINK X_WaitForTrue, X_WaitForTrue /> 
'   при выгрузке страницы.
':Сигнатура:
'	Sub X_DisableWaitForTrue()
Sub X_DisableWaitForTrue() 
	x_nWaitForTrueID = Empty
End Sub

'===============================================================================
'@@X_WaitForTrue
'<GROUP !!FUNCTIONS_x-utils><TITLE X_WaitForTrue>
':Назначение:
'	Процедура вызывает процедуру с именем, заданным в параметре <b><i>sProcName</b></i> 
'   при истинности выражения, заданного в параметре <b><i>sExpr</b></i>.
':Параметры:
'	sProcName - 
'       [in] имя вызываемой процедуры.
'	sExpr - 
'       [in] строка с логическим выражением на VBScript.
':Сигнатура:
'	Sub X_WaitForTrue( sProcName [As String], sExpr [As String] )
Sub X_WaitForTrue( sProcName, sExpr)
	' При первом запуске
	if IsEmpty( x_nWaitForTrueID) Then 
		'...сформируем уникальный ID...
		Randomize
		x_nWaitForTrueID = CLng( Rnd() * 100000)	' Формируем случайное целое от 0 до 100000
		'...который будет сброшен при выгрузке
		window.attachEvent "onunload" , GetRef("X_DisableWaitForTrue")
	End if
	' И вызовем внутренний обработчик
	window.setTimeout _
		"X_WaitForTrueInternal """ & _
		X_VBEncode(sProcName)  & _
		""", """ & _
		X_VBEncode(sExpr) & """," & x_nWaitForTrueID , _
		0, "VBScript"
End Sub


'===============================================================================
':Назначение:
'	Процедура вызывает процедуру с именем, заданным в параметре <b><i>sProcName</b></i> 
'   при истинности выражения, заданного в параметре <b><i>sExpr</b></i>, и совпадении
'   текущего ID с переданным.
':Параметры:
'	sProcName - 
'       [in] имя вызываемой процедуры.
'	sExpr - 
'       [in] строка с логическим выражением на VBScript.
'	nCurrentID - 
'       [in] ключ для сравнения.
':Сигнатура:
'	Sub X_WaitForTrueInternal (
'       sProcName [As String], 
'       sExpr [As String],
'       nCurrentID [As Int]
'    )
Sub X_WaitForTrueInternal( sProcName, sExpr, nCurrentID)
	' Если текущий ID и переданный различны - значит страница была перегружена и выполнять ничего не надо
	if IsEmpty(nCurrentID) or IsEmpty(x_nWaitForTrueID) or (nCurrentID <> x_nWaitForTrueID) Then 
		Exit Sub
	End if	
	const WAIT_TIMEOUT = 200
	Dim bRes		' результат вычисления выражения sExpr
	
	bRes = (True = Eval( sExpr))
	if X_ErrOccured() Then
		X_ErrReport()
		Exit Sub
	End if	
	if bRes Then
		ExecuteGlobal sProcName 
	Else
		window.setTimeout _
			"X_WaitForTrueInternal """ & _
			X_VBEncode(sProcName)  & _
			""", """ & _
			X_VBEncode(sExpr) & """," & nCurrentID , _
			WAIT_TIMEOUT, "VBScript"
	End if
End Sub


'===============================================================================
'@@X_VBEncode
'<GROUP !!FUNCTIONS_x-utils><TITLE X_VBEncode>
':Назначение:
'	Функция перекодирует строку в формат, воспринимаемый интерпретатором VBS.
':Параметры:
'	sIN - 
'       [in] входная строка.
':Сигнатура:
'	Function X_VBEncode ( sIN [As String] ) [As String]
Function X_VBEncode(sIN)
	X_VBEncode = Replace(Replace( Replace( Replace ( sIN, """", """"""), vbNewLine, """  & vbNewLine & """), vbCr, """  & vbCr & """), vbLf, """  & vbLf & """)
End Function


'===============================================================================
'@@X_ErrOccured
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ErrOccured>
':Назначение:
'	Функция проверяет состояние объекта Err. 
':Результат:
'	Если Err.Number не равен 0, то возвращает True и сохраняет данные об ошибке
'   в глобальных переменных.<P/>
'   Если Err.Number равен 0, то возвращает Empty.
':Сигнатура:
'	Function X_ErrOccured () [As Variant]
Function X_ErrOccured()
	If Err Then
		x_nErrNumber = Err.Number
		x_sErrSrc = Err.Source
		x_sErrDesc = Err.Description
		X_ErrOccured = true
	End if
End Function


'===============================================================================
'@@X_ErrReRaise
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ErrReRaise>
':Назначение:
'	Процедура возбуждает ошибку на основе данных об ошибке, сохраненных в 
'   глобальных переменных вызовом функции <LINK X_ErrOccured, X_ErrOccured />, с 
'   добавлением к ним описания ошибки и источника.
':Параметры:
'	sDesc - 
'       [in] описание ошибки (может быть Null или пустой строкой).
'	sSrc - 
'       [in] имя источника (может быть Null или пустой строкой).
':Примечание:	
'	<b><i>Внимание!</b></i> Использование данной функции без предварительного вызова 
'   функции <LINK X_ErrOccured, X_ErrOccured />, вернувшей True, приведет к
'   непредсказуемым результатам! Перед вызовом данной функции в обработчике ошибок
'   необходимо вызвать On Error Goto 0.<P/>
'   <b><i>Пример использования:</b></i><P/>
'	if X_ErrOccurеd() Then <P/>
'		On Error Goto 0 <P/>
'		X_ErrReRaise "Какая-то ошибка", "моя плохая функция" <P/>
'	End if
':Сигнатура:
'	Sub X_ErrReRaise (
'       sDesc [As String], 
'       sSrc [As String]
'    )
Sub X_ErrReRaise( sDesc, sSrc)
	Err.Raise _
		x_nErrNumber, _
		iif( Len( sSrc) > 0, sSrc & vbNewLine & x_sErrSrc, x_sErrSrc), _
		iif( Len( sDesc) > 0, sDesc & vbNewLine & x_sErrDesc, x_sErrDesc)
End Sub


'===============================================================================
'@@X_IsDebugMode
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsDebugMode>
':Назначение:
'	Функция возвращает признак отладочного режима.
':Сигнатура:
'   Function X_IsDebugMode [As Boolean]
Function X_IsDebugMode
	X_IsDebugMode = Not IsNull(X_GetMD().getAttribute(META_DATA_DEBUG_ATTR))
End Function


'===============================================================================
'@@X_SetDebugMode
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SetDebugMode>
':Назначение:
'	Процедура устанавливает признак отладочного режима.
':Параметры:
'	bDebug - 
'       [in] признак включенной отладки.
':Сигнатура:
'	Sub X_SetDebugMode( bDebug [As Boolean] )
Sub X_SetDebugMode( bDebug)
	Dim bDebugCur	' Текущий признак отладочного режима
	Dim oMD			' Метаданные
	Set oMD = X_GetMD()
	bDebugCur = CBool( X_GetAttributeDef(oMD, META_DATA_DEBUG_ATTR, "0") = "1")
	bDebug = CBool(bDebug)
	If bDebugCur <> bDebug Then
		If bDebug Then 
			oMD.setAttribute META_DATA_DEBUG_ATTR, "1"
		Else
			oMD.removeAttribute META_DATA_DEBUG_ATTR
		End If
		XService.SetUserData META_DATA_STORE, oMD
	End If
End Sub


'===============================================================================
'@@X_ErrReportEx
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ErrReportEx>
':Назначение:
'	Процедура выводит расширенное сообщение об ошибке. 
':Параметры:
'	sMsg - 
'       [in] описание ошибки.
'	sSrc - 
'       [in] источник ошибки.
':Сигнатура:
'	Sub X_ErrReportEx (
'       sMsg [As String], 
'       sSrc [As String]
'    )
Sub X_ErrReportEx( sMsg, sSrc )
	On Error GoTo 0
	if X_IsDebugMode Then sMsg = sMsg & vbNewLine & vbNewLine & sSrc
	Alert sMsg
End Sub


'===============================================================================
'@@X_ErrReport
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ErrReport>
':Назначение:
'	Процедура выводит сообщение об ошибке из объекта Err. 
':Сигнатура:
'	Sub X_ErrReport ()
Sub X_ErrReport()
	X_ErrReportEx Err.Description, Err.Source
End Sub


'===============================================================================
'@@X_CreateObjectStub
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CreateObjectStub>
':Назначение:
'	Функция возвращает "заглушку" для объекта с указанным типом и идентификатором.
':Параметры:
'	sType - 
'       [in] имя типа объекта.
'	sID - 
'       [in] идентификатор объекта.
':Сигнатура:
'	Function X_CreateObjectStub ( 
'       sType [As String],
'       sID [As String]
'   ) [As IXMLDOMElement]
Function X_CreateObjectStub( sType, sID)
	Dim oStub	' "Заглушка" объекта (XMLDOMElement)

	' идентификатор - это гуид в формате: 00000000-0000-0000-0000-000000000000
	If Len(sID) <> 36 Then Err.Raise -1, "X_CreateObjectStub", "Некорректный формат идентификатор объекта: " & sID & vbCr & "Ожидается: 00000000-0000-0000-0000-000000000000"
	
	Set oStub = XService.XMLGetDocument()					' Создаем пустой XML-документ
	oStub.appendChild oStub.createElement( sType)			' Создаем корневой элемент
	oStub.documentElement.setAttribute "oid", LCase(sID)	' Устанавливаем идентификатор объекта
	Set X_CreateObjectStub = oStub.documentElement			' Возвращаем заглушку
End Function


'===============================================================================
'@@X_CreateStubFromXmlObject
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CreateStubFromXmlObject>
':Назначение:
'	Функция возвращает "заглушку" для переданного объекта.
':Параметры:
'	oXmlObject - 
'       [in] объект, для которого необходимо создать "заглушку".
':Сигнатура:
'	Function X_CreateStubFromXmlObject ( oXmlObject [As IXMLDOMElement] ) [As IXMLDOMElement]
Function X_CreateStubFromXmlObject( oXmlObject )
	Dim oStub		' "Заглушка" объекта (XMLDOMElement)
	
	' Создаем пустой XML-документ
	Set oStub = XService.XMLGetDocument()			
	' Создаем корневой элемент
	oStub.appendChild oStub.createElement( oXmlObject.tagName )	
	' Устанавливаем идентификатор объекта
	oStub.documentElement.setAttribute "oid", oXmlObject.getAttribute("oid")
	' Возвращаем заглушку
	Set X_CreateStubFromXmlObject = oStub.documentElement	
End Function


'===============================================================================
'@@X_DeleteObject
'<GROUP !!FUNCTIONS_x-utils><TITLE X_DeleteObject>
':Назначение:
'	Функция удаляет объект из БД, используя команду <b>DeleteObject</b>.
':Параметры:
'	sObjectType - 
'       [in] наименование типа объекта.
'	sObjectID - 
'       [in] идентификатор объекта.
':Результат:
'	Возвращает количество удаленных объектов (0 в случае ошибки или больше 1, если
'   есть каскадное удаление.
':Сигнатура:
'	Function X_DeleteObject ( 
'       sObjectType [As String],
'       sObjectID [As String]
'   ) [As Int]
Function X_DeleteObject(sObjectType, sObjectID)
	Dim oResponse		' респонс команды
	
	With New XDeleteObjectRequest
		.m_sName = "DeleteObject"
		.m_sTypeName = sObjectType
		.m_sObjectID = sObjectID
		Set oResponse = internal_executeServerCommand( .Self )
	End With
	If Not oResponse Is Nothing Then
		X_DeleteObject = oResponse.m_nDeletedObjectQnt
	Else
		X_DeleteObject = 0
	End If
End Function


'===============================================================================
'@@X_GetObjectFromServer
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetObjectFromServer>
':Назначение:
'	Функция загружает объект с сервера, используя команду <b>GetObject</b>.
':Параметры:
'	sObjectType - 
'       [in] наименование типа загружаемого объекта.
'	sObjectID - 
'       [in] идентификатор загружаемого объекта.
'	vPreloads - 
'       [in] список прелоадов; может быть либо массивом строк либо перечислением 
'       через " ", "," или ";".
':Результат:
'	Возвращает инициализированный экземпляр IXMLDOMElement, содержащий данные
'   загруженного объекта. В случае ошибки - Nothing.
':Примечание:	
'   Если на сервере произошло исключение, отличное от 
'   <LINK Croc.XmlFramework.Data.XObjectNotFoundException, XObjectNotFoundException />, 
'   <LINK Croc.XmlFramework.Public.XSecurityException, XSecurityException />,
'   <LINK Croc.XmlFramework.Public.XBusinessLogicException, XBusinessLogicException />,
'   то показывается сообщение об ошибке и генерируется VBS-ошибка. Описание ошибки 
'   можно получить с помощью функции X_GetLastError.<P/>
'	Функция реализует кеширование болванок новых объектов.
':Сигнатура:
'	Function X_GetObjectFromServer ( 
'       sObjectType [As String],
'       ByVal sObjectID [As String],
'       ByVal vPreloads [As Variant]
'   ) [As IXMLDOMElement]
Function X_GetObjectFromServer( sObjectType, ByVal sObjectID, ByVal vPreloads )
	Dim oTypeMD			' As IXMLDOMElement, Метаданные типы
	Dim oXmlElement		' As IXMLDOMElement, элемент
	
	Set X_GetObjectFromServer = Nothing
	If IsEmpty(vPreloads) Then
		vPreloads = Null
	Elseif IsNull(vPreloads) Then
		vPreloads = Null
	Elseif Not IsArray(vPreloads) Then 
		vPreloads = Replace(vPreloads, ",", " ")
		vPreloads = Replace(vPreloads, ";", " ")
		vPreloads = Replace(vPreloads, "  ", " ")
		vPreloads = Split(vPreloads, " ")
	End If
	If IsNull(sObjectID) Then
		sObjectID = GUID_EMPTY
	ElseIf IsEmpty(sObjectID) Or sObjectID="" Then
		sObjectID = GUID_EMPTY
	End If 
	If sObjectID = GUID_EMPTY Then
		' Кеширование болванок новых объектов (если sObjectID не задан)
		Set oTypeMD = X_GetTypeMD(sObjectType)
		If Nothing Is oTypeMD.SelectSingleNode("ds:prop[@vt='date' or @vt='dateTime' or @vt='time']/ds:def[(@default-type='both' or @default-type='xml') and (.='#CURRENT')]") Then
			Set oXmlElement = oTypeMD.selectSingleNode("template/" & sObjectType)
			If Nothing Is oXmlElement Then
				Set oXmlElement = internal_GetObjectFromServer(sObjectType, sObjectID, vPreloads)
				If Not oXmlElement Is Nothing Then
					oTypeMD.AppendChild(oTypeMD.ownerDocument.CreateElement("template")).AppendChild oXmlElement
					X_SaveMetadata oTypeMD.parentNode
				End If
			End If
			Set oXmlElement = oXmlElement.cloneNode(true)
			oXmlElement.SetAttribute "oid", CreateGuid
			XService.XmlGetDocument.AppendChild oXmlElement
			XService.XmlSetSelectionNamespaces oXmlElement.ownerDocument
			Set X_GetObjectFromServer = oXmlElement
		Else
			Set X_GetObjectFromServer = internal_GetObjectFromServer(sObjectType, sObjectID, vPreloads)
		End If	
	Else
		Set X_GetObjectFromServer = internal_GetObjectFromServer(sObjectType, sObjectID, vPreloads)
	End If
End Function


'==============================================================================
' ВНИАНИЕ: Функция для внутренних целей!
' Возвращает объект с сервера, полученный командов GetObject.
' Если на сервере произошло исключение отличное от XObjectNotFoundException, XSecurityException, XBusinessLogicException,
' то показывается сообщение об ошибки и генерируется vbs ошибка, иначе функция просто возвращает Nothing.
Private Function internal_GetObjectFromServer( sObjectType, sObjectID, vPreloads )
	Dim oResponse		' респонс команды
	
	With New XGetObjectRequest
		.m_sName = "GetObject"
		.m_sTypeName = sObjectType
		.m_sObjectID = sObjectID
		.m_aPreloadProperties = vPreloads
		Set oResponse = internal_executeServerCommand( .Self )
	End With
	If Not oResponse Is Nothing Then
		Set internal_GetObjectFromServer = oResponse.m_oXmlObject
	Else
		Set internal_GetObjectFromServer = Nothing
	End If
End Function


'==============================================================================
' Вызывает функцию-обертку серверной команды с заданным реквестом.
' Реализует проверку на следующие типы исключений: XObjectNotFoundException, XSecurityException, XBusinessLogicException.
' Для остальных исключений показывается сообщение об ошибки и генерируется vbs ошибка.
'	[in] oRequest - реквест команды, полностью инициализированный
'	[retval] объект респонса (vbs-класса врапера) или Nothing
Private Function internal_ExecuteServerCommand(oRequest)
	Dim oResponse	' респонс команды
	Dim aErr		' поля объекта Err
	Dim sErrDescr	' описание ошибки
	
	Set internal_ExecuteServerCommand = Nothing
	On Error Resume Next
	Set oResponse = X_ExecuteCommand(oRequest)
	If X_WasErrorOccured Then
		' на сервере произошла ошибка
		On Error Goto 0
		' если ошибка не ожидаемого типа, то покажем диалоговое окно и перерейзим ошибку vbs
		With X_GetLastError
			' TODO: если понадобиться переделать на проверку попадания в заданный список типов исключений
			If Not (.IsObjectNotFoundException Or .IsSecurityException Or .IsBusinessLogicException) Then
				.ShowDebugDialog
				.RaiseError
			End If
		End With
		' иначе просто выйдем с результатом функции Nothing, активной ошибки vbs нет
		Exit Function
	ElseIf Err Then
		' ошибка произошла на клиенте - это ошибка в XFW
		sErrDescr = Err.Description
		' велика вероятность, что ошибка произошла из-за vbs-proxy для серверных команд, поэтому обработаем несколько частных случаев
		If Err.Number = 13 Then			' - Type mismatch - вызвали неизвестную функцию
			sErrDescr = sErrDescr & vbCr & "Неизвестная функция: " & sFunctionName & vbCr & "Возможно не были сгенерированы proxy серверных операций"
		ElseIf Err.Number = 450 Then	' - Wrong number of arguments or invalid property assignment - неправильное кол-во параметров
			sErrDescr = sErrDescr & vbCr & "Ошибка вызова функции: " & sFunctionName & vbCr & "Возможно не были сгенерированы proxy серверных операций"
		End If
		aErr = Array(Err.Number, Err.Source, sErrDescr)
		On Error Goto 0
		Err.Raise aErr(0), aErr(1), aErr(2)				
	End If
	Set internal_ExecuteServerCommand = oResponse
End Function


'===============================================================================
'@@X_LoadObjectPropertyFromServer
'<GROUP !!FUNCTIONS_x-utils><TITLE X_LoadObjectPropertyFromServer>
':Назначение:
'	Функция вызывает серверную команду <b>GetProperty</b>.
':Параметры:
'	sObjectType - 
'       [in] наименование типа загружаемого объекта.
'	sObjectID - 
'       [in] идентификатор загружаемого объекта.
'	sPropertyName - 
'       [in] наименование прогружаемого свойства объекта. 
':Результат:
'	Возвращает инициализированный экземпляр IXMLDOMElement, содержащий данные
'   узла прогруженного свойства.
':Сигнатура:
'	Function X_LoadObjectPropertyFromServer ( 
'       sObjectType [As String],
'       sObjectID [As String],
'       sPropertyName [As String]
'   ) [As IXMLDOMElement]
Function X_LoadObjectPropertyFromServer(sObjectType, sObjectID, sPropertyName)
	Dim oResponse		' респонс команды
	
	With New XGetPropertyRequest
		.m_sName = "GetProperty"
		.m_sTypeName = sObjectType
		.m_sObjectID = sObjectID
		.m_sPropName = sPropertyName
		Set oResponse = internal_ExecuteServerCommand( .Self )
	End With
	If Not oResponse Is Nothing Then
		Set X_LoadObjectPropertyFromServer = oResponse.m_oXmlProperty
	Else
		Set X_LoadObjectPropertyFromServer = Nothing
	End If
End Function


'===============================================================================
'@@X_GetMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetMD>
':Назначение:
'	Функция возвращает метаданные (IXMLDOMElement с корневым элементом 
'   <b>metadata</b>), загруженные в текущий момент на клиент и находящиеся в кэше.
':Примечание:	
'   Если в клиентском кэше нет метаданных, то функция инициализирует их.<P/> 
'   Признаком наличия инициализированных в контексте сессии метаданных
'   является наличие клиентского cookie "metadata=1".<P/>
'	В случае возникновения проблем, функция генерирует ошибку.
':Сигнатура:
'	Function X_GetMD () [As IXMLDOMElement]
Function X_GetMD()
	Dim oServerMD	' метаданные с сервера
	Dim bCached		' признак наличия кэшированных метаданных
	Dim sCookie		' строка cookie, используемая для определения факта 
					' инициализации метаданных в сессии
	Dim aErr		' массив с полями объекта Err
	
	sCookie = XService.URLEncode( UCase(XService.BaseURL())) & "METADATA=1"
	
	If IsEmpty(X_bMD) Then
		' Получаем кэшированные метаданные
		bCached = XService.GetUserData( META_DATA_STORE,x_oMD )
		
		' Если живых метаданных на клиенте нет...
		If Not bCached Then
			' Грузим корневой элемент метаданных с сервера
			Set x_oMD = internal_GetMetadataRoot
			If x_oMD Is Nothing Then Exit Function
			' Сохраняем корневой элемент в клиентском кэше
			XService.SetUserData META_DATA_STORE, x_oMD
		
		' Если метаданные в данной сессии не инициализированы
		ElseIf 0 = InStr( document.cookie, sCookie ) Then
			' Грузим корневой элемент метаданных с сервера
			Set oServerMD = internal_GetMetadataRoot
			If oServerMD Is Nothing Then Exit Function

			' Проверяем не изменились ли метаданные
			If 0 <> StrComp( "" & x_oMD.getAttribute("md5"), oServerMD.getAttribute("md5")) Then
				' Перезаписываем кэш
				XService.SetUserData META_DATA_STORE, oServerMD
				' Возвращаем серверную копию
				Set X_oMD = oServerMD
				' Очищаем кеш данных
				X_ClearDataCache
			' Проверим не изменились ли XSLT шаблоны
			ElseIf 0 <> StrComp( "" & x_oMD.getAttribute("xsl-md5"), oServerMD.getAttribute("xsl-md5")) Then
				x_oMD.SetAttribute "xsl-md5", oServerMD.getAttribute("xsl-md5")
				' Перезаписываем кэш метаданных
				XService.SetUserData META_DATA_STORE, oServerMD
			' Проверим не изменился ли файл конфигурации
			ElseIf 0 <> StrComp( "" & x_oMD.getAttribute("config-hash"), oServerMD.getAttribute("config-hash")) Then
				x_oMD.SetAttribute "config-hash", oServerMD.getAttribute("config-hash")
				' Перезаписываем кэш
				XService.SetUserData META_DATA_STORE, oServerMD
				' Очищаем кеш данных
				X_ClearDataCache
			End If
		Else
			' Устанавливаем пространства имен для XPath-запросов
			XService.XMLSetSelectionNamespaces X_oMD.ownerDocument
		End If
		
		' инициализируем Cookie
		document.cookie = sCookie
		X_bMD = True
	End If
	
	' Возвращаем метаданные
	Set X_GetMD = X_oMD
End Function


'==============================================================================
' Внутренняя функция получения корня метаданных
' В случае серверной ошибки показывает окно, в случае клиентской ошибки генерирует VBS runtime ошибку.
' [retval] IXMLDOMElement - узел ds:metadata, или Nothing в случае ошибки
Private Function internal_GetMetadataRoot
	Dim oServerMD	' метаданные с сервера
	Set internal_GetMetadataRoot = Nothing
	On Error Resume Next
	Set oServerMD = XService.XMLGetDocument("x-metadata.aspx?ROOT=1")
	If Err Then
		X_SetLastServerError XService.LastServerError, Err.number, Err.Source, Err.Description
		X_HandleError
		Exit Function
	Else
		On Error Goto 0
		X_ClearLastServerError
	End If
	Set internal_GetMetadataRoot = oServerMD.documentElement
End Function


'==============================================================================
' Получает элемент метаданных с сервера, используя страницу x-metadata.aspx
'	[in] sParamName - наименование параметра страницы x-metadata.aspx
'	[in] sMetaname - значение параметра
Function internal_GetMetadataSubrootElementFromServer(sParamName, sMetaname)
	Dim oMD			' Метаданные из кэша
	Dim oNodeMD		' (XMLDOMDocument, потом XMLDOMNode)
	
	Set internal_GetMetadataSubrootElementFromServer = Nothing
	On Error Resume Next
	Set oNodeMD = XService.XMLGetDocument("x-metadata.aspx?" & sParamName & "=" & sMetaname)
	If Err Then
		X_SetLastServerError XService.LastServerError, Err.number, Err.Source, Err.Description
		On Error Goto 0
		X_GetLastError.RaiseError
	Else
		On Error Goto 0
		X_ClearLastServerError
	End If
	If Not IsNothing(oNodeMD) Then
		Set oMD = X_GetMD()
		Set oNodeMD = oNodeMD.documentElement
		' добавляем метаданные узда (XMLElement) в общий XML кэша метаданных
		oMD.appendChild oNodeMD
		' Сохраняем метаданные в локальный кэш
		X_SaveMetadata oMD
	End If
	Set internal_GetMetadataSubrootElementFromServer = oNodeMD
End Function

'===============================================================================
'@@X_GetSubrootElementMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetSubrootElementMD>
':Назначение:
'	Функция возвращает узел метаданных.
':Параметры:
'	sNode - 
'       [in] тип узла метаданных, например "i:menu"
'	sNodeName - 
'       [in]  значение атрибута "n" узла метаданных
':Результат:
'	Узел <b>sNode</b> метаданных.
':Примечание:	
'   Метаданные берутся из кэша.<P/> 
'   Если для метаданные еще не загружены, то они подгружаются 
'   с сервера.<P/>
'	<b><i>Внимание!</b></i> Ошибки не обрабатываются, но заносятся в глобальную 
'   переменную, доступную через X_GetLastError.
':Сигнатура:
'	Function X_GetSubrootElementMD ( 
'       sNode [As String],
'       sNodeName [As String]
'   ) [As IXMLDOMElement]
Function X_GetSubrootElementMD( sNode, sNodeName)
	Dim oMD					' Метаданные из кэша
	Dim oSubrootElementMD	' Метаданные для указанного узла
	Set X_GetSubrootElementMD = Nothing
	' получаем текущий кэш метаданных
	Set oMD = X_GetMD()	
	' пытаемся получить нужный тип из кэша
	Set oSubrootElementMD = oMD.selectSingleNode( sNode & "[@n='" & sNodeName & "']" )
	If oSubrootElementMD Is Nothing Then
		' В кэше нет, получаем с сервера:
		Set oSubrootElementMD = internal_GetMetadataSubrootElementFromServer("NODE=" & XService.UrlEncode(sNode) & "&NAME", XService.UrlEncode(sNodeName))
	End If
	' Вернём значение
	Set X_GetSubrootElementMD = oSubrootElementMD	
End Function


'===============================================================================
'@@X_GetTypeMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetTypeMD>
':Назначение:
'	Функция возвращает метаданные указанного типа.
':Параметры:
'	sType - 
'       [in] имя типа информационных объектов.
':Результат:
'	Узел <b>ds:type</b> метаданных типа.
':Примечание:	
'   Метаданные берутся из кэша.<P/> 
'   Если для указанного типа метаданные еще не загружены, то они подгружаются 
'   с сервера.<P/>
'	<b><i>Внимание!</b></i> Ошибки не обрабатываются, но заносятся в глобальную 
'   переменную, доступную через X_GetLastError.
':Сигнатура:
'	Function X_GetTypeMD ( 
'       sType [As String]
'   ) [As IXMLDOMElement]
Function X_GetTypeMD( sType)
	Dim oMD			' Метаданные из кэша
	Dim oTypeMD		' Метаданные для указанного типа (XMLDOMDocument, потом XMLDOMNode)

	Set X_GetTypeMD = Nothing
	' получаем текущий кэш метаданных
	Set oMD = X_GetMD()
	' пытаемся получить нужный тип из кэша
	Set oTypeMD = oMD.selectSingleNode( "ds:type[@n='" & sType & "']" )
	If oTypeMD Is Nothing Then
		' В кэше нет, получаем с сервера:
		Set oTypeMD = internal_GetMetadataSubrootElementFromServer("OT", sType)
	End If
	' Вернём значение
	Set X_GetTypeMD = oTypeMD
End Function


'===============================================================================
'@@X_GetEnumMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetEnumMD>
':Назначение:
'	Функция возвращает метаданные перечисления или флагов.
':Параметры:
'	sEnumName - 
'       [in] имя перечисления или флагов.
':Результат:
'	Узел <b>ds:enum</b> или <b>ds:flags</b>.
':Сигнатура:
'	Function X_GetEnumMD ( 
'       sEnumName [As String]
'   ) [As IXMLDOMElement]
Function X_GetEnumMD(sEnumName)
	Dim oMD			' Метаданные из кэша
	Dim oEnumMD 	' Метаданные для указанного перечисления

	Set X_GetEnumMD = Nothing
	' получаем текущий кэш метаданных
	Set oMD = X_GetMD()
	' пытаемся получить нужный тип из кэша
	Set oEnumMD = oMD.selectSingleNode( "ds:enum[@n='" & sEnumName & "'] | ds:flags[@n='" & sEnumName & "']" ) 
	If oEnumMD Is Nothing Then
		' В кэше нет, получаем с сервера:
		Set oEnumMD = internal_GetMetadataSubrootElementFromServer("ENUM", sEnumName)
	End If
	' Вернём значение
	Set X_GetEnumMD = oEnumMD
End Function


'===============================================================================
'@@X_GetTreeMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetTreeMD>
':Назначение:
'	Функция возвращает XML-узел метаданных дерева/селектора из дерева.
':Параметры:
'	sMetaname - 
'       [in] метанаименование страницы.
':Результат:
'	Узел <b>i:objects-tree</b> или <b>i:objects-tree-selector</b>.
':Сигнатура:
'	Function X_GetTreeMD ( 
'       sMetaname [As String]
'   ) [As IXMLDOMElement]
Function X_GetTreeMD(sMetaname)
	Dim oMD			' Метаданные из кэша
	Dim oTreeMD 	' Метаданные дерева
	
	Set X_GetTreeMD = Nothing
	' получаем текущий кэш метаданных
	Set oMD = X_GetMD()
	' пытаемся получить из кэша
	Set oTreeMD = oMD.selectSingleNode( "i:objects-tree[@n='" & sMetaname & "'] | i:objects-tree-selector[@n='" & sMetaname & "']" ) 
	If oTreeMD Is Nothing Then
		' В кэше нет, получаем с сервера:
		Set oTreeMD = internal_GetMetadataSubrootElementFromServer("TREE", sMetaname)
	End If
	Set X_GetTreeMD = oTreeMD
End Function


'===============================================================================
'@@X_GetListMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetListMD>
':Назначение:
'	Функция возвращает XML-узел метаданных списка.
':Параметры:
'	sObjectType - 
'       [in] наименование типа.
'	sMetaname - 
'       [in] метанаименование страницы.
':Результат:
'	Узел <b>i:objects-list</b>.
':Сигнатура:
'	Function X_GetListMD ( 
'       sObjectType [As String],
'       sMetaname [As String]
'   ) [As IXMLDOMElement]
Function X_GetListMD(sObjectType, sMetaname)
	Dim sFilter
	If hasValue(sMetaname) Then sFilter = "[@n='" & sMetaname & "']"
	Set X_GetListMD = X_GetTypeMD(sObjectType).selectSingleNode("i:objects-list" & sFilter)
End Function


'===============================================================================
'@@X_SaveMetadata
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SaveMetadata>
':Назначение:
'	Процедура сохраняет метаданные в кэше.
':Параметры:
'	oMD - 
'       [in] метаданные.
':Сигнатура:
'	Sub X_SaveMetadata ( oMD [As IXMLDOMElement] )
Sub X_SaveMetadata(oMD)
	' Устанавливаем пространства имен для XPath-запросов
	XService.XMLSetSelectionNamespaces oMD.ownerDocument
	' Сохраняем метаданные в локальный кэш
	XService.SetUserData META_DATA_STORE, oMD
End Sub


'===============================================================================
'@@X_GetPropertyMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetPropertyMD>
':Назначение:
'	Функция возвращает метаданные свойства для переданного XML-свойства.
':Параметры:
'	oXmlProperty - 
'       [in] XML-свойство.
':Сигнатура:
'	Function X_GetPropertyMD ( 
'       oXmlProperty [As IXMLDOMElement]
'   ) [As IXMLDOMElement]
Function X_GetPropertyMD(oXmlProperty)
	If 0 <> StrComp(TypeName(oXmlProperty), "IXMLDOMElement", vbTextCompare) Then
		Err.Raise -1, "X_GetPropertyMD", "Недопустимый тип параметра oXmlProperty: " & TypeName(oXmlProperty) & " - должен быть IXMLDOMElement"
	End If
	Set X_GetPropertyMD = X_GetTypeMD( oXmlProperty.parentNode.nodeName ).selectSingleNode( "ds:prop[@n='" & oXmlProperty.nodeName & "']")
End Function


'===============================================================================
'@@X_DialogDim
'<GROUP !!FUNCTIONS_x-utils><TITLE X_DialogDim>
':Назначение:
'	Процедура возвращает размеры диалогового окна.
':Параметры:
'	vHeight - 
'       [in] высота диалогового окна, или Null, или Empty.
'	vWidth - 
'       [in] ширина диалогового окна, или Null, или Empty.
'	nDefaultHeight - 
'       [in] высота диалогового окна по умолчанию.
'	nDefaultWidth - 
'       [in] ширина диалогового окна по умолчанию.
'	nHeight - 
'       [out] искомая высота диалогового окна в точках.
'	nWidth - 
'       [out] искомая ширина диалогового окна в точках.
':Сигнатура:
'   Sub X_DialogDim ( 
'       ByVal vHeight [As Variant], 
'       ByVal vWidth [As Variant], 
'       ByVal nDefaultHeight [As Int], 
'       ByVal nDefaultWidth [As Int], 
'       ByRef nHeight [As Int], 
'       ByRef nWidth [As Int]
'   )
Sub X_DialogDim(ByVal vHeight, ByVal vWidth, ByVal nDefaultHeight, ByVal nDefaultWidth , ByRef nHeight, ByRef nWidth )
	const HUNDRED_PERCENT = 100 ' 100 %

	if IsNull(vHeight) Then 
		vHeight = nDefaultHeight
	ElseIf IsEmpty(vHeight)	Then
		vHeight = nDefaultHeight
	End if	
	
	if IsNull(vWidth) Then 
		vWidth = nDefaultWidth
	ElseIf IsEmpty(vWidth)	Then
		vWidth = nDefaultWidth
	End if
	
	vHeight = CLng(vHeight) 
	vWidth = CLng(vWidth) 
	if vHeight <= HUNDRED_PERCENT Then
		nHeight = CLng( vHeight * window.screen.availHeight / HUNDRED_PERCENT  ) 
	Else
		nHeight = vHeight
	End if
	if vWidth <= HUNDRED_PERCENT Then
		nWidth = CLng( vWidth * window.screen.availWidth / HUNDRED_PERCENT  ) 
	Else
		nWidth = vWidth
	End if
End Sub


'===============================================================================
'@@ObjectEditorDialogClass
'<GROUP !!CLASSES_x-utils><TITLE ObjectEditorDialogClass>
':Назначение:	
'	Класс, инкапсулирующий логику открытия и передачи параметров в редактор,
'	открываемый в диалоговом окне.
':Примечание:
'	В открываемое окно редактора передается экземпляр данного класса. 
'	Это позволяет получить в редакторе ссылки на объекты с вызывающей страницы: 
'	кэш прав, метаданные, ConfigClass.<P/>
'	Для открытия редактора следует использовать функцию 
'	ObjectEditorDialogClass_Show, передав в нее экземпляр данного класса. 
':См. также:
'	ObjectEditorDialogClass_Show
'
'@@!!MEMBERTYPE_Methods_ObjectEditorDialogClass
'<GROUP ObjectEditorDialogClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_ObjectEditorDialogClass
'<GROUP ObjectEditorDialogClass><TITLE Свойства>
Class ObjectEditorDialogClass
	Private m_oXmlObject		' XmlElement, редактируемый объект
	Private m_oPool				' As XObjectPool - пул объектов (для случая задания его снаружи корневого редактора)
	Public ObjectType			' As String - Тип объекта
	Public ObjectID				' As String - Идентификатор объекта 
	Public MetaName				' As String - Метаимя редактора/мастера
	Public IsNewObject			' As Boolean - Признак необходимости создания нового объекта вместо загрузки з БД
	Public IsAggregation		' As Boolean - Признак открытия в той-же транзакции что и родитель
	Public QueryString			' QueryStringClass
	Public ParentObjectEditor	' ObjectEditorClass, родительский редактор
	Public ParentObjectID		' As String - ObjectID родительского объекта
	Public ParentObjectType		' As String - Наименование типа родительского объекта
	Public ParentPropertyName	' As String - наименовнаие свойства родительского объекта, в котором создается/редактирует объект
	Public EnlistInCurrentTransaction	' As Boolean - признак того, что редактор работает в текущей транзакции пула и не начинает/отменяет новой транзакции
	'@@ObjectEditorDialogClass.SkipInitErrorAlerts
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorDialogClass><TITLE SkipInitErrorAlerts>
	':Назначение:	Указывает редактору и всем его компонентам о том, 
	'				что в случае невозможности установить значения UI контролов для 
	'               текущего объекта, не следует выдавать никаких предупреждений 
	'               пользователю.
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	Public SkipInitErrorAlerts [As Boolean]
	Public SkipInitErrorAlerts
	
	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		IsNewObject	= False
		IsAggregation = True
		EnlistInCurrentTransaction = False
		Set QueryString = X_GetEmptyQueryString
		Set ParentObjectEditor = Nothing
		Set m_oXmlObject = Nothing
		Set m_oPool = Nothing
	End Sub

	'------------------------------------------------------------------------------
	'@@ObjectEditorDialogClass.XmlObject
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorDialogClass><TITLE XmlObject>
	':Назначение:	 
	'   Редактируемый объект.
	':Сигнатура:	
	'   Public Property Set XmlObject (value [As IXMLDOMElement])
	'   Public Property Get XmlObject [As IXMLDOMElement]
	Public Property Set XmlObject(value)
		If Not value Is Nothing Then
			ObjectType = value.tagName
			ObjectID = value.getAttribute("oid")
		End If
		Set m_oXmlObject = value
	End Property
	
	Public Property Get XmlObject
		Set XmlObject = m_oXmlObject
	End Property
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorDialogClass.Pool
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorDialogClass><TITLE Pool>
	':Назначение:	 
	'   Пул объектов (для случая задания его снаружи корневого редактора).
	':Сигнатура:	
	'   Public Property Set Pool (value [As XObjectPool])
	'   Public Property Get Pool [As XObjectPool]
	Public Property Set Pool(value)
		Set m_oPool = value
	End Property
	
	Public Property Get Pool
		Set Pool = m_oPool
	End Property
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorDialogClass.GetRightsCache
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorDialogClass><TITLE GetRightsCache>
	':Назначение:	
	'	Функция возвращает кэш прав с текущей страницы (на которой был создан 
	'   экземпляр ObjectEditorDialogClass). При открытии корневого редактора
	'   возвращается пустой кэш прав.
	':Сигнатура:
	'	Public Function GetRightsCache [As ObjectRightsCacheClass] 
	Public Function GetRightsCache
		If ParentObjectEditor Is Nothing Then
			Set GetRightsCache = New ObjectRightsCacheClass
		Else
			Set GetRightsCache = X_RightsCache()
		End If
	End Function
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorDialogClass.GetMetadataRoot
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorDialogClass><TITLE GetMetadataRoot>
	':Назначение:	
	'	Функция возвращает корневой узел метаданных со страницы, где был создан 
	'   текущий экземпляр ObjectEditorDialogClass (т.е. инициировано открытие 
	'   редактора).
	':Сигнатура:
	'	Public Function GetMetadataRoot [As IXMLDOMElement] 
	Public Function GetMetadataRoot
		Set GetMetadataRoot = X_GetMD()
	End Function
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorDialogClass.GetConfig
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorDialogClass><TITLE GetConfig>
	':Назначение:	
	'	Функция возвращает экземпляр ConfigClass
	'   со страницы, где был создан текущий экземпляр ObjectEditorDialogClass 
	'   (т.е. инициировано открытие редактора).
	':Сигнатура:
	'	Public Function GetConfig [As ConfigClass] 
	Public Function GetConfig
		If hasValue(x_oConfig) Then
			Set GetConfig = x_oConfig
		Else
			Set GetConfig = Nothing
		End If
	End Function
End Class


'===============================================================================
'@@ObjectEditorDialogClass_Show
'<GROUP !!FUNCTIONS_x-utils><TITLE ObjectEditorDialogClass_Show>
':Назначение:
'	Функция открывает диалоговое модальное окно с редактором.
':Параметры:
'	oObjectEditorDialog - 
'       [in] экземпляр ObjectEditorDialogClass.
':Результат:
' 	Возвращает идентификатор созданного / отредактированного объекта, если 
'	редактор закрыт по "ОК", иначе - Empty.
':Примечание:
'	Функция вынесена из класса ObjectEditorDialogClass для того, чтобы не 
'	увеличивать стек объектных вызовов (из-за ошибки в VBScript-runtime, 
'	приводящей к "stack overflow at line 0").
':Сигнатура:
'   Function ObjectEditorDialogClass_Show ( 
'       oObjectEditorDialog [As ObjectEditorDialogClass]
'   ) [As Variant]
Function ObjectEditorDialogClass_Show(oObjectEditorDialog)
	Dim sUrl			' URL вызова редактора
	Dim vResult			' результат выполнения операции
	Dim bLoad			' признак необходимости загрузить данные редактируемого объекта
	
	ObjectEditorDialogClass_Show = Empty

	With oObjectEditorDialog
		' Если редактор открывается для редактирования объекта, отсутствующего на клиенте, то передадим в урле его идентификатор, 
		' это будет означать, что серверный код должен загрузить объект и "сериализовать" его в скрытом поле, откуда его достанет ObjectEditor.
		bLoad = True
		If .IsNewObject Then
			' при создании объекта не надо грузить (мы кэшируем болванки новых объектов на клиенте)
			bLoad = False
		ElseIf Not .XmlObject Is Nothing Then 
			' задан редактируемый объект - не надо грузить
			bLoad = False
		ElseIf Not .Pool Is Nothing Then
			' задан пул, проверим есть ли там редактируемый объект
			If Not .Pool.FindXmlObject(.ObjectType, .ObjectID) Is Nothing Then
				bLoad = False
			End If
		End If
		
		' Формируем URL редактора
		sUrl = XService.BaseUrl() & "x-editor.aspx?OT=" & .ObjectType & "&MetaName=" & .MetaName & "&CreateNewObject=" & Iif(true=.IsNewObject,1,0)
		If bLoad Then 
			sUrl = sUrl & "&ID=" & .ObjectID & "&tm=" & CDbl(Now())
		End If
		' Откроем диалоговое окно редактора
		vResult = X_ShowModalDialog(sURL, oObjectEditorDialog)
		' Проанализируем отклик
		If IsEmpty(vResult) Then Exit Function
		If IsNull(vResult) Then Exit Function
	End With
	ObjectEditorDialogClass_Show = vResult
End Function


'===============================================================================
'@@X_OpenObjectEditor
'<GROUP !!FUNCTIONS_x-utils><TITLE X_OpenObjectEditor>
':Назначение:
'	Функция открывает окно редактора (x-editor.aspx).
':Параметры:
'	sObjectType - 
'       [in] тип объекта.
'	sObjectID - 
'       [in] идентификатор объекта (если Null, то объект создается).
'	sEditorMetaname - 
'       [in] имя редактора в метаданных.
'	sUrlParams - 
'       [in] строка дополнительных параметров (передается в URL).
':Результат:
' 	Возвращает Empty, если ничего не отредактировано, иначе - идентификатор объекта.
':Сигнатура:
'   Function X_OpenObjectEditor (
'       sObjectType [As String], 
'       sObjectID [As String], 
'       sEditorMetaname [As String], 
'       sUrlParams [As String]
'   ) [As Variant]
Function X_OpenObjectEditor(sObjectType, sObjectID, sEditorMetaname, sUrlParams)
	Dim oObjectEditorDialog
	Set oObjectEditorDialog = new ObjectEditorDialogClass
	oObjectEditorDialog.IsNewObject = Not HasValue(sObjectID)
	oObjectEditorDialog.QueryString.QueryString = sUrlParams
	oObjectEditorDialog.IsAggregation = False
	oObjectEditorDialog.MetaName = sEditorMetaname
	oObjectEditorDialog.ObjectType = sObjectType
	oObjectEditorDialog.ObjectID = sObjectID
	X_OpenObjectEditor = ObjectEditorDialogClass_Show(oObjectEditorDialog)
End Function

'==============================================================================
' ВНИМАНИЕ!
' В связи с выходом
'	974455  MS09-054: Cumulative security update for Internet Explorer
' http://support.microsoft.com/kb/976749/
' при работе с модальными диалогами как во фреймворке так и
' в кастомном коде необходимо:
' 1) При открытии диалогового окна вместо вызова window.ShowModalDialog 
'		ВЕЗДЕ использовать X_ShowModalDialogEx
' 2) В коде диалогового окна для получения значений аргументов вместо
'		прямого доступа к свойству window.DialogArguments 
'		ВЕЗДЕ использовать X_GetDialogArguments
' 3) В коде диалогового окна для установки возвращаемого значения вместо
'		модификации свойства window.ReturnValue 
'		ВЕЗДЕ использовать X_SetDialogWindowReturnValue
'==============================================================================

'===============================================================================
' Класс инкапсулирует аргумент и возвращаемое значение модального диалога
' Данный класс введен для борьбы с последствиями 
' 974455  MS09-054: Cumulative security update for Internet Explorer
' http://support.microsoft.com/kb/976749/
'
' Класс не предназначен для непосредственного использования прикладным кодом, 
' должны использоваться функции X_ShowModalDialog, X_ShowModalDialogEx, 
' X_GetDialogArguments, X_SetDialogWindowReturnValue
Class internal_DialogArgsAndReturnValueClass
	' Аргументы, передаваемые в диалоговое окно 
	public internal_Arguments
	' Значение, передаваемое из диалогового окна в вызывающий код
	public internal_ReturnValue
End Class

'===============================================================================
'@@X_ShowModalDialogEx
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ShowModalDialogEx>
':Назначение:	
'	Открывает диалоговое окно браузера, возращает результат.
'	Предназначен для борьбы с последствиями KB974455  MS09-054: Cumulative security update for Internet Explorer
'	http://support.microsoft.com/kb/976749/
':Параметры:
'	sUrl - 
'       [in] адрес открываемой в модальном диалоговом окне странички.
'	vArguments - 
'       [in] параметры, передаваемые в вызываемый диалог.
'	sFeatures - 
'       [in] дополнительные параметры диалогового окна, например "help:no;center:yes;status:no".
':Результат:
' 	Результат, возвращаемый диалогом (установленный вызовом X_SetDialogWindowReturnValue).
':Сигнатура:
'	Function X_ShowModalDialogEx(
'       sUrl [As String],
'       vArguments [As Variant],
'       sFeatures [As String]
'   ) [As Variant]
Function X_ShowModalDialogEx(sUrl,  vArguments, sFeatures )
	Dim objArguments ' аргументы окна
	Set objArguments = new internal_DialogArgsAndReturnValueClass
	If IsObject( vArguments ) Then
		Set objArguments.internal_Arguments = vArguments
	Else
		objArguments.internal_Arguments = vArguments
	End If
	objArguments.internal_ReturnValue = Empty
	' Позовём диалоговое окно
	window.ShowModalDialog sUrl, objArguments, sFeatures
	' Результат возьмём из поля
	If IsObject( objArguments.internal_ReturnValue ) Then
		Set X_ShowModalDialogEx = objArguments.internal_ReturnValue
	Else
		X_ShowModalDialogEx = objArguments.internal_ReturnValue
	End If
End Function

'===============================================================================
'@@X_GetDialogArguments
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetDialogArguments>
':Назначение:	
'	Получение аргументов в диалоговом окне.
'	Предназначен для борьбы с последствиями KB974455  MS09-054: Cumulative security update for Internet Explorer
'	http://support.microsoft.com/kb/976749/
':Параметры:
'	vDialogArguments - 
'       [out] значение аргументов диалогового окна, можно передать NULL и использовать возвращаемое функцией значение.
':Результат:
' 	Значение аргументов диалогового окна, то же самое, что получим в vDialogArguments после возврата из функции.
':Сигнатура:
'	Function X_GetDialogArguments(
'       ByRef vDialogArguments [As Variant]
'   ) [As Variant]
Function X_GetDialogArguments(ByRef vDialogArguments)
	Dim arrResult ' Результат выполнения
	' Берём в массив чтобы не мучится с Set и Let
	' Конструкция Eval("...") используется для подавления ошибки при обращении к св-ву DialogArguments
	'	из немодального окна.
	arrResult = Eval("Array(DialogArguments)")
	If IsObject(arrResult(0)) Then
		Set vDialogArguments = arrResult(0)
		If "internal_DialogArgsAndReturnValueClass" = TypeName(vDialogArguments) Then
			If IsObject(vDialogArguments.internal_Arguments) Then
				Set  vDialogArguments = vDialogArguments.internal_Arguments
				Set X_GetDialogArguments = vDialogArguments
			Else
				vDialogArguments = vDialogArguments.internal_Arguments
				X_GetDialogArguments = vDialogArguments
			End If
		Else
			Err.Raise -1, "x-utils.vbs - X_GetDialogArguments", _
				"Для вызова диалогового окна необходимо использовать X_ShowModalDialog(Ex)!"
		End If
	Else
		vDialogArguments = arrResult(0)
	End If		
End Function

'===============================================================================
'@@X_SetDialogWindowReturnValue
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SetDialogWindowReturnValue>
':Назначение:	
'	Устанавливает результат выполнения диалогового окна.
'	Предназначен для борьбы с последствиями KB974455  MS09-054: Cumulative security update for Internet Explorer
'	http://support.microsoft.com/kb/976749/
':Параметры:
'	vReturnValue - 
'       [in] значение.
':Сигнатура:
'	Sub X_SetDialogWindowReturnValue( vReturnValue [As Variant] )
Sub X_SetDialogWindowReturnValue( vReturnValue )
	If IsObject( vReturnValue ) Then
		Set window.DialogArguments.internal_ReturnValue = vReturnValue
	Else
		window.DialogArguments.internal_ReturnValue = vReturnValue
	End If		
End Sub

'===============================================================================
'@@X_ShowModalDialog
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ShowModalDialog>
':Назначение:
'	Функция открывает диалоговое окно, дополнительно добавляя в URL параметры
'   SCREENWIDTH и SCREENHEIGHT.
':Параметры:
'	sURL - 
'       [in] URL диалога.
'	vDialogArguments - 
'       [in] параметры, передаваемые в вызываемый диалог.
':Результат:
' 	Результат, возвращаемый диалогом (результат вызова X_SetDialogWindowReturnValue).
':Сигнатура:
'   Function X_ShowModalDialog (
'       sURL [As String], 
'       vDialogArguments [As Variant]
'   ) [As Variant]
Function X_ShowModalDialog(sURL, vDialogArguments)
	Dim arrResult ' результат
	arrResult = Array(	 X_ShowModalDialogEx(sURL & "&SCREENWIDTH=" & window.screen.availWidth & "&SCREENHEIGHT=" & window.screen.availHeight, vDialogArguments, "help:no;center:yes;status:no") )
	If IsObject(arrResult(0)) Then
		Set X_ShowModalDialog = arrResult(0)
	Else
		X_ShowModalDialog = arrResult(0)
	End If
End Function

'===============================================================================
'@@X_OpenReport
'<GROUP !!FUNCTIONS_x-utils><TITLE X_OpenReport>
':Назначение:
'	Функция открывает окно с отчетом.
':Параметры:
'	sURL - 
'       [in] адрес страницы отчета.
':Результат:
' 	Результат вызова window.open.
':Сигнатура:
'   Function X_OpenReport (
'       sURL [As String] 
'   ) [As IHTMLWindow]
Function X_OpenReport(sURL)
	If Len(sURL) = 0 Then
		sURL = ABOUT_BLANK
	ElseIf 0 <> StrComp(sURL, ABOUT_BLANK, vbTextCompare) Then
		' Добавляем параметр tm для предотвращения кэширования (только если его еще нет!)
		If 0 >= InStr(1, sURL, "&tm=", vbTextCompare) Then
			If 0>=InStr(1, sURL, "?tm=", vbTextCompare) Then
				sURL = sURL & iif(InStr(1, sURL, "?"), "&tm=" , "?tm=" ) & CDbl(now)
			End If
		End If
	End If

	' Открываем окно отчета и устанавливаем на него фокус
	' К наименованию окна добавляем случайное целое от 0 до 100000
	Randomize
	Set X_OpenReport = window.open(sURL, "report_" & CLng( Rnd()*100000), _
			"width=" & CStr(screen.availWidth*0.9) & _
			",height=" & CStr(screen.availHeight*0.9) & _
			",top=1,left=1,toolbar=no,menubar=yes,location=no,resizable=yes,scrollbars=yes,status=no,directories=no")
End Function

'===============================================================================
'@@X_OpenReportEx
'<GROUP !!FUNCTIONS_x-utils><TITLE X_OpenReportEx>
':Назначение:
'	Функция открывает окно с отчетом. 
':Параметры:
'	sURL - 
'       [in] адрес страницы отчета.
'   vReportParams -
'       [in] коллекция параметров отчета (в виде класса QueryStringClass или строки вида Name1=Value1&Name2=Value2&...&NameY=ValueY.)
'   bSendUsingPOST -
'       [in] True - всегда передавать параметры на сервер методом POST; False - использовать POST только, если длина URL > MAX_GET_SIZE
':Результат:
' 	Результат вызова window.open.
':Сигнатура:
'   Function X_OpenReportEx (
'       sURL [As String],
'       vReportParams [As String | QueryStringClass],
'       bSendUsingPOST [As Boolean]
'   ) [As IHTMLWindow]
Function X_OpenReportEx(sURL, vReportParams, bSendUsingPOST)
    Dim sReportParams   '[As String] - параметры отчета в виде строки
    Dim oReportParams   '[As QueryStringClass] - параметры отчета в виде класса
    Dim oDoc            ' документ окна броузера
    Dim sKey            '[As String] - наименование параметра отчета
    Dim aValues         '[As Array] - массив значений параметра отчета
    Dim sValue          '[As String] - значение параметра отчета
    
    If IsNothing(vReportParams) Then
        ' Параметры передали строкой
        sReportParams = toString(vReportParams)
        If Len(sReportParams) > 0 Then
            Set oReportParams = New QueryStringClass
            oReportParams.QueryString = sReportParams                
        End If
    Else
        ' Параметры передали классом
        Set oReportParams = vReportParams
        sReportParams = oReportParams.QueryString
    End If

    If Len(sReportParams) = 0 Then
        Set X_OpenReportEx = X_OpenReport(sURL)
        Exit Function
    End If
    
    If Not bSendUsingPOST And Len(sURL) + Len(sReportParams) <= MAX_GET_SIZE Then
        ' Передаем через GET
        If InStr(1, sURL, "?") <= 0 Then
            sURL = sURL & "?" & sReportParams
        Else
            sURL = sURL & "&" & sReportParams
        End If
        Set X_OpenReportEx = X_OpenReport(sURL)
        Exit Function
    End If
    
    ' Будем передавать через POST. Для этого в новом окне создадим форму, заполним параметрами и заPOSTим
    Set X_OpenReportEx = X_OpenReport(ABOUT_BLANK)
    Set oDoc = X_OpenReportEx.document
    oDoc.open
    oDoc.writeln "<HTML><HEAD><meta http-equiv=""Content-Type"" content=""text/html; charset=windows-1251"" /></HEAD>"
    oDoc.writeln "<BODY><FORM id=""PostDataForm"" method=""POST"" action=""" & XService.HtmlEncodeLite(sURL) & """>"
    For Each sKey In oReportParams.Names
        aValues = oReportParams.GetValues(sKey)
        If IsArray(aValues) Then
            For Each sValue in aValues
                oDoc.writeln "<INPUT name=""" & XService.HtmlEncodeLite(sKey) & """ type=""hidden"" value=""" & XService.HtmlEncodeLite(sValue) & """></INPUT>"
            Next
        End If
    Next
    oDoc.writeln "</FORM>"
    oDoc.writeln "<SCRIPT TYPE=""text/vbscript"" LANGUAGE=""VBScript"">"
    oDoc.writeln "document.charset=""windows-1251"""
    oDoc.writeln "setTimeout ""document.forms(""""PostDataForm"""").submit"", 10, ""VBScript"""
    oDoc.writeln "</SCRIPT></BODY></HTML>"
    oDoc.close
End Function

'===============================================================================
'@@X_OpenHelp
'<GROUP !!FUNCTIONS_x-utils><TITLE X_OpenHelp>
':Назначение:
'	Процедура показывает окно справки.
':Параметры:
'	vHelpPage - 
'       [in] имя страницы со справкой.
':Сигнатура:
'   Sub X_OpenHelp(ByVal vHelpPage [As Variant])
Sub X_OpenHelp(ByVal vHelpPage)
	vHelpPage = "" & vHelpPage
	if 0=len( vHelpPage) Then
		vHelpPage = "HELP/HELP.ASPX"
	Else
		vHelpPage = "HELP/HELP.ASPX?" & XService.UrlEncode( vHelpPage)
	End if		
	window.open vHelpPage, "CrocXmlFrameworkHelpWindow_B2F1D332EB024632BA4EF8E72BC86957" , _
			"width=" & CStr(screen.availWidth*0.7) & _
			",height=" & CStr(screen.availHeight*0.7) & _
			",top=1,,left=1,toolbar=no,menubar=no,location=no,resizable=yes,scrollbars=yes,status=no"
End Sub


'===============================================================================
'@@X_DebugShowHTML
'<GROUP !!FUNCTIONS_x-utils><TITLE X_DebugShowHTML>
':Назначение:
'	Процедура открывает окно и выводит в него исходный HTML-текст.
':Параметры:
'	vHtml - 
'       [in] выводимый HTML-текст.
':Сигнатура:
'   Sub X_DebugShowHTML(vHtml [As Variant])
Sub X_DebugShowHTML( vHtml)
	Dim oWin	' Новое окно
	If IsObject( vHtml) Then
		window.showModelessDialog "x-html-dom-navigator.aspx", vHtml, "help:no;center:yes;status:no;resizable:yes"
	Else
		' Открываем отладочное окно
		Set oWin = window.open(ABOUT_BLANK, "_blank", "height=200,width=400,status=yes,toolbar=no,menubar=no,location=no,scrollbars=yes,resizable=yes")
		' Выводим текст
		oWin.document.open
		oWin.document.write "<PLAINTEXT>" & vHtml
		oWin.document.close
	End If	
End Sub


'===============================================================================
'@@X_DebugShowXML
'<GROUP !!FUNCTIONS_x-utils><TITLE X_DebugShowXML>
':Назначение:
'	Процедура открывает окно с XML-документом, преобразованным отладочным шаблоном.
':Параметры:
'	oXMLDOMDocument - 
'       [in] выводимый XML, экземпляр IXMLDOMDocument или IXMLDOMElement.
':Сигнатура:
'   Sub X_DebugShowXML(oXMLDOMDocument [As Variant])
Sub X_DebugShowXML( oXMLDOMDocument)
	CONST XML_NODE_DOCUMENT = 9
	Dim oStyle	' XSL
	Dim oWin	' Новое окно
	Dim oXmlDoc	' Отображаемый документ
	' Загружаем шаблон
	On Error Resume Next
	Set oStyle = XService.XMLGetDocument( "xsl/x-debug.xsl")
	if Err Then
		X_ErrReport()
		Exit Sub
	End if
	if XML_NODE_DOCUMENT =  oXMLDOMDocument.nodeType Then
		Set oXmlDoc = oXMLDOMDocument
	Else
		Set oXmlDoc = XService.XMLGetDocument()
		Set oXmlDoc.documentElement = oXMLDOMDocument.cloneNode( true) 
	End if
	' Открываем отладочное окно
	Set oWin = window.open(ABOUT_BLANK, "_blank", "height=200,width=400,status=yes,toolbar=no,menubar=no,location=no,scrollbars=yes,resizable=yes")
	' Выводим текст
	oWin.document.open
	oWin.document.write oXmlDoc.transformNode( oStyle)
	oWin.document.close
End Sub


'===============================================================================
'@@X_IsFrameReady
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsFrameReady>
':Назначение:
'	Функция осуществляет проверку, что фрейм загружен и инициализирован.
':Параметры:
'	oFrame - 
'       [in] HTML-элемент <b>FRAME</b> или <b>IFRAME</b>.
':Результат:
' 	Возвращает True, если фрейм загружен и инициализирован, или False - в 
'	противном случае.
':Примечание:
'	Проверяет соответствие атрибута <b>src</b> адресу документа, загруженного
'	во фрейм, и для проверки состояния загруженного документа вызывает функцию
'	X_IsDocumentReady.
':Сигнатура:
'   Function X_IsFrameReady ( 
'       oFrame [As IHTMLElement]
'   ) [As Boolean]
Function X_IsFrameReady( oFrame)
	Dim oDoc	' Документ в фрейме
	' Проверяем состояние элемента FRAME или IFRAME
	if 0 <> StrComp(oFrame.readyState, "complete", vbTextCompare) Then 
		X_IsFrameReady = false
		Exit Function
	End if
	' Фрейму не назначено содержимое
	if 0 = Len(oFrame.src) Then 
		X_IsFrameReady = true
		Exit Function
	End if
	' Трюк для перехода к DOM загруженного документа
	Set oDoc = oFrame.Document.Frames(oFrame.uniqueID).Document
	' Проверяем URL
	if 0 = InStr( 1, oDoc.location.href, oFrame.src, vbTextCompare) Then
		X_IsFrameReady = false
		Exit Function
	End if
	' Проверяем загруженный документ
	X_IsFrameReady = X_IsDocumentReady( oDoc)
End Function


'===============================================================================
'@@X_IsObjectReady
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsObjectReady>
':Назначение:
'	Функция осуществляет проверку, что объект загружен и инициализирован.
':Параметры:
'	oObject - 
'       [in] HTML-элемент <b>OBJECT</b> или объект IXMLDOMDocument.
':Результат:
' 	Возвращает True, если объект загружен и инициализирован, или False - в 
'	противном случае.
':Сигнатура:
'   Function X_IsObjectReady ( 
'       oObject [As Variant]
'   ) [As Boolean]
Function X_IsObjectReady( oObject)
	Const READY_STATE_INITIALIZED = 4	' Состояние объекта - инициализирован
	X_IsObjectReady = ( READY_STATE_INITIALIZED = CLng( oObject.readyState) )
End Function


'===============================================================================
'@@X_IsBehaviorReady
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsBehaviorReady>
':Назначение:
'	Функция осуществляет проверку, что DHTML Behavior загружен и инициализирован.
':Параметры:
'	oObject - 
'       [in] ссылка на экземпляр DHTML Behavior.
':Результат:
' 	Возвращает True, если DHTML Behavior загружен и инициализирован, или False - в 
'	противном случае.
':Примечание:
'	Используется для всех DHTML Behavior в XFW .NET.<P/>
'	Готовность определяется с помощью вызова метода IsComponentReady.
':Сигнатура:
'   Function X_IsBehaviorReady ( 
'       oObject [As Variant]
'   ) [As Boolean]
Function X_IsBehaviorReady(oObject)
	On Error Resume Next

	X_IsBehaviorReady = oObject.IsComponentReady
	If Err Then
		On Error GoTo 0
		X_IsBehaviorReady = True
	End If
End Function


'===============================================================================
'@@X_IsDocumentReady
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsDocumentReady>
':Назначение:
'	Функция осуществляет проверку, что документ загружен и инициализирован.
':Параметры:
'	oDoc - 
'       [in] документ или другой элемент, который содержит коллекцию all.
':Результат:
' 	Возвращает True, если документ загружен и инициализирован, или False - в 
'	противном случае.
':Примечание:
'	Если значение параметра <b><i>oDoc</b></i> - Null, то проверяется текущий
'   документ.<P/>
'	В документе проверяется состояние фреймов и объектов. Для проверки фреймов 
'   вызывается функция X_IsFrameReady, для проверки объектов - функция
'   X_IsObjectReady.
':Сигнатура:
'   Function X_IsDocumentReady ( 
'       byval oDoc [As Variant]
'   ) [As Boolean]
Function X_IsDocumentReady(byval oDoc)
	Dim oElement	' Элемент документа
	X_IsDocumentReady = False
	If IsNull( oDoc) Then
		Set oDoc = Document
	End If	
	If 0 <> StrComp(oDoc.readyState, "complete", vbTextCompare) Then Exit Function
	With oDoc.all
		' Ищем фреймы
		For Each oElement In .tags("iframe")
			If Not X_IsFrameReady( oElement) Then Exit Function
		Next
		For Each oElement In .tags("frame")
			If Not X_IsFrameReady( oElement) Then Exit Function
		Next
		' Ищем объекты
		For Each oElement In .tags("object")
			If Not X_IsObjectReady( oElement) Then Exit Function
		Next
	End With
	X_IsDocumentReady = True
End Function


'===============================================================================
'@@X_IsDocumentReadyEx
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsDocumentReadyEx>
':Назначение:
'	Функция осуществляет проверку, что документ загружен и инициализирован, а также
'   что загружены все элементы заданных тегов.
':Параметры:
'	oDoc - 
'       [in] документ или другой элемент, который содержит коллекцию all.
'	vCustomTags - 
'       [in] наименование custom-тега DHTML Behavior, либо массив наименований.
':Результат:
' 	Возвращает True, если документ загружен и инициализирован и загружены все
'   элементы заданных тегов, или False - в противном случае.
':Примечание:
'   Функция используется на страницах, содержащих DHTML Behavior.<P/>
'	Если значение параметра <b><i>oDoc</b></i> - Null, то проверяется текущий
'   документ.<P/>
'	Функция вызывает функцию X_IsDocumentReady. Если результат ее вызова - True, то 
'   на странице находятся все элементы заданных тегов и для каждого из них вызывается
'   функция X_IsBehaviorRead.
':Сигнатура:
'   Function X_IsDocumentReadyEx ( 
'       byval oDoc [As Variant],
'       vCustomTags [As Variant]
'   ) [As Boolean]
Function X_IsDocumentReadyEx(byval oDoc, vCustomTags)
	Dim sCustomTag 
	Dim oElement
	
	X_IsDocumentReadyEx = False
	If Not X_IsDocumentReady(oDoc) Then Exit Function
	If Not IsNull(vCustomTags) Then 
		If VarType(vCustomTags) = vbString Then
			vCustomTags = Array(vCustomTags)
		End If
		If IsArray(vCustomTags) Then 
			If IsNull( oDoc) Then
				Set oDoc = Document
			End If
			For Each sCustomTag In vCustomTags
				For Each oElement In oDoc.getElementsByTagName(sCustomTag)
					If Not X_IsBehaviorReady(oElement) Then Exit Function
				Next
			Next
		End If
	End If
	X_IsDocumentReadyEx = True
End Function


'===============================================================================
'@@X_IsProcPresented
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsProcPresented>
':Назначение:
'	Функция проверяет наличие функции или процедуры с именем, заданным в параметре
'   <b><i>sName</b></i>.
':Параметры:
'	sName - 
'       [in] имя процедуры.
':Результат:
' 	Возвращает True, если процедура с заданным именем найдена, или False - в 
'   противном случае.
':Примечание:
'   <b><i>Внимание!</b></i> Функция может подавить сообщение об ошибке, возникшей 
'   до вызова этой функции.
':Сигнатура:
'   Function X_IsProcPresented ( 
'       sName [As String]
'   ) [As Boolean]
Function X_IsProcPresented( sName)
	Const ERR_NO_SUCH_FUNCTION = 5	' Код ошибки об отсутствии функции
	X_IsProcPresented = False
	' Предупреждение рекурсивного вызова
	If 0 = StrComp( sName, "X_IsProcPresented", vbTextCompare) Then Exit Function
	On Error Resume Next
	GetRef  sName
	If ERR_NO_SUCH_FUNCTION = Err.number Then
		On Error Goto 0 
		Exit Function
	End if
	X_IsProcPresented = True
End Function


'===============================================================================
'@@X_SetComboBoxValue
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SetComboBoxValue>
':Назначение:
'	Функция выбирает в элементе SELECT пункт (OPTION) с заданным номером (селектором).
':Параметры:
'	oComboBox - 
'       [in] HTML-элемент SELECT.
'	vVal - 
'       [in] значение, соответствующее выбираемому пункту (OPTION).
':Результат:
' 	Возвращает индекс пункта селектора или -1.
':Сигнатура:
'   Function X_SetComboBoxValue (
'       oComboBox [As IHTMLElement], 
'       vVal [As Variant]
'   ) [As Int]
Function X_SetComboBoxValue(oComboBox, vVal)
	X_SetComboBoxValue = X_SetComboBoxTypedValue(oComboBox, vVal, "")
End Function


'===============================================================================
'@@X_SetComboBoxTypedValue
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SetComboBoxTypedValue>
':Назначение:
'	Функция выбирает в элементе SELECT пункт (OPTION), номер (селектор) которого
'   определяется путем приведения значения, задаваемого параметром <b><i>vVal</b></i>.
':Параметры:
'	oComboBox - 
'       [in] HTML-элемент SELECT.
'	vVal - 
'       [in] значение, соответствующее выбираемому пункту (OPTION).
'	sTypeCast - 
'       [in] имя процедуры.
':Результат:
' 	Возвращает индекс пункта селектора или -1.
':Примечание:
'   Если значение параметра <b><i>vVal</b></i> - Null, то выделение сбрасывается 
'   (на индекс -1).<P/>
'   <b><i>Внимание!</b></i> Если задана функция, то на вычисляемое выражение применяется
'   "Eval" (для того, чтобы в качестве значения пункта (OPTION) в элементе SELECT
'   можно было бы задавать константы - имеет смысл только для необъектных элементов 
'   SELECT).
':Сигнатура:
'   Function X_SetComboBoxTypedValue (
'       oComboBox [As IHTMLElement], 
'       vVal [As Variant], 
'       sTypeCast [As String]
'   ) [As Int]
Function X_SetComboBoxTypedValue(oComboBox, vVal, sTypeCast)
	Dim i
	Dim bIsEquals	' признак выполнения условия сравнения
	
	XService.DoEvents	' Протолкнем очередь сообщений (инц. №39381)
	X_SetComboBoxTypedValue = -1

	If IsNull(vVal) Then
		' в комбобоксе не может быть значения Null, а нам могли передать - значит надо сбросить выделение
		oComboBox.SelectedIndex = -1
		Exit Function
	End If
	With oComboBox.options
		For i=0 to .length-1
			' Eval Для .item(i).Value делаем потому, что в значении option'а может быть наименование константы
			If Len("" & sTypeCast)>0 And sTypeCast <> "CStr" And Len("" & .item(i).Value)>0 Then
				' если задана функция приведения типа, то сравним типизированные значения
				' если функция CStr, то Eval делать не надо, т.к. combo содержить не константы, а сами значения, просто они строковые
				' если функция CBool то надо выполнить специальную "обработку"
				If "CBool" = sTypeCast Then
					bIsEquals = CBool( iif(vVal,true,false)=Eval("CBool(" & .item(i).Value &")") )
				Else
					bIsEquals = CBool( Eval( sTypeCast & "(" & .item(i).Value & ")") = Eval(sTypeCast & "(" & vVal &")") )
				End If	
			Else
				' иначе сравним как есть
				bIsEquals = CBool( .item(i).Value = vVal )
			End If
			If bIsEquals Then
				oComboBox.SelectedIndex = i
				X_SetComboBoxTypedValue = i
				Exit Function
			End If
		Next
	End With 
End Function


'===============================================================================
'@@X_SetActiveXComboBoxValue
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SetActiveXComboBoxValue>
':Назначение:
'	Функция устанавливает активный пункт в <LINK CROC.XComboBox, CROC.XComboBox />.
':Параметры:
'	oComboBox - 
'       [in] экземпляр компоненты <LINK CROC.XComboBox, CROC.XComboBox />.
'	vVal - 
'       [in] значение, соответствующее активному пункту.
':Результат:
' 	Возвращает индекс пункта селектора или -1.
':Сигнатура:
'   Function X_SetActiveXComboBoxValue (
'       oComboBox [As CROC.XComboBox], 
'       vVal [As Variant]
'   ) [As Int]
Function X_SetActiveXComboBoxValue(oComboBox, vVal)
	' Устанавливаем текущий элемент
	X_SetActiveXComboBoxValue = -1
	If IsNull(vVal) Then
		oComboBox.Rows.SelectedID = vbNullString
	Else
		If Not oComboBox.Rows.GetRowByID(vVal) Is Nothing Then
			oComboBox.Rows.SelectedID = vVal
			X_SetActiveXComboBoxValue = oComboBox.Rows.Selected
		End If
	End If
End Function


'===============================================================================
'@@X_AddComboBoxItem
'<GROUP !!FUNCTIONS_x-utils><TITLE X_AddComboBoxItem>
':Назначение:
'	Процедура добавляет пункт (OPTION) с заданным номером (селектором) в элемент SELECT.
':Параметры:
'	oComboBox - 
'       [in] HTML-элемент SELECT.
'	vVal - 
'       [in] значение, соответствующее добавляемому пункту (OPTION).
'	sText - 
'       [in] текст добавляемого пункта (OPTION).
':Сигнатура:
'   Sub X_AddComboBoxItem (
'       oComboBox [As IHTMLElement], 
'       vVal [As Variant], 
'       sText [As String]
'   )
Sub X_AddComboBoxItem( oComboBox, vVal, sLabel)
	Dim oOption	' Элемент OPTION
	Set oOption = window.document.createElement( "OPTION")
	oOption.appendChild window.document.createTextNode( sLabel)
	oOption.Value = vVal
	oComboBox.appendChild oOption
End Sub


'===============================================================================
'@@X_AddActiveXComboBoxItem
'<GROUP !!FUNCTIONS_x-utils><TITLE X_AddActiveXComboBoxItem>
':Назначение:
'	Процедура добавляет элемент в <LINK CROC.XComboBox, CROC.XComboBox />.
':Параметры:
'	oComboBox - 
'       [in] экземпляр компоненты <LINK CROC.XComboBox, CROC.XComboBox />.
'	vVal - 
'       [in] значение, соответствующее добавляемому элементу.
'	sText - 
'       [in] текст добавляемого элемента.
':Сигнатура:
'   Sub X_AddActiveXComboBoxItem (
'       oComboBox [As CROC.XComboBox], 
'       vVal [As Variant], 
'       sText [As String]
'   )
Sub X_AddActiveXComboBoxItem( oComboBox, vVal, sLabel)
	With oComboBox.columns
		If .Count=0 Then .Add "X_TEXT", "string"
	End With
	oComboBox.Rows.Add	Array(sLabel), CStr(vVal)
End Sub


'===============================================================================
'@@X_GetStringHash
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetStringHash>
':Назначение:
'	Функция вычисляет хэш строки.
':Параметры:
'	s - 
'       [in] строка.
':Результат:
' 	Хэш строки.
':Сигнатура:
'   Function X_GetStringHash (s [As String]) [As String]
Function X_GetStringHash(s)
	X_GetStringHash = XService.GetMD5Hex(s)
End Function


'===============================================================================
'@@X_ClearListDataCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ClearListDataCache>
':Назначение:
'	Процедура удаляет файлы кэша для заданного списка.
':Параметры:
'	sTypeName - 
'       [in] наименование типа (ds:type), в метаданных которого определен список.
'	sMetaName - 
'       [in] метаимя списка.
'	vRestrictions - 
'       [in] URL ограничений, передаваемых POST-запросом.
':Примечание:
'   Значение параметра <b><i>vRestrictions</b></i> - это параметр RESTR страницы
'   x-list-loader.aspx. Формируется вызовом X_CreateListLoaderRestrictions.
'   Если в качестве значения параметра передается Null, то удаляется весь кэш для 
'   данного списка. В противном случае, удаляется только кэш для данного ограничения.
':Сигнатура:
'   Sub X_ClearListDataCache (
'       sTypeName [As String], 
'       sMetaName [As String], 
'       vRestrictions [As Variant]
'   )
Sub X_ClearListDataCache(sTypeName, sMetaName, vRestrictions)
	Dim sFilePefix	' Часть имени файла. Все файлы начинающиеся на данную строку подлежат удалению
	sFilePefix = X_GetListCacheFileNameCommonPart(sTypeName, sMetaName, vRestrictions)
	internal_ClearDataCache sFilePefix
End Sub


'===============================================================================
'@@X_ClearCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ClearCache>
':Назначение:
'	Процедура удаляет все файлы из каталога с кешированными данными (в том числе
'   метаданные, XSL, данные списков, представления списков).
':Сигнатура:
'   Sub X_ClearCache ()
Sub X_ClearCache()
	internal_ClearDataCache "*"
End Sub


'===============================================================================
'@@X_ClearDataCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ClearDataCache>
':Назначение:
'	Процедура удаляет все файлы с закешированными данными (в том числе фильтры и данные
'   списков).
':Сигнатура:
'   Sub X_ClearDataCache ()
Sub X_ClearDataCache()
	internal_ClearDataCache "data."
End Sub


'===============================================================================
'@@X_ClearViewStateCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ClearViewStateCache>
':Назначение:
'	Процедура удаляет все файлы с закешированными представлениями.
':Сигнатура:
'   Sub X_ClearViewStateCache ()
Sub X_ClearViewStateCache()
	internal_ClearDataCache "view."
End Sub


'==============================================================================
' Удаляет из кэша  файлы, наименование которых начинается с указанной строки
'	[in] sFilePefix	- Часть имени файла. Все файлы начинающиеся на данную строку подлежат удалению
Sub internal_ClearDataCache(sFilePefix)
	Dim oFileSystemObject	' As Scripting.FileSystemObject
	Dim oSingleFile			' As Scripting.File - удаляемый файл
	Dim sAppFolderName		' As String - путь до каталога
	
	Set oFileSystemObject =	XService.CreateObject("Scripting.FileSystemObject")
	sAppFolderName = XService.GetAppDataPath
	If oFileSystemObject.FolderExists(sAppFolderName) Then
		For Each oSingleFile in oFileSystemObject.GetFolder(sAppFolderName).Files
			If sFilePefix = "*" Or 1=InStr(1,oSingleFile.Name, sFilePefix, vbTextCompare) Then
				oSingleFile.Delete true
			End If
		Next
	End If
End Sub


'==============================================================================
Sub X_SaveViewStateCache(sName, vData)
	XService.SetUserData "view." & sName, vData
End Sub


'==============================================================================
Sub X_SaveDataCache(sName, vData)
	XService.SetUserData "data." & sName, vData
End Sub


'==============================================================================
Function X_GetViewStateCache(sName, vData)
	X_GetViewStateCache = XService.GetUserData( "view." & sName, vData)
End Function


'==============================================================================
Function X_GetDataCache(sName, vData)
	X_GetDataCache = XService.GetUserData( "data." & sName, vData)
End Function


'===============================================================================
'@@X_GetListCacheFileNameCommonPart
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetListCacheFileNameCommonPart>
':Назначение:
'	Функция вычисляет имя файла для хранения кэша.
':Параметры:
'	sTypeName - 
'       [in] наименование типа (ds:type), в метаданных которого определен список.
'	sMetaName - 
'       [in] метаимя списка.
'	vRestrictions - 
'       [in] URL ограничений, передаваемых POST-запросом.
':Примечание:
'   Значение параметра <b><i>vRestrictions</b></i> - это параметр RESTR страницы
'   x-list-loader.aspx. Формируется вызовом X_CreateListLoaderRestrictions.
'   Если в качестве значения параметра передается Null, то его хэш не участвует 
'   в именовании файла.
':Сигнатура:
'   Function X_GetListCacheFileNameCommonPart (
'       sTypeName [As String], 
'       sMetaName [As String], 
'       vRestrictions [As Variant]
'   ) [As String]
Function X_GetListCacheFileNameCommonPart(sTypeName, sMetaName, vRestrictions)
	X_GetListCacheFileNameCommonPart = "XSLD." & sTypeName & "." & sMetaName & "."
	If Not IsNull(vRestrictions) Then
		' На основании параметров vRestrictions вычисляется MD5-хеш - НО при этом
		' из параметров д.б. исключено пара параметр-значение "VALUEOBJECTID=":
		Dim sRestrictions
		sRestrictions = internal_getPartlyRestrictions("" & vRestrictions,null,"")
		If Len(sRestrictions) > 0 Then X_GetListCacheFileNameCommonPart = X_GetListCacheFileNameCommonPart & X_GetStringHash(sRestrictions) & "." 
	End If
End Function


'===============================================================================
'@@X_GetListData
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetListData>
':Назначение:
'	Функция возвращает данные для заполнения выпадающего списка (элемента SELECT).
':Параметры:
'	nUseCache - 
'       [in] признак использования кэширования
'       (<LINK CACHE_BEHAVIOR_nnnn, CACHE_BEHAVIOR_nnnn />).
'	sTypeName - 
'       [in] наименование типа (ds:type), в метаданных которого определен список.
'	sMetaName - 
'       [in] метаимя списка.
'	sRestrictions - 
'       [in] URL ограничений, передаваемых POST-запросом.
'	sSaltExpression - 
'       [in] дополнительный параметр для кэширования (VBS-код, возвращающий результат).
':Примечание:
'   Значение параметра <b><i>sRestrictions</b></i> - это параметр RESTR страницы
'   x-list-loader.aspx. Формируется вызовом X_CreateListLoaderRestrictions.
':Сигнатура:
'   Function X_GetListData (
'       nUseCache [As Int],
'       sTypeName [As String], 
'       sMetaName [As String], 
'       ByVal sRestrictions [As String],
'       ByVal sSaltExpression [As String] 
'   ) [As IXMLDOMElement]
Function X_GetListData(nUseCache, sTypeName, sMetaName, ByVal sRestrictions, ByVal sSaltExpression)
	Dim sDataName	' Имя файла с данными
	Dim bCached		' Признак наличия закэшированных данных
	Dim oData		' Закэшированные данные
	Dim oDataEntry	' Элемент закэшированных данных
	Dim sFilePefix	' Часть имени файла. Все файлы начинающиеся на данную строку подлежат удалению
	
	Dim sPartlyRestrictions	' Строка параметров ограничения, без VALUEOBJECTID
	Dim vPartValueObjectIDs	' Значение вычлененных ограничений VALUEOBJECTID
	Dim sQueryValueObjectID	' ... и XPath-выражение для поиска VALUEOBJECTID в кеше
	
	sRestrictions = "" & sRestrictions
	If CACHE_BEHAVIOR_NOT_USE = nUseCache Then
		Set X_GetListData = X_GetListDataFromServer(sTypeName, sMetaName, sRestrictions)
	Else		
		If Not hasValue(sSaltExpression) Then
			sSaltExpression = "0"
		End If
		sFilePefix = X_GetListCacheFileNameCommonPart(sTypeName, sMetaName, sRestrictions)
		sDataName =  sFilePefix & Eval(sSaltExpression)
		sPartlyRestrictions = internal_getPartlyRestrictions(sRestrictions,null,vPartValueObjectIDs)
		
		' Получаем кэшированные данные
		If CACHE_BEHAVIOR_USE = nUseCache Then
			bCached = X_GetDataCache(sDataName, oData)
		Else
			bCached = False
		End If	
		
		If bCached Then
			' Если есть кэш, то проверяем наличие блока с соотв. ограничениями, и, если 
			' задавался VALUEOBJECTID, ищем соотв. данные с таким id (если таких нет,
			' то блок из кеша удаляется, т.к. будет прогружен далее)
			sQueryValueObjectID = ""
			If hasValue(vPartValueObjectIDs) Then sQueryValueObjectID = ".//*[@id='" & vPartValueObjectIDs(0) & "']"
		
			For Each oDataEntry in oData.selectNodes("*")
				If oDataEntry.getAttribute("restr") = sPartlyRestrictions Then
					bCached = True
					If Len(sQueryValueObjectID) > 0 Then 
						bCached = ( oDataEntry.selectNodes(sQueryValueObjectID).length > 0 )
						If Not bCached Then	oData.removeChild oDataEntry
					End If
					If bCached Then
						Set X_GetListData = oDataEntry.FirstChild
						Exit Function
					End If
				End If
			Next
		Else
			' Удалим все кэши для данного сочетания sTypeName, sMetaName, sRestrictions
			internal_ClearDataCache sFilePefix
			' Конструируем новый кэш
			Set oData = XService.XmlGetDocument()
			Set oData = oData.appendChild( oData.CreateElement("root") )
		End If
		
		' Загрузка данных с сервера, запись в кэш:
		Set oDataEntry = X_GetListDataFromServer( sTypeName, sMetaName, sRestrictions )
		With oData.AppendChild( oData.ownerDocument.createElement("entry") )
			' NB! Для блока закешированных данных указываем все ограничения, кроме VALUEOBJECTID!
			.SetAttribute "restr", sPartlyRestrictions
			.AppendChild oDataEntry
		End With
		' Сохраняем корневой элемент в клиентском кэше
		X_SaveDataCache sDataName, oData
		Set X_GetListData = oDataEntry
	End If	
End Function


'===============================================================================
'@@X_LoadComboBox
'<GROUP !!FUNCTIONS_x-utils><TITLE X_LoadComboBox>
':Назначение:
'	Функция заполняет выпадающий список (элемент SELECT) на основании списка, 
'   определенного в метаданных, без использования кэширования.
':Параметры:
'	oComboBox - 
'       [in] выпадающий список (элемент SELECT).
'	sTypeName - 
'       [in] наименование типа (ds:type), в метаданных которого определен список.
'	sMetaName - 
'       [in] метаимя списка.
'	sUserRestrictions - 
'       [in] URL ограничений, передаваемых POST-запросом.
'	sValueObjectIDs - 
'       [in] список идентификаторов объектов, которые должны попасть в выборку.
':Примечание:
'   Значение параметра <b><i>sUserRestrictions</b></i> - это параметр RESTR страницы
'   x-list-loader.aspx.<P/>
'   Значение параметра <b><i>sValueObjectIDs</b></i> - это параметр VALUEOBJECTID 
'   страницы x-list-loader.aspx.
':Сигнатура:
'   Function X_LoadComboBox (
'       oComboBox [As IHTMLElement],
'       sTypeName [As String], 
'       sMetaName [As String], 
'       sUserRestrictions [As String],
'       sValueObjectIDs [As String] 
'   ) [As Boolean]
Function X_LoadComboBox(oComboBox, sTypeName, sMetaName, sUserRestrictions, sValueObjectIDs)
	X_LoadComboBox = X_LoadComboBoxUseCache( CACHE_BEHAVIOR_NOT_USE, oComboBox, sTypeName, sMetaName, sUserRestrictions, Null,  sValueObjectIDs, Empty )
End Function


'===============================================================================
'@@X_LoadComboBoxUseCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_LoadComboBoxUseCache>
':Назначение:
'	Функция заполняет выпадающий список (элемент SELECT) на основании списка, 
'   определенного в метаданных.
':Параметры:
'	nUseCache - 
'       [in] признак использования кэширования
'       (<LINK CACHE_BEHAVIOR_nnnn, CACHE_BEHAVIOR_nnnn />).
'	oComboBox - 
'       [in] выпадающий список (элемент SELECT).
'	sTypeName - 
'       [in] наименование типа (ds:type), в метаданных которого определен список.
'	sMetaName - 
'       [in] метаимя списка.
'	sUserRestrictions - 
'       [in] URL ограничений, передаваемых POST-запросом.
'	sUrlArguments - 
'       [in] дополнительные параметры загрузчика.
'	sValueObjectIDs - 
'       [in] список идентификаторов объектов, которые должны попасть в выборку.
'	sSaltExpression - 
'       [in] дополнительный параметр для кэширования (VBS-код, возвращающий результат).
':Примечание:
'   Значение параметра <b><i>sUserRestrictions</b></i> - это параметр RESTR страницы
'   x-list-loader.aspx.<P/>
'   Значение параметра <b><i>sValueObjectIDs</b></i> - это параметр VALUEOBJECTID 
'   страницы x-list-loader.aspx.
':Результат:
'	Возвращает True, если список был ограничен серверным условием MAXROWS, и False в 
'   противном случае.
':Сигнатура:
'   Function X_LoadComboBoxUseCache (
'       nUseCache [As Int],
'       oComboBox [As IHTMLElement],
'       sTypeName [As String], 
'       sMetaName [As String], 
'       sUserRestrictions [As String],
'       sUrlArguments [As String],
'       sValueObjectIDs [As String],
'       sSaltExpression [As String],
'   ) [As Boolean]
Function X_LoadComboBoxUseCache(nUseCache, oComboBox, sTypeName, sMetaName, sUserRestrictions, sUrlArguments,  sValueObjectIDs, sSaltExpression)
	X_LoadComboBoxUseCache = X_FillComboBox( oComboBox, X_GetListData(nUseCache, sTypeName, sMetaName, X_CreateListLoaderRestrictions(sUserRestrictions, sUrlArguments, sValueObjectIDs), sSaltExpression) )
End Function


'===============================================================================
'@@X_LoadActiveXComboBoxUseCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_LoadActiveXComboBoxUseCache>
':Назначение:
'	Функция заполняет выпадающий список ActiveX (<LINK CROC.XComboBox, CROC.XComboBox />)
'   данными списка, определенного в метаданных.
':Параметры:
'	nUseCache - 
'       [in] признак использования кэширования
'       (<LINK CACHE_BEHAVIOR_nnnn, CACHE_BEHAVIOR_nnnn />).
'	oComboBox - 
'       [in] выпадающий список ActiveX (<LINK CROC.XComboBox, CROC.XComboBox />).
'	sTypeName - 
'       [in] наименование типа (ds:type), в метаданных которого определен список.
'	sMetaName - 
'       [in] метаимя списка.
'	sUserRestrictions - 
'       [in] URL ограничений, передаваемых POST-запросом.
'	sUrlArguments - 
'       [in] дополнительные параметры загрузчика.
'	sValueObjectIDs - 
'       [in] список идентификаторов объектов, которые должны попасть в выборку.
'	sSaltExpression - 
'       [in] дополнительный параметр для кэширования (VBS-код, возвращающий результат).
':Примечание:
'   Значение параметра <b><i>sUserRestrictions</b></i> - это параметр RESTR страницы
'   x-list-loader.aspx.<P/>
'   Значение параметра <b><i>sValueObjectIDs</b></i> - это параметр VALUEOBJECTID 
'   страницы x-list-loader.aspx.
':Сигнатура:
'   Function X_LoadActiveXComboBoxUseCache (
'       nUseCache [As Int],
'       oComboBox [As CROC.XComboBox],
'       sTypeName [As String], 
'       sMetaName [As String], 
'       sUserRestrictions [As String],
'       sUrlArguments [As String],
'       sValueObjectIDs [As String],
'       sSaltExpression [As String],
'   ) [As Boolean]
Function X_LoadActiveXComboBoxUseCache(nUseCache, oComboBox, sTypeName, sMetaName, sUserRestrictions, sUrlArguments, sValueObjectIDs, sSaltExpression)
	Dim oListData 		' As IXMLDOMElement - Данные списка
	Dim oXmlDoc 		' As IXMLDOMDocument - XmlFillList работает только с XmlDomDocument
	Dim bHasMoreRows	' As Boolean - признак наличия в БД данных больше, чем получено
	Dim vMaxRows			' As Variant - значение атрибута maxrows xml-узла LIST
	
	bHasMoreRows = False
	Set oListData = X_GetListData(nUseCache, sTypeName, sMetaName, X_CreateListLoaderRestrictions(sUserRestrictions, sUrlArguments,  sValueObjectIDs), sSaltExpression)
	vMaxRows = oListData.getAttribute("maxrows")
	If Not IsNull(vMaxRows) Then
		bHasMoreRows = CLng(vMaxRows) < CLng(oListData.selectNodes("RS/R").length)
	End If
	
	Set oXmlDoc = oListData.ownerDocument.cloneNode(false)
	oXmlDoc.appendChild oListData
	oComboBox.XmlFillList oXmlDoc, True
	X_LoadActiveXComboBoxUseCache = bHasMoreRows
End Function


'===============================================================================
'@@X_LoadXListViewUseCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_LoadXListViewUseCache>
':Назначение:
'	Функция заполняет список ActiveX (<LINK CROC.XListView, CROC.XListView />)
'   данными списка, определенного в метаданных.
':Параметры:
'	nUseCache - 
'       [in] признак использования кэширования
'       (<LINK CACHE_BEHAVIOR_nnnn, CACHE_BEHAVIOR_nnnn />).
'	oXListView - 
'       [in] список ActiveX (<LINK CROC.XListView, CROC.XListView />).
'	sTypeName - 
'       [in] наименование типа (ds:type), в метаданных которого определен список.
'	sMetaName - 
'       [in] метаимя списка.
'	sUserRestrictions - 
'       [in] URL ограничений, передаваемых POST-запросом.
'	sUrlArguments - 
'       [in] дополнительные параметры загрузчика.
'	sValueObjectIDs - 
'       [in] список идентификаторов объектов, которые должны попасть в выборку.
'	sSaltExpression - 
'       [in] дополнительный параметр для кэширования (VBS-код, возвращающий результат).
':Примечание:
'   Значение параметра <b><i>sUserRestrictions</b></i> - это параметр RESTR страницы
'   x-list-loader.aspx.<P/>
'   Значение параметра <b><i>sValueObjectIDs</b></i> - это параметр VALUEOBJECTID 
'   страницы x-list-loader.aspx.
':Сигнатура:
'   Function X_LoadXListViewUseCache (
'       nUseCache [As Int],
'       oXListView [As CROC.XListView],
'       sTypeName [As String], 
'       sMetaName [As String], 
'       sUserRestrictions [As String],
'       sUrlArguments [As String],
'       sValueObjectIDs [As String],
'       sSaltExpression [As String],
'   ) [As Boolean]
Function X_LoadXListViewUseCache(nUseCache, oXListView, sTypeName, sMetaName, sUserRestrictions, sUrlArguments, sValueObjectIDs, sSaltExpression)
	' Т.к. интерфейсы CROC.XComboBox и CROC.XListView одинаковый
	X_LoadXListViewUseCache = X_LoadActiveXComboBoxUseCache( nUseCache, oXListView, sTypeName, sMetaName, sUserRestrictions, sUrlArguments, sValueObjectIDs, sSaltExpression )
End Function


'===============================================================================
'@@X_LoadActiveXComboBox
'<GROUP !!FUNCTIONS_x-utils><TITLE X_LoadActiveXComboBox>
':Назначение:
'	Функция заполняет выпадающий список ActiveX (<LINK CROC.XComboBox, CROC.XComboBox />)
'   данными списка, определенного в метаданных, без использования кэширования.
':Параметры:
'	oComboBox - 
'       [in] выпадающий список ActiveX (<LINK CROC.XComboBox, CROC.XComboBox />).
'	sTypeName - 
'       [in] наименование типа (ds:type), в метаданных которого определен список.
'	sMetaName - 
'       [in] метаимя списка.
'	sUserRestrictions - 
'       [in] URL ограничений, передаваемых POST-запросом.
'	sValueObjectIDs - 
'       [in] список идентификаторов объектов, которые должны попасть в выборку.
':Примечание:
'   Значение параметра <b><i>sUserRestrictions</b></i> - это параметр RESTR страницы
'   x-list-loader.aspx.<P/>
'   Значение параметра <b><i>sValueObjectIDs</b></i> - это параметр VALUEOBJECTID 
'   страницы x-list-loader.aspx.
':Сигнатура:
'   Function X_LoadActiveXComboBox (
'       oComboBox [As CROC.XComboBox],
'       sTypeName [As String], 
'       sMetaName [As String], 
'       sUserRestrictions [As String],
'       sValueObjectIDs [As String]
'   ) [As Boolean]
Function X_LoadActiveXComboBox(oComboBox, sTypeName, sMetaName, sUserRestrictions, sValueObjectIDs)
	X_LoadActiveXComboBox = X_LoadActiveXComboBoxUseCache( CACHE_BEHAVIOR_NOT_USE,oComboBox, sTypeName, sMetaName, sUserRestrictions, Null, sValueObjectIDs, Empty )
End Function


'===============================================================================
'@@X_GetListDataFromServer
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetListDataFromServer>
':Назначение:
'	Функция запрашивает данные с содержимым выпадающего списка с сервера.
':Параметры:
'	sTypeName - 
'       [in] наименование типа (ds:type), в метаданных которого определен список.
'	sMetaName - 
'       [in] метаимя списка.
'	sRestrictions - 
'       [in] URL ограничений, передаваемых POST-запросом.
':Примечание:
'   Значение параметра <b><i>sRestrictions</b></i> - это параметр RESTR страницы
'   x-list-loader.aspx. Формируется вызовом функции X_CreateListLoaderRestrictions.
':Результат:
'	Возвращает IXMLDOMElement со списком объектов (в формате x-list-loader.aspx).
':Сигнатура:
'   Function X_GetListDataFromServer (
'       sTypeName [As String], 
'       sMetaName [As String], 
'       ByVal sRestrictions [As String]
'   ) [As IXMLDOMElement]
Function X_GetListDataFromServer(sTypeName, sMetaName,ByVal sRestrictions)
	Set X_GetListDataFromServer = XService.XMLGetDocument( "x-list-loader.aspx?tm=" & XService.NewGuidString & "&OT=" & sTypeName & "&METANAME=" & sMetaname, sRestrictions ).documentElement
End Function


'===============================================================================
'@@X_CreateListLoaderRestrictions
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CreateListLoaderRestrictions>
':Назначение:
'	Функция создает строку параметров для загрузки выпадающего списка.
':Параметры:
'	sUserRestrictions - 
'       [in] URL ограничений, передаваемых POST-запросом.
'	sUrlArguments - 
'       [in] дополнительные параметры загрузчика.
'	sValueObjectIDs - 
'       [in] список идентификаторов объектов, которые должны попасть в выборку.
':Примечание:
'   Значение параметра <b><i>sUserRestrictions</b></i> - это параметр RESTR страницы
'   x-list-loader.aspx.<P/>
'   Значение параметра <b><i>sValueObjectIDs</b></i> - это параметр VALUEOBJECTID 
'   страницы x-list-loader.aspx.
':Сигнатура:
'   Function X_CreateListLoaderRestrictions (
'       sUserRestrictions [As String],
'       sUrlArguments [As String],
'       sValueObjectIDs [As String]
'   ) [As String]
Function X_CreateListLoaderRestrictions(sUserRestrictions, sUrlArguments, sValueObjectIDs)
	X_CreateListLoaderRestrictions = "WHERE=" & XService.UrlEncode( sUserRestrictions )
	If Not (IsNull(sValueObjectIDs) Or IsEmpty(sValueObjectIDs)) Then
		X_CreateListLoaderRestrictions = X_CreateListLoaderRestrictions & "&VALUEOBJECTID=" & XService.UrlEncode(sValueObjectIDs)
	End If
	If Not (IsNull(sUrlArguments) Or IsEmpty(sUrlArguments)) Then
		If 0<Len(sUrlArguments) Then
			If "&"=MID(sUrlArguments,1,1) Then
				X_CreateListLoaderRestrictions = X_CreateListLoaderRestrictions & sUrlArguments
			Else
				X_CreateListLoaderRestrictions = X_CreateListLoaderRestrictions & "&" & sUrlArguments
			End If
		End If
	End If
End Function

'===============================================================================
' Внутренняя процедура получения частичных ограничений: из заданной строки 
' параметров ограничений исключаются все пары "параметр=значение" с заданным
' наименованием параметра. По умолчанию, если наименование параметра не задано 
' (null, пустая строка, vbEmpty), исключается параметр VALUEOBJECTID.
' Параметры:
'	sRestrictions	 - [in] строка параметров ограничения;
'	sUrlRestrictions - [in] наименование параметра, исключаемого их строки;
'						Если не задано, то по умолчанию принимается VALUEOBJECTID;
'	vRemovedParts	 - [out] массив со значениями исключенного параметра.
' Примечание:
'	Строка параметров м.б. сформирована X_CreateListLoaderRestrictions.
' Сигнатура:
'   Sub internal_getPartlyRestrictions( 
'       sRestrictions [As String],
'       sUrlRestrictions [As String],
'		vRemovedParts [As Array]
'   ) [As String]
Function internal_getPartlyRestrictions(sRestrictions, sRemovedParamName, ByRef vRemovedParts)
	Dim sResult			' Результат функции
	Dim nParamNameLen	' Длина наименования параметра
	Dim sPart			' Переменная цикла - одна пара "параметр=значение"

	If Not hasValue(sRemovedParamName) Then sRemovedParamName = "VALUEOBJECTID"
	If Right(sRemovedParamName,1) <> "=" Then sRemovedParamName = sRemovedParamName & "="
	nParamNameLen = Len(sRemovedParamName)
	vRemovedParts = "" 
	sResult = ""
	
	For Each sPart in splitString(sRestrictions,"&")
		If UCase(Left(sPart,nParamNameLen)) <> sRemovedParamName Then 
			sResult = sResult & sPart & "&"
		Else
			vRemovedParts = vRemovedParts & sPart & "&" 
		End If
	Next
	If Right(sResult,1) = "&" Then sResult = Left(sResult,Len(sResult)-1)
	If Len(vRemovedParts) > 0 Then 
		vRemovedParts = Left(vRemovedParts,Len(vRemovedParts)-1)
		vRemovedParts = splitString( Replace(vRemovedParts,sRemovedParamName,""), "&" )
	End If
	internal_getPartlyRestrictions = sResult
End Function


'===============================================================================
'@@X_FillComboBox
'<GROUP !!FUNCTIONS_x-utils><TITLE X_FillComboBox>
':Назначение:
'	Функция заполняет выпадающий список (элемент SELECT) значениями из IXMLDOMElement.
':Параметры:
'	oComboBox - 
'       [in] выпадающий список (элемент SELECT).
'	oList - 
'       [in] IXMLDOMElement со списком объектов в формате x-list-loader.aspx 
'       (узел <b>LIST</b>).
':Результат:
'	Возвращает True, если в списке записей больше, чем указано в атрибуте <b>maxrows</b> 
'   элемента <b>LIST</b>, и False в противном случае.
':Сигнатура:
'   Function X_FillComboBox (
'       oComboBox [As IHTMLElement],
'       oList [As IXMLDOMElement],
'   ) [As Boolean]
Function X_FillComboBox(oComboBox, oList)
	Dim oRow				' As XMLDOMElement - Строка списка (узел R)
	Dim nRowCount			' As Integer - колличество строк
	Dim bHasMoreRows		' As Boolean - признак наличия в БД данных больше, чем получено
	Dim vMaxRows			' As Variant - значение атрибута maxrows xml-узла LIST
	
	bHasMoreRows = False
	nRowCount = 0
	For Each oRow In oList.selectNodes( "RS/R")
		X_AddComboBoxItem oComboBox, oRow.getAttribute("id"), X_GetChildValueDef( oRow, "F[1]", "")
		nRowCount = nRowCount + 1
	Next
	vMaxRows = oList.getAttribute("maxrows")
	If Not IsNull(vMaxRows) Then
		vMaxRows = CLng(vMaxRows)
		bHasMoreRows = vMaxRows < nRowCount
	End If
	X_FillComboBox = bHasMoreRows
End Function


'===============================================================================
'@@SelectFromTreeDialogClass
'<GROUP !!CLASSES_x-utils><TITLE SelectFromTreeDialogClass>
':Назначение:	
'	Класс, используемый для передачи параметров в и из диалогового окна
'	x-select-from-tree (выбор из дерева).
'
'@@!!MEMBERTYPE_Methods_SelectFromTreeDialogClass
'<GROUP SelectFromTreeDialogClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_SelectFromTreeDialogClass
'<GROUP SelectFromTreeDialogClass><TITLE Свойства>
Class SelectFromTreeDialogClass

	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.Metaname
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE Metaname>
	':Назначение:	
	'	Имя селектора (<b>i:objects-tree-selector</b>) в метаданных. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Metaname [As String]
	Public Metaname
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.LoaderParams
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE LoaderParams>
	':Назначение:	
	'	Строка параметров для <b>i:data-source</b>. Строка из пар Param1=Value1, 
	'   разделенных символом "&".<P/>
	'   Для получении строки параметров можно использовать класс 
	'   QueryStringParamCollectionBuilderClass.
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public LoaderParams [As String]
	Public LoaderParams

	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.InitialPath
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE InitialPath>
	':Назначение:	
	'	Путь от узла, на который должен быть установлен фокус при старте, до корня.<P/>
	'   Cостоит из пар вида "тип узла"|"ID узла", разделенных символом "|".
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public InitialPath [As String]
	Public InitialPath		
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.InitialSelection
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE InitialSelection>
	':Назначение:	
	'	Список узлов, у которых устанавливается флаг после их первой загрузки, в формате 
	'   <LINK CROC.XTreeView, CROC.XTreeView /> (см. x-net-interop-schema.xml).
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public InitialSelection [As IXMLDOMElement]
	Public InitialSelection	 
							
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.UrlArguments
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE UrlArguments>
	':Назначение:	
	'	Дополнительные параметры в страницу.
	':Примечание:	
	'   Параметры, переопределяющие режимы работы страницы, заданные в метаописании 
	'   (<b>objects-tree-selector</b>). Данные параметры могут быть также заданы через 
	'   URL (UrlArguments). Однако значения, заданные через свойства, имеют больший 
	'   приоритет.<P/>
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public UrlArguments [As QueryString]
	Public UrlArguments	
	 
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.SelectionMode
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE SelectionMode>
	':Назначение:	
	'	Режим работы дерева: TSM_LEAFNODE, TSM_LEAFNODES, TSM_ANYNODE, TSM_ANYNODES. 
	'   Параметр URL: <b>selection-mode</b>.
	':Примечание:	
	'   Может быть не задан. В этом случае режим определяется самой иерархией.
	':Сигнатура:	
	'	Public SelectionMode [As Int]
	Public SelectionMode			 
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.SuitableSelectionModes
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE SuitableSelectionModes>
	':Назначение:	
	'	Массив подходящих режимов для случая, когда не задано значение свойства
	'   <LINK SelectFromTreeDialogClass.SelectionMode, SelectionMode /> и режим 
	'   иерархии определяется ее метаданными - он должен быть одим из заданных здесь. 
	':Примечание:	
	'   Может быть не задан. В этом случае режим определяется самой иерархией.
	':Сигнатура:	
	'	Public SuitableSelectionModes [As Array]
	Public SuitableSelectionModes	 

	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.SelectableTypes
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE SelectableTypes>
	':Назначение:	
	'	Типы узлов, которые можно выбрать. Параметр URL: <b>selectable-types</b>. 
	':Сигнатура:	
	'	Public SelectableTypes [As String]
	Public SelectableTypes		
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.SelectionCanBeEmpty
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE SelectionCanBeEmpty>
	':Назначение:	
	'	Признак разрешенного пустого выбора. Параметр URL: <b>selection-can-be-empty</b>. 
	'   Значения: 1 и 0.  
	':Сигнатура:	
	'	Public SelectionCanBeEmpty [As Boolean]
	Public SelectionCanBeEmpty	
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.SelectionEmptyMsg
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE SelectionEmptyMsg>
	':Назначение:	
	'	Сообщение, выдаваемое пользователю, в случае, если он не выбрал ни одного узла 
	'   и свойство <LINK SelectFromTreeDialogClass.SelectionCanBeEmpty, SelectionCanBeEmpty /> 
	'   не принимает значение True. Параметр URL: <b>selection-empty-msg</b>. 
	':Сигнатура:	
	'	Public SelectionEmptyMsg [As String]
	Public SelectionEmptyMsg	 
	
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE ReturnValue>
	':Назначение:	
	'	Нажатая кнопка. Возможные значения: True - была нажата кнопка <b>OK</b>,
	'   False - была нажата кнопка <b>Отмена</b>. 
	':Сигнатура:	
	'	Public ReturnValue [As Boolean]
	Public ReturnValue		
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.Selection
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE Selection>
	':Назначение:	
	'	Список узлов, у которых установлен флаг (для режима множественного выбора),
	'   в формате <LINK CROC.XTreeView, CROC.XTreeView /> (см. x-net-interop-schema.xml). 
	':Сигнатура:	
	'	Public Selection [As IXMLDOMElement]
	Public Selection		
							
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.Path
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE Path>
	':Назначение:	
	'	Путь от узла, на котором был фокус при нажатии на кнопку <b>OK</b> в 
	'   диалоговом окне, до корня. 
	':Сигнатура:	
	'	Public Path [As String]
	Public Path				 
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.UserData
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE UserData>
	':Назначение:	
	'	Данные, установленные пользовательским обработчиком в диалоговом окне. 
	':Сигнатура:	
	'	Public UserData [As Variant]
	Public UserData			 

	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.ExcludeNodes
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE ExcludeNodes>
	':Назначение:	
	'	Строка со списком исключаемых из иерархии узлов в формате: 
	'	последовательность пар <тип объекта> - <идентификатор объекта>, 
	'	разделенных символом вертикальной черты (|); 
	'	тип и идентификатор внутри пары также разделяются символом вертикальной черты
	':Сигнатура:	
	'	Public ExcludeNodes [As String]
	Public ExcludeNodes

	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.GetRightsCache
	'<GROUP !!MEMBERTYPE_Methods_SelectFromTreeDialogClass><TITLE GetRightsCache>
	':Назначение:	
	'	Функция возвращает уникальный глобальный экземпляр кеша прав, 
	'   ObjectRightsCacheClass.
	':Сигнатура:
	'	Public Function GetRightsCache [As ObjectRightsCacheClass]
	Public Function GetRightsCache
		Set GetRightsCache = X_RightsCache()
	End Function

	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		Set InitialSelection = Nothing
		Set UrlArguments = X_GetEmptyQueryString
	End Sub
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SelectFromTreeDialogClass><TITLE Self>
	':Назначение:	
	'	Функция возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:
	'	Public Function Self [As SelectFromTreeDialogClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@SelectFromTreeDialogClass_Show
'<GROUP !!FUNCTIONS_x-utils><TITLE SelectFromTreeDialogClass_Show>
':Назначение:
'	Функция открывает диалоговое окно выбора из дерева.
':Параметры:
'	oSelectFromTreeDialog - 
'       [in] экземпляр SelectFromTreeDialogClass.
':Результат:
' 	Возвращает True, если значение выбрано, и False - в противном случае.
':Примечание:
'	Функция вынесена из класса SelectFromTreeDialogClass для того, чтобы не 
'	увеличивать стек объектных вызовов (из-за ошибки в VBScript-runtime, 
'	приводящей к "stack overflow at line 0").
':Сигнатура:
'   Function SelectFromTreeDialogClass_Show ( 
'       oSelectFromTreeDialog [As SelectFromTreeDialogClass]
'   ) [As Boolean]
Function SelectFromTreeDialogClass_Show(oSelectFromTreeDialog)
	With oSelectFromTreeDialog
		If Not hasValue(.MetaName) Then
			Err.Raise -1, "SelectFromTreeDialogClass_Show", "Не задан обязательный параметр: sMetaName - метаимя i:objects-tree"
		End If
		If IsEmpty(.SelectionMode) Then
			.SelectionMode = .UrlArguments.GetValue("selection-mode", Empty)
		End If
		If IsEmpty(.SelectableTypes) Then
			.SelectableTypes = .UrlArguments.GetValue("selectable-types", Empty)
		End If
		If IsEmpty(.SelectionCanBeEmpty) Then
			.SelectionCanBeEmpty = .UrlArguments.GetValue("selection-can-be-empty", Empty)
			If Not IsEmpty(.SelectionCanBeEmpty) Then
				.SelectionCanBeEmpty = CBool(CStr(.SelectionCanBeEmpty)="1")
			End If
		End If
		If IsEmpty(.SelectionEmptyMsg) Then
			.SelectionEmptyMsg = .UrlArguments.GetValue("selection-empty-msg", Empty)
		End If
		Set .Selection = Nothing
		.Path = Empty
		.UserData = Empty
		.ReturnValue = (True = X_ShowModalDialog("x-select-from-tree.aspx?METANAME=" & .MetaName, oSelectFromTreeDialog))
		SelectFromTreeDialogClass_Show = .ReturnValue
	End With
End Function


'===============================================================================
'@@X_SelectFromTree
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SelectFromTree>
':Назначение:
'	Функция производит отбор из дерева (x-selectfromtree.htm) с помощью 
'   экземпляра класса SelectFromTreeDialogClass.
':Параметры:
'	sMetaName - 
'       [in] имя селектора в метаданных.
'	sInitPath - 
'       [in] путь к узлу, на который должен быть установлен фокус при инициализации 
'       интерфейса выбора из иерархии (путь указывается от узла к корню, состоит из 
'       пар вида "<тип узла>;<id узла>", разделенных точкой с запятой).
'	sParams - 
'       [in] строка параметров для источника данных, состоящая из пар "Param1=Value1", 
'       разделенных символом "&" (для получении строки параметров можно использовать 
'       класс QueryStringParamCollectionBuilderClass).
'	sAddUrl - 
'       [in] дополнительные параметры, передаваемые в URL загрузчику дерева и 
'       страницы x-tree.aspx.
'	oSelected - 
'       [in] cписок узлов, у которых устанавливается check после их первой загрузки в
'       виде XML.
':Результат:
' 	Возвращает экземпляр класса SelectFromTreeDialogClass. 
':Сигнатура:
'   Function X_SelectFromTree(
'       byval sMetaName [As String], 
'       sInitPath [As String], 
'       sParams [As String], 
'       sAddUrl [As String], 
'       oSelected [As IXMLDOMElement] 
'   ) [As SelectFromTreeDialogClass]
Function X_SelectFromTree(byval sMetaName, sInitPath, sParams, sAddUrl, oSelected)
	With New SelectFromTreeDialogClass
		.Metaname = sMetaName
		.InitialPath = sInitPath
		.LoaderParams = sParams
		Set .InitialSelection = ToObject(oSelected)
		If Len("" & sAddUrl) > 0 Then
			.UrlArguments.QueryString = sAddUrl
		End If
		SelectFromTreeDialogClass_Show .Self
		Set X_SelectFromTree = .Self
	End With
End Function


'===============================================================================
'@@ListSelectEventArgsClass
'<GROUP !!CLASSES_x-utils><TITLE ListSelectEventArgsClass>
':Назначение:	
'	Параметры события OK (нажатие <b>OK</b> в режиме выбора) в списка выбора
'	(x-list-page.vbs/x-list-xml.vbs).
'
'@@!!MEMBERTYPE_Methods_ListSelectEventArgsClass
'<GROUP ListSelectEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_ListSelectEventArgsClass
'<GROUP ListSelectEventArgsClass><TITLE Свойства>
Class ListSelectEventArgsClass

	'------------------------------------------------------------------------------
	'@@ListSelectEventArgsClass.Selection
	'<GROUP !!MEMBERTYPE_Properties_ListSelectEventArgsClass><TITLE Selection>
	':Назначение:	
	'	Выбранные строки. В режиме LM_SINGLE - идентификатор выбранной строки, 
	'   в режимах LM_MULTI/LM_MULTI_OR_NONE - массив из идентификаторов.
	':Сигнатура:
	'	Public Selection [As Variant]
	Public Selection			

	'------------------------------------------------------------------------------
	'@@ListSelectEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_ListSelectEventArgsClass><TITLE Cancel>
	':Назначение:	
	'	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:
	'	Public Cancel [As Boolean]
	Public Cancel				

	'------------------------------------------------------------------------------
	'@@ListSelectEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_ListSelectEventArgsClass><TITLE Self>
	':Назначение:	
	'	Функция возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:
	'	Public Function Self [As ListSelectEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@X_SelectFromList
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SelectFromList>
':Назначение:
'	Функция производит отбор из списка (x-list.aspx).
':Параметры:
'	sMetaName - 
'       [in] имя списка в метаданных.
'	sOT - 
'       [in] наименование типа, в метаданных которого располагается описание списка 
'       (<b>i:objects-list</b>).
'	nMode - 
'       [in] режим отбора (LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE).
'   sParams - 
'       [in] строка параметров для источника данных, состоящая из пар "Param1=Value1", 
'       разделенных символом "&" (для получении строки параметров можно использовать 
'       класс QueryStringParamCollectionBuilderClass).
'	sAddUrl - 
'       [in] дополнительные параметры, передаваемые в URL загрузчику списка 
'       (использование  параметров описано в файле x-list.aspx, x-list-page.vbs).
':Результат:
' 	Возвращает:
'   - Empty при нажатии кнопки <b>Отмена</b> или при пустом выборе при вызове в режиме LM_MULTIPLE_OR_NONE;
'   - список идентификаторов выбранных объектов, разделенных ";" при вызове в режиме LM_MULTIPLE;
'   - идентификатор выбранного объекта при вызове в режиме LM_SINGLE.
':Сигнатура:
'   Function X_SelectFromList(
'       sMetaName [As String], 
'       sOT [As String], 
'       nMode [As Int], 
'       sParams [As String], 
'       sAddUrl [As String] 
'   ) [As Variant]
Function X_SelectFromList( sMetaName, sOT, nMode, sParams, sAddUrl)
	Dim sURL						' URL вызова селектора
	If nMode <> LM_SINGLE And nMode <> LM_MULTIPLE And nMode <> LM_MULTIPLE_OR_NONE Then
		Err.Raise -1, "X_SelectFromList", "Недопустимый режим списка"
	End If
	'Получим URL диалога	
	sURL =  "OT=" & sOT & "&MODE=" & nMode
	If Len("" & sMetaName) > 0 Then  sURL = sURL & "&METANAME=" & sMetaName 
	If Len("" & sParams) > 0 Then  sURL = sURL & "&RESTR=" & XService.UrlEncode(sParams)
	If Len("" & sAddUrl) > 0 Then
		If Left(sAddUrl,1) <> "&" Then sURL = sURL & "&"
		sURL = sURL & sAddUrl
	End If
	With X_GetEmptyQueryString
		.QueryString = sUrl
		'Покажем диалог
		X_SelectFromList = X_ShowModalDialog("x-list.aspx?OT=" & sOT & "&METANAME=" & sMetaname & "&MODE=" & nMode, .Self())
	End With	
End Function

	
'===============================================================================
'@@X_SelectFromXmlList
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SelectFromXmlList>
':Назначение:
'	Функция производит отбор из списка (x-select-from-xml.aspx) из переданных объектов.
':Параметры:
'	oObjectEditor - 
'       [in] экземпляр ObjectEditorClass.
'	sMetaName - 
'       [in] имя списка в метаданных.
'	sOT - 
'       [in] наименование типа, в метаданных которого располагается описание списка 
'       (<b>i:objects-list</b>).
'	nMode - 
'       [in] режим отбора (LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE).
'   oObjects - 
'       [in] коллекция XML-объектов для выбора (должна поддерживать For Each: Array, 
'       IXMLDOMNodeList).
'	sAddUrl - 
'       [in] дополнительные параметры, передаваемые в URL загрузчику списка.
':Результат:
' 	Возвращает:
'   - Empty при нажатии кнопки <b>Отмена</b> или при пустом выборе при вызове в режиме LM_MULTIPLE_OR_NONE;
'   - список идентификаторов выбранных объектов, разделенных ";" при вызове в режиме LM_MULTIPLE;
'   - идентификатор выбранного объекта при вызове в режиме LM_SINGLE.
':Сигнатура:
'   Function X_SelectFromXmlList(
'       oObjectEditor [As ObjectEditorClass],
'       sMetaName [As String], 
'       sOT [As String], 
'       nMode [As Int], 
'       oObjects [As ICollection], 
'       sAddUrl [As String] 
'   ) [As Variant]
Function X_SelectFromXmlList(oObjectEditor, sMetaName, sOT, nMode, oObjects, sAddUrl)
	Dim sURL						' URL вызова селектора
	If nMode <> LM_SINGLE And nMode <> LM_MULTIPLE And nMode <> LM_MULTIPLE_OR_NONE Then
		Err.Raise -1, "X_SelectFromXmlList", "Недопустимый режим списка"
	End If
	'Получим URL диалога	
	sURL =  "OT=" & sOT & "&MODE=" & nMode
	If Len("" & sMetaName) > 0 Then  sURL = sURL & "&METANAME=" & sMetaName 
	If Len("" & sAddUrl) > 0 Then
		If Left(sAddUrl,1) <> "&" Then sURL = sURL & "&"
		sURL = sURL & sAddUrl
	End If
	Dim oSelectFromXmlListDialogParams
	Set oSelectFromXmlListDialogParams = New SelectFromXmlListDialogParamsClass
	Set oSelectFromXmlListDialogParams.ObjectEditor = oObjectEditor
	If IsObject(oObjects) Then
		Set oSelectFromXmlListDialogParams.Objects = oObjects
	Else
		oSelectFromXmlListDialogParams.Objects = oObjects
	End If
	X_SelectFromXmlList = X_ShowModalDialog("x-select-from-xml.aspx?" & sURL, oSelectFromXmlListDialogParams)
End Function


'===============================================================================
'@@SelectFromXmlListDialogParamsClass
'<GROUP !!CLASSES_x-utils><TITLE SelectFromXmlListDialogParamsClass>
':Назначение:	
'	Класс параметров, передаваемых в диалог x-select-from-xml.aspx/x-list-xml.vbs.
'
'@@!!MEMBERTYPE_Properties_SelectFromXmlListDialogParamsClass
'<GROUP SelectFromXmlListDialogParamsClass><TITLE Свойства>
Class SelectFromXmlListDialogParamsClass

	'------------------------------------------------------------------------------
	'@@SelectFromXmlListDialogParamsClass.Objects
	'<GROUP !!MEMBERTYPE_Properties_SelectFromXmlListDialogParamsClass><TITLE Objects>
	':Назначение:	
	'	Коллекция отображаемых объектов. Единственное требование - коллекция должна 
	'   поддерживать For Each.
	':Сигнатура:
	'	Public Objects [As ICollection]
    Public Objects          
    
	'------------------------------------------------------------------------------
	'@@SelectFromXmlListDialogParamsClass.ObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_SelectFromXmlListDialogParamsClass><TITLE ObjectEditor>
	':Назначение:	
	'	Экземпляр ObjectEditorClass. Используется для вычисления выражений 
	'   (ExecuteStatement).
	':Сигнатура:
	'	Public ObjectEditor [As ObjectEditorClass]
    Public ObjectEditor     
End Class


'===============================================================================
'@@ChooseImageDialogClass
'<GROUP !!CLASSES_x-utils><TITLE ChooseImageDialogClass>
':Назначение:	
'	Класс, инкапсулирующий логику открытия и передачи параметров в диалог выбора 
'   изображения.
'
'@@!!MEMBERTYPE_Methods_ChooseImageDialogClass
'<GROUP ChooseImageDialogClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_ChooseImageDialogClass
'<GROUP ChooseImageDialogClass><TITLE Свойства>
Class ChooseImageDialogClass

	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.Caption
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE Caption>
	':Назначение:	
	'	Заголовок диалога выбора картинки.
	':Сигнатура:
	'	Public Caption [As String]
	Public Caption		
	
	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.Url
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE Url>
	':Назначение:	
	'	URL текущей картинки (пустая строка в случае отсутствия оной).
	':Сигнатура:
	'	Public Url [As String]
	Public Url			
	
	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.Filters
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE Filters>
	':Назначение:	
	'	Строка фильтров в формате 
	'   "description1|patternlist1|...descriptionN|patternlistN|", где
	'   patternlistI - есть перечисление через ";" масок файлов
	'   (если "", то - не используется).
	':Сигнатура:
	'	Public Filters [As String]
	Public Filters		
	
	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.MaxFileSize
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE MaxFileSize>
	':Назначение:	
	'	Максимальный размер файла (если 0, то - не используется).
	':Сигнатура:
	'	Public MaxFileSize [As Int]
	Public MaxFileSize
	
	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.MinHeight
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE MinHeight>
	':Назначение:	
	'	Минимальная высота изображения (если 0, то - не используется).
	':Сигнатура:
	'	Public MinHeight [As Int]
	Public MinHeight

	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.MaxHeight
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE MaxHeight>
	':Назначение:	
	'	Максимальная высота изображения (если 0, то - не используется).
	':Сигнатура:
	'	Public MaxHeight [As Int]
	Public MaxHeight
	
	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.MinWidth
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE MinWidth>
	':Назначение:	
	'	Минимальная ширина изображения (если 0, то - не используется).
	':Сигнатура:
	'	Public MinWidth [As Int]
	Public MinWidth
	
	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.MaxWidth
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE MaxWidth>
	':Назначение:	
	'	Максимальная ширина изображения (если 0, то - не используется).
	':Сигнатура:
	'	Public MaxWidth [As Int]
	Public MaxWidth

	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.OffClear
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE OffClear>
	':Назначение:	
	'	Запрещение отображения кнопки <b>Очистить</b>.
	':Сигнатура:
	'	Public OffClear [As Boolean]
	Public OffClear
	
	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		MaxFileSize	= 0
		MinHeight	= 0
		MaxHeight	= 0
		MinWidth	= 0
		MaxWidth	= 0
		OffClear	= False
	End Sub


	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.Show
	'<GROUP !!MEMBERTYPE_Methods_ChooseImageDialogClass><TITLE Show>
	':Назначение:	
	'	Функция открывает диалоговое модальное окно с редактором.
    ':Результат:
    ' 	Возвращает:
    '   - Empty - нажата кнопка <b>Отмена</b>;
    '   - Null - "пустая" картинка;
    '   - Строка - URL новой картинки.
	':Сигнатура:
	'	Public Function Show [As Variant]
	Public Function Show
		const PICTURE_DIALOG_SIZE = 60 'размер (в процентах относительно экрана) диалога выбора картинки
		Show = X_ShowModalDialogEx(XService.BaseURL &  "x-choose-image.aspx"  , Me , "dialogWidth:" & Round(window.screen.availWidth * PICTURE_DIALOG_SIZE / 100)  & "px;dialogHeight:" & Round(window.screen.availHeight * PICTURE_DIALOG_SIZE / 100) & "px;help:no;center:yes;status:no;resizable:yes") 
	End Function
End Class


'===============================================================================
'@@X_SelectImage
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SelectImage>
':Назначение:
'	Функция вызова диалога выбора картинки.
':Параметры:
'	sCaption - 
'       [in] заголовок диалога выбора картинки.
'	sCurrentPictureURL - 
'       [in] URL текущей картинки (пустая строка в случае отсутствия оной).
'	sFilrers - 
'       [in] строка фильтров в формате 
'       "description1|patternlist1|...descriptionN|patternlistN|", где 
'       "patternlistI" - есть перечисление через ";" масок файлов
'       (если "", то - не используется).
'	nMaxFileSize - 
'       [in] максимальный размер файла (если 0, то - не используется).
'   nMinHeight - 
'       [in] минимальная высота изображения (если 0, то - не используется).
'	nMaxHeight - 
'       [in] максимальная высота изображения (если 0, то - не используется).
'   nMinWidth - 
'       [in] минимальная ширина изображения (если 0, то - не используется).
'	nMaxWidth - 
'       [in] максимальная ширина изображения (если 0, то - не используется).
':Результат:
' 	Возвращает:
'   - Empty - нажата кнопка <b>Отмена</b>;
'   - Null - "пустая" картинка;
'   - Строка - URL новой картинки.
':Сигнатура:
'   Function X_SelectImage( 
'       sCaption [As String],
'       sCurrentPictureURL [As String], 
'       sFilrers [As String], 
'       nMaxFileSize [As Int], 
'       nMinHeight [As Int], 
'       nMaxHeight [As Int], 
'       nMinWidth [As Int], 
'       nMaxWidth [As Int] 
'   ) [As Variant]
Function X_SelectImage(sCaption,sCurrentPictureURL, sFilrers, nMaxFileSize, nMinHeight, nMaxHeight, nMinWidth, nMaxWidth  )
	Dim o						' Объект ChooseImageDialogClass
	Set o = new ChooseImageDialogClass
	o.Caption = "" & sCaption
	o.Url = "" & sCurrentPictureURL
	o.Filters = "" & sFilrers
	o.MaxFileSize = nMaxFileSize
	o.MaxHeight = nMaxHeight
	o.MaxWidth = nMaxWidth
	o.MinHeight = nMinHeight
	o.MinWidth = nMinWidth
	X_SelectImage = o.Show()
End Function


'===============================================================================
'@@X_CheckObjectRights
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CheckObjectRights>
':Назначение:
'	Функция проверяет наличие определенного динамического права на экземпляр объекта.
':Параметры:
'	sType - 
'       [in] имя типа объекта.
'   sObjectID - 
'       [in] идентификатор объекта.
'	sAction - 
'       [in] действие над объектом (константа ACCESS_RIGHT_nnnn).
':Результат:
' 	True - заданое действие над объектом разрешено, False - в противном случае.
':Сигнатура:
'   Function X_CheckObjectRights( 
'       sType [As String],
'       sObjectID [As String], 
'       sAction [As String] 
'   ) [As Boolean]
Function X_CheckObjectRights( sType, sObjectID, sAction)
	Dim oObjectPermission
	
	Set oObjectPermission = New XObjectPermission
	oObjectPermission.m_sAction = sAction
	oObjectPermission.m_sTypeName = sType
	oObjectPermission.m_sObjectID = sObjectID
	X_CheckObjectRights = X_CheckObjectsRights( Array(oObjectPermission))(0)
End Function


'===============================================================================
'@@X_CheckObjectsRights
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CheckObjectsRights>
':Назначение:
'	Функция проверяет наличие определенного динамического права на множество объектов.
':Параметры:
'	aObjectPermission - 
'       [in] массив объектов для запроса прав.
':Результат:
' 	Массив True/False размерностью такой же, как <b><i>aObjectPermission</b></i>: 
'   True - заданое действие над объектом, описанное в соответствующем элементе массива 
'   <b><i>aObjectPermission</b></i>, разрешено, False - в противном случае.
':Сигнатура:
'   Function X_CheckObjectsRights( 
'       aObjectPermission [As XObjectPermission] 
'   ) [As Boolean]
Function X_CheckObjectsRights(aObjectPermission)
	Dim aResult			' As Boolean() - возвращаемый результат 
	Dim aServerResult	' As Boolean()
	Dim oList			' As ObjectArrayListClass
	Dim bPermited		' As Boolean
	Dim i,j
	Dim aErr

	X_CheckObjectsRights = Array()
	If Not IsArray(aObjectPermission) Then Exit Function
	If UBound(aObjectPermission)<0 Then Exit Function
	Set oList = New ObjectArrayListClass
	oList.AddRange aObjectPermission
	ReDim aResult(Ubound(aObjectPermission))
	For i=UBound(aResult) To 0 Step -1
		If X_RightsCache().Find(aObjectPermission(i), bPermited) Then
			aResult(i) = bPermited
			oList.RemoveAt i
		End If	
	Next
	if oList.Count>0 Then
		On Error Resume Next
		With New XGetObjectsRightsRequest
			.m_sName = "GetObjectsRights"
			.m_aPermissions = oList.GetArray
			aServerResult = X_ExecuteCommand( .Self ).m_aObjectPermissionCheckList
		End With
		If Err Then
			If Not X_HandleError Then
				' ошибка на клиенте
				aErr = Array(Err.Number, Err.Source, Err.Description)
				On Error Goto 0
				Err.Raise aErr(0), aErr(1), aErr(2)				
			End If
			On Error GoTo 0
			For i=0 To UBound(aResult)
				If IsEmpty(aResult(i)) Then
					aResult(i) = False
				End If
			Next
		Else
			On Error GoTo 0
			j=0
			For i=0 To UBound(aResult)
				If IsEmpty(aResult(i)) Then
					aResult(i) = aServerResult(j)
					X_RightsCache().SetValue aObjectPermission(i), aResult(i)
					j=j+1
				End If
			Next
		End If
	End If
	X_CheckObjectsRights = aResult
End Function


'===============================================================================
'@@X_CheckTypeRights
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CheckTypeRights>
':Назначение:
'	Функция проверяет наличие определенного статического права на указанный тип(ы).
':Параметры:
'	sType - 
'       [in] имена типов объектов через ";".
'	sAction - 
'       [in] действие над объектом (константа ACCESS_RIGHT_nnnn).
':Результат:
' 	True - заданое действие над объектом разрешено, False - в противном случае.
':Сигнатура:
'   Function X_CheckTypeRights( 
'       sType [As String],
'       sAction [As String] 
'   ) [As Boolean]
Function X_CheckTypeRights( sType, sAction)
	X_CheckTypeRights = X_CheckObjectRights(sType, Empty, sAction)
End Function


'==============================================================================
'@@ObjectRightsCacheClass
'<GROUP !!CLASSES_x-utils><TITLE ObjectRightsCacheClass>
':Назначение:	
'   Кеш проверенных прав на объекты.
'   Класс поддерживает два варианта использования:
'	- кэширование и поиск разрешений на операции над объектами, описываемыми экземплярами XObjectPermission; 
'	- расширенный механизм кэширования. Реализуется  
'   Первый вариант реализуется методами 
'   <LINK ObjectRightsCacheClass.SetValue, SetValue />
'   и <LINK ObjectRightsCacheClass.Find, Find />. Первым параметром они принимают 
'   экземпляр XObjectPermission, описывающий операцию над объектом. 
'   Кэшируемое значение - логический признак разрешения операции.  
'   Второй вариант реализуется методами 
'   <LINK ObjectRightsCacheClass.SetValueEx, SetValueEx /> и 
'   <LINK ObjectRightsCacheClass.FindEx, FindEx />. В данном варианте ключ в кэше 
'   задается непосредственно прикладным кодом (в предыдущем варианте он вычисляется из 
'   экземпляра XObjectPermission). В качестве кэшируемого значения может использоваться 
'   любой объект (т.е. vbObject). Вариант предназначен для реализаций в прикладном коде 
'   расширенных механизмов проверки прав и XFW .NET не используется. Второй вариант 
'   реализован в данном классе (а не отдельно) из-за того, что экземпляр 
'   ObjectRightsCacheClass автоматически передается XFW .NET между всеми диалоговыми 
'   окнами редакторов.  
':Примечание: 
'	Поиск по ключам всегда регистрозависимый.
'@@!!MEMBERTYPE_Methods_ObjectRightsCacheClass
'<GROUP ObjectRightsCacheClass><TITLE Методы>
Class ObjectRightsCacheClass
	Private m_oCache		' As Scripting.Dictionary

	'==========================================================================	
	Private Sub Class_Initialize
		Set m_oCache = CreateObject("Scripting.Dictionary")
		m_oCache.CompareMode = vbBinaryCompare
	End Sub
	
	'==========================================================================
	' Создает ключ для кэширования из объекта XObjectPermission
	'	[in] oObjectPermission As XObjectPermission - запрос на операцию над объектом
	'	[out] As String - ключ
	Private Function getKey(oObjectPermission)
		getKey = oObjectPermission.m_sTypeName & "?" & oObjectPermission.m_sObjectID & "?" & oObjectPermission.m_sAction
	End Function
	
	'==========================================================================	
	'@@ObjectRightsCacheClass.Find
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE Find>
	':Назначение:	
	'	Функция проверяет наличие в кэше разрешений на заданные операции над объектом 
	'   (установленные методом <LINK ObjectRightsCacheClass.SetValue, SetValue />).
	':Параметры: 
    '	oObjectPermission - 
    '       [in] запрос на операцию над объектом.
	'	bPermited - 
	'       [out] результат проверки прав.
	':Результат:
	'	True - закешированное значение найдено, False - в противном случае.
	':Сигнатура:	
	'	Public Function Find( 
	'       oObjectPermission [As XObjectPermission], 
	'       ByRef bPermited [As Boolean] 
	'   ) [As Boolean]	
	Public Function Find(oObjectPermission, ByRef bPermited)
		Dim vTemp
		Find = False
		vTemp = m_oCache.Item(getKey(oObjectPermission))
		If Not IsEmpty(vTemp) Then
			bPermited = vTemp
			Find = True
		End If
	End Function


	'==========================================================================
	'@@ObjectRightsCacheClass.SetValue
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE SetValue>
	':Назначение:	
	'	Процедура кэширует разрешение для операции над объектом. 
	'	Если значение уже существует, оно перезаписывается. Получается значение методом 
	'   <LINK ObjectRightsCacheClass.Find, Find />.
	':Параметры: 
    '	oObjectPermission - 
    '       [in] запрос на операцию над объектом.
	'	bPermited - 
	'       [in] кэшируемое значение (возвращается методом 
	'       <LINK ObjectRightsCacheClass.Find, Find />).
	':Сигнатура:	
	'	Public Sub SetValue( 
	'       oObjectPermission [As XObjectPermission], 
	'       bPermited [As Boolean] 
	'   ) 	
	Public Sub SetValue(oObjectPermission, bPermited)
		m_oCache.Item(oObjectPermission.m_sTypeName & "?" & oObjectPermission.m_sObjectID & "?" & oObjectPermission.m_sAction) = bPermited
	End Sub


	'==========================================================================	
	'@@ObjectRightsCacheClass.FindEx
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE FindEx>
	':Назначение:	
	'	Функция получает закэшированный объект по ключу.
	':Параметры: 
    '	sKey - 
    '       [in] ключ для поиска значения в кэше.
	'	oObjectRightsDescr - 
	'       [out] закэшированное значение.
	':Результат:
	'	True - закешированное значение найдено, False - в противном случае.
	':Сигнатура:	
	'	Public Function FindEx( 
	'       sKey [As String], 
	'       ByRef oObjectRightsDescr [As Object] 
	'   ) [As Object]	
	Public Function FindEx(sKey, ByRef oObjectRightsDescr)
		FindEx = False
		If m_oCache.Exists(sKey) Then
			Set oObjectRightsDescr = m_oCache.Item(sKey)
			FindEx = True
		End If
	End Function
	
	
	'==========================================================================	
	'@@ObjectRightsCacheClass.SetValueEx
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE SetValueEx>
	':Назначение:	
	'	Процедура кэширует некоторый объект под заданным ключем.
	':Параметры: 
    '	sKey - 
    '       [in] ключ для поиска значения в кэше.
	'	oObjectRightsDescr - 
	'       [in] закэшированное значение.
	':Сигнатура:	
	'	Public Sub SetValueEx( 
	'       sKey [As String], 
	'       oObjectRightsDescr [As Object] 
	'   ) 	
	Public Sub SetValueEx(sKey, oObjectRightsDescr)
		Set m_oCache.Item(sKey) = oObjectRightsDescr
	End Sub
	
	
	'==========================================================================	
	'@@ObjectRightsCacheClass.Contains
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE Contains>
	':Назначение:	
	'	Функция возвращает признак наличия закэшированного значения для заданого ключа.
	':Параметры: 
    '	sKey - 
    '       [in] ключ для поиска значения в кэше.
	':Результат:
	'	True - закешированное значение найдено, False - в противном случае.	
	':Сигнатура:	
	'	Public Function Contains(sKey [As String]) [As Boolean]	
	Public Function Contains(sKey)
		Contains = m_oCache.Exists(sKey)
	End Function

	
	'==========================================================================	
	'@@ObjectRightsCacheClass.RemoveByKey
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE RemoveByKey>
	':Назначение:	
	'	Функция удаляет закэшированное значение по ключу.
	':Параметры: 
    '	sKey - 
    '       [in] ключ для поиска значения в кэше.
	':Результат:
	'	True - значение с заданным ключем удалено, False - значения с заданным 
	'   ключем в кэше нет.
	':Сигнатура:	
	'	Public Function RemoveByKey( 
	'       sKey [As String] 
	'   ) [As Boolean]	
	Public Function RemoveByKey(sKey)
		RemoveByKey = False
		If m_oCache.Exists(sKey) Then
			m_oCache.Remove(sKey)
			RemoveByKey = True
		End If
	End Function

	
	'==========================================================================	
	'@@ObjectRightsCacheClass.Remove
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE Remove>
	':Назначение:	
	'	Функция удаляет закэшированное разрешение для заданной операции над объектом.
	':Параметры: 
    '	oObjectPermission - 
    '       [in] запрос на операцию над объектом.
	':Результат:
	'	True - значение для заданной операции над объектом удалено, False - значения 
	'   для заданной операции в кэше нет.
	':Сигнатура:	
	'	Public Function Remove( 
	'       oObjectPermission [As XObjectPermission] 
	'   ) [As Boolean]	
	Public Function Remove(oObjectPermission)
		Remove = RemoveByKey(getKey(oObjectPermission))
	End Function


	'==========================================================================	
	'@@ObjectRightsCacheClass.RemoveByObject
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE RemoveByObject>
	':Назначение:	
	'	Функция удаляет закэшированные значения резрешений на все операции для 
	'   заданного объекта.
	':Параметры: 
    '	sObjectType - 
    '       [in] наименование типа объекта.
    '	sObjectID - 
    '       [in] идентификатор объекта.
	':Результат:
	'	True - значение для заданного объекта удалено, False - значения для заданного 
	'   объекта в кэше нет.
	':Сигнатура:	
	'	Public Function RemoveByObject( 
	'       sObjectType [As String], 
	'       sObjectID [As String] 
	'   ) [As Boolean]	
	Public Function RemoveByObject(sObjectType, sObjectID)
		RemoveByObject = RemoveByKeyPattern(sObjectType & "?" & sObjectID & "?")
	End Function

	
	'==========================================================================	
	'@@ObjectRightsCacheClass.RemoveByType
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE RemoveByType>
	':Назначение:	
	'	Функция удаляет закэшированные значения резрешений на все операции всех 
	'   объектов заданного типа.
	':Параметры: 
    '	sObjectType - 
    '       [in] наименование типа объекта.
	':Результат:
	'	True - значение для заданного типа удалено, False - значения для заданного 
	'   типа в кэше нет.
	':Сигнатура:	
	'	Public Function RemoveByObject( 
	'       sObjectType [As String] 
	'   ) [As Boolean]	
	Public Function RemoveByType(sObjectType)
		RemoveByType = RemoveByKeyPattern(sObjectType & "?")
	End Function


	'==========================================================================	
	'@@ObjectRightsCacheClass.RemoveByKeyPattern
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE RemoveByKeyPattern>
	':Назначение:	
	'	Функция удаляет закэшированные значения по начальному значению ключа,
	'	т.е. все значения, ключи которых начинаются с переданной строки.
	':Параметры: 
    '	sKeyPattern - 
    '       [in] начало строки ключа.
	':Результат:
	'	Количество найденных и удаленных значений. 0 - значения с заданным ключем в 
	'   кэше нет.
	':Сигнатура:	
	'	Public Function RemoveByKeyPattern( 
	'       sKeyPattern [As String] 
	'   ) [As Int]	
	Public Function RemoveByKeyPattern(sKeyPattern)
		Dim i
		Dim sKey		' Ключ в кэше
		Dim nFound		' Колличество найденных и удаленных значений
		Dim nLastIndex	' Индекс последнего ключа в массиве ключей
			
		nFound = 0
		nLastIndex = m_oCache.Count-1
		Do
			If i > nLastIndex Then Exit Do
			sKey = m_oCache.Keys()(i)
			If Mid(sKey, 1, Len(sKeyPattern)) = sKeyPattern Then
				m_oCache.Remove(sKey)
				nLastIndex = nLastIndex - 1
				nFound = nFound + 1
			Else
				i = i + 1
			End If
		Loop
		RemoveByKeyPattern = nFound
	End Function
End Class


'===============================================================================
'@@X_RightsCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_RightsCache>
':Назначение:
'	Функция, через которую должен всегда происходить доступ к глобальному кэшу 
'	прав (переменная <b><i>x_oRightsCache</b></i>).
':Примечание:
'	<b>Внимание!</b> Использовать переменную <b><i>x_oRightsCache</b></i> напрямую 
'   запрещается!
':Результат:
' 	Экземпляр ObjectRightsCacheClass, представляющий данные глобального кэша прав.
':Сигнатура:
'   Public Function X_RightsCache() [As ObjectRightsCacheClass]
Public Function X_RightsCache()
	If Not hasValue(x_oRightsCache) Then
		Set x_oRightsCache = New ObjectRightsCacheClass
	End If
	Set X_RightsCache = x_oRightsCache
End Function


'===============================================================================
'@@QueryStringClass
'<GROUP !!CLASSES_x-utils><TITLE QueryStringClass>
':Назначение:	
'	Класс - контейнер параметров URL-запросов; реализует логику разбора строки
'	параметров. Используется для передачи параметров через dialogArguments (см.
'	X_GetQueryString).
':Примечание: 
'	Важно: наименование класса используется при проверке типа параметра!
'
'@@!!MEMBERTYPE_Methods_QueryStringClass
'<GROUP QueryStringClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_QueryStringClass
'<GROUP QueryStringClass><TITLE Свойства>
Class QueryStringClass

	Private m_oParams	' Коллекция параметров (Scripting.Dictionary)

	'---------------------------------------------------------------------------
	' Конструктор
	Private Sub Class_Initialize()
		Set m_oParams = CreateObject("Scripting.Dictionary")
		m_oParams.CompareMode = vbTextCompare
	End Sub
	
	'---------------------------------------------------------------------------
	' Деструктор
	Private Sub Class_Terminate()
		Set m_oParams = Nothing
	End Sub

	'---------------------------------------------------------------------------
	'@@QueryStringClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_QueryStringClass><TITLE QueryString>
	':Назначение:	Возвращает строку запроса, сформированную на основе текущего
	'				состояния коллекции параметров. Если коллекция параметров 
	'				пустая, возвращает пустую строку.
	':Примечание:	Свойство доступно как для чтения, так и для записи. При 
	'				изменении значения свойства выполняется переформатирование
	'				коллекции параметров.
	':Сигнатура:	
	'	Public Property Get QueryString [As String]
	'	Public Property Let QueryString( sQueryString [As String] )
	Public Property Get QueryString
		Dim sResult ' результат выполнения функции
		Dim sKey	' ключ
		Dim sValue	' значение
		
		sResult = Empty
		For Each sKey In m_oParams.Keys
			For Each sValue in m_oParams.Item(sKey)
				If Not IsObject(sValue) Then
					If IsEmpty(sResult) Then
						sResult =  XService.URLEncode( sKey ) & "=" & XService.URLEncode( "" & sValue)
					Else
						sResult =  sResult & "&" &  XService.URLEncode( sKey ) & "=" & XService.URLEncode( "" & sValue )
					End If
				End If
			Next
		Next	
		QueryString = CStr(sResult)
	End Property
	
	Public Property Let QueryString( sQueryString )
		Dim aParams		'	массив пар вида name=value
		Dim sName		'	имя параметра
		Dim sValue		'	значение параметра
		Dim nOffset		'	позиция символа =
		Dim i
		With m_oParams
			.RemoveAll
			aParams = Split( vbNullString & sQueryString, "&" )
			For i=0 To UBound(aParams)
				nOffset = InStr(1,aParams(i),"=")
				If nOffset=0 Then
					sName  = aParams(i)
					sValue = ""
				Else
					sName	= MID(aParams(i),1,nOffset-1)
					sValue	= MID(aParams(i),nOffset+1)
				End If
				If 0<>Len(sName) Then
					AddValue XService.URLDecode( sName )  , XService.URLDecode( sValue )
				End If
			Next
		End With
	End Property

	'---------------------------------------------------------------------------
	'@@QueryStringClass.SerializeToXml
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE SerializeToXml>
	':Назначение:	Формирует XML-представление данных, представленных 
	'				в коллекции параметров ("сериализация" коллекции).
	':Результат:
	'	XML-представление данных, как IXMLDOMElement.
	':Примечание:
	'	В результате выполнения процедуры будет сформирован XML с корневым
	'	элементом <B>params</B> и набором подчиненных ему элементов <B>param</B>,
	'	представляющих данные каждого параметра, представленного в коллекции.
	'	Наименование параметра передается как значение атрибута <B>n</B> элемента 
	'	<B>param</B>, значение - как содержание элемента <B>param</B>.
	':Сигнатура:
	'	Public Function SerializeToXml() [As IXMLDOMElement]
	Public Function SerializeToXml()
		Dim sKey		' ключ
		Dim sValue		' значение
		Dim oXmlRoot	' возвращаемый корневой узел params
		
		Set oXmlRoot = XService.XmlGetDocument.createElement("params")
		For Each sKey In m_oParams.Keys
			For Each sValue in m_oParams.Item(sKey)
				If Not IsObject(sValue) Then
					With oXmlRoot.AppendChild(oXmlRoot.OwnerDocument.CreateElement("param"))
						.SetAttribute "n", sKey
						.text = sValue
					End With
				End If
			Next
		Next
		Set SerializeToXml = oXmlRoot
	End Function
	
	'---------------------------------------------------------------------------
	'@@QueryStringClass.Names
	'<GROUP !!MEMBERTYPE_Properties_QueryStringClass><TITLE Names>
	':Назначение:	Возвращает массив имен параметров, представленных в коллекции.
	':См. также:	QueryStringClass.GetValues
	':Сигнатура:	Public Property Get Names() [As Array]
	Public Property Get Names()
		Names = m_oParams.Keys()
	End Property
	
	'---------------------------------------------------------------------------
	'@@QueryStringClass.GetValues
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE GetValues>
	':Назначение:	
	'	Возвращает массив значений указанного параметра запроса.
	':Параметры: 
	'	sName - [in] наименование параметра.
	':Результат:
	'	Значение указанного парамета. Если параметр с заданным наименованием
	'	в коллекции не представлен, метод возвращает Null.
	':См. также:	
	'	QueryStringClass.Names, QueryStringClass.GetValueEx
	':Сигнатура:	
	'	Public Function GetValues( ByVal sName [As String] ) [As Variant]
	Public Function GetValues(byval sName)
		With m_oParams
			If .Exists(sName) Then
				GetValues = .Item(sName)
				' Для пустого массива тоже вернём Null
				If UBound(GetValues)=-1 Then
					GetValues = Null
				End If 
			Else
				GetValues = Null
			End if
		End With
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.GetValueEx
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE GetValueEx>
	':Назначение:	
	'	Возвращает значение указанного параметра запроса (в том числе и массивы).
	':Параметры: 
	'	sName - 
	'       [in] наименование параметра.
	'	vValue - 
    '       [in,out] значение запрошенного параметра; если параметр с 
	'			указанным наименованием не найден, значение <b><i>vValue</b></i> 
	'			остается неизменным (т.о. исходное значение, задаваемое для параметра,
	'			есть "значение по умолчанию").
	':Результат:
	'	Логиический признак наличия указанного параметра в коллекции: True - 
	'	параметр в коллекции присутствует; False - параметра с указанным 
	'	наименованием в коллекции нет.
	':См. также:	
	'	QueryStringClass.Names, QueryStringClass.GetValue
	':Сигнатура:	
	'	Public Function GetValueEx( 
	'		sName [As String], ByRef vValue [As Variant]
	'	) [As Variant]
	Public Function GetValueEx(sName, ByRef vValue)
		Dim aValues	' Массив значений параметра
		Dim nIndex	' Индекс элемента в aValues
		aValues = GetValues(sName)
		If IsNull(aValues) Then
			GetValueEx = False
		Else
			GetValueEx = True
			nIndex = UBound(aValues)
			If IsObject(aValues(nIndex)) Then
				Set vValue = aValues(nIndex)
			Else
				vValue = aValues(nIndex)
			End If		
		End If
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.GetValue
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE GetValue>
	':Назначение:	Возвращает значение указанного параметра запроса.
	':Параметры: 	
	'   sName - 
	'       [in] наименование параметра.
	'	vDefault - 
	'       [in] значение по умолчанию.
	':Результат:
	'	Значение указанного параметра. Если параметр с указанным наименованием в 
	'	коллекции не представлен, метод возвращает значение по умолчанию.
	':См. также:	
	'	QueryStringClass.Names
	':Сигнатура:	
	'	Public Function GetValue( 
	'		sName [As String], ByVal vDefault [As Variant] 
	'	) [As Variant]
	Public Function GetValue( sName, ByVal vDefault)
		GetValueEx sName, vDefault
		If IsObject(vDefault) Then
			Set GetValue = vDefault
		Else
			GetValue = vDefault
		End If		
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.GetValueInt
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE GetValueInt>
	':Назначение:	Возвращает значение указанного параметра запроса,
	'				приведенное к целочисленному значению.
	':Параметры: 	sName - [in] наименование параметра.
	'				nDefault - [in] значение по умолчанию.
	':Результат:
	'	Значение указанного параметра. Если параметр с указанным наименованием в 
	'	коллекции не представлен, метод возвращает значение по умолчанию.
	':См. также:	
	'	QueryStringClass.Names
	':Сигнатура:	
	'	Public Function GetValueInt( 
	'		sName [As String], ByVal nDefault [As Int] 
	'	) [As Int]
	Public Function GetValueInt( sName, ByVal nDefault)
		Dim nResult	' Возвращаемое значение
		nResult = nDefault
		If GetValueEx( sName, nResult) Then
			If IsObject(nResult) Then
				nResult = nDefault
			ElseIf IsArray(nResult) Then
				nResult = nDefault
			End If
			On Error Resume Next
			nResult  = CLng(nResult)
			if Err Then
				nResult = nDefault
			End if
			On Error GoTo 0
		End If	
		On Error Resume Next
		nResult  = CLng(nResult)
		If Err Then
			nResult = 0
		End if
		On Error GoTo 0
		GetValueInt = nResult
	End Function
	

	'---------------------------------------------------------------------------
	'@@QueryStringClass.SetValues
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE SetValues>
	':Назначение:	
	'   Для указанного параметра коллекции устанавливает заданое значение (в том числе 
	'   и массивы значений).
	':Параметры: 	sName - [in] наименование параметра.
	'				aValues - [in] устанавливаемое значение.
	':Примечание:
	'	Если параметр с указанным именем не найден, то метод добавляет его в коллекцию.
	':Сигнатура:	
	'	Public Sub SetValues(
	'       ByVal sName [As String],
	'       ByVal aValues [As Variant] 
	'	) 
	Public Sub SetValues(ByVal sName,ByVal aValues)
		If Not IsArray(aValues) Then
			aValues = Null
		ElseIf -1=UBound(aValues) Then
			aValues = Null
		End If	
		With m_oParams
			If Not .Exists(sName) Then
				If Not IsNull(aValues) Then
					.Add sName, aValues
				End If	
			ElseIf IsNull(aValues) Then
				.Remove sName
			Else
				.Item( sName) = aValues
			End if
		End With		
	End Sub
	

	'---------------------------------------------------------------------------
	'@@QueryStringClass.SetValue
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE SetValue>
	':Назначение:	
	'   Для указанного параметра коллекции устанавливает заданое значение (в том числе 
	'   и массивы значений).
	':Параметры: 	sName - [in] наименование параметра.
	'				vValue - [in] устанавливаемое значение.
	':Примечание:
	'	Если параметр с указанным именем не найден, то метод добавляет его в коллекцию.
	':Сигнатура:	
	'	Public Sub SetValue(
	'       sName [As String],
	'       vValue [As Variant] 
	'	) 
	Public Sub SetValue(sName, vValue)
		SetValues sName, Array(vValue)
	End Sub
	
	
	'---------------------------------------------------------------------------
	'@@QueryStringClass.AddValue
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE AddValue>
	':Назначение:	
	'   Добавляет в коллекцию параметр и его значение.
	':Параметры: 	sName - [in] наименование параметра.
	'				vValue - [in] значение параметра.
	':Сигнатура:	
	'	Public Sub AddValue(
	'       sName [As String],
	'       vValue [As Variant] 
	'	) 
	Public Sub AddValue(sName, vValue)
		Dim aValues	' Текущие значения
		aValues = GetValues(sName)
		If IsNull(aValues) Then
			aValues = Array(vValue)
		Else
			ReDim Preserve aValues(UBound(aValues)+1)
			If IsObject(vValue) Then
				Set aValues(UBound(aValues)) = 	vValue
			Else
				aValues(UBound(aValues)) = 	vValue
			End If	
		End If
		SetValues sName, aValues	
	End Sub

	'---------------------------------------------------------------------------
	'@@QueryStringClass.AddValues
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE AddValues>
	':Назначение:	
	'	Добавляет в текущую коллекцию параметры из заданной коллекции QueryStringClass.
	':Параметры: 	
	'	oQS - [in] коллекция, параметры которой добавляются.
	':Сигнатура:	
	'	Public Sub AddValues( oQS [As QueryStringClass] )
	Public Sub AddValues(oQS)
		Dim sKey	' наименование параметра
		Dim sValue	' значение параметра
		
		If IsObject(oQS) Then
			If StrComp(TypeName(oQS), "QueryStringClass", vbTextCompare) <> 0 Then
				Err.Raise -1, "QueryStringClass::AddValues", "Параметр метода должен быть типа QueryStringClass"
			End If
			For Each sKey In oQS.Names
				For Each sValue In oQS.GetValues(sKey)
					AddValue sKey, sValue
				Next
			Next
		End If
	End Sub
	
	'---------------------------------------------------------------------------
	'@@QueryStringClass.IsExists
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE IsExists>
	':Назначение:	
	'	Проверяет наличие в коллекции параметра с заданным наименованием.
	':Параметры: 	
	'	sName - [in] наименование искомого параметра.
	':Результат: 	
	'	True - указанный параметр в коллекции существует, инчае - False.
	':Сигнатура:	
	'	Public Function IsExists( ByVal sName [As String] ) [As Boolean]
	Public Function IsExists(ByVal sName)
		IsExists = m_oParams.Exists( sName)
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.Remove
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE Remove>
	':Назначение:	
	'	Удаляет указанный параметр из коллекции.
	':Параметры: 	
	'	sName - [in] наименование удаляемого параметра.
	':Результат: 	
	'	- True - указанный параметр в коллекции существовал и был удален; 
	'	- False - указанного параметра в коллекции не было.
	':Сигнатура:	
	'	Public Function Remove( ByVal sName [As String] ) [As Boolean]
	Public Function Remove(byval sName)
		Remove = False
		if m_oParams.Exists(sName) Then 
			m_oParams.Remove sName
			Remove = True
		End if 
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.Clone
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE Clone>
	':Назначение:	
	'	Возвращает копию объекта QueryStringClass.
	':Результат: 	
	'	Экземпляр QueryStringClass, полная копия данного экземпляра.
	':Сигнатура:	
	'	Public Function Clone() [As QueryStringClass]
	Public Function Clone()
		Dim oResult 'результат выполнения функции
		Dim i
		Set oResult = new QueryStringClass
		For Each i in Names
			oResult.SetValues i, GetValues(i)
		Next
		Set Clone = oResult
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.MakeURL
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE MakeURL>
	':Назначение:	
	'	На основании текущего состояния коллекции параметров и заданного имени 
	'	страницы формирует полный URL. Полученный URL используется для загрузки
	'	страницы.
	':Параметры:
	'	sPage - [in] имя страницы.
	':Результат: 	
	'	Строка с полным параметризированным URL-адресом страницы.
	':Примечание:
	'	Если заданное имя страницы является относительным (т.е. отсутствует указание
	'	схемы, адреса сервера, приложения), то метод расширяет адрес страницы до 
	'	полного, используя базовый URL-адрес текущей страницы.
	':Сигнатура:	
	'	Public Function MakeURL( sPage [As String] ) [As String]
	Public Function MakeURL( sPage )
		Dim sURL	' URL страницы
		sURL = sPage 
		' проверяем наличие протокола
		if InStr(1,sURL, "://") <= 0 Then 'протокол отсутствует - используем текущий
			sURL = XService.BaseURL & sURL
		End if
		' добавляем параметры
		if InStr(1,sURL, "?")>0 Then
			sURL = sURL & "&" & QueryString
		Else
			sURL = sURL & "?" & QueryString
		End if
		MakeURL = sURL
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.Self
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self [As QueryStringClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@X_GetQueryString
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetQueryString>
':Назначение:	
'	Создает и инициализирует новый экземпляр класса QueryStringClass.
':Примечание:
'	Функция обрабатывает следующие случаи передачи параметров:
'	- параметры переданы через location.href;
'	- параметры переданы через dialogArguments, как экземпляр класса 
'		QueryStringClass;
'	- параметры переданы через dialogArguments, в виде строки;
'	- параметры переданы через dialogArguments, первым элементом массива, 
'		как экземпляр класса QueryStringClass;
'	- параметры переданы через dialogArguments, первым элементом массива, 
'		строкой.
'	Фукнция проверяет перечисленные случаи задания параметров (в порядке их
'	перечисления) и создает экземпляр QueryStringClass при нахождении первого
'	подходящего случая.
':Сигнатура:
'	Function X_GetQueryString() [As QueryStringClass]
Function X_GetQueryString()
	Dim nOffset		' Смещение
	Dim oQS			' Объект QueryStringClass - результат выполнения функции
	Dim aDA			' Массив в DialogArguments
	Dim vArgs		' аргументы
	
	X_GetDialogArguments vArgs

	'	!!! ВНИМАНИЕ !!!
	' В IE 5.5+ замечена следующая особенность:
	'	плавающий фрейм(IFRAME), заключённый в диалоговое окно наследует
	'	DialogArguments от родителя, что может привести к сбоям и некорректным значениям параметров
	'	поэтому при работе в плавающем фрейме обрабатываем только первый вариант передачи параметров...
	'	...
	if  Not(Window Is Parent) or IsEmpty(vArgs) or IsNull(vArgs) Then
		' 1-й вариант - параметры переданы через location.href
		Set oQS = new QueryStringClass
		nOffset = InStr(1,document.location.href,"?")
		if nOffset > 0 Then
			oQS.QueryString = MID(document.location.href, nOffset + 1)
		End if
	ElseIf vbString = VarType(vArgs) Then
		' 3-й вариант - параметры переданы через DialogArguments в виде строки
		Set oQS = new QueryStringClass
		oQS.QueryString = vArgs
	ElseIf 0=StrComp(TypeName(vArgs), "QueryStringClass", vbTextCompare) Then
		' 2-й вариант - параметры переданы через DialogArguments в виде объекта QueryStringClass
		Set  oQS = vArgs.Clone
	ElseIf IsArray(vArgs) Then
		aDA = vArgs
		if vbString = VarType(aDA(0)) Then
			' 5-й вариант - параметры переданы через DialogArguments в виде 1-го элемента массива строкой
			Set oQS = new QueryStringClass
			oQS.QueryString = aDA(0)
		ElseIf 0=StrComp(TypeName(aDA(0)), "QueryStringClass", vbTextCompare) Then
			' 4-й вариант - параметры переданы через DialogArguments в виде 1-го элемента массива объектом QueryStringClass
			Set  oQS = aDA(0).Clone
		End if
	End if
	Set X_GetQueryString = oQS
End Function

'===============================================================================
'@@X_GetEmptyQueryString
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetEmptyQueryString>
':Назначение:	
'	Создает новый пустой экземпляр класса QueryStringClass.
':Сигнатура:
'	Function X_GetEmptyQueryString() [As QueryStringClass]
Function X_GetEmptyQueryString()
	Set X_GetEmptyQueryString = new QueryStringClass
End Function


'===============================================================================
'@@X_GetApproximateXmlSize
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetApproximateXmlSize>
':Назначение:
'	Функция выполняет примерное определение размера XML-файла.
':Параметры:
'	oXml - 
'       [in] XML-файл.
':Сигнатура:
'   Function X_GetApproximateXmlSize( 
'       oXml [As IXMLDOMDocument] 
'   ) [As Int]
Function X_GetApproximateXmlSize(oXml)
	Dim oNode	' Узел
	Dim nLen	' Длина
	nLen=0
	For Each oNode in oXml.selectNodes("//*[not(*)]")
		if oNode.dataType="bin.hex" Then
			if IsNull(oNode.nodeTypedValue) Then
				nLen = nLen + len(oNode.xml)
			Else
				nLen = nLen + len(oNode.tagName)*2 + 5 +  UBound(oNode.nodeTypedValue)+1
			End if
		Else
			nLen = nLen + len(oNode.xml)
		End if
	Next
	For Each oNode in oXml.selectNodes("//*[*]")
		nLen = nLen + len(oNode.tagName)*2 + 5
	Next
	For Each oNode in oXml.selectNodes("//@*")
		nLen = nLen + len(oNode.xml) + 1
	Next
	X_GetApproximateXmlSize=nLen
End Function


'===============================================================================
'@@X_CreateControlsDisabler
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CreateControlsDisabler>
':Назначение:
'	Фабрика класса ControlsDisablerClass.
':Параметры:
'	oObject - 
'       [in] объект, который блокируется - в нем вызывается метод <b>EnableControls</b>.
':Сигнатура:
'   Function X_CreateControlsDisabler( 
'       oObject [As Variant] 
'   ) [As ControlsDisablerClass]
Function X_CreateControlsDisabler(oObject)
	Set X_CreateControlsDisabler = X_CreateControlsDisablerEx(oObject, Nothing)
End Function


'===============================================================================
'@@X_CreateControlsDisablerEx
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CreateControlsDisablerEx>
':Назначение:
'	Фабрика класса ControlsDisablerClass. Позволяет задать как блокируемый объект, 
'   так и объект, на который следует установить фокус.
':Параметры:
'	oObject - 
'       [in] объект, который блокируется - в нем вызывается метод <b>EnableControls</b>.
'	oSetFocusObject - 
'       [in] объект, на который устанавливается фокус после разблорирования - в нем 
'       вызывается метод <b>SetFocus</b>.
':Сигнатура:
'   Function X_CreateControlsDisablerEx( 
'       oObject [As Variant],
'       oSetFocusObject [As Variant] 
'   ) [As ControlsDisablerClass]
Function X_CreateControlsDisablerEx(oObject, oSetFocusObject)
	Set X_CreateControlsDisablerEx = New ControlsDisablerClass
	X_CreateControlsDisablerEx.DoCreate oObject, oSetFocusObject
End Function


'===============================================================================
'@@ControlsDisablerClass
'<GROUP !!CLASSES_x-utils><TITLE ControlsDisablerClass>
':Назначение:	
'	Класс для упрощения логики блокирования объектов.
'
'@@!!MEMBERTYPE_Methods_ControlsDisablerClass
'<GROUP ControlsDisablerClass><TITLE Методы>
Class ControlsDisablerClass
	Private m_oObject
	Private m_oSetFocusObject
	
	'---------------------------------------------------------------------------
	'@@ControlsDisablerClass.DoCreate
	'<GROUP !!MEMBERTYPE_Methods_ControlsDisablerClass><TITLE DoCreate>
	':Назначение:	
	'	Процедура инициализации экземпляра класса ControlsDisablerClass.
	'	Блокирует заданный объект и переводит фокус.
	':Параметры:
    '	oObject - 
    '       [in] объект, который блокируется - в нем вызывается метод <b>EnableControls</b>.
    '	oSetFocusObject - 
    '       [in] объект, на который устанавливается фокус после разблорирования - в нем 
    '       вызывается метод <b>SetFocus</b>.
    ':Сигнатура:
    '   Public Sub DoCreate( 
    '       oObject [As Variant],
    '       oSetFocusObject [As Variant] 
    '   ) 
	Public Sub DoCreate(oObject, oSetFocusObject)
		If IsNothing(oObject) Then Err.Raise -1, "ControlsDisablerClass::DoCreate", "Параметр oObject должен быть задан"
		Set m_oObject = oObject
		m_oObject.EnableControls False
		Set m_oSetFocusObject = toObject(oSetFocusObject)
	End Sub
	
	Private Sub Class_Initialize
		Set m_oObject = Nothing
		Set m_oSetFocusObject = Nothing
	End Sub
	
	Private Sub Class_Terminate
		' Есл вдруг DoCreate не вызывали, тихо выйдем
		If Nothing Is m_oObject Then Exit Sub
		m_oObject.EnableControls True
		If Not IsNothing(m_oSetFocusObject) Then
			m_oSetFocusObject.SetFocus
		End If
	End Sub
End Class


'===============================================================================
'@@X_GetHtmlElementScreenPos
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetHtmlElementScreenPos>
':Назначение:
'	Процедура получения "экранных" координат верхнего левого угла HTML-элемента. 
'   Учитывает скроллирование страницы (или "родительского" элемента).
':Параметры:
'	oHtmlElement - 
'       [in] HTML-элемент.
'	nPosX - 
'       [out] "экранная" координата X.
'	nPosY - 
'       [out] "экранная" координата Y.
':Примечание:	
'	Начальные значения параметров <b><i>nPosX</b></i> и <b><i>nPosY</b></i> сбрасываются.
':Сигнатура:
'   Sub X_GetHtmlElementScreenPos( 
'       oHtmlElement [As IHTMLDOMElement],
'       ByRef nPosX [As Int],
'       ByRef nPosY [As Int]
'   ) 
Sub X_GetHtmlElementScreenPos( oHtmlElement, ByRef nPosX, ByRef nPosY )
	X_GetHtmlElementRelativePos oHtmlElement, nPosX, nPosY
	nPosX = nPosX + window.top.screenLeft 
	nPosY = nPosY + window.top.screenTop
End Sub


'===============================================================================
'@@X_GetHtmlElementRelativePos
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetHtmlElementRelativePos>
':Назначение:
'	Процедура получения относительных (окна) координат верхнего левого угла 
'   HTML-элемента. Учитывает скроллирование страницы (или "родительского" элемента)
'   и вложенность фреймов.
':Параметры:
'	oElement - 
'       [in] HTML-элемент.
'	nPosX - 
'       [out] "экранная" координата X.
'	nPosY - 
'       [out] "экранная" координата Y.
':Примечание:	
'	Начальные значения параметров <b><i>nPosX</b></i> и <b><i>nPosY</b></i> сбрасываются.
':Сигнатура:
'   Sub X_GetHtmlElementRelativePos( 
'       oElement [As IHTMLDOMElement],
'       ByRef nPosX [As Int],
'       ByRef nPosY [As Int]
'   ) 
Sub X_GetHtmlElementRelativePos( oElement, ByRef nPosX, ByRef nPosY )

	X_GetHtmlElementRelativePosEx window, oElement, nPosX, nPosY
End Sub

'===============================================================================
'@@X_GetHtmlElementRelativePosEx
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetHtmlElementRelativePosEx>
':Назначение:
'	Процедура получения относительных (окна) координат верхнего левого угла 
'   HTML-элемента. Учитывает скроллирование страницы (или "родительского" элемента)
'   и вложенность фреймов.
':Параметры:
'	oWindow - 
'       [in] текущее окно браузера.
'	oElement - 
'       [in] HTML-элемент.
'	nPosX - 
'       [out] "экранная" координата X.
'	nPosY - 
'       [out] "экранная" координата Y.
':Примечание:	
'	Начальные значения параметров <b><i>nPosX</b></i> и <b><i>nPosY</b></i> сбрасываются.
':Сигнатура:
'   Sub X_GetHtmlElementRelativePosEx( 
'       oWindow [As IHTMLWindow],
'       oElement [As IHTMLDOMElement],
'       ByRef nPosX [As Int],
'       ByRef nPosY [As Int]
'   ) 
Sub X_GetHtmlElementRelativePosEx( oWindow, oElement, ByRef nPosX, ByRef nPosY )
	Dim oCurrentElement	' элемент цепочки "потомок-родитель", переменная цикла
	Set oCurrentElement = oElement
	nPosX = 0
	nPosY = 0
	Do
		Do 
			If Not hasValue(oCurrentElement) Then Exit Do
			nPosX = nPosX + oCurrentElement.offsetLeft - oCurrentElement.scrollLeft
			nPosY = nPosY + oCurrentElement.offsetTop - oCurrentElement.scrollTop
			
			If Not hasValue(oCurrentElement.offsetParent) Then Exit Do
			' Элемент верхнего уровня м.б. "замкнут" ссылкой на самого себя
			If oCurrentElement Is oCurrentElement.offsetParent Then Exit Do
			
			Set oCurrentElement = oCurrentElement.offsetParent
			
		Loop
		' если элемент (oCurrentElement) находился в окне фрейма, то выйдем в родительский документ и продолжим
		If oWindow.frameElement Is Nothing Then Exit Do
		Set oCurrentElement = oWindow.frameElement
		Set oWindow = oWindow.Parent
	Loop
End Sub


'===============================================================================
'@@X_SafeFocus
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SafeFocus>
':Назначение:
'	"Безопасная" установка фокуса для заданного HTML-элемента. Реализация метода focus 
'   (установка фокуса) в HTML, если элемент на момент вызова недоступен.
'   Данная реализация пытается установить фокус таким образом, чтобы ошибка не возникала.
':Параметры:
'	oHtmlElement - 
'       [in] HTML-элемент.
':Результат:
'	Признак успешности установки фокуса.
':Сигнатура:
'   Function X_SafeFocus( 
'       oHtmlElement [As IHTMLDOMElement]
'   ) [As Boolean]
Function X_SafeFocus( oHtmlElement )
	On Error GoTo 0
	X_SafeFocus = False
	On Error Resume Next
	oHtmlElement.focus
	X_SafeFocus = CBool(0 = Err.Number)
	On Error GoTo 0
End Function


'===============================================================================
'@@X_GetVbsTypeCaseFunc
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetVbsTypeCaseFunc>
':Назначение:
'	Возвращает наименование VBS-функции для приведения значения скалярного 
'   необъктного свойства заданного типа.
':Параметры:
'	sPropType - 
'       [in] тип XML-свойства.
':Сигнатура:
'   Function X_GetVbsTypeCaseFunc( 
'       sPropType [As String]
'   ) [As String]
Function X_GetVbsTypeCaseFunc(sPropType)
	Dim sFunc		' наименование функции
	Select Case sPropType
		Case "ui1"
			sFunc = "CByte"
		Case "i2"
			sFunc = "CInt"
		Case "i4"
			sFunc = "CLng"
		Case "boolean"
			sFunc = "CBool"
		Case "fixed"
			sFunc = "CCur"
		Case "r4"
			sFunc = "CSng"
		Case "r8"
			sFunc = "CDbl"
		Case "string", "text"
			sFunc = "CStr"
	End Select
	X_GetVbsTypeCaseFunc = sFunc
End Function


'===============================================================================
'@@X_IsSecurityException
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsSecurityException>
':Назначение:
'	Функция проверяет, является ли описание ошибки, полученное от сервера приложений, 
'   описанием исключения типа 
'   <LINK Croc.XmlFramework.Public.XSecurityException, XSecurityException />.
':Параметры:
'	oLastServerErrorXml - 
'       [in] XML-элемент с данными ошибки, полученной от сервера приложений.
':Сигнатура:
'   Function X_IsSecurityException( 
'       oLastServerErrorXml [As IXMLDOMElement]
'   ) [As Boolean]
Function X_IsSecurityException(oLastServerErrorXml)
	X_IsSecurityException = X_CheckExceptionType(oLastServerErrorXml, "Croc.XmlFramework.Public.XSecurityException")
End Function 


'===============================================================================
'@@X_IsBusinessLogicException
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsBusinessLogicException>
':Назначение:
'	Функция проверяет, является ли описание ошибки, полученное от сервера приложений, 
'   описанием исключения типа 
'   <LINK Croc.XmlFramework.Public.XBusinessLogicException, XBusinessLogicException />.
':Параметры:
'	oLastServerErrorXml - 
'       [in] XML-элемент с данными ошибки, полученной от сервера приложений.
':Сигнатура:
'   Function X_IsBusinessLogicException( 
'       oLastServerErrorXml [As IXMLDOMElement]
'   ) [As Boolean]
Function X_IsBusinessLogicException(oLastServerErrorXml)
	X_IsBusinessLogicException = X_CheckExceptionType(oLastServerErrorXml, "Croc.XmlFramework.Public.XBusinessLogicException")
End Function 

'===============================================================================
'@@X_IsObjectNotFoundException
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsObjectNotFoundException>
':Назначение:
'	Функция проверяет, является ли описание ошибки, полученное от сервера приложений, 
'   описанием исключения типа 
'   <LINK Croc.XmlFramework.Data.XObjectNotFoundException, XObjectNotFoundException />.
':Параметры:
'	oLastServerErrorXml - 
'       [in] XML-элемент с данными ошибки, полученной от сервера приложений.
':Сигнатура:
'   Function X_IsObjectNotFoundException( 
'       oLastServerErrorXml [As IXMLDOMElement]
'   ) [As Boolean]
Function X_IsObjectNotFoundException(oLastServerErrorXml)
	X_IsObjectNotFoundException = X_CheckExceptionType(oLastServerErrorXml, "Croc.XmlFramework.Data.XObjectNotFoundException")
End Function 


'===============================================================================
'@@X_IsOutdatedTimestampException
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsOutdatedTimestampException>
':Назначение:
'	Функция проверяет, является ли описание ошибки, полученное от сервера приложений, 
'   описанием исключения типа 
'   <LINK Croc.XmlFramework.Data.XOutdatedTimestampException, XOutdatedTimestampException />.
':Параметры:
'	oLastServerErrorXml - 
'       [in] XML-элемент с данными ошибки, полученной от сервера приложений.
':Сигнатура:
'   Function X_IsOutdatedTimestampException( 
'       oLastServerErrorXml [As IXMLDOMElement]
'   ) [As Boolean]
Function X_IsOutdatedTimestampException(oLastServerErrorXml)
	X_IsOutdatedTimestampException = X_CheckExceptionType(oLastServerErrorXml, "Croc.XmlFramework.Data.XOutdatedTimestampException")
End Function

'===============================================================================
'@@X_CheckExceptionType
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CheckExceptionType>
':Назначение:
'	Функция проверяет, является ли описание ошибки, полученное от сервера приложений, 
'   описанием исключения заданного типа.
':Параметры:
'	oLastServerErrorXml - 
'       [in] XML-элемент с данными ошибки, полученной от сервера приложений.
'	sFullTypeName - 
'       [in] наименование типа класса исключения.
':Сигнатура:
'   Function X_CheckExceptionType( 
'       oLastServerErrorXml [As IXMLDOMElement],
'       sFullTypeName [As String]
'   ) [As Boolean]
Function X_CheckExceptionType(oLastServerErrorXml, sFullTypeName)
	X_CheckExceptionType = False
	If Not Nothing Is oLastServerErrorXml Then
		If Not Nothing Is oLastServerErrorXml.selectSingleNode("type-info//type[@n='" & sFullTypeName & "']") Then
			X_CheckExceptionType = True
		End If
	End If
End Function


'===============================================================================
'@@X_HandleError
'<GROUP !!FUNCTIONS_x-utils><TITLE X_HandleError>
':Назначение:
'	Функция отображает диалог сообщения об ошибке (если была).
':Результат:
'	True - если серверная ошибка была, False - в противном случае.
':Сигнатура:
'   Function X_HandleError() [As Boolean]
Function X_HandleError()
	X_HandleError = False
	If X_WasErrorOccured Then
		X_GetLastError.Show
		X_ClearLastServerError
		X_HandleError = True
	End If
End Function


'===============================================================================
'@@X_ResetSession
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ResetSession>
':Назначение:
'	Процедура сброса сессии.
':Сигнатура:
'   Sub X_ResetSession
Sub X_ResetSession
	Dim sResetUrl ' Url для сброса сессии
	Dim sBaseUrl  ' Базовый Url
	Dim sPageUrl  ' Url страницы на которую надо вернуться после сброса сессии
	sBaseUrl = XService.BaseURL()
	sPageUrl = MID( window.location.href, len(sBaseUrl)+1)
	sResetUrl = sBaseUrl & "x-reset.aspx?TM=" & CDbl(Now) & "&RET=" & XService.UrlEncode(sPageUrl)
	Window.Navigate  sResetUrl
End Sub

'===============================================================================
'@@X_RunReport
'<GROUP !!FUNCTIONS_x-utils><TITLE X_RunReport>
':Назначение:
'	Процедура открывает отчет, описанный в метаданных.
':Параметры:
'	sReportName - 
'       [in] метанаименование отчета в матаданных (элемент <b>i:report</b>).
'	vUrlArgs - 
'       [in] аргументы, передаваемые в диалог фильтра. Строка или QueryStringClass
':Примечание:	
'	В случае, если в метаданных отчета указан фильтр, то процедура открывает
'   x-report-filter.aspx. Иначе - открывает отчет непосредственно по URL.
':Сигнатура:
'   Sub X_RunReport (
'       sReportName [As String], 
'       vUrlArgs [As String | QueryStringClass]
'   )
Sub X_RunReport(sReportName, vUrlArgs)
	Dim oReportMD	    ' метаданые отчета (элемент i:report)
	Dim oFilter		    ' узел описания фильтра (i:filter-direct-url | i:filter-as-editor)
	Dim sUrl		    ' URL отчета
	Dim bSendUsingPOST  ' признак передачи параметров на сервер методом POST
	
	Set oReportMD = XService.XMLGetDocument("x-metadata.aspx?NODE=i%3Areport&NAME=" & sReportName)
	If oReportMD Is Nothing Then
		' Нет метаданных отчета. Откроем по простецки
		X_OpenReportEx "x-get-report.aspx?name=" & sReportName & ".xml", vUrlArgs, False
		Exit Sub
	End If
		
	Set oReportMD = oReportMD.documentElement
	Set oFilter = oReportMD.selectSingleNode("i:filter-direct-url | i:filter-as-editor")    
	If oFilter Is Nothing Then
		bSendUsingPOST = LCase(CStr(X_GetAttributeDef(oReportMD, "sendUsingPOST", False)))
		bSendUsingPOST = iif(IsNumeric(bSendUsingPOST), bSendUsingPOST <> "0", bSendUsingPOST = "true")
		sUrl = X_GetAttributeDef(oReportMD, "url", "x-get-report.aspx?name=r-" & sReportName & ".xml")
		X_OpenReportEx sUrl, vUrlArgs, bSendUsingPOST
	Else
		' Формируем URL редактора
		sUrl = XService.BaseUrl() & "x-report-filter.aspx?MetaName=" & sReportName
		' Откроем диалоговое окно редактора
		X_ShowModalDialog sURL, vUrlArgs
	End If
End Sub

'===============================================================================
'@@X_SaltPerMonth
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SaltPerMonth>
':Назначение:
'	Salt-функция: генерация служебного значения, различного для каждого месяца.
':Результат:
'	Строка формата "SLT-M-{YYYYMM}", где {YYYYMM} - значения года и месяца,
'   соответствующих текущей дате.
':Примечание:	
'	Результат используется при формировании URL или хэш-ключей, в частности,
'   в функциях загрузки данных, использующих локальный кэш (см. описание
'   функции X_GetListData).
':Сигнатура:
'   Function X_SaltPerMonth() [As String]
Function X_SaltPerMonth() 
	With DateToDateTimeFormatter( Now() )
		X_SaltPerMonth = "SLT-M-" & .YearString & .MonthString
	End With
End Function

'===============================================================================
'@@X_SaltPerWeek
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SaltPerWeek>
':Назначение:
'	Salt-функция: генерация служебного значения, различного для каждой недели 
'   (вне зависимости от года/месяца).
':Результат:
'	Строка формата "SLT-W-{YYYYMM}-{W}", где {YYYYMM} - значения года и месяца,
'   соответствующих текущей дате; {W} - номер недели месяца.
':Примечание:	
'   Если первое число месяца попадает на середину недели, то такая
'   неделя считается первой неделей месяца.<P/>
'	Результат используется при формировании URL или хэш-ключей, в частности,
'   в функциях загрузки данных, использующих локальный кэш (см. описание
'   функции X_GetListData).
':Сигнатура:
'   Function X_SaltPerWeek() [As String]
Function X_SaltPerWeek()
	With DateToDateTimeFormatter( Now() )
		X_SaltPerWeek = "SLT-W-" & .YearString & .MonthString & "-" & .WeekNumString
	End With
End Function


'===============================================================================
'@@X_SaltPerDay
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SaltPerDay>
':Назначение:
'	Salt-функция: генерация служебного значения, различного для каждого календарного дня.
':Результат:
'	Строка формата "SLT-D-{YYYYMMDD}", где {YYYYMMDD} - значения года, месяца и дня,
'   соответствующих текущей дате.
':Примечание:	
'	Результат используется при формировании URL или хэш-ключей, в частности,
'   в функциях загрузки данных, использующих локальный кэш (см. описание
'   функции X_GetListData).
':Сигнатура:
'   Function X_SaltPerDay() [As String]
Function X_SaltPerDay() 
	With DateToDateTimeFormatter( Now() )
		X_SaltPerDay = "SLT-D-" & .YearString & .MonthString & .DayString 
	End With
End Function

'===============================================================================
'@@X_SaltPerHour
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SaltPerHour>
':Назначение:
'	Salt-функция: генерация служебного значения, различного для каждого часа каждого 
'   календарного дня.
':Результат:
'	Строка формата "SLT-H-{YYYYMMDD}-{HH}", где {YYYYMMDD} - значения года, месяца и дня,
'   соответствующих текущей дате; {H} - номер часа, соответствующего текущему времени.
':Примечание:	
'	Результат используется при формировании URL или хэш-ключей, в частности,
'   в функциях загрузки данных, использующих локальный кэш (см. описание
'   функции X_GetListData).
':Сигнатура:
'   Function X_SaltPerHour() [As String]
Function X_SaltPerHour() 
	With DateToDateTimeFormatter( Now() )
		X_SaltPerHour = "SLT-H-" & .YearString & .MonthString & .DayString & "-" & .HourString
	End With
End Function

'===============================================================================
'@@X_SaltPerSession
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SaltPerSession>
':Назначение:
'	Salt-функция: генерация служебного значения, различного для каждой сессии 
'   ASP .NET, установленной между клиентом и сервером.
':Результат:
'	Строка формата "SLT-SESS-{KEY}", где {KEY} - значения сессионного ключа,
'   уникального для каждой сессии ASP .NET.
':Примечание:	
'   Если клиент не устанавливает сессию ASP .NET, то в качестве результата возвращается 
'   значение, гарантированно различное для каждого часа каждого календарного дня.<P/>
'	Результат используется при формировании URL или хэш-ключей, в частности,
'   в функциях загрузки данных, использующих локальный кэш (см. описание
'   функции X_GetListData).
':Сигнатура:
'   Function X_SaltPerSession() [As String]
Function X_SaltPerSession() 
	' Наименование cookie, в которой ASP .NET сохраняет "идентификатор" сессии
	Const ASP_NET_SESSION_COOKIE = "ASP.NET_SESSIONID"
	                                                     
	Dim aCookies	' массив строк вида "{ключ}={значение}", соотв. всем cookie на клиенте
	Dim sCookie		' строка с cookie, используемой для сохранения "идентификатора" сесси ASP .NET
	Dim nIndex		' итератор цикла
	
	sCookie = ""
	' Суть идеи определения сессии: 
	' ASP .NET сохраняет "идентификатор" сессии в качестве значения cookie 
	' с наименованием "ASP.NET_SessionId"; для анализа получаем строку со значениями
	' всех cookie, в виде набора пар {ключ}={значение}, разделенных символом ";",
	' формируем массив таких пар и пытаемся найти нужную:
	If 0 <> InStr( UCase(document.cookie), ASP_NET_SESSION_COOKIE ) Then
		aCookies = Split( UCase(document.cookie),";")
		For nIndex=0 to UBound(aCookies)
			If 0 <> InStr( aCookies(nIndex),ASP_NET_SESSION_COOKIE) Then 
				sCookie = Trim( aCookies(nIndex) )
				Exit For
			End If
		Next
	End If
	
	' В найденной строке (вида {ключ}={значение}) заменяем наименование ключа 
	' и символ "=" пустыми символамми, и затем убираем лидирующие и финальные 
	' пробелы. Так, по идее, получаем "чистое" значение:
	sCookie = Trim( Replace( Replace( sCookie,ASP_NET_SESSION_COOKIE,"" ), "=", "" ) )
	
	' Если в итоге мы получили "пустую" cookie - то вместо нее сгенерируем 
	' значение, гарантированно различающееся для каждого часа каждого дня:
	If 0 = Len(sCookie) Then
		With DateToDateTimeFormatter( Now() )
			sCookie = "STUB-" & .YearString & .MonthString & .DayString & "-" & .HourString
		End With
	End If
	
	X_SaltPerSession = "SLT-SESS-" & sCookie 
End Function

'===============================================================================
'@@ConfigClass
'<GROUP !!CLASSES_x-utils><TITLE ConfigClass>
':Назначение:	
'	Класс-обертка для файла конфигурации.
'
'@@!!MEMBERTYPE_Methods_ConfigClass
'<GROUP ConfigClass><TITLE Методы>
Class ConfigClass
	Private m_oConfig			' IXMLDOMDocument с конфигурацией системы или Empty
	
	'---------------------------------------------------------------------------
	'@@ConfigClass.GetValue
	'<GROUP !!MEMBERTYPE_Methods_ConfigClass><TITLE GetValue>
	':Назначение:	
	'	Функция возвращает значение узла (элемента или атрибута) файла конфигурации.
	':Параметры:
    '	sXPath - 
    '       [in] строка с путем к узлу в файле конфигурации (выражение XPath).
    ':Примечание:	
    '   Перед вызовом необходимо загрузить секцию с помощью процедуры 
    '   <LINK ConfigClass.Load, Load />. 
    ':Сигнатура:
    '   Public Function GetValue(
    '       ByVal sXPath [As String] 
    '   ) [As IXMLDOMElement]
	Public Function GetValue(ByVal sXPath)
		Dim oNode	' IXMLDOMElement
		
		If IsEmpty(m_oConfig) Then
			Err.Raise -1, "ConfigClass::GetValue", "Объект не инициализирован"
		End If
		Set oNode = m_oConfig.selectSingleNode(sXPath)
		If Not oNode Is Nothing Then
			GetValue = oNode.nodeTypedValue
		End If
	End Function

	'---------------------------------------------------------------------------
	'@@ConfigClass.Load
	'<GROUP !!MEMBERTYPE_Methods_ConfigClass><TITLE Load>
	':Назначение:	
	'	Процедура выполняет загрузку секции с сервера или инициализацию из кэша.
	':Параметры:
    '	sSectionXPath - 
    '       [in] строка с путем к секции в файле конфигурации (выражение XPath).
    ':Сигнатура:
    '   Public Sub Load(
    '       sSectionXPath [As String] 
    '   ) 
	Public Sub Load(sSectionXPath)
		Dim oServerConfig	' XConfig с сервера
		Dim bCached			' признак наличия кэшированных метаданных
		Dim sCookie			' строка cookie, используемая для определения факта инициализации Config в сессии
		Dim bLoaded			' признак, что запрешенная секция грузилась с сервера

		bLoaded = False
		If IsEmpty(m_oConfig) Then
			sCookie = XService.URLEncode( XService.BaseURL()) & "CONFIG=1"
			' Получаем кэшированные config
			bCached = XService.GetUserData( XCONFIG_STORE, m_oConfig)
			
			' Если на клиенте нет Config'a
			If Not bCached Or 0 = InStr( document.cookie, sCookie ) Then
				' Грузим запрошенную секцию Config с сервера
				Set oServerConfig = getSectionFromServer(sSectionXPath)
				If oServerConfig Is Nothing Then Exit Sub
				bLoaded = True
				With XService.XMLGetDocument()
					Set m_oConfig = .appendChild( .createElement("config") )
				End With
				m_oConfig.appendChild oServerConfig
				' Сохраняем корневой элемент в клиентском кэше
				XService.SetUserData XCONFIG_STORE, m_oConfig
			End If
			' Устанавливаем пространства имен для XPath-запросов
			XService.XMLSetSelectionNamespaces m_oConfig.ownerDocument
			' инициализируем Cookie
			document.cookie = sCookie
		End If
		If m_oConfig.selectSingleNode(sSectionXPath) Is Nothing And Not bLoaded Then
			' заданной секции в закешированном конфиге нет и при этом мы еще не грузили ее с сервера
			Set oServerConfig = getSectionFromServer(sSectionXPath)
			If oServerConfig Is Nothing Then Exit Sub
			m_oConfig.appendChild oServerConfig
			' Сохраняем корневой элемент в клиентском кэше
			XService.SetUserData XCONFIG_STORE, m_oConfig
		End If
	End Sub
		
	'==================================================================
	'	Возвращает XML объект XConfig.xml с сервера
	Private Function getSectionFromServer(sSectionXPath)
		Set getSectionFromServer = Nothing
		On Error Resume Next
		With New XGetConfigElementRequest
			.m_sName = "GetConfigElement"
			.m_sParameterPath = sSectionXPath
			Set getSectionFromServer = X_ExecuteCommand( .Self ).m_oParameterElement
		End With
		If Err Then 
			X_HandleError
		ElseIf getSectionFromServer Is Nothing Then
			Alert "Не удалось загрузить элемент '" & sSectionXPath & "' файла конфигурации с сервера"
		End If 
	End Function
End Class

'===============================================================================
'@@X_Config
'<GROUP !!FUNCTIONS_x-utils><TITLE X_Config>
':Назначение:
'	Функция возвращает объект класса ConfigClass, если он еще не создан, то создает его.
':Параметры:
'	sSectionXPath - 
'       [in] наименование секции в файле конфигурации, которая гарантированно загружается
'       (по сути - это xpath в контексте <b>xfw:configuration</b>).
':Сигнатура:
'   Function X_Config( 
'       sSectionXPath [As String]
'   ) [As ConfigClass]
Function X_Config(sSectionXPath)
	If Not hasValue(x_oConfig) Then
		Set x_oConfig = New ConfigClass
		x_oConfig.Load sSectionXPath
	End If
	Set X_Config = x_oConfig
End Function

'===============================================================================
' Внутренняя процедура добавления ограничений в XML-запрос загрузчика дерева.
' Параметры:
'	oRestrictions - [in] XML-запрос загрузчика дерева.
'	sUrlRestrictions - [in] накладываемые ограничения в виде QueryString-строки.
' Сигнатура:
'   Sub internal_TreeInsertRestrictions( 
'       oRestrictions [As IXMLDOMElement],
'       sUrlRestrictions [As String]
'   ) 
Sub internal_TreeInsertRestrictions(oRestrictions, sUrlRestrictions)
	Dim oQS				' Строка запроса (CXQueryString)
	Dim oParamsElement	' Элемент params в restrictions
	Dim oParamsFromQS	' Элемент params, полученный из oQS
	Dim oParam			' Элемент param
	
	If 0 = Len( sUrlRestrictions) Then Exit Sub
	'Распарсим их
	Set oQS = X_GetEmptyQueryString
	oQS.QueryString = sUrlRestrictions
	
	Set oParamsElement = oRestrictions.selectSingleNode("params")
	' Если нет тега - создадим
	If Nothing Is oParamsElement Then
		' примечание: SerializeToXml возвращает узел params
		oRestrictions.appendChild( oQS.SerializeToXml() )
	Else
		' узел params уже есть, поэтому пернесем в него все узлы param из сериализованного объекта oQS
		Set oParamsFromQS = oQS.SerializeToXml() 
		For Each oParam In oParamsFromQS.selectNodes("param")
			oParamsElement.appendChild oParam
		Next
	End If
End Sub


'===============================================================================
' Внутренняя процедура добавления списка исключаемых узлов в XML-запрос загрузчика дерева.
' Параметры:
'	oRestrictions - [in] XML-запрос загрузчика дерева.
'	sExcludeNodes - [in] список исключаемых узлов. См. комментарий к [x-utils.vbs]SelectFromTreeDialogClass.ExcludeNodes
' Сигнатура:
'   Sub internal_TreeSetExcludeNodes( 
'       oRestrictions [As IXMLDOMElement],
'       sExcludeNodes [As String]
'   ) 
Sub internal_TreeSetExcludeNodes(oRestrictions, sExcludeNodes)
	If hasValue(sExcludeNodes) Then
		sExcludeNodes = Replace(Replace(sExcludeNodes, ";", "|"), ",", "|")
		oRestrictions.setAttribute "exclude", sExcludeNodes
	End If
End Sub


'===============================================================================
'@@IParamCollectionBuilder
'<GROUP !!CLASSES_x-utils><TITLE IParamCollectionBuilder>
':Назначение:	
'	Интерфейс IParamCollectionBuilder для формирования коллекции параметров.
'   Используется при вызове IFilterObject::GetRestrictions.
'
'@@!!MEMBERTYPE_Methods_IParamCollectionBuilder
'<GROUP IParamCollectionBuilder><TITLE Методы>
Class IParamCollectionBuilder

	'---------------------------------------------------------------------------
	'@@IParamCollectionBuilder.AppendParameter
	'<GROUP !!MEMBERTYPE_Methods_IParamCollectionBuilder><TITLE AppendParameter>
	':Назначение:	
	'	Процедура выполняет добавление параметра в коллекцию параметров.
	':Параметры:
    '	sParameterName - 
    '       [in] имя параметра.
    '	sParameterText - 
    '       [in] значение параметра в виде текста в соответствии с XML DataTypes.
    ':Сигнатура:
    '   Public Sub AppendParameter(
    '       sParameterName [As String],
    '       sParameterText [As String]
    '   ) 
	Public Sub AppendParameter(sParameterName, sParameterText)
	End Sub
End Class


'===============================================================================
'@@XmlParamCollectionBuilderClass
'<GROUP !!CLASSES_x-utils><TITLE XmlParamCollectionBuilderClass>
':Назначение:	
'	Реализация интерфейса IParamCollectionBuilder. Поддерживает массивные параметры. 
':Примечание:	
'	Формирует XML вида:<P/>
'	&lt;pаrams&gt;<P/>
' 		&lt;pаram name='Name1'&gt;Value1&lt;/pаram&gt;<P/>
' 		&lt;pаram name='Name2'&gt;Value2&lt;/pаram&gt;<P/>
' 		&lt;pаram name='NameY'&gt;ValueY&lt;/pаram&gt;<P/>
' 	&lt;/pаrams&gt;
'
'@@!!MEMBERTYPE_Methods_XmlParamCollectionBuilderClass
'<GROUP XmlParamCollectionBuilderClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_XmlParamCollectionBuilderClass
'<GROUP XmlParamCollectionBuilderClass><TITLE Свойства>
Class XmlParamCollectionBuilderClass
	'-------------------------------------------------------------------------------
	' Назначение:	IXMLDOMElement, DocumentElement формируемого
	'				XML-документа, содержащего коллекцию параметров
	' Результат:    
	' Параметры:	
	' Примечание:	
	' Зависимости:	
	' Пример: 		
	Private m_oXmlParametersRoot

	'------------------------------------------------------------------------------
	'@@XmlParamCollectionBuilderClass.XmlParametersRoot
	'<GROUP !!MEMBERTYPE_Properties_XmlParamCollectionBuilderClass><TITLE XmlParametersRoot>
	':Назначение:	
	'	DocumentElement формируемого XML-документа, содержащего коллекцию параметров.
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get XmlParametersRoot [As IXMLDOMElement]
	Public Property Get XmlParametersRoot
		Set XmlParametersRoot = m_oXmlParametersRoot
	End Property
	
	'-------------------------------------------------------------------------------
	' Назначение:	Конструктор
	' Результат:    
	' Параметры:	
	' Примечание:	
	' Зависимости:	
	' Пример: 		
	Private Sub Class_Initialize
		' Создадим документ - владелец коллекции
		Set m_oXmlParametersRoot = _
			XService.XmlFromString( _
				"<?xml version=""1.0"" encoding=""windows-1251""?><params/>" )
	End Sub 
	
	'------------------------------------------------------------------------------
	'@@XmlParamCollectionBuilderClass.AppendParameter
	'<GROUP !!MEMBERTYPE_Methods_XmlParamCollectionBuilderClass><TITLE AppendParameter>
	':Назначение:	
	'   Реализация метода 
	'   <LINK IParamCollectionBuilder.AppendParameter, AppendParameter /> 
	'   интерфейса IParamCollectionBuilder.
    ':Параметры:
    '	sParameterName - [in] наименование параметра.
    '	vParameterText - [in] текстовое представление значения параметра или массив 
    '                          таких представлений.
	':Сигнатура:	
	'   Public Sub AppendParameter(sParameterName [As String], vParameterText [As Variant])
	Public Sub AppendParameter(sParameterName, vParameterText)
		Dim i
		If Not hasValue(sParameterName) Then Err.Raise -1, "XmlParamCollectionBuilderClass::AppendParameter", "Наименование параметра не задано"
		If IsArray(vParameterText) Then
			For i=0 To UBound(vParameterText)
				appendScalarParameter sParameterName, vParameterText(i)
			Next
		Else
			appendScalarParameter sParameterName, vParameterText
		End If
	End Sub
	
	'-------------------------------------------------------------------------------
	' Назначение:	Добавляет скалярные параметр или одно значение массивного параметра
	Private Sub appendScalarParameter(sParameterName, sParameterText)
		With m_oXmlParametersRoot.appendChild(m_oXmlParametersRoot.ownerDocument.createElement("param"))
			.SetAttribute "n", sParameterName
			If IsEmpty(sParameterText) Or IsNull(sParameterText) Then
				.text = ""
			Else
				.text = sParameterText
			End If
		End With
	End Sub
End Class


'===============================================================================
'@@QueryStringParamCollectionBuilderClass
'<GROUP !!CLASSES_x-utils><TITLE QueryStringParamCollectionBuilderClass>
':Назначение:	
'	Реализация интерфейса IParamCollectionBuilder. Поддерживает массивные параметры. 
':Примечание:	
'	Формирует строку вида: Name1=Value1&Name2=Value2&...&NameY=ValueY.
'
'@@!!MEMBERTYPE_Methods_QueryStringParamCollectionBuilderClass
'<GROUP QueryStringParamCollectionBuilderClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_QueryStringParamCollectionBuilderClass
'<GROUP QueryStringParamCollectionBuilderClass><TITLE Свойства>
Class QueryStringParamCollectionBuilderClass
	'-------------------------------------------------------------------------------
	' Назначение:	строка ограничений
	' Результат:    
	' Параметры:	
	' Примечание:	
	' Зависимости:	
	' Пример: 		
	Private m_sQueryString

	'------------------------------------------------------------------------------
	'@@QueryStringParamCollectionBuilderClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_QueryStringParamCollectionBuilderClass><TITLE QueryString>
	':Назначение:	
	'	Строка ограничений.
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get QueryString [As String]
	Public Property Get QueryString
		If IsEmpty(m_sQueryString) Then 
			QueryString = vbNullString
		Else
			QueryString = m_sQueryString
		End If	
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@QueryStringParamCollectionBuilderClass.AppendParameter
	'<GROUP !!MEMBERTYPE_Methods_QueryStringParamCollectionBuilderClass><TITLE AppendParameter>
	':Назначение:	
	'   Реализация метода 
	'   <LINK IParamCollectionBuilder.AppendParameter, AppendParameter /> 
	'   интерфейса IParamCollectionBuilder.
    ':Параметры:
    '	sParameterName - [in] наименование параметра.
    '	vParameterText - [in] текстовое представление значения параметра или массив 
    '                         таких представлений.
	':Сигнатура:	
	'   Public Sub AppendParameter(sParameterName [As String], vParameterText [As Variant])
	Public Sub AppendParameter(sParameterName, vParameterText)
		Dim i
		If Not hasValue(sParameterName) Then Err.Raise -1, "QueryStringParamCollectionBuilderClass::AppendParameter", "Наименование параметра не задано"
		If IsArray(vParameterText) Then
			For i=0 To UBound(vParameterText)
				appendScalarParameter sParameterName, vParameterText(i)
			Next
		Else
			appendScalarParameter sParameterName, vParameterText
		End If
		
	End Sub
	
	
	'-------------------------------------------------------------------------------
	' Назначение:	Добавляет скалярные параметр или одно значение массивного параметра
	Private Sub appendScalarParameter(sParameterName, sParameterText)
		If Not IsEmpty(m_sQueryString) Then
			m_sQueryString = m_sQueryString & "&"
		End If
		m_sQueryString = m_sQueryString & XService.UrlEncode(sParameterName) & "=" & XService.UrlEncode(sParameterText)
	End Sub
End Class


'===============================================================================
'@@X_DateToXmlType
'<GROUP !!FUNCTIONS_x-utils><TITLE X_DateToXmlType>
':Назначение:
'	Функция формирует для заданной даты/времени строку с представлением даты/времени 
'   в формате XML.
':Параметры:
'	dtValue - 
'       [in] исходная дата/время.
'	bAsDateOnly - 
'       [in] признак наличия в строке только даты (без времени).
':Результат:
'	Строка с форматированным значением.
':Примечание:	
'   Требует наличия XService!
':Сигнатура:
'   Function X_DateToXmlType(
'       dtValue [As Date],
'       bAsDateOnly [As Boolean]
'   ) [As String]
Function X_DateToXmlType( dtValue, bAsDateOnly )
	Dim oXml	' Временный XML
	X_DateToXmlType = vbNullString
	If IsNull(dtValue) Or IsEmpty(dtValue) Then Exit Function
	Set oXml = XService.XMLFromString("<DATE/>")
	If CBool(bAsDateOnly) Then
		oXml.dataType = "date"
	Else
		oXml.dataType = "dateTime.tz"
	End If
	oXml.nodeTypedValue = CDate(dtValue)
	X_DateToXmlType = oXml.text
End Function


'===============================================================================
'@@X_ConvertVarTypeToXmlNodeType
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ConvertVarTypeToXmlNodeType>
':Назначение:
'	Функция конвертирует тип свойства в XML XDR-тип.
':Параметры:
'	sVarType - 
'       [in] наименование типa свойства.
':Результат:
'	Строка с наименованием XML XDR-типа.
':Сигнатура:
'   Function X_ConvertVarTypeToXmlNodeType(
'       sVarType [As String]
'   ) [As String]
Function X_ConvertVarTypeToXmlNodeType(sVarType)
	Dim vVal
	Select Case sVarType
		Case "fixed":	vVal = "fixed.14.4"
		Case "time":	vVal = "time.tz"
		Case "dateTime":vVal = "dateTime.tz"
		Case "smallBin":vVal = "bin.base64"
		Case Else 		vVal = sVarType
	End Select
	X_ConvertVarTypeToXmlNodeType = vVal
End Function


'==============================================================================
' Облегчает создание экземпляра XObjectIdentity.
' ВНИМАНИЕ: ts при этом устанавливается в -1, 
' что на серверной стороне всегда трактуется как "игнорировать ts"
'	[in] sObjectType - наименование типа
'	[in] sObjectID - идентификатор типа
Function internal_New_XObjectIdentity(sObjectType, sObjectID)
	With New XObjectIdentity
		.m_sObjectType = sObjectType
		.m_sObjectID = sObjectID
		.m_vTS = -1
		Set internal_New_XObjectIdentity = .Self
	End With
End Function 


'==============================================================================
' Облегчает создание экземпляра XObjectPermission.
'	[in] sAction - действие - одна из констант: ACCESS_RIGHT_CHANGE, ACCESS_RIGHT_CREATE, ACCESS_RIGHT_DELETE
'	[in] sTypeName - наименование типа
'	[in] sObjectID - идентификатор типа
Function internal_New_XObjectPermission(sAction,sTypeName,sObjectID)
	With New XObjectPermission
		.m_sAction = sAction
		.m_sTypeName = sTypeName
		.m_sObjectID = sObjectID
		Set internal_New_XObjectPermission = .Self
	End With
End Function

'===============================================================================
'@@RunCommandDialogClass
'<GROUP !!CLASSES_x-utils><TITLE RunCommandDialogClass>
':Назначение:	
'	Класс, инкапсулирующий логику открытия и передачи параметров в диалог
'	задания параметров серверной команды.
'
'@@!!MEMBERTYPE_Methods_RunCommandDialogClass
'<GROUP RunCommandDialogClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_RunCommandDialogClass
'<GROUP RunCommandDialogClass><TITLE Свойства>
Class RunCommandDialogClass
	'---------------------------------------------------------------------------
	'@@RunCommandDialogClass.MetaName
	'<GROUP !!MEMBERTYPE_Properties_RunCommandDialogClass><TITLE MetaName>
	':Назначение:	Метаимя редактора/мастера.
	':Сигнатура:	
	'	Public MetaName [As String]
	Public MetaName			
	
	'---------------------------------------------------------------------------
	'@@RunCommandDialogClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_RunCommandDialogClass><TITLE QueryString>
	':Назначение:	Экземпляр класса QueryStringClass.
	':Сигнатура:	
	'	Public QueryString [As QueryStringClass]
	Public QueryString
	
	'---------------------------------------------------------------------------
	'@@RunCommandDialogClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_RunCommandDialogClass><TITLE ReturnValue>
	':Назначение:	Результирующее значение (может быть установлено из кода).
	':Сигнатура:	
	'	Public ReturnValue [As Variant]
	Public ReturnValue		

	'------------------------------------------------------------------------------
	'@@RunCommandDialogClass.GetRightsCache
	'<GROUP !!MEMBERTYPE_Methods_RunCommandDialogClass><TITLE GetRightsCache>
	':Назначение:	
	'	Функция возвращает уникальный глобальный экземпляр кеша прав, 
	'   ObjectRightsCacheClass.
	':Сигнатура:
	'	Public Function GetRightsCache [As ObjectRightsCacheClass]
	Public Function GetRightsCache
		Set GetRightsCache = X_RightsCache()
	End Function
	
	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		Set QueryString = X_GetEmptyQueryString
	End Sub

	'------------------------------------------------------------------------------
	'@@RunCommandDialogClass.Show
	'<GROUP !!MEMBERTYPE_Methods_RunCommandDialogClass><TITLE Show>
	':Назначение:	
	'	Процедура открывает диалоговое модальное окно с редактором.
    ':Примечание:
    '	Возвращает идентификатор созданного/отредактированного объекта,
    '   если редактор закрыт по нажатию кнопки <b>ОK</b>; иначе - Empty.
	':Сигнатура:
	'	Public Sub Show
	Public Sub Show
		' Откроем диалоговое окно редактора
		X_ShowModalDialogEx _
			XService.BaseUrl() & "x-command-executor.aspx?MetaName=" & MetaName & "&SCREENWIDTH=" & window.screen.availWidth & "&SCREENHEIGHT=" & window.screen.availHeight, Me, "help:no;center:yes;status:no"
	End Sub
End Class

'===============================================================================
'@@X_RunCommandUI
'<GROUP !!FUNCTIONS_x-utils><TITLE X_RunCommandUI>
':Назначение:
'	Процедура открывает диалог задания параметров серверной команды по метаимени 
'   элемента <b>i:command</b>.
':Параметры:
'	sMetaName - 
'       [in] метаимя элемента <b>i:command</b> (значение атрибута элемента <b>n</b>).
'	sUrlArguments - 
'       [in] строка с параметрами вызываемой серверной команды (в виде URL).
'	vReturnValue - 
'       [out] результат вызова диалога.
':Сигнатура:
'   Sub X_RunCommandUI( 
'       sMetaName [As String],
'       sUrlArguments [As String],
'       ByRef vReturnValue [As Variant]
'   ) 
Sub X_RunCommandUI(sMetaName, sUrlArguments, ByRef vReturnValue)
	With New RunCommandDialogClass
		.MetaName = sMetaName
		.QueryString.QueryString = sUrlArguments
		.Show
		If IsObject(.ReturnValue) Then
			Set vReturnValue = .ReturnValue
		Else
			vReturnValue = .ReturnValue
		End If	
	End With
End Sub


'===============================================================================
'@@AsynOperationExecutorClass
'<GROUP !!CLASSES_x-utils><TITLE AsynOperationExecutorClass>
':Назначение:	
'	Класс, инкапсулирующий логику передачи параметров в и выполнения асинхронной
'	команды
':Примечание:
'	В открываемое окно передается экземпляр данного класса. 
'	Для выполнения следует использовать функцию 
'	AsynOperationExecutorClass_Execute, передав в нее экземпляр данного класса. 
':См. также:
'	AsynOperationExecutorClass_Execute
'
'@@!!MEMBERTYPE_Methods_AsynOperationExecutorClass
'<GROUP AsynOperationExecutorClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_AsynOperationExecutorClass
'<GROUP AsynOperationExecutorClass><TITLE Свойства>
Class AsynOperationExecutorClass
	'@@AsynOperationExecutorClass.ShowProgress
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE ShowProgress>
	':Назначение:	Указывает необходимость указывать прогресс в процентах 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	'	Если индикатор прогресса заблокирован используется
	'	анимированный GIF x-execute-command-async.gif
	'   для генерации можно использовать http://www.ajaxload.info/
	'   или взять готовый отсюда http://www.napyfab.com/ajax-indicators/
	'		http://mentalized.net/activity-indicators/
	'		http://www.ajax.su/ajax_activity_indicators.html
	'		
	':Сигнатура:	Public ShowProgress [As Boolean]
	Public ShowProgress
	
	'@@AsynOperationExecutorClass.Request
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE Request>
	':Назначение:	Запрос на выполнение асинхронной команды 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	Public Request [As XRequest]
	Public Request
	
	'@@AsynOperationExecutorClass.Response
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE Response>
	':Назначение:	Результат выполнения асинхронной команды 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	Public Response [As XResponse]
	Public Response
	
	'@@AsynOperationExecutorClass.Aborted
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE Aborted>
	':Назначение:	Признак того что пользователь прервал выполнение команды  
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	Public Aborted [As Boolean]
	Public Aborted
	
	'@@AsynOperationExecutorClass.DialogHeight
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE DialogHeight>
	':Назначение:	Высота окна в пикселях 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	Public DialogHeight [As Long]
	Public DialogHeight
	
	'@@AsynOperationExecutorClass.DialogWidth
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE DialogWidth>
	':Назначение:	Ширина окна в пикселях 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	Public DialogWidth [As Long]
	Public DialogWidth
	
	'@@AsynOperationExecutorClass.DialogTitle
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE DialogTitle>
	':Назначение:	Заголовок диалога 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	Public Caption [As String]
	Public DialogTitle
	
	'@@AsynOperationExecutorClass.Caption
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE Caption>
	':Назначение:	Заголовок окна 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	'	Свойство может содержать HTML-код
	':Сигнатура:	Public Caption [As String]
	Public Caption	
	
	'@@AsynOperationExecutorClass.Self
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE Self>
	':Назначение:	 
	':Примечание:	
	':Сигнатура:	Public Property Get Self [As AsynOperationExecutorClass]
	Public Property Get Self
		Set Self = Me
	End Property
	
	
	
	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		ShowProgress = True
		Set Request = Nothing
		Caption = "Выполнение операции..."
		DialogTitle = Caption
		DialogWidth		=	400
		DialogHeight	=	280
	End Sub
End Class


'===============================================================================
'@@AsynOperationExecutorClass_Execute
'<GROUP !!FUNCTIONS_x-utils><TITLE AsynOperationExecutorClass_Execute>
':Назначение:
'	Функция открывает диалоговое модальное окно для выполнения асинхронной операции.
':Параметры:
'	oAsynOperationExecutor - 
'       [in] экземпляр AsynOperationExecutorClass.
':Примечание:
'	Функция вынесена из класса AsynOperationExecutorClass для того, чтобы не 
'	увеличивать стек объектных вызовов (из-за ошибки в VBScript-runtime, 
'	приводящей к "stack overflow at line 0").
':Сигнатура:
'   Function AsynOperationExecutorClass_Execute ( 
'       oAsynOperationExecutor [As AsynOperationExecutorClass]
'   ) [As Variant]
Sub AsynOperationExecutorClass_Execute(oAsynOperationExecutor)
	On Error GoTo 0
	oAsynOperationExecutor.Aborted = True
	Set oAsynOperationExecutor.Response = Nothing
	Dim vResult
	vResult = X_ShowModalDialogEx(XService.BaseURL & "x-execute-command-async.aspx?progress=" & iif(oAsynOperationExecutor.ShowProgress,1,0) & "&title=" & XService.UrlEncode("" & oAsynOperationExecutor.DialogTitle), oAsynOperationExecutor, "dialogWidth:" & oAsynOperationExecutor.DialogWidth & "px;dialogHeight:" & oAsynOperationExecutor.DialogHeight & "px;help:no;center:yes;status:no")

	If IsArray(vResult) Then
		If UBound(vResult) = 3 Then
			X_SetLastServerError vResult(0), vResult(1), vResult(2), vResult(3)
			X_GetLastError.Show
			Exit Sub
		End If
	End If
	X_ClearLastServerError
	If Not IsNothing(oAsynOperationExecutor.Response) Then
		' А теперь десериализуем ответ
		Dim oResponse
		Set oResponse = Eval("New " & oAsynOperationExecutor.Response.documentElement.tagName)
		Set oAsynOperationExecutor.Response = oResponse.Deserialize(oAsynOperationExecutor.Response.documentElement)
	End If
End Sub



'</SCRIPT>
