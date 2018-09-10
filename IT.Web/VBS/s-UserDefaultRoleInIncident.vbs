Option Explicit
' Редактор объекта "Роль пользователя в инциденте по умолчанию"
' Редактор может открываться по любой из трех ссылок: Тип инцидента, Роль в инциденте, Роль пользователя в папке,
' и в каждом из этих случаев одна из ссылок будет задана снаружи, а соответствующий PE отсутствовать

'==============================================================================
Sub usr_IncidentType_ObjectDropDown_OnChanged(oSender, oEventArgs)
	Dim oPE
	Set oPE = oSender.ParentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("UserRoleInIncident") )
	oPE.ValueID = Null
	oPE.Reload
End Sub


'==============================================================================
' 
Sub usr_UserRoleInIncident_ObjectDropDown_OnGetRestrictions(oSender, oEventArgs)
	Dim sIncidentTypeID
	sIncidentTypeID = getIncidentTypeID(oSender.ObjectEditor)
	If Not IsNull(sIncidentTypeID) Then
		oEventArgs.ReturnValue = "IncidentType=" & sIncidentTypeID
	End If
End Sub


'==============================================================================
' Возвращает идентификатор текущего типа инцидента
Function getIncidentTypeID(oObjectEditor)
	Dim oPE
	Dim oXmlProp
	getIncidentTypeID = Null
	
	Set oXmlProp = oObjectEditor.XmlObject.selectSingleNode("IncidentType")
	If oXmlProp.hasChildNodes Then
		' тип инцидента задан
		getIncidentTypeID = oXmlProp.firstChild.getAttribute("oid")
	Else
		Set oPE = oObjectEditor.CurrentPage.GetPropertyEditor( oXmlProp )
		If Not oPE Is Nothing Then
			getIncidentTypeID = oPE.ValueID
		End If
	End If
End Function
