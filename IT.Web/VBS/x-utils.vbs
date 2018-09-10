'<SCRIPT LANGUAGE="VBScript">
'===============================================================================
'@@!!FILE_x-utils
'<GROUP !!SYMREF_VBS>
'<TITLE x-utils - ����� ������� Web-������� XFW .NET >
':����������:
'	����� ����� �������, �������� � �������, ������������ � ���������� 
'	Web-������� XFW .NET.
':��. �����:
'	<LINK !!FILE_x-vbs, x-vbs - ����� ����������� �������\, "����������" VBScript />
'===============================================================================
'@@!!CONSTANTS_x-utils
'<GROUP !!FILE_x-utils><TITLE ���������>
'@@!!FUNCTIONS_x-utils
'<GROUP !!FILE_x-utils><TITLE ������� � ���������>
'@@!!CLASSES_x-utils
'<GROUP !!FILE_x-utils><TITLE ������>

Option Explicit

Dim x_nWaitForTrueID		' ���������� � ������ ������ �������� �������������, ������������ �������� X_WaitForTrue	
Dim x_nErrNumber			' ����� ������
Dim x_sErrSrc				' �������� ������
Dim x_sErrDesc				' �������� ������
Dim x_oMD					' ���������� �� �������...
Dim x_bMD					' � ������� �� �������...
Dim x_oLastServerError		' As ErrorInfoClass - �������� ��������� ������ ��� ������ ��������� ��������
Dim x_oRightsCache			' As ObjectRightsCacheClass - ��� ����. ������ ������ �������������� ������ ����� �������-�������� X_RightsCache!
Dim x_oConfig				' As ConfigClass - ���������� ������� ��� ������� � ����� ������������. ������ ������ �������������� ������ ����� �������-�������� X_Config!

Set x_oLastServerError = Nothing

'==============================================================================
' ��������� - �������� ��������� - ���� ���������� � ������������� 
' �������� DIV, ������������� ��� ��������� ��� userData
const META_DATA_STORE = "XMetaDataStore"
const META_DATA_DEBUG_ATTR = "is-debug-mode"
const XCONFIG_STORE = "XConfigStore"	' ������������ ��������� - ���� xconfig'a


'==============================================================================
'@@ACCESS_RIGHT_nnnn
'<GROUP !!CONSTANTS_x-utils><TITLE ACCESS_RIGHT_nnnn>
':����������:	��������� ����� �������� ��� ���������.

'@@ACCESS_RIGHT_CREATE
'<GROUP ACCESS_RIGHT_nnnn>
':����������:	�������� �������� ������� (Create).
const ACCESS_RIGHT_CREATE	= "Create"

'@@ACCESS_RIGHT_CHANGE
'<GROUP ACCESS_RIGHT_nnnn>
':����������:	�������� ����������� ������� (Edit).
const ACCESS_RIGHT_CHANGE	= "Edit"

'@@ACCESS_RIGHT_DELETE
'<GROUP ACCESS_RIGHT_nnnn>
':����������:	�������� �������� ������� (Delete).
const ACCESS_RIGHT_DELETE	= "Delete"

'==============================================================================
'@@CACHE_BEHAVIOR_nnnn
'<GROUP !!CONSTANTS_x-utils><TITLE CACHE_BEHAVIOR_nnnn>
':����������:	��������� ����� �������������� � �����.

'@@CACHE_BEHAVIOR_NOT_USE
'<GROUP CACHE_BEHAVIOR_nnnn>
':����������:	��� �� ������������.
const CACHE_BEHAVIOR_NOT_USE	= 0

'@@CACHE_BEHAVIOR_USE
'<GROUP CACHE_BEHAVIOR_nnnn>
':����������:	��� ������������.
const CACHE_BEHAVIOR_USE		= 1

'@@CACHE_BEHAVIOR_ONLY_WRITE
'<GROUP CACHE_BEHAVIOR_nnnn>
':����������:	���������� ����������� ���������� ���� ���������� � �������.
const CACHE_BEHAVIOR_ONLY_WRITE	= 2

'===============================================================================
'@@X_CreateGuid
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CreateGuid>
':����������:	
'	���������� ���������� GUID � ���������� ��� ��������� �������������, 
'	����������� � ������ �������.
':���������:
'	Function X_CreateGuid() [As String]
Function X_CreateGuid()
	X_CreateGuid = LCase(XService.NewGuidString)
End Function

' ������� X_CreateGuid(), ����������� ��� ������������� � ������ �����
' �� �������! � ����� ���� �� ������������!
Function CreateGuid()
	CreateGuid = LCase(XService.NewGuidString)
End Function

'===============================================================================
'@@ErrorInfoClass
'<GROUP !!CLASSES_x-utils><TITLE ErrorInfoClass>
':����������:	
'	����� ������������� �������� ������, ������������ � �������� ������ ���
'	���������� �������� ������� ����������.
'
'@@!!MEMBERTYPE_Methods_ErrorInfoClass
'<GROUP ErrorInfoClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_ErrorInfoClass
'<GROUP ErrorInfoClass><TITLE ��������>
Class ErrorInfoClass

	'------------------------------------------------------------------------------
	'@@ErrorInfoClass.LastServerError
	'<GROUP !!MEMBERTYPE_Properties_ErrorInfoClass><TITLE LastServerError>
	':����������:	
	'	�������� CROC.XClientService.LastServerError. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public LastServerError [As IXMLDOMElement]
	Public LastServerError
	
	'------------------------------------------------------------------------------
	'@@ErrorInfoClass.ErrDescription
	'<GROUP !!MEMBERTYPE_Properties_ErrorInfoClass><TITLE ErrDescription>
	':����������:	
	'	�������� ������ (Err.Description). 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ErrDescription [As String]
	Public ErrDescription
	
	'------------------------------------------------------------------------------
	'@@ErrorInfoClass.ErrSource
	'<GROUP !!MEMBERTYPE_Properties_ErrorInfoClass><TITLE ErrSource>
	':����������:	
	'	�������� ������ (Err.Source). 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ErrSource [As String]
	Public ErrSource
	
	'------------------------------------------------------------------------------
	'@@ErrorInfoClass.ErrNumber
	'<GROUP !!MEMBERTYPE_Properties_ErrorInfoClass><TITLE ErrNumber>
	':����������:	
	'	����� ������ (Err.Number). 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ErrNumber [As Int]
	Public ErrNumber

	'---------------------------------------------------------------------------
	' ������������� ����������
	Private Sub Class_Initialize
		Set LastServerError = Nothing
		ErrNumber = 0
	End Sub
	
	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.IsSecurityException
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE IsSecurityException>
	':����������:
	'   ���������� True, ���� ����������� ����������� ������ ���� ��������� ������ 
	'   <LINK Croc.XmlFramework.Public.XSecurityException, XSecurityException />, 
	'   ��������������� �������� ����������.
	':��. �����:	ErrorInfoClass.IsBusinessLogicException, 
	'				ErrorInfoClass.IsObjectNotFoundException, 
	'				ErrorInfoClass.IsOutdatedTimestampException, 
	'				ErrorInfoClass.IsServerError
	':���������:	Public Function IsSecurityException [As Boolean]
	Public Function IsSecurityException
		IsSecurityException = X_IsSecurityException(LastServerError)
	End Function 

	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.IsBusinessLogicException
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE IsBusinessLogicException>
	':����������:	
	'   ���������� True, ���� ����������� ����������� ������ ���� ��������� ������
	'   <LINK Croc.XmlFramework.Public.XBusinessLogicException, XBusinessLogicException />, 
	'   ��������������� �������� ����������.
	':��. �����:	ErrorInfoClass.IsSecurityException, 
	'				ErrorInfoClass.IsObjectNotFoundException, 
	'				ErrorInfoClass.IsOutdatedTimestampException, 
	'				ErrorInfoClass.IsServerError
	':���������:	Public Function IsBusinessLogicException [As Boolean]
	Public Function IsBusinessLogicException
		IsBusinessLogicException = X_IsBusinessLogicException(LastServerError)
	End Function 

	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.IsObjectNotFoundException
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE IsObjectNotFoundException>
	':����������:	
	'   ���������� True, ���� ����������� ����������� ������ ���� ��������� ������
	'	<LINK Croc.XmlFramework.Data.XObjectNotFoundException, XObjectNotFoundException />, 
	'   ��������������� �������� ����������.
	':��. �����:	ErrorInfoClass.IsSecurityException, 
	'				ErrorInfoClass.IsBusinessLogicException, 
	'				ErrorInfoClass.IsOutdatedTimestampException, 
	'				ErrorInfoClass.IsServerError	
	':���������:	Public Function IsObjectNotFoundException [As Boolean]
	Public Function IsObjectNotFoundException
		IsObjectNotFoundException = X_IsObjectNotFoundException(LastServerError)
	End Function 

	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.IsOutdatedTimestampException
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE IsOutdatedTimestampException>
	':����������:	
	'   ���������� True, ���� ����������� ����������� ������ ���� ��������� ������
	'	<LINK Croc.XmlFramework.Data.XOutdatedTimestampException, XOutdatedTimestampException />, 
	'   ��������������� �������� ����������.
	':��. �����:	ErrorInfoClass.IsSecurityException, 
	'				ErrorInfoClass.IsBusinessLogicException, 
	'				ErrorInfoClass.IsObjectNotFoundException, 
	'				ErrorInfoClass.IsServerError
	':���������:	Public Function IsSecurityException [As Boolean]
	Public Function IsOutdatedTimestampException
		IsOutdatedTimestampException = X_IsOutdatedTimestampException(LastServerError)
	End Function
	
	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.IsServerError
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE IsServerError>
	':����������:	
	'   ���������� True, ���� ����������� ����������� ������ ���� ����������, 
	'   ��������������� �������� ����������.
	':��. �����:	ErrorInfoClass.IsSecurityException, 
	'				ErrorInfoClass.IsBusinessLogicException, 
	'				ErrorInfoClass.IsObjectNotFoundException, 
	'				ErrorInfoClass.IsOutdatedTimestampException
	':���������:	Public Function IsServerError [As Boolean]
	Public Function IsServerError
		IsServerError = Not LastServerError Is Nothing
	End Function
	
	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.RaiseError
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE RaiseError>
	':����������:	� ������������ � �������, ������������ �����������, 
	'				���������� ������ ������� ���������� VBScript.
	':��. �����:	ErrorInfoClass.ShowDebugDialog
	':���������:	Public Sub RaiseError
	Public Sub RaiseError
		Err.Raise ErrNumber, ErrSource, ErrDescription
	End Sub
	
	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.ShowDebugDialog
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE ShowDebugDialog>
	':����������:	���������� ������ ��������� �� ������.
	':��. �����:	ErrorInfoClass.Show
	':���������:	Public Sub ShowDebugDialog
	Public Sub ShowDebugDialog
		Dim oDlg	' As CROC.XErrorDialog
		If IsServerError Then
			Set oDlg = XService.CreateErrorDialog("", ERRDLG_ICON_ERROR, LastServerError.getAttribute("user-msg"), LastServerError.getAttribute("sys-msg"))
			oDlg.ShowModal
		Else
			Set oDlg = XService.CreateErrorDialog("", ERRDLG_ICON_ERROR, ErrDescription)
			oDlg.ShowModal
		End If
	End Sub
	
	'---------------------------------------------------------------------------
	'@@ErrorInfoClass.Show
	'<GROUP !!MEMBERTYPE_Methods_ErrorInfoClass><TITLE Show>
	':����������:	
	'	���������� ������ � ���������� �� ������. ��� ������� � ����� ��������� 
	'	� ������� ������������ � ����������� �� ���� ������ (���� ����������, 
	'	���������������� �������� ����������).
	':����������:	
	'	����������� ���� ������� �� ���� ������:
	'	- <LINK Croc.XmlFramework.Public.XSecurityException, XSecurityException /> - �������������� � ������������� ������� "� ������� ��������";
	'	- <LINK Croc.XmlFramework.Public.XBusinessLogicException, XBusinessLogicException /> - ���������, ����� ��������� ���������� � ����������;
	'	- <LINK Croc.XmlFramework.Data.XObjectNotFoundException, XObjectNotFoundException /> - �������������� � ������������� ������� "������ �� ������";
	'	- <LINK Croc.XmlFramework.Data.XOutdatedTimestampException, XOutdatedTimestampException /> - �������������� � ��������� � ���, ��� ������ ����������� ������� ��������, ������ �������� ��������� ����� (������ ���� ����������).
	'   �� ���� ��������� ������� ����������� ������ � �������.
	':��. �����:	ErrorInfoClass.ShowDebugDialog
	':���������:	Public Sub Show
	Public Sub Show
		Dim sMsg
		Dim oDlg	' As CROC.XErrorDialog
		
		If IsSecurityException Then
			sMsg = "" & LastServerError.getAttribute("user-msg")
			If Len(sMsg) = 0 Then
				sMsg = "� ������� ��������"
			End If
			Set oDlg = XService.CreateErrorDialog("", ERRDLG_ICON_SECURITY, sMsg)
			oDlg.ShowModal
		ElseIf IsObjectNotFoundException Then
			alert "������ �� ������, �������� �� ��� ����� ������ �������������"
		ElseIf IsOutdatedTimestampException Then
			sMsg = "������ ������������ ������� ������, ������� �� ��������� ���������. ��� ���������� ������� �������� ��� ����������, � ����� ��������� ��� ���������."
			Set oDlg = XService.CreateErrorDialog("", ERRDLG_ICON_WARNING, sMsg, LastServerError.getAttribute("sys-msg"))
			oDlg.ShowModal
		ElseIf IsBusinessLogicException Then
			Set oDlg = XService.CreateErrorDialog("", ERRDLG_ICON_INFORMATION, LastServerError.getAttribute("user-msg"), LastServerError.getAttribute("sys-msg"))
			oDlg.ShowModal
		Else
			ShowDebugDialog
		End If
	End Sub
End Class

'===============================================================================
'@@X_SetLastServerError
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SetLastServerError>
':����������:
'	��������� ������������� �������� ��������� ������.
':���������:
'	oLastServerError - 
'       [in] ���� <b>x-res</b>, ������������ CROC.XClientService.LastServerError.
'	nErrNumber - 
'       [in] ����� ������.
'	sErrSource - 
'       [in] �������� ������.
'	sErrDescription - 
'       [in] �������� ������.
':���������:
'	Sub X_SetLastServerError(
'       oLastServerError [As IXMLDOMElement],
'       nErrNumber [As Int],
'       sErrSource [As String],
'       sErrDescription [As String]
'   )
Sub X_SetLastServerError(oLastServerError, nErrNumber, sErrSource, sErrDescription)
	If Not IsObject(oLastServerError) Then Err.Raise -1, "X_SetLastServerError", "oLastServerError ������ ���� �������� XMLDOMElement"
	Set x_oLastServerError = New ErrorInfoClass
	Set x_oLastServerError.LastServerError = oLastServerError
	x_oLastServerError.ErrNumber = nErrNumber
	x_oLastServerError.ErrSource = sErrSource
	x_oLastServerError.ErrDescription = sErrDescription
End Sub


'===============================================================================
'@@X_ClearLastServerError
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ClearLastServerError>
':����������:
'	��������� ���������� �������� ������ ��������� ��������� ��������.
':���������:
'	Sub X_ClearLastServerError
Sub X_ClearLastServerError
	Set x_oLastServerError = Nothing
End Sub


'===============================================================================
'@@X_GetLastError
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetLastError>
':����������:
'	������� ���������� �������� ��������� ������, ������������� ����� � �������
'   ��������� <LINK X_SetLastServerError, X_SetLastServerError />.
':���������:
'	���� <b>x-res</b>, ������������ CROC.XClientService.LastServerError.
':���������:
'	Function X_GetLastError () [As IXMLDOMElement]
Function X_GetLastError()
	Set X_GetLastError = x_oLastServerError 
End Function


'===============================================================================
'@@X_WasErrorOccured
'<GROUP !!FUNCTIONS_x-utils><TITLE X_WasErrorOccured>
':����������:
'	������� ���������� ������� ����, ��� ���� ����������� �������� ��������� ������ 
'   (����� ��������� <LINK X_SetLastServerError, X_SetLastServerError />).
':���������:
'	True - ���� ����������� �������� ��������� ������, False - � ��������� ������.
':���������:
'	Function X_WasErrorOccured [As Boolean]
Function X_WasErrorOccured
	X_WasErrorOccured = Not x_oLastServerError Is Nothing
End Function


'===============================================================================
'@@X_GetAttributeDef
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetAttributeDef>
':����������:
'	������� ���������� �������� �������� ��������.
':���������:
'	oDOMElement - 
'       [in] ������� XML-���������, � �������� ������������� �������� ��������.
'	sAttrName - 
'       [in] ��� ��������.
'	vDefVal - 
'       [in] �������� �������� �� ���������.
':���������:
'	Function X_GetAttributeDef (
'       oDOMElement [As IXMLDOMElement],
'       sAttrName [As String],
'       vDefVal [As Variant]
'   ) [As Variant]
Function X_GetAttributeDef( oDOMElement, sAttrName, vDefVal)
	Dim vVal	' �������� ��������
	vVal = oDOMElement.getAttribute(sAttrName)
	If IsNull( vVal) Then
		X_GetAttributeDef = vDefVal
	Else
		X_GetAttributeDef = vVal
	End If
End Function


'===============================================================================
'@@X_GetChildValueDef
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetChildValueDef>
':����������:
'	������� ���������� �������� ������������ ���� ��������.
':���������:
'	oDOMElement - 
'       [in] ������� XML-���������, � �������� ������������� �������� ������������ 
'       ���� ��������.
'	sChildName - 
'       [in] ��� ������������ ���� ��������.
'	vDefVal - 
'       [in] �������� �������� �� ���������.
':���������:
'	Function X_GetChildValueDef (
'       oDOMElement [As IXMLDOMElement],
'       sChildName [As String],
'       vDefVal [As Variant]
'   ) [As Variant]
Function X_GetChildValueDef( oDOMElement, sChildName, vDefVal)
	Dim oChild  '����������� ����
	Set oChild = oDOMElement.selectSingleNode(sChildName)
	If oChild Is Nothing Then
		X_GetChildValueDef = vDefVal
	Else
		X_GetChildValueDef = oChild.nodeTypedValue
	End If
End Function


'===============================================================================
'@@X_DisableWaitForTrue
'<GROUP !!FUNCTIONS_x-utils><TITLE X_DisableWaitForTrue>
':����������:
'	��������� ��������� ��������� ��������� <LINK X_WaitForTrue, X_WaitForTrue /> 
'   ��� �������� ��������.
':���������:
'	Sub X_DisableWaitForTrue()
Sub X_DisableWaitForTrue() 
	x_nWaitForTrueID = Empty
End Sub

