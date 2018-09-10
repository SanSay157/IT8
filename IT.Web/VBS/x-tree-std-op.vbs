'===============================================================================
'@@!!FILE_x-tree-std-op
'<GROUP !!SYMREF_VBS>
'<TITLE x-tree-std-op - Стандартные обработчики меню иерархии объектов>
':Назначение:
'	Набор общих функций, процедур и классов, используемых в реализации 
'	стандартных обработчиков меню иерархии объектов.
'===============================================================================
'@@!!FUNCTIONS_x-tree-std-op
'<GROUP !!FILE_x-tree-std-op><TITLE Функции и процедуры>
'@@!!CLASSES_x-tree-std-op
'<GROUP !!FILE_x-tree-std-op><TITLE Классы>

Option Explicit
'<СТАНДАРТНЫЕ ОБРАБОТЧИКИ МЕНЮ>							


'==============================================================================
' Стандартный обработчик события OnEdit (редактированиe объекта)
'	[in] oEventArg As CommonEventArgsClass
Sub stdXTree_OnEdit(oXTreePage, oEventArg)
	oEventArg.ObjectID = X_OpenObjectEditor(oEventArg.ObjectType, oEventArg.ObjectID, oEventArg.Metaname, oEventArg.Values.Item("URLPARAMS"))
	oEventArg.ReturnValue = Not IsEmpty(oEventArg.ObjectID)
End Sub


'==============================================================================
' Стандартный обработчик события OnAfterEdit
'	[in] oEventArg As CommonEventArgsClass
Sub stdXTree_OnAfterEdit(oXTreePage, oEventArg)
	' ReturnValue говорит об успехе
	' ObjectID - идентификатор объекта
	If oEventArg.ReturnValue Then
		oXTreePage.RefreshCurrentNode Eval(oEventArg.Values.Item("RefreshFlags"))
		oXTreePage.ShowMenu()			
	End If
End Sub


'==============================================================================
' Стандартный обработчик события OnCreate (создание объекта)
'	[in] oEventArg As CommonEventArgsClass
Sub stdXTree_OnCreate(oXTreePage, oEventArg)
	oEventArg.ReturnValue = X_OpenObjectEditor(oEventArg.ObjectType, oEventArg.ObjectID, oEventArg.Metaname, oEventArg.Values.Item("URLPARAMS"))
End Sub


'==============================================================================
' Стандартный обработчик события OnAfterCreate
'	[in] oEventArg As CommonEventArgsClass
Sub stdXTree_OnAfterCreate(oXTreePage, oEventArg)
	' ReturnValue идентификатор объекта
	If Not IsEmpty(oEventArg.ReturnValue) Then
		oXTreePage.RefreshCurrentNode Eval(oEventArg.Values.Item("RefreshFlags"))
		oXTreePage.ShowMenu()			
	End If
End Sub


'==============================================================================
' Стандартный обработчик события OnBeforeDelete
'	[in] oEventArg As DeleteObjectArgsClass
Sub stdXTree_OnBeforeDelete( oXTreePage, oEventArg )
	' запомним текущий узел
	Set oEventArg.AddEventArgs = oXTreePage.TreeView.ActiveNode
End Sub


'==============================================================================
' Стандартный обработчик события OnDelete (удаления указанного объекта)
'	[in] oEventArg As DeleteObjectArgsClass
Sub stdXTree_OnDelete(oXTreePage, oEventArg)
	Dim nButtonFlag		' флаги MsgBox
	nButtonFlag = iif(StrComp(oEventArg.Values.Item("DefaultButton"), "No")=0, vbDefaultButton2, vbDefaultButton1)
	If vbYes = MsgBox(oEventArg.Values.Item("Prompt"), vbYesNo + vbInformation + nButtonFlag, "Удаление объекта") Then
		' Удаляю объект
		oEventArg.Count = X_DeleteObject( oEventArg.ObjectType, oEventArg.ObjectID )
		oEventArg.ReturnValue = Not X_HandleError
	End If				
End Sub


