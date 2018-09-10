<?xml version="1.0" encoding="windows-1251"?>
<!-- 
********************************************************************************
	Система оперативного управления проектами - Incident Tracker
	ЗАО КРОК инкорпорейтед, 2005
********************************************************************************
	Шаблон формирования HTML-страницы диалога задания параметров отчета
	"Затраты в разрезе направлений"; вторая страница - "Настройки представления"
********************************************************************************
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
	xmlns:b = "urn:x-page-builder"
	xmlns:w = "urn:editor-window-access"
	xmlns:d = "urn:object-editor-access"
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

	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" STYLE="width:100%; position:relative;">
	<TR>
		<!-- Левая половина -->
		<TD STYLE="width:45%; padding:3px; vertical-align:top;">
		
			<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" STYLE="width:100%;">
				<xsl:for-each select="ShownColumns">
				<TR CLASS="x-editor-text x-editor-propcaption">
					<TD ID="tdShownColumns"><DIV>Отображаемые колонки:</DIV></TD>
				</TR>
				<TR CLASS="x-editor-text">
					<TD STYLE="padding-left:10px;">
						<xsl:call-template name="std-template-flags">
							<xsl:with-param name="horizontal-direction">0</xsl:with-param>
						</xsl:call-template>
					</TD>
				</TR>
				</xsl:for-each>
			</TABLE>
		
		</TD>
		
		<!-- Вертикальный разделитель -->
		<TD STYLE="position:relative; width:0px; overflow:hidden; border:#fff inset 1px;">
			<DIV STYLE="position:relative; width:0px; overflow:hidden;"></DIV>
		</TD>
		
		<!-- Правая половина -->
		<TD STYLE="width:55%; padding:3px; vertical-align:top;">
		
			<TABLE BORDER="0" CELLSPACING="2" CELLPADDING="0" STYLE="width:100%;">
			
			<xsl:for-each select="DataFormat">
			<TR>
				<TD CLASS="x-editor-text x-editor-propcaption" ID="tdDataFormat">
					<DIV><NOBR>Представление данных:</NOBR></DIV>
				</TD>
				<TD CLASS="x-editor-text">
					<xsl:call-template name="std-template-selector">
						<xsl:with-param name="selector">combo</xsl:with-param>
						<xsl:with-param name="no-empty-value">1</xsl:with-param>
					</xsl:call-template>
				</TD>
			</TR>
			</xsl:for-each>
			
			<TR>
				<TD CLASS="x-editor-text x-editor-propcaption" ID="tdPercentBase">
					<DIV><NOBR>За 100% брать:</NOBR></DIV>
				</TD>
				<TD CLASS="x-editor-text">
					<SELECT 
						ID="selPercentBase" 
						CLASS="x-editor-control-notnull x-editor-dropdown"
						LANGUAGE="VBScript"
						ONCHANGE="selPercentBase_OnChanged"
					>
						<OPTION VALUE="0">Сумму затрат по строке</OPTION>
						<OPTION VALUE="1">Сумму затрат по колонке</OPTION>
					</SELECT>
				</TD>
			</TR>
			
			<xsl:for-each select="TimeMeasureUnits">
			<TR>
				<TD CLASS="x-editor-text x-editor-propcaption" ID="tdTimeMeasure">
					<DIV><NOBR>Представление времени:</NOBR></DIV>
				</TD>
				<TD CLASS="x-editor-text">
					<xsl:call-template name="std-template-selector">
						<xsl:with-param name="selector">combo</xsl:with-param>
						<xsl:with-param name="no-empty-value">1</xsl:with-param>
					</xsl:call-template>
				</TD>
			</TR>
			</xsl:for-each>
			
			<xsl:for-each select="PassRedundant">
			<TR>
				<TD CLASS="x-editor-text x-editor-propcaption" COLSPAN="2">
					<xsl:call-template name="std-template-bool">
						<xsl:with-param name="description">Исключить данные уволенных сотрудников</xsl:with-param>
					</xsl:call-template>
				</TD>
			</TR>
			</xsl:for-each>

			<xsl:for-each select="PassDisabled">
					<TR>
						<TD CLASS="x-editor-text x-editor-propcaption" COLSPAN="2">
							<xsl:call-template name="std-template-bool">
								<xsl:with-param name="description">Исключить данные нетрудоспособных сотрудников</xsl:with-param>
							</xsl:call-template>
						</TD>
					</TR>
			</xsl:for-each>	
			</TABLE>
		
		</TD>
	</TR>
	
	<TR><TD COLSPAN="3"><HR/></TD></TR>
	<TR>
		<TD ID="tdActivityTypesAsExternalBlock" COLSPAN="3">
			<DIV CLASS="x-editor-text x-editor-propcaption">
				Виды проектных активностей, затраты которых будут рассматриваться как "внешние" 
				затраты (соответственно, все остальные затраты будут приняты как "внутренние"):
			</DIV>
			<DIV STYLE="position:relative; width:100%; padding:3px 3px 0px 15px;">
				<xsl:for-each select="ActivityTypesAsExternal">
					<xsl:call-template name="std-template-objects-selector">
						<xsl:with-param name="list-metaname">ExternalActivityTypes</xsl:with-param>
						<xsl:with-param name="height">100</xsl:with-param>
						<xsl:with-param name="off-operations">1</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</DIV>
			<DIV CLASS="x-editor-text" STYLE="padding:0px 5px 0px 15px; font-size:10px; text-align:right;">
				(Необходимо выбрать хотя бы один вид проектных активностей)
			</DIV>
		</TD>
	</TR>
	</TABLE>
	
	<TABLE BORDER="0" CELLSPACING="2" CELLPADDING="0" STYLE="width:100%;">
	<COL STYLE="width:10%; padding-right:5px;" />
	<COL STYLE="width:90%;"/>
	<TBODY>
		<TR><TD COLSPAN="2"><HR/></TD></TR>
		
		<!-- Определение сортировки -->
		<xsl:for-each select="SortingMode">
		<TR>
			<TD CLASS="x-editor-text x-editor-propcaption">Сортировка:</TD>
			<TD CLASS="x-editor-text">
				<xsl:call-template name="std-template-selector">
					<xsl:with-param name="selector">combo</xsl:with-param>
					<xsl:with-param name="no-empty-value">1</xsl:with-param>
				</xsl:call-template>
			</TD>
		</TR>			
		</xsl:for-each>
		
		<!-- Группировка по подразделению -->
		<xsl:for-each select="DoGroup">
		<TR>
			<TD COLSPAN="2">
				<xsl:call-template name="std-template-bool">
					<xsl:with-param name="description">Группировать данные по подразделениям</xsl:with-param>
				</xsl:call-template>
			</TD>
		</TR>
		</xsl:for-each>
	
		<!-- Включать заданные условия поиска в отчет -->
		<xsl:for-each select="ShowRestrictions">
		<TR>
			<TD COLSPAN="2">
				<xsl:call-template name="std-template-bool" />
			</TD>
		</TR>
		</xsl:for-each>
	</TBODY>		
	</TABLE>
	
</DIV>

</xsl:template>  

<!-- Стандартный шаблон для отображения/модификации массивный объектных свйоств, как списка с флагами -->
<xsl:include href="x-pe-objects-selector.xsl"/>

<!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
<xsl:include href="x-pe-object.xsl"/>
<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
<xsl:include href="x-pe-selector.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
<xsl:include href="x-pe-bool.xsl"/>
<!-- Стандартный шаблон для отображения/модификации набора флагов -->
<xsl:include href="x-pe-flags.xsl"/>

</xsl:stylesheet>