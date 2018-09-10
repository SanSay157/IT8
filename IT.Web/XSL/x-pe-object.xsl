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
		������� ��������
			urn:object-editor-access - ��������� ������� EditorData									
		�������������� �������:																		
			�������� ������� X-Storage
		������� ���������:
			[in] disabled		- ������� ���������������� ����
			[in] maybenull		- ������� ������������ ������� ��������	(0/1)										
			[in] description 	- �������� ����
		��������� �������������:
			HTML -	���, ����������� ��������� ��� ��������� �����������/����������� ��������� ��������� ������� 
			�������
	-->		
	<xsl:template name="std-template-object">
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
		<!-- ������������� �������� Html-�������� ��� PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- ���������� � ������������� VBS-���������� � ����������� ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		
		<!-- 
			�������� 2 ��������:
				1)	������ � ���������� ���������� i:object-presentation - ������� ���
				2)	������ � ���������� ���������� i:object-dropdown - ������� ���
		-->
		<xsl:choose>
			<xsl:when test="$xml-prop-md/i:object-presentation[1]">
				<xsl:call-template name="std-template-object-presentation">
					<xsl:with-param name="description"><xsl:value-of select="$description"/></xsl:with-param>
					<xsl:with-param name="maybenull"><xsl:value-of select="$maybenull"/></xsl:with-param>
					<xsl:with-param name="disabled"><xsl:value-of select="$disabled"/></xsl:with-param>
					<xsl:with-param name="html-id"><xsl:value-of select="$html-id"/></xsl:with-param>
					<xsl:with-param name="xml-params" select="$xml-params"/>
					<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
				</xsl:call-template>
			</xsl:when>	
			<xsl:otherwise>
				<xsl:call-template name="std-template-object-dropdown">
					<xsl:with-param name="description"><xsl:value-of select="$description"/></xsl:with-param>
					<xsl:with-param name="maybenull"><xsl:value-of select="$maybenull"/></xsl:with-param>
					<xsl:with-param name="disabled"><xsl:value-of select="$disabled"/></xsl:with-param>
					<xsl:with-param name="html-id"><xsl:value-of select="$html-id"/></xsl:with-param>
					<xsl:with-param name="xml-params" select="$xml-params"/>
					<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		=============================================================================================
		����������� ������ ��������� ���������  �����������/����������� ��� ��������� ��������� �������
		������� � ���� ����������� ������
		������� ��������
			urn:object-editor-access - ��������� ������� EditorData									
		�������������� �������:																		
			�������� ������� X-Storage
		������� ���������:
			[in] maybenull			- ������� ������������ ������� ��������	(0/1)										
			[in] description		- �������� ����
			[in] metaname			- ���������������� ������ �������� � ����������
			[in] disabled			- ������� ���������������� ����
			[in] no-empty-value		- ������� ���������� ������� ��������
			[in] empty-value-text	- ����� ������� �������� ����������� ������
			[in] use-cache			- ������� ������������� ���� ��� �������� ������ � ������� (�� ��������� �� ������������) (0/1)	
			[in] cache-salt			- ��������� �� VBS, ���� ������ �� ������������ ��� �������������� ���� ��� ������������ �������� ����
										������:
											cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;)" - ������ ���� ���������� ����������������� ��� ����� ����������
											cache-salt="clng(date())" - ������ ���� ���������� ����������������� ��� � �����
											cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;) &amp; &quot;-&quot; &amp; clng(date())" - ������ ���� ���������� ����������������� ��� � ����� ��� ��� ����� ����������
											cache-salt="MyVbsFunctionName()" - ���������� ���������� �������
		��������� �������������:
			HTML -	���, ����������� ��������� ��� ��������� �����������/����������� ��������� ��������� ������� 
			�������
	-->		
	<xsl:template name="std-template-object-dropdown">
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
		<!-- ��������: ��� PropertyEditor'a � ���������� -->
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:object-dropdown/@n))"/>
		<!-- ���������� pe: i:object-dropdown -->
		<xsl:param name="pe-md" select="$xml-prop-md/i:object-dropdown[($metaname='' and not(@n)) or ($metaname=@n)]"/>
		<!-- ��������: ���������������� ������, ������������� ��� ���������� ���������� -->
		<xsl:param name="list-metaname" select="b:nvl(string($xml-params/@list-metaname), string($pe-md/@use-list))" />
		<!-- ��������: ������� ������������� CROC.XComboBox ������ �������� ���������� -->
		<xsl:param name="use-activex" select="b:nvl(string($xml-params/@use-activex), string($pe-md/@use-activex))"/>
		<!-- ��������: �� ��������� ������ ������ � ��������� (�� ��������� �����������) -->
		<xsl:param name="no-empty-value" select="b:nvl(string($xml-params/@no-empty-value), string($pe-md/@no-empty-value))"/>
		<!-- ��������: ����� ������� �������� ����������� ������ -->
		<xsl:param name="empty-value-text" select="b:nvl(string($xml-params/@empty-value-text), string($pe-md/@empty-value-text))"/>
		<!-- ��������: ������� ����������� -->
		<xsl:param name="use-cache" select="b:nvl(string($xml-params/@use-cache), string($pe-md/@use-cache))"/>
		<!-- ��������: �������������� �������� ����������� -->
		<xsl:param name="cache-salt" select="b:nvl(string($xml-params/@cache-salt), string($pe-md/@cache-salt))"/>
		<!-- ��������: C������� �������� ����������, ������������ ������������� ���  -->
		<xsl:param name="off-reload" select="b:nvl(string($xml-params/@off-reload), string($pe-md/@off-reload))"/>
			
		<!-- ��������: ������������� �������� Html-�������� ��� PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- ���������� � ������������� VBS-���������� � ����������� ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		<!-- ������� ����������� ������ ������������ ������ -->
		<xsl:variable name="show-reload-button" select="('1'=$use-cache) and ('1'!=$off-reload)"/>
		
		<!-- 
			� �������� �������������� ���������� ������� html-id ���������� 
			��������. ��� �������� � ���������� ����������� ����������� 
			������� � �������������� ��������� ������� �� ����.

			�������������� ������� X_DESCR ����� ������� �������� ��������, 
			�������,� ����� ������ ����� ���������� �� ��������� � ����������.
			���� ������� �������� �������� �������� ��������������� � ���������
			�������� �� ����.

			������� X_METANAME �������� ���������������� ������ ��������.
			������� X_DISABLED �������� ������� ��������������� �������� (0/1)
		-->
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
			<COL WIDTH="100%;"/>
			<xsl:if test="$show-reload-button">
				<COL STYLE="padding-left:3px;"/>
			</xsl:if>
		<TBODY>
			<TR>
				<TD>
				<xsl:choose>
					<!-- 
						UI-������������� ���������� ���������� ��������: ������������� ���������� ������
					-->
					<xsl:when test="$use-activex='1'">
						<OBJECT
							ID="{$html-id}"
							CLASSID="{b:Evaluate('CLSID_COMBOBOX')}" 
							BORDER="0"
							WIDTH="100%"
							TABINDEX="0"
							NAME="{b:GetUniqueNameFor(current())}"
						
							X_LISTMETANAME="{$list-metaname}" 
							X_DESCR="{$description}"
							X_DISABLED="{$disabled+1}"
							PEMetadataLocator="{concat( 'i:object-dropdown',user:GetMetaNameFilter( string( $metaname )))}"
							X_PROPERTY_EDITOR = "XPEObjectDropdownClass"
							NoEmptyValue = "{$no-empty-value}"
							EmptyValueText="{$empty-value-text}"
							UseCache="{$use-cache}" 
							CacheSalt="{$cache-salt}" 
							RefreshButtonID = "{$html-id}Refresh"
						>
							<!-- ��������� ������������/�������������� ������� -->
							<xsl:choose>
								<xsl:when test="'1'=$maybenull">
									<!-- 
										���� �������� ����� ��������� �������� null - �������� ��������������
										������� X_MAYBENULL.
										���� ������� �������� �������������� ������������ �������� ��-�� ���
										��������� �� ����.
									-->						
									<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
									<!-- ���������� ����� ��-������������� �������� -->
									<xsl:attribute name="CLASS">x-editor-control x-editor-dropdown x-editor-dropdown-activex</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<!-- ���������� ����� ������������� �������� -->
									<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-dropdown  x-editor-dropdown-activex</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
	 
							<PARAM NAME="Enabled" VALUE="0"></PARAM>
							<PARAM NAME="Editable" VALUE="-1"></PARAM>
							<PARAM NAME="AutoSearch" VALUE="-1"></PARAM>
							<PARAM NAME="EmptySelectionText" VALUE="{$empty-value-text}"></PARAM>
							<PARAM NAME="LockHtmlKeyboardEvents" VALUE="-1"></PARAM>
						</OBJECT>
						
						<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnItemSelect( ByVal oSender, ByVal nItemIndex, ByVal sItemID, sText )">
							If 0 = Len(sItemID) Then oSender.text = oSender.EmptySelectionText
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnChange
						</SCRIPT>
						<SCRIPT FOR="{$html-id}" EVENT="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" LANGUAGE="VBScript">
							window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpAsync " &amp; nKeyCode &amp; "," &amp; nFlags, 0, "VBScript"
						</SCRIPT>
					</xsl:when>
			
					<!-- 
						UI-������������� ���������� ���������� ��������: ���������� ������
					-->
					<xsl:otherwise>
						<SELECT
							ID="{$html-id}" 
							DISABLED="1" STYLE="width:100%" 
							
							X_LISTMETANAME="{$list-metaname}" 
							X_DESCR="{$description}"
							X_DISABLED="{$disabled+1}"
							PEMetadataLocator="{concat( 'i:object-dropdown',user:GetMetaNameFilter( string( $metaname )))}"
							X_PROPERTY_EDITOR = "XPEObjectDropdownClass"
							NoEmptyValue = "{$no-empty-value}"
							EmptyValueText="{$empty-value-text}" 
							UseCache="{$use-cache}" 
							CacheSalt="{$cache-salt}" 
							RefreshButtonID = "{$html-id}Refresh"
						>
							<!-- ��������� ������������/�������������� ������� -->
							<xsl:choose>
								<xsl:when test="'1'=$maybenull">
									<!-- 
										���� �������� ����� ��������� �������� null - �������� ��������������
										������� X_MAYBENULL.
										���� ������� �������� �������������� ������������ �������� ��-�� ���
										��������� �� ����.
									-->						
									<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
									<!-- ���������� ����� ��-������������� �������� -->
									<xsl:attribute name="CLASS">x-editor-control x-editor-dropdown</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<!-- ���������� ����� ������������� �������� -->
									<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-dropdown</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							
							<!-- ������� ������ ��������, ���� ��� ���� �� ��������� ���������� -->
							<xsl:if test="$no-empty-value!='1'">
								<!-- ���� � �������� ���������� i:object-dropdown ����� �����, ��������� ��� � ������ -->
								<xsl:choose>
									<!-- ���� � �������� ���������� i:object-dropdown ����� �����, ��������� ��� � ������ -->
									<xsl:when test="$empty-value-text">
										<option selected="1"><xsl:value-of select="$empty-value-text"/></option>
									</xsl:when>
									<!-- ���� ����� ������� �������� �� �����, ��������� ������ ������� -->
									<xsl:otherwise>
										<option selected="1"></option>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</SELECT>
						<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnChange">
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_OnChange
						</SCRIPT>
						<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnKeyUp">
							With window.event
								window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpHtmlAsync " &amp; .keyCode &amp; "," &amp; CLng(.altKey) &amp; "," &amp; CLng(.ctrlKey) &amp; "," &amp; CLng(.shiftKey), 0, "VBScript"
							.cancelBubble = True
							End With
						</SCRIPT>				
					</xsl:otherwise>
				</xsl:choose>
				</TD>
					
				<xsl:if test="$show-reload-button">
				<TD>
					<BUTTON 
						ID="{$html-id}Refresh" 
						NAME="{b:GetUniqueNameFor(current())}"
						TITLE="�������� ������ ������"
						DISABLED="1" 
						CLASS="x-editor-objectpresentation-button" 
						STYLE="background-color:#cccccc; border-color:#eeeeee; padding:0px; margin-left:2px;"
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
		</TBODY>
		</TABLE>					
	</xsl:template>


	<!--
		=============================================================================================
		����������� ������ ��������� ���������  �����������/����������� ��� ��������� ��������� �������
		������� � ���� ������� ������������� ������� � ������ �������� ��� ���
		������� ��������
			urn:object-editor-access - ��������� ������� EditorData									
		�������������� �������:																		
			�������� ������� X-Storage
		������� ���������:
			[in] maybenull		- ������� ������������ ������� ��������	(0/1)										
			[in] description	- �������� ����
			[in] metaname		- ��� i:object-presentation � ���������
			[in] disabled		- ������� ���������������� ����
			[in] off-create		- ���������� �������� �������
			[in] off-select		- ���������� �������� �������
			[in] off-edit		- ���������� �������� ��������
			[in] off-unlink 	- ���������� �������� ��������� �����
			[in] off-delete		- ���������� �������� �������
		��������� �������������:
			HTML -	���, ����������� ��������� ��� ��������� �����������/����������� ��������� ��������� ������� 
			�������
	-->		
	<xsl:template name="std-template-object-presentation">
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
		<!-- ��������: ��� PropertyEditor'a � ���������� -->
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:object-presentation/@n))"/>
		<!-- ���������� pe: i:object-dropdown -->
		<xsl:param name="pe-md" select="$xml-prop-md/i:object-presentation[($metaname='' and not(@n)) or ($metaname=@n)]"/>
		<!-- ���������� ���������� -->
		<xsl:param name="off-create" select="b:nvl(string($xml-params/@off-create), string($pe-md/@off-create))"/>
		<xsl:param name="off-edit"   select="b:nvl(string($xml-params/@off-edit),   string($pe-md/@off-edit))"/>
		<xsl:param name="off-select" select="b:nvl(string($xml-params/@off-select), string($pe-md/@off-select))"/>
		<xsl:param name="off-unlink" select="b:nvl(string($xml-params/@off-unlink), string($pe-md/@off-unlink))"/>
		<xsl:param name="off-delete" select="b:nvl(string($xml-params/@off-delete), string($pe-md/@off-delete))"/>
		<!-- ��������: ���������� ���� �������� -->
		<xsl:param name="off-operations" select="b:nvl(string($xml-params/@off-operations), string($pe-md/@off-operations))"/>
		<!-- ��������: ������, ������������ ������� ������ (�� ������ ������ �� �������� �����������) -->
		<xsl:param name="select-symbol" select="b:nvl(string($xml-params/@select-symbol), 'arrow')"/>
		<!-- ������������ ���������, ������������� ��� �������� ������� -->
		<xsl:param name="use-for-creation" select="b:nvl(string($xml-params/@use-for-creation), string($pe-md/@use-for-creation))"/>
		<!-- ������������ ���������, ������������� ��� �������������� ������� -->
		<xsl:param name="use-for-editing" select="b:nvl(string($xml-params/@use-for-editing), string($pe-md/@use-for-editing))"/>
		<!-- ������������ ������, ������������� ��� ������ -->
		<xsl:param name="use-list-selector" select="b:nvl(string($xml-params/@use-list-selector), string($pe-md/@use-list-selector))"/>
		<!-- ������������ ������, ������������� ��� ������ -->
		<xsl:param name="use-tree-selector" select="b:nvl(string($xml-params/@use-tree-selector), string($pe-md/@use-tree-selector))"/>
		<!-- ������������� �������� Html-�������� ��� PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>			
		<!-- ������� ��������������� ��������� ������� ��� ���������� ���� -->
		<xsl:param name="auto-tooltip" select="b:nvl(string($xml-params/@auto-tooltip), string($pe-md/@auto-tooltip))"/>
			
		<!-- ���������� � ������������� VBS-���������� � ����������� ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		<!-- ��������� ��� ���������� ������������� �������� � Html -->
		<xsl:variable name="expression" select="string($pe-md/i:value)"/>
			
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
			<COL WIDTH="100%;"/>
			<COL STYLE="padding-left:3px;"/>
		<TBODY>
		<TR>
			<TD>
				<!-- 
					���� ��� ������ ������ ������������� ������� 
					
					Read-only ���� (������ ��� ������)
					� �������� ������ ��� �������������� ���������� ������� 
					html-id ��������������� ���������� ��������. ��� �������� 
					����������� ����������� ������� � �������������� ��������� 
					������� �� ����������� ����.
				-->
				<INPUT ID="{$html-id}Caption" TYPE="TEXT" READONLY="1" TABINDEX="-1" VALUE="" DISABLED="1" STYLE="width:100%">
					<!-- ��������� ������������/�������������� ������� -->
					<xsl:choose>
						<xsl:when test="1=$maybenull">
							<xsl:attribute name="CLASS">x-editor-control x-editor-objectpresentation-text</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-objectpresentation-text</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</INPUT>
			</TD>
			<TD>
				<!--
					������ �������� � ��������, ������������ ���������
					�� ������������, ���� ��� �������� � �������� ��������:
					������ ��� ������ "���������"
				-->
					<xsl:if test="$off-operations">
						<xsl:attribute name="STYLE">display:none</xsl:attribute>
					</xsl:if>
					
				<!-- 
					� �������� �������������� ���������� ������� html-id 
					��������������� ���������� ��������. ��� �������� � 
					���������� ����������� ����������� ������� � �������������� 
					��������� ������� �� ����.

					������� X_DESCR ����� ������� �������� ��������, �������, 
					� ����� ������ ����� ���������� �� �������� � ����������. 
					���� ������� �������� �������� �������� ��������������� 
					� ��������� �������� �� ����.
				-->
				
				<!--
					!!! ������������ ����� ��������, �� ������ ��������!!!
					STYLE="
						position:relative; overflow-y:hidden; overflow-x:visible; 
						height:expression(document.all(this.INPUTID).offsetHeight); width:expression(this.clientHeight);
						line-height:expression(this.offsetHeight/2+'px');"
				-->
				<BUTTON
					ID="{$html-id}" DISABLED="1" 
					CLASS="x-editor-objectpresentation-button"
					NAME="{b:GetUniqueNameFor(current())}"
					
					INPUTID="{$html-id}Caption" 
					
					X_PROPERTY_EDITOR = "XPEObjectPresentationClass"
					X_DESCR="{$description}" 
					X_DISABLED="{$disabled+1}"
					
					PEMetadataLocator = "{concat( 'i:object-presentation',user:GetMetaNameFilter( string( $metaname )))}"
					
					OFF_CREATE ="{$off-create}"
					OFF_EDIT   ="{$off-edit}"
					OFF_SELECT ="{$off-select}"
					OFF_UNLINK ="{$off-unlink}"
					OFF_DELETE ="{$off-delete}"
					EditorMetanameForCreating = "{$use-for-creation}"
					EditorMetanameForEditing  = "{$use-for-editing}"
					ListSelectorMetaname = "{$use-list-selector}"
					TreeSelectorMetaname = "{$use-tree-selector}"
					ObjectPresentationExpression="{$expression}" 
					AutoToolTip="{$auto-tooltip}"
				>
					<!-- ���� ��� �������� ��������� - �� � ��������� ������ ��� �� ��������� -->
					<xsl:if test="$off-operations">
						<xsl:attribute name="TABINDEX">-1</xsl:attribute>
					</xsl:if>						
					
					<!-- 
						���� �������� ����� ��������� �������� null - �������� 
						������� X_MAYBENULL. ���� ������� �������� �������������� 
						������������ �������� �������� ��� ��������� �� ����.
					-->						
					<xsl:if test="'1'=$maybenull">
						<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
					</xsl:if>
					
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
