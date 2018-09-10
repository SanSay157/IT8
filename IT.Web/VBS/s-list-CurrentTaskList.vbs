Option Explicit


'==============================================================================
' Стандартный обработчик события OnAfterEdit
'	[in] oEventArg AS CommonEventArgsClass - параметры события
Sub usrXList_OnAfterEdit(oXList, oEventArg)
	Dim sRestrictions
	Dim oListData
	Dim oRow
	Dim oXmlRow
	Dim nRowIndex
	' ReturnValue говорит об успехе
	' ObjectID - идентификатор объекта

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
				If Nothing Is oRow Then Err.Raise -1, "", "Не удалось получить отредактированную строку"
				Set oXmlRow = oListData.selectSingleNode("RS/R")
				If oXmlRow Is Nothing Then
					' объект исчез из списка - удалим строку
					nRowIndex = oRow.Index
					oXList.ListView.Rows.Remove nRowIndex
					If nRowIndex > 0 Then
						' если последняя удаленная запись была в списке не первой, то поставим фокус на запись перед ней
						oXList.ListView.Rows.SelectedPosition  = nRowIndex - 1
					ElseIf oXList.ListView.Rows.Count > 0 Then
						' иначе, если была первой и список не пуст, то поставим фокус на первую запись
						oXList.ListView.Rows.SelectedPosition = 0
					End If
					
				Else
					' иначе обновим значения колонок
					oXList.UpdateRow oRow, oXmlRow
				End If
			End If
			' установим курсор на отредактированную строку
			oXList.SelectRowByObjectID .ObjectID
			' обновим табло несписанного времени
			ReloadUserCurrentExpensesPanel
		End If
	End With
	oXList.SetListFocus
End Sub


'==============================================================================
Sub CurrentTaskList_MenuVisibilityHandler(oSender, oEventArgs)
	Dim sType			' As String - наименование типа выбранного объекта
	Dim sGUID			' As String - идентификатор выбранного объекта
	Dim oNode			' As XMLDOMElement - текущий menu-item
	Dim sAction			' As String - наименования действия(action'a) пункта меню
	
	sType = oEventArgs.Menu.Macros.item("ObjectType")
	sGUID = oEventArgs.Menu.Macros.item("ObjectID")
	' Обработаем только известные нам операции
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
		' "Затратить время"
		Case "DoCreateTimeSpent"
			' Создадим объек TimeSPent, ссылающийся на Задание (Task) текущего сотрудника в выбранном инциденте.
			' Идентификатор Задания находится в колонке OwnTaskID
			sTaskID = oEventArgs.Menu.Macros.item("OwnTaskID")
			If Len("" & sTaskID) > 0 Then
				If hasValue(X_OpenObjectEditor("TimeSpent", Null, "", ".Task=" & sTaskID)) Then
					' обновим табло несписанного времени
					ReloadUserCurrentExpensesPanel
				End If
			End If
		' "Переместиться в дерево"
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
' Обновляет табло несписанного времение. 
' ВНИМАНИЕ: использует лобальных идентификатор behavior'a
Sub ReloadUserCurrentExpensesPanel
	UserCurrentExpensesPanel.Reload
End Sub
