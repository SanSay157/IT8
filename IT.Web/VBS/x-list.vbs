'===============================================================================
'@@!!FILE_x-list
'<GROUP !!SYMREF_VBS>
'<TITLE x-list - Обслуживание списка на стороне клиента>
':Назначение:	Обслуживание списка на стороне клиента.
'===============================================================================
'@@!!CONSTANTS_x-list
'<GROUP !!FILE_x-list><TITLE Константы>
'@@!!CLASSES_x-list
'<GROUP !!FILE_x-list><TITLE Классы>
Option Explicit
 
'@@DEFAULT_MAXROWS
'<GROUP !!CONSTANTS_x-list>
':Описание:	Максимальное число строк списка по умолчанию. Значение константы - <B>500</B>.
const DEFAULT_MAXROWS = 500

'===============================================================================
'@@XListClass
'<GROUP !!CLASSES_x-list><TITLE XListClass>
':Назначение:	Компонент списка с меню на основе CROC.IXListView.
'				Содержит ссылку на элемент управления списка - ListView.
' Описание событий класса приведено в разделе <LINK points_wc1_03-1, События>
'@@!!MEMBERTYPE_Methods_XListClass
'<GROUP XListClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_XListClass
'<GROUP XListClass><TITLE Свойства>
'
Class XListClass
    '@@XListClass.ListView
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE ListView>
	':Назначение:	Элемент управления CROC.IXListView	
	Public ListView				' Контрол CROC.IXListView
	'@@XListClass.ObjectType
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE ObjectType>
	':Назначение:	Имя типа информационных объектов
	':Сигнатура:	Public ObjectType [String]
	Public ObjectType			' Имя типа информационных объектов
	'@@XListClass.TypedBy
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE TypedBy>
	':Назначение:	Имя колонки/макроса, которые определяют тип объекта
	':Сигнатура:	Public TypedBy [String]
	Public TypedBy				' имя колонки/макроса, которые определяют тип объекта 
	'@@XListClass.IdentifiedBy
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE IdentifiedBy>
	':Назначение:	Имя колонки/макроса, которые определяют идентификатор объекта
	':Сигнатура:	Public IdentifiedBy [Sring]
	Public IdentifiedBy			' имя колонки/макроса, которые определяют идентификатор объекта
	'@@XListClass.UseEditor
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE UseEditor>
	':Назначение:	Имя используемого редактора в метаданных или Null (устанавливается контейнером)
	':Сигнатура:	Public UseEditor [String]
	Public UseEditor			' Имя используемого редактора в метаданных или Null (устанавливается контейнером)
	'@@XListClass.UseWizard
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE UseWizard>
	':Назначение:	Имя используемого мастера в метаданных или Null (устанавливается контейнером)
	':Сигнатура:	Public UseWizard [String]
	Public UseWizard			' Имя используемого мастера в метаданных или Null (устанавливается контейнером)
	'@@XListClass.MaxRows
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE MaxRows>
	':Назначение:	Максимальное кол-во строк (устанавливается контейнером)
	':Сигнатура:	Public MaxRows [Integer]
	Public MaxRows				' Максимальное кол-во строк (устанавливается контейнером)
	'@@XListClass.GridLines
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE GridLines>
	':Назначение:	Признак отображения разметки табличного представления (сетки списка)
	':Сигнатура:	Public GridLines [Boolean]
	Public GridLines			' Признак отображения гридлайнов (устанавливается контейнером)
	'@@XListClass.CheckBoxes
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE CheckBoxes>
	':Назначение:	Признак показа полей выбора (устанавливается контейнером)
	':Сигнатура:	Public CheckBoxes [Boolean]
	Public CheckBoxes			' Признак показа checkbox'ов (устанавливается контейнером)
	'@@XListClass.ShowLineNumbers
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE ShowLineNumbers>
	':Назначение:	Признак показа номеров строк (устанавливается контейнером)
	':Сигнатура:	Public ShowLineNumbers [Boolean]
	Public ShowLineNumbers		' Признак показа номеров строк (устанавливается контейнером)

    '@@XListClass.Loader
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE Loader>
	':Назначение:	URL загрузчика списка (устанавливается контейнером)
	':Сигнатура:	Public Loader [String]
	Public Loader				' URL загрузчика списка (устанавливается контейнером)
	'@@XListClass.Restrictions
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE Restrictions>
	':Назначение:	Дополнительные параметры загрузчику, устанавливаемые контейнером (передается загрузчику параметром RESTR)
	':Сигнатура:	Public Restrictions [String]
	Public Restrictions			' Дополнительные параметры загрузчику, устанавливаемые контейнором (передается загрузчику параметром RESTR)
	'@@XListClass.ValueObjectIDs
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE ValueObjectIDs>
	':Назначение:	Список идентификаторов объектов, которые должны присутствовать в выборке (передается загрузчику параметром VALUEOBJECTID)
	':Сигнатура:	Public ValueObjectIDs [String]
	Public ValueObjectIDs		' Список идентификаторов объектов, которые должны присутствовать в выборе (передается загрузчику параметром VALUEOBJECTID)
	
	'@@XListClass.OffCreate
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE OffCreate>
	':Назначение:	Признак недоступности операции создания объектов
	':Сигнатура:	Public OffCreate [Boolean]
	Public OffCreate			
	'@@XListClass.OffEdit
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE OffEdit>
	':Назначение:	Признак недоступности операции редактирования
	':Сигнатура:	Public OffEdit [Boolean]
	Public OffEdit				
	'@@XListClass.OffClear
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE OffClear>
	':Назначение:	Признак недоступности операции удаления
	':Сигнатура:	Public OffClear [Boolean]
	Public OffClear				
	'@@XListClass.OffReport
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE OffReport>
	':Назначение:	Признак отключения команды выдачи отчета, идентичного списку объектов
	':Сигнатура:	Public OffReport [Boolean]
	Public OffReport			 
	'@@XListClass.AccelProcessing
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE AccelProcessing>
	':Назначение:	Признак того, что идет обработка комбинации "горячих" клавиш
	':Сигнатура:	Public AccelProcessing [Boolean]
	Public AccelProcessing		' Признак того, что идет обработка хоткея
	
	Private EVENTS				' список поддерживаемых событий
	Private m_sXListPageVarName	' As String	- наименование переменной с экземпляром контейнера
	Private m_oMenu				' As MenuClass - меню
	Private m_oEventEngine		' As EventEngineClass	

	Private m_sCaption			' Заголовок списка
	Private m_bInTrackContextMenu	' Признак того, что контекстное меню уже строится и не надо строить его повторно
	Private m_bMayBeInterrupted	' Признак того, что компонент ничем не знанят и уход со страницы не вызовет негативных последствий
	Private m_sOldSelectedID	' Идентификатор выделенной строки до перезагрузки списка
	
	'==========================================================================
	'@@XListClass.MayBeInterrupted
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE MayBeInterrupted>
	':Назначение:	Признак того, что компонент ничем не знанят и уход со страницы не вызовет негативных последствий
	':Сигнатура:	Public Property Get MayBeInterrupted [Boolean]
	Public Property Get MayBeInterrupted
		MayBeInterrupted = (m_bMayBeInterrupted=True And m_bInTrackContextMenu<>True)
	End Property
	Private Property Let MayBeInterrupted(bValue)
		m_bMayBeInterrupted = bValue=true
	End Property
	
	
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "BeforeEdit,Edit,AfterEdit," & _
				"BeforeCreate,Create,AfterCreate," & _
				"BeforeDelete,Delete,AfterDelete," & _
				"BeforeListReload,AfterListReload,GetRestrictions," & _
				"ListColumnWidthChange,MenuBeforeShow,Accel,SetDefaultFocus"
		MayBeInterrupted = true
		m_bInTrackContextMenu = False
		Set m_oEventEngine = X_CreateEventEngine
		' Инициализируем коллекцию обработчиков события
		m_oEventEngine.InitHandlers EVENTS, "usrXList_On"
		' Стандартные обработчики добавим только, если не нашли пользовательских
		' 3-ий True означает: добавлять обработчик только в случае отсутствия для данного события других обработчиков
		' 4-ый False означает: не перезаписывать коллекцию обработчиков, а добавлять в нее
		m_oEventEngine.InitHandlersEx EVENTS, "stdXList_On", True, False
		Set m_oMenu = New MenuClass
	End Sub
	

	'==========================================================================
	' Инициализация обратной ссылки на контейнер
	Sub Internal_SetContainer(sContainerVarName)
		m_sXListPageVarName = sContainerVarName
	End Sub


	'==========================================================================
	'@@XListClass.InitMenu
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE InitMenu>
	':Назначение: Инициализация меню.
	':Сигнатура: Public Sub InitMenu(oMenuXmlMD [as XMLDOMElement])
	':Параметры: 
	'	oMenuXmlMD - 
	'       [in] метаданные меню.
	Public Sub InitMenu(oMenuXmlMD)
		' создадим объект меню и установим стандартные обработчики
		m_oMenu.SetMacrosResolver X_CreateDelegate(Me, "MenuMacrosResolver")
		m_oMenu.SetVisibilityHandler X_CreateDelegate(Me, "MenuVisibilityHandler")
		m_oMenu.SetExecutionHandler X_CreateDelegate(Me, "MenuExecutionHandler")
		If Not oMenuXmlMD Is Nothing Then
			' инициализировать меню имеет смысл если оно задано в МД
			m_oMenu.Init oMenuXmlMD
		End If
		' удостоверимся, что в коллекции есть предопределенный набор параметров: ObjectID, ObjectType
		m_oMenu.Macros.Item("OBJECTID") = Null
		m_oMenu.Macros.Item("OBJECTTYPE") = ObjectType
	End Sub


	'==========================================================================
	'@@XListClass.Container
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE Container>
	':Назначение:	Возвращает экземпляр контейнера XListPage, владельца для текущего экземпляра XList
	':Сигнатура:	Public Property Get Container [As XListPage]
	Public Property Get Container
		Set Container = Eval(m_sXListPageVarName)
	End Property


	'==========================================================================
	'@@XListClass.Menu
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE Menu>
	':Назначение:	Возвращает экземпляр меню
	':Сигнатура:	Public Property Get Menu [As MenuClass]	
	Public Property Get Menu
		Set Menu = m_oMenu
	End Property


	'==========================================================================
	'@@XListClass.EventEngine
	'<GROUP !!MEMBERTYPE_Properties_XListClass><TITLE EventEngine>
	':Назначение:	Возвращает экземпляр <LINK Client_EventEngine, EventEngineClass>, используемый для генерации событий
	':Сигнатура:	Public Property Get EventEngine [As <LINK Сlient_EventEngine, EventEngineClass>]	
	Public Property Get EventEngine
		Set EventEngine = m_oEventEngine
	End Property
	
	
	'==========================================================================
	' Возбуждает событие
	'	[in] sEventName As String
	'	[in] oEventArgs As Object 
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub
	
	'==========================================================================
	'@@XListClass.SetCaption
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SetCaption>
	':Назначение: Установка заголовка списка.
	':Сигнатура: Public Sub SetCaption(sCaption [as Sting])
	':Параметры: 
	'	sCaption - 
	'       [in] строка с текстом заголовка списка.
	'
	Public Sub SetCaption(sCaption)
		m_sCaption = sCaption
	End Sub


	'==========================================================================
	'@@XListClass.GetRestrictions
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetRestrictions>
	':Назначение: Возвращает строку ограничений фильтра, полученную от контейнера.
	':Сигнатура: Public Function GetRestrictions() [as String]
	Public Function GetRestrictions()
        With New GetRestrictionsEventArgsClass
            .StayOnCurrentPage = False
            .ReturnValue = vbNullString
            .UrlParams = vbNullString
            FireEvent "GetRestrictions", .Self()
            GetRestrictions = .ReturnValue
        End With
	End Function

	
	'==========================================================================
	'@@XListClass.Reload
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE Reload>
	':Назначение:  Перезагружает список в соответствии с ограничениями фильтра.
	':Сигнатура: Public Sub Reload()
	Public Sub Reload()
		ReloadEx False
	End Sub
	
	'==========================================================================
	'@@XListClass.ReloadEx
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE ReloadEx>
	':Назначение:  Перезагружает список в соответствии с ограничениями фильтра.
	':Сигнатура: Public Sub ReloadEx( bStayOnCurrentPage [As Boolean])
	':Параметры: 
	'	bStayOnCurrentPage - 
	'       [in] признак, задающий необходимость остаться на текущей странице 
	'			(при использовании пейджинга).
	Public Sub ReloadEx(bStayOnCurrentPage)
		Dim bMoreRows		' Признак того, что есть больше объектов, чем заказано
		Dim sWhere			' Ограничения фильтра
		Dim sUrlParams      ' Дополнительные параметры, передаваемые в звгрузчик
		Dim dtTime

		MayBeInterrupted = false
		
		m_sOldSelectedID = ListView.Rows.SelectedID
		FireEvent "BeforeListReload", Nothing
		
		With X_CreateControlsDisabler(Me)
			Container.ShowProcessMessage "Получение ограничений..."

			' #259932 - Ошибка при обработке hotkey в случае, если в поле в фильтре введено неправильное значение.
			' Почистим список для устранения подобных side-эффектов
			' Потому как у нас не предусмотрено никакого механизма для хранения признака неудачной 
			' загрузки списка
			ListView.Rows.RemoveAll()
				
		    ' Получаем ограничения фильтра
		    ' Примечание: не используем метод GetRestrictions, т.к. нам его надо получить UrlParams
            With New GetRestrictionsEventArgsClass
                .ReturnValue = vbNullString
                .UrlParams = vbNullString
                .StayOnCurrentPage = bStayOnCurrentPage
                FireEvent "GetRestrictions", .Self()
                sWhere = .ReturnValue
                sUrlParams = .UrlParams
            End With
            If 0<>Len(sUrlParams) Then
                sUrlParams = "&" & sUrlParams
            End If    
        
			If False = sWhere Then
				' произошла обшика сбора данных. False должен установить обработчик, стандартный обработчик контейнера x-list-page так и делает
				Container.ShowProcessMessage "Неправильно заполнены ограничения..."
				' Ошибка в фильтре - отвалим!
				MayBeInterrupted = true
				Exit Sub
			End If

			Container.ShowProcessMessage "Загрузка списка..."

			ListView.ShowBorder = False
			' номера строк показывает, если это не запрещено атрибутом off-rownumbers
			ListView.LineNumbers = ShowLineNumbers
			' Перед загрузкой списка отключаем сетку - так красивее...
			ListView.GridLines = False

			If 0=ListView.Columns.Count Then
				RestoreColumnsFromUserData
			End If
			
			' ЗДЕСЬ ОШИБКИ ОБРАБАТЫВАЕМ
			On Error Resume Next
			dtTime = Now()
			bMoreRows = ListView.XMLLoad( Loader & "&TM=" & ListView.XClientService.NewGuidString() ,"WHERE=" & ListView.XClientService.URLEncode(sWhere) & "&RESTR=" &  ListView.XClientService.URLEncode(Restrictions) & "&VALUEOBJECTID=" & ListView.XClientService.URLEncode(ValueObjectIDs) & sUrlParams , MaxRows , True)	
			If Err Then
				X_SetLastServerError ListView.XClientService.LastServerError, Err.number, Err.Source, Err.Description
				If X_IsSecurityException(ListView.XClientService.LastServerError) Then
					Container.ShowProcessMessage "В доступе отказано..."
					Err.Clear
					MayBeInterrupted=true
					Exit Sub
				Else
					X_HandleError
					ReportStatus "Список не загружен: " & Err.description
				End If
			Else
				dtTime = Now() - dtTime
				ReportStatus "Список загружен ("	& CStr(DatePart("n",dtTime) * 60 + DatePart("s",dtTime)) & " сек.)"
			End If
			On Error GoTo 0
			' ЗДЕСЬ ОШИБКИ НЕ ОБРАБАТЫВАЕМ
			If 0 = ListView.Rows.Count Then
				If Len( sWhere) = 0 Then
					Container.ShowProcessMessage "Отсутствуют данные для отображения в списке."
				Else
					Container.ShowProcessMessage "Нет информации, удовлетворяющей фильтру."
				End If
			Else
				ListView.GridLines = GridLines
				Container.HideProcessMassage
				' TODO:
				' Здесь было: ListView.Rows.SelectedPosition=0
				' Установка ListView.Rows.SelectedPosition без предварительной
				' установки фокуса приводит к ужасным визуальным эффектам в списке -
				' поэтому сейчас закомментировано
			End If
		End With
		ListView.CheckBoxes = CheckBoxes
		
		With New AfterListReloadEventArgsClass
			.HasMoreRows = bMoreRows
			.MaxRows = MaxRows
			.Restrictions = sWhere
			FireEvent "AfterListReload", .Self()
		End With
			
		MayBeInterrupted = true
	End Sub


	'==============================================================================
	'@@XListClass.TrackContextMenu
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE TrackContextMenu>
	':Назначение: Отработка контекстного меню.
	':Сигнатура: Public Sub TrackContextMenu()
	
	Public Sub TrackContextMenu()
		Internal_showContextMenu Null, Null
	End Sub


	'==============================================================================
	' Отображает контекстое меню списка либо в заданной точке, либо в текущей позиции курсора мыши
	'	[in] nPosX - экранная X-координта для отображения меню или Null
	'	[in] nPosY - экранная Y-координта для отображения меню или Null
	Private Sub Internal_showContextMenu(nPosX, nPosY)
		If m_bInTrackContextMenu = True Then Exit Sub
		m_bInTrackContextMenu = True

		' Смотрим задано ли меню для списка
		If m_oMenu Is Nothing Then m_bInTrackContextMenu = False: Exit Sub: End If
		If Not m_oMenu.Initialized Then m_bInTrackContextMenu = False: Exit Sub: End If
		
		With X_CreateControlsDisabler(Me)
			prepareMenuBeforeShow
			' отобразим меню
			If IsNull(nPosX) Or IsNull(nPosY) Then
				m_oMenu.ShowPopupMenu Me
			Else
				m_oMenu.ShowPopupMenuWithPos Me, nPosX, nPosY
			End If
		End With
		m_bInTrackContextMenu = False
	End Sub


	'==============================================================================
	' Подготавливает меню к отображению
	Private Sub prepareMenuBeforeShow
		' TODO: здесь надо сделать анализ атрибута load-cmd узла list-menu метаданных списка и загрузку меню с сервера, 
		' если он задан. Если загрузка будет с сервера, то объект меню надо переинициализировать.
		
		' вызовем пользовательский обработчик
		' ВНИМАНИЕ, если пользовательский обработчик добавит пункты меню, то он должен установить им атрибуты n
		With New MenuEventArgsClass
			Set .Menu = m_oMenu
			FireEvent "MenuBeforeShow", .Self()
		End With
	End Sub
	
	
	'==============================================================================
	'@@XListClass.MenuMacrosResolver
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE MenuMacrosResolver>
	':Назначение: Подстановка значений макросов меню ObjectType и ObjectID.
	':Сигнатура: Public Sub MenuMacrosResolver(
	'               oSender [as MenuClass], 
	'               oEventArgs [as MenuEventArgsClass])
	':Параметры: 
	'   oSender -
	'       [in] объект, сгенерировавший событие, экземпляр класса MenuClass
	'   oEventArgs - 
	'       [in] параметры события, экземпляр MenuEventArgsClass
	Public Sub MenuMacrosResolver(oSender, oEventArgs)
		Dim oRow			' выбранная строка списка IXListRow
		Dim sKey			' ключ в хеш-таблице
		Dim i

		' Сначала сбросим все значения макросов
		For Each sKey In m_oMenu.Macros.Keys
			m_oMenu.Macros.Item(sKey) = Null
		Next
		' поставим значение предопределенных макросов - наименование типа и выбранный идентификатор (они есть всегда)
		
		m_oMenu.Macros.item("ObjectType") = ObjectType
		' подставим значения макросом, чьи имена совпадают с наименованиями колонок
		' Значением макроса будет ячейка на пересечении выбранной строки и колонки, наименование которой совпадает с именем макроса
		If ListView.Rows.Selected>=0 Then
			Set oRow = ListView.Rows.GetRow( ListView.Rows.Selected )
			For i=0 To ListView.Columns.Count-1
				sKey = UCase(ListView.Columns.GetColumn(i).Name)
				If sKey<>"OBJECTID" And sKey<>"OBJECTTYPE" Then
					m_oMenu.Macros.Item(sKey) = oRow.GetField(i).Value
				End If
				If UCase(IdentifiedBy) = sKey Then
					' текущая колонка используется для идентификации объекта
					m_oMenu.Macros.item("ObjectID") = oRow.GetField(i).Value
				End If
				If UCase(TypedBy) = sKey Then
					m_oMenu.Macros.item("ObjectType") = oRow.GetField(i).Value
				End If
			Next
			If IsNull( m_oMenu.Macros.item("ObjectID") ) Then
				' в случае дефолтовой идентификации, либо если колонки указанной в identified-by не нашли, берем id текущей строки
				m_oMenu.Macros.item("ObjectID") = GetSelectedRowID()
			End if
		End If
	End Sub
	
	
	'==============================================================================
	'@@XListClass.MenuVisibilityHandler
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE MenuVisibilityHandler>
	':Назначение: Стандартный обработчик установки доступности/видимости пунктов меню. Проставляет признаки доступности стандартных пунктов меню. 
	'      Тип и идентификатор объекта, для которого проверяется доступность операции, берутся из словаря макросов меню (а не из выбранной строки).
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
		Dim sGUID			' As String - идентификатор выбранного объекта
		Dim sType			' As String - наименование типа выбранного объекта
		Dim bDisabled		' As Boolean - признак заблокированности пункта
		Dim bHidden			' As Boolean - признак сокрытия пункта
		Dim oNode			' As XMLDOMElement - текущий menu-item
		Dim oParam			' As IXMLDOMElement - узел param в метаданных меню 
		Dim oList			' As ObjectArrayListClass - массив объектов XObjectPermission
		Dim sAction			' As String - наименования действия(action'a) пункта меню
		Dim bProcess		' As Boolean - признак обработки текущего пункта
		Dim bTrustworthy	' As Boolean - признак "заслуживающего доверия" меню - для его пункто не надо выполнять проверку прав

		sType = m_oMenu.Macros.item("ObjectType")
		sGUID = m_oMenu.Macros.item("ObjectID")
		Set oList = New ObjectArrayListClass
		bTrustworthy = Not IsNull(m_oMenu.XmlMenu.getAttribute("trustworthy"))
		' Обработаем только известные нам операции
		For Each oNode In oEventArgs.ActiveMenuItems
			bHidden = Empty
			bDisabled = Empty
			bProcess = False
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
			If Not bTrustworthy Then 
				oNode.setAttribute "type", sType
				If hasValue(sGUID) Then _
					oNode.setAttribute "oid",  sGUID
			End If

			sAction = oNode.getAttribute("action")
			Select Case sAction
				Case CMD_ADD
					bHidden = OffCreate
					If Not bTrustworthy Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CREATE, sType, Empty)
					bProcess = True
				Case CMD_VIEW
					bHidden = IsNull(sGUID)
					bProcess = True
				Case CMD_EDIT
					bHidden = IsNull(sGUID) Or OffEdit
					If Not bHidden And Not bTrustworthy Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CHANGE, sType, sGUID)
					bProcess = True
				Case CMD_DELETE
					bHidden = IsNull(sGUID) Or OffClear
					If Not bHidden And Not bTrustworthy Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_DELETE, sType, sGUID)
					bProcess = True
				Case Else
					With New SetMenuItemVisibilityEventArgsClass
						Set .Menu = m_oMenu
						Set .MenuItemNode = oNode
						.Action = sAction
						FireEvent "SetMenuItemVisibility", .Self()
						bHidden		= .Hidden
						bDisabled	= .Disabled
					End With
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
			m_oMenu.SetMenuItemsAccessRights oList.GetArray()
		End If
	End Sub
	
	
	'==========================================================================
	'@@XListClass.MenuExecutionHandler
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE MenuExecutionHandler>
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
		Dim sGUID		' идентификатор выбранного объекта

		sGUID = m_oMenu.Macros.item("ObjectID")
		Select Case oEventArgs.Action
			Case CMD_EDIT:
				' если метаимя редактора не задано через параметры меню, установим его на основании атрибута use-for-editing objects-list'a
				If Not hasValue(m_oMenu.Macros.Item("MetanameForEdit")) Then
					m_oMenu.Macros.Item("MetanameForEdit") = UseEditor
				End If
				oEventArgs.Cancel = Not DoEdit(m_oMenu.Macros)
			Case CMD_ADD:			
				' если метаимя мастера не задано через параметры меню, установим его на основании атрибута use-for-creation objects-list'a
				If Not hasValue(m_oMenu.Macros.Item("MetanameForCreate")) Then
					m_oMenu.Macros.Item("MetanameForCreate") = UseWizard
				End If
				oEventArgs.Cancel = Not DoCreate(m_oMenu.Macros)
			Case CMD_DELETE:
				If Not hasValue(m_oMenu.Macros.Item("Prompt")) Then
					m_oMenu.Macros.Item("Prompt") = "Вы действительно хотите удалить объект?"
				End If
				oEventArgs.Cancel = Not DoDelete(m_oMenu.Macros)
			Case CMD_VIEW:			
				X_OpenReport m_oMenu.Macros.Item("ReportURL")
		End Select
	End Sub
	
	'==========================================================================
	'@@XListClass.DoEdit
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE DoEdit>
	':Назначение: Редактирование объекта списка. Возвращает True, если операция выполнена.
	':Сигнатура: Public Function DoEdit(oValues [as Scripting.Dictionary]) [As Boolean]
	':Параметры: 
	'    oValues -
	'       [in] коллекция параметров операции меню
	Public Function DoEdit(oValues)
		Dim sGUID	' Идентификатор текущего объекта
		DoEdit = False
		sGUID = oValues.Item("ObjectID")
		If 0 = Len(sGUID) Then Exit Function
		With X_CreateControlsDisabler(Me)
			With New CommonEventArgsClass
				.ObjectID = sGUID
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = False
				' установим метаимя редактора. Оно должно быть задано в коллекции макросов
				.Metaname = oValues.Item("MetanameForEdit")
				Set .Values = oValues
				' подготовка к редактированию
				FireEvent "BeforeEdit", .Self()
				' обработчики могли выставить флаг "прервать выполнение"
				If .ReturnValue Then Exit Function
				' редактирование
				FireEvent "Edit", .Self()
				' по завершении редактирования
				FireEvent "AfterEdit", .Self()
			End With
		End With
		DoEdit = True
	End Function

	'==========================================================================
	'@@XListClass.DoCreate
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE DoCreate>
	':Назначение: Создание нового объекта списка. Возвращает True, если операция выполнена.
	':Сигнатура: Public Function DoCreate(oValues [as Scripting.Dictionary]) [As Boolean]
	':Параметры: 
	'    oValues -
	'       [in] коллекция параметров операции меню
	Public Function DoCreate(oValues)
		DoCreate = False
		With X_CreateControlsDisabler(Me)
			With New CommonEventArgsClass
				.ObjectID = Null
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = Empty
				' установим метаимя мастера. Оно должно быть задано в коллекции макросов
				.Metaname = oValues.Item("MetanameForCreate")
				Set .Values = oValues
				' подготовка к созданию
				FireEvent "BeforeCreate", .Self()
				' обработчики могли выставить флаг "прервать выполнение"
				If .ReturnValue Then Exit Function
				' создание
				FireEvent "Create", .Self()
				' постобработка
				FireEvent "AfterCreate", .Self()			
			End With	
		End With
		DoCreate = True
	End Function

	'==========================================================================
	'@@XListClass.DoDelete
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE DoDelete>
	':Назначение: Удаление  объекта списка. Возвращает True, если операция выполнена.
	':Сигнатура: Public Function DoDelete(oValues [as Scripting.Dictionary]) [As Boolean]
	':Параметры: 
	'    oValues -
	'       [in] коллекция параметров операции меню
	Public Function DoDelete(oValues)
		Dim sGUID		' Идентификатор удаляемого объекта		
		DoDelete = False
		' получим идентификатор удаляемого объекта
		sGUID = oValues.Item("ObjectID")
		If 0=Len(sGUID) Then Exit Function
		With X_CreateControlsDisabler(Me)
			With New DeleteObjectEventArgsClass
				.ObjectID = sGUID
				.ObjectType = oValues.Item("ObjectType")
				.ReturnValue = True
				Set .Values = oValues
				' подготовка к удалению
				FireEvent "BeforeDelete", .Self()
				' обработчики могли выставить флаг "прервать выполнение"
				If .ReturnValue = False Then Exit Function
				' создание
				FireEvent "Delete", .Self()
				' обработчики могли выставить флаг "прервать выполнение"
				If .ReturnValue = False Then Exit Function
				' постобработка
				FireEvent "AfterDelete", .Self()
			End With
		End With
		DoDelete = True
	End Function
	
	
	'==========================================================================	
	'@@XListClass.EnableControlsInternal
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE EnableControlsInternal>
	':Назначение: Блокирование/разблокирование элементов управления. Вызывается снаружи (из контейнера). Передает управление контейнеру.
	':Сигнатура: Public Sub EnableControlsInternal( 
	'                   ByVal bEnable [as Boolean])
	':Параметры: 
	'    bEnable - 
	'       [in] признак блокировки/разблокировки элементов управления.
	Public Sub EnableControlsInternal( ByVal bEnable)
		ListView.LockEvents = not bEnable
	End Sub


	'==========================================================================	
	'@@XListClass.EnableControls
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE EnableControls>
	':Назначение: Блокирование/разблокирование элементов управления. Вызывается изнутри (с помощью X_CreateControlsDisabler).
	' Передает управление контейнеру.
	':Сигнатура: Public Sub EnableControls (ByVal bEnable [as Boolean])	
	':Параметры: 
	'    bEnable - 
	'       [in] признак блокировки/разблокировки элементов управления.
	Public Sub EnableControls( ByVal bEnable)
		EnableControlsInternal bEnable
		Container.EnableControls bEnable
	End Sub


	'==========================================================================
	' Вывод строки статуса загрузки
	'	[In] sMsg - выводимая строка
	Private Sub ReportStatus( sMsg)
		Container.ReportStatus sMsg
	End Sub
	
	'==========================================================================
	'@@XListClass.RestoreColumnsFromUserData
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE RestoreColumnsFromUserData>
	':Назначение: Восстанавливает представление списка из xml-файла, сохраненного с помощью SaveUserData.
	':Сигнатура: Public Sub RestoreColumnsFromUserData
	Public Sub RestoreColumnsFromUserData
		Dim oListColumns	' IXMLDOMElement, переменная со описанием колонок
		
		If Container.GetViewStateCache( "columns", oListColumns) Then
			If IsObject(oListColumns) Then
				If Not Nothing Is oListColumns.selectSingleNode("C") Then
					With XService.XmlGetDocument
						.appendChild .createElement("LIST")
						.documentElement.appendChild oListColumns
						.documentElement.appendChild .createElement("RS")
					End With
					ListView.XMLFillList oListColumns.ownerDocument, -1, True
				End If
				Set oListColumns = Nothing
			End If	
		End If
	End Sub


	'==========================================================================
	'@@XListClass.SaveColumnsInUserData
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SaveColumnsInUserData>
	':Назначение: Сохраняет представление списка в xml-файл.
	':Сигнатура: Public Sub SaveColumnsInUserData
	Public Sub SaveColumnsInUserData
		If 0=ListView.Columns.Count Then Exit Sub
		Container.SaveViewStateCache "columns", ListView.Columns.Xml
	End Sub
	
	
	'==========================================================================
	'@@XListClass.SetListFocus
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SetListFocus>
	':Назначение: Устанавливает фокус на список
	':Сигнатура: Public Sub SetListFocus()
	Public Sub SetListFocus()
		window.Focus()
		' установка фокуса выполняется под контролем ошибки - т.к. сам список
		' в силу внешних причин (отсутствие прав, функционал прикладных обработчиков 
		' и т.д.) может быть недоступен или скрыт
		on error resume next
		ListView.Focus()
		on error goto 0
	End Sub	


	'==============================================================================
	'@@XListClass.SetDefaultFocus
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SetDefaultFocus>
	':Назначение: Вызывает поведение по установке фокуса после перегрузки списка.
	'   Генерируется событие SetDefaultFocus если есть обработчик, иначе вызывает 
	'   стандартную реализацию.
	':Сигнатура:  Public Sub SetDefaultFocus(oFilterObject [as XFilterObjectClass])
	':Параметры: 
	'   oFilterObject - 
	'           [in] htc-объект фильтра
	Public Sub SetDefaultFocus(oFilterObject)
		' для ценителей жанра возможность заменить поведение	
		If m_oEventEngine.IsHandlerExists("SetDefaultFocus") Then
			With New SetDefaultFocusEventArgsClass
				Set .FilterObject = toObject(oFilterObject)
				FireEvent "SetDefaultFocus", .Self()
			End With
		Else
			SetDefaultFocusImpl(oFilterObject)
		End If
	End Sub
	
	'==============================================================================
	'@@XListClass.SetDefaultFocusImpl
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SetDefaultFocusImpl>
	':Назначение: Стандартная реализация установки фокуса после перегрузки списка. 
	'       Если есть записи, то фокус устанавливается на запись, которая была до перезагрузки. Если записей нет, фокус устанавливается на фильтр.
	':Сигнатура: Public Sub SetDefaultFocusImpl(oFilterObject [as XFilterObjectClass])
	':Параметры: 
	'   oFilterObject - 
	'           [in]  htc-объект фильтра
	Public Sub SetDefaultFocusImpl(oFilterObject)
		If ListView.Rows.Count > 0 Then
			SetListFocus
			
			If Len(m_sOldSelectedID) > 0 Then
				If Not ListView.Rows.FindRowByID(m_sOldSelectedID) Is Nothing Then
					ListView.Rows.SelectedID = m_sOldSelectedID
				ElseIf ListView.Rows.Count > 0 Then
					ListView.Rows.SelectedPosition = 0
				End If
			Else
				ListView.Rows.SelectedPosition = 0
			End If
		ElseIf hasValue(oFilterObject) Then
			oFilterObject.SetFocus
		End If
	End Sub
	
	'==============================================================================
	'@@XListClass.GetRowObjectTypeName
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetRowObjectTypeName>
	':Назначение: Возвращает наименование типа объекта заданной строки
	':Сигнатура: Public Function GetRowObjectTypeName(oRow [as IXListRow]) [as String]
	':Параметры: 
	'   oRow - 
	'   	[in] строка списка
	Public Function GetRowObjectTypeName(oRow)
		Dim i
		Dim sColumnName		' наименование колонки
		
		For i=0 To ListView.Columns.Count-1
			sColumnName = UCase(ListView.Columns.GetColumn(i).Name)
			If UCase(TypedBy) = sColumnName Then
				GetRowObjectTypeName = oRow.GetField(i).Value
				Exit Function
			End If
		Next
		GetRowObjectTypeName = ObjectType
	End Function
	
	
	'==============================================================================
	'@@XListClass.GetSelectedRowObjectTypeName
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetSelectedRowObjectTypeName>
	':Назначение: Возвращает наименование типа объекта текущей выбранной строки.
	':Сигнатура: Public Function GetSelectedRowObjectTypeName() [as String]	
	Public Function GetSelectedRowObjectTypeName()
		If ListView.Rows.Selected >= 0 Then
			GetSelectedRowObjectTypeName = GetRowObjectTypeName( ListView.Rows.GetRow(ListView.Rows.Selected) )
		End If
	End Function

		
	'==========================================================================
	'@@XListClass.GetTypeName
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetTypeName>
	':Назначение: Возвращает тип объектов, загруженных в список.
	':Сигнатура: Public Function GetTypeName() [as String]
	Public Function GetTypeName()
		GetTypeName = ObjectType
	End Function

	'==========================================================================
	'@@XListClass.GetSelectedRowID
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetSelectedRowID>
	':Назначение: Возвращает идентификатор выбранной строки или пустую строку.
	':Сигнатура: Public Function GetSelectedRowID() [as Variant]
	Public Function GetSelectedRowID()
		GetSelectedRowID = ListView.Rows.SelectedID
	End Function

	'==========================================================================
	'@@XListClass.GetSelectedObjectID
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetSelectedObjectID>
	':Назначение: Возвращает идентификатор выбранного объекта или пустую строку.
	':Сигнатура: Public Function GetSelectedObjectID() [as String]
	Public Function GetSelectedObjectID()
		Dim oRow
		If not hasValue( IdentifiedBy) Then
			GetSelectedObjectID = GetSelectedRowID()
		ElseIf ListView.Rows.Selected >= 0 Then
			Set oRow = ListView.Rows.GetRow( ListView.Rows.Selected )
			GetSelectedObjectID = oRow.GetFieldByName(IdentifiedBy)
		End If
	End Function
	
	'==========================================================================
	'@@XListClass.GetSelectedRow
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetSelectedRow>
	':Назначение: Возвращает индекс выбранной строки.
	':Сигнатура: Public Function GetSelectedRow() [as Integer]
	Public Function GetSelectedRow()
		GetSelectedRow = ListView.Rows.Selected
	End Function

	'==========================================================================
	'@@XListClass.GetCheckedObjectIDs
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE GetCheckedObjectIDs>
	':Назначение: Возвращает массив идентификаторов отмеченных строк.
	':Сигнатура: Public Function GetCheckedObjectIDs [as Variant]
	Public Function GetCheckedObjectIDs
		Dim vSel
		Dim nIdx
		Dim i
		
		ReDim vSel(ListView.Rows.Count - 1)	' Распределяем массив по количеству строк в списке
		nIdx = 0
		With ListView.Rows
			For i=0 To .count -1
				With .GetRow(i)
					If .Checked Then
						vSel( nIdx) = .ID	' Заносим идентификаторы отобранных строк в массив
						nIdx = nIdx + 1
					End If
				End With
			Next
		End With
		ReDim Preserve vSel(nIdx - 1)	' Оставляем в массиве только идентификаторы
		GetCheckedObjectIDs = vSel
	End Function


	'==========================================================================
	'@@XListClass.SelectRowByID
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SelectRowByID>
	':Назначение: Возвращает массив идентификаторов отмеченных строк. Устанавливает текущей строку по ID строки (он же ID объекта, если не используется кастомная идентификация через атрибут identified-by меню) sGUID - идентификатор объекта.
	' <b>Внимание!</b> Данный метод может использоваться подгружаемыми скриптами.
	':Сигнатура: Public Sub SelectRowByID (sGUID [as String])
	':Параметры: 
	'       sGUID - 
	'           [in] идентификатор объекта
	Public Sub SelectRowByID( sGUID)
		Dim oRow ' Строка списка
		Set oRow = ListView.Rows.FindRowByID(sGUID) 
		If Nothing Is oRow Then Exit Sub
		ListView.Rows.SelectedID = sGUID
	End Sub


	'==========================================================================	
	'@@XListClass.SelectRowByObjectID
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SelectRowByObjectID>
	':Назначение: Выбирает строку по идентификатору объекта.
	':Сигнатура: Public Sub SelectRowByObjectID(sObjectID [as String])
	':Параметры: 
	'       sObjectID - 
	'           [in] идентификатор объекта
	Public Sub SelectRowByObjectID(sObjectID)
		If Not hasValue(IdentifiedBy) Then
			SelectRowByID sObjectID
		Else
			SelectRowByFieldValue IdentifiedBy, sObjectID
		End If
	End Sub

	'==============================================================================
	'@@XListClass.SelectAll
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE SelectAll>
	':Назначение: В режиме множественного выбора отмечает все строки.
	':Сигнатура: Public Sub SelectAll
	Public Sub SelectAll
		Dim i
		If Not CheckBoxes Then Exit Sub
		For i=0 to ListView.Rows.Count -1
			ListView.Rows.GetRow(i).Checked = True
		Next
	End Sub


	'==============================================================================
	'@@XListClass.DeselectAll
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE DeselectAll>
	':Назначение: В режиме множественного выбора снимает отметку со всех выбранных строк
	':Сигнатура: Public Sub DeselectAll
	Public Sub DeselectAll
		Dim i
		If Not CheckBoxes Then Exit Sub
		For i=0 to ListView.Rows.count -1
			ListView.Rows.GetRow(i).Checked = false
		Next
	End Sub


	'==============================================================================
	'@@XListClass.InvertSelection
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE InvertSelection>
	':Назначение: В режиме множественного выбора инвертирует выделение выбранных строк.
	':Сигнатура: Public Sub InvertSelection
	Public Sub InvertSelection
		Dim i
		If Not CheckBoxes Then Exit Sub
		For i=0 To ListView.Rows.count -1
			With ListView.Rows.GetRow(i)
				.Checked = NOT .Checked
			End With
		Next
	End Sub


	'==============================================================================
	'@@XListClass.ChangeSelectedRowState
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE ChangeSelectedRowState>
	':Назначение: Для режима выбора с использованием флагов изменяет состояние выбранной строки
	':Сигнатура: Public Sub ChangeSelectedRowState
	Public Sub ChangeSelectedRowState
		Dim nRow	' индекс выбранной строки
		
		If Not CheckBoxes Then Exit Sub
		nRow = ListView.Rows.Selected
		If nRow>=0 Then
			ListView.Rows.GetRow(nRow).Checked = Not ListView.Rows.GetRow(nRow).Checked 
		End If
	End Sub
	
	
	'==============================================================================
	'@@XListClass.OnWidthChange
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE OnWidthChange>
	':Назначение: Обработчик события изменения размера списка.
	':Сигнатура: Public Sub OnWidthChange(nColIndex [as Integer], nWidth [as Integer])
	':Параметры: 
	'   nColIndex - 
	'       [in] внутрений идентификатор колонки (порядковый номер во внутреннем представлении)
	'   nWidth - 
	'       [in] ширина столбца в пикселях
	Public Sub OnWidthChange(nColIndex, nWidth)
		If m_oEventEngine.IsHandlerExists("ListColumnWidthChange") Then
			With New ListColumnWidthChangeEventArgsClass
				Set .SenderObject = ListView
				.ColumnIndex = nColIndex
				.ColumnWidth = nWidth		
				FireEvent "ListColumnWidthChange", .Self()
			End With 
		End If
	End Sub


	'==============================================================================
	'@@XListClass.OnKeyUp
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE OnKeyUp>
	':Назначение: Обработчик события отжатия клавиши в списке, вызывается контейнером XListPage.
	':Сигнатура: Public Sub OnKeyUp(oAccelerationEventArgs [as AccelerationEventArgsClass])
	':Параметры:	
	'   oAccelerationEventArgs - 
	'       [in] код клавишы
	Public Sub OnKeyUp(oAccelerationEventArgs)
		Dim nPosLeft, nPosTop, nPosRight, nPosBottom	' относительные координаты выбранной строки списка
		Dim nListPosX, nListPosY	' экранные координаты списка (ListView)
		Dim nRow					' индекс выбранной строки
		
		If AccelProcessing Then Exit Sub
		
		With oAccelerationEventArgs
			If .KeyCode = VK_UP Or .KeyCode = VK_DOWN Or .KeyCode = VK_PAGEUP Or .KeyCode = VK_PAGEDOWN Then Exit Sub
			
			AccelProcessing = True
			If .KeyCode = VK_APPS Then
				' получим координаты строки списка
				nRow = ListView.Rows.SelectedPosition
				If nRow > -1 Then
					ListView.GetRowCoords nRow, nPosLeft, nPosTop, nPosRight, nPosBottom
					X_GetHtmlElementScreenPos ListView, nListPosX, nListPosY
					Internal_showContextMenu nListPosX, nListPosY + nPosBottom
				End If
			Else		
				FireEvent "Accel", oAccelerationEventArgs
			End If
		End With
		AccelProcessing = False
	End Sub


	'==============================================================================
	'@@XListClass.OnDblClick
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE OnDblClick>
	':Назначение: Обработчик двойного щелчка мыши в списке.
	':Сигнатура: Public Sub OnDblClick(
	'               ByVal nIndex [as Integer], 
	'               ByVal nColumn [as Integer], 
	'               ByVal sID [as String]
	'               )
	
	Public Sub OnDblClick(ByVal nIndex , ByVal nColumn, ByVal sID)
		If AccelProcessing Then Exit Sub
		AccelProcessing = True
		' дабл-клик приравняем к нажатию ентер
		With New AccelerationEventArgsClass
			.keyCode	= VK_ENTER
			.altKey		= False
			.ctrlKey	= False
			.shiftKey	= False
			.DblClick	= True
			FireEvent "Accel", .Self()
		End With
		AccelProcessing = False
	End Sub


	'==============================================================================
	'@@XListClass.OnUnLoad
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE OnUnLoad>
	':Назначение: Обработчик выгрузки списка.
	':Сигнатура: Public Sub OnUnLoad
	Public Sub OnUnLoad
		' Сохраним описание спика. Подавим ошибки, т.к. списка может не быть
		On Error Resume Next
		SaveColumnsInUserData
		If 0 <> Err.number Then
			Err.Clear 
		End If
	End Sub
	
	
	'==============================================================================
	'@@XListClass.UpdateRow
	'<GROUP !!MEMBERTYPE_Methods_XListClass><TITLE UpdateRow>
	':Назначение: Обновляет заданную строку данными в формате x-list-loader.
	':Сигнатура: Public Sub UpdateRow(oRow [as IXListRow], oXmlRowData [as IXMLDOMElement])
	':Параметры:
	'	oRow - 
	'       [in] строка списка
	'	oXmlRowData - 
	'       [in] xml-узел LIST с данными строки в формате загрузчика списка
	Public Sub UpdateRow(oRow, oXmlRowData)
		Dim i
		Dim oXmlFields
		Dim oXmlField
		Dim sVarType
		
		oRow.IconURL = ListView.XImageList.MakeIconUrl(GetRowObjectTypeName(oRow), "", oXmlRowData.getAttribute("s"))
		Set oXmlFields = oXmlRowData.selectNodes("F")
		For i=0 To ListView.Columns.Count-1
			Set oXmlField = oXmlFields.item(i)
			sVarType = ListView.Columns.GetColumn(i).Type
			If Len("" & sVarType) > 0 Then
				' для колонки задан тип, надо получим типизированное значение
				On Error Resume Next
				oXmlField.dataType = sVarType
				If Err Then Alert "Не удалось привести значение ячейки '" & oXmlField.text & "' к типу " & sVarType
				On Error GoTo 0
				oRow.GetField(i).Value = oXmlField.nodeTypedValue
			Else
				oRow.GetField(i).Value = oXmlField.text
			End If
		Next
	End Sub
