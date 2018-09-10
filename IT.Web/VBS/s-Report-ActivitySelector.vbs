Option Explicit

Dim g_oFilterXmlObject 'Временный объект - фильтр для дерева выбора папки  

'==============================================================================
' Инициализация фильтра дерева для выбора папки
Sub setUpXmlObjectOfFoldersTreeFilter(oObjectEditor)
	Dim oProp ' Виртуально св-во инцидента
	
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
' Обработчик события OnGetRestrictions
Sub usr_Folders_ObjectsTreeSelector_OnGetRestrictions(oSender, oEventArgs)
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
' Обработчик кнопки "Настроить" (свойство Folders)
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

	If ( nOldTS = SafeCLng(g_oFilterXmlObject.getAttribute("ts")) ) Then
		' Если получили в результате Empty, это означает, что редактор был закрыт
		' без внесения изменений (по кнопке "Отменить" или явно); в этом случае, 
		' ничего не изменяя, просто выходим из обработчика
		If Not hasValue(vResult) Then Exit Sub

		' Вызываем внутренний метод, приводящий к перегрузке списка, зависящего 
		' от фильтра:
		Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Folders"))
		oPE.Load
	End If
End Sub

'==============================================================================
' Обработчик кнопки "Очистить" (свойство Folders)
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

'==============================================================================
' Разрешает/запрещает доступ к выбору папок
Sub enableFolders()
	Dim oAllFoldersEditor ' Св-во фильтра "AllFolders"
	Dim oFoldersEditor ' Св-во фильтра "Folders"
	Dim oDepthEditor ' Св-во фильтра "ActivityAnalysDepth" (глубина анализа)
	' Получаем значения свойств
	Set oAllFoldersEditor = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("AllFolders"))
	Set oFoldersEditor = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Folders"))
	Set oDepthEditor = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("ActivityAnalysDepth"))
	' Если выбран режим "Все активности", то выбор папки в режиме дерева не доступен.
	oFoldersEditor.Enabled = Not CBool(oAllFoldersEditor.Value)
	oDepthEditor.Enabled = Not CBool(oAllFoldersEditor.Value)
	document.all("btnOpenFilterOfFoldersTree").disabled = CBool(oAllFoldersEditor.Value)
	document.all("btnClearFilterOfFoldersTree").disabled = CBool(oAllFoldersEditor.Value)
End Sub

'==============================================================================
Sub usr_AllFolders_Bool_OnChanged(oSender, oEventArgs)
	enableFolders()	
End Sub