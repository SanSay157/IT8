'*******************************************************************************
' Подсистема:	XEditor
' Назначение:	Логика использования редактора в качестве открываемого
'				в диалоговом окне редактора
'*******************************************************************************
Option Explicit
' Ссылки на HTML-контролы
Dim cmdCancel           ' кнопка Отмена
Dim g_oMenuHolder		' Экземпляр x-menu-editor.htc - контейнер меню (может быть Nothing, если меню для редактора не задано)

'==============================================================================
' Реализация IObjectContainerEventsClass для в диалоговом окне в качестве редактора
Class ObjectEditorDialogWindowContainerEventsClass
	
	'==========================================================================
	' Редактор запрашивает об изменении заголовка
	'	[in] oObjectEditor
	'	[in] sEditorCaption As String - заголовок редактора. Может содержать HTML-форматирование.
	'	[in] sPageCaption As String - заголовок страницы. Может содержать HTML-форматирование.
	Public Sub OnSetCaption(oObjectEditor, ByVal sEditorCaption, sPageCaption)
		Dim oCaption	' Элемент с идентификатором "xPaneCaption"
		Dim aCaption	' Текст заголовка в виде массива строк
		
		If hasValue(sPageCaption) Then
			' установим заголовок страницы, если задан
			If oObjectEditor.IsMultipageEditor Then
				' многозакладочный редактор - наименование страницы установим на активной закладке
				Tabs.SetTabLabel Tabs.ActiveTabID, sPageCaption
			End If
		End If
		' установим заголовок редактора
		Set oCaption = document.all( "XEditor_xPaneCaption", 0)
		If Not oCaption Is Nothing Then
			' Занесём HTML-код заголовка...
			oCaption.innerHTML = sEditorCaption
			' Получим его "чистый" текст и разoбъем на строки 
			aCaption = Split( "" & oCaption.innerText, vbCr)
			' Выставим заголовок окна = первой строке заголовка
			If UBound(aCaption)>=0 Then
				document.title = aCaption(0) 
			Else
				document.title = ""
			End If	
		End If
	End Sub


	'==========================================================================
	' Редактор просит изменить состояние доступности контролов контейнера
	Public Sub OnEnableControls(oObjectEditor, bEnable, vReserved)
		If oObjectEditor.IsEditor Then
			If oObjectEditor.IsMultipageEditor Then
				Tabs.Enabled = bEnable
			End If
		End If
		cmdCancel.disabled = Not bEnable
		If Not g_oMenuHolder Is Nothing Then _
		    g_oMenuHolder.SetEnableState bEnable
	End Sub


	'==========================================================================
	' Возвращает редактору HTMLDIV, в который он может вставлять свое содержимое
	'	[in] oObjectEditor
	'	[in] vReserved
	Public Function OnGetPageDiv(oObjectEditor, vReserved)
		Set OnGetPageDiv = document.all("x_editor_content_div",0)
	End Function

	
	'==========================================================================
	' Редактор сообщает о том, что можно приступать к инициализации интерефейса контейнера
	'	[in] oObjectEditor As ObjectEditorClass - редактор
	'	[in] vReserved
	Public Sub OnInitializeUI(oObjectEditor, vReserved)
		If g_bExiting Then Exit Sub
		If oObjectEditor.IsEditor Then
			If oObjectEditor.IsMultipageEditor Then
				' редактор многозакладочный
				Tabs.style.display = "block"
				If g_bExiting Then Exit Sub
				XService.DoEvents
				Exit Sub
			End If
		End If
		If g_bExiting Then Exit Sub
		XService.DoEvents
	End Sub

	
	'==========================================================================
	' Редактор сообщает о добавления описания страницы.
	'	[in] oObjectEditor As ObjectEditorClass - редактор
	'	[in] oPage As EditorPageClass - описание страницы
	Public Sub OnAddEditorPage(oObjectEditor, oPage, vReserved)
		Dim nIndex		' индекс добавленной закладки
		If g_bExiting Then Exit Sub
		nIndex = Tabs.AddIdentified( oPage.PageName, oPage.PageTitle, oPage.PageHint, "" )
		' если добавленная страница должна быть скрыта, то скроем закладку ей соответствующую
		If oPage.IsHidden Then
			Tabs.HideTab nIndex, True
		End If
	End Sub

	
	'==========================================================================
	' Редактор сам хочет перейти на заданной странице. 
	' Только для многозакладочного редактора!
	Public Sub OnActivateEditorPage(oObjectEditor, nPageIndex, vReserved)
		If g_bExiting Then Exit Sub
		Tabs.ActiveTab = nPageIndex
	End Sub
	
	
	'==========================================================================
	' Редактор (в режиме мастера) сообщает об изменении состава операций
	' Кнопки должны появляться заблокированными, т.к. позже будет вызван OnEnableControls
	'	[in] oArgs As SetWizardOperationsArgsClass
	Public Sub OnSetWizardOperations(oObjectEditor, oArgs)
		If Not g_oMenuHolder Is Nothing Then _
		    g_oMenuHolder.SetWizardButtonsState oArgs.bIsFirstPage, oArgs.bIsLastPage, oArgs.EditorPage
	End Sub


	'==========================================================================
	' Редактор сообщает об изменении состава операций. Происходит при отображении страницы.
	' Кнопки должны появляться заблокированными, т.к. позже будет вызван OnEnableControls
	'	[in] oArgs As SetWizardOperationsArgsClass
	Public Sub OnSetEditorOperations(oObjectEditor, oArgs)
		If Not g_oMenuHolder Is Nothing Then _
		    g_oMenuHolder.SetEditorButtonsState oArgs.EditorPage
	End Sub


	'==========================================================================
	Public Sub OnSetStatusMessage( oObjectEditor, sMsg, vReserved )
		StatusDiv.innerText = sMsg
		If Len(sMsg) > 0 Then
			StatusDiv.style.display = "block"
		Else
			StatusDiv.style.display = "none"
		End If
		XService.DoEvents
	End Sub


	'==========================================================================
	' Возвращает индекс следующей видимой закладки слева направо по кругу
	'	[in] nIndex As Integer - индекс закладки (от 0)
	'	[retval As Integer - новый индекс закладки (от 0)
	Private Function getNextTabIndex(ByVal nIndex)
		If nIndex = Tabs.Count - 1 Then
			nIndex = 0
		Else
			nIndex = nIndex + 1
		End If
		If Tabs.IsTabHidden(nIndex) Then
			nIndex = getNextTabIndex(nIndex)
		End If
		getNextTabIndex = nIndex
	End Function

	'==========================================================================
	' Возвращает индекс следующей видимой закладки справа налево по кругу
	'	[in] nIndex As Integer - индекс закладки (от 0)
	'	[retval As Integer - новый индекс закладки (от 0)
	Private Function getPrevTabIndex(ByVal nIndex)
		If nIndex = 0 Then
			nIndex = Tabs.Count - 1
		Else
			nIndex = nIndex - 1
		End If
		If Tabs.IsTabHidden(nIndex) Then
			nIndex = getPrevTabIndex(nIndex)
		End If
		getPrevTabIndex = nIndex
	End Function

	'==========================================================================
	' Обработчик нажатия комбинации клавиш. Вызывается из ObjectEditor'a
	'	[in] oEventArgs As AccelerationEventArgsClass
	Public Sub OnKeyUp(oObjectEditor, oEventArgs)
		Dim isList	' Элемент управления является списком
		With oEventArgs
			If .keyCode	= VK_ESC Then
				XEditor_cmdCancel_onClick
			' Если элементы управления не активны, то обрабатывать нажатие не надо
			ElseIf Not oObjectEditor.IsControlsEnabled Then 
				oEventArgs.Processed = True
				Exit Sub
			ElseIf oObjectEditor.IsMultipageEditor Then
				isList = False
				If Not IsEmpty(oEventArgs.HtmlSource) Then
					If (oEventArgs.HtmlSource.tagName = "SELECT" Or oEventArgs.HtmlSource.getAttribute("classid") = CLSID_LIST_VIEW) Then
						isList = True
					End If
				End If
				' Если нажаты Ctrl+Tab и текущий ЭУ select или XListView, то нажатие было обработано на OnKeyDown - ничего не делать
				If .ctrlKey = True And .keyCode = VK_TAB And isList = True Then
					oEventArgs.Processed = True
				ElseIf .ctrlKey = True And .shiftKey = False And .keyCode = VK_RIGHT Then
					If CheckTabNavigation(oEventArgs.HtmlSource) Then
						oEventArgs.Processed = True
						ActivateTabByIndex oObjectEditor, getNextTabIndex(Tabs.ActiveTab)
					End If
				ElseIf .ctrlKey = True And .shiftKey = False And .keyCode = VK_LEFT Then
					If CheckTabNavigation(oEventArgs.HtmlSource) Then
						oEventArgs.Processed = True
						ActivateTabByIndex oObjectEditor, getPrevTabIndex(Tabs.ActiveTab)
					End If
				ElseIf .ctrlKey = True And .shiftKey = False And .keyCode = VK_TAB Then 
					oEventArgs.Processed = True
					ActivateTabByIndex oObjectEditor, getNextTabIndex(Tabs.ActiveTab)
				ElseIf .ctrlKey = True And .shiftKey = True And .keyCode = VK_TAB Then 
					oEventArgs.Processed = True
					ActivateTabByIndex oObjectEditor, getPrevTabIndex(Tabs.ActiveTab)
				' Обработка нажатия Ctrl+<номер страницы>
				ElseIf .ctrlKey = True And .keyCode >= VK_D1 And .keyCode <= VK_D9 Then
					oEventArgs.Processed = True
					ActivateTabByIndex oObjectEditor, .keyCode - VK_D1
				Else
					g_oMenuHolder.ExecuteHotkey oEventArgs
				End If
			Else
				If Not g_oMenuHolder Is Nothing Then _
				    g_oMenuHolder.ExecuteHotkey oEventArgs
			End If
		End With
	End Sub
	
	
	
	'==========================================================================
	' Обработчик нажатия комбинации клавиш. Вызывается из ObjectEditor'a
	'	[in] oEventArgs As AccelerationEventArgsClass
	Public Sub OnKeyDown(oObjectEditor, oEventArgs)
		' Если элементы управления не активны, то обрабатывать нажатие не надо
		If Not oObjectEditor.IsControlsEnabled Then 
			oEventArgs.Processed = True
			Exit Sub
		End If
		With oEventArgs
			' Если редактор многостраничный и текущая страница отрисована - возможен переход на следующую страницу по Ctrl+Tab
			If oObjectEditor.IsMultipageEditor And oObjectEditor.CurrentPage.IsReady Then
				' Переход по Ctrl+Tab обрабатывается на OnKeyDown только для следующих ЭУ: select, XListView
				' Для остальных переход обрабатывается в OnKeyUp
				If oEventArgs.HtmlSource.tagName = "SELECT" Or oEventArgs.HtmlSource.getAttribute("classid") = CLSID_LIST_VIEW Then
					If .ctrlKey = True And .keyCode = VK_TAB Then
						ActivateTabByIndex oObjectEditor, getNextTabIndex(Tabs.ActiveTab)
						oEventArgs.Processed = True
					End If
				End If
			End If
		End With
	End Sub
	
	'==========================================================================
	' Выполняет переключение текущей закладки редактора на закладку с указанным индексом
	'	[in] nTabIndex - индекс закладки, которую необходимо сделать активной
	Private Sub ActivateTabByIndex(oObjectEditor, nTabIndex)
		Dim oEditorPage	' Страница редактора
		' Проверить количество страниц
		If nTabIndex < oObjectEditor.Pages.Count Then
			' Получить страницу с указанным индексом
			Set oEditorPage = oObjectEditor.GetPageByIndex(nTabIndex)
			' Если текущая страница не совпадает с выбранной
			If oEditorPage.PageName <> oObjectEditor.CurrentPage.PageName And oEditorPage.isHidden = False Then 
				' Перевести фокус на кнопку "Отменить"
				cmdCancel.Focus
				' Сделать элементы управления неактивными
				oObjectEditor.EnableControls False
				' Проверить, что текущая страница правильно заполнена
				If oObjectEditor.CanSwitchPage Then 
					' Переключить страницу
					window.setTimeout "g_oController.SetActiveTab """ & Tabs.ActiveTabID & """, """ & oEditorPage.PageName & """", 100, "VBScript"
				End If
			End If
		End If
	End Sub
	
	'==========================================================================
	' Проверяет возможность переключения закладки редактора в зависимости от элемента управления
	'	[in] nTabIndex - индекс закладки, которую необходимо сделать активной
	Function CheckTabNavigation(oHtmlSource)
		CheckTabNavigation = True
		If oHtmlSource.tagName = "INPUT" Then
			If oHtmlSource.type = "text" Then CheckTabNavigation = False
		End If
		If oHtmlSource.tagName = "TEXTAREA" Then CheckTabNavigation = False
	End Function
	
End Class


'==============================================================================
' Назначение:	Класс-контейнер редактора (ObjectEditor'a), принимает воздействия от Html-элементов
' Примечание:	Интерфейс данного класса в отличии от ObjectContainerEventsClass
'				не является фиксированным...
' Зависимости:	
' Пример: 	
Class ObjectEditorDialogWindowContainerClass
	Private m_oObjectEditor			' As ObjectEditorClass - Редактор
    Private m_oContainerEvents		' As ObjectEditorDialogWindowContainerEventsClass
   
	'-------------------------------------------------------------------------------
	' Назначение:	Инициализация
	' Результат:
	'	true если всё хорошо, иначе false 
	' Параметры:	
	'	[in] oContainerEvents - экземпляр ObjectContainerEventsClass
	Public Function Init(oContainerEvents)
		Dim sInitResult		' сообщение от Init
		Dim oObjectEditor	' ObjectEditor
		Dim oParams			' As ObjectEditorInitializationParametersClass

		initializeHtmlControls		
		Set oObjectEditor = New ObjectEditorClass
		Set m_oContainerEvents = oContainerEvents
		Set oParams = getEditorInitializationParams()

		' Инициализиуем меню
		Set g_oMenuHolder = document.all("oMenu")
		If Not g_oMenuHolder Is Nothing Then _
		    g_oMenuHolder.Init oObjectEditor.UniqueID, X_CreateDelegate(Me, "Internal_MenuExecutionHandler")

		' Инициализируем редактор
		sInitResult = oObjectEditor.Init(oContainerEvents, oParams)
		If Len("" & sInitResult) > 0 Then
			oContainerEvents.OnSetStatusMessage oObjectEditor, sInitResult, Null
			Init = False
		Else
			Set m_oObjectEditor = oObjectEditor
			Init = True
		End If
	End Function


	'-------------------------------------------------------------------------------
	' Инициализация ссылок на HTML-контролы
	Private Sub initializeHtmlControls()
		Set cmdCancel = document.all("XEditor_cmdCancel")
	End Sub


	'==========================================================================
	' Возвращает заполненные инициализирующие параметры для редактор
	Private Function getEditorInitializationParams()
		Dim oObjectEditorDialog	' Временный массив
		Dim oParams				' As ObjectEditorInitializationParametersClass
		
		Set oParams = New ObjectEditorInitializationParametersClass
		' Инициализируем данные редактора/мастера
		X_GetDialogArguments oObjectEditorDialog
		' Переложим кэш прав в текущий контекст из контекста предыдущего родительского окна
		Set x_oRightsCache = oObjectEditorDialog.GetRightsCache
		' Переложим метаданные в текущий контекст из контекста предыдущего родительского окна
		Set x_oMD = oObjectEditorDialog.GetMetadataRoot()
		' Переложит враппер файла конфигурации в текущий контекст из контекста предыдущего родительского окна
		Set x_oConfig = oObjectEditorDialog.GetConfig()
		
		With oParams
			.ObjectType = X_PAGE_OBJECT_TYPE
			.MetaName = X_PAGE_METANAME
			.CreateNewObject = oObjectEditorDialog.IsNewObject
			.ObjectID = oObjectEditorDialog.ObjectID
			.IsAggregation = oObjectEditorDialog.IsAggregation
			Set .QueryString = oObjectEditorDialog.QueryString
			Set .XmlObject = oObjectEditorDialog.XmlObject
			Set .ParentObjectEditor = oObjectEditorDialog.ParentObjectEditor
			.ParentObjectID = oObjectEditorDialog.ParentObjectID
			.ParentObjectType = oObjectEditorDialog.ParentObjectType
			.ParentPropertyName = oObjectEditorDialog.ParentPropertyName
			.EnlistInCurrentTransaction = oObjectEditorDialog.EnlistInCurrentTransaction
			Set .InterfaceMD = XService.XmlFromString( document.all("oMetadata",0).value )
			Set .Pool = oObjectEditorDialog.Pool
			
			If hasValue(oObjectEditorDialog.SkipInitErrorAlerts) Then
				.SkipInitErrorAlerts = oObjectEditorDialog.SkipInitErrorAlerts
			Else
				.SkipInitErrorAlerts = False
			End If
		End With
		Set getEditorInitializationParams = oParams
	End Function


	'-------------------------------------------------------------------------------
	' Назначение:	Обработка желания пользователя переключить закладку
	' Примечание:	Вызывается из обработчика события OnBeforeSwitch объекта Tabs
	' Результат:	true если всё можно, иначе false 
	Public Function OnBeforeTabsSwitch()
		OnBeforeTabsSwitch = m_oObjectEditor.CanSwitchPage
	End Function


	'-------------------------------------------------------------------------------
	' Назначение:	Обработка переключения закладок
	' Примечание:	Вызывается из обработчика события OnSwitch объекта Tabs
	Public Sub OnTabsSwitch()
		' Переинициализирую вкладку
		m_oObjectEditor.SwitchToPageByPageID Tabs.ActiveTabID
	End Sub


	'-------------------------------------------------------------------------------
	' Назначение:	Переход на следующую страницу мастера
	Public Sub OnNextPage
		m_oObjectEditor.WizardGoToNextPage
	End Sub


	'-------------------------------------------------------------------------------
	' Назначение:	Переход на предыдущую страницу мастера
	Public Sub OnPrevPage
		m_oObjectEditor.WizardGoToPrevPage
	End Sub


	'-------------------------------------------------------------------------------
	' Назначение:	Сохраняет объект и закрывает окно
	Public Sub OnSaveAndClose
		Dim vResult		' Empty - ошибка, иначе ObjectID сохраненного объекта
		
		vResult = m_oObjectEditor.Save
		If IsEmpty(vResult) Then Exit Sub
		' Всё замечательно - оставим контролы заблокированными
		' установим ReturnValue
		X_SetDialogWindowReturnValue vResult 
		' И закроем окно
		g_bOkPressed = True
		g_bCancelPressed = Empty

		window.Close
	End Sub

	
	'-------------------------------------------------------------------------------
	' Назначение:	Сохраняет текущий объект на начинает создание нового
	Public Sub OnSaveAndStartNew
		Dim vResult			' Empty - ошибка, иначе ObjectID сохраненного объекта
		Dim sStatusDivHtml	' HTML DIV'a с сообщением
		Dim oContentDiv		' Объект DIV'a с содержанием редактора
        
        ' Сохраним изменения в текущем редакторе
		vResult = m_oObjectEditor.Save
		
		' Если сохранить не удалось, не продолжаем, остаемся в текущем редакторе
		If IsEmpty(vResult) Then Exit Sub
		
		' Освободим текущий экземпляр ObjectEditor
		m_oObjectEditor.Dispose
		Set m_oObjectEditor = Nothing
		
		' Сохраняем содержание элемента с сообщением:
		sStatusDivHtml = StatusDiv.outerHtml

		' Зачистим содержимое всего поля редактора:
		Set oContentDiv = document.all("x_editor_content_div",0)
		oContentDiv.InnerHtml = ""
		
		' ...это нужно, что бы прошло все события, ответственные 
		' за корректное разрушение компонент и HTML-я в IE
		XService.DoEvents
		
		' Восстановим элемент для отображения сообщения
		oContentDiv.InnerHtml = sStatusDivHtml
		
		' Запускаем повторный цикл инициализации
		Init New ObjectEditorDialogWindowContainerEventsClass
	End Sub


	'-------------------------------------------------------------------------------
	' Назначение:	Отменяет редактирование и закрывает окно
	Public Sub OnCancel
		' и закроем окошко
		window.close
	End Sub


	'-------------------------------------------------------------------------------
	' Назначение:	Оображение справочной информации
	Public Sub OnHelp
		If m_oObjectEditor.IsHelpAvailiable Then
			X_OpenHelp m_oObjectEditor.HelpPage
		End If	
	End Sub


	'-------------------------------------------------------------------------------
	':Назначение:	Обработчик попытки выгрузки окна редактора
	':Параметры:	bOkPressed - [in] признак того, что закрытие редактора вызвано нажатием ОК/Готово
	Public Function OnBeforeWindowUnload(bOkPressed)
		If m_oObjectEditor.MayBeInterrupted Then
			OnBeforeWindowUnload = m_oObjectEditor.OnClosing(bOkPressed)
		Else	
			OnBeforeWindowUnload =  "Внимание!" & vbNewLine & "Закрытие окна в данный момент может привести к возникновению ошибки!"
		End If	
	End Function


	'-------------------------------------------------------------------------------
	' Назначение:	Обработчик выгрузки окна редактора
	Public Sub OnWindowUnload
		If g_bCancelPressed Then
			m_oObjectEditor.OnCancel
		End If
		m_oObjectEditor.OnClose
		Set m_oObjectEditor = Nothing
	End Sub


	'-------------------------------------------------------------------------------
	' Назначение:	Отлов отладочных сообщений
	Public Sub OnDebugEvent
		m_oObjectEditor.ShowDebugMenu
	End Sub


	'==========================================================================
	' Обработчик нажатия комбинации клавиш
	'	[in] oEventArgs As AccelerationEventArgsClass
	Public Sub OnKeyUp(oEventArgs)
		m_oObjectEditor.OnKeyUp Me, oEventArgs
	End Sub

	'==========================================================================
	' Обработчик нажатия комбинации клавиш
	'	[in] oEventArgs As AccelerationEventArgsClass
	Public Sub OnKeyDown(oEventArgs)
		m_oObjectEditor.OnKeyDown Me, oEventArgs
	End Sub

	'==========================================================================
	Public Sub Internal_MenuExecutionHandler(oSender, oEventArgs)
		Select Case oEventArgs.Action
			Case "DoSaveAndClose"
				OnSaveAndClose
			Case "DoNextPage"
				OnNextPage
			Case "DoPrevPage"
				OnPrevPage
			Case "DoSaveAndStartNew"
				OnSaveAndStartNew
		End Select
	End Sub
	
	'==========================================================================
	' Перелключает текущую закладку редактора
	' используется при асинхронном вызове
	'	[in] sCurrentTab - Текущая закладка редактора
	'	[in] sNewTab - Закладка редактора, которую надо сделать активной
	Public Sub SetActiveTab(sCurrentTab, sNewTab)
		' Если указанная в качестве текущей закладка редактора не совпадает с текущей закладкой редактора - ничего не делать
		' Случается, если пользователь барабанит по клавишам.
		If Tabs.ActiveTabID = sCurrentTab And sCurrentTab <> sNewTab Then _
			Tabs.ActiveTabID = sNewTab
	End Sub
	
End Class


Dim g_bExiting			' признак выгрузки окна
Dim g_oController		' Глобально доступный экземпляр ObjectEditorScriptletContainerClass		
Dim g_bCancelPressed	' Признак нажатия Cancel (Отмена)
Dim g_bOkPressed		' Признак нажатия OK (Готово)

Set g_oController = Nothing

'<ОБРАБОТЧИКИ window и document>
'======================================================================
' Инициализация страницы
Sub Window_OnLoad
	' Обычно пользователь жмет Cancel...
	X_SetDialogWindowReturnValue Empty
	
	If X_ACCESS_DENIED Then 
		document.all("XEditor_cmdCancel").disabled = False
		Exit Sub
	End If
	' Дожидаемся загрузки всех частей страницы
	StatusDiv.innerText = "Завершение загрузки страницы..."
	X_WaitForTrue "XEditor_InitializeAndRun", "X_IsDocumentReady(Null)"
End Sub

'======================================================================
' Обрабочик начала выгрузки окна редактора
Sub Window_OnBeforeUnload
	Dim sUserString	' Строка пользователя
	If X_ACCESS_DENIED Then Exit Sub
	If IsNothing(g_oController) Then Exit Sub
	sUserString =  vbNullString & g_oController.OnBeforeWindowUnload(g_bOkPressed)
	If 0 <> Len(sUserString) Then window.event.returnValue = sUserString
End Sub

'======================================================================
' Обрабочик выгрузки страницы
Sub Window_OnUnLoad
	' выставим признак выгрузки окна
	g_bExiting = True
	If X_ACCESS_DENIED Then Exit Sub
	If IsNothing(g_oController) Then Exit Sub
	g_oController.OnWindowUnload
End Sub		

'======================================================================
' Обработчик нажатия F1
Sub Document_OnHelp
	If IsNothing(g_oController) Then Exit Sub
	If X_MD_HELP_AVAILABLE Then
		window.event.returnValue = False
		g_oController.OnHelp 
	End If
End Sub

'======================================================================
Sub Document_OnKeyUp
	If window.event Is Nothing Then Exit Sub
	If g_oController Is Nothing Then
		If window.event.KeyCode = VK_ESC Then XEditor_cmdCancel_onClick
		Exit Sub
	Else
		With window.event
			If Not .srcElement Is Nothing Then
				If Not IsNull(.srcElement.getAttribute("X_IgnoreHtmlEvents")) Then
					Exit Sub
				End If
			End If
			g_oController.OnKeyUp CreateAccelerationEventArgsForHtmlEvent()
		End With
	End If
End Sub

'======================================================================
Sub Document_OnKeyDown
	If window.event Is Nothing Then Exit Sub
	If g_oController Is Nothing Then Exit Sub
	With window.event
		If Not .srcElement Is Nothing Then
			If Not IsNull(.srcElement.getAttribute("X_IgnoreHtmlEvents")) Then Exit Sub
		End If
		g_oController.OnKeyDown CreateAccelerationEventArgsForHtmlEvent()
	End With
End Sub

'</ОБРАБОТЧИКИ window и document>


'<ОБРАБОТЧИКИ ОБЪЕКТА XTabStrip>
'======================================================================
' Обработка желания пользователя переключить закладку
Sub Tabs_OnBeforeSwitch()
	If IsNothing(g_oController) Then Exit Sub
	window.event.returnValue = g_oController.OnBeforeTabsSwitch
End Sub

'======================================================================
' Обработка переключения закладок
Sub Tabs_OnSwitch()
	If IsNothing(g_oController) Then Exit Sub
	g_oController.OnTabsSwitch
End Sub
'</ОБРАБОТЧИКИ ОБЪЕКТА XTabStrip>


'<ОБРАБОТЧИКИ КНОПОК>
'======================================================================
' Обработка нажатия кнопки "ОТМЕНИТЬ"
Sub XEditor_cmdCancel_onClick
	g_bOkPressed = Empty
	g_bCancelPressed = True
	If IsNothing(g_oController) Then
		window.Close
	Else
		g_oController.OnCancel
	End If
End Sub

'======================================================================
' Обработчик нажатия на кнопку "справка"
Sub XEditor_cmdHelp_OnClick
	Document_OnHelp
End Sub
'</ОБРАБОТЧИКИ КНОПОК>


'======================================================================
Sub XEditor_InitializeAndRun()
	Dim oController
	Set oController = New ObjectEditorDialogWindowContainerClass
	If oController.Init(New ObjectEditorDialogWindowContainerEventsClass) Then
		Set g_oController = oController 
	End If
End Sub


'======================================================================
' Отлов "отладочных" событий
' Показываем по PopUp-меню и CTRL (если в отладке-CTRL-не обязательно) на заголовке 
Sub OnDebugEvent
	If IsNothing(g_oController) Then Exit Sub
	If Not( window.event.ctrlKey  Or X_IsDebugMode)Then Exit Sub
	window.event.returnValue = False
	window.event.cancelBubble = True
	g_oController.OnDebugEvent
End Sub
