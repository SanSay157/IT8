Option Explicit

'==========================================================================
' Класс редактора массивных свойств в виде read-only-списка  с чекбоксами.
' При выделении объекта он заносится в свойства, при снятии - удаляется.
' События:
'	Load		- загрузка (Nothing), есть стандартный обработчик
'	Selected	- выбор элемента, занесение объекта в свойство (SelectedEventArgsClass)
'	UnSelected	- снятие выделения с элемента, удаления объекта из свойства (SelectedEventArgsClass)
Class XPEObjectsTreeSelectorClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private EVENTS						' As String	- список событий страницы
	Private m_sLoader					' As String	- URL загрузчика списка
	Private m_sMetaName					' As String	- метаимя описание PE (i:tree-selector)
	Private m_sTreeSelectorMetaName		' As String	- метаимя описания селектора (i:objects-tree-selector)
	Private m_bLoading					' As Boolean - признак загрузки
	Private m_oTreeSelectorMD			' As IXMLDOMElement - узел i:objects-tree-selector
	Private m_sSelectionMode			' As String - режим отбора (Константы TSM_*)
	Private m_sViewStateCacheFileName	' As String - наименование файла с закешированным представлением
	Private m_bKeyUpEventProcessing		' As Boolean - Признак обработки ActiveX-события OnKeyUp для предотвращения бесконечного цикла
	Private m_oDragDropController       ' AS TreeViewNodeDragDropController - контроллер операции переноса узлов дерева
	
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "Load,Selected,UnSelected,GetRestrictions,Accel"
	End Sub
 
	'==========================================================================
	' IPropertyEditor: 
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorObjectBaseClass
		m_oPropertyEditorBase.Init Me, oEditorPage, oXmlProperty, oHtmlElement, EVENTS, "ObjectsTreeSelector"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEvent "Load", Me, "OnLoad"
		
		m_sMetaName = HtmlElement.GetAttribute("Metaname")
		If m_oPropertyEditorBase.PropertyEditorMD Is Nothing Then Err.Raise -1, "XPEObjectsTreeSelectorClass::Init", "Не найдено описание редактора свойства (i:tree-selector) в МД"
		Set m_oTreeSelectorMD = m_oPropertyEditorBase.PropertyEditorMD.selectSingleNode("i:objects-tree-selector")
		If m_oTreeSelectorMD Is Nothing Then Err.Raise -1, "XPEObjectsTreeSelectorClass::Init", "Не задан узел i:objects-tree-selector для i:tree-selector"
		' получим режим выбора, по умолчанию все узлы (поддерживаемого типа)
		m_sSelectionMode  = X_GetAttributeDef(m_oTreeSelectorMD, "selection-mode", TSM_ANYNODES)
		' получим метаимя селектора
		m_sTreeSelectorMetaName = m_oTreeSelectorMD.GetAttribute("n")
		
		Set m_oDragDropController = Nothing

        If m_oPropertyEditorBase.PropertyEditorMD.GetAttribute("allow-drag-drop") = "1" Then
		    ' Инициализация контроллера операции переноса
		    Set m_oDragDropController = New TreeNodeDragDropController
		    m_oDragDropController.EventEngine.InitHandlers XTREENODEDRAGDROPCONTROLLER_EVENTS, "usr_" & oXmlProperty.ParentNode.tagName & "_" & oXmlProperty.tagName & "_ObjectsTreeSelector_On"
		    m_oDragDropController.EventEngine.InitHandlers XTREENODEDRAGDROPCONTROLLER_EVENTS, "usr_" & oXmlProperty.ParentNode.tagName & "_" & oXmlProperty.tagName & "_On"
		    m_oDragDropController.EventEngine.InitHandlers XTREENODEDRAGDROPCONTROLLER_EVENTS, "usr_" & oXmlProperty.tagName & "_ObjectsTreeSelector_On"
		    m_oDragDropController.EventEngine.InitHandlers XTREENODEDRAGDROPCONTROLLER_EVENTS, "usr_ObjectsTreeSelector_On"
		End If
		
		m_sLoader = "x-tree-loader.aspx?metaname=" & m_sTreeSelectorMetaName
		m_sViewStateCacheFileName = ObjectEditor.Signature() & "XTreeSelector." + oXmlProperty.parentNode.tagName & "." & oXmlProperty.tagName & "." & m_oPropertyEditorBase.PropertyEditorMD.getAttribute("n")
	End Sub

	
	'==========================================================================
	' IPropertyEdior: Метод вызывается при построении страницы редактора, после инициализации всех PE на странице
	Public Sub FillData()
		Load
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
	' Возвращает путь в дереве в формате Тип|Идентификатор|Тип|Идентификатор из xml-узла описания положения ноды в формате
	' <n ot=".." id=".." t=".."><n ../></n>
	Public Function GetPathFromXml(oNode)
		Dim oSubNode
		Dim sPath
		For Each oSubNode In oNode.selectNodes("descendant-or-self::n")
			If Len(sPath)>0 Then sPath = sPath & "|" 
			sPath = sPath & oSubNode.getAttribute("ot") & "|" & oSubNode.getAttribute("id")
		Next
		GetPathFromXml = sPath
	End Function

	
	'==========================================================================
	' Загружает дерево
	Public Sub Load()
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
				TreeView.IsMultipleSel = False
			Case TSM_LEAFNODES
				TreeView.IsOnlyLeafSel = True
				TreeView.IsMultipleSel = True
			Case TSM_ANYNODE
				TreeView.IsOnlyLeafSel = False
				TreeView.IsMultipleSel = False
			Case TSM_ANYNODES 
				TreeView.IsOnlyLeafSel = False
				TreeView.IsMultipleSel = True
			Case Else
				Err.Raise -1, "::SelectionMode", "Неизвестный режим отображения"
		End Select
	End Property
	Public Property Get SelectionMode
		SelectionMode = m_sSelectionMode
	End Property

	
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
	' IPropertyEditor: Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property


	'==========================================================================
	' IPropertyEditor: Устанавливает значение в дереве
	Public Sub SetData
		Dim oXmlProperty	' As IXMLDOMElement - xml-свойство
		Dim oSelection
		Dim oNode

		Set TreeView.Selection = Nothing
		Set oXmlProperty = XmlProperty
		If Not oXmlProperty.hasChildNodes Then Exit Sub
		processNodes oXmlProperty
		' развернем дерево по путям до отмеченных узлов при предыдущем редактированнии
		If X_GetDataCache( m_sViewStateCacheFileName, oSelection ) Then
			For Each oNode In oSelection.selectNodes("n[n]")
				TreeView.SetNearestPath GetPathFromXml(oNode), False
			Next
		End If
	End Sub
	
	'==========================================================================
	' IPropertyEditor: Сбор данных
	Public Sub GetData(oGetDataArgs)
		Dim oSelection		' отмеченные узлы дерева
		' сохраним выбранные пути до выбранных узлов, кроме корневых
		Set oSelection = TreeView.Selection.cloneNode(true)
		oSelection.selectNodes("n[not(n)]").removeAll
		X_SaveDataCache m_sViewStateCacheFileName, oSelection
	End Sub

	
	'==========================================================================
	' IPropertyEditor: Mandatory
	' Массивное свойство необязательное по определению
	Public Property Get Mandatory
		Mandatory = False
	End Property
	Public Property Let Mandatory(bMandatory)
	End Property


	'==========================================================================
	' IPropertyEditor: Установка/получение (не)доступности контрола
	Public Property Get Enabled
		Enabled = HtmlElement.object.Enabled
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.object.Enabled = bEnabled
		ExtraHtmlElement("Clear").disabled = Not( bEnabled )
		ExtraHtmlElement("ExpandAll").disabled = Not( bEnabled )
		ExtraHtmlElement("CollapseAll").disabled = Not( bEnabled )
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
		Set ExtraHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.id & sName)
	End Function

	
	'==========================================================================
	' Обработчик выбора элемента дерева. Устанавливается в xslt-шаблоне. 
	' Запускает асинхронно по таймеру
	' Для внутренного использования!
	'	[in] oNode - выбранная нода
	'	[in] bSelected - состояние checkbox'a ноды
	Public Sub Internal_OnSelChange( oNode, bSelected )
		Dim oXmlProperty	' As IXMLDOMElement - xml-свойство

		If m_bLoading Then Exit Sub
		Set oXmlProperty = XmlProperty
		With New NodeSelectedEventArgsClass
			Set .TreeNode = oNode
			.Checked = bSelected
			If bSelected Then
				' отметили объект - занесем ссылку на него в свойства
				' заглушку всегда добавляем в конец
				m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, X_CreateObjectStub(ValueObjectTypeName, oNode.ID)
				FireEvent "Selected", .Self()
			Else
				' разотметили объект - выкиним сссылку на него из свойства
				m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.selectSingleNode("*[@oid='" & oNode.ID &"']")
				FireEvent "UnSelected", .Self()
			End If
		End With
	End Sub	

	
	'==========================================================================
	' Обработчик начала загрузки уровня дерева (ActiveX-события OnDataLoaded - см. спецификация на XControls). 
	' Устанавливается в xslt-шаблоне. Для внутренного использования!
	'	[in] nQuerySet - действие, вызвавшее событие (константа QUERY_SET_*)
	'	[in] sNodePath - путь до узла, относительно которого была выполнена операция загрузки множества описаний элементов
	'	[in] sObjectType - 
	'	[in] sObjectID -
	'	[in] oRestrictions as IXMLDOMElement - xml-узел с ограничениями (подробней см процедуру internal_TreeInsertRestrictions)
	Public Sub Internal_OnDataLoading( nQuerySet, sNodePath, sObjectType, sObjectID, oRestrictions )
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass
		
		' получим ограничения от пользовательских скриптов
		Set oSelectorRestrictions = New GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions
		' и допишем их в xml-запрос загрузчику дерева
		internal_TreeInsertRestrictions oRestrictions, oSelectorRestrictions.ReturnValue
	End Sub


	'==========================================================================
	' Обработчик окончания загрузки уровня дерева (ActiveX-события OnDataLoaded - см. спецификация на XControls). 
	' Устанавливается в xslt-шаблоне. Для внутренного использования!
	'	[in] nQuerySet - действие, вызвавшее событие (константа QUERY_SET_*)
	'	[in] sNodePath - путь до узла, относительно которого была выполнена операция загрузки множества описаний элементов
	'	[in] sObjectType - 
	'	[in] sObjectID -
	Public Sub Internal_OnDataLoaded( nQuerySet, sNodePath, sObjectType, sObjectID )
		Dim oXmlProperty	' As IXMLDOMElement - xml-свойство
		Dim oNodes			' As IXTreeNodes

		Set oXmlProperty = XmlProperty
		If Not oXmlProperty.hasChildNodes Then Exit Sub
		
		Set oNodes = Nothing
		If QUERY_SET_ROOT = nQuerySet Then
			' загрузили корневой узел
			Set oNodes = TreeView.Root
		ElseIf QUERY_SET_CHILD = nQuerySet Then
			Set oNodes = TreeView.GetNode(sNodePath).Children
		End If
		
		If oNodes Is Nothing Then Exit Sub
		
		processNodes oXmlProperty
	End Sub

	'==========================================================================
	' Устанавливает checkbox'ы на узлы, соответствующие объектам в свойстве
	'	[in] oXmlProperty As IXMLDOMElement
	Private Sub processNodes(oXmlProperty)
		Dim aNodes			' As Array - массив интерфейсов IXTreeNode
		Dim oNode			' As IXTreeNode - нода дерева
		Dim oObject			' As IXMLDOMElement - xml-объект
		
		m_bLoading = True
		For Each oObject In oXmlProperty.childNodes
			aNodes = HtmlElement.FindAnyNode(oObject.tagName, oObject.getAttribute("oid"))
			If UBound(aNodes) > -1 Then
				For Each oNode In aNodes
					HtmlElement.LockEvents = True
					oNode.Selected = True
					HtmlElement.LockEvents = False
				Next
			End If
		Next
		m_bLoading = False
	End Sub


	'==========================================================================
	' Обработчик операции "Свернуть всё"
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
	' Обработчик операции "Развернуть всё"
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
	' Обработчик операции "Очистить выделение"
	Public Sub Internal_OnClear
		Dim oNode			' As IXMLDOMELement
		Dim oTreeNode		' As IXTreeNode
		' пройдем по все отмеченным узлам и сыметируем снятие выделения с них
		For Each oNode In TreeView.Selection.ChildNodes
			Set oTreeNode = TreeView.GetNode( GetPathFromXml(oNode), False )
			oTreeNode.Selected = False
		Next
	End Sub
	
	
	'==========================================================================
	' Обработчик ActiveX-события onKeyUp (отжатия клавиши). Запускается отложенно по таймауту 
	' Внимание: для внутренного использования.
	Public Sub Internal_OnKeyUp(ByVal nKeyCode, ByVal nFlags)
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

    '==============================================================================
    ' Начало операции - можно отменить
    Public Sub Internal_OnBeforeNodeDrag(oTreeView, oSourceNode, nKeyFlags, bCanDrag)
	    m_oDragDropController.OnBeforeNodeDrag Me, oTreeView, oSourceNode, nKeyFlags, bCanDrag
    End Sub

    '==============================================================================
    ' Начало операции - начали перетаскивать
    Public Sub Internal_OnNodeDrag(oTreeView, oSourceNode, nKeyFlags)
	    m_oDragDropController.OnNodeDrag Me, oTreeView, oSourceNode, nKeyFlags
    End Sub

    '==============================================================================
    ' Проносим над другим узлом
    Public Sub Internal_OnNodeDragOver(oTreeView, oSourceNode, oTargetNode, nKeyFlags, bCanDrog)
	    m_oDragDropController.OnNodeDragOver Me, oTreeView, oSourceNode, oTargetNode, nKeyFlags, bCanDrog
    End Sub
    '==============================================================================
    ' Успешно перенесли
    Public Sub Internal_OnNodeDragDrop(oTreeView, oSourceNode, oTargetNode, nKeyFlags)
	    m_oDragDropController.OnNodeDragDrop Me, oTreeView, oSourceNode, oTargetNode, nKeyFlags
    End Sub

    '==============================================================================
    ' Отменили перенос
    Public Sub Internal_OnNodeDragCanceled(oTreeView, oSourceNode, nKeyFlags)
	    m_oDragDropController.OnNodeDragCanceled Me, oTreeView, oSourceNode, nKeyFlags
    End Sub
    
End Class


'==============================================================================
' Параметры событий "Selected", "UnSelected"
Class NodeSelectedEventArgsClass
	Public Cancel			' As Boolean - признак отмены для цепочки обработчиков. 
	Public TreeNode			' As IXTreeNode
	Public Checked			' As Boolean
	
	Public Function Self
		Set Self = Me
	End Function
End Class
