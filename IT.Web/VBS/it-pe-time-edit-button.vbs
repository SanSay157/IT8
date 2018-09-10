Class PETimeEditButtonClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_bMandatory
	
	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Dim sPropType		' тип свойства
		
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Changed", "TimeEditButton"
		sPropType = m_oPropertyEditorBase.PropertyMD.getAttribute("vt")
		If Not CBool(sPropType = "ui1" Or sPropType = "i2" Or sPropType = "i4") Then
			Err.Raise -1, "", "PE может использоваться только для целых свойств (ui1, i2, i4)"
		End If
'		If IsNull(Value) Then Value = 0
		m_bMandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
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
	' Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property

	
	'==========================================================================
	' Возвращает типизированное значение из checkbox'a
	' Если он отмечен, возвращается 1, иначе 0
	Public Property Get Value
		Value = XmlProperty.nodeTypedValue
	End Property

	
	'==========================================================================
	' Устанавливает значение в контроле и в xml-свойстве
	Public Property Let Value(vValue)
		
		With New ChangeEventArgsClass
			.OldValue = XmlProperty.nodeTypedValue
			.NewValue = vValue
			' занесем значение в Html
			updateButtonTitle vValue
			ObjectEditor.SetPropertyValue XmlProperty, vValue
			FireEvent "Changed", .Self()
		End With
	End Property


	'==========================================================================
	' Устанавливает значение в редакторе свойства
	Public Sub SetData
		updateButtonTitle XmlProperty.nodeTypedValue 
	End Sub


	'==========================================================================
	' Устанавливает наименование кнопки
	Private Sub updateButtonTitle(ByVal vValue)
		If IsNull(vValue) Then vValue = 0
		HtmlElement.value = FormatTimeString(vValue)
	End Sub

	
	'==========================================================================
	' Сбор и валидация данных
	Public Sub GetData(oGetDataArgs)
		' Сбор данных происходит при изменении значения
		
		' Проверяем на NOT NULL: 
		If ValueCheckOnNullForPropertyEditor( Value, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then 
			' Проверяем на вхождение в допустимых диапазон:
			ValueCheckRangeForPropertyEditor Value, m_oPropertyEditorBase, oGetDataArgs
		End If
	End Sub

	
	'==========================================================================
	' Устанавливает/возвращает (не)обязательность свойства
	Public Property Get Mandatory
		Mandatory = m_bMandatory
	End Property
	Public Property Let Mandatory(bMandatory)
		m_bMandatory = bMandatory
	End Property

	
	'==========================================================================
	' Устанавливает/возвращает (не)доступность редактора свойства
	Public Property Get Enabled
		 Enabled = Not HtmlElement.disabled
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.disabled = Not( bEnabled )
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
	' IDisposable: подчистка ссылок
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
	End Sub	


	'==========================================================================
	' Обработчик Html-события OnClick на чекбоксе. Внимание: для внутренного использования.
	Public Sub Internal_OnClick()
		Dim vOldValue		' текущее значение 
		
		vOldValue = Value
		' откроем диалог с выбором дней, часов и минут
		' В диалог передаем массив из 3-х параметров: текущее значение, кол-во часов в дне и описание свойства
		vRet = X_ShowModalDialogEx( "p-TimeChange.aspx", _
			Array( vOldValue, GetHoursInDay(), m_oPropertyEditorBase.PropertyDescription), _
			"dialogWidth:400px;dialogHeight:200px;help:no;border:thin;center:yes;status:no")
		If Not HasValue(vRet) Then Exit Sub
		' занесем выбранное значение в xml-свойство
		ObjectEditor.SetPropertyValue XmlProperty, vRet
		' обновим представление
		updateButtonTitle vRet
		
		With New ChangeEventArgsClass
			.OldValue = vOldValue 
			.NewValue = CLng(vRet)
			FireEvent "Changed", .Self()
		End With
	End Sub
	
	
	'==========================================================================
	' Возбуждает событие
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Nothing, oEventArgs
	End Sub	
End Class