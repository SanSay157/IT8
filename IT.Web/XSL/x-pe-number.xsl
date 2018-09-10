<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	����������� �������� ��������� ���������  �����������/����������� ��� �������� ��������� ������� 
	�������
-->	
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:d="urn:object-editor-access"
	xmlns:b="urn:x-page-builder"
	xmlns:w="urn:editor-window-access"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"			
	>

	<xsl:output 
		method="html" 
		version="4.0" 
		encoding="windows-1251"
		omit-xml-declaration="yes"
		media-type="text/html"/>
	<!--
		=============================================================================================
		����������� ������ ��������� ���������  �����������/����������� ��� �������� ��������� �������
		�������
		������� ��������
			urn:object-editor-access - ��������� ������� EditorData									
		�������������� �������:																		
			�������� ������� X-Storage
		������� ���������:
			[in] maybenull		- ������� ������������ ������� ��������	(0/1)										
			[in] description	- �������� ����
			[in] disabled		- ������� ���������������� ����
			[in] vt 			- ��� ��-��
			[in] readonly 		- ������� ���� ������ ��� ������
			[in] min			- ����������� �������� �������� (�������������� ds:min)
			[in] max			- ������������ �������� �������� (�������������� ds:max)
			[in] width			- ������ inputbox'a (��� �������� � � style="width:x")

		��������� �������������:
			HTML -	���, ����������� ��������� ��� ��������� �����������/����������� �������� ��������� ������� 
			�������
	-->		
	<xsl:template name="std-template-number">
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
		<!-- ���� ������ ��� ������ -->
		<xsl:param name="readonly" select="number(b:nvl(string($xml-params/@readonly),'0'))"/>
		<!-- ��� �������� -->
		<xsl:param name="vt" select="b:nvl(string($xml-params/@vt),string($xml-prop-md/@vt))"/>
		<!-- ������������� �������� -->
		<xsl:param name="max" select="b:nvl(string($xml-params/@max), string($xml-prop-md/ds:max))"/>
		<!-- ����������� �������� -->
		<xsl:param name="min" select="b:nvl(string($xml-params/@min), string($xml-prop-md/ds:min))"/>
		
		<!-- ��������: ��� PropertyEditor'a � ���������� -->
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:object-dropdown/@n))"/>
		<!-- ���������� pe: i:number-presentation -->
		<xsl:param name="pe-md" select="$xml-prop-md/i:number-presentation[($metaname='' and not(@n)) or ($metaname=@n)]"/>
		<!-- ��������: ������� �������������� � ������ -->
		<xsl:param name="format-function" select="b:nvl(string($xml-params/@format-function), string($pe-md/@format-function))" />
		<!-- ��������: ������� �������������� �� ������ -->
		<xsl:param name="parse-function" select="b:nvl(string($xml-params/@parse-function), string($pe-md/@parse-function))" />
		<!-- ��������: ���������� ������ ����� . -->
		<xsl:param name="decimal-places" select="b:nvl(string($xml-params/@decimal-places), string($pe-md/@decimal-places))" />
		<!-- ��������: ������������ -->
		<xsl:param name="align" select="b:nvl(b:nvl(string($xml-params/@align), string($pe-md/@align)),'left')"/>

		<!-- ��������: ������ �������� -->
		<xsl:param name="width" select="b:nvl(string($xml-params/@width),'100%')" />
		<!-- ������������� �������� Html-�������� ��� PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- ���������� � ������������� VBS-���������� � ����������� ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		
		<INPUT 
			ID="{$html-id}" TYPE="TEXT" VALUE="" DISABLED="1" 
			NAME="{b:GetUniqueNameFor(current())}"
			STYLE="width:{$width};text-align:{$align};"
			
			X_FORMAT_FUNCTION="{$format-function}"
			X_PARSE_FUNCTION="{$parse-function}"
			X_DECIMAL_PLACES="{$decimal-places}" 
			
			X_TYPE="{$vt}"
			X_MIN="{$min}"
			X_MAX="{$max}"
			X_DISABLED = "{$disabled+1}"
			X_DESCR = "{$description}"
			X_PROPERTY_EDITOR = "XPENumberClass"
		>
			<xsl:if test="$readonly='1'">
				<xsl:attribute name="readonly">1</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="1=$maybenull">
					<!-- 
						���� �������� ����� ��������� �������� null - �������� ��������������
						�������� X_MAYBENULL.
						���� �������� �������� �������������� ������������ �������� ��-�� ���
						��������� �� ����.
					-->						
					<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
					<!-- ���������� ����� ��-������������� �������� -->
					<xsl:attribute name="CLASS">x-editor-control x-editor-numeric-field</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<!-- ���������� ����� ������������� �������� -->
					<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-numeric-field</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</INPUT>
		<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnKeyUp">
			With window.event
				window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpHtmlAsync " &amp; .keyCode &amp; "," &amp; CLng(.altKey) &amp; "," &amp; CLng(.ctrlKey) &amp; "," &amp; CLng(.shiftKey), 0, "VBScript"
			.cancelBubble = True
			End With
		</SCRIPT>
		<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="onbeforedeactivate">
			<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnBeforeDeactivate
		</SCRIPT>
	</xsl:template>
</xsl:stylesheet>