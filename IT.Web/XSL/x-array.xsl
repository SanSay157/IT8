<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	����������� �������� ��������� �������� ���������/������� ��� �����������/����������� ����������
	���������� ��������						
	������� ��������� ���a����:																	
	���������, ����������� ����� ������ �������:
		PN				- XPath-������, ������������ ��������� ��������, 
							���������� ��������� 
							(� ���������� ������ ��������� � ������ ��-��).

							��������! ���� PN �� ������ - ������������ 
							����������, ���� ��� ����� ����	�������������� 
							��� ���������� x-self-check.asp

		METANAME		- ������������ ��������, ��� i:elements-list � ����������
		DESCRIPTION		- ������������ ��������, �������� ��������
		OFF-DESCRIPTION - ������� �������� ������ � ��������� ��������
		PROP-NOT-FOUND	- ��������� � ��� ��� XPath-������ PN ������ �� ������
		NODE-TEST-QUERY	- �������������� XPath-������ ��� �������� ������� ������������ 
							����������� ��������. ���� � ���������� NODE-TEST-QUERY ��� ���������
							���� �� �������� ������� ��������� ��������� ��������, �����
							����� �������� ��������� NODE-TEST-FAILED. 
		NODE-TEST-FAILED- ���������, ��������� � ������ ����������� ���������� NODE-TEST-QUERY
							
				
	�������������� �������:																		
		������ X-Storage										
	��������� �������������:
		HTML - ���, ���������� ��������� ��� �� �����������/����������� ����������
		���������� ��������
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:nav="urn:xml-object-navigator-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt">

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>
	
<!-- ������� ������� ��������� �������� -->
	
<!-- XPath-������, ������������ ������������ ��������� ��-�� -->
<xsl:variable name="x-path-query" select="q:GetValue('PN','')"/>
<!-- ������� ������  ��� ����������� ���������� �������� -->
<xsl:variable name="elements-list-metaname" select="q:GetValue('METANAME','')"/>
<!-- ������� �������� �������� -->
<xsl:variable name="off-description" select="q:GetValue('OFF-DESCRIPTION','')"/>
<!-- ��������� � ������ �������� -->
<xsl:variable name="prop-not-found" select="q:GetValue('PROP-NOT-FOUND','� ������� ������� ��� ������ ��������.')"/>
<!-- ������ ��� �������� -->
<xsl:variable name="node-test-query" select="q:GetValue('NODE-TEST-QUERY','')"/>
<!-- ��� �������� ����� -->
<xsl:variable name="node-test-failed" select="q:GetValue('NODE-TEST-FAILED','� ������� ������� ��� �������� �����������.')"/>

<!-- ��������������� ������ ����������� ���������� �������� -->
<xsl:template name="internal-show-array">
	<!-- � ���������� ������� ��������� �������� - ��������� ��� �� ��� �������� -->
	<xsl:choose>
		<!-- ������������� ��� ����, �������� XPath ������ ����������-->
		<xsl:when test="0!=number(nav:SelectScalar($x-path-query))">
			<!-- ������� ��� ������� ������� ������ html-id ���� �������� -->
			<xsl:variable name="html-id" select="nav:SelectScalar(concat('generate-id(',$x-path-query,')'))"/>
			<TABLE BORDER="0" CELLSPACING="1" WIDTH="100%" HEIGHT="100%">
				<TBODY>
					<!-- ����� � ������� ��-�� � ���������� html-id -->
					<xsl:for-each select=".//*">
						<xsl:variable name="this-id" select="generate-id()"/>
						<xsl:if test="$this-id=$html-id">
							<!-- �������� �������� -->
							<xsl:variable name="description" select="q:GetValue('DESCRIPTION',b:MDQueryProp( current(), '@d'))"/>
							<xsl:if test="''=$off-description">
								<tr height="1">
									<td class="x-editor-text x-editor-propcaption"><xsl:value-of select="$description"/>:</td>
								</tr>
							</xsl:if>		
							<tr>
								<td>
									<xsl:call-template name="std-template-objects">
										<xsl:with-param name="metaname" select="$elements-list-metaname"/>
										<xsl:with-param name="description" select="$description"/>
									</xsl:call-template>	
								</td>		
							</tr>
						</xsl:if>	
					</xsl:for-each>
				</TBODY>
			</TABLE>
		</xsl:when>
		<xsl:otherwise>
			<TABLE BORDER="0" CELLSPACING="1" WIDTH="100%" HEIGHT="100%">
			<TR><TD VALIGN="MIDDLE" ALIGN="CENTER">
			<DIV class="x-editor-array-noprop">
				<xsl:value-of select="$prop-not-found"/>
			</DIV>
			</TD></TR>
			</TABLE>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- �������� ������ -->
<xsl:template match="*">
	<xsl:choose>
		<!-- �������� �� ������ - ����������� ���������� -->
		<xsl:when test="''=$x-path-query">
			<xsl:message terminate="yes">��������: ��� ������ �������� (X-ARRAY.XSL) �� ������ ������������ �������� &quot;PN&quot; (��� ���������� �������� ��� �����������)</xsl:message>
		</xsl:when>
		<xsl:otherwise>
			<CENTER>
			<!-- �������� ���� ��������� ������� ������-�� ���� -->
			<xsl:choose>
				<xsl:when test="''=$node-test-query">
					<!-- ������� ���� ������ �������� -->
					<xsl:call-template name="internal-show-array"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- �������� �������� -->
					<xsl:choose>
						<xsl:when test="0!=number(nav:SelectScalar($node-test-query))">
							<!-- ������� -->
							<xsl:call-template name="internal-show-array"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- ���������� -->
							<TABLE BORDER="0" CELLSPACING="1" WIDTH="100%" HEIGHT="100%">
							<TR><TD VALIGN="MIDDLE" ALIGN="CENTER">
							<DIV class="x-editor-array-testfailed">
								<xsl:value-of select="$node-test-failed"/>
							</DIV>
							</TD></TR>
							</TABLE>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			</CENTER>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��������� ��-� -->
<xsl:include href="x-pe-objects.xsl"/>

</xsl:stylesheet>
