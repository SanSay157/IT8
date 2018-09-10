<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	Стандартная страница генерации элементов  отображения/модификации для логических свойств объекта
-->
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:d="urn:object-editor-access"
	xmlns:b="urn:x-page-builder"
	xmlns:w="urn:editor-window-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"	
	>

	<!--
		=============================================================================================
		Стандартный шаблон генерации элементов  отображения/модификации для логических свойств объекта
		Объекты страницы
			urn:object-editor-access - интерфейс объекта EditorData									
		Обрабатываемый элемент:																		
			Свойство объекта X-Storage
		Входные параметры:
			[in] maybenull		- признак допустимости пустого значения	(0/1)										
			[in] description	- описание поля
			[in] disabled		- признак заблокированного поля
			[in] label			- подпись к полю
		Результат трансформации:
			HTML - код, реализующий интерфейс для элементов отображения/модификации логических свойств объекта
	-->
	<xsl:template name="std-template-bool">
		<!-- xml со всеми параметрами шаблона -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml с металданными -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- Параметр: доступность  -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- Параметр: описание поля  -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description), string($xml-prop-md/@d))"/>
		<!-- Параметр: подпись к полю  -->
		<xsl:param name="label" select="b:nvl(string($xml-params/@label), string($description) )"/>
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		
		<!-- 
			Вставим check-box (изначально заблокированный - он разблокируется на кодом 
			по завершении инициализации)
			
			В качестве идентификатора используем атрибут html-id обрабатываемого
			объектного свойства. Это позволит в дальнейшем сопоставить вставленный 
			элемент с соответсвующим свойством объекта из кода.

			Дополнительный атрибут X_DESCR будет хранить описание свойства, которое
			в общем случае может отличаться от описания в метаданных.
			Этот атрибут позволит получить описание сопоставленного с элементом
			свойства из кода.
		-->
		<INPUT 
			ID="{$html-id}" TYPE="CHECKBOX" DISABLED="1" 			
			NAME="{b:GetUniqueNameFor(current())}"
			X_DESCR = "{$description}"
			X_DISABLED = "{$disabled+1}"
			X_PROPERTY_EDITOR = "XPEBoolClass"
		>
		</INPUT>
		
		<!-- Обычно у CheckBox бывает Label -->
		<!-- ассоциируем элемент Label с элементом CheckBox -->
		<!-- 
			В кач-ве основы для идентификатора используем атрибут html-id обрабатываемого
			объектного св-ва. Это позволит в дальнейшем сопоставить вставленный 
			элемент с соответсвующим свойством объекта из пользовательского кода.
		 -->			
		<LABEL FOR="{$html-id}" ID="{$html-id}Caption" CLASS="x-editor-text x-editor-propcaption-notnull">
			<xsl:value-of select="$label"/>
		</LABEL>
		<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnClick">
			<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnClick
		</SCRIPT>				
		<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnKeyUp">
			<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnKeyUp
		</SCRIPT>				
	</xsl:template>
</xsl:stylesheet>