<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	2-я страница параметров отчета "Списания времени сотрудниками"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="FilterReportTimeLosses">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<col width="30%"/>
			<col width="70%"/>
			<tr>
				<td colspan="2">
					<xsl:for-each select="Departments">
						<xsl:call-template name="it-template-any-type-objects-tree-selector">
							<xsl:with-param name="prop-names">Organizations Departments Employees</xsl:with-param>
							<xsl:with-param name="height">300</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
		</table>
	</xsl:template>
	<!-- Стандартный шаблон для отображения /модификации массивных объектных св-в в виде дерева с чекбоксами -->
	<xsl:include href="x-pe-objects-tree-selector.xsl"/>
	<!-- Кастомный шаблон для отображения /модификации массивных объектных св-в в виде дерева с чекбоксами -->
	<xsl:include href="it-pe-any-type-objects-tree-selector.xsl"/>
</xsl:stylesheet>
