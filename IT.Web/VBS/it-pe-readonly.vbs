Option Explicit

'==============================================================================
' PE для отображения значения свойства в виде r4ead-only поля. 
' Поддерживается произвольные виды свойств. Отображение осуществляется с помощью VBS-выражения, переданного параметром в XSLT-шаблон.
' Для объектных свойств выражение указывается относительно объекта-значения (аналогично object-presentation), 
' для необъектных свойств выражение указывается относительно объекта-владельца свойства
Class PEReadOnlyClass
	Private m_oEditorPage			' As EditorPageClass
	Private m_oObjectEditor			' As ObjectEditorClass
	Private m_oHtmlElement			' As IHtmlElement	- ссылка на главный Html-элемент
	Private m_oPropertyMD			' As XMLDOMElement	- метаданные xml-свойства
	Private m_sXmlPropertyXPath		' As String - XPAth - Запрос для получения свойства в Pool'e
	Private m_sObjectType			' As String - Наименование типа объекта владельца свойства
	Private m_sObjectID				' As String - Идентификатор объекта владельца свойства
	Private m_sPropertyName			' As String - Наименование свойства
	Private m_sExpression			' As String	- VBS-выражение
	Private m_bAutoCaptionToolTip	' As Boolean - признак автоматического изменения тултипа текстового поля
	Private m_bIsObject				' As Boolean - признак объектного свойства
	
	'==========================================================================
	' Возвращает экземпляр ObjectEditorClass - редактора,
	' в рамках которого работает данный редактор свойства
	Public Property Get ObjectEditor
		Set ObjectEditor = m_oObjectEditor
	End Property


	'==========================================================================
	' Возвращает экземпляр EditorPageClass - страницы редактора,
	' на которой размещается данный редактор свойства
	Public Property Get ParentPage
		Set ParentPage = m_oEditorPage
	End Property


	'==========================================================================
	' Инициализация редактора свойства.
	' см. IPropertyEditor::Init
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Set m_oEditorPage	= oEditorPage
		Set m_oObjectEditor = m_oEditorPage.ObjectEditor
		Set m_oHtmlElement	= oHtmlElement
		m_sObjectType		= oXmlProperty.parentNode.tagName
		m_sObjectID			= oXmlProperty.parentNode.getAttribute("oid")
		m_sPropertyName		= oXmlProperty.tagName
		m_sXmlPropertyXPath	= m_sObjectType & "[@oid='" & m_sObjectID & "']/" & m_sPropertyName
		Set m_oPropertyMD	= m_oObjectEditor.PropMD(oXmlProperty)
		Set m_oHtmlElement  = oHtmlElement
		m_bIsObject = CBool(m_oPropertyMD.getAttribute("vt") = "object")
		m_sExpression = HtmlElement.GetAttribute("ValueExpression")
		If Not hasValue(m_sExpression) Then
			If m_bIsObject Then
				m_sExpression = "item.ObjectID"
			Else
				m_sExpression = "item." & m_sPropertyName
			End If
		End If
		m_bAutoCaptionToolTip = CBool(HtmlElement.GetAttribute("AutoToolTip") = "1")
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: Метод вызывается при построении страницы редактора, после 
	'	инициализации всех PE на странице
	Public Sub FillData()
	End Sub

	
	'==========================================================================
	' Возвращает Xml-свойство
	' Подробнее см. IPropertyEditor::XmlProperty
	Public Property Get XmlProperty
		Set XmlProperty = m_oObjectEditor.XmlObjectPool.selectSingleNode( m_sXmlPropertyXPath )
		If XmlProperty Is Nothing Then
			Set XmlProperty = m_oObjectEditor.Pool.GetXmlObject(m_sObjectType, m_sObjectID, Null).SelectSingleNode(m_sPropertyName)
		End If
		If XmlProperty Is Nothing Then _
			Err.Raise -1, "XPropertyEditorBaseClass::XmlProperty", "Не найдено свойство " & PropertyName & " в xml-объекте"
		If Not IsNull(XmlProperty.getAttribute("loaded")) Then
			Set XmlProperty = m_oObjectEditor.LoadXmlProperty( Nothing, XmlProperty)
		End If		
	End Property

	
	'==========================================================================
	' Устанавливает значение в комбобоксе
	' см. IPropertyEditor::SetData	
	Public Sub SetData
		SetDataEx XmlProperty
	End Sub
	
	'==========================================================================
	' Устанавливает значения. Используется для оптимизации, 
	'	т.к. не получает XmlProperty стандартным механизмом
	' Метод устанавливает строку представления объекта в соответствии со
	'	значением объектного свойства в пуле 
	'	[in] oXmlProperty As IXMLDOMElement - закешированная ссылка на текущее xml-свойство
	Private Sub SetDataEx(oXmlProperty)
		Dim oXmlItem		' As XMLDOMELement - объект-значение свойства
		Dim sCaption		' As String - текстовое представление объекта

		If m_bIsObject Then			
			Set oXmlItem = oXmlProperty.firstChild
		Else
			Set oXmlItem = oXmlProperty.parentNode
		End If

		' Расчитаем строку с текстом представления значения свойства
		If Not(Nothing Is oXmlItem) Then
			' расчет самой строки - выполняется VBS-выражение
			sCaption = vbNullString & ObjectEditor.ExecuteStatement( oXmlItem, m_sExpression )
		End if

		' Отображение текста представления в UI:
		SetText sCaption
	End Sub
	
	
	'==========================================================================
	' Сбор и проверка данных
	' Подробнее см. IPropertyEditor::GetDataArgsClass
	Public Sub GetData(oGetDataArgs)
		' Nothing to do
	End Sub
	
	'==========================================================================
	' Возвращает признак (не)обязательности свойства
	' Подробнее см. IPropertyEditor::Mandatory
	Public Property Get Mandatory
		Mandatory = False
	End Property
	
	'==========================================================================
	' Установка (не)обязательности
	' Подробнее см. IPropertyEditor::Mandatory
	Public Property Let Mandatory(bMandatory)
	End Property
	
	'==========================================================================
	' Получение (не)доступности
	' Подробнее см. IPropertyEditor::Enabled
	Public Property Get Enabled
		 Enabled = Not (HtmlElement.disabled)
	End Property

	'==========================================================================
	' Установка (не)доступности
	' Подробнее см. IPropertyEditor::Enabled
	Public Property Let Enabled(bEnabled)
		' задизейблим/раздизейблим кнопку
		HtmlElement.disabled = Not( bEnabled )
	End Property
	
	
	'==========================================================================
	' Установка фокуса
	' Подробнее см. IPropertyEditor::SetFocus
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function
	
	
	'==========================================================================
	' Получение основного HTML-элемента редактора свойства
	' Подробнее см. IPropertyEditor::HtmlElement
	Public Property Get HtmlElement
		Set HtmlElement = m_oHtmlElement
	End Property
	
	'==========================================================================
	' Разрыв связей с другими объектами
	' Подробнее см. IDisposable::Dispose
	Public Sub Dispose
	End Sub
	
	
	'==========================================================================
	' Возвращает значение свойства
	Public Property Get Value
		Set oXmlProperty = XmlProperty
		If m_bIsObject Then
			If oXmlProperty.firstChild Is Nothing Then
				Set Value = Nothing
			Else	
				' Загружен объект-значение
				Set Value = m_oObjectEditor.Pool.GetXmlObjectByXmlElement( oXmlProperty.firstChild, Null )
			End If
		Else
			Value = oXmlProperty.nodeTypedValue
		End If
	End Property

	'==========================================================================
	' Устанавливает значение в контроле и в xml-свойстве
	Public Property Let Value(vValue)
		Dim oXmlProperty		' As IXMLDOMElement - текущее свойство
		
		Set oXmlProperty = XmlProperty
		If m_bIsObject Then
			' очисти значние свойства
			If Not oXmlProperty.firstChild Is Nothing Then
				' если св-во непустое - очистим его
				m_oObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
			End If
			' установим значение свойства
			If Not IsNothing(vValue) Then
				m_oObjectEditor.Pool.AddRelation Nothing, oXmlProperty, vValue
			End If
		Else
			m_oObjectEditor.Pool.SetPropertyValue oXmlProperty, vValue
		End If
		SetDataEx oXmlProperty
	End Property
	
	
	'==========================================================================
	' Устанавливает содержимое текстовой строки описывающей представление свойства
	Private Sub SetText(sText)
		HtmlElement.Value = sText
		If m_bAutoCaptionToolTip Then
			ToolTip = sText
		End If
	End Sub
	
	'==========================================================================
	' Устанавливает/Возвращает Vbs-выражение для вычисления представления свойства
	' подробнее см. i:object-presentation
	Public Property Get Expression
		Expression = m_sExpression
	End Property 
	Public Property Let Expression(value)
		m_sExpression = value
		SetData
	End Property 
	
	'==========================================================================
	' Устанавливает/Возвращает тултип для текстового поля, в котором отображается строка описывающая объект
	Public Property Let ToolTip(sValue)
		HtmlElement.Title = sValue
	End Property
	Public Property Get ToolTip
		ToolTip = HtmlElement.Title
	End Property
End Class