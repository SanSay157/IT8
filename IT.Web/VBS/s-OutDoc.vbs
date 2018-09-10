Option Explicit

'���������� ���� �������� "��������� ������"
Sub OutDoc_BudgetOut_ExecutionHandler(oSender, oEventArgs)
    Select Case oEventArgs.Action
		Case "DoSelectFromDb"
            ' �������������� ������ ������ ��������� ��������. ���������� ������ ������ �� ������� �������
            oEventArgs.Menu.Macros.Item("UrlParams") = ".Contract=" & oSender.ObjectEditor.GetProp("Contract").firstChild.getAttribute("oid")          
	End Select
    oSender.Internal_MenuExecutionHandler oSender, oEventArgs
End Sub

Sub usrXEditor_OnPageEnd(oSender, oEventArgs)
    With oSender
        .Pool.GetXmlProperty(.XmlObject, "Outcomes").RemoveAttribute "dirty"
        
        '�������� �������� ��� ������� ������� �������� ����������� ���������� �������� � ����� ������������� � ����������. ��� ���� ������ ������ �� 
        '��������� ������� �����������. ��� �������� � ������������ ������ � �������. �.�. ������� ������ �� ��������� �������� � ������ �������
        '������ �� ��������� �������
        If .GetProp("Contract").hasChildNodes And .GetProp("OutContract").hasChildNodes Then
            .Pool.RemoveRelation .XmlObject, "Contract", .Pool.GetXmlProperty(.XmlObject, "Contract").firstChild
        End If

        '����������� ����� ��������� ��������� �������� �� ���� ������ ���� �� ��������� �������� ���� ��������� ��������
        If (Not .GetProp("Contract").hasChildNodes) And (Not .GetProp("OutContract").hasChildNodes) Then
            oEventArgs.ReturnValue = False
	        oEventArgs.ErrorMessage = _
		    "��������!" & vbCrLf & _
		    vbCrLf & _
		    "� ���������� ���������� ��������� ������ �������������" & vbCrLf & _
		    "������ �� ��������� ��� ��������� ��������!"
        End If
    End With
End Sub