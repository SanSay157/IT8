<?xml version="1.0" encoding="windows-1251"?>
<!--
	===========================================================================
	Редактор лота - страница "Информация о тендере"
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:user="urn:это_нужно_для_блока_msxsl:script">
	
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>

	<msxsl:script language="VBScript" implements-prefix="user">
	<![CDATA['<%
'==============================================================================
' Возвращает строковое представление суммы
Function GetSumString(curSumValue, sCurrencyCode, dExchangeRate)
	GetSumString = Replace(FormatNumber(curSumValue, 2), ",", ".") _
		& " " & sCurrencyCode _
		& " (" & Replace(CStr(dExchangeRate), ",", ".") & ")"
End Function

'==============================================================================
' Возвращает строковое представление даты
Function GetDateString(xmlDate)
	GetDateString = FormatDateTime(xmlDate.item(0).nodeTypedValue, vbShortDate)
End Function

'==============================================================================
' Возвращает строковое представление даты/времени
Function GetDateTimeString(xmlDate)
	Dim dt
	dt = xmlDate.item(0).nodeTypedValue
	GetDateTimeString = FormatDateTime(dt, vbShortDate) & " " & FormatDateTime(dt, vbShortTime)
End Function
	'%>']]>
	</msxsl:script>

	<xsl:template name="inner-template-label">
		<div>
			<xsl:choose>
				<xsl:when test=".!=''">
					<xsl:attribute name="class">x-editor-text-bold x-editor-propcaption</xsl:attribute>
					<xsl:value-of select="string(.)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="disabled">1</xsl:attribute>
					<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
					<xsl:text>&lt;нет данных&gt;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<xsl:template name="inner-template-sum-label">
		<div>
			<xsl:choose>
				<xsl:when test="Sum">
					<xsl:attribute name="class">x-editor-text-bold x-editor-propcaption</xsl:attribute>
					<xsl:value-of select="user:GetSumString(number(Sum/SumValue), string(Sum/Currency/Currency/Code), number(Sum/ExchangeRate))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
					<xsl:attribute name="disabled">1</xsl:attribute>
					<xsl:text>&lt;нет данных&gt;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<xsl:template name="inner-template-date-label">
		<div>
			<xsl:choose>
				<xsl:when test=".!=''">
					<xsl:attribute name="class">x-editor-text-bold x-editor-propcaption</xsl:attribute>
					<xsl:value-of select="user:GetDateString(current())" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
					<xsl:attribute name="disabled">1</xsl:attribute>
					<xsl:text>&lt;нет данных&gt;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<xsl:template name="inner-template-datetime-label">
		<div>
			<xsl:choose>
				<xsl:when test=".!=''">
					<xsl:attribute name="class">x-editor-text-bold x-editor-propcaption</xsl:attribute>
					<xsl:value-of select="user:GetDateTimeString(current())" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
					<xsl:attribute name="disabled">1</xsl:attribute>
					<xsl:text>&lt;нет данных&gt;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<xsl:template name="inner-template-employee-label">
		<div>
			<xsl:choose>
				<xsl:when test="Employee">
					<xsl:attribute name="class">x-editor-text-bold x-editor-propcaption</xsl:attribute>
					<xsl:value-of select="concat(Employee/LastName, ' ', Employee/FirstName, ' ', Employee/MiddleName)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
					<xsl:attribute name="disabled">1</xsl:attribute>
					<xsl:text>&lt;нет данных&gt;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<xsl:template match="Lot">
		<!-- Так как на странице информация только о тендере, сразу перейдем к узлу тендера -->
		<xsl:for-each select="Tender/Tender">

			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td>
						<table width="100%" cellspacing="3" cellpadding="0">
							<col width="40%" />
							<col width="60%" />
							<tr>
								<td class="x-editor-text x-editor-propcaption">Название</td>
								<td>
									<xsl:for-each select="Name">
										<xsl:call-template name="inner-template-label" />
									</xsl:for-each>
								</td>
							</tr>
							<tr>
								<td class="x-editor-text x-editor-propcaption">Номер</td>
								<td>
									<xsl:for-each select="Number">
										<xsl:call-template name="inner-template-label" />
									</xsl:for-each>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><hr/></td></tr>
				<tr>
					<td>
						<table width="100%" cellspacing="2" cellpadding="0">
							<col width="40%" />
							<col width="60%" />
							<tr>
								<td class="x-editor-text x-editor-propcaption">Заказчик</td>
								<td>
									<xsl:for-each select="TenderCustomer/Organization">
										<xsl:choose>
											<xsl:when test="ShortName!=''">
												<xsl:for-each select="ShortName">
													<xsl:call-template name="inner-template-label" />
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:for-each select="Name">
													<xsl:call-template name="inner-template-label" />
												</xsl:for-each>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</td>
							</tr>
							<tr>
								<td class="x-editor-text x-editor-propcaption">Организатор</td>
								<td>
									<xsl:for-each select="Organizer/Organization">
										<xsl:choose>
											<xsl:when test="ShortName!=''">
												<xsl:for-each select="ShortName">
													<xsl:call-template name="inner-template-label" />
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:for-each select="Name">
													<xsl:call-template name="inner-template-label" />
												</xsl:for-each>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><hr/></td></tr>
				<tr>
					<td>
						<table width="100%" cellspacing="3" cellpadding="0">
							<col width="40%" />
							<col width="60%" />
							<tr>
								<td class="x-editor-text-bold x-editor-propcaption">Дата подачи документов</td>
								<td>
									<xsl:for-each select="DocFeedingDate">
										<xsl:call-template name="inner-template-datetime-label" />
									</xsl:for-each>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><hr/></td></tr>
				<tr>
					<td>
						<table width="100%" cellspacing="3" cellpadding="0">
							<col width="40%" />
							<col width="60%" />
							<tr>
								<td class="x-editor-text x-editor-propcaption">Сотрудник, получивший документы от заказчика</td>
								<td>
									<xsl:for-each select="DocGettingEmployee">
										<xsl:call-template name="inner-template-employee-label" />
									</xsl:for-each>
								</td>
							</tr>
							<tr>
								<td class="x-editor-text x-editor-propcaption">Дата получения документов от заказчика</td>
								<td>
									<xsl:for-each select="CustomerDocGettingDate">
										<xsl:call-template name="inner-template-date-label" />
									</xsl:for-each>
								</td>
							</tr>
							<tr>
								<td class="x-editor-text x-editor-propcaption"><b>Директор клиента</b></td>
								<td>
									<table width="100%" cellspacing="1" cellpadding="0">
										<tr>
											<td>
												<xsl:for-each select="Director">
													<xsl:call-template name="inner-template-employee-label" />
												</xsl:for-each>
											</td>
										</tr>
										<xsl:if test="Director/Employee">
											<tr>
												<td class="x-editor-text x-editor-propcaption">
													
												</td>
											</tr>
										</xsl:if>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><hr/></td></tr>
				<tr>
					<td>
						<table width="100%" cellspacing="3" cellpadding="0">
							<col width="10%" />
							<col width="30%" />
							<col width="60%" />
							<tr>
								<td colspan="3" class="x-editor-text-bold x-editor-propcaption">Контактное лицо конкурсной комиссии</td>
							</tr>
							<tr>
								<td />
								<td class="x-editor-text x-editor-propcaption">Фамилия, Имя, Отчество</td>
								<td>
									<xsl:for-each select="JuryContactName">
										<xsl:call-template name="inner-template-label" />
									</xsl:for-each>
								</td>
							</tr>
							<tr>
								<td />
								<td class="x-editor-text x-editor-propcaption">Контактные телефоны</td>
								<td>
									<xsl:for-each select="JuryContactPhone">
										<xsl:call-template name="inner-template-label" />
									</xsl:for-each>
								</td>
							</tr>
							<tr>
								<td />
								<td class="x-editor-text x-editor-propcaption">Адреса электронной почты</td>
								<td>
									<xsl:for-each select="JuryContactEMail">
										<xsl:call-template name="inner-template-label" />
									</xsl:for-each>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>

		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>
