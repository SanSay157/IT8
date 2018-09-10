Option Explicit
Dim g_bIsSearchingInProgress		' ������� �������� �������� ������ ���������

'==============================================================================
' ���������� ������� "Load" - �������� ��������
' ������������ ��������� LocateIncidentByID � LocateFolderByID, ���������� �������������� ��������� � ����� ��������������, 
' ������� ��������� ������� � ������.
Sub usrXTree_OnLoad(oSender, oEventArgs)
    Dim oTreeView
   	Dim sIncidentID			' As Guid - ������������� ���������
	Dim sFolderID			' As Guid - ������������� �����
	Dim oResponse			' As XResonse - ����� ��������� ��������
	Dim oDragDropMenuMetadata
    

	If oSender.QueryString.IsExists("LocateIncidentByID") Then
		sIncidentID = oSender.QueryString.GetValue("LocateIncidentByID", Null)
		If hasValue(sIncidentID) Then
			On Error Resume Next
			With New IncidentLocatorInTreeRequest
		        .m_sName = "IncidentLocatorInTree"
		        .m_sIncidentOID = sIncidentID
		        .m_nIncidentNumber = Null
		    Set oResponse = X_ExecuteCommand( .Self )
	        End With
			
			If Err Then
				If Not X_HandleError Then MsgBox Err.Description
			Else
				On Error Goto 0
				If Len("" & oResponse.m_sPath) > 0 Then
					oSender.m_sTreeInitPath = oResponse.m_sPath
				End If
			End If
		End If
	ElseIf oSender.QueryString.IsExists("LocateFolderByID") Then
		sFolderID = oSender.QueryString.GetValue("LocateFolderByID", Null)
		If hasValue(sFolderID) Then
			On Error Resume Next
			With New FolderLocatorInTreeRequest
		        .m_sName = "FolderLocatorInTree"
		        .m_sFolderOID = sFolderID
		    Set oResponse = X_ExecuteCommand( .Self )
	        End With
			If Err Then
				If Not X_HandleError Then MsgBox Err.Description
			Else
			 	On Error Goto 0
				If Len("" & oResponse.m_sPath) > 0 Then
					oSender.m_sTreeInitPath = oResponse.m_sPath
				End If
			End If
		End If
	End If
End Sub


'==============================================================================
' ���������� ������� "SetInitPath" - ��������� ���� ������ ��� �������� �������� �� ��������� ��������� INITPATH
Sub usrXTree_OnSetInitPath(oSender, oEventArgs)
	Dim sPath
	
	' ���� ����� ���� �� ������� ���� ������, ��
	If Len("" & oSender.m_sTreeInitPath) > 0 Then
		LocateNodeInDKPTree oSender.m_sTreeInitPath, Null, Null
	Else
		' ����� ����������� ���� �� ����
		If X_GetViewStateCache( "XT.TreeMain.Path", sPath) Then
			oSender.TreeView.SetNearestPath sPath, false, true
		End If
	End If
End Sub


'==============================================================================
' ��������� ���� �� ���������� ���� � ���
Sub usrXTree_OnUnLoad(oSender, oEventArgs)
	Dim oNode
	Set oNode = oSender.TreeView.ActiveNode 
	If Not oNode Is Nothing Then
		X_SaveViewStateCache "XT.TreeMain.Path", oNode.Path
	End If
End Sub


'==============================================================================
' ExecutionHandler ���� ����� ���� Organization (�����������)
Sub DKP_OrganizationMenu_ExecutionHandler(oSender, oEventArg)
	Dim oActiveNode

	Set oActiveNode = oSender.TreeView.ActiveNode
	Select Case oEventArg.Action
		Case "DoRunReport"
			X_RunReport oEventArg.Menu.Macros.Item("ReportName"), oEventArg.Menu.Macros.Item("UrlParams")
	End Select
End Sub

'==============================================================================
' ExecutionHandler ���� ����� ���� Organization (�����������)
Sub DKP_ContractMenu_ExecutionHandler(oSender, oEventArg)
	Dim oActiveNode
	
    Set oActiveNode = oSender.TreeView.ActiveNode
	Select Case oEventArg.Action
		Case "DoRunReport"
			X_RunReport oEventArg.Menu.Macros.Item("ReportName"), oEventArg.Menu.Macros.Item("UrlParams")
	End Select
End Sub

Sub DKP_ContractLevel_ExecutionHandler(oSender, oEventArg)
    'Alert "ContractLevel execution handler!!"
