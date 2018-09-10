Option Explicit

Dim g_oFilterXmlObject
Dim g_sViewStateCacheFileName
Dim g_bFilterDKPInitialized

X_RegisterStaticHandler "usrXEditor_OnLoad", "usrXEditor_OnLoad_WizardWithSelectFolder"
X_RegisterStaticHandler "usrXEditor_OnPageStart", "usrXEditor_OnPageStart_WizardWithSelectFolder"

'==============================================================================
' Обработчик события Load только для мастера 
Sub usrXEditor_OnLoad_WizardWithSelectFolder(oSender, oEventArgs)
	Dim oFilterXmlObjectCached
	Dim oProp
	Dim oPropCached
	
	g_bFilterDKPInitialized = False
	g_sViewStateCacheFileName = oSender.Signature() & "FilterDKP"
	' Создадим в пуле временный объект для отрисовки фильтра для дерева выбора папки
	Set g_oFilterXmlObject = oSender.Pool.CreateXmlObjectInPool( "FilterDKP" )
	' Восстановим значения свойств временого объекта
	If X_GetDataCache( g_sViewStateCacheFileName, oFilterXmlObjectCached ) Then
		For Each oProp In g_oFilterXmlObject.childNodes
			If Not IsNull(oProp.dataType) Then
				Set oPropCached = oFilterXmlObjectCached.selectSingleNode(oProp.tagName)
				If Not oPropCached Is Nothing Then
					If oProp.dataType = oPropCached.dataType Then
						oProp.nodeTypedValue = oPropCached.nodeTypedValue
					End If
				End If
			End If
		Next
	End If
	' Положим объект фильтра в виртуальное свойство Инцидента
	oSender.XmlObject.appendChild( oSender.XmlObject.ownerDocument.createElement("virtual-prop-filter") ).appendChild X_CreateStubFromXmlObject(g_oFilterXmlObject)
End Sub


'==============================================================================
'	[in] oEventArgs As EditorStateChangedEventArgs
Sub usrXEditor_OnPageStart_WizardWithSelectFolder(oSender, oEventArgs)
	If oSender.CurrentPage.PageName = "FolderSelection" Then
		g_bFilterDKPInitialized = True
	End If
End Sub


'==============================================================================
' [in] oSender As XPEObjectTreeSelectorClass
' [in] oEventArgs As GetRestrictionsEventArgsClass
Sub usr_Folder_ObjectTreeSelector_OnGetRestrictions(oSender, oEventArgs)
	Dim oBuilder
	Dim oProp
	
	' True - значит "молчаливый режим"
	' Примечание: нас не интересует результат GetData, т.к. нам надо получить данные временного объекта для фильтрации
	If g_bFilterDKPInitialized Then
		' если страница с фильтром была инициализирована, то выполним сбор данных, иначе,
		' если ограничения получаются при 1-jv заполнении PE, то собирать данные с формы не надо, ибо она еще не была инициализирована!
		oSender.ObjectEditor.FetchXmlObject True
	End If
	Set oBuilder = New QueryStringParamCollectionBuilderClass
	' по всем свойствам временного объекта-фильтра 
	For Each oProp In g_oFilterXmlObject.selectNodes("*")
		If Not IsNull(oProp.dataType) Then
			If 0 < Len(oProp.text) Then
				oBuilder.AppendParameter oProp.tagName, oProp.text
			End If	 
		End If	 
	Next
	oEventArgs.ReturnValue = oBuilder.QueryString
End Sub


Sub usrXEditor_OnSaved(oSender, oEventArgs)
	' В случае успешного сохранения (условие генерации события Saved) сохраним данные временного объекта
	X_SaveDataCache g_sViewStateCacheFileName, g_oFilterXmlObject
End Sub