'===============================================================================
'@@X_WaitForTrue
'<GROUP !!FUNCTIONS_x-utils><TITLE X_WaitForTrue>
':����������:
'	��������� �������� ��������� � ������, �������� � ��������� <b><i>sProcName</b></i> 
'   ��� ���������� ���������, ��������� � ��������� <b><i>sExpr</b></i>.
':���������:
'	sProcName - 
'       [in] ��� ���������� ���������.
'	sExpr - 
'       [in] ������ � ���������� ���������� �� VBScript.
':���������:
'	Sub X_WaitForTrue( sProcName [As String], sExpr [As String] )
Sub X_WaitForTrue( sProcName, sExpr)
	' ��� ������ �������
	if IsEmpty( x_nWaitForTrueID) Then 
		'...���������� ���������� ID...
		Randomize
		x_nWaitForTrueID = CLng( Rnd() * 100000)	' ��������� ��������� ����� �� 0 �� 100000
		'...������� ����� ������� ��� ��������
		window.attachEvent "onunload" , GetRef("X_DisableWaitForTrue")
	End if
	' � ������� ���������� ����������
	window.setTimeout _
		"X_WaitForTrueInternal """ & _
		X_VBEncode(sProcName)  & _
		""", """ & _
		X_VBEncode(sExpr) & """," & x_nWaitForTrueID , _
		0, "VBScript"
End Sub


'===============================================================================
':����������:
'	��������� �������� ��������� � ������, �������� � ��������� <b><i>sProcName</b></i> 
'   ��� ���������� ���������, ��������� � ��������� <b><i>sExpr</b></i>, � ����������
'   �������� ID � ����������.
':���������:
'	sProcName - 
'       [in] ��� ���������� ���������.
'	sExpr - 
'       [in] ������ � ���������� ���������� �� VBScript.
'	nCurrentID - 
'       [in] ���� ��� ���������.
':���������:
'	Sub X_WaitForTrueInternal (
'       sProcName [As String], 
'       sExpr [As String],
'       nCurrentID [As Int]
'    )
Sub X_WaitForTrueInternal( sProcName, sExpr, nCurrentID)
	' ���� ������� ID � ���������� �������� - ������ �������� ���� ����������� � ��������� ������ �� ����
	if IsEmpty(nCurrentID) or IsEmpty(x_nWaitForTrueID) or (nCurrentID <> x_nWaitForTrueID) Then 
		Exit Sub
	End if	
	const WAIT_TIMEOUT = 200
	Dim bRes		' ��������� ���������� ��������� sExpr
	
	bRes = (True = Eval( sExpr))
	if X_ErrOccured() Then
		X_ErrReport()
		Exit Sub
	End if	
	if bRes Then
		ExecuteGlobal sProcName 
	Else
		window.setTimeout _
			"X_WaitForTrueInternal """ & _
			X_VBEncode(sProcName)  & _
			""", """ & _
			X_VBEncode(sExpr) & """," & nCurrentID , _
			WAIT_TIMEOUT, "VBScript"
	End if
End Sub


'===============================================================================
'@@X_VBEncode
'<GROUP !!FUNCTIONS_x-utils><TITLE X_VBEncode>
':����������:
'	������� ������������ ������ � ������, �������������� ��������������� VBS.
':���������:
'	sIN - 
'       [in] ������� ������.
':���������:
'	Function X_VBEncode ( sIN [As String] ) [As String]
Function X_VBEncode(sIN)
	X_VBEncode = Replace(Replace( Replace( Replace ( sIN, """", """"""), vbNewLine, """  & vbNewLine & """), vbCr, """  & vbCr & """), vbLf, """  & vbLf & """)
End Function


'===============================================================================
'@@X_ErrOccured
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ErrOccured>
':����������:
'	������� ��������� ��������� ������� Err. 
':���������:
'	���� Err.Number �� ����� 0, �� ���������� True � ��������� ������ �� ������
'   � ���������� ����������.<P/>
'   ���� Err.Number ����� 0, �� ���������� Empty.
':���������:
'	Function X_ErrOccured () [As Variant]
Function X_ErrOccured()
	If Err Then
		x_nErrNumber = Err.Number
		x_sErrSrc = Err.Source
		x_sErrDesc = Err.Description
		X_ErrOccured = true
	End if
End Function


'===============================================================================
'@@X_ErrReRaise
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ErrReRaise>
':����������:
'	��������� ���������� ������ �� ������ ������ �� ������, ����������� � 
'   ���������� ���������� ������� ������� <LINK X_ErrOccured, X_ErrOccured />, � 
'   ����������� � ��� �������� ������ � ���������.
':���������:
'	sDesc - 
'       [in] �������� ������ (����� ���� Null ��� ������ �������).
'	sSrc - 
'       [in] ��� ��������� (����� ���� Null ��� ������ �������).
':����������:	
'	<b><i>��������!</b></i> ������������� ������ ������� ��� ���������������� ������ 
'   ������� <LINK X_ErrOccured, X_ErrOccured />, ��������� True, �������� �
'   ��������������� �����������! ����� ������� ������ ������� � ����������� ������
'   ���������� ������� On Error Goto 0.<P/>
'   <b><i>������ �������������:</b></i><P/>
'	if X_ErrOccur�d() Then <P/>
'		On Error Goto 0 <P/>
'		X_ErrReRaise "�����-�� ������", "��� ������ �������" <P/>
'	End if
':���������:
'	Sub X_ErrReRaise (
'       sDesc [As String], 
'       sSrc [As String]
'    )
Sub X_ErrReRaise( sDesc, sSrc)
	Err.Raise _
		x_nErrNumber, _
		iif( Len( sSrc) > 0, sSrc & vbNewLine & x_sErrSrc, x_sErrSrc), _
		iif( Len( sDesc) > 0, sDesc & vbNewLine & x_sErrDesc, x_sErrDesc)
End Sub


'===============================================================================
'@@X_IsDebugMode
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsDebugMode>
':����������:
'	������� ���������� ������� ����������� ������.
':���������:
'   Function X_IsDebugMode [As Boolean]
Function X_IsDebugMode
	X_IsDebugMode = Not IsNull(X_GetMD().getAttribute(META_DATA_DEBUG_ATTR))
End Function


'===============================================================================
'@@X_SetDebugMode
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SetDebugMode>
':����������:
'	��������� ������������� ������� ����������� ������.
':���������:
'	bDebug - 
'       [in] ������� ���������� �������.
':���������:
'	Sub X_SetDebugMode( bDebug [As Boolean] )
Sub X_SetDebugMode( bDebug)
	Dim bDebugCur	' ������� ������� ����������� ������
	Dim oMD			' ����������
	Set oMD = X_GetMD()
	bDebugCur = CBool( X_GetAttributeDef(oMD, META_DATA_DEBUG_ATTR, "0") = "1")
	bDebug = CBool(bDebug)
	If bDebugCur <> bDebug Then
		If bDebug Then 
			oMD.setAttribute META_DATA_DEBUG_ATTR, "1"
		Else
			oMD.removeAttribute META_DATA_DEBUG_ATTR
		End If
		XService.SetUserData META_DATA_STORE, oMD
	End If
End Sub


'===============================================================================
'@@X_ErrReportEx
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ErrReportEx>
':����������:
'	��������� ������� ����������� ��������� �� ������. 
':���������:
'	sMsg - 
'       [in] �������� ������.
'	sSrc - 
'       [in] �������� ������.
':���������:
'	Sub X_ErrReportEx (
'       sMsg [As String], 
'       sSrc [As String]
'    )
Sub X_ErrReportEx( sMsg, sSrc )
	On Error GoTo 0
	if X_IsDebugMode Then sMsg = sMsg & vbNewLine & vbNewLine & sSrc
	Alert sMsg
End Sub


'===============================================================================
'@@X_ErrReport
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ErrReport>
':����������:
'	��������� ������� ��������� �� ������ �� ������� Err. 
':���������:
'	Sub X_ErrReport ()
Sub X_ErrReport()
	X_ErrReportEx Err.Description, Err.Source
End Sub


'===============================================================================
'@@X_CreateObjectStub
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CreateObjectStub>
':����������:
'	������� ���������� "��������" ��� ������� � ��������� ����� � ���������������.
':���������:
'	sType - 
'       [in] ��� ���� �������.
'	sID - 
'       [in] ������������� �������.
':���������:
'	Function X_CreateObjectStub ( 
'       sType [As String],
'       sID [As String]
'   ) [As IXMLDOMElement]
Function X_CreateObjectStub( sType, sID)
	Dim oStub	' "��������" ������� (XMLDOMElement)

	' ������������� - ��� ���� � �������: 00000000-0000-0000-0000-000000000000
	If Len(sID) <> 36 Then Err.Raise -1, "X_CreateObjectStub", "������������ ������ ������������� �������: " & sID & vbCr & "���������: 00000000-0000-0000-0000-000000000000"
	
	Set oStub = XService.XMLGetDocument()					' ������� ������ XML-��������
	oStub.appendChild oStub.createElement( sType)			' ������� �������� �������
	oStub.documentElement.setAttribute "oid", LCase(sID)	' ������������� ������������� �������
	Set X_CreateObjectStub = oStub.documentElement			' ���������� ��������
End Function


'===============================================================================
'@@X_CreateStubFromXmlObject
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CreateStubFromXmlObject>
':����������:
'	������� ���������� "��������" ��� ����������� �������.
':���������:
'	oXmlObject - 
'       [in] ������, ��� �������� ���������� ������� "��������".
':���������:
'	Function X_CreateStubFromXmlObject ( oXmlObject [As IXMLDOMElement] ) [As IXMLDOMElement]
Function X_CreateStubFromXmlObject( oXmlObject )
	Dim oStub		' "��������" ������� (XMLDOMElement)
	
	' ������� ������ XML-��������
	Set oStub = XService.XMLGetDocument()			
	' ������� �������� �������
	oStub.appendChild oStub.createElement( oXmlObject.tagName )	
	' ������������� ������������� �������
	oStub.documentElement.setAttribute "oid", oXmlObject.getAttribute("oid")
	' ���������� ��������
	Set X_CreateStubFromXmlObject = oStub.documentElement	
End Function


'===============================================================================
'@@X_DeleteObject
'<GROUP !!FUNCTIONS_x-utils><TITLE X_DeleteObject>
':����������:
'	������� ������� ������ �� ��, ��������� ������� <b>DeleteObject</b>.
':���������:
'	sObjectType - 
'       [in] ������������ ���� �������.
'	sObjectID - 
'       [in] ������������� �������.
':���������:
'	���������� ���������� ��������� �������� (0 � ������ ������ ��� ������ 1, ����
'   ���� ��������� ��������.
':���������:
'	Function X_DeleteObject ( 
'       sObjectType [As String],
'       sObjectID [As String]
'   ) [As Int]
Function X_DeleteObject(sObjectType, sObjectID)
	Dim oResponse		' ������� �������
	
	With New XDeleteObjectRequest
		.m_sName = "DeleteObject"
		.m_sTypeName = sObjectType
		.m_sObjectID = sObjectID
		Set oResponse = internal_executeServerCommand( .Self )
	End With
	If Not oResponse Is Nothing Then
		X_DeleteObject = oResponse.m_nDeletedObjectQnt
	Else
		X_DeleteObject = 0
	End If
End Function


'===============================================================================
'@@X_GetObjectFromServer
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetObjectFromServer>
':����������:
'	������� ��������� ������ � �������, ��������� ������� <b>GetObject</b>.
':���������:
'	sObjectType - 
'       [in] ������������ ���� ������������ �������.
'	sObjectID - 
'       [in] ������������� ������������ �������.
'	vPreloads - 
'       [in] ������ ���������; ����� ���� ���� �������� ����� ���� ������������� 
'       ����� " ", "," ��� ";".
':���������:
'	���������� ������������������ ��������� IXMLDOMElement, ���������� ������
'   ������������ �������. � ������ ������ - Nothing.
':����������:	
'   ���� �� ������� ��������� ����������, �������� �� 
'   <LINK Croc.XmlFramework.Data.XObjectNotFoundException, XObjectNotFoundException />, 
'   <LINK Croc.XmlFramework.Public.XSecurityException, XSecurityException />,
'   <LINK Croc.XmlFramework.Public.XBusinessLogicException, XBusinessLogicException />,
'   �� ������������ ��������� �� ������ � ������������ VBS-������. �������� ������ 
'   ����� �������� � ������� ������� X_GetLastError.<P/>
'	������� ��������� ����������� �������� ����� ��������.
':���������:
'	Function X_GetObjectFromServer ( 
'       sObjectType [As String],
'       ByVal sObjectID [As String],
'       ByVal vPreloads [As Variant]
'   ) [As IXMLDOMElement]
Function X_GetObjectFromServer( sObjectType, ByVal sObjectID, ByVal vPreloads )
	Dim oTypeMD			' As IXMLDOMElement, ���������� ����
	Dim oXmlElement		' As IXMLDOMElement, �������
	
	Set X_GetObjectFromServer = Nothing
	If IsEmpty(vPreloads) Then
		vPreloads = Null
	Elseif IsNull(vPreloads) Then
		vPreloads = Null
	Elseif Not IsArray(vPreloads) Then 
		vPreloads = Replace(vPreloads, ",", " ")
		vPreloads = Replace(vPreloads, ";", " ")
		vPreloads = Replace(vPreloads, "  ", " ")
		vPreloads = Split(vPreloads, " ")
	End If
	If IsNull(sObjectID) Then
		sObjectID = GUID_EMPTY
	ElseIf IsEmpty(sObjectID) Or sObjectID="" Then
		sObjectID = GUID_EMPTY
	End If 
	If sObjectID = GUID_EMPTY Then
		' ����������� �������� ����� �������� (���� sObjectID �� �����)
		Set oTypeMD = X_GetTypeMD(sObjectType)
		If Nothing Is oTypeMD.SelectSingleNode("ds:prop[@vt='date' or @vt='dateTime' or @vt='time']/ds:def[(@default-type='both' or @default-type='xml') and (.='#CURRENT')]") Then
			Set oXmlElement = oTypeMD.selectSingleNode("template/" & sObjectType)
			If Nothing Is oXmlElement Then
				Set oXmlElement = internal_GetObjectFromServer(sObjectType, sObjectID, vPreloads)
				If Not oXmlElement Is Nothing Then
					oTypeMD.AppendChild(oTypeMD.ownerDocument.CreateElement("template")).AppendChild oXmlElement
					X_SaveMetadata oTypeMD.parentNode
				End If
			End If
			Set oXmlElement = oXmlElement.cloneNode(true)
			oXmlElement.SetAttribute "oid", CreateGuid
			XService.XmlGetDocument.AppendChild oXmlElement
			XService.XmlSetSelectionNamespaces oXmlElement.ownerDocument
			Set X_GetObjectFromServer = oXmlElement
		Else
			Set X_GetObjectFromServer = internal_GetObjectFromServer(sObjectType, sObjectID, vPreloads)
		End If	
	Else
		Set X_GetObjectFromServer = internal_GetObjectFromServer(sObjectType, sObjectID, vPreloads)
	End If
End Function


'==============================================================================
' �������: ������� ��� ���������� �����!
' ���������� ������ � �������, ���������� �������� GetObject.
' ���� �� ������� ��������� ���������� �������� �� XObjectNotFoundException, XSecurityException, XBusinessLogicException,
' �� ������������ ��������� �� ������ � ������������ vbs ������, ����� ������� ������ ���������� Nothing.
Private Function internal_GetObjectFromServer( sObjectType, sObjectID, vPreloads )
	Dim oResponse		' ������� �������
	
	With New XGetObjectRequest
		.m_sName = "GetObject"
		.m_sTypeName = sObjectType
		.m_sObjectID = sObjectID
		.m_aPreloadProperties = vPreloads
		Set oResponse = internal_executeServerCommand( .Self )
	End With
	If Not oResponse Is Nothing Then
		Set internal_GetObjectFromServer = oResponse.m_oXmlObject
	Else
		Set internal_GetObjectFromServer = Nothing
	End If
End Function


'==============================================================================
' �������� �������-������� ��������� ������� � �������� ���������.
' ��������� �������� �� ��������� ���� ����������: XObjectNotFoundException, XSecurityException, XBusinessLogicException.
' ��� ��������� ���������� ������������ ��������� �� ������ � ������������ vbs ������.
'	[in] oRequest - ������� �������, ��������� ������������������
'	[retval] ������ �������� (vbs-������ �������) ��� Nothing
Private Function internal_ExecuteServerCommand(oRequest)
	Dim oResponse	' ������� �������
	Dim aErr		' ���� ������� Err
	Dim sErrDescr	' �������� ������
	
	Set internal_ExecuteServerCommand = Nothing
	On Error Resume Next
	Set oResponse = X_ExecuteCommand(oRequest)
	If X_WasErrorOccured Then
		' �� ������� ��������� ������
		On Error Goto 0
		' ���� ������ �� ���������� ����, �� ������� ���������� ���� � ���������� ������ vbs
		With X_GetLastError
			' TODO: ���� ������������ ���������� �� �������� ��������� � �������� ������ ����� ����������
			If Not (.IsObjectNotFoundException Or .IsSecurityException Or .IsBusinessLogicException) Then
				.ShowDebugDialog
				.RaiseError
			End If
		End With
		' ����� ������ ������ � ����������� ������� Nothing, �������� ������ vbs ���
		Exit Function
	ElseIf Err Then
		' ������ ��������� �� ������� - ��� ������ � XFW
		sErrDescr = Err.Description
		' ������ �����������, ��� ������ ��������� ��-�� vbs-proxy ��� ��������� ������, ������� ���������� ��������� ������� �������
		If Err.Number = 13 Then			' - Type mismatch - ������� ����������� �������
			sErrDescr = sErrDescr & vbCr & "����������� �������: " & sFunctionName & vbCr & "�������� �� ���� ������������� proxy ��������� ��������"
		ElseIf Err.Number = 450 Then	' - Wrong number of arguments or invalid property assignment - ������������ ���-�� ����������
			sErrDescr = sErrDescr & vbCr & "������ ������ �������: " & sFunctionName & vbCr & "�������� �� ���� ������������� proxy ��������� ��������"
		End If
		aErr = Array(Err.Number, Err.Source, sErrDescr)
		On Error Goto 0
		Err.Raise aErr(0), aErr(1), aErr(2)				
	End If
	Set internal_ExecuteServerCommand = oResponse
End Function


'===============================================================================
'@@X_LoadObjectPropertyFromServer
'<GROUP !!FUNCTIONS_x-utils><TITLE X_LoadObjectPropertyFromServer>
':����������:
'	������� �������� ��������� ������� <b>GetProperty</b>.
':���������:
'	sObjectType - 
'       [in] ������������ ���� ������������ �������.
'	sObjectID - 
'       [in] ������������� ������������ �������.
'	sPropertyName - 
'       [in] ������������ ������������� �������� �������. 
':���������:
'	���������� ������������������ ��������� IXMLDOMElement, ���������� ������
'   ���� ������������� ��������.
':���������:
'	Function X_LoadObjectPropertyFromServer ( 
'       sObjectType [As String],
'       sObjectID [As String],
'       sPropertyName [As String]
'   ) [As IXMLDOMElement]
Function X_LoadObjectPropertyFromServer(sObjectType, sObjectID, sPropertyName)
	Dim oResponse		' ������� �������
	
	With New XGetPropertyRequest
		.m_sName = "GetProperty"
		.m_sTypeName = sObjectType
		.m_sObjectID = sObjectID
		.m_sPropName = sPropertyName
		Set oResponse = internal_ExecuteServerCommand( .Self )
	End With
	If Not oResponse Is Nothing Then
		Set X_LoadObjectPropertyFromServer = oResponse.m_oXmlProperty
	Else
		Set X_LoadObjectPropertyFromServer = Nothing
	End If
End Function


'===============================================================================
'@@X_GetMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetMD>
':����������:
'	������� ���������� ���������� (IXMLDOMElement � �������� ��������� 
'   <b>metadata</b>), ����������� � ������� ������ �� ������ � ����������� � ����.
':����������:	
'   ���� � ���������� ���� ��� ����������, �� ������� �������������� ��.<P/> 
'   ��������� ������� ������������������ � ��������� ������ ����������
'   �������� ������� ����������� cookie "metadata=1".<P/>
'	� ������ ������������� �������, ������� ���������� ������.
':���������:
'	Function X_GetMD () [As IXMLDOMElement]
Function X_GetMD()
	Dim oServerMD	' ���������� � �������
	Dim bCached		' ������� ������� ������������ ����������
	Dim sCookie		' ������ cookie, ������������ ��� ����������� ����� 
					' ������������� ���������� � ������
	Dim aErr		' ������ � ������ ������� Err
	
	sCookie = XService.URLEncode( UCase(XService.BaseURL())) & "METADATA=1"
	
	If IsEmpty(X_bMD) Then
		' �������� ������������ ����������
		bCached = XService.GetUserData( META_DATA_STORE,x_oMD )
		
		' ���� ����� ���������� �� ������� ���...
		If Not bCached Then
			' ������ �������� ������� ���������� � �������
			Set x_oMD = internal_GetMetadataRoot
			If x_oMD Is Nothing Then Exit Function
			' ��������� �������� ������� � ���������� ����
			XService.SetUserData META_DATA_STORE, x_oMD
		
		' ���� ���������� � ������ ������ �� ����������������
		ElseIf 0 = InStr( document.cookie, sCookie ) Then
			' ������ �������� ������� ���������� � �������
			Set oServerMD = internal_GetMetadataRoot
			If oServerMD Is Nothing Then Exit Function

			' ��������� �� ���������� �� ����������
			If 0 <> StrComp( "" & x_oMD.getAttribute("md5"), oServerMD.getAttribute("md5")) Then
				' �������������� ���
				XService.SetUserData META_DATA_STORE, oServerMD
				' ���������� ��������� �����
				Set X_oMD = oServerMD
				' ������� ��� ������
				X_ClearDataCache
			' �������� �� ���������� �� XSLT �������
			ElseIf 0 <> StrComp( "" & x_oMD.getAttribute("xsl-md5"), oServerMD.getAttribute("xsl-md5")) Then
				x_oMD.SetAttribute "xsl-md5", oServerMD.getAttribute("xsl-md5")
				' �������������� ��� ����������
				XService.SetUserData META_DATA_STORE, oServerMD
			' �������� �� ��������� �� ���� ������������
			ElseIf 0 <> StrComp( "" & x_oMD.getAttribute("config-hash"), oServerMD.getAttribute("config-hash")) Then
				x_oMD.SetAttribute "config-hash", oServerMD.getAttribute("config-hash")
				' �������������� ���
				XService.SetUserData META_DATA_STORE, oServerMD
				' ������� ��� ������
				X_ClearDataCache
			End If
		Else
			' ������������� ������������ ���� ��� XPath-��������
			XService.XMLSetSelectionNamespaces X_oMD.ownerDocument
		End If
		
		' �������������� Cookie
		document.cookie = sCookie
		X_bMD = True
	End If
	
	' ���������� ����������
	Set X_GetMD = X_oMD
End Function


'==============================================================================
' ���������� ������� ��������� ����� ����������
' � ������ ��������� ������ ���������� ����, � ������ ���������� ������ ���������� VBS runtime ������.
' [retval] IXMLDOMElement - ���� ds:metadata, ��� Nothing � ������ ������
Private Function internal_GetMetadataRoot
	Dim oServerMD	' ���������� � �������
	Set internal_GetMetadataRoot = Nothing
	On Error Resume Next
	Set oServerMD = XService.XMLGetDocument("x-metadata.aspx?ROOT=1")
	If Err Then
		X_SetLastServerError XService.LastServerError, Err.number, Err.Source, Err.Description
		X_HandleError
		Exit Function
	Else
		On Error Goto 0
		X_ClearLastServerError
	End If
	Set internal_GetMetadataRoot = oServerMD.documentElement
End Function


'==============================================================================
' �������� ������� ���������� � �������, ��������� �������� x-metadata.aspx
'	[in] sParamName - ������������ ��������� �������� x-metadata.aspx
'	[in] sMetaname - �������� ���������
Function internal_GetMetadataSubrootElementFromServer(sParamName, sMetaname)
	Dim oMD			' ���������� �� ����
	Dim oNodeMD		' (XMLDOMDocument, ����� XMLDOMNode)
	
	Set internal_GetMetadataSubrootElementFromServer = Nothing
	On Error Resume Next
	Set oNodeMD = XService.XMLGetDocument("x-metadata.aspx?" & sParamName & "=" & sMetaname)
	If Err Then
		X_SetLastServerError XService.LastServerError, Err.number, Err.Source, Err.Description
		On Error Goto 0
		X_GetLastError.RaiseError
	Else
		On Error Goto 0
		X_ClearLastServerError
	End If
	If Not IsNothing(oNodeMD) Then
		Set oMD = X_GetMD()
		Set oNodeMD = oNodeMD.documentElement
		' ��������� ���������� ���� (XMLElement) � ����� XML ���� ����������
		oMD.appendChild oNodeMD
		' ��������� ���������� � ��������� ���
		X_SaveMetadata oMD
	End If
	Set internal_GetMetadataSubrootElementFromServer = oNodeMD
End Function

'===============================================================================
'@@X_GetSubrootElementMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetSubrootElementMD>
':����������:
'	������� ���������� ���� ����������.
':���������:
'	sNode - 
'       [in] ��� ���� ����������, �������� "i:menu"
'	sNodeName - 
'       [in]  �������� �������� "n" ���� ����������
':���������:
'	���� <b>sNode</b> ����������.
':����������:	
'   ���������� ������� �� ����.<P/> 
'   ���� ��� ���������� ��� �� ���������, �� ��� ������������ 
'   � �������.<P/>
'	<b><i>��������!</b></i> ������ �� ��������������, �� ��������� � ���������� 
'   ����������, ��������� ����� X_GetLastError.
':���������:
'	Function X_GetSubrootElementMD ( 
'       sNode [As String],
'       sNodeName [As String]
'   ) [As IXMLDOMElement]
Function X_GetSubrootElementMD( sNode, sNodeName)
	Dim oMD					' ���������� �� ����
	Dim oSubrootElementMD	' ���������� ��� ���������� ����
	Set X_GetSubrootElementMD = Nothing
	' �������� ������� ��� ����������
	Set oMD = X_GetMD()	
	' �������� �������� ������ ��� �� ����
	Set oSubrootElementMD = oMD.selectSingleNode( sNode & "[@n='" & sNodeName & "']" )
	If oSubrootElementMD Is Nothing Then
		' � ���� ���, �������� � �������:
		Set oSubrootElementMD = internal_GetMetadataSubrootElementFromServer("NODE=" & XService.UrlEncode(sNode) & "&NAME", XService.UrlEncode(sNodeName))
	End If
	' ����� ��������
	Set X_GetSubrootElementMD = oSubrootElementMD	
End Function


'===============================================================================
'@@X_GetTypeMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetTypeMD>
':����������:
'	������� ���������� ���������� ���������� ����.
':���������:
'	sType - 
'       [in] ��� ���� �������������� ��������.
':���������:
'	���� <b>ds:type</b> ���������� ����.
':����������:	
'   ���������� ������� �� ����.<P/> 
'   ���� ��� ���������� ���� ���������� ��� �� ���������, �� ��� ������������ 
'   � �������.<P/>
'	<b><i>��������!</b></i> ������ �� ��������������, �� ��������� � ���������� 
'   ����������, ��������� ����� X_GetLastError.
':���������:
'	Function X_GetTypeMD ( 
'       sType [As String]
'   ) [As IXMLDOMElement]
Function X_GetTypeMD( sType)
	Dim oMD			' ���������� �� ����
	Dim oTypeMD		' ���������� ��� ���������� ���� (XMLDOMDocument, ����� XMLDOMNode)

	Set X_GetTypeMD = Nothing
	' �������� ������� ��� ����������
	Set oMD = X_GetMD()
	' �������� �������� ������ ��� �� ����
	Set oTypeMD = oMD.selectSingleNode( "ds:type[@n='" & sType & "']" )
	If oTypeMD Is Nothing Then
		' � ���� ���, �������� � �������:
		Set oTypeMD = internal_GetMetadataSubrootElementFromServer("OT", sType)
	End If
	' ����� ��������
	Set X_GetTypeMD = oTypeMD
End Function


'===============================================================================
'@@X_GetEnumMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetEnumMD>
':����������:
'	������� ���������� ���������� ������������ ��� ������.
':���������:
'	sEnumName - 
'       [in] ��� ������������ ��� ������.
':���������:
'	���� <b>ds:enum</b> ��� <b>ds:flags</b>.
':���������:
'	Function X_GetEnumMD ( 
'       sEnumName [As String]
'   ) [As IXMLDOMElement]
Function X_GetEnumMD(sEnumName)
	Dim oMD			' ���������� �� ����
	Dim oEnumMD 	' ���������� ��� ���������� ������������

	Set X_GetEnumMD = Nothing
	' �������� ������� ��� ����������
	Set oMD = X_GetMD()
	' �������� �������� ������ ��� �� ����
	Set oEnumMD = oMD.selectSingleNode( "ds:enum[@n='" & sEnumName & "'] | ds:flags[@n='" & sEnumName & "']" ) 
	If oEnumMD Is Nothing Then
		' � ���� ���, �������� � �������:
		Set oEnumMD = internal_GetMetadataSubrootElementFromServer("ENUM", sEnumName)
	End If
	' ����� ��������
	Set X_GetEnumMD = oEnumMD
End Function


'===============================================================================
'@@X_GetTreeMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetTreeMD>
':����������:
'	������� ���������� XML-���� ���������� ������/��������� �� ������.
':���������:
'	sMetaname - 
'       [in] ���������������� ��������.
':���������:
'	���� <b>i:objects-tree</b> ��� <b>i:objects-tree-selector</b>.
':���������:
'	Function X_GetTreeMD ( 
'       sMetaname [As String]
'   ) [As IXMLDOMElement]
Function X_GetTreeMD(sMetaname)
	Dim oMD			' ���������� �� ����
	Dim oTreeMD 	' ���������� ������
	
	Set X_GetTreeMD = Nothing
	' �������� ������� ��� ����������
	Set oMD = X_GetMD()
	' �������� �������� �� ����
	Set oTreeMD = oMD.selectSingleNode( "i:objects-tree[@n='" & sMetaname & "'] | i:objects-tree-selector[@n='" & sMetaname & "']" ) 
	If oTreeMD Is Nothing Then
		' � ���� ���, �������� � �������:
		Set oTreeMD = internal_GetMetadataSubrootElementFromServer("TREE", sMetaname)
	End If
	Set X_GetTreeMD = oTreeMD
End Function


'===============================================================================
'@@X_GetListMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetListMD>
':����������:
'	������� ���������� XML-���� ���������� ������.
':���������:
'	sObjectType - 
'       [in] ������������ ����.
'	sMetaname - 
'       [in] ���������������� ��������.
':���������:
'	���� <b>i:objects-list</b>.
':���������:
'	Function X_GetListMD ( 
'       sObjectType [As String],
'       sMetaname [As String]
'   ) [As IXMLDOMElement]
Function X_GetListMD(sObjectType, sMetaname)
	Dim sFilter
	If hasValue(sMetaname) Then sFilter = "[@n='" & sMetaname & "']"
	Set X_GetListMD = X_GetTypeMD(sObjectType).selectSingleNode("i:objects-list" & sFilter)
End Function


'===============================================================================
'@@X_SaveMetadata
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SaveMetadata>
':����������:
'	��������� ��������� ���������� � ����.
':���������:
'	oMD - 
'       [in] ����������.
':���������:
'	Sub X_SaveMetadata ( oMD [As IXMLDOMElement] )
Sub X_SaveMetadata(oMD)
	' ������������� ������������ ���� ��� XPath-��������
	XService.XMLSetSelectionNamespaces oMD.ownerDocument
	' ��������� ���������� � ��������� ���
	XService.SetUserData META_DATA_STORE, oMD
End Sub


'===============================================================================
'@@X_GetPropertyMD
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetPropertyMD>
':����������:
'	������� ���������� ���������� �������� ��� ����������� XML-��������.
':���������:
'	oXmlProperty - 
'       [in] XML-��������.
':���������:
'	Function X_GetPropertyMD ( 
'       oXmlProperty [As IXMLDOMElement]
'   ) [As IXMLDOMElement]
Function X_GetPropertyMD(oXmlProperty)
	If 0 <> StrComp(TypeName(oXmlProperty), "IXMLDOMElement", vbTextCompare) Then
		Err.Raise -1, "X_GetPropertyMD", "������������ ��� ��������� oXmlProperty: " & TypeName(oXmlProperty) & " - ������ ���� IXMLDOMElement"
	End If
	Set X_GetPropertyMD = X_GetTypeMD( oXmlProperty.parentNode.nodeName ).selectSingleNode( "ds:prop[@n='" & oXmlProperty.nodeName & "']")
End Function


'===============================================================================
'@@X_DialogDim
'<GROUP !!FUNCTIONS_x-utils><TITLE X_DialogDim>
':����������:
'	��������� ���������� ������� ����������� ����.
':���������:
'	vHeight - 
'       [in] ������ ����������� ����, ��� Null, ��� Empty.
'	vWidth - 
'       [in] ������ ����������� ����, ��� Null, ��� Empty.
'	nDefaultHeight - 
'       [in] ������ ����������� ���� �� ���������.
'	nDefaultWidth - 
'       [in] ������ ����������� ���� �� ���������.
'	nHeight - 
'       [out] ������� ������ ����������� ���� � ������.
'	nWidth - 
'       [out] ������� ������ ����������� ���� � ������.
':���������:
'   Sub X_DialogDim ( 
'       ByVal vHeight [As Variant], 
'       ByVal vWidth [As Variant], 
'       ByVal nDefaultHeight [As Int], 
'       ByVal nDefaultWidth [As Int], 
'       ByRef nHeight [As Int], 
'       ByRef nWidth [As Int]
'   )
Sub X_DialogDim(ByVal vHeight, ByVal vWidth, ByVal nDefaultHeight, ByVal nDefaultWidth , ByRef nHeight, ByRef nWidth )
	const HUNDRED_PERCENT = 100 ' 100 %

	if IsNull(vHeight) Then 
		vHeight = nDefaultHeight
	ElseIf IsEmpty(vHeight)	Then
		vHeight = nDefaultHeight
	End if	
	
	if IsNull(vWidth) Then 
		vWidth = nDefaultWidth
	ElseIf IsEmpty(vWidth)	Then
		vWidth = nDefaultWidth
	End if
	
	vHeight = CLng(vHeight) 
	vWidth = CLng(vWidth) 
	if vHeight <= HUNDRED_PERCENT Then
		nHeight = CLng( vHeight * window.screen.availHeight / HUNDRED_PERCENT  ) 
	Else
		nHeight = vHeight
	End if
	if vWidth <= HUNDRED_PERCENT Then
		nWidth = CLng( vWidth * window.screen.availWidth / HUNDRED_PERCENT  ) 
	Else
		nWidth = vWidth
	End if
End Sub


'===============================================================================
'@@ObjectEditorDialogClass
'<GROUP !!CLASSES_x-utils><TITLE ObjectEditorDialogClass>
':����������:	
'	�����, ��������������� ������ �������� � �������� ���������� � ��������,
'	����������� � ���������� ����.
':����������:
'	� ����������� ���� ��������� ���������� ��������� ������� ������. 
'	��� ��������� �������� � ��������� ������ �� ������� � ���������� ��������: 
'	��� ����, ����������, ConfigClass.<P/>
'	��� �������� ��������� ������� ������������ ������� 
'	ObjectEditorDialogClass_Show, ������� � ��� ��������� ������� ������. 
':��. �����:
'	ObjectEditorDialogClass_Show
'
'@@!!MEMBERTYPE_Methods_ObjectEditorDialogClass
'<GROUP ObjectEditorDialogClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_ObjectEditorDialogClass
'<GROUP ObjectEditorDialogClass><TITLE ��������>
Class ObjectEditorDialogClass
	Private m_oXmlObject		' XmlElement, ������������� ������
	Private m_oPool				' As XObjectPool - ��� �������� (��� ������ ������� ��� ������� ��������� ���������)
	Public ObjectType			' As String - ��� �������
	Public ObjectID				' As String - ������������� ������� 
	Public MetaName				' As String - ������� ���������/�������
	Public IsNewObject			' As Boolean - ������� ������������� �������� ������ ������� ������ �������� � ��
	Public IsAggregation		' As Boolean - ������� �������� � ���-�� ���������� ��� � ��������
	Public QueryString			' QueryStringClass
	Public ParentObjectEditor	' ObjectEditorClass, ������������ ��������
	Public ParentObjectID		' As String - ObjectID ������������� �������
	Public ParentObjectType		' As String - ������������ ���� ������������� �������
	Public ParentPropertyName	' As String - ������������ �������� ������������� �������, � ������� ���������/����������� ������
	Public EnlistInCurrentTransaction	' As Boolean - ������� ����, ��� �������� �������� � ������� ���������� ���� � �� ��������/�������� ����� ����������
	'@@ObjectEditorDialogClass.SkipInitErrorAlerts
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorDialogClass><TITLE SkipInitErrorAlerts>
	':����������:	��������� ��������� � ���� ��� ����������� � ���, 
	'				��� � ������ ������������� ���������� �������� UI ��������� ��� 
	'               �������� �������, �� ������� �������� ������� �������������� 
	'               ������������.
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	Public SkipInitErrorAlerts [As Boolean]
	Public SkipInitErrorAlerts
	
	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		IsNewObject	= False
		IsAggregation = True
		EnlistInCurrentTransaction = False
		Set QueryString = X_GetEmptyQueryString
		Set ParentObjectEditor = Nothing
		Set m_oXmlObject = Nothing
		Set m_oPool = Nothing
	End Sub

	'------------------------------------------------------------------------------
	'@@ObjectEditorDialogClass.XmlObject
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorDialogClass><TITLE XmlObject>
	':����������:	 
	'   ������������� ������.
	':���������:	
	'   Public Property Set XmlObject (value [As IXMLDOMElement])
	'   Public Property Get XmlObject [As IXMLDOMElement]
	Public Property Set XmlObject(value)
		If Not value Is Nothing Then
			ObjectType = value.tagName
			ObjectID = value.getAttribute("oid")
		End If
		Set m_oXmlObject = value
	End Property
	
	Public Property Get XmlObject
		Set XmlObject = m_oXmlObject
	End Property
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorDialogClass.Pool
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorDialogClass><TITLE Pool>
	':����������:	 
	'   ��� �������� (��� ������ ������� ��� ������� ��������� ���������).
	':���������:	
	'   Public Property Set Pool (value [As XObjectPool])
	'   Public Property Get Pool [As XObjectPool]
	Public Property Set Pool(value)
		Set m_oPool = value
	End Property
	
	Public Property Get Pool
		Set Pool = m_oPool
	End Property
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorDialogClass.GetRightsCache
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorDialogClass><TITLE GetRightsCache>
	':����������:	
	'	������� ���������� ��� ���� � ������� �������� (�� ������� ��� ������ 
	'   ��������� ObjectEditorDialogClass). ��� �������� ��������� ���������
	'   ������������ ������ ��� ����.
	':���������:
	'	Public Function GetRightsCache [As ObjectRightsCacheClass] 
	Public Function GetRightsCache
		If ParentObjectEditor Is Nothing Then
			Set GetRightsCache = New ObjectRightsCacheClass
		Else
			Set GetRightsCache = X_RightsCache()
		End If
	End Function
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorDialogClass.GetMetadataRoot
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorDialogClass><TITLE GetMetadataRoot>
	':����������:	
	'	������� ���������� �������� ���� ���������� �� ��������, ��� ��� ������ 
	'   ������� ��������� ObjectEditorDialogClass (�.�. ������������ �������� 
	'   ���������).
	':���������:
	'	Public Function GetMetadataRoot [As IXMLDOMElement] 
	Public Function GetMetadataRoot
		Set GetMetadataRoot = X_GetMD()
	End Function
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorDialogClass.GetConfig
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorDialogClass><TITLE GetConfig>
	':����������:	
	'	������� ���������� ��������� ConfigClass
	'   �� ��������, ��� ��� ������ ������� ��������� ObjectEditorDialogClass 
	'   (�.�. ������������ �������� ���������).
	':���������:
	'	Public Function GetConfig [As ConfigClass] 
	Public Function GetConfig
		If hasValue(x_oConfig) Then
			Set GetConfig = x_oConfig
		Else
			Set GetConfig = Nothing
		End If
	End Function
End Class


'===============================================================================
'@@ObjectEditorDialogClass_Show
'<GROUP !!FUNCTIONS_x-utils><TITLE ObjectEditorDialogClass_Show>
':����������:
'	������� ��������� ���������� ��������� ���� � ����������.
':���������:
'	oObjectEditorDialog - 
'       [in] ��������� ObjectEditorDialogClass.
':���������:
' 	���������� ������������� ���������� / ������������������ �������, ���� 
'	�������� ������ �� "��", ����� - Empty.
':����������:
'	������� �������� �� ������ ObjectEditorDialogClass ��� ����, ����� �� 
'	����������� ���� ��������� ������� (��-�� ������ � VBScript-runtime, 
'	���������� � "stack overflow at line 0").
':���������:
'   Function ObjectEditorDialogClass_Show ( 
'       oObjectEditorDialog [As ObjectEditorDialogClass]
'   ) [As Variant]
Function ObjectEditorDialogClass_Show(oObjectEditorDialog)
	Dim sUrl			' URL ������ ���������
	Dim vResult			' ��������� ���������� ��������
	Dim bLoad			' ������� ������������� ��������� ������ �������������� �������
	
	ObjectEditorDialogClass_Show = Empty

	With oObjectEditorDialog
		' ���� �������� ����������� ��� �������������� �������, �������������� �� �������, �� ��������� � ���� ��� �������������, 
		' ��� ����� ��������, ��� ��������� ��� ������ ��������� ������ � "�������������" ��� � ������� ����, ������ ��� �������� ObjectEditor.
		bLoad = True
		If .IsNewObject Then
			' ��� �������� ������� �� ���� ������� (�� �������� �������� ����� �������� �� �������)
			bLoad = False
		ElseIf Not .XmlObject Is Nothing Then 
			' ����� ������������� ������ - �� ���� �������
			bLoad = False
		ElseIf Not .Pool Is Nothing Then
			' ����� ���, �������� ���� �� ��� ������������� ������
			If Not .Pool.FindXmlObject(.ObjectType, .ObjectID) Is Nothing Then
				bLoad = False
			End If
		End If
		
		' ��������� URL ���������
		sUrl = XService.BaseUrl() & "x-editor.aspx?OT=" & .ObjectType & "&MetaName=" & .MetaName & "&CreateNewObject=" & Iif(true=.IsNewObject,1,0)
		If bLoad Then 
			sUrl = sUrl & "&ID=" & .ObjectID & "&tm=" & CDbl(Now())
		End If
		' ������� ���������� ���� ���������
		vResult = X_ShowModalDialog(sURL, oObjectEditorDialog)
		' �������������� ������
		If IsEmpty(vResult) Then Exit Function
		If IsNull(vResult) Then Exit Function
	End With
	ObjectEditorDialogClass_Show = vResult
End Function


'===============================================================================
'@@X_OpenObjectEditor
'<GROUP !!FUNCTIONS_x-utils><TITLE X_OpenObjectEditor>
':����������:
'	������� ��������� ���� ��������� (x-editor.aspx).
':���������:
'	sObjectType - 
'       [in] ��� �������.
'	sObjectID - 
'       [in] ������������� ������� (���� Null, �� ������ ���������).
'	sEditorMetaname - 
'       [in] ��� ��������� � ����������.
'	sUrlParams - 
'       [in] ������ �������������� ���������� (���������� � URL).
':���������:
' 	���������� Empty, ���� ������ �� ���������������, ����� - ������������� �������.
':���������:
'   Function X_OpenObjectEditor (
'       sObjectType [As String], 
'       sObjectID [As String], 
'       sEditorMetaname [As String], 
'       sUrlParams [As String]
'   ) [As Variant]
Function X_OpenObjectEditor(sObjectType, sObjectID, sEditorMetaname, sUrlParams)
	Dim oObjectEditorDialog
	Set oObjectEditorDialog = new ObjectEditorDialogClass
	oObjectEditorDialog.IsNewObject = Not HasValue(sObjectID)
	oObjectEditorDialog.QueryString.QueryString = sUrlParams
	oObjectEditorDialog.IsAggregation = False
	oObjectEditorDialog.MetaName = sEditorMetaname
	oObjectEditorDialog.ObjectType = sObjectType
	oObjectEditorDialog.ObjectID = sObjectID
	X_OpenObjectEditor = ObjectEditorDialogClass_Show(oObjectEditorDialog)
End Function

'==============================================================================
' ��������!
' � ����� � �������
'	974455  MS09-054: Cumulative security update for Internet Explorer
' http://support.microsoft.com/kb/976749/
' ��� ������ � ���������� ��������� ��� �� ���������� ��� �
' � ��������� ���� ����������:
' 1) ��� �������� ����������� ���� ������ ������ window.ShowModalDialog 
'		����� ������������ X_ShowModalDialogEx
' 2) � ���� ����������� ���� ��� ��������� �������� ���������� ������
'		������� ������� � �������� window.DialogArguments 
'		����� ������������ X_GetDialogArguments
' 3) � ���� ����������� ���� ��� ��������� ������������� �������� ������
'		����������� �������� window.ReturnValue 
'		����� ������������ X_SetDialogWindowReturnValue
'==============================================================================

'===============================================================================
' ����� ������������� �������� � ������������ �������� ���������� �������
' ������ ����� ������ ��� ������ � ������������� 
' 974455  MS09-054: Cumulative security update for Internet Explorer
' http://support.microsoft.com/kb/976749/
'
' ����� �� ������������ ��� ����������������� ������������� ���������� �����, 
' ������ �������������� ������� X_ShowModalDialog, X_ShowModalDialogEx, 
' X_GetDialogArguments, X_SetDialogWindowReturnValue
Class internal_DialogArgsAndReturnValueClass
	' ���������, ������������ � ���������� ���� 
	public internal_Arguments
	' ��������, ������������ �� ����������� ���� � ���������� ���
	public internal_ReturnValue
End Class

'===============================================================================
'@@X_ShowModalDialogEx
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ShowModalDialogEx>
':����������:	
'	��������� ���������� ���� ��������, ��������� ���������.
'	������������ ��� ������ � ������������� KB974455  MS09-054: Cumulative security update for Internet Explorer
'	http://support.microsoft.com/kb/976749/
':���������:
'	sUrl - 
'       [in] ����� ����������� � ��������� ���������� ���� ���������.
'	vArguments - 
'       [in] ���������, ������������ � ���������� ������.
'	sFeatures - 
'       [in] �������������� ��������� ����������� ����, �������� "help:no;center:yes;status:no".
':���������:
' 	���������, ������������ �������� (������������� ������� X_SetDialogWindowReturnValue).
':���������:
'	Function X_ShowModalDialogEx(
'       sUrl [As String],
'       vArguments [As Variant],
'       sFeatures [As String]
'   ) [As Variant]
Function X_ShowModalDialogEx(sUrl,  vArguments, sFeatures )
	Dim objArguments ' ��������� ����
	Set objArguments = new internal_DialogArgsAndReturnValueClass
	If IsObject( vArguments ) Then
		Set objArguments.internal_Arguments = vArguments
	Else
		objArguments.internal_Arguments = vArguments
	End If
	objArguments.internal_ReturnValue = Empty
	' ������ ���������� ����
	window.ShowModalDialog sUrl, objArguments, sFeatures
	' ��������� ������ �� ����
	If IsObject( objArguments.internal_ReturnValue ) Then
		Set X_ShowModalDialogEx = objArguments.internal_ReturnValue
	Else
		X_ShowModalDialogEx = objArguments.internal_ReturnValue
	End If
End Function

'===============================================================================
'@@X_GetDialogArguments
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetDialogArguments>
':����������:	
'	��������� ���������� � ���������� ����.
'	������������ ��� ������ � ������������� KB974455  MS09-054: Cumulative security update for Internet Explorer
'	http://support.microsoft.com/kb/976749/
':���������:
'	vDialogArguments - 
'       [out] �������� ���������� ����������� ����, ����� �������� NULL � ������������ ������������ �������� ��������.
':���������:
' 	�������� ���������� ����������� ����, �� �� �����, ��� ������� � vDialogArguments ����� �������� �� �������.
':���������:
'	Function X_GetDialogArguments(
'       ByRef vDialogArguments [As Variant]
'   ) [As Variant]
Function X_GetDialogArguments(ByRef vDialogArguments)
	Dim arrResult ' ��������� ����������
	' ���� � ������ ����� �� ������� � Set � Let
	' ����������� Eval("...") ������������ ��� ���������� ������ ��� ��������� � ��-�� DialogArguments
	'	�� ������������ ����.
	arrResult = Eval("Array(DialogArguments)")
	If IsObject(arrResult(0)) Then
		Set vDialogArguments = arrResult(0)
		If "internal_DialogArgsAndReturnValueClass" = TypeName(vDialogArguments) Then
			If IsObject(vDialogArguments.internal_Arguments) Then
				Set  vDialogArguments = vDialogArguments.internal_Arguments
				Set X_GetDialogArguments = vDialogArguments
			Else
				vDialogArguments = vDialogArguments.internal_Arguments
				X_GetDialogArguments = vDialogArguments
			End If
		Else
			Err.Raise -1, "x-utils.vbs - X_GetDialogArguments", _
				"��� ������ ����������� ���� ���������� ������������ X_ShowModalDialog(Ex)!"
		End If
	Else
		vDialogArguments = arrResult(0)
	End If		
End Function

'===============================================================================
'@@X_SetDialogWindowReturnValue
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SetDialogWindowReturnValue>
':����������:	
'	������������� ��������� ���������� ����������� ����.
'	������������ ��� ������ � ������������� KB974455  MS09-054: Cumulative security update for Internet Explorer
'	http://support.microsoft.com/kb/976749/
':���������:
'	vReturnValue - 
'       [in] ��������.
':���������:
'	Sub X_SetDialogWindowReturnValue( vReturnValue [As Variant] )
Sub X_SetDialogWindowReturnValue( vReturnValue )
	If IsObject( vReturnValue ) Then
		Set window.DialogArguments.internal_ReturnValue = vReturnValue
	Else
		window.DialogArguments.internal_ReturnValue = vReturnValue
	End If		
End Sub

'===============================================================================
'@@X_ShowModalDialog
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ShowModalDialog>
':����������:
'	������� ��������� ���������� ����, ������������� �������� � URL ���������
'   SCREENWIDTH � SCREENHEIGHT.
':���������:
'	sURL - 
'       [in] URL �������.
'	vDialogArguments - 
'       [in] ���������, ������������ � ���������� ������.
':���������:
' 	���������, ������������ �������� (��������� ������ X_SetDialogWindowReturnValue).
':���������:
'   Function X_ShowModalDialog (
'       sURL [As String], 
'       vDialogArguments [As Variant]
'   ) [As Variant]
Function X_ShowModalDialog(sURL, vDialogArguments)
	Dim arrResult ' ���������
	arrResult = Array(	 X_ShowModalDialogEx(sURL & "&SCREENWIDTH=" & window.screen.availWidth & "&SCREENHEIGHT=" & window.screen.availHeight, vDialogArguments, "help:no;center:yes;status:no") )
	If IsObject(arrResult(0)) Then
		Set X_ShowModalDialog = arrResult(0)
	Else
		X_ShowModalDialog = arrResult(0)
	End If
End Function

'===============================================================================
'@@X_OpenReport
'<GROUP !!FUNCTIONS_x-utils><TITLE X_OpenReport>
':����������:
'	������� ��������� ���� � �������.
':���������:
'	sURL - 
'       [in] ����� �������� ������.
':���������:
' 	��������� ������ window.open.
':���������:
'   Function X_OpenReport (
'       sURL [As String] 
'   ) [As IHTMLWindow]
Function X_OpenReport(sURL)
	If Len(sURL) = 0 Then
		sURL = ABOUT_BLANK
	ElseIf 0 <> StrComp(sURL, ABOUT_BLANK, vbTextCompare) Then
		' ��������� �������� tm ��� �������������� ����������� (������ ���� ��� ��� ���!)
		If 0 >= InStr(1, sURL, "&tm=", vbTextCompare) Then
			If 0>=InStr(1, sURL, "?tm=", vbTextCompare) Then
				sURL = sURL & iif(InStr(1, sURL, "?"), "&tm=" , "?tm=" ) & CDbl(now)
			End If
		End If
	End If

	' ��������� ���� ������ � ������������� �� ���� �����
	' � ������������ ���� ��������� ��������� ����� �� 0 �� 100000
	Randomize
	Set X_OpenReport = window.open(sURL, "report_" & CLng( Rnd()*100000), _
			"width=" & CStr(screen.availWidth*0.9) & _
			",height=" & CStr(screen.availHeight*0.9) & _
			",top=1,left=1,toolbar=no,menubar=yes,location=no,resizable=yes,scrollbars=yes,status=no,directories=no")
End Function

'===============================================================================
'@@X_OpenReportEx
'<GROUP !!FUNCTIONS_x-utils><TITLE X_OpenReportEx>
':����������:
'	������� ��������� ���� � �������. 
':���������:
'	sURL - 
'       [in] ����� �������� ������.
'   vReportParams -
'       [in] ��������� ���������� ������ (� ���� ������ QueryStringClass ��� ������ ���� Name1=Value1&Name2=Value2&...&NameY=ValueY.)
'   bSendUsingPOST -
'       [in] True - ������ ���������� ��������� �� ������ ������� POST; False - ������������ POST ������, ���� ����� URL > MAX_GET_SIZE
':���������:
' 	��������� ������ window.open.
':���������:
'   Function X_OpenReportEx (
'       sURL [As String],
'       vReportParams [As String | QueryStringClass],
'       bSendUsingPOST [As Boolean]
'   ) [As IHTMLWindow]
Function X_OpenReportEx(sURL, vReportParams, bSendUsingPOST)
    Dim sReportParams   '[As String] - ��������� ������ � ���� ������
    Dim oReportParams   '[As QueryStringClass] - ��������� ������ � ���� ������
    Dim oDoc            ' �������� ���� ��������
    Dim sKey            '[As String] - ������������ ��������� ������
    Dim aValues         '[As Array] - ������ �������� ��������� ������
    Dim sValue          '[As String] - �������� ��������� ������
    
    If IsNothing(vReportParams) Then
        ' ��������� �������� �������
        sReportParams = toString(vReportParams)
        If Len(sReportParams) > 0 Then
            Set oReportParams = New QueryStringClass
            oReportParams.QueryString = sReportParams                
        End If
    Else
        ' ��������� �������� �������
        Set oReportParams = vReportParams
        sReportParams = oReportParams.QueryString
    End If

    If Len(sReportParams) = 0 Then
        Set X_OpenReportEx = X_OpenReport(sURL)
        Exit Function
    End If
    
    If Not bSendUsingPOST And Len(sURL) + Len(sReportParams) <= MAX_GET_SIZE Then
        ' �������� ����� GET
        If InStr(1, sURL, "?") <= 0 Then
            sURL = sURL & "?" & sReportParams
        Else
            sURL = sURL & "&" & sReportParams
        End If
        Set X_OpenReportEx = X_OpenReport(sURL)
        Exit Function
    End If
    
    ' ����� ���������� ����� POST. ��� ����� � ����� ���� �������� �����, �������� ����������� � ��POST��
    Set X_OpenReportEx = X_OpenReport(ABOUT_BLANK)
    Set oDoc = X_OpenReportEx.document
    oDoc.open
    oDoc.writeln "<HTML><HEAD><meta http-equiv=""Content-Type"" content=""text/html; charset=windows-1251"" /></HEAD>"
    oDoc.writeln "<BODY><FORM id=""PostDataForm"" method=""POST"" action=""" & XService.HtmlEncodeLite(sURL) & """>"
    For Each sKey In oReportParams.Names
        aValues = oReportParams.GetValues(sKey)
        If IsArray(aValues) Then
            For Each sValue in aValues
                oDoc.writeln "<INPUT name=""" & XService.HtmlEncodeLite(sKey) & """ type=""hidden"" value=""" & XService.HtmlEncodeLite(sValue) & """></INPUT>"
            Next
        End If
    Next
    oDoc.writeln "</FORM>"
    oDoc.writeln "<SCRIPT TYPE=""text/vbscript"" LANGUAGE=""VBScript"">"
    oDoc.writeln "document.charset=""windows-1251"""
    oDoc.writeln "setTimeout ""document.forms(""""PostDataForm"""").submit"", 10, ""VBScript"""
    oDoc.writeln "</SCRIPT></BODY></HTML>"
    oDoc.close
