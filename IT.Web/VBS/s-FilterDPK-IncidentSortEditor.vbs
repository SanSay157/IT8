Option Explicit

Dim g_oObjectEditor	' Объект-редактор объекта (ObjectEditorClass)

'==============================================================================
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	Dim oEnumMD		' Метаданные перечисления с полями типа Инцидент, используемые для сортировки
	Dim oValueMD	' 
	Dim oProp
	Dim oItem
	Dim bFound
	
	' Сохраним ссылку на экземпляр класса редактора объекта ObjectEditorClass
	Set g_oObjectEditor = oSender
	
	Set oProp = g_oObjectEditor.XmlObject.selectSingleNode("IncidentSortOrder")
	
	Set oEnumMD = X_GetEnumMD("IncidentSortFields")
	If oEnumMD Is Nothing Then Err.Raise -1, "", "Не удалось получить метаданные перечисления IncidentSortFields"
	For Each oValueMD In oEnumMD.selectNodes("ds:value")
		bFound = False
		For Each oItem In oProp.childNodes
			Set oItem = g_oObjectEditor.Pool.GetXmlObjectByXmlElement(oItem, Null)
			If oItem.selectSingleNode("Field").nodeTypedValue = oValueMD.text Then
				bFound = True
				Exit For
			End If
		Next
		If Not bFound Then
			Set oItem = g_oObjectEditor.Pool.CreateXmlObjectInPool("IncidentSortItem")
			oItem.selectSingleNode("Field").nodeTypedValue = oValueMD.text
			oItem.selectSingleNode("Direction").nodeTypedValue = SORTDIRECTIONS_ASC
			g_oObjectEditor.Pool.AddRelation Nothing, oProp, oItem
		End If
	Next
End Sub


Sub IncidentSortOrder_MenuVisibilityHandler(oSender, oEventArgs)
	Dim oMenuItem
	Dim sObjectID
	
	Set oMenuItem = oEventArgs.Menu.XmlMenu.selectSingleNode("i:menu-item[@action='Change']")
	If Not oMenuItem Is Nothing Then
		sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
		If Len("" & sObjectID) = 0 Then 
			oMenuItem.setAttribute "hidden", "1"
		Else
			oMenuItem.removeAttribute "hidden"
		End If
	End If
End Sub


Sub IncidentSortOrder_MenuExecutionHandler(oSender, oEventArgs)
	Dim oItem
	Dim oPE
	Dim nMode
	If oEventArgs.Action = "Change" Then
		Set oItem = g_oObjectEditor.Pool.GetXmlObject( "IncidentSortItem", oEventArgs.Menu.Macros.item("ObjectID"), Null)
		nMode = oItem.selectSingleNode("Direction").nodeTypedValue
		If nMode  = SORTDIRECTIONS_ASC Then
			oItem.selectSingleNode("Direction").nodeTypedValue = SORTDIRECTIONS_DESC
		ElseIf nMode = SORTDIRECTIONS_DESC Then
			oItem.selectSingleNode("Direction").nodeTypedValue = SORTDIRECTIONS_IGNORE
		Else
			oItem.selectSingleNode("Direction").nodeTypedValue = SORTDIRECTIONS_ASC
		End If
	End If
	Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("IncidentSortOrder") )
	oPE.SetData
End Sub
