'===============================================================================
'@@!!FILE_x-tree
'<GROUP !!SYMREF_VBS>
'<TITLE x-tree - Базовое обслуживание иерархии объектов>
':Назначение:
'	Набор общих функций, процедур и классов, используемых в реализации 
'	отображения иерархии объектов.
'===============================================================================
'@@!!CONSTANTS_x-tree
'<GROUP !!FILE_x-tree><TITLE Константы>
'@@!!FUNCTIONS_x-tree
'<GROUP !!FILE_x-tree><TITLE Функции и процедуры>
'@@!!CLASSES_x-tree
'<GROUP !!FILE_x-tree><TITLE Классы>

Option Explicit

'@@PANEL_MIN_WIDTH
'<GROUP !!CONSTANTS_x-tree>
':Назначение:   Минимально допустимая ширина панели (иерархии или меню)
const PANEL_MIN_WIDTH		= 5		' минимально допустимая ширина панели  

'@@XTreePageClass
'<GROUP !!CLASSES_x-tree><TITLE XTreePageClass>
':Назначение:   Инкапсулирует логику работы страницы иерархии объектов
'
'@@!!MEMBERTYPE_Methods_XTreePageClass
'<GROUP XTreePageClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_XTreePageClass
'<GROUP XTreePageClass><TITLE Свойства>
Class XTreePageClass

	'@@XTreePageClass.HelpPage
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE HelpPage>
	':Назначение:	URL страницы помощи
	':Примечание:	Значение по умолчанию - vbNullString
	':Сигнатура:	Public HelpPage [As String]
	Public HelpPage					' Страница помощи

	'@@XTreePageClass.HelpAvailiabe
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE HelpAvailiabe>
	':Назначение:	Признак доступности помощи для данной страницы
	':Примечание:	Значение по умолчанию - False
	':Сигнатура:	Public HelpAvailiabe [As Boolean]
	Public HelpAvailiabe

	'@@XTreePageClass.OffLoad
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE OffLoad>
	':Назначение:	Запрет загрузки дерева сразу после инициализации страницы
	':Примечание:	Значение по умолчанию - False
	':Сигнатура:	Public OffLoad [As Boolean]
	Public OffLoad

	'@@XTreePageClass.OffShowReload
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE OffShowReload>
	':Назначение:	Запрет показа кнопки "Обновить"
	':Примечание:	Значение по умолчанию - False
	':Сигнатура:	Public OffShowReload [As Boolean]
	Public OffShowReload

	'@@XTreePageClass.AllowDragDrop
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE AllowDragDrop>
	':Назначение:	Признак доступности операции переноса узлов дерева мышью
	':Примечание:	Значение по умолчанию - False
	':Сигнатура:	Public AllowDragDrop [As Boolean]
    Public AllowDragDrop

	Public m_sLoading				' Строка, в которой хранится сообщение о загрузке
	Public m_dSplitterPos			' Положение сплиттера в % (!!! но не целое !!!)
	Public m_oMenuXSLCollection		' хеш XMLDOMDocument'ов XSL страниц всех меню. Ключ - наименование level'a (типа)
	Public m_oMenu					' Объект меню
	Public m_oMenuHTTP				' Объект MSXML2.XMLHTTP, используемый для загрузке меню с сервера
	Public m_oMenuCache				' кеш меню. объект Dictionary
	Public m_sMenuXslDefault		' наименование меню-стильшита по дефолту
	Public m_oMenuXslDefault		' XMLDOMDocument дефолтового стильшита меню
	Public m_bMenuIsReady			' Признак готовности(загруженности) меню
	Public m_bPendingRunDefaultMenuItem		' Признак необходимости выполнить пункт меню по умолчанию
	Public m_bPendingShowPopup		' Признак необходимости показать PopUp меню
	Private m_bPendingShowPopupNearActiveNode	' Признак отображать PopUp меню, когда оно загрузится, рядом с активныи узлом
	Public m_oXmlStatesPersist		' XMLDOMDocument для сохранения состояния меню
	Public m_nTimeout				' Признак установленного для вывода меню таймера
	Public m_oTreeMD				' Метаданные дерева
	Public m_oMenuSect				' Объект QueryString, в котором хранится состояние секций меню

	Public m_sTreePath				' путь к узлу дерева  пары type;id, разделенные "|" 
									'  показывающие путь от корня  до нужного узла
	Public m_sTreeInitPath			' путь к узлу дерева, заданный с помощью параметра INITPATH страницы

    Private m_oPageParams			' Объект QueryString, содержащий параметры страницы
	Private m_sMetaName				' Имя страницы в МетаДанных
	Private m_sMenuLoaderUrl		' Имя формирователя дерева (см. use-menu в метаданных)
	Private m_oTreeView				' As CROC.IXTreeView - контрол дерева
	Private EVENTS					' список поддерживаемых событий
	Private m_oEventEngine			' As EventEngineClass
	Private m_bMayBeInterrupted 		' As Boolean - Признак безопасной выгрузки страницы
	Private m_oRequestingMenuTreeNode	' As IXTreeNode - активный узел на момент _начала_ показа меню
	Private m_bOffFilterViewState		' As Boolean	- Признак "Не сохранять состояние фильтра"
	Private m_bAccessDenied			' Признак режима "В доступе отказано"
	Private m_oEventEngineFilter	' As EventEngine - EventEngine для получения событий от фильтра (передается в x-filter.htc)
	Private m_oDragDropController   ' As TreeViewNodeDragDropController - контроллер операции переноса узлов дерева
	
	' HTML Controls
	Private xPaneFilter				' As IHTMLElement - контейнер фильтра
	Private xPaneHeader				' As IHTMLElement - контейнер заголовков и кнопок
	Private xPaneCaption			' As IHTMLElement - заголовок
	Private xPaneSpecialCaption		' As IHTMLElement - дополнительный заголовок
	Private cmdHideFilter			' As IHTMLElement - кнопка "Скрыть"/"Показать" (фильтр)
	Private cmdRefresh				' As IHTMLElement - кнопка "Обновить"
	Private cmdClearFilter			' As IHTMLElement - кнопка "Очистить" (фильтр)
	Private idNormalTreeBody		' As IHTMLElement - TD - ячейка с деревом, меню и фильтров
	Private xPaneAccessDenied		' As IHTMLElement - TD - ячейка с надписью об отсутствии доступа
	Private TreeHolderCell			' As IHTMLElement - 
	Private TreeHolder				' As IHTMLElement - контейнер для дерева (CROC.IXTreeView)
	Private MenuHolder				' As IHTMLElement - контейнер для MenuHtml
	Private MenuHtml				' Ссылка на DHTML Behavior XMenuHtml (x-menu-html.htc)
	
	'==============================================================================
	' "Конструктор" (обработчик события инстанцирования класса)
	Private Sub Class_Initialize
		Dim oQS					' клон QueryString
		
		' ИНИЦИАЛИЗАЦИЯ ПАРАМЕТРОВ
		m_bAccessDenied = X_ACCESS_DENIED 
		'получаем признак отображения справки
		HelpAvailiabe = X_MD_HELP_AVAILABLE 
		' и URL страницы справки
		HelpPage = X_MD_HELP_PAGE_URL
		' признак выключения загрузки
		OffLoad = TREE_MD_OFF_LOAD
		' признак выключения показа кнопки "Обновить"
		OffShowReload = TREE_MD_OFF_RELOAD
		' Получаем значение положения сплиттера
		m_dSplitterPos = TREE_MD_WIDTH
		' Признак доступности операции переноса узлов
		AllowDragDrop = TREE_MD_ALLOW_DRAG_DROP

		m_bMayBeInterrupted = true
		
		' Раз нет доступа то нам тут делать нечего 
		If m_bAccessDenied Then
			Exit Sub
		End If

		If IsObject(g_oXTreePage) Then _
			If Not g_oXTreePage Is Nothing Then _
				Err.Raise -1, "XTreePageClass::Class_Initialize", "Допустимо существование только одного экземпляра XTreePageClass"
		' инициализируем ссылку на XTreeView. В html-странице объект имеет id oTreeView
		Set m_oTreeView = document.all("oTreeView")
		EVENTS = "BeforeEdit,Edit,AfterEdit," & _
			"BeforeCreate,Create,AfterCreate," & _
			"BeforeDelete,Delete,AfterDelete," & _
			"MenuBeforeShow,MenuUnLoad,MenuRendered,Load,Unload," & _
			"BeforeMove,Move,AfterMove,SelectParent," & _
			"SetInitPath"
		Set m_oEventEngine = X_CreateEventEngine
		' Инициализируем коллекцию обработчиков события
		m_oEventEngine.InitHandlers EVENTS, "usrXTree_On"
		m_oEventEngine.InitHandlersEx EVENTS, "stdXTree_On", True, False
		
		m_sMetaName = X_PAGE_METANAME		
		
		Set m_oDragDropController = Nothing

        If AllowDragDrop Then
		    ' Инициализация контроллера операции переноса
		    Set m_oDragDropController = New TreeNodeDragDropController
		    m_oDragDropController.EventEngine.InitHandlers XTREENODEDRAGDROPCONTROLLER_EVENTS, "usrXTree_On"
		    m_oDragDropController.EventEngine.InitHandlersEx XTREENODEDRAGDROPCONTROLLER_EVENTS, "stdXTree_On", True, False
		End If
		
		'  ПОЛУЧЕНИЕ ВХОДНЫХ ПАРАМЕТРОВ СТРАНИЦЫ
		Set m_oPageParams = X_GetQueryString()
		' Читаем начальный путь дерева
		m_sTreeInitPath = m_oPageParams.GetValue("INITPATH","")
		' Транслируем параметры страницы в параметры загрузчика, выкусив ненужные
		Set oQS = m_oPageParams.Clone
		oQS.Remove "RET"
		oQS.Remove "HOME"
		oQS.Remove "INITPATH"
		m_bMenuIsReady = False
		m_bPendingRunDefaultMenuItem = False
		
		' установим загрузчик
		m_oTreeView.Loader = "x-tree-loader.aspx" & "?" & oQS.QueryString
		m_sLoading = "Загрузка..."

		' загрузим дефолтовый xsl-стильшит для всех меню (асинхронно)
		m_sMenuXslDefault = TREE_MD_MENUSTYLESHEET
		Set m_oMenuXslDefault = XService.XMLGetDocument()
		m_oMenuXslDefault.async = true
		m_oMenuXslDefault.load(XService.BaseURL() & "XSL\" & m_sMenuXslDefault)
		
		' Загрузим данные о состоянии меню (в m_oXmlStatesPersist)
		LoadMenuStates
		'получаем имя формирователя меню
		m_sMenuLoaderUrl = "x-tree-menu.aspx?METANAME=" & m_sMetaName
		' коллекция стильшитов меню
		Set m_oMenuXSLCollection = CreateObject("Scripting.Dictionary")
		' коллекция закешированных меню
		Set m_oMenuCache = CreateObject("Scripting.Dictionary")
		Set m_oMenu = Nothing
	End Sub

	'==============================================================================
	' Инициализирует фильтр
	Public Sub Internal_InitFilter
		Dim oFilterXmlState	' As XMLDOMElement - восстановленное состояние фильтра
		Dim oParams 		' параметры инициализации фильтра

		If X_ACCESS_DENIED Then Exit Sub		
		Set oParams = New FilterObjectInitializationParamsClass
		Set oParams.QueryString = QueryString
		Set oParams.OuterContainerPage = Me
		oParams.DisableContentScrolling = True
		
		m_bOffFilterViewState = X_MD_FILTER_OFF_VIEWSTATE

		' восстановим состояние фильтра, если это не отключено
		If m_bOffFilterViewState=False Then
			If X_GetDataCache( GetCacheFileName("FilterXmlState"), oFilterXmlState) Then
				Set oParams.XmlState = oFilterXmlState
			End If
		End If
		' Инициализируем фильтр
		Set m_oEventEngineFilter = X_CreateEventEngine
		m_oEventEngineFilter.AddHandlerForEvent "EnableControls", Me, "Internal_On_Filter_EnableControls"
		m_oEventEngineFilter.AddHandlerForEvent "Accel", Me, "Internal_On_Filter_Accel"
		m_oEventEngineFilter.AddHandlerForEvent "Apply", Me, "Internal_On_Filter_Apply"		
		g_oFilterObject.Init m_oEventEngineFilter, oParams
	End Sub

	'==============================================================================
	' Финальная инициализация страницы
	Public Sub Internal_InitPageFinal
		If X_ACCESS_DENIED Then Exit Sub
		EnableControls True
		Internal_FireEvent "Load", Nothing	
		ResizePanels()
		If Not OffLoad Then
			XService.DoEvents 
			MenuHtml.SetStatus "&nbsp;"
			Reload() 
			Internal_FireEvent "SetInitPath", Nothing
		Else
			MenuHtml.SetStatus "&nbsp;"
		End If
	End Sub

	'==========================================================================
	' Инициализируем ссылки на HTML контролы
	Public Sub Internal_InitializeHtmlControls
		If X_MD_PAGE_HAS_FILTER Then
			Set xPaneFilter = document.all("XTree_xPaneFilter")
		End If
		Set xPaneHeader = document.all("XTree_xPaneHeader")
		Set xPaneCaption = document.all("XTree_xPaneCaption")
		Set xPaneSpecialCaption = document.all("XTree_xPaneSpecialCaption")
		
		If Not TREE_MD_OFF_RELOAD Then _
			Set cmdRefresh = document.all("XTree_cmdRefresh")
		If Not X_MD_OFF_CLEARFILTER Then _
			Set cmdClearFilter = document.all("XTree_cmdClearFilter")
		If Not X_MD_OFF_HIDEFILTER Then _
			Set cmdHideFilter = document.all("XTree_cmdHideFilter")
		
		Set idNormalTreeBody = document.all("XTree_idNormalTreeBody")
		Set xPaneAccessDenied = document.all("XTree_xPaneAccessDenied")
		Set TreeHolderCell = document.all("XTree_TreeHolderCell")
		Set TreeHolder = document.all("TreeHolder")
		Set MenuHolder = document.all("XTree_MenuHolder")
		Set MenuHtml = document.all("MenuHtml")
	End Sub
	
	'==========================================================================
	' Генерирует заданное собыие
	'	[in] sEventName As String - наименование события
	'	[in] oEventArgs As Object - параметры события
	Public Sub Internal_FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub
	
	'==============================================================================
	' Загружает данные о состоянии меню
	Private Sub LoadMenuStates
		Dim sMenuStates ' Строка состояния видимости элементов меню
		Set m_oMenuSect = X_GetEmptyQueryString()
		If X_GetViewStateCache( GetCacheFileName("MenuStates"), sMenuStates) Then _
			m_oMenuSect.QueryString = sMenuStates
	End Sub

	'==============================================================================
	' Сохраняет данные о состоянии меню и фильтра
	Public Sub Internal_SaveStateOnUnload
		Dim oXmlFilterState ' As IXMLDOMElement, Состояние фильтра
		' проверка на IsObject() нужна на случай неполной инициализации страницы
		' в случае проблем при загрузке скриптов
		If IsObject(m_oMenuSect) Then _
			X_SaveViewStateCache GetCacheFileName("MenuStates"), m_oMenuSect.QueryString 
		
		If X_MD_PAGE_HAS_FILTER Then
			' Сохраним фильтр
			If m_bOffFilterViewState=False Then
				Set oXmlFilterState = g_oFilterObject.GetXmlState()
				If Not oXmlFilterState Is Nothing Then _
					X_SaveDataCache GetCacheFileName("FilterXmlState"), oXmlFilterState
			End If
		End If
	End Sub
	
	'==============================================================================
	'@@XTreePageClass.GetUserData
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE GetUserData>
	':Назначение:	Считывает данные из постоянного хранилища по заданному ключу
	':Параметры:
	'	[in] sKey As String   - ключ
	'	[in] vData As Variant - результат 
	':Результат:
	'	True - данные считаны, False - ключ не найден
	':Сигнатура:	Public Function GetUserData(sKey, vData) [As Boolean]
	Public Function GetUserData(sKey, vData)
		GetUserData = XService.GetUserData( GetCacheFileName(sKey), vData)
	End Function 

	'==============================================================================
	'@@XTreePageClass.SetUserData
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE SetUserData>
	':Назначение:	Сохраняет данные в постоянном хранилище по заданному ключу
	':Параметры:
	'	[in] sKey As String   - ключ
	'	[in] vData As Variant - данные для сохранения в хранилище
	':Сигнатура:	Public Sub SetUserData(sKey, vData)
	Public Sub SetUserData(sKey, vData)
		XService.SetUserData GetCacheFileName(sKey), vData
	End Sub

	'==============================================================================
	' Возвращает имя файла для сохранения пользовательских данных
	'	[in] sSuffix - суфикс имени
	'	[retval] наименование файла
	Private Function GetCacheFileName(sSuffix)
		GetCacheFileName = "XT." & MetaName & "." & sSuffix
	End Function

	'==============================================================================
	' Отображает popup-меню для текущего узла дерева
	' В обычных условиях не предназначен для вызова из прикладного кода
	Public Sub ShowPopupMenu
		If m_bMenuIsReady = False Then Exit Sub
		m_oMenu.ShowPopupMenu Me
	End Sub
	
	'==============================================================================
	' Отобразить popup-меню рядом с активным узлом
	Public Sub Internal_ShowPopupMenuNearActiveNode
		Dim nPosLeft, nPosTop, nPosRight, nPosBottom	' относительные координаты выбранной строки списка
		Dim nTreeViewPosX, nTreeViewPosY	' экранные координаты TreeView
		Dim nPendingMenuPosX				'- Экранная Х-координата точки показа PopUp меню, после того как оно будет загружено
		Dim nPendingMenuPosY				'- Экранная Y-координата точки показа PopUp меню, после того как оно будет загружено
		
		If TreeView.ActiveNode.GetCoords(nPosLeft, nPosTop, nPosRight, nPosBottom) Then
			X_GetHtmlElementScreenPos TreeView, nTreeViewPosX, nTreeViewPosY
			nPendingMenuPosX = nTreeViewPosX+nPosLeft
			nPendingMenuPosY = nTreeViewPosY+nPosBottom
		End If
		m_oMenu.ShowPopupMenuWithPos Me, nPendingMenuPosX, nPendingMenuPosY
	End Sub
	
	'==============================================================================
	' Вызов пункта меню по умолчанию...
	' В обычных условиях не предназначен для вызова из прикладного кода
	Public Sub CallMenuDefaultItem
		Dim oMenuAction		' пункт меню по умолчанию

		If m_bMenuIsReady = False Then Exit Sub
		m_bPendingRunDefaultMenuItem = False
		' поищим видимый, не заблокированный пункт меню, помеченный флагом "пункт по умолчанию"
		Set oMenuAction = m_oMenu.XmlMenu.selectSingleNode("//i:menu-item[@default=1 and not(@hidden) and not(@disabled)]")
		If oMenuAction Is Nothing Then
			' если не нашли пункт явно помеченный как дефолтовый, то просто возьмем первый
			Set oMenuAction = m_oMenu.XmlMenu.selectSingleNode("//i:menu-item[not(@hidden) and not(@disabled)]")
		End If
		If Not oMenuAction Is Nothing Then
			' нашли - выполним
			m_oMenu.RunExecutionHandlers Me, oMenuAction.getAttribute("n")
		End If
	End Sub
	
	'==============================================================================
	' Начинает процедуру загрузки меню. Генерирует событие "MenuUnLoad" и по таймауту вызывает ShowMenuNow.
	' Таймаут нажен для того, чтобы при быстром переключении узлов меню не грузилось.
	' В обычных условиях не предназначен для вызова из прикладного кода.
	Public Sub ShowMenu()
		Const MENU_TIMEOUT  = 1000  ' Пауза перед выводом меню
		m_bPendingRunDefaultMenuItem = False
		m_bMenuIsReady = False
		If False=IsEmpty(m_nTimeout) Then
			clearTimeout m_nTimeout
			m_nTimeout=Empty
			Internal_FireEvent "MenuUnLoad", Nothing
		End If	
		m_nTimeout = setTimeout( "g_oXTreePage.BeginShowMenu()", MENU_TIMEOUT, "VBScript")
		MenuHtml.SetStatus m_sLoading
	End Sub

	'==============================================================================
	' Создает и возвращает Xml-запрос на получение меню (для x-tree-menu.aspx).
	' В обычных условиях не предназначен для вызова из прикладного кода.
	Public Function CreateMenuRequest	' As XMLDOMElement
		Dim oNode			'  XMLDOMNode
		Dim oMenuPostData	'  Данные, посылаемые меню
		Dim aPath			'  Путь до узла
		Dim i
		' Создадим объект для отсылки данных
		Set oMenuPostData = XService.XMLGetDocument
		oMenuPostData.async = False
		oMenuPostData.appendChild oMenuPostData.createProcessingInstruction("xml","version=""1.0"" encoding=""windows-1251""") 
		oMenuPostData.appendChild oMenuPostData.createElement("tree-menu-request")
		Set oNode = oMenuPostData.documentElement
		aPath = Split( m_sTreePath, "|")
		For i=0 To UBound(aPath) Step 2
			set oNode = oNode.appendChild(oMenuPostData.createElement("n"))
			oNode.setAttribute "ot", aPath(i)
			oNode.setAttribute "id", aPath(i+1)
		Next
		Set oNode = oMenuPostData.documentElement.appendChild(oMenuPostData.createElement("restrictions"))
		
		internal_TreeInsertRestrictions oNode, GetRestrictions
		Set CreateMenuRequest = oMenuPostData
	End Function

	'==============================================================================
	' Начинает отрисовку меню. Вызывается по тайм-ауту, установленному в ShowMenu. 
	' Метод не должен вызываться напрямую.
	Public Sub BeginShowMenu()
		Dim sMenuLoaderUrl		' урл страницы получения меню (x-tree-menu.aspx)
		Dim aPath				' Путь до узла
		Dim oMenuCached			' закешированное меню
		Dim oMenuPostData		' узел tree-menu-request для посылки на сервер
		Dim sKeyPath			' ключ в кеше меню - путь от корня до текущего узла
		Dim sKeyType			' ключ в кеше меню - тип текущего узла
		Dim bIsEmptyMenu		' Признак пустого меню
		
		' нас действительно вызвали по тайм-ауту из ShowMenu?
		If IsEmpty(m_nTimeout) Then Exit Sub
		clearTimeout m_nTimeout
		Set m_oRequestingMenuTreeNode = m_oTreeView.ActiveNode
		' получаем URL меню
		aPath = Split( m_sTreePath,"|")
		If UBound(aPath) < 1 Then 
			MenuHtml.SetStatus "&nbsp;"
			bIsEmptyMenu = (0 = m_oTreeView.Root.Count)
		Else
			bIsEmptyMenu = false
		End If	

		m_bMenuIsReady = False
		' если предыдущее меню не догрузилось, прервем его
		If IsObject(m_oMenuHTTP) Then m_oMenuHTTP.abort
		' проверим, что меню текущего узла статическое, если так, то возьмем из кеша и вызовем EndShowMenu
		If Not m_oTreeView.ActiveNode Is Nothing Then
			Set oMenuCached = Nothing
			sKeyPath = "path:" & GetPathOfTypes()
			sKeyType = "type:" & m_oTreeView.ActiveNode.Type
			If m_oMenuCache.Exists(sKeyPath ) Then
				Set oMenuCached = m_oMenuCache.Item( sKeyPath )
			ElseIf m_oMenuCache.Exists( sKeyType ) Then
				Set oMenuCached = m_oMenuCache.Item( sKeyType )
			End If
			If Not oMenuCached Is Nothing Then
				' нашли закешированное меню
				EndShowMenu oMenuCached
				Exit Sub
			End If
		End If
		' закешированного меню нет
		' создадим xml-запрос загрузчику меню
		Set oMenuPostData = CreateMenuRequest()
		If(bIsEmptyMenu) Then
			' установим признак того, что требуется меню для пустого дерева
			oMenuPostData.documentElement.setAttribute "for-empty-tree", "1"
		End If		
		' создадим объект для асинхронной загрузки xml
		Set m_oMenuHTTP = CreateObject( "Msxml2.XMLHTTP")
		' Формируем URL меню
		sMenuLoaderUrl = m_sMenuLoaderUrl & "&tm=" & CDbl(Now)
		' Пошлем запрос на сервер асинхронно (true в 3-м параметре)
		m_oMenuHTTP.open "POST", sMenuLoaderUrl, true
		' по получении ответа вызовем ProcessMenuXML
		m_oMenuHTTP.onreadystatechange = GetRef("ProcessMenuXML")
		m_oMenuHTTP.send oMenuPostData 		
	End Sub

	'==============================================================================
	' Заканчивает формирование меню. На вход принимает корневой узел menu xml-меню.
	' Создает экземпляр класса MenuClass, устанавливает стандартные обработчики, 
	' добавляет предопределенный набор макросов в коллекцию
	'	[in] oMenuXML - xml-меню (закешированное, либо полученное с сервера от m_oMenuHTTP)
	' В обычных условиях не предназначен для вызова из прикладного кода
	Public Sub EndShowMenu(oMenuXML)
		Dim sKey		' ключ в кеше меню
		Dim oMenuXSL	' XMLDOMDocument Xslt-стильшита

		If IsObject(m_oRequestingMenuTreeNode) Then
			 If Not (m_oRequestingMenuTreeNode Is m_oTreeView.ActiveNode) Then Exit Sub
		End If
		' создадим объект меню и установим стандартные обработчики
		Set m_oMenu = New MenuClass		
		m_oMenu.SetMacrosResolver X_CreateDelegate(Me, "MenuMacrosResolver")
		m_oMenu.SetVisibilityHandler X_CreateDelegate(Me, "MenuVisibilityHandler")
		m_oMenu.SetExecutionHandler X_CreateDelegate(Me, "MenuExecutionHandler")
		m_oMenu.Init oMenuXML
		' если можно закешируем меню. определяет атрибутом cache-for корневго элемента menu
		If Not IsNull(oMenuXML.getAttribute("cache-for")) And Not m_oTreeView.ActiveNode Is Nothing Then
			If oMenuXML.getAttribute("cache-for") = "type" Then
				sKey = "type:" & m_oTreeView.ActiveNode.Type
			ElseIf oMenuXML.getAttribute("cache-for") = "level" Then
				sKey = "path:" & GetPathOfTypes()
			End If
			Set m_oMenuCache.Item(sKey) = oMenuXML
		End If
		' удостоверимся, что в коллекции есть предопределенный набор параметров: ObjectID, ObjectType
		If Not m_oMenu.Macros.Exists("ObjectID") Then _
			m_oMenu.Macros.Add "ObjectID", Null
		If Not m_oMenu.Macros.Exists("ObjectType") Then _
			m_oMenu.Macros.Add "ObjectType", Null
			
		' получим объект XSLT-стильшит для рендеренга по его наименованию
		' Если m_oMenu.MenuXslTemplate вернет ничего, то GetXsl вернет шаблон по умолчанию
		Set oMenuXSL = GetXsl( m_oMenu.MenuXslTemplate )
		
		' Сгенерируем событие перед отрисовкой меню, передав туда ссылку на меню и xsl-шаблон
		' Прикладной код может модифицировать данные меню и/или используемый шаблон для рендеренга
		If m_oEventEngine.IsHandlerExists("MenuBeforeShow") Then
			With New TreeMenuEventArgsClass
				Set .Menu = m_oMenu
				Set .MenuXsl = oMenuXSL
				Internal_FireEvent "MenuBeforeShow", .Self
				Set oMenuXSL = .MenuXsl
			End With
		End If
		
		' отрендерим меню в HTML. 
		MenuHtml.Render Me, m_oMenu, oMenuXSL
		
		m_bMenuIsReady = True
		' принудительный вызов обработки меню в HTML
		ProcessMenuHTML
		
		' После показа меню сгененируем событие, 
		' чтобы прикладной код мог доработать его визиальное представление программно
		If m_oEventEngine.IsHandlerExists("MenuRendered") Then
			With New TreeMenuEventArgsClass
				Set .Menu = m_oMenu
				Internal_FireEvent "MenuRendered", .Self
			End With
		End If
		
		PostProcessMenu
	End Sub

	'==============================================================================
	' Инициализация меню, представленная HTML
	Private Sub ProcessMenuHTML()
		Dim aIDs				' Список идентификаторов секций меню
		Dim sID					' Идентификатор секции меню
		Dim sMode				' Признак открытости секции
		Dim oSectionTHEAD	    ' Заголовок секции меню (HTML_THEAD_Element) 	

		' обрабатываем секции меню (скрываем/показываем) в зависимости от состояния
		aIDs = m_oMenuSect.Names()
		' по всем вхождениям в m_oMenuSect
		For Each sID In aIDs
			' пытаемся получить секцию меню		
			Set oSectionTHEAD = MenuHtml.Html.all(sID)
			If Not (oSectionTHEAD Is Nothing) Then
				'и в случае успеха показываем или скрываем данную секцию
				sMode = CStr(m_oMenuSect.GetValue(sID, oSectionTHEAD.ExtendedIsCollapsed))
				SetMenuSectionState oSectionTHEAD, sMode
			End If	
		Next
	End Sub

	'==============================================================================
	' Постобработка меню. Обрабатывает дабл-клики и вызов контекстного меню, которые были сделаны когда меню еще не было сформировано
	Private Sub PostProcessMenu
		Const MENU_ITEM_DELAY  = 10		' задержка перед выполнением пункта меню "по умолчанию"

		If m_bPendingRunDefaultMenuItem Then
			' был даблклик на листовом элементе - надо выполнить пункт по умолчанию
			m_bPendingRunDefaultMenuItem = False 
			' Напрямую из обработчика изменения состояния IXMLDomDocument выполнять код нельзя !!!
			' Поэтому отложим выполнение на несколько милисекунд и выпихнем вызов за рамки обработчика...
			window.setTimeout "g_oXTreePage.CallMenuDefaultItem", MENU_ITEM_DELAY, "VBScript"
		ElseIf m_bPendingShowPopup Then
			' нажимали правую кнопку мыши - пакажем им popup-меню
			m_bPendingShowPopup = False
			' Напрямую из обработчика изменения состояния IXMLDomDocument выполнять код нельзя !!!
			' Поэтому отложим выполнение на несколько милисекунд и выпихнем вызов за рамки обработчика...
			If m_bPendingShowPopupNearActiveNode Then
				m_bPendingShowPopupNearActiveNode = False
				window.setTimeout "g_oXTreePage.Internal_ShowPopupMenuNearActiveNode", MENU_ITEM_DELAY, "VBScript"
			Else
				window.setTimeout "g_oXTreePage.ShowPopupMenu", MENU_ITEM_DELAY, "VBScript"
			End If
		End If	
	End Sub

	'==============================================================================
	'@@XTreePageClass.GetPathOfTypes
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE GetPathOfTypes>
	':Назначение:	Возвращает путь до текущего узла, в котором перечислены только типы узлов. 
	':Сигнатура:	Public Function GetPathOfTypes()	' As String
	Public Function GetPathOfTypes()	' As String
		Dim aPath	' массив частей пути
		Dim sPath	' формируемый путь
		Dim i
		
		aPath = Split( m_sTreePath,"|")
		For i=0 To Ubound(aPath) Step 2
			If Len(sPath) > 0 Then sPath = sPath & "|"
			sPath = sPath & aPath(i)
		Next
		GetPathOfTypes = sPath
	End Function

	'==============================================================================
	'@@XTreePageClass.RunMenuExecutionHandlers
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE RunMenuExecutionHandlers>
	':Назначение:	Запускает обработчики выбора пункта меню для заданного action'a
	':Параметры:
	'	[in] sCmd As String	- наименование пункта меню (menu-item/@n)
	':Сигнатура:	Public Sub RunMenuExecutionHandlers(sCmd)
	Public Sub RunMenuExecutionHandlers(sCmd)
		if Not m_oMenu Is Nothing Then
			m_oMenu.RunExecutionHandlers Me, sCmd
		End If
	End Sub

	'==============================================================================
	' Отображает меню для пустого дерева
	' В обычных условиях не предназначен для вызова из прикладного кода, для обратной совместимости с старым кодом.
	Public Sub ShowMenuForEmptyTree
		ShowMenu
	End Sub

	'==============================================================================
	'@@XTreePageClass.TreeView
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE TreeView>
	':Назначение:	Возвращает интерфейс CROC.IXTreeView
	':Сигнатура:	Public Property Get TreeView [As IXTreeView]
	Public Property Get TreeView
		Set TreeView = m_oTreeView
	End Property
	
	'==============================================================================
	'@@XTreePageClass.DragDropController
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE DragDropController>
	':Назначение:	Возвращает контроллер операции переноса узлов дерева
	':Примечание:	Если у иерархии запрещены операции переноса узлов мышью (AllowDragDrop = false), свойство вернет Nothing
	':Сигнатура:	Public Property Get DragDropController [As TreeNodeDragDropController]
	Public Property Get DragDropController
		Set DragDropController = m_oDragDropController
	End Property
	
	'==============================================================================
	'@@XTreePageClass.XmlMenu
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE XmlMenu>
	':Назначение:	Возвращает XML меню узла дерева
	':Примечание:	Если в текущий момент меню недоступно, свойство вернет Nothing
	':Сигнатура:	Public Property Get XmlMenu [As IXMLDOMElement]
	Public Property Get XmlMenu
		If Not m_oMenu Is Nothing Then
			Set XmlMenu = m_oMenu.XmlMenu
		Else
			Set XmlMenu = Nothing
		End If
	End Property

	'==============================================================================
	'@@XTreePageClass.MenuDefaultStylesheet
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE MenuDefaultStylesheet>
	':Назначение:	Возвращает XSLT-шаблон по умолчанию для рендеренга меню
	':Сигнатура:	Public Property Get MenuDefaultStylesheet [As XMLDOMDocument]
	Public Property Get MenuDefaultStylesheet
		Set MenuDefaultStylesheet = m_oMenuXslDefault
	End Property
	
	'==============================================================================
	'@@XTreePageClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE QueryString>
	':Назначение:	Возвращает объект с параметрами страницы
	':Сигнатура:	Public Property Get QueryString [As QueryStringClass]
	Public Property Get QueryString
		Set QueryString = m_oPageParams
	End Property

	'==============================================================================
	'@@XTreePageClass.MetaName
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE MetaName>
	':Назначение:	Возвращает метаимя дерева
	':Сигнатура:	Public Property Get MetaName [As String]
	Public Property Get MetaName
		MetaName = m_sMetaName
	End Property
	
	'==============================================================================
	' Возвращает метаданные дерева
	' При первом вызове вызывает серверную операцию получения метаданных и кэширует результат
	' Примечание: для обычного функционирования дерева метаданные не нужны, поэтому на клиент они при построении страницы не передаются
	Public Function GetTreeMD	' As IXMLDOMElement
		If IsEmpty(m_oTreeMD) Then
			Set m_oTreeMD = X_GetTreeMD(m_sMetaname)
		End If
		Set GetTreeMD = m_oTreeMD
	End Function

	'==============================================================================
	'@@XTreePageClass.MayBeInterrupted
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE MayBeInterrupted>
	':Назначение:	Возвращает признак безопасной выгрузки страницы
	':Сигнатура:	Public Property Get MayBeInterrupted [As Boolean]
	Public Property Get MayBeInterrupted
		If true=m_bMayBeInterrupted Then
			If X_MD_PAGE_HAS_FILTER Then
				MayBeInterrupted = not g_oFilterObject.IsBusy
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
	'@@XTreePageClass.OffFilterViewState
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE OffFilterViewState>
	':Назначение:	Возвращает/устанавливает признак отключения сохранения состояния фильтра
	':Сигнатура:	Public Property Get/Let OffFilterViewState [As Boolean]
	Public Property Get OffFilterViewState 	' As Boolean
		OffFilterViewState = m_bOffFilterViewState
	End Property
	Public Property Let OffFilterViewState(sValue)
		m_bOffFilterViewState = sValue=True
	End Property

	'==============================================================================
	'@@XTreePageClass.Reload
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE Reload>
	':Назначение:	Пере/загружает дерево
	':Сигнатура:	Public Sub Reload
	Public Sub Reload
		If m_bAccessDenied Then Exit Sub
		MenuHtml.SetStatus "&nbsp;"
		on error resume next	
		EnableControls False
		m_oTreeView.Reload
		If Err Then
			MayBeInterrupted = True
			X_SetLastServerError m_oTreeView.XClientService.LastServerError, Err.number, Err.Source, Err.Description
			If X_IsSecurityException(m_oTreeView.XClientService.LastServerError) Then
				idNormalTreeBody.style.display = "none"
				xPaneAccessDenied.style.display = "block"
				ReportStatus "В доступе отказано..."
				TreeHolder.style.display = "none"
				m_bAccessDenied = True
				Err.Clear
			Else
				X_HandleError
			End If
			EnableControls True
			Exit Sub
		End If
		If 0<>len( m_sTreePath) Then
			m_oTreeView.SetNearestPath m_sTreePath, False, True
		End If
		EnableControls True
		m_oTreeView.focus
		Err.Clear
	End Sub

	'==============================================================================
	'@@XTreePageClass.MenuMacrosResolver
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE MenuMacrosResolver>
	':Назначение: Подстановка значений макросов меню.
	':Примечание: Подставляет значения следующих макросов:
	'	ObjectID	- идентификатор выбранного узла; 
	'	ObjectType	- наименование типа выбранного узла; 
	'	RefreshFlags- флаги обновления узла после операции над ним; 
	'	IsLeaf		- признак листового узла; 
	'	Title		- наименование узла; 
	'	Все макросы из ApplicationData выбранного узла
	':Сигнатура: Public Sub MenuMacrosResolver(
	'               oSender [as MenuClass], 
	'               oEventArgs [as MenuEventArgsClass])
	':Параметры: 
	'   oSender -
	'       [in] объект, сгенерировавший событие, экземпляр класса MenuClass
	'   oEventArgs - 
	'       [in] параметры события, экземпляр MenuEventArgsClass
	Public Sub MenuMacrosResolver(oSender, oEventArgs)
		Dim oNode	' xml-узел пользовательских параметров из ApplicationData активного узла дерева
		If Not m_oTreeView.ActiveNode Is Nothing Then
			m_oMenu.Macros.Item("ObjectID") = m_oTreeView.ActiveNode.ID
			m_oMenu.Macros.Item("ObjectType") = m_oTreeView.ActiveNode.Type
			m_oMenu.Macros.Item("RefreshFlags") = Empty
			m_oMenu.Macros.Item("IsLeaf") = m_oTreeView.ActiveNode.IsLeaf
			m_oMenu.Macros.Item("Title") = m_oTreeView.ActiveNode.text
			If Not m_oTreeView.ActiveNode.ApplicationData Is Nothing Then
				For Each oNode In m_oTreeView.ActiveNode.ApplicationData.selectNodes("ud/*")
					m_oMenu.Macros.Item(oNode.tagName) = oNode.text
				Next
			End If
		End If
	End Sub
	 
	'==============================================================================
	'@@XTreePageClass.MenuVisibilityHandler
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE MenuVisibilityHandler>
	':Назначение: Стандартный обработчик установки доступности/видимости пунктов меню. Проставляет признаки доступности стандартных пунктов меню. 
	':Сигнатура: Public Sub MenuVisibilityHandler(
	'       oSender [as MenuClass], 
	'       oEventArgs [as MenuEventArgsClass]
	'       )
	':Параметры: 
	'    oSender -
	'       [in] объект, сгенерировавший событие, экземпляр класса MenuClass
	'    oEventArgs - 
	'       [in] параметры события, экземпляр MenuEventArgsClass
	Public Sub MenuVisibilityHandler(oSender, oEventArgs)
		Dim oMenu			' As MenuClass
		Dim sGUID			' идентификатор выбранного объекта
		Dim sType			' тип выбранного объекта
		Dim bDisabled		' признак заблокированности пункта
		Dim bHidden			' признак сокрытия пункта
		Dim oNode			' текущий menu-item
		Dim oList			' As ObjectArrayListClass - массив объектов XObjectPermission
		Dim oParam			' As IXMLDOMElement - узел param в метаданных меню 
		Dim bProcess		' As Boolean - признак обработки текущего пункта
		Dim bTrustworthy	' признак "заслуживающего доверия" меню - для его пункто не надо выполнять проверку прав
		
		Set oMenu = oEventArgs.Menu
		Set oList = New ObjectArrayListClass
		bTrustworthy = Not IsNull(oMenu.XmlMenu.getAttribute("trustworthy"))
		' Обработаем только известные нам операции
		For Each oNode In oEventArgs.ActiveMenuItems
			bHidden = Empty
			bDisabled = Empty
			bProcess = False
			sGUID = oMenu.Macros.item("ObjectID")
			sType = oMenu.Macros.item("ObjectType")
			' по всем параметрам пункта меню
			For Each oParam In oNode.selectNodes("*[local-name()='params']/*[local-name()='param']")
				' если задан параметры ObjectType и/или ObjectID, то переопределим тип и/или OID (для проверки прав)
				If StrComp(oParam.getAttribute("n"), "ObjectType", vbTextCompare)=0 Then
					sType = oParam.text
				ElseIf StrComp(oParam.getAttribute("n"), "ObjectID", vbTextCompare)=0 Then
					sGUID = oParam.text
				End If
			Next
			' установим атрибуты на пункте меню, чтобы oMenu.SetMenuItemsAccessRights смог увязать запросы на проверку прав и пункты меню (при проставлении флага disabled)
			' если меню "заслуживает доверия", то данное действие без надобности
			If Not bTrustworthy Then 
				If Not IsNull(sType) Then _
					oNode.setAttribute "type", sType
				If Not IsNull(sGUID) Then _
					oNode.setAttribute "oid", sGUID
			End If
			
			Select Case oNode.getAttribute("action")
				Case CMD_ADD: 			' "DoCreate"
					If Not bTrustworthy Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CREATE, sType, Empty)
					bProcess = True
				Case CMD_VIEW: 			' "DoView"
					bHidden = IsNull(sGUID)
					bProcess = True
				Case CMD_EDIT: 			' "DoEdit"
					bHidden = IsNull(sGUID)
					If Not bHidden And Not bTrustworthy Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CHANGE, sType, sGUID)
					bProcess = True
				Case CMD_DELETE: 		' "DoDelete"
					bHidden = IsNull(sGUID)
					If Not bHidden And Not bTrustworthy Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_DELETE, sType, sGUID)
					bProcess = True
				Case CMD_HELP 			' "DoHelp"
					bHidden = Not HelpAvailiabe
					bProcess = True
				Case CMD_MOVE 			' "DoMove"
					bHidden = IsNull(sGUID)
					bProcess = True
				Case CMD_NODEREFRESH 	' "DoNodeRefresh"
					bHidden = IsNull(sGUID)
					bProcess = True
			End Select
			If bProcess Then
				If IsEmpty(bHidden) Then bHidden = False
				If IsEmpty(bDisabled) Then bDisabled = False
			End If
			If Not IsEmpty(bHidden) Then
				If bHidden Then 
					oNode.setAttribute "hidden", "1"
				Else
					oNode.removeAttribute "hidden"
				End If
			End If
			If Not IsEmpty(bDisabled) Then
				If bDisabled Then 
					oNode.setAttribute "disabled", "1"
				Else
					oNode.removeAttribute "disabled"
				End If
			End If
		Next
		If Not oList.IsEmpty Then
			oMenu.SetMenuItemsAccessRights oList.GetArray()
		End If
		If X_IsDebugMode Then
			Set oNode = oMenu.XmlMenu.ownerDocument.createElement("menu-item")
			oNode.setAttribute "action", "DebugShowMenuXml"
			oNode.setAttribute "t", "Debug: XmlMenu"
			oNode.setAttribute "n", "DebugShowMenuXml"
			oMenu.XmlMenu.appendChild oNode
			Set oNode = oMenu.XmlMenu.ownerDocument.createElement("menu-item")
			oNode.setAttribute "action", "DebugActiveNodeType"
			oNode.setAttribute "t", "Debug: Тип выбранного узла"
			oNode.setAttribute "n", "DebugActiveNodeType"
			oMenu.XmlMenu.appendChild oNode
			Set oNode = oMenu.XmlMenu.ownerDocument.createElement("menu-item")
			oNode.setAttribute "action", "DebugActiveNodeOID"
			oNode.setAttribute "t", "Debug: Копировать идентификатор выбранного узла в буфер обмена"
			oNode.setAttribute "n", "DebugActiveNodeOID"
			oMenu.XmlMenu.appendChild oNode
			Set oNode = oMenu.XmlMenu.ownerDocument.createElement("menu-item")
			oNode.setAttribute "action", "DebugActiveNodeIconSelector"
			oNode.setAttribute "t", "Debug: селектор иконки"
			oNode.setAttribute "n", "DebugActiveNodeIconSelector"
			oMenu.XmlMenu.appendChild oNode
			Set oNode = oMenu.XmlMenu.ownerDocument.createElement("menu-item")
			oNode.setAttribute "action", "DebugActiveNodeAppData"
			oNode.setAttribute "t", "Debug: дополнительные данные выбранного узла"
			oNode.setAttribute "n", "DebugActiveNodeAppData"
			oMenu.XmlMenu.appendChild oNode
			Set oNode = oMenu.XmlMenu.ownerDocument.createElement("menu-item")
			oNode.setAttribute "action", "DebugActiveNodePath"
			oNode.setAttribute "t", "Debug: путь до выбранного узла"
			oNode.setAttribute "n", "DebugActiveNodePath"
			oMenu.XmlMenu.appendChild oNode
		End If
	End Sub
	
	'==============================================================================
	'@@XTreePageClass.MenuExecutionHandler
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE MenuExecutionHandler>
	':Назначение: Стандартный обработчик выполнения выбранной команды меню.
	':Сигнатура: Public Sub MenuExecutionHandler(
	'       oSender [as MenuClass], 
	'       oEventArgs [as MenuExecuteEventArgsClass]
	'       )
	':Параметры: 
	'    oSender -
	'       [in] объект, сгенерировавший событие, экземпляр класса MenuClass
	'    oEventArgs - 
	'       [in] параметры события, экземпляр MenuExecuteEventArgsClass
	Public Sub MenuExecutionHandler(oSender, oEventArgs)
		Dim oMenu		' As MenuClass
		Dim sGUID		' идентификатор выбранного объекта
		
		Set oMenu = oEventArgs.Menu
		sGUID = oMenu.Macros.item("ObjectID")
		' установим флаги обновления после стандартных операций по умолчанию (т.е. если флаги не заданы в i:params)
		If Not hasValue(oMenu.Macros.Item("RefreshFlags")) Then
			Select Case oEventArgs.Action
				Case CMD_ADD:
					oMenu.Macros.Item("RefreshFlags") = TRM_PARENT
				Case CMD_EDIT:
					oMenu.Macros.Item("RefreshFlags") = TRM_NODE
				Case CMD_DELETE:
					oMenu.Macros.Item("RefreshFlags") = TRM_PARENTNODE
				Case Else
					oMenu.Macros.Item("RefreshFlags") = TRM_NONE
			End Select
		End If
		
		Select Case oEventArgs.Action
			Case CMD_EDIT:			OnEdit oMenu.Macros
			Case CMD_ADD:			OnCreate oMenu.Macros
			Case CMD_DELETE:		
				If Not hasValue(oMenu.Macros.Item("Prompt")) Then
					oMenu.Macros.Item("Prompt") = "Вы действительно хотите удалить объект?"
				End If
				OnDelete oMenu.Macros
			Case CMD_VIEW:			X_OpenReport oMenu.Macros.Item("ReportURL")
			Case CMD_HELP:			X_OpenHelp HelpPage 
			Case CMD_MOVE:			OnMove oMenu.Macros
			Case CMD_NODEREFRESH:	OnNodeRefresh oMenu.Macros
			Case "DebugShowMenuXml"		: X_DebugShowXML oMenu.XmlMenu
			Case "DebugActiveNodeType"	: Alert m_oTreeView.ActiveNode.Type
			Case "DebugActiveNodeOID" 	: window.clipboardData.setData "Text", m_oTreeView.ActiveNode.ID
			Case "DebugActiveNodeIconSelector" 	: Alert m_oTreeView.ActiveNode.IconSelector
			Case "DebugActiveNodeAppData"		: 
				If Not m_oTreeView.ActiveNode.ApplicationData Is Nothing Then
					X_DebugShowXML m_oTreeView.ActiveNode.ApplicationData
				Else
					Alert "Узел не содержит дополнительных данных"
				End If
			Case "DebugActiveNodePath":	Alert m_oTreeView.ActiveNode.Path
		End Select
	End Sub
	
	'==========================================================================
	' Редактирование объекта
	' В обычных условиях не предназначен для вызова из прикладного кода
	Public Sub OnEdit(oValues)
		Dim sGUID	' Идентификатор текущего объекта
		
		sGUID = oValues.Item("ObjectID")
		If 0 = Len(sGUID) Then Exit Sub
		With X_CreateControlsDisabler(Me)
			With New CommonEventArgsClass
				.ObjectID = sGUID
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = False
				' установим метаимя редактора. Оно должно быть задано в коллекции макросов
				.Metaname = oValues.Item("MetanameForEdit")
				Set .Values = oValues
				' подготовка к редактированию
				Internal_FireEvent "BeforeEdit", .Self()
				' обработчики могли выставить флаг "прервать выполнение"
				If .ReturnValue Then Exit Sub
				' редактирование
				Internal_FireEvent "Edit", .Self()
				' по завершении редактирования
				Internal_FireEvent "AfterEdit", .Self()
			End With
		End With
	End Sub

	'==========================================================================
	' Создание нового объекта
	' В обычных условиях не предназначен для вызова из прикладного кода
	Public Sub OnCreate(oValues)
		With X_CreateControlsDisabler(Me)
			With New CommonEventArgsClass
				.ObjectID = Null
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = Empty
				' установим метаимя мастера. Оно должно быть задано в коллекции макросов
				.Metaname = oValues.Item("MetanameForCreate")
				Set .Values = oValues
				' подготовка к созданию
				Internal_FireEvent "BeforeCreate", .Self()
				' обработчики могли выставить флаг "прервать выполнение"
				If .ReturnValue Then Exit Sub
				' создание
				Internal_FireEvent "Create", .Self()
				' постобработка
				Internal_FireEvent "AfterCreate", .Self()			
			End With	
		End With
	End Sub

	'==========================================================================
	' Удаление  объекта
	' В обычных условиях не предназначен для вызова из прикладного кода
	Public Sub OnDelete(oValues)
		Dim sGUID		' Идентификатор удаляемого объекта
		
		' получим идентификатор удаляемого объекта
		sGUID = oValues.Item("ObjectID")
		If 0=Len(sGUID) Then Exit Sub
		With X_CreateControlsDisabler(Me)
			With New DeleteObjectEventArgsClass
				.ObjectID = sGUID
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = True
				Set .Values = oValues
				' подготовка к удалению
				Internal_FireEvent "BeforeDelete", .Self()
				' обработчики могли выставить флаг "прервать выполнение"
				If .ReturnValue = False Then Exit Sub
				' удаление объекта
				Internal_FireEvent "Delete", .Self()
				' обработчики могли выставить флаг "прервать выполнение"
				If .ReturnValue = False Then Exit Sub
				' постобработка
				Internal_FireEvent "AfterDelete", .Self()
			End With
		End With
	End Sub
	
	'==============================================================================
	' Перенос узла. Обработчик операции CMD_MOVE
	' В обычных условиях не предназначен для вызова из прикладного кода
	Public Sub OnMove(oValues)
		With X_CreateControlsDisabler(Me)
			With New CommonEventArgsClass
				.ObjectID = oValues.Item("ObjectID")
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = True
				.Metaname = oValues.Item("Metaname")
				Set .AddEventArgs = New MoveTreeNodeEventArgsClass
				.AddEventArgs.ParentPropName = oValues.Item("ParentPropName")
				' запомним перемещаемый узел дерева
				Set .AddEventArgs.MovingNode = m_oTreeView.ActiveNode
				Set .Values = oValues
				' подготовка к переносу
				Internal_FireEvent "BeforeMove", .Self()
				' обработчики могли выставить флаг "прервать выполнение"
				If .ReturnValue = False Then Exit Sub
				' получаю путь до нового родителя...
				Internal_FireEvent "SelectParent", .Self()
				If .ReturnValue = False Or IsEmpty(.AddEventArgs.ParentObjectType) Or IsEmpty(.AddEventArgs.ParentObjectID) Then Exit Sub
				' собственно перенос
				Internal_FireEvent "Move", .Self()
				' постобработка
				Internal_FireEvent "AfterMove", .Self()			
			End With	
		End With
	End Sub
	
	'==============================================================================
	' Обновляет текущий (выбранный) узел дерева, т.е. посылает команду GET_NODE загрузчику.
	' В обычных условиях не предназначен для вызова из прикладного кода
	Public Sub OnNodeRefresh(oValues)
		ReloadNode m_oTreeView.ActiveNode
	End Sub
	
	'==============================================================================
	'@@XTreePageClass.ReloadNode
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE ReloadNode>
	':Назначение:	Перегружает узел дерева и возвращает переполученный интерфейс IXTreeNode
	':Параметры:
	'	[in] oNode As IXTreeNode - узел дерева, который необходимо перегрузить
	':Сигнатура:	Public Function ReloadNode(oNode)
	':Результат:
	'	Переполученный интерфейс IXTreeNode
	Public Function ReloadNode(oNode) ' As IXTreeNode
		Dim sPath	' путь
		sPath = oNode.Path
		On Error Resume Next
		oNode.Reload 
		If Err Then MsgBox Err.Description, vbCritical
		On Error GoTo 0
		Set ReloadNode = m_oTreeView.FindNode(sPath, True, False)
	End Function

	'==============================================================================
	'@@XTreePageClass.Title
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE Title>
	':Назначение:	Возвращает/устанавливает заголовок страницы
	':Сигнатура:	Public Property Get/Let Title [As String]
	Public Property Get Title
		Title = xPaneCaption.innerText
	End Property
	Public Property Let Title(sText)
		xPaneCaption.innerText = sText
	End Property

	'==============================================================================
	'@@XTreePageClass.SpecialCaption
	'<GROUP !!MEMBERTYPE_Properties_XTreePageClass><TITLE SpecialCaption>
	':Назначение:	Возвращает/устанавливает "специальный" заголовок страницы
	':Примечание:   "Специальный" заголовок страницы выводиться ниже "стандартного" заголовка, предназначен для вывода дополнительной информации
	':Сигнатура:	Public Property Get/Let SpecialCaption [As String]
 	Public Property Get SpecialCaption		' As String
		SpecialCaption = xPaneSpecialCaption.innerHtml
	End Property
	Public Property Let SpecialCaption(sText)
		xPaneSpecialCaption.innerHtml = sText
	End Property
	
	'==========================================================================
	'@@XTreePageClass.EnableControls
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE EnableControls>
	':Назначение:	Разрешение/отключение управляющих элементов страницы
	':Параметры:
	'	[in] bEnable As Boolean  - признак доступности контролов
	':Сигнатура:	Sub EnableControls(bEnable)
	Sub EnableControls(bEnable)
		If Not TREE_MD_OFF_RELOAD Then _
			cmdRefresh.disabled = Not bEnable
		If Not X_MD_OFF_CLEARFILTER Then _
			cmdClearFilter.disabled = Not bEnable
		If Not X_MD_OFF_HIDEFILTER Then _
			cmdHideFilter.disabled = Not bEnable
		If X_MD_PAGE_HAS_FILTER Then
			g_oFilterObject.Enabled = bEnable
		End If
		MenuHtml.HTML.style.display = iif(bEnable, "block", "none")
		g_oXTreePage.TreeView.Enabled = bEnable
		XService.DoEvents
	End Sub
	
	'==============================================================================
	'@@XTreePageClass.SwitchFilter
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE SwitchFilter>
	':Назначение:	Изменяет состояние фильтра: скрыто или показано
	':Сигнатура:	Public Sub SwitchFilter()
	Public Sub SwitchFilter()
		If X_MD_PAGE_HAS_FILTER Then
			If UCase(xPaneFilter.style.display) = "NONE" Then
				xPaneFilter.style.display = "block"
				g_oFilterObject.SetVisibility True
				cmdHideFilter.innerText = "Скрыть"
				cmdHideFilter.title = "Скрыть фильтр"
			Else
				cmdHideFilter.focus
				xPaneFilter.style.display = "none"
				g_oFilterObject.SetVisibility False
				cmdHideFilter.innerText = "Показать"
				cmdHideFilter.title = "Показать фильтр"
			End If
		End If
	End Sub

	'==============================================================================
	'@@XTreePageClass.ResizePanels
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE ResizePanels>
	':Назначение:	Расчёт и установка размеров дерева и меню в зависимости от положения сплиттера
	':Сигнатура:	Sub ResizePanels()
	Sub ResizePanels()
		Const WINDOW_MIN_WIDTH  = 20	'- минимально допустимая ширина окна, 
										' при котором ещё можно пересчитывать размеры панелей
										
		Dim nWidth		' вычисляемая ширина
		Dim nMAX		' максимальная допустимая ширина
		Dim nDiff		' разница в ширинах
		
		' Раз нет доступа то нам тут делать нечего 
		If m_bAccessDenied Then
			Exit Sub
		End If
		
		nMAX = document.body.clientWidth
		If nMAX < WINDOW_MIN_WIDTH Then
			Exit Sub ' при сверхмалой ширине окна лучше не мудрить
		End If

		If IsNumeric(TreeHolder.offsetWidth) And (0<>Len(TreeHolder.offsetWidth)) And IsNumeric(TreeView.clientWidth) And (0<>len(TreeView.clientWidth)) Then
			nDiff = TreeHolder.offsetWidth - TreeView.clientWidth
			If nDiff < 0 Then nDiff = 0
		Else
			nDiff = 0
		End If
		
		' переходим от процентов к пикселям
		nWidth = Int( m_dSplitterPos * nMAX /100 )

		'!!! пусть хоть немного будет видно и дерево и меню !!!
		If nWidth < (PANEL_MIN_WIDTH + nDiff + Splitter.offsetWidth ) Then
			nWidth = PANEL_MIN_WIDTH + nDiff + Splitter.offsetWidth
		End If
		If nMAX - nWidth - Splitter.offsetWidth < PANEL_MIN_WIDTH Then
			nWidth = nMAX - Splitter.offsetWidth - PANEL_MIN_WIDTH
		End If
		' переходим от пикселей к процентам
		m_dSplitterPos = nWidth*100/nMAX
		' и устанавливаем новые ширины
		nMAX = nMAX - nWidth - Splitter.offsetWidth
		
		MenuHolder.style.width = nMAX & "px"
		TreeHolder.style.width = (nWidth - nDiff) & "px"
		MenuHtml.style.width=nMAX&"px"

		' Корректируем ширину
		nDiff = TreeHolderCell.clientWidth - nWidth
		If nDiff>0 Then
			nMAX = nMAX + nDiff
			MenuHolder.style.width = nMAX & "px"
		End If

	End Sub

	'==============================================================================
	'@@XTreePageClass.RefreshCurrentNode
	'<GROUP !!MEMBERTYPE_Methods_XTreePageClass><TITLE RefreshCurrentNode>
	':Назначение: Обновляет дерево объектов относительно текущего узла в соответствии со флагами обновления
	':Сигнатура: Public Sub RefreshCurrentNode(nOps)
	':Параметры: 
	'   nOps - [in] флаги обновления (TRM_xxxx)
	Public Sub RefreshCurrentNode(nOps)
		Dim oParentNode		' родительский узел обновляемого узла
		Dim oCurrentNode	' текущий узел дерева

		If TRM_NONE = nOps Then Exit Sub ' ничего не делаем
		
		Set oCurrentNode = TreeView.ActiveNode
		If oCurrentNode Is Nothing Then
			Set oParentNode = Nothing
		Else
			Set oParentNode = oCurrentNode.parent
		End If
		
		DoRefreshTree nOps, oCurrentNode, oParentNode  
	End Sub
	
	'==============================================================================
	' Обработчик события EnableControls, сгенерированного фильтром (x-filter.htc)
	'	[in] oEventArgs - EnableControlsEventArgs
	Public Sub Internal_On_Filter_EnableControls(oSender, oEventArgs)
		EnableControls oEventArgs.Enable
	End Sub

	'==============================================================================
	' Обработчик события Accel, сгенерированного фильтром (x-filter.htc)
	'	[in] oEventArgs - AccelerationEventArgsClass
	Public Sub Internal_On_Filter_Accel(oSender, oEventArgs)
		If oEventArgs.keyCode = VK_ENTER Then
			Reload
		End If
	End Sub


	'==============================================================================
	' Обработчик события "Apply", сгенерированного фильтром (x-filter.htc)
	'	[in] oEventArgs - AccelerationEventArgsClass
	Public Sub Internal_On_Filter_Apply(oSender, oEventArgs)
		Reload
	End Sub

	'==============================================================================
	' Обработчик ActiveX-события onKeyUp компоненты TreeView
	' Не предназначен для использования прикладным кодом
	Public Sub OnKeyUp(nKeyCode, nFlags)
		Dim oActiveNode						' As IXTreeNode - текущий узел
				
		' Обрабатываем только кнопку APPS/MENU (слева от правого Control)
		If nKeyCode = VK_APPS Then
			' Если нет активого узла не будем ничего делать
			Set oActiveNode = TreeView.ActiveNode
			If Not oActiveNode Is Nothing Then
				' если меню готово, то покажем его, иначе запомним факт нажатия кнопки и покажем меню позже, когда получим его с сервера
				If m_bMenuIsReady Then
					Internal_ShowPopupMenuNearActiveNode
				Else
					m_bPendingShowPopupNearActiveNode = True
					m_bPendingShowPopup = True
				End If
			End If
		Else			
			' если меню готово
			If m_bMenuIsReady Then
                                m_oMenu.ExecuteHotkey Me, CreateAccelerationEventArgsForActiveXEvent(nKeyCode, nFlags)
			End If	
		End If
	End Sub
