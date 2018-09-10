<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	Шаблон для отображения значения любого свойства в виде read-only поля.
-->	
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:d="urn:object-editor-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:b="urn:x-page-builder"
	xmlns:w="urn:editor-window-access"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"
	>
	<xsl:template name="it-template-readonly">
		<!-- xml со всеми параметрами шаблона -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml с металданными -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- Параметр: доступность -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- Параметр: описание поля -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
		<!-- VBS-выражение для вычисления значения -->
		<xsl:param name="value-expression" />
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- Параметр: ширина контрола -->
		<xsl:param name="width" select="b:nvl(string($xml-params/@width),'100%')" />
		<!-- признак автоматического изменения тултипа для текстового поля -->
		<xsl:param name="auto-tooltip" select="b:nvl(string($xml-params/@auto-tooltip), '1')"/>

		<INPUT 	
			ID="{$html-id}" 
			X_DESCR="{$description}"
			READONLY="1"
			TYPE="TEXT" DISABLED="1" VALUE="" 
			X_DISABLED = "{$disabled+1}"
			NAME="{b:GetUniqueNameFor(current())}"
			STYLE="width:{$width};"
			CLASS="x-editor-control x-editor-string-field"
			X_PROPERTY_EDITOR = "PEReadOnlyClass"
			ValueExpression="{$value-expression}"
			AutoToolTip="{$auto-tooltip}"
		>
		</INPUT>
	</xsl:template>

</xsl:stylesheet>
