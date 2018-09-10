'===============================================================================
'@@!!FILE_x-pe-object-common
'<GROUP !!SYMREF_VBS>
'<TITLE x-pe-object-common - Базовый функционал для объектных редакторов свойств>
':Назначение:	Базовый функционал для объектных редакторов свойств.
'===============================================================================
'@@!!CLASSES_x-pe-object-common
'<GROUP !!FILE_x-pe-object-common><TITLE Классы>

Option Explicit

'===============================================================================
'@@XPropertyEditorObjectBaseClass
'<GROUP !!CLASSES_x-pe-object-common><TITLE XPropertyEditorObjectBaseClass>
':Назначение:	
'	"Базовый" класс для объектных редакторов свойств.<P/>
'   Экземпляр данного класса инкапсулируется в объектных редакторах свойств.    
'
'@@!!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass
'<GROUP XPropertyEditorObjectBaseClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass
'<GROUP XPropertyEditorObjectBaseClass><TITLE Свойства>
Class XPropertyEditorObjectBaseClass

	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.EditorPage
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE EditorPage>
	':Назначение:	
	'	Ссылка на экземпляр страницы. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public EditorPage [As EditorPageClass]
	Public EditorPage
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.ObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE ObjectEditor>
	':Назначение:	
	'	Ссылка на экземпляр редактора. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ObjectEditor [As ObjectEditorClass]
	Public ObjectEditor
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.HtmlElement
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE HtmlElement>
	':Назначение:	
	'	Ссылка на главный HTML-элемент. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public HtmlElement [As IHtmlElement]
	Public HtmlElement
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.PropertyMD
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE PropertyMD>
	':Назначение:	
	'	Метаданные XML-свойства. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public PropertyMD [As XMLDOMElement]
	Public PropertyMD
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.EventEngine
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE EventEngine>
	':Назначение:	
	'	Экземпляр EventEngine, используемый для управления и вызова обработчиков 
	'   событий. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public EventEngine [As EventEngineClass]
	Public EventEngine
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.XmlPropertyXPath
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE XmlPropertyXPath>
	':Назначение:	
	'	XPath-запрос для получения свойства в пуле. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public XmlPropertyXPath [As String]
	Public XmlPropertyXPath

	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.ObjectType
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE ObjectType>
	':Назначение:	
	'	Наименование типа объекта - владельца свойства. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ObjectType [As String]
	Public ObjectType
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE ObjectID>
	':Назначение:	
	'	Идентификатор объекта - владельца свойства. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ObjectID [As String]
	Public ObjectID
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.PropertyName
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE PropertyName>
	':Назначение:	
	'	Наименование свойства. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public PropertyName [As String]
	Public PropertyName
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.ValueObjectTypeName
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE ValueObjectTypeName>
	':Назначение:	
	'	Наименование типа объекта значения свойства. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ValueObjectTypeName [As String]
	Public ValueObjectTypeName
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.PropertyEditorMD
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE PropertyEditorMD>
	':Назначение:	
	'	Метаданные редактора свойств. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public PropertyEditorMD [As XMLDOMElement]
	Public PropertyEditorMD
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.SelectorMetaname
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE SelectorMetaname>
	':Назначение:	
	'	Метаимя селектора. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public SelectorMetaname [As String]
	Public SelectorMetaname
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.SelectorType
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE SelectorType>
	':Назначение:	
	'	Тип селектора для выбора. Возможные значения: "list", "tree".
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public SelectorType [As String]
	Public SelectorType
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.PropertyDescription
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE PropertyDescription>
	':Назначение:	
	'	Описание свойства в текущем контексте, используемое в сообщении об ошибке 
	'   при сборе данных.
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public PropertyDescription [As String]
	Public PropertyDescription
	Private m_oParent			' As Object - ссылка на родительский PropertyEditor для передачи в событие
	

	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.Init
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE Init>
	':Назначение:	
	'	Инициализация экземпляра класса XPropertyEditorObjectBaseClass.
	':Параметры:
	'	oParentPE - 
	'       [in] класс, реализующий IObjectPropertyEditor, агрегирующий текущий 
	'       экземпляр XPropertyEditorObjectBaseClass.
	'	oEditorPage - 
	'       [in] экземпляр класса EditorPageClass, на котором расположен редактор
	'       объектного свойства, представленный параметром <b><i>oParentPE</b></i>.
	'	oXmlProperty - 
	'       [in] редактируемое XML-свойство.
	'	oHtmlElement - 
	'       [in] базовый элемент редактора свойства.
	'	sEvents - 
	'       [in] список поддерживаемых событий.
	'	sPEShortName - 
	'       [in] краткое наименование редактора свойства.
	':Сигнатура:
	'	Sub Init ( 
	'		oParentPE [As Object], 
	'		oEditorPage [As EditorPageClass], 
	'		oXmlProperty [As IXMLDOMElement], 
	'		oHtmlElement [As IHTMLDOMElement], 
	'		sEvents [As String], 
	'		sPEShortName [As String] 
	'	)
	Public Sub Init(oParentPE, oEditorPage, oXmlProperty, oHtmlElement, sEvents, sPEShortName)
		Set EventEngine = X_CreateEventEngine
		Set m_oParent		= oParentPE
		Set EditorPage		= oEditorPage
		Set ObjectEditor	= EditorPage.ObjectEditor
		ObjectType			= oXmlProperty.parentNode.tagName
		ObjectID			= oXmlProperty.parentNode.getAttribute("oid")
		PropertyName		= oXmlProperty.tagName
		XmlPropertyXPath	= ObjectType & "[@oid='" & ObjectID & "']/" & PropertyName
		Set PropertyMD		= ObjectEditor.PropMD(oXmlProperty)
		ValueObjectTypeName = PropertyMD.GetAttribute("ot")
		Set HtmlElement		= oHtmlElement
		PropertyDescription = oHtmlElement.GetAttribute("X_DESCR")
		' метаописание propertyeditor'a, xpath для его получения лежит в атрибуте Html "PEMetadataLocator" элемента
		Set PropertyEditorMD = PropertyMD.selectSingleNode( HtmlElement.getAttribute("PEMetadataLocator") )
		If Nothing Is PropertyEditorMD Then
			Err.Raise -1, "XPropertyEditorObjectBaseClass::Init", "Не обнаружены метаданные радактора свойства. XPath-запрос: " & HtmlElement.getAttribute("PEMetadataLocator")
		End If
		' статический биндинг
		If Len("" & sEvents) > 0 Then
			EventEngine.InitHandlers sEvents, "usr_" & ObjectType & "_" & PropertyName & "_" & sPEShortName & "_On"
			EventEngine.InitHandlers sEvents, "usr_" & ObjectType & "_" & PropertyName & "_On"
			EventEngine.InitHandlers sEvents, "usr_" & PropertyName & "_" & sPEShortName & "_On"
			EventEngine.InitHandlers sEvents, "usr_" & sPEShortName & "_On"
		End If
		
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
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.XmlProperty
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE XmlProperty>
	':Назначение:	
	'	XML-данные редактируемого свойства. 
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get XmlProperty [As IXMLDOMElement]
	Public Property Get XmlProperty
		Set XmlProperty = ObjectEditor.XmlObjectPool.selectSingleNode( XmlPropertyXPath )
		If XmlProperty Is Nothing Then
			Set XmlProperty = ObjectEditor.Pool.GetXmlObject(ObjectType, ObjectID, Null).SelectSingleNode(PropertyName)
		End If
		If XmlProperty Is Nothing Then _
			Err.Raise -1, "XPropertyEditorBaseClass::XmlProperty", "Не найдено свойство " & PropertyName & " в xml-объекте"
		If Not IsNull(XmlProperty.getAttribute("loaded")) Then
			Set XmlProperty = ObjectEditor.LoadXmlProperty( Nothing, XmlProperty)
		End If
	End Property


	'==========================================================================
	' Возбуждает событие
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent EventEngine, sEventName, m_oParent, oEventArgs
	End Sub	


	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.SetDirty
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE SetDirty>
	':Назначение:	
	'	Процедура помечает свойство как модифицированное.
	':Сигнатура:
	'	Public Sub SetDirty 
	Public Sub SetDirty
		ObjectEditor.SetXmlPropertyDirty XmlProperty
	End Sub	

	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.Dispose
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE Dispose>
	':Назначение:	
	'	Процедура выполняет освобождение ссылок.
	':Сигнатура:
	'	Public Sub Dispose 
	Public Sub Dispose
		Set m_oParent = Nothing
		Set m_oObjectEditor = Nothing
		Set m_oEditorPage = Nothing
	End Sub	

	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoSelectFromDb
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoSelectFromDb>
	':Назначение:	
	'	Стандартный обработчик команды <b>DoSelectFromDb</b>.
	':Параметры:
	'	oValue - 
	'       [in] коллекция параметров операции меню. 
	':Сигнатура:
	'	Public Sub DoSelectFromDb( oValues [As Scripting.Dictionary] ) 
	Public Sub DoSelectFromDb( oValues )
		Dim oDisabler	' экземпляр класса-дизейблера (ControlsDisablerClass)
		With New SelectEventArgsClass
			Set .OperationValues = oValues
			.ReturnValue = True
			' установим тип селектора и его метаимя
			If IsNull(SelectorMetaname) Then
				' в xls не заданы были параметры use-list-selector/use-tree-selector и аналогичные атрибуты для i:object-presentation в МД
				If oValues.Exists("ListSelectorMetaname") Then
					.SelectorType = "list"
					.SelectorMetaname = oValues.Item("ListSelectorMetaname")
				ElseIf oValues.Exists("TreeSelectorMetaname") Then
					.SelectorType = "tree"
					.SelectorMetaname = oValues.Item("TreeSelectorMetaname")
				Else
					' ничего не задано, значит первый попавшийся список
					.SelectorType = "list"
					.SelectorMetaname = vbNullString
				End If
			Else
				.SelectorType = SelectorType
				.SelectorMetaname = SelectorMetaname 
			End If
			If oValues.Exists("UrlParams") Then
				.UrlArguments = oValues.Item("UrlParams")
			End If
			.ObjectValueType = oValues.Item("ObjectType")

			Set oDisabler = X_CreateControlsDisablerEx(ObjectEditor, m_oParent)
			' 1) Возможность перебить значения
			FireEvent "BeforeSelect", .Self()
			If .ReturnValue <> True Then Exit Sub
			' 2) Показать UI, получить выбранные ID
			.Selection = Empty
			FireEvent "Select", .Self()
			' если ничего не выбрали, пока
			If Not hasValue(.Selection) Then Exit Sub
			.ReturnValue = True
			' 3) Выполнить валидацию
			FireEvent "ValidateSelection", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "BindSelectedData", .Self()
			Set oDisabler = Nothing

			' 4) Постдействия
			FireEvent "AfterSelect", .Self()
			
			tryUpdateOtherPE oValues
		End With	
	End Sub	


	'==========================================================================
	' Отфильтровывает объекты из переданной коллекции с помощью ограничений.
	'	[in] oObjects - коллекция xml-объектов (должна поддрживать For Each)
	'	[in] sRestrictions - ограничения. Последовательность пара PropName=PropValue, разделенных ";"
	'	[retval] массив отфильтрованных объектов, в частном случае пустой массив
	Private Function FilterObjects(oObjects, sRestrictions)
        Dim sRestriction		' Элемент из массива, полученного зазбиением строки sRestrictions по символу ";"
        Dim oObject				' Один объект из коллекции .Objects
        Dim aParts				' Массив (пара), полученный из разбиения строки sRestriction по символу "="
        Dim sPropName			' наименование свойства
        Dim sPropValue			' значение свойства
        Dim oXmlProp			' As IXMLDOMElement - xml-свойства
        Dim aFiltredObjects		' массив объектов из коллекции .Objects, отфильтрованных с помощью ограничений (sRestrictions)
        Dim nIndex				' Индекс в массиве aFiltredObjects
        
		ReDim aFiltredObjects(oObjects.length - 1)
		nIndex = 0
		For Each oObject In oObjects
			For Each sRestriction In Split(sRestrictions, ";")
				aParts = Split(sRestriction , "=")
				If UBound(aParts) = 1 Then
					sPropName = aParts(0)
					sPropValue = aParts(1)
					Set oXmlProp = oObject.selectSingleNode(sPropName)
					If Not oXmlProp Is Nothing Then
						If oXmlProp.text = sPropValue Then
							Set aFiltredObjects(nIndex) = oObject
							nIndex = nIndex + 1
						End If
					End If
				End If
			Next
		Next
		If nIndex > 0 Then 
			ReDim Preserve aFiltredObjects(nIndex - 1)
			FilterObjects = aFiltredObjects
		Else
			' ничего не отобралось - присвоим пустой массив
			FilterObjects = Array()
		End If
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoSelectFromXml
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoSelectFromXml>
	':Назначение:	
	'	Стандартный обработчик команды <b>DoSelectFromXml</b>.
	':Параметры:
	'	oValue - 
	'       [in] коллекция параметров операции меню. 
	':Сигнатура:
	'	Public Sub DoSelectFromXml( oValues [As Scripting.Dictionary] ) 
	Public Sub DoSelectFromXml( oValues )
		Dim sQuery          ' запрос на получение объектов (xpath или object-path)
		Dim oNav            ' As XmlObjectNavigatorClass
		Dim sPreload        ' цепочка preload'ов
		Dim oDisabler	    ' экземпляр класса-дизейблера (ControlsDisablerClass)
        Dim sRestrictions	' Значение параметра "Restrictions"
		
		With New SelectXmlEventArgsClass
			Set .OperationValues = oValues
			' установим тип селектора и его метаимя
			If IsNull(SelectorMetaname) Then
				' в xls не заданы были параметры use-list-selector/use-tree-selector и аналогичные атрибуты для i:object-presentation в МД
				If oValues.Exists("ListSelectorMetaname") Then
					.SelectorMetaname = oValues.Item("ListSelectorMetaname")
				Else
					' ничего не задано, значит первый попавшийся список
					.SelectorMetaname = vbNullString
				End If
			Else
				.SelectorMetaname = SelectorMetaname 
			End If
			If oValues.Exists("UrlParams") Then
				.UrlArguments = oValues.Item("UrlParams")
			End If

			' Сформируем коллекцию объектов, из которых будет производиться отбор.
			' Формирование коллекции определяется параметром Mode пункта меню. Для каждого режима есть свои дополнительные параметры.
            Select Case oValues("Mode")
                Case "ObjectsFromProp"
                    sQuery = oValues("PropPath")
                    If Not hasValue(sQuery) Then
                        Alert "Для операции DoSelectFromXml в режиме ObjectsFromProp не задан обязательный параметр PropPath"
                        Exit Sub
                    End If
                    Set .Objects = ObjectEditor.Pool.GetXmlObjectsByOPath(ObjectEditor.XmlObject, sQuery)
                                        
                    sRestrictions = oValues("Restrictions")
                    If hasValue(.Objects) Then
						If hasValue(sRestrictions) And .Objects.length > 0 Then
							.Objects = FilterObjects(.Objects, sRestrictions)
						End If
                    End If
                Case "ObjectsFromPool"
                    sQuery = oValues("XPath")
                    If Not hasValue(sQuery) Then
                        Alert "Для операции DoSelectFromXml в режиме ObjectsFromPool не задан обязательный параметр XPath"
                        Exit Sub
                    End If
                    Set .Objects = ObjectEditor.Pool.Xml.selectNodes(sQuery)
                Case "ObjectsFromXPathNavigator"
                    Set oNav = ObjectEditor.CreateXmlObjectNavigatorFor(ObjectEditor.XmlObject)
                    sQuery = oValues("XPath")
                    If Not hasValue(sQuery) Then
                        Alert "Для операции DoSelectFromXml в режиме ObjectsFromXPathNavigator не задан обязательный параметр XPath"
                        Exit Sub
                    End If
		            For Each sPreload In Split(oValues("Preloads"), ";")
			            oNav.ExpandProperty sPreload 
		            Next
		            Set .Objects = oNav.SelectNodes(sQuery)
            End Select
			.ReturnValue = True
            .ObjectValueType = oValues.Item("ObjectType")
            
			Set oDisabler = X_CreateControlsDisablerEx(ObjectEditor, m_oParent)			
			' 1) Возможность перебить значения
			FireEvent "BeforeSelectXml", .Self()
			If .ReturnValue <> True Then Exit Sub
			' 2) Показать UI, получить выбранные ID
			.Selection = Empty
			FireEvent "SelectXml", .Self()
			' если ничего не выбрали, пока
			If Not hasValue(.Selection) Then Exit Sub
			.ReturnValue = True
			' 3) Выполнить валидацию
			FireEvent "ValidateSelection", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "BindSelectedData", .Self()
			Set oDisabler = Nothing
			
			' 4) Постдействия
			FireEvent "AfterSelectXml", .Self()
			
			tryUpdateOtherPE oValues
		End With	
	End Sub	


	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoCreate
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoCreate>
	':Назначение:	
	'	Стандартный обработчик команд <b>DoCreate</b> и <b>DoCreateAndSave</b>.
	':Параметры:
	'	oValue - 
	'       [in] коллекция параметров операции меню. 
	'	bSeparateTransaction - 
	'       [in] признак выполнения операции в отдельной транзакции. 
	':Сигнатура:
	'	Public Sub DoCreate( 
	'       oValues [As Scripting.Dictionary], 
	'       bSeparateTransaction [As Boolean]
	'   ) 
	Public Sub DoCreate(oValues, bSeparateTransaction)
		With New OpenEditorEventArgsClass
			Set .OperationValues = oValues
			.Metaname = HtmlElement.GetAttribute("EditorMetanameForCreating")
			If Not hasValue(.Metaname) And oValues.Exists("Metaname") Then
				.Metaname = oValues.Item("Metaname")
			End If
			.IsSeparateTransaction = bSeparateTransaction
			If oValues.Exists("UrlParams") Then
				.UrlArguments = oValues.Item("UrlParams")
			End If
			.ReturnValue = True
			FireEvent "BeforeCreate", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "Create", .Self()
			' В обработчике "Create" в ReturnValue помещается ObjectID созданного объекта, если редактор был закрыт по ОК
			If Not hasValue(.ReturnValue) Then Exit Sub
			FireEvent "AfterCreate", .Self()
			
			tryUpdateOtherPE oValues
		End With
	End Sub


	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoEdit
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoEdit>
	':Назначение:	
	'	Стандартный обработчик команды <b>DoEdit</b> и <b>DoEditAndSave</b>.
	':Параметры:
	'	oValue - 
	'       [in] коллекция параметров операции меню. 
	'	bSeparateTransaction - 
	'       [in] признак выполнения операции в отдельной транзакции. 
	':Сигнатура:
	'	Public Sub DoEdit( 
	'       oValues [As Scripting.Dictionary], 
	'       bSeparateTransaction [As Boolean]
	'   ) 
	Public Sub DoEdit(oValues, bSeparateTransaction)
		With New OpenEditorEventArgsClass
			Set .OperationValues = oValues
			.Metaname = HtmlElement.GetAttribute("EditorMetanameForEditing")
			If Not hasValue(.Metaname) And oValues.Exists("Metaname") Then
				.Metaname = oValues.Item("Metaname")
			End If
			.IsSeparateTransaction = bSeparateTransaction
			If oValues.Exists("UrlParams") Then
				.UrlArguments = oValues.Item("UrlParams")
			End If
			
			.ReturnValue = True
			.ObjectID = oValues.Item("ObjectID")
			FireEvent "BeforeEdit", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "Edit", .Self()
			' В обработчике "Edit" в ReturnValue помещается ObjectID отредактирвоанного объекта, если редактор был закрыт по ОК
			If Not hasValue(.ReturnValue) Then Exit Sub
			FireEvent "AfterEdit", .Self()

			tryUpdateOtherPE oValues
		End With
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoMarkDelete
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoMarkDelete>
	':Назначение:	
	'	Стандартный обработчик команды <b>DoMarkDelete</b>.
	':Параметры:
	'	oValue - 
	'       [in] коллекция параметров операции меню. 
	':Сигнатура:
	'	Public Sub DoMarkDelete( oValues [As Scripting.Dictionary] ) 
	Public Sub DoMarkDelete( oValues )
		With New OperationEventArgsClass
			Set .OperationValues = oValues
			.ReturnValue = True
			.ObjectID = oValues.Item("ObjectID")
			If oValues.Exists("Prompt") Then
				.Prompt = oValues.Item("Prompt")
			Else
				.Prompt = "Вы действительно хотите удалить объект?"
			End If
			FireEvent "BeforeMarkDelete", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "MarkDelete", .Self()
			FireEvent "AfterMarkDelete", .Self()
			tryUpdateOtherPE oValues
		End With	
	End Sub


	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoUnlink
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoUnlink>
	':Назначение:	
	'	Стандартный обработчик команды <b>DoUnlink</b>.
	':Параметры:
	'	oValue - 
	'       [in] коллекция параметров операции меню. 
	':Сигнатура:
	'	Public Sub DoUnlink( oValues [As Scripting.Dictionary] ) 
	Public Sub DoUnlink( oValues )
		With New OperationEventArgsClass
			Set .OperationValues = oValues
			.ReturnValue = True
			.ObjectID = oValues.Item("ObjectID")
			If oValues.Exists("Prompt") Then
				.Prompt = oValues.Item("Prompt")
			Else
				.Prompt = "Вы действительно хотите удалить ссылку?"
			End If
			FireEvent "BeforeUnlink", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "Unlink", .Self()
			FireEvent "AfterUnlink", .Self()
			tryUpdateOtherPE oValues
		End With	
	End Sub

	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoUnlinkImplementation
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoUnlinkImplementation>
	':Назначение:	
	'	Функция реализует операцию "Разорвать связь" (<b>DoUnlink</b>) для классов
	'   XPEObjectPresentationClass и XPEObjectsElementsListClass.
	':Параметры:
	'	oXmlProperty - 
	'       [in] XML-свойство, из которого удаляется ссылка.
	'	oXmlValueObject - 
	'       [in] объект-значение свойства.
	':Результат:
	'	Возвращает True при успешном удалении ссылки и False в противном случае.
	':Сигнатура:
	'	Public Function DoUnlinkImplementation ( 
	'		oXmlProperty [As IXMLDOMElement], 
	'		oXmlValueObject [As IXMLDOMElement] 
	'	) [As Boolean]
	Public Function DoUnlinkImplementation(oXmlProperty, ByVal oXmlValueObject)
		Dim bIsNew				' As Boolean - признак нового объекта
		Dim oAllReferences		' As ObjectArrayListClass - список всех ссылок на удаляемые объекты
		Dim oNotNullReferences	' As ObjectArrayListClass - список ссылок на удаляемые объекты из обязательных свойств
		Dim oObjectsToDelete	' As ObjectArrayListClass - список ссылок на объекты в пуле, которые надо пометить как удаляемые

		' переполучим объект-значение как указатель на xml-объект в пуле		
		Set oXmlValueObject = ObjectEditor.Pool.GetXmlObjectByXmlElement(oXmlValueObject, Null)
		bIsNew = Not IsNull(oXmlValueObject.getAttribute("new"))
		DoUnlinkImplementation = False
		If Not bIsNew Then
			ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlValueObject
		Else
			' Очищаем ссылку на новый объект...
			' Поищем ссылки на объект-значение
			Set oAllReferences = New ObjectArrayListClass
			Set oNotNullReferences = New ObjectArrayListClass
			Set oObjectsToDelete = New ObjectArrayListClass
			ObjectEditor.Pool.CheckReferences oXmlValueObject, oXmlProperty, oAllReferences, oNotNullReferences, oObjectsToDelete, Nothing
			If oAllReferences.Count>1 Then
				ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlValueObject
			Else
				' выполним удаление
				ObjectEditor.Pool.Internal_DoMarkObjectAsDeleted oAllReferences, oObjectsToDelete
			End If
		End If
		DoUnlinkImplementation = True
	End Function

	
	'==============================================================================
	' Обновляет редакторы свойств для свойств, наименования которых перечисленны в параметре UpdatePE
	'	[in] oValues As Scripting.Duictionary - словарь параметров операции меню. Используется параметр "UpdatePE"
	Private Sub tryUpdateOtherPE(oValues)
		If oValues.Exists("UpdatePE") Then
			Dim sProps				' список свойств для обновления PE
			Dim sProp				' наименование свойства
			Dim oXmlProp			' As XmlElement - xml-свойство
			Dim aPropertyEditors	' As Array - массив редакторов свойств для одного свойства
			Dim i
			
			sProps = oValues.Item("UpdatePE")
			If hasValue(sProps) Then
				If sProps = "*" Then
					' одновить все редакторы свойства
					For Each aPropertyEditors In EditorPage.PropertyEditors.Items()
						For i=0 To UBound(aPropertyEditors)
							' если редактор свойств не текущий 
							If Not aPropertyEditors(i) Is m_oParent Then
								aPropertyEditors(i).SetData
							End If
						Next
					Next
				Else
					For Each sProp In Split(sProps, ";")
						Set oXmlProp = ObjectEditor.XmlObject.selectSingleNode(sProp)
						If Not oXmlProp Is Nothing Then
							aPropertyEditors = EditorPage.GetPropertyEditors(oXmlProp)
							If IsArray(aPropertyEditors) Then
								For i=0 To UBound(aPropertyEditors)
									aPropertyEditors(i).SetData
								Next
							End If
						End If     
					Next
				End If
			End If
		End If
	End Sub	
