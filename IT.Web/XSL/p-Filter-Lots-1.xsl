<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	Первая страница для фильтра списка лотов ("Основные параметры")
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt">

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>
	
<xsl:template match="FilterLotsList">
	<table cellspacing="2" cellpadding="0" class="x-layoutgrid x-filter-layoutgrid">
      <col width="13%" />
      <col width="25%" />
      <!-- Колонка - вертикальный разделитель -->
      <col width="3%" />
      <col width="13%" />
      <col width="27%" />
      <!-- Колонка - вертикальный разделитель -->
      <col width="3%" />
      <col width="3%" />
      <col width="13%" />
      <tr>
        <td class="x-editor-text x-editor-propcaption">Заказчик:</td>
        <td>
          <xsl:for-each select="CustomerName">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td class="x-editor-text x-editor-propcaption">
          <b>Участник:</b>
        </td>
        <td>
          <xsl:for-each select="Company">
            <xsl:call-template name="std-template-object-dropdown">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td colspan="2" class="x-editor-text x-editor-propcaption">Подача документов</td>
      </tr>
      <tr >
        <td class="x-editor-text x-editor-propcaption">Организатор:</td>
        <td>
          <xsl:for-each select="OrganizerName">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td class="x-editor-text x-editor-propcaption">Конкурент:</td>
        <td>
          <xsl:for-each select="Competitor">
            <xsl:call-template name="std-template-object-presentation" />
          </xsl:for-each>
        </td>
        <td />
        
        <!-- Начало подачи документов -->
        <td class="x-editor-text x-editor-propcaption">c:</td>
        <td>
          <xsl:for-each select="DocFeedingBegin">
            <xsl:call-template name="std-template-date">
              <xsl:with-param name="format">dd.MM.yyyy</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr >
        <td class="x-editor-text x-editor-propcaption">Название лота:</td>
        <td>
          <xsl:for-each select="LotName">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td class="x-editor-text x-editor-propcaption">Состояние лота:</td>
        <td>
          <xsl:for-each select="State">
            <xsl:call-template name="std-template-selector">
              <xsl:with-param name="selector">combo</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <!-- Окончание подачи документов -->
        <td class="x-editor-text x-editor-propcaption">по:</td>
        <td style="padding-bottom:5px;">
          <xsl:for-each select="DocFeedingEnd">
            <xsl:call-template name="std-template-date">
              <xsl:with-param name="format">dd.MM.yyyy</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td colspan="8" style="border:#fff groove 2px; border-width:2px 0px 0px 0px; padding-top:3px;">
          <xsl:for-each select="IsStrictStateCalc">
            <xsl:call-template name="std-template-bool">
              <xsl:with-param name="label">Учитывать итоговый статус указанной Компании при определении статуса конкурсов</xsl:with-param>
              <xsl:with-param name="disabled" select="'1'" />
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
    </table>
</xsl:template>

<!-- Стандартный шаблон для отображения/модификации произвольных текстовых св-в -->
<xsl:include href="x-pe-string.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных св-в  даты и времени-->
<xsl:include href="x-pe-datetime.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
<xsl:include href="x-pe-object.xsl"/>
<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
<xsl:include href="x-pe-selector.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
<xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
