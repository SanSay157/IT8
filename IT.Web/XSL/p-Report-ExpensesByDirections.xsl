<?xml version="1.0" encoding="windows-1251"?>
<!-- 
********************************************************************************
	������� ������������ ���������� ��������� - Incident Tracker
	��� ���� �������������, 2005
********************************************************************************
	������ ������������ HTML-�������� ������� ������� ���������� ������
	"������� � ������� �����������"
********************************************************************************
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
	xmlns:b = "urn:x-page-builder"
	xmlns:w = "urn:editor-window-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	xmlns:user = "urn:offcache"
>
<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251" 
	omit-xml-declaration="yes" 
	media-type="text/html"/>
	
<xsl:template match="FilterReportExpensesByDirections">
<DIV ID="divPagePane" STYLE="visibility:hidden;">

	<!-- ���� ��� ������� ���������������� �������; ������������ ���������� ������ -->
	<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" STYLE="width:99%;">
	<TBODY>
		<TR>
			<TD CLASS="x-editor-text x-editor-propcaption"><NOBR>������ �������:</NOBR></TD>
			<TD STYLE="width:100%;"><xsl:call-template name="it-template-period-selector" /></TD>
		</TR>
		<TR><TD COLSPAN="2"><HR/></TD></TR>
	</TBODY>
	</TABLE>
	
	<!-- ���� ������ ����������� ������� � ����������, ��������� �� ����������� ������� -->
	<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" STYLE="width:99%;">
		<COL STYLE="width:25%; padding-right:5px;" />
		<COL STYLE="width:75%" />
	<TBODY>
		<TR>
			<TD CLASS="x-editor-text x-editor-propcaption"><NOBR><B>����������� �������:</B></NOBR></TD>
			<TD>
				<SELECT ID="selAnalysisType" CLASS="x-editor-control-notnull x-editor-const-selector" STYLE="width:100%;">
					<OPTION VALUE="ByCustomer" SELECTED="1">����������� - �����������</OPTION>
					<OPTION VALUE="ByActivity">���������� - �����������</OPTION>
				</SELECT>
			</TD>
		</TR>
		
		<!-- :: ������, ���������� ��� ����������� ������� "����������� - �����������" -->
		<xsl:for-each select="Organization">
		<TR>
			<TD ID="tdAnalysisDirByCustomer" COLSPAN="2" STYLE="width:100%; position:relative; padding-left:20px;">
			
				<LABEL 
					CLASS="x-editor-text x-editor-propcaption"
					STYLE="position:relative; left:5px; top:5px; z-index:9; background-color:#d4d0c8;"
				><B>����������-������</B></LABEL>
				<DIV STYLE="position:relative: top:-14px; width:100%; border:#a98 solid 1px; padding:8px 5px 5px 5px;">
				
				<TABLE CELLSPACING="0" CELLPADDING="2" STYLE="width:100%;">
				<TBODY>
					<TR>
						<TD COLSPAN="2" STYLE="vertical-align:top; padding-right:5px;" CLASS="x-editor-text x-editor-propcaption">
							<INPUT TYPE="radio" NAME="rdCustomersSelection" ID="rdCustomersSelectionAll" CHECKED="1"/>
							<LABEL FOR="rdCustomersSelectionAll" STYLE="position:relative; top:-2px;"><NOBR>��� �����������;</NOBR></LABEL>
						</TD>
					</TR>
					<TR>
						<TD STYLE="vertical-align:top; padding-right:5px;" CLASS="x-editor-text x-editor-propcaption">
							<INPUT TYPE="radio" NAME="rdCustomersSelection" ID="rdCustomersSelectionTarget" />
							<LABEL FOR="rdCustomersSelectionTarget" STYLE="position:relative; top:-2px;"><NOBR>�����������:</NOBR></LABEL>
						</TD>
						<TD STYLE="width:100%;">
							<xsl:call-template name="std-template-object-presentation">
								<xsl:with-param name="off-create">1</xsl:with-param>
								<xsl:with-param name="off-edit">1</xsl:with-param>
								<xsl:with-param name="off-delete">1</xsl:with-param>
								<xsl:with-param name="select-symbol">dots</xsl:with-param>
							</xsl:call-template>
						</TD>
					</TR>
					<TR>
						<TD COLSPAN="2" STYLE="padding-top:5px;">
							<TABLE CELLSPACING="0" CELLPADDING="1" STYLE="width:100%; border:#a98 solid 1px; border-width:1px 0px 0px 0px;">
								<xsl:for-each select="//FolderType">
								<TR>
									<TD STYLE="padding-right:5px;" CLASS="x-editor-text x-editor-propcaption">
										<NOBR><LABEL>�������� ������ �����������:</LABEL></NOBR>
									</TD>
									<TD STYLE="width:100%;">
										<xsl:call-template name="std-template-flags">
											<xsl:with-param name="horizontal-direction">1</xsl:with-param>
										</xsl:call-template>
									</TD>
								</TR>
								</xsl:for-each>
								<xsl:for-each select="//OnlyActiveFolders">
								<TR>
									<TD COLSPAN="2" CLASS="x-editor-text x-editor-propcaption">
										<xsl:call-template name="std-template-bool">
											<xsl:with-param name="label">�������� ������ ������ �������� ����������� (������� "�������" � "�������� ��������")</xsl:with-param>
										</xsl:call-template>
									</TD>
								</TR>
								</xsl:for-each>
							</TABLE>
						</TD>
					</TR>			
					
				</TBODY>					
				</TABLE>
				
				</DIV>
			</TD>
		</TR>
		</xsl:for-each>

		<!-- :: ������, ���������� ��� ����������� ������� "���������� - �����������" -->
		<xsl:for-each select="Folder">
		<TR>
			<TD ID="tdAnalysisDirByActivity" COLSPAN="2" STYLE="width:100%; position:relative; padding-left:20px;">
			
				<LABEL 
					CLASS="x-editor-text x-editor-propcaption"
					STYLE="position:relative; left:10px; top:5px; z-index:9; background-color:#d4d0c8;"
				><B>����������</B></LABEL>
				<DIV STYLE="position:relative: top:-14px; width:100%; border:#a98 solid 1px; padding:8px 5px 5px 5px;">
				
					<TABLE CELLSPACING="0" CELLPADDING="2" STYLE="width:100%;">
						<TR>
							<TD STYLE="width:100%;">
								<xsl:call-template name="std-template-object-presentation">
									<xsl:with-param name="off-create">1</xsl:with-param>
									<xsl:with-param name="off-edit">1</xsl:with-param>
									<xsl:with-param name="off-delete">1</xsl:with-param>
									<xsl:with-param name="select-symbol">dots</xsl:with-param>
								</xsl:call-template>
							</TD>
						</TR>
						<xsl:for-each select="//ShowHistoryInfo">
						<TR>
							<TD>
								<xsl:call-template name="std-template-bool">
									<xsl:with-param name="label">���������� ������ � ��������� ��������� ����������� �����������</xsl:with-param>
								</xsl:call-template>
							</TD>
						</TR>
						</xsl:for-each>
					</TABLE>
				
				</DIV>
				
			</TD>
		</TR>
		</xsl:for-each>
		
	</TBODY>
	</TABLE>
		
	<!-- ������, "�����" ���������: �����������, ���������� -->
	<TABLE BORDER="0" CELLSPACING="2" CELLPADDING="2" STYLE="width:99%;">
		<COL STYLE="width:10%; padding-right:5px;" />
		<COL STYLE="width:25%;" />
		<COL STYLE="width:20%; padding-right:5px;" />
		<COL STYLE="width:25%;" />
		<COL STYLE="width:15%;" />
	<TBODY>
		<TR><TD COLSPAN="5"><HR/></TD></TR>
		<TR>
			<TD CLASS="x-editor-text x-editor-propcaption">�����������:</TD>
			<TD>
				<SELECT ID="selDetalization" CLASS="x-editor-control-notnull x-editor-const-selector" STYLE="width:100%;">
					<OPTION VALUE="0" SELECTED="1">���</OPTION>
					<OPTION VALUE="1" ID="selDetalizationYes">�� ������������</OPTION>
				</SELECT>
			</TD>
			
			<TD CLASS="x-editor-text x-editor-propcaption" STYLE="padding-left:20px;">
				<NOBR>������������� �������:</NOBR>
			</TD>
			<TD>
				<xsl:for-each select="TimeMeasureUnits">
					<xsl:call-template name="std-template-selector">
						<xsl:with-param name="selector">combo</xsl:with-param>
						<xsl:with-param name="no-empty-value">1</xsl:with-param>
					</xsl:call-template>				
				</xsl:for-each>
			</TD>
			
			<TD/>
		</TR>
		<TR>
			<TD CLASS="x-editor-text x-editor-propcaption">����������:</TD>
			<TD>
				<xsl:for-each select="SortBy">
					<xsl:call-template name="std-template-selector">
						<xsl:with-param name="no-empty-value">1</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</TD>
			
			<TD CLASS="x-editor-text x-editor-propcaption" COLSPAN="3" STYLE="padding-left:20px;">
				<xsl:for-each select="ShowRestrictions">
					<xsl:call-template name="std-template-bool" />
				</xsl:for-each>
			</TD>
		</TR>
		
	</TBODY>
	</TABLE>

</DIV>
</xsl:template>

<!-- ������������������ ������ ��� �����������/����������� ������� ������� -->
<xsl:import href="it-period-selector.xsl"/>

<!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��������� ��-� -->
<xsl:include href="x-pe-object.xsl"/>
<!-- ����������� ������ ��� �����������/����������� �������� ��-�, �������������� ����� �� ������ �������� -->
<xsl:include href="x-pe-selector.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ������������ ���������� ��-� -->
<xsl:include href="x-pe-bool.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ������ ������ -->
<xsl:include href="x-pe-flags.xsl"/>

</xsl:stylesheet>
	