<%@ Page 
	Language="c#" 
	ValidateRequest="false" 
	AutoEventWireup="true" 
	Inherits="Croc.XmlFramework.Web.XResetPage" 
	
	EnableViewState="false"
	EnableSessionState="True" 
 Codebehind="~/x-reset.aspx.cs" %>
<!--
	Данная страница предназначена для уничтожения текущей сессии и возврата на 
	исходную страницу. Это может быть полезно при модификации метаданных.
-->
<html>
<head runat="server" enableviewstate="false">
	<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
	<title>Сброс сессии</title>
	<link rel="SHORTCUT ICON" href="Icons/xu-application-icon.ico">
</head>
<SCRIPT LANGUAGE="VBScript">
	Option Explicit
	' Обработка загрузки страницы на клиенте
	Sub Window_OnLoad
		Const DELAY = 4000	' задержка перед возвратом назад
		On Error Resume Next
		' Сбрасываем признак проинициализированности метаданных в сессии
		document.cookie = XService.URLEncode( UCase(XService.BaseURL())) & "METADATA=0"
		' Сбрасываем признак проинициализированности конфига в сессии
		document.cookie = XService.URLEncode( UCase(XService.BaseURL())) & "CONFIG=0"
		If Err Then
			MsgBox "Не удалось сбросить признак наличия метаданных на клиенте", vbCritical
		End If
		g_oBackCmd.style.display = "BLOCK"		
		window.setTimeout "Go_Back", DELAY , "VBScript" 
	End Sub
	
	' Возвращаемся на предыдущую страницу				
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
	<div style="font-family:Verdana; font:bold 12; color:#036;">Сессия сброшена...</div>
	<br/>
	<button id="g_oBackCmd" style="font-family:Verdana; font:normal 12; display:none;" language="VBScript" onclick="Go_Back"> Назад </button>
</body>
</html>
