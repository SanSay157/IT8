<?xml version="1.0" encoding="windows-1251"?>
<!-- 
********************************************************************************
	Страница редактора временного объекта "Фильтр списка активностей"
********************************************************************************
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
	xmlns:b = "urn:x-page-builder"
	xmlns:w = "urn:editor-window-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	xmlns:user = "urn:offcache"
	user:off-cache="1"
>
<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
<xsl:template match="FilterFolderList"> 

	<TABLE CELLSPACING="0" CELLPADDING="0" WIDTH="99%" HEIGHT="99%" BORDER="0">
	<COL STYLE="width:25%" />
	<COL STYLE="width:41%" />
	<COL STYLE="width:12%" />
	<COL STYLE="width:12%" />
	<TBODY>
		<TR>
			<TD STYLE="vertical-align:top; border:#999 solid 1px; border-width:0px 1px 0px 0px; padding-right:5px;">
				
				<TABLE CELLSPACING="0" CELLPADDING="0" WIDTH="99%" BORDER="0">
				<COL STYLE="width:35%;"/>
				<COL STYLE="width:65%;"/>
				<TBODY>

          <xsl:for-each select="CustomerName">
            <TR>
              <TD CLASS="x-editor-text x-editor-propcaption">
                <NOBR>Наименование организации</NOBR>
              </TD>
            </TR>
            <TR>
              <TD STYLE="padding:0px 0px 3px 0px;">
                <xsl:call-template name="std-template-string"/>
              </TD>
            </TR>
          </xsl:for-each>
					<xsl:for-each select="FolderName">
					<TR>
						<TD CLASS="x-editor-text x-editor-propcaption"><NOBR>Наименование активности</NOBR></TD>
					</TR><TR>
						<TD STYLE="padding:0px 0px 3px 0px;"><xsl:call-template name="std-template-string"/></TD>
					</TR>
					</xsl:for-each>
          <xsl:for-each select="NavCode">
          <TR>
            <TD CLASS="x-editor-text x-editor-propcaption">
              <NOBR>Код</NOBR>
            </TD>
          </TR>
          <TR>
            <TD STYLE="padding:0px 0px 3px 0px;">
              <xsl:call-template name="std-template-string"/>
            </TD>
          </TR>
          </xsl:for-each>
          <xsl:for-each select="OnlyRootFolder">
            <TR>
              <TD>
                <xsl:call-template name="std-template-bool">
                  <xsl:with-param name="label">Отображать только корневые активности</xsl:with-param>
                </xsl:call-template>
              </TD>
            </TR>
          </xsl:for-each>
				</TBODY>
				</TABLE>
			
			</TD>
			<TD STYLE="vertical-align:top; border:#999 solid 1px; border-width:0px 1px 0px 0px; height:100%; padding:0px 2px 0px 2px; margin:0px;">
			
				<xsl:for-each select="Directions">
					<xsl:call-template name="std-template-objects-selector">
						<xsl:with-param name="list-metaname">SimpleList</xsl:with-param>
						<xsl:with-param name="off-operations">1</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
				
			</TD>
			<TD STYLE="vertical-align:top; border:#999 solid 1px; border-width:0px 1px 0px 0px;">
			
				<xsl:for-each select="FolderTypes">
				<TABLE CELLSPACING="1" CELLPADDING="0" WIDTH="99%" BORDER="0">
				<TR>
					<TD CLASS="x-editor-text x-editor-propcaption">Типы активностей</TD>
				<TR></TR>
					<TD STYLE="padding-left:10px;">
						<xsl:call-template name="std-template-flags"/>
					</TD>
				</TR>
				</TABLE>
				</xsl:for-each>

			</TD>
			<TD STYLE="vertical-align:top;">
			
				<xsl:for-each select="FolderState">
				<TABLE CELLSPACING="1" CELLPADDING="0" WIDTH="99%" BORDER="0">
				<TR>
					<TD CLASS="x-editor-text x-editor-propcaption">Состояния активностей</TD>
				<TR></TR>
					<TD STYLE="padding-left:10px;">
						<xsl:call-template name="std-template-flags"/>
					</TD>
				</TR>
				</TABLE>
				</xsl:for-each>
				
			</TD>
		</TR>
	</TBODY>
	</TABLE>

</xsl:template>

<xsl:include href="x-pe-string.xsl"/>
<xsl:include href="x-pe-bool.xsl"/>
<xsl:include href="x-pe-objects-selector.xsl"/>
<xsl:include href="x-pe-flags.xsl"/>

</xsl:stylesheet>
