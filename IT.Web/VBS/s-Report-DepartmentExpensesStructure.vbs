'*******************************************************************************
' Подсистема:	
' Назначение:	Редактор/Мастер формы задания параметров отчета "Структура  
'				затрат подразделения" (см. определение в it-metadata-reports.xml,
'				тип FilterReportDepartmentExpensesStructure)
'*******************************************************************************
Option Explicit

Dim g_oEditor		' Ссылка на ObjectEditor; запоминается в usrXEditor_OnLoad

'===============================================================================
' Обработчик события завершения загрузки данных редактора
'	Инициализирует внутр. глобальную ссылку на объект редактора; 
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Set g_oEditor = oSender
End Sub


'===============================================================================
' Обработчик события загрузки страницы мастера / редактора - Инициализация UI
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	Dim nReportForm		' Значение свойства "Форма отчета"
	Dim nSelValue		' Значение искусственного селектора "За 100% брать"
	
	nReportForm	= g_oEditor.GetProp("ReportForm").nodeTypedValue
	
	If ("MainParams" = g_oEditor.CurrentPage.PageName) Then	
		' Инициализация прикладного PE задания периодов времени:
		InitPeriodSelector(oSender)
	Else
		' Установка значения искусственного селектора "За 100% брать":
		nSelValue = 0
		If CBool(g_oEditor.GetProp("ExpensesSumAsPercentBase").nodeTypedValue) Then nSelValue = 1
		g_oEditor.CurrentPage.HtmlDivElement.all.item("selPercentBase",0).value = nSelValue 
	End If
	
	applySelectedReportForm nReportForm
	applySelectedDataFormat g_oEditor.GetProp("DataFormat").nodeTypedValue
	applyFlagsShownColumns g_oEditor.GetProp("ShownColumns").nodeTypedValue
	applySelectednReportForm_OnColumnsFlags nReportForm

	' Включаем отображение внутреннего содержания страницы:
	g_oEditor.CurrentPage.HtmlDivElement.all.item("divPagePane",0).style.visibility = "visible"
End Sub

' Параметры:
'	[in] oSender - экземпляр ObjectEditorClass
'	[in] oEventArgs - экземпляр EditorStateChangedEventArgs
Sub usrXEditor_OnPageEnd( oSender, oEventArgs )
	' Если причина "завершения" страницы - переключение на другую страницу, то
	' отключаем отображение внутреннего содержания данной страницы (что бы не 
	' "чмызгало" при след. включении, см. OnPageStart):
	If ( REASON_PAGE_SWITCH = oEventArgs.Reason ) Then
		g_oEditor.CurrentPage.HtmlDivElement.all.item("divPagePane",0).style.visibility = "hidden"
	End If
End Sub


'===============================================================================
' Внутрений метод, включающий отображение элемента с кратким описанием выбранной 
'	формы отчета. Вызывается из обработчика события изменения значения селектора 
'	"Форма отчета" (см. далее)
' Параметры:
'	[in] nReportForm - значение селектора "Форма отчета" (определяются 
'		перечислением RepDepartmentExpensesStructure_ReportForm)
Sub applySelectedReportForm( nReportForm )
	Dim oSpanElement		' Ссылка на SPAN-элемент, итератор цикла
	Dim bIsTaskDetailMode	' Форма отчета, при котором выводятся данные по 
							' заданиям (и НЕ выводятся КУ, всяческие проценты)
	
	bIsTaskDetailMode = CBool(REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEEWITHTASKSDETALI = nReportForm) 
	
	With g_oEditor.CurrentPage
		' На странице "Основые параметры":
		If ("MainParams" = .PageName) Then
			' Отображение краткого описания выбранной формы отчета: сначала все 
			' спрячем, затем включим отображение нужного:
			For Each oSpanElement In divHlpOpt.all.tags("SPAN")
				oSpanElement.style.display = "none"
			Next
			Set oSpanElement = divHlpOpt.all.item( "sHlpOpt_" & nReportForm, 0 )
			If hasValue(oSpanElement) Then oSpanElement.style.display = "inline"
		End If
		
		' Коррекция зависимых элементов: селектор "Представление данных":
		' ...на странице "Настройки представления":			
		If ("Format" = .PageName) Then
			With .GetPropertyEditor( g_oEditor.GetProp("DataFormat") )
				If (bIsTaskDetailMode) Then .Value = REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYTIME
				.Enabled = Not bIsTaskDetailMode
				applayLockTextStyleClassFor tdDataFormat, bIsTaskDetailMode
			End With
		' ...на странице "Основные параметры":
		Else
			If (bIsTaskDetailMode) Then 
				g_oEditor.SetPropertyValue g_oEditor.GetProp("DataFormat"), REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYTIME
			End If
		End If
		
		' Коррекция зависимых элементов: флаги "Отображаемые колонки"
		applySelectednReportForm_OnColumnsFlags nReportForm 		
	End With
	
