<?xml version="1.0" encoding="windows-1251"?>
<!--
*******************************************************************************
  XSL-шаблон элемента UI-представления скалярного объектного свойства 
  (для свойств с типом vt="object")
*******************************************************************************
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
	>

	<msxsl:script language="VBScript" implements-prefix="user">

		<![CDATA['<%
		' Формирует часть XPath запрса, содержащую фильтр по переданному метаимени
		' [in] sMetaName - метаимя
		Function GetMetaNameFilter( sMetaName )
			If IsNull(sMetaName) Or IsEmpty(sMetaName) Or sMetaName="" Then
				GetMetaNameFilter = "[(not(@n)) or (@n='')]"
			Else
				GetMetaNameFilter = "[@n='" & sMetaName & "']"
			End If
		End Function
		
		'%>']]>

	</msxsl:script>		

	<!--
		=============================================================================================
		Объекты страницы
			urn:object-editor-access - интерфейс объекта EditorData									
		Обрабатываемый элемент:																		
			Свойство объекта X-Storage
		Входные параметры:
			[in] disabled		- признак заблокированного поля
			[in] maybenull		- признак допустимости пустого значения	(0/1)										
			[in] description 	- описание поля
		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации объектных скалярных свойств 
			объекта
	-->		
	<xsl:template name="std-template-object">
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
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		
		<!-- 
			Возможно 2 варианта:
				1)	Первым в метаданных встретился i:object-presentation - выведем его
				2)	Первым в метаданных встретился i:object-dropdown - выведем его
		-->
		<xsl:choose>
			<xsl:when test="$xml-prop-md/i:object-presentation[1]">
				<xsl:call-template name="std-template-object-presentation">
					<xsl:with-param name="description"><xsl:value-of select="$description"/></xsl:with-param>
					<xsl:with-param name="maybenull"><xsl:value-of select="$maybenull"/></xsl:with-param>
					<xsl:with-param name="disabled"><xsl:value-of select="$disabled"/></xsl:with-param>
					<xsl:with-param name="html-id"><xsl:value-of select="$html-id"/></xsl:with-param>
					<xsl:with-param name="xml-params" select="$xml-params"/>
					<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
				</xsl:call-template>
			</xsl:when>	
			<xsl:otherwise>
				<xsl:call-template name="std-template-object-dropdown">
					<xsl:with-param name="description"><xsl:value-of select="$description"/></xsl:with-param>
					<xsl:with-param name="maybenull"><xsl:value-of select="$maybenull"/></xsl:with-param>
					<xsl:with-param name="disabled"><xsl:value-of select="$disabled"/></xsl:with-param>
					<xsl:with-param name="html-id"><xsl:value-of select="$html-id"/></xsl:with-param>
					<xsl:with-param name="xml-params" select="$xml-params"/>
					<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		=============================================================================================
		Стандартный шаблон генерации элементов  отображения/модификации для объектных скалярных свойств
		объекта в виде выпадающего списка
		Объекты страницы
			urn:object-editor-access - интерфейс объекта EditorData									
		Обрабатываемый элемент:																		
			Свойство объекта X-Storage
		Входные параметры:
			[in] maybenull			- признак допустимости пустого значения	(0/1)										
			[in] description		- описание поля
			[in] metaname			- метанаименование списка объектов в метаданных
			[in] disabled			- признак заблокированного поля
			[in] no-empty-value		- признак отсутствия пустого значения
			[in] empty-value-text	- текст первого элемента выпадающего списка
			[in] use-cache			- признак использования кэша при загрузке данных с сервера (по умолчанию не используется) (0/1)	
			[in] cache-salt			- выражение на VBS, если указан то используется как дополнительный ключ для наименования элемента кэша
										Пример:
											cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;)" - данные кэша становятся недействительными при смене метаданных
											cache-salt="clng(date())" - данные кэша становятся недействительными раз в сутки
											cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;) &amp; &quot;-&quot; &amp; clng(date())" - данные кэша становятся недействительными раз в сутки или при смене метаданных
											cache-salt="MyVbsFunctionName()" - вызывается прикладная функция
		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации объектных скалярных свойств 
			объекта
	-->		
	<xsl:template name="std-template-object-dropdown">
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
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:object-dropdown/@n))"/>
		<!-- метаданные pe: i:object-dropdown -->
		<xsl:param name="pe-md" select="$xml-prop-md/i:object-dropdown[($metaname='' and not(@n)) or ($metaname=@n)]"/>
		<!-- Параметр: метанаименование списка, используемого для заполнения комбобокса -->
		<xsl:param name="list-metaname" select="b:nvl(string($xml-params/@list-metaname), string($pe-md/@use-list))" />
		<!-- Параметр: признак использования CROC.XComboBox вместо обычного комбобокса -->
		<xsl:param name="use-activex" select="b:nvl(string($xml-params/@use-activex), string($pe-md/@use-activex))"/>
		<!-- Параметр: не добавлять пустую строку в комбобокс (по умолчанию добавляется) -->
		<xsl:param name="no-empty-value" select="b:nvl(string($xml-params/@no-empty-value), string($pe-md/@no-empty-value))"/>
		<!-- Параметр: Текст пустого элемента выпадающего списка -->
		<xsl:param name="empty-value-text" select="b:nvl(string($xml-params/@empty-value-text), string($pe-md/@empty-value-text))"/>
		<!-- Параметр: Признак кэширования -->
		<xsl:param name="use-cache" select="b:nvl(string($xml-params/@use-cache), string($pe-md/@use-cache))"/>
		<!-- Параметр: Дополнительный параметр кэширования -->
		<xsl:param name="cache-salt" select="b:nvl(string($xml-params/@cache-salt), string($pe-md/@cache-salt))"/>
		<!-- Параметр: Cокрытие элемента управления, позволяющего перезагрузить кэш  -->
		<xsl:param name="off-reload" select="b:nvl(string($xml-params/@off-reload), string($pe-md/@off-reload))"/>
			
		<!-- Параметр: Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		<!-- признак отображения кнопки перезагрузки списка -->
		<xsl:variable name="show-reload-button" select="('1'=$use-cache) and ('1'!=$off-reload)"/>
		
		<!-- 
			В качестве идентификатора используем атрибут html-id объектного 
			свойства. Это позволит в дальнейшем сопоставить вставленный 
			элемент с соответсвующим свойством объекта из кода.

			Дополнительный атрибут X_DESCR будет хранить описание свойства, 
			которое,в общем случае может отличаться от заданного в метаданных.
			Этот атрибут позволит получить описание сопоставленного с элементом
			свойства из кода.

			Атрибут X_METANAME содержит метанаименование списка объектов.
			Атрибут X_DISABLED содержит признак блокированности элемента (0/1)
		-->
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
			<COL WIDTH="100%;"/>
			<xsl:if test="$show-reload-button">
				<COL STYLE="padding-left:3px;"/>
			</xsl:if>
		<TBODY>
			<TR>
				<TD>
				<xsl:choose>
					<!-- 
						UI-ПРЕДСТАВЛЕНИЕ СКАЛЯРНОГО ОБЪЕКТНОГО СВОЙСТВА: РЕДАКТИРУЕМЫЙ ВЫПАДАЮЩИЙ СПИСОК
					-->
					<xsl:when test="$use-activex='1'">
						<OBJECT
							ID="{$html-id}"
							CLASSID="{b:Evaluate('CLSID_COMBOBOX')}" 
							BORDER="0"
							WIDTH="100%"
							TABINDEX="0"
							NAME="{b:GetUniqueNameFor(current())}"
						
							X_LISTMETANAME="{$list-metaname}" 
							X_DESCR="{$description}"
							X_DISABLED="{$disabled+1}"
							PEMetadataLocator="{concat( 'i:object-dropdown',user:GetMetaNameFilter( string( $metaname )))}"
							X_PROPERTY_EDITOR = "XPEObjectDropdownClass"
							NoEmptyValue = "{$no-empty-value}"
							EmptyValueText="{$empty-value-text}"
							UseCache="{$use-cache}" 
							CacheSalt="{$cache-salt}" 
							RefreshButtonID = "{$html-id}Refresh"
						>
							<!-- Обработка обязательных/необязательных свойств -->
							<xsl:choose>
								<xsl:when test="'1'=$maybenull">
									<!-- 
										Если свойство может принимать значение null - выставим дополнительный
										атрибут X_MAYBENULL.
										Этот атрибут позволит контролировать допустимость значения св-ва при
										обработке из кода.
									-->						
									<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
									<!-- Выставляем стиль не-обязательного свойства -->
									<xsl:attribute name="CLASS">x-editor-control x-editor-dropdown x-editor-dropdown-activex</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<!-- Выставляем стиль обязательного свойства -->
									<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-dropdown  x-editor-dropdown-activex</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
	 
							<PARAM NAME="Enabled" VALUE="0"></PARAM>
							<PARAM NAME="Editable" VALUE="-1"></PARAM>
							<PARAM NAME="AutoSearch" VALUE="-1"></PARAM>
							<PARAM NAME="EmptySelectionText" VALUE="{$empty-value-text}"></PARAM>
							<PARAM NAME="LockHtmlKeyboardEvents" VALUE="-1"></PARAM>
						</OBJECT>
						
						<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnItemSelect( ByVal oSender, ByVal nItemIndex, ByVal sItemID, sText )">
							If 0 = Len(sItemID) Then oSender.text = oSender.EmptySelectionText
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnChange
						</SCRIPT>
						<SCRIPT FOR="{$html-id}" EVENT="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" LANGUAGE="VBScript">
							window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpAsync " &amp; nKeyCode &amp; "," &amp; nFlags, 0, "VBScript"
						</SCRIPT>
					</xsl:when>
			
					<!-- 
						UI-ПРЕДСТАВЛЕНИЕ СКАЛЯРНОГО ОБЪЕКТНОГО СВОЙСТВА: ВЫПАДАЮЩИЙ СПИСОК
					-->
					<xsl:otherwise>
						<SELECT
							ID="{$html-id}" 
							DISABLED="1" STYLE="width:100%" 
							
							X_LISTMETANAME="{$list-metaname}" 
							X_DESCR="{$description}"
							X_DISABLED="{$disabled+1}"
							PEMetadataLocator="{concat( 'i:object-dropdown',user:GetMetaNameFilter( string( $metaname )))}"
							X_PROPERTY_EDITOR = "XPEObjectDropdownClass"
							NoEmptyValue = "{$no-empty-value}"
							EmptyValueText="{$empty-value-text}" 
							UseCache="{$use-cache}" 
							CacheSalt="{$cache-salt}" 
							RefreshButtonID = "{$html-id}Refresh"
						>
							<!-- Обработка обязательных/необязательных свойств -->
							<xsl:choose>
								<xsl:when test="'1'=$maybenull">
									<!-- 
										Если свойство может принимать значение null - выставим дополнительный
										атрибут X_MAYBENULL.
										Этот атрибут позволит контролировать допустимость значения св-ва при
										обработке из кода.
									-->						
									<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
									<!-- Выставляем стиль не-обязательного свойства -->
									<xsl:attribute name="CLASS">x-editor-control x-editor-dropdown</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<!-- Выставляем стиль обязательного свойства -->
									<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-dropdown</xsl:attribute>
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
					</xsl:otherwise>
				</xsl:choose>
				</TD>
					
				<xsl:if test="$show-reload-button">
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
					<SCRIPT FOR="{$html-id}Refresh" LANGUAGE="VBScript" event="OnClick">
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
		Стандартный шаблон генерации элементов  отображения/модификации для объектных скалярных свойств
		объекта в виде стргоки представления объекта и кнопки операций над ним
		Объекты страницы
			urn:object-editor-access - интерфейс объекта EditorData									
		Обрабатываемый элемент:																		
			Свойство объекта X-Storage
		Входные параметры:
			[in] maybenull		- признак допустимости пустого значения	(0/1)										
			[in] description	- описание поля
			[in] metaname		- имя i:object-presentation в метаданых
			[in] disabled		- признак заблокированного поля
			[in] off-create		- запрещение операции создать
			[in] off-select		- запрещение операции выбрать
			[in] off-edit		- запрещение операции изменить
			[in] off-unlink 	- запрещение операции разорвать связь
			[in] off-delete		- запрещение операции удалить
		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации объектных скалярных свойств 
			объекта
	-->		
	<xsl:template name="std-template-object-presentation">
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
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:object-presentation/@n))"/>
		<!-- метаданные pe: i:object-dropdown -->
		<xsl:param name="pe-md" select="$xml-prop-md/i:object-presentation[($metaname='' and not(@n)) or ($metaname=@n)]"/>
		<!-- Управление операциями -->
		<xsl:param name="off-create" select="b:nvl(string($xml-params/@off-create), string($pe-md/@off-create))"/>
		<xsl:param name="off-edit"   select="b:nvl(string($xml-params/@off-edit),   string($pe-md/@off-edit))"/>
		<xsl:param name="off-select" select="b:nvl(string($xml-params/@off-select), string($pe-md/@off-select))"/>
		<xsl:param name="off-unlink" select="b:nvl(string($xml-params/@off-unlink), string($pe-md/@off-unlink))"/>
		<xsl:param name="off-delete" select="b:nvl(string($xml-params/@off-delete), string($pe-md/@off-delete))"/>
		<!-- Параметр: запрещение всех операций -->
		<xsl:param name="off-operations" select="b:nvl(string($xml-params/@off-operations), string($pe-md/@off-operations))"/>
		<!-- Параметр: символ, отображаемый кнопкой выбора (на данный момент на задается метаданными) -->
		<xsl:param name="select-symbol" select="b:nvl(string($xml-params/@select-symbol), 'arrow')"/>
		<!-- наименование радактора, используемого для создания объекта -->
		<xsl:param name="use-for-creation" select="b:nvl(string($xml-params/@use-for-creation), string($pe-md/@use-for-creation))"/>
		<!-- наименование радактора, используемого для редактирования объекта -->
		<xsl:param name="use-for-editing" select="b:nvl(string($xml-params/@use-for-editing), string($pe-md/@use-for-editing))"/>
		<!-- наименование списка, используемого для выбора -->
		<xsl:param name="use-list-selector" select="b:nvl(string($xml-params/@use-list-selector), string($pe-md/@use-list-selector))"/>
		<!-- наименование дерева, используемого для выбора -->
		<xsl:param name="use-tree-selector" select="b:nvl(string($xml-params/@use-tree-selector), string($pe-md/@use-tree-selector))"/>
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>			
		<!-- признак автоматического изменения тултипа для текстового поля -->
		<xsl:param name="auto-tooltip" select="b:nvl(string($xml-params/@auto-tooltip), string($pe-md/@auto-tooltip))"/>
			
		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		<!-- выражение для вычисления представления свойства в Html -->
		<xsl:variable name="expression" select="string($pe-md/i:value)"/>
			
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
			<COL WIDTH="100%;"/>
			<COL STYLE="padding-left:3px;"/>
		<TBODY>
		<TR>
			<TD>
				<!-- 
					ПОЛЕ ДЛЯ ВЫВОДА ТЕКСТА ПРЕДСТАВЛЕНИЯ ОБЪЕКТА 
					
					Read-only поле (только для чтения)
					В качестве основы для идентификатора используем атрибут 
					html-id обрабатываемого объектного свойства. Это позволит 
					сопоставить вставленный элемент с соответсвующим свойством 
					объекта из прикладного кода.
				-->
				<INPUT ID="{$html-id}Caption" TYPE="TEXT" READONLY="1" TABINDEX="-1" VALUE="" DISABLED="1" STYLE="width:100%">
					<!-- Обработка обязательных/необязательных свойств -->
					<xsl:choose>
						<xsl:when test="1=$maybenull">
							<xsl:attribute name="CLASS">x-editor-control x-editor-objectpresentation-text</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-objectpresentation-text</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</INPUT>
			</TD>
			<TD>
				<!--
					КНОПКА ОПЕРАЦИЙ С ОБЪЕКТОМ, ОТОБРАЖАЕМЫМ ЭЛЕМЕНТОМ
					Не отображается, если все действия с объектом зпрещены:
					прячем всю ячейку "раскладки"
				-->
					<xsl:if test="$off-operations">
						<xsl:attribute name="STYLE">display:none</xsl:attribute>
					</xsl:if>
					
				<!-- 
					В качестве идентификатора используем атрибут html-id 
					обрабатываемого объектного свойства. Это позволит в 
					дальнейшем сопоставить вставленный элемент с соответсвующим 
					свойством объекта из кода.

					Атрибут X_DESCR будет хранить описание свойства, которое, 
					в общем случае может отличаться от описания в метаданных. 
					Этот атрибут позволит получить описание сопоставленного 
					с элементом свойства из кода.
				-->
				
				<!--
					!!! ДИНАМИЧЕСКИЙ СТИЛЬ РАБОТАЕТ, НО СИЛЬНО ТОРМОЗИТ!!!
					STYLE="
						position:relative; overflow-y:hidden; overflow-x:visible; 
						height:expression(document.all(this.INPUTID).offsetHeight); width:expression(this.clientHeight);
						line-height:expression(this.offsetHeight/2+'px');"
				-->
				<BUTTON
					ID="{$html-id}" DISABLED="1" 
					CLASS="x-editor-objectpresentation-button"
					NAME="{b:GetUniqueNameFor(current())}"
					
					INPUTID="{$html-id}Caption" 
					
					X_PROPERTY_EDITOR = "XPEObjectPresentationClass"
					X_DESCR="{$description}" 
					X_DISABLED="{$disabled+1}"
					
					PEMetadataLocator = "{concat( 'i:object-presentation',user:GetMetaNameFilter( string( $metaname )))}"
					
					OFF_CREATE ="{$off-create}"
					OFF_EDIT   ="{$off-edit}"
					OFF_SELECT ="{$off-select}"
					OFF_UNLINK ="{$off-unlink}"
					OFF_DELETE ="{$off-delete}"
					EditorMetanameForCreating = "{$use-for-creation}"
					EditorMetanameForEditing  = "{$use-for-editing}"
					ListSelectorMetaname = "{$use-list-selector}"
					TreeSelectorMetaname = "{$use-tree-selector}"
					ObjectPresentationExpression="{$expression}" 
					AutoToolTip="{$auto-tooltip}"
				>
					<!-- если все действия запрещены - то и установка фокуса так же запрещена -->
					<xsl:if test="$off-operations">
						<xsl:attribute name="TABINDEX">-1</xsl:attribute>
					</xsl:if>						
					
					<!-- 
						Если свойство может принимать значение null - выставим 
						атрибут X_MAYBENULL. Этот атрибут позволит контролировать 
						допустимость значения свойства при обработке из кода.
					-->						
					<xsl:if test="'1'=$maybenull">
						<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
					</xsl:if>
					
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
