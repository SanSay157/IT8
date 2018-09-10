Option Explicit
'*******************************************************************************
' Подсистема:	
' Назначение:	Стандартный функционал обслуживания UI-представления скалярного 
'				свойства маски флагов (i:bits)
'*******************************************************************************

' События:
'	Changed (EventArg: ChangeEventArgsClass)
'		- изменение состояния (Checked/Unchecked) 
'	Accel (EventArg: AccelerationEventArgsClass)
'		- нажатие комбинации клавиш 
Class XPEFlagsClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_bEnabled					' As Boolean
	
	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Changed,Accel", "Flags"
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
	' Возвращает типизированное значение из PE
	Public Property Get Value
		Dim nFlagsValue		' суммарное значение битовых флагов
		Dim oBitFlagElement	' один HTML-элемент; флажок, соотв. битовому флагу
		
		' Значение реквизита, отображаемого битовыми флагами, в том случае если 
		' ни один флаг не установлен, считается нулевым (вследствии этого значение
		' свойства всегда не-NULL-овое):
		nFlagsValue = 0
		' Перебираем все check-box-ы флагов, проверяя те, для которых установлены 
		' флажки
		For Each oBitFlagElement In HtmlElement.all.tags("INPUT")
			If oBitFlagElement.checked Then
				' Суммируем значение флага; само значение получаем через Eval, т.к. оно 
				' может быть прописано в метаданных как именованная константа:
				'		<i:bit n="Флаг">MY_COOL_FLAG</i:bit>
				' где MY_COOL_FLAG объявлен где-то в клиентском VBS, а потом из метаданных 
				' это же значение переносится в атрибут ExpBitValue
				nFlagsValue = CLng(nFlagsValue) Or CLng( Eval( oBitFlagElement.ExpBitValue ) )
			End If
		Next
		Value = nFlagsValue 
	End Property
	

	'==========================================================================
	' Устанавливает значение в контроле и в xml-свойстве
	Public Property Let Value(vValue)
		SetFlags vValue
		With New GetDataArgsClass
			.SilentMode = True
			GetData .Self
		End With
	End Property

	
	'==========================================================================
	' Устанавливает значение в комбобоксе
	Public Sub SetData
		SetFlags XmlProperty.nodeTypedValue
	End Sub

	
	'==========================================================================
	Private Sub SetFlags(vValue)
		Dim oBitFlagElement	' один HTML-элемент; флажок, соотв. битовому флагу
		
		If Not HasValue(vValue) Then 
			vValue = CLng(0)
		Else
			vValue = CLng(vValue)
		End If		
		' заносим битики...
		For Each oBitFlagElement In HtmlElement.all.tags("INPUT")
			oBitFlagElement.Checked = (CLng(Eval(oBitFlagElement.ExpBitValue)) and vValue)
		Next
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
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			HtmlElement.removeAttribute "X_MAYBENULL"
		Else
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
		End If			
	End Property

	
	'==========================================================================
	' Устанавливает/возвращает (не)доступность редактора свойства
	Public Property Get Enabled
		 Enabled = m_bEnabled
	End Property
	Public Property Let Enabled(bEnabled)
		m_bEnabled = bEnabled
		Dim oBitFlagElement		' HTML-элемент одного checkbox'a
		Dim oLabelElement		' HTML-элемент соовтетствующего label'a 
		Dim sClasses
		
		' Установка / снятие блокировки для всех флажков битов
		For Each oBitFlagElement In HtmlElement.all.tags("INPUT")
			oBitFlagElement.disabled = Not( bEnabled )
			
			Set oLabelElement = HtmlElement.all( oBitFlagElement.ID & "Label")
			sClasses = " " & oLabelElement.className & " "
			If bEnabled Then
				If InStr(sClasses, " x-editor-flags-disabled ") > 0 Then
					sClasses = Replace(sClasses, " x-editor-flags-disabled ", "")
				End If
			Else
				If InStr(sClasses, " x-editor-flags-disabled ") = 0 Then
					sClasses = sClasses & " x-editor-flags-disabled"
				End If
			End If
			oLabelElement.className = sClasses
		Next
	End Property

	
	'==========================================================================
	' Установка фокуса
	Public Function SetFocus
		Dim oBitFlagElement	' HTML-элемент одного флажка 
		
		' Изначально считаем, что фокус не установлен
		SetFocus= False
		
		' Пробуем установить фокус на один из флажков битов;
		' цикл повторяется до тех пор, пока фокус не будет установлен
		For Each oBitFlagElement In HtmlElement.all.tags("INPUT")
			If X_SafeFocus( oBitFlagElement ) Then
				SetFocus = True
				Exit For
			End If
		Next
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
	' Если бит = 0, то флаг прячется, если 1, то показывается
	Public Sub ShowFlagsByMask(nMask)
		Dim oBitFlagElement	' HTML-элемент одного флажка 
		nMask = CLng(nMask)
		For Each oBitFlagElement In HtmlElement.all.tags("INPUT")
			If (CLng(Eval(oBitFlagElement.ExpBitValue)) And nMask) Then
				oBitFlagElement.parentNode.style.display = "block"
			Else
				oBitFlagElement.parentNode.style.display = "none"
			End If
		Next
	End Sub

	
	'==========================================================================
	' Обработчик html-события OnClick на checkbox'е. Внимание: для внутреннего использования!
	'	[in] sID - идентификатор checkbox'a
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
	
	
	'==========================================================================
	' Возбуждает событие
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub
End Class
