<%@ Page  validateRequest="false"  %>
<html>
<head>
<title>HTML DOM Navigator</title>
<script language="VBScript">
Option Explicit
Dim g_oRoot

Sub window_OnLoad
	window.setTimeout "Init", 100, "VBScript"
End Sub

Sub Init
	If Eval("IsObject(dialogArguments)") Then
		InitTree dialogArguments 
	Else
		InitTree document.documentElement 
	End If	
End Sub

Sub InitTree(oNode)
	Dim oTreeNode
	txtInnerHtml.value = ""
	Set g_oRoot = oNode
	g_oTreeView.Clear
	Set oTreeNode = g_oTreeView.Root.Add( "DomNode", oNode.uniqueID, oNode.TagName & " (" & TypeName(oNode) & ")", False)
	g_oTreeView.Path = oTreeNode.Path
End Sub

Function GetNodeByID(sID)
	Set GetNodeByID = g_oRoot.ownerDocument.all(sID)
End Function 

Sub g_oTreeView_OnExpand(oSender, oTreeNode)
	Dim oSubNode, oNode
	If 0 <> oTreeNode.Children.Count Then Exit Sub
	Set oNode = GetNodeByID(oTreeNode.ID)
	For Each oSubNode In oNode.children
		oTreeNode.Children.Add  "DomNode", oSubNode.uniqueID, oSubNode.TagName & " (" & TypeName(oSubNode) & ")", False
	Next
End Sub

Sub g_oTreeView_OnPathChange(pDispSender, pTreeNode_Previous, pTreeNode_Current)
	txtInnerHtml.value = GetNodeByID(pTreeNode_Current.ID).innerHtml
End Sub

Sub g_oSwitchWrap_OnClick
	If UCase(txtInnerHtml.wrap)="OFF" Then
		txtInnerHtml.wrap = "Soft"
	Else
		txtInnerHtml.wrap = "Off"
	End If
End Sub

Sub g_oMoveLeft_OnClick
	Dim nWidth
	nWidth = CLng(Trim(Replace(g_oTreeTD.width, "%","")))
	If nWidth < 10 Then Exit Sub
	g_oTreeTD.width = (nWidth-5) & "%"
End Sub

Sub g_oMoveRight_OnClick
	Dim nWidth
	nWidth = CLng(Trim(Replace(g_oTreeTD.width, "%","")))
	If nWidth > 90 Then Exit Sub
	g_oTreeTD.width = (nWidth+5) & "%"
End Sub

Sub g_oMaximize_OnClick
	On Error Resume Next
	window.dialogWidth = (window.screen.availWidth - 8 ) & "px"
	window.dialogHeight = (window.screen.availHeight - 8) & "px"
	window.dialogLeft = "4px"
	window.dialogTop = "4px"
End Sub

</script>
</head>
<body style="padding:0px;margin:0px;" scroll="no">
	<table border="1" cellpadding="0" cellspacing="0" style="width:100%;height:100%;">
	<tr>
		<td>
			<button id=g_oSwitchWrap>Wrap On/Off</button>
			<button id=g_oMoveLeft>&lt;&lt;&lt;</button>
			<button id=g_oMoveRight>&gt;&gt;&gt;</button>
			<button id=g_oMaximize>Maximize</button>
			
		</td>
	</tr>
	<tr>
		<td height="100%">
			<table border="0" cellpadding="0" cellspacing="0" style="width:100%;height:100%;">
				<tr>
					<td id=g_oTreeTD width="35%">
						<OBJECT 
							ID="g_oTreeView" 
							CLASSID="CLSID:4BB69C5B-87D1-4630-ABB5-34CE7AB57724"
							style="height:100%;width:100%;font-size:10px;font-family:verdana;background-color:#efefef"
							width="100%" height="100%" border="0" VIEWASTEXT>
							<PARAM NAME="ShowExpandingSigns" VALUE="-1">
							<PARAM NAME="ShowLines" VALUE="-1">
							<PARAM NAME="ShowBorder" VALUE="0">
							<PARAM NAME="AutoReloading" VALUE="0">
						</OBJECT>
					</td>
				<td><textarea  wrap="off" id="txtInnerHtml" readonly style="width:100%;height:100%;wrap:none;"></textarea></td>
				</tr> 
			</table>
		</td>	
	</tr>
</body>
</html>