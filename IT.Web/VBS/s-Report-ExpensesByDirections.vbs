'*******************************************************************************
' Подсистема:	
' Назначение:	Редактор/Мастер формы задания параметров отчета "Затраты 
'				в разрезе направлений"
'*******************************************************************************
Option Explicit

' Константы, соотв. значениям селектора "Направления активности" (selAnalysisType)
Const AnalysisDirection_ByCustomer = "ByCustomer"	' - "Организация - Направления"
Const AnalysisDirection_ByActivity = "ByActivity"	' -  "Активности - Направления"

Dim g_oEditor	' Сохраненная ссылка на ObjectEditor; запоминается в usrXEditor_OnPageStart
Dim g_bIsInited	' Признак фазы инициализации (устанавливается в True в финале обработчика 
				' usrXEditor_OnPageStart). Необходим для отслеживания случая переключения
				' в режим выбора одной организации, сделанной явно пользователем. В этом
				' случае, если организация еще не задана, код сразу вызывает диалог выбора
				' организации, экономя пользователю клик - см. applySelectedAnalisysType 
				' (случай направления анализа по активности) и applayCustomersSelection
g_bIsInited = False

'===============================================================================
' Обработчик события загрузки первой страницы мастера / редактора
'	Инициализирует внутр. глобальную ссылку на объект редактора; 
'	Инициализирует UI
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	Dim bWasSetTargetCustomer	' Признак, что при предыдущем запуске был задан конкретный клиент
	Dim bWasSetTargetActivity	' Признак, что при предыдущем запуске была задана активность

	' Запоминаем глобальные ссылки
	Set g_oEditor = oSender
	
	' Проанализируем "запомненные" данные, задаваемые в предыдущий раз: для того,
	' что бы корректно восстановить вид редактора - как он был в прошлый раз
	'	- была ли задана конкретная активность?
	bWasSetTargetActivity = hasValue( g_oEditor.CurrentPage.GetPropertyEditor( g_oEditor.GetProp("Folder") ).Value )
	'	- была ли задана конкретная организация?
	bWasSetTargetCustomer = Not(bWasSetTargetActivity) And hasValue( g_oEditor.CurrentPage.GetPropertyEditor( g_oEditor.GetProp("Organization") ).Value )
	
	' Параметры отчета могут задаваться из-вне; в этом случае "запомненнные" данные
	' имеют меньший приоритет. В первую (и пока последнюю) очередь это касается
	' переключателя "Направление анализа", состояние которого определяется по тому,
	' заданы ли идентификатор организации или активности. Если в параметрах задаются
	' эти значения, то это влияет на UI:
	If g_oEditor.QueryString.IsExists(".Organization") Then
		If hasValue( g_oEditor.QueryString.GetValue(".Organization","") ) Then
			bWasSetTargetActivity = False
			bWasSetTargetCustomer = True
		Else
			bWasSetTargetCustomer = False
		End If
	End If
	If g_oEditor.QueryString.IsExists(".Folder") Then
		If hasValue( g_oEditor.QueryString.GetValue(".Folder","") ) Then
			bWasSetTargetActivity = True
			bWasSetTargetCustomer = False
		Else
			bWasSetTargetActivity = False
		End If
	End If
	
	' Инициализация PE задания периодов времени
	InitPeriodSelector(oSender)
	
	' Инициализация остальных элемнтов UI:
	With g_oEditor.CurrentPage.HtmlDivElement
	
		' Повесим событие на radio-переключатели, заодно скорретируем их 
		' состояние в зависимости от "запомненных" данных:
		With .all.item("rdCustomersSelectionAll",0)
			.checked = Not(bWasSetTargetCustomer)
			.attachEvent "onclick", GetRef("internal_rdCustomersSelectionAll_OnClick")
		End With
		With .all.item("rdCustomersSelectionTarget",0)
			.checked = bWasSetTargetCustomer
			.attachEvent "onclick", GetRef("internal_rdCustomersSelectionTarget_OnClick")
		End With
		
		With .all.item("selAnalysisType",0)
			' Скорректируем значение селектора в зависимости от "запомненных" данных:
			If bWasSetTargetActivity Then
				.Value = AnalysisDirection_ByActivity
			Else
				.Value = AnalysisDirection_ByCustomer
			End If
			.attachEvent "onchange", GetRef("internal_selAnalysisType_OnChange")
			applySelectedAnalisysType CBool( .value = AnalysisDirection_ByCustomer )
		End With
		
		' Значение искусственного селектора "Детализация" задается значением ShowDetails данных фильтра:
		With .all.item("selDetalization",0)
			If CBool( g_oEditor.GetPropertyValue("ShowDetails" ) ) Then
				.Value = "1"
			Else
				.Value = "0"
			End If

			' Если задана целевая активность - то детализация НЕВОЗМОЖНА:
			' Принудительно переставляем значение:
			If (bWasSetTargetActivity) Then
				applayDetalizationSelection False
				.Value = "0"
				.disabled = True
			End If
			
			.attachEvent "onchange", GetRef("internal_selDetalization_OnChange")
		End With
		
		' ВКЛЮЧАЕМ ОТОБРАЖЕНИЕ
		.all.item("divPagePane",0).style.visibility = "visible"
	End With
	
	' Инициализация завершена (см. комментарии к объявлению переменной):
	g_bIsInited = True
