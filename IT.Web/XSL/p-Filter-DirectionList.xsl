<?xml version="1.0" encoding="windows-1251"?>
<!-- 
	РЕДАКТОР ТИПА FilterDirectionList
	Фильтр списка "Направления"
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
	xmlns:d="urn:object-editor-access"
	xmlns:b = "urn:x-page-builder"
	xmlns:w = "urn:editor-window-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
>

<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>

<xsl:template match="FilterDirectionList"> 
	<TABLE CELLSPACING="0" CELLPADDING="0" STYLE="width:100%; height:100%;">
	<TR>
		<TD STYLE="width:100%; text-align:left; padding:2px 5px 3px 5px;">
			<xsl:for-each select="ShowObsolete">
				<xsl:call-template name="std-template-bool" />
			</xsl:for-each>
		</TD>
	</TR>
	</TABLE>
</xsl:template>

<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
<xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
  