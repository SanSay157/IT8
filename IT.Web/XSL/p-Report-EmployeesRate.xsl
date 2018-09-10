<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
	xmlns:b = "urn:x-page-builder"
	xmlns:w = "urn:editor-window-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:user = "urn:offcache"
>
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="FilterReportEmployeeRate">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<col width="10%"/>
			<col width="90%" height="100"/>
			<tr>
				<td />
				<td>
					<xsl:for-each select="PassDisabled">
						<xsl:call-template name="std-template-bool">
							<xsl:with-param name="label">Исключить временно нетрудоспособных сотрудников</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td />
				<td>
					<xsl:for-each select="PassRedundant">
						<xsl:call-template name="std-template-bool">
							<xsl:with-param name="label">Исключить уволенных сотрудников</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td />
				<td>
					<xsl:for-each select="ShowRestrictions">
						<xsl:call-template name="std-template-bool">
							<xsl:with-param name="label">Включить в отчет условия поиска</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
		</table>
	</xsl:template>
	<!-- Стандартный шаблон для отображения/модификации произвольных текстовых св-в -->
	<xsl:include href="x-pe-string.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации произвольных св-в  даты и времени-->
	<xsl:include href="x-pe-datetime.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
	<xsl:include href="x-pe-object.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
	<xsl:include href="x-pe-selector.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
	<xsl:include href="x-pe-bool.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации двоичных флагов св-в -->
	<xsl:include href="x-pe-flags.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
	<xsl:include href="x-pe-object.xsl"/>
	<!-- Стандартный шаблон для отображения /модификации массивных объектных св-в в виде дерева с чекбоксами -->
	<xsl:include href="x-pe-objects-tree-selector.xsl"/>
	<!-- Шаблон для отображения/модификации периода времени -->
</xsl:stylesheet>