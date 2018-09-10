<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	����������� �������� ��������� ���������  �����������/����������� ��� ��������� ������� �������
	���� bin
-->	
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:b="urn:x-page-builder"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"		
	>
	<!--
		=============================================================================================
		����������� ������ ��������� ���������  �����������/����������� ��� ��������� ������� �������
		���� bin
		������� ��������
			urn:editor-data-access - ��������� ������� EditorData									
		�������������� �������:																		
			�������� DS-������� Storage
		������� ���������:
			[in] maybenull		-	������� ������������ ������� ��������	(0/1)										
			[in] description	-	�������� ����
			[in] off-view		-	������� ���������� �������� "��������"
			[in] off-clear		-	������� ���������� �������� "��������"
			[in] off-showsize	-	������� ���������� ����������� ������� �����
			[in] filters		-	C����� ��������, � ��������� �������:
									"description1|patternlist1|...descriptionN|patternlistN|", 
									��� "patternlistI" ���� ������ ����� ������, ������������� ����� ";" 
									���� �� ������, ��  ������������ �������� �� ��������� � �����������
									�� ����:
										- ��� ������������ �������� ������ - "��� ����� (*.*)|*.*|"
										- ��� ����������� - "����� ����������� (*.gif;*.jpg;*.jpeg;*.bmp;*.png)" 
										� "��� �����(*.*)"
			[in] max-file-size  -	������������ ������ �����
			[in] file-name-in	-	��� �������� �������-��������� ������� ��������� ��-��, � ������� 
									���������� ���������� ��� ����� (� �����������, ��� ����) 
			[in] is-image		-	������� �����������, � �� ������ ��������� �����
			[in] max-width		-	O���������� �� �������������� ������� �����������
			[in] max-height		-	O���������� �� �������������� ������� �����������
			[in] min-width		-	O���������� �� �������������� ������� �����������
			[in] min-height		-	O���������� �� �������������� ������� �����������
			[in] t				-	��������� ������� ������ ��������/�������� �����
			[in] disabled		-   ������� ���������������� ����

		��������� �������������:
			HTML -	���, ����������� ��������� ��� ��������� �����������/����������� ��������� ������� ������� 
					���� bin

		TODO: �������
	-->	
	<xsl:template name="std-template-file">
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
		<!-- ��������: ���������� ��������� -->
		<xsl:param name="off-view" select="b:nvl(string($xml-params/@off-view),string($xml-prop-md/i:binary-presentation/@off-view))"/>
		<!-- ��������: ���������� ������� -->
		<xsl:param name="off-clear" select="b:nvl(string($xml-params/@off-clear),string($xml-prop-md/i:binary-presentation/@off-clear))"/>
		<!-- ��������: ���������� ����������� ������� ����� -->
		<xsl:param name="off-showsize" select="b:nvl(string($xml-params/@off-showsize),string($xml-prop-md/i:binary-presentation/@off-showsize))"/>
		<!-- ��������: c����� �������� -->
		<xsl:param name="filters" select="b:nvl(string($xml-params/@filters),string($xml-prop-md/i:binary-presentation/@filters))"/>
		<!-- ��������: ������������ ������ ����� -->
		<xsl:param name="max-file-size" select="b:nvl(string($xml-params/@max-file-size),string($xml-prop-md/i:binary-presentation/@max-file-size))"/>
		<!-- ��������: ��� �������� �������, � ������� ���������� ��� ����� -->
		<xsl:param name="file-name-in" select="b:nvl(string($xml-params/@file-name-in),string($xml-prop-md/i:binary-presentation/@file-name-in))"/>
		<!-- ��������: ��������� ������� ������ ��������/�������� ����� -->
		<xsl:param name="t" select="b:nvl(b:nvl(string($xml-params/@title),string($xml-prop-md/i:binary-presentation/@t)),'��������...')"/>
		<!-- ��������: ������� �����������, � �� ������ ��������� ����� -->
		<xsl:param name="is-image" select="b:nvl(string($xml-params/@is-image),string($xml-prop-md/i:binary-presentation/@is-image))"/>
		<!-- ���������: O���������� �� �������������� ������� ����������� -->
		<xsl:param name="min-width" select="b:nvl(string($xml-params/@min-width),string($xml-prop-md/i:binary-presentation/@min-width))"/>
		<xsl:param name="min-height" select="b:nvl(string($xml-params/@min-height),string($xml-prop-md/i:binary-presentation/@min-height))"/>
		<xsl:param name="max-width" select="b:nvl(string($xml-params/@max-width),string($xml-prop-md/i:binary-presentation/@max-width))"/>
		<xsl:param name="max-height" select="b:nvl(string($xml-params/@filters),string($xml-prop-md/i:binary-presentation/@max-height))"/>
		<!-- ��������: ������, ������������ ������� ������ (�� ������ ������ �� �������� �����������) -->
		<!-- ��������: dots, arrow -->		
		<xsl:param name="select-symbol" select="b:nvl(string($xml-params/@select-symbol),string($xml-prop-md/i:binary-presentation/@select-symbol))"/>
		<!-- ������������� �������� Html-�������� ��� PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- ���������� � ������������� VBS-���������� � ����������� ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		<!-- ��� �������� (bin/smallBin) -->
		<xsl:variable name="vt" select="string($xml-prop-md/@vt)"/>
		
		<!-- ������� ����� ���������� ��������� ����������� -->
		<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" WIDTH="100%">
			<COL WIDTH="100%;"/>
			<COL STYLE="padding-left:3px;"/>
			<COL STYLE="padding-left:3px;"/>
		<TBODY>
		<TR>
			<TD>
				<!-- 
					���� ��� ������ ����� �����.
					���� ������-���-������, ������� ����� ����� ����������� � ������� ����
					� �������� ������ ��� �������������� ���������� ������� html-id 
					���������� ��������. ��� �������� � ���������� ����������� ����������� 
					������� � �������������� ��������� ������� �� ����������������� ����.
				-->
				<INPUT 
					ID="{$html-id}FileName" 
					TYPE="TEXT" 
					NAME="{b:GetUniqueNameFor(current())}"
					TABINDEX="-1" VALUE="" READONLY="1" DISABLED="1" STYLE="width:100%">
					<!-- 
						��������� ������������ / �������������� �������
						� ������ �������������� �������� ����������� ����. 
						�������� �����
					-->
					<xsl:choose>
						<xsl:when test="'1'=$maybenull">
							<!-- ���������� ����� ��-������������� �������� -->
							<xsl:attribute name="CLASS">x-editor-control</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<!-- ���������� ����� ������������� �������� -->
							<xsl:attribute name="CLASS">x-editor-control-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</INPUT>
			</TD>
			<TD>
				<!-- 
					������ ����������� ������� �����; ����� ���� ������ ���� ����� ������� 
					off-showsize: ��� ��� ������� ���� ���������� � HTML-��������, �� ���
					"��������������"; �.�. ����������� � ����������� �������� ���� �� 
					����������� ����, � ��� "�����������"
				-->
				<xsl:choose>
					<xsl:when test="'1'=$off-showsize">
						<!-- "�����������" ����������� �� ���� �������������� ��������� ����� -->
						<xsl:attribute name="STYLE">display:none;</xsl:attribute>
					</xsl:when>
				</xsl:choose>
				
				<!-- 
					���� ��� ������ ������� ����� 
					� �������� ������ ��� �������������� ���������� ������� html-id 
					���������� ��������. ��� �������� � ���������� ����������� ����������� 
					������� � �������������� ��������� ������� �� ����������������� ����.
					���� ������-���-������.
					
					�������������� ������� X_OFF_SHOWSIZE ��������������� � ������������ 
					�� ��������� ��������� off-showsize �������;
				-->
				<INPUT
					NAME="{b:GetUniqueNameFor(current())}"
					ID="{$html-id}FileSize" TYPE="TEXT" TABINDEX="-1" VALUE="" READONLY="1" DISABLED="1">
					<!-- 
						��������� ������������/�������������� �������
						� ������ �������������� �������� ����������� ����. 
						�������� �����
					 -->					
					<xsl:choose>
						<xsl:when test="'1'=$maybenull">
							<!-- ���������� ����� ��-������������� �������� -->
							<xsl:attribute name="CLASS">x-editor-control</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<!-- ���������� ����� ������������� �������� -->
							<xsl:attribute name="CLASS">x-editor-control-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</INPUT>
			</TD>
			<TD>
				<!-- 
					������ ��� ������ �������� ��� ��������� 
					
					� �������� �������������� ���������� ������� html-id ���������� 
					��������. ��� �������� � ���������� ����������� ����������� 
					������� � �������������� ��������� ������� �� ����.

					�������������� ������� X_DESCR �������� �������� ��������, 
					�������, � ����� ������, ����� ���������� �� �������� 
					� ����������. ���� ������� �������� �������� �������� 
					��������������� � ��������� �������� �� ����.
					
					�������������� �������� X_FILTERS, X_MAX_FILE_SIZE, 
					X_FILE_NAME_IN, X_TITLE, X_IS_IMAGE, X_MAX_WIDTH, 
					X_MIN_WIDTH, X_MAX_HEIGHT, X_MIN_HEIGHT, X_OFF_VIEW 
					X_OFF_CLEAR � X_OFF_SHOWSIZE ����� ��������� �������
					��������� �������, ��� �������� ������������ �� �� ����.
				-->
				<BUTTON 
					NAME="{b:GetUniqueNameFor(current())}"
					ID="{$html-id}" 
					DISABLED="1"
					FileNameID="{$html-id}FileName"
					FileSizeID="{$html-id}FileSize" 
					CLASS="x-editor-file-button" 
					X_DESCR="{$description}"
					FileNameFilters="{$filters}"
					MaxFileSize="{$max-file-size}"
					PropertyType="{$vt}"
					PropertyNameToStoreFileName="{$file-name-in}"
					ChooseFileTitle="{$t}"
					IsPicture="{$is-image}"
					X_OFF_VIEW="{$off-view}" 
					X_OFF_CLEAR="{$off-clear}" 
					DoNotShowFileSize="{$off-showsize}"
					MaxImageWidth="{$max-width}" 
					MinImageWidth="{$min-width}" 
					MaxImageHeight="{$max-width}"
					MinImageHeight="{$min-height}"
					X_DISABLED="{$disabled+1}"
					X_PROPERTY_EDITOR = "XPEBinaryPresentationClass"
					
					TITLE="{$t}"
				>
						
					<!-- 
						���� �������� ����� ��������� NULL-�������� - �������� ������� 
						X_MAYBENULL. ���� ������� �������� �������������� ������������ 
						�������� �������� ��� ��������� �� ����.
					-->
					<xsl:choose>
						<xsl:when test="'1'=$maybenull">
							<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<!-- 
						������, ������������ ������� ������.
						��������: ��� ������� ����������� ������� ������������ 
						����� ������� ������, �������������� ��������� �������,
						��������� ����� �������� ����� � CSS
					-->
					<xsl:choose>
						<xsl:when test="'dots'=$select-symbol">
							<!-- ������: ����� -->
							<SPAN STYLE="font-family:Verdana;">...</SPAN>
						</xsl:when>
						<xsl:otherwise>
							<!-- ��� ��������� ������: ������� -->
							<SPAN STYLE="font-family:Webdings">&#54;</SPAN>
						</xsl:otherwise>
					</xsl:choose>

				</BUTTON>
				<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" event="OnClick">
					<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").ShowMenu
				</SCRIPT>				
				<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnKeyUp">
					<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnKeyUp
				</SCRIPT>				
			</TD>
		</TR>
		</TBODY>
		</TABLE>
		
	</xsl:template>
</xsl:stylesheet>
