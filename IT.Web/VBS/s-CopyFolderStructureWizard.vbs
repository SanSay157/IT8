Option Explicit

' Признак выполнения операции по изменению ведыления
Dim g_bProcessingSelection
g_bProcessingSelection = False

' Обработчик загрузки м/р
Sub usrXEditor_OnLoad(oSender, oEventArgs)
    Dim oSource
    
    ' Проверим, что задана папка - источник
    Set oSource = oSender.Pool.GetXmlObjectByOPath(oSender.XmlObject, "Source")
    If oSource Is Nothing Then Err.Raise vbObjectError, "usrXEditor_OnLoad", "Не указано значение свойства Source. Проверьте код вызова мастера."
End Sub

' Обработчик видимости операций м/р
Sub CopyFolderStructureWizard_MenuVisibilityHandler(oSender, oEventArgs)
    Dim oNode			' As IXMLDOMElement - текущий menu-item
	Dim bHidden			' As Boolean - признак сокрытия пункта
	Dim bProcessed		' As Boolean - признак обработки текущего пункта
	Dim oContext		' As EditorContext
	
	Set oContext = oEventArgs.Menu.Macros.Item("EditorContext")
	For Each oNode In oEventArgs.ActiveMenuItems
		bHidden = Empty
		bProcessed = False
		Select Case oNode.getAttribute("action")
			Case "DoCopy"
				bHidden = Not oContext.IsLastPage
				bProcessed = True
		End Select
		If Not IsEmpty(bHidden) Then
			If bHidden Then 
				oNode.setAttribute "hidden", "1"
			Else
				oNode.removeAttribute "hidden"
			End If
		End If
		If bProcessed Then
			oNode.removeAttribute "disabled"
		End If
	Next
End Sub

