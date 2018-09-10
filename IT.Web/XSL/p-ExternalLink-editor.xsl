<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	>

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>

<xsl:template match="ExternalLink">
	<CENTER>
		<!-- Основная таблица, в которой будут разложены св-ва объекта -->
		<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%" height="99%" style="height1:100%;">
			<COL WIDTH="30%"/>
			<COL WIDTH="70%"/>
			<COL STYLE="padding-left:3px;"/>
			<tbody>
				<xsl:for-each select="Name">
					<tr style="height:1px;">
						<td valign="top" class="x-editor-text x-editor-propcaption-notnull">Наименование:</td>
						<td  colspan="2"><xsl:call-template name="std-template-string"/></td>
					</tr>
				</xsl:for-each>
				<xsl:for-each select="URI">
					<tr style="height:1%;">
						<td valign="top" class="x-editor-text x-editor-propcaption">Значение ссылки:</td>
						<xsl:choose>
							<xsl:when test="not(w:IsJustURL())">
								<td><xsl:call-template name="std-template-string"/></td>
								<TD>
									<BUTTON
										ID="LinkButton"
										CLASS="x-button x-editor-objectpresentation-button"
										language="VBScript"
										OnClick="btnGetDCTMLink_OnClick {d:UniqueID()}"
									>
										<SPAN STYLE="font-family:Verdana;">...</SPAN>
									</BUTTON>
								</TD>								
							</xsl:when>
							<xsl:otherwise>
								<td colspan="2"><xsl:call-template name="std-template-string"/></td>
							</xsl:otherwise>
						</xsl:choose>
					</tr>
				</xsl:for-each>
				<xsl:for-each select="Description">
					<tr style="height:100%;">
						<td valign="top" class="x-editor-text x-editor-propcaption-notnull">Описание:</td>
						<td  colspan="2">
							<xsl:call-template name="std-template-text">
								<xsl:with-param name="height" select="'100%'" />
							</xsl:call-template>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>				
		</TABLE>
	</CENTER>
</xsl:template>

<!-- Стандартный шаблон для отображения/модификации произвольных текстовых св-в -->
<xsl:include href="x-pe-string.xsl"/>

</xsl:stylesheet>

  