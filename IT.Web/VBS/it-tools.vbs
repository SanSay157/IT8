'----------------------------------------------------------
'	����������� �������
Option Explicit

Dim g_oUserProfile			' As UserProfileClass - ���������� ��������� �������� ������� �����. 
							' ������������ ���������� �������������. ��� ��������� �������������� GetCurrentUserProfile

'==============================================================================
' ������� �������� ������������
Class UserProfileClass
	Public EmployeeID			' ������������� ���������� (Employee.ObjectID)
	Public SystemUserID			' ������������� ������������ ���������� (SystemUser.ObjectID)
	Public WorkdayDuration		' ���������� ����� � ������� ���
	
	'==============================================================================
	' ��������� ������ � ������� ��������� ������� GetCurrentUserClientProfile
	Public Sub Load()
		Dim oResponse
		On Error Resume Next
		With New XRequest
		    .m_sName = "GetCurrentUserClientProfile"
		    Set oResponse = X_ExecuteCommand( .Self )
	    End With
		If Err Then
			If Not X_HandleError Then
				MsgBox "������ ��� ��������� �������� �������� ������������" & vbCr & Err.Description, vbCritical
			End If
		End If
		EmployeeID   = oResponse.m_sEmployeeID
		SystemUserID = oResponse.m_sSystemUserID
		WorkdayDuration = oResponse.m_nWorkdayDuration
	End Sub
	
	
	'==============================================================================
	Function Serialize()
		Serialize = "WD:" & WorkdayDuration & ",EmpID:" & EmployeeID & ",SUID:" & SystemUserID
	End Function


	'==============================================================================
	' 	[in] sSerializedData
	Function Deserialize(sSerializedData)
	    Const AMOUNT_OF_ELEMENTS = 2		' ���������� ��������� � ������� aPairs
	
		Dim aPairs		' ������ ��� �������� �������
		Dim asPair		' ������ �� ���� ���������: ������������ �������� � ��� ��������
		Dim nCount		' ������ ���������� �������� � ������� aPairs
		Dim i
		Deserialize = False
		aPairs = Split(sSerializedData, ",")
		nCount = UBound(aPairs)
		If nCount <> AMOUNT_OF_ELEMENTS Then Exit Function
		For i = 0 To nCount
			asPair = Split( aPairs(i), ":")
			If UBound(asPair) <> 1 Then Exit Function
			Select Case asPair(0)
				Case "WD"	: WorkdayDuration = asPair(1)
				Case "EmpID": EmployeeID = asPair(1)
				Case "SUID" : SystemUserID = asPair(1)
			End Select
		Next
		Deserialize = True
	End Function
End Class


'==============================================================================
' ���������� �������������� ������� �������� ����� - ��������� UserProfileClass
' ���� ������ �� ������, ������� � �������������� ��� �������������� ������� �� ��� ("�������������").
' ���� �� ���������� ��������������� ��� ���� ����������� - ��������� ������� � ������� ������� GetCurrentUserClientProfile
'	[retval] As UserProfileClass
Function GetCurrentUserProfile
	Dim bNeedLoad
	Dim vValue

	bNeedLoad = False
	If IsEmpty(g_oUserProfile) Then
		Set g_oUserProfile = New UserProfileClass
		vValue = GetCachedParameter("UserProfile")
		If Not hasValue(vValue) Then
			bNeedLoad = True
		Else
			If Not g_oUserProfile.Deserialize(vValue) Then
				bNeedLoad
			End If
		End If
		If bNeedLoad Then
			g_oUserProfile.Load()
			vValue = g_oUserProfile.Serialize()
			Document.Cookie = "UserProfile=" & vValue
		End If
	End If
	Set GetCurrentUserProfile = g_oUserProfile
End Function



'==============================================================================
' ���������� �������� ���������, �������������� � ����� ���������
'	[retval] �������� ��������� ��� "", ��� Null, ���� ��������� ���
Function GetCachedParameter(sParamName)
	Dim asCookies		' ������ ��������� ��������� Cookies
	Dim asPair			' ������ ��������� ��������, � ������� ����������� ���� ������� ������� a_sCookies.
						' ������ ������� ����� ������� ������ �������� ���������, ������ - ��� ��������.
	Dim i

	GetCachedParameter = Null

	' �������� ������ Cookies �� �������� ����: ���=��������
	' -1 - ����� ������������ �������� Split ��������. ������, ��� ����� ���������� ���.
	asCookies = Split( Document.Cookie, ";", -1, vbTextCompare )

	' � �����
	For i = 0 To UBound(asCookies)
		' �������� ���� �������� �� ����� "=".
		asPair = Split( asCookies(i), "=", -1, vbTextCompare )
		' ���� ��� ��������� = ����� ����������� ���������, ���������� ��������� ��������.
		' Trim ������������ ������, ��� ������ Cookie �������� ����� ����������� �������
		If Trim( asPair(0) ) = sParamName Then
			If 0=UBound(asPair) Then	' �������� ����, �� �������� � ���� ��� => ���������� ������ ������
				GetCachedParameter = ""
				Exit Function
			End If
			GetCachedParameter = Trim ( asPair(1) )
			Exit Function
		End If
	Next