End Class


'===============================================================================
'@@ListColumnWidthChangeEventArgsClass
'<GROUP !!CLASSES_x-list><TITLE ListColumnWidthChangeEventArgsClass>
':Назначение:	Параметры события обработчика изменения ширины списка.
'
'@@!!MEMBERTYPE_Methods_ListColumnWidthChangeEventArgsClass
'<GROUP ListColumnWidthChangeEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_ListColumnWidthChangeEventArgsClass
'<GROUP ListColumnWidthChangeEventArgsClass><TITLE Свойства>
Class ListColumnWidthChangeEventArgsClass
	'@@ListColumnWidthChangeEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_ListColumnWidthChangeEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@ListColumnWidthChangeEventArgsClass.SenderObject
	'<GROUP !!MEMBERTYPE_Properties_ListColumnWidthChangeEventArgsClass><TITLE SenderObject>
	':Назначение:	Список - источник события
	':Сигнатура:	Public SenderObject [As IXListView]
	Public SenderObject
	
	'@@ListColumnWidthChangeEventArgsClass.ColumnIndex
	'<GROUP !!MEMBERTYPE_Properties_ListColumnWidthChangeEventArgsClass><TITLE ColumnIndex>
	':Назначение:	Индекс колонки, чья ширина изменилась
	':Сигнатура:	Public ColumnIndex [As Integer]
	Public ColumnIndex
	
	'@@ListColumnWidthChangeEventArgsClass.ColumnWidth
	'<GROUP !!MEMBERTYPE_Properties_ListColumnWidthChangeEventArgsClass><TITLE ColumnWidth>
	':Назначение:	Ширина колонки
	':Сигнатура:	Public ColumnWidth [As Integer]
	Public ColumnWidth
	
	'@@ListColumnWidthChangeEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_ListColumnWidthChangeEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As ListColumnWidthChangeEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@AfterListReloadEventArgsClass
