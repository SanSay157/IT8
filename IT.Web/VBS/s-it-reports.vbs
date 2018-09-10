'Скрипт, подключаемый к отчётам IncidentTracker
Option Explicit

Function ShowContextForOrganization(sID, sExtID, sDirectorEMail)
	Dim oPopUp
	Set oPopUp = XService.CreateObject("CROC.XPopUpMenu")
	oPopUp.Add "Просмотр", "X_OpenReport ""nsi-redirect.aspx?OT=Organization&ID="" & sID & ""&FROM=0AEFC1FD-4D42-4AAC-8369-76E5A812EFF3&COMMAND=CARD"""
	oPopUp.Add "Перейти в Navision", "X_OpenReport ""nsi-redirect.aspx?OT=Organization&ID="" & sExtID & ""&FROM=DF65E2F0-1420-4268-936F-E9E6CEDB3C65&TO=DF65E2F0-1420-4268-936F-E9E6CEDB3C65&COMMAND=EDITOR"""
	oPopUp.Add "Написать письмо Директору Клиента", "window.Open ""mailto:"" & sDirectorEMail", 0<>len(sDirectorEMail)
	Execute oPopUp.Show & "' "
End Function

' Формирование выпадающего меню для пользователя
Function ShowContextForEmployeeLite(sID, sEMail)
	ShowContextForEmployeeEx sID, sEMail, GUID_EMPTY, GUID_EMPTY, Null, Null
End Function

' Формирование выпадающего меню для пользователя
Function ShowContextForEmployee(sID, sEMail, sIncidentID, sProjectID)
	ShowContextForEmployeeEx sID, sEMail, sIncidentID, sProjectID, Null, Null
End Function

' Формирование выпадающего меню для пользователя
' (с заданием дат для вызываемых отчетов)
Function ShowContextForEmployeeEx(sID, sEMail, sIncidentID, sProjectID, dtStartDate, dtEndDate)
	Dim oPopUp
	Dim x_oXConfig
	Dim XService
	Set XService = document.all("XService")	
	Set oPopUp = XService.CreateObject("CROC.XPopUpMenu")
	If sIncidentID <> GUID_EMPTY Then
		oPopUp.Add "Написать письмо по инциденту", "MailIncidentLinkToUser sIncidentID, sID, vbNullString"
	End If
	If sProjectID <> GUID_EMPTY Then
		oPopUp.Add "Написать письмо по проекту", "MailFolderLinkToUser sProjectID, sID, vbNullString"
	End If
	If dtStartDate = "" Then dtStartDate = Null
	If dtEndDate = "" Then dtEndDate = Null
	oPopUp.Add "Написать письмо", "window.Open ""mailto:"" & sEMail"
	oPopUp.AddSeparator
	oPopUp.Add "Список инцидентов и затрат сотрудника", "X_RunReport ""ReportEmployeeExpensesList"", "".Employee="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString )"
	oPopUp.Add "Баланс списаний сотрудника", "X_RunReport ""EmployeeExpensesBalance"", "".Employee="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString )"
	oPopUp.AddSeparator
	oPopUp.Add "Просмотр (карточка сотрудника в NSI)", "X_OpenReport XService.BaseUrl & ""nsi-redirect.aspx?OT=SystemUser&FROM=0AEFC1FD-4D42-4AAC-8369-76E5A812EFF3&COMMAND=CARD&ID="" & sID"
	oPopUp.Add "Редактировать", "If Not IsEmpty( X_OpenObjectEditor(""Employee"", sID, Null, Null)) Then DoRefresh", X_CheckObjectRights("Employee", sID, "Edit")
	Execute oPopUp.Show & "' "
End Function

' Формирование выпадающего меню для проекта
Function ShowContextForFolder(sID, bShowView)
	ShowContextForFolderEx sID, bShowView, Null, Null
End Function

Function ShowContextForFolderEx(sID, bShowView, dtStartDate, dtEndDate)
	ShowContextForFolderEx2 sID, GUID_EMPTY, bShowView, dtStartDate, dtEndDate
End Function

