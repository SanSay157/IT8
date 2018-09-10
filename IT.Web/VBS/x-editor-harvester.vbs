'===============================================================================
'@@!!FILE_x-editor-harvester
'<GROUP !!SYMREF_VBS>
'<TITLE x-editor-harvester - Обслуживание процессов взаимодействи редактора и редакторов свойств>
':Назначение:
'	Обслуживание процессов взаимодействи редактора и редакторов свойств.
'===============================================================================
'@@!!CLASSES_x-editor-harvester
'<GROUP !!FILE_x-editor-harvester><TITLE Классы>
Option Explicit

' "Базовый" класс для необъектных редакторов свойств
Class XPropertyEditorBaseClass
	Public EditorPage				' As EditorPageClass
	Public ObjectEditor				' As ObjectEditorClass
	Public HtmlElement				' As IHtmlElement	- ссылка на главный Html-элемент
	Public PropertyMD				' As XMLDOMElement	- метаданные xml-свойства
	Public EventEngine				' As EventEngineClass
	Public EVENTS					' список событий
	Public XmlPropertyXPath			' XPath - Запрос для получения свойства в Pool'e
	Public ObjectType				' Наименование типа объекта владельца свойства
	Public ObjectID					' Идентификатор объекта владельца свойства
	Public PropertyName				' Наименование свойства
	Public PropertyDescription		' Описание свойства
	
	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		Set EventEngine = X_CreateEventEngine
	End Sub

	'--------------------------------------------------------------------------
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement, sEvents, sPEShortName)
		EVENTS = sEvents
		Set EditorPage		= oEditorPage
		Set ObjectEditor	= EditorPage.ObjectEditor
		ObjectType			= oXmlProperty.parentNode.tagName
		ObjectID			= oXmlProperty.parentNode.getAttribute("oid")
		PropertyName		= oXmlProperty.tagName
		XmlPropertyXPath	= ObjectType & "[@oid='" & ObjectID & "']/" & PropertyName
		Set PropertyMD		= ObjectEditor.PropMD(oXmlProperty)
		Set HtmlElement		= oHtmlElement
		' статический биндинг
		If Len("" & sEvents) > 0 Then
			EventEngine.InitHandlers EVENTS, "usr_" & ObjectType & "_" & PropertyName & "_" & sPEShortName & "_On"
			EventEngine.InitHandlers EVENTS, "usr_" & ObjectType & "_" & PropertyName & "_On"
			EventEngine.InitHandlers EVENTS, "usr_" & PropertyName & "_" & sPEShortName & "_On"
			EventEngine.InitHandlers EVENTS, "usr_" & sPEShortName & "_On"
		End If
		PropertyDescription = HtmlElement.GetAttribute("X_DESCR")
	End Sub


	'--------------------------------------------------------------------------
	' Возвращает Xml-свойство
	' [in] bLoad - признак необходимости прогрузить свойство
	Public Function GetXmlProperty(bLoad)
		Set GetXmlProperty = ObjectEditor.XmlObjectPool.selectSingleNode( XmlPropertyXPath )
		If GetXmlProperty Is Nothing Then
			Set GetXmlProperty = ObjectEditor.Pool.GetXmlObject(ObjectType, ObjectID, Null).SelectSingleNode(PropertyName)
		End If
		If GetXmlProperty Is Nothing Then _
			Err.Raise -1, "XPropertyEditorBaseClass::XmlProperty", "Не найдено свойство " & PropertyName & " в xml-объекте"
		If bLoad Then	
			If Not IsNull(GetXmlProperty.getAttribute("loaded")) Then
				Set GetXmlProperty = ObjectEditor.LoadXmlProperty( Nothing, GetXmlProperty)
			End If
		End If	
	End Function


	'--------------------------------------------------------------------------
	' Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = GetXmlProperty(true)
	End Property


	'-------------------------------------------------------------------------------
	' Помечает свойство как модифицированное
	Public Sub SetDirty
		ObjectEditor.SetXmlPropertyDirty XmlProperty
	End Sub
	
	
	'-------------------------------------------------------------------------------
	' Возвращает минимальное/максимальное значение свойства
	Public Sub GetRange(ByRef vMin, ByRef vMax)
		vMin = HtmlElement.GetAttribute("X_MIN")
		vMax = HtmlElement.GetAttribute("X_MAX")
		If HasValue(vMin) Then
			With XmlProperty.OwnerDocument.CreateElement("X")
				.dataType=XmlProperty.dataType
				if .dataType="string" Then .dataType="i4" 
				.text = vMin
				vMin = .nodeTypedValue
			End With
		Else
			vMin = X_GetChildValueDef( PropertyMD, "ds:min", Null )
		End If	
		If HasValue(vMax) Then
			With XmlProperty.OwnerDocument.CreateElement("X")
				.dataType=XmlProperty.dataType
				if .dataType="string" Then .dataType="i4" 
				.text = vMax
				vMax = .nodeTypedValue
			End With		
		Else
			vMax = X_GetChildValueDef( PropertyMD, "ds:max", Null )
		End If	
	End Sub
End Class


'-------------------------------------------------------------------------------
' Назначение:	Функция проверки значения NOT-NULL-свойства, заданного в 
'				редакторе свойства, на NULL
' Результат:    True - если значение не NULL, если значение NULL и свойство 
'				допускает задание NULL-значений; иначе - False
' Параметры:	[in] oPropertyEditor - экземпляр IPropertyEditor, редактор свойства
'				[in] oGetDataArgs As GetDataArgsClass - 
' Примечание:	При ошибочном значение исключение НЕ ГЕНЕРИРУЕТСЯ, описание 
'				ошибки записывается в переданный экземпляр oGetDataArgs
Function ValueCheckOnNullForPropertyEditor( vValue, oPropertyEditorBase, oGetDataArgs, bMandatory)
	' Изначально считаем что значение некорректно:
	ValueCheckOnNullForPropertyEditor = False
	' Заданное значение считается априори корректным:
	If hasValue(vValue) Then 
		ValueCheckOnNullForPropertyEditor = True
	' Заданное значение есть NULL: 
	Else
		' Проверим возможность задания NULL-значения для свойства
		If bMandatory Then
			oGetDataArgs.ErrorMessage = "Значение реквизита """ & oPropertyEditorBase.PropertyDescription & """ должно быть задано"
			oGetDataArgs.ReturnValue = False
		Else
			ValueCheckOnNullForPropertyEditor = True
		End If
	End If
End Function


'-------------------------------------------------------------------------------
' Назначение:	Функция проверки попадания значения свойства, заданного в 
'				редакторе свойства, в корректный диапазон знавений (определяемый
'				метаданными)
' Результат:    True в случае если значение корректно, иначе - False
' Параметры:	[in] vValue	- проверяемое значение свойства
'				[in] oIPropertyEditorBase - экземпляр PropertyEditorBaseClass, данные 
'				редактора свойства
'				[in] oGetDataArgs As GetDataArgsClass
' Примечание:	При ошибочном значение исключение НЕ ГЕНЕРИРУЕТСЯ, описание 
'				ошибки записывается в переданный экземпляр GetDataArgsClass
' Зависимости:	
Function ValueCheckRangeForPropertyEditor( vValue, oPropertyEditorBase, oGetDataArgs)
	Dim vLowerRangeBound	' значение нижней границы диапазона значений, ds:min
	Dim vUpperRangeBound	' значение верхней границы диапазона значений, ds:max
	
	' Незаданное значение считается априори корректным:
	If Not hasValue(vValue) Then 
		ValueCheckRangeForPropertyEditor = True
		Exit Function
	End If
	' Для всех остальных случаев изначально считаем что значение некорректно
	ValueCheckRangeForPropertyEditor = False
	
	With oPropertyEditorBase
		.GetRange vLowerRangeBound, vUpperRangeBound
		
		' Свойство - строка: проверяем на длину строки
		If vbString = VarType(vValue) Then
			If Not IsNull(vLowerRangeBound) Then
				If vLowerRangeBound > Len(vValue) Then
					oGetDataArgs.ReturnValue = False
					oGetDataArgs.ErrorMessage = _
						"Длина текста реквизита """ & .PropertyDescription & """ меньше минимально допустимой" & vbNewLine & _
						vbNewLine & _
						"Длина заданного текста: " & Len(vValue) & vbNewLine & _
						"Минимально допустимая длина: " & vLowerRangeBound
					Exit Function					
				End If
			End If
			If Not IsNull(vUpperRangeBound) Then
				If vUpperRangeBound < Len(vValue) Then
					oGetDataArgs.ReturnValue = False
					oGetDataArgs.ErrorMessage =	_
						"Длина текста реквизита """ & .PropertyDescription & """ больше максимально допустимой" & vbNewLine & _
						vbNewLine & _
						"Длина заданного текста: " & Len( vValue) & vbNewLine & _
						"Максимально допустимая длина: " & vUpperRangeBound
					Exit Function					
				End If
			End If
			
		' Свойство - НЕ строка: проверяем на диапазон значений, при приведении свойства в число
		Else
			If Not IsNull(vLowerRangeBound) Then
				If vLowerRangeBound > vValue Then
					oGetDataArgs.ReturnValue = False
					oGetDataArgs.ErrorMessage = _
						"Значение реквизита """ & .PropertyDescription & """ меньше минимального возможного значения" & vbNewLine & _
						vbNewLine & _
						"Заданное значение: " & vValue & vbNewLine & _
						"Минимально допустимое значение: " & vLowerRangeBound
					Exit Function
				End If
			End If
			If Not IsNull(vUpperRangeBound) Then
				If vUpperRangeBound < vValue Then
					oGetDataArgs.ReturnValue = False
					oGetDataArgs.ErrorMessage = _
						"Значение реквизита """ & .PropertyDescription & """ больше максимального возможного значения" & vbNewLine & _
						vbNewLine & _
						"Заданное значение: " & vValue & vbNewLine & _
						"Максимально допустимое значение: " & vUpperRangeBound
					Exit Function					
				End If
			End If
		End If
		
	End With	
	
	' Все проверки прошли: считаем значение корректным
	ValueCheckRangeForPropertyEditor = True
End Function 


'-------------------------------------------------------------------------------
' Назначение:	Фукнция записи данных свойства, заданных в редакторе свойства, 
'				в XML-данные объекта-владельца.
' Результат:    True в случае успешной записи данных в XML, иначе - False
'				В случае ошибки описание ошибки записывается в oGetDataArgs
'	[in] vValue - значение
'	[in] oPEArgsObject As PropertyEditorBaseClass - редактор свойства
'	[in] oGetDataArgs As GetDataArgsClass - может быть не задан
' Примечание:	(1) Фунция устанавливает служебный атрибут "dirty" в XML-данных
'				объекта-владельца, сравнивая исходное значение свойства со значением, 
'				заданным в редакторе;
'				(2) При ошибочной записи исключение НЕ ГЕНЕРИРУЕТСЯ, описание 
'				ошибки записывается в переданный экземпляр oGetDataArgs
Function GetDataFromPropertyEditor( vValue, oPropertyEditorBase, oGetDataArgs )
	GetDataFromPropertyEditor = True
		
	With oPropertyEditorBase
		On Error Resume Next
		oPropertyEditorBase.ObjectEditor.SetPropertyValue .XmlProperty, vValue
		If Err Then
			GetDataFromPropertyEditor = False
			If Not IsNothing(oGetDataArgs) Then
				oGetDataArgs.ReturnValue = False
				oGetDataArgs.ErrorMessage = "Ошибка при занесении реквизита """ & .PropertyDescription & """ в XML"	
			End If
			Err.Clear
		End If
	End With
End Function


'===============================================================================
'@@ChangeEventArgsClass
'<GROUP !!CLASSES_x-editor-harvester><TITLE ChangeEventArgsClass>
':Назначение:	
'	Параметры событий "Changing", "Changed" (см. перечень типов редакторов в примечании).
':Описание:
'	Экземпляр класса используется для передачи параметров событий в следующих 
'	редакторах свойств (property editors, XPE):
'	* XPESelectorRadioClass - для события "Changed";
'	* XPESelectorComboClass - для событий "Changing" и "Changed";
'	* XPEObjectDropdownClass - для событий "Changing" и "Changed".
'
'@@!!MEMBERTYPE_Methods_ChangeEventArgsClass
'<GROUP ChangeEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_ChangeEventArgsClass
'<GROUP ChangeEventArgsClass><TITLE Свойства>
Class ChangeEventArgsClass
	'@@ChangeEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_ChangeEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@ChangeEventArgsClass.OldValue
	'<GROUP !!MEMBERTYPE_Properties_ChangeEventArgsClass><TITLE OldValue>
	':Назначение:	"Старое" значение, до изменения.
	':Сигнатура:	Public OldValue [As Variant]
	Public OldValue
	
	'@@ChangeEventArgsClass.NewValue
	'<GROUP !!MEMBERTYPE_Properties_ChangeEventArgsClass><TITLE NewValue>
	':Назначение:	"Новое" значение, после изменения.
	':Сигнатура:	Public NewValue [As Variant]
	Public NewValue
	
	'@@ChangeEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_ChangeEventArgsClass><TITLE ReturnValue>
	':Назначение:	Данные, возвращаемые обработчиком события. 
	':Примечание:	
	'	Значение свойства анализируется только для случая события "Changing": 
	'	обработчик события, в качестве "возвращаемых" данных указывает логическое
	'	значение - признак допустимости изменения значения. Здесь:
	'	* True - изменение значения разрешено;
	'	* False - изменение значения запрещено; в этом случае редактор свойства
	'		не изменяет значение, событие "Changed" не генерируется.
	':Сигнатура:	Public ReturnValue [As Variant (As Boolean)]
	Public ReturnValue
	
	'@@ChangeEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_ChangeEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As ChangeEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class