End Function

'===============================================================================
'@@X_OpenHelp
'<GROUP !!FUNCTIONS_x-utils><TITLE X_OpenHelp>
':����������:
'	��������� ���������� ���� �������.
':���������:
'	vHelpPage - 
'       [in] ��� �������� �� ��������.
':���������:
'   Sub X_OpenHelp(ByVal vHelpPage [As Variant])
Sub X_OpenHelp(ByVal vHelpPage)
	vHelpPage = "" & vHelpPage
	if 0=len( vHelpPage) Then
		vHelpPage = "HELP/HELP.ASPX"
	Else
		vHelpPage = "HELP/HELP.ASPX?" & XService.UrlEncode( vHelpPage)
	End if		
	window.open vHelpPage, "CrocXmlFrameworkHelpWindow_B2F1D332EB024632BA4EF8E72BC86957" , _
			"width=" & CStr(screen.availWidth*0.7) & _
			",height=" & CStr(screen.availHeight*0.7) & _
			",top=1,,left=1,toolbar=no,menubar=no,location=no,resizable=yes,scrollbars=yes,status=no"
End Sub


'===============================================================================
'@@X_DebugShowHTML
'<GROUP !!FUNCTIONS_x-utils><TITLE X_DebugShowHTML>
':����������:
'	��������� ��������� ���� � ������� � ���� �������� HTML-�����.
':���������:
'	vHtml - 
'       [in] ��������� HTML-�����.
':���������:
'   Sub X_DebugShowHTML(vHtml [As Variant])
Sub X_DebugShowHTML( vHtml)
	Dim oWin	' ����� ����
	If IsObject( vHtml) Then
		window.showModelessDialog "x-html-dom-navigator.aspx", vHtml, "help:no;center:yes;status:no;resizable:yes"
	Else
		' ��������� ���������� ����
		Set oWin = window.open(ABOUT_BLANK, "_blank", "height=200,width=400,status=yes,toolbar=no,menubar=no,location=no,scrollbars=yes,resizable=yes")
		' ������� �����
		oWin.document.open
		oWin.document.write "<PLAINTEXT>" & vHtml
		oWin.document.close
	End If	
End Sub


'===============================================================================
'@@X_DebugShowXML
'<GROUP !!FUNCTIONS_x-utils><TITLE X_DebugShowXML>
':����������:
'	��������� ��������� ���� � XML-����������, ��������������� ���������� ��������.
':���������:
'	oXMLDOMDocument - 
'       [in] ��������� XML, ��������� IXMLDOMDocument ��� IXMLDOMElement.
':���������:
'   Sub X_DebugShowXML(oXMLDOMDocument [As Variant])
Sub X_DebugShowXML( oXMLDOMDocument)
	CONST XML_NODE_DOCUMENT = 9
	Dim oStyle	' XSL
	Dim oWin	' ����� ����
	Dim oXmlDoc	' ������������ ��������
	' ��������� ������
	On Error Resume Next
	Set oStyle = XService.XMLGetDocument( "xsl/x-debug.xsl")
	if Err Then
		X_ErrReport()
		Exit Sub
	End if
	if XML_NODE_DOCUMENT =  oXMLDOMDocument.nodeType Then
		Set oXmlDoc = oXMLDOMDocument
	Else
		Set oXmlDoc = XService.XMLGetDocument()
		Set oXmlDoc.documentElement = oXMLDOMDocument.cloneNode( true) 
	End if
	' ��������� ���������� ����
	Set oWin = window.open(ABOUT_BLANK, "_blank", "height=200,width=400,status=yes,toolbar=no,menubar=no,location=no,scrollbars=yes,resizable=yes")
	' ������� �����
	oWin.document.open
	oWin.document.write oXmlDoc.transformNode( oStyle)
	oWin.document.close
End Sub


'===============================================================================
'@@X_IsFrameReady
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsFrameReady>
':����������:
'	������� ������������ ��������, ��� ����� �������� � ���������������.
':���������:
'	oFrame - 
'       [in] HTML-������� <b>FRAME</b> ��� <b>IFRAME</b>.
':���������:
' 	���������� True, ���� ����� �������� � ���������������, ��� False - � 
'	��������� ������.
':����������:
'	��������� ������������ �������� <b>src</b> ������ ���������, ������������
'	�� �����, � ��� �������� ��������� ������������ ��������� �������� �������
'	X_IsDocumentReady.
':���������:
'   Function X_IsFrameReady ( 
'       oFrame [As IHTMLElement]
'   ) [As Boolean]
Function X_IsFrameReady( oFrame)
	Dim oDoc	' �������� � ������
	' ��������� ��������� �������� FRAME ��� IFRAME
	if 0 <> StrComp(oFrame.readyState, "complete", vbTextCompare) Then 
		X_IsFrameReady = false
		Exit Function
	End if
	' ������ �� ��������� ����������
	if 0 = Len(oFrame.src) Then 
		X_IsFrameReady = true
		Exit Function
	End if
	' ���� ��� �������� � DOM ������������ ���������
	Set oDoc = oFrame.Document.Frames(oFrame.uniqueID).Document
	' ��������� URL
	if 0 = InStr( 1, oDoc.location.href, oFrame.src, vbTextCompare) Then
		X_IsFrameReady = false
		Exit Function
	End if
	' ��������� ����������� ��������
	X_IsFrameReady = X_IsDocumentReady( oDoc)
End Function


'===============================================================================
'@@X_IsObjectReady
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsObjectReady>
':����������:
'	������� ������������ ��������, ��� ������ �������� � ���������������.
':���������:
'	oObject - 
'       [in] HTML-������� <b>OBJECT</b> ��� ������ IXMLDOMDocument.
':���������:
' 	���������� True, ���� ������ �������� � ���������������, ��� False - � 
'	��������� ������.
':���������:
'   Function X_IsObjectReady ( 
'       oObject [As Variant]
'   ) [As Boolean]
Function X_IsObjectReady( oObject)
	Const READY_STATE_INITIALIZED = 4	' ��������� ������� - ���������������
	X_IsObjectReady = ( READY_STATE_INITIALIZED = CLng( oObject.readyState) )
End Function


'===============================================================================
'@@X_IsBehaviorReady
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsBehaviorReady>
':����������:
'	������� ������������ ��������, ��� DHTML Behavior �������� � ���������������.
':���������:
'	oObject - 
'       [in] ������ �� ��������� DHTML Behavior.
':���������:
' 	���������� True, ���� DHTML Behavior �������� � ���������������, ��� False - � 
'	��������� ������.
':����������:
'	������������ ��� ���� DHTML Behavior � XFW .NET.<P/>
'	���������� ������������ � ������� ������ ������ IsComponentReady.
':���������:
'   Function X_IsBehaviorReady ( 
'       oObject [As Variant]
'   ) [As Boolean]
Function X_IsBehaviorReady(oObject)
	On Error Resume Next

	X_IsBehaviorReady = oObject.IsComponentReady
	If Err Then
		On Error GoTo 0
		X_IsBehaviorReady = True
	End If
End Function


'===============================================================================
'@@X_IsDocumentReady
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsDocumentReady>
':����������:
'	������� ������������ ��������, ��� �������� �������� � ���������������.
':���������:
'	oDoc - 
'       [in] �������� ��� ������ �������, ������� �������� ��������� all.
':���������:
' 	���������� True, ���� �������� �������� � ���������������, ��� False - � 
'	��������� ������.
':����������:
'	���� �������� ��������� <b><i>oDoc</b></i> - Null, �� ����������� �������
'   ��������.<P/>
'	� ��������� ����������� ��������� ������� � ��������. ��� �������� ������� 
'   ���������� ������� X_IsFrameReady, ��� �������� �������� - �������
'   X_IsObjectReady.
':���������:
'   Function X_IsDocumentReady ( 
'       byval oDoc [As Variant]
'   ) [As Boolean]
Function X_IsDocumentReady(byval oDoc)
	Dim oElement	' ������� ���������
	X_IsDocumentReady = False
	If IsNull( oDoc) Then
		Set oDoc = Document
	End If	
	If 0 <> StrComp(oDoc.readyState, "complete", vbTextCompare) Then Exit Function
	With oDoc.all
		' ���� ������
		For Each oElement In .tags("iframe")
			If Not X_IsFrameReady( oElement) Then Exit Function
		Next
		For Each oElement In .tags("frame")
			If Not X_IsFrameReady( oElement) Then Exit Function
		Next
		' ���� �������
		For Each oElement In .tags("object")
			If Not X_IsObjectReady( oElement) Then Exit Function
		Next
	End With
	X_IsDocumentReady = True
End Function


'===============================================================================
'@@X_IsDocumentReadyEx
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsDocumentReadyEx>
':����������:
'	������� ������������ ��������, ��� �������� �������� � ���������������, � �����
'   ��� ��������� ��� �������� �������� �����.
':���������:
'	oDoc - 
'       [in] �������� ��� ������ �������, ������� �������� ��������� all.
'	vCustomTags - 
'       [in] ������������ custom-���� DHTML Behavior, ���� ������ ������������.
':���������:
' 	���������� True, ���� �������� �������� � ��������������� � ��������� ���
'   �������� �������� �����, ��� False - � ��������� ������.
':����������:
'   ������� ������������ �� ���������, ���������� DHTML Behavior.<P/>
'	���� �������� ��������� <b><i>oDoc</b></i> - Null, �� ����������� �������
'   ��������.<P/>
'	������� �������� ������� X_IsDocumentReady. ���� ��������� �� ������ - True, �� 
'   �� �������� ��������� ��� �������� �������� ����� � ��� ������� �� ��� ����������
'   ������� X_IsBehaviorRead.
':���������:
'   Function X_IsDocumentReadyEx ( 
'       byval oDoc [As Variant],
'       vCustomTags [As Variant]
'   ) [As Boolean]
Function X_IsDocumentReadyEx(byval oDoc, vCustomTags)
	Dim sCustomTag 
	Dim oElement
	
	X_IsDocumentReadyEx = False
	If Not X_IsDocumentReady(oDoc) Then Exit Function
	If Not IsNull(vCustomTags) Then 
		If VarType(vCustomTags) = vbString Then
			vCustomTags = Array(vCustomTags)
		End If
		If IsArray(vCustomTags) Then 
			If IsNull( oDoc) Then
				Set oDoc = Document
			End If
			For Each sCustomTag In vCustomTags
				For Each oElement In oDoc.getElementsByTagName(sCustomTag)
					If Not X_IsBehaviorReady(oElement) Then Exit Function
				Next
			Next
		End If
	End If
	X_IsDocumentReadyEx = True
End Function


'===============================================================================
'@@X_IsProcPresented
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsProcPresented>
':����������:
'	������� ��������� ������� ������� ��� ��������� � ������, �������� � ���������
'   <b><i>sName</b></i>.
':���������:
'	sName - 
'       [in] ��� ���������.
':���������:
' 	���������� True, ���� ��������� � �������� ������ �������, ��� False - � 
'   ��������� ������.
':����������:
'   <b><i>��������!</b></i> ������� ����� �������� ��������� �� ������, ��������� 
'   �� ������ ���� �������.
':���������:
'   Function X_IsProcPresented ( 
'       sName [As String]
'   ) [As Boolean]
Function X_IsProcPresented( sName)
	Const ERR_NO_SUCH_FUNCTION = 5	' ��� ������ �� ���������� �������
	X_IsProcPresented = False
	' �������������� ������������ ������
	If 0 = StrComp( sName, "X_IsProcPresented", vbTextCompare) Then Exit Function
	On Error Resume Next
	GetRef  sName
	If ERR_NO_SUCH_FUNCTION = Err.number Then
		On Error Goto 0 
		Exit Function
	End if
	X_IsProcPresented = True
End Function


'===============================================================================
'@@X_SetComboBoxValue
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SetComboBoxValue>
':����������:
'	������� �������� � �������� SELECT ����� (OPTION) � �������� ������� (����������).
':���������:
'	oComboBox - 
'       [in] HTML-������� SELECT.
'	vVal - 
'       [in] ��������, ��������������� ����������� ������ (OPTION).
':���������:
' 	���������� ������ ������ ��������� ��� -1.
':���������:
'   Function X_SetComboBoxValue (
'       oComboBox [As IHTMLElement], 
'       vVal [As Variant]
'   ) [As Int]
Function X_SetComboBoxValue(oComboBox, vVal)
	X_SetComboBoxValue = X_SetComboBoxTypedValue(oComboBox, vVal, "")
End Function


