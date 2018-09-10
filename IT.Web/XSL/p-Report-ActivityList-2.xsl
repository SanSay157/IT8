<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	3-я страница параметров отчета "Список активностей"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="FilterReportActivityList">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<tr>
				<td>
					<xsl:for-each select="NotAssignedRoles">
						<xsl:call-template name="std-template-objects-selector">
							<xsl:with-param name="list-metaname">Roles</xsl:with-param>
							<!--xsl:with-param name="off-operations">1</xsl:with-param-->
							<xsl:with-param name="height">300</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
		</table>
	</xsl:template>
	<!-- Стандартный шаблон для отображения/модификации массивных объектных св-в в виде read-only списка -->
	<xsl:include href="x-pe-objects-selector.xsl"/>
</xsl:stylesheet>
