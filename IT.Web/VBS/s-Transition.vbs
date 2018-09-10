Option Explicit

Dim g_sIncidentTypeID


Sub usrXEditor_OnLoad(oSender, oEventArgs)
	If oSender.GetProp("From").HasChildNodes Then
		g_sIncidentTypeID = oSender.GetPropertyValue("From.IncidentType.ObjectID")
	ElseIf oSender.GetProp("To").HasChildNodes Then
		g_sIncidentTypeID = oSender.GetPropertyValue("To.IncidentType.ObjectID")
	ElseIf oSender.GetProp("Role").HasChildNodes Then
		g_sIncidentTypeID = oSender.GetPropertyValue("To.IncidentType.ObjectID")
	Else
		g_sIncidentTypeID = oSender.QueryString.GetValue("IncidentType", Empty)
	End If

	If Len(g_sIncidentTypeID & "") = 0 Then
		Err.Raise -1, "", "Должен быть задан идентификатор типа инцидента"
	End If
End Sub

Sub usr_Transition_From_ObjectDropDown_OnLoadList(oSender, oEventArgs)
	If oSender.ObjectEditor.MetaName <> "cool" Then Exit Sub
	oEventArgs.Cancel=True
	FillIncidentStateList oSender
End Sub

Sub usr_Transition_To_ObjectDropDown_OnLoadList(oSender, oEventArgs)
	If oSender.ObjectEditor.MetaName <> "cool" Then Exit Sub
	oEventArgs.Cancel=True
	FillIncidentStateList oSender
End Sub

Sub FillIncidentStateList(oPEObjectDropdown)
	Dim oStates		' список существующих состояний
	Dim oState		' состояние инцидента
	Dim sStateName	' наименование состояния инцидента
	' Очистим значение
	oPEObjectDropdown.ClearComboBox()
	With oPEObjectDropdown.ObjectEditor.Pool
		' Получим список существующих состояний
		Set oStates = .GetXmlProperty(.GetXmlObject( "IncidentType", g_sIncidentTypeID, "Roles States"),"States")
		For Each oState In oStates.SelectNodes("*")
			sStateName = .GetPropertyValue(oState, "Name")
			If HasValue( sStateName) Then
				oPEObjectDropdown.AddComboBoxItem oState.GetAttribute("oid"), sStateName
			End If	
		Next
	End With	
End Sub

Sub usr_Transition_Role_ObjectDropDown_OnLoadList(oPEObjectDropdown, oEventArgs)
	Dim oRoles		' список существующих состояний
	Dim oRole		' состояние инцидента
	Dim sRoleName	' наименование состояния инцидента
	
	If oPEObjectDropdown.ObjectEditor.MetaName <> "cool" Then Exit Sub
	oEventArgs.Cancel=True
	
	' Очистим значение
	oPEObjectDropdown.ClearComboBox()
	With oPEObjectDropdown.ObjectEditor.Pool
		' Получим список существующих ролей
		Set oRoles = .GetXmlProperty(.GetXmlObject( "IncidentType", g_sIncidentTypeID, "Roles States"),"Roles")
		For Each oRole In oRoles.SelectNodes("*")
			sRoleName = .GetPropertyValue(oRole, "Name")
			If HasValue( sRoleName) Then
				oPEObjectDropdown.AddComboBoxItem oRole.GetAttribute("oid"), sRoleName
			End If	
		Next
	End With
End Sub


Sub usr_Transition_From_ObjectDropDown_OnGetRestrictions(oSender, oEventArgs)
	oEventArgs.ReturnValue = "IncidentTypeID=" & g_sIncidentTypeID
End Sub

Sub usr_Transition_To_ObjectDropDown_OnGetRestrictions(oSender, oEventArgs)
	oEventArgs.ReturnValue = "IncidentTypeID=" & g_sIncidentTypeID
End Sub

Sub usr_Transition_Role_ObjectDropDown_OnGetRestrictions(oSender, oEventArgs)
	oEventArgs.ReturnValue = "IncidentType=" & g_sIncidentTypeID
End Sub