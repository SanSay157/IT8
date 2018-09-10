Option Explicit


'==============================================================================
' ExecutionHandler меню узлов типа Employee, Department, Organization
Sub CompanyTree_Menu_ExecutionHandler(oSender, oEventArg)
	Dim oActiveNode
    Set oActiveNode = oSender.TreeView.ActiveNode
	Select Case oEventArg.Action
		Case "DoRunReport"
			X_RunReport oEventArg.Menu.Macros.Item("ReportName"), oEventArg.Menu.Macros.Item("UrlParams")
	End Select
End Sub


