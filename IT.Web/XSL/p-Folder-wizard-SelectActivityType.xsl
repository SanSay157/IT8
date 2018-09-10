<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	Первая страница мастера Папки для выбора типа проектных затрат
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

<xsl:template match="Folder">
<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%">
	<COL WIDTH="30%"/>
	<COL WIDTH="70%"/>
	<TBODY>
		<xsl:for-each select="ActivityType">
			<TR>
				<TD class="x-editor-text x-editor-propcaption-notnull">Тип проектных затрат:</TD>
				<TD>
					<xsl:call-template name="std-template-object-dropdown">
						<xsl:with-param name="empty-value-text" select="'&lt;&lt;Выберите тип&gt;&gt;'"/>
					</xsl:call-template>
				</TD>
			</TR>
		</xsl:for-each>
	</TBODY>
</TABLE>
</xsl:template>

<xsl:include href="x-pe-string.xsl"/>
<xsl:include href="x-pe-datetime.xsl"/>
<xsl:include href="x-pe-object.xsl"/>
<xsl:include href="x-pe-objects.xsl"/>
<xsl:include href="it-pe-incident-links.xsl"/>

</xsl:stylesheet>