End Class

Dim g_oXTreePage		' Глобальный экземпляр XTreePageClass - синглетон
Dim g_oFilterObject		' Фильтр страницы иерархии - экземпляр класса XFilterObjectClass

'<ИНИЦИАЛИЗАЦИЯ СТРАНИЦЫ>
'==============================================================================
' Инициализация страницы
Sub Window_OnLoad()	
	X_WaitForTrue "Init()" , "X_IsDocumentReadyEx( null, ""XFilter"")"
End Sub

'==============================================================================
' Инициализация страницы после загрузки всех контролов на странице
Sub Init
	Set g_oXTreePage = New XTreePageClass

	g_oXTreePage.Internal_InitializeHtmlControls
    ' Отображение фильтра:
    If X_MD_PAGE_HAS_FILTER Then
		Set g_oFilterObject = X_GetFilterObject( document.all( "FilterFrame") )
	    g_oXTreePage.Internal_InitFilter
	    ' Дождёмся загрузки фильтрa в контейнере FilterObject
	    X_WaitForTrue  "g_oXTreePage.Internal_InitPageFinal", "g_oFilterObject.IsReady"
	Else
		g_oXTreePage.Internal_InitPageFinal
	End If		
End Sub

'</ИНИЦИАЛИЗАЦИЯ СТРАНИЦЫ>

