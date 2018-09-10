<?xml version="1.0" encoding="windows-1251"?>
<!-- Файл стиля для отображения отчета по XML-файлу передачи списка объектов -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">

<xsl:script language="VBScript">
	Option Explicit
	
	dim g_aColumns	' массив объектов для преобразования данных
	
	'#####################################################################
	' Процедура сбора информации о типах значений в колонках списка
	' Инициализирует глобальный массив g_aColumns объектами типа IXMLDOMElement
	'	 с предустановленным свойством DataType
	' [in] oColumns - IXSLRuntime объект - узел CS списка
	function XslObtainTypes(oColumns)
		dim nCount		' Кол-во столбцов
		dim oTempNode	' IXMLDOMElement, Вспомогательый объект
		dim oTypeNode	' IXMLDOMNode,	Тип данных (аттрибут vt у столбца)
		dim i
		
		'Фиктивное значение (XSL выдаст ошибки если будет Empty)
		XslObtainTypes = 0
		
		nCount = oColumns.childNodes.length
		ReDim g_aColumns(nCount-1)
		
		set oTempNode =  CreateObject("MSXML2.DomDocument").createElement("x")
		oTempNode.text = vbNullString
		
		for i=0 to nCount - 1
			set g_aColumns(i) = oTempNode.cloneNode(true)
			set oTypeNode = oColumns.childNodes.item(i).selectSingleNode("@vt")
			if oTypeNode Is Nothing then
				g_aColumns(i).DataType = "string"
			else
				g_aColumns(i).DataType = oTypeNode.text
			end if
		next
	end function
	
	'#####################################################################
	' Функция форматирования значения поля
	' [in] oField - IXSLRuntime, узел F строки списка - значение поля
	function XmlFormatValue(oField)
		dim sText	' Текст узла
		
		XmlFormatValue = vbNullString
		
		sText = oField.text
		if 0=len(sText) then exit function
		
		with g_aColumns(oField.childNumber(oField)-1)
			.text = sText
			XmlFormatValue = CStr( .nodeTypedValue)  
		end with
	end function
	
</xsl:script>


<xsl:template match="/" language="VBScript">
	<xsl:apply-templates select="LIST"/>
</xsl:template>	
	