' Формирование выпадающего меню для проекта
' (с заданием дат для вызываемых отчетов)
Function ShowContextForFolderEx2(sID, sUserID, bShowView, dtStartDate, dtEndDate)
	Dim oPopUp
	Set oPopUp = XService.CreateObject("CROC.XPopUpMenu")
	
	If GUID_EMPTY = sUserID Then sUserID = Null
	
	If bShowView Then
		oPopUp.Add "Просмотр", "X_OpenReport XService.BaseUrl & ""x-get-report.aspx?name=r-Folder.xml&ID="" & sID"
		oPopUp.AddSeparator
	End If
	oPopUp.Add "Редактировать", "DoEditFolder sID", X_CheckObjectRights("Folder", sID, "Edit")
	
	oPopUp.Add "Найти в дереве", "window.Open XService.BaseUrl & ""x-tree.aspx?METANAME=Main&LocateFolderByID="" & sID"
	oPopUp.AddSeparator
	oPopUp.Add "Список инцидентов и затрат проекта (по инцидентам)", "X_RunReport ""ProjectIncidentsAndExpenses"", "".Folder="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString ) & ""&.IncidentStates=&.PlannerOrganizations=&.PlannerDepartments=&.Planners=&.WorkerDepartments=&.WorkerOrganizations=&.Workers="" & sUserID"
	oPopUp.Add "Список инцидентов и затрат проекта (по сотрудникам)", "X_RunReport ""ProjectParticipantsAndExpenses"", "".Folder="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString )"
	oPopUp.Add "Списание времени сотрудниками", "X_RunReport ""TimeLosses"", "".Folder="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString )"
	oPopUp.Add "Хроника изменений инцидентов проекта", "X_RunReport ""FolderIncidentsHistory"", "".Folder="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString )"
	oPopUp.Add "Динамика затрат сотрудников", "X_RunReport ""ReportUsersExpences"", "".Folder="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString )"

	oPopUp.AddSeparator
	oPopUp.Add "Написать письмо", "MailFolderLinkToAll sID"

	Execute oPopUp.Show & "' "
End Function

' Формирование выпадающего меню для инцидента
Function ShowContextForIncident(sID, nIncidentNumber, bShowView)
	Dim oPopUp
	Set oPopUp = XService.CreateObject("CROC.XPopUpMenu")
	oPopUp.Add "Написать письмо", "MailIncidentLinkToAll sID"
	oPopUp.AddSeparator
	oPopUp.Add "Перейти в дерево", "DoShowIncidentInTree sID"
	oPopUp.AddSeparator
	If bShowView Then
		oPopUp.AddSeparator
		oPopUp.Add "Просмотр (карточка инцидента)", "X_OpenReport XService.BaseUrl & ""x-get-report.aspx?name=r-Incident.xml&DontCacheXslfo=true&IncidentID="" & sID"
	End If
	oPopUp.Add "Редактировать", "DoEditIncident sID", X_CheckObjectRights("Incident", sID, "Edit")
	
	Execute oPopUp.Show & "' "
End Function

' Редактирование инцидента из отчёта
Sub DoEditIncident(sID)
	If Not IsEmpty( X_OpenObjectEditor("Incident", sID, Null, Null)) Then
		DoRefresh
	End If	
End Sub

' Редактирование папки из отчёта
Sub DoEditFolder(sID)
	If Not IsEmpty( X_OpenObjectEditor("Folder", sID, Null, Null)) Then
		DoRefresh
	End If	
End Sub

' Открытие дерева проектов и позиционирование на инциденте
Sub DoShowIncidentInTree(sID)
	window.Open XService.BaseUrl & "x-tree.aspx?METANAME=Main&LocateIncidentByID=" & sID
End Sub