End Sub
'==============================================================================
' ExecutionHandler ���� ����� ���� Folder (�����) � Incident (��������)
Sub DKP_FolderMenu_ExecutionHandler(oSender, oEventArg)
	Dim oActiveNode
	Dim sPath
	Dim sFolderPath
	Dim sObjectID
	Dim sTitle
	Dim aNodes
	Dim oNode
	Dim vRet
	
	Set oActiveNode = oSender.TreeView.ActiveNode
	Select Case oEventArg.Action
		Case "DoMoveIncidents"
		    DisableAllControls oSender, True
			DoMoveIncidents oSender, oActiveNode
		    DisableAllControls oSender, False
	    Case "DoCopyFolderStructure"
	        vRet = X_OpenObjectEditor ( _
	            "CopyFolderStructureOperation", _
	            Null, "CopyFolderStructureWizard", ".Source=" & oEventArg.Menu.Macros.Item("ObjectID"))
	        If HasValue(vRet) Then
	            aNodes = oSender.TreeView.FindAnyNode("Folder", vRet)
			    If UBound(aNodes) > -1 Then
				    For Each oNode In aNodes
					    oNode.Reload
				    Next
			    End If
			End If
		Case "DoMoveIncident"
		    DisableAllControls oSender, True
			DoMoveIncident oSender, oActiveNode
		    DisableAllControls oSender, False
		Case "DoMoveFolder"
		    DisableAllControls oSender, True
			DoMoveFolder oSender, oActiveNode
		    DisableAllControls oSender, False
		Case "DoRunReport"
			X_RunReport oEventArg.Menu.Macros.Item("ReportName"), oEventArg.Menu.Macros.Item("UrlParams")
		Case "DoNavigate"
			sPath = oEventArg.Menu.Macros.Item("Path")
			If Not hasValue(sPath) Then
				Alert "��������� ���� �� ����������� �������� Path - ���� �� ����"
				Exit Sub
			End If
			LocateNodeInDKPTree sPath, Null, Null
		Case "DoAddFavorite"
			sObjectID = oEventArg.Menu.Macros.Item("ObjectID")
			sFolderPath = GetScalarValueFromDataSource( "GetFolderPath", Array("FolderID"), Array(sObjectID) )
			sTitle = "CROC.IT - ������� � ������� - " & Replace(sFolderPath, "\", "+")
			window.external.AddFavorite XService.BaseURL & "x-tree.aspx?METANAME=Main&LocateFolderByID=" + sObjectID, sTitle
		Case "DoCopyFolderPathToClipboard"
			sObjectID = oEventArg.Menu.Macros.Item("ObjectID")
			sFolderPath = GetScalarValueFromDataSource( "GetFolderPath", Array("FolderID"), Array(sObjectID) )
			window.clipboardData.setData "Text", sFolderPath
		Case "DoCopyFolderLinkToClipboard"
			window.clipboardData.setData "Text", XService.BaseURL & "x-tree.aspx?METANAME=Main&LocateFolderByID=" + oEventArg.Menu.Macros.Item("ObjectID")
		Case "DoCopyIncidentLinkToClipboard"
			window.clipboardData.setData "Text", XService.BaseURL & "x-tree.aspx?METANAME=Main&LocateIncidentByID=" + oEventArg.Menu.Macros.Item("ObjectID")
		Case "DoCopyIncidentViewLinkToClipboard"
			window.clipboardData.setData "Text", XService.BaseURL & "x-get-report.aspx?name=r-Incident.xml&DontCacheXslfo=true&IncidentID=" + oEventArg.Menu.Macros.Item("ObjectID")
		
	End Select
End Sub

'==============================================================================
' ��������� "������������" ������� ������� ����������� ������� - ��� �������� 
'	������� �����������. ������������ ��� ������������� "�������" �������� 
'	�������� ������ �����, ��� �������� ����� / ��������� / ����������
Function GetRestrictionsForFolderSelector()
	With new QueryStringClass
		.QueryString = GetRestrictions()
		.Remove "Directions"
		GetRestrictionsForFolderSelector = Replace( .QueryString, "&", "&." )
		If hasValue(GetRestrictionsForFolderSelector) Then
			GetRestrictionsForFolderSelector = "." & GetRestrictionsForFolderSelector
		End If
	End With
End Function


'==============================================================================
'	[in] oXTreePage As XTreePageClass
'	[in] oActiveNode As IXTreeNode - ���� ����� (Folder)
Sub DoMoveIncidents(oXTreePage, oActiveNode)
	Dim aIncidentIDs 	' As Guid() - ������ ��������������� ��������� ����������
	Dim vResult
	Dim bWasExpanded	' As Boolean - ������� ����, ��� ���� ����� ��� �������� �� ����������
	Dim sFolderID		' As Guid - ������������� �����
	Dim oFolder			' As IXTreeNode
	Dim bWasLeaf
	Dim oMoveObjectsRequest
	sFolderID = oActiveNode.ID
	' 1. ������� ������ ������ ���������� � ��������� �������
	aIncidentIDs = X_SelectFromList("IncidentsSelectorForMove", "Incident", LM_MULTIPLE, "Folder=" & sFolderID, Null)
	' 2. ���� ���-�� �������, ������� ������ ������ ����� ����������
	Set oMoveObjectsRequest = New MoveObjectsRequest
	If Not IsEmpty(aIncidentIDs) Then
		With New SelectFromTreeDialogClass
			.Metaname = "FolderSelector"
			.InitialPath = oActiveNode.Path
			.UrlArguments.QueryString = GetRestrictionsForFolderSelector()
			.SelectionMode = TSM_ANYNODE
			.SelectableTypes = "Folder"
			.ReturnValue = SelectFromTreeDialogClass_Show(.Self())
			If .ReturnValue Then
			    oMoveObjectsRequest.m_sName = "MoveObjects"
			    oMoveObjectsRequest.m_sSessionID =  Null
		        oMoveObjectsRequest.m_sSelectedObjectType = "Incident"
		        oMoveObjectsRequest.m_aSelectedObjectsID = aIncidentIDs
		        oMoveObjectsRequest.m_sNewParent = .Selection.selectSingleNode("n").getAttribute("id")
		        oMoveObjectsRequest.m_sParentPropName = "Folder"
		        oMoveObjectsRequest.m_sSubTreeSelectorPropName = Empty
				Set vResult = X_ExecuteCommandSafe( oMoveObjectsRequest )
				If hasValue(vResult) Then
					' TODO: ������-�� ��������� ��������� ���� �� ���� �����������, � ������ �� ������ ������ �������� (���� ����), �� ��� ������
					If oActiveNode.Expanded Then
						' ���� ���� ��� �������, ���������� ��� �����
						UpdateParentFolders oXTreePage.TreeView, oActiveNode
						oActiveNode.Children.Reload
					Else
						' ����� ������ ���������� ����, �.�. ��� ���������� ������� ��������� ����
						If Not oActiveNode.Parent Is Nothing Then
							UpdateParentFolders oXTreePage.TreeView, oActiveNode.Parent
						End If
						oActiveNode.Reload True
					End If
					' �������� � ������ �� ��������� �����
					Set oFolder = LocateNodeInDKPTree( .Path, "Folder", Null )
					If Not oFolder Is Nothing Then
						bWasExpanded = oFolder.Expanded
						' ����������: �� ����� ���� ���� oFolder ��� ��� ���� ���������� � ���������� ����������� ����������, 
						' ������� ��������� IsLeaf ������. 
						' ���������� ��� ���: ����� ��������� ��������� � ����������� �������� ����, �� �� �� ���������������.
						' 
						bWasLeaf = oFolder.IsLeaf
						' TODO: ������-�� ��������� ��������� ���� �� ���� �����������, � ������ �� ������ ������ �������� (���� ����), �� ��� ������
						If Not oFolder.Parent Is Nothing Then
							UpdateParentFolders oXTreePage.TreeView, oFolder.Parent
						End If
						' ���������� ��
						oFolder.Reload
						' � ���� ��� ���� ������� - ���������� �� �����
						If bWasExpanded Then
							oFolder.Children.Reload
						ElseIf bWasLeaf Then
							' �.�. ���� ������ ��� ��������, �� ��� ������� �������� �����
							oFolder.Expanded = True
						End If
					End If
				End If
			End If
		End With
	End If
End Sub


'==============================================================================
' ������� ���������
'	[in] oXTreePage As XTreePageClass
'	[in] oActiveNode As IXTreeNode - ���� ��������� (Incident)
Sub DoMoveIncident(oXTreePage, oMovingNode)
	Dim oResponse				' As XResonse - ����� ��������� ��������
	Dim aSelection				' As Variant() - ��������� ������ �� ������
	Dim sParentObjectType 		' As String - ��� ����, ���������� ��� ������������
	Dim sParentObjectID			' As Guid - ������������� ����, ���������� ��� ������������
	Dim sIncidentID				' As Guid - ������������� ������������� ���������
	Dim oMoveObjectRequest
	
	sIncidentID = oMovingNode.ID
	' ������� ������ ��� ������ ������ �������� � ������� ��������� ��������
	With New SelectFromTreeDialogClass
		.Metaname = "FolderSelector"
		.InitialPath = oMovingNode.Path
		.UrlArguments.QueryString = GetRestrictionsForFolderSelector()
		.SelectionMode = TSM_ANYNODE
		.SelectableTypes = "Folder"
		.ReturnValue = SelectFromTreeDialogClass_Show(.Self())
		If .ReturnValue Then
			' ������� ��� � ������������� �������, ���������� ��� ��������
			aSelection = Split(.Path, "|")
			sParentObjectType = aSelection(0)
			sParentObjectID	= aSelection(1)
			If sParentObjectType <> "Folder" Then X_ErrReportEx "������������ ����� ��� ��������� ����� ���� ������ �����", "DoMoveIncident"
			Set oMoveObjectRequest =  new MoveObjectsRequest 
			oMoveObjectRequest.m_sName = "MoveObjects"
		    oMoveObjectRequest.m_sSessionID = Null
		    oMoveObjectRequest.m_sSelectedObjectType = "Incident"
		    oMoveObjectRequest.m_aSelectedObjectsID = Array(sIncidentID)
		    oMoveObjectRequest.m_sNewParent = sParentObjectID
		    oMoveObjectRequest.m_sParentPropName = "Folder"
		    oMoveObjectRequest.m_sSubTreeSelectorPropName = Empty	
			Set oResponse = X_ExecuteCommandSafe(oMoveObjectRequest)
			If hasValue(oResponse) Then
				' ����� ������� ���������� - ������� ������
				'UpdateTreeStateAfterNodeMove oXTreePage, oMovingNode, .Path
				'LocateNodeInDKPTree "Incident|" & sIncidentID & "|" & .Path, "Incident", sIncidentID
				PostMove oXTreePage.TreeView, oMovingNode.Path, .Path
			End If
		End If
	End With
End Sub


'==============================================================================
' ��������� �����
Sub DoMoveFolder(oTreePage, oMovingNode)
	Dim sObjectID				' �������������
	Dim aSelection				' ��������� ������ �� ������
	Dim sUrlArguments			' ���������, ������������ ����� ��� � ������ ������ �� ������
	Dim nFolderType				' ��� �����
	Dim sParentObjectType 		' ��� ����, ���������� ��� ������������
	Dim sParentObjectID			' ������������� ����, ���������� ��� ������������
	Dim sOrganizationID 		' ������������� �����������
	Dim sActivityTypeID			' ������������� ���� ��������� ������ (ActivityType)
	Dim oResponse				' As XResonse - ����� ��������� ��������
	Dim i
	Dim oMoveFolderRequest
	Dim sFolderDirectionDiff
	Dim vRet
	nFolderType = CLng(oMovingNode.ApplicationData.selectSingleNode("ud/FolderType").text)
	sObjectID = oMovingNode.ID
	' ������� ������ ��� ������ ������ �������� � ������� ��������� ��������
	With New SelectFromTreeDialogClass
		.Metaname = "SelectorForFolderMove"
		.InitialPath = oMovingNode.Path
		.UrlArguments.QueryString = "EXCLUDE=Folder|" & sObjectID & "&" & GetRestrictionsForFolderSelector() 
		.SelectionMode = TSM_ANYNODE
		' ���� ����������� ����� - �������, �� ��������� ����� ���� ������ �����
		If nFolderType = FOLDERTYPEENUM_DIRECTORY Then
			.SelectableTypes = "Folder"
		' .. ������ � ������� ����� ���������� ������ �� �������� �������
		ElseIf nFolderType = FOLDERTYPEENUM_TENDER OR nFolderType = FOLDERTYPEENUM_PRESALE Then
			.SelectableTypes = "Organization ActivityType ActivityTypeInternal"
		' ����� � �����, � �����������, � ��� ��������� ������
		Else
			.SelectableTypes = "Folder Organization ActivityType ActivityTypeInternal"
		End If
		.ReturnValue = SelectFromTreeDialogClass_Show(.Self())
		If .ReturnValue Then
			' ������� ��� � ������������� �������, ���������� ��� ��������
			aSelection = Split(.Path, "|")
			sParentObjectType = aSelection(0)
			sParentObjectID	= aSelection(1)
			' ��������, �� �������� �� ����� ������ ����� ����� ��� ��� ������
			If 0<>InStr(1,"|" & .Path & "|" , "|Folder|" & sObjectID & "|") Then
				MsgBox "����� �� ����� ���� ���������� � ���� �� ����� �������� �����", vbExclamation, "��������������"
				Exit Sub
			End If
			' ��������, ������������� �� ����������� ����������� ����� ������������ ������������
			sFolderDirectionDiff = GetScalarValueFromDataSource("GetFirstFolderDirectionDifference-ForChildFolder", _
			                                Array("FolderID","ParentID"), Array(sObjectID,sParentObjectID))
		    If hasValue(sFolderDirectionDiff) Then
			    vRet = MsgBox ("��������! ����������� ����������/����� ����� �����������, ������� ��� � ��������� ����������/�����."& vbCrLf & _
			     "��� ����������� ����� ������� � ����������� ����������/�����." & vbCrLf & _
		        "����������?", vbYesNo+vbExclamation, "��������!") 
		        If ( vbNo = vRet ) Then Exit Sub
		    End If
			
			' �������� ������� � ������� ��������� ������� MoveFolder
			Set oMoveFolderRequest = new MoveFolderRequest
			
			If sParentObjectType = "Folder" Then	
			    oMoveFolderRequest.m_sName = "MoveFolder"
		        oMoveFolderRequest.m_sSessionID = Null
		        oMoveFolderRequest.m_aObjectsID = Array(sObjectID)
		        oMoveFolderRequest.m_sNewParent = sParentObjectID
		        oMoveFolderRequest.m_sNewCustomer = Null
		        oMoveFolderRequest.m_sNewActivityType = Null
				Set oResponse = X_ExecuteCommandSafe(oMoveFolderRequest)                  		
			Else			
				' ���� ������� �����������, �� ���������������, ��� ��� ��������� ������ �������� �������, ������
				' ����� �������� ������ ��� �������� ����� �������������-���������
				If sParentObjectType = "Organization" Then
					' TODO: ���� ������� ����������� ��� ����� ��������� ������ � ��������� ������� ��� ������, �� ���� ���������� ��������� ActivityType
					sOrganizationID = sParentObjectID
					sActivityTypeID = Null
					For i=0 To UBound(aSelection)-1 Step 2
						If aSelection(i) = "ActivityTypeExternal" Then
							sActivityTypeID = aSelection(i+1)
							Exit For
						End If
					Next
				Else
					' ���� ������� ��� ��������� ������, �� ���������� ��������� ������ �� �����������-�������. ��� ������ ����� ���� �� ����
					For i=0 To UBound(aSelection)-1 Step 2
						If aSelection(i) = "Organization" Or aSelection(i) = "HomeOrganization" Then
							sOrganizationID = aSelection(i+1)
							Exit For
						End If
					Next			
					sActivityTypeID = sParentObjectID
				End If
				oMoveFolderRequest.m_sName = "MoveFolder"
		        oMoveFolderRequest.m_sSessionID = Null
		        oMoveFolderRequest.m_aObjectsID = Array(sObjectID)
		        oMoveFolderRequest.m_sNewParent = Null
		        oMoveFolderRequest.m_sNewCustomer = sOrganizationID
		        oMoveFolderRequest.m_sNewActivityType = sActivityTypeID
				Set oResponse = X_ExecuteCommandSafe(oMoveFolderRequest)
			End If
			If hasValue(oResponse) Then
				' ����� ������� ���������� - ������� ������
				'UpdateTreeStateAfterNodeMove oTreePage, oMovingNode, .Path
				PostMove oTreePage.TreeView, oMovingNode.Path, .Path				
			End If
		End If
	End With
End Sub


'==============================================================================
' ������� � ������ ���� �������������� ����. 
' ���� ������� ����� ������ �� ��������� ��� �����, �� ������ ������������� � ����� "����������� �� ����� ������������" -
' � ���� ������ ����� ����� ���
'	[in] sPath - ���� �� ������� ���� (required)
'	[in] sType - ��� �������� ���� (optional)
'	[in] sObjectID - ������������� �������� ���� (optional)
'	[retval] ���������� IXTreeNode ���������� ���� ��� Nothing
Function LocateNodeInDKPTree(sPath, sType, sObjectID)
	Dim bNeedRepeatSearch		' As Boolean - ������� ������������� ��������� �����
	Dim aPathParts				' As Variant() - ������ ������ ���� ������ sPath
	Dim oTreeView
	Set LocateNodeInDKPTree = Nothing
	If Not hasValue(sPath) Then Exit Function
	If g_bIsSearchingInProgress=True Then
		Alert "���������� ������� ��������� �������� ������"
		Exit Function
	End If
	g_bIsSearchingInProgress = True
	Set oTreeView = document.all("oTreeView")
	oTreeView.SetNearestPath sPath, false, true
	' ���� ��� ��� ������������� �������� ���� �� ������, �� ������� �� �� ���� (��� ���� 1-�� �����)
	If Not hasValue(sObjectID) Or Not hasValue(sType) Then
		aPathParts = Split(sPath, "|")
		If UBound(aPathParts) < 1 Then g_bIsSearchingInProgress=False : Exit Function
		sType = aPathParts(0)
		sObjectID = aPathParts(1)
	End If

	bNeedRepeatSearch = Not CheckActiveNode(oTreeView, sType, sObjectID)

	' �������� � �� ����, �� ������� ����� ������ �� ��������� ��� ���������� - 
	' ���� �������� ����� ������ �� �����, ����� ������� �������� ����� ���� � ��� �������� - 
	' ��� ����� � ����������� ��������� "������ ��� ����������"
	If bNeedRepeatSearch Then
		' ��������: HACK :( �������� ����� � �������� ������, � ��� xml-������ � ������ ��� �������a
		With FilterObject().ObjectEditor
		    .Pool.BeginTransaction True
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "Mode"), DKPTREEMODES_ORGANIZATIONS
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "OnlyOwnActivity"), False
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "ShowOrgWithoutActivities"), False
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "IncidentViewMode"), INCIDENTVIEWMODES_ALL
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "OrganizationName"), ""
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "FolderName"), ""
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "FolderState"), 0
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "ActivityState"), 0
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "ActivityTypes"), 0
		    .Pool.RemoveAllRelations .XmlObject, "Directions"
		    Reload
		    oTreeView.SetNearestPath sPath, false, true
		    .Pool.RollBackTransaction
		End With
		If Not CheckActiveNode(oTreeView, sType, sObjectID) Then
			MsgBox "�� ������� ������� " & iif (sType = "Incident", "��������", "�����") & " � ������ ��-�� �������� ����", vbInformation + vbOkOnly, "����� ���������"
		Else
			Set LocateNodeInDKPTree = oTreeView.ActiveNode
		End If
	Else
		Set LocateNodeInDKPTree = oTreeView.ActiveNode
	End If
	g_bIsSearchingInProgress = False
