<?xml version="1.0" encoding="windows-1251"?>
<!-- ���� ����� ��� ����������� ������ �� XML-����� �������� ������ �������� -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">

<xsl:script language="VBScript">
	Option Explicit
	
	dim g_aColumns	' ������ �������� ��� �������������� ������
	
	'#####################################################################
	' ��������� ����� ���������� � ����� �������� � �������� ������
	' �������������� ���������� ������ g_aColumns ��������� ���� IXMLDOMElement
	'	 � ����������������� ��������� DataType
	' [in] oColumns - IXSLRuntime ������ - ���� CS ������
	function XslObtainTypes(oColumns)
		dim nCount		' ���-�� ��������
		dim oTempNode	' IXMLDOMElement, �������������� ������
		dim oTypeNode	' IXMLDOMNode,	��� ������ (�������� vt � �������)
		dim i
		
		'��������� �������� (XSL ������ ������ ���� ����� Empty)
		XslObtainTypes = 0
		
		nCount = oColumns.childNodes.length
		ReDim g_aColumns(nCount-1)
		
		set oTempNode =  CreateObject("MSXML2.DomDocument").createElement("x")
		oTempNode.text = vbNullString
		
		for i=0 to nCount - 1
			set g_aColumns(i) = oTempNode.cloneNode(true)
			set oTypeNode = oColumns.childNodes.item(i).selectSingleNode("@vt")
			if oTypeNode Is Nothing then
				g_aColumns(i).DataType = "string"
			else
				g_aColumns(i).DataType = oTypeNode.text
			end if
		next
	end function
	
	'#####################################################################
	' ������� �������������� �������� ����
	' [in] oField - IXSLRuntime, ���� F ������ ������ - �������� ����
	function XmlFormatValue(oField)
		dim sText	' ����� ����
		
		XmlFormatValue = vbNullString
		
		sText = oField.text
		if 0=len(sText) then exit function
		
		with g_aColumns(oField.childNumber(oField)-1)
			.text = sText
			XmlFormatValue = CStr( .nodeTypedValue)  
		end with
	end function
	
</xsl:script>


<xsl:template match="/" language="VBScript">
	<xsl:apply-templates select="LIST"/>
</xsl:template>	
	
<xsl:template match="LIST" language="VBScript">
	<HTML>
		<HEAD>
			<META http-equiv="Content-Type" content="text/html; charset=windows-1251"/>
			<!-- ������� ��������� ���� -->
			<TITLE>
				<xsl:choose>
					<xsl:when test="@title">
						<xsl:value-of select="@title"/>
					</xsl:when>
					<xsl:otherwise>
						������ �������� "<xsl:value-of select="@ot"/>"
					</xsl:otherwise>
				</xsl:choose>
			</TITLE>
			<!-- ������ �� CSS -->
			<LINK href="x-report.css" rel="STYLESHEET" type="text/css"/>
		</HEAD>
		<BODY CLASS="REPBODY">
			<CENTER>
				<TABLE	border="0" cellPadding="0" cellSpacing="0"><TR><TD>
				<TABLE	border="0" cellPadding="5" cellSpacing="1" CLASS="HTABLE" WIDTH="100%">
					<TR>
						<TD CLASS="TITLES" ALIGN="CENTER" VALIGN="MIDDLE">
							<xsl:choose>
								<xsl:when test="CAPTION">
									<xsl:for-each select="CAPTION">			
										<xsl:apply-templates match="*">
											<!-- recursively apply this template to them -->
											<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
										</xsl:apply-templates>					
									</xsl:for-each>
								</xsl:when>
								
								<xsl:when test="./@title">
									<xsl:for-each select="./@title">			
										<xsl:apply-templates match="*">
											<!-- recursively apply this template to them -->
											<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
										</xsl:apply-templates>					
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									������ �������� "<xsl:value-of select="./@ot"/>"
								</xsl:otherwise>
							</xsl:choose>
						</TD>
					</TR>
				</TABLE>
				<!-- ������ ������� - ����������� ����� ���������� � ������� -->
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
					<TR><TD WIDTH="100%"></TD></TR>
				</TABLE>
				<!-- ���������� ������� ������ -->
				<TABLE border="1" BorderColor="black" cellSpacing="0" style="border-collapse:collapse;" width="100%">
					<!-- �������� ������� -->
					<COLGROUP>
						<!-- ���������� ������� ������� � ������� -->
						<xsl:for-each select="CS">
							<xsl:comment>
								<xsl:eval language="VBScript">XslObtainTypes(me)</xsl:eval><BR/>
							</xsl:comment>	
							<!-- ������ ������� ��� ������� ����� -->
							<COL ALIGN="CENTER" WIDTH="50"></COL>
							<xsl:for-each select="C">
								<COL>
									<xsl:attribute name="ALIGN"><xsl:value-of select="@align"/></xsl:attribute>
									<xsl:attribute name="WIDTH"><xsl:value-of select="@width"/></xsl:attribute>
									<xsl:if test="./@hidden">
										<xsl:attribute name="STYLE">DISPLAY:NONE</xsl:attribute>
									</xsl:if>	
									<xsl:if test=".[@width='0']">
										<xsl:attribute name="STYLE">DISPLAY:NONE</xsl:attribute>
									</xsl:if>	
								</COL>
							</xsl:for-each>
						</xsl:for-each>
					</COLGROUP>
					
					<THEAD class="REPHEAD">
						<!-- ������ ��������� ������� -->
						<TR>
							<TD CLASS="LINENUMBER">�</TD>
							<!-- ��������������� ������� ��������� �������  -->
							<xsl:for-each select="CS/C">
							
								<TD ALIGN="CENTER" VALIGN="MIDDLE" CLASS="DEFAULT_HEADER_STYLE"><B><xsl:value-of select="."/></B></TD>
							</xsl:for-each>
						</TR>
					</THEAD>
					<!-- ��������� ���� ������ -->
					<TBODY class="REPBODY">
						<!-- ������ � ������� -->
						<xsl:apply-templates select="RS"/>
					</TBODY>	
				</TABLE>
				<!-- ������ ������� - ����������� ����� ���������� � ������� -->
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
					<TR><TD WIDTH="100%"></TD></TR>
				</TABLE>
				<!-- ������ ������ -->
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
					<TR>
						<TD>
							<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="1" WIDTH="100%" BGCOLOR="BLACK" STYLE="font:10pt;font-family:Arial">
								<TR>
									<TD CLASS="FOOTER" ALIGN="RIGHT">
										<FONT COLOR="BLACK">
											����� ��������� <xsl:eval>FormatDateTime( Now(), 1)</xsl:eval> � <xsl:eval>FormatDateTime( Now(), 4)</xsl:eval>
										</FONT>
									</TD>
								</TR>
							</TABLE>
						</TD>
					</TR>
				</TABLE>
				</TD></TR></TABLE>
			</CENTER>
		</BODY>
	</HTML>
</xsl:template>

<!-- ������ ������ ����� ������� -->
<xsl:template match="RS">
	<xsl:for-each select="R">
		<TR>
			<!-- ������ � ������� ������ -->
			<TD	class="LINENUMBER"><xsl:eval>formatIndex(childNumber(this), "1")</xsl:eval></TD>
			<xsl:for-each select="F">
				<TD class="DEFAULT_TABLE_STYLE">
					<xsl:eval language="VBScript">XmlFormatValue(me)</xsl:eval>
				</TD>
			</xsl:for-each>	
		</TR>
	</xsl:for-each>
</xsl:template>


<!-- ������ ������ ��-��������� -->
<xsl:template match="text()"><xsl:value-of /></xsl:template>
  
</xsl:stylesheet>