'<GROUP !!CLASSES_x-list><TITLE AfterListReloadEventArgsClass>
':Назначение:	Параметры события "OnAfterListReload".
'
'@@!!MEMBERTYPE_Methods_AfterListReloadEventArgsClass
'<GROUP AfterListReloadEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_AfterListReloadEventArgsClass
'<GROUP AfterListReloadEventArgsClass><TITLE Свойства>
Class AfterListReloadEventArgsClass

	'@@AfterListReloadEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_AfterListReloadEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel

	'@@AfterListReloadEventArgsClass.HasMoreRows
	'<GROUP !!MEMBERTYPE_Properties_AfterListReloadEventArgsClass><TITLE HasMoreRows>
	':Назначение:	
	'	Признак достижения ограничения на максимальное количество строк в списке.
	'	Т.е. запрос вернул бы больше строк, если бы не ограничение MaxRows.
	':См. также:	AfterListReloadEventArgsClass.MaxRows
	':Сигнатура:	Public HasMoreRows [As Boolean]
	Public HasMoreRows

	'@@AfterListReloadEventArgsClass.MaxRows
	'<GROUP !!MEMBERTYPE_Properties_AfterListReloadEventArgsClass><TITLE MaxRows>
	':Назначение:	Максимальное количество строк в списке.
	':См. также:	AfterListReloadEventArgsClass.HasMoreRows
	':Сигнатура:	Public MaxRows [As Int]
	Public MaxRows

	'@@AfterListReloadEventArgsClass.Restrictions
	'<GROUP !!MEMBERTYPE_Properties_AfterListReloadEventArgsClass><TITLE Restrictions>
	':Назначение:	Ограничения, с которыми выполнялся запрос на получение данных.
	':Сигнатура:	Public Restrictions [As String]
	Public Restrictions
	
	'@@AfterListReloadEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_AfterListReloadEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As AfterListReloadEventArgsClass]
	Public Function Self()
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@SetDefaultFocusEventArgsClass
'<GROUP !!CLASSES_x-list><TITLE SetDefaultFocusEventArgsClass>
':Назначение:	Параметры события "SetDefaultFocus".
'
'@@!!MEMBERTYPE_Methods_SetDefaultFocusEventArgsClass
'<GROUP SetDefaultFocusEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_SetDefaultFocusEventArgsClass
'<GROUP SetDefaultFocusEventArgsClass><TITLE Свойства>
Class SetDefaultFocusEventArgsClass
	'@@SetDefaultFocusEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_SetDefaultFocusEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@SetDefaultFocusEventArgsClass.FilterObject
	'<GROUP !!MEMBERTYPE_Properties_SetDefaultFocusEventArgsClass><TITLE FilterObject>
	':Назначение:	Cсылка на объект фильтра.
	':Сигнатура:	Public FilterObject [As XFilterObjectClass]
	Public FilterObject
	
	'@@SetDefaultFocusEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SetDefaultFocusEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As SetDefaultFocusEventArgsClass]
	Public Function Self()
		Set Self = Me
	End Function