End Function


Dim g_oXmlBackUpFilterDKPState		' ��������� ��������� �������

'==============================================================================
' ������ ����� ��������� �������
' ���������� g_oXmlBackUpFilterDKPState
Sub backUpFilterDKPState(oXmlObject)
	Set	g_oXmlBackUpFilterDKPState = oXmlObject.cloneNode(true)
End Sub

'==============================================================================
' ��������������� ��������� ������� �� ������
' ���������� g_oXmlBackUpFilterDKPState
Sub restoreFilterDKPState(oXmlObject)
	oXmlObject.selectSingleNode("Mode").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("Mode").nodeTypedValue
	oXmlObject.selectSingleNode("ActivityTypes").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("ActivityTypes").nodeTypedValue
	'oXmlObject.selectSingleNode("OnlyOpenActivity").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("OnlyOpenActivity").nodeTypedValue
	oXmlObject.selectSingleNode("OnlyOwnActivity").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("OnlyOwnActivity").nodeTypedValue
	oXmlObject.selectSingleNode("ShowOrgWithoutActivities").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("ShowOrgWithoutActivities").nodeTypedValue
	oXmlObject.selectSingleNode("IncidentViewMode").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("IncidentViewMode").nodeTypedValue
	oXmlObject.selectSingleNode("IncidentSortOrder").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("IncidentSortOrder").nodeTypedValue
	oXmlObject.selectSingleNode("IncidentSortMode").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("IncidentSortMode").nodeTypedValue
	oXmlObject.selectSingleNode("OrganizationName").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("OrganizationName").nodeTypedValue
	oXmlObject.selectSingleNode("FolderName").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("FolderName").nodeTypedValue
	oXmlObject.selectSingleNode("ShowTasks").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("ShowTasks").nodeTypedValue
