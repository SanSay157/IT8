<?xml version="1.0" encoding="windows-1251"?>
<!--
	===========================================================================
	Редактор лота/однолотового тендера – страница "Финансы"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>

	<!-- Вызывается в случае редактора лота -->
	<xsl:template match="Lot">
		<xsl:call-template name="editor-page-template-Finances" />
	</xsl:template>

	<!-- Вызывается в случае редактора однолотового тендера -->
	<xsl:template match="Tender">
		<xsl:for-each select="Lots/Lot[1]">
			<xsl:call-template name="editor-page-template-Finances" />
		</xsl:for-each>
	</xsl:template>

	<!-- Шаблон страницы "Финансы" -->
	<xsl:template name="editor-page-template-Finances">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<tr>
				<td>
					<table width="100%" cellspacing="4" cellpadding="0" class="x-editor-subtable-green">
						<col width="20%"/>
						<col width="80%"/>
						<tr>
							<td class="x-editor-text x-editor-propcaption">
								<b>Бюджет, определенный заказчиком</b>
							</td>
              <td>
                <xsl:for-each select="CustomerBudget">
                  <xsl:call-template name="tms-template-sum">
                    <xsl:with-param name="select-symbol">dots</xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </td>
						</tr>
						<tr>
              <td class="x-editor-text x-editor-propcaption">
                <b>Все цены</b>
              </td>
              <td>
                <xsl:for-each select="NDS">
                  <xsl:call-template name="std-template-selector">
                    <xsl:with-param name="selector">combo</xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Участие подразделений</td>
			</tr>
			<tr>
				<td>
					<xsl:for-each select="ParticipantDepartments">
						<xsl:call-template name="std-template-objects">
							<xsl:with-param name="height">260</xsl:with-param>
							<xsl:with-param name="off-select">1</xsl:with-param>
							<xsl:with-param name="off-unlink">1</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td>
					<table width="100%" cellspacing="2" cellpadding="0" class="x-editor-subtable-blue">
						<tr>
							<td width="100%">
								<table width="100%" border="0" cellspacing="2" cellpadding="0">
									<tr>
										<td width="20%" class="x-editor-text x-editor-propcaption">Банковская гарантия</td>
										<td width="80%">
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