End Function


'==============================================================================
' ���������� ��������� XConfigClass � ����������� ������� it:app-data
Function ITConfig()
	Set ITConfig = XConfig("it:app-data")
End Function


'==============================================================================
' ���������� ���������� �������� ����� � ������ ��� �������� ������������
Function GetHoursInDay()
    Const MINUNTES_IN_ONE_HOUR = 60		' ����� ����� � ����� ����
	' ����������: � UserProfileClass::WorkdayDuration ����������� ���������� �����, ������� �������� �� ���������� ����� � ����
	GetHoursInDay = CLng(GetCurrentUserProfile().WorkdayDuration /MINUNTES_IN_ONE_HOUR)
End Function


'==============================================================================
' ��������� ������������� �����
' ���������:
'	[in] nTime - ����� �����
' ���������:
'	������ ���� "DD ���� HH ����� MM �����", ��������������� ����������� ����� ����� nTime
Function FormatTimeString(nTime)
	Const MINUNTES_IN_ONE_HOUR = 60		' ����� ����� � ����� ����

	Dim sOut			' ����������� ������
	Dim nHours			' ����� �����
	Dim nDays			' ����� ����
	Dim nMinutes		' ����� �����
	Dim nMinsInDay		' ����� ����� � ���
	
	if nTime = 0 then 
		FormatTimeString = "0 �����"
		exit function
	end if		
	
	nMinsInDay = GetHoursInDay() * MINUNTES_IN_ONE_HOUR
	nMinutes = ABS( nTime)
	nDays = Int(nMinutes/nMinsInDay)
	nHours = Int((nMinutes Mod nMinsInDay)/MINUNTES_IN_ONE_HOUR)
	nMinutes = nMinutes Mod MINUNTES_IN_ONE_HOUR


	if nDays > 0 then sOut = nDays & " " & XService.GetUnitForm(nDays, array("����","����","���"))
	if nHours > 0 then 
		if not IsEmpty(sOut)  then sOut = sOut & ", "
		sOut = sOut & nHours & " " & XService.GetUnitForm(nHours, array("�����","���","����"))
	end if
	if nMinutes > 0 then 
		if not IsEmpty(sOut)  then sOut = sOut & ", "
		sOut = sOut & nMinutes & " " & XService.GetUnitForm(nMinutes, array("�����","������","������"))
	end if
	if nTime < 0 then sOut = "- " & sOut	
	
	FormatTimeString =   sOut 
End function



'==============================================================================
' ��������� �������� ������ � �������� ������������� (��������� ������� ExecuteDataSource) 
' � ����������� ����������� � ���������� �������� ������ ������� ������ ������ ����������
'	[in] sDataSourceName 
'	[in] aParamNames
'	[in] aParamValues
Function GetScalarValueFromDataSource(sDataSourceName, aParamNames, aParamValues)
	Dim aValues			' ������ ��������
	
	aValues = GetFirstRowValuesFromDataSource(sDataSourceName, aParamNames, aParamValues)
	If UBound(aValues) >= 0 Then
		GetScalarValueFromDataSource = aValues(0)
	End If
End Function


'==============================================================================
' ��������� �������� ������ � �������� ������������� (��������� ������� ExecuteDataSource) 
' � ����������� ����������� � ���������� ������ ����� ������ ������ ����������
' (���������� � ������� ������� ������������ ���������� ������).
' � ������ ������� ���������� ������������ ������ ������.
'	[in] sDataSourceName 
'	[in] aParamNames
'	[in] aParamValues
'	[retval] Array
Function GetFirstRowValuesFromDataSource(sDataSourceName, aParamNames, aParamValues)
	Dim oParamsBuilder
	Dim oResponse
	Dim oRow
	Dim i
	Dim aValues			' ������ ��������
	Dim nCount          ' ���������� ��������
	Dim oXmlFields		' As IXMLDOMNodeList
	Dim oParamsCollection
	Set oParamsBuilder = New XmlParamCollectionBuilderClass
	If Not IsNull(aParamNames) Then
		If UBound(aParamNames) <> UBound(aParamValues) Then
			Err.Raise -1, "GetScalarValueFromDataSource", "����������� ������� � ������������� ���������� � ������� �� ���������� ���������� ������ ���������"
		End If
		' ���������� ��������� ���������� ��� ���������� ��������� ������	
		For i=0 To UBound(aParamNames)
			oParamsBuilder.AppendParameter aParamNames(i), aParamValues(i)
		Next
	End If

	On Error Resume Next
    Set oParamsCollection = New XParamsCollection
    Set oParamsCollection.m_oXmlParams = oParamsBuilder.XmlParametersRoot
	With New XExecuteDataSourceRequest
		.m_sName = "ExecuteDataSource"
		.m_sDataSourceName = sDataSourceName
		Set .m_oParams = oParamsCollection
		Set oResponse = X_ExecuteCommand( .Self )
	End With
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
	'	On Error GoTo 0
		Set oRow = oResponse.m_oDataWrapped.m_oXmlDataTable.selectSingleNode("RS/R")
		If Not oRow Is Nothing Then
			Set oXmlFields = oRow.selectNodes("F")
			nCount = oXmlFields.length
			ReDim aValues(nCount-1)
			For i = 0 To nCount-1
				aValues(i) = oXmlFields.item(i).text
			Next
		Else
			aValues = Array()
		End If
	End If
	GetFirstRowValuesFromDataSource = aValues