End Sub


'==============================================================================
' ���������� ������� OnBeforeEdit
'	[in] oEventArg As DeleteObjectArgsClass
Sub usrXTree_OnBeforeEdit( oXTreePage, oEventArg )
	' �������� ������� ����
	Set oEventArg.AddEventArgs = oXTreePage.TreeView.ActiveNode
End Sub


'==============================================================================
' ���������� ������� OnAfterEdit
'	[in] oEventArg As CommonEventArgsClass
Sub usrXTree_OnAfterEdit(oXTreePage, oEventArg)
	Dim oDict 	' As Scripting.Dictionary
	Dim aValues
	Dim aFields
	
	' ReturnValue ������� �� ������
	' ObjectID - ������������� �������
	If oEventArg.ReturnValue Then
		If oEventArg.ObjectType = "Incident" Then
			' ����� �������������� ��������� ������� ��� � ����������� �����
			UpdateParentFolders oXTreePage.TreeView, oEventArg.AddEventArgs
		ElseIf oEventArg.ObjectType = "Folder" Then
			' ����� �������������� ����� ������� �� � ��� ������� ����������� �����
			Set oDict = CreateObject("Scripting.Dictionary")
			CollectChildFoldersID oEventArg.AddEventArgs, oDict
			aValues = GetValuesFromDataSource("GetFoldersInfo", Array("FolderID", "ShowWorkProgress"), Array(oDict.Keys(), 1))
			' 0 - ObjectID �����
			' 1 - ������������ ����
			' 2 - �������� ��o���
			For Each aFields In aValues
				oDict.item(aFields(0)) = Array(aFields(1), aFields(2))
			Next
			ApplyChildFoldersState oXTreePage.TreeView, oEventArg.AddEventArgs, oDict
		Else
			oXTreePage.RefreshCurrentNode Eval(oEventArg.Values.Item("RefreshFlags"))
		End If
		oXTreePage.ShowMenu()			
	End If
