Option Explicit

Dim ug_sTitle

Sub usrXListPage_OnLoad(oSender, oEventArgs)
    
    'Сохраняем оригинальный заголовок списка
    ug_sTitle = oSender.Title
End Sub

Sub usrXList_OnAfterListReload(oSender, oEventArgs)
     Dim oResponse
     
     On Error Resume Next

     'Показываем балланс ДС в кассе в заголовке списка
     With New GetKassBallanceRequest
        .m_sName = "GetKassBallance"
        Set oResponse = X_ExecuteCommand(.Self)
    End With
    If Err Then
		If Not X_HandleError Then
            MsgBox "Ошибка при получении балланса кассы с сервера" & vbCr & Err.Description, vbCritical
		End If
    Else
        oSender.Container.Title = ug_sTitle & ". (В кассе: " & oResponse.m_ssKassBallance & " руб.)"
	End If
End Sub