Option Explicit


'==============================================================================
' ExecutionHandler меню узлов типа Employee (Папка) и Incident (Инцидент)
Sub IncidentCategoryMenu_ExecutionHandler(oSender, oEventArg)
	Dim oActiveNode

	Set oActiveNode = oSender.TreeView.ActiveNode
	Select Case oEventArg.Action
		Case "DoMakeRoot"
			DoMakeRoot oSender, oSender.TreeView.ActiveNode
		Case "DoMoveCategory"
			DoMoveCategory oSender, oSender.TreeView.ActiveNode
	End Select
End Sub


'==============================================================================
'	[in] oXTreePage As XTreePageClass
'	[in] oActiveNode As IXTreeNode - узел IncidentCategory
Sub DoMakeRoot(oXTreePage, oMovingNode)
	Dim sID						' As Guid - идентификатор перемещаемой категории
	Dim oXmlObject
	Dim oResponse				' As XResonse - ответ серверной операции
	Dim sNewParentPath			' новый путь до родительского узла (вирт. узел "Категории")
	Dim sNewPath				' новый путь до узла oMovingNode после переноса
	Dim aPathParts				' массив элементов пути до узла oMovingNode
	
	sID = oMovingNode.ID
	On Error Resume Next
	Set oXmlObject = X_GetObjectFromServer( "IncidentCategory", sID, vbNullString )
	If oXmlObject Is Nothing Then
		X_HandleError
		Exit Sub
	End If
	On Error GoTo 0
	oXmlObject.selectNodes("*").removeAll
	oXmlObject.appendChild( oXmlObject.ownerDocument.createElement("Parent") )
	With New XSaveObjectRequest
		Set .m_oXmlSaveData = oXmlObject
		.m_sName = "SaveObject"
		.m_sSessionID = Null
		.m_oRootObjectId = Null
		.m_sContext = Null
		Set oResponse = X_ExecuteCommandSafe(.Self)
	End With
	If hasValue(oResponse) Then
		' папка успешно перенесена - обновим дерево
		' Новый путь до узла мы можем указать сразу
		aPathParts = Split(oMovingNode.Path, "|")
		sNewParentPath = "IncidentCategoriesFolder|" & GUID_EMPTY & "|IncidentType|" & aPathParts(UBound(aPathParts))
		sNewPath = "IncidentCategory|" & sID & "|" & sNewParentPath
		UpdateTreeStateAfterNodeMove oXTreePage, oMovingNode, sNewPath
		' перегрузим виртуальный узел "Категории", под которым должна будет появиться текущая категория
		oXTreePage.TreeView.GetNode(sNewParentPath).Children.Reload
	End If
End Sub


'==============================================================================
' Перенос категории
'	[in] oXTreePage As XTreePageClass
'	[in] oActiveNode As IXTreeNode - узел IncidentCategory
Sub DoMoveCategory(oXTreePage, oMovingNode)
	Dim oResponse				' As XResonse - ответ серверной операции
	Dim aSelection				' As Variant() - результат отбора из дерева
	Dim sParentObjectType 		' As String - тип узла, выбранного как родительский
	Dim sParentObjectID			' As Guid - идентификатор узла, выбранного как родительский
	Dim sID						' As Guid - идентификатор перемещаемой категории
	Dim oXmlObject
	Dim sIncidentTypeIDCurrent
	Dim sIncidentTypeIDNew
	Dim sNewParentPath			' Путь до нового родителя
	Dim i
	Dim oSaveObjectRequest
	
	sID = oMovingNode.ID
	' Покажем дерево для выбора нового родителя и получим выбранное значение
	With New SelectFromTreeDialogClass
		.Metaname = "IncidentCategorySelectorForMove"
		.InitialPath = oMovingNode.Path		' TODO
		.SelectionMode = TSM_ANYNODE
		.SelectableTypes = "IncidentType IncidentCategory"
		SelectFromTreeDialogClass_Show(.Self)
		If .ReturnValue Then
			' получим тип и идентификатор объекта, выбранного как родитель
			aSelection = Split(.Path, "|")
			sParentObjectType = aSelection(0)
			sParentObjectID	= aSelection(1)
			' проверяю, не является ли новый парент самим узлом или его чилдом
			If 0<>InStr(1,"|" & .Path & "|" , "|IncidentCategory|" & sID & "|") Then
				MsgBox "Категория не может быть перенесена в одну из своих дочерних категорий", vbExclamation, "Предупреждение"
				Exit Sub
			End If
			
			Set oXmlObject = X_GetObjectFromServer( "IncidentCategory", sID, vbNullString )
			If oXmlObject Is Nothing Then
				X_HandleError
				Exit Sub
			End If
			oXmlObject.selectNodes("*").removeAll
			' если выбрали Тип инцидента, то изменим ссылку на тип и обнулим ссылку на родителя
			If sParentObjectType = "IncidentType" Then
				oXmlObject.appendChild( oXmlObject.ownerDocument.createElement("IncidentType") ).appendChild X_CreateObjectStub("IncidentType", sParentObjectID)
				oXmlObject.appendChild( oXmlObject.ownerDocument.createElement("Parent") )
			Else
				' выбрали ссылку на Категорию. Выясним принадлежит ли она тому же типу инцидента, что и перемещаемая
				' тип инцидента в выбранном пути всегда будет на корневом уровне
				sIncidentTypeIDCurrent = oMovingNode.ApplicationData.selectSingleNode("ud/IncidentTypeID").text
				sIncidentTypeIDNew = aSelection(UBound(aSelection))
				If sIncidentTypeIDNew <> sIncidentTypeIDCurrent Then
					oXmlObject.appendChild( oXmlObject.ownerDocument.createElement("IncidentType") ).appendChild X_CreateObjectStub("IncidentType", sIncidentTypeIDNew)
				End If
				' ссылку на родителя полюбому надо изменить
				oXmlObject.appendChild( oXmlObject.ownerDocument.createElement("Parent") ).appendChild X_CreateObjectStub("IncidentCategory", sParentObjectID)
			End If
			' выполним команду сохранения
			Set oSaveObjectRequest = New XSaveObjectRequest
				Set oSaveObjectRequest.m_oXmlSaveData = oXmlObject
				oSaveObjectRequest.m_sContext = Null
				oSaveObjectRequest.m_oRootObjectId = sParentObjectID
				oSaveObjectRequest.m_sName = "SaveObject"
				oSaveObjectRequest.m_sSessionID = Null
			Set oResponse = X_ExecuteCommandSafe(oSaveObjectRequest)
			If hasValue(oResponse) Then
				' полученный путь .Path - содержит путь из категорий и тип инцидента на корне, 
				' а в текущей иерархии между типом инцидента и категорией присутствует еще виртуальный узел "Категории", 
				' поэтому надо скорректировать путь до нового родителя
				For i=0 To UBound(aSelection)-1 Step 2
					If aSelection(i) = "IncidentType" Then
						sNewParentPath = sNewParentPath & "|IncidentCategoriesFolder|" & GUID_EMPTY
					End If
					If Not IsEmpty(sNewParentPath) Then sNewParentPath = sNewParentPath & "|"
					sNewParentPath = sNewParentPath & aSelection(i) & "|" & aSelection(i+1)
				Next
				' папка успешно перенесена - обновим дерево
				UpdateTreeStateAfterNodeMove oXTreePage, oMovingNode, sNewParentPath
			End If
		End If
	End With
End Sub
