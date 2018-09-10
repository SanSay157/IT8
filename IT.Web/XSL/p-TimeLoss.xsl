<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	Страница редактора "Списания времени" (TimeSpent) 
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

<xsl:template match="TimeLoss">
<TABLE BORDER="0" CELLSPACING="4" CELLPADDING="0" WIDTH="100%" HEIGHT="100%">
	<COL WIDTH="20%"/>
	<COL/>
	<COL/>
	<COL/>
	<TBODY>
		<xsl:for-each select="Worker[not(@read-only)]">
			<TR>
				<TD class="x-editor-text x-editor-propcaption">Сотрудник:</TD>
				<TD COLSPAN="3">
					<xsl:call-template name="std-template-object" />
				</TD>
			</TR>
		</xsl:for-each>
		<xsl:if test="not (@new)">
			<xsl:for-each select="Worker[(@read-only)]">
				<TR>
					<TD class="x-editor-text x-editor-propcaption">Сотрудник:</TD>
					<TD COLSPAN="3">
						<xsl:call-template name="std-template-object">
							<xsl:with-param name="disabled" select="'1'" />
							<xsl:with-param name="maybenull" select="'1'" />
						</xsl:call-template>

					</TD>
				</TR>
			</xsl:for-each>
		</xsl:if>
		
		<!-- При создании нового объекта покажем радиокнопки с возможностью списания диапазона -->
		<xsl:if test="current()/@new">
		<TR>
			<TD>
				<INPUT id="LostTimeByDate" CHECKED="1" type="radio" value="1" name="LostTimeType"/>
				<LABEL for="LostTimeByDate"><B>На дату</B></LABEL>
			</TD>
			<TD COLSPAN="3"/>
		</TR>
		<TR>
			<TD align="right" class="x-editor-text x-editor-propcaption">Дата списания:</TD>
			<TD>
				<xsl:for-each select="LossFixed">
					<xsl:call-template name="std-template-date" />
				</xsl:for-each>
			</TD>
			<TD class="x-editor-text x-editor-propcaption">Количество времени:</TD>
			<TD>
				<xsl:for-each select="LostTime">
					<xsl:call-template name="it-template-time-edit-button">
						<xsl:with-param name="width" select="200"/>
					</xsl:call-template>
				</xsl:for-each>
			</TD>
		</TR>
		<TR>
			<TD>
				<INPUT id="LostTimeByPeriod" type="radio" value="2" name="LostTimeType"/>
				<LABEL for="LostTimeByPeriod"><b>Период времени</b></LABEL>
			</TD>
			<TD COLSPAN="3"/>
		</TR>
		<TR>
			<TD/>
			<TD COLSPAN="3">
				<TABLE CELLSPACING="0" CELLPADDING="0">
				<TR>
					<TD>c:</TD>
					<TD>
						<xsl:for-each select="LossFixedStart">
							<xsl:call-template name="std-template-date" />
						</xsl:for-each>
					</TD>
					<TD>по:</TD>
					<TD>
						<xsl:for-each select="LossFixedEnd">
							<xsl:call-template name="std-template-date" />
						</xsl:for-each>
					</TD>
				</TR>
				</TABLE>
			</TD>
		</TR>
		</xsl:if>
		<!-- При редактировании можно только изменять дату и количество времени -->
		<xsl:if test="not(current()/@new)">
			<TD class="x-editor-text x-editor-propcaption">Дата списания:</TD>
			<TD>
				<xsl:for-each select="LossFixed">
					<xsl:call-template name="std-template-date" />
				</xsl:for-each>
			</TD>
			<TD class="x-editor-text x-editor-propcaption">Количество времени:</TD>
			<TD>
				<xsl:for-each select="LostTime">
					<xsl:call-template name="it-template-time-edit-button">
						<xsl:with-param name="width" select="200"/>
					</xsl:call-template>
				</xsl:for-each>
			</TD>
		</xsl:if>
		
		<!-- далее общие поля -->
		<xsl:for-each select="Cause">
			<TR>
				<TD class="x-editor-text x-editor-propcaption">Причина:</TD>
				<TD COLSPAN="3">
					<xsl:call-template name="std-template-object-dropdown">
						<xsl:with-param name="empty-value-text" select="'&lt;&lt;Выберите причину&gt;&gt;'"/>
						<xsl:with-param name="list-metaname" select="'AvailableTimeLossCauses'"/>
					</xsl:call-template>
				</TD>
			</TR>
		</xsl:for-each>
		<xsl:for-each select="Folder">
			<TR>
				<TD class="x-editor-text x-editor-propcaption">Проект/тендер/пресейл:</TD>
				<TD COLSPAN="3">
					<xsl:call-template name="std-template-object" />
				</TD>
			</TR>
		</xsl:for-each>
		<xsl:for-each select="Descr">
			<TR>
				<TD class="x-editor-text x-editor-propcaption" valign="top">Комментарий:</TD>
				<TD COLSPAN="3">
					<xsl:call-template name="std-template-text">
						<xsl:with-param name="minheight" select="60" />
					</xsl:call-template>
				</TD>
			</TR>
		</xsl:for-each>
		<TR>
			<TD height="100%" colspan="4"/>
		</TR>
	</TBODY>
</TABLE>

<SCRIPT language="VBScript" event="onClick" for="LostTimeType">
	ChangeLossType_OnClick
</SCRIPT>

</xsl:template>

<xsl:include href="x-pe-string.xsl"/>
<xsl:include href="x-pe-object.xsl"/>
<xsl:include href="x-pe-datetime.xsl"/>
<xsl:include href="it-pe-time-edit-button.xsl"/>

</xsl:stylesheet>
