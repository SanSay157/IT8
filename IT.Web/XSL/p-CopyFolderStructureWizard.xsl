<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	Страница редактора "Списания времени по заданию" (TimeSpent) 
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:user="urn:это_нужно_для_блока_msxsl:script"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	user:off-cache="1"
	>
  <xsl:output
		method="html"
		version="4.0"
		encoding="windows-1251"
		omit-xml-declaration="yes"
		media-type="text/html"/>

  <xsl:template match="CopyFolderStructureOperation">
    <xsl:variable name="editordata" select="d:UniqueID()"/>
    <!-- Основная таблица, в которой будут разложены св-ва объекта -->
    <TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="100%" HEIGHT="100%" STYLE="table-layout:fixed">
      <TBODY>
        <xsl:for-each select="Target">
          <TR>
            <TD>
              <DIV class="x-editor-text x-editor-propcaption">
                <NOBR>Выберите папку назначения</NOBR>
              </DIV>
              <xsl:call-template name="std-template-object-presentation" />
            </TD>
          </TR>
        </xsl:for-each>

        <xsl:for-each select="Folders">
          <xsl:variable name="html-id" select="b:GetHtmlID(current())"/>
          <TR>
            <TD HEIGHT="90%">
              <DIV class="x-editor-text x-editor-propcaption">
                <NOBR>Выберите папки, которые необходимо скопировать</NOBR>
              </DIV>
              <xsl:call-template name="std-template-objects-tree-selector">
                <xsl:with-param name="html-id" select="$html-id"/>
                <xsl:with-param name="height" select="'90%'"/>
              </xsl:call-template>
              <script for="{$html-id}" event="OnMouseUp(oSender, oTreeNode, nFlags)" language="VBScript">
                <![CDATA[
                Const	KEYFLG_RBUTTON = 16 ' Код правой кнопки мыши
                Dim oCurrentNode	' Выбранный узел дерева

                If nFlags = KEYFLG_RBUTTON Then
                  If Not Nothing Is oTreeNode Then 
                    Set oCurrentNode = oSender.ActiveNode
                    If Nothing Is oCurrentNode Then
                      oSender.Path = oTreeNode.Path
                    ElseIf oCurrentNode.nodeUID <> oTreeNode.nodeUID Then
                      oSender.Path = oTreeNode.Path
                    End If
                    XXTreeViewShowContextMenu _
                      ]]><xsl:value-of select="$editordata"/><![CDATA[.CurrentPage.GetPropertyEditorByFullHtmlID("]]><xsl:value-of select="$html-id"/><![CDATA["), _
                      document.all("]]><xsl:value-of select="$html-id"/><![CDATA["), _
                      oTreeNode, _
                      X_GetSubrootElementMD("i:menu", "FolderSelectorForCopyFolderStructureMenu")
                  End If
                End If
                ]]>
              </script>
            </TD>
          </TR>
        </xsl:for-each>
      </TBODY>
    </TABLE>
    <div id="bkg" class="xx-background xx-initially-hidden"></div>
    <div id="dlgWait" class="xx-dialog xx-initially-hidden" style="height:200px;width:300px;margin-top:-100px;margin-left:-150px;">
      <div style="background-color:#fff;border:1px solid black;text-align: center">
      <b>Операция выполняется, подождите пожалуйста</b>
      <img style="display:block;margin-left:auto;margin-right:auto;" src="Images/x-execute-command-async.gif"/>
      </div>
    </div>
  </xsl:template>

  <xsl:include href="x-pe-object.xsl"/>
  <xsl:include href="x-pe-objects-tree-selector.xsl"/>

</xsl:stylesheet>
