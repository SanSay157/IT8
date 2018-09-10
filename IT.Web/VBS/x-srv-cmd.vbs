'===============================================================================
'@@!!FILE_x-srv-cmd
'<GROUP !!SYMREF_VBS>
'<TITLE x-srv-cmd - Обслуживание серверных команд>
':Назначение:	Обслуживание серверных команд
'@@!!CLASSES_x-srv-cmd
'<GROUP !!FILE_x-srv-cmd><TITLE Классы>
'@@!!FUNCTIONS_x-srv-cmd
'<GROUP !!FILE_x-srv-cmd><TITLE Функции и процедуры>
'<SCRIPT LANGUAGE="VBScript">
Option Explicit

'===============================================================================
'@@MemberInfo
'<GROUP !!CLASSES_x-srv-cmd><TITLE MemberInfo>
':Назначение:	Описание метаданных поля/свойства типа.
'@@!!MEMBERTYPE_Properties_MemberInfo
'<GROUP MemberInfo><TITLE Свойства>
'
Class MemberInfo
 '@@MemberInfo.Name
	'<GROUP !!MEMBERTYPE_Properties_MemberInfo><TITLE Name>
	':Назначение:	Имя
	':Сигнатура:	Public Name [String]	
	Public Name				' Имя
	'@@MemberInfo.Prefix
	'<GROUP !!MEMBERTYPE_Properties_MemberInfo><TITLE Prefix>
	':Назначение:	Префикс
	':Сигнатура:	Public Prefix [String]	
	Public Prefix			' Префикс
	'@@MemberInfo.CLRType
	'<GROUP !!MEMBERTYPE_Properties_MemberInfo><TITLE CLRType>
	':Назначение:	CLR Тип, как он подразумевается на клиенте
	':Сигнатура:	Public CLRType [String]	
	Public CLRType			' CLR Тип, как он подразумевается на клиенте
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
':Назначение: 
'   Вспомогательный класс-обертка, оформляющий XML-документ "сериализованных"
'   данных XRequest. Для задания типа реквеста можно установить свойство RequestTypeFullName, либо 
'	отдельно установить тип (RequestTypeName), пространство имен(NameSpace) и наименование сборки (AssemblyName).
'	Если имя сборки не задано используется наименование пространства имен.
'@@!!MEMBERTYPE_Methods_XSerializerClass
'<GROUP XSerializerClass><TITLE Методы>
Class XSerializerClass
	Private m_oXmlRoot			' As IXMLDOMElement - корневой узел сериализованного xml-запроса
		 
	'--------------------------------------------------------------------------
	'@@XSerializerClass.Init
	'<GROUP !!MEMBERTYPE_Methods_XSerializerClass><TITLE Init>
	':Назначение:	Инициализация экземпляра класса
	':Сигнатура:	Public Sub Init(ByVal sCLRTypeName [as String])	
	':Параметры:	
	'   sCLRTypeName - 
	'       [in] наименование CLR-типа поля/свойства запроса
	
	Public Sub Init(ByVal sCLRTypeName)
		Set m_oXmlRoot = XService.XmlFromString("<?xml version=""1.0"" encoding=""windows-1251""?><" & sCLRTypeName & " xmlns:dt=""urn:schemas-microsoft-com:datatypes""/>")
	End	Sub

		
	'--------------------------------------------------------------------------
	'@@XSerializerClass.AddParameter
	'<GROUP !!MEMBERTYPE_Methods_XSerializerClass><TITLE AddParameter>
	':Назначение:	Добавляет пару "наименование" - "параметр" в XML-документ "сериализованного" запроса
	':Сигнатура:	Public Sub AddParameter(
	'        sName [as Sting], 
	'        vValue [as Variant], 
	'        sCLRTypeName [as String], 
	'        bIsAttribute [as Boolean] )
	':Параметры:	
	'   sName - 
	'       [in] наименование параметра
	'   vValue - 
	'       [in] значение параметра
	'   sCLRTypeName - 
	'       [in] наименование CLR-типа поля/свойства запроса
	'   bIsAttribute - 
	'       [in] если значение true, то сериализовывать в атрибут, иначе в элемент
		
	Public Sub AddParameter( sName, vValue, sCLRTypeName, bIsAttribute )
		If IsEmpty(m_oXmlRoot) Then Err.Raise -1, "XSerializerClass::AddParameter", "XSerializerClass не инициализирован"
		internal_AddParameter sName, vValue, sCLRTypeName, bIsAttribute, m_oXmlRoot
	End Sub
	
	
	Private Sub internal_AddParameter( sName, vValue, sCLRTypeName, bIsAttribute, oParentNode )
		Dim oNode			' узел значения сериализованного массива
		Dim sScalarType		' наименование скалярного CLR-типа
		Dim i
		Dim oValueNode		' xml-узел со значением поля
		Dim bAppend			' признак, что сформированная нода добавляется в xml-реквест
		Dim sTagName		' наименование тега элемента массива
		Dim sAttrValue		' значение атрибута
		Const vbByteArray = &h2010	' "Специальный" тип массивов, который в VBS обрабатывается не как другие массивы
		
		If IsDefined(vValue) Then
			bAppend = False
			' создадим xml-ноду для свойства (это либо элемент, либо атрибут - определяется атрибутами в C#) 
			If bIsAttribute Then
				set oValueNode = m_oXmlRoot.ownerDocument.createAttribute(sName)
			Else
				Set oValueNode = m_oXmlRoot.ownerDocument.createElement(sName)
			End If	
			With oValueNode
				If IsCLRTypeArray(sCLRTypeName) Then
					' массив (в том числе ArrayList, Но без Byte[])
					If IsArray(vValue) Then
						If VarType(vValue) = vbByteArray Then
							Err.Raise -1, "internal_AddParameter", "Массив элементов типа vbByte не поддерживается. TypeName=" & TypeName(vValue)
						End If
						' и передали массив - все правильно
						sScalarType = GetArrayItemType(sCLRTypeName)
						bAppend = True
						If IsCLRTypeArray(sScalarType) Then Err.Raise -1, "XSerializerClass::AddParameter", "Многомерные массивы не поддерживаются"
						' Массив (любой)                 
						If bIsAttribute Then
							' Сериализуется как последовательность значений через пробел
							For i=0 To UBound(vValue)
								Set oNode = m_oXmlRoot.ownerDocument.createElement("node")
								If SerializeSimpleCLRType( oNode, vValue(i), sScalarType) Then
									sAttrValue = sAttrValue & oNode.text & " "
								End If
							Next
							oValueNode.text = RTrim(sAttrValue)
						Else
							' Сериализуется как: <свойство><тип>vValue(0)</тип><тип>vValue(1)</тип></свойство>
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
					' Объект
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
					' элементарный тип
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
		Dim sTagName	' возвращаемое значение
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
								Err.Raise -1, "", "Непредусмотренный случай: " & TypeName(vValue)
						End Select
					Else
						sTagName = sScalarType
					End If
				End If
		End Select
		getArrayElementTagName = sTagName 
	End Function
	
	'--------------------------------------------------------------------------
	'Сериализует скалярный CLR-тип (т.е. не массив) в xml-узел [retval]: True - значение добавлено, False - значение не добавлено
	
	
	Public Function SerializeSimpleCLRType(oValueNode, ByVal vValue, sCLRTypeName)
		SerializeSimpleCLRType = False
		If IsNull(vValue) Then Exit Function
		If IsEmpty(vValue) Then Exit Function
		Select Case sCLRTypeName
			Case "Guid"
				' Guid - в случае отсутствия значения подставим нулевой гуид
				oValueNode.text = vValue
			Case "DateTime"
				' Важно: XmlSerializer тип DateTime (де)сериализует с time zone!
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
	':Назначение:	Формирует XML-элемент "сериализованного" запроса. Результат:    XML-документ (IXMLDOMDocument)
	Public Function ToXml()
		Set ToXml = m_oXmlRoot
	End Function 
