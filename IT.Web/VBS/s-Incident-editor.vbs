'	��������/������ Incident
Option Explicit

Dim g_oObjectEditor			  ' ������� �������� (��������������� ���� ��� � OnLoad)
Dim g_oPool					  ' ������� ��� (��������������� ���� ��� � OnLoad)
Dim g_sCurrentEmployeeID	  ' ������������� �������� ����������
Dim g_sCurrentWorkdayDuration ' ������� ������������ �������� ���
Dim g_sCurrentSystemUserID	  ' ������������� �������� ������������
Dim g_bHasIncidentTypeChanged ' ������� ����, ��� ��� ��������� ������� (��������������� �������� � ���� �������� ���������) 
'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Dim oProp
	Dim oValue
	
	Set g_oObjectEditor = oSender
	Set g_oPool = oSender.Pool
	g_bHasIncidentTypeChanged=True
	With g_oPool
		' �������� ����������� �������� ��� ����������� ������ "�����" (��� ����� ���� ���, ���� ��� ��������� �� ������� ���������)
		Set oProp = oSender.XmlObject.selectSingleNode("VirtualPropIncidentLinks")
		If oProp Is Nothing Then
			Set oProp = oSender.XmlObject.appendChild( oSender.XmlObject.ownerDocument.createElement("VirtualPropIncidentLinks") )
		End If	
		' �������� ������ ��������������: Employee-������� ���������, SystemUser-������� ������������ ����������
		With GetCurrentUserProfile()
		    g_sCurrentEmployeeID   = .EmployeeID
		    g_sCurrentSystemUserID = .SystemUserID
		    g_sCurrentWorkdayDuration = .WorkdayDuration
		End With
		If oSender.IsObjectCreationMode Then
			' �������������� ����������
			.AddRelation Nothing, oSender.GetProp("Initiator"), X_CreateObjectStub("SystemUser", g_sCurrentSystemUserID)
		Else
			' ��������� � ����������� ��-�� VirtualPropIncidentLinks ������ �� ������� LinksFromRoleB � LinksFromRoleA
			For Each oValue In .GetXmlProperty(oSender.XmlObject, "LinksFromRoleA").childNodes
				oProp.appendChild X_CreateStubFromXmlObject(oValue)
			Next
			For Each oValue In .GetXmlProperty(oSender.XmlObject, "LinksFromRoleB").childNodes
				oProp.appendChild X_CreateStubFromXmlObject(oValue)
			Next
		End If
	End With	
End Sub


'==============================================================================
Sub usrXEditor_OnSetCaption(oSender, oEventArgs)
	Dim oInitiator			' As IXMLDOMElement - xml-������ Employee - ����������� �������� ���������
	Dim aValues				' As Array - ������ �������� �� ��������� ������
	Dim sFolderPath			' ���� �� ������������ �����
	Dim sOrgPath			' ���� �� ������������ �����������
	Dim FolderID			' ������������� ������� �����
	Dim sCaption  
	Dim oXmlObject 
	
	Set oXmlObject = g_oObjectEditor.XmlObject.selectSingleNode("Folder/Folder")
	If Not oXmlObject Is Nothing Then
		FolderID = g_oObjectEditor.XmlObject.selectSingleNode("Folder/Folder").getAttribute("oid")
		aValues = GetFirstRowValuesFromDataSource("GetFolderPath", Array("FolderID"), Array(FolderID) )
		sFolderPath = aValues(0)
		sOrgPath = aValues(1)
	End If
	sCaption = "<TABLE CELLPADDING=0 CELLSPACING=0 style='color:#fff;' WIDTH='100%'>"
	If Not IsNull(g_oObjectEditor.XmlObject.getAttribute("new"))  Then
		sCaption = sCaption & "<TR><TD COLSPAN=3 style='font-size:14pt;'>����� �������� - " & oEventArgs.PageTitle & "</TD></TR>"
	Else
		sCaption = sCaption  & _
			"<TR><TD COLSPAN=3 style='font-size:14pt;'>" & _
			g_oPool.GetPropertyValue(g_oObjectEditor.XmlObject, "Type.Name") & "  �" & g_oObjectEditor.XmlObject.selectSingleNode("Number").text & _
			"</TD></TR>"
	End If
	
	If Not IsEmpty(sOrgPath) Then _
		sCaption = sCaption & "<TR><TD>&nbsp;&nbsp;</TD><TD style='font-size:12pt;' valign=top>������:&nbsp;&nbsp;</TD><TD style='font-size:12pt;' width='100%'>" & sOrgPath & "</TD></TR>"
	If Not IsEmpty(sFolderPath) Then _
		sCaption = sCaption & "<TR><TD>&nbsp;&nbsp;</TD><TD style='font-size:12pt;' valign=top>������:&nbsp;&nbsp;</TD><TD style='font-size:12pt;' width='100%'>" & sFolderPath & "</TD></TR>"
		
	' �������� Initiator (����������� ���������) ��������������� �� �������, ����� �����������
	If IsNull(g_oObjectEditor.XmlObject.getAttribute("new")) Then
		Set oInitiator = g_oPool.GetXmlObjectByOPath(g_oObjectEditor.XmlObject, "Initiator.Employee")
		sCaption = sCaption & "<TR><TD>&nbsp;&nbsp;</TD><TD COLSPAN=2 style='font-size:10pt;'>���������������: " & g_oPool.GetPropertyValue(oInitiator, "LastName") & " " & g_oPool.GetPropertyValue(oInitiator, "FirstName") & _
		", ����: " & GetDateValue(g_oObjectEditor.XmlObject.selectSingleNode("InputDate").nodeTypedValue) & "</TD></TR>"
	End If
	sCaption = sCaption & "</TABLE>"
	oEventArgs.EditorCaption = sCaption
End Sub


