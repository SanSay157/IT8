'===============================================================================
'@@!!FILE_x-tree-std-op
'<GROUP !!SYMREF_VBS>
'<TITLE x-tree-std-op - ����������� ����������� ���� �������� ��������>
':����������:
'	����� ����� �������, �������� � �������, ������������ � ���������� 
'	����������� ������������ ���� �������� ��������.
'===============================================================================
'@@!!FUNCTIONS_x-tree-std-op
'<GROUP !!FILE_x-tree-std-op><TITLE ������� � ���������>
'@@!!CLASSES_x-tree-std-op
'<GROUP !!FILE_x-tree-std-op><TITLE ������>

Option Explicit
'<����������� ����������� ����>							


'==============================================================================
' ����������� ���������� ������� OnEdit (�������������e �������)
'	[in] oEventArg As CommonEventArgsClass
Sub stdXTree_OnEdit(oXTreePage, oEventArg)
	oEventArg.ObjectID = X_OpenObjectEditor(oEventArg.ObjectType, oEventArg.ObjectID, oEventArg.Metaname, oEventArg.Values.Item("URLPARAMS"))
	oEventArg.ReturnValue = Not IsEmpty(oEventArg.ObjectID)
End Sub


'==============================================================================
' ����������� ���������� ������� OnAfterEdit
'	[in] oEventArg As CommonEventArgsClass
Sub stdXTree_OnAfterEdit(oXTreePage, oEventArg)
	' ReturnValue ������� �� ������
	' ObjectID - ������������� �������
	If oEventArg.ReturnValue Then
		oXTreePage.RefreshCurrentNode Eval(oEventArg.Values.Item("RefreshFlags"))
		oXTreePage.ShowMenu()			
	End If
End Sub


'==============================================================================
' ����������� ���������� ������� OnCreate (�������� �������)
'	[in] oEventArg As CommonEventArgsClass
Sub stdXTree_OnCreate(oXTreePage, oEventArg)
	oEventArg.ReturnValue = X_OpenObjectEditor(oEventArg.ObjectType, oEventArg.ObjectID, oEventArg.Metaname, oEventArg.Values.Item("URLPARAMS"))
End Sub


'==============================================================================
' ����������� ���������� ������� OnAfterCreate
'	[in] oEventArg As CommonEventArgsClass
Sub stdXTree_OnAfterCreate(oXTreePage, oEventArg)
	' ReturnValue ������������� �������
	If Not IsEmpty(oEventArg.ReturnValue) Then
		oXTreePage.RefreshCurrentNode Eval(oEventArg.Values.Item("RefreshFlags"))
		oXTreePage.ShowMenu()			
	End If
End Sub


'==============================================================================
' ����������� ���������� ������� OnBeforeDelete
'	[in] oEventArg As DeleteObjectArgsClass
Sub stdXTree_OnBeforeDelete( oXTreePage, oEventArg )
	' �������� ������� ����
	Set oEventArg.AddEventArgs = oXTreePage.TreeView.ActiveNode
End Sub


'==============================================================================
' ����������� ���������� ������� OnDelete (�������� ���������� �������)
'	[in] oEventArg As DeleteObjectArgsClass
Sub stdXTree_OnDelete(oXTreePage, oEventArg)
	Dim nButtonFlag		' ����� MsgBox
	nButtonFlag = iif(StrComp(oEventArg.Values.Item("DefaultButton"), "No")=0, vbDefaultButton2, vbDefaultButton1)
	If vbYes = MsgBox(oEventArg.Values.Item("Prompt"), vbYesNo + vbInformation + nButtonFlag, "�������� �������") Then
		' ������ ������
		oEventArg.Count = X_DeleteObject( oEventArg.ObjectType, oEventArg.ObjectID )
		oEventArg.ReturnValue = Not X_HandleError
	End If				
End Sub


