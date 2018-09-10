'===============================================================================
'@@!!FILE_x-editor-page
'<GROUP !!SYMREF_VBS>
'<TITLE x-editor-page - Ослуживание страницы редактора>
':Назначение:	Ослуживание страницы редактора.
'===============================================================================
'@@!!CLASSES_x-editor-page
'<GROUP !!FILE_x-editor-page><TITLE Классы>
Option Explicit

'===============================================================================
'@@EditorPageClass
'<GROUP !!CLASSES_x-editor-page><TITLE EditorPageClass>
':Назначение:	Класс страницы редактора. Страница имеет билдер, с помощью которого строится HTML-содержимое. 
'               Описание событий класса приведено в разделе <LINK points_wc1_02-1,События>
'<P/> 
'@@!!MEMBERTYPE_Methods_EditorPageClass
'<GROUP EditorPageClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_EditorPageClass
'<GROUP EditorPageClass><TITLE Свойства>
Class EditorPageClass
' События:
'	EnableControls
'	AfterEnableControls
'	Init
'	PreRender
'	Render
'	AfterBinding
'	Load
'	AfterLoad
'	SetDefaultFocus


	'------------------------------------------------------------------------------
	'@@EditorPageClass.CanBeCached
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE CanBeCached>
	':Назначение:	
	'	Признак того, что содержимое страницы может кэшироваться. 
	':Сигнатура:	
	'	Public CanBeCached [As Boolean]
	Public CanBeCached
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.NeedBuilding
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE NeedBuilding>
	':Назначение:	
	'	Признак того, что при отображении страницы надо выполнить ее построение. 
	':Сигнатура:	
	'	Public NeedBuilding [As Boolean]
	Public NeedBuilding
	
	Private m_sPageName			' As String - идентификатор страницы
	Private m_sPageTitle		' As String - заголовок страницы
	Private m_sPageHint			' As String	- хинт
	Private m_oObjectEditor		' As ObjectEditor - ссылка на редактор
	Private m_oBuilder			' As IEditorPageBuilder - PageBuilder для создания контента страницы
	Private m_oPropertyEditors	' As Scripting.Dictionary - словарь редакторов свойств, ключ - html-id свойства, значение массив PropertyEditor'ов
	Private m_oHTMLDIVElement	' As IHTMLDIVElement - ссылка на DIV, в котором хранится контент страницы
	Private m_oMetadata			' As XMLDOMElement - метаданные страницы - узел i:page МД
	Private m_oEventEngine		' As EventEngineClass
	Private EVENTS				' список событий страницы
	Private m_nBackMode			' Переопределенный режим поведения мастера при возвращении с данной страницы. Если задано, переопределяет BackMode редактора
	Private m_bHidden			' As Boolean - признак того, что страница в данный момент скрыта

	
	'==========================================================================
	' "Конструктор" экземпляра
	Private Sub Class_Initialize
		Set m_oPropertyEditors = CreateObject("Scripting.Dictionary")
		Set m_oEventEngine = X_CreateEventEngine
		Set m_oBuilder = Nothing
		Set m_oObjectEditor = Nothing
		Set m_oHTMLDIVElement = Nothing
		CanBeCached = True
		NeedBuilding = True
		EVENTS = "EnableControls,AfterEnableControls,Init,PreRender,Render,AfterBinding,Load,AfterLoad,SetDefaultFocus"
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.Dispose
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE Dispose>
	':Назначение:	
	'	Процедура выполняет освобождение ссылок.
	':Сигнатура:
	'	Public Sub Dispose () 
	Public Sub Dispose
		On Error Resume Next
		
		Set m_oObjectEditor = Nothing
		
		m_oBuilder.Dispose
		Set m_oBuilder = Nothing
		
		DisposePropertyEditors
		Set m_oPropertyEditors = Nothing
		On Error GoTo 0
	End Sub
	
	
	'==========================================================================
	' Вызывает Dispose у всех редакторов свойств
	Private Sub DisposePropertyEditors
		Dim aPropertyEditor		'
		Dim i
		If Not IsObject(m_oPropertyEditors) Then Exit Sub
		If Nothing Is m_oPropertyEditors Then Exit Sub
		For Each aPropertyEditor In m_oPropertyEditors.Items
			For i=0 To UBound(aPropertyEditor)
				On Error Resume Next
				aPropertyEditor(i).Dispose
				On Error GoTo 0
			Next
		Next
		m_oPropertyEditors.RemoveAll
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.Init
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE Init>
	':Назначение:	
	'	Инициализация страницы на основе метаданных.
	':Параметры:
	'	oObjectEditor - 
	'       [in] экземпляр класса ObjectEditorClass.
	'	oMetadata - 
	'       [in] метаданные страницы (узел <b>i:page</b>).
	':Сигнатура:
	'	Public Sub Init ( 
	'		oObjectEditor [As ObjectEditorClass], 
	'		oMetadata [As IXMLDOMElement]
	'	)
	Public Sub Init(oObjectEditor, oMetadata)
		Dim oBuilder		' As IEditorPageBuilder
		
		Set m_oMetadata = oMetadata
		CanBeCached = IsNull( oMetadata.getAttribute("off-cache") )
		If oObjectEditor.IsWizard Then
			' если для страницы задан режим мастера возьмем его, иначе возьмем режим мастера по умолчанию из редактора
			If Not IsNull( oMetadata.GetAttribute("wizard-mode") ) Then
				BackMode = ParseWizardBackMode( oMetadata.getAttribute("wizard-mode") )
			Else
				BackMode = oObjectEditor.DefaultBackMode
			End If
		End If
		Set oBuilder = Eval("New " & X_GetAttributeDef(oMetadata, "builder", "EditorPageXsltBuilderClass") )
		oBuilder.Init oObjectEditor, oMetadata
		InitIndirect oObjectEditor, oBuilder, oMetadata.getAttribute("n"), oMetadata.getAttribute("t")
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.InitIndirect
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE InitIndirect>
	':Назначение:	
	'	Инициализация страницы на основе метаданных.
	':Параметры:
	'	oObjectEditor - 
	'       [in] экземпляр класса ObjectEditorClass.
	'	oPageBuilder - 
	'       [in] билдер содержимого страницы.
	'	sPageName - 
	'       [in] наименомение страницы.
	'	sPageTitle - 
	'       [in] заголовок страницы.
	':Сигнатура:
	'	Public Sub InitIndirect ( 
	'		oObjectEditor [As ObjectEditorClass], 
	'		oPageBuilder [As IEditorPageBuilder],
	'       sPageName [As String],
	'       sPageTitle [As String]
	'	)
	Public Sub InitIndirect(oObjectEditor, oPageBuilder, sPageName, sPageTitle)
		Dim oPageDiv		' IHTMLDIVElement
		
		Set m_oObjectEditor = oObjectEditor
		Set m_oBuilder = oPageBuilder
		' создадим DIV, где будет лежать контент страницы
		With m_oObjectEditor.HtmlPageContainer
			Set oPageDiv = .appendChild( .ownerDocument.createElement("DIV") )
			oPageDiv.style.display = "none"
		End With
		Set m_oHTMLDIVElement =  oPageDiv
		m_sPageName  = sPageName
		m_sPageTitle = sPageTitle
		m_oEventEngine.InitHandlers EVENTS, "usrXEditorPage_On"
		fireEvent "Init", Nothing
	End Sub


	'==========================================================================
	' Возбуждает событие
	Private Sub fireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.PageName
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE PageName>
	':Назначение:	
	'	Наименование (идентификатор) страницы.
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get PageName [As String]
	Public Property Get PageName		' As String
		PageName = m_sPageName
	End Property


	'------------------------------------------------------------------------------
	'@@EditorPageClass.PageTitle
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE PageTitle>
	':Назначение:	
	'	Заголовок страницы.
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get PageTitle [As String]
	Public Property Get PageTitle		' As String
		PageTitle = m_sPageTitle
	End Property


	'------------------------------------------------------------------------------
	'@@EditorPageClass.PageHint
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE PageHint>
	':Назначение:	
	'	Подсказка.
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get PageHint [As String]
	Public Property Get PageHint		' As String
		PageHint = m_sPageHint
	End Property 


	'------------------------------------------------------------------------------
	'@@EditorPageClass.PageBuilder
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE PageBuilder>
	':Назначение:	
	'	Билдер содержимого страницы.
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get PageBuilder [As IEditorPageBuilder]
	Public Property Get PageBuilder		' As IEditorPageBuilder
		Set PageBuilder = m_oBuilder
	End Property


	'------------------------------------------------------------------------------
	'@@EditorPageClass.ObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE ObjectEditor>
	':Назначение:	
	'	Экземпляр класса ObjectEditorClass.
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get ObjectEditor [As ObjectEditorClass]
	Public Property Get ObjectEditor	' As ObjectEditorClass
		Set ObjectEditor = m_oObjectEditor
	End Property


	'------------------------------------------------------------------------------
	'@@EditorPageClass.Metadata
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE Metadata>
	':Назначение:	
	'	Метаданные страницы (узел <b>i:page</b>).
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get Metadata [As IXMLDOMElement]
	Public Property Get Metadata		' As XmlElement - метаданные страницы
		Set Metadata = m_oMetadata
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.BackMode
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE BackMode>
	':Назначение:	
	'	Поведение мастера при возвращении назад с данной страницы.
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get BackMode [As Int]
	Public Property Get BackMode
		BackMode = m_nBackMode
	End Property
	Public Property Let BackMode(nBackMode)
		m_nBackMode = nBackMode
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.IsHidden
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE IsHidden>
	':Назначение:	
	'	Признак того, что страница в данный момент скрыта.
	':Сигнатура:	
	'	Public Property Get IsHidden [As Boolean]
	'   Public Property Let IsHidden(bIsHidden [As Boolean])
	Public Property Get IsHidden
		IsHidden = m_bHidden
	End Property
	Public Property Let IsHidden(bIsHidden)
		m_bHidden = bIsHidden
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.HtmlDivElement
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE HtmlDivElement>
	':Назначение:	
	'	Cсылка на DIV-элемент, в котором содержится контент страницы.
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get HtmlDivElement [As IHTMLElement]
	Public Property Get HtmlDivElement	' As IHTMLElement - узел DIV страницы
		Set HtmlDivElement = m_oHTMLDIVElement
	End Property 


	'------------------------------------------------------------------------------
	'@@EditorPageClass.IsReady
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE IsReady>
	':Назначение:	
	'	Признак готовности страницы (готовности всех контролов на странице).
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get IsReady [As Boolean]
	Public Property Get IsReady			' As Boolean
		IsReady = X_IsDocumentReady( HtmlDivElement )
	End Property
	
	
	'==========================================================================
	Private Property Get IsInterrupted
		IsInterrupted = m_oObjectEditor.IsInterrupted
	End Property


	'------------------------------------------------------------------------------
	'@@EditorPageClass.EventEngine
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE EventEngine>
	':Назначение:	
	'	Экземпляр класса EventEngineClass.
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get EventEngine [As EventEngineClass]
	Public Property Get EventEngine
		Set EventEngine = m_oEventEngine
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.Clear
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE Clear>
	':Назначение:	
	'	Процедура очищает содержимое страницы.
	':Сигнатура:
	'	Public Sub Clear () 
	Public Sub Clear()
		HtmlDivElement.InnerHtml = ""
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.PrepareForRender
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE PrepareForRender>
	':Назначение:	
	'	Процедура выполняет инициализацию HTML-элемента DIV, в рамках которого 
	'   размещается содержание страницы: удаление существовавшего содержимого, 
	'   установка атрибута <b>visibility</b> в значение "hidden".
	':Сигнатура:
	'	Public Sub PrepareForRender () 
	Public Sub PrepareForRender()
		Clear
		HtmlDivElement.style.visibility = "hidden"
	End Sub
	

	'------------------------------------------------------------------------------
	'@@EditorPageClass.VisibilityTurnOn
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE VisibilityTurnOn>
	':Назначение:	
	'	Процедура устанавливает атрибут <b>visibility</b> в значение "visible".
	':Сигнатура:
	'	Public Sub VisibilityTurnOn () 
	Public Sub VisibilityTurnOn
		HtmlDivElement.style.visibility = "visible"
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.Build
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE Build>
	':Назначение:	
	'	Функция выполняет построение содержимого страницы.
	':Сигнатура:
	'	Public Function Build () [As Boolean]
	Public Function Build()
		Dim sHtmlString		' As String
		fireEvent "PreRender", Nothing
		' если есть обработчик события Render, то вызовем его, иначе получим Html от builder'a
		If m_oEventEngine.IsHandlerExists("Render") Then
			fireEvent "Render", Nothing
			Build = True
		Else
			On Error Resume Next
			sHtmlString = PageBuilder.GetHtml()
			If Err Then
				MsgBox "Ошибка в процессе формирования HTML страницы:" & vbCr & Err.Description & vbCr & "Источник: " & Err.Source, vbCritical 
				Exit Function
			End If
			On Error GoTo 0
			If Not IsEmpty(sHtmlString) Then
				HtmlDivElement.InnerHtml = sHtmlString
				NeedBuilding = False
				Build = True
			Else
				Build = False
			End If	
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.PostBuild
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE PostBuild>
	':Назначение:	
	'	Процедура выполняет пост-инициализацию страницы. Инициализирует коллекцию 
	'   редакторов свойств и заполняет их данными.
	':Сигнатура:
	'	Public Sub PostBuild () 
	Public Sub PostBuild
		Dim oElement			' IHTMLElement
		Dim vPEClassName		' значение атрибута X_PROPERTY_EDITOR
		Dim oPropertyEditor		' редактор свойства
		Dim oXmlProperty		' Xml-свойство
		Dim sHtmlKey			' идентификатор Html-контрола редактора свойства, идентифицирующий свойство объекта
		Dim aPropertyEditor 	' массив редакторов свойств
		Dim i
		DisposePropertyEditors
		For Each oElement In HtmlDivElement.all
			vPEClassName = oElement.getAttribute("X_PROPERTY_EDITOR")
			If Not IsNull(vPEClassName) Then
				sHtmlKey = GetHtmlIdFromFullHtmlId(oElement.id)
				Set oXmlProperty = m_oObjectEditor.GetPropByHtmlID(sHtmlKey)
				If Not oXmlProperty Is Nothing Then
					On Error Resume Next
					Set oPropertyEditor = Eval("New " & vPEClassName)
					If Err Then 
						Alert "Не удалось создать объект редактора свойства:" & vPEClassName & vbCr & Err.Description
						Exit Sub
					End If
					On Error GoTo 0
					If m_oPropertyEditors.Exists(sHtmlKey) Then
						' если PE с таким ключем уже есть, то добавим значение в массив
						aPropertyEditor = m_oPropertyEditors.Item(sHtmlKey)
						addRefIntoArray aPropertyEditor, oPropertyEditor
						m_oPropertyEditors.Item(sHtmlKey) = aPropertyEditor
					Else
						' иначе создадим новый элемент словаря
						m_oPropertyEditors.Add sHtmlKey, Array(oPropertyEditor)
					End If
					On Error Resume Next
					oPropertyEditor.Init Me, oXmlProperty, oElement
					If Err Then
						Alert "Ошибка инициализации редактора свойства " & vPEClassName & " для свойства " & oXmlProperty.tagName & vbCr & Err.Description
						Exit Sub
					End If
					On Error GoTo 0
				End If
			End If
		Next
		InitPropertyEditorsUI
		fireEvent "AfterBinding", Nothing
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.InitPropertyEditorsUI
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE InitPropertyEditorsUI>
	':Назначение:	
	'	Процедура выполняет вторую фазу пост-инициализацию страницы. Для каждого 
	'   редактора свойств вызывается процедура <b>FillDаta</b>.
	':Примечание:	
	'	Отдельная фаза введена из-за того, что заполнение данными редактора свойства
	'   (процедура <b>FillDаta</b>) может зависеть от других редакторов свойств.
	'   Поэтому циклы создания редакторов свойств и инициализации разделены.<P/>
	'   Отдельный метод введен из-за того, что редактору иногда требуется 
	'   переинициализировать интерфейс без разрушения коллекции редакторов свойств.
	':Сигнатура:
	'	Public Sub InitPropertyEditorsUI () 
	Public Sub InitPropertyEditorsUI
		Dim aPropertyEditor 	' массив редакторов свойств
		Dim i
		
		' пройдем по всем PE и вызовем FillData
		For Each aPropertyEditor In m_oPropertyEditors.Items
			For i=0 To UBound(aPropertyEditor)
				aPropertyEditor(i).FillData
			Next
		Next
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.SetData
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE SetData>
	':Назначение:	
	'	Процедура заполняет редакторы свойств данными объектов из XML. 
	':Сигнатура:
	'	Public Sub SetData () 
	Public Sub SetData
		Dim aPropertyEditor
		Dim i
		
		If m_oEventEngine.IsHandlerExists("Load") Then
			fireEvent "Load", Nothing
		Else
			For Each aPropertyEditor In m_oPropertyEditors.Items
				For i=0 To UBound(aPropertyEditor)
					aPropertyEditor(i).SetData
				Next
			Next
		End If
		fireEvent "AfterLoad", Nothing
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.SetDefaultFocus
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE SetDefaultFocus>
	':Назначение:	
	'	Функция устанавливает фокус на первый возможный редактор свойства на странице.
	':Сигнатура:
	'	Public Function SetDefaultFocus () [As Boolean]
	Public Function SetDefaultFocus()
		Dim aPropertyEditor
		Dim i

		SetDefaultFocus = True
		If m_oEventEngine.IsHandlerExists("SetDefaultFocus") Then
			' TODO: нужен какой-то EventArgs
			fireEvent "SetDefaultFocus", Nothing
		Else
			For Each aPropertyEditor In m_oPropertyEditors.Items
				For i=0 To UBound(aPropertyEditor)
					' Может окно уже закрыли...
					If IsInterrupted Then Exit Function
					If aPropertyEditor(i).SetFocus Then Exit Function
				Next
			Next
			SetDefaultFocus = False		
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.GetData
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE GetData>
	':Назначение:	
	'	Процедура переносит данные из формы в загруженный XML-объект и возбуждает 
	'   событие <b>OnPageLoad</b>.
	':Параметры:
	'	oGetDataArgs - 
	'       [in] экземпляр класса GetDataArgsClass.
	':Сигнатура:
	'	Public Sub GetData ( 
	'		oGetDataArgs [As GetDataArgsClass]
	'	) 
	Public Sub GetData(oGetDataArgs)
		Dim aPropertyEditor		' редактор свойства
		Dim i
		
' TODO: событие!
		' Проитерируем все html-элементы в области редактирования
		For Each aPropertyEditor In m_oPropertyEditors.Items
			For i=0 To UBound(aPropertyEditor)
				With oGetDataArgs.Clone
					aPropertyEditor(i).GetData .Self()
					If .ReturnValue <> True And Not oGetDataArgs.SilentMode Then
						' Обломались!
						If HasValue(.ErrorMessage) Then
							Alert .ErrorMessage
						End If
						EnablePropertyEditor aPropertyEditor(i), True
						' Установим фокус на PE
						' ВНИМАНИЕ: выполним это асинхронно (вместо того, что просто сделать aPropertyEditor(i).SetFocus)
						' из-за странного поведение IE:
						' она неправильно определяет источник события (window.event.srcElement), 
						' если в потоке выполнения обработчика ActiveX-события мы поменяем активный элемент (т.е. вызовем focus).
						' HTML-событие, соответствующее обрабатываемому ActiveX (например, OnKeyUp) придет в document 
						' (т.е. в обработчик document_onKeyUp) со свойством srcElement установленным уже на новый контрол (в результате focus)
						window.setTimeout ObjectEditor.UniqueID & ".CurrentPage.GetPropertyEditorByFullHtmlID(""" & aPropertyEditor(i).HtmlElement.id & """).SetFocus", 1, "VBScript"
						oGetDataArgs.ReturnValue = False
						Exit Sub
					End If
				End With
			Next
		Next
					
' TODO: события (OnPageEnd)
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.SetEnable
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE SetEnable>
	':Назначение:	
	'	Процедура блокирует/разблокирует все редакторы свойств на странице и возбуждает 
	'   события <b>EnableControls</b> и <b>AfterEnableControls</b>.
	':Параметры:
	'	bEnable - 
	'       [in] признак блокировки/разблокировки всех редакторов свойств на странице.
	':Сигнатура:
	'	Public Sub SetEnable ( 
	'		bEnable [As Boolean]
	'	) 
	Public Sub SetEnable(bEnable)
		Dim aPropertyEditor 
		Dim i
		
		If m_oEventEngine.IsHandlerExists("EnableControls") Then
			With New EnableControlsEventArgsClass
				.Enable = bEnable
				fireEvent "EnableControls", .Self()
			End With
		Else
			For Each aPropertyEditor In m_oPropertyEditors.Items
				For i=0 To UBound(aPropertyEditor)
					EnablePropertyEditor aPropertyEditor(i), bEnable
				Next
			Next
		End If
		' для оптимизации проверим, есть ли обработчик, чтобы зря не создавать объект
		If m_oEventEngine.IsHandlerExists("AfterEnableControls") Then
			With New EnableControlsEventArgsClass
				.Enable = bEnable
				fireEvent "AfterEnableControls", .Self()
			End With
		End If
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.EnablePropertyEditor
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE EnablePropertyEditor>
	':Назначение:	
	'	Функция разрешает/запрещает элемент управления.
	':Параметры:
	'	oPropertyEditor - 
	'       [in] редактор свойства.
	'	bEnable - 
	'       [in] признак доступности элемента.
	':Примечание:	
	'	В общем случае при работе мастера/редактора необходимо иметь некоторые
	'   элементы управления заблокированными. При этом глобальная блокировка с
	'   последующей  разблокировкой не должна вызывать  разблокирования  ранее
	'   заблокированных элементов. Поэтому посредством дополнительного  атрибута
	'   <b>X_DISABLED</b> реализовано подобие стека "доступности". При попытке 
	'   разблокировать элемент, снабженный данным атрибутом, реального 
	'   разблокирования не происходит, а атрибут удаляется.
	':Сигнатура:
	'	Public Function EnablePropertyEditor ( 
	'       oPropertyEditor [As Object],
	'		bEnable [As Boolean]
	'	) [As Boolean]
	Public Function EnablePropertyEditor(oPropertyEditor, bEnable)
		EnablePropertyEditor = EnablePropertyEditorEx(oPropertyEditor, bEnable, False)
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.EnablePropertyEditorEx
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE EnablePropertyEditorEx>
	':Назначение:	
	'	Функция разрешает/запрещает элемент управления.
	':Параметры:
	'	oPropertyEditor - 
	'       [in] редактор свойства.
	'	bEnable - 
	'       [in] признак доступности элемента.
	'	bForce - 
	'       [in] признак принудительного перевода в данное состояние без
	'       анализа стека "доступности".
	':Примечание:	
	'	В общем случае при работе мастера/редактора необходимо иметь некоторые
	'   элементы управления заблокированными. При этом глобальная блокировка с
	'   последующей  разблокировкой не должна вызывать  разблокирования  ранее
	'   заблокированных элементов. Поэтому посредством дополнительного  атрибута
	'   <b>X_DISABLED</b> реализовано подобие стека "доступности". При попытке 
	'   разблокировать элемент, снабженный данным атрибутом, реального 
	'   разблокирования не происходит, а атрибут удаляется.
	':Сигнатура:
	'	Public Function EnablePropertyEditorEx ( 
	'       oPropertyEditor [As Object],
	'		bEnable [As Boolean],
	'		bForce [As Boolean]
	'	) [As Boolean]
	Public Function EnablePropertyEditorEx(oPropertyEditor, bEnable, bForce)
		Dim oIHtmlElement		' IHtmlElement PE
		Dim nDisableDepth		' глубина стека дизейблов
		Dim nDisableDepthOrigin	' первоначальное значение nDisableDepth
		
		EnablePropertyEditorEx = False
		Set oIHtmlElement = oPropertyEditor.HtmlElement

		nDisableDepth = CLng("0" & oIHtmlElement.GetAttribute("X_DISABLED"))
		nDisableDepthOrigin = nDisableDepth
		If bForce Then
			If bEnable Then
				nDisableDepth =  0
			Else	
				nDisableDepth =  1
			End If	
		Else
			' если контрол уже раздизейблин и хотят еще, то не надо
			If Not (nDisableDepth = 0 And bEnable) Then
				nDisableDepth = nDisableDepth + Iif(bEnable, -1, +1)
			End If
		End If

		EnablePropertyEditorEx = True 
		oIHtmlElement.SetAttribute "X_DISABLED", nDisableDepth
		If nDisableDepth = 0 And nDisableDepthOrigin>0 Then
			oPropertyEditor.Enabled = True
		ElseIf nDisableDepth = 1 And nDisableDepthOrigin=0 Then
			oPropertyEditor.Enabled = False
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.Hide
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE Hide>
	':Назначение:	
	'	Процедура скрывает DIV страницы. 
	':Сигнатура:
	'	Public Sub Hide () 
	Public Sub Hide
		HTMLDIVElement.style.display = "none"
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.Show
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE Show>
	':Назначение:	
	'	Процедура показывает DIV страницы. 
	':Сигнатура:
	'	Public Sub Show () 
	Public Sub Show
		HTMLDIVElement.style.display = "block"
	End Sub	


	'------------------------------------------------------------------------------
	'@@EditorPageClass.GetPropertyEditors
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE GetPropertyEditors>
	':Назначение:	
	'	Функция возвращает массив редакторов свойств для заданного свойства или
	'   Empty, если для заданного свойства не найдено редактора свойства.
	':Параметры:
	'	oXmlProperty - 
	'       [in] ссылка на XML-свойство.
	':Сигнатура:
	'	Public Function GetPropertyEditors ( 
	'		oXmlProperty [As IXMLDOMElement]
	'	) [As Array]
	Public Function GetPropertyEditors(oXmlProperty)
		Dim sHtmlId		' краткий html-id
		
		sHtmlId = m_oObjectEditor.GetHtmlID( oXmlProperty )
		If Not IsNull(sHtmlId) Then
			If m_oPropertyEditors.Exists( sHtmlId ) Then
				GetPropertyEditors = m_oPropertyEditors.Item(sHtmlId)
			End If
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.GetPropertyEditor
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE GetPropertyEditor>
	':Назначение:	
	'	Функция возвращает первый элемент из массива редакторов свойств для заданного 
	'   свойства или Nothing, если для заданного свойства не найдено редактора свойства.
	':Параметры:
	'	oXmlProperty - 
	'       [in] ссылка на XML-свойство.
	':Сигнатура:
	'	Public Function GetPropertyEditor ( 
	'		oXmlProperty [As IXMLDOMElement]
	'	) [As Object]
	Public Function GetPropertyEditor(oXmlProperty)
		Dim sHtmlId		' краткий html-id
		
		Set GetPropertyEditor = Nothing
		sHtmlId = m_oObjectEditor.GetHtmlID( oXmlProperty )
		If Not IsNull(sHtmlId) Then
			If m_oPropertyEditors.Exists( sHtmlId ) Then
				Set GetPropertyEditor = m_oPropertyEditors.Item(sHtmlId)(0)
			End If
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.GetPropertyEditorByFullHtmlID
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE GetPropertyEditorByFullHtmlID>
	':Назначение:	
	'	Функция возвращает экземпляр редактора свойства для HTML-элемента с заданным 
	'   идентификатором.
	':Параметры:
	'	sFullHtmlId - 
	'       [in] идентификатор HTML-элемента.
	':Сигнатура:
	'	Public Function GetPropertyEditorByFullHtmlID ( 
	'		sFullHtmlId [As String]
	'	) [As Object]
	Public Function GetPropertyEditorByFullHtmlID(sFullHtmlId)
		Dim oPropertyEditor		' As IPropertyEditor
		Dim sKey				' As String - ключ в словаре PropertyEditor'ов
		
		Set GetPropertyEditorByFullHtmlID = Nothing
		sKey = GetHtmlIdFromFullHtmlId(sFullHtmlId)
		If Not m_oPropertyEditors.Exists(sKey) Then Exit Function
		
		For Each oPropertyEditor In m_oPropertyEditors.Item( sKey )
			If oPropertyEditor.HtmlElement.id = sFullHtmlId Then
				Set GetPropertyEditorByFullHtmlID = oPropertyEditor
				Exit For
			End If
		Next
	End Function


	'==========================================================================
	' Возвращает значимую часть html-id из полного идентификатора Html элемента,
	' отрезая окончания #гуид (37 символов), добавляемое для обеспечения уникальности идентификаторов контролов
	'	[in] sFullHtmlId As String - идентификатор Html элемента
	'	[retval] Значимая часть html-id
	Private Function GetHtmlIdFromFullHtmlId(sFullHtmlId)
		' 37 - это длина гуида + символ "#" отделяющий значимую часть html-id от гуида, 
		' добавляемого для обеспечения уникальности
		GetHtmlIdFromFullHtmlId = Left(sFullHtmlId, Len(sFullHtmlId) - 37)
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.PropertyEditors
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE PropertyEditors>
	':Назначение:	
	'	Коллекция редакторов свойств.
	':Примечание:	
	'	Свойство доступно только для чтения.
	':Сигнатура:	
	'	Public Property Get PropertyEditors [As Scripting.Dictionary]
	Public Property Get PropertyEditors
		Set PropertyEditors = m_oPropertyEditors
	End Property
End Class


'==============================================================================
' Элемент кэша XSL страниц (g_oXsltPageCacheStatic).
Class XslCacheEntry
	Private m_sUserDataNamePrefix	' префикс ключа в UserData, под которым хранится Xsl
	
	Public Xsl						' As IXMLDOMDocument - документ с XSLT-шаблоном
	
	' Устанавливает префикс ключа в UserData, под которым будет храниться Xsl
	Public Sub SetUserDataNamePrefix(sName)
		m_sUserDataNamePrefix = "XSL." & sName & "."
	End Sub
	
	' Возвращает префикс ключа в UserData, под которым хранится Xsl
	Public Property Get UserDataNamePrefix
		UserDataNamePrefix = m_sUserDataNamePrefix
	End Property
End Class

Private g_oXsltPageCacheStatic ' As Scripting.Dictionary - кэщ xsl. Ключ - наименование xsl, значение - экземпляр XslCacheEntry
Set g_oXsltPageCacheStatic = CreateObject("Scripting.Dictionary")

'==============================================================================
' Создание стандартного построителя страниц
' см. EditorPageXsltBuilderClass::InitIndirect
Function X_CreateXsltPageBuilder(oObjectEditor, sXsltFileName, sExpandPropertyPath)
	Set X_CreateXsltPageBuilder = New EditorPageXsltBuilder
	X_CreateXsltPageBuilder.InitIndirect oObjectEditor, sXsltFileName, sExpandPropertyPath
End Function


'==============================================================================
'implements interface IEditorPageBuilder:
'GetHtml(oObjectEditor As ObjectEditor)
'Init(PageMetadata As XMLDOMElement)
'IsEqual(oBuilder As IEditorPageBuilder) As Boolean
Class EditorPageXsltBuilderClass	' : IEditorPageBuilder
	Private m_sXsltFileName		' As String
	Private m_sExpandProperty	' As String
	Private m_oObjectEditor
	
	'==========================================================================
	Public Sub Dispose()
		Set m_oObjectEditor = Nothing
	End Sub
	
	'==========================================================================
	Public Sub Init(oObjectEditor, oPageMetadata)
		InitIndirect oObjectEditor, Trim(oPageMetadata.text), oPageMetadata.GetAttribute("expand")
	End Sub
	
	'==========================================================================
	' Инициализация построителя HTML-страниц редактора
	' [in] oObjectEditor - редактор
	' [in] sXsltFileName - имя Xslt - файла используемого для построения страницы
	' [in] sExpandProperty - список свойств которыедлжны присуствовать в Xml (см. XmlObjectNavigatorClass::ExpandProperty)
	Public Sub InitIndirect(oObjectEditor, sXsltFileName, sExpandProperty)
		Set m_oObjectEditor = oObjectEditor
		m_sXsltFileName = sXsltFileName
		m_sExpandProperty = trim("" & sExpandProperty)
	End Sub

	'==========================================================================
	Public Property Get XsltFileName
		XsltFileName = m_sXsltFileName
	End Property


	'==========================================================================
	Public Function IsEqual(oBuilder) 'As Boolean
		IsEqual = False
		If TypeName(Me)<>TypeName(oBuilder) Then Exit Function
		If XsltFileName <> oBuilder.XsltFileName Then Exit Function
		IsEqual = True
	End Function


	'==========================================================================
	Private Property Get IsInterrupted
		IsInterrupted = m_oObjectEditor.IsInterrupted
	End Property


	'==========================================================================
	' Возвращает XmlDomDocument, содержащий Xsl
	' [In] sName  - имя прогружаемой Xsl
	Public Function GetXsl(sName)
		Set GetXsl = InternalGetXsl(sName).Xsl
	End Function
	

	'==========================================================================
	' Возвращает XmlDomDocument, содержащий Xsl, рекурсивная функция
	' [In] sName				- имя прогружаемой Xsl
	' [In] oContextDictionary	- словарик для предотвращения циклического включения
	Private Function InternalGetXsl(sName)
		Dim oEntry
		Dim oXsl					' IXMLDOMDocument, содержащий Xsl
		Dim sXslMD5					' MD5 каталога с XSL
		Dim bSave
		Dim sXslLocalFileName		' имя XSL на локальном диске
		Dim sXslToIncludeName		' наименование внешней XSL, подлежащей внедрению
		Dim oXslIncludeEntry		' IXMLDOMElement, ссылка на внешний XSL (xsl:include или xsl:import)
		Dim oIncludedEntry
		Dim bReload
		Dim oNewEntry
		
		If g_oXsltPageCacheStatic.Exists(sName) Then
			' Если нашли - вернём из кэша
			Set oEntry = g_oXsltPageCacheStatic.Item (sName)
		Else
			Set oEntry = New XslCacheEntry
			oEntry.SetUserDataNamePrefix sName
			
			bSave = False
			sXslMD5 = X_GetMD().GetAttribute("xsl-md5")
					
			If XService.GetUserData( oEntry.UserDataNamePrefix & sXslMD5 , oXsl) Then
				Set oEntry.Xsl = oXsl.ownerDocument
				If Not IsNothing(oEntry.Xsl.DocumentElement.SelectSingleNode("@*[local-name()='off-cache']")) Then
					' Переполучим с сервера
					Set oEntry.Xsl = XService.XmlGetDocument( "Xsl/" & sName)
					bSave = True 
				End If
			Else
				' Почистим кэш XSL-ей
				internal_ClearDataCache oEntry.UserDataNamePrefix
				' Получим с сервера
				Set oEntry.Xsl = XService.XmlGetDocument( "Xsl/" & sName)
				bSave = True
			End If
			g_oXsltPageCacheStatic.Add sName, oEntry
			If bSave Then
				bReload = False
				Set oNewEntry = oEntry.Xsl.CreateElement("xsl:import")
				For Each oXslIncludeEntry In oEntry.Xsl.documentElement.selectNodes("xsl:import[@href]|xsl:include[@href]")
					bReload = True
					sXslToIncludeName = oXslIncludeEntry.GetAttribute("href")
					Set oIncludedEntry = InternalGetXsl(sXslToIncludeName)
					sXslLocalFileName = "file://" & Replace( XService.GetAppDataPath() , "\", "/") & "/" & XService.UrlEncode( oIncludedEntry.UserDataNamePrefix & sXslMD5 & ".xml")
					Set oNewEntry = oEntry.Xsl.CreateElement("xsl:import")
					oNewEntry.SetAttribute "href", sXslLocalFileName
					oEntry.Xsl.documentElement.InsertBefore oNewEntry.CloneNode(True), oEntry.Xsl.documentElement.firstChild
					oXslIncludeEntry.parentNode.RemoveChild oXslIncludeEntry
				Next
				' Запишем в кэш
				XService.SetUserData oEntry.UserDataNamePrefix & sXslMD5 , oEntry.Xsl.documentElement				
				If bReload Then
					Call XService.GetUserData( oEntry.UserDataNamePrefix & sXslMD5 , oXsl)
					Set oEntry.Xsl = oXsl.ownerDocument
				End If
			End If
		End If
		Set InternalGetXsl = oEntry
	End Function


	'==========================================================================
	' Возвращает Html контента страницы
	Public Function GetHtml()
		Dim oStyle			' Xsl-шаблон (XmlDOMDocument)
		Dim oTemplate		' XslTemplate
		Dim oProcessor		' XslProcessor
		Dim nOffset			' позиция символа "?" в имени Xsl
		Dim oQS				' CQueryString - строка параметров Xsl-страницы
		Dim oXmlNavigator
		Dim oXmlObject
		Dim sStyleSheet
		
		sStyleSheet = m_sXsltFileName

		' Инстанцируем объект со строкой запроса
		Set oQS = X_GetEmptyQueryString
		
		' Если стильшит страницы задан как XSL-файл, то получим его наименование 
		' без параметров для обеспечения возможности загрузки из кеша (а потом -
		' при отсутствии в кеше - с сервера). 
		' Это верно, так как параметры для XSL-шаблона нужны только на клиенте.
		' Если же стильшит задан как серверный скрипт, то пошлем запрос на сервер 
		' полностью, включая query-string. Эти два случая определяем по наличию
		' расширения .xsl в наименовании запрашиваемого ресурса
		
		' Попытаемся определить наличие строки запроса в имени Xsl
		nOffset  = InStr( sStyleSheet, "?")
		' Нашли...
		If nOffset > 0 Then
			' Занесём строку запроса в объектик
			oQS.QueryString = MID( sStyleSheet, nOffset + 1 )
			' Для "чистых" XSL-страниц не имеет смысла передавать параметры
			' на сервер - уберем их. "Чистые" страницы опредеяем по наличию
			' расширения .xsl в наименовании запрашиваемого ресурса:
			If (nOffset - Len(".xsl")) = InStr( LCase(sStyleSheet), ".xsl?") Then
				sStyleSheet = MID( sStyleSheet, 1, nOffset - 1 )
			End If
		End If
		oQS.AddValues m_oObjectEditor.QueryString
		
		' Загружаем шаблон
		On Error Resume Next
		Set oStyle = GetXsl( sStyleSheet)
		If Err Then
			X_ErrReport
			Exit Function
		End If
		On Error GoTo 0
		If IsInterrupted = True Then 
			Exit Function
		End If	
		' Создаем XslTemplate
		Set oTemplate = CreateObject( "MSXml2.XslTemplate.3.0")
		' Указываем используемый шаблон
		oTemplate.stylesheet = oStyle
		' Создаем процессор
		Set oProcessor = oTemplate.createProcessor
		Set oXmlNavigator = m_oObjectEditor.CreateXmlObjectNavigator()
		
		If IsInterrupted = True Then 
			Exit Function
		End If	
		
		If 0<>Len(m_sExpandProperty) Then
			oXmlNavigator.ExpandProperty m_sExpandProperty
		End If
		
		If IsInterrupted = True Then 
			Exit Function
		End If	
		
		Set oXmlObject = oXmlNavigator.XmlObject
		' Передаем процессору трансформируемый документ - данные
		oProcessor.input = oXmlObject
		oProcessor.addObject oXmlNavigator, "urn:xml-object-navigator-access"
		' Передаем процессору объект доступа к данным редактора/мастера
		oProcessor.addObject m_oObjectEditor, "urn:object-editor-access"
		' Передаем процессору объект доступа к окну редактора/мастера
		oProcessor.addObject window, "urn:editor-window-access"
		' Передаем процессору объект доступа к строке параметров Xsl
		oProcessor.addObject oQS, "urn:query-string-access"
		' Передаем процессору объект доступа к IXClientService
		oProcessor.addObject XService, "urn:x-client-service"
		' Передаем процессору объект доступа к себе
		oProcessor.addObject Me, "urn:x-page-builder"
		On Error Resume Next
		' Трансформируем
		oProcessor.transform
		' Может окно уже закрыли...
		If IsInterrupted = True Then 
			' Раз окно уже закрыли - задавим возможную ошибку!
			err.Clear 
			Exit Function
		End If		
		If Err Then
			' TODO: Alert !!!
			Alert "Ошибка при преобразовании входного документа процессором Xsl!" & vbNewLine & Err.Description
			Exit Function
		End If
		GetHtml = oProcessor.output
	End Function
	
	'==================================================================
	' Возвращает значение элемента метаданных, полученного XPath-запросом, 
	' выполняемым в контексте указанного свойства указанного типа
	' Используется из xslt-шаблонов.
	' [In] oProp  - IXmlDOMElement cо свойством или 
	'				IXmlDOMNodeList, первый элемент которого есть свойство или 
	'				имя свойства в текеущем объекте
	' [In] sQuery - текст XPath-запроса...
	Public Function MDQueryProp( oProp, sQuery)
		MDQueryProp = MDQueryPropDef(oProp, sQuery, "")
	End Function	


	'==================================================================
	' Возвращает значение элемента метаданных, полученного XPath-запросом, 
	' выполняемым в контексте указанного свойства указанного типа.
	' Используется из xslt-шаблонов.
	'	[in] oProp  - IXmlDOMElement cо свойством или 
	'				IXmlDOMNodeList, первый элемент которого есть свойство или 
	'				имя свойства в текеущем объекте
	'	[in] sQuery - текст XPath-запроса...
	'	[in] sDefValue - значение по умолчанию, используемое, если запрашиваемый узел не найден
	Public Function MDQueryPropDef( oProp, sQuery, sDefValue)
		Dim vVal	' Значение св-ва
		MDQueryPropDef = sDefValue
		If 0=StrComp(  typename(oProp), "IXmlDomNodeList", vbTextCompare) Then
			Set vVal = m_oObjectEditor.PropMD(oProp.item(0)).selectSingleNode( sQuery)
		Else
			Set vVal = m_oObjectEditor.PropMD(oProp).selectSingleNode( sQuery)
		End If 
		If vVal Is Nothing Then Exit Function
		vVal = vVal.nodeTypedValue
		If IsNull( vVal) Then Exit Function
		MDQueryPropDef = vVal
	End Function	

	
	'==================================================================
	' Вовзвращает True/False если в метаданных свойства заданный XPath что-то нашел
	Public Function IsMDPropExists( oProp, sQuery)
		If 0=StrComp(  typename(oProp), "IXmlDomNodeList", vbTextCompare) Then
			IsMDPropExists = Not m_oObjectEditor.PropMD(oProp.item(0)).selectSingleNode( sQuery ) Is Nothing
		Else
			IsMDPropExists = Not m_oObjectEditor.PropMD(oProp).selectSingleNode( sQuery ) Is Nothing
		End If 
	End Function


	'==================================================================
	' Выполняет выражение и возвращает полученное значение
	' Предназначена для использование в Xsl-странице при рендеринге
	' Если передали пустое значение, то на выходе тоже будет пустое значение
	Public Function Evaluate( sExpression)
		Dim vResult	' Результат выполнения
		If Len("" & sExpression) > 0 Then
			vResult = Eval( sExpression)
			If Err.number Then
				Alert  sExpression  & vbNewLine & Err.number & vbNewLine & Err.Description & vbNewLine  & Err.Source 
			End If	
		Else
			vResult = ""
		End If
		Evaluate = vResult
	End Function	


	'==========================================================================
	' Возвращает значение заданного атрибута метаданный свойства, являющегося родительским для текущего объекта 
	' Работает только для вложенный объектов
	'	<!-- имя свойства, на котором построено виртуальное объектное свойство -->
	'   <xsl:variable name="build-on-name" select="b:Evaluate('eval( iif(IsIncludedEditor,&quot;&quot;&quot;&quot;&quot; &amp; PropMD( XmlObject.parentNode).getAttribute(&quot;&quot;built-on&quot;&quot;)&quot; ,&quot;0&quot; ))')"/>
	'	<!-- имя индексного свойства линка -->
	'	<xsl:variable name="order-by-name" select="b:Evaluate('eval( iif(IsIncludedEditor,&quot;&quot;&quot;&quot;&quot; &amp; PropMD( XmlObject.parentNode).getAttribute(&quot;&quot;order-by&quot;&quot;)&quot; ,&quot;0&quot; ))')"/>	
	Public Function GetSpecialName(sName)
		GetSpecialName = ""
		If Not IsNothing(m_oObjectEditor.ParentXmlProperty) Then
			GetSpecialName = "" & m_oObjectEditor.PropMD(m_oObjectEditor.ParentXmlProperty).getAttribute(sName)	
		End If
	End Function


	'==========================================================================
	' Возвращает полный HtmlId для редактора свойства на основании узла xml-свойтсва.
	' Используется из XSLT шаблонов
	'	[in] oNode - IXMLNodeList
	Public Function GetHtmlID(oNode)
		GetHtmlID = m_oObjectEditor.GetHtmlID(oNode.item(0)) & "#" & XService.NewGuidString
	End Function


	'==========================================================================
	' Возвращает уникальное наименование для PropertyEditor'a, используя PageNameManager из редактора
	'	[in] xslt контекст 
	Public Function GetUniqueNameFor(oXSLTContext)
		GetUniqueNameFor = m_oObjectEditor.GetUniqueNameFor( oXSLTContext.item(0) )
	End Function

	
	'==========================================================================
	' Возвращает xml-узел ds:prop метаданных свойств
	' "Специальная" версия для использования из XSLT-шаблона - возвращает новый документ, 
	' т.к. XSLT помечает все XMLDocument'ы как read-only и передать ему наши метаданные мы не может, 
	' т.к. они могут модифицироваться (подгружаться по ходу запросов новых типов)
	'	[in]  oXSLTContext - XSLT-контекст. xml-узел текущего свойства
	Public Function GetPropMD(oXSLTContext)
		Dim oXmlDoc		' As IXMLDOMDocument - новый документ, для возврата в XSLT
		Dim oXmlPropMD	' As IXMLDOMElement - узел ds:prop
		
		Set oXmlPropMD = m_oObjectEditor.PropMD( oXSLTContext.item(0) )
		Set oXmlDoc = oXmlPropMD.ownerDocument.cloneNode( false) 
		oXmlDoc.appendChild oXmlPropMD.CloneNode( true)
		oXmlDoc.SetProperty "SelectionNamespaces", oXmlPropMD.ownerDocument.GetProperty("SelectionNamespaces")
		oXmlDoc.SetProperty "SelectionLanguage", oXmlPropMD.ownerDocument.GetProperty("SelectionLanguage")
		Set GetPropMD = oXmlDoc.documentElement
	End Function


	'==========================================================================
	' Возвращает xml-узел ds:type метаданных типа
	' "Специальная" версия для использования из XSLT-шаблона - возвращает новый документ, 
	' т.к. XSLT помечает все XMLDocument'ы как read-only и передать ему наши метаданные мы не может, 
	' т.к. они могут модифицироваться (подгружаться по ходу запросов новых типов)
	'	[in] sTypeName - наименование типа
	Public Function GetTypeMD(sTypeName)
		Dim oXmlDoc		' As IXMLDOMDocument - новый документ, для возврата в XSLT
		Dim oXmlTypeMD	' As IXMLDOMElement - узел ds:type
		
		Set oXmlTypeMD = X_GetTypeMD(sTypeName)
		Set oXmlDoc = oXmlTypeMD.ownerDocument.cloneNode( false) 
		oXmlDoc.appendChild oXmlTypeMD.CloneNode( true)
		oXmlDoc.SetProperty "SelectionNamespaces", oXmlTypeMD.ownerDocument.GetProperty("SelectionNamespaces")
		oXmlDoc.SetProperty "SelectionLanguage", oXmlTypeMD.ownerDocument.GetProperty("SelectionLanguage")
		Set GetTypeMD = oXmlDoc.documentElement
	End Function
	
	
	'==========================================================================
	' Назначение:	Returns the first nonnull expression among its arguments
	' Отличие от одноименной функции в x-vbs.vbs в том, что если оба переданных значения пустые, то возвращается пустая строка
	Public Function nvl(a,b)
		nvl = Coalesce(Array(a,b))
		If IsEmpty(nvl) Then nvl=""
	End Function


	'==========================================================================
	' Возвращает строку с закодированным XML первого элемента коллекции
	'	[in] oNodeList As IXMLNodeList
	'	[retval] As String
	Public Function GetXmlString(oNodeList)
		GetXmlString = ""
		If oNodeList Is Nothing Then Exit Function
		If oNodeList.length = 0 Then Exit Function
		GetXmlString = XService.UrlEncode(oNodeList.item(0).cloneNode(true).xml)
	End Function
End Class


'===============================================================================
'@@GetDataArgsClass
'<GROUP !!CLASSES_x-editor-page><TITLE GetDataArgsClass>
':Назначение:	Класс параметров процедуры сбора данных от редакторов свойств.
'
'@@!!MEMBERTYPE_Methods_GetDataArgsClass
'<GROUP GetDataArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_GetDataArgsClass
'<GROUP GetDataArgsClass><TITLE Свойства>
Class GetDataArgsClass
	'@@GetDataArgsClass.Reason
	'<GROUP !!MEMBERTYPE_Properties_GetDataArgsClass><TITLE Reason>
	':Назначение:	Причина процесса сбора данных.
	':Примечание:	Значение свойства есть константа вида REASON_nnnn
	'				(см. x-editor.vbs).
	':Сигнатура:	Public Reason [As Int]
	Public Reason
	
	'@@GetDataArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_GetDataArgsClass><TITLE ReturnValue>
	':Назначение:	Признак успешного завершения сбора данных от редактора
	'				свойства. Здесь:
	'				* True - получение данных успешно завершено;
	'				* False - процесс сбора данных завершился ошибкой.
	':См. также:	GetDataArgsClass.ErrorMessage
	':Сигнатура:	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	'@@GetDataArgsClass.SilentMode
	'<GROUP !!MEMBERTYPE_Properties_GetDataArgsClass><TITLE SilentMode>
	':Назначение:	Признак "тихого" режима сбора данных (см. замечания).
	':Примечания:
	'	Если в процессе сбора данных возникает ошибка, то в общем случае XPE
	'	отражает факт ошибки установкой свойства GetDataArgsClass.ReturnValue
	'	в значение False. Описание ошибки при этом записывается в ErrorMessage.
	'	Однако возможны такие случаи реализации XPE, когда ошибка отображается 
	'	самим редактором свойства.<P/>
	'	При этом существуют сценарии, когда какое-либо отображение не требуется 
	'	(например, при попытке сбора данных редактора временного объекта, 
	'	используемого при задании параметров фильтра, для сервисного сохранения 
	'	этих параметров при переходе на другую страницу).<P/>
	'	Свойство SilentMode указывает редактору свойства случай такого сценария: 
	'	если свойство установлено в True, то логика редактора свойства должна 
	'	блокировать вывод каких-либо сообщений. При этом вся информация об ошибке 
	'	может быть передана через свойства ReturnValue и ErrorMessage.
	':См. также:	GetDataArgsClass.ReturnValue, GetDataArgsClass.ErrorMessage
	':Сигнатура:	Public SilentMode [As Boolean]
	Public SilentMode
	
	'@@GetDataArgsClass.ErrorMessage
	'<GROUP !!MEMBERTYPE_Properties_GetDataArgsClass><TITLE ErrorMessage>
	':Назначение:	
	'	Текст сообщения об ошибке, возникшей в редакторе свойства в процессе 
	'	сбора данных (см. замечания).
	':Примечание:			
	'	Значение свойства анализируется логикой редактора только в том случае,
	'	когда свойство GetDataArgsClass.ReturnValue установлено в значение False.
	'	В этом случае редактор показывает заданный текст в виде сообщения об ошибке.
	':Сигнатура:	Public ErrorMessage [As String]
	Public ErrorMessage
	
	' Внутренний метод инициализации, "конструктор"
	Private Sub Class_Initialize
		ReturnValue = True
		SilentMode = False
	End Sub
	
	'@@GetDataArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_GetDataArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As GetDataArgsClass]
	Public Function Self
		Set Self = Me
	End Function
	
	'@@GetDataArgsClass.Clone
	'<GROUP !!MEMBERTYPE_Methods_GetDataArgsClass><TITLE Clone>
	':Назначение:	Создает полную копию данного экземпляра объекта.
	':Сигнатура:	Public Function Clone() [As GetDataArgsClass]
	Public Function Clone
		Dim o
		Set o = New GetDataArgsClass
		o.ErrorMessage = ErrorMessage
		o.Reason = Reason
		o.ReturnValue = ReturnValue
		o.SilentMode = SilentMode
		Set Clone = o
	End Function
End Class


'===============================================================================
'@@EnableControlsEventArgsClass
'<GROUP !!CLASSES_x-editor-page><TITLE EnableControlsEventArgsClass>
':Назначение:	
'	Класс параметров события "EnableControls", генерируемого редактором при 
'	выполнении общей блокировки / разблокировки элементов (страницы) редактора.
'
'@@!!MEMBERTYPE_Methods_EnableControlsEventArgsClass
'<GROUP EnableControlsEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_EnableControlsEventArgsClass
'<GROUP EnableControlsEventArgsClass><TITLE Свойства>
Class EnableControlsEventArgsClass
	'@@EnableControlsEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_EnableControlsEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@EnableControlsEventArgsClass.Enable
	'<GROUP !!MEMBERTYPE_Properties_EnableControlsEventArgsClass><TITLE Enable>
	':Назначение:	Признак разблокировки элементов (страницы) редактора:
	'				* True - блокировка для элементов снимается;
	'				* False - блокировка устанавливается.
	':Сигнатура:	Public Enable [As Boolean]
	Public Enable
	
	'@@EnableControlsEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_EnableControlsEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As EnableControlsEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function	
End Class