End Sub


'===============================================================================
' Валидация данных страницы. Здесь используется для проверки заданного периода
' и, в случае задания большого периода, отображения предупреждения о том, что 
' отчет на таких данных будет формироваться долго.
'	[in] oEventArgs As oEditorStateChangedArgs
Sub usrXEditor_OnValidatePage(oSender, oEventArgs)
	Dim dtIntervalBegin
	Dim dtIntervalEnd
	Dim sMessage
	Dim vMsgBoxRet
	
	' Все проверки - только для того, что бы предупредить пользователя, что 
	' отчет будет формироваться долго. Если у нас "тихий режим" (в частности,
	' так бывает при закрыти формы ;) - то и проверять ничего не надо...
	If oEventArgs.SilentMode Then Exit Sub
	
	With oSender ' ObjectEditor
		dtIntervalBegin = .GetPropertyValue("IntervalBegin")
		dtIntervalEnd = .GetPropertyValue("IntervalEnd" )
	End With
	
	' Если дата конца периода не задана, то считаем ее текущей - 
	' для последующей провекри это вполне приемлемо:
	If Not hasValue(dtIntervalEnd) Then dtIntervalEnd = Now()
	
	' #1: Дата начала периода не задана:
	If Not hasValue(dtIntervalBegin) Then
		sMessage = "Дата начала отчетного периода не задана."
	' #2: Разница м/у датой начала и конца периода более года 
	ElseIf DateDiff( "m", dtIntervalBegin, dtIntervalEnd ) >= 12 Then
		sMessage = "Указанные даты покрывают отчетный период продолжительностью более года."
	End If
	
	' Если есть что показывать - показываем. Если пользователь отказывается
	' от продолжения (vMsgBoxRet != vbYes), то блокируем дальнейщее выполнение
	' дейстывий, задав ReturnValue в False. Пользователь остается в редакторе,
	' отчет НЕ запускается...
	If hasValue(sMessage) Then
 		vMsgBoxRet = MsgBox( _
 			"Внимание!" & vbCr & sMessage & vbCr & _
 			"Формирование отчета для такого периода может занять продолжительное время." & vbCr & _
 			vbCr & "Продолжить выполнение?", _
 			vbQuestion + vbYesNo + vbDefaultButton2, "Подтверждение" )
 		oEventArgs.ReturnValue = CBool( vMsgBoxRet = vbYes )
	End If
End Sub


