Option Explicit

Dim g_sIncidentID		' »дентификатор инцидента, редактор которого надо открыть
Dim g_bOpenEditor		' ѕризнак открывать редактор после перезагрузки списка

'==============================================================================
Sub usrXListPage_OnLoad(oSender, oEventArgs)
	
	
	g_sIncidentID = oSender.QueryString.GetValue("OpenEditorByIncidentID", Null)
	If hasValue(g_sIncidentID) Then
		g_bOpenEditor = True
		If Len(oSender.XList.Restrictions) > 0 Then
			oSender.XList.Restrictions = oSender.XList.Restrictions & "&"
		End If
		oSender.XList.Restrictions = "IncidentID=" & g_sIncidentID
		oSender.XList.Reload()
	End If
End Sub


'==============================================================================
Sub usrXList_OnAfterListReload(oSender, oEventArgs)
	Dim oRow
	
	If g_bOpenEditor Then
		If oSender.ListView.Rows.Count > 0 Then
			Set oRow = oSender.ListView.Rows.GetRow(0)
			If Not oRow Is Nothing Then
				If LCase(oRow.ID) = LCase(g_sIncidentID) Then
					g_bOpenEditor = False
					if hasValue(X_OpenObjectEditor("Incident", g_sIncidentID, "", "")) then oSender.Reload()
				End If
			End If
		End If
	End If
End Sub