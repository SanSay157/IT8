Option Explicit

Dim g_oPool					' XObjectPool (���������������� � OnLoad � ����� �� ����������)
Dim g_oObjectEditor			' ObjectEditor (���������������� � OnLoad � ����� �� ����������)
Dim g_IncidentTypeID		' ������������� ���� ���������, �� �������� ���������/������� ������ ������� (���������������� � OnLoad � ����� �� ����������)
Dim g_FolderID				' ������������� �����, � ������� ��������� �������� (���������������� � OnLoad � ����� �� ����������)

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	With oSender
		Set g_oPool = .Pool
		Set g_oObjectEditor = oSender
		g_IncidentTypeID = .Pool.GetXmlProperty(.XmlObject, "Incident.Type").firstChild.GetAttribute("oid")
		g_FolderID = .Pool.GetPropertyValue(.XmlObject, "Incident.Folder.ObjectID")
	End With
End Sub


'==============================================================================
' ����� ���� ���������
Sub usr_Task_Role_OnGetRestrictions(oSender, oEventArgs)
	oEventArgs.ReturnValue = "IncidentType=" & g_IncidentTypeID
End Sub


'==============================================================================
' ���������� ��������� ���� ������������
' ��� �������� ������� ������������� ����������� ��������������� �����
Sub usr_Task_Role_OnChanged(oSender, oEventArgs)
	Dim oXmlProp	' xml-��������
	Dim oPE			' �������� �������� "��������������� �����"
	Dim vValue		' �������� ������������ ������� �� ��������� ��� ����
	
	If g_oObjectEditor.IsObjectCreationMode Then
		' ��� ��������� ����, ������� ��������������� �����
		' �������, ��� ���� ���� ����� �� ��������� ����, ������ � ���� ����� �� ��������� ����. ������� - ���������� "���������� ����������� ���������"
		vValue = g_oObjectEditor.Pool.GetPropertyValue( g_oObjectEditor.XmlObject, "Role.DefDuration" )
		If hasValue(vValue) Then
			Set oXmlProp = g_oObjectEditor.XmlObject.selectSingleNode("PlannedTime")
			Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor( oXmlProp )
			oPE.Value = vValue
		End If
	End If
End Sub


'==============================================================================
' ���������� ������� ������������� ����������� � ��������� ��e������ ���������� �������:
' ��������������� �����, ���������� �����. 
' ����������� �� ��������� �������� ������������� �����, � ������� ��������� �������� �������� �������, �
' ������� ������������� ������, � ������� ��������� ������� �����������
Function IsTimeReporting()
	' �����, ��� ��� �������� �������, ����������� ����� ���� ��� �� �����
	
	' TODO
	IsTimeReporting = True
End Function


'==============================================================================
' ���������� ��������������� �����
Function GetPlannedTimeString()
	GetPlannedTimeString = FormatTimeString ( g_oPool.GetPropertyValue(g_oObjectEditor.XmlObject, "PlannedTime") )
End Function 

'==============================================================================
' ���������� ���������� �����
Function GetTimeLeftString()
	GetTimeLeftString = FormatTimeString( g_oPool.GetPropertyValue(g_oObjectEditor.XmlObject, "LeftTime") )
End Function 

'==============================================================================
' ���������� ����������� �����
Function GetSpentTimeString()
	GetSpentTimeString = FormatTimeString ( getTaskTimeSpent(g_oPool, g_oObjectEditor.XmlObject) )
End Function 


'==============================================================================
' ���������� ��������� ���������������� �������
Sub usr_Task_PlannedTime_TimeEditButton_OnChanged(oSender, oEventArgs)
	Dim oXmlPropLeftTime
	Dim nSpentTime
	Dim nLeftTime
	Dim oPE

	' ��� ��������� ���������������� ������� ������� � ���������� �����
	Set oXmlPropLeftTime = g_oObjectEditor.XmlObject.selectSingleNode("LeftTime")
	' ���������� ����� ��������� ��� ������� ���������������� � ������������
	nSpentTime = getTaskTimeSpent(g_oPool, g_oObjectEditor.XmlObject)
	nLeftTime  = CLng(oEventArgs.NewValue) - nSpentTime
	If nLeftTime < 0 Then
		nLeftTime = 0
	End If
	g_oObjectEditor.Pool.SetPropertyValue oXmlPropLeftTime, nLeftTime
	' ��� �������� ������� �������� �������� "���������� �����" �� ������������, ������� ������ ��������� ��������
	If Not g_oObjectEditor.IsObjectCreationMode Then
		Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(oXmlPropLeftTime)
		oPE.SetData
	End If
End Sub