<xsl:template match="LIST" language="VBScript">
	<HTML>
		<HEAD>
			<META http-equiv="Content-Type" content="text/html; charset=windows-1251"/>
			<!-- Выводим заголовок окна -->
			<TITLE>
				<xsl:choose>
					<xsl:when test="@title">
						<xsl:value-of select="@title"/>
					</xsl:when>
					<xsl:otherwise>
						Список объектов "<xsl:value-of select="@ot"/>"
					</xsl:otherwise>
				</xsl:choose>
			</TITLE>
			<!-- Ссылка на CSS -->
			<LINK href="x-report.css" rel="STYLESHEET" type="text/css"/>
		</HEAD>
		<BODY CLASS="REPBODY">
			<CENTER>
				<TABLE	border="0" cellPadding="0" cellSpacing="0"><TR><TD>
				<TABLE	border="0" cellPadding="5" cellSpacing="1" CLASS="HTABLE" WIDTH="100%">
					<TR>
						<TD CLASS="TITLES" ALIGN="CENTER" VALIGN="MIDDLE">
							<xsl:choose>
								<xsl:when test="CAPTION">
									<xsl:for-each select="CAPTION">			
										<xsl:apply-templates match="*">
											<!-- recursively apply this template to them -->
											<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
										</xsl:apply-templates>					
									</xsl:for-each>
								</xsl:when>
								
								<xsl:when test="./@title">
									<xsl:for-each select="./@title">			
										<xsl:apply-templates match="*">
											<!-- recursively apply this template to them -->
											<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
										</xsl:apply-templates>					
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									Список объектов "<xsl:value-of select="./@ot"/>"
								</xsl:otherwise>
							</xsl:choose>
						</TD>
					</TR>
				</TABLE>
				<!-- Пустая таблица - разделитель между заголовком и отчетом -->
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
					<TR><TD WIDTH="100%"></TD></TR>
				</TABLE>
				<!-- Генерируем таблицу отчета -->
				<TABLE border="1" BorderColor="black" cellSpacing="0" style="border-collapse:collapse;" width="100%">
					<!-- Описание колонок -->
					<COLGROUP>
						<!-- Генерируем форматы колонок с данными -->
						<xsl:for-each select="CS">
							<xsl:comment>
								<xsl:eval language="VBScript">XslObtainTypes(me)</xsl:eval><BR/>
							</xsl:comment>	
							<!-- Формат колонки для номеров строк -->
							<COL ALIGN="CENTER" WIDTH="50"></COL>
							<xsl:for-each select="C">
								<COL>
									<xsl:attribute name="ALIGN"><xsl:value-of select="@align"/></xsl:attribute>
									<xsl:attribute name="WIDTH"><xsl:value-of select="@width"/></xsl:attribute>
									<xsl:if test="./@hidden">
										<xsl:attribute name="STYLE">DISPLAY:NONE</xsl:attribute>
									</xsl:if>	
									<xsl:if test=".[@width='0']">
										<xsl:attribute name="STYLE">DISPLAY:NONE</xsl:attribute>
									</xsl:if>	
								</COL>
							</xsl:for-each>
						</xsl:for-each>
					</COLGROUP>
					
					<THEAD class="REPHEAD">
						<!-- Строка заголовка таблицы -->
						<TR>
							<TD CLASS="LINENUMBER">№</TD>
							<!-- Последовательно выводим заголовки колонок  -->
							<xsl:for-each select="CS/C">
							
								<TD ALIGN="CENTER" VALIGN="MIDDLE" CLASS="DEFAULT_HEADER_STYLE"><B><xsl:value-of select="."/></B></TD>
							</xsl:for-each>
						</TR>
					</THEAD>
					<!-- Формируем тело отчета -->
					<TBODY class="REPBODY">
						<!-- Строки с данными -->
						<xsl:apply-templates select="RS"/>
					</TBODY>	
				</TABLE>
				<!-- Пустая таблица - разделитель между заголовком и отчетом -->
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
					<TR><TD WIDTH="100%"></TD></TR>
				</TABLE>
				<!-- Подвал отчета -->
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
					<TR>
						<TD>
							<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="1" WIDTH="100%" BGCOLOR="BLACK" STYLE="font:10pt;font-family:Arial">
								<TR>
									<TD CLASS="FOOTER" ALIGN="RIGHT">
										<FONT COLOR="BLACK">
											Отчет составлен <xsl:eval>FormatDateTime( Now(), 1)</xsl:eval> в <xsl:eval>FormatDateTime( Now(), 4)</xsl:eval>
										</FONT>
									</TD>
								</TR>
							</TABLE>
						</TD>
					</TR>
				</TABLE>
				</TD></TR></TABLE>
			</CENTER>
		</BODY>
	</HTML>
</xsl:template>

<!-- Шаблон вывода строк таблицы -->
<xsl:template match="RS">
	<xsl:for-each select="R">
		<TR>
			<!-- Ячейка с номером строки -->
			<TD	class="LINENUMBER"><xsl:eval>formatIndex(childNumber(this), "1")</xsl:eval></TD>
			<xsl:for-each select="F">
				<TD class="DEFAULT_TABLE_STYLE">
					<xsl:eval language="VBScript">XmlFormatValue(me)</xsl:eval>
				</TD>
			</xsl:for-each>	
		</TR>
	</xsl:for-each>
</xsl:template>


<!-- Шаблон вывода по-умолчанию -->
<xsl:template match="text()"><xsl:value-of /></xsl:template>
  
</xsl:stylesheet>
