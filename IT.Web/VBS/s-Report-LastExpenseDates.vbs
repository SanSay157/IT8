Option Explicit

Dim g_oFilterXmlObject
Dim g_oObjectEditor

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Set g_oObjectEditor = oSender

	setUpXmlObjectOfFoldersTreeFilter oSender
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
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim oFolders, oOrganizations, oDepartments, oEmployees
	
	Set oFolders = oSender.Pool.GetXmlObjectsByOPath(oSender.XmlObject, "Folders")
	Set oOrganizations = oSender.Pool.GetXmlObjectsByOPath(oSender.XmlObject, "Organizations")
	Set oDepartments = oSender.Pool.GetXmlObjectsByOPath(oSender.XmlObject, "Departments")
	Set oEmployees = oSender.Pool.GetXmlObjectsByOPath(oSender.XmlObject, "Employees")
	
	If	(oFolders Is Nothing) And _
		(oOrganizations Is Nothing) And _
		(oDepartments Is Nothing) And _
		(oEmployees Is Nothing) Then
		alert "Вы должны задать активности или сотрудников."
		oEventArgs.ReturnValue = False
	End If
End Sub
