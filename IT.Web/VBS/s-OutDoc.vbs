Option Explicit

'ќбработчик меню свойства "Ѕюджетный расход"
Sub OutDoc_BudgetOut_ExecutionHandler(oSender, oEventArgs)
    Select Case oEventArgs.Action
		Case "DoSelectFromDb"
            ' »нициализируем фильтр списка бюджетных расходов. ќтображаем статьи только по данному проекту
            oEventArgs.Menu.Macros.Item("UrlParams") = ".Contract=" & oSender.ObjectEditor.GetProp("Contract").firstChild.getAttribute("oid")          
	End Select
    oSender.Internal_MenuExecutionHandler oSender, oEventArgs
End Sub

Sub usrXEditor_OnPageEnd(oSender, oEventArgs)
    With oSender
        .Pool.GetXmlProperty(.XmlObject, "Outcomes").RemoveAttribute "dirty"
        
        '¬озможна ситуаци€ при которой сначала документ пренадлежит приходному договору а затем прикремп€етс€ к расходному. ѕри этом пр€ма€ ссылка на 
        'приходный договор сохран€етс€. Ёто приводит к дублированию данных в отчетах. “.о. удал€ем ссылку на приходный контракт в случае наличи€
        'ссылки на расходный договор
        If .GetProp("Contract").hasChildNodes And .GetProp("OutContract").hasChildNodes Then
            .Pool.RemoveRelation .XmlObject, "Contract", .Pool.GetXmlProperty(.XmlObject, "Contract").firstChild
        End If

        'Ќедопустимо чтобы проектный расходный документ не имел ссылки либо на расходный контракт либо приходный контракт
        If (Not .GetProp("Contract").hasChildNodes) And (Not .GetProp("OutContract").hasChildNodes) Then
            oEventArgs.ReturnValue = False
	        oEventArgs.ErrorMessage = _
		    "¬нимание!" & vbCrLf & _
		    vbCrLf & _
		    "” расходного проектного документа должна присутсвовать" & vbCrLf & _
		    "ссылка на расходный или приходный контракт!"
        End If
    End With
End Sub