'<ФИНАЛИЗАЦИЯ СТРАНИЦЫ>
'==============================================================================
' Попытка выгрузки страницы
Sub Window_onBeforeUnload
	If Not IsObject(g_oXTreePage) Then Exit Sub
	If Nothing Is g_oXTreePage Then Exit Sub
	If g_oXTreePage.MayBeInterrupted Then Exit Sub
	window.event.returnValue="Внимание!" & vbNewLine & "Выгрузка страницы в данный момент может привести к возникновению ошибки!"
End Sub

'==============================================================================
' Выгрузка страницы
Sub window_onUnLoad()
	on error resume next
	If IsNothing(g_oXTreePage) Then Exit Sub
	g_oXTreePage.Internal_FireEvent "UnLoad", Nothing
	' сохраняю состояния именованных секций меню и фильтра
	g_oXTreePage.Internal_SaveStateOnUnload
End Sub
'</ФИНАЛИЗАЦИЯ СТРАНИЦЫ>

'<ОБРАБОТЧИКИ КНОПОК>

'==============================================================================
' Обработка команды очистки фильтра...
Sub XTree_cmdClearFilter_OnClick()
	If X_MD_PAGE_HAS_FILTER Then 
		g_oFilterObject.ClearRestrictions()
	End If
End Sub

