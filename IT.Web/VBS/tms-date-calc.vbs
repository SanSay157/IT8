Option Explicit

Const DATE_CALC_BUTTON_ID = "btnDateCalc"
Const DATE_CALC_PARENT_ID = "XEditor_xPaneSpecialCaption"

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	TMS_CreateDataCalcButton()
End Sub

'==============================================================================
' ������� ������ ������ ������������ ���
Sub TMS_CreateDataCalcButton()
	Dim oParent	' ������������ HTML-������� ��� ������� ������
	Dim oButton ' ���������� HTML-������ ������
	' ���� ������������ ������� ��� ������
	Set oParent = document.all(DATE_CALC_PARENT_ID)
	If oParent Is Nothing Then
		Err.Raise -1, "TMS_CreateDataCalcButton", "�� ������ ������������ ������� ��� ������"
	End If
		
	' ���� ������ ��� ����, ������ �� ������
	If Not oParent.all(DATE_CALC_BUTTON_ID) Is Nothing Then Exit Sub
		
	' ������� ������:
	Set oButton = document.createElement("BUTTON")
	If oButton Is Nothing Then
		Err.Raise -1, "TMS_CreateDateCalcButton", "������ �������� �������� BUTTON"
	End If
	
	' ������������� ������
	oButton.id = DATE_CALC_BUTTON_ID
	oButton.className = "x-button x-button-control x-editor-button x-editor-button-control"
	oButton.style.width = "130px"
	oButton.value = "����������� ���"
	oButton.attachEvent "onclick", GetRef("TMS_OpenDateCalcDialog")
	
	' ��������� ������ � ������������ �������
	oParent.appendChild oButton
End Sub

'==============================================================================
' ��������� ������ ������ ������������ ���
Sub TMS_OpenDateCalcDialog()
	window.showModelessDialog XService.BaseURL & "tms-date-calc.htm", _
		null, _
		"dialogHeight:150px;dialogWidth:300px;center:yes;resizable:no;status:no;help:no"
End Sub