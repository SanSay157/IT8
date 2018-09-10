Option Explicit


'==============================================================================
' �������� ��� ����� ������ �� ��������
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim oValueRoleA
	Dim oValueRoleB
	
	' ��������, ��� � ��������� RoleA � RoleB ������ �� ������ ���������
	' ����������: �.�. ���� �������� ������ ��� ��������, � ������ ������ ������, �.�. ��� not null, �� �������������� �������� �� ������
	Set oValueRoleA = oSender.XmlObject.selectSingleNode("RoleA").firstChild
	Set oValueRoleB = oSender.XmlObject.selectSingleNode("RoleB").firstChild
	If oValueRoleA.getAttribute("oid") = oValueRoleB.getAttribute("oid") Then
		oEventArgs.ErrorMessage = "����� �� ����� ���� ����������� ����� ����� � ��� �� ����������"
		oEventArgs.ReturnValue = False
	End If
End Sub


