'********************************************************************************
'Cтраница отбора одного или нескольких объектов из дерева,
' ДОЛЖНА открываться в модальном окне.
'
' Для передачи и получения параметров используется экземпляр класса SelectFromTreeDialogClass.
' Все параметры устанавливаются и получаются через этот класс. Открытие диалога производиться с помощью метода Show.
' Экземпляр класса SelectFromTreeDialogClass передается через DialogArguments.
' Основой страницы является управляющий элемент CROC.XTreeView (имя на странице - "oTreeView")
'
'********************************************************************************

Option Explicit
' Глобальные переменные
Dim g_XTreeSelectorInstance
Dim FilterObject				' Экземпляр фильтра

Function XTreeSelector
	' Реализуется Singleton
	If IsObject(g_XTreeSelectorInstance) Then
		If Nothing Is g_XTreeSelectorInstance Then
			Set g_XTreeSelectorInstance = New TreeSelectorClass
		End If
	Else
		Set g_XTreeSelectorInstance = New TreeSelectorClass
	End If
	Set  XTreeSelector = g_XTreeSelectorInstance
End Function


'==============================================================================
'	События:
'	Load	- Вызывается после окончания загрузки всех элементов страницы и данных, но перед установкой пути в дереве. (EventArgs: Nothing)
'	Select	- Вызывается после выбора узлов перед закрытие окна. Если поле ReturnValue установить в False, окно не закрывается. (EventArgs: SelectEventArgsClass)
'	UnLoad	- Вызывается при закрытии окна (любым образом) (EventArgs: Nothing)
Class TreeSelectorClass
	Private m_oTreeView				' As CROC.IXTreeView
	Private m_sLoader				' URL загрузчикa дерева		
	Private m_sTreeInitPath			' начальный путь к узлу дерева, заданный снаружи при вызове страницы
	Private m_sSelectionMode		' Режим отбора: TSM_LEAFNODE, TSM_LEAFNODES, TSM_ANYNODE, TSM_ANYNODES
	Private m_sSelectableTypes		' Типы узлов, которые можно выбрать. 
	Private m_bSelectionCanBeEmpty	' Допустимость пустого выделения
	Private m_sSelectionEmptyMsg	' Сообщение, выдаваемое пользователю, в случае, если он не выбрал ниодного узла и SelectionCanBeEmpty<>True
	Private m_oSelected				' То, что уже отобрано
	Private m_sHelpPage				' Страница помощи
	Private m_vDone					' Признак того что страница ужe проинициализирована
	Private m_sMetaName				' Метатимя страницы
	Private m_sLoaderParams			' параметры загрузчика
	Private m_oUrlArguments			' As QueryString - Дополнительные аргументы, передаваемые в загрузчик
	Private m_sExcludeNodes			' As String - список исключаемых узлов - см. [x-utils.vbs]SelectFromTreeDialogClass.ExcludeNodes
	Private m_oEventEngine			' As EventEngine
	Private m_oEventEngineFilter	' As EventEngine - EventEngine для получения событий от фильтра (передается в x-filter.htc)
	Private EVENTS					' As String -список событий компонента
	Private m_bOffFilterViewState	' As Boolean - Признак "Не сохранять состояние фильтра"
	Private m_bMayBeInterrupted 	' As Boolean - Признак безопасной выгрузки страницы

	' HTML Controls
	Private xPaneFilter
	Private xPaneHeader
	Private xPaneCaption
	Private xPaneSpecialCaption
	Private cmdRefresh
	Private cmdClearFilter
	Private cmdHideFilter
	Private cmdOK
	Private cmdCancel
	Private xPaneAccessDenied
	Private TreeHolder
	Private NoDataMsg
	
	'==========================================================================
	'- Дополнительные аргументы
	Public Property Get UrlArguments	' As QueryStringClass
		Set UrlArguments = m_oUrlArguments
	End Property
	
	'==========================================================================
	'- Метаимя страницы
	Public Property Get MetaName
		MetaName = X_PAGE_METANAME
	End Property

	
	'==========================================================================
	'- Страница помощи
	Public Property Get HelpPage
		HelpPage = m_sHelpPage
	End Property

	
	'==========================================================================
	'- Режим отбора
	Public Property Get SelectionMode
		SelectionMode = m_sSelectionMode
	End Property

	
	'==========================================================================
	'-- Начальный путь в дереве
	Public Property Get InitialTreePath
		InitialTreePath = m_sTreeInitPath
	End Property


	'==========================================================================
	Public Property Let InitialTreePath(sNewValue)
		If True=m_vDone Then
			err.Raise -1, "public property let InitialTreePath(sNewValue)", "Поздно менять это свойство!"	
		end if
		m_sTreeInitPath = sNewValue
	End Property

	
	'==========================================================================
	' Конструктор
	Private Sub Class_Initialize
		m_bMayBeInterrupted = True
		' Реализуется Singleton
		If IsObject(g_XTreeSelectorInstance) Then
			If Not (Nothing Is g_XTreeSelectorInstance) Then
				Err.Raise -1, "TreeSelectorClass::Class_Initialize", "Singleton"
			End If
		End if
		EVENTS = "Load,UnLoad,Select,SetInitPath"
		Set m_oEventEngine = X_CreateEventEngine
	End Sub


	'==============================================================================
	' Считывает данные в постоянном хранилище по заданным ключем
	'	[in] sKey As String   - ключ
	'	[in] vData As Variant - результат 
	'	[retval] True - данные считанны, False - ключ не найден
	Public Function GetUserData(sKey, vData)
		GetUserData = XService.GetUserData( GetUserDataName(sKey), vData)
	End Function 


	'==============================================================================
	' Сохраняет данные из постоянного хранилища по заданным ключем
	'	[in] sKey As String   - ключ
	'	[in] vData As Variant - какие-то данные 
	Public Sub SetUserData(sKey, vData)
		XService.SetUserData GetUserDataName(sKey), vData
	End Sub


	'==============================================================================
	' Возвращает имя файла для сохранения пользовательских данных
	'	[in] sSuffix - суфикс имени
	'	[retval] наименование файла
	Private Function GetUserDataName(sSuffix)
		GetUserDataName = "XSFT." & m_sMetaName & "." & sSuffix
	End Function


	'==============================================================================
	' Сохраняет состояние фильтра в кеше
	Public Sub SaveFilterState
		Dim oXmlFilterState		' As IXMLDOMElement - состояние фильтра
		
		If X_MD_PAGE_HAS_FILTER Then
			' Сохраним фильтр
			If m_bOffFilterViewState=False Then
				Set oXmlFilterState = FilterObject.GetXmlState()
				If Not oXmlFilterState Is Nothing Then _
					X_SaveDataCache GetUserDataName("FilterXmlState"), oXmlFilterState
			End If
		End If
	End Sub
	
	
	'==========================================================================
	' Инициализация страницы
	' Вызывается по готовности страницы (X_IsDocumentReady), в том числе фильтра.
	Public Sub InitPage
		Dim aSuitableSelectionModes		' As Array - массив поддерживаемых режимов
		Dim i
		'**************************************************************
		'  ПОЛУЧЕНИЕ ВХОДНЫХ ПАРАМЕТРОВ СТРАНИЦЫ
		'**************************************************************
		' В DialogArguments находит экземпляр класса SelectFromTreeDialogClass
		With X_GetDialogArguments(Null) 
			' переложим кэш прав из вызывающей страницы
			m_sLoader = "x-tree-loader.aspx?METANAME=" & .Metaname
			m_sMetaName 			= .Metaname
			Set x_oRightsCache 		= .GetRightsCache
			m_sTreeInitPath 		= .InitialPath
			Set m_oSelected 		= .InitialSelection
			Set m_oUrlArguments		= .UrlArguments
			m_sLoaderParams 		= .LoaderParams
			m_sExcludeNodes			= .ExcludeNodes
			m_sSelectionMode		= .SelectionMode
			m_sSelectableTypes 		= .SelectableTypes
			m_bSelectionCanBeEmpty	= .SelectionCanBeEmpty
			m_sSelectionEmptyMsg	= .SelectionEmptyMsg
			aSuitableSelectionModes = .SuitableSelectionModes
		End With
		m_oEventEngine.InitHandlers EVENTS, "usrXTreeSelector_On"
		' стандартные обработчики добавляем только, если не нашли прикладных
		m_oEventEngine.InitHandlersEx EVENTS, "stdXTreeSelector_On", True, False

		m_sHelpPage = X_MD_HELP_PAGE_URL

		' установим режим иерархии. Он может быть задан диалоговыми параметрами, либо в противном случае самой страницой (метаданными дерева)
		' Во втором случае, проверим что режим удовлетворят перечню поддерживаемых caller'ом режимов
		If Not hasValue(m_sSelectionMode) Then
			m_sSelectionMode = Empty
			If IsArray(aSuitableSelectionModes) Then
				For i=0 To UBound(aSuitableSelectionModes)
					If aSuitableSelectionModes(i) = TREE_SELECTOR_MODE Then
						m_sSelectionMode = TREE_SELECTOR_MODE
						Exit For
					End If
				Next
				If IsEmpty(m_sSelectionMode) And UBound(aSuitableSelectionModes) > -1 Then m_sSelectionMode = aSuitableSelectionModes(0)
			End If
			If IsEmpty(m_sSelectionMode) Then m_sSelectionMode = TREE_SELECTOR_MODE
		End If

		If IsEmpty(m_sSelectableTypes) Then
			m_sSelectableTypes = TREE_SELECTOR_NODETYPES
		End If
		If IsEmpty(m_bSelectionCanBeEmpty) Then
			m_bSelectionCanBeEmpty  = TREE_SELECTOR_SELECTION_CAN_BE_EMPTY
		End If
		If IsEmpty(m_sSelectionEmptyMsg) Then
			m_sSelectionEmptyMsg = TREE_SELECTOR_SELECTION_EMPTY_MSG
		End If
		
		Internal_InitializeHtmlControls
		m_oTreeView.Loader = m_sLoader
		m_oTreeView.SelectableTypes = m_sSelectableTypes
		Select Case m_sSelectionMode
			Case TSM_LEAFNODE
				m_oTreeView.IsOnlyLeafSel = true
				m_oTreeView.IsMultipleSel = false
			Case TSM_LEAFNODES
				m_oTreeView.IsOnlyLeafSel = true
				m_oTreeView.IsMultipleSel = true
			Case TSM_ANYNODE
				m_oTreeView.IsOnlyLeafSel = false
				m_oTreeView.IsMultipleSel = false
			Case TSM_ANYNODES 
				m_oTreeView.IsOnlyLeafSel = false
				m_oTreeView.IsMultipleSel = true
			Case Else
				Err.Raise -1, "TreeSelectorClass::InitPage", "Неизвестный режим отображения"
		End Select

		' Отображение фильтра:
		If X_MD_PAGE_HAS_FILTER Then
			' Автоперезагрузка дерева имеет смысл только если имеется фильтр
			m_oTreeView.AutoReloading = True
			
			InitFilters
		Else
			XTreeSelector.InitPageFinal
		End If
	End Sub


	'==========================================================================
	' Инициализируем ссылки на HTML контролы
	Public Sub Internal_InitializeHtmlControls
		Set m_oTreeView = document.all("oTreeView")
		If X_MD_PAGE_HAS_FILTER Then
			Set FilterObject = X_GetFilterObject( document.all( "FilterFrame") )
			Set xPaneFilter = document.all("XTree_xPaneFilter")
		End If
		Set NoDataMsg = document.all("XTree_ContentPlaceHolderForTree_NoDataMsg")
		Set TreeHolder = document.all("XTree_ContentPlaceHolderForTree_TreeHolder")
		Set xPaneHeader = document.all("XTree_xPaneHeader")
		Set xPaneCaption = document.all("XTree_xPaneCaption")
		Set xPaneSpecialCaption = document.all("XTree_xPaneSpecialCaption")
		
		If Not TREE_MD_OFF_RELOAD Then _
			Set cmdRefresh = document.all("XTree_cmdRefresh")
		If Not X_MD_OFF_CLEARFILTER Then _
			Set cmdClearFilter = document.all("XTree_cmdClearFilter")
		If Not X_MD_OFF_HIDEFILTER Then _
			Set cmdHideFilter = document.all("XTree_cmdHideFilter")
		Set cmdOK = document.all("XTree_cmdOk")
		Set cmdCancel = document.all("XTree_cmdCancel")
		Set xPaneAccessDenied = document.all("XTree_xPaneAccessDenied")
	End Sub
	
	
	'==========================================================================
	' Инициализация системы фильтров
	Sub InitFilters()
		Dim oFilterXmlState		' As XMLDOMElement - восстановленное состояние фильтра
		
		Dim oParams ' параметры инициализации фильтра
		Set oParams = New FilterObjectInitializationParamsClass
		Set oParams.QueryString = UrlArguments
		Set oParams.OuterContainerPage = Me
		oParams.DisableContentScrolling = True
		m_bOffFilterViewState = X_MD_FILTER_OFF_VIEWSTATE
		
		If false = m_bOffFilterViewState Then
			If X_GetDataCache( GetUserDataName("FilterXmlState"), oFilterXmlState ) Then
				Set oParams.XmlState = oFilterXmlState
			End If
		End If
		
		Set m_oEventEngineFilter = X_CreateEventEngine
		m_oEventEngineFilter.AddHandlerForEvent "EnableControls", Me, "OnEnableControls"
		m_oEventEngineFilter.AddHandlerForEvent "Accel", Me, "OnAccel"
		' Инициализируем фильтр
		FilterObject.Init m_oEventEngineFilter, oParams
		' Дождёмся загрузки фильтров в контейнере FilterObject
		X_WaitForTrue  "XTreeSelector.InitPageFinal", "FilterObject.IsReady"
	End Sub


	'==========================================================================
	' Завершение загрузки страницы
	Public Sub InitPageFinal
		If (X_MD_PAGE_HAS_FILTER And TREE_MD_OFF_LOAD) Then
			NoDataMsg.innerHTML = "Нажмите кнопку &quot;<span title='Нажмите здесь для загрузки...' style='cursor: default;font-weight: bold;' language='VBSCript' onclick='ReloadTree'>Обновить</span>&quot; для загрузки."
		End If
	
		m_oTreeView.Enabled = True
		' Если не отключена начальная загрузка, то грузим дерево
		If Not TREE_MD_OFF_LOAD Then
			Reload
			Internal_FireEvent "SetInitPath", Nothing
		End If
		
		m_vDone = True
		
		EnableControls true
		
		' после загрузки и инициализации всего установим фокус
		If UCase(TreeHolder.style.display) = "BLOCK" Then
			SetFocus
		Else
			NoDataMsg.focus
		End If
	End Sub


	'==========================================================================
	' Перезагрузка дерева
	Public Sub Reload
		' параметры передаемые через URl-параметр RESTR перезапишут параметры из фильтра (от GetRestrictions)
		m_oTreeView.Loader = m_sLoader & "&RESTR=" & XService.UrlEncode(m_sLoaderParams)
		m_bMayBeInterrupted = False
		With X_CreateControlsDisabler(Me)
			TreeHolder.style.display = "NONE"
			NoDataMsg.style.display = "BLOCK"
			NoDataMsg.innerText = "Загрузка данных..."
			XService.DoEvents
			
			On Error Resume Next
			m_oTreeView.Reload
			If Err Then
				X_SetLastServerError m_oTreeView.XClientService.LastServerError, Err.number, Err.Source, Err.Description
				If X_IsSecurityException(m_oTreeView.XClientService.LastServerError) Then
					NoDataMsg.innerText = "В доступе отказано..."
					Err.Clear
					MayBeInterrupted = True
					Exit Sub
				Else
					X_HandleError
				End If
			End If
			On Error GoTo 0
			
			If m_oTreeView.Root.Count = 0 Then
				NoDataMsg.innerText = "Нет данных"
				Internal_FireEvent "Load", Nothing
				NoDataMsg.focus
			Else
				NoDataMsg.style.display = "NONE"
				TreeHolder.style.display = "BLOCK"
				XService.DoEvents
				If Not (m_oSelected Is Nothing) Then
					Set m_oTreeView.Selection =  m_oSelected
					m_oTreeView.ExpandSelection True
				End If
				Internal_FireEvent "Load", Nothing
				SetFocus
			End If
		End With
		m_bMayBeInterrupted = True
	End Sub
	
	
	'==========================================================================
	' Устанавливает фокус на контрол дерева
	Public Sub SetFocus
		window.focus
		X_SafeFocus(m_oTreeView)
	End Sub


	'==========================================================================
	' Возбуждает заданное событие с переданеыми параметрами
	Public Sub Internal_FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub


	'==========================================================================
	' Устанавливает заголовок страницы
	'	[in] sCaption As String - текст заголовка. Может содержать HTML-форматирование.
	Public Sub SetCaption(sCaption)
		Dim aCaption	' Текст заголовка в виде массива строк
		
		' Занесём HTML-код заголовка...
		xPaneCaption.innerHTML = sCaption
		' Получим его "чистый" текст и разoбъем на строки 
		aCaption = Split( "" & xPaneCaption.innerText, vbCr)
		' Выставим заголовок окна = первой строке заголовка
		If UBound(aCaption)>=0 Then
			document.title = aCaption(0) 
		Else
			document.title = ""
		End If	
	End Sub
	
	
	'==========================================================================
	' обработка завершения выбора пользователя
	' [in] bSlient - признак "бесшумной" работы 
	Public Sub ProcessSelection(bSlient)
		Dim oSelection  'выделение на дереве
		
		Set oSelection = m_oTreeView.Selection
		If Not oSelection.hasChildNodes Then
			If  Not m_bSelectionCanBeEmpty Then
				If Not bSlient Then Alert m_sSelectionEmptyMsg
				Exit Sub 
			End If
		End If
		With New SelectEventArgsClass
			Set .Selection = oSelection
			.Silent = bSlient
			.ReturnValue = True
			Internal_FireEvent "Select", .Self()
			If .ReturnValue <> True Then Exit Sub
		End With
		With X_GetDialogArguments(Null) 
			Set .Selection = oSelection
			.Path = m_oTreeView.Path
			X_SetDialogWindowReturnValue True
		End With
		window.close
	End Sub	
	
	
	'==============================================================================
	' Возвращает/устанавливает признак отключения сохранения состояния фильтра
	Public Property Get OffFilterViewState 	' As Boolean
		OffFilterViewState = m_bOffFilterViewState
	End Property
	Public Property Let OffFilterViewState(sValue)
		m_bOffFilterViewState = sValue=True
	End Property
	
	'==============================================================================
	' Возвращает/устанавливает список исключаемых узлов
	Public Property Get ExcludeNodes 	' As String
		ExcludeNodes = m_sExcludeNodes
	End Property
	Public Property Let ExcludeNodes(sValue)
		m_sExcludeNodes = sValue
	End Property
	
	
	'==============================================================================
	' Возвращает экземпляр CROC.IXTreeView
	Public Property Get TreeView
		Set TreeView = m_oTreeView
	End Property
	
	
	'==============================================================================
	' Признак безопасной выгрузки страницы	
	Public Property Get MayBeInterrupted
		If True = m_bMayBeInterrupted Then
			If X_MD_PAGE_HAS_FILTER Then
				MayBeInterrupted = not FilterObject.IsBusy
			Else
				MayBeInterrupted = True
			End If		
		Else
			MayBeInterrupted = False
		End If
	End Property
	Public Property Let MayBeInterrupted(bValue)
		m_bMayBeInterrupted = (true=bValue)
	End Property


	'==============================================================================
	'	Установка доступности элементов управление
	Public Sub EnableControls(bEnable)
		m_oTreeView.Enabled = bEnable
		cmdOk.disabled = Not bEnable
		cmdCancel.disabled = Not bEnable
		If Not X_MD_OFF_CLEARFILTER Then _
			cmdClearFilter.disabled = Not bEnable
		If Not TREE_MD_OFF_RELOAD Then _
			cmdRefresh.disabled = Not bEnable
		If Not X_MD_OFF_HIDEFILTER Then _
			cmdHideFilter.disabled = Not bEnable
		If X_MD_PAGE_HAS_FILTER Then _
			FilterObject.Enabled = bEnable
	End Sub
	
	
	'==============================================================================
	' Изменяет состояние фильтра: скрыто или показано
	Public Sub SwitchFilter()
		If X_MD_PAGE_HAS_FILTER Then
			If UCase(xPaneFilter.style.display) = "NONE" Then
				xPaneFilter.style.display = "block"
				FilterObject.SetVisibility True
				cmdHideFilter.innerText = "Скрыть"
				cmdHideFilter.title = "Скрыть фильтр"
			Else
				xPaneFilter.style.display = "none"
				FilterObject.SetVisibility False
				cmdHideFilter.innerText = "Показать"
				cmdHideFilter.title = "Показать фильтр"
			End If
		End If
	End Sub


	'==============================================================================
	' Обработчик события EnableControls, сгенерированного фильтром (x-filter.htc)
	'	[in] oEventArgs - EnableControlsEventArgs
	Public Sub OnEnableControls(oSender, oEventArgs)
		EnableControls oEventArgs.Enable
	End Sub


	'==============================================================================
	' Обработчик события Accel, сгенерированного фильтром (x-filter.htc)
	'	[in] oEventArgs - AccelerationEventArgsClass
	Public Sub OnAccel(oSender, oEventArgs)
		If oEventArgs.keyCode = VK_ENTER Then
			Reload
		End If
	End Sub
