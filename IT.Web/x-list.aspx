<%@ Page 
	Language="C#" 
	ValidateRequest="false" 
	AutoEventWireup="true" 

	MasterPageFile="~/xu-list.master" 

	Inherits="Croc.XmlFramework.Web.XListPage"

	EnableViewState="false"
	EnableSessionState="True" 
 Codebehind="x-list.aspx.cs" %>
<asp:Content runat="server" ContentPlaceHolderID="ContentPlaceHolderForFilter" EnableViewState="false">
	<asp:PlaceHolder ID="FilterPlaceHolder" runat="server"/>
</asp:Content>
    
<asp:Content runat="server" ContentPlaceHolderID="ContentPlaceHolderForList" EnableViewState="false">

    <asp:PlaceHolder ID="ListDataPlaceHolder" runat="server">
	
		<!-- —трока сообщени€ об отсутствии данных -->
		<table runat="server" cellpadding="0" cellspacing="0" width="100%" height="100%">
			<tr runat="server">
			<td runat="server" id="NoDataMsg" oncontextmenu="TrackContextMenu()" language="VBScript" class="x-pane-main-message"></td>
			</tr>
			<tr runat="server">
			<td ID="ListHolder" runat="server" style="width:100%; height:100%;">
				<object id="List" classid="<%= Croc.XmlFramework.Web.XConst.CLSID_LIST_VIEW %>"
					width="100%" height="100%" border="0">
					<param name="Enabled" value="-1"/>
					<param name="ShowIcons" value="-1"/>
					<param name="LockHtmlKeyboardEvents" value="-1"></param>
				</object>
			</td>
			</tr>
		</table>
        
        <!-- In-place обработка событий компоненты списка -->
        <script for="List" event="OnRightClick(ByVal oSender, ByVal nIndex, ByVal nColumn, ByVal sID)" language="VBScript">
			TrackContextMenu()
        </script>

		<script for="List" event="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" language="VBScript">
			XListPage_OnKeyUp oSender, nKeyCode, nFlags
		</script>

		<script for="List" event="OnDblClick(ByVal oSender, ByVal nIndex, ByVal nColumn, ByVal sID)" language="VBScript">
			XListPage_OnDblClick oSender, nIndex, nColumn, sID
		</script>

		<script for="List" event="OnWidthChange(oDispSender, nColIndex, nWidth)" language="VBScript">
			XListPage_OnListWidthChange oDispSender, nColIndex, nWidth
		</script>

	</asp:PlaceHolder>

</asp:Content>
