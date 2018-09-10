<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	�������� ��������� "�������� ������� �� �������" (TimeSpent) 
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

<xsl:template match="TimeSpent">
	<!-- �������� �������, � ������� ����� ��������� ��-�� ������� -->
	<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%" HEIGHT="100%">
		<COL WIDTH="20%"/>
		<COL WIDTH="80%"/>
		<TBODY>
			<xsl:for-each select="RegDate">
				<TR>
					<TD class="x-editor-text x-editor-propcaption"><NOBR>���� ��������:</NOBR></TD>
					<TD>
						<xsl:call-template name="std-template-date" />
					</TD>
				</TR>
			</xsl:for-each>
			<xsl:for-each select="Spent">
				<TR>
					<TD class="x-editor-text x-editor-propcaption"><NOBR>����������� �����:</NOBR></TD>
					<TD>
						<xsl:call-template name="it-template-time-edit-button">
							<xsl:with-param name="width" select="200"/>
							<xsl:with-param name="description" select="'����������� �����'"/>
						</xsl:call-template>
					</TD>
				</TR>
			</xsl:for-each>
		</TBODY>
	</TABLE>
</xsl:template>

<xsl:include href="x-pe-datetime.xsl"/>
<xsl:include href="it-pe-time-edit-button.xsl"/>

</xsl:stylesheet>