End Class


'==============================================================================
    '@@X_ExecuteCommandXmlEx
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ExecuteCommandXmlEx>
	':Назначение: Вызывает серверную команду с сериализованным объектом запроса.
    ' Единое место для вызова серверных команд с клиента. В случае возникновения серверной ошибки 
    ' она откладывается в глобальную переменную окна, которую можно получить 
    ' через X_GetLastError.
    ' Ошибки не гасятся.
	':Сигнатура:	Function X_ExecuteCommandXmlEx( oRequestXmlDomDocument [As XMLDOMDocument],
	'       oXService [As XClientService])
	':Параметры:	
	'   oRequestXmlDomDocument - 
	'       [in] XML-документ с сериализованным объектом запроса серверной команды
	'   oXService - 
	'       [in] экземпляр ActiveX CROC.XClientService; может быть Nothing; в этом случае в качестве экземпляра компоненты используется локальный объект с идентификатором "XService"
	
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
 	':Назначение:
    '            Вызывает серверную команду с сериализованным объектом запроса.
    '            Версия функции X_ExecuteCommandXmlEx, без указания экземпляра XService, 
    '            для обратной совместимости.
    '            Единое место для вызова серверных команд с клиента. В случае возникновения серверной ошибки 
    '            она сохраняется в глобальную переменную окна, которую можно получить 
    '            через X_GetLastError.
    '            Ошибки не гасятся.
	':Сигнатура: Function X_ExecuteCommandXml(oRequestXmlDomDocument [As XMLDOMDocument])
   	':Параметры:	
	'   oRequestXmlDomDocument - 
	'       [in] XML-документ с сериализованным объектом запроса серверной команды
    
