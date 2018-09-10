<?xml version="1.0" encoding="windows-1251"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:user="urn:это_нужно_для_блока_msxsl:script"
	xmlns:m="urn:menu-object-access"
	xmlns:tp="urn:sender-object-access"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"
>	
	
<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>

<!-- наименование процедуры-обработчика клика на пункте меню. Прототип следующий:
	{handler-proc-name}(sAction)
-->
<xsl:param name="handler-proc-name" select="'alert '"/>

<msxsl:script language="VBScript" implements-prefix="user">

	<![CDATA['<%

	Dim g_nGlobalCounter		' максимальное кол-во значений menu-info-item в секции
	Dim g_nCurrentCounter		' количество значений в текущем menu-info-item
	
	'Сброс глобального счётчика
	function DoResetGlobalCounter()
		g_nGlobalCounter = 0
		DoResetGlobalCounter = ""
	end function
	
	'Сброс текущего счётчика
	function DoResetCurrentCounter()
		g_nCurrentCounter = 0
		DoResetCurrentCounter = ""
	end function
	
	'Инкремент текущего счётчика
	function DoIncrementCurrentCounter()
		g_nCurrentCounter = g_nCurrentCounter + 1 
		if g_nCurrentCounter > 	g_nGlobalCounter then
				g_nGlobalCounter = g_nCurrentCounter
		end if	
		DoIncrementCurrentCounter = ""
	end function
	
	
	'Возвращает максимальное кол-во значений menu-info-item в секции
	function GetMaxCount()
		GetMaxCount = g_nGlobalCounter
	end function
	
	'Возвращает значение параметра COLSPAN для заголовка меню
	function GetColSpan()
		' COLSPAN = общее число значений menu-info-item + 2 сужебных столбца (описание + :)
		GetColSpan = g_nGlobalCounter+2
	end function
	
	'Возвращает значение параметра COLSPAN для последнего значений текущего элемента menu-info-item
	function GetColSpan2()
		' COLSPAN = общее число значений menu-info-item  - число значений текущем menu-info-item + 1
		GetColSpan2 = g_nGlobalCounter - g_nCurrentCounter + 1
	end function
	
	' Функция возвращает преобразованный к 16-ричному виду код ошибки
	' [in] nVal  - значение кода ошибки
	Function DoHex(byval nVal)
		const HEX_DIGITS = 8	' число шеснадцатеричных разрядов
		dim sTemp				' временная переменная
		sTemp = HEX(CLng(nVal))
		DoHex = LCase( "0x" & String( HEX_DIGITS - Len( sTemp), "0") & sTemp)
	End Function	
	
	'%>']]>

</msxsl:script>


<xsl:template match="i:menu">
<div class="x-tree-menu">
<table class="x-tree-menu" border="0" cellpadding="0" cellspacing="0">
<!-- 1 сначала посчитаю максимальное вхождение элементов value в //menu-item-info -->
	<!-- обнуляю глобальный счётчик вхождений -->
	<xsl:value-of select="user:DoResetGlobalCounter()"/>
	<xsl:for-each select="//i:menu-item-info">
		<!-- обнуляю счётчик вхождений в текущий пункт-->
		<xsl:value-of select="user:DoResetCurrentCounter()"/>
		<!-- подсчитываю число вхождений в текущий пункт-->
		<xsl:for-each select="i:value">
			<xsl:value-of select="user:DoIncrementCurrentCounter()"/>
		</xsl:for-each>
	</xsl:for-each>
<!-- 2 строю результирующую таблицу... -->
<thead class="x-tree-menu-header">
	<tr class="x-tree-menu-header">
		<!-- заголовок меню -->
		<td class="x-tree-menu-header">
			<xsl:attribute name="colspan"><xsl:value-of select="user:GetColSpan()"/></xsl:attribute>
			<xsl:apply-templates select="i:caption"/>
		</td> 
	</tr>
	<tr class="x-tree-menu-header-shadow">
		<!-- тень заголовка меню -->
		<td class="x-tree-menu-header-shadow">
			<xsl:attribute 	name="colspan">
				<xsl:value-of select="user:GetColSpan()"/>
			</xsl:attribute>
		</td> 
	</tr>
</thead>
	<!-- обрабатываем сабитемы -->
	<xsl:call-template name="iterate-items" />