'==============================================================================
' Стандартный обработчик события OnAfterDelete
' В AddEventArgs IXTreeNode удаляемого узла.
'	[in] oEventArg As DeleteObjectArgsClass
Sub stdXTree_OnAfterDelete( oXTreePage, oEventArg )
    Dim oParentNode		' родитель удаляемого узла
    Dim nOps			' флаги обновления 

	If oEventArg.ReturnValue Then
		oXTreePage.TreeView.Enabled = false
		Set oParentNode = oEventArg.AddEventArgs.Parent
		If oEventArg.Count > 0  Then
			' объект удаляли и удалили - удалим соответствующий ему узел из дерева
			oEventArg.AddEventArgs.Remove
			nOps = Eval(oEventArg.Values.Item("RefreshFlags"))
			If nOps = TRM_NONE Then
				If Not oParentNode Is Nothing Then
					oParentNode.Reload
				End If
			Else
				' Обновим дерево
				DoRefreshTree nOps, Nothing, oParentNode
			End If
		Else
			' объект удаляли, но не удалили - обновим его
			oEventArg.AddEventArgs.Reload
		End If
		oXTreePage.TreeView.Enabled = true
		oXTreePage.m_sTreePath = oXTreePage.TreeView.Path
		oXTreePage.ShowMenu
	End If
End Sub


'===============================================================================
'@@MoveTreeNodeEventArgsClass
'<GROUP !!CLASSES_x-tree-std-op><TITLE MoveTreeNodeEventArgsClass>
':Назначение:	
'   Дополнительные параметры событий BeforeMove, Move, AfterMove.
'
'@@!!MEMBERTYPE_Properties_MoveTreeNodeEventArgsClass
'<GROUP MoveTreeNodeEventArgsClass><TITLE Свойства>
Class MoveTreeNodeEventArgsClass

	'------------------------------------------------------------------------------
	'@@MoveTreeNodeEventArgsClass.MovingNode
	'<GROUP !!MEMBERTYPE_Properties_MoveTreeNodeEventArgsClass><TITLE MovingNode>
	':Назначение:	
	'	Узел перемещаемого объекта. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public MovingNode [As IXTreeNode]
	Public MovingNode
	
	'------------------------------------------------------------------------------
	'@@MoveTreeNodeEventArgsClass.ParentObjectType
	'<GROUP !!MEMBERTYPE_Properties_MoveTreeNodeEventArgsClass><TITLE ParentObjectType>
	':Назначение:	
	'	Наименование типа родительского объекта. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ParentObjectType [As String]
	Public ParentObjectType
	
	'------------------------------------------------------------------------------
	'@@MoveTreeNodeEventArgsClass.ParentObjectID
	'<GROUP !!MEMBERTYPE_Properties_MoveTreeNodeEventArgsClass><TITLE ParentObjectID>
	':Назначение:	
	'	Идентификатор родительского объекта. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ParentObjectID [As String]
	Public ParentObjectID
	
	'------------------------------------------------------------------------------
	'@@MoveTreeNodeEventArgsClass.NewParentPath
	'<GROUP !!MEMBERTYPE_Properties_MoveTreeNodeEventArgsClass><TITLE NewParentPath>
	':Назначение:	
	'	Путь от нового родительского объекта до корня. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public NewParentPath [As String]
	Public NewParentPath
	
	'------------------------------------------------------------------------------
	'@@MoveTreeNodeEventArgsClass.ParentPropName
	'<GROUP !!MEMBERTYPE_Properties_MoveTreeNodeEventArgsClass><TITLE ParentPropName>
	':Назначение:	
	'	Наименование свойства, указывающее на вышестоящий объект. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ParentPropName [As String]
	Public ParentPropName
End Class


