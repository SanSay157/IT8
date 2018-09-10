Option Explicit


'==============================================================================
' ѕроверки при сборе данных со страницы
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim oValueRoleA
	Dim oValueRoleB
	
	' ѕроверим, что в свойствах RoleA и RoleB ссылки на разные инциденты
	' ѕримечание: т.к. одно свойство задано при открытии, а другое всегда задано, т.к. оно not null, то дополнительных проверок не делаем
	Set oValueRoleA = oSender.XmlObject.selectSingleNode("RoleA").firstChild
	Set oValueRoleB = oSender.XmlObject.selectSingleNode("RoleB").firstChild
	If oValueRoleA.getAttribute("oid") = oValueRoleB.getAttribute("oid") Then
		oEventArgs.ErrorMessage = "—в€зь не может быть установлена между одним и тем же инцидентом"
		oEventArgs.ReturnValue = False
	End If
End Sub


