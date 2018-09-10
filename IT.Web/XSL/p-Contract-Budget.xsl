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
    <xsl:variable name="BudgetOutsSum" select="w:it_FormatCurr(sum(//BudgetOut/Sum))"/>
    <xsl:variable name="OutLimitsSum" select="w:it_FormatCurr(sum(//OutLimit/Sum))"/>
    <xsl:variable name="AOLimitsSum" select="w:it_FormatCurr(sum(//AOLimit/Sum))"/>
    <TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="100%">
      <col width="30%" />
      <col width="70%" />

      <xsl:for-each select="BudgetOuts">
        <TR>
          <TD colspan="2" valign="top" class="x-editor-text x-editor-propcaption">
            <NOBR>Забюджетированные проектные расходы:</NOBR>
          </TD>
        </TR>
        <TR height="300">
          <TD colspan="2">
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
        <TR>
          <TD>
            <NOBR>
              <B STYLE="font:bold 11px;">
                Итого: <B STYLE="font:bold 12px; color:green;">
                  <xsl:value-of select="$BudgetOutsSum"/> с НДС
                </B>
              </B>
            </NOBR>
          </TD>
        </TR>
      </xsl:for-each>
      <xsl:call-template name="it-Separator-2CS" />

      <tr>
        <td class="x-editor-text x-editor-propcaption">Состояние бюджета проекта:</td>
        <td>
          <xsl:for-each select="BudgetState">
            <xsl:call-template name="std-template-selector">
              <xsl:with-param name="selector">combo</xsl:with-param>
              <xsl:with-param name="no-empty-value">0</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <xsl:call-template name="it-Separator-2CS" />

      <xsl:for-each select="OutLimits">
        <TR>
          <TD colspan="2" class="x-editor-text x-editor-propcaption">
            <NOBR>Лимиты по расходам:</NOBR>
          </TD>
        </TR>
        <TR height="180">
          <TD colspan="2">
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
        <TR>
          <TD>
            <NOBR>
              <B STYLE="font:bold 11px;">
                Итого: <B STYLE="font:bold 12px; color:green;">
                  <xsl:value-of select="$OutLimitsSum"/> с НДС
                </B>
              </B>
            </NOBR>
          </TD>
        </TR>
      </xsl:for-each>

      <xsl:call-template name="it-Separator-2CS" />

      <xsl:for-each select="AOLimits">
        <TR>
          <TD colspan="2" class="x-editor-text x-editor-propcaption">
            <NOBR>Лимиты по АО:</NOBR>
          </TD>
        </TR>
        <TR height="180">
          <TD colspan="2">
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
        <TR>
          <TD>
            <NOBR>
              <B STYLE="font:bold 11px;">
                Итого: <B STYLE="font:bold 12px; color:green;">
                  <xsl:value-of select="$AOLimitsSum"/> с НДС
                </B>
              </B>
            </NOBR>
          </TD>
        </TR>
      </xsl:for-each>

      
    </TABLE>
  </xsl:template>
  <xsl:include href="it-editor-borders.xsl"/>
  <xsl:include href="x-pe-objects.xsl"/>
  <xsl:include href="x-pe-selector.xsl"/>
</xsl:stylesheet>