End Class


'==============================================================================
' Стандартный обработчик события OnEdit
'	[in] oEventArg AS CommonEventArgsClass - параметры события
Sub stdXList_OnEdit(oXList, oEventArg)
	oEventArg.ObjectID = X_OpenObjectEditor(oEventArg.ObjectType, oEventArg.ObjectID, oEventArg.Metaname, oEventArg.Values.Item("URLPARAMS"))
	oEventArg.ReturnValue = Not IsEmpty(oEventArg.ObjectID)
End Sub


'==============================================================================
' Стандартный обработчик события OnAfterEdit
'	[in] oEventArg AS CommonEventArgsClass - параметры события
Sub stdXList_OnAfterEdit(oXList, oEventArg)
	' ReturnValue говорит об успехе
	' ObjectID - идентификатор объекта
	With oEventArg
		If .ReturnValue Then
			oXList.ReloadEx True
			' установим курсор на отредактированную строку
			oXList.SelectRowByObjectID .ObjectID
		End If
	End With
	oXList.SetListFocus
End Sub


'==============================================================================
' Стандартный обработчик события OnCreate
'	[in] oEventArg AS CommonEventArgsClass - параметры события
Sub stdXList_OnCreate( oXList, oEventArg )
	oEventArg.ReturnValue = X_OpenObjectEditor(oEventArg.ObjectType, oEventArg.ObjectID, oEventArg.Metaname, oEventArg.Values.Item("URLPARAMS"))