'==============================================================================
' ����������� ���������� ������� OnAfterDelete
' � AddEventArgs IXTreeNode ���������� ����.
'	[in] oEventArg As DeleteObjectArgsClass
Sub stdXTree_OnAfterDelete( oXTreePage, oEventArg )
    Dim oParentNode		' �������� ���������� ����
    Dim nOps			' ����� ���������� 

	If oEventArg.ReturnValue Then
		oXTreePage.TreeView.Enabled = false
		Set oParentNode = oEventArg.AddEventArgs.Parent
		If oEventArg.Count > 0  Then
			' ������ ������� � ������� - ������ ��������������� ��� ���� �� ������
			oEventArg.AddEventArgs.Remove
			nOps = Eval(oEventArg.Values.Item("RefreshFlags"))
			If nOps = TRM_NONE Then
				If Not oParentNode Is Nothing Then
					oParentNode.Reload
				End If
			Else
				' ������� ������
				DoRefreshTree nOps, Nothing, oParentNode
			End If
		Else
			' ������ �������, �� �� ������� - ������� ���
			oEventArg.AddEventArgs.Reload
		End If
		oXTreePage.TreeView.Enabled = true
		oXTreePage.m_sTreePath = oXTreePage.TreeView.Path
		oXTreePage.ShowMenu
	End If
End Sub


'===============================================================================
'@@MoveTreeNodeEventArgsClass
'<GROUP !!CLASSES_x-tree-std-op><TITLE MoveTreeNodeEventArgsClass>
':����������:	
'   �������������� ��������� ������� BeforeMove, Move, AfterMove.
'
'@@!!MEMBERTYPE_Properties_MoveTreeNodeEventArgsClass
'<GROUP MoveTreeNodeEventArgsClass><TITLE ��������>
Class MoveTreeNodeEventArgsClass

	'------------------------------------------------------------------------------
	'@@MoveTreeNodeEventArgsClass.MovingNode
	'<GROUP !!MEMBERTYPE_Properties_MoveTreeNodeEventArgsClass><TITLE MovingNode>
	':����������:	
	'	���� ������������� �������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public MovingNode [As IXTreeNode]
	Public MovingNode
	
	'------------------------------------------------------------------------------
	'@@MoveTreeNodeEventArgsClass.ParentObjectType
	'<GROUP !!MEMBERTYPE_Properties_MoveTreeNodeEventArgsClass><TITLE ParentObjectType>
	':����������:	
	'	������������ ���� ������������� �������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ParentObjectType [As String]
	Public ParentObjectType
	
	'------------------------------------------------------------------------------
	'@@MoveTreeNodeEventArgsClass.ParentObjectID
	'<GROUP !!MEMBERTYPE_Properties_MoveTreeNodeEventArgsClass><TITLE ParentObjectID>
	':����������:	
	'	������������� ������������� �������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ParentObjectID [As String]
	Public ParentObjectID
	
	'------------------------------------------------------------------------------
	'@@MoveTreeNodeEventArgsClass.NewParentPath
	'<GROUP !!MEMBERTYPE_Properties_MoveTreeNodeEventArgsClass><TITLE NewParentPath>
	':����������:	
	'	���� �� ������ ������������� ������� �� �����. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public NewParentPath [As String]
	Public NewParentPath
	
	'------------------------------------------------------------------------------
	'@@MoveTreeNodeEventArgsClass.ParentPropName
	'<GROUP !!MEMBERTYPE_Properties_MoveTreeNodeEventArgsClass><TITLE ParentPropName>
	':����������:	
	'	������������ ��������, ����������� �� ����������� ������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ParentPropName [As String]
	Public ParentPropName
End Class


