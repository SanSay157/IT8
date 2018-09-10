<%@ Page 
	Language="C#" 
	ValidateRequest="false" 
	AutoEventWireup="true" 

	MasterPageFile="~/xu-editor.master" 
	
	Inherits="Croc.XmlFramework.Web.XEditorPage" 
	
	EnableViewState="false"
	EnableSessionState="True" 
 Codebehind="x-editor.aspx.cs" %>
<%@ Register Src="~/x-menu-editor.htc.ascx" TagPrefix="xfw" TagName="menu" %>
<asp:Content ContentPlaceHolderID="ContentPlaceHolderForContent" runat="Server">
	<div id="x_editor_content_div" class="x-editor-body">
		<div id="StatusDiv">Загрузка...</div>
	</div>
</asp:Content>

<asp:Content ContentPlaceHolderID="ContentPlaceHolderForMenu" runat="server">
	<xfw:menu id="oMenuHTC" runat="server"></xfw:menu>
</asp:Content>