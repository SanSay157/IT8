<%@ Page Language="C#" ValidateRequest="false" AutoEventWireup="true" 
    MasterPageFile="~/xu-get-report.master" Inherits="Croc.XmlFramework.Web.XGetReport" 
    Buffer="false" EnableViewState="false" EnableSessionState="True" Codebehind="x-get-report.aspx.cs" %>

<%@ Import Namespace="Croc.XmlFramework.Public" %>

<asp:Content runat="server" ContentPlaceHolderID="ContentPlaceHolderForReport" EnableViewState="false">
    <!-- ��������� �������� ���������� ������, ���������� ����� POST -->
    <%= getReportFormParamsScript() %>

    <script language="JavaScript" type="text/javascript" src="VBS/x-report.js" charset="windows-1251"></script>

	<script type="text/javascript" language="JavaScript">
		var sMasterPagePrefix = "<%= MASTER_PREFIX %>_";    // ������� ��� ��������� �� ������-��������
		var sRefreshURL = "x-get-report.aspx";              // ��� �� ���� �� ��������
		var iSecsDelay = <%= POLLING_INTERVAL %>;           // �������� �� ��������� ������������ ������
		var sReportCmdID = "<%= ReportCmdID %>";            // ������������� �������, ����������� ���������� ������
		var oFrame = null;                                  // ������� iframe

		window.onload = window_onload;
		window.onunload = window_onunload;
		
		// ���������� �� �������� ��������
		function window_onload()
		{
			oFrame = document.getElementById("frameContent");   // ��� ����� ������ ��� iframe �������
			// ������ ����� ��������� ������������ ������. 
			// �������� ����� ������, ����� ������ � ����� ������� ��������� ���������
			window.setTimeout("refreshFrame()", 500);
		}

		// ���������� �� �������� ��������. ������������ ��� ����������� ������� � ���,
		// ��� ������� ����� ��� ������ �� �����!
		function window_onunload()
		{
			refreshFrameWithExecMode(<%= (int)ExecModeEnum.EXIT_MODE %>);
		}
		
		// ���������� ��������� �������� ����������� ������        
		function frameContent_onload()
		{ 
			var oDoc = GetFrameDocument(oFrame);
			if (!oDoc || oDoc.location == "about:blank")
				return;
			
			var sStatus = oDoc.documentElement.getAttribute("reportStatus");
			if (!sStatus)
				showFrame();    // ��� ������ ��������. ������, ��� ��� ����� ��� ��������� �� ������

			else if (sStatus == "<%= INVALID_COMMAND %>")
				// ���������� �������. ���������� ��� ����������� ������� ����� ��������.���� ������ �������� ��� ��������
				window.location.reload(true);

			else if (sStatus != "<%= XCommandStatusEnum.OK.ToString() %>" &&
					 sStatus != "<%= XCommandStatusEnum.FAIL.ToString() %>")
				window.setTimeout("refreshFrame()", iSecsDelay * 1000);     // ������������ ������ �� ��������� ��������

			else
			{
				// ������� �����������. ���� �������� ����������
				
				// ��������� �������� ������
				var oURLParams = new URLParams(document.URL);
				// �������� ���������, ���������� ����� POST
				var oFormPostData = new FormPostData();
				// ��������� ��������� ���������
				var sOutputFormat = oFormPostData.GetValue("<%= OUTPUTFORMAT_PARAM %>") || oURLParams.GetValue("<%= OUTPUTFORMAT_PARAM %>");

				// ������ �������
				var oElem = document.getElementById(sMasterPagePrefix + "xPaneProcessMessage");
				if (oElem)
					oElem.innerHTML = "����� �����������";
				
				if (sStatus == "<%= XCommandStatusEnum.FAIL.ToString() %>")
				{
					// ���� ����� �� ������������� �������, �� ��������� �� �����.
					refreshFrameWithExecMode(<%= (int)ExecModeEnum.SYNC_MODE %>);                     
				}
				else if (sOutputFormat && sOutputFormat.toUpperCase() != "HTML")
				{
					// ���� ��� �� ����, �� ��������� �� �����.
					// � ���� ���������, ����� ����� ������ ���� ��������
					refreshFrameWithExecMode(<%= (int)ExecModeEnum.SYNC_MODE %>);
					window.setTimeout("checkAttachmentBeforeClose()", iSecsDelay * 1000);
				}
				else
				{
					// ��� ����, ��������� �� ���� (���� ������� �� �����, �� ������ �� ��������!)
					
					// ����� POST �������� ������������� ������� (����� �� ������� � �������� ������)
					oFormPostData.SetValue("<%= REPORT_CMDID_PARAM %>", sReportCmdID);
					// ���� �����: ����� POST �������� ���������� ����� ��� ��������� ��������, 
					// � � �������� ������ ������ ����������� �����. �������� ��-�� ���������� POST ��� �������
					oFormPostData.SetValue("<%= EXECMODE_PARAM %>", <%= (int)ExecModeEnum.SYNC_MODE %>);
					oURLParams.SetValue("<%= EXECMODE_PARAM %>", <%= (int)ExecModeEnum.ASYNC_MODE %>);
					oFormPostData.Submit(window, oURLParams.toString(), "_top");
				}
				
				// ������� ������������� �������, ��� ��� ������ �� �������� ��� �� ���� �������� �� ���� ������
				sReportCmdID = "";
			}
		}
		
		// ������������ ������ ��� ���������� ��������� ������������ ������
		function refreshFrame()
		{
			refreshFrameWithExecMode(<%= (int)ExecModeEnum.ASYNC_MODE %>);
		}

		// ������������ ������ � ������������ ������� ���������� ������
		function refreshFrameWithExecMode(nExecMode)
		{
			if (!sReportCmdID)
				return;
			var tm = (new Date()).getTime();             // ������������� ���, ����� ���������� � ��������
			var sURL = sRefreshURL + "?<%= REPORT_CMDID_PARAM %>=" + sReportCmdID +
					   "&<%= EXECMODE_PARAM %>=" + nExecMode + "&tm=" + tm.toString();
			var oDoc = GetFrameDocument(oFrame);
			if (oDoc)
				oDoc.location.replace(sURL);
		}
				
		// ������� ��������� �������� ��������� (��� IE). ����� ���� ��������� ���� �������� (��� ����)
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
		
		// ���������� ���������� ������
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

    <!-- �����, � ������� ����������� ���������� ������������ ������.
         ��, ��� � ������ ����� �� ����� �������� SRC - ���������!
         ���� � ���, ��� ���� ����� ������ �������� � ���������� (����� - ����),
         �� ����������� ������� �� ��������/�������� ���� �� �����������!
    -->
    <iframe id="frameContent" onload="javascript:frameContent_onload()" 
        width="100%" height="100%" frameborder="0" style="width: 100%; height: 100%; display: none;">
    </iframe>
</asp:Content>