End Class


'===============================================================================
'@@SelectEventArgsClass
'<GROUP !!CLASSES_x-pe-object-common><TITLE SelectEventArgsClass>
':Назначение:	
'	Параметры событий выбора объекта - значения свойства.
'
'@@!!MEMBERTYPE_Methods_SelectEventArgsClass
'<GROUP SelectEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_SelectEventArgsClass
'<GROUP SelectEventArgsClass><TITLE Свойства>
Class SelectEventArgsClass

	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.SelectorMetaname
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE SelectorMetaname>
	':Назначение:	
	'	Метанаименование списка или дерева, используемого для выбора объекта-значения.
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public SelectorMetaname [As String]
	Public SelectorMetaname
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.SelectorType
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE SelectorType>
	':Назначение:	
	'	Вид селектора (список/дерево), метаимя котого лежит в свойстве 
	'   <LINK SelectEventArgsClass.SelectorMetaname, SelectorMetaname />. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public SelectorType [As String]
	Public SelectorType
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE ReturnValue>
	':Назначение:	
	'	Свойство сообщает об успехе обработчика. При установленном False прерывает 
	'   цепочку событий, генерируемых обработчиком операции меню (например, 
	'   BeforeSelect, Select, AfterSelect). 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.UrlArguments
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE UrlArguments>
	':Назначение:	
	'	Параметры URL страницы, открываемой для выбора. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public UrlArguments [As String]
	Public UrlArguments
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.OperationValues
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE OperationValues>
	':Назначение:	
	'	Коллекция параметров, связанная с действием (action), вызванным по пункту 
	'   меню (по сути - ссылка на коллекцию Values меню). 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public OperationValues [As Scripting.Dictionary]
	Public OperationValues
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.Selection
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE Selection>
	':Назначение:	
	'	Строка со списком идентификаторов выбранных объектов. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Selection [As String]
	Public Selection
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.ObjectValueType
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE ObjectValueType>
	':Назначение:	
	'	Тип выбираемых объектов. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ObjectValueType [As String]
	Public ObjectValueType
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE Cancel>
	':Назначение:	
	'	Прерывание цепочки обработчиков. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Cancel [As Boolean]
	Public Cancel

	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SelectEventArgsClass><TITLE Self>
	':Назначение:	
	'	Функция возвращает ссылку на текущий экземпляр класса SelectEventArgsClass.
	':Сигнатура:
	'	Public Function Self() [As SelectEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function	
