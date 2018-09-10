<?xml version="1.0" encoding="windows-1251"?>
<!--
********************************************************************************
	������� ������������ ���������� ��������� - Incident Tracker
	��� ���� �������������, 2005
********************************************************************************
	������ ������������ HTML-������������� "��������������" ����
	������������ ��� ����������� ������� � ����� ���� ("��������" ��������,
	���� � �������� ����� ������ �������, ���������������� �������� � �.�.)
	
	��������! ��� �����, ������������ � �������������� HTML, �����������!
-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:user="urn:���_�����_���_�����_msxsl:script"
	xmlns:m="urn:menu-object-access"
	xmlns:tp="urn:sender-object-access"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"
>	
	
<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>

<!-- ������������ ���������-����������� ����� �� ������ ����. �������� ���������:
	{handler-proc-name}(sAction)
-->
<xsl:param name="handler-proc-name" select="'alert '"/>

<msxsl:script language="VBScript" implements-prefix="user">
	<![CDATA['<%
	' ��������� ��������������� ���:
	
	'***************************************************************************
	' ��������� ���������������� ���������������, ���������� � ������ ��������,
	' ��� ���������� ��������� �������, ��� ������� ����������� ������ "�����������"
	
	' ��������� ������� � ��� ��������� ��������
	Dim g_nFollowerPaneIDsCounter	
	'g_nFollowerPaneIDsCounter = 0
	
	' ���������� "���������" ���������� ������������� ���� tdFollowerPane_NNN, 
	' ��� NNN - ������� �������� ��������; ��� ���� �������� �������� �������������
	Function GetNextFollowerPaneID()
		g_nFollowerPaneIDsCounter = g_nFollowerPaneIDsCounter + 1
		GetNextFollowerPaneID = "tdFollowerPane_" & CStr(g_nFollowerPaneIDsCounter)
	End Function
	
	'***************************************************************************
	' ������ ����������� ������ ������� "�������" ��������
	' � ������ ������� ����� �������������� ���� ����� �� ������ ������� ������;
	' �.�. ���-�� ������� ����� ���������� ������ ������� ������ (���� �� ���, 
	' �� ����� ���� �������). ����������� ������ ���� 100%, ����������� �� ���-��
	' �������. ��������� ������������ � ���� ������ ������� "NN%"
	Function GetPaneQnt( oNodeList )
		GetPaneQnt = ""
		If ("IXMLDOMNodeList" = TypeName(oNodeList)) Then
			If (oNodeList.length > 0) Then
				GetPaneQnt = CStr( CLng( 100 / oNodeList.length ) + 1 ) & "%"
			End If
		End If
		If 0 = Len(GetPaneQnt) Then GetPaneQnt = "100%"
	End Function
	
	'***************************************************************************
	' ���������, ��� �������� ������ �������� ��-������ ����� (�.�. ���-��,
	' �������� �� ��������, ���������, ��������� ������). 
	Function IsNonBlankText( vText )
		vText = "" & vText
		vText = Trim( Replace( Replace( Replace( vText,chr(9),"" ), chr(10),"" ), chr(13),"" ) )
		IsNonBlankText = CBool( Len(vText) > 0 )
	End Function
	
	'***************************************************************************
	' ����������� ������� - ��� ������� &nbsp; � HTML-����� 
	Function NBSP()
		NBSP = "&nbsp;"
	End Function
	
	'%>']]>
</msxsl:script>


<!-- ������ �������������� �������� ���� -->
<xsl:template match="i:menu">
	<!-- 
		��� ������ ������� ������ ���������������� ��� "�������" ����� "��������" 
		���������; ��� ����������� ����������� �.�. ���������� ���� �� ���� ������
		
		NB! ���������� ��������� �����������: ���� �� ������ ������ ���� � ������, 
		� ������ ����, �� ��������� ����� ���������������� � � �������� ���������
		������������ �� �����!
	-->
	
	<!-- ������� ������ ������� � "��������" ���������: ������������� ��� 100%, 
		����������� �� ���-�� ������ ������� ������ (���� �� ��� - ������� 100%) -->
	<xsl:variable name="panelWidth" select="user:GetPaneQnt(i:menu-section)"/>
	
	<!-- �������� ������� -->
	<TABLE CELLSPACING="0" CELLPADDING="0" STYLE="width:100%; height:100%;">
		<TR>
		<!-- ...�� ���� ������� ������� ������ -->
		<xsl:for-each select="i:menu-section">

			<!-- ...���� ��� �� ������ ������, ��������� �������-����������� ������� -->
			<xsl:if test="position()!=1">
				<TD STYLE="position:relative; width:2px; height:100%; overflow:hidden; background-color:#369;">
					<IMG SRC="Images/delimiter-vertical.gif" STYLE="width:2px; height:100%;"/>
				</TD>
			</xsl:if>
			
			<!-- ..."�������� �������" -->
			<TD>
				<!--<xsl:attribute name="WIDTH"></xsl:attribute> -->
				<xsl:attribute name="STYLE">
					position:relative; 
					height:100%; width:<xsl:value-of select="$panelWidth"/>;
					padding: 2px;
					background-color: #fff;
				</xsl:attribute> 
				
				<!-- ���������� placeholder -
					��������� ��� ����������� ����������� ���������� � ������, ����� 
					���������� ������� �� ��������� � ���������� ���������� �������
					NB! ����� ��� ���������� ��������������
				-->
					
				<DIV>
					<xsl:attribute name="STYLE">
						position: relative; 
						width:100%; height:100%; 
						padding:8px; overflow:auto; 
						/* ��������� */
						scrollbar-3dlight-color: #bcd;
						scrollbar-arrow-color: #89A;
						scrollbar-face-color: #e9eeff; 
						scrollbar-base-color: #bcd;
						scrollbar-darkshadow-color: #9ab;
						scrollbar-shadow-color: #e9eeff;
						scrollbar-highlight-color: #fff;
					</xsl:attribute>
					
					<!-- ���������� �������: ������ ���� � ���-������ -->
					
					<xsl:for-each select="i:menu-item">
						<xsl:call-template name="nav-menu-items">
							<!-- ���������� ������������ ����������� � ��������� ������ -->
							<xsl:with-param name="handler-proc-name"><xsl:value-of select="$handler-proc-name"/></xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				
					<xsl:for-each select="i:menu-section">
						<xsl:call-template name="nav-menu-section">
							<!-- ���������� ������������ ����������� � ��������� ������ -->
							<xsl:with-param name="handler-proc-name"><xsl:value-of select="$handler-proc-name"/></xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				
				</DIV>
				
			</TD>
			</xsl:for-each>
		</TR>
	</TABLE>
</xsl:template>

<!-- ������ �������������� ��������� ������ -->
<xsl:template name="nav-menu-section">

	<xsl:variable name="FollowerPaneID" select="user:GetNextFollowerPaneID()"/>
	<xsl:variable name="FollowerKeyPaneID" select="concat($FollowerPaneID,'_Key')"/>
	
	<TABLE CELLSPACING="0" CELLPADDING="0" STYLE="width:100%; margin:0px; margin-bottom:5px;">
	<!-- "������" ��������� - �������� ������������ ����� -->
	<TR>
		<TD STYLE="position:relative; overflow:hidden; height:5px; width:5px;"><IMG SRC="Images/it-header-left-369.gif" STYLE="width:5px; height:5px; overflow:hidden;"/></TD>
		<TD STYLE="position:relative; overflow:hidden; height:5px; width:90%; height:5px; background-color:#369; filter: progid:DXImageTransform.Microsoft.Gradient(GradientType=1,StartColorStr='#11336699',EndColorStr='#FF224466');"><IMG WIDTH="1"/></TD>
		<TD STYLE="position:relative; overflow:hidden; height:5px; width:10%; height:5px; background-color:#369; filter: progid:DXImageTransform.Microsoft.Gradient(GradientType=1,StartColorStr='#FF224466',EndColorStr='#FF336699');"><IMG WIDTH="1"/></TD>
		<TD STYLE="position:relative; overflow:hidden; height:5px; width:5px;"><IMG SRC="Images/it-header-right-369.gif" STYLE="width:5px; height:5px; overflow:hidden;"/></TD>
	</TR>
	<!-- ��� ��������: ������ ����������� � ����� + ��� ������������ ����������� / ������������� -->
	<TR>
		<TD COLSPAN="2" 
			FollowerPaneMarker="1"
			STYLE="width:90%; padding:0px 5px 5px 25px; background:#369 url('Images/x-arrowdown.gif') no-repeat 5 0; height:20px; font-family:Verdana; font:bold 12px; color:#eff5ff; filter: progid:DXImageTransform.Microsoft.Gradient(GradientType=1,StartColorStr='#11336699',EndColorStr='#FF224466'); cursor:hand;"
		>
			<xsl:attribute name="ID"><xsl:value-of select="$FollowerKeyPaneID"/></xsl:attribute>
			<xsl:attribute name="FollowerPaneID"><xsl:value-of select="$FollowerPaneID"/></xsl:attribute>
			
			<xsl:for-each select="i:caption">
				<xsl:value-of select="."/>
			</xsl:for-each>
		</TD>
		<TD COLSPAN="2" 
			STYLE="width:10%; padding:0px 0px 5px 0px; background:#369 url('Images/x-arrowdown.gif') no-repeat 5 0; height:20px; font-family:Verdana; font:bold 12px; color:#eff5ff; filter: progid:DXImageTransform.Microsoft.Gradient(GradientType=1,StartColorStr='#FF224466',EndColorStr='#FF336699'); cursor:hand;"
		><IMG WIDTH="1"/></TD>
		
		<SCRIPT LANGUAGE="VBScript" EVENT="ONCLICK">
			<xsl:attribute name="FOR"><xsl:value-of select="$FollowerKeyPaneID"/></xsl:attribute>
			<![CDATA['<%
			
			Dim sFollowerPaneID
			Dim oFollowerPanel
			
			sFollowerPaneID = window.event.srcElement.getAttribute("FollowerPaneID")
			Set oFollowerPanel = document.all(sFollowerPaneID,0)
			
			If hasValue(oFollowerPanel) Then
				If 0 = StrComp("none", oFollowerPanel.style.display, 1) Then
					oFollowerPanel.style.display = "block"
					window.event.srcElement.style.backgroundImage = "url(Images/x-arrowdown.gif)"
				Else
					oFollowerPanel.style.display = "none"
					window.event.srcElement.style.backgroundImage = "url(Images/x-arrowright.gif)"
				End If
			End If
			
			'%>']]>	
		</SCRIPT>
	</TR>
	<!-- ���������� ������ (�������������) -->
	<TR>
		<TD COLSPAN="4" 
			STYLE="border:#369 solid 1px; color:#234; padding:3px; filter:progid:DXImageTransform.Microsoft.Gradient(GradientType=0,StartColorStr='#FFCCDDFF',EndColorStr='#FFFFFFFF');"
		>
			<xsl:attribute name="ID">
				<xsl:value-of select="$FollowerPaneID"/>
			</xsl:attribute>
			
			<!-- ... ������ - ������ ���� -->
			<xsl:for-each select="i:menu-item">
				<xsl:call-template name="nav-menu-items">
					<!-- ���������� ������������ ����������� � ��������� ������ -->
					<xsl:with-param name="handler-proc-name"><xsl:value-of select="$handler-proc-name"/></xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
	
		</TD>
	</TR>
	</TABLE>
</xsl:template>

<!-- ������ �������������� �������� ������� � �������� ������� (���� A) -->
<xsl:template name="nav-menu-items">
	<xsl:variable name="menuItemID" select="concat('menuItem', user:GetNextFollowerPaneID())"/>
	
	<!-- ��� �����:
		NB! ������� �������� ����� "��������" �����������; � ���� ����� ��������� 
		������ (A.hover) �������� ��� ���� ������, � �� ������ ��� ������ ������ -->
	<A	CLASS = "nav-item" 
		STYLE = "display:block; positon:relative; width:100%; margin:2px; margin-top:5px;"
		LANGUAGE = "VBScript"
	>
		<xsl:choose>
			<xsl:when test="@action">
				<xsl:attribute name="HREF">#</xsl:attribute>
				<xsl:attribute name="ONCLICK"><xsl:value-of select="concat($handler-proc-name,' ')"/> "<xsl:value-of select="@n"/>"</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		
		<!-- ��� "������ ����" ����� ���� ������ ������������ ������������ - ��� ������ ���������
			� ������������� Icon, ��� ����������� ����� ����� ��������. ����������� ������ - 16x16 -->
		<xsl:for-each select="./i:params/i:param[@n='Icon']">
			<IMG STYLE="position:relative; margin:0px 3px -3px 1px; border:none; border-width:0px;">
				<xsl:attribute name="SRC">
					<xsl:value-of disable-output-escaping="yes" select="."/>
				</xsl:attribute>
			</IMG>
		</xsl:for-each>
		
		<xsl:value-of select="@t"/>

		<!-- ����������� ������������ ���������:
			���������� ���� ��� ������ ���� ����� ���� ��������� (i:caption) 
			� ��� ���� ����� ���������� ���� <i:param n="ShowTooltip/> -->
		<xsl:if test="user:IsNonBlankText(string(./i:caption)) and (count(./i:params/i:param[@n='ShowTooltip'])!=0)">
			<xsl:value-of disable-output-escaping="yes" select="user:NBSP()"/>
			<IMG 
				SRC="Images\it-info-mini.gif" 
				STYLE="position:relative; width:14px; height:14px; margin:0px 0px -2px 0px; border:none; behavior:url(x-Tooltip.htc);"
				ToolTipWidth = "300"
				StyleSheet = "it-styles-tips-2.css"	
			>
				<xsl:attribute name="ID"><xsl:value-of select="concat('info_',$menuItemID)"/></xsl:attribute>
				<xsl:attribute name="TOOLTIPHTML">
					<xsl:value-of disable-output-escaping="yes" select="./i:caption"/>
				</xsl:attribute>
			</IMG>
		</xsl:if>
	</A>
	
	<!-- ...���� ��� ������ ���� ����� ���� ��������� (i:caption) � ��� ����
		 �������� ShowTooltip �� �����, �� ����� ��������� ��������� ������ 
		 ����� ����� �� ������� (��� ���� ������� �� �� ��������) -->
	<xsl:if test="user:IsNonBlankText(string(./i:caption)) and (count(./i:params/i:param[@n='ShowTooltip'])=0)">
		<xsl:for-each select="i:caption[user:IsNonBlankText(string(.))!='']">
		<DIV STYLE="font:normal 9px; color:#369; padding:0px 0px 5px 25px;">
			<xsl:value-of disable-output-escaping="yes" select="."/>
		</DIV>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
