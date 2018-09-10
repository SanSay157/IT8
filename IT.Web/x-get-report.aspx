<%@ Page Language="C#" ValidateRequest="false" AutoEventWireup="true" 
    MasterPageFile="~/xu-get-report.master" Inherits="Croc.XmlFramework.Web.XGetReport" 
    Buffer="false" EnableViewState="false" EnableSessionState="True" Codebehind="x-get-report.aspx.cs" %>

<%@ Import Namespace="Croc.XmlFramework.Public" %>

<asp:Content runat="server" ContentPlaceHolderID="ContentPlaceHolderForReport" EnableViewState="false">
    <!-- Вставляем значения параметров отчета, переданных через POST -->
    <%= getReportFormParamsScript() %>

    <script language="JavaScript" type="text/javascript" src="VBS/x-report.js" charset="windows-1251"></script>

	<script type="text/javascript" language="JavaScript">
		var sMasterPagePrefix = "<%= MASTER_PREFIX %>_";    // Префикс для контролов на мастер-странице
		var sRefreshURL = "x-get-report.aspx";              // УРЛ на свою же страницу
		var iSecsDelay = <%= POLLING_INTERVAL %>;           // Задержка до повторной перезагрузки фрейма
		var sReportCmdID = "<%= ReportCmdID %>";            // Идентификатор команды, выполняющей построение отчета
		var oFrame = null;                                  // элемент iframe

		window.onload = window_onload;
		window.onunload = window_onunload;
		
		// Обработчик на загрузку страницы
		function window_onload()
		{
			oFrame = document.getElementById("frameContent");   // Тут берем именно сам iframe элемент
			// Начнем опрос состояния формирования отчета. 
			// Вызываем через таймер, чтобы встать в конец очереди обработки сообщений
			window.setTimeout("refreshFrame()", 500);
		}

		// Обработчик на выгрузку страницы. Используется для нотификации сервера о том,
		// что текущий отчет уже никому не нужен!
		function window_onunload()
		{
			refreshFrameWithExecMode(<%= (int)ExecModeEnum.EXIT_MODE %>);
		}
		
		// Обработчик окончания загрузки содержимого фрейма        
		function frameContent_onload()
		{ 
			var oDoc = GetFrameDocument(oFrame);
			if (!oDoc || oDoc.location == "about:blank")
				return;
			
			var sStatus = oDoc.documentElement.getAttribute("reportStatus");
			if (!sStatus)
				showFrame();    // нет такого атрибута. Значит, уже сам отчет или сообщение об ошибке

			else if (sStatus == "<%= INVALID_COMMAND %>")
				// Невалидная команда. Получается при возвращении кнопкой НАЗАД броузера.Надо заново обновить всю страницу
				window.location.reload(true);

			else if (sStatus != "<%= XCommandStatusEnum.OK.ToString() %>" &&
					 sStatus != "<%= XCommandStatusEnum.FAIL.ToString() %>")
				window.setTimeout("refreshFrame()", iSecsDelay * 1000);     // Перезагрузка фрейма по истечению таймаута

			else
			{
				// Команда завершилась. Надо получить содержимое
				
				// Разбираем адресную строку
				var oURLParams = new URLParams(document.URL);
				// Получаем параметры, переданные через POST
				var oFormPostData = new FormPostData();
				// Считываем служебные параметры
				var sOutputFormat = oFormPostData.GetValue("<%= OUTPUTFORMAT_PARAM %>") || oURLParams.GetValue("<%= OUTPUTFORMAT_PARAM %>");

				// Меняем надпись
				var oElem = document.getElementById(sMasterPagePrefix + "xPaneProcessMessage");
				if (oElem)
					oElem.innerHTML = "Отчет сформирован";
				
				if (sStatus == "<%= XCommandStatusEnum.FAIL.ToString() %>")
				{
					// Если отчет НЕ сформировался успешно, то загружаем во фрейм.
					refreshFrameWithExecMode(<%= (int)ExecModeEnum.SYNC_MODE %>);                     
				}
				else if (sOutputFormat && sOutputFormat.toUpperCase() != "HTML")
				{
					// Если это НЕ ХТМЛ, то загружаем во фрейм.
					// И ждем прогрузки, чтобы убить данное окно браузера
					refreshFrameWithExecMode(<%= (int)ExecModeEnum.SYNC_MODE %>);
					window.setTimeout("checkAttachmentBeforeClose()", iSecsDelay * 1000);
				}
				else
				{
					// Это ХТМЛ, переходим на него (если грузить во фрейм, то печать не работает!)
					
					// Через POST передаем идентификатор команды (чтобы не светить в адресной строке)
					oFormPostData.SetValue("<%= REPORT_CMDID_PARAM %>", sReportCmdID);
					// Финт ушами: через POST передаем синхронный режим для получения контента, 
					// а в адресной строке светим асинхронный режим. Работает из-за приоритета POST при разборе
					oFormPostData.SetValue("<%= EXECMODE_PARAM %>", <%= (int)ExecModeEnum.SYNC_MODE %>);
					oURLParams.SetValue("<%= EXECMODE_PARAM %>", <%= (int)ExecModeEnum.ASYNC_MODE %>);
					oFormPostData.Submit(window, oURLParams.toString(), "_top");
				}
				
				// Сбросим идентификатор команды, ибо при выходе со странице уже не надо извещать об этом сервер
				sReportCmdID = "";
			}
		}
		
		// Перезагрузка фрейма для обновления состояния формирования отчета
		function refreshFrame()
		{
			refreshFrameWithExecMode(<%= (int)ExecModeEnum.ASYNC_MODE %>);
		}

		// Перезагрузка фрейма с определенным режимом построения отчета
		function refreshFrameWithExecMode(nExecMode)
		{
			if (!sReportCmdID)
				return;
			var tm = (new Date()).getTime();             // Рандомизируем УРЛ, чтобы принуждать к загрузке
			var sURL = sRefreshURL + "?<%= REPORT_CMDID_PARAM %>=" + sReportCmdID +
					   "&<%= EXECMODE_PARAM %>=" + nExecMode + "&tm=" + tm.toString();
			var oDoc = GetFrameDocument(oFrame);
			if (oDoc)
				oDoc.location.replace(sURL);
		}
				
		// Попытка отследить загрузку атачмента (для IE). После чего закрываем окно браузера (для всех)
		function checkAttachmentBeforeClose()
		{
			var oDoc = GetFrameDocument(oFrame);
			if (oDoc.readyState)
			{
				if (oDoc.readyState != "complete" && oDoc.readyState != "interactive")
				{
					window.setTimeout("checkAttachmentBeforeClose()", 1000);
					return;
				}
			}
			window.setInterval("window.close()", 1000);
		}
		
		// Отображаем содержимое фрейма
		function showFrame()
		{
			var oDoc = GetFrameDocument(oFrame);
			document.title = oDoc.title;
			var oElem = document.getElementById(sMasterPagePrefix + "xLayoutGrid");
			if (!oElem)
				oElem = document.getElementById(sMasterPagePrefix + "xPaneProcessMessage");
			if (oElem)
				oElem.style.display = "none";
				
		   oFrame.style.display = "block";
		}
	</script>

    <!-- Фрейм, в который загружается содержимое формируемого отчета.
         То, что у фрейма сразу не задан параметр SRC - неспроста!
         Дело в том, что если фрейм грузит страницу с атачментом (отчет - файл),
         то обработчики событий на загрузку/выгрузку окна не срабатывают!
    -->
    <iframe id="frameContent" onload="javascript:frameContent_onload()" 
        width="100%" height="100%" frameborder="0" style="width: 100%; height: 100%; display: none;">
    </iframe>
</asp:Content>