End Function


'==============================================================================
' ��������� �������� ������ � �������� ������������� (��������� ������� ExecuteDataSource) 
' � ����������� ����������� � ���������� ������ ��������: ������ �����-�������� � ���������� �������
' (���������� � ������� ������� ������������ ���������� ������).
' � ������ ������� ���������� ������������ ������ ������.
'	[in] sDataSourceName 
'	[in] aParamNames
'	[in] aParamValues
'	[retval] Array
Function GetValuesFromDataSource(sDataSourceName, aParamNames, aParamValues)
	Dim oParamsBuilder
	Dim oResponse
	Dim oRow
	Dim i
	Dim aValues			' ������ ��������
	Dim oXmlFields		' As IXMLDOMNodeList
	Dim oParams
	Set oParamsBuilder = New XmlParamCollectionBuilderClass
	If Not IsNull(aParamNames) Then
		If UBound(aParamNames) <> UBound(aParamValues) Then
			Err.Raise -1, "GetValuesFromDataSource", "����������� ������� � ������������� ���������� � ������� �� ���������� ���������� ������ ���������"
		End If
		' ���������� ��������� ���������� ��� ���������� ��������� ������	
		For i=0 To UBound(aParamNames)
			oParamsBuilder.AppendParameter aParamNames(i), aParamValues(i)
		Next
	End If

	On Error Resume Next
	Set oParams = New XParamsCollection
	Set oParams.m_oXmlParams = oParamsBuilder.XmlParametersRoot
	With New XExecuteDataSourceRequest
		.m_sName = "ExecuteDataSource"
		.m_sDataSourceName = sDataSourceName
		Set .m_oParams = oParams
		Set oResponse = X_ExecuteCommand( .Self )
	End With
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
		On Error GoTo 0
		Dim oRows ' ������ xml-����� � ������������ ���������� ��������� ������
		Dim nColumnsCount '���������� �������
		Dim aFieldValues  '������ �������� �������
		Dim nRow '����� ��������������� xml-����
		
		Set oRows = oResponse.m_oDataWrapped.m_oXmlDataTable.selectNodes("RS/R")
		ReDim aValues(oRows.length-1)
		If oRows.length > 0 Then
			nColumnsCount = oRows.item(0).selectNodes("F").length
		End If
		nRow = 0
		For Each oRow In oRows
			Set oXmlFields = oRow.selectNodes("F")
			ReDim aFieldValues(nColumnsCount-1)
			For i = 0 To nColumnsCount-1
				aFieldValues(i) = oXmlFields.item(i).text
			Next
			aValues(nRow) = aFieldValues
			nRow = nRow + 1
		Next
	End If
	GetValuesFromDataSource = aValues
End Function


'==============================================================================
' ������ ����� ������ ��� �������� �����, ������� ��������� � ���������.
' [in] sIncidentID - ObjectID ���������
' ��������! ������������� ���� ������� ������� ������� ����� x-create-outlook-letter.vbs
Function MailIncidentLinkToAll(sIncidentID)
	MailTo "Incident", sIncidentID, Null, Null
End Function


'==============================================================================
' ������ ����� ������ ��� �������� ����������� �����, �������� ��������� � ���������.
' [in] sIncidentID - ID ���������
' [in] sEmployeeID - ID ����������
' [in] sAuxInfo	- �������������� ���������� ��� ������� � ���� ������
' ��������! ������������� ���� ������� ������� ������� ����� x-create-outlook-letter.vbs
Function MailIncidentLinkToUser(sIncidentID, sEmployeeID, sAuxInfo)
	MailTo "Incident", sIncidentID, Array(sEmployeeID), sAuxInfo
End Function


'==============================================================================
' ������ ����� ������ ��� �������� ����������� �����, �������� ��������� � ���������.
' [in] sIncidentID - ID ���������
' [in] sEmployeeID - ID ����������
' [in] sAuxInfo	- �������������� ���������� ��� ������� � ���� ������
' ��������! ������������� ���� ������� ������� ������� ����� x-create-outlook-letter.vbs
Function MailIncidentLinkToUsers(sIncidentID, aEmployeeIDs, sAuxInfo)
	MailTo "Incident", sIncidentID, aEmployeeIDs, sAuxInfo
End Function


