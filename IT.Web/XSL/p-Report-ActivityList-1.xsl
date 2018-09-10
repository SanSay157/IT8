<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	1-я страница параметров отчета "Список активностей"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="FilterReportActivityList">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<col width="30%"/>
			<col width="70%"/>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Период времени:</td>
				<td>
					<xsl:call-template name="it-template-period-selector" />
				</td>
			</tr>
			<tr><td colspan="2"><hr /></td></tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Выборка активностей:</td>
				<td>
					<xsl:for-each select="ActivitySelection">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
							<xsl:with-param name="no-empty-value">1</xsl:with-param>
							<xsl:with-param name="maybenull">1</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Тип активности:</td>
				<td>
					<xsl:for-each select="FolderType">
						<xsl:call-template name="std-template-flags">
							<xsl:with-param name="horizontal-direction">1</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Статус активности:</td>
				<td>
					<xsl:for-each select="FolderState">
						<xsl:call-template name="std-template-flags">
							<xsl:with-param name="horizontal-direction">1</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr><td colspan="2"><hr /></td></tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Отображаемые колонки:</td>
				<td>
					<table width="100%" border="0" cellspacing="1" cellpadding="0">
						<tr>
							<td>
								<xsl:for-each select="ShowColumnNavisionID">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Идентификатор для Navision</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>
								<xsl:for-each select="ShowColumnProjectManager">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Менеджер проекта</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="ShowColumnProjectAdmin">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Администратор проекта</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>
								<xsl:for-each select="ShowColumnDirector">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Директор клиента</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="ShowColumnNotAssignedRoles">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Не назначенные роли</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr><td colspan="2"><hr /></td></tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Сортировка:</td>
				<td>
					<xsl:for-each select="SortType">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
							<xsl:with-param name="no-empty-value">1</xsl:with-param>
							<xsl:with-param name="maybenull">1</xsl:with-param>
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
							<xsl:with-param name="no-empty-value">1</xsl:with-param>
							<xsl:with-param name="maybenull">1</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr><td colspan="2"><hr /></td></tr>
			<tr>
				<td />
				<td>
					<xsl:for-each select="InsertRestrictions">
						<xsl:call-template name="std-template-bool">
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
	<!-- Стандартный шаблон для отображения/модификации двоичных флагов св-в -->
	<xsl:include href="x-pe-flags.xsl"/>
	<!-- Стандартный шаблон для отображения /модификации массивных объектных св-в в виде дерева с чекбоксами -->
	<xsl:include href="x-pe-objects-tree-selector.xsl"/>
	<!-- Шаблон для отображения/модификации периода времени -->
	<xsl:include href="it-period-selector.xsl"/>
</xsl:stylesheet>
