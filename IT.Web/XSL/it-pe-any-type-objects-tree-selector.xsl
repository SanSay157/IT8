<?xml version="1.0" encoding="windows-1251"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:user="urn:���_�����_���_�����_msxsl:script"
	xmlns:w="urn:editor-window-access"
	xmlns:d="urn:object-editor-access"
	xmlns:b="urn:x-page-builder"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"	
	>

<msxsl:script language="VBScript" implements-prefix="user">

	<![CDATA['<%
	
	' ��������� ����� XPath ������, ���������� ������ �� ����������� ���������
	' [in] sMetaName - �������
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
		������ ��������� ��������� �����������/����������� ��� ��������� ����������� ������� ��������� �����
		�������
		������� ��������
			urn:object-editor-access - ��������� ������� EditorData									
			urn:editor-window-access - ��������� ���� ���������								
		�������������� �������:																		
			�������� ������� X-Storage
		������� ���������:
			[in] height - ������ ������� ��� �������������� ���������� �������
			[in] metaname - ������� ������
			[in] description - �������� ����
			
		��������� �������������:
			HTML -	���, ����������� ��������� ��� ��������� �����������/����������� ��������� ����������� ������� 
			�������
	-->		
	<xsl:template name="it-template-any-type-objects-tree-selector">
		<!-- xml �� ����� ����������� ������� -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml � ������������ -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- ��������: ����������� -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- ��������: �������� ���� -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
		<!-- ��������: ����������� -->
		<xsl:param name="height" select="b:nvl(string($xml-params/@height),'100%')"/>
		<!-- ��������: ��� PropertyEditor'a � ���������� -->
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:tree-selector/@n))"/>
		<!-- ���������� pe: i:object-dropdown -->
		<xsl:param name="pe-md" select="$xml-prop-md/i:tree-selector[($metaname='' and not(@n)) or ($metaname=@n)]"/>
		<!-- ������������� �������� Html-�������� ��� PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>	
		
		<!-- ��������: ������� ���������� ������ ���� ������ -->
		<xsl:param name="off-operations" select="b:nvl(string($xml-params/@off-operations), string($pe-md/@off-operations))"/>
		<!-- ��������: ������� ���������� ������ "�������� ���������" -->
		<xsl:param name="off-show-selected" select="b:nvl(string($xml-params/@off-show-selected), string($pe-md/@off-show-selected))"/>
		<!-- ��������: ������� ���������� ������ "����������� ���" -->
		<xsl:param name="off-expand-all" select="b:nvl(string($xml-params/@off-expand-all), string($pe-md/@off-expand-all))"/>
		<!-- ��������: ������� ���������� ������ "�������� ���" -->
		<xsl:param name="off-collapse-all" select="b:nvl(string($xml-params/@off-collapse-all), string($pe-md/@off-collapse-all))"/>
		<!-- ��������: �������� ������� ��� �������������� ����� ������ -->
		<xsl:param name="prop-names" />

		<!-- ���������� � ������������� VBS-���������� � ����������� ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>

		<!-- ������� ��������� ���������� ���������� �������� -->
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
						X_PROPERTY_EDITOR = "XPEAnyTypeObjectsTreeSelectorClass"
						X_PROP_NAMES = "{$prop-names}"
					>
						<PARAM NAME="Enabled" VALUE="0"></PARAM>
						<PARAM NAME="IsMultipleSel" VALUE="-1"></PARAM>
					</OBJECT>
					
					<SCRIPT for="{$html-id}" event="OnSelChange(ByVal oSender, oNode, ByVal bSelected)" language="VBScript">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnSelChange oNode, bSelected
					</SCRIPT>
					
					<SCRIPT for="{$html-id}" event="OnDataLoaded(ByVal oSender, nQuerySet, sNodePath, sObjectType, sObjectID)" language="VBScript">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnDataLoaded nQuerySet, sNodePath, sObjectType, sObjectID
					</SCRIPT>

					</DIV>
				</TD>
			</TR>
			<TR>
				<xsl:if test="'1' = $off-operations">
					<xsl:attribute name="STYLE">display:none</xsl:attribute>
				</xsl:if>
				<TD STYLE="padding:2px 0px 0px 0px; text-align:right;">
				
					<BUTTON
						ID = "{$html-id}Clear" 
						NAME = "{b:GetUniqueNameFor(current())}"
						TITLE = "����� ���������" 
						CLASS = "x-button x-editor-objects-opbutton"
						DISABLED = "1"
						STYLE = "margin-left:3px;"
						X_DISABLED="{$disabled+2}"
					><CENTER>����� ���������</CENTER></BUTTON>
					
					<BUTTON
						ID = "{$html-id}ShowSelected" 
						NAME = "{b:GetUniqueNameFor(current())}"
						TITLE = "�������� ���������" 
						CLASS = "x-button x-editor-objects-opbutton"
						DISABLED = "1"
						STYLE = "margin-left:3px;"
						X_DISABLED="{$disabled+2}"
					>
						<xsl:if test="'1'=$off-show-selected">
							<xsl:attribute name="STYLE">display:none</xsl:attribute>
						</xsl:if>
						<CENTER>�������� ���������</CENTER>
					</BUTTON>
					
					<BUTTON
						ID = "{$html-id}ExpandAll" 
						NAME = "{b:GetUniqueNameFor(current())}"
						TITLE = "���������� ���" 
						CLASS = "x-button x-editor-objects-opbutton"
						DISABLED = "1"
						STYLE = "margin-left:3px;"
						X_DISABLED="{$disabled+2}"
					>
						<xsl:if test="'1'=$off-expand-all">
							<xsl:attribute name="STYLE">display:none</xsl:attribute>
						</xsl:if>
						<CENTER>���������� ���</CENTER>
					</BUTTON>
					
					<BUTTON
						ID = "{$html-id}CollapseAll" 
						NAME = "{b:GetUniqueNameFor(current())}"
						TITLE = "�������� ���" 
						CLASS = "x-button x-editor-objects-opbutton"
						DISABLED = "1"
						STYLE = "margin-left:3px;"
						X_DISABLED="{$disabled+2}"
					>
						<xsl:if test="'1'=$off-collapse-all">
							<xsl:attribute name="STYLE">display:none</xsl:attribute>
						</xsl:if>
						<CENTER>�������� ���</CENTER>
					</BUTTON>
					
					<SCRIPT FOR="{$html-id}Clear" EVENT="onClick" LANGUAGE="VBScript">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnClear
					</SCRIPT>
					<SCRIPT FOR="{$html-id}ShowSelected" EVENT="onClick" LANGUAGE="VBScript">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnShowSelected
					</SCRIPT>
					<SCRIPT FOR="{$html-id}ExpandAll" EVENT="onClick" LANGUAGE="VBScript">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnExpandAll
					</SCRIPT>
					<SCRIPT FOR="{$html-id}CollapseAll" EVENT="onClick" LANGUAGE="VBScript">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnCollapseAll
					</SCRIPT>
				</TD>
			</TR>
		</TABLE>
	</xsl:template>
</xsl:stylesheet>