End Sub

' Внутренний обработчик события Changed для XPE селектора "Форма отчета"
' Параметры:
'	[in] oSender - экземпляр XPE, XPESelectorComboClass
'	[in] oEventArgs - экземпляр ChangeEventArgsClass (см. x-pe-object-dropdown.vbs)
Sub usr_FilterReportDepartmentExpensesStructure_ReportForm_OnChanged( oSender, oEventArgs )
	applySelectedReportForm oEventArgs.NewValue
End Sub


'===============================================================================
' Внутрений метод, коррктирующий доступность и значения селекторов "За 100% 
'	брать" и "Представление времени" (страница "Настройки представления")
'	в зависимости от значения селектора "Представление данных"
' Параметры:
'	[in] nDataFormat - значение селектора "Представление времени" (все значения
'		опр. перечислением RepDepartmentExpensesStructure_DataFormat)
Sub applySelectedDataFormat( nDataFormat )
	Dim bLockFlag		' Призак блокировки
	With g_oEditor.CurrentPage
		If ("Format" = .PageName) Then
			' Селектор "За 100% брать" блокируется, если выбранное представление 
			' данных отображение процентов не включает:
			bLockFlag = CBool( REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYTIME = nDataFormat )
			document.all("selPercentBase").disabled = bLockFlag
			applayLockTextStyleClassFor tdPercentBase, bLockFlag
			
			' Селектор выбора формы представления времени блокируется, если 
			' представление данных выдается только в процентах:
			bLockFlag = CBool( REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYPERCENT <> nDataFormat )
			.GetPropertyEditor( g_oEditor.GetProp("TimeMeasureUnits") ).Enabled = bLockFlag
			applayLockTextStyleClassFor tdTimeMeasure, Not(bLockFlag)
		End If
	End With
End Sub

' Внутренний обработчик события Changed для XPE селектора "Представление данных"
' Параметры:
'	[in] oSender - экземпляр XPE, XPESelectorComboClass
'	[in] oEventArgs - экземпляр ChangeEventArgsClass (см. x-pe-object-dropdown.vbs)
Sub usr_FilterReportDepartmentExpensesStructure_DataFormat_OnChanged( oSender, oEventArgs )
	applySelectedDataFormat oEventArgs.NewValue
End Sub

'===============================================================================
' Внутрений метод, коррктирующий доступность и значения флагов включения вывода
'	опциональных столбцов отчета, в зависимости от выбраннрй формы отчета.
' Параметры:
'	[in] nReportForm - значение селектора "Форма отчета" (определяются 
'		перечислением RepDepartmentExpensesStructure_ReportForm)
Sub applySelectednReportForm_OnColumnsFlags( nReportForm )
	Dim bIsTaskDetailMode	' Признак: выбрана форма отчета с данными по заданиям
	Dim oShownColumns		' Редактируемое свойство
	
	bIsTaskDetailMode = ( REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEEWITHTASKSDETALI = nReportForm )
	Set oShownColumns = g_oEditor.GetProp("ShownColumns")	 
	
	' Если "Форма отчета" задана как "Данные по каждому сотруднику, с данными 
	' по заданиям", то (а) отображение всех опциональных колонок отключается 
	' и (б) флаги выбора блокируются:
	With g_oEditor.CurrentPage 
		If ("Format" = .PageName) Then
			' ... все действия с PE возможны, если мы на нужной странице:
			With .GetPropertyEditor(oShownColumns)
				.Enabled = Not(bIsTaskDetailMode)
				If (bIsTaskDetailMode) Then .Value = 0
				applayLockTextStyleClassFor tdShownColumns, bIsTaskDetailMode
			End With
		Else
			' ...иначе - только корректируем значение свойства:
			If bIsTaskDetailMode Then
				g_oEditor.SetPropertyValue oShownColumns, 0
				g_oEditor.SetPropertyValue g_oEditor.GetProp("SortingMode"), REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYNAME
				applyFlagsShownColumns 0
			End If
		End If
	End With
End Sub