'===============================================================================
'@@X_SetComboBoxTypedValue
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SetComboBoxTypedValue>
':����������:
'	������� �������� � �������� SELECT ����� (OPTION), ����� (��������) ��������
'   ������������ ����� ���������� ��������, ����������� ���������� <b><i>vVal</b></i>.
':���������:
'	oComboBox - 
'       [in] HTML-������� SELECT.
'	vVal - 
'       [in] ��������, ��������������� ����������� ������ (OPTION).
'	sTypeCast - 
'       [in] ��� ���������.
':���������:
' 	���������� ������ ������ ��������� ��� -1.
':����������:
'   ���� �������� ��������� <b><i>vVal</b></i> - Null, �� ��������� ������������ 
'   (�� ������ -1).<P/>
'   <b><i>��������!</b></i> ���� ������ �������, �� �� ����������� ��������� �����������
'   "Eval" (��� ����, ����� � �������� �������� ������ (OPTION) � �������� SELECT
'   ����� ���� �� �������� ��������� - ����� ����� ������ ��� ����������� ��������� 
'   SELECT).
':���������:
'   Function X_SetComboBoxTypedValue (
'       oComboBox [As IHTMLElement], 
'       vVal [As Variant], 
'       sTypeCast [As String]
'   ) [As Int]
Function X_SetComboBoxTypedValue(oComboBox, vVal, sTypeCast)
	Dim i
	Dim bIsEquals	' ������� ���������� ������� ���������
	
	XService.DoEvents	' ���������� ������� ��������� (���. �39381)
	X_SetComboBoxTypedValue = -1

	If IsNull(vVal) Then
		' � ���������� �� ����� ���� �������� Null, � ��� ����� �������� - ������ ���� �������� ���������
		oComboBox.SelectedIndex = -1
		Exit Function
	End If
	With oComboBox.options
		For i=0 to .length-1
			' Eval ��� .item(i).Value ������ ������, ��� � �������� option'� ����� ���� ������������ ���������
			If Len("" & sTypeCast)>0 And sTypeCast <> "CStr" And Len("" & .item(i).Value)>0 Then
				' ���� ������ ������� ���������� ����, �� ������� �������������� ��������
				' ���� ������� CStr, �� Eval ������ �� ����, �.�. combo ��������� �� ���������, � ���� ��������, ������ ��� ���������
				' ���� ������� CBool �� ���� ��������� ����������� "���������"
				If "CBool" = sTypeCast Then
					bIsEquals = CBool( iif(vVal,true,false)=Eval("CBool(" & .item(i).Value &")") )
				Else
					bIsEquals = CBool( Eval( sTypeCast & "(" & .item(i).Value & ")") = Eval(sTypeCast & "(" & vVal &")") )
				End If	
			Else
				' ����� ������� ��� ����
				bIsEquals = CBool( .item(i).Value = vVal )
			End If
			If bIsEquals Then
				oComboBox.SelectedIndex = i
				X_SetComboBoxTypedValue = i
				Exit Function
			End If
		Next
	End With 
End Function


'===============================================================================
'@@X_SetActiveXComboBoxValue
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SetActiveXComboBoxValue>
':����������:
'	������� ������������� �������� ����� � <LINK CROC.XComboBox, CROC.XComboBox />.
':���������:
'	oComboBox - 
'       [in] ��������� ���������� <LINK CROC.XComboBox, CROC.XComboBox />.
'	vVal - 
'       [in] ��������, ��������������� ��������� ������.
':���������:
' 	���������� ������ ������ ��������� ��� -1.
':���������:
'   Function X_SetActiveXComboBoxValue (
'       oComboBox [As CROC.XComboBox], 
'       vVal [As Variant]
'   ) [As Int]
Function X_SetActiveXComboBoxValue(oComboBox, vVal)
	' ������������� ������� �������
	X_SetActiveXComboBoxValue = -1
	If IsNull(vVal) Then
		oComboBox.Rows.SelectedID = vbNullString
	Else
		If Not oComboBox.Rows.GetRowByID(vVal) Is Nothing Then
			oComboBox.Rows.SelectedID = vVal
			X_SetActiveXComboBoxValue = oComboBox.Rows.Selected
		End If
	End If
End Function


'===============================================================================
'@@X_AddComboBoxItem
'<GROUP !!FUNCTIONS_x-utils><TITLE X_AddComboBoxItem>
':����������:
'	��������� ��������� ����� (OPTION) � �������� ������� (����������) � ������� SELECT.
':���������:
'	oComboBox - 
'       [in] HTML-������� SELECT.
'	vVal - 
'       [in] ��������, ��������������� ������������ ������ (OPTION).
'	sText - 
'       [in] ����� ������������ ������ (OPTION).
':���������:
'   Sub X_AddComboBoxItem (
'       oComboBox [As IHTMLElement], 
'       vVal [As Variant], 
'       sText [As String]
'   )
Sub X_AddComboBoxItem( oComboBox, vVal, sLabel)
	Dim oOption	' ������� OPTION
	Set oOption = window.document.createElement( "OPTION")
	oOption.appendChild window.document.createTextNode( sLabel)
	oOption.Value = vVal
	oComboBox.appendChild oOption
End Sub


'===============================================================================
'@@X_AddActiveXComboBoxItem
'<GROUP !!FUNCTIONS_x-utils><TITLE X_AddActiveXComboBoxItem>
':����������:
'	��������� ��������� ������� � <LINK CROC.XComboBox, CROC.XComboBox />.
':���������:
'	oComboBox - 
'       [in] ��������� ���������� <LINK CROC.XComboBox, CROC.XComboBox />.
'	vVal - 
'       [in] ��������, ��������������� ������������ ��������.
'	sText - 
'       [in] ����� ������������ ��������.
':���������:
'   Sub X_AddActiveXComboBoxItem (
'       oComboBox [As CROC.XComboBox], 
'       vVal [As Variant], 
'       sText [As String]
'   )
Sub X_AddActiveXComboBoxItem( oComboBox, vVal, sLabel)
	With oComboBox.columns
		If .Count=0 Then .Add "X_TEXT", "string"
	End With
	oComboBox.Rows.Add	Array(sLabel), CStr(vVal)
End Sub


'===============================================================================
'@@X_GetStringHash
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetStringHash>
':����������:
'	������� ��������� ��� ������.
':���������:
'	s - 
'       [in] ������.
':���������:
' 	��� ������.
':���������:
'   Function X_GetStringHash (s [As String]) [As String]
Function X_GetStringHash(s)
	X_GetStringHash = XService.GetMD5Hex(s)
End Function


'===============================================================================
'@@X_ClearListDataCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ClearListDataCache>
':����������:
'	��������� ������� ����� ���� ��� ��������� ������.
':���������:
'	sTypeName - 
'       [in] ������������ ���� (ds:type), � ���������� �������� ��������� ������.
'	sMetaName - 
'       [in] ������� ������.
'	vRestrictions - 
'       [in] URL �����������, ������������ POST-��������.
':����������:
'   �������� ��������� <b><i>vRestrictions</b></i> - ��� �������� RESTR ��������
'   x-list-loader.aspx. ����������� ������� X_CreateListLoaderRestrictions.
'   ���� � �������� �������� ��������� ���������� Null, �� ��������� ���� ��� ��� 
'   ������� ������. � ��������� ������, ��������� ������ ��� ��� ������� �����������.
':���������:
'   Sub X_ClearListDataCache (
'       sTypeName [As String], 
'       sMetaName [As String], 
'       vRestrictions [As Variant]
'   )
Sub X_ClearListDataCache(sTypeName, sMetaName, vRestrictions)
	Dim sFilePefix	' ����� ����� �����. ��� ����� ������������ �� ������ ������ �������� ��������
	sFilePefix = X_GetListCacheFileNameCommonPart(sTypeName, sMetaName, vRestrictions)
	internal_ClearDataCache sFilePefix
End Sub


'===============================================================================
'@@X_ClearCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ClearCache>
':����������:
'	��������� ������� ��� ����� �� �������� � ������������� ������� (� ��� �����
'   ����������, XSL, ������ �������, ������������� �������).
':���������:
'   Sub X_ClearCache ()
Sub X_ClearCache()
	internal_ClearDataCache "*"
End Sub


'===============================================================================
'@@X_ClearDataCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ClearDataCache>
':����������:
'	��������� ������� ��� ����� � ��������������� ������� (� ��� ����� ������� � ������
'   �������).
':���������:
'   Sub X_ClearDataCache ()
Sub X_ClearDataCache()
	internal_ClearDataCache "data."
End Sub


'===============================================================================
'@@X_ClearViewStateCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ClearViewStateCache>
':����������:
'	��������� ������� ��� ����� � ��������������� ���������������.
':���������:
'   Sub X_ClearViewStateCache ()
Sub X_ClearViewStateCache()
	internal_ClearDataCache "view."
End Sub


'==============================================================================
' ������� �� ����  �����, ������������ ������� ���������� � ��������� ������
'	[in] sFilePefix	- ����� ����� �����. ��� ����� ������������ �� ������ ������ �������� ��������
Sub internal_ClearDataCache(sFilePefix)
	Dim oFileSystemObject	' As Scripting.FileSystemObject
	Dim oSingleFile			' As Scripting.File - ��������� ����
	Dim sAppFolderName		' As String - ���� �� ��������
	
	Set oFileSystemObject =	XService.CreateObject("Scripting.FileSystemObject")
	sAppFolderName = XService.GetAppDataPath
	If oFileSystemObject.FolderExists(sAppFolderName) Then
		For Each oSingleFile in oFileSystemObject.GetFolder(sAppFolderName).Files
			If sFilePefix = "*" Or 1=InStr(1,oSingleFile.Name, sFilePefix, vbTextCompare) Then
				oSingleFile.Delete true
			End If
		Next
	End If
End Sub


'==============================================================================
Sub X_SaveViewStateCache(sName, vData)
	XService.SetUserData "view." & sName, vData
End Sub


'==============================================================================
Sub X_SaveDataCache(sName, vData)
	XService.SetUserData "data." & sName, vData
End Sub


'==============================================================================
Function X_GetViewStateCache(sName, vData)
	X_GetViewStateCache = XService.GetUserData( "view." & sName, vData)
End Function


'==============================================================================
Function X_GetDataCache(sName, vData)
	X_GetDataCache = XService.GetUserData( "data." & sName, vData)
End Function


'===============================================================================
'@@X_GetListCacheFileNameCommonPart
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetListCacheFileNameCommonPart>
':����������:
'	������� ��������� ��� ����� ��� �������� ����.
':���������:
'	sTypeName - 
'       [in] ������������ ���� (ds:type), � ���������� �������� ��������� ������.
'	sMetaName - 
'       [in] ������� ������.
'	vRestrictions - 
'       [in] URL �����������, ������������ POST-��������.
':����������:
'   �������� ��������� <b><i>vRestrictions</b></i> - ��� �������� RESTR ��������
'   x-list-loader.aspx. ����������� ������� X_CreateListLoaderRestrictions.
'   ���� � �������� �������� ��������� ���������� Null, �� ��� ��� �� ��������� 
'   � ���������� �����.
':���������:
'   Function X_GetListCacheFileNameCommonPart (
'       sTypeName [As String], 
'       sMetaName [As String], 
'       vRestrictions [As Variant]
'   ) [As String]
Function X_GetListCacheFileNameCommonPart(sTypeName, sMetaName, vRestrictions)
	X_GetListCacheFileNameCommonPart = "XSLD." & sTypeName & "." & sMetaName & "."
	If Not IsNull(vRestrictions) Then
		' �� ��������� ���������� vRestrictions ����������� MD5-��� - �� ��� ����
		' �� ���������� �.�. ��������� ���� ��������-�������� "VALUEOBJECTID=":
		Dim sRestrictions
		sRestrictions = internal_getPartlyRestrictions("" & vRestrictions,null,"")
		If Len(sRestrictions) > 0 Then X_GetListCacheFileNameCommonPart = X_GetListCacheFileNameCommonPart & X_GetStringHash(sRestrictions) & "." 
	End If
End Function


'===============================================================================
'@@X_GetListData
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetListData>
':����������:
'	������� ���������� ������ ��� ���������� ����������� ������ (�������� SELECT).
':���������:
'	nUseCache - 
'       [in] ������� ������������� �����������
'       (<LINK CACHE_BEHAVIOR_nnnn, CACHE_BEHAVIOR_nnnn />).
'	sTypeName - 
'       [in] ������������ ���� (ds:type), � ���������� �������� ��������� ������.
'	sMetaName - 
'       [in] ������� ������.
'	sRestrictions - 
'       [in] URL �����������, ������������ POST-��������.
'	sSaltExpression - 
'       [in] �������������� �������� ��� ����������� (VBS-���, ������������ ���������).
':����������:
'   �������� ��������� <b><i>sRestrictions</b></i> - ��� �������� RESTR ��������
'   x-list-loader.aspx. ����������� ������� X_CreateListLoaderRestrictions.
':���������:
'   Function X_GetListData (
'       nUseCache [As Int],
'       sTypeName [As String], 
'       sMetaName [As String], 
'       ByVal sRestrictions [As String],
'       ByVal sSaltExpression [As String] 
'   ) [As IXMLDOMElement]
Function X_GetListData(nUseCache, sTypeName, sMetaName, ByVal sRestrictions, ByVal sSaltExpression)
	Dim sDataName	' ��� ����� � �������
	Dim bCached		' ������� ������� �������������� ������
	Dim oData		' �������������� ������
	Dim oDataEntry	' ������� �������������� ������
	Dim sFilePefix	' ����� ����� �����. ��� ����� ������������ �� ������ ������ �������� ��������
	
	Dim sPartlyRestrictions	' ������ ���������� �����������, ��� VALUEOBJECTID
	Dim vPartValueObjectIDs	' �������� ����������� ����������� VALUEOBJECTID
	Dim sQueryValueObjectID	' ... � XPath-��������� ��� ������ VALUEOBJECTID � ����
	
	sRestrictions = "" & sRestrictions
	If CACHE_BEHAVIOR_NOT_USE = nUseCache Then
		Set X_GetListData = X_GetListDataFromServer(sTypeName, sMetaName, sRestrictions)
	Else		
		If Not hasValue(sSaltExpression) Then
			sSaltExpression = "0"
		End If
		sFilePefix = X_GetListCacheFileNameCommonPart(sTypeName, sMetaName, sRestrictions)
		sDataName =  sFilePefix & Eval(sSaltExpression)
		sPartlyRestrictions = internal_getPartlyRestrictions(sRestrictions,null,vPartValueObjectIDs)
		
		' �������� ������������ ������
		If CACHE_BEHAVIOR_USE = nUseCache Then
			bCached = X_GetDataCache(sDataName, oData)
		Else
			bCached = False
		End If	
		
		If bCached Then
			' ���� ���� ���, �� ��������� ������� ����� � �����. �������������, �, ���� 
			' ��������� VALUEOBJECTID, ���� �����. ������ � ����� id (���� ����� ���,
			' �� ���� �� ���� ���������, �.�. ����� ��������� �����)
			sQueryValueObjectID = ""
			If hasValue(vPartValueObjectIDs) Then sQueryValueObjectID = ".//*[@id='" & vPartValueObjectIDs(0) & "']"
		
			For Each oDataEntry in oData.selectNodes("*")
				If oDataEntry.getAttribute("restr") = sPartlyRestrictions Then
					bCached = True
					If Len(sQueryValueObjectID) > 0 Then 
						bCached = ( oDataEntry.selectNodes(sQueryValueObjectID).length > 0 )
						If Not bCached Then	oData.removeChild oDataEntry
					End If
					If bCached Then
						Set X_GetListData = oDataEntry.FirstChild
						Exit Function
					End If
				End If
			Next
		Else
			' ������ ��� ���� ��� ������� ��������� sTypeName, sMetaName, sRestrictions
			internal_ClearDataCache sFilePefix
			' ������������ ����� ���
			Set oData = XService.XmlGetDocument()
			Set oData = oData.appendChild( oData.CreateElement("root") )
		End If
		
		' �������� ������ � �������, ������ � ���:
		Set oDataEntry = X_GetListDataFromServer( sTypeName, sMetaName, sRestrictions )
		With oData.AppendChild( oData.ownerDocument.createElement("entry") )
			' NB! ��� ����� �������������� ������ ��������� ��� �����������, ����� VALUEOBJECTID!
			.SetAttribute "restr", sPartlyRestrictions
			.AppendChild oDataEntry
		End With
		' ��������� �������� ������� � ���������� ����
		X_SaveDataCache sDataName, oData
		Set X_GetListData = oDataEntry
	End If	
End Function


'===============================================================================
'@@X_LoadComboBox
'<GROUP !!FUNCTIONS_x-utils><TITLE X_LoadComboBox>
':����������:
'	������� ��������� ���������� ������ (������� SELECT) �� ��������� ������, 
'   ������������� � ����������, ��� ������������� �����������.
':���������:
'	oComboBox - 
'       [in] ���������� ������ (������� SELECT).
'	sTypeName - 
'       [in] ������������ ���� (ds:type), � ���������� �������� ��������� ������.
'	sMetaName - 
'       [in] ������� ������.
'	sUserRestrictions - 
'       [in] URL �����������, ������������ POST-��������.
'	sValueObjectIDs - 
'       [in] ������ ��������������� ��������, ������� ������ ������� � �������.
':����������:
'   �������� ��������� <b><i>sUserRestrictions</b></i> - ��� �������� RESTR ��������
'   x-list-loader.aspx.<P/>
'   �������� ��������� <b><i>sValueObjectIDs</b></i> - ��� �������� VALUEOBJECTID 
'   �������� x-list-loader.aspx.
':���������:
'   Function X_LoadComboBox (
'       oComboBox [As IHTMLElement],
'       sTypeName [As String], 
'       sMetaName [As String], 
'       sUserRestrictions [As String],
'       sValueObjectIDs [As String] 
'   ) [As Boolean]
Function X_LoadComboBox(oComboBox, sTypeName, sMetaName, sUserRestrictions, sValueObjectIDs)
	X_LoadComboBox = X_LoadComboBoxUseCache( CACHE_BEHAVIOR_NOT_USE, oComboBox, sTypeName, sMetaName, sUserRestrictions, Null,  sValueObjectIDs, Empty )
End Function


'===============================================================================
'@@X_LoadComboBoxUseCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_LoadComboBoxUseCache>
':����������:
'	������� ��������� ���������� ������ (������� SELECT) �� ��������� ������, 
'   ������������� � ����������.
':���������:
'	nUseCache - 
'       [in] ������� ������������� �����������
'       (<LINK CACHE_BEHAVIOR_nnnn, CACHE_BEHAVIOR_nnnn />).
'	oComboBox - 
'       [in] ���������� ������ (������� SELECT).
'	sTypeName - 
'       [in] ������������ ���� (ds:type), � ���������� �������� ��������� ������.
'	sMetaName - 
'       [in] ������� ������.
'	sUserRestrictions - 
'       [in] URL �����������, ������������ POST-��������.
'	sUrlArguments - 
'       [in] �������������� ��������� ����������.
'	sValueObjectIDs - 
'       [in] ������ ��������������� ��������, ������� ������ ������� � �������.
'	sSaltExpression - 
'       [in] �������������� �������� ��� ����������� (VBS-���, ������������ ���������).
':����������:
'   �������� ��������� <b><i>sUserRestrictions</b></i> - ��� �������� RESTR ��������
'   x-list-loader.aspx.<P/>
'   �������� ��������� <b><i>sValueObjectIDs</b></i> - ��� �������� VALUEOBJECTID 
'   �������� x-list-loader.aspx.
':���������:
'	���������� True, ���� ������ ��� ��������� ��������� �������� MAXROWS, � False � 
'   ��������� ������.
':���������:
'   Function X_LoadComboBoxUseCache (
'       nUseCache [As Int],
'       oComboBox [As IHTMLElement],
'       sTypeName [As String], 
'       sMetaName [As String], 
'       sUserRestrictions [As String],
'       sUrlArguments [As String],
'       sValueObjectIDs [As String],
'       sSaltExpression [As String],
'   ) [As Boolean]
Function X_LoadComboBoxUseCache(nUseCache, oComboBox, sTypeName, sMetaName, sUserRestrictions, sUrlArguments,  sValueObjectIDs, sSaltExpression)
	X_LoadComboBoxUseCache = X_FillComboBox( oComboBox, X_GetListData(nUseCache, sTypeName, sMetaName, X_CreateListLoaderRestrictions(sUserRestrictions, sUrlArguments, sValueObjectIDs), sSaltExpression) )
End Function


'===============================================================================
'@@X_LoadActiveXComboBoxUseCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_LoadActiveXComboBoxUseCache>
':����������:
'	������� ��������� ���������� ������ ActiveX (<LINK CROC.XComboBox, CROC.XComboBox />)
'   ������� ������, ������������� � ����������.
':���������:
'	nUseCache - 
'       [in] ������� ������������� �����������
'       (<LINK CACHE_BEHAVIOR_nnnn, CACHE_BEHAVIOR_nnnn />).
'	oComboBox - 
'       [in] ���������� ������ ActiveX (<LINK CROC.XComboBox, CROC.XComboBox />).
'	sTypeName - 
'       [in] ������������ ���� (ds:type), � ���������� �������� ��������� ������.
'	sMetaName - 
'       [in] ������� ������.
'	sUserRestrictions - 
'       [in] URL �����������, ������������ POST-��������.
'	sUrlArguments - 
'       [in] �������������� ��������� ����������.
'	sValueObjectIDs - 
'       [in] ������ ��������������� ��������, ������� ������ ������� � �������.
'	sSaltExpression - 
'       [in] �������������� �������� ��� ����������� (VBS-���, ������������ ���������).
':����������:
'   �������� ��������� <b><i>sUserRestrictions</b></i> - ��� �������� RESTR ��������
'   x-list-loader.aspx.<P/>
'   �������� ��������� <b><i>sValueObjectIDs</b></i> - ��� �������� VALUEOBJECTID 
'   �������� x-list-loader.aspx.
':���������:
'   Function X_LoadActiveXComboBoxUseCache (
'       nUseCache [As Int],
'       oComboBox [As CROC.XComboBox],
'       sTypeName [As String], 
'       sMetaName [As String], 
'       sUserRestrictions [As String],
'       sUrlArguments [As String],
'       sValueObjectIDs [As String],
'       sSaltExpression [As String],
'   ) [As Boolean]
Function X_LoadActiveXComboBoxUseCache(nUseCache, oComboBox, sTypeName, sMetaName, sUserRestrictions, sUrlArguments, sValueObjectIDs, sSaltExpression)
	Dim oListData 		' As IXMLDOMElement - ������ ������
	Dim oXmlDoc 		' As IXMLDOMDocument - XmlFillList �������� ������ � XmlDomDocument
	Dim bHasMoreRows	' As Boolean - ������� ������� � �� ������ ������, ��� ��������
	Dim vMaxRows			' As Variant - �������� �������� maxrows xml-���� LIST
	
	bHasMoreRows = False
	Set oListData = X_GetListData(nUseCache, sTypeName, sMetaName, X_CreateListLoaderRestrictions(sUserRestrictions, sUrlArguments,  sValueObjectIDs), sSaltExpression)
	vMaxRows = oListData.getAttribute("maxrows")
	If Not IsNull(vMaxRows) Then
		bHasMoreRows = CLng(vMaxRows) < CLng(oListData.selectNodes("RS/R").length)
	End If
	
	Set oXmlDoc = oListData.ownerDocument.cloneNode(false)
	oXmlDoc.appendChild oListData
	oComboBox.XmlFillList oXmlDoc, True
	X_LoadActiveXComboBoxUseCache = bHasMoreRows
End Function


'===============================================================================
'@@X_LoadXListViewUseCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_LoadXListViewUseCache>
':����������:
'	������� ��������� ������ ActiveX (<LINK CROC.XListView, CROC.XListView />)
'   ������� ������, ������������� � ����������.
':���������:
'	nUseCache - 
'       [in] ������� ������������� �����������
'       (<LINK CACHE_BEHAVIOR_nnnn, CACHE_BEHAVIOR_nnnn />).
'	oXListView - 
'       [in] ������ ActiveX (<LINK CROC.XListView, CROC.XListView />).
'	sTypeName - 
'       [in] ������������ ���� (ds:type), � ���������� �������� ��������� ������.
'	sMetaName - 
'       [in] ������� ������.
'	sUserRestrictions - 
'       [in] URL �����������, ������������ POST-��������.
'	sUrlArguments - 
'       [in] �������������� ��������� ����������.
'	sValueObjectIDs - 
'       [in] ������ ��������������� ��������, ������� ������ ������� � �������.
'	sSaltExpression - 
'       [in] �������������� �������� ��� ����������� (VBS-���, ������������ ���������).
':����������:
'   �������� ��������� <b><i>sUserRestrictions</b></i> - ��� �������� RESTR ��������
'   x-list-loader.aspx.<P/>
'   �������� ��������� <b><i>sValueObjectIDs</b></i> - ��� �������� VALUEOBJECTID 
'   �������� x-list-loader.aspx.
':���������:
'   Function X_LoadXListViewUseCache (
'       nUseCache [As Int],
'       oXListView [As CROC.XListView],
'       sTypeName [As String], 
'       sMetaName [As String], 
'       sUserRestrictions [As String],
'       sUrlArguments [As String],
'       sValueObjectIDs [As String],
'       sSaltExpression [As String],
'   ) [As Boolean]
Function X_LoadXListViewUseCache(nUseCache, oXListView, sTypeName, sMetaName, sUserRestrictions, sUrlArguments, sValueObjectIDs, sSaltExpression)
	' �.�. ���������� CROC.XComboBox � CROC.XListView ����������
	X_LoadXListViewUseCache = X_LoadActiveXComboBoxUseCache( nUseCache, oXListView, sTypeName, sMetaName, sUserRestrictions, sUrlArguments, sValueObjectIDs, sSaltExpression )
End Function


'===============================================================================
'@@X_LoadActiveXComboBox
'<GROUP !!FUNCTIONS_x-utils><TITLE X_LoadActiveXComboBox>
':����������:
'	������� ��������� ���������� ������ ActiveX (<LINK CROC.XComboBox, CROC.XComboBox />)
'   ������� ������, ������������� � ����������, ��� ������������� �����������.
':���������:
'	oComboBox - 
'       [in] ���������� ������ ActiveX (<LINK CROC.XComboBox, CROC.XComboBox />).
'	sTypeName - 
'       [in] ������������ ���� (ds:type), � ���������� �������� ��������� ������.
'	sMetaName - 
'       [in] ������� ������.
'	sUserRestrictions - 
'       [in] URL �����������, ������������ POST-��������.
'	sValueObjectIDs - 
'       [in] ������ ��������������� ��������, ������� ������ ������� � �������.
':����������:
'   �������� ��������� <b><i>sUserRestrictions</b></i> - ��� �������� RESTR ��������
'   x-list-loader.aspx.<P/>
'   �������� ��������� <b><i>sValueObjectIDs</b></i> - ��� �������� VALUEOBJECTID 
'   �������� x-list-loader.aspx.
':���������:
'   Function X_LoadActiveXComboBox (
'       oComboBox [As CROC.XComboBox],
'       sTypeName [As String], 
'       sMetaName [As String], 
'       sUserRestrictions [As String],
'       sValueObjectIDs [As String]
'   ) [As Boolean]
Function X_LoadActiveXComboBox(oComboBox, sTypeName, sMetaName, sUserRestrictions, sValueObjectIDs)
	X_LoadActiveXComboBox = X_LoadActiveXComboBoxUseCache( CACHE_BEHAVIOR_NOT_USE,oComboBox, sTypeName, sMetaName, sUserRestrictions, Null, sValueObjectIDs, Empty )
End Function


'===============================================================================
'@@X_GetListDataFromServer
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetListDataFromServer>
':����������:
'	������� ����������� ������ � ���������� ����������� ������ � �������.
':���������:
'	sTypeName - 
'       [in] ������������ ���� (ds:type), � ���������� �������� ��������� ������.
'	sMetaName - 
'       [in] ������� ������.
'	sRestrictions - 
'       [in] URL �����������, ������������ POST-��������.
':����������:
'   �������� ��������� <b><i>sRestrictions</b></i> - ��� �������� RESTR ��������
'   x-list-loader.aspx. ����������� ������� ������� X_CreateListLoaderRestrictions.
':���������:
'	���������� IXMLDOMElement �� ������� �������� (� ������� x-list-loader.aspx).
':���������:
'   Function X_GetListDataFromServer (
'       sTypeName [As String], 
'       sMetaName [As String], 
'       ByVal sRestrictions [As String]
'   ) [As IXMLDOMElement]
Function X_GetListDataFromServer(sTypeName, sMetaName,ByVal sRestrictions)
	Set X_GetListDataFromServer = XService.XMLGetDocument( "x-list-loader.aspx?tm=" & XService.NewGuidString & "&OT=" & sTypeName & "&METANAME=" & sMetaname, sRestrictions ).documentElement
End Function


'===============================================================================
'@@X_CreateListLoaderRestrictions
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CreateListLoaderRestrictions>
':����������:
'	������� ������� ������ ���������� ��� �������� ����������� ������.
':���������:
'	sUserRestrictions - 
'       [in] URL �����������, ������������ POST-��������.
'	sUrlArguments - 
'       [in] �������������� ��������� ����������.
'	sValueObjectIDs - 
'       [in] ������ ��������������� ��������, ������� ������ ������� � �������.
':����������:
'   �������� ��������� <b><i>sUserRestrictions</b></i> - ��� �������� RESTR ��������
'   x-list-loader.aspx.<P/>
'   �������� ��������� <b><i>sValueObjectIDs</b></i> - ��� �������� VALUEOBJECTID 
'   �������� x-list-loader.aspx.
':���������:
'   Function X_CreateListLoaderRestrictions (
'       sUserRestrictions [As String],
'       sUrlArguments [As String],
'       sValueObjectIDs [As String]
'   ) [As String]
Function X_CreateListLoaderRestrictions(sUserRestrictions, sUrlArguments, sValueObjectIDs)
	X_CreateListLoaderRestrictions = "WHERE=" & XService.UrlEncode( sUserRestrictions )
	If Not (IsNull(sValueObjectIDs) Or IsEmpty(sValueObjectIDs)) Then
		X_CreateListLoaderRestrictions = X_CreateListLoaderRestrictions & "&VALUEOBJECTID=" & XService.UrlEncode(sValueObjectIDs)
	End If
	If Not (IsNull(sUrlArguments) Or IsEmpty(sUrlArguments)) Then
		If 0<Len(sUrlArguments) Then
			If "&"=MID(sUrlArguments,1,1) Then
				X_CreateListLoaderRestrictions = X_CreateListLoaderRestrictions & sUrlArguments
			Else
				X_CreateListLoaderRestrictions = X_CreateListLoaderRestrictions & "&" & sUrlArguments
			End If
		End If
	End If