End Class


'===============================================================================
'@@SelectXmlEventArgsClass
'<GROUP !!CLASSES_x-pe-object-common><TITLE SelectXmlEventArgsClass>
':Назначение:	
'	Параметры события SelectXml выбора объекта-значения из контекста 
'   (используя x-select-from-xml.aspx). 
'
'@@!!MEMBERTYPE_Methods_SelectXmlEventArgsClass
'<GROUP SelectXmlEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_SelectXmlEventArgsClass
'<GROUP SelectXmlEventArgsClass><TITLE Свойства>
Class SelectXmlEventArgsClass

	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.Objects
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE Objects>
	':Назначение:	
	'	Коллекция объектов для выбора (должна поддерживать 
	'   For Each: Array, IXMLDOMNodeList). 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Objects [As ICollection]
    Public Objects
    
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.SelectorMetaname
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE SelectorMetaname>
	':Назначение:	
	'	Метанаименование списка, используемого для выбора объекта. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public SelectorMetaname [As String]
	Public SelectorMetaname
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE ReturnValue>
	':Назначение:	
	'	Свойство сообщает об успехе обработчика. При установленном False прерывает 
	'   цепочку событий, генерируемых обработчиком операции меню (например, 
	'   BeforeSelectXml, SelectXml, AfterSelectXml). 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.UrlArguments
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE UrlArguments>
	':Назначение:	
	'	Параметры URL страницы, открываемой для выбора. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public UrlArguments [As String]
	Public UrlArguments
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.OperationValues
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE OperationValues>
	':Назначение:	
	'	Коллекция параметров, связанная с действием (action), вызванным по пункту 
	'   меню (по сути - ссылка на коллекцию Values меню). 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public OperationValues [As Scripting.Dictionary]
	Public OperationValues
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.Selection
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE Selection>
	':Назначение:	
	'	Строка со списком идентификаторов выбранных объектов. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Selection [As String]
	Public Selection
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.ObjectValueType
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE ObjectValueType>
	':Назначение:	
	'	Тип выбираемых объектов. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ObjectValueType [As String]
	Public ObjectValueType
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE Cancel>
	':Назначение:	
	'	Прерывание цепочки обработчиков одного события. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Cancel [As Boolean]
	Public Cancel
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SelectXmlEventArgsClass><TITLE Self>
	':Назначение:	
	'	Функция возвращает ссылку на текущий экземпляр класса SelectXmlEventArgsClass.
	':Сигнатура:
	'	Public Function Self() [As SelectXmlEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function	
