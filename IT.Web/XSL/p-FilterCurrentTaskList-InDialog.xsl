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

<xsl:template match="FilterCurrentTaskList"> 
<TABLE CELLSPACING="2" border="0" CELLPADDING="0" CLASS="x-layoutgrid x-filter-layoutgrid" STYLE="width:100%; height:99%;">
	<COL WIDTH="60%"/>
	<COL WIDTH="40%"/>
	<TR>
		<TD ROWSPAN="14">
			<xsl:for-each select="IncidentTypes">
				<xsl:call-template name="std-template-objects-selector" >
				</xsl:call-template>
			</xsl:for-each>
		</TD>
		<TD>
			<!-- Сокращенный список инцидентов -->
			<xsl:for-each select="RestrictedList">
				<xsl:call-template name="std-template-bool" />
			</xsl:for-each>
		</TD>
	</TR>
	<!-- Инциденты с дедлайном -->
	<TR>
		<TD>
			<xsl:for-each select="IncidentsWithDeadline">
				<xsl:call-template name="std-template-bool" />
			</xsl:for-each>
		</TD>
	</TR>
	<!-- Дней до дедлайна -->
	<TR>
		<TD>
			<TABLE CELLSPACING="2" border="0" CELLPADDING="0" WIDTH="100%">
				<TR>
					<TD class="x-editor-text x-editor-propcaption" id="oDeadlineInNextDaysTitle"><NOBR>Дедлайн в ближайщие (дней):</NOBR></TD>
					<TD WIDTH="100%">
						<xsl:for-each select="DeadlineInNextDays">
							<xsl:call-template name="std-template-number">
							</xsl:call-template>
						</xsl:for-each>
					</TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
	<!-- Инциденты с просроченным дедлайном -->
	<TR>
		<TD>
			<xsl:for-each select="IncidentsWithExpiredDeadline">
				<xsl:call-template name="std-template-bool" />
			</xsl:for-each>
		</TD>
	</TR>
	
	<TR><TD><HR class="x-editor-hr"/></TD></TR>
	<!-- Наименование папки -->
	<TR>
		<TD class="x-editor-text x-editor-propcaption"><NOBR>Наименование папки:</NOBR></TD>
	</TR>
	<TR>
		<TD>
			<xsl:for-each select="FolderName">
				<xsl:call-template name="std-template-string" />
			</xsl:for-each>
		</TD>
	</TR>
	<!-- Наименование инцидента -->
	<TR>
		<TD class="x-editor-text x-editor-propcaption"><NOBR>Наименование инцидента:</NOBR></TD>
	</TR>
	<TR>
		<TD>
			<xsl:for-each select="IncidentName">
				<xsl:call-template name="std-template-string" />
			</xsl:for-each>
		</TD>
	</TR>
	<!-- Приоритет инцидента -->
	<TR>
		<TD class="x-editor-text x-editor-propcaption">Приоритет инцидента:</TD>
	</TR>
	<TR>
		<TD>
			<xsl:for-each select="IncidentPriority">
				<xsl:call-template name="std-template-selector" />
			</xsl:for-each>
		</TD>
	</TR>
	<!-- Категория состояния -->
	
	<TR>
		<TD class="x-editor-text x-editor-propcaption">Категория состояния:</TD>
	</TR>
	<TR>
		<TD>
			<xsl:for-each select="IncidentStateCategory">
				<xsl:call-template name="std-template-selector" />
			</xsl:for-each>
		</TD>
	</TR>
	<TR>
		<TD height="100%">&#160;</TD>
	</TR>
</TABLE>
</xsl:template>

<xsl:include href="x-pe-objects-selector.xsl"/>
<xsl:include href="x-pe-bool.xsl"/>
<xsl:include href="x-pe-string.xsl"/>
<xsl:include href="x-pe-selector.xsl"/>
<xsl:include href="x-pe-number.xsl"/>

</xsl:stylesheet>