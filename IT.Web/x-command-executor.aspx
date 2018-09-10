<%@ Page 
	Language="C#" 
	ValidateRequest="false" 
	AutoEventWireup="true" 

	MasterPageFile="~/xu-command-executor.master" 
	
	Inherits="Croc.XmlFramework.Web.XCommandExecutorPage" 
	
	EnableViewState="false"
	EnableSessionState="True" 
 Codebehind="x-command-executor.aspx.cs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderForFilter" Runat="Server">
    
<SCRIPT TYPE="text/vbscript" LANGUAGE="VBScript">

	Option Explicit

	Dim g_oEventEngine		' As XEventEngine
	Dim g_oFilterObject		' Объект (HTC-Behavior) фильтра
	
	'==============================================================================
	' Реализация IParamCollectionBuilder
	Class RequestProxyParamCollectionBuilderClass
		Public Request
		
		'-------------------------------------------------------------------------------
		' Назначение:	Реализация IParamCollectionBuilder::AppendParameter
		' Результат:    
		' Параметры:	
		' Примечание:	
		' Зависимости:	
		' Пример: 		
		Public Sub AppendParameter(sParameterName, sParameterText)
			Dim oMemberInfo
			Dim vValue			' As Variant - типизированное значение параметра
			Dim sXmlType		' As String - xml-тип узла
			Dim oNode			' As XMLDOMElement
			Dim bGuidArray
			
			bGuidArray = False
			
			For Each oMemberInfo In Request.GetMembersInfo()
				If oMemberInfo.Name = sParameterName Then
					Select Case oMemberInfo.CLRType
						Case "Char":
							sXmlType = "char"
						case "SByte":
							sXmlType = "i1"
						case "Byte":
							sXmlType = "ui1"
						case "Int16":
							sXmlType = "i2"
						case "UInt16":
							sXmlType = "ui2"
						case "Int32":
							sXmlType = "i4"
						case "UInt32":
							sXmlType = "ui4"
						case "Int64":
							sXmlType = "i8"
						case "UInt64":
							sXmlType = "ui8"
						case "Single":
							sXmlType = "r4"
						case "Double":
							sXmlType = "r8"
						case "Decimal":
							sXmlType = "fixed.14.4"
						case "DateTime":
							sXmlType = "dateTime.tz"
						case "String":
							sXmlType = "string"
						case "Boolean":
							sXmlType = "boolean"
						case "Byte[]":
							sXmlType = "bin.base64"
						case "Guid":
							sXmlType = "uuid"
						case "Guid[]":
							sXmlType = "uuid"
							bGuidArray = true 
					End Select
					Set oNode = XService.XMLFromString("<node/>")
					oNode.text = sParameterText
					oNode.dataType = sXmlType
					vValue = oNode.nodeTypedValue
					If bGuidArray Then
						Execute "Request.m_" & oMemberInfo.Prefix & sParameterName & " = appendArray( Request.m_" & oMemberInfo.Prefix & sParameterName & ", vValue)"
					Else
						Execute "Request.m_" & oMemberInfo.Prefix & sParameterName & "=vValue"
					End If
				End If
			Next
		End Sub
		
		Private Function appendArray(ByRef arr, vValueToAdd)
			If IsArray(arr) Then
				ReDim Preserve arr(UBound(arr)+1)
				arr(Ubound(arr)) = vValueToAdd
			Else
				arr = Array(vValueToAdd)
			End If
			appendArray = arr
		End Function
		
	End Class

	'==============================================================================
	' Аргумент события "Error"
	Class ErrorEventArgsClass
		Public Cancel				' As Boolean - признак прервать цепочку обработки событий.
		Public ServerError			' As ErrorInfoClass - серверная ошибка
		Public Function Self()
			Set  Self = Me
		End Function	
	End Class


	' Константы видов действий после получения респонса от команды
	Const CMD_FINISHED_ACTION_CLOSE = 1			' закрыть диалог
	Const CMD_FINISHED_ACTION_RETRY = 2			' повторить команду
	Const CMD_FINISHED_ACTION_NOTHING = 3		' ничего не делать (по умолчанию)
	
	'==============================================================================
	' Аргумент события "CommandFinished"
	Class CommandFinishedEventArgsClass
		Public Cancel				' As Boolean - признак прервать цепочку обработки событий.
		Public ReturnValue			' As Integer - одна из констант CMD_FINISHED_ACTION_*
		Public Response				' респонс серверной команды
		Public ResultToReturn		' что вернёт при закрытии диалог
		Public Function Self()
			Set  Self = Me
		End Function	
	End Class
	
	'==============================================================================
	' Аргумент события "BeforeRunCommand"
	Class BeforeRunCommandEventArgsClass
		Public Cancel				' As Boolean - признак прервать цепочку обработки событий.
		Public ReturnValue			' As Boolean - если False, то выполнение команды не начинается
		Public Request				' реквест серверной команды
		Public Function Self()
			Set  Self = Me
		End Function	
	End Class
			
	'==============================================================================
	' Обработчик нажатия "Отменить"
	Sub XCommandExecutor_cmdCancel_onClick()
		window.close
	End Sub

	'==============================================================================
	' Обработчик нажатия OK
	Sub XCommandExecutor_cmdOK_onClick()
		XEventEngine_FireEvent g_oEventEngine, "RunCommand", Nothing, Nothing
	End Sub
	
	'==============================================================================
	' Обработчик события "RunCommand"
	' oSender, oEventArgs всегда Nothing
	Sub OnRunCommand(oSender, oEventArgs)
		Dim oArguments		' As FilterObjectGetRestrictionsParamsClass
		Dim oBuilder		' As IParamCollectionBuilder
		Dim oResponse		' респонс команды
		Dim nAction			' действие после завершения команды
		
		Set oArguments = New FilterObjectGetRestrictionsParamsClass
		Set oBuilder = New RequestProxyParamCollectionBuilderClass
		Set oBuilder.Request = Eval( "New " & VBS_REQUEST_TYPENAME )
		Set oArguments.ParamCollectionBuilder = oBuilder
		oBuilder.Request.m_sName = COMMAND_NAME
		g_oFilterObject.GetRestrictions oArguments
		If False=oArguments.ReturnValue Then Exit Sub
		If 0=SafeCLng(ASYNC_COMMAND) Then	
			Do
				With New BeforeRunCommandEventArgsClass
					Set .Request = oBuilder.Request
					.ReturnValue = True
					XEventEngine_FireEvent g_oEventEngine, "BeforeRunCommand", Nothing, .Self()
					If .ReturnValue = False Then Exit Sub
					On Error Resume Next
					EnableControls False
					Set oResponse = X_ExecuteCommand( .Request )
					EnableControls True
				End With
				If Err Then
					With New ErrorEventArgsClass
						Set .ServerError = X_GetLastError
						XEventEngine_FireEvent g_oEventEngine, "Error", Nothing, .Self()
					End With
					Exit Sub 
				End If
				On Error GoTo 0
				With New CommandFinishedEventArgsClass
					.ReturnValue = CMD_FINISHED_ACTION_NOTHING
					Set .Response = oResponse
					Set .ResultToReturn = oResponse
					XEventEngine_FireEvent g_oEventEngine, "CommandFinished", Nothing, .Self()
					nAction = .ReturnValue
					If nAction = CMD_FINISHED_ACTION_CLOSE Then
						If IsObject( .ResultToReturn ) Then
							Set dialogArguments.returnValue = .ResultToReturn
						Else
							dialogArguments.returnValue = .ResultToReturn
						End If	
						XCommandExecutor_cmdCancel_onClick
					End If
				End With
			Loop While nAction = CMD_FINISHED_ACTION_RETRY
		Else
			Alert "Not supported"
		End If
	End Sub
	
	'==============================================================================
	' Стандартные обработчик ошибки
	Sub OnError(oSender, oEventArgs)
		If Not oEventArgs.ServerError Is Nothing Then
			oEventArgs.ServerError.Show
		End If
	End Sub	

	'==============================================================================
	Public Sub EnableControls(bEnable)
		document.all( "XCommandExecutor_cmdOK").disabled = not bEnable
		document.all( "XCommandExecutor_cmdCancel").disabled = not bEnable
	End Sub
	


	'==============================================================================
	' Инициализация страницы
	Sub Window_OnLoad()	
		X_WaitForTrue "Init()" , "X_IsDocumentReadyEx(null, ""XFilter"")"
	End Sub


	'==============================================================================
	' Инициализация страницы
	Sub Init()
		Dim oParams			' параметры для инициализации фильтра
		Dim oFilterXmlState	' состояние фильтра
		
		Set g_oEventEngine = X_CreateEventEngine()
		Set g_oFilterObject = X_GetFilterObject( document.all( "FilterFrame") )

		' Инициализируем пользовательские обработчики событий статическим биндингом (по маске имени)
		g_oEventEngine.InitHandlers "CommandFinished,Error,BeforeRunCommand,RunCommand", "usrXCmdExecutor_On"
		' добавим собственный обработчик события "RunCommand", если не нашли пользовательских
		g_oEventEngine.AddHandlerForEventWeakly "RunCommand", Nothing, "OnRunCommand"
		g_oEventEngine.AddHandlerForEventWeakly "Error", Nothing, "OnError"

		' Инициализируем фильтр
		Set oParams = New FilterObjectInitializationParamsClass
		Set oParams.QueryString = dialogArguments.QueryString
		
		' Востановим состояние, если у метаописания фильтра нет атрибута "off-viewstate"
		' Примечание: фильтр должен всегда быть, мы это проверяли в момент открытия
		If false = X_MD_FILTER_OFF_VIEWSTATE Then
			If XService.GetUserData("XCommand/" & X_PAGE_METANAME & "/State", oFilterXmlState) Then
				Set oParams.XmlState = oFilterXmlState
			End If
		End If

		g_oEventEngine.AddHandlerForEvent "EnableControls", Nothing, GetRef("OnEnableControls")
		g_oEventEngine.AddHandlerForEvent "Accel", Nothing, GetRef("OnAccel")
		g_oEventEngine.AddHandlerForEvent "SetCaption", Nothing, GetRef("OnSetCaption")
		If g_oFilterObject.Init (g_oEventEngine, oParams) Then
			' Ожидаем завершения инициализации фильтров
			X_WaitForTrue "Init2" , "X_IsDocumentReady( null) and g_oFilterObject.IsReady"
		Else
			Alert "Ошибка инициализации фильтра!"
		End If
	End Sub


	'==============================================================================
	' Завершение инициализации страницы
	Sub Init2
		EnableControls true
	End Sub

	
	'==============================================================================
	' Обработчик закрытия окна
	Sub Window_OnUnLoad
		Dim oXmlFilterState ' As IXMLDOMElement, Состояние фильтра
		
		' сохраним состояние фильтра (если не отключено)
		If Not IsNothing(g_oFilterObject) And False = X_MD_FILTER_OFF_VIEWSTATE Then
			Set oXmlFilterState = g_oFilterObject.GetXmlState()
			If Not oXmlFilterState Is Nothing Then _
				XService.SetUserData "XCommand/" & X_PAGE_METANAME & "/State", oXmlFilterState
		End If
	End Sub




	'======================================================================
	Sub document_OnKeyUp
		If window.event Is Nothing Then Exit Sub		
		With window.event
			If Not .srcElement Is Nothing Then
				If Not IsNull(.srcElement.getAttribute("X_IgnoreHtmlEvents")) Then
					Exit Sub
				End If
			End If
			If Not IsNothing(g_oFilterObject) Then
				g_oFilterObject.OnKeyUp CreateAccelerationEventArgsForHtmlEvent()
			ElseIf .KeyCode = VK_ESC Then 
				XCommandExecutor_cmdCancel_onClick
			End If
		End With
	End Sub


	'==============================================================================
	' Обработчик события EnableControls, сгенерированного фильтром (x-filter.htc)
	'	[in] oEventArgs - EnableControlsEventArgs
	Public Sub OnEnableControls(oSender, oEventArgs)
		EnableControls oEventArgs.Enable
	End Sub

	'==============================================================================
	' Обработчик события Accel, сгенерированного фильтром (x-filter.htc)
	'	[in] oEventArgs - AccelerationEventArgsClass
	Public Sub OnAccel(oSender, oEventArgs)
		If oEventArgs.keyCode = VK_ENTER Then
			XCommandExecutor_cmdOk_onClick
		ElseIf oEventArgs.keyCode = VK_ESC Then 
			XCommandExecutor_cmdCancel_onClick
		End If
	End Sub
	
	
	'==============================================================================
	' Обработчик события SetCaption, сгенерированного редактором в фильтре (x-filter.htc)
	'	[in] oEventArgs As SetCaptionEventArgsClass
	Public Sub OnSetCaption(oSender, oEventArgs)
		document.all( "XCommandExecutor_xPaneCaption").innerHtml = oEventArgs.EditorCaption
	End Sub
</SCRIPT>

<asp:PlaceHolder ID="FilterPlaceHolder" runat="server" EnableViewState="false" />

</asp:Content>