'==============================================================================
' Обработчик кнопки "Скрыть"/"Показать" фильтр
Sub XTree_cmdHideFilter_onClick()
	g_oXTreePage.SwitchFilter()
End Sub

'==============================================================================
' Обработчик события OnClick для cmdRefresh
Sub XTree_cmdRefresh_OnClick()
   g_oXTreePage.Reload()
End Sub

'==============================================================================
' Обработчик нажатия на кнопку "справка"
Sub XTree_cmdOpenHelp_OnClick
	Document_onHelp
End Sub
'</ОБРАБОТЧИКИ КНОПОК>

'==============================================================================
' Пере/Загрузка дерева. Вынесено из класса XTreePageClass, т.к. передается GetRef'ом
Sub Reload()
	g_oXTreePage.Reload
End Sub

'==============================================================================
' Обработчик события OnReadyStateChange для g_oXTreePage.m_oMenuHTTP
Sub ProcessMenuXML
	Const XML_DOM_COMPLETE = 4		' признак конца загрузки документа в XMLDomDocument
	Dim oMenuXML			' IXMLDOMDocument пришедшего меню
	' проверяем готовность меню
	If g_oXTreePage.m_oMenuHTTP.readyState <> XML_DOM_COMPLETE Then Exit Sub
	' проверяем корректность пришедшего ответа
	Set oMenuXML = CheckMenuRequestResponse(g_oXTreePage.m_oMenuHTTP) 
	' если в ответе не Nothing, значит получили корректное меню
	If Not oMenuXML Is Nothing Then
		g_oXTreePage.EndShowMenu oMenuXML
	End If