End Sub


'==============================================================================
' ���������� ������� OnBeforeCreate
'	[in] oEventArg As DeleteObjectArgsClass
Sub usrXTree_OnBeforeCreate( oXTreePage, oEventArg )
	' �������� ������� ����
	Set oEventArg.AddEventArgs = oXTreePage.TreeView.ActiveNode
End Sub


'==============================================================================
' ���������� ������� OnAfterCreate
'	[in] oEventArg As CommonEventArgsClass
Sub usrXTree_OnAfterCreate(oXTreePage, oEventArg)
	Dim oResponse		' ����� ��������� ��������
	Dim sIncidentID
	Dim oNode
	
	' ReturnValue ������� �� ������
	' ObjectID - ������������� �������
	If Not IsEmpty(oEventArg.ReturnValue) Then
		If oEventArg.ObjectType = "Incident" Then
			' �������� ���������
			sIncidentID = oEventArg.ReturnValue
			If oEventArg.Metaname = "WizardWithSelectFolder" Then
				' �������� ��������� � ������� �����. ������ �������� � ������ �� ��������������
				On Error Resume Next
				With New IncidentLocatorInTreeRequest
		            .m_sName = "IncidentLocatorInTree"
		            .m_sIncidentOID = sIncidentID
		            .m_nIncidentNumber = Null
		            Set oResponse = X_ExecuteCommand( .Self )
	            End With
				If Err Then
					If Not X_HandleError Then MsgBox Err.Description
				Else
					On Error Goto 0
					Set oNode = LocateNodeInDKPTree( oResponse.m_sPath, "Incident", sIncidentID)
					If Not oNode Is Nothing Then
						UpdateParentFolders oXTreePage.TreeView, oNode.Parent
					End If
				End If
			Else
				' �������� ��������� ������������ �������� ����: ����� - ��� ���, ��������� - �����, ��� ��� �� ������
				If oEventArg.AddEventArgs.Type = "Folder" Then
					' �������� ��������� � ������� ����� - � oEventArg.AddEventArgs ������������� �����
					UpdateParentFolders oXTreePage.TreeView, oEventArg.AddEventArgs
					oEventArg.AddEventArgs.Children.Reload
				ElseIf oEventArg.AddEventArgs.Type = "Incident" Then
					' �������� ��������� � ��� �� �����, ��� � ������� �������� - � oEventArg.AddEventArgs ������������� ���������� ���������
					UpdateParentFolders oXTreePage.TreeView, oEventArg.AddEventArgs.Parent
					oEventArg.AddEventArgs.Parent.Children.Reload
				End If
			End If
		Else
			oXTreePage.RefreshCurrentNode Eval(oEventArg.Values.Item("RefreshFlags"))
		End If
		oXTreePage.ShowMenu()			
	End If
End Sub


'==============================================================================
' ���������� ������� OnAfterDelete
' � AddEventArgs IXTreeNode ���������� ����.
'	[in] oEventArg As DeleteObjectArgsClass
Sub usrXTree_OnAfterDelete( oXTreePage, oEventArg )
    Dim oParentNode		' �������� ���������� ����
    
    If oEventArg.ObjectType = "Incident" Then
		If oEventArg.ReturnValue And oEventArg.Count > 0 Then
			Set oParentNode = oEventArg.AddEventArgs.Parent
			oEventArg.AddEventArgs.Remove
			If Not oParentNode Is Nothing Then
				UpdateParentFolders oXTreePage.TreeView, oParentNode
			End If
			oXTreePage.ShowMenu
		End If
    Else
		stdXTree_OnAfterDelete oXTreePage, oEventArg
	End If
End Sub


'==============================================================================
' �������� �������������� �����, ����������� ��������� ����. ��������!
'	[in] oFolderNode As IXTreeNode - ���� �����
'	[in] oDict As Scripting.Dictionary - ������� � ����������������
Sub CollectChildFoldersID(oFolderNode, oDict)
	Dim oNode
	Dim i
	oDict.Add oFolderNode.ID, Null
	If oFolderNode.Expanded Then
		For i=0 To oFolderNode.Children.Count - 1
			Set oNode = oFolderNode.Children.GetNode(i)
			If oNode.Type = "Folder" Then
				CollectChildFoldersID oNode, oDict
			End If
		Next
	End If
End Sub