'===============================================================================
' Внутрений метод, корректирующий отображение элементов редактора в зависимости
'	от заданного флага bIsByCustomer, отражающего задание направления анализа 
'	как "Организации - Направления". Вызывается из обработчика события изменения
'	значения селектора "Направление анализа" (см. далее)
' Параметры:
'	[in] bIsByCustomer - True: направление анализа - "Организации - Направления",
'			иначе (False) направление анализа - "Активность - Направления".
Sub applySelectedAnalisysType( bIsByCustomer )

	If CBool(bIsByCustomer) Then
		' ВЫБРАННОЕ НАПРАВЛЕНИЕ АНАЛИЗА - "Организации - Направления";
		' Соответственно:
		'	- зачищаем значение в поле выбора активности и блокируем само поле;
		'	- зачищаем значение и блокируем флаг "Отображать данные о последнем изменении..."
		'	- разблокируем поля, соотв. организаци, выбираем последний известный режим 
		'		анализа организаций (все или конкретная выбранная)
		'	- разблокируем поля, соотв. выбору типа активности;
		'	- разблокируем поля, соотв. флагу "Включать данные только открытых активностей"
		'	- скорректируем значение выбора в поле "Детализация"
		With g_oEditor.CurrentPage
			With .GetPropertyEditor( g_oEditor.GetProp("Folder") ) 
				.Mandatory = False
				Set .Value = Nothing
				.Enabled = False
			End With
			With .GetPropertyEditor( g_oEditor.GetProp("ShowHistoryInfo") ) 
				.Value = False
				.Enabled = False
			End With
			
			.GetPropertyEditor( g_oEditor.GetProp("Organization") ).Enabled = True
			.GetPropertyEditor( g_oEditor.GetProp("FolderType") ).Enabled = True
			.GetPropertyEditor( g_oEditor.GetProp("OnlyActiveFolders") ).Enabled = True
			
			.HtmlDivElement.all.item("rdCustomersSelectionAll",0).disabled = False
			With .HtmlDivElement.all.item("rdCustomersSelectionTarget",0)
				.disabled = False
				' В зависимости от выбранного режима анализа организации - всех или 
				' какой-то конкретной - меняется блокировка поля выбора этой самой 
				' конкретной организации. 
				' Этот режим так же влияет на способ детализации - в коде вызываемой
				' процедуры так же корректируется значение селектора selDetalizationYes
				applayCustomersSelection .checked
			End With 
			
			' Если анализ выполняется по заданной активности, то детализация блокируется;
			' здесь же включаем возможность задания детализации:
			.HtmlDivElement.all.item("selDetalization",0).disabled = False
						
			applayLockTextStyleClassFor .HtmlDivElement.all.item("tdAnalysisDirByCustomer",0), False  
			applayLockTextStyleClassFor .HtmlDivElement.all.item("tdAnalysisDirByActivity",0), True
		End With
		
	Else
		' ВЫБРАННОЕ НАПРАВЛЕНИЕ АНАЛИЗА - "Активности- Направления";
		' Соответственно:
		'	- блокируем радио выбора режима анализа организаций (все или конкретная)
		'	- зачищаем поля, соотв. выбору организаци, 
		'	- заблокируем поля, соотв. выбору типа активности;
		'	- заблокируем поля, соотв. флагу "Включать данные только открытых активностей"
		'	- разблокируем поле выбора активности;
		'	- разблокируем флаг "Отображать данные о последнем изменении..."
		'	- скорректируем значение выбора в поле "Детализация"
		With g_oEditor.CurrentPage
			.HtmlDivElement.all.item("rdCustomersSelectionAll",0).disabled = True
			.HtmlDivElement.all.item("rdCustomersSelectionTarget",0).disabled = True
		
			With .GetPropertyEditor( g_oEditor.GetProp("Organization") )
				.Mandatory = False
				Set .Value = Nothing
				.Enabled = False
			End With
			.GetPropertyEditor( g_oEditor.GetProp("FolderType") ).Enabled = False
			With .GetPropertyEditor( g_oEditor.GetProp("OnlyActiveFolders") )
				.Value = False
				.Enabled = False
			End With

			With .GetPropertyEditor( g_oEditor.GetProp("Folder") )
				.Enabled = True
				.Mandatory = True
			End With
			.GetPropertyEditor( g_oEditor.GetProp("ShowHistoryInfo") ).Enabled = True
			
			' Если анализ выполняется по заданной активности, то детализация НЕВОЗМОЖНА
			With .HtmlDivElement.all.item("selDetalization",0)
				applayDetalizationSelection False
				.Value = 0
				.disabled = True
			End With
			' ...однако (на случай будущего развития) подменим название элемента выбора:
			.HtmlDivElement.all.item("selDetalizationYes",0).innerText = "По активностям"
			
			applayLockTextStyleClassFor .HtmlDivElement.all.item("tdAnalysisDirByActivity",0), False
			applayLockTextStyleClassFor .HtmlDivElement.all.item("tdAnalysisDirByCustomer",0), True  
			
			' Дополнительное действие:
			' Если (а) это не фаза инициализации (g_bIsInited = True), т.е. если переключатель
			' переставил пользователь, и если (б) значение селектора "Активность" еще не задано,
			' то имеет смысл сразу вызвать диалог выбора активности - сэкономим пользователю
			' один клик мышкой по кнопке операций:
			If (True = g_bIsInited) Then
				With .GetPropertyEditor( g_oEditor.GetProp("Folder") )
					If Not hasValue(.Value) Then
						' NB! К сожалению, нет явного способа "вызвать" операцию DoSelectFormDb 
						' из меню object-selector-а. Обходной маневр: т.к. известно, что операция 
						' выьбора есть операция "по умолчанию", и для "пустого" PE будет доступна
						' только она, имитируем нажатие на кнопку "Операции"; сама объект кнопки
						' получем через HtmlElement - в PE object-selector в этом качестве 
						' возвращается именно кнопка:
						 .HtmlElement.click
					End If
				End With
			End If
			 
		End With
	End If
