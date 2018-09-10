'<SCRIPT LANGUAGE="VBScript">
Option Explicit
const TIMEOUT	= 1			' ������� �������� ��� �������� � ���������� ������
const IGNORED_STRING_SIZE=5 ' ���� ������ ������ ������ ��������� ����� �� � ��� � ���
const MAX_STRING_SIZE=4000	' ������ ������� ����� ���� BLOB-�
const MIN_POST_SIZE = 1024	' ����������� ����� ��� �������� �� ������
const RETRY_COUNT = 32		' ����������� �������� ��� ������� ������� ������������� �����
const RETRY_TIMEOUT = 30	' ������� ����� ����� ����� ��� ��� ������������� ���������� ��������� �������

dim g_oObjectEditor         ' As ObjectEditor
dim g_sUploadChunkCommandName
dim g_sChunkPurgeCommandName

dim g_bChunkIsBinary
dim g_sChunkGUID
dim g_nChunkIndex
dim g_nChunkSize
dim g_vChunkData

dim g_nSize					' ������ ������������ ������
dim g_sTicket				' �����
dim g_oTotalXml				' ������������ �� ������ ����� ������
dim g_bCanClose				' ������� �������� ����
dim g_bOK					' ������� ��������� ���������� �������
dim g_dtStartTime			' ����� ������ �������� �����������
dim g_oData					' �������� ������� ������

dim g_nUpperLimit			' ����������� ����������� ������������ ����� ������������� �������
dim g_nLowerLimit			' ����������� ����������� ����������� ����� ������������� �������
dim g_dtStart				' ����� ������ ��������
dim g_nCurrentSize			' ������� ������ ����� ��� �������� �� ������
dim g_nOldCurrentSize		' ������� ������ ����� ��� �������� �� ������ (� ������� ���)
dim g_nCounter				' ������� ��������� ������� ��� ����������� ���������
dim g_rOldDiff				' ������� �����
dim g_rDiff					' ������� �����
dim g_nSizeDelta			' ������� ���� �������� ������ ��� ������� ������ �����
dim g_nOldSizeDelta			' ������� ���� �������� ������ ��� ������� ������ �����


dim g_nSend					' ������� �������

dim g_sRetryProcName		' ��� ��������� ���������� ������� ���� ����������� ���������
dim g_nInterval				' hanle �������
dim g_nRetryCounter			' �������

' HTML ��������
dim xPaneCaption
dim idMainTable
dim idLabel
dim ProgressObject
dim idChunkSize
dim idETA
dim idBandwith
dim cmdMain
dim idRetryTable
dim idTechInfo
dim cmdRetry
dim cmdCancel

'=========================================================================
' ����� ��� �������� ����� ������
class clsDataHolder
	private m_sGUID				' GUID �����
	private m_nPos				' �������
	
	public IsBinary				' ������ bin.hex?
	public Data					' ���� ������
	public NextChunk			' ��������� ���� ������
	
	' ������ �����
	public property get Size
		if IsNull(Data) then
			Size=0
		elseif IsBinary then
			Size = UBound(Data)	
		else
			Size = len(Data)	
		end if	
	end property
	
	' ������������� �����
	public property get GUID
		GUID = m_sGUID
	end property
	
	' �����������
	Private Sub class_Initialize
		m_sGUID	= LCase( XService.NewGUIDString )
		IsBinary = True
		If IsObject(g_oData) then
			' �������� 2-�� � ����������� ��������� - ��������� � ������ ������
			Set NextChunk = g_oData
		Else	
			' �������� 1-�� �������� ������
			Set NextChunk = Nothing
		End If
		Set g_oData = me
		Data = Null
		m_nPos = 0
	End Sub
	
	' ������ ������� ��� ������� �� ������
	' [in]  nMaxChunkSize - ������������ ������ ������������� �������
	public sub CreateSubChunk(ByRef vChunkData,ByRef  nChunkSize,ByRef  sChunkGUID,ByRef  nChunkIndex,ByRef  bChunkIsBinary,ByVal nMaxChunkSize)
		Dim vBinary
		Dim sText
		vBinary = null
		sText = null
		sChunkGUID = GUID
		bChunkIsBinary = IsBinary
		nChunkIndex = m_nPos
		if IsBinary then
			vChunkData = XService.ByteArrayMid(Data, m_nPos+1, nMaxChunkSize)
			nChunkSize = UBound(vChunkData)+1
		else
			vChunkData = MID(Data, m_nPos+1, nMaxChunkSize)
			nChunkSize = len(vChunkData)
		end if
		m_nPos = m_nPos + nChunkSize
		if (m_nPos-1) >= UBound(Data) then
			' ����� �� ����� ;)
			set g_oData = NextChunk
		end if	
	end sub
