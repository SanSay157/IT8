Option Explicit

'Sub usrXEditor_OnPageStart(oSender, oEventArgs)
 '   With oSender
		
        '���� ������ �� �������� ��� �����, �� ��������� �������� ��� � ��� �������
  '      If .GetProp("Contract").hasChildNodes Or .GetProp("Loan").hasChildNodes Then
	'		.CurrentPage.EnablePropertyEditor .CurrentPage.GetPropertyEditor(oSender.GetProp("Code")), false
     '       .CurrentPage.EnablePropertyEditor .CurrentPage.GetPropertyEditor(oSender.GetProp("Year")), false
		'End If
    'End With
'End Sub

'���������� ���� �������� "��������� ������"
Sub Outcome_BudgetOut_MenuExecutionHandler(oSender, oEventArgs)
    Select Case oEventArgs.Action
		Case "DoSelectFromDb"
            ' �������������� ������ ������ ��������� ��������. ���������� ������ ������ �� ������� �������
            oEventArgs.Menu.Macros.Item("UrlParams") = ".Contract=" & oSender.ObjectEditor.GetProp("Contract").firstChild.getAttribute("oid")          
	End Select
    oSender.Internal_MenuExecutionHandler oSender, oEventArgs
End Sub