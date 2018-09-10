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
	xmlns:msxsl="urn:schemas-microsoft-com:xslt">

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>

<xsl:template match="*">
	<CENTER>
		<!-- Основная таблица, в которой будут разложены св-ва объекта -->
		<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%" style="table-layout1:fixed;">
			<COL WIDTH="10%"/>
			<COL WIDTH="90%"/>
			<TBODY>
				<xsl:for-each select="Priority">
					<tr>
						<xsl:call-template name="it-template-incident-priority"/>
					</tr>
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:for-each>
				<xsl:for-each select="Tasks">
					<TR style="height:100px;">
						<TD class="x-editor-text x-editor-propcaption" nowrap="nowrap" valign="top">Задания:</TD>
						<TD>
							<xsl:call-template name="std-template-objects"/>
						</TD>
					</TR>
				</xsl:for-each>
				<!-- выведем дополнительные свойства инцидента -->
				<xsl:call-template name="it-template-incident-props">
					<xsl:with-param name="props" select="Props"/>
					<xsl:with-param name="incident-type-props" select="Type/*/Props"/>
				</xsl:call-template>
			</TBODY>
		</TABLE>
	</CENTER>
</xsl:template>

<!-- шаблон для отображения дополнительных свойств инцидента -->
<xsl:import href="it-Incident-Props.xsl"/>

</xsl:stylesheet>
