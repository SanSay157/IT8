<?xml version="1.0" encoding="windows-1251"?>
<!--
	===========================================================================
	Редактор однолотового тендера – страница "Участники"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">

	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>

	<xsl:template match="DepartmentParticipation">
		<table width="100%" border="0" cellspacing="2" cellpadding="0">
			<tr>
				<td>
					<table width="100%" border="0" cellspacing="2" cellpadding="0">
						<tr>
							<td width="20%" class="x-editor-text x-editor-propcaption">Подразделение</td>
							<td width="80%">
								<xsl:for-each select="Department">
									<xsl:call-template name="std-template-object-presentation">
										<xsl:with-param name="use-tree-selector">FriendlyDepartments</xsl:with-param>
										<xsl:with-param name="off-create">1</xsl:with-param>
										<xsl:with-param name="off-edit">1</xsl:with-param>
										<xsl:with-param name="off-delete">1</xsl:with-param>
										<xsl:with-param name="select-symbol">dots</xsl:with-param>
									</xsl:call-template>
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
							<td colspan="4" class="x-editor-text x-editor-propcaption">Исполнитель от подразделения</td>
						</tr>
						<tr>
							<td width="5%" />
							<td width="55%">
								<xsl:for-each select="Executor">
									<xsl:call-template name="std-template-object-presentation">
										<xsl:with-param name="use-tree-selector">DepartmentEmployees</xsl:with-param>
										<xsl:with-param name="off-create">1</xsl:with-param>
										<xsl:with-param name="off-edit">1</xsl:with-param>
										<xsl:with-param name="off-delete">1</xsl:with-param>
										<xsl:with-param name="select-symbol">dots</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td width="20%" align="center">
								<xsl:for-each select="ExecutorIsAcquaint">
									<xsl:call-template name="std-template-bool">
										<xsl:with-param name="label">ознакомился, </xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
							<td width="20%" align="right">
								<xsl:for-each select="DocsGettingDate">
									<xsl:call-template name="std-template-date"/>
								</xsl:for-each>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr><td><hr/></td></tr>
			<tr>
				<td>
					<table width="100%" border="0" cellspacing="2" cellpadding="0">
						<tr>
							<td colspan="2" class="x-editor-text x-editor-propcaption">Примечание</td>
						</tr>
						<tr>
							<td width="5%"/>
							<td width="95%">
								<xsl:for-each select="Note">
									<xsl:call-template name="std-template-text">
										<xsl:with-param name="minheight">80</xsl:with-param>
										<xsl:with-param name="maxheight">200</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</xsl:template>

	<!-- Стандартный шаблон для отображения/модификации произвольных текстовых св-в -->
	<xsl:include href="x-pe-string.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
	<xsl:include href="x-pe-object.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации произвольных св-в  даты и времени-->
	<xsl:include href="x-pe-datetime.xsl"/>
	<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
	<xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
