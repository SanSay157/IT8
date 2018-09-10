Option Explicit

'=====================================================================
' ПОДКЛЮЧАЕТСЯ К СТРАНИЦАМ, ГЕНЕРИРУЕМЫМ С МАСТЕР-СТРАНИЦЕЙ "xu-transfer.master"

'----------------------------------------------------------------------
' Инициализация страницы
Sub Window_OnLoad
	' Дожидаемся загрузки всех частей страницы
	' Примечание: объект g_TransferServiceClient объявлен и создается в файле x-transfer.vbs
	X_WaitForTrue "TransferServiceClient.OnMainPageLoad(IS_IMPORT)", "X_IsDocumentReadyEx(null, ""XProgressBar"")"
        
	document.all("XTransfer_cmdCancel").disabled = false	
End Sub

'----------------------------------------------------------------------
' Вызывается при закрытии окна
Sub Window_onBeforeUnload()
	TransferServiceClient.OnBeforeUnload
End Sub

'----------------------------------------------------------------------
' Обработчик кнопки Cancel
Sub XTransfer_cmdCancel_OnClick()
    TransferServiceClient.OnCancelClick
End Sub
