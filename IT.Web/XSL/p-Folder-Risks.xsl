<?xml version="1.0" encoding="windows-1251"?>
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

  <xsl:template match="Folder">
    <TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="90%">
      <TBODY>
        <xsl:for-each select="Risks">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>��������� �����:</NOBR>
            </TD>
          </TR>
          <TR height="350">
            <TD>
              <xsl:if test="@read-only">
                <xsl:call-template name="std-template-objects" >
                  <xsl:with-param name="disabled" select="'1'" />
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="not(@read-only)">
                <xsl:call-template name="std-template-objects"/>
              </xsl:if>
            </TD>
          </TR>
        </xsl:for-each>
      </TBODY>
    </TABLE>
  </xsl:template>
  <xsl:include href="x-pe-objects.xsl"/>
</xsl:stylesheet>
