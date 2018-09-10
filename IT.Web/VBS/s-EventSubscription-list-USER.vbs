Option Explicit

Dim g_bNotFirstLoad
Dim g_vEventCreationRule

'==============================================================================
' ���������������� ���������� ������� OnCreate
'	[in] oEventArg AS CommonEventArgsClass - ��������� �������
Sub usrXList_OnCreate( oXList, oEventArg )
	If Not IsNull(g_vEventCreationRule) Then
		oEventArg.Values.Item("URLPARAMS")=".EventCreationRule=" & g_vEventCreationRule
	End If
	stdXList_OnCreate oXList, oEventArg
End Sub

Sub CreateSubscription
	cmdNewSubscriptionRule.Disabled=True
	g_oXListPage.XList.OnKeyUp VK_INS, 0
	cmdNewSubscriptionRule.Disabled=False
End Sub

'###############################################################

Sub usrXListPage_OnLoad(oSender, oEventArgs)
	Dim sCaption  
	Dim oItem


	xPaneControl.style.display = "BLOCK"
	xCtrlPlace_cmdOK.style.display = "BLOCK"
	cmdOk.InnerText="������� �������"
	cmdOk.insertAdjacentHTML "beforeBegin", Replace(cmdOk.OuterHtml, "cmdOk", "cmdNewSubscriptionRule")
	cmdOk.style.display="NONE"
	cmdNewSubscriptionRule.disabled=False
	cmdNewSubscriptionRule.title="�������� ������ ������� ��������"
	Set cmdNewSubscriptionRule.onclick = GetRef("CreateSubscription")
	
	

	cmdCancel.InnerText = "�������"

	
	g_vEventCreationRule=oSender.QueryString.GetValue("EventCreationRule",Null)

	If Not IsNull(g_vEventCreationRule) Then	
		Set oItem = X_GetObjectFromServer("EventType",g_vEventCreationRule, Null )
		sCaption = ""
		sCaption = sCaption & "<DL style='color:#fff;font-size:10pt;'>"
		sCaption = sCaption & "<DT style='font-weight:bold'>������� ��������� �������� �� �������</DT>"
		sCaption = sCaption & "<DD>" & XService.HtmlEncodeLite(NameOf_EventClass(oItem.SelectSingleNode("EventType").NodeTypedValue)) & "</DD>"
		sCaption = sCaption & "<DT style='font-weight:bold'>������� ���������/�������� �������</DT>"
		sCaption = sCaption & "<DD>" & XService.HtmlEncodeLite(oItem.SelectSingleNode("Name").NodeTypedValue) & "</DD>"
		sCaption = sCaption & "</DL>"
		xPaneCaption.innerHtml = sCaption
	End If
End Sub

Sub usrXList_OnAfterListReload(oSender, oEventArgs)

	If g_bNotFirstLoad Then Exit Sub
	g_bNotFirstLoad = True
	If 0=oSender.ListView.Rows.Count Then
		'oSender.OnKeyUp VK_INS, 0
		CreateSubscription
	End If
End Sub

Sub stdXList_OnAccel(oXList, oAccelerationArgs)
	If VK_ESC = oAccelerationArgs.KeyCode Then
		cmdCancel_OnClick
	Else
		' ������� ������� ���������� � ���� ������ - ����� ��� ��� ��� ���������� hotkey'�
		oXList.Menu.ExecuteHotkey oXList, oAccelerationArgs
	End If
End Sub

Sub document_onkeyUp
	If window.event.keyCode = VK_ESC Then
		' ������ Escape � ������ ������
		cmdCancel_OnClick
	End If
End Sub