'==============================================================================
'	[in] oEventArgs As EditorStateChangedEventArgs
Sub usrXEditor_OnBeforePageStart(oSender, oEventArgs)
	Dim oIncidentType
	Dim sObjectID
	
	If oSender.IsObjectCreationMode Then
		' ������ � ������ �������� (������ ��������� � ������ ��������� � ������� ����� �� 1-�� ����)
		If "IncidentTypeSelection" = oSender.CurrentPage.PageName Then
			' �� ������ �������� ��� ������ ������ �����, ������� � ��� ��� ��������� �� ���������
			' ���� ��� ��������� �� �����, �� ������� ��� �� �������� ����� "��� ��������� �� ���������" (���� �� ��� �����)
			If Not oSender.XmlObject.selectSingleNode("Type").hasChildNodes Then
				' ���� ��� �����, ��������� ���
				Set oIncidentType = oSender.Pool.GetXmlProperty( oSender.XmlObject, "Folder.DefaultIncidentType")
				' Nothing �����, ���� ������ �� Folder ���
				If oIncidentType Is Nothing Then Err.Raise -1, "usrXEditor_OnBeforePageStart", "ASSERT: �� ������ ������ �� ����� (Folder)"
				If oIncidentType.hasChildNodes Then
					sObjectID = oIncidentType.firstChild.getAttribute("oid")
					oSender.Pool.AddRelation Nothing, oSender.GetProp("Type"), oSender.Pool.GetXmlObject("IncidentType", sObjectID, "Props States")
				End If
			End If
		ElseIf "PriorityTasksLinksProps" = oSender.CurrentPage.PageName Then
			' �� ������ �������� ��� ������ ����� ��� ���������
			' �������� ��������� �������������� ������� ���������
			Set oIncidentType = oSender.Pool.GetXmlObjectByOPath(oSender.XmlObject, "Type")
			If oIncidentType Is Nothing Then Err.Raise -1, "usrXEditor_OnBeforePageStart", "ASSERT: �� ������� �������� ������ �� ��� ���������"
			
			'���� ������ ��� ��������� �� ���������� ���� ��� ������ �� ���� ��� ������� � ������ ���, �� ������� �� ���� �������������� �������� � ������ ���-��,
			'������� ����� ���� ����������� �� ���� ��������.
			'������������� ������ ��������� ��������� ��������� ������ �� ��� ���� � ��������� �������������� �������� � ���
			If g_bHasIncidentTypeChanged Then 
			   clearValues oSender.Pool,oSender.XmlObject
			   fillAbsentIncidentPropsFromIncidentType oSender.Pool, oSender.XmlObject, oIncidentType
			   setInitialStateFromIncidentType oSender.Pool, oSender.XmlObject, oIncidentType
			   setDefaultPriorityFromIncidentType oSender.Pool, oSender.XmlObject, oIncidentType 
			   g_bHasIncidentTypeChanged=False
			 End If  
			  			 
			'���� �������� Tasks �� �����������, �� ������� ������� ��� �������� ������������ 
			If  Not oSender.XmlObject.selectSingleNode("Tasks").hasChildNodes Then createInitiatorTaskByDefaultFromIncidentType oSender.Pool, oSender.XmlObject, oIncidentType
		End If
	ElseIf "��������������" = oSender.CurrentPage.PageTitle OR "AdditionalProperties" = oSender.CurrentPage.PageName Then
			Set oIncidentType = oSender.Pool.GetXmlObjectByOPath(oSender.XmlObject, "Type")
			If oIncidentType Is Nothing Then Err.Raise -1, "usrXEditor_OnBeforePageStart", "ASSERT: �� ������� �������� ������ �� ��� ���������"
			fillAbsentIncidentPropsFromIncidentType oSender.Pool, oSender.XmlObject, oIncidentType
	End If
End Sub


'==============================================================================
'	[in] oEventArgs As EditorStateChangedEventArgs
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	If "��������" = oSender.CurrentPage.PageTitle Then
		refreshCustomVisualsForCurrentTask
		updateIncidentLinksOnMainPage
	End If
End Sub


'==============================================================================
' ��������� �������� ��� ����������
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim oTask
	Dim oTimeSpent		' xml-������ "�������� ������� �� �������"
	Dim oTimeSpentList	' xml-�������� "�������� �������"
	Dim bFound
	
	' ���� ���������� ��������� ���������, �� ������ ���� ��������� �����, ���� � ��������� ���� ������� ��� �������� �����.
	' ���� ��� �� ���, �� �����������
	If Not oSender.IsObjectCreationMode Then
		If Not IsNull(oSender.XmlObject.selectSingleNode("State").getAttribute("dirty")) Then
			' ��������� ����������, ��������, ��� ���� ��������� �����
			Set oTask = getCurrentUserTask(oSender.XmlObject)
			If Not oTask Is Nothing Then
				bFound = False
				Set oTimeSpentList = g_oPool.GetXmlObjectsByOPath(oTask,"TimeSpentList")
				If Not oTimeSpentList Is Nothing Then
					' ������� ��������� ������ �������� ������� �������� ����� � �������� ���� �� � ���� ������� ������ �������
					Set oTimeSpent = oTimeSpentList.item(oTimeSpentList.length-1)
					If Not Nothing Is oTimeSpent Then
						If Not IsNull(oTimeSpent.GetAttribute("new")) Then bFound = True
					End If
				End If
				If Not bFound Then
					' ��� �������� ��� ������ �������
					
					' �������� ��� ����� �������� ���, ���� ��� 0, �� � �������� �� �����
					If g_sCurrentWorkdayDuration = 0 Then Exit Sub
					
					If vbNo = MsgBox( "��� ��������� ��������� ������ ���� ��������� ����������� �����. �� �������, ��� ������ ��������� �������� ��� ���������� ������������ �������?", vbYesNo Or vbQuestion Or vbDefaultButton2 ) Then
						oEventArgs.ReturnValue = False
						Exit Sub
					End If
					
					' ������� �� �������. ������ �� ���������� ����������
					'MsgBox "��� ��������� ��������� ������ ���� ��������� ����������� �����.", vbOkOnly Or vbExclamation
					'oEventArgs.ReturnValue = False
				End If
			End If
		End If
	End If
End Sub


'==============================================================================
' ���������� ������� Accel
' 	[in] oEventArgs As AccelerationEventArgsClass
Sub usrXEditor_OnAccel(oSender, oEventArgs)
	Dim oPEName
	Dim oPEDescr
	Dim oPESolution
	Dim bAsk

	If oEventArgs.keyCode = VK_ESC Then
		If MsgBox("�� �������, ��� ������ ������� " & iif(oSender.IsEditor,"��������","������") & "?", vbYesNo Or vbQuestion, "��������") = vbNo Then
			oEventArgs.Processed = True
		End If
	End If
End Sub


'==============================================================================
' �������� ����� ����� �� ������������ ������� 
'	[in] sTitle - ��������� ����
' 	[in] nTime - ��������� ��������
'	[retvla] �������� ����� ��������������, ���� � ������� ������ ��, ���� ��������� ��������, ���� ������ ������
Function getValueFromTimeDialog(sTitle, nTime)
	dim vRet		' ������� �� ��������� �������
	getValueFromTimeDialog = nTime
	vRet = X_ShowModalDialogEx( "p-TimeChange.aspx", _
			Array(nTime, GetHoursInDay(), sTitle & ":"), _
			"dialogWidth:400px;dialogHeight:200px;help:no;border:thin;center:yes;status:no")
	If Not HasValue(vRet) Then Exit Function
	getValueFromTimeDialog = CLng(vRet)
End Function


