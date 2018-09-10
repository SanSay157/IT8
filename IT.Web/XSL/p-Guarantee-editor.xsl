<?xml version="1.0" encoding="windows-1251"?>
<!--
	===========================================================================
	Страница редактора объекта "Банковская гарантия"
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt">

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>
	
<xsl:template match="Guarantee">
	<table border="0" cellspacing="2" cellpadding="0" width="100%">
		<col width="35%" />
		<col width="65%" />
		<tr>
			<td class="x-editor-text x-editor-propcaption">Сумма:</td>
			<!-- Сумма -->
			<td>
				<xsl:for-each select="GuaranteeSum">
					<xsl:call-template name="tms-template-sum">
						<xsl:with-param name="select-symbol">dots</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</td>
		</tr>
		<tr>
			<td class="x-editor-text x-editor-propcaption">Доля банковской гарантии, %:</td>
			<!-- Доля банковской гарантии -->
			<td>
				<xsl:for-each select="PortionValue">
					<xsl:call-template name="std-template-number">
					</xsl:call-template>
				</xsl:for-each>
			</td>
		</tr>
		<tr><td colspan="2"><hr/></td></tr>
		<tr>
			<td class="x-editor-text x-editor-propcaption">Срок действия:</td>
			<!-- Срок действия -->
			<td>
				<xsl:for-each select="ValidityPeriod">
					<xsl:call-template name="std-template-number">
					</xsl:call-template>
				</xsl:for-each>
			</td>
		</tr>
		<tr>
			<td class="x-editor-text x-editor-propcaption">Дата окончания действия:</td>
			<!-- Дата окончания действия -->
			<td>
				<xsl:for-each select="EndingDate">
					<xsl:call-template name="std-template-date">
					</xsl:call-template>
				</xsl:for-each>
			</td>
		</tr>
		<tr><td colspan="2"><hr/></td></tr>
		<tr>
			<td class="x-editor-text x-editor-propcaption">Примечание:</td>
			<!-- Примечание -->
			<td>
				<xsl:for-each select="Note">
					<xsl:call-template name="std-template-text">
						<xsl:with-param name="minheight">60</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</td>
		</tr>
	</table>
</xsl:template>

<!-- Шаблон для отображения/модификации скалярного объектного свойства типа "Сумма" -->
<xsl:include href="tms-pe-object-sum.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных текстовых св-в -->
<xsl:include href="x-pe-string.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных числовых св-в -->
<xsl:include href="x-pe-number.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных св-в  даты и времени-->
<xsl:include href="x-pe-datetime.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
<xsl:include href="x-pe-object.xsl"/>
<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
<xsl:include href="x-pe-selector.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
<xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
