<HTML>
<HEAD>
<!--
�������� �������������� �������. ����������� ��� ��������� ������.
����� window.dialogArguments �������� ������ � 3 ����������:
	1 - ��������� �������� ������� � ������� � ���� ����� ���� long
	2 - ����������������� �������� ��� � �����
	3 - ��������� ��������
�������� ������� ������������ ����� window.returnValue � ���� ����� ���� double.
���� ������ ������ Cancel, ������������ NULL.
-->
<META http-equiv="Content-Type" content="text/html; charset=windows-1251">
<TITLE>��������� �������</TITLE>
<LINK href="x.css" rel="STYLESHEET" type="text/css">
<!-- ���������� ����������� ������ � ��������� -->
<SCRIPT Language="VBScript" type="text/vbscript" SRC="vbs/x-const.vbs"></SCRIPT>
<SCRIPT Language="VBScript" type="text/vbscript" SRC="vbs/x-utils.vbs"></SCRIPT>
<SCRIPT Language="VBScript" type="text/vbscript" SRC="vbs/it-const.vbs"></SCRIPT>
<SCRIPT Language="VBScript" type="text/vbscript" SRC="vbs/it-tools.vbs"></SCRIPT>
<SCRIPT LANGUAGE="VBScript">

Option Explicit

' ������� ��������� � ������� ���������� ��������
Const ITEM_TIME = 0			' ��������� �����
Const ITEM_HOURSINDAY = 1	' ���������� ����� � ���
Const ITEM_CAPTION = 2		' ���������
Const MINUTES_IN_HOUR = 60	' ����� ����� � ����

Dim g_nHoursInDay			' ���������� ����� � ���

Sub Minutes_OnChange
	oMinuteLabel.innerText = XService.GetUnitForm(CInt(Minutes.value), array("�����","������","������"))
End Sub

Sub Hours_OnChange
	oHourLabel.innerText = XService.GetUnitForm(CInt(Hours.value), array("�����","���","����"))
End Sub

Sub Days_OnChange
	oDayLabel.innerText = XService.GetUnitForm(CInt(Days.value), array("����","����","���"))
End Sub


'---------------------------------------------------------------
' �������������
Sub Init()
	Dim arrArgs			' ������ ���������� ��������
	Dim nTotalMinutes			' ��������� �������� ������� � �������
	Dim dblTimeInHours	' ��������� �������� ������� � �����
	Dim i
	Dim nRemainder
	Dim nHours
	Dim nMinutes
	Dim nDays
	
	X_SetDialogWindowReturnValue Null
	
	Const WAIT_MILLISEC = 10	' ����� �������� � ��
	X_GetDialogArguments arrArgs
	' ���������, ��� ��� ������� ������
	If Not IsArray( arrArgs) Then
		Alert "������������ �������� ����������� ����: ������ ���� ������� ������"
		Exit Sub
	End If
	' ��������� ����������� �������
	If 2 <> UBound(arrArgs) Then
		Alert "������������ �������� ����������� ����: ������ ���� ������� ������ �� 3 ���������"
		Exit Sub
	End If
	' �������� ���������
	nTotalMinutes = arrArgs( ITEM_TIME)
	g_nHoursInDay = arrArgs( ITEM_HOURSINDAY)
	idPageCaption.innerText = arrArgs( ITEM_CAPTION)
	If 0=InStr(1,idPageCaption.innerText, ":" ) Then idPageCaption.innerText = idPageCaption.innerText & ":" 
	
	' ��������� ���������� ������ �����
	idHours.innerHTML = ""
	For i = 0 To g_nHoursInDay-1
		X_AddComboBoxItem Hours, i, CStr(i)
	Next

	' ���������� ���������� �����	
	If nTotalMinutes > 0 Then
		dblTimeInHours = CDbl(nTotalMinutes/MINUTES_IN_HOUR)
		' ��������� ���������� ����� � ���������� ��������
		nDays = Int( dblTimeInHours / g_nHoursInDay)
		If nDays > 30 Then
			' ���� "����" ����� ����� �����, �� ������� ����������� �����
			X_AddComboBoxItem Days, nDays, CStr(nDays)
			setTimeout  "Days.value =" & nDays & " : Days_OnChange", WAIT_MILLISEC, "VBScript"
		Else
			Days.value = nDays
			Days_OnChange
		End If
		
		nHours = Int(dblTimeInHours) Mod g_nHoursInDay
		setTimeout  "Hours.value =" & nHours & " : Hours_OnChange", WAIT_MILLISEC, "VBScript"
		' �������� ����� ����� ����� ����� ��������� ������� ����� ����� �� ���������� ����� � ���� 
		' � ����������� �� ���������� ������
		nMinutes = Int((dblTimeInHours - Int(dblTimeInHours)) * MINUTES_IN_HOUR)
		nRemainder = nMinutes MOD 5
		If nRemainder < 3 Then
			Minutes.value = nMinutes - nRemainder
		Else
			Minutes.value = nMinutes + (5 - nRemainder)
		End If
		Minutes_OnChange
	Else
		Minutes_OnChange
		Hours_OnChange
		Days_OnChange
	End If
	cmdOK.disabled = false
End Sub


'---------------------------------------------------------------
' ��������� ������� �������
Sub document_onkeydown()
	select case window.event.keyCode
		case VK_ENTER 'Enter
			cmdOK_OnClick
			window.event.returnValue = false
		case VK_ESC 'Esc
			cmdCancel_OnClick
			window.event.returnValue = false
	end select