'==============================================================================
' ���������� ������� ��������� ������ "����������� �����" � "���������� �����".
' ������������ �� XSLT
' ������ �����, ���� ������� ��������� ����� ������� � ������ ���������, �� ������� ���� ����� �� ���������
Function getUserHoursVisibility()
	Dim oTask
	Dim oRightsChecker		' As RightsChecker
	Dim oXmlProp			' As IXMLDOMElement - xml-��������

	getUserHoursVisibility = "none"
	Set oTask = getCurrentUserTask(g_oObjectEditor.XmlObject)
	If Not oTask Is Nothing Then
'		Set oRightsChecker = New RightsChecker
'		oRightsChecker.Initialize g_oObjectEditor
'		Set oXmlProp = oTask.selectSingleNode("TimeSpentList")
'		oRightsChecker.AddCheckForCreateObjectInProp Nothing, oXmlProp, "TimeSpent", "Incident.Folder"
'		oRightsChecker.ExecuteRightsRequest()
		If oTask.getAttribute("change-right") = "1" Then
			getUserHoursVisibility = "block"
		End If
	End If
End Function


'==============================================================================
' �������������� ���������������� ������� �� ������� �������� ������������
Private Sub editUserHoursLeft()
	Dim oTask			' ������� �������� ������������
	Dim nTimeLeft		' ���������� ����� (���������� ��������)
	Dim nTimeLeftNew	' ���������� ����� (����� ��������)
	Dim oXmlProp		' xml-��������

	Set oTask = getCurrentUserTask(g_oObjectEditor.XmlObject)
	If oTask Is Nothing Then _
		Err.Raise -1, "editUserHoursLeft", "�� ������� �������� ������� �������� ����������"
	nTimeLeft = oTask.selectSingleNode("LeftTime").nodeTypedValue
	nTimeLeftNew = getValueFromTimeDialog("�������� ���������� �����", nTimeLeft)
	If nTimeLeftNew=nTimeLeft Then Exit Sub

	g_oObjectEditor.SetPropertyValue oTask.selectSingleNode("LeftTime"), nTimeLeftNew
	Set oXmlProp = oTask.selectSingleNode("PlannedTime")
	' ������� �������� "��������������� �����" ������ ���� ��� �� read-only
	If IsNull(oXmlProp.getAttribute("read-only")) Then
		' ������ � ���������� �������� � ��������������� �����
		g_oObjectEditor.SetPropertyValue oXmlProp, nTimeLeftNew
		' � ����� ������������ ��������� ��� �������� ����������
		g_oPool.RemoveAllRelations oTask, "Planner"
		g_oPool.AddRelation oTask, "Planner", X_CreateObjectStub("Employee", g_sCurrentEmployeeID)
	End If
	
	' ������� ����������� ������
	refreshCustomVisualsForTask oTask
	' ������� ������ �������
	refreshTasks
End Sub


'==============================================================================
' �������������� ������������ ������� ������� �������������
Private Sub editUserHoursSpent()
	Dim oTask			' xml-������ ������� �������� �����
	Dim nTime			' ���-�� ���������� �������
	Dim oTimeSpent		' xml-������ "�������� ������� �� �������"
	Dim oTimeSpentList	' xml-�������� "�������� �������"
	Dim nTimeLeft		' ���������� �����
	
	Set oTask = getCurrentUserTask(g_oObjectEditor.XmlObject)
	If oTask Is Nothing Then _
		Err.Raise -1, "editUserHoursSpent", "�� ������� �������� ������� �������� ����������"
	nTime = getValueFromTimeDialog("�������� � ������������ �������", 0)
	If 0=nTime Then Exit Sub
	
	Set oTimeSpentList = g_oPool.LoadXmlProperty(oTask,"TimeSpentList")
	' ������� ��������� ������ �������� ������� �������� ����� � �������� ���� �� � ���� ������� ������ �������
	Set oTimeSpent = oTimeSpentList.LastChild
	If Not Nothing Is oTimeSpent Then
		Set oTimeSpent = g_oPool.GetXmlObjectByXmlElement(oTimeSpent, Null)
		If IsNull(oTimeSpent.GetAttribute("new")) Then Set oTimeSpent = Nothing
	End If
	If Nothing Is oTimeSpent Then
		' ��� ������������� �������� - �������� �����
		Set oTimeSpent = g_oPool.CreateXmlObjectInPool("TimeSpent")
		g_oPool.AddRelation Nothing, oTimeSpentList, oTimeSpent
	End If
	' ������� ��-�� "���������� �������" (� �������)
	Set oTimeSpent = oTimeSpent.selectSingleNode("Spent")
	If IsNull(oTimeSpent.nodeTypedValue) Then
		oTimeSpent.nodeTypedValue = nTime
	Else
		oTimeSpent.nodeTypedValue = nTime + oTimeSpent.nodeTypedValue
	End If
	
	' �������� ���������� ����� �� ��������� ��������
		nTimeLeft = oTask.selectSingleNode("LeftTime").nodeTypedValue
	If IsNull(nTimeLeft) Then nTimeLeft = 0
	' ���� �������� ������, ��� ���������, ��� ��������� 0
	If nTimeLeft < nTime Then 
		nTimeLeft = 0
	Else
		nTimeLeft = nTimeLeft - nTime
	End If
	g_oObjectEditor.SetPropertyValue oTask.selectSingleNode("LeftTime"), nTimeLeft
	
	' ������� ����������� ������
	refreshCustomVisualsForTask oTask
	' ������� ������ �������
	refreshTasks
End Sub


'==============================================================================
' ��������� ������ ��� �������� "������" (Tasks)
Sub refreshTasks( )
	Dim oTaskListEditor
	Set oTaskListEditor = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.GetProp("Tasks"))
	If Nothing Is oTaskListEditor Then Exit Sub
	oTaskListEditor.SetData()
End Sub


'==============================================================================
' ������� � ���� ����� ������ "�������� �������� ���������" ��� ��������� ��������
' [in] ������ �� ������ "������� ���������" ("IncidentProp")
Function createIncidentPropValue(oIncidentProp) 
	Dim oObject
	with g_oPool
		Set oObject = .CreateXmlObjectInPool("IncidentPropValue")
		.AddRelation oObject, "IncidentProp", oIncidentProp
		' ��������� �������� �� ���������
		setIncidentPropertyDefaultValue oObject, oIncidentProp
	End With
	Set createIncidentPropValue = oObject
End Function


