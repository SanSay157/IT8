<?xml version="1.0" encoding="windows-1251"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:user="urn:это_нужно_для_блока_msxsl:script"
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

  <xsl:template match="gkGuitar">
    <TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="90%">
      <COL WIDTH="25%"/>
      <COL WIDTH="75%"/>
      <TBODY>
        <xsl:for-each select="Model">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Модель:</NOBR>
            </TD>
            <TD>
                <xsl:call-template name="std-template-object-dropdown"/>
            </TD>
          </TR>
        </xsl:for-each>
        
        <xsl:for-each select="Instance">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Экземпляр:</NOBR>
            </TD>
            <TD>
                <xsl:call-template name="std-template-string"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="CS">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR></NOBR>
            </TD>
            <TD>
                <xsl:call-template name="std-template-bool"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Year">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Год производства:</NOBR>
            </TD>
            <TD>
                <xsl:call-template name="std-template-number"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Month">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Месяц производства:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-number"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="SN">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>SN:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-string"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Code">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Код:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-string"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Name">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Имя:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-string"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Rem">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Примечание:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-text"/>
            </TD>
          </TR>
        </xsl:for-each>
      </TBODY>
    </TABLE>
  </xsl:template>
  <xsl:include href="x-pe-bool.xsl"/>
  <xsl:include href="x-pe-string.xsl"/>
  <xsl:include href="x-pe-number.xsl"/>
  <xsl:include href="x-pe-object.xsl"/>
</xsl:stylesheet>
