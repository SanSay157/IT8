' ������ �������� ���������� ����������� �������
Option Explicit

Const TIMEOUT = 500 ' ��� ����� ����� "������" ���������
Const RETRY_COUNT = 1000 ' ����� ���������� �������� � ������ ����� �����

Dim g_nRetryCount: g_nRetryCount = RETRY_COUNT			' ������� �������� ��������
Dim g_sOperationID: g_sOperationID = Empty				' GUID ��������
Dim g_nInterval: g_nInterval = Empty					' ������
Dim g_bAbortedViaButton: g_bAbortedViaButton = False	' ������� ���������� � ������� ������ "��������"
Dim g_dtStart: g_dtStart = Now							' ������ �������� ����

Sub Window_OnLoad
	dim oArgs
	X_GetDialogArguments oArgs
	MainPage_xPaneCaption.innerHTML = oArgs.Caption
	setPercent 0
	On Error Resume Next
	g_sOperationID = X_ExecuteCommandAsync(oArgs.Request)
	If X_WasErrorOccured Then
		setErrorResult
		closeWindow
		Exit Sub
	End If
	On Error GoTo 0
	setState "����������..."
	updateTime	
	oArgs.Aborted = False
	document.all("MainPage_cmdCancel").Disabled = False
	setListener "checkState"
End Sub

'==========================================
' ����������� �������� ����������
' [in] n As Long - ����������
Sub setPercent(n)
	Dim oArgs ' ���������
	X_GetDialogArguments oArgs
	If oArgs.ShowProgress Then
		ProgressObject.SetState  0, 100, SafeCLng(n)
	End If
End Sub

'==========================================
' ����������� �������� ���������
' [in] s As String - ���������
Sub setState(s)
	document.all("objStatus",0).innerText = s
End Sub

'==========================================
' ����������� ������� ������� ������
' [in] s As String - ���������
Sub updateTime
	document.all("objTime",0).innerText = FormatDateTime(Now - g_dtStart, vbLongTime)
End Sub

'==========================================
' ��������� ����������� �������
' [in] s As String - ������������ �����������
Sub setListener(s)
	clearListener
	g_nInterval = window.SetInterval(s, TIMEOUT, "VBScript")
End Sub

'==========================================
' �������� ����
Sub closeWindow()
	g_sOperationID = Empty
	clearListener
	window.close
End Sub


'==========================================
' ������� ���������� �� ������ � window.ReturnValue � ���� �������
Sub setErrorResult()
	Dim oError	' As ErrorInfoClass
	Set oError = X_GetLastError
	If hasValue(oError) Then
		X_SetDialogWindowReturnValue Array(oError.LastServerError, oError.ErrNumber, oError.ErrSource, oError.ErrDescription)
	End If
End Sub


'==========================================
' ������� ����������� �������
Sub clearListener()
	If IsEmpty(g_nInterval) Then Exit Sub
	window.ClearInterval g_nInterval
	g_nInterval = Empty
End Sub


'==========================================
' �������� ������� ��������
Sub checkState()
	If IsEmpty(g_sOperationID) Then Exit Sub
	updateTime
	On Error Resume Next
	Dim oXmlResponse	' ��������������� Response
	Dim oResponse		' ����������������� Response
	Dim oArgs			' ���������
	Set oXmlResponse = X_QueryCommandResultXml(g_sOperationID)
	If X_WasErrorOccured Then
		If X_GetLastError.IsServerError OR ( 0=g_nRetryCount ) Then
			setErrorResult
			closeWindow
			Exit Sub
		End If
		g_nRetryCount = g_nRetryCount - 1
		setState "������ �����, ������� �" & ( RETRY_COUNT - g_nRetryCount )
	Else
		On Error GoTo 0
		' � ������ ������������� �����
		Set oResponse = Eval("New " & oXmlResponse.documentElement.tagName)
		oResponse.Deserialize(oXmlResponse.documentElement)

		setPercent oResponse.m_nPercentCompleted
		If "OK" = oResponse.m_sStatus Then
			' ��������� ��������������� ����� ��� ���, ��� ������ �������
			X_GetDialogArguments oArgs
			Set oArgs.Response = oXmlResponse
			setState "���������"
			g_sOperationID = Empty
			setListener "closeWindow"
		End If
	End If
End Sub


'==========================================
' �������� ���� ������� "��������"
Sub MainPage_cmdCancel_OnClick
	If IsEmpty(g_sOperationID) Then
		closeWindow
	ElseIf vbYes = MsgBox("�������� ��������� � ������ ����������. ��������?", vbYesNo + vbDefaultButton2 + vbQuestion, "����������� ������������� �������� ��������") Then
		clearListener
		g_bAbortedViaButton = True
		window.close
	End If
End Sub

'==========================================
' ��������� �������� ����
Sub Window_OnUnload
	Dim oArgs			' ���������
	document.all("MainPage_cmdCancel").Disabled = True
	clearListener
	If IsEmpty(g_sOperationID) Then
		Exit Sub
	End If
	X_GetDialogArguments oArgs
	oArgs.Aborted = True
	setState "����������..."
	On Error Resume Next
	X_TerminateCommand g_sOperationID
	If X_WasErrorOccured Then
		setErrorResult
	End If
	g_sOperationID = Empty
End Sub

'==========================================
' �������� ���� ���������
Sub Window_OnBeforeUnload
	If g_bAbortedViaButton Then Exit Sub
	If IsEmpty(g_sOperationID) Then Exit Sub
	window.event.returnValue = "�������� ��������� � ������ ����������. ��������?"
End Sub
