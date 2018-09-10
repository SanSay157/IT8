<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	Вторая страница для фильтра списка лотов ("Дополнительные параметры")
-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:XService="urn:x-client-service" 
	xmlns:q="urn:query-string-access" 
	xmlns:d="urn:object-editor-access" 
	xmlns:w="urn:editor-window-access" 
	xmlns:b="urn:x-page-builder" 
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
>

<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>

<xsl:template match="FilterLotsList">
<div style="position:relative; width:80%;">

	<table cellspacing="2" cellpadding="0" class="x-layoutgrid x-filter-layoutgrid">
		<col width="15%"/>
		<col width="40%"/>
		<!-- Колонка - вертикальный разделитель --><col width="5%" />
		<col width="5%"/>
		<col width="20%"/>
	<tbody>
		<tr>
			<td class="x-editor-text x-editor-propcaption"><nobr>Отрасль заказчика:</nobr></td>
			<td>
				<xsl:for-each select="CustomerBranch">
					<xsl:call-template name="std-template-object-dropdown" />
				</xsl:for-each>
			</td>
			
			<!-- Колонка - вертикальный разделитель --><td />
			
			<td class="x-editor-text x-editor-propcaption"><nobr>Документация:</nobr></td>
			<td>
				<xsl:for-each select="DocumentationType">
					<xsl:call-template name="std-template-selector">
						<xsl:with-param name="selector">combo</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</td>
		</tr>
		<tr>
			<td class="x-editor-text x-editor-propcaption"><nobr>Менеджер по лоту:</nobr></td>
			<td>
				<xsl:for-each select="LotManager">
					<xsl:call-template name="std-template-object-dropdown" />
				</xsl:for-each>
			</td>
			
			<!-- Колонка - вертикальный разделитель --><td />
			
			<td class="x-editor-text x-editor-propcaption"><nobr>Банковская гарантия:</nobr></td>
			<td>
				<xsl:for-each select="GuaranteeType">
					<xsl:call-template name="std-template-selector">
						<xsl:with-param name="selector">combo</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</td>
			
		</tr>
		<tr>
		
			<td class="x-editor-text x-editor-propcaption"><nobr>Конкурент:</nobr></td>
			<td>
				<xsl:for-each select="Competitor">
					<xsl:call-template name="std-template-object-presentation" />
				</xsl:for-each>
			</td>
			
			<!-- Колонка - вертикальный разделитель --><td />
			
			<td class="x-editor-text x-editor-propcaption"><nobr>Тип конкурента:</nobr></td>
			<td style="padding-bottom:5px;">
				<xsl:for-each select="CompetitorType">
					<xsl:call-template name="std-template-selector">
						<xsl:with-param name="selector">combo</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</td>

		</tr>
		<tr>
			<!-- Не указан менеджер по лоту -->
			<td colspan="5" style="padding-top:3px;">
				<xsl:for-each select="NoLotManager">
					<xsl:call-template name="std-template-bool">
						<xsl:with-param name="label">Отобразить те лоты, в описании которых не задан менеджер проекта</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</td>
		</tr>
	</tbody>
	</table>
	
</div>
</xsl:template>

<!-- Стандартный шаблон для отображения/модификации произвольных текстовых св-в -->
<xsl:include href="x-pe-string.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных св-в  даты и времени-->
<xsl:include href="x-pe-datetime.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
<xsl:include href="x-pe-object.xsl"/>
<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
<xsl:include href="x-pe-selector.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
<xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
