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
	user:off-cache="1"
	>

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>

<xsl:template match="Incident">	
	<!-- Основная таблица, в которой будут разложены св-ва объекта -->
	<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%" height="100%">
		<COL />
		<COL width="100%" />
		<TBODY>
		<xsl:for-each select="virtual-prop-filter/FilterDKP/Mode">
			<TR>
				<TD>Режим:</TD>
				<TD>
					<xsl:call-template name="std-template-selector">
					</xsl:call-template>
				</TD>
			</TR>
		</xsl:for-each>
		<xsl:for-each select="virtual-prop-filter/FilterDKP/OrganizationName ">
			<TR>
				<TD><NOBR>Наименование организации:</NOBR></TD>
				<TD>
					<xsl:call-template name="std-template-string">
					</xsl:call-template>
				</TD>
			</TR>
		</xsl:for-each>
		<xsl:for-each select="virtual-prop-filter/FilterDKP/FolderName">
			<TR>
				<TD><NOBR>Наименование папки:</NOBR></TD>
				<TD>
					<xsl:call-template name="std-template-string"/>
				</TD>
			</TR>
		</xsl:for-each>
		<xsl:for-each select="virtual-prop-filter/FilterDKP/ActivityTypes">
			<TR>
				<TD><NOBR>Типы проектных затрат:</NOBR></TD>
				<TD>
					<xsl:call-template name="std-template-flags">
						<xsl:with-param name="horizontal-direction" select='1'/>
					</xsl:call-template>
				</TD>
			</TR>
		</xsl:for-each>
		<xsl:for-each select="virtual-prop-filter/FilterDKP/OnlyOwnActivity">
			<TR>
				<TD/>
				<TD>
					<xsl:call-template name="std-template-bool"/>
				</TD>
			</TR>
		</xsl:for-each>
		<xsl:for-each select="Folder">
			<TR>
				<TD valign="top" colspan="2" class="x-editor-text x-editor-propcaption">Папка:</TD>
			</TR>
			<TR>
				<TD height="100%" width="100%" colspan="2">
					<xsl:call-template name="std-template-object-tree-selector"/>
				</TD>
			</TR>
		</xsl:for-each>
		</TBODY>
	</TABLE>
</xsl:template>

<!--  -->
<xsl:include href="x-pe-object-tree-selector.xsl"/>
<xsl:include href="x-pe-selector.xsl"/>
<xsl:include href="x-pe-string.xsl"/>
<xsl:include href="x-pe-flags.xsl"/>
<xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