' Обрабочик выполнения операций меню м/р
Sub CopyFolderStructureWizard_MenuExecutionHandler(oSender, oEventArgs)
    Dim oOldNewMap
    Dim oChildParentMap
    Dim oNode
    Dim oPE
    Dim oFolder
    Dim sId
    Dim oTarget

    Select Case oEventArgs.Action
        ' Операция копирования структуры папок
        Case "DoCopy"
            oSender.EnableControls False
            ' Проверим параметры
            Set oTarget = oSender.Pool.GetXmlObjectByOPath(oSender.XmlObject, "Target")
            If oTarget Is Nothing Then 
                Alert "Выберите папку назначения"
                oSender.EnableControls True
                Exit Sub
            End If
            Set oPE = oSender.CurrentPage.GetPropertyEditor(oSender.Pool.GetXmlProperty(oSender.XmlObject, "Folders"))
            
            If Not oPE.TreeView.Selection.HasChildNodes Then 
                Alert "Выберите папки для копирования"                
                oSender.EnableControls True
                Exit Sub
            End If
            
            ' Покажем сообщение о том, что операция выполняется
            oPE.HtmlElement.style.display = "none"
            document.all("bkg").style.display = "block"
            document.all("dlgWait").style.display = "block"
            
            oSender.Pool.BeginTransaction False
            
            Set oOldNewMap = CreateObject("Scripting.Dictionary")
            Set oChildParentMap = CreateObject("Scripting.Dictionary")
            
            ' Обработаем выделенные папки
            For Each oNode In oPE.TreeView.Selection.ChildNodes
                Set oFolder = oSender.Pool.CreateXmlObjectInPool("Folder")
                oSender.Pool.SetPropertyValue oSender.Pool.GetXmlProperty(oFolder, "Type"), FOLDERTYPEENUM_DIRECTORY
                oSender.Pool.SetPropertyValue oSender.Pool.GetXmlProperty(oFolder, "Name"), oNode.SelectSingleNode("ad/ud/Name").NodeTypedValue
                oSender.Pool.SetPropertyValue oSender.Pool.GetXmlProperty(oFolder, "IsLocked"), oNode.SelectSingleNode("ad/ud/IsLocked").NodeTypedValue
                If Not oNode.SelectSingleNode("ad/ud/DefaultIncidentType") Is Nothing Then _
                    oSender.Pool.AddRelation _
                        oFolder, _
                        "DefaultIncidentType", _
                        X_CreateObjectStub("IncidentType", oNode.SelectSingleNode("ad/ud/DefaultIncidentType").NodeTypedValue)
                If Not oNode.SelectSingleNode("ad/ud/Description") Is Nothing Then _
                    oSender.Pool.SetPropertyValue oSender.Pool.GetXmlProperty(oFolder, "Description"), oNode.SelectSingleNode("ad/ud/Description").NodeTypedValue
                oOldNewMap.Add oNode.GetAttribute("id"), oSender.Pool.GetPropertyValue(oFolder, "ObjectID")
                If oNode.SelectSingleNode("n/n") Is Nothing Then
                    oChildParentMap.Add oNode.GetAttribute("id"), Null
                Else
                    oChildParentMap.Add oNode.GetAttribute("id"), oNode.SelectSingleNode("n").GetAttribute("id")
                End If
                oSender.Pool.AddRelation _
                    oFolder, _
                    "Customer", _
                    oSender.Pool.GetXmlProperty(oTarget, "Customer").FirstChild
                oSender.Pool.AddRelation _
                    oFolder, _
                    "ActivityType", _
                    oSender.Pool.GetXmlProperty(oTarget, "ActivityType").FirstChild
            Next
            
            For Each sId In oChildParentMap.Keys
                If IsNull(oChildParentMap.Item(sId)) Then
                    oSender.Pool.AddRelation _
                        oSender.Pool.GetXmlObject("Folder", oOldNewMap.Item(sId), Null), _
                        "Parent", _
                        oTarget
                Else
                    oSender.Pool.AddRelation _
                        oSender.Pool.GetXmlObject("Folder", oOldNewMap.Item(sId), Null), _
                        "Parent", _
                        oSender.Pool.GetXmlObject("Folder", oOldNewMap.Item(oChildParentMap.Item(sId)), Null)                    
                End If
            Next
            
            On Error Resume Next
            ' Сохраним новые папки
            oSender.Save
            If X_WasErrorOccured() Then
                On Error GoTo 0
                document.all("dlgWait").style.display = "none"
                document.all("bkg").style.display = "none"
                oPE.HtmlElement.style.display = "block"
                oSender.Pool.RollBackTransaction
                oSender.EnableControls True
                Exit Sub
            End If
            If Err Then
                On Error GoTo 0
                document.all("dlgWait").style.display = "none"
                document.all("bkg").style.display = "none"
                oPE.HtmlElement.style.display = "block"
                oSender.Pool.RollBackTransaction
                oSender.EnableControls True
                Exit Sub
            End If
            On Error GoTo 0
            
            document.all("dlgWait").style.display = "none"
            document.all("bkg").style.display = "none"
            oPE.HtmlElement.style.display = "block"
            oSender.Pool.CommitTransaction
            oSender.EnableControls True
            
            ' Вернем идентификатор папки назначения
            X_SetDialogWindowReturnValue oSender.Pool.GetPropertyValue(oTarget, "ObjectID")
            
            window.close
    End Select
End Sub

' Ограничение на дерево выбора папок 
Sub usr_CopyFolderStructureOperation_Folders_OnGetRestrictions(oSender, oEventArgs)
    oEventArgs.ReturnValue = "Folder=" & oSender.ObjectEditor.Pool.GetPropertyValue(oSender.ObjectEditor.XmlObject, "Source.ObjectID")
End Sub

' Обработчик выделения узла дерева выбора папок
Sub usr_CopyFolderStructureOperation_Folders_OnSelected(oSender, oEventArgs)
    If Not g_bProcessingSelection Then
        g_bProcessingSelection = True 
        ' Выделим все вышестоящие
        TryAddUpperItems oEventArgs.TreeNode 
        g_bProcessingSelection = False
    End If
End Sub

' Обработчик снятия выделения узла дерева выбора папок
Sub usr_CopyFolderStructureOperation_Folders_OnUnSelected(oSender, oEventArgs)
    If Not g_bProcessingSelection Then
        g_bProcessingSelection = True 
        ' Снимим выделение с поддерева
        TryRemoveSubItems oSender.ObjectEditor, oSender.TreeView, oEventArgs.TreeNode.ID
        g_bProcessingSelection = False
    End If
