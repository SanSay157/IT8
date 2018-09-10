Option Explicit

'==============================================================================
' Класс PE виртуального свойства для отображения связей между инцидентами
' События:
'	BeforeShowMenu - при нажатии кнопки "операции", либо вызове контекстного меню перед вызовом MenuClass
'Команда DoCreate порождает события:
'	BeforeCreate,Create,AfterCreate - см.XPropertyEditorObjectBaseClass
'Команда DoEdit порождает события:
'	BeforeEdit,Edit,AfterEdit - см.XPropertyEditorObjectBaseClass
'Команда DoMarkDelete порождает события:
'	BeforeMarkDelete,MarkDelete,AfterMarkDelete - см.XPropertyEditorObjectBaseClass
'Accel - нажатие комбинации клавиш в списке (есть стандартный обработчик)
Class PEIncidentLinksClass
	Private m_oMenu						' As MenuClass	- меню операций
	Private EVENTS						' As String		- список событий страницы
	Private m_sViewStateCacheFileName	' As String - наименование файла с закешированным представлением
	Private m_oPropertyEditorMD
	Private m_sOrderBy					' As String		- выражение order-by для сортировки объектов в свойстве
	Private m_bOrderByAsc				' As Boolean	- True - сортировать по возрастанию, False - По убыванию
	
	Public ParentPage			' As EditorPageClass	- ссылка на экземпляр страницы
	Public ObjectEditor			' As ObjectEditorClass	- ссылка на экземпляр редатора
	Public HtmlElement			' As IHtmlElement	- ссылка на главный Html-элемент
	Public EventEngine			' As EventEngineClass
	Public XmlPropertyXPath		' As String - XPath - Запрос для получения свойства в Pool'e
	Public ObjectType			' As String - Наименование типа объекта владельца свойства
	Public ObjectID				' As String - Идентификатор объекта владельца свойства
	Public PropertyName			' As String - Наименование свойства
	Public ValueObjectTypeName	' As String - Наименование типа объекта значения свойства
	Public SelectorMetaname		' As String	- метаимя селектора
	Public SelectorType			' As String	- тип селектора для выбора: list или tree
	Public PropertyDescription	' As String
	
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "BeforeShowMenu," & _
			"BeforeCreate,AfterCreate," & _
			"BeforeEdit,AfterEdit," & _
			"BeforeMarkDelete,AfterMarkDelete," & _
			"Accel"
	End Sub
	

	'==========================================================================
	' IPropertyEdior: инициализация
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim oMenuMD				' As IXMLDOMElement - метаданные меню (i:menu)
		Dim oDoc
		
		Set EventEngine 	= X_CreateEventEngine
		Set ParentPage  	= oEditorPage
		Set ObjectEditor	= oEditorPage.ObjectEditor
		ObjectType			= oXmlProperty.parentNode.tagName
		ObjectID			= oXmlProperty.parentNode.getAttribute("oid")
		PropertyName		= oXmlProperty.tagName
		XmlPropertyXPath	= ObjectType & "[@oid='" & ObjectID & "']/" & PropertyName
		ValueObjectTypeName = "IncidentLink"
		Set HtmlElement		= oHtmlElement
		PropertyDescription = oHtmlElement.GetAttribute("X_DESCR")
		' статический биндинг
		If Len("" & EVENTS) > 0 Then
			EventEngine.InitHandlers EVENTS, "usr_" & ObjectType & "_" & PropertyName & "_On"
		End If
		EventEngine.AddHandlerForEventWeakly "Create", Me, "OnCreate"
		EventEngine.AddHandlerForEventWeakly "Edit", Me, "OnEdit"
		EventEngine.AddHandlerForEventWeakly "MarkDelete", Me, "OnMarkDelete"
		EventEngine.AddHandlerForEventWeakly "Accel", Me, "OnAccel"
		
		' установим тип селектора и имя списка/дерева на основании параметров из xsl и метаданных
		SelectorType = "list"
		SelectorMetaname = Null
		If hasValue( HtmlElement.getAttribute("ListSelectorMetaname") ) Then
			SelectorType = "list"
			SelectorMetaname = HtmlElement.getAttribute("ListSelectorMetaname")
		ElseIf hasValue( HtmlElement.getAttribute("TreeSelectorMetaname") ) Then
			SelectorType = "tree"
			SelectorMetaname = HtmlElement.getAttribute("TreeSelectorMetaname")
		End If		
	
		Set m_oMenu = New MenuClass
		
		Set oDoc = XService.XMLGetDocument()
		'getIconSelectorForIncidentLink(item())
		oDoc.loadXml _
			"<i:elements-list xmlns:i=""http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"" off-rownumbers=""1"">" & _
			"	<i:icon-selector>iif(item.RoleA.ObjectID = """ & ObjectID & """, ""from"",""to"")</i:icon-selector>" & _
			"	<i:column width=""100"" t=""№"">IncidentLink_getNumber(pool(), item(),""" & ObjectID & """)</i:column>" & _
			"	<i:column width=""100"" t=""Состояние"">IncidentLink_getState(pool(), item(),""" & ObjectID & """)</i:column>" & _
			"	<i:column width=""600"" t=""Наименование"">IncidentLink_getName(pool(), item(),""" & ObjectID & """)</i:column>" & _
			"	<i:prop-menu>" & _
			"		<i:menu>" & _
			"			<i:menu-item action=""DoCreate"" hotkey=""VK_INS""  t=""Создать ссылку от текущего инцидента"">" & _
			"				<i:params><i:param n=""URLParams"">.RoleA=" & ObjectID & "</i:param>" & _
			"							<i:param n=""RealPropName"">LinksFromRoleA</i:param>" & _
			"				</i:params>" & _
			"			</i:menu-item>" & _
			"			<i:menu-item action=""DoCreate"" t=""Создать новый инцидент со ссылкой от текущего"">" & _
			"				<i:params><i:param n=""ObjectType"">Incident</i:param>" & _
			"							<i:param n=""RealPropName"">LinksFromRoleA</i:param>" & _
			"				</i:params>" & _
			"			</i:menu-item>" & _
			"			<i:menu-item action=""DoCreate"" t=""Создать ссылку на текущий инцидент"" separator-before=""1"">" & _
			"				<i:params><i:param n=""URLParams"">.RoleB=" & ObjectID & "</i:param>" & _
			"							<i:param n=""RealPropName"">LinksFromRoleB</i:param>" & _
			"				</i:params>" & _
			"			</i:menu-item>" & _
			"			<i:menu-item action=""DoCreate"" t=""Создать новый инцидент со ссылкой на текущий"">" & _
			"				<i:params><i:param n=""ObjectType"">Incident</i:param>" & _
			"							<i:param n=""RealPropName"">LinksFromRoleB</i:param>" & _
			"				</i:params>" & _
			"			</i:menu-item>" & _
			"			<i:menu-item action=""DoEdit"" t=""Редактировать ссылку"" separator-before=""1""/>" & _
			"			<i:menu-item action=""DoMarkDelete"" hotkey=""VK_DEL"" t=""Удалить ссылку"" separator-after=""1""/>" & _
			"			<i:menu-item action=""DoEdit"" hotkey=""VK_ENTER,VK_DBLCLICK""  t=""Редактировать инцидент"">" & _
			"				<i:params><i:param n=""ObjectType"">Incident</i:param></i:params>" & _
			"			</i:menu-item>" & _
			"			<i:menu-item action=""DoIncidentView"" t=""Просмотр инцидента"" />" & _
			"		</i:menu>" & _
			"	</i:prop-menu>" & _
			"</i:elements-list>"
		XService.XmlSetSelectionNamespaces oDoc
		Set m_oPropertyEditorMD = oDoc.documentElement
		
		Dim oXmlOrderBy
		Set oXmlOrderBy = m_oPropertyEditorMD.selectSingleNode("i:order-by")
		If Not oXmlOrderBy Is Nothing Then
			m_sOrderBy = oXmlOrderBy.text
			m_bOrderByAsc = X_GetAttributeDef(oXmlOrderBy, "desc", "0") <> "1"
		End If
		
		' Инициализируем меню: получим его метаданные, добавим стандартные обработчики 
		Set oMenuMD = m_oPropertyEditorMD.selectSingleNode( "i:prop-menu/i:menu")
		If Not oMenuMD Is Nothing Then
			m_oMenu.Init oMenuMD	
			m_oMenu.AddMacrosResolver X_CreateDelegate(Me, "Internal_MenuMacrosResolver") 
			' ВАЖНА последовательность: снача XPEObjectsElementsListClass_MenuVisibilityHandler, потом Internal_MenuVisibilityHandler
			' потому, что в Internal_MenuVisibilityHandler переопределяется видимость стандартного пункта DoEdit для ссылки на новый инцидент
			m_oMenu.AddVisibilityHandler X_CreateDelegate(Nothing, "XPEObjectsElementsListClass_MenuVisibilityHandler")
			m_oMenu.AddVisibilityHandler X_CreateDelegate(Me, "Internal_MenuVisibilityHandler")
			m_oMenu.AddExecutionHandler X_CreateDelegate(Me, "Internal_MenuExecutionHandler") 
		End If
		m_sViewStateCacheFileName = ObjectEditor.Signature() & "XArrayProp." + oXmlProperty.parentNode.tagName & "." & oXmlProperty.tagName & "." & m_oPropertyEditorMD.getAttribute("n")
		InitXListViewInterface HtmlElement, m_oPropertyEditorMD, m_sViewStateCacheFileName, True
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: Метод вызывается при построении страницы редактора, после инициализации всех PE на странице
	Public Sub FillData()
		' Nothing to do...
	End Sub
	
	
	
	'==========================================================================
	' IPropertyEdior: Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = ObjectEditor.Pool.GetXmlObject(ObjectType, ObjectID, Null).SelectSingleNode(PropertyName)
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
		FillXListViewEx2 HtmlElement, Me, oXmlProperty, m_oPropertyEditorMD, HideIf, False
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
		ExtraHtmlElement("ButtonOperation").disabled = Not( bEnabled )
	End Property
	
	
	'==========================================================================
	' IPropertyEdior: Установка фокуса
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function
	

	'==========================================================================
	' IPropertyEdior: Возвращает IHTMLElement кнопки с операцими
	Public Property Get ButtonOperation
		Set ButtonOperation = ExtraHtmlElement("ButtonOperation")
	End Property

	
	'==========================================================================
	' Возвращает дополнительный контрол IHTMLElement
	Private Function ExtraHtmlElement(sName)
		Set ExtraHtmlElement = ParentPage.HtmlDivElement.all( HtmlElement.id & sName)
	End Function

	
	'==========================================================================
	' IDisposable
	Public Sub Dispose
	End Sub	


	'==========================================================================
	' Генерирует событие
	'	[in] sEventName - наименование события
	'	[in] oEventArgs - параметры события
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent EventEngine, sEventName, Me, oEventArgs
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
			Set Value = ObjectEditor.Pool.GetXmlObjectsByXmlNodeList( oXmlProperty.ChildNodes, Null )
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
	' ОБСЛУЖИВАНИЕ
	
	'==========================================================================
	' Обработчик отжатия клавиши в списке
	Sub OnKeyUp(ByVal nKeyCode, ByVal nFlags)
		With New AccelerationEventArgsClass
			.keyCode	= nKeyCode
			.altKey		= nFlags and KF_ALTLTMASK
			.ctrlKey	= nFlags and KF_CTRLMASK
			.shiftKey	= nFlags and KF_SHIFTMASK
			FireEvent "Accel", .Self()
			Set .HtmlSource = HtmlElement
			Set .Source = Me
			' HtmlElement.CancelEventBubble = True
			If Not .Processed Then
				' если нажатая комбинация не обработана - передадим ее в объект страницы
				ObjectEditor.OnKeyUp Me, .Self()
			End If
		End With
	End Sub


	'==========================================================================
	' Обработчик двойного клика в списке
	Sub OnDblClick(ByVal nIndex , ByVal nColumn, ByVal sID)
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
		If Not m_oMenu.Initialized Then Exit Sub
		' отдадим нажатую комбинацию в меню списка - может для нее там определены hotkey'и
		m_oMenu.ExecuteHotkey Me, oEventArgs
	End Sub


	'==========================================================================
	' Обработчик клика правой кнопкой мыши 
	Public Sub OnContextMenu()
		If Not m_oMenu.Initialized Then Exit Sub
		With New MenuEventArgsClass
			Set .Menu = m_oMenu
			.ReturnValue = True
			FireEvent "BeforeShowMenu", .Self()
			If .ReturnValue <> True Then Exit Sub
			m_oMenu.ShowPopupMenu Me
		End With	
	End Sub
	
	
	'==========================================================================
	' Начинает отображение меню операций
	Public Sub ShowMenu
		Dim oHtmlElement	' объект кнопки "Операции"
		Dim nPosX			'
		Dim nPosY			'
		With New MenuEventArgsClass
			Set .Menu = m_oMenu
			.ReturnValue = True
			FireEvent "BeforeShowMenu", .Self()
			If .ReturnValue <> True Then Exit Sub
			Set oHtmlElement = ExtraHtmlElement("ButtonOperation")
			X_GetHtmlElementScreenPos oHtmlElement, nPosX, nPosY
			'nPosX = nPosX + window.screenLeft
			'nPosY = nPosY + window.screenTop + oHtmlElement.offsetHeight
			m_oMenu.ShowPopupMenuWithPosEx Me, nPosX, nPosY, True
		End With	
	End Sub	

	
	'==========================================================================
	' Стандартный обработчик видимости/доступности
	'	[in] oEventArgs As MenuEventArgsClass
	Sub Internal_MenuVisibilityHandler(oSender, oEventArgs)
		Dim oNode			' текущий menu-item
		Dim bHidden			' признак сокрытия пункта
		Dim oParam
		Dim sObjectID

		For Each oNode In oEventArgs.ActiveMenuItems
			If oNode.getAttribute("action") = "DoIncidentView" Then
				bHidden = Len("" & oEventArgs.Menu.Macros.Item("ObjectID")) = 0 

				If bHidden Then 
					oNode.setAttribute "hidden", "1"
				Else
					oNode.removeAttribute "hidden"
				End If
			ElseIf oNode.getAttribute("action") = "DoEdit" Then
				Set oParam = oNode.selectSingleNode("i:params/i:param[@n='ObjectType']")
				If Not oParam Is Nothing Then
					If oParam.text = "Incident" Then
						' Редактирование инцидента - 
						' - запретим, если он новый (ибо это значит, что нас открыли из него)
						sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
						If Len("" & sObjectID) > 0 Then
							If Not IsNull(getOtherIncident(sObjectID).getAttribute("new")) Then
								oNode.setAttribute "disabled", "1"
							Else
								oNode.removeAttribute "disabled"
							End If
						End If
					End If
				End If
			End If
		Next
	End Sub


	'==========================================================================
	' Стандартный резолвер максров меню
	'	[in] oEventArgs As MenuEventArgsClass
	Sub Internal_MenuMacrosResolver(oSender, oEventArgs)
		oEventArgs.Menu.Macros.Item("ObjectID") = HtmlElement.Rows.SelectedID
		If Len("" & oEventArgs.Menu.Macros.Item("ObjectType")) = 0 Then
			oEventArgs.Menu.Macros.Item("ObjectType") = ValueObjectTypeName
		End If	
	End Sub

	
	'==========================================================================
	' Стандартный обработчик выбора пункта меню
	'	[in] oMenuExecuteEventArgs As MenuExecuteEventArgsClass
	Sub Internal_MenuExecutionHandler(oSender, oEventArgs)
		Dim oSourceElement		' активный элемент до начала операции
		Set oSourceElement = document.activeElement
		
		oEventArgs.Cancel = True
		Select Case oEventArgs.Action
			Case "DoCreate"
				' Создать в текущей транзакции
				DoCreate m_oMenu.Macros
			Case "DoEdit"
				' Редактировать в текущей транзации
				DoEdit m_oMenu.Macros
			Case "DoMarkDelete"
				' Пометить объект как удаленный и удалить ссылку на него из свойства
				DoMarkDelete m_oMenu.Macros
			Case "DoIncidentView"
				DoOpenIncidentView oEventArgs.Menu.Macros.Item("ObjectID")
			Case Else
				oEventArgs.Cancel = False
		End Select
		If Nothing Is oSourceElement Then Exit Sub 
		On Error Resume Next
		oSourceElement.setActive
		oSourceElement.focus
		On Error GoTo 0  
	End Sub

	
	'==========================================================================
	' Возвращает xml-объект инцидента, с которым установлена заданная ссылка от текущего инцидента
	'	[in] sIncidentLinkID
	Private Function getOtherIncident(sIncidentLinkID)
		Dim oIncidentLink
		Dim oOtherIncident
		' выберем текущий объект IncidentLink
		Set oIncidentLink = ObjectEditor.Pool.GetXmlObjectByXmlElement( _
			ObjectEditor.XmlObject.selectSingleNode("LinksFromRoleA/*[@oid='" & sIncidentLinkID & "'] | LinksFromRoleB/*[@oid='" & sIncidentLinkID & "']"), Null )
		' выберем противоположный инцидент
		Set getOtherIncident = ObjectEditor.Pool.GetXmlObjectByXmlElement( oIncidentLink.selectSingleNode("RoleA/*[@oid!='" & ObjectID & "'] | RoleB/*[@oid!='" & ObjectID & "']"), Null )
	End Function


	'==========================================================================
	' Обработчик команды "DoIncidentView" - просмотр инцидента
	Sub DoOpenIncidentView(sIncidentLinkID)
		X_RunReport "Incident", "IncidentID=" & getOtherIncident(sIncidentLinkID).getAttribute("oid")
	End Sub

	
	'==========================================================================
	' Стандартный обработчик команды DoCreate & DoCreateAndSave
	'	[in] oValues	- коллекция параметров операции меню
	'	[in] bSeparateTransaction As Boolean - признак выполнения операции в отдельной транзакции
	Public Sub DoCreate(oValues)
		With New OpenEditorEventArgsClass
			Set .OperationValues = oValues
			.Metaname = HtmlElement.GetAttribute("EditorMetanameForCreating")
			If Not hasValue(.Metaname) And oValues.Exists("Metaname") Then
				.Metaname = oValues.Item("Metaname")
			End If
			.IsSeparateTransaction = False
			If oValues.Exists("UrlParams") Then
				.UrlArguments = oValues.Item("UrlParams")
			End If
			.ReturnValue = True
			FireEvent "BeforeCreate", .Self()
			If .ReturnValue <> True Then Exit Sub
			OnCreate .Self()
			FireEvent "AfterCreate", .Self()
		End With
	End Sub


	'==========================================================================
	' Стандартный обработчик команды DoEdit & DoEditAndSave
	'	[in] oValues	- коллекция параметров операции меню
	'	[in] bSeparateTransaction As Boolean - признак выполнения операции в отдельной транзакции
	Public Sub DoEdit(oValues)
		With New OpenEditorEventArgsClass
			Set .OperationValues = oValues
			.Metaname = HtmlElement.GetAttribute("EditorMetanameForEditing")
			If Not hasValue(.Metaname) And oValues.Exists("Metaname") Then
				.Metaname = oValues.Item("Metaname")
			End If
			.IsSeparateTransaction = False
			If oValues.Exists("UrlParams") Then
				.UrlArguments = oValues.Item("UrlParams")
			End If
			.ReturnValue = True
			.ObjectID = oValues.Item("ObjectID")
			FireEvent "BeforeEdit", .Self()
			If .ReturnValue <> True Then Exit Sub
			OnEdit .Self()
			FireEvent "AfterEdit", .Self()
		End With
	End Sub


	'==============================================================================
	' Стандартный обработчик команды DoMarkDelete
	'	[in] oValues	- коллекция параметров операции меню
	Public Sub DoMarkDelete( oValues )
		With New OperationEventArgsClass
			Set .OperationValues = oValues
			.ReturnValue = True
			.ObjectID = oValues.Item("ObjectID")
			.Prompt = "Вы действительно хотите удалить объект?"
			FireEvent "BeforeMarkDelete", .Self()
			If .ReturnValue <> True Then Exit Sub
			OnMarkDelete .Self()
			FireEvent "AfterMarkDelete", .Self()
		End With	
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
	Public Sub OnCreate(oEventArgs)
		Dim oXmlProperty		' xml-свойство
		Dim oNewObject			' Новый объект-значение
		Dim oNewObjectInProp	' заглушка объекта-значения в свойстве
		Dim oRealProp
		Dim oTempObject         'временный объект типа MultiChoiceIncident - предназначен исключительно для возможности выбора нескольких инцидентов,
		                        'c которыми будет связан текущий

		With oEventArgs
			If oEventArgs.OperationValues.Item("ObjectType") = "Incident" Then
				Dim sIncidentID
				sIncidentID = X_OpenObjectEditor( "Incident", Null, "WizardWithSelectFolder", "")
				If hasValue(sIncidentID) Then
					Set oXmlProperty = XmlProperty
					' создадим новый объект и поместим его в пул
					Set oNewObject = ObjectEditor.Pool.CreateXmlObjectInPool(ValueObjectTypeName)
					' добавим этот новый объект-значение в виртуальное свойство
					Set oNewObjectInProp = oXmlProperty.appendChild( X_CreateStubFromXmlObject(oNewObject) )
					If IsOrdered Then
						' если свойство сортируемое - вставим расположим в свойстве с учетом сортировки
						OrderObjectInPropEx oXmlProperty, oNewObjectInProp
					End If
					' в реальное свойство, в котором мы создаем объект, добавим ссылку на созданный объект IncidentLink
					' тем самым модифицировалось обратное свойство (RoleA или RoleB)
					ObjectEditor.Pool.AddRelation ObjectEditor.XmlObject, .OperationValues.Item("RealPropName"), X_CreateStubFromXmlObject(oNewObject)
					' осталось добавить в созданный объект IncidentLink ссылку на созданный инцидент
					' выбирем свободное свойство из RoleA и ROleB - в него и добавим (другое будет занято ссылкой на текущий инцидент)
					Set oRealProp = oNewObject.selectSingleNode("RoleA[not(*)] | RoleB[not(*)]")
					ObjectEditor.Pool.AddRelation oNewObject, oRealProp, X_CreateObjectStub("Incident", sIncidentID) 
					' обновим представление PE
					SetDataEx oXmlProperty
				End If
			Else
			    Dim sUrlParams 'Строка со значением параметра RealPropName, который принимает значение  LinksFromRoleA либо LinksFromRoleB
			    Dim resultSelection 'Массив первый,элемент которого содержит выбранные узлы(инциденты)
			    Dim oNode ' выбранный элемент в дереве инцидентов
			     
				' начнем агрегированную транзакцию
				ObjectEditor.Pool.BeginTransaction True
				' получим реальное свойство объекта
				Set oRealProp = ObjectEditor.XmlObject.selectSingleNode( .OperationValues.Item("RealPropName") )
				' ВАЖНО: ссылка oXmlProperty полечена после вызова BeginTransaction, поэтому ей можно пользоваться и после CommitTransaction
				Set oXmlProperty = XmlProperty
				
				' Создадим  временный объект типа MultiChoiceIncident и поместим его в пул
				'Если такой временный объект уже есть,то повторно его не создаем
				 Set oTempObject = ObjectEditor.Pool.Xml.selectSingleNode("MultiChoiceIncident")
				 If oTempObject Is Nothing Then
				    Set oTempObject = ObjectEditor.Pool.CreateXmlObjectInPool("MultiChoiceIncident")
			     End If
			   				
										
                sUrlParams= "RealPropName=" & .OperationValues.Item("RealPropName")
				
				'Откроем редактор временного объекта, чтобы можно было выбрать инциденты (см.свойство Incidents врем.объекта)	
				'Oткрываем редактор с признаком EnlistInCurrentTransaction=True, т.о. этот редактор не будет создавать новой транзакции			
				resultSelection =ObjectEditor.OpenEditor(oTempObject, Null, Null, .Metaname, True, oRealProp, Not .IsSeparateTransaction, True,sUrlParams)
				
				If  IsEmpty(resultSelection)  Then
					' нажали отмену - откатим транзакцию
					ObjectEditor.Pool.RollbackTransaction
				Else
					' успешно выбрали инциденты - создадим для каждого выбранного инц-та объект IncidentLink и установим все нужные ссылки в текущем 
					'пуле объектов										
					For Each oNode In resultSelection(0).ChildNodes
                       CreateIncidentLink oNode.getAttribute("id"),.OperationValues.Item("RealPropName")
                    Next
					
					'закомитим транзакцию
					ObjectEditor.Pool.CommitTransaction
					' обновим представление PE
					SetDataEx oXmlProperty
				End If		
			End If	
		End With
	End Sub
	
    '==========================================================================
    'Вспомогательная процедура, которая создает объект  IncidentLink в текущем пуле объектов и устанавливает необходимые ссылки между объектами.
    '	[in] sIncidentID    - идентификатор инцидента, на который/от которого ставим ссылку относительно текущего ин-та 
    '	[in] sRealPropName  - наименование свойства в типе Incident, куда будем помещать ссылку на создаваемый объект типа IncidentLink
    ' это либо LinksFromRoleA или LinksFromRoleB                            
     
    Public Sub CreateIncidentLink(sIncidentID,sRealPropName)
        Dim oXmlProperty		' xml-свойство
		Dim oNewObject			' Новый объект-Incident
		Dim oNewObjectInProp	' заглушка объекта-значения в свойстве
		Dim oRealProp           'Свойство RoleA или RoleB в создаваемом объекте IncidentLink
		
		Set oXmlProperty = XmlProperty 'виртуальное свойство
		' создадим новый объект  IncidentLink и поместим его в пул
		Set oNewObject = ObjectEditor.Pool.CreateXmlObjectInPool(ValueObjectTypeName)
		' добавим этот новый объект-значение в виртуальное свойство
		Set oNewObjectInProp = oXmlProperty.appendChild( X_CreateStubFromXmlObject(oNewObject) )
		If IsOrdered Then
					' если свойство сортируемое - вставим расположим в свойстве с учетом сортировки
					OrderObjectInPropEx oXmlProperty, oNewObjectInProp
		End If
		' в реальное свойство, в котором мы создаем объект, добавим ссылку на созданный объект IncidentLink
		' тем самым модифицировалось обратное свойство (RoleA или RoleB)
		ObjectEditor.Pool.AddRelation ObjectEditor.XmlObject, sRealPropName, X_CreateStubFromXmlObject(oNewObject)
		' осталось добавить в созданный объект IncidentLink ссылку на выбранный инцидент
		' выбирем свободное свойство из RoleA и ROleB - в него и добавим (другое будет занято ссылкой на текущий инцидент)
		Set oRealProp = oNewObject.selectSingleNode("RoleA[not(*)] | RoleB[not(*)]")
		ObjectEditor.Pool.AddRelation oNewObject, oRealProp, X_CreateObjectStub("Incident", sIncidentID) 
			 
    End Sub
	
	'==============================================================================
	' Стандартный обработчик события Edit
	'	[in] oEventArgs As OpenEditorEventArgsClass
	Public Sub OnEdit(oEventArgs)
		Dim oXmlProperty		' виртуальное xml-свойство
		Dim oRealXmlProp		' реальное xml-свойство
		Dim oIncidentLink		' As IXMLDOMElement - xml-Объект IncidentLink
		Dim oOtherIncident		' As IXMLDOMElement - xml-Объект Incident, с которым связан текущий по средством объекта IncidentLink

		With oEventArgs
			' И редактируем его...
			Set oRealXmlProp = getRealXmlProp(.ObjectID)
			If oRealXmlProp Is Nothing Then Err.Raise -1, "OnEdit", "Не удалось найти реальное свойство"

			If oEventArgs.OperationValues.Item("ObjectType") = "Incident" Then

				Set oIncidentLink = ObjectEditor.Pool.GetXmlObjectByXmlElement( oRealXmlProp.selectSingleNode("IncidentLink[@oid='" & .ObjectID & "']"), Null)
				Set oOtherIncident = oIncidentLink.selectSingleNode("RoleA/*[@oid!='" & ObjectID & "'] | RoleB/*[@oid!='" & ObjectID & "']")
				.ReturnValue = ObjectEditor.OpenEditor(Null, "Incident", oOtherIncident.getAttribute("oid"), Null, False, oOtherIncident.parentNode, Not .IsSeparateTransaction, False, .UrlArguments)
				If IsEmpty( .ReturnValue ) Then Exit Sub
				' после редактирования инцидента ссылка (IncidentLink) могла пропасть
				Set oRealXmlProp = getRealXmlProp(.ObjectID)
				If oRealXmlProp Is Nothing Then
					' пропала, удалим заглушку из виртуального свойства
					XmlProperty.selectNodes("*[@oid='" & .ObjectID & "']").removeAll
				End If
				SetDataEx XmlProperty
			Else
				.ReturnValue = ObjectEditor.OpenEditor(Null, ValueObjectTypeName, .ObjectID, .Metaname, False, oRealXmlProp, Not .IsSeparateTransaction, False, .UrlArguments)
				If IsEmpty( .ReturnValue ) Then Exit Sub
				Set oXmlProperty = XmlProperty
				If IsOrdered Then
					' если свойство сортируемое - расположим отредактированный объект с учетом сортировка
					OrderObjectInPropEx oXmlProperty, oXmlProperty.selectSingleNode(ValueObjectTypeName & "[@oid='" & .ObjectID & "']")
				End If
				' обновим представление PE
				SetDataEx oXmlProperty
			End If	
		End With
	End Sub


	'==============================================================================
	' Стандартный обработчик события MarkDelete
	'	[in] oEventArgs As OperationEventEventArgs
	Public Sub OnMarkDelete(oEventArgs)
		Dim oXmlProperty	' xml-свойство
		Dim nButtonFlag		' флаги MsgBox
		Dim oRealXmlProp		' реальное xml-свойство
		
		With oEventArgs
			' если задан текст запроса пользователю, то сначала спросим
			If hasValue(.Prompt) Then
				' задизеблим, чтобы подавить порождение нежелательного события OnKeyUp от нажатия Enter в диаголе
				HtmlElement.object.Enabled = False
				nButtonFlag = iif(StrComp(.OperationValues.Item("DefaultButton"), "No")=0, vbDefaultButton2, vbDefaultButton1)
				If vbNo = MsgBox(.Prompt, vbYesNo + vbInformation + nButtonFlag) Then
					HtmlElement.object.Enabled = True
					Exit Sub
				End If
				HtmlElement.object.Enabled = True
			End If
			
			' ПРИМЕЧАНИЕ: MarkObjectAsDeleted не использует транзации пула, поэтому можно безболезненно сохранять ссылку на XmlProperty
			Set oXmlProperty = XmlProperty
			Set oRealXmlProp = getRealXmlProp(.ObjectID)
			If oRealXmlProp Is Nothing Then Err.Raise -1, "OnEdit", "Не удалось найти реальное свойство"
			' ObjectEditor.Pool.MarkObjectAsDeleted здесь работать не будет, т.к. у нас есть ссылки на удаляемый объект в в
			oEventArgs.ReturnValue = ObjectEditor.Pool.MarkObjectAsDeleted( ValueObjectTypeName, .ObjectID, oRealXmlProp, False, Nothing )
			If oEventArgs.ReturnValue Then
				' а теперь удалим ссылку из виртуального свойства
				oXmlProperty.selectNodes(ValueObjectTypeName & "[@oid='" & .ObjectID & "']").removeAll
				' обновим представление свойства
				SetDataEx oXmlProperty
			End If
		End With
	End Sub
	
	
	'==============================================================================
	Private Function getRealXmlProp(ValueObjectID)
		Set getRealXmlProp = ObjectEditor.XmlObject.selectSingleNode("LinksFromRoleA[*[@oid='" & ValueObjectID & "']] | LinksFromRoleB[*[@oid='" & ValueObjectID & "']]")
	End Function
End Class


'==============================================================================
Function IncidentLink_getLinkedIncident(oPool, oIncidentLink, sOwnderOID)
	Set IncidentLink_getLinkedIncident = oPool.GetXmlObjectByXmlElement(oIncidentLink, "RoleA.State;RoleB.State").selectSingleNode("RoleA/Incident[@oid!='" & sOwnderOID & "'] | RoleB/Incident[@oid!='" & sOwnderOID & "']")
End Function


'==============================================================================
Function IncidentLink_getNumber(oPool, oIncidentLink, sOwnderOID)
	Dim oIncident
	Set oIncident = IncidentLink_getLinkedIncident(oPool, oIncidentLink, sOwnderOID)
	IncidentLink_getNumber = oPool.GetPropertyValue(oIncident, "Number")
End Function

Function IncidentLink_getState(oPool, oIncidentLink, sOwnderOID)
	Dim oIncident
	Set oIncident = IncidentLink_getLinkedIncident(oPool, oIncidentLink, sOwnderOID)
	IncidentLink_getState = oPool.GetPropertyValue(oIncident, "State.Name")
End Function

Function IncidentLink_getName(oPool, oIncidentLink, sOwnderOID)
	Dim oIncident
	Set oIncident = IncidentLink_getLinkedIncident(oPool, oIncidentLink, sOwnderOID)
	IncidentLink_getName = oPool.GetPropertyValue(oIncident, "Name")
End Function
