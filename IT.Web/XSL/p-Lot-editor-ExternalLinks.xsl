<?xml version="1.0" encoding="windows-1251"?>
<!--
	===========================================================================
	Редактор лота – страница "Внешние ссылки"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">

	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>

	<xsl:template match="Lot" >
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<tr>
				<td>
					<xsl:for-each select="ExternalLinks">
						<xsl:call-template name="std-template-objects">
							<xsl:with-param name="height">430</xsl:with-param>
							<xsl:with-param name="off-select">1</xsl:with-param>
							<xsl:with-param name="off-unlink">1</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
		</table>
	</xsl:template>

	<!-- Стандартный шаблон для отображения/модификации произвольных массивных объектных св-в -->
	<xsl:include href="x-pe-objects.xsl"/>
</xsl:stylesheet>
