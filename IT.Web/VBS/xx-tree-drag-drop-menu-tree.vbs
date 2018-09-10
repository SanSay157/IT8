'===============================================================================
'@@!!FILE_xx-tree-drag-drop-menu-tree
'<GROUP !!SYMREF_VBS>
'<TITLE xx-tree-drag-drop-menu-tree - Реализация операции переноса в виде попап меню>
':Назначение:
'	Только для страницы x-tree.aspx. Реализуется обработчики событий операции переноса. 
'   Операция переноса описывается в метаданных в виде меню.
'   Меню показывается при "отпускании" переносимого узла
'   Отдельно обрабатывается операция "DoMove".
'   
'===============================================================================
'@@!!FUNCTIONS_xx-tree-drag-drop-menu-tree
'<GROUP !!FILE_xx-tree-drag-drop-menu-tree><TITLE Функции и процедуры>
'@@!!CLASSES_xx-tree-drag-drop-menu-tree
'<GROUP !!FILE_xx-tree-drag-drop-menu-tree><TITLE Классы>

Option Explicit

'===============================================================================
' Обработчик события NodeDragOver
Sub XXNodeDragMenuCanDropHandler(oSender, oEventArgs)
    Dim oMDManager      ' Менеджер метаданных
    Dim sPath           ' Путь переносимого узла
    Dim aPath           ' Путь переносимого узла в виде массива
    Dim oNodeDragXml    ' Описание операции переноса
    Dim oMenuXml        ' Описание меню
    Dim oMenuItemNode   ' Пункт меню
    Dim oParam          ' Параметр пункта меню
    Dim sParentPropName ' Название родительского свойства
    Dim sParentPropType ' Название типа родительского объекта
    
    sPath = oEventArgs.SourceNode.Path
    
    ' Обрабатываем только случай проноса над узлом, вне узлов запрещать не будем
    If HasValue(oEventArgs.TargetNode) Then 
        ' Получим менеджер метаданных для иерархии
        Set oMDManager = XX_GetTreeDragDropMDManager(g_oXTreePage.MetaName)
        ' Получим описание операции переноса из метаданных
        Set oNodeDragXml = oMDManager.GetMDByPath(sPath)
        If HasValue(oNodeDragXml) Then
            ' Поищем описание меню
            Set oMenuXml = oNodeDragXml.SelectSingleNode("ie:node-drag-menu/i:menu") 
            If HasValue(oMenuXml) Then
                ' Если есть операции, отличные от DoMove или DoCancel, разрешаем "отпускать"
                If oMenuXml.SelectNodes("i:menu-item[not(@action='DoMove' or @action='DoMove')]").Length > 0 Then Exit Sub
                ' Ищем операции DoMove, для которых указано свойство, тип значения которого совпадает с типом узла, над которым проносим
                For Each oMenuItemNode in oMenuXml.SelectNodes("i:menu-item[@action='DoMove']")
                    Set oParam = oMenuItemNode.SelectSingleNode("i:params/i:param[@n='ParentPropName']")
                    If HasValue(oParam) Then
                        sParentPropName = oParam.NodeTypedValue
                        sParentPropType = X_GetTypeMD(oEventArgs.SourceNode.Type).SelectSingleNode("ds:prop[@n='" & sParentPropName & "']").GetAttribute("ot")
                        ' Если нашли - можно "Отпускать"
                        If sParentPropType = oEventArgs.TargetNode.Type Then
                            Exit Sub
                        End If
                    End If
                Next
            End If
        End If
        oEventArgs.CanDrop = False
        oEventArgs.Cancel = True
    End If
End Sub

