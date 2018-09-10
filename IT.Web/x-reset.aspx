<%@ Page 
	Language="c#" 
	ValidateRequest="false" 
	AutoEventWireup="true" 
	Inherits="Croc.XmlFramework.Web.XResetPage" 
	
	EnableViewState="false"
	EnableSessionState="True" 
 Codebehind="~/x-reset.aspx.cs" %>
<!--
	������ �������� ������������� ��� ����������� ������� ������ � �������� �� 
	�������� ��������. ��� ����� ���� ������� ��� ����������� ����������.
-->
<html>
<head runat="server" enableviewstate="false">
	<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
	<title>����� ������</title>
	<link rel="SHORTCUT ICON" href="Icons/xu-application-icon.ico">
</head>
<SCRIPT LANGUAGE="VBScript">
	Option Explicit
	' ��������� �������� �������� �� �������
	Sub Window_OnLoad
		Const DELAY = 4000	' �������� ����� ��������� �����
		On Error Resume Next
		' ���������� ������� ����������������������� ���������� � ������
		document.cookie = XService.URLEncode( UCase(XService.BaseURL())) & "METADATA=0"
		' ���������� ������� ����������������������� ������� � ������
		document.cookie = XService.URLEncode( UCase(XService.BaseURL())) & "CONFIG=0"
		If Err Then
			MsgBox "�� ������� �������� ������� ������� ���������� �� �������", vbCritical
		End If
		g_oBackCmd.style.display = "BLOCK"		
		window.setTimeout "Go_Back", DELAY , "VBScript" 
	End Sub
	
	' ������������ �� ���������� ��������				
	Sub Go_Back
		<% if (m_sReturnPage.Length==0)
		{%>
		window.history.back
		<%} 
		else 
		{%>
		window.location.href= "<%= m_sReturnPage %>" & CDbl(Now)	
		<%};%>
	End Sub
	
</SCRIPT>

<body scroll=NO>
	<div style="font-family:Verdana; font:bold 12; color:#036;">������ ��������...</div>
	<br/>
	<button id="g_oBackCmd" style="font-family:Verdana; font:normal 12; display:none;" language="VBScript" onclick="Go_Back"> ����� </button>
</body>
</html>
