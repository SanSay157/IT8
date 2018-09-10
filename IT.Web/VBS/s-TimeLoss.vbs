Option Explicit

Dim g_oObjectEditor
Dim g_sCurrentSystemUserID	' Идентификатор текущего Пользователя

'==========================================================================
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	' Сохраним ссылку на экземпляр класса редактора объекта ObjectEditorClass
	Set g_oObjectEditor = oSender
	' сохраним ссылку идентификатор: SystemUser-текущий пользователь приложения
	g_sCurrentSystemUserID = GetCurrentUserProfile().SystemUserID
	' Добавим обработчик события AfterEnableControls для 1-ой (и единственной) стрнице редактора
	If g_oObjectEditor.IsObjectCreationMode Then
		g_oObjectEditor.Pages.Items()(0).EventEngine.AddHandlerForEvent "AfterEnableControls", Nothing, "OnAfterEnableControls_TrackRadio"
	End If
End Sub


'==========================================================================
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	Dim oXmlObjectCause
	If Not g_oObjectEditor.IsObjectCreationMode Then
		Set oXmlObjectCause = g_oObjectEditor.Pool.GetXmlObjectByOPath(g_oObjectEditor.XmlObject, "Cause")
		TrackTimeLossCause g_oObjectEditor.XmlObject, oXmlObjectCause, g_oObjectEditor.CurrentPage
	End If
End Sub


'==========================================================================
' Финальный обработчик после сбора данные перед сохранением
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	If g_oObjectEditor.IsObjectCreationMode Then
		' если режим списания за период, то обNULLим свойства Дата списания и Количество времени
		If document.all("LostTimeByPeriod").Checked Then
			g_oObjectEditor.XmlObject.selectSingleNode("LossFixed").text = ""
			g_oObjectEditor.XmlObject.selectSingleNode("LostTime").text = ""
		Else
			' иначе обNULLим свойства Дата начала диапазона, Дата окончания диапазона
			g_oObjectEditor.XmlObject.selectSingleNode("LossFixedStart").text = ""
			g_oObjectEditor.XmlObject.selectSingleNode("LossFixedEnd").text = ""
		End If
	End If
End Sub


'==========================================================================
' Обработчик события OnAfterEnableControls для редактора создания объекта - 
' устанавливает доступность контролов свойств Дата списания, Количество времени, Дата начала диапазона, Дата окончания диапазона
' (а также их обязательность) на основании состояния радио-кнопок
Sub OnAfterEnableControls_TrackRadio( oSender, oEventArgs )
	Dim oEditorPage		' As EditorPage
	Dim oPE_Date		' As XPEDateTime
	Dim oPE_Time		' As PETimeEditButtonClass
	Dim oPE_DateStart	' As XPEDateTime
	Dim oPE_DateEnd		' As XPEDateTime
	Dim bByDate
	
	Set oEditorPage = g_oObjectEditor.CurrentPage
	Set oPE_Date = oEditorPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("LossFixed") )
	Set oPE_Time = oEditorPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("LostTime") )
	Set oPE_DateStart = oEditorPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("LossFixedStart") )
	Set oPE_DateEnd   = oEditorPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("LossFixedEnd") )
	
	bByDate = document.all("LostTimeByDate").Checked
	If oEventArgs.Enable Then
		oEditorPage.EnablePropertyEditorEx oPE_Date, bByDate, True
		oEditorPage.EnablePropertyEditorEx oPE_Time, bByDate, True
		oPE_Date.Mandatory = bByDate 
		oPE_Time.Mandatory = bByDate
		oEditorPage.EnablePropertyEditorEx oPE_DateStart, document.all("LostTimeByPeriod").Checked, True
		oEditorPage.EnablePropertyEditorEx oPE_DateEnd, document.all("LostTimeByPeriod").Checked, True
		oPE_DateStart.Mandatory = Not bByDate
		oPE_DateEnd.Mandatory = Not bByDate
	End If
End Sub