' Открытие внешней ссылки
Sub OpenExternalLink( nServiceSystemType, sURI )
	Dim sMessage		' Текст сообщения (об ошибке)
		
	Select Case nServiceSystemType
		' Тип системы обслуживания: "просто" URL
		Case SERVICESYSTEMTYPE_URL
			Dim oIE		' Экземпляр Internet Explorer
			
			sMessage = "Ошибка при открытии ссылки """ & sURI & """: "
			On Error Resume Next
			Set oIE = XService.CreateObject("InternetExplorer.Application")
			oIE.Visible = True
			oIE.Navigate sURI
			If Err Then
				MsgBox sMessage & Err.Description, vbCritical, "Ошибка"
				Exit Sub
			End If
			On Error Goto 0
		
		' Тип системы обслуживания: ссылка на файл
		Case SERVICESYSTEMTYPE_FILELINK
			Dim oFSO	' Объект FileSystemObject
			Dim vRet	' Результат запроса подтверждения у пользователя
			
			sMessage  = "Ошибка при попытке открытия ссылки на файл """ & sURI & """: " 
			On Error Resume Next
			Set oFSO = XService.CreateObject("Scripting.FileSystemObject")
			If Err Then
				MsgBox sMessage & Err.Description, vbCritical, "Ошибка"
				Exit Sub
			End If
			If Not oFSO.FileExists(sURI) Then 
				vRet = MsgBox( _
					"Указанный файл """ & sURI & """ не существует." & vbNewLine & _
					"Возможно, у Вас нет прав на открытие файла или файл был переименован, перемещен или удален." & vbNewLine & _
					"Попытаться открыть файл?", vbYesNo Or vbExclamation, "Файл не существует" ) 
				If vbYes <> vRet Then Exit Sub
			End If
			On Error Resume Next
			XService.ShellExecute sURI
			If 0<>Err.Number Then
				MsgBox sMessage & Err.Description, vbCritical, "Ошибка"
			End If
			On Error GoTo 0
		
		' Тип системы обслуживания: ссылка на каталог
		Case SERVICESYSTEMTYPE_DIRECTORYLINK
			Dim oFolder	
			
			sMessage = "Ошибка при попытке открытия ссылки на папку """ & sURI & """: " 
			On Error Resume Next
			With XService.CreateObject("Shell.Application")
				Set oFolder = .NameSpace(sURI)
				If Not hasValue(oFolder) Then
					MsgBox _
						"Указанная папка """ & sURI & """ не существует." & vbNewLine & _
						"Возможно, у Вас нет прав на открытие папки или папка была переименована, перемещена или удалена.", _
						vbCritical, "Ошибка"
					Exit Sub
				End If
				' NB: oFolder.Self возвращает FolderItem, для которого допустимо использование Verb
				oFolder.Self.InvokeVerb("explore")
			End With
			If Err Then MsgBox sMessage & Err.Description, vbCritical, "Ошибка"
			On Error Goto 0
			
		' Тип системы обслуживания: ссылка на файл в Documentum
		Case SERVICESYSTEMTYPE_DOCUMENTUMFILELINK	
			window.open XService.BaseUrl & "webtop.aspx?goto=" & XService.UrlEncode("drl/objectId/" & sURI)
		
		' Тип системы обслуживания: ссылка на папку в Documentum 
		Case SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK	'
			window.open XService.BaseUrl & "webtop.aspx?goto=" & XService.UrlEncode("drl/objectId/" & sURI)
			' Для нормальной версии WebTop-а будет использоваться cледующий код
			'X_ShowModalDialogEx XService.BaseUrl & "it-integrate-documentum.aspx?Command=crocintgopen&Params=objectId~" & URI & "|launchViewer~true" , "", "help:no;center:yes;status:no"
	End Select
End Sub

'##########################################################################################
' Волшебство
'##########################################################################################

' Вставим ActiveX
document.Write "<scr" & "ipt language=""VBScript"" src=""IT-Install-XControls-via-VBS.aspx""></sc" & "ript>"
' Вставим клиентские скрипты
document.Write "<scr" & "ipt language=""VBScript"" src=""VBS/x-const.vbs""></sc" & "ript>"
document.Write "<scr" & "ipt language=""VBScript"" src=""VBS/x-vbs.vbs""></sc" & "ript>"
document.Write "<scr" & "ipt language=""VBScript"" src=""VBS/x-utils.vbs""></sc" & "ript>"
document.Write "<scr" & "ipt language=""VBScript"" src=""VBS/x-proxy.vbs""></sc" & "ript>"
document.Write "<scr" & "ipt language=""VBScript"" src=""VBS/x-srv-cmd.vbs""></sc" & "ript>"
document.Write "<scr" & "ipt language=""VBScript"" src=""VBS/x-menu.vbs""></sc" & "ript>"
document.Write "<scr" & "ipt language=""VBScript"" src=""VBS/x-event-engine.vbs""></sc" & "ript>"
document.Write "<scr" & "ipt language=""VBScript"" src=""VBS/it-const.vbs""></sc" & "ript>"
document.Write "<scr" & "ipt language=""VBScript"" src=""VBS/it-tools.vbs""></sc" & "ript>"
document.Write "<scr" & "ipt language=""VBScript"" src=""VBS/it-security.vbs""></sc" & "ript>"
document.Write "<scr" & "ipt language=""VBScript"" src=""VBS/it-proxy.vbs""></sc" & "ript>"
document.Write "<scr" & "ipt language=""VBScript"" src=""VBS/it-editor-security.vbs""></sc" & "ript>"
document.Write "<scr" & "ipt language=""VBScript"" src=""VBS/x-create-outlook-letter.vbs""></sc" & "ript>"

'