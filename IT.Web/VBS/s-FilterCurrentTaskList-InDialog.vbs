Option Explicit


'==============================================================================
' ����������:	���������� ������� ��������� PageStart
' ���������:    -
' ���������:	oSender - ������, ������������ �������; ����� - �������� �������
'				oEventArgs - ������, ����������� ��������� �������, ����� Null
' ����������:	���������-���������� ������� ���������� �� ���������� "���������"
'				�������� ���������; 
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	trackStateOfDeadlineInNextDays oSender
End Sub


'==============================================================================
' ���������� �������� "��������� � ���������"
Sub usr_IncidentsWithDeadline_Bool_OnChanged(oSender, oEventArgs)
	trackStateOfDeadlineInNextDays oSender.ObjectEditor
End Sub


'==============================================================================
' ���������� �������� "��������� � ������������ ���������"
Sub usr_IncidentsWithExpiredDeadline_Bool_OnChanged(oSender, oEventArgs)
	Dim oPE
	
	trackStateOfDeadlineInNextDays oSender.ObjectEditor
	
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
Sub trackStateOfDeadlineInNextDays(oObjectEditor)
	Dim bDeadlineEditable
	Dim oPE

	With oObjectEditor.XmlObject
		bDeadlineEditable = .selectSingleNode("IncidentsWithDeadline").nodeTypedValue And Not .selectSingleNode("IncidentsWithExpiredDeadline").nodeTypedValue
	End With
	
	Set oPE = oObjectEditor.CurrentPage.GetPropertyEditor(oObjectEditor.XmlObject.selectSingleNode("DeadlineInNextDays"))
	
	If bDeadlineEditable <> oPE.Enabled Then
		oObjectEditor.CurrentPage.EnablePropertyEditor oPE, bDeadlineEditable
	End If
	If Not bDeadlineEditable Then
		oPE.Value = ""
	End If
	
	oDeadlineInNextDaysTitle.disabled = Not bDeadlineEditable
End Sub