'==============================================================================
Sub setIncidentPropertyDefaultValue(oIncidentPropValue, ByVal oIncidentProp)
	Dim nType
	
	Set oIncidentProp = g_oPool.GetXmlObjectByXmlElement(oIncidentProp, Null)
	nType = oIncidentProp.SelectSingleNode("Type").NodeTypedValue
	Select Case nType
		Case IPROP_TYPE_IPROP_TYPE_LONG, IPROP_TYPE_IPROP_TYPE_DOUBLE, IPROP_TYPE_IPROP_TYPE_BOOLEAN:
			g_oPool.SetPropertyValue oIncidentPropValue.SelectSingleNode("NumericData"), oIncidentProp.SelectSingleNode("DefDouble").nodeTypedValue
		Case IPROP_TYPE_IPROP_TYPE_DATE, IPROP_TYPE_IPROP_TYPE_TIME, IPROP_TYPE_IPROP_TYPE_DATEANDTIME :
			g_oPool.SetPropertyValue oIncidentPropValue.SelectSingleNode("DateData"), oIncidentProp.SelectSingleNode("DefDate").nodeTypedValue
		Case IPROP_TYPE_IPROP_TYPE_STRING :
			g_oPool.SetPropertyValue oIncidentPropValue.SelectSingleNode("StringData"), oIncidentProp.SelectSingleNode("DefText").nodeTypedValue
		Case IPROP_TYPE_IPROP_TYPE_TEXT :
			g_oPool.SetPropertyValue oIncidentPropValue.SelectSingleNode("TextData"), oIncidentProp.SelectSingleNode("DefText").nodeTypedValue
		Case IPROP_TYPE_IPROP_TYPE_PICTURE :
			' Nothing to do
		Case IPROP_TYPE_IPROP_TYPE_FILE :
			' Nothing to do
		Case Else
			Stop
	End Select
End Sub


'----------------------------------------------------------
Sub fillAbsentIncidentPropsFromIncidentType(oPool, oIncident, oIncidentType)
	Dim oIncidentProps
	Dim oIncidentProp
	Dim oIncidentPropValue
	Dim oExistingPropDictionary
	
	Set oExistingPropDictionary = CreateObject("Scripting.Dictionary")
	oExistingPropDictionary.CompareMode = vbTextCompare
	
	With oPool
		' ������������ ��� �������� �������� ��������� � ������� �������������� ������������ ������� � �������
		Set oIncidentProps = .GetXmlProperty( oIncident, "Props")
		For Each oIncidentProp In oIncidentProps.SelectNodes("*")
			oExistingPropDictionary.Item(.GetPropertyValue(oIncidentProp, "IncidentProp.ObjectID"))=True
		Next
		' ������ ������������ ��� �������� � ������� ����������� ��������
		Set oIncidentProps = .GetXmlProperty( oIncidentType, "Props")
		For Each oIncidentProp In oIncidentProps.SelectNodes("*")
			If Not .GetPropertyValue(oIncidentProp, "IsArchive") Then
				If Not .GetPropertyValue(oIncidentProp, "IsArray") Then
					If Not oExistingPropDictionary.Exists(oIncidentProp.GetAttribute("oid")) Then
						' �������� ����� �������� (��� ������������ ��������������)
						Set oIncidentPropValue = createIncidentPropValue(oIncidentProp)
						.AddRelation oIncident, "Props", oIncidentPropValue
					End If	
				End If	
			End If	
		Next
	End With
End Sub

'----------------------------------------------------------
'������� �� ���� �������, �������������� ��������� �������������� �������, ������� ��������������� �� �������� "PriorityTasksLinksProps", 
'� ����� ������� �������������� ��������� ���-��
Sub clearValues(oPool, oIncident)
   Dim oXmlObjectToDelete '��������� ������ �� ����
   Dim oXmlObject '��������������� ������ ��� �������� �� �����
   Dim oXmlObjectState '������ - ��������� ���-��
   
   '������� ��������� ���������
   Set oXmlObjectState = oIncident.SelectSingleNode("State/IncidentState")
   If Not oXmlObjectState Is Nothing Then oIncident.SelectSingleNode("State").removeChild oXmlObjectState
   
   '�������� �� ���� ��������� ������� � �������� Props � ������� ��    
   For Each oXmlObject in oIncident.selectSingleNode("Props").childNodes
     oPool.RemoveRelation oIncident,"Props",oXmlObject
      Set oXmlObjectToDelete = oPool.FindXmlObject("IncidentPropValue",oXmlObject.GetAttribute("oid"))
      '����� ������� �� ����  �������������� ������ ���� IncidentPropValue
      If Not oXmlObjectToDelete Is Nothing Then
         If Not IsNull(oXmlObjectToDelete.getAttribute("new")) Then  oPool.Xml.removeChild oXmlObjectToDelete
      End If  
   Next 
   
   Set oXmlObjectToDelete = Nothing
   
   '�������� �� ���� �������� ���-�� �� �������� Tasks � ������� ��
   For Each oXmlObject in oIncident.selectSingleNode("Tasks").childNodes
     oPool.RemoveRelation oIncident,"Tasks",oXmlObject
      Set oXmlObjectToDelete = oPool.FindXmlObject("Task",oXmlObject.GetAttribute("oid"))
      '����� ������� �� ����  �������������� ������ ���� Task
      If Not oXmlObjectToDelete Is Nothing Then
         If Not IsNull(oXmlObjectToDelete.getAttribute("new")) Then  oPool.Xml.removeChild oXmlObjectToDelete
      End If  
   Next 

End Sub
'----------------------------------------------------------
Sub setDefaultPriorityFromIncidentType(oPool, oIncident, oIncidentType)
	oPool.SetPropertyValue oIncident.SelectSingleNode("Priority"), oIncidentType.SelectSingleNode("DefaultPriority").nodeTypedValue
End Sub

'----------------------------------------------------------
Sub setInitialStateFromIncidentType(oPool, oIncident, oIncidentType)
	Dim oIncidentStates
	Dim oIncidentState
	With oPool
		Set oIncidentStates = .GetXmlProperty( oIncidentType, "States")
		For Each oIncidentState In oIncidentStates.SelectNodes("*")
			If .GetPropertyValue(oIncidentState, "IsStartState") Then
				.AddRelation oIncident, "State", oIncidentState
				Exit For
			End If
		Next
	End With
End Sub


