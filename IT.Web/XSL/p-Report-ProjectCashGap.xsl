<?xml version="1.0" encoding="windows-1251"?>
<!-- 
********************************************************************************
	Страница редактора временного объекта FilterReportCashGap для фильтра 
  отчета "Кассовые разрывы". Редактор открывается в отдельном диалоговом окне.
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

<xsl:template match="FilterReportCashGap"> 
<TABLE CELLSPACING="2" CELLPADDING="0" CLASS="x-layoutgrid x-filter-layoutgrid" STYLE="width:100%; height:100%;">
	<TR>
		<TD class="x-editor-text x-editor-propcaption"><NOBR>Режим:</NOBR></TD>
		<TD width="20%">
			<xsl:for-each select="Mode">
				<xsl:call-template name="std-template-selector" >
					<xsl:with-param name="selector" select="'horizontal-radio'"/>
				</xsl:call-template>
			</xsl:for-each>
		</TD>
		<TD  width="80%" height="100%"><SPAN style="margin-left:5px;">Направления:</SPAN><BR/>
			<xsl:for-each select="Directions">
				<xsl:call-template name="std-template-objects-selector" >
          <xsl:with-param name="height">98%</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</TD>
	</TR>
	<TR><TD colspan="2"><HR class="x-editor-hr"/></TD></TR>
	<TR>
		<TD COLSPAN="2" class="x-editor-text x-editor-propcaption"><NOBR>Наименование организации клиента:</NOBR></TD>
	</TR>
	<TR>
		<TD COLSPAN="2">
			<xsl:for-each select="OrganizationName">
				<xsl:call-template name="std-template-string" />
			</xsl:for-each>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="2" class="x-editor-text x-editor-propcaption"><NOBR>Наименование активности (папки):</NOBR></TD>
	</TR>
	<TR>
		<TD COLSPAN="2">
			<xsl:for-each select="FolderName">
				<xsl:call-template name="std-template-string" />
			</xsl:for-each>
		</TD>
	</TR>
	<TR><TD colspan="2"><HR class="x-editor-hr"/></TD></TR>
	<TR>
		<TD valign="top" class="x-editor-text x-editor-propcaption"><NOBR>Виды активностей:</NOBR></TD>
		<TD>
			<xsl:for-each select="ActivityTypes">
				<xsl:call-template name="std-template-flags" />
			</xsl:for-each>
		</TD>
	</TR>
  <xsl:if test="w:CanAccessNotOwnActivities() = 1">
    <TR>
      <TD COLSPAN="2">
        <xsl:for-each select="ShowOrgWithoutActivities">
          <xsl:call-template name="std-template-bool" />
        </xsl:for-each>
      </TD>
    </TR>
    <TR>
      <TD COLSPAN="2">
        <xsl:for-each select="OnlyOwnActivity">
          <xsl:call-template name="std-template-bool" />
        </xsl:for-each>
      </TD>
    </TR>
  </xsl:if>
	<TR>
		<TD colspan="2">
			<HR class="x-editor-hr"/>
		</TD>
	</TR>
	<TR>
		<TD valign="top" class="x-editor-text x-editor-propcaption">
			<NOBR>Состояния активностей:</NOBR>
		</TD>
		<TD>
			<xsl:for-each select="ActivityState">
				<xsl:call-template name="std-template-flags" />
			</xsl:for-each>
		</TD>
	</TR>
	<TR>
		<TD colspan="2">
			<HR class="x-editor-hr"/>
		</TD>
	</TR>
	<TR>
		<TD valign="top" class="x-editor-text x-editor-propcaption">
			<NOBR>Состояния папок:</NOBR>
		</TD>
		<TD>
			<xsl:for-each select="FolderState">
				<xsl:call-template name="std-template-flags" />
			</xsl:for-each>
		</TD>
	</TR>
	<TR>
		<TD/><TD height="100%"/>
	</TR>
</TABLE>
</xsl:template>

<xsl:include href="x-pe-objects-selector.xsl"/>
<xsl:include href="x-pe-bool.xsl"/>
<xsl:include href="x-pe-string.xsl"/>
<xsl:include href="x-pe-selector.xsl"/>
<xsl:include href="x-pe-flags.xsl"/>

</xsl:stylesheet>