Function X_ExecuteCommandXml( oRequestXmlDomDocument )
	Set X_ExecuteCommandXml = X_ExecuteCommandXmlEx( oRequestXmlDomDocument, Nothing ) 
End Function


'==============================================================================
    '@@X_ExecuteCommandAsyncXml
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ExecuteCommandAsyncXml>
    ':Назначение:	
    '            Асинхронно вызывает серверную команду с сериализованным объектом запроса.
    '            Единое место для вызова серверных команд с клиента.
    '            В случае возникновения серверной ошибки она откладывается в глобальную переменную окна, которую можно получить через X_GetLastError.
    '            Ошибки не гасятся.
	':Сигнатура: Function X_ExecuteCommandAsyncXml(oRequestXmlDomDocument)
   	':Параметры:	
	'   oRequestXmlDomDocument - 
	'       [in] XML-документ с сериализованным объектом запроса серверной команды
	
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
    ':Назначение:	
    '           Возвращает отклик (статус или результат) асинхронно запущенной серверной операции.
    '           Единое место для вызова серверных команд с клиента.
    '           В случае возникновения серверной ошибки она откладывается в глобальную переменную окна, которую можно получить через X_GetLastError.
    '           Ошибки не гасятся.
    ':Сигнатура: Function X_QueryCommandResultXml(sCommandID [as String])
    ':Параметры:	
	'   sCommandID - 
	'       [in] уникальный идентификатор исполняемой на сервере команды, полученный в результате вызова X_ExecuteCommandAsyncXml
   
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
    ':Назначение:	
    '            Продолжает выполение команды, ранее запущенной с помощью X_ExecuteCommandAsyncXml
    '            В случае серверной ошибки она откладывается в глобальную переменную окна, которую можно получить через X_GetLastError.
    '            Ошибки не гасятся.
    ':Сигнатура: Sub X_ResumeCommandXml(sCommandID [as String], oRequestXmlDomDocument [as XMLDOMDocument])
    ':Параметры:	
	'   sCommandID - 
	'       [in] уникальный идентификатор исполняемой на сервере команды, полученный в результате вызова X_ExecuteCommandAsyncXml
	'   oRequestXmlDomDocument - 
	'       [in] xml-документ с сериализованным объектом запроса серверной команды
  
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
    ':Назначение:	
    '            Вызывает гвард серверной команды с сериализованным объектом запроса.
    '            В случае возникновения серверной ошибки она откладывается в глобальную переменную окна, которую можно получить через X_GetLastError.
    '            Ошибки не гасятся.
    ':Сигнатура: Function X_HasRightsToExecuteXml(oRequestXmlDomDocument [As XMLDOMDocument]) As Boolean
    ':Параметры:	
	'   oRequestXmlDomDocument - 
	'       [in] xml-документ с сериализованным объектом запроса серверной команды
    ':Результат: Facade.HasRightsToExecute: true - доступ к операции разрешен, false - нет
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
	':Назначение:	
    '            Вызывает гвард серверной команды с объектом запроса.
    ':Сигнатура: Function X_HasRightsToExecute(oRequest) As Boolean
    ':Параметры:	
	'   oRequest - 
	'       [in] экземпляр VBS-класса, соответствующий серверному классу-наследнику XRequest, для вызова серверной команды. VBS-класс должен содержать метод Serialize
    ':Результат: Facade.HasRightsToExecute: true - доступ к операции разрешен, false - нет
