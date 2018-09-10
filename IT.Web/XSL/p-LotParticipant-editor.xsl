<?xml version="1.0" encoding="windows-1251"?>
<!--
	===========================================================================
	Редактор учасника лота
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
  <xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
  <xsl:template match="LotParticipant">
    <xsl:variable name="LOT_STATE_WINNER">5</xsl:variable>
    <xsl:variable name="LOT_STATE_LOSER">6</xsl:variable>

    <table width="100%" border="0" cellspacing="2" cellpadding="0">
      <!-- Информация о тендере -->
      <tr id="trTenderInfo">
        <td>
          <table width="100%" cellspacing="0" cellpadding="0">
            <tr>
              <td class="x-editor-text x-editor-propcaption">
                <b id="captionTenderInfo">Информация о тендере</b>
              </td>
            </tr>
            <tr>
              <td>
                <table width="90%" align="right" cellspacing="2" cellpadding="0">
                  <col width="15%" />
                  <col width="85%" />
                  <tr>
                    <td class="x-editor-text x-editor-propcaption">Номер</td>
                    <td class="x-editor-text x-editor-propcaption">
                      <b>
                        <xsl:value-of select="Lot/Lot/Tender/Tender/Number"/>
                      </b>
                    </td>
                  </tr>
                  <tr>
                    <td class="x-editor-text x-editor-propcaption">Название</td>
                    <td class="x-editor-text x-editor-propcaption">
                      <b>
                        <xsl:value-of select="Lot/Lot/Tender/Tender/Name"/>
                      </b>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </td>
      </tr>
      <!-- Информация о лоте -->
      <tr id="trLotInfo" style="display:none">
        <td>
          <table width="100%" cellspacing="0" cellpadding="0">
            <tr>
              <td class="x-editor-text x-editor-propcaption">
                <b id="captionLotInfo">Информация о лоте</b>
              </td>
            </tr>
            <tr>
              <td>
                <table width="90%" align="right" cellspacing="2" cellpadding="0">
                  <col width="15%" />
                  <col width="85%" />
                  <tr>
                    <td class="x-editor-text x-editor-propcaption">Номер</td>
                    <td class="x-editor-text x-editor-propcaption">
                      <b>
                        <xsl:value-of select="Lot/Lot/Number"/>
                      </b>
                    </td>
                  </tr>
                  <tr>
                    <td class="x-editor-text x-editor-propcaption">Название</td>
                    <td class="x-editor-text x-editor-propcaption">
                      <b>
                        <xsl:value-of select="Lot/Lot/Name"/>
                      </b>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </td>
      </tr>
      <tr />
      <!-- Информация об участнике -->
      <tr>
        <td>
          <table id="tblParticipantInfo" width="100%" cellspacing="2" cellpadding="0">
            <xsl:attribute name="class">
              <xsl:choose>
                <!-- Если лот не в состоянии "Выигран" или "Проигран" -->
                <xsl:when test="Lot/Lot/State!=$LOT_STATE_WINNER and Lot/Lot/State!=$LOT_STATE_LOSER">x-editor-subtable-blue</xsl:when>
                <!-- Иначе ("Выигран" или "Проигран") -->
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="Winner!=0">x-editor-subtable-green</xsl:when>
                    <xsl:when test="Winner=0">x-editor-subtable-red</xsl:when>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <tr>
              <td>
                <table width="100%" cellspacing="2" cellpadding="0">
                  <col width="20%" />
                  <col width="80%" />
                  <tr>
                    <td class="x-editor-text x-editor-propcaption">Организация</td>
                    <td>
                      <xsl:for-each select="ParticipantOrganization">
                        <xsl:call-template name="std-template-object-presentation">
                          <xsl:with-param name="select-symbol">dots</xsl:with-param>
                        </xsl:call-template>
                      </xsl:for-each>
                    </td>
                  </tr>
                  <tr>
                    <td class="x-editor-text x-editor-propcaption">Тип участия</td>
                    <td>
                      <xsl:for-each select="ParticipationType">
                        <xsl:call-template name="std-template-selector">
                          <xsl:with-param name="selector">combo</xsl:with-param>
                        </xsl:call-template>
                      </xsl:for-each>
                    </td>
                  </tr>
                  <tr>
                    <td class="x-editor-text x-editor-propcaption"></td>
                    <td>
                      <xsl:for-each select="Declined">
                        <xsl:call-template name="std-template-bool"/>
                      </xsl:for-each>
                    </td>
                  </tr>
                  <tr>
                    <td colspan="2">
                      <hr align="center"/>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
            <tr>
              <td>
                <table width="100%" cellspacing="2" cellpadding="0">
                  <col width="35%" />
                  <col width="65%" />
                  <tr>
                    <td class="x-editor-text x-editor-propcaption">
                      <b>Итоговый статус участника</b>
                    </td>
                    <td>
                      <select id="StateSelector"
												class="x-editor-control x-editor-const-selector"
												style="width:40%"
												onchange="OnStateChanged">
                        <xsl:choose>
                          <!-- Если лот не в состоянии "Выигран" или "Проигран" -->
                          <xsl:when test="Lot/Lot/State!=$LOT_STATE_WINNER and Lot/Lot/State!=$LOT_STATE_LOSER">
                            <xsl:attribute name="disabled">1</xsl:attribute>
                            <option>(нет результатов по лоту)</option>
                          </xsl:when>
                          <!-- Иначе ("Выигран" или "Проигран") -->
                          <xsl:otherwise>
                            <option value="winner">
                              <!-- если победитель, то выбираем этот пункт -->
                              <xsl:if test="Winner!=0">
                                <xsl:attribute name="selected">1</xsl:attribute>
                              </xsl:if>
                              <xsl:text>Победитель</xsl:text>
                            </option>
                            <option value="loser">
                              <!-- если не победитель, то выбираем этот пункт -->
                              <xsl:if test="Winner=0">
                                <xsl:attribute name="selected">1</xsl:attribute>
                              </xsl:if>
                              <xsl:text>Проигравший</xsl:text>
                            </option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </select>
                    </td>
                  </tr>
                  <tr>
                    <td class="x-editor-text x-editor-propcaption">Сумма предложения участника</td>
                    <td>
                      <xsl:for-each select="TenderParticipantPrice">
                        <xsl:call-template name="tms-template-sum">
                          <xsl:with-param name="select-symbol">dots</xsl:with-param>
                        </xsl:call-template>
                      </xsl:for-each>
                    </td>
                  </tr>
                  <tr>
                    <td class="x-editor-text x-editor-propcaption">Сумма после переторжки</td>
                    <td>
                      <xsl:for-each select="SumTorg1">
                        <xsl:call-template name="tms-template-sum">
                          <xsl:with-param name="select-symbol">dots</xsl:with-param>
                        </xsl:call-template>
                      </xsl:for-each>
                    </td>
                  </tr>
                  <tr>
                    <td class="x-editor-text x-editor-propcaption">Сумма после 2й переторжки</td>
                    <td>
                      <xsl:for-each select="SumTorg2">
                        <xsl:call-template name="tms-template-sum">
                          <xsl:with-param name="select-symbol">dots</xsl:with-param>
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
                    <td class="x-editor-text x-editor-propcaption">Сумма АП участника</td>
                    <td>
                      <xsl:for-each select="TenderParticipantPriceAP">
                        <xsl:call-template name="tms-template-sum">
                          <xsl:with-param name="select-symbol">dots</xsl:with-param>
                        </xsl:call-template>
                      </xsl:for-each>
                    </td>
                  </tr>
                  <tr>
                    <td class="x-editor-text x-editor-propcaption">Сумма АП после переторжки</td>
                    <td>
                      <xsl:for-each select="SumTorg1AP">
                        <xsl:call-template name="tms-template-sum">
                          <xsl:with-param name="select-symbol">dots</xsl:with-param>
                        </xsl:call-template>
                      </xsl:for-each>
                    </td>
                  </tr>
                  <tr>
                    <td class="x-editor-text x-editor-propcaption">Сумма АП после 2й переторжки</td>
                    <td>
                      <xsl:for-each select="SumTorg2AP">
                        <xsl:call-template name="tms-template-sum">
                          <xsl:with-param name="select-symbol">dots</xsl:with-param>
                        </xsl:call-template>
                      </xsl:for-each>
                    </td>
                  </tr>
                  <tr>
                    <td class="x-editor-text x-editor-propcaption">Банковская гарантия</td>
                    <td>
                      <xsl:for-each select="Guarantee">
                        <xsl:call-template name="std-template-object-presentation">
                          <xsl:with-param name="select-symbol">dots</xsl:with-param>
                        </xsl:call-template>
                      </xsl:for-each>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </td>
      </tr>
      <tr />
      <!-- Причины помощи/контактная информация -->
      <tr>
        <td>
          <table  width="100%" cellspacing="0" cellpadding="0">
            <col width="23%" />
            <col width="77%" />
            <tr>
              <td nowrap="1" class="x-editor-text x-editor-propcaption">Причина помощи</td>
              <td>
                <xsl:for-each select="LossReason">
                  <xsl:call-template name="std-template-text">
                    <xsl:with-param name="minheight">80</xsl:with-param>
                    <xsl:with-param name="maxheight">200</xsl:with-param>
                    <xsl:with-param name="disabled">1</xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </td>
            </tr>
            <tr>
              <td nowrap="1" class="x-editor-text x-editor-propcaption">Контактная информация</td>
              <td>
                <xsl:for-each select="HelperContactInfo">
                  <xsl:call-template name="std-template-text">
                    <xsl:with-param name="minheight">80</xsl:with-param>
                    <xsl:with-param name="maxheight">200</xsl:with-param>
                    <xsl:with-param name="disabled">1</xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </xsl:template>

  <!-- Шаблон для отображения/модификации скалярного объектного свойства типа "Сумма" -->
  <xsl:include href="tms-pe-object-sum.xsl"/>
  <!-- Стандартный шаблон для отображения/модификации произвольных текстовых св-в -->
  <xsl:include href="x-pe-string.xsl"/>
  <!-- Стандартный шаблон для отображения/модификации произвольных числовых св-в -->
  <xsl:include href="x-pe-number.xsl"/>
  <!-- Стандартный шаблон для отображения/модификации произвольных св-в  даты и времени-->
  <xsl:include href="x-pe-datetime.xsl"/>
  <!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
  <xsl:include href="x-pe-object.xsl"/>
  <!-- Стандартный шаблон для отображения/модификации произвольных массивных объектных св-в -->
  <xsl:include href="x-pe-objects.xsl"/>
  <!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
  <xsl:include href="x-pe-selector.xsl"/>
  <!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
  <xsl:include href="x-pe-bool.xsl"/>
</xsl:stylesheet>
