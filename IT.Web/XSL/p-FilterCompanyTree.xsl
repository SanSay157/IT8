<?xml version="1.0" encoding="windows-1251"?>
<!-- 
********************************************************************************
********************************************************************************
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
	xmlns:d="urn:object-editor-access"
	xmlns:b = "urn:x-page-builder"
	xmlns:w = "urn:editor-window-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	>

<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>

<xsl:template match="FilterCompanyTree"> 
	<TABLE CELLSPACING="0" CELLPADDING="0" STYLE="width:100%; height:100%;">
	<TR>
		<TD>
			<xsl:for-each select="ShowArchive">
				<xsl:call-template name="std-template-bool" />
			</xsl:for-each>
		</TD>
	</TR>
	<TR>
		<TD>
		<TABLE CELLSPACING="2" CELLPADDING="0" CLASS="x-layoutgrid x-filter-layoutgrid" STYLE="width:100%; height:100%;">
		<TBODY>
			<TR>
				<TD class="x-editor-text x-editor-propcaption-notnull"><NOBR>Поиск сотрудника. Фамилия:</NOBR></TD>
				<TD width="30%">
					<INPUT 	
						ID="EmployeeSearch"
						TYPE="TEXT" DISABLED="0" VALUE="" 
						X_DISABLED = "0"
						X_DESCR = "Сотрудник"
						STYLE="width:100%;"
						CLASS="x-editor-control x-editor-string-field"
					/>
					<SCRIPT FOR="EmployeeSearch" LANGUAGE="VBScript" EVENT="onKeyUp">
						Internal_EmployeeSearch_onKeyUp
					</SCRIPT>
				</TD>
				<TD align="right">
					<BUTTON DISABLED="0"
						ID="EmployeeSearch_btnRunSearch" CLASS="x-button x-control-button"
						STYLE="width:100px; padding:0px 5px 1px 5px; border:#777 solid 1px; font:bold 9px; color:#393;"
					><CENTER>Поиск</CENTER></BUTTON>
				</TD>
				<TD align="right">
					<BUTTON DISABLED="0"
						ID="EmployeeSearch_btnSearchNext" CLASS="x-button x-control-button"
						STYLE="width:100px; padding:0px 5px 1px 5px; border:#777 solid 1px; font:bold 9px; color:#393;"
					><CENTER>Следующий</CENTER></BUTTON>
				</TD>
				<TD width="100%"><DIV id="EmployeeSeach_Results" style="width:100%"/></TD>
			</TR>
		</TBODY>
		</TABLE>
		<SCRIPT FOR="EmployeeSearch_btnRunSearch" LANGUAGE="VBScript" event="OnClick">
			Internal_OnbtnRunSearchClick
		</SCRIPT>
		<SCRIPT FOR="EmployeeSearch_btnSearchNext" LANGUAGE="VBScript" event="OnClick">
			Internal_OnbtnSearchNext
		</SCRIPT>
		</TD>
	</TR>
	</TABLE>
</xsl:template>

<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
<xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
