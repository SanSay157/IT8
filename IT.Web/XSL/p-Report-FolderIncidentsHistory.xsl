<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	�������� ���������� ������ "������� ��������� ���������� �������"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="FilterReportFolderIncidentsHistory">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<col width="30%"/>
			<col width="70%"/>
			<tr>
				<td class="x-editor-text x-editor-propcaption">������ �������:</td>
				<td>
					<xsl:call-template name="it-template-period-selector" />
				</td>
			</tr>
			<tr><td colspan="2"><hr /></td></tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">����������:</td>
				<td>
					<xsl:for-each select="Folder">
						<xsl:call-template name="std-template-object-presentation">
							<xsl:with-param name="select-symbol">dots</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">������� ������� �����������:</td>
				<td>
					<xsl:for-each select="ActivityAnalysDepth">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
							<xsl:with-param name="no-empty-value">1</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">��������������� �� �����������:</td>
				<td>
					<xsl:for-each select="SectionByActivity">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
							<xsl:with-param name="no-empty-value">1</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">����������� ��������� ����������:</td>
				<td>
					<xsl:for-each select="Detalization">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
							<xsl:with-param name="no-empty-value">1</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td />
				<td>
					<xsl:for-each select="IncludeSubProjects">
						<xsl:call-template name="std-template-bool">
							<xsl:with-param name="label">�������� � ������ ������� �����������</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr><td colspan="2"><hr /></td></tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">������������ �������:</td>
				<td>
					<table width="100%" border="0" cellspacing="1" cellpadding="0">
						<tr>
							<td>
								<xsl:for-each select="ShowColumnIncidentNumber">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">����� ���������</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="ShowColumnIncidentName">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">�������� ���������</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>
								<xsl:for-each select="ShowColumnIncidentType">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">����� ���������</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="ShowColumnDescr">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">�������� ���������</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>
								<xsl:for-each select="ShowColumnChangeDate">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">����</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="ShowColumnState">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">���������</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>
								<xsl:for-each select="ShowColumnEmployee">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">���������</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="ShowColumnSolution">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">�������� �������</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
					</table>
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
	<!-- ������ ��� �����������/����������� ������� ������� -->
	<xsl:include href="it-period-selector.xsl"/>
</xsl:stylesheet>