End Sub

'==============================================================================
' проверяет на корректность ответ от загрузчика меню (по умолчанию x-tree-menu.aspx)
'	[in] oXmlHttp - объект XMLHTTP, ответ от которого проверяем
'	[retval] - если ответ корректный, xml-возвращает содержимое ответ (IXMLDOMElement корневого узла - menu)
Function CheckMenuRequestResponse(oXmlHttp)	' As XMLDOMElement
	Const vbByteArray = &h2011		' Единственный тип массивов, которые обрабатываем
	Dim sMenuHTML				' отрендерённое содержание меню
	Dim oMenuXML				' IXMLDOMDocument пришедшего меню
	
	Set CheckMenuRequestResponse = Nothing
	' 400 - максимальный НЕОШИБОЧНЫЙ статус отклика
	If oXmlHttp.status > 400 Then
		sMenuHTML = "<h2>Ошибка на сервере</h2><br/>" & oXmlHttp.status & "<br/>" & XService.HTMLEncodeLite(  oXmlHttp.statusText) & "<hr/><h3>Информация для администратора:</h3><div style=""background-color:white;"">" & XService.HTMLEncodeLite(XService.ByteArrayToText(oXmlHttp.responseBody)) & "</div>"
		MenuHtml.SetStatus sMenuHTML
		Exit Function 
	End If
			
	' Могло прийти пустое меню
	If vbByteArray <> VarType( oXmlHttp.responseBody) Then
		sMenuHTML = "<h2>Ошибка на сервере</h2><BR/>TypeName(oXmlHttp.responseBody)=" & VarType( oXmlHttp.responseBody) & "<br>http status:" & oXmlHttp.status & "<hr/>"
		On Error Resume Next
		sMenuHTML = sMenuHTML & "<h3>Информация для администратора:</h3><div style=""background-color:white;"">" & XService.HTMLEncodeLite(XService.ByteArrayToText(oXmlHttp.responseBody))
		On Error GoTo 0
		MenuHtml.SetStatus sMenuHTML
		Exit Function 
	End If
	
	' Могло прийти пустое меню
	If 0 > UBound( oXmlHttp.responseBody) Then
		sMenuHTML = "<h2>Ошибка на сервере</h2><BR>UBound=" & UBound( oXmlHttp.responseBody)
		MenuHtml.SetStatus sMenuHTML
		Exit Function 
	End If
	
	Set oMenuXML = XService.XmlFromString(XService.ByteArrayToText(oXmlHttp.responseBody ))	
	' А пришел ли нам корректный XML?
	If oMenuXML Is Nothing Then
		sMenuHTML = "<h2>Ошибка на сервере - пришел неверный XML</h2><br/>" & XService.HTMLEncodeLite(XService.ByteArrayToText(oXmlHttp.responseBody) )
		MenuHtml.SetStatus sMenuHTML
		Exit Function
	End If
	If oMenuXML.nodeName = "x-res" Then
		' xml пришел корректный, но это сообщение об ошибке - обработаем его стильшитом по умолчанию
		sMenuHTML = oMenuXML.transformNode( GetXsl("") )
		MenuHtml.SetStatus sMenuHTML
		Exit Function
	End If
	' если дошли до сюда, значит все хорошо	
	Set CheckMenuRequestResponse = oMenuXML
