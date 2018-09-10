Option Explicit

' ����������� ���������� ����������, ����������� (����������) ������ �� �������,
' ������������� �������� �������
Dim g_oObjectEditor	' ������-�������� ������� (ObjectEditorClass)

Private Const CASE_NOMINATIVE 	= 1	' ������������ �����
Private Const CASE_INSTRUMENTAL	= 2	' ������������ �����

'==============================================================================
' ��������� ������������ ����� �����������, �������� ������ (nActivityTypes) � ����������� �� ������ (nCase)
' ������ ��� ������������� � ������� GetFilterStateDescription!
'	[in] nActivityTypes - ����� ����� �����������
'	[in] nCase - ����� (CASE_NOMINATIVE ��� CASE_INSTRUMENTAL)
'	[out] s1
'	[out] s2
'	[out] s3
Private Function initActivityNameParts(nActivityTypes, nCase, ByRef s1, ByRef s2, ByRef s3)
	Dim nParts				' ���������� �������� ���� (0,1,2,3)
	Dim sProjectName		' ����� ����� "�������"
	Dim sTenderName			' ����� ����� "�������"
	Dim sPresaleName		' ����� ����� "��������"
	Dim sActivitiesName		' ����� ����� "����������"
	
	If nCase = CASE_NOMINATIVE Then
		sProjectName	= "�������"
		sTenderName		= "�������"
		sPresaleName	= "��������"
		sActivitiesName	= "����������"
	Else
		sProjectName	= "���������"
		sTenderName		= "���������"
		sPresaleName	= "����������"
		sActivitiesName	= "������������"
	End If
	
	nParts = 0
	If nActivityTypes = 0 Then
		s1	= sActivitiesName
		nParts = 1
	Else
		If (nActivityTypes AND CLng(FOLDERTYPEFLAGS_PROJECT)) > 0 Then
			s1 = sProjectName
			nParts = nParts + 1
		End If
		If (nActivityTypes AND CLng(FOLDERTYPEFLAGS_TENDER)) > 0 Then
			If IsEmpty(s1) Then 
				s1 = sTenderName
			Else
				s2 = sTenderName
			End If
			nParts = nParts + 1
		End If
		If (nActivityTypes AND CLng(FOLDERTYPEFLAGS_PRESALE)) > 0 Then
			If IsEmpty(s1) Then 
				s1 = sPresaleName
			ElseIf IsEmpty(s2) Then
				s2 = sPresaleName
			Else
				s3 = sPresaleName
			End If
			nParts = nParts + 1
		End If
		If nParts = 3 Then
		    s1	= sActivitiesName
		    nParts = 1
		End If
	End If
	initActivityNameParts = nParts
End Function


'==============================================================================
' ���������� �� XSL ��� ������ ���������� � ��������� �������
Function GetFilterStateDescription()
	
	Dim sResult						' ����������� ������
	Dim nMode						'
	Dim bOnlyOwnActivities			' �������� ��������-����� "������ ��� ����������"
	Dim bShowOrgWithoutActivities	' �������� ��������-����� "���������� ����������� ��� �����������"
	Dim oDirections                 ' ����������� 
	Dim nActivityState              ' ��������� ����������� 
	Dim nFolderState                ' ��������� �����
	Dim nActivityTypes              '
	Dim s1, s2, s3
	Dim nParts						' 
	Dim sOrgName					' ������������ �����������
	Dim sFolderName 				' ������������ �����
	Dim nCase						' �����  
	Dim bFilterExists               ' ������� �������������� �������
	nMode = g_oObjectEditor.XmlObject.selectSingleNode("Mode").nodeTypedValue
	nActivityState = g_oObjectEditor.XmlObject.selectSingleNode("ActivityState").nodeTypedValue
	nFolderState = g_oObjectEditor.XmlObject.selectSingleNode("FolderState").nodeTypedValue
	Set oDirections = g_oObjectEditor.XmlObject.selectSingleNode("Directions/Direction[@oid]")
	bOnlyOwnActivities  = g_oObjectEditor.XmlObject.selectSingleNode("OnlyOwnActivity").nodeTypedValue
	bShowOrgWithoutActivities = g_oObjectEditor.XmlObject.selectSingleNode("ShowOrgWithoutActivities").nodeTypedValue
	nActivityTypes		= CLng( g_oObjectEditor.XmlObject.selectSingleNode("ActivityTypes").nodeTypedValue )
	sOrgName 	= g_oObjectEditor.XmlObject.selectSingleNode("OrganizationName").nodeTypedValue
	sFolderName = g_oObjectEditor.XmlObject.selectSingleNode("FolderName").nodeTypedValue
	If nMode = DKPTREEMODES_ORGANIZATIONS Then
		If bShowOrgWithoutActivities Then
			sResult = "��� �����������"
			nParts = -1
		Else
			' ����� "�����������"
			sResult = "�����������"
			sResult = sResult & " �"
			If bOnlyOwnActivities Then
				sResult = sResult & " �����"
			End if
			sResult = sResult & " "
			nCase = CASE_INSTRUMENTAL
			nParts = initActivityNameParts(nActivityTypes, CASE_INSTRUMENTAL, s1, s2, s3)
		End If
	Else
		' ����� "����������"
		If bOnlyOwnActivities Then
			sResult = sResult & "��� "
		End if
		nCase = CASE_NOMINATIVE
		nParts = initActivityNameParts(nActivityTypes, CASE_NOMINATIVE, s1, s2, s3)
		If IsEmpty(sResult) Then
			s1 = UCase( Left(s1,1) ) & Mid(s1, 2)
		End If
	End If
	' ������� ��������� ���� "�������, ������� � ��������"
	Select Case nParts
	    Case 1
	        sResult = sResult & s1
	    Case 2
	        sResult = sResult & s1 & " � " & s2
	    Case 3
	        sResult = sResult & s1 & ", " & s2 & " � " & s3
	End Select
	IF (Not oDirections Is Nothing) Or (nActivityState <> 0) Or (nFolderState <> 0) Or (Len("" & sFolderName) > 0) Or (Len("" & sOrgName) > 0) Then 
	   sResult = sResult & " (�������� ��������� ��������)" 
	End If
	GetFilterStateDescription = "" & sResult
End Function


'==============================================================================
Sub usrXEditor_OnLoad( oSender, oEventArgs )
    ' �������� ������ �� ��������� ������ ��������� ������� ObjectEditorClass
	Set g_oObjectEditor = oSender
	' ���������� �� ������� "AfterEnableControls" 1-�� ��������
	oSender.Pages.Items()(0).EventEngine.AddHandlerForEvent "AfterEnableControls", Null, "OnAfterEnableControls"
End Sub


'==============================================================================
' ����������:	���������� ������� ��������� PageStart
' ���������:    -
' ���������:	oSender - ������, ������������ �������; ����� - �������� �������
'				oEventArgs - ������, ����������� ��������� �������, ����� Null
' ����������:	���������-���������� ������� ���������� �� ���������� "���������"
'				�������� ���������; 
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	Dim bIsFilterSet			' ������� ����, ��� � ������� ������ ������
	Dim oBtnOpenFilterDialog	' ������ �� HTML-DOM ������ ������ "����������"
	Dim oBtnClearFilter			' ������ �� HTML-DOM ������ ������ "��������"
    
	' ���������� ������ �� HTML-������� � "����������" ����������� ������� ����� 
	With g_oObjectEditor.CurrentPage.HtmlDivElement
		' ������ "���������� (������)"		
		Set oBtnOpenFilterDialog = .all.item("btnOpenFilterDialog")
		If Not(oBtnOpenFilterDialog Is Nothing) Then 
			Set oBtnOpenFilterDialog.onClick = GetRef("OnOpenFilterDialog")
		End If
	End With
	updateTreeModeDescription
	updateIncidentSortModeDescription
End Sub


'==============================================================================
' ����������:	���������� ������� ������� ������ "���������� (������)"
'				�������� "�������" ������ �������������� ���������� �������,
'				��������� ��������� �������; ��� ��������� ����� ����������
'				�������� ����������� �������� �������� ��������� (������� � 
'				������) � ������������ ������, ���������� �� ������� 
' ���������:    -
' ���������:	-
Sub OnOpenFilterDialog()
	Dim oFilterDialog	' ��������� ������� ��������� (���������� �������)
	Dim vResult			' ��������� ������ ��������� 
	Dim nOldTS			' ts �� ������ ��������� � ������
	
	' ������� ��������� ������, �������� ��������� ������� ���������:
	Set oFilterDialog = new ObjectEditorDialogClass
	' ...� ���������� ������� ���������� ������ ������� ��������� (����� ���� 
	' �������������� ������ ������ �������������� ���������� ������� � �����
	' ���):
	Set oFilterDialog.ParentObjectEditor = g_oObjectEditor
	' ...��������� ��� ���� ��� � ������������� �������������� ������� - ��� 
	' ��� �� ������, ��� ������������ ������ ����������:
	oFilterDialog.ObjectType = "FilterDKP"
	oFilterDialog.ObjectID = g_oObjectEditor.ObjectID
	' ...��������� ���������������� �������� ���������, ������������� ��� 
	' ���������� ���������� ������� (��. ����������� � ����������):
	oFilterDialog.MetaName = "EditorInDialog"
	oFilterDialog.IsNewObject = true
	nOldTS = SafeCLng(g_oObjectEditor.XmlObject.getAttribute("ts"))
	
	' �������� ����������� ������� ���������:
	vResult = ObjectEditorDialogClass_Show(oFilterDialog)
	If ( nOldTS <> SafeCLng(g_oObjectEditor.XmlObject.getAttribute("ts")) ) Then
		' ��������� ts �������. ��� ������ � ������� ������ ������ "�������"
		updateTreeModeDescription
	Else
		' ���� �������� � ���������� Empty, ��� ��������, ��� �������� ��� ������
		' ��� �������� ��������� (�� ������ "��������" ��� ����); � ���� ������, 
		' ������ �� �������, ������ ������� �� �����������
		If Not hasValue(vResult) Then Exit Sub

		updateTreeModeDescription		
		
		' �������� ���������� �����, ���������� � ���������� ������, ���������� 
		' �� �������:
		ReloadTree
	End If
