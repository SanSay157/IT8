<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	Стандартная страница генерации закладки редактора/мастера по умолчанию						
	Входные параметры стрaницы:																	
		urn:x-client-service - интерфейс IXClientService								
		urn:object-editor-access - интерфейс объекта EditorData									
		urn:editor-window-access - интерфейс объекта окна редактора								
		urn:query-string-access - интерфейс строки запроса страницы
			Аргументы, принимаемые через строку запроса:
				PROPLIST  -	список имен свойств, подлежащих	отображению на странице в необходимой 
								последoвательности через ;. При обработке PROPLIST аттрибуты i:hide-in-* игнорируются.
								Внимание! В случае если вместо имени свойства "-" то вставляется горизонтальный разделитель
				DisableHR - Запрет на горизонтальные разделители
				ArrayHeight - Высота отображаемых на странице массивных свойств				
				При отсутствии аргумента PROPLIST производится отображение ВСЕХ свойств с учетом аттрибутов
								i:hide-in-* и в порядке следования их в XML объекта (обычно совпадает с 
								порядком следования в метаднных)				
				
	Обрабатываемый элемент:																		
		Объект X-Storage										
	Результат трансформации:
		HTML - код, реалиующий интерфейс для редактирования свойств переданного объекта
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:user="urn:это_нужно_для_блока_msxsl:script"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt">

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>
	
<msxsl:script language="VBScript" implements-prefix="user">
	<![CDATA['<%

	Dim g_aProps		' Массив имен свойств св-в
	Dim g_nCurrentProp	' Индекс текущего св-ва в списке g_aProps
	Dim g_bNotFirst		' Признак не-первого вызова функции IsFirst()

	'==========================================================================
	' Возвращает true, если вызвана не первый раз, иначе возвращает false
	Function IsNotFirst()
		if not g_bNotFirst then
			IsNotFirst = false
			g_bNotFirst = true
		else
			IsNotFirst = true
		end if
	End Function

	'==========================================================================
	' Инициализирует итератор имён отображаемых свойств
	' [in] sPropList - список отображаемых св-в через ";"
	' Возвращает кол-во свойств в списке
	Function InitPropListIterator(ByVal sPropList)
		sPropList = Trim( "" & sPropList) 
		g_nCurrentProp = 0
		if 0=Len( sPropList) then
			InitPropListIterator = 0
		else
			g_aProps = Split( sPropList, ";")
			InitPropListIterator = UBound( g_aProps)+1
		end if
	End Function
	
	'==========================================================================
	' Возвращает очередное имя свойства либо пустую строку при завершении списка
	Function GetNextPropName()
		GetNextPropName = ""
		if IsEmpty( g_nCurrentProp) then Exit Function
		if not IsArray( g_aProps)	then Exit Function
		if g_nCurrentProp > UBound( g_aProps) then Exit Function
		GetNextPropName = Trim( g_aProps( g_nCurrentProp))
		' Инкрементируем глобальный счётчик
		g_nCurrentProp = g_nCurrentProp + 1
	End Function
	
	'%>']]>
</msxsl:script>

<!-- Признак отключения автоматически вставляемых HR -->
<xsl:variable name="off-hr" select="number(q:GetValueInt('DisableHR',0))"/>

<!-- Высота отображаемых на странице массивных свойств -->
<xsl:variable name="array-height" select="number(q:GetValueInt('ArrayHeight',200))"/>




