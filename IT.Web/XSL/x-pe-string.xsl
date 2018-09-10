<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	Стандартная страница генерации элементов  отображения/модификации для строковых скалярных свойств 
	объекта
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

	<!--
		=============================================================================================
		Стандартный шаблон генерации элементов  отображения/модификации для однострочных строковых скалярных 
		свойств	объекта с возможностью выбора из списка
		Объекты страницы
			urn:object-editor-access - интерфейс объекта EditorData									
		Обрабатываемый элемент:																		
			Свойство объекта X-Storage
		Входные параметры:
			[in] maybenull		- признак допустимости пустого значения	(0/1)										
			[in] description	- описание поля
			[in] metaname		- метанаименование
			[in] disabled		- признак заблокированного поля
			[in] off-edit		- отключение возможности редактирования значения (только выбор из возможных вариантов)
			[in] ot				- имя типа списка, используемого при задании списка значений
			[in] listname		- метаимя списка, используемого при задании списка значений
			[in] use-cache		- признак использования кэша при загрузке данных с сервера (по умолчанию не используется) (0/1)	
			[in] cache-salt		- выражение на VBS, если указан то используется как дополнительный ключ для наименования элемента кэша
										Пример:
											cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;)" - данные кэша становятся недействительными при смене метаданных
											cache-salt="clng(date())" - данные кэша становятся недействительными раз в сутки
											cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;) &amp; &quot;-&quot; &amp; clng(date())" - данные кэша становятся недействительными раз в сутки или при смене метаданных
											cache-salt="MyVbsFunctionName()" - вызывается прикладная функция
			[in] off-reload		- cокрытие элемента управления позволяющего перезагрузить кэш 
									(по умолчанию компонент отображается)
			[in] pattern 		- паттерн регулярного выражения для проверки
			[in] pattern-msg	- сообщение о несоответствии паттерна

		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации однострочных строковых скалярных 
			свойств	объекта
	-->			
	<xsl:template name="std-template-string-lookup" >
		<!-- xml со всеми параметрами шаблона -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml с металданными -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- Параметр: имя PropertyEditor'a в метаданных -->
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:string-lookup[1]/@n))"/>
		<!-- Параметр: доступность -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- Параметр: признак допустимости пустого значения -->
		<xsl:param name="maybenull" select="b:nvl(string($xml-params/@maybenull), string($xml-prop-md/@maybenull))"/>
		<!-- Параметр: описание поля -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
		<!-- Переменная: метаданные i:string-lookup -->
		<xsl:param name="xml-lookup-md" select="$xml-prop-md/i:string-lookup[($metaname='' and not(@n)) or (@n=$metaname)]" />
		<!-- Параметр: имя типа списка, используемого при задании списка значений -->
		<xsl:param name="ot" select="b:nvl(string($xml-params/@ot), string($xml-lookup-md/@ot))"/>
		<!-- Параметр: метаимя списка, используемого при задании списка значений -->
		<xsl:param name="listname" select="b:nvl(string($xml-params/@listname), string($xml-lookup-md/@use-list))"/>
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- Параметр: Признак кэширования -->
		<xsl:param name="use-cache" select="b:nvl(string($xml-params/@use-cache), string($xml-lookup-md/@use-cache))"/>
		<!-- Параметр: Дополнительный параметр кэширования -->
		<xsl:param name="cache-salt" select="b:nvl(string($xml-params/@cache-salt), string($xml-lookup-md/@cache-salt))"/>
		<!-- Параметр: Отключение возможности редактирования значения (только выбор из возможных вариантов) -->
		<xsl:param name="off-edit" select="b:nvl(string($xml-params/@off-edit), string($xml-lookup-md/@off-edit))"/>
		<!-- Параметр: Cокрытие элемента управления, позволяющего перезагрузить кэш  -->
		<xsl:param name="off-reload" select="b:nvl(string($xml-params/@off-reload), string($xml-lookup-md/@off-reload))"/>
		<!-- Параметр: Регулярное выражение для проверки значения  -->
		<xsl:param name="pattern" select="b:nvl(string($xml-params/@pattern), string($xml-prop-md/ds:pattern))"/>
		<!-- Параметр: Сообщение о нарушении паттерна  -->
		<xsl:param name="pattern-msg" select="b:nvl(string($xml-params/@pattern-msg), string($xml-prop-md/ds:pattern/@msg))"/>
		<!-- Масксимальное значение -->
		<xsl:param name="max" select="b:nvl(string($xml-params/@max), string($xml-prop-md/ds:max))"/>
		<!-- Минимальное значение -->
		<xsl:param name="min" select="b:nvl(string($xml-params/@min), string($xml-prop-md/ds:min))"/>
				
		<!-- Ссылка на ObjectEditorClass -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
			<COL WIDTH="100%;"/>
			<xsl:if test="('1'=$use-cache) and ('1'!=$off-reload)">
				<COL STYLE="padding-left:3px;"/>
			</xsl:if>
		<TBODY>
		<TR>
			<TD>
			<!-- 
				Дополнительный аттрибут X_DESCR будет хранить описание св-ва, которое,
				в общем случае может отличаться от описания в метаданных.
				Этот аттрибут позволит получить описание сопоставленного с элементом
				свойства из кода.
			-->
			<OBJECT 
				ID="{$html-id}" BORDER="0"  
				CLASSID="clsid:EB98C2B1-BEF9-4C24-B248-0F1634BD1488" 
				HEIGHT="24" WIDTH="100%" 
				MAXLENGTH="{$max}"
				NAME="{b:GetUniqueNameFor(current())}"

				X_MIN="{$min}"
				X_MAX="{$max}"

				Metaname = "{$metaname}" 
				ListMetaname = "{$listname}" 
				TypeName = "{$ot}" 
				X_DESCR = "{$description}"
				X_DISABLED = "{$disabled+1}"
				X_PROPERTY_EDITOR = "XPEStringLookupClass"
				
				UseCache="{$use-cache}" 
				CacheSalt="{$cache-salt}" 
				RefreshButtonID = "{$html-id}Refresh"
				
				RegExpPattern="{$pattern}"
				RegExpPatternMsg="{$pattern-msg}"
			>
				<!-- Обработка обязательных/необязательных свойств -->
				<xsl:choose>
					<xsl:when test="'1'=$maybenull">
						<!-- 
							Если свойство может принимать значение null - выставим дополнительный
							аттрибут X_MAYBENULL.
							Этот аттрибут позволит контролировать допустимость значения св-ва при
							обработке из кода.
						-->						
						<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
						<!-- Выставляем стиль не-обязательного свойства -->
						<xsl:attribute name="CLASS">x-editor-control x-editor-string-lookup-field</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<!-- Выставляем стиль обязательного свойства -->
						<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-string-lookup-field</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<PARAM NAME="ENABLED" VALUE="0"></PARAM>
				<xsl:choose>
					<xsl:when test="'1'=$off-edit">				
						<PARAM NAME="EDITABLE" VALUE="0"></PARAM>
					</xsl:when>
					<xsl:otherwise>
						<PARAM NAME="EDITABLE" VALUE="-1"></PARAM>
					</xsl:otherwise>
				</xsl:choose>
				<PARAM NAME="AUTOSEARCH" VALUE="-1"></PARAM>
				<PARAM NAME="LockHtmlKeyboardEvents" VALUE="-1"></PARAM>
			</OBJECT>
			<SCRIPT FOR="{$html-id}" EVENT="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" LANGUAGE="VBScript">
				window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpAsync " &amp; nKeyCode &amp; "," &amp; nFlags, 0, "VBScript"
			</SCRIPT>
			</TD>
			<xsl:if test="('1'=$use-cache) and ('1'!=$off-reload)">
			<TD>
				<BUTTON 
					ID="{$html-id}Refresh" 
					NAME="{b:GetUniqueNameFor(current())}"
					TITLE="Обновить данные списка"
					DISABLED="1" 
					CLASS="x-editor-objectpresentation-button" 
					STYLE="background-color:#cccccc; border-color:#eeeeee; padding:0px; margin-left:2px;"
					TABINDEX="-1"
				>
					<IMG SRC="Images/x-reload.gif" STYLE="overflow:hidden; margin:-2px; border:none; border-width:0px;"/>
				</BUTTON>
				<SCRIPT FOR="{$html-id}Refresh" EVENT="OnClick" LANGUAGE="VBScript">
					<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Reload
				</SCRIPT>
			</TD>
			</xsl:if>
		</TR>
		</TBODY>
		</TABLE>
	</xsl:template>
	
	
	<!--
		=============================================================================================
		Стандартный шаблон генерации элементов  отображения/модификации для однострочных строковых скалярных 
		свойств	объекта
		Объекты страницы
			urn:object-editor-access - интерфейс объекта EditorData									
		Обрабатываемый элемент:																		
			Свойство объекта X-Storage
		Входные параметры:
			[in] disabled		- признак заблокированного поля
			[in] readonly 		- признак поля только для чтения
			[in] maybenull		- признак допустимости пустого значения	(0/1)										
			[in] description 	- описание поля
			[in] pattern 		- паттерн регулярного выражения для проверки
			[in] pattern-msg	- сообщение о несоответствии паттерна
			[in] min			- минимальная длина строки
			[in] max			- максимальная длина строки
		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации однострочных строковых скалярных 
			свойств	объекта
	-->			
	<xsl:template name="std-template-string">
		<!-- xml со всеми параметрами шаблона -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml с металданными -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- Параметр: доступность -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- Параметр: признак поля только для чтения -->
		<xsl:param name="readonly" select="number(b:nvl(string($xml-params/@readonly),'0'))"/>
		<!-- Параметр: признак допустимости пустого значения -->
		<xsl:param name="maybenull" select="b:nvl(string($xml-params/@maybenull), string($xml-prop-md/@maybenull))"/>
		<!-- Параметр: описание поля -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
			
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		
		<!-- Параметр: Регулярное выражение для проверки значения  -->
		<xsl:param name="pattern" select="b:nvl(string($xml-params/@pattern), string($xml-prop-md/ds:pattern))"/>
		<!-- Параметр: Сообщение о нарушении паттерна  -->
		<xsl:param name="pattern-msg" select="b:nvl(string($xml-params/@pattern-msg), string($xml-prop-md/ds:pattern/@msg))"/>
		<!-- Масксимальное значение -->
		<xsl:param name="max" select="b:nvl(string($xml-params/@max), string($xml-prop-md/ds:max))"/>
		<!-- Минимальное значение -->
		<xsl:param name="min" select="b:nvl(string($xml-params/@min), string($xml-prop-md/ds:min))"/>
		<!-- Параметр: ширина контрола -->
		<xsl:param name="width" select="b:nvl(string($xml-params/@width),'100%')" />
		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>

		<!-- 
			В кач-ве идентификатора используем аттрибут html-id обрабатываемого
			объектного св-ва. Это позволит в дальнейшем сопоставить вставленный 
			элемент с соответсвующим свойством объекта из кода.

			Дополнительный аттрибут X_DESCR будет хранить описание св-ва, которое,
			в общем случае может отличаться от описания в метаданных.
			Этот аттрибут позволит получить описание сопоставленного с элементом
			свойства из кода.
		-->

		<INPUT 	
			ID="{$html-id}" 
			X_DESCR="{$description}"

			TYPE="TEXT" DISABLED="1" VALUE="" 
			X_DISABLED = "{$disabled+1}"
			X_PROPERTY_EDITOR = "XPEStringClass"
			NAME="{b:GetUniqueNameFor(current())}"
			MAXLENGTH="{$max}"
			STYLE="width:{$width};"

			X_MIN="{$min}"
			X_MAX="{$max}"

			RegExpPattern="{$pattern}"
			RegExpPatternMsg="{$pattern-msg}"
		>
			<!-- Признак ReadOnly -->
			<xsl:if test="1=$readonly">
				<xsl:attribute name="readonly">1</xsl:attribute>
			</xsl:if>
			
			<!-- Обработка обязательных/необязательных свойств -->
			<xsl:choose>
				<xsl:when test="'1'=$maybenull">
					<!-- 
						Если свойство может принимать значение null - выставим дополнительный
						аттрибут X_MAYBENULL.
						Этот аттрибут позволит контролировать допустимость значения св-ва при
						обработке из кода.
					-->						
					<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
					<!-- Выставляем стиль не-обязательного свойства -->
					<xsl:attribute name="CLASS">x-editor-control x-editor-string-field</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<!-- Выставляем стиль обязательного свойства -->
					<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-string-field</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</INPUT>
		<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnKeyUp">
			With window.event
				window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpHtmlAsync " &amp; .keyCode &amp; "," &amp; CLng(.altKey) &amp; "," &amp; CLng(.ctrlKey) &amp; "," &amp; CLng(.shiftKey), 0, "VBScript"
			.cancelBubble = True
			End With
		</SCRIPT>				
	</xsl:template>
	

	<!--
		=============================================================================================
		Стандартный шаблон генерации элементов  отображения/модификации для многострочных строковых скалярных 
		свойств	объекта
		Объекты страницы
			urn:object-editor-access - интерфейс объекта EditorData									
		Обрабатываемый элемент:																		
			Свойство объекта X-Storage
		Входные параметры:
			[in] height - высота ячейки для редактирования текстового свойства
			[in] minrows - минимальное количество строк для редактирования
			[in] disabled		- признак заблокированного поля
			[in] maxrows - максимальное количество строк для редактирования
			[in] maybenull	- признак допустимости пустого значения	(0/1)										
			[in] description - описание поля
			[in] readonly - признак поля только для чтения
			[in] pattern 		- паттерн регулярного выражения для проверки
			[in] pattern-msg	- сообщение о несоответствии паттерна
		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации многострочных строковых скалярных 
			свойств	объекта
	-->			
	<xsl:template name="std-template-text">
		<!-- xml со всеми параметрами шаблона -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml с металданными -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- Параметр: доступность -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- Параметр: признак поля только для чтения -->
		<xsl:param name="readonly" select="number(b:nvl(string($xml-params/@readonly),'0'))"/>
		<!-- Параметр: признак допустимости пустого значения -->
		<xsl:param name="maybenull" select="b:nvl(string($xml-params/@maybenull), string($xml-prop-md/@maybenull))"/>
		<!-- Параметр: описание поля -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
			
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		
		<!-- Параметр: Регулярное выражение для проверки значения  -->
		<xsl:param name="pattern" select="b:nvl(string($xml-params/@pattern), string($xml-prop-md/ds:pattern))"/>
		<!-- Параметр: Сообщение о нарушении паттерна  -->
		<xsl:param name="pattern-msg" select="b:nvl(string($xml-params/@pattern-msg), string($xml-prop-md/ds:pattern/@msg))"/>
		<!-- Масксимальное значение -->
		<xsl:param name="max" select="b:nvl(string($xml-params/@max), string($xml-prop-md/ds:max))"/>
		<!-- Минимальное значение -->
		<xsl:param name="min" select="b:nvl(string($xml-params/@min), string($xml-prop-md/ds:min))"/>
		<!-- Параметр: ширина контрола -->
		<xsl:param name="width" select="b:nvl(string($xml-params/@width),'100%')" />

		<!-- Параметр: высота ячейки для редактирования текстового свойства -->
		<xsl:param name="height" select="string($xml-params/@height)"/>
		<!-- Параметр: минимальное количество строк для редактирования -->
		<xsl:param name="minheight" select="number(b:nvl(string($xml-params/@minheight),'1'))"/>
		<!-- Параметр: максимальное количество строк для редактирования -->
		<xsl:param name="maxheight" select="number(b:nvl(string($xml-params/@maxheight),'200'))"/>
		<!-- Параметр: перенос строк -->
		<xsl:param name="wrap" select="b:nvl(string($xml-params/@wrap),'soft')"/>

		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		
		<!-- 
			В кач-ве идентификатора используем аттрибут html-id обрабатываемого
			объектного св-ва. Это позволит в дальнейшем сопоставить вставленный 
			элемент с соответсвующим свойством объекта из кода.

			Дополнительный аттрибут X_DESCR будет хранить описание св-ва, которое,
			в общем случае может отличаться от описания в метаданных.
			Этот аттрибут позволит получить описание сопоставленного с элементом
			свойства из кода.
		-->
				
		<TEXTAREA 
			ID="{$html-id}" 
			X_DESCR="{$description}"
					
			WRAP="{$wrap}" DISABLED="1" 
			X_DISABLED = "{$disabled+1}"
			X_RowHeight="10"
			X_PROPERTY_EDITOR = "XPEStringClass"
			LANGUAGE="VBScript"
			NAME="{b:GetUniqueNameFor(current())}"
			MAXLENGTH="{$max}"

			X_MIN="{$min}"
			X_MAX="{$max}"
			
			X_MinH="{$minheight}"
			X_MaxH="{$maxheight}"

			RegExpPattern="{$pattern}"
			RegExpPatternMsg="{$pattern-msg}"
		>
			<!-- Признак ReadOnly -->
			<xsl:if test="1=$readonly">
				<xsl:attribute name="READONLY">1</xsl:attribute>
			</xsl:if>
			
			<xsl:if test="''=$height">
				<xsl:attribute name="ROWS">1</xsl:attribute>
				<xsl:attribute name="X_IS_SMART">YES</xsl:attribute>
				<xsl:attribute name="OnClick"><xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_SmartTextAreaOnAdjustSize</xsl:attribute>
			</xsl:if>
			
			<!-- Обработка обязательных/необязательных свойств -->
			<xsl:attribute name="style">width:100%;overflow:auto;
				<xsl:if test="''!=$height">
					height:<xsl:value-of select="$height"/>;
				</xsl:if>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="'1'=$maybenull">
					<!-- 
						Если свойство может принимать значение null - выставим дополнительный
						аттрибут X_MAYBENULL.
						Этот аттрибут позволит контролировать допустимость значения св-ва при
						обработке из кода.
					-->						
					<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
					<!-- Выставляем стиль не-обязательного свойства -->
					<xsl:attribute name="CLASS">x-editor-control x-editor-text-field</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<!-- Выставляем стиль обязательного свойства -->
					<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-text-field</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</TEXTAREA>
		<SCRIPT LANGUAGE="VBScript" FOR="{$html-id}" EVENT="OnKeyUp" >
		<xsl:if test="''=$height">
			<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_SmartTextAreaOnAdjustSize
		</xsl:if>
		With Window.Event
			IF (.KeyCode = VK_ENTER) AND NOT .CtrlKey AND NOT .AltKey AND NOT .shiftKey THEN
				.cancelBubble = True
			END IF
		End With
		</SCRIPT>
		<xsl:if test="''=$height">
			<SCRIPT LANGUAGE="VBScript" FOR="{$html-id}" EVENT="OnPropertyChange" >
				If 0=StrComp(window.event.propertyName,"VALUE", vbTextCompare ) Then 
					<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_SmartTextAreaOnAdjustSize
				End If	
			</SCRIPT>
		</xsl:if>

	</xsl:template>

</xsl:stylesheet>
