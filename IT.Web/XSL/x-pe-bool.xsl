<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	����������� �������� ��������� ���������  �����������/����������� ��� ���������� ������� �������
-->
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:d="urn:object-editor-access"
	xmlns:b="urn:x-page-builder"
	xmlns:w="urn:editor-window-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"	
	>

	<!--
		=============================================================================================
		����������� ������ ��������� ���������  �����������/����������� ��� ���������� ������� �������
		������� ��������
			urn:object-editor-access - ��������� ������� EditorData									
		�������������� �������:																		
			�������� ������� X-Storage
		������� ���������:
			[in] maybenull		- ������� ������������ ������� ��������	(0/1)										
			[in] description	- �������� ����
			[in] disabled		- ������� ���������������� ����
			[in] label			- ������� � ����
		��������� �������������:
			HTML - ���, ����������� ��������� ��� ��������� �����������/����������� ���������� ������� �������
	-->
	<xsl:template name="std-template-bool">
		<!-- xml �� ����� ����������� ������� -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml � ������������ -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- ��������: �����������  -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- ��������: �������� ����  -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description), string($xml-prop-md/@d))"/>
		<!-- ��������: ������� � ����  -->
		<xsl:param name="label" select="b:nvl(string($xml-params/@label), string($description) )"/>
		<!-- ������������� �������� Html-�������� ��� PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- ���������� � ������������� VBS-���������� � ����������� ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		
		<!-- 
			������� check-box (���������� ��������������� - �� �������������� �� ����� 
			�� ���������� �������������)
			
			� �������� �������������� ���������� ������� html-id ���������������
			���������� ��������. ��� �������� � ���������� ����������� ����������� 
			������� � �������������� ��������� ������� �� ����.

			�������������� ������� X_DESCR ����� ������� �������� ��������, �������
			� ����� ������ ����� ���������� �� �������� � ����������.
			���� ������� �������� �������� �������� ��������������� � ���������
			�������� �� ����.
		-->
		<INPUT 
			ID="{$html-id}" TYPE="CHECKBOX" DISABLED="1" 			
			NAME="{b:GetUniqueNameFor(current())}"
			X_DESCR = "{$description}"
			X_DISABLED = "{$disabled+1}"
			X_PROPERTY_EDITOR = "XPEBoolClass"
		>
		</INPUT>
		
		<!-- ������ � CheckBox ������ Label -->
		<!-- ����������� ������� Label � ��������� CheckBox -->
		<!-- 
			� ���-�� ������ ��� �������������� ���������� ������� html-id ���������������
			���������� ��-��. ��� �������� � ���������� ����������� ����������� 
			������� � �������������� ��������� ������� �� ����������������� ����.
		 -->			
		<LABEL FOR="{$html-id}" ID="{$html-id}Caption" CLASS="x-editor-text x-editor-propcaption-notnull">
			<xsl:value-of select="$label"/>
		</LABEL>
		<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnClick">
			<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnClick
		</SCRIPT>				
		<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnKeyUp">
			<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnKeyUp
		</SCRIPT>				
	</xsl:template>
</xsl:stylesheet>