end class


'=========================================================================
'���������� �������� ����
sub window_OnLoad()
	Dim aDA ' dialogArguments
	InitHtmlContols()
	g_nCurrentSize = (MIN_POST_SIZE+MAX_POST_SIZE)\2 
	g_bCanClose = false
	g_bOK = false
	X_GetDialogArguments aDA
	Set g_oTotalXml = aDA(0)
	Set g_oObjectEditor = aDA(1)
	g_sUploadChunkCommandName = aDA(2)
	g_sChunkPurgeCommandName = aDA(3)
	
	cmdMain.focus 
	' �������� ��������� � ������������� ���������
	X_WaitForTrue "Init()" , "X_IsDocumentReadyEx( null, ""XProgressBar"")"
end sub


'=========================================================================
' ������������� ������ �� Html-��������
Sub InitHtmlContols()
	Set idMainTable = document.all("idMainTable")
	Set idLabel = document.all("idLabel")
	Set xPaneCaption = document.all("XMultipart_xPaneCaption")
	Set ProgressObject = document.all("ProgressObject")
	Set idChunkSize = document.all("idChunkSize")
	Set idETA = document.all("idETA")
	Set idBandwith = document.all("idBandwith")
	Set cmdMain = document.all("cmdMain")
	Set idRetryTable = document.all("idRetryTable")
	Set idTechInfo = document.all("idTechInfo")
	Set cmdRetry = document.all("cmdRetry")
	Set cmdCancel = document.all("cmdCancel")
End Sub


'=========================================================================
' �������������
Sub Init()
	dim oNodes	' ���� � �������� ����������
	dim oNode	' ����
	dim oChunk	' ����
	dim nCount	' ���-�� ������
	dim nSize	' ����� ������
	nCount = 0
	nSize = 0
	' ������� ��� �������� ��������
	set oNodes = g_oTotalXml.selectNodes("//*[(@dt:dt='bin.base64')and (''!=.)]")
	for each oNode in oNodes
		set oChunk = new clsDataHolder
		nCount = nCount + 1
		oChunk.Data = oNode.nodeTypedValue
		nSize = nSize + UBound(oChunk.Data)
		oNode.text = vbNullString
		oNode.setAttribute "chunked-chain-id", oChunk.GUID
	next
	set oNode = nothing
	set oNodes = nothing
	
	' ���� ��������� �� ��� � ��� ;)
	if X_GetApproximateXmlSize(g_oTotalXml) > MAX_POST_SIZE then
		' ������� ��������� ��������
		set oNodes = g_oTotalXml.selectNodes("//*[(@dt:dt='string')and (string-length(.)>" & IGNORED_STRING_SIZE & ")]")	' ���� ������ �������� �� � ��� � ��� ;)
		for each oNode in oNodes
			if not nothing is X_GetTypeMD(oNode.parentNode.tagName).selectSingleNode("ds:prop[@n='" & oNode.tagName & "' and number(ds:max)>" & MAX_STRING_SIZE & "]") then
				' ��� ������ - � �����
				set oChunk = new clsDataHolder
				oChunk.IsBinary = false
				nCount = nCount + 1
				oChunk.Data = oNode.nodeTypedValue
				nSize = nSize + len(oChunk.Data)
				oNode.text = vbNullString
				oNode.setAttribute "chunked-chain-id", oChunk.GUID
			end if
		next
	end if
	if nCount > 0 then 
		g_sTicket = LCase(XService.NewGUIDString)
		g_oTotalXml.documentElement.setAttribute "transaction-id", g_sTicket
	end if	
	
	'??? ��� ����� ����� XML ���� ������ ���� ������� ������� �������
	g_nSize = nSize + len(g_oTotalXml.xml)
	g_nSend = 0

	' �������������� ProgressBar (�� 0 �� 100%, ������ - 0)
	ProgressObject.SetState 0, g_nSize, 0
	idLabel.innerText = "�������� ������ �� ������..."
	XService.DoEvents()
	g_dtStartTime = Now
	
	if nCount > 0 then
		setTimeout 	"UploadStep", 0, "VBScript"
	else
		setTimeout 	"SaveStep", 0, "VBScript"
	end if		
