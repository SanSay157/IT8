Option Explicit

Sub TmsOrganizations_VisibilityHandler(oSender, oEventArgs)
    Dim oNode
    For Each oNode in oEventArgs.ActiveMenuItems
        Select Case oNode.GetAttribute("action")
            Case "ShowHistory"
                If Not HasValue(oEventArgs.Menu.Macros.item("ObjectID")) Then
                    oNode.SetAttribute "hidden", 1
                End If
        End Select
    Next
End Sub

Sub TmsOrganizations_ExecuteHandler(oSender, oEventArgs)
    Select Case oEventArgs.Action
        Case "ShowHistory"
                X_RunReport "OrganizationHistory", "Organization=" & oEventArgs.Menu.Macros.item("ObjectID")
    End Select
End Sub