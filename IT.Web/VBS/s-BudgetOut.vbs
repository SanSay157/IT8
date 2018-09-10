Option Explicit

'Обработчик меню свойства "Расход"
Sub BudgetOut_Outcomes_MenuExecutionHandler(oSender, oEventArgs)
    Select Case oEventArgs.Action
		Case "DoSelectFromDb"
            ' Инициализируем фильтр списка бюджетных расходов. Отображаем статьи только по данному проекту
            oEventArgs.Menu.Macros.Item("UrlParams") = ".Contract=" & oSender.ObjectEditor.GetProp("Contract").firstChild.getAttribute("oid") 
        Case "DoCreate"
            oEventArgs.Menu.Macros.Item("UrlParams") = ".Contract=" & oSender.ObjectEditor.GetProp("InContract").firstChild.getAttribute("oid")         
	End Select
    oSender.Internal_MenuExecutionHandler oSender, oEventArgs
End Sub