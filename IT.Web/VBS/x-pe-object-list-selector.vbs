Option Explicit

'==========================================================================
' Класс редактора скалярных свойств в виде read-only-списка  с чекбоксами с единичным выбором
' При выделении объекта он заносится в свойства, при снятии - удаляется.
' События:
'	LoadList	- загрузка списка (LoadListEventArgsClass), есть стандартный обработчик
'	Selected	- выбор элемента, занесение объекта в свойство (SelectedEventArgsClass)
'	UnSelected	- снятие выделения с элемента, удаления объекта из свойства (SelectedEventArgsClass)
'   События, относящиеся к выбору значения из списка/дерева в диалоговом окне:
'	BeforeSelect
'	GetSelectorRestrictions
'	Select
'	ValidateSelection
'	BindSelectedData
'	AfterSelect
Class XPEObjectListSelectorClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private EVENTS						' As String		- список событий страницы
	
	Private m_oRefreshButton			' As IHTMLElement - кнопка операции перегрузки кэша
	Private m_bUseCache					' As Boolean - признак использования кэша при загрузке данных с сервера (по умолчанию не используется)
	Private m_sCacheSalt				' As String - выражение на VBS, если указан то используется как дополнительный ключ для наименования элемента кэша
										'	Пример:
										'	cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;)" - данные кэша становятся недействительными при смене метаданных
										'	cache-salt="clng(date())" - данные кэша становятся недействительными раз в сутки
										'	cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;) &amp; &quot;-&quot; &amp; clng(date())" - данные кэша становятся недействительными раз в сутки или при смене метаданных
										'	cache-salt="MyVbsFunctionName()" - вызывается прикладная функция
	Private m_bHasMoreRows				' As Boolean - признак того, что в список значений на сервере был ограничен условием MAXROWS
	Private m_sViewStateCacheFileName	' As String - наименование файла с закешированным представлением
	Private m_sListSelectorMetaname
	Private m_sTreeSelectorMetaname
	Private m_bKeyUpEventProcessing		' As Boolean - Признак обработки ActiveX-события OnKeyUp для "разбухания" стэка

		
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "LoadList,Selected,UnSelected,GetRestrictions," & _
			"BeforeSelect,GetSelectorRestrictions,Select,ValidateSelection,BindSelectedData,AfterSelect,Accel"
	End Sub


	'==========================================================================
	' IPropertyEdior: инициализация редактора свойства
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim vMetaName		' метаимя списка для наполнения ListView
		Dim sXPath			' XPAth -запрос
		
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectListSelector"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEvent "LoadList", Me, "OnLoadList"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "Select", Me, "OnSelect"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEventWeakly "BindSelectedData", Me, "OnBindSelectedData"
		
		' i:list-selector ссылается на i:objects-list в типе объекта значения свойства
		' сформируем xpath для поиска objects-list'a в МД
		vMetaName = HtmlElement.getAttribute("ListMetaname")
		
		m_sListSelectorMetaname = HtmlElement.getAttribute("ListSelectorMetaname")
		m_sTreeSelectorMetaname = HtmlElement.getAttribute("TreeSelectorMetaname")
		
		' Факт наличия кнопки операции перезагрузки и сами параметры кэширования: 
		Set m_oRefreshButton = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.GetAttribute("RefreshButtonID"), 0 ) 
		m_bUseCache = "" & HtmlElement.getAttribute("UseCache") = "1"
		m_sCacheSalt = "" & HtmlElement.getAttribute("CacheSalt")
		If m_bUseCache AND (Not hasValue(m_sCacheSalt)) Then
			m_sCacheSalt = "0"
		End If
		
		sXPath = "i:objects-list"
		If Not IsNull(vMetaName) Then
			sXPath = sXPath & "[@n='" & vMetaName & "']"
		End If
		ListView.CheckBoxes = True
		
		m_sViewStateCacheFileName = ObjectEditor.Signature() & "XOLS." + oXmlProperty.parentNode.tagName & "." & oXmlProperty.tagName 
		If Not m_oPropertyEditorBase.PropertyEditorMD Is Nothing Then _
			m_sViewStateCacheFileName = m_sViewStateCacheFileName & "." & m_oPropertyEditorBase.PropertyEditorMD.getAttribute("n")
		InitXListViewInterface HtmlElement, X_GetTypeMD(ValueObjectTypeName).selectSingleNode(sXPath), m_sViewStateCacheFileName, False
		ViewInitialize
	End Sub

	
	'==========================================================================
	' Выполняет выравнивание размеров кнопки операций, 
	' в соответствии с размером поля отображения представления объекта.
	Private Sub ViewInitialize( )
		' Проверяем существование кнопки операций 
		' (включена в HTML, если используется use-cache и нет off-reload)
		If Not m_oRefreshButton Is Nothing Then 
			' Выравнивание размеров кнопки операций выполняется по отношению к размерам
			' поля отображения представления объекта: получаем ссылку на соотв. HTML-элемент
			With RefreshButton 
				.style.height = ExtraHtmlElement("Deselect").offsetHeight
				.style.width = .style.height
				.style.lineHeight = (.offsetHeight \ 2) & "px"
			End With
		End If
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: Метод вызывается при построении страницы редактора, после инициализации всех PE на странице
	Public Sub FillData()
		LoadInternal iif(UseCache, CACHE_BEHAVIOR_USE, CACHE_BEHAVIOR_NOT_USE)
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
	' Загружает список с сервера, перезаписывая кеш, если включен режим кеширования
	Public Sub ReLoad()
		Dim oData				' Закэшированные данные
		Dim oRestrictions		' As GetRestrictionsEventArgsClass
		Dim sRestrictions		' URL ограничений загрузчика списка. хеш от него участвует в наименовании ключа в хеше
		Dim sFilePefix			' Префикс имени файла
		Dim sDataName			' Имя файла с данными

		' отключим перезапись кеша, т.к. после заполнения списка, в SetData мы можем удалить объекты из свойства, 
		' если их не окажется в пришедших с сервера данных. А объекты в свойстве влияют на хеш в кеше, поэтому
		' операции с кешем выполним явно (иначе они выполнялись бы в X_LoadXListViewUseCache)
		If UseCache Then 
			ClearCache False
		End If
		' Не используем LoadInternal для того, чтобы не получить два раза ограничения через событие "GetRestrictions"
		' Получим текущие ограничения
		Set oRestrictions = New GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oRestrictions
		With New LoadListEventArgsClass
			.TypeName = ValueObjectTypeName
			.ListMetaname = HtmlElement.GetAttribute("ListMetaname")
			.RequiredValues = ValueID
			.Cache = CACHE_BEHAVIOR_NOT_USE
			.CacheSalt = CacheSalt
			Set .Restrictions = oRestrictions
			FireEvent "LoadList", .Self()
			m_bHasMoreRows = .HasMoreRows
			' установим состояние списка в соответствии с наполнением свойства
			SetData
			If UseCache Then
				' сформирует URL из ограничений
				sRestrictions = X_CreateListLoaderRestrictions(oRestrictions.ReturnValue, oRestrictions.UrlParams, .RequiredValues)
				' Сформируем наименование файла с кешем
				sFilePefix = X_GetListCacheFileNameCommonPart(.TypeName, .ListMetaname, sRestrictions)
				sDataName =  sFilePefix & Eval(CacheSalt)
				' Конструируем новый кэш
				Set oData = XService.XmlGetDocument()
				Set oData = oData.appendChild( oData.CreateElement("root") )
				With oData.AppendChild( oData.ownerDocument.createElement("entry") )
					.SetAttribute "restr", sRestrictions
					.AppendChild HtmlElement.xml
				End With
				' Сохраняем корневой элемент в клиентском кэше
				X_SaveDataCache sDataName, oData
			End If
		End With
	End Sub


	'==========================================================================
	' Загружает список
	' [in] nCacheBehavior - режим использования кеша (константы CACHE_BEHAVIOR_*)
	Private Sub LoadInternal(nCacheBehavior)
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass
		
		Set oSelectorRestrictions = new GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions

		With New LoadListEventArgsClass
			.TypeName = ValueObjectTypeName
			.ListMetaname = HtmlElement.GetAttribute("ListMetaname")
			.RequiredValues = ValueID
			.Cache = nCacheBehavior
			.CacheSalt = CacheSalt
			Set .Restrictions = oSelectorRestrictions
			FireEvent "LoadList", .Self()
			m_bHasMoreRows = .HasMoreRows
		End With
	End Sub


	'==========================================================================
	' Очищает кэш 
	' [in] bOnlyForCurrentRestrictions - признак удалить не весь кэш вообще
	'		а только кэш для текущих ограничений, 
	'		полученных в результате выполнения обработчика события GetRestrictions
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
		X_ClearListDataCache ValueObjectTypeName, HtmlElement.GetAttribute("ListMetaname"), vRestrictions
	End Sub


	'==========================================================================
	' Стандартный обработчик события "LoadList"
	' [in] oEventArgs As LoadListEventArgsClass
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
			' Загрузим список (кодирование и анализ параметров делаются в X_LoadXListViewUseCache)
			On Error Resume Next
			ListView.LockEvents = True
			' перегрузим
			.HasMoreRows = X_LoadXListViewUseCache( .Cache, HtmlElement, .TypeName, .ListMetaname, sRestrictions, sUrlParams, .RequiredValues, .CacheSalt )
			If Err Then
				X_SetLastServerError XService.LastServerError, Err.number, Err.Source, Err.Description
				With X_GetLastError
					If .IsServerError Then
						On Error Goto 0
						' на сервере произошла ошибка
						If .IsSecurityException Then
							' произошла ошибка при чтении объектов
							ClearComboBox
							m_oEditorPage.EnablePropertyEditor Me, False
						End If
						.Show
					Else
						' ошибка произошла на клиенте - это ошибка в XFW
						aErr = Array(Err.Number, Err.Source, Err.Description)
						On Error Goto 0
						Err.Raise aErr(0), aErr(1), aErr(2)				
					End If
				End With
			End If
		End With
		UpdateXListViewColumnsFromCache HtmlElement, m_sViewStateCacheFileName
		HtmlElement.LockEvents = False
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property


	'==========================================================================
	' IPropertyEdior: Устанавливает значение в списке
	Public Sub SetData
		Dim i
		Dim oRow					' IXListRow - строка списка
		Dim oXmlObject
		Dim oXmlProperty
		Dim sObjectID
		Dim bFound
		
		ListView.LockEvents = True
		Set oXmlObject = Value
		If oXmlObject Is Nothing Then
			' свойство не установлено - снимем все чекбоксы
			HtmlElement.Rows.UnCheckAll
		Else
			bFound = False
			For i=0 To HtmlElement.Rows.Count-1
				Set oRow = HtmlElement.Rows.GetRow(i)
				If oRow.ID = oXmlObject.getAttribute("oid") Then
					oRow.Checked = True
					bFound = True
				Else
					oRow.Checked = False
				End If
			Next
			If Not bFound Then
				' в списке нет строки, соответствующей текущему объекту
				If m_bHasMoreRows Then
					' были получены не все записи, поэтому заблокируем свойство
					ParentPage.EnablePropertyEditor Me, False
					MsgBox "Внимание! Значение реквизита """ & PropertyDescription & """ не может быть отображено корректно, " & vbCr & _
						"т.к. полученный список значений с сервера был ограничен условием на максимальное количество строк.", vbExclamation
					Exit Sub
				Else
					' удалим объект
					m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.selectSingleNode("*[@oid='" & sObjectID &"']")
				End If
			End If
		End If
		
		ListView.LockEvents = False
	End Sub


	'==========================================================================
	' IPropertyEdior: Сбор данных
	Public Sub GetData(oGetDataArgs)
		' сохраним колонки
		X_SaveViewStateCache m_sViewStateCacheFileName, HtmlElement.Columns.Xml
		' Не задано значение - проверим на допустимость NULL'a
		ValueCheckOnNullForPropertyEditor ValueID, m_oPropertyEditorBase, oGetDataArgs, Mandatory
	End Sub


	'==========================================================================
	' IPropertyEdior: 
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If (bMandatory) Then
			HtmlElement.removeAttribute "X_MAYBENULL"
		Else	
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
		End If
	End Property


	'==========================================================================
	' IPropertyEdior: Установка/получение (не)доступности контрола
	Public Property Get Enabled
		Enabled = HtmlElement.object.Enabled 
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.object.Enabled = bEnabled
		' Не забывам про кнопку операции обновления кэша:
		If Not IsNothing(RefreshButton) Then RefreshButton.disabled = Not( bEnabled )
		ExtraHtmlElement("Deselect").disabled = Not( bEnabled )
		If Not IsNothing(ExtraHtmlElement("Select")) Then ExtraHtmlElement("Select").disabled = Not (bEnabled)
	End Property


	'==========================================================================
	' IPropertyEdior: Установка фокуса
	Public Function SetFocus
		' Бубен! Без window.focus фокус иногда не устанавливается
		window.focus	
		SetFocus = X_SafeFocus( HtmlElement )
		window.focus	
	End Function


	'==========================================================================
	' IPropertyEdior: Возвращает IHTMLObjectElement
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property


	'==========================================================================
	' Возвращает дополнительный контрол IHTMLElement
	Private Function ExtraHtmlElement(sName)
		Set ExtraHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.id & sName)
	End Function

	
	'==========================================================================
	' Возвращает XListView
	Public Property Get ListView
		Set ListView = m_oPropertyEditorBase.HtmlElement.object
	End Property

	
	'==========================================================================
	' Возвращает HTML-элемент кнопки обновления списка
	Public Property Get RefreshButton
		Set RefreshButton = m_oRefreshButton
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
	' Очистка ссылок
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
		Set m_oPropertyEditorBase = Nothing
	End Sub	
	
	
	'==========================================================================
	' Выбрасывает событие
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
			Set Value = m_oPropertyEditorBase.ObjectEditor.Pool.GetXmlObjectByXmlElement( oXmlProperty.FirstChild, Null )
		End If
	End Property
	
	
	'==========================================================================
	' Возвращает идентификаторы объектов-значений xml-свойства
	Public Property Get ValueID
		Dim oXmlProperty
		Set oXmlProperty = XmlProperty
		ValueID = Null
		If Not oXmlProperty.FirstChild Is Nothing Then
			ValueID = oXmlProperty.FirstChild.getAttribute("oid")
		End If
	End Property
	
	
	'==========================================================================
	' Возвращает наименование типа объекта значения свойства
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyEditorBase.ValueObjectTypeName
	End Property
	
	
	'==========================================================================
	' Обработчик ActiveX события OnChechChange, устанволенный в xslt-шаблоне.
	' Для внутреннего использования
	' Примечание: обработчик должен вызываться синхронно, 
	' т.к. рекурсивно вызывает себя путем изменения свойства контрола, которое вызывает его срабатывание!
	Public Sub Internal_OnCheckChange( nRow, sRowID, bPrevState, bNewState )
		Dim oXmlProperty	' As IXMLDOMElement - xml-свойство
		Dim oOldValue
		Dim oRow
		
		Set oXmlProperty = XmlProperty
		With New SelectedEventArgsClass
			.RowIndex = nRow
			If bPrevState And Not bNewState Then
				' разотметили объект - выкиним сссылку на него из свойства
				m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.selectSingleNode("*[@oid='" & sRowID &"']")
				.OldValue = sRowID
				FireEvent "UnSelected", .Self()
			ElseIf bNewState And Not bPrevState Then
				' отметили объект - удалим текушее значение св-ва и занесем новое значение
				Set oOldValue = oXmlProperty.firstChild
				If Not oOldValue Is Nothing Then
					' снимем галочку со строки, соответствующей объекту в свойстве
					Set oRow = HtmlElement.Rows.GetRowByID( oOldValue.getAttribute("oid") )
					' это вызовет рекурсивный вызов, но попадем уже в предыдущий if
					oRow.Checked = False
				End If
				m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, X_CreateObjectStub(ValueObjectTypeName, sRowID)
				.NewValue = sRowID
				FireEvent "Selected", .Self()
			End If
		End With
	End Sub


	'==========================================================================
	' Обработчик двойного клика по строке
	Public Sub Internal_OnDblClick( nIndex, nColumn, sID )
		Dim oRow
		If Len("" & sID) > 0 Then
			Set oRow = HtmlElement.Rows.GetRowByID(sID)
			oRow.Checked = Not oRow.Checked
		End If
	End Sub
	
	'==========================================================================
	' Обработчик кнопки "Снять выделение" 	
	Public Sub Deselect
		Dim i
		For i=0 To HtmlElement.Rows.Count-1
			If HtmlElement.Rows.GetRow(i).Checked = True Then
				HtmlElement.Rows.GetRow(i).Checked = False
			End If
		Next
	End Sub
	

	'==========================================================================
	' Обработчик нажатия кнопки "Выбрать"
	Public Sub Internal_OnSelectClick
		Dim oValues
		Set oValues = CreateObject("Scripting.Dictionary")
		oValues.item("ListSelectorMetaname") = m_sListSelectorMetaname
		oValues.item("TreeSelectorMetaname") = m_sTreeSelectorMetaname
		m_oPropertyEditorBase.DoSelectFromDb oValues
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
		
		Set oXmlProperty = XmlProperty
		' Получаем тип объекта-значения
		sType = m_oPropertyEditorBase.ValueObjectTypeName
		' получим пользовательские ограничения для селектора через событие GetSelectorRestrictions 
		' (Событие GetRestrictions используется для заполнения основного списка)
		With New GetRestrictionsEventArgsClass
			FireEvent "GetSelectorRestrictions", .Self()
			sParams = .ReturnValue
			' параметры в селектор из параметров пункта меню
			sUrlArguments = oEventArgs.UrlArguments
			' и добавим параметры в селектор от обработчиков события "GetSelectorRestrictions"
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
		Else
			' Покажем диалог и получим выбранное значение
			With New SelectFromTreeDialogClass
				.Metaname = oEventArgs.SelectorMetaname
				.LoaderParams = sParams
				If hasValue(sUrlArguments) Then
					.UrlArguments.QueryString = sUrlArguments
				End If
				
				' Если объект ссылается сам на себя, то не дадим ему выбрать себя в стандартном дереве
				If Not hasValue(sExcludeNodes) And sType = oXmlProperty.parentNode.tagName Then
					sExcludeNodes = sType & "|" & oXmlProperty.parentNode.GetAttribute("oid")
				End If
				.ExcludeNodes = sExcludeNodes
				
				SelectFromTreeDialogClass_Show .Self
				
				If .ReturnValue Then
					vRet = .Selection.selectSingleNode("n").getAttribute("id")
				End If				
			End With
		End If
		oEventArgs.Selection = vRet
	End Sub

	
	'==========================================================================
	' Стандартный обработчик события "BindSelectedData"
	' [in] oSender - экземпляр XPEObjectListSelectorClass, источник события.
	' [in] oEventArgs - экземпляр SelectEventArgsClass, параметры события.
	' Данный обработчик производит замену текущего значения объектной ссылки
	' на отобранную в результате обработки события "OnSelect".
	' Также обновляется текстовое представление объекта
	Public Sub OnBindSelectedData(oSender, oEventArgs)
		Dim oXmlProperty		' xml-свойство
		Dim sObjectID			' идентификатор выбранного объекта
		Dim oListData
		Dim oFields
		Dim oField
		Dim aRowData
		Dim oRow
		Dim i
		
		Set oXmlProperty = XmlProperty
		sObjectID = oEventArgs.Selection

		If HtmlElement.Rows.FindRowByID(sObjectID) Is Nothing Then
			' если выбраного объекта еще нет в дереве
			Set oListData = X_GetListDataFromServer(ValueObjectTypeName, HtmlElement.GetAttribute("ListMetaname"), X_CreateListLoaderRestrictions(Empty, Empty, sObjectID))
			Set oRow = oListData.selectSingleNode("//RS/R")
			If Not oRow Is Nothing Then
				Set oFields = oRow.selectNodes("F")
				ReDim aRowData(oFields.length)
				i = 0
				For Each oField In oFields
					aRowData(i) = oField.nodeTypedValue
					i = i + 1
				Next
				
				' А теперь найдем добавим строку в список и установим ей checkbox
				Set oRow = HtmlElement.Rows.Insert(-1, aRowData, sObjectID )
				oRow.IconURL = HtmlElement.XImageList.MakeIconUrl( ValueObjectTypeName, "", "")
				oRow.Checked = True
			End If
		Else
			MsgBox "Выбранный объект уже находится в списке", vbOkOnly + vbInformation 
		End If
	End Sub
	
	
	'==========================================================================
	' Возвращает/устанавливает признак кэширования 
	' см. i:list-selector/@use-cache
	Public Property Get UseCache
		UseCache = (m_bUseCache=True)
	End Property
	Public Property Let UseCache(vValue)
		m_bUseCache = (vValue=True)
	End Property


	'==========================================================================
	' Возвращает/устанавливает параметр кэширования
	' см. i:list-selector/@cache-salt
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
End Class
