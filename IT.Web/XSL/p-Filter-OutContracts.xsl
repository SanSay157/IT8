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
  
  <xsl:template match="FilterOutContractsList">
    <table cellspacing="2" cellpadding="0" class="x-layoutgrid x-filter-layoutgrid">
      <col width="5%" />
      <col width="10%" />
      <!-- Вертикальный разделитель -->
      <col width="5%" />
      <col width="7%" />
      <col width="13%" />
      <!-- Вертикальный разделитель -->
      <col width="5%" />
      <col width="20%" />
      <col width="35%" />

      <tr>
        <td class="x-editor-text x-editor-propcaption">Дата с:</td>
        <td>
          <xsl:for-each select="DateFrom">
            <xsl:call-template name="std-template-date">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td class="x-editor-text x-editor-propcaption">Владелец:</td>
        <td >
          <xsl:for-each select="InContrOwner">
            <xsl:call-template name="std-template-object-dropdown">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td class="x-editor-text x-editor-propcaption">Код проекта:</td>
        <td>
          <xsl:for-each select="PrjCode">
            <xsl:call-template name="std-template-string">
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
        <td class="x-editor-text x-editor-propcaption">Отчетный год:</td>
        <td >
          <xsl:for-each select="InContrYear">
            <xsl:call-template name="std-template-object-dropdown">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td /> 
        <td class="x-editor-text x-editor-propcaption">Номер приходного договора:</td>
        <td>
          <xsl:for-each select="ContrNum">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td class="x-editor-text x-editor-propcaption">Контрагент:</td>
        <td colspan="4">
          <xsl:for-each select="Org">
            <xsl:call-template name="std-template-object">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td/>
        <td class="x-editor-text x-editor-propcaption">Номер расходного договора:</td>
        <td>
          <xsl:for-each select="OutContrNum">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
    </table>
  </xsl:template>
  <xsl:include href="x-pe-string.xsl"/>
  <xsl:include href="x-pe-datetime.xsl"/>
  <xsl:include href="x-pe-object.xsl"/>
</xsl:stylesheet>
