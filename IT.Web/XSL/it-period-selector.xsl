<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	Cтраница генерации элементов для выбора периода времени
-->	
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:d="urn:object-editor-access"
	xmlns:b="urn:x-page-builder"
	xmlns:w="urn:editor-window-access"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"	
	>

	<xsl:output 
		method="html" 
		version="4.0" 
		encoding="windows-1251"
		omit-xml-declaration="yes"
		media-type="text/html"/>

	<xsl:template name="it-template-period-selector">
		<table cellspacing="5" cellpadding="1" width="100%" height="23px">
			<tr>
				<td style="width:170px; padding-right:5px;">
					<xsl:for-each select="PeriodType">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
							<xsl:with-param name="no-empty-value">1</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
				<td>
					<div id="divInterval" style="width:100%; text-align:left; display:none;">
						<table cellspacing="5" cellpadding="1">
              <col width="5%" />
              <col width="95%" />
              <tr>
                <td class="x-editor-text x-editor-propcaption">с</td>
                <td>
                  <xsl:for-each select="IntervalBegin">
                    <xsl:call-template name="std-template-date">
                      <xsl:with-param name="format">dd.MM.yyyy</xsl:with-param>
                    </xsl:call-template>
                  </xsl:for-each>
                </td>
              </tr>
              <tr>
								<td class="x-editor-text x-editor-propcaption">по</td>
								<td>
									<xsl:for-each select="IntervalEnd">
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="format">dd.MM.yyyy</xsl:with-param>
										</xsl:call-template>
									</xsl:for-each>
								</td>
							</tr>
						</table>
					</div>
					<div id="divQuarter" style="width:100%; text-align:left; display:none;">
						<table cellspacing="0" cellpadding="0">
							<tr>
								<td class="x-editor-text x-editor-propcaption">квартал</td>
								<td width="70px">
									<xsl:for-each select="Quarter">
										<xsl:call-template name="std-template-selector">
											<xsl:with-param name="selector">combo</xsl:with-param>
											<xsl:with-param name="no-empty-value">1</xsl:with-param>
										</xsl:call-template>
									</xsl:for-each>
								</td>
							</tr>
              <tr>
                <td/>
              </tr>  
						</table>
					</div>
				</td>
			</tr>
		</table>
	</xsl:template>

	<!-- Стандартный шаблон для отображения/модификации произвольных св-в  даты и времени-->
	<xsl:include href="x-pe-datetime.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
	<xsl:include href="x-pe-selector.xsl"/>

</xsl:stylesheet>