<xsl:template match="*">
	<!-- 
		Если отрисовываем редактор/мастер вложенного объекта, получаем имена свойств,
		используемых для построения вируального объектного свойства и индекса линка.
		Иначе в эти переменные будет занесён 0, что никогда не совпадёт с именем объектного св-ва
	-->
	<!-- имя свойства, на котором построено виртуальное объектное свойство -->
	<xsl:variable name="build-on-name" select="b:GetSpecialName('built-on')"/>
	<!-- имя индексного свойства линка -->
	<xsl:variable name="order-by-name" select="b:GetSpecialName('order-by')"/>	
	
	<CENTER>
		<!-- Основная таблица, в которой будут разложены св-ва объекта -->
		<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%" style="table-layout1:fixed;">
			<COL WIDTH="40%"/>
			<COL WIDTH="60%"/>
			<TBODY>
				<xsl:choose>
					<!-- В параметрах указан список свойств -->
					<xsl:when test="0!=user:InitPropListIterator(q:GetValue('PROPLIST',''))">
						<!-- Приступим к обработке -->
						<xsl:call-template name="x-editor-xsl-template-iterate-props">
							<xsl:with-param name="build-on-name" select="$build-on-name"/>
							<xsl:with-param name="order-by-name" select="$order-by-name"/>
							<xsl:with-param name="current-name" select="user:GetNextPropName()"/>
						</xsl:call-template>
					</xsl:when>
					<!-- Применяем шаблоны для всех свойств -->
					<xsl:otherwise>
						<xsl:for-each select="*">
							<!-- 
								Если мы находимся в том режиме, в котором отображение текущего св-ва
								не запрещено - сгенерируем соотв. HTML-код для его отображения/модификации
							 -->
							<xsl:if test="(d:IsObjectCreationMode() and not(b:MDQueryProp(current(), 'i:behavior/@hide-on-create'))) or (not(d:IsObjectCreationMode()) and not(b:MDQueryProp(current(), 'i:behavior/@hide-on-edit')))" >
								<xsl:call-template name="x-editor-xsl-template-internal-any">
									<xsl:with-param name="build-on-name" select="$build-on-name"/>
									<xsl:with-param name="order-by-name" select="$order-by-name"/>
								</xsl:call-template>
							</xsl:if>	
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</TBODY>
		</TABLE>
	</CENTER>
</xsl:template>

<!-- 
	=============================================================================================
	Внутренняя рекурсивная функция для организации последовательного вывода св-в из списка 
	[in] build-on-name	- имя свойства, на котором построено виртуальное объектное свойство
	[in] order-by-name	- имя индексного свойства линка
	[in] current-name	- имя текущего выводмого свойства (или пустая строка - если список св-в закончился)
-->
<xsl:template name="x-editor-xsl-template-iterate-props">
	<!-- имя свойства, на котором построено виртуальное объектное свойство -->
	<xsl:param name="build-on-name" />
	<!-- имя индексного свойства линка -->
	<xsl:param name="order-by-name" />
	<!-- имя текущего выводмого свойства -->
	<xsl:param name="current-name" />
	
	<!--  Возможно мы достигли конца очереди-->
	<xsl:if test="''!=$current-name">
		<xsl:choose>
			<xsl:when test="'-'=$current-name">
				<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
			</xsl:when>
			<xsl:when test="'--'=$current-name">
				<tr><td colspan="2"><hr class="x-editor-hr-2"/></td></tr>
			</xsl:when>
			<xsl:when test="'---'=$current-name">
				<tr><td colspan="2"><hr class="x-editor-hr-3"/></td></tr>
			</xsl:when>
			<xsl:otherwise>
				<!-- Найдём и выведем в объекте св-во с указанным именем -->
				<xsl:for-each select="*[name()=$current-name]">
					<xsl:call-template name="x-editor-xsl-template-internal-any">
						<xsl:with-param name="build-on-name" select="$build-on-name"/>
						<xsl:with-param name="order-by-name" select="$order-by-name"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<!-- рекурсивный вызов для дальнейшей обработки -->
		<xsl:call-template name="x-editor-xsl-template-iterate-props">
			<xsl:with-param name="build-on-name" select="$build-on-name"/>
			<xsl:with-param name="order-by-name" select="$order-by-name"/>
			<xsl:with-param name="current-name" select="user:GetNextPropName()"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>


<!-- 
	=============================================================================================
	Внутренняя функция для организации вывода любого свойства... 
	[in] build-on-name - имя свойства, на котором построено виртуальное объектное свойство
	[in] order-by-name - имя индексного свойства линка
