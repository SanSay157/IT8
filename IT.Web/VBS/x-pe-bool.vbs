'*******************************************************************************
' Подсистема:	
' Назначение:	Стандартный функционал обслуживания UI-представления скалярного 
'				логического свойства (vt="boolean")
'*******************************************************************************
' События:
'	Changed (EventArg: ChangeEventArgsClass)
'		- изменение состояния (Checked/Unchecked) 
'	Accel (EventArg: AccelerationEventArgsClass)
'		- нажатие комбинации клавиш 
Class XPEBoolClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	
	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Changed,Accel", "Bool"
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
	' Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property

	
	'==========================================================================
	' Возвращает типизированное значение из checkbox'a
	' Если он отмечен, возвращается 1, иначе 0
	Public Property Get Value
		Value = CBool(HtmlElement.checked)
	End Property

	
	'==========================================================================
	' Устанавливает значение в контроле и в xml-свойстве
	Public Property Let Value(vValue)
		With New ChangeEventArgsClass
			.OldValue = XmlProperty.nodeTypedValue
			.NewValue = vValue
			' занесем значение в Html
			SetChechBoxValue vValue
			' занесем значение в XML-свойство
			With New GetDataArgsClass
				.SilentMode = True
				GetData .Self
			End With
			FireEvent "Changed", .Self()
		End With
	End Property


	'==========================================================================
	' Устанавливает значение в редакторе свойства
	Public Sub SetData
		SetChechBoxValue XmlProperty.nodeTypedValue 
	End Sub


	'==========================================================================
	' Устанавливает значение в checkbox'e
	Private Sub SetChechBoxValue(vValue)
		If hasValue(vValue) Then
			HtmlElement.checked = vValue
		Else
			HtmlElement.checked = False
		End If
	End Sub

	
	'==========================================================================
	' Сбор и валидация данных
	Public Sub GetData(oGetDataArgs)
		' Занесём значение в XML:
		GetDataFromPropertyEditor Value, m_oPropertyEditorBase, oGetDataArgs
	End Sub

	
	'==========================================================================
	' Устанавливает/возвращает (не)обязательность свойства
	Public Property Get Mandatory
		Mandatory = True 
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory <> True Then _
			Err.Raise -1, "", "Свойство типа Boolean должно быть обязательным"
	End Property

	
	'==========================================================================
	' Устанавливает/возвращает (не)доступность редактора свойства
	Public Property Get Enabled
		 Enabled = Not HtmlElement.disabled
	End Property
	Public Property Let Enabled(bEnabled)
		Dim sClasses
		
		HtmlElement.disabled = Not( bEnabled )
		sClasses = " " & LabelElement.className & " "
		If bEnabled Then
			If InStr(sClasses, " x-editor-flags-disabled ") > 0 Then
				sClasses = Replace(sClasses, " x-editor-flags-disabled ", "")
			End If
		Else
			If InStr(sClasses, " x-editor-flags-disabled ") = 0 Then
				sClasses = sClasses & " x-editor-flags-disabled"
			End If
		End If
		LabelElement.className = sClasses
	End Property

	
	'==========================================================================
	' Установка фокуса
	Public Function SetFocus
		SetFocus = X_SafeFocus(HtmlElement)
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
	' Обработчик Html-события OnClick на чекбоксе. Внимание: для внутренного использования.
	Public Sub Internal_OnClick()
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

	'==========================================================================
	' Возбуждает событие
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	
	
	
	'==========================================================================
	' Возвращает Html-элемент LABEL для чекбокса
	Public Property Get LabelElement
		Set LabelElement = HtmlElement.parentElement.all(HtmlElement.ID & "Caption")
	End Property

		
	'==========================================================================
	' Возвращает текст LABEL'a для чекбокса
	Public Property Get LabelText
		LabelText = LabelElement.innerText
	End Property

		
	'==========================================================================
	' Устанавливает текст LABEL'a для чекбокса
	Public Property Let LabelText(sText)
		LabelElement.innerText = sText
	End Property
End Class