End Function

'==============================================================================
' Возвращает XMLDocument Xsl-шаблона для меню с заданным именем. Вынесено из класса XTreePageClass, т.к. передается GetRef'ом
'	[in] sXslFileName - наименование файла XSLT-стильшита. Если "" или Null, то испольщует шаблон по умолчанию
Function GetXsl(sXslFileName)
	Dim oMenuXsl
	If g_oXTreePage.m_sMenuXslDefault = sXslFileName Or IsNull(sXslFileName) Or Len(sXslFileName)=0 Then
		' если стильшит не задан или передано имя стильшита по умолчанию, то возьмем отдельно лежащий стильшит по умолчанию
		Set oMenuXsl = g_oXTreePage.MenuDefaultStylesheet
		' дождемся синхронно полной загрузки стильшита
		while Not X_IsObjectReady(oMenuXsl)
			' waiting...
		wend
		Set GetXsl = oMenuXsl
	Else
		' иначе будем искать в хеше стильшитов (ключ - имя стильшита)
		If g_oXTreePage.m_oMenuXSLCollection.Exists(sXslFileName) Then
			' стильшит уже есть - вернем его
			Set GetXsl = g_oXTreePage.m_oMenuXSLCollection.Item(sXslFileName)
		Else
			' стильшит запрашивает первый раз - загручим его и запомним в хеше (ключ - имя стильшита)
			Set oMenuXsl = XService.XMLGetDocument("XSL\" & sXslFileName) 
			g_oXTreePage.m_oMenuXSLCollection.Add sXslFileName, oMenuXsl
			Set GetXsl = oMenuXsl
		End If
	End If
End Function

'<ОБРАБОТЧИКИ СПЛИТТЕРА>

Dim g_xSplitter ' document.all("XTree_Splitter")

'==============================================================================
' Возвращает объект сплиттера
Function Splitter
	If IsEmpty(g_xSplitter) Then
		Set g_xSplitter = document.all("XTree_Splitter")
	End If
	Set Splitter = g_xSplitter 
End Function

'==============================================================================
' Начинает изменение положения разделителя
Sub XTree_Splitter_OnMouseDown()
	If Not IsObject(g_oXTreePage) Then Exit Sub
	
	Splitter.LeftButton = "1"
	Splitter.SetCapture
End Sub

'==============================================================================
' Изменение положения разделителя
Sub XTree_Splitter_OnMouseMove()
	If Not IsObject(g_oXTreePage) Then Exit Sub

	Dim nNewX	' Новое положение разделителя
	Dim nMAX	' Максимально допустимое положение
	nMAX = document.body.clientwidth 
	If Splitter.LeftButton="1" And window.event.button=1 Then ' Если кнопка уже была нажата, перемещаем сплитер
		nNewX=window.event.clientX
		If nNewX<PANEL_MIN_WIDTH Then 
		  nNewX=PANEL_MIN_WIDTH
		End If  
		If nMAX<PANEL_MIN_WIDTH Then 
		  nNewX= nMAX-PANEL_MIN_WIDTH
		End If 
		' переходим от  пикселей к процентам 
        g_oXTreePage.m_dSplitterPos = nNewX*100/nMAX
        ' и изменяем размеры панелей
        g_oXTreePage.ResizePanels()
	End If
	If Splitter.LeftButton="1" And window.event.button<>1 Then	'если кнопка мышки отжата дезактивируем сплитер
		Splitter_OnMouseUp
	End If
End Sub

'==============================================================================
' Завершает изменение положения разделителя
Sub XTree_Splitter_OnMouseUp()
	If Not IsObject(g_oXTreePage) Then Exit Sub

	If Splitter.LeftButton="1" Then
		Splitter.LeftButton="0"
		Splitter.releaseCapture()
	End If
End Sub
'</ОБРАБОТЧИКИ СПЛИТТЕРА>


'<ОБРАБОТЧИКИ РАЗМЕРОВ ЭЛЕМЕНТОВ>
'==============================================================================
' обработчик изменения размеров окна
Sub window_OnResize()
	If Not IsObject(g_oXTreePage) Then Exit Sub
	g_oXTreePage.ResizePanels()
End Sub
'</ОБРАБОТЧИКИ РАЗМЕРОВ ЭЛЕМЕНТОВ>

'==============================================================================
' Обработчик вызова справки
Sub Document_OnHelp
	If Not IsObject(g_oXTreePage) Then Exit Sub
	If g_oXTreePage.HelpAvailiabe Then
		window.event.returnValue = False
		X_OpenHelp g_oXTreePage.HelpPage
	End If
End Sub

'<ОБРАБОТЧИКИ КОНТРОЛА TREEVIEW>
'==============================================================================
' Обработчик события OnDataLoading для oTreeView.
'	Используется для включения в запрос на получение данных
'	иерархии информации фильтра.
Sub TreeView_OnDataLoading( oSender,  nQuerySet,  sNodePath,  sObjectType,  sObjectID,  oRestrictions)
	Dim sRestrictions		' ограничения фильтра
	Dim sSpecialCaption		' заголовок
	
	g_oXTreePage.MayBeInterrupted = False
	sRestrictions = GetRestrictions
	internal_TreeInsertRestrictions oRestrictions, sRestrictions
	If Len(sRestrictions) > 0 Then
		sSpecialCaption = "<NOBR>фильтр активен</NOBR>"
	Else
		sSpecialCaption = ""
	End If
	g_oXTreePage.SpecialCaption = sSpecialCaption
End Sub

'==============================================================================
' Обработчик события OnDataLoaded для oTreeView
'	Используется для определения случая "пустой" иерархии,
'	при котором возможно необходимо сформировать меню 
'	создания первого корневого элемента. 
' ВНИМАНИЕ! Процесс генерации меню выполняется из этого 
'	обработчика, т.к. именно в этом месте можно 
'	гарантировать то, что данные в иерархии отсутствуют.
Sub TreeView_OnDataLoaded( oSender, nQuerySet, sNodePath, sObjectType, sObjectID )
	g_oXTreePage.MayBeInterrupted = True
	If 0<>nQuerySet Then Exit Sub
	If 0<>oSender.Root.Count Then Exit Sub
	g_oXTreePage.ShowMenu
End Sub

'==============================================================================
' Обработчик нажатия правой кнопки мыши
Sub TreeView_OnMouseUp(oSender, oTreeNode, nFlags)
	Const	KEYFLG_RBUTTON = 16 ' Код правой кнопки мыши
	Dim oCurrentNode	' Выбранный узел дерева
	
	If nFlags <> KEYFLG_RBUTTON Then Exit Sub
	
	If Nothing Is oTreeNode Then Exit Sub
	
	Set oCurrentNode = oSender.ActiveNode
	If Nothing Is oCurrentNode Then
		oSender.Path = oTreeNode.Path 
	ElseIf oCurrentNode.nodeUID <> oTreeNode.nodeUID Then
		oSender.Path = oTreeNode.Path 
	End If
	If g_oXTreePage.m_bMenuIsReady Then
		window.setTimeout "g_oXTreePage.ShowPopupMenu", 0, "VBScript"
	Else
		g_oXTreePage.m_bPendingShowPopup = True
	End If
End Sub

'==============================================================================
' Обработчик вызова контекстного меню
Sub TreeView_OnKeyUp(oSender, nKeyCode, nFlags)
	g_oXTreePage.OnKeyUp nKeyCode, nFlags
End Sub

'==============================================================================
' Обработчик события DoubleClick
Sub TreeView_OnDblClick(oSender, oTreeNode)
	Dim oCurrentNode	' Текущий узел дерева

	If Nothing Is oTreeNode Then Exit Sub

	If Not oTreeNode.IsLeaf Then Exit Sub
	
	Set oCurrentNode = oSender.ActiveNode
	If Nothing Is oCurrentNode Then
		oSender.Path = oTreeNode.Path 
	ElseIf oCurrentNode.nodeUID <> oTreeNode.nodeUID Then
		oSender.Path = oTreeNode.Path 
	End If
	' если меню готово, то выполним пункт, считающийся пунктом по умолчанию, иначе запомним
	If g_oXTreePage.m_bMenuIsReady Then   
		window.setTimeout "g_oXTreePage.CallMenuDefaultItem", 0, "VBScript"
	Else
		g_oXTreePage.m_bPendingRunDefaultMenuItem = True
	End if		
End Sub

'==============================================================================
'Обработчик изменения активного узла
Sub TreeView_OnPathChange(oSender, oCurrent, oNew)
	If oNew Is Nothing Then Exit Sub
	g_oXTreePage.m_sTreePath = oNew.Path
	g_oXTreePage.ShowMenu
End Sub

'==============================================================================
' Начало операции - можно отменить
Sub TreeView_OnBeforeNodeDrag(oTreeView, oSourceNode, nKeyFlags, bCanDrag)
	g_oXTreePage.DragDropController.OnBeforeNodeDrag g_oXTreePage, oTreeView, oSourceNode, nKeyFlags, bCanDrag
End Sub

'==============================================================================
' Начало операции - начали перетаскивать
Sub TreeView_OnNodeDrag(oTreeView, oSourceNode, nKeyFlags)
	g_oXTreePage.DragDropController.OnNodeDrag g_oXTreePage, oTreeView, oSourceNode, nKeyFlags
End Sub

'==============================================================================
' Проносим над другим узлом
Sub TreeView_OnNodeDragOver(oTreeView, oSourceNode, oTargetNode, nKeyFlags, bCanDrog)
	g_oXTreePage.DragDropController.OnNodeDragOver g_oXTreePage, oTreeView, oSourceNode, oTargetNode, nKeyFlags, bCanDrog
End Sub
'==============================================================================
' Успешно перенесли
Sub TreeView_OnNodeDragDrop(oTreeView, oSourceNode, oTargetNode, nKeyFlags)
	g_oXTreePage.DragDropController.OnNodeDragDrop g_oXTreePage, oTreeView, oSourceNode, oTargetNode, nKeyFlags
End Sub

'==============================================================================
' Отменили перенос
Sub TreeView_OnNodeDragCanceled(oTreeView, oSourceNode, nKeyFlags)
	g_oXTreePage.DragDropController.OnNodeDragCanceled g_oXTreePage, oTreeView, oSourceNode, nKeyFlags
End Sub

'</ОБРАБОТЧИКИ КОНТРОЛА TREEVIEW>

'==============================================================================
'@@FilterObject
'<GROUP !!FUNCTIONS_x-tree><TITLE FilterObject>
':Назначение:
'	Возвращает объект фильтра страницы иерархии - экземпляр класса XFilterObjectClass
':Результат:
'	Экземпляр класса XFilterObjectClass или Empty, если у страницы нет фильтра.
':Сигнатура:
'	Function FilterObject()
Function FilterObject() ' As XFilterObjectClass
    Set FilterObject = g_oFilterObject
End Function

'==============================================================================
'@@GetRestrictions
'<GROUP !!FUNCTIONS_x-tree><TITLE GetRestrictions>
':Назначение:
'	Возвращает состояние фильтра (строку ограничений) в формате Name1=Value1&Name2=Value2&...&NameY=ValueY
':Результат:
'	Строку с ограничениями или vbNullString, если у страницы нет фильтра.
':Сигнатура:
'	Function GetRestrictions()
Function GetRestrictions() ' As String
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
'@@MenuSectionClick
'<GROUP !!FUNCTIONS_x-tree><TITLE MenuSectionClick>
':Назначение:
'	Обработчик щелчка мышью на заголовке секции меню - реализует схлопывание/расхлопывание
':Параметры:
'	oSectionTHEAD - [in] заголовок секции меню (HTML_THEAD_Element)
':Сигнатура:
'	Sub MenuSectionClick( oSectionTHEAD)
Sub MenuSectionClick( oSectionTHEAD)
	Dim sMode				' признак открытости секции
	Dim sID					' идентификатор секции меню
	
	' получим текущее состояние секции и инвертируем его
	sMode = iif(CStr(oSectionTHEAD.ExtendedIsCollapsed) = "0", "1", "0")
	SetMenuSectionState oSectionTHEAD, sMode
	
	sID = oSectionTHEAD.ID
	' если секция меню поименована - сохраняем её состояние в m_oMenuSect
	If Len(sID)>0 Then
		g_oXTreePage.m_oMenuSect.SetValue sID, sMode
	End If
End Sub

'==============================================================================
'@@SetMenuSectionState
'<GROUP !!FUNCTIONS_x-tree><TITLE SetMenuSectionState>
':Назначение:
'	Устанавливает состояние секции меню: схлопнуто/расхлопнуто
':Параметры:
'	oSectionTHEAD - [in] заголовок секции меню (HTML_THEAD_Element)
'	sMode - [in] нужное состояние секции: 1 - распахнуть, 0 - схлопнуть
':Сигнатура:
'	SetMenuSectionState(oSectionTHEAD, sMode)
Sub SetMenuSectionState(oSectionTHEAD, sMode)
	Dim oSubItemsTBODY		'TBODY таблицы, содержащая итемы секции 
	Dim oMenuSectionStateTD	'TD таблицы c картинкой картинка ( треугольничек вправо/вниз)
	Dim oMenuSectionCaptTD	'TD таблицы c заголовком секции

	Set oSubItemsTBODY = oSectionTHEAD.nextSibling
	With oSectionTHEAD.childNodes.item(0).childNodes.item(0).childNodes.item(0).childNodes.item(0).childNodes.item(0)
		Set oMenuSectionStateTD = .childNodes.item(0)
		Set oMenuSectionCaptTD  = .childNodes.item(1)
	End With
		
	If sMode = "1" Then
		' распахиваем секцию
		oSubItemsTBODY.className = "x-tree-menu-section-content-expanded"
		oMenuSectionStateTD.className = "x-tree-menu-section-state-expanded"
		oMenuSectionCaptTD.className = "x-tree-menu-section-caption-expanded"
	Else
		' спахиваем секцию 
		oSubItemsTBODY.className = "x-tree-menu-section-content-collapsed"
		oMenuSectionStateTD.className = "x-tree-menu-section-state-collapsed"
		oMenuSectionCaptTD.className = "x-tree-menu-section-caption-collapsed"
	End If
	
	oSectionTHEAD.ExtendedIsCollapsed = sMode
End Sub

'==============================================================================
' Отлов "отладочных" событий
' Показываем по PopUp-меню и CTRL (если в отладке-CTRL-не обязательно) на заголовке 
Sub OnDebugEvent()
	const DEB_ALL_METADATA		= 1001	'Метаданные
	const DEB_TREE_METADATA		= 1002	'Метаданные дерева
	const DEB_SYSINFO			= 1009	'Системная информация
	const DEB_RESTRICTIONS		= 1012	'Ограничения фильтра
	const DEB_MENU_XML			= 1014	'Меню: XML
	const DEB_MENU_HTML			= 1015	'Меню: HTML
	const DEB_RESET				= 1016	'Сброс сессии
	const DEB_XDEFAULT			= 1017	'x-default.aspx
	const DEB_ISDEBUGMODE		= 1018	'Отладочный режим
	const DEB_FILTERMENU		= 1019	' Отладочное меню фильтра
	
	dim sTempStr						'Вспомогательная строка
	dim PopUp
	Set PopUp = XService.CreateObject("CROC.XPopUpMenu")
	
	'проверяем секретную комбинацию...
	If  window.event.ctrlKey Or X_IsDebugMode Then
		' Строим меню
		PopUp.Clear
		PopUp.Add "Метаданные",				DEB_ALL_METADATA,		true
		PopUp.Add "Метаданные дерева",		DEB_TREE_METADATA,		true
		PopUp.AddSeparator
		PopUp.Add "Меню: XML",				DEB_MENU_XML,			g_oXTreePage.m_bMenuIsReady
		PopUp.Add "Меню: HTML",				DEB_MENU_HTML,			true
		PopUp.AddSeparator
		PopUp.Add "Системная информация",	DEB_SYSINFO,			true
		PopUp.AddSeparator
		PopUp.Add "Ограничения фильтра",	DEB_RESTRICTIONS,		X_MD_PAGE_HAS_FILTER
		PopUp.AddSeparator
		PopUp.Add "Отладочное меню фильтра...", DEB_FILTERMENU,		X_MD_PAGE_HAS_FILTER
		PopUp.AddSeparator
		PopUp.Add "Сброс сессии...", 		DEB_RESET, true
		PopUp.AddSeparator
		PopUp.Add "Отладочный режим",		DEB_ISDEBUGMODE, true, iif(X_IsDebugMode, 1, 0)
		PopUp.AddSeparator
		PopUp.Add "x-default.aspx", 		DEB_XDEFAULT, true	
		select case PopUp.Show()
			case DEB_XDEFAULT
				navigate XService.BaseURL( location.href) & "X-DEFAULT.ASPX?ALL=1&TM="  & CDbl(Now)
			case DEB_RESET
				X_ResetSession
			case DEB_MENU_XML
				X_DebugShowXML  g_oXTreePage.XmlMenu
			case DEB_MENU_HTML
				X_DebugShowHTML  MenuHtml.Html.InnerHTML
			case DEB_RESTRICTIONS
				on error resume next
				sTempStr = GetRestrictions()
				if Err then
					Alert "Ошибка в фильтре:" & vbNewLine & Err.Source & vbNewLine  & Err.Description
					exit sub
				end if
				on error goto 0
				InputBox sTempStr ,"Текущие ограничения фильтра", sTempStr 
			case DEB_FILTERMENU
				FilterObject.ShowDebugMenu
			case DEB_ALL_METADATA
				X_DebugShowXML X_GetMD()
			case DEB_TREE_METADATA
				X_DebugShowXML g_oXTreePage.GetTreeMD()
			case DEB_SYSINFO
				' Формируем строку с системной информацией...
				sTempStr =	"Файл:			X-TREE.ASPX" & vbNewLine &_
							"Размер:			" & document.fileSize & vbNewLine & _
							"Обновлён:		"  & FormatDateTime( document.lastModified, vbShortDate ) & " " & FormatDateTime( document.lastModified, vbLongTime ) & vbNewLine & vbNewLine & _
							"Метаимя:			" & g_oXTreePage.MetaName & vbNewLine &_
							"Строка запроса:		" & g_oXTreePage.QueryString.QueryString
				
				if not Nothing Is g_oXTreePage.TreeView.ActiveNode then
					sTempStr = sTempStr & vbNewLine & vbNewLine & "Тип узла:			" & g_oXTreePage.TreeView.ActiveNode.type 
					sTempStr = sTempStr & vbNewLine & "Идентификатор:		" & g_oXTreePage.TreeView.ActiveNode.ID 
					sTempStr = sTempStr & vbNewLine & "Селектор:		" & g_oXTreePage.TreeView.ActiveNode.IconSelector 
					sTempStr = sTempStr & vbNewLine & "Иконка:			" & g_oXTreePage.TreeView.ActiveNode.IconURL
				end if			
							 							
				' И вывожу её			
				MsgBox sTempStr, vbOKOnly , "Системная информация"
			case DEB_ISDEBUGMODE
				X_SetDebugMode Not X_IsDebugMode
		end select
		window.event.returnValue = false
	end if
End Sub

'==============================================================================
' Стандартный обработчик "SetInitPath" - начальная установка пути в дереве, заданного параметром страницы
Sub stdXTree_OnSetInitPath(oSender, oEventArgs)
	oSender.TreeView.SetNearestPath oSender.m_sTreeInitPath, False, True
End Sub

'===============================================================================
'@@TreeMenuEventArgsClass
'<GROUP !!CLASSES_x-tree><TITLE TreeMenuEventArgsClass>
':Назначение:	Параметры событий связанные с показом меню иерархии (MenuBeforeShow, MenuRendered).
':Примечание:	Поле <LINK TreeMenuEventArgsClass.MenuXsl, MenuXsl /> используется только для события MenuBeforeShow.
'
'@@!!MEMBERTYPE_Methods_TreeMenuEventArgsClass
'<GROUP TreeMenuEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_TreeMenuEventArgsClass
'<GROUP TreeMenuEventArgsClass><TITLE Свойства>
Class TreeMenuEventArgsClass
	'@@TreeMenuEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_TreeMenuEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel				
	
	'@@TreeMenuEventArgsClass.Menu
	'<GROUP !!MEMBERTYPE_Properties_TreeMenuEventArgsClass><TITLE Menu>
	':Назначение:	Возвращает ссылку на экземпляр MenuClass.
	':Сигнатура:	Public Menu [As MenuClass]
	Public Menu
	
	'@@TreeMenuEventArgsClass.MenuXsl
	'<GROUP !!MEMBERTYPE_Properties_TreeMenuEventArgsClass><TITLE MenuXsl>
	':Назначение:	Возвращает ссылку на экземпляр XMLDOMDocument Xslt-шаблона для рендеренга меню.
	':Сигнатура:	Public MenuXsl [As IXMLDOMDocument]
	Public MenuXsl
	
	'@@TreeMenuEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_TreeMenuEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As TreeMenuEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class
