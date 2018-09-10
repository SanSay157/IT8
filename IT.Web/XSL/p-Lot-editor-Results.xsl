<?xml version="1.0" encoding="windows-1251"?>
<!--
	===========================================================================
	Редактор лота/однолотового тендера – страница "Результаты"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>

	<!-- Вызывается в случае редактора лота -->
	<xsl:template match="Lot">
		<xsl:call-template name="editor-page-template-Results" />
	</xsl:template>

	<!-- Вызывается в случае редактора однолотового тендера -->
	<xsl:template match="Tender">
		<xsl:for-each select="Lots/Lot[1]">
			<xsl:call-template name="editor-page-template-Results" />
		</xsl:for-each>
	</xsl:template>

	<!-- Шаблон страницы "Результаты" -->
	<xsl:template name="editor-page-template-Results">
		<xsl:variable name="LOT_STATE_PARTICIPATING">2</xsl:variable>
		<xsl:variable name="LOT_STATE_WINNER">5</xsl:variable>
		<xsl:variable name="LOT_STATE_LOSER">6</xsl:variable>
		<xsl:variable name="LOT_STATE_CANCELED">7</xsl:variable>

		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<tr id="trWrongState">
				<xsl:if test="State=$LOT_STATE_PARTICIPATING or State=$LOT_STATE_WINNER or State=$LOT_STATE_LOSER or State=$LOT_STATE_CANCELED">
					<xsl:attribute name="style">display:none</xsl:attribute>
				</xsl:if>
				<td align="center" height="50px" class="x-editor-text x-editor-propcaption">
					<b>Данные этой страницы могут быть заданы только для состояния<br/>'Проигран'</b>
				</td>
			</tr>
			<tr>
				<td>
					<table id="tblWinner" disabled="1" width="100%" cellspacing="2" cellpadding="0">
						<xsl:if test="State=$LOT_STATE_WINNER">
							<xsl:attribute name="class">x-editor-subtable-green</xsl:attribute>
						</xsl:if>
						<tr>
							<td class="x-editor-text x-editor-propcaption">
								<b>Выигрыш:</b>
							</td>
						<tr>
						</tr>
							<td id="tdLotWasGain" align="center">
								<xsl:if test="State=$LOT_STATE_PARTICIPATING or State=$LOT_STATE_WINNER or State=$LOT_STATE_LOSER or State=$LOT_STATE_CANCELED">
									<xsl:attribute name="style">display:none</xsl:attribute>
								</xsl:if>
								<b>ЛОТ ВЫИГРАН</b>
							</td>
						</tr>
					</table>
				</td>
			</tr>

			<tr><td/></tr>

			<tr>
				<td>
					<table id="tblLoser" disabled="1" width="100%" cellspacing="2" cellpadding="0">
						<xsl:if test="State=$LOT_STATE_LOSER">
							<xsl:attribute name="class">x-editor-subtable-red</xsl:attribute>
						</xsl:if>
						<tr>
							<td class="x-editor-text x-editor-propcaption">
								<b>Проигрыш:</b>
							</td>
						</tr>
						<tr>
							<td>
								<table width="100%" cellspacing="2" cellpadding="0">
									<col width="20%"/>
									<col width="80%"/>
									<tr>
										<td class="x-editor-text x-editor-propcaption">Победитель</td>
										<td>
											<select id="selectorWinner" disabled="1" onchange="OnWinnerSelectorChanged" style="width:100%" class="x-editor-control x-editor-dropdown">
												<option>(укажите организацию–победителя конкурса)</option>
												<xsl:for-each select="LotParticipants/LotParticipant[ParticipationType!=1]">
													<option value="{string(@oid)}">
														<xsl:if test="Winner!=0">
															<xsl:attribute name="selected">1</xsl:attribute>
														</xsl:if>
														<xsl:choose>
															<xsl:when test="ParticipantOrganization/Organization/ShortName!=''">
																<xsl:value-of select="ParticipantOrganization/Organization/ShortName"/>
															</xsl:when>
															<xsl:otherwise>
																<xsl:value-of select="ParticipantOrganization/Organization/Name"/>
															</xsl:otherwise>
														</xsl:choose>
													</option>
												</xsl:for-each>
											</select>
										</td>
									</tr>
									<tr>
										<td class="x-editor-text x-editor-propcaption">Причина проигрыша</td>
										<td>
											<xsl:for-each select="LossReason">
												<xsl:call-template name="std-template-object-dropdown">
													<xsl:with-param name="disabled">1</xsl:with-param>
												</xsl:call-template>
											</xsl:for-each>
										</td>
									</tr>
									<tr>
										<td class="x-editor-text x-editor-propcaption">Комментарии к причине проигрыша</td>
										<td>
											<xsl:for-each select="ResultNote">
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
				</td>
			</tr>
			<tr><td/></tr>
		</table>
	</xsl:template>
	<!-- Стандартный шаблон для отображения/модификации произвольных текстовых св-в -->
	<xsl:include href="x-pe-string.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации произвольных числовых св-в -->
	<xsl:include href="x-pe-number.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
	<xsl:include href="x-pe-object.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
	<xsl:include href="x-pe-selector.xsl"/>
</xsl:stylesheet>
