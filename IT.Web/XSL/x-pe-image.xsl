<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	Стандартная страница генерации элементов  отображения/модификации для скалярных свойств объекта
	типа bin.hex в виде изображения
-->	
	<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:d="urn:editor-data-access">
	<!--
		=============================================================================================
		Стандартный шаблон генерации элементов  отображения/модификации для скалярных свойств объекта
		типа bin.hex в виде изображения
		Объекты страницы
			urn:editor-data-access - интерфейс объекта EditorData									
		Обрабатываемый элемент:																		
			Свойство объекта X-Storage
		Входные параметры:
			[in] maybenull	- признак допустимости пустого значения	(0/1)										
			[in] description - описание поля
		Результат трансформации:
			HTML -	код, реализующий интерфейс для элементов отображения/модификации скалярных свойств объекта 
			типа bin.hex в виде изображения
	-->	
	<!-- Шаблон вывода картинки из bin.hex -->
	<xsl:template name="std-template-image">
		<!-- Параметр: описание поля -->
		<xsl:param name="description" select="d:MDQueryProp(current(), '@d')"/>
		<!-- Параметр: признак допустимости пустого значения -->
		<xsl:param name="maybenull" select="d:MDQueryProp(current(), '@maybenull')"/>
		<!-- 
			При шелчке по кнопке будем вызывать функцию в стандартном коде, 
			формирующую выпадающее меню операций над свойством, передавая ей ID 
		-->	
		<button disabled="1" style="width:100%" class="x-editor-image-button" >
			<!-- 
				В кач-ве основы для идентификатора используем аттрибут html-id обрабатываемого
				объектного св-ва. Это позволит в дальнейшем сопоставить вставленный 
				элемент с соответсвующим свойством объекта из пользовательского кода.
			-->				
			<xsl:attribute name="id"><xsl:value-of select="@html-id"/></xsl:attribute>
			<!-- 
				Если свойство может принимать значение null - выставим дополнительный
				аттрибут X_MAYBENULL.
				Этот аттрибут позволит контролировать допустимость значения св-ва при
				обработке из кода.
			-->
			<xsl:if test="1=$maybenull">
				<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
			</xsl:if>
			<!-- 
				Дополнительный аттрибут X_DESCR будет хранить описание св-ва, которое,
				в общем случае может отличаться от описания в метаданных.
				Этот аттрибут позволит получить описание сопоставленного с элементом
				свойства из кода.
			-->					
			<xsl:attribute name="X_DESCR"><xsl:value-of select="$description" /></xsl:attribute>

			<table cellpadding="0" cellspacing="0" border="0" width="100%" height="100%">
				<tr>
					<td width="10%" align="right" valign="middle"><b>&lt;</b></td>
					<td width="80%" align="center" valign="middle">
						<!-- 
							В кач-ве основы для идентификатора используем аттрибут html-id обрабатываемого
							объектного св-ва. Это позволит в дальнейшем сопоставить вставленный 
							элемент с соответсвующим свойством объекта из пользовательского кода.
						-->
						<xsl:attribute name="id"><xsl:value-of select="@html-id"/>Caption</xsl:attribute>
						<xsl:choose>
							<xsl:when test="@data-size=0">
								- пусто -
							</xsl:when>
							<xsl:when test="@local-file-name">
								изображение* [<xsl:value-of select="@data-size"/> байт]	
							</xsl:when>
							<xsl:otherwise>
								изображение
								<xsl:choose>
									<xsl:when test="@data-size">
										[<xsl:value-of select="@data-size"/> байт]	
									</xsl:when>
									<xsl:otherwise>
										???
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</td>	
					<td width="10%" align="left" valign="middle"><b>&gt;</b></td>
				</tr>
			</table>
		</button>
		<script language="VBScript" for="{@html-id}" event="OnClick">
		'<xsl:comment>
		'===========================================================================
		' Обработка изменения свойства - картинки
		const sHTMLID= "<xsl:value-of select="@html-id"/>"' уникальный идентификатор
		'<![CDATA[
		dim sOT				'  тип объекта - контейнера св-ва
		dim nID				'  идентификатор объекта - контейнера св-ва
		dim sPN				'  имя  текущего св-ва
		dim sURL			'  URL картинки
		dim oImage			'  свойство c картинкой в виде XMLDomElement
		dim oButton			'  кнопка - элемент редактиования свойства
		dim nFileSize		'  размер файла с картинкой в байтах
		dim aFileData		'  данные файла в виде SafeArray однобайтных беззнаковых целых
		' Получаем  свойство c картинкой из XML
		set oImage = EditorData.getPropByHTMLID(  sHTMLID )
		' Получаем  тип объекта - контейнера св-ва
		sOT = oImage.parentNode.tagName
		' Получаем  идентификатор объекта - контейнера св-ва
		nID = oImage.parentNode.getAttribute("oid")
		' Получаем  имя  текущего св-ва
		sPN = oImage.tagName
		' Получаем URL для отрисовки картинки
		if (X_GetAttributeDef( oImage, "data-size", -1) <> 0) and ( nID>0 ) then
			sURL = XService.BaseURL & "x-get-image.asp?OT=" & sOT & "&ID=" & nID & "&PN=" & sPN & "&TM=" & CDbl(Now)
		else
			sURL = ""
		end if
		sURL = X_GetAttributeDef( oImage, IMG_LOCAL_FILE_NAME, sURL)
		'выбираем новую картинку...
		sURL = X_SelectImage("Выбор изображения",sURL,"",0,0,0,0,0)
		'нажата кнопка Отмена - ничего не делаем
		if IsEmpty(sURL) then exit sub 
			
		if IsNull(sURL) then
			'нажата кнопка Очистить - удаляем картинку...
			nFileSize = 0	
			aFileData = Empty
		else
			'загружаем картину в массив
			on error resume next

			aFileData = XService.GetFileData(sURL)
			if Err then
				Alert "Ошибка при попытке чтения из файла:" & vbNewLine & vbTab & sURL & vbNewLine & vbTab & Err.Description
				Err.Clear 
				exit sub
			end if
			on error goto 0
			nFileSize = UBound(aFileData)+1
			'если выбранный файл пустой - тоже удаляем картинку
			if nFileSize = 0 then 
				aFileData = Empty
			end if
		end if	
		'обновляем XML
		oImage.setAttribute "data-size", nFileSize
		oImage.removeAttribute LOADED
		if nFileSize=0 then
			oImage.removeAttribute IMG_LOCAL_FILE_NAME
			oImage.Text = ""
		else
			oImage.setAttribute IMG_LOCAL_FILE_NAME, sURL
			oImage.nodeTypedValue = aFileData
		end if
		'получаем надпись в кнопке...
		set oButton = document.all(  sHTMLID & "Caption" )
		'перерисовываем кнопку
		if nFileSize>0 then
			oButton.innerHTML ="изображение<b>*</b> [" & nFileSize & " байт]"
		else
			oButton.innerHTML = "- Пусто -"				
		end if
		']]>
		'</xsl:comment>
		</script>
	</xsl:template>

</xsl:stylesheet>
