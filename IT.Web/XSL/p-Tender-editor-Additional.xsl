<?xml version="1.0" encoding="windows-1251"?>
<!--
	===========================================================================
	Редактор однолотового тендера – страница "Дополнительно"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">

	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>

	<xsl:template match="Tender">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<col width="20%" />
			<col width="80%" />
      <!--tr>
				<td class="x-editor-text x-editor-propcaption">Источник информации</td>
				<td>
					<xsl:for-each select="InfoSource">
						<xsl:call-template name="std-template-object-presentation">
							<xsl:with-param name="select-symbol">dots</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr-->
			<tr><td colspan="2"><hr/></td></tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Данные для Заказчика</td>
				<td>
					<xsl:for-each select="QualifyingRequirement">
						<xsl:call-template name="std-template-text">
							<xsl:with-param name="minheight">80</xsl:with-param>
							<xsl:with-param name="maxheight">200</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Примечание</td>
				<td>
					<xsl:for-each select="Note">
						<xsl:call-template name="std-template-text">
							<xsl:with-param name="minheight">80</xsl:with-param>
							<xsl:with-param name="maxheight">200</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Обсуждения</td>
				<td>
					<xsl:for-each select="Discussion">
						<xsl:call-template name="std-template-text">
							<xsl:with-param name="minheight">80</xsl:with-param>
							<xsl:with-param name="maxheight">200</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
		</table>
	</xsl:template>

	<!-- Стандартный шаблон для отображения/модификации произвольных текстовых св-в -->
	<xsl:include href="x-pe-string.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
	<xsl:include href="x-pe-object.xsl"/>

</xsl:stylesheet>
