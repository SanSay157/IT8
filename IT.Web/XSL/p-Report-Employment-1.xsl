<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	1-� �������� ���������� ������ "�������� ��������� �����������"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="FilterReportEmploymentPlanned">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<col width="30%"/>
			<col width="70%"/>
			<tr>
				<td class="x-editor-text x-editor-propcaption">������ �������:</td>
				<td>
					<xsl:call-template name="it-template-period-selector" />
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<hr />
				</td>
			</tr>
			<tr>
				<td>
					<xsl:for-each select="PassRedundant">
						<xsl:call-template name="std-template-bool"/>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td>
					<xsl:for-each select="PassDisabled">
						<xsl:call-template name="std-template-bool"/>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<hr />
				</td>
			</tr>
			<tr>
				<td />
				<td>
					<xsl:for-each select="InsertRestrictions">
						<xsl:call-template name="std-template-bool">
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td />
				<td>
					<xsl:for-each select="IncludeEmployeesWithZeroEmploiment">
						<xsl:call-template name="std-template-bool">
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
		</table>
	</xsl:template>
	<!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��-� -->
	<xsl:include href="x-pe-string.xsl"/>
	<!-- ����������� ������ ��� �����������/����������� ������������ ��-�  ���� � �������-->
	<xsl:include href="x-pe-datetime.xsl"/>
	<!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��������� ��-� -->
	<xsl:include href="x-pe-object.xsl"/>
	<!-- ����������� ������ ��� �����������/����������� �������� ��-�, �������������� ����� �� ������ �������� -->
	<xsl:include href="x-pe-selector.xsl"/>
	<!-- ����������� ������ ��� �����������/����������� ������������ ���������� ��-� -->
	<xsl:include href="x-pe-bool.xsl"/>
	<!-- ����������� ������ ��� �����������/����������� �������� ������ ��-� -->
	<xsl:include href="x-pe-flags.xsl"/>
	<!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��������� ��-� -->
	<xsl:include href="x-pe-object.xsl"/>
	<!-- ����������� ������ ��� ����������� /����������� ��������� ��������� ��-� � ���� ������ � ���������� -->
	<xsl:include href="x-pe-objects-tree-selector.xsl"/>
	<!-- ������ ��� �����������/����������� ������� ������� -->
	<xsl:include href="it-period-selector.xsl"/>
</xsl:stylesheet>