'==============================================================================
' Обработчик радио-кнопок "На дату"/"За период"
Sub ChangeLossType_OnClick
	With New EnableControlsEventArgsClass
		.Enable = True
		OnAfterEnableControls_TrackRadio g_oObjectEditor, .Self()
	End With
End Sub
'==============================================================================
' Получение ограничений списка для заполнения комбобокса доступных причин списаний
Sub usr_TimeLoss_Cause_ObjectDropDown_OnGetRestrictions(oSender, oEventArgs)
	oEventArgs.ReturnValue = oEventArgs.ReturnValue & _
		"&SystemUserID=" & g_sCurrentSystemUserID & _
		"&Privileges=" & SYSTEMPRIVILEGES_MANAGETIMELOSS
End Sub

'==============================================================================
' Обработчик изменения причины списания
Sub usr_TimeLoss_Cause_OnChanging(oSender, oEventArgs)
	Dim oXmlObjectCause
	Dim nType
	Dim oPE					' Редактор свойства
	
	' Получим выбранный объект "Причина списания"
	Set oXmlObjectCause = oSender.ObjectEditor.Pool.GetXmlObject("TimeLossCause", oEventArgs.NewValue, Null)
	
	' В зависимости от типа установим обязательность и доступность поля Папка
	nType = oXmlObjectCause.selectSingleNode("Type").nodeTypedValue
	Set oPE = oSender.ParentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("Folder") )
	
	If nType = TIMELOSSCAUSETYPES_NOTAPPLICABLETOFOLDER Then
		' если в свойство Папка что-то выбрано, то предложим очистить, либо отказаться от изменения причины
		If Not IsNull(oPE.ValueID) Then
			If vbYes = MsgBox("Для выбранной причины списания не может быть указана ссылка на проект/тендер/пресейл." & vbCr & "Очистить (Yes) или вернуть предыдущее значение (No) ?", vbYesNo + vbQuestion) Then
				oPE.ValueID = Null
			Else
				' скажем, что надо вернуться на предыдущее значение
				oEventArgs.ReturnValue = False
				Exit Sub
			End If
		End If
	End If
	
	TrackTimeLossCause g_oObjectEditor.XmlObject, oXmlObjectCause, g_oObjectEditor.CurrentPage
End Sub


Sub TrackTimeLossCause(oXmlObject, oXmlObjectCause, oPage)
	Dim nType
	Dim oPE					' Редактор свойства
	
	' В зависимости от признака "Требует указания комментария" (CommentReq) установим обязательность поля Descr
	Set oPE = oPage.GetPropertyEditor( oXmlObject.selectSingleNode("Descr") )
	If Not oXmlObjectCause Is Nothing Then
	    oPE.Mandatory = oXmlObjectCause.selectSingleNode("CommentReq").nodeTypedValue
	Else
	    oPE.Mandatory = False
	End If
	
	' В зависимости от типа установим обязательность и доступность поля Папка
	If Not oXmlObjectCause Is Nothing Then _
	    nType = oXmlObjectCause.selectSingleNode("Type").nodeTypedValue
	Set oPE = oPage.GetPropertyEditor( oXmlObject.selectSingleNode("Folder") )
	Select Case nType
		Case TIMELOSSCAUSETYPES_MUSTAPPLICABLETOFOLDER
			If Not oPE.Enabled Then
				oPage.EnablePropertyEditorEx oPE, True, True
			End If
			oPE.Mandatory = True
		Case TIMELOSSCAUSETYPES_NOTAPPLICABLETOFOLDER
			oPE.Mandatory = False
			oPage.EnablePropertyEditorEx oPE, False, True
		Case TIMELOSSCAUSETYPES_APPLICABLETOFOLDER
			If Not oPE.Enabled Then
				oPage.EnablePropertyEditorEx oPE, True, True
			End If
			oPE.Mandatory = False
		Case Else
		    If Not oPE.Enabled Then
				oPage.EnablePropertyEditorEx oPE, True, True
			End If
			oPE.Mandatory = False
	End Select
End Sub
