<%@ Page Language="C#" EnableViewState="false" ValidateRequest="false" %>
<html xmlns:xfw="http://www.croc.ru/XmlFramework/Behaviors">
<!--
================================================================================
	�������� ���������/�������� �����
	���������: ����� DialogArguments ��������� ������ �� ������� ���������
		0 - �������� URL
		1 - ��� ����� ��� ����������/��������� �� �������
		2 - ������ �����
		3 - ������� ������ ��������� (true/false)
================================================================================
-->
<%
	Croc.XmlFramework.Web.XUIPage.InstallXService( Page.Header.Controls);
	Croc.XmlFramework.Web.XUIPage.InstallXDownload(Page.Header.Controls);
	Croc.XmlFramework.Web.XUIPage.InstallMSXML(Page.Header.Controls);
%>
<head id="Head1" runat="server">
	<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
	<?import namespace="xfw" implementation="x-progress-bar.htc"/> 
	<title>�������� ������</title>
	<link href="x.css" rel="STYLESHEET" type="text/css" />
	
	<!-- ����������� ����� -->
	<script language="VBScript" src="VBS/x-const.vbs" type="text/vbscript"></script>
	<script language="VBScript" src="VBS/x-vbs.vbs" type="text/vbscript"></script>
	<script language="VBScript" src="VBS/x-utils.vbs" type="text/vbscript"></script>
	<script language="VBScript">
	
	Option Explicit

	Dim g_sFileName	' ��� ����� ��� ��������
	Dim g_sURL		' ������ �������-��...
	Dim g_nSize		' ������ ��� ��������
	Dim g_bViewMode	' ����� �������� (� ����������/��� ���������)
	Dim g_bCanClose	' ������� ����, ��� ���� �������� ����� ������� ��� ��������� ������

	'=========================================================================
	'���������� �������� ����
	Sub window_OnLoad()
		dim aParams '����� ����������
		g_bCanClose = false
		' ������� ������� ��������� ��������
		X_GetDialogArguments aParams
		g_sURL		= aParams(0)	'URL - ������ ��������
		g_sFileName = aParams(1)	'FileName - ������ ��������
		g_nSize		= aParams(2)	'������ - ������ ��������
		g_bViewMode = aParams(3)	'����� ��������� - ��������� ��������
		cmdMain.focus 
		' �������� ��������� � ������������� ���������
		X_WaitForTrue "Init()" , "X_IsDocumentReadyEx( null, ""XProgressBar"" )"
	End sub

	'=========================================================================
	' �������� ��������� ��� ���������
	Sub Init()
		On Error Resume Next
		' �������������� ProgressBar (�� 0 �� 100%, ������ - 0)
		ProgressObject.SetState 0, 100, 0
		XService.DoEvents()
		idLabel.innerText = "�������� �����"
		'� ����� ������ ���� ���� ������� ���������...
		Xservice.Download g_sURL,g_sFileName,g_nSize
		If Err Then
			Alert "�� ������� ��������� ����. ��������, ���� " & g_sFileName & " ����� �������� ""������ ��� ������ ""  ��� �� ������ ������ �����������."
			window.close
		End if
	End Sub

	'=========================================================================
	' ��������� ������� OnProgress �� ���������� ��������
	'	[in] nProgress - ��������� ����
	'	[in] nProgressMax - ������ �����
	Sub XService_OnProgress( nProgress, nProgressMax)
		if nProgressMax > 0 and nProgressMax >= nProgress then
			ProgressObject.SetState 0, nProgressMax, nProgress
		end if
		XService.DoEvents
	End Sub

	'=========================================================================
	' ������� ��������� ���������� �������� �����
	Sub XService_OnFinish()
		idLabel.innerText  = "���� ��������"
		' �������������� ProgressBar (�� 0 �� 100%, ������ - 100%)
		ProgressObject.SetState 0, 100, 100
		cmdMain.value = "�������"
		'���� ��� ������� ���� ���������, �� �������� ���� ����� ShellExecute
		if g_bViewMode then
			setTimeout "X_OpenDocumentForView", 0, "VBScript"	
		else
			' ����: ������ ��� ������� ���� �� ����������� ������
			' ������� ������� ��������� TimeOut - ���� "��������"
			' ���� ��� ��� ����� ������� �����������
			setTimeout "window.close", 0, "VBScript"	
		end if
	End Sub

	'=========================================================================
	' �������� ��������� �� ��������
	Sub X_OpenDocumentForView
		const NO_SUCH_EXTENSION = -2147024865   ' ��� ������ ��� ���������� �����. ��������� - �����������
		dim nErrNo	' ���������� �� ������
		On Error Resume Next
		XService.ShellExecute g_sFileName
		' ����: ���� ����� ������� �����, �� IE ������� ����� �
		' ��������� ��������������� ��������. ������� ����� �����
		' ������� ������ ��� ��������� ������ � OnFocus()
		g_bCanClose = true
		with Err
			nErrNo = .number
			if 0=nErrNo then exit sub
			if NO_SUCH_EXTENSION = nErrNo then
				Alert "������ ��� ������� ������� ���� '" & g_sFileName  & "'" & vbNewLine & "�������� � ��� �� ����������� �������� ��������� ������ ����� ����."
				exit sub
			end if
			X_ErrReport
		end with
	End Sub

	'=========================================================================
	' ��� ������� �� ESC ������� ����
	sub Document_OnKeyPress
		if VK_ESC = window.event.keyCode then window.close 
	end sub

	'=========================================================================
	' �������, ������������ ������ ��� �������� �����
	Sub XService_OnError( strErrorDescription)
		XService.DoEvents
		Alert "������ ��� �������� �����: " & strErrorDescription
		window.close
	End Sub

	'=========================================================================
	' ��������� ��������� ������ ������
	Sub OnFocus()
		if g_bCanClose then
			window.close
		end if
	End Sub
	
	</script>
</head>

<body scroll="no" language="VBScript" onfocus="OnFocus">
	<table border="0" width="100%" height="100%">
		<tr>
			<td id="idLabel" align="center">
				���� �������� �����...</td>
		</tr>
		<tr>
			<td width="100%">
				<xfw:xprogressbar id="ProgressObject" language="VBScript" solidpageborder="false"
					enabled="False" style="width: 100%; height: 24px;" />
			</td>
		</tr>
		<tr>
			<td align="center">
				<button id="cmdMain" name="cmdMain" class="x-button x-button-control" title="�������� �������� ������"
					tabindex="0" language="VBScript" onclick="window.close">
					�������� ��������</button>
			</td>
		</tr>
	</table>
</body>
</html>
