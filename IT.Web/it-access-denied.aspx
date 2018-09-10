<%@ Page Language="c#" validateRequest="false" AutoEventWireup="false" %>
<HTML>
<HEAD>
	<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=windows-1251">
	<TITLE>Incident Tracker - В доступе отказано</TITLE>
	<LINK REL="SHORTCUT ICON" HREF="Icons/xu-application-icon.ico">
	<LINK HREF="x.css" REL="STYLESHEET" TYPE="text/css"/>
	<STYLE>
		BODY, TD {
			font-family: Verdana; 
			font-weight: normal;
			font-size: 11px;
			color: #357;
			cursor: default;
		}
		BODY { margin: 0px; }

		.head {
			height: 40px;
			margin: 0px 0px 10px 0px;
			color: #fff;
			background: url('Images/x-caption.jpg') repeat-x center right;
			background-color: #369;
			border: #F7AF00 groove 3px; 
			border-width: 0px 0px 3px 0px;
			filter: progid:DXImageTransform.Microsoft.Gradient(GradientType=1,StartColorStr='#99336699',EndColorStr='#00113355');
		}

		.head-pane-1 {
			text-align: left;
			vertical-align: middle;
			padding: 5px 250px 0px 10px;
			background: transparent;
		}
		.head-pane-2 {
			text-align: left;
			vertical-align: middle;
			padding: 5px 10px 5px 10px;
			font-size: 10px;
			color: #fff;
			background: transparent;
		}
		.head-title {
			position: absolute;
			top: 8px;
			left: 62px;
			font-family: Georgia;
			font-weight: bold;
			font-size: 28px;
			font-style: italic;
			color: #f5f7ff;
			filter: progid:DXImageTransform.Microsoft.Shadow( color=#001133, direction=135, strength=3 );
		}
		.head-subtitle {
			position: absolute;
			top: 40px;
			left: 62px;
			text-transform: uppercase; 
			font-family: Verdana;
			font-size: 8px;
			font-weight: bold;
			color: #036; 
		}
		.head-picture {
			position: absolute;
			top: 5px;
			left: 5px;
			z-index: 5;
		}
		
		.msg-title {
			text-align: center;
			font-family: Impact, Georgia;
			font-weight: normal;
			font-size: 31px;
			font-style: normal;
			color: #dd3311;
		}
		.msg-text {
			padding: 3px 0px 5px 0px;
			margin: 2px 0px 3px 0px;
			text-align: center;
			font-family: Verdana, Arial Cyr, Helvetica;
			font-weight: bold; 
			font-size: 12px;
			color: #dd3311;
			border: #dd3311 solid 2px; 
			border-width: 2px 0px 2px 0px;
		}
		.msg-footnote {
			color: #993311; 
			font-size: 11px; 
			text-align: center;		
		}
		.msg-footnote A {
			text-decoration: none;
			color: #993311;
			font-weight: bold;
		}
		.msg-footnote A:hover {
			text-decoration: underline;
			color: #AA3311;
			font-weight: bold;
		}
	</STYLE>
</HEAD>

<BODY SCROLL="NO">

	<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0" STYLE="width:100%; height:100%;">
	<TR>
		<TD>
		
		<!-- Заголовок: -->
		<TABLE CELLSPACING="0" CELLPADDING="0" CLASS="head" STYLE="width:100%;">
		<TBODY>
			<TR>
				<TD CLASS="head-pane-1" STYLE="position: relative; width:100%;">
					<DIV CLASS="head-title"><NOBR>Incident Tracker</NOBR></DIV>
					<DIV CLASS="head-subtitle"><NOBR>Система оперативного управления проектами</NOBR></DIV>
					<IMG CLASS="head-picture" SRC="Images/ApplicationSign.gif"/>
				</TD>
				<!-- TODO: По-хорошему, здесь надо выводить наименование компании-владелицы системы -->
				<TD CLASS="head-pane-2"><NOBR>Компания <A HREF="http://www.croc.ru" STYLE="color:#2D4;"><B>КРОК</B></A></NOBR></TD>
			</TR>
		</TBODY>
		</TABLE>

		</TD>
	</TR>
	<TR>
		<TD COLSPAN="2" STYLE="width:100%; height:100%; text-align:center; vertical-align:middle; background-color: #d4d0c8;">
		
		<!-- Основное тело: -->
		<TABLE CELLSPACING="0" CELLPADDING="0" STYLE="width:520px;">
		<TBODY>
			<TR>
				<TD STYLE="vertical-align:middle;"><IMG SRC="Images/no-access-sign.gif" STYLE="width:128px; height:128px;"/></TD>
				<TD STYLE="vertical-align:middle;">
					<DIV CLASS="msg-title">В ДОСТУПЕ ОТКАЗАНО</DIV>
					<DIV CLASS="msg-text">
						Причина: <% Response.Write( Server.UrlDecode(Request["reason"]) ); %>
					</DIV>
					<DIV CLASS="msg-footnote">
						По всем вопросам получения доступа в систему Incident Tracker обращайтесь, пожалуйста, в 
						<A HREF="mailto:HelpDesk@croc.ru" TITLE="Центральная Служба Технической Поддержки (ЦСТП): внутренний телефон 44-00, адрес электронной почты HelpDesk@croc.ru"
						>Центральную Службу Технической Поддержки</A> компании.
					</DIV>
				</TD>
			</TR>
		</TBODY>
		</TABLE>
		
		</TD>
	</TR>
	</TABLE>
	
</BODY>
</HTML>