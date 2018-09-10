'������, ������������ � ������� IncidentTracker
Option Explicit

Function ShowContextForOrganization(sID, sExtID, sDirectorEMail)
	Dim oPopUp
	Set oPopUp = XService.CreateObject("CROC.XPopUpMenu")
	oPopUp.Add "��������", "X_OpenReport ""nsi-redirect.aspx?OT=Organization&ID="" & sID & ""&FROM=0AEFC1FD-4D42-4AAC-8369-76E5A812EFF3&COMMAND=CARD"""
	oPopUp.Add "������� � Navision", "X_OpenReport ""nsi-redirect.aspx?OT=Organization&ID="" & sExtID & ""&FROM=DF65E2F0-1420-4268-936F-E9E6CEDB3C65&TO=DF65E2F0-1420-4268-936F-E9E6CEDB3C65&COMMAND=EDITOR"""
	oPopUp.Add "�������� ������ ��������� �������", "window.Open ""mailto:"" & sDirectorEMail", 0<>len(sDirectorEMail)
	Execute oPopUp.Show & "' "
End Function

' ������������ ����������� ���� ��� ������������
Function ShowContextForEmployeeLite(sID, sEMail)
	ShowContextForEmployeeEx sID, sEMail, GUID_EMPTY, GUID_EMPTY, Null, Null
End Function

' ������������ ����������� ���� ��� ������������
Function ShowContextForEmployee(sID, sEMail, sIncidentID, sProjectID)
	ShowContextForEmployeeEx sID, sEMail, sIncidentID, sProjectID, Null, Null
End Function

' ������������ ����������� ���� ��� ������������
' (� �������� ��� ��� ���������� �������)
Function ShowContextForEmployeeEx(sID, sEMail, sIncidentID, sProjectID, dtStartDate, dtEndDate)
	Dim oPopUp
	Dim x_oXConfig
	Dim XService
	Set XService = document.all("XService")	
	Set oPopUp = XService.CreateObject("CROC.XPopUpMenu")
	If sIncidentID <> GUID_EMPTY Then
		oPopUp.Add "�������� ������ �� ���������", "MailIncidentLinkToUser sIncidentID, sID, vbNullString"
	End If
	If sProjectID <> GUID_EMPTY Then
		oPopUp.Add "�������� ������ �� �������", "MailFolderLinkToUser sProjectID, sID, vbNullString"
	End If
	If dtStartDate = "" Then dtStartDate = Null
	If dtEndDate = "" Then dtEndDate = Null
	oPopUp.Add "�������� ������", "window.Open ""mailto:"" & sEMail"
	oPopUp.AddSeparator
	oPopUp.Add "������ ���������� � ������ ����������", "X_RunReport ""ReportEmployeeExpensesList"", "".Employee="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString )"
	oPopUp.Add "������ �������� ����������", "X_RunReport ""EmployeeExpensesBalance"", "".Employee="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString )"
	oPopUp.AddSeparator
	oPopUp.Add "�������� (�������� ���������� � NSI)", "X_OpenReport XService.BaseUrl & ""nsi-redirect.aspx?OT=SystemUser&FROM=0AEFC1FD-4D42-4AAC-8369-76E5A812EFF3&COMMAND=CARD&ID="" & sID"
	oPopUp.Add "�������������", "If Not IsEmpty( X_OpenObjectEditor(""Employee"", sID, Null, Null)) Then DoRefresh", X_CheckObjectRights("Employee", sID, "Edit")
	Execute oPopUp.Show & "' "
End Function

' ������������ ����������� ���� ��� �������
Function ShowContextForFolder(sID, bShowView)
	ShowContextForFolderEx sID, bShowView, Null, Null
End Function

Function ShowContextForFolderEx(sID, bShowView, dtStartDate, dtEndDate)
	ShowContextForFolderEx2 sID, GUID_EMPTY, bShowView, dtStartDate, dtEndDate
End Function

