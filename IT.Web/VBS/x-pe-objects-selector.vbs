Option Explicit

'==========================================================================
' Класс редактора массивных свойств в виде read-only-списка  с чекбоксами.
' При выделении объекта он заносится в свойства, при снятии - удаляется.
' События:
'	LoadList	- загрузка списка (LoadListEventArgsClass), есть стандартный обработчик
'	Selected	- выбор элемента, занесение объекта в свойство (SelectedEventArgsClass)
'	UnSelected	- снятие выделения с элемента, удаления объекта из свойства (SelectedEventArgsClass)
Class XPEObjectsSelectorClass
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
	Private m_bOffIcons					' As Boolean - признак отключения показа иконок
	Private m_bKeyUpEventProcessing		' As Boolean - Признак обработки ActiveX-события OnKeyUp для предотвращения бесконечного цикла
	
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "LoadList,Selected,UnSelected,GetRestrictions,Accel"
	End Sub


	'==========================================================================
	' IPropertyEdior: инициализация редактора свойства
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim vMetaName		' метаимя списка для наполнения ListView
		Dim sXPath			' XPAth -запрос
		
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectsSelector"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEvent "LoadList", Me, "OnLoadList"
		
		' i:list-selector ссылается на i:objects-list в типе объекта значения свойства
		' сформируем xpath для поиска objects-list'a в МД
		vMetaName = HtmlElement.GetAttribute("ListMetaname")
		
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
		m_sViewStateCacheFileName = ObjectEditor.Signature() & "XArrayProp." + oXmlProperty.parentNode.tagName & "." & oXmlProperty.tagName & "." & m_oPropertyEditorBase.PropertyEditorMD.getAttribute("n")
		InitXListViewInterface HtmlElement, X_GetTypeMD(ValueObjectTypeName).selectSingleNode(sXPath), m_sViewStateCacheFileName, False
		
		If Not IsNull( HtmlElement.getAttribute("off-rownumbers")) Then ListView.LineNumbers = False
		m_bOffIcons = Not IsNull(HtmlElement.getAttribute("off-icons"))
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
				.style.height = ExtraHtmlElement("SelectAll").offsetHeight
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
			If m_bOffIcons Then
				HtmlElement.ShowIcons = False
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
		Dim sVisibleObjectIDList	' As String - список идентификаторов через запятую, отображаемых в списке
		Dim oXmlObject
		Dim oXmlProperty
		Dim sObjectID
		
		ListView.LockEvents = True
		For i=0 To HtmlElement.Rows.Count-1
			Set oRow = HtmlElement.Rows.GetRow(i)
			If XmlProperty.selectSingleNode("*[@oid='" & oRow.ID & "']") Is Nothing Then
				oRow.Checked = False
			Else
				oRow.Checked = True
				sVisibleObjectIDList = sVisibleObjectIDList & " " & oRow.ID
			End If
		Next
		' А есть ли в свойстве объекты, для которых нет соответствующей строки в списке?
		Set oXmlProperty = XmlProperty
		For Each oXmlObject In oXmlProperty.selectNodes("*")
			sObjectID = oXmlObject.getAttribute("oid")
			If 0=InStr( sVisibleObjectIDList, sObjectID ) Then
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
		Next
		ListView.LockEvents = False
	End Sub


	'==========================================================================
	' IPropertyEdior: Сбор данных
	Public Sub GetData(oGetDataArgs)
		' сохраним колонки
		X_SaveViewStateCache m_sViewStateCacheFileName, HtmlElement.Columns.Xml
	End Sub


	'==========================================================================
	' IPropertyEdior: 
	Public Property Get Mandatory
		Mandatory = False
	End Property
	Public Property Let Mandatory(bMandatory)
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
		ExtraHtmlElement("SelectAll").disabled = Not( bEnabled )
		ExtraHtmlElement("InvertSelection").disabled = Not( bEnabled )
		ExtraHtmlElement("DeselectAll").disabled = Not( bEnabled )
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
	' Возвращает наименование типа объекта значения свойства
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyEditorBase.ValueObjectTypeName
	End Property
	
	
	'==========================================================================
	' Обработчик ActiveX события OnChechChange, устанволенный в xslt-шаблоне.
	' Для внутреннего использования
	Public Sub Internal_OnCheckChange( nRow, sRowID, bPrevState, bNewState )
		Dim i
		Dim oRowBefore		' xml-заглушка объекта в свойстве, соответствующая следующей отмеченной строке в списке
		Dim oXmlProperty	' As IXMLDOMElement - xml-свойство

		Set oXmlProperty = XmlProperty
		With New SelectedEventArgsClass
			.RowIndex = nRow
			If bPrevState And Not bNewState Then
				' разотметили объект - выкиним сссылку на него из свойства
				m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.selectSingleNode("*[@oid='" & sRowID &"']")
				.OldValue = sRowID
				FireEvent "UnSelected", .Self()
			ElseIf bNewState And Not bPrevState Then
				' отметили объект - занесем ссылку на него в свойства
				' если свойство упорядоченное, то добавим заглушку с учетом порядка, иначе просто в конец
				If m_oPropertyEditorBase.PropertyMD.getAttribute("cp") = "array" Then
					For i=nRow+1 To HtmlElement.Rows.Count-1
						If HtmlElement.Rows.GetRow(i).Checked Then
							Set oRowBefore = oXmlProperty.selectSingleNode("*[@oid='" & HtmlElement.Rows.GetRow(i).ID & "']")
							Exit For
						End If
					Next
					m_oPropertyEditorBase.ObjectEditor.Pool.AddRelationWithOrder Nothing, oXmlProperty, X_CreateObjectStub(ValueObjectTypeName, sRowID), oRowBefore
				Else
					m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, X_CreateObjectStub(ValueObjectTypeName, sRowID)
				End If
				.NewValue = sRowID
				FireEvent "Selected", .Self()
			End If
		End With
	End Sub


	'==========================================================================
	' Обработчик кнопки "Выбрать все"
	Public Sub SelectAll
		Dim i
		For i=0 To HtmlElement.Rows.Count-1
			If HtmlElement.Rows.GetRow(i).Checked = False Then
				HtmlElement.Rows.GetRow(i).Checked = True
			End If
		Next
	End Sub
	

	'==========================================================================
	' Обработчик кнопки "Снять выделение" 	
	Public Sub DeselectAll
		Dim i
		For i=0 To HtmlElement.Rows.Count-1
			If HtmlElement.Rows.GetRow(i).Checked = True Then
				HtmlElement.Rows.GetRow(i).Checked = False
			End If
		Next
	End Sub
	
	
	'==========================================================================
	' Обработчик кнопки "Изменить выделение"
	Public Sub InvertSelection
		Dim i
		For i=0 To HtmlElement.Rows.Count-1
			HtmlElement.Rows.GetRow(i).Checked = Not HtmlElement.Rows.GetRow(i).Checked
		Next
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


