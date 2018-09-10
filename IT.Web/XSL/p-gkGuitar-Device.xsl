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
        <xsl:for-each select="Scale">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Мензура:</NOBR>
            </TD>
            <TD>
                <xsl:call-template name="std-template-object-dropdown"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="NeckJoint">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Крепление грифа:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-object-dropdown"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Body">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Корпус:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-object-dropdown"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Top">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Топ:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-object-dropdown"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Neck">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Гриф:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-object-dropdown"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Fingerboards">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Накладка:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-object-dropdown"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="NumFrets">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Количество ладов:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-number"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Frets">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Лады:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-object-dropdown"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Bridge">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Бридж:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-object-dropdown"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Nut">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Порожек:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-object-dropdown"/>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Tuners">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Колки:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-object-dropdown"/>
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
