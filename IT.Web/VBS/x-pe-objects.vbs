'*******************************************************************************
' Подсистема:	
' Назначение:	Стандартный функционал обслуживания UI-представления массивного
'				объектного свойства (для значений vt: array, collection)
'*******************************************************************************
Option Explicit

Const PE_MENU_STYLE_BUTTON_WITH_POPUP = "op-button"
Const PE_MENU_STYLE_VERTICAL_BUTTONS = "vertical-buttons"
Const PE_MENU_STYLE_HORIZONAL_BUTTONS = "horizontal-buttons"

'==============================================================================
' Класс редактора массивных свойств в виде ListView с операциями.
' События:
' Команда DoSelectFromDb порождает цепочку событий:
'	BeforeSelect	- перед выбором объекта (SelectEventArgsClass)
'	Select			- выбор объекта (SelectEventArgsClass). Есть стандартный обработчик
'	GetRestrictions	- получение ограничений для выбора (GetRestrictionsEventArgsClass). Выбрасывается из стандартного обработчика события Select
'	ValidateSelection	- проверка выбора - если ReturnValue будет False, то занесение данных в xml не выполняется 
'						и AfterSelect не выбрасывается (SelectEventArgsClass)
'	BindSelectedData	- занесение выбранного объекта в xml и поля формы (SelectEventArgsClass). Есть стандартный обработчик
'	AfterSelect 	- постдействия после выбора объекта (SelectEventArgsClass)
'	SelectConflict	- генерируется стандартным обработчиком события BindSelectedData, если при загрузке выбранного объекта возникло исключение XObjectNotFound
' Команда DoSelectFromXml:
'	BeforeSelectXml	- перед выбором объекта (SelectEventArgsClass)
'	SelectXml		- выбор объекта (SelectEventArgsClass). Есть стандартный обработчик
'	ValidateSelection	- проверка выбора - если ReturnValue будет False, то занесение данных в xml не выполняется 
'						и AfterSelect не выбрасывается (SelectEventArgsClass)
'	BindSelectedData	- занесение выбранного объекта в xml и поля формы (SelectEventArgsClass). Есть стандартный обработчик
'	AfterSelectXml 	- постдействия после выбора объекта (SelectEventArgsClass)
'	SelectConflict	- генерируется стандартным обработчиком события BindSelectedData, если при загрузке выбранного объекта возникло исключение XObjectNotFound
'Команда DoCreate порождает события:
'	BeforeCreate,Create,AfterCreate - см.XPropertyEditorObjectBaseClass
'Команда DoEdit порождает события:
'	BeforeEdit,Edit,AfterEdit - см.XPropertyEditorObjectBaseClass
'Команда DoMarkDelete порождает события:
'	BeforeMarkDelete,MarkDelete,AfterMarkDelete - см.XPropertyEditorObjectBaseClass
'Команда DoUnLink порождает события:
'	BeforeUnlink,Unlink,AfterUnlink - см.XPropertyEditorObjectBaseClass
'Accel - нажатие комбинации клавиш в списке (есть стандартный обработчик)
'SelChanged - изменение выделенной строки в списке (в том числе при удалении самой строки)
'SelLost - удаление выделения строки в списке (в том числе при удалении самой строки)

