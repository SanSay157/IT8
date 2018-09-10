Option Explicit

'===============================================================================
'@@XListPageClass
'<GROUP !!CLASSES_x-list-page><TITLE XListPageClass>
':Назначение:	Класс страницы контейнера списка и фильтра.
'@@!!MEMBERTYPE_Methods_XListPageClass
'<GROUP XListPageClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_XListPageClass
'<GROUP XListPageClass><TITLE Свойства>
'
'<Ignore>
' События:
'	Load			- загрузка страницы (EventArgs: Nothing)
'	UnLoad			- выгрузка страницы (EventArgs: Nothing)
'	Ok				- нажатие на Ок в режиме выбора (EventArgs: ListSelectEventArgsClass)
'	ResetFilter		- нажитие на Очистить фильтр (EventArgs: Nothing)
'</Ignore>
Class XListPageClass
	Public QueryString			' As QueryString - параметры, переданные странице
	Public MetaName				' As String	- Имя списка в метаданных
	Public ObjectType			' As String	- наименование типа объектов в списке
	Public FilterObject			' As Object - объект фильтра

	Private m_nMode					' As Byte - Режим работы списка (LM_LIST, LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE)
	Private m_oXList				' As XListClass	- компонент списка
	Private m_oListMD				' As IXMLDOMElement - метаданные списка (получаются с сервера только при необходимости)
	Private EVENTS					' As String - список поддерживаемых событий
	Private m_oEventEngine			' As CROC.XEventEngine
	Private m_oEventEngineFilter	' As CROC.XEventEngine - EventEngine для получения событий от фильтра (передается в x-filter.htc)
	Private m_bIsDialog				' As Boolean - признак того, что страница открыта в диалоговом окне (для всех режимов кроме LM_LIST)
	Private m_bMayBeInterrupted		' As Boolean - признак того, что пользователь может безопасно покинуть текущую страницу
	Private m_oReportXsl			' As XSL для построения отчёта
	Private m_bOffFilterViewState	' As Boolean	- Признак "Не сохранять состояние фильтра"

	Private m_nServerMaxRows        ' As Long - максимальное количество строк в списке, определяемое сервером
	Private m_nFirstRow             ' As Long - номер первой строки
	Private m_bPaging	            ' As Bool - признак загрузки в режиме пейджинга
	Private m_sRestrictions                  ' As String  - получение последнего известного значения фильтра
	Private m_sRestrictionsDescription      ' As String  - получение последнего известного значения описания фильтра

	' HTML Controls
	Private NoDataMsg				' As IHTMLElement - DIV с сообщением
	Private ListHolder				' As IHTMLElement - TD, в котором содержится список (XListView)
	Private xPaneFilter				' As IHTMLElement - TD - контейнер фильтра
	Private cmdHideFilter			' As IHTMLElement - кнопка Скрыть/Показать фильтр
	
	'==========================================================================
	' "Конструктор"
	Private Sub Class_Initialize
		m_nFirstRow = 1
		m_bPaging	= False
		m_bMayBeInterrupted = true
		If IsObject(g_oXListPage) Then _
			If Not g_oXListPage Is Nothing Then _
				Err.Raise -1, "XListPageClass::Class_Initialize", "Допустимо существование только одного экземпляра XListPageClass"
		' Получение входных параметров
		Set QueryString = X_GetQueryString()
		ObjectType = X_PAGE_OBJECT_TYPE
		MetaName = X_PAGE_METANAME
		m_nMode = LIST_MODE
		m_nServerMaxRows = iif( LIST_MD_MAXROWS > 0, LIST_MD_MAXROWS, DEFAULT_MAXROWS )	
		
		
		EVENTS = "Load,UnLoad,Ok,ResetFilter,Refresh"
		Set m_oEventEngine = X_CreateEventEngine
		' Инициализируем пользовательские обработчики событий статическим биндингом (по маске имени)
		m_oEventEngine.InitHandlers EVENTS, "usrXListPage_On"
		If Not m_oEventEngine.IsHandlerExists("Ok") Then
			m_oEventEngine.AddHandlerForEvent "Ok", Me, "OnOk"
		End If

		Set m_oXList = New XListClass
				
		m_oXList.ObjectType = ObjectType
		' передадим вложенному списку имя переменной текущего экземпляра
		m_oXList.Internal_SetContainer "g_oXListPage"
		' подпишемся на событие "SetMenuItemVisibility" обработки видимости/доступности пунктов меню
		m_oXList.EventEngine.AddHandlerForEvent "SetMenuItemVisibility", Me, "OnSetMenuItemVisibility"
		' подпишемся на событие "GetRestrictions" своего компонента XList
		m_oXList.EventEngine.AddHandlerForEvent "GetRestrictions", Me, "OnGetRestrictions"
		' подпишемся на событие "AfterListReload" своего компонента XList
		m_oXList.EventEngine.AddHandlerForEvent "AfterListReload", Me, "OnAfterListReload"
	End Sub


	'==========================================================================
	' Инициализация страницы
	'	[in] sMenuMDXml As String	- метаданные меню
	Sub Internal_Init( sMenuMDXml)
		Dim oMenuXml	' As IXMLDOMElement - метаданные меню
		
		m_bIsDialog = Not Eval("IsEmpty(dialogHeight)")
		
		' Если режим отбора нескольких объектов, включаю показ флажков
		If LM_MULTIPLE = Mode OR LM_MULTIPLE_OR_NONE = Mode Then
			m_oXList.CheckBoxes = True
		End If
		
		' Инициализация параметров на основе значений метаданных, подставленных серверным кодом в константы
		m_oXList.ShowLineNumbers = Not LIST_MD_OFF_ROWNUMBERS
		m_oXList.GridLines = Not LIST_MD_OFF_GRIDLINES
		m_oXList.OffCreate = LIST_MD_OFF_CREATE
		m_oXList.OffEdit = LIST_MD_OFF_EDIT
		m_oXList.OffClear = LIST_MD_OFF_CLEAR
		m_oXList.OffReport = LIST_MD_OFF_REPORT
		m_oXList.IdentifiedBy = LIST_MD_IDENTIFIED_BY
		m_oXList.TypedBy = LIST_MD_TYPED_BY		
		m_oXList.MaxRows = ServerMaxRows
		m_oXList.UseEditor = LIST_MD_USE_EDITOR
		m_oXList.UseWizard = LIST_MD_USE_WIZARD

		' Формируем URL загрузчика списка
		m_oXList.Loader =  "x-list-loader.aspx?OT=" & ObjectType & "&MetaName=" & MetaName	
		m_oXList.Restrictions = QueryString.GetValue("RESTR","")
		m_oXList.ValueObjectIDs = QueryString.GetValue("VALUEOBJECTID","")
		
		' инициализируем меню
		If Len(sMenuMDXml) > 0 Then
			Set oMenuXml = XService.XMLFromString(sMenuMDXml)
			If Not oMenuXml Is Nothing Then
				m_oXList.InitMenu oMenuXml
				' добавим свои обработчики
				m_oXList.Menu.AddExecutionHandler X_CreateDelegate(Me, "MenuExecutionHandler")
			End If
		End If

		Internal_InitializeHtmlControls
		' Ожидаем завершения полной загрузки страницы	
		window.status = "Ожидание загрузки объекта фильтра..."
		
		Internal_Init2
	End Sub

	'==========================================================================
	' Инициализируем ссылки на HTML контролы
	' Их приходиться получать через document.all, так как
	' элементы находиться внутри формы, которой ASP.Net дает случайное наименование...
	Sub Internal_InitializeHtmlControls
		Set NoDataMsg = document.all("XList_ContentPlaceHolderForList_NoDataMsg")
		Set ListHolder = document.all("XList_ContentPlaceHolderForList_ListHolder")
		Set m_oXList.ListView = document.all( "List")

		If X_MD_PAGE_HAS_FILTER Then
			Set FilterObject = X_GetFilterObject( document.all( "FilterFrame") )
			Set xPaneFilter = document.all("XList_xPaneFilter")
		End If
		If Not X_MD_OFF_HIDEFILTER Then _
			Set cmdHideFilter = document.all("XList_cmdHideFilter")
	End Sub
	
	'==========================================================================
	' Инициализация страницы - фаза 2
	' Вызывается по окончании загрузки страницы
	Sub Internal_Init2
		m_bMayBeInterrupted = false

		If X_MD_PAGE_HAS_FILTER Then
			' Инициализируем фильтр
			g_oXListPage.Internal_InitFilter()
		Else
			Internal_Init3 ' Фильтров нет - значит НЕ обрабтываем
		End If	
	End Sub

	
	'==========================================================================
	' Инициализация фильтра
	' Вызывается по окончании загрузки содержимого фильтра (FilterObject.IsComponentReady = True)
	Sub Internal_InitFilter
		Dim oParams			' параметры для инициализации фильтра
		Dim oFilterXmlState	' As XMLDOMElement - восстановленное состояние фильтра
		Dim bInit			' AS Boolean - признак инициализации
		
		window.status = "Инициализация фильтра..."
		Set oParams = New FilterObjectInitializationParamsClass
		Set oParams.QueryString = g_oXListPage.QueryString
		Set oParams.OuterContainerPage = Me
		oParams.DisableContentScrolling = True
		m_bOffFilterViewState = X_MD_FILTER_OFF_VIEWSTATE
		If m_bOffFilterViewState = False Then
			If GetDataCache("FilterXmlState", oFilterXmlState) Then
				Set oParams.XmlState = oFilterXmlState
			End If
		End If
		On Error Resume Next
		
		Set m_oEventEngineFilter = X_CreateEventEngine
		m_oEventEngineFilter.AddHandlerForEvent "EnableControls", Me, "Internal_On_Filter_EnableControls"
		m_oEventEngineFilter.AddHandlerForEvent "Accel", Me, "Internal_On_Filter_Accel"
		m_oEventEngineFilter.AddHandlerForEvent "Apply", Me, "Internal_On_Filter_Apply"
		bInit = FilterObject.Init (m_oEventEngineFilter, oParams)

		If Err Then
			If Not X_HandleError Then
				X_ErrReportEx Err.Description, Err.Source
			End If
			bInit = False
		End If
		On Error GoTo 0
		If bInit Then
			' Ожидаем завершения инициализации фильтров
			X_WaitForTrue "g_oXListPage.Internal_Init3()" , "g_oXListPage.FilterObject.IsReady"
		Else
			Alert "Ошибка инициализации фильтра!"
			Internal_Init3
		End If
	End Sub


	'==========================================================================
	' Инициализация страницы - фаза 3
	' Вызывается по завершению инициализации фильтров
	Sub Internal_Init3
		If (X_MD_PAGE_HAS_FILTER And LIST_MD_OFF_LOAD) Then
			NoDataMsg.innerHTML = "Нажмите кнопку &quot;<span title='Нажмите здесь для загрузки списка...' style='cursor: default;font-weight: bold;' language='VBSCript' onclick='ReloadList'>Обновить</span>&quot; для загрузки списка."
		End If
		window.status = "Инициализация страницы завершена."

		Internal_FireEvent "Load", Nothing

		m_bMayBeInterrupted = true

		' Проверяем, что требуется начальная загрузка списка
		If Not LIST_MD_OFF_LOAD Then
			ReloadList()
		Else
			EnableControls True
			XList.SetDefaultFocus(FilterObject)
		End If

		g_bFullLoad = True
	End Sub

	'==========================================================================
	' получение последнего известного значения фильтра
	Public Property Get CurrentRestrictions
		CurrentRestrictions = m_sRestrictions
	End Property

	'==========================================================================
	' Получение описания последнего известного значения фильтра
	Public Property Get CurrentRestrictionsDescription
		CurrentRestrictionsDescription = m_sRestrictionsDescription
	End Property

	'==========================================================================
	' Возвращает режим работы страницы: LM_LIST, LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE
	Public Property Get Mode
		Mode = m_nMode
	End Property


	'==========================================================================
	' Возвращает экземпляр класса списка
	Public Property Get XList
		Set XList = m_oXList
	End Property


	'==========================================================================
	' Признак того, что со страницы может быть выполнен безопасный уход
	' Используется в window_OnBeforeUnload
	Public Property Get MayBeInterrupted
		If m_bMayBeInterrupted=true Then
			If IsObject(m_oXList) Then
				If Not m_oXList Is Nothing Then
					MayBeInterrupted = m_oXList.MayBeInterrupted
				Else
					MayBeInterrupted = True
				End If
			Else
				MayBeInterrupted = True
			End If
		Else
			MayBeInterrupted = False
		End If
		
		If MayBeInterrupted Then
			If X_MD_PAGE_HAS_FILTER Then
				MayBeInterrupted = not FilterObject.IsBusy
			End If
		End If	
	End Property


	'==============================================================================
	' Возвращает признак того, что страница открыта как диалог
	Public Property Get IsDialog
		IsDialog = m_bIsDialog
	End Property


	'==========================================================================
	' Возбуждение события
	Public Sub Internal_FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub


	'==========================================================================
	' Обработчик события XList'a "SetMenuItemVisibility"
	Public Sub OnSetMenuItemVisibility( oSender, oEventArgs )
		Select Case oEventArgs.Action
			Case CMD_REPORT
				oEventArgs.Hidden = XList.OffReport
				oEventArgs.Disabled = XList.ListView.Rows.Count = 0
			Case CMD_EXCEL
				oEventArgs.Hidden = XList.OffReport
				oEventArgs.Disabled = XList.ListView.Rows.Count = 0
			Case CMD_REFRESH
				oEventArgs.Disabled = LIST_MD_OFF_RELOAD
			Case CMD_RESETFILTER
				oEventArgs.Disabled = X_MD_OFF_CLEARFILTER
			Case CMD_HELP
				oEventArgs.Hidden = Not X_MD_HELP_AVAILABLE
		End Select		
	End Sub


	'==========================================================================
	' Обработчик команд меню, относящихся к контейнеру
	'	[in] oEventArgs As MenuExecuteEventArgsClass
	Public Sub MenuExecutionHandler(oSender, oEventArgs)
		Select Case oEventArgs.Action
			Case CMD_REPORT:		ShowReport()
			Case CMD_EXCEL:			ShowExcel()
			Case CMD_REFRESH:		ReloadList()
			Case CMD_RESETFILTER:	XList_cmdClearFilter_OnClick()
			Case CMD_HELP:			XList_cmdOpenHelp_OnClick()
		End Select
	End Sub


	' <МЕТОДЫ, ВЫЗЫВАЕМЫЕ из XList>
	'==============================================================================
	' Сохраняет данные о представлении в постоянном хранилище
	'	[in] sKey As String   - ключ
	'	[in] vData As Variant - какие-то данные 
	Public Sub SaveViewStateCache(sKey, vData)
		X_SaveViewStateCache GetCacheFileName(sKey), vData
	End Sub

	'==============================================================================
	' Считывает данные в постоянном хранилище
	'	[in] sKey As String   - ключ
	'	[in] vData As Variant - результат 
	'	[retval] True - данные считанны, False - ключ не найден
	Public Function GetViewStateCache(sKey, vData)
		GetViewStateCache = X_GetViewStateCache( GetCacheFileName(sKey), vData )
	End Function
	
	
	'==========================================================================
	' Отображает строку состояния
	Public Sub ReportStatus(sMsg)
		window.status = sMsg
	End Sub


	'==========================================================================
	' Выводит сообщение о ходе процесса. Контрол списка (IXListVIew) прячется
	'	[in] sMessage - текст сообщения
	Public Sub ShowProcessMessage(sMessage)
		If UCase(ListHolder.style.display) = "BLOCK" Then
			ListHolder.style.display = "none"
			NoDataMsg.style.display = "block"
		End If
		NoDataMsg.innerText = sMessage
		ReportStatus sMessage
		XService.DoEvents
	End Sub

	
	'==========================================================================
	' Прячет область для вывода сообщений о ходе процесса. Показаывает контрол списка (IXListVIew)
	Public Sub HideProcessMassage
		NoDataMsg.style.display = "none"
		ListHolder.style.display = "block"
	End Sub
	
	
	'==========================================================================
	' Разрешение/отключение управляющих элементов страницы
	Sub EnableControls( bEnable)
		EnableControl "XList_cmdGoBack", bEnable
		EnableControl "XList_cmdGoHome", bEnable
		EnableControl "XList_cmdOpenHelp", bEnable
		EnableControl "XList_cmdRefresh", bEnable
		EnableControl "XList_cmdOperations", bEnable
		EnableControl "XList_cmdOk", bEnable
		EnableControl "XList_cmdCancel", bEnable
		EnableControl "XList_cmdClearFilter", bEnable
		EnableControl "XList_cmdHideFilter", bEnable
		EnableControl "XList_cmdSelectAll", bEnable
		EnableControl "XList_cmdInvertSelection", bEnable
		EnableControl "XList_cmdDeselect", bEnable
		XList.EnableControlsInternal bEnable
		If X_MD_PAGE_HAS_FILTER Then
			FilterObject.Enabled = bEnable
		End If
		XService.DoEvents
	End Sub
	' </МЕТОДЫ, ВЫЗЫВАЕМЫЕ из XList>


	'==========================================================================
	' Разрешение/включение управляющего элемента по имени управляющего элемента
	' с проверкой, что элемент есть на странице
	Sub EnableControl( sCtlName, bEnable)
		Dim oCtl
		Set oCtl = document.all( sCtlName)
		
		if not oCtl is nothing then
			oCtl.disabled = not bEnable
		end if
	End Sub


	'==============================================================================
	' Стандартный обработчик события "OK"
	'	[in] oEventArg As ListSelectEventArgsClass
	Sub OnOk(oSender, oEventArg)
		Select Case Mode
			Case LM_MULTIPLE_OR_NONE
				X_SetDialogWindowReturnValue oEventArg.Selection
				window.close
			Case LM_SINGLE
				If 0<>Len(oEventArg.Selection) Then
					X_SetDialogWindowReturnValue oEventArg.Selection
					window.close
				Else
					Alert "Нужно выбрать объект"
				End if
			Case LM_MULTIPLE
				If UBound(oEventArg.Selection)>=0 Then
					X_SetDialogWindowReturnValue oEventArg.Selection
					window.close
				Else
					Alert "Нужно отметить хотя бы один объект"
				End If
		End Select 
	End Sub



	'==============================================================================
	' Стандартный обработчик события "GetRestrictions"
	'	[in] oSender As XListClass
	'	[in] oEventArg As GetRestrictionsEventArgsClass
	Public Sub OnGetRestrictions(oSender, oEventArg)
		Dim oArguments		' As FilterObjectGetRestrictionsParamsClass
		Dim oBuilder		' As IParamCollectionBuilder
		Dim bUsePaging		' Использовать пейджинг?
		
		bUsePaging = IsPagingProcess OR ( true = oEventArg.StayOnCurrentPage )
		If X_MD_PAGE_HAS_FILTER Then
			If bUsePaging AND (NOT IsEmpty(m_sRestrictions)) Then
				' В режиме пейджинга мы не собираем ограничения а используем
				' запомненные в "прошлый раз"
				oEventArg.ReturnValue = m_sRestrictions
				oEventArg.Description = m_sRestrictionsDescription
			Else
				Set oArguments = New FilterObjectGetRestrictionsParamsClass
				Set oBuilder = New QueryStringParamCollectionBuilderClass
				Set oArguments.ParamCollectionBuilder = oBuilder
				FilterObject.GetRestrictions(oArguments)
				If False=oArguments.ReturnValue Then
					oEventArg.ReturnValue = False
					oEventArg.Description = vbNullString
				Else
					m_sRestrictions = oBuilder.QueryString
					m_sRestrictionsDescription = oArguments.Description
					oEventArg.ReturnValue = m_sRestrictions
					oEventArg.Description = m_sRestrictionsDescription
				End If
			End If
		End If
		
		If LIST_MD_USE_PAGING AND bUsePaging Then
			oEventArg.UrlParams = "X-FIRST-ROW=" & PagingFirstRow & "&X-LAST-ROW=" & PagingLastRow
		Else
			m_nFirstRow = 1 ' Сбросим номер строки
			oEventArg.UrlParams = "X-FIRST-ROW=1&X-LAST-ROW=" & XList.MaxRows
		End If
	End Sub
	
	'==============================================================================
	' Максимально возможное количество строк
	Public Property Get ServerMaxRows
		ServerMaxRows = m_nServerMaxRows
	End Property
	
	'==============================================================================
	' Признак перезагрузки списка в режиме переключения страницы
	Public Property Get IsPagingProcess
		IsPagingProcess = m_bPaging
	End Property

	'==============================================================================
	' Номер первой выбираемой строки
	Public Property Get PagingFirstRow
		PagingFirstRow = m_nFirstRow
	End Property
	
	'==============================================================================
	' Номер последней выбираемой строки
	Public Property Get PagingLastRow
		PagingLastRow =  XList.MaxRows + PagingFirstRow - 1
	End Property

	'==============================================================================
	' Стандартный обработчик события "AfterListReload".
	' Событие генерируется XList'ом после (пере)загрузки данных с сервера
	'	[in] oSender As XListClass
	'	[in] oEventArg As AfterListReloadEventArgsClass
	Public Sub OnAfterListReload(oSender, oEventArg)
		' Отобразим количество полученных записей и признак активного фильтра
		Dim sSpecialTitle: sSpecialTitle = vbNullString
		With oEventArg
			Dim nRowCount: nRowCount = oSender.ListView.Rows.Count
			If LIST_MD_USE_PAGING AND ((Mode=LM_SINGLE) OR (Mode=LM_LIST)) Then
				Dim nFirstRow
				Dim nLastRow
				
				nFirstRow = PagingFirstRow
				
				sSpecialTitle = "<NOBR>"
				
				If 1=nFirstRow AND NOT .HasMoreRows Then
					sSpecialTitle = sSpecialTitle & "всего " & nRowCount & XService.GetUnitForm(nRowCount, Array(" записей", " запись", " записи"))
				Else
					nLastRow = nFirstRow + nRowCount - 1
					If 1<>nFirstRow Then
						sSpecialTitle = sSpecialTitle & _
							"<span style='font-family:Webdings;cursor:hand;font-size:120%;' onclick='g_oXListPage.SetDataWindow " & (1) & ", " & (.MaxRows) & "' language=vbscript>9</span>" & _
							"<span style='font-family:Webdings;cursor:hand;font-size:120%;' onclick='g_oXListPage.SetDataWindow " & (nFirstRow - .MaxRows) & ", " & (nFirstRow - 1) & "' language=vbscript>7</span>"
					End If
					sSpecialTitle = sSpecialTitle & "&nbsp;" & nFirstRow & " - " & nLastRow & "&nbsp;"
					If .HasMoreRows Then
						sSpecialTitle = sSpecialTitle & _
							"<span style='font-family:Webdings;cursor:hand;font-size:120%;' onclick='g_oXListPage.SetDataWindow " & (nFirstRow + .MaxRows) & ", " & (nFirstRow + .MaxRows*2 - 1) & "' language=vbscript>8</span>"
					End If
				End If
				sSpecialTitle = sSpecialTitle & "</NOBR>"
			Else
				If .HasMoreRows Then
					sSpecialTitle = "<NOBR>первые " & .MaxRows & XService.GetUnitForm(.MaxRows, Array(" записей", " запись", " записи")) & "</NOBR>"
				Else
					sSpecialTitle = "<NOBR>всего " & nRowCount & XService.GetUnitForm(nRowCount, Array(" записей", " запись", " записи")) & "</NOBR>"
				End If
			End If    
			If Len(.Restrictions) > 0 Then
				If Len(sSpecialTitle) > 0 Then sSpecialTitle = sSpecialTitle & "<BR>"
				sSpecialTitle = sSpecialTitle & "<NOBR>фильтр активен</NOBR>"
			End If
			
		End With
		
		XList_SpecialCaption.innerHtml = sSpecialTitle
	End Sub
		
	'==============================================================================
	' Возвращает заголовок списка
	Public Property Get Title		' As String
		Title = document.all("XList_Caption").innerText
	End Property

	'==============================================================================
	' Устанавливает заголовок списка
	Public Property Let Title(sText)
		document.all("XList_Caption").innerText = sText
	End Property
	
	'==============================================================================
	' Метод получения объекта QueryString с параметрами фильтра
	' Если фильтр в списке отсутствует, возвращается пустой экземпляр QueryStringClass.
	'	[retval] As QueryStringClass
	Public Function GetRestrictions()
		Set GetRestrictions = New QueryStringClass
		If X_MD_PAGE_HAS_FILTER Then
			With New GetRestrictionsEventArgsClass
				OnGetRestrictions Me, .Self()
				GetRestrictions.QueryString = .ReturnValue
			End With
		End If
	End Function

	'==============================================================================
	' Внутренний обработчик выгрузки страницы
	Sub Internal_OnUnLoad
		Dim oXmlFilterState ' As IXMLDOMElement, Состояние фильтра
		' При необходимости вызовем пользовательский обработчик...
		Internal_FireEvent "UnLoad", Nothing
		If X_MD_PAGE_HAS_FILTER Then
			If m_bOffFilterViewState=False Then
				' Если не отключено схранения состояния фильтра, сохраним его. Считаем, что фильтр это данные.
				Set oXmlFilterState = FilterObject.GetXmlState()
				If Not oXmlFilterState Is Nothing Then _
					SaveDataCache "FilterXmlState", oXmlFilterState
			End If
		End If
		XList.OnUnLoad
	End Sub

	'==============================================================================
	' Выполняет переданный скрипт. Предназначен для вызова из scriptlet'ов фильтров
	Public Sub ExecuteScript(sScript)
		ExecuteGlobal sScript
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
	' Сохраняет данные в постоянном хранилище
	'	[in] sKey As String   - ключ
	'	[in] vData As Variant - какие-то данные 
	Public Sub SaveDataCache(sKey, vData)
		X_SaveDataCache GetCacheFileName(sKey), vData
	End Sub

	'==============================================================================
	' Считывает данные в постоянном хранилище
	'	[in] sKey As String   - ключ
	'	[in] vData As Variant - результат 
	'	[retval] True - данные считаны, False - ключ не найден
	Public Function GetDataCache(sKey, vData)
		GetDataCache = X_GetDataCache( GetCacheFileName(sKey), vData )
	End Function


	'==============================================================================
	' Возвращает имя файла для сохранения пользовательских данных
	'	[in] sSuffix - суфикс имени
	'	[retval] наименование файла
	Private Function GetCacheFileName(sSuffix)
		GetCacheFileName = "XL." & ObjectType & "." & MetaName & "." & sSuffix
	End Function


	'==============================================================================
	' Возвращает метаданные списка
	' При первом вызове вызывает серверную операцию получения метаданных и кэширует результат
	' Примечание: для обычного функционирования списка метаданные не нужны, поэтому на клиент они при построении страницы не передаются
	Public Function GetListMD	' As IXMLDOMElement
		If IsEmpty(m_oListMD) Then
			Set m_oListMD = X_GetListMD(ObjectType, MetaName)
		End If
		Set GetListMD = m_oListMD
	End Function
	
	
	'==============================================================================
	' Отображает отладочное меню
	Public Sub ShowDebugMenu
		Dim oPopUp
		Set oPopUp = XService.CreateObject("CROC.XPopUpMenu")
		oPopUp.Clear
		
		oPopUp.Add "Метаданные", "X_DebugShowXML X_GetMD()", true
		oPopUp.Add "Метаданные типа '" & ObjectType & "'", "X_DebugShowXml X_GetTypeMD(""" & ObjectType & """)", true
		oPopUp.Add "Метаданные списка '" & MetaName & "'", "X_DebugShowXml GetListMD()", true
		oPopUp.Add "Системная информация", "ShowSystemInfo", true
		oPopUp.AddSeparator
		oPopUp.Add "Текущие ограничения...", "ShowCurrentRestrictions", X_MD_PAGE_HAS_FILTER
		oPopUp.AddSeparator
		oPopUp.Add "Отладочное меню фильтра...", "FilterObject.ShowDebugMenu", X_MD_PAGE_HAS_FILTER
		oPopUp.AddSeparator
		oPopUp.Add "Сброс сессии", "X_ResetSession", true
		oPopUp.AddSeparator
		oPopUp.Add "Отладочный режим", "X_SetDebugMode Not X_IsDebugMode", true, iif(X_IsDebugMode, 1, 0)
		oPopUp.AddSeparator
		oPopUp.Add "x-default.aspx", "window.navigate XService.BaseURL( location.href) & ""X-DEFAULT.ASPX?ALL=1&TM="" & CDbl(Now)", true
		Execute 	oPopUp.Show & "' Фиктивный комментарий"
		Window.event.cancelBubble=true
		Window.event.returnValue = false
	End Sub

	'==============================================================================
	' Отображает ограничения
	Public Sub ShowCurrentRestrictions
		Alert CurrentRestrictions
	End Sub

	
	'==============================================================================
	' Отображает системую информацию
	Public Sub ShowSystemInfo
		Alert _
			"Тип объекта: " & ObjectType & vbNewLine & _
			"Режим работы списка: " & Mode & vbNewLine & _
			"Метаимя списка: " & MetaName & vbNewLine & _
			"Строка аргументов: " & Querystring.QueryString & vbNewLine & _
			"Выбранный идентификатор: " & XList.GetSelectedRowID
	End Sub
	
	'==========================================================================
	' Построение халявного отчёта
	Public Sub ShowReport()
		Dim sCaption		' описания ограничений в виде строки
		Dim oDataFromServer	' данные с сервера
		Dim oCaption		' описания ограничений, загруженные в IXMLDOMDocument
		
		' Получим описание
		'!!! ЗАЛИПУХА !!!
		sCaption =	XService.HtmlEncodeLite(XList_Caption.innerText)

		if 0<>len( sCaption) then 
			sCaption = "<?xml version=""1.0"" encoding=""windows-1251""?><CAPTION>" & sCaption & "</CAPTION>"
			set oCaption = XService.XMLGetDocument()
			if not oCaption.LoadXml(sCaption) then
				X_ErrReportEx  "Ошибка при разборе описания ограничений фильтра!", "описания ограничения д.б. в виде XHTML" & vbNewLine & oCaption.parseError.reason
				exit sub
			end if
		end if	
		
		' Получим XSL
		If IsEmpty( m_oReportXsl ) Then
			On Error Resume Next
			Set m_oReportXsl = XService.XMLGetDocument( "xsl/x-list.xsl") 
			If 0<>err.number Then
				X_ErrReportEx "Ошибка при получении страницы стиля отчета!" & vbNewLine & Err.Description, Err.Source  
				Exit Sub
			End If
			On Error GoTo 0
		End If

		' Получим данные
		Set oDataFromServer = XList.ListView.Xml
		
		oDataFromServer.setAttribute "ot", ObjectType 
		
		' Подменим заголовок
		If Not IsEmpty( oCaption) Then
			with oDataFromServer
				.selectNodes("CAPTION").removeAll
				.appendChild oCaption.documentElement
			End With
		End If

		' Построим отчет
		With X_OpenReport( vbNullString).document
			.open
			.write oDataFromServer.transformNode(m_oReportXsl)
			.close
		End With
	End Sub
	
	
	'==========================================================================
	' Экспорт халявного отчёта в Excel
	Public Sub ShowExcel()
		' коэффициент пересчёта ширины столбца 
		const  WIDTH_RATIO = 8
		' размер шрифта у заголока/подвала
		const  HEAD_FONT_SIZE = 9
		' размер шрифта у тела документа
		const  BODY_FONT_SIZE = 7
		' имя шрифта
		const  FONT_NAME = "Microsoft Sans Serif"
		' экспериментально подобранный коэффициент
		const  MULTIPLY_RATIO = 3
		
		const  xlWBATWorksheet = -4167
		const  xlNormal = -4143
		const  xlMinimized = -4140

		' горизонтальные и вертикальные выравнивания
		const  xlHAlignCenter = -4108
		const  xlHAlignLeft = -4131
		const  xlHAlignRight = -4152
		const  xlVAlignCenter = -4108

		' индексы рамок
		const  xlInsideHorizontal = 12
		const  xlInsideVertical = 11
		const  xlEdgeBottom = 9
		const  xlEdgeLeft = 7
		const  xlEdgeRight = 10
		const  xlEdgeTop = 8

		' толщина рамок
		const  xlThin = 2

		' стили линий
		const  xlContinuous = 1
		
		' Максимально допустимое число колонок в Excel
		const  xlMaxColCount = 254

		dim oExelApp		' приложение Excel.Application
		dim oListData		' данные списка IXMLDomElement
		dim oRec			' строка списка IXMLDomElement
		dim oSheet			' таблица Excel.Sheet
		dim oBook			' книга Excel.Workbook
		dim nColumns		' число столбцов страницы
		dim nDataRows		' число строк данных
		dim x,y				' "Координаты" обрабатываемой ячейки таблицы
		dim sCaption		' описания ограничений в виде строки
		dim oCaption		' описания ограничений, загруженные в IXMLDOMDocument
		dim vVal			' Значение ячейки
		dim sCellType		' тип значения ячейки
		dim i
		dim j
		
		' Сформирует заголовок
		' !!! ЗАЛИПУХА !!!
		sCaption =	XList_Caption.innerText
		if 0<>len( sCaption) then 
			' Загрузим описание в XML
			sCaption = "<?xml version=""1.0"" encoding=""windows-1251""?><CAPTION>" & sCaption & "</CAPTION>"
			set oCaption = XService.XMLGetDocument()
			oCaption.preserveWhiteSpace = true
			on error resume next
			oCaption.loadXml sCaption
			If Err Then
				X_ErrReportEx  "Ошибка при загрузке заголовка в xml...", Err.Description 
				Exit Sub
			End If
			On Error GoTo 0
			with oCaption.documentElement
				' Заменим переносы на текст
				for each oRec in .selectNodes("//BR|//br|//Br|//bR")
					oRec.parentNode.replaceChild  oCaption.createTextNode(vbNewLine), oRec
				next
				' Получим тескст
				sCaption = .text
				set oRec = Nothing
			end with
			set oCaption = Nothing
		end if	

		window.status = "Загрузка с сервера данных для отчета..."
		set oListData =	XList.ListView.xml
		nColumns=0
		for each oRec in oListData.selectNodes("CS/C[not(@hidden)]")
			oRec.setAttribute "i", nColumns
			nColumns=nColumns+1
		next
		nColumns = nColumns + 1
		 
		if nColumns > xlMaxColCount  then
			Alert "Число колонок в данном отчёте больше максимально допустимого в Excel"
			window.status = "Экспорт в Excel невозможен ввиду ограничений на предельное число столбцов в отчёте."
			exit sub
		end if
		
		window.status = "Установление связи с Microsoft Excel..."
		On Error Resume Next
		set oExelApp = XService.CreateObject("Excel.Application")
		if Err then
			X_ErrReportEx "Невозможно установить связь с Microsoft Excel. Возможно он не установлен, либо настройки безопасности препятствуют взаимодействию с ним...", Err.Description  & " code: " & Hex(Err.Number)
			window.status = "При попытке установить связь с Microsoft Excel произошла ошибка."
			exit sub
		end if
		On Error GoTo 0

		window.status = "Инициализация страницы рабочей книги Excel..."
		set oBook =  oExelApp.WorkBooks.Add( xlWBATWorksheet)
		set oSheet = oBook.Worksheets.Item( 1)
		oSheet.Name = "Отчет"
		oSheet.Activate

		' Генерация заголовка
		window.status = "Формирование заголовка отчета..."
		oSheet.Rows("1:1").RowHeight = HEAD_FONT_SIZE * (UBound(Split(sCaption, vbNewLine ))+1) * MULTIPLY_RATIO
		with oSheet.Range(oSheet.Cells(1,1),oSheet.Cells(1,nColumns))
			.Merge
			.Value = sCaption 	' Заголовок
			.HorizontalAlignment = xlHAlignCenter 
			.VerticalAlignment = xlVAlignCenter
			with .Font
				.Bold = true
				.Size = HEAD_FONT_SIZE 
				.Name = FONT_NAME 
			end with
			.Interior.Color = RGB(252,253,225)
			with .Borders(xlEdgeBottom)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeRight)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeLeft)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeTop)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
		end with
		
		' Генерация шапки таблицы
		window.status = "Формирование шапки таблицы отчета..."

		' Генерация шапки таблицы
		oSheet.Columns(1).ColumnWidth = 3 ' Установка ширины столбца с номером записи
		x = 2 ' Первый столбец номер записи, значит основные столцы начинаются с 2
		y = 2 ' Шапка таблицы распологается во второй строке таблицы
		
		for i=0 to nColumns - 2
			set oRec = oListData.selectSingleNode("CS/C[number(@display-index)=" & i & "]")
			oSheet.Cells(y,x).Value = oRec.nodeTypedValue
			oSheet.Columns(x).ColumnWidth = Int(Int(oRec.getAttribute("width"))/ WIDTH_RATIO  )
			x=x+1
		next
		
		with oSheet.Range(oSheet.Cells(y,1),oSheet.Cells(y,nColumns))
			.HorizontalAlignment = xlHAlignCenter 
			.VerticalAlignment = xlVAlignCenter
			with .Font
				.Bold = true
				.Size = BODY_FONT_SIZE 
				.Name = FONT_NAME 
			end with
			.Interior.Color = RGB(220,220,220)
		end with
		
		' Генерация тела таблицы
		window.status = "Формирование таблицы отчета..."
		y = y + 1
		
		with oListData.selectSingleNode("RS")
			nDataRows = 0
			do
				set oRec = .selectSingleNode("R[number(@display-index)=" & nDataRows & "]")
				if not oRec is Nothing then
					nDataRows = nDataRows + 1
					window.status = "Формирование таблицы отчета (строка " & nDataRows & ")..."
					XService.DoEvents()
					oSheet.Cells(y+nDataRows-1,1).Value = nDataRows
					for j=2 to nColumns
						set vVal = oRec.selectSingleNode("F[not(@hidden)][1+number(./../../../CS/C[number(@display-index)=" & (j-2) & "]/@i)]")
						if not vVal is Nothing then
							vVal = vVal.nodeTypedValue
							if not IsNull( vVal) then
								if 0<>Len(CStr(vVal)) then
									vVal = CStr( vVal)
									set sCellType = oRec.selectSingleNode("F[not(@hidden)][1+number(./../../../CS/C[number(@display-index)=" & (j-2) & "]/@i)]/@dt:dt")
									if not sCellType is Nothing then
										sCellType = sCellType.Value
									else
										sCellType = ""
									end if
									select case sCellType
										case "i2", "i4", "fixed.14.4"
											oSheet.Cells(y+nDataRows-1,j).NumberFormat = "00"
											oSheet.Cells(y+nDataRows-1,j).Value = vVal
										case "r4", "r8"
											oSheet.Cells(y+nDataRows-1,j).NumberFormat = "00.0"
											oSheet.Cells(y+nDataRows-1,j).Value = vVal
										case "dateTime.tz"
											oSheet.Cells(y+nDataRows-1,j).NumberFormat = "dd.mm.yyyy h:mm:ss"
											oSheet.Cells(y+nDataRows-1,j).Value = "=DATE(" & Year(vVal) & "," & Month(vVal) & "," & Day(vVal) & ") + TIME(" & Hour(vVal) & "," & Minute(vVal) & "," & Second(vVal) & ")"
										case "time.tz"
											oSheet.Cells(y+nDataRows-1,j).Value = "=TIME(" & Hour(vVal) & "," & Minute(vVal) & "," & Second(vVal) & ")"
										case "date"
											oSheet.Cells(y+nDataRows-1,j).Value = "=DATE(" & Year(vVal) & "," & Month(vVal) & "," & Day(vVal) & ")"
										case else
											oSheet.Cells(y+nDataRows-1,j).Value = "'" &	vVal
									end select
								end if	
							end if 
						end if
					next
				end if
			loop until oRec is Nothing
		end with
		
		with oSheet.Range(oSheet.Cells(y,2),oSheet.Cells(y+nDataRows-1,nColumns))
			.HorizontalAlignment = xlHAlignLeft 
			.VerticalAlignment = xlVAlignCenter
			.WrapText = True
			with .Font
				.Bold = false
				.Size = BODY_FONT_SIZE 
				.Name = FONT_NAME 
			end with
		end with	
		
		' установим стиль у "СЕРЫХ" ячеек
		with oSheet.Range(oSheet.Cells(y,1),oSheet.Cells(y+nDataRows-1,1))
			.HorizontalAlignment = xlHAlignCenter 
			.VerticalAlignment = xlVAlignCenter
			with .Font
				.Bold = true
				.Size = BODY_FONT_SIZE 
				.Name = FONT_NAME 
			end with
			.Interior.Color = RGB(220,220,220)
		end with	
		
		' включим границы таблицы
		with oSheet.Range( oSheet.Cells(y-1,1), oSheet.Cells(y+nDataRows-1,nColumns) )
			with .Borders(xlEdgeBottom)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeRight)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeLeft)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeTop)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			' Внутреннюю сетку имеет смысл устанавливаеть если только есть хотя 
			' бы одна строка отчета;  в противном случае попытка установки 
			' внтуренней сетки приводит к runtime ошибке Excel:
			if ( nDataRows>0 and nColumns>0 ) then
				with .Borders(xlInsideHorizontal)
					.LineStyle = xlContinuous
					.Weight = xlThin
				end with
				with .Borders(xlInsideVertical)
					.LineStyle = xlContinuous
					.Weight = xlThin
				end with
			end if
		end with	
		
		' Генерация подвала
		window.status = "Формирование подвала отчета..."
		with oSheet.Range(oSheet.Cells(y+nDataRows,1),oSheet.Cells(y+nDataRows,nColumns))
			.Merge
			.Value = "Отчет составлен " & FormatDateTime (Now(), vbLongDate) & " в " & FormatDateTime (Now(), vbShortTime)
			.HorizontalAlignment = xlHAlignRight
			.VerticalAlignment = xlVAlignCenter
			with .Font
				.Size = HEAD_FONT_SIZE 
				.Name = FONT_NAME 
			end with	
			.Interior.Color = RGB(252,253,225)
			with .Borders(xlEdgeBottom)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeRight)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeLeft)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeTop)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
		end with
		window.status = "Экспорт в Excel выполнен."
		' Показываем Excel
		oExelApp.Visible = true
		oExelApp.WindowState = xlMinimized
		oExelApp.WindowState = xlNormal
	End Sub

	
	'==============================================================================
	' Изменяет состояние фильтра: скрыто или показано
	Public Sub SwitchFilter()
		If X_MD_PAGE_HAS_FILTER Then
			If UCase(xPaneFilter.style.display) = "NONE" Then
				xPaneFilter.style.display = "inline"
				FilterObject.SetVisibility True
				cmdHideFilter.innerText = "Скрыть"
				cmdHideFilter.title = "Скрыть фильтр"
			Else
				cmdHideFilter.focus
				xPaneFilter.style.display = "none"
				FilterObject.SetVisibility False
				cmdHideFilter.innerText = "Показать"
				cmdHideFilter.title = "Показать фильтр"
			End If
		End If
	End Sub
	
	
	'==============================================================================
	' Обработчик события "EnableControls", сгенерированного фильтром (x-filter.htc)
	'	[in] oEventArgs - EnableControlsEventArgs
	Public Sub Internal_On_Filter_EnableControls(oSender, oEventArgs)
		EnableControls oEventArgs.Enable
	End Sub


	'==============================================================================
	' Обработчик события "Accel", сгенерированного фильтром (x-filter.htc)
	'	[in] oEventArgs - AccelerationEventArgsClass
	Public Sub Internal_On_Filter_Accel(oSender, oEventArgs)
		If oEventArgs.keyCode = VK_ENTER Then
			ReloadList
		End If
	End Sub
	
	'==============================================================================
	' Обработчик события "Apply", сгенерированного фильтром (x-filter.htc)
	'	[in] oEventArgs - AccelerationEventArgsClass
	Public Sub Internal_On_Filter_Apply(oSender, oEventArgs)
		ReloadList
	End Sub
	
	
	'==============================================================================
	' Обработчик пейджинга, устанавливает "окно" отображаемых данных
	'	[in] nFirstRow  - номер первой отображаемой строки
	'	[in] nLastRow  - номер последней отображаемой строки
	Public Sub SetDataWindow(nFirstRow, nLastRow)
		Dim nMaxRows ' Количество строк которые необходимо отобразить
		
		If LIST_MD_USE_PAGING AND ((Mode=LM_SINGLE) OR (Mode=LM_LIST)) Then
			If m_bMayBeInterrupted Then
				If nFirstRow < 1 Then nFirstRow=1
				m_nFirstRow = nFirstRow
				If nLastRow >= nFirstRow Then
					nMaxRows = nLastRow - nFirstRow + 1
					If nMaxRows > ServerMaxRows Then
						nMaxRows = ServerMaxRows
					End If    
					XList.MaxRows = nMaxRows
				End If
				
				m_bPaging = true
				XList.Reload()
				m_bPaging = false
				
				XList.SetListFocus()
			End If
		Else
			Err.Raise -1, "XListPageClass::SetDataWindow", "Некорректная попытка использовать пейджинг"        
		End If    
	End Sub
End Class


'==============================================================================

Dim g_oXListPage		' As XListPageClass
Dim g_nThisPageID		' Уникальный идентификатор текущей страницы
Dim g_bFullLoad			' Признак полной загрузки страницы

'==============================================================================
' Инициализация скрипта (ПРОИСХОДИТ ДО инициализации страницы)
'...загрузка только начата...
g_bFullLoad = False
'...сформируем уникальный ID...
g_nThisPageID = CLng( CDbl( Time()) * 1000000000 )

'==============================================================================
' Инициализация страницы.
' Вызывается по готовности страницы, в том числе фильтра.
Sub Init()
	Dim vMenuMD		' метаданные меню
	
	If X_ACCESS_DENIED Then Exit Sub
	Set g_oXListPage = New XListPageClass
	Set vMenuMD = document.all("oListMenuMD",0)
	If Not vMenuMD Is Nothing Then 
		vMenuMD = vMenuMD.value
	Else
		vMenuMD = ""
	End If
	
	g_oXListPage.Internal_Init vMenuMD
End Sub


'==============================================================================
' Общий обработчик нажатия комбинации клавиш.
' Вызывается как из Document_onkeyUp, так и из 
':Параметры:	oAccelerationEventArgs - [in] AccelerationEventArgsClass
Sub Internal_OnKeyUp(oAccelerationEventArgs)
	' Клавиша моежт быть нажата еще до того, как будет 
	' проинициализирован экземпляр g_oXListPage: если это так,
	' то ничего не делаем:
	If Not hasValue(g_oXListPage) Then Exit Sub
	With oAccelerationEventArgs
		If g_oXListPage.Mode <> LM_LIST  Then
			If .KeyCode = VK_ENTER Then
				' нажали Enter в режиме выбора
				XList_cmdOk_OnClick()
			ElseIf .KeyCode = VK_ESC Then
				' нажали Escape в режиме выбора
				XList_cmdCancel_OnClick
			Else
				g_oXListPage.XList.OnKeyUp oAccelerationEventArgs
			End If
		Else
			g_oXListPage.XList.OnKeyUp oAccelerationEventArgs
		End If
	End With
End Sub


'<ОБРАБОТЧИКИ window и document>
'==============================================================================
' Инициализация страницы
Sub Window_OnLoad()	
	X_WaitForTrue "Init()" , "X_IsDocumentReadyEx(null, ""XFilter"")"
End Sub

'==============================================================================
' Финализация страницы
Sub Window_OnUnLoad()
	g_nThisPageID = Empty	' Сбрасываем идентификатор
	
	' Если список был недогружен делать ничего не будем!
	If True <> g_bFullLoad Then Exit Sub
	
	g_oXListPage.Internal_OnUnLoad
End Sub

'==============================================================================
' Попытка выгрузки страницы
Sub Window_onBeforeUnload
	If Not IsObject(g_oXListPage) Then Exit Sub
	If Nothing Is g_oXListPage Then Exit Sub
	If g_oXListPage.MayBeInterrupted Then Exit Sub
	window.event.returnValue="Внимание!" & vbNewLine & "Закрытие окна в данный момент может привести к возникновению ошибки!"
End Sub

Dim g_bKeyProcessing	' Признак обработки события Document_onkeyUp

'==============================================================================
' Нажатие клавиши, не словленное другими обработчиками
Sub Document_onkeyUp
	' если источник события контрол списка, то игнорируем событие - 
	' у списка есть собственное ActiveX-событие onKeyUp (см. XListPage_OnKeyUp)
	If Not IsObject(g_oXListPage) Then Exit Sub
	If Nothing Is g_oXListPage Then Exit Sub
	If Not window.event.srcElement is g_oXListPage.XList.ListView Then
		If g_bKeyProcessing Then Exit Sub
		g_bKeyProcessing = True
		Internal_OnKeyUp CreateAccelerationEventArgsForHtmlEvent()
		g_bKeyProcessing = False
	End If
End Sub
 

'==============================================================================
' Обработчик вызова справки
Sub Document_OnHelp
	If True <> g_bFullLoad Then Exit Sub
	If X_MD_HELP_AVAILABLE Then
		'В _некоторых_ случаях возникает ошибка	
		'A Runtime Error has occurred.
		'Do you wish to Debug?
		'Line: 1243
		'Error: Object required: 'window.event'	
		'Поэтому просто "потушим" её дабы не мешала ;)
		On Error Resume Next
		window.event.returnValue = False
		On Error GoTo 0
		X_OpenHelp X_MD_HELP_PAGE_URL
	End If
End Sub
'<ОБРАБОТЧИКИ window и document>


'<ОБРАБОТЧИКИ КНОПОК>
'==============================================================================
' Закрытие окна в режиме отбора по кнопке "OK"
Sub XList_cmdOk_OnClick()
	If document.all( "XList_cmdOk").disabled Then Exit Sub	' Если кнопка заблокирована - ничего не бум делать!
	With New ListSelectEventArgsClass
		If LM_SINGLE = g_oXListPage.Mode Then
			' В режиме отбора одного объекта получаем идентификатор выбранного
			.Selection = g_oXListPage.XList.GetSelectedObjectID()
		Else
			' В режиме отбора нескольких объектов формируем массив идентификаторов
			.Selection= g_oXListPage.XList.GetCheckedObjectIDs()		
		End If
		g_oXListPage.Internal_FireEvent "Ok", .Self()
	End With	
End Sub


'==============================================================================
' Закрытие окна в режиме отбора по кнопке "Отменить"
Sub XList_cmdCancel_OnClick()
	window.close
End Sub


'==============================================================================
' Нажатие на кнопку "Операции"
Sub XList_cmdOperations_onClick()
	g_oXListPage.XList.TrackContextMenu
End Sub


'==============================================================================
Sub XList_cmdRefresh_OnClick
	ReloadList()
End Sub

'==============================================================================
' Обработка команды: "Очистить фильтр"
Sub XList_cmdClearFilter_OnClick()
	g_oXListPage.FilterObject.ClearRestrictions()
	g_oXListPage.Internal_FireEvent "ResetFilter", Nothing
End Sub


'==============================================================================
' Обработчик кнопки "Скрыть"/"Показать" фильтр
Sub XList_cmdHideFilter_onCLick()
	g_oXListPage.SwitchFilter
End Sub


'==============================================================================
' Выбор всех объектов в списке
Sub XList_cmdSelectAll_OnClick
	g_oXListPage.XList.SelectAll
End Sub


'==============================================================================
' Снятие выделения
Sub XList_cmdDeselect_OnClick
	g_oXListPage.XList.DeselectAll
End Sub


'==============================================================================
' Инверсия выделения
Sub XList_cmdInvertSelection_OnClick
	g_oXListPage.XList.InvertSelection
End Sub


'==============================================================================
' Обработчик нажатия на кнопку "справка"
Sub XList_cmdOpenHelp_OnClick
	Document_OnHelp
End Sub
'</ОБРАБОТЧИКИ КНОПОК>

'<ОБРАБОТЧИКИ ActiveX-СОБЫТИЙ ListVIew>
'==============================================================================
' Обработчик события "OnWidthChange" ActiveX-компонента CROC.IXListView - cобытие изменения ширины колонки
Sub XListPage_OnListWidthChange(oDispSender, nColIndex, nWidth)
	g_oXListPage.XList.OnWidthChange nColIndex, nWidth
End Sub


'==============================================================================
' Обработчик события "OnDblClick" ActiveX-компонента CROC.IXListView - Двойное нажатие в строке списка
Sub XListPage_OnDblClick(ByVal oSender, ByVal nIndex , ByVal nColumn, ByVal sID)
	If LM_LIST = g_oXListPage.Mode Then
		' Примечание: почему-то синхронный вызов стал приводить к падению IE !!!
		window.setTimeout "g_oXListPage.XList.OnDblClick " & nIndex & "," & nColumn & ",""" & sID & """", 1 , "VBScript"
	ElseIf LM_SINGLE = g_oXListPage.Mode Then
		' Для режимов отбора одного элемента эмулируем нажатие ОК	
		XList_cmdOk_OnClick
	Else
		' Для режимов отбора множества элементов (LM_MULTIPLE, LM_MULTIPLE_OR_NONE) эмулируем клик на чекбоксе строки
		g_oXListPage.XList.ChangeSelectedRowState
	End If	
End Sub


'==============================================================================
' Нажатие клавиши в списке
Sub XListPage_OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)
	Internal_onKeyUp CreateAccelerationEventArgsForActiveXEvent(nKeyCode, nFlags)
End Sub
'</ОБРАБОТЧИКИ ActiveX-СОБЫТИЙ ListVIew>


'==============================================================================
' Отлов "отладочных" событий
' Показываем по PopUp-меню и CTRL на заголовке 
Sub OnDebugEvent()
	If Not IsObject(g_oXListPage) Then Exit Sub
	If Nothing Is g_oXListPage Then Exit Sub
	If Window.event.ctrlKey or X_IsDebugMode Then
		window.event.cancelBubble=true
		window.event.returnValue = false
		g_oXListPage.ShowDebugMenu
	End If
End Sub


'==============================================================================
' Oбработчик Html-события oncontextmenu.
' Отображает контекстное меню списка.
Sub TrackContextMenu()
	' Чистим системное событие, дабы не всплыло стандартное меню IE
	If Not window.event Is Nothing Then	
		window.event.cancelBubble = True
		window.event.returnValue = False
	End If
	' Будем ждать ПОЛНОЙ ЗАГРУЗКИ списка
	If g_bFullLoad = True Then 
		' В режиме списка "Выбрать" контексного меню не должно быть
		If g_oXListPage.Mode = LM_LIST Then 
			window.setTimeout "g_oXListPage.XList.TrackContextMenu", 0, "VBScript"
		End If
	End If
End Sub


'==============================================================================
' Перегружает список
' Примечание: вынесено из XListPageClass, т.к. вызывается из HTML-обработчиков
Public Sub ReloadList
	g_oXListPage.XList.Reload()	
	g_oXListPage.XList.SetDefaultFocus(g_oXListPage.FilterObject)
End Sub
