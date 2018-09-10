<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
	xmlns:b = "urn:x-page-builder"
	xmlns:w = "urn:editor-window-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:user = "urn:offcache"
>
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="FilterReportEmployeeRate">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<col width="10%"/>
			<col width="90%" height="100"/>
			<tr>
				<td />
				<td>
					<xsl:for-each select="PassDisabled">
						<xsl:call-template name="std-template-bool">
							<xsl:with-param name="label">��������� �������� ���������������� �����������</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td />
				<td>
					<xsl:for-each select="PassRedundant">
						<xsl:call-template name="std-template-bool">
							<xsl:with-param name="label">��������� ��������� �����������</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td />
				<td>
					<xsl:for-each select="ShowRestrictions">
						<xsl:call-template name="std-template-bool">
							<xsl:with-param name="label">�������� � ����� ������� ������</xsl:with-param>
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
</xsl:stylesheet>