'==============================================================================
' ��������� ���� ���������� ������������ ���������. 
'	[in] oTreeView As IXTreeView
'	[in] oFolderNode As IXTreeNode - ������� ����
'	[in] oDict As Scripting.Dictionary - ���� - ������������� ����, �������� - ������ (������������ ����, �������� ������)
Sub ApplyChildFoldersState(oTreeView, oFolderNode, oDict)
	Dim oNode
	Dim i
	Dim aValues

	If oDict.Exists(oFolderNode.ID) Then
		aValues = oDict.item(oFolderNode.ID)
		If IsArray(aValues) Then
			oFolderNode.Text = aValues(0)
			oFolderNode.IconUrl = oTreeView.XImageList.MakeIconUrl(oFolderNode.Type, "", aValues(1))
		End If
	End If
	If oFolderNode.Expanded Then
		For i=0 To oFolderNode.Children.Count - 1
			Set oNode = oFolderNode.Children.GetNode(i)
			If oNode.Type = "Folder" Then
				ApplyChildFoldersState oTreeView, oNode, oDict
			End If
		Next
	End If
End Sub


'==============================================================================
' ��������� ���� ����� ��� �������� �����
'	[in] oTreeView As IXTreeView
' 	[in] oActiveNode - ������� ����, ������� � �������� ����� ��������� �������� ���� (��� ���� Folder, ���� Incident)
Sub UpdateParentFolders(oTreeView, oActiveNode)
	Dim aParamNames 	' ������ ������������ ���������� ��������� ������
	Dim oCurrentNode	' As IXTreeNode - ����������� ����
	Dim aValues			' ������ � ��������� ����� � ��� �� ������������������ ��� ��� ������������� � ������
						' �������� �������� ������� - ������ � ���������� ������� ����� ������ ��������� ������ GetParentFoldersInfo:
						' 0 - ������������� (���������, �����)
						' 1 - ������������ ����
						' 2 - �������� ������
	Dim nIndex			' ������ � ������� aValues ��������, ���������������� �������� ����
	Dim oParent			' As IXTreeNode
	
	If oActiveNode Is Nothing Then 
		Exit Sub
	End If
	If oActiveNode.Type = "Incident" Then
		aParamNames = Array("IncidentID", "ShowWorkProgress")
	Else
		aParamNames = Array("FolderID", "ShowWorkProgress")
	End If
	
	Set oCurrentNode = oActiveNode
	aValues = GetValuesFromDataSource("GetParentFoldersInfo", aParamNames, Array(oActiveNode.ID, 1))
	nIndex = 0
	While Not oCurrentNode Is Nothing
		If oCurrentNode.Type <> "Folder" And oCurrentNode.Type <> "Incident" Then Exit Sub
		If oCurrentNode.ID <> aValues(nIndex)(0) Then 
			' ������������� �������� ���� � ������ �� ������ � ������������� �����, ������� ��������� � ������ ����� �������� � ��
			' ��� �������� ��-�� ����, ��� ��������� ������ �� ������� �������� (���-�� ����-�� ���-�� �������)
			' ������� ����������� ���� ����� "���������" ��������
			While Not oCurrentNode Is Nothing
				Set oParent = oCurrentNode.Parent
				oCurrentNode.Reload
				Set oCurrentNode = oParent
			Wend
			Exit Sub
		End If
		oCurrentNode.Text = aValues(nIndex)(1)
		oCurrentNode.IconUrl = oTreeView.XImageList.MakeIconUrl(oCurrentNode.Type, "", aValues(nIndex)(2))
		Set oCurrentNode = oCurrentNode.Parent
		nIndex = nIndex + 1
	Wend
End Sub

' ���������� ������ �������� ��������
Sub FolderCanDragHandler(oSender, oEventArgs)
    If oEventArgs.CanDrag Then
        If Not(HasValue(GetTreeMenuForActiveNode(oSender).SelectSingleNode("i:menu-item[@action='DoMoveFolder']"))) Then
            oEventArgs.CanDrag = False
        End If
    End If
End Sub

' ���������� ������ �������� ��������
Sub IncidentCanDragHandler(oSender, oEventArgs)
    If oEventArgs.CanDrag Then
        If Not(HasValue(GetTreeMenuForActiveNode(oSender).SelectSingleNode("i:menu-item[@action='DoMoveIncident']"))) Then
            oEventArgs.CanDrag = False
        End If
    End If
End Sub

' ���������� ������� ���������� ���� ��� ������ �����
Sub FolderCanDropHandler(oSender, oEventArgs)
    Dim nFolderType
    If oEventArgs.CanDrop Then
        nFolderType = CLng(oEventArgs.SourceNode.ApplicationData.selectSingleNode("ud/FolderType").text)
        ' ���� ����������� ����� - �������, �� ��������� ����� ���� ������ �����
        If nFolderType = FOLDERTYPEENUM_DIRECTORY Then
	        If oEventArgs.TargetNode.Type = "Folder" Then
                If 0<>InStr(1,"|" & oEventArgs.TargetNode.Path & "|" , "|Folder|" & oEventArgs.SourceNode.ID & "|") Then
                    oEventArgs.CanDrop = False
                    oEventArgs.Cancel = True
                End If
            Else
	            oEventArgs.CanDrop = False
	        End If
        ' .. ������ � ������� ����� ���������� ������ �� �������� �������
        ElseIf nFolderType = FOLDERTYPEENUM_TENDER OR nFolderType = FOLDERTYPEENUM_PRESALE Then
	        If oEventArgs.TargetNode.Type <> "Organization" And oEventArgs.TargetNode.Type <> "ActivityType" And oEventArgs.TargetNode.Type <> "ActivityTypeInternal" Then
	            oEventArgs.CanDrop = False
	        End If
        ' ����� � �����, � �����������, � ��� ��������� ������
        Else
            If oEventArgs.TargetNode.Type = "Folder" Then
                If 0<>InStr(1,"|" & oEventArgs.TargetNode.Path & "|" , "|Folder|" & oEventArgs.SourceNode.ID & "|") Then
                    oEventArgs.CanDrop = False
                End If
            ElseIf oEventArgs.TargetNode.Type <> "Organization" And oEventArgs.TargetNode.Type <> "ActivityType" And oEventArgs.TargetNode.Type <> "ActivityTypeInternal" Then
	            oEventArgs.CanDrop = False
	        End If
        End If
    End If
End Sub

' ���������� ������� ���������� ���� ��� ������ �����
Sub IncidentCanDropHandler(oSender, oEventArgs)
    ' ���������� ����� ������ ��� �����
    If oEventArgs.CanDrop Then
        If oEventArgs.TargetNode.Type <> "Folder" Then 
            oEventArgs.CanDrop = False
        End If
    End If
End Sub

