<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
-->
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

  <xsl:template match="*">
    <TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="100%">
      <xsl:for-each select="SystemUser/SystemUser/Login">
        <TR>
          <TD width="20%" class="x-editor-text x-editor-propcaption">
            <NOBR>Логин:</NOBR>
          </TD>
          <TD>
            <xsl:call-template name="std-template-string" />
          </TD>
        </TR>
      </xsl:for-each>
    </TABLE>
    <TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="100%">
      <xsl:for-each select="SystemUser/SystemUser/SystemRoles">
        <TR>
          <TD COLSPAN="2" class="x-editor-text x-editor-propcaption" valign="bottom">Системные роли:</TD>
        </TR>
        <TR>
          <TD COLSPAN="2">
            <xsl:call-template name="std-template-objects-selector" >
              <xsl:with-param name="height" select="'200px'"/>
            </xsl:call-template>
          </TD>
        </TR>
      </xsl:for-each>
      <tr>
        <td colspan="2">
          <hr class="x-editor-hr"/>
        </td>
      </tr>
      <TR>
        <TD width="50%">Системные привилегии:</TD>
        <TD width="50%">Управление папками типов проектных затрат:</TD>
      </TR>
      <TR>
        <TD>
          <xsl:for-each select="SystemUser/SystemUser/SystemPrivileges">
            <xsl:call-template name="std-template-flags" />
          </xsl:for-each>
        </TD>
        <TD height="100%">
          <xsl:for-each select="SystemUser/SystemUser/ActivityTypes">
            <xsl:call-template name="std-template-objects-tree-selector" />
          </xsl:for-each>
        </TD>
      </TR>
      <tr>
        <td colspan="2">
          <hr class="x-editor-hr"/>
        </td>
      </tr>
      <TR>
        <td>
          <xsl:for-each select="SystemUser/SystemUser/IsServiceAccount">
            <xsl:call-template name="std-template-bool" />
          </xsl:for-each>
        </td>
      </TR>
    </TABLE>
  </xsl:template>
  <xsl:include href="x-pe-string.xsl"/>
  <xsl:include href="x-pe-flags.xsl"/>
  <xsl:include href="x-pe-bool.xsl"/>
  <xsl:include href="x-pe-objects-tree-selector.xsl"/>
  <xsl:include href="x-pe-objects-selector.xsl"/>
</xsl:stylesheet>
