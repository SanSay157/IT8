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

  <xsl:template match="Contract">
    <xsl:variable name="OutcomeSum" select="w:it_FormatCurr(sum(//Outcome/Sum))"/>
    
    <TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="100%">
      <TBODY>
        <xsl:for-each select="Outcomes">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Все платежи по проекту:</NOBR>
            </TD>
          </TR>
          <TR  HEIGHT="97%" VALIGN="TOP">
            <TD>
              <xsl:if test="@read-only">
                <xsl:call-template name="std-template-objects" >
                  <xsl:with-param name="metaname" select="'AllOutcomesList'"/>
                  <xsl:with-param name="disabled" select="'1'" />
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="not(@read-only)">
                <xsl:call-template name="std-template-objects">
                  <xsl:with-param name="metaname" select="'AllOutcomesList'"/>
                </xsl:call-template>
              </xsl:if>
            </TD>
          </TR>
          <TR  VALIGN="BOTTOM">
            <TD>
              <NOBR>
                <B STYLE="font:bold 11px;">
                  Итого выплачено (в т.ч. планируется выплатить): <B STYLE="font:bold 12px; color:green;">
                    <xsl:value-of select="$OutcomeSum"/> с НДС
                  </B>
                </B>
              </NOBR>
            </TD>
          </TR>
          
        </xsl:for-each>

      </TBODY>
    </TABLE>
  </xsl:template>
  <xsl:include href="it-editor-borders.xsl"/>
  <xsl:include href="x-pe-objects.xsl"/>
</xsl:stylesheet>
