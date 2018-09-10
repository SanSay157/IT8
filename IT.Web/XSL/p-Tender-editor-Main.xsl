<?xml version="1.0" encoding="windows-1251"?>
<!--
	===========================================================================
	Редактор однолотового тендера – страница "Основные реквизиты"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="Tender">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<!-- Вложенная таблица первого уровня -->
			<tr>
				<td>
					<table width="100%" cellspacing="2" cellpadding="0" class="x-editor-subtable-yellow">
						<col width="100%" />
						<!-- Секция данных о клиенте -->
						<tr>
							<td>
								<table width="100%" border="0" cellspacing="2" cellpadding="0">
									<tr>
										<td width="20%" class="x-editor-text x-editor-propcaption">Основной участник</td>
										<td width="80%">
											<xsl:for-each select="Lots/Lot[1]/LotParticipants/LotParticipant[ParticipationType=1]/ParticipantOrganization">
												<xsl:call-template name="std-template-object-dropdown">
													<xsl:with-param name="list-metaname">OwnTenderParticipants</xsl:with-param>
												</xsl:call-template>
											</xsl:for-each>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<!-- Вложенная таблица второго уровня -->
						<tr>
							<td>
								<table width="100%" cellspacing="0" cellpadding="0">
									<tr>
										<td>
											<table width="100%" cellspacing="2" cellpadding="0" style="border-width:1px 1px 0px 1px" class="x-editor-subtable-green">
												<!-- Секция данных о лоте / тендере	-->
												<tr>
													<td>
														<table width="100%" border="0" cellspacing="2" cellpadding="0">
															<col width="20%"/>
															<col width="80%"/>
															<!-- Заказчик -->
															<tr>
																<td class="x-editor-text x-editor-propcaption">Заказчик</td>
																<td>
																	<xsl:for-each select="TenderCustomer">
																		<xsl:call-template name="std-template-object-presentation">
																			<xsl:with-param name="select-symbol">dots</xsl:with-param>
																		</xsl:call-template>
																	</xsl:for-each>
																</td>
															</tr>
															<!-- Организатор -->
															<tr>
																<td class="x-editor-text x-editor-propcaption">Организатор</td>
																<td>
																	<xsl:for-each select="Organizer">
																		<xsl:call-template name="std-template-object-presentation">
																			<xsl:with-param name="select-symbol">dots</xsl:with-param>
																		</xsl:call-template>
																	</xsl:for-each>
																</td>
															</tr>
															<!-- Номер -->
															<tr>
																<td class="x-editor-text x-editor-propcaption">Номер</td>
																<td>
																	<xsl:for-each select="Number">
																		<xsl:call-template name="std-template-string"/>
																	</xsl:for-each>
																</td>
															</tr>
															<!-- Название -->
															<tr>
																<td class="x-editor-text x-editor-propcaption">Название</td>
																<td>
																	<xsl:for-each select="Name">
																		<xsl:call-template name="std-template-string"/>
																	</xsl:for-each>
																</td>
															</tr>
														</table>
													</td>
												</tr>
												<tr>
													<td>
														<table width="100%" border="0" cellspacing="2" cellpadding="0">
															<tr>
																
                                <!-- Дата подачи документов -->
																<td width="23%" align="right" class="x-editor-text x-editor-propcaption">
																	<b>Дата подачи документов</b>
																</td>
																<td width="10%" align="right">
																	<xsl:for-each select="DocFeedingDate">
																		<xsl:call-template name="std-template-date">
																			<xsl:with-param name="vt">dateTime</xsl:with-param>
																		</xsl:call-template>
																	</xsl:for-each>
																</td>

                                <!-- Дата переторжки -->
                                <td width="23%" align="right" class="x-editor-text x-editor-propcaption">
                                  <b>Дата переторжки</b>
                                </td>
                                <td width="10%" align="right">
                                  <xsl:for-each select="DateTorg1">
                                    <xsl:call-template name="std-template-date">
                                      <xsl:with-param name="vt">dateTime</xsl:with-param>
                                    </xsl:call-template>
                                  </xsl:for-each>
                                </td>

                                <!-- Дата 2й переторжки -->
                                <td width="23%" align="right" class="x-editor-text x-editor-propcaption">
                                  <b>Дата 2й переторжки</b>
                                </td>
                                <td width="150%" align="right">
                                  <xsl:for-each select="DateTorg2">
                                    <xsl:call-template name="std-template-date">
                                      <xsl:with-param name="vt">dateTime</xsl:with-param>
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
									<tr>
										<td>
											<table width="100%" cellspacing="2" cellpadding="0" style="border-width:1px 1px 0px 1px" class="x-editor-subtable-blue">
												<!-- Секция данных о нашем участии в тендере -->
												<tr>
													<td>
														<table width="100%" border="0" cellspacing="2" cellpadding="0">
															<tr>
																<!-- Состояние -->
																<td width="30%" class="x-editor-text x-editor-propcaption">Состояние</td>
																<td width="70%">
																	<xsl:for-each select="Lots/Lot[1]/State">
																		<xsl:call-template name="std-template-selector">
																			<xsl:with-param name="selector">combo</xsl:with-param>
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
									<tr>
										<td>
											<table width="100%" cellspacing="2" cellpadding="0" class="x-editor-subtable-yellow">
												<!-- Секция данных о нашей организации -->
												<tr>
													<td>
														<table width="100%" border="0" cellspacing="2" cellpadding="0">
															<col width="30%" />
															<col width="40%" />
															<col width="15%" align="right" />
															<col width="15%" align="right" />
                              
															<!-- Директор клиента -->
															<tr>
																<td class="x-editor-text x-editor-propcaption">Директор клиента</td>
																<td >
																	<xsl:for-each select="Director">
																		<xsl:call-template name="std-template-object-presentation">
																			<xsl:with-param name="use-tree-selector">AnyEmployees</xsl:with-param>
																			<xsl:with-param name="off-create">1</xsl:with-param>
																			<xsl:with-param name="off-edit">1</xsl:with-param>
																			<xsl:with-param name="off-delete">1</xsl:with-param>
																			<xsl:with-param name="select-symbol">dots</xsl:with-param>
																		</xsl:call-template>
																	</xsl:for-each>
																</td>
                                <td colspan="3"/>
															</tr>
                              
															<!-- Менеджер проекта -->
															<tr>
																<td class="x-editor-text x-editor-propcaption">Менеджер проекта</td>
																<td>
																	<xsl:for-each select="Lots/Lot[1]/Manager">
																		<xsl:call-template name="std-template-object-presentation">
																			<xsl:with-param name="use-tree-selector">AnyEmployees</xsl:with-param>
																			<xsl:with-param name="off-create">1</xsl:with-param>
																			<xsl:with-param name="off-edit">1</xsl:with-param>
																			<xsl:with-param name="off-delete">1</xsl:with-param>
																			<xsl:with-param name="select-symbol">dots</xsl:with-param>
																		</xsl:call-template>
																	</xsl:for-each>
																</td>
																<td>
																	<xsl:for-each select="Lots/Lot[1]/MgrIsAcquaint">
																		<xsl:call-template name="std-template-bool">
																			<xsl:with-param name="label">ознакомился, </xsl:with-param>
																		</xsl:call-template>
																	</xsl:for-each>
																</td>
																<td>
																	<xsl:for-each select="Lots/Lot[1]/MgrDocsGettingDate">
																		<xsl:call-template name="std-template-date"/>
																	</xsl:for-each>
																</td>
															</tr>
                              
                              <!-- Сотрудник, получивший документы от заказчика -->
                              <tr>
                                <td class="x-editor-text x-editor-propcaption">Сотрудник, получивший документы</td>
                                <td>
                                  <xsl:for-each select="DocGettingEmployee">
                                    <xsl:call-template name="std-template-object-presentation">
                                      <xsl:with-param name="use-tree-selector">AnyEmployees</xsl:with-param>
                                      <xsl:with-param name="off-create">1</xsl:with-param>
                                      <xsl:with-param name="off-edit">1</xsl:with-param>
                                      <xsl:with-param name="off-delete">1</xsl:with-param>
                                      <xsl:with-param name="select-symbol">dots</xsl:with-param>
                                    </xsl:call-template>
                                  </xsl:for-each>
                                </td>
                                <td class="x-editor-text x-editor-propcaption">дата получения</td>
                                <td>
                                  <xsl:for-each select="CustomerDocGettingDate">
                                    <xsl:call-template name="std-template-date"/>
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
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<!-- Контактное лицо конкурсной комиссии -->
			<tr>
				<td class="x-editor-text x-editor-propcaption">
					<b>Контактное лицо конкурсной комиссии</b>
				</td>
			</tr>
			<tr>
				<td>
					<table width="95%" align="right" border="0" cellspacing="2" cellpadding="0">
						<col width="30%"/>
						<col width="70%"/>
						<!-- Фамилия, Имя, Отчество -->
						<tr>
							<td class="x-editor-text x-editor-propcaption">Фамилия, Имя, Отчество</td>
							<td>
								<xsl:for-each select="JuryContactName">
									<xsl:call-template name="std-template-string"/>
								</xsl:for-each>
							</td>
						</tr>
						<!-- Контактные телефоны -->
						<tr>
							<td class="x-editor-text x-editor-propcaption">Контактные телефоны</td>
							<td>
								<xsl:for-each select="JuryContactPhone">
									<xsl:call-template name="std-template-string"/>
								</xsl:for-each>
							</td>
						</tr>
						<!-- Адреса электронной почты -->
						<tr>
							<td class="x-editor-text x-editor-propcaption">Адрес электронной почты</td>
							<td>
								<xsl:for-each select="JuryContactEMail">
									<xsl:call-template name="std-template-string"/>
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
	<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
	<xsl:include href="x-pe-selector.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
	<xsl:include href="x-pe-bool.xsl"/>
	
</xsl:stylesheet>