'==============================================================================
' Стандартный обработчик события OnMove
Sub stdXTree_OnMove(oXTreePage, oEventArg)
	Dim sNewParentPath		' As String - путь от нового парента до корня
	Dim sOT					' As String - тип объекта
	Dim sID					' As String - идентификатор объекта
	Dim oXmlObject			' IXMLDOMElement - Xml-объект переносимого узла
	Dim sPN					' As String - наименование св-ва выбранного объекта, указывающее на родительский объект
	Dim sPID				' As String - идентификатор родителя
	Dim sPOT				' As String - тип родителя

	oEventArg.ReturnValue = False
	sPN = oEventArg.AddEventArgs.ParentPropName
	If Not Len(sPN)>0 Then
		X_ErrReportEx "Не задано наименование свойства, указывающее на вышестоящий объект", "stdXTree_OnMove"
	End If
	sOT = oEventArg.ObjectType
	sID = oEventArg.ObjectID 	
	If Not Len(sOT)>0 Or Not Len(sID)>0 Then
		X_ErrReportEx "Не задан тип и/или идентификатор переносимого объекта", "stdXTree_OnMove"
	End If
	sNewParentPath = oEventArg.AddEventArgs.NewParentPath
	' проверяю, не является ли новый парент самим узлом или его чилдом
	If 0<>InStr(1,"|" & sNewParentPath & "|" , "|" & sOT & "|" & sID & "|") Then
		MsgBox "Этот объект не может быть перенесен сюда", vbExclamation, "Предупреждение"
		Exit Sub
	End If
	sPOT = oEventArg.AddEventArgs.ParentObjectType
	sPID = oEventArg.AddEventArgs.ParentObjectID
	If Not Len(sPOT)>0 Or Not Len(sPID)>0 Then
		X_ErrReportEx "Не задан тип и/или идентификатор родительского объекта", "stdXTree_OnMove"
	End If
	Set oXmlObject = X_GetObjectFromServer( sOT, sID, vbNullString )
	If oXmlObject Is Nothing Then
		X_HandleError
		Exit Sub
	End If
	oXmlObject.selectNodes("*").removeAll
	oXmlObject.appendChild( oXmlObject.ownerDocument.createElement(sPN) ).appendChild X_CreateObjectStub(sPOT, sPID)
	' выполним команду сохранения
	With New XSaveObjectRequest
		.m_sName = "SaveObject"
		Set .m_oXmlSaveData = oXmlObject
		X_ExecuteCommand .Self
	End With
	oEventArg.ReturnValue = Not X_HandleError
End Sub


'==============================================================================
' Обновление состояния дерева после переноса узла
'	[in] oXTreePage As XTreePageClass
'	[in] oNode As IXTreeNode - перемещаемый узел
'	[in] sNewParentPath As String - путь до нового родителя
Sub UpdateTreeStateAfterNodeMove(oXTreePage, oNode, sNewParentPath)
	Dim oOldParent		' старый родитель
	Dim oNewParent		' новый родительский узел
	Dim bExpanded		' признак распахнутости старого родителя
	Dim sOT				' As String - тип объекта
	Dim sID				' As String - идентификатор объекта

	sOT = oNode.Type
	sID = oNode.ID	
	' путь до старого парента
	Set oOldParent = oNode.Parent
	' получаю нового родителя - владельца перемещаемого узла...
	Set oNewParent = GetTreeViewNodeSafe( sNewParentPath )
	' и запоминаю его состояние (распахнутость)
	If oNewParent Is Nothing then
		bExpanded = Null
	Else
		bExpanded = oNewParent.Expanded
	End If
	' удаляю объект из его старого владельца с обновлением
	oNode.Remove()	
	If oOldParent Is Nothing Then
		' Корневой элемент - перезагружаю дерево...
		oXTreePage.Reload
	Else
		' обновляю старого владельца узла
		oOldParent.Reload
		' и обновляем все узлы на пути от старого родителя до корня
		Set oOldParent = oOldParent.Parent
		Do While Not (Nothing Is oOldParent)
			oOldParent.Reload
			Set oOldParent = oOldParent.Parent
		Loop
	End If
	' получаю нового родителя - владельца перемещаемого узла... (после обновления дерева объект мог разрушиться, а путь - постоянен)
	If Not oNewParent Is Nothing Then
		set oNewParent = GetTreeViewNodeSafe(sNewParentPath)
	End If
	If Not oNewParent Is Nothing Then
		oNewParent.Reload
		If oNewParent.Expanded Then  'если узел уже распахнут, следовательно дети видны, перегрузим их
			oNewParent.Children.Reload
			g_oXTreePage.TreeView.Path = sOT & "|" & sID & "|" & sNewParentPath
		ElseIf bExpanded Then		 'узел, не распахнут, но был распахнут до обновления
			oNewParent.Expanded = True
			g_oXTreePage.TreeView.Path = sOT & "|" & sID & "|" & sNewParentPath
		end if
		' Обновим всех парентов до корня
		Do While Not (Nothing Is oNewParent)
			oNewParent.Reload
			Set oNewParent = oNewParent.Parent
		Loop
	End If
