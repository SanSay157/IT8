Option Explicit

'Sub usrXEditor_OnPageStart(oSender, oEventArgs)
 '   With oSender
		
        'Если расход по договору или займу, то блокируем отчетный год и код расхода
  '      If .GetProp("Contract").hasChildNodes Or .GetProp("Loan").hasChildNodes Then
	'		.CurrentPage.EnablePropertyEditor .CurrentPage.GetPropertyEditor(oSender.GetProp("Code")), false
     '       .CurrentPage.EnablePropertyEditor .CurrentPage.GetPropertyEditor(oSender.GetProp("Year")), false
		'End If
    'End With
'End Sub

'Обработчик меню свойства "Бюджетный расход"
Sub Outcome_BudgetOut_MenuExecutionHandler(oSender, oEventArgs)
    Select Case oEventArgs.Action
		Case "DoSelectFromDb"
            ' Инициализируем фильтр списка бюджетных расходов. Отображаем статьи только по данному проекту
            oEventArgs.Menu.Macros.Item("UrlParams") = ".Contract=" & oSender.ObjectEditor.GetProp("Contract").firstChild.getAttribute("oid")          
	End Select
    oSender.Internal_MenuExecutionHandler oSender, oEventArgs
End Sub