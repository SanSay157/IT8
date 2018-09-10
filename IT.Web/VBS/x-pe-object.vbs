Option Explicit

'==============================================================================
'	OBJECT-PRESENTATION (read-only-поле + кнопка с меню операций)
'==============================================================================
' События (в скобках наименования класса параметров события):
'	MenuBeforeShow  - перед показом меню (MenuEventArgs)
'	ShowMenu		- показ меню (MenuEventArgs). Есть стандартный обработчик
'	Accel (EventArgs: AccelerationEventArgsClass)
'		нажатие комбинации клавиш
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
' Команда DoCreate:
'	BeforeCreate	- Перед создание объекта (OpenEditorEventArgsClass). Если ReturnValue=False, цепочка событий прерывается
'	Create			- Создание объекта (OpenEditorEventArgsClass). Есть стандартный обработчик
'	AfterCreate		- После создания объекта (OpenEditorEventArgsClass).
' Команда DoEdit:
'	BeforeEdit		- Перед редактирование объекта (OpenEditorEventArgsClass). Если ReturnValue=False, цепочка событий прерывается
'	Edit			- Редактирование объекта (OpenEditorEventArgsClass). Есть стандартный обработчик
'	AfterEdit		- После редактирования объекта (OpenEditorEventArgsClass).
' Команда DoMarkDelete:
'	BeforeMarkDelete- (EventArgsClass)
'	MarkDelete		- Очистка свойства и помечание объекта как удаленного (EventArgsClass). Есть стандартный обработчик
'	AfterMarkDelete	- (EventArgsClass)
' Команда DoUnLink:
'	BeforeUnlink	- перед очисткой свойства (EventArgsClass). Если ReturnValue=False, цепочка событий прерывается
'	Unlink			- очистка свойства (EventArgsClass). Есть стандартный обработчик
'	AfterUnlink		- после очистки свойства (EventArgsClass).
Class XPEObjectPresentationClass
	Private m_oPropertyEditorBase 	' As XPropertyEditorObjectBaseClass
	Private m_oCaptionHtmlElement	' As IHtmlElement	- Html-элемент кнопки с операциями
	Private EVENTS					' список событий страницы
	Private m_oMenu					' As MenuClass		- меню операций
	Private m_sExpression			' As String			- VBS-выражение
	Private m_bAutoCaptionToolTip	' As Boolean		- признак автоматического изменения тултипа текстового поля
	
	'==========================================================================
	' Конструктор
	Private Sub Class_Initialize
		EVENTS = "MenuBeforeShow," & _
			"BeforeSelect,GetRestrictions,Select,ValidateSelection,BindSelectedData,AfterSelect," & _
			"BeforeSelectXml,SelectXml,AfterSelectXml," & _
			"BeforeCreate,Create,AfterCreate," & _
			"BeforeEdit,Edit,AfterEdit," & _
			"BeforeMarkDelete,MarkDelete,AfterMarkDelete," & _
			"BeforeUnlink,Unlink,AfterUnlink,SelectConflict,Accel"
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
	' Инициализация редактора свойства.
	' см. IPropertyEditor::Init
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim oMenuMD				' метаданные меню (i:menu)
		
		Set m_oMenu = New MenuClass
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectPresentation"
		
		Set m_oCaptionHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all(HtmlElement.GetAttribute("INPUTID"), 0) 
		' подпишем стандартные обработчики своих событий
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Select", Me, "OnSelect"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "BindSelectedData", Me, "OnBindSelectedData"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Create", Me, "OnCreate"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Edit", Me, "OnEdit"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "MarkDelete", Me, "OnMarkDelete"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "UnLink", Me, "OnUnLink"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "SelectXml", Me, "OnSelectXml"
		
		' Инициализируем меню: получим его метаданные, (используя атрибут MetadataLocator найдем i:object-presentation), добавим стандартные обработчики 
		Set oMenuMD = m_oPropertyEditorBase.PropertyEditorMD.selectSingleNode( "i:prop-menu/i:menu")
		If Not oMenuMD Is Nothing Then
			m_oMenu.AddMacrosResolver X_CreateDelegate(Me, "Internal_MenuMacrosResolver") 
			m_oMenu.AddVisibilityHandler X_CreateDelegate(Me, "Internal_MenuVisibilityHandler")
			m_oMenu.AddExecutionHandler X_CreateDelegate(Me, "Internal_MenuExecutionHandler") 
			m_oMenu.Init oMenuMD
		End If
				
		m_sExpression = HtmlElement.GetAttribute("ObjectPresentationExpression")
		' Если формула получения представления не задана - отображаем ObjectID (пока)
		If Not hasValue(m_sExpression) Then 
			m_sExpression = "item.ObjectID"
		End If
		ViewInitialize
		m_bAutoCaptionToolTip = CBool(HtmlElement.GetAttribute("AutoToolTip") = "1")
	End Sub

	
	'==========================================================================
	' IPropertyEdior: Метод вызывается при построении страницы редактора, после инициализации всех PE на странице
	Public Sub FillData()
		' Nothing to do...
	End Sub

	
	'==========================================================================
	' Установка значения редактора свойства.
	' см. IPropertyEditor::SetData
	Public Sub SetData
		SetDataEx XmlProperty
	End Sub

	
	'==========================================================================
	' Устанавливает значения. Используется для оптимизации, 
	'	т.к. не получает XmlProperty стандартным механизмом
	' Метод устанавливает строку представления объекта в соответствии со
	'	значением объектного свойства в пуле 
	'	[in] oXmlProperty As IXMLDOMElement - закешированная ссылка на текущее xml-свойство
	Private Sub SetDataEx(oXmlProperty)
		Dim oXmlItem		' As XMLDOMELement - объект-значение свойства
		Dim sCaption		' As String - текстовое представление объекта
		
		Set oXmlItem = oXmlProperty.firstChild
		' Расчитаем строку с текстом представления объекта:
		If Not(Nothing Is oXmlItem) Then
			' расчет самой строки - выполняется VBS-выражение
			sCaption = vbNullString & m_oPropertyEditorBase.ObjectEditor.ExecuteStatement( oXmlItem, Expression )
		End if
		' Отображение текста представления в UI:
		SetCaption sCaption
	End Sub
	
	
	'==========================================================================
	' Сбор и проверка данных
	' Подробнее см. IPropertyEditor::GetDataArgsClass
	Public Sub GetData(oGetDataArgs)
		ValueCheckOnNullForPropertyEditor Value,  Me, oGetDataArgs, Mandatory
	End Sub
	
	
	'==========================================================================
	' Возвращает признак (не)обязательности свойства
	' Подробнее см. IPropertyEditor::Mandatory
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	
	
	'==========================================================================
	' Установка (не)обязательности
	' Подробнее см. IPropertyEditor::Mandatory
	Public Property Let Mandatory(bMandatory)
		If (bMandatory) Then
			HtmlElement.removeAttribute "X_MAYBENULL"
		Else	
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
		End If
		If (bMandatory) Then
			m_oCaptionHtmlElement.className = "x-editor-control-notnull x-editor-objectpresentation-text"
		Else
			m_oCaptionHtmlElement.className = "x-editor-control x-editor-objectpresentation-text"
		End If
	End Property
	
	
	'==========================================================================
	' Получение (не)доступности
	' Подробнее см. IPropertyEditor::Enabled
	Public Property Get Enabled
		 Enabled = Not (HtmlElement.disabled)
	End Property

	'==========================================================================
	' Установка (не)доступности
	' Подробнее см. IPropertyEditor::Enabled
	Public Property Let Enabled(bEnabled)
		' задизейблим/раздизейблим кнопку
		HtmlElement.disabled = Not( bEnabled )
		' задизейблим/раздизейблим read-only-поле
		CaptionElement.disabled = Not( bEnabled )
	End Property
	
	
	'==========================================================================
	' Установка фокуса
	' Подробнее см. IPropertyEditor::SetFocus
	Public Function SetFocus
		window.focus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function
	
	
	'==========================================================================
	' Получение основного HTML-элемента редактора свойства
	' Подробнее см. IPropertyEditor::HtmlElement
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property


	'==========================================================================
	' Возвращает/устанавливает описание свойства
	Public Property Get PropertyDescription
		PropertyDescription = m_oPropertyEditorBase.PropertyDescription
	End Property	
	Public Property Let PropertyDescription(sValue)
		m_oPropertyEditorBase.PropertyDescription = sValue
	End Property

	
	'==========================================================================
	' Разрыв связей с другими объектами
	' Подробнее см. IDisposable::Dispose
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
		Set m_oPropertyEditorBase = Nothing
	End Sub

	
	'==========================================================================
	' Возвращает Xml-свойство
	' Подробнее см. IPropertyEditor::XmlProperty
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property

		
	'==========================================================================
	' Возвращает xml-объект-значениe xml-свойства. Если объектная ссылка пустая
	' возвращает Nothing
	Public Property Get Value
		Dim oXmlProperty		' As IXMLDOMElement
		
		Set oXmlProperty = XmlProperty
		If oXmlProperty.FirstChild Is Nothing Then
			Set Value = Nothing
		Else	
			' Загружен объект-значение
			Set Value = m_oPropertyEditorBase.ObjectEditor.Pool.GetXmlObjectByXmlElement( oXmlProperty.FirstChild, Null )
		End If
	End Property
	
	
	'==========================================================================
	' Устанавливает одноременно xml-объект-значениe xml-свойства и значение 
	' строки отображения, ему соответствующее
	' [in] oObject - устанавливаемый в качестве значения Xml-объект
	' Если oObject Is Nothing свойство очищается
	Public Property Set Value(oObject)
		Dim oXmlProperty		' As IXMLDOMElement - текущее свойство
		Set oXmlProperty = XmlProperty
		' очисти значние свойства
		If Not oXmlProperty.firstChild Is Nothing Then
			' если св-во непустое - очистим его
			m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
		End If
		' установим значение свойства
		If Not IsNothing(oObject) Then
			m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, oObject
		End If
		' установим значение
		SetDataEx oXmlProperty
	End Property


	'==========================================================================
	' Возвращает идентификатор объекта-значения xml-свойства
	' Если свойство пустое возвращает Null
	Public Property Get ValueID
		' Получим ID объекта - значения свойства
		If XmlProperty.FirstChild Is Nothing Then
			ValueID = Null
		Else	
			' Загружен объект-значение
			ValueID = XmlProperty.FirstChild.getAttribute("oid") 
		End If
	End Property
	 
	
	'==========================================================================
	' Устанавливает значение свойства и строки отображения по идентификатору объекта значения.
	' Тип объекта получаем по метаданным свойства.
	' [in] sObjectID - идентификатор устанавливаемого в качестве значения Xml-объекта
	' Если sObjectID Is Null свойство очищается
	Public Property Let ValueID(sObjectID)
		If Len("" & sObjectID) = 0 Then
			Set Value = Nothing
		Else
			Set Value = X_CreateObjectStub(ValueObjectTypeName, sObjectID)
		End If
	End Property

	
	'==========================================================================
	' Возвращает наименование типа объекта значения свойства
	' Подробнее см. IObjectPropertyEditor::ValueObjectTypeName 
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyEditorBase.ValueObjectTypeName
	End Property
	
	
	'==========================================================================
	' Возвращает IHtmlInputElement элемент текстового поля, в котором отображается 
	' строка описывающая объект
	Private Property Get CaptionElement
		Set CaptionElement = m_oCaptionHtmlElement
	End Property

	
	'==========================================================================
	' Возвращает содержимое текстового поля, в котором отображается строка описывающая объект
	Public Property Get CaptionText
		CaptionText = CaptionElement.Value
	End Property

	
	'==========================================================================
	' Устанавливает/Возвращает тултип для текстового поля, в котором отображается строка описывающая объект
	Public Property Let CaptionToolTip(sValue)
		CaptionElement.Title = sValue
	End Property
	Public Property Get CaptionToolTip
		CaptionToolTip = CaptionElement.Title
	End Property


	'==========================================================================
	' Устанавливает/возвращает признак автоматического изменения тултипа текстового поля
	Public Property Let AutoToolTip(bValue)
		m_bAutoCaptionToolTip = bValue
	End Property
	Public Property Get AutoToolTip
		AutoToolTip = m_bAutoCaptionToolTip
	End Property


	'==========================================================================
	' Устанавливает содержимое текстовой строки описывающей представление объекта
	Private Sub SetCaption(sText)
		CaptionElement.Value = sText
		If m_bAutoCaptionToolTip Then
			CaptionToolTip = sText
		End If
	End Sub

	
	'==========================================================================
	' Возбуждает событие
	' [in] sEventName - наименование события
	' [in] oEventArgs - экземпляр потомка EventArgsClass, события
	' Вызывает одноименный метод EventEngine, передавая ему в качестве
	' источника ссылку на себя 
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub
	
	
	'==========================================================================
	' Выполняет выравнивание размеров кнопки операций, 
	' в соответствии с размером поля отображения представления объекта.
	Private Sub ViewInitialize( )
		' Примечание: было обнаружено необъяснимое поведение - возникала ошибка object required при обращении к CaptionElement, 
		' при этом свойства объекта считывались.
		On Error Resume Next
		' Выравнивание размеров кнопки операций выполняется по отношению к размерам
		' поля отображения представления объекта: получаем ссылку на соотв. HTML-элемент
		With HtmlElement
			.style.height = CaptionElement.offsetHeight
			.style.width = .style.height
			.style.lineHeight = (.offsetHeight \ 2) & "px"
		End With
		CaptionElement.style.width = CaptionElement.offsetWidth & "px"
		Err.Clear
	End Sub
	
	
	'==========================================================================
	' Устанавливает/Возвращает Vbs-выражение для вычисления представления свойства
	' подробнее см. i:object-presentation
	Public Property Get Expression
		Expression = m_sExpression
	End Property 
	Public Property Let Expression(value)
		m_sExpression = value
		SetData
	End Property 

	
	'==========================================================================
	' Устанавливает/Возвращает тип селектора, используемого при выборке объекта
	' Может принимать значения "list" и "tree"
	' Подробнее см. IObjectPropertyEditor::SelectorType
	Public Property Get SelectorType
		SelectorType = m_oPropertyEditorBase.SelectorType
	End Property
	Public Property Let SelectorType(value)
		m_oPropertyEditorBase.SelectorType = value
	End Property
	
	
	'==========================================================================
	' Устанавливает/Возвращает метаимя селектора, используемого при выборке объекта
	' Подробнее см. IObjectPropertyEditor::SelectorMetaname
	Public Property Get SelectorMetaname
		SelectorMetaname = m_oPropertyEditorBase.SelectorMetaname
	End Property
	Public Property Let SelectorMetaname(value)
		m_oPropertyEditorBase.SelectorMetaname = value
	End Property
	
	
	'==========================================================================
	' Возвращает меню, используемое стандартным обработчиком события OnShowMenu
	Public Property Get Menu
		Set Menu = m_oMenu
	End Property	

	
	'==========================================================================
	' Обработчик клика кнопки "...". Начинает показ меню операций.
	Public Sub ShowMenu
		Dim nPosX		' координата x для показа меню
		Dim nPosY		' координата y для показа меню
		
		With New MenuEventArgsClass
			Set .Menu = m_oMenu
			.ReturnValue = True
			FireEvent "MenuBeforeShow", .Self()
			If .ReturnValue <> True Then Exit Sub
		End With
		If Not m_oMenu.Initialized Then Exit Sub
		X_GetHtmlElementScreenPos HtmlElement, nPosX, nPosY
		nPosY = nPosY + HtmlElement.offsetHeight
		m_oMenu.ShowPopupMenuWithPosEx Me, nPosX, nPosY, True
	End Sub
	
	
	'==========================================================================
	' Обработчик Html-события OnKeyUp на кнопке.
	' Внимание: для внутренного использования.
	Public Sub Internal_OnKeyUp()
		Dim oEventArgs		' As AccelerationEventArgsClass
		
		If window.event Is Nothing Then Exit Sub
		window.event.cancelBubble = True
		Set oEventArgs = CreateAccelerationEventArgsForHtmlEvent()
		Set oEventArgs.Source = Me
		FireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' если нажатая комбинация не обработана - передадим ее в редактор
			ObjectEditor.OnKeyUp Me, oEventArgs
		End If
	End Sub
	
	
	'==========================================================================
	' Стандартные резолвер макросов меню
	'	[in] oMenuEventArgs As MenuEventArgsClass
	' Подробнее см. описание MenuClass 
	Sub Internal_MenuMacrosResolver(oSender, oMenuEventArgs)
		Dim sObjectID		' идентификатор объекта-значения
		sObjectID = Null
		With XmlProperty
			If Not .firstChild Is Nothing Then
				sObjectID = .firstChild.getAttribute("oid")
			End If
		End With
		oMenuEventArgs.Menu.Macros.Item("ObjectID")   = sObjectID
		oMenuEventArgs.Menu.Macros.Item("ObjectType") = m_oPropertyEditorBase.ValueObjectTypeName
	End Sub
	
	
	'==========================================================================
	' Стандартный обработчик видимости/доступности пунктов меню
	'	[in] oMenuEventArgs As MenuEventArgsClass
	' Подробнее см. описание MenuClass 
	Sub Internal_MenuVisibilityHandler(oSender, oMenuEventArgs)
		Dim bDisabled		' признак заблокированности пункта
		Dim bHidden			' признак сокрытия пункта
		Dim oNode			' текущий menu-item
		Dim sType			' тип объекта в свойстве
		Dim sObjectID		' идентификатор объекта-значения
		Dim oList			' As ObjectArrayListClass - массив объектов XObjectPermission
		Dim oXmlProperty	' xml-свойство
		Dim oObjectValue	' As IXMLDOMElement - xml-объект значение
		Dim bIsLoaded		' As Boolean - признак того,что объект-значение загружен из БД
		Dim bProcess		' As Boolean - признак обработки текущего пункта

		Set oXmlProperty = XmlProperty		
		sType = oMenuEventArgs.Menu.Macros.Item("ObjectType")
		sObjectID = oMenuEventArgs.Menu.Macros.Item("ObjectID")
		If Not IsNull(sObjectID) Then
			Set oObjectValue = ObjectEditor.Pool.GetXmlObject(sType, sObjectID, Null)
			If Not oObjectValue Is Nothing Then
				bIsLoaded = IsNull(oObjectValue.getAttribute("new"))
			End If
		End If	

		Set oList = New ObjectArrayListClass
		' Обработаем только известные нам операции
		For Each oNode In oMenuEventArgs.ActiveMenuItems
			' установим атрибуты на пункте меню, чтобы oMenu.SetMenuItemsAccessRights смог увязать запросы на проверку прав и пункты меню (при проставлении флага disabled)
			oNode.setAttribute "type", sType
			If Not IsNull(sObjectID) Then _
				oNode.setAttribute "oid",  sObjectID
				
			bHidden = Empty
			bDisabled = Empty
			bProcess = False
			Select Case oNode.getAttribute("action")
				Case "DoSelectFromDb"
					bHidden = Len( HtmlElement.getAttribute("OFF_SELECT") )>0
					bProcess = True
				Case "DoSelectFromXml"
					bHidden = Len( HtmlElement.getAttribute("OFF_SELECT") )>0
					bProcess = True
				Case "DoCreate"
					bHidden = Len( HtmlElement.getAttribute("OFF_CREATE") )>0
					oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CREATE, sType, Empty)
					bProcess = True
				Case "DoEdit"
					bHidden = IsNull(sObjectID) Or Len( HtmlElement.getAttribute("OFF_EDIT") )>0
					If Not bHidden And bIsLoaded Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CHANGE, sType, sObjectID)
					bProcess = True
				Case "DoMarkDelete"
					bHidden = IsNull(sObjectID) Or Len( HtmlElement.getAttribute("OFF_DELETE") )>0
					If Not bHidden And bIsLoaded Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_DELETE, sType, sObjectID)
					bProcess = True
				Case "DoUnlink"
					bHidden = IsNull(sObjectID) Or Len( HtmlElement.getAttribute("OFF_UNLINK") )>0
					If Not bHidden Then
						bDisabled = Mandatory
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
			oMenuEventArgs.Menu.SetMenuItemsAccessRights oList.GetArray()
		End If
	End Sub
	
	
	'==========================================================================
	' Стандратный обработчик выполнения пункта меню
	' [in] oMenuExecuteEventArgs As MenuExecuteEventArgsClass
	' Подробнее см. описание MenuClass 
	Sub Internal_MenuExecutionHandler(oSender, oMenuExecuteEventArgs)
		oMenuExecuteEventArgs.Cancel = True
		Select Case oMenuExecuteEventArgs.Action
			' выбор объекта из БД
			Case "DoSelectFromDb"
				m_oPropertyEditorBase.DoSelectFromDb oMenuExecuteEventArgs.Menu.Macros
			' выбор объекта из Xml
			Case "DoSelectFromXml"
				m_oPropertyEditorBase.DoSelectFromXml oMenuExecuteEventArgs.Menu.Macros
			' Создать в текущей транзакции
			Case "DoCreate"
				m_oPropertyEditorBase.DoCreate oMenuExecuteEventArgs.Menu.Macros, False
			' Отредактировать в текущей транзакции
			Case "DoEdit"
				m_oPropertyEditorBase.DoEdit oMenuExecuteEventArgs.Menu.Macros, False
			' Пометить объект как удаленный и разорвать связь
			Case "DoMarkDelete"
				m_oPropertyEditorBase.DoMarkDelete oMenuExecuteEventArgs.Menu.Macros
			' Разорвать связь
			Case "DoUnlink"
				m_oPropertyEditorBase.DoUnlink oMenuExecuteEventArgs.Menu.Macros
			Case Else
				oMenuExecuteEventArgs.Cancel = False
		End Select	
	End Sub
	
	
	'==========================================================================
	' Стандартный обработчик события "Select"
	' [in] oSender - экземпляр XPEObjectPresentationClass, источник события
	' [in] oEventArgs - экземпляр SelectEventArgsClass, параметры события
	' Данный обработчик производит генерацию событий GetRestrictions для
	' получения дополнительных ограничений после чего производит отбор используя
	' седектор типа "SelectorType" с метаименем "SelectorMetaname"
	Public Sub OnSelect(oSender, oEventArgs)
		Dim sType					' As String		- Тип объекта-значения
		Dim sParams					' As String		- Параметры для data-source (Param1=Value1&Param2=Value2)
		Dim sUrlArguments			' As String		- Параметры селектора
		Dim sExcludeNodes			' As String		- Список исключаемых узлов для выбора из дерева
		Dim vRet					' As String		- Результат отбора
		Dim oXmlProperty			' As XMLDOMElement	- xml-свойтсво
		Dim vTemp                   ' As Variant    - Вспомогательная переменная для вычисления SelectionMode
		
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
		If oEventArgs.SelectorType="list" Then
			' Выбор производится из списка
			vRet = X_SelectFromList(oEventArgs.SelectorMetaname , sType, LM_SINGLE, sParams, sUrlArguments)
			oEventArgs.ObjectValueType = sType
		Else
			' Покажем диалог и получим выбранное значение
			With New SelectFromTreeDialogClass
				.Metaname = oEventArgs.SelectorMetaname
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
				.SuitableSelectionModes = Array(TSM_ANYNODE, TSM_LEAFNODE)

				' Если объект ссылается сам на себя, то не дадим ему выбрать себя в стандартном дереве
				If Not hasValue(sExcludeNodes) And sType = oXmlProperty.parentNode.tagName Then
					sExcludeNodes = sType & "|" & oXmlProperty.parentNode.GetAttribute("oid")
				End If
				.ExcludeNodes = sExcludeNodes
				
				SelectFromTreeDialogClass_Show .Self()
				
				If .ReturnValue Then
					vRet = .Selection.selectSingleNode("n").getAttribute("id")
					oEventArgs.ObjectValueType = .Selection.selectSingleNode("n").getAttribute("ot")
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
		    .Selection = X_SelectFromXmlList(ObjectEditor, .SelectorMetaname, .ObjectValueType, LM_SINGLE, .Objects, .UrlArguments)
		    .ReturnValue = hasValue(.Selection)
		End With
	End Sub


	'==========================================================================
	' Стандартный обработчик события "BindSelectedData"
	' [in] oSender - экземпляр XPEObjectPresentationClass, источник события.
	' [in] oEventArgs - экземпляр SelectEventArgsClass, параметры события.
	' Данный обработчик производит замену текущего значения объектной ссылки
	' на отобранную в результате обработки события "OnSelect".
	' Также обновляется текстовое представление объекта
	Public Sub OnBindSelectedData(oSender, oEventArgs)
		Dim oXmlProperty		' xml-свойство
		Dim oNewItem			' выбранный объект
		Dim sObjectID			' идентификатор выбранного объекта
		
		Set oXmlProperty = XmlProperty
		sObjectID = oEventArgs.Selection
		' Если здесь, значит чего-то выбрали и проверка выбора не запретила его
		' Удаляем старое значение
		With m_oPropertyEditorBase.ObjectEditor.Pool
			.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
			' Загрузим выбранный объект в пул, чтобы, во-первых, убедиться что он есть 
			' и, во-вторых, все равно он будет загружен при отрисовке свойства в SetData
			Set oNewItem = .GetXmlObject(oEventArgs.ObjectValueType, sObjectID, Null)
			If X_WasErrorOccured Then
				If X_GetLastError.IsObjectNotFoundException Then
					' выбранный объект не найден
					If EventEngine.IsHandlerExists("SelectConflict") Then
						' TODO: возможно надо EventArgs со список идентификаторов удаленных объектов, сделаем как понадобится
						FireEvent "SelectConflict", Nothing
					Else
						MsgBox "Выбранный объект '" & sObjectID & "' не был добавлен в свойство, т.к. был удален другим пользователем", vbOKOnly + vbInformation
					End If
				Else
					' если была другая серверная ошибка, покажем сообщение
					X_GetLastError.Show
				End If
			Else
				.AddRelation Nothing, oXmlProperty, oNewItem
			End If
		End With	
		' Обновим данные
		SetDataEx oXmlProperty
	End Sub
	
	
	'==========================================================================
	' Стандартный обработчик события "Create"
	' [in] oSender - экземпляр XPEObjectPresentationClass, источник события
	' [in] oEventArgs - экземпляр OpenEditorEventArgsClass, параметры события
	' Данный обработчик производит вызов редактора в режиме создания
	' нового объекта.
	Public Sub OnCreate(oSender, oEventArgs)
		Dim oXmlProperty	' xml-свойство
		Dim oNewObject		' Новый объект-значение
		
		With oEventArgs
			' начнем агрегированную транзакцию
			m_oPropertyEditorBase.ObjectEditor.Pool.BeginTransaction True
			Set oXmlProperty = XmlProperty
			' удалим объект-значение из свойства, если он там есть
			m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
			' создаим новый объект и поместим его в пул
			Set oNewObject = m_oPropertyEditorBase.ObjectEditor.Pool.CreateXmlObjectInPool(ValueObjectTypeName)
			' добавим этот новый объект-значение в свойство
			m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, oNewObject
			' откроем вложенный редактор с признаком EnlistInCurrentTransaction=True, т.о. этот редактор не будет создавать новой транзакции
			.ReturnValue  = m_oPropertyEditorBase.ObjectEditor.OpenEditor(oNewObject, Null, Null, .Metaname, True, oXmlProperty, Not .IsSeparateTransaction, True, .UrlArguments)
			If IsEmpty( .ReturnValue  ) Then
				' нажали отмену - откатим транзакцию
				m_oPropertyEditorBase.ObjectEditor.Pool.RollbackTransaction
			Else
				' нажали Ок - закомитим
				m_oPropertyEditorBase.ObjectEditor.Pool.CommitTransaction
				' Заносим в поле формы новое представление (oXmlProperty использовать уже нельзя)
				SetData
			End If		
		End With
	End Sub
	
	
	'==========================================================================
	' Стандартный обработчик события "Edit"
	' [in] oSender - экземпляр XPEObjectPresentationClass, источник события
	' [in] oEventArgs - экземпляр OpenEditorEventArgsClass, параметры события
	' Данный обработчик производит вызов редактора в режиме редактирования
	' нового объекта.
	Public Sub OnEdit(oSender, oEventArgs)
		Dim oXmlProperty	' xml-свойство
		
		With oEventArgs
			Set oXmlProperty = XmlProperty
			.ReturnValue = m_oPropertyEditorBase.ObjectEditor.OpenEditor(oXmlProperty.firstChild, Null, Null, .Metaname, False, oXmlProperty, Not .IsSeparateTransaction, False, .UrlArguments)
			If IsEmpty( .ReturnValue ) Then Exit Sub
			' oXmlProperty использовать уже нельзя
			SetData
		End With
	End Sub

	
	'==============================================================================
	' Стандартный обработчик события MarkDelete
	' [in] oSender - экземпляр XPEObjectPresentationClass, источник события
	' [in] oEventArgs - экземпляр DeleteEventArgsClass, параметры события
	' Данный обработчик запрашивает подтверждение у пользвателя, после чего выполняет
	' операцию пометки на удаления используя соотв. механизм пула.
	Public Sub OnMarkDelete(oSender, oEventArgs)
		Dim oXmlProperty	' xml-свойство
		
		oEventArgs.ReturnValue = False
		' если задан текст запроса пользователю, то сначала спросим
		If hasValue(oEventArgs.Prompt) Then
			If Not Confirm( oEventArgs.Prompt ) Then Exit Sub
		End If
		Set oXmlProperty = XmlProperty
		oEventArgs.ReturnValue = m_oPropertyEditorBase.ObjectEditor.MarkXmlObjectAsDeleted( oXmlProperty.firstChild, oXmlProperty )
		If oEventArgs.ReturnValue Then
			SetDataEx oXmlProperty
		End If
	End Sub

	
	'==============================================================================
	' Стандартный обработчик события UnLink
	' [in] oSender - экземпляр XPEObjectPresentationClass, источник события
	' [in] oEventArgs - экземпляр DeleteEventArgsClass, параметры события
	' Данный обработчик запрашивает подтверждение у пользвателя, после чего выполняет
	' операцию очистки значения объектного свойства используя соотв. механизм пула.
	Public Sub OnUnlink(oSender, oEventArgs)
		Dim oXmlProperty		' xml-свойство
		
		' если задан текст запроса пользователю, то сначала спросим
		If hasValue(oEventArgs.Prompt) Then
			If Not Confirm( oEventArgs.Prompt ) Then Exit Sub
		End If
		' ПРИМЕЧАНИЕ: RemoveRelation не использует транзации пула, поэтому можно безболезненно сохранять ссылку на XmlProperty
		Set oXmlProperty = XmlProperty
		
		If m_oPropertyEditorBase.DoUnlinkImplementation( oXmlProperty, oXmlProperty.firstChild  ) Then
			SetDataEx oXmlProperty
		End If
	End Sub
End Class