'==============================================================================
' ����������� ���������� ������� OnMove
Sub stdXTree_OnMove(oXTreePage, oEventArg)
	Dim sNewParentPath		' As String - ���� �� ������ ������� �� �����
	Dim sOT					' As String - ��� �������
	Dim sID					' As String - ������������� �������
	Dim oXmlObject			' IXMLDOMElement - Xml-������ ������������ ����
	Dim sPN					' As String - ������������ ��-�� ���������� �������, ����������� �� ������������ ������
	Dim sPID				' As String - ������������� ��������
	Dim sPOT				' As String - ��� ��������

	oEventArg.ReturnValue = False
	sPN = oEventArg.AddEventArgs.ParentPropName
	If Not Len(sPN)>0 Then
		X_ErrReportEx "�� ������ ������������ ��������, ����������� �� ����������� ������", "stdXTree_OnMove"
	End If
	sOT = oEventArg.ObjectType
	sID = oEventArg.ObjectID 	
	If Not Len(sOT)>0 Or Not Len(sID)>0 Then
		X_ErrReportEx "�� ����� ��� �/��� ������������� ������������ �������", "stdXTree_OnMove"
	End If
	sNewParentPath = oEventArg.AddEventArgs.NewParentPath
	' ��������, �� �������� �� ����� ������ ����� ����� ��� ��� ������
	If 0<>InStr(1,"|" & sNewParentPath & "|" , "|" & sOT & "|" & sID & "|") Then
		MsgBox "���� ������ �� ����� ���� ��������� ����", vbExclamation, "��������������"
		Exit Sub
	End If
	sPOT = oEventArg.AddEventArgs.ParentObjectType
	sPID = oEventArg.AddEventArgs.ParentObjectID
	If Not Len(sPOT)>0 Or Not Len(sPID)>0 Then
		X_ErrReportEx "�� ����� ��� �/��� ������������� ������������� �������", "stdXTree_OnMove"
	End If
	Set oXmlObject = X_GetObjectFromServer( sOT, sID, vbNullString )
	If oXmlObject Is Nothing Then
		X_HandleError
		Exit Sub
	End If
	oXmlObject.selectNodes("*").removeAll
	oXmlObject.appendChild( oXmlObject.ownerDocument.createElement(sPN) ).appendChild X_CreateObjectStub(sPOT, sPID)
	' �������� ������� ����������
	With New XSaveObjectRequest
		.m_sName = "SaveObject"
		Set .m_oXmlSaveData = oXmlObject
		X_ExecuteCommand .Self
	End With
	oEventArg.ReturnValue = Not X_HandleError
End Sub


'==============================================================================
' ���������� ��������� ������ ����� �������� ����
'	[in] oXTreePage As XTreePageClass
'	[in] oNode As IXTreeNode - ������������ ����
'	[in] sNewParentPath As String - ���� �� ������ ��������
Sub UpdateTreeStateAfterNodeMove(oXTreePage, oNode, sNewParentPath)
	Dim oOldParent		' ������ ��������
	Dim oNewParent		' ����� ������������ ����
	Dim bExpanded		' ������� ������������� ������� ��������
	Dim sOT				' As String - ��� �������
	Dim sID				' As String - ������������� �������

	sOT = oNode.Type
	sID = oNode.ID	
	' ���� �� ������� �������
	Set oOldParent = oNode.Parent
	' ������� ������ �������� - ��������� ������������� ����...
	Set oNewParent = GetTreeViewNodeSafe( sNewParentPath )
	' � ��������� ��� ��������� (�������������)
	If oNewParent Is Nothing then
		bExpanded = Null
	Else
		bExpanded = oNewParent.Expanded
	End If
	' ������ ������ �� ��� ������� ��������� � �����������
	oNode.Remove()	
	If oOldParent Is Nothing Then
		' �������� ������� - ������������ ������...
		oXTreePage.Reload
	Else
		' �������� ������� ��������� ����
		oOldParent.Reload
		' � ��������� ��� ���� �� ���� �� ������� �������� �� �����
		Set oOldParent = oOldParent.Parent
		Do While Not (Nothing Is oOldParent)
			oOldParent.Reload
			Set oOldParent = oOldParent.Parent
		Loop
	End If
	' ������� ������ �������� - ��������� ������������� ����... (����� ���������� ������ ������ ��� �����������, � ���� - ���������)
	If Not oNewParent Is Nothing Then
		set oNewParent = GetTreeViewNodeSafe(sNewParentPath)
	End If
	If Not oNewParent Is Nothing Then
		oNewParent.Reload
		If oNewParent.Expanded Then  '���� ���� ��� ���������, ������������� ���� �����, ���������� ��
			oNewParent.Children.Reload
			g_oXTreePage.TreeView.Path = sOT & "|" & sID & "|" & sNewParentPath
		ElseIf bExpanded Then		 '����, �� ���������, �� ��� ��������� �� ����������
			oNewParent.Expanded = True
			g_oXTreePage.TreeView.Path = sOT & "|" & sID & "|" & sNewParentPath
		end if
		' ������� ���� �������� �� �����
		Do While Not (Nothing Is oNewParent)
			oNewParent.Reload
			Set oNewParent = oNewParent.Parent
		Loop
	End If
