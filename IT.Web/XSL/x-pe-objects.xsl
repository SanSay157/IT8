<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	Стандартная страница генерации элементов  отображения/модификации для нескалярных объектных свойств 
	объекта
-->	
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:XFW="http://www.croc.ru/XmlFramework/Behaviors"

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
			[in] menu-style - режим отображения меню (значение по умолчанию берется из i:prop-menu/@menu-style)
				Значения: op-button (по умолчанию), vertical-buttons, horizontal-buttons
			[in] button-width - ширина кнопки меню
			[in] button-height- высота кнопки меню
			[in] off-create	- запрещение операции создать
			[in] off-select	- запрещение операции выбрать
			[in] off-edit	- запрещение операции изменить
			[in] off-unlink 	- запрещение операции разорвать связь
			[in] off-delete		- запрещение операции удалить
			[in] off-position - запрещение операций перемещения вверх/вниз
			[in] lbl-position-up - надпись на кнопке операций перемещения вверх
			[in] lbl-position-down - надпись на кнопке операций перемещения вниз
			
		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации объектных нескалярных свойств 
			объекта
	-->		
	<xsl:template name="std-template-objects">
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
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:elements-list/@n))"/>
		<!-- метаданные pe: i:elements-list-->
		<xsl:param name="pe-md" select="$xml-prop-md/i:elements-list[($metaname='' and not(@n)) or ($metaname=@n)]"/>
		
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>

		<!-- Выключалки кнопок -->
		<xsl:param name="off-create"   select="b:nvl(string($xml-params/@off-create),  string($pe-md/@off-create))"/>
		<xsl:param name="off-select"   select="b:nvl(string($xml-params/@off-select),  string($pe-md/@off-select))"/>
		<xsl:param name="off-edit"     select="b:nvl(string($xml-params/@off-edit),    string($pe-md/@off-edit))"/>
		<xsl:param name="off-unlink"   select="b:nvl(string($xml-params/@off-unlink),  string($pe-md/@off-unlink))"/>
		<xsl:param name="off-delete"   select="b:nvl(string($xml-params/@off-delete),  string($pe-md/@off-delete))"/>
		<xsl:param name="off-position" select="b:nvl(string($xml-params/@off-position),string($pe-md/@off-position))"/>

		<!-- Подписи к кнопкам -->
		<xsl:param name="lbl-position-up"   select="b:nvl(string($xml-params/@lbl-position-up),   string($pe-md/@lbl-position-up))"/>
		<xsl:param name="lbl-position-down" select="b:nvl(string($xml-params/@lbl-position-down), string($pe-md/@lbl-position-down))"/>
		<!-- Управление режимами списка -->
		<xsl:param name="off-sortcolumn"   select="b:nvl(string($xml-params/@off-sortcolumn), string($pe-md/@off-sortcolumn))"/>
		<xsl:param name="off-movecolumn"   select="b:nvl(string($xml-params/@off-movecolumn), string($pe-md/@off-movecolumn))"/>
		<!-- наименование радактора, используемого для создания объекта -->
		<xsl:param name="use-for-creation" select="b:nvl(string($xml-params/@use-for-creation), string($pe-md/@use-for-creation))"/>
		<!-- наименование радактора, используемого для редактирования объекта -->
		<xsl:param name="use-for-editing"  select="b:nvl(string($xml-params/@use-for-editing), string($pe-md/@use-for-editing))"/>
		<!-- наименование списка, используемого для выбора -->
		<xsl:param name="use-list-selector" select="b:nvl(string($xml-params/@use-list-selector), string($pe-md/@use-list-selector))"/>
		<!-- наименование дерева, используемого для выбора -->
		<xsl:param name="use-tree-selector" select="b:nvl(string($xml-params/@use-tree-selector), string($pe-md/@use-tree-selector))"/>
		<!-- VBS выражение для сокрытия строк списка -->
		<xsl:param name="hide-if" select="b:nvl(string($xml-params/@hide-if), string($pe-md/i:hide-if))"/>
		<!-- Режим отображения меню -->
		<xsl:param name="menu-style" select="b:nvl(string($xml-params/@menu-style), string($pe-md/i:prop-menu/@menu-style))"/>
		<!-- Вертикальное выравнивание кнопок: top или bottom -->
		<xsl:param name="buttons-valign" select="b:nvl(string($xml-params/@buttons-valign), string('bottom'))" />
		<!-- Ширина кнопок меню -->
		<xsl:param name="button-width" select="b:nvl(string($xml-params/@button-width), string($pe-md/i:prop-menu/@button-width))" />
		<!-- Высота кнопок меню -->
		<xsl:param name="button-height" select="b:nvl(string($xml-params/@button-height), string($pe-md/i:prop-menu/@button-height))" />

		<!-- Емкость свойства -->
		<xsl:variable name="capacity" select="string($xml-prop-md/@cp)"/>
		<!-- Индексное свойство для link'а -->
		<xsl:variable name="order-by" select="string($xml-prop-md/@order-by)"/>
		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>

		<!-- Таблица редактора массивного объектного свойства -->
		<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" WIDTH="100%" HEIGHT="{$height}" ID="{$html-id}Container">
			<TR>
				<TD HEIGHT="100%" WIDTH="100%" COLSPAN="2">
					<DIV STYLE="position:relative; width:100%; height:100%;" CLASS="x-editor-control x-editor-objects-list">
					<!-- 
						ACTIVEX - СПИСОК ОБЪЕКТОВ
						
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
						CLASSID="{b:Evaluate('CLSID_LIST_VIEW')}" 
						BORDER="0" TABINDEX="0"
						WIDTH="100%" HEIGHT="100%"
						
						X_PROPERTY_EDITOR = "XPEObjectsElementsListClass"
						X_DISABLED="{$disabled+1}"
						X_DESCR = "{$description}"
						
						HIDE_IF="{$hide-if}" 
						
						PEMetadataLocator = "i:elements-list[('{$metaname}'='' and not(@n)) or ('{$metaname}'=@n)]"
						OFF_CREATE ="{$off-create}"
						OFF_EDIT   ="{$off-edit}"
						OFF_SELECT ="{$off-select}"
						OFF_UNLINK ="{$off-unlink}"
						OFF_DELETE ="{$off-delete}"						
						EditorMetanameForCreating = "{$use-for-creation}"
						EditorMetanameForEditing  = "{$use-for-editing}"
						ListSelectorMetaname = "{$use-list-selector}"
						TreeSelectorMetaname = "{$use-tree-selector}"
					>
						<xsl:if test="('1'!=$off-position) and (('array'=$capacity) or ('link'=$capacity and $order-by))">
							<xsl:attribute name="X_SHIFT_OPERATIONS">1</xsl:attribute>
						</xsl:if>
					
						<PARAM NAME="Enabled" VALUE="0"></PARAM>
						<PARAM NAME="ShowBorder" VALUE="0"></PARAM>
						
						<xsl:if test="('1'=$off-sortcolumn) or ('1'=$off-position) or (('1'!=$off-position) and (('array'=$capacity) or ('link'=$capacity and $order-by!='')))">
							<PARAM NAME="AllowSorting" VALUE="0"></PARAM>
						</xsl:if>
						<xsl:if test="'1'=$off-movecolumn" >
							<PARAM NAME="AllowChangePositions" VALUE="0"></PARAM>
						</xsl:if>
						<PARAM NAME="LockHtmlKeyboardEvents" VALUE="-1"></PARAM>
					</OBJECT>
					<SCRIPT for="{$html-id}" event="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" language="VBScript">
						window.setTimeout "Dim o: Set o = <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>""): If Not o Is Nothing Then : o.Internal_OnKeyUpAsync " &amp; nKeyCode &amp; "," &amp; nFlags &amp; ": End If", 0, "VBScript"
					</SCRIPT>
					<SCRIPT for="{$html-id}" event="OnDblClick(ByVal oSender, ByVal nIndex , ByVal nColumn, ByVal sID)" language="VBScript">
						window.setTimeout "Dim o: Set o = <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>""): If Not o Is Nothing Then : o.Internal_OnDblClickAsync " &amp; nIndex &amp; "," &amp; nColumn &amp; ",""" &amp; sID &amp; """: End If", 0, "VBScript"
					</SCRIPT>
					<SCRIPT FOR="{$html-id}" EVENT="OnRightClick(ByVal oSender, ByVal nIndex, ByVal nColumn, ByVal sID)" LANGUAGE="VBScript">
						window.setTimeout "Dim o: Set o = <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>""): If Not o Is Nothing Then : o.Internal_OnContextMenuAsync: End If", 0, "VBScript"
					</SCRIPT>
					<SCRIPT FOR="{$html-id}" EVENT="OnSelChange(ByVal oSender, ByVal nPrewRow, ByVal nNewRow)" LANGUAGE="VBScript">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_DispatchOnSelChange "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"")", nPrewRow, nNewRow
					</SCRIPT>
					</DIV>
				</TD>
				<xsl:if test="$menu-style='vertical-buttons'">
					<TD valign="{$buttons-valign}" style="padding-left:5px;">
						<XFW:XMenuHtmlPE
							ID="{$html-id}Menu" language="VBScript" 
							SolidPageBorder="false" 
							Enabled="True" 
							style="width:100%; height:100%;"
							menu-style="{$menu-style}"
							X_DISABLED="{$disabled}"
							button-width="{$button-width}"
							button-height="{$button-height}"
						>
							<xsl:attribute name="propmenu-xml"><xsl:value-of select="b:GetXmlString($pe-md/i:prop-menu)"/></xsl:attribute>
						</XFW:XMenuHtmlPE>
					</TD>
				</xsl:if>
			</TR>
			
			<!-- 
				Для всех генерируемых кнопок управления списком в качестве 
				основы для идентификатора используем атрибут html-id 
				обрабатываемого объектного свойства с служебным суффиксом
				"Button" + псевдо-наименование кнопки (Up, Down, Menu)
				-->
			<TR>
				<TD ALIGN="left" NOWRAP="1" CLASS="x-editor-objects-buttons-pane">
					<xsl:if test="('1'!=$off-position) and (('array'=$capacity) or ('link'=$capacity and ''!=$order-by))">
						<BUTTON 
							ID = "{$html-id}ButtonUp" 
							NAME = "{b:GetUniqueNameFor(current())}"
							TITLE = "Вверх" 
							CLASS = "x-button x-editor-objects-opbutton"
							DISABLED = "1"
							STYLE = "margin-right:3px;"
							X_DISABLED="{$disabled+2}"
						>
							<CENTER>
								<xsl:choose>
									<xsl:when test="''!=$lbl-position-up">
										<!-- Заданный текст кнопки -->
										<xsl:value-of select="$lbl-position-up"/>
									</xsl:when>
									<xsl:otherwise>
										<!-- Все остальные случаи: стрелка -->
										<SPAN STYLE="font-family:Webdings">&#53;</SPAN>
									</xsl:otherwise>
								</xsl:choose>
							</CENTER>
						</BUTTON>
						<SCRIPT FOR="{$html-id}ButtonUp" LANGUAGE="VBScript" event="OnClick">
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").DoItemShift True
						</SCRIPT>
						
						<BUTTON
							ID = "{$html-id}ButtonDown" 
							NAME = "{b:GetUniqueNameFor(current())}"
							TITLE = "Вниз" 
							CLASS = "x-button x-editor-objects-opbutton" 
							DISABLED = "1"
							STYLE = "margin-right:3px;"
							X_DISABLED="{$disabled+2}"
						>
							<CENTER>
								<xsl:choose>
									<xsl:when test="''!=$lbl-position-down">
										<!-- Заданный текст кнопки -->
										<xsl:value-of select="$lbl-position-down"/>
									</xsl:when>
									<xsl:otherwise>
										<!-- Все остальные случаи: стрелка -->
										<SPAN STYLE="font-family:Webdings">&#54;</SPAN>
									</xsl:otherwise>
								</xsl:choose>
							</CENTER>
						</BUTTON>
						<SCRIPT FOR="{$html-id}ButtonDown" LANGUAGE="VBScript" event="OnClick">
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").DoItemShift False
						</SCRIPT>
					</xsl:if>
				</TD>
				<TD WIDTH="100%" ALIGN="right" NOWRAP="1" CLASS="x-editor-objects-buttons-pane" >
					<xsl:if test="$menu-style!='vertical-buttons'">
						<DIV>
							<XFW:XMenuHtmlPE
								ID="{$html-id}Menu" language="VBScript" 
								SolidPageBorder="false" 
								Enabled="True" 
								style="width:100%; height:100%;"
								menu-style="{$menu-style}"
								X_DISABLED="{$disabled}"
								button-width="{$button-width}"
								button-height="{$button-height}"
							>
								<xsl:attribute name="propmenu-xml"><xsl:value-of select="b:GetXmlString($pe-md/i:prop-menu)"/></xsl:attribute>
							</XFW:XMenuHtmlPE>
						</DIV>	
					</xsl:if>
				</TD>
			</TR>
		</TABLE>
	</xsl:template>
</xsl:stylesheet>