End Class


'==============================================================================
' Параметры события "Select"
Class SelectEventArgsClass
	Public Cancel				' As Boolean - признак прервать цепочку обработки событий.
	Public ReturnValue			' As Booleab - Если False, то страница не закрывается.
	Public Selection			' As IXMLDOMElement - IXTreeView::Selection
	Public Silent				' As Boolean - признак тихой работы (выбор по Enter'у или даблклику)
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'<ОБРАБОТЧИКИ window И document>
'==============================================================================
' Обработка клавиатуры
Sub Document_onKeyPress()
	Select Case window.event.keyCode
		Case VK_ENTER	'Enter
			XTree_cmdOk_OnClick
		Case VK_ESC		'Esc
			XTree_cmdCancel_OnClick
	End Select
End Sub


'==============================================================================
' Попытка выгрузки страницы
Sub window_OnBeforeUnload
	If IsNothing(g_XTreeSelectorInstance) Then Exit Sub
	If XTreeSelector.MayBeInterrupted Then Exit Sub
	window.event.returnValue = "Внимание!" & vbNewLine & "Выгрузка страницы в данный момент может привести к возникновению ошибки!"
End Sub


'==============================================================================
' Инициализация страницы
Sub window_OnLoad
	X_WaitForTrue "XTreeSelector.InitPage()" , "X_IsDocumentReadyEx( null, ""XFilter"")"