End Sub


'==============================================================================
' ����������� ���������� ������� OnAfterMove
Sub stdXTree_OnAfterMove(oXTreePage, oEventArg)
	Dim nOps			' As Int
	Dim oNode			' ������������ ����
	Dim sNewParentPath	' ���� �� ������ ������� �� �����
	
	If oEventArg.ReturnValue = False Then Exit Sub
	' ������� ������������ ����
	Set oNode = oEventArg.AddEventArgs.MovingNode
	' ������� ���� �� ������ ��������
	sNewParentPath = oEventArg.AddEventArgs.NewParentPath
	' �������� ����� ����������
	nOps = Eval(oEventArg.Values.Item("RefreshFlags"))
	If CLng(nOps) = TRM_NONE Then   ' �� ��������� �������� ����������� ����������
		UpdateTreeStateAfterNodeMove oXTreePage, oNode, sNewParentPath
	Else	'����� -  ��� �������...
		oXTreePage.m_sTreePath = ""
		oXTreePage.RefreshCurrentNode nOps
		oXTreePage.TreeView.SetNearestPath oEventArg.ObjectType & "|" & oEventArg.ObjectID & "|" & sNewParentPath
	End If
End Sub


'==============================================================================
' ����������� ���������� ������� OnSelectParent
Sub stdXTree_OnSelectParent(oXTreePage, oEventArg) 
	Dim aSelection		' ��������� ������ �� ������
	Dim sUrlArguments	' ���������, ������������ ����� ��� � ������ ������ �� ������
	
	'TODO: FireEvent "GetRestrictions"
	oEventArg.ReturnValue = False
	sUrlArguments = oEventArg.Values.Item("UrlParams")
	If Len(sUrlArguments)>0 Then sUrlArguments = sUrlArguments & "&"
	sUrlArguments = sUrlArguments & "EXCLUDE=" & oEventArg.ObjectType & "|" & oEventArg.ObjectID
	' ������� ������ ������ ����
	' ������� ������ � ������� ��������� ��������
	With X_SelectFromTree(oEventArg.Metaname, "", "", sUrlArguments, Nothing)
		If .ReturnValue Then
			' �������� ��������� ����
			oEventArg.AddEventArgs.NewParentPath = .Path
			' ������� ��� � ������������� �������, ���������� ��� ��������
			aSelection = Split(oEventArg.AddEventArgs.NewParentPath, "|")
			oEventArg.AddEventArgs.ParentObjectType = aSelection(0)
			oEventArg.AddEventArgs.ParentObjectID	= aSelection(1)
			oEventArg.ReturnValue = True
		End If
	End With
End Sub


'==============================================================================
' ���������� � ������-���� ���������������� ��������� � ������
' [in] oLink			- ������ (IHTMLAncorElement)
Sub OnMenuShowHint( oLink )
	window.defaultStatus = oLink.Title
	setTimeout  "window.status=window.defaultStatus" ,0,"VBScript"
End Sub


'==============================================================================
' ��������� ���������� ������-����
Sub OnMenuHideHint()
	window.status = ""
	window.defaultStatus = ""
End Sub