End Function

'===============================================================================
' ���������� ��������� ��������� ��������� �����������: �� �������� ������ 
' ���������� ����������� ����������� ��� ���� "��������=��������" � ��������
' ������������� ���������. �� ���������, ���� ������������ ��������� �� ������ 
' (null, ������ ������, vbEmpty), ����������� �������� VALUEOBJECTID.
' ���������:
'	sRestrictions	 - [in] ������ ���������� �����������;
'	sUrlRestrictions - [in] ������������ ���������, ������������ �� ������;
'						���� �� ������, �� �� ��������� ����������� VALUEOBJECTID;
'	vRemovedParts	 - [out] ������ �� ���������� ������������ ���������.
' ����������:
'	������ ���������� �.�. ������������ X_CreateListLoaderRestrictions.
' ���������:
'   Sub internal_getPartlyRestrictions( 
'       sRestrictions [As String],
'       sUrlRestrictions [As String],
'		vRemovedParts [As Array]
'   ) [As String]
Function internal_getPartlyRestrictions(sRestrictions, sRemovedParamName, ByRef vRemovedParts)
	Dim sResult			' ��������� �������
	Dim nParamNameLen	' ����� ������������ ���������
	Dim sPart			' ���������� ����� - ���� ���� "��������=��������"

	If Not hasValue(sRemovedParamName) Then sRemovedParamName = "VALUEOBJECTID"
	If Right(sRemovedParamName,1) <> "=" Then sRemovedParamName = sRemovedParamName & "="
	nParamNameLen = Len(sRemovedParamName)
	vRemovedParts = "" 
	sResult = ""
	
	For Each sPart in splitString(sRestrictions,"&")
		If UCase(Left(sPart,nParamNameLen)) <> sRemovedParamName Then 
			sResult = sResult & sPart & "&"
		Else
			vRemovedParts = vRemovedParts & sPart & "&" 
		End If
	Next
	If Right(sResult,1) = "&" Then sResult = Left(sResult,Len(sResult)-1)
	If Len(vRemovedParts) > 0 Then 
		vRemovedParts = Left(vRemovedParts,Len(vRemovedParts)-1)
		vRemovedParts = splitString( Replace(vRemovedParts,sRemovedParamName,""), "&" )
	End If
	internal_getPartlyRestrictions = sResult
End Function


'===============================================================================
'@@X_FillComboBox
'<GROUP !!FUNCTIONS_x-utils><TITLE X_FillComboBox>
':����������:
'	������� ��������� ���������� ������ (������� SELECT) ���������� �� IXMLDOMElement.
':���������:
'	oComboBox - 
'       [in] ���������� ������ (������� SELECT).
'	oList - 
'       [in] IXMLDOMElement �� ������� �������� � ������� x-list-loader.aspx 
'       (���� <b>LIST</b>).
':���������:
'	���������� True, ���� � ������ ������� ������, ��� ������� � �������� <b>maxrows</b> 
'   �������� <b>LIST</b>, � False � ��������� ������.
':���������:
'   Function X_FillComboBox (
'       oComboBox [As IHTMLElement],
'       oList [As IXMLDOMElement],
'   ) [As Boolean]
Function X_FillComboBox(oComboBox, oList)
	Dim oRow				' As XMLDOMElement - ������ ������ (���� R)
	Dim nRowCount			' As Integer - ����������� �����
	Dim bHasMoreRows		' As Boolean - ������� ������� � �� ������ ������, ��� ��������
	Dim vMaxRows			' As Variant - �������� �������� maxrows xml-���� LIST
	
	bHasMoreRows = False
	nRowCount = 0
	For Each oRow In oList.selectNodes( "RS/R")
		X_AddComboBoxItem oComboBox, oRow.getAttribute("id"), X_GetChildValueDef( oRow, "F[1]", "")
		nRowCount = nRowCount + 1
	Next
	vMaxRows = oList.getAttribute("maxrows")
	If Not IsNull(vMaxRows) Then
		vMaxRows = CLng(vMaxRows)
		bHasMoreRows = vMaxRows < nRowCount
	End If
	X_FillComboBox = bHasMoreRows
End Function


'===============================================================================
'@@SelectFromTreeDialogClass
'<GROUP !!CLASSES_x-utils><TITLE SelectFromTreeDialogClass>
':����������:	
'	�����, ������������ ��� �������� ���������� � � �� ����������� ����
'	x-select-from-tree (����� �� ������).
'
'@@!!MEMBERTYPE_Methods_SelectFromTreeDialogClass
'<GROUP SelectFromTreeDialogClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_SelectFromTreeDialogClass
'<GROUP SelectFromTreeDialogClass><TITLE ��������>
Class SelectFromTreeDialogClass

	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.Metaname
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE Metaname>
	':����������:	
	'	��� ��������� (<b>i:objects-tree-selector</b>) � ����������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Metaname [As String]
	Public Metaname
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.LoaderParams
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE LoaderParams>
	':����������:	
	'	������ ���������� ��� <b>i:data-source</b>. ������ �� ��� Param1=Value1, 
	'   ����������� �������� "&".<P/>
	'   ��� ��������� ������ ���������� ����� ������������ ����� 
	'   QueryStringParamCollectionBuilderClass.
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public LoaderParams [As String]
	Public LoaderParams

	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.InitialPath
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE InitialPath>
	':����������:	
	'	���� �� ����, �� ������� ������ ���� ���������� ����� ��� ������, �� �����.<P/>
	'   C������ �� ��� ���� "��� ����"|"ID ����", ����������� �������� "|".
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public InitialPath [As String]
	Public InitialPath		
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.InitialSelection
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE InitialSelection>
	':����������:	
	'	������ �����, � ������� ��������������� ���� ����� �� ������ ��������, � ������� 
	'   <LINK CROC.XTreeView, CROC.XTreeView /> (��. x-net-interop-schema.xml).
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public InitialSelection [As IXMLDOMElement]
	Public InitialSelection	 
							
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.UrlArguments
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE UrlArguments>
	':����������:	
	'	�������������� ��������� � ��������.
	':����������:	
	'   ���������, ���������������� ������ ������ ��������, �������� � ������������ 
	'   (<b>objects-tree-selector</b>). ������ ��������� ����� ���� ����� ������ ����� 
	'   URL (UrlArguments). ������ ��������, �������� ����� ��������, ����� ������� 
	'   ���������.<P/>
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public UrlArguments [As QueryString]
	Public UrlArguments	
	 
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.SelectionMode
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE SelectionMode>
	':����������:	
	'	����� ������ ������: TSM_LEAFNODE, TSM_LEAFNODES, TSM_ANYNODE, TSM_ANYNODES. 
	'   �������� URL: <b>selection-mode</b>.
	':����������:	
	'   ����� ���� �� �����. � ���� ������ ����� ������������ ����� ���������.
	':���������:	
	'	Public SelectionMode [As Int]
	Public SelectionMode			 
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.SuitableSelectionModes
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE SuitableSelectionModes>
	':����������:	
	'	������ ���������� ������� ��� ������, ����� �� ������ �������� ��������
	'   <LINK SelectFromTreeDialogClass.SelectionMode, SelectionMode /> � ����� 
	'   �������� ������������ �� ����������� - �� ������ ���� ���� �� �������� �����. 
	':����������:	
	'   ����� ���� �� �����. � ���� ������ ����� ������������ ����� ���������.
	':���������:	
	'	Public SuitableSelectionModes [As Array]
	Public SuitableSelectionModes	 

	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.SelectableTypes
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE SelectableTypes>
	':����������:	
	'	���� �����, ������� ����� �������. �������� URL: <b>selectable-types</b>. 
	':���������:	
	'	Public SelectableTypes [As String]
	Public SelectableTypes		
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.SelectionCanBeEmpty
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE SelectionCanBeEmpty>
	':����������:	
	'	������� ������������ ������� ������. �������� URL: <b>selection-can-be-empty</b>. 
	'   ��������: 1 � 0.  
	':���������:	
	'	Public SelectionCanBeEmpty [As Boolean]
	Public SelectionCanBeEmpty	
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.SelectionEmptyMsg
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE SelectionEmptyMsg>
	':����������:	
	'	���������, ���������� ������������, � ������, ���� �� �� ������ �� ������ ���� 
	'   � �������� <LINK SelectFromTreeDialogClass.SelectionCanBeEmpty, SelectionCanBeEmpty /> 
	'   �� ��������� �������� True. �������� URL: <b>selection-empty-msg</b>. 
	':���������:	
	'	Public SelectionEmptyMsg [As String]
	Public SelectionEmptyMsg	 
	
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE ReturnValue>
	':����������:	
	'	������� ������. ��������� ��������: True - ���� ������ ������ <b>OK</b>,
	'   False - ���� ������ ������ <b>������</b>. 
	':���������:	
	'	Public ReturnValue [As Boolean]
	Public ReturnValue		
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.Selection
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE Selection>
	':����������:	
	'	������ �����, � ������� ���������� ���� (��� ������ �������������� ������),
	'   � ������� <LINK CROC.XTreeView, CROC.XTreeView /> (��. x-net-interop-schema.xml). 
	':���������:	
	'	Public Selection [As IXMLDOMElement]
	Public Selection		
							
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.Path
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE Path>
	':����������:	
	'	���� �� ����, �� ������� ��� ����� ��� ������� �� ������ <b>OK</b> � 
	'   ���������� ����, �� �����. 
	':���������:	
	'	Public Path [As String]
	Public Path				 
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.UserData
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE UserData>
	':����������:	
	'	������, ������������� ���������������� ������������ � ���������� ����. 
	':���������:	
	'	Public UserData [As Variant]
	Public UserData			 

	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.ExcludeNodes
	'<GROUP !!MEMBERTYPE_Properties_SelectFromTreeDialogClass><TITLE ExcludeNodes>
	':����������:	
	'	������ �� ������� ����������� �� �������� ����� � �������: 
	'	������������������ ��� <��� �������> - <������������� �������>, 
	'	����������� �������� ������������ ����� (|); 
	'	��� � ������������� ������ ���� ����� ����������� �������� ������������ �����
	':���������:	
	'	Public ExcludeNodes [As String]
	Public ExcludeNodes

	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.GetRightsCache
	'<GROUP !!MEMBERTYPE_Methods_SelectFromTreeDialogClass><TITLE GetRightsCache>
	':����������:	
	'	������� ���������� ���������� ���������� ��������� ���� ����, 
	'   ObjectRightsCacheClass.
	':���������:
	'	Public Function GetRightsCache [As ObjectRightsCacheClass]
	Public Function GetRightsCache
		Set GetRightsCache = X_RightsCache()
	End Function

	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		Set InitialSelection = Nothing
		Set UrlArguments = X_GetEmptyQueryString
	End Sub
	
	'------------------------------------------------------------------------------
	'@@SelectFromTreeDialogClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SelectFromTreeDialogClass><TITLE Self>
	':����������:	
	'	������� ���������� ������ �� ������� ��������� ������.
	':���������:
	'	Public Function Self [As SelectFromTreeDialogClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@SelectFromTreeDialogClass_Show
'<GROUP !!FUNCTIONS_x-utils><TITLE SelectFromTreeDialogClass_Show>
':����������:
'	������� ��������� ���������� ���� ������ �� ������.
':���������:
'	oSelectFromTreeDialog - 
'       [in] ��������� SelectFromTreeDialogClass.
':���������:
' 	���������� True, ���� �������� �������, � False - � ��������� ������.
':����������:
'	������� �������� �� ������ SelectFromTreeDialogClass ��� ����, ����� �� 
'	����������� ���� ��������� ������� (��-�� ������ � VBScript-runtime, 
'	���������� � "stack overflow at line 0").
':���������:
'   Function SelectFromTreeDialogClass_Show ( 
'       oSelectFromTreeDialog [As SelectFromTreeDialogClass]
'   ) [As Boolean]
Function SelectFromTreeDialogClass_Show(oSelectFromTreeDialog)
	With oSelectFromTreeDialog
		If Not hasValue(.MetaName) Then
			Err.Raise -1, "SelectFromTreeDialogClass_Show", "�� ����� ������������ ��������: sMetaName - ������� i:objects-tree"
		End If
		If IsEmpty(.SelectionMode) Then
			.SelectionMode = .UrlArguments.GetValue("selection-mode", Empty)
		End If
		If IsEmpty(.SelectableTypes) Then
			.SelectableTypes = .UrlArguments.GetValue("selectable-types", Empty)
		End If
		If IsEmpty(.SelectionCanBeEmpty) Then
			.SelectionCanBeEmpty = .UrlArguments.GetValue("selection-can-be-empty", Empty)
			If Not IsEmpty(.SelectionCanBeEmpty) Then
				.SelectionCanBeEmpty = CBool(CStr(.SelectionCanBeEmpty)="1")
			End If
		End If
		If IsEmpty(.SelectionEmptyMsg) Then
			.SelectionEmptyMsg = .UrlArguments.GetValue("selection-empty-msg", Empty)
		End If
		Set .Selection = Nothing
		.Path = Empty
		.UserData = Empty
		.ReturnValue = (True = X_ShowModalDialog("x-select-from-tree.aspx?METANAME=" & .MetaName, oSelectFromTreeDialog))
		SelectFromTreeDialogClass_Show = .ReturnValue
	End With
End Function


'===============================================================================
'@@X_SelectFromTree
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SelectFromTree>
':����������:
'	������� ���������� ����� �� ������ (x-selectfromtree.htm) � ������� 
'   ���������� ������ SelectFromTreeDialogClass.
':���������:
'	sMetaName - 
'       [in] ��� ��������� � ����������.
'	sInitPath - 
'       [in] ���� � ����, �� ������� ������ ���� ���������� ����� ��� ������������� 
'       ���������� ������ �� �������� (���� ����������� �� ���� � �����, ������� �� 
'       ��� ���� "<��� ����>;<id ����>", ����������� ������ � �������).
'	sParams - 
'       [in] ������ ���������� ��� ��������� ������, ��������� �� ��� "Param1=Value1", 
'       ����������� �������� "&" (��� ��������� ������ ���������� ����� ������������ 
'       ����� QueryStringParamCollectionBuilderClass).
'	sAddUrl - 
'       [in] �������������� ���������, ������������ � URL ���������� ������ � 
'       �������� x-tree.aspx.
'	oSelected - 
'       [in] c����� �����, � ������� ��������������� check ����� �� ������ �������� �
'       ���� XML.
':���������:
' 	���������� ��������� ������ SelectFromTreeDialogClass. 
':���������:
'   Function X_SelectFromTree(
'       byval sMetaName [As String], 
'       sInitPath [As String], 
'       sParams [As String], 
'       sAddUrl [As String], 
'       oSelected [As IXMLDOMElement] 
'   ) [As SelectFromTreeDialogClass]
Function X_SelectFromTree(byval sMetaName, sInitPath, sParams, sAddUrl, oSelected)
	With New SelectFromTreeDialogClass
		.Metaname = sMetaName
		.InitialPath = sInitPath
		.LoaderParams = sParams
		Set .InitialSelection = ToObject(oSelected)
		If Len("" & sAddUrl) > 0 Then
			.UrlArguments.QueryString = sAddUrl
		End If
		SelectFromTreeDialogClass_Show .Self
		Set X_SelectFromTree = .Self
	End With
End Function


'===============================================================================
'@@ListSelectEventArgsClass
'<GROUP !!CLASSES_x-utils><TITLE ListSelectEventArgsClass>
':����������:	
'	��������� ������� OK (������� <b>OK</b> � ������ ������) � ������ ������
'	(x-list-page.vbs/x-list-xml.vbs).
'
'@@!!MEMBERTYPE_Methods_ListSelectEventArgsClass
'<GROUP ListSelectEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_ListSelectEventArgsClass
'<GROUP ListSelectEventArgsClass><TITLE ��������>
Class ListSelectEventArgsClass

	'------------------------------------------------------------------------------
	'@@ListSelectEventArgsClass.Selection
	'<GROUP !!MEMBERTYPE_Properties_ListSelectEventArgsClass><TITLE Selection>
	':����������:	
	'	��������� ������. � ������ LM_SINGLE - ������������� ��������� ������, 
	'   � ������� LM_MULTI/LM_MULTI_OR_NONE - ������ �� ���������������.
	':���������:
	'	Public Selection [As Variant]
	Public Selection			

	'------------------------------------------------------------------------------
	'@@ListSelectEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_ListSelectEventArgsClass><TITLE Cancel>
	':����������:	
	'	�������, �������� ���������� ������� ��������� �������.
	':���������:
	'	Public Cancel [As Boolean]
	Public Cancel				

	'------------------------------------------------------------------------------
	'@@ListSelectEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_ListSelectEventArgsClass><TITLE Self>
	':����������:	
	'	������� ���������� ������ �� ������� ��������� ������.
	':���������:
	'	Public Function Self [As ListSelectEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@X_SelectFromList
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SelectFromList>
':����������:
'	������� ���������� ����� �� ������ (x-list.aspx).
':���������:
'	sMetaName - 
'       [in] ��� ������ � ����������.
'	sOT - 
'       [in] ������������ ����, � ���������� �������� ������������� �������� ������ 
'       (<b>i:objects-list</b>).
'	nMode - 
'       [in] ����� ������ (LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE).
'   sParams - 
'       [in] ������ ���������� ��� ��������� ������, ��������� �� ��� "Param1=Value1", 
'       ����������� �������� "&" (��� ��������� ������ ���������� ����� ������������ 
'       ����� QueryStringParamCollectionBuilderClass).
'	sAddUrl - 
'       [in] �������������� ���������, ������������ � URL ���������� ������ 
'       (�������������  ���������� ������� � ����� x-list.aspx, x-list-page.vbs).
':���������:
' 	����������:
'   - Empty ��� ������� ������ <b>������</b> ��� ��� ������ ������ ��� ������ � ������ LM_MULTIPLE_OR_NONE;
'   - ������ ��������������� ��������� ��������, ����������� ";" ��� ������ � ������ LM_MULTIPLE;
'   - ������������� ���������� ������� ��� ������ � ������ LM_SINGLE.
':���������:
'   Function X_SelectFromList(
'       sMetaName [As String], 
'       sOT [As String], 
'       nMode [As Int], 
'       sParams [As String], 
'       sAddUrl [As String] 
'   ) [As Variant]
Function X_SelectFromList( sMetaName, sOT, nMode, sParams, sAddUrl)
	Dim sURL						' URL ������ ���������
	If nMode <> LM_SINGLE And nMode <> LM_MULTIPLE And nMode <> LM_MULTIPLE_OR_NONE Then
		Err.Raise -1, "X_SelectFromList", "������������ ����� ������"
	End If
	'������� URL �������	
	sURL =  "OT=" & sOT & "&MODE=" & nMode
	If Len("" & sMetaName) > 0 Then  sURL = sURL & "&METANAME=" & sMetaName 
	If Len("" & sParams) > 0 Then  sURL = sURL & "&RESTR=" & XService.UrlEncode(sParams)
	If Len("" & sAddUrl) > 0 Then
		If Left(sAddUrl,1) <> "&" Then sURL = sURL & "&"
		sURL = sURL & sAddUrl
	End If
	With X_GetEmptyQueryString
		.QueryString = sUrl
		'������� ������
		X_SelectFromList = X_ShowModalDialog("x-list.aspx?OT=" & sOT & "&METANAME=" & sMetaname & "&MODE=" & nMode, .Self())
	End With	
End Function

	
'===============================================================================
'@@X_SelectFromXmlList
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SelectFromXmlList>
':����������:
'	������� ���������� ����� �� ������ (x-select-from-xml.aspx) �� ���������� ��������.
':���������:
'	oObjectEditor - 
'       [in] ��������� ObjectEditorClass.
'	sMetaName - 
'       [in] ��� ������ � ����������.
'	sOT - 
'       [in] ������������ ����, � ���������� �������� ������������� �������� ������ 
'       (<b>i:objects-list</b>).
'	nMode - 
'       [in] ����� ������ (LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE).
'   oObjects - 
'       [in] ��������� XML-�������� ��� ������ (������ ������������ For Each: Array, 
'       IXMLDOMNodeList).
'	sAddUrl - 
'       [in] �������������� ���������, ������������ � URL ���������� ������.
':���������:
' 	����������:
'   - Empty ��� ������� ������ <b>������</b> ��� ��� ������ ������ ��� ������ � ������ LM_MULTIPLE_OR_NONE;
'   - ������ ��������������� ��������� ��������, ����������� ";" ��� ������ � ������ LM_MULTIPLE;
'   - ������������� ���������� ������� ��� ������ � ������ LM_SINGLE.
':���������:
'   Function X_SelectFromXmlList(
'       oObjectEditor [As ObjectEditorClass],
'       sMetaName [As String], 
'       sOT [As String], 
'       nMode [As Int], 
'       oObjects [As ICollection], 
'       sAddUrl [As String] 
'   ) [As Variant]
Function X_SelectFromXmlList(oObjectEditor, sMetaName, sOT, nMode, oObjects, sAddUrl)
	Dim sURL						' URL ������ ���������
	If nMode <> LM_SINGLE And nMode <> LM_MULTIPLE And nMode <> LM_MULTIPLE_OR_NONE Then
		Err.Raise -1, "X_SelectFromXmlList", "������������ ����� ������"
	End If
	'������� URL �������	
	sURL =  "OT=" & sOT & "&MODE=" & nMode
	If Len("" & sMetaName) > 0 Then  sURL = sURL & "&METANAME=" & sMetaName 
	If Len("" & sAddUrl) > 0 Then
		If Left(sAddUrl,1) <> "&" Then sURL = sURL & "&"
		sURL = sURL & sAddUrl
	End If
	Dim oSelectFromXmlListDialogParams
	Set oSelectFromXmlListDialogParams = New SelectFromXmlListDialogParamsClass
	Set oSelectFromXmlListDialogParams.ObjectEditor = oObjectEditor
	If IsObject(oObjects) Then
		Set oSelectFromXmlListDialogParams.Objects = oObjects
	Else
		oSelectFromXmlListDialogParams.Objects = oObjects
	End If
	X_SelectFromXmlList = X_ShowModalDialog("x-select-from-xml.aspx?" & sURL, oSelectFromXmlListDialogParams)
End Function


'===============================================================================
'@@SelectFromXmlListDialogParamsClass
'<GROUP !!CLASSES_x-utils><TITLE SelectFromXmlListDialogParamsClass>
':����������:	
'	����� ����������, ������������ � ������ x-select-from-xml.aspx/x-list-xml.vbs.
'
'@@!!MEMBERTYPE_Properties_SelectFromXmlListDialogParamsClass
'<GROUP SelectFromXmlListDialogParamsClass><TITLE ��������>
Class SelectFromXmlListDialogParamsClass

	'------------------------------------------------------------------------------
	'@@SelectFromXmlListDialogParamsClass.Objects
	'<GROUP !!MEMBERTYPE_Properties_SelectFromXmlListDialogParamsClass><TITLE Objects>
	':����������:	
	'	��������� ������������ ��������. ������������ ���������� - ��������� ������ 
	'   ������������ For Each.
	':���������:
	'	Public Objects [As ICollection]
    Public Objects          
    
	'------------------------------------------------------------------------------
	'@@SelectFromXmlListDialogParamsClass.ObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_SelectFromXmlListDialogParamsClass><TITLE ObjectEditor>
	':����������:	
	'	��������� ObjectEditorClass. ������������ ��� ���������� ��������� 
	'   (ExecuteStatement).
	':���������:
	'	Public ObjectEditor [As ObjectEditorClass]
    Public ObjectEditor     
End Class


'===============================================================================
'@@ChooseImageDialogClass
'<GROUP !!CLASSES_x-utils><TITLE ChooseImageDialogClass>
':����������:	
'	�����, ��������������� ������ �������� � �������� ���������� � ������ ������ 
'   �����������.
'
'@@!!MEMBERTYPE_Methods_ChooseImageDialogClass
'<GROUP ChooseImageDialogClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_ChooseImageDialogClass
'<GROUP ChooseImageDialogClass><TITLE ��������>
Class ChooseImageDialogClass

	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.Caption
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE Caption>
	':����������:	
	'	��������� ������� ������ ��������.
	':���������:
	'	Public Caption [As String]
	Public Caption		
	
	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.Url
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE Url>
	':����������:	
	'	URL ������� �������� (������ ������ � ������ ���������� ����).
	':���������:
	'	Public Url [As String]
	Public Url			
	
	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.Filters
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE Filters>
	':����������:	
	'	������ �������� � ������� 
	'   "description1|patternlist1|...descriptionN|patternlistN|", ���
	'   patternlistI - ���� ������������ ����� ";" ����� ������
	'   (���� "", �� - �� ������������).
	':���������:
	'	Public Filters [As String]
	Public Filters		
	
	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.MaxFileSize
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE MaxFileSize>
	':����������:	
	'	������������ ������ ����� (���� 0, �� - �� ������������).
	':���������:
	'	Public MaxFileSize [As Int]
	Public MaxFileSize
	
	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.MinHeight
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE MinHeight>
	':����������:	
	'	����������� ������ ����������� (���� 0, �� - �� ������������).
	':���������:
	'	Public MinHeight [As Int]
	Public MinHeight

	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.MaxHeight
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE MaxHeight>
	':����������:	
	'	������������ ������ ����������� (���� 0, �� - �� ������������).
	':���������:
	'	Public MaxHeight [As Int]
	Public MaxHeight
	
	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.MinWidth
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE MinWidth>
	':����������:	
	'	����������� ������ ����������� (���� 0, �� - �� ������������).
	':���������:
	'	Public MinWidth [As Int]
	Public MinWidth
	
	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.MaxWidth
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE MaxWidth>
	':����������:	
	'	������������ ������ ����������� (���� 0, �� - �� ������������).
	':���������:
	'	Public MaxWidth [As Int]
	Public MaxWidth

	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.OffClear
	'<GROUP !!MEMBERTYPE_Properties_ChooseImageDialogClass><TITLE OffClear>
	':����������:	
	'	���������� ����������� ������ <b>��������</b>.
	':���������:
	'	Public OffClear [As Boolean]
	Public OffClear
	
	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		MaxFileSize	= 0
		MinHeight	= 0
		MaxHeight	= 0
		MinWidth	= 0
		MaxWidth	= 0
		OffClear	= False
	End Sub


	'------------------------------------------------------------------------------
	'@@ChooseImageDialogClass.Show
	'<GROUP !!MEMBERTYPE_Methods_ChooseImageDialogClass><TITLE Show>
	':����������:	
	'	������� ��������� ���������� ��������� ���� � ����������.
    ':���������:
    ' 	����������:
    '   - Empty - ������ ������ <b>������</b>;
    '   - Null - "������" ��������;
    '   - ������ - URL ����� ��������.
	':���������:
	'	Public Function Show [As Variant]
	Public Function Show
		const PICTURE_DIALOG_SIZE = 60 '������ (� ��������� ������������ ������) ������� ������ ��������
		Show = X_ShowModalDialogEx(XService.BaseURL &  "x-choose-image.aspx"  , Me , "dialogWidth:" & Round(window.screen.availWidth * PICTURE_DIALOG_SIZE / 100)  & "px;dialogHeight:" & Round(window.screen.availHeight * PICTURE_DIALOG_SIZE / 100) & "px;help:no;center:yes;status:no;resizable:yes") 
	End Function
End Class


'===============================================================================
'@@X_SelectImage
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SelectImage>
':����������:
'	������� ������ ������� ������ ��������.
':���������:
'	sCaption - 
'       [in] ��������� ������� ������ ��������.
'	sCurrentPictureURL - 
'       [in] URL ������� �������� (������ ������ � ������ ���������� ����).
'	sFilrers - 
'       [in] ������ �������� � ������� 
'       "description1|patternlist1|...descriptionN|patternlistN|", ��� 
'       "patternlistI" - ���� ������������ ����� ";" ����� ������
'       (���� "", �� - �� ������������).
'	nMaxFileSize - 
'       [in] ������������ ������ ����� (���� 0, �� - �� ������������).
'   nMinHeight - 
'       [in] ����������� ������ ����������� (���� 0, �� - �� ������������).
'	nMaxHeight - 
'       [in] ������������ ������ ����������� (���� 0, �� - �� ������������).
'   nMinWidth - 
'       [in] ����������� ������ ����������� (���� 0, �� - �� ������������).
'	nMaxWidth - 
'       [in] ������������ ������ ����������� (���� 0, �� - �� ������������).
':���������:
' 	����������:
'   - Empty - ������ ������ <b>������</b>;
'   - Null - "������" ��������;
'   - ������ - URL ����� ��������.
':���������:
'   Function X_SelectImage( 
'       sCaption [As String],
'       sCurrentPictureURL [As String], 
'       sFilrers [As String], 
'       nMaxFileSize [As Int], 
'       nMinHeight [As Int], 
'       nMaxHeight [As Int], 
'       nMinWidth [As Int], 
'       nMaxWidth [As Int] 
'   ) [As Variant]
Function X_SelectImage(sCaption,sCurrentPictureURL, sFilrers, nMaxFileSize, nMinHeight, nMaxHeight, nMinWidth, nMaxWidth  )
	Dim o						' ������ ChooseImageDialogClass
	Set o = new ChooseImageDialogClass
	o.Caption = "" & sCaption
	o.Url = "" & sCurrentPictureURL
	o.Filters = "" & sFilrers
	o.MaxFileSize = nMaxFileSize
	o.MaxHeight = nMaxHeight
	o.MaxWidth = nMaxWidth
	o.MinHeight = nMinHeight
	o.MinWidth = nMinWidth
	X_SelectImage = o.Show()
End Function


