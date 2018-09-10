Option Explicit

Dim g_oObjectEditor
Dim g_sCurrentSystemUserID	' ������������� �������� ������������

'==========================================================================
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	' �������� ������ �� ��������� ������ ��������� ������� ObjectEditorClass
	Set g_oObjectEditor = oSender
	' �������� ������ �������������: SystemUser-������� ������������ ����������
	g_sCurrentSystemUserID = GetCurrentUserProfile().SystemUserID
	' ������� ���������� ������� AfterEnableControls ��� 1-�� (� ������������) ������� ���������
	If g_oObjectEditor.IsObjectCreationMode Then
		g_oObjectEditor.Pages.Items()(0).EventEngine.AddHandlerForEvent "AfterEnableControls", Nothing, "OnAfterEnableControls_TrackRadio"
	End If
End Sub


'==========================================================================
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	Dim oXmlObjectCause
	If Not g_oObjectEditor.IsObjectCreationMode Then
		Set oXmlObjectCause = g_oObjectEditor.Pool.GetXmlObjectByOPath(g_oObjectEditor.XmlObject, "Cause")
		TrackTimeLossCause g_oObjectEditor.XmlObject, oXmlObjectCause, g_oObjectEditor.CurrentPage
	End If
End Sub


'==========================================================================
' ��������� ���������� ����� ����� ������ ����� �����������
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	If g_oObjectEditor.IsObjectCreationMode Then
		' ���� ����� �������� �� ������, �� ��NULL�� �������� ���� �������� � ���������� �������
		If document.all("LostTimeByPeriod").Checked Then
			g_oObjectEditor.XmlObject.selectSingleNode("LossFixed").text = ""
			g_oObjectEditor.XmlObject.selectSingleNode("LostTime").text = ""
		Else
			' ����� ��NULL�� �������� ���� ������ ���������, ���� ��������� ���������
			g_oObjectEditor.XmlObject.selectSingleNode("LossFixedStart").text = ""
			g_oObjectEditor.XmlObject.selectSingleNode("LossFixedEnd").text = ""
		End If
	End If
End Sub


'==========================================================================
' ���������� ������� OnAfterEnableControls ��� ��������� �������� ������� - 
' ������������� ����������� ��������� ������� ���� ��������, ���������� �������, ���� ������ ���������, ���� ��������� ���������
' (� ����� �� ��������������) �� ��������� ��������� �����-������
Sub OnAfterEnableControls_TrackRadio( oSender, oEventArgs )
	Dim oEditorPage		' As EditorPage
	Dim oPE_Date		' As XPEDateTime
	Dim oPE_Time		' As PETimeEditButtonClass
	Dim oPE_DateStart	' As XPEDateTime
	Dim oPE_DateEnd		' As XPEDateTime
	Dim bByDate
	
	Set oEditorPage = g_oObjectEditor.CurrentPage
	Set oPE_Date = oEditorPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("LossFixed") )
	Set oPE_Time = oEditorPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("LostTime") )
	Set oPE_DateStart = oEditorPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("LossFixedStart") )
	Set oPE_DateEnd   = oEditorPage.GetPropertyEditor( g_oObjectEditor.XmlObject.selectSingleNode("LossFixedEnd") )
	
	bByDate = document.all("LostTimeByDate").Checked
	If oEventArgs.Enable Then
		oEditorPage.EnablePropertyEditorEx oPE_Date, bByDate, True
		oEditorPage.EnablePropertyEditorEx oPE_Time, bByDate, True
		oPE_Date.Mandatory = bByDate 
		oPE_Time.Mandatory = bByDate
		oEditorPage.EnablePropertyEditorEx oPE_DateStart, document.all("LostTimeByPeriod").Checked, True
		oEditorPage.EnablePropertyEditorEx oPE_DateEnd, document.all("LostTimeByPeriod").Checked, True
		oPE_DateStart.Mandatory = Not bByDate
		oPE_DateEnd.Mandatory = Not bByDate
	End If
End Sub