End Sub


'==============================================================================
' Выгрузка окна
Sub Window_OnUnLoad
	If IsNothing(g_XTreeSelectorInstance) Then Exit Sub
	' При необходимости вызовем пользовательский обработчик...
	XTreeSelector.Internal_FireEvent "UnLoad", Nothing
	XTreeSelector.SaveFilterState
End Sub


'==============================================================================
' Обработчик вызова справки
Sub Document_OnHelp
	If IsNothing(g_XTreeSelectorInstance) Then Exit Sub
	If X_MD_HELP_AVAILABLE Then
		window.event.returnValue = False
		X_OpenHelp XTreeSelector.HelpPage
	End If
End Sub
'</ОБРАБОТЧИКИ window И document>


'<ОБРАБОТЧИКИ КОНТРОЛА TREEVIEW>
'==============================================================================
' Обработаем ENTER
Sub	TreeView_OnKeyPress(oSender, nKeyAscii)
	If nKeyAscii <> VK_ENTER then exit sub
	If Not (XTreeSelector.SelectionMode = TSM_LEAFNODE or XTreeSelector.SelectionMode = TSM_ANYNODE) Then Exit Sub
	If Nothing Is oSender.ActiveNode Then Exit Sub
	If Not oSender.ActiveNode.IsLeaf Then Exit Sub
	If Not oSender.ActiveNode.IsSelectable Then Exit Sub
	' если был нажат Enter на листовом выбираемом узле в режиме TSM_LEAFNODE или TSM_ANYNODE:
	XTreeSelector.ProcessSelection true	