' ������������ ����������� ���� ��� �������
' (� �������� ��� ��� ���������� �������)
Function ShowContextForFolderEx2(sID, sUserID, bShowView, dtStartDate, dtEndDate)
	Dim oPopUp
	Set oPopUp = XService.CreateObject("CROC.XPopUpMenu")
	
	If GUID_EMPTY = sUserID Then sUserID = Null
	
	If bShowView Then
		oPopUp.Add "��������", "X_OpenReport XService.BaseUrl & ""x-get-report.aspx?name=r-Folder.xml&ID="" & sID"
		oPopUp.AddSeparator
	End If
	oPopUp.Add "�������������", "DoEditFolder sID", X_CheckObjectRights("Folder", sID, "Edit")
	
	oPopUp.Add "����� � ������", "window.Open XService.BaseUrl & ""x-tree.aspx?METANAME=Main&LocateFolderByID="" & sID"
	oPopUp.AddSeparator
	oPopUp.Add "������ ���������� � ������ ������� (�� ����������)", "X_RunReport ""ProjectIncidentsAndExpenses"", "".Folder="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString ) & ""&.IncidentStates=&.PlannerOrganizations=&.PlannerDepartments=&.Planners=&.WorkerDepartments=&.WorkerOrganizations=&.Workers="" & sUserID"
	oPopUp.Add "������ ���������� � ������ ������� (�� �����������)", "X_RunReport ""ProjectParticipantsAndExpenses"", "".Folder="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString )"
	oPopUp.Add "�������� ������� ������������", "X_RunReport ""TimeLosses"", "".Folder="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString )"
	oPopUp.Add "������� ��������� ���������� �������", "X_RunReport ""FolderIncidentsHistory"", "".Folder="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString )"
	oPopUp.Add "�������� ������ �����������", "X_RunReport ""ReportUsersExpences"", "".Folder="" & sID & iif( hasValue(dtStartDate), ""&.IntervalBegin="" & X_DateToXmlType(dtStartDate, True), vbNullString ) & iif( hasValue(dtEndDate), ""&.IntervalEnd="" & X_DateToXmlType(dtEndDate, True), vbNullString )"

	oPopUp.AddSeparator
	oPopUp.Add "�������� ������", "MailFolderLinkToAll sID"

	Execute oPopUp.Show & "' "
End Function

' ������������ ����������� ���� ��� ���������
Function ShowContextForIncident(sID, nIncidentNumber, bShowView)
	Dim oPopUp
	Set oPopUp = XService.CreateObject("CROC.XPopUpMenu")
	oPopUp.Add "�������� ������", "MailIncidentLinkToAll sID"
	oPopUp.AddSeparator
	oPopUp.Add "������� � ������", "DoShowIncidentInTree sID"
	oPopUp.AddSeparator
	If bShowView Then
		oPopUp.AddSeparator
		oPopUp.Add "�������� (�������� ���������)", "X_OpenReport XService.BaseUrl & ""x-get-report.aspx?name=r-Incident.xml&DontCacheXslfo=true&IncidentID="" & sID"
	End If
	oPopUp.Add "�������������", "DoEditIncident sID", X_CheckObjectRights("Incident", sID, "Edit")
	
	Execute oPopUp.Show & "' "
End Function

' �������������� ��������� �� ������
Sub DoEditIncident(sID)
	If Not IsEmpty( X_OpenObjectEditor("Incident", sID, Null, Null)) Then
		DoRefresh
	End If	
End Sub

' �������������� ����� �� ������
Sub DoEditFolder(sID)
	If Not IsEmpty( X_OpenObjectEditor("Folder", sID, Null, Null)) Then
		DoRefresh
	End If	
End Sub

' �������� ������ �������� � ���������������� �� ���������
Sub DoShowIncidentInTree(sID)
	window.Open XService.BaseUrl & "x-tree.aspx?METANAME=Main&LocateIncidentByID=" & sID
End Sub

