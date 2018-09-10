<%@ Page 
	Language="C#" 
	ValidateRequest="false"
	AutoEventWireup="true" 
	MasterPageFile="~/xu-select-from-tree.master" 
	Inherits="Croc.XmlFramework.Web.XSelectFromTreePage" 
	
	EnableViewState="false"
	EnableSessionState="True" 
 Codebehind="x-select-from-tree.aspx.cs" %>
<asp:Content ContentPlaceHolderID="ContentPlaceHolderForFilter" Runat="Server">
	<asp:PlaceHolder ID="FilterPlaceHolder" runat="server"/>
</asp:Content>

<asp:Content ContentPlaceHolderID="ContentPlaceHolderForTree" Runat="Server">
	<!-- —трока сообщени€ об отсутствии данных -->
	<table runat="server" cellpadding="0" cellspacing="0" width="100%" height="100%">
		<tr runat="server">
			<td runat="server" id="NoDataMsg" class="x-pane-main-message"></td>
		</tr>
		<tr runat="server">
			<td ID="TreeHolder" runat="server" style="width:100%; height:100%;">
				<object 
					classid="<%= Croc.XmlFramework.Web.XConst.CLSID_TREE_VIEW %>" 
					id="oTreeView" 
					class="x-tree-sel-selector" 
					style="width:100%; height:100%;"
				>
					<param name="Enabled" value="0"/>
					<param name="ShowExpandingSigns" value="-1"/>
					<param name="ShowLines" value="-1"/>
					<param name="AutoReloading" value="0"/>
					<param name="ShowBorder" value="0"/>
					<param name="DisableExpandAll" value="-1"/>
				</object>
				<script for="oTreeView" event="OnDblClick(oSender, oTreeNode)" language="VBScript">
					TreeView_OnDblClick oSender, oTreeNode
				</script>
				<script for="oTreeView" event="OnKeyPress(oSender, nKeyAscii)" language="VBScript">
					TreeView_OnKeyPress oSender, nKeyAscii
				</script>
				<script for="oTreeView" event="OnDataLoading( oSender,  nQuerySet,  sNodePath,  sObjectType,  sObjectID,  oRestrictions)" language="VBScript">
					TreeView_OnDataLoading oSender, nQuerySet, sNodePath, sObjectType, sObjectID, oRestrictions
				</script>
				<script for="oTreeView" event="OnDataLoaded( oSender, nQuerySet, sNodePath, sObjectType, sObjectID )" language="VBScript">
					TreeView_OnDataLoaded oSender, nQuerySet, sNodePath, sObjectType, sObjectID 
				</script>
			</td>
		</tr>
	</table>
</asp:Content>
