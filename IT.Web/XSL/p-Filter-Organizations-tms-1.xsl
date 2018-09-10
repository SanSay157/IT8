<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	Первая страница для фильтра организаций в СУТ ("Основные параметры")
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="FilterTmsOrganizations">
		<table width="100%" cellspacing="2" cellpadding="0" class="x-layoutgrid x-filter-layoutgrid">
			<col width="20%"/>
			<col width="35%"/>
			<col width="45%"/>
			<tr>
				<td class="x-editor-text x-editor-propcaption"><nobr>Наименование (полное или краткое):</nobr></td>
				<!-- Наименование -->
				<td colspan="2">
					<xsl:for-each select="Name">
						<xsl:call-template name="std-template-string"/>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<!-- Участвует в тендерах -->
				<td colspan="3">
					<xsl:for-each select="OwnTenderParticipant">
						<xsl:call-template name="std-template-bool"/>
					</xsl:for-each>
				</td>
			</tr>
		</table>
	</xsl:template>
	<!-- Стандартный шаблон для отображения/модификации произвольных текстовых св-в -->
	<xsl:include href="x-pe-string.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
	<xsl:include href="x-pe-bool.xsl"/>
</xsl:stylesheet>
