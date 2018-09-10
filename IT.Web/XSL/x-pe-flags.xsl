<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	����������� �������� ��������� ���������  �����������/����������� ��� ����� ��������� ������� 
	�������, ������� �������� �������������
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
	<!-- 
		=============================================================================================
		���������� ������� ��� ����������� ������� ����� FOR ��� ������� ���������
	-->
	<xsl:template name="std-template-flags-internal-checkbox">
		<xsl:param name="bit"/>
		<xsl:param name="i"/>
		<xsl:param name="html-id"/>
		<xsl:param name="editordata"/>
		<xsl:param name="prop"/>

		<!-- ����� checkbox'a -->
		<xsl:variable name="lbl" select="string($bit/@n)"/>
		<!-- ����� tooltip'a -->
		<xsl:variable name="hint" select="string($bit/@hint)"/>
		<!-- ������������� checkbox'a -->
		<xsl:variable name="id"><xsl:value-of select="$html-id"/>_<xsl:if test="$i &lt; 9">0</xsl:if><xsl:value-of select="$i+1"/></xsl:variable>
		<!-- 
			���������� HTML ��� �������������� �������������� ������ 
			
			��� ������� ����� ���������� ��������� HTML-�������������:
			
			<INPUT 
				TYPE="CHECKBOX" 
				ID="{html-id ��������}_{����� ��������������� �����}" 
				ExpBitValue="{����� ����� � ����������}" 
				DASABLED="1"
				NAME="{b:GetUniqueNameFor(current())}"
				OnClick=""
			>
			<LABEL FOR="{html-id ��������}_{����� ��������������� �����}">
				{��� ����� � ����������}
			</LABEL>
			<BR/>
			
			������������� ��������� ������������ ����� ���������.
			��������������� ��������� ������������ ����� ���������.
		-->
		<INPUT 
			TYPE="CHECKBOX" 
			NAME="{b:GetUniqueNameFor($prop)}"
			ID="{$id}"
			DISABLED="1"
			ExpBitValue="{string($bit)}" title="{$hint}"
		/>
		<LABEL id="{$id}Label" FOR="{$id}" title="{$hint}">
			<xsl:value-of select="$lbl"/>
		</LABEL>
		<SCRIPT FOR="{$id}" LANGUAGE="VBScript" EVENT="OnClick">
			<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnClick "<xsl:value-of select="$id"/>"
		</SCRIPT>
		<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnKeyUp">
			<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnKeyUp
		</SCRIPT>				
	</xsl:template>	
	
	<!--
		=============================================================================================
		����������� ������ ��������� ���������  �����������/����������� ��� ����� ��������� �������
		�������, ������� �������� �������������
		������� ��������
			urn:object-editor-access - ��������� ������� EditorData									
		�������������� �������:																		
			�������� ������� X-Storage
		������� ���������:
			[in] description - �������� ����
			[in] metaname		- ������� ��������� �������� (i:bits/@n)
		��������� �������������:
			HTML -	���, ����������� ��������� ��� ��������� �����������/����������� ����� ��������� ������� 
			�������, ������� �������� �������������
	-->	
	<xsl:template name="std-template-flags">
		<!-- xml �� ����� ����������� ������� -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml � ������������ -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- ��������: ����������� -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- ��������: �������� ���� -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
		<!-- ��������: ��� PropertyEditor'a � ���������� -->
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:bits[1]/@n))"/>
		<!-- ������� ����������� �������� �� �����������. �� ��������� ��� ������������� � ������ -->
		<xsl:param name="horizontal-direction" select="b:nvl(string($xml-params/@horizontal), string($xml-prop-md/i:bits[($metaname='' and not(@n)) or ($metaname=@n)]/@horizontal))"/>
		<!-- ������������� �������� Html-�������� ��� PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- ���������� � ������������� VBS-���������� � ����������� ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		<xsl:variable name="prop" select="current()"/>
		
		<!-- 
			���������� ��������� (������� DIV)
			
			� �������� �������������� ���������� ������� html-id ���������������
			���������� ��-��. ��� �������� � ���������� ����������� ����������� 
			������� � �������������� ��������� ������� �� ����.
			
			�������������� ������� X_DESCR ����� ������� �������� ��-��, �������,
			� ����� ������ ����� ���������� �� �������� � ����������.
			���� ������� �������� �������� �������� ��������������� � ���������
			�������� �� ����.
		-->
		<DIV ID="{$html-id}" CLASS="x-editor-flags"
			X_DESCR = "{$description}"
			X_DISABLED = "{$disabled+1}"
			X_PROPERTY_EDITOR = "XPEFlagsClass"
		>
			<!--  ����������� �������� -->
			<xsl:choose>
				<xsl:when test="'1'=$horizontal-direction">
					<TABLE CELLSPACING="0" CELLPADDING="0"><TR>
						<xsl:for-each select="$xml-prop-md/i:bits[($metaname='' and not(@n)) or ($metaname=@n)]/i:bit">
							<td style="padding-right:3px;">
								<xsl:call-template name="std-template-flags-internal-checkbox">
									<xsl:with-param name="bit" select="current()"/>
									<xsl:with-param name="html-id" select="$html-id"/>
									<xsl:with-param name="editordata" select="$editordata"/>
									<xsl:with-param name="prop" select="$prop"/>
									<xsl:with-param name="i" select="position()"/>
								</xsl:call-template>
							</td>
						</xsl:for-each>
					</TR></TABLE>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="$xml-prop-md/i:bits[($metaname='' and not(@n)) or ($metaname=@n)]/i:bit">
						<div>
							<xsl:call-template name="std-template-flags-internal-checkbox">
								<xsl:with-param name="bit" select="current()"/>
								<xsl:with-param name="html-id" select="$html-id"/>
								<xsl:with-param name="editordata" select="$editordata"/>
								<xsl:with-param name="prop" select="$prop"/>
								<xsl:with-param name="i" select="position()"/>
							</xsl:call-template>
						</div>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</DIV>
	</xsl:template>
</xsl:stylesheet>