Function X_HasRightsToExecute(oRequest)
	Dim oXmlRequest		' сериализованный Request
	
	If Not hasValue(oRequest.m_sName) Then
		Err.Raise -1, "X_HasRightsToExecute", "Не задано наименование команды"
	End If
	Set oXmlRequest = X_WrapSerializedXRequest(oRequest.CLRFullTypeName, oRequest.Serialize())
	X_HasRightsToExecute = X_HasRightsToExecuteXml(oXmlRequest)
End Function

'==============================================================================
    '@@X_TerminateCommand
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_TerminateCommand>
	':Назначение:	
    '            Завершает выполение команды, ранее запущенной с помощью X_ExecuteCommandAsyncXml
    '            В случае серверной ошибки она откладывается в глобальную переменную окна, которую можно получить через X_GetLastError.
    '            Ошибки не гасятся.
    ':Сигнатура: Sub X_TerminateCommand(sCommandID [as String])
    ':Параметры:	
	'   sCommandID - 
	'       [in] уникальный идентификатор исполняемой на сервере команды, полученный в результате вызова X_ExecuteCommandAsyncXml
    
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
	':Назначение:	
    '            Вызов команды, используя переданный запрос            
    ':Сигнатура: Function X_ExecuteCommandEx( oRequest, oXService )
    ':Параметры:	
	'   oRequest - 
	'       [in] экземпляр VBS-класса, соответствующий серверному классу наследнику XRequest, для вызова серверной команды. VBS-класс должен содержать метод Serialize
	'   oXService - 
	'       [in] экземпляр ActiveX CROC.XClientService, через который будет выполняться запрос на сервер. Может быть Nothing; в этом случае в кач. экземпляра компоненты используется локальный объект с идентификатором "XService"
    ':Результат: экземпляр VBS-класса, соответствующий серверному классу-наследнику XResponse, полученному от серверной команды.
Function X_ExecuteCommandEx( oRequest, oXService )
	Dim oXmlRequest		' сериализованный Request
	Dim oXmlResponse	' сериализованный Response
	Dim oResponse       ' десериализованный Response
	
	If Not hasValue(oRequest.m_sName) Then
		Err.Raise -1, "X_ExecuteCommand", "Не задано наименование команды"
	End If
	Set oXmlRequest = X_WrapSerializedXRequest(oRequest.CLRFullTypeName, oRequest.Serialize())
	Set oXmlResponse = X_ExecuteCommandXmlEx( oXmlRequest, oXService )
	Set oResponse = Eval("New " & oXmlResponse.documentElement.tagName)
	Set X_ExecuteCommandEx = oResponse.Deserialize( oXmlResponse.documentElement )
End Function

'==============================================================================
    '@@X_ExecuteCommand
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ExecuteCommand>
	':Назначение:	
    '            Вызов команды, используя переданный запрос
    '            Версия функции X_ExecuteCommandEx, для обратной совместимости.  
    ':Сигнатура: Function X_ExecuteCommand( oRequest )
    ':Параметры:	
	'   oRequest - 
	'       [in] экземпляр VBS-класса, соответствующий серверному классу наследнику XRequest, для вызова серверной команды. VBS-класс должен содержать метод Serialize
	':Результат: экземпляр VBS-класса, соответствующий серверному классу-наследнику XResponse, полученному от серверной команды.
Function X_ExecuteCommand( oRequest )
	Set X_ExecuteCommand = X_ExecuteCommandEx( oRequest, Nothing )
End Function

'==============================================================================
    '@@X_ExecuteCommandSafe
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ExecuteCommandSafe>
	':Назначение:	
    '               Выполняет серверную команду (используя X_ExecuteCommand), но в отличии от X_ExecuteCommand,
    '               в случае серверной ошибки всегда показывает сообщение.
    '               Таким образом функцию можно использовать в тех случаях, когда нет необходимости в обработки различных типов исключений.
    '               Параметры и возвращаемое значение совпадают с X_ExecuteCommand
    ':Сигнатура: Function X_ExecuteCommandSafe(oRequest)
    ':Параметры:	
	'   oRequest - 
	'       [in] экземпляр VBS-класса, соответствующий серверному классу наследнику XRequest, для вызова серверной команды. VBS-класс должен содержать метод Serialize
	':Результат: экземпляр VBS-класса, соответствующий серверному классу-наследнику XResponse, полученному от серверной команды.
