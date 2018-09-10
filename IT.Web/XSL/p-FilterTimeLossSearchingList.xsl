<?xml version="1.0" encoding="windows-1251"?>
<!-- 
	Страница редактора объекта FilterTimeLossSearchingList для фильтра списка списаний сотрудника (TimeLossSearchingList)
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
	xmlns:b = "urn:x-page-builder"
	xmlns:w = "urn:editor-window-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	xmlns:user = "urn:offcache"
	xmlns:qs = "urn:query-string-access"
	user:off-cache="1"
	>

<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>

<xsl:template match="FilterTimeLossSearchingList"> 
	<TABLE CELLSPACING="2" CELLPADDING="0" border="0" CLASS="x-layoutgrid x-filter-layoutgrid" STYLE="width:100%; height:100%;">
		<TR>
			<TD STYLE="height:20%;">
				<TABLE CELLSPACING="2" CELLPADDING="0" BORDER="0">
					<TR>
						<TD class="x-editor-text x-editor-propcaption" style="padding-left:0px;">
							<NOBR>Дата списания:</NOBR>
						</TD>
						<TD>c</TD>
						<TD>
							<xsl:for-each select="LossFixedStart">
								<xsl:call-template name="std-template-date" />
							</xsl:for-each>
						</TD>
						<TD>по</TD>
						<TD>
							<xsl:for-each select="LossFixedEnd">
								<xsl:call-template name="std-template-date" />
							</xsl:for-each>
						</TD>
					</TR>
				</TABLE>
			</TD>
			<TD width="100%" ROWSPAN="8" STYLE="width:70%; height:100%;">
				<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0" STYLE="width:100%; height:100%;">
					<TR>
						<TD class="x-editor-text x-editor-propcaption">Причина списания:</TD>
					</TR>
					<TR>
						<TD ROWSPAN="8" STYLE="width:50%; height:100%">
							<xsl:for-each select="Causes">
								<xsl:call-template name="std-template-objects-selector" />
							</xsl:for-each>
						</TD>
					</TR>
				</TABLE>
			</TD>
		</TR>
		<TR>
			<TD STYLE="height:20%;">
				<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0" STYLE="width:40%; height:100%;">
					<TD class="x-editor-text x-editor-propcaption" style="padding-left:0px;">
							<NOBR>Внешний код:</NOBR>
					</TD>
					<TD ROWSPAN="0">
						<xsl:for-each select="ExternalID">
							<xsl:call-template name="std-template-string">
								<xsl:with-param name="width" select="250"/>
							</xsl:call-template>
						</xsl:for-each>
					</TD>
				</TABLE>	
			</TD>
		</TR>
    <xsl:if test="w:get-g_bShowOnlyOwnTimeLoss()">
      <TR>
        <TD>
          <xsl:for-each select="OnlyOwnTimeLoss">
            <xsl:call-template name="std-template-bool" />
          </xsl:for-each>
        </TD>
      </TR>
    </xsl:if>
	</TABLE>
	
</xsl:template>

<xsl:include href="x-pe-objects-selector.xsl"/>
<xsl:include href="x-pe-object.xsl"/>
<xsl:include href="x-pe-objects.xsl"/>
<xsl:include href="x-pe-datetime.xsl"/>
<xsl:include href="x-pe-bool.xsl"/>
<xsl:include href="x-pe-string.xsl"/>
</xsl:stylesheet>