End Sub

' Внутренний обработчик события OnChange для селектора "Направление анализа"
Sub internal_selAnalysisType_OnChange()
	applySelectedAnalisysType  CBool( window.event.srcElement.Value = AnalysisDirection_ByCustomer )
End Sub


'===============================================================================
' Внутренний метод коррекции стиля отображения текстов (меток) в HTML-области,
'	заданной ссылкой oMainHtmlElement. Используется для визуального отображения
'	"блокированных" для использования элементов. 
' Параметры:
'	[in] oMainHtmlElement - HTML-элемент, в котором для всех LABEL корректируются стили
'	[in] bIsLockTextStyle - Если True, то для всех найденных LABEL цвет текста задается 
'			как "серо-синий"; если False, то цвет текста зачищается
Sub applayLockTextStyleClassFor( oMainHtmlElement, bIsLockTextStyle ) 
	Dim oElement
	For Each oElement In oMainHtmlElement.all.tags("LABEL")
		If bIsLockTextStyle Then
			oElement.style.color = "#789"
		Else
			oElement.style.color = ""
		End If
	Next
End Sub


'===============================================================================
' Внутрений метод, корректирующий отображение элементов редактора в зависимости
'	от режима анализа данных организаций - всех или конкретной, задаваемого 
'	radio-переключателем "rdCustomersSelection". Вызывается из обработчиков 
'	событий OnClick элментов radio-переключателя (см. далее)
Sub applayCustomersSelection( bIsTargetCustomer )
	bIsTargetCustomer = CBool(bIsTargetCustomer)
	
	With g_oEditor.CurrentPage
		' Разбираемся с доступностью поля выбора конкретной организации:
		With .GetPropertyEditor( g_oEditor.GetProp("Organization") )
			.Enabled = bIsTargetCustomer 
			.Mandatory = bIsTargetCustomer 
			
			If Not(bIsTargetCustomer) Then 
				Set .Value = Nothing
			Else
				' РЕЖИМ ВЫБОРА КОНКРЕТНОЙ ОРГАНИЗАЦИИ - Дополнительное действие:
				' Если (а) это не фаза инициализации (g_bIsInited = True), т.е. если переключатель
				' переставил пользователь, и если (б) значение селектора "Организация" еще не задано,
				' то имеет смысл сразу вызвать диалог выбора организации - сэкономим пользователю
				' один клик мышкой по кнопке операций:
				If (True = g_bIsInited) Then
					If Not hasValue(.Value) Then
						' NB! К сожалению, нет явного способа "вызвать" операцию DoSelectFormDb 
						' из меню object-selector-а. Обходной маневр: т.к. известно, что операция 
						' выьбора есть операция "по умолчанию", и для "пустого" PE будет доступна
						' только она, имитируем нажатие на кнопку "Операции"; сама объект кнопки
						' получем через HtmlElement - в PE object-selector в этом качестве 
						' возвращается именно кнопка:
						.HtmlElement.click
					End If
				End If
			End If
			
		End With
	
		' "Вид" детализации здесь зависит от того, анализируются ли данные всех 
		' организаций-Клиентов, или только одной: в первом случая детализация - 
		' по организациям, во втором - по активностям выбранной организации:
		.HtmlDivElement.all.item("selDetalizationYes",0).innerText = _
			iif( bIsTargetCustomer, "По активностям", "По организациям" )
	End With
End Sub

' Внутренний обработчик события OnClick для элемента radio-переключателя "Все организации"
Sub internal_rdCustomersSelectionAll_OnClick()
	applayCustomersSelection false
End Sub

' Внутренний обработчик события OnClick для элемента radio-переключателя "Организация"
Sub internal_rdCustomersSelectionTarget_OnClick()
	applayCustomersSelection true
End Sub


'===============================================================================
' Внутренний метод, корректирующий значение параметра ShowDetails в зависимости
' от заданного логического значения
Sub applayDetalizationSelection( bShowDetail )
	g_oEditor.SetPropertyValue g_oEditor.GetProp("ShowDetails"), CBool(bShowDetail)
End Sub

' Внутренний обработчик события изменения значения селектора "Детализация"
'	Устанавливает соответствующее значение для поля "ShowDetails" данных фильтра
Sub internal_selDetalization_OnChange()
	applayDetalizationSelection CBool(window.event.srcElement.value = "1")
End Sub