'==============================================================================
' ���������� �����-������ "�� ����"/"�� ������"
Sub ChangeLossType_OnClick
	With New EnableControlsEventArgsClass
		.Enable = True
		OnAfterEnableControls_TrackRadio g_oObjectEditor, .Self()
	End With
End Sub
'==============================================================================
' ��������� ����������� ������ ��� ���������� ���������� ��������� ������ ��������
Sub usr_TimeLoss_Cause_ObjectDropDown_OnGetRestrictions(oSender, oEventArgs)
	oEventArgs.ReturnValue = oEventArgs.ReturnValue & _
		"&SystemUserID=" & g_sCurrentSystemUserID & _
		"&Privileges=" & SYSTEMPRIVILEGES_MANAGETIMELOSS
End Sub

'==============================================================================
' ���������� ��������� ������� ��������
Sub usr_TimeLoss_Cause_OnChanging(oSender, oEventArgs)
	Dim oXmlObjectCause
	Dim nType
	Dim oPE					' �������� ��������
	
	' ������� ��������� ������ "������� ��������"
	Set oXmlObjectCause = oSender.ObjectEditor.Pool.GetXmlObject("TimeLossCause", oEventArgs.NewValue, Null)
	
	' � ����������� �� ���� ��������� �������������� � ����������� ���� �����
	nType = oXmlObjectCause.selectSingleNode("Type").nodeTypedValue
	Set oPE = oSender.ParentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("Folder") )
	
	If nType = TIMELOSSCAUSETYPES_NOTAPPLICABLETOFOLDER Then
		' ���� � �������� ����� ���-�� �������, �� ��������� ��������, ���� ���������� �� ��������� �������
		If Not IsNull(oPE.ValueID) Then
			If vbYes = MsgBox("��� ��������� ������� �������� �� ����� ���� ������� ������ �� ������/������/�������." & vbCr & "�������� (Yes) ��� ������� ���������� �������� (No) ?", vbYesNo + vbQuestion) Then
				oPE.ValueID = Null
			Else
				' ������, ��� ���� ��������� �� ���������� ��������
				oEventArgs.ReturnValue = False
				Exit Sub
			End If
		End If
	End If
	
	TrackTimeLossCause g_oObjectEditor.XmlObject, oXmlObjectCause, g_oObjectEditor.CurrentPage
End Sub


Sub TrackTimeLossCause(oXmlObject, oXmlObjectCause, oPage)
	Dim nType
	Dim oPE					' �������� ��������
	
	' � ����������� �� �������� "������� �������� �����������" (CommentReq) ��������� �������������� ���� Descr
	Set oPE = oPage.GetPropertyEditor( oXmlObject.selectSingleNode("Descr") )
	If Not oXmlObjectCause Is Nothing Then
	    oPE.Mandatory = oXmlObjectCause.selectSingleNode("CommentReq").nodeTypedValue
	Else
	    oPE.Mandatory = False
	End If
	
	' � ����������� �� ���� ��������� �������������� � ����������� ���� �����
	If Not oXmlObjectCause Is Nothing Then _
	    nType = oXmlObjectCause.selectSingleNode("Type").nodeTypedValue
	Set oPE = oPage.GetPropertyEditor( oXmlObject.selectSingleNode("Folder") )
	Select Case nType
		Case TIMELOSSCAUSETYPES_MUSTAPPLICABLETOFOLDER
			If Not oPE.Enabled Then
				oPage.EnablePropertyEditorEx oPE, True, True
			End If
			oPE.Mandatory = True
		Case TIMELOSSCAUSETYPES_NOTAPPLICABLETOFOLDER
			oPE.Mandatory = False
			oPage.EnablePropertyEditorEx oPE, False, True
		Case TIMELOSSCAUSETYPES_APPLICABLETOFOLDER
			If Not oPE.Enabled Then
				oPage.EnablePropertyEditorEx oPE, True, True
			End If
			oPE.Mandatory = False
		Case Else
		    If Not oPE.Enabled Then
				oPage.EnablePropertyEditorEx oPE, True, True
			End If
			oPE.Mandatory = False
	End Select
End Sub