End Sub


'==============================================================================
' Обработаем DblClick
Sub TreeView_OnDblClick(oSender, oTreeNode)
	If Not (XTreeSelector.SelectionMode = TSM_LEAFNODE Or XTreeSelector.SelectionMode = TSM_ANYNODE) Then Exit Sub
	If Nothing Is oTreeNode Then Exit Sub
	If Not oTreeNode.IsLeaf Then Exit Sub
	If Not oTreeNode.IsSelectable Then Exit Sub
	XTreeSelector.ProcessSelection True
End Sub

'==============================================================================
' Обработчик события OnDataLoading для TreeView.
'	Используется для включения в запрос на получение данных
'	иерархии информации фильтра.
Sub TreeView_OnDataLoading( oSender,  nQuerySet,  sNodePath,  sObjectType,  sObjectID,  oRestrictions)
	XTreeSelector.MayBeInterrupted = False
	internal_TreeInsertRestrictions oRestrictions, XTreeSelector.UrlArguments.QueryString
	internal_TreeInsertRestrictions oRestrictions, GetRestrictions
	internal_TreeSetExcludeNodes oRestrictions, XTreeSelector.ExcludeNodes
End Sub


'==============================================================================
' Обработчик события OnDataLoaded для TreeView
Sub TreeView_OnDataLoaded( oSender, nQuerySet, sNodePath, sObjectType, sObjectID )
	XTreeSelector.MayBeInterrupted = True
