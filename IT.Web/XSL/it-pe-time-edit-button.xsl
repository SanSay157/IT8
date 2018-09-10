<?xml version="1.0" encoding="windows-1251"?>
<!--
-->
<xsl:stylesheet
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:user="urn:это_нужно_для_блока_msxsl:script"
	xmlns:d="urn:object-editor-access"
	xmlns:b="urn:x-page-builder"
	xmlns:w="urn:editor-window-access"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"			
	user:off-cache="1"
	>

<xsl:template name="it-template-time-edit-button">
	<!-- xml со всеми параметрами шаблона -->
	<xsl:param name="xml-params" select="*[0!=0]"/>
	<!-- xml с металданными -->
	<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
	<!-- Параметр: доступность -->
	<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
	<!-- Параметр: описание поля -->
	<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
	<!-- Ширина кнопки в пикселях -->
	<xsl:param name="width" select="number(b:nvl(string($xml-params/@width),'50'))"/>
	
	<!-- Параметр: Идентификатор главного Html-контрола для PropertyEditor'a -->
	<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
	<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
	<xsl:variable name="editordata" select="d:UniqueID()"/>
	
	<button 
		ID="{$html-id}" 
		STYLE="width:15em" 
		DISABLED="1"
		WIDTH="{$width}px"
		
		X_PROPERTY_EDITOR = "PETimeEditButtonClass"
		X_DESCR="{$description}" 
		X_DISABLED="{$disabled+1}"
		>
	</button>
	
	<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnClick">
		<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnClick
	</SCRIPT>
</xsl:template>

</xsl:stylesheet>