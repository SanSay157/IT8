Option Explicit

Dim g_bIsHomeOrganization		' As Boolean - ������� ����, ��� ����� ����������� "������" �����������

'==============================================================================
'	[in] oSender As ObjectEditor
'	[in] oEventArgs As Nothing
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	' ��������, ��� ������ �����������
	If oSender.IsObjectCreationMode Then
		If Not oSender.GetProp("Organization").hasChildNodes Then
			Err.Raise -1, "usrXEditor_OnLoad", "��� �������� ������ ������ ���� ������ ������ �� �����������"
		End If
	End If
	g_bIsHomeOrganization = CBool( oSender.QueryString.GetValueInt("IsHomeOrg", 0) )
End Sub


'==============================================================================
'	[in] oSender As ObjectEditor
'	[in] oEventArgs As Nothing
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	Dim oPE
	' ���� ������ ����������� �����������, �� ��� ������ "�����"
	If oSender.IsObjectCreationMode AND IsHomeOrganization Then
		If oSender.GetProp("Parent").hasChildNodes Then
			Set oPE = oSender.CurrentPage.GetPropertyEditor( oSender.GetProp("Type") )
			oPE.Value = DEPARTMENTTYPE_DIRECTION
			oSender.CurrentPage.EnablePropertyEditor oPE, false
		End If
	End If
End Sub


'==============================================================================
' ����� ������������ ������
Sub usr_Department_Director_OnGetRestrictions(oSender, oEventArgs)
	oEventArgs.ReturnValue = "Department=" & oSender.ObjectEditor.ObjectID
End Sub


'==============================================================================
' �������� ������������ ������
Sub usr_Department_Children_OnBeforeCreate(oSender, oEventArgs)
	' ����������: �������� Organization ����� ���������, ��������� � usrXEditor_OnLoad
	oEventArgs.UrlArguments = ".Organization=" & oSender.ObjectEditor.GetProp("Organization").firstChild.getAttribute("oid")
End Sub


'==============================================================================
Function IsForeignOrganization
	IsForeignOrganization = Not g_bIsHomeOrganization
End Function


'==============================================================================
Function IsHomeOrganization
	IsHomeOrganization = g_bIsHomeOrganization
End Function
