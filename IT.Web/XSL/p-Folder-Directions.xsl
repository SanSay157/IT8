<?xml version="1.0" encoding="windows-1251"?>
<!--
================================================================================
 Редактор папки (активности / каталога)
 Страница "Направления"
================================================================================
-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:user="urn:это_нужно_для_блока_msxsl:script"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"
	user:off-cache="1"
>

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>

<xsl:template match="Folder">
	<xsl:variable name="Isdisabled" select="number(b:nvl(string(FolderDirections/@read-only),'0'))"/>
	<TABLE CELLPADDING="1" CELLSPACING="0" STYLE="width:100%; height:100%;">
	
		<xsl:if test="not(w:CanUseDirectionSet())">
		<TR>
			<TD ID="tdDirectionsList" STYLE="width:100%; height:100%;">
				<xsl:for-each select="FolderDirections">
					<xsl:call-template name="std-template-objects">
						<xsl:with-param name="disabled" select="$Isdisabled" />
					</xsl:call-template>
				</xsl:for-each>
			</TD>
		</TR>
		</xsl:if>
		
		<xsl:if test="w:CanUseDirectionSet()">
		<TR>
			<TD CLASS="x-editor-text" STYLE="width:100%; height:100%;">
			
				<DIV ID="divLockDirectionWarningText" STYLE="position:relative; width:100%; height:100%; color:#DD3322; border:#DD3322 solid 2px; background:#FFCCBB; padding:5px; display:none;">
					<DIV STYLE="font:bold 14px;">Внимание! Обнаружено некорректные определение направлений</DIV>
					<DIV STYLE="padding-left:20px; padding-top:5px;">
						Для редактируемой папки задано <B>более одного</B> направления. Это 
						противоречит определению направлений, заданных для вышестоящей папки: 
						в этом случае для редактируемой папки может быть указано только одно 
						направление, из числа тех, что заданы для вышестоящей папки. Такие 
						данные могут быть получены в результате переподчинения активности.<BR/>
						<BR/>
						Для корректного определения направления необходимо удалить все
						некорректные определения направлений, заданных для этой папки, и 
						назначить одно направление – из числа тех, что указаны для вышестоящей 
						папки.<BR/>
						<BR/>
						Для удаления некорректных определений направлений откройте редактор 
						данной папки снова, перейдите на страницу "Направления", и подтвердите
						удаление определений направлений, предложенное системой.
					</DIV>
				</DIV>
				
				<DIV ID="divSingleDirection" STYLE="position:relative; width:100%; height:100%; display:none;">
					<xsl:variable name="currFolder" select="." />
					<xsl:for-each select="w:GetSingleDirection( $currFolder )" >
						<xsl:call-template name="std-template-object-list-selector">
							<xsl:with-param name="list-metaname">SpecialSelectorList</xsl:with-param>
							<xsl:with-param name="maybenull">1</xsl:with-param>
							<xsl:with-param name="disabled" select="$Isdisabled" />
						</xsl:call-template>
					</xsl:for-each>
				</DIV>
			
			</TD>
		</TR>
		</xsl:if>

		<TFOOTER>
		<TR>
			<!-- Информационная часть: отображение данных по истории, предупреждений -->
			<TD ID="tdInfo" STYLE="padding:10px 0px 15px 0px;">
			
				<TABLE CELLPADDING="0" CELLSPACING="0" STYLE="width:100%; height:100%;">
				<TR>
					<!-- Историческая информация -->
					<TD CLASS="x-editor-text x-editor-propcaption" STYLE="vertical-align:top;"><NOBR>Последние изменения:</NOBR></TD>
					<TD CLASS="x-editor-text" STYLE="width:100%; vertical-align:top; font-weight:bold;">
						<xsl:value-of disable-output-escaping="yes" select="w:GetDirectionsHisoryInfo()"/>
					</TD>
				</TR>
				<TR>
					<!-- Предупреждения -->
					<TD></TD>
					<TD CLASS="x-editor-text" STYLE="width:100%; vertical-align:top; color:#DD3322;">
						<DIV ID="divStructWarningText" STYLE="padding-top:3px;"><xsl:value-of disable-output-escaping="yes" select="w:GetDirectionStructError()"/></DIV>
						<DIV ID="divPercentWarningText" STYLE="padding-top:3px; display:none;">
							<B>Внимание!</B><BR/>
							Сумма долей затрат, заданных для указанных направлений не равна 100%! 
							Такое определение долей является некорректным, и не может быть записано!
						</DIV>
					</TD>
				</TR>
				</TABLE>
				
			</TD>
		</TR>
		</TFOOTER>
		
	</TABLE>

</xsl:template>  

<xsl:include href="x-pe-objects.xsl" />
<xsl:include href="x-pe-object.xsl" />
<xsl:include href="x-pe-object-list-selector.xsl" />

</xsl:stylesheet>
