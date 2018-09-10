Option Explicit

'=====================================================================
' ПОДКЛЮЧАЕТСЯ К СТРАНИЦАМ, ГЕНЕРИРУЕМЫМ С МАСТЕР-СТРАНИЦЕЙ "xu-transfer-error.master"

Dim g_bGoodButtonPressed	    ' показывает, что пользователь нажал одну из кнопок (а не закрыл окно нажатием на "крестик")
Dim g_bShowAreYouSureMsgBox     ' показывать ли мессадж-бокс "Вы уверены, что..."
g_bShowAreYouSureMsgBox = True  ' по умолчанию - показывать

'----------------------------------------------------------------------
' Инициализация страницы
Sub Window_OnLoad
	' ВНИМАНИЕ: из OnSpecialPageLoad вызывается функция Init2
	TransferServiceClient.OnSpecialPageLoad
End Sub

'----------------------------------------------------------------------
' Инициализация страницы - фаза 2
' Вызывается по полному окончанию загрузки страницы из OnSpecialPageLoad
Sub Init2
	dim aButtons            ' массив названий-id кнопок
	dim i,j
	dim oQueryStr           ' объект QueryString
	dim sAllowedActions     ' строка с перечислением идентификаторов допустимых операций
	dim aAllowedActions     ' массив идентификаторов допустимых операций
	dim aDelimeters         ' массив допустимых разделителей идентификаторов
	dim oCancelButton       ' кнопка "Прервать"
	
	' задаем допустимые разделители идентификаторов допустимых операций
	aDelimeters = Array(" ", ",", "|", ";")
	
	' вызов процедуры для заполнения html-элементов
	' CURRENT_DIALOG_TYPE - автогенерируемая константа (см. class XTransferServicePage)
	TransferServiceClient.FillTableInModalDialog CURRENT_DIALOG_TYPE 
	
	' делаем доступными кнопки
	aButtons = Array("XTransfer_cmdCancel", _
	    "XTransfer_ContentPlaceHolderForAdditionalButtons_cmdIgnore", _
	    "XTransfer_ContentPlaceHolderForAdditionalButtons_cmdIgnoreAll", _
	    "XTransfer_ContentPlaceHolderForAdditionalButtons_cmdRetry", _
	    "XTransfer_ContentPlaceHolderForAdditionalButtons_cmdSkip", _
	    "XTransfer_ContentPlaceHolderForAdditionalButtons_cmdReplace")
	for i = LBound(aButtons) to UBound(aButtons)
	    if not document.all(aButtons(i)) Is nothing then document.all(aButtons(i)).disabled = false
	next
	
	' получаем объект QueryString
	set oQueryStr = X_GetQueryString
	' пробуем получить массив идентификаторов допустимых операций
	' если соответствующий параметр не задан, оставляем кнопки без изменений
	if not oQueryStr is nothing then
	    sAllowedActions = oQueryStr.GetValue("ALLOWEDACTIONS", "")
	    if sAllowedActions <> "" then
	        for i = LBound(aDelimeters) to UBound(aDelimeters)
	            aAllowedActions = Split(sAllowedActions, aDelimeters(i), -1)
	            ' если удалось разбить строку используя текущий разделитель, прерываем цикл
	            if IsArray(aAllowedActions) then
	                if sAllowedActions <> aAllowedActions(0) then exit for
	            end if
	        next
	    end if
	end if
	' ищем и оставляем видимыми и доступными только кнопки с перечисленными в массиве идентификаторами
	if IsArray(aAllowedActions) then
	    for i = LBound(aButtons) to UBound(aButtons)
	        Dim bShowButton     ' показывать ли текущую кнопку
	        bShowButton = false
	        for j = LBound(aAllowedActions) to UBound(aAllowedActions)
	            if InStrRev(aButtons(i), aAllowedActions(j)) _
	               = Len(aButtons(i)) - Len(aAllowedActions(j)) + 1 then
	                bShowButton = true
	                exit for
	            end if
	        next
	        ' скрываем и отключаем кнопку
	        if not bShowButton and not document.all(aButtons(i)) is nothing then
	            document.all(aButtons(i)).disabled = true
	            document.all(aButtons(i)).style.display = "none"
	        end if
	    next
	    ' Если доступна только одна кнопка "Прервать", то спрашивать
	    ' пользователя, уверен ли он, нужды нет
	    g_bShowAreYouSureMsgBox = not (UBound(aAllowedActions) = 0 and _
	                                   aAllowedActions(0) = "cmdCancel")
	end if
	
	g_bGoodButtonPressed = false
	
	' устанавливаем фокус на "Прервать", если она видима и не отключена
	Set oCancelButton = document.all("XTransfer_cmdCancel")
	if not oCancelButton is nothing _
	   and oCancelButton.disabled = false _
	   and oCancelButton.style.display = "" then
	    oCancelButton.focus
	end if
End Sub

'----------------------------------------------------------------------
' Вызывается при попытке закрыть окно
Sub Window_onBeforeUnload()
	If False = g_bGoodButtonPressed Then 
		X_SetDialogWindowReturnValue WINDOW_RESULT_IGNORE
	End If
End Sub

'----------------------------------------------------------------------
' Обработка клавиатуры
Sub Document_onKeyPress()
	If VK_ESC = window.event.keyCode Then
		' при нажатии Esc срабатывает кнопка "Игнорировать"
		XTransfer_cmdIgnore_OnClick
	End If
End Sub

'----------------------------------------------------------------------
' обработчики нажатий кнопок
Sub XTransfer_ContentPlaceHolderForAdditionalButtons_cmdIgnore_OnClick()
	X_SetDialogWindowReturnValue WINDOW_RESULT_IGNORE
	g_bGoodButtonPressed = True
	window.close 
End Sub

Sub XTransfer_ContentPlaceHolderForAdditionalButtons_cmdIgnoreAll_OnClick()
	X_SetDialogWindowReturnValue WINDOW_RESULT_IGNOREALL
	g_bGoodButtonPressed = True
	window.close 
End Sub

Sub XTransfer_ContentPlaceHolderForAdditionalButtons_cmdRetry_OnClick()
	X_SetDialogWindowReturnValue WINDOW_RESULT_RETRY
	g_bGoodButtonPressed = True
	window.close 
End Sub

Sub XTransfer_ContentPlaceHolderForAdditionalButtons_cmdSkip_OnClick()
	X_SetDialogWindowReturnValue WINDOW_RESULT_SKIP
	g_bGoodButtonPressed = true
	window.close 
End Sub

Sub XTransfer_ContentPlaceHolderForAdditionalButtons_cmdReplace_OnClick()
	X_SetDialogWindowReturnValue WINDOW_RESULT_REPLACE
	g_bGoodButtonPressed = true
	window.close 
End Sub


Sub XTransfer_cmdCancel_OnClick()
    Dim bCancelProcess      ' прерывать ли процесс
    
    ' Определяем, нужно ли прерывать процесс
    If g_bShowAreYouSureMsgBox Then
        ' Спрашиваем пользователя, уверен ли он
        bCancelProcess = (TransferServiceClient.AreYouSure_MsgBox() = vbYes)
    Else
        ' Спрашивать не надо
        bCancelProcess = True
    End If
    ' Если нужно, прерываем процесс
	If bCancelProcess Then
		X_SetDialogWindowReturnValue WINDOW_RESULT_CANCEL
		g_bGoodButtonPressed = True
		window.close 
	End If
End Sub