'==============================================================================
' ������� ������� ��� �������� ������������ 
Sub createInitiatorTaskByDefaultFromIncidentType(oPool, oIncident, oIncidentType)
	Dim sRoleID
	Dim oInitiatorRole
	Dim oTask
	Dim oRightsChecker		' As RightsChecker
	Dim oXmlProp			' As IXMLDOMElement - xml-��������
	
	' ������� ������������� "���� ����������� � ���������" �� ��������� ��� �������� ������������ �� ��������� ��� ���� � ������� �����
	sRoleID = GetScalarValueFromDataSource("GetDefaultIncidentRole", _
		Array("FolderID", "EmployeeID", "IncidentTypeID"), _
		Array( _
			oPool.GetPropertyValue( oIncident, "Folder.ObjectID"), _
			g_sCurrentEmployeeID, _
			oIncidentType.getAttribute("oid")) )

	If hasValue(sRoleID) Then
		Set oInitiatorRole = oPool.GetXmlObject( "UserRoleInIncident", sRoleID, Null )

		' ������� ����� �� �������� ������� Task � �������� Tasks �������� ���������
		Set oRightsChecker = New RightsChecker
		oRightsChecker.Initialize g_oObjectEditor
		Set oXmlProp = oIncident.selectSingleNode("Tasks")
		oRightsChecker.AddCheckForCreateObjectInProp Nothing, oXmlProp, "Task", "Folder"
		oRightsChecker.ExecuteRightsRequest()
		
		' �������� ������ �� ������� �� �������� � �������������� ���������� ����������� ������� �� ��������� ����������� ����
		Set oTask = CreateXmlObjectInProp(oPool, "Task", oXmlProp )
		oPool.AddRelation oTask, "Role" , oInitiatorRole
		oPool.AddRelation oTask, "Worker" , X_CreateObjectStub("Employee", g_sCurrentEmployeeID)
		oPool.SetPropertyValue oTask.SelectSingleNode("PlannedTime"), oInitiatorRole.SelectSingleNode("DefDuration").nodeTypedValue
		oPool.SetPropertyValue oTask.SelectSingleNode("LeftTime"), oInitiatorRole.SelectSingleNode("DefDuration").nodeTypedValue
	End If
End Sub


'==============================================================================
' ���������� xml-������ ������� (Task), � ������� ������� ������������ �������� ������������
'	[in] oIncident - xml-������ ��������
Function getCurrentUserTask(oIncident)
	Dim oTask
	Set getCurrentUserTask = Nothing
	With g_oPool
		For Each oTask In .GetXmlProperty(  oIncident , "Tasks").SelectNodes("*")
			If .GetPropertyValue(oTask,"Worker.ObjectID") = g_sCurrentEmployeeID Then
				Set getCurrentUserTask = .GetXmlObjectByXmlElement(oTask, Null)
				Exit For
			End If
		Next
	End With	
End Function


'==============================================================================
' ��������� ����������� ������ ��� ���������� ���������� ��������� ���������
Sub usr_Incident_State_ObjectDropDown_OnGetRestrictions(oSender, oEventArgs)
	Dim oTask
	Dim oRole
	
	' ����� ���� �������� ������������ � ������ ���������
	Set oTask = getCurrentUserTask(g_oObjectEditor.XmlObject)
	If Not oTask Is Nothing Then
		Set oRole = g_oPool.GetXmlProperty(oTask, "Role").firstChild
		oEventArgs.ReturnValue = "UserRoleID=" & oRole.getAttribute("oid")
	End If
	' ������� ���������, ����� � ��� ��������� ������ ������
	oEventArgs.ReturnValue = oEventArgs.ReturnValue & _
		"&CurrentStateID=" & oSender.InitialValue.getAttribute("oid") & _
		"&FolderID=" & g_oObjectEditor.XmlObject.selectSingleNode("Folder/Folder").getAttribute("oid") & _
		"&IncidentTypeID=" & g_oObjectEditor.XmlObject.selectSingleNode("Type/IncidentType").getAttribute("oid")
End Sub

'==============================================================================
' ��������� ����������� ������ ��� ���������� ���������� ��������� "����� ����������"
Sub usr_Incident_Type_ObjectDropDown_OnGetRestrictions(oSender, oEventArgs)
	' ����� � ��� ��������� ������ ������
	oEventArgs.ReturnValue = oEventArgs.ReturnValue & _
		"&FolderID=" & g_oObjectEditor.XmlObject.selectSingleNode("Folder/Folder").getAttribute("oid")
End Sub
'==============================================================================
Sub usr_Incident_Type_ObjectDropDown_OnChanged(oSender, oEventArgs)
'���� ��������� � ������ �������� ��������� � �������� ��� ���, �� ���������� ���� ���� 
   g_bHasIncidentTypeChanged = True
End Sub
'==============================================================================
' ����������� �������� ��� ��������� (Task)
Sub usr_Incident_Tasks_ObjectsElementsList_OnAfterCreate(oSender, oEventArgs)
	refreshCustomVisualsForCurrentTask
End Sub

Sub usr_Incident_Tasks_ObjectsElementsList_OnAfterMarkDelete(oSender, oEventArgs)
	refreshCustomVisualsForCurrentTask
End Sub

Sub usr_Incident_Tasks_ObjectsElementsList_OnAfterEdit(oSender, oEventArgs)
	refreshCustomVisualsForCurrentTask
End Sub

Sub refreshCustomVisualsForCurrentTask()
	refreshCustomVisualsForTask getCurrentUserTask(g_oObjectEditor.XmlObject)
End Sub


'==============================================================================
' ��������� ����������� ������ "���������" � "��������"
Sub refreshCustomVisualsForTask(oTask)
	Dim oTBody

	Set oTBody = document.all("tbodyUserHours",0)
	If Nothing Is oTBody Then Exit Sub
	If Nothing Is oTask Then
		oTBody.style.display="NONE"
	ElseIf oTask.getAttribute("change-right") = "1" Then
		oTBody.style.display="BLOCK"
		document.all("UserHoursSpent",0).innerText = FormatTimeString( getTaskTimeSpent(g_oPool, oTask) )
		document.all("UserHoursLeft",0).innerText  = FormatTimeString( g_oPool.GetPropertyValue(oTask, "LeftTime") )
	Else
		oTBody.style.display="NONE"
	End If
End Sub


Function GetIncidentPropValueBinSize(oPool, oIncidentPropValue)
	GetIncidentPropValueBinSize = SafeClng( oPool.GetXmlObjectByXmlElement(oIncidentPropValue, Null).SelectSingleNode("FileData").getAttribute("data-size"))
End Function