End Sub



'=========================================================================
' ������� ������� ������� � ������� ������������ ������� ������������� �����
' [in] nSize - ���������� ������� ������
' [in] bBefore = true ���� ������� ����� ��������� ������
Sub UpdateStatisticsAndMakeDesign(nSize, bBefore)
	if bBefore then
		if 0=nSize then
			if CLng(g_nCounter) = RETRY_COUNT then
				if IsEmpty(g_rOldDiff) then
					g_nUpperLimit = MAX_POST_SIZE
					g_nLowerLimit = MIN_POST_SIZE
					
					g_nCounter = 0
					g_nOldSizeDelta = g_nSizeDelta
					g_rOldDiff = g_rDiff
					g_nOldCurrentSize = g_nCurrentSize
					g_nCurrentSize = Clng( g_nLowerLimit +  3*(g_nUpperLimit - g_nLowerLimit)/8 )
				else
					if 0=g_rDiff then g_rDiff = 1
					if 0=g_rOldDiff then g_rOldDiff = 1
					if (g_nOldSizeDelta/g_rOldDiff) < (g_nSizeDelta/g_rDiff ) then
						if g_nOldCurrentSize > g_nCurrentSize  then
							' �������� �������� � ����������� - �������� ������ �� ������������ ������ 
							g_nUpperLimit = g_nCurrentSize
						else
							' �������� �������� � ����������� - �������� ������ �� ����������� ������ 
							g_nLowerLimit = g_nCurrentSize
						end if
					else
						if g_nOldCurrentSize > g_nCurrentSize  then
							' �������� ����� � ����������� - �������� ������ �� ����������� ������ 
							g_nLowerLimit = g_nCurrentSize
						else
							' �������� ����� � ����������� - �������� ������ �� ������������ ������ 
							g_nUpperLimit = g_nCurrentSize
						end if
					end if
					g_nCounter = 0
					g_nOldSizeDelta = g_nSizeDelta
					g_rOldDiff = g_rDiff
					g_nOldCurrentSize = g_nCurrentSize
				
					g_nCurrentSize = Clng((g_nUpperLimit + g_nLowerLimit) / 2)
				end if
			end if	
		else
			g_dtStart=now
		end if
	else
		g_rDiff = CDbl(g_rDiff) + CDbl(datediff("s",g_dtStart,now))
		g_nCounter = CLng(g_nCounter) + 1
		g_nSizeDelta = CLng(g_nSizeDelta) + nSize
	end if
End Sub


'=========================================================================
' �������� ��������� ������ ��������� �� ������
Sub UploadStep
	Err.Clear
	if true=g_bCanClose then exit sub
	' ������ ������
	if not IsObject(g_oData) then exit sub
	if nothing is g_oData then exit sub
	UpdateStatisticsAndMakeDesign 0, true
	idChunkSize.innerText = g_nCurrentSize 
	XService.DoEvents 
	
	g_oData.CreateSubChunk g_vChunkData,g_nChunkSize,g_sChunkGUID,g_nChunkIndex,g_bChunkIsBinary,g_nCurrentSize
	
	UploadStep2
	
