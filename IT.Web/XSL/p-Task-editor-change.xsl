<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	�������� ��������� ��������� ������� (Task)
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:user="urn:���_�����_���_�����_msxsl:script"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	user:off-cache="1"
	>

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>

<xsl:template match="Task">
	<!-- ������������� ������������ ��� ������� -->
	<xsl:variable name="IsTimeReporting" select="w:IsTimeReporting()"/>
	
	<!-- �������� �������, � ������� ����� ��������� ��-�� ������� -->
	<TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="99%" >
		<COL />
		<COL WIDTH="100%"/>
		<TBODY>
			<xsl:for-each select="Worker/Employee">
				<TR>
					<TD class="x-editor-text x-editor-propcaption">�����������:</TD>
					<TD>
						<B>
							<xsl:value-of select="LastName"/>
							<xsl:value-of select="' '"/>
							<xsl:value-of select="FirstName"/>
						</B>
					</TD>
				</TR>
			</xsl:for-each>
			<xsl:for-each select="Role">
				<TR>
					<TD class="x-editor-text x-editor-propcaption">����:</TD>
					<TD>
						<xsl:choose>
							<xsl:when test="@read-only">
								<B><xsl:value-of select="UserRoleInIncident/Name"/></B>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="std-template-object-dropdown">
									<xsl:with-param name="list-metaname" select="'RolesOfIncidentType'"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</TD>
				</TR>
			</xsl:for-each>
			<!-- ������ ��� ����������� ������������ ��� ������� � ���� ����������� ����� �� ��������� ���������������� ������� -->
			<xsl:if test="$IsTimeReporting and PlannedTime/@read-only">
				<!--��������������� �����-->
				<xsl:for-each select="PlannedTime">
					<TR>
						<TD class="x-editor-text x-editor-propcaption"><NOBR>������� �� �����:</NOBR></TD>
						<TD id="oPlannedTime">
							<xsl:value-of select="w:GetPlannedTimeString()"/>
						</TD>
					</TR>	
				</xsl:for-each>
			</xsl:if>
			<!--����������� -->
			<xsl:for-each select="Planner/Employee">
				<TR>
					<TD class="x-editor-text x-editor-propcaption">�����������:</TD>
					<TD id="oPlannerName">
						<B>
							<xsl:value-of select="LastName"/>
							<xsl:value-of select="' '"/>
							<xsl:value-of select="FirstName"/>
						</B>
					</TD>
				</TR>	
			</xsl:for-each>
			<!-- ������ ��� ����������� ������������ � ������� -->
			<xsl:if test="$IsTimeReporting">
				<TR>
					<TD class="x-editor-text x-editor-propcaption"><NOBR>��������� ������� �����:</NOBR></TD>
					<TD id="oSpentTime">
						<xsl:value-of select="w:GetSpentTimeString()"/>
					</TD>
				</TR>
				<!-- ������ �������� �� ������� -->
				<xsl:for-each select="TimeSpentList">
					<TR>
						<TD style="vertical-align:bottom;padding-bottom:0px;padding-top:10px;" colspan="2" class="x-editor-text x-editor-propcaption">�������� ������� �� �������:</TD>
					</TR>
					<TR>
						<TD colspan="2">
							<xsl:call-template name="std-template-objects">
								<xsl:with-param name="height">156</xsl:with-param>
							</xsl:call-template>
						</TD>
					</TR>
				</xsl:for-each>
				<!-- ���� ��� ���� �� ��������� ���������������� ������� -->
				<xsl:if test="PlannedTime/@read-only">
					<!-- ���������� ����� -->
					<xsl:for-each select="LeftTime">
						<TR>
							<TD class="x-editor-text x-editor-propcaption"><NOBR>�������� �������:</NOBR></TD>
							<TD width="100%">
								<xsl:call-template name="it-template-time-edit-button">
									<xsl:with-param name="width" select="200"/>
								</xsl:call-template>
							</TD>
						</TR>	
					</xsl:for-each>		
				</xsl:if>
				<!-- ���� �������������� ����� ����� ������ -->
				<xsl:if test="not(PlannedTime/@read-only)">
					<!-- ��������������� ����� -->
					<xsl:for-each select="PlannedTime">
						<TR>
							<TD class="x-editor-text x-editor-propcaption">��������������� �����:</TD>
							<TD>
								<xsl:call-template name="it-template-time-edit-button">
									<xsl:with-param name="width" select="200"/>
								</xsl:call-template>
							</TD>
						</TR>
					</xsl:for-each>
					<!-- ���������� ����� -->
					<xsl:for-each select="LeftTime">
						<TR>
							<TD class="x-editor-text x-editor-propcaption"><NOBR>�������� �������:</NOBR></TD>
							<TD>
								<xsl:call-template name="it-template-readonly">
									<xsl:with-param name="value-expression" select="'GetTimeLeftString()'"/>
								</xsl:call-template>
							</TD>
						</TR>	
					</xsl:for-each>		
				</xsl:if>
				<xsl:if test="not(IsFrozen/@read-only)">
					<xsl:for-each select="IsFrozen">
						<TR>
							<TD/>
							<TD>
								<xsl:call-template name="std-template-bool"/>
							</TD>
						</TR>	
					</xsl:for-each>		
				</xsl:if>
				<TR><TD height="100%"/></TR>
			</xsl:if>
		</TBODY>
	</TABLE>
</xsl:template>

<xsl:include href="x-pe-object-list-selector.xsl"/>
<xsl:include href="x-pe-object.xsl"/>
<xsl:include href="it-pe-time-edit-button.xsl"/>
<xsl:include href="x-pe-objects.xsl"/>
<xsl:include href="x-pe-bool.xsl"/>
<xsl:include href="it-pe-readonly.xsl"/>

</xsl:stylesheet>