<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	6-я страница параметров отчета "Список инцидентов и затрат проекта"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="FilterReportProjectIncidentsAndExpenses">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<col width="30%"/>
			<col width="70%"/>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Отображаемые колонки:</td>
				<td>
					<table width="100%" border="0" cellspacing="1" cellpadding="0">
						<tr>
							<td>
								<xsl:for-each select="ShowColumnSolution">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Решение</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="ShowColumnDescription">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Описание</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>
								<xsl:for-each select="ShowColumnState">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Состояние</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="ShowColumnPriority">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Приоритет</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>
								<xsl:for-each select="ShowColumnDeadLine">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Крайний срок</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="ShowColumnInputDate">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Дата открытия</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>
								<xsl:for-each select="ShowColumnLastChange">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Последняя смена состояния</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="ShowColumnLastSpent">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Последняя затрата времени</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>
								<xsl:for-each select="ShowColumnRole">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Роль</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="ShowColumnEmployee">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Сотрудник</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>
								<xsl:for-each select="ShowColumnPlannedTime">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Запланировано</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="ShowColumnSpentTime">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Общие трудозатраты</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>
								<xsl:for-each select="ShowColumnLeftTime">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">Осталось</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td />
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
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="x-editor-text x-editor-propcaption">Единицы измерения времени:</td>
				<td>
					<xsl:for-each select="TimeMeasureUnits">
						<xsl:call-template name="std-template-selector">
							<xsl:with-param name="selector">combo</xsl:with-param>
							<xsl:with-param name="no-empty-value">1</xsl:with-param>
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
	<!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
	<xsl:include href="x-pe-object.xsl"/>
	<!-- Стандартный шаблон для отображения /модификации массивных объектных св-в в виде дерева с чекбоксами -->
	<xsl:include href="x-pe-objects-tree-selector.xsl"/>
	<!-- Шаблон для отображения/модификации периода времени -->
	<xsl:include href="it-period-selector.xsl"/>
</xsl:stylesheet>