End Sub


'==============================================================================
' Стандартный обработчик события OnAfterCreate
'	[in] oEventArg AS CommonEventArgsClass - параметры события
Sub stdXList_OnAfterCreate( oXList, oEventArg )
	If Not IsEmpty(oEventArg.ReturnValue) Then
		oXList.Reload()
		' установим курсов на отредактированную строку
		oXList.SelectRowByObjectID oEventArg.ReturnValue
	End If
	oXList.SetListFocus()
End Sub


'==============================================================================
' Стандартный обработчик события OnBeforeDelete
'	[in] oEventArg AS DeleteObjectEventArgsClass - параметры события.
Sub stdXList_OnBeforeDelete( oXList, oEventArg )
	' запомним идентификатор выбранной строки
	oEventArg.AddEventArgs = oXList.GetSelectedRowID()
End Sub


'==============================================================================
' Стандартный обработчик события OnDelete (удаления указанного объекта)
'	[in] oEventArg AS DeleteObjectEventArgsClass - параметры события
' Возвращаемое значение:
'	false - отказ от удаления (нажатие Cancel) 
'	true - объект удален
Sub stdXList_OnDelete( oXList, oEventArg )
	Dim nButtonFlag		' флаги для MsgBox
	Dim nDeleteCount	' количество удаленных объектов
	
	oXList.ListView.Enabled = False
	oEventArg.ReturnValue = False
	nButtonFlag = iif(StrComp(oEventArg.Values.Item("DefaultButton"), "Yes")=0, vbDefaultButton1, vbDefaultButton2)
	If vbYes = MsgBox(oEventArg.Values.Item("Prompt"), vbYesNo + vbInformation + nButtonFlag, "Удаление объекта") Then
		' Удаляю объект
		nDeleteCount = X_DeleteObject( oEventArg.ObjectType, oEventArg.ObjectID )
		If X_HandleError Then
			' была ошибка
			oXList.ListView.object.Enabled = True
			oXList.SetListFocus()
			Exit Sub
		End If
		oEventArg.Count = nDeleteCount
		oEventArg.ReturnValue = True
		oXList.ListView.XClientService.DoEvents
		oXList.ListView.Enabled = True
	Else
		oXList.ListView.Enabled = True
		oXList.SetListFocus()
	End If
