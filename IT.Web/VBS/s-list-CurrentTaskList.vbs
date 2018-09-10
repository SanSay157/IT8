Option Explicit


'==============================================================================
' ����������� ���������� ������� OnAfterEdit
'	[in] oEventArg AS CommonEventArgsClass - ��������� �������
Sub usrXList_OnAfterEdit(oXList, oEventArg)
	Dim sRestrictions
	Dim oListData
	Dim oRow
	Dim oXmlRow
	Dim nRowIndex
	' ReturnValue ������� �� ������
	' ObjectID - ������������� �������

	With oEventArg
		If .ReturnValue Then
			On Error Resume Next
			sRestrictions = "IncidentID=" & .ObjectID
			Set oListData = X_GetListDataFromServer("Incident", oXList.Container.MetaName, X_CreateListLoaderRestrictions(sRestrictions, Null, Null) )
			If Err Then
				Alert Err.Description
			ElseIf Not oListData Is Nothing Then
				On Error GoTo 0
				Set oRow = oXList.ListView.Rows.FindRowByID(.ObjectID)
				If Nothing Is oRow Then Err.Raise -1, "", "�� ������� �������� ����������������� ������"
				Set oXmlRow = oListData.selectSingleNode("RS/R")
				If oXmlRow Is Nothing Then
					' ������ ����� �� ������ - ������ ������
					nRowIndex = oRow.Index
					oXList.ListView.Rows.Remove nRowIndex
					If nRowIndex > 0 Then
						' ���� ��������� ��������� ������ ���� � ������ �� ������, �� �������� ����� �� ������ ����� ���
						oXList.ListView.Rows.SelectedPosition  = nRowIndex - 1
					ElseIf oXList.ListView.Rows.Count > 0 Then
						' �����, ���� ���� ������ � ������ �� ����, �� �������� ����� �� ������ ������
						oXList.ListView.Rows.SelectedPosition = 0
					End If
					
				Else
					' ����� ������� �������� �������
					oXList.UpdateRow oRow, oXmlRow
				End If
			End If
			' ��������� ������ �� ����������������� ������
			oXList.SelectRowByObjectID .ObjectID
			' ������� ����� ������������ �������
			ReloadUserCurrentExpensesPanel
		End If
	End With
	oXList.SetListFocus
End Sub


'==============================================================================
Sub CurrentTaskList_MenuVisibilityHandler(oSender, oEventArgs)
	Dim sType			' As String - ������������ ���� ���������� �������
	Dim sGUID			' As String - ������������� ���������� �������
	Dim oNode			' As XMLDOMElement - ������� menu-item
	Dim sAction			' As String - ������������ ��������(action'a) ������ ����
	
	sType = oEventArgs.Menu.Macros.item("ObjectType")
	sGUID = oEventArgs.Menu.Macros.item("ObjectID")
	' ���������� ������ ��������� ��� ��������
	For Each oNode In oEventArgs.ActiveMenuItems
		sAction = oNode.getAttribute("action")
		Select Case sAction
			Case "DoCreateTimeSpent", "DoOpenInTree", "DoCreateMail", _
				"DoCopyNumberToClipboard", "DoCopyNameToClipboard", "DoCopyFolderPathToClipboard", "DoCopyReportURLToClipboard"
				If IsNull(sGUID) Then
					oNode.setAttribute "hidden", "1"
				Else
					oNode.removeAttribute "hidden"
				End If
		End Select
	Next
End Sub


'==============================================================================
Sub CurrentTaskList_MenuExecutionHandler(oSender, oEventArgs)
	Dim sTaskID
	Dim oField
	
	Select Case oEventArgs.Action
		' "��������� �����"
		Case "DoCreateTimeSpent"
			' �������� ����� TimeSPent, ����������� �� ������� (Task) �������� ���������� � ��������� ���������.
			' ������������� ������� ��������� � ������� OwnTaskID
			sTaskID = oEventArgs.Menu.Macros.item("OwnTaskID")
			If Len("" & sTaskID) > 0 Then
				If hasValue(X_OpenObjectEditor("TimeSpent", Null, "", ".Task=" & sTaskID)) Then
					' ������� ����� ������������ �������
					ReloadUserCurrentExpensesPanel
				End If
			End If
		' "������������� � ������"
		Case "DoOpenInTree"
			OpenFindIncidentInTreeByID oEventArgs.Menu.Macros.item("ObjectID")
		Case "DoCreateMail"
			MailIncidentLinkToAll oEventArgs.Menu.Macros.item("ObjectID")
		Case "DoCopyNumberToClipboard"
			Set oField = oSender.ListView.Rows.GetRow( oSender.ListView.Rows.Selected ).GetFieldByName("IncidentNumber")
			window.clipboardData.setData "Text", oField.Text
		Case "DoCopyNameToClipboard"
			Set oField = oSender.ListView.Rows.GetRow( oSender.ListView.Rows.Selected ).GetFieldByName("IncidentName")
			window.clipboardData.setData "Text", oField.Text
		Case "DoCopyFolderPathToClipboard"
			Set oField = oSender.ListView.Rows.GetRow( oSender.ListView.Rows.Selected ).GetFieldByName("FolderPath")
			window.clipboardData.setData "Text", oField.Text
		Case "DoCopyReportURLToClipboard"
			window.clipboardData.setData "Text", XService.BaseURL & "/x-get-report.aspx?NAME=r-Incident.xml&DontCacheXslfo=true&IncidentID=" & oSender.ListView.Rows.GetRow( oSender.ListView.Rows.Selected ).ID
	End Select
End Sub


'==============================================================================
' ��������� ����� ������������ ��������. 
' ��������: ���������� ��������� ������������� behavior'a
Sub ReloadUserCurrentExpensesPanel
	UserCurrentExpensesPanel.Reload
End Sub
