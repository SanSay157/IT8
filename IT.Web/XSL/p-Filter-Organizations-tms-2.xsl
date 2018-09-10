<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	Первая страница для фильтра организаций в СУТ ("Основные параметры")
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="FilterTmsOrganizations">
		<table width="100%" cellspacing="0" cellpadding="0" class="x-layoutgrid x-filter-layoutgrid">
			<col width="13%"/>
			<col width="25%"/>
			<col width="2%"/>
			<col width="58%"/>
			<col width="2%"/>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Тип фильтрации:</td>
				<!-- Тип фильтрации по отрасли -->
				<td>
					<xsl:for-each select="BranchFilterType">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">radio</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
				<td/>
				<td id="tdBranch" style="visibility:hidden">
					<xsl:for-each select="Branch">
						<xsl:call-template name="std-template-objects-selector">
							<xsl:with-param name="list-metaname">BranchSelector</xsl:with-param>
							<xsl:with-param name="off-operations">1</xsl:with-param>
							<xsl:with-param name="height" select="'70px'"/>
						</xsl:call-template>
					</xsl:for-each>
				</td>
				<td/>
			</tr>
		</table>
	</xsl:template>
	<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
	<xsl:include href="x-pe-selector.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации произвольных массивных объектных св-в -->
	<xsl:include href="x-pe-objects.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации массивных объектных св-в в виде read-only списка -->
	<xsl:include href="x-pe-objects-selector.xsl"/>
</xsl:stylesheet>
