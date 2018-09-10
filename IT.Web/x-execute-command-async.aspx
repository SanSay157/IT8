<%@ Page Language="C#" MasterPageFile="~/xu-execute-command-async.master" AutoEventWireup="true" Inherits="Croc.XmlFramework.Web.XUIPageWithMaster" %>
<script runat="server" language="C#">
	void Page_Load(object src, EventArgs ea)
	{
		onLoad("MainPage");
	}


	/// <summary>
	/// Признак запрета доступа к странице.
	/// </summary>                         
	protected override bool IsAccessDenied
	{
		get { return false; }
	}

	/// <summary>
	/// Заголовок страницы.
	/// </summary>         
	public override string PageTitle
	{
	
		get
		{
			string title = ("" + Request.QueryString["title"]).Trim();
			return string.IsNullOrEmpty(title)?"Выполнение операции...":title;
		}
	} 
	</script>
<asp:Content ID="Content1" ContentPlaceHolderID="ProgressPlaceHolder" Runat="Server">

	<%if(Request.QueryString["progress"]=="0"){%>
		<img src="images/x-execute-command-async.gif" alt="" />
	<%} else { %>
		<?import namespace="XFW" implementation="x-progress-bar.htc"/>
		<XFW:XProgressBar
			ID="ProgressObject" language="VBScript" 
			SolidPageBorder="false" 
			Enabled="False" 
			style="width:100%; height:24px;"
		/>		
	<%};%>
	
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StatePlaceHolder" Runat="Server">
	<span ID="objStatus">Запуск операции...</span>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="TimePlaceHolder" Runat="Server">
	<span ID="objTime"></span>
</asp:Content>
