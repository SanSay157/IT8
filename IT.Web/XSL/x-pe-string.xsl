<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	����������� �������� ��������� ���������  �����������/����������� ��� ��������� ��������� ������� 
	�������
-->	
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:d="urn:object-editor-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:b="urn:x-page-builder"
	xmlns:w="urn:editor-window-access"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"
	>

	<!--
		=============================================================================================
		����������� ������ ��������� ���������  �����������/����������� ��� ������������ ��������� ��������� 
		�������	������� � ������������ ������ �� ������
		������� ��������
			urn:object-editor-access - ��������� ������� EditorData									
		�������������� �������:																		
			�������� ������� X-Storage
		������� ���������:
			[in] maybenull		- ������� ������������ ������� ��������	(0/1)										
			[in] description	- �������� ����
			[in] metaname		- ����������������
			[in] disabled		- ������� ���������������� ����
			[in] off-edit		- ���������� ����������� �������������� �������� (������ ����� �� ��������� ���������)
			[in] ot				- ��� ���� ������, ������������� ��� ������� ������ ��������
			[in] listname		- ������� ������, ������������� ��� ������� ������ ��������
			[in] use-cache		- ������� ������������� ���� ��� �������� ������ � ������� (�� ��������� �� ������������) (0/1)	
			[in] cache-salt		- ��������� �� VBS, ���� ������ �� ������������ ��� �������������� ���� ��� ������������ �������� ����
										������:
											cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;)" - ������ ���� ���������� ����������������� ��� ����� ����������
											cache-salt="clng(date())" - ������ ���� ���������� ����������������� ��� � �����
											cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;) &amp; &quot;-&quot; &amp; clng(date())" - ������ ���� ���������� ����������������� ��� � ����� ��� ��� ����� ����������
											cache-salt="MyVbsFunctionName()" - ���������� ���������� �������
			[in] off-reload		- c������� �������� ���������� ������������ ������������� ��� 
									(�� ��������� ��������� ������������)
			[in] pattern 		- ������� ����������� ��������� ��� ��������
			[in] pattern-msg	- ��������� � �������������� ��������

		��������� �������������:
			HTML -	���, ����������� ��������� ��� ��������� �����������/����������� ������������ ��������� ��������� 
			�������	�������
	-->			
	<xsl:template name="std-template-string-lookup" >
		<!-- xml �� ����� ����������� ������� -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml � ������������ -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- ��������: ��� PropertyEditor'a � ���������� -->
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:string-lookup[1]/@n))"/>
		<!-- ��������: ����������� -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- ��������: ������� ������������ ������� �������� -->
		<xsl:param name="maybenull" select="b:nvl(string($xml-params/@maybenull), string($xml-prop-md/@maybenull))"/>
		<!-- ��������: �������� ���� -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
		<!-- ����������: ���������� i:string-lookup -->
		<xsl:param name="xml-lookup-md" select="$xml-prop-md/i:string-lookup[($metaname='' and not(@n)) or (@n=$metaname)]" />
		<!-- ��������: ��� ���� ������, ������������� ��� ������� ������ �������� -->
		<xsl:param name="ot" select="b:nvl(string($xml-params/@ot), string($xml-lookup-md/@ot))"/>
		<!-- ��������: ������� ������, ������������� ��� ������� ������ �������� -->
		<xsl:param name="listname" select="b:nvl(string($xml-params/@listname), string($xml-lookup-md/@use-list))"/>
		<!-- ������������� �������� Html-�������� ��� PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- ��������: ������� ����������� -->
		<xsl:param name="use-cache" select="b:nvl(string($xml-params/@use-cache), string($xml-lookup-md/@use-cache))"/>
		<!-- ��������: �������������� �������� ����������� -->
		<xsl:param name="cache-salt" select="b:nvl(string($xml-params/@cache-salt), string($xml-lookup-md/@cache-salt))"/>
		<!-- ��������: ���������� ����������� �������������� �������� (������ ����� �� ��������� ���������) -->
		<xsl:param name="off-edit" select="b:nvl(string($xml-params/@off-edit), string($xml-lookup-md/@off-edit))"/>
		<!-- ��������: C������� �������� ����������, ������������ ������������� ���  -->
		<xsl:param name="off-reload" select="b:nvl(string($xml-params/@off-reload), string($xml-lookup-md/@off-reload))"/>
		<!-- ��������: ���������� ��������� ��� �������� ��������  -->
		<xsl:param name="pattern" select="b:nvl(string($xml-params/@pattern), string($xml-prop-md/ds:pattern))"/>
		<!-- ��������: ��������� � ��������� ��������  -->
		<xsl:param name="pattern-msg" select="b:nvl(string($xml-params/@pattern-msg), string($xml-prop-md/ds:pattern/@msg))"/>
		<!-- ������������� �������� -->
		<xsl:param name="max" select="b:nvl(string($xml-params/@max), string($xml-prop-md/ds:max))"/>
		<!-- ����������� �������� -->
		<xsl:param name="min" select="b:nvl(string($xml-params/@min), string($xml-prop-md/ds:min))"/>
				
		<!-- ������ �� ObjectEditorClass -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
			<COL WIDTH="100%;"/>
			<xsl:if test="('1'=$use-cache) and ('1'!=$off-reload)">
				<COL STYLE="padding-left:3px;"/>
			</xsl:if>
		<TBODY>
		<TR>
			<TD>
			<!-- 
				�������������� �������� X_DESCR ����� ������� �������� ��-��, �������,
				� ����� ������ ����� ���������� �� �������� � ����������.
				���� �������� �������� �������� �������� ��������������� � ���������
				�������� �� ����.
			-->
			<OBJECT 
				ID="{$html-id}" BORDER="0"  
				CLASSID="clsid:EB98C2B1-BEF9-4C24-B248-0F1634BD1488" 
				HEIGHT="24" WIDTH="100%" 
				MAXLENGTH="{$max}"
				NAME="{b:GetUniqueNameFor(current())}"

				X_MIN="{$min}"
				X_MAX="{$max}"

				Metaname = "{$metaname}" 
				ListMetaname = "{$listname}" 
				TypeName = "{$ot}" 
				X_DESCR = "{$description}"
				X_DISABLED = "{$disabled+1}"
				X_PROPERTY_EDITOR = "XPEStringLookupClass"
				
				UseCache="{$use-cache}" 
				CacheSalt="{$cache-salt}" 
				RefreshButtonID = "{$html-id}Refresh"
				
				RegExpPattern="{$pattern}"
				RegExpPatternMsg="{$pattern-msg}"
			>
				<!-- ��������� ������������/�������������� ������� -->
				<xsl:choose>
					<xsl:when test="'1'=$maybenull">
						<!-- 
							���� �������� ����� ��������� �������� null - �������� ��������������
							�������� X_MAYBENULL.
							���� �������� �������� �������������� ������������ �������� ��-�� ���
							��������� �� ����.
						-->						
						<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
						<!-- ���������� ����� ��-������������� �������� -->
						<xsl:attribute name="CLASS">x-editor-control x-editor-string-lookup-field</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<!-- ���������� ����� ������������� �������� -->
						<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-string-lookup-field</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<PARAM NAME="ENABLED" VALUE="0"></PARAM>
				<xsl:choose>
					<xsl:when test="'1'=$off-edit">				
						<PARAM NAME="EDITABLE" VALUE="0"></PARAM>
					</xsl:when>
					<xsl:otherwise>
						<PARAM NAME="EDITABLE" VALUE="-1"></PARAM>
					</xsl:otherwise>
				</xsl:choose>
				<PARAM NAME="AUTOSEARCH" VALUE="-1"></PARAM>
				<PARAM NAME="LockHtmlKeyboardEvents" VALUE="-1"></PARAM>
			</OBJECT>
			<SCRIPT FOR="{$html-id}" EVENT="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" LANGUAGE="VBScript">
				window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpAsync " &amp; nKeyCode &amp; "," &amp; nFlags, 0, "VBScript"
			</SCRIPT>
			</TD>
			<xsl:if test="('1'=$use-cache) and ('1'!=$off-reload)">
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
				<SCRIPT FOR="{$html-id}Refresh" EVENT="OnClick" LANGUAGE="VBScript">
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
		����������� ������ ��������� ���������  �����������/����������� ��� ������������ ��������� ��������� 
		�������	�������
		������� ��������
			urn:object-editor-access - ��������� ������� EditorData									
		�������������� �������:																		
			�������� ������� X-Storage
		������� ���������:
			[in] disabled		- ������� ���������������� ����
			[in] readonly 		- ������� ���� ������ ��� ������
			[in] maybenull		- ������� ������������ ������� ��������	(0/1)										
			[in] description 	- �������� ����
			[in] pattern 		- ������� ����������� ��������� ��� ��������
			[in] pattern-msg	- ��������� � �������������� ��������
			[in] min			- ����������� ����� ������
			[in] max			- ������������ ����� ������
		��������� �������������:
			HTML -	���, ����������� ��������� ��� ��������� �����������/����������� ������������ ��������� ��������� 
			�������	�������
	-->			
	<xsl:template name="std-template-string">
		<!-- xml �� ����� ����������� ������� -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml � ������������ -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- ��������: ����������� -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- ��������: ������� ���� ������ ��� ������ -->
		<xsl:param name="readonly" select="number(b:nvl(string($xml-params/@readonly),'0'))"/>
		<!-- ��������: ������� ������������ ������� �������� -->
		<xsl:param name="maybenull" select="b:nvl(string($xml-params/@maybenull), string($xml-prop-md/@maybenull))"/>
		<!-- ��������: �������� ���� -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
			
		<!-- ������������� �������� Html-�������� ��� PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		
		<!-- ��������: ���������� ��������� ��� �������� ��������  -->
		<xsl:param name="pattern" select="b:nvl(string($xml-params/@pattern), string($xml-prop-md/ds:pattern))"/>
		<!-- ��������: ��������� � ��������� ��������  -->
		<xsl:param name="pattern-msg" select="b:nvl(string($xml-params/@pattern-msg), string($xml-prop-md/ds:pattern/@msg))"/>
		<!-- ������������� �������� -->
		<xsl:param name="max" select="b:nvl(string($xml-params/@max), string($xml-prop-md/ds:max))"/>
		<!-- ����������� �������� -->
		<xsl:param name="min" select="b:nvl(string($xml-params/@min), string($xml-prop-md/ds:min))"/>
		<!-- ��������: ������ �������� -->
		<xsl:param name="width" select="b:nvl(string($xml-params/@width),'100%')" />
		<!-- ���������� � ������������� VBS-���������� � ����������� ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>

		<!-- 
			� ���-�� �������������� ���������� �������� html-id ���������������
			���������� ��-��. ��� �������� � ���������� ����������� ����������� 
			������� � �������������� ��������� ������� �� ����.

			�������������� �������� X_DESCR ����� ������� �������� ��-��, �������,
			� ����� ������ ����� ���������� �� �������� � ����������.
			���� �������� �������� �������� �������� ��������������� � ���������
			�������� �� ����.
		-->

		<INPUT 	
			ID="{$html-id}" 
			X_DESCR="{$description}"

			TYPE="TEXT" DISABLED="1" VALUE="" 
			X_DISABLED = "{$disabled+1}"
			X_PROPERTY_EDITOR = "XPEStringClass"
			NAME="{b:GetUniqueNameFor(current())}"
			MAXLENGTH="{$max}"
			STYLE="width:{$width};"

			X_MIN="{$min}"
			X_MAX="{$max}"

			RegExpPattern="{$pattern}"
			RegExpPatternMsg="{$pattern-msg}"
		>
			<!-- ������� ReadOnly -->
			<xsl:if test="1=$readonly">
				<xsl:attribute name="readonly">1</xsl:attribute>
			</xsl:if>
			
			<!-- ��������� ������������/�������������� ������� -->
			<xsl:choose>
				<xsl:when test="'1'=$maybenull">
					<!-- 
						���� �������� ����� ��������� �������� null - �������� ��������������
						�������� X_MAYBENULL.
						���� �������� �������� �������������� ������������ �������� ��-�� ���
						��������� �� ����.
					-->						
					<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
					<!-- ���������� ����� ��-������������� �������� -->
					<xsl:attribute name="CLASS">x-editor-control x-editor-string-field</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<!-- ���������� ����� ������������� �������� -->
					<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-string-field</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</INPUT>
		<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" EVENT="OnKeyUp">
			With window.event
				window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpHtmlAsync " &amp; .keyCode &amp; "," &amp; CLng(.altKey) &amp; "," &amp; CLng(.ctrlKey) &amp; "," &amp; CLng(.shiftKey), 0, "VBScript"
			.cancelBubble = True
			End With
		</SCRIPT>				
	</xsl:template>
	

	<!--
		=============================================================================================
		����������� ������ ��������� ���������  �����������/����������� ��� ������������� ��������� ��������� 
		�������	�������
		������� ��������
			urn:object-editor-access - ��������� ������� EditorData									
		�������������� �������:																		
			�������� ������� X-Storage
		������� ���������:
			[in] height - ������ ������ ��� �������������� ���������� ��������
			[in] minrows - ����������� ���������� ����� ��� ��������������
			[in] disabled		- ������� ���������������� ����
			[in] maxrows - ������������ ���������� ����� ��� ��������������
			[in] maybenull	- ������� ������������ ������� ��������	(0/1)										
			[in] description - �������� ����
			[in] readonly - ������� ���� ������ ��� ������
			[in] pattern 		- ������� ����������� ��������� ��� ��������
			[in] pattern-msg	- ��������� � �������������� ��������
		��������� �������������:
			HTML -	���, ����������� ��������� ��� ��������� �����������/����������� ������������� ��������� ��������� 
			�������	�������
	-->			
	<xsl:template name="std-template-text">
		<!-- xml �� ����� ����������� ������� -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml � ������������ -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- ��������: ����������� -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- ��������: ������� ���� ������ ��� ������ -->
		<xsl:param name="readonly" select="number(b:nvl(string($xml-params/@readonly),'0'))"/>
		<!-- ��������: ������� ������������ ������� �������� -->
		<xsl:param name="maybenull" select="b:nvl(string($xml-params/@maybenull), string($xml-prop-md/@maybenull))"/>
		<!-- ��������: �������� ���� -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
			
		<!-- ������������� �������� Html-�������� ��� PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		
		<!-- ��������: ���������� ��������� ��� �������� ��������  -->
		<xsl:param name="pattern" select="b:nvl(string($xml-params/@pattern), string($xml-prop-md/ds:pattern))"/>
		<!-- ��������: ��������� � ��������� ��������  -->
		<xsl:param name="pattern-msg" select="b:nvl(string($xml-params/@pattern-msg), string($xml-prop-md/ds:pattern/@msg))"/>
		<!-- ������������� �������� -->
		<xsl:param name="max" select="b:nvl(string($xml-params/@max), string($xml-prop-md/ds:max))"/>
		<!-- ����������� �������� -->
		<xsl:param name="min" select="b:nvl(string($xml-params/@min), string($xml-prop-md/ds:min))"/>
		<!-- ��������: ������ �������� -->
		<xsl:param name="width" select="b:nvl(string($xml-params/@width),'100%')" />

		<!-- ��������: ������ ������ ��� �������������� ���������� �������� -->
		<xsl:param name="height" select="string($xml-params/@height)"/>
		<!-- ��������: ����������� ���������� ����� ��� �������������� -->
		<xsl:param name="minheight" select="number(b:nvl(string($xml-params/@minheight),'1'))"/>
		<!-- ��������: ������������ ���������� ����� ��� �������������� -->
		<xsl:param name="maxheight" select="number(b:nvl(string($xml-params/@maxheight),'200'))"/>
		<!-- ��������: ������� ����� -->
		<xsl:param name="wrap" select="b:nvl(string($xml-params/@wrap),'soft')"/>

		<!-- ���������� � ������������� VBS-���������� � ����������� ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		
		<!-- 
			� ���-�� �������������� ���������� �������� html-id ���������������
			���������� ��-��. ��� �������� � ���������� ����������� ����������� 
			������� � �������������� ��������� ������� �� ����.

			�������������� �������� X_DESCR ����� ������� �������� ��-��, �������,
			� ����� ������ ����� ���������� �� �������� � ����������.
			���� �������� �������� �������� �������� ��������������� � ���������
			�������� �� ����.
		-->
				
		<TEXTAREA 
			ID="{$html-id}" 
			X_DESCR="{$description}"
					
			WRAP="{$wrap}" DISABLED="1" 
			X_DISABLED = "{$disabled+1}"
			X_RowHeight="10"
			X_PROPERTY_EDITOR = "XPEStringClass"
			LANGUAGE="VBScript"
			NAME="{b:GetUniqueNameFor(current())}"
			MAXLENGTH="{$max}"

			X_MIN="{$min}"
			X_MAX="{$max}"
			
			X_MinH="{$minheight}"
			X_MaxH="{$maxheight}"

			RegExpPattern="{$pattern}"
			RegExpPatternMsg="{$pattern-msg}"
		>
			<!-- ������� ReadOnly -->
			<xsl:if test="1=$readonly">
				<xsl:attribute name="READONLY">1</xsl:attribute>
			</xsl:if>
			
			<xsl:if test="''=$height">
				<xsl:attribute name="ROWS">1</xsl:attribute>
				<xsl:attribute name="X_IS_SMART">YES</xsl:attribute>
				<xsl:attribute name="OnClick"><xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_SmartTextAreaOnAdjustSize</xsl:attribute>
			</xsl:if>
			
			<!-- ��������� ������������/�������������� ������� -->
			<xsl:attribute name="style">width:100%;overflow:auto;
				<xsl:if test="''!=$height">
					height:<xsl:value-of select="$height"/>;
				</xsl:if>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="'1'=$maybenull">
					<!-- 
						���� �������� ����� ��������� �������� null - �������� ��������������
						�������� X_MAYBENULL.
						���� �������� �������� �������������� ������������ �������� ��-�� ���
						��������� �� ����.
					-->						
					<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
					<!-- ���������� ����� ��-������������� �������� -->
					<xsl:attribute name="CLASS">x-editor-control x-editor-text-field</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<!-- ���������� ����� ������������� �������� -->
					<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-text-field</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</TEXTAREA>
		<SCRIPT LANGUAGE="VBScript" FOR="{$html-id}" EVENT="OnKeyUp" >
		<xsl:if test="''=$height">
			<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_SmartTextAreaOnAdjustSize
		</xsl:if>
		With Window.Event
			IF (.KeyCode = VK_ENTER) AND NOT .CtrlKey AND NOT .AltKey AND NOT .shiftKey THEN
				.cancelBubble = True
			END IF
		End With
		</SCRIPT>
		<xsl:if test="''=$height">
			<SCRIPT LANGUAGE="VBScript" FOR="{$html-id}" EVENT="OnPropertyChange" >
				If 0=StrComp(window.event.propertyName,"VALUE", vbTextCompare ) Then 
					<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_SmartTextAreaOnAdjustSize
				End If	
			</SCRIPT>
		</xsl:if>

	</xsl:template>

</xsl:stylesheet>
