<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	2-� �������� ���������� ������ "������ �����������"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="/*">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<col width="40%" />
			<col width="60%" />
			<tr>
				<td colspan="2">
					<xsl:for-each select="AllFolders">
						<xsl:call-template name="std-template-bool" />
					</xsl:for-each>
				</td>
			</tr>
			<tr><td  colspan="2"><hr /></td></tr>
			<tr>
				<td  colspan="2">
					<!-- ������ ������ ������� ������� -->
					<BUTTON 
						ID="btnOpenFilterOfFoldersTree" onClick="btnOpenFilterOfFoldersTree_onClick" language="VBScript" 
						CLASS="x-button x-control-button"
						STYLE="width:50px; padding:0px 5px 1px 5px; border:#777 solid 1px; font:bold 9px; color:#393; margin-right:3px;"
					><CENTER>���������...</CENTER></BUTTON>
					<!-- ������ ������� ������� -->
					<BUTTON 
						ID="btnClearFilterOfFoldersTree" onClick="btnClearFilterOfFoldersTree_onClick" language="VBScript" 
						CLASS="x-button x-control-button"
						STYLE="width:50px; padding:0px 5px 1px 5px; border:#777 solid 1px; font:bold 9px; color:#393;"
					><CENTER>��������</CENTER></BUTTON>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<xsl:for-each select="Folders">
						<xsl:call-template name="std-template-objects-tree-selector">
							<xsl:with-param name="height">210</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr><td/></tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">������� ������� �����������:</td>
				<td>
					<xsl:for-each select="ActivityAnalysDepth">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
							<xsl:with-param name="no-empty-value">1</xsl:with-param>
							<xsl:with-param name="maybenull">1</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
		</table>
	</xsl:template>
	<!-- ����������� ������ ��� �����������/����������� ������������ ���������� ��-� -->
	<xsl:include href="x-pe-bool.xsl"/>
	<!-- ����������� ������ ��� �����������/����������� �������� ��-�, �������������� ����� �� ������ �������� -->
	<xsl:include href="x-pe-selector.xsl"/>
	<!-- ����������� ������ ��� ����������� /����������� ��������� ��������� ��-� � ���� ������ � ���������� -->
	<xsl:include href="x-pe-objects-tree-selector.xsl"/>
</xsl:stylesheet>