'==============================================================================
' Восстанавливает из кеша колонок
'	[in] oListView As XListView - список
'	[in] sCacheKey As String - ключ к закешированному описанию колонок на клиентском компьютере
Sub UpdateXListViewColumnsFromCache(oListView, sCacheKey)
	Dim oColumnsFromCache 	' закешированное xml-описание колонок
	Dim oColumns			' текущее xml-описание колонок
	Dim oColumnXml			' узел C xml-описания колонки
	Dim oColumn				' CROC.IXListColumn
	Dim nWidth				' Ширина колонки
	Dim vOrder				' Сортировка колонки (значение атрибута order)
	
	' Попробуем восстановить данные о столбцах
	If HasValue(sCacheKey) Then
		If X_GetViewStateCache( sCacheKey, oColumnsFromCache) Then
			If Not IsObject(oColumnsFromCache) Then Exit Sub
			Set oColumns = oListView.Columns.Xml
			For Each oColumnXml In oColumnsFromCache.SelectNodes("C")
				Set oColumn = oListView.Columns.GetColumnByName(oColumnXml.getAttribute("name"))
				If Not oColumn Is Nothing Then
					' колонка из кеша присутствует в списке
					' восстановим ширину
					nWidth = oColumnXml.getAttribute("width")

					If Not IsNull(nWidth) Then
						nWidth = CLng("0" & nWidth)
					Else
						nWidth = 0
					End If
					
					If nWidth > 0 Then
						oColumn.Width = nWidth
					Else
						oColumn.Hidden = True
					End If
					' восстановим сортировку
					vOrder = oColumnXml.getAttribute("order")
					If Not IsNull(vOrder) Then
						If vOrder = "asc" Then
							oColumn.Order = CORDER_ASC
						ElseIf vOrder = "desc" Then
							oColumn.Order = CORDER_DESC
						End If
					End If
				End If
			Next
		End If
	End If
End Sub


'==============================================================================
' Параметры событий "Selected", "UnSelected"
Class SelectedEventArgsClass
	Public Cancel			' признак отмены для цепочки обработчиков. 
	Public OldValue			' старое значение, если задано, значит объект разотметили (сняли чекбокс)
	Public NewValue			' новое значение, если задано, значит объект отметили (установили чекбокс)
	Public RowIndex			' индекс строки объекта, над которым произвели операцию
	Public Function Self
		Set Self = Me
	End Function
End Class
