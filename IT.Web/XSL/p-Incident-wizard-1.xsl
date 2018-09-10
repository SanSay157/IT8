<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	1-ый шаг мастера Инцидента (основные реквизиты)
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:user="urn:это_нужно_для_блока_msxsl:script"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	user:off-cache1="1"
	>

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>

<xsl:template match="Incident">
<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%" height="100%">
	<COL WIDTH="20%"/>
	<COL WIDTH="80%"/>
	<TBODY>
		<xsl:for-each select="Name">
			<tr>
				<td class="x-editor-text x-editor-propcaption-notnull">Наименование:</td>
				<td><xsl:call-template name="std-template-text"/></td>
			</tr>
		</xsl:for-each>
		<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
		<xsl:for-each select="Type">
			<TR>
				<TD class="x-editor-text x-editor-propcaption-notnull">Тип:</TD>
				<TD>
					<xsl:call-template name="std-template-object-dropdown">
						<xsl:with-param name="empty-value-text" select="'&lt;&lt;Выберите тип&gt;&gt;'"/>
						<xsl:with-param name="list-metaname" select="'AvailableIcidentTypesOfUserRole'"/>
					</xsl:call-template>
				</TD>
			</TR>
		</xsl:for-each>
		<xsl:for-each select="DeadLine">
			<TR>
				<TD class="x-editor-text x-editor-propcaption"><NOBR>Крайний срок:</NOBR></TD>
				<TD>
					<xsl:call-template name="std-template-date" />
				</TD>
			</TR>
		</xsl:for-each>
		<xsl:for-each select="Descr">
			<TR>
				<TD valign="top" class="x-editor-text x-editor-propcaption">Описание:</TD>
				<TD>
					<xsl:call-template name="std-template-text">
						<xsl:with-param name="minheight" select="80"/>
						<xsl:with-param name="maxheight" select="200"/>
					</xsl:call-template>
				</TD>
			</TR>
		</xsl:for-each>
		<xsl:for-each select="VirtualPropIncidentLinks">
			<TR><TD colspan="2" class="x-editor-text x-editor-propcaption" nowrap="nowrap">Связи:</TD></TR>
			<TR>
				<TD colspan="2" style="height:30%;">
					<xsl:call-template name="it-template-incident-links"/>
				</TD>
			</TR>
		</xsl:for-each>
		<xsl:for-each select="ExternalLinks">
			<TR><TD colspan="2" class="x-editor-text x-editor-propcaption" nowrap="nowrap">Внешние ссылки:</TD></TR>
			<TR>
				<TD colspan="2" style="height:30%;">
					<xsl:call-template name="std-template-objects" />
				</TD>
			</TR>
		</xsl:for-each>
		<TR><TD hight="100%"/></TR>
	</TBODY>
</TABLE>
</xsl:template>

<xsl:include href="x-pe-string.xsl"/>
<xsl:include href="x-pe-datetime.xsl"/>
<xsl:include href="x-pe-object.xsl"/>
<xsl:include href="x-pe-objects.xsl"/>
<xsl:include href="it-pe-incident-links.xsl"/>

</xsl:stylesheet>