'==============================================================================
' ����������� ������� ����� - �-� �����������
Function getIncidentPropID(oPEObjects)
	getIncidentPropID = oPEObjects.HideIf
	getIncidentPropID = MID(getIncidentPropID, InStr(getIncidentPropID, """")+1)
	getIncidentPropID = Left(getIncidentPropID,36)	
End Function


Function getBinaryData(sFileName)
	Dim aFileData
	On Error Resume Next
	' ���������� ��������� ���� � �����
	aFileData = XService.GetFileData(sFileName)
	If Err Then
		X_ErrReportEx "������ ��� ������� ������ �� �����:" & vbNewLine & vbTab & sFileName & vbNewLine & "�������� �� ������������ ������ �����������."  ,err.Description & vbNewLine & err.Source 
		On Error Goto 0
		Exit Function
	End If
	On Error Goto 0	
	getBinaryData = aFileData
End Function


Function createBinaryIncidentPropValue(oPool, oIncidentProps, oIncidentProp, sFileName)
	Dim aFileData
	Dim oIncidentPropValue
	set createBinaryIncidentPropValue = Nothing
	aFileData = getBinaryData(sFileName)
	If IsEmpty(aFileData) Then Exit Function
	set oIncidentPropValue = createIncidentPropValue(oIncidentProp)
	oPool.AddRelation Nothing, oIncidentProps, oIncidentPropValue
	setBinaryIncidentPropValue oPool, oIncidentPropValue, aFileData, sFileName
	Set createBinaryIncidentPropValue = oIncidentPropValue
End Function

Function setBinaryIncidentPropValue(oPool, oIncidentPropValue, aFileData, sFileName)
	With oIncidentPropValue.SelectSingleNode("FileData")
		.removeAttribute "loaded"
		.setAttribute "data-size", UBound(aFileData)
		.setAttribute "local-file-name", sFileName
		.setAttribute "dirty", 1
		.nodeTypedValue = aFileData
	End With
	oPool.SetPropertyValue oIncidentPropValue.SelectSingleNode("StringData"), XService.GetFileTitle(sFileName)
End Function



'==============================================================================
' Visibility-handler ���� ���������� �������� Props ��� ������� ���� �������� (IPROP_TYPE_IPROP_TYPE_PICTURE)
' ����������: ���������� ��������� �������� �����������
Sub IncidentPropsList_MenuVisibilityHandler(oSender, oEventArgs)
	Dim bDisabled		' ������� ����������������� ������
	Dim bHidden			' ������� �������� ������
	Dim oNode			' ������� menu-item
	Dim bProcess		' As Boolean - ������� ��������� �������� ������
	Dim sObjectID		' ������������� ���������� �������

	sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")	
	' ���������� ������ ��������� ��� ��������
	For Each oNode In oEventArgs.ActiveMenuItems
		bHidden = Empty
		bDisabled = Empty
		bProcess = False
		Select Case oNode.getAttribute("action")
			Case "DoCreatePicture"
				bHidden = False
				bProcess = True
			Case "DoEditPicture"
				bHidden = Not hasValue(sObjectID) 
				bProcess = True
			Case "DoUploadNew"
				bHidden = False
				bProcess = True
			Case "DoUpload"
				bHidden = Not hasValue(sObjectID) 
				bProcess = True
			Case "DoView"
				bHidden = Not hasValue(sObjectID) 
				bProcess = True
			Case "DoDownload"
				bHidden = Not hasValue(sObjectID) 
				bProcess = True
			Case "DoMarkDelete"
				bHidden = Not hasValue(sObjectID)
				bProcess = True
		End Select
		If bProcess Then
			If IsEmpty(bHidden) Then bHidden = False
			If IsEmpty(bDisabled) Then bDisabled = False
		End If
		If Not IsEmpty(bHidden) Then
			If bHidden Then 
				oNode.setAttribute "hidden", "1"
			Else
				oNode.removeAttribute "hidden"
			End If
		End If
		If Not IsEmpty(bDisabled) Then
			If bDisabled Then 
				oNode.setAttribute "disabled", "1"
			Else
				oNode.removeAttribute "disabled"
			End If
		End If
	Next
End Sub


'==============================================================================
' Execution-handler ���� ���������� �������� Props ��� ������� ���� �������� (IPROP_TYPE_IPROP_TYPE_PICTURE)
Sub IncidentPropsList_MenuExecutionHandler_ForPicture(oSender, oEventArgs)
	Select Case oEventArgs.Action
		Case "DoCreatePicture"
			IncidentProps_OnCreatePicture oSender
		Case "DoEditPicture"
			IncidentProps_OnEditPicture oSender, oEventArgs.Menu.Macros.Item("ObjectID")
		Case "DoUploadNew"
			IncidentProps_OnUpload oSender, Null
		Case "DoUpload"
			IncidentProps_OnUpload oSender, oEventArgs.Menu.Macros.Item("ObjectID")
		Case "DoView"
			IncidentProps_OnView oSender, oEventArgs.Menu.Macros.Item("ObjectID")
		Case "DoDownload"
			IncidentProps_OnDownload oSender, oEventArgs.Menu.Macros.Item("ObjectID")
	End Select
End Sub


'==============================================================================
' ���������� �������� (DoCreatePicture) �������� �������� �������� ���� �������� (IPROP_TYPE_IPROP_TYPE_PICTURE)
' 	oSender - PE elements-list'a
Sub IncidentProps_OnCreatePicture(oSender)
	Dim sFileName
	Dim oIncidentPropValue
	Dim oIncidentProp
	Dim sIncidentPropID
	Dim oPool
	
	Set oPool = oSender.ObjectEditor.Pool
	sIncidentPropID = getIncidentPropID(oSender)
	Set oIncidentProp = oPool.GetXmlObject("IncidentProp", sIncidentPropID, Null)
	With New ChooseImageDialogClass
		.OffClear = True
		sFileName =	.Show()
	End With
	If Not HasValue(sFileName) Then Exit Sub
	Set oIncidentPropValue = createBinaryIncidentPropValue(oPool, oSender.XmlProperty, oIncidentProp, sFileName)
	If Nothing Is oIncidentPropValue Then Exit Sub
	oSender.SetData
End Sub


'==============================================================================
' ���������� �������� (DoEditPicture) �������������� �������� �������� ���� �������� (IPROP_TYPE_IPROP_TYPE_PICTURE)
' 	[in] oSender - PE elements-list'a
'	[in] sObjectID - ������������� �������������� �������
Sub IncidentProps_OnEditPicture(oSender, sObjectID)
	Dim sFileName
	Dim oIncidentPropValue
	Dim oIncidentProp
	Dim oPool
	Dim aFileData
	Dim sTempFileName	' ������ ��� ���������� �����
	Dim sImageLocation	' ���������� ��������	
	
	Set oPool = oSender.ObjectEditor.Pool
	Set oIncidentPropValue = oPool.GetXmlObject(oSender.ValueObjectTypeName, sObjectID, Null)
	Set oIncidentProp = oPool.GetXmlObjectByXmlElement( oPool.LoadXmlProperty( oIncidentPropValue,  "IncidentProp").firstChild, null)
	
	If IsNull(oIncidentPropValue.SelectSingleNode("FileData").getAttribute("loaded")) Then
		' �������� ��� ��������� � ������ ��������� � XML
		' ������� �������� � ��� ��������� ����
		sTempFileName = XService.GetFileExt( oIncidentPropValue.SelectSingleNode("StringData").text)
		If 0=len(sTempFileName) Then sTempFileName="gif"
		sTempFileName = XService.GetTempPath & XService.NewGUIDString & "." & sTempFileName
		' �������� ���� �� ���� �� ��������� �������,
		' ������� ����������� ��� ��������� ������:
		On Error Resume Next
		XService.SaveFileData sTempFileName, oIncidentPropValue.SelectSingleNode("FileData").nodeTypedValue
		' ���� ���� ������ - ���������� ��������� 
		If 0<>Err.Number Then
			X_ErrReportEx "������ ��� ������� ������ � ���� '" & sTempFileName & "'" & vbNewLine & Err.Description, err.Source 
			On Error Goto 0
			Exit Sub
		End If	
		On Error Goto 0				
		sImageLocation = sTempFileName
	Else
		sImageLocation = _	
			XService.BaseURL & "x-get-image.aspx" & _
			"?ID=" & sObjectID & _
			"&OT=IncidentPropValue&PN=FileData&TM=" & XService.NewGuidString			
		
	End If
	With New ChooseImageDialogClass
		.OffClear = True
		.Url = sImageLocation
		sFileName =	.Show()
	End With
	If Not IsEmpty(sTempFileName) Then
		On Error Resume Next
		' ��������� ������� ����
		XService.CreateObject("Scripting.FileSystemObject").DeleteFile sTempFileName, True
		' ���� ���� ������ - ���������� ��������� 
		If 0<>Err.Number Then
			X_ErrReportEx  "������ ��� ������� �������� ���������� ����� '" & sTempFileName &  "'" & vbNewLine & err.Description, err.Source 
			On Error Goto 0
			' �� ������ �� ����� ����������
		End If
		On Error Goto 0	
	End If	
	
	If Not HasValue(sFileName) Then Exit Sub
	aFileData = getBinaryData(sFileName)
	If IsEmpty(aFileData) Then Exit Sub
	setBinaryIncidentPropValue  oPool, oIncidentPropValue, aFileData, sFileName
	oSender.SetData
End Sub

'==============================================================================
' ���������� �������� (DoUpload) �������� �������� �������� ���� ���� (IPROP_TYPE_IPROP_TYPE_FILE)
' 	oSender - PE elements-list'a
Sub IncidentProps_OnUpload(oSender, sObjectID)
	Dim sFileName
	Dim oIncidentPropValue
	Dim oIncidentProp
	Dim sIncidentPropID
	Dim oPool
	Dim aFileData
	
	Set oPool = oSender.ObjectEditor.Pool
    sIncidentPropID = getIncidentPropID(oSender)
    Set oIncidentProp = oPool.GetXmlObject("IncidentProp", sIncidentPropID, Null)
	
	' �������� ����
    sFileName = toString( XService.SelectFile( _
        "�������� ����", _
        BFF_PATHMUSTEXIST or BFF_FILEMUSTEXIST or BFF_HIDEREADONLY, _
        "", _
        sFileName, _
        "��� ����� (*.*)|*.*||" ) )
        
    ' ���� ������ �� ������� - ������� �� ���������
    If Not hasValue(sFileName) Then Exit Sub
	
	If HasValue(sObjectID) Then
	    Set oIncidentPropValue = oPool.GetXmlObject(oSender.ValueObjectTypeName, sObjectID, Null)
	    aFileData = getBinaryData(sFileName)
	    If IsEmpty(aFileData) Then Exit Sub
	    setBinaryIncidentPropValue  oPool, oIncidentPropValue, aFileData, sFileName
	    oSender.SetData
	Else
        
        Set oIncidentPropValue = createBinaryIncidentPropValue(oPool, oSender.XmlProperty, oIncidentProp, sFileName)
        If Nothing Is oIncidentPropValue Then Exit Sub
        oSender.SetData
    End If
End Sub

'==============================================================================
' ���������� �������� (DoView) ��������� �������� �������� ���� ���� (IPROP_TYPE_IPROP_TYPE_FILE)
' 	[in] oSender - PE elements-list'a
'	[in] sObjectID - ������������� �������������� �������
Sub IncidentProps_OnView(oSender, sObjectID)
	Dim sFileName
	Dim oIncidentPropValue
	Dim oIncidentProp
	Dim oPool
	Dim aFileData
	Dim sPropertyUrl
	
	Set oPool = oSender.ObjectEditor.Pool
	Set oIncidentPropValue = oPool.GetXmlObject(oSender.ValueObjectTypeName, sObjectID, Null)
	Set oIncidentProp = oPool.GetXmlObjectByXmlElement( oPool.LoadXmlProperty( oIncidentPropValue,  "IncidentProp").firstChild, null)
	
	If IsNull(oIncidentPropValue.SelectSingleNode("FileData").getAttribute("loaded")) Then
		' �������� ��� ��������� � ������ ��������� � XML
		' ������� �������� � ��� ��������� ����
		sFileName = XService.GetFileExt( oIncidentPropValue.SelectSingleNode("StringData").text)
		sFileName = XService.GetTempPath & XService.NewGUIDString & iif(0=len(sFileName), "" , "." & sFileName)
		' �������� ���� �� ���� �� ��������� �������,
		' ������� ����������� ��� ��������� ������:
		On Error Resume Next
		XService.SaveFileData sFileName, oIncidentPropValue.SelectSingleNode("FileData").nodeTypedValue
		' ���� ���� ������ - ���������� ��������� 
		If 0<>Err.Number Then
			X_ErrReportEx "������ ��� ������� ������ � ���� '" & sFileName & "'" & vbNewLine & Err.Description, err.Source 
			On Error Goto 0
			Exit Sub
		End If	
		On Error Goto 0				
		
		On Error Resume Next
		' "��������" ���...
		XService.ShellExecute sFileName
		' ���� ���� ������ - ���������� ��������� 
		If 0<>err.number Then
			X_ErrReportEx  "������ ��� ������� ��������� ����� '" & sFileName &  "'" & vbNewLine & err.Description, err.Source 
			On Error Goto 0
			Exit Sub	
		End If	
		On Error Goto 0
		
		' ������� ���� ������������ �� ������ OK � ������ �������� ���������...
		MsgBox "�� ���������� ��������� ������� ""OK""", vbInformation, "�������� �����"
		
        On Error Resume Next
        XService.CreateObject("Scripting.FileSystemObject").DeleteFile sFileName, True
        If 0<>Err.Number Then
            X_ErrReportEx  "������ ��� ������� �������� ���������� ����� '" & sFileName &  "'" & vbNewLine & err.Description, err.Source
            On Error Goto 0
			Exit Sub	
		End If 
        On Error Goto 0
	Else
	    ' �������� � ������� (�� �� ����� LoadProp)
		' ������� ��� ���������� �����
		sFileName = oIncidentPropValue.SelectSingleNode("StringData").text
		sFileName = XService.GetTempPath & sFileName
		
		sPropertyUrl = _
					XService.BaseURL & "x-get-image.aspx" & _
					"?ID=" & sObjectID & _
					"&OT=" & oSender.ValueObjectTypeName & _
					"&PN=" & "FileData" & _
					"&TM=" & XService.NewGuidString
					
		' �������� ������ ��������
		X_ShowModalDialogEx _
			XService.BaseURL & "x-download.aspx", _
			Array( sPropertyUrl, sFileName, 0, True), _
			"dialogWidth:400px; dialogHeight:150px; help:no; center:yes; status:no"				
	End If
End Sub

'==============================================================================
' ���������� �������� (DoDownload) �������� �������� �������� ���� ���� (IPROP_TYPE_IPROP_TYPE_FILE)
' 	[in] oSender - PE elements-list'a
'	[in] sObjectID - ������������� �������������� �������
Sub IncidentProps_OnDownload(oSender, sObjectID)
	Dim sFileName
	Dim oIncidentPropValue
	Dim oIncidentProp
	Dim oPool
	Dim aFileData
	Dim sPropertyUrl
	
	Set oPool = oSender.ObjectEditor.Pool
	Set oIncidentPropValue = oPool.GetXmlObject(oSender.ValueObjectTypeName, sObjectID, Null)
	Set oIncidentProp = oPool.GetXmlObjectByXmlElement( oPool.LoadXmlProperty( oIncidentPropValue,  "IncidentProp").firstChild, null)
	
	' ���������� ������� ����� 
	sFileName = ToString( XService.SelectFile("������� ���� ��� ����������", BFF_SAVEDLG, "", sFileName, "��� ����� (*.*)|*.*||") )
	If hasValue(sFileName) Then
		If IsNull(oIncidentPropValue.SelectSingleNode("FileData").getAttribute("loaded")) Then
			' ������� ����������� ��� ��������� ������:
			On Error Resume Next
			XService.SaveFileData sFileName, oIncidentPropValue.SelectSingleNode("FileData").nodeTypedValue
			' ���� ���� ������ - ���������� ��������� 
			If 0<>Err.Number Then
				X_ErrReportEx "������ ��� ������� ������ � ���� '" & sFileName & "'" & vbNewLine & Err.Description, err.Source 
			End If	
			On Error Goto 0
		Else
		    sPropertyUrl = _
					XService.BaseURL & "x-get-image.aspx" & _
					"?ID=" & sObjectID & _
					"&OT=" & oSender.ValueObjectTypeName & _
					"&PN=" & "FileData" & _
					"&TM=" & XService.NewGuidString
			' �������� ������ ��������
			X_ShowModalDialogEx _
				XService.BaseURL & "x-download.aspx", _
				Array( sPropertyUrl , sFileName, 0, False) , _
				"dialogWidth:400px; dialogHeight:150px; help:no; center:yes; status:no"
		End If
	End If
End Sub

'==============================================================================
' ���������� �� xsl ��� ����������� ������������� ����������� �������� ���������
Function ShowCategory
	' TODO: ���������� �������� ����� ����� ������ � ������, ���� ��� ���� ��������� ������ ���������
	ShowCategory = True
End Function


'==============================================================================
' ����������� ��� ������ ��������� �� ������ (objects-tree-selector'a)
Sub usr_Incident_Category_ObjectPresentation_OnGetRestrictions(oSender, oEventArgs)
	oEventArgs.ReturnValue = "IncidentTypeID=" & g_oPool.GetPropertyValue(g_oObjectEditor.XmlObject, "Type.ObjectID")
End Sub


'==============================================================================
' ����������� �������� ��� �������� (IncidentLink)
Sub usr_Incident_VirtualPropIncidentLinks_OnAfterCreate(oSender, oEventArgs)
	updateIncidentLinksOnMainPage
End Sub

Sub usr_Incident_VirtualPropIncidentLinks_OnAfterMarkDelete(oSender, oEventArgs)
	updateIncidentLinksOnMainPage
End Sub

Sub usr_Incident_VirtualPropIncidentLinks_OnAfterEdit(oSender, oEventArgs)
	updateIncidentLinksOnMainPage
End Sub

'==============================================================================
' ���������� ������������� ������ �/�� ��������� �� ������ �������� ���������
Sub updateIncidentLinksOnMainPage
	Dim oObject
	Dim oLinkList
	Dim oIncident
	Dim sText
	Dim oPageHtml

	' ��������� ����� ���� ������ � ���������!
	If g_oObjectEditor.IsObjectCreationMode Then Exit Sub

	Set oLinkList = g_oPool.GetXmlObjectsByOPath(g_oObjectEditor.XmlObject, "LinksFromRoleA")
	If Not oLinkList Is Nothing Then
		For Each oObject In oLinkList
			Set oIncident = g_oPool.GetXmlObjectByOPath(oObject, "RoleB")
			sText = sText & "<img src='" & XService.BaseURL & "Images/link-fromThis.gif' height=10 width=10>&nbsp;"
			sText = sText & getIncidentPresentation(oIncident) & "<BR>"
		Next
	End If
	Set oLinkList = g_oPool.GetXmlObjectsByOPath(g_oObjectEditor.XmlObject, "LinksFromRoleB")
	If Not oLinkList Is Nothing Then
		For Each oObject In oLinkList 
			Set oIncident = g_oPool.GetXmlObjectByOPath(oObject, "RoleA")
			sText = sText & "<img src='" & XService.BaseURL & "Images/link-toThis.gif' height=10 width=10>&nbsp;"
			sText = sText & getIncidentPresentation(oIncident) & "<BR>"
		Next
	End If
	Set oPageHtml = g_oObjectEditor.Pages.Items()(0).HtmlDivElement
	If Len(sText) > 0 Then
		sText = sText & "<a href='' onclick='SwitchToPageWithLinks' language='VBScript' style='color:navy;'><U>������� �� �������� �� ������� ��������� ����������</U></a><br><br>"
		oPageHtml.all("oIncidentLinksCaption").innerHtml = "�����:"
	Else	
		oPageHtml.all("oIncidentLinksCaption").innerHtml = ""
	End If
	oPageHtml.all("oIncidentLinksPlaceHolder").innerHtml = sText
End Sub


Sub SwitchToPageWithLinks
	Tabs.ActiveTab = 1
	window.event.returnValue = False
	window.event.cancelBubble = True
End Sub


Function getIncidentPresentation(oIncident)
	Dim sNumber
	Dim sName
	sNumber = oIncident.selectSingleNode("Number").text
	sName = oIncident.selectSingleNode("Name").text
	If Len(sName) > 512 Then sName = Left(sName,512) & "..." 
	If IsNull(oIncident.getAttribute("new")) Then
		getIncidentPresentation = "<a href='' onClick='OpenIncidentViewByNumberLocal " & sNumber & "' style='color:navy;' language='VBScript'><B>�" & sNumber & " " & sName & "</B></a>"
	Else
		getIncidentPresentation = "<B> � &lt;&lt;�����������&gt;&gt;" & sNumber & " " & sName & "</B></a>"
	End If	
End Function

Sub OpenIncidentViewByNumberLocal(sNumner)
	OpenIncidentViewByNumber sNumner
	window.event.returnValue = False
	window.event.cancelBubble = True
End Sub