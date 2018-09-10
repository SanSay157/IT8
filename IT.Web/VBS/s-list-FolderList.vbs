Option Explicit

'==============================================================================
Sub FolderList_MenuVisibilityHandler(oSender, oEventArgs)
	Dim sGUID			' As String - ������������� ���������� �������
	Dim oNode			' As XMLDOMElement - ������� menu-item
	Dim sAction			' As String - ������������ ��������(action'a) ������ ����
	
	sGUID = oEventArgs.Menu.Macros.item("ObjectID")
	' ���������� ������ ��������� ��� ��������
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
		' "������������� � ������"
		Case "DoOpenInTree"
			OpenFindFolderInTree oEventArgs.Menu.Macros.item("ObjectID")
	End Select
End Sub