Sub FolderDragDropMenuVisibilityHandler(oSender, oEventArgs)
    Dim oMenuItemNode   ' �������� ������ ����
    Dim oParam          ' �������� ������ ����
    Dim bHide           ' ������� ����, ��� ����� ���� ���� ��������
    Dim sParentPropName ' ������������ ������������� ��������
    Dim sParentPropType ' ������������ ���� ������������� �������
    
    ' ��������� �� ������� ����
    For Each oMenuItemNode In oEventArgs.ActiveMenuItems
        bHide = True
        ' ��� ����� DoMove ������� ��� ����
        If oMenuItemNode.GetAttribute("action") = "DoMove" Then
            ' ��� DoMove ������� ��, � ������� ��� �������� �������� ParentPropName ��������� � ����� ����, ���� "���������"
            Set oParam = oMenuItemNode.SelectSingleNode("i:params/i:param[@n='ParentPropName']")
            If HasValue(oParam) Then
                sParentPropName = oParam.NodeTypedValue
                Select Case sParentPropName
                    Case "Parent"
                        If oEventArgs.Menu.Macros.Item("TargetType") = "Folder" Then bHide = False
                    Case "Customer"
                        If oEventArgs.Menu.Macros.Item("TargetType") = "Organization" Then bHide = False
                    Case "ActivityType"
                        If oEventArgs.Menu.Macros.Item("TargetType") = "ActivityType" Then bHide = False
                        If oEventArgs.Menu.Macros.Item("TargetType") = "ActivityTypeInternal" Then bHide = False
                End Select
            End If
        Else
            bHide = False
        End If
        If bHide Then
            oMenuItemNode.SetAttribute "hidden", "1"         
        End If
    Next
End Sub

' ���������� ���� �������� �����
Sub FolderDragDropMenuExecutionHandler(oSender, oEventArgs)
    Dim oResponse
    Dim oSourceParent
    Dim sSourceParentPath
    Dim sSourceID
    Dim sSourcePath
    Dim aSourcePath
    Dim sSourceType
    Dim oTarget
    Dim sTargetID
    Dim sTargetPath
    Dim aTargetPath
    Dim sTargetType
    
    If oEventArgs.Action = "DoMove" Then
    
        DisableAllControls oSender, True
    
        sSourcePath = oEventArgs.Menu.Macros.Item("NodePath")
        aSourcePath = Split(sSourcePath, "|")
        sSourceType = aSourcePath(0)
        sSourceID = aSourcePath(1)
        sSourceParentPath = Right(sSourcePath, Len(sSourcePath) - Len(sSourceType) - Len(sSourceID) - 1)
        If Len(sSourceParentPath) > 0 Then sSourceParentPath = Right(sSourceParentPath, Len(sSourceParentPath) - 1) Else sSourceParentPath = Null
        
        sTargetPath = oEventArgs.Menu.Macros.Item("NewParentPath")
        aTargetPath = Split(sTargetPath, "|")
        sTargetType = aTargetPath(0)
        sTargetID = aTargetPath(1)
        
        Dim oMoveFolderRequest
        Dim sFolderDirectionDiff
        Dim vRet
        Dim sOrganizationID
        Dim sActivityTypeID
        Dim aSelection 
        Dim i
        
        ' ��������, ������������� �� ����������� ����������� ����� ������������ ������������
	    sFolderDirectionDiff = _
	        GetScalarValueFromDataSource( _
	            "GetFirstFolderDirectionDifference-ForChildFolder", _
	            Array("FolderID", "ParentID"), _
	            Array(sSourceID, sTargetID))
        If hasValue(sFolderDirectionDiff) Then
	        vRet = MsgBox ("��������! ����������� ����������/����� ����� �����������, ������� ��� � ��������� ����������/�����."& vbCrLf & _
	         "��� ����������� ����� ������� � ����������� ����������/�����." & vbCrLf & _
            "����������?", vbYesNo+vbExclamation, "��������!") 
            If ( vbNo = vRet ) Then Exit Sub
        End If
    	
	    ' �������� ������� � ������� ��������� ������� MoveFolder
	    Set oMoveFolderRequest = new MoveFolderRequest
    	
	    If sTargetType = sSourceType Then	
	        oMoveFolderRequest.m_sName = "MoveFolder"
            oMoveFolderRequest.m_sSessionID = Null
            oMoveFolderRequest.m_aObjectsID = Array(sSourceID)
            oMoveFolderRequest.m_sNewParent = sTargetID
            oMoveFolderRequest.m_sNewCustomer = Null
            oMoveFolderRequest.m_sNewActivityType = Null   
		    Set oResponse = X_ExecuteCommandSafe(oMoveFolderRequest)                  		
	    Else			
		    ' ���� ������� �����������, �� ���������������, ��� ��� ��������� ������ �������� �������, ������
		    ' ����� �������� ������ ��� �������� ����� �������������-���������
		    If sTargetType = "Organization" Then
			    ' TODO: ���� ������� ����������� ��� ����� ��������� ������ � ��������� ������� ��� ������, �� ���� ���������� ��������� ActivityType
			    sOrganizationID = sTargetID
			    sActivityTypeID = Null
			    For i=0 To UBound(aTargetPath) - 1 Step 2
				    If aTargetPath(i) = "ActivityTypeExternal" Then
					    sActivityTypeID = aTargetPath(i + 1)
					    Exit For
				    End If
			    Next
		    Else
			    ' ���� ������� ��� ��������� ������, �� ���������� ��������� ������ �� �����������-�������. ��� ������ ����� ���� �� ����
			    For i=0 To UBound(aTargetPath) - 1 Step 2
				    If aTargetPath(i) = "Organization" Or aTargetPath(i) = "HomeOrganization" Then
					    sOrganizationID = aTargetPath(i + 1)
					    Exit For
				    End If
			    Next			
			    sActivityTypeID = sTargetID
		    End If
		    oMoveFolderRequest.m_sName = "MoveFolder"
            oMoveFolderRequest.m_sSessionID = Null
            oMoveFolderRequest.m_aObjectsID = Array(sSourceID)
            oMoveFolderRequest.m_sNewParent = Null
            oMoveFolderRequest.m_sNewCustomer = sOrganizationID
            oMoveFolderRequest.m_sNewActivityType = sActivityTypeID
            
		    Set oResponse = X_ExecuteCommandSafe(oMoveFolderRequest)
	    End If
	    If hasValue(oResponse) Then
		    ' �������� ������� ��������� - ������� ������
		    ' ������� ������ ����� � ����� �����
		    oSender.TreeView.GetNode(sSourcePath, false).Remove
    		
		    If HasValue(sSourceParentPath) Then
		        Set oSourceParent = oSender.TreeView.GetNode(sSourceParentPath, false)
	        Else 
	            Set oSourceParent = Nothing
	        End If
    	    
		    Set oTarget = oSender.TreeView.GetNode(sTargetPath, false)
    	    
		    ReloadAfterMoveSafe oSourceParent, oTarget, oSender.TreeView
    		
		    If HasValue(sSourceParentPath) Then 
		        oSender.TreeView.Path = sSourceParentPath
		    Else 
		        oSender.TreeView.Path = sSourceType & "|" & sSourceID & "|" & sTargetPath
		    End If
	    End If
	    DisableAllControls oSender, False
	End If