'===============================================================================
'@@X_CheckObjectRights
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CheckObjectRights>
':����������:
'	������� ��������� ������� ������������� ������������� ����� �� ��������� �������.
':���������:
'	sType - 
'       [in] ��� ���� �������.
'   sObjectID - 
'       [in] ������������� �������.
'	sAction - 
'       [in] �������� ��� �������� (��������� ACCESS_RIGHT_nnnn).
':���������:
' 	True - ������� �������� ��� �������� ���������, False - � ��������� ������.
':���������:
'   Function X_CheckObjectRights( 
'       sType [As String],
'       sObjectID [As String], 
'       sAction [As String] 
'   ) [As Boolean]
Function X_CheckObjectRights( sType, sObjectID, sAction)
	Dim oObjectPermission
	
	Set oObjectPermission = New XObjectPermission
	oObjectPermission.m_sAction = sAction
	oObjectPermission.m_sTypeName = sType
	oObjectPermission.m_sObjectID = sObjectID
	X_CheckObjectRights = X_CheckObjectsRights( Array(oObjectPermission))(0)
End Function


'===============================================================================
'@@X_CheckObjectsRights
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CheckObjectsRights>
':����������:
'	������� ��������� ������� ������������� ������������� ����� �� ��������� ��������.
':���������:
'	aObjectPermission - 
'       [in] ������ �������� ��� ������� ����.
':���������:
' 	������ True/False ������������ ����� ��, ��� <b><i>aObjectPermission</b></i>: 
'   True - ������� �������� ��� ��������, ��������� � ��������������� �������� ������� 
'   <b><i>aObjectPermission</b></i>, ���������, False - � ��������� ������.
':���������:
'   Function X_CheckObjectsRights( 
'       aObjectPermission [As XObjectPermission] 
'   ) [As Boolean]
Function X_CheckObjectsRights(aObjectPermission)
	Dim aResult			' As Boolean() - ������������ ��������� 
	Dim aServerResult	' As Boolean()
	Dim oList			' As ObjectArrayListClass
	Dim bPermited		' As Boolean
	Dim i,j
	Dim aErr

	X_CheckObjectsRights = Array()
	If Not IsArray(aObjectPermission) Then Exit Function
	If UBound(aObjectPermission)<0 Then Exit Function
	Set oList = New ObjectArrayListClass
	oList.AddRange aObjectPermission
	ReDim aResult(Ubound(aObjectPermission))
	For i=UBound(aResult) To 0 Step -1
		If X_RightsCache().Find(aObjectPermission(i), bPermited) Then
			aResult(i) = bPermited
			oList.RemoveAt i
		End If	
	Next
	if oList.Count>0 Then
		On Error Resume Next
		With New XGetObjectsRightsRequest
			.m_sName = "GetObjectsRights"
			.m_aPermissions = oList.GetArray
			aServerResult = X_ExecuteCommand( .Self ).m_aObjectPermissionCheckList
		End With
		If Err Then
			If Not X_HandleError Then
				' ������ �� �������
				aErr = Array(Err.Number, Err.Source, Err.Description)
				On Error Goto 0
				Err.Raise aErr(0), aErr(1), aErr(2)				
			End If
			On Error GoTo 0
			For i=0 To UBound(aResult)
				If IsEmpty(aResult(i)) Then
					aResult(i) = False
				End If
			Next
		Else
			On Error GoTo 0
			j=0
			For i=0 To UBound(aResult)
				If IsEmpty(aResult(i)) Then
					aResult(i) = aServerResult(j)
					X_RightsCache().SetValue aObjectPermission(i), aResult(i)
					j=j+1
				End If
			Next
		End If
	End If
	X_CheckObjectsRights = aResult
End Function


'===============================================================================
'@@X_CheckTypeRights
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CheckTypeRights>
':����������:
'	������� ��������� ������� ������������� ������������ ����� �� ��������� ���(�).
':���������:
'	sType - 
'       [in] ����� ����� �������� ����� ";".
'	sAction - 
'       [in] �������� ��� �������� (��������� ACCESS_RIGHT_nnnn).
':���������:
' 	True - ������� �������� ��� �������� ���������, False - � ��������� ������.
':���������:
'   Function X_CheckTypeRights( 
'       sType [As String],
'       sAction [As String] 
'   ) [As Boolean]
Function X_CheckTypeRights( sType, sAction)
	X_CheckTypeRights = X_CheckObjectRights(sType, Empty, sAction)
End Function


'==============================================================================
'@@ObjectRightsCacheClass
'<GROUP !!CLASSES_x-utils><TITLE ObjectRightsCacheClass>
':����������:	
'   ��� ����������� ���� �� �������.
'   ����� ������������ ��� �������� �������������:
'	- ����������� � ����� ���������� �� �������� ��� ���������, ������������ ������������ XObjectPermission; 
'	- ����������� �������� �����������. �����������  
'   ������ ������� ����������� �������� 
'   <LINK ObjectRightsCacheClass.SetValue, SetValue />
'   � <LINK ObjectRightsCacheClass.Find, Find />. ������ ���������� ��� ��������� 
'   ��������� XObjectPermission, ����������� �������� ��� ��������. 
'   ���������� �������� - ���������� ������� ���������� ��������.  
'   ������ ������� ����������� �������� 
'   <LINK ObjectRightsCacheClass.SetValueEx, SetValueEx /> � 
'   <LINK ObjectRightsCacheClass.FindEx, FindEx />. � ������ �������� ���� � ���� 
'   �������� ��������������� ���������� ����� (� ���������� �������� �� ����������� �� 
'   ���������� XObjectPermission). � �������� ����������� �������� ����� �������������� 
'   ����� ������ (�.�. vbObject). ������� ������������ ��� ���������� � ���������� ���� 
'   ����������� ���������� �������� ���� � XFW .NET �� ������������. ������ ������� 
'   ���������� � ������ ������ (� �� ��������) ��-�� ����, ��� ��������� 
'   ObjectRightsCacheClass ������������� ���������� XFW .NET ����� ����� ����������� 
'   ������ ����������.  
':����������: 
'	����� �� ������ ������ �����������������.
'@@!!MEMBERTYPE_Methods_ObjectRightsCacheClass
'<GROUP ObjectRightsCacheClass><TITLE ������>
Class ObjectRightsCacheClass
	Private m_oCache		' As Scripting.Dictionary

	'==========================================================================	
	Private Sub Class_Initialize
		Set m_oCache = CreateObject("Scripting.Dictionary")
		m_oCache.CompareMode = vbBinaryCompare
	End Sub
	
	'==========================================================================
	' ������� ���� ��� ����������� �� ������� XObjectPermission
	'	[in] oObjectPermission As XObjectPermission - ������ �� �������� ��� ��������
	'	[out] As String - ����
	Private Function getKey(oObjectPermission)
		getKey = oObjectPermission.m_sTypeName & "?" & oObjectPermission.m_sObjectID & "?" & oObjectPermission.m_sAction
	End Function
	
	'==========================================================================	
	'@@ObjectRightsCacheClass.Find
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE Find>
	':����������:	
	'	������� ��������� ������� � ���� ���������� �� �������� �������� ��� �������� 
	'   (������������� ������� <LINK ObjectRightsCacheClass.SetValue, SetValue />).
	':���������: 
    '	oObjectPermission - 
    '       [in] ������ �� �������� ��� ��������.
	'	bPermited - 
	'       [out] ��������� �������� ����.
	':���������:
	'	True - �������������� �������� �������, False - � ��������� ������.
	':���������:	
	'	Public Function Find( 
	'       oObjectPermission [As XObjectPermission], 
	'       ByRef bPermited [As Boolean] 
	'   ) [As Boolean]	
	Public Function Find(oObjectPermission, ByRef bPermited)
		Dim vTemp
		Find = False
		vTemp = m_oCache.Item(getKey(oObjectPermission))
		If Not IsEmpty(vTemp) Then
			bPermited = vTemp
			Find = True
		End If
	End Function


	'==========================================================================
	'@@ObjectRightsCacheClass.SetValue
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE SetValue>
	':����������:	
	'	��������� �������� ���������� ��� �������� ��� ��������. 
	'	���� �������� ��� ����������, ��� ����������������. ���������� �������� ������� 
	'   <LINK ObjectRightsCacheClass.Find, Find />.
	':���������: 
    '	oObjectPermission - 
    '       [in] ������ �� �������� ��� ��������.
	'	bPermited - 
	'       [in] ���������� �������� (������������ ������� 
	'       <LINK ObjectRightsCacheClass.Find, Find />).
	':���������:	
	'	Public Sub SetValue( 
	'       oObjectPermission [As XObjectPermission], 
	'       bPermited [As Boolean] 
	'   ) 	
	Public Sub SetValue(oObjectPermission, bPermited)
		m_oCache.Item(oObjectPermission.m_sTypeName & "?" & oObjectPermission.m_sObjectID & "?" & oObjectPermission.m_sAction) = bPermited
	End Sub


	'==========================================================================	
	'@@ObjectRightsCacheClass.FindEx
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE FindEx>
	':����������:	
	'	������� �������� �������������� ������ �� �����.
	':���������: 
    '	sKey - 
    '       [in] ���� ��� ������ �������� � ����.
	'	oObjectRightsDescr - 
	'       [out] �������������� ��������.
	':���������:
	'	True - �������������� �������� �������, False - � ��������� ������.
	':���������:	
	'	Public Function FindEx( 
	'       sKey [As String], 
	'       ByRef oObjectRightsDescr [As Object] 
	'   ) [As Object]	
	Public Function FindEx(sKey, ByRef oObjectRightsDescr)
		FindEx = False
		If m_oCache.Exists(sKey) Then
			Set oObjectRightsDescr = m_oCache.Item(sKey)
			FindEx = True
		End If
	End Function
	
	
	'==========================================================================	
	'@@ObjectRightsCacheClass.SetValueEx
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE SetValueEx>
	':����������:	
	'	��������� �������� ��������� ������ ��� �������� ������.
	':���������: 
    '	sKey - 
    '       [in] ���� ��� ������ �������� � ����.
	'	oObjectRightsDescr - 
	'       [in] �������������� ��������.
	':���������:	
	'	Public Sub SetValueEx( 
	'       sKey [As String], 
	'       oObjectRightsDescr [As Object] 
	'   ) 	
	Public Sub SetValueEx(sKey, oObjectRightsDescr)
		Set m_oCache.Item(sKey) = oObjectRightsDescr
	End Sub
	
	
	'==========================================================================	
	'@@ObjectRightsCacheClass.Contains
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE Contains>
	':����������:	
	'	������� ���������� ������� ������� ��������������� �������� ��� �������� �����.
	':���������: 
    '	sKey - 
    '       [in] ���� ��� ������ �������� � ����.
	':���������:
	'	True - �������������� �������� �������, False - � ��������� ������.	
	':���������:	
	'	Public Function Contains(sKey [As String]) [As Boolean]	
	Public Function Contains(sKey)
		Contains = m_oCache.Exists(sKey)
	End Function

	
	'==========================================================================	
	'@@ObjectRightsCacheClass.RemoveByKey
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE RemoveByKey>
	':����������:	
	'	������� ������� �������������� �������� �� �����.
	':���������: 
    '	sKey - 
    '       [in] ���� ��� ������ �������� � ����.
	':���������:
	'	True - �������� � �������� ������ �������, False - �������� � �������� 
	'   ������ � ���� ���.
	':���������:	
	'	Public Function RemoveByKey( 
	'       sKey [As String] 
	'   ) [As Boolean]	
	Public Function RemoveByKey(sKey)
		RemoveByKey = False
		If m_oCache.Exists(sKey) Then
			m_oCache.Remove(sKey)
			RemoveByKey = True
		End If
	End Function

	
	'==========================================================================	
	'@@ObjectRightsCacheClass.Remove
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE Remove>
	':����������:	
	'	������� ������� �������������� ���������� ��� �������� �������� ��� ��������.
	':���������: 
    '	oObjectPermission - 
    '       [in] ������ �� �������� ��� ��������.
	':���������:
	'	True - �������� ��� �������� �������� ��� �������� �������, False - �������� 
	'   ��� �������� �������� � ���� ���.
	':���������:	
	'	Public Function Remove( 
	'       oObjectPermission [As XObjectPermission] 
	'   ) [As Boolean]	
	Public Function Remove(oObjectPermission)
		Remove = RemoveByKey(getKey(oObjectPermission))
	End Function


	'==========================================================================	
	'@@ObjectRightsCacheClass.RemoveByObject
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE RemoveByObject>
	':����������:	
	'	������� ������� �������������� �������� ���������� �� ��� �������� ��� 
	'   ��������� �������.
	':���������: 
    '	sObjectType - 
    '       [in] ������������ ���� �������.
    '	sObjectID - 
    '       [in] ������������� �������.
	':���������:
	'	True - �������� ��� ��������� ������� �������, False - �������� ��� ��������� 
	'   ������� � ���� ���.
	':���������:	
	'	Public Function RemoveByObject( 
	'       sObjectType [As String], 
	'       sObjectID [As String] 
	'   ) [As Boolean]	
	Public Function RemoveByObject(sObjectType, sObjectID)
		RemoveByObject = RemoveByKeyPattern(sObjectType & "?" & sObjectID & "?")
	End Function

	
	'==========================================================================	
	'@@ObjectRightsCacheClass.RemoveByType
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE RemoveByType>
	':����������:	
	'	������� ������� �������������� �������� ���������� �� ��� �������� ���� 
	'   �������� ��������� ����.
	':���������: 
    '	sObjectType - 
    '       [in] ������������ ���� �������.
	':���������:
	'	True - �������� ��� ��������� ���� �������, False - �������� ��� ��������� 
	'   ���� � ���� ���.
	':���������:	
	'	Public Function RemoveByObject( 
	'       sObjectType [As String] 
	'   ) [As Boolean]	
	Public Function RemoveByType(sObjectType)
		RemoveByType = RemoveByKeyPattern(sObjectType & "?")
	End Function


	'==========================================================================	
	'@@ObjectRightsCacheClass.RemoveByKeyPattern
	'<GROUP !!MEMBERTYPE_Methods_ObjectRightsCacheClass><TITLE RemoveByKeyPattern>
	':����������:	
	'	������� ������� �������������� �������� �� ���������� �������� �����,
	'	�.�. ��� ��������, ����� ������� ���������� � ���������� ������.
	':���������: 
    '	sKeyPattern - 
    '       [in] ������ ������ �����.
	':���������:
	'	���������� ��������� � ��������� ��������. 0 - �������� � �������� ������ � 
	'   ���� ���.
	':���������:	
	'	Public Function RemoveByKeyPattern( 
	'       sKeyPattern [As String] 
	'   ) [As Int]	
	Public Function RemoveByKeyPattern(sKeyPattern)
		Dim i
		Dim sKey		' ���� � ����
		Dim nFound		' ����������� ��������� � ��������� ��������
		Dim nLastIndex	' ������ ���������� ����� � ������� ������
			
		nFound = 0
		nLastIndex = m_oCache.Count-1
		Do
			If i > nLastIndex Then Exit Do
			sKey = m_oCache.Keys()(i)
			If Mid(sKey, 1, Len(sKeyPattern)) = sKeyPattern Then
				m_oCache.Remove(sKey)
				nLastIndex = nLastIndex - 1
				nFound = nFound + 1
			Else
				i = i + 1
			End If
		Loop
		RemoveByKeyPattern = nFound
	End Function
End Class


'===============================================================================
'@@X_RightsCache
'<GROUP !!FUNCTIONS_x-utils><TITLE X_RightsCache>
':����������:
'	�������, ����� ������� ������ ������ ����������� ������ � ����������� ���� 
'	���� (���������� <b><i>x_oRightsCache</b></i>).
':����������:
'	<b>��������!</b> ������������ ���������� <b><i>x_oRightsCache</b></i> �������� 
'   �����������!
':���������:
' 	��������� ObjectRightsCacheClass, �������������� ������ ����������� ���� ����.
':���������:
'   Public Function X_RightsCache() [As ObjectRightsCacheClass]
Public Function X_RightsCache()
	If Not hasValue(x_oRightsCache) Then
		Set x_oRightsCache = New ObjectRightsCacheClass
	End If
	Set X_RightsCache = x_oRightsCache
End Function


'===============================================================================
'@@QueryStringClass
'<GROUP !!CLASSES_x-utils><TITLE QueryStringClass>
':����������:	
'	����� - ��������� ���������� URL-��������; ��������� ������ ������� ������
'	����������. ������������ ��� �������� ���������� ����� dialogArguments (��.
'	X_GetQueryString).
':����������: 
'	�����: ������������ ������ ������������ ��� �������� ���� ���������!
'
'@@!!MEMBERTYPE_Methods_QueryStringClass
'<GROUP QueryStringClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_QueryStringClass
'<GROUP QueryStringClass><TITLE ��������>
Class QueryStringClass

	Private m_oParams	' ��������� ���������� (Scripting.Dictionary)

	'---------------------------------------------------------------------------
	' �����������
	Private Sub Class_Initialize()
		Set m_oParams = CreateObject("Scripting.Dictionary")
		m_oParams.CompareMode = vbTextCompare
	End Sub
	
	'---------------------------------------------------------------------------
	' ����������
	Private Sub Class_Terminate()
		Set m_oParams = Nothing
	End Sub

	'---------------------------------------------------------------------------
	'@@QueryStringClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_QueryStringClass><TITLE QueryString>
	':����������:	���������� ������ �������, �������������� �� ������ ��������
	'				��������� ��������� ����������. ���� ��������� ���������� 
	'				������, ���������� ������ ������.
	':����������:	�������� �������� ��� ��� ������, ��� � ��� ������. ��� 
	'				��������� �������� �������� ����������� ������������������
	'				��������� ����������.
	':���������:	
	'	Public Property Get QueryString [As String]
	'	Public Property Let QueryString( sQueryString [As String] )
	Public Property Get QueryString
		Dim sResult ' ��������� ���������� �������
		Dim sKey	' ����
		Dim sValue	' ��������
		
		sResult = Empty
		For Each sKey In m_oParams.Keys
			For Each sValue in m_oParams.Item(sKey)
				If Not IsObject(sValue) Then
					If IsEmpty(sResult) Then
						sResult =  XService.URLEncode( sKey ) & "=" & XService.URLEncode( "" & sValue)
					Else
						sResult =  sResult & "&" &  XService.URLEncode( sKey ) & "=" & XService.URLEncode( "" & sValue )
					End If
				End If
			Next
		Next	
		QueryString = CStr(sResult)
	End Property
	
	Public Property Let QueryString( sQueryString )
		Dim aParams		'	������ ��� ���� name=value
		Dim sName		'	��� ���������
		Dim sValue		'	�������� ���������
		Dim nOffset		'	������� ������� =
		Dim i
		With m_oParams
			.RemoveAll
			aParams = Split( vbNullString & sQueryString, "&" )
			For i=0 To UBound(aParams)
				nOffset = InStr(1,aParams(i),"=")
				If nOffset=0 Then
					sName  = aParams(i)
					sValue = ""
				Else
					sName	= MID(aParams(i),1,nOffset-1)
					sValue	= MID(aParams(i),nOffset+1)
				End If
				If 0<>Len(sName) Then
					AddValue XService.URLDecode( sName )  , XService.URLDecode( sValue )
				End If
			Next
		End With
	End Property

	'---------------------------------------------------------------------------
	'@@QueryStringClass.SerializeToXml
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE SerializeToXml>
	':����������:	��������� XML-������������� ������, �������������� 
	'				� ��������� ���������� ("������������" ���������).
	':���������:
	'	XML-������������� ������, ��� IXMLDOMElement.
	':����������:
	'	� ���������� ���������� ��������� ����� ����������� XML � ��������
	'	��������� <B>params</B> � ������� ����������� ��� ��������� <B>param</B>,
	'	�������������� ������ ������� ���������, ��������������� � ���������.
	'	������������ ��������� ���������� ��� �������� �������� <B>n</B> �������� 
	'	<B>param</B>, �������� - ��� ���������� �������� <B>param</B>.
	':���������:
	'	Public Function SerializeToXml() [As IXMLDOMElement]
	Public Function SerializeToXml()
		Dim sKey		' ����
		Dim sValue		' ��������
		Dim oXmlRoot	' ������������ �������� ���� params
		
		Set oXmlRoot = XService.XmlGetDocument.createElement("params")
		For Each sKey In m_oParams.Keys
			For Each sValue in m_oParams.Item(sKey)
				If Not IsObject(sValue) Then
					With oXmlRoot.AppendChild(oXmlRoot.OwnerDocument.CreateElement("param"))
						.SetAttribute "n", sKey
						.text = sValue
					End With
				End If
			Next
		Next
		Set SerializeToXml = oXmlRoot
	End Function
	
	'---------------------------------------------------------------------------
	'@@QueryStringClass.Names
	'<GROUP !!MEMBERTYPE_Properties_QueryStringClass><TITLE Names>
	':����������:	���������� ������ ���� ����������, �������������� � ���������.
	':��. �����:	QueryStringClass.GetValues
	':���������:	Public Property Get Names() [As Array]
	Public Property Get Names()
		Names = m_oParams.Keys()
	End Property
	
	'---------------------------------------------------------------------------
	'@@QueryStringClass.GetValues
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE GetValues>
	':����������:	
	'	���������� ������ �������� ���������� ��������� �������.
	':���������: 
	'	sName - [in] ������������ ���������.
	':���������:
	'	�������� ���������� ��������. ���� �������� � �������� �������������
	'	� ��������� �� �����������, ����� ���������� Null.
	':��. �����:	
	'	QueryStringClass.Names, QueryStringClass.GetValueEx
	':���������:	
	'	Public Function GetValues( ByVal sName [As String] ) [As Variant]
	Public Function GetValues(byval sName)
		With m_oParams
			If .Exists(sName) Then
				GetValues = .Item(sName)
				' ��� ������� ������� ���� ����� Null
				If UBound(GetValues)=-1 Then
					GetValues = Null
				End If 
			Else
				GetValues = Null
			End if
		End With
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.GetValueEx
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE GetValueEx>
	':����������:	
	'	���������� �������� ���������� ��������� ������� (� ��� ����� � �������).
	':���������: 
	'	sName - 
	'       [in] ������������ ���������.
	'	vValue - 
    '       [in,out] �������� ������������ ���������; ���� �������� � 
	'			��������� ������������� �� ������, �������� <b><i>vValue</b></i> 
	'			�������� ���������� (�.�. �������� ��������, ���������� ��� ���������,
	'			���� "�������� �� ���������").
	':���������:
	'	����������� ������� ������� ���������� ��������� � ���������: True - 
	'	�������� � ��������� ������������; False - ��������� � ��������� 
	'	������������� � ��������� ���.
	':��. �����:	
	'	QueryStringClass.Names, QueryStringClass.GetValue
	':���������:	
	'	Public Function GetValueEx( 
	'		sName [As String], ByRef vValue [As Variant]
	'	) [As Variant]
	Public Function GetValueEx(sName, ByRef vValue)
		Dim aValues	' ������ �������� ���������
		Dim nIndex	' ������ �������� � aValues
		aValues = GetValues(sName)
		If IsNull(aValues) Then
			GetValueEx = False
		Else
			GetValueEx = True
			nIndex = UBound(aValues)
			If IsObject(aValues(nIndex)) Then
				Set vValue = aValues(nIndex)
			Else
				vValue = aValues(nIndex)
			End If		
		End If
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.GetValue
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE GetValue>
	':����������:	���������� �������� ���������� ��������� �������.
	':���������: 	
	'   sName - 
	'       [in] ������������ ���������.
	'	vDefault - 
	'       [in] �������� �� ���������.
	':���������:
	'	�������� ���������� ���������. ���� �������� � ��������� ������������� � 
	'	��������� �� �����������, ����� ���������� �������� �� ���������.
	':��. �����:	
	'	QueryStringClass.Names
	':���������:	
	'	Public Function GetValue( 
	'		sName [As String], ByVal vDefault [As Variant] 
	'	) [As Variant]
	Public Function GetValue( sName, ByVal vDefault)
		GetValueEx sName, vDefault
		If IsObject(vDefault) Then
			Set GetValue = vDefault
		Else
			GetValue = vDefault
		End If		
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.GetValueInt
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE GetValueInt>
	':����������:	���������� �������� ���������� ��������� �������,
	'				����������� � �������������� ��������.
	':���������: 	sName - [in] ������������ ���������.
	'				nDefault - [in] �������� �� ���������.
	':���������:
	'	�������� ���������� ���������. ���� �������� � ��������� ������������� � 
	'	��������� �� �����������, ����� ���������� �������� �� ���������.
	':��. �����:	
	'	QueryStringClass.Names
	':���������:	
	'	Public Function GetValueInt( 
	'		sName [As String], ByVal nDefault [As Int] 
	'	) [As Int]
	Public Function GetValueInt( sName, ByVal nDefault)
		Dim nResult	' ������������ ��������
		nResult = nDefault
		If GetValueEx( sName, nResult) Then
			If IsObject(nResult) Then
				nResult = nDefault
			ElseIf IsArray(nResult) Then
				nResult = nDefault
			End If
			On Error Resume Next
			nResult  = CLng(nResult)
			if Err Then
				nResult = nDefault
			End if
			On Error GoTo 0
		End If	
		On Error Resume Next
		nResult  = CLng(nResult)
		If Err Then
			nResult = 0
		End if
		On Error GoTo 0
		GetValueInt = nResult
	End Function
	

	'---------------------------------------------------------------------------
	'@@QueryStringClass.SetValues
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE SetValues>
	':����������:	
	'   ��� ���������� ��������� ��������� ������������� ������� �������� (� ��� ����� 
	'   � ������� ��������).
	':���������: 	sName - [in] ������������ ���������.
	'				aValues - [in] ��������������� ��������.
	':����������:
	'	���� �������� � ��������� ������ �� ������, �� ����� ��������� ��� � ���������.
	':���������:	
	'	Public Sub SetValues(
	'       ByVal sName [As String],
	'       ByVal aValues [As Variant] 
	'	) 
	Public Sub SetValues(ByVal sName,ByVal aValues)
		If Not IsArray(aValues) Then
			aValues = Null
		ElseIf -1=UBound(aValues) Then
			aValues = Null
		End If	
		With m_oParams
			If Not .Exists(sName) Then
				If Not IsNull(aValues) Then
					.Add sName, aValues
				End If	
			ElseIf IsNull(aValues) Then
				.Remove sName
			Else
				.Item( sName) = aValues
			End if
		End With		
	End Sub
	

	'---------------------------------------------------------------------------
	'@@QueryStringClass.SetValue
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE SetValue>
	':����������:	
	'   ��� ���������� ��������� ��������� ������������� ������� �������� (� ��� ����� 
	'   � ������� ��������).
	':���������: 	sName - [in] ������������ ���������.
	'				vValue - [in] ��������������� ��������.
	':����������:
	'	���� �������� � ��������� ������ �� ������, �� ����� ��������� ��� � ���������.
	':���������:	
	'	Public Sub SetValue(
	'       sName [As String],
	'       vValue [As Variant] 
	'	) 
	Public Sub SetValue(sName, vValue)
		SetValues sName, Array(vValue)
	End Sub
	
	
	'---------------------------------------------------------------------------
	'@@QueryStringClass.AddValue
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE AddValue>
	':����������:	
	'   ��������� � ��������� �������� � ��� ��������.
	':���������: 	sName - [in] ������������ ���������.
	'				vValue - [in] �������� ���������.
	':���������:	
	'	Public Sub AddValue(
	'       sName [As String],
	'       vValue [As Variant] 
	'	) 
	Public Sub AddValue(sName, vValue)
		Dim aValues	' ������� ��������
		aValues = GetValues(sName)
		If IsNull(aValues) Then
			aValues = Array(vValue)
		Else
			ReDim Preserve aValues(UBound(aValues)+1)
			If IsObject(vValue) Then
				Set aValues(UBound(aValues)) = 	vValue
			Else
				aValues(UBound(aValues)) = 	vValue
			End If	
		End If
		SetValues sName, aValues	
	End Sub

	'---------------------------------------------------------------------------
	'@@QueryStringClass.AddValues
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE AddValues>
	':����������:	
	'	��������� � ������� ��������� ��������� �� �������� ��������� QueryStringClass.
	':���������: 	
	'	oQS - [in] ���������, ��������� ������� �����������.
	':���������:	
	'	Public Sub AddValues( oQS [As QueryStringClass] )
	Public Sub AddValues(oQS)
		Dim sKey	' ������������ ���������
		Dim sValue	' �������� ���������
		
		If IsObject(oQS) Then
			If StrComp(TypeName(oQS), "QueryStringClass", vbTextCompare) <> 0 Then
				Err.Raise -1, "QueryStringClass::AddValues", "�������� ������ ������ ���� ���� QueryStringClass"
			End If
			For Each sKey In oQS.Names
				For Each sValue In oQS.GetValues(sKey)
					AddValue sKey, sValue
				Next
			Next
		End If
	End Sub
	
	'---------------------------------------------------------------------------
	'@@QueryStringClass.IsExists
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE IsExists>
	':����������:	
	'	��������� ������� � ��������� ��������� � �������� �������������.
	':���������: 	
	'	sName - [in] ������������ �������� ���������.
	':���������: 	
	'	True - ��������� �������� � ��������� ����������, ����� - False.
	':���������:	
	'	Public Function IsExists( ByVal sName [As String] ) [As Boolean]
	Public Function IsExists(ByVal sName)
		IsExists = m_oParams.Exists( sName)
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.Remove
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE Remove>
	':����������:	
	'	������� ��������� �������� �� ���������.
	':���������: 	
	'	sName - [in] ������������ ���������� ���������.
	':���������: 	
	'	- True - ��������� �������� � ��������� ����������� � ��� ������; 
	'	- False - ���������� ��������� � ��������� �� ����.
	':���������:	
	'	Public Function Remove( ByVal sName [As String] ) [As Boolean]
	Public Function Remove(byval sName)
		Remove = False
		if m_oParams.Exists(sName) Then 
			m_oParams.Remove sName
			Remove = True
		End if 
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.Clone
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE Clone>
	':����������:	
	'	���������� ����� ������� QueryStringClass.
	':���������: 	
	'	��������� QueryStringClass, ������ ����� ������� ����������.
	':���������:	
	'	Public Function Clone() [As QueryStringClass]
	Public Function Clone()
		Dim oResult '��������� ���������� �������
		Dim i
		Set oResult = new QueryStringClass
		For Each i in Names
			oResult.SetValues i, GetValues(i)
		Next
		Set Clone = oResult
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.MakeURL
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE MakeURL>
	':����������:	
	'	�� ��������� �������� ��������� ��������� ���������� � ��������� ����� 
	'	�������� ��������� ������ URL. ���������� URL ������������ ��� ��������
	'	��������.
	':���������:
	'	sPage - [in] ��� ��������.
	':���������: 	
	'	������ � ������ ������������������� URL-������� ��������.
	':����������:
	'	���� �������� ��� �������� �������� ������������� (�.�. ����������� ��������
	'	�����, ������ �������, ����������), �� ����� ��������� ����� �������� �� 
	'	�������, ��������� ������� URL-����� ������� ��������.
	':���������:	
	'	Public Function MakeURL( sPage [As String] ) [As String]
	Public Function MakeURL( sPage )
		Dim sURL	' URL ��������
		sURL = sPage 
		' ��������� ������� ���������
		if InStr(1,sURL, "://") <= 0 Then '�������� ����������� - ���������� �������
			sURL = XService.BaseURL & sURL
		End if
		' ��������� ���������
		if InStr(1,sURL, "?")>0 Then
			sURL = sURL & "&" & QueryString
		Else
			sURL = sURL & "?" & QueryString
		End if
		MakeURL = sURL
	End Function

	'---------------------------------------------------------------------------
	'@@QueryStringClass.Self
	'<GROUP !!MEMBERTYPE_Methods_QueryStringClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self [As QueryStringClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@X_GetQueryString
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetQueryString>
':����������:	
'	������� � �������������� ����� ��������� ������ QueryStringClass.
':����������:
'	������� ������������ ��������� ������ �������� ����������:
'	- ��������� �������� ����� location.href;
'	- ��������� �������� ����� dialogArguments, ��� ��������� ������ 
'		QueryStringClass;
'	- ��������� �������� ����� dialogArguments, � ���� ������;
'	- ��������� �������� ����� dialogArguments, ������ ��������� �������, 
'		��� ��������� ������ QueryStringClass;
'	- ��������� �������� ����� dialogArguments, ������ ��������� �������, 
'		�������.
'	������� ��������� ������������� ������ ������� ���������� (� ������� ��
'	������������) � ������� ��������� QueryStringClass ��� ���������� �������
'	����������� ������.
':���������:
'	Function X_GetQueryString() [As QueryStringClass]
Function X_GetQueryString()
	Dim nOffset		' ��������
	Dim oQS			' ������ QueryStringClass - ��������� ���������� �������
	Dim aDA			' ������ � DialogArguments
	Dim vArgs		' ���������
	
	X_GetDialogArguments vArgs

	'	!!! �������� !!!
	' � IE 5.5+ �������� ��������� �����������:
	'	��������� �����(IFRAME), ����������� � ���������� ���� ���������
	'	DialogArguments �� ��������, ��� ����� �������� � ����� � ������������ ��������� ����������
	'	������� ��� ������ � ��������� ������ ������������ ������ ������ ������� �������� ����������...
	'	...
	if  Not(Window Is Parent) or IsEmpty(vArgs) or IsNull(vArgs) Then
		' 1-� ������� - ��������� �������� ����� location.href
		Set oQS = new QueryStringClass
		nOffset = InStr(1,document.location.href,"?")
		if nOffset > 0 Then
			oQS.QueryString = MID(document.location.href, nOffset + 1)
		End if
	ElseIf vbString = VarType(vArgs) Then
		' 3-� ������� - ��������� �������� ����� DialogArguments � ���� ������
		Set oQS = new QueryStringClass
		oQS.QueryString = vArgs
	ElseIf 0=StrComp(TypeName(vArgs), "QueryStringClass", vbTextCompare) Then
		' 2-� ������� - ��������� �������� ����� DialogArguments � ���� ������� QueryStringClass
		Set  oQS = vArgs.Clone
	ElseIf IsArray(vArgs) Then
		aDA = vArgs
		if vbString = VarType(aDA(0)) Then
			' 5-� ������� - ��������� �������� ����� DialogArguments � ���� 1-�� �������� ������� �������
			Set oQS = new QueryStringClass
			oQS.QueryString = aDA(0)
		ElseIf 0=StrComp(TypeName(aDA(0)), "QueryStringClass", vbTextCompare) Then
			' 4-� ������� - ��������� �������� ����� DialogArguments � ���� 1-�� �������� ������� �������� QueryStringClass
			Set  oQS = aDA(0).Clone
		End if
	End if
	Set X_GetQueryString = oQS
