<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	страница генерации элементов отображения/модификации для массивных объектных свойств в види списка-селектора
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:user="urn:это_нужно_для_блока_msxsl:script"
	xmlns:w="urn:editor-window-access"
	xmlns:d="urn:object-editor-access"
	xmlns:b="urn:x-page-builder"
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
			
		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации объектных нескалярных свойств 
			объекта
	-->
  <xsl:template name="std-template-objects-tree-selector">
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
    <xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:tree-selector/@n))"/>
    <!-- метаданные pe: i:tree-selector -->
    <xsl:param name="pe-md" select="$xml-prop-md/i:tree-selector[($metaname='' and not(@n)) or ($metaname=@n)]"/>

    <!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
    <xsl:param name="html-id" select="b:GetHtmlID(current())"/>
    <!-- Параметр: Признак отключения кнопок всех кнопок -->
    <xsl:param name="off-operations" select="b:nvl(string($xml-params/@off-operations), string($pe-md/@off-operations))"/>
    <!-- Параметр: Признак отключения кнопки "Разевернуть все" -->
    <xsl:param name="off-expand-all" select="b:nvl(string($xml-params/@off-expand-all), string($pe-md/@off-expand-all))"/>
    <!-- Параметр: Признак разрешения переноса узлов дерева -->
    <!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
    <xsl:variable name="editordata" select="d:UniqueID()"/>

    <!-- Таблица редактора массивного объектного свойства -->
    <TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" WIDTH="100%" HEIGHT="{$height}">
      <TR>
        <TD HEIGHT="100%" WIDTH="100%">
          <DIV STYLE="position:relative; width:100%; height:100%;" CLASS="x-editor-control x-editor-objects-list">
            <OBJECT
              ID="{$html-id}"
              NAME="{b:GetUniqueNameFor(current())}"
              CLASSID="{b:Evaluate('CLSID_TREE_VIEW')}"
              BORDER="0" TABINDEX="0"
              WIDTH="100%" HEIGHT="100%"
              X_DESCR = "{$description}"
              Metaname = "{$metaname}"
              PEMetadataLocator = "{concat( 'i:tree-selector',user:GetMetaNameFilter( string( $metaname )))}"
              X_DISABLED="{$disabled+1}"
              X_PROPERTY_EDITOR = "XPEObjectsTreeSelectorClass"
					>
              <PARAM NAME="Enabled" VALUE="0"></PARAM>
              <PARAM NAME="IsMultipleSel" VALUE="-1"></PARAM>
              <PARAM NAME="LockHtmlKeyboardEvents" VALUE="-1"></PARAM>
              <xsl:if test="'1' = string($pe-md/@allow-drag-drop)">
                <PARAM NAME="AllowDragDrop" VALUE="-1"></PARAM>
              </xsl:if>
            </OBJECT>

            <SCRIPT for="{$html-id}" event="OnSelChange(ByVal oSender, oNode, ByVal bSelected)" language="VBScript">
              <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnSelChange oNode, bSelected
            </SCRIPT>
            <SCRIPT for="{$html-id}" event="OnDataLoading(ByVal oSender, nQuerySet, sNodePath, sObjectType, sObjectID, oRestrictions)" language="VBScript">
              <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnDataLoading nQuerySet, sNodePath, sObjectType, sObjectID, oRestrictions
            </SCRIPT>
            <SCRIPT for="{$html-id}" event="OnDataLoaded(ByVal oSender, nQuerySet, sNodePath, sObjectType, sObjectID)" language="VBScript">
              <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnDataLoaded nQuerySet, sNodePath, sObjectType, sObjectID
            </SCRIPT>
            <SCRIPT for="{$html-id}" event="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" language="VBScript">
              <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnKeyUp nKeyCode, nFlags
            </SCRIPT>
            <script for="{$html-id}" event="OnBeforeNodeDrag(oTreeView, oSourceNode, nKeyFlags, bCanDrag)" language="VBScript">
              <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnBeforeNodeDrag oTreeView, oSourceNode, nKeyFlags, bCanDrag
            </script>
            <script for="{$html-id}" event="OnNodeDrag(oTreeView, oSourceNode, nKeyFlags)" language="VBScript">
              <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnNodeDrag oTreeView, oSourceNode, nKeyFlags
            </script>
            <script for="{$html-id}" event="OnNodeDragOver(oTreeView, oSourceNode, oTargetNode, nKeyFlags, bCanDrog)" language="VBScript">
              <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnNodeDragOver oTreeView, oSourceNode, oTargetNode, nKeyFlags, bCanDrog
            </script>
            <script for="{$html-id}" event="OnNodeDragDrop(oTreeView, oSourceNode, oTargetNode, nKeyFlags)" language="VBScript">
              <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnNodeDragDrop oTreeView, oSourceNode, oTargetNode, nKeyFlags
            </script>
            <script for="{$html-id}" event="OnNodeDragCanceled(oTreeView, oSourceNode, nKeyFlags)" language="VBScript">
              <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnNodeDragCanceled oTreeView, oSourceNode, nKeyFlags
            </script>
          </DIV>
        </TD>
      </TR>
      <TR>
        <xsl:if test="'1' = $off-operations">
          <xsl:attribute name="STYLE">display:none</xsl:attribute>
        </xsl:if>
        <TD STYLE="width:100%;">
          <DIV STYLE="position:relative; width:100%;">

            <BUTTON
              ID = "{$html-id}Clear"
              NAME = "{b:GetUniqueNameFor(current())}"
              TITLE = "Очистить выделение"
              CLASS = "x-button x-editor-objects-opbutton"
              DISABLED = "1"
              STYLE = "margin-right:3px;"
              X_DISABLED="{$disabled+2}"
					>
              <CENTER>Очистить выделение</CENTER>
            </BUTTON>
            <SCRIPT FOR="{$html-id}Clear" EVENT="onClick" LANGUAGE="VBScript">
              <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnClear
            </SCRIPT>

            <BUTTON
              ID = "{$html-id}ExpandAll"
              NAME = "{b:GetUniqueNameFor(current())}"
              TITLE = "Развернуть все"
              CLASS = "x-button x-editor-objects-opbutton"
              DISABLED = "1"
              STYLE = "margin-right:3px;"
              X_DISABLED="{$disabled+2}"
					>
              <xsl:if test="'1'=$off-expand-all">
                <xsl:attribute name="STYLE">display:none</xsl:attribute>
              </xsl:if>
              <CENTER>Развернуть все</CENTER>
            </BUTTON>
            <SCRIPT FOR="{$html-id}ExpandAll" EVENT="onClick" LANGUAGE="VBScript">
              <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnExpandAll
            </SCRIPT>

            <BUTTON
              ID = "{$html-id}CollapseAll"
              NAME = "{b:GetUniqueNameFor(current())}"
              TITLE = "Свернуть все"
              CLASS = "x-button x-editor-objects-opbutton"
              DISABLED = "1"
              STYLE = "margin-right:3px;"
              X_DISABLED="{$disabled+2}"
					>
              <CENTER>Свернуть все</CENTER>
            </BUTTON>
            <SCRIPT FOR="{$html-id}CollapseAll" EVENT="onClick" LANGUAGE="VBScript">
              <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnCollapseAll
            </SCRIPT>

          </DIV>
        </TD>
      </TR>
    </TABLE>
  </xsl:template>
</xsl:stylesheet>
