<%@ Page 
	Language="C#" 
	ValidateRequest="false" 
	AutoEventWireup="true" 

	MasterPageFile="~/xu-report-filter.master" 
	
	Inherits="Croc.XmlFramework.Web.XReportFilterPage" 
	
	EnableViewState="false"
	EnableSessionState="True" 
 Codebehind="x-report-filter.aspx.cs" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolderForFilter" Runat="Server">
    
<SCRIPT TYPE="text/vbscript" LANGUAGE="VBScript">

	Option Explicit

	Dim g_oEventEngine		' As XEventEngine
	Dim g_oFilterObject		' Объект (HTC-Behavior) фильтра

	'===============================================================================
	':Назначение:	
	'	Реализация интерфейса IParamCollectionBuilder на основе класса QueryStringClass (шаблон Адаптер)
	Class QueryStringParamCollectionBuilderClassEx

		Private m_oQueryStringParams	'[As QueryStringClass]

		'---------------------------------------------------------------------------
		' Конструктор
		Private Sub Class_Initialize()
			Set m_oQueryStringParams = New QueryStringClass
		End Sub

		'---------------------------------------------------------------------------
		' Деструктор
		Private Sub Class_Terminate()
			Set m_oQueryStringParams = Nothing
		End Sub

		'------------------------------------------------------------------------------
		':Назначение:
		'	Класс для работы с параметрами
		':Примечание:
		'	Свойство доступно только для чтения.
		':Сигнатура:
		'	Public Property Get QueryStringParams [As QueryStringParam]
		Public Property Get QueryStringParams
			Set QueryStringParams = m_oQueryStringParams
		End Property

		'------------------------------------------------------------------------------
		':Назначение:
		'	Строка ограничений.
		':Примечание:
		'	Свойство доступно только для чтения.
		':Сигнатура:
		'	Public Property Get QueryString [As String]
		Public Property Get QueryString
			QueryString = m_oQueryStringParams.QueryString
		End Property

		'------------------------------------------------------------------------------
		':Назначение:	
		'   Реализация метода 
		'   <LINK IParamCollectionBuilder.AppendParameter, AppendParameter /> 
		'   интерфейса IParamCollectionBuilder.
		':Параметры:
		'	sParameterName - [in] наименование параметра.
		'	vParameterText - [in] текстовое представление значения параметра или массив 
		'                         таких представлений.
		':Сигнатура:	
		'   Public Sub AppendParameter(sParameterName [As String], vParameterText [As Variant])
		Public Sub AppendParameter(sParameterName, vParameterText)
			m_oQueryStringParams.AddValue sParameterName, vParameterText
		End Sub

		Public Function Self()
			Set Self = Me
		End Function
	End Class


	'==============================================================================
	' Класс параметров события "OpenReport"
	Class OpenReportEventArgsClass
		Public ReportDirectUrl		' As String - "прямой" URL отчета
		Public ReportName			' As String - наименование отчета, открываемого средсвами ReportService (x-get-report.aspx?NAME=r-{ReportName}.xml
		Public CloseDialog			' As Boolean - True - закрывать диалог после вызова отчета, False - не закрывать
		Public SendUsingPOST                    ' As Boolean - True - всегда передавать параметры на сервер методом POST; False - использовать POST только, если длина URL > MAX_GET_SIZE
		Public QueryStringParamCollectionBuilder' As QueryStringParamCollectionBuilderClassEx - Построитель параметров
		Public Cancel				' As Boolean - признак прервать цепочку обработки событий.
		Public ReturnValue			' As Variant - какие-то данные от обработчиков событий
		
		Public Function Self()
			Set Self = Me
		End Function
	End Class


	'==============================================================================
	' Обработчик нажатия "Отменить"
	Sub XReportFilter_cmdCancel_onClick()
		window.close
	End Sub

	'==============================================================================
	' "Протягивание" параметров, переданных в фильтр, в параметры формирования отчета
	Private Sub MergeQueryStringParamsToReportParamsBuilder(oReportParams)
		Dim oQueryParams	' As QueryStringClass - параметры, переданные в фильтр
		Dim sKey		' As String - наименование параметра
 
		Set oQueryParams = X_GetQueryString()
		For Each sKey In oQueryParams.Names
			If Left(sKey, 1) <> "." And Not oReportParams.IsExists(sKey) Then
				' Если это не параметр, переданный для иницилизации свойства фильтра (не начинается на точку),
				' И фильтр не вернул такого параметра
				oReportParams.SetValues sKey, oQueryParams.GetValues(sKey)
			End If
		Next
	End Sub

	'==============================================================================
	' Обработчик нажатия OK
	Sub XReportFilter_cmdOK_onClick()
		Dim oArguments		' As FilterObjectGetRestrictionsParamsClass
		Dim oBuilder		' As IParamCollectionBuilder
		Dim sUrl
		
		Set oArguments = New FilterObjectGetRestrictionsParamsClass
		Set oBuilder = New QueryStringParamCollectionBuilderClassEx
		Set oArguments.ParamCollectionBuilder = oBuilder
		g_oFilterObject.GetRestrictions oArguments
		If False=oArguments.ReturnValue Then Exit Sub

		' "Протягивание" параметров, переданных в фильтр, в параметры формирования отчета
		MergeQueryStringParamsToReportParamsBuilder oBuilder.QueryStringParams

		With New OpenReportEventArgsClass
			' Инициализируем параметры события
			.ReportDirectUrl = REPORT_DIRECT_URL
			.ReportName = iif( not hasValue(.ReportDirectUrl), X_PAGE_METANAME, Null ) 
			.CloseDialog = False
			.SendUsingPost = CBool(SEND_USING_POST)
			Set .QueryStringParamCollectionBuilder = oBuilder

			XEventEngine_FireEvent g_oEventEngine, "OpenReport", Nothing, .Self()

			sUrl = .ReportDirectUrl
			If Not hasValue(sUrl) Then
				sUrl = "x-get-report.aspx?name=r-" & .ReportName & ".xml"
			End If

			X_OpenReportEx sURL, oBuilder.QueryStringParams, .SendUsingPOST

			If .CloseDialog Then
				window.close
			End If
		End With
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
		g_oEventEngine.InitHandlers "OpenReport", "usrXReportFilter_On"

		' Инициализируем фильтр
		Set oParams = New FilterObjectInitializationParamsClass
		Set oParams.QueryString = X_GetQueryString()
		
		' Востановим состояние, если у метаописания фильтра нет атрибута "off-viewstate"
		' Примечание: фильтр должен всегда быть, мы это проверяли в момент открытия
		If false = X_MD_FILTER_OFF_VIEWSTATE Then
			If XService.GetUserData("XReport/" & X_PAGE_METANAME & "/State", oFilterXmlState) Then
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
				XService.SetUserData "XReport/" & X_PAGE_METANAME & "/State", oXmlFilterState
		End If
	End Sub


	'==============================================================================
	Public Sub EnableControls(bEnable)
		document.all( "XReportFilter_cmdOK").disabled = not bEnable
		document.all( "XReportFilter_cmdCancel").disabled = not bEnable
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
				XReportFilter_cmdCancel_onClick
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
			XReportFilter_cmdOk_onClick
		ElseIf oEventArgs.keyCode = VK_ESC Then 
			XReportFilter_cmdCancel_onClick
		End If
	End Sub
	
	
	'==============================================================================
	' Обработчик события SetCaption, сгенерированного редактором в фильтре (x-filter.htc)
	'	[in] oEventArgs As SetCaptionEventArgsClass
	Public Sub OnSetCaption(oSender, oEventArgs)
		document.all( "XReportFilter_xPaneCaption").innerHtml = oEventArgs.EditorCaption
	End Sub
</SCRIPT>

<asp:PlaceHolder ID="FilterPlaceHolder" runat="server" EnableViewState="false" />

</asp:Content>
