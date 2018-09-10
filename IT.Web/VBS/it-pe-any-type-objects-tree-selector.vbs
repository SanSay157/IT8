Option Explicit

'==========================================================================
' Класс редактора нескольких массивных свойств в виде read-only-дерева  с чекбоксами.
' При выделении объекта он заносится в свойства, при снятии - удаляется.
' События:
'	Load		- загрузка (Nothing), есть стандартный обработчик
'	Selected	- выбор элемента, занесение объекта в свойство (SelectedEventArgsClass)
'	UnSelected	- снятие выделения с элемента, удаления объекта из свойства (SelectedEventArgsClass)
Class XPEAnyTypeObjectsTreeSelectorClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private EVENTS						' As String	- список событий страницы
	Private m_sLoader					' As String	- URL загрузчика списка
	Private m_sMetaName					' As String	- метаимя описание PE (i:tree-selector)
	Private m_sTreeSelectorMetaName		' As String	- метаимя описания селектора (i:objects-tree-selector)
	Private m_bLoading					' As Boolean - признак загрузки
	Private m_oTreeSelectorMD			' As IXMLDOMElement - узел i:objects-tree-selector
	Private m_sSelectionMode			' As String - режим отбора (Константы TSM_*)
	Private m_sViewStateCacheFileName	' As String - наименование файла с закешированным представлением
	Private m_oPropertyNamesDictionary	' As Scripting.Dictionary - словарь наименований редактируемых свойств:
										' ключ - наименование объектного типа, значение - наименование свойства
		
	'==========================================================================
	Private Sub Class_Initialize
		EVENTS = "Load,Selected,UnSelected,GetRestrictions"
	End Sub
	
	
	'==========================================================================
	' IPropertyEditor: 
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim vMetaName		' метаимя списка для наполнения ListView
		Dim sXPath			' XPAth -запрос
		Dim oSelection		' As IXMLDOMElement - закешированное описание выбранных узлов
		Dim oNode			' As IXMLDOMElement - узел "n" в описании выбранных узлов
		Dim sPropertyName	' As String			- наименование редактируемого свойства
		Dim sObjectType		' As String			- наименование типа объекта значения свойства
		
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
		m_sLoader = "x-tree-loader.aspx?metaname=" & m_sTreeSelectorMetaName
		m_sViewStateCacheFileName = ObjectEditor.Signature() & "XTreeSelector." + oXmlProperty.parentNode.tagName & "." & oXmlProperty.tagName & "." & m_oPropertyEditorBase.PropertyEditorMD.getAttribute("n")
		
		' инициализируем словарь наименований редактируемых свойств
		Set m_oPropertyNamesDictionary = CreateObject("Scripting.Dictionary")
		For Each sPropertyName In PropertyNames
			sObjectType	= ObjectEditor.PropMD(sPropertyName).getAttribute("ot")
			m_oPropertyNamesDictionary.Add sObjectType, sPropertyName		
		Next
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
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass
		Dim sUrlParams		' параметры в страницу загрузчик списка
		Dim sRestrictions	' параметры в список от юзерских обработчиков
		
		' получим ограничения от пользовательских скриптов
		Set oSelectorRestrictions = New GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions

		sUrlParams = oSelectorRestrictions.UrlParams
		sRestrictions = XService.URLEncode(oSelectorRestrictions.ReturnValue)

		' Установим режимы отображения
		SelectionMode = m_sSelectionMode
		' Выбирать можно только узлы, чей тип соответствует типу объекта какого-либо
		' редактируемого свойства.  Если не задано ни одного редактируемого свойства,
		' передаем "_" (будем надеятся, что такого свойства нет)
		TreeView.SelectableTypes = nvl( Join(PropertyNamesDictionary.Keys, " "), "_" )
		TreeView.Loader = m_sLoader & "&RESTR=" & sRestrictions & sUrlParams
		TreeView.LockEvents = True
		On Error Resume Next
		TreeView.Reload
		TreeView.LockEvents = False
		If X_ErrOccured() Then
			X_ErrReport()
			Exit Sub
		End If
	End Sub

	
	'==========================================================================
	' Устанавливает/возсращает режимы отображения дерева (признак множественного выбора и признак отбора только листовых узлов)
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
	' IPropertyEditor: Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property


	'==========================================================================
	' IPropertyEditor: Устанавливает значение в дереве
	Public Sub SetData
		Dim oSelection
		Dim oNode

		Set TreeView.Selection = Nothing
		processNodes TreeView.Root
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
	' IPropertyEditor: 
	Public Property Get Mandatory
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
		ExtraHtmlElement("ShowSelected").disabled = Not( bEnabled )
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
	' Очистка ссылок
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
		Set m_oPropertyEditorBase = Nothing
		Set m_oPropertyNamesDictionary = Nothing
	End Sub	

	
	'==========================================================================
	' Выбрасывает событие
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	

	
	'==========================================================================
	' Возвращает дополнительный контрол IHTMLElement
	Private Function ExtraHtmlElement(sName)
		Set ExtraHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.id & sName)
	End Function


	'==========================================================================
	' Возвращает массив наименований редактируемых свойств
	Public Property Get PropertyNames
		PropertyNames = Split( HtmlElement.GetAttribute("X_PROP_NAMES"), " " )
	End Property


	'==========================================================================
	' Возвращает словарь наименований редактируемых свойств:
	' ключ - наименование объектного типа, значение - наименование свойства
	Public Property Get PropertyNamesDictionary
		Set PropertyNamesDictionary = m_oPropertyNamesDictionary
	End Property

	
	'==========================================================================
	' Возвращает наименование редактируемого свойства по наименованию типа объекта значения свойства
	' [in] sObjectType - наименование типа
	Public Function PropertyNameByType(sObjectType)
		PropertyNameByType = PropertyNamesDictionary.Item(sObjectType)
	End Function
	

	'==========================================================================
	' Возвращает Xml-свойство по наименованию типа
	' [in] sObjectType - наименование типа
	Public Function XmlPropertyByType(sObjectType)
		Dim sPropertyName
		sPropertyName = PropertyNameByType(sObjectType)
		Set XmlPropertyByType = XmlPropertyByPropertyName(sPropertyName)
	End Function


	'==========================================================================
	' Возвращает Xml-свойство по наименованию свойства
	' [in] - наименование свойства
	Public Function XmlPropertyByPropertyName(sPropertyName)
		Dim sObjectType			' As String
		Dim sObjectID			' As String
		Dim sXmlPropertyXPath	' As String - XPath для нахождения свойства в пуле
		
		' если не передано имя свойства, то возвращаем Nothing
		If IsEmpty(sPropertyName) Then
			Set XmlPropertyByPropertyName = Nothing
			Exit Function
		End If
				
		sObjectType	= m_oPropertyEditorBase.ObjectType
		sObjectID	= m_oPropertyEditorBase.ObjectID
		sXmlPropertyXPath	= sObjectType & "[@oid='" & sObjectID & "']/" & sPropertyName
		Set XmlPropertyByPropertyName = ObjectEditor.XmlObjectPool.selectSingleNode( sXmlPropertyXPath )
		If XmlPropertyByPropertyName Is Nothing Then
			Set XmlPropertyByPropertyName = ObjectEditor.Pool.GetXmlObject(sObjectType, sObjectID, Null).SelectSingleNode(sPropertyName)
		End If
		If XmlPropertyByPropertyName Is Nothing Then _
			Err.Raise -1, "XPEAnyTypeObjectsTreeSelectorClass::XmlPropertyByPropertyName", "Не найдено свойство " & sPropertyName & " в xml-объекте"
		If Not IsNull(XmlPropertyByPropertyName.getAttribute("loaded")) Then
			Set XmlPropertyByPropertyName = ObjectEditor.LoadXmlProperty( Nothing, XmlPropertyByPropertyName)
		End If
	End Function


	'==========================================================================
	' Обработчик выбора элемента дерева. Устанавливается в xslt-шаблоне. Для внутренного использования!
	'	[in] oNode - выбранная нода
	'	[in] bSelected - состояние checkbox'a ноды
	Public Sub Internal_OnSelChange( oNode, bSelected )
		Dim oXmlProperty	' As IXMLDOMElement - xml-свойство

		If m_bLoading Then Exit Sub

		Set oXmlProperty = XmlPropertyByType(oNode.Type)
		If oXmlProperty Is Nothing Then Exit Sub

		With New NodeSelectedEventArgsClass
			Set .TreeNode = oNode
			.Checked = bSelected
			If bSelected Then
				' отметили объект - занесем ссылку на него в свойства
				' заглушку всегда добавляем в конец
				m_oPropertyEditorBase.ObjectEditor.Pool.AddRelation Nothing, oXmlProperty, X_CreateObjectStub(oNode.Type, oNode.ID)
				FireEvent "Selected", .Self()
			Else
				' разотметили объект - выкиним сссылку на него из свойства
				m_oPropertyEditorBase.ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.selectSingleNode("*[@oid='" & oNode.ID &"']")
				FireEvent "UnSelected", .Self()
			End If
		End With
	End Sub	

	
	'==========================================================================
	' Обработчик загрузки уровня дерева. Устанавливается в xslt-шаблоне. Для внутренного использования!
	'	[in] nQuerySet - действие, вызвавшее событие (константа QUERY_SET_*)
	'	[in] sNodePath - путь до узла, относительно которого была выполнена операция загрузки множества описаний элементов
	'	[in] sObjectType - 
	'	[in] sObjectID 
	Public Sub Internal_OnDataLoaded( nQuerySet, sNodePath, sObjectType, sObjectID )
		Dim oNodes			' As IXTreeNodes

		Set oNodes = Nothing
		If QUERY_SET_ROOT = nQuerySet Then
			' загрузили корневой узел
			Set oNodes = TreeView.Root
		ElseIf QUERY_SET_CHILD = nQuerySet Then
			Set oNodes = TreeView.GetNode(sNodePath).Children
		End If
		
		If oNodes Is Nothing Then Exit Sub
		
		processNodes oNodes
	End Sub


	'==========================================================================
	' Устанавливает checkbox'ы на узлы из коллекции oNodes, соответствующие объектам в свойстве
	'	[in] oNodes As CROC.IXTreeNodes
	Private Sub processNodes(oNodes)
		Dim oXmlProperty	' As IXMLDOMElement - xml-свойство
		Dim sType			' As String - тип объекта значения свойства
		Dim oNode			' As IXTreeNode - нода дерева
		Dim oObject			' As IXMLDOMElement - xml-объект
		Dim i
		Dim oChildren
		
		If oNodes.Count=0 Then Exit Sub
		m_bLoading = True
		For i=0 To oNodes.Count-1
			Set oNode = oNodes.GetNode(i)
			Set oXmlProperty = XmlPropertyByType(oNode.Type)
			If Not oXmlProperty Is Nothing Then
				For Each oObject In oXmlProperty.childNodes
					If oNode.ID = oObject.getAttribute("oid") Then
						HtmlElement.LockEvents = True
						oNode.Selected = True
						HtmlElement.LockEvents = False
						Exit For
					End If
				Next
			End If
			If oNode.Expanded Then
				Set oChildren = oNode.Children
				If oChildren.Count > 0 Then processNodes oChildren
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
			ExpandNode oTreeNode.Children
		Next
	End Sub
	
	'==========================================================================
	' Обработчик операции "Очистить выделение"
	Public Sub Internal_OnClear
		Dim oNode			' As IXMLDOMELement
		Dim oTreeNode		' As IXTreeNode
		' пройдем по все отмеченным узлам и сымитируем снятие выделения с них
		For Each oNode In TreeView.Selection.ChildNodes
			Set oTreeNode = TreeView.GetNode( GetPathFromXml(oNode), False )
			oTreeNode.Selected = False
		Next
	End Sub
	
	
	'==========================================================================
	' Обработчик операции "Показать выбранные"
	Public Sub Internal_OnShowSelected
		TreeView.ExpandSelection True
	End Sub
End Class
