<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	Стандартная страница генерации закладки редактора/мастера для отображения/модификации массивного
	объектного свойства						
	Входные параметры стрaницы:																	
	Аргументы, принимаемые через строку запроса:
		PN				- XPath-запрос, возвращающий массивное свойство, 
							подлежашее обработке 
							(в простейшем случае совпадает с именем св-ва).

							Внимание! Если PN не указан - генерируется 
							исключение, дабы его можно было	сдетектировать 
							при выполнении x-self-check.asp

		METANAME		- опциональный аргумент, имя i:elements-list в метаданных
		DESCRIPTION		- опциональный аргумент, описание свойства
		OFF-DESCRIPTION - признак сокрытия ячейки с описанием свойства
		PROP-NOT-FOUND	- сообщение о том что XPath-запрос PN ничего не вернул
		NODE-TEST-QUERY	- Дополнительный XPath-запрос для проверки условия допустимости 
							отображения свойства. Если в результате NODE-TEST-QUERY был возвращен
							узел то страница выведет массивное объектное свойство, иначе
							будет выведено сообщение NODE-TEST-FAILED. 
		NODE-TEST-FAILED- Сообщение, выводимое в случае неуспешного выполнения NODE-TEST-QUERY
							
				
	Обрабатываемый элемент:																		
		Объект X-Storage										
	Результат трансформации:
		HTML - код, реалиующий интерфейс для ля отображения/модификации массивного
		объектного свойства
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
	
<!-- получим входные параметры страницы -->
	
<!-- XPath-запрос, возвращающий отображаемое массивное св-во -->
<xsl:variable name="x-path-query" select="q:GetValue('PN','')"/>
<!-- метаимя списка  для отображения объектного свойства -->
<xsl:variable name="elements-list-metaname" select="q:GetValue('METANAME','')"/>
<!-- признак сокрытия описания -->
<xsl:variable name="off-description" select="q:GetValue('OFF-DESCRIPTION','')"/>
<!-- сообщение о пустом свойстве -->
<xsl:variable name="prop-not-found" select="q:GetValue('PROP-NOT-FOUND','У данного объекта нет такого свойства.')"/>
<!-- запрос для проверки -->
<xsl:variable name="node-test-query" select="q:GetValue('NODE-TEST-QUERY','')"/>
<!-- как ругаться будем -->
<xsl:variable name="node-test-failed" select="q:GetValue('NODE-TEST-FAILED','К данному объекту это свойство неприменимо.')"/>

<!-- Вспомогательный шаблон отображения массивного свойства -->
<xsl:template name="internal-show-array">
	<!-- В параметрах указано массивное свойство - разрисуем его на всю страницу -->
	<xsl:choose>
		<!-- Удостоверимся что узел, заданный XPath вообще существует-->
		<xsl:when test="0!=number(nav:SelectScalar($x-path-query))">
			<!-- Сначала для данного запроса найдем html-id узла своиства -->
			<xsl:variable name="html-id" select="nav:SelectScalar(concat('generate-id(',$x-path-query,')'))"/>
			<TABLE BORDER="0" CELLSPACING="1" WIDTH="100%" HEIGHT="100%">
				<TBODY>
					<!-- Найдём в объекте св-во с полученным html-id -->
					<xsl:for-each select=".//*">
						<xsl:variable name="this-id" select="generate-id()"/>
						<xsl:if test="$this-id=$html-id">
							<!-- описание свойства -->
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

<!-- Основной шаблон -->
<xsl:template match="*">
	<xsl:choose>
		<!-- Параметр не указан - сгенерируем исключение -->
		<xsl:when test="''=$x-path-query">
			<xsl:message terminate="yes">Внимание: для данной страницы (X-ARRAY.XSL) не указан обязательный параметр &quot;PN&quot; (имя массивного свойства для отображения)</xsl:message>
		</xsl:when>
		<xsl:otherwise>
			<CENTER>
			<!-- Возможно надо проверить наличие какого-то узла -->
			<xsl:choose>
				<xsl:when test="''=$node-test-query">
					<!-- Выведем безо всяких проверок -->
					<xsl:call-template name="internal-show-array"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- Выполним проверку -->
					<xsl:choose>
						<xsl:when test="0!=number(nav:SelectScalar($node-test-query))">
							<!-- Выведем -->
							<xsl:call-template name="internal-show-array"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- Выскажемся -->
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

<!-- Стандартный шаблон для отображения/модификации произвольных массивных объектных св-в -->
<xsl:include href="x-pe-objects.xsl"/>

</xsl:stylesheet>
