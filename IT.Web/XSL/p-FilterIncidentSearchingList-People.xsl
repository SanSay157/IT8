<?xml version="1.0" encoding="windows-1251"?>
<!-- 
********************************************************************************
	Фильтр списка "Список инцидентов" (IncidentSearchingList). Закладка "Люди"
********************************************************************************
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
	xmlns:b = "urn:x-page-builder"
	xmlns:w = "urn:editor-window-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	xmlns:user = "urn:offcache"
	user:off-cache="1">

<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>

<xsl:template match="FilterIncidentSearchingList"> 
<TABLE CELLSPACING="2" CELLPADDING="0" CLASS="x-layoutgrid x-filter-layoutgrid" STYLE="width:100%; height:100%;">
	<TR>
		<TD  width="50%" class="x-editor-text x-editor-propcaption">Зарегистрировал:</TD>
		<TD  width="15%" class="x-editor-text x-editor-propcaption">Исполнитель:</TD>
		<TD width="35%">
			<xsl:for-each select="ExceptParticipants">
				<xsl:call-template name="std-template-bool" />
			</xsl:for-each>
		</TD>
	</TR>
	<TR>
		<TD width="50%" height="100%">
			<xsl:for-each select="Initiators">
				<xsl:call-template name="std-template-objects-tree-selector" >
				</xsl:call-template>
			</xsl:for-each>
		</TD>
		<TD COLSPAN="2" width="50%" height="100%">
			<xsl:for-each select="Participants">
				<xsl:call-template name="std-template-objects-tree-selector" >
				</xsl:call-template>
			</xsl:for-each>
		</TD>
	</TR>
</TABLE>
</xsl:template>

<xsl:include href="x-pe-objects-tree-selector.xsl"/>
<xsl:include href="x-pe-bool.xsl"/>
</xsl:stylesheet>