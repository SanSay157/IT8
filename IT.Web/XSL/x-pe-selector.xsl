<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	Стандартная страница генерации элементов  отображения/модификации для целых скалярных свойств 
	объекта, допускающих выбор из набора доп. значений
-->	 
<xsl:stylesheet 
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"

	xmlns:w="urn:editor-window-access"
	xmlns:d="urn:object-editor-access"
	xmlns:b="urn:x-page-builder"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"	
	>


	
	<!--
		=============================================================================================
		Стандартный шаблон генерации элементов  отображения/модификации для числовых скалярных свойств
		объекта, допускающих выбор из набора доп. значений
		Объекты страницы
			urn:object-editor-access - интерфейс объекта EditorData									
		Обрабатываемый элемент:																		
			Свойство объекта X-Storage
		Входные параметры:
			[in] maybenull		- признак допустимости пустого значения	(0/1)										
			[in] description	- описание поля
			[in] metaname		- метаимя редактора свойства (i:const-value-selection/@n)
			[in] html-id		- идентификатор Html-контрола
			[in] disabled		- признак заблокированного поля (только для COMBO)
			[in] selector		- Тип селектора (радиокнопки/комбобокc)
			[in] empty-value-text	- текст пустого значения
			[in] no-empty-value		- признак отсутствия пустого значения (по умолчанию 0, т.е. пустое значение есть)
		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации числовых скалярных свойств 
			объекта, допускающих выбор из набора доп. значений
	-->	
	<xsl:template name="std-template-selector">
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
		<!-- Параметр: имя PropertyEditor'a в метаданных -->
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:const-value-selection/@n))"/>
		<!-- метаданные pe: i:object-dropdown -->
		<xsl:param name="pe-md" select="$xml-prop-md/i:const-value-selection[($metaname='' and not(@n)) or ($metaname=@n)]"/>
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>	
		<!-- Параметр: Тип селектора (радиокнопки/комбобох)-->
		<xsl:param name="selector" select="b:nvl(string($xml-params/@selector), string($pe-md/@selector))"/>
		<!-- Параметр: текст пустого значения -->
		<xsl:param name="empty-value-text" select="b:nvl(string($xml-params/@empty-value-text), string($pe-md/@empty-value-text))"/>
		<!-- Параметр: не добавлять пустую строку в комбобокс (по умолчанию добавляется) -->
		<xsl:param name="no-empty-value" select="b:nvl(string($xml-params/@no-empty-value), string($pe-md/@no-empty-value))"/>
		<!-- Параметр: ширина контрола -->
		<xsl:param name="width" select="b:nvl(string($xml-params/@width),'100%')" />
		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>

		<xsl:choose>
			<xsl:when test="$selector='activex-combo'">
				<OBJECT
					ID="{$html-id}"
					CLASSID="{w:get-CLSID_COMBOBOX()}" 
					BORDER="0" WIDTH="100%" TABINDEX="0"
					X_DESCR = "{$description}"
					X_DISABLED = "{$disabled+1}"
					X_PROPERTY_EDITOR = "XPESelectorComboClass"
					HiddenDataID = "{$html-id}_HiddenData"
					NAME="{b:GetUniqueNameFor(current())}"
					NoEmptyValue = "{$no-empty-value}"
					EmptyValueText = "{$empty-value-text}"
					STYLE="width:{$width};"
				>
					<xsl:choose>
						<xsl:when test="'1'=$maybenull">
							<!-- 
								Если свойство может принимать значение null - выставим дополнительный
								Aтрибут X_MAYBENULL.
								Этот Aтрибут позволит контролировать допустимость значения св-ва при
								обработке из кода.
							-->						
							<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
							<!-- Выставляем стиль не-обязательного свойства -->
							<xsl:attribute name="CLASS">x-editor-control x-editor-const-selector</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<!-- Выставляем стиль обязательного свойства -->
							<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-const-selector</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>						
					
					<PARAM NAME="Enabled" VALUE="0"></PARAM>
					<PARAM NAME="Editable" VALUE="0"></PARAM>
					<PARAM NAME="AutoSearch" VALUE="-1"></PARAM>
					<PARAM NAME="EmptySelectionText" VALUE="{$empty-value-text}"></PARAM>
					<PARAM NAME="LockHtmlKeyboardEvents" VALUE="-1"></PARAM>
				</OBJECT>
				
				<SCRIPT FOR="{$html-id}" EVENT="OnItemSelect( ByVal oSender, ByVal nItemIndex, ByVal sItemID, sText )" LANGUAGE="VBScript">
					If 0 = Len(sItemID) Then oSender.text = oSender.EmptySelectionText
					<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnChange
				</SCRIPT>
				<SCRIPT FOR="{$html-id}" EVENT="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" LANGUAGE="VBScript">
					window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpAsync " &amp; nKeyCode &amp; "," &amp; nFlags, 0, "VBScript"
				</SCRIPT>
				<!-- Вставим селектор с опциями (позже мы ПЕРЕКАЧАЕМ эти опции в OBJECT)  -->
				<select style="display:none;" id="{$html-id}_HiddenData">
					<xsl:for-each select="$pe-md/i:const-value">
						<OPTION value="{string(.)}"><xsl:value-of select="@n"/></OPTION>
					</xsl:for-each>
				</select>
			</xsl:when>
			
			<xsl:when test="$selector='combo'">
				<!-- 
					Дополнительный Aтрибут X_DESCR будет хранить описание св-ва, которое,
					в общем случае может отличаться от описания в метаданных.
					Этот Aтрибут позволит получить описание сопоставленного с элементом
					свойства из кода.
				-->
				<SELECT
					ID="{$html-id}" DISABLED="1" 
					NAME="{b:GetUniqueNameFor(current())}"
					X_DESCR="{$description}"
					X_DISABLED="{$disabled+1}"
					X_PROPERTY_EDITOR = "XPESelectorComboClass"
					NoEmptyValue = "{$no-empty-value}"
					EmptyValueText = "{$empty-value-text}"
					STYLE="width:{$width};"
				>
					<!--
						Признак заблокированного контрола
					-->
					<xsl:choose>
						<xsl:when test="'1'=$maybenull">
							<!-- 
								Если свойство может принимать значение null - выставим дополнительный
								Aтрибут X_MAYBENULL.
								Этот Aтрибут позволит контролировать допустимость значения св-ва при
								обработке из кода.
							-->						
							<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
							<!-- Выставляем стиль не-обязательного свойства -->
							<xsl:attribute name="class">x-editor-control x-editor-const-selector</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<!-- Выставляем стиль обязательного свойства -->
							<xsl:attribute name="class">x-editor-control-notnull x-editor-const-selector</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>						
					
					<!-- добавим пустое значение, если это явно не запрещено параметром -->
					<xsl:if test="$no-empty-value!='1'">
						<!-- Если у элемента метаданных i:object-dropdown задан текст, добавляем его в список -->
						<xsl:choose>
							<!-- Если у элемента метаданных i:object-dropdown задан текст, добавляем его в список -->
							<xsl:when test="$empty-value-text">
								<option selected="1"><xsl:value-of select="$empty-value-text"/></option>
							</xsl:when>
							<!-- Если текст первого элемента не задан, добавляем пустой элемент -->
							<xsl:otherwise>
								<option selected="1"></option>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:for-each select="$pe-md/i:const-value">
						<OPTION value="{string(.)}"><xsl:value-of select="@n"/></OPTION>
					</xsl:for-each>
				</SELECT>	
				<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnChange">
					<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnChange
				</SCRIPT>
				<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnKeyUp">
					With window.event
						window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpHtmlAsync " &amp; .keyCode &amp; "," &amp; CLng(.altKey) &amp; "," &amp; CLng(.ctrlKey) &amp; "," &amp; CLng(.shiftKey), 0, "VBScript"
					.cancelBubble = True
					End With
				</SCRIPT>				
			</xsl:when>
			<xsl:when test="$selector='horizontal-radio'">
				<!-- 
					Сформируем контейнер (элемент DIV)
					В кач-ве идентификатора используем Aтрибут html-id обрабатываемого
					объектного св-ва. Это позволит в дальнейшем сопоставить вставленный 
					элемент с соответсвующим свойством объекта из кода.
					
					Aтрибут X_DESCR будет хранить описание св-ва, которое,
					в общем случае может отличаться от описания в метаданных.
					Этот атрибут позволит получить описание сопоставленного с элементом
					свойства из кода.
				-->				
				<TABLE
					ID="{$html-id}" CLASS="x-editor-const-selector" BORDER="0"
					X_DESCR="{$description}"
					X_DISABLED="{$disabled+1}"
					X_PROPERTY_EDITOR = "XPESelectorRadioClass"
				>
					<xsl:if test="'1'=$maybenull">
						<!-- 
							Если свойство может принимать значение null - выставим дополнительный
							Aтрибут X_MAYBENULL.
							Этот Aтрибут позволит контролировать допустимость значения св-ва при
							обработке из кода.
						-->						
						<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
					</xsl:if>
					<tr>
					<xsl:variable name="name" select="b:GetUniqueNameFor(current())"/>
					<xsl:for-each select="$pe-md/i:const-value">
					<td><nobr>
						<xsl:variable name="id"><xsl:value-of select="$html-id"/>_<xsl:if test="position() &lt; 9">0</xsl:if><xsl:value-of select="position()+1"/></xsl:variable>
						<INPUT NAME="{$name}" TYPE="radio" DISABLED="1" ID="{$id}" VALUE="{string(.)}"/>
						<LABEL FOR="{$id}"><xsl:value-of select="@n"/></LABEL>
						<SCRIPT FOR="{$id}" LANGUAGE="VBScript" EVENT="OnClick">
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnClick "<xsl:value-of select="$id"/>"
						</SCRIPT>						
						<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnKeyUp">
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnKeyUp
						</SCRIPT>				
					</nobr></td>
					</xsl:for-each>
					</tr>
				</TABLE>
			</xsl:when>			
			<xsl:otherwise>
				<!-- 
					Сформируем контейнер (элемент DIV)
					В кач-ве идентификатора используем Aтрибут html-id обрабатываемого
					объектного св-ва. Это позволит в дальнейшем сопоставить вставленный 
					элемент с соответсвующим свойством объекта из кода.
					
					Aтрибут X_DESCR будет хранить описание св-ва, которое,
					в общем случае может отличаться от описания в метаданных.
					Этот атрибут позволит получить описание сопоставленного с элементом
					свойства из кода.
				-->				
				<DIV
					ID="{$html-id}" CLASS="x-editor-const-selector" STYLE="width:100%;" 
					X_DESCR="{$description}"
					X_DISABLED="{$disabled+1}"
					X_PROPERTY_EDITOR = "XPESelectorRadioClass"
				>
					<xsl:if test="'1'=$maybenull">
						<!-- 
							Если свойство может принимать значение null - выставим дополнительный
							Aтрибут X_MAYBENULL.
							Этот Aтрибут позволит контролировать допустимость значения св-ва при
							обработке из кода.
						-->						
						<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
					</xsl:if>
					<xsl:variable name="name" select="b:GetUniqueNameFor(current())"/>
					<xsl:for-each select="$pe-md/i:const-value">
						<xsl:variable name="id"><xsl:value-of select="$html-id"/>_<xsl:if test="position() &lt; 9">0</xsl:if><xsl:value-of select="position()+1"/></xsl:variable>
						<INPUT NAME="{$name}" TYPE="radio" DISABLED="1" ID="{$id}" VALUE="{string(.)}"/>
						<LABEL FOR="{$id}"><xsl:value-of select="@n"/></LABEL><BR/>
						<SCRIPT FOR="{$id}" LANGUAGE="VBScript" EVENT="OnClick">
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnClick "<xsl:value-of select="$id"/>"
						</SCRIPT>						
						<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnKeyUp">
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnKeyUp
						</SCRIPT>				
					</xsl:for-each>
				</DIV>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