Function X_ExecuteCommandSafe(oRequest)
	Dim aErr		' поля объекта Err
	On Error Resume Next
	Set X_ExecuteCommandSafe = X_ExecuteCommand(oRequest)
	If X_WasErrorOccured Then
		' на сервере произошла ошибка
		On Error Goto 0
		Set X_ExecuteCommandSafe = Nothing
		X_GetLastError.Show
	ElseIf Err Then
		' ошибка произошла на клиенте - это ошибка в XFW
		aErr = Array(Err.Number, Err.Source, Err.Description)
		On Error Goto 0
		Err.Raise aErr(0), aErr(1), aErr(2)				
	End If
End Function

'==============================================================================
    '@@X_ExecuteCommandAsync
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ExecuteCommandAsync>
	':Назначение:	
	'               Вызов команды, используя переданный запрос
	':Сигнатура: Function X_ExecuteCommandAsync(oRequest)
	':Параметры:	
	'   oRequest - 
	'       [in] экземпляр VBS-класса, соответствующий серверному классу наследнику XRequest, для вызова серверной команды. VBS-класс должен содержать метод Serialize
    ':Результат: - идентификатор команды (Guid)

Function X_ExecuteCommandAsync(oRequest)
	Dim oXmlRequest		' сериализованный Request
	
	If Not hasValue(oRequest.m_sName) Then
		Err.Raise -1, "X_ExecuteCommandAsync", "Не задано наименование команды"
	End If
	Set oXmlRequest = X_WrapSerializedXRequest(oRequest.CLRFullTypeName, oRequest.Serialize())
	X_ExecuteCommandAsync = X_ExecuteCommandAsyncXml(oXmlRequest)
End Function

'==============================================================================
    '@@X_QueryCommandResult
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_QueryCommandResult>
	':Назначение:	
    '             Возвращает отклик команды, запущенной асинхронно. Обертка вокруг X_QueryCommandResultXml.
    ':Сигнатура: Function X_QueryCommandResult(sCommandID)
	':Параметры:
	'   sCommandID - 
	'       [in] уникальный идентификатор исполняемой на сервере команды, полученный в результате вызова X_ExecuteCommandAsyncXml
    ':Результат: экземпляр VBS-класса, соответствующий серверному классу-наследнику XResponse, полученному от серверной команды
Function X_QueryCommandResult(sCommandID)
	Dim oXmlResponse	' сериализованный Response
	Dim oResponse       ' десериализованный Response
	
	Set oXmlResponse = X_QueryCommandResultXml(sCommandID)
	Set oResponse = Eval("New " & oXmlResponse.documentElement.tagName)
	Set X_QueryCommandResult = oResponse.Deserialize(oXmlResponse.documentElement)
End Function

'==============================================================================
    '@@X_ResumeCommand
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ResumeCommand>
	':Назначение:	
    '            Продолжает выполение команды, ранее запущенной с помощью X_ExecuteCommandAsyncXml. Обертка вокруг X_ResumeCommandXml, в отличии от которой принимает типизированный октлик.
    ':Сигнатура: Sub X_ResumeCommand(sCommandID, oRequest)
    ':Параметры:
	'   sCommandID - 
	'       [in] уникальный идентификатор исполняемой на сервере команды, полученный в результате вызова X_ExecuteCommandAsyncXml
	'   oRequest - 
	'       [in] экземпляр VBS-класса, соответствующий серверному классу-наследнику XRequest    
Sub X_ResumeCommand(sCommandID, oRequest)
	X_ResumeCommandXml sCommandID, X_WrapSerializedXRequest(oRequest.CLRFullTypeName, oRequest.Serialize())
End Sub


    '==============================================================================
    '@@X_ExecuteCommandByName
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_ExecuteCommandByName>
	':Назначение:	
	'            Вызов команды по имени, используя стандартный XRequest
    ':Сигнатура: Function X_ExecuteCommandByName( sCommandName [as String])
    ':Параметры:
	'   sCommandName - 
	'       [in] наименование команды
	':Результат: экземпляр VBS-класса, соответствующий серверному классу-наследнику XResponse, полученному от серверной команды