</table>
</div>
</xsl:template>

<!-- Отдельный шаблон для итерирования элементов одного уровня menu или section -->
<xsl:template name="iterate-items">
	<xsl:for-each select="i:menu-item[not(@hidden) and not(@disabled)]|i:menu-item-info[not(@hidden) and not(@disabled)]|i:menu-section[not(@hidden) and not(@disabled)]|i:menu-item-separ[not(@hidden) and not(@disabled)]">
		<xsl:apply-templates select=".">
			<!-- протолкнем наименование обработчика в следующий шаблон -->
			<xsl:with-param name="handler-proc-name">
				<xsl:value-of select="$handler-proc-name"/>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:for-each>
</xsl:template>
	
<xsl:template match="i:menu-item">
	<xsl:if test="@separator-before">
		<xsl:call-template name="template-menu-item-separ"/>
	</xsl:if>
	<tr class="x-tree-menu-item">
		<td class="x-tree-menu-item">
			<xsl:attribute name="colspan"><xsl:value-of select="user:GetColSpan()"/></xsl:attribute>
			<a class="x-tree-menu-item">
			<xsl:choose>
				<xsl:when test="@action">
					<xsl:attribute name="href">javascript:void(0);</xsl:attribute>
					<xsl:attribute name="language">VBScript</xsl:attribute>
					<xsl:attribute name="onclick"><xsl:value-of select="concat($handler-proc-name,' ')"/> "<xsl:value-of select="@n"/>"</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:attribute name="title">
				<xsl:value-of select="@hint"/>
			</xsl:attribute>
			<xsl:attribute name="OnMouseOver">vbscript:OnMenuShowHint me</xsl:attribute>
			<xsl:attribute name="OnMouseOut">vbscript:OnMenuHideHint</xsl:attribute>
			<xsl:value-of select="@t" disable-output-escaping="yes"/>
			</a>
		 </td>
	</tr>
	<xsl:if test="@separator-after">
		<xsl:call-template name="template-menu-item-separ"/>
	</xsl:if>
</xsl:template>

<xsl:template match="i:menu-section">
<thead class="x-menu-section-header" language="VBScript" ondblclick="MenuSectionClick(me)" onclick="MenuSectionClick(me)">
	<!-- id, если он есть... -->
	<xsl:if test="@n">
		<xsl:attribute name="id">XUIMENUSECTION_<xsl:value-of select="@n"/></xsl:attribute>
	</xsl:if>
	<!-- трюк! ,будем использовать дополнительные свойства как флаг состояния секции !!! -->
	<xsl:attribute name="ExtendedIsCollapsed">
		<xsl:choose>
			<xsl:when test="@section-hidden='1'">0</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
	<tr class="x-menu-section-header">
		<!-- заголовок секции меню -->
		<td class="x-tree-menu-section-header">
			<xsl:attribute 	name="colspan">
				<xsl:value-of select="user:GetColSpan()"/>
			</xsl:attribute>
			<!-- таблица - holder для заголовка секций меню -->
			<table class="x-tree-menu-section-header-holder"  border="0" cellpadding="0" cellspacing="0">
				<tr class="x-tree-menu-section-header-holder">
					<!-- ячейка для состояния меню (раскрытая/скрытая) -->
					<td>
						<xsl:attribute name="class">x-tree-menu-section-state-<xsl:choose>
						<xsl:when test="@section-hidden='1'">collapsed</xsl:when>
						<xsl:otherwise>expanded</xsl:otherwise>
						</xsl:choose>
						</xsl:attribute>
					</td>
					<!-- ячейка для заголовка секции меню -->
					<td><xsl:attribute name="class">x-tree-menu-section-caption-<xsl:choose>
						<xsl:when test="@section-hidden='1'">collapsed</xsl:when>
						<xsl:otherwise>expanded</xsl:otherwise>
						</xsl:choose>
						</xsl:attribute>
						<xsl:value-of select="@t" disable-output-escaping="yes"/>
					</td>
				</tr>
			</table>
		</td> 
	</tr>
	<!-- тень заголовка секции меню
	<tr class="x-tree-menu-section-header-shadow">
		<td class="x-tree-menu-section-header-shadow">
			<xsl:attribute 	name="colspan">
				<xsl:value-of select="user:GetColSpan()"/>
			</xsl:attribute>
		</td> 
	</tr>
	 -->
