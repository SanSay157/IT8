Option Explicit

'==============================================================================
Sub FolderList_MenuVisibilityHandler(oSender, oEventArgs)
	Dim sGUID			' As String - идентификатор выбранного объекта
	Dim oNode			' As XMLDOMElement - текущий menu-item
	Dim sAction			' As String - наименования действия(action'a) пункта меню
	
	sGUID = oEventArgs.Menu.Macros.item("ObjectID")
	' Обработаем только известные нам операции
	For Each oNode In oEventArgs.ActiveMenuItems
		sAction = oNode.getAttribute("action")
		Select Case sAction
			Case "DoOpenInTree"
				If IsNull(sGUID) Then
					oNode.setAttribute "hidden", "1"
				Else
					oNode.removeAttribute "hidden"
				End If
		End Select
	Next
End Sub


'==============================================================================
Sub FolderList_MenuExecutionHandler(oSender, oEventArgs)	
	Select Case oEventArgs.Action
		' "Переместиться в дерево"
		Case "DoOpenInTree"
			OpenFindFolderInTree oEventArgs.Menu.Macros.item("ObjectID")
	End Select
End Sub
