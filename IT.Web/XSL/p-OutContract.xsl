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

  <xsl:template match="OutContract">

      
    <table BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="100%">

      <col width="15"/>
      <col width="85%" />
      <tr>
        <td class="x-editor-text x-editor-propcaption">Контрагент:</td>
        <td>
          <xsl:for-each select="Org">
            <xsl:call-template name="std-template-object">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td class="x-editor-text x-editor-propcaption">Статья бюджета:</td>
        <td>
          <xsl:for-each select="BudgetOut">
            <xsl:call-template name="std-template-object">
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
        <td class="x-editor-text x-editor-propcaption">Примечание:</td>
        <td>
          <xsl:for-each select="Rem">
            <xsl:call-template name="std-template-text">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td/>
        <td>
          <xsl:for-each select="IsVirtual">
            <xsl:call-template name="std-template-bool">
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
        <td class="x-editor-text x-editor-propcaption">Дата:</td>
        <td>
          <xsl:for-each select="Date">
            <xsl:call-template name="std-template-date">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td/>
        <td>
          <xsl:for-each select="Signed">
            <xsl:call-template name="std-template-bool">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td class="x-editor-text x-editor-propcaption">Сумма:</td>
        <td>
          <xsl:for-each select="Sum">
            <xsl:call-template name="std-template-number">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      
      <tr>
        <td class="x-editor-text x-editor-propcaption">Номер:</td>
        <td>
          <xsl:for-each select="Number">
            <xsl:call-template name="std-template-string">
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
          <xsl:for-each select="Company2">
            <xsl:call-template name="std-template-bool">
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
        <td class="x-editor-text x-editor-propcaption">Сумма аванса:</td>
        <td>
          <xsl:for-each select="AvansSum">
            <xsl:call-template name="std-template-number">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td/>
        <td>
          <xsl:for-each select="AvansPaid">
            <xsl:call-template name="std-template-bool">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td class="x-editor-text x-editor-propcaption">Дата аванса:</td>
        <td>
          <xsl:for-each select="AvansDate">
            <xsl:call-template name="std-template-date">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td class="x-editor-text x-editor-propcaption">Номер поручения:</td>
        <td>
          <xsl:for-each select="AvansPayNumber">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <hr align="center"/>
        </td>
      </tr>
      <tr height="150">
        <td valign="top" class="x-editor-text x-editor-propcaption">Документы:</td>
        <td>
          <xsl:for-each select="OutDocs">
            <xsl:call-template name="std-template-objects">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
    
      <tr height="150">
        <td valign="top" class="x-editor-text x-editor-propcaption">Расходы без документов:</td>
        <td>
          <xsl:for-each select="Outcomes">
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
      <tr height="150">
        <td valign="top" class="x-editor-text x-editor-propcaption">Комплектаторы:</td>
        <td>
          <xsl:for-each select="Suppliers">
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
    </table>
  </xsl:template>
  <xsl:include href="x-pe-string.xsl"/>
  <xsl:include href="x-pe-number.xsl"/>
  <xsl:include href="x-pe-datetime.xsl"/>
  <xsl:include href="x-pe-object.xsl"/>
  <xsl:include href="x-pe-objects.xsl"/>
  <xsl:include href="x-pe-bool.xsl"/>
</xsl:stylesheet>
