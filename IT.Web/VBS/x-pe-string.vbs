'*******************************************************************************
' Подсистема:	
' Назначение:	Стандартный функционал обслуживания UI-представления строкового
'				скалярного свойства (для значений vt: string)
'*******************************************************************************

Option Explicit

' Число строк для оценки высоты одной строки при обработке "умных" элементов textarea

'==============================================================================
Class XPEStringLookupClass
	Private m_oPropertyEditorBase	' As XPropertyEditorBaseClass
	Private m_oRefreshButton		' As IHTMLElement - кнопка операции перегрузки кэша
	Private m_bUseCache				' As Boolean - признак использования кэша при загрузке данных с сервера (по умолчанию не используется)
	Private m_sCacheSalt			' As String - выражение на VBS, если указан то используется как дополнительный ключ для наименования элемента кэша
									'	Пример:
									'	cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;)" - данные кэша становятся недействительными при смене метаданных
									'	cache-salt="clng(date())" - данные кэша становятся недействительными раз в сутки
									'	cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;) &amp; &quot;-&quot; &amp; clng(date())" - данные кэша становятся недействительными раз в сутки или при смене метаданных
									'	cache-salt="MyVbsFunctionName()" - вызывается прикладная функция
	Private m_bDisableGetData		' As Boolean - признак выключения сбора данных
	Private m_bKeyUpEventProcessing	' As Boolean - Признак обработки ActiveX-события OnKeyUp для предотвращения бесконечного цикла

	
	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "LoadList,GetRestrictions,Accel", "StringLookup"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEvent "LoadList", Me, "OnLoadList"
		
		' Факт наличия кнопки операции перезагрузки и сами параметры кэширования: 
		Set m_oRefreshButton = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.GetAttribute("RefreshButtonID"), 0 ) 
		m_bUseCache = "" & HtmlElement.getAttribute("UseCache") = "1"
		m_sCacheSalt = "" & HtmlElement.getAttribute("CacheSalt")		
		m_bDisableGetData = False
		ViewInitialize
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
			vRestrictions = X_CreateCommonRestrictions(oSelectorRestrictions.ReturnValue,oSelectorRestrictions.UrlParams,Null)
		End If
		X_ClearListDataCache m_oPropertyEditorBase.HtmlElement.getAttribute("TypeName"), m_oPropertyEditorBase.HtmlElement.getAttribute("ListMetaname"), vRestrictions
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
	' Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property


	'==========================================================================
	' Возвращает типизированное значение из Xml-свойства
	Public Property Get Value
		Value = XmlProperty.nodeTypedValue
	End Property

	
	'==========================================================================
	' Устанавливает значение в контроле и в xml-свойстве
	Public Property Let Value(vValue)
		Dim vHtmlValuePrev		' предыдущее значение в html
		
		vHtmlValuePrev = HtmlElement.value
		HtmlElement.value = vValue
		With New GetDataArgsClass
			.SilentMode = True
			GetData .Self
			If .ReturnValue = False Then
				HtmlElement.value = vHtmlValuePrev
			End If
		End With
	End Property


	'==========================================================================
	' Возвращает типизированное значение из input'a
	Public Property Get RawValue
		RawValue = HtmlElement.value
	End Property

	
	'==========================================================================
	' Устанавливает значение в редакторе свойства
	Public Sub SetData
		Dim oCrocComboBox		' As Croc.IXComboBox
		Dim vValue				' As String - текущее значение
		
		Set oCrocComboBox = m_oPropertyEditorBase.HtmlElement
		vValue = XmlProperty.nodeTypedValue
		If EventEngine.IsHandlerExists("BeforeSetData") Then
			With New BeforeSetDataEventArgsClass
				.CurrentValue = vValue 
				FireEvent "BeforeSetData", .Self()
				' если прикладной обработчик изменил значение, то изменим значение в пуле
				If .CurrentValue <> vValue Then
					vValue = .CurrentValue
					XmlProperty.nodeTypedValue = vValue 
				End If
			End With
		End If
		
		' Занесем значение
		If oCrocComboBox.Editable Then
			oCrocComboBox.text	= vbNullString & vValue
		Else 
			oCrocComboBox.value = vbNullString & vValue
			
			If Not ObjectEditor.SkipInitErrorAlerts Then
				If oCrocComboBox.value <> vValue Then
					If .HasMoreRows Then
						' значение не установилось и записей получено меньше, чем могло бы
						ParentPage.EnablePropertyEditor Me, False
						m_bDisableGetData = True
						MsgBox "Внимание! Значение реквизита """ & PropertyDescription & """ не может быть отображено корректно, " & vbCr & _
							"т.к. полученный список значений с сервера был ограничен условием на максимальное количество строк.", vbExclamation
					Else
						MsgBox _
							"Внимание! Выбранное ранее значение реквизита """ & PropertyDescription & """ более не существует; возможно, оно было" & vbCrLf & _
							"удалено или изменено другим пользователем. Значение свойства будет сброшено." & vbCrLf & _
							"Пожалуйста, выберите новое значение.", vbExclamation, "Внимание - изменение данных"
						' сбросим значение свойства, значение combobox'a уже сброшено
						XmlProperty.nodeTypedValue = ""
					End If
				End If
			End If
		End If		
	End Sub


	'==========================================================================
	' Сбор и валидация данных
	Public Sub GetData(oGetDataArgs)
		Dim vHtmlValue		' значение в Html
		
		If m_bDisableGetData Then Exit Sub
		vHtmlValue = HtmlElement.value
		' Проверяем на NOT NULL: 
		If Not ValueCheckOnNullForPropertyEditor( vHtmlValue, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then Exit Sub
		' Проверяем на максимальную длинну:
		If Not ValueCheckRangeForPropertyEditor(vHtmlValue, m_oPropertyEditorBase, oGetDataArgs) Then Exit Sub
		' Проверим допустимые символы
		If Not CheckOnInvalidCharacters(vHtmlValue, m_oPropertyEditorBase, oGetDataArgs) Then Exit Sub
		' Проверим регулярное выражение
		If Not CheckOnPatternMatch(vHtmlValue, Me, oGetDataArgs) Then Exit Sub
		' Занесём значение в XML:
		GetDataFromPropertyEditor vHtmlValue, m_oPropertyEditorBase, oGetDataArgs
	End Sub

	
	'==========================================================================
	' Устанавливает/возвращает (не)обязательность свойства
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			HtmlElement.removeAttribute "X_MAYBENULL"
			HtmlElement.className = "x-editor-control-notnull x-editor-string-lookup-field"
		Else
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
			HtmlElement.className = "x-editor-control x-editor-string-lookup-field"
		End If			
	End Property

	
	'==========================================================================
	' Устанавливает/возвращает (не)доступность редактора свойства
	Public Property Get Enabled
		 Enabled = HtmlElement.object.Enabled
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.object.Enabled = bEnabled
		' Не забывам про кнопку операции обновления кэша:
		If Not IsNothing(RefreshButton) Then RefreshButton.disabled = Not( bEnabled )
	End Property

	
	'==========================================================================
	' Установка фокуса
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function

	
	'==========================================================================
	' Возвращает Html контрол
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
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
	' IDisposable: подчистка ссылок
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
	End Sub	


	'==========================================================================
	' Выключает сбор данных с PE
	Public Sub DisableGetData
		m_bDisableGetData = True
	End Sub


	'==========================================================================
	' Включает обратно сбор данных с PE
	Public Sub EnableGetData
		m_bDisableGetData = False
	End Sub

	
	'==========================================================================
	' Возвращает HTML-элемент кнопки обновления списка
	Public Property Get RefreshButton
		Set RefreshButton = m_oRefreshButton
	End Property


	'==========================================================================
	' Возбуждает событие
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
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


	'==========================================================================
	' IPropertyEdior: Метод вызывается при построении страницы редактора, после инициализации всех PE на странице
	Public Sub FillData()
		Load False, XmlProperty.nodeTypedValue
	End Sub

	
	'==========================================================================
	' Загружает список
	'	[in] bOverwriteCache - признак сброса закэшированных значений
	'	[in] vValue - начальное значение, устанавливаемое в комбобоксе
	Public Sub Load(bOverwriteCache, vValue)
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass
		
		Set oSelectorRestrictions = new GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions

		With New LoadListEventArgsClass
			.TypeName = m_oPropertyEditorBase.HtmlElement.getAttribute("TypeName")
			.ListMetaname = m_oPropertyEditorBase.HtmlElement.getAttribute("ListMetaname")
			.RequiredValues = vValue
			if Not UseCache then
				.Cache = CACHE_BEHAVIOR_NOT_USE
			elseif bOverwriteCache then
				.Cache = CACHE_BEHAVIOR_ONLY_WRITE
			else
				.Cache = CACHE_BEHAVIOR_USE
			end if	
			.CacheSalt = CacheSalt
			Set .Restrictions = oSelectorRestrictions
			FireEvent "LoadList", .Self()
		End With
	End Sub


	'==========================================================================
	' Пергружает список, отключая кеширование
	Public Sub ReLoad
		Load True, Value
		SetData
	End Sub

	
	'==========================================================================
	' Стандартный обработчик события "LoadList"
	'	[in] oEventArgs As LoadListEventArgsClass
	Public Sub OnLoadList(oSender, oEventArgs)
		Dim sUrlParams			' параметры в страницу загрузчик списка
		Dim sRestrictions		' параметры в список от юзерских обработчиков
		Dim aErr				' As Array - поля объекта Err
		Dim oCrocComboBox		'
		Dim vValue 
		Set oCrocComboBox = m_oPropertyEditorBase.HtmlElement

		With oEventArgs
			' Получим ограничения
			If Not IsNothing(.Restrictions) Then
				sUrlParams = .Restrictions.UrlParams
				sRestrictions =  .Restrictions.ReturnValue
			End If
			' В отличии от обычного комбика в RequiredValues лежит строчка а не идентификатор
			'	поэтому её обработка отличается от стандартной
			vValue = .RequiredValues
			.RequiredValues = Empty
			' сначала очистим значение
			oCrocComboBox.Clear
			' Загрузим список (кодирование и анализ параметров делаются в X_Load*ComboBox)
			On Error Resume Next
			' перегрузим комбобокс
			.HasMoreRows = X_LoadActiveXComboBoxUseCache( .Cache, oCrocComboBox, .TypeName, .ListMetaname, sRestrictions, sUrlParams, .RequiredValues, .CacheSalt )
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
				Exit Sub
			End If
		End With
	End Sub
	
	
	'==========================================================================
	' Возвращает/устанавливает признак кэширования 
	' см. i:string-lookup/@use-cache
	Public Property Get UseCache
		UseCache = (m_bUseCache=True)
	End Property
	Public Property Let UseCache(vValue)
		m_bUseCache = (vValue=True)
	End Property

	
	'==========================================================================
	' Возвращает/устанавливает параметр кэширования
	' см. i:string-lookup/@cache-salt
	Public Property Get CacheSalt
		CacheSalt = m_sCacheSalt
	End Property
	Public Property Let CacheSalt(vValue)
		m_sCacheSalt = vValue
	End Property

	'==========================================================================
	' Возвращает регулярное выражение для проверки значения
	Public Property Get RegExpPattern
		RegExpPattern = "" & HtmlElement.getAttribute("RegExpPattern")
	End Property

	'==========================================================================
	' Возвращает сообщение о несоответствии значения рещулярному выражению
	Public Property Get RegExpPatternMismatchMessage
		RegExpPatternMismatchMessage = "" & HtmlElement.getAttribute("RegExpPatternMsg")
	End Property	
	

	'==========================================================================
	' Обработчик ActiveX-события onKeyUp (отжатия клавиши). Запускается отложенно по таймауту 
	' Внимание: для внутренного использования.
	Public Sub Internal_OnKeyUpAsync(ByVal nKeyCode, ByVal nFlags)
		Dim oEventArgs		' As AccelerationEventArgsClass

		If m_bKeyUpEventProcessing Then Exit Sub
		' проверим специфичные комбинации для текстовых полей
		If checkTextSpecificHotkeys(nKeyCode, CBool(nFlags and KF_ALTLTMASK), CBool(nFlags and KF_CTRLMASK), CBool(nFlags and KF_SHIFTMASK)) Then Exit Sub
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
'
'==============================================================================
Class XPEStringClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_bIsSmart
	Private m_nMinH						' Минимальная высота умного контрола в пикселях
	Private m_nMaxH						' Максимальная высота умного контрола в пикселях
	Private m_bKeyUpEventProcessing		' As Boolean - Признак обработки ActiveX-события OnKeyUp для предотвращения бесконечного цикла

	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Accel", "String"
		m_bIsSmart = Not IsNull(HtmlElement.GetAttribute("X_IS_SMART"))
		If Not m_bIsSmart  Then Exit Sub
		' Инициализируем "умные" TEXTAREA
		initSmartTextArea()
	End Sub

	
	'==========================================================================
	' IPropertyEdior: Метод вызывается при построении страницы редактора, после инициализации всех PE на странице
	Public Sub FillData()
		' Nothing to do...
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
	' Возвращает типизированное значение из input'a
	Public Property Get Value
		Value = HtmlElement.value
	End Property
	
	
	'==========================================================================
	' Устанавливает значение в контроле и в xml-свойстве
	Public Property Let Value(vValue)
		HtmlElement.value = vValue
		If m_bIsSmart Then Internal_SmartTextAreaOnAdjustSize
		With New GetDataArgsClass
			.SilentMode = True
			GetData .Self
		End With
	End Property

	
	'==========================================================================
	' Устанавливает значение в редакторе свойства
	Public Sub SetData
		HtmlElement.value = XmlProperty.nodeTypedValue
		If m_bIsSmart Then Internal_SmartTextAreaOnAdjustSize
	End Sub

	
	'==========================================================================
	' Сбор и валидация данных
	Public Sub GetData(oGetDataArgs)
		' Проверяем на NOT NULL: 
		If Not ValueCheckOnNullForPropertyEditor( Value, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then Exit Sub
		' Проверяем на максимальную длинну:
		If Not ValueCheckRangeForPropertyEditor(Value, m_oPropertyEditorBase, oGetDataArgs) Then Exit Sub
		' Проверим допустимые символы
		If Not CheckOnInvalidCharacters(Value, m_oPropertyEditorBase, oGetDataArgs) Then Exit Sub
		' Проверим регулярное выражение
		If Not CheckOnPatternMatch(Value, Me, oGetDataArgs) Then Exit Sub
		' Занесём значение в XML:
		GetDataFromPropertyEditor Value, m_oPropertyEditorBase, oGetDataArgs
	End Sub
	
	
	'==========================================================================
	' Устанавливает/возвращает (не)обязательность свойства
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			HtmlElement.removeAttribute "X_MAYBENULL"
			HtmlElement.className = "x-editor-control-notnull x-editor-string-field"
		Else
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
			HtmlElement.className = "x-editor-control x-editor-string-field"
		End If			
	End Property
	
	
	'==========================================================================
	' Устанавливает/возвращает (не)доступность редактора свойства
	Public Property Get Enabled
		 Enabled = Not HtmlElement.disabled
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.disabled = Not bEnabled
	End Property
	
	
	'==========================================================================
	' Установка фокуса
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function
	
	
	'==========================================================================
	' Возвращает Html контрол
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
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
	' IDisposable: подчистка ссылок
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
	End Sub	
	
	
	'==========================================================================
	' Инициализация "умного" поля ввода
	Private Sub initSmartTextArea()
		AdjustTextAreaWidth
		m_nMinH = SafeClng( HtmlElement.GetAttribute("X_MinH"))
		m_nMaxH = SafeClng( HtmlElement.GetAttribute("X_MaxH"))
	End Sub
	
	
	'==========================================================================
	' Корректирует ширину textarea в соответствии с шириной клиентской области редактора
	Public Sub AdjustTextAreaWidth()
		' #259092 При уменьшении ширины таблицы (при появлении скролбара в результате чмызгания)
		' clientWidth остаётся болше положенного так как заданная ранее ширина "распирает" ячейку
		' поэтому сначала сбросим ширину в 1px и вызовем DoEvents чтобы "прососалось"
		HtmlElement.Style.Width = "1px" '#259092
		XService.DoEvents				'#259092
		HtmlElement.Style.Width = HtmlElement.parentNode.clientWidth  & "px"
	End Sub
	
	
	'==========================================================================
	' Обработка изменения размера "Умных" элементов TextArea
	Sub Internal_SmartTextAreaOnAdjustSize()
		const DELTA	= 8	' небольшой "запас"	по высоте (в пикселях)
		
		Dim nAvailHeight	' доступная высота
		Dim nValue			' высота
		
		nValue = SafeClng(HtmlElement.scrollHeight) + SafeClng(HtmlElement.OffsetHeight) - SafeClng(HtmlElement.ClientHeight)
		nAvailHeight = SafeClng(ObjectEditor.HtmlPageContainer.clientHeight) - DELTA 
		
		If nValue < m_nMinH Then nValue = m_nMinH
		If nValue > m_nMaxH Then nValue = m_nMaxH
		
		If nValue > nAvailHeight Then nValue = nAvailHeight

		HtmlElement.style.Height =  nValue & "px"
	End Sub

	
	'==========================================================================
	' Возбуждает событие
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	

	
	'==========================================================================
	' Возвращает регулярное выражение для проверки значения
	Public Property Get RegExpPattern
		RegExpPattern = "" & HtmlElement.getAttribute("RegExpPattern")
	End Property

	'==========================================================================
	' Возвращает сообщение о несоответствии значения рещулярному выражению
	Public Property Get RegExpPatternMismatchMessage
		RegExpPatternMismatchMessage = "" & HtmlElement.getAttribute("RegExpPatternMsg")
	End Property	
	
	
	'==========================================================================
	' Обработчик Html-события OnKeyUp . Вызывается асинхронно по тайм-ауту.
	' Внимание: для внутренного использования.
	Public Sub Internal_OnKeyUpHtmlAsync(keyCode, altKey, ctrlKey, shiftKey)
		Dim oEventArgs		' As AccelerationEventArgsClass

		If m_bKeyUpEventProcessing Then Exit Sub
		' проверим специфичные комбинации для текстовых полей
		If checkTextSpecificHotkeys(keyCode, altKey, ctrlKey, shiftKey) Then Exit Sub
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


'==========================================================================
' Проверяет некоторые комбинации клавиш, которые в текстовых полях имеют локальное значение, 
' которое не стоит переопределять ни при каких обстоятельствах
Function checkTextSpecificHotkeys(keyCode, altKey, ctrlKey, shiftKey)
	checkTextSpecificHotkeys = False
	' клавиши Del и Backspace 
	If Not altKey And Not ctrlKey And Not shiftKey And (keyCode = VK_DEL OR keyCode = VK_BACK) Then 
		checkTextSpecificHotkeys = True
	' Ctrl + вправо и Ctrl + влево
	ElseIf ctrlKey And (keyCode = VK_LEFT Or keyCode = VK_RIGHT) Then
		checkTextSpecificHotkeys = True
	End If
End Function 

Const INVALID_XML_CHARS_PATTERN = "[^\x01-\xFF\u2116-\u2126\u0021-\u2044\u0401-\u04F9]"	' Шаблон регулярного выражения, используемый для поиска/замены недопустимых символов
Private g_oInvalidXmlCharsRegularExpressionStatic ' As RegExp
' Инстанцируем и настраиваем RegExp для поиска недопустимых символов
set g_oInvalidXmlCharsRegularExpressionStatic = new RegExp
g_oInvalidXmlCharsRegularExpressionStatic.Multiline = True
g_oInvalidXmlCharsRegularExpressionStatic.IgnoreCase = false
g_oInvalidXmlCharsRegularExpressionStatic.Global = true
g_oInvalidXmlCharsRegularExpressionStatic.Pattern = INVALID_XML_CHARS_PATTERN	

' Проверка на регулярное выражение
Function CheckOnPatternMatch(ByVal vValue, oPropertyEditor, oGetArgs)
	Dim sPattern
	Dim oRegEx
	CheckOnPatternMatch = True
	If 0=Len("" & vValue) Then
		Exit Function
	End If
	sPattern = "" & oPropertyEditor.RegExpPattern
	If 0=Len(sPattern) Then
		Exit Function
	End If
	
	Set oRegEx = New RegExp
	oRegEx.Pattern = sPattern
	
	If oRegEx.Test( vValue) Then
		Exit Function
	End If
		
	oGetArgs.ReturnValue = False
	oGetArgs.ErrorMessage = oPropertyEditor.RegExpPatternMismatchMessage
	CheckOnPatternMatch = False
End Function


' Проверка на допустимые Xml-символы
Function CheckOnInvalidCharacters(ByVal vValue, oPropertyEditorBase, oGetArgs)
	CheckOnInvalidCharacters = False
	' Проверим строку на вхождение недопустимых символов...
	If g_oInvalidXmlCharsRegularExpressionStatic.Test( vValue) Then
		' Ага, есть такие символы, спросим у пользователя: что с этим всем делать
		If Not oGetArgs.SilentMode Then
			If vbOK = MsgBox(  _
				"Текст реквизита """ & oPropertyEditorBase.PropertyDescription  & """ содержит недопустимые символы!" & vbNewLine & vbNewLine & _
				"Все недопустимые символы будут заменены пробелами." ,_ 
				vbOKCancel or vbDefaultButton1 or vbExclamation, "Внимание!") _
			Then
				' Подтвердили - заменим все пробелами
				vValue = g_oInvalidXmlCharsRegularExpressionStatic.Replace( vValue, " ")
				' Занесем исправленное значение обратно в HTML-элемент
				oPropertyEditorBase.HtmlElement.value = vValue
				CheckOnInvalidCharacters = True
			Else
				oGetArgs.ReturnValue = False
			End If
		Else
			oGetArgs.ReturnValue = False
		End If
	Else
		CheckOnInvalidCharacters = True
	End If
End Function