End Sub
'</ОБРАБОТЧИКИ КОНТРОЛА TREEVIEW>


'<ОБРАБОТЧИКИ КНОПОК>
'==============================================================================
' обработка нажатия кнопки OK
Sub XTree_cmdOK_OnClick
	XTreeSelector.ProcessSelection False
End Sub


'==============================================================================
' обработка нажатия кнопки Cancel
Sub XTree_cmdCancel_OnClick
	window.close
End Sub


'==============================================================================
' Обработчик нажатия на кнопку "справка"
Sub XTree_cmdOpenHelp_OnClick
	Document_OnHelp
End Sub


'==============================================================================
'	Перезагрузка
Sub XTree_cmdRefresh_OnClick
	If IsNothing(g_XTreeSelectorInstance) Then Exit Sub
	XTreeSelector.Reload
End Sub


'==============================================================================
'	Сброс значения фильтра
Sub XTree_cmdClearFilter_OnClick
	If X_MD_PAGE_HAS_FILTER Then FilterObject.ClearRestrictions()
End Sub


'==============================================================================
' Обработчик кнопки "Скрыть"/"Показать" фильтр
Sub XTree_cmdHideFilter_onClick()
	XTreeSelector.SwitchFilter()
End Sub
'<ОБРАБОТЧИКИ КНОПОК>


