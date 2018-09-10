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
	Dim g_oFilterObject		' ������ (HTC-Behavior) �������

	'===============================================================================
	':����������:	
	'	���������� ���������� IParamCollectionBuilder �� ������ ������ QueryStringClass (������ �������)
	Class QueryStringParamCollectionBuilderClassEx

		Private m_oQueryStringParams	'[As QueryStringClass]

		'---------------------------------------------------------------------------
		' �����������
		Private Sub Class_Initialize()
			Set m_oQueryStringParams = New QueryStringClass
		End Sub

		'---------------------------------------------------------------------------
		' ����������
		Private Sub Class_Terminate()
			Set m_oQueryStringParams = Nothing
		End Sub

		'------------------------------------------------------------------------------
		':����������:
		'	����� ��� ������ � �����������
		':����������:
		'	�������� �������� ������ ��� ������.
		':���������:
		'	Public Property Get QueryStringParams [As QueryStringParam]
		Public Property Get QueryStringParams
			Set QueryStringParams = m_oQueryStringParams
		End Property

		'------------------------------------------------------------------------------
		':����������:
		'	������ �����������.
		':����������:
		'	�������� �������� ������ ��� ������.
		':���������:
		'	Public Property Get QueryString [As String]
		Public Property Get QueryString
			QueryString = m_oQueryStringParams.QueryString
		End Property

		'------------------------------------------------------------------------------
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
			m_oQueryStringParams.AddValue sParameterName, vParameterText
		End Sub

		Public Function Self()
			Set Self = Me
		End Function
	End Class


	'==============================================================================
	' ����� ���������� ������� "OpenReport"
	Class OpenReportEventArgsClass
		Public ReportDirectUrl		' As String - "������" URL ������
		Public ReportName			' As String - ������������ ������, ������������ ��������� ReportService (x-get-report.aspx?NAME=r-{ReportName}.xml
		Public CloseDialog			' As Boolean - True - ��������� ������ ����� ������ ������, False - �� ���������
		Public SendUsingPOST                    ' As Boolean - True - ������ ���������� ��������� �� ������ ������� POST; False - ������������ POST ������, ���� ����� URL > MAX_GET_SIZE
		Public QueryStringParamCollectionBuilder' As QueryStringParamCollectionBuilderClassEx - ����������� ����������
		Public Cancel				' As Boolean - ������� �������� ������� ��������� �������.
		Public ReturnValue			' As Variant - �����-�� ������ �� ������������ �������
		
		Public Function Self()
			Set Self = Me
		End Function
	End Class


	'==============================================================================
	' ���������� ������� "��������"
	Sub XReportFilter_cmdCancel_onClick()
		window.close
	End Sub

	'==============================================================================
	' "������������" ����������, ���������� � ������, � ��������� ������������ ������
	Private Sub MergeQueryStringParamsToReportParamsBuilder(oReportParams)
		Dim oQueryParams	' As QueryStringClass - ���������, ���������� � ������
		Dim sKey		' As String - ������������ ���������
 
		Set oQueryParams = X_GetQueryString()
		For Each sKey In oQueryParams.Names
			If Left(sKey, 1) <> "." And Not oReportParams.IsExists(sKey) Then
				' ���� ��� �� ��������, ���������� ��� ������������ �������� ������� (�� ���������� �� �����),
				' � ������ �� ������ ������ ���������
				oReportParams.SetValues sKey, oQueryParams.GetValues(sKey)
			End If
		Next
	End Sub

	'==============================================================================
	' ���������� ������� OK
	Sub XReportFilter_cmdOK_onClick()
		Dim oArguments		' As FilterObjectGetRestrictionsParamsClass
		Dim oBuilder		' As IParamCollectionBuilder
		Dim sUrl
		
		Set oArguments = New FilterObjectGetRestrictionsParamsClass
		Set oBuilder = New QueryStringParamCollectionBuilderClassEx
		Set oArguments.ParamCollectionBuilder = oBuilder
		g_oFilterObject.GetRestrictions oArguments
		If False=oArguments.ReturnValue Then Exit Sub

		' "������������" ����������, ���������� � ������, � ��������� ������������ ������
		MergeQueryStringParamsToReportParamsBuilder oBuilder.QueryStringParams

		With New OpenReportEventArgsClass
			' �������������� ��������� �������
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
	' ������������� ��������
	Sub Window_OnLoad()	
		X_WaitForTrue "Init()" , "X_IsDocumentReadyEx(null, ""XFilter"")"
	End Sub


	'==============================================================================
	' ������������� ��������
	Sub Init()
		Dim oParams			' ��������� ��� ������������� �������
		Dim oFilterXmlState	' ��������� �������
		
		Set g_oEventEngine = X_CreateEventEngine()
		Set g_oFilterObject = X_GetFilterObject( document.all( "FilterFrame") )

		' �������������� ���������������� ����������� ������� ����������� ��������� (�� ����� �����)
		g_oEventEngine.InitHandlers "OpenReport", "usrXReportFilter_On"

		' �������������� ������
		Set oParams = New FilterObjectInitializationParamsClass
		Set oParams.QueryString = X_GetQueryString()
		
		' ���������� ���������, ���� � ������������ ������� ��� �������� "off-viewstate"
		' ����������: ������ ������ ������ ����, �� ��� ��������� � ������ ��������
		If false = X_MD_FILTER_OFF_VIEWSTATE Then
			If XService.GetUserData("XReport/" & X_PAGE_METANAME & "/State", oFilterXmlState) Then
				Set oParams.XmlState = oFilterXmlState
			End If
		End If

		g_oEventEngine.AddHandlerForEvent "EnableControls", Nothing, GetRef("OnEnableControls")
		g_oEventEngine.AddHandlerForEvent "Accel", Nothing, GetRef("OnAccel")
		g_oEventEngine.AddHandlerForEvent "SetCaption", Nothing, GetRef("OnSetCaption")
		If g_oFilterObject.Init (g_oEventEngine, oParams) Then
			' ������� ���������� ������������� ��������
			X_WaitForTrue "Init2" , "X_IsDocumentReady( null) and g_oFilterObject.IsReady"
		Else
			Alert "������ ������������� �������!"
		End If
	End Sub


	'==============================================================================
	' ���������� ������������� ��������
	Sub Init2
		EnableControls true
	End Sub

	
	'==============================================================================
	' ���������� �������� ����
	Sub Window_OnUnLoad
		Dim oXmlFilterState ' As IXMLDOMElement, ��������� �������
		
		' �������� ��������� ������� (���� �� ���������)
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
	' ���������� ������� EnableControls, ���������������� �������� (x-filter.htc)
	'	[in] oEventArgs - EnableControlsEventArgs
	Public Sub OnEnableControls(oSender, oEventArgs)
		EnableControls oEventArgs.Enable
	End Sub

	'==============================================================================
	' ���������� ������� Accel, ���������������� �������� (x-filter.htc)
	'	[in] oEventArgs - AccelerationEventArgsClass
	Public Sub OnAccel(oSender, oEventArgs)
		If oEventArgs.keyCode = VK_ENTER Then
			XReportFilter_cmdOk_onClick
		ElseIf oEventArgs.keyCode = VK_ESC Then 
			XReportFilter_cmdCancel_onClick
		End If
	End Sub
	
	
	'==============================================================================
	' ���������� ������� SetCaption, ���������������� ���������� � ������� (x-filter.htc)
	'	[in] oEventArgs As SetCaptionEventArgsClass
	Public Sub OnSetCaption(oSender, oEventArgs)
		document.all( "XReportFilter_xPaneCaption").innerHtml = oEventArgs.EditorCaption
	End Sub
</SCRIPT>

<asp:PlaceHolder ID="FilterPlaceHolder" runat="server" EnableViewState="false" />

</asp:Content>
