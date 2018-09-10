Option Explicit
Dim g_oFilterXmlObject
Dim g_bFilterDKPInitialized
Dim g_oObjectEditor
Dim g_bShowOnlyOwnTimeLoss

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
    Dim nResult
    g_bShowOnlyOwnTimeLoss = True
    If oSender.QueryString.GetValue("METANAME", Null) = "TimeLossSearchingList" Then
        nResult = GetScalarValueFromDataSource("CheckFoldersForTimeLossSearchingList", Array("CurEmployeeID"), Array(GetCurrentUserProfile().EmployeeID))
        If nResult = 0 Then
            oSender.Pool.SetPropertyValue oSender.Pool.GetXmlProperty(oSender.XmlObject, "OnlyOwnTimeLoss"), True
            g_bShowOnlyOwnTimeLoss = False
        End If
    End If
    
    If oSender.Pool.GetPropertyValue(oSender.XmlObject, "OnlyOwnTimeLoss") Then
        oSender.Pages.Item("Employees").IsHidden = True
    End If    
	
	Set g_oObjectEditor = oSender
	setUpXmlObjectOfFoldersTreeFilter oSender
End Sub


'==============================================================================
' Обработчик изменения состояния булевого флага "Только мои списания"
' Если флаг устанавливается, то закладка "Сотрудники" скрывается
Sub usr_OnlyOwnTimeLoss_Bool_OnChanged(oSender, oEventArgs)
	hideEmployeesTab oEventArgs.NewValue
End Sub


'==============================================================================
' Скрываеть или показывает закладку "Сотрудники"
'	[in] bHide - True - скрыть, False - показать закладку
Sub hideEmployeesTab(bHide)
	Tabs.HideTab 2, bHide
End Sub

'==============================================================================
Sub setUpXmlObjectOfFoldersTreeFilter(oObjectEditor)
	Dim oProp
	
	Set oProp = oObjectEditor.XmlObject.selectSingleNode("virtual-prop-filter")
	If oProp Is Nothing Then
		Set oProp = oObjectEditor.XmlObject.appendChild( oObjectEditor.XmlObject.ownerDocument.createElement("virtual-prop-filter") )
	End If
	Set g_oFilterXmlObject = oProp.firstChild
	If g_oFilterXmlObject Is Nothing Then
		' Создадим в пуле временный объект для отрисовки фильтра для дерева выбора папки
		Set g_oFilterXmlObject = oObjectEditor.Pool.CreateXmlObjectInPool( "FilterDKP" )
		' Положим объект фильтра в виртуальное свойство Инцидента
		 oProp.appendChild X_CreateStubFromXmlObject(g_oFilterXmlObject)
	Else
		Set g_oFilterXmlObject = oObjectEditor.Pool.GetXmlObjectByXmlElement(g_oFilterXmlObject, Null)
	End If
End Sub

'==============================================================================
'	[in] oEventArgs As EditorStateChangedEventArgs
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	g_bFilterDKPInitialized = True
End Sub


'==============================================================================
' [in] oSender As XPEObjectTreeSelectorClass
' [in] oEventArgs As GetRestrictionsEventArgsClass
Sub usr_FilterTimeLossSearchingList_Folders_ObjectsTreeSelector_OnGetRestrictions(oSender, oEventArgs)
	Dim oBuilder
	Dim oProp
	
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


'==============================================================================
' Обработчик кнопки "Настроить" фильтра по проекту (свойство Folders)
Sub btnOpenFilterOfFoldersTree_onClick
	Dim oFilterDialog	' Параметры диалога редактора (временного объекта)
	Dim vResult			' Результат работы редактора 
	Dim nOldTS			' ts до вызова редактора в диалге
	Dim oPE
	
	' Создаем служебный объект, задающий параметры диалога редактора:
	Set oFilterDialog = new ObjectEditorDialogClass
	' ...в вызываемый редактр передается объект данного редактора (через него 
	' осуществляется запись данных редактируемого временного объекта в общий пул):
	Set oFilterDialog.ParentObjectEditor = g_oObjectEditor
	' ...указываем при этом тип и идентификатор редактируемого объекта - это 
	' тот же объект, что отображается данным редактором:
	Set oFilterDialog.XmlObject = g_oFilterXmlObject
	' ...указываем метанаименование описания редактора, используемого при 
	' построении интерфейса диалога (см. определения в метаданных):
	oFilterDialog.MetaName = "EditorInDialog"
	
	nOldTS = SafeCLng(g_oFilterXmlObject.getAttribute("ts"))
	
	' Вызываем отображение диалога редактора:
	vResult = ObjectEditorDialogClass_Show(oFilterDialog)
	
	Set g_oFilterXmlObject = g_oObjectEditor.Pool.Xml.selectSingleNode("FilterDKP")

	If ( nOldTS <> SafeCLng(g_oFilterXmlObject.getAttribute("ts")) ) Then
		' изменился ts объекта. Это значит в диалоге нажали кнопку "Закрыть"
		updateTreeModeDescription
	Else
		' Если получили в результате Empty, это означает, что редактор был закрыт
		' без внесения изменений (по кнопке "Отменить" или явно); в этом случае, 
		' ничего не изменяя, просто выходим из обработчика
		If Not hasValue(vResult) Then Exit Sub

		updateTreeModeDescription		
		
		' Вызываем внутренний метод, приводящий к перегрузке списка, зависящего 
		' от фильтра:
		Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Folders"))
		oPE.Load
	End If
End Sub


'==============================================================================
' Обработчик кнопки "Очистить" фильтра по проекту (свойство Folders)
Sub btnClearFilterOfFoldersTree_onClick
	Dim oPE
	
	' Очистим свойство "Папки"
	g_oObjectEditor.XmlObject.selectNodes("Folders/*").removeAll
	' Удалим объект фильтра
	With g_oObjectEditor
		.XmlObject.selectSingleNode("virtual-prop-filter").selectNodes("*").removeAll
		g_oFilterXmlObject.parentNode.removeChild g_oFilterXmlObject
		Set g_oFilterXmlObject = Nothing
	End With
	' и заново создадим
	setUpXmlObjectOfFoldersTreeFilter g_oObjectEditor
	' и перегрузим иерархию папок
	Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Folders"))
	oPE.Load
End Sub


Sub updateTreeModeDescription
End Sub