<%@ Page 
	Language="C#" 
	ValidateRequest="false" 
	AutoEventWireup="true" 

	MasterPageFile="~/xu-default.master" 

	Inherits="Croc.XmlFramework.Web.XReportsListPage"

	EnableViewState="false"
	EnableSessionState="True" 
 Codebehind="x-reports-list.aspx.cs" %>
<%@ Import Namespace='Croc.XmlFramework.ReportService.Commands' %>
<asp:Content ContentPlaceHolderID="ContentPlaceHolder" Runat="Server" EnableViewState="false">
	<div id="content" style="width: 100%; height: 100%; overflow: auto; padding: 5px;">
        <ul>
            <asp:Repeater ID="ReportsList" runat="server">
                <ItemTemplate>
                    <li>
                        <a 
                            href="x-get-report.aspx?name=<%# ((XGetReportsListResponse.ReportInfo)Container.DataItem).ProfileFileName %>" 
                            target="_blank">
                        <%# ((XGetReportsListResponse.ReportInfo)Container.DataItem).Title %>
                        </a>
                        &nbsp;
                        (<a 
                            href="x-get-report.aspx?execmode=1&name=<%# ((XGetReportsListResponse.ReportInfo)Container.DataItem).ProfileFileName %>" 
                            target="_blank">асинхронно</a>)
                    </li>
                </ItemTemplate>
            </asp:Repeater>
        </ul>
	</div>
</asp:Content>

