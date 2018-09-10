Option Explicit

Dim ug_sTitle

Sub usrXListPage_OnLoad(oSender, oEventArgs)
    
    '��������� ������������ ��������� ������
    ug_sTitle = oSender.Title
End Sub

Sub usrXList_OnAfterListReload(oSender, oEventArgs)
     Dim oResponse
     
     On Error Resume Next

     '���������� ������� �� � ����� � ��������� ������
     With New GetKassBallanceRequest
        .m_sName = "GetKassBallance"
        Set oResponse = X_ExecuteCommand(.Self)
    End With
    If Err Then
		If Not X_HandleError Then
            MsgBox "������ ��� ��������� �������� ����� � �������" & vbCr & Err.Description, vbCritical
		End If
    Else
        oSender.Container.Title = ug_sTitle & ". (� �����: " & oResponse.m_ssKassBallance & " ���.)"
	End If
End Sub