</thead>
<tbody>
	<xsl:attribute name="class">x-tree-menu-section-content-<xsl:choose>
		<xsl:when test="@section-hidden='1'">collapsed</xsl:when>
		<xsl:otherwise>expanded</xsl:otherwise></xsl:choose>
	</xsl:attribute>
	<!-- обрабатываем сабитемы -->
	<xsl:call-template name="iterate-items" />	
</tbody>
</xsl:template>

<xsl:template match="i:menu-item-separ">
	<xsl:call-template name="template-menu-item-separ">
		<xsl:with-param name="horizontal-line" select="@horizontal-line"/>
	</xsl:call-template>
</xsl:template>
<!-- Шаблон для вывода разделителя -->
<xsl:template name="template-menu-item-separ">
	<xsl:param name="horizontal-line" select="'1'"/>
	<tr class="x-tree-menu-separ-item">
		<td class="x-tree-menu-separ-item">
			<xsl:attribute name="colspan"><xsl:value-of select="user:GetColSpan()"/></xsl:attribute>
			<xsl:choose>
				<xsl:when test="$horizontal-line='1'"><hr class="x-tree-menu-separ-item"></hr></xsl:when>
				<xsl:otherwise><xsl:attribute name="style">display:block;height:8px;</xsl:attribute>
			</xsl:otherwise>
			</xsl:choose>
		</td>
	</tr>
</xsl:template>

<xsl:template match="i:menu-item-custom">
    <tr class="x-tree-menu-item-custom">
		<td class="x-tree-menu-item-custom">
			<xsl:attribute name="colspan">
				<xsl:value-of select="user:GetColSpan()" />
			</xsl:attribute>
			<xsl:value-of select="." disable-output-escaping="yes"/>
		</td>
	</tr>
</xsl:template>

<!-- информационный пункт -->
<xsl:template match="i:menu-item-info">
<tr class="x-tree-menu-info-item" >
	<!-- подсчитываю кол-во информационных подитемов -->
	<xsl:value-of select= "user:DoResetCurrentCounter()" />
	<xsl:for-each select= "i:value">
		<xsl:value-of select="user:DoIncrementCurrentCounter()"/>
	</xsl:for-each>
	<!-- и понеслась -->
	<td class="x-tree-menu-info-item-caption">
		<xsl:apply-templates select="i:caption"/>
		<xsl:if test="string-length(i:caption/text()) != 0">:</xsl:if>
	</td>
	<td class="x-tree-menu-info-item-space"></td>
	<xsl:for-each select= "i:value">
		<td class="x-tree-menu-info-item-value">
			<xsl:if test="position()=last()">
				<xsl:attribute name="colspan"><xsl:value-of select="user:GetColSpan2()" /></xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="."/>
		</td>	
	</xsl:for-each>
</tr>
</xsl:template>

<xsl:template match="i:caption">
	<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="i:value">
	<xsl:value-of select="." disable-output-escaping="yes"/>
</xsl:template>

<xsl:template match="x-res">
	<table border="0">
			<tr>
				<td colspan="2">
					<h2 style="color:red">
						При построении меню на сервере произошла ошибка!
					</h2>
				</td>
			</tr>
			<tr>
				<td><b>Описание:</b></td>
				<td><xsl:value-of select="@user-msg" /></td>
			</tr>
			<xsl:if test="( (@c) and (@c !='') ) or ( (@sys-msg) and (@sys-msg !='') )">
				<tr><td colspan="2"><br/><h3>Информация для администратора:</h3></td></tr>
				<xsl:if test="(@c) and (@c !='')">
					<tr>
					<td><b>Код ошибки:</b></td>
					<td>
						<B><tt><xsl:value-of select="user:DoHex(number(@c))"/>
							(<xsl:value-of select="@c" />)</tt></B>
					</td></tr>
				</xsl:if>
				<xsl:if test="(@sys-msg) and (@sys-msg !='')">
					<tr>
						<td><b>Системное сообщение:</b></td>
						<td>
							<xsl:value-of select="@sys-msg" />
						</td>
					</tr>
				</xsl:if>
			</xsl:if>
	</table>
</xsl:template>

</xsl:stylesheet>
