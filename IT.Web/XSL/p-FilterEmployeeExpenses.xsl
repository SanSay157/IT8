<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	�������� ���������� ������ "���� � ��������� ���������"
-->
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:XService="urn:x-client-service" 
	xmlns:q="urn:query-string-access" 
	xmlns:d="urn:object-editor-access" 
	xmlns:w="urn:editor-window-access" 
	xmlns:b="urn:x-page-builder" 
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:user="urn:���_�����_���_�����_msxsl:script"	
	>
	
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="FilterEmployeeExpensesList">
		<CENTER>
			<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%">
				<COL WIDTH="30%"/>
				<COL WIDTH="70%"/>
				<TBODY>
				
					<xsl:choose>
						<xsl:when test="0!=user:InitPropListIterator('AnalysDirection;')">
							<xsl:call-template name="x-editor-xsl-template-iterate-props">
								<xsl:with-param name="current-name" select="user:GetNextPropName()"/>
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>	
					<tr><td colspan="2"><hr/></td></tr>
					<tr>
						<td class="x-editor-text x-editor-propcaption">������ �������:</td>
						<td>
							<xsl:call-template name="it-template-period-selector" />
						</td>
					</tr>
			<tr><td colspan="2"><hr/></td></tr>
			
					<xsl:choose>
						<xsl:when test="0!=user:InitPropListIterator('Employee;ActivityType;ExepenseDetalization;SectioningByActivity;ExpenseType;IncidentState;NonProjectExpences')">
							<xsl:call-template name="x-editor-xsl-template-iterate-props">
								<xsl:with-param name="current-name" select="user:GetNextPropName()"/>
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>	
					<tr>
						<td class="x-editor-text x-editor-propcaption" colspan="2">���������� �������:</td>
					</tr>
					<xsl:choose>
						<xsl:when test="0!=user:InitPropListIterator('IncidentAttributes;Date;NumberOfTasks;Remaining;NewState;Comment')">
							<xsl:call-template name="x-editor-xsl-template-iterate-props">
								<xsl:with-param name="current-name" select="user:GetNextPropName()"/>
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>			
			<tr><td colspan="2"><hr/></td></tr>				
					<xsl:choose>
						<xsl:when test="0!=user:InitPropListIterator('SectionByActivity;Sort;SortOrder;TimeMeasureUnits;IncludeParams')">
							<xsl:call-template name="x-editor-xsl-template-iterate-props">
								<xsl:with-param name="current-name" select="user:GetNextPropName()"/>
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>
				</TBODY>
			</TABLE>
		</CENTER>
	</xsl:template>
	<!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��-� -->
	<xsl:import href="x-pe-string.xsl"/>
	<!-- ����������� ������ ��� �����������/����������� ������������ ��-�  ���� � �������-->
	<xsl:import href="x-pe-datetime.xsl"/>
	<!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��������� ��-� -->
	<xsl:import href="x-pe-object.xsl"/>
	<!-- ����������� ������ ��� �����������/����������� �������� ��-�, �������������� ����� �� ������ �������� -->
	<xsl:import href="x-pe-selector.xsl"/>
	<!-- ����������� ������ ��� �����������/����������� ������������ ���������� ��-� -->
	<xsl:import href="x-pe-bool.xsl"/>
	
	<xsl:import href="x-editor.xsl"/>
	<!-- ������ ��� �����������/����������� ������� ������� -->
	<xsl:import href="it-period-selector.xsl"/>
	
</xsl:stylesheet>