'===============================================================================
' Обработчик события NodeDragDrop
Sub XXNodeDragMenuExecuteDropHandler(oSender, oEventArgs)
    Dim oMDManager      ' Менеджер метаданных
    Dim sPath           ' Путь переносимого узла
    Dim aPath           ' Путь переносимого узла в виде массива
    Dim oNodeDragXml    ' Описание операции переноса
    Dim oMenuXml        ' Описание меню
    Dim oMenu           ' Меню
    
    ' Определим, где будем показывать меню
    Dim nPosLeft, nPosTop, nPosRight, nPosBottom
    Dim nTreeViewPosX, nTreeViewPosY	' экранные координаты TreeView
	Dim nPendingMenuPosX				'- Экранная Х-координата точки показа PopUp меню, после того как оно будет загружено
	Dim nPendingMenuPosY				'- Экранная Y-координата точки показа PopUp меню, после того как оно будет загружено
	
	' Если "отпускаем" в узел, то покажем рядом с ним
	If HasValue(oEventArgs.TargetNode) Then
	    If oEventArgs.TargetNode.GetCoords(nPosLeft, nPosTop, nPosRight, nPosBottom) Then
		    X_GetHtmlElementScreenPos oSender.TreeView, nTreeViewPosX, nTreeViewPosY
		    nPendingMenuPosX = nTreeViewPosX + nPosLeft
		    nPendingMenuPosY = nTreeViewPosY + nPosBottom
	    End If
	End If
    
    sPath = oEventArgs.SourceNode.Path     
    Set oMDManager = XX_GetTreeDragDropMDManager(g_oXTreePage.MetaName)
    Set oNodeDragXml = oMDManager.GetMDByPath(sPath)
    If HasValue(oNodeDragXml) Then
        Set oMenuXml = oNodeDragXml.SelectSingleNode("ie:node-drag-menu/i:menu") 
        If HasValue(oMenuXml) Then
            Set oMenu = New MenuClass
            oMenu.Init oMenuXml
            ' Если не было указано обработчиков с mode=replace - добавим стандартные
            If oMenuXml.SelectNodes("i:visibility-handler[@mode='replace']").Length = 0 Then _
                oMenu.AddVisibilityHandler X_CreateDelegate(Nothing, "XXNodeDragMenuVisibilityHandler")
            If oMenuXml.SelectNodes("i:execution-handler[@mode='replace']").Length = 0 Then _                
                oMenu.AddExecutionHandler X_CreateDelegate(Nothing, "XXNodeDragMenuExecutionHandler")
            oMenu.Macros.Item("SourceType") = oEventArgs.SourceNode.Type    
            oMenu.Macros.Item("NodePath") = oEventArgs.SourceNode.Path
            If HasValue(oEventArgs.TargetNode) Then
                oMenu.Macros.Item("TargetType") = oEventArgs.TargetNode.Type
                oMenu.Macros.Item("NewParentPath") = oEventArgs.TargetNode.Path
            Else
                oMenu.Macros.Item("TargetType") = Null  
                oMenu.Macros.Item("NewParentPath") = Null
            End If         
            oMenu.ShowPopupMenuWithPos oSender, nPendingMenuPosX, nPendingMenuPosY                
        End If
    End If
End Sub

'===============================================================================
' Стандартный обработчик видимости пунктов меню при переносе узла иерархии
Sub XXNodeDragMenuVisibilityHandler(oSender, oEventArgs)
    Dim oMenuItemNode   ' описание пункта меню
    Dim oParam          ' параметр пункта меню
    Dim bHide           ' признак того, что пункт меню надо спрятать
    Dim sParentPropName ' наименование родительского свойства
    Dim sParentPropType ' наименование типа родительского объекта
    
    ' Пройдемся по пунктам меню
    For Each oMenuItemNode In oEventArgs.ActiveMenuItems
        bHide = True
        ' Все кроме DoMove оставим как есть
        If oMenuItemNode.GetAttribute("action") = "DoMove" Then
            ' Для DoMove оставим те, у которых тип значения свойства ParentPropName совпадает с типом узла, куда "отпускаем"
            Set oParam = oMenuItemNode.SelectSingleNode("i:params/i:param[@n='ParentPropName']")
            If HasValue(oParam) Then
                sParentPropName = oParam.NodeTypedValue
                sParentPropType = X_GetTypeMD(oEventArgs.Menu.Macros.Item("SourceType")).SelectSingleNode("ds:prop[@n='" & sParentPropName & "']").GetAttribute("ot")
                If sParentPropType = oEventArgs.Menu.Macros.Item("TargetType") Then
                    bHide = False
                End If
            End If
        Else
            bHide = False
        End If
        If bHide Then
            oMenuItemNode.SetAttribute "hidden", "1"         
        End If
    Next
End Sub

'===============================================================================
' Стандартный обработчик выполнения пунктов меню при переносе узла иерархии
Sub XXNodeDragMenuExecutionHandler(oSender, oEventArgs)
    ' Обрабатывает только DoMove
    Select Case oEventArgs.Action
        Case "DoMove"
            XXNodeDragMenuOnMove oSender, oEventArgs 
    End Select
