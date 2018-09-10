' Скрипт страницы выполнения асонхронной команды
Option Explicit

Const TIMEOUT = 500 ' Как часто будем "пулить" результат
Const RETRY_COUNT = 1000 ' Общее количество повторов в случае сбоев связи

Dim g_nRetryCount: g_nRetryCount = RETRY_COUNT			' Сколько повторов осталось
Dim g_sOperationID: g_sOperationID = Empty				' GUID операции
Dim g_nInterval: g_nInterval = Empty					' таймер
Dim g_bAbortedViaButton: g_bAbortedViaButton = False	' признак прерывания с помощью кнопки "Прервать"
Dim g_dtStart: g_dtStart = Now							' момент открытия окна

Sub Window_OnLoad
	dim oArgs
	X_GetDialogArguments oArgs
	MainPage_xPaneCaption.innerHTML = oArgs.Caption
	setPercent 0
	On Error Resume Next
	g_sOperationID = X_ExecuteCommandAsync(oArgs.Request)
	If X_WasErrorOccured Then
		setErrorResult
		closeWindow
		Exit Sub
	End If
	On Error GoTo 0
	setState "Выполнение..."
	updateTime	
	oArgs.Aborted = False
	document.all("MainPage_cmdCancel").Disabled = False
	setListener "checkState"
End Sub

'==========================================
' Отображение процента готовности
' [in] n As Long - готовность
Sub setPercent(n)
	Dim oArgs ' аргументы
	X_GetDialogArguments oArgs
	If oArgs.ShowProgress Then
		ProgressObject.SetState  0, 100, SafeCLng(n)
	End If
End Sub

'==========================================
' Отображение текущего состояния
' [in] s As String - состояние
Sub setState(s)
	document.all("objStatus",0).innerText = s
End Sub

'==========================================
' Отображение сколько времени прошло
' [in] s As String - состояние
Sub updateTime
	document.all("objTime",0).innerText = FormatDateTime(Now - g_dtStart, vbLongTime)
End Sub

'==========================================
' Установка обработчика таймера
' [in] s As String - наименование обработчика
Sub setListener(s)
	clearListener
	g_nInterval = window.SetInterval(s, TIMEOUT, "VBScript")
End Sub

'==========================================
' Закрытие окна
Sub closeWindow()
	g_sOperationID = Empty
	clearListener
	window.close
End Sub


'==========================================
' Возврат информации об ошибке в window.ReturnValue в виде массива
Sub setErrorResult()
	Dim oError	' As ErrorInfoClass
	Set oError = X_GetLastError
	If hasValue(oError) Then
		X_SetDialogWindowReturnValue Array(oError.LastServerError, oError.ErrNumber, oError.ErrSource, oError.ErrDescription)
	End If
End Sub


'==========================================
' Очистка обработчика таймера
Sub clearListener()
	If IsEmpty(g_nInterval) Then Exit Sub
	window.ClearInterval g_nInterval
	g_nInterval = Empty
End Sub


'==========================================
' Проверка статуса операции
Sub checkState()
	If IsEmpty(g_sOperationID) Then Exit Sub
	updateTime
	On Error Resume Next
	Dim oXmlResponse	' сериализованный Response
	Dim oResponse		' десериализованный Response
	Dim oArgs			' аргументы
	Set oXmlResponse = X_QueryCommandResultXml(g_sOperationID)
	If X_WasErrorOccured Then
		If X_GetLastError.IsServerError OR ( 0=g_nRetryCount ) Then
			setErrorResult
			closeWindow
			Exit Sub
		End If
		g_nRetryCount = g_nRetryCount - 1
		setState "Ошибка связи, попытка №" & ( RETRY_COUNT - g_nRetryCount )
	Else
		On Error GoTo 0
		' А теперь десериализуем ответ
		Set oResponse = Eval("New " & oXmlResponse.documentElement.tagName)
		oResponse.Deserialize(oXmlResponse.documentElement)

		setPercent oResponse.m_nPercentCompleted
		If "OK" = oResponse.m_sStatus Then
			' Сохраняем сериализованный ответ для тех, кто вызвал команду
			X_GetDialogArguments oArgs
			Set oArgs.Response = oXmlResponse
			setState "Выполнено"
			g_sOperationID = Empty
			setListener "closeWindow"
		End If
	End If
End Sub


'==========================================
' Закрытие окна кнопкой "прервать"
Sub MainPage_cmdCancel_OnClick
	If IsEmpty(g_sOperationID) Then
		closeWindow
	ElseIf vbYes = MsgBox("Операция находится в стадии выполнения. Прервать?", vbYesNo + vbDefaultButton2 + vbQuestion, "Подтвердите необходимость прервать операцию") Then
		clearListener
		g_bAbortedViaButton = True
		window.close
	End If
End Sub

'==========================================
' Обработка закрытия окна
Sub Window_OnUnload
	Dim oArgs			' аргументы
	document.all("MainPage_cmdCancel").Disabled = True
	clearListener
	If IsEmpty(g_sOperationID) Then
		Exit Sub
	End If
	X_GetDialogArguments oArgs
	oArgs.Aborted = True
	setState "Прерывание..."
	On Error Resume Next
	X_TerminateCommand g_sOperationID
	If X_WasErrorOccured Then
		setErrorResult
	End If
	g_sOperationID = Empty
End Sub

'==========================================
' Закрытие окна крестиком
Sub Window_OnBeforeUnload
	If g_bAbortedViaButton Then Exit Sub
	If IsEmpty(g_sOperationID) Then Exit Sub
	window.event.returnValue = "Операция находится в стадии выполнения. Прервать?"
End Sub
