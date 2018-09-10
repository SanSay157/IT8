<?xml version="1.0" encoding="windows-1251"?>
<!-- 
********************************************************************************
	Система оперативного управления проектами - Incident Tracker
	ЗАО КРОК инкорпорейтед, 2005-2006
********************************************************************************
	Шаблон формирования HTML-страницы диалога задания параметров отчета
	"Структура затрат подразделения"; первая страница - "Основные параметры"
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
	
<xsl:template match="FilterReportDepartmentExpensesStructure">
<DIV ID="divPagePane" STYLE="visibility:hidden; padding:5px 0px 0px 0px;">

	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" STYLE="width:100%;">
	<COL STYLE="width:5%;"/>
	<COL STYLE=""/>
	<COL STYLE="width:95%;"/>
	<TBODY>
		<!-- Выбор формы отчета -->
		<TR>
			<TD CLASS="x-editor-text x-editor-propcaption"><NOBR><B>Форма отчета:</B></NOBR></TD>
			<TD COLSPAN="2">
				<xsl:for-each select="ReportForm">
					<xsl:call-template name="std-template-selector">
						<xsl:with-param name="selector">combo</xsl:with-param>
						<xsl:with-param name="no-empty-value">1</xsl:with-param>
					</xsl:call-template>				
				</xsl:for-each>
			</TD>
		</TR>
		<TR>
			<TD></TD>
			<TD CLASS="x-editor-text" STYLE="vertical-align:top; padding:3px 3px 0px 0px;"><IMG SRC="Images/it-info-mini.gif"/></TD>
			<TD CLASS="x-editor-text" STYLE="vertical-align:top; padding:3px 0px 0px 0px; position:relative;">
				<DIV ID="divHlpOpt" STYLE="position:relative; height:3em; font-size:10px; overflow:hidden;">
					<SPAN ID="sHlpOpt_0" STYLE="display:none;">
						В строках выводятся затраты времени по <B>подразделениям</B>, как 
						сумма затрат времени сотрудников этих подразделений.</SPAN>
					<SPAN ID="sHlpOpt_1" STYLE="display:none;">
						В строках выводятся затраты времени для <B>каждого сотрудника</B>,
						входящего в выбранные подразделения.</SPAN>
					<SPAN ID="sHlpOpt_2" STYLE="display:none;">
						В строках выводятся затраты времени для <B>каждого сотрудника</B>,
						а так же суммарные данные <B>по заданиям</B> этого сотудника.</SPAN>
				</DIV>
			</TD>
		</TR>
		<TR><TD COLSPAN="3"><HR/></TD></TR>
	
		<!-- Поля для задания рассматриваемого периода; используется внутренний шаблон -->
		<TR>
			<TD CLASS="x-editor-text x-editor-propcaption"><NOBR>Период времени:</NOBR></TD>
			<TD COLSPAN="2" STYLE="width:100%;">
				<xsl:call-template name="it-template-period-selector" />
			</TD>
		</TR>
		<TR><TD COLSPAN="3"><HR/></TD></TR>
	</TBODY>
	</TABLE>
	
	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" STYLE="width:100%;">
	<TBODY>
		<TR>
			<TD CLASS="x-editor-text x-editor-propcaption">Анализируемые данные:</TD>
		</TR>
		<TR>
			<TD STYLE="padding:3px 3px 0px 15px; vertical-align:top;">
				<!-- Поле Departments здесь как опорное, для корректного вызова XSLT-шаблона
					Полный перечень полей объекта, с которым работает эта PE, задается 
					в качестве значения параметра prop-names: 
				-->
				<xsl:for-each select="Departments">
					<xsl:call-template name="it-template-any-type-objects-tree-selector">
						<xsl:with-param name="height">190</xsl:with-param>
						<!-- Блокируем кнопки "Развернуть все" и "Свернуть все" -->
						<xsl:with-param name="off-expand-all">1</xsl:with-param>
						<xsl:with-param name="off-collapse-all">1</xsl:with-param>
						<!-- Массивные поля, заполняемые при выборе узлов соотв. типв в объекте: -->
						<xsl:with-param name="prop-names">Organizations Departments</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</TD>
		</TR>
		<TR>			
			<TD STYLE="padding:3px 3px 0px 15px; vertical-align:top;">
				<xsl:for-each select="AnalysisDepth">
					<xsl:call-template name="std-template-selector">
						<xsl:with-param name="selector">combo</xsl:with-param>
						<xsl:with-param name="no-empty-value">1</xsl:with-param>
					</xsl:call-template>				
				</xsl:for-each>
			</TD>
		</TR>
	</TBODY>
	</TABLE>
	
</DIV>
</xsl:template>

<!-- Специализированный шаблон для отображения/модификации периода времени -->
<xsl:import href="it-period-selector.xsl"/>

<!-- Специализированный шаблон для отображения/модификации НЕСКОЛЬКИХ массивных объектных св-в, в виде дерева с флагам -->
<xsl:include href="it-pe-any-type-objects-tree-selector.xsl"/>

<!-- Стандартный шаблон для работы с массивными объектными свойствами, в виде дерева с флагам -->
<xsl:include href="x-pe-objects-tree-selector.xsl"/>
<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
<xsl:include href="x-pe-selector.xsl"/>

</xsl:stylesheet>
