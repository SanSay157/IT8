<?xml version="1.0" encoding="windows-1251"?>
<!--
	===========================================================================
	�������� ���� - �������� "�������� ��������������"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
<xsl:template match="Lot">
	<table width="100%" border="0" cellspacing="3" cellpadding="0">
		<!-- ��������� ������� ������� ������ -->
		<tr>
			<td>
				<table width="100%" cellspacing="3" cellpadding="0" class="x-editor-subtable-yellow">
					<col width="100%" />
					<!-- ������ ������ � ������� -->
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="3" cellpadding="0">
								<tr>
									<td width="20%" class="x-editor-text x-editor-propcaption">�������� ��������</td>
									<td width="80%">
										<xsl:for-each select="LotParticipants/LotParticipant[ParticipationType=1]/ParticipantOrganization">
											<xsl:call-template name="std-template-object-dropdown">
												<xsl:with-param name="list-metaname">OwnTenderParticipants</xsl:with-param>
											</xsl:call-template>
										</xsl:for-each>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<!-- ��������� ������� ������� ������ -->
					<tr>
						<td>
							<table width="100%" cellspacing="0" cellpadding="0">
								<tr>
									<td>
										<table width="100%" cellspacing="3" cellpadding="0" style="border-width:1px 1px 0px 1px" class="x-editor-subtable-green">
											<!-- ������ ������ � ���� / �������	-->
											<tr>
												<td>
													<table width="100%" border="0" cellspacing="3" cellpadding="0">
														<col width="20%"/>
														<col width="80%"/>
														<!-- ����� -->
														<tr>
															<td class="x-editor-text x-editor-propcaption">�����</td>
															<td>
																<xsl:for-each select="Number">
																	<xsl:call-template name="std-template-string"/>
																</xsl:for-each>
															</td>
														</tr>
														<!-- �������� -->
														<tr>
															<td class="x-editor-text x-editor-propcaption">��������</td>
															<td>
																<xsl:for-each select="Name">
																	<xsl:call-template name="std-template-string"/>
																</xsl:for-each>
															</td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
									</td>
								</tr>
								<tr>
									<td>
										<table width="100%" cellspacing="3" cellpadding="0" style="border-width:1px 1px 0px 1px" class="x-editor-subtable-blue">
											<!-- ������ ������ � ����� ������� � ������� -->
											<tr>
												<td>
													<table width="100%" border="0" cellspacing="3" cellpadding="0">
														<tr>
															<!-- ��������� -->
															<td width="30%" class="x-editor-text x-editor-propcaption">���������</td>
															<td width="70%">
																<xsl:for-each select="State[not(@read-only)]">
																	<xsl:call-template name="std-template-selector">
																		<xsl:with-param name="selector">combo</xsl:with-param>
																	</xsl:call-template>
																</xsl:for-each>
																<xsl:for-each select="State[@read-only]">
																	<xsl:call-template name="it-template-readonly">
																		<xsl:with-param name="value-expression">NameOf_LotState(item.State)</xsl:with-param>
																	</xsl:call-template>
																</xsl:for-each>
															</td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
									</td>
								</tr>
								<tr>
									<td>
										<table width="100%" cellspacing="3" cellpadding="0" class="x-editor-subtable-yellow">
											<!-- ������ ������ � ����� ����������� -->
											<tr>
												<td>
													<table width="100%" border="0" cellspacing="3" cellpadding="0">
														<col width="30%" />
														<col width="40%" />
														<col width="15%" align="right" />
														<col width="15%" align="right" />
														<!-- �������� ������� -->
														<tr>
															<td class="x-editor-text x-editor-propcaption">�������� �������</td>
															<td>
																<xsl:for-each select="Manager">
																	<xsl:call-template name="std-template-object-presentation">
																		<xsl:with-param name="use-tree-selector">AnyEmployees</xsl:with-param>
																		<xsl:with-param name="off-create">1</xsl:with-param>
																		<xsl:with-param name="off-edit">1</xsl:with-param>
																		<xsl:with-param name="off-delete">1</xsl:with-param>
																		<xsl:with-param name="select-symbol">dots</xsl:with-param>
																	</xsl:call-template>
																</xsl:for-each>
															</td>
															<td>
																<xsl:for-each select="MgrIsAcquaint">
																	<xsl:call-template name="std-template-bool">
																		<xsl:with-param name="label">�����������, </xsl:with-param>
																	</xsl:call-template>
																</xsl:for-each>
															</td>
															<td>
																<xsl:for-each select="MgrDocsGettingDate">
																	<xsl:call-template name="std-template-date"/>
																</xsl:for-each>
															</td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<!-- ���������� -->
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="3" cellpadding="0">
					<col width="15%"/>
					<col width="85%"/>
					<tr>
						<td class="x-editor-text x-editor-propcaption">����������</td>
						<td>
							<xsl:for-each select="Note">
								<xsl:call-template name="std-template-text">
									<xsl:with-param name="minheight">80</xsl:with-param>
									<xsl:with-param name="maxheight">200</xsl:with-param>
								</xsl:call-template>
							</xsl:for-each>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</xsl:template>

<!-- ������ ��� �����������/����������� ���������� ���������� �������� ���� "�����" -->
<xsl:include href="tms-pe-object-sum.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��-� -->
<xsl:include href="x-pe-string.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ������������ �������� ��-� -->
<xsl:include href="x-pe-number.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ������������ ��-�  ���� � �������-->
<xsl:include href="x-pe-datetime.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��������� ��-� -->
<xsl:include href="x-pe-object.xsl"/>
<!-- ����������� ������ ��� �����������/����������� �������� ��-�, �������������� ����� �� ������ �������� -->
<xsl:include href="x-pe-selector.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ������������ ���������� ��-� -->
<xsl:include href="x-pe-bool.xsl"/>

<xsl:include href="it-pe-readonly.xsl"/>
	
</xsl:stylesheet>
