Option Explicit

'���������� ���� �������� "��������� ������"
Sub OutContract_BudgetOut_MenuExecutionHandler(oSender, oEventArgs)
    Select Case oEventArgs.Action
		Case "DoSelectFromDb"
            ' �������������� ������ ������ ��������� ��������. ���������� ������ ������ �� ������� �������
            oEventArgs.Menu.Macros.Item("UrlParams") = ".Contract=" & oSender.ObjectEditor.GetProp("Contract").firstChild.getAttribute("oid")          
	End Select
    oSender.Internal_MenuExecutionHandler oSender, oEventArgs
End Sub

'���������� ���� �������� "������"
Sub OutContract_Outcomes_MenuExecutionHandler(oSender, oEventArgs)
    Select Case oEventArgs.Action
        Case "DoCreate"
            oEventArgs.Menu.Macros.Item("UrlParams") = ".Contract=" & oSender.ObjectEditor.GetProp("Contract").firstChild.getAttribute("oid")         
	End Select
    oSender.Internal_MenuExecutionHandler oSender, oEventArgs
End Sub

Sub usrXEditor_OnPageEnd(oSender, oEventArgs)
    oSender.Pool.GetXmlProperty(oSender.XmlObject, "OutDocs").RemoveAttribute "dirty"
End Sub