End Sub 

' Выделим вышестоящие узлы 
Sub TryAddUpperItems(oTreeNode)
    
    While Not oTreeNode.Parent Is Nothing
        Set oTreeNode = oTreeNode.Parent
        If oTreeNode.IsSelectable Then
            If oTreeNode.Selected Then Exit Sub
            oTreeNode.Selected = True
        End If
    WEnd
End Sub

' Снимем выделение с поддерева
Sub TryRemoveSubItems(oObjectEditor, oTreeView, sId)
    Dim oSelection
    Dim oPath
    
    Set oSelection = oTreeView.Selection.CloneNode(True)
    
    For Each oPath In oSelection.SelectNodes("n[.//n[@ot='Folder' and @id='" & sId & "']]")
        TryRemoveItem oObjectEditor, oPath.GetAttribute("id")
    Next
    
    oSelection.SelectNodes("n[.//n[@ot='Folder' and @id='" & sId & "']]").RemoveAll
    
    Set oTreeView.Selection = oSelection
End Sub

' Попробуем добавить узел в выборку
Sub TryAddItem(oObjectEditor, sId)
    Dim oFolder

    With oObjectEditor
        For Each oFolder in .Pool.GetXmlProperty(.XmlObject, "Folders").ChildNodes
            If .Pool.GetPropertyValue(oFolder, "ObjectID") = sId Then
                Exit Sub
            End If
        Next
        .Pool.AddRelation .XmlObject, "Folders", X_CreateObjectStub("Folder", sId)
    End With
End Sub

' Попробуем убрать узел из выборки
Sub TryRemoveItem(oObjectEditor, sId)
    Dim oFolder

    With oObjectEditor
        For Each oFolder in .Pool.GetXmlProperty(.XmlObject, "Folders").ChildNodes
            If .Pool.GetPropertyValue(oFolder, "ObjectID") = sId Then
                .Pool.RemoveRelation .XmlObject, "Folders", oFolder
                Exit Sub
            End If
        Next
    End With
End Sub

' Обработчик видимости меню дерева выбора папок 
Sub FolderSelectorForCopyFolderStructureMenuVisibilityHandler(oSender, oEventArgs)
    ' Do Nothing
End Sub

' Обработчик выполнения меню дерева выбора папок
Sub FolderSelectorForCopyFolderStructureMenuExecutionHandler(oSender, oEventArgs)
    Select Case oEventArgs.Action
        Case "DoExpandSubTree"
            If Not g_bProcessingSelection Then
                g_bProcessingSelection = True
                If Not Nothing Is oSender.TreeView.ActiveNode Then ExpandNode oSender.TreeView.ActiveNode, False
                g_bProcessingSelection = False
            End If
        Case "DoSelectSubTree"
            If Not g_bProcessingSelection Then
                g_bProcessingSelection = True
                If Not Nothing Is oSender.TreeView.ActiveNode Then 
                    TryAddUpperItems oSender.TreeView.ActiveNode
                    ExpandNode oSender.TreeView.ActiveNode, True 
                End If
                g_bProcessingSelection = False
            End If    
    End Select
End Sub

' Развернуть узел и поддерево и межут быть выделить все эти узлы
Sub ExpandNode(oTreeNode, bForceSelect)
    If oTreeNode Is Nothing Then Exit Sub
    If oTreeNode.IsSelectable And bForceSelect Then If Not oTreeNode.Selected Then oTreeNode.Selected = True
    If Not oTreeNode.IsLeaf Then
        oTreeNode.Expanded = True
		ExpandNodes oTreeNode.Children, bForceSelect
	End If
End Sub

' Развернуть узлы и их поддеревья и может быть выделить все эти узлы
Sub ExpandNodes(oTreeNodes, bForceSelect)
	Dim i
	
	If oTreeNodes Is Nothing Then Exit Sub
	If oTreeNodes.Count=0 Then Exit Sub
	For i=0 To oTreeNodes.Count-1
		ExpandNode oTreeNodes.GetNode(i), bForceSelect
	Next
End Sub