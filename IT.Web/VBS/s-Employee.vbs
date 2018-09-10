Option Explicit

Dim g_bIsHomeOrganization		' As Boolean - ������� ����, ��� ����� ����������� "������" �����������
Dim g_bEmployeeRateIsZero       ' As Boolean - ������� ����, ��� "����� �������� ���" ���� ��������

g_bEmployeeRateIsZero = False
'==============================================================================
'	[in] oSender As ObjectEditor
'	[in] oEventArgs As Nothing
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Dim oSysUser	' IXMLDOMElement - xml-������ ������������ (SystemUser)
	
	g_bIsHomeOrganization = CBool( oSender.QueryString.GetValueInt("IsHomeOrg", 0) )
	On Error Resume Next
	If oSender.IsObjectCreationMode Then
		Set oSysUser = oSender.Pool.CreateXmlObjectInPool("SystemUser")
		oSender.Pool.AddRelation oSender.XmlObject, "SystemUser", oSysUser
	End If
End Sub


'==============================================================================
Function IsForeignOrganization
	IsForeignOrganization = Not g_bIsHomeOrganization
End Function


'==============================================================================
Function IsHomeOrganization
	IsHomeOrganization = g_bIsHomeOrganization
End Function


'==============================================================================
' ����� O�����
Sub usr_Employee_Department_OnGetRestrictions(oSender, oEventArgs)
	Dim oPE
	Dim oOrganization
	' ����������� ����������� �� ���������� ����� - �� ������ ��������� � ������� �����������
	Set oPE = oSender.ParentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("Organization") )
	Set oOrganization = oPE.Value
	If Not oOrganization Is Nothing Then
		oEventArgs.ReturnValue = "OrganizationID=" & oOrganization.getAttribute("oid")
	End If
End Sub


'==============================================================================
' ����� ��������� O�����
Sub usr_Employee_Department_OnBeforeCreate(oSender, oEventArgs)
	Dim oPE
	Dim oOrganization
	' ����������� ����������� �� ���������� ����� - �� ������ ��������� � ������� �����������
	Set oPE = oSender.ParentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("Organization") )
	Set oOrganization = oPE.Value
	If oOrganization Is Nothing Then Err.Raise -1, "usr_Employee_Department_OnBeforeCreate", "����������� ������ ���� ������ ������"
	' �������������� ������ �� ����������� ������������ ������ � ����������� ��
	oEventArgs.UrlArguments = ".Organization=" & oOrganization.getAttribute("oid") & "&@Organization=disabled:1"
End Sub


'==============================================================================
'	����� ������� ����������� �������� ������� ��������
'	[in] oEventArgs AS SelectEventArgsClass
Sub usr_Employee_Organization_OnBeforeSelect(oSender, oEventArgs)
	' �������� ���������� ��������
	oEventArgs.OperationValues.item("_OLDVALUE") = "" & oSender.ParentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("Department") ).ValueID
End Sub


'==============================================================================
'	����� ������ ����������� ������� �������� �������� "�����"
'	[in] oEventArgs AS SelectEventArgsClass
Sub usr_Employee_Organization_OnAfterSelect(oSender, oEventArgs)
	Dim oPE
	' ���� ��������� �������� (Selection ������ �� ����) ���������� �� �����������, �� ������� �������� ����� 
	If oEventArgs.OperationValues.item("_OLDVALUE") <> oEventArgs.Selection Then
		Set oPE = oSender.ParentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("Department") )
		oPE.ValueID = Null
	End If
End Sub
