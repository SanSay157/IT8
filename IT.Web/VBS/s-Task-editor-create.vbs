Option Explicit

' ВНИМАНИЕ: используются глобальные переменные, объявленные в s-Task-editor.vbs:
'	g_IncidentTypeID	- идентификатор типа инцидента, по которому создается/создано данное задание (устанавливается в OnLoad и не изменяется)
'	g_FolderID			- идентификатор папки, в которой находится инцидент (устанавливается в OnLoad и не изменяется)


'==============================================================================
' Ограничения для списка исполнителей
Sub usr_Task_Worker_OnGetRestrictions(oSender, oEventArgs)
	Dim oTask          'объект "Задание" 
	With oSender.ObjectEditor
		' Обязательный параметр - идентификатор текущей папки
		' Примечание: ссылка на Папку для инцидента всегда задана
		oEventArgs.ReturnValue = "FolderID=" & g_FolderID
		' Исключим сотрудников, у которых уже есть задания по данному инциденту
		For Each oTask In .Pool.GetXmlProperty(.XmlObject, "Incident.Tasks").childNodes
			oEventArgs.ReturnValue = oEventArgs.ReturnValue & "&IgnoreEmployeeID=" & .Pool.GetPropertyValue(oTask, "Worker.ObjectID")
		Next
	End With
End Sub

'==============================================================================
' Ограничения для дерева исполнителей
Sub usr_Task_Worker_OnGetSelectorRestrictions(oSender, oEventArgs)
	Dim sIgnoreObjectID   'строка с идентификатором исключаемого объекта (Сотрудника)
	Dim sIgnoreObjectIDs  'список идентификаторов sIgnoreObjectID, разделенных ;
	Dim oTask             'объект "Задание"
	With oSender.ObjectEditor
		oEventArgs.ReturnValue = "" 
		' Исключим сотрудников, у которых уже есть задания по данному инциденту
		For Each oTask In .Pool.GetXmlProperty(.XmlObject, "Incident.Tasks").childNodes
			sIgnoreObjectID = .Pool.GetPropertyValue(oTask, "Worker.ObjectID")
			If HasValue(sIgnoreObjectID) Then
				If 0<>len(sIgnoreObjectIDs) Then
					sIgnoreObjectIDs = sIgnoreObjectIDs & ";"
				End If
				sIgnoreObjectIDs = sIgnoreObjectIDs & sIgnoreObjectID
			End If
		Next
		If 0<>len(sIgnoreObjectIDs) Then
			oEventArgs.ReturnValue = "IgnoreEmployeeID=" & Replace(sIgnoreObjectIDs,";", "&IgnoreEmployeeID=")
			oEventArgs.UrlParams = "IgnoreEmployeeIDs=" & sIgnoreObjectIDs
		End If
	End With
End Sub

'==============================================================================
' Проверка допустимости выбора сотрудника из дереве
Sub usr_Task_Worker_OnValidateSelection(oSender, oEventArgs)
	Dim oTask   'объект "Задание"
	' Проверим, что для выбранного сотрудника нет уже Задания в инциденте
	' Это необходимо в дополнении к обработчику usr_Task_Worker_OnGetRestrictions, т.к. сотрудник мог выбираться из дерева, где нет ограничений
	With oSender.ObjectEditor
		For Each oTask In .Pool.GetXmlProperty(.XmlObject, "Incident.Tasks").childNodes
			If oEventArgs.Selection = .Pool.GetPropertyValue(oTask, "Worker.ObjectID") Then
				MsgBox "Для выбранного сотрудника уже создано задание", vbOkOnly + vbExclamation
				oEventArgs.ReturnValue = False
			End If
		Next
	End With
End Sub


'==============================================================================
' Обработчик выбора сотрудника в списке (в том числе и после выбора из дерева - происходит автоматически)
Sub usr_Task_Worker_OnSelected(oSender, oEventArgs)
	Dim sRoleID 'идентификатор объекта UserRoleInIncident (роли в инци-те по умолчанию)
	Dim oPE     'редактор свойства Role типа "Task" 

	sRoleID = GetScalarValueFromDataSource("GetDefaultIncidentRole", Array("FolderID", "EmployeeID", "IncidentTypeID"), Array(g_FolderID,oEventArgs.NewValue,g_IncidentTypeID))
	If Len("" & sRoleID) > 0 Then
		Set oPE = oSender.ObjectEditor.CurrentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("Role") )
		oPE.ValueID = sRoleID
	End If
End Sub

