<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	����������� �������� ��������� ���������  �����������/����������� ��� ��������� ������� �������
	���� "dateTime.tz", "date", "time.tz"
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
		����������� ������ ��������� ���������  �����������/����������� ��� ��������� ������� �������
		���� "dateTime", "date", "time"
		������� ��������
			urn:object-editor-access - ��������� ������� EditorData									
		�������������� �������:																		
			�������� ������� X-Storage
		������� ���������:
			[in] disabled - ������� ���������������� ����
			[in] maybenull	- ������� ������������ ������� ��������	(0/1)										
			[in] description - �������� ����
			[in] off-checkbox - ������� ���������� ��������
			[in] format	- ������ �����������										
			[in] up-down - Up-Down � �������� (��� ������������� ���������� ������������� �������)
			[in] vt - ��� ��-�� (date dateTime time)
			
		��������� �������������:
			HTML -	���, ����������� ��������� ��� ��������� �����������/����������� ��������� ������� ������� 
					���� "dateTime", "date", "time"

		TODO: min/max !!!
	-->	
	<xsl:template name="std-template-date">
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
		<!-- ���� �������� ����� � 1, �� ������� � �������� ���� �� ������������ -->
		<xsl:param name="off-checkbox" select="b:nvl(string($xml-params/@off-checkbox), string($xml-prop-md/i:dtpicker/@off-checkbox))"/>
		<!-- ������ ����������� -->
		<xsl:param name="format" select="b:nvl(string($xml-params/@format), string($xml-prop-md/i:dtpicker/@format))"/>
		<!-- Up-Down � �������� (��� ������������� ���������� ������������� �������) -->
		<xsl:param name="up-down" select="b:nvl(string($xml-params/@up-down),string($xml-prop-md/i:dtpicker/@up-down))"/>
		<!-- ������� ��������� ��������������� �������� ����� ������������ ���� ��� ����� � ���������� -->
		<xsl:param name="autoshift" select="b:nvl( b:nvl(string($xml-params/@autoshift), string($xml-prop-md/i:dtpicker/@autoshift)), '1')" />
		
		<!-- ��� �������� -->
		<xsl:param name="vt" select="b:nvl(string($xml-params/@vt),string($xml-prop-md/@vt))"/>
		<!-- ������������� �������� Html-�������� ��� PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- ���������� � ������������� VBS-���������� � ����������� ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>
		<!-- 
		������� ������ DateTimePicker (���������� ��������������� - �� �������������� ����� �� ���������� �������������) 
		
				� ���-�� �������������� ���������� ������� html-id ���������������
				���������� ��-��. ��� �������� � ���������� ����������� ����������� 
				������� � �������������� ��������� ������� �� ����.

				�������������� ������� X_DESCR ����� ������� �������� ��-��, �������,
				� ����� ������ ����� ���������� �� �������� � ����������.
				���� ������� �������� �������� �������� ��������������� � ���������
				�������� �� ����.
				
				�������������� ������� X_DATETYPE �������� ������ � ����� ����-�������,
				� ��� �� ����, ��� � ���, �������� ��� DS-��������
		-->	
		<OBJECT	
			ID="{$html-id}" CLASSID="{b:Evaluate('CLSID_DT_PICKER')}" BORDER="0"
			NAME="{b:GetUniqueNameFor(current())}"
			X_DATETYPE = "{$vt}"
			X_DESCR = "{$description}" 
			X_DISABLED = "{$disabled+1}"
			X_PROPERTY_EDITOR = "XPEDateTimeClass"
		>
			<xsl:choose>
				<xsl:when test="1=$maybenull">
					<!-- 
						���� �������� ����� ��������� NULL-�������� - �������� 
						������� X_MAYBENULL ��� �������� �������������� ������������
						�������� �������� ��� ��������� �� ����.
					-->						
					<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
					<!-- ���������� ����� ��-������������� �������� -->
					<xsl:attribute name="CLASS">x-editor-control x-editor-datetime-field</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<!-- ���������� ����� ������������� �������� -->
					<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-datetime-field</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:choose>
				<xsl:when test="''=$format">
					<!--
						���������������� ������ �� �����. � ����������� �� ���� �������� ����� 
						������� ������ ����������� �������
					-->	
					<xsl:choose>
						<xsl:when test="'dateTime' = $vt">
							<PARAM NAME="CustomFormat" VALUE="dd.MM.yyyy HH:mm"></PARAM>
							<PARAM NAME="UpDown" VALUE="0"></PARAM>
						</xsl:when>
						<xsl:when test="'date' = $vt">
							<PARAM NAME="CustomFormat" VALUE="dd.MM.yyyy"></PARAM>
							<PARAM NAME="UpDown" VALUE="0"></PARAM>
						</xsl:when>
						<xsl:when test="'time' = $vt">
							<PARAM NAME="CustomFormat" VALUE="HH:mm"></PARAM>
							<PARAM NAME="UpDown" VALUE="1"></PARAM>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<!-- �������� ���������������� ��������� -->
					<PARAM NAME="CustomFormat" VALUE="{$format}"></PARAM>
					<!-- ������� "0" ����� ����������� ��� ��������� ������ ��� ���������� up-down -->
					<PARAM NAME="UpDown" VALUE="0{$up-down}"></PARAM>
				</xsl:otherwise>
			</xsl:choose>
			
			<PARAM NAME="Enabled" VALUE="0"></PARAM>
			<xsl:choose>
				<xsl:when test="$off-checkbox='1'">
					<PARAM NAME="CheckBox" VALUE="0"></PARAM>
				</xsl:when>
				<xsl:otherwise>
					<PARAM NAME="CheckBox" VALUE="1"></PARAM>
				</xsl:otherwise>
			</xsl:choose>
			<PARAM NAME="ShowBorder" VALUE="0"></PARAM>
			<PARAM NAME="LockHtmlKeyboardEvents" VALUE="-1"></PARAM>
			<PARAM NAME="EnableAutoShift" VALUE="{$autoshift}"></PARAM>
		</OBJECT>
		<SCRIPT FOR="{$html-id}" LANGUAGE="VBScript" event="OnDateTimeChange(oSender,vOldValue,vNewValue)">
			window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnChangeAsync",0,"VBScript"
		</SCRIPT>
		<SCRIPT FOR="{$html-id}" EVENT="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" LANGUAGE="VBScript">
			window.setTimeout "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"").Internal_OnKeyUpAsync " &amp; nKeyCode &amp; "," &amp; nFlags, 0, "VBScript"
		</SCRIPT>
	</xsl:template>
</xsl:stylesheet>
