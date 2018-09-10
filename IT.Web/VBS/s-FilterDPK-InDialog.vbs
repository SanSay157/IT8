Option Explicit

Dim g_oObjectEditor	' ������-�������� ������� (ObjectEditorClass)

' ������������ ���������� ���������� ���������� ������� �������� HTML-����:
Call window.attachEvent( "onload", GetRef("AddButtonOnWindowLoad") )


'==============================================================================
' ������� ������ "�������"
Sub AddButtonOnWindowLoad()
	' HTML-������������� ������� ��������� (�� �� ������� ���������!) �� ������ 
	' ������ ������������ � �������� ����� HTML DOM: ��������� ����� ������
	Dim oTD
	Set oTD = xBarControl1.Rows(0).insertCell(1)
	oTD.ID = "xCtrlPlace_cmdClose"
	oTD.innerHTML =_
					"<BUTTON ID='cmdClose' style='display:inline;' CLASS='x-button-wide'" & _
					"	TITLE='��������� � ������� ��� ���������� ��������' LANGUAGE='VBScript' ONCLICK='cmdClose_onClick'>" & _
					"	<CENTER>�������</CENTER></BUTTON>"
End Sub 


'==============================================================================
' ���������� ������ "�������"
Sub cmdClose_onClick
	Dim vResult
	g_oObjectEditor.XmlObject.setAttribute "ts", SafeCLng(g_oObjectEditor.XmlObject.getAttribute("ts")) + 1
	vResult = g_oObjectEditor.Save
	If IsEmpty(vResult) Then Exit Sub
	' �� ������������ - ������� �������� ����������������
	' ��������� ReturnValue
	X_SetDialogWindowReturnValue Empty
	' � ������� ����
	window.Close
End Sub


'==============================================================================
' ���������� "Load" ���������
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	' �������� ������ �� ��������� ������ ��������� ������� ObjectEditorClass
	Set g_oObjectEditor = oSender
End Sub


'==============================================================================
' ���������� "PageStart" ���������
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	trackModeChanged oSender.CurrentPage.GetPropertyEditor(oSender.XmlObject.selectSingleNode("Mode"))
	trackShowOrgWithoutActivities oSender.XmlObject.selectSingleNode("ShowOrgWithoutActivities").nodeTypedValue
End Sub


'==============================================================================
' ���������� "Validate" ���������
Sub usrXEditor_OnValidate( oSender, oEventArgs )
	' ���� ����� "�����������" � ������� ���� "���������� ����������� ��� �����������", �� ����������� � ��������� ��������
	If oSender.XmlObject.selectSingleNode("Mode").nodeTypedValue = DKPTREEMODES_ORGANIZATIONS Then
		If oSender.XmlObject.selectSingleNode("ShowOrgWithoutActivities").nodeTypedValue = True Then
			If vbNo = MsgBox("��������� ����� (""��� �����������"") ����� �������� � ����� ������ �������� ��������. ����������?", vbYesNo + vbQuestion) Then
				oEventArgs.ReturnValue = False
			End If
		End If
	End If
End Sub


'==============================================================================
' ���������� "Changed" PE �������� ShowOrgWithoutActivities ("���������� ����������� ��� �����������")
Sub usr_ShowOrgWithoutActivities_Bool_OnChanged(oSender, oEventArgs)
	trackShowOrgWithoutActivities oEventArgs.NewValue
End Sub


'==============================================================================
' ������������� ��������� ����� "������ ��� ����������" � "������ �������� ����������" � ���-�� �� ����� "����������� ��� �����������"
Sub trackShowOrgWithoutActivities(bShowOrgWithoutActivitiesChecked)
	Dim oPE_OnlyOwnActivity
	Set oPE_OnlyOwnActivity  = g_oObjectEditor.CurrentPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("OnlyOwnActivity") )
	If Not Nothing Is oPE_OnlyOwnActivity Then
	    If bShowOrgWithoutActivitiesChecked Then
		    oPE_OnlyOwnActivity.Value = False
		    g_oObjectEditor.CurrentPage.EnablePropertyEditor oPE_OnlyOwnActivity, False
	    Else
		    g_oObjectEditor.CurrentPage.EnablePropertyEditor oPE_OnlyOwnActivity, True
	    End If
	End If
End Sub


'==============================================================================
' ���������� "Changed" PE �������� Mode (�����)
Sub usr_Mode_Selector_OnChanged(oSender, oEventArgs)
	trackModeChanged oSender
End Sub


'==============================================================================
'	[in] oModePE - PE �������� Mode (�����)
Sub trackModeChanged(oModePE)
	Dim oPE
	Dim oPE_OnlyOwnActivity
	Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("ShowOrgWithoutActivities") )
	Set oPE_OnlyOwnActivity  = g_oObjectEditor.CurrentPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("OnlyOwnActivity") )
	If Not Nothing Is oPE And Not Nothing Is oPE_OnlyOwnActivity Then
	    If oModePE.Value = DKPTREEMODES_ORGANIZATIONS Then
		    ' �����������:
		    oPE_OnlyOwnActivity.LabelText = "������ ����������� � ����� ������������"
		    ' ������� "���������� ����������� ��� �����������" ������� ���������
		    oModePE.ParentPage.EnablePropertyEditor oPE, True
	    Else
		    ' ����������
		    oPE_OnlyOwnActivity.LabelText = "������ ��� ����������"
		    ' ������� "���������� ����������� ��� �����������" �������� � ������� �����������
		    oPE.Value = False
		    oModePE.ParentPage.EnablePropertyEditor oPE, False
	    End If
	End If
End Sub

Function CanAccessNotOwnActivities()
    CanAccessNotOwnActivities = GetScalarValueFromDataSource("CheckEmployeeAccessToNotOwnFolders", Array("Employee"), Array(GetCurrentUserProfile().EmployeeID))
End Function
