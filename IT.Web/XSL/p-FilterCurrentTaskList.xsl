<?xml version="1.0" encoding="windows-1251"?>
<!-- 
	Страница редактора объекта FilterCurrentTaskList для фильтра списка текущих заданий сотрудника (CurrentTaskList)
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

<xsl:template match="FilterCurrentTaskList"> 
<TABLE CELLSPACING="0" CELLPADDING="0" border="0" CLASS="x-layoutgrid x-filter-layoutgrid" STYLE="width:100%; height:100%;">
	<TR>
		<TD>
			<!-- Сокращенный список инцидентов -->
			<xsl:for-each select="RestrictedList">
				<xsl:call-template name="std-template-bool" />
			</xsl:for-each>
		</TD>
		<TD align="right" width="200">
			<!-- Кнопка вызова диалога фильтра -->
			<BUTTON 
				ID="btnOpenFilterDialog" CLASS="x-button x-control-button"
				STYLE="width:100px; height:25px; padding:0px 5px 1px 5px; border:#777 solid 1px; font:bold 9px; color:#393;"
			><CENTER>Фильтр...</CENTER></BUTTON>
		</TD>
		<TD align="right" width="200">
			<BUTTON 
				ID="btnCreateTimeLoss" CLASS="x-button x-control-button"
				STYLE="width:100px; height:25px; padding:0px 5px 1px 5px; border:#777 solid 1px; font:bold 9px; color:#393;"
			><CENTER>Списать время...</CENTER></BUTTON>
		</TD>
	</TR>
</TABLE>
</xsl:template>

<xsl:include href="x-pe-objects-selector.xsl"/>
<xsl:include href="x-pe-bool.xsl"/>
<xsl:include href="x-pe-string.xsl"/>
<xsl:include href="x-pe-selector.xsl"/>

</xsl:stylesheet>