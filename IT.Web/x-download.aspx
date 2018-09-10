<%@ Page Language="C#" EnableViewState="false" ValidateRequest="false" %>
<html xmlns:xfw="http://www.croc.ru/XmlFramework/Behaviors">
<!--
================================================================================
	СТРАНИЦА ПРОСМОТРА/ЗАГРУЗКИ ФАЙЛА
	Параметры: через DialogArguments принамает массив из четырех элементов
		0 - исходный URL
		1 - имя файла для сохранения/просмотра на клиенте
		2 - размер файла
		3 - признак режима просмотра (true/false)
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
	<title>Загрузка данных</title>
	<link href="x.css" rel="STYLESHEET" type="text/css" />
	
	<!-- Стандартные файлы -->
	<script language="VBScript" src="VBS/x-const.vbs" type="text/vbscript"></script>
	<script language="VBScript" src="VBS/x-vbs.vbs" type="text/vbscript"></script>
	<script language="VBScript" src="VBS/x-utils.vbs" type="text/vbscript"></script>
	<script language="VBScript">
	
	Option Explicit

	Dim g_sFileName	' Имя файла для загрузки
	Dim g_sURL		' Откуда грузить-то...
	Dim g_nSize		' Размер для контроля
	Dim g_bViewMode	' Режим загрузки (с просмотром/без просмотра)
	Dim g_bCanClose	' Признак того, что окно загрузки можно закрыть при получении фокуса

	'=========================================================================
	'Обработчик загрузки окна
	Sub window_OnLoad()
		dim aParams 'Набор параметров
		g_bCanClose = false
		' Получим входные параметры страницы
		X_GetDialogArguments aParams
		g_sURL		= aParams(0)	'URL - первый параметр
		g_sFileName = aParams(1)	'FileName - второй параметр
		g_nSize		= aParams(2)	'Размер - третий параметр
		g_bViewMode = aParams(3)	'Режим просмотра - четвертый параметр
		cmdMain.focus 
		' Дождемся прогрузки и инициализации документа
		X_WaitForTrue "Init()" , "X_IsDocumentReadyEx( null, ""XProgressBar"" )"
	End sub

	'=========================================================================
	' Загрузка документа для просмотра
	Sub Init()
		On Error Resume Next
		' Инициализируем ProgressBar (от 0 до 100%, сейчас - 0)
		ProgressObject.SetState 0, 100, 0
		XService.DoEvents()
		idLabel.innerText = "Загрузка файла"
		'В любом случае файл надо сначала загрузить...
		Xservice.Download g_sURL,g_sFileName,g_nSize
		If Err Then
			Alert "Не удалось загрузить файл. Возможно, файл " & g_sFileName & " имеет аттрибут ""Только для чтения ""  или он открыт другим приложением."
			window.close
		End if
	End Sub

	'=========================================================================
	' Обработка события OnProgress от компонента загрузки
	'	[in] nProgress - загружено байт
	'	[in] nProgressMax - размер файла
	Sub XService_OnProgress( nProgress, nProgressMax)
		if nProgressMax > 0 and nProgressMax >= nProgress then
			ProgressObject.SetState 0, nProgressMax, nProgress
		end if
		XService.DoEvents
	End Sub

	'=========================================================================
	' Событие успешного завершения загрузки файла
	Sub XService_OnFinish()
		idLabel.innerText  = "Файл загружен"
		' Инициализируем ProgressBar (от 0 до 100%, сейчас - 100%)
		ProgressObject.SetState 0, 100, 100
		cmdMain.value = "Закрыть"
		'если был передан флаг просмотра, то запустим файл через ShellExecute
		if g_bViewMode then
			setTimeout "X_OpenDocumentForView", 0, "VBScript"	
		else
			' Трюк: просто так закрыть окно из обработчика нельзя
			' поэтому сделаем фиктивный TimeOut - дабы "вытащить"
			' этот код вне стека вызовов обработчика
			setTimeout "window.close", 0, "VBScript"	
		end if
	End Sub

	'=========================================================================
	' Открытие документа на просмотр
	Sub X_OpenDocumentForView
		const NO_SUCH_EXTENSION = -2147024865   ' Код ошибки при отсутствии соотв. программы - обработчика
		dim nErrNo	' Информация об ошибке
		On Error Resume Next
		XService.ShellExecute g_sFileName
		' Трюк: если сразу закрыть форму, то IE получит фокус и
		' перекроет просматриваемый документ. Поэтому форма будет
		' закрыта только при получении фокуса в OnFocus()
		g_bCanClose = true
		with Err
			nErrNo = .number
			if 0=nErrNo then exit sub
			if NO_SUCH_EXTENSION = nErrNo then
				Alert "Ошибка при попытке открыть файл '" & g_sFileName  & "'" & vbNewLine & "Возможно у вас не установлена програма просмотра файлов этого типа."
				exit sub
			end if
			X_ErrReport
		end with
	End Sub

	'=========================================================================
	' При нажатии на ESC закроем окно
	sub Document_OnKeyPress
		if VK_ESC = window.event.keyCode then window.close 
	end sub

	'=========================================================================
	' Событие, индицирующее ошибку при загрузке файла
	Sub XService_OnError( strErrorDescription)
		XService.DoEvents
		Alert "Ошибка при загрузке файла: " & strErrorDescription
		window.close
	End Sub

	'=========================================================================
	' Обработка получения фокуса формой
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
				Идет загрузка файла...</td>
		</tr>
		<tr>
			<td width="100%">
				<xfw:xprogressbar id="ProgressObject" language="VBScript" solidpageborder="false"
					enabled="False" style="width: 100%; height: 24px;" />
			</td>
		</tr>
		<tr>
			<td align="center">
				<button id="cmdMain" name="cmdMain" class="x-button x-button-control" title="Прервать загрузку данных"
					tabindex="0" language="VBScript" onclick="window.close">
					Прервать загрузку</button>
			</td>
		</tr>
	</table>
</body>
</html>