End Function

'===============================================================================
'@@X_GetEmptyQueryString
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetEmptyQueryString>
':����������:	
'	������� ����� ������ ��������� ������ QueryStringClass.
':���������:
'	Function X_GetEmptyQueryString() [As QueryStringClass]
Function X_GetEmptyQueryString()
	Set X_GetEmptyQueryString = new QueryStringClass
End Function


'===============================================================================
'@@X_GetApproximateXmlSize
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetApproximateXmlSize>
':����������:
'	������� ��������� ��������� ����������� ������� XML-�����.
':���������:
'	oXml - 
'       [in] XML-����.
':���������:
'   Function X_GetApproximateXmlSize( 
'       oXml [As IXMLDOMDocument] 
'   ) [As Int]
Function X_GetApproximateXmlSize(oXml)
	Dim oNode	' ����
	Dim nLen	' �����
	nLen=0
	For Each oNode in oXml.selectNodes("//*[not(*)]")
		if oNode.dataType="bin.hex" Then
			if IsNull(oNode.nodeTypedValue) Then
				nLen = nLen + len(oNode.xml)
			Else
				nLen = nLen + len(oNode.tagName)*2 + 5 +  UBound(oNode.nodeTypedValue)+1
			End if
		Else
			nLen = nLen + len(oNode.xml)
		End if
	Next
	For Each oNode in oXml.selectNodes("//*[*]")
		nLen = nLen + len(oNode.tagName)*2 + 5
	Next
	For Each oNode in oXml.selectNodes("//@*")
		nLen = nLen + len(oNode.xml) + 1
	Next
	X_GetApproximateXmlSize=nLen
End Function


'===============================================================================
'@@X_CreateControlsDisabler
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CreateControlsDisabler>
':����������:
'	������� ������ ControlsDisablerClass.
':���������:
'	oObject - 
'       [in] ������, ������� ����������� - � ��� ���������� ����� <b>EnableControls</b>.
':���������:
'   Function X_CreateControlsDisabler( 
'       oObject [As Variant] 
'   ) [As ControlsDisablerClass]
Function X_CreateControlsDisabler(oObject)
	Set X_CreateControlsDisabler = X_CreateControlsDisablerEx(oObject, Nothing)
End Function


'===============================================================================
'@@X_CreateControlsDisablerEx
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CreateControlsDisablerEx>
':����������:
'	������� ������ ControlsDisablerClass. ��������� ������ ��� ����������� ������, 
'   ��� � ������, �� ������� ������� ���������� �����.
':���������:
'	oObject - 
'       [in] ������, ������� ����������� - � ��� ���������� ����� <b>EnableControls</b>.
'	oSetFocusObject - 
'       [in] ������, �� ������� ��������������� ����� ����� ��������������� - � ��� 
'       ���������� ����� <b>SetFocus</b>.
':���������:
'   Function X_CreateControlsDisablerEx( 
'       oObject [As Variant],
'       oSetFocusObject [As Variant] 
'   ) [As ControlsDisablerClass]
Function X_CreateControlsDisablerEx(oObject, oSetFocusObject)
	Set X_CreateControlsDisablerEx = New ControlsDisablerClass
	X_CreateControlsDisablerEx.DoCreate oObject, oSetFocusObject
End Function


'===============================================================================
'@@ControlsDisablerClass
'<GROUP !!CLASSES_x-utils><TITLE ControlsDisablerClass>
':����������:	
'	����� ��� ��������� ������ ������������ ��������.
'
'@@!!MEMBERTYPE_Methods_ControlsDisablerClass
'<GROUP ControlsDisablerClass><TITLE ������>
Class ControlsDisablerClass
	Private m_oObject
	Private m_oSetFocusObject
	
	'---------------------------------------------------------------------------
	'@@ControlsDisablerClass.DoCreate
	'<GROUP !!MEMBERTYPE_Methods_ControlsDisablerClass><TITLE DoCreate>
	':����������:	
	'	��������� ������������� ���������� ������ ControlsDisablerClass.
	'	��������� �������� ������ � ��������� �����.
	':���������:
    '	oObject - 
    '       [in] ������, ������� ����������� - � ��� ���������� ����� <b>EnableControls</b>.
    '	oSetFocusObject - 
    '       [in] ������, �� ������� ��������������� ����� ����� ��������������� - � ��� 
    '       ���������� ����� <b>SetFocus</b>.
    ':���������:
    '   Public Sub DoCreate( 
    '       oObject [As Variant],
    '       oSetFocusObject [As Variant] 
    '   ) 
	Public Sub DoCreate(oObject, oSetFocusObject)
		If IsNothing(oObject) Then Err.Raise -1, "ControlsDisablerClass::DoCreate", "�������� oObject ������ ���� �����"
		Set m_oObject = oObject
		m_oObject.EnableControls False
		Set m_oSetFocusObject = toObject(oSetFocusObject)
	End Sub
	
	Private Sub Class_Initialize
		Set m_oObject = Nothing
		Set m_oSetFocusObject = Nothing
	End Sub
	
	Private Sub Class_Terminate
		' ��� ����� DoCreate �� ��������, ���� ������
		If Nothing Is m_oObject Then Exit Sub
		m_oObject.EnableControls True
		If Not IsNothing(m_oSetFocusObject) Then
			m_oSetFocusObject.SetFocus
		End If
	End Sub
End Class


'===============================================================================
'@@X_GetHtmlElementScreenPos
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetHtmlElementScreenPos>
':����������:
'	��������� ��������� "��������" ��������� �������� ������ ���� HTML-��������. 
'   ��������� �������������� �������� (��� "�������������" ��������).
':���������:
'	oHtmlElement - 
'       [in] HTML-�������.
'	nPosX - 
'       [out] "��������" ���������� X.
'	nPosY - 
'       [out] "��������" ���������� Y.
':����������:	
'	��������� �������� ���������� <b><i>nPosX</b></i> � <b><i>nPosY</b></i> ������������.
':���������:
'   Sub X_GetHtmlElementScreenPos( 
'       oHtmlElement [As IHTMLDOMElement],
'       ByRef nPosX [As Int],
'       ByRef nPosY [As Int]
'   ) 
Sub X_GetHtmlElementScreenPos( oHtmlElement, ByRef nPosX, ByRef nPosY )
	X_GetHtmlElementRelativePos oHtmlElement, nPosX, nPosY
	nPosX = nPosX + window.top.screenLeft 
	nPosY = nPosY + window.top.screenTop
End Sub


'===============================================================================
'@@X_GetHtmlElementRelativePos
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetHtmlElementRelativePos>
':����������:
'	��������� ��������� ������������� (����) ��������� �������� ������ ���� 
'   HTML-��������. ��������� �������������� �������� (��� "�������������" ��������)
'   � ����������� �������.
':���������:
'	oElement - 
'       [in] HTML-�������.
'	nPosX - 
'       [out] "��������" ���������� X.
'	nPosY - 
'       [out] "��������" ���������� Y.
':����������:	
'	��������� �������� ���������� <b><i>nPosX</b></i> � <b><i>nPosY</b></i> ������������.
':���������:
'   Sub X_GetHtmlElementRelativePos( 
'       oElement [As IHTMLDOMElement],
'       ByRef nPosX [As Int],
'       ByRef nPosY [As Int]
'   ) 
Sub X_GetHtmlElementRelativePos( oElement, ByRef nPosX, ByRef nPosY )

	X_GetHtmlElementRelativePosEx window, oElement, nPosX, nPosY
End Sub

'===============================================================================
'@@X_GetHtmlElementRelativePosEx
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetHtmlElementRelativePosEx>
':����������:
'	��������� ��������� ������������� (����) ��������� �������� ������ ���� 
'   HTML-��������. ��������� �������������� �������� (��� "�������������" ��������)
'   � ����������� �������.
':���������:
'	oWindow - 
'       [in] ������� ���� ��������.
'	oElement - 
'       [in] HTML-�������.
'	nPosX - 
'       [out] "��������" ���������� X.
'	nPosY - 
'       [out] "��������" ���������� Y.
':����������:	
'	��������� �������� ���������� <b><i>nPosX</b></i> � <b><i>nPosY</b></i> ������������.
':���������:
'   Sub X_GetHtmlElementRelativePosEx( 
'       oWindow [As IHTMLWindow],
'       oElement [As IHTMLDOMElement],
'       ByRef nPosX [As Int],
'       ByRef nPosY [As Int]
'   ) 
Sub X_GetHtmlElementRelativePosEx( oWindow, oElement, ByRef nPosX, ByRef nPosY )
	Dim oCurrentElement	' ������� ������� "�������-��������", ���������� �����
	Set oCurrentElement = oElement
	nPosX = 0
	nPosY = 0
	Do
		Do 
			If Not hasValue(oCurrentElement) Then Exit Do
			nPosX = nPosX + oCurrentElement.offsetLeft - oCurrentElement.scrollLeft
			nPosY = nPosY + oCurrentElement.offsetTop - oCurrentElement.scrollTop
			
			If Not hasValue(oCurrentElement.offsetParent) Then Exit Do
			' ������� �������� ������ �.�. "�������" ������� �� ������ ����
			If oCurrentElement Is oCurrentElement.offsetParent Then Exit Do
			
			Set oCurrentElement = oCurrentElement.offsetParent
			
		Loop
		' ���� ������� (oCurrentElement) ��������� � ���� ������, �� ������ � ������������ �������� � ���������
		If oWindow.frameElement Is Nothing Then Exit Do
		Set oCurrentElement = oWindow.frameElement
		Set oWindow = oWindow.Parent
	Loop
End Sub


'===============================================================================
'@@X_SafeFocus
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SafeFocus>
':����������:
'	"����������" ��������� ������ ��� ��������� HTML-��������. ���������� ������ focus 
'   (��������� ������) � HTML, ���� ������� �� ������ ������ ����������.
'   ������ ���������� �������� ���������� ����� ����� �������, ����� ������ �� ���������.
':���������:
'	oHtmlElement - 
'       [in] HTML-�������.
':���������:
'	������� ���������� ��������� ������.
':���������:
'   Function X_SafeFocus( 
'       oHtmlElement [As IHTMLDOMElement]
'   ) [As Boolean]
Function X_SafeFocus( oHtmlElement )
	On Error GoTo 0
	X_SafeFocus = False
	On Error Resume Next
	oHtmlElement.focus
	X_SafeFocus = CBool(0 = Err.Number)
	On Error GoTo 0
End Function


'===============================================================================
'@@X_GetVbsTypeCaseFunc
'<GROUP !!FUNCTIONS_x-utils><TITLE X_GetVbsTypeCaseFunc>
':����������:
'	���������� ������������ VBS-������� ��� ���������� �������� ���������� 
'   ����������� �������� ��������� ����.
':���������:
'	sPropType - 
'       [in] ��� XML-��������.
':���������:
'   Function X_GetVbsTypeCaseFunc( 
'       sPropType [As String]
'   ) [As String]
Function X_GetVbsTypeCaseFunc(sPropType)
	Dim sFunc		' ������������ �������
	Select Case sPropType
		Case "ui1"
			sFunc = "CByte"
		Case "i2"
			sFunc = "CInt"
		Case "i4"
			sFunc = "CLng"
		Case "boolean"
			sFunc = "CBool"
		Case "fixed"
			sFunc = "CCur"
		Case "r4"
			sFunc = "CSng"
		Case "r8"
			sFunc = "CDbl"
		Case "string", "text"
			sFunc = "CStr"
	End Select
	X_GetVbsTypeCaseFunc = sFunc
End Function


'===============================================================================
'@@X_IsSecurityException
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsSecurityException>
':����������:
'	������� ���������, �������� �� �������� ������, ���������� �� ������� ����������, 
'   ��������� ���������� ���� 
'   <LINK Croc.XmlFramework.Public.XSecurityException, XSecurityException />.
':���������:
'	oLastServerErrorXml - 
'       [in] XML-������� � ������� ������, ���������� �� ������� ����������.
':���������:
'   Function X_IsSecurityException( 
'       oLastServerErrorXml [As IXMLDOMElement]
'   ) [As Boolean]
Function X_IsSecurityException(oLastServerErrorXml)
	X_IsSecurityException = X_CheckExceptionType(oLastServerErrorXml, "Croc.XmlFramework.Public.XSecurityException")
End Function 


'===============================================================================
'@@X_IsBusinessLogicException
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsBusinessLogicException>
':����������:
'	������� ���������, �������� �� �������� ������, ���������� �� ������� ����������, 
'   ��������� ���������� ���� 
'   <LINK Croc.XmlFramework.Public.XBusinessLogicException, XBusinessLogicException />.
':���������:
'	oLastServerErrorXml - 
'       [in] XML-������� � ������� ������, ���������� �� ������� ����������.
':���������:
'   Function X_IsBusinessLogicException( 
'       oLastServerErrorXml [As IXMLDOMElement]
'   ) [As Boolean]
Function X_IsBusinessLogicException(oLastServerErrorXml)
	X_IsBusinessLogicException = X_CheckExceptionType(oLastServerErrorXml, "Croc.XmlFramework.Public.XBusinessLogicException")
End Function 

'===============================================================================
'@@X_IsObjectNotFoundException
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsObjectNotFoundException>
':����������:
'	������� ���������, �������� �� �������� ������, ���������� �� ������� ����������, 
'   ��������� ���������� ���� 
'   <LINK Croc.XmlFramework.Data.XObjectNotFoundException, XObjectNotFoundException />.
':���������:
'	oLastServerErrorXml - 
'       [in] XML-������� � ������� ������, ���������� �� ������� ����������.
':���������:
'   Function X_IsObjectNotFoundException( 
'       oLastServerErrorXml [As IXMLDOMElement]
'   ) [As Boolean]
Function X_IsObjectNotFoundException(oLastServerErrorXml)
	X_IsObjectNotFoundException = X_CheckExceptionType(oLastServerErrorXml, "Croc.XmlFramework.Data.XObjectNotFoundException")
End Function 


'===============================================================================
'@@X_IsOutdatedTimestampException
'<GROUP !!FUNCTIONS_x-utils><TITLE X_IsOutdatedTimestampException>
':����������:
'	������� ���������, �������� �� �������� ������, ���������� �� ������� ����������, 
'   ��������� ���������� ���� 
'   <LINK Croc.XmlFramework.Data.XOutdatedTimestampException, XOutdatedTimestampException />.
':���������:
'	oLastServerErrorXml - 
'       [in] XML-������� � ������� ������, ���������� �� ������� ����������.
':���������:
'   Function X_IsOutdatedTimestampException( 
'       oLastServerErrorXml [As IXMLDOMElement]
'   ) [As Boolean]
Function X_IsOutdatedTimestampException(oLastServerErrorXml)
	X_IsOutdatedTimestampException = X_CheckExceptionType(oLastServerErrorXml, "Croc.XmlFramework.Data.XOutdatedTimestampException")
End Function

'===============================================================================
'@@X_CheckExceptionType
'<GROUP !!FUNCTIONS_x-utils><TITLE X_CheckExceptionType>
':����������:
'	������� ���������, �������� �� �������� ������, ���������� �� ������� ����������, 
'   ��������� ���������� ��������� ����.
':���������:
'	oLastServerErrorXml - 
'       [in] XML-������� � ������� ������, ���������� �� ������� ����������.
'	sFullTypeName - 
'       [in] ������������ ���� ������ ����������.
':���������:
'   Function X_CheckExceptionType( 
'       oLastServerErrorXml [As IXMLDOMElement],
'       sFullTypeName [As String]
'   ) [As Boolean]
Function X_CheckExceptionType(oLastServerErrorXml, sFullTypeName)
	X_CheckExceptionType = False
	If Not Nothing Is oLastServerErrorXml Then
		If Not Nothing Is oLastServerErrorXml.selectSingleNode("type-info//type[@n='" & sFullTypeName & "']") Then
			X_CheckExceptionType = True
		End If
	End If
End Function


'===============================================================================
'@@X_HandleError
'<GROUP !!FUNCTIONS_x-utils><TITLE X_HandleError>
':����������:
'	������� ���������� ������ ��������� �� ������ (���� ����).
':���������:
'	True - ���� ��������� ������ ����, False - � ��������� ������.
':���������:
'   Function X_HandleError() [As Boolean]
Function X_HandleError()
	X_HandleError = False
	If X_WasErrorOccured Then
		X_GetLastError.Show
		X_ClearLastServerError
		X_HandleError = True
	End If
End Function


'===============================================================================
'@@X_ResetSession
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ResetSession>
':����������:
'	��������� ������ ������.
':���������:
'   Sub X_ResetSession
Sub X_ResetSession
	Dim sResetUrl ' Url ��� ������ ������
	Dim sBaseUrl  ' ������� Url
	Dim sPageUrl  ' Url �������� �� ������� ���� ��������� ����� ������ ������
	sBaseUrl = XService.BaseURL()
	sPageUrl = MID( window.location.href, len(sBaseUrl)+1)
	sResetUrl = sBaseUrl & "x-reset.aspx?TM=" & CDbl(Now) & "&RET=" & XService.UrlEncode(sPageUrl)
	Window.Navigate  sResetUrl
End Sub

'===============================================================================
'@@X_RunReport
'<GROUP !!FUNCTIONS_x-utils><TITLE X_RunReport>
':����������:
'	��������� ��������� �����, ��������� � ����������.
':���������:
'	sReportName - 
'       [in] ���������������� ������ � ���������� (������� <b>i:report</b>).
'	vUrlArgs - 
'       [in] ���������, ������������ � ������ �������. ������ ��� QueryStringClass
':����������:	
'	� ������, ���� � ���������� ������ ������ ������, �� ��������� ���������
'   x-report-filter.aspx. ����� - ��������� ����� ��������������� �� URL.
':���������:
'   Sub X_RunReport (
'       sReportName [As String], 
'       vUrlArgs [As String | QueryStringClass]
'   )
Sub X_RunReport(sReportName, vUrlArgs)
	Dim oReportMD	    ' ��������� ������ (������� i:report)
	Dim oFilter		    ' ���� �������� ������� (i:filter-direct-url | i:filter-as-editor)
	Dim sUrl		    ' URL ������
	Dim bSendUsingPOST  ' ������� �������� ���������� �� ������ ������� POST
	
	Set oReportMD = XService.XMLGetDocument("x-metadata.aspx?NODE=i%3Areport&NAME=" & sReportName)
	If oReportMD Is Nothing Then
		' ��� ���������� ������. ������� �� ���������
		X_OpenReportEx "x-get-report.aspx?name=" & sReportName & ".xml", vUrlArgs, False
		Exit Sub
	End If
		
	Set oReportMD = oReportMD.documentElement
	Set oFilter = oReportMD.selectSingleNode("i:filter-direct-url | i:filter-as-editor")    
	If oFilter Is Nothing Then
		bSendUsingPOST = LCase(CStr(X_GetAttributeDef(oReportMD, "sendUsingPOST", False)))
		bSendUsingPOST = iif(IsNumeric(bSendUsingPOST), bSendUsingPOST <> "0", bSendUsingPOST = "true")
		sUrl = X_GetAttributeDef(oReportMD, "url", "x-get-report.aspx?name=r-" & sReportName & ".xml")
		X_OpenReportEx sUrl, vUrlArgs, bSendUsingPOST
	Else
		' ��������� URL ���������
		sUrl = XService.BaseUrl() & "x-report-filter.aspx?MetaName=" & sReportName
		' ������� ���������� ���� ���������
		X_ShowModalDialog sURL, vUrlArgs
	End If
End Sub

'===============================================================================
'@@X_SaltPerMonth
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SaltPerMonth>
':����������:
'	Salt-�������: ��������� ���������� ��������, ���������� ��� ������� ������.
':���������:
'	������ ������� "SLT-M-{YYYYMM}", ��� {YYYYMM} - �������� ���� � ������,
'   ��������������� ������� ����.
':����������:	
'	��������� ������������ ��� ������������ URL ��� ���-������, � ���������,
'   � �������� �������� ������, ������������ ��������� ��� (��. ��������
'   ������� X_GetListData).
':���������:
'   Function X_SaltPerMonth() [As String]
Function X_SaltPerMonth() 
	With DateToDateTimeFormatter( Now() )
		X_SaltPerMonth = "SLT-M-" & .YearString & .MonthString
	End With
End Function

'===============================================================================
'@@X_SaltPerWeek
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SaltPerWeek>
':����������:
'	Salt-�������: ��������� ���������� ��������, ���������� ��� ������ ������ 
'   (��� ����������� �� ����/������).
':���������:
'	������ ������� "SLT-W-{YYYYMM}-{W}", ��� {YYYYMM} - �������� ���� � ������,
'   ��������������� ������� ����; {W} - ����� ������ ������.
':����������:	
'   ���� ������ ����� ������ �������� �� �������� ������, �� �����
'   ������ ��������� ������ ������� ������.<P/>
'	��������� ������������ ��� ������������ URL ��� ���-������, � ���������,
'   � �������� �������� ������, ������������ ��������� ��� (��. ��������
'   ������� X_GetListData).
':���������:
'   Function X_SaltPerWeek() [As String]
Function X_SaltPerWeek()
	With DateToDateTimeFormatter( Now() )
		X_SaltPerWeek = "SLT-W-" & .YearString & .MonthString & "-" & .WeekNumString
	End With
End Function


'===============================================================================
'@@X_SaltPerDay
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SaltPerDay>
':����������:
'	Salt-�������: ��������� ���������� ��������, ���������� ��� ������� ������������ ���.
':���������:
'	������ ������� "SLT-D-{YYYYMMDD}", ��� {YYYYMMDD} - �������� ����, ������ � ���,
'   ��������������� ������� ����.
':����������:	
'	��������� ������������ ��� ������������ URL ��� ���-������, � ���������,
'   � �������� �������� ������, ������������ ��������� ��� (��. ��������
'   ������� X_GetListData).
':���������:
'   Function X_SaltPerDay() [As String]
Function X_SaltPerDay() 
	With DateToDateTimeFormatter( Now() )
		X_SaltPerDay = "SLT-D-" & .YearString & .MonthString & .DayString 
	End With
End Function

'===============================================================================
'@@X_SaltPerHour
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SaltPerHour>
':����������:
'	Salt-�������: ��������� ���������� ��������, ���������� ��� ������� ���� ������� 
'   ������������ ���.
':���������:
'	������ ������� "SLT-H-{YYYYMMDD}-{HH}", ��� {YYYYMMDD} - �������� ����, ������ � ���,
'   ��������������� ������� ����; {H} - ����� ����, ���������������� �������� �������.
':����������:	
'	��������� ������������ ��� ������������ URL ��� ���-������, � ���������,
'   � �������� �������� ������, ������������ ��������� ��� (��. ��������
'   ������� X_GetListData).
':���������:
'   Function X_SaltPerHour() [As String]
Function X_SaltPerHour() 
	With DateToDateTimeFormatter( Now() )
		X_SaltPerHour = "SLT-H-" & .YearString & .MonthString & .DayString & "-" & .HourString
	End With
End Function

'===============================================================================
'@@X_SaltPerSession
'<GROUP !!FUNCTIONS_x-utils><TITLE X_SaltPerSession>
':����������:
'	Salt-�������: ��������� ���������� ��������, ���������� ��� ������ ������ 
'   ASP .NET, ������������� ����� �������� � ��������.
':���������:
'	������ ������� "SLT-SESS-{KEY}", ��� {KEY} - �������� ����������� �����,
'   ����������� ��� ������ ������ ASP .NET.
':����������:	
'   ���� ������ �� ������������� ������ ASP .NET, �� � �������� ���������� ������������ 
'   ��������, �������������� ��������� ��� ������� ���� ������� ������������ ���.<P/>
'	��������� ������������ ��� ������������ URL ��� ���-������, � ���������,
'   � �������� �������� ������, ������������ ��������� ��� (��. ��������
'   ������� X_GetListData).
':���������:
'   Function X_SaltPerSession() [As String]
Function X_SaltPerSession() 
	' ������������ cookie, � ������� ASP .NET ��������� "�������������" ������
	Const ASP_NET_SESSION_COOKIE = "ASP.NET_SESSIONID"
	                                                     
	Dim aCookies	' ������ ����� ���� "{����}={��������}", �����. ���� cookie �� �������
	Dim sCookie		' ������ � cookie, ������������ ��� ���������� "��������������" ����� ASP .NET
	Dim nIndex		' �������� �����
	
	sCookie = ""
	' ���� ���� ����������� ������: 
	' ASP .NET ��������� "�������������" ������ � �������� �������� cookie 
	' � ������������� "ASP.NET_SessionId"; ��� ������� �������� ������ �� ����������
	' ���� cookie, � ���� ������ ��� {����}={��������}, ����������� �������� ";",
	' ��������� ������ ����� ��� � �������� ����� ������:
	If 0 <> InStr( UCase(document.cookie), ASP_NET_SESSION_COOKIE ) Then
		aCookies = Split( UCase(document.cookie),";")
		For nIndex=0 to UBound(aCookies)
			If 0 <> InStr( aCookies(nIndex),ASP_NET_SESSION_COOKIE) Then 
				sCookie = Trim( aCookies(nIndex) )
				Exit For
			End If
		Next
	End If
	
	' � ��������� ������ (���� {����}={��������}) �������� ������������ ����� 
	' � ������ "=" ������� ����������, � ����� ������� ���������� � ��������� 
	' �������. ���, �� ����, �������� "������" ��������:
	sCookie = Trim( Replace( Replace( sCookie,ASP_NET_SESSION_COOKIE,"" ), "=", "" ) )
	
	' ���� � ����� �� �������� "������" cookie - �� ������ ��� ����������� 
	' ��������, �������������� ������������� ��� ������� ���� ������� ���:
	If 0 = Len(sCookie) Then
		With DateToDateTimeFormatter( Now() )
			sCookie = "STUB-" & .YearString & .MonthString & .DayString & "-" & .HourString
		End With
	End If
	
	X_SaltPerSession = "SLT-SESS-" & sCookie 