End sub

'---------------------------------------------------------------
' ���������� ������� OK
Sub cmdOK_OnClick()
	X_SetDialogWindowReturnValue (CLng(Days.value) * g_nHoursInDay + CLng(Hours.value))*MINUTES_IN_HOUR + CLng(Minutes.value) 
	window.close
End Sub

'---------------------------------------------------------------
' ���������� ������� Cancel
Sub cmdCancel_OnClick()
	X_SetDialogWindowReturnValue null
	window.close
End Sub

</SCRIPT>
</HEAD>

<BODY SCROLL=NO ONLOAD="Init()" LANGUAGE="VBS" bgcolor="Gray">
<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" WIDTH="100%" height="100%" class="x-editor-body">
	<TBODY>
		<TR>
			<TD ID="xPaneHeader" CLASS="x-pane-header" ONCONTEXTMENU="OnDebugEvent()">
				<TABLE ID="xCaptionBar" CLASS="x-header" CELLPADDING="0" CELLSPACING="0">
				<TBODY>
					<TR>
						<TD ID="idPageCaption" CLASS="x-header-title">�������� �����:</TD>
					</TR>
				</TBODY>
				</TABLE>
			</TD>
		</TR>
		<TR>
			<TD align="center" height="100%" CLASS="x-pane x-pane-main x-editor-pane x-editor-pane-main">
			<TABLE CELLPADDING="0" CELLSPACING="5" BORDER="0">
			<TR>
			<TD align="right" nowrap class="x-editor-text">
				<SELECT name="Days" style="width:50px;">
					<OPTION VALUE="0" SELECTED>0</OPTION>
					<OPTION VALUE="1">1</OPTION>
					<OPTION VALUE="2">2</OPTION>
					<OPTION VALUE="3">3</OPTION>
					<OPTION VALUE="4">4</OPTION>
					<OPTION VALUE="5">5</OPTION>
					<OPTION VALUE="6">6</OPTION>
					<OPTION VALUE="7">7</OPTION>
					<OPTION VALUE="8">8</OPTION>
					<OPTION VALUE="9">9</OPTION>
					<OPTION VALUE="10">10</OPTION>
					<OPTION VALUE="11">11</OPTION>
					<OPTION VALUE="12">12</OPTION>
					<OPTION VALUE="13">13</OPTION>
					<OPTION VALUE="14">14</OPTION>
					<OPTION VALUE="15">15</OPTION>
					<OPTION VALUE="16">16</OPTION>
					<OPTION VALUE="17">17</OPTION>
					<OPTION VALUE="18">18</OPTION>
					<OPTION VALUE="19">19</OPTION>
					<OPTION VALUE="20">20</OPTION>
					<OPTION VALUE="21">21</OPTION>
					<OPTION VALUE="22">22</OPTION>
					<OPTION VALUE="23">23</OPTION>
					<OPTION VALUE="24">24</OPTION>
					<OPTION VALUE="25">25</OPTION>
					<OPTION VALUE="26">26</OPTION>
					<OPTION VALUE="27">27</OPTION>
					<OPTION VALUE="28">28</OPTION>
					<OPTION VALUE="29">29</OPTION>
					<OPTION VALUE="30">30</OPTION>
				</SELECT> <span id="oDayLabel" style="width:40px;text-align:left;"></span>
			</TD>
			<TD align="center" nowrap class="x-editor-text">
				<SELECT name="Hours" id="idHours" style="width:50px;">
					<OPTION VALUE="20">20</OPTION>
				</SELECT> <span id="oHourLabel" style="width:40px;text-align:left;"></span>
			</TD>
			<TD align="left" nowrap class="x-editor-text">
				<SELECT name="Minutes" style="width:50px;">
					<OPTION VALUE="0" SELECTED>0</OPTION>
					<OPTION VALUE="5">5</OPTION>
					<OPTION VALUE="10">10</OPTION>
					<OPTION VALUE="15">15</OPTION>
					<OPTION VALUE="20">20</OPTION>
					<OPTION VALUE="25">25</OPTION>
					<OPTION VALUE="30">30</OPTION>
					<OPTION VALUE="35">35</OPTION>
					<OPTION VALUE="40">40</OPTION>
					<OPTION VALUE="45">45</OPTION>
					<OPTION VALUE="50">50</OPTION>
					<OPTION VALUE="55">55</OPTION>
				</SELECT> <span id="oMinuteLabel" style="width:40px;text-align:left;"></span>
			</TD>
			</TR>
			</TABLE>
			</TD>
		</TR>
		<TR>
			<TD ID="xPaneControl" CLASS="x-pane-control x-editor-pane-control">
				<TABLE ID="xBarControl" CLASS="x-controlbar" CELLSPACING="0" CELLPADDING="0">
				<TR>
					<TD align="center" class="x-editor-bottom" height="35px">
						<button name="cmdOK" CLASS="x-button-wide" style="margin-right: 10px;" disabled="1">OK</button>
						<button name="cmdCancel" CLASS="x-button-wide">������</button>
					</TD>
				</TR>
			</TD>
		</TR>
	</TBODY>
</TABLE>
</BODY>
	<!-- ���������� CROC.XClinetService : ������� ������� -->
	<OBJECT ID="XService" CLASSID="CLSID:31A948DA-9A04-4A95-8138-3B62E9AB92FC" STYLE="display:none" VIEWASTEXT>
		<PARAM NAME="AppIconURL" VALUE="icons/xu-application-icon.ico"/>		
	</OBJECT>
</HTML>
