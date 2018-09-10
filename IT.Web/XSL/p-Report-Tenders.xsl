<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	Страница параметров отчета "Лоты и участники конкурсов"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="ReportTenders">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<col width="30%"/>
			<col width="70%"/>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Подача документов:</td>
				<td>
					<xsl:call-template name="it-template-period-selector" />
				</td>
			</tr>
			<tr><td colspan="2"><hr/></td></tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Компания:</td>
				<td>
					<xsl:for-each select="Company">
						<xsl:call-template name="std-template-object-dropdown">
							<xsl:with-param name="select-symbol">dots</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Заказчик:</td>
				<td>
					<xsl:for-each select="TenderCustomer">
						<xsl:call-template name="std-template-object-presentation">
							<xsl:with-param name="select-symbol">dots</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Организатор:</td>
				<td>
					<xsl:for-each select="Organizer">
						<xsl:call-template name="std-template-object-presentation">
							<xsl:with-param name="select-symbol">dots</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Участник:</td>
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
				<td class="x-editor-text x-editor-propcaption">Название тендера</td>
				<td>
					<xsl:for-each select="TenderName">
						<xsl:call-template name="std-template-string" />
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Состояние тендера:</td>
				<td>
					<xsl:for-each select="LotState">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Директор клиента:</td>
				<td>
					<xsl:for-each select="Director">
						<xsl:call-template name="std-template-object-dropdown">
							<xsl:with-param name="select-symbol">dots</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Менеджер клиента:</td>
				<td>
					<xsl:for-each select="Manager">
						<xsl:call-template name="std-template-object-dropdown">
							<xsl:with-param name="select-symbol">dots</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Отрасль заказчика:</td>
				<td>
					<xsl:for-each select="Branch">
						<xsl:call-template name="std-template-object-dropdown">
							<xsl:with-param name="select-symbol">dots</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Тип источника:</td>
				<td>
					<xsl:for-each select="InfoSourceOrigin">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Банковская гарантия:</td>
				<td>
					<xsl:for-each select="GuaranteeType">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
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
			<tr>
				<td class="x-editor-text x-editor-propcaption"></td>
				<td>
					<xsl:for-each select="AnyParticipantType">
						<xsl:call-template name="std-template-bool">
							<xsl:with-param name="label">Любой тип участия</xsl:with-param>
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