'==============================================================================
' ������ ����� ������ ��� �������� ��������� ���������� (��������� �������)
' [in] sProjectID 	- ID �������
' [in] sEmployeeID - ID ����������
' ��������! ������������� ���� ������� ������� ������� ����� x-create-outlook-letter.vbs
Function MailFolderLinkToUser(sProjectID, sEmployeeID, sAuxInfo)
	MailTo "Folder", sProjectID, Array(sEmployeeID), sAuxInfo
End Function


'==============================================================================
' ������ ����� ������ ��� �������� ���� ���������� ��������� �������
' [in] sProjectID 	- ID �������
' ��������! ������������� ���� ������� ������� ������� ����� x-create-outlook-letter.vbs
Function MailFolderLinkToAll(sProjectID)
	MailTo "Folder", sProjectID, Null, Null
End Function

Function Exec_GetMailMsgInfoRequest(sCommandName, sObjectID, sObjectType, aEmployeeIDs)
	With New GetMailMsgInfoRequest
		.m_sName = sCommandName
		.m_sObjectID = sObjectID
		.m_sObjectType = sObjectType
		.m_aEmployeeIDs = aEmployeeIDs
		Set Exec_GetMailMsgInfoRequest = X_ExecuteCommand( .Self )
	End With
End Function

'==============================================================================
' ������ ����� ������ ��� �������� �����, ������� ��������� � ��������� ��� �������.
' [in] sObjectType 	- ������������ ���� �������, � �������� ��������� ������: Folder ��� Incident
' [in] sObjectID	- ID ��������� / �������
' [in] aEmployeeIDs - ������ ID �������������
' [in] sAuxInfo		- �������������� ���������� ��� ������� � ���� ������
' ��������! ������������� ���� ������� ������� ������� ����� x-create-outlook-letter.vbs
Function MailTo( sObjectType, sObjectID, aEmployeeIDs, sAuxInfo)
    Dim oXml			' ������ � ������ � �������	
    Dim sParams			' ������ ���������� ��� �������� �� ������
    Dim oResponse		' ����� �������� ��������
    Dim sBody			' ����� ������
    
    If Len("" & sObjectID) = 0 Then Err.Raise -1, "", "sObjectID is not specified"
    
    if Not window.event Is Nothing Then
		If window.event.srcElement.tagName="A" Then
			window.event.returnValue = False
			window.event.cancelBubble = True
		End If
    End If

    On Error Resume Next
    Set oResponse = Exec_GetMailMsgInfoRequest("GetMailMsgInfo", sObjectID, sObjectType, aEmployeeIDs)
    If Err Then
		If Not X_HandleError Then 
			MsgBox Err.Description
		End If
	Else
		On Error Resume Next
		sBody = vbCr & vbCr & oResponse.m_sFolderPath & vbCr & vbCr & oResponse.m_sProjectLinks
		If hasValue(oResponse.m_sIncidentLinks) Then
			sBody = sBody & vbCr & vbCr & oResponse.m_sIncidentLinks
		End If
		X_CreateOutlookLetter oResponse.m_sTo, "", "", oResponse.m_sSubject, sBody, False, True, XService
	End If
End Function


Dim g_oNameCtrl		' As Name.NameCtrl

' ���������� ��������
' [in] sName - email ������������ 
' [in] nCorrectShiftLeft - ����� ���������������� ��������������� �������� �������� �����
Sub CrocUserOver(sName, nCorrectShiftLeft)
	' TODO: �������� ��� ����������� �� it5 � �������� �����������,������� ��� ������
End Sub


'-------------------------------------------------------------------------
' �������� ��������
Sub CrocUserOut()
End Sub


'==============================================================================
' ���������� ����������� ���� �� ����������
Sub ShowContextMenuForEmployee(EmployeeID, oMenuMD)
	Dim oMenu '������ ������ MenuClass - ���� ��������
	Dim oMenuMDXml '�������� ������� ���������� ���� (i:menu), ��������� IXMLDOMElement
	
	Set oMenuMDXml = XService.XMLFromString(oMenuMD.Value)
	Set oMenu = new MenuClass
	oMenu.Init oMenuMDXml
	oMenu.ShowPopupMenu Nothing
	' �������� ������� ������������ ����
	window.event.returnValue = False
End Sub


'==============================================================================
Sub EmployeeContextMenu_VisibilityHandler(oSender, oEventArgs)
End Sub


'==============================================================================
' ExecutionHandler ������������ ���� ����������
Sub EmployeeContextMenu_ExecutionHandler(oSender, oEventArgs)
	Select Case oEventArgs.Action
		Case "DoMailAboutIncident"
			MailIncidentLinkToUser oEventArgs.Menu.Macros.item("IncidentID"), oEventArgs.Menu.Macros.item("EmployeeID"), ""
		Case "DoMailAboutFolder"
			MailFolderLinkToUser oEventArgs.Menu.Macros.item("FolderID"), oEventArgs.Menu.Macros.item("EmployeeID"), ""
		Case "DoView"
			X_OpenReport oEventArgs.Menu.Macros.item("ReportURL")
		Case "DoRunReport"
			X_RunReport oEventArgs.Menu.Macros.Item("ReportName"), oEventArgs.Menu.Macros.Item("UrlParams")
		Case Else
			MsgBox "EmployeeContextMenu_ExecutionHandler. ����������� ��������� ������� '" & oEventArgs.Action & "'"
	End Select
