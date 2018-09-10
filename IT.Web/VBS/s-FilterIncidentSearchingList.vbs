Option Explicit

Dim g_oFilterXmlObject
Dim g_bFilterDKPInitialized
Dim g_oObjectEditor


'==============================================================================
' Обработчик события Load только для мастера 
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Set g_oObjectEditor = oSender
    setUpXmlObjectOfFoldersTreeFilter oSender
	
End Sub


'==============================================================================
Sub setUpXmlObjectOfFoldersTreeFilter(oObjectEditor)
	Dim oProp
	
	Set oProp = oObjectEditor.XmlObject.selectSingleNode("virtual-prop-filter")
	If oProp Is Nothing Then
		Set oProp = oObjectEditor.XmlObject.appendChild( oObjectEditor.XmlObject.ownerDocument.createElement("virtual-prop-filter") )
	End If
	Set g_oFilterXmlObject = oProp.firstChild
	If g_oFilterXmlObject Is Nothing Then
		' Создадим в пуле временный объект для отрисовки фильтра для дерева выбора папки
		Set g_oFilterXmlObject = oObjectEditor.Pool.CreateXmlObjectInPool( "FilterDKP" )
		' Положим объект фильтра в виртуальное свойство Инцидента
		 oProp.appendChild X_CreateStubFromXmlObject(g_oFilterXmlObject)
	Else
		Set g_oFilterXmlObject = oObjectEditor.Pool.GetXmlObjectByXmlElement(g_oFilterXmlObject, Null)
	End If
End Sub


'==============================================================================
'	[in] oEventArgs As EditorStateChangedEventArgs
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	g_bFilterDKPInitialized = True
End Sub


'==============================================================================
' [in] oSender As XPEObjectTreeSelectorClass
' [in] oEventArgs As GetRestrictionsEventArgsClass
Sub usr_FilterIncidentSearchingList_Folders_ObjectsTreeSelector_OnGetRestrictions(oSender, oEventArgs)
	Dim oBuilder
	Dim oProp
	
	Set oBuilder = New QueryStringParamCollectionBuilderClass
	' по всем свойствам временного объекта-фильтра 
	For Each oProp In g_oFilterXmlObject.selectNodes("*")
		If Not IsNull(oProp.dataType) Then
			If 0 < Len(oProp.text) Then
				oBuilder.AppendParameter oProp.tagName, oProp.text
			End If	 
		End If	 
	Next
	oEventArgs.ReturnValue = oBuilder.QueryString
End Sub


'==============================================================================
' Обработчик кнопки "Настроить" фильтра по проекту (свойство Folders)
Sub btnOpenFilterOfFoldersTree_onClick
	Dim oFilterDialog	' Параметры диалога редактора (временного объекта)
	Dim vResult			' Результат работы редактора 
	Dim nOldTS			' ts до вызова редактора в диалге
	Dim oPE
	
	' Создаем служебный объект, задающий параметры диалога редактора:
	Set oFilterDialog = new ObjectEditorDialogClass
	' ...в вызываемый редактр передается объект данного редактора (через него 
	' осуществляется запись данных редактируемого временного объекта в общий пул):
	Set oFilterDialog.ParentObjectEditor = g_oObjectEditor
	' ...указываем при этом тип и идентификатор редактируемого объекта - это 
	' тот же объект, что отображается данным редактором:
	Set oFilterDialog.XmlObject = g_oFilterXmlObject
	' ...указываем метанаименование описания редактора, используемого при 
	' построении интерфейса диалога (см. определения в метаданных):
	oFilterDialog.MetaName = "EditorInDialog"
	
	nOldTS = SafeCLng(g_oFilterXmlObject.getAttribute("ts"))
	
	' Вызываем отображение диалога редактора:
	vResult = ObjectEditorDialogClass_Show(oFilterDialog)
	
	Set g_oFilterXmlObject = g_oObjectEditor.Pool.Xml.selectSingleNode("FilterDKP")

	If ( nOldTS <> SafeCLng(g_oFilterXmlObject.getAttribute("ts")) ) Then
		' изменился ts объекта. Это значит в диалоге нажали кнопку "Закрыть"
		updateTreeModeDescription
	Else
		' Если получили в результате Empty, это означает, что редактор был закрыт
		' без внесения изменений (по кнопке "Отменить" или явно); в этом случае, 
		' ничего не изменяя, просто выходим из обработчика
		If Not hasValue(vResult) Then Exit Sub

		updateTreeModeDescription		
		
		' Вызываем внутренний метод, приводящий к перегрузке списка, зависящего 
		' от фильтра:
		Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Folders"))
		oPE.Load
	End If
End Sub


'==============================================================================
' Обработчик кнопки "Очистить" фильтра по проекту (свойство Folders)
Sub btnClearFilterOfFoldersTree_onClick
	Dim oPE
	
	' Очистим свойство "Папки"
	g_oObjectEditor.XmlObject.selectNodes("Folders/*").removeAll
	' Удалим объект фильтра
	With g_oObjectEditor
		.XmlObject.selectSingleNode("virtual-prop-filter").selectNodes("*").removeAll
		g_oFilterXmlObject.parentNode.removeChild g_oFilterXmlObject
		Set g_oFilterXmlObject = Nothing
	End With
	' и заново создадим
	setUpXmlObjectOfFoldersTreeFilter g_oObjectEditor
	' и перегрузим иерархию папок
	Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Folders"))
	oPE.Load
End Sub


Sub updateTreeModeDescription
End Sub


'==============================================================================
' Назначение:	Обработчик события редактора PageStart
' Результат:    -
' Параметры:	oSender - объект, генерирующий событие; здесь - редактор объекта
'				oEventArgs - объект, описывающий параметры события, здесь Null
' Примечание:	Процедура-обработчик события вызывается по завершению "отрисовки"
'				страницы редактора; 
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	trackStateOfDeadlineDates oSender
	trackParticipantsTree oSender
End Sub


'==============================================================================
' Обработчик чекбокса "Инциденты с дедлайном"
Sub usr_IncidentsWithDeadline_Bool_OnChanged(oSender, oEventArgs)
	trackStateOfDeadlineDates oSender.ObjectEditor
End Sub


'==============================================================================
' Обработчик чекбокса "Инциденты с просроченным дедлайном"
Sub usr_IncidentsWithExpiredDeadline_Bool_OnChanged(oSender, oEventArgs)
	Dim oPE
	trackStateOfDeadlineDates oSender.ObjectEditor
	
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
Sub trackStateOfDeadlineDates(oObjectEditor)
	Dim oPE
	Dim bEnableDeadlineDates
	
	With oObjectEditor.XmlObject
		If Nothing Is oObjectEditor.CurrentPage.GetPropertyEditor(.selectSingleNode("DeadlineDateBegin")) Then Exit Sub
		bEnableDeadlineDates = .selectSingleNode("IncidentsWithDeadline").nodeTypedValue And Not .selectSingleNode("IncidentsWithExpiredDeadline").nodeTypedValue
	End With
	
	With oObjectEditor.CurrentPage
		Set oPE = .GetPropertyEditor(oObjectEditor.XmlObject.selectSingleNode("DeadlineDateBegin"))
		If bEnableDeadlineDates <> oPE.Enabled Then
			.EnablePropertyEditor oPE, bEnableDeadlineDates
		End If
		If Not bEnableDeadlineDates Then
			oPE.Value = Null
		End If

		Set oPE = .GetPropertyEditor(oObjectEditor.XmlObject.selectSingleNode("DeadlineDateEnd"))
		If bEnableDeadlineDates <> oPE.Enabled Then
			.EnablePropertyEditor oPE, bEnableDeadlineDates
		End If
		If Not bEnableDeadlineDates Then
			oPE.Value = Null
		End If
	End With
End Sub

'==============================================================================
'При загрузке страницы редактора блокирует или разблокировывает иерархию выбора  исполнителей в 
'в зависисмости от значения признака ExceptParticipants ("Исполнители не заданы") фильтра
Sub trackParticipantsTree(oObjectEditor)
	Dim oPE
	Dim bExceptParticipants
	
	With oObjectEditor.XmlObject
		If Nothing Is oObjectEditor.CurrentPage.GetPropertyEditor(.selectSingleNode("Participants")) Then Exit Sub
		bExceptParticipants = .selectSingleNode("ExceptParticipants").nodeTypedValue
	End With
	
	With oObjectEditor.CurrentPage
		Set oPE = .GetPropertyEditor(oObjectEditor.XmlObject.selectSingleNode("Participants"))
		If bExceptParticipants <> Not oPE.Enabled Then
			oPE.Enabled = Not bExceptParticipants
		End If
	End With
End Sub

'==============================================================================
' Обработчик чекбокса "Исполнители не заданы"
Sub usr_ExceptParticipants_Bool_OnChanged(oSender, oEventArgs)
	Dim oPE
	
	' при установке флага "Исполнители не заданы" - задизейблим иерархию выбора  исполнителей
	' при снятии наооборот сделаем доступным
	With oSender.ObjectEditor.CurrentPage
		Set oPE = .GetPropertyEditor(oSender.ObjectEditor.XmlObject.selectSingleNode("Participants"))
		If oEventArgs.NewValue=True Then
		.EnablePropertyEditorEx oPE, False,True
		Else 
		.EnablePropertyEditorEx oPE, True,True
		End If
	End With
	
End Sub