End Class


'===============================================================================
'@@OpenEditorEventArgsClass
'<GROUP !!CLASSES_x-pe-object-common><TITLE OpenEditorEventArgsClass>
':Назначение:	
'	Параметры событий BeforeCreate, Create, AfterCreate, BeforeEdit, Edit, AfterEdit.
'
'@@!!MEMBERTYPE_Methods_OpenEditorEventArgsClass
'<GROUP OpenEditorEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_OpenEditorEventArgsClass
'<GROUP OpenEditorEventArgsClass><TITLE Свойства>
Class OpenEditorEventArgsClass

	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.OperationValues
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE OperationValues>
	':Назначение:	
	'	Коллекция параметров операции.
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public OperationValues [As Scripting.Dictionary]
	Public OperationValues
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.Metaname
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE Metaname>
	':Назначение:	
	'	Метаимя редактора/мастера. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Metaname [As String]
	Public Metaname
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.IsSeparateTransaction
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE IsSeparateTransaction>
	':Назначение:	
	'	Признак выполнения операции в отдельной транзакции. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public IsSeparateTransaction [As Boolean]
	Public IsSeparateTransaction
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.UrlArguments
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE UrlArguments>
	':Назначение:	
	'	Параметры, передаваемые в редактор через URL страницы. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public UrlArguments [As String]
	Public UrlArguments
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE ObjectID>
	':Назначение:	
	'	Идентификатор объекта значения. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ObjectID [As String]
	Public ObjectID
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE ReturnValue>
	':Назначение:	
	'	Для событий BeforeCreate и BeforeEdit при задании значения False прерывает 
	'   цепочку событий, генерируемых обработчиком операции. Таким образом, 
	'   блокируется генерация событий Create и Edit. Для остальных событий значение
	'   свойства игнорируется.
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE Cancel>
	':Назначение:	
	'	Прерывание цепочки обработчиков для события. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Cancel [As Boolean]
	Public Cancel
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_OpenEditorEventArgsClass><TITLE Self>
	':Назначение:	
	'	Функция возвращает ссылку на текущий экземпляр класса OpenEditorEventArgsClass.
	':Сигнатура:
	'	Public Function Self() [As OpenEditorEventArgsClass]
	Public Function Self()
		Set Self = Me
	End Function
