<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	Стандартная страница генерации элементов  отображения/модификации для скалярных свойств объекта
	типа "dateTime.tz", "date", "time.tz"
-->	

<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:d="urn:object-editor-access"
	xmlns:b="urn:x-page-builder"
	xmlns:w="urn:editor-window-access"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"	
	>
	
	<!--
		=============================================================================================
		Стандартный шаблон генерации элементов  отображения/модификации для скалярных свойств объекта
		типа "dateTime", "date", "time"
		Объекты страницы
			urn:object-editor-access - интерфейс объекта EditorData									
		Обрабатываемый элемент:																		
			Свойство объекта X-Storage
		Входные параметры:
			[in] disabled - признак заблокированного поля
			[in] maybenull	- признак допустимости пустого значения	(0/1)										
			[in] description - описание поля
			[in] off-checkbox - признак отключения чекбокса
			[in] format	- Формат отображения										
			[in] up-down - Up-Down у контрола (при использовании указанного пользователем формата)
			[in] vt - тип св-ва (date dateTime time)
			
		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации скалярных свойств объекта 
					типа "dateTime", "date", "time"

		TODO: min/max !!!
	-->	
	<xsl:template name="std-template-date">
		<!-- xml со всеми параметрами шаблона -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml с металданными -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- Параметр: доступность -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- Параметр: признак допустимости пустого значения -->
		<xsl:param name="maybenull" select="b:nvl(string($xml-params/@maybenull), string($xml-prop-md/@maybenull))"/>
		<!-- Параметр: описание поля -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
		<!-- Если параметр задан в 1, то чекбокс у контрола даты не отображается -->
		<xsl:param name="off-checkbox" select="b:nvl(string($xml-params/@off-checkbox), string($xml-prop-md/i:dtpicker/@off-checkbox))"/>
		<!-- Формат отображения -->
		<xsl:param name="format" select="b:nvl(string($xml-params/@format), string($xml-prop-md/i:dtpicker/@format))"/>
		<!-- Up-Down у контрола (при использовании указанного пользователем формата) -->
		<xsl:param name="up-down" select="b:nvl(string($xml-params/@up-down),string($xml-prop-md/i:dtpicker/@up-down))"/>
		<!-- Признак включения автоматического перехода между компонентами даты при вводе с клавиатуры -->
		<xsl:param name="autoshift" select="b:nvl( b:nvl(string($xml-params/@autoshift), string($xml-prop-md/i:dtpicker/@autoshift)), '1')" />
		
		<!-- Тип свойства -->
		<xsl:param name="vt" select="b:nvl(string($xml-params/@vt),string($xml-prop-md/@vt))"/>
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		<!-- 
		Вставим объект DateTimePicker (изначально заблокированный - он разблокируется кодом по завершении инициализации) 
		
				В кач-ве идентификатора используем атрибут html-id обрабатываемого
				объектного св-ва. Это позволит в дальнейшем сопоставить вставленный 
				элемент с соответсвующим свойством объекта из кода.

				Дополнительный атрибут X_DESCR будет хранить описание св-ва, которое,
				в общем случае может отличаться от описания в метаданных.
				Этот атрибут позволит получить описание сопоставленного с элементом
				свойства из кода.
				
				Дополнительный атрибут X_DATETYPE содержит строку с типом даты-времени,
				в том же виде, что и тип, заданный для DS-свойства
		-->	
		<OBJECT	
			ID="{$html-id}" CLASSID="{b:Evaluate('CLSID_DT_PICKER')}" BORDER="0"
			NAME="{b:GetUniqueNameFor(current())}"
			X_DATETYPE = "{$vt}"
			X_DESCR = "{$description}" 
			X_DISABLED = "{$disabled+1}"
			X_PROPERTY_EDITOR = "XPEDateTimeClass"
		>
			<xsl:choose>
				<xsl:when test="1=$maybenull">
					<!-- 
						Если свойство может принимать NULL-значение - выставим 
						атрибут X_MAYBENULL Это позволит контролировать допустимость
						значения свойства при обработке из кода.
					-->						
					<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
					<!-- Выставляем стиль не-обязательного свойства -->
					<xsl:attribute name="CLASS">x-editor-control x-editor-datetime-field</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<!-- Выставляем стиль обязательного свойства -->
					<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-datetime-field</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:choose>
				<xsl:when test="''=$format">
					<!--
						Пользовательский формат не задан. В зависимости от типа значения задаём 
						объекту формат отображения времени
					-->	
					<xsl:choose>
						<xsl:when test="'dateTime' = $vt">
							<PARAM NAME="CustomFormat" VALUE="dd.MM.yyyy HH:mm"></PARAM>
							<PARAM NAME="UpDown" VALUE="0"></PARAM>
						</xsl:when>
						<xsl:when test="'date' = $vt">
							<PARAM NAME="CustomFormat" VALUE="dd.MM.yyyy"></PARAM>
							<PARAM NAME="UpDown" VALUE="0"></PARAM>
						</xsl:when>
						<xsl:when test="'time' = $vt">
							<PARAM NAME="CustomFormat" VALUE="HH:mm"></PARAM>
							<PARAM NAME="UpDown" VALUE="1"></PARAM>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<!-- выставим пользовательские параметры -->
					<PARAM NAME="CustomFormat" VALUE="{$format}"></PARAM>
					<!-- Ведущий "0" здесь добавляется для избежания ошибки при незаданном up-down -->
					<PARAM NAME="UpDown" VALUE="0{$up-down}"></PARAM>
				</xsl:otherwise>
			</xsl:choose>
			
			<PARAM NAME="Enabled" VALUE="0"></PARAM>
			<xsl:choose>
				<xsl:when test="$off-checkbox='1'">
					<PARAM NAME="CheckBox" VALUE="0"></PARAM>
				</xsl:when>
				<xsl:otherwise>
					<PARAM NAME="CheckBox" VALUE="1"></PARAM>
				</xsl:otherwise>
			</xsl:choose>
			<PARAM NAME="ShowBorder" VALUE="0"></PARAM>
			<PARAM NAME="LockHtmlKeyboardEvents" VALUE="-1"></PARAM>
			<PARAM NAME="EnableAutoShift" VALUE="{$autoshift}"></PARAM>
		</OBJECT>
		<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" event="OnDateTimeChange(oSender,vOldValue,vNewValue)">
			window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnChangeAsync",0,"VBScript"
		</SCRIPT>
		<SCRIPT FOR="{$html-id}" EVENT="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" LANGUAGE="VBScript">
			window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpAsync " &amp; nKeyCode &amp; "," &amp; nFlags, 0, "VBScript"
		</SCRIPT>
	</xsl:template>
</xsl:stylesheet>
