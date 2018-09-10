Option Explicit

Dim g_bPeriodSelectorInited

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	Dim nDetalization
	
	If oSender.CurrentPage.PageTitle = "ќсновные параметры" And Not g_bPeriodSelectorInited Then
		' »нициализируем обработку свойств, св€занных с периодом времени
		InitPeriodSelector oSender
		g_bPeriodSelectorInited = True
	
	ElseIf oSender.CurrentPage.PageTitle = "‘ормат" Then
		nDetalization = oSender.XmlObject.selectSingleNode("LossDetalization").nodeTypedValue
		' детализаци€ по датам
		If nDetalization = LOSSDETALIZATION_BYDATES Then
			enablePropertyEditor oSender, "ShowColumnTimeLossCause", False
			enablePropertyEditor oSender, "ShowColumnDescr", False
		' детализаци€ по отдельным списани€м
		Else
			enablePropertyEditor oSender, "ShowColumnTimeLossCause", True
			enablePropertyEditor oSender, "ShowColumnDescr", True
		End If

	End If
End Sub

'==============================================================================
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim dtIntervalBegin, dtIntervalEnd
	Dim sMsg
	
	dtIntervalBegin = oSender.XmlObject.selectSingleNode("IntervalBegin").nodeTypedValue
	dtIntervalEnd = oSender.XmlObject.selectSingleNode("IntervalEnd").nodeTypedValue
	
	If IsNull(dtIntervalBegin) Or IsNull(dtIntervalEnd) _
		Or DateDiff("m", dtIntervalBegin, dtIntervalEnd) >= 3 Then
		sMsg = "«адан большой диапазон дат. ¬озможно, отчет будет строитьс€ длительное врем€." _
			& vbNewLine & "¬ы уверены, что хотите продолжить?"
		If Not confirm(sMsg) Then
			oEventArgs.ReturnValue = False
			Exit Sub
		End If
	End If
	
	' если детализаци€ по датам, то не будем показывать дополнительные столбцы
	If oSender.XmlObject.selectSingleNode("LossDetalization").nodeTypedValue = LOSSDETALIZATION_BYDATES Then
		setPropertyValue oSender, "ShowColumnTimeLossCause", False
		setPropertyValue oSender, "ShowColumnDescr", False
	End If
End Sub

'==============================================================================
' –азрешает/запрещает редактор свойства
' [in] oObjectEditor	- ObjectEditorClass, редактор объекта
' [in] sPropName		- String, OPath свойтва
' [in] bEnable		- As Boolean, признак доступности редактора
Sub enablePropertyEditor(oObjectEditor, sPropName, bEnable)
	Dim oPropEditor 
	
	Set oPropEditor = oObjectEditor.CurrentPage.GetPropertyEditor( _
		oObjectEditor.Pool.GetXmlProperty( oObjectEditor.XmlObject, sPropName) )
	
	If bEnable Then
		' Ќе используем "стек доступности", так как количества разрешений
		' и запрещений могут быть не равны
		oPropEditor.ParentPage.EnablePropertyEditorEx oPropEditor, True, True
	Else
		oPropEditor.ParentPage.EnablePropertyEditor oPropEditor, False
	End If
End Sub

'==============================================================================
' ”станавливает значение свойства свойства
' [in] oObjectEditor	- ObjectEditorClass, редактор объекта
' [in] sPropName		- String, OPath свойтва
' [in] vValue As Variant - значение свойства
Sub setPropertyValue(oObjectEditor, sPropName, ByVal vValue)
	Dim oXmlProperty
	
	Set oXmlProperty = oObjectEditor.Pool.GetXmlProperty( _
		oObjectEditor.XmlObject, sPropName )
	
	oObjectEditor.Pool.SetPropertyValue oXmlProperty, vValue
End Sub