End Sub


'==============================================================================
' ��������� ������ ������ ��������� �� ������ ��� ����� � ������ ��������
Sub OpenIncidentFinder()
	Dim vRes			' ��������� ������ � ������� ������
	Dim aRes			' ������ ����� ������� ����������
	Dim sURL			' ����� ������ ��������� ����� ������� ������

	sURL = XService.BaseURL & "dlg-IncidentFinder.htm?tm=" & cdbl(now())
	
	' ���������� ��������� ������ ������
	vRes = X_ShowModalDialogEx( sURL, null, _
			"dialogHeight:180px;dialogWidth:300px;center:no;resizable:no;status:no;help:no;scroll:no")
	If "" = vRes Then Exit Sub

	' ��������� ��������� - �� ������ �������� �� ID ���-�� � ������ ��� ��������
	' chr(11) - ������ ������������ ���������
	aRes = Split( vRes, chr(11) )
	
	' ��������� ������ ���������� - ������ ���������� �� 2 �����
	If UBound( aRes ) <> 1 Then
		Exit Sub
	End If
	Select Case aRes(1)
		Case "OPENINTREE": 	' ��������� � ������
			OpenFindIncidentInTreeByNumber aRes(0)
		Case "OPENINEDITOR": 	' ��������� � ���������
			OpenIncidentInEditorByNumber aRes(0)
		Case "OPENVIEW": 		' ��������� �� ��������
			OpenIncidentViewByNumber aRes(0)
	End Select  
End Sub

'==============================================================================
' ��������� ������ ������ ������� �� ���� � ������ ��������
Sub OpenProjectFinder()
	Dim vRes			' ��������� ������ � ������� ������
	Dim aRes			' ������ ����� ������� ����������
	Dim sURL			' ����� ������ ��������� ����� ������� ������
   
	sURL = XService.BaseURL & "dlg-IncidentFinder.htm?tm=" & cdbl(now())
	
	' ���������� ��������� ������ ������
	vRes = X_ShowModalDialogEx( sURL, null, _
			"dialogHeight:180px;dialogWidth:300px;center:no;resizable:no;status:no;help:no;scroll:no")
	If "" = vRes Then Exit Sub

	' ��������� ��������� - �� ������ �������� �� ID ���-�� � ������ ��� ��������
	' chr(11) - ������ ������������ ���������
	aRes = Split( vRes, chr(11) )
	
	' ��������� ������ ���������� - ������ ���������� �� 2 �����
	If UBound( aRes ) <> 1 Then
		Exit Sub
	End If
	Select Case aRes(1)
		Case "OPENINTREE": 	' ��������� � ������
			OpenContractInTreeByExtID aRes(0)
		Case "OPENINEDITOR": 	' ��������� � ���������
			OpenContractInEditorByExtID aRes(0)
		Case "OPENVIEW": 		' ��������� �� ��������
			'OpenIncidentViewByNumber aRes(0)
	End Select  
End Sub

'==============================================================================
' ��������� ������ ��� � ������� � ��� �������� � �������� ���������������
Sub OpenFindIncidentInTreeByID(sObjectID)
	OpenFindIncidentInTree sObjectID, Null
End Sub 


'==============================================================================
' ��������� ������ ��� � ������� � ��� �������� � �������� �������
'	[in] sNumber - ����� ���������
Sub OpenFindIncidentInTreeByNumber(sNumber)
    ' ������� �������� ��� ����� ������ ������
    If hasValue(sNumber) Then
	    If Not IsNumeric(sNumber) Then
	        MsgBox "������� ��������� ������ ���� ����� �����", vbExclamation
	        Exit Sub 
	   End If
	End If
	OpenFindIncidentInTree Null, sNumber
End Sub