End Sub


'==============================================================================
' Стандартный обработчик события OnAfterDelete
'	[in] oEventArg AS DeleteObjectEventArgsClass - параметры события
Sub stdXList_OnAfterDelete( oXList, oEventArg )
	Dim sRowID		' Идентификатор строки удаляемого объекта
	Dim bRet		' Возврат из функции удаления
	Dim oRow		' Объект IXListRow, соответствующий удаляемой строки
	Dim nRowIndex	' Индекс удаляемой строки
	Dim nRowPos		' Позиция удаляемой строки
	Dim oRows		' As IXListRows
	Dim nCount		' Количество строк, после удаления
	
	With oEventArg
		' если удаляли и удалили объекты, то удалим строки из списка
		If .ReturnValue And .Count > 0 Then
			' если объект был удален..
			sRowID = .AddEventArgs
			Set oRows = oXList.ListView.Rows
			' удалим из списка все строки, соответствующие объекту с идентификатором sGUID
			Do
				Set oRow = oRows.FindRowByID(sRowID)
				If oRow Is Nothing Then Exit Do
				nRowIndex = oRow.Index
				nRowPos = oRows.Idx2Pos(nRowIndex)
				oRows.Remove nRowIndex
				nCount = oRows.Count
				If nRowPos = nCount And nCount > 0 Then
					' удалили последнюю строку - встанем на предыдущую, если она есть
					oRows.SelectedPosition = nRowPos - 1
				ElseIf nRowPos > 0 Then
					' если последняя удаленная запись была в списке не первой, то поставим фокус на запись перед ней
					oRows.SelectedPosition  = nRowPos
				ElseIf nCount > 0 Then
					' иначе, если была первой и список не пуст, то поставим фокус на первую запись
					oRows.SelectedPosition = 0
				End If
			Loop While True
		End If
	End With
	oXList.SetListFocus()
End Sub


'==============================================================================
' Обрабатывает нажатия и клики в окне. Вызывает хоткеи меню...
Sub stdXList_OnAccel(oXList, oAccelerationArgs)
	' отдадим нажатую комбинацию в меню списка - может для нее там определены hotkey'и
	If oXList.Menu.Initialized Then
		oXList.Menu.ExecuteHotkey oXList, oAccelerationArgs
	End If
End Sub