'===============================================================================
' Внутрений метод, коррктирующий доступность и значения в списке выбора видов
'	активностей, в зависимости от включения отображения столбца "Коэффициент
'	утилизации" (задается свойством ShownColumns; включение отображения столбца
'	опр. установленным флагом из RepDepartmentExpensesStructure_OptColsFlags)
' Параметры:
'	[in] nShownColumns - значение свойства "Отображаемые колонки" (набор флагов
'			из RepDepartmentExpensesStructure_OptColsFlags)
Sub applyFlagsShownColumns( nShownColumns )
	Dim bShowDisbalance		' Признак отображения колонки "Дисбаланс"
	Dim bShowUtilization	' Признак отображения колонки "Коэффициент утилизации"
	Dim bIsRestrictedValue	' Расчетный признак - выбранная опция сортировки в данном случае недоступна
	Dim oActivityTypes		' Свойство ActivityTypesAsExternal редактируемого объекта
	Dim oSortingMode		' Свойство SotringMode редактируемого объекта

	bShowDisbalance = CBool( ( nShownColumns And REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODDISBALANCE ) > 0 )
	bShowUtilization = CBool( ( nShownColumns And REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWUTILIZATION ) > 0 )
	Set oActivityTypes = g_oEditor.GetProp("ActivityTypesAsExternal")
	Set oSortingMode = g_oEditor.GetProp("SortingMode")
	
	' Если в отчете нет данных по утилизации (КУ), то разделение затрат на "внешние" 
	' и "внутренние" не требуется, и значит, перечень видов активностей, затраты
	' на которые будут считаться как "внешние" - тоже не нужен; и наоборот - если
	' данные КУ выводятся - то и определение видов активностей нужно. Вся логика
	' далее "рулит" доступностью UI-элементов, задающих виды активностейЮ, в 
	' зависимости от отображения данных КУ, а так же данными соответствующего 
	' свойства:
	 
	' Если КУ не отображается, то зачищаем список видов активностей в свойстве:
	If Not(bShowUtilization) Then g_oEditor.Pool.RemoveAllRelations Nothing, oActivityTypes
		
	With g_oEditor.CurrentPage
		' ... все манипуляции с элементами UI имеют место на странице "Настройки...":
		If ("Format" = .PageName) Then
		
			' Для PE со списком видов активностей:	
			With .GetPropertyEditor(oActivityTypes) 
				.SetData						' ...отображение - в соотв. с данными свойства
				.Enabled = bShowUtilization		' ...доступность - если КУ отображется
				
				' Отдельные операции над списком в PE: (1) если КУ НЕ отображается, то цвет фона
				' списка заменяем на серый; (2) если КУ отображется, и в списке нет ни одного 
				' выбранного вида, то принудительно выбираем первый попавшийся; (3) управляем
				' выделением строки - если КУ не отображается, то выделение снимаем (иначе это
				' не очень хорошо смотрится при блокировке), если установлен и принудительно 
				' выбирали элемент - то на нем установим выделение:
				.HtmlElement.style.backgroundColor = iif( bShowUtilization, "", "#e0dad0" )
				If (bShowUtilization And 0 = oActivityTypes.childNodes.length) Then
					If (.HtmlElement.Rows.Count > 0) Then
						.HtmlElement.Rows.GetRow(0).Checked = True
						.HtmlElement.Rows.SelectedID = .HtmlElement.Rows.GetRow(0).ID
					End If
				ElseIf (Not bShowUtilization) Then
					.HtmlElement.Rows.Selected = -1	
				End If
			
			End With
			
			' Принудительная коррекция стилей отображения группы элементов, связанных 
			' со списком "видов активностей" - описание поля, сам список, сноска: если
			' КУ не задан, то цвет текста заменяется на "серый":
			applayLockTextStyleClassFor tdActivityTypesAsExternalBlock, Not(bShowUtilization)
			
			' Коррекция зависимого элемнта "Сортировка": варианты "По значению дизбаланса" и
			' "По значению КУ" доступны только тогда, когда включены соответствующие колонки.
			' Если так получается, что в кач. значения выбран "невозможный" вариант, то
			' принудительно сбрасываем значение сортировки в вариант "По наименованию":
			With .GetPropertyEditor(oSortingMode) 
				bIsRestrictedValue = _
					( ( REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYDISBALANCE = CLng(.Value) ) And Not(bShowDisbalance) ) Or _
					( ( REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYUTILIZATION = CLng(.Value) ) And Not(bShowUtilization) )
				If (bIsRestrictedValue) Then .Value = REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYNAME
			End With
			
		End If
	End With
End Sub

