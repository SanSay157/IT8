<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================


-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt">

<xsl:variable name="maybenull_0" select="'x-editor-text x-editor-propcaption-notnull'"/>
<xsl:variable name="maybenull_1" select="'x-editor-text x-editor-propcaption'"/>

<xsl:template name="it-template-incident-priority">
	<!-- метаданные свойства -->
	<xsl:variable name="md" select="b:GetPropMD(current())"/>
	<!-- описание свойства -->
	<xsl:variable name="d" select="string($md/@d)"/>
	<!-- признак нулабельного свойства -->
	<xsl:variable name="maybenull" select="string($md/@maybenull)"/>
	<td class="{w:iif('1'=$maybenull,$maybenull_1,$maybenull_0)}" nowrap="nowrap"><xsl:value-of select="$d"/>:</td>
	<td>
		<xsl:call-template name="std-template-selector">
			<xsl:with-param name="xml-prop-md" select="$md"/>
			<xsl:with-param name="description" select="$d"/>
			<xsl:with-param name="maybenull" select="$maybenull"/>
			<xsl:with-param name="selector" select="'horizontal-radio'"/>
		</xsl:call-template>
	</td>
</xsl:template>

<xsl:template name="it-template-incident-deadline">
	<!-- метаданные свойства -->
	<xsl:variable name="md" select="b:GetPropMD(current())"/>
	<!-- описание свойства -->
	<xsl:variable name="d" select="string($md/@d)"/>
	<!-- признак нулабельного свойства -->
	<xsl:variable name="maybenull" select="string($md/@maybenull)"/>
	<td  class="x-editor-text x-editor-propcaption" nowrap="nowrap"><xsl:value-of select="$d"/>:</td>
	<td>
		<xsl:call-template name="std-template-date">
			<xsl:with-param name="xml-prop-md" select="$md"/>
			<xsl:with-param name="description" select="$d"/>
			<xsl:with-param name="maybenull" select="$maybenull"/>
		</xsl:call-template>
	</td>
</xsl:template>