Class XPEObjectsElementsListClass
	Public m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_sOrderBy					' As String		- выражение order-by для сортировки объектов в свойстве
	Private m_bOrderByAsc				' As Boolean	- True - сортировать по возрастанию, False - По убыванию
	Private EVENTS						' As String		- список событий страницы
	Private m_sViewStateCacheFileName	' As String - наименование файла с закешированным представлением
	Private m_bKeyUpEventProcessing		' As Boolean - Признак обработки ActiveX-события OnKeyUp для предотвращения бесконечного цикла
	Private m_sMenuStyle				' Режим отображения меню операций
	Private m_bMenuAsButtons			' As Boolean - признак того, что меню отображается в виде кнопок (часто требует обработки отличной от случая "меню по кнопке Операции")
	Private m_oMenuHolder				' HTC-компонент x-menu-html-pe.htc
	
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = _
			"BeforeSelect,GetRestrictions,Select,ValidateSelection,BindSelectedData,AfterSelect," & _
			"BeforeSelectXml,SelectXml,AfterSelectXml," & _
			"BeforeCreate,Create,AfterCreate," & _
			"BeforeEdit,Edit,AfterEdit," & _
			"BeforeMarkDelete,MarkDelete,AfterMarkDelete," & _
			"BeforeUnlink,Unlink,AfterUnlink," & _
			"Accel,SelectConflict,SelChanged,SelLost"
	End Sub
	

	'==========================================================================
	' Возвращает экземпляр ObjectEditorClass - редактора,
	' в рамках которого работает данный редактор свойства
	Public Property Get ObjectEditor
		Set ObjectEditor = m_oPropertyEditorBase.ObjectEditor
	End Property

	
	'==========================================================================
	' Возвращает экземпляр EditorPageClass - страницы редактора,
	' на которой размещается данный редактор свойства
	Public Property Get ParentPage
		Set ParentPage = m_oPropertyEditorBase.EditorPage
	End Property


	'==========================================================================
	' Возвращает метаданные свойства
	'	[retval] As IXMLDOMElement - узел ds:prop
	Public Property Get PropertyMD
		Set PropertyMD = m_oPropertyEditorBase.PropertyMD
	End Property


	'==========================================================================
	' Возвращает экземпляр EventEngineClass - объекта, поддерживающего
	' событийную модель для данного редактора свойства
	Public Property Get EventEngine
		Set EventEngine = m_oPropertyEditorBase.EventEngine
	End Property


	'==========================================================================
	' IPropertyEdior: инициализация
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim oMenuMD				' As IXMLDOMElement - метаданные меню (i:menu)
		Dim oXmlOrderBy			' As IXMLDOMElement - xml-узел i:order-by
		
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectsElementsList"
		' подпишем стандартные обработчики своих событий
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Select", Me, "OnSelect"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "BindSelectedData", Me, "OnBindSelectedData"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "AfterSelect", Me, "OnAfterSelect"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Create", Me, "OnCreate"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "AfterCreate", Me, "OnAfterCreate"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Edit", Me, "OnEdit"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "AfterEdit", Me, "OnAfterEdit"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "MarkDelete", Me, "OnMarkDelete"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Unlink", Me, "OnUnlink"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Accel", Me, "OnAccel"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "SelectXml", Me, "OnSelectXml"
		
		' Инициализируем меню: получим его метаданные, добавим стандартные обработчики 
		Set oMenuMD = m_oPropertyEditorBase.PropertyEditorMD.selectSingleNode("i:prop-menu")
		If Not oMenuMD Is Nothing Then
			m_sMenuStyle = oMenuMD.getAttribute("menu-style")
			If not hasValue(m_sMenuStyle) Then m_sMenuStyle = PE_MENU_STYLE_BUTTON_WITH_POPUP
			m_bMenuAsButtons = (m_sMenuStyle = PE_MENU_STYLE_HORIZONAL_BUTTONS Or m_sMenuStyle = PE_MENU_STYLE_VERTICAL_BUTTONS)
		End If
		
		Set m_oMenuHolder = ExtraHtmlElement("Menu")
		m_oMenuHolder.Init Me, X_CreateDelegate(Me, "Internal_MenuMacrosResolver"), X_CreateDelegate(Me, "Internal_MenuVisibilityHandler"), X_CreateDelegate(Me, "Internal_MenuExecutionHandler")

		With m_oPropertyEditorBase
			If Not .PropertyMD.getAttribute("cp") = "array" And IsNull(.PropertyMD.getAttribute("order-by")) Then
				Set oXmlOrderBy = .PropertyEditorMD.selectSingleNode("i:order-by")
				If Not oXmlOrderBy Is Nothing Then
					m_sOrderBy = oXmlOrderBy.text
					m_bOrderByAsc = X_GetAttributeDef(oXmlOrderBy, "desc", "0") <> "1"
				End If
			End If
		End With
		m_sViewStateCacheFileName = ObjectEditor.Signature() & "XArrayProp." + oXmlProperty.parentNode.tagName & "." & oXmlProperty.tagName & "." & m_oPropertyEditorBase.PropertyEditorMD.getAttribute("n")
		InitXListViewInterface HtmlElement, m_oPropertyEditorBase.PropertyEditorMD, m_sViewStateCacheFileName, True
		' Отсортируем объекты в свойстве
		SortProperty ObjectEditor, XmlProperty, m_sOrderBy, m_bOrderByAsc
	End Sub

	
	'==========================================================================
	' IPropertyEdior: Метод вызывается при построении страницы редактора, после инициализации всех PE на странице
	Public Sub FillData()
		' Установим доступность меню
		m_oMenuHolder.UpdateMenuState True
	End Sub

	Private m_nTimeoutHandle ' - таймер
	Private m_nPrevRow ' - индекс ранее выделенной строки (или -1, если выделение снимается).

	'==========================================================================
	' Обработчик ActiveX-события OnSelChange списка
	' 	[in] sSelf - строка с идентификатором данного экземпляра объекта
	'	[in] nPrevRow	- индекс ранее выделенной строки (или -1, если выделение снимается).
	'	[in] nNewRow	- индекс вновь выделенной строки (или -1, если выделение снимается).
	Public Sub Internal_DispatchOnSelChange(sSelf, nPrevRow, nNewRow)
		const DELAY_VALUE = 100 ' задержка в милисекундах
		If IsEmpty(m_nTimeoutHandle) Then	
			m_nPrevRow = nPrevRow
		Else
			clearTimeout m_nTimeoutHandle
		End If
		m_nTimeoutHandle = setTimeout("Dim o: Set o=" & sSelf & ": If Not o Is Nothing Then : o.Internal_OnSelChange " & nNewRow & ": End If", DELAY_VALUE, "VBScript")
	End Sub

	'==========================================================================
	' Обработчик ActiveX-события OnSelChange списка
	'	[in] nNewRow	- индекс вновь выделенной строки (или -1, если выделение снимается).
	Public Sub Internal_OnSelChange(nNewRow)
		clearTimeout m_nTimeoutHandle
		m_nTimeoutHandle = Empty
		' Обновим состояние меню
		m_oMenuHolder.UpdateMenuState True
		' сгенерируем событие прикладному коду
		fireEventAboutSelChanging m_nPrevRow, nNewRow
	End Sub

	'==========================================================================
	' Генератор событий SelChanged и SelLost
	'	[in] nPrevRow	- индекс ранее выделенной строки (или -1, если выделения не было).
	'	[in] nNewRow	- индекс вновь выделенной строки (или -1, если выделение снимается).
	Private Sub fireEventAboutSelChanging(nPrevRow, nNewRow)
		If nNewRow > -1 Then
			If m_oPropertyEditorBase.EventEngine.IsHandlerExists("SelChanged") Then
				With New ListViewSelChangeEventArgsClass
					.UnselectedRowIndex = nPrevRow
					.SelectedRowIndex = nNewRow
					FireEvent "SelChanged", .Self()
				End With
			End If
		Else
			If m_oPropertyEditorBase.EventEngine.IsHandlerExists("SelLost") Then
				With New ListViewSelChangeEventArgsClass
					.UnselectedRowIndex = nPrevRow
					.SelectedRowIndex = -1
					FireEvent "SelLost", .Self()
				End With
			End If
		End If
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property
	
	
	'==========================================================================
	' IPropertyEdior: Устанавливает значение в комбобоксе
	Public Sub SetData
		SetDataEx XmlProperty
	End Sub
	
	'==========================================================================
	' Устанавливает значения. Используется для оптимизации, т.к. не получает XmlProperty стандартным механизмом
	'	[in] oXmlProperty As IXMLDOMElement - закешированная ссылка на текущее xml-свойство
	Private Sub SetDataEx(oXmlProperty)
		' Заполним список массивного объектного свойства:
		FillXListViewEx HtmlElement, m_oPropertyEditorBase, oXmlProperty, m_oPropertyEditorBase.PropertyEditorMD, HideIf
	End Sub
	
	'==========================================================================
	' Возвращает признак HideIf
	Public Property Get HideIf
		HideIf = HtmlElement.GetAttribute("HIDE_IF")
		If Not HasValue(HideIf) Then HideIf = Null
	End Property
	
	'==========================================================================
	' IPropertyEdior: сбор данных
	Public Sub GetData(oGetDataArgs)
		' сохраним колонки
		X_SaveViewStateCache m_sViewStateCacheFileName, HtmlElement.Columns.Xml
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: установка (не)обязательности
	Public Property Get Mandatory
		Mandatory = False
	End Property
	Public Property Let Mandatory(bMandatory)
	End Property
	
	
	'==========================================================================
	' IPropertyEdior: установка (не)доступности
	Public Property Get Enabled
		Enabled = HtmlElement.object.Enabled 
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.object.Enabled = bEnabled

		m_oMenuHolder.SetEnableState bEnabled
		
		' Управление достудностью кнопок Вверх/Вниз
		If Not IsNull(HtmlElement.GetAttribute("X_SHIFT_OPERATIONS")) Then
			ExtraHtmlElement("ButtonUp").disabled = Not( bEnabled )
			ExtraHtmlElement("ButtonDown").disabled = Not( bEnabled )
		End If
	End Property
	
	
	'==========================================================================
	' IPropertyEdior: Установка фокуса (асинхронно)
	Public Sub SetFocus
		window.setTimeout ObjectEditor.UniqueID & ".CurrentPage.GetPropertyEditorByFullHtmlID(""" & HtmlElement.id & """).Internal_SetFocus", 1, "VBScript"		
	End Sub
	
	'==========================================================================
	' Установка фокуса
	Public Sub Internal_SetFocus
		' Бубен! Без window.focus фокус иногда не устанавливается
		window.focus
		X_SafeFocus( HtmlElement )
	End Sub
	
	'==========================================================================
	' IPropertyEdior: Возвращает IHTMLElement списка
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property
	
	
	'==========================================================================
	' Возвращает дополнительный контрол IHTMLElement
	Public Function ExtraHtmlElement(sName)
		Set ExtraHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.id & sName)
	End Function


	'==========================================================================
	' Возвращает/устанавливает описание свойства
	Public Property Get PropertyDescription
		PropertyDescription = m_oPropertyEditorBase.PropertyDescription
	End Property	
	Public Property Let PropertyDescription(sValue)
		m_oPropertyEditorBase.PropertyDescription = sValue
	End Property


	'==========================================================================
	' IDisposable
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
		Set m_oPropertyEditorBase = Nothing
	End Sub	


	'==========================================================================
	' Генерирует событие
	'	[in] sEventName - наименование события
	'	[in] oEventArgs - параметры события
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	
	
	
	'==========================================================================
	' Возвращает xml-объекты-значения xml-свойства
	'	[retval] IXMLDOMNodeList объектов в пуле, на которые установлена ссылка в свойстве, либо Nothing, если св-во пустое
	Public Property Get Value
		Dim oXmlProperty		' As IXMLDOMElement
		
		Set oXmlProperty = XmlProperty
		If oXmlProperty.FirstChild Is Nothing Then
			Set Value = Nothing
		Else	
			' Загружен объект-значение
			Set Value = m_oPropertyEditorBase.ObjectEditor.Pool.GetXmlObjectsByXmlNodeList( oXmlProperty.ChildNodes, Null )
		End If
	End Property
	
	
	'==========================================================================
	' Возвращает идентификаторы объектов-значений xml-свойства
	Public Property Get ValueID
		Dim sRetVal		' As String - возвращаемое значение
		Dim oNode		' As IXMLDOMElement - xml-заглушка объекта значения свойства
		For Each oNode In XmlProperty.ChildNodes
			If Not IsEmpty(sRetVal) Then
				sRetVal = sRetVal & ";"
			End If
			sRetVal = sRetVal & oNode.getAttribute("oid")
		Next
		ValueID = sRetVal
	End Property


	'==========================================================================
	' IPropertyEditorObject: Возвращает наименование типа объекта значения свойства
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyEditorBase.ValueObjectTypeName
	End Property

	
	'==========================================================================
	' IPropertyEditorObject: возвращает тип селектора для выбора: list или tree
	Public Property Get SelectorType
		SelectorType = m_oPropertyEditorBase.SelectorType
	End Property
	Public Property Let SelectorType(sValue)
		m_oPropertyEditorBase.SelectorType = sValue
	End Property

	
	'==========================================================================
	' IPropertyEditorObject: метаимя селектора
	Public Property Get SelectorMetaname
		SelectorMetaname = m_oPropertyEditorBase.SelectorMetaname
	End Property
	Public Property Let SelectorMetaname(sValue)
		m_oPropertyEditorBase.SelectorMetaname = sValue
	End Property


	'==========================================================================
	' Возвращает признак того, что PE поддерживает сортировку объектов в свойстве на основании VBS-выражения
	Public Property Get IsOrdered
		IsOrdered = Len("" & m_sOrderBy) > 0
	End Property

	
	'==========================================================================
	' Возвращает/устанавливает VBS-выражение, используемое для сортировки объектов в свойстве
	Public Property Get OrderByExpression	' As String
		OrderByExpression = m_sOrderBy
	End Property
	Public Property Let OrderByExpression(sExpr)
		m_sOrderBy = sExpr
	End Property

	
	'==========================================================================
	' Возвращает/устанавливает режим сортировки: True - сортировать по возрастанию, False - По убыванию
	' Если PE не сортируемое, то значение не определено
	Public Property Get OrderByAsc		' As Boolean
		OrderByAsc = m_bOrderByAsc
	End Property
	Public Property Let OrderByAsc(bValue)
		m_bOrderByAsc = bValue
	End Property

	
	'==========================================================================
	' Устанавливает сортировку объектов в свойстве и сразу выполяет сортировку объектов
	' Визуальное представление PE не обновляется
	'	[in] sOrderByExpression - VBS-выражение, используемое для сортировки объектов в свойстве
	'	[in] bAsc - True - сортировать по возрастанию, False - По убыванию
	Public Sub SetPropertySorting(sOrderByExpression, bAsc)
		m_sOrderBy = sOrderByExpression
		m_bOrderByAsc = CBool(bAsc = True)
		' Отсортируем объекты в свойстве
		SortProperty ObjectEditor, XmlProperty, m_sOrderBy, m_bOrderByAsc
	End Sub

	
	'==========================================================================
	' "Выключает" сортировку объектов в свойстве. Положение объектов в свойстве не изменяется
	Public Sub DisablePropertySorting
		m_bOrderByAsc = vbNullString
	End Sub

	
	'==========================================================================
	' ОБСЛУЖИВАНИЕ
	
	'==========================================================================
	' Обработчик отжатия клавиши в списке
	Sub Internal_OnKeyUpAsync(ByVal nKeyCode, ByVal nFlags)
		Dim oEventArgs		' As AccelerationEventArgsClass
		Dim nPosLeft, nPosTop, nPosRight, nPosBottom	' относительные координаты выбранной строки списка
		Dim nListPosX, nListPosY	' экранные координаты списка (ListView)
		Dim nRow					' индекс выбранной строки
		
		If m_bKeyUpEventProcessing Then Exit Sub
		m_bKeyUpEventProcessing = True
		
		' получим координаты строки списка
		nRow = m_oPropertyEditorBase.HtmlElement.Rows.SelectedPosition
		If nRow > -1 Then
			m_oPropertyEditorBase.HtmlElement.GetRowCoords nRow, nPosLeft, nPosTop, nPosRight, nPosBottom
		Else
			m_oPropertyEditorBase.HtmlElement.GetRowCoords 0, nPosLeft, nPosTop, nPosRight, nPosBottom
		End If
		X_GetHtmlElementScreenPos m_oPropertyEditorBase.HtmlElement, nListPosX, nListPosY
		If nRow < 0 Then nListPosY = nListPosY + 16
		nListPosY = nListPosY + nPosBottom
		
		If nKeyCode = VK_APPS Then
			m_oMenuHolder.ShowPopupMenuWithPos nListPosX, nListPosY
		Else
			Set oEventArgs = CreateAccelerationEventArgsForActiveXEvent(nKeyCode, nFlags)
			Set oEventArgs.Source = Me
			Set oEventArgs.HtmlSource = HtmlElement
			oEventArgs.MenuPosX = nListPosX
			oEventArgs.MenuPosY = nListPosY
			FireEvent "Accel", oEventArgs
			If Not oEventArgs.Processed Then
				' передадим нажатую комбинацию в редактор
				ObjectEditor.OnKeyUp Me, oEventArgs
			End If
		End If
		m_bKeyUpEventProcessing = False
	End Sub


	'==========================================================================
	' Обработчик двойного клика в списке
	Sub Internal_OnDblClickAsync(ByVal nIndex , ByVal nColumn, ByVal sID)
		' дабл-клик приравняем к нажатию ентер
		With New AccelerationEventArgsClass
			.keyCode	= VK_ENTER
			.altKey		= False
			.ctrlKey	= False
			.shiftKey	= False
			.DblClick	= True
			FireEvent "Accel", .Self()
		End With
	End Sub

		
	'==========================================================================
	' Стандартный обработчик события "Accel"
	'	[in] oEventArgs As AccelerationEventArgsClass
	Public Sub OnAccel(oSender, oEventArgs)
		' отдадим нажатую комбинацию в меню списка - может для нее там определены hotkey'и
		m_oMenuHolder.ExecuteHotkey oEventArgs
	End Sub


	'==========================================================================
	' Обработчик клика правой кнопкой мыши 
	Public Sub Internal_OnContextMenuAsync()
		m_oMenuHolder.ShowPopupMenu 
	End Sub


	'==========================================================================
	' Стандартный резолвер максров меню
	'	[in] oEventArgs As MenuEventArgsClass
	Sub Internal_MenuMacrosResolver(oSender, oEventArgs)
		oEventArgs.Menu.Macros.Item("ObjectID") = HtmlElement.Rows.SelectedID
		oEventArgs.Menu.Macros.Item("ObjectType") = ValueObjectTypeName
	End Sub

	
	'==========================================================================
	' Стандартный обработчик видимости/доступности
	'	[in] oEventArgs As MenuEventArgsClass
	Sub Internal_MenuVisibilityHandler(oSender, oEventArgs)
		Dim bDisabled		' признак заблокированности пункта
		Dim bHidden			' признак сокрытия пункта
		Dim oNode			' текущий menu-item
		Dim sType			' тип объекта в свойстве
		Dim sObjectID		' идентификатор выбранного объекта
		Dim oObjectValue	' As IXMLDOMElement - xml-объект значение
		Dim oList			' As ObjectArrayListClass - массив объектов XObjectPermission
		Dim bIsLoaded		' As Boolean - признак того,что объект-значение загружен из БД
		Dim bProcess		' As Boolean - признак обработки текущего пункта
		
		sType = m_oPropertyEditorBase.PropertyMD.getAttribute("ot")
		sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
		If 0=Len("" & sObjectID) Then
			sObjectID = Empty
		End If 
		If Not IsEmpty(sObjectID) Then
			Set oObjectValue = ObjectEditor.Pool.GetXmlObject(sType, sObjectID, Null)
			If Not oObjectValue Is Nothing Then
				bIsLoaded = IsNull(oObjectValue.getAttribute("new"))
			End If
		End If	
		
		Set oList = New ObjectArrayListClass
		' Обработаем только известные нам операции
		For Each oNode In oEventArgs.ActiveMenuItems
			' установим атрибуты на пункте меню, чтобы oMenu.SetMenuItemsAccessRights смог увязать запросы на проверку прав и пункты меню (при проставлении флага disabled)
			oNode.setAttribute "type", sType
			If Not IsNull(sObjectID) Then _
				oNode.setAttribute "oid",  sObjectID
				
			bHidden = Empty
			bDisabled = Empty
			bProcess = False
			Select Case oNode.getAttribute("action")
				Case "DoSelectFromDb", "DoSelectFromXml"
					bHidden = HasValue(HtmlElement.getAttribute("OFF_SELECT"))
					bProcess = True
				Case "DoCreate"
					bHidden = HasValue(HtmlElement.getAttribute("OFF_CREATE"))
					If Not bHidden Then
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CREATE, sType, Empty)
					End If
					bProcess = True
				Case "DoEdit"
					If m_bMenuAsButtons Then
						bHidden = HasValue(HtmlElement.getAttribute("OFF_EDIT"))
						bDisabled = IsEmpty(sObjectID)
					Else
						bHidden = IsEmpty(sObjectID) Or HasValue(HtmlElement.getAttribute("OFF_EDIT"))
					End If
					If (Not bHidden Or Not bDisabled) And bIsLoaded Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CHANGE, sType, sObjectID)
					bProcess = True
				Case "DoMarkDelete"
					If m_bMenuAsButtons Then
						bHidden = HasValue(HtmlElement.getAttribute("OFF_DELETE"))
						bDisabled = IsEmpty(sObjectID)
					Else
						bHidden = IsEmpty(sObjectID) Or HasValue(HtmlElement.getAttribute("OFF_DELETE"))
					End If
					If (Not bHidden Or Not bDisabled) And bIsLoaded Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_DELETE, sType, sObjectID)
					bProcess = True
				Case "DoUnlink"
					' если линк и обратное скалярное массивное свойство (по которому объекты попадают в список)
					' ненулабельное, то операция "разорвать связь" должна быть задизейблена всегда
					If m_oPropertyEditorBase.PropertyMD.getAttribute("cp") = "link" Then
						If IsNull(ObjectEditor.Pool.GetReversePropertyMD(XmlProperty).getAttribute("maybenull")) Then
							bHidden = True
						End If
					End If
					If Not bHidden Then
						If m_bMenuAsButtons Then
							bDisabled = IsEmpty(sObjectID)
							bHidden = HasValue(HtmlElement.getAttribute("OFF_UNLINK"))
						Else
							bHidden = IsEmpty(sObjectID) Or HasValue(HtmlElement.getAttribute("OFF_UNLINK"))
						End If
					End If
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
			oEventArgs.Menu.SetMenuItemsAccessRights oList.GetArray()
		End If
	End Sub

	
	'==========================================================================
	' Стандартный обработчик выбора пункта меню
	'	[in] oMenuExecuteEventArgs As MenuExecuteEventArgsClass
	Sub Internal_MenuExecutionHandler(oSender, oEventArgs)
		oEventArgs.Cancel = True
		Select Case oEventArgs.Action
			Case "DoSelectFromDb"
				' Выбор из БД
				m_oPropertyEditorBase.DoSelectFromDb oEventArgs.Menu.Macros
			Case "DoSelectFromXml"
				' Выбор из Xml
				m_oPropertyEditorBase.DoSelectFromXml oEventArgs.Menu.Macros
			Case "DoCreate"
				' Создать в текущей транзакции
				m_oPropertyEditorBase.DoCreate oEventArgs.Menu.Macros, False
			Case "DoEditAndSave"
				' Редактировать и сохранить в БД
				m_oPropertyEditorBase.DoEdit oEventArgs.Menu.Macros, True
			Case "DoEdit"
				' Редактировать в текущей транзации
				m_oPropertyEditorBase.DoEdit oEventArgs.Menu.Macros, False
			Case "DoMarkDelete"
				' Пометить объект как удаленный и удалить ссылку на него из свойства
				m_oPropertyEditorBase.DoMarkDelete oEventArgs.Menu.Macros
			Case "DoUnlink"
				' Удалить ссылку на объект из свойства
				m_oPropertyEditorBase.DoUnlink oEventArgs.Menu.Macros
			Case Else
				oEventArgs.Cancel = False
		End Select
		SetFocus
	End Sub

	
	'==========================================================================
	' Стандартный обработчик события "Select"
	'	[in] oEventArgs As SelectEventArgsClass
	Public Sub OnSelect(oSender, oEventArgs)
		Dim sType					' As String		- Тип объекта-значения
		Dim sParams					' As String		- Параметры для data-source (Param1=Value1&Param2=Value2)
		Dim sUrlArguments			' As String		- Параметры селектора
		Dim sExcludeNodes			' As String		- Список исключаемых узлов для выбора из дерева
		Dim vRet					' As String		- Результат отбора
		Dim oXmlProperty			' As XMLDOMElement	- xml-свойтсво
		Dim vTemp
		Dim i
		
		Set oXmlProperty = XmlProperty
		' Получаем тип объекта-значения
		sType = oEventArgs.ObjectValueType
		' получим пользовательские ограничения для селектора через событие GetRestrictions
		With New GetRestrictionsEventArgsClass
			.ReturnValue = oEventArgs.OperationValues.item("DataSourceParams")
			FireEvent "GetRestrictions", .Self()
			sParams = .ReturnValue
			' параметры в селектор из параметров пункта меню
			sUrlArguments = oEventArgs.UrlArguments
			' и добавим параметры в селектор от обработчиков события "GetRestrictions"
			If Len(.UrlParams) Then
				If Left(.UrlParams, 1) <> "&" And Len(sUrlArguments) Then sUrlArguments = sUrlArguments & "&"
				sUrlArguments = sUrlArguments & .UrlParams
			End If
			sExcludeNodes = .ExcludeNodes
		End With

		' Выбираем объект
		If SelectorType="list" Then
			' Выбор производится из списка
			vRet = X_SelectFromList(SelectorMetaname, sType, LM_MULTIPLE, sParams, sUrlArguments)
		Else
			' Покажем диалог и получим выбранное значение
			With New SelectFromTreeDialogClass
				.Metaname = SelectorMetaname
				.LoaderParams = sParams
				If Len("" & sUrlArguments) > 0 Then
					.UrlArguments.QueryString = sUrlArguments
				End If
				.SelectableTypes = sType
				If oEventArgs.OperationValues.Exists("SelectionMode") Then
					vTemp = oEventArgs.OperationValues.item("SelectionMode")
					If UCase(Mid(CStr(vTemp), 1, 4)) = "TSM_" Then 
						On Error Resume Next
						vTemp = Eval(vTemp)
						If Err Then 
							Alert "Для операции DoSelectFromDb редактора свойства '" & oXmlProperty.tagNane & "' задано некорректное значение параметра SelectionMode (режим иерархии): " & vTemp
							' но ради этого не стоит обваливать работу приложения
							Err.Clear
						End If
						On Error GoTo 0
					End If
					.SelectionMode = vTemp
				End If
				.SuitableSelectionModes = Array(TSM_ANYNODES, TSM_LEAFNODES)
				
				' Если объект ссылается сам на себя, то не дадим ему выбрать себя в стандартном дереве
				If Not hasValue(sExcludeNodes) And sType = oXmlProperty.parentNode.tagName Then
					sExcludeNodes = sType & "|" & oXmlProperty.parentNode.GetAttribute("oid")
				End If
				.ExcludeNodes = sExcludeNodes 
				
				' откроем диалог и получим объекты через тот же экземпляр SelectFromTreeDialogClass
				SelectFromTreeDialogClass_Show .Self()
				
				vRet = Empty
				If .ReturnValue Then
					With .Selection.selectNodes("n[@ot='" & sType & "']")
						If .length = 0 Then
							vRet = Empty
						Else
							ReDim vRet(.length-1)
							For i=0 To .length-1
								vRet(i) =  .item(i).getAttribute("id")
							Next
						End If
					End With
				End If
			End With
		End If
		oEventArgs.Selection = vRet
	End Sub


	'==========================================================================
	' Стандартный обработчик события "SelectXml"
	' [in] oSender - экземпляр XPEObjectPresentationClass, источник события
	' [in] oEventArgs - экземпляр SelectXmlEventArgsClass, параметры события
	Public Sub OnSelectXml(oSender, oEventArgs)
		oEventArgs.ReturnValue = False
        If Not hasValue(oEventArgs.Objects) Then
            Alert "Нет доступных для выбора объектов"
            Exit Sub
        End If
        
		' Выбор производится из списка
		With oEventArgs
		    .Selection = X_SelectFromXmlList(ObjectEditor, .SelectorMetaname, .ObjectValueType, LM_MULTIPLE, .Objects, .UrlArguments)
		    .ReturnValue = hasValue(.Selection)
		End With
	End Sub

	
	'==========================================================================
	' Стандартный обработчик события "BindSelectedData"
	'	[in] oEventArgs As SelectEventArgsClass
	Public Sub OnBindSelectedData(oSender, oEventArgs)
		Dim oXmlProperty		' xml-свойство
		Dim vSelection			' массив идентификаторов
		Dim i
		Dim oNewItem			' выбранный объект
		Dim bObjectNotFound		' признак что выбранный объект не был получен
		
		Set oXmlProperty = XmlProperty
		vSelection = oEventArgs.Selection
		If IsEmpty(vSelection) Then Exit Sub
		If Not IsArray(vSelection) Then Exit Sub
		With m_oPropertyEditorBase.ObjectEditor.Pool
			bObjectNotFound = False
			For i=0 To UBound(vSelection)
				If Nothing Is oXmlProperty.selectSingleNode("*[@oid='" & vSelection(i) & "']") Then
					' Объекта не было в свойстве - добавим
					Set oNewItem = .GetXmlObject(ValueObjectTypeName, vSelection(i), Null)
					If X_WasErrorOccured Then
						' возникла ошибка при загрузке объекта в пул
						If X_GetLastError.IsObjectNotFoundException Then
							bObjectNotFound = True
						ElseIf X_GetLastError.IsSecurityException or X_GetLastError.IsBusinessLogicException Then
							' к выбранному объекту запрещен доступ - считаем это ошибкой
							MsgBox "К выбранному объекту '" & vSelection(i) & "' запрещен доступ." & vbCr & X_GetLastError.LastServerError.getAttribute("user-msg")
						End If
						vSelection(i) = " "
					Else
						If IsNothing(oNewItem) Then Exit Sub	' какая-то другая ошибка
						' выбранный объект успешно добавлен в пул - вставим в свойство
						AppendXmlObjectEx oXmlProperty, oNewItem
					End If
				Else
					' Объект был в свойстве - заменяем идентификатор на пробел
					vSelection(i) = " "
				End If
			Next
			If bObjectNotFound Then
				' если нет обработчика покажем сообщение
				If EventEngine.IsHandlerExists("SelectConflict") Then
					' TODO: возможно надо EventArgs со список идентификаторов удаленных объектов, сделаем как понадобится
					FireEvent "SelectConflict", Nothing
				Else
					MsgBox "Некоторые выбранные объекты не были добавлены в список, т.к. были удалены другим пользователем", vbOKOnly + vbInformation
				End If
			End If
		End With	
		' сформируем массив идентификаторов объектов, реально добавленных в свойство
		vSelection = Split(Replace(Replace(Join(vSelection, ","), ", ", ""), " ,", ""),",")
		oEventArgs.ReturnValue = vSelection
		If UBound(vSelection) = -1 Then Exit Sub ' Ничего не добавилось!
		' Обновим данные
		SetDataEx oXmlProperty
	End Sub


	'==========================================================================
	' Стандартный обработчик события "AfterSelect"
	'	[in] oEventArgs As SelectEventArgsClass
	Public Sub OnAfterSelect(oSender, oEventArgs)
		If UBound(oEventArgs.ReturnValue) = -1 Then Exit Sub ' Ничего не добавилось!
		SelectRowForObject oEventArgs.ReturnValue(0)
	End Sub
	
	
	'==========================================================================
	' Добавляет объект в свойство. 
	'	[in] oNewItem - вставляемый объект.
	Public Sub AppendXmlObject(oNewItem)
		AppendXmlObjectEx XmlProperty, oNewItem
	End Sub


	'==========================================================================
	' Добавляет объект в свойство. 
	'	[in] oXmlProperty - свойство (для оптимизации)
	'	[in] oNewItem - вставляемый объект.
	Public Sub AppendXmlObjectEx(oXmlProperty, oNewItem)
		If IsOrdered Then
			' задано выражение для сортировки объектов в свойстве
			InsertXmlObject oXmlProperty, oNewItem
		Else
			' не задано выражение для сортировки - добавим объект в конец свойства
			m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, oNewItem
		End If
	End Sub

	
	'==========================================================================
	' Вставляет объект в свойство с учетом сортировки, заданной элементом i:order-by списка
	'	[in] oXmlProperty - свойтсво
	'	[in] oNewItem - вставляемый объект.
	Private Sub InsertXmlObject(oXmlProperty, oNewItem)
		Dim sNewItemOrderBy		' вычисленное выражение для сортировки выбранного объекта
		Dim sItemOrderBy		' вычисленное выражение для сортировки
		Dim oItem				' объект в свойстве
		Dim bFound				' признак найденного объекта, перед которым добавляем новый
		
		If IsOrdered = False Then Err.Raise -1, "InsertXmlObject", "Метод должен вызываться только для сортируемых свойств"
		' объект загружен в пул, вычислив выражение для сортировки
		sNewItemOrderBy = ObjectEditor.ExecuteStatement( oNewItem, m_sOrderBy)
		For Each oItem In oXmlProperty.SelectNodes("*")
			' по всем объектам в свойстве, найдем объект перед которым надо добавить выбранных объект
			sItemOrderBy = ObjectEditor.ExecuteStatement( oItem, m_sOrderBy)
			bFound = False
			If m_bOrderByAsc Then
				' сортируем по возрастанию
				If sNewItemOrderBy < sItemOrderBy Then bFound = True
			Else
				' сортируем по убыванию
				If sNewItemOrderBy > sItemOrderBy Then bFound = True
			End If
			If bFound Then
				' Нашли узел, перед которым надо вставить
				m_oPropertyEditorBase.ObjectEditor.Pool.AddRelationWithOrder Nothing, oXmlProperty, oNewItem, oItem
				Exit For
			End If
		Next
		If Not bFound Then
			' если не нашли узел (если нашли, то bFound сохранит свое значение True) -
			' добавим в конец
			m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, oNewItem
		End If
	End Sub


	'==========================================================================
	' Устанавливает порядок объекта в свойстве с учетом заданной сортировки (i:order-by)
	' Работает только для списков, для которых задан элемент order-by.
	'	[in] oNewObjectInProp - объект или заглушка объекта в свойстве, для которого надо установить 
	' порядок в свойстве с учетом order-by
	Public Sub OrderObjectInProp( ByVal oNewObjectInProp )
		Dim oXmlProperty	' xml-свойство
		
		If IsOrdered = False Then Err.Raise -1, "", "Метод должен вызываться только для сортируемых свойств"
		Set oXmlProperty = XmlProperty
		' если переданные объект не добавлен в свойство - добавим
		If Not oNewObjectInProp.parentNode Is oXmlProperty Then
			Set oNewObjectInProp = oXmlProperty.appendChild( X_CreateStubFromXmlObject(oNewObjectInProp) )
		End If
		OrderObjectInPropEx oXmlProperty, oNewObjectInProp
	End Sub
	
	
	'==========================================================================
	' Устанавливает порядок объекта в свойстве с учетом заданной сортировки (i:order-by)
	' Работает только для списков, для которых задан элемент order-by.
	'	[in] oXmlProperty - xml-свойство (для оптимизации)
	'	[in] oNewObjectInProp - заглушка объекта в свойстве, для которого надо установить правильное положение
	Private Sub OrderObjectInPropEx( oXmlProperty, oNewObjectInProp )
		Dim sNewItemOrderBy		' вычисленное выражение для сортировки выбранного объекта
		Dim sItemOrderBy		' вычисленное выражение для сортировки
		Dim oItem				' объект в свойстве
		Dim bFound				' признак найденного объекта, перед которым добавляем новый
		
		' если в свойстве меньше 2-х объектов, то сортировать нечего
		If oXmlProperty.childNodes.length < 2 Then Exit Sub
		' объект загружен в пул, вычислим выражение для сортировки
		sNewItemOrderBy = ObjectEditor.ExecuteStatement( oNewObjectInProp, m_sOrderBy )
		For Each oItem In oXmlProperty.SelectNodes("*")
			' по всем объектам в свойстве, найдем объект перед которым надо добавить выбранных объект
			sItemOrderBy = ObjectEditor.ExecuteStatement( oItem, m_sOrderBy)
			bFound = False
			If m_bOrderByAsc Then
				' сортируем по возрастанию
				If sNewItemOrderBy < sItemOrderBy Then bFound = True
			Else
				' сортируем по убыванию
				If sNewItemOrderBy > sItemOrderBy Then bFound = True
			End If
			If bFound Then
				' Нашли узел, перед которым надо вставить
				oXmlProperty.insertBefore oNewObjectInProp, oItem
				Exit Sub
			End If
		Next
		' не нашли в свойстве объект, перед которым надо вставить переданный объект, поэтому переместим его в конец/начало (если он уже не там)
		If m_bOrderByAsc Then
			If Not oXmlProperty.lastChild Is oNewObjectInProp Then
				oXmlProperty.insertBefore oNewObjectInProp, Null
			End If
		Else
			If Not oXmlProperty.firstChild Is oNewObjectInProp Then
				oXmlProperty.insertBefore oNewObjectInProp, oXmlProperty.firstChild
			End If
		End If
	End Sub


	'==========================================================================
	' Стандартный обработчик события "Create"
	'	[in] oEventArgs As OpenEditorEventArgsClass
	Public Sub OnCreate(oSender, oEventArgs)
		Dim oXmlProperty		' xml-свойство
		Dim oNewObject			' Новый объект-значение
		Dim oNewObjectInProp	' заглушка объекта-значения в свойстве
		
		With oEventArgs
			' начнем агрегированную транзакцию
			m_oPropertyEditorBase.ObjectEditor.Pool.BeginTransaction True
			' ВАЖНО: ссылка oXmlProperty полечена после вызова BeginTransaction, поэтому ей можно пользоваться и после CommitTransaction
			Set oXmlProperty = XmlProperty
			' создаим новый объект и поместим его в пул
			Set oNewObject = m_oPropertyEditorBase.ObjectEditor.Pool.CreateXmlObjectInPool(ValueObjectTypeName)
			' добавим этот новый объект-значение в свойство
			Set oNewObjectInProp = m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation( Nothing, oXmlProperty, oNewObject )
			' откроем вложенный редактор с признаком EnlistInCurrentTransaction=True, т.о. этот редактор не будет создавать новой транзакции 
			.ReturnValue  = m_oPropertyEditorBase.ObjectEditor.OpenEditor(oNewObject, Null, Null, .Metaname, True, oXmlProperty,Not .IsSeparateTransaction, True, .UrlArguments)
			If IsEmpty( .ReturnValue  ) Then
				' нажали отмену - откатим транзакцию
				m_oPropertyEditorBase.ObjectEditor.Pool.RollbackTransaction
			Else
				' нажали Ок - закомитим
				If IsOrdered Then
					' если свойство сортируемое - вставим расположим в свойстве с учетом сортировки
					' т.к. не известно сколько транзакций могло начинаться во вложенном редакторе, 
					' необходимо переполучить ссылку на заглушку в свойстве
					Set oXmlProperty = XmlProperty
					Set oNewObjectInProp = oXmlProperty.selectSingleNode(oNewObjectInProp.tagName & "[@oid='" & oNewObjectInProp.getAttribute("oid") & "']")
					OrderObjectInPropEx oXmlProperty, oNewObjectInProp
				End If
				m_oPropertyEditorBase.ObjectEditor.Pool.CommitTransaction
				' обновим представление PE
				SetData
			End If		
		End With
	End Sub

	
	'==========================================================================
	' Стандартный обработчик события "AfterCreate"
	'	[in] oEventArgs As OpenEditorEventArgsClass
	Public Sub OnAfterCreate(oSender, oEventArgs)
		If hasValue(oEventArgs.ReturnValue) Then
			SelectRowForObject oEventArgs.ReturnValue
		End If
	End Sub
	
	
	'==============================================================================
	' Стандартный обработчик события Edit
	'	[in] oEventArgs As OpenEditorEventArgsClass
	Public Sub OnEdit(oSender, oEventArgs)
		Dim oXmlProperty		' xml-свойство

		With oEventArgs
			' И редактируем его...
			.ReturnValue = m_oPropertyEditorBase.ObjectEditor.OpenEditor(Null, ValueObjectTypeName, .ObjectID, .Metaname, False, XmlProperty, Not .IsSeparateTransaction, False, .UrlArguments)
			If IsEmpty( .ReturnValue ) Then Exit Sub
			Set oXmlProperty = XmlProperty
			If IsOrdered Then
				' если свойство сортируемое - расположим отредактированный объект с учетом сортировка
				OrderObjectInPropEx oXmlProperty, oXmlProperty.selectSingleNode(ValueObjectTypeName & "[@oid='" & .ObjectID & "']")
			End If
			' обновим представление PE
			SetDataEx oXmlProperty
		End With
	End Sub


	'==========================================================================
	' Стандартный обработчик события "AfterEdit"
	'	[in] oEventArgs As OpenEditorEventArgsClass
	Public Sub OnAfterEdit(oSender, oEventArgs)
		If hasValue(oEventArgs.ReturnValue) Then
			SelectRowForObject oEventArgs.ReturnValue
		End If
	End Sub


	'==============================================================================
	' Стандартный обработчик события MarkDelete
	'	[in] oEventArgs As OperationEventArgsClass
	Public Sub OnMarkDelete(oSender, oEventArgs)
		Dim oXmlProperty	' xml-свойство
		Dim nButtonFlag		' флаги MsgBox
		
		With oEventArgs
			.ReturnValue = False
			' если задан текст запроса пользователю, то сначала спросим
			If hasValue(.Prompt) Then
				' задизеблим, чтобы подавить порождение нежелательного события OnKeyUp от нажатия Enter в диаголе
				HtmlElement.object.Enabled = False
				nButtonFlag = iif(StrComp(.OperationValues.Item("DefaultButton"), "No")=0, vbDefaultButton2, vbDefaultButton1)
				If vbNo = MsgBox(.Prompt, vbYesNo + vbInformation + nButtonFlag) Then
					HtmlElement.object.Enabled = True
					SetFocus
					Exit Sub
				End If
				HtmlElement.object.Enabled = True
			End If
			
			' ПРИМЕЧАНИЕ: MarkObjectAsDeleted не использует транзации пула, поэтому можно безболезненно сохранять ссылку на XmlProperty
			Set oXmlProperty = XmlProperty
			.ReturnValue = m_oPropertyEditorBase.ObjectEditor.MarkObjectAsDeleted( ValueObjectTypeName, .ObjectID, oXmlProperty)
			If .ReturnValue Then
				updateListAfterObjectRemoving .ObjectID
			End If
		End With
	End Sub
	
	
	'==============================================================================
	' Стандартный обработчик события UnLink
	'	[in] oEventArgs As OperationEventArgsClass
	Public Sub OnUnlink(oSender, oEventArgs)
		Dim oXmlProperty	' xml-свойство
		Dim nButtonFlag		' флаги MsgBox
		Dim oXmlValueObject		' As IXMLDOMElement - объект-значение
		
		' если задан текст запроса пользователю, то сначала спросим
		With oEventArgs
			If hasValue(.Prompt) Then
				' задизеблим, чтобы подавить порождение нежелательного события OnKeyUp от нажатия Enter в диаголе
				HtmlElement.object.Enabled = False
				nButtonFlag = iif(StrComp(.OperationValues.Item("DefaultButton"), "No")=0, vbDefaultButton2, vbDefaultButton1)
				If vbNo = MsgBox(.Prompt, vbYesNo + vbInformation + nButtonFlag) Then
					HtmlElement.object.Enabled = True
					SetFocus
					Exit Sub
				End If
				HtmlElement.object.Enabled = True
			End If
		End With
		
		' ПРИМЕЧАНИЕ: RemoveRelation не использует транзации пула, поэтому можно безболезненно сохранять ссылку на XmlProperty
		Set oXmlProperty = XmlProperty
		' Получим объект значение
		Set oXmlValueObject = oXmlProperty.selectSingleNode("*[@oid='" & oEventArgs.ObjectID &"']")
		
		If m_oPropertyEditorBase.DoUnlinkImplementation( oXmlProperty, oXmlValueObject ) Then
			updateListAfterObjectRemoving oEventArgs.ObjectID
		End If
	End Sub


	'==========================================================================
	' Обновление списка после удаление объекта из него
	'	[in] sObjectID - идентификатор удаленного объекта (он же идентификатор удаленной строки)
	Private Sub updateListAfterObjectRemoving(sObjectID)	
		Dim oRow		' Объект CROC.IXListRow, соответствующий удаляемой строки
		Dim oRows		' CROC.IXListRows
		Dim nRowIndex	' Индекс удаляемой строки
		Dim nRowPos		' Позиция удаляемой строки
		Dim nCount		' Количество строк, после удаления

		Set oRows = m_oPropertyEditorBase.HtmlElement.Rows
		Set oRow = oRows.FindRowByID(sObjectID)
		
		If oRow Is Nothing Then 
			SetData
		Else
			nRowIndex = oRow.Index
			nRowPos = oRows.Idx2Pos(nRowIndex)
			' заблокируем генерацию событий, чтобы не сгенерировалось событие onSelChange при удалении строки.
			' Это не надо, т.к. потом мы вручную установим выбранную строку. 
			' Больше того, если это не сделать, то будет stack overflow, если меню "раскатано" в кнопки
			m_oPropertyEditorBase.HtmlElement.LockEvents = True
			oRows.Remove nRowIndex
			m_oPropertyEditorBase.HtmlElement.LockEvents = False
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
			Else
				' Была удалена последняя строка - надо обновить меню 
				' (т.к. SelectedPosition, то OnSelChange не вызовется, поэтому сделаем все явно)
				m_oMenuHolder.UpdateMenuState True
				' сгенерируем событие прикладному коду (SelLost)
				fireEventAboutSelChanging nRowIndex, -1
			End If
		End If
		SetFocus
	End Sub
	
	
	'==========================================================================
	' Перемещение (изменение позиции) объекта в списке (массиве)
	'	[in] bShiftDirection - направдение смещения: True - вверх, False - вниз
	Sub DoItemShift(bShiftDirection)
		Dim oProp				' xml-свойство
		Dim nSelected			' индекс выбранной строки
		Dim nRow1, nRow2		' Индексы переставляемых элементов
		Dim sID1,sID2			' Идентификаторы переставляемых элементов
		Dim oItem1, oItem2		' Переставляемые элементы (XMLDOMElement)
		Dim nOrder				' Поле для сортировки
		
		Set oProp = XmlProperty
		With HtmlElement.Rows
			' установим сортировку по колонке с индексом
			HtmlElement.Columns.GetColumn(0).Order = CORDER_ASC
			nSelected = .Selected
			If nSelected < 0 Then Exit Sub
			' Проверка в зависимости от направления сдвига и 
			' получение индексов элементов
			If bShiftDirection Then
				nRow1 =	 nSelected
				nRow2 =	 .idx2pos(nRow1) - 1
				If nRow2 < 0 Then Exit Sub
				nRow2 = .pos2idx( nRow2) 
			Else
				nRow2 = nSelected
				nRow1 =	.idx2pos(nRow2) + 1
				If nRow1 >= .Count Then Exit Sub
				nRow1 = .pos2idx( nRow1) 
			End If
			
			' получение идентификаторов
			sID1 = .GetRow(nRow1).ID
			sID2 = .GetRow(nRow2).ID
			
			' Получаем переставляемые объекты
			Set oItem1 = oProp.selectSingleNode("*[@oid='" & sID1 & "']")
			Set oItem2 = oProp.selectSingleNode("*[@oid='" & sID2 & "']")
		
			' Переставляем элементы в XML-свойстве
			oProp.insertBefore oItem1, oItem2 
		
			' Переставляем строки списка визуально посредством модификации скрытого поля
			nOrder = .GetRow(nRow1).GetField(0).value
			.GetRow(nRow1).GetField(0).value = .GetRow(nRow2).GetField(0 ).value
			.GetRow(nRow2).GetField(0).value = nOrder
			' пометим св-во как измененное, т.к. изменился порядок
			m_oPropertyEditorBase.ObjectEditor.SetXmlPropertyDirty oProp
		End With	
	End Sub
	
	
	'==========================================================================
	' Выбирает строку в списке, соответствующую объекту с заданным идентификатором
	' ВНИМАНИЕ: выбор строки приводит к обновлению меню
	'	[in] sObjectID - идентификатор выбираемого объекта
	Public Sub SelectRowForObject(sObjectID)
		Dim oRow		' Объект CROC.IXListRow, соответствующий удаляемой строки
		Dim oRows		' CROC.IXListRows
		
		Set oRows = m_oPropertyEditorBase.HtmlElement.Rows
		Set oRow = oRows.FindRowByID( sObjectID )
		If Not oRow Is Nothing Then
			oRows.Selected = oRow.Index
		End If
	End Sub
End Class


'==============================================================================
' Инициализирует представление XListView-списка на основании метаданных
'	[in] oListView As XListView 	- контрол списка (CROC.XListView)
'	[in] oInterfaceMD As XMLDOMELement - метаданные списка (узел i:elements-list или i:objects-list)
'	[in] sCacheKey As String 		- ключ к закешированному описанию колонок на клиентском компьютере
'	[in] bCreateColumns as Boolean 	- True - создавать колонки списка, иначе не создават
Function InitXListViewInterface( oListView, oInterfaceMD, sCacheKey, bCreateColumns )
	Dim oColumnsFromMetadata	' As XMLDOMNodeList - список колонок из метаданных
	Dim oColumnFromMetadata		' As XMLDOMElement - метаданные одной колонки - узел i:column
	Dim oXmlColumns				' As XMLDOMElement - узел CS xml'ля с определением колонок
	Dim vVal
	Dim i
	Dim oCachedColumns			' As XMLDOMElement - закешированное описание колонок (элемент CS)
	Dim oCachedColumn			' As XMLDOMElement - закешированное описание колонки (элемент C)
	Dim nWidth
	Dim bShowIcons				' As Boolean - признак показа иконок
	
	InitXListViewInterface = False
	' Получим метаданные
	If Nothing Is oInterfaceMD Then Exit Function
	' Получим список колонок из метаданных
	Set oColumnsFromMetadata = oInterfaceMD.selectNodes("i:column")
	' Если колонок не задано, выходим
	If 0 = oColumnsFromMetadata.length Then Exit Function
	' получим описания колонок из списка
	Set oCachedColumns = Nothing
	Set oCachedColumn = Nothing
	If HasValue(sCacheKey) Then
		X_GetViewStateCache sCacheKey, oCachedColumns
		If 0 <> StrComp( TypeName(oCachedColumns), "IXMLDOMElement", vbTextCompare) Then
			Set oCachedColumns = Nothing
		End If
	End If
	
	' Если нужно, отключаем вывод номеров строк
	oListView.LineNumbers = IsNull( oInterfaceMD.getAttribute("off-rownumbers"))
	
	' инициализация колонок
	If bCreateColumns Then
		' Создадим XML документ содержащий определения столбцов в формате CROC.XListView
		With XService.XmlGetDocument
			Set oXmlColumns = .createElement("CS")
			i = 0
			
			' Добавим служебный столбец
			With oXmlColumns.appendChild(.createElement("C"))
				.text = "X_ORDER_990D331EBEAD454EAC32DCF76E06167A"
				.setAttribute "name", "X_ORDER_990D331EBEAD454EAC32DCF76E06167A"
				.setAttribute "hidden", 1
				.setAttribute "vt", "i4"
			End With
			
			' Надобавляем колонок из метаданных
			For Each oColumnFromMetadata In oColumnsFromMetadata
				With oXmlColumns.appendChild(.createElement("C"))
					.text =	vbNullString & oColumnFromMetadata.getAttribute("t")
					
					vVal = oColumnFromMetadata.getAttribute("n")
					If IsNull(vVal) Then vVal = "NONAME__" & i
					.setAttribute "name", vVal
					If Not oCachedColumns Is Nothing Then
						Set oCachedColumn = oCachedColumns.selectSingleNode("C[@name='" & vVal & "']")
					End If
					nWidth = oColumnFromMetadata.getAttribute("width") 
					If Not oCachedColumn Is Nothing Then
						vVal = oCachedColumn.getAttribute("width")
						If Not IsNull(vVal) Then _
							nWidth = vVal
						vVal = oCachedColumn.getAttribute("order")
						If Not IsNull(vVal) Then _
							.setAttribute "order", vVal
					End If
					nWidth = SafeCLng(nWidth)
					If nWidth > 0 Then
						.setAttribute "width", nWidth
					Else
						.setAttribute "hidden", 1
					End If
					If Not oCachedColumn Is Nothing Then
						vVal = oCachedColumn.getAttribute("display-index")
						If Not IsNull(vVal) Then _
							.setAttribute "display-index", vVal
					End If					
						
					vVal = oColumnFromMetadata.getAttribute("align")  	
					If Not IsNull(vVal) Then .setAttribute "align", vVal
					
					vVal = oColumnFromMetadata.getAttribute("vt")  	
					' скорректируем тип свойства в XDR-тип xml
					If Not IsNull(vVal) Then 
						Select Case vVal
							Case "fixed":	vVal = "fixed.14.4"
							Case "time":	vVal = "time.tz"
							Case "dateTime":vVal = "dateTime.tz"
							Case "smallBin":vVal = "bin.base64"
						End Select
						.setAttribute "vt", vVal
					End If
					
					vVal = oColumnFromMetadata.getAttribute("order-by")  	
					If Not IsNull(vVal) Then .setAttribute "order-by", vVal
				End With
				i = i + 1
			Next
			With .appendChild(.createElement("LIST"))
				.appendChild oXmlColumns
				Set oXmlColumns = .ownerDocument
				.appendChild oXmlColumns.createElement("RS") 
			End With
		End With
		' Проинициализируем столбцы списка загрузкой из XML-я
		oListView.XmlFillList oXmlColumns, -1, True
		Set oXmlColumns = Nothing
	Else
	    ' Ветка для списков, загружаемых с сервера
	    If Not Nothing Is oCachedColumns Then
		    If Not Nothing Is oCachedColumns.selectSingleNode("C") Then
			    With XService.XmlGetDocument
				    .appendChild .createElement("LIST")
				    .documentElement.appendChild oCachedColumns
				    .documentElement.appendChild .createElement("RS")
			    End With
			    oListView.XMLFillList oCachedColumns.ownerDocument, -1, True
		    End If
		End If 
	End If
	
	' включаем показ иконок, если явно не отключено
	If IsNull( oInterfaceMD.getAttribute("off-icons") ) Then
		' иконки показываем либо если задан icon-selector, либо если для типа объектов-значения есть тег icons (т.е. всегда есть иконка по умолчанию)
		' получения наименования типа зависит от метаданных PE: elements-list вложен в свойство (ds:prop), у которого наименование типа в атрибуте ot;
		' objects-list вложен непосредственно в нужный тип
		bShowIcons = False
		If Not oInterfaceMD.selectSingleNode("i:icon-selector") Is Nothing Then
			bShowIcons = True
		Else
			If oInterfaceMD.baseName = "elements-list" Then
				If Not X_GetTypeMD(oInterfaceMD.parentNode.getAttribute("ot")).selectSingleNode("i:icons") Is Nothing Then
					bShowIcons = True
				End If
			ElseIf oInterfaceMD.baseName = "objects-list" Then
				If Not oInterfaceMD.parentNode.selectSingleNode("i:icons") Is Nothing Then
					bShowIcons = True
				End If
			End If
		End If
		If bShowIcons Then
			oListView.ShowIcons = True
			oListView.XImageList.IconTemplate = "x-get-icon.aspx?OT={T}&SL={S}&BIN=1"
		End If
	End If
	' При необходимости включим отображение сетки
	If IsNull(oInterfaceMD.getAttribute("off-gridlines")) Then oListView.gridLines = True
	
	InitXListViewInterface = True
End Function

'==============================================================================
' Заполняет список на основании метаописания и данных свойства
'	[in] oListView As IXListView
'	[in] oPropertyEditorBase As IPropertyEditor
'	[in] oXmlProperty As IXMLDOMElement - xml-свойство
'	[in] oInterfaceMD As IXMLDOMElement - узел в МД с описанием списка (i:element-list или i:list-selector)
Sub FillXListView(oListView, oPropertyEditorBase, oXmlProperty, oInterfaceMD)
	FillXListViewEx oListView, oPropertyEditorBase, oXmlProperty, oInterfaceMD,  X_GetChildValueDef( oInterfaceMD, "i:hide-if", Null)
End Sub


'==============================================================================
' Заполняет список на основании метаописания и данных свойства
'	[in] oListView As IXListView
'	[in] oPropertyEditorBase As IPropertyEditor
'	[in] oXmlProperty As IXMLDOMElement - xml-свойство
'	[in] oInterfaceMD As IXMLDOMElement - узел в МД с описанием списка (i:element-list или i:list-selector)
'	[in] vHideIf  As String - выражение hide-if для определения сокрытия строки
Sub FillXListViewEx(oListView, oPropertyEditorBase, oXmlProperty, oInterfaceMD, ByVal vHideIf)
	Dim bOrderedHard			' признак упорядоченного свойства (массив/упорядоченный линк)
	
	bOrderedHard = oPropertyEditorBase.PropertyMD.getAttribute("cp") = "array" Or Not IsNull(oPropertyEditorBase.PropertyMD.getAttribute("order-by"))
	FillXListViewEx2 oListView, oPropertyEditorBase, oXmlProperty, oInterfaceMD, vHideIf, bOrderedHard
End Sub


'==============================================================================
' Заполняет список на основании метаописания и данных свойства
' Примечание: создана ради сохранения совместимости
'	[in] oListView As IXListView
'	[in] oPropertyEditorBase As IPropertyEditor
'	[in] oXmlProperty As IXMLDOMElement - xml-свойство
'	[in] oInterfaceMD As IXMLDOMElement - узел в МД с описанием списка (i:element-list или i:list-selector)
'	[in] vHideIf  As String - выражение hide-if для определения сокрытия строки
'	[in] bOrderedHard - признак упорядоченного свойства (массив/упорядоченный линк)
Sub FillXListViewEx2(oListView, oPropertyEditorBase, oXmlProperty, oInterfaceMD, ByVal vHideIf, bOrderedHard)
	Dim oObjectEditor			' As oObjectEditor
	Dim oObjects                ' As IXMLDOMNodeList
	
    Set oObjectEditor = oPropertyEditorBase.ObjectEditor
    Set oObjects = oXmlProperty.selectNodes( "*[(@oid)]" )
    
    FillXListViewEx3 oListView, oObjectEditor, oObjects, oInterfaceMD, vHideIf, bOrderedHard
End Sub


'==============================================================================
' Заполняет список на основании метаописания и коллекции объектов
' Примечание: создана ради сохранения совместимости
'	[in] oListView As IXListView
'	[in] oObjectEditor As oObjectEditor
'	[in] oObjects As IXMLDOMNodeList - коллекция отображаемых объектов
'	[in] oInterfaceMD As IXMLDOMElement - узел в МД с описанием списка (i:element-list или i:list-selector)
'	[in] vHideIf  As String - выражение hide-if для определения сокрытия строки
'	[in] bOrderedHard - признак упорядоченного свойства (массив/упорядоченный линк)
Sub FillXListViewEx3(oListView, oObjectEditor, oObjects, oInterfaceMD, ByVal vHideIf, bOrderedHard)
	Dim oColumnsFromMetadata	' As IXMLDOMNodeList - список колонок из метаданных
	Dim oColumnFromMetadata		' As IXMLDOMElement - колонка из метаданных (i:column)
	Dim nUpper					' As Interger - индекс последней колонки
	Dim oItem
	Dim aStatements				' As Array - массив выражений для вычисления значений колонок
	Dim sVisibleObjectIDList	' As String - список идентификаторов через запятую, отображаемых в списке
	Dim oXRows					' As Croc.IXListViewRows - коллекция строк списка
	Dim vIconSelector			' As String - селектор иконки
	Dim oXImageList				' As Croc.XImageList
	Dim aRowData				' As Array - массив вариантов со значениями полей строки
	Dim oXRow
	Dim bVisible				' As Boolean - признак того, что строка отображается в списке
	Dim vVal
	Dim nObjectIndex			' As Integer - порядок объекта в свойстве
	Dim i, j
	Dim bOrderedSoft			' признак неупорядоченного свойства, но с дефолтовой сортировкой списка (с помощью элемента i:order-by)
	
	Set oXRows = oListView.Rows
	
	If Not HasValue(vHideIf) Then vHideIf = Null

	' Получим список колонок из метаданных
	Set oColumnsFromMetadata = oInterfaceMD.selectNodes("i:column")
	nUpper = oColumnsFromMetadata.Length - 1
	' Распределяем массив для кэширования выражений
	Redim aStatements( nUpper)
	' Кэшируем выражения
	i = 0
	For Each oColumnFromMetadata  In oColumnsFromMetadata
		aStatements(i) = oColumnFromMetadata.nodeTypedValue
		i = i + 1
	Next
	vIconSelector = X_GetChildValueDef( oInterfaceMD, "i:icon-selector", Null )

	' Анализ отображаемых объектов
	
	' Заполнение списка
	' Выделим место под данные строки	
	ReDim aRowData(nUpper+1) 

	bOrderedSoft = Not oInterfaceMD.selectSingleNode("i:order-by") Is Nothing
	' если св-во упорядоченное, то включим сортировку по скрытому полю
	If bOrderedHard Then
		oListView.Columns.GetColumn(0).Order = CORDER_ASC
	End If
	nObjectIndex = 0
	' Добавляем отсутствующие в списке строки, подлежащие отображению
	For Each oItem In oObjects
		If IsNull(vHideIf) Then
			bVisible = True 
		Else
			' если задано выражение hide-if, то вычислим его
			bVisible = (True <> oObjectEditor.ExecuteStatement( oItem,vHideIf)) 
		End If 
		If bVisible Then
			sVisibleObjectIDList = sVisibleObjectIDList & " " & oItem.GetAttribute("oid")
			aRowData(0) = nObjectIndex
			' Проходим по всем выражениям, вычисляем их, и формируем строку списка
			For i=0 To nUpper
				' Вычислим значение
				vVal = oObjectEditor.ExecuteStatement( oItem, aStatements(i) )
				' ...занесём в поле строки
				If IsEmpty(vVal) Then vVal = Null  
				aRowData(i+1) = vVal
			Next
			' Поищем в списке строку с идентификатором текущего объекта
			Set oXRow  = oXRows.FindRowByID(oItem.GetAttribute("oid"))
			If Nothing Is oXRow Then
				' Такой строки нет, надо добавить:
				' Добавляем строку в список
				If bOrderedSoft Then
					' Если список с order-by, то строку надо вставить под индексом совпадающим с индексом объекта в свойстве.
					' Это надо для того, чтобы при сбросе сортировки строки были в ожидаемом порядке (т.е. в порядке их следования в св-ве).
					' Для массива/упорядоченого линка такого не нужно, т.к. там всегда жесткая сортировка по 0-му столбцу, 
					' в который мы кладем индекс объекта в свойстве.
					Set oXRow = oXRows.Insert( nObjectIndex, aRowData, oItem.GetAttribute("oid") )
				Else
					Set oXRow = oXRows.Insert(-1, aRowData, oItem.GetAttribute("oid") )
				End If
			Else
				' Строка уже есть
				' Для упорядоченного свойства подправим поле индекса, по которому сортируются строки
				If bOrderedHard Then
					oXRow.GetField(0).value = nObjectIndex
				End If
				For j=1 To UBound(aRowData)
					oXRow.GetField(j).value = aRowData(j)
				Next
				If bOrderedSoft Then
					If oXRow.Index <> nObjectIndex Then
						' индекс строки не равен индексу объекта в свойстве
						oXRows.Remove oXRow.Index
						Set oXRow = oXRows.Insert( nObjectIndex, aRowData, oItem.GetAttribute("oid") )
					End If
				End If
			End If
			' Вычислим селектор иконки
			If Not IsNull(vIconSelector) Then
				vVal = ToString( oObjectEditor.ExecuteStatement( oItem, vIconSelector ) )
				oXRow.IconURL = oListView.XImageList.MakeIconUrl( oItem.nodeName, 0, vVal ) 
			ElseIf oListView.ShowIcons Then
				oXRow.IconURL = oListView.XImageList.MakeIconUrl( oItem.nodeName, "", "")
			End If
			nObjectIndex = nObjectIndex + 1
		End if
	Next
	' Подчистим строки не попавшие в список отображаемых
	If IsEmpty(sVisibleObjectIDList) Then
		oXRows.RemoveAll		 
	Else
		' по всем строкам в списке: 
		For i=oXRows.Count-1 To 0 Step -1
			' если идентификатора объекта строки нет в списке отображаемых объектов, то удалим строку
			If 0=InStr( sVisibleObjectIDList,  oXRows.GetRow(i).ID) Then
				oXRows.Remove i
			End If 
		Next
	End If
End Sub


'==========================================================================
' Сортирует обекты в свойстве на основании применяемого к ним vbs-выражения
'	[in] ObjectEditor - Редактор
'	[in] oXmlPropert As IXMLDOMElement - xml-свойство
'	[in] sOrderBy As String  - выражение (ObjectPath)
'	[in] bAsc As Boolean - если True сортируем по возростанию, иначе по убыванию.
Public Sub SortProperty( ObjectEditor, oXmlProperty, sOrderBy, bAsc )
	Dim oNodes				' коллекция объектов-значений в свойстве oXmlProperty
	Dim nCount				' количество объектов в коллекции oNodes
	Dim sCurItemOrderBy		' Вычисленное выражение order-by текущего объекта
	Dim sPrevItemOrderBy	' Вычисленное выражение order-by предыдущего объекта
	Dim bFound				' признак найденного объекта, перед которым добавляем текущий
	Dim i, j

	If Len("" & sOrderBy) = 0 Then Exit Sub
	Set oNodes = oXmlProperty.ChildNodes
	nCount = oNodes.length
	For i=1 To nCount-1
		sCurItemOrderBy = ObjectEditor.ExecuteStatement( oNodes.item(i), sOrderBy)
		For j=0 To i-1
			sPrevItemOrderBy = ObjectEditor.ExecuteStatement( oNodes.item(j), sOrderBy)
			bFound = False
			If bAsc Then
				' сортируем по возрастанию
				If sCurItemOrderBy < sPrevItemOrderBy Then bFound = True
			Else
				' сортируем по убыванию
				If sCurItemOrderBy > sPrevItemOrderBy Then bFound = True
			End If
			If bFound Then
				oXmlProperty.insertBefore oNodes.item(i), oNodes.item(j)
				Exit For
			End If
		Next
	Next
End Sub


'===============================================================================
'@@ListViewSelChangeEventArgsClass
'<GROUP !!CLASSES_x-pe-objects><TITLE ListViewSelChangeEventArgsClass>
':Назначение:	Класс параметров событий SelChanged, SelLost, поражденных ActiveX-событием XListView OnSelChange
'@@!!MEMBERTYPE_Methods_ListViewSelChangeEventArgsClass
'<GROUP ListViewSelChangeEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_ListViewSelChangeEventArgsClass
'<GROUP ListViewSelChangeEventArgsClass><TITLE Свойства>
Class ListViewSelChangeEventArgsClass

	'@@ListViewSelChangeEventArgsClass.UnselectedRowIndex
	'<GROUP !!MEMBERTYPE_Properties_ListViewSelChangeEventArgsClass><TITLE UnselectedRowIndex>
	':Назначение:	Индекс строки (от 0), которая была выделенной до изменения активной строки
	':Сигнатура:	Public UnselectedRowIndex [As Integer]
	Public UnselectedRowIndex
	
	'@@ListViewSelChangeEventArgsClass.SelectedRowIndex
	'<GROUP !!MEMBERTYPE_Properties_ListViewSelChangeEventArgsClass><TITLE SelectedRowIndex>
	':Назначение:	Индекс строки (от 0), которая стала выделенной
	':Сигнатура:	Public SelectedRowIndex [As Integer]
	Public SelectedRowIndex
	
	'@@EventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_EventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel				
	
	'@@EventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_EventArgsClass><TITLE ReturnValue>
	':Назначение:	Данные, возвращаемые обработчиком события.
	':Сигнатура:	Public ReturnValue [As Variant]
	Public ReturnValue
	
	'@@EventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_EventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As EventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class