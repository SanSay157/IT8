Option Explicit

Dim g_oObjectEditor	' Объект-редактор объекта (ObjectEditorClass)

' Регистрируем ДОБАВОЧНЫЙ обработчик системного события загрузки HTML-окна:
Call window.attachEvent( "onload", GetRef("AddButtonOnWindowLoad") )


'==============================================================================
' Добавим кнопку "Закрыть"
Sub AddButtonOnWindowLoad()
	' HTML-представление диалога редактора (но не страниц редактора!) на данный 
	' момент сформировано и доступно через HTML DOM: подменяем текст кнопки
	Dim oTD
	Set oTD = xBarControl1.Rows(0).insertCell(1)
	oTD.ID = "xCtrlPlace_cmdClose"
	oTD.innerHTML =_
					"<BUTTON ID='cmdClose' style='display:inline;' CLASS='x-button-wide'" & _
					"	TITLE='Сохранить и закрыть без перегрузки иерархии' LANGUAGE='VBScript' ONCLICK='cmdClose_onClick'>" & _
					"	<CENTER>Закрыть</CENTER></BUTTON>"
End Sub 


'==============================================================================
' Обработчик кнопки "Закрыть"
Sub cmdClose_onClick
	Dim vResult
	g_oObjectEditor.XmlObject.setAttribute "ts", SafeCLng(g_oObjectEditor.XmlObject.getAttribute("ts")) + 1
	vResult = g_oObjectEditor.Save
	If IsEmpty(vResult) Then Exit Sub
	' Всё замечательно - оставим контролы заблокированными
	' установим ReturnValue
	X_SetDialogWindowReturnValue Empty
	' И закроем окно
	window.Close
End Sub


'==============================================================================
' Обработчик "Load" редактора
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	' Сохраним ссылку на экземпляр класса редактора объекта ObjectEditorClass
	Set g_oObjectEditor = oSender
End Sub


'==============================================================================
' Обработчик "PageStart" редактора
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	trackModeChanged oSender.CurrentPage.GetPropertyEditor(oSender.XmlObject.selectSingleNode("Mode"))
	trackShowOrgWithoutActivities oSender.XmlObject.selectSingleNode("ShowOrgWithoutActivities").nodeTypedValue
End Sub


'==============================================================================
' Обработчик "Validate" редактора
Sub usrXEditor_OnValidate( oSender, oEventArgs )
	' если режим "Организации" и включен флаг "Отображать организации без активностей", то предупредим о возможной задержке
	If oSender.XmlObject.selectSingleNode("Mode").nodeTypedValue = DKPTREEMODES_ORGANIZATIONS Then
		If oSender.XmlObject.selectSingleNode("ShowOrgWithoutActivities").nodeTypedValue = True Then
			If vbNo = MsgBox("Выбранный режим (""все организации"") может привести к очень долгой загрузке иерархии. Продолжить?", vbYesNo + vbQuestion) Then
				oEventArgs.ReturnValue = False
			End If
		End If
	End If
End Sub


'==============================================================================
' Обработчик "Changed" PE свойства ShowOrgWithoutActivities ("Отображать организации без активностей")
Sub usr_ShowOrgWithoutActivities_Bool_OnChanged(oSender, oEventArgs)
	trackShowOrgWithoutActivities oEventArgs.NewValue
End Sub


'==============================================================================
' Устанавливает состояния флаго "Только мои активности" и "Только открытые активности" в зав-ти от флага "Организации без активностей"
Sub trackShowOrgWithoutActivities(bShowOrgWithoutActivitiesChecked)
	Dim oPE_OnlyOwnActivity
	Set oPE_OnlyOwnActivity  = g_oObjectEditor.CurrentPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("OnlyOwnActivity") )
	If Not Nothing Is oPE_OnlyOwnActivity Then
	    If bShowOrgWithoutActivitiesChecked Then
		    oPE_OnlyOwnActivity.Value = False
		    g_oObjectEditor.CurrentPage.EnablePropertyEditor oPE_OnlyOwnActivity, False
	    Else
		    g_oObjectEditor.CurrentPage.EnablePropertyEditor oPE_OnlyOwnActivity, True
	    End If
	End If
End Sub


'==============================================================================
' Обработчик "Changed" PE свойства Mode (Режим)
Sub usr_Mode_Selector_OnChanged(oSender, oEventArgs)
	trackModeChanged oSender
End Sub


'==============================================================================
'	[in] oModePE - PE свойства Mode (Режим)
Sub trackModeChanged(oModePE)
	Dim oPE
	Dim oPE_OnlyOwnActivity
	Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("ShowOrgWithoutActivities") )
	Set oPE_OnlyOwnActivity  = g_oObjectEditor.CurrentPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("OnlyOwnActivity") )
	If Not Nothing Is oPE And Not Nothing Is oPE_OnlyOwnActivity Then
	    If oModePE.Value = DKPTREEMODES_ORGANIZATIONS Then
		    ' Организации:
		    oPE_OnlyOwnActivity.LabelText = "Только организации с моими активностями"
		    ' Чекбокс "Отображать организации без активностей" сделаем доступным
		    oModePE.ParentPage.EnablePropertyEditor oPE, True
	    Else
		    ' Активности
		    oPE_OnlyOwnActivity.LabelText = "Только мои активности"
		    ' Чекбокс "Отображать организации без активностей" выключим и сделаем недоступным
		    oPE.Value = False
		    oModePE.ParentPage.EnablePropertyEditor oPE, False
	    End If
	End If
End Sub

Function CanAccessNotOwnActivities()
    CanAccessNotOwnActivities = GetScalarValueFromDataSource("CheckEmployeeAccessToNotOwnFolders", Array("Employee"), Array(GetCurrentUserProfile().EmployeeID))
End Function
