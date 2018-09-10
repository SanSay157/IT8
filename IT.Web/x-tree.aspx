<%@ Page 
	Language="C#" 
	ValidateRequest="false" 
	AutoEventWireup="true" 
	
	MasterPageFile="~/xu-tree.master" 
	Inherits="Croc.XmlFramework.Web.XTreePage"
	
	EnableViewState="false"
	EnableSessionState="True" 
 Codebehind="x-tree.aspx.cs" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolderForFilter" Runat="Server">
	<asp:PlaceHolder ID="FilterPlaceHolder" runat="server"/>
</asp:Content>

<asp:Content ContentPlaceHolderID="ContentPlaceHolderForTree" Runat="Server">
	<div id="TreeHolder" style="position:relative; width:100%; height:100%;">
		<object 
			classid="<%= Croc.XmlFramework.Web.XConst.CLSID_TREE_VIEW %>" 
			id="oTreeView" 
			class="x-tree" 
			style="width:100%; height:100%;"
		>
			<param name="ReadyState" value="4"/>
			<param name="Enabled" value="-1"/>
			<param name="ShowExpandingSigns" value="-1"/>
			<param name="ShowLines" value="-1"/>
			<param name="AutoReloading" value="-1"/>
			<param name="IsOnlyLeafSel" value="0"/>
			<param name="IsMultipleSel" value="0"/>
			<param name="ShowBorder" value="0"/>
			<param name="DisableExpandAll" value="-1"/>
			<param name="AllowDragDrop" value="<%= AllowDragDrop ? -1 : 0 %>"/>
		</object>
		<script for="oTreeView" event="OnDataLoading( oSender,  nQuerySet,  sNodePath,  sObjectType,  sObjectID,  oRestrictions)" language="VBScript">
			TreeView_OnDataLoading oSender, nQuerySet, sNodePath, sObjectType, sObjectID, oRestrictions
		</script>
		<script for="oTreeView" event="OnDataLoaded( oSender, nQuerySet, sNodePath, sObjectType, sObjectID )" language="VBScript">
			TreeView_OnDataLoaded oSender, nQuerySet, sNodePath, sObjectType, sObjectID 
		</script>
		<script for="oTreeView" event="OnMouseUp(oSender, oTreeNode, nFlags)" language="VBScript">
			TreeView_OnMouseUp oSender, oTreeNode, nFlags
		</script>
		<script for="oTreeView" event="OnKeyUp(oSender, nKeyCode, nFlags)" language="VBScript">
			TreeView_OnKeyUp oSender, nKeyCode, nFlags
		</script>
		<script for="oTreeView" event="OnDblClick(oSender, oTreeNode)" language="VBScript">
			TreeView_OnDblClick oSender, oTreeNode
		</script>
		<script for="oTreeView" event="OnPathChange(oSender, oCurrent, oNew)" language="VBScript">
			TreeView_OnPathChange oSender, oCurrent, oNew
		</script>
		<script for="oTreeView" event="OnBeforeNodeDrag(oTreeView, oSourceNode, nKeyFlags, bCanDrag)" language="VBScript">
	        TreeView_OnBeforeNodeDrag oTreeView, oSourceNode, nKeyFlags, bCanDrag
		</script>
		<script for="oTreeView" event="OnNodeDrag(oTreeView, oSourceNode, nKeyFlags)" language="VBScript">
	        TreeView_OnNodeDrag oTreeView, oSourceNode, nKeyFlags
		</script>
		<script for="oTreeView" event="OnNodeDragOver(oTreeView, oSourceNode, oTargetNode, nKeyFlags, bCanDrog)" language="VBScript">
	        TreeView_OnNodeDragOver oTreeView, oSourceNode, oTargetNode, nKeyFlags, bCanDrog
		</script>
		<script for="oTreeView" event="OnNodeDragDrop(oTreeView, oSourceNode, oTargetNode, nKeyFlags)" language="VBScript">
	        TreeView_OnNodeDragDrop oTreeView, oSourceNode, oTargetNode, nKeyFlags
		</script>
		<script for="oTreeView" event="OnNodeDragCanceled(oTreeView, oSourceNode, nKeyFlags)" language="VBScript">
	        TreeView_OnNodeDragCanceled oTreeView, oSourceNode, nKeyFlags
		</script>
	</div>
</asp:Content>

<asp:Content ContentPlaceHolderID="ContentPlaceHolderForMenu" Runat="Server">
	<?import namespace="XFW" implementation="x-menu-html.htc"/?>
	<XFW:XMenuHtml
			ID="MenuHtml" language="VBScript" 
			SolidPageBorder="false" 
			Enabled="True" 
			style="width:100%; height:100%;"
		/>
</asp:Content>