'==============================================================================
' ��������� ������ ��� � ������� � ��� �������� � �������� ��������������� ��� �������
Sub OpenFindIncidentInTree(sObjectID, sNumber)
	Dim oResponse		' ����� ��������� ��������
	Dim sPath			' ����
	Dim sURL
	Dim sBaseURL        '������� ����� ������ ��������
	Dim bIsLocal		'������� ���������� �� �������� x-tree.aspx?METANAME=Main
	Dim oQS             '������ ������ QueryStringClass - ������ �������
	On Error Resume Next
	With New IncidentLocatorInTreeRequest
		.m_sName = "IncidentLocatorInTree"
		.m_sIncidentOID = sObjectID
		.m_nIncidentNumber = sNumber
		Set oResponse = X_ExecuteCommand( .Self )
	End With
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
    On Error Goto 0
		If Len("" & oResponse.m_sPath) = 0 Then
			If hasValue(sNumber) Then
				MsgBox "�������� � ������� " & sNumber & " �� ������", vbInformation
			Else
				MsgBox "�������� � ��������������� " & sObjectID & " �� ������", vbInformation
			End If
		Else
			bIsLocal = False
			sPath = oResponse.m_sPath
			
			' �������� ���� ����������� �� �������� ������ ���. 
			' ���� �� ���, �� ������� ��������� ��������� LocateNodeInDKPTree, ����� �������� �� ��� ��������
			
			' ������� ������ ����� ������� ��������
			sURL = window.location.protocol & "//" & window.location.host & window.location.pathname
			sBaseURL = XService.BaseURL 
			' ������ �� ���� ������ � �������, ������� ��� �����
			sURL = Mid(sURL, Len(sBaseURL) + 1, Len(sURL) - Len(sBaseURL))
			If LCase(sURL) = "x-tree.aspx" Then
				sURL = window.location.search
				If Len(sURL) > 0 Then
					Set oQS = X_GetEmptyQueryString
					' ������� ������ ������ "?", �� ���� 2 - ��������� ������� ������������ ������
					oQS.QueryString = Mid(sURL, 2, Len(sURL) - 1)
					If UCase(oQS.GetValue("metaname", "")) = "MAIN" Then
						bIsLocal = True
					End If
				End If
			End If
			
			If bIsLocal Then
				LocateNodeInDKPTree sPath, Null, Null
			Else
				' ��������: �.�. �� ��������� � ������ ���������� ����������� ����, 
				' �� �������� MayBeInterrapted XList'a ����� false, 
				' ������� ���������� ���� �� �������� ������� ����� ���������������� �������.
				' ����� ����� �������� ���������� ����������� �����
				window.setTimeout "window.navigate """ & sBaseURL & "x-tree.aspx?METANAME=Main" & "&INITPATH=" & sPath & """", 50, "VBScript"
			End If
		End If
	End If
End Sub

Function Exec_GetObjectIdByExKeyRequest(sCommandName, sTypeName, sDataSourceName, oParams)
	With New GetObjectIdByExKeyRequest
		.m_sName = sCommandName
		.m_sTypeName = sTypeName
		.m_sDataSourceName = sDataSourceName
		Set .m_oParams = oParams
		Set Exec_GetObjectIdByExKeyRequest = X_ExecuteCommand( .Self )
	End With
End Function

'==============================================================================
' ��������� �������� ��������� � �������� �������
'	[in] sNumber - ����� ���������
Sub OpenIncidentInEditorByNumber(sNumber)
	Dim oXmlParams   '���������� ���������� � ������� xml
	Dim oResponse    '������ - ��������� ������ ��������
	Dim oParamCollection  '��������� ����������
	' ������� �������� ��� ����� ������ ������
	If hasValue(sNumber) Then
	    If Not IsNumeric(sNumber) Then
	        MsgBox "������� ��������� ������ ���� ����� �����", vbExclamation
	        Exit Sub 
	   End If
	End If
    On Error Resume Next
	Set oXmlParams = New XmlParamCollectionBuilderClass
	oXmlParams.AppendParameter "Number", sNumber
	Set oParamCollection = New XParamsCollection
	Set oParamCollection.m_oXmlParams = oXmlParams.XmlParametersRoot
	Set oResponse = Exec_GetObjectIdByExKeyRequest("GetObjectIdByExKey", "Incident", Null, oParamCollection)
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
		On Error Goto 0
		If (oResponse.m_sObjectID = GUID_EMPTY) Then
			MsgBox "�������� � ������� " & sNumber & " �� ������.", vbExclamation
	        Exit Sub 
		End If
		
		X_OpenObjectEditor "Incident", oResponse.m_sObjectID, "", ""
	End If
End Sub


'==============================================================================
' ��������� ����� �������� ��������� � �������� �������
'	[in] sNumber - ����� ���������
Sub OpenIncidentViewByNumber(sNumber)
' ������� �������� ��� ����� ������ ������
    If hasValue(sNumber) Then
	    If Not IsNumeric(sNumber) Then
	        MsgBox "������� ��������� ������ ���� ����� �����", vbExclamation
	        Exit Sub 
	   End If
	End If
	X_RunReport "Incident", "IncidentNumber=" & sNumber
End Sub


'==============================================================================
' ��������� ��� � ������������� �������� ��������� ���� ������ �� ���������� � ���������
'	[in] oTreeView As CROC.IXTreeView
'	[in] sObjectID - ������������� �������� ����
'	[in] sType - ��� �������� ����
'	[retval] ���� �������� ���� ������ True, ����� False
Function CheckActiveNode(oTreeView, sType, sObjectID)
	Dim oActiveNode		' As IXTreeNode
	
	CheckActiveNode = False
	Set oActiveNode = oTreeView.ActiveNode
	If Not oActiveNode Is Nothing Then
		If oActiveNode.ID = sObjectID And oActiveNode.Type = sType Then
			CheckActiveNode = True
		End If
	End If
End Function


'==============================================================================
' ���������� ��������� ������ ���������� �����
'	[in] sMetaName	- ��� ������ � ���������� 
'	[in] sOT		- ������������ ����, � ���������� �������� ������������� �������� ������ (i:objects-list)
'	[in] nMode		- ����� ������ (LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE)
'	[in] sParams	- ������ ���������� ��� i:data-source. ������ �� ��� Param1=Value1, ����������� "&". 
'					��� ��������� ������ ���������� ����� ������������ ����� QueryStringParamCollectionBuilderClass
'	[in] sAddURL	- �������������� ���������, ������������ � ��� ���������� ������...
'		�������������  ���������� ������� � ����� x-list.aspx, x-list-page.vbs
Sub IT_OpenXListInDialog( byval sMetaName, sOT, nMode, sParams, sAddUrl, sHeght, sWidth)
	Dim sURL						' URL ������
	'������� URL �������	
	sURL =  "OT=" & sOT & "&MODE=" & nMode
	If Len(sMetaName) Then  sURL = sURL & "&METANAME=" & sMetaName 
	If Len(sParams)   Then  sURL = sURL & "&RESTR=" & XService.UrlEncode(sParams)
	If Len(sAddUrl)   Then
		If Left(sAddUrl,1) <> "&" Then sURL = sURL & "&"
		sURL = sURL & sAddUrl
	End If
	With X_GetEmptyQueryString
		.QueryString = sUrl
		'������� ������
		X_ShowModalDialogEx _
		    "x-list.aspx?OT=" & sOT & "&METANAME=" & sMetaname & "&MODE=" & nMode & "&TM=" & CDbl(Now), _
		    .Self , _
		    "dialogHeight:" & sHeght & ";dialogWidth:" & sWidth & ";help:no;center:yes;status:no"
	End With	
End Sub


'==============================================================================
' ���������� UI ��������� �������� �������� ������������ �� �������
Sub OpenUserEventTypeSubscriptionEditor()
	OpenUserEventTypeSubscriptionEditorEx 0
End Sub

Sub OpenUserEventTypeSubscriptionEditorEx(nEventClass)
	Dim sUrl
	sUrl = "METANAME=UserSubscription"
	If nEventClass>0 Then
		If nEventClass>15 Then
			sUrl = sUrl & "&INITPATH=EventType|0|EventClass|00000000-0000-0000-0000-0000000000" & LCase(Hex(nEventClass))
		Else
			sUrl = sUrl & "&INITPATH=EventType|0|EventClass|00000000-0000-0000-0000-00000000000" & LCase(Hex(nEventClass))
		End If
	End If
	X_ShowModalDialogEx _
		XService.BaseUrl & "x-tree.aspx?NONAVPANE=1&METANAME=UserSubscription", _
		sUrl, _
		"dialogHeight:600px; dialogWidth:750px; help:no; center:yes; status:no; resizable:yes;"
End Sub

'==============================================================================
' ��������� ������ ��� � ������� � ��� ����� � �������� ���������������
Sub OpenFindFolderInTree(sObjectID)
	Dim oResponse		' ����� ��������� ��������
	Dim sPath			' ����
	Dim sURL
	Dim sBaseURL        '������� ����� ������ ��������
	Dim bIsLocal		'������� ���������� �� �������� x-tree.aspx?METANAME=Main
	Dim oQS             '������ ������ QueryStringClass - ������ �������
	On Error Resume Next
	With New FolderLocatorInTreeRequest
        .m_sName = "FolderLocatorInTree"
        .m_sFolderOID = sObjectID
        Set oResponse = X_ExecuteCommand( .Self )
    End With
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
    On Error Goto 0
		If Len("" & oResponse.m_sPath) = 0 Then
			MsgBox "����� � ��������������� " & sObjectID & " �� �������", vbInformation
		Else
			bIsLocal = False
			sPath = oResponse.m_sPath
			
			' �������� ���� ����������� �� �������� ������ ���. 
			' ���� �� ���, �� ������� ��������� ��������� LocateNodeInDKPTree, ����� �������� �� ��� ��������
			
			' ������� ������ ����� ������� ��������
			sURL = window.location.protocol & "//" & window.location.host & window.location.pathname
			sBaseURL = XService.BaseURL 
			' ������ �� ���� ������ � �������, ������� ��� �����
			sURL = Mid(sURL, Len(sBaseURL) + 1, Len(sURL) - Len(sBaseURL))
			If LCase(sURL) = "x-tree.aspx" Then
				sURL = window.location.search
				If Len(sURL) > 0 Then
					Set oQS = X_GetEmptyQueryString
					' ������� ������ ������ "?", �� ���� 2 - ��������� ������� ������������ ������
					oQS.QueryString = Mid(sURL, 2, Len(sURL) - 1)
					If UCase(oQS.GetValue("metaname", "")) = "MAIN" Then
						bIsLocal = True
					End If
				End If
			End If
			
			If bIsLocal Then
				LocateNodeInDKPTree sPath, Null, Null
			Else
				' ��������: �.�. �� ��������� � ������ ���������� ����������� ����, 
				' �� �������� MayBeInterrapted XList'a ����� false, 
				' ������� ���������� ���� �� �������� ������� ����� ���������������� �������.
				' ����� ����� �������� ���������� ����������� �����
				window.setTimeout "window.navigate """ & sBaseURL & "x-tree.aspx?METANAME=Main" & "&INITPATH=" & sPath & """", 50, "VBScript"
			End If
		End If
	End If
End Sub

'==============================================================================
' ��������� �������� ���������� �������� �� ���� �������
'	[in] sNumber - ��� �������
Sub OpenContractInEditorByExtID(sExternalID)
	Dim oXmlParams   '���������� ���������� � ������� xml
	Dim oResponse    '������ - ��������� ������ ��������
	Dim oParamCollection  '��������� ����������
	
    On Error Resume Next
	Set oXmlParams = New XmlParamCollectionBuilderClass
	oXmlParams.AppendParameter "ExternalID", sExternalID
	Set oParamCollection = New XParamsCollection
	Set oParamCollection.m_oXmlParams = oXmlParams.XmlParametersRoot
	Set oResponse = Exec_GetObjectIdByExKeyRequest("GetObjectIdByExKey", "Folder", Null, oParamCollection)
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
		On Error Goto 0
		If (oResponse.m_sObjectID = GUID_EMPTY) Then
			MsgBox "������ � ����� " & sExternalID & " �� ������.", vbExclamation
	        Exit Sub 
		End If
	End If
	
	Set oXmlParams = New XmlParamCollectionBuilderClass
	oXmlParams.AppendParameter "Project", oResponse.m_sObjectID
	Set oParamCollection = New XParamsCollection
	Set oParamCollection.m_oXmlParams = oXmlParams.XmlParametersRoot
	Set oResponse = Exec_GetObjectIdByExKeyRequest("GetObjectIdByExKey", "Contract", Null, oParamCollection)
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
		On Error Goto 0
		If (oResponse.m_sObjectID = GUID_EMPTY) Then
			MsgBox "��������� ������� � ����� ������� " & sExternalID & " �� ������.", vbExclamation
	        Exit Sub 
		End If
		
		X_OpenObjectEditor "Contract", oResponse.m_sObjectID, "", ""
	End If
End Sub

'==============================================================================
' ��������� ������ ��� � ������� � ��� ����� � �������� ���������������
Sub OpenContractInTreeByExtID(sExternalID)
	Dim oResponse		' ����� ��������� ��������
	Dim sPath			' ����
	Dim sURL
	Dim sBaseURL        '������� ����� ������ ��������
	Dim bIsLocal		'������� ���������� �� �������� x-tree.aspx?METANAME=Main
	Dim oQS             '������ ������ QueryStringClass - ������ �������
	On Error Resume Next
	With New ContractLocatorInTreeRequest
        .m_sName = "ContractLocatorInTree"
        .m_sExternalID = sExternalID
        Set oResponse = X_ExecuteCommand( .Self )
    End With
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
    On Error Goto 0
		If Len("" & oResponse.m_sPath) = 0 Then
			MsgBox "����� � ��������������� " & sObjectID & " �� �������", vbInformation
		Else
			bIsLocal = False
			sPath = oResponse.m_sPath
			
			' �������� ���� ����������� �� �������� ������ ���. 
			' ���� �� ���, �� ������� ��������� ��������� LocateNodeInDKPTree, ����� �������� �� ��� ��������
			
			' ������� ������ ����� ������� ��������
			sURL = window.location.protocol & "//" & window.location.host & window.location.pathname
			sBaseURL = XService.BaseURL 
			' ������ �� ���� ������ � �������, ������� ��� �����
			sURL = Mid(sURL, Len(sBaseURL) + 1, Len(sURL) - Len(sBaseURL))
			If LCase(sURL) = "x-tree.aspx" Then
				sURL = window.location.search
				If Len(sURL) > 0 Then
					Set oQS = X_GetEmptyQueryString
					' ������� ������ ������ "?", �� ���� 2 - ��������� ������� ������������ ������
					oQS.QueryString = Mid(sURL, 2, Len(sURL) - 1)
					If UCase(oQS.GetValue("metaname", "")) = "MAIN" Then
						bIsLocal = True
					End If
				End If
			End If
			
			If bIsLocal Then
				LocateNodeInDKPTree sPath, Null, Null
			Else
				' ��������: �.�. �� ��������� � ������ ���������� ����������� ����, 
				' �� �������� MayBeInterrapted XList'a ����� false, 
				' ������� ���������� ���� �� �������� ������� ����� ���������������� �������.
				' ����� ����� �������� ���������� ����������� �����
				window.setTimeout "window.navigate """ & sBaseURL & "x-tree.aspx?METANAME=Main" & "&INITPATH=" & sPath & """", 50, "VBScript"
			End If
		End If
	End If
End Sub
