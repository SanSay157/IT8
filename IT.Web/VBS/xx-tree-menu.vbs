Sub XXTreeViewShowContextMenu(oSender, oTreeView, oTreeNode, oMenuXml)
    Dim sPath           ' Путь переносимого узла
    Dim aPath           ' Путь переносимого узла в виде массива
    Dim oMenu           ' Меню
    
    ' Определим, где будем показывать меню
    Dim nPosLeft, nPosTop, nPosRight, nPosBottom
    Dim nTreeViewPosX, nTreeViewPosY	' экранные координаты TreeView
	Dim nPendingMenuPosX				'- Экранная Х-координата точки показа PopUp меню, после того как оно будет загружено
	Dim nPendingMenuPosY				'- Экранная Y-координата точки показа PopUp меню, после того как оно будет загружено
	
    If HasValue(oMenuXml) Then
	    ' Если "отпускаем" в узел, то покажем рядом с ним
	    If HasValue(oTreeNode) Then
	        If oTreeNode.GetCoords(nPosLeft, nPosTop, nPosRight, nPosBottom) Then
		        X_GetHtmlElementScreenPos oTreeView, nTreeViewPosX, nTreeViewPosY
		        nPendingMenuPosX = nTreeViewPosX + nPosLeft
		        nPendingMenuPosY = nTreeViewPosY + nPosBottom
	        End If
	    End If
        Set oMenu = New MenuClass
        oMenu.Init oMenuXml        
        oMenu.ShowPopupMenuWithPos oSender, nPendingMenuPosX, nPendingMenuPosY                
    End If
End Sub