'==============================================================================
' ��������� ������ ��������
' [in] nOps			- ����� ���������� (TRM_xxxx)
' [in] oCurrentNode	- ������� ���� ������
' [in] oParentNode	- ������������ ���� ������������ ����
Sub DoRefreshTree(nOps, oCurrentNode, oParentNode)
	Dim oTreeNode		' As CROC.IXTreeNode - ���� ������
	Dim oParent			' As CROC.IXTreeNode - ���� ������
	
	If TRM_NONE = nOps Then Exit Sub ' ������ �� ������
	
	If (nOps And TRM_TREE) Then '���������� ����� ������
		g_oXTreePage.Reload
	Else
		If (nOps And TRM_NODE) Then   '���������� �������� ���� 
			If oCurrentNode Is Nothing Then
				g_oXTreePage.Reload
				Exit Sub
			End If
			Set oCurrentNode = g_oXTreePage.ReloadNode( oCurrentNode )
		End If	

		If (nOps And TRM_CHILDS) Then  '���������� �������� �����
			If oCurrentNode Is Nothing Then
				g_oXTreePage.Reload
				Exit Sub
			End if
			If Not oCurrentNode.IsLeaf Then oCurrentNode.children.reload
		End If
		
		If (nOps And TRM_PARENTNODES) Then  ' ���������� ����� ������� � ������� � �� �����
			Set oTreeNode = oParentNode
			Do While Not( Nothing Is oTreeNode)
				Set oParent = oTreeNode.Parent
				oTreeNode.Reload
				Set oTreeNode = oParent
			Loop
		ElseIf (nOps And TRM_PARENTNODE) Then '���������� ���� ������� ��� ����������� ��� �����
			If Not ( oParentNode Is Nothing ) Then
				Set oParentNode = g_oXTreePage.ReloadNode( oParentNode )
			End If
		End If

		If (nOps And TRM_PARENT) Then  '���������� ������������� ���� 
			If oParentNode Is Nothing Then
				g_oXTreePage.Reload
			Else
				oParentNode.Children.Reload
				g_oXTreePage.TreeView.SetNearestPath g_oXTreePage.m_sTreePath
			End If
		end if	
	end if
End Sub


'==============================================================================
' ����� PopUp-����
Sub DoShowPopupMenu
	g_oXTreePage.ShowPopupMenu
End Sub


'------------------------------------------------------------
' "����������" ��������� ����
' ���. #65281
' [in] sPath - ���� ����������� ����
' �������� ��������� ������������ - �������� � ����� �������� ����
' �������� �� ����� ������ � ��������. ��� ������ ������ �� ������������
' � �������� ������������� ���������� ��������� ��������
Function GetTreeViewNodeSafe(sPath)
	Dim oTempNode	' ��������� �������� ���� ������
	Dim sTempPath	' ����
	Dim aTempPath	' ������������ ����
	Dim nUBound		' ������ ������������� �������� ����
	Dim i			' �������
	
	On Error Resume Next
	Set GetTreeViewNodeSafe = Nothing
	' ��������� �������� ����� �� �������
	Set GetTreeViewNodeSafe = g_oXTreePage.TreeView.GetNode( sPath, false )
	If 0=Err.number Then Exit Function ' ����� ������ �����
	' �� ������� - ��� �������� �������� ���������� ��������
	aTempPath = Split(sPath, "|" )
	nUBound = UBound(aTempPath) 
	For i=0 To nUBound-2 Step 2
		aTempPath(i)   = vbNullString
		aTempPath(i+1) = vbNullString
		sPath = Replace(Trim(Join(aTempPath, " ")), " ", "|")
		Set oTempNode = g_oXTreePage.TreeView.GetNode( sTempPath, False )
		If IsObject(oTempNode) Then Exit For
	Next
	If IsObject(oTempNode) Then
		' ����� ��������, ���!
		' ������������ ���
		oTempNode.Children.Reload
		' �������� �������
		' ���� �� �� ������ �� ���������� :)
		Set GetTreeViewNodeSafe = g_oXTreePage.TreeView.GetNode( sPath, False)
	End If
	' ���� ��������� �������� ������� ������, ��
	' ������ �� ������������� ����������� �� ����� :)
	Err.Clear
End Function

'</����������� ����������� ����>							
