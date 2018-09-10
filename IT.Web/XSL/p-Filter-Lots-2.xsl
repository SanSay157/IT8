<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	������ �������� ��� ������� ������ ����� ("�������������� ���������")
-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:XService="urn:x-client-service" 
	xmlns:q="urn:query-string-access" 
	xmlns:d="urn:object-editor-access" 
	xmlns:w="urn:editor-window-access" 
	xmlns:b="urn:x-page-builder" 
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
>

<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>

<xsl:template match="FilterLotsList">
<div style="position:relative; width:80%;">

	<table cellspacing="2" cellpadding="0" class="x-layoutgrid x-filter-layoutgrid">
		<col width="15%"/>
		<col width="40%"/>
		<!-- ������� - ������������ ����������� --><col width="5%" />
		<col width="5%"/>
		<col width="20%"/>
	<tbody>
		<tr>
			<td class="x-editor-text x-editor-propcaption"><nobr>������� ���������:</nobr></td>
			<td>
				<xsl:for-each select="CustomerBranch">
					<xsl:call-template name="std-template-object-dropdown" />
				</xsl:for-each>
			</td>
			
			<!-- ������� - ������������ ����������� --><td />
			
			<td class="x-editor-text x-editor-propcaption"><nobr>������������:</nobr></td>
			<td>
				<xsl:for-each select="DocumentationType">
					<xsl:call-template name="std-template-selector">
						<xsl:with-param name="selector">combo</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</td>
		</tr>
		<tr>
			<td class="x-editor-text x-editor-propcaption"><nobr>�������� �� ����:</nobr></td>
			<td>
				<xsl:for-each select="LotManager">
					<xsl:call-template name="std-template-object-dropdown" />
				</xsl:for-each>
			</td>
			
			<!-- ������� - ������������ ����������� --><td />
			
			<td class="x-editor-text x-editor-propcaption"><nobr>���������� ��������:</nobr></td>
			<td>
				<xsl:for-each select="GuaranteeType">
					<xsl:call-template name="std-template-selector">
						<xsl:with-param name="selector">combo</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</td>
			
		</tr>
		<tr>
		
			<td class="x-editor-text x-editor-propcaption"><nobr>���������:</nobr></td>
			<td>
				<xsl:for-each select="Competitor">
					<xsl:call-template name="std-template-object-presentation" />
				</xsl:for-each>
			</td>
			
			<!-- ������� - ������������ ����������� --><td />
			
			<td class="x-editor-text x-editor-propcaption"><nobr>��� ����������:</nobr></td>
			<td style="padding-bottom:5px;">
				<xsl:for-each select="CompetitorType">
					<xsl:call-template name="std-template-selector">
						<xsl:with-param name="selector">combo</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</td>

		</tr>
		<tr>
			<!-- �� ������ �������� �� ���� -->
			<td colspan="5" style="padding-top:3px;">
				<xsl:for-each select="NoLotManager">
					<xsl:call-template name="std-template-bool">
						<xsl:with-param name="label">���������� �� ����, � �������� ������� �� ����� �������� �������</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</td>
		</tr>
	</tbody>
	</table>
	
</div>
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

</xsl:stylesheet>