Function X_ExecuteCommandByName( sCommandName)
	If Not hasValue(sCommandName) Then
		Err.Raise -1, "X_ExecuteCommandByName", "Не задано наименование команды"
	End If
	With New XRequest
		.m_sName = sCommandName
		Set X_ExecuteCommandByName = X_ExecuteCommand( .Self )
	End With
End Function

    '==============================================================================
    '@@X_Deserialize
	'<GROUP !!FUNCTIONS_x-srv-cmd><TITLE X_Deserialize>
	':Назначение:	
    '               Десериализует значение поля (свойства) из переданного xml-узла
    ':Сигнатура: Sub X_Deserialize(vValue [as Variant],
    '        oXmlNode [as XmlNode], 
    '        sCLRTypeName [as String])
    ':Параметры:
	'   vValue - 
	'       [in] ссылка на переменную, в которую десериализуется значение
	'   oXmlNode - 
	'       [in] xml-узел сериализованного значения
	'   sCLRTypeName - 
	'       [in] наименование CLR-типа значения
	
Sub X_Deserialize(vValue, oXmlNode, sCLRTypeName)
	Dim oNodes			' коллекция узлов элементов массива
	Dim aValues			' десериализованный массив
	Dim sScalarType		' скалярный тип
	Dim sArrayItemType	' тип элемента массива
	Dim bIsAttribute	' признак, что десериализация происходит из атрибута
	Dim bIsPrimitiveType	' признак примитивного CLR типа
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
			If IsCLRTypeArray(sScalarType) Then Err.Raise -1, "X_Deserialize", "Многомерные массивы не поддерживаются"
			bIsPrimitiveType = IsPrimitiveType(sScalarType)
			sArrayItemType = sScalarType
			If bIsAttribute Then
				If Not bIsPrimitiveType Then _
					Err.Raise -1, "", "Недопустима сериализация непримитивных типов в xml атрибут"
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
				' Важно: XmlSerializer тип DateTime (де)сериализует с time zone!
				' В пришедшем xml-узле дата содержиться с time zone, 
				' однако при интерпретации этого значения VBS прибавляет ко времени значение timezone, что нам совершенно не надо, т.к. время изначально правильное!
				' Поэтому вырежем из значения xml-узла значения time zone что-то типа этого: +3.00
				If Not oXmlNode Is Nothing Then
					vValue = oXmlNode.text
					Dim plus,minus,colon
					plus=InStrRev(vValue,"+")
					
					if plus>0 then
					    ' Отбросим все, что после +
					    oXmlNode.Text=Left(vValue,plus-1)
					else
					    minus=InStrRev(vValue,"-")
				        colon=InStr(vValue,":")
				        ' минус должен быть после :, если он перед :, то это не минус
				        ' временной зоны, но разделитель в дате;
				        ' время должно присутствовать обязательно - иначе это не dateTime
				        if colon>0 and minus>colon then
    					    oXmlNode.Text = Left(vValue,minus-1)
				        end if
					end if
				
					If oXmlNode.text = "0001-01-01T00:00:00" or oXmlNode.text = "0001-01-01T00:00:00.0000000" Then
						' если поле типа DateTime на сервере не было проинициализировано, то оно содержит указанное значение
						' по сути это Empty, кроме того, такое значение не может быть в узле типа dt:dt="dateTime"
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
				' значит массив типов Object - возьмем тип из тега и повторим
				X_Deserialize vValue, oXmlNode, oXmlNode.nodeName
			Case Else
				' значит неизвестный нам тип - это объет
				Set vValue = Nothing
				If bIsAttribute Then
					Err.Raise -1, "X_Deserialize", "В атрибуте сериализован объект неизвестного типа: " & sCLRTypeName
				ElseIf Not oXmlNode Is Nothing Then
					Set vValue = Eval("new " & sCLRTypeName)
					vValue.Deserialize oXmlNode
				End If
		End Select
	End If
End Sub


'==============================================================================
' Возвращает логический признак того, что переданный CLR тип является массивом
' Массив все, что оканчивается на "[]", кроме Byte[]
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
		Err.Raise -1, "GetArrayItemType", "Некорректный тип: " & sArrayTypeName
	End if
End Function


'==============================================================================
Private Function IsPrimitiveType(sCLRTypeName)
	IsPrimitiveType = InStr(",Byte,Int16,Int32,Int64,Char,Single,Double,Decimal,String,DateTime,Guid,TimeSpan,", "," & sCLRTypeName & ",") > 0
End Function
