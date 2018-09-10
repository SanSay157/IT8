<?xml version="1.0" encoding="windows-1251"?>
<!-- 
********************************************************************************
	Фильтр списка "Список инцидентов" (IncidentSearchingList) - Закладка "Проекты"
********************************************************************************
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
	xmlns:b = "urn:x-page-builder"
	xmlns:w = "urn:editor-window-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	xmlns:user = "urn:offcache"
	user:off-cache="1"
	>

<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>

<xsl:template match="FilterIncidentSearchingList"> 
<TABLE CELLSPACING="2" CELLPADDING="0" CLASS="x-layoutgrid x-filter-layoutgrid" STYLE="width:100%; height:100%;">
	<TR>
		<!-- Дерево с папками -->
		<TD ROWSPAN="4" width="60%" height="100%" style="padding-right:5px">
			<xsl:for-each select="Folders">
				<xsl:call-template name="std-template-objects-tree-selector" >
				</xsl:call-template>
			</xsl:for-each>
		</TD>
		<TD>
			<!-- Кнопка вызова диалога фильтра -->
			<BUTTON 
				ID="btnOpenFilterOfFoldersTree" onClick="btnOpenFilterOfFoldersTree_onClick" language="VBScript" 
				CLASS="x-button x-control-button"
				STYLE="width:150px; height: 30px; padding:0px 5px 1px 5px; border:#777 solid 1px; font:bold 9px; color:#393;"
			><CENTER>Настроить...</CENTER></BUTTON>
		</TD>
	</TR>
	<TR>
		<TD>
			<!-- Кнопка вызова диалога фильтра -->
			<BUTTON 
				ID="btnClearFilterOfFoldersTree" onClick="btnClearFilterOfFoldersTree_onClick" language="VBScript" 
				CLASS="x-button x-control-button"
				STYLE="width:150px; height: 30px; padding:0px 5px 1px 5px; border:#777 solid 1px; font:bold 9px; color:#393;"
			><CENTER>Очистить</CENTER></BUTTON>
		</TD>
	</TR>
	<TR>
		<TD style="padding-right:15px;">
			<xsl:for-each select="RecursiveFolderSearch">
				<xsl:call-template name="std-template-bool" />
			</xsl:for-each>
		</TD>
	</TR>
	<TR>
		<TD height="100%"/>
	</TR>
</TABLE>
</xsl:template>

<xsl:include href="x-pe-objects-selector.xsl"/>
<xsl:include href="x-pe-bool.xsl"/>
<xsl:include href="x-pe-datetime.xsl"/>
<xsl:include href="x-pe-string.xsl"/>
<xsl:include href="x-pe-number.xsl"/>
<xsl:include href="x-pe-selector.xsl"/>
<xsl:include href="x-pe-objects-tree-selector.xsl"/>

</xsl:stylesheet>