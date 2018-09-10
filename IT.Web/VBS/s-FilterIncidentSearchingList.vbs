Option Explicit

Dim g_oFilterXmlObject
Dim g_bFilterDKPInitialized
Dim g_oObjectEditor


'==============================================================================
' ���������� ������� Load ������ ��� ������� 
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Set g_oObjectEditor = oSender
    setUpXmlObjectOfFoldersTreeFilter oSender
	
End Sub


'==============================================================================
Sub setUpXmlObjectOfFoldersTreeFilter(oObjectEditor)
	Dim oProp
	
	Set oProp = oObjectEditor.XmlObject.selectSingleNode("virtual-prop-filter")
	If oProp Is Nothing Then
		Set oProp = oObjectEditor.XmlObject.appendChild( oObjectEditor.XmlObject.ownerDocument.createElement("virtual-prop-filter") )
	End If
	Set g_oFilterXmlObject = oProp.firstChild
	If g_oFilterXmlObject Is Nothing Then
		' �������� � ���� ��������� ������ ��� ��������� ������� ��� ������ ������ �����
		Set g_oFilterXmlObject = oObjectEditor.Pool.CreateXmlObjectInPool( "FilterDKP" )
		' ������� ������ ������� � ����������� �������� ���������
		 oProp.appendChild X_CreateStubFromXmlObject(g_oFilterXmlObject)
	Else
		Set g_oFilterXmlObject = oObjectEditor.Pool.GetXmlObjectByXmlElement(g_oFilterXmlObject, Null)
	End If
End Sub


'==============================================================================
'	[in] oEventArgs As EditorStateChangedEventArgs
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	g_bFilterDKPInitialized = True
End Sub


'==============================================================================
' [in] oSender As XPEObjectTreeSelectorClass
' [in] oEventArgs As GetRestrictionsEventArgsClass
Sub usr_FilterIncidentSearchingList_Folders_ObjectsTreeSelector_OnGetRestrictions(oSender, oEventArgs)
	Dim oBuilder
	Dim oProp
	
	Set oBuilder = New QueryStringParamCollectionBuilderClass
	' �� ���� ��������� ���������� �������-������� 
	For Each oProp In g_oFilterXmlObject.selectNodes("*")
		If Not IsNull(oProp.dataType) Then
			If 0 < Len(oProp.text) Then
				oBuilder.AppendParameter oProp.tagName, oProp.text
			End If	 
		End If	 
	Next
	oEventArgs.ReturnValue = oBuilder.QueryString
End Sub


'==============================================================================
' ���������� ������ "���������" ������� �� ������� (�������� Folders)
Sub btnOpenFilterOfFoldersTree_onClick
	Dim oFilterDialog	' ��������� ������� ��������� (���������� �������)
	Dim vResult			' ��������� ������ ��������� 
	Dim nOldTS			' ts �� ������ ��������� � ������
	Dim oPE
	
	' ������� ��������� ������, �������� ��������� ������� ���������:
	Set oFilterDialog = new ObjectEditorDialogClass
	' ...� ���������� ������� ���������� ������ ������� ��������� (����� ���� 
	' �������������� ������ ������ �������������� ���������� ������� � ����� ���):
	Set oFilterDialog.ParentObjectEditor = g_oObjectEditor
	' ...��������� ��� ���� ��� � ������������� �������������� ������� - ��� 
	' ��� �� ������, ��� ������������ ������ ����������:
	Set oFilterDialog.XmlObject = g_oFilterXmlObject
	' ...��������� ���������������� �������� ���������, ������������� ��� 
	' ���������� ���������� ������� (��. ����������� � ����������):
	oFilterDialog.MetaName = "EditorInDialog"
	
	nOldTS = SafeCLng(g_oFilterXmlObject.getAttribute("ts"))
	
	' �������� ����������� ������� ���������:
	vResult = ObjectEditorDialogClass_Show(oFilterDialog)
	
	Set g_oFilterXmlObject = g_oObjectEditor.Pool.Xml.selectSingleNode("FilterDKP")

	If ( nOldTS <> SafeCLng(g_oFilterXmlObject.getAttribute("ts")) ) Then
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
		Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Folders"))
		oPE.Load
	End If
End Sub


'==============================================================================
' ���������� ������ "��������" ������� �� ������� (�������� Folders)
Sub btnClearFilterOfFoldersTree_onClick
	Dim oPE
	
	' ������� �������� "�����"
	g_oObjectEditor.XmlObject.selectNodes("Folders/*").removeAll
	' ������ ������ �������
	With g_oObjectEditor
		.XmlObject.selectSingleNode("virtual-prop-filter").selectNodes("*").removeAll
		g_oFilterXmlObject.parentNode.removeChild g_oFilterXmlObject
		Set g_oFilterXmlObject = Nothing
	End With
	' � ������ ��������
	setUpXmlObjectOfFoldersTreeFilter g_oObjectEditor
	' � ���������� �������� �����
	Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Folders"))
	oPE.Load
