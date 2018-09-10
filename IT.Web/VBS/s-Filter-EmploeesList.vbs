' Обработчик фильтра списка "Сотрудники"

'==============================================================================
' Выбор Oтдела
Sub usr_FilterEmployeesList_ByDepartment_OnGetRestrictions(oSender, oEventArgs)
    Dim oOrganization
    Set oOrganization = oSender.ObjectEditor.XmlObject.selectSingleNode("ByOrganization/Organization" )
    If ( Not oOrganization is Nothing) Then
        oEventArgs.ReturnValue = "OrganizationID=" & oOrganization.getAttribute("oid")
    Else 
        oEventArgs.ReturnValue = "OrganizationID=" & GUID_EMPTY  
    End If 
    stop
End Sub
