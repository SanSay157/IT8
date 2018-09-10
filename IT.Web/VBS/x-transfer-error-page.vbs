Option Explicit

'=====================================================================
' ������������ � ���������, ������������ � ������-��������� "xu-transfer-error.master"

Dim g_bGoodButtonPressed	    ' ����������, ��� ������������ ����� ���� �� ������ (� �� ������ ���� �������� �� "�������")
Dim g_bShowAreYouSureMsgBox     ' ���������� �� �������-���� "�� �������, ���..."
g_bShowAreYouSureMsgBox = True  ' �� ��������� - ����������

'----------------------------------------------------------------------
' ������������� ��������
Sub Window_OnLoad
	' ��������: �� OnSpecialPageLoad ���������� ������� Init2
	TransferServiceClient.OnSpecialPageLoad
End Sub

'----------------------------------------------------------------------
' ������������� �������� - ���� 2
' ���������� �� ������� ��������� �������� �������� �� OnSpecialPageLoad
Sub Init2
	dim aButtons            ' ������ ��������-id ������
	dim i,j
	dim oQueryStr           ' ������ QueryString
	dim sAllowedActions     ' ������ � ������������� ��������������� ���������� ��������
	dim aAllowedActions     ' ������ ��������������� ���������� ��������
	dim aDelimeters         ' ������ ���������� ������������ ���������������
	dim oCancelButton       ' ������ "��������"
	
	' ������ ���������� ����������� ��������������� ���������� ��������
	aDelimeters = Array(" ", ",", "|", ";")
	
	' ����� ��������� ��� ���������� html-���������
	' CURRENT_DIALOG_TYPE - ���������������� ��������� (��. class XTransferServicePage)
	TransferServiceClient.FillTableInModalDialog CURRENT_DIALOG_TYPE 
	
	' ������ ���������� ������
	aButtons = Array("XTransfer_cmdCancel", _
	    "XTransfer_ContentPlaceHolderForAdditionalButtons_cmdIgnore", _
	    "XTransfer_ContentPlaceHolderForAdditionalButtons_cmdIgnoreAll", _
	    "XTransfer_ContentPlaceHolderForAdditionalButtons_cmdRetry", _
	    "XTransfer_ContentPlaceHolderForAdditionalButtons_cmdSkip", _
	    "XTransfer_ContentPlaceHolderForAdditionalButtons_cmdReplace")
	for i = LBound(aButtons) to UBound(aButtons)
	    if not document.all(aButtons(i)) Is nothing then document.all(aButtons(i)).disabled = false
	next
	
	' �������� ������ QueryString
	set oQueryStr = X_GetQueryString
	' ������� �������� ������ ��������������� ���������� ��������
	' ���� ��������������� �������� �� �����, ��������� ������ ��� ���������
	if not oQueryStr is nothing then
	    sAllowedActions = oQueryStr.GetValue("ALLOWEDACTIONS", "")
	    if sAllowedActions <> "" then
	        for i = LBound(aDelimeters) to UBound(aDelimeters)
	            aAllowedActions = Split(sAllowedActions, aDelimeters(i), -1)
	            ' ���� ������� ������� ������ ��������� ������� �����������, ��������� ����
	            if IsArray(aAllowedActions) then
	                if sAllowedActions <> aAllowedActions(0) then exit for
	            end if
	        next
	    end if
	end if
	' ���� � ��������� �������� � ���������� ������ ������ � �������������� � ������� ����������������
	if IsArray(aAllowedActions) then
	    for i = LBound(aButtons) to UBound(aButtons)
	        Dim bShowButton     ' ���������� �� ������� ������
	        bShowButton = false
	        for j = LBound(aAllowedActions) to UBound(aAllowedActions)
	            if InStrRev(aButtons(i), aAllowedActions(j)) _
	               = Len(aButtons(i)) - Len(aAllowedActions(j)) + 1 then
	                bShowButton = true
	                exit for
	            end if
	        next
	        ' �������� � ��������� ������
	        if not bShowButton and not document.all(aButtons(i)) is nothing then
	            document.all(aButtons(i)).disabled = true
	            document.all(aButtons(i)).style.display = "none"
	        end if
	    next
	    ' ���� �������� ������ ���� ������ "��������", �� ����������
	    ' ������������, ������ �� ��, ����� ���
	    g_bShowAreYouSureMsgBox = not (UBound(aAllowedActions) = 0 and _
	                                   aAllowedActions(0) = "cmdCancel")
	end if
	
	g_bGoodButtonPressed = false
	
	' ������������� ����� �� "��������", ���� ��� ������ � �� ���������
	Set oCancelButton = document.all("XTransfer_cmdCancel")
	if not oCancelButton is nothing _
	   and oCancelButton.disabled = false _
	   and oCancelButton.style.display = "" then
	    oCancelButton.focus
	end if
End Sub

'----------------------------------------------------------------------
' ���������� ��� ������� ������� ����
Sub Window_onBeforeUnload()
	If False = g_bGoodButtonPressed Then 
		X_SetDialogWindowReturnValue WINDOW_RESULT_IGNORE
	End If
End Sub

'----------------------------------------------------------------------
' ��������� ����������
Sub Document_onKeyPress()
	If VK_ESC = window.event.keyCode Then
		' ��� ������� Esc ����������� ������ "������������"
		XTransfer_cmdIgnore_OnClick
	End If
End Sub

'----------------------------------------------------------------------
' ����������� ������� ������
Sub XTransfer_ContentPlaceHolderForAdditionalButtons_cmdIgnore_OnClick()
	X_SetDialogWindowReturnValue WINDOW_RESULT_IGNORE
	g_bGoodButtonPressed = True
	window.close 
End Sub

Sub XTransfer_ContentPlaceHolderForAdditionalButtons_cmdIgnoreAll_OnClick()
	X_SetDialogWindowReturnValue WINDOW_RESULT_IGNOREALL
	g_bGoodButtonPressed = True
	window.close 
End Sub

Sub XTransfer_ContentPlaceHolderForAdditionalButtons_cmdRetry_OnClick()
	X_SetDialogWindowReturnValue WINDOW_RESULT_RETRY
	g_bGoodButtonPressed = True
	window.close 
End Sub

Sub XTransfer_ContentPlaceHolderForAdditionalButtons_cmdSkip_OnClick()
	X_SetDialogWindowReturnValue WINDOW_RESULT_SKIP
	g_bGoodButtonPressed = true
	window.close 
End Sub

Sub XTransfer_ContentPlaceHolderForAdditionalButtons_cmdReplace_OnClick()
	X_SetDialogWindowReturnValue WINDOW_RESULT_REPLACE
	g_bGoodButtonPressed = true
	window.close 
End Sub


Sub XTransfer_cmdCancel_OnClick()
    Dim bCancelProcess      ' ��������� �� �������
    
    ' ����������, ����� �� ��������� �������
    If g_bShowAreYouSureMsgBox Then
        ' ���������� ������������, ������ �� ��
        bCancelProcess = (TransferServiceClient.AreYouSure_MsgBox() = vbYes)
    Else
        ' ���������� �� ����
        bCancelProcess = True
    End If
    ' ���� �����, ��������� �������
	If bCancelProcess Then
		X_SetDialogWindowReturnValue WINDOW_RESULT_CANCEL
		g_bGoodButtonPressed = True
		window.close 
	End If
End Sub
