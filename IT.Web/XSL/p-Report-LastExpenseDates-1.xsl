<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	2-я страница параметров отчета "Список активностей"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="FilterReportLastExpenseDates">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<col width="30%" />
			<col width="70%" />
			<tr>
				<td  colspan="2">
					<!-- Кнопка вызова диалога фильтра -->
					<BUTTON 
						ID="btnOpenFilterOfFoldersTree" onClick="btnOpenFilterOfFoldersTree_onClick" language="VBScript" 
						CLASS="x-button x-control-button"
						STYLE="width:50px; padding:0px 5px 1px 5px; border:#777 solid 1px; font:bold 9px; color:#393; margin-right:3px;"
					><CENTER>Настроить...</CENTER></BUTTON>
					<!-- Кнопка очистки фильтра -->
					<BUTTON 
						ID="btnClearFilterOfFoldersTree" onClick="btnClearFilterOfFoldersTree_onClick" language="VBScript" 
						CLASS="x-button x-control-button"
						STYLE="width:50px; padding:0px 5px 1px 5px; border:#777 solid 1px; font:bold 9px; color:#393;"
					><CENTER>Очистить фильтр</CENTER></BUTTON>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<xsl:for-each select="Folders">
						<xsl:call-template name="std-template-objects-tree-selector">
							<xsl:with-param name="height">230</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr><td/></tr>
			<tr>
				<td />
				<td>
					<xsl:for-each select="IncludeSubProjects">
						<xsl:call-template name="std-template-bool">
							<xsl:with-param name="label">Включать в проект затраты подпроектов</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
		</table>
	</xsl:template>
	<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
	<xsl:include href="x-pe-bool.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации двоичных флагов св-в -->
	<xsl:include href="x-pe-flags.xsl"/>
	<!-- Стандартный шаблон для отображения /модификации массивных объектных св-в в виде дерева с чекбоксами -->
	<xsl:include href="x-pe-objects-tree-selector.xsl"/>
</xsl:stylesheet>
