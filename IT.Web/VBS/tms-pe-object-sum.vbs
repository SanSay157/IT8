Option Explicit

'==============================================================================
'	Скалаярное объектное свойство типа "Сумма"
'==============================================================================
' События (в скобках наименования класса параметров события):
'	MenuBeforeShow  - перед показом меню (MenuEventArgs)
'	ShowMenu		- показ меню (MenuEventArgs). Есть стандартный обработчик
'	BeforeCreate	- перед созданием объекта (EventArgsClass, если создается объект суммы; OpenEditorEventArgs, если создается объект валюты). 
'	Create			- создание объекта (EventArgsClass, если создается объект суммы; OpenEditorEventArgs, если создается объект валюты). Есть стандартный обработчик
'	AfterCreate		- после создания объекта (EventArgsClass, если создается объект суммы; OpenEditorEventArgs, если создается объект валюты).
' Команда DoEdit:
'	BeforeEdit		- перед редактирование объекта (OpenEditorEventArgs). Если ReturnValue=False, цепочка событий прерывается
'	Edit			- редактирование объекта (OpenEditorEventArgs). Есть стандартный обработчик
'	AfterEdit		- после редактирования объекта (OpenEditorEventArgs).
'	BeforeMarkDelete- перед пометкой объекта как удаленного (EventArgsClass)
'	MarkDelete		- помечание объекта как удаленного (EventArgsClass). Есть стандартный обработчик
'	AfterMarkDelete	- после пометки объекта как удаленного (EventArgsClass)
'	BeforeLink		- перед добавлением объекта в свойство (EventArgsClass).
'	Link			- добавление объекта в свойство (EventArgsClass). Есть стандартный обработчик
'	AfterLink		- после добавления объекта в свойство (EventArgsClass).
'	BeforeUnlink	- перед очисткой свойства (EventArgsClass). Если ReturnValue=False, цепочка событий прерывается
'	Unlink			- очистка свойства (EventArgsClass). Есть стандартный обработчик
'	AfterUnlink		- после очистки свойства (EventArgsClass).
Class PEObjectSumClass
	Private EVENTS						' список событий
	Private m_oPropertyEditorBase		' As XPropertyEditorObjectBaseClass
	Private m_oSumValuePropertyEditor	' As XPENumberClass
	Private m_oCurrencyPropertyEditor	' As XPEObjectDropdownClass
	Private m_oExchangePropertyEditor	' As XPENumberClass
	Private m_oFocusedPropertyEditor
	Private m_bCreateTempValue			' As Boolean - создавался временный объект-значение свойства
	Private m_sTempValueID				' As Guid - идентификатор временного объекта
	Private m_oMenu						' As MenuClass		- меню операций
	
	'==========================================================================
	' Конструктор
	Private Sub Class_Initialize
		EVENTS = "MenuBeforeShow,ShowMenu," & _
			"BeforeEdit,Edit,AfterEdit," & _
			"BeforeCreate,Create,AfterCreate," & _
			"BeforeMarkDelete,MarkDelete,AfterMarkDelete," & _
			"BeforeLink,Link,AfterLink," & _
			"BeforeUnlink,Unlink,AfterUnlink"			
	End Sub

	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim oMenuMD				' метаданные меню (i:menu)
		Dim oTempValue			' временный объект-значение

		Set m_oMenu = New MenuClass
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectSum"
		
		Set m_oFocusedPropertyEditor = Me
		
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Create", Me, "OnCreate"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Link", Me, "OnLink"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Unlink", Me, "OnUnlink"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "MarkDelete", Me, "OnMarkDelete"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Edit", Me, "OnEdit"
      
		' Инициализируем меню: получим его метаданные, (используя атрибут MetadataLocator найдем i:object-presentation), добавим стандартные обработчики 
		Set oMenuMD = m_oPropertyEditorBase.PropertyEditorMD.selectSingleNode( "i:prop-menu/i:menu")
		If Not oMenuMD Is Nothing Then
			m_oMenu.AddMacrosResolver X_CreateDelegate(Me, "Internal_MenuMacrosResolver") 
			m_oMenu.AddVisibilityHandler X_CreateDelegate(Me, "Internal_MenuVisibilityHandler")
			m_oMenu.AddExecutionHandler X_CreateDelegate(Me, "Internal_MenuExecutionHandler") 
			m_oMenu.Init oMenuMD
		End If
		
		' Если объект-значение свойства еще не создан, то создадим временный
		Set oTempValue = Value
		If oTempValue Is Nothing Then
			DoCreate()
			m_bCreateTempValue = True
			Set oTempValue = TempValue()
		Else
			m_bCreateTempValue = False
			m_sTempValueID = oTempValue.getAttribute("oid")
		End If

		Set m_oSumValuePropertyEditor = New XPENumberClass
		m_oSumValuePropertyEditor.Init ParentPage, GetSumValueXmlProperty(oTempValue), SumValueHtmlElement
		
		Set m_oCurrencyPropertyEditor = New XPEObjectDropdownClass
		m_oCurrencyPropertyEditor.Init ParentPage, GetCurrencyXmlProperty(oTempValue), CurrencyHtmlElement

		Set m_oExchangePropertyEditor = New XPENumberClass
		m_oExchangePropertyEditor.Init ParentPage, GetExchangeXmlProperty(oTempValue), ExchangeHtmlElement
	End Sub


	'==========================================================================
	' IPropertyEdior: Метод вызывается при построении страницы редактора, после инициализации всех PE на странице
	Public Sub FillData()
		CurrencyPropertyEditor.FillData				
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
	' Возвращает экземпляр EventEngineClass - объекта, поддерживающего
	' событийную модель для данного редактора свойства
	Public Property Get EventEngine
		Set EventEngine = m_oPropertyEditorBase.EventEngine
	End Property


	'==========================================================================
	' Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property


	'==========================================================================
	' Возвращает Xml-свойство значения суммы
	Public Property Get SumValueXmlProperty
		SumValueXmlProperty = SumValueXmlPropertyEx(Value)
	End Property
	
	'==========================================================================
	' Возвращает Xml-свойство значения суммы по Xml-свойству объекта суммы
	' Используется для оптимизации, т.к. не получает Value стандартным механизмом
	Private Function GetSumValueXmlProperty(oValue)
		If oValue Is Nothing Then
			Set GetSumValueXmlProperty = Nothing
		Else	
			Set GetSumValueXmlProperty = oValue.selectSingleNode("SumValue")
		End If
	End Function
	

	'==========================================================================
	' Возвращает Xml-свойство валюты
	Public Property Get CurrencyXmlProperty
		SumValueXmlProperty = SumValueXmlPropertyEx(Value)
	End Property
	
	'==========================================================================
	' Возвращает Xml-свойство валюты по Xml-свойству объекта суммы
	' Используется для оптимизации, т.к. не получает Value стандартным механизмом
	Private Function GetCurrencyXmlProperty(oValue)
		If oValue Is Nothing Then
			Set GetCurrencyXmlProperty = Nothing
		Else	
			Set GetCurrencyXmlProperty = oValue.selectSingleNode("Currency")
		End If
	End Function
	

	'==========================================================================
	' Возвращает Xml-свойство значения курса перевода
	Public Property Get ExchangeXmlProperty
		ExchangeXmlProperty = ExchangeXmlPropertyEx(Value)
	End Property
	
	'==========================================================================
	' Возвращает Xml-свойство значения курса перевода по Xml-свойству объекта суммы
	' Используется для оптимизации, т.к. не получает Value стандартным механизмом
	Private Function GetExchangeXmlProperty(oValue)
		If oValue Is Nothing Then
			Set GetExchangeXmlProperty = Nothing
		Else	
			Set GetExchangeXmlProperty = oValue.selectSingleNode("ExchangeRate")
		End If
	End Function
	

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
	' Возвращает временный xml-объект-значениe xml-свойства. Если временный
	' объект не создавался, возвращает Value
	Public Property Get TempValue
		Set TempValue = m_oPropertyEditorBase.ObjectEditor.Pool.GetXmlObject(ValueObjectTypeName, TempValueID, Nothing)
	End Property

	'==========================================================================
	' Возвращает идентификатор временного объекта-значения xml-свойства
	' Если свойство пустое возвращает Null
	Public Property Get TempValueID
		TempValueID = m_sTempValueID
	End Property	 


	'==========================================================================
	' Устанавливает значение в редакторе свойства
	Public Sub SetData
		SumValuePropertyEditor.SetData
		CurrencyPropertyEditor.SetData
		ExchangePropertyEditor.SetData
	End Sub


	'==========================================================================
	' Сбор и валидация данных
	Public Sub GetData(oGetDataArgs)
		Dim oSumValuePropertyEditor 'редактор свойства Sum объекта типа "Сумма"
		Dim oCurrencyPropertyEditor 'редактор свойства Currency объекта типа "Сумма"
		Dim oExchangePropertyEditor 'редактор свойства Exchange объекта типа "Сумма"
		Dim bHasSomeData 'логический признак проверки, что задано значение хотя бы одного из трех выше указанных свойств
		
		' закэшируем ссылки на редакторы к локальные переменные
		Set oSumValuePropertyEditor = SumValuePropertyEditor
		Set oCurrencyPropertyEditor = CurrencyPropertyEditor
		Set oExchangePropertyEditor = ExchangePropertyEditor
				
		' собираем данные из редактора суммы
		oSumValuePropertyEditor.GetData oGetDataArgs
		If Not oGetDataArgs.ReturnValue Then
			Set m_oFocusedPropertyEditor = oSumValuePropertyEditor
			Exit Sub		
		End If
		' собираем данные из редактора валюты
		oCurrencyPropertyEditor.GetData oGetDataArgs
		If Not oGetDataArgs.ReturnValue Then
			Set m_oFocusedPropertyEditor = oCurrencyPropertyEditor
			Exit Sub		
		End If
		' собираем данные из редактора курса обмена
		oExchangePropertyEditor.GetData oGetDataArgs
		If Not oGetDataArgs.ReturnValue Then
			Set m_oFocusedPropertyEditor = oExchangePropertyEditor
			Exit Sub		
		End If

		Set m_oFocusedPropertyEditor = Me

		bHasSomeData = HasSomeDataEx(oSumValuePropertyEditor, oCurrencyPropertyEditor, oExchangePropertyEditor)
		
		' если хотя бы одно поле заполнено
		If bHasSomeData Then
			' проверяем, что задано значение суммы
			If Not hasValue(oSumValuePropertyEditor.Value) Then
				oGetDataArgs.ReturnValue = False
				oGetDataArgs.ErrorMessage = "Для свойства """ & PropertyDescription & """ не задано значение суммы." & vbNewLine & "Вы должны ввести значение суммы либо очистить все реквизиты данного свойства."
				Set m_oFocusedPropertyEditor = oSumValuePropertyEditor
				Exit Sub
			End If

			' проверяем, что задана валюта
			If Not hasValue(oCurrencyPropertyEditor.Value) Then
				oGetDataArgs.ReturnValue = False
				oGetDataArgs.ErrorMessage = "Для свойства """ & PropertyDescription & """ не задана валюта." & vbNewLine & "Вы должны ввести код валюты либо очистить все реквизиты данного свойства."
				Set m_oFocusedPropertyEditor = oCurrencyPropertyEditor
				Exit Sub
			End If

			DoLink()
		End If
		
		' если ни одно поле не заполнено
		If Not bHasSomeData Then
			DoUnlink()
		End If 

		' проверим обязательность свойства
		ValueCheckOnNullForPropertyEditor Value, Me, oGetDataArgs, Mandatory
	End Sub

	
	'==========================================================================
	' Проверяет, что хотя бы одно поле заполнено
	Public Function HasSomeData()
		HasSomeData = HasSomeDataEx( _
			SumValuePropertyEditor, _
			CurrencyPropertyEditor, _
			ExchangePropertyEditor)
	End Function

	'==========================================================================
	' Проверяет, что хотя бы одно поле заполнено
	Public Function HasSomeDataEx(oSumValuePropertyEditor, oCurrencyPropertyEditor, oExchangePropertyEditor)
		HasSomeDataEx = hasValue(oSumValuePropertyEditor.Value) _
			Or hasValue(oCurrencyPropertyEditor.Value) _
			Or hasValue(oExchangePropertyEditor.Value)
	End Function


	'==========================================================================
	' Устанавливает/возвращает (не)обязательность свойства
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If (bMandatory) Then
			HtmlElement.removeAttribute "X_MAYBENULL"
			
			SumValueHtmlElement.removeAttribute "X_MAYBENULL"
			SumValueHtmlElement.className = "x-editor-control-notnull x-editor-numeric-field"

			CurrencyHtmlElement.removeAttribute "X_MAYBENULL"
			CurrencyHtmlElement.className = "x-editor-control-notnull x-editor-dropdown"
		Else	
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
			
			SumValueHtmlElement.setAttribute "X_MAYBENULL", "YES"
			SumValueHtmlElement.className = "x-editor-control x-editor-numeric-field"
			
			CurrencyHtmlElement.setAttribute "X_MAYBENULL", "YES"
			CurrencyHtmlElement.className = "x-editor-control x-editor-dropdown"
		End If
	End Property
	

	'==========================================================================
	' Устанавливает/возвращает (не)доступность редактора свойства
	Public Property Get Enabled
		Enabled = Not (HtmlElement.disabled)
	End Property
	Public Property Let Enabled(bEnabled)
		 HtmlElement.disabled = Not( bEnabled )
		 SumValueHtmlElement.disabled = Not( bEnabled )
		 CurrencyHtmlElement.disabled = Not( bEnabled )
		 ExchangeHtmlElement.disabled = Not( bEnabled )
	End Property


	'==========================================================================
	' Установка фокуса
	Public Function SetFocus
		If m_oFocusedPropertyEditor Is Nothing Or _
		   m_oFocusedPropertyEditor Is Me Then
			SetFocus = X_SafeFocus( HtmlElement )
		Else
			SetFocus = m_oFocusedPropertyEditor.SetFocus()
		End If
	End Function


	'==========================================================================
	' Возвращает Html контрол
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property


	'==========================================================================
	' Возвращает Html элемент текстового поля ввода суммы
	Public Property Get SumValueHtmlElement
		Set SumValueHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all(HtmlElement.GetAttribute("SumValueID"), 0)
	End Property


	'==========================================================================
	' Возвращает Html элемент выпадаюшего списка валют
	Public Property Get CurrencyHtmlElement
		Set CurrencyHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all(HtmlElement.GetAttribute("CurrencyID"), 0)
	End Property


	'==========================================================================
	' Возвращает Html элемент текстового поля ввода курса перевода
	Public Property Get ExchangeHtmlElement
		Set ExchangeHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all(HtmlElement.GetAttribute("ExchangeID"), 0)
	End Property

	'==========================================================================
	' Создает временный объект, если он отсутствует в пуле
	Private Sub DoCreateIfNotExists()
		Dim sTempObjectXPath 'XPath -запрос, по которому ищется объект в пуле
		Dim oTempObject 'временный объект
		
		sTempObjectXPath = ValueObjectTypeName & "[@oid='" & TempValueID & "']"
		Set oTempObject = m_oPropertyEditorBase.ObjectEditor.XmlObjectPool.selectSingleNode(sTempObjectXPath)
		If oTempObject Is Nothing Then
			DoCreate()
		End If		
	End Sub
	
	'==========================================================================
	' Возвращает редактор значения суммы
	Public Property Get SumValuePropertyEditor
		DoCreateIfNotExists()
		Set SumValuePropertyEditor = m_oSumValuePropertyEditor
	End Property


	'==========================================================================
	' Возвращает редактор объектного свойства валюты
	Public Property Get CurrencyPropertyEditor
		DoCreateIfNotExists()
		Set CurrencyPropertyEditor = m_oCurrencyPropertyEditor
	End Property


	'==========================================================================
	' Возвращает редактор значения курса переводы
	Public Property Get ExchangePropertyEditor
		DoCreateIfNotExists()
		Set ExchangePropertyEditor = m_oExchangePropertyEditor
	End Property


	'==========================================================================
	' Возвращает описание свойства
	' Подробнее см. IPropertyEditor::PropertyDescription
	Public Property Get PropertyDescription
		PropertyDescription = m_oPropertyEditorBase.PropertyDescription
	End Property	


	'==========================================================================
	' Возвращает наименование типа объекта значения свойства
	' Подробнее см. IObjectPropertyEditor::ValueObjectTypeName 
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyEditorBase.ValueObjectTypeName
	End Property


	'==========================================================================
	' IDisposable: подчистка ссылок
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
		Set m_oPropertyEditorBase = Nothing
		
		m_oSumValuePropertyEditor.Dispose
		Set m_oSumValuePropertyEditor = Nothing
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
	Public Sub DoCreate()
		With New EventArgsClass
			FireEvent "BeforeCreate", .Self()
			FireEvent "Create", .Self()
			FireEvent "AfterCreate", .Self()
		End With
	End Sub

	'==========================================================================
	Public Sub DoLink()
		If XmlProperty.selectSingleNode(ValueObjectTypeName) Is Nothing Then
			With New EventArgsClass
				FireEvent "BeforeLink", .Self()
				FireEvent "Link", .Self()
				FireEvent "AfterLink", .Self()
			End With
		End If
	End Sub

	'==========================================================================
	Public Sub DoUnlink()
		With New EventArgsClass
			If Not XmlProperty.selectSingleNode(ValueObjectTypeName) Is Nothing Then
				FireEvent "BeforeUnlink", .Self()
				FireEvent "Unlink", .Self()
				FireEvent "AfterUnlink", .Self()
			End If

			FireEvent "BeforeMarkDelete", .Self()
			FireEvent "MarkDelete", .Self()
			FireEvent "AfterMarkDelete", .Self()
		End With
	End Sub


	'==========================================================================
	'	[in] oValues	- коллекция параметров операции меню
	Public Sub DoCreateCurrency(oValues)
		With New OpenEditorEventArgsClass
			Set .OperationValues = oValues
			.Metaname = CurrencyHtmlElement.GetAttribute("EditorMetanameForCreating")
			If Not hasValue(.Metaname) And .OperationValues.Exists("Metaname") Then
				.Metaname = .OperationValues.Item("Metaname")
			End If
			.IsSeparateTransaction = False
			If .OperationValues.Exists("UrlParams") Then
				.UrlArguments = .OperationValues.Item("UrlParams")
			End If
			.ReturnValue = True
			FireEvent "BeforeCreate", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "Create", .Self()
			FireEvent "AfterCreate", .Self()
		End With
	End Sub


	'==========================================================================
	' Стандартный обработчик события "Create"
	' [in] oSender - экземпляр PEObjectSumClass, источник события
	' [in] oEventArgs - экземпляр EventArgsClass, параметры события
	Public Sub OnCreate(oSender, oEventArgs)
		Dim oTempValue		' временный объект-значение
		Dim oXmlProperty	' xml-свойство
		Dim oNewObject		' Новый объект-значение
	
		' Если мы создаем объект суммы
		If TypeName(oEventArgs) <> "OpenEditorEventArgsClass" Then
			Set oTempValue = m_oPropertyEditorBase.ObjectEditor.Pool.CreateXmlObjectInPool(ValueObjectTypeName)
			oTempValue.removeAttribute "new"
			oTempValue.removeAttribute "transaction-id"
			If Not hasValue(m_sTempValueID) Then
				' если идентификатор временного объекта еще не определен, запоминаем его
				m_sTempValueID = oTempValue.getAttribute("oid")
			Else
				' если идентификатор временного объект уже был определен, то
				' установим его для вновь созданного объекта
				' ЗАМЕЧАНИЕ. Такое может быть возможно при использовании
				' RollbackTransaction в пуле (например, в мастере с
				'  wizard-mode = "undo-chenges")
				oTempValue.setAttribute "oid", m_sTempValueID
			End If
			m_bCreateTempValue = True
		
		' Если мы создаем новую валюту
		Else
			' закэшируем временный объект-значение
			Set oTempValue = TempValue()
			' начнем агрегированную транзакцию
			m_oPropertyEditorBase.ObjectEditor.Pool.BeginTransaction True
			Set oXmlProperty = oTempValue.selectSingleNode("Currency")
			' удалим объект-значение из свойства, если он там есть
			m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
			' создаим новый объект и поместим его в пул
			Set oNewObject = m_oPropertyEditorBase.ObjectEditor.Pool.CreateXmlObjectInPool("Currency")
			' добавим этот новый объект-значение в свойство
			m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation oTempValue, oXmlProperty, oNewObject
			' откроем вложенный редактор с признаком EnlistInCurrentTransaction=True, т.о. этот редактор не будет создавать новой транзакции
			oEventArgs.ReturnValue  = m_oPropertyEditorBase.ObjectEditor.OpenEditor(oNewObject, Null, Null, oEventArgs.Metaname, True, oXmlProperty, True, True, oEventArgs.UrlArguments)
			If IsEmpty( oEventArgs.ReturnValue ) Then
				' нажали отмену - откатим транзакцию
				m_oPropertyEditorBase.ObjectEditor.Pool.RollbackTransaction
			Else
				' нажали Ок - закомитим
				m_oPropertyEditorBase.ObjectEditor.Pool.CommitTransaction

				' добавим значение в выпадающий список
				CurrencyPropertyEditor.AddComboBoxItem oNewObject.getAttribute("oid"), oNewObject.selectSingleNode("Code").nodeTypedValue
				' выберем вновь созданную валюту
				Set CurrencyPropertyEditor.Value = oNewObject
				' привяжем значение объектного свойства к самого свойству
				DoLink()
			End If
		End If
	End Sub
	
	'==========================================================================
	' Стандартный обработчик события "Link"
	' [in] oSender - экземпляр PEObjectSumClass, источник события
	' [in] oEventArgs - экземпляр EventArgsClass, параметры события
	Public Sub OnLink(oSender, oEventArgs)
		Dim oTempValue		' временный объект-значение

		' закэшируем временный объект-значение
		Set oTempValue = TempValue()

		m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, XmlProperty, oTempValue
		If m_bCreateTempValue Then
			oTempValue.setAttribute "new", "1"
			oTempValue.setAttribute "transaction-id", m_oPropertyEditorBase.ObjectEditor.Pool.TransactionID
		Else
			oTempValue.removeAttribute "delete"
		End If
	End Sub

	'==========================================================================
	' Стандартный обработчик события "UnLink"
	' [in] oSender - экземпляр PEObjectSumClass, источник события
	' [in] oEventArgs - экземпляр EventArgsClass, параметры события
	Public Sub OnUnlink(oSender, oEventArgs)
		m_oPropertyEditorBase.ObjectEditor.Pool.RemoveAllRelations Nothing, XmlProperty
	End Sub
	
	'==========================================================================
	' Стандартный обработчик события "MarkDelete"
	' [in] oSender - экземпляр PEObjectSumClass, источник события
	' [in] oEventArgs - экземпляр EventArgsClass, параметры события
	Public Sub OnMarkDelete(oSender, oEventArgs)
		Dim oTempValue		' временный объект-значение

		' закэшируем временный объект-значение
		Set oTempValue = TempValue()

		If m_bCreateTempValue Then
			oTempValue.removeAttribute "new"
			oTempValue.removeAttribute "transaction-id"
		Else
			m_oPropertyEditorBase.ObjectEditor.MarkXmlObjectAsDeleted  oTempValue, Nothing
		End If
	End Sub


	'==========================================================================
	' Стандартный обработчик события "Edit"
	' [in] oSender - экземпляр PEObjectSumClass, источник события
	' [in] oEventArgs - экземпляр OpenEditorEventArgsClass, параметры события
	' Данный обработчик производит вызов редактора в режиме редактирования
	' нового объекта.
	Public Sub OnEdit(oSender, oEventArgs)
		Dim oXmlProperty	' xml-свойство

		' по-тихому собираем данные из вложенных редакторов
		With New GetDataArgsClass
			.SilentMode = True
			SumValuePropertyEditor.GetData .Self()
			CurrencyPropertyEditor.GetData .Self()
			ExchangePropertyEditor.GetData .Self()
		End With
		
		With oEventArgs
			Set oXmlProperty = XmlProperty
			.ReturnValue = m_oPropertyEditorBase.ObjectEditor.OpenEditor(oXmlProperty.firstChild, Null, Null, .Metaname, False, oXmlProperty, Not .IsSeparateTransaction, False, .UrlArguments)
			If IsEmpty( .ReturnValue ) Then Exit Sub
			' oXmlProperty использовать уже нельзя
			SetData
		End With
	End Sub

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
		'nPosX = nPosX + window.screenLeft
		nPosY = nPosY + HtmlElement.offsetHeight
		m_oMenu.ShowPopupMenuWithPosEx Me, nPosX, nPosY, True
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
		Dim bHasChild		' признак, что в свойстве есть объект-значение
		Dim oXmlProperty	' xml-свойство
		Dim oObjectValue	' As IXMLDOMElement - xml-объект значение
		Dim bIsLoaded		' As Boolean - признак того,что объект-значение загружен из БД
		Dim bProcess		' As Boolean - признак обработки текущего пункта

		Set oXmlProperty = XmlProperty		
		sType = ValueObjectTypeName
		sObjectID = TempValueID
		If Not IsNull(sObjectID) Then
			Set oObjectValue = ObjectEditor.Pool.GetXmlObject(sType, sObjectID, Null)
			If Not oObjectValue Is Nothing Then
				bIsLoaded = IsNull(oObjectValue.getAttribute("new"))
			End If
		End If	

		Set oList = New ObjectArrayListClass
		' Обработаем только известные нам операции
		For Each oNode In oMenuEventArgs.Menu.XmlMenu.selectNodes("i:menu-item")
			' установим атрибуты на пункте меню, чтобы oMenu.SetMenuItemsAccessRights смог увязать запросы на проверку прав и пункты меню (при проставлении флага disabled)
			oNode.setAttribute "type", sType
			If Not IsNull(sObjectID) Then _
				oNode.setAttribute "oid",  sObjectID
				
			bHidden = Empty
			bDisabled = Empty
			bProcess = False
			Select Case oNode.getAttribute("action")
				Case "DoEdit"
					bHidden = Len( HtmlElement.getAttribute("OFF_EDIT") )>0
					If Not bHidden Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CHANGE, sType, sObjectID)
					bProcess = True
				Case "DoUnlink"
					bHidden = Not HasSomeData() Or Len( HtmlElement.getAttribute("OFF_UNLINK") )>0
					If Not bHidden Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_DELETE, sType, sObjectID)
					bProcess = True
				Case "DoCreateCurrency"
					bHidden = Len( HtmlElement.getAttribute("OFF_CREATE_CURRENCY") )>0
					If Not bHidden Then _
						oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CREATE, "Currency", Null)
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
			' Отредактировать в текущей транзакции
			Case "DoEdit"
				DoLink()
				m_oPropertyEditorBase.DoEdit oMenuExecuteEventArgs.Menu.Macros, False
			' Разорвать связь
			Case "DoUnlink"
				SumValuePropertyEditor.Value = Null
				CurrencyPropertyEditor.ValueID = Null
				ExchangePropertyEditor.Value = Null
				DoUnlink()
			' Создать новую валюту
			Case "DoCreateCurrency"
				DoCreateCurrency oMenuExecuteEventArgs.Menu.Macros
			Case Else
				oMenuExecuteEventArgs.Cancel = False
		End Select
	End Sub
	
End Class
