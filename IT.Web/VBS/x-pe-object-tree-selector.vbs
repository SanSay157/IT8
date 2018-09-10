Option Explicit

'==========================================================================
' Класс редактора объектного свойства в виде дерева.
' Выбранный объект заносится в свойство при сборе данных (GetData).
' USE-CASE: Для использовании в мастере для задания объектного скалярного свойства. 
' ВНИМАНИЕ: Для использования в редакторах при модификации объекта НЕ ПРЕДУСМОТРЕН!
' События:
'	Load	- загрузка дерева
'	GetRestrictions - получение ограничений для загрузчика дерева
Class XPEObjectTreeSelectorClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private EVENTS						' As String	- список событий страницы
	Private m_sLoader					' As String	- URL загрузчика списка
	Private m_sMetaName					' As String	- метаимя описание PE (i:tree-selector)
	Private m_sTreeSelectorMetaName		' As String	- метаимя описания селектора (i:objects-tree-selector)
	Private m_oTreeSelectorMD			' As IXMLDOMElement - узел i:objects-tree-selector
	Private m_sSelectionMode			' As String - режим отбора (Константы TSM_*)
	Private m_sViewStateCacheFileName	' As String - наименование файла с закешированным представлением
	Private m_bKeyUpEventProcessing		' As Boolean - Признак обработки ActiveX-события OnKeyUp для "разбухания" стэка
	
	'Реализация drag&drop тут не реализована, может быть сделана по требованию
	'Private m_oDragDropController       ' AS TreeViewNodeDragDropController - контроллер операции переноса узлов дерева
	
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "Load,GetRestrictions,Accel"
	End Sub
	
	'==========================================================================
	' IPropertyEditor: 
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectTreeSelector"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEvent "Load", Me, "OnLoad"
		m_sMetaName = HtmlElement.GetAttribute("Metaname")
		If m_oPropertyEditorBase.PropertyEditorMD Is Nothing Then Err.Raise -1, "XPEObjectsTreeSelectorClass::Init", "Не найдено описание редактора свойства (i:tree-selector) в МД"
		Set m_oTreeSelectorMD = m_oPropertyEditorBase.PropertyEditorMD.selectSingleNode("i:objects-tree-selector")
		If m_oTreeSelectorMD Is Nothing Then Err.Raise -1, "XPEObjectsTreeSelectorClass::Init", "Не задан узел i:objects-tree-selector для i:tree-selector"
		' получим режим выбора, по умолчанию все узлы (поддерживаемого типа)
		m_sSelectionMode  = X_GetAttributeDef(m_oTreeSelectorMD, "selection-mode", TSM_ANYNODES)
		' получим метаимя селектора
		m_sTreeSelectorMetaName = m_oTreeSelectorMD.GetAttribute("n")
		m_sLoader = "x-tree-loader.aspx?metaname=" & m_sTreeSelectorMetaName
		m_sViewStateCacheFileName = ObjectEditor.Signature() & "XTreeSelector." + oXmlProperty.parentNode.tagName & "." & oXmlProperty.tagName & "." & m_oPropertyEditorBase.PropertyEditorMD.getAttribute("n")
	End Sub
	
	'==========================================================================
	' IPropertyEdior: Метод вызывается при построении страницы редактора, после инициализации всех PE на странице
	Public Sub FillData()
		Dim sPath
		Load
		' развернем дерево по путям до отмеченных узлов при предыдущем редактированнии
		If X_GetDataCache( m_sViewStateCacheFileName, sPath ) Then
			TreeView.SetNearestPath sPath, False
		End If
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
	' Загружает дерево
	Public Sub Load
		FireEvent "Load", Nothing
	End Sub

	'==========================================================================
	' Обработчик события Load
	Public Sub OnLoad(oSender, oEventArgs)
		' Установим режимы отображения
		SelectionMode = m_sSelectionMode
		' выбирать можно только узлы, чей типа соответствует типу объекта значения свойства
		TreeView.SelectableTypes = ValueObjectTypeName
		TreeView.Loader = m_sLoader
		On Error Resume Next
		' Примечание: подстановка параметров выполниться в обработчике события OnDataLoading (Internal_OnDataLoading)
		TreeView.Reload
		If X_ErrOccured() Then
			X_ErrReport()
			Exit Sub
		End If	
	End Sub
	
	'==========================================================================
	' Устанавливает/возвращает режимы отображения дерева (признак множественного выбора и признак отбора только листовых узлов)
	Public Property Let SelectionMode(sMode)
		m_sSelectionMode = sMode
		Select Case m_sSelectionMode 
			Case TSM_LEAFNODE
				TreeView.IsOnlyLeafSel = True
			Case TSM_LEAFNODES
				TreeView.IsOnlyLeafSel = True
			Case TSM_ANYNODE
				TreeView.IsOnlyLeafSel = False
			Case TSM_ANYNODES 
				TreeView.IsOnlyLeafSel = False
			Case Else
				Err.Raise -1, "::SelectionMode", "Неизвестный режим отображения"
		End Select
	End Property
	Public Property Get SelectionMode
		SelectionMode = m_sSelectionMode
	End Property

	
	'==========================================================================
	' Возвращает xml-объекты-значения xml-свойства
	'	[retval] IXMLDOMElement объект-значение в пуле, либо Nothing, если св-во пустое
	Public Property Get Value
		Dim oXmlProperty		' As IXMLDOMElement
		
		Set oXmlProperty = XmlProperty
		If oXmlProperty.FirstChild Is Nothing Then
			Set Value = Nothing
		Else	
			' Загрузим объект-значение
			Set Value = m_oPropertyEditorBase.ObjectEditor.Pool.GetXmlObjectByXmlElement( oXmlProperty.FirstChild, Null )
		End If
	End Property
	
	
	'==========================================================================
	' Возвращает идентификатор объектa-значеня xml-свойства
	Public Property Get ValueID
		Dim oXmlProperty
		Set oXmlProperty = XmlProperty
		ValueID = Null
		If Not oXmlProperty.FirstChild Is Nothing Then
			ValueID = oXmlProperty.FirstChild.getAttribute("oid")
		End If
	End Property
	
	'==========================================================================
	' IPropertyEditor: Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property

	'==========================================================================
	' IPropertyEditor: Устанавливает значение в дереве
	Public Sub SetData
		' Т.к. дерево у нас загружается с сервера, то его содержимое не зависит от данных в текущем Xml,
		' поэтому никак обновлять представление не будем.
	End Sub

	'==========================================================================
	' IPropertyEditor: Сбор данных
	Public Sub GetData(oGetDataArgs)
		Dim oNode
		' сохраним выбранные пути до выбранных узлов, кроме корневых
		Set oNode = TreeView.ActiveNode
		If Not oNode Is Nothing Then
			XmlProperty.selectNodes("*").removeAll
			ObjectEditor.Pool.AddRelation Nothing, XmlProperty, X_CreateObjectStub(oNode.Type, oNode.ID)
			X_SaveDataCache m_sViewStateCacheFileName, oNode.Path
		Else
			' Не задано значение - проверим на допустимость NULL'a
			ValueCheckOnNullForPropertyEditor ValueID, m_oPropertyEditorBase, oGetDataArgs, Mandatory
		End If
	End Sub
	
	'==========================================================================
	' IPropertyEditor: 
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
	' IPropertyEditor: Установка/получение (не)доступности контрола
	Public Property Get Enabled
		Enabled = HtmlElement.object.Enabled
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.object.Enabled = bEnabled
		ExtraHtmlElement("ExpandAll").disabled = Not( bEnabled )
		ExtraHtmlElement("CollapseAll").disabled = Not( bEnabled )
		ExtraHtmlElement("Reload").disabled = Not( bEnabled )
	End Property
	
	'==========================================================================
	' IPropertyEditor: Установка фокуса
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function
	
	'==========================================================================
	' IPropertyEditor: Возвращает IHTMLObjectElement
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property
	
	'==========================================================================
	' Возвращает XTreeView
	Public Property Get TreeView
		Set TreeView = m_oPropertyEditorBase.HtmlElement.object
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
	' Возвращает наименование типа объекта значения свойства
	Public Property Get ValueObjectTypeName
		ValueObjectTypeName = m_oPropertyEditorBase.ValueObjectTypeName
	End Property
	
	'==========================================================================
	' Возвращает дополнительный контрол IHTMLElement
	Private Function ExtraHtmlElement(sName)
		Set ExtraHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.id & sName )
	End Function
	
	'==========================================================================
	' Обработчик кнопки "Свернуть всё"
	Public Sub Internal_OnCollapseAll
		Dim oNode	' As IXTreeNode
		Dim i
		' просто свернем все корневые узлы
		For i=0 To TreeView.Root.Count-1
			Set oNode = TreeView.Root.GetNode(i)
			oNode.Expanded = False
		Next
	End Sub
	
	'==========================================================================
	' Обработчик кнопки "Развернуть всё"
	Public Sub Internal_OnExpandAll
		m_oPropertyEditorBase.ObjectEditor.EnableControls False
		ExpandNode TreeView.Root
		m_oPropertyEditorBase.ObjectEditor.EnableControls True
	End Sub
	
	'==========================================================================
	' Внутренний метод рекурсивного разворачивания узлов
	'	[in] oTreeNodes As IXTreeNodes
	Private Sub ExpandNode(oTreeNodes)
		Dim oTreeNode	' As IXTreeNode
		Dim i
		
		If oTreeNodes Is Nothing Then Exit Sub
		If oTreeNodes.Count=0 Then Exit Sub
		For i=0 To oTreeNodes.Count-1
			Set oTreeNode = oTreeNodes.GetNode(i)
			oTreeNode.Expanded = True
			' ВНИМАНИЕ: обращение к свойству Children приводит к выполнению команды загрузчика getchildren (даже для листового узла) !
			If Not oTreeNode.IsLeaf Then
				ExpandNode oTreeNode.Children
			End If
		Next
	End Sub
	
	'==========================================================================
	' Обработчик кнопки "Обновить"
	Sub Internal_OnReload
		Load
	End Sub
	
	'==============================================================================
	' Обработчик события OnDataLoading для oTreeView.
	'	Используется для включения в запрос на получение данных
	'	иерархии информации фильтра.
	Sub Internal_OnDataLoading( oSender,  nQuerySet,  sNodePath,  sObjectType,  sObjectID,  oRestrictions)
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass
		Dim sRestrictions	' параметры в список от юзерских обработчиков
		
		' получим ограничения от пользовательских скриптов
		Set oSelectorRestrictions = New GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions
		sRestrictions = oSelectorRestrictions.ReturnValue

		internal_TreeInsertRestrictions oRestrictions, sRestrictions
	End Sub
	
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
