'==============================================================================
' Проверка прав на проставление роли "Директор Аккаунта"
Option Explicit
Dim g_nPrivileges ' Привелегии пользователя
Dim g_oRolesBefore
Dim g_bReturnValue

g_bReturnValue = True
' Обрабочик загрузки редактора 
Sub usrXEditor_OnLoad( oSender, oEventArgs )
    Dim aUserInfo ' Данные от пользователе и его правах
	' Запрос информации о текущем пользователи с сервера
	aUserInfo = GetFirstRowValuesFromDataSource("HomePage-GetCurrentEmployeeInfo", Null, Null)
	g_nPrivileges = CLng(aUserInfo(5))
	
	With oSender
	    If .IsObjectCreationMode Then
	        Dim oEmployment
	        Set oEmployment = .Pool.CreateXmlObjectInPool("EmploymentParticipantProject")
	        If Not(HasValue(oEmployment)) THen
	            Err.Raise vbObjectError, "usrXEditor_OnLoad", "Не удалось создать занятость для нового сотрудника"
	        End If
	        .Pool.SetPropertyValue .Pool.GetXmlProperty(oEmployment, "DateBegin"), Date()
	        .Pool.SetPropertyValue .Pool.GetXmlProperty(oEmployment, "DateEnd"), DateAdd("m", 1, Date())
	        .Pool.SetPropertyValue .Pool.GetXmlProperty(oEmployment, "Percent"), 100
	        .Pool.AddRelation oEmployment, "ProjectParticipant", .XmlObject
	    End If
	End With
	
End Sub

' Обрабочик загрузки списка участников проекта
Sub usr_ProjectParticipant_Roles_ObjectsSelector_OnLoadList(oSender, oEventArgs)
    ' Зачитаем роли до редактирования
    Set g_oRolesBefore = oSender.XmlProperty.cloneNode(true)
End Sub 

' Валидация данных
Sub usrXEditor_OnValidatePage( oSender, oEventArgs )
    Dim oRoles ' 
    Dim oRole
    Dim nPrivilegesOnRole ' Привилегия на выдачу роли
    Dim oRoleInObject ' Роль пользователя в проекте (Roles/UserRoleInProject)
    Dim oRolesInPool ' Роли пользователя в папке, загруженные в пул
    ' Загрузим роли 
    Set oRoles = oSender.Pool.GetXmlObjectsByOPath(oSender.XmlObject, "Roles")
    If Not (oRoles Is Nothing) Then
   	    For Each oRole In oRoles
   	        ' Зачитаем необходимую привилегию
   	        nPrivilegesOnRole = oRole.SelectSingleNode("SystemPrivilegesOnRole").nodeTypedValue
   	        If nPrivilegesOnRole <> 0 Then
   	            Set oRoleInObject = g_oRolesBefore.selectSingleNode("UserRoleInProject" & "[@oid='" & oRole.getAttribute("oid") & "']")
   	            ' Если роль у пользователя была до редактирования, то не будем проверять специальные права на выдачу этой роли
   	            If (oRoleInObject Is Nothing) Then
   	                If (nPrivilegesOnRole And g_nPrivileges) = 0 Then 
   	                    oEventArgs.Cancel = True
   	                    oEventArgs.ReturnValue = False
   	                    oEventArgs.ErrorMessage = "У вас нет прав на выдачу роли " & oRole.SelectSingleNode("Name").nodeTypedValue
   	                    'Exit Sub
   	                End If
   	            End If
       	            
   	        End If
   	    Next
   	End If
   	' Теперь посмотрим те роли, которые были прогружены в пул, но в итоге были удалены из объекта 	
   	Set oRolesInPool = g_oRolesBefore.selectNodes("UserRoleInProject")
   	If Not (oRolesInPool Is Nothing) Then
   	    For Each oRole in oRolesInPool
   	        nPrivilegesOnRole = oSender.XmlObjectPool.SelectSingleNode("UserRoleInProject" & "[@oid='" & oRole.getAttribute("oid") & "']/SystemPrivilegesOnRole").nodeTypedValue
   	        If nPrivilegesOnRole <> 0 Then
   	            Set oRoleInObject = oSender.XmlObject.SelectSingleNode("Roles/UserRoleInProject" & "[@oid='" & oRole.getAttribute("oid") & "']")
   	            ' Если удаленная роль требует дополнительно привилегии, то проверим ее наличие у пользователя
   	            If (oRoleInObject Is Nothing) Then
   	                If (nPrivilegesOnRole And g_nPrivileges) = 0 Then 
   	                    g_bReturnValue = False
   	                    oEventArgs.Cancel = True
   	                    oEventArgs.ReturnValue = False
   	                    oEventArgs.ErrorMessage = "У вас нет прав на удаление роли " & oSender.XmlObjectPool.SelectSingleNode("UserRoleInProject" & "[@oid='" & oRole.getAttribute("oid") & "']/Name").nodeTypedValue
   	                    'Exit Sub
   	                End If 
   	            End If
   	        End If
   	    Next
   	End If 
End Sub
