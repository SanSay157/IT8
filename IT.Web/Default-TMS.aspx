<%@ Page Language="C#" 
AutoEventWireup="true" 
MasterPageFile="~/xu-default-tms.master"
Inherits="Croc.XmlFramework.Web.DefaultPageTMS" Codebehind="Default-TMS.aspx.cs" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" Runat="Server">
<!-- локальный скрипт -->
	<SCRIPT LANGUAGE="VBscript">
	
	Option Explicit
	
	' Обработчик события клика по ссылке (анкер А), по которой должен вызываться 
	' отчет. Тип вызываемого отчета определяется по идентификатору анкера, 
	' сгенерировавшего событие
	Sub DoOpenReport()
		' Обрабатываем клик как вызов отчета, если выполняются следующие условия:
		'	- элемент - источник события есть анкер (тег А)
		'	- у элемента задан идентификатор
		' Во всех остальных случаях ничего не делаем
		If Not hasValue(window.event) Then Exit Sub
		If Not hasValue(window.event.srcElement) Then Exit Sub
		If ( "A" <> UCase(window.event.srcElement.tagName) ) Then Exit Sub
		If Not hasValue(window.event.srcElement.ID) Then Exit Sub

		' В этом случае стандартная логика обработки события - блокируется;
		window.event.returnValue = false
		window.event.cancelBubble = true
		
		' Вызов конкретного отчета зависит от идентификатора анкера:
		Select Case CStr(window.event.srcElement.ID)
		
			Case "refReport_LotsAndParticipants"
				On Error Resume Next
				X_RunReport "LotsAndParticipants", Empty
				If Err Then
					MsgBox Err.Description
				End If
			Case "refReport_Tenders"
				On Error Resume Next
				X_RunReport "Tenders", Empty
				If Err Then
					MsgBox Err.Description
				End If							
			' TODO: ОТЛАДОЧНАЯ ВЕРСИЯ - ЭТОТ КОД ДОЛЖЕН БЫТЬ ПЕРЕПИСАН!
			Case Else
				MsgBox window.event.srcElement.ID
		
		End Select
		
	End Sub
		
	</SCRIPT>
<TABLE ID="xLayoutGrid" CELLPADDING="0" CELLSPACING="0" CLASS="x-page-layoutgrid">
	<TBODY>
		<TR>
			<!-- *************************************************************** -->
			<!-- ПАНЕЛЬ "ИСТОРИЧЕСКОЙ" СТАРТОВОЙ СТРАНИЦЫ СУТ -->
			<TD ID="xPaneMain" CLASS="x-pane x-pane-main" 
				STYLE="position:relative; width:100%; height:100%; "
				STYLE="background:url('Images/tms-Background.gif'); background-color:#4A6C60; "
				STYLE="vertical-align:top; text-align:center; padding:0px;"
			>
			<DIV 
				STYLE="position:relative; width:100%; height:100%; overflow:auto; "
				STYLE="border:#fff inset 2px; padding:5px;"
			>
			<!-- Заголовок -->
			<TABLE 
				CELLPADDING="0" CELLSPACING="0" 
				STYLE="width:655px; height:232px; overflow:hidden;"
				STYLE="border:#ff9033 solid 2px; "
			>
				<TR>
					<TD WIDTH="488" HEIGHT="147" COLSPAN="2"><IMG SRC="Images/tms-header-topleft.gif" WIDTH="488" HEIGHT="147"></TD>
					<TD WIDTH="167" HEIGHT="147"><IMG SRC="Images/tms-header-topright.gif" WIDTH="167" HEIGHT="147"></TD>
				</TR>
				<TR>
					<TD WIDTH="363" HEIGHT="85" STYLE="vertical-align:bottom;">
						<IMG SRC="Images/tms-header-left.jpg" WIDTH="363" HEIGHT="85">
					</TD>
					<TD WIDTH="125" HEIGHT="85" STYLE="vertical-align:top;">
						<IMG NAME="menu11" SRC="Images/tms-header-lots.jpg" WIDTH="125" HEIGHT="85"/>
					</TD>
					<TD WIDTH="167" HEIGHT="85" STYLE="vertical-align:top;">
						<A HREF="x-list.aspx?HOME=&RET=&OT=Tender&METANAME=TendersList"><IMG NAME="menu0" SRC="Images/tms-header-tenders.jpg" WIDTH="167" HEIGHT="85"/></A>
					</TD>
				</TR>
				<TR>
					<TD COLSPAN="3" CLASS="tms-main-pane">
					
						<TABLE ID="tmsNavPane" STYLE="width:655px; overflow:hidden;">
						<COL STYLE="width:45%; padding-rigth:5px;"/>
						<COL STYLE="width:45%; padding-left:5px;"/>
						
						<!-- Секция СПРАВОЧНИКИ -->
							<TR>
								<TD CLASS="tms-nav-title" COLSPAN="2">Справочники</TD>
							</TR>
							<TR>
								<TD CLASS="tms-nav-item">
									<A	CLASS="tms-nav-item-anchor"
										HREF="x-list.aspx?HOME=&RET=&OT=Organization&METANAME=TmsOrganizations"
										TARGET="_self"
									>Организации</A>
								</TD>
								<TD CLASS="tms-nav-item">
									<A	CLASS="tms-nav-item-anchor"
										HREF="x-list.aspx?HOME=&RET=&OT=Branch"
										TARGET="_self"
									>Отрасли</A>
								</TD>
							</TR>
							<TR>
                            	<TD CLASS="tms-nav-item">
									<A	CLASS="tms-nav-item-anchor"
										HREF="x-list.aspx?HOME=&RET=&OT=LossReason"
										TARGET="_self"
									>Причины проигрыша</A>
								</TD>
								<TD CLASS="tms-nav-item">
									<A	CLASS="tms-nav-item-anchor"
										HREF="x-list.aspx?HOME=&RET=&OT=Currency"
										TARGET="_self"
									>Валюты</A>
								</TD>
							</TR>
						
						<!-- Секция ОТЧЕТЫ-
							<TR>
								<TD CLASS="tms-nav-title" COLSPAN="2">Отчеты</TD>
							</TR>
							<TR>
								<TD CLASS="tms-nav-item">
									<A	CLASS="tms-nav-item-anchor"
										HREF = ""
										TARGET = "_self"
										LANGUAGE = "VBScript"
										ID = "refReport_LotsAndParticipants"
										ONCLICK = "DoOpenReport()"
									>Лоты и участники конкурсов</A>
								</TD>
								<TD CLASS="tms-nav-item">
									<A	CLASS="tms-nav-item-anchor"
										HREF = ""
										TARGET = "_self"
										LANGUAGE = "VBScript"
										ID = "refReport_Tenders"
										ONCLICK = "DoOpenReport()"
									>Тендеры</A>
								</TD>
							</TR-->					
							<TR>
								<TD COLSPAN="2" STYLE="height:50px;">&nbsp;</TD>
							</TR>
						</TABLE>
					</TD>
				</TR>
				<TR>
					<TD COLSPAN="3" CLASS="tms-footer-pane">
						<IMG SRC="Images/tms-footer.gif"/>
                        </DIV>
						<DIV><A HREF="http://www.elgascom.ru" TITLE="Электрогазовая компания">Электрогазовая компания</A>, 2001 - 2013</DIV>
					</TD>
				</TR>
			</TABLE>						
			</DIV>
			</TD>
		</TR>
	</TBODY>
	</TABLE>
</asp:Content>