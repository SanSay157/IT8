Option Explicit


'==============================================================================
' Назначение:	Обработчик события редактора PageStart
' Результат:    -
' Параметры:	oSender - объект, генерирующий событие; здесь - редактор объекта
'				oEventArgs - объект, описывающий параметры события, здесь Null
' Примечание:	Процедура-обработчик события вызывается по завершению "отрисовки"
'				страницы редактора; 
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	trackStateOfDeadlineInNextDays oSender
End Sub


'==============================================================================
' Обработчик чекбокса "Инциденты с дедлайном"
Sub usr_IncidentsWithDeadline_Bool_OnChanged(oSender, oEventArgs)
	trackStateOfDeadlineInNextDays oSender.ObjectEditor
End Sub


'==============================================================================
' Обработчик чекбокса "Инциденты с просроченным дедлайном"
Sub usr_IncidentsWithExpiredDeadline_Bool_OnChanged(oSender, oEventArgs)
	Dim oPE
	
	trackStateOfDeadlineInNextDays oSender.ObjectEditor
	
	' при установке флага "Инциденты с просроченным дедлайном" - установим и задизейблим флаг "Инциденты с дедлайном"
	With oSender.ObjectEditor.CurrentPage
		Set oPE = .GetPropertyEditor(oSender.ObjectEditor.XmlObject.selectSingleNode("IncidentsWithDeadline"))
		If oEventArgs.NewValue Then
			oPE.Value = True
			If oPE.Enabled Then
				.EnablePropertyEditor oPE, False
			End If
		ElseIf Not oPE.Enabled Then
			.EnablePropertyEditor oPE, True
		End If
	End With
End Sub


'==============================================================================
Sub trackStateOfDeadlineInNextDays(oObjectEditor)
	Dim bDeadlineEditable
	Dim oPE

	With oObjectEditor.XmlObject
		bDeadlineEditable = .selectSingleNode("IncidentsWithDeadline").nodeTypedValue And Not .selectSingleNode("IncidentsWithExpiredDeadline").nodeTypedValue
	End With
	
	Set oPE = oObjectEditor.CurrentPage.GetPropertyEditor(oObjectEditor.XmlObject.selectSingleNode("DeadlineInNextDays"))
	
	If bDeadlineEditable <> oPE.Enabled Then
		oObjectEditor.CurrentPage.EnablePropertyEditor oPE, bDeadlineEditable
	End If
	If Not bDeadlineEditable Then
		oPE.Value = ""
	End If
	
	oDeadlineInNextDaysTitle.disabled = Not bDeadlineEditable
End Sub
