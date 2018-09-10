<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	Страница редактор Задания (Task) для создания (и только) объекта
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:user="urn:это_нужно_для_блока_msxsl:script"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	user:off-cache="1"
	>

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>

<xsl:template match="Task">
	<!-- Основная таблица, в которой будут разложены св-ва объекта -->
	<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%" HEIGHT="100%">
		<COL WIDTH="20%"/>
		<COL WIDTH="80%"/>
		<TBODY>
			<xsl:for-each select="Worker">
				<TR>
					<TD valign="top" class="x-editor-text x-editor-propcaption-multiline">Исполнитель:</TD>
					<TD height="100%">
						<xsl:call-template name="std-template-object-list-selector">
							<xsl:with-param name="list-metaname" select="'FolderParticipantsWithRoles'"/>
							<xsl:with-param name="tree-selector-metaname" select="'AnyEmployees'"/>
						</xsl:call-template>
					</TD>
				</TR>
			</xsl:for-each>
			<xsl:for-each select="Role">
				<TR>
					<TD class="x-editor-text x-editor-propcaption">Роль:</TD>
					<TD>
						<xsl:call-template name="std-template-object-dropdown">
							<xsl:with-param name="list-metaname" select="'RolesOfIncidentType'"/>
							<xsl:with-param name="empty-value-text" select="'&lt;&lt;Выберите роль&gt;&gt;'"/>
						</xsl:call-template>
					</TD>
				</TR>
			</xsl:for-each>
			<xsl:for-each select="PlannedTime">
				<TR>
					<TD class="x-editor-text x-editor-propcaption">Запланированное время:</TD>
					<TD>
						<xsl:call-template name="it-template-time-edit-button">
							<xsl:with-param name="width" select="200"/>
						</xsl:call-template>
					</TD>
				</TR>
			</xsl:for-each>
		</TBODY>
	</TABLE>
</xsl:template>

<xsl:include href="x-pe-object-list-selector.xsl"/>
<xsl:include href="x-pe-object.xsl"/>
<xsl:include href="it-pe-time-edit-button.xsl"/>

</xsl:stylesheet>
