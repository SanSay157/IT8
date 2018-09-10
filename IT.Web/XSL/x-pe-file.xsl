<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	Стандартная страница генерации элементов  отображения/модификации для скалярных свойств объекта
	типа bin
-->	
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:b="urn:x-page-builder"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"		
	>
	<!--
		=============================================================================================
		Стандартный шаблон генерации элементов  отображения/модификации для скалярных свойств объекта
		типа bin
		Объекты страницы
			urn:editor-data-access - интерфейс объекта EditorData									
		Обрабатываемый элемент:																		
			Свойство DS-объекта Storage
		Входные параметры:
			[in] maybenull		-	Признак допустимости пустого значения	(0/1)										
			[in] description	-	Описание поля
			[in] off-view		-	Признак отключения операции "просмотр"
			[in] off-clear		-	Признак отключения операции "очистить"
			[in] off-showsize	-	Признак отключение отображения размера файла
			[in] filters		-	Cтрока фильтров, в следующем формате:
									"description1|patternlist1|...descriptionN|patternlistN|", 
									где "patternlistI" есть список масок файлов, перечисленных через ";" 
									если не указан, то  используется значение по умолчанию в зависимости
									от типа:
										- для произвольный двоичных данных - "Все файлы (*.*)|*.*|"
										- для изображений - "Файлы изображения (*.gif;*.jpg;*.jpeg;*.bmp;*.png)" 
										и "Все файлы(*.*)"
			[in] max-file-size  -	Максимальный размер файла
			[in] file-name-in	-	Имя свойства объекта-владельца данного двоичного св-ва, в котором 
									Необходимо разместить имя файла (с расширением, без пути) 
			[in] is-image		-	Признак изображения, а не просто двоичного файла
			[in] max-width		-	Oграничения на геометрические размеры изображения
			[in] max-height		-	Oграничения на геометрические размеры изображения
			[in] min-width		-	Oграничения на геометрические размеры изображения
			[in] min-height		-	Oграничения на геометрические размеры изображения
			[in] t				-	Заголовок диалога выбора картинки/открытия файла
			[in] disabled		-   Признак заблокированного поля

		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации скалярных свойств объекта 
					типа bin

		TODO: метаимя
	-->	
	<xsl:template name="std-template-file">
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
		<!-- Параметр: блокировка просмотра -->
		<xsl:param name="off-view" select="b:nvl(string($xml-params/@off-view),string($xml-prop-md/i:binary-presentation/@off-view))"/>
		<!-- Параметр: блокировка очистки -->
		<xsl:param name="off-clear" select="b:nvl(string($xml-params/@off-clear),string($xml-prop-md/i:binary-presentation/@off-clear))"/>
		<!-- Параметр: блокировка отображения размера файла -->
		<xsl:param name="off-showsize" select="b:nvl(string($xml-params/@off-showsize),string($xml-prop-md/i:binary-presentation/@off-showsize))"/>
		<!-- Параметр: cтрока фильтров -->
		<xsl:param name="filters" select="b:nvl(string($xml-params/@filters),string($xml-prop-md/i:binary-presentation/@filters))"/>
		<!-- Параметр: максимальный размер файла -->
		<xsl:param name="max-file-size" select="b:nvl(string($xml-params/@max-file-size),string($xml-prop-md/i:binary-presentation/@max-file-size))"/>
		<!-- Параметр: имя свойства объекта, в котором содержится имя файла -->
		<xsl:param name="file-name-in" select="b:nvl(string($xml-params/@file-name-in),string($xml-prop-md/i:binary-presentation/@file-name-in))"/>
		<!-- Параметр: заголовок диалога выбора картинки/открытия файла -->
		<xsl:param name="t" select="b:nvl(b:nvl(string($xml-params/@title),string($xml-prop-md/i:binary-presentation/@t)),'Операции...')"/>
		<!-- Параметр: Признак изображения, а не просто двоичного файла -->
		<xsl:param name="is-image" select="b:nvl(string($xml-params/@is-image),string($xml-prop-md/i:binary-presentation/@is-image))"/>
		<!-- Параметры: Oграничения на геометрические размеры изображения -->
		<xsl:param name="min-width" select="b:nvl(string($xml-params/@min-width),string($xml-prop-md/i:binary-presentation/@min-width))"/>
		<xsl:param name="min-height" select="b:nvl(string($xml-params/@min-height),string($xml-prop-md/i:binary-presentation/@min-height))"/>
		<xsl:param name="max-width" select="b:nvl(string($xml-params/@max-width),string($xml-prop-md/i:binary-presentation/@max-width))"/>
		<xsl:param name="max-height" select="b:nvl(string($xml-params/@filters),string($xml-prop-md/i:binary-presentation/@max-height))"/>
		<!-- Параметр: символ, отображаемый кнопкой выбора (на данный момент на задается метаданными) -->
		<!-- Варианты: dots, arrow -->		
		<xsl:param name="select-symbol" select="b:nvl(string($xml-params/@select-symbol),string($xml-prop-md/i:binary-presentation/@select-symbol))"/>
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		<!-- тип свойства (bin/smallBin) -->
		<xsl:variable name="vt" select="string($xml-prop-md/@vt)"/>
		
		<!-- Таблица сетки размещения элементов отображения -->
		<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" WIDTH="100%">
			<COL WIDTH="100%;"/>
			<COL STYLE="padding-left:3px;"/>
			<COL STYLE="padding-left:3px;"/>
		<TBODY>
		<TR>
			<TD>
				<!-- 
					ПОЛЕ ДЛЯ ВЫВОДА ИМЕНИ ФАЙЛА.
					Поле только-для-четния, задание имени файла выполняется с помощью меню
					В качестве основы для идентификатора используем атрибут html-id 
					объектного свойства. Это позволит в дальнейшем сопоставить вставленный 
					элемент с соответсвующим свойством объекта из пользовательского кода.
				-->
				<INPUT 
					ID="{$html-id}FileName" 
					TYPE="TEXT" 
					NAME="{b:GetUniqueNameFor(current())}"
					TABINDEX="-1" VALUE="" READONLY="1" DISABLED="1" STYLE="width:100%">
					<!-- 
						Обработка обязательных / необязательных свойств
						В случае обязательности свойства назначается спец. 
						стилевой класс
					-->
					<xsl:choose>
						<xsl:when test="'1'=$maybenull">
							<!-- Выставляем стиль не-обязательного свойства -->
							<xsl:attribute name="CLASS">x-editor-control</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<!-- Выставляем стиль обязательного свойства -->
							<xsl:attribute name="CLASS">x-editor-control-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</INPUT>
			</TD>
			<TD>
				<!-- 
					Ячейка отображения размера файла; иожет быть скрыта если задан атрибут 
					off-showsize: при его задании поле включается в HTML-страницу, но как
					"неотображаемое"; т.о. достигается и доступность значения поля из 
					прикладного кода, и его "невидемость"
				-->
				<xsl:choose>
					<xsl:when test="'1'=$off-showsize">
						<!-- "Невидимость" достигается за счет принудительной установки стиля -->
						<xsl:attribute name="STYLE">display:none;</xsl:attribute>
					</xsl:when>
				</xsl:choose>
				
				<!-- 
					ПОЛЕ ДЛЯ ВЫВОДА РАЗМЕРА ФАЙЛА 
					В качестве основы для идентификатора используем атрибут html-id 
					объектного свойства. Это позволит в дальнейшем сопоставить вставленный 
					элемент с соответсвующим свойством объекта из пользовательского кода.
					Поле только-для-четния.
					
					Дополнительный атрибут X_OFF_SHOWSIZE устанавливается в соответствии 
					со значением параметра off-showsize шаблона;
				-->
				<INPUT
					NAME="{b:GetUniqueNameFor(current())}"
					ID="{$html-id}FileSize" TYPE="TEXT" TABINDEX="-1" VALUE="" READONLY="1" DISABLED="1">
					<!-- 
						Обработка обязательных/необязательных свойств
						В случае обязательности свойства назначается спец. 
						стилевой класс
					 -->					
					<xsl:choose>
						<xsl:when test="'1'=$maybenull">
							<!-- Выставляем стиль не-обязательного свойства -->
							<xsl:attribute name="CLASS">x-editor-control</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<!-- Выставляем стиль обязательного свойства -->
							<xsl:attribute name="CLASS">x-editor-control-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</INPUT>
			</TD>
			<TD>
				<!-- 
					КНОПКА ДЛЯ ВЫЗОВА ОПЕРАЦИЙ НАД СВОЙСТВОМ 
					
					В качестве идентификатора используем атрибут html-id объектного 
					свойства. Это позволит в дальнейшем сопоставить вставленный 
					элемент с соответсвующим свойством объекта из кода.

					Дополнительный атрибут X_DESCR содержит описание свойства, 
					которое, в общем случае, может отличаться от описания 
					в метаданных. Этот атрибут позволит получить описание 
					сопоставленного с элементом свойства из кода.
					
					Дополнительные атрибуты X_FILTERS, X_MAX_FILE_SIZE, 
					X_FILE_NAME_IN, X_TITLE, X_IS_IMAGE, X_MAX_WIDTH, 
					X_MIN_WIDTH, X_MAX_HEIGHT, X_MIN_HEIGHT, X_OFF_VIEW 
					X_OFF_CLEAR и X_OFF_SHOWSIZE будут содержать входные
					параметры шаблона, что позволит обрабатывать их из кода.
				-->
				<BUTTON 
					NAME="{b:GetUniqueNameFor(current())}"
					ID="{$html-id}" 
					DISABLED="1"
					FileNameID="{$html-id}FileName"
					FileSizeID="{$html-id}FileSize" 
					CLASS="x-editor-file-button" 
					X_DESCR="{$description}"
					FileNameFilters="{$filters}"
					MaxFileSize="{$max-file-size}"
					PropertyType="{$vt}"
					PropertyNameToStoreFileName="{$file-name-in}"
					ChooseFileTitle="{$t}"
					IsPicture="{$is-image}"
					X_OFF_VIEW="{$off-view}" 
					X_OFF_CLEAR="{$off-clear}" 
					DoNotShowFileSize="{$off-showsize}"
					MaxImageWidth="{$max-width}" 
					MinImageWidth="{$min-width}" 
					MaxImageHeight="{$max-width}"
					MinImageHeight="{$min-height}"
					X_DISABLED="{$disabled+1}"
					X_PROPERTY_EDITOR = "XPEBinaryPresentationClass"
					
					TITLE="{$t}"
				>
						
					<!-- 
						Если свойство может принимать NULL-значение - выставим атрибут 
						X_MAYBENULL. Этот атрибут позволит контролировать допустимость 
						значения свойства при обработке из кода.
					-->
					<xsl:choose>
						<xsl:when test="'1'=$maybenull">
							<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<!-- 
						Символ, отображаемый кнопкой выбора.
						Внимание: для точного отображения символа исподьзуется 
						явное задание шрифта, перекрывающего возможные задания,
						сделанные через стилевой класс в CSS
					-->
					<xsl:choose>
						<xsl:when test="'dots'=$select-symbol">
							<!-- Символ: точки -->
							<SPAN STYLE="font-family:Verdana;">...</SPAN>
						</xsl:when>
						<xsl:otherwise>
							<!-- Все остальные случаи: стрелка -->
							<SPAN STYLE="font-family:Webdings">&#54;</SPAN>
						</xsl:otherwise>
					</xsl:choose>

				</BUTTON>
				<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" event="OnClick">
					<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").ShowMenu
				</SCRIPT>				
				<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnKeyUp">
					<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnKeyUp
				</SCRIPT>				
			</TD>
		</TR>
		</TBODY>
		</TABLE>
		
	</xsl:template>
</xsl:stylesheet>
