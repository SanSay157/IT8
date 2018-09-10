<?xml version="1.0" encoding="windows-1251"?>
<!-- 
********************************************************************************
	Страница мастера/редактора объекта "Настройки пользователя" (UserProfile)
********************************************************************************
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
	xmlns:b = "urn:x-page-builder"
	xmlns:w = "urn:editor-window-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	xmlns:user = "urn:offcache"
	user:off-cache="1"
>
<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
<xsl:template match="UserProfile"> 

	<TABLE CELLSPACING="0" CELLPADDING="1" STYLE="width:100%;">
		<COL STYLE="padding-right:5px;"/>
		<COL STYLE="width:100%;"/>
	<TBODY>
		<xsl:for-each select="SystemUser/SystemUser/Employee/Employee">
		<TR>
			<TD COLSPAN="2" CLASS="x-editor-text x-editor-propcaption" >
				<xsl:variable name="EmpFullName" select="concat( LastName, ', ', FirstName, ' ', MiddleName )"/>
				Настройки пользователя: <B><xsl:value-of select="$EmpFullName"/></B>
			</TD>
		</TR>
		</xsl:for-each>

		<TR><TD COLSPAN="2"><HR CLASS="x-editor-hr-1"/></TD></TR>
	
		<xsl:for-each select="StartPage">
		<TR>
			<TD CLASS="x-editor-text x-editor-propcaption" nowrap="nowrap">Стартовая страница:</TD>
			<TD>
				<xsl:call-template name="std-template-selector">
					<xsl:with-param name="empty-value-text">( не задано - страница данных и настроек пользователя )</xsl:with-param>
				</xsl:call-template>
			</TD>
		</TR>	
		</xsl:for-each>
	
		<TR><TD COLSPAN="2"><HR CLASS="x-editor-hr-1"/></TD></TR>
		
		<xsl:for-each select="ShowExpensesPanel">
		<TR>
			<TD COLSPAN="2" CLASS="x-editor-text x-editor-propcaption">
				<xsl:call-template name="std-template-bool">
					<xsl:with-param name="label">Отображать панель Списанного времени</xsl:with-param>
				</xsl:call-template>
			</TD>
		</TR>
		</xsl:for-each>
		
		<xsl:for-each select="ExpensesPanelAutoUpdateDelay">
		<TR>
			<TD COLSPAN="2" CLASS="x-editor-text x-editor-propcaption">
				<INPUT ID="inpAutoUpdateOn" TYPE="checkbox" LANGUAGE="VBScript" ONCLICK="AutoUpdateOn_OnChanged"/>
				<LABEL FOR="inpAutoUpdateOn">Автоматическое обновление данных панели,</LABEL>
				<LABEL>
				каждые 
				<xsl:call-template name="std-template-string">
					<xsl:with-param name="width">5em</xsl:with-param>
				</xsl:call-template>
				мин.
				</LABEL>
			</TD>
		</TR>
		</xsl:for-each>
		
	</TBODY>
	</TABLE>

</xsl:template>

<xsl:include href="x-pe-selector.xsl"/>
<xsl:include href="x-pe-string.xsl"/>
<xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
