Option Explicit


'==============================================================================
' ExecutionHandler ���� ����� ���� Employee (�����) � Incident (��������)
Sub IncidentCategoryMenu_ExecutionHandler(oSender, oEventArg)
	Dim oActiveNode

	Set oActiveNode = oSender.TreeView.ActiveNode
	Select Case oEventArg.Action
		Case "DoMakeRoot"
			DoMakeRoot oSender, oSender.TreeView.ActiveNode
		Case "DoMoveCategory"
			DoMoveCategory oSender, oSender.TreeView.ActiveNode
	End Select
End Sub


'==============================================================================
'	[in] oXTreePage As XTreePageClass
'	[in] oActiveNode As IXTreeNode - ���� IncidentCategory
Sub DoMakeRoot(oXTreePage, oMovingNode)
	Dim sID						' As Guid - ������������� ������������ ���������
	Dim oXmlObject
	Dim oResponse				' As XResonse - ����� ��������� ��������
	Dim sNewParentPath			' ����� ���� �� ������������� ���� (����. ���� "���������")
	Dim sNewPath				' ����� ���� �� ���� oMovingNode ����� ��������
	Dim aPathParts				' ������ ��������� ���� �� ���� oMovingNode
	
	sID = oMovingNode.ID
	On Error Resume Next
	Set oXmlObject = X_GetObjectFromServer( "IncidentCategory", sID, vbNullString )
	If oXmlObject Is Nothing Then
		X_HandleError
		Exit Sub
	End If
	On Error GoTo 0
	oXmlObject.selectNodes("*").removeAll
	oXmlObject.appendChild( oXmlObject.ownerDocument.createElement("Parent") )
	With New XSaveObjectRequest
		Set .m_oXmlSaveData = oXmlObject
		.m_sName = "SaveObject"
		.m_sSessionID = Null
		.m_oRootObjectId = Null
		.m_sContext = Null
		Set oResponse = X_ExecuteCommandSafe(.Self)
	End With
	If hasValue(oResponse) Then
		' ����� ������� ���������� - ������� ������
		' ����� ���� �� ���� �� ����� ������� �����
		aPathParts = Split(oMovingNode.Path, "|")
		sNewParentPath = "IncidentCategoriesFolder|" & GUID_EMPTY & "|IncidentType|" & aPathParts(UBound(aPathParts))
		sNewPath = "IncidentCategory|" & sID & "|" & sNewParentPath
		UpdateTreeStateAfterNodeMove oXTreePage, oMovingNode, sNewPath
		' ���������� ����������� ���� "���������", ��� ������� ������ ����� ��������� ������� ���������
		oXTreePage.TreeView.GetNode(sNewParentPath).Children.Reload
	End If
End Sub


'==============================================================================
' ������� ���������
'	[in] oXTreePage As XTreePageClass
'	[in] oActiveNode As IXTreeNode - ���� IncidentCategory
Sub DoMoveCategory(oXTreePage, oMovingNode)
	Dim oResponse				' As XResonse - ����� ��������� ��������
	Dim aSelection				' As Variant() - ��������� ������ �� ������
	Dim sParentObjectType 		' As String - ��� ����, ���������� ��� ������������
	Dim sParentObjectID			' As Guid - ������������� ����, ���������� ��� ������������
	Dim sID						' As Guid - ������������� ������������ ���������
	Dim oXmlObject
	Dim sIncidentTypeIDCurrent
	Dim sIncidentTypeIDNew
	Dim sNewParentPath			' ���� �� ������ ��������
	Dim i
	Dim oSaveObjectRequest
	
	sID = oMovingNode.ID
	' ������� ������ ��� ������ ������ �������� � ������� ��������� ��������
	With New SelectFromTreeDialogClass
		.Metaname = "IncidentCategorySelectorForMove"
		.InitialPath = oMovingNode.Path		' TODO
		.SelectionMode = TSM_ANYNODE
		.SelectableTypes = "IncidentType IncidentCategory"
		SelectFromTreeDialogClass_Show(.Self)
		If .ReturnValue Then
			' ������� ��� � ������������� �������, ���������� ��� ��������
			aSelection = Split(.Path, "|")
			sParentObjectType = aSelection(0)
			sParentObjectID	= aSelection(1)
			' ��������, �� �������� �� ����� ������ ����� ����� ��� ��� ������
			If 0<>InStr(1,"|" & .Path & "|" , "|IncidentCategory|" & sID & "|") Then
				MsgBox "��������� �� ����� ���� ���������� � ���� �� ����� �������� ���������", vbExclamation, "��������������"
				Exit Sub
			End If
			
			Set oXmlObject = X_GetObjectFromServer( "IncidentCategory", sID, vbNullString )
			If oXmlObject Is Nothing Then
				X_HandleError
				Exit Sub
			End If
			oXmlObject.selectNodes("*").removeAll
			' ���� ������� ��� ���������, �� ������� ������ �� ��� � ������� ������ �� ��������
			If sParentObjectType = "IncidentType" Then
				oXmlObject.appendChild( oXmlObject.ownerDocument.createElement("IncidentType") ).appendChild X_CreateObjectStub("IncidentType", sParentObjectID)
				oXmlObject.appendChild( oXmlObject.ownerDocument.createElement("Parent") )
			Else
				' ������� ������ �� ���������. ������� ����������� �� ��� ���� �� ���� ���������, ��� � ������������
				' ��� ��������� � ��������� ���� ������ ����� �� �������� ������
				sIncidentTypeIDCurrent = oMovingNode.ApplicationData.selectSingleNode("ud/IncidentTypeID").text
				sIncidentTypeIDNew = aSelection(UBound(aSelection))
				If sIncidentTypeIDNew <> sIncidentTypeIDCurrent Then
					oXmlObject.appendChild( oXmlObject.ownerDocument.createElement("IncidentType") ).appendChild X_CreateObjectStub("IncidentType", sIncidentTypeIDNew)
				End If
				' ������ �� �������� �������� ���� ��������
				oXmlObject.appendChild( oXmlObject.ownerDocument.createElement("Parent") ).appendChild X_CreateObjectStub("IncidentCategory", sParentObjectID)
			End If
			' �������� ������� ����������
			Set oSaveObjectRequest = New XSaveObjectRequest
				Set oSaveObjectRequest.m_oXmlSaveData = oXmlObject
				oSaveObjectRequest.m_sContext = Null
				oSaveObjectRequest.m_oRootObjectId = sParentObjectID
				oSaveObjectRequest.m_sName = "SaveObject"
				oSaveObjectRequest.m_sSessionID = Null
			Set oResponse = X_ExecuteCommandSafe(oSaveObjectRequest)
			If hasValue(oResponse) Then
				' ���������� ���� .Path - �������� ���� �� ��������� � ��� ��������� �� �����, 
				' � � ������� �������� ����� ����� ��������� � ���������� ������������ ��� ����������� ���� "���������", 
				' ������� ���� ��������������� ���� �� ������ ��������
				For i=0 To UBound(aSelection)-1 Step 2
					If aSelection(i) = "IncidentType" Then
						sNewParentPath = sNewParentPath & "|IncidentCategoriesFolder|" & GUID_EMPTY
					End If
					If Not IsEmpty(sNewParentPath) Then sNewParentPath = sNewParentPath & "|"
					sNewParentPath = sNewParentPath & aSelection(i) & "|" & aSelection(i+1)
				Next
				' ����� ������� ���������� - ������� ������
				UpdateTreeStateAfterNodeMove oXTreePage, oMovingNode, sNewParentPath
			End If
		End If
	End With
End Sub