End Sub

'==============================================================================
' Перенос узла. Обработчик операции DoMove
Sub XXNodeDragMenuOnMove(oSender, oEventArgs)
    Dim aPath           ' Путь переносимого узла в виде массива
    Dim aTargetPath     ' Путь узла в виде массива
    Dim oOldParent      ' Старый родительский узел
    Dim oNewParent      ' Новый родительский узел
    
    aPath = Split(oEventArgs.Menu.Macros.Item("NodePath"), "|")
    
    Set oOldParent = Nothing
    Set oNewParent = Nothing
    
    ' Сформируем параметры и вызовем стандартную реализуцию переноса 
    
	With X_CreateControlsDisabler(oSender)
		With New CommonEventArgsClass
			.ObjectID = aPath(1)
			.ObjectType = aPath(0)
			.ReturnValue = True
			.Metaname = Null
			Set .AddEventArgs = New MoveTreeNodeEventArgsClass
			.AddEventArgs.ParentPropName = oEventArgs.Menu.Macros.Item("ParentPropName")
			.AddEventArgs.NewParentPath = oEventArgs.Menu.Macros.Item("NewParentPath")
			aTargetPath = Split(oEventArgs.Menu.Macros.Item("NewParentPath"), "|")
			.AddEventArgs.ParentObjectType = aTargetPath(0)
			.AddEventArgs.ParentObjectID = aTargetPath(1)
			' запомним перемещаемый узел дерева
			Set .AddEventArgs.MovingNode = oSender.TreeView.GetNode(oEventArgs.Menu.Macros.Item("NodePath"), False)
			Set oOldParent = .AddEventArgs.MovingNode.Parent
			If HasValue(.AddEventArgs.NewParentPath) Then
			    Set oNewParent = oSender.TreeView.GetNode(.AddEventArgs.NewParentPath, False)
			End If
			Set .Values = oEventArgs.Menu.Macros
			' собственно перенос
			stdXTree_OnMove oSender, .Self()	
			' постобработка
			If oEventArgs.Menu.Macros.Exists("RefreshFlags") Then
			    If oEventArgs.Menu.Macros.Item("RefreshFlags") <> "TRM_NONE" Then
			        stdXTree_OnAfterMove oSender, .Self()
			        Exit Sub
			    End If
			End If
			.AddEventArgs.MovingNode.Remove
			ReloadAfterMoveSafe oOldParent, oNewParent, oSender.TreeView
		End With	
	End With
End Sub

'==============================================================================
' Операция обновления дерева после переноса узла
' [in] oFromNode - откуда перенесли
' [in] oToNode - куда перенесли
' [in] oTreeView - дерево
Public Sub ReloadAfterMoveSafe(oFromNode, oToNode, oTreeView)
    Dim oTopNode
    Dim oBottomNode
    
    If HasValue(oFromNode) And HasValue(oToNode) Then
        ' Перенесли самого на себя
        If oToNode.Path = oFromNode.Path Then
            oToNode.Reload            
            Exit Sub
        ' Перенесли по ветке выше
        ElseIf InStrRev(oFromNode.Path, oToNode.Path) > 0 Then
            Set oTopNode = oToNode
            Set oBottomNode = oFromNode
        ' Перенесли по ветке ниже
        ElseIf InStrRev(oToNode.Path, oFromNode.Path) > 0 Then
            Set oTopNode = oFromNode
            Set oBottomNode = oToNode
            If oToNode.Expanded Then oToNode.Children.Reload
        ' Перенесли в другую ветку
        Else
            If oToNode.Expanded Then oToNode.Children.Reload
            oToNode.Reload
            oFromNode.Reload
            Exit Sub
        End If
        ' Если перенесли в рамках ветки, обновим в ней узлы
        Do
            oBottomNode.Reload
            Set oBottomNode = oBottomNode.Parent
        Loop While Not (oBottomNode.Path = oTopNode.Path)
        If oTopNode Is oToNode Then
            If oTopNode.Expanded Then oTopNode.Children.Reload
        End If
        oTopNode.Reload
    ' Перенесли в корень
    ElseIf HasValue(oFromNode) Then
        oFromNode.Reload
    ' Перенесли из корня
    ElseIf HasValue(oToNode) Then 
        oTreeView.Reload
    End If
End Sub