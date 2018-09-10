<%@ Page Language="c#" validateRequest="false" AutoEventWireup="false" %><%
/*
Страница перенаправления
*/
string s = Request.RawUrl;
string[] arr = s.Split(new char[]{'?'},2);
arr[0] = Session["NSI_REP"] + "nsi-redirect.asp";
s = string.Join("?",arr);
Response.Redirect(s, true);%>