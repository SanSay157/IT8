Option Explicit

Sub Document_OnKeyUp
    Dim arrArgs
	If IsEmpty(X_GetDialogArguments(arrArgs)) Then Exit Sub
	If window.event.keyCode <> VK_ESC Then Exit Sub
	window.close
End Sub

Sub DoOperation(sAction, nEventClass)
	
	With New UserSubscriptionForEventClassRequest
		.m_sName = "UserSubscriptionForEventClass"
		.m_sAction = sAction
		.m_nEventClass = nEventClass
		X_ExecuteCommand( .Self )
	End With
End Sub

'<i:menu-item action="DoDigestThis" t="���� �������� ���������� �� ���� ������� � ���� ���������"/>
'<i:menu-item action="DoUnsubscribeThis" t="�� ���� �������� ���������� �� ���� �������"/>
'<i:menu-item action="DoResetThis" t="���������� �������� �� ������ ������� �� ���������"/>
'<i:menu-item-separ/>
'<i:menu-item action="DoDigestAll" t="���� �������� ���������� �������� � ���� ���������"/>
'<i:menu-item action="DoUnsubscribeAll" t="�� ���� �������� ���������� � ��������"/>
'<i:menu-item action="DoResetAll" t="���������� �������� ������� �� ���������"/>

Sub MenuExecutionHandler_ForEventClass(oSender, oEventArgs)
	Dim nEventClass
	Dim oActiveNode
	Dim oParentNode
	Set oActiveNode = oSender.TreeView.ActiveNode
	If oActiveNode Is Nothing Then
		Set oParentNode = Nothing
	Else
		Set oParentNode = oActiveNode.Parent
	End If
	nEventClass = oEventArgs.Menu.Macros.Item("EventClass")
	Select Case oEventArgs.Action
		Case "DoDigestThis"
			If Confirm("��� ������� ��� ��������� ��� ������� """ & NameOf_EventClass(nEventClass) & """, �� �������?") Then
				DoOperation "SwitchToDigestOnly", nEventClass
				DoRefreshTree TRM_CHILDS+TRM_NODE+TRM_PARENTNODES, oActiveNode, oParentNode			
			End If
		Case "DoUnsubscribeThis"
			If Confirm("��� ������� ��� ��������� ��� ������� """ & NameOf_EventClass(nEventClass) & """, �� �������?") Then
				DoOperation "Unsubscribe", nEventClass
				DoRefreshTree TRM_CHILDS+TRM_NODE+TRM_PARENTNODES, oActiveNode, oParentNode			
			End If
		Case "DoResetThis"
			If Confirm("��� ������� ��� ��������� ��� ������� """ & NameOf_EventClass(nEventClass) & """, �� �������?") Then
				DoOperation "ResetToDefaults", nEventClass
				DoRefreshTree TRM_CHILDS+TRM_NODE+TRM_PARENTNODES, oActiveNode, oParentNode			
			End If
		Case "DoDigestAll"
			If Confirm("��� ������� ��� ��������� ��� ���� �������, �� �������?") Then
				DoOperation "SwitchToDigestOnly", 0
				DoRefreshTree TRM_TREE, oActiveNode, oParentNode			
			End If
		Case "DoUnsubscribeAll"
			If Confirm("��� ������� ��� ��������� ��� ���� �������, �� �������?") Then
				DoOperation "Unsubscribe", 0
				DoRefreshTree TRM_TREE, oActiveNode, oParentNode			
			End If
		Case "DoResetAll"
			If Confirm("��� ������� ��� ��������� ��� ���� �������, �� �������?") Then
				DoOperation "ResetToDefaults", 0
				DoRefreshTree TRM_TREE, oActiveNode, oParentNode			
			End If
	End Select
End Sub

