'*******************************************************************************
' Подсистема:	
' Назначение:	Стандартный функционал обслуживания UI-представления числового 
'				скалярного свойства (для значений vt: ui1 i2 i4 r4 r8 fixed.14.4)
'*******************************************************************************

'==============================================================================
' События:
'	Accel (EventArg: AccelerationEventArgsClass)
'		- нажатие комбинации клавиш 
'	BeforeDeactivate (EventArg: EventArgsClass)
'		- потеря фокуса
Class XPENumberClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_sTypeCastFunc				' As String			- наименование
	Private m_sFormatFunc				' As String			- наименование
	Private m_sParseFunc				' As String			- наименование
	Private m_nDecimalPlaces			' As Long			- количество десятичных знаков после ,
	Private m_bIsInteger				' As Boolean		
	Private m_sPropType					' As String	- тип свойства
	Private m_bKeyUpEventProcessing		' As Boolean - Признак обработки ActiveX-события OnKeyUp для "разбухания" стэка
	
	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Accel,BeforeDeactivate", "Number"
		' в зависимости от типа свойства, установим наименование VBS-функции для приведения типа
		m_sPropType = oHtmlElement.GetAttribute("X_TYPE")
		m_sTypeCastFunc = X_GetVbsTypeCaseFunc(m_sPropType)
		m_bIsInteger = CBool(m_sPropType = "ui1" Or m_sPropType = "i2" Or m_sPropType = "i4")
		m_sFormatFunc = Trim("" & oHtmlElement.GetAttribute("X_FORMAT_FUNCTION"))
		m_sParseFunc =  Trim("" & oHtmlElement.GetAttribute("X_PARSE_FUNCTION"))
		m_nDecimalPlaces = Trim("" & oHtmlElement.GetAttribute("X_DECIMAL_PLACES"))		
		If 0<>Len(m_nDecimalPlaces) Then
			m_nDecimalPlaces = SafeCLng(m_nDecimalPlaces)
		Else
			m_nDecimalPlaces = Null	
		End If
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
	' Возвращает строковое значение из input'a
	Public Property Get Value
		Dim vValue
		vValue = Trim(HtmlElement.Value)
		If Len(vValue)>0 Then
			Value = vValue
		Else
			Value = Null
		End If
	End Property


	'==========================================================================
	' Устанавливает значение в контроле и в xml-свойстве
	Public Property Let Value(vValue)
		SetFieldValue vValue
		With New GetDataArgsClass
			.SilentMode = True
			GetData .Self
		End With
	End Property
	

	'==========================================================================
	' Устанавливает типизированное значение в контроле и в xml-свойстве
	Public Sub SetTypedValue(ByVal vValue)
		Value = ConvertTypedValueToStringRepresentation(vValue)
	End Sub
	
	'==========================================================================
	' Устанавливает типизированное значение в контроле
	Public Sub SetTypedFieldValue(ByVal vValue)
		SetFieldValue ConvertTypedValueToStringRepresentation(vValue)
	End Sub

	'==========================================================================
	' Устанавливает значение в редакторе свойства
	Public Sub SetData
		SetTypedFieldValue XmlProperty.nodeTypedValue
	End Sub


	'==========================================================================
	' Устанавливает значение в Html поле input
	Private Sub SetFieldValue(vValue)
		If hasValue(vValue) Then
			HtmlElement.value = vValue
		Else
			HtmlElement.value = vbNullString
		End If
	End Sub


	'==========================================================================
	' Сбор и валидация данных
	Public Sub GetData(oGetDataArgs)
		Dim vValue			' обрабатываемое значение
		Dim vTypedValue		' типизированное значение
		
		vValue = Value
		If Not ValueTypeCast(vValue, vTypedValue) Then 
			SetInvalidPropertyValueErrorInfo oGetDataArgs, PropertyDescription
			Exit Sub
		End If
		' Проверяем на NOT NULL: 
		If Not ValueCheckOnNullForPropertyEditor( vTypedValue, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then 
			Exit Sub
		End If
		If Not IsNull(vTypedValue) Then
			' Проверяем на вхождение в допустимых диапазон:
			If Not ValueCheckRangeForPropertyEditor(vTypedValue, m_oPropertyEditorBase, oGetDataArgs) Then 
				Exit Sub
			End If
		End If
		' Сбор данных
		GetDataFromPropertyEditor vTypedValue, m_oPropertyEditorBase, oGetDataArgs
	End Sub


	'==========================================================================
	' Запись описания ощибки "некорректного значения" в переданный зкземпляр GetDataArgsClass
	Private Sub SetInvalidPropertyValueErrorInfo( oGetDataArgs, sPropertyDescription  )
		With oGetDataArgs
			.ReturnValue = False
			.ErrorMessage = "Недопустимое значение реквизита """ & sPropertyDescription & """"
		End With
	End Sub

	
	'==========================================================================
	' Приводит значение к строке
	Public Function ConvertTypedValueToStringRepresentation(ByVal vValue)
		If 0<Len(m_sFormatFunc) Then
			Dim f: Set f = GetRef(m_sFormatFunc)
			vValue = f(vValue)	
		ElseIf (Not m_bIsInteger) and (Not IsNull(m_nDecimalPlaces)) and (Not IsNull(vValue)) Then
			vValue = Round(vValue,m_nDecimalPlaces)
			vValue = FormatNumber(vValue,m_nDecimalPlaces)
		End If
		ConvertTypedValueToStringRepresentation = "" & vValue
	End Function


	'==========================================================================
	' Функция "безопасного" приведения типа значения свойства
	' True при успешном конвертировании значения, иначе - False;
	'	[in] vValue - приводимое значение 
	'	[out] vTypedValue - возвращаемое типизированное значение
	Public Function ValueTypeCast( ByVal vValue, ByRef vTypedValue )
		Dim bDefaultProcessing: bDefaultProcessing = True
		ValueTypeCast = False
		If 0<Len(m_sParseFunc) Then
			bDefaultProcessing = False
			Dim f: Set f = GetRef(m_sParseFunc)
			On Error Resume Next
			vValue = f(vValue)	
			If 0 <> Err.Number Then
				Err.Clear
				Exit Function
			End If
		End If
		
		If HasValue(vValue) Then		
			If Not IsNumeric(vValue) Then
				Exit Function
			End If
			
			On Error Resume Next
			vTypedValue = Eval(m_sTypeCastFunc & "(vValue)")
			If 0 = Err.Number Then
				If bDefaultProcessing Then
					If m_bIsInteger Then
						' Проверим, что число не дробное 
						' (CDlb, CLng гарантировано не дадут переполнения)
						If CDbl(vValue) <> CLng(vValue) Then 
							Exit Function
						End If
					Else
						If m_sTypeCastFunc = "CCur" Then
							If Not IsCurrency(vValue) Then 
								Exit Function
							End If
						End If
						' Теперь по необходимости выполним округление
						If	Not IsNull(m_nDecimalPlaces) Then
							vTypedValue = Round(vTypedValue,m_nDecimalPlaces)
						End If
					End If					
				End If
				ValueTypeCast = True
			End If
			On Error GoTo 0
		Else
			ValueTypeCast = True
			vTypedValue = Null
		End If	
	End Function


	'==========================================================================
	' Устанавливает/возвращает (не)обязательность свойства
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			HtmlElement.removeAttribute "X_MAYBENULL"
			HtmlElement.className = "x-editor-control-notnull x-editor-numeric-field"
		Else
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
			HtmlElement.className = "x-editor-control x-editor-numeric-field"
		End If			
	End Property


	'==========================================================================
	' Устанавливает/возвращает (не)доступность редактора свойства
	Public Property Get Enabled
		Enabled = Not (HtmlElement.disabled)
	End Property
	Public Property Let Enabled(bEnabled)
		 HtmlElement.disabled = Not( bEnabled )
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
		Set m_oPropertyEditorBase = Nothing
	End Sub	
	
	
	'==========================================================================
	' Возбуждает событие
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
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

	'==========================================================================
	' Обработчик Html-события OnBeforeDeactivate.
	' Внимание: для внутренного использования.
	Public Sub Internal_OnBeforeDeactivate
		With New EventArgsClass
			FireEvent "BeforeDeactivate", .Self			
		End With
		' Перевыставим значение
		Dim v: v=Value
		If ValueTypeCast(v,v) Then
			SetTypedFieldValue v
		End If			
	End Sub
	
End Class