End Sub


'=========================================================================
' �������� ��������� ������ ��������� �� ������
Sub UploadStep2
	dim nSec		' ������� ������ �������� (��������)
	dim nSend		' ������� ���� ���� ��������
	dim nT0,nS0,nV,nS1,nT1, nBitrate	' ���������� ��� �������� ��������
	
	Err.Clear
	
	if true=g_bCanClose then exit sub
	
	nSend = g_nChunkSize
	
	UpdateStatisticsAndMakeDesign g_nCurrentSize, true
	

	' ��������� �� ������
	On Error Resume Next
	
	With New XChunkUploadRequest
		.m_sName = g_sUploadChunkCommandName
		.m_sTransactionID = g_sTicket
		.m_sOwnerID = g_sChunkGUID
		.m_sChunkText = iif(Not g_bChunkIsBinary, g_vChunkData,Null) 
		.m_nOrderIndex = g_nChunkIndex
		.m_aChunkData = iif(g_bChunkIsBinary, g_vChunkData,Null) 
		X_ExecuteCommand .Self
	End With
	
	' �������������� ������
	if 0=err.number then
		UpdateStatisticsAndMakeDesign nSend, false
		' ��� ������ �������, ����� �������
		' ����������� ������� �������
		g_nSend = g_nSend + nSend
			
		'T0=S0/V - ������� ���������� ������� �����
		'V=S1/T1 - ��������
		nS0=g_nSize - g_nSend
		nS1=g_nSend
		nT1=DateDiff("s", g_dtStartTime, now)
		if nT1=0 then nT1=1
		nV=nS1/nT1
		nT0=nS0/nV
		nSec = CLng(nT0)
		nBitrate = CLng(8*nV/1024)
			
		idSizeSent.innerText = CStr(g_nSend)
		idETA.innerText = FormatSeconds( nSec )
		idBandwith.innerText = nBitrate
			
		' �������� "���������"
		ProgressObject.SetState 0, g_nSize + 0, g_nSend
		XService.DoEvents
		if nothing is g_oData then
			window.setTimeout "SaveStep", TIMEOUT, "VBScript" 
		else
			window.setTimeout "UploadStep", TIMEOUT, "VBScript" 
		end if
	else
		' ��� ������� �������� �������� ������!
		DoConfirmRetry err.Description & vbNewLine & err.Source, "UploadStep2" 
	end if
End Sub

Function FormatSeconds(nSeconds)
	Dim nMinutes ' ���-�� �����
	nMinutes = CLng(Round(CDbl(nSeconds)/CDbl(60.0)))
	If nMinutes > 0 Then
		FormatSeconds = "����� " & nMinutes & " " & XService.GetUnitForm(nMinutes, Array("�����","������","�����"))
	Else
		FormatSeconds = "����� 1 ������"
	End If
End Function
	

'=========================================================================
' ���������� ����� ����� ������� �� �������
Sub SaveStep()
	dim oResultXml	' �������������� xml
	idLabel.innerText = "���������� ������ � ��..."
	cmdMain.disabled = true
	XService.DoEvents()
	
	On Error Resume Next
	X_ExecuteCommand g_oObjectEditor.Internal_GetSaveRequest(g_oTotalXml.documentElement)
	
	g_bOK = true
	ProgressObject.SetState 0, g_nSize, g_nSize+1
	XService.DoEvents
	g_oTotalXml.removeChild g_oTotalXml.documentElement
	If X_WasErrorOccured Then
		' �� ������� ��������� ������
		g_oTotalXml.appendChild X_GetLastError.LastServerError.cloneNode(true)
	ElseIf Err Then
		' ������ ��������� �� �������
		with g_oTotalXml.appendChild(g_oTotalXml.createElement("x-res")) 
			.setAttribute "c", err.number
			' ������ ���������� ����������, �.�. �������� � ������ ��������� ����������������
			.setAttribute "sys-msg", err.Source
			.setAttribute "user-msg", err.Description
		end with
	Else
		g_oTotalXml.appendChild g_oTotalXml.createElement("Done")
	End If
	
	err.Clear
	
	g_bCanClose = true
	cmdMain.disabled = True

	window.setTimeout "window.close", 300, "VBScript" ' ����� ��������� ������ ������� 100%
End Sub


'=========================================================================
' ��� ������� �� ESC ������� ����
sub Document_OnKeyPress
	if VK_ESC = window.event.keyCode then DoCloseWindow()
end sub

'=========================================================================
' �������� ��������
Sub window_OnUnload
	set g_oData=Nothing
	On Error Resume Next	' ��� ������ �����
	clearInterval g_nInterval
	g_bCanClose = true
	X_SetDialogWindowReturnValue g_bOK
	if true = g_bOK then exit sub
	if IsEmpty(g_sTicket) then exit sub
	idLabel.innerText = "�������� ����������� ������..."
	
	With New XChunkPurgeRequest
		.m_sName = g_sChunkPurgeCommandName
		.m_sTransactionID = g_sTicket
		X_ExecuteCommand .Self 
	End With
	err.Clear ' ������ �� ������
End Sub

'=========================================================================
' �������������� ���������� ������ �� ������ �������
Sub Window_OnBeforeUnload
	if true=g_bCanClose then exit sub
	window.event.returnValue = "�������� �������� ������ �� ������?"
End Sub

'=========================================================================
' �������� ����
Sub DoCloseWindow
    If Not g_bCanClose Then
	    g_bCanClose = (true=confirm("�������� �������� ������ �� ������?"))
	End If
	If g_bCanClose Then
		cmdMain.disabled = True
		window.close
	End If
End Sub

'=========================================================================
'��������� �������
Sub TimerProc
	g_nRetryCounter = g_nRetryCounter - 1
	UpdateButtons
	if g_nRetryCounter = 0 then
		DoSetRetryResult true
	end if
End Sub

'=========================================================================
'���������� ������
Sub UpdateButtons
	if g_nRetryCounter > 0 then
		cmdRetry.innerHTML = "<b>��������� ������� (" & g_nRetryCounter & ")</b>"
	else
		cmdRetry.innerText = "��������� �������"
	end if
End Sub


'=========================================================================
'����� ��������� �� ������ � ������������ �������� �������
' [in] sTechInfo		- ����������� ����������
' [in] sRetryProcName	- ��� ��������� ������� ���� ����������� ���������
Sub DoConfirmRetry( sTechInfo, sRetryProcName)
	err.Clear
	g_sRetryProcName = sRetryProcName
	idTechInfo.value = sTechInfo 
	g_nRetryCounter = RETRY_TIMEOUT
	UpdateButtons
	idMainTable.style.display = "none"
	idRetryTable.style.display = "block"
	cmdRetry.focus
	g_bCanClose = true
	g_nInterval = setInterval( "TimerProc",1000,"VBScript" )
End Sub

'=========================================================================
'��������� �������� �������
' [in] bResult	= true ���� ��������� ������, ����� false
Sub DoSetRetryResult(bResult)
	clearInterval g_nInterval
	if bResult then
		g_bCanClose = false
		idRetryTable.style.display = "none"		
		idMainTable.style.display = "block"
		cmdMain.focus
		setTimeout g_sRetryProcName, TIMEOUT, "VBScript" 
	else
		window.close
	end if
End Sub

'=========================================================================
'��������� ������ �� ���������
sub Document_OnClick
	clearInterval g_nInterval
	g_nRetryCounter=0
	UpdateButtons
end sub
'</SCRIPT>
