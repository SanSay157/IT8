<%@ Page Language="C#" 
    AutoEventWireup="true" 
    MasterPageFile="~/xu-it-reports.master"
    Inherits="Croc.XmlFramework.Web.ReportsPage"
 Codebehind="it-reports.aspx.cs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" Runat="Server">
    <SCRIPT LANGUAGE="VBScript" TYPE="text/VBScript">
    Option Explicit
	
	Dim g_oNavigationMenuClass 	' ��������� ������ NavigationMenuClass (��. it-nav-menu.vbs)
	
	'===========================================================================
	' �����, ������������� ����������� � ������ �������� �������������� HTML-����
	Class NavigationMenuClass
		Private m_oEventEngine		' As EventEngineClass - ��������� EventEngine,
		Private m_oMenu				' As MenuClass - ������ ����
		'Private MenuHtml
		Private m_oPlaceholderElement
		'=======================================================================
		' ���������� ��������� MenuClass
		Public Property Get Menu
			Set Menu = m_oMenu
		End Property
		
		'=======================================================================
		' "�����������" (���������� ������� ��������������� ������)
		Private Sub Class_Initialize
			Set m_oEventEngine = X_CreateEventEngine		
			Set m_oMenu = Nothing
		End Sub
		
		'=======================================================================
		'	[in] oMenuMetadata - ���������� ����
		'	[in] oPlaceholderElement - HTML-�������, � ������� ������������ 
		'		�������������� ����
		Public Sub ShowMenu( oMenuMetadata, oPlaceholderElement )
		    Set m_oPlaceholderElement = oPlaceholderElement 
			Set m_oMenu = new MenuClass
			m_oMenu.SetMacrosResolver X_CreateDelegate(Me, "MenuMacrosResolver")
			m_oMenu.SetVisibilityHandler X_CreateDelegate(Me, "MenuVisibilityHandler")
			m_oMenu.SetExecutionHandler X_CreateDelegate(Me, "MenuExecutionHandler")
			
			m_oMenu.Init oMenuMetadata
			'm_oMenu.PrepareMenu(Me)
			'Set MenuHtml = document.all("MenuHtml")
			'MenuHtml.Render Me, m_oMenu, GetRef("GetNavigationMenuXsl")
			Dim oXsl 
			Set oXsl =  GetNavigationMenuXsl("")
			'oPlaceholderElement.innerHtml = m_oMenu.CreateHtmlMenu( window, "MenuHandler", oXsl)
			RenderMenu oPlaceholderElement, m_oMenu, oXsl  
		End Sub
		
		'==============================================================================
		' ����������� ������-�������� ��� ����
		'	[in] oEventArgs As MenuEventArgsClass
		Public Sub MenuMacrosResolver(oSender, oEventArgs)
			' TODO:
		End Sub
		
		'==============================================================================
		' ����������� ���������� ��������� ���������/����������� ������� ����. 
		'	[in] oEventArgs As MenuEventArgsClass
		Public Sub MenuVisibilityHandler(oSender, oEventArgs)
			' TODO:
		End Sub
		
		'==============================================================================
		' ����������� ��������� ������ ������ ���� (� � Html � � Popup ����). 
		'	[in] oEventArgs As MenuExecuteEventArgsClass
		Public Sub MenuExecutionHandler(oSender, oEventArgs)
			Dim oMenu			' As MenuClass
			Dim sMetaname		' ������ � ����������������� (������, ��������); 
			Dim sObjectType		' ������ � ������������� ���� �������;
			
			Dim sUrl			' ������ � URL-������� �������� (�������� DoNavigate)
			Dim sNavTarget		' ������ � ������������� ������ ���� IE (�������� DoNavigate)
			Dim sNavParams		' ������ � ����������� ����������� ������ ���� IE (�������� DoNavigate)
			Dim bUseOwnBaseUrl	' ������� ������������� �������� ������ ������� ��������, ��� �������
								' ������ ��� ��������, ����������� � ����� ���� IE (�������� DoNavigate)
			Dim oNavWindow		' ����� ���� IE (�������� DoNavigate)
			
			Set oMenu = oEventArgs.Menu
			
			Select Case oEventArgs.Action
				' ... �������� ������ ������ 
				Case "DoOpenReport"
					OnOpenReport oMenu.Macros
			
				Case "DoScriptAction"
					' TODO:
					Alert "����� ��������� - ���� �� ����������"
					
				Case "DoNavigate"
					sUrl = Trim( oMenu.Macros.Item("Url") & "" )
					sNavTarget = Trim( oMenu.Macros.Item("NavigationTarget") & "" )
					sNavParams = Trim( oMenu.Macros.Item("NavigationParams") & "" )
					bUseOwnBaseUrl = oMenu.Macros.Exists("UseOwnBaseUrl")
					
					If Not hasValue(sUrl) Then
						Err.Raise -1, "","�� ����� ����� �������� (�������� sUrl)"
					End If
					If Not hasValue(sNavTarget) And Not hasValue(sNavParams) Then
						window.setTimeout "window.location.href=""" & XService.BaseURL & sUrl & """", 1, "VBScript"
					Else
						If Not hasValue(sNavParams) Then sNavParams = "location=yes, menubar=yes, resizable=yes, scrollbars=yes, status=yes, titlebar=yes, toolbar=yes"
						If bUseOwnBaseUrl Then sUrl = XService.BaseURL & sUrl
						Set oNavWindow = window.open( sUrl, sNavTarget, sNavParams, true )
						If hasValue(oNavWindow) And IsObject(oNavWindow) Then oNavWindow.focus
					End If
					
				Case "DoOpenTree"
					sMetaname = oMenu.Macros.Item("Metaname")
					If Not hasValue(sMetaname) Then
						Err.Raise -1, "", "�� ������ ���������������� �������� (�������� Metaname)"
					End If
					window.setTimeout "window.location.href=""" & XService.BaseURL & "x-tree.aspx?Metaname=" &  sMetaname & """", 0, "VBScript"
					
				Case "DoOpenList"
					sObjectType = oMenu.Macros.Item("ObjectType")
					If Not hasValue(sObjectType) Then
						Err.Raise -1, "", "�� ������ ������������ ���� (�������� ObjectType)"
					End If
					sUrl = XService.BaseURL & "x-list.aspx?OT=" & sObjectType
					sMetaname = oMenu.Macros.Item("Metaname")
					If hasValue(sMetaname) Then
						sUrl = sUrl & "&Metaname=" & sMetaname
					End If
					window.setTimeout "window.location.href=""" &  sUrl & """", 0, "VBScript"
			End Select
		End Sub
		
		'==============================================================================
		' ����������� ��������� "��������" ������ ������ 
		'	[in] oMacros - ��������� �������� ��������
		Public Sub OnOpenReport( oMacros )
			Dim sReportDefName	' ���������������� ����������� ������ i:report 
								' � ���������� ����������; 
								
			' ���������������� ������ �������� ��� �������� ������ ����, ��������
			' �������� i:menu-item/i:params/i:param c n="ReportDefinition"
			If hasValue( oMacros.Item("ReportDefinition") ) Then
				sReportDefName = CStr(oMacros.Item("ReportDefinition"))
				X_RunReport sReportDefName, null
			End If
		End Sub
			'================================================================
' ��������� ��������� ���� � HTML � ������� XSLT-�������
'	[in] oSender - ������ �� ������������ ������, ������������ � execution-handler'�
'	[in] oMenu As MenuClass - ������������ ����. ������ ���� ����������������
'	[in] oMenuXSL As XMLDOMDocument Xslt-���������
    public Sub RenderMenu(oPlaceholderElement,oMenu, oMenuXSL)
	    Dim oTemplate	' XslTemplate
	    Dim oProcessor	' XslProcessor
		Dim m_oSender
		Dim m_oMenu
    	'Set m_oSender = oSender
    	Set m_oMenu = oMenu

    	' ���������� ����
	    oMenu.PrepareMenu window
		
    	' ������� ������ IXSLTTemplate
    	Set oTemplate = CreateObject( "MSXml2.XslTemplate.3.0")
    	oTemplate.stylesheet = oMenuXSL
    	Set oProcessor = oTemplate.createProcessor
    	oProcessor.addParameter "handler-proc-name", "MenuHandler"
    	' ������� �������� � xsl-������ - ��� ���������, ���������� ��� ����� �� ������ ����
    	'oProcessor.addParameter "handler-proc-name", "MenuHandler"
    	'On Error Resume Next
    	oProcessor.input = oMenu.XmlMenu
    	
		
	    ' ���������� ����
	    oProcessor.transform
	    oPlaceholderElement.innerHTML = oProcessor.output
    End Sub
	
	End Class
	
	
	
	'===========================================================================
	' ��������� �����, ��������� ��� "�����" �� ������ HTML-����
	' �������� ���������� � ������ ����, ����������������� � NavigationMenuClass
	Sub MenuHandler(sAction)
		If hasValue(g_oNavigationMenuClass) Then
			g_oNavigationMenuClass.Menu.RunExecutionHandlers window, sAction
		End If
	End Sub
	
	'===========================================================================
	' ��������� �����, ������������ ������ (XML DomDocument) ����� XSLT-��������, 
	' ������������� ��� �������������� ���� � HTML
	Function GetNavigationMenuXsl( sXslFileName )
		Dim oMenuXsl
		
		sXslFileName = Trim("" & sXslFileName)
		If 0 = Len(sXslFileName) Then sXslFileName = "it-nav-menu.xsl"
		
		Set oMenuXsl = XService.XMLGetDocument( "XSL\" & sXslFileName ) 
		Set GetNavigationMenuXsl = oMenuXsl
	End Function
	
'===========================================================================
	' ���������� ������� �������� ����	
	Sub Window_OnLoad()
		Dim vMenuMD	' XML-������ ���� �� XML-�������� c ��������������� oNavigationMenu
		Dim xPaneMain
		' �������� XML � ��������� ������ ����
		Set vMenuMD = document.all("oNavigationMenu",0)
		Set xPaneMain = document.all("XDefault_xPaneMain")
		If Not vMenuMD Is Nothing Then 
			vMenuMD = vMenuMD.value
		Else
			vMenuMD = ""
		End If
		''MenuHtml.sss
		' ���� XML ������ ���� ������������, ��������� ���� ����.
		' ��� ����������� � ��������� ��������� ������ MenuClass
		If Len(vMenuMD) > 0 Then
			Set vMenuMD = XService.XMLFromString(vMenuMD)
			If Not vMenuMD Is Nothing Then
				Set g_oNavigationMenuClass = new NavigationMenuClass
				g_oNavigationMenuClass.ShowMenu vMenuMD, xPaneMain
			End If
		End If
	End Sub
	</SCRIPT>
	<?import namespace="XFW" implementation="x-menu-html.htc"/?>
	<XFW:XMenuHtml
			ID="MenuHtml" language="VBScript" 
			SolidPageBorder="false" 
			Enabled="True" 
			style="width:100%; height:100%;"
		/>
	
	<!-- XML-�������� ������ �������������� ���� -->
	<% WriteNavigationMenuMetadata(); %>
</asp:Content>