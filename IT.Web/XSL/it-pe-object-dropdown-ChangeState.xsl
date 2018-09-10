<?xml version="1.0" encoding="windows-1251"?>
<!--
*******************************************************************************
  XSL-������ �������� UI-������������� ���������� ���������� �������� 
  (��� ������� � ����� vt="object")
*******************************************************************************
-->
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:user="urn:���_�����_���_�����_msxsl:script"
	xmlns:d="urn:object-editor-access"
	xmlns:b="urn:x-page-builder"
	xmlns:w="urn:editor-window-access"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"			
	user:off-cache="1"
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

<xsl:template name="it-template-object-dropdown-changestate">
	<!-- xml �� ����� ����������� ������� -->
	<xsl:param name="xml-params" select="*[0!=0]"/>
	<!-- xml � ������������ -->
	<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
	<!-- ��������: ����������� -->
	<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
	<!-- ��������: ������� ������������ ������� �������� -->
	<xsl:param name="maybenull" select="b:nvl(string($xml-params/@maybenull), string($xml-prop-md/@maybenull))"/>
	<!-- ��������: �������� ���� -->
	<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
	<!-- ��������: ���������������� ������, ������������� ��� ���������� ���������� -->
	<xsl:param name="list-metaname" />
	<!-- ��������: ����� ������� �������� ����������� ������ -->
	<xsl:param name="empty-value-text" select="'&lt;&lt;�������� ��� ���������&gt;&gt;'"/>
	<!-- ��������: ��������� ��� ���������� ������������� ��������� � textbox'e "������� ���������" -->
	<xsl:param name="initial-value-title-stmt" select="'item.ObjectID'"/>
	<!-- ������ ������ ������� -->
	<xsl:param name="first-column-width" select="'10%'"/>
	<!-- ��������: ������������� �������� Html-�������� ��� PropertyEditor'a -->
	<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
	<!-- ���������� � ������������� VBS-���������� � ����������� ObjectEditor'a -->
	<xsl:variable name="editordata" select="d:UniqueID()"/>
	
	<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%">
	<COL WIDTH="{$first-column-width}"/>
	<COL WIDTH="100%"/>
	<TBODY>
	<TR>
		<TD CLASS="x-editor-text x-editor-propcaption"><NOBR>������� ���������:  </NOBR></TD>
		<TD>
			<INPUT ID="oInitialValueTitleElement" STYLE="width:100%;" readonly="1" class="x-editor-control x-editor-string-field" />
		</TD>
	</TR>
	<TR>
		<TD CLASS="x-editor-text x-editor-propcaption"><NOBR>����� ���������:  </NOBR></TD>
		<TD>
			<!-- 
				UI-������������� ���������� ���������� ��������: ���������� ������
			-->
			<SELECT
				ID="{$html-id}" 
				DISABLED="1" STYLE="width:100%" 
				X_DESCR="{$description}"
				X_DISABLED="{$disabled+1}"
				X_PROPERTY_EDITOR = "PEObjectDropdownChangeStateClass"
				ListMetaname="{$list-metaname}" 
				EmptyValueText="{$empty-value-text}" 
				InitialValueTitleStmt = "{$initial-value-title-stmt}"
				CLASS="x-editor-control x-editor-dropdown"
			>
				<option selected="1"><xsl:value-of select="$empty-value-text"/></option>
			</SELECT>
			<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnChange">
				<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnChange
			</SCRIPT>
		</TD>
	</TR>
	</TBODY>
	</TABLE>
</xsl:template>
</xsl:stylesheet>
