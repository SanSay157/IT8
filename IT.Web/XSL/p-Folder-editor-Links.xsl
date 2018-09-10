<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:d="urn:object-editor-access"
>

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>

<xsl:template match="Folder">
	<CENTER>
		<!-- Основная таблица, в которой будут разложены св-ва объекта -->
		<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%" HEIGHT="100%">
			<COL WIDTH="30%"/>
			<COL WIDTH="70%"/>
			<tbody>
				<xsl:for-each select="ExternalLink">
					<tr>
						<td valign="top" class="x-editor-text x-editor-propcaption">Ссылка на внешний каталог:</td>
						<td  colspan="1">
							<xsl:call-template name="std-template-object">
								<xsl:with-param name="maybenull" select="number('1')" />
							</xsl:call-template>
						</td>
					</tr>
				</xsl:for-each>
				<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				<xsl:for-each select="ExternalLinks">
					<tr>
						<td valign="top" colspan="2" class="x-editor-text x-editor-propcaption">
							Внешние ссылки:
						</td>
					</tr>
					<tr>
						<td height="100%" width="100%" colspan="2">
							<xsl:call-template name="std-template-objects"/>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>				
		</TABLE>
	</CENTER>
</xsl:template>

<xsl:include href="x-pe-objects.xsl"/>
<xsl:include href="x-pe-object.xsl"/>
</xsl:stylesheet>

  