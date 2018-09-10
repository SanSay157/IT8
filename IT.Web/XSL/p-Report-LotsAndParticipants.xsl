<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	Страница параметров отчета "Лоты и участники конкурсов"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="ReportLotsAndParticipants">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<col width="30%"/>
			<col width="70%"/>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Период времени:</td>
				<td>
					<xsl:call-template name="it-template-period-selector" />
				</td>
			</tr>
			<tr><td colspan="2"><hr/></td></tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Организация-конкурсант:</td>
				<td>
					<xsl:for-each select="Company">
						<xsl:call-template name="std-template-object-presentation">
							<xsl:with-param name="select-symbol">dots</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Организация-заказчик:</td>
				<td>
					<xsl:for-each select="TenderCustomer">
						<xsl:call-template name="std-template-object-presentation">
							<xsl:with-param name="select-symbol">dots</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Организация-участник:</td>
				<td>
					<xsl:for-each select="ParticipantOrganization">
						<xsl:call-template name="std-template-object-presentation">
							<xsl:with-param name="select-symbol">dots</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Тип отношений с участником:</td>
				<td>
					<xsl:for-each select="CompetitorType">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption"></td>
				<td>
					<xsl:for-each select="ExcludeOtherParticipants">
						<xsl:call-template name="std-template-bool" />
					</xsl:for-each>
				</td>
			</tr>
			<tr><td colspan="2"><hr/></td></tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Сортировка:</td>
				<td>
					<xsl:for-each select="SortType">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Порядок сортировки:</td>
				<td>
					<xsl:for-each select="SortOrder">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr><td colspan="2"><hr/></td></tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption"></td>
				<td>
					<xsl:for-each select="InsertResctrictions">
						<xsl:call-template name="std-template-bool" />
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
	<!-- Шаблон для отображения/модификации периода времени -->
	<xsl:include href="it-period-selector.xsl"/>
</xsl:stylesheet>
