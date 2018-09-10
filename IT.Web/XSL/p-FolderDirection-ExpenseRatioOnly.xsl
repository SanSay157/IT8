<?xml version="1.0" encoding="windows-1251"?>
<!--
================================================================================
 ����������� �������� ������� "����������� ����������" (FolderDirection)
 ������� ���� ������ �� �����������
================================================================================
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>

<xsl:template match="FolderDirection">

	<TABLE CELLPADDING="0" CELLSPACING="3" STYLE="width:100%; margin:10px 0px 10px 0px;">
	<COL STYLE="" />
	<COL STYLE="width: 100%;" />
	<TBODY>
	
		<xsl:for-each select="Direction/Direction">
		<TR>
			<TD CLASS="x-editor-text x-editor-propcaption" STYLE="vertical-align:top; padding-bottom:5px;">�����������:</TD>
			<TD CLASS="x-editor-text" STYLE="vertical-align:top; padding-bottom:5px;">
				<!-- �������� ����������� -->
				<B><xsl:value-of select="Name" /></B>
				
				<!-- ������� � ��� ������������ (���� �� �����) -->
				<xsl:for-each select="Director/Employee">
					<xsl:text> (������������ - </xsl:text>
					
					<xsl:value-of select="LastName" />
					<xsl:text> </xsl:text>
					<xsl:value-of select="FirstName" />
					
					<!-- ... �����. ������� ������������ (���� ����) -->
					<xsl:for-each select="PhoneExt">
						<xsl:text>, #</xsl:text>
						<xsl:value-of select="text()" />
					</xsl:for-each>
						
					<xsl:text>)</xsl:text>
				</xsl:for-each>
			</TD>
		</TR>
		</xsl:for-each>
		
		<TR>
			<TD CLASS="x-editor-text x-editor-propcaption"><NOBR>���� ������ (� %):</NOBR></TD>
			<TD CLASS="x-editor-text">
				<xsl:for-each select="ExpenseRatio">
					<xsl:call-template name="std-template-number" />
				</xsl:for-each>
			</TD>
		</TR>
		
	</TBODY>		
	</TABLE>
	
</xsl:template>

<!-- ����������� ������ XFW: ����������� ���� ��� ����� ���������� �������������� �������� -->
<xsl:include href="x-pe-number.xsl" />

</xsl:stylesheet>