End Sub


Sub updateTreeModeDescription
End Sub


'==============================================================================
' ����������:	���������� ������� ��������� PageStart
' ���������:    -
' ���������:	oSender - ������, ������������ �������; ����� - �������� �������
'				oEventArgs - ������, ����������� ��������� �������, ����� Null
' ����������:	���������-���������� ������� ���������� �� ���������� "���������"
'				�������� ���������; 
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	trackStateOfDeadlineDates oSender
	trackParticipantsTree oSender
End Sub


'==============================================================================
' ���������� �������� "��������� � ���������"
Sub usr_IncidentsWithDeadline_Bool_OnChanged(oSender, oEventArgs)
	trackStateOfDeadlineDates oSender.ObjectEditor
End Sub


'==============================================================================
' ���������� �������� "��������� � ������������ ���������"
Sub usr_IncidentsWithExpiredDeadline_Bool_OnChanged(oSender, oEventArgs)
	Dim oPE
	trackStateOfDeadlineDates oSender.ObjectEditor
	
	' ��� ��������� ����� "��������� � ������������ ���������" - ��������� � ����������� ���� "��������� � ���������"
	With oSender.ObjectEditor.CurrentPage
		Set oPE = .GetPropertyEditor(oSender.ObjectEditor.XmlObject.selectSingleNode("IncidentsWithDeadline"))
		If oEventArgs.NewValue Then
			oPE.Value = True
			If oPE.Enabled Then
				.EnablePropertyEditor oPE, False
			End If
		ElseIf Not oPE.Enabled Then
			.EnablePropertyEditor oPE, True
		End If
	End With
End Sub


'==============================================================================
Sub trackStateOfDeadlineDates(oObjectEditor)
	Dim oPE
	Dim bEnableDeadlineDates
	
	With oObjectEditor.XmlObject
		If Nothing Is oObjectEditor.CurrentPage.GetPropertyEditor(.selectSingleNode("DeadlineDateBegin")) Then Exit Sub
		bEnableDeadlineDates = .selectSingleNode("IncidentsWithDeadline").nodeTypedValue And Not .selectSingleNode("IncidentsWithExpiredDeadline").nodeTypedValue
	End With
	
	With oObjectEditor.CurrentPage
		Set oPE = .GetPropertyEditor(oObjectEditor.XmlObject.selectSingleNode("DeadlineDateBegin"))
		If bEnableDeadlineDates <> oPE.Enabled Then
			.EnablePropertyEditor oPE, bEnableDeadlineDates
		End If
		If Not bEnableDeadlineDates Then
			oPE.Value = Null
		End If

		Set oPE = .GetPropertyEditor(oObjectEditor.XmlObject.selectSingleNode("DeadlineDateEnd"))
		If bEnableDeadlineDates <> oPE.Enabled Then
			.EnablePropertyEditor oPE, bEnableDeadlineDates
		End If
		If Not bEnableDeadlineDates Then
			oPE.Value = Null
		End If
	End With
End Sub

'==============================================================================
'��� �������� �������� ��������� ��������� ��� ���������������� �������� ������  ������������ � 
'� ������������ �� �������� �������� ExceptParticipants ("����������� �� ������") �������
Sub trackParticipantsTree(oObjectEditor)
	Dim oPE
	Dim bExceptParticipants
	
	With oObjectEditor.XmlObject
		If Nothing Is oObjectEditor.CurrentPage.GetPropertyEditor(.selectSingleNode("Participants")) Then Exit Sub
		bExceptParticipants = .selectSingleNode("ExceptParticipants").nodeTypedValue
	End With
	
	With oObjectEditor.CurrentPage
		Set oPE = .GetPropertyEditor(oObjectEditor.XmlObject.selectSingleNode("Participants"))
		If bExceptParticipants <> Not oPE.Enabled Then
			oPE.Enabled = Not bExceptParticipants
		End If
	End With
End Sub

'==============================================================================
' ���������� �������� "����������� �� ������"
Sub usr_ExceptParticipants_Bool_OnChanged(oSender, oEventArgs)
	Dim oPE
	
	' ��� ��������� ����� "����������� �� ������" - ����������� �������� ������  ������������
	' ��� ������ ��������� ������� ���������
	With oSender.ObjectEditor.CurrentPage
		Set oPE = .GetPropertyEditor(oSender.ObjectEditor.XmlObject.selectSingleNode("Participants"))
		If oEventArgs.NewValue=True Then
		.EnablePropertyEditorEx oPE, False,True
		Else 
		.EnablePropertyEditorEx oPE, True,True
		End If
	End With
	
End Sub
