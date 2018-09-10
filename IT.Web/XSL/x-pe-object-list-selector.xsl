<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	страница генерации элементов отображения/модификации для скалярных объектных свойств в види списка-селектора 
	(список с чекбоксами, но с единичным выбором)
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
		Объекты страницы
			urn:object-editor-access - интерфейс объекта EditorData									
			urn:editor-window-access - интерфейс окна редактора								
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
	-->		
	<xsl:template name="std-template-object-list-selector">
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
		<!-- Параметр: Наименование objects-list'a, используемого для выбора значения из списка в диалоговом окне -->
		<xsl:param name="list-selector-metaname" select="b:nvl(string($xml-params/@list-selector-metaname), string($pe-md/@use-list-selector))"/>
		<!-- Параметр: Наименование objects-tree-selector'a, используемого для выбора значения из дерева в диалоговом окне -->
		<xsl:param name="tree-selector-metaname" select="b:nvl(string($xml-params/@tree-selector-metaname), string($pe-md/@use-tree-selector))"/>
		
		<!-- Управление режимами списка -->		
		<xsl:param name="off-sortcolumn" select="b:nvl(string($xml-params/@off-sortcolumn),  string($pe-md/@off-sortcolumn))"/>
		<xsl:param name="off-movecolumn" select="b:nvl(string($xml-params/@off-movecolumn),  string($pe-md/@off-movecolumn))"/>

		<!-- Параметр: Признак кэширования -->
		<xsl:param name="use-cache" select="b:nvl(string($xml-params/@use-cache), string($pe-md/@use-cache))"/>
		<!-- Параметр: Дополнительный параметр кэширования -->
		<xsl:param name="cache-salt" select="b:nvl(string($xml-params/@cache-salt), string($pe-md/@cache-salt))"/>
		<!-- Параметр: Cокрытие элемента управления, позволяющего перезагрузить кэш  -->
		<xsl:param name="off-reload" select="b:nvl(string($xml-params/@off-reload), string($pe-md/@off-reload))"/>

		<!-- Емкость свойства -->
		<xsl:variable name="capacity" select="string($xml-prop-md/@cp)"/>
		<!-- Индексное свойство для link'а -->
		<xsl:variable name="order-by" select="string($xml-prop-md/@order-by)"/>
		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>

		<!-- Таблица редактора массивного объектного свойства -->
		<TABLE CELLPADDING="0" CELLSPACING="3" BORDER="0" WIDTH="100%" HEIGHT="{$height}">
			<TR>
				<TD HEIGHT="100%" WIDTH="100%" COLSPAN="2">
					<DIV 
						STYLE="position:relative; width:100%; height:100%;" 
						CLASS="x-editor-control x-editor-objects-list">
						<OBJECT 
							ID="{$html-id}"
							NAME="{b:GetUniqueNameFor(current())}"
							CLASSID="{w:get-CLSID_LIST_VIEW()}" 
							BORDER="0" TABINDEX="0"
							WIDTH="100%" HEIGHT="100%"
							
							X_DESCR = "{$description}"
							X_PROPERTY_EDITOR = "XPEObjectListSelectorClass"
							X_DISABLED="{$disabled+1}"
							
							PEMetadataLocator = "i:list-selector[('{$metaname}'='' and not(@n)) or ('{$metaname}'=@n)]"
							ListMetaname = "{$list-metaname}" 
							ListSelectorMetaname = "{$list-selector-metaname}"
							TreeSelectorMetaname = "{$tree-selector-metaname}"
							UseCache="{$use-cache}" 
							CacheSalt="{$cache-salt}" 
							RefreshButtonID = "{$html-id}Refresh"
						>
							<xsl:if test="'1'=$maybenull">
								<!-- 
									Если свойство может принимать значение null - выставим дополнительный
									атрибут X_MAYBENULL.
									Этот атрибут позволит контролировать допустимость значения св-ва при
									обработке из кода.
								-->						
								<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
							</xsl:if>
							<PARAM NAME="Enabled" VALUE="0"></PARAM>
							<xsl:if test="$off-sortcolumn">
								<PARAM NAME="AllowSorting" VALUE="0"></PARAM>
							</xsl:if>
							<xsl:if test="$pe-md/icon-selector" >
								<PARAM NAME="ShowIcons" VALUE="-1"></PARAM>
							</xsl:if>
							<xsl:if test="$off-movecolumn" >
								<PARAM NAME="AllowChangePositions" VALUE="0"></PARAM>
							</xsl:if>
							<PARAM NAME="LockHtmlKeyboardEvents" VALUE="-1"></PARAM>
						</OBJECT>
						<SCRIPT for="{$html-id}" event="OnCheckChange(ByVal oSender, ByVal nRow , ByVal sRowID, ByVal bPrevState, ByVal bNewState)" language="VBScript">
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnCheckChange nRow, sRowID, bPrevState, bNewState
						</SCRIPT>
						<SCRIPT for="{$html-id}" event="OnDblClick(ByVal oSender, ByVal nIndex , ByVal nColumn, ByVal sID)" language="VBScript">
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnDblClick nIndex, nColumn, sID
						</SCRIPT>
						<SCRIPT FOR="{$html-id}" EVENT="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" LANGUAGE="VBScript">
							window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpAsync " &amp; nKeyCode &amp; "," &amp; nFlags, 0, "VBScript"
						</SCRIPT>
					</DIV>
				</TD>
			</TR>
			
			<TR><TD><TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" WIDTH="100%">
				<TR>
				<TD>
					<BUTTON 
						ID="{$html-id}Deselect" 
						NAME="{b:GetUniqueNameFor(current())}"
						CLASS = "x-button x-editor-objects-opbutton"
						TITLE="Очистить" 
						DISABLED="1" STYLE = "margin-right:3px;"
					><CENTER>Очистить</CENTER></BUTTON>
					<SCRIPT FOR="{$html-id}Deselect" LANGUAGE="VBScript" event="OnClick">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Deselect
					</SCRIPT>
				</TD>
				<xsl:if test="$list-selector-metaname or $tree-selector-metaname">
					<TD>
						<BUTTON 
							ID="{$html-id}Select" 
							NAME="{b:GetUniqueNameFor(current())}"
							CLASS = "x-button x-editor-objects-opbutton"
							TITLE="Выбрать значение" 
							DISABLED="1" STYLE = "margin-right:3px;"
						><CENTER>Выбрать</CENTER></BUTTON>
						<SCRIPT FOR="{$html-id}Select" LANGUAGE="VBScript" event="OnClick">
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnSelectClick
						</SCRIPT>
					</TD>
				</xsl:if>
				<TD WIDTH="100%"/>
				<xsl:if test="(1=$use-cache) and (1!=$off-reload)">
					<TD>
						<BUTTON 
							ID="{$html-id}Refresh" 
							NAME="{b:GetUniqueNameFor(current())}"
							TITLE="Обновить данные списка"
							DISABLED="1" 
							CLASS = "x-button x-editor-objects-opbutton"
							STYLE="background-color:#cccccc; border-color:#eeeeee; padding:0px; height:20px; width:20px;"
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
			</TABLE></TD></TR>
		</TABLE>
	</xsl:template>
</xsl:stylesheet>
