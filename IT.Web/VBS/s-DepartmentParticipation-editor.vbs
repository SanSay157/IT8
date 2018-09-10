Option Explicit

'==============================================================================
Dim ObjectEditor			' Редактор объекта
Dim Pool					' Пул объектов
Dim DepartmentEditor		' Редактор свойства "Подразделение"
Dim ExecutorEditor			' Редактор свойства "Сотрудник от подразделения"
Dim IsAcquaintEditor		' Редактор свойства "Ознакомился"
Dim DateEditor				' Редактор свойства "Дата"
Dim ExecutorHandlerClass	' Класс управления отображением редакторов, 
							'  связанных с редактором "Сотрудник от подразделения"

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	' Запоминаем объект редактора
	Set ObjectEditor = oSender
	' получаем пул
	Set Pool = ObjectEditor.Pool
End Sub

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	' запоминаема редакторы свойств
	Set DepartmentEditor	= TMS_GetPropertyEditor(ObjectEditor, Nothing, "Department")
	Set ExecutorEditor		= TMS_GetPropertyEditor(ObjectEditor, Nothing, "Executor")
	Set IsAcquaintEditor	= TMS_GetPropertyEditor(ObjectEditor, Nothing, "ExecutorIsAcquaint")
	Set DateEditor			= TMS_GetPropertyEditor(ObjectEditor, Nothing, "DocsGettingDate")
	
	' инициализируем обработку свойств "Сотрудник от подразделения",
	' "Ознакомился" и "Дата получения документов"
	Set ExecutorHandlerClass = TMS_InitAcquaintedEmployeeHandler( _
		ExecutorEditor, IsAcquaintEditor, DateEditor )
		
	' подписываемся на события редактора подразделения
	DepartmentEditor.EventEngine.AddHandlerForEvent "BeforeSelect", Nothing, "OnDepartmentChanging"
	DepartmentEditor.EventEngine.AddHandlerForEvent "AfterSelect", Nothing, "OnDepartmentChanged"
	DepartmentEditor.EventEngine.AddHandlerForEvent "BeforeUnlink", Nothing, "OnDepartmentChanging"
	DepartmentEditor.EventEngine.AddHandlerForEvent "AfterUnlink", Nothing, "OnDepartmentChanged"
	DepartmentEditor.EventEngine.AddHandlerForEvent "BeforeCreate", Nothing, "OnDepartmentChanging"
	DepartmentEditor.EventEngine.AddHandlerForEvent "AfterCreate", Nothing, "OnDepartmentChanged"
	DepartmentEditor.EventEngine.AddHandlerForEvent "BeforeDelete", Nothing, "OnDepartmentChanging"
	DepartmentEditor.EventEngine.AddHandlerForEvent "AfterDelete", Nothing, "OnDepartmentChanged"
	DepartmentEditor.EventEngine.AddHandlerForEvent "BeforeMarkDelete", Nothing, "OnDepartmentChanging"
	DepartmentEditor.EventEngine.AddHandlerForEvent "AfterMarkDelete", Nothing, "OnDepartmentChanged"
	
	' блокируем/разрещаем данные об исполнителе от подразделения
	disableExecutor()
End Sub

'==============================================================================
' Обработчик событий, возникающий перед изменением свойства "Подразделение"
Sub OnDepartmentChanging( oSender, oEventArgs )
	Dim sMessage
		
	' если сотрудника от подразделения не задан, то ничего не делаем
	If ExecutorEditor.Value Is Nothing Then Exit Sub
	
	sMessage = "Данные по сотруднику от подразделения будут сброшены." & vbNewLine & "Вы уверены, что хотите продолжить?"
	If confirm(sMessage) = False Then
		oEventArgs.ReturnValue = False
		DepartmentEditor.SetData()
	End If
End Sub

'==============================================================================
' Обработчик событий, возникающий после изменения свойства "Подразделение"
Sub OnDepartmentChanged( oSender, oEventArgs )
	Set ExecutorEditor.Value = Nothing
	IsAcquaintEditor.Value = False
	DateEditor.Value = Null
	
	' блокируем/разрещаем данные об исполнителе от подразделения
	disableExecutor()
End Sub

'==============================================================================
' Блокирует/разрещает данные об исполнителе от подразделения
Sub disableExecutor()
	If DepartmentEditor.Value Is Nothing Then
		TMS_EnablePropertyEditor ExecutorEditor, False
	Else
		TMS_EnablePropertyEditor ExecutorEditor, True
	End If

	' обрабатываем редакторы, связанных с исполнителем
	ExecutorHandlerClass.Handle()
End Sub

'==============================================================================
' Обработчик получения ограничений при выборе исполнителя
Sub usr_DepartmentParticipation_Executor_ObjectPresentation_OnGetRestrictions(oSender, oEventArgs)
	oEventArgs.UrlParams = "DepartmentID=" & DepartmentEditor.ValueID
End Sub



