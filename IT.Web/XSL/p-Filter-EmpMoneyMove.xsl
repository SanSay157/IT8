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
  
  <xsl:template match="FilterEmpMoneyMove">
    <table cellspacing="2" cellpadding="0" class="x-layoutgrid x-filter-layoutgrid">
      <col width="5%" />
      <col width="25%" />
      <!-- Вертикальный разделитель -->
      <col width="15%" />
      <col width="5%" />
      <col width="50%" />

      <tr>
        <td class="x-editor-text x-editor-propcaption">Дата с:</td>
        <td>
          <xsl:for-each select="DateFrom">
            <xsl:call-template name="std-template-date">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td class="x-editor-text x-editor-propcaption">Передал:</td>
        <td >
          <xsl:for-each select="From">
            <xsl:call-template name="std-template-object">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td class="x-editor-text x-editor-propcaption">Дата по:</td>
        <td>
          <xsl:for-each select="DateTo">
            <xsl:call-template name="std-template-date">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td class="x-editor-text x-editor-propcaption">Принял:</td>
        <td >
          <xsl:for-each select="To">
            <xsl:call-template name="std-template-object">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
    </table>
  </xsl:template>
  <xsl:include href="x-pe-string.xsl"/>
  <xsl:include href="x-pe-datetime.xsl"/>
  <xsl:include href="x-pe-selector.xsl"/>
  <xsl:include href="x-pe-object.xsl"/>
</xsl:stylesheet>
