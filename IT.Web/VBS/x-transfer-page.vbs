Option Explicit

'=====================================================================
' ������������ � ���������, ������������ � ������-��������� "xu-transfer.master"

'----------------------------------------------------------------------
' ������������� ��������
Sub Window_OnLoad
	' ���������� �������� ���� ������ ��������
	' ����������: ������ g_TransferServiceClient �������� � ��������� � ����� x-transfer.vbs
	X_WaitForTrue "TransferServiceClient.OnMainPageLoad(IS_IMPORT)", "X_IsDocumentReadyEx(null, ""XProgressBar"")"
        
	document.all("XTransfer_cmdCancel").disabled = false	
End Sub

'----------------------------------------------------------------------
' ���������� ��� �������� ����
Sub Window_onBeforeUnload()
	TransferServiceClient.OnBeforeUnload
End Sub

'----------------------------------------------------------------------
' ���������� ������ Cancel
Sub XTransfer_cmdCancel_OnClick()
    TransferServiceClient.OnCancelClick
End Sub
