<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
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
	<!-- Основная таблица, в которой будут разложены св-ва объекта -->
	<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%" HEIGHT="100%">
		<TBODY>
			<xsl:for-each select="VirtualPropIncidentLinks">
				<TR><TD class="x-editor-text x-editor-propcaption" nowrap="nowrap">Связи:</TD></TR>
				<TR style="height:50%;">
					<TD >
						<xsl:call-template name="it-template-incident-links"/>
					</TD>
				</TR>
			</xsl:for-each>
			<xsl:for-each select="ExternalLinks">
				<TR><TD class="x-editor-text x-editor-propcaption" nowrap="nowrap">Внешние ссылки:</TD></TR>
				<TR style="height:50%;">
					<TD >
						<xsl:call-template name="std-template-objects" />
					</TD>
				</TR>
			</xsl:for-each>
		</TBODY>				
	</TABLE>
</xsl:template>

<!-- шаблон для отображения дополнительных свойств инцидента -->
<xsl:import href="x-pe-objects.xsl"/>
<xsl:include href="it-pe-incident-links.xsl"/>

</xsl:stylesheet>