' Внутренний обработчик события Changed для XPE флагов "Отображаемые колонки"
' Параметры:
'	[in] oSender - экземпляр XPE, XPESelectorComboClass
'	[in] oEventArgs - экземпляр ChangeEventArgsClass (см. x-pe-object-dropdown.vbs)
Sub usr_FilterReportDepartmentExpensesStructure_ShownColumns_OnChanged( oSender, oEventArgs )
	applyFlagsShownColumns oEventArgs.NewValue
End Sub


'===============================================================================
' Внутренний метод, задающий логическое свойство "ExpensesSumAsPercentBase" 
'	в соответствии со значением искусственного селектора "За 100% брать"
' Параметры:
'	[in] nPercentBase - 0 - За 100% берется сумма затрат по колонке
'						1 - За 100% берется сумма затрат по строке
Sub applyPercentBase( nPercentBase )
	g_oEditor.SetPropertyValue g_oEditor.GetProp("ExpensesSumAsPercentBase"), CBool( 0<>CLng(nPercentBase) )
End Sub

' Внутренний обработчик события Change для селектора "За 100% брать"
Sub selPercentBase_OnChanged()
	applyPercentBase window.event.srcElement.value
End Sub


'===============================================================================
' Внутренний обработчик события Changing для селектора "Сортировка"
' Параметры:
'	[in] oEventArgs - экземпляр ChangeEventArgsClass
Sub usr_FilterReportDepartmentExpensesStructure_SortingMode_OnChanging( oSender, oEventArgs )
	Dim bShowDisbalance		' Признак отображения колонки "Дисбаланс"
	Dim bShowUtilization	' Признак отображения колонки "Коэффициент утилизации"
	Dim bIsRestrictedValue	' Расчетный признак - выбранная опция в данном случае недоступна
	
	With g_oEditor.CurrentPage.GetPropertyEditor( g_oEditor.GetProp("ShownColumns") )
		bShowDisbalance = CBool( ( .Value And REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODDISBALANCE ) > 0 )
		bShowUtilization = CBool( ( .Value And REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWUTILIZATION ) > 0 )
	End With
	
	bIsRestrictedValue = _
		( ( REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYDISBALANCE = CLng(oSender.Value) ) And Not(bShowDisbalance) ) Or _
		( ( REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYUTILIZATION = CLng(oSender.Value) ) And Not(bShowUtilization) )

	If (bIsRestrictedValue) Then
		MsgBox _
			"Применение указанного способа сортировки невозможно - соответствующая колонка отчета скрыта.", _
			vbOkOnly + vbExclamation, "Предупреждение"
		oSender.Value = REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYNAME
		oEventArgs.ReturnValue = False
	End If
End Sub


'===============================================================================
' Внутренний метод коррекции стиля отображения текстов (меток) в HTML-области,
'	заданной ссылкой oMainHtmlElement. Используется для визуального отображения
'	"блокированных" для использования элементов. 
' Параметры:
'	[in] oMainHtmlElement - HTML-элемент, в котором для всех DIV корректируются стили
'	[in] bIsLockTextStyle - Если True, то для всех найденных DIV цвет текста задается 
'			как "серо-синий"; если False, то цвет текста зачищается
Sub applayLockTextStyleClassFor( oMainHtmlElement, bIsLockTextStyle ) 
	Dim oElement
	For Each oElement In oMainHtmlElement.all.tags("DIV")
		If bIsLockTextStyle Then
			oElement.style.color = "#789"
		Else
			oElement.style.color = ""
		End If
	Next
End Sub


'===============================================================================
' Валидация данных страницы. Здесь используется для проверки задания значений:
' -- Не допускается задание интервала, открытого по дате начала (т.е. когда 
'	дата начала не задана), интервала с продолжительностью более года. 
' -- В случае задания интервала продолжительностью более чем в квартал (три 
'	месяца) выводится предупреждение о том, что отчет на таких данных будет 
'	формироваться долго.
' -- Если указано отображение колонки с коэффициентом утилизации, то проверяется
'	задание хотя бы одного вида проектных активностей - для КУ это обязательно
' Параметры:
'	[in] oSender - ObjectEditorClass
'	[in] oEventArgs - EditorStateChangedEventArgs
Sub usrXEditor_OnValidatePage(oSender, oEventArgs)
	Dim dtIntervalBegin		' Дата начала отч. периода
	Dim dtIntervalEnd		' Дата конца отч. периода
	Dim nFlags				' Флаги, опр. отображение опц. колонок
	Dim sMessage			' Текст сообщения
	Dim vMessageType		' Тип сообщения (как флаг vbCritical или vbQuestion)
	Dim vMsgBoxRet			' Результат выбора пользователя (при vbQuestion)
	
	' Все проверки - только для того, что бы предупредить пользователя, что 
	' отчет будет формироваться долго. Если у нас "тихий режим" (в частности,
	' так бывает при закрыти формы по Cancel ;) - то и проверять ничего не надо...
	If oEventArgs.SilentMode Then Exit Sub
	' ...и вообще - все проверки - только при закрытии редактора кнопкой "ОК":
	If REASON_OK <> oEventArgs.Reason Then Exit Sub
 	
	With oSender ' ObjectEditor
		dtIntervalBegin = .GetPropertyValue("IntervalBegin" )
		dtIntervalEnd = .GetPropertyValue("IntervalEnd" )
	End With
	
	' #1: Проверка задания отчетного периода:
	' Если дата конца периода не задана, то считаем ее текущей - 
	' для последующей провекри это вполне приемлемо:
	If Not hasValue(dtIntervalEnd) Then dtIntervalEnd = Now()
	
	' Дата начала периода не задана:
	If Not hasValue(dtIntervalBegin) Then
		sMessage = "Дата начала отчетного периода не задана."
		vMessageType = vbCritical
	' Разница м/у датой начала и конца периода более года 
	ElseIf DateDiff( "m", dtIntervalBegin, dtIntervalEnd ) > 12 Then
		sMessage = "Указанные даты покрывают отчетный период продолжительностью более года."
		vMessageType = vbCritical
	End If
	If ( Len(sMessage) > 0 ) Then
		sMessage = sMessage & vbCr & _
			"Формирование отчета для такого периода невозможно." & vbCr & _
			vbCr & _
			"Для получения информации по структуре затрат подразделений за период времени " & vbCr & _
			"продолжительностью более года воспользуйтесь, пожалуйста, аналитическими данными."
	End If
	
	If DateDiff( "m", dtIntervalBegin, dtIntervalEnd ) > 3 Then
	' Разница м/у датой начала и конца периода более квартала (3 месяца)
		sMessage = _
			"Указанные даты покрывают отчетный период продолжительностью более квартала." & vbCr & _
 			"Формирование отчета для такого периода может занять продолжительное время." 
		vMessageType = vbQuestion
	End If
	
	' #2: Проверка задания хотя бы одной организации или подразделения:
	If	( 0 = g_oEditor.GetProp("Organizations").childNodes.length ) And _
		( 0 = g_oEditor.GetProp("Departments").childNodes.length ) _
	Then
		sMessage = "Подразделение или организация не указаны!"
		vMessageType = vbCritical
	End If
	
	' #3: Проверка задания вида активностей в случае отображения данных КУ:
	nFlags = CLng( g_oEditor.GetProp("ShownColumns").nodeTypedValue )
	' ...отображение "Коэффициэнт утилизации" включено?
	If ( ( nFlags And REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWUTILIZATION ) > 0 ) Then
		' Проверим наличие задания хотя бы одного вида активности:
		If ( 0 = g_oEditor.GetProp("ActivityTypesAsExternal").childNodes.length ) Then
			sMessage = _
				"Для корректного расчета коэффициента утилизации требуется указание хотя бы одного " & vbCr & _
				"вида активностей, затраты по которым будут рассматриваться как ""внешние"" затраты."
			vMessageType = vbCritical
		End If
	End If
	
	' #4: Если есть что показывать - показываем:
	If hasValue(sMessage) Then
		' Вид сообщения и возможность выбора (принципиальная) зависит от типа сообщения:
		' -- это сообщение о _невозможности_ запуска отчета для указанного периода: 
		If (vbCritical = vMessageType) Then
 			vMsgBoxRet = MsgBox( "Внимание!" & vbCr & sMessage, vMessageType + vbOKOnly, "Предупреждение" )
		
		' -- это предупреждение; тут пользователь выбирает, запускать лм отчет:
		Else
 			vMsgBoxRet = MsgBox( _
 				"Внимание!" & vbCr & sMessage & vbCr & vbCr & "Продолжить выполнение?", _
 				vMessageType + vbYesNo + vbDefaultButton2, "Подтверждение" )
		End If
		
		' Если пользователь отказывается от продолжения или если запуск заблокирован
		' безусловно (общее услрвие - vMsgBoxRet != vbYes), то блокируем дальнейщее 
		' выполнение дейстывий, задав ReturnValue в False. Пользователь остается в 
		' редакторе, отчет НЕ запускается...
 		oEventArgs.ReturnValue = CBool( vMsgBoxRet = vbYes )
	End If
End Sub