-->
<xsl:template name="x-editor-xsl-template-internal-any">
	<!-- имя свойства, на котором построено виртуальное объектное свойство -->
	<xsl:param name="build-on-name" />
	<!-- имя индексного свойства линка -->
	<xsl:param name="order-by-name" />
	
	<!-- Имя свойства -->
	<xsl:variable name="prop-name" select="name()"/>
	<!-- Тип значения свойства -->
	<xsl:variable name="prop-vt" select="b:MDQueryProp(current(), '@vt')"/>
	<!-- Емкость свойства -->
	<xsl:variable name="prop-capacity" select="b:MDQueryProp(current(), '@cp')"/>
	<!-- Описание свойства -->
	<xsl:variable name="prop-d" select="q:GetValue(concat(name(),'-title') ,b:MDQueryProp(current(), '@d'))"/>
	<!-- Признак допустимости пустого значения -->
	<xsl:variable name="prop-maybenull" select="q:GetValue(concat(name(),'-maybenull') ,b:MDQueryProp(current(), '@maybenull'))"/>				
				
	<!-- В зависимости от типа свойства строим UI -->
	<xsl:choose>
		<!-- Строки -->
		<xsl:when test="$prop-vt='string' or $prop-vt='text'">
			<!-- Если это св-во не первое из отображаемых - вставим перед ним разделитель -->
			<!-- Максимальная длина строки -->
			<xsl:variable name="prop-max" select="b:MDQueryProp(current(), 'ds:max')"/>
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	

			<tr>
				<td valign="top">
					<xsl:choose>
						<xsl:when test="1=$prop-maybenull">
							<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>									
					<xsl:value-of select="$prop-d"/>:
				</td>
				<xsl:choose>
					<!-- Для больших строк будет выведено многострочное поле -->
					<xsl:when test="$prop-max &gt; 256 or $prop-vt='text'">
						<td>
							<xsl:call-template name="std-template-text">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:when>
					<!-- Возможно необходима возможность выбора из списка -->
					<xsl:when test="b:MDQueryProp(current(), 'i:string-lookup/@ot')">
						<td>
							<xsl:call-template name="std-template-string-lookup">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:when>
					<!-- Селектор -->
					<xsl:when test="b:MDQueryProp(current(), 'i:const-value-selection')">
						<td>
							<xsl:call-template name="std-template-selector">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:when>
					<!-- Однострочное поле -->
					<xsl:otherwise>
						<td>
							<xsl:call-template name="std-template-string">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:otherwise>
				</xsl:choose>
			</tr>
		</xsl:when>

		<!-- Числа -->
		<xsl:when test="($prop-vt='i2' or $prop-vt='i4' or $prop-vt='r4' or $prop-vt='r8' or $prop-vt='fixed' or $prop-vt='ui1') and $order-by-name!=$prop-name">

			<!-- Если это св-во не первое из отображаемых - вставим перед ним разделитель -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<td valign="top">
					<xsl:choose>
						<xsl:when test="1=$prop-maybenull">
							<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>									
					<xsl:value-of select="$prop-d"/>:
				</td>
				<td>
					<xsl:choose>
						<!-- Битовые флаги -->
						<xsl:when test="b:MDQueryProp(current(), 'i:bits')">
							<xsl:call-template name="std-template-flags"/>
						</xsl:when>

						<!-- Селектор -->
						<xsl:when test="b:MDQueryProp(current(), 'i:const-value-selection')">
							<xsl:call-template name="std-template-selector">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
							</xsl:call-template>
						</xsl:when>

						<!-- Поле ввода -->
						<xsl:otherwise>
							<xsl:call-template name="std-template-number">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
		</xsl:when>

		<!-- Булево значение -->
		<xsl:when test="$prop-vt='boolean'">

			<!-- Если это св-во не первое из отображаемых - вставим перед ним разделитель -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<xsl:choose>
					<!-- Селектор -->
					<xsl:when test="b:MDQueryProp(current(), 'i:const-value-selection')">
						<td valign="top">
							<xsl:choose>
								<xsl:when test="1=$prop-maybenull">
									<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>									
							<xsl:value-of select="$prop-d"/>:
						</td>
						<td>
							<xsl:call-template name="std-template-selector">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:when>
					<!-- Чекбокс -->
					<xsl:otherwise>
						<td valign="top">
							<br />
						</td>
						<td>
							<xsl:call-template name="std-template-bool">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:otherwise>
				</xsl:choose>
			</tr>
		</xsl:when>

		<!-- UUID -->
		<xsl:when test="$prop-vt='uuid'">

			<!-- Если это св-во не первое из отображаемых - вставим перед ним разделитель -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<td valign="top">
					<xsl:choose>
						<xsl:when test="1=$prop-maybenull">
							<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>									
					<xsl:value-of select="$prop-d"/>:
				</td>
				<td>
					<xsl:call-template name="std-template-string">
						<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
						<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:when>
						
		<!-- Дата -->
		<xsl:when test="$prop-vt='dateTime' or $prop-vt='date' or $prop-vt='time'">

			<!-- Если это св-во не первое из отображаемых - вставим перед ним разделитель -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	

			<tr>
				<td valign="top">
					<xsl:choose>
						<xsl:when test="1=$prop-maybenull">
							<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>									
					<xsl:value-of select="$prop-d"/>:
				</td>
				<td>
					<xsl:call-template name="std-template-date">
						<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
						<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:when>
		
		<!-- Объект -->
		<xsl:when test="$prop-vt='object' and ($prop-capacity='scalar' or $prop-capacity='link-scalar' )">
			<!-- Исключим показ скалярных св-в, в которых отображается родительский объект (из редактора которого был вызван текущий редактор) -->
			<xsl:if test="($prop-capacity='scalar' and $build-on-name!=$prop-name or $prop-capacity='link-scalar' and b:MDQueryProp(current(),'@built-on')!=b:GetSpecialName('n')) and (b:IsMDPropExists(current(), 'i:object-presentation') or b:IsMDPropExists(current(), 'i:object-dropdown'))">
				<!-- Если это св-во не первое из отображаемых - вставим перед ним разделитель -->
				<xsl:if test="0=$off-hr">
					<xsl:if test="user:IsNotFirst()">
						<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
					</xsl:if>
				</xsl:if>	
				<tr>
					<td valign="top">
						<xsl:choose>
							<xsl:when test="1=$prop-maybenull">
								<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>									
						<xsl:value-of select="$prop-d"/>:
					</td>
					<td>
						<xsl:call-template name="std-template-object">
							<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
							<xsl:with-param name="maybenull"><xsl:value-of select="w:iif(string($prop-maybenull)='1' or $prop-capacity='link-scalar','1','0')"/></xsl:with-param>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>
		</xsl:when>
						
		<!-- Картинка -->
		<xsl:when test="$prop-vt='bin'">

			<!-- Если это св-во не первое из отображаемых - вставим перед ним разделитель -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<td valign="top">
					<xsl:choose>
						<xsl:when test="1=$prop-maybenull">
							<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>									
					<xsl:value-of select="$prop-d"/>:
				</td>
				<td>
					<xsl:call-template name="std-template-file">
						<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
						<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:when>

		<!-- Массив/коллекция в list-selector'e -->
		<xsl:when test="$prop-vt='object' and ($prop-capacity='array' or $prop-capacity='collection' or $prop-capacity='collection-membership') and b:IsMDPropExists( current(), 'i:list-selector')">
			<!-- Если это св-во не первое из отображаемых - вставим перед ним разделитель -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<td valign="top" colspan="2" class="x-editor-text x-editor-propcaption">
					<xsl:value-of select="$prop-d"/>:
				</td>
			</tr>
			<tr>
				<xsl:variable name="this-array-height" select="number(q:GetValueInt(concat(name(),'-height'),$array-height))"/>
				<xsl:variable name="this-array-metaname" select="q:GetValue(concat(name(),'-metaname'),'')"/>
				<xsl:choose>
					<xsl:when test="''!=$this-array-metaname"> 
						<td height="{$this-array-height}" width="100%" colspan="2">
							<xsl:call-template name="std-template-objects-selector">
								<xsl:with-param name="height"><xsl:value-of select="$this-array-height"/></xsl:with-param>
								<xsl:with-param name="metaname"><xsl:value-of select="$this-array-metaname"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td height="{$this-array-height}" width="100%" colspan="2">
							<xsl:call-template name="std-template-objects-selector">
								<xsl:with-param name="height"><xsl:value-of select="$this-array-height"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:otherwise>
				</xsl:choose>
				<!-- По умолчанию все массивные объектные св-ва выводим с высотой=200 -->
			</tr>
		</xsl:when>

		<!-- Массив/коллекция в tree-selector'e -->
		<xsl:when test="$prop-vt='object' and ($prop-capacity='array' or $prop-capacity='collection' or $prop-capacity='collection-membership') and b:IsMDPropExists( current(), 'i:tree-selector')">
			<!-- Если это св-во не первое из отображаемых - вставим перед ним разделитель -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<td valign="top" colspan="2" class="x-editor-text x-editor-propcaption">
					<xsl:value-of select="$prop-d"/>:
				</td>
			</tr>
			<tr>
				<xsl:variable name="this-array-height" select="number(q:GetValueInt(concat(name(),'-height'),$array-height))"/>
				<xsl:variable name="this-array-metaname" select="q:GetValue(concat(name(),'-metaname'),'')"/>
				<xsl:choose>
					<xsl:when test="''!=$this-array-metaname"> 
						<td height="{$this-array-height}" width="100%" colspan="2">
							<xsl:call-template name="std-template-objects-tree-selector">
								<xsl:with-param name="height"><xsl:value-of select="$this-array-height"/></xsl:with-param>
								<xsl:with-param name="metaname"><xsl:value-of select="$this-array-metaname"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td height="{$this-array-height}" width="100%" colspan="2">
							<xsl:call-template name="std-template-objects-tree-selector">
								<xsl:with-param name="height"><xsl:value-of select="$this-array-height"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:otherwise>
				</xsl:choose>
				<!-- По умолчанию все массивные объектные св-ва выводим с высотой=200 -->
			</tr>
		</xsl:when>
		
		<!-- Массив/линк/коллекция в element-list'e -->
		<xsl:when test="$prop-vt='object' and ($prop-capacity='array' or $prop-capacity='link' or $prop-capacity='collection' or $prop-capacity='array-membership' or $prop-capacity='collection-membership') and b:IsMDPropExists( current(), 'i:elements-list')">
			<!-- Если это св-во не первое из отображаемых - вставим перед ним разделитель -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<td valign="top" colspan="2" class="x-editor-text x-editor-propcaption">
					<xsl:value-of select="$prop-d"/>:
				</td>
			</tr>
			<tr>
				<xsl:variable name="this-array-height" select="number(q:GetValueInt(concat(name(),'-height'),$array-height))"/>
				<xsl:variable name="this-array-metaname" select="q:GetValue(concat(name(),'-metaname'),'')"/>
				<xsl:choose>
					<xsl:when test="''!=$this-array-metaname"> 
						<td height="{$this-array-height}" width="100%" colspan="2">
							<xsl:call-template name="std-template-objects">
								<xsl:with-param name="height"><xsl:value-of select="$this-array-height"/></xsl:with-param>
								<xsl:with-param name="metaname"><xsl:value-of select="$this-array-metaname"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td height="{$this-array-height}" width="100%" colspan="2">
							<xsl:call-template name="std-template-objects">
								<xsl:with-param name="height"><xsl:value-of select="$this-array-height"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:otherwise>
				</xsl:choose>
				<!-- По умолчанию все массивные объектные св-ва выводим с высотой=200 -->
			</tr>
		</xsl:when>
	</xsl:choose>
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
<!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
<xsl:include href="x-pe-object.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных массивных объектных св-в -->
<xsl:include href="x-pe-objects.xsl"/>
<!-- Стандартный шаблон для отображения/модификации массивных объектных св-в в виде read-only списка -->
<xsl:include href="x-pe-objects-selector.xsl"/>
<!-- Стандартный шаблон для отображения /модификации массивных объектных св-в в виде дерева с чекбоксами -->
<xsl:include href="x-pe-objects-tree-selector.xsl"/>
<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
<xsl:include href="x-pe-selector.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
<xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
