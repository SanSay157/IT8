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

'<i:menu-item action="DoDigestThis" t="Хочу получать информацию об этом событии в виде дайджеста"/>
'<i:menu-item action="DoUnsubscribeThis" t="Не хочу получать информацию об этом событии"/>
'<i:menu-item action="DoResetThis" t="Установить подписку на данное событие по умолчанию"/>
'<i:menu-item-separ/>
'<i:menu-item action="DoDigestAll" t="Хочу получать информацию событиях в виде дайджеста"/>
'<i:menu-item action="DoUnsubscribeAll" t="Не хочу получать информацию о событиях"/>
'<i:menu-item action="DoResetAll" t="Установить подписку события по умолчанию"/>

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
			If Confirm("Это изменит ВСЕ настройки для события """ & NameOf_EventClass(nEventClass) & """, вы уверены?") Then
				DoOperation "SwitchToDigestOnly", nEventClass
				DoRefreshTree TRM_CHILDS+TRM_NODE+TRM_PARENTNODES, oActiveNode, oParentNode			
			End If
		Case "DoUnsubscribeThis"
			If Confirm("Это изменит ВСЕ настройки для события """ & NameOf_EventClass(nEventClass) & """, вы уверены?") Then
				DoOperation "Unsubscribe", nEventClass
				DoRefreshTree TRM_CHILDS+TRM_NODE+TRM_PARENTNODES, oActiveNode, oParentNode			
			End If
		Case "DoResetThis"
			If Confirm("Это изменит ВСЕ настройки для события """ & NameOf_EventClass(nEventClass) & """, вы уверены?") Then
				DoOperation "ResetToDefaults", nEventClass
				DoRefreshTree TRM_CHILDS+TRM_NODE+TRM_PARENTNODES, oActiveNode, oParentNode			
			End If
		Case "DoDigestAll"
			If Confirm("Это изменит ВСЕ настройки для ВСЕХ событий, вы уверены?") Then
				DoOperation "SwitchToDigestOnly", 0
				DoRefreshTree TRM_TREE, oActiveNode, oParentNode			
			End If
		Case "DoUnsubscribeAll"
			If Confirm("Это изменит ВСЕ настройки для ВСЕХ событий, вы уверены?") Then
				DoOperation "Unsubscribe", 0
				DoRefreshTree TRM_TREE, oActiveNode, oParentNode			
			End If
		Case "DoResetAll"
			If Confirm("Это изменит ВСЕ настройки для ВСЕХ событий, вы уверены?") Then
				DoOperation "ResetToDefaults", 0
				DoRefreshTree TRM_TREE, oActiveNode, oParentNode			
			End If
	End Select
End Sub

