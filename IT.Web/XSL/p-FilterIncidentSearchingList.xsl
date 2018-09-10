<?xml version="1.0" encoding="windows-1251"?>
<!-- 
********************************************************************************
	Фильтр списка "Список инцидентов" (IncidentSearchingList)
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
		<TD width="30%" class="x-editor-text x-editor-propcaption"><NOBR>Номер инцидента:</NOBR></TD>
		<TD>
			<xsl:for-each select="IncidentNumber">
				<xsl:call-template name="std-template-number" >
					<xsl:with-param name="width" select="250"/>
				</xsl:call-template>
			</xsl:for-each>
		</TD>
		<TD ROWSPAN="8" width="45%" height="100%">
			<xsl:for-each select="IncidentTypes">
				<xsl:call-template name="std-template-objects-selector" >
				</xsl:call-template>
			</xsl:for-each>
		</TD>
    <TD ROWSPAN="8" width="25%" height="100%" valign="top">
      <NOBR>Категория состояния инцидента:</NOBR>
      <br/>
      <xsl:for-each select="IncidentStateCategoryFlags">
        <xsl:call-template name="std-template-flags">
          <xsl:with-param name="width" select="250"/>
        </xsl:call-template>
      </xsl:for-each>
    </TD>
	</TR>
	<TR>
		<TD class="x-editor-text x-editor-propcaption"><NOBR>Наименование инцидента:</NOBR></TD>
		<TD>
			<xsl:for-each select="IncidentName">
				<xsl:call-template name="std-template-string" >
					<xsl:with-param name="width" select="250"/>
				</xsl:call-template>
			</xsl:for-each>
		</TD>
	</TR>
	<TR>
		<TD class="x-editor-text x-editor-propcaption"><NOBR>Приоритет инцидента:</NOBR></TD>
		<TD>
			<xsl:for-each select="IncidentPriority">
				<xsl:call-template name="std-template-selector">
					<xsl:with-param name="width" select="250"/>
				</xsl:call-template>
			</xsl:for-each>
		</TD>
	</TR>
	<TR>
		<!-- Инциденты с просроченным дедлайном -->
		<TD COLSPAN="2">
			<xsl:for-each select="IncidentsWithExpiredDeadline">
				<xsl:call-template name="std-template-bool" />
			</xsl:for-each>
		</TD>
	</TR>
	<TR>
		<!-- Инциденты с дедлайном -->
		<TD>
			<xsl:for-each select="IncidentsWithDeadline">
				<xsl:call-template name="std-template-bool" />
			</xsl:for-each>
		</TD>
		<TD>
			<TABLE CELLSPACING="2" CELLPADDING="0" >
			<TR>
				<TD> с </TD>
				<TD>
					<xsl:for-each select="DeadlineDateBegin">
						<xsl:call-template name="std-template-date" >
							<!--xsl:with-param name="disabled" select="number('1')" /-->
						</xsl:call-template>
					</xsl:for-each>
				</TD>
				<TD> по </TD>
				<TD>
					<xsl:for-each select="DeadlineDateEnd">
						<xsl:call-template name="std-template-date" />
					</xsl:for-each>
				</TD>
			</TR>
			</TABLE>
		</TD>		
	</TR>
	<TR>
		<TD class="x-editor-text x-editor-propcaption"><NOBR>Дата регистрации:</NOBR></TD>
		<TD>
			<TABLE CELLSPACING="2" CELLPADDING="0" >
			<TR>
				<TD> с </TD>
				<TD>
					<xsl:for-each select="InputDateBegin">
						<xsl:call-template name="std-template-date" />
					</xsl:for-each>
				</TD>
				<TD> по </TD>
				<TD>
					<xsl:for-each select="InputDateEnd">
						<xsl:call-template name="std-template-date" />
					</xsl:for-each>
				</TD>
			</TR>
			</TABLE>
		</TD>
	</TR>
	<TR>
		<TD class="x-editor-text x-editor-propcaption"><NOBR>Дата последней активности:</NOBR></TD>
		<TD>
			<TABLE CELLSPACING="2" CELLPADDING="0" >
			<TR>
				<TD> с </TD>
				<TD>
					<xsl:for-each select="LastActivityDateBegin">
						<xsl:call-template name="std-template-date" />
					</xsl:for-each>
				</TD>
				<TD> по </TD>
				<TD>
					<xsl:for-each select="LastActivityDateEnd">
						<xsl:call-template name="std-template-date" />
					</xsl:for-each>
				</TD>
			</TR>
			</TABLE>
		</TD>
	</TR>
	<TR>
		<TD/><TD height="100%"/>
	</TR>
</TABLE>
</xsl:template>

<xsl:include href="x-pe-objects-selector.xsl"/>
<xsl:include href="x-pe-bool.xsl"/>
<xsl:include href="x-pe-datetime.xsl"/>
<xsl:include href="x-pe-string.xsl"/>
<xsl:include href="x-pe-number.xsl"/>
<xsl:include href="x-pe-selector.xsl"/>
<xsl:include href="x-pe-flags.xsl"/>
<xsl:include href="x-pe-objects-tree-selector.xsl"/>

</xsl:stylesheet>