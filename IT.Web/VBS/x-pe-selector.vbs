Option Explicit
'*******************************************************************************
' Подсистема:	
' Назначение:	Стандартный функционал обслуживания UI-представления числового 
'				скалярного свойства, допускающих выбор из набора значений
'				(для значений vt: ui1 i2 i4 boolean fixed.14.4 r4 r8 )
'*******************************************************************************

'==============================================================================
' Класс редактора свойства для представления скалярного необъектного свойства в виде комбобокс.
' Xslt: файл x-pe-selector.xsl, шаблон std-template-selector
' События:
' Changing - (EventArgs: ChangeEventArgsClass) генерируется перед после выбора значения, 
'			но перед изменением значения свойства. Если значение поля ReturnValue не True, то изменения св-ва не происходит.
' Changed (EventArgs: ChangeEventArgsClass) - генерируется после выбора значения и изменения значения свойства
Class XPESelectorComboClass
	Private m_oPropertyEditorBase	' As XPropertyEditorBaseClass
	Private m_bIsActiveX			' As Boolean - признак ActiveX-комбобокса
	Private m_vPrevValue			' As Variant - предыдущее значение комбобокса
	Private m_sTypeCastFunc			' As String	 - наименование
	Private m_bNoEmptyValue			' As Boolean - признак отсутствия пустого значения
	Private m_sDropdownText			' As String  - текст пустого значения
	Private m_bKeyUpEventProcessing		' As Boolean - Признак обработки ActiveX-события OnKeyUp для предотвращения бесконечного цикла
	
	'==========================================================================
	' IPropertyEditor: Инициализация
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Changing,Changed,Accel", "SelectorCombo"
		m_bIsActiveX = False
		If UCase(oHtmlElement.tagName) = "OBJECT" Then
			m_bIsActiveX = True
		End If
		' в зависимости от типа свойства, установим наименование VBS-функции для приведения типа
		m_sTypeCastFunc = X_GetVbsTypeCaseFunc(m_oPropertyEditorBase.PropertyMD.getAttribute("vt"))
		m_bNoEmptyValue = HtmlElement.getAttribute("NoEmptyValue") = "1"
		m_sDropdownText = HtmlElement.getAttribute("EmptyValueText")
		If m_bIsActiveX Then InitActiveXCombo
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
	' Инициализирует ActiveX комбобокс - переносит данные из стрытого select'а в контрол
	Private Sub InitActiveXCombo
		Dim oHiddenData			' Скрытый набор значений
		Dim oOption				' Опция
		Dim oSelectorRows		' Выбранные строки в селекторе
		
		Set oHiddenData = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.getAttribute("HiddenDataID") )
		Set oSelectorRows = HtmlElement.Rows
		For Each oOption In oHiddenData.options
			oSelectorRows.Add Array(oOption.innerText, oOption.value), CStr(Eval(m_sTypeCastFunc & "(Eval(oOption.value))"))
		Next
		' Обход глюка (похоже ShowEmptySelection не в PropertyBag), поэтому устанавливаем здесь, а не в xsl
		HtmlElement.ShowEmptySelection = Not m_bNoEmptyValue
	End Sub


	'==========================================================================
	' IPropertyEditor: Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property


	'==========================================================================
	' Возвращает типизированное значение из input'a
	Public Property Get Value
		Dim vValue
		If m_bIsActiveX Then
			vValue = HtmlElement.Rows.SelectedID
		Else
			vValue = HtmlElement.Value
		End If
		If Len(vValue)>0 Then
			If m_sTypeCastFunc = "CStr" Then
				' для строк никакого приведения типа не нужно
				Value = vValue
			Else
				Value = Eval( m_sTypeCastFunc & "(" & vValue & ")" )
			End If
		Else
			Value = Null
		End If
	End Property


	'==========================================================================
	' Устанавливает значение в контроле и в xml-свойстве
	Public Property Let Value(vValue)
		If GetDataFromPropertyEditor( vValue, m_oPropertyEditorBase, Null) Then
			SetData
		End If
	End Property


	'==========================================================================
	' IPropertyEditor: Устанавливает значение в редакторе свойства
	Public Sub SetData
		Dim vVal		' значение свойства
		vVal = XmlProperty.nodeTypedValue
		If SetComboBoxValue(vVal) > -1 Then
			m_vPrevValue = vVal
		End if
	End Sub


	'==========================================================================
	' IPropertyEditor: Сбор и валидация данных
	Public Sub GetData(oGetDataArgs)
		' Проверяем на NOT NULL: 
		If Not ValueCheckOnNullForPropertyEditor( Value, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then Exit Sub
	End Sub


	'==========================================================================
	' IPropertyEditor: Устанавливает/возвращает (не)обязательность свойства
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			HtmlElement.removeAttribute "X_MAYBENULL"
			HtmlElement.className = "x-editor-control-notnull x-editor-const-selector"
		Else
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
			HtmlElement.className = "x-editor-control x-editor-const-selector"
		End If			
	End Property


	'==========================================================================
	' IPropertyEditor: Устанавливает/возвращает (не)доступность редактора свойства
	Public Property Get Enabled
		If m_bIsActiveX Then
			 Enabled = HtmlElement.object.Enabled
		Else
			 Enabled = Not (HtmlElement.disabled)
		End If
	End Property
	Public Property Let Enabled(bEnabled)
		If m_bIsActiveX Then
			 HtmlElement.object.Enabled = bEnabled
		Else
			 HtmlElement.disabled = Not( bEnabled )
		End If
	End Property


	'==========================================================================
	' IPropertyEditor: Установка фокуса
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function


	'==========================================================================
	' IPropertyEditor: Возвращает Html контрол
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
		Set m_oPropertyEditorBase = Nothing
	End Sub	


	'==========================================================================
	' Добавляет элемент в выпадающий список
	'	[in] vVal - значение, соответствующее элементу
	'	[in] sLabel - текст элемента
	Public Sub AddComboBoxItem( vVal, sLabel)
		If m_bIsActiveX Then
			X_AddActiveXComboBoxItem HtmlElement, vVal, sLabel
		Else
			X_AddComboBoxItem HtmlElement, vVal, sLabel
		End If
	End Sub


	'==========================================================================
	' Очищает комбобокс и сбрасывает значение свойства в Null
	Public Sub Clear
		ClearComboBox
		Value = Null
	End Sub
	

	'==========================================================================
	' Очищает все значения комбобокса. Значение свойства при этом не меняется!
	' При необходимости добавляется пустое значение (возможно с текстом)
	Private Sub ClearComboBox
		If m_bIsActiveX Then
			HtmlElement.Clear
		Else
			' сначала очистим значение
			If m_bNoEmptyValue Then
				' пустого значения нет
				HtmlElement.innerHTML = ""
			Else
				' пустое значение должно быть
				HtmlElement.innerHTML = "<option>" & m_sDropdownText & "</option>"
			End If
		End If
	End Sub


	'==========================================================================
	' Устанавливает активный пункт с заданным значением
	'	[in]		vVal - значение, соответствующее элементу
	'   [retval]	индек пункта селектора или -1
	Private Function SetComboBoxValue(vVal)
		If m_bIsActiveX Then
			SetComboBoxValue = X_SetActiveXComboBoxValue( HtmlElement, vVal )
		Else
			SetComboBoxValue = X_SetComboBoxTypedValue( HtmlElement, vVal, m_sTypeCastFunc )
			If SetComboBoxValue = -1 And Not m_bNoEmptyValue Then
				' если не удалось найти значения и задан пустой элемент разрешен, установим его (он всегда идет первым)
				HtmlElement.SelectedIndex = 0
			End If
		End If
	End Function


	'==========================================================================
	' Обработчик Html события OnChange. Для внутренного использования!
	Public Sub Internal_OnChange
		Dim vValue		' выбранное значение комбобокса
		
		vValue = Value
		With New ChangeEventArgsClass
			.OldValue = m_vPrevValue
			.NewValue = vValue
			.ReturnValue = True
			FireEvent "Changing", .Self()
			If Not (.ReturnValue = True) Then
				' если в обработчике выставили флаг, то вернем предыдушее значение и прервем обработку
				SetComboBoxValue m_vPrevValue
				Exit Sub
			End If
			' занесем выбранное значение в xml-свойство
			GetDataFromPropertyEditor vValue, m_oPropertyEditorBase, Nothing
			' запомним текущее значение для следующего изменения
			m_vPrevValue = vValue
			FireEvent "Changed", .Self()
		End With
	End Sub


	'==========================================================================
	' Возбуждает событие
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
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



'==============================================================================
' Класс редактора свойства для представления скалярного необъектного свойства в виде радио-кнопок.
' Xslt: файл x-pe-selector.xsl, шаблон std-template-selector
Class XPESelectorRadioClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_bEnabled					' As Boolean - признак (не)доступности редактора свойства
	Private m_sTypeCastFunc				' As String - наименование VBS-функции для приведения типа
	
	'==========================================================================
	' IPropertyEditor: 
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Changed,Accel", "Selector"
		' в зависимости от типа свойства, установим наименование VBS-функции для приведения типа
		m_sTypeCastFunc = X_GetVbsTypeCaseFunc(m_oPropertyEditorBase.PropertyMD.getAttribute("vt"))
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
	' IPropertyEditor: Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property
	
	
	'==========================================================================
	' Возвращает типизированное значение из input'a
	' Если ничего не выбрано или выбрано пустое значение - возвращается Null
	Public Property Get Value
		Dim oHtmlRadioElement	' один HTML-элемент радио-кнопки переключателя
		Value = Null
		For Each oHtmlRadioElement In HtmlElement.all.tags("INPUT")
			If "RADIO" = UCase(oHtmlRadioElement.Type) Then
				If oHtmlRadioElement.Checked Then
					Value = oHtmlRadioElement.value
					If Len(Value)=0 Then Value = Null
					Exit For
				End If
			End If 
		Next
		If Not IsNull(Value) Then
			' для строк никакого приведения типа не нужно
			If m_sTypeCastFunc <> "CStr" Then
				Value = Eval( m_sTypeCastFunc & "(Eval(" & Value & "))" )
			End If
		End If
	End Property
	
	
	'==========================================================================
	' Устанавливает значение в контроле и в xml-свойстве
	Public Property Let Value(vValue)
		If GetDataFromPropertyEditor( vValue, m_oPropertyEditorBase, Null) Then
			SetData
		End If
	End Property


	'==========================================================================
	' IPropertyEditor: Устанавливает значение в редакторе свойства
	Public Sub SetData
		SetRadioValue XmlProperty.nodeTypedValue 
	End Sub


	'==========================================================================
	' Устанавливает значение в радио кнопках
	Private Sub SetRadioValue(ByVal vValue)
		Dim oHtmlRadioElement	' Html элемент input
		
		' Ищем соответствующее значение
		If hasValue(vValue) Then
			vValue = Eval( m_sTypeCastFunc & "(vValue)") ' На фсякий случай
		End If
		For Each oHtmlRadioElement In HtmlElement.All.Tags("input")
			If Len(oHtmlRadioElement.value) = 0 Then
				' пустое значение в input'e
				If Not hasValue(vValue) Then
					' если в vValue тоже пустое значение - значит равны
					oHtmlRadioElement.Checked = True
					Exit Sub
				Else
					oHtmlRadioElement.Checked = False
				End If
			ElseIf hasValue(vValue) Then
				If m_sTypeCastFunc = "CStr" Then
					If vValue = oHtmlRadioElement.value Then
						oHtmlRadioElement.Checked = True
					Else
						oHtmlRadioElement.Checked = False
					End If
				Else
					' непустое значение в input'e и в vValue - сравним типизированные значения
					If (Eval( m_sTypeCastFunc & "(Eval(oHtmlRadioElement.value))") = vValue) Then
						oHtmlRadioElement.Checked = True
						Exit Sub
					Else
						oHtmlRadioElement.Checked = False
					End If		
				End If		
			Else
				' непустое значение в input'e и пустое значение в vValue - точно не равны
				oHtmlRadioElement.Checked = False
			End If		
		Next
	End Sub
	
	
	'==========================================================================
	' IPropertyEditor: Сбор и валидация данных
	Public Sub GetData(oGetDataArgs)
		Dim vValue			' обрабатываемое значение
	
		vValue = Value
		' Проверяем на NOT NULL: 
		If Not ValueCheckOnNullForPropertyEditor( vValue, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then Exit Sub
		' Занесём значение в XML:
		GetDataFromPropertyEditor vValue, m_oPropertyEditorBase, oGetDataArgs
	End Sub
	
	
	'==========================================================================
	' IPropertyEditor: Устанавливает/возвращает (не)обязательность свойства
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
	' IPropertyEditor: Устанавливает/возвращает (не)доступность редактора свойства
	Public Property Get Enabled
		 Enabled = m_bEnabled
	End Property
	Public Property Let Enabled(bEnabled)
		Dim oRadioElement	' Html элемент input'a
		For Each oRadioElement In HtmlElement.all.tags("INPUT")
			oRadioElement.disabled = Not( bEnabled )
		Next
		m_bEnabled = bEnabled
	End Property
	
	
	'==========================================================================
	' IPropertyEditor: Установка фокуса
	Public Function SetFocus
		Dim oRadioElement	' Html элемент input'a
		
		SetFocus = False
		' Пробуем установить фокус на одну из радио-кнопок;
		' цикл повторяется до тех пор, пока фокус не будет установлен
		For Each oRadioElement In HtmlElement.all.tags("INPUT")
			If X_SafeFocus( oRadioElement ) Then
				SetFocus = True
				Exit For
			End If
		Next
	End Function
	
	
	'==========================================================================
	' IPropertyEditor: Возвращает Html контрол
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property


	'==========================================================================
	' IDisposable: подчистка ссылок
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
	End Sub	
	
	
	'==========================================================================
	' Возбуждает событие
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	


	'==========================================================================
	' Обработчик Html-события OnClick на radio-кнопке. Внимание: для внутренного использования.
	'	[in] sID - идентификатор выбранной radio-кнопки
	Public Sub Internal_OnClick(sID)
		Dim vValue		' текущее значение radio-кнопки
		vValue = Value
		With New ChangeEventArgsClass
			.OldValue = XmlProperty.nodeTypedValue
			.NewValue = vValue
			' занесем выбранное значение в xml-свойство
			GetDataFromPropertyEditor vValue, m_oPropertyEditorBase, Nothing
			FireEvent "Changed", .Self()
		End With
	End Sub
	
	
	'==========================================================================
	' Обработчик Html-события OnKeyUp на чекбоксе. Внимание: для внутренного использования.
	Public Sub Internal_OnKeyUp()
		Dim oEventArgs		' As AccelerationEventArgsClass
		
		If window.event Is Nothing Then Exit Sub
		window.event.cancelBubble = True
		Set oEventArgs = CreateAccelerationEventArgsForHtmlEvent()
		Set oEventArgs.Source = Me
		FireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' если нажатая комбинация не обработана - передадим ее в редактор
			ObjectEditor.OnKeyUp Me, oEventArgs
		End If
	End Sub
End Class
