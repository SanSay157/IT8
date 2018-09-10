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
    <xsl:variable name="IncDocSum" select="w:it_FormatCurr(sum(//IncDoc/Sum))"/>
    <xsl:variable name="OutDocSum" select="w:it_FormatCurr(sum(//OutDoc/Sum))"/>
    <xsl:variable name="OutContractSum" select="w:it_FormatCurr(sum(//OutContract/Sum))"/>
    <xsl:variable name="OutcomesSum" select="w:it_FormatCurr(sum(//Outcome/Sum))"/>
    <TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="95%">
      <COL WIDTH="25%"/>
      <COL WIDTH="75%"/>
      <TBODY>
        <xsl:for-each select="Project/Folder/Name">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Проект:</NOBR>
            </TD>
            <TD>
              <xsl:call-template name="std-template-string" >
                <xsl:with-param name="readonly" select="'1'" />
                <xsl:with-param name="disabled" select="'1'" />
              </xsl:call-template>
            </TD>
          </TR>
        </xsl:for-each>
        
        <xsl:call-template name="it-Separator-2CS" />

        <xsl:for-each select="Number">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Номер:</NOBR>
            </TD>
            <TD>
              <xsl:if test="@read-only">
                <xsl:call-template name="std-template-string" >
                  <xsl:with-param name="disabled" select="'1'" />
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="not(@read-only)">
                <xsl:call-template name="std-template-string"/>
              </xsl:if>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Sum">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Сумма, руб. с НДС:</NOBR>
            </TD>
            <TD>
              <xsl:if test="@read-only">
                <xsl:call-template name="std-template-number" >
                  <xsl:with-param name="disabled" select="'1'" />
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="not(@read-only)">
                <xsl:call-template name="std-template-number"/>
              </xsl:if>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="MaxCost">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Предельная себестоимость, руб. с НДС:</NOBR>
            </TD>
            <TD>
              <xsl:if test="@read-only">
                <xsl:call-template name="std-template-number" >
                  <xsl:with-param name="disabled" select="'1'" />
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="not(@read-only)">
                <xsl:call-template name="std-template-number"/>
              </xsl:if>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Date">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Дата подписания:</NOBR>
            </TD>
            <TD>
              <xsl:if test="@read-only">
                <xsl:call-template name="std-template-date" >
                  <xsl:with-param name="disabled" select="'1'" />
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="not(@read-only)">
                <xsl:call-template name="std-template-date"/>
              </xsl:if>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:call-template name="it-Separator-2CS" />

        <xsl:for-each select="AvansSum">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Сумма аванса, руб. с НДС:</NOBR>
            </TD>
            <TD>
              <xsl:if test="@read-only">
                <xsl:call-template name="std-template-number" >
                  <xsl:with-param name="disabled" select="'1'" />
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="not(@read-only)">
                <xsl:call-template name="std-template-number"/>
              </xsl:if>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="AvansDate">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Дата оплаты аванса:</NOBR>
            </TD>
            <TD>
              <xsl:if test="@read-only">
                <xsl:call-template name="std-template-date" >
                  <xsl:with-param name="disabled" select="'1'" />
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="not(@read-only)">
                <xsl:call-template name="std-template-date"/>
              </xsl:if>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="AvansPaid">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Аванс оплачен:</NOBR>
            </TD>
            <TD>
              <xsl:if test="@read-only">
                <xsl:call-template name="std-template-bool" >
                  <xsl:with-param name="disabled" select="'1'" />
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="not(@read-only)">
                <xsl:call-template name="std-template-bool"/>
              </xsl:if>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="AvansPayNumber">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Номер поручения:</NOBR>
            </TD>
            <TD>
              <xsl:if test="@read-only">
                <xsl:call-template name="std-template-string" >
                  <xsl:with-param name="disabled" select="'1'" />
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="not(@read-only)">
                <xsl:call-template name="std-template-string"/>
              </xsl:if>
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:call-template name="it-Separator-2CS" />

        <xsl:for-each select="Year">
          <TR>
            <TD class="x-editor-text x-editor-propcaption">
              <NOBR>Отчетный год:</NOBR>
            </TD>
            <TD>
              <xsl:if test="@read-only">
                <xsl:call-template name="std-template-object-dropdown" >
                  <xsl:with-param name="disabled" select="'1'" />
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="not(@read-only)">
                <xsl:call-template name="std-template-object-dropdown"/>
              </xsl:if>
            </TD>
          </TR>
        </xsl:for-each>
      </TBODY>
    </TABLE>


    <TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="95%">
      <TBODY>
        <COL WIDTH="25%"/>
        <COL WIDTH="75%"/>
        <xsl:call-template name="it-Separator-2CS" />
        <TR>
          <TD class="x-editor-text x-editor-propcaption">
            <B STYLE="font:bold 11px;">
              <NOBR> Всего ПРИХОДНЫХ ДОКУМЕНТОВ на сумму: </NOBR>
            </B>
          </TD>
          <TD align="right">
            <B STYLE="color:green;">
              <xsl:value-of select="$IncDocSum"/> с НДС
            </B>
          </TD>
        </TR>
        
        <TR>
          <TD class="x-editor-text x-editor-propcaption">
            <B STYLE="font:bold 11px;">
              <NOBR> Всего РАСХОДНЫХ ДОГОВОРОВ на сумму: </NOBR>
            </B>
          </TD>
          <TD align="right">
            <B STYLE="color:green;">
              <xsl:value-of select="$OutContractSum"/> с НДС
            </B>
          </TD>
        </TR>
        
        <TR>
          <TD class="x-editor-text x-editor-propcaption">
            <B STYLE="font:bold 11px;">
              <NOBR> Всего РАСХОДНЫХ ДОКУМЕНТОВ на сумму: </NOBR>
            </B>
          </TD>
          <TD align="right">
            <B STYLE="color:green;">
              <xsl:value-of select="$OutDocSum"/> с НДС
            </B>
          </TD>
        </TR>
        
        <TR>
          <TD class="x-editor-text x-editor-propcaption">
            <B STYLE="font:bold 11px;">
              <NOBR> Всего РАСХОДОВ БЕЗ ДОКУМЕНТОВ на сумму: </NOBR>
            </B>
          </TD>
          <TD align="right">
            <B STYLE="color:green;">
              <xsl:value-of select="$OutcomesSum"/> с НДС
            </B>
          </TD>
        </TR>
      </TBODY>
    </TABLE>

  </xsl:template>
  <xsl:include href="it-editor-borders.xsl"/>
  <xsl:include href="x-pe-datetime.xsl"/>
  <xsl:include href="x-pe-bool.xsl"/>
  <xsl:include href="x-pe-string.xsl"/>
  <xsl:include href="x-pe-number.xsl"/>
  <xsl:include href="x-pe-object.xsl"/>
  <xsl:include href="x-pe-objects.xsl"/>
  <xsl:include href="x-pe-selector.xsl"/>
</xsl:stylesheet>
