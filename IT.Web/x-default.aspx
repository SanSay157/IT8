<%@ Page 
	Language="C#" 
	ValidateRequest="false" 
	AutoEventWireup="true" 
	
	MasterPageFile="~/xu-default.master" 

	Inherits="Croc.XmlFramework.Web.XDefaultPage"

	EnableViewState="false"
	EnableSessionState="True" 
 Codebehind="x-default.aspx.cs" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder" Runat="Server">

	<table width="100%" height="100%">
		<tr>
			<td class="x-controlbar-left-zone" nowrap>
				<button id="cmdResetSession" class="x-button-wide" title="��������� ���������� ����������"
					language="VBScript" onclick="X_ResetSession()">
					<b style="color: #e33;">�����������</b>
				</button>
				<button id="cmdClearCache" class="x-button-wide" title="������ ����� ���� (������, ������������, ����������, xsl)"
					language="VBScript" onclick="X_ClearCache()">
					<b style="color: #33e;">������ ����� ����</b>
				</button>
				<button id="cmdClearDataCache" class="x-button-wide" title="�������� �������������� ������"
					language="VBScript" onclick="X_ClearDataCache()">
					<b style="color: #33e;">����� ���� ������</b>
				</button>
				<button id="cmdClearViewStateCache" class="x-button-wide" title="�������� ���������������� �������� ������������� ����������"
					language="VBScript" onclick="X_ClearViewStateCache()">
					<b style="color: #33e;">�������� �������� �������������</b>
				</button>
			</td>
		</tr>
		<tr>
			<td width="100%" height="100%">
				<div id="content" style="width: 100%; height: 100%; overflow: auto; padding: 5px;">
					������
					<hr/>
					<asp:PlaceHolder ID="TypesListPlaceholder" runat="server"></asp:PlaceHolder>
					
					<asp:Panel ID="TreesPanel" runat="server">
					    ��������
					    <hr/>
					    <asp:BulletedList ID="TreesList" DisplayMode="HyperLink" runat="server"></asp:BulletedList>
					</asp:Panel>

					<asp:Panel ID="ReportsPanel" runat="server">
					    <hr/>
					    <asp:HyperLink ID="ReportsListLink" runat="server">������ �������</asp:HyperLink>
					</asp:Panel>
				</div>
			</td>
		</tr>
	</table>
</asp:Content>

