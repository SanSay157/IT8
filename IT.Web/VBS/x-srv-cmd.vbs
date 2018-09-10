'===============================================================================
'@@!!FILE_x-srv-cmd
'<GROUP !!SYMREF_VBS>
'<TITLE x-srv-cmd - ������������ ��������� ������>
':����������:	������������ ��������� ������
'@@!!CLASSES_x-srv-cmd
'<GROUP !!FILE_x-srv-cmd><TITLE ������>
'@@!!FUNCTIONS_x-srv-cmd
'<GROUP !!FILE_x-srv-cmd><TITLE ������� � ���������>
'<SCRIPT LANGUAGE="VBScript">
Option Explicit

'===============================================================================
'@@MemberInfo
'<GROUP !!CLASSES_x-srv-cmd><TITLE MemberInfo>
':����������:	�������� ���������� ����/�������� ����.
'@@!!MEMBERTYPE_Properties_MemberInfo
'<GROUP MemberInfo><TITLE ��������>
'
Class MemberInfo
 '@@MemberInfo.Name
	'<GROUP !!MEMBERTYPE_Properties_MemberInfo><TITLE Name>
	':����������:	���
	':���������:	Public Name [String]	
	Public Name				' ���
	'@@MemberInfo.Prefix
	'<GROUP !!MEMBERTYPE_Properties_MemberInfo><TITLE Prefix>
	':����������:	�������
	':���������:	Public Prefix [String]	
	Public Prefix			' �������
	'@@MemberInfo.CLRType
	'<GROUP !!MEMBERTYPE_Properties_MemberInfo><TITLE CLRType>
	':����������:	CLR ���, ��� �� ��������������� �� �������
	':���������:	Public CLRType [String]	
	Public CLRType			' CLR ���, ��� �� ��������������� �� �������
End Class


