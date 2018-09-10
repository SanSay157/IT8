<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	Стандартная страница генерации элементов  отображения/модификации для целых скалярных свойств 
	объекта, имеющих флаговое представление
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
		Внутренняя функция для организации подобия цикла FOR при вставке чекбоксов
	-->
	<xsl:template name="std-template-flags-internal-checkbox">
		<xsl:param name="bit"/>
		<xsl:param name="i"/>
		<xsl:param name="html-id"/>
		<xsl:param name="editordata"/>
		<xsl:param name="prop"/>

		<!-- текст checkbox'a -->
		<xsl:variable name="lbl" select="string($bit/@n)"/>
		<!-- текст tooltip'a -->
		<xsl:variable name="hint" select="string($bit/@hint)"/>
		<!-- идентификатор checkbox'a -->
		<xsl:variable name="id"><xsl:value-of select="$html-id"/>_<xsl:if test="$i &lt; 9">0</xsl:if><xsl:value-of select="$i+1"/></xsl:variable>
		<!-- 
			Генерируем HTML для редактирования индивидуальных флагов 
			
			для каждого флага сформируем следующее HTML-представление:
			
			<INPUT 
				TYPE="CHECKBOX" 
				ID="{html-id свойства}_{номер обрабатываемого флага}" 
				ExpBitValue="{маска флага в метаданных}" 
				DASABLED="1"
				NAME="{b:GetUniqueNameFor(current())}"
				OnClick=""
			>
			<LABEL FOR="{html-id свойства}_{номер обрабатываемого флага}">
				{имя флага в метаданных}
			</LABEL>
			<BR/>
			
			инициализация элементов производится кодом редактора.
			разблокирование элементов производится кодом редактора.
		-->
		<INPUT 
			TYPE="CHECKBOX" 
			NAME="{b:GetUniqueNameFor($prop)}"
			ID="{$id}"
			DISABLED="1"
			ExpBitValue="{string($bit)}" title="{$hint}"
		/>
		<LABEL id="{$id}Label" FOR="{$id}" title="{$hint}">
			<xsl:value-of select="$lbl"/>
		</LABEL>
		<SCRIPT FOR="{$id}" LANGUAGE="VBScript" EVENT="OnClick">
			<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnClick "<xsl:value-of select="$id"/>"
		</SCRIPT>
		<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnKeyUp">
			<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnKeyUp
		</SCRIPT>				
	</xsl:template>	
	
	<!--
		=============================================================================================
		Стандартный шаблон генерации элементов  отображения/модификации для целых скалярных свойств
		объекта, имеющих флаговое представление
		Объекты страницы
			urn:object-editor-access - интерфейс объекта EditorData									
		Обрабатываемый элемент:																		
			Свойство объекта X-Storage
		Входные параметры:
			[in] description - описание поля
			[in] metaname		- метаимя редактора свойства (i:bits/@n)
		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации целых скалярных свойств 
			объекта, имеющих флаговое представление
	-->	
	<xsl:template name="std-template-flags">
		<!-- xml со всеми параметрами шаблона -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml с металданными -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- Параметр: доступность -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- Параметр: описание поля -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
		<!-- Параметр: имя PropertyEditor'a в метаданных -->
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:bits[1]/@n))"/>
		<!-- признак располагать чекбоксы по горизонтали. По умолчанию они располагаются в стобец -->
		<xsl:param name="horizontal-direction" select="b:nvl(string($xml-params/@horizontal), string($xml-prop-md/i:bits[($metaname='' and not(@n)) or ($metaname=@n)]/@horizontal))"/>
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		<xsl:variable name="prop" select="current()"/>
		
		<!-- 
			Сформируем контейнер (элемент DIV)
			
			В качестве идентификатора используем атрибут html-id обрабатываемого
			объектного св-ва. Это позволит в дальнейшем сопоставить вставленный 
			элемент с соответсвующим свойством объекта из кода.
			
			Дополнительный атрибут X_DESCR будет хранить описание св-ва, которое,
			в общем случае может отличаться от описания в метаданных.
			Этот атрибут позволит получить описание сопоставленного с элементом
			свойства из кода.
		-->
		<DIV ID="{$html-id}" CLASS="x-editor-flags"
			X_DESCR = "{$description}"
			X_DISABLED = "{$disabled+1}"
			X_PROPERTY_EDITOR = "XPEFlagsClass"
		>
			<!--  Сгенерируем чекбоксы -->
			<xsl:choose>
				<xsl:when test="'1'=$horizontal-direction">
					<TABLE CELLSPACING="0" CELLPADDING="0"><TR>
						<xsl:for-each select="$xml-prop-md/i:bits[($metaname='' and not(@n)) or ($metaname=@n)]/i:bit">
							<td style="padding-right:3px;">
								<xsl:call-template name="std-template-flags-internal-checkbox">
									<xsl:with-param name="bit" select="current()"/>
									<xsl:with-param name="html-id" select="$html-id"/>
									<xsl:with-param name="editordata" select="$editordata"/>
									<xsl:with-param name="prop" select="$prop"/>
									<xsl:with-param name="i" select="position()"/>
								</xsl:call-template>
							</td>
						</xsl:for-each>
					</TR></TABLE>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="$xml-prop-md/i:bits[($metaname='' and not(@n)) or ($metaname=@n)]/i:bit">
						<div>
							<xsl:call-template name="std-template-flags-internal-checkbox">
								<xsl:with-param name="bit" select="current()"/>
								<xsl:with-param name="html-id" select="$html-id"/>
								<xsl:with-param name="editordata" select="$editordata"/>
								<xsl:with-param name="prop" select="$prop"/>
								<xsl:with-param name="i" select="position()"/>
							</xsl:call-template>
						</div>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</DIV>
	</xsl:template>
</xsl:stylesheet>