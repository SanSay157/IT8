Option Explicit

'==============================================================================
' Обработчик выбора инцидента - ограничивает тип выбираемых узлов
Sub usr_ObjectPresentation_OnBeforeSelect(oSender, oEventArgs)
	oEventArgs.UrlArguments = oEventArgs.UrlArguments & "&selectable-types=Incident" 
End Sub

'==============================================================================
Sub usrXEditor_OnSetCaption(oSender, oEventArgs)
	Dim oParentProp
	Dim sOwnerOID
	Dim sCaptionHTML
	
	Set oParentProp = oSender.ParentXmlProperty
	If oParentProp Is Nothing Then
		oEventArgs.EditorCaption = "Редактирование связи между инцидентами"
	Else
		' Если родительский инцидент в роли А, значит ссылка от него, иначе на него
		sOwnerOID = oParentProp.parentNode.getAttribute("oid")
		If Not oSender.XmlObject.selectSingleNode("RoleA/Incident[@oid='" & sOwnerOID & "']") Is Nothing Then
			sCaptionHTML = "Ссылка на инцидент"
		Else
			sCaptionHTML = "Ссылка со стороны инцидента"
		End If
		oEventArgs.EditorCaption = sCaptionHTML
	End If
End Sub
