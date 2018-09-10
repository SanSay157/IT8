<%@ Import namespace="System"%>
<%@ Import namespace="System.Web"%>
<%@ Import namespace="System.Diagnostics"%>
<%@ Import namespace="Croc.IncidentTracker.Commands"%>
<%@ Import namespace="Croc.XmlFramework.Commands"%>
<%@ Import namespace="Croc.XmlFramework.Web"%>
<%@ Import namespace="Croc.XmlFramework.Core"%>
<%@ Import namespace="Croc.XmlFramework.Public"%>
<%@ Application Language="C#" %>

<script runat="server">
    
    /// <summary>
    /// Константное наименованание стартовой страницы (отслеживается)
    /// </summary>
    const string DEF_DEFAULT_PAGE = "default.aspx";
        
    void Application_Start(object sender, EventArgs e) 
    {
        // Code that runs on application startup

    }
    
    void Application_End(object sender, EventArgs e) 
    {
        //  Code that runs on application shutdown

    }
        
    void Application_Error(object sender, EventArgs e) 
    { 
        // Code that runs when an unhandled error occurs
        Response.Clear();
        Exception ex = Server.GetLastError();
        while (ex != null)
        {
            if (ex is XSecurityException)
                Server.Transfer("it-access-denied.aspx?reason=" + Server.UrlEncode(ex.Message));
            ex = ex.InnerException;
        }

    }

    void Session_Start(object sender, EventArgs e) 
    {
        // Code that runs when a new session is started
        // Формируем запрос на выполнение операции GetConfigElement - 
        // получение данных основного конфигурационного файла:
        // Передаем запрос на выполнение операции в Ядро
        Session["NSI_REP"] = ((XGetConfigElementResponse)XFacadeProxyHolder.ExecCommand(new XGetConfigElementRequest("it:app-data/it:services-location/it:service-location[@service-type='NSI-Rep']"))).ParameterElement.InnerText;
        Session["DocumentumWebTop"] = ((XGetConfigElementResponse) XFacadeProxyHolder.ExecCommand(new XGetConfigElementRequest("it:app-data/it:services-location/it:service-location[@service-type='DocumentumWebTop']"))).ParameterElement.InnerText;

        string sLastSegment = Request.Url.Segments[Request.Url.Segments.Length - 1].ToLower();
        if (DEF_DEFAULT_PAGE == sLastSegment && 0 == Request.QueryString.Count)
        {
            UserNavigationInfo navInfo = UserNavigationInfoWrapper.GetInstance(Session); 
            
                
            if (null != navInfo && 0 != navInfo.UsedNavigationItems.Count)
            {
               string sUrl = UserNavigationInfoWrapper.GetStartPageUrl(navInfo.OwnStartPage);
                if (!String.IsNullOrEmpty(sUrl) && navInfo.UseOwnStartPage)
                    Response.Redirect(sUrl, false);
                // Server.Transfer( item.NavigationUrl, true ); - NB! ПРИВОДИТ К ОШИБКЕ НА КЛИЕНТЕ!
            }
            //else
            // Нет доступа?.. 
            // TODO: Переделать на redirect на "свою" страницу с соотв. сообщением о запрете доступа
            // throw new HttpException( 404, "Доступ запрещен" );
              
        }

    }

    void Session_End(object sender, EventArgs e) 
    {
        // Code that runs when a session ends. 
        // Note: The Session_End event is raised only when the sessionstate mode
        // is set to InProc in the Web.config file. If session mode is set to StateServer 
        // or SQLServer, the event is not raised.
        try
        {
			XFacadeProxyHolder.StopSession(Session.SessionID);
        }
        catch(Exception ex)
        {
			Trace.WriteLine(ex);
        }
    }
       
</script>
