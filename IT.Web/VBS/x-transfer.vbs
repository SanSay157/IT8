'*******************************************************************************
' ����������:    Transfer Service
' ����������:    ���������� �-���, ����������� �������� � �������� ������
' �������������: ������ ��������� - XTransfer_ExportToFile ��� XTransfer_ImportFromFile
'*******************************************************************************

Option Explicit

' �������� ���������� ������� � ������� � �������������
const REFRESH_TIME_TRANSFER = 100	

' ������ ������ ��������� ����� ������� ��� �������� ��� �� ������ � KB
const IMPORT_FILE_CHUNK_READING_KB = 30	

' �������� HTML-��������, ������������ �������� �������� � �������
const TRANSFER_PROGRESS_PAGE = "x-transfer-progress.aspx"

' �������� HTML-�����, ���������������� ��������� ��������
const OBJECT_COMPARE_PAGE = "x-transfer-objects-compare.aspx"
' �������� HTML-�����, ���������������� ���� �������
const OBJECT_ERROR_ON_SAVE_PAGE = "x-transfer-object-dump.aspx"	
' �������� HTML-�����, ���������������� ���� ������� ��� ��������� ��������� �����������
const OBJECT_UNRESOLVED_PAGE = "x-transfer-reference-integrity.aspx"	
' �������� HTML-�����, ���������������� ���� � �������
const OBJECT_ERROR_PAGE = "x-transfer-error.aspx"

' ������� �� ������, ����� ����, ��� ��������� ��������/�������� ���������
const OK_BUTTON_VALUE = "�������"

' ������ ����� ��������� ���������, ��������� Transfer Service
const MSGBOX_TITLE_BEGIN = "Transfer Service"

' �������� ��������, ����������� ��� ������� ���������� ��������� ...
const EXPORT_COMPLETE_IMAGE = "Images/x-transfer-export-complete.gif"	' ... ��������
const IMPORT_COMPLETE_IMAGE = "Images/x-transfer-import-complete.gif"	' ... ��������

' ����������� ��������, ������������ ���������� ����� ���������
const TRANSFER_RESULT_ERROR_NOT_STARTED = 0 ' �������� �� ���� �������� ��-�� ������ �� ������� ��� �� �������
const TRANSFER_RESULT_TERMINATED = 1 ' �������� ���� �������� �������������
const TRANSFER_RESULT_FATAL_ERROR = 2 ' �������� ���������� ��-�� ������ �� ������� ��� �� �������
const TRANSFER_RESULT_SUCCESS_WITH_ERRORS = 3 ' �������� ����������� �������, � �������� ��������� ������
const TRANSFER_RESULT_SUCCESS = 4 ' �������� ����������� �������

'--------------------------------------------------------------------------------------
' �������� ��� �������� ���� � ������ ������
const WINDOW_CLOSE_INTERVAL = 2000

'--------------------------------------------------------------------------------------
' ����������� ��������, ������������ ����������� ������ ������������
const WINDOW_RESULT_CANCEL		= 0	' ������� ������ "��������" (��� ��� ������������� ������)
const WINDOW_RESULT_SKIP			= 1	' � ���� ��������� �������� ������ ������ "����������"
const WINDOW_RESULT_REPLACE		= 2	' � ���� ��������� �������� ������ ������ "������������"
const WINDOW_RESULT_RETRY			= 3	' � ���� ������ ���������� ������� ������ ������ "���������"
const WINDOW_RESULT_IGNORE		= 4	' � ���� ������ ������ "������������"
const WINDOW_RESULT_IGNOREALL = 5	' � ���� ������ ������ "������������ ���"

'--------------------------------------------------------------------------------------
' ����������� ��������, ������������ ��� ���������� �������
const DIALOG_TYPE_ERROR = 1             ' ������ (x-transfer-error.aspx)
const DIALOG_TYPE_OBJECT_DUMP = 2       ' ���� ������� (x-transfer-object-dump.aspx)
const DIALOG_TYPE_REF_INTEGRITY = 3     ' ��������� ��������� ����������� (x-transfer-reference-integrity.aspx)
const DIALOG_TYPE_OBJECTS_COMPARE = 4   ' ��������� �������� (x-transfer-objects-compare.aspx)

'--------------------------------------------------------------------------------------
dim g_TransferServiceClient ' ���������� ������ ������� ���������

'======================================================================
' ����������:  ���������� ���������� ������ ������� ���������
' ���������:   ������ ���� XTransferServiceClient
Function TransferServiceClient
	If IsEmpty(g_TransferServiceClient) Then
		Set g_TransferServiceClient = new XTransferServiceClient
	End If
	Set TransferServiceClient = g_TransferServiceClient
End Function

'======================================================================
' ����������:  ��������� ������� ��������
' ���������:   TRANSFER_RESULT_XXX
' ���������:   [in] sScenarioFileId - ������������� ����� ��������, �������� ��������� 
' 						ts:scenario-file � ���������������� ����� ���������� � ������ <ts:transfer-service>
'              [in] sScenarioName - ������������� ��������, ��������������� � ����� ��������
'              [in] sDestinationFile - ���������� ��� ������������� ���� � ����� ������ 
'              (� ������� ��������� ������). ������������� ���� �� ������� �������� � ������ 
'              �������� <ts:export-folder> � ���������������� ����� ���������� 
'              [in] bFileToClient - ���������� ���� ������ ������� (��� ��������� �� �������)
'              true: ���� ������ ����� ������������ �������
'              false: ���� ������ ����� ����������� �� �������
'              [in] oXmlParams - XML �������� ��� ��� ����� � ����������� SQL �������� (data-source) � ������� data-source.
'              ���� ��������� �� ���������, ����� ���� null ��� ""
'              ������: <param n="DepName">����� ��</param><param n="PersCount">15</param>
function XTransfer_ExportToFile(sScenarioFileId, sScenarioName, _
	sDestinationFile, bFileToClient, oXmlParams) 

	XTransfer_ExportToFile = TransferServiceClient.ExportToFile(sScenarioFileId, sScenarioName, sDestinationFile, bFileToClient, oXmlParams)
end function 

'======================================================================
' ����������:  ��������� ������� �������
' ���������:   TRANSFER_RESULT_XXX
' ���������:   [in] sScenarioFileId - ������������� ����� ��������, �������� ��������� 
' 						ts:scenario-file � ���������������� ����� ���������� � ������ <ts:transfer-service>
'              [in] sSourceFile - ���� � ����� ������ (�� �-�� ��������� ������). ������������� ���� �� ������� �������� � ������ 
'              �������� <ts:import-folder> � ���������������� ����� ���������� 
'              [in] bFileFromClient - ���������� ���� ������ � ������� (��� �� ��� �� �������)
'              true: ���� ������ ���������� �� ������� � ������ ���� ������� �� ������
'              false: ���� ������ ���������� �� �������
'              [in] oXmlParams - XML �������� ��� ��� ����� � ����������� SQL �������� (data-source) � ������� data-source.
'              ���� ��������� �� ���������, ����� ���� null ��� ""
'              ������: <param n="DepName">����� ��</param><param n="PersCount">15</param>
function XTransfer_ImportFromFile(sScenarioFileId, sSourceFile, bFileFromClient, oXmlParams) 
	XTransfer_ImportFromFile = TransferServiceClient.ImportFromFile(sScenarioFileId, sSourceFile, bFileFromClient, oXmlParams) 
end function 

'==============================================================================
' ����� ���������� ������� "TSMsgBox"
Class TSMsgBoxEventArgsClass
	Public Cancel				' As Boolean - ������� ���������� ������� ������������ �������
	
	Public prompt ' ������ ���������
	Public buttons ' ��� � ���-�� ������ (��. MsgBox)
	Public title ' ������ ����� ���������
	Public ReturnValue ' ����� ������������
		
	Public Function Self
		Set Self = Me
	End Function

End Class

'==============================================================================
' ����� ���������� ������� �������� ���� �������
Class TSOpenPageEventArgsClass
	Public Cancel				' As Boolean - ������� ���������� ������� ������������ �������
	
	Public QueryStr ' ��������� ��� �������� �������
	Public ReturnValue ' ������������ �������� - TRANSFER_RESULT_XXX
		
	Public Function Self
		Set Self = Me
	End Function

End Class
'==============================================================================
' ����� ���������� ������� ��������� ������������������ ���������
Class TSGetValueArgsClass
	Public Cancel				' As Boolean - ������� ���������� ������� ������������ �������
	
	Public DefaultValue ' �������� �� ���������
	Public ReturnValue ' ������������ ��������
		
	Public Function Self
		Set Self = Me
	End Function

End Class
'======================================================================
' ����� ������� Transfer Service
' �������:
' TSMsgBox - ������� ���������
' OpenExportPage - ��������� ������� ������ ��������
' OpenImportPage - ��������� ������� ������ �������
' OpenErrorPage - ��������� ������ ��������� �� ������
' OpenErrorOnSavePage - ��������� ������ ������ ��� ���������� �������
' OpenUnresolvedPage - ��������� ������ ������ "������ � �������������� ��������"
' OpenComparePage - ��������� ������ ��������� � �������� �������
' GetRefreshTime - ����������� �������� ���������� ������� � ������� � �������������, �� ��������� 100
' GetImportFileChunkSize - ����������� ������ ������ ��������� ����� ������� ��� �������� ��� �� ������ � KB, �� ��������� 30
' ������� ���������������� ������� �������: usrXTransfer_On

