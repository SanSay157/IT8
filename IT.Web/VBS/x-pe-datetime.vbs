Option Explicit
'*******************************************************************************
' Подсистема:	
' Назначение:	Стандартный функционал обслуживания UI-представления скалярного 
'				свойства даты-времени (vt="datetime")
'*******************************************************************************

' События:
'	Changed (EventArg: ChangeEventArgsClass)
'		- изменение состояния (Checked/Unchecked) 
'	Accel (EventArg: AccelerationEventArgsClass)
'		- нажатие комбинации клавиш 
Class XPEDateTimeClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_bKeyUpEventProcessing		' As Boolean - Признак обработки ActiveX-события OnKeyUp для "разбухания" стэка
	
	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing  = False
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Changed,Accel", "DateTime"
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
	' Возвращает типизированное значение из контрола даты
	Public Property Get Value
		Dim sDateType	' формат представления даты-времени (date, dateTime, time)
		Dim dtValue		' значение свойства - дата-вермя
		
		dtValue = HtmlElement.value
		' Получаем данные: значение, выбранное в date-time-picker, и тип значения
		' DS-свойства (date, dateTime или time):
		sDateType = HtmlElement.GetAttribute("X_DATETYPE")
		' Проверяем тип DS-свойства: если это "date" - срежем у значения "временную" часть:
		If "date"=sDateType And hasValue(dtValue) Then  dtValue = GetDateValue( CDate(dtValue) )
		Value = dtValue
	End Property

		
	'==========================================================================
	' Устанавливает значение в контроле и в xml-свойстве
	Public Property Let Value(vValue)
		HtmlElement.value = vValue
		With New GetDataArgsClass
			.SilentMode = True
			GetData .Self
		End With
	End Property

		
	'==========================================================================
	' Устанавливает значение в редакторе свойства
	Public Sub SetData
		HtmlElement.value = XmlProperty.nodeTypedValue 
	End Sub
	

	'==========================================================================
	' Сбор и валидация данных
	Public Sub GetData(oGetDataArgs)
	    Dim vValue
	    vValue = Value
		' Проверяем на NOT NULL: 
		If ValueCheckOnNullForPropertyEditor( vValue, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then 
			' Занесём значение в XML:
			GetDataFromPropertyEditor vValue, m_oPropertyEditorBase, oGetDataArgs
		End If
	End Sub
	

	'==========================================================================
	' Устанавливает/возвращает (не)обязательность свойства
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			HtmlElement.removeAttribute "X_MAYBENULL"
			HtmlElement.className = "x-editor-control-notnull x-editor-datetime-field"
		Else
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
			HtmlElement.className = "x-editor-control x-editor-datetime-field"
		End If			
	End Property
	

	'==========================================================================
	' Устанавливает/возвращает (не)доступность редактора свойства
	Public Property Get Enabled
		 Enabled = HtmlElement.object.Enabled
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.object.Enabled = bEnabled
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
	' Возбуждает событие
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	


	'==========================================================================
	' Обработчик Html события OnDateTimeChange от контрола. Запускается отложенно по таймауту
	' Внимание: для внутренного использования.
	Public Sub Internal_OnChangeAsync()
		With New GetDataArgsClass
			.SilentMode = True
			GetData .Self()
		End With
		FireEvent "Changed", New EventArgsClass
	End Sub


	'==========================================================================
	' Обработчик ActiveX-события onKeyUp (отжатия клавиши). Запускается отложенно по таймауту 
	' Внимание: для внутренного использования.
	Public Sub Internal_OnKeyUpAsync(nKeyCode, nFlags)
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