End Sub

' ���������� ���� �������� ����������
Sub IncidentDragDropMenuExecutionHandler(oSender, oEventArgs)
    Dim oResponse
    Dim oSourceParent
    Dim sSourceParentPath
    Dim sSourceID
    Dim sSourcePath
    Dim aSourcePath
    Dim sSourceType
    Dim oTarget
    Dim sTargetID
    Dim sTargetPath
    Dim aTargetPath
    Dim sTargetType
    
    If oEventArgs.Action = "DoMove" Then
        DisableAllControls oSender, True
        sSourcePath = oEventArgs.Menu.Macros.Item("NodePath")
        aSourcePath = Split(sSourcePath, "|")
        sSourceType = aSourcePath(0)
        sSourceID = aSourcePath(1)
        sSourceParentPath = Right(sSourcePath, Len(sSourcePath) - Len(sSourceType) - Len(sSourceID) - 1)
        If Len(sSourceParentPath) > 0 Then sSourceParentPath = Right(sSourceParentPath, Len(sSourceParentPath) - 1) Else sSourceParentPath = Null
        
        sTargetPath = oEventArgs.Menu.Macros.Item("NewParentPath")
        aTargetPath = Split(sTargetPath, "|")
        sTargetType = aTargetPath(0)
        sTargetID = aTargetPath(1)
        
        Dim oMoveObjectRequest
                
        Set oMoveObjectRequest =  new MoveObjectsRequest 
	    oMoveObjectRequest.m_sName = "MoveObjects"
        oMoveObjectRequest.m_sSessionID = Null
        oMoveObjectRequest.m_sSelectedObjectType = sSourceType
        oMoveObjectRequest.m_aSelectedObjectsID = Array(sSourceID)
        oMoveObjectRequest.m_sNewParent = sTargetID
        oMoveObjectRequest.m_sParentPropName = sTargetType
        oMoveObjectRequest.m_sSubTreeSelectorPropName = Empty	

        Set oResponse = X_ExecuteCommandSafe(oMoveObjectRequest)
	    If hasValue(oResponse) Then
		    ' �������� ������� ��������� - ������� ������
		    ' ������� ������ ����� � ����� �����
		    oSender.TreeView.GetNode(sSourcePath, false).Remove
    		
		    If HasValue(sSourceParentPath) Then
		        Set oSourceParent = oSender.TreeView.GetNode(sSourceParentPath, false)
	        Else 
	            Set oSourceParent = Nothing
	        End If
    	    
		    Set oTarget = oSender.TreeView.GetNode(sTargetPath, false)
    	    
		    ReloadAfterMoveSafe oSourceParent, oTarget, oSender.TreeView
    		
		    If HasValue(sSourceParentPath) Then 
		        oSender.TreeView.Path = sSourceParentPath
		    Else 
		        oSender.TreeView.Path = sSourceType & "|" & sSourceID & "|" & sTargetPath
		    End If
	    End If
        DisableAllControls oSender, False
    End If
    
End Sub

Sub DisableAllControls(oTreePage, bDisabled)
    If bDisabled Then
        oTreePage.EnableControls False
    Else
        oTreePage.EnableControls True
    End If
End Sub 

Function GetTreeMenuForActiveNode(oTree)
    Dim oMenuCached
    Dim sKeyPath
    Dim sKeyType
    Dim oMenuPostData
    Dim oMenuHTTP
    Dim sMenuLoaderUrl
    
    Set oMenuCached = Nothing
	sKeyPath = "path:" & oTree.GetPathOfTypes()
	sKeyType = "type:" & oTree.TreeView.ActiveNode.Type
	If oTree.m_oMenuCache.Exists(sKeyPath) Then
		Set oMenuCached = oTree.m_oMenuCache.Item(sKeyPath)
	ElseIf oTree.m_oMenuCache.Exists(sKeyType) Then
		Set oMenuCached = oTree.m_oMenuCache.Item(sKeyType)
	End If
	If Not oMenuCached Is Nothing Then
	    Set GetTreeMenuForActiveNode = oMenuCached
	    Exit Function 
	End If
	
	' ��������������� ���� ���
	' �������� xml-������ ���������� ����
	Set oMenuPostData = oTree.CreateMenuRequest()		
	' �������� ������ ��� ����������� �������� xml
	Set oMenuHTTP = CreateObject( "Msxml2.XMLHTTP")
	' ��������� URL ����
	sMenuLoaderUrl = "x-tree-menu.aspx?METANAME=" & oTree.Metaname & "&tm=" & CDbl(Now)
	' ������ ������ �� ������ ��������� (false � 3-� ���������)
	oMenuHTTP.open "POST", sMenuLoaderUrl, false
	oMenuHTTP.send oMenuPostData 	
		
    Set GetTreeMenuForActiveNode = CheckMenuRequestResponse(oMenuHTTP)
End Function

' ��������� ������ ����� �������� �����
Sub PostMove(oTreeView, sMovingNodePath, sNewParentPath)
    Dim oSourceParent
    Dim sSourceParentPath
    Dim sSourceID
    Dim sSourcePath
    Dim aSourcePath
    Dim sSourceType
    Dim oTarget
    Dim sTargetPath
    
    sSourcePath = sMovingNodePath
    aSourcePath = Split(sSourcePath, "|")
    sSourceType = aSourcePath(0)
    sSourceID = aSourcePath(1)
    sSourceParentPath = Right(sSourcePath, Len(sSourcePath) - Len(sSourceType) - Len(sSourceID) - 1)
    If Len(sSourceParentPath) > 0 Then sSourceParentPath = Right(sSourceParentPath, Len(sSourceParentPath) - 1) Else sSourceParentPath = Null
    
    sTargetPath = sNewParentPath

    oTreeView.GetNode(sSourcePath, false).Remove
		
	If HasValue(sSourceParentPath) Then
	    Set oSourceParent = oTreeView.GetNode(sSourceParentPath, false)
    Else 
        Set oSourceParent = Nothing
    End If
    
	Set oTarget = oTreeView.GetNode(sTargetPath, false)
    
	ReloadAfterMoveSafe oSourceParent, oTarget, oTreeView
	
	If HasValue(sSourceParentPath) Then 
	    oTreeView.Path = sSourceParentPath
	Else 
	    oTreeView.Path = sSourceType & "|" & sSourceID & "|" & sTargetPath
	End If
End Sub