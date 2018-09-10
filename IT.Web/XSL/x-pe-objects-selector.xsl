<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	страница генерации элементов отображения/модификации для массивных объектных свойств в види списка-селектора
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
		Стандартный шаблон генерации элементов  отображения/модификации для объектных нескалярных свойств
		объекта
		Объекты страницы
			urn:object-editor-access - интерфейс объекта EditorData									
			urn:editor-window-access - интерфейс окна редактора								
		Обрабатываемый элемент:																		
			Свойство объекта X-Storage
		Входные параметры:
			[in] height - высота таблицы для редактирования массивного свойств
			[in] metaname - метаимя списка
			[in] description - описание поля
			[in] use-cache			- признак использования кэша при загрузке данных с сервера (по умолчанию не используется) (0/1)	
			[in] cache-salt			- выражение на VBS, если указан то используется как дополнительный ключ для наименования элемента кэша
										Пример:
											cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;)" - данные кэша становятся недействительными при смене метаданных
											cache-salt="clng(date())" - данные кэша становятся недействительными раз в сутки
											cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;) &amp; &quot;-&quot; &amp; clng(date())" - данные кэша становятся недействительными раз в сутки или при смене метаданных
											cache-salt="MyVbsFunctionName()" - вызывается прикладная функция
			
		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации объектных нескалярных свойств 
			объекта
	-->		
	<xsl:template name="std-template-objects-selector">
		<!-- xml со всеми параметрами шаблона -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml с металданными -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- Параметр: доступность -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- Параметр: описание поля -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
		<!-- Параметр: доступность -->
		<xsl:param name="height" select="b:nvl(string($xml-params/@height),'100%')"/>
		<!-- Параметр: имя PropertyEditor'a в метаданных -->
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:list-selector/@n))"/>
		<!-- метаданные pe: i:object-dropdown -->
		<xsl:param name="pe-md" select="$xml-prop-md/i:list-selector[($metaname='' and not(@n)) or ($metaname=@n)]"/>
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>	
		<!-- Параметр: метанаименование списка, используемого для заполнения ListView -->
		<xsl:param name="list-metaname" select="b:nvl(string($xml-params/@list-metaname), string($pe-md/@use-list))"/>
		
		<!-- Управление режимами списка -->		
		<xsl:param name="off-sortcolumn" select="b:nvl(string($xml-params/@off-sortcolumn),  string($pe-md/@off-sortcolumn))"/>
		<xsl:param name="off-movecolumn" select="b:nvl(string($xml-params/@off-movecolumn),  string($pe-md/@off-movecolumn))"/>
		<xsl:param name="off-rownumbers" select="b:nvl(string($xml-params/@off-rownumbers),  string($pe-md/@off-rownumbers))"/>
		<xsl:param name="off-icons" select="b:nvl(string($xml-params/@off-icons),  string($pe-md/@off-icons))"/>
		
		<!-- Параметр: Признак кэширования -->
		<xsl:param name="use-cache" select="b:nvl(string($xml-params/@use-cache), string($pe-md/@use-cache))"/>
		<!-- Параметр: Дополнительный параметр кэширования -->
		<xsl:param name="cache-salt" select="b:nvl(string($xml-params/@cache-salt), string($pe-md/@cache-salt))"/>

		<!-- Параметр: Cокрытие элемента управления, позволяющего перезагрузить кэш  -->
		<xsl:param name="off-reload" select="b:nvl(string($xml-params/@off-reload), string($pe-md/@off-reload))"/>
		<!-- Параметр: Cокрытие элементов управления, позволяющих управлять массовым выделением -->
		<xsl:param name="off-select-all" select="b:nvl(string($xml-params/@off-select-all), string($pe-md/@off-select-all))"/>
		<xsl:param name="off-select-none" select="b:nvl(string($xml-params/@off-select-none), string($pe-md/@off-select-none))"/>
		<xsl:param name="off-select-invert" select="b:nvl(string($xml-params/@off-select-invert), string($pe-md/@off-select-invert))"/>
		<!-- Параметр: запрещение всех операций (либо передан как параметр шаблона, либо указано как атрибут off-operations в МД -->
		<xsl:param name="off-operations" select="b:nvl(string($xml-params/@off-operations),string($pe-md/@off-operations))='1'"/>

		<!-- Емкость свойства -->
		<xsl:variable name="capacity" select="string($xml-prop-md/@cp)"/>
		<!-- Индексное свойство для link'а -->
		<xsl:variable name="order-by" select="string($xml-prop-md/@order-by)"/>
		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>

		<!-- Таблица редактора массивного объектного свойства -->
		<TABLE CELLPADDING="0" CELLSPACING="3" BORDER="0" WIDTH="100%" HEIGHT="{$height}">
			<TR>
				<TD HEIGHT="100%" WIDTH="100%">
					<DIV 
						STYLE="position:relative; width:100%; height:100%;" 
						CLASS="x-editor-control x-editor-objects-list">
					<!-- 
						ACTIVEX - СПИСОК ОБЪЕКТОВ ДЛЯ ВЫБОРА
						
						В качестве идентификатора используем атрибут html-id 
						обрабатываемого объектного свойства. Это позволит 
						в дальнейшем сопоставить вставленный элемент со 
						соответсвующим свойством объекта из кода.
						
						Дополнительные атрибуты, содержащие данные, доступные 
						из кода обслуживания и прикладного кода:
						
						Атрибут X_DESCR хранит описание, которое в общем случае 
						может отличаться от описания в метаданных.
					-->					
					<OBJECT 
						ID="{$html-id}"
						NAME="{b:GetUniqueNameFor(current())}"
						CLASSID="{w:get-CLSID_LIST_VIEW()}" 
						BORDER="0" TABINDEX="0"
						WIDTH="100%" HEIGHT="100%"
						
						X_DESCR = "{$description}"
						
						ListMetaname = "{$list-metaname}" 
						PEMetadataLocator = "i:list-selector[('{$metaname}'='' and not(@n)) or ('{$metaname}'=@n)]"
						X_DISABLED="{$disabled+1}"
						X_PROPERTY_EDITOR = "XPEObjectsSelectorClass"
						
						UseCache="{$use-cache}" 
						CacheSalt="{$cache-salt}" 
						RefreshButtonID = "{$html-id}Refresh"
					>
						<xsl:if test="$off-rownumbers='1'">
							<xsl:attribute name="off-rownumbers">1</xsl:attribute>
						</xsl:if>
						<xsl:if test="$off-icons='1'">
							<xsl:attribute name="off-icons">1</xsl:attribute>
						</xsl:if>
						<PARAM NAME="Enabled" VALUE="0"></PARAM>
						<xsl:if test="$off-sortcolumn or 'array'=$capacity">
							<PARAM NAME="AllowSorting" VALUE="0"></PARAM>
						</xsl:if>
						<PARAM NAME="ShowIcons" VALUE="0"></PARAM>
						<xsl:if test="$off-movecolumn" >
							<PARAM NAME="AllowChangePositions" VALUE="0"></PARAM>
						</xsl:if>
						<PARAM NAME="LockHtmlKeyboardEvents" VALUE="-1"></PARAM>
					</OBJECT>
					<SCRIPT for="{$html-id}" event="OnCheckChange(ByVal oSender, ByVal nRow , ByVal sRowID, ByVal bPrevState, ByVal bNewState)" language="VBScript">
						window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnCheckChange " &amp; nRow &amp; ",""" &amp; sRowID &amp; """," &amp; CLng(bPrevState) &amp; "," &amp; CLng(bNewState), 0, "VBScript"
					</SCRIPT>
					<SCRIPT for="{$html-id}" event="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" language="VBScript">
						window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpAsync " &amp; nKeyCode &amp; "," &amp; nFlags, 0, "VBScript"
					</SCRIPT>
					</DIV>
				</TD>
			</TR>
			
			<TR>
				<xsl:if test="'1'=$off-operations">
					<xsl:attribute name="style">display:none;</xsl:attribute>
				</xsl:if>
				<TD STYLE="width:100%;">
				<DIV STYLE="position:relative; width:100%;">
				
					<!-- NB! Определение этой кнопки д.б. первым, т.к. у DIV - абсолютное позиционирование -->
					<xsl:if test="(1=$use-cache) and (1!=$off-reload)">
						<DIV STYLE="position:absolute; left:0px; top:0px; width:100%; text-align:right;">
						<BUTTON 
							ID="{$html-id}Refresh" 
							NAME="{b:GetUniqueNameFor(current())}"
							TITLE="Обновить данные списка"
							DISABLED="1" 
							CLASS="x-editor-objectpresentation-button" 
							STYLE="background-color:#cccccc; border-color:#eeeeee; padding:0px; height:20px; width:20px;"
							TABINDEX="-1"
						>
							<IMG SRC="Images/x-reload.gif" STYLE="overflow:hidden; margin:-2px; border:none; border-width:0px;"/>
						</BUTTON>
						<SCRIPT FOR="{$html-id}Refresh" LANGUAGE="VBScript" event="OnClick">
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Reload
						</SCRIPT>
						</DIV>
					</xsl:if>
				
					<BUTTON 
						ID="{$html-id}SelectAll"
						NAME="{b:GetUniqueNameFor(current())}"
						CLASS="x-editor-objectpresentation-button" 
						TITLE="Выбрать все элементы" 
						DISABLED="1" 
						STYLE = "margin-right:3px;"
					>
						<xsl:if test="'1'=$off-select-all">
							<xsl:attribute name="style">display:none;</xsl:attribute>
						</xsl:if>
						<CENTER>Выбрать все</CENTER></BUTTON>
					<SCRIPT FOR="{$html-id}SelectAll" LANGUAGE="VBScript" event="OnClick">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").SelectAll
					</SCRIPT>
					
					<BUTTON 
						ID="{$html-id}InvertSelection" 
						NAME="{b:GetUniqueNameFor(current())}"
						CLASS="x-editor-objectpresentation-button" 
						TITLE="Изменить выделение элементов" 
						DISABLED="1" 
						STYLE = "margin-right:3px;"
					>
						<xsl:if test="'1'=$off-select-invert">
							<xsl:attribute name="style">display:none;</xsl:attribute>
						</xsl:if>
						<CENTER>Изменить выделение</CENTER>
					</BUTTON>
					<SCRIPT FOR="{$html-id}InvertSelection" LANGUAGE="VBScript" event="OnClick">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").InvertSelection
					</SCRIPT>
					
					<BUTTON 
						ID="{$html-id}DeselectAll" 
						NAME="{b:GetUniqueNameFor(current())}"
						CLASS="x-editor-objectpresentation-button" 
						TITLE="Снять выделение" 
						DISABLED="1" 
						STYLE = "margin-right:3px;"
					>
						<xsl:if test="'1'=$off-select-none">
							<xsl:attribute name="style">display:none;</xsl:attribute>
						</xsl:if>
						<CENTER>Снять выделение</CENTER>
					</BUTTON>
					<SCRIPT FOR="{$html-id}DeselectAll" LANGUAGE="VBScript" event="OnClick">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").DeselectAll
					</SCRIPT>

				</DIV>
				</TD>
			</TR>
		</TABLE>
	</xsl:template>
</xsl:stylesheet>