'==============================================================================
Public Function X_WrapSerializedXRequest(sRequestFullTypeName, oXmlRequest)
	Dim oXmlRoot
	Set oXmlRoot = XService.XmlFromString("<?xml version=""1.0"" encoding=""windows-1251""?><XRequestData xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" ><XmlData/></XRequestData>")
	oXmlRoot.setAttribute "TypeName", sRequestFullTypeName
	oXmlRoot.FirstChild.appendChild oXmlRequest
	Set X_WrapSerializedXRequest = oXmlRoot.ownerDocument
End Function


'==============================================================================
'@@XSerializerClass
'<GROUP !!CLASSES_x-srv-cmd><TITLE XSerializerClass>
':����������: 
'   ��������������� �����-�������, ����������� XML-�������� "���������������"
'   ������ XRequest. ��� ������� ���� �������� ����� ���������� �������� RequestTypeFullName, ���� 
'	�������� ���������� ��� (RequestTypeName), ������������ ����(NameSpace) � ������������ ������ (AssemblyName).
'	���� ��� ������ �� ������ ������������ ������������ ������������ ����.
'@@!!MEMBERTYPE_Methods_XSerializerClass
'<GROUP XSerializerClass><TITLE ������>
Class XSerializerClass
	Private m_oXmlRoot			' As IXMLDOMElement - �������� ���� ���������������� xml-�������
		 
	'--------------------------------------------------------------------------
	'@@XSerializerClass.Init
	'<GROUP !!MEMBERTYPE_Methods_XSerializerClass><TITLE Init>
	':����������:	������������� ���������� ������
	':���������:	Public Sub Init(ByVal sCLRTypeName [as String])	
	':���������:	
	'   sCLRTypeName - 
	'       [in] ������������ CLR-���� ����/�������� �������
	
	Public Sub Init(ByVal sCLRTypeName)
		Set m_oXmlRoot = XService.XmlFromString("<?xml version=""1.0"" encoding=""windows-1251""?><" & sCLRTypeName & " xmlns:dt=""urn:schemas-microsoft-com:datatypes""/>")
	End	Sub

		
	'--------------------------------------------------------------------------
	'@@XSerializerClass.AddParameter
	'<GROUP !!MEMBERTYPE_Methods_XSerializerClass><TITLE AddParameter>
	':����������:	��������� ���� "������������" - "��������" � XML-�������� "����������������" �������
	':���������:	Public Sub AddParameter(
	'        sName [as Sting], 
	'        vValue [as Variant], 
	'        sCLRTypeName [as String], 
	'        bIsAttribute [as Boolean] )
	':���������:	
	'   sName - 
	'       [in] ������������ ���������
	'   vValue - 
	'       [in] �������� ���������
	'   sCLRTypeName - 
	'       [in] ������������ CLR-���� ����/�������� �������
	'   bIsAttribute - 
	'       [in] ���� �������� true, �� ��������������� � �������, ����� � �������
		
	Public Sub AddParameter( sName, vValue, sCLRTypeName, bIsAttribute )
		If IsEmpty(m_oXmlRoot) Then Err.Raise -1, "XSerializerClass::AddParameter", "XSerializerClass �� ���������������"
		internal_AddParameter sName, vValue, sCLRTypeName, bIsAttribute, m_oXmlRoot
	End Sub
	
	
	Private Sub internal_AddParameter( sName, vValue, sCLRTypeName, bIsAttribute, oParentNode )
		Dim oNode			' ���� �������� ���������������� �������
		Dim sScalarType		' ������������ ���������� CLR-����
		Dim i
		Dim oValueNode		' xml-���� �� ��������� ����
		Dim bAppend			' �������, ��� �������������� ���� ����������� � xml-�������
		Dim sTagName		' ������������ ���� �������� �������
		Dim sAttrValue		' �������� ��������
		Const vbByteArray = &h2010	' "�����������" ��� ��������, ������� � VBS �������������� �� ��� ������ �������
		
		If IsDefined(vValue) Then
			bAppend = False
			' �������� xml-���� ��� �������� (��� ���� �������, ���� ������� - ������������ ���������� � C#) 
			If bIsAttribute Then
				set oValueNode = m_oXmlRoot.ownerDocument.createAttribute(sName)
			Else
				Set oValueNode = m_oXmlRoot.ownerDocument.createElement(sName)
			End If	
			With oValueNode
				If IsCLRTypeArray(sCLRTypeName) Then
					' ������ (� ��� ����� ArrayList, �� ��� Byte[])
					If IsArray(vValue) Then
						If VarType(vValue) = vbByteArray Then
							Err.Raise -1, "internal_AddParameter", "������ ��������� ���� vbByte �� ��������������. TypeName=" & TypeName(vValue)
						End If
						' � �������� ������ - ��� ���������
						sScalarType = GetArrayItemType(sCLRTypeName)
						bAppend = True
						If IsCLRTypeArray(sScalarType) Then Err.Raise -1, "XSerializerClass::AddParameter", "����������� ������� �� ��������������"
						' ������ (�����)                 
						If bIsAttribute Then
							' ������������� ��� ������������������ �������� ����� ������
							For i=0 To UBound(vValue)
								Set oNode = m_oXmlRoot.ownerDocument.createElement("node")
								If SerializeSimpleCLRType( oNode, vValue(i), sScalarType) Then
									sAttrValue = sAttrValue & oNode.text & " "
								End If
							Next
							oValueNode.text = RTrim(sAttrValue)
						Else
							' ������������� ���: <��������><���>vValue(0)</���><���>vValue(1)</���></��������>
							For i=0 To UBound(vValue)
								sTagName = getArrayElementTagName(sCLRTypeName, sScalarType, vValue(i))
								internal_AddParameter sTagName, vValue(i), sScalarType, false, oValueNode
							Next
						End If
					Else
						Err.Raise -1, "XSerializerClass::AddParameter", "vValue must be array!"
					End If	
				ElseIf sCLRTypeName = "XmlElement" Then
					.appendChild vValue.cloneNode(true)
					bAppend = True
				ElseIf IsObject(vValue) Then
					' ������
					' TODO: On Error Resume Next
					Dim oObject
					Set oObject = vValue.Serialize()
					For Each oNode In oObject.ChildNodes
						.appendChild oNode
					Next
					For Each oNode In oObject.SelectNodes("@*")
						.setAttribute oNode.nodeName, oNode.text
					Next
					bAppend = True
				Else
					' ������������ ���
					bAppend = SerializeSimpleCLRType( oValueNode, vValue, sCLRTypeName )
				End If
			End With
			If bAppend Then
				If bIsAttribute Then
					oParentNode.setAttributeNode oValueNode
				Else
					oParentNode.appendChild oValueNode
				End If
			End If
		End If
	End Sub
	
	'--------------------------------------------------------------------------
	'
	
	Public Function getArrayElementTagName(sCLRType, sScalarType, vValue)
		Dim sTagName	' ������������ ��������
		Select Case sCLRType
			Case "Guid[]":		sTagName = "guid"
			Case "Char[]":		sTagName = "char"
			Case "String[]":	sTagName = "string"
			Case "Int16[]":		sTagName = "short"
			Case "Int32[]":		sTagName = "int"
			Case "Int64[]":		sTagName = "long"
			Case "Single[]":	sTagName = "float"
			Case "Double[]":	sTagName = "double"
			Case "Boolean[]":	sTagName = "boolean"
			Case "Decimal[]":	sTagName = "decimal"
			Case "DateTime[]":	sTagName = "dateTime"
			Case Else
				If IsObject(vValue) Then
					sTagName = TypeName(vValue)
					If sTagName = "IXMLDOMElement" Then
						sTagName = "XmlElement"
					End If
				Else
					If sScalarType = "Object" Then
						Select Case VarType(vValue)
							Case vbInteger:	sTagName = "short"
							Case vbLong:	sTagName = "long"
							Case vbSingle:	sTagName = "float"
							Case vbDouble:	sTagName = "double"
							Case vbCurrency:sTagName = "decimal"
							Case vbDate:	sTagName = "dateTime"
							Case vbString:	sTagName = "string"
							Case vbBoolean:	sTagName = "boolean"
							Case vbByte:	sTagName = "unsignedByte"
							Case Else
								Err.Raise -1, "", "����������������� ������: " & TypeName(vValue)
						End Select
					Else
						sTagName = sScalarType
					End If
				End If
		End Select
		getArrayElementTagName = sTagName 
	End Function
	
	'--------------------------------------------------------------------------
	'����������� ��������� CLR-��� (�.�. �� ������) � xml-���� [retval]: True - �������� ���������, False - �������� �� ���������
	
	
	Public Function SerializeSimpleCLRType(oValueNode, ByVal vValue, sCLRTypeName)
		SerializeSimpleCLRType = False
		If IsNull(vValue) Then Exit Function
		If IsEmpty(vValue) Then Exit Function
		Select Case sCLRTypeName
			Case "Guid"
				' Guid - � ������ ���������� �������� ��������� ������� ����
				oValueNode.text = vValue
			Case "DateTime"
				' �����: XmlSerializer ��� DateTime (��)����������� � time zone!
				oValueNode.dataType = "dateTime.tz"
				oValueNode.nodeTypedValue = CDate(vValue)
			Case "Decimal"
				oValueNode.dataType = "fixed.14.4"
				oValueNode.nodeTypedValue = CCur(vValue)
			case "Char"
				oValueNode.dataType = "char"
				oValueNode.nodeTypedValue = vValue
			case "Byte"
				oValueNode.dataType = "ui1"
				oValueNode.nodeTypedValue = vValue
			case "Int16"
				oValueNode.dataType = "i2"
				oValueNode.nodeTypedValue = vValue
			case "Int32"
				oValueNode.dataType = "i4"
				oValueNode.nodeTypedValue = vValue
			case "Int64"
				oValueNode.text = vValue
			case "Single"
				oValueNode.dataType = "r4"
				oValueNode.nodeTypedValue = vValue
			case "Double"
				oValueNode.dataType = "r8"
				oValueNode.nodeTypedValue = vValue
			case "Boolean"
				oValueNode.text = iif( CBool(vValue), "true", "false")
			case "Byte[]"
				oValueNode.dataType = "bin.base64"
				oValueNode.nodeTypedValue = vValue
			Case "String"
				oValueNode.dataType = "string"
				oValueNode.nodeTypedValue = vValue
			Case Else
				oValueNode.text = vValue
		End Select
		SerializeSimpleCLRType = True
	End Function
	
	'--------------------------------------------------------------------------
	'@@XSerializerClass.ToXml
	'<GROUP !!MEMBERTYPE_Methods_XSerializerClass><TITLE ToXml>
	':����������:	��������� XML-������� "����������������" �������. ���������:    XML-�������� (IXMLDOMDocument)
	Public Function ToXml()
		Set ToXml = m_oXmlRoot
	End Function 
End Class


'==============================================================================
    '@@X_ExecuteCommandXmlEx
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ExecuteCommandXmlEx>
	':����������: �������� ��������� ������� � ��������������� �������� �������.
    ' ������ ����� ��� ������ ��������� ������ � �������. � ������ ������������� ��������� ������ 
    ' ��� ������������� � ���������� ���������� ����, ������� ����� �������� 
    ' ����� X_GetLastError.
    ' ������ �� �������.
	':���������:	Function X_ExecuteCommandXmlEx( oRequestXmlDomDocument [As XMLDOMDocument],
	'       oXService [As XClientService])
	':���������:	
	'   oRequestXmlDomDocument - 
	'       [in] XML-�������� � ��������������� �������� ������� ��������� �������
	'   oXService - 
	'       [in] ��������� ActiveX CROC.XClientService; ����� ���� Nothing; � ���� ������ � �������� ���������� ���������� ������������ ��������� ������ � ��������������� "XService"
	
Function X_ExecuteCommandXmlEx( oRequestXmlDomDocument, oXService )
	If oXService Is Nothing Then Set oXService = XService

	On Error Resume Next
	Set X_ExecuteCommandXmlEx = oXService.XMLGetDocument( "x-execute-command.aspx?action=Exec&tm=" & oXService.NewGuidString, oRequestXmlDomDocument, false )
	If Err Then
		X_SetLastServerError oXService.LastServerError, -1, Err.Source, Err.Description
		On Error Goto 0
		X_GetLastError.RaiseError
	Else
		X_ClearLastServerError
	End If
End Function


'==============================================================================
    '@@X_ExecuteCommandXml
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ExecuteCommandXml>
 	':����������:
    '            �������� ��������� ������� � ��������������� �������� �������.
    '            ������ ������� X_ExecuteCommandXmlEx, ��� �������� ���������� XService, 
    '            ��� �������� �������������.
    '            ������ ����� ��� ������ ��������� ������ � �������. � ������ ������������� ��������� ������ 
    '            ��� ����������� � ���������� ���������� ����, ������� ����� �������� 
    '            ����� X_GetLastError.
    '            ������ �� �������.
	':���������: Function X_ExecuteCommandXml(oRequestXmlDomDocument [As XMLDOMDocument])
   	':���������:	
	'   oRequestXmlDomDocument - 
	'       [in] XML-�������� � ��������������� �������� ������� ��������� �������
    
Function X_ExecuteCommandXml( oRequestXmlDomDocument )
	Set X_ExecuteCommandXml = X_ExecuteCommandXmlEx( oRequestXmlDomDocument, Nothing ) 
End Function


'==============================================================================
    '@@X_ExecuteCommandAsyncXml
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ExecuteCommandAsyncXml>
    ':����������:	
    '            ���������� �������� ��������� ������� � ��������������� �������� �������.
    '            ������ ����� ��� ������ ��������� ������ � �������.
    '            � ������ ������������� ��������� ������ ��� ������������� � ���������� ���������� ����, ������� ����� �������� ����� X_GetLastError.
    '            ������ �� �������.
	':���������: Function X_ExecuteCommandAsyncXml(oRequestXmlDomDocument)
   	':���������:	
	'   oRequestXmlDomDocument - 
	'       [in] XML-�������� � ��������������� �������� ������� ��������� �������
	
Function X_ExecuteCommandAsyncXml(oRequestXmlDomDocument)
	On Error Resume Next
	X_ExecuteCommandAsyncXml = XService.XMLExecOperation( "x-execute-command.aspx?action=ExecAsync&tm=" & XService.NewGuidString, oRequestXmlDomDocument)
	If Err Then
		X_SetLastServerError XService.LastServerError, -1, Err.Source, Err.Description
		On Error Goto 0
		X_GetLastError.RaiseError
	Else
		X_ClearLastServerError
	End If
End Function


    '==============================================================================
    '@@X_QueryCommandResultXml
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_QueryCommandResultXml>
    ':����������:	
    '           ���������� ������ (������ ��� ���������) ���������� ���������� ��������� ��������.
    '           ������ ����� ��� ������ ��������� ������ � �������.
    '           � ������ ������������� ��������� ������ ��� ������������� � ���������� ���������� ����, ������� ����� �������� ����� X_GetLastError.
    '           ������ �� �������.
    ':���������: Function X_QueryCommandResultXml(sCommandID [as String])
    ':���������:	
	'   sCommandID - 
	'       [in] ���������� ������������� ����������� �� ������� �������, ���������� � ���������� ������ X_ExecuteCommandAsyncXml
   
Function X_QueryCommandResultXml(sCommandID)
	On Error Resume Next
	Set X_QueryCommandResultXml = XService.XMLGetDocument( "x-execute-command.aspx?action=QueryResult&AsyncCmdID=" & sCommandID & " &tm=" & XService.NewGuidString, "", false )
	If Err Then
		X_SetLastServerError XService.LastServerError, -1, Err.Source, Err.Description
		On Error Goto 0
		X_GetLastError.RaiseError
	Else
		X_ClearLastServerError
	End If
End Function


'==============================================================================
    '@@X_ResumeCommandXml
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ResumeCommandXml>
    ':����������:	
    '            ���������� ��������� �������, ����� ���������� � ������� X_ExecuteCommandAsyncXml
    '            � ������ ��������� ������ ��� ������������� � ���������� ���������� ����, ������� ����� �������� ����� X_GetLastError.
    '            ������ �� �������.
    ':���������: Sub X_ResumeCommandXml(sCommandID [as String], oRequestXmlDomDocument [as XMLDOMDocument])
    ':���������:	
	'   sCommandID - 
	'       [in] ���������� ������������� ����������� �� ������� �������, ���������� � ���������� ������ X_ExecuteCommandAsyncXml
	'   oRequestXmlDomDocument - 
	'       [in] xml-�������� � ��������������� �������� ������� ��������� �������
  
Sub X_ResumeCommandXml(sCommandID, oRequestXmlDomDocument)
	On Error Resume Next
	XService.XMLExecOperation "x-execute-command.aspx?action=Resume&AsyncCmdID=" & sCommandID & " &tm=" & XService.NewGuidString, oRequestXmlDomDocument
	If Err Then
		X_SetLastServerError XService.LastServerError, -1, Err.Source, Err.Description
		On Error Goto 0
		X_GetLastError.RaiseError
	Else
		X_ClearLastServerError
	End If
End Sub

'==============================================================================
    '@@X_HasRightsToExecuteXml
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_HasRightsToExecuteXml>
    ':����������:	
    '            �������� ����� ��������� ������� � ��������������� �������� �������.
    '            � ������ ������������� ��������� ������ ��� ������������� � ���������� ���������� ����, ������� ����� �������� ����� X_GetLastError.
    '            ������ �� �������.
    ':���������: Function X_HasRightsToExecuteXml(oRequestXmlDomDocument [As XMLDOMDocument]) As Boolean
    ':���������:	
	'   oRequestXmlDomDocument - 
	'       [in] xml-�������� � ��������������� �������� ������� ��������� �������
    ':���������: Facade.HasRightsToExecute: true - ������ � �������� ��������, false - ���
Function X_HasRightsToExecuteXml(oRequestXmlDomDocument)
	Dim oXmlResponse
	On Error Resume Next
	Set oXmlResponse = XService.XMLGetDocument( "x-execute-command.aspx?action=ExecGuard&tm=" & XService.NewGuidString, oRequestXmlDomDocument, false )
	If Err Then
		X_SetLastServerError XService.LastServerError, -1, Err.Source, Err.Description
		On Error Goto 0
		X_GetLastError.RaiseError
	Else
		On Error Goto 0
		X_HasRightsToExecuteXml = oXmlResponse.documentElement.nodeTypedValue
		X_ClearLastServerError
	End If
End Function 

'==============================================================================
    '@@X_HasRightsToExecute
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_HasRightsToExecute>
	':����������:	
    '            �������� ����� ��������� ������� � �������� �������.
    ':���������: Function X_HasRightsToExecute(oRequest) As Boolean
    ':���������:	
	'   oRequest - 
	'       [in] ��������� VBS-������, ��������������� ���������� ������-���������� XRequest, ��� ������ ��������� �������. VBS-����� ������ ��������� ����� Serialize
    ':���������: Facade.HasRightsToExecute: true - ������ � �������� ��������, false - ���
Function X_HasRightsToExecute(oRequest)
	Dim oXmlRequest		' ��������������� Request
	
	If Not hasValue(oRequest.m_sName) Then
		Err.Raise -1, "X_HasRightsToExecute", "�� ������ ������������ �������"
	End If
	Set oXmlRequest = X_WrapSerializedXRequest(oRequest.CLRFullTypeName, oRequest.Serialize())
	X_HasRightsToExecute = X_HasRightsToExecuteXml(oXmlRequest)
End Function

'==============================================================================
    '@@X_TerminateCommand
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_TerminateCommand>
	':����������:	
    '            ��������� ��������� �������, ����� ���������� � ������� X_ExecuteCommandAsyncXml
    '            � ������ ��������� ������ ��� ������������� � ���������� ���������� ����, ������� ����� �������� ����� X_GetLastError.
    '            ������ �� �������.
    ':���������: Sub X_TerminateCommand(sCommandID [as String])
    ':���������:	
	'   sCommandID - 
	'       [in] ���������� ������������� ����������� �� ������� �������, ���������� � ���������� ������ X_ExecuteCommandAsyncXml
    
Sub X_TerminateCommand(sCommandID)
	On Error Resume Next
	XService.XMLExecOperation "x-execute-command.aspx?action=Terminate&AsyncCmdID=" & sCommandID & " &tm=" & XService.NewGuidString
	If Err Then
		X_SetLastServerError XService.LastServerError, -1, Err.Source, Err.Description
		On Error Goto 0
		X_GetLastError.RaiseError
	Else
		X_ClearLastServerError
	End If
End Sub

'==============================================================================
    '@@X_ExecuteCommandEx
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_TerminateCommand>
	':����������:	
    '            ����� �������, ��������� ���������� ������            
    ':���������: Function X_ExecuteCommandEx( oRequest, oXService )
    ':���������:	
	'   oRequest - 
	'       [in] ��������� VBS-������, ��������������� ���������� ������ ���������� XRequest, ��� ������ ��������� �������. VBS-����� ������ ��������� ����� Serialize
	'   oXService - 
	'       [in] ��������� ActiveX CROC.XClientService, ����� ������� ����� ����������� ������ �� ������. ����� ���� Nothing; � ���� ������ � ���. ���������� ���������� ������������ ��������� ������ � ��������������� "XService"
    ':���������: ��������� VBS-������, ��������������� ���������� ������-���������� XResponse, ����������� �� ��������� �������.
Function X_ExecuteCommandEx( oRequest, oXService )
	Dim oXmlRequest		' ��������������� Request
	Dim oXmlResponse	' ��������������� Response
	Dim oResponse       ' ����������������� Response
	
	If Not hasValue(oRequest.m_sName) Then
		Err.Raise -1, "X_ExecuteCommand", "�� ������ ������������ �������"
	End If
	Set oXmlRequest = X_WrapSerializedXRequest(oRequest.CLRFullTypeName, oRequest.Serialize())
	Set oXmlResponse = X_ExecuteCommandXmlEx( oXmlRequest, oXService )
	Set oResponse = Eval("New " & oXmlResponse.documentElement.tagName)
	Set X_ExecuteCommandEx = oResponse.Deserialize( oXmlResponse.documentElement )
End Function

'==============================================================================
    '@@X_ExecuteCommand
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ExecuteCommand>
	':����������:	
    '            ����� �������, ��������� ���������� ������
    '            ������ ������� X_ExecuteCommandEx, ��� �������� �������������.  
    ':���������: Function X_ExecuteCommand( oRequest )
    ':���������:	
	'   oRequest - 
	'       [in] ��������� VBS-������, ��������������� ���������� ������ ���������� XRequest, ��� ������ ��������� �������. VBS-����� ������ ��������� ����� Serialize
	':���������: ��������� VBS-������, ��������������� ���������� ������-���������� XResponse, ����������� �� ��������� �������.
Function X_ExecuteCommand( oRequest )
	Set X_ExecuteCommand = X_ExecuteCommandEx( oRequest, Nothing )
End Function

'==============================================================================
    '@@X_ExecuteCommandSafe
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ExecuteCommandSafe>
	':����������:	
    '               ��������� ��������� ������� (��������� X_ExecuteCommand), �� � ������� �� X_ExecuteCommand,
    '               � ������ ��������� ������ ������ ���������� ���������.
    '               ����� ������� ������� ����� ������������ � ��� �������, ����� ��� ������������� � ��������� ��������� ����� ����������.
    '               ��������� � ������������ �������� ��������� � X_ExecuteCommand
    ':���������: Function X_ExecuteCommandSafe(oRequest)
    ':���������:	
	'   oRequest - 
	'       [in] ��������� VBS-������, ��������������� ���������� ������ ���������� XRequest, ��� ������ ��������� �������. VBS-����� ������ ��������� ����� Serialize
	':���������: ��������� VBS-������, ��������������� ���������� ������-���������� XResponse, ����������� �� ��������� �������.
Function X_ExecuteCommandSafe(oRequest)
	Dim aErr		' ���� ������� Err
	On Error Resume Next
	Set X_ExecuteCommandSafe = X_ExecuteCommand(oRequest)
	If X_WasErrorOccured Then
		' �� ������� ��������� ������
		On Error Goto 0
		Set X_ExecuteCommandSafe = Nothing
		X_GetLastError.Show
	ElseIf Err Then
		' ������ ��������� �� ������� - ��� ������ � XFW
		aErr = Array(Err.Number, Err.Source, Err.Description)
		On Error Goto 0
		Err.Raise aErr(0), aErr(1), aErr(2)				
	End If
End Function

'==============================================================================
    '@@X_ExecuteCommandAsync
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ExecuteCommandAsync>
	':����������:	
	'               ����� �������, ��������� ���������� ������
	':���������: Function X_ExecuteCommandAsync(oRequest)
	':���������:	
	'   oRequest - 
	'       [in] ��������� VBS-������, ��������������� ���������� ������ ���������� XRequest, ��� ������ ��������� �������. VBS-����� ������ ��������� ����� Serialize
    ':���������: - ������������� ������� (Guid)

Function X_ExecuteCommandAsync(oRequest)
	Dim oXmlRequest		' ��������������� Request
	
	If Not hasValue(oRequest.m_sName) Then
		Err.Raise -1, "X_ExecuteCommandAsync", "�� ������ ������������ �������"
	End If
	Set oXmlRequest = X_WrapSerializedXRequest(oRequest.CLRFullTypeName, oRequest.Serialize())
	X_ExecuteCommandAsync = X_ExecuteCommandAsyncXml(oXmlRequest)
End Function

'==============================================================================
    '@@X_QueryCommandResult
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_QueryCommandResult>
	':����������:	
    '             ���������� ������ �������, ���������� ����������. ������� ������ X_QueryCommandResultXml.
    ':���������: Function X_QueryCommandResult(sCommandID)
	':���������:
	'   sCommandID - 
	'       [in] ���������� ������������� ����������� �� ������� �������, ���������� � ���������� ������ X_ExecuteCommandAsyncXml
    ':���������: ��������� VBS-������, ��������������� ���������� ������-���������� XResponse, ����������� �� ��������� �������
Function X_QueryCommandResult(sCommandID)
	Dim oXmlResponse	' ��������������� Response
	Dim oResponse       ' ����������������� Response
	
	Set oXmlResponse = X_QueryCommandResultXml(sCommandID)
	Set oResponse = Eval("New " & oXmlResponse.documentElement.tagName)
	Set X_QueryCommandResult = oResponse.Deserialize(oXmlResponse.documentElement)
End Function

'==============================================================================
    '@@X_ResumeCommand
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ResumeCommand>
	':����������:	
    '            ���������� ��������� �������, ����� ���������� � ������� X_ExecuteCommandAsyncXml. ������� ������ X_ResumeCommandXml, � ������� �� ������� ��������� �������������� ������.
    ':���������: Sub X_ResumeCommand(sCommandID, oRequest)
    ':���������:
	'   sCommandID - 
	'       [in] ���������� ������������� ����������� �� ������� �������, ���������� � ���������� ������ X_ExecuteCommandAsyncXml
	'   oRequest - 
	'       [in] ��������� VBS-������, ��������������� ���������� ������-���������� XRequest    
Sub X_ResumeCommand(sCommandID, oRequest)
	X_ResumeCommandXml sCommandID, X_WrapSerializedXRequest(oRequest.CLRFullTypeName, oRequest.Serialize())
End Sub


    '==============================================================================
    '@@X_ExecuteCommandByName
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ExecuteCommandByName>
	':����������:	
	'            ����� ������� �� �����, ��������� ����������� XRequest
    ':���������: Function X_ExecuteCommandByName( sCommandName [as String])
    ':���������:
	'   sCommandName - 
	'       [in] ������������ �������
	':���������: ��������� VBS-������, ��������������� ���������� ������-���������� XResponse, ����������� �� ��������� �������
Function X_ExecuteCommandByName( sCommandName)
	If Not hasValue(sCommandName) Then
		Err.Raise -1, "X_ExecuteCommandByName", "�� ������ ������������ �������"
	End If
	With New XRequest
		.m_sName = sCommandName
		Set X_ExecuteCommandByName = X_ExecuteCommand( .Self )
	End With
End Function

    '==============================================================================
    '@@X_Deserialize
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_Deserialize>
	':����������:	
    '               ������������� �������� ���� (��������) �� ����������� xml-����
    ':���������: Sub X_Deserialize(vValue [as Variant],
    '        oXmlNode [as XmlNode], 
    '        sCLRTypeName [as String])
    ':���������:
	'   vValue - 
	'       [in] ������ �� ����������, � ������� ��������������� ��������
	'   oXmlNode - 
	'       [in] xml-���� ���������������� ��������
	'   sCLRTypeName - 
	'       [in] ������������ CLR-���� ��������
	
Sub X_Deserialize(vValue, oXmlNode, sCLRTypeName)
	Dim oNodes			' ��������� ����� ��������� �������
	Dim aValues			' ����������������� ������
	Dim sScalarType		' ��������� ���
	Dim sArrayItemType	' ��� �������� �������
	Dim bIsAttribute	' �������, ��� �������������� ���������� �� ��������
	Dim bIsPrimitiveType	' ������� ������������ CLR ����
	Dim i
	Const NODE_ATTRIBUTE = 2	'
	
	If oXmlNode Is Nothing Then
		vValue = Null
		Exit Sub
	End If
	bIsAttribute = (oXmlNode.nodeType = NODE_ATTRIBUTE)
	If IsCLRTypeArray(sCLRTypeName)	Then
		If Not oXmlNode Is Nothing Then
			sScalarType = GetArrayItemType(sCLRTypeName)
			If IsCLRTypeArray(sScalarType) Then Err.Raise -1, "X_Deserialize", "����������� ������� �� ��������������"
			bIsPrimitiveType = IsPrimitiveType(sScalarType)
			sArrayItemType = sScalarType
			If bIsAttribute Then
				If Not bIsPrimitiveType Then _
					Err.Raise -1, "", "����������� ������������ ������������� ����� � xml �������"
				aValues = Split(oXmlNode.text, " ")
				Set oNode = m_oXmlRoot.ownerDocument.createElement("node")
				For i=0 To oNodes.length-1
					oNode.text = aValues(i)
					X_Deserialize aValues(i), oNode, sScalarType
				Next
			Else
				Set oNodes = oXmlNode.selectNodes("*")
				ReDim aValues(oNodes.length-1)
				For i=0 To oNodes.length-1
					If Not bIsPrimitiveType Then
						sArrayItemType = sScalarType
						If IsNull(oNodes.item(i).GetAttribute("xsi:nil")) Then
							X_Deserialize aValues(i), oNodes.item(i), sArrayItemType
						Else
							If sScalarType = "Object" Then
								aValues(i) = Null
							Else
								Set aValues(i) = Nothing
							End If
						End If			
					Else
						X_Deserialize aValues(i), oNodes.item(i), sArrayItemType
					End If
				Next
			End If
			vValue = aValues
		End If
	Else
		Select Case sCLRTypeName
			Case "string", "String", "Guid", "char", "Char"
				If Not oXmlNode Is Nothing Then _
					vValue = oXmlNode.text
			Case "int", "Int32"
				If Not oXmlNode Is Nothing Then
					oXmlNode.dataType = "i4"
					vValue = oXmlNode.nodeTypedValue
				End If
			Case "long", "Int64"
				If Not oXmlNode Is Nothing Then
					oXmlNode.dataType = "i4"
					vValue = oXmlNode.nodeTypedValue
				End If
			Case "short", "Int16"
				If Not oXmlNode Is Nothing Then
					oXmlNode.dataType = "i2"
					vValue = oXmlNode.nodeTypedValue
				End If
			Case "byte", "Byte"
				If Not oXmlNode Is Nothing Then
					oXmlNode.dataType = "ui1"
					vValue = oXmlNode.nodeTypedValue
				End If
			Case "float", "Single"
				If Not oXmlNode Is Nothing Then
					oXmlNode.dataType = "r4"
					vValue = oXmlNode.nodeTypedValue
				End If
			Case "double", "Double"
				If Not oXmlNode Is Nothing Then
					oXmlNode.dataType = "r8"
					vValue = oXmlNode.nodeTypedValue
				End If
			Case "bool", "Boolean"
				If Not oXmlNode Is Nothing Then
					If oXmlNode.text = "true" Then
						vValue = True
					Else
						vValue = False
					End If
				End If
			Case "decimal", "Decimal"
				If Not oXmlNode Is Nothing Then
					oXmlNode.dataType = "fixed.14.4"
					vValue = oXmlNode.nodeTypedValue
				End If
			Case "Byte[]"
				If Not oXmlNode Is Nothing Then
					oXmlNode.dataType = "bin.base64"
					vValue = oXmlNode.nodeTypedValue
				End If
			Case "dateTime", "DateTime"
				' �����: XmlSerializer ��� DateTime (��)����������� � time zone!
				' � ��������� xml-���� ���� ����������� � time zone, 
				' ������ ��� ������������� ����� �������� VBS ���������� �� ������� �������� timezone, ��� ��� ���������� �� ����, �.�. ����� ���������� ����������!
				' ������� ������� �� �������� xml-���� �������� time zone ���-�� ���� �����: +3.00
				If Not oXmlNode Is Nothing Then
					vValue = oXmlNode.text
					Dim plus,minus,colon
					plus=InStrRev(vValue,"+")
					
					if plus>0 then
					    ' �������� ���, ��� ����� +
					    oXmlNode.Text=Left(vValue,plus-1)
					else
					    minus=InStrRev(vValue,"-")
				        colon=InStr(vValue,":")
				        ' ����� ������ ���� ����� :, ���� �� ����� :, �� ��� �� �����
				        ' ��������� ����, �� ����������� � ����;
				        ' ����� ������ �������������� ����������� - ����� ��� �� dateTime
				        if colon>0 and minus>colon then
    					    oXmlNode.Text = Left(vValue,minus-1)
				        end if
					end if
				
					If oXmlNode.text = "0001-01-01T00:00:00" or oXmlNode.text = "0001-01-01T00:00:00.0000000" Then
						' ���� ���� ���� DateTime �� ������� �� ���� �������������������, �� ��� �������� ��������� ��������
						' �� ���� ��� Empty, ����� ����, ����� �������� �� ����� ���� � ���� ���� dt:dt="dateTime"
						vValue = Empty
					Else
						oXmlNode.dataType = "dateTime"
						vValue = oXmlNode.nodeTypedValue
					End If
				End If
			Case "TimeSpan"
				If Not oXmlNode Is Nothing Then _
					vValue = oXmlNode.text
			Case "XmlElement"
				Set vValue = Nothing
				If Not oXmlNode Is Nothing Then
					If oXmlNode.HasChildNodes Then
						Set vValue = XService.XmlGetDocument
						Set vValue = vValue.appendChild( oXmlNode.firstChild)
						XService.XMLSetSelectionNamespaces vValue.ownerDocument
					End If
				End If
			Case "Object"
				' ������ ������ ����� Object - ������� ��� �� ���� � ��������
				X_Deserialize vValue, oXmlNode, oXmlNode.nodeName
			Case Else
				' ������ ����������� ��� ��� - ��� �����
				Set vValue = Nothing
				If bIsAttribute Then
					Err.Raise -1, "X_Deserialize", "� �������� ������������ ������ ������������ ����: " & sCLRTypeName
				ElseIf Not oXmlNode Is Nothing Then
					Set vValue = Eval("new " & sCLRTypeName)
					vValue.Deserialize oXmlNode
				End If
		End Select
	End If
End Sub


'==============================================================================
' ���������� ���������� ������� ����, ��� ���������� CLR ��� �������� ��������
' ������ ���, ��� ������������ �� "[]", ����� Byte[]
Private Function IsCLRTypeArray(sCLRTypeName)
	If sCLRTypeName = "Byte[]" Then
		IsCLRTypeArray = False
	ElseIf Len(sCLRTypeName) > 2 Then
		IsCLRTypeArray = (Right(sCLRTypeName,2) = "[]") Or (sCLRTypeName = "ArrayList")
	Else
		IsCLRTypeArray = False
	End If
End Function


'==============================================================================
Private Function GetArrayItemType(sArrayTypeName)
	If sArrayTypeName = "ArrayList" Then
		GetArrayItemType = "Object"
	ElseIf Len(sArrayTypeName) > 2 Then
		GetArrayItemType = Mid(sArrayTypeName,1, Len(sArrayTypeName)-2)
	Else
		Err.Raise -1, "GetArrayItemType", "������������ ���: " & sArrayTypeName
	End if
End Function


'==============================================================================
Private Function IsPrimitiveType(sCLRTypeName)
	IsPrimitiveType = InStr(",Byte,Int16,Int32,Int64,Char,Single,Double,Decimal,String,DateTime,Guid,TimeSpan,", "," & sCLRTypeName & ",") > 0
End Function
