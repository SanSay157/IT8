<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
-->	
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:XFW="http://www.croc.ru/XmlFramework/Behaviors"
	
	xmlns:w="urn:editor-window-access"
	xmlns:d="urn:object-editor-access"
	xmlns:b="urn:x-page-builder"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"			
	xmlns:user="urn:это_нужно_для_блока_msxsl:script"
	user:off-cache="1"
	>

	<!--
	-->		
	<xsl:template name="it-template-incident-links">
		<!-- xml со всеми параметрами шаблона -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- Параметр: доступность -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- Параметр: описание поля -->
		<xsl:param name="description" select="string($xml-params/@description)"/>
		<!-- Параметр: доступность -->
		<xsl:param name="height" select="b:nvl(string($xml-params/@height),'100%')"/>
		
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>

		<!-- Параметр: доступность -->
		<!-- Параметр: признак допустимости пустого значения -->
		

		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>

		<!-- Таблица редактора массивного объектного свойства -->
		<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" WIDTH="100%" HEIGHT="{$height}">
			<TR>
				<TD HEIGHT="100%" WIDTH="100%" COLSPAN="2">
					<DIV STYLE="position:relative; width:100%; height:100%;" CLASS="x-editor-control x-editor-objects-list">
					<OBJECT 
						ID="{$html-id}"
						NAME="{b:GetUniqueNameFor(current())}"
						CLASSID="{b:Evaluate('CLSID_LIST_VIEW')}" 
						BORDER="0" TABINDEX="0"
						WIDTH="100%" HEIGHT="100%"
						
						X_PROPERTY_EDITOR = "PEIncidentLinksClass"
						X_DISABLED="{$disabled+1}"
						X_DESCR = "{$description}"
						X_IgnoreHtmlEvents = "1"
					>
						<PARAM NAME="Enabled" VALUE="0"></PARAM>
						<PARAM NAME="ShowBorder" VALUE="0"></PARAM>
					</OBJECT>
					<SCRIPT for="{$html-id}" event="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" language="VBScript">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").OnKeyUp nKeyCode, nFlags
					</SCRIPT>
					<SCRIPT for="{$html-id}" event="OnDblClick(ByVal oSender, ByVal nIndex , ByVal nColumn, ByVal sID)" language="VBScript">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").OnDblClick nIndex, nColumn, sID
					</SCRIPT>
					<SCRIPT FOR="{$html-id}" EVENT="OnRightClick(ByVal oSender, ByVal nIndex, ByVal nColumn, ByVal sID)" LANGUAGE="VBScript">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").OnContextMenu 
					</SCRIPT>
					</DIV>
				</TD>
			</TR>
			<TR>
				<TD/>
				<TD WIDTH="100%" ALIGN="right" NOWRAP="1" CLASS="x-editor-objects-buttons-pane">
					<!-- 
					-->
					<BUTTON 
						ID = "{$html-id}ButtonOperation" 
						NAME = "{b:GetUniqueNameFor(current())}"
						TITLE = "Операции..." 
						CLASS = "x-button x-editor-objects-opbutton"
						DISABLED = "1"
						X_DISABLED="{$disabled+2}"
					>
						Операции <SPAN STYLE="font-family:Webdings">&#54;</SPAN>
					</BUTTON>
					<SCRIPT FOR="{$html-id}ButtonOperation" LANGUAGE="VBScript" event="OnClick">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").ShowMenu
					</SCRIPT>
				</TD>
			</TR>
		</TABLE>
	</xsl:template>
</xsl:stylesheet>
