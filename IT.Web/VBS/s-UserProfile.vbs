'*******************************************************************************
' Подсистема:	Редактор/Мастер Профиля пользовтеля (персональные настройки)
' Назначение:	
'*******************************************************************************
Option Explicit

Dim g_oShowExpensesPanel	' PE свойства ShowExpensesPanel (экземпляр XPEBoolClass)
Dim g_oAutoUpdateDelay		' PE свойства ExpensesPanelAutoUpdateDelay (XPEStringClass)
Dim g_oStartPage            ' PE свойства StartPage (XPESelectorComboClass) 

'==============================================================================
' Обработчик события загрузки первой страницы мастера / редактора
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
    Dim resultRight 'результат проверки  наличия у текущего пользователя системной привилегии доступа в систему СУТ (true или false)
    	' Сохраним ссылки на экземпляры PE, обслуживающие свойства "Отображать 
	' панель" и "Период автообновления панели" - дальше работать с PE будем
	' используя эти ссылки
	With oSender
		Set g_oShowExpensesPanel = .CurrentPage.GetPropertyEditor( .GetProp("ShowExpensesPanel") )
		Set g_oAutoUpdateDelay = .CurrentPage.GetPropertyEditor( .GetProp("ExpensesPanelAutoUpdateDelay") )
		Set g_oStartPage = .CurrentPage.GetPropertyEditor( .GetProp("StartPage"))
	End with
	
	'Проверяем может ли текущий пользователь создать объект типа Лот(для этого должна быть системная привилегия - доступ в систему СУТ)
	resultRight = X_CheckObjectRights ("Lot",Empty,"Create")
	'Если нет, то уберем  из combobox стартовой страницы элементы,относящиеся к системе СУТ (два последних)
	If Not(resultRight) Then
	   g_oStartPage.HtmlElement.children(4).RemoveNode True
	   g_oStartPage.HtmlElement.children(4).RemoveNode True
	End If
	   
	' Явно подписываемся на HTML-DOM-событие (PE такое событие не отслеживает,
	' а нам - надо):
	g_oAutoUpdateDelay.HtmlElement.attachEvent "onchange", GetRef("chechAutoUpdateDelay")
	
	' Принудительно вызываем внутреннюю процедуру, корректирующую досутпность
	' элементов / полей ввода в зависимости от данных:
	checkAvailability
	
	
End Sub


'==============================================================================
' Событие изменения значения PE, отражающего свойство "ShowExpensesPanel"
Sub usr_ShowExpensesPanel_Bool_OnChanged( oSender, oEventArgs )
	If Not(oSender.Value) Then
		g_oAutoUpdateDelay.Value = 0
		g_oAutoUpdateDelay.SetData
	End If
	checkAvailability
End Sub


'==============================================================================
' Событие изменения флажка "Автоматическое обновление" (обработчик явно 
' определен в XSL, для прикладного эленмент INPUT TYPE="checkbox")
Sub AutoUpdateOn_OnChanged()
	If (document.all("inpAutoUpdateOn").checked) Then
		If (0 = g_oAutoUpdateDelay.Value) Then g_oAutoUpdateDelay.Value = 1
		checkAvailability
		g_oAutoUpdateDelay.HtmlElement.Focus
		g_oAutoUpdateDelay.HtmlElement.Select
	Else 
		g_oAutoUpdateDelay.Value = 0
	End If
End Sub


'==============================================================================
' Внутренняя процедура, корректирующая доступность элементов интерфейса. 
' Реализует следующие правила:
'	- если флаг "Отображать панель" сброшен, то флаг "Включить автообновление"
'		и поле "Период автообновления" - заблокированы
'	- если флаг "Включить автообновление" заблокирован, то и поле "Период 
'		автообновления" заблокировано для ввода
'	- если значение "Период автообновления" отлично от нуля, то флаг установлен
Sub checkAvailability()
	document.all("inpAutoUpdateOn").disabled = Not CBool( g_oShowExpensesPanel.Value )
	g_oAutoUpdateDelay.Enabled = Not CBool(document.all("inpAutoUpdateOn").disabled )
	document.all("inpAutoUpdateOn").checked = CBool(0<>g_oAutoUpdateDelay.Value)
End sub


'==============================================================================
' Спц. обработчик перехода ИЗ поля ввода "Период обновления" куда-то еще: 
' если в этот момент значение поля установлено в 0, то принудительно снимаем
' флаг "Автообновление включено" (т.к. 0 == выключено)
Sub chechAutoUpdateDelay()
	If (0 = g_oAutoUpdateDelay.Value) Then 
		' ... что, в свою очередь, вызовет обработчик события изменения 
		' состояния check-box-а, AutoUpdateOn_OnChanged
		document.all("inpAutoUpdateOn").checked = false
	End If
End Sub

