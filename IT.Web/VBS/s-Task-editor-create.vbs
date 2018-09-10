Option Explicit

' ��������: ������������ ���������� ����������, ����������� � s-Task-editor.vbs:
'	g_IncidentTypeID	- ������������� ���� ���������, �� �������� ���������/������� ������ ������� (��������������� � OnLoad � �� ����������)
'	g_FolderID			- ������������� �����, � ������� ��������� �������� (��������������� � OnLoad � �� ����������)


'==============================================================================
' ����������� ��� ������ ������������
Sub usr_Task_Worker_OnGetRestrictions(oSender, oEventArgs)
	Dim oTask          '������ "�������" 
	With oSender.ObjectEditor
		' ������������ �������� - ������������� ������� �����
		' ����������: ������ �� ����� ��� ��������� ������ ������
		oEventArgs.ReturnValue = "FolderID=" & g_FolderID
		' �������� �����������, � ������� ��� ���� ������� �� ������� ���������
		For Each oTask In .Pool.GetXmlProperty(.XmlObject, "Incident.Tasks").childNodes
			oEventArgs.ReturnValue = oEventArgs.ReturnValue & "&IgnoreEmployeeID=" & .Pool.GetPropertyValue(oTask, "Worker.ObjectID")
		Next
	End With
End Sub

'==============================================================================
' ����������� ��� ������ ������������
Sub usr_Task_Worker_OnGetSelectorRestrictions(oSender, oEventArgs)
	Dim sIgnoreObjectID   '������ � ��������������� ������������ ������� (����������)
	Dim sIgnoreObjectIDs  '������ ��������������� sIgnoreObjectID, ����������� ;
	Dim oTask             '������ "�������"
	With oSender.ObjectEditor
		oEventArgs.ReturnValue = "" 
		' �������� �����������, � ������� ��� ���� ������� �� ������� ���������
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
' �������� ������������ ������ ���������� �� ������
Sub usr_Task_Worker_OnValidateSelection(oSender, oEventArgs)
	Dim oTask   '������ "�������"
	' ��������, ��� ��� ���������� ���������� ��� ��� ������� � ���������
	' ��� ���������� � ���������� � ����������� usr_Task_Worker_OnGetRestrictions, �.�. ��������� ��� ���������� �� ������, ��� ��� �����������
	With oSender.ObjectEditor
		For Each oTask In .Pool.GetXmlProperty(.XmlObject, "Incident.Tasks").childNodes
			If oEventArgs.Selection = .Pool.GetPropertyValue(oTask, "Worker.ObjectID") Then
				MsgBox "��� ���������� ���������� ��� ������� �������", vbOkOnly + vbExclamation
				oEventArgs.ReturnValue = False
			End If
		Next
	End With
End Sub


'==============================================================================
' ���������� ������ ���������� � ������ (� ��� ����� � ����� ������ �� ������ - ���������� �������������)
Sub usr_Task_Worker_OnSelected(oSender, oEventArgs)
	Dim sRoleID '������������� ������� UserRoleInIncident (���� � ����-�� �� ���������)
	Dim oPE     '�������� �������� Role ���� "Task" 

	sRoleID = GetScalarValueFromDataSource("GetDefaultIncidentRole", Array("FolderID", "EmployeeID", "IncidentTypeID"), Array(g_FolderID,oEventArgs.NewValue,g_IncidentTypeID))
	If Len("" & sRoleID) > 0 Then
		Set oPE = oSender.ObjectEditor.CurrentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("Role") )
		oPE.ValueID = sRoleID
	End If
End Sub

