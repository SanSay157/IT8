Option Explicit

'==============================================================================
Dim ObjectEditor			' �������� �������
Dim Pool					' ��� ��������
Dim DepartmentEditor		' �������� �������� "�������������"
Dim ExecutorEditor			' �������� �������� "��������� �� �������������"
Dim IsAcquaintEditor		' �������� �������� "�����������"
Dim DateEditor				' �������� �������� "����"
Dim ExecutorHandlerClass	' ����� ���������� ������������ ����������, 
							'  ��������� � ���������� "��������� �� �������������"

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	' ���������� ������ ���������
	Set ObjectEditor = oSender
	' �������� ���
	Set Pool = ObjectEditor.Pool
End Sub

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	' ����������� ��������� �������
	Set DepartmentEditor	= TMS_GetPropertyEditor(ObjectEditor, Nothing, "Department")
	Set ExecutorEditor		= TMS_GetPropertyEditor(ObjectEditor, Nothing, "Executor")
	Set IsAcquaintEditor	= TMS_GetPropertyEditor(ObjectEditor, Nothing, "ExecutorIsAcquaint")
	Set DateEditor			= TMS_GetPropertyEditor(ObjectEditor, Nothing, "DocsGettingDate")
	
	' �������������� ��������� ������� "��������� �� �������������",
	' "�����������" � "���� ��������� ����������"
	Set ExecutorHandlerClass = TMS_InitAcquaintedEmployeeHandler( _
		ExecutorEditor, IsAcquaintEditor, DateEditor )
		
	' ������������� �� ������� ��������� �������������
	DepartmentEditor.EventEngine.AddHandlerForEvent "BeforeSelect", Nothing, "OnDepartmentChanging"
	DepartmentEditor.EventEngine.AddHandlerForEvent "AfterSelect", Nothing, "OnDepartmentChanged"
	DepartmentEditor.EventEngine.AddHandlerForEvent "BeforeUnlink", Nothing, "OnDepartmentChanging"
	DepartmentEditor.EventEngine.AddHandlerForEvent "AfterUnlink", Nothing, "OnDepartmentChanged"
	DepartmentEditor.EventEngine.AddHandlerForEvent "BeforeCreate", Nothing, "OnDepartmentChanging"
	DepartmentEditor.EventEngine.AddHandlerForEvent "AfterCreate", Nothing, "OnDepartmentChanged"
	DepartmentEditor.EventEngine.AddHandlerForEvent "BeforeDelete", Nothing, "OnDepartmentChanging"
	DepartmentEditor.EventEngine.AddHandlerForEvent "AfterDelete", Nothing, "OnDepartmentChanged"
	DepartmentEditor.EventEngine.AddHandlerForEvent "BeforeMarkDelete", Nothing, "OnDepartmentChanging"
	DepartmentEditor.EventEngine.AddHandlerForEvent "AfterMarkDelete", Nothing, "OnDepartmentChanged"
	
	' ���������/��������� ������ �� ����������� �� �������������
	disableExecutor()
End Sub

'==============================================================================
' ���������� �������, ����������� ����� ���������� �������� "�������������"
Sub OnDepartmentChanging( oSender, oEventArgs )
	Dim sMessage
		
	' ���� ���������� �� ������������� �� �����, �� ������ �� ������
	If ExecutorEditor.Value Is Nothing Then Exit Sub
	
	sMessage = "������ �� ���������� �� ������������� ����� ��������." & vbNewLine & "�� �������, ��� ������ ����������?"
	If confirm(sMessage) = False Then
		oEventArgs.ReturnValue = False
		DepartmentEditor.SetData()
	End If
End Sub

'==============================================================================
' ���������� �������, ����������� ����� ��������� �������� "�������������"
Sub OnDepartmentChanged( oSender, oEventArgs )
	Set ExecutorEditor.Value = Nothing
	IsAcquaintEditor.Value = False
	DateEditor.Value = Null
	
	' ���������/��������� ������ �� ����������� �� �������������
	disableExecutor()
End Sub

'==============================================================================
' ���������/��������� ������ �� ����������� �� �������������
Sub disableExecutor()
	If DepartmentEditor.Value Is Nothing Then
		TMS_EnablePropertyEditor ExecutorEditor, False
	Else
		TMS_EnablePropertyEditor ExecutorEditor, True
	End If

	' ������������ ���������, ��������� � ������������
	ExecutorHandlerClass.Handle()
End Sub

'==============================================================================
' ���������� ��������� ����������� ��� ������ �����������
Sub usr_DepartmentParticipation_Executor_ObjectPresentation_OnGetRestrictions(oSender, oEventArgs)
	oEventArgs.UrlParams = "DepartmentID=" & DepartmentEditor.ValueID
End Sub