End Sub


'==============================================================================
' Стандартный обработчик события OnAfterMove
Sub stdXTree_OnAfterMove(oXTreePage, oEventArg)
	Dim nOps			' As Int
	Dim oNode			' перемещаемый узел
	Dim sNewParentPath	' путь от нового парента до корня
	
	If oEventArg.ReturnValue = False Then Exit Sub
	' получаю перемещаемый узел
	Set oNode = oEventArg.AddEventArgs.MovingNode
	' получим путь до нового родителя
	sNewParentPath = oEventArg.AddEventArgs.NewParentPath
	' получаем флаги обновления
	nOps = Eval(oEventArg.Values.Item("RefreshFlags"))
	If CLng(nOps) = TRM_NONE Then   ' по умолчанию обновляю собственным алгоритмом
		UpdateTreeStateAfterNodeMove oXTreePage, oNode, sNewParentPath
	Else	'иначе -  как сказали...
		oXTreePage.m_sTreePath = ""
		oXTreePage.RefreshCurrentNode nOps
		oXTreePage.TreeView.SetNearestPath oEventArg.ObjectType & "|" & oEventArg.ObjectID & "|" & sNewParentPath
	End If
End Sub


'==============================================================================
' Стандартный обработчик события OnSelectParent
Sub stdXTree_OnSelectParent(oXTreePage, oEventArg) 
	Dim aSelection		' результат отбора из дерева
	Dim sUrlArguments	' параметры, передаваемые через урл в диагол выбора из дерева
	
	'TODO: FireEvent "GetRestrictions"
	oEventArg.ReturnValue = False
	sUrlArguments = oEventArg.Values.Item("UrlParams")
	If Len(sUrlArguments)>0 Then sUrlArguments = sUrlArguments & "&"
	sUrlArguments = sUrlArguments & "EXCLUDE=" & oEventArg.ObjectType & "|" & oEventArg.ObjectID
	' вызываю диалог выбора узла
	' Покажем диалог и получим выбранное значение
	With X_SelectFromTree(oEventArg.Metaname, "", "", sUrlArguments, Nothing)
		If .ReturnValue Then
			' запомним выбранный путь
			oEventArg.AddEventArgs.NewParentPath = .Path
			' получим тип и идентификатор объекта, выбранного как родитель
			aSelection = Split(oEventArg.AddEventArgs.NewParentPath, "|")
			oEventArg.AddEventArgs.ParentObjectType = aSelection(0)
			oEventArg.AddEventArgs.ParentObjectID	= aSelection(1)
			oEventArg.ReturnValue = True
		End If
	End With
End Sub


'==============================================================================
' Отображает в статус-баре инструментальную подсказку к ссылке
' [in] oLink			- ссылка (IHTMLAncorElement)
Sub OnMenuShowHint( oLink )
	window.defaultStatus = oLink.Title
	setTimeout  "window.status=window.defaultStatus" ,0,"VBScript"
End Sub


'==============================================================================
' сбрасывае содержимое статус-бара
Sub OnMenuHideHint()
	window.status = ""
	window.defaultStatus = ""
End Sub