Class XTransferServiceClient

	Private m_CmdGuid ' ���� ��������
	Private m_nTimer	' ������ ���������� �������
	Private m_dtBegin	' ����� ������ ���������
	Private m_bProcessFinished ' ���������� �� ��� �������
	Private m_bImport ' ��� ������ (��� �������)

	Private m_FilePath ' ���� � ����� �� �������
	Private m_oFSO		' FileScriptingObject
	Private m_oFileStream	' ����

	Private m_oEventEngine	' As EventEngineClass - event engine

	'--------------------------------------------------------------------------------------
	' ���� ��������
	Public Property Get CmdGuid
		Set CmdGuid = m_CmdGuid
	End Property

	' ��� ������ (��� �������)
	Public Property Get bImport
		Set bImport = m_bImport
	End Property

	' ������ ���������� �������
	Public Property Get Timer
		Set Timer = m_nTimer
	End Property

	' ���������� �� ��� �������
	Public Property Get bProcessFinished
		Set bProcessFinished = m_bProcessFinished
	End Property

	' ���� � ����� �� �������
	Public Property Get FilePath
		Set FilePath = m_FilePath
	End Property

	'--------------------------------------------------------------------------------------
	' "�����������" �������
	Private Sub Class_Initialize
		Set m_oEventEngine = X_CreateEventEngine
	End Sub
	'--------------------------------------------------------------------------------------
	' ���������� �������� ������� � ����������� �����������
	Public Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub
	
	'******************************************************************************	
	'
	' ������� ������� ��������
	'
	'******************************************************************************	
	' ����������:  ������� �������� XML ����������
	' ���������:   �������� XML ����������
	' ���������:   [in] sParams - ������ ���� [<param n="ParamNameN">ParamValueN</param>]
	'              ����� ���� ""
	' ������ sParams: <param n="DepName">����� ��</param><param n="PersCount">15</param>
	Private function CreateXmlParams(sParams)
		dim oXmlDoc				' ������ XML-�������� ��� �������� ���������� �������
		Set oXmlDoc = XService.XmlGetDocument
		oXmlDoc.async = False
		oXmlDoc.loadXML "<?xml version=""1.0"" encoding=""windows-1251""?><params>" & _
			sParams & "</params>"
		Set CreateXmlParams = oXmlDoc.selectSingleNode("params")
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  �������������� ��������� ������������ ������� ����������� ��������� (�� ����� ����� ���������)
	Private Sub InitEventEngineHandlers()
		m_oEventEngine.Clear
		
			m_oEventEngine.InitHandlers _
			"TSMsgBox,OpenExportPage,OpenImportPage," & _
			"OpenErrorPage,OpenErrorOnSavePage,OpenUnresolvedPage,OpenComparePage," & _
			"GetRefreshTime,GetImportFileChunkSize,CommandComplete,GetHeaderString" _
			, "usrXTransfer_On"
	end Sub
		'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������� ��������
	' ���������:   TRANSFER_RESULT_XXX
	' ���������:   [in] sScenarioFileId - ������������� ����� �������� (ts:scenario-file)
	'              [in] sScenarioName - �������� �������� (�� ����� ��������)
	'              [in] sDestinationFile - ���� � ����� ������ (� �-� ��������� ������)
	'										���� �� ������� �������� � ������ ts:export-folder
	'              [in] bFileToClient - ���������� ���� ������ ������� (��� ��������� �� �������)
	'              [in] oXmlParams - XML �������� ��� ��� ����� � ����������� SQL �������� (data-source)
	'              ���� ��������� �� �����, ����� ���� null ��� ""
	'              ������: <param n="DepName">����� ��</param><param n="PersCount">15</param>
	Public function ExportToFile(sScenarioFileId, sScenarioName, _
		sDestinationFile, bFileToClient, oXmlParams) 
		dim oQueryStr   ' ������ QueryString
		dim CmdGuid  ' ���� �������
		dim sFilePathClient  ' ���� � ����� �� �������
		dim sFilePathServer  ' ���� � ����� �� �������
		dim oFSO		' FileScriptingObject
		dim sHeaderString	' ��������������� ���������������� ������, ������������ � ���������

		on error resume next
		ExportToFile = TRANSFER_RESULT_ERROR_NOT_STARTED

		' �������������� ��������� ������������ ������� ����������� ��������� (�� ����� ����� ���������)
		InitEventEngineHandlers

		' ���������, �������� �� ���������
		if Not hasValue(sScenarioFileId) then
			Error_MsgBox "�� ����� ������������� ����� ��������!"
			exit function
		end if

		if Not hasValue(sScenarioName) then
			Error_MsgBox "�� ������ ��� ��������!"
			exit function
		end if

		if Not hasValue(sDestinationFile) then
			Error_MsgBox "�� ������ ��� ����� ������!"
			exit function
		end if

		If Not IsObject(oXmlParams) Then
			Set oXmlParams = CreateXmlParams(toString(oXmlParams))
		end if

		' ������ ����
		if bFileToClient then
			sFilePathClient = sDestinationFile
			sFilePathServer = ""
		else
			sFilePathClient = ""
			sFilePathServer = sDestinationFile
		end if

		' ��������, ���������� �� ����
		if bFileToClient And Len(sFilePathClient)>0 then
			set oFSO = XService.CreateObject("Scripting.FileSystemObject")
			if oFSO.FileExists(sFilePathClient) then
				' ���� ����������, ������� � ������������, ��� ������?
				if vbNo = TSMsgBox("���� """ & sFilePathClient & """ ��� ����������. ������������?", vbYesNo + vbExclamation, "��������������") then
					' ������������
					exit function
				end if
				' ������� ������������ ����, ���� ���������� ������ � ���� �� �������, ����� � ������ ������ ��� ������������� �� ������� ������ ���� � ����� ����������
				oFSO.DeleteFile sFilePathClient
				if Err then
					Error_MsgBox "�� ������� ������� ���� " & sFilePathClient & vbNewLine & Err.Description 
					exit function		
				end if
			end if
			Err.Clear
		end if


		' �������� ���. ������ ��� ���������
		If m_oEventEngine.IsHandlerExists("GetHeaderString") Then
			' ������� ����������
			With New TSGetValueArgsClass
				FireEvent "GetHeaderString", .Self()
				sHeaderString = .ReturnValue
			End With
		end if
		
		' ��������� ��������
		With New ExportRequest
			.m_sScenarioName = sScenarioName
			.m_sDestinationFile = sFilePathServer
			.m_sClientFilePath = sFilePathClient
			.m_sHeaderString = sHeaderString
			.m_sScenarioFileId = sScenarioFileId
			Set .m_oXmlParams = oXmlParams
			.m_sName = "TransferServiceExportData"
			CmdGuid = X_ExecuteCommandAsync( .Self )
		End With
		
		if Err then
			Error_MsgBox "�� ������� ��������� �������" & vbNewLine & Err.Description 
			exit function		
		end if

		' ���� ������� ��������� ��������, ��������� ������ ���������
		set oQueryStr = X_GetEmptyQueryString
		' ��������� ��������� QueryString, ������������ � ���������� ����
		with oQueryStr
			.SetValue "CMDGUID",   CmdGuid
			.SetValue "FILEPATH",   sFilePathClient
		end with	

		' ��������� ������ � �������� ��������� ��������
		ExportToFile = OpenExportPage(oQueryStr)

		if Err then
			Error_MsgBox "�� ������� ������� ����" & vbNewLine & Err.Description 
		end if

		if IsEmpty(ExportToFile) then
			' ������ �������
			ExportToFile = TRANSFER_RESULT_ERROR_NOT_STARTED
		end if

	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������� ������ ��������,
	' ���� ���������� ���������� usrXTransfer_OnOpenExportPage, �������� ���
	' ���������:   [in] QueryStr - ��������� QueryString, ������������ � ���������� ����
	' ���������:   TRANSFER_RESULT_XXX
	Public function OpenExportPage(QueryStr)
		If m_oEventEngine.IsHandlerExists("OpenExportPage") Then
			' ������� ����������
			With New TSOpenPageEventArgsClass
				set .QueryStr = QueryStr
				FireEvent "OpenExportPage", .Self()
				OpenExportPage = .ReturnValue
			End With
		else
			' ������� ����
			OpenExportPage = DefaultOpenExportPage(QueryStr)
		end if
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������� ������ ��������,
	' ���������:   [in] QueryStr - ��������� QueryString, ������������ � ���������� ����
	' ���������:   TRANSFER_RESULT_XXX
	Public function DefaultOpenExportPage(QueryStr)
		DefaultOpenExportPage = X_ShowModalDialogEx(TRANSFER_PROGRESS_PAGE & "?ACTION=EXPORT&TM=" & CDbl(Now), _
			QueryStr, "dialogWidth:500px;dialogHeight:280px;status:no;center:yes;scroll:no")
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������� �������
	' ���������:   TRANSFER_RESULT_XXX
	' ���������:   [in] sScenarioFileId - ������������� ����� �������� (ts:scenario-file)
	'              [in] sSourceFile - ���� � ����� ������ (�� �-�� ��������� ������)
	'										���� �� ������� �������� � ������ ts:import-folder
	'              [in] bFileFromClient - ���������� ���� ������ � ������� (��� �� ��� �� �������)
	'              [in] oXmlParams - XML �������� ��� ��� ����� � ����������� SQL �������� (data-source)
	'              ���� ��������� �� �����, ����� ���� null ��� ""
	'              ������: <param n="DepName">����� ��</param><param n="PersCount">15</param>
	Public function ImportFromFile(sScenarioFileId, sSourceFile, bFileFromClient, oXmlParams) 
		dim oQueryStr   ' ������ QueryString
		dim CmdGuid  ' ���� �������
		dim sFilePathClient  ' ���� � ����� �� �������
		dim sFilePathServer  ' ���� � ����� �� �������

		on error resume next
		ImportFromFile = TRANSFER_RESULT_ERROR_NOT_STARTED

		' �������������� ��������� ������������ ������� ����������� ��������� (�� ����� ����� ���������)
		InitEventEngineHandlers

		' ���������, �������� �� ���������
		if Not hasValue(sScenarioFileId) then
			Error_MsgBox "�� ����� ������������� ����� ��������!"
			exit function
		end if

		if Not hasValue(sSourceFile) then
			Error_MsgBox "�� ������ ��� ����� ������!"
			exit function
		end if

		If Not IsObject(oXmlParams) Then
			Set oXmlParams = CreateXmlParams(toString(oXmlParams))
		end if

	' ������ ����
		if bFileFromClient then
			sFilePathClient = sSourceFile
			sFilePathServer = ""
		else
			sFilePathClient = ""
			sFilePathServer = sSourceFile
		end if

		' ��������� ��������
		With New ImportRequest
			.m_sSourceFile = sFilePathServer
			.m_sClientFilePath = sFilePathClient
			.m_sScenarioFileId = sScenarioFileId
			Set .m_oXmlParams = oXmlParams
			.m_sName = "TransferServiceImportData"
			CmdGuid = X_ExecuteCommandAsync( .Self )
		End With
		
		if Err then
			Error_MsgBox "�� ������� ��������� ������" & vbNewLine & Err.Description 
			exit function		
		end if
		
		' ���� ������� ��������� ��������, ��������� ������ ���������
		set oQueryStr = X_GetEmptyQueryString
		' ��������� ��������� QueryString, ������������ � ���������� ������
		with oQueryStr
			.SetValue "CMDGUID",   CmdGuid
			.SetValue "FILEPATH",   sFilePathClient
		end with	

		' ��������� ������ � �������� ��������� ��������
		ImportFromFile = OpenImportPage(oQueryStr)

		if Err then
			Error_MsgBox "�� ������� ������� ����" & vbNewLine & Err.Description 
		end if

		if IsEmpty(ImportFromFile) then
			' ������ �������
			ImportFromFile = TRANSFER_RESULT_ERROR_NOT_STARTED
		end if

	'	Error_MsgBox FinalCodeToText(ImportFromFile)
	end function
		'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������� ������ �������
	' ���� ���������� ���������� usrXTransfer_OnOpenImportPage, �������� ���
	' ���������:   [in] QueryStr - ��������� QueryString, ������������ � ���������� ����
	' ���������:   TRANSFER_RESULT_XXX
	Public function OpenImportPage(QueryStr)
		If m_oEventEngine.IsHandlerExists("OpenImportPage") Then
			' ������� ����������
			With New TSOpenPageEventArgsClass
				set .QueryStr = QueryStr
				FireEvent "OpenImportPage", .Self()
				OpenimportPage = .ReturnValue
			End With
		else
			' ������� ����
			OpenimportPage = DefaultOpenImportPage(QueryStr)
		end if
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������� ������ �������
	' ���������:   [in] QueryStr - ��������� QueryString, ������������ � ���������� ����
	' ���������:   TRANSFER_RESULT_XXX
	Public function DefaultOpenImportPage(QueryStr)
		DefaultOpenImportPage = X_ShowModalDialogEx(TRANSFER_PROGRESS_PAGE & "?ACTION=IMPORT&TM=" & CDbl(Now), _
			QueryStr, "dialogWidth:500px;dialogHeight:280px;status:no;center:yes;scroll:no")
	end function
'--------------------------------------------------------------------------------------
	' ����������:  ����������� ��������� ��������� �������� � �����
	' ���������:   ����� ������
	' ���������:   ��������� �������� 
	Private function FinalCodeToText(nCode)
		dim sText
		Select Case nCode
			Case TRANSFER_RESULT_ERROR_NOT_STARTED sText = "ERROR_NOT_STARTED"
			Case TRANSFER_RESULT_TERMINATED sText = "TERMINATED"
			Case TRANSFER_RESULT_FATAL_ERROR sText = "FATAL_ERROR"
			Case TRANSFER_RESULT_SUCCESS_WITH_ERRORS sText = "SUCCESS_WITH_ERRORS"
			Case TRANSFER_RESULT_SUCCESS sText = "SUCCESS"
			Case Else
				Error_MsgBox "����������� ���!"
		End Select
		FinalCodeToText = "���������� ����������: ��� �������� = " & sText
	end function
	'******************************************************************************	
	'
	' �������-������� ������ ��������� enum'�� ������ ��������
	'
	'******************************************************************************	
	' ����������:	����������, ��������� �� �������� � ��������� "SUSPENDED"
	' ���������:  boolean
	' ���������:	����� ��������
	Private function IsSuspended(response)
		IsSuspended = false

		if response.m_sStatus = "SUSPENDED" Then
			IsSuspended = true
		end if
	end function
	'--------------------------------------------------------------------------------------
	' ����������:	����������, �������� �� ��� ������ - "������������"
	' ���������:  boolean
	' ���������:	����� �������� TransferServiceErrorResponse
	Private function CanErrorBeIgnored(response)
		CanErrorBeIgnored = false
		if response.m_sErrorStatus = "ERROR_CAN_BE_IGNORED" then
			CanErrorBeIgnored = true
		end if
	end function
	'--------------------------------------------------------------------------------------
	' ����������:   ����������, �������� �� ��� ������ - "���������"
	' ���������:    boolean
	' ���������:    ����� �������� TransferServiceErrorResponse
	Private Function IsFatalError(response)
	    IsFatalError = False
	    If response.m_sErrorStatus = "ERROR_FATAL" Then
			IsFatalError = True
		End If
	End Function
	'--------------------------------------------------------------------------------------
	' ����������:	��������� ����� ������������ �� ��������� � ������, ���������� ����������
	' ���������: ������
	' ���������: ����� ������������
	Private function FormatUserAnswer(nResult)
		Select Case nResult
			Case WINDOW_RESULT_IGNORE
				FormatUserAnswer = "WINDOW_RESULT_IGNORE"
			Case WINDOW_RESULT_IGNOREALL
				FormatUserAnswer = "WINDOW_RESULT_IGNOREALL"
			Case WINDOW_RESULT_CANCEL
				FormatUserAnswer = "WINDOW_RESULT_CANCEL"
			Case WINDOW_RESULT_SKIP
				FormatUserAnswer = "WINDOW_RESULT_SKIP"
			Case WINDOW_RESULT_REPLACE
				FormatUserAnswer = "WINDOW_RESULT_REPLACE"
			Case WINDOW_RESULT_RETRY
				FormatUserAnswer = "WINDOW_RESULT_RETRY"
			Case Else
				Error_MsgBox "����������� ����� ������������!"
		End Select
	End Function
	
	'--------------------------------------------------------------------------------------
	' ����������:  ������ ������ ������ ������������
	' ���������:   ������ ������ ������������ TransferServiceUserAnswerRequest
	' ���������:   ����� ������������
	Private function BuildUserAnswerRequest(nResult)
		With New TransferServiceUserAnswerRequest
			.m_sUserAnswer = FormatUserAnswer(nResult)
			.m_sName = "TransferServiceUserAnswerRequest"
			Set BuildUserAnswerRequest = .Self
		End With
	End Function
	
	'******************************************************************************	
	'
	' ��������� � ��������������� ������� (�� ������������ ���������� ����������)
	'
	'******************************************************************************	
	' ����������:  �������� ����� ���������� ��������� ����� ����� ���������
	' ���������:   ������ hhh:mm:ss
	' ���������:   [in] time1 - ����� ������� ������� (������)
	'              [in] time2 - ����� ������� ������� (�����)
	' ����������:  ���� ����� ������ �����, ���������� �����. ���-�� �����
	Private function FormatTimeDiff(time1, time2)
		Dim sec
		Dim h, m, s
		sec = DateDiff("s", time1, time2)
		h = Int(sec / 3600)
		m = Int((sec Mod 3600) / 60)
		s = sec Mod 60
		FormatTimeDiff = FormatInteger(h, 2) & ":" & FormatInteger(m, 2) & ":" & FormatInteger(s, 2)
	End Function
	'--------------------------------------------------------------------------------------
	' ����������:  ����������� ����� �����, ���������� ������ ����� ����� �������
	' ���������:   ������ 000[�����]
	' ���������:   [in] n - �����
	'              [in] nNumberOfChars - ����������� ����� ���������� ��������
	Private function FormatInteger(n, nNumberOfChars)
		Dim sRes
		sRes = n
		While (Len(sRes) < nNumberOfChars)
			sRes = "0" & sRes
		Wend
		FormatInteger = sRes
	End Function
	'--------------------------------------------------------------------------------------
	' ����������:  ���������, �������� �� ��������� ������ �������� ��������
	' ���������:  boolean
	' ���������:   [in] nCode - ��������� ������ ��������
	Private function IsFinalCodeSuccesfull(nCode)
		if nCode=TRANSFER_RESULT_SUCCESS or nCode=TRANSFER_RESULT_SUCCESS_WITH_ERRORS then
			IsFinalCodeSuccesfull = true
		else
			IsFinalCodeSuccesfull = false
		end if
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  � ����������� �� ���������� � ��������� ������ �������� � �������
	'              ��������� VBS-��������� ��������
	' ���������:   VBS-��������� �������� TRANSFER_RESULT_���
	' ���������:   [in] response - ����� �������� TransferServiceFinishedResponse
	Private function FormatFinalCode(response)
		Dim nCode
		if response.m_bWasTerminated then
			nCode = TRANSFER_RESULT_TERMINATED
		elseif Not response.m_bSuccess then
			nCode = TRANSFER_RESULT_FATAL_ERROR
		elseif response.m_bWereIgnorableErrors then
			nCode = TRANSFER_RESULT_SUCCESS_WITH_ERRORS
		else
			nCode = TRANSFER_RESULT_SUCCESS
		end if
		FormatFinalCode = nCode
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ������� ��������� � ����������� � ��������� "Transfer Service - "
	Public function DefaultTSMsgBox(prompt, buttons, title)
		Dim sSeparatorTitle ' ������ ���������
		if Len(title) > 0 then
			sSeparatorTitle = " - "
		else
			sSeparatorTitle = ""
		end if
		DefaultTSMsgBox = MsgBox(prompt, buttons, MSGBOX_TITLE_BEGIN & sSeparatorTitle & title)
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ������� ��������� � ����������� � ��������� "Transfer Service - "
	' ���� ���������� ���������� usrXTransfer_OnTSMsgBox, �������� ���
	' ���������:   [in] prompt - ������ ���������
	'              [in] buttons - ��� � ���-�� ������ (��. MsgBox)
	'              [in] title - ������ ����� ���������
	' ���������:   ����� ������������ �� ���������
	Public function TSMsgBox(prompt, buttons, title)
		if not window.closed then
			If m_oEventEngine.IsHandlerExists("TSMsgBox") Then
				' ������� ����������
				With New TSMsgBoxEventArgsClass
					.prompt = prompt
					.buttons = buttons
					.title = title
					FireEvent "TSMsgBox", .Self()
					TSMsgBox = .ReturnValue
				End With
			else
				' ������� ����
				TSMsgBox = DefaultTSMsgBox(prompt, buttons, title)
			end if
		end if
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ������� ��������� �� ������ � ������ ���������� � �������
	' ���������:   [in] sMessage - ������ ���������
	Public Sub Error_MsgBox(sMessage)
		TSMsgBox sMessage, vbCritical, "������!"
	end Sub
	
	'--------------------------------------------------------------------------------------
	' ����������:  ������� ������ � �������������� � ���������� �������� (� ������ ���������� � �������)
	' ���������:   ����� ������������ �� ��������� (��. MsgBox)
	Public function AreYouSure_MsgBox()
		Dim sMsg ' ���������

		sMsg = "�� �������, ��� ������ �������� ��������� "
		if iif(IsEmpty(m_bImport), true, m_bImport) then
			sMsg = sMsg & "��������"
		else
			sMsg = sMsg & "��������"
		end if
		sMsg = sMsg & "?"

		AreYouSure_MsgBox = TSMsgBox(sMsg, vbYesNo + vbQuestion, "�������������")
	end function
	'******************************************************************************	
	'
	' ����� ������� �������� � �������
	'
	'******************************************************************************	
	' ����������:  ���������� �� ������� ��������� �������� �������� ������� �������� ��� �������
	' ���������:   
	'	[in] bImport - True - ������, False - �������
	Public Sub OnMainPageLoad(bImport)
		dim oQueryStr			' ������ QueryString

		InitEventEngineHandlers
		m_bImport = bImport
		m_bProcessFinished = false

		' ��������� ������ �� UpdateStatus
		m_nTimer = window.setInterval("g_TransferServiceClient.UpdateStatus()", GetRefreshTime())

		set m_oFileStream = nothing
		set m_oFSO = nothing

		on error resume next
		set oQueryStr = X_GetQueryString
		if Err then
			Error_MsgBox "�� ������� �������� ������ QueryString" & vbNewLine & Err.Description 
			exit Sub
		end if

		' ������� ������, ���������� ���������� ��������
		m_FilePath = oQueryStr.GetValue("FILEPATH", 0)
		m_CmdGuid = oQueryStr.GetValue("CMDGUID", 0)

		m_dtBegin = Now
	end Sub
	
	'--------------------------------------------------------------------------------------
	' ����������:  ���������� �������� ���������� ������� � ������� � �������������
	' ���� ���������� ���������� usrXTransfer_OnGetRefreshTime, �������� ���
	' ���������:   integer
	Public function GetRefreshTime()
		If m_oEventEngine.IsHandlerExists("GetRefreshTime") Then
			' ������� ����������
			With New TSGetValueArgsClass
				.DefaultValue = REFRESH_TIME_TRANSFER
				FireEvent "GetRefreshTime", .Self()
				GetRefreshTime = .ReturnValue
			End With
		else
			' �������� �� ���������
			GetRefreshTime = REFRESH_TIME_TRANSFER
		end if
	end function
	
	'--------------------------------------------------------------------------------------
	' ����������:  ���������� �������� �������� ���������
	Public Sub OnSpecialPageLoad()
		' ���������� �������� ���� ������ ��������
		X_WaitForTrue "Init2", "X_IsDocumentReady(null)"
		' ������������� ���������������� ����������� �������
		InitEventEngineHandlers
	end Sub
	
	'--------------------------------------------------------------------------------------
	' ����������:  ���������� �� �������. ��������� ��������� �������� � ��������� ������.
	' ����������:  ��������� ���������, ������������ ���������� ����������.
	Public Sub UpdateStatus
		dim response ' ����� ��������
		dim sResponseType ' ��� ������ ��������

		' ���� �����������, �� �� ������ ���� ��������
		if m_bProcessFinished then
			Error_MsgBox "����������� ��� ProcessFinished!"
		end if

		On Error Resume Next
		' ������� ����� ��������
		set response = X_QueryCommandResult(m_CmdGuid)
		if Err then
			onErrorOnClient "�� ������� �������� ������ ��������", true, Err.Description, true
		elseif isempty(response) then
			onErrorOnClient "������ ����� ��������", true, "", false
		end if

		if m_bProcessFinished then
		' �������� ���� ��������� - �������
			Exit Sub
		End If
		' ������ �� ������ ���� ������� ������
		On Error Goto 0

		' ������� ��� ����
		sResponseType = typename(response) 
		' ������� � GUI ������� ������ ��������
		SetDataToGui response

		if IsSuspended(response) Then
		' �������� ��������. ���� ������, ������; ������� ��, ��� �����, � ����������.
			Select Case sResponseType
				Case "TransferServiceErrorResponse"
					ErrorResponse response
				Case "ExportDataResponse"
					ExportDataResponse response
				Case "ImportGetFileResponse"
					ImportGetFileResponse response
				Case "ImportErrorOnSaveResponse"
					ImportErrorOnSaveResponse response
				Case "ImportUnresolvedResponse"
					ImportUnresolvedResponse response
				Case "ImportCompareObjectsResponse"
					ImportCompareObjectsResponse response
				Case Else
					Error_MsgBox "����������� ����� ��������! " & sResponseType
			End Select
		else
		' �������� �� ��������.
			Select Case sResponseType
				Case "TransferServiceFinishedResponse"
					FinishedResponse response
				Case "TransferServiceResponse"
				Case "TransferServiceErrorResponse"
				Case "ExportDataResponse"
				Case "ImportGetFileResponse"
				Case "ImportErrorOnSaveResponse"
				Case "ImportUnresolvedResponse"
				Case "ImportCompareObjectsResponse"
				Case "XResponse"
				Case Else
					Error_MsgBox "����������� ����� ��������. " & sResponseType
			End Select
		end if
	end Sub
	'--------------------------------------------------------------------------------------
	' ����������:  ������������ ��������� ������, ������������ �� �������.
	' ���������:   [in] sDescription - �������� ������
	'              [in] bServerError - ��� ��������� ������
	'                   true - �� ������� (�� ������� �������� ����� ��������, �������� ������ ����������)
	'                   false - �� ������� - �����-�� �������� � ������ ������
	'              [in] sErrorDescription - �������� ������
	'              [in] bShowMsgBox - ���������� �� ��������� �� ������
	Private Sub onErrorOnClient(sDescription, bServerError, sErrorDescription, bShowMsgBox)
		SetProcessFinished TRANSFER_RESULT_FATAL_ERROR

		if bShowMsgBox then
			Error_MsgBox sDescription & vbNewLine & sErrorDescription & vbNewLine & "�������� ����� ��������"
		end if

		' ���������� ������ � ��������� ������
		Line1.innerText = "�������� �������� ��-�� ������ �� "
		if bServerError then
			Line1.innerText = Line1.innerText + "�������"
		else
			Line1.innerText = Line1.innerText + "�������"
		end if
		
		Line2.innerText = sDescription
		Line3.innerText = ""
		Line4.innerText = ""

		TerminateTransfer false
	end Sub
	'--------------------------------------------------------------------------------------
	' ����������:  ��������� �������� ��-�� ������ �� ������� ������� ��� 
	'              �� ���������� ������������ � ������� ����
	' ���������:   [in] bUserTerminated - 
	'                   true - �������� �������������
	'                   false - ��������� ������������� ��-�� ������
	Public Sub TerminateTransfer(bUserTerminated)
		if bUserTerminated then
			' �������� ������
			document.all("XTransfer_cmdCancel").disabled = true
		end if

		' ��������� ������
		window.clearInterval m_nTimer

		if (not m_bProcessFinished) or (not bUserTerminated) then
		' ���� �������� ��� �� �����������, ��� ����������� � ������ ��������� ������
			if bUserTerminated then
			' �������� ��� �� �����������, ������������ ��������� - ��������� ���
				SetFinishedCode TRANSFER_RESULT_TERMINATED
			end if

			' ��������� ����
			CloseFile true

			' ��������� �������� �� �������
			' �������� ����� ��� ����������� � ����� �������, ���������� ��� ������
			on error resume next
			X_TerminateCommand m_CmdGuid
		end if
	end Sub
	'--------------------------------------------------------------------------------------
	' ����������:  ������������� ��� ���������� ��������
	' ���������:   [in] nCode - ��� ���������� ��������
	Private Sub SetFinishedCode(nCode)
		m_bProcessFinished = true
		X_SetDialogWindowReturnValue nCode
	end Sub
	'--------------------------------------------------------------------------------------
	' ����������:  ������������� ������ ��� ���������� ��������
	' ���������:   [in] nCode - ��� ���������� ��������
	Private Sub SetProcessFinished(nCode)
		' ��������� ������
		window.clearInterval m_nTimer

		' ������������ ��� ���������� ��������
		SetFinishedCode nCode

		' ����������� �������� �������-����
		ProgressBar.CurrentVal = ProgressBar.MaxVal

		' ������ ������� �� ������
		document.all("XTransfer_cmdCancel").value = OK_BUTTON_VALUE

		' ��������� ��������
		SetPicture IsFinalCodeSuccesfull(nCode)
	end Sub
	'--------------------------------------------------------------------------------------
	' ����������:  ������������� �������� ��� ���������� ��������
	' ���������:   [in] bSuccess - ������� �� ����������� ��������
	Private Sub SetPicture(bSuccess)
		if bSuccess then
			' ��������� �������� �� ������� ��������
			if m_bImport then
				document.all("XTransfer_ProgressPicture").src = IMPORT_COMPLETE_IMAGE
			else
				document.all("XTransfer_ProgressPicture").src = EXPORT_COMPLETE_IMAGE
			end if
		else
			' ��� ��������� �������� ������� �������� (��������� ��� �������� � ���������� �� ������)
			document.all("XTransfer_ProgressPicture").width = 0
		end if
	end Sub
	'--------------------------------------------------------------------------------------
	' ����������:  ������������� ������� ������ �������� � ������ ���������
	' ���������:   [in] response - ����� �������� 
	' ����������:  response - ����� ����������� �� TransferServiceResponse, �� ����� ���� �����
	Private Sub SetDataToGui(response)
		on error resume next

		ProgressBar.CurrentVal = response.m_nPercentCompleted
		ScenarioName.innerText = iif(len(response.m_sScenarioName) = 0, " ", response.m_sScenarioName)
		Line1.innerText = response.m_sLine1
		Line2.innerText = response.m_sLine2
		Line3.innerText = response.m_sLine3
		Line4.innerText = response.m_sLine4

		TransferTime.innerText = "��������� �������: " & FormatTimeDiff(m_dtBegin, Now)
	end Sub
	'--------------------------------------------------------------------------------------		
	' ����������:  ������� �������� ��������� ���������
	' ���������:   [in] Response - ������� �������
	Private Sub ResumeCommand(Response)
		on error resume next

		' ���� ��� �����������, �� ������ �� ������
		if not m_bProcessFinished then
			X_ResumeCommand m_CmdGuid, Response
			if Err then
			    If m_bProcessFinished Then
			        Err.Clear
			    Else
				    Error_MsgBox "ResumeCommand ������ ������" & vbNewLine & Err.Description 
				End If
			end if
		end if
	end Sub
	'--------------------------------------------------------------------------------------
	' ����������:  ������ ������ ������ ������������ TransferServiceUserAnswerRequest
	'              � ������� �������.
	' ���������:   [in] nResult - ����� ������������
	Private Sub ResumeWithUserAnswer(nResult)
		ResumeCommand BuildUserAnswerRequest(nResult)
	end Sub
	'--------------------------------------------------------------------------------------
	' ����������:  ���������� ��������� �� ������. 
	'              ��������� ������ OBJECT_ERROR_PAGE ��� ��������� ��������.
	' ���������:   [in] response - ����� �������� ���� TransferServiceErrorResponse
	Private Sub ErrorResponse(response)
		dim oQueryStr         ' ������ QueryString
		dim sMessage   ' ��������� ��� ������������

		sMessage = response.m_sErrorDescription & vbNewLine & response.m_sExceptionString

		if CanErrorBeIgnored(response) then
			' ��� ������ ����� ���������������
			' ��������� ��������� ��� ������ ���� � �������
			set oQueryStr = X_GetEmptyQueryString

			' ��������� ��������� QueryString, ������������ � ���������� ������
			with oQueryStr
				.SetValue "ERRDESCRIPTION", sMessage
			end with

			' ���������� ������ � ������� �������� ������� ������������
			ResumeWithUserAnswer OpenErrorPage(oQueryStr)
		elseif IsFatalError(response) then
			' ��� ��������� ������. ��������� ���� � ���������� �����������
			CloseFile true
			TSMsgBox sMessage & vbNewLine & "�������� ��������", vbCritical, "��������� ������"
			ResumeCommand new XRequest
		else
		    ' ��� "��������������" ������, ���������� � ����� �� �����, ��� � ������������,
		    ' �� ��������� ��� ������ ����� "��������"
		    set oQueryStr = X_GetEmptyQueryString
            ' ������ ���������
            with oQueryStr
				.SetValue "ERRDESCRIPTION", sMessage & vbNewLine & vbNewLine _
				    & "�������� �� ����� ���� ����������." & vbNewLine _ 
				    & "��������� ���������� ��. � ���-�����: " & vbNewLine _
				    & response.m_sLogFileName
				.SetValue "ALLOWEDACTIONS", "cmdCancel"
			end with
			
			OpenErrorPage(oQueryStr)
			ResumeCommand new XRequest
		end if
	end Sub
	'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������ ��������� �� ������
	' ���� ���������� ���������� usrXTransfer_OnOpenErrorPage, �������� ���
	' ���������:   [in] QueryStr - ��������� QueryString, ������������ � ���������� ����
	' ���������:   TRANSFER_RESULT_XXX
	Public function OpenErrorPage(QueryStr)
		If m_oEventEngine.IsHandlerExists("OpenErrorPage") Then
			' ������� ����������
			With New TSOpenPageEventArgsClass
				set .QueryStr = QueryStr
				FireEvent "OpenErrorPage", .Self()
				OpenErrorPage = .ReturnValue
			End With
		else
			' ������� ����
			OpenErrorPage = DefaultOpenErrorPage(QueryStr)
		end if
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������ ��������� �� ������
	' ���������:   [in] QueryStr - ��������� QueryString, ������������ � ���������� ����
	' ���������:   TRANSFER_RESULT_XXX
	Public function DefaultOpenErrorPage(QueryStr)
		DefaultOpenErrorPage = X_ShowModalDialogEx(OBJECT_ERROR_PAGE & "?TM=" & CDbl(Now), _
			QueryStr, "dialogWidth:600px;dialogHeight:320px;status:no")
	end function
'--------------------------------------------------------------------------------------
	' ����������:  ���������� ���������� ������ ��������.
	' ���������:   [in] response - ����� �������� ���� TransferServiceFinishedResponse
	Private Sub FinishedResponse(response)
		dim oEventArgs	' ��������� �������
	
		' ��������� ����
		CloseFile not response.m_bSuccess
		
		' ������������� ������ ��� ���������� ��������
		SetProcessFinished FormatFinalCode(response)

		' ���� ��������� ���������� ��������� ��������
		If m_oEventEngine.IsHandlerExists("CommandComplete") Then
			' ������� ����������
			set oEventArgs = new TSGetValueArgsClass
			oEventArgs.DefaultValue = response.m_sLogFileName
			FireEvent "CommandComplete", oEventArgs
		else
			if response.m_bCloseWindow then
				' ���� ������� ����
				if response.m_bWasTerminated then
					' ��� ������� � ���� ������� ����, ������, ��� ������� ������������� - ����� ���������
					window.close
				else
					' ������������� ��������� ���� ����� 2 ������� 
					' ����� ������������ �� ������� �� ������� ���������� :)
					window.setInterval "window.close", WINDOW_CLOSE_INTERVAL
				end if
			end if
		end if
	end Sub
	
	'=========================================================================
	' ������ � ������
	'=========================================================================
	' ����������:  ��������� ��������� ���� ������ m_FilePath � m_oFileStream
	' ���������:   bool - ������� �� ������� ����
	Private function OpenFile()
		on error resume next
		Const ForReading = 1 ' ��������� �� ������
		OpenFile = false
		Err.Clear 
		
		' ������� ������ FileSystemObject
		set m_oFSO = XService.CreateObject("Scripting.FileSystemObject")
		if Err then
			Error_MsgBox "�� �����c� ������� ������ Scripting.FileSystemObject" & vbNewLine & Err.Description 
		else
			if m_bImport then
				' ��� ������� ����� ���������� ���� �� ������ - ��������� �� ������
				set m_oFileStream = m_oFSO.OpenTextFile(m_FilePath, ForReading)
			else
				' ��� �������� ����� ������ ���� �������� �� ������ - ������� �� ������
				set m_oFileStream = m_oFSO.CreateTextFile(m_FilePath, true)
			end if

			if Err then
				Error_MsgBox "�� �����c� ������� ���� [" & m_FilePath & "]" & vbNewLine & Err.Description 
			else
				OpenFile = true
			end if
		end if
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ��������� ���� � ��� ������������� ������� ���� ��������
	' ���������:   [in] bDelete - ���� �� ������� ���� (��� ��������)
	Private Sub CloseFile(bDelete)
		on error resume next

		if not m_oFileStream is nothing then
			' ���� ���� ������
			' ���������
			m_oFileStream.Close 
			set m_oFileStream = nothing

			if bDelete and not m_bImport then
				' �������
				m_oFSO.DeleteFile m_FilePath
			end if

			' �������
			set m_oFSO = nothing
		end if
	end Sub
	'=========================================================================
	' ����������� ������� �������� ���� - ������� ���������
	'=========================================================================
	' ����������:  ���������� ������� ������ "��������". ��������� �������� � ��������� ����. 
	Public Sub OnCancelClick()

		if m_bProcessFinished then
			' ��� ����������� - ������ ���������
			window.close
		end if

		' �������� ������������ - ������� �������������
		if AreYouSure_MsgBox() = vbYes then
			' ��������
			TerminateTransfer true
			' ������� ����
			window.close
		end if

	end Sub
	'--------------------------------------------------------------------------------------
	' ����������:  ���������� �������� �������� ����. ���� �������� �� ���� ���������, 
	'              ��������� �� �� ������� � ���������� ������������ �����������.
	Public Sub OnBeforeUnload()
		Dim sMessage ' ������ ���������

		if not m_bProcessFinished then 
			' ������� ��������, � ����� ��� ������� �����������
			TerminateTransfer true

			if m_bImport then
				sMessage = "�������� �������� �������� �������������!"
			else
				sMessage = "�������� �������� �������� �������������!"
			end if
			TSMsgBox sMessage, vbCritical, ""

		end if	
	end Sub
	'******************************************************************************	
	'
	' ������� ��������
	'
	'******************************************************************************	
	' ����������:  ���������� ��������� � ����� ��������� ����� ��� ��������.
	' ���������:   [in] response - ����� �������� ���� ExportDataResponse
	Private Sub ExportDataResponse(response)
		if m_oFileStream is nothing then
			' ���� ���� ��� �� ������, ���������
			if Not OpenFile then
				' ���� �� ������� ������� (��������, ����������� ������ ���� ��� ���� �������),
				' ��������� ��������. 
				' (� �������� ����� ��������� ��� ����� ����� ������� ��������, ����� ���� �� 
				' ����������, ���� ����������� ����� ���� ��������)
				onErrorOnClient "��������� ������ ��� �������� �����", false, "", false
			end if
		end if

		on error resume next
		if Not m_oFileStream is nothing then
			' ���� ���� ������, �� ����� ����
			m_oFileStream.Write response.m_sData
			if Err then
				' ���� �� ������� ��������, ��������� ��������
				onErrorOnClient "��������� ������ ��� ������ � ���� ��������", false, Err.Description, true
			end if
		end if

		' ������� �������� � ������ �������
		ResumeCommand new XRequest
	end Sub
	'******************************************************************************	
	'
	' ������� �������
	'
	'******************************************************************************	
	' ����������:  �������� ������ ����� ������, ������������� �� ������ m_FilePath
	' ���������:   ������ ����� ������
	' ����������:  ������������ ������ ��� ������ �������� ���������� � ������ ������� (4 GB problem)
	Private function GetFileSize()
		on error resume next
		Dim f
		GetFileSize = 0
		Set f = m_oFSO.GetFile(m_FilePath)
		GetFileSize = f.Size
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ���������� ������� ���������� ��������� ����� ������ ��� �������
	' ���������:   [in] response - ������ �������� ���� ImportGetFileResponse
	Private Sub ImportGetFileResponse(response)
		dim sData
		dim bLastChunk
		dim nFileSize

		if m_oFileStream is nothing then
			if Not OpenFile then
				onErrorOnClient "��������� ������ ��� �������� �����", false, "", false
			end if
		end if

		if Not m_oFileStream is nothing then
			on error resume next
			sData = m_oFileStream.Read(GetImportFileChunkSize() * 1024)
			if Err then
				onErrorOnClient "��������� ������ ��� ������ �� ����� �������", false, Err.Description, true
			else
				on error goto 0
				nFileSize = GetFileSize
				bLastChunk = m_oFileStream.AtEndOfStream
				if bLastChunk then
					CloseFile false
				end if
			end if
		end if

		With New ImportFileDataRequest
			.m_sData = sData
			.m_bLastChunk = bLastChunk
			.m_nFileSize = nFileSize
			.m_sName = "ImportFileDataRequest"
			ResumeCommand .Self
		End With
		
		if err then						
			SetProcessFinished TRANSFER_RESULT_FATAL_ERROR
			TerminateTransfer true
			document.all("XTransfer_cmdCancel").disabled = false
		end if
	end Sub
	'--------------------------------------------------------------------------------------
	' ����������:  ������ ������ ��������� ����� ������� ��� �������� ��� �� ������ � KB, �� ��������� 30
	' ���� ���������� ���������� usrXTransfer_OnGetImportFileChunkSize, �������� ���
	' ���������:   integer
	Public function GetImportFileChunkSize()
		If m_oEventEngine.IsHandlerExists("GetImportFileChunkSize") Then
			' ������� ����������
			With New TSGetValueArgsClass
				.DefaultValue = IMPORT_FILE_CHUNK_READING_KB
				FireEvent "GetImportFileChunkSize", .Self()
				GetImportFileChunkSize = .ReturnValue
			End With
		else
			' �������� �� ���������
			GetImportFileChunkSize = IMPORT_FILE_CHUNK_READING_KB
		end if
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ���������� ������ ��� ���������� �������
	'              ��������� ���� OBJECT_ERROR_ON_SAVE_PAGE
	' ���������:   [in] response - ����� �������� ���� ImportErrorOnSaveResponse
	Private Sub ImportErrorOnSaveResponse(response)
		dim oQueryStr                       ' ������ QueryString

		' ��������� ��������� ��� ������ ���� � ������ �������	
		set oQueryStr = X_GetEmptyQueryString

		' ��������� ��������� QueryString, ������������ � ���������� ������
		with oQueryStr
			.SetValue "OBJECTXML", response.m_oXmlObject
			.SetValue "ERRDESCRIPTION", response.m_sErrDescription
		end with

	' ���������� ������ � ������� �������� ������� ������������
		ResumeWithUserAnswer OpenErrorOnSavePage(oQueryStr)
	end Sub
	'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������ ������ ��� ���������� �������
	' ���� ���������� ���������� usrXTransfer_OnOpenErrorOnSavePage, �������� ���
	' ���������:   [in] QueryStr - ��������� QueryString, ������������ � ���������� ����
	' ���������:   TRANSFER_RESULT_XXX
	Public function OpenErrorOnSavePage(QueryStr)
		If m_oEventEngine.IsHandlerExists("OpenErrorOnSavePage") Then
			' ������� ����������
			With New TSOpenPageEventArgsClass
				set .QueryStr = QueryStr
				FireEvent "OpenErrorOnSavePage", .Self()
				OpenErrorOnSavePage = .ReturnValue
			End With
		else
			' ������� ����
			OpenErrorOnSavePage = DefaultOpenErrorOnSavePage(QueryStr)
		end if
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������ ������ ��� ���������� �������
	' ���������:   [in] QueryStr - ��������� QueryString, ������������ � ���������� ����
	' ���������:   TRANSFER_RESULT_XXX
	Public function DefaultOpenErrorOnSavePage(QueryStr)
		DefaultOpenErrorOnSavePage = X_ShowModalDialogEx(OBJECT_ERROR_ON_SAVE_PAGE & "?TM=" & CDbl(Now), _
			QueryStr, "dialogWidth:600px;dialogHeight:400px;status:no")
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ���������� ������ "������ � �������������� ��������"
	'              ��������� ���� OBJECT_UNRESOLVED_PAGE
	' ���������:   [in] response - ����� �������� ���� ImportUnresolvedResponse
	Private Sub ImportUnresolvedResponse(response)
		dim oQueryStr                       ' ������ QueryString

		' ��������� ��������� ��� ������ ���� � ������ �������	
		set oQueryStr = X_GetEmptyQueryString

		' ��������� ��������� QueryString, ������������ � ���������� ������
		with oQueryStr
			.SetValue "OBJECTXML", response.m_oXmlObject
			.SetValue "PROPS", response.m_sUnreferencedProps
		end with
		
		' ���������� ������ � ������� �������� ������� ������������
		ResumeWithUserAnswer OpenUnresolvedPage(oQueryStr)
	end Sub
	'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������ ������ "������ � �������������� ��������"
	' ���� ���������� ���������� usrXTransfer_OnOpenUnresolvedPage, �������� ���
	' ���������:   [in] QueryStr - ��������� QueryString, ������������ � ���������� ����
	' ���������:   TRANSFER_RESULT_XXX
	Public function OpenUnresolvedPage(QueryStr)
		If m_oEventEngine.IsHandlerExists("OpenUnresolvedPage") Then
			' ������� ����������
			With New TSOpenPageEventArgsClass
				set .QueryStr = QueryStr
				FireEvent "OpenUnresolvedPage", .Self()
				OpenUnresolvedPage = .ReturnValue
			End With
		else
			' ������� ����
			OpenUnresolvedPage = DefaultOpenUnresolvedPage(QueryStr)
		end if
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������ ������ "������ � �������������� ��������"
	' ���������:   [in] QueryStr - ��������� QueryString, ������������ � ���������� ����
	' ���������:   TRANSFER_RESULT_XXX
	Public function DefaultOpenUnresolvedPage(QueryStr)
		DefaultOpenUnresolvedPage = X_ShowModalDialogEx(OBJECT_UNRESOLVED_PAGE & "?TM=" & CDbl(Now), _
			QueryStr, "dialogWidth:600px;dialogHeight:400px;status:no")
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ���������� ��������� � �������� ������� ��� ������� � action="ask"
	'              ��������� ���� OBJECT_COMPARE_PAGE
	' ���������:   [in] response - ����� �������� ���� ImportCompareObjectsResponse
	Private Sub ImportCompareObjectsResponse(response)
		dim oQueryStr                       ' ������ QueryString

		' ��������� ��������� ��� ������ ���� � ������ �������	
		set oQueryStr = X_GetEmptyQueryString

		' ��������� ��������� QueryString, ������������ � ���������� ������
		with oQueryStr
			.SetValue "NEWOBJECTXML", response.m_oXmlNewObject
			.SetValue "STOREDOBJECTXML", response.m_oXmlStoredObject
		end with

	' ���������� ������ � ������� �������� ������� ������������
		ResumeWithUserAnswer OpenComparePage(oQueryStr)
	end Sub
		'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������ ��������� � �������� �������
	' ���� ���������� ���������� usrXTransfer_OnOpenComparePage, �������� ���
	' ���������:   [in] QueryStr - ��������� QueryString, ������������ � ���������� ����
	' ���������:   TRANSFER_RESULT_XXX
	Public function OpenComparePage(QueryStr)
		If m_oEventEngine.IsHandlerExists("OpenComparePage") Then
			' ������� ����������
			With New TSOpenPageEventArgsClass
				set .QueryStr = QueryStr
				FireEvent "OpenComparePage", .Self()
				OpenComparePage = .ReturnValue
			End With
		else
			' ������� ����
			OpenComparePage = DefaultOpenComparePage(QueryStr)
		end if
	end function
	'--------------------------------------------------------------------------------------
	' ����������:  ��������� ������ ��������� � �������� �������
	' ����������:  ��������� ������ ��������� � �������� �������
	' ���������:   [in] QueryStr - ��������� QueryString, ������������ � ���������� ����
	' ���������:   TRANSFER_RESULT_XXX
	Public function DefaultOpenComparePage(QueryStr)
		DefaultOpenComparePage = X_ShowModalDialogEx(OBJECT_COMPARE_PAGE & "?TM=" & CDbl(Now), _
			QueryStr, "dialogWidth:600px;dialogHeight:400px;status:no")
	end function
'******************************************************************************	
	'
	' ������� ������ ������ � �������������� ����
	'
	'******************************************************************************	
	' ������� ��������� ������� � ��������� ���� �����
	' [in] oTBodyObject - HTML-������� <TBODY> ��� ������ ������� � ��������� �������
	' [in] oTBodyProps - HTML-������� <TBODY> ��� ������ ������� ������� �������
	' [out/retval] ���������� TRUE � ������ ������ � FALSE � ������ ������������� ������
	Private function FormatUnresolvedObject(oTBodyObject, oTBodyProps)
		on error resume next

		dim oQueryStr			' ������ QueryString
		dim oXmlObject			' ����������� ������
		dim oMetadata			' ���������� ��� ���� �������
		dim oProp				' �������� ������� 
		dim oTR					' HTML-������� <TR>
		dim oTD					' HTML-������� <TD>
		dim oDIV				' HTML-������� <DIV>
		dim sProps				' �������� ������� �������

		FormatUnresolvedObject = false

		' �������� ������ QueryString
		set oQueryStr = X_GetQueryString
		if Err then
			Error_MsgBox "�� ������� �������� ������ QueryString" & vbNewLine & Err.Description 
			exit function
		end if

		' �������� ��������� ��������
		set oXmlObject = oQueryStr.GetValue("OBJECTXML", nothing)
		sProps = oQueryStr.GetValue("PROPS", "")

		' ������� ����������
		Set oMetadata = X_GetTypeMD(oXmlObject.tagName)

		' ��������� �������� �������
        document.all("ObjectName").innerText = oMetadata.getAttribute("d")
        document.all("ObjectID").value = oXmlObject.getAttribute("oid")
	
				
		' ��o����� �� ���� ��������� ��������� (� ����������)
		for each oProp in oMetadata.selectNodes("ds:prop[@cp='scalar']")
			
		
			' ������� ����� ������� � �������
			set oTR = document.createElement("TR")

			' ������� ������ ������ � ������� (�������� ��������)
			set oTD = document.createElement("TD")
			oTD.innerText = oProp.getAttribute("d")
			oTR.appendChild oTD
			
			' ������� ������ ������ � ������� (�������� �������� � ����������� �������)
			set oTD = document.createElement("TD")
			
			if not (oXmlObject.selectSingleNode(oProp.getAttribute("n")) is nothing) then
			    if not oProp.selectSingleNode("i:const-value-selection") is nothing then
				    ' ���� �������� - ����������� ��������
				    if not oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]") is nothing then
					    oTD.innerText = oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]").getAttribute("n")
					    
				    end if
			    elseif not oProp.selectSingleNode("i:bits") is nothing then
				    ' ���� �������� - ����� ������� ������
				    for i = 1 to oProp.selectNodes("i:bits/i:bit").length
					    ' �������� �� ���� ��������� ���������
					    if 0 < Clng(CLng(oProp.selectSingleNode("i:bits/i:bit[" & i & "]").text) and CLng(oXmlObject.selectSingleNode(oProp.getAttribute("n")).text)) then
						    ' ��������� ������� <DIV> ��� �� ������ �������� ���� � ����� �������
						    set oDIV = document.createElement("DIV")
						    oDIV.innerText = oProp.selectSingleNode("i:bits/i:bit[" & i & "]").getAttribute("n")
						    oTD.appendChild oDIV
					    end if
				    next
				    if oTD.firstChild is nothing then
					    ' ���� �� ������ �������� ���, ������ ��������� (��� �������)
					    set oDIV = document.createElement("DIV")
					    oDIV.innerText = "-"
					    oTD.appendChild oDIV
				    end if	
				    
			    elseif "bin" = oProp.getAttribute("vt") then
				    ' ���� �������� - ���������� ��� (��������, ������ � �.�.)
				    ' ������� ������ ���-�� ����
				    oTD.innerText = "������: " & _
					    oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size") & _
					    " ����"
				    if 0 < Clng(oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size")) then 
					    
				    end if

			    else
			    
			        if oXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*") is nothing then
			            oTD.innerText = oXmlObject.selectSingleNode(oProp.getAttribute("n")).text
			        else
			            oTD.innerText = oXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*").getAttribute("oid")
			        end if			    

				    if 0 <> InStr(1, sProps, ";" & oProp.getAttribute("ot") & ";") then
					    oTR.setAttribute "bgColor", "#F69694"					
				    end if
			    end if	
			end if		
			oTR.appendChild oTD			
			

			oTBodyProps.appendChild oTR

			err.Clear 
		next
		
		FormatUnresolvedObject = true
	End function
	
	'==============================================================================================
	' ���������� ��� ������������ ������ (� ��. ���������) � ��������� ��������
	' ���������� ��� ������� � ������� ��������������� private-�������
	'
	' [in] nDialogType - ��� ������� � ������������ � ����������� DIALOG_TYPE_...
	public sub FillTableInModalDialog(nDialogType)
		select case nDialogType
			case DIALOG_TYPE_ERROR :
                if false = ShowErrorInHtml(document.all("XTransfer_ContentPlaceHolderForErrorBody_ErrDescription")) then
		            Error_MsgBox "������ ��� ������ �������� ������"
	            end if
                			
			case DIALOG_TYPE_OBJECT_DUMP :
		        if false = ErrorOnSaveObject(document.all("XTransfer_ContentPlaceHolderForErrorBody_ErrDescription"), document.all("objTbodyObject"), document.all("objTbodyProps")) then
		            Error_MsgBox "������ ��� ���������� ������� ������� �������"
	            end if
			
			case DIALOG_TYPE_OBJECTS_COMPARE :
	            if false = CompareObjects(document.all("objTbodyProps")) then
		            Error_MsgBox "������ ��� ���������� ������� ��������� ��������"
	            end if

            case DIALOG_TYPE_REF_INTEGRITY : 
	            if false = FormatUnresolvedObject(document.all("objTbodyObject"), document.all("objTbodyProps")) then
		            Error_MsgBox "������ ��� ���������� ������� ������� �������"
	            end if
	    end select
	end sub
	
	'==============================================================================================
	' ������� �������� ������ � ��������� ���� 
	' [in] oErrDescription - HTML-������� <DIV> ��� ������ �������� ������
	' [out/retval] ���������� TRUE � ������ ������ � FALSE � ������ ������������� ������
	Private function ShowErrorInHtml(oErrDescription)
		on error resume next

		dim oQueryStr			' ������ QueryString
		const MAX_ROWS = 16

		ShowErrorInHtml = false
		
		' �������� ������ QueryString
		set oQueryStr = X_GetQueryString
		if Err then
			Error_MsgBox "�� ������� �������� ������ QueryString" & vbNewLine & Err.Description 
			exit function
		end if

		' �������� ��������� ��������
		oErrDescription.innerText = oQueryStr.GetValue("ERRDESCRIPTION", "")
		oErrDescription.rows = MAX_ROWS

		ShowErrorInHtml = true
	End function
	'==============================================================================================
	' ������� ��������� ������� � �������� ������ � ��������� ���� 
	' [in] oErrDescription - HTML-������� <DIV> ��� ������ �������� ������
	' [in] oTBodyObject - HTML-������� <TBODY> ��� ������ ������� � ��������� �������
	' [in] oTBodyProps - HTML-������� <TBODY> ��� ������ ������� ������� �������
	' [out/retval] ���������� TRUE � ������ ������ � FALSE � ������ ������������� ������
	Private function ErrorOnSaveObject(oErrDescription, oTBodyObject, oTBodyProps)
		on error resume next

		dim oQueryStr			' ������ QueryString
		dim oXmlObject			' ����������� ������
		dim oMetadata			' ���������� ��� ���� �������
		dim oProp				' �������� ������� 
		dim oTR					' HTML-������� <TR>
		dim oTD					' HTML-������� <TD>
		dim oDIV				' HTML-������� <DIV>
		dim i

		const MAX_ROWS = 11
		ErrorOnSaveObject = false
		
		' �������� ������ QueryString
		set oQueryStr = X_GetQueryString
		if Err then
			Error_MsgBox "�� ������� �������� ������ QueryString" & vbNewLine & Err.Description 
			exit function
		end if

		' �������� ��������� ��������
		set oXmlObject = oQueryStr.GetValue("OBJECTXML", nothing)
		oErrDescription.innerText = oQueryStr.GetValue("ERRDESCRIPTION", "")
		oErrDescription.rows = MAX_ROWS

		' ������� ����������
		Set oMetadata = X_GetTypeMD(oXmlObject.tagName)

		' ��������� �������� �������

		' ��������
        document.all("ObjectName").innerText = oMetadata.getAttribute("d")
        document.all("ObjectID").value = oXmlObject.getAttribute("oid")
				
		' ��o����� �� ���� ��������� ��������� (� ����������)
		for each oProp in oMetadata.selectNodes("ds:prop[@cp='scalar']")
			
		
			' ������� ����� ������� � �������
			set oTR = document.createElement("TR")

			' ������� ������ ������ � ������� (�������� ��������)
			set oTD = document.createElement("TD")
			oTD.innerText = oProp.getAttribute("d")
			oTR.appendChild oTD
			
			' ������� ������ ������ � ������� (�������� �������� � ����������� �������)
			set oTD = document.createElement("TD")

			if not (oXmlObject.selectSingleNode(oProp.getAttribute("n")) is nothing) then
    			
			    if not oProp.selectSingleNode("i:const-value-selection") is nothing then
				    ' ���� �������� - ����������� ��������
				    if not oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]") is nothing then
					    oTD.innerText = oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]").getAttribute("n")
					    
				    end if
			    elseif not oProp.selectSingleNode("i:bits") is nothing then
				    ' ���� �������� - ����� ������� ������
				    for i = 1 to oProp.selectNodes("i:bits/i:bit").length
					    ' �������� �� ���� ��������� ���������
					    if 0 < Clng(CLng(oProp.selectSingleNode("i:bits/i:bit[" & i & "]").text) and CLng(oXmlObject.selectSingleNode(oProp.getAttribute("n")).text)) then
						    ' ��������� ������� <DIV> ��� �� ������ �������� ���� � ����� �������
						    set oDIV = document.createElement("DIV")
						    oDIV.innerText = oProp.selectSingleNode("i:bits/i:bit[" & i & "]").getAttribute("n")
						    oTD.appendChild oDIV
					    end if
				    next
				    if oTD.firstChild is nothing then
					    ' ���� �� ������ �������� ���, ������ ��������� (��� �������)
					    set oDIV = document.createElement("DIV")
					    oDIV.innerText = "-"
					    oTD.appendChild oDIV
				    end if	
				    
			    elseif "bin.hex" = oProp.getAttribute("vt") then
				    ' ���� �������� - ���������� ��� (��������, ������ � �.�.)
				    ' ������� ������ ���-�� ����
				    oTD.innerText = "������: " & _
					    oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size") & _
					    " ����"
				    if 0 < Clng(oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size")) then 
					    
				    end if
			    else
			        if oXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*") is nothing then
			            oTD.innerText = oXmlObject.selectSingleNode(oProp.getAttribute("n")).text
			        else
			            oTD.innerText = oXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*").getAttribute("oid")
			        end if
			        
				    
			    end if		
			end if	
			oTR.appendChild oTD			
			
            oTBodyProps.appendChild oTR			
			err.Clear 
		next
		
		ErrorOnSaveObject = true
	End function

		'==============================================================================================
	' ������� ������������ ��������� �������� � ��������� ���� ���������
	' [in] oTBody - HTML-������� <TBODY> ��� ������ ������� ���������
	' [out/retval] ���������� TRUE � ������ ������ � FALSE � ������ ������������� ������
	Private function CompareObjects(oTBody)
		on error resume next

		dim oQueryStr			' ������ QueryString
		dim oXmlObject			' ����������� ������
		dim oStoredXmlObject    ' ������ � ��
		dim oXmlDiffersAttr     ' �������, ������������, ��������� �� ��������
		dim oMetadata			' ���������� ��� ���� �������
		dim oProp				' �������� ������� 
		dim oTR					' HTML-������� <TR>
		dim oTD					' HTML-������� <TD>
		dim oDIV				' HTML-������� <DIV>
		dim i
		
		' ������� ��������� <TD> � �������� "�����" �������� <TR>
		const TD_INDEX_FIRST = 1	' ��� ������������ �������
		const TD_INDEX_SECOND = 2	' ��� ������� �� ��
		
		' ��� �������� ���� ��������, ������� ����������,
		' ��� ��� �������� �� ���������
		const DIFFERS_ATTR_NAME = "differs"
		
		' ����, ������� ����������� ������������� ��������
		const COLOR_EQUAL_PROP = "#F69694"	
		
		CompareObjects = false
		
		' �������� ������ QueryString
		set oQueryStr = X_GetQueryString
		if Err then
			Error_MsgBox "�� ������� �������� ������ QueryString" & vbNewLine & Err.Description 
			exit function
		end if

		' �������� ��������� ��������
		set oXmlObject = oQueryStr.GetValue("NEWOBJECTXML", nothing)
		set oStoredXmlObject = oQueryStr.GetValue("STOREDOBJECTXML", nothing)

		' ������� ����������
		Set oMetadata = X_GetTypeMD(oXmlObject.tagName)

		' ��������� �������� �������
        document.all("ObjectName").innerText = oMetadata.getAttribute("d")
        document.all("ObjectID").value = oXmlObject.getAttribute("oid")
        
		' ��o����� �� ���� ��������� ��������� (� ����������)
		for each oProp in oMetadata.selectNodes("ds:prop[@cp='scalar']")

			' ������� ����� ������� � �������
			set oTR = document.createElement("TR")

			' ������� ������ ������ � ������� (�������� ��������)
			set oTD = document.createElement("TD")
			oTD.innerText = oProp.getAttribute("d")
			oTR.appendChild oTD

			' ������� ������ ������ � ������� (�������� �������� � ����������� �������)
			set oTD = document.createElement("TD")
			
			if not oProp.selectSingleNode("i:const-value-selection") is nothing then
				' ���� �������� - ����������� ��������
				if not oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]") is nothing then
					oTD.innerText = oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]").getAttribute("n")
					
				end if
			elseif not oProp.selectSingleNode("i:bits") is nothing then
				' ���� �������� - ����� ������� ������
				for i = 1 to oProp.selectNodes("i:bits/i:bit").length
					' �������� �� ���� ��������� ���������
					if 0 < Clng(CLng(oProp.selectSingleNode("i:bits/i:bit[" & i & "]").text) and CLng(oXmlObject.selectSingleNode(oProp.getAttribute("n")).text)) then
						' ��������� ������� <DIV> ��� �� ������ �������� ���� � ����� �������
						set oDIV = document.createElement("DIV")
						oDIV.innerText = oProp.selectSingleNode("i:bits/i:bit[" & i & "]").getAttribute("n")
						oTD.appendChild oDIV
					end if
				next
				if oTD.firstChild is nothing then
					' ���� �� ������ �������� ���, ������ ��������� (��� �������)
					set oDIV = document.createElement("DIV")
					oDIV.innerText = "-"
					oTD.appendChild oDIV
				end if	
				
			elseif "bin.hex" = oProp.getAttribute("vt") then
				' ���� �������� - ���������� ��� (��������, ������ � �.�.)
				' ������� ������ ���-�� ����
				oTD.innerText = "������: " & _
					oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size") & _
					" ����"
				if 0 < Clng(oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size")) then 
					
				end if
			else
                ' ���������, �������� �� ������� �������� ��������� ��������� ���������
                ' (�������� �� �������� XML-��������)
		        if oXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*") is nothing then
		            ' �������� ������ ����� - ��� � ��������
		            oTD.innerText = oXmlObject.selectSingleNode(oProp.getAttribute("n")).text
		        else
		            ' �������� �������� XML-�������� - �������� �� ��� ��� �����
		            oTD.innerText = oXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*").xml
		        end if				
			end if			
			oTR.appendChild oTD

			' ������� ������ ������ � ������� (�������� �������� ������� � ��)
			set oTD = document.createElement("TD")
		
			if not oProp.selectSingleNode("i:const-value-selection") is nothing then
				' ���� �������� - ����������� ��������
				if not oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oStoredXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]") is nothing then
					oTD.innerText = oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oStoredXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]").getAttribute("n")
					
				end if
			elseif not oProp.selectSingleNode("i:bits") is nothing then
				' ���� �������� - ����� ������� ������
				for i = 1 to oProp.selectNodes("i:bits/i:bit").length
					' �������� �� ���� ��������� ���������
					if 0 < Clng(CLng(oProp.selectSingleNode("i:bits/i:bit[" & i & "]").text) and CLng(oStoredXmlObject.selectSingleNode(oProp.getAttribute("n")).text)) then
						' ��������� ������� <DIV> ��� �� ������ �������� ���� � ����� �������
						set oDIV = document.createElement("DIV")
						oDIV.innerText = oProp.selectSingleNode("i:bits/i:bit[" & i & "]").getAttribute("n")
						oTD.appendChild oDIV
					end if
				next
				if oTD.firstChild is nothing then
					' ���� �� ������ �������� ���, ������ ��������� (��� �������)
					set oDIV = document.createElement("DIV")
					oDIV.innerText = "-"
					oTD.appendChild oDIV
				end if	
				

			elseif "bin.hex" = oProp.getAttribute("vt") then
				' ���� �������� - ���������� ��� (��������, ������ � �.�.)
				' ������� ������ ���-�� ����
				oTD.innerText = "������: " & _
					oStoredXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size") & _
					" ����"
				if 0 < CLng(oStoredXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size")) then 
					
				end if
						
			else
			    ' ���������, �������� �� ������� �������� ��������� ��������� ���������
                ' (�������� �� �������� XML-��������)
                if oStoredXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*") is nothing then
                    ' �������� ������ ����� - ��� � ��������
		            oTD.innerText = oStoredXmlObject.selectSingleNode(oProp.getAttribute("n")).text
		        else
		            ' �������� �������� XML-�������� - �������� �� ��� ��� �����
		            oTD.innerText = oStoredXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*").xml
		        end if	
			end if
			oTR.appendChild oTD
				
		    ' ������� ������� ��������, ������������ �� ������������
		    ' �������� �������� � �������������� �������
			Set oXmlDiffersAttr = oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttributeNode(DIFFERS_ATTR_NAME)
			if not oXmlDiffersAttr is nothing then
			    ' ������� ����� - ��������� ��������
			    if oXmlDiffersAttr.value = "true" then
			        oTR.setAttribute "bgColor", COLOR_EQUAL_PROP
			    end if
			else
			    ' ���� ������� �� �����, �������� ���������� ����� � �������
			    if oTR.children(TD_INDEX_FIRST).innerText <> oTR.children(TD_INDEX_SECOND).innerText then
				    oTR.setAttribute "bgColor", COLOR_EQUAL_PROP
			    end if
			end if
			
			oTBody.appendChild oTR
			err.Clear
		next
		CompareObjects = true
	end function

End Class