End Function

'===============================================================================
'@@ConfigClass
'<GROUP !!CLASSES_x-utils><TITLE ConfigClass>
':����������:	
'	�����-������� ��� ����� ������������.
'
'@@!!MEMBERTYPE_Methods_ConfigClass
'<GROUP ConfigClass><TITLE ������>
Class ConfigClass
	Private m_oConfig			' IXMLDOMDocument � ������������� ������� ��� Empty
	
	'---------------------------------------------------------------------------
	'@@ConfigClass.GetValue
	'<GROUP !!MEMBERTYPE_Methods_ConfigClass><TITLE GetValue>
	':����������:	
	'	������� ���������� �������� ���� (�������� ��� ��������) ����� ������������.
	':���������:
    '	sXPath - 
    '       [in] ������ � ����� � ���� � ����� ������������ (��������� XPath).
    ':����������:	
    '   ����� ������� ���������� ��������� ������ � ������� ��������� 
    '   <LINK ConfigClass.Load, Load />. 
    ':���������:
    '   Public Function GetValue(
    '       ByVal sXPath [As String] 
    '   ) [As IXMLDOMElement]
	Public Function GetValue(ByVal sXPath)
		Dim oNode	' IXMLDOMElement
		
		If IsEmpty(m_oConfig) Then
			Err.Raise -1, "ConfigClass::GetValue", "������ �� ���������������"
		End If
		Set oNode = m_oConfig.selectSingleNode(sXPath)
		If Not oNode Is Nothing Then
			GetValue = oNode.nodeTypedValue
		End If
	End Function

	'---------------------------------------------------------------------------
	'@@ConfigClass.Load
	'<GROUP !!MEMBERTYPE_Methods_ConfigClass><TITLE Load>
	':����������:	
	'	��������� ��������� �������� ������ � ������� ��� ������������� �� ����.
	':���������:
    '	sSectionXPath - 
    '       [in] ������ � ����� � ������ � ����� ������������ (��������� XPath).
    ':���������:
    '   Public Sub Load(
    '       sSectionXPath [As String] 
    '   ) 
	Public Sub Load(sSectionXPath)
		Dim oServerConfig	' XConfig � �������
		Dim bCached			' ������� ������� ������������ ����������
		Dim sCookie			' ������ cookie, ������������ ��� ����������� ����� ������������� Config � ������
		Dim bLoaded			' �������, ��� ����������� ������ ��������� � �������

		bLoaded = False
		If IsEmpty(m_oConfig) Then
			sCookie = XService.URLEncode( XService.BaseURL()) & "CONFIG=1"
			' �������� ������������ config
			bCached = XService.GetUserData( XCONFIG_STORE, m_oConfig)
			
			' ���� �� ������� ��� Config'a
			If Not bCached Or 0 = InStr( document.cookie, sCookie ) Then
				' ������ ����������� ������ Config � �������
				Set oServerConfig = getSectionFromServer(sSectionXPath)
				If oServerConfig Is Nothing Then Exit Sub
				bLoaded = True
				With XService.XMLGetDocument()
					Set m_oConfig = .appendChild( .createElement("config") )
				End With
				m_oConfig.appendChild oServerConfig
				' ��������� �������� ������� � ���������� ����
				XService.SetUserData XCONFIG_STORE, m_oConfig
			End If
			' ������������� ������������ ���� ��� XPath-��������
			XService.XMLSetSelectionNamespaces m_oConfig.ownerDocument
			' �������������� Cookie
			document.cookie = sCookie
		End If
		If m_oConfig.selectSingleNode(sSectionXPath) Is Nothing And Not bLoaded Then
			' �������� ������ � �������������� ������� ��� � ��� ���� �� ��� �� ������� �� � �������
			Set oServerConfig = getSectionFromServer(sSectionXPath)
			If oServerConfig Is Nothing Then Exit Sub
			m_oConfig.appendChild oServerConfig
			' ��������� �������� ������� � ���������� ����
			XService.SetUserData XCONFIG_STORE, m_oConfig
		End If
	End Sub
		
	'==================================================================
	'	���������� XML ������ XConfig.xml � �������
	Private Function getSectionFromServer(sSectionXPath)
		Set getSectionFromServer = Nothing
		On Error Resume Next
		With New XGetConfigElementRequest
			.m_sName = "GetConfigElement"
			.m_sParameterPath = sSectionXPath
			Set getSectionFromServer = X_ExecuteCommand( .Self ).m_oParameterElement
		End With
		If Err Then 
			X_HandleError
		ElseIf getSectionFromServer Is Nothing Then
			Alert "�� ������� ��������� ������� '" & sSectionXPath & "' ����� ������������ � �������"
		End If 
	End Function
End Class

'===============================================================================
'@@X_Config
'<GROUP !!FUNCTIONS_x-utils><TITLE X_Config>
':����������:
'	������� ���������� ������ ������ ConfigClass, ���� �� ��� �� ������, �� ������� ���.
':���������:
'	sSectionXPath - 
'       [in] ������������ ������ � ����� ������������, ������� �������������� �����������
'       (�� ���� - ��� xpath � ��������� <b>xfw:configuration</b>).
':���������:
'   Function X_Config( 
'       sSectionXPath [As String]
'   ) [As ConfigClass]
Function X_Config(sSectionXPath)
	If Not hasValue(x_oConfig) Then
		Set x_oConfig = New ConfigClass
		x_oConfig.Load sSectionXPath
	End If
	Set X_Config = x_oConfig
End Function

'===============================================================================
' ���������� ��������� ���������� ����������� � XML-������ ���������� ������.
' ���������:
'	oRestrictions - [in] XML-������ ���������� ������.
'	sUrlRestrictions - [in] ������������� ����������� � ���� QueryString-������.
' ���������:
'   Sub internal_TreeInsertRestrictions( 
'       oRestrictions [As IXMLDOMElement],
'       sUrlRestrictions [As String]
'   ) 
Sub internal_TreeInsertRestrictions(oRestrictions, sUrlRestrictions)
	Dim oQS				' ������ ������� (CXQueryString)
	Dim oParamsElement	' ������� params � restrictions
	Dim oParamsFromQS	' ������� params, ���������� �� oQS
	Dim oParam			' ������� param
	
	If 0 = Len( sUrlRestrictions) Then Exit Sub
	'��������� ��
	Set oQS = X_GetEmptyQueryString
	oQS.QueryString = sUrlRestrictions
	
	Set oParamsElement = oRestrictions.selectSingleNode("params")
	' ���� ��� ���� - ��������
	If Nothing Is oParamsElement Then
		' ����������: SerializeToXml ���������� ���� params
		oRestrictions.appendChild( oQS.SerializeToXml() )
	Else
		' ���� params ��� ����, ������� �������� � ���� ��� ���� param �� ���������������� ������� oQS
		Set oParamsFromQS = oQS.SerializeToXml() 
		For Each oParam In oParamsFromQS.selectNodes("param")
			oParamsElement.appendChild oParam
		Next
	End If
End Sub


'===============================================================================
' ���������� ��������� ���������� ������ ����������� ����� � XML-������ ���������� ������.
' ���������:
'	oRestrictions - [in] XML-������ ���������� ������.
'	sExcludeNodes - [in] ������ ����������� �����. ��. ����������� � [x-utils.vbs]SelectFromTreeDialogClass.ExcludeNodes
' ���������:
'   Sub internal_TreeSetExcludeNodes( 
'       oRestrictions [As IXMLDOMElement],
'       sExcludeNodes [As String]
'   ) 
Sub internal_TreeSetExcludeNodes(oRestrictions, sExcludeNodes)
	If hasValue(sExcludeNodes) Then
		sExcludeNodes = Replace(Replace(sExcludeNodes, ";", "|"), ",", "|")
		oRestrictions.setAttribute "exclude", sExcludeNodes
	End If
End Sub


'===============================================================================
'@@IParamCollectionBuilder
'<GROUP !!CLASSES_x-utils><TITLE IParamCollectionBuilder>
':����������:	
'	��������� IParamCollectionBuilder ��� ������������ ��������� ����������.
'   ������������ ��� ������ IFilterObject::GetRestrictions.
'
'@@!!MEMBERTYPE_Methods_IParamCollectionBuilder
'<GROUP IParamCollectionBuilder><TITLE ������>
Class IParamCollectionBuilder

	'---------------------------------------------------------------------------
	'@@IParamCollectionBuilder.AppendParameter
	'<GROUP !!MEMBERTYPE_Methods_IParamCollectionBuilder><TITLE AppendParameter>
	':����������:	
	'	��������� ��������� ���������� ��������� � ��������� ����������.
	':���������:
    '	sParameterName - 
    '       [in] ��� ���������.
    '	sParameterText - 
    '       [in] �������� ��������� � ���� ������ � ������������ � XML DataTypes.
    ':���������:
    '   Public Sub AppendParameter(
    '       sParameterName [As String],
    '       sParameterText [As String]
    '   ) 
	Public Sub AppendParameter(sParameterName, sParameterText)
	End Sub
End Class


'===============================================================================
'@@XmlParamCollectionBuilderClass
'<GROUP !!CLASSES_x-utils><TITLE XmlParamCollectionBuilderClass>
':����������:	
'	���������� ���������� IParamCollectionBuilder. ������������ ��������� ���������. 
':����������:	
'	��������� XML ����:<P/>
'	&lt;p�rams&gt;<P/>
' 		&lt;p�ram name='Name1'&gt;Value1&lt;/p�ram&gt;<P/>
' 		&lt;p�ram name='Name2'&gt;Value2&lt;/p�ram&gt;<P/>
' 		&lt;p�ram name='NameY'&gt;ValueY&lt;/p�ram&gt;<P/>
' 	&lt;/p�rams&gt;
'
'@@!!MEMBERTYPE_Methods_XmlParamCollectionBuilderClass
'<GROUP XmlParamCollectionBuilderClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_XmlParamCollectionBuilderClass
'<GROUP XmlParamCollectionBuilderClass><TITLE ��������>
Class XmlParamCollectionBuilderClass
	'-------------------------------------------------------------------------------
	' ����������:	IXMLDOMElement, DocumentElement ������������
	'				XML-���������, ����������� ��������� ����������
	' ���������:    
	' ���������:	
	' ����������:	
	' �����������:	
	' ������: 		
	Private m_oXmlParametersRoot

	'------------------------------------------------------------------------------
	'@@XmlParamCollectionBuilderClass.XmlParametersRoot
	'<GROUP !!MEMBERTYPE_Properties_XmlParamCollectionBuilderClass><TITLE XmlParametersRoot>
	':����������:	
	'	DocumentElement ������������ XML-���������, ����������� ��������� ����������.
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get XmlParametersRoot [As IXMLDOMElement]
	Public Property Get XmlParametersRoot
		Set XmlParametersRoot = m_oXmlParametersRoot
	End Property
	
	'-------------------------------------------------------------------------------
	' ����������:	�����������
	' ���������:    
	' ���������:	
	' ����������:	
	' �����������:	
	' ������: 		
	Private Sub Class_Initialize
		' �������� �������� - �������� ���������
		Set m_oXmlParametersRoot = _
			XService.XmlFromString( _
				"<?xml version=""1.0"" encoding=""windows-1251""?><params/>" )
	End Sub 
	
	'------------------------------------------------------------------------------
	'@@XmlParamCollectionBuilderClass.AppendParameter
	'<GROUP !!MEMBERTYPE_Methods_XmlParamCollectionBuilderClass><TITLE AppendParameter>
	':����������:	
	'   ���������� ������ 
	'   <LINK IParamCollectionBuilder.AppendParameter, AppendParameter /> 
	'   ���������� IParamCollectionBuilder.
    ':���������:
    '	sParameterName - [in] ������������ ���������.
    '	vParameterText - [in] ��������� ������������� �������� ��������� ��� ������ 
    '                          ����� �������������.
	':���������:	
	'   Public Sub AppendParameter(sParameterName [As String], vParameterText [As Variant])
	Public Sub AppendParameter(sParameterName, vParameterText)
		Dim i
		If Not hasValue(sParameterName) Then Err.Raise -1, "XmlParamCollectionBuilderClass::AppendParameter", "������������ ��������� �� ������"
		If IsArray(vParameterText) Then
			For i=0 To UBound(vParameterText)
				appendScalarParameter sParameterName, vParameterText(i)
			Next
		Else
			appendScalarParameter sParameterName, vParameterText
		End If
	End Sub
	
	'-------------------------------------------------------------------------------
	' ����������:	��������� ��������� �������� ��� ���� �������� ���������� ���������
	Private Sub appendScalarParameter(sParameterName, sParameterText)
		With m_oXmlParametersRoot.appendChild(m_oXmlParametersRoot.ownerDocument.createElement("param"))
			.SetAttribute "n", sParameterName
			If IsEmpty(sParameterText) Or IsNull(sParameterText) Then
				.text = ""
			Else
				.text = sParameterText
			End If
		End With
	End Sub
End Class


'===============================================================================
'@@QueryStringParamCollectionBuilderClass
'<GROUP !!CLASSES_x-utils><TITLE QueryStringParamCollectionBuilderClass>
':����������:	
'	���������� ���������� IParamCollectionBuilder. ������������ ��������� ���������. 
':����������:	
'	��������� ������ ����: Name1=Value1&Name2=Value2&...&NameY=ValueY.
'
'@@!!MEMBERTYPE_Methods_QueryStringParamCollectionBuilderClass
'<GROUP QueryStringParamCollectionBuilderClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_QueryStringParamCollectionBuilderClass
'<GROUP QueryStringParamCollectionBuilderClass><TITLE ��������>
Class QueryStringParamCollectionBuilderClass
	'-------------------------------------------------------------------------------
	' ����������:	������ �����������
	' ���������:    
	' ���������:	
	' ����������:	
	' �����������:	
	' ������: 		
	Private m_sQueryString

	'------------------------------------------------------------------------------
	'@@QueryStringParamCollectionBuilderClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_QueryStringParamCollectionBuilderClass><TITLE QueryString>
	':����������:	
	'	������ �����������.
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get QueryString [As String]
	Public Property Get QueryString
		If IsEmpty(m_sQueryString) Then 
			QueryString = vbNullString
		Else
			QueryString = m_sQueryString
		End If	
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@QueryStringParamCollectionBuilderClass.AppendParameter
	'<GROUP !!MEMBERTYPE_Methods_QueryStringParamCollectionBuilderClass><TITLE AppendParameter>
	':����������:	
	'   ���������� ������ 
	'   <LINK IParamCollectionBuilder.AppendParameter, AppendParameter /> 
	'   ���������� IParamCollectionBuilder.
    ':���������:
    '	sParameterName - [in] ������������ ���������.
    '	vParameterText - [in] ��������� ������������� �������� ��������� ��� ������ 
    '                         ����� �������������.
	':���������:	
	'   Public Sub AppendParameter(sParameterName [As String], vParameterText [As Variant])
	Public Sub AppendParameter(sParameterName, vParameterText)
		Dim i
		If Not hasValue(sParameterName) Then Err.Raise -1, "QueryStringParamCollectionBuilderClass::AppendParameter", "������������ ��������� �� ������"
		If IsArray(vParameterText) Then
			For i=0 To UBound(vParameterText)
				appendScalarParameter sParameterName, vParameterText(i)
			Next
		Else
			appendScalarParameter sParameterName, vParameterText
		End If
		
	End Sub
	
	
	'-------------------------------------------------------------------------------
	' ����������:	��������� ��������� �������� ��� ���� �������� ���������� ���������
	Private Sub appendScalarParameter(sParameterName, sParameterText)
		If Not IsEmpty(m_sQueryString) Then
			m_sQueryString = m_sQueryString & "&"
		End If
		m_sQueryString = m_sQueryString & XService.UrlEncode(sParameterName) & "=" & XService.UrlEncode(sParameterText)
	End Sub
End Class


'===============================================================================
'@@X_DateToXmlType
'<GROUP !!FUNCTIONS_x-utils><TITLE X_DateToXmlType>
':����������:
'	������� ��������� ��� �������� ����/������� ������ � �������������� ����/������� 
'   � ������� XML.
':���������:
'	dtValue - 
'       [in] �������� ����/�����.
'	bAsDateOnly - 
'       [in] ������� ������� � ������ ������ ���� (��� �������).
':���������:
'	������ � ��������������� ���������.
':����������:	
'   ������� ������� XService!
':���������:
'   Function X_DateToXmlType(
'       dtValue [As Date],
'       bAsDateOnly [As Boolean]
'   ) [As String]
Function X_DateToXmlType( dtValue, bAsDateOnly )
	Dim oXml	' ��������� XML
	X_DateToXmlType = vbNullString
	If IsNull(dtValue) Or IsEmpty(dtValue) Then Exit Function
	Set oXml = XService.XMLFromString("<DATE/>")
	If CBool(bAsDateOnly) Then
		oXml.dataType = "date"
	Else
		oXml.dataType = "dateTime.tz"
	End If
	oXml.nodeTypedValue = CDate(dtValue)
	X_DateToXmlType = oXml.text
End Function


'===============================================================================
'@@X_ConvertVarTypeToXmlNodeType
'<GROUP !!FUNCTIONS_x-utils><TITLE X_ConvertVarTypeToXmlNodeType>
':����������:
'	������� ������������ ��� �������� � XML XDR-���.
':���������:
'	sVarType - 
'       [in] ������������ ���a ��������.
':���������:
'	������ � ������������� XML XDR-����.
':���������:
'   Function X_ConvertVarTypeToXmlNodeType(
'       sVarType [As String]
'   ) [As String]
Function X_ConvertVarTypeToXmlNodeType(sVarType)
	Dim vVal
	Select Case sVarType
		Case "fixed":	vVal = "fixed.14.4"
		Case "time":	vVal = "time.tz"
		Case "dateTime":vVal = "dateTime.tz"
		Case "smallBin":vVal = "bin.base64"
		Case Else 		vVal = sVarType
	End Select
	X_ConvertVarTypeToXmlNodeType = vVal
End Function


'==============================================================================
' ��������� �������� ���������� XObjectIdentity.
' ��������: ts ��� ���� ��������������� � -1, 
' ��� �� ��������� ������� ������ ���������� ��� "������������ ts"
'	[in] sObjectType - ������������ ����
'	[in] sObjectID - ������������� ����
Function internal_New_XObjectIdentity(sObjectType, sObjectID)
	With New XObjectIdentity
		.m_sObjectType = sObjectType
		.m_sObjectID = sObjectID
		.m_vTS = -1
		Set internal_New_XObjectIdentity = .Self
	End With
End Function 


'==============================================================================
' ��������� �������� ���������� XObjectPermission.
'	[in] sAction - �������� - ���� �� ��������: ACCESS_RIGHT_CHANGE, ACCESS_RIGHT_CREATE, ACCESS_RIGHT_DELETE
'	[in] sTypeName - ������������ ����
'	[in] sObjectID - ������������� ����
Function internal_New_XObjectPermission(sAction,sTypeName,sObjectID)
	With New XObjectPermission
		.m_sAction = sAction
		.m_sTypeName = sTypeName
		.m_sObjectID = sObjectID
		Set internal_New_XObjectPermission = .Self
	End With
End Function

'===============================================================================
'@@RunCommandDialogClass
'<GROUP !!CLASSES_x-utils><TITLE RunCommandDialogClass>
':����������:	
'	�����, ��������������� ������ �������� � �������� ���������� � ������
'	������� ���������� ��������� �������.
'
'@@!!MEMBERTYPE_Methods_RunCommandDialogClass
'<GROUP RunCommandDialogClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_RunCommandDialogClass
'<GROUP RunCommandDialogClass><TITLE ��������>
Class RunCommandDialogClass
	'---------------------------------------------------------------------------
	'@@RunCommandDialogClass.MetaName
	'<GROUP !!MEMBERTYPE_Properties_RunCommandDialogClass><TITLE MetaName>
	':����������:	������� ���������/�������.
	':���������:	
	'	Public MetaName [As String]
	Public MetaName			
	
	'---------------------------------------------------------------------------
	'@@RunCommandDialogClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_RunCommandDialogClass><TITLE QueryString>
	':����������:	��������� ������ QueryStringClass.
	':���������:	
	'	Public QueryString [As QueryStringClass]
	Public QueryString
	
	'---------------------------------------------------------------------------
	'@@RunCommandDialogClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_RunCommandDialogClass><TITLE ReturnValue>
	':����������:	�������������� �������� (����� ���� ����������� �� ����).
	':���������:	
	'	Public ReturnValue [As Variant]
	Public ReturnValue		

	'------------------------------------------------------------------------------
	'@@RunCommandDialogClass.GetRightsCache
	'<GROUP !!MEMBERTYPE_Methods_RunCommandDialogClass><TITLE GetRightsCache>
	':����������:	
	'	������� ���������� ���������� ���������� ��������� ���� ����, 
	'   ObjectRightsCacheClass.
	':���������:
	'	Public Function GetRightsCache [As ObjectRightsCacheClass]
	Public Function GetRightsCache
		Set GetRightsCache = X_RightsCache()
	End Function
	
	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		Set QueryString = X_GetEmptyQueryString
	End Sub

	'------------------------------------------------------------------------------
	'@@RunCommandDialogClass.Show
	'<GROUP !!MEMBERTYPE_Methods_RunCommandDialogClass><TITLE Show>
	':����������:	
	'	��������� ��������� ���������� ��������� ���� � ����������.
    ':����������:
    '	���������� ������������� ����������/������������������ �������,
    '   ���� �������� ������ �� ������� ������ <b>�K</b>; ����� - Empty.
	':���������:
	'	Public Sub Show
	Public Sub Show
		' ������� ���������� ���� ���������
		X_ShowModalDialogEx _
			XService.BaseUrl() & "x-command-executor.aspx?MetaName=" & MetaName & "&SCREENWIDTH=" & window.screen.availWidth & "&SCREENHEIGHT=" & window.screen.availHeight, Me, "help:no;center:yes;status:no"
	End Sub
End Class

'===============================================================================
'@@X_RunCommandUI
'<GROUP !!FUNCTIONS_x-utils><TITLE X_RunCommandUI>
':����������:
'	��������� ��������� ������ ������� ���������� ��������� ������� �� ��������� 
'   �������� <b>i:command</b>.
':���������:
'	sMetaName - 
'       [in] ������� �������� <b>i:command</b> (�������� �������� �������� <b>n</b>).
'	sUrlArguments - 
'       [in] ������ � ����������� ���������� ��������� ������� (� ���� URL).
'	vReturnValue - 
'       [out] ��������� ������ �������.
':���������:
'   Sub X_RunCommandUI( 
'       sMetaName [As String],
'       sUrlArguments [As String],
'       ByRef vReturnValue [As Variant]
'   ) 
Sub X_RunCommandUI(sMetaName, sUrlArguments, ByRef vReturnValue)
	With New RunCommandDialogClass
		.MetaName = sMetaName
		.QueryString.QueryString = sUrlArguments
		.Show
		If IsObject(.ReturnValue) Then
			Set vReturnValue = .ReturnValue
		Else
			vReturnValue = .ReturnValue
		End If	
	End With
End Sub


'===============================================================================
'@@AsynOperationExecutorClass
'<GROUP !!CLASSES_x-utils><TITLE AsynOperationExecutorClass>
':����������:	
'	�����, ��������������� ������ �������� ���������� � � ���������� �����������
'	�������
':����������:
'	� ����������� ���� ���������� ��������� ������� ������. 
'	��� ���������� ������� ������������ ������� 
'	AsynOperationExecutorClass_Execute, ������� � ��� ��������� ������� ������. 
':��. �����:
'	AsynOperationExecutorClass_Execute
'
'@@!!MEMBERTYPE_Methods_AsynOperationExecutorClass
'<GROUP AsynOperationExecutorClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_AsynOperationExecutorClass
'<GROUP AsynOperationExecutorClass><TITLE ��������>
Class AsynOperationExecutorClass
	'@@AsynOperationExecutorClass.ShowProgress
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE ShowProgress>
	':����������:	��������� ������������� ��������� �������� � ��������� 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	'	���� ��������� ��������� ������������ ������������
	'	������������� GIF x-execute-command-async.gif
	'   ��� ��������� ����� ������������ http://www.ajaxload.info/
	'   ��� ����� ������� ������ http://www.napyfab.com/ajax-indicators/
	'		http://mentalized.net/activity-indicators/
	'		http://www.ajax.su/ajax_activity_indicators.html
	'		
	':���������:	Public ShowProgress [As Boolean]
	Public ShowProgress
	
	'@@AsynOperationExecutorClass.Request
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE Request>
	':����������:	������ �� ���������� ����������� ������� 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	Public Request [As XRequest]
	Public Request
	
	'@@AsynOperationExecutorClass.Response
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE Response>
	':����������:	��������� ���������� ����������� ������� 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	Public Response [As XResponse]
	Public Response
	
	'@@AsynOperationExecutorClass.Aborted
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE Aborted>
	':����������:	������� ���� ��� ������������ ������� ���������� �������  
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	Public Aborted [As Boolean]
	Public Aborted
	
	'@@AsynOperationExecutorClass.DialogHeight
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE DialogHeight>
	':����������:	������ ���� � �������� 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	Public DialogHeight [As Long]
	Public DialogHeight
	
	'@@AsynOperationExecutorClass.DialogWidth
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE DialogWidth>
	':����������:	������ ���� � �������� 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	Public DialogWidth [As Long]
	Public DialogWidth
	
	'@@AsynOperationExecutorClass.DialogTitle
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE DialogTitle>
	':����������:	��������� ������� 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	Public Caption [As String]
	Public DialogTitle
	
	'@@AsynOperationExecutorClass.Caption
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE Caption>
	':����������:	��������� ���� 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	'	�������� ����� ��������� HTML-���
	':���������:	Public Caption [As String]
	Public Caption	
	
	'@@AsynOperationExecutorClass.Self
	'<GROUP !!MEMBERTYPE_Properties_AsynOperationExecutorClass><TITLE Self>
	':����������:	 
	':����������:	
	':���������:	Public Property Get Self [As AsynOperationExecutorClass]
	Public Property Get Self
		Set Self = Me
	End Property
	
	
	
	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		ShowProgress = True
		Set Request = Nothing
		Caption = "���������� ��������..."
		DialogTitle = Caption
		DialogWidth		=	400
		DialogHeight	=	280
	End Sub
End Class


'===============================================================================
'@@AsynOperationExecutorClass_Execute
'<GROUP !!FUNCTIONS_x-utils><TITLE AsynOperationExecutorClass_Execute>
':����������:
'	������� ��������� ���������� ��������� ���� ��� ���������� ����������� ��������.
':���������:
'	oAsynOperationExecutor - 
'       [in] ��������� AsynOperationExecutorClass.
':����������:
'	������� �������� �� ������ AsynOperationExecutorClass ��� ����, ����� �� 
'	����������� ���� ��������� ������� (��-�� ������ � VBScript-runtime, 
'	���������� � "stack overflow at line 0").
':���������:
'   Function AsynOperationExecutorClass_Execute ( 
'       oAsynOperationExecutor [As AsynOperationExecutorClass]
'   ) [As Variant]
Sub AsynOperationExecutorClass_Execute(oAsynOperationExecutor)
	On Error GoTo 0
	oAsynOperationExecutor.Aborted = True
	Set oAsynOperationExecutor.Response = Nothing
	Dim vResult
	vResult = X_ShowModalDialogEx(XService.BaseURL & "x-execute-command-async.aspx?progress=" & iif(oAsynOperationExecutor.ShowProgress,1,0) & "&title=" & XService.UrlEncode("" & oAsynOperationExecutor.DialogTitle), oAsynOperationExecutor, "dialogWidth:" & oAsynOperationExecutor.DialogWidth & "px;dialogHeight:" & oAsynOperationExecutor.DialogHeight & "px;help:no;center:yes;status:no")

	If IsArray(vResult) Then
		If UBound(vResult) = 3 Then
			X_SetLastServerError vResult(0), vResult(1), vResult(2), vResult(3)
			X_GetLastError.Show
			Exit Sub
		End If
	End If
	X_ClearLastServerError
	If Not IsNothing(oAsynOperationExecutor.Response) Then
		' � ������ ������������� �����
		Dim oResponse
		Set oResponse = Eval("New " & oAsynOperationExecutor.Response.documentElement.tagName)
		Set oAsynOperationExecutor.Response = oResponse.Deserialize(oAsynOperationExecutor.Response.documentElement)
	End If
End Sub



'</SCRIPT>
