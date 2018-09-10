Option Explicit

Dim g_oObjectEditor

'==============================================================================
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	' Сохраним ссылку на экземпляр класса редактора объекта ObjectEditorClass
	Set g_oObjectEditor = oSender
	' подпишемся на событие "AfterEnableControls" 1-ой страницы
	oSender.Pages.Items()(0).EventEngine.AddHandlerForEvent "AfterEnableControls", Nothing, "OnAfterEnableControls"
End Sub


'==============================================================================
' Назначение:	Обработчик события редактора PageStart
' Результат:    -
' Параметры:	oSender - объект, генерирующий событие; здесь - редактор объекта
'				oEventArgs - объект, описывающий параметры события, здесь Null
' Примечание:	Процедура-обработчик события вызывается по завершению "отрисовки"
'				страницы редактора; 
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	Dim bIsFilterSet		' Признак того, что в фильтре заданы данные
	Dim oButton 			' Ссылка на HTML-DOM объект кнопки "Установить"
	
	' Определяем ссылки на HTML-конопки и "навешиваем" обработчики соыбтия клика 
	With g_oObjectEditor.CurrentPage.HtmlDivElement
		' Кнопка "Установить (фильтр)"		
		Set oButton= .all.item("btnOpenFilterDialog")
		If Not(oButton Is Nothing) Then 
			Set oButton.onClick = GetRef("OnOpenFilterDialog")
		End If
		Set oButton = .all.item("btnCreateTimeLoss")
		If Not(oButton Is Nothing) Then 
			Set oButton.onClick = GetRef("OnCreateTimeLoss")
		End If
	End With
End Sub


'==============================================================================
' Назначение:	Обработчик события нажатия кнопки "Установить (фильтр)"
'				Вызывает "внешний" диалог редактирования временного объекта,
'				задающего параметры фильтра; при получении таких параметров
'				вызывает перерисовку страницы текущего редактора (фильтра в 
'				списке) и перезагрузку списка, зависимого от фильтра 
' Результат:    -
' Параметры:	-
Sub OnOpenFilterDialog()
	Dim oFilterDialog	' Параметры диалога редактора (временного объекта)
	Dim vResult			' Результат работы редактора 
	
	' Создаем служебный объект, задающий параметры диалога редактора:
	Set oFilterDialog = new ObjectEditorDialogClass
	' ...в вызываемый редактр передается объект данного редактора (через него 
	' осуществляется запись данных редактируемого временного объекта в общий пул):
	Set oFilterDialog.ParentObjectEditor = g_oObjectEditor
	' ...указываем при этом тип и идентификатор редактируемого объекта - это 
	' тот же объект, что отображается данным редактором:
	oFilterDialog.ObjectType = "FilterCurrentTaskList"
	oFilterDialog.ObjectID = g_oObjectEditor.ObjectID
	' ...указываем метанаименование описания редактора, используемого при 
	' построении интерфейса диалога (см. определения в метаданных):
	oFilterDialog.MetaName = "EditorInDialog"
	oFilterDialog.IsNewObject = true
	' Вызываем отображение диалога редактора:
	vResult = ObjectEditorDialogClass_Show(oFilterDialog)
	
	' Если получили в результате Empty, это означает, что редактор был закрыт
	' без внесения изменений (по кнопке "Отменить" или явно); в этом случае, 
	' ничего не изменяя, просто выходим из обработчика
	If Not hasValue(vResult) Then Exit Sub

	g_oObjectEditor.CurrentPage.SetData
	' Вызываем внутренний метод, приводящий к перегрузке списка, зависящего 
	' от фильтра:
	ReloadList
End Sub


'==============================================================================
Sub OnCreateTimeLoss
    Dim oTimeLossEditor
	Set oTimeLossEditor = New ObjectEditorDialogClass
	With oTimeLossEditor
		.IsNewObject = True 
		.IsAggregation = False
		Set .XmlObject = X_GetObjectFromServer("TimeLoss", Null, Null)
		.XmlObject.selectSingleNode("Worker").setAttribute "read-only", "1"
	End With	
		If hasValue(ObjectEditorDialogClass_Show(oTimeLossEditor)) Then
			' обновить табло несписанного времени
			g_oObjectEditor.ObjectContainerEventsImp.OuterContainerPage.ExecuteScript "ReloadUserCurrentExpensesPanel"
		End If
	
End Sub


'==============================================================================
' Назначение:	Явно генерирует событие скриптлета фильтра; внешний по отношению
'				к фильтру обработчик события (списка) перегружает по этому 
'				событию данные (списка)
Sub ReloadList()
	window.parent.ReloadList() 
End Sub


'==============================================================================
' Обработчик чекбокса "Сотращенный список инцидентов"
Sub usr_RestrictedList_Bool_OnChanged(oSender, oEventArgs)
	ReloadList
End Sub


'==============================================================================
' Обработчик события "AfterEnableControls" страницы
Sub OnAfterEnableControls(oSender, oEventArgs)
	document.all("btnOpenFilterDialog").disabled = Not oEventArgs.Enable
	document.all("btnCreateTimeLoss").disabled = Not oEventArgs.Enable
End Sub
