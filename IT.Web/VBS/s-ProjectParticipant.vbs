'==============================================================================
' �������� ���� �� ������������ ���� "�������� ��������"
Option Explicit
Dim g_nPrivileges ' ���������� ������������
Dim g_oRolesBefore
Dim g_bReturnValue

g_bReturnValue = True
' ��������� �������� ��������� 
Sub usrXEditor_OnLoad( oSender, oEventArgs )
    Dim aUserInfo ' ������ �� ������������ � ��� ������
	' ������ ���������� � ������� ������������ � �������
	aUserInfo = GetFirstRowValuesFromDataSource("HomePage-GetCurrentEmployeeInfo", Null, Null)
	g_nPrivileges = CLng(aUserInfo(5))
	
	With oSender
	    If .IsObjectCreationMode Then
	        Dim oEmployment
	        Set oEmployment = .Pool.CreateXmlObjectInPool("EmploymentParticipantProject")
	        If Not(HasValue(oEmployment)) THen
	            Err.Raise vbObjectError, "usrXEditor_OnLoad", "�� ������� ������� ��������� ��� ������ ����������"
	        End If
	        .Pool.SetPropertyValue .Pool.GetXmlProperty(oEmployment, "DateBegin"), Date()
	        .Pool.SetPropertyValue .Pool.GetXmlProperty(oEmployment, "DateEnd"), DateAdd("m", 1, Date())
	        .Pool.SetPropertyValue .Pool.GetXmlProperty(oEmployment, "Percent"), 100
	        .Pool.AddRelation oEmployment, "ProjectParticipant", .XmlObject
	    End If
	End With
	
End Sub

' ��������� �������� ������ ���������� �������
Sub usr_ProjectParticipant_Roles_ObjectsSelector_OnLoadList(oSender, oEventArgs)
    ' �������� ���� �� ��������������
    Set g_oRolesBefore = oSender.XmlProperty.cloneNode(true)
End Sub 

' ��������� ������
Sub usrXEditor_OnValidatePage( oSender, oEventArgs )
    Dim oRoles ' 
    Dim oRole
    Dim nPrivilegesOnRole ' ���������� �� ������ ����
    Dim oRoleInObject ' ���� ������������ � ������� (Roles/UserRoleInProject)
    Dim oRolesInPool ' ���� ������������ � �����, ����������� � ���
    ' �������� ���� 
    Set oRoles = oSender.Pool.GetXmlObjectsByOPath(oSender.XmlObject, "Roles")
    If Not (oRoles Is Nothing) Then
   	    For Each oRole In oRoles
   	        ' �������� ����������� ����������
   	        nPrivilegesOnRole = oRole.SelectSingleNode("SystemPrivilegesOnRole").nodeTypedValue
   	        If nPrivilegesOnRole <> 0 Then
   	            Set oRoleInObject = g_oRolesBefore.selectSingleNode("UserRoleInProject" & "[@oid='" & oRole.getAttribute("oid") & "']")
   	            ' ���� ���� � ������������ ���� �� ��������������, �� �� ����� ��������� ����������� ����� �� ������ ���� ����
   	            If (oRoleInObject Is Nothing) Then
   	                If (nPrivilegesOnRole And g_nPrivileges) = 0 Then 
   	                    oEventArgs.Cancel = True
   	                    oEventArgs.ReturnValue = False
   	                    oEventArgs.ErrorMessage = "� ��� ��� ���� �� ������ ���� " & oRole.SelectSingleNode("Name").nodeTypedValue
   	                    'Exit Sub
   	                End If
   	            End If
       	            
   	        End If
   	    Next
   	End If
   	' ������ ��������� �� ����, ������� ���� ���������� � ���, �� � ����� ���� ������� �� ������� 	
   	Set oRolesInPool = g_oRolesBefore.selectNodes("UserRoleInProject")
   	If Not (oRolesInPool Is Nothing) Then
   	    For Each oRole in oRolesInPool
   	        nPrivilegesOnRole = oSender.XmlObjectPool.SelectSingleNode("UserRoleInProject" & "[@oid='" & oRole.getAttribute("oid") & "']/SystemPrivilegesOnRole").nodeTypedValue
   	        If nPrivilegesOnRole <> 0 Then
   	            Set oRoleInObject = oSender.XmlObject.SelectSingleNode("Roles/UserRoleInProject" & "[@oid='" & oRole.getAttribute("oid") & "']")
   	            ' ���� ��������� ���� ������� ������������� ����������, �� �������� �� ������� � ������������
   	            If (oRoleInObject Is Nothing) Then
   	                If (nPrivilegesOnRole And g_nPrivileges) = 0 Then 
   	                    g_bReturnValue = False
   	                    oEventArgs.Cancel = True
   	                    oEventArgs.ReturnValue = False
   	                    oEventArgs.ErrorMessage = "� ��� ��� ���� �� �������� ���� " & oSender.XmlObjectPool.SelectSingleNode("UserRoleInProject" & "[@oid='" & oRole.getAttribute("oid") & "']/Name").nodeTypedValue
   	                    'Exit Sub
   	                End If 
   	            End If
   	        End If
   	    Next
   	End If 
End Sub