'==============================================================================
' Перегрузка дерева.
' Примечание: вынесено из
Sub ReloadTree
	If IsNothing(g_XTreeSelectorInstance) Then Exit Sub
	XTreeSelector.Reload
End Sub


'==============================================================================
' Возвращает состояние фильтра (строку ограничений)
Function GetRestrictions()
	Dim oArguments		' As FilterObjectGetRestrictionsParamsClass
	Dim oBuilder		' As IParamCollectionBuilder
	If X_MD_PAGE_HAS_FILTER Then
		Set oArguments = New FilterObjectGetRestrictionsParamsClass
		Set oBuilder = New QueryStringParamCollectionBuilderClass
		Set oArguments.ParamCollectionBuilder = oBuilder
		FilterObject.GetRestrictions(oArguments)
		If False=oArguments.ReturnValue Then
			GetRestrictions = vbNullString
		Else
			GetRestrictions = oBuilder.QueryString
		End If	 	
	Else
		GetRestrictions = vbNullString
	End If	
End Function


'==============================================================================
'	Установка доступности элементов управление
Sub EnableControls(bEnable)
	XTreeSelector.EnableControls bEnable
End Sub


'==============================================================================
' Стандартный обработчик "SetInitPath" - начальная установка пути в дереве, заданного параметром страницы
Sub stdXTreeSelector_OnSetInitPath(oSender, oEventArgs)
	oSender.TreeView.SetNearestPath oSender.InitialTreePath, False, True
End Sub
