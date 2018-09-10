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
	xmlns:msxsl="urn:schemas-microsoft-com:xslt">
  <xsl:output
    method="html"
    version="4.0"
    encoding="windows-1251"
    omit-xml-declaration="yes"
    media-type="text/html"/>
  <xsl:template match="PrjGroup">
    <table BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="100%">
      <col/>
      <col width="100%" />
      <tr>
        <td class="x-editor-text x-editor-propcaption">Название:</td>
        <td>
          <xsl:for-each select="Name">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td class="x-editor-text x-editor-propcaption">Владелец:</td>
        <td>
          <xsl:for-each select="Owner">
            <xsl:call-template name="std-template-object-dropdown">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <hr align="center"/>
        </td>
      </tr>
      <tr height="620">
        <td class="x-editor-text x-editor-propcaption" valign="top">Договоры:</td>
        <td>
          <xsl:for-each select="Contracts">
            <xsl:call-template name="std-template-objects">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <hr align="center"/>
        </td>
      </tr>
      <tr>
        <td/>
        <td>
          <xsl:for-each select="Archive">
            <xsl:call-template name="std-template-bool">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
    </table>
  </xsl:template>
  <xsl:include href="x-pe-string.xsl"/>
  <xsl:include href="x-pe-object.xsl"/>
  <xsl:include href="x-pe-objects.xsl"/>
  <xsl:include href="x-pe-bool.xsl"/>
</xsl:stylesheet>
