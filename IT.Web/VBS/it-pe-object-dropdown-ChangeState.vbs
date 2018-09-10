Option Explicit

'==============================================================================
'	OBJECT-DROPDOWN (комбобокс) 
'==============================================================================
' События:
'	GetRestrictions (EventArgs: GetRestrictionsEventArgsClass)
'		возникает при заполнении списка данными с сервера
'	LoadList (EventArgs: LoadListEventArgsClass)
'		возникает при заполнении списка данными с сервера
'	Changing (EventArgs: ChangeEventArgsClass)
'		возникает в процессе изменения значения
'	Changed (EventArgs: ChangeEventArgsClass)
'		возникает после ищменения значения
Class PEObjectDropdownChangeStateClass
	Private m_bIsInitialized	' As Boolean - признак завершения инциализации редактора свойства
	Private m_oEditorPage		' As EditorPageClass
	Private m_oObjectEditor		' As ObjectEditorClass
	Private m_oHtmlElement		' As IHtmlElement	- ссылка на главный Html-элемент
	Private m_oPropertyMD		' As XMLDOMElement	- метаданные xml-свойства
	Private m_oEventEngine		' As EventEngineClass
	Private m_vPrevValue		' As Variant		- предыдущее значение комбобокса
	Private EVENTS				' As String - список событий страницы
	Private m_sXmlPropertyXPath	' As String - XPAth - Запрос для получения свойства в Pool'e
	Private m_sObjectType		' As String - Наименование типа объекта владельца свойства
	Private m_sObjectID			' As String - Идентификатор объекта владельца свойства
	Private m_sPropertyName		' As String - Наименование свойства
	Private m_sDropdownText		' As String - текст пустого значения
	Private m_sListMetaname		' As String - метанаименование списка для заполнения комбобокса
	
	Private m_bUseCache			' As Boolean - признак использования кэша при загрузке данных 
								'	с сервера (по умолчанию не используется)
	Private m_sCacheSalt		' As String - выражение на VBS, если указан то используется как 
								'	дополнительный ключ для наименования элемента кэша
	Private m_bHasMoreRows		' As Boolean - признак того, что в список значений на сервере был 
								'	ограничен условием MAXROWS
	Private m_oInitialValue		' начальное значение
	Private m_sInitialValueTitleStmt
	Private m_oInitialValueTitleElement	' HTML-элемент с текстовым представлением начального значения
	
	'==========================================================================
	' Конструктор
	Private Sub Class_Initialize
		Set m_oEventEngine = X_CreateEventEngine
		EVENTS = "GetRestrictions,LoadList,Changing,Changed"
		m_vPrevValue = Null
		m_bIsInitialized = False
	End Sub
	

	'==========================================================================
	' Возвращает экземпляр ObjectEditorClass - редактора,
	' в рамках которого работает данный редактор свойства
	Public Property Get ObjectEditor
		Set ObjectEditor = m_oObjectEditor
	End Property


	'==========================================================================
	' Возвращает экземпляр EditorPageClass - страницы редактора,
	' на которой размещается данный редактор свойства
	Public Property Get ParentPage
		Set ParentPage = m_oEditorPage
	End Property


	'==========================================================================
	' Инициализация редактора свойства.
	' см. IPropertyEditor::Init
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Set m_oEditorPage	= oEditorPage
		Set m_oObjectEditor = m_oEditorPage.ObjectEditor
		m_sObjectType		= oXmlProperty.parentNode.tagName
		m_sObjectID			= oXmlProperty.parentNode.getAttribute("oid")
		m_sPropertyName		= oXmlProperty.tagName
		m_sXmlPropertyXPath	= m_sObjectType & "[@oid='" & m_sObjectID & "']/" & m_sPropertyName
		Set m_oPropertyMD	= m_oObjectEditor.PropMD(oXmlProperty)
		Set m_oHtmlElement  = oHtmlElement
		' oInitialValueTitleElement - идентификатор из XSLT
		'Set m_oInitialValueTitleElement = document.all.items("oInitialValueTitleElement")
		' Статический биндинг обработчиков событий:
		m_oEventEngine.InitHandlers EVENTS, "usr_" & oXmlProperty.parentNode.tagName & "_" & oXmlProperty.tagName & "_ObjectDropDown_On"
		m_oEventEngine.InitHandlers EVENTS, "usr_" & oXmlProperty.parentNode.tagName & "_" & oXmlProperty.tagName & "_On"
		m_oEventEngine.InitHandlers EVENTS, "usr_" & oXmlProperty.tagName & "_ObjectDropDown_On"
		m_oEventEngine.InitHandlers EVENTS, "usr_ObjectDropDown_On"
		m_oEventEngine.InitHandlers "GetRestriction", "usr_PE_On"
		m_oEventEngine.AddHandlerForEvent "LoadList", Me, "OnLoadList"
		m_sDropdownText = m_oHtmlElement.getAttribute("EmptyValueText")
		m_sListMetaname = m_oHtmlElement.getAttribute("ListMetaname")
		m_sInitialValueTitleStmt = m_oHtmlElement.getAttribute("InitialValueTitleStmt")

		Set m_oInitialValue = Value
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: Метод вызывается при построении страницы редактора, после 
	'	инициализации всех PE на странице
	Public Sub FillData()
		ReloadInternal
	End Sub

	
	'==========================================================================
	' Загружает список, генерируя событие "GetRestrictions". 
	' Текущее значение xml-свойства проставляется в списке, если оно там есть. 
	' Если значения св-ва в списке нет, то св-во очищается и выделение в списке 
	'	сбрасывается на неопределенное значение - см. реализацию SetData
	Public Sub Load()
		ReloadInternal
		SetData
	End Sub
	
	
	'==========================================================================
	' Загружает список
	' Текущее значение xml-свойства проставляется в списке, если оно там есть. 
	' Если значения св-ва в списке нет, то св-во очищается и выделение в списке 
	'	сбрасывается на неопределенное значение - см. реализацию SetData
	Public Sub ReLoad()
		ReloadInternal
		SetData
	End Sub

	
	'==========================================================================
	' Перезагружает список, генерируя событие "GetRestrictions". 
	Private Sub ReloadInternal( )
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass - Параметры события "GetRestrictions"
		Dim vVal					' As String - значение свойства
		
		' Получаем ограничения - генерируем событие GetRestrictions
		Set oSelectorRestrictions = new GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions

		' Перегружаем данные списка - генерируем событие LoadList
		With New LoadListEventArgsClass
			.TypeName = ValueObjectTypeName
			.ListMetaname = m_sListMetaname
			Set .Restrictions = oSelectorRestrictions
			FireEvent "LoadList", .Self()
			m_bHasMoreRows = .HasMoreRows
		End With
	End Sub
	

	'==========================================================================
	' Стандартный обработчик события "LoadList"
	' Очищает и потом заполняет список
	' Сбрасывает активный элемент на неопределенное значение (с индексом -1)
	'	[in] oEventArgs As LoadListEventArgsClass
	Public Sub OnLoadList(oSender, oEventArgs)
		Dim sUrlParams			' параметры в страницу загрузчик списка
		Dim sRestrictions		' параметры в список от юзерских обработчиков
		Dim aErr				' As Array - поля объекта Err
		
		With oEventArgs
			' Получим ограничения
			If Not IsNothing(.Restrictions) Then
				sUrlParams = .Restrictions.UrlParams
				sRestrictions =  .Restrictions.ReturnValue
			End If
			' сначала очистим значение
			ClearComboBox
			' Загрузим список (кодирование и анализ параметров делаются в X_Load*ComboBox)
			On Error Resume Next
			' перегрузим комбобокс
			.HasMoreRows = X_LoadComboBox(m_oHtmlElement, .TypeName, .ListMetaname, sRestrictions, .RequiredValues)
			If Err Then
				X_SetLastServerError XService.LastServerError, Err.number, Err.Source, Err.Description
				With X_GetLastError
					If .IsServerError Then
						On Error Goto 0
						' на сервере произошла ошибка
						If .IsSecurityException Then
							' произошла ошибка при чтении объектов
							ClearComboBox
							Enabled = False
						Else
							.Show
						End If
					Else
						' ошибка произошла на клиенте - это ошибка в XFW
						aErr = Array(Err.Number, Err.Source, Err.Description)
						On Error Goto 0
						Err.Raise aErr(0), aErr(1), aErr(2)				
					End If
				End With
			End If
		End With
	End Sub

	
	'==========================================================================
	' Возвращает Xml-свойство
	' Подробнее см. IPropertyEditor::XmlProperty
	Public Property Get XmlProperty
		Set XmlProperty = m_oObjectEditor.XmlObjectPool.selectSingleNode( m_sXmlPropertyXPath )
		If XmlProperty Is Nothing Then
			Set XmlProperty = m_oObjectEditor.Pool.GetXmlObject(m_sObjectType, m_sObjectID, Null).SelectSingleNode(m_sPropertyName)
		End If
		If XmlProperty Is Nothing Then _
			Err.Raise -1, "XPropertyEditorBaseClass::XmlProperty", "Не найдено свойство " & PropertyName & " в xml-объекте"
		If Not IsNull(XmlProperty.getAttribute("loaded")) Then
			Set XmlProperty = m_oObjectEditor.LoadXmlProperty( Nothing, XmlProperty)
		End If		
	End Property
	
	
	'==========================================================================
	' Возвращает xml-объект начальное значениe xml-свойства. 
	Public Property Get InitialValue
		Set InitialValue = m_oInitialValue
	End Property
	

	'==========================================================================
	' Возвращает xml-объект начальное значениe xml-свойства. 
	Public Property Get InitialValueID
		If Not m_oInitialValue Is Nothing Then
			InitialValueID = m_oInitialValue.getAttribute("oid")
		Else
			InitialValueID = Null
		End If
	End Property
	

	'==========================================================================
	' Возвращает xml-объект-значениe xml-свойства. Если объектная ссылка пустая
	' возвращает Nothing
	Public Property Get Value
		Dim oXmlProperty		' As IXMLDOMElement - текущее свойство
		
		Set oXmlProperty = XmlProperty
		If oXmlProperty.FirstChild Is Nothing Then
			Set Value = Nothing
		Else	
			' Загружен объект-значение
			Set Value = m_oObjectEditor.Pool.GetXmlObjectByXmlElement( oXmlProperty.FirstChild, Null )
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
			m_oObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
		End If
		' установим значение свойства
		If Not IsNothing(oObject) Then
			m_oObjectEditor.Pool.AddRelation Nothing, oXmlProperty, oObject
		End If
		' установим значение в комбобоксе
		SetData
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
	' Устанавливает значение свойства и значение комбобокса по идентификатору объекта значения
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
	' Возвращает первый непустой идентификатор из списка доступных
	Public Property Get FirstNonEmptyValueID
		Dim sValue	' Значение
		Dim i
		
		For i=0 To m_oHtmlElement.Options.Length-1
			sValue = m_oHtmlElement.Options.Item(i).value
			If HasValue(sValue) Then
				FirstNonEmptyValueID = sValue
				Exit Property
			End If
		Next
	End Property


	'==========================================================================
	' Возвращает наименование типа объекта значения свойства
	' Подробнее см. IObjectPropertyEditor::ValueObjectTypeName 
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyMD.GetAttribute("ot")
	End Property
		

	'==========================================================================
	' Возвращает текущее значение ComboBox'a. Если выбрана пустая строка, то возвращается Null
	Private Property Get ComboboxValue
		Dim vValue
		vValue = m_oHtmlElement.Value
		If Len(vValue)>0 Then
			ComboboxValue = vValue
		Else
			ComboboxValue = Null
		End If
	End Property
	
	
	'==========================================================================
	' Добавляет элемент в выпадающий список
	'	[in] vVal - значение, соответствующее элементу
	'	[in] sLabel - текст элемента
	Public Sub AddComboBoxItem( vVal, sLabel)
		X_AddComboBoxItem m_oHtmlElement, vVal, sLabel
	End Sub
	
	
	'==========================================================================
	' Устанавливает активный пункт с заданным значением. Свойство при этом не изменяется!
	'	[in]		vVal - значение, соответствующее элементу
	'   [retval]	индек пункта селектора или -1
	Private Function SetComboBoxValue(vVal)
		SetComboBoxValue = X_SetComboBoxValue( m_oHtmlElement, vVal )
	End Function


	'==========================================================================
	' Устанавливает значение в комбобоксе
	' см. IPropertyEditor::SetData	
	Public Sub SetData
		Dim vVal		' значение свойства
		
		InitialValueTitleElement.value = ObjectEditor.ExecuteStatement( m_oInitialValue, m_sInitialValueTitleStmt )
		vVal = ValueID
		If vVal = InitialValueID Then
			HtmlElement.selectedIndex = 0
		ElseIf SetComboBoxValue(vVal) > -1 Or IsNull(vVal) Then
			m_vPrevValue = vVal
		Else
			If m_bHasMoreRows Then
				m_oEditorPage.EnablePropertyEditor Me, False
				MsgBox _
					"Внимание! Значение реквизита """ & PropertyDescription & """ " & _
					"не может быть отображено корректно, так как полученный список " & _
					"значений ограничен условием на максимальное количество строк.", _
					vbExclamation, "Внимание - невозможно отобразть данные"
			Else
				' в загруженном списке нет значения свойства - очистим свойство;
				' При этом предупредим пользователя о том, что ранее выбранное 
				' значение "исчезло" из возможных:
				MsgBox _
					"Внимание! Выбранное ранее значение реквизита """ & PropertyDescription & """ более не существует; возможно, оно было" & vbCrLf & _
					"удалено или изменено другим пользователем. Значение свойства будет сброшено." & vbCrLf & _
					"Пожалуйста, выберите новое значение.", _
					vbExclamation, "Внимание - изменение данных"
				ValueID = Null
			End If
		End If
		
		' Первый вызов SetData (по идее, это вызов из редактора при инициализации
		' свойства) заверщить процесс инициализации PE
		m_bIsInitialized = True
	End Sub
	
	
	'==========================================================================
	' Проверка и сбор данных
	' Подробнее см. IPropertyEditor::GetDataArgsClass
	Public Sub GetData(oGetDataArgs)
		' сбор данных происходит непосредственно при выборе значения
		' Однако, если текущее значение не отличается от начального, то сбросим признак модифицированного св-ва, 
		' т.к. по сути оно не изменилось
		If ValueID = InitialValueID Then
			XmlProperty.removeAttribute "dirty"
		End If
	End Sub
	
	
	'==========================================================================
	' Очищает комбобокс и сбрасывает значение свойства в Null
	Public Sub Clear
		ClearComboBox
		ValueID = Null
	End Sub

	
	'==========================================================================
	' Очищает все значения комбобокса. Значение свойства при этом не меняется!
	' При необходимости добавляется пустое значение (возможнос с текстом)
	Public Sub ClearComboBox
		' пустое значение должно быть
		m_oHtmlElement.innerHTML = ""
		X_AddComboBoxItem m_oHtmlElement, Empty, m_sDropdownText
	End Sub

	
	'==========================================================================
	' Возвращает признак (не)обязательности свойства
	' Подробнее см. IPropertyEditor::Mandatory
	Public Property Get Mandatory
		Mandatory = IsNull( m_oHtmlElement.GetAttribute("X_MAYBENULL"))
	End Property

	'==========================================================================
	' Установка (не)обязательности
	' Подробнее см. IPropertyEditor::Mandatory
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			m_oHtmlElement.removeAttribute "X_MAYBENULL"
			m_oHtmlElement.className = "x-editor-control-notnull x-editor-dropdown"
		Else
			m_oHtmlElement.setAttribute "X_MAYBENULL", "YES"
			m_oHtmlElement.className = "x-editor-control x-editor-dropdown"
		End If			
	End Property
	

	'==========================================================================
	' Получение (не)доступности
	' Подробнее см. IPropertyEditor::Enabled
	Public Property Get Enabled
		 Enabled = Not (m_oHtmlElement.disabled)
	End Property

	'==========================================================================
	' Установка (не)доступности
	' Подробнее см. IPropertyEditor::Enabled
	Public Property Let Enabled(bEnabled)
		 m_oHtmlElement.disabled = Not( bEnabled )
	End Property
	
	
	'==========================================================================
	' Установка фокуса
	' Подробнее см. IPropertyEditor::SetFocus
	Public Function SetFocus
		SetFocus = X_SafeFocus( m_oHtmlElement )
	End Function
	
	
	'==========================================================================
	' Получение основного HTML-элемента редактора свойства
	' Подробнее см. IPropertyEditor::HtmlElement
	Public Property Get HtmlElement
		Set HtmlElement = m_oHtmlElement
	End Property

	
	'==========================================================================
	' Возвращает контрол inputbox'a с начальным состоянием
	Public Property Get InitialValueTitleElement
		Set InitialValueTitleElement = document.all.item("oInitialValueTitleElement")
	End Property


	'==========================================================================
	' Разрыв связей с другими объектами
	' Подробнее см. IDisposable::Dispose
	Public Sub Dispose
		Set m_oObjectEditor = Nothing
		Set m_oEditorPage = Nothing
	End Sub	

	
	'==========================================================================
	' Обработчик Html события OnChange. Для внутренного использования!
	Public Sub Internal_OnChange
		If m_bIsInitialized Then
			With New ChangeEventArgsClass
				.OldValue = m_vPrevValue
				.NewValue = ComboboxValue
				.ReturnValue = True
				FireEvent "Changing", .Self()
				If Not .ReturnValue Then
					' если в обработчике выставили флаг, то вернем предыдушее значение и прервем обработку
					SetComboBoxValue m_vPrevValue
					Exit Sub
				End If
				Internal_ValueChange ComboboxValue
				FireEvent "Changed", .Self()
			End With
		End if
	End Sub
	
	
	'==========================================================================
	' Обработка изменения значения комбобокса - занесение значения в Xml
	Private Sub Internal_ValueChange(vSelectedValue)
		Dim vValue			' значение свойства
		Dim oXmlProperty	' xml-свойство
		
		Set oXmlProperty = XmlProperty
		With m_oObjectEditor.Pool
			.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
			If IsNull(vSelectedValue) Then 
				' Выбрано пустое значение - значит требуется оставить значение свойства без изменений
				If IsNull(ValueID) Then
					.AddRelation Nothing, oXmlProperty, InitialValue
					oXmlProperty.removeAttribute "dirty"
				End If
			Else
				.AddRelation Nothing, oXmlProperty, X_CreateObjectStub(ValueObjectTypeName, vSelectedValue)
			End If
		End With
	End Sub
	
	
	'==========================================================================
	' Возвращает описание свойства
	' Подробнее см. IPropertyEditor::PropertyDescription
	Public Property Get PropertyDescription
		PropertyDescription = m_oHtmlElement.GetAttribute("X_DESCR")
	End Property

	
	'==========================================================================
	' Возбуждает событие
	' [in] sEventName - наименование события
	' [in] oEventArgs - экземпляр потомка EventArgsClass, события
	' Вызывает одноименный метод EventEngine, передавая ему в качестве
	' источника ссылку на себя 
	Private Sub FireEvent(sEventName, oEventArgs)
	    XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub	
	
	
	'==========================================================================
	' Возвращает/устанавливает текст пустого значения
	' см. i:object-dropdown
	Public Property Get DropdownText
		DropdownText = m_sDropdownText
	End Property
	Public Property Let DropdownText(vValue)
		m_sDropdownText = vValue
	End Property
End Class