<xsl:template name="it-template-incident-props">
	<xsl:param name="props" select="*[0!=0]"/>
	<xsl:param name="incident-type-props" select="*[0!=0]"/>

	<xsl:variable name="maybenull_0" select="'x-editor-text x-editor-propcaption'"/>
	<xsl:variable name="maybenull_1" select="'x-editor-text x-editor-propcaption-notnull'"/>
				
	<!-- выведем дополнительные свойства инцидента -->
	<xsl:for-each select="$incident-type-props/*[string(IsArchive/text())='0']">
		<!-- описание свойства -->
		<xsl:variable name="propInfo" select="current()"/>
		<!-- идентификатор свойства -->
		<xsl:variable name="propInfoID" select="string(@oid)"/>
		<!-- описание свойства -->
		<xsl:variable name="d" select="$propInfo/Name"/>
		<!-- тип свойства -->
		<xsl:variable name="type" select="number($propInfo/Type)"/>
		<!-- признак нулабельного свойства -->
		<xsl:variable name="maybenull-temp">
			<xsl:choose>
				<xsl:when test="'1'=string($propInfo/IsMandatory/text())">0</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="maybenull" select="string($maybenull-temp)"/>
		
		<xsl:choose>
			<xsl:when test="'0'!=string($propInfo/IsArray/text())">
				<xsl:for-each select="$props">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
					<tr style="height:100px;">
						<td valign="top" class="{w:iif('1'=$maybenull,$maybenull_1,$maybenull_0)}" nowrap="nowrap"><xsl:value-of select="$d"/>:</td>
						<td>
							<xsl:call-template name="std-template-objects">
								<xsl:with-param name="description" select="$d"/>
								<xsl:with-param name="metaname" select="concat('array-of-', string($type) )"/>
								<xsl:with-param name="hide-if" select="concat('not(item.IncidentProp.ObjectID=&quot;', $propInfoID ,'&quot;)')"/>
							</xsl:call-template>
						</td>
					</tr>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$props/*[string(IncidentProp/*/@oid)=string($propInfoID)][1]">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
					<tr>
						<td class="{w:iif('1'=$maybenull,$maybenull_1,$maybenull_0)}" nowrap="nowrap"><xsl:value-of select="$d"/>:</td>
						<td>
							<!-- Отображаем в зависимости от типа -->
							<xsl:choose>
								<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_LONG()">
									<xsl:for-each select="NumericData">
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="$d"/>
											<xsl:with-param name="vt" select="'i4'"/>
											<xsl:with-param name="maybenull" select="$maybenull"/>
											<xsl:with-param name="min" select="$propInfo/MinDouble"/>
											<xsl:with-param name="max" select="$propInfo/MaxDouble"/>
										</xsl:call-template>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_DOUBLE()">
									<xsl:for-each select="NumericData">
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="$d"/>
											<xsl:with-param name="maybenull" select="$maybenull"/>
											<xsl:with-param name="min" select="$propInfo/MinDouble"/>
											<xsl:with-param name="max" select="$propInfo/MaxDouble"/>
										</xsl:call-template>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_STRING()">
									<xsl:for-each select="StringData">
										<xsl:call-template name="std-template-text">
											<xsl:with-param name="description" select="$d"/>
											<xsl:with-param name="maybenull" select="$maybenull"/>
											<xsl:with-param name="min" select="$propInfo/MinDouble"/>
											<xsl:with-param name="max" select="$propInfo/MaxDouble"/>
										</xsl:call-template>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_TEXT()">
									<xsl:for-each select="TextData">
										<xsl:call-template name="std-template-text">
											<xsl:with-param name="description" select="$d"/>
											<xsl:with-param name="maybenull" select="$maybenull"/>
											<xsl:with-param name="min" select="$propInfo/MinDouble"/>
											<xsl:with-param name="max" select="$propInfo/MaxDouble"/>
										</xsl:call-template>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_FILE()">
									<xsl:for-each select="FileData">
										<xsl:call-template name="std-template-file">
											<xsl:with-param name="description" select="$d"/>
											<xsl:with-param name="maybenull" select="$maybenull"/>
											<xsl:with-param name="file-name-in" select="'StringData'"/>
											<xsl:with-param name="max-file-size" select="$propInfo/MaxDouble"/>
											<xsl:with-param name="is-image"  select="'0'"/>
										</xsl:call-template>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_PICTURE()">
									<xsl:for-each select="FileData">
										<xsl:call-template name="std-template-file">
											<xsl:with-param name="description" select="$d"/>
											<xsl:with-param name="maybenull" select="$maybenull"/>
											<xsl:with-param name="file-name-in" select="'StringData'"/>
											<xsl:with-param name="max-file-size" select="$propInfo/MaxDouble"/>
											<xsl:with-param name="is-image"  select="'1'"/>
										</xsl:call-template>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_DATE()">
									<xsl:for-each select="DateData">
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="$d"/>
											<xsl:with-param name="maybenull" select="$maybenull"/>
											<xsl:with-param name="min" select="$propInfo/MinDate"/>
											<xsl:with-param name="max" select="$propInfo/MaxDate"/>
											<xsl:with-param name="vt" select="'date'"/>
										</xsl:call-template>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_TIME()">
									<xsl:for-each select="DateData">
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="$d"/>
											<xsl:with-param name="maybenull" select="$maybenull"/>
											<xsl:with-param name="min" select="$propInfo/MinDate"/>
											<xsl:with-param name="max" select="$propInfo/MaxDate"/>
											<xsl:with-param name="vt" select="'time'"/>
										</xsl:call-template>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_DATEANDTIME()">
									<xsl:for-each select="DateData">
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="$d"/>
											<xsl:with-param name="maybenull" select="$maybenull"/>
											<xsl:with-param name="min" select="$propInfo/MinDate"/>
											<xsl:with-param name="max" select="$propInfo/MaxDate"/>
											<xsl:with-param name="vt" select="'dateTime'"/>
										</xsl:call-template>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_BOOLEAN()">
									<xsl:for-each select="NumericData">
										<xsl:call-template name="std-template-selector">
											<xsl:with-param name="description" select="$d"/>
											<xsl:with-param name="maybenull" select="$maybenull"/>
										</xsl:call-template>
									</xsl:for-each>	
								</xsl:when>
							</xsl:choose>
						</td>
					</tr>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>


<!-- Стандартный шаблон для отображения/модификации произвольных двоичных св-в -->
<xsl:include href="x-pe-file.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных текстовых св-в -->
<xsl:include href="x-pe-string.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных числовых св-в -->
<xsl:include href="x-pe-number.xsl"/>
<!-- Стандартный шаблон для отображения/модификации двоичных флагов св-в -->
<xsl:include href="x-pe-flags.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных св-в  даты и времени-->
<xsl:include href="x-pe-datetime.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных массивных объектных св-в -->
<xsl:include href="x-pe-objects.xsl"/>
<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
<xsl:include href="x-pe-selector.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
<xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