End Class

'===============================================================================
'@@OperationEventArgsClass
'<GROUP !!CLASSES_x-pe-object-common><TITLE OperationEventArgsClass>
':Назначение:	
'	Параметры различных событий, связанные с командами меню.
'
'@@!!MEMBERTYPE_Methods_OperationEventArgsClass
'<GROUP OperationEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_OperationEventArgsClass
'<GROUP OperationEventArgsClass><TITLE Свойства>
Class OperationEventArgsClass

	'------------------------------------------------------------------------------
	'@@OperationEventArgsClass.OperationValues
	'<GROUP !!MEMBERTYPE_Properties_OperationEventArgsClass><TITLE OperationValues>
	':Назначение:	
	'	Коллекция параметров операции.
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public OperationValues [As Scripting.Dictionary]
	Public OperationValues
	
	'------------------------------------------------------------------------------
	'@@OperationEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_OperationEventArgsClass><TITLE ReturnValue>
	':Назначение:	
	'	Для событий BeforeCreate и BeforeEdit при задании значения False прерывает 
	'   цепочку событий, генерируемых обработчиком операции. Таким образом, 
	'   блокируется генерация событий Create и Edit. Для остальных событий значение
	'   свойства игнорируется.
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	'------------------------------------------------------------------------------
	'@@OperationEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_OperationEventArgsClass><TITLE Cancel>
	':Назначение:	
	'	Прерывание цепочки обработчиков для события. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Cancel [As Boolean]
	Public Cancel
	
	'------------------------------------------------------------------------------
	'@@OperationEventArgsClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_OperationEventArgsClass><TITLE ObjectID>
	':Назначение:	
	'	Идентификатор объекта значения. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ObjectID [As String]
	Public ObjectID
	
	'------------------------------------------------------------------------------
	'@@OperationEventArgsClass.Prompt
	'<GROUP !!MEMBERTYPE_Properties_OperationEventArgsClass><TITLE Prompt>
	':Назначение:	
	'	Приглашение/запрос пользователю. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Prompt [As String]
	Public Prompt
	
	'------------------------------------------------------------------------------
	'@@OperationEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_OperationEventArgsClass><TITLE Self>
	':Назначение:	
	'	Функция возвращает ссылку на текущий экземпляр класса OperationEventArgsClass.
	':Сигнатура:
	'	Public Function Self() [As OperationEventArgsClass]
	Public Function Self()
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@LoadListEventArgsClass
'<GROUP !!CLASSES_x-pe-object-common><TITLE LoadListEventArgsClass>
':Назначение:	
'	Параметры события <b>LoadList</b>. 
'
'@@!!MEMBERTYPE_Methods_LoadListEventArgsClass
'<GROUP LoadListEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_LoadListEventArgsClass
'<GROUP LoadListEventArgsClass><TITLE Свойства>
Class LoadListEventArgsClass

	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE Cancel>
	':Назначение:	
	'	Признак отмены для цепочки обработчиков. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Cancel [As Boolean]
	Public Cancel
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.Restrictions
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE Restrictions>
	':Назначение:	
	'	Параметры для загрузчика списка. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Restrictions [As GetRestrictionsEventArgsClass]
	Public Restrictions
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.TypeName
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE TypeName>
	':Назначение:	
	'	Наименование типа, в котором объявлен список с именем 
	'   <LINK LoadListEventArgsClass.ListMetaname, ListMetaname />. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public TypeName [As String]
	Public TypeName
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.ListMetaname
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE ListMetaname>
	':Назначение:	
	'	Метаимя списка объектов. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ListMetaname [As String]
	Public ListMetaname
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.RequiredValues
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE RequiredValues>
	':Назначение:	
	'	Список идентификаторов, которые должны присутствовать в списке (параметр 
	'   <b><i>VALUEOBJECTID</b></i> для загручика списка). 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public RequiredValues [As String]
	Public RequiredValues
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.Cache
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE Cache>
	':Назначение:	
	'	Режим кеширования данных списка (константы 
	'   <LINK CACHE_BEHAVIOR_nnnn, CACHE_BEHAVIOR_nnnn />). 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Cache [As Int]
	Public Cache
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.CacheSalt
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE CacheSalt>
	':Назначение:	
	'	Строка с текстом VBS-выражения. Если свойство указано, то оно 
	'   используется как дополнительный ключ для наименования элемента кэша. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.<P/>
	'   <b><i>Пример:</b></i><P/>
	'   cаche-salt="X_GetMD().GetAttribute(&quot;md5&quot;)" - данные кэша 
	'   становятся недействительными при смене метаданных.<P/>
	'	cаche-salt="clng(date())" - данные кэша становятся недействительными 
	'   раз в сутки.<P/>
	'	cаche-salt="X_GetMD().GetAttribute(&quot;md5&quot;) &amp; &quot;-&quot; 
	'   &amp; clng(date())" - данные кэша становятся недействительными раз в сутки 
	'   или при смене метаданных.<P/>
    '	cаche-salt="MyVbsFunctionName()" - вызывается прикладная функция.
	':Сигнатура:	
	'	Public CacheSalt [As String]
	Public CacheSalt

	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.HasMoreRows
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE HasMoreRows>
	':Назначение:	
	'	Признак того, что при загрузке списка сработало ограничение на максимальное 
	'   количество записей (MAXROWS). 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public HasMoreRows [As Boolean]
	Public HasMoreRows
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_LoadListEventArgsClass><TITLE Self>
	':Назначение:	
	'	Функция возвращает ссылку на текущий экземпляр класса LoadListEventArgsClass.
	':Сигнатура:
	'	Public Function Self() [As LoadListEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'==============================================================================
' Параметры события "Load" для TreeView
Class LoadTreeEventArgsClass
	Public Cancel				' признак отмены для цепочки обработчиков. 
	Public Restrictions			' параметры для загрузчика списка - экземпляр GetRestrictionsEventArgsClass
	Public Metaname				' метаимя загрузчика списка
	
	Public Function Self
		Set Self = Me
	End Function
End Class