End Sub


'==============================================================================
' ��������� �������� �������� ������ ������
Sub updateTreeModeDescription
    oTreeModeDescription.innerText = GetFilterStateDescription
End Sub


'==============================================================================
' ����������:	�������� ������������ ������ �������������� �������
' ���������:    -
' ���������:	-
Sub ReloadTree()
    window.parent.Reload()
	XService.DoEvents()
End Sub



'==============================================================================
' ���������� ����� �� ������ �������� ������� ��������� ���������� ����������
Sub OnOpenIncidentSortDialog()
	Dim oFilterDialog	' ��������� ������� ��������� (���������� �������)
	Dim vResult			' ��������� ������ ��������� 

	Set oFilterDialog = new ObjectEditorDialogClass
	Set oFilterDialog.ParentObjectEditor = g_oObjectEditor
	oFilterDialog.ObjectType = "FilterDKP"
	oFilterDialog.ObjectID = g_oObjectEditor.ObjectID
	oFilterDialog.MetaName = "IncidentSortEditorInDialog"
	oFilterDialog.IsNewObject = true
	vResult = ObjectEditorDialogClass_Show(oFilterDialog)
	If Not IsEmpty(vResult) Then
		InitIncidentSortMode
		updateIncidentSortModeDescription
		ReloadTree
	End If
End Sub


'==============================================================================
' ���������� ����� �� ������ ������ ���������� � ��������� "�� ���������"
Sub OnSetIncidentSortDefault
	g_oObjectEditor.XmlObject.selectNodes("IncidentSortOrder/*").removeAll
	g_oObjectEditor.XmlObject.selectSingleNode("IncidentSortMode").nodeTypedValue = ""
	updateIncidentSortModeDescription
	ReloadTree
End Sub


'==============================================================================
Function InitIncidentSortMode
	Dim oItems
	Dim oItem
	Dim sParamValue
	
	Set oItems = g_oObjectEditor.XmlObject.selectNodes("IncidentSortOrder/*")
	For Each oItem In oItems
		Set oItem = g_oObjectEditor.Pool.GetXmlObjectByXmlElement(oItem, Null)
		If oItem.selectSingleNode("Direction").nodeTypedValue = SORTDIRECTIONS_DESC Then
			If Not IsEmpty(sParamValue) Then sParamValue = sParamValue & ":"
			sParamValue = sParamValue & oItem.selectSingleNode("Field").text &	"-"
		ElseIf oItem.selectSingleNode("Direction").nodeTypedValue = SORTDIRECTIONS_ASC Then
			If Not IsEmpty(sParamValue) Then sParamValue = sParamValue & ":"
			sParamValue = sParamValue & oItem.selectSingleNode("Field").text &	"+"
		ENd If
	Next
	g_oObjectEditor.XmlObject.selectSingleNode("IncidentSortMode").nodeTypedValue = sParamValue
End Function


'==============================================================================
' ��������� �������� ������ ���������� ����������
Function GetIncidentSortMode()
	Dim oItems
	Dim oItem
	Dim sDesc
	Dim nMode
	
	Set oItems = g_oObjectEditor.XmlObject.selectNodes("IncidentSortOrder/*")
	For Each oItem In oItems
		Set oItem = g_oObjectEditor.Pool.GetXmlObjectByXmlElement(oItem, Null)
		nMode = oItem.selectSingleNode("Direction").nodeTypedValue
		If nMode = SORTDIRECTIONS_ASC OR nMode = SORTDIRECTIONS_DESC Then
			If Not IsEmpty(sDesc) Then sDesc = sDesc & ", "
			sDesc = sDesc & NameOf_IncidentSortFields( oItem.selectSingleNode("Field").text )
		End If
	Next

	If IsEmpty(sDesc) Then sDesc = "�� ���������"	
	GetIncidentSortMode = sDesc
End Function


'==============================================================================
' ��������� ���� ����������� ������� ���������� ����������
Sub updateIncidentSortModeDescription
	oIncidentSortModeDescription.innerText = GetIncidentSortMode()
End Sub


'==========================================================================
' ���������� ������� "AfterEnableControls" �������� ���������
'	[in] oEventArgs As EnableControlsEventArgs
Public Sub OnAfterEnableControls(oSender, oEventArgs)
	document.all("btnOpenFilterDialog").disabled = Not oEventArgs.Enable
	document.all("btnOpenIncidentSortDialog").disabled = Not oEventArgs.Enable
	document.all("btnSetIncidentSortDefault").disabled = Not oEventArgs.Enable
End Sub
