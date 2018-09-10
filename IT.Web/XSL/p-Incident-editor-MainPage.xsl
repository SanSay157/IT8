<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================


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

<xsl:template match="Incident">
	<CENTER>
		<!-- Основная таблица, в которой будут разложены св-ва объекта -->
		<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="95%">
			<COL WIDTH="10%"/>
			<COL WIDTH="40%"/>
			<COL WIDTH="10%"/>
			<COL WIDTH="40%"/>
			<tbody>
				<xsl:for-each select="Name">
					<tr>
						<td valign="top" class="x-editor-text x-editor-propcaption-notnull">Наименование:</td>
						<td  colspan="3"><xsl:call-template name="std-template-text"/></td>
					</tr>
				</xsl:for-each>
				<tr><td colspan="4"><hr class="x-editor-hr"/></td></tr>
				<TR>
					<TD COLSPAN="2">
						<xsl:for-each select="State">
							<xsl:call-template name="it-template-object-dropdown-changestate">
								<xsl:with-param name="initial-value-title-stmt" select="'item.Name'"/>
								<xsl:with-param name="list-metaname" select="'AvailableStatesOfUserRole'"/>
								<xsl:with-param name="first-column-width" select="'10%'"/>
							</xsl:call-template>
						</xsl:for-each>
					</TD>
					<xsl:if test="w:ShowCategory()">
						<xsl:for-each select="Category">
							<TD valign="Top" class="x-editor-text x-editor-propcaption" nowrap="nowrap">Категория:</TD>
							<TD valign="Top">
								<xsl:call-template name="std-template-object"/>
							</TD>
						</xsl:for-each>
					</xsl:if>
				</TR>
				<tr><td colspan="4"><hr class="x-editor-hr"/></td></tr>
				<tr>
					<xsl:for-each select="Priority">
						<xsl:call-template name="it-template-incident-priority"/>
					</xsl:for-each>
					<xsl:for-each select="DeadLine">
						<xsl:call-template name="it-template-incident-deadline"/>
					</xsl:for-each>
				</tr>
				<tr><td colspan="4"><hr class="x-editor-hr"/></td></tr>
			</tbody>
			<TBODY id="tbodyUserHours" style="display:{w:getUserHoursVisibility()};">
				<TR>
					<TD class="x-editor-text x-editor-propcaption-notnull">Затрачено:</TD>
					<TD><BUTTON style="width:80%" id="UserHoursSpent" onClick="editUserHoursSpent" language="VBScript" class="x-editor-button_time"></BUTTON></TD>
					<TD class="x-editor-text x-editor-propcaption-notnull">Осталось:</TD>
					<TD><BUTTON style="width:80%" id="UserHoursLeft" onClick="editUserHoursLeft" language="VBScript" class="x-editor-button_time"></BUTTON></TD>
				</TR>
				<TR><TD colspan="4"><hr class="x-editor-hr"/></TD></TR>
			</TBODY>				
			<TBODY>
				<xsl:for-each select="Tasks">
					<TR style="height:100px;">
						<TD class="x-editor-text x-editor-propcaption" nowrap="nowrap">Задания:</TD>
						<TD colspan="3">
							<xsl:call-template name="std-template-objects"/>
						</TD>
					</TR>
				</xsl:for-each>
				<xsl:for-each select="Descr">
					<TR><TD colspan="4"><hr class="x-editor-hr"/></TD></TR>
					<TR>
						<TD valign="top" class="x-editor-text x-editor-propcaption-notnull">Описание:</TD>
						<TD  colspan="3">
							<xsl:call-template name="std-template-text">
								<xsl:with-param name="minheight">80</xsl:with-param>
								<xsl:with-param name="maxheight">200</xsl:with-param>
							</xsl:call-template>
						</TD>
					</TR>
				</xsl:for-each>				
				<xsl:for-each select="Solution">
					<TR><TD colspan="4"><hr class="x-editor-hr"/></TD></TR>
					<TR><TD valign="top" class="x-editor-text" id="oIncidentLinksCaption"/><TD colspan="3" id="oIncidentLinksPlaceHolder"></TD></TR>
					<TR>
						<td valign="top" class="x-editor-text x-editor-propcaption-notnull">Решение:</td>
						<td  colspan="3">
							<xsl:call-template name="std-template-text">
								<xsl:with-param name="minheight">80</xsl:with-param>
								<xsl:with-param name="maxheight">200</xsl:with-param>
							</xsl:call-template>
						</td>
					</TR>
				</xsl:for-each>
				
			</TBODY>				
		</TABLE>
	</CENTER>
</xsl:template>

<!-- шаблон для отображения дополнительных свойств инцидента -->
<xsl:import href="it-Incident-Props.xsl"/>
<xsl:import href="x-pe-object.xsl"/>
<xsl:include href="it-pe-object-dropdown-ChangeState.xsl"/>
<xsl:include href="it-pe-incident-links.xsl"/>

</xsl:stylesheet>