'==============================================================================
' обновляет дерево объектов
' [in] nOps			- флаги обновления (TRM_xxxx)
' [in] oCurrentNode	- текущий узел дерева
' [in] oParentNode	- родительский узел обновляемого узла
Sub DoRefreshTree(nOps, oCurrentNode, oParentNode)
	Dim oTreeNode		' As CROC.IXTreeNode - Узел дерева
	Dim oParent			' As CROC.IXTreeNode - Узел дерева
	
	If TRM_NONE = nOps Then Exit Sub ' ничего не делаем
	
	If (nOps And TRM_TREE) Then 'обновление всего дерева
		g_oXTreePage.Reload
	Else
		If (nOps And TRM_NODE) Then   'обновление текущего узла 
			If oCurrentNode Is Nothing Then
				g_oXTreePage.Reload
				Exit Sub
			End If
			Set oCurrentNode = g_oXTreePage.ReloadNode( oCurrentNode )
		End If	

		If (nOps And TRM_CHILDS) Then  'обновление дочерних узлов
			If oCurrentNode Is Nothing Then
				g_oXTreePage.Reload
				Exit Sub
			End if
			If Not oCurrentNode.IsLeaf Then oCurrentNode.children.reload
		End If
		
		If (nOps And TRM_PARENTNODES) Then  ' обновление узлов начиная с парента и до корня
			Set oTreeNode = oParentNode
			Do While Not( Nothing Is oTreeNode)
				Set oParent = oTreeNode.Parent
				oTreeNode.Reload
				Set oTreeNode = oParent
			Loop
		ElseIf (nOps And TRM_PARENTNODE) Then 'обновление узла парента без подчиненных ему узлов
			If Not ( oParentNode Is Nothing ) Then
				Set oParentNode = g_oXTreePage.ReloadNode( oParentNode )
			End If
		End If

		If (nOps And TRM_PARENT) Then  'обновление родительского узла 
			If oParentNode Is Nothing Then
				g_oXTreePage.Reload
			Else
				oParentNode.Children.Reload
				g_oXTreePage.TreeView.SetNearestPath g_oXTreePage.m_sTreePath
			End If
		end if	
	end if
End Sub


'==============================================================================
' Вызов PopUp-меню
Sub DoShowPopupMenu
	g_oXTreePage.ShowPopupMenu
End Sub


'------------------------------------------------------------
' "Безопасное" получение узла
' инц. #65281
' [in] sPath - путь получаемого узла
' Обладает следующей особенностью - пытается в цикле получить узел
' двигаясь от корня вглубь к искомому. При первом обломе НЕ вываливается
' а пытается перезагрузить последнего успешного родителя
Function GetTreeViewNodeSafe(sPath)
	Dim oTempNode	' Временное значение узла дерева
	Dim sTempPath	' Путь
	Dim aTempPath	' Распаршенный путь
	Dim nUBound		' Индекс максимального элемента пути
	Dim i			' Счётчик
	
	On Error Resume Next
	Set GetTreeViewNodeSafe = Nothing
	' Попробуем получить сразу по чесному
	Set GetTreeViewNodeSafe = g_oXTreePage.TreeView.GetNode( sPath, false )
	If 0=Err.number Then Exit Function ' Нашли объект сразу
	' Не удалось - бум пытаться получить ближайшего родителя
	aTempPath = Split(sPath, "|" )
	nUBound = UBound(aTempPath) 
	For i=0 To nUBound-2 Step 2
		aTempPath(i)   = vbNullString
		aTempPath(i+1) = vbNullString
		sPath = Replace(Trim(Join(aTempPath, " ")), " ", "|")
		Set oTempNode = g_oXTreePage.TreeView.GetNode( sTempPath, False )
		If IsObject(oTempNode) Then Exit For
	Next
	If IsObject(oTempNode) Then
		' Нашли родителя, ура!
		' Перезагрузим его
		oTempNode.Children.Reload
		' Повторим попытку
		' Если уж не нейдем не обессудьте :)
		Set GetTreeViewNodeSafe = g_oXTreePage.TreeView.GetNode( sPath, False)
	End If
	' Если добавился корневой элемент дерева, то
	' дерево мы насильственно перегружать не будем :)
	Err.Clear
End Function

'</СТАНДАРТНЫЕ ОБРАБОТЧИКИ МЕНЮ>							
