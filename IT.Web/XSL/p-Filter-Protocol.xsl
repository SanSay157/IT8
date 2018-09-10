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
  
  <xsl:template match="FilterProtocol">
    <table cellspacing="2" cellpadding="0" class="x-layoutgrid x-filter-layoutgrid">
      <col width="5%" />
      <col width="10%" />
      <!-- Вертикальный разделитель -->
      <col width="5%" />
      <col width="10%" />
      <col width="20%" />
      <!-- Вертикальный разделитель -->
      <col width="5%" />
      <col width="10%" />
      <col width="35%" />

      <tr>
        <td class="x-editor-text x-editor-propcaption">C:</td>
        <td>
          <xsl:for-each select="DateFrom">
            <xsl:call-template name="std-template-date">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td class="x-editor-text x-editor-propcaption">Сущность:</td>
        <td >
          <xsl:for-each select="Object">
            <xsl:call-template name="std-template-selector">
              <xsl:with-param name="selector">combo</xsl:with-param>
              <xsl:with-param name="empty-value-text">(Укажите тип сущности)</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td class="x-editor-text x-editor-propcaption">Данные:</td>
        <td>
          <xsl:for-each select="Data">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td class="x-editor-text x-editor-propcaption">По:</td>
        <td>
          <xsl:for-each select="DateTo">
            <xsl:call-template name="std-template-date">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td class="x-editor-text x-editor-propcaption">Действие:</td>
        <td >
          <xsl:for-each select="Action">
            <xsl:call-template name="std-template-selector">
              <xsl:with-param name="selector">combo</xsl:with-param>
              <xsl:with-param name="empty-value-text">(Укажите действие)</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td /> 
        <td class="x-editor-text x-editor-propcaption">Инициатор:</td>
        <td>
          <xsl:for-each select="Initiator">
            <xsl:call-template name="std-template-object">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td class="x-editor-text x-editor-propcaption">ID:</td>
        <td colspan="3">
          <xsl:for-each select="OID">
            <xsl:call-template name="std-template-string">
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
