<?xml version="1.0" encoding="windows-1251"?>
<!-- 
********************************************************************************
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

<xsl:template match="FilterDKP"> 
	<TABLE CELLSPACING="2" CELLPADDING="0" CLASS="x-layoutgrid x-filter-layoutgrid" STYLE="width:100%; height:100%;">
	<TBODY>
	<TR>
		<TD>
		<TABLE CELLSPACING="1" CELLPADDING="0" STYLE="width:100%;">
			<TR>
				<!-- Отображение установленных данных фильтра -->
				<TD STYLE="padding:3px 5px 0px 3px; vertical-align:top;">
					<NOBR><B STYLE="font:bold 11px; color:#777;">Отображается: </B></NOBR>
				</TD>
				<!-- Отображение установленных данных фильтра -->
				<TD id="oTreeModeDescription" STYLE="width:100%; height:100%; vertical-align:top; padding:2px; background-color:#eee;">
					<xsl:value-of select="w:GetFilterStateDescription()"/>
				</TD>
				<TD align="right" style="width:100px;">
					<!-- Кнопка вызова диалога фильтра -->
					<BUTTON 
						ID="btnOpenFilterDialog" CLASS="x-button x-control-button"
						STYLE="width:50px; padding:0px 5px 1px 5px; border:#777 solid 1px; font:bold 9px; color:#393;"
					><CENTER>Настроить...</CENTER></BUTTON>
				</TD>
			</TR>
		</TABLE>
		</TD>
		<TD width="30%">
			<xsl:for-each select="IncidentViewMode">
				<TABLE CELLSPACING="0" CELLPADDING="0" STYLE="width:100%; height:100%;">
				<TR>
					<TD width="50%" align="right" class="x-editor-text x-editor-propcaption-notnull">Инциденты:</TD>
					<TD width="50%"><xsl:call-template name="std-template-selector"/></TD>
				</TR>
				</TABLE>
			</xsl:for-each>
		</TD>
	</TR>
	<TR>
		<TD width="40%">
		<TABLE CELLSPACING="1" CELLPADDING="0" STYLE="width:100%;">
			<TR>
				<TD><NOBR><B STYLE="font:bold 11px; color:#777;">Сортировка инцидентов:</B></NOBR></TD>
				<TD id="oIncidentSortModeDescription" STYLE="width:100%; height:100%; padding:2px; background-color:#eee;">
					<xsl:value-of select="w:GetIncidentSortMode()"/>
				</TD>
				<TD align="right" style="width:100px;">
					<!-- Кнопка вызова диалога -->
					<BUTTON 
						ID="btnOpenIncidentSortDialog" CLASS="x-button x-control-button" onClick="OnOpenIncidentSortDialog" language="VBScript"
						STYLE="width:50px; padding:0px 5px 1px 5px; border:#777 solid 1px; font:bold 9px; color:#393;"
					><CENTER>Настроить...</CENTER></BUTTON>
				</TD>
				<TD align="right" style="width:100px;">
					<!-- Кнопка вызова диалога -->
					<BUTTON 
						ID="btnSetIncidentSortDefault" CLASS="x-button x-control-button" onClick="OnSetIncidentSortDefault" language="VBScript"
						STYLE="width:50px; padding:0px 5px 1px 5px; border:#777 solid 1px; font:bold 9px; color:#393;"
					><CENTER>По умолчанию</CENTER></BUTTON>
				</TD>
			</TR>
		</TABLE>
		</TD>
		<TD align="right">
			<xsl:for-each select="ShowTasks">
				<xsl:call-template name="std-template-bool"/>
			</xsl:for-each>
			<xsl:for-each select="ShowWorkProgress">
				<xsl:call-template name="std-template-bool"/>
			</xsl:for-each>
		</TD>
	</TR>
	</TBODY>
	</TABLE>
</xsl:template>

<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
<xsl:include href="x-pe-selector.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
<xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
