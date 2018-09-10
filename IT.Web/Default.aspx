<%@ Page Language="C#" 
AutoEventWireup="true" 
MasterPageFile="~/xu-default.master"
Inherits="Croc.XmlFramework.Web.DefaultPage" Codebehind="Default.aspx.cs" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" Runat="Server">
 <SCRIPT LANGUAGE="VBScript" TYPE="text/VBScript">
	Option Explicit
	
	Const MANAGE_USER_SUBSCRIPTION = "<%=Server.UrlEncode( Request.QueryString["ManageUserSubscription"])%>"
	
	Sub Window_OnLoad
		If 0<>Len(MANAGE_USER_SUBSCRIPTION) Then
			X_WaitForTrue "OpenUserEventTypeSubscriptionEditorEx SafeCLng(MANAGE_USER_SUBSCRIPTION)" , "X_IsDocumentReady( null)"
		End If
	End Sub
	
	'Init
	
	' ���������� ������� ����� �� ������ "��������� ������������"
	' �������� �������� ������� �������� ������������; ������������� ������� ����� 
	' ��� �������� ����������� �������� UserProfileID, ���������� ��� ������ ������
	' (����������� � codebehind)
	Sub OpenUserProfileEditor()
		Dim oResponse			' ��������� �������� GetCurrentUserProfile; ��������� XGetObjectResponse
		Dim oObject				' XML-������ ������� UserProfile
		Dim oObjectEditorDialog	' ��������������� �����, ������������� ������ ��������� � ������� (��. x-utils.vbs)
		Dim vEditSettingsResult	' ��������� �������������� ��������
		
		' ��������� ����������� ������� ������ (� ��� ������ �� ������)
		window.event.returnValue = False
		window.event.cancelBubble = True
		
		' ������� XML-������ ������� ����������������� ������� (�����. �������� ������������)
		With New XRequest
		    .m_sName = "GetCurrentUserProfile"
		    Set oResponse = X_ExecuteCommand( .Self )
	    End With
		Set oObject = oResponse.m_oXmlObject
		
		' �������������� ����� ������������ � � ��� ������� ��������� ������ ��������� �������
		Set oObjectEditorDialog = new ObjectEditorDialogClass
		Set oObjectEditorDialog.XmlObject = oObject
		oObjectEditorDialog.IsAggregation = False
		oObjectEditorDialog.IsNewObject = hasValue(oObject.getAttribute("new"))
		vEditSettingsResult = ObjectEditorDialogClass_Show(oObjectEditorDialog)
		
		' ���� ��������� ���������� - ����� ������ � ������������ ��������:
		If hasValue(vEditSettingsResult) Then
			' TODO! TODO! ���� ������ UserNavigationInfo � ������ �� �����������
			' (��. UserNavigationInfoWrapper); �� ��� ������ ��� ����� ������� - 
			' ����� ���� ��������� �����-�� ��� ���������� ������ � ������ (���
			' �������� ������) ASP .NET
			
			' ...����������� ��������������� � ������� (������� - true):
			window.location.reload true
		End If
	End Sub 
	</SCRIPT>
	<STYLE>
		a		{ color: #036; background-color: auto; margin: 3px; text-decoration: none; }
		a:hover	{ color: #036; background-color: #f7df80; }
	</STYLE>
    <TABLE ID="xLayoutGrid" CELLPADDING="0" CELLSPACING="0" CLASS="x-page-layoutgrid x-page-layoutgrid">
	<TBODY>
		<TR>
			<!-- ������ ���������� ������ ��������� �������� -->
			<TD ID="xPaneMain" CLASS="x-pane x-pane-main x-homepage-pane x-homepage-pane-main" STYLE="background-color:#fff;">
			
				<TABLE CELLPADDING="0" CELLSPACING="0" STYLE="width:100%; height:100%;" STYLE="margin-top:10px;">
				<TR>
					<TD STYLE="position:relative; width:50%; height:100%; padding:10px;">
						<div style="overflow:auto;width:100%;height:100%;">
						<DL>
						<% if ( null!=m_UserInfo ) { %>
						<DT>������������</DT>
						<DD><a href="#" language="VBScript" onclick="X_OpenReport XService.BaseUrl &amp; &quot;nsi-redirect.aspx?OT=SystemUser&FROM=0AEFC1FD-4D42-4AAC-8369-76E5A812EFF3&COMMAND=CARD&ID=<%=m_UserInfo["EmployeeID"]%>&quot;"><%=Server.HtmlEncode((string)m_UserInfo["FIO"])%></a></DD>
						<% 
							object oEMail = m_UserInfo["EMail"];
							if (null!=oEMail && String.Empty!=oEMail && System.DBNull.Value!=oEMail) 
							{
								oEMail = Server.HtmlEncode( oEMail.ToString() );
								Response.Write( "<DT>EMail</DT>" );
								Response.Write( "<DD><A HREF='mailto:" + oEMail + "'>" + oEMail + "</A></DD>" );
							}
						%>
						<% } %>
						<% if ( null!=m_UserInfo ) { %>
						<DT>��������� ����������</DT>
						<DD>
							<ul>
								<% if ( m_UserInfo["IsAdmin"].ToString()!="0" ) { %>
									<li><EM>�������������</EM></li>
								<% } %>
								<li>
								<%=Server.HtmlEncode(
                                            Croc.IncidentTracker.SystemPrivilegesItem.ToStringOfDescriptions(
                                                                                (Croc.IncidentTracker.SystemPrivileges)m_UserInfo["SystemPrivileges"]
										)
									).Replace( ",", "</li><li>" )
								%>
								</li>
							</ul>
						</DD>
						<% } %>
						<% if ( null != m_FolderRolesAndPrivileges && m_FolderRolesAndPrivileges.Rows.Count > 0 ) { %>
						<DT>������� � ��������</DT>
						<DD>
						<%
							System.Guid prevFolderID = System.Guid.Empty;
							int nPriveledges = 0;
							foreach(System.Data.DataRow row in m_FolderRolesAndPrivileges.Rows )
							{
								if( prevFolderID!=(System.Guid)row["FolderID"] )
								{
									if(prevFolderID!=System.Guid.Empty)
									{
										if(0!=nPriveledges)
										{
											Response.Write("</ul>");
											Response.Write("</li>");
											Response.Write("<li>������ ����������<ul><li>");
											Response.Write(
                                                Server.HtmlEncode(Croc.IncidentTracker.FolderPrivilegesItem.ToStringOfDescriptions((Croc.IncidentTracker.FolderPrivileges)nPriveledges)).Replace(",", "</li><li>"));
											Response.Write("</li>");
										}
										Response.Write("</ul>");
										Response.Write("</li>");
										Response.Write("</ul>");
										Response.Write("</li>");
										Response.Write("</ul>");
										nPriveledges = 0;	
									}
									prevFolderID = (System.Guid)row["FolderID"];
									Response.Write("<ul><li><a href=\"x-tree.aspx?METANAME=Main&LocateFolderByID=" +row["FolderID"] + "\">");
									Response.Write(Server.HtmlEncode((string)row["FolderPath"]));
									Response.Write("</a><ul><li>������ �����<ul>");
								}
								nPriveledges = nPriveledges | (int)row["Privileges"];
								Response.Write("<li>");
								Response.Write(Server.HtmlEncode((string)row["RoleName"]));
								Response.Write("</li>");
							}
							if(prevFolderID!=System.Guid.Empty)
							{
								
								if(0!=nPriveledges)
								{
									Response.Write("</ul>");
									Response.Write("</li>");
									Response.Write("<li>������ ����������<ul><li>");
									Response.Write(
                                        Server.HtmlEncode(Croc.IncidentTracker.FolderPrivilegesItem.ToStringOfDescriptions((Croc.IncidentTracker.FolderPrivileges)nPriveledges)).Replace(",", "</li><li>"));
									Response.Write("</li>");
								}
								Response.Write("</ul>");
								Response.Write("</li>");
								Response.Write("</ul>");
								Response.Write("</li>");
								Response.Write("</ul>");
							}
						%>
						</DD>
						<% } %>
						</DL>
						</div>						
					</TD>
								
					<TD STYLE="position:relative; width:2px; height:100%; overflow:hidden; background-color:#369;">
						<IMG SRC="Images/delimiter-vertical.gif" STYLE="width:2px; height:100%;"/>
					</TD>
			
					<TD STYLE="position:relative; width:50%; height:100%; padding:10px; vertical-align:top;">
						
						<TABLE CELLPADDING="0" CELLSPACING="0" STYLE="width:100%;">
						<COL STYLE=""/>
						<COL STYLE="width:100%;"/>
						<TBODY>
							<TR>
								<TD STYLE="padding:1px 5px 1px 5px;"><IMG SRC="Images/bullet-operation.gif"/></TD>
								<TD>
									<A HREF="#" LANGUAGE="VBScript" ONCLICK="OpenUserProfileEditor">���������������� ���������</A>
								</TD>
							</TR>
							<TR>
								<TD STYLE="padding:1px 5px 1px 5px;"><IMG SRC="Images/bullet-operation.gif"/></TD>
								<TD>
									<A HREF="#" LANGUAGE="VBScript" ONCLICK="OpenUserEventTypeSubscriptionEditor">�������� �� �������</A>
								</TD>
							</TR>
						</TBODY>
						</TABLE>
						
					</TD>
				</TR>
				</TABLE>
				
			</TD>
		</TR>
	</TBODY>
	</TABLE>
</asp:Content>

   
