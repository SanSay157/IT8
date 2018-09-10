Option Explicit

Const DATE_CALC_BUTTON_ID = "btnDateCalc"
Const DATE_CALC_PARENT_ID = "XEditor_xPaneSpecialCaption"

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	TMS_CreateDataCalcButton()
End Sub

'==============================================================================
' Создает кнопку вызова калькулятора дат
Sub TMS_CreateDataCalcButton()
	Dim oParent	' родительский HTML-элемент для вставки кнопки
	Dim oButton ' собственно HTML-объект кнопки
	' ищем родительский элемент для кнопки
	Set oParent = document.all(DATE_CALC_PARENT_ID)
	If oParent Is Nothing Then
		Err.Raise -1, "TMS_CreateDataCalcButton", "Не найден родительский элемент для кнопки"
	End If
		
	' если кнопка уже есть, ничего не делаем
	If Not oParent.all(DATE_CALC_BUTTON_ID) Is Nothing Then Exit Sub
		
	' создаем кнопку:
	Set oButton = document.createElement("BUTTON")
	If oButton Is Nothing Then
		Err.Raise -1, "TMS_CreateDateCalcButton", "Ошибка создания элемента BUTTON"
	End If
	
	' параметризуем кнопку
	oButton.id = DATE_CALC_BUTTON_ID
	oButton.className = "x-button x-button-control x-editor-button x-editor-button-control"
	oButton.style.width = "130px"
	oButton.value = "Калькулятор дат"
	oButton.attachEvent "onclick", GetRef("TMS_OpenDateCalcDialog")
	
	' вставляем кнопку в родительский элемент
	oParent.appendChild oButton
End Sub

'==============================================================================
' Открывает диалог вызова калькулятора дат
Sub TMS_OpenDateCalcDialog()
	window.showModelessDialog XService.BaseURL & "tms-date-calc.htm", _
		null, _
		"dialogHeight:150px;dialogWidth:300px;center:yes;resizable:no;status:no;help:no"
End Sub