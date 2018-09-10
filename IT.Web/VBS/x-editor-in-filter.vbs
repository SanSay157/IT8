'*******************************************************************************
' Реализация фильтра с помощью редактора временного объекта.
' Фильтр "живет" во фрейме, который вставлен в x-filter.htc
' ВНИМАНИЕ: обращение ко всем глобальным переменным должно выполняться с помощью parent
'*******************************************************************************
Option Explicit

'==============================================================================
' Назначение:	Реализация IObjectContainerEventsClass
'				для использования в скриплете в качесве фильтра
' Интерфейс данного класса фиксирован, т.к. используется экземпляром ObjectEditorClass
Class ObjectEditorScriptletContainerEventsClass
	' Экземпляр класса контейнера хост-страницы, т.е. страницы создающией и инициализирующей экземпляр FilterObject
	' В x-list - это XListPageClass
	' В x-tree - это XTreePageClass
	Public OuterContainerPage

	' Внешний EventEngine - для генерации событий в страницу, на которой располагается фильтр 
	'	Сюда генерируются события:
	'		EnableControls (EventArgs - EnableControlsEventArgs) - (рас)блокирование контролов
	'		Accel (EventArg: AccelerationEventArgsClass) - нажатие клавиши-акселератора
	'		Apply (EventArg: Nothing) - применение условий фильтрации (XFW не использует, но может использовать прикладной код)
	'		SetCaption (EventArg: SetCaptionEventArgsClass) - установка заголовка фильтра
	Public ExternalEventEngine
		
	'==========================================================================
	' Редактор запрашивает об изменении заголовка
	'	[in] oObjectEditor
	'	[in] sEditorCaption As String - заголовок редактора. Может содержать HTML-форматирование.
	'	[in] sPageCaption As String - заголовок страницы. Может содержать HTML-форматирование.
	Public Sub OnSetCaption(oObjectEditor, sEditorCaption, sPageCaption)
		If ExternalEventEngine.IsHandlerExists("SetCaption") Then 
			With New SetCaptionEventArgsClass
				.EditorCaption = sEditorCaption
				.PageTitle = sPageCaption
				XEventEngine_FireEvent ExternalEventEngine, "SetCaption", oObjectEditor, .Self()				
			End With
		End If
	End Sub


	'==========================================================================
	' Редактор просит изменить состояние доступности контролов контейнера
	Public Sub OnEnableControls(oObjectEditor, bEnable, vReserved)
		' Из родных контролов у нас только табер, но он может быть скрыт
		If oObjectEditor.IsMultipageEditor Then
			Tabs.Enabled = bEnable
		End If
		' Без DoEvents фильтр "мигает", до конца эффект не понятен
		XService.DoEvents
		' сгенерируем событие "EnableControls" вовне
		With New EnableControlsEventArgsClass
			.Enable = bEnable
			XEventEngine_FireEvent ExternalEventEngine, "EnableControls", Me, .Self()
		End With
	End Sub


	'==========================================================================
	' Возвращает редактору HTMLDIV, в который он может вставлять свое содержимое
	'	[in] oObjectEditor
	'	[in] vReserved
	Public Function OnGetPageDiv(oObjectEditor, vReserved)
		Set OnGetPageDiv = document.all("x_editor_content_div",0)
	End Function
	
	
	'==========================================================================
	' Редактор сообщает о том, что можно приступать к инициализации интерефейса контейнера
	'	[in] oObjectEditor As ObjectEditorClass - редактор
	'	[in] vReserved
	Public Sub OnInitializeUI(oObjectEditor, vReserved)
		If oObjectEditor.IsEditor Then
			If oObjectEditor.IsMultipageEditor Then
				'TODO: не видно надобности: TabsRow.style.display = "block"
				XEditor_xPaneTabs.style.display = "block"
				Tabs.style.display = "block"
				XService.DoEvents
			End If
		Else
			err.Raise -1, "SetUiByMode", "Wizard not supported for filters!"	
		End If
	End Sub
	
	
	'==========================================================================
	' Редактор сообщает о добавления описания страницы.
	'	[in] oObjectEditor As ObjectEditorClass - редактор
	'	[in] oPage As EditorPageClass - описание страницы
	Public Sub OnAddEditorPage(oObjectEditor, oPage, vReserved)
		Dim nIndex		' индекс добавленной закладки
		If g_bExiting Then Exit Sub
		nIndex = Tabs.AddIdentified( oPage.PageName, oPage.PageTitle, oPage.PageHint, "" )
		' если добавленная страница должна быть скрыта, то скроем закладку ей соответствующую
		If oPage.IsHidden Then
			Tabs.HideTab nIndex, True
		End If
	End Sub

	
	'==========================================================================
	' Редактор сам хочет перейти на заданной странице. 
	' Только для многозакладочного редактора!
	Public Sub OnActivateEditorPage(oObjectEditor, nPageIndex, vReserved)
		If g_bExiting Then Exit Sub
		Tabs.ActiveTab = nPageIndex
	End Sub
	
	
	'==========================================================================
	' Редактор сообщает об изменении состава операций
	'	[in] oArgs As SetWizardOperationsArgsClass
	Public Sub OnSetWizardOperations(oObjectEditor, oArgs)
		' В фильтрах мастера не используем
	End Sub

	
	'==========================================================================
	' Редактор сообщает об изменении состава операций
	'	[in] oArgs As SetWizardOperationsArgsClass
	Public Sub OnSetEditorOperations(oObjectEditor, oArgs)
		' Nothing To Do
	End Sub

	
	'==========================================================================
	Public Sub OnSetStatusMessage( oObjectEditor, sMsg, vReserved )
		StatusDiv.innerText = sMsg
		If Len(sMsg) > 0 Then
			StatusDiv.style.display = "block"
		Else
			StatusDiv.style.display = "none"
		End If
		XService.DoEvents
	End Sub
	
	
	'==========================================================================
	' Обработчик нажатия комбинации клавиш
	'	[in] oSender As источник события
	'	[in] oEventArgs As AccelerationEventArgsClass
	Public Sub OnKeyUp(oSender, oEventArgs)
		' Событие вытолкнем наружу (например, может инициировать перегрузку списка/дерева по нажатию Ентера)
		XEventEngine_FireEvent ExternalEventEngine, "Accel", Me, oEventArgs
	End Sub
End Class


'==============================================================================
' Назначение:	Одна из реализаций ObjectEditorContainerClass
' Примечание:	Интерфейс данного класса в отличии от ObjectContainerEventsClass
'				не является фиксированным...
Class ObjectEditorScriptletContainerClass
	Public m_oObjectEditor		' Редактор (экземпляр ObjectEditorClass)
	Public XmlState				' IXMLDOMElement, состояние фильтра
	Public QueryString			' экземпляр QueryStringClass	
	
	'==========================================================================
	' Назначение:	Инициализация
	' Результат:
	'	true если всё хорошо, иначе false 
	' Параметры:	
	'	[in] oContainerEvents - экземпляр ObjectContainerEventsClass
	' Примечание:	
	' Зависимости:
	' Пример: 		
	Public Function Init(oContainerEvents)
		Dim sInitResult		' сообщение от Init
		Dim oObjectEditor	' ObjectEditor
		Dim oParams			' As ObjectEditorInitializationParametersClass

		Set oObjectEditor = New ObjectEditorClass
		Set oParams = getEditorInitializationParams()
		sInitResult = oObjectEditor.Init(oContainerEvents, oParams)
		If Len("" & sInitResult) > 0 Then
			oContainerEvents.OnSetStatusMessage oObjectEditor, sInitResult, Null
			Init = False
		Else
			Set m_oObjectEditor = oObjectEditor
			Init = True
		End If
	End Function


	'==========================================================================
	' Возвращает заполненные инициализирующие параметры для редактор
	Private Function getEditorInitializationParams()
		Dim oParams				' As ObjectEditorInitializationParametersClass
		
		Set oParams = New ObjectEditorInitializationParametersClass
		' Инициализируем данные редактора
		With oParams
			.ObjectType = X_PAGE_OBJECT_TYPE
			.MetaName = X_PAGE_METANAME
			.CreateNewObject = True
			If Not XmlState Is Nothing Then
				.ObjectID = XmlState.getAttribute("main-oid")
				Set .InitialObjectSet = XmlState
			End If
			Set .QueryString = QueryString
			Set .InterfaceMD = XService.XmlFromString( document.all("oMetadata",0).value )
			.SkipInitErrorAlerts = True
		End With	
		Set getEditorInitializationParams = oParams
	End Function


	'==========================================================================
	' Назначение:	Обработка желания пользователя переключить закладку
	' Результат:
	'	true если всё можно, иначе false 
	' Параметры:	
	' Примечание:	
	' Зависимости:
	' Пример: 		
	Public Function OnBeforeTabsSwitch()
		OnBeforeTabsSwitch = m_oObjectEditor.CanSwitchPage
	End Function
	
	
	'==========================================================================
	' Назначение:	Обработка переключения закладок
	' Вызывается из обработчика события OnSwitch объекта Tabs
	Public Sub OnTabsSwitch()
		' Переинициализирую вкладку
		m_oObjectEditor.SwitchToPageByPageID Tabs.ActiveTabID
	End Sub
	
	
	'==========================================================================
	' Назначение:	Отображение справки
	' Результат:
	' Параметры:
	' Примечание:	
	' Зависимости:
	' Пример: 		
	Public Sub OnHelp
		If m_oObjectEditor.IsHelpAvailiable Then
			X_OpenHelp m_oObjectEditor.HelpPage
		End If	
	End Sub


	'==========================================================================
	' Назначение:	Выгрузка страницы
	' Результат:
	' Параметры:
	' Примечание:	
	' Зависимости:
	' Пример: 		
	Public Sub OnWindowUnload
		Set m_oObjectEditor = Nothing
	End Sub
	
	
	'==========================================================================
	' Назначение:	Проверка "занятости" реадктора
	' Результат:
	' 	=true если редактор "занят", иначе false
	' Параметры:
	' Примечание:	
	' Зависимости:
	' Пример: 		
	Public Function GetMayBeInterrupted
		GetMayBeInterrupted = m_oObjectEditor.MayBeInterrupted
	End Function
	
	
	'==========================================================================
	' Назначение:	Сброс ограничений фильтра
	' Результат:
	' Параметры:
	' Примечание:	
	' Зависимости:
	Public Sub 	OnClearRestrictions
		m_oObjectEditor.Internal_RestartEditor
	End Sub
	
	
	'==========================================================================
	' Назначение:	Получение ограничений фильтра
	' Результат:
	' Параметры:
	'	[in] oFilterObjectGetRestrictionsParamsObject - экземпляр FilterObjectGetRestrictionsParamsClass
	' Примечание:	
	' Зависимости:
	Public Sub 	OnGetRestrictions(oFilterObjectGetRestrictionsParamsObject)
		Dim oXmlObject		' Объект по которому мы собираем ограничения
		Dim oXmlProperty	' Свойство объекта
		Dim oXmlObjectRef	' Ссылка от oXmlObject на другой объект
		' "Сохраним" все изменения
		If Not m_oObjectEditor.FetchXmlObject(False) Then
			oFilterObjectGetRestrictionsParamsObject.ReturnValue = False 
			Exit Sub
		End If	
		' Проитерируем головной элемент
		Set oXmlObject = m_oObjectEditor.XmlObject
		For Each oXmlProperty In oXmlObject.SelectNodes("*")
			If IsNull(oXmlProperty.dataType) Then
				' Объектное свойство - пихаем идентификаторы
				For Each oXmlObjectRef In oXmlProperty.selectNodes("*/@oid")
					oFilterObjectGetRestrictionsParamsObject.ParamCollectionBuilder.AppendParameter oXmlProperty.TagName, oXmlObjectRef.text
				Next 
			ElseIf 0<Len(oXmlProperty.Text) Then
				oFilterObjectGetRestrictionsParamsObject.ParamCollectionBuilder.AppendParameter oXmlProperty.TagName, oXmlProperty.Text
			End If	 
		Next
	End Sub	
	
	
	'==========================================================================
	' Отображает отладочное меню
	Public Sub OnDebugEvent
		m_oObjectEditor.ShowDebugMenu
	End Sub


	'==========================================================================
	' Обработчик нажатия комбинации клавиш
	'	[in] oEventArgs As AccelerationEventArgsClass
	Public Sub OnKeyUp(oEventArgs)
		m_oObjectEditor.OnKeyUp Me, oEventArgs
	End Sub

	
	'==========================================================================
	Public Sub SetFocus()
		window.focus
		m_oObjectEditor.SetDefaultFocus
	End Sub
End Class

' признак выгрузки окна
Dim g_bExiting

' Глабально доступный экземпляр ObjectEditorScriptletContainerClass		
Dim g_oController
g_oController = Empty

'==============================================================================
' Применение условий фильтрации в контейнере, который владее фильтром
' Формально: генерируется событие "Apply" в EventEngine, переданный фильтру при инициализации
Public Sub ApplyFilter
	XEventEngine_FireEvent g_oController.m_oObjectEditor.ObjectContainerEventsImp.ExternalEventEngine, "Apply", Nothing, Nothing
End Sub

'<ОБРАБОТЧИКИ СОБЫТИЙ window и document>
'==============================================================================
' Обрабочик выгрузки страницы
Sub Window_OnUnload
	g_bExiting = True
	If Not IsObject(g_oController) Then  Exit Sub
	g_oController.OnWindowUnload 
	Set g_oController = Nothing
	g_oController = Empty
End Sub

'==============================================================================
' Обработчик нажатия F1
Sub Document_OnHelp
	If g_bExiting Then Exit Sub
	If Not IsObject(g_oController) Then Exit Sub
	g_oController.OnHelp() 
End Sub

'==============================================================================
' Обработчик Html-события OnKeyUp документа.
' Переадресует событие в экземпляр ObjectEditorScriptletContainerClass
Sub document_OnKeyUp
	If window.event Is Nothing Then Exit Sub
	If g_oController Is Nothing Then Exit Sub
	With window.event
		If Not .srcElement Is Nothing Then
			If Not IsNull(.srcElement.getAttribute("X_IgnoreHtmlEvents")) Then
				Exit Sub
			End If
		End If
		window.event.cancelBubble = True
		window.event.returnValue = False
		
		g_oController.OnKeyUp CreateAccelerationEventArgsForHtmlEvent()
	End With
End Sub
'<ОБРАБОТЧИКИ СОБЫТИЙ window и document>


'<ОБРАБОТЧИКИ ОБЪЕКТА XTabStrip>
'==============================================================================
' Обработка желания пользователя переключить закладку
Sub Tabs_OnBeforeSwitch()
	If Not IsObject(g_oController) Then  Exit Sub
	window.event.returnValue = g_oController.OnBeforeTabsSwitch
End Sub


'==============================================================================
' Обработка переключения закладок
Sub Tabs_OnSwitch()
	' Переинициализирую вкладку
	If Not IsObject(g_oController) Then  Exit Sub
	g_oController.OnTabsSwitch
End Sub
'</ОБРАБОТЧИКИ ОБЪЕКТА XTabStrip>


'<МЕТОДЫ ИНТЕРФЕЙСА IFilterObject>
'==============================================================================
' Назначение:	IFilterObject::Init
' Результат:    
' 	возвращает признак что всё в порядке
' Параметры:	
'	[in] oEventEngine As XEventEngine - менеджер событий, в который фильтр будет генерировать свои события для уведомления контейнера
'	[in] oFilterObjectInitializationParamsObject	- параметры инициализации фильтра
' Примечание:	
'	производит инициализацию системы фильтров
Function public_Init(oEventEngine, oFilterObjectInitializationParamsObject)
	Dim oContainer		' As ObjectEditorScriptletContainerEventsClass - реализация интерфейса конейнера редактора
	Dim oController		' As ObjectEditorScriptletContainerClass - обёртка вокруг редактора
	Dim oReference		' Объектная ссылка (значение)
	Dim aObjectIDs		' As ObjectIdentity() - массив идентификаторов загружаемых объектов
	Dim i
	Dim sString			' As String	- 
	Dim aString			' As String() -
	Dim oGetObjectsResponse	' As XGetObjectsResponse - ответ команды GetObjects
	
	' Переложим кэш прав в текущий контекст
	Set x_oRightsCache = oFilterObjectInitializationParamsObject.GetRightsCache
	Set oController = New ObjectEditorScriptletContainerClass
	Set oController.XmlState =  oFilterObjectInitializationParamsObject.XmlState
	Set oController.QueryString =  toObject(oFilterObjectInitializationParamsObject.QueryString)
	Set oContainer = New ObjectEditorScriptletContainerEventsClass
	Set oContainer.OuterContainerPage = toObject(oFilterObjectInitializationParamsObject.OuterContainerPage)
	Set oContainer.ExternalEventEngine = oEventEngine
	
	If Not oController.XmlState Is Nothing Then
		If "" & X_GetMD().GetAttribute("md5")= "" & oController.XmlState.GetAttribute("metadataMD5") Then
			With oController.XmlState
				.RemoveAttribute "metadataMD5"
				' Пройдем по всем ссылакам и загрузим объекты, на которые ссылается основной объект
				For Each oReference In .SelectNodes("*/*/*[@oid]")
					' Посмотрим что такого объекта нету в пуле
					If Nothing Is .SelectSingleNode(oReference.nodeName & "[@oid='" & oReference.getAttribute("oid") & "']") Then
						' если объект не временный, то будем грузить с сервера
						If "temporary" <> ("" & X_GetTypeMD(oReference.nodeName).GetAttribute("tp")) Then
							If 0=InStr(1, sString, " " & oReference.nodeName & " " & oReference.GetAttribute("oid")) Then
								sString = sString & " " & oReference.nodeName & " " & oReference.GetAttribute("oid")
							End If
						Else
							' иначе (объект - временный, но пуле отсутствует) - очистим ссылку
							oReference.parentNode.removeChild oReference
						End If
					End If
				Next
				sString = Trim(sString)
				If 0<>Len(sString) Then
					aString = Split( sString, " ")
					ReDim aObjectIDs( (UBound(aString)+1)/2-1 )
					For i=0 To UBound(aObjectIDs)
						' примечание: 1-ый параметр наименование типа, 2-ой - идентификатор
						Set aObjectIDs(i) = internal_New_XObjectIdentity( aString(i*2), aString(i*2+1) )
					Next

					With New XGetObjectsRequest
						.m_sName = "GetObjects"
						.m_aList = aObjectIDs
						Set oGetObjectsResponse = X_ExecuteCommand( .Self )
					End With
					
					For Each oReference In oGetObjectsResponse.m_oXmlObjectsList.SelectNodes("*")
						If IsNull(oReference.GetAttribute("not-found")) Then
							.AppendChild(oReference)
						Else
							.SelectNodes("//" & oReference.nodeName & "[@oid='" & oReference.GetAttribute("oid") & "']" ).removeAll
						End If
					Next
				End If	
			End With
		Else
			' Метаданные с последнего раза изменились - сбросим сохрaанённый фильтр
			Set oController.XmlState = Nothing	
		End If
	End if

	If oFilterObjectInitializationParamsObject.DisableContentScrolling Then
		' DIV'у, в который вставляется содержимое всех страниц редактор изменим стиль т.о. чтобы никогда не появлялся scrollbar.
		document.all("x_editor_content_div",0).style.overflow = "hidden"
	End If
	
	If False = oController.Init(oContainer) Then
		public_Init = False
		Exit Function
	End If
	
	Set g_oController = oController
	public_Init = True	
End Function


'==============================================================================
' Назначение:	Возвращает работающий в фильтре редактор объектов
' Результат:	экземпляр ObjectEditorClass  
' Примечание:	
Function public_get_ObjectEditor
	Set public_get_ObjectEditor = Nothing
	If g_bExiting Then Exit Function
	If Not IsObject(g_oController) Then Exit Function
	Set public_get_ObjectEditor = g_oController.m_oObjectEditor
End Function


'-------------------------------------------------------------------------------
' Назначение:	IFilterObject::GetXmlState
' Результат:    клон пула объектов редактора, в котором оставлены временные модифицированные объекты
Function public_GetXmlState
	Dim oXmlPool	' Копия пула редактора
	Dim oXmlObject	' Объект в редакторе
	Set public_GetXmlState = Nothing
	If g_bExiting Then Exit Function
	If Not IsObject(g_oController) Then Exit Function
	' инициируем сбор данных с признаком "тихой" работы
	g_oController.m_oObjectEditor.FetchXmlObject(True)
	Set oXmlPool = g_oController.m_oObjectEditor.Pool.Xml.CloneNode( true)
	For Each oXmlObject In oXmlPool.SelectNodes("*[local-name()!='x-pending-actions']")
		' Будем искать только постоянные объекты
		If "temporary" <> ("" & X_GetTypeMD(oXmlObject.nodeName).GetAttribute("tp")) Then
			' Объект постоянный, удалим его из пула...
			oXmlObject.ParentNode.removeChild oXmlObject
		End If
	Next
	' удалим все атрибуты dirty
	oXmlPool.selectNodes("//@dirty").removeAll
	' Установим аттрибут MD5 из метаданных
	oXmlPool.setAttribute "metadataMD5", "" & X_GetMD.GetAttribute("md5")
	' установим идентификатор "главного" объекта, т.е. того, для которого запускался редактор
	oXmlPool.setAttribute "main-oid", g_oController.m_oObjectEditor.ObjectID
	
	' Вернём значение
 	Set public_GetXmlState = oXmlPool
End Function


'-------------------------------------------------------------------------------
' Назначение:	IFilterObject::IsComponentReady
' Результат:    признак полной загруженности фильтра
Function public_get_IsComponentReady()
	public_get_IsComponentReady = X_IsDocumentReady(Null)
End Function


'-------------------------------------------------------------------------------
' Назначение:	IFilterObject::IsReady
' Результат:    
' 	возвращает признак полной готовности фильтра
Function public_get_IsReady()
	dim bReady
	bReady = public_get_IsComponentReady And IsObject(g_oController) 
	If bReady Then
		bReady = not public_get_IsBusy
	End If
	public_get_IsReady = bReady
End Function


'-------------------------------------------------------------------------------
' Назначение:	IFilterObject::Enabled
'		Управление доступностью
Function public_get_Enabled()
	public_get_Enabled =  True
	If g_bExiting Then Exit Function
	If Not IsObject(g_oController) Then Exit Function
	public_get_Enabled = g_oController.m_oObjectEditor.IsControlsEnabled
End Function

Sub public_put_Enabled( bEnabled)
	If g_bExiting Then Exit Sub
	If Not IsObject(g_oController) Then Exit Sub
	g_oController.m_oObjectEditor.EnableControlsInternal bEnabled, False
	' Из родных контролов у нас только табер, но он может быть скрыт
	If g_oController.m_oObjectEditor.IsMultipageEditor Then
		Tabs.Enabled = bEnabled
	End If
End Sub


'-------------------------------------------------------------------------------
' Назначение:	IFilterObject::IsBusy
Function public_get_IsBusy()
	public_get_IsBusy = False
	If g_bExiting Then Exit Function
	If not IsObject(g_oController) then Exit Function
	public_get_IsBusy = Not g_oController.GetMayBeInterrupted
End Function


'-------------------------------------------------------------------------------
' Назначение:	IFilterObject::ClearRestrictions
' Примечание:
'	Сбрасывает состояние фильтра в первоначальное...	
Sub public_ClearRestrictions()
	If g_bExiting Then Exit Sub
	If not IsObject(g_oController) Then Exit Sub
	g_oController.OnClearRestrictions
End Sub


'-------------------------------------------------------------------------------
' Назначение:	IFilterObject::GetRestrictions
' Параметры:	
Sub public_GetRestrictions(oFilterObjectGetRestrictionsParamsObject)
	If g_bExiting Then Exit Sub
	If not IsObject(g_oController) Then Exit Sub
	If Nothing Is g_oController Then Exit Sub
	g_oController.OnGetRestrictions(oFilterObjectGetRestrictionsParamsObject)  
End Sub

'-------------------------------------------------------------------------------
' Назначение:	IFilterObject::ShowDebugMenu
Sub public_ShowDebugMenu()
	If g_bExiting Then Exit Sub
	If IsNothing(g_oController) Then Exit Sub
	g_oController.OnDebugEvent
End Sub


'-------------------------------------------------------------------------------
' Назначение:	IFilterObject::OnKeyUp
' Обработчик комбинации клавиш, нажатой в контейнере
'	[in] oEventArgs As AccelerationEventArgsClass
Sub public_OnKeyUp(oEventArgs)
	If g_bExiting Then Exit Sub
	If IsNothing(g_oController) Then Exit Sub
	g_oController.OnKeyUp oEventArgs
End Sub

'-------------------------------------------------------------------------------
' Назначение:     IFilterObject::SetFocus
' Установка фокуса
Sub public_SetFocus()
      If g_bExiting Then Exit Sub
      If IsNothing(g_oController) Then Exit Sub
      g_oController.SetFocus
End Sub

'</МЕТОДЫ ИНТЕРФЕЙСА IFilterObject>


'======================================================================
' Обработчик события oncontextmenu - Отлов "отладочных" событий
' Показываем по PopUp-меню и CTRL (если в отладке-CTRL-не обязательно) на заголовке 
Sub OnDebugEvent
	If Not( window.event.ctrlKey  Or X_IsDebugMode)Then Exit Sub
	window.event.returnValue = False
	window.event.cancelBubble = True
	public_ShowDebugMenu()
End Sub
