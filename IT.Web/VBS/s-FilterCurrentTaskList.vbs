Option Explicit

Dim g_oObjectEditor

'==============================================================================
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	' �������� ������ �� ��������� ������ ��������� ������� ObjectEditorClass
	Set g_oObjectEditor = oSender
	' ���������� �� ������� "AfterEnableControls" 1-�� ��������
	oSender.Pages.Items()(0).EventEngine.AddHandlerForEvent "AfterEnableControls", Nothing, "OnAfterEnableControls"
End Sub


'==============================================================================
' ����������:	���������� ������� ��������� PageStart
' ���������:    -
' ���������:	oSender - ������, ������������ �������; ����� - �������� �������
'				oEventArgs - ������, ����������� ��������� �������, ����� Null
' ����������:	���������-���������� ������� ���������� �� ���������� "���������"
'				�������� ���������; 
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	Dim bIsFilterSet		' ������� ����, ��� � ������� ������ ������
	Dim oButton 			' ������ �� HTML-DOM ������ ������ "����������"
	
	' ���������� ������ �� HTML-������� � "����������" ����������� ������� ����� 
	With g_oObjectEditor.CurrentPage.HtmlDivElement
		' ������ "���������� (������)"		
		Set oButton= .all.item("btnOpenFilterDialog")
		If Not(oButton Is Nothing) Then 
			Set oButton.onClick = GetRef("OnOpenFilterDialog")
		End If
		Set oButton = .all.item("btnCreateTimeLoss")
		If Not(oButton Is Nothing) Then 
			Set oButton.onClick = GetRef("OnCreateTimeLoss")
		End If
	End With
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
	
	' ������� ��������� ������, �������� ��������� ������� ���������:
	Set oFilterDialog = new ObjectEditorDialogClass
	' ...� ���������� ������� ���������� ������ ������� ��������� (����� ���� 
	' �������������� ������ ������ �������������� ���������� ������� � ����� ���):
	Set oFilterDialog.ParentObjectEditor = g_oObjectEditor
	' ...��������� ��� ���� ��� � ������������� �������������� ������� - ��� 
	' ��� �� ������, ��� ������������ ������ ����������:
	oFilterDialog.ObjectType = "FilterCurrentTaskList"
	oFilterDialog.ObjectID = g_oObjectEditor.ObjectID
	' ...��������� ���������������� �������� ���������, ������������� ��� 
	' ���������� ���������� ������� (��. ����������� � ����������):
	oFilterDialog.MetaName = "EditorInDialog"
	oFilterDialog.IsNewObject = true
	' �������� ����������� ������� ���������:
	vResult = ObjectEditorDialogClass_Show(oFilterDialog)
	
	' ���� �������� � ���������� Empty, ��� ��������, ��� �������� ��� ������
	' ��� �������� ��������� (�� ������ "��������" ��� ����); � ���� ������, 
	' ������ �� �������, ������ ������� �� �����������
	If Not hasValue(vResult) Then Exit Sub

	g_oObjectEditor.CurrentPage.SetData
	' �������� ���������� �����, ���������� � ���������� ������, ���������� 
	' �� �������:
	ReloadList
End Sub


'==============================================================================
Sub OnCreateTimeLoss
    Dim oTimeLossEditor
	Set oTimeLossEditor = New ObjectEditorDialogClass
	With oTimeLossEditor
		.IsNewObject = True 
		.IsAggregation = False
		Set .XmlObject = X_GetObjectFromServer("TimeLoss", Null, Null)
		.XmlObject.selectSingleNode("Worker").setAttribute "read-only", "1"
	End With	
		If hasValue(ObjectEditorDialogClass_Show(oTimeLossEditor)) Then
			' �������� ����� ������������ �������
			g_oObjectEditor.ObjectContainerEventsImp.OuterContainerPage.ExecuteScript "ReloadUserCurrentExpensesPanel"
		End If
	
End Sub


'==============================================================================
' ����������:	���� ���������� ������� ���������� �������; ������� �� ���������
'				� ������� ���������� ������� (������) ����������� �� ����� 
'				������� ������ (������)
Sub ReloadList()
	window.parent.ReloadList() 
End Sub


'==============================================================================
' ���������� �������� "����������� ������ ����������"
Sub usr_RestrictedList_Bool_OnChanged(oSender, oEventArgs)
	ReloadList
End Sub


'==============================================================================
' ���������� ������� "AfterEnableControls" ��������
Sub OnAfterEnableControls(oSender, oEventArgs)
	document.all("btnOpenFilterDialog").disabled = Not oEventArgs.Enable
	document.all("btnCreateTimeLoss").disabled = Not oEventArgs.Enable
End Sub