' �������� ������� ������
Sub OpenExternalLink( nServiceSystemType, sURI )
	Dim sMessage		' ����� ��������� (�� ������)
		
	Select Case nServiceSystemType
		' ��� ������� ������������: "������" URL
		Case SERVICESYSTEMTYPE_URL
			Dim oIE		' ��������� Internet Explorer
			
			sMessage = "������ ��� �������� ������ """ & sURI & """: "
			On Error Resume Next
			Set oIE = XService.CreateObject("InternetExplorer.Application")
			oIE.Visible = True
			oIE.Navigate sURI
			If Err Then
				MsgBox sMessage & Err.Description, vbCritical, "������"
				Exit Sub
			End If
			On Error Goto 0
		
		' ��� ������� ������������: ������ �� ����
		Case SERVICESYSTEMTYPE_FILELINK
			Dim oFSO	' ������ FileSystemObject
			Dim vRet	' ��������� ������� ������������� � ������������
			
			sMessage  = "������ ��� ������� �������� ������ �� ���� """ & sURI & """: " 
			On Error Resume Next
			Set oFSO = XService.CreateObject("Scripting.FileSystemObject")
			If Err Then
				MsgBox sMessage & Err.Description, vbCritical, "������"
				Exit Sub
			End If
			If Not oFSO.FileExists(sURI) Then 
				vRet = MsgBox( _
					"��������� ���� """ & sURI & """ �� ����������." & vbNewLine & _
					"��������, � ��� ��� ���� �� �������� ����� ��� ���� ��� ������������, ��������� ��� ������." & vbNewLine & _
					"���������� ������� ����?", vbYesNo Or vbExclamation, "���� �� ����������" ) 
				If vbYes <> vRet Then Exit Sub
			End If
			On Error Resume Next
			XService.ShellExecute sURI
			If 0<>Err.Number Then
				MsgBox sMessage & Err.Description, vbCritical, "������"
			End If
			On Error GoTo 0
		
		' ��� ������� ������������: ������ �� �������
		Case SERVICESYSTEMTYPE_DIRECTORYLINK
			Dim oFolder	
			
			sMessage = "������ ��� ������� �������� ������ �� ����� """ & sURI & """: " 
			On Error Resume Next
			With XService.CreateObject("Shell.Application")
				Set oFolder = .NameSpace(sURI)
				If Not hasValue(oFolder) Then
					MsgBox _
						"��������� ����� """ & sURI & """ �� ����������." & vbNewLine & _
						"��������, � ��� ��� ���� �� �������� ����� ��� ����� ���� �������������, ���������� ��� �������.", _
						vbCritical, "������"
					Exit Sub
				End If
				' NB: oFolder.Self ���������� FolderItem, ��� �������� ��������� ������������� Verb
				oFolder.Self.InvokeVerb("explore")
			End With
			If Err Then MsgBox sMessage & Err.Description, vbCritical, "������"
			On Error Goto 0
			
		' ��� ������� ������������: ������ �� ���� � Documentum
		Case SERVICESYSTEMTYPE_DOCUMENTUMFILELINK	
			window.open XService.BaseUrl & "webtop.aspx?goto=" & XService.UrlEncode("drl/objectId/" & sURI)
		
		' ��� ������� ������������: ������ �� ����� � Documentum 
		Case SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK	'
			window.open XService.BaseUrl & "webtop.aspx?goto=" & XService.UrlEncode("drl/objectId/" & sURI)
			' ��� ���������� ������ WebTop-� ����� �������������� c�������� ���
			'X_ShowModalDialogEx XService.BaseUrl & "it-integrate-documentum.aspx?Command=crocintgopen&Params=objectId~" & URI & "|launchViewer~true" , "", "help:no;center:yes;status:no"
	End Select
End Sub

'##########################################################################################
' ����������
'##########################################################################################

' ������� ActiveX
document.Write "<scr" & "ipt language=""VBScript"" src=""IT-Install-XControls-via-VBS.aspx""></sc" & "ript>"
' ������� ���������� �������
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