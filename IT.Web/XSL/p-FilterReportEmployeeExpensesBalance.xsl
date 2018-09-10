<?xml version="1.0" encoding="windows-1251"?>
<!-- 
********************************************************************************
	Система оперативного управления проектами - Incident Tracker
	ЗАО КРОК инкорпорейтед, 2005
********************************************************************************
	Шаблон формирования HTML-страницы диалога задания параметров отчета
	"Баланс списаний сотрудника"
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
	
<xsl:template match="FilterReportEmployeeExpensesBalance">

	<TABLE BORDER="0" CELLSPACING="2" CELLPADDING="0" WIDTH="99%">
		<COL WIDTH="30%"/>
		<COL WIDTH="70%"/>
	<TBODY>
	
		<xsl:for-each select="Employee">
		<TR>
			<TD CLASS="x-editor-text x-editor-propcaption">Для сотрудника:</TD>
			<TD>
				<xsl:call-template name="std-template-object-presentation">
					<xsl:with-param name="use-tree-selector">AnyEmployees</xsl:with-param>
					<xsl:with-param name="off-create">1</xsl:with-param>
					<xsl:with-param name="off-edit">1</xsl:with-param>
					<xsl:with-param name="off-delete">1</xsl:with-param>
					<xsl:with-param name="select-symbol">dots</xsl:with-param>
				</xsl:call-template>
			</TD>
		</TR>
		</xsl:for-each>
		
		<TR>
			<TD CLASS="x-editor-text x-editor-propcaption">Период времени:</TD>
			<TD>
				<xsl:call-template name="it-template-period-selector" />
			</TD>
		</TR>
		
		<xsl:for-each select="ShowFreeWeekends">
		<TR>
			<TD COLSPAN="2" CLASS="x-editor-text x-editor-propcaption">
				<xsl:call-template name="std-template-bool">
					<xsl:with-param name="label">Отображать строки без списаний, соответствующие выходным дням</xsl:with-param>
				</xsl:call-template>
			</TD>
		</TR>
		</xsl:for-each>
		
		<TR><TD COLSPAN="2"><HR/></TD></TR>
	</TBODY>
	</TABLE>
	
	<TABLE BORDER="0" CELLSPACING="2" CELLPADDING="0" WIDTH="99%">
		<COL WIDTH="30%"/>
		<COL WIDTH="70%"/>
	<TBODY>
		<xsl:for-each select="TimeMeasureUnits">
		<TD CLASS="x-editor-text x-editor-propcaption"><NOBR>Единицы измерения времени:</NOBR></TD>
		<TD>
			<xsl:call-template name="std-template-selector">
				<xsl:with-param name="selector">combo</xsl:with-param>
			</xsl:call-template>
		</TD>
		</xsl:for-each>
		
		<xsl:for-each select="ShowRestrictions">
		<TR>
			<TD COLSPAN="2" CLASS="x-editor-text x-editor-propcaption">
				<xsl:call-template name="std-template-bool">
					<xsl:with-param name="label">Включить в отчет отображение заданных праметров</xsl:with-param>
				</xsl:call-template>
			</TD>
		</TR>
		</xsl:for-each>
	</TBODY>
	</TABLE>	
</xsl:template>	

<!-- Специализированный шаблон для отображения/модификации периода времени -->
<xsl:import href="it-period-selector.xsl"/>

<!-- Стандартный шаблон для отображения/модификации произвольных текстовых св-в -->
<xsl:include href="x-pe-string.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных св-в даты и времени-->
<xsl:include href="x-pe-datetime.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
<xsl:include href="x-pe-object.xsl"/>
<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
<xsl:include href="x-pe-selector.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
<xsl:include href="x-pe-bool.xsl"/>
	
</xsl:stylesheet>	

