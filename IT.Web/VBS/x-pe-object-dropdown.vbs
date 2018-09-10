'===============================================================================
'@@!!FILE_x-pe-object-dropdown
'<GROUP !!SYMREF_VBS>
'<TITLE x-pe-object-dropdown - Функционал обслуживания поля ввода типа "выпадающий список" для объектных свойств>
':Назначение:	Стандартный функционал обслуживания UI-представления скалярного
'               объектного свойства в виде выпадающего списка.
'===============================================================================
'@@!!CLASSES_x-pe-object-dropdown
'<GROUP !!FILE_x-pe-object-dropdown><TITLE Классы>

Option Explicit

'===============================================================================
'@@XPEObjectDropdownClass
'<GROUP !!CLASSES_x-pe-object-dropdown><TITLE XPEObjectDropdownClass>
':Назначение:	Класс обслуживания UI-представления скалярного
'               объектного свойства в виде выпадающего списка. 
':Примечание:   Перечень событий, генерируемых классом, приведен в пункте
'               "<LINK points_wc1_02-3-41, События />".
'@@!!MEMBERTYPE_Methods_XPEObjectDropdownClass
'<GROUP XPEObjectDropdownClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_XPEObjectDropdownClass
'<GROUP XPEObjectDropdownClass><TITLE Свойства>
Class XPEObjectDropdownClass
' События:
'	GetRestrictions (EventArgs: GetRestrictionsEventArgsClass)
'		возникает при заполнении списка данными с сервера
'	LoadList (EventArgs: LoadListEventArgsClass)
'		возникает при заполнении списка данными с сервера
'	BeforeSetData (EventArgs: BeforeSetDataEventArgsClass)
'		возникает при установке значения (в SetData)
'	SetDataError (EventArgs: ChangeEventArgsClass)
'		возникает при невозможности установить к комбобоксе значение свойства, либо нового значения
'	Changing (EventArgs: ChangeEventArgsClass)
'		возникает в процессе изменения значения
'	Changed (EventArgs: ChangeEventArgsClass)
'		возникает после ищменения значения
'	Accel (EventArgs: AccelerationEventArgsClass)
'		нажатие комбинации клавиш

	Private m_bIsInitialized	' As Boolean - признак завершения инциализации редактора свойства
	Private m_oEditorPage		' As EditorPageClass
	Private m_oObjectEditor		' As ObjectEditorClass
	Private m_oHtmlElement		' As IHtmlElement	- ссылка на главный Html-элемент
	Private m_oPropertyMD		' As XMLDOMElement	- метаданные xml-свойства
	Private m_bIsActiveX		' As Boolean		- признак ActiveX-комбобокса
	Private m_oEventEngine		' As EventEngineClass
	Private m_vPrevValue		' As Variant		- предыдущее значение комбобокса
	Private EVENTS				' As String - список событий страницы
	Private m_sXmlPropertyXPath	' As String - XPAth - Запрос для получения свойства в Pool'e
	Private m_sObjectType		' As String - Наименование типа объекта владельца свойства
	Private m_sObjectID			' As String - Идентификатор объекта владельца свойства
	Private m_sPropertyName		' As String - Наименование свойства
	Private m_bNoEmptyValue		' As Boolean - признак отсутствия пустого значения
	Private m_sDropdownText		' As String - текст пустого значения
	Private m_sListMetaname		' As String - метанаименование списка для заполнения комбобокса
	Private m_sPropertyDescription	' As String - описание свойства
	Private m_oRefreshButton	' As IHTMLElement - кнопка операции перегрузки кэша
	Private m_bUseCache			' As Boolean - признак использования кэша при загрузке данных 
								'	с сервера (по умолчанию не используется)
	Private m_sCacheSalt		' As String - выражение на VBS, если указан то используется как 
								'	дополнительный ключ для наименования элемента кэша
	Private m_bHasMoreRows		' As Boolean - признак того, что в список значений на сервере был 
								'	ограничен условием MAXROWS
	Private m_bKeyUpEventProcessing		' As Boolean - Признак обработки ActiveX-события OnKeyUp для "разбухания" стэка
	
	Private m_oRestrictions		' As XMLDOMNodeList - элементы i:restriction, описывающие ограничения
	Private m_arrDependDropds		' As XMLDOMElement - коллекция свойств, у которых в метаданных
								' заданы ограничения i:restriction, указывающие данное свойство в prop-name


	'==========================================================================
	' Конструктор
	Private Sub Class_Initialize
		Set m_oEventEngine = X_CreateEventEngine
		EVENTS = "GetRestrictions,LoadList,BeforeSetData,SetDataError,Changing,Changed,Accel"
		m_vPrevValue = Null
		m_bIsInitialized = False
	End Sub


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE ObjectEditor>
	':Назначение:	
	'	Экземпляр ObjectEditorClass - редактор, в рамках которого работает
	'   данный редактор свойства. 
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get ObjectEditor [As ObjectEditorClass]
	Public Property Get ObjectEditor
		Set ObjectEditor = m_oObjectEditor
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ParentPage
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE ParentPage>
	':Назначение:	
	'	Экземпляр EditorPageClass - страница редактора, на которой размещается
	'   данный редактор свойства. 
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get ParentPage [As EditorPageClass]
	Public Property Get ParentPage
		Set ParentPage = m_oEditorPage
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.PropertyMD
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE PropertyMD>
	':Назначение:	
	'	Метаданные свойства (узел <b>ds:prop</b>). 
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get PropertyMD [As IXMLDOMElement]
	Public Property Get PropertyMD
		Set PropertyMD = m_oPropertyMD
	End Property

	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.EventEngine
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE EventEngine>
	':Назначение:	
	'	Экземпляр EventEngineClass - объект, поддерживающий событийную модель
	'   для данного редактора свойства.
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get EventEngine [As EventEngineClass]
	Public Property Get EventEngine
		Set EventEngine = m_oEventEngine
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Init
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE Init>
	':Назначение:	
	'	Инициализация редактора свойства (экземпляра класса XPEObjectDropdownClass).
	':Параметры:
	'	oEditorPage - 
	'       [in] экземпляр класса EditorPageClass, на котором расположен редактор
	'       свойства.
	'	oXmlProperty - 
	'       [in] редактируемое XML-свойство.
	'	oHtmlElement - 
	'       [in] базовый элемент редактора свойства.
	':Сигнатура:
	'	Public Sub Init ( 
	'		oEditorPage [As EditorPageClass], 
	'		oXmlProperty [As IXMLDOMElement], 
	'		oHtmlElement [As IHTMLDOMElement]
	'	)
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
		Set m_oEditorPage	= oEditorPage
		Set m_oObjectEditor = m_oEditorPage.ObjectEditor
		m_sObjectType		= oXmlProperty.parentNode.tagName
		m_sObjectID			= oXmlProperty.parentNode.getAttribute("oid")
		m_sPropertyName		= oXmlProperty.tagName
		m_sXmlPropertyXPath	= m_sObjectType & "[@oid='" & m_sObjectID & "']/" & m_sPropertyName
		Set m_oPropertyMD	= m_oObjectEditor.PropMD(oXmlProperty )
		Set m_oHtmlElement  = oHtmlElement
		m_bIsActiveX = False
		If UCase(oHtmlElement.tagName) = "OBJECT" Then
			m_bIsActiveX = True
		End If
		
		' Коллекция ограничений, заданных на уровне метаданных:
		Dim oRestriction, sErr, sProp, sConst
		Set m_oRestrictions = m_oPropertyMD.selectNodes(".//i:restriction")
		If m_oRestrictions.length > 0 Then
			' Проверка согласованности определения атрибутов:
			For Each oRestriction In m_oRestrictions
				With oRestriction
					sProp = .getAttribute("prop-name")
					sConst = .getAttribute("const-value")
					If Not hasValue(.getAttribute("param-name")) Then
						sErr = "наименование параметра (@param-name) для источника данных не задано!"
					ElseIf Not hasValue(sProp) And Not hasValue(sConst) Then
						sErr = "нет определения значения - ни свойства-источника (@prop-name), ни константного значения (@const-value)!"
					ElseIf hasValue(sProp) And hasValue(sConst) Then
						sErr = "нет определения значения - ни свойства-источника (@prop-name), ни константного значения (@const-value)!"
					ElseIf hasValue(sProp) And UCase("" & sProp) = UCase(m_sPropertyName) Then
						sErr = "в качестве свойства-источника (@prop-name) указано обслуживаемое свойство!"
					End If
					If hasValue(sErr) Then
						Err.Raise -1, "XPEObjectDropdownClass::Init", _
						"Ошибочное определение i:object-dropdown/i:restriction для свойства " & m_sPropertyName & " типа " & m_sObjectType & ": " & sErr
					End If
				End With
			Next
		Else
			Set m_oRestrictions = Nothing
		End If
		
		' Статический биндинг обработчиков событий:
		m_oEventEngine.InitHandlers EVENTS, "usr_" & oXmlProperty.parentNode.tagName & "_" & oXmlProperty.tagName & "_ObjectDropDown_On"
		m_oEventEngine.InitHandlers EVENTS, "usr_" & oXmlProperty.parentNode.tagName & "_" & oXmlProperty.tagName & "_On"
		m_oEventEngine.InitHandlers EVENTS, "usr_" & oXmlProperty.tagName & "_ObjectDropDown_On"
		m_oEventEngine.InitHandlers EVENTS, "usr_ObjectDropDown_On"
		m_oEventEngine.InitHandlers "GetRestrictions", "usr_PE_On"
		' Стандартный обработчик GetRestrictions регистрируется только если в метаданных есть ограничения:
		If hasValue(m_oRestrictions) Then
			m_oEventEngine.AddHandlerForEvent "GetRestrictions", Me, "OnGetRestrictions"
		End If
		m_oEventEngine.AddHandlerForEvent "LoadList", Me, "OnLoadList"
		
		' Определяем свойства, для которых определены ограничения i:restriction, завязанные 
		' на свойства, обслуживаемое данным PE - если такие есть, то их списки будут 
		' автоматически перегружаться при изменении занчения в данном PE:
		m_arrDependDropds = Null
		Dim oDrivenProps, nIndex
		Set oDrivenProps = X_GetTypeMD(m_oObjectEditor.ObjectType).selectNodes("ds:prop[.//i:object-dropdown/i:restriction/@prop-name='" & m_sPropertyName & "']")
		If oDrivenProps.length > 0 Then
			ReDim m_arrDependDropds(oDrivenProps.length-1)
			For nIndex = 0 To oDrivenProps.length-1
				Set m_arrDependDropds(nIndex) = m_oObjectEditor.GetProp( oDrivenProps.item(nIndex).getAttribute("n") )
			Next
			' ...регистрация обработчика изменения значения:
			m_oEventEngine.AddHandlerForEvent "Changed", Me, "OnChangedReloadDependant"
		End If
		
		m_bNoEmptyValue = m_oHtmlElement.getAttribute("NoEmptyValue") = "1"
		m_sDropdownText = m_oHtmlElement.getAttribute("EmptyValueText") 
		m_sListMetaname = m_oHtmlElement.GetAttribute("X_LISTMETANAME")
		
		' Факт наличия кнопки операции перезагрузки и сами параметры кэширования: 
		Set m_oRefreshButton = m_oEditorPage.HtmlDivElement.all( oHtmlElement.GetAttribute("RefreshButtonID"), 0 ) 
		m_bUseCache = "" & m_oHtmlElement.getAttribute("UseCache") = "1"
		m_sCacheSalt = m_oHtmlElement.getAttribute("CacheSalt")
		If m_bUseCache And (Not hasValue(m_sCacheSalt)) Then
			m_sCacheSalt = "0"
		End If
		
		If m_bIsActiveX Then
			' Свойство ShowEmptySelection не входит в PropertyBag, поэтому 
			' устанавливаем его значение здесь, а не в XSL
			m_oHtmlElement.ShowEmptySelection = Not m_bNoEmptyValue 
		End If
		m_sPropertyDescription = m_oHtmlElement.GetAttribute("X_DESCR")
		ViewInitialize
	End Sub

	
	'==========================================================================
	' Выполняет выравнивание размеров кнопки операций, 
	' в соответствии с размером поля отображения представления объекта.
	Private Sub ViewInitialize( )
		' Проверяем существование кнопки операций (включена в HTML, если используется
		' use-cache и нет off-reload:
		If RefreshButton Is Nothing Then Exit Sub
		' Выравнивание размеров кнопки операций выполняется по отношению к размерам
		' поля отображения представления объекта: получаем ссылку на соотв. HTML-элемент
		With RefreshButton 
			.style.height = HtmlElement.offsetHeight
			.style.width = .style.height
			.style.lineHeight = (.offsetHeight \ 2) & "px"
		End With
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.FillData
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE FillData>
	':Назначение:	
	'	Процедура загружает список, генерируя событие <b>GetRestrictions</b>. 
	'   Вызывается при построении страницы редактора, после
	'   инициализации всех редакторов свойств на странице.
	':Сигнатура:
	'	Public Sub FillData ()
	Public Sub FillData()
		ReloadInternal False
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Load
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE Load>
	':Назначение:	
	'	Процедура загружает список, генерируя событие <b>GetRestrictions</b>.<P/> 
	'   Текущее значение XML-свойства проставляется в списке, если оно там есть.
	'   Если значения свойства в списке нет, то свойство очищается и выделение
	'   в списке сбрасывается на неопределенное значение (см. описание процедуры
	'   <LINK XPEObjectDropdownClass.SetData, SetData />).
	':Сигнатура:
	'	Public Sub Load ()
	Public Sub Load()
		ReloadInternal False
		SetData
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ReLoad
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE ReLoad>
	':Назначение:	
	'	Процедура загружает список.<P/> 
	'   Текущее значение XML-свойства проставляется в списке, если оно там есть.
	'   Если значения свойства в списке нет, то свойство очищается и выделение
	'   в списке сбрасывается на неопределенное значение (см. описание процедуры
	'   <LINK XPEObjectDropdownClass.SetData, SetData />).
	':Сигнатура:
	'	Public Sub ReLoad ()
	Public Sub ReLoad()
		ReloadInternal True
		SetData
	End Sub

	
	'==========================================================================
	' Перезагружает список, генерируя событие "GetRestrictions". 
	'	[in] bOverwriteCache - признак сброса закэшированных значений
	Private Sub ReloadInternal( bOverwriteCache )
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass - Параметры события "GetRestrictions"
		
		' Получаем ограничения - генерируем событие GetRestrictions
		Set oSelectorRestrictions = new GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions

		' Перегружаем данные списка - генерируем событие LoadList
		With New LoadListEventArgsClass
			.TypeName = ValueObjectTypeName
			.ListMetaname = m_sListMetaname
			if Not UseCache then
				.Cache = CACHE_BEHAVIOR_NOT_USE
			elseif bOverwriteCache then
				.Cache = CACHE_BEHAVIOR_ONLY_WRITE
			else
				.Cache = CACHE_BEHAVIOR_USE
			end if
			.CacheSalt = CacheSalt
			Set .Restrictions = oSelectorRestrictions
			.RequiredValues = ValueID
			FireEvent "LoadList", .Self()
			m_bHasMoreRows = .HasMoreRows
		End With
	End Sub
	

	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ClearCache
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE ClearCache>
	':Назначение:	
	'	Процедура очищает кэш.
	':Параметры:
	'	bOnlyForCurrentRestrictions - 
	'       [in] признак удаления кэша для текущих ограничений, полученных в результате
	'       выполнения обработчика события <b>GetRestrictions</b>.
	':Сигнатура:
	'	Public Sub ClearCache ( 
	'		bOnlyForCurrentRestrictions [As Boolean]
	'	)
	Public Sub ClearCache(bOnlyForCurrentRestrictions)
		Dim oSelectorRestrictions	' параметр события GetRestrictions
		Dim vRestrictions			' пользовательские ограничения
		
		If Not m_bUseCache Then Exit Sub
		
		vRestrictions = Null
		If bOnlyForCurrentRestrictions Then
			Set oSelectorRestrictions = new GetRestrictionsEventArgsClass
			FireEvent "GetRestrictions", oSelectorRestrictions
			vRestrictions = X_CreateCommonRestrictions(oSelectorRestrictions.ReturnValue,oSelectorRestrictions.UrlParams,ValueID)
		End If
		X_ClearListDataCache ValueObjectTypeName, m_sListMetaname, vRestrictions
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.OnGetRestrictions
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE OnGetRestrictions>
	':Назначение:	
	'	Стандартный обработчик события <b>GetRestrictions</b>.<P/>
	'   Применяется в случае декларативного определения ограничений в метаданных
	'	(элементы i:restriction для i:object-dropdown). Формирует данные ограничений
	'	на основании определений, заданных в метаданных.
	':Параметры:
	'	oSender - 
	'       [in] объект, сгенерировавший событие.
	'	oEventArgs - 
	'       [in] параметры события.
	':Сигнатура:
	'	Public Sub OnGetRestrictions ( 
	'		oSender [As XPEObjectDropdownClass],
	'       oEventArgs [As LoadListEventArgsClass]
	'	)
	Public Sub OnGetRestrictions(oSender, oEventArgs)
		If Not hasValue(m_oRestrictions) Then Exit Sub
		
		Dim oQuery		' Построитель строки ограничений
		Dim oRestr		' Экземпляр i:restriction, итератор цикла по всем ограничениям m_oRestrictions
		Dim sParam		' Наименование параметра для источника данных
		Dim sValue		' Значение ограничения - константа / наименование свойства
		Dim oProp		' Представление свойства, адресованного описанием ограничения
		Dim oElement	' Объект (объектного свойства)
		Dim bUseIfNull	' Признак использования if-null
		
		Set oQuery = new QueryStringParamCollectionBuilderClass
		
		For Each oRestr In m_oRestrictions
			sParam = oRestr.getAttribute("param-name")
			sValue = oRestr.getAttribute("prop-name")
			If hasValue(sValue) Then
				bUseIfNull = True
				' Чтение свойства выполняется через пул, для гарантии прогрузки данных:
				Set oProp = oSender.ObjectEditor.Pool.GetXmlProperty(oSender.ObjectEditor.XmlObject, sValue)
				If hasValue(oProp) Then
					If oSender.ObjectEditor.PropMD(oProp).getAttribute("vt") = "object" Then
						For Each oElement In oProp.selectNodes(".//@oid")
							oQuery.AppendParameter sParam, oElement.nodeTypedValue
							bUseIfNull = False
						Next
					Else
						sValue = "" & oProp.text
						If hasValue(sValue) Then 
							oQuery.AppendParameter sParam, sValue
							bUseIfNull = False
						End If
					End If
				End If
				If bUseIfNull Then 
					sValue = oRestr.getAttribute("if-null")
					If hasValue(sValue) Then oQuery.AppendParameter sParam, sValue
				End If
			Else
				sValue = oRestr.getAttribute("const-value")
				If hasValue(sValue) Then oQuery.AppendParameter sParam, sValue
			End If
		Next
		oEventArgs.ReturnValue = oQuery.QueryString
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.OnChangedReloadDependant
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE OnChangedReloadDependant>
	':Назначение:	
	'	Стандартный обработчик события <b>OnChanged</b>.<P/>
	'   Применяется в случае декларативного определения ограничений в метаданных
	'	(элементы i:restriction для i:object-dropdown); выполняет автоматическую 
	'	перегрузку всех object-dropdown, зависимых от данного.
	':Параметры:
	'	oSender - 
	'       [in] объект, сгенерировавший событие.
	'	oEventArgs - 
	'       [in] параметры события.
	':Сигнатура:
	'	Public Sub OnChangedReloadDependant ( 
	'		oSender [As XPEObjectDropdownClass],
	'       oEventArgs [As LoadListEventArgsClass]
	'	)
	Sub OnChangedReloadDependant(oSender, oEventArgs)
		If Not hasValue(m_arrDependDropds) Then Exit Sub
		Dim oDependProp, oDependPEs, oDependPE
		For Each oDependProp In m_arrDependDropds
			If hasValue(oDependProp) Then oDependPEs = oSender.ParentPage.GetPropertyEditors( oDependProp )
			If hasValue(oDependPEs) Then 
				For Each oDependPE In oDependPEs
					If hasValue(oDependPE) And TypeName(oDependPE) = "XPEObjectDropdownClass" Then
						If hasValue(oDependPE.ValueID) Then oDependPE.ValueID = Null
						oDependPE.Load()
					End If
				Next
			End If
		Next
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.OnLoadList
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE OnLoadList>
	':Назначение:	
	'	Стандартный обработчик события <b>LoadList</b>.<P/>
	'   Очищает и потом заполняет список. Сбрасывает активный элемент на неопределенное
	'   значение (с индексом -1).
	':Параметры:
	'	oSender - 
	'       [in] объект, сгенерировавший событие.
	'	oEventArgs - 
	'       [in] параметры события.
	':Сигнатура:
	'	Public Sub OnLoadList ( 
	'		oSender [As XPEObjectDropdownClass],
	'       oEventArgs [As LoadListEventArgsClass]
	'	)
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
			If m_bIsActiveX Then
				' перегрузим комбобокс
				.HasMoreRows = X_LoadActiveXComboBoxUseCache( .Cache, m_oHtmlElement, .TypeName, .ListMetaname, sRestrictions, sUrlParams, .RequiredValues, .CacheSalt )
			Else
				' перегрузим комбобокс
				.HasMoreRows = X_LoadComboBoxUseCache( .Cache, m_oHtmlElement, .TypeName, .ListMetaname, sRestrictions, sUrlParams, .RequiredValues, .CacheSalt )
			End If
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

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.XmlProperty
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE XmlProperty>
	':Назначение:	
	'	Редактируемое XML-свойство.
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get XmlProperty [As IXMLDOMElement]
	Public Property Get XmlProperty
		Set XmlProperty = m_oObjectEditor.XmlObjectPool.selectSingleNode( m_sXmlPropertyXPath )
		If XmlProperty Is Nothing Then
			Set XmlProperty = m_oObjectEditor.Pool.GetXmlObject(m_sObjectType, m_sObjectID, Null).SelectSingleNode(m_sPropertyName)
		End If
		If XmlProperty Is Nothing Then _
			Err.Raise -1, "XPropertyEditorBaseClass::XmlProperty", "Не найдено свойство " & m_sPropertyName & " в xml-объекте"
		If Not IsNull(XmlProperty.getAttribute("loaded")) Then
			Set XmlProperty = m_oObjectEditor.LoadXmlProperty( Nothing, XmlProperty)
		End If		
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Value
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE Value>
	':Назначение:	
	'	XML-объект-значениe XML-свойства. Если объектная ссылка пустая, то
	'   возвращает Nothing.
	':Примечание:	
	'	При установке значения (Set) устанавливает одноременно XML-объект-значениe 
	'   XML-свойства и значение строки отображения, ему соответствующее.
	'   Если свойство устанавливается в Nothing, то свойство очищается.
	':Сигнатура:	
	'	Public Property Get Value [As IXMLDOMElement]
	'   Public Property Set Value(oObject [As IXMLDOMElement])
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
	
	Public Property Set Value(oObject)
		Dim vVal	' ObjectID нового объекта-значения
		
		' сгенерируем событие
		With New ChangeEventArgsClass
			.OldValue = m_vPrevValue
			vVal = getValueFromObject(oObject)
			.NewValue = vVal
			' установим значение в комбобоксе
			' Прим.: SetData не вызываем, т.к. там содержится специфическая логика
			If SetComboBoxValue(vVal) > -1 Or IsNull(vVal) Then
				' удалось установить новое значение в комбобоксе - изменим значение в свойстве
				doChangeValueObject oObject
				FireEvent "Changed", .Self()
			Else
				' не удалось установить новое значение в комбобоксе  -
				' сгенерируем событие, если есть обработчик, иначе генерируешь runtime ошибку
				If EventEngine.IsHandlerExists("SetDataError") Then
					' генерируем событие с текущим экземляром ChangeEventArgsClass
					' (свойства .OldValue, NewValue установлены как надо)
					FireEvent "SetDataError", .Self()
				Else
					Err.Raise -1, "XPEObjectDropdownClass::set_Value", "Не удалось установить значение в выпадающем списке при модификации свойства Value"
				End If
			End If	
		End With
	End Property

	'==========================================================================
	' Правильно изменяет значение свойства
	' Примечание: изменяет значение m_vPrevValue
	'	[in] oObject As IXMLDOMElement - xml-заглушка объект-значения
	Private Sub doChangeValueObject(oObject)
		Dim oXmlProperty		' As IXMLDOMElement - текущее свойство
		
		Set oXmlProperty = XmlProperty
		' очистим значние свойства
		' Примечание: проверка на пустоту свойства есть в RemoveRelation 
		m_oObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
		' установим значение свойства
		If Not IsNothing(oObject) Then
			m_oObjectEditor.Pool.AddRelation Nothing, oXmlProperty, oObject
			m_vPrevValue = oObject.getAttribute("oid")
		Else
			m_vPrevValue = Null
		End If
	End Sub

	
	'==========================================================================
	' Правильно изменяет значение свойства
	'	[in] vSelectedValue - идентификатор объекта-значения
	Private Sub doChangeValue(vSelectedValue)
		If hasValue(vSelectedValue) Then
			doChangeValueObject X_CreateObjectStub(ValueObjectTypeName, vSelectedValue)
		Else
			doChangeValueObject Nothing
		End If
	End Sub
	
	'==========================================================================
	' Возвращает идентификатор объекта-значения, обрабатывая случая Nothing 
	' - в этом случае возвращает Null
	Private Function getValueFromObject(oObject)
		If Not IsNothing(oObject) Then
			getValueFromObject = oObject.getAttribute("oid")
		Else
			getValueFromObject = Null
		End If
	End Function
	

	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ValueID
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE ValueID>
	':Назначение:	
	'	Идентификатор объекта-значения XML-свойства. 
	':Примечание:	
	'	Если объект-значение - пустое, то свойство возвращает Null. Соответственно, 
	'   при установке значения в Null значение объектного свойства очищается.
	':Сигнатура:	
	'	Public Property Get ValueID [As String]
	'   Public Property Let ValueID(sObjectID [As String])
	Public Property Get ValueID
		' Получим ID объекта - значения свойства
		If XmlProperty.FirstChild Is Nothing Then
			ValueID = Null
		Else	
			' Загружен объект-значение
			ValueID = XmlProperty.FirstChild.getAttribute("oid") 
		End If
	End Property
	
	Public Property Let ValueID(sObjectID)
		If Len("" & sObjectID) = 0 Then
			Set Value = Nothing
		Else
			Set Value = X_CreateObjectStub(ValueObjectTypeName, sObjectID)
		End If
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.FirstNonEmptyValueID
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE FirstNonEmptyValueID>
	':Назначение:	
	'	Первый непустой идентификатор из списка доступных. 
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get FirstNonEmptyValueID [As String]
	Public Property Get FirstNonEmptyValueID
		Dim sValue	' Значение
		Dim i
		
		If m_bIsActiveX Then
			For i=0 To m_oHtmlElement.Rows.Count-1
				sValue = m_oHtmlElement.Rows.GetRow(i).ID
				If HasValue(sValue) Then
					FirstNonEmptyValueID = sValue
					Exit Property
				End If
			Next
		Else
			For i=0 To m_oHtmlElement.Options.Length-1
				sValue = m_oHtmlElement.Options.Item(i).value
				If HasValue(sValue) Then
					FirstNonEmptyValueID = sValue
					Exit Property
				End If
			Next
		End If
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ValueObjectTypeName
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE ValueObjectTypeName>
	':Назначение:	
	'	Наименование типа объекта-значения свойства. 
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get ValueObjectTypeName [As String]
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyMD.GetAttribute("ot")
	End Property
		

	'==========================================================================
	' Возвращает текущее значение ComboBox'a. Если выбрана пустая строка, то возвращается Null
	Private Property Get ComboboxValue
		Dim vValue
		If m_bIsActiveX Then
			vValue = m_oHtmlElement.Rows.SelectedID
		Else
			vValue = m_oHtmlElement.Value
		End If
		If Len(vValue)>0 Then
			ComboboxValue = vValue
		Else
			ComboboxValue = Null
		End If
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.AddComboBoxItem
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE AddComboBoxItem>
	':Назначение:	
	'	Процедура добавляет элемент в выпадающий список.
	':Параметры:
	'	vVal - 
	'       [in] значение, соответствующее элементу.
	'	sLabel - 
	'       [in] текст элемента.
	':Сигнатура:
	'	Public Sub AddComboBoxItem ( 
	'		vVal [As Variant],
	'       sLabel [As String]
	'	)
	Public Sub AddComboBoxItem( vVal, sLabel)
		If m_bIsActiveX Then
			X_AddActiveXComboBoxItem m_oHtmlElement, vVal, sLabel
		Else
			X_AddComboBoxItem m_oHtmlElement, vVal, sLabel
		End If
	End Sub
	
	
	'==========================================================================
	' Устанавливает активный пункт с заданным значением. Свойство при этом не изменяется!
	' События не генерируются!
	'	[in]		vVal - значение, соответствующее элементу
	'   [retval]	индек пункта селектора или -1
	Private Function SetComboBoxValue(vVal)
		If m_bIsActiveX Then
			SetComboBoxValue = X_SetActiveXComboBoxValue( m_oHtmlElement, vVal )
		Else
			SetComboBoxValue = X_SetComboBoxValue( m_oHtmlElement, vVal )
			If SetComboBoxValue = -1 And Not m_bNoEmptyValue Then
				' если не удалось найти значения и задан пустой элемент разрешен, установим его (он всегда идет первым)
				HtmlElement.SelectedIndex = 0
			End If
		End If
	End Function
	

	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.SetData
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE SetData>
	':Назначение:	
	'	Процедура устанавливает значение в выпадающем списке.
	':Сигнатура:
	'	Public Sub SetData 
	Public Sub SetData
		Dim vVal		' As String - значение свойства
		
		vVal = ValueID
		If EventEngine.IsHandlerExists("BeforeSetData") Then
			With New BeforeSetDataEventArgsClass
				.CurrentValue = vVal 
				FireEvent "BeforeSetData", .Self()
				' если прикладной обработчик изменил значение, то изменим значение в пуле
				If .CurrentValue <> vVal Or hasValue(.CurrentValue) <> hasValue(vVal) Then
					vVal = .CurrentValue
					doChangeValue vVal
				End If
			End With
		End If
		
		If SetComboBoxValue(vVal) > -1 Or IsNull(vVal) Then
			m_vPrevValue = vVal
		Else
			' не удалось установить значение свойства в комбобоксе..
			If Not ObjectEditor.SkipInitErrorAlerts Then
				If EventEngine.IsHandlerExists("SetDataError") Then
					With New ChangeEventArgsClass
						.OldValue = m_vPrevValue
						.NewValue = vVal
						FireEvent "SetDataError", .Self()
					End With
				Else			
					If m_bHasMoreRows Then
						m_oEditorPage.EnablePropertyEditor Me, False
						MsgBox _
							"Внимание! Значение реквизита """ & PropertyDescription & """ " & _
							"не может быть отображено корректно, так как полученный список " & _
							"значений ограничен условием на максимальное количество строк.", _
							vbExclamation, "Внимание - невозможно отобразить данные"
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
			End If
		End if
		
		' Первый вызов SetData (по идее, это вызов из редактора при инициализации
		' свойства) заверщить процесс инициализации PE
		m_bIsInitialized = True
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.GetData
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE GetData>
	':Назначение:	
	'	Процедура осуществляет проверку и сбор данных.
	':Параметры:
	'	oGetDataArgs - 
	'       [in] экземпляр класса GetDataArgsClass.
	':Сигнатура:
	'	Public Sub GetData ( 
	'       oGetDataArgs [As GetDataArgsClass]
	'	)
	Public Sub GetData(oGetDataArgs)
		' проверим на Not Null
		ValueCheckOnNullForPropertyEditor ValueID, Me, oGetDataArgs, Mandatory
		' сбор данных происходит непосредственно при выборе значения
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Clear
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE Clear>
	':Назначение:	
	'	Процедура очищает выпадающий список и сбрасывает значение свойства в Null.
	':Сигнатура:
	'	Public Sub Clear 
	Public Sub Clear
		ClearComboBox
		ValueID = Null
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.ClearComboBox
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE ClearComboBox>
	':Назначение:	
	'	Процедура очищает все значения выпадающего списка. Значение свойства при этом 
	'   не меняется! При необходимости, добавляется пустое значение (возможно с текстом).
	':Сигнатура:
	'	Public Sub ClearComboBox 
	Public Sub ClearComboBox
		If m_bIsActiveX Then
			' удалим только строки
			' ВНИМАНИЕ: если вызвать m_oHtmlElement.Clear, что вобщем-то более правильно, 
			' то это приведет к пересозданию компоненты и как следствие потери фокуса
			m_oHtmlElement.Rows.RemoveAll
		Else
			' сначала очистим значение
			If m_bNoEmptyValue Then
				' пустого значения нет
				m_oHtmlElement.innerHTML = ""
			Else
				' пустое значение должно быть
				m_oHtmlElement.innerHTML = ""
				X_AddComboBoxItem m_oHtmlElement, Empty, m_sDropdownText
			End If
		End If
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Mandatory
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE Mandatory>
	':Назначение:	
	'	Признак (не)обязательности свойства. 
	':Сигнатура:	
	'	Public Property Get Mandatory [As Boolean]
	'   Public Property Let Mandatory(bMandatory [As Boolean])
	Public Property Get Mandatory
		Mandatory = IsNull( m_oHtmlElement.GetAttribute("X_MAYBENULL"))
	End Property

	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			m_oHtmlElement.removeAttribute "X_MAYBENULL"
			m_oHtmlElement.className = "x-editor-control-notnull x-editor-dropdown"
		Else
			m_oHtmlElement.setAttribute "X_MAYBENULL", "YES"
			m_oHtmlElement.className = "x-editor-control x-editor-dropdown"
		End If			
	End Property
	

	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Enabled
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE Enabled>
	':Назначение:	
	'	Признак (не)доступности свойства. 
	':Сигнатура:	
	'	Public Property Get Enabled [As Boolean]
	'   Public Property Let Enabled(bEnabled [As Boolean])
	Public Property Get Enabled
		If m_bIsActiveX Then
			 Enabled = m_oHtmlElement.object.Enabled
		Else
			 Enabled = Not (m_oHtmlElement.disabled)
		End If
	End Property

	Public Property Let Enabled(bEnabled)
		If m_bIsActiveX Then
			 m_oHtmlElement.object.Enabled = bEnabled
		Else
			 m_oHtmlElement.disabled = Not( bEnabled )
		End If
		' Не забывам про кнопку операции обновления кэша:
		If Not IsNothing(RefreshButton) Then RefreshButton.disabled = Not( bEnabled )
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.SetFocus
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE SetFocus>
	':Назначение:	
	'	Установка фокуса.
	':Сигнатура:
	'	Public Function SetFocus [As IHTMLElement]
	Public Function SetFocus
		SetFocus = X_SafeFocus( m_oHtmlElement )
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.HtmlElement
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE HtmlElement>
	':Назначение:	
	'	Основной HTML-элемент редактора свойства. 
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get HtmlElement [As IHTMLElement]
	Public Property Get HtmlElement
		Set HtmlElement = m_oHtmlElement
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.RefreshButton
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE RefreshButton>
	':Назначение:	
	'	HTML-элемент кнопки обновления списка. 
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get RefreshButton [As IHTMLElement]
	Public Property Get RefreshButton
		Set RefreshButton = m_oRefreshButton
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.PropertyDescription
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE PropertyDescription>
	':Назначение:	
	'	Описание свойства. 
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get PropertyDescription [As IHTMLElement]
	Public Property Get PropertyDescription
		PropertyDescription = m_sPropertyDescription
	End Property	
	Public Property Let PropertyDescription(sValue)
		m_sPropertyDescription = sValue
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Dispose
	'<GROUP !!MEMBERTYPE_Methods_XPEObjectDropdownClass><TITLE Dispose>
	':Назначение:	
	'	Разрыв связей с другими объектами.
	':Сигнатура:
	'	Public Sub Dispose
	Public Sub Dispose
		Set m_oObjectEditor = Nothing
		Set m_oEditorPage = Nothing
	End Sub	

	
	'==========================================================================
	' Обработчик Html события OnChange. 
	' Внимание: для внутренного использования.
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
				doChangeValue ComboboxValue
				FireEvent "Changed", .Self()
			End With
		End if
	End Sub
	
	
	'==========================================================================
	' Возбуждает событие
	' [in] sEventName - наименование события
	' [in] oEventArgs - экземпляр потомка EventArgsClass, события
	' Вызывает одноименный метод EventEngine, передавая ему в качестве
	' источника ссылку на себя 
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub	
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.Enabled
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE Enabled>
	':Назначение:	
	'	Признак отсутствия пустого значения. 
	':Сигнатура:	
	'	Public Property Get NoEmptyValue [As Boolean]
	'   Public Property Let NoEmptyValue(vValue [As Boolean])
	Public Property Get NoEmptyValue
		NoEmptyValue = m_bNoEmptyValue
	End Property
	Public Property Let NoEmptyValue(vValue)
		m_bNoEmptyValue = vValue
	End Property

	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.DropdownText
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE DropdownText>
	':Назначение:	
	'	Текст пустого значения. 
	':Сигнатура:	
	'	Public Property Get DropdownText [As String]
	'   Public Property Let DropdownText(vValue [As String])
	Public Property Get DropdownText
		DropdownText = m_sDropdownText
	End Property
	Public Property Let DropdownText(vValue)
		m_sDropdownText = vValue
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.UseCache
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE UseCache>
	':Назначение:	
	'	Признак кэширования. 
	':Сигнатура:	
	'	Public Property Get UseCache [As Boolean]
	'   Public Property Let UseCache(vValue [As Boolean])
	Public Property Get UseCache
		UseCache = (m_bUseCache=True)
	End Property
	Public Property Let UseCache(vValue)
		m_bUseCache = (vValue=True)
	End Property


	'------------------------------------------------------------------------------
	'@@XPEObjectDropdownClass.CacheSalt
	'<GROUP !!MEMBERTYPE_Properties_XPEObjectDropdownClass><TITLE CacheSalt>
	':Назначение:	
	'	Параметр кэширования. 
	':Сигнатура:	
	'	Public Property Get CacheSalt [As String]
	'   Public Property Let CacheSalt(vValue [As String])
	Public Property Get CacheSalt
		CacheSalt = m_sCacheSalt
	End Property
	Public Property Let CacheSalt(vValue)
		m_sCacheSalt = vValue
	End Property
	
	
	'==========================================================================
	' Обработчик ActiveX-события onKeyUp (отжатия клавиши). Запускается отложенно по таймауту 
	' Внимание: для внутренного использования.
	Public Sub Internal_OnKeyUpAsync(ByVal nKeyCode, ByVal nFlags)
		Dim oEventArgs		' As AccelerationEventArgsClass
		
		If m_bKeyUpEventProcessing Then Exit Sub
		m_bKeyUpEventProcessing = True
		Set oEventArgs = CreateAccelerationEventArgsForActiveXEvent(nKeyCode, nFlags)
		Set oEventArgs.Source = Me
		Set oEventArgs.HtmlSource = HtmlElement
		FireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' передадим нажатую комбинацию в редактор
			ObjectEditor.OnKeyUp Me, oEventArgs
		End If
		m_bKeyUpEventProcessing = False
	End Sub


	'==========================================================================
	' Обработчик Html-события OnKeyUp . Вызывается асинхронно по тайм-ауту.
	' Внимание: для внутренного использования.
	Public Sub Internal_OnKeyUpHtmlAsync(keyCode, altKey, ctrlKey, shiftKey)
		Dim oEventArgs		' As AccelerationEventArgsClass

		If m_bKeyUpEventProcessing Then Exit Sub
		m_bKeyUpEventProcessing = True
		Set oEventArgs = CreateAccelerationEventArgs(keyCode, altKey, ctrlKey, shiftKey)
		Set oEventArgs.Source = Me
		Set oEventArgs.HtmlSource = HtmlElement
		FireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' если нажатая комбинация не обработана - передадим ее в редактор
			ObjectEditor.OnKeyUp Me, oEventArgs
		End If
		m_bKeyUpEventProcessing = False
	End Sub
End Class


'===============================================================================
'@@BeforeSetDataEventArgsClass
'<GROUP !!CLASSES_x-pe-object-dropdown><TITLE BeforeSetDataEventArgsClass>
':Назначение:	класс параметров события BeforeSetData редактора свойства XPEObjectDropdownClass. 
'
'@@!!MEMBERTYPE_Methods_BeforeSetDataEventArgsClass
'<GROUP BeforeSetDataEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_BeforeSetDataEventArgsClass
'<GROUP BeforeSetDataEventArgsClass><TITLE Свойства>
Class BeforeSetDataEventArgsClass
	'@@BeforeSetDataEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_BeforeSetDataEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel				
	
	'@@BeforeSetDataEventArgsClass.CurrentValue
	'<GROUP !!MEMBERTYPE_Properties_BeforeSetDataEventArgsClass><TITLE CurrentValue>
	':Назначение:	Текущее значение свойства, если обработчик изменит данное свойство, 
	'				то PE установит новое значение в пуле и в контроле
	':Сигнатура:	Public CurrentValue [As String]
	Public CurrentValue
	
	'@@BeforeSetDataEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_BeforeSetDataEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As BeforeSetDataEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class
