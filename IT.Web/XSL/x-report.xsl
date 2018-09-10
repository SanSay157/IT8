<?xml version="1.0" encoding="windows-1251"?>
<!-- 
	Файл стиля для отображения отчета по XML-файлу, сгенеренному ReportGenerator'ом.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">
<xsl:script language="VBScript"><![CDATA[ 
	''>
	dim g_nCurrentRow	' Глобальная переменная - номер текущей строки таблицы отчета...
	' Функция возвращает номер строки текущей таблицы отчёта... >
    Function GetRowNum()
		if IsEmpty(g_nCurrentRow) then
			g_nCurrentRow = 0
		else
			g_nCurrentRow = g_nCurrentRow+1	
		end if	
		GetRowNum = g_nCurrentRow 
    End Function
    
    ' Специальный аттрибут CSS,выставляемый у таблицы и указывающий частоту дублирования заголовка в теле таблицы...
    const CSS_FIX_SELECTOR = "croc-duplicate-header"
    
    dim g_nTableFixDist	' Глобальная переменная - число строк, через которые надо дублировать заголовок таблицы...
    dim g_nTableBodyRow ' Глобальная переменная - номер текущей строки тела текущей таблицы отчёта
    
    ' Инициализация переменных при начале очередной таблицы
    ' oTable [in] - объект таблица
    Function OnStartTable(oTable)
		dim vClass	' класс таблицы
		dim oStyle	' стиль таблицы (объект)
		dim sStyle	' стиль таблицы (строка)
		dim nOffset ' смещение в стиле
		dim aTmp	' временный массив, получаемый операцией Split над строкой со стилем
		
		OnStartTable	= ""
		g_nTableBodyRow	= 0
		
		g_nTableFixDist = Empty
		vClass = oTable.getAttribute("CLASS")
		if IsNull(vClass) then 	Exit Function
		set oStyle =  oTable.parentNode.selectSingleNode("STYLES/STYLE[@NAME='" & vClass &  "']")
		if oStyle is Nothing then 	Exit Function
		
		sStyle = oStyle.text
		nOffset = InStr(1, sStyle , CSS_FIX_SELECTOR )
		if 0 = nOffset then Exit Function
		
		sStyle = MID(sStyle, nOffset)
		
		aTmp = Split(sStyle, ":")
		sStyle = Trim(aTmp(1))
		
		aTmp = Split(sStyle, ";")
		sStyle = Trim(aTmp(0))
		
		if CLng(sStyle) > 0 then 
			g_nTableFixDist = CLng(sStyle) + 1
		end if	
		
    End Function
    
    ' Проверка на необходимость вставки дубликата заголовка таблицы
    Function OnCheckDuplicateHeader()
		OnCheckDuplicateHeader = false
		if IsEmpty( g_nTableFixDist) then exit function
		g_nTableBodyRow = g_nTableBodyRow + 1
		if 0 = (g_nTableBodyRow mod g_nTableFixDist) then OnCheckDuplicateHeader=true
    End Function
    
    ]]>
 </xsl:script>

<xsl:template match="/" language="VBScript">
	<HTML>
		<HEAD>
			<META http-equiv="Content-Type" content="text/html; charset=windows-1251"/>
			<!-- Выводим заголовок окна -->
			<TITLE>
				<xsl:choose>
					<xsl:when test="REPORT/APPNAME[.!='']">
						<xsl:value-of select="REPORT/APPNAME"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="REPORT/TITLE"/>
					</xsl:otherwise>
				</xsl:choose>
			</TITLE>
			<!-- Ссылка на CSS -->
			<LINK href="x-report.css" rel="STYLESHEET" type="text/css"/>
			<!-- XML data island - копия данных отчёта -->
			<XML id="xmlReportData">
				<REPORT>
					<xsl:for-each select="REPORT">			
						<xsl:apply-templates match="*">
							<!-- recursively apply this template to them -->
							<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
						</xsl:apply-templates>					
					</xsl:for-each>
				</REPORT>
			</XML>
			
			<SCRIPT language="VBScript" type="text/vbscript">
				<xsl:comment>'<![CDATA[ <%

' Обработчик команды "Экспорт в Excel"
' Поддерживается следующее подмножество CSS:
' background-color & color
'  формат: color:rgb(nRed,nGreen,nBlue) & background-color:rgb(nRed,nGreen,nBlue)
'     - nRed	- составляющая красного цвета 0<= nRed <=255
'     - nGreen  - составляющая зелёного цвета 0<= nGreen <=255
'     - nBlue	- составляющая синего   цвета 0<= nBlue <=255
'  пример:
'     color:rgb(0,0,0)  - устанавливает чёрный цвет текста
'  ! другой формат задания цвета не поддерживается и может привести к ошибке
' font-size
'  формат: font-size:nFontSize
'     - nFontSize	- размер шрифта в пунктах
'  пример:
'     font-size:12  - устанавливает размер шрифта = 12 пунктам
'  ! другой формат задания размера шрифта не поддерживается
'
' text-align			\
' font-weight			 \
' text-decoration         \   см. спецификацию CSS
' font-style              /
' font-family            /
' vertical-align		/
'
'	все остальные аттрибуты CSS игнорируются

sub DoExportToExcel
	' коэффициент пересчёта ширины столбца 
	const  WIDTH_RATIO	= 7.5
	' коэффициент пересчёта высоты строки
	const  HEIGHT_RATIO = 1.1
	' размер шрифта у заголока/подвала
	const  HEAD_FONT_SIZE = 10
	' размер шрифта у APPNAME
	const  APPNAME_FONT_SIZE = 16
	' размер шрифта у тела документа
	const  BODY_FONT_SIZE = 8
	' имя шрифта
	const  FONT_NAME = "Arial" '"Microsoft Sans Serif"
	' гранулярность расчёта ширины столбцов
	const  PERCENT_SIZE = 500
	
	' Максимально допустимое число колонок в Excel
	const  xlMaxColCount = 254

	' всякие константы Excel-а
	const  xlWBATWorksheet = -4167
	const  xlNormal = -4143
	const  xlMinimized = -4140

	' горизонтальные и вертикальные выравнивания
	const  xlHAlignCenter = -4108
	const  xlHAlignLeft = -4131
	const  xlHAlignRight = -4152
	const  xlVAlignBottom = -4107
	const  xlVAlignCenter = -4108
	const  xlVAlignJustify = -4130
	const  xlVAlignTop = -4160

	' индексы рамок
	const  xlInsideHorizontal = 12
	const  xlInsideVertical = 11
	const  xlEdgeBottom = 9
	const  xlEdgeLeft = 7
	const  xlEdgeRight = 10
	const  xlEdgeTop = 8

	' толщина рамок
	const  xlThin = 2

	' стили линий
	const  xlContinuous = 1
	
	' подчёркивание текста
	const xlUnderlineStyleSingle = 2
	const xlUnderlineStyleNone = -4142

	dim oXmlData				' объект с исходными данными отчёта
	dim oExelApp				' приложение Excel.Application
	dim oSheet					' таблица Excel.Sheet
	dim oBook					' книга Excel.Workbook
	dim aCols				    ' массив ширин столбцов таблиц
	dim aRows					' массив размерностью n*5, где n - число столбцов в обрабатываемой таблице
								' aRows(i,0) - текущее значение RowSpan в контексте i-го столбца данной строки
								' aRows(i,1) - текущее значение ColSpan в контексте i-го столбца данной строки
								' aRows(i,2) - номер первого столбца в диапазоне столбцов таблицы Excel, отображаемого на i-й столбец
								' aRows(i,3) - номер последнего столбца в диапазоне столбцов таблицы Excel, отображаемого на i-й столбец
								' aRows(i,4) - признак того, что столбец таблицы отчёта занимает несколько столбцов таблицы Excel
	dim nTotalCols				' общее количество столбцов в таблице Excel
	dim oTable					' обрабатываемая таблица отчёта	(IXMLDomElement)
	dim oCol					' обрабатываемый элемент COL в COLGROUP у oTable
	dim nMaxWidth				' максимально - возможная ширина для таблицы (в пикселях)
	dim sWidth					' значение аттрибута WIDTH у oCol
	dim nWidth					' ширина текущего столбца текущей таблицы отчёта в %
	dim nCurrentWidth			' текущая ширина
	dim nRow					' текущая строка таблицы Excel
	dim nCol					' текущий столбец таблицы Excel
	dim oTR						' обрабатываемая строка таблицы отчёта	(IXMLDomElement)
	dim oTD						' обрабатываемый столбец строки таблицы отчёта	(IXMLDomElement)
	dim nOffset					' смещение ширина текущего столбца текущей таблицы отчёта в линейке ширин столбцов таблицы Excel
	dim nColSpan				' значение аттрибута COLSPAN у столбца текущей таблицы отчёта
	dim nRowSpan				' значение аттрибута ROWSPAN у столбца текущей таблицы отчёта
	dim oCell					' ячейка таблицы Excel
	dim nTableStartRow			' номер первой строки текущей таблицы отчёта в таблице Excel
	dim aStyle					' массив, содержащий пары вида АТТРИБУТ_CSS : ЗНАЧЕНИЕ_АТТРИБУТА_CSS 
	dim aOneStyle				' массив из 2-х элементов, содержит аттрибут и значение
								' aOneStyle(0) - АТТРИБУТ_CSS
								' aOneStyle(1) - ЗНАЧЕНИЕ_АТТРИБУТА_CSS 
	dim sOneStyleSelector		' АТТРИБУТ_CSS
	dim vStyleValue				' ЗНАЧЕНИЕ_АТТРИБУТА_CSS
	dim sStyle					' имя класса, либо список пар вида  АТТРИБУТ_CSS : ЗНАЧЕНИЕ_АТТРИБУТА_CSS, разделённых ;
	dim oStyle					' элемент STYLE отчёта (IXMLDomElement)
	dim sCell					' содержимое ячейки таблицы Excel
	dim nTotalTDCount			' общее количество ячеек во всех таблицах отчётов
	dim nCurrentTD				' сколько ячеек уже обработано
	dim nTableTD				' число ячеек в таблице - 1
	dim oRowGroup				' контейнер строк таблицы (THEAD или TBODY или TFOOT) (IXMLDomElement)
	dim nRowGroupLen			' число строк в oRowGroup
	dim vColor					' цвет текста
	dim vBGColor				' цвет фона
	dim vFontName				' имя шрифта
	dim vFontSize				' размер шрифта
	dim vAlign					' горизонтальное выравнивание
	dim vVAlign					' вертикальное выравнивание
	dim vUnderline				' признак подчёркивания
	dim vItalic					' признак наклонности
	dim vBold					' признак толстого шрифта
	dim nTableRowCount			' число строк в таблице отчёта
	dim nTableRow				' текущая строка таблицы отчёта
	dim nMaxRowHeight			' максимально-допустимая высота строки...
	dim i,j						
	
	on error resume next
	'покажем строку статуса...
	idStatus.style.display = "block"
	' переносим данные в новосозданный объект чтобы перейти к конкретной версии парсера...
	ReportStatus  "Получение исходных данных..."
	set oXmlData = CreateObject("MSXML2.FreeThreadedDOMDocument.3.0")
	oXmlData.loadXML "<?xml version='1.0' encoding='windows-1251' ?>" & xmlReportData.XmlDocument.xml
	set oXmlData = oXmlData.documentElement 
	' пытаюсь поднять Excel...
	ReportStatus "Установление связи с Microsoft Excel..."
	set oExelApp = XService.CreateObject("Excel.Application")
	if Err then
	    Alert "Невозможно установить связь с Microsoft Excel. Возможно он не установлен, либо настройки безопасности препятствуют взаимодействию с ним..." & _
			 vbNewLine & Err.Description
	    ReportStatus "При попытке установить связь с Microsoft Excel произошла ошибка."
		exit sub
	end if
	' предварительная обработка отчёта
	ReportStatus "Экспорт стилей..."
	' Парсинг стилей...
	for each oStyle in oXmlData.selectNodes("STYLES/STYLE[@NAME]")
		' Сначала распарсим строчку стиля и занесём поддерживаемые аттрибуты в переменные
		vColor		= null
		vBGColor	= null
		vFontName	= null
		vFontSize	= null
		vAlign		= null
		vVAlign		= null
		vUnderline	= null
		vItalic		= null
		vBold		= null
		
		sStyle = Trim(oStyle.text)
		aStyle = Split(sStyle,";")
		for i=0 to UBound(aStyle)
				if 0<> InStr(1,aStyle(i),":") then
				aOneStyle = Split(aStyle(i),":" )
				sOneStyleSelector = UCase( Trim(aOneStyle(0)))
				vStyleValue	= Trim(aOneStyle(1))
				select case sOneStyleSelector 
					case "COLOR"
						vStyleValue = UCase(vStyleValue)
						if 1=InStr(1,vStyleValue , "RGB(") then
							vColor = Eval(vStyleValue)
						end if
					case "BACKGROUND-COLOR" 
						vStyleValue = UCase(vStyleValue)
						if 1=InStr(1,vStyleValue , "RGB(") then
							vBGColor = Eval(vStyleValue)
						end if
					case "TEXT-ALIGN"
						vAlign = UCase(vStyleValue)
					case "VERTICAL-ALIGN"
						vAlign = UCase(vStyleValue)
					case "FONT-WEIGHT"
						if "BOLD" = UCase(vStyleValue) then vBold = 1
					case "FONT-STYLE"	
						if "ITALIC" = UCase(vStyleValue) then vItalic = 1
					case "TEXT-DECORATION"	
						if "UNDERLINE" = UCase(vStyleValue) then vUnderline = 1
					case "FONT-FAMILY"	
						vFontName = vStyleValue
					case "FONT-SIZE"	
						vFontSize = CLng( vStyleValue)
				end select
				if Err then 
					oExelApp.Quit
					set oExelApp = Nothing
					alert "Ошибка при обработке стиля: [" & aStyle(i) & "]" & vbNewLine & "возможно задано неверное значение параметра, либо данный формат задания параметров не поддерживается механизмом экспорта в Excel..." & _
						 vbNewLine & Err.Description
					ReportStatus "При обработке стиля: [" & aStyle(i) & "]  произошла ошибка."
					exit sub
				end if
			end if
		next
		' Потом назначим эти стили ячейкам...
		for each oTD in oXmlData.selectNodes("TABLE/*/TR/TD[@CLASS='" & oStyle.getAttribute("NAME") & "']")
			with oTD
				if not IsNull(vAlign) then .setAttribute "ALIGN", vAlign
				if not IsNull(vVAlign) then .setAttribute "VALIGN", vVAlign
				if not IsNull(vColor) then .setAttribute "COLOR", vColor
				if not IsNull(vBGColor) then .setAttribute "BGCOLOR", vBGColor
				if not IsNull(vBold) then .setAttribute "BOLD", vBold 
				if not IsNull(vUnderline) then .setAttribute "UNDERLINE", vUnderline
				if not IsNull(vItalic) then .setAttribute "ITALIC", vItalic
				if not IsNull(vFontName ) then .setAttribute "FONTNAME", vFontName 
				if not IsNull(vFontSize) then .setAttribute "FONTSIZE", vFontSize
			end with
		next
	next
	' теперь проставим признаки нестандартных ячеек
	for each oTD in oXmlData.selectNodes("TABLE/*/TR/TD[@ALIGN or @VALIGN or @CLASS]")
		oTD.setAttribute "X-USE-STYLE", 1
	next
	
	' для оптимизации и пордгонки таблицы пересчитываем ширины колонок
	ReportStatus "Вычисление ширин столбцов..."
	ReDim aCols(PERCENT_SIZE)
	for i=0 to PERCENT_SIZE-1
		aCols(i) = 0
	next
	aCols(PERCENT_SIZE) = 1
	
	' получим максимально-доступную ширину таблицы
	nMaxWidth = window.screen.availWidth 
	' по всем таблицам
	for each oTable in oXmlData.selectNodes("TABLE/COLGROUP")
		nCurrentWidth = 0
		' по всем колонкам с проставленной шириной - пересчитаем в % и посчитаем их сумму
		for each oCol in oTable.selectNodes("COL[@WIDTH]")
			sWidth = oCol.getAttribute("WIDTH")
			sWidth = Split(sWidth,"%" )
			nWidth = CLng( sWidth(0) )
			if UBound(sWidth) = 0 then 
				nWidth = Clng(nWidth * PERCENT_SIZE / nMaxWidth)
			else
				nWidth = Clng(nWidth * PERCENT_SIZE / 100 )
			end if	
			if nWidth = 0 then nWidth = 1
			oCol.setAttribute "WIDTH", nWidth
			nCurrentWidth = nCurrentWidth + nWidth
		next
		' теперь получим оставшуюся ширину для распределения между колонками
		nCurrentWidth =  PERCENT_SIZE - nCurrentWidth
		' вполне возможно, что сумма по ширине превышает 100%, IE это переварит, а мы терпеть не будем !!!
		if nCurrentWidth < 0 then
			oExelApp.Quit
			set oExelApp = Nothing
			alert "В исходном отчёте некорректно проставлена ширина столбцов" & vbNewLine & "дальнейшая работа невозможна!"
			ReportStatus "При обработке ширин столбцов произошла ошибка."
			exit sub
		end if
		' теперь вычислим ширину колонок с неназначенной шириной...
		with  oTable.selectNodes("COL[not(@WIDTH)]")
			if .length > 0 then
				nWidth = Int(nCurrentWidth / .length)
				' но, возможно, мы не сможем назначить корректную ширину (места не хватит)!!!
				if nWidth = 0 then
					oExelApp.Quit
					set oExelApp = Nothing
					alert "Невозможно автоматически распределить ширину столбцов (места не хватит)" & vbNewLine & "дальнейшая работа невозможна!"
					ReportStatus "При вычислении ширин столбцов произошла ошибка."
					exit sub
				end if
				for i=0 to .length-1
					if i then
						.item(i).setAttribute "WIDTH" ,nWidth	
					else
						.item(i).setAttribute "WIDTH" ,nCurrentWidth  - nWidth*(.length-1)
					end if
				next
			end if
		end with
		' Теперь пересчитаем ширину последний раз - возможно осталось лишка
		nCurrentWidth = 0
		with  oTable.selectNodes("COL")
			for i=0 to .length-1
				nCurrentWidth = nCurrentWidth + CLng(.item(i).getAttribute("WIDTH"))
			next
			nCurrentWidth = PERCENT_SIZE - nCurrentWidth
			if nCurrentWidth > 0 then 
				nWidth = Int( nCurrentWidth / .length)
				for i=0 to .length-1
					if i then
						.item(i).setAttribute "WIDTH" ,nWidth + CLng(.item(i).getAttribute("WIDTH"))	
					else
						.item(i).setAttribute "WIDTH" ,nCurrentWidth  - nWidth*(.length-1) + CLng(.item(i).getAttribute("WIDTH"))
					end if
				next
			end if
		end with
		
		nWidth = 0
		' теперь проставим в массиве границы колонок
		for each oCol in oTable.selectNodes("COL")
			nWidth = nWidth + CLng(oCol.getAttribute("WIDTH"))
			if nWidth <= PERCENT_SIZE then
				aCols(nWidth) = 1
			else
				oExelApp.Quit
				set oExelApp = Nothing
				alert "Невозможно автоматически распределить ширину столбцов (места не хватит)" & vbNewLine & "возможно ваш отчёт содержит слишком много колонок" & vbNewLine & "дальнейшая работа невозможна!"
				ReportStatus "При вычислении ширин столбцов произошла ошибка."
				exit sub
			end if	
		next
	next
	
	' подсчитываем общее количество колонок в результирующей таблице
	nTotalCols = 0
	for i=0 to PERCENT_SIZE
		nTotalCols = nTotalCols + aCols(i)
	next
	
	if nTotalCols > xlMaxColCount  then
		oExelApp.Quit
		set oExelApp = Nothing
		Alert "Число колонок в данном отчёте больше максимально допустимого в Excel"
	    ReportStatus "Экспорт в Excel невозможен ввиду ограничений на предельное число столбцов в отчёте."
		exit sub
	end if	
	
	' Экспорт в Excel...
	ReportStatus "Инициализация рабочей книги Excel..."
	set oBook =  oExelApp.WorkBooks.Add( xlWBATWorksheet)
	if Err then
		oExelApp.Quit
		set oExelApp = Nothing
		alert "Невозможно создать рабочую книгу Excel " & vbNewLine & "дальнейшая работа невозможна!" & _
			 vbNewLine & Err.Description
		ReportStatus "При создании рабочей книги Excel произошла ошибка."
		exit sub
	end if
	ReportStatus "Инициализация страницы рабочей книги Excel..."
	set oSheet = oBook.Worksheets.Item( 1)
	if Err then
		set oBook = Nothing
		oExelApp.Quit
		set oExelApp = Nothing
		alert "Невозможно создать страницу рабочей книги Excel " & vbNewLine & "дальнейшая работа невозможна!" & _
			 vbNewLine & Err.Description
		ReportStatus "При создании страницы рабочей книги Excel произошла ошибка."
		exit sub
	end if
	oSheet.Name = "Отчет"
	oSheet.Activate	
	nCol = 1
	nWidth = 0
	'Определим максимально-возможную высоту строки
	ReportStatus "Определение максимальной высоты строки"
	nMaxRowHeight = 0
	set vBold = oSheet.Rows(1)
	vItalic = vBold.RowHeight
	for i=1 to 1000 step 100
		vBold.RowHeight = i 
		if Err then
			Err.Clear
			exit for
		else	
			nMaxRowHeight = i
		end if	
	next
	for i=nMaxRowHeight to 1000 step 10
		vBold.RowHeight = i 
		if Err then
			Err.Clear
			exit for
		else	
			nMaxRowHeight = i
		end if	
	next
	for i=nMaxRowHeight to 1000 step 1
		vBold.RowHeight = i 
		if Err then
			Err.Clear
			exit for
		else	
			nMaxRowHeight = i
		end if	
	next
	vBold.RowHeight = vItalic

	ReportStatus "Задание ширин колонок..."
	
	'Назначаем ширины колонок в Excel
	for i=0 to PERCENT_SIZE
		if aCols(i) then
			oSheet.Columns(nCol).ColumnWidth = (i - nWidth)*nMaxWidth/( PERCENT_SIZE*WIDTH_RATIO) 
			if Err then
				alert "Невозможно установить ширину колонки Excel "  &  nCol  & " -> " & (i - nWidth)*nMaxWidth/( PERCENT_SIZE*WIDTH_RATIO) & vbNewLine & Err.Description 
				Err.Clear 
			end if
			nWidth = i
			nCol = nCol +1
		end if
	next
	
	' Задаём начальное значение счётчика строк...
	nRow = 1
	
	' Хардкодим заголовок таблицы
	ReportStatus "Формирование заголовка отчёта..."
	' Получение имени приложения
	sCell = ""
	with oXmlData.selectNodes("APPNAME")
		if .length > 0 then sCell = .item(0).text
	end with
	nTableStartRow = nRow 
	if Len(sCell) then
		with oSheet.Range(oSheet.Cells(nRow ,1),oSheet.Cells(nRow ,nTotalCols))
			.Merge
			.WrapText = true
			.NumberFormat = "General"
			.Value = sCell 
			.HorizontalAlignment = xlHAlignCenter 
			.VerticalAlignment = xlVAlignCenter
			with .Font
				.Size = APPNAME_FONT_SIZE
				.Name = FONT_NAME 
				.Color = RGB(255,255,255)
				.Bold = true
			end with	
			.Interior.Color = RGB(0,51,0)
		end with
		set oCell = document.all("AutoReportRow_APPNAME",0)
		if not (oCell is Nothing) then
			vBold = oCell.offsetHeight/HEIGHT_RATIO
			with oSheet.Rows(nRow)
				if .RowHeight < vBold then .RowHeight = vBold
			end with
		end if
		nRow = nRow + 1
	end if

	' Получение заголовка
	sCell = ""
	with oXmlData.selectNodes("TITLE")
		for i=0 to .length -1
			if i=0 then
				sCell = .item(i).text
			else
				sCell = sCell & vbLf & .item(i).text
			end if
		next
	end with

	if Len(sCell ) then
		with oSheet.Range(oSheet.Cells(nRow ,1),oSheet.Cells(nRow ,nTotalCols))
			.Merge
			.WrapText = true
			.NumberFormat = "General"			
			.Value = sCell 
			.HorizontalAlignment = xlHAlignCenter 
			.VerticalAlignment = xlVAlignCenter
			with .Font
				.Size = HEAD_FONT_SIZE 
				.Name = FONT_NAME 
				.Bold = true
			end with	
			.Interior.Color = RGB(252,253,225)
		end with	
		set oCell = document.all("AutoReportRow_TITLES",0)
		if not (oCell is Nothing) then
			vBold = oCell.offsetHeight/HEIGHT_RATIO
			with oSheet.Rows(nRow)
				if .RowHeight < vBold then .RowHeight = vBold
			end with
		end if
		nRow  = nRow + 1
	end if
	
	' включим границы у таблицы заголовка
	with oSheet.Range(oSheet.Cells(nTableStartRow,1),oSheet.Cells(nRow-1 ,nTotalCols))
		with .Borders(xlEdgeBottom)
			.LineStyle = xlContinuous
			.Weight = xlThin
		end with
		with .Borders(xlEdgeRight)
			.LineStyle = xlContinuous
			.Weight = xlThin
		end with
		with .Borders(xlEdgeLeft)
			.LineStyle = xlContinuous
			.Weight = xlThin
		end with
		with .Borders(xlEdgeTop)
			.LineStyle = xlContinuous
			.Weight = xlThin
		end with
	end with	

	if Err then
		alert "Ошибка при формировании шапки таблицы" & vbNewLine & Err.Description
		Err.Clear 
	end if

	' Пустая строка для красоты...
	oSheet.Range(oSheet.Cells(nRow ,1),oSheet.Cells(nRow ,nTotalCols)).RowHeight = 3
	nRow = nRow + 1

	ReportStatus "Формирование тела отчёта..."

	' Могли встретить EMPTYBODY
	sCell = ""
	with oXmlData.selectNodes("EMPTYBODY")
		for i=0 to .length -1
			if i=0 then
				sCell = " " & .item(i).text
			else
				sCell = sCell & vbLf & .item(i).text
			end if
		next
	end with

	if Len(sCell ) then
		with oSheet.Range(oSheet.Cells(nRow ,1),oSheet.Cells(nRow ,nTotalCols))
			.Merge
			.WrapText = true
			.NumberFormat = "@"			
			' Если это число, то записываем в ячейку '="число"', для того, чтобы не портились большие числа.
			if IsNumeric( sCell) then
				.Value = "=""" & sCell & """"
			elseif InStr(1,sCell,"=") then
				.Value = "'" & sCell
			elseif 	InStr(1,sCell,"'") then 
				.Value = "'" & sCell
			else	
				.Value = sCell 
			end if
			nRow  = nRow + 1
			.HorizontalAlignment = xlHAlignCenter 
			.VerticalAlignment = xlVAlignCenter
			with .Font
				.Size = HEAD_FONT_SIZE 
				.Name = FONT_NAME 
				.Bold = true
			end with	
			.Interior.Color = RGB(252,253,225)
			with .Borders(xlEdgeBottom)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeRight)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeLeft)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeTop)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
		end with	
	end if

	' Оценим общее количество ячеек для обработки...
	nTotalTDCount = oXmlData.selectNodes("TABLE/*/TR/TD").length
	nCurrentTD = 0 
	nTableRow  = 0

	for each oTable in oXmlData.selectNodes("TABLE[*/TR]")
		nTableStartRow = nRow 
		nTableRowCount = nRow
		' проставим фоновые цвета на всё
		for each oRowGroup in oTable.selectNodes("*[TR]")
			' получим кол-во строк в таблице
			nRowGroupLen = oRowGroup.selectNodes("TR").length
			' назначим цвет фона
			with oSheet.Range(oSheet.Cells(nTableRowCount,1),oSheet.Cells(nTableRowCount + nRowGroupLen -1 ,nTotalCols)).Interior
				select case UCase(oRowGroup.TagName)
					case "THEAD" : .Color = RGB(220,220,220)
					case "TBODY" : .Color = RGB(255,255,255)
					case "TFOOT" : .Color = RGB(255,204,153)
				end select
			end with
			nTableRowCount = nTableRowCount + nRowGroupLen 
		next
		' теперь включим рамки и проставим основные свойства по умолчанию...
		with oSheet.Range(oSheet.Cells(nTableStartRow,1),oSheet.Cells(nTableRowCount-1 ,nTotalCols))
			.HorizontalAlignment = xlHAlignLeft 
			.VerticalAlignment = xlVAlignCenter 
			.WrapText = true
			.NumberFormat = "General"
			with .Font
				.Name = FONT_NAME
				.Size = BODY_FONT_SIZE
				.Bold = false
				.Underline = xlUnderlineStyleNone 
				.Color = RGB(0,0,0)
			end with
			with .Borders(xlEdgeBottom)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeRight)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeLeft)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			with .Borders(xlEdgeTop)
				.LineStyle = xlContinuous
				.Weight = xlThin
			end with
			if nTableStartRow <> (nTableRowCount-1) then
				with .Borders(xlInsideHorizontal)
					.LineStyle = xlContinuous
					.Weight = xlThin
				end with
			end if
			if 	nTotalCols > 1 then
				with .Borders(xlInsideVertical)
					.LineStyle = xlContinuous
					.Weight = xlThin
				end with
			end if	
		end with	

		' Получаем кол-во ячеек строке таблицы
		with oTable.selectNodes("COLGROUP/COL")
			' Выделяем память для хранения признаков "Хитрых Ячеек" (COLSPAN & ROWSPAN) и позиций ячеек в таблице Excel
			nTableTD = .length-1
			ReDim aRows( 4, nTableTD) 
			' И инициализируем массив
			nCurrentWidth = 0
			nOffset		= 0
			for i=0 to .length-1
				aRows(0,i) = 0
				aRows(1,i) = 0
				aRows(2,i) = GetColName ( nOffset + 1)
				for j = nCurrentWidth+1 to nCurrentWidth + CLng(.item(i).getAttribute("WIDTH"))
					nOffset = nOffset + aCols(j)
				next
				nCurrentWidth  = CLng(.item(i).getAttribute("WIDTH")) + nCurrentWidth 
				aRows(3,i) = GetColName ( nOffset)
				aRows(4,i) = (aRows(2,i) <> aRows(3,i))
			next
		end with

		nTableStartRow = nRow 
		for each oTR in oTable.selectNodes("*/TR")
			with oTR.selectNodes("TD")
				' Задаём начальное значение счётчика столбцов
				nCol = 0
				for i=0 to .length-1
					' Вычислим позицию ячейки в исходной таблице
					while (aRows(0,nCol) > 0) and (nCol <= nTableTD)
						nCol = nCol + aRows(1,nCol)
					wend
					
					set oTD = .item(i)
					
					with oTD
						' Теперь проанализируем у ячейки COLSPAN и ROWSAPN 
						nColSpan = .getAttribute("COLSPAN")
						if IsNull(nColSpan) then 
							nColSpan = 1
						else
							nColSpan = CLng(nColSpan)
						end if
						nRowSpan = 	nTableTD - nCol + 1
						' Пытаемся пофиксить некорректные ColSpan-ы
						if nColSpan > nRowSpan  then
							nColSpan = nRowSpan 
						end if
					
						nRowSpan = .getAttribute("ROWSPAN")
						if IsNull(nRowSpan) then 
							nRowSpan = 1
						else
							nRowSpan = CLng(nRowSpan)
						end if
					
						' И занесём в массив
						if nRowSpan > 1 then
							 aRows(0,nCol) = nRowSpan 
							 aRows(1,nCol) = nColSpan 
						end if
					end with	
					' Получим значение ячейки
					if oTD.hasChildNodes then
						sCell = GetCellText(oTD)
					else
						sCell = oTD.text
					end if
					' Теперь поимеем "Ячейку" таблицы Excel
					set oCell = oSheet.Range( aRows(2,nCol) & nRow & ":" & aRows(3,nCol + nColSpan -1) & (nRow + nRowSpan - 1) ) 
					' Если она состоит из нескольких ячеек - объединим
					if aRows(4,nCol)  or (nColSpan >1) or (nRowSpan > 1) then oCell.Merge
					if not IsNull(oTD.getAttribute("X-USE-STYLE")) then
						' Получим стили
						with oTD
							vAlign			= .getAttribute("ALIGN")
							vVAlign			= .getAttribute("VALIGN")
							vColor			= .getAttribute("COLOR")
							vBGColor		= .getAttribute("BGCOLOR")
							vBold			= .getAttribute("BOLD")
							vUnderline		= .getAttribute("UNDERLINE")
							vItalic			= .getAttribute("ITALIC")
							vFontName		= .getAttribute("FONTNAME")
							vFontSize		= .getAttribute("FONTSIZE")
						end with
						' И наложим их...
						with oCell
							if not IsNull(vAlign) then
								select case vAlign
									case "RIGHT"			: .HorizontalAlignment = xlHAlignRight
									case "CENTER"			: .HorizontalAlignment = xlHAlignCenter
									case "JUSTIFY"			: .HorizontalAlignment = xlHAlignJustify
								end select 
							end if
							if not IsNull(vVAlign) then
								select case vVAlign
									case "TOP"				: .VerticalAlignment = xlVAlignTop 
									case "BOTTOM"			: .VerticalAlignment = xlVAlignBottom 
									case "JUSTIFY"			: .VerticalAlignment = xlVAlignJustify 
								end select 
							end if
							if not IsNull(vBGColor)		then  .Interior.Color = Clng(vBGColor)
							if not IsNull(vColor)		then  .Font.Color = Clng(vColor)
							if not IsNull(vFontName)	then  .Font.Name = vFontName
							if not IsNull(vFontSize)	then  .Font.Size = CLng(vFontSize)
							if not IsNull(vBold)		then  .Font.Bold = true
							if not IsNull(vUnderline)	then  .Font.Underline = xlUnderlineStyleSingle
							if not IsNull(vItalic)		then  .Font.Italic = true
						end with
					end if
					' И занесём в неё значение

					' Если это число, то записываем в ячейку '="число"', для того, чтобы не портились большие числа.
					if IsNumeric( sCell) then
						oCell.Value = "=""" & sCell & """"
					elseif InStr(1,sCell,"=") then
						oCell.Value = "'" & sCell
					elseif 	InStr(1,sCell,"'") then 
						oCell.Value = "'" & sCell
					else	
						oCell.Value = sCell 
					end if

					nCol = nCol + nColSpan 
					nCurrentTD = nCurrentTD + 1
					if nCol > nTableTD then exit for
				next
			end with
			' попытаемся получить высоту строки из HTML, отрендерённого IE
			set oCell = document.all("AutoReportRow_" & nTableRow , 0)
			if not (oCell is Nothing) then
				vBold = oCell.offsetHeight/HEIGHT_RATIO
				if vBold > nMaxRowHeight then vBold = nMaxRowHeight 
				with oSheet.Rows(nRow)
					if .RowHeight < vBold then .RowHeight = vBold
				end with
			end if	 
			nRow = nRow +1
			nTableRow = nTableRow + 1
			for i=0 to nTableTD 
				if aRows(0, i) > 0 then	aRows(0, i) = aRows(0, i) - 1
			next
			ReportStatus "Формирование тела отчёта... ( " & FormatPercent(nCurrentTD/nTotalTDCount , 0) & ")"
		next
	next

	if Err then
		alert "Ошибка при формировании тела отчёта"  & vbNewLine & Err.Description
		Err.Clear 
	end if

	' Пустая строка для красоты...
	oSheet.Range(oSheet.Cells(nRow ,1),oSheet.Cells(nRow ,nTotalCols)).RowHeight = 3
	nRow = nRow + 1

	' Генерация подвала
	ReportStatus "Формирование подвала отчета..."
	with oSheet.Range(oSheet.Cells(nRow ,1),oSheet.Cells(nRow ,nTotalCols))
		.Merge
		.WrapText = true
		.NumberFormat = "@"			
		.Value = "Отчет составлен " & FormatDateTime (Now(), vbLongDate) & " в " & FormatDateTime (Now(), vbShortTime)
		.HorizontalAlignment = xlHAlignRight
		.VerticalAlignment = xlVAlignCenter
		with .Font
			.Size = BODY_FONT_SIZE 
			.Name = FONT_NAME 
		end with	
		.Interior.Color = RGB(252,253,225)
		with .Borders(xlEdgeBottom)
			.LineStyle = xlContinuous
			.Weight = xlThin
		end with
		with .Borders(xlEdgeRight)
			.LineStyle = xlContinuous
			.Weight = xlThin
		end with
		with .Borders(xlEdgeLeft)
			.LineStyle = xlContinuous
			.Weight = xlThin
		end with
		with .Borders(xlEdgeTop)
			.LineStyle = xlContinuous
			.Weight = xlThin
		end with
	end with
	nRow = nRow + 1
	if Err then
		alert "Ошибка при формировании подвала таблицы"  & vbNewLine & Err.Description
		Err.Clear 
	end if
	ReportStatus "Выполнено..."
	' Показываем Excel
	oExelApp.Visible = true
	oExelApp.WindowState = xlMinimized
	oExelApp.WindowState = xlNormal
	idStatus.style.display="none"	
end sub

' Рекурсивная функция вычисления текста ячейки для представления значения в Excel
' [in] oXmlElement - обрабатываемый элемент
const XML_NODE_TEXT		= 3		' текстовый узел
const XML_NODE_ELEMENT	= 1		' узел - элемент
function GetCellText(oXmlElement)
	dim sText		' возвращаемое значение
	dim oElement	' текущий элемент
	sText = ""
	for each oElement in oXmlElement.childNodes
		if XML_NODE_TEXT  = oElement.nodeType then 'text
			sText = sText & oElement.text
		elseif XML_NODE_ELEMENT = oElement.nodeType then 'element
			if UCase(oElement.tagName) = "BR" then
				sText = sText & vbLf
			elseif (UCase(oElement.tagName) = "P") and (Len(sText )>0) then
				sText = sText & vbLf & GetCellText(oElement)
			elseif (UCase(oElement.tagName) = "DIV") and (Len(sText )>0) then
				sText = sText & vbLf & GetCellText(oElement)
			else
			    sText = sText & GetCellText(oElement)
			end if
		end if
	next
	GetCellText= sText
end function

' Вывод строки о состояниии процесса преобразования...
' [in] sStatus - статус преобразования
sub ReportStatus( sStatus)
	idStatus.innerText = sStatus
	XService.DoEvents()
end sub

' Возвращает имя столбца для Excel
' [in] nColumn - номер столбца
const COL_LETTERS		= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const COL_LETTERS_COUNT	= 26
function GetColName(nColumn)
	dim nC2 ' Число "десятков"
	dim nC1 ' Число "единиц"
	nC2 = (nColumn -1) \ COL_LETTERS_COUNT
	nC1 = (nColumn -1) mod COL_LETTERS_COUNT
	if nC2 then
		GetColName = MID(COL_LETTERS, nC2 ,1) & MID(COL_LETTERS, nC1+1 ,1)
	else
		GetColName = MID(COL_LETTERS, nC1+1 ,1)
	end if
end function

					'%>]]>'</xsl:comment>
			</SCRIPT>

			<!-- Стандартные стили -->
			<STYLE>
				<!-- Дополнительные стили определенные пользователем-->
				<xsl:for-each select="/REPORT/STYLES/STYLE">
					.<xsl:value-of select="@NAME"/> {<xsl:value-of select="." />}
				</xsl:for-each>
				
				<!--
					Список стандартных дополнительных стилей определенных пользователем:
					DEFAULT_HEADER_STYLE - в случае его определения, накладывается на заголовоки таблиц
					DEFAULT_TABLE_STYLE - в случае его определения, накладывается на тела таблиц
					DEFAULT_FOOTER_STYLE - в случае его определения, накладывается на подвалы таблиц
				-->
								
			</STYLE>
			<!-- 
				Добавление пользовательских скриптов
				================================================
					Теперь при генерации отчёта скрипт можно добавить следующим способом:
					в момент, когда доступен вызов TStart вставить такой вызов:
					oRepGen.RawOutput "<VBScript>" & XTools.HtmlEncodeLite("тело_скрипта") & "</VBScript>"

					Все обнаруженные в теле отчёта скрипты будут добавлены в HEAD формируемого HTML-я			
			-->
			<xsl:for-each select="REPORT/VBScript">
				<script language="VBScript" type="text/vbscript">
					<xsl:comment>
						'Эта строка нужна чтобы вставляемый клиентский скрипт начинался с новой строки после HTML-комментария(!!! КРИТИЧНО !!!)
						<xsl:value-of select="."/>
						'Эта строка нужна чтобы завешение HTML-комментария не сливалось (не стояло сразу после) вставленного клиентского скрипта
					'</xsl:comment>
				</script>
			</xsl:for-each>
			
		</HEAD>
		<BODY leftMargin="2" topMargin="5" scroll="auto" CLASS="REPBODY">
			<div id="idStatus" class="noprint" style="margin-bottom:5px; display:none;font-weight:bold;font-family:MS Sans Serif;font-size:14px;text-align:left;text-indent:1cm; "></div>
			
			<!-- Организующая таблица -->
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%"><TR><TD>
			<!-- Таблица заголовка отчета -->
			<TABLE border="0" cellPadding="5" cellSpacing="1" CLASS="HTABLE" width="100%">
				<xsl:if test="REPORT/APPNAME[.!='']">
					<TR ID="AutoReportRow_APPNAME">
						<TD CLASS="APPNAME" ALIGN="CENTER" VALIGN="MIDDLE" WIDTH="100%">
							<xsl:value-of select="REPORT/APPNAME"/>
						</TD>
						<TD CLASS="APPNAME" ALIGN="RIGHT" VALIGN="TOP" WIDTH="100%">
							<img 
								src="Images/x-excel.gif" 
								border="0"  
								alt="Экспорт в Excel..."
								language="VBScript"
								onclick="DoExportToExcel()" 
								class="noprint"
								style="cursor:hand"
							/>
						</TD>
					</TR>
				</xsl:if>
				<TR ID="AutoReportRow_TITLES">
					<TD CLASS="TITLES" COLSPAN="2" ALIGN="CENTER" VALIGN="MIDDLE">
						<xsl:for-each select="REPORT/TITLE">
							<DIV>
								<xsl:apply-templates match="*">
									<!-- recursively apply this template to them -->
									<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
								</xsl:apply-templates>					
							</DIV>
						</xsl:for-each>
					</TD>
				</TR>
			</TABLE>
			
			<!-- Пустая таблица - разделитель между заголовком и отчетом -->
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
				<TR><TD WIDTH="100%"></TD></TR>
			</TABLE>
			
			<xsl:for-each select="REPORT/EMPTYBODY">
				<!-- Таблица EmptyBody -->
				<TABLE border="0" cellPadding="5" cellSpacing="1" CLASS="HTABLE"  width="100%">
					<COL ALIGN="MIDDLE"></COL>
					<TR>
						<TD CLASS="EMPTYBODY">
							<xsl:value-of select="."/>
						</TD>
					</TR>
				</TABLE>

				<!-- Пустая таблица - разделитель между заголовком и отчетом -->
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
					<TR><TD WIDTH="100%"></TD></TR>
				</TABLE>
			</xsl:for-each>
			
			<!-- Див для скроллинга -->
			<div id="scroll_div">
			<!-- Генерируем таблицу отчета -->
			<xsl:for-each select="REPORT/TABLE">
				<xsl:eval language="VBScript">OnStartTable(me)</xsl:eval>
				<TABLE border="1" BorderColor="black" cellSpacing="0" style="border-collapse:collapse;" width="100%">
					<!-- Задать класс таблицы -->

					 <xsl:if test = '@CLASS'>
						<xsl:attribute name="class"><xsl:value-of select="@CLASS" /></xsl:attribute>
					</xsl:if>
					<!-- Описание колонок -->
					<COLGROUP>
						<xsl:for-each select="COLGROUP/COL">
							<xsl:element name="COL">
								<!-- Задать горизонтальное смещение колонок -->
								 <xsl:if test = '@ALIGN'>
									<xsl:attribute name="align"><xsl:value-of select="@ALIGN" /></xsl:attribute>
								</xsl:if>
								<!-- Задать вертикальное смещение колонок -->
								<xsl:if test = '@VALIGN'>
									<xsl:attribute name="valign"><xsl:value-of select="@VALIGN" /></xsl:attribute>
								</xsl:if>
								<!-- Задать ширину колонки -->
								<xsl:if test = '@WIDTH'>
									<xsl:attribute name="width"><xsl:value-of select="@WIDTH" /></xsl:attribute>
								</xsl:if>
								<!-- Задать класс колонки -->
								<xsl:if test = '@CLASS'>
									<xsl:attribute name="class"><xsl:value-of select="@CLASS" /></xsl:attribute>
								</xsl:if>
							</xsl:element>
						</xsl:for-each>
					</COLGROUP>
					<!-- Формируем заголовок таблицы -->
					<xsl:if test="THEAD/TR">
						<THEAD class="REPHEAD">
							<xsl:for-each select="THEAD/TR">
								<TR>
									<!-- Формируем для элементов TR аттрибут ID вида AutoReportRow_xxx, 
										где ххх - номер строки. В дальнейшем ID строки будет использоваться при импорте
										в Excel для вычисления высоты строки.
									 -->
									<xsl:attribute name="ID">AutoReportRow_<xsl:eval>GetRowNum()</xsl:eval></xsl:attribute>
									<xsl:for-each select="./TD">
										<xsl:element name="TD">
											<xsl:if test='@ROWSPAN'>
												<xsl:attribute name="ROWSPAN"><xsl:value-of select="@ROWSPAN" /></xsl:attribute>
											</xsl:if>
											<xsl:if test='@COLSPAN'>
												<xsl:attribute name="COLSPAN">	<xsl:value-of select="@COLSPAN" /></xsl:attribute>
											</xsl:if>

											<!-- определяем стиль, наклыдываемый на заголовок -->
											<xsl:choose>
												<xsl:when test = '@CLASS'>
													<!-- в случае, если стиль указан явно -->
													<xsl:attribute name="class">
														<xsl:value-of select="@CLASS" />							
													</xsl:attribute>
												</xsl:when>
												<xsl:otherwise>												
													<!-- 
														В случае, если стиль НЕ указан явно,
														пытаемся наложить стиль DEFAULT_HEADER_STYLE.
														В случае если такой стиль не был определен,
														использоваться буде стиль REPHEAD...
													-->
													<xsl:attribute name="class">DEFAULT_HEADER_STYLE</xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>		
																					
											<xsl:if test='@ALIGN'>
												<xsl:attribute name="align"><xsl:value-of select="@ALIGN" /></xsl:attribute>
											</xsl:if>
											<xsl:if test='@VALIGN'>
												<xsl:attribute name="valign"><xsl:value-of select="@VALIGN" /></xsl:attribute>
											</xsl:if>
											<!-- Копирование элементов TD целиком -->
											<xsl:apply-templates match="*">
												<!-- recursively apply this template to them -->
												<!-- НЕ ПЕРЕФОРМАТИРОВЫВАТЬ, А ТО ЛИШНИЕ ПЕРЕВОДЫ СТРОК ПРУТ !!!! -->
												<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
											</xsl:apply-templates>
										</xsl:element>

									</xsl:for-each>
								</TR>
							</xsl:for-each>
						</THEAD>
					</xsl:if>	
					<!-- Формируем тело отчета -->
					<TBODY class="REPBODY">
						<xsl:for-each select="TBODY/TR">
								<xsl:if language="VBScript" expr="OnCheckDuplicateHeader()">
									<!-- Формируем заголовок таблицы (Дубль) REPHEAD -->
									<THEAD class="REPHEAD_noprint">
										<xsl:for-each select="../../THEAD/TR">
											<TR>
												<xsl:for-each select="./TD">
													<xsl:element name="TD">
														<xsl:if test='@ROWSPAN'>
															<xsl:attribute name="ROWSPAN"><xsl:value-of select="@ROWSPAN" /></xsl:attribute>
														</xsl:if>
														<xsl:if test='@COLSPAN'>
															<xsl:attribute name="COLSPAN">	<xsl:value-of select="@COLSPAN" /></xsl:attribute>
														</xsl:if>

														<!-- определяем стиль, наклыдываемый на заголовок -->
														<xsl:choose>
															<xsl:when test = '@CLASS'>
																<!-- в случае, если стиль указан явно -->
																<xsl:attribute name="class">
																	<xsl:value-of select="@CLASS" />							
																</xsl:attribute>
															</xsl:when>
															<xsl:otherwise>
																<!-- 
																	В случае, если стиль НЕ указан явно,
																	пытаемся наложить стиль DEFAULT_HEADER_STYLE.
																	В случае если такой стиль не был определен,
																	использоваться буде стиль REPHEAD...
																-->															
																<xsl:attribute name="class">DEFAULT_HEADER_STYLE</xsl:attribute>
															</xsl:otherwise>
														</xsl:choose>																
														<xsl:if test='@ALIGN'>
															<xsl:attribute name="align"><xsl:value-of select="@ALIGN" /></xsl:attribute>
														</xsl:if>
														<xsl:if test='@VALIGN'>
															<xsl:attribute name="valign"><xsl:value-of select="@VALIGN" /></xsl:attribute>
														</xsl:if>
														<!-- Копирование элементов TD целиком -->
														<xsl:apply-templates match="*">
															<!-- recursively apply this template to them -->
															<!-- НЕ ПЕРЕФОРМАТИРОВЫВАТЬ, А ТО ЛИШНИЕ ПЕРЕВОДЫ СТРОК ПРУТ !!!!ц -->
															<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
														</xsl:apply-templates>
													</xsl:element>
												</xsl:for-each>
											</TR>
										</xsl:for-each>
									</THEAD>
								</xsl:if>
								
								<xsl:element name="TR">
									<!-- Формируем для элементов TR аттрибут ID вида AutoReportRow_xxx, 
										где ххх - номер строки. В дальнейшем ID строки будет использоваться при импорте
										в Excel для вычисления высоты строки.
									 -->								
									<xsl:attribute name="ID">AutoReportRow_<xsl:eval>GetRowNum()</xsl:eval></xsl:attribute>
									<xsl:if test='@HEIGHT'>
										<xsl:attribute name="HEIGHT"><xsl:value-of select="@HEIGHT" /></xsl:attribute>
									</xsl:if>
									<xsl:if test='@CLASS'>
										<xsl:attribute name="CLASS"><xsl:value-of select="@CLASS" /></xsl:attribute>
									</xsl:if><!--OnCheckDuplicateHeader-->
									<xsl:for-each select="./TD">
										<xsl:element name="TD">
											<xsl:if test='@ROWSPAN'>
												<xsl:attribute name="ROWSPAN"><xsl:value-of select="@ROWSPAN" /></xsl:attribute>
											</xsl:if>
											<xsl:if test='@COLSPAN'>
												<xsl:attribute name="COLSPAN">	<xsl:value-of select="@COLSPAN" /></xsl:attribute>
											</xsl:if>

											<!-- определяем стиль, наклыдываемый на тело таблицы -->
											<xsl:choose>
												<xsl:when test = '@CLASS'>
													<!-- в случае, если стиль указан явно -->
													<xsl:attribute name="class">
														<xsl:value-of select="@CLASS" />							
													</xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<!-- 
														В случае, если стиль НЕ указан явно,
														пытаемся наложить стиль DEFAULT_TABLE_STYLE.
														В случае если такой стиль не был определен,
														использоваться буде стиль REPBODY...
													-->												
													<xsl:attribute name="class">DEFAULT_TABLE_STYLE</xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>					
											
											<xsl:if test='@ALIGN'>
												<xsl:attribute name="align"><xsl:value-of select="@ALIGN" /></xsl:attribute>
											</xsl:if>
											<xsl:if test='@VALIGN'>
												<xsl:attribute name="valign"><xsl:value-of select="@VALIGN" /></xsl:attribute>
											</xsl:if>
											<!-- Копирование элементов TD целиком -->
											<xsl:apply-templates match="*">
												<!-- recursively apply this template to them -->
												<!-- НЕ ПЕРЕФОРМАТИРОВЫВАТЬ, А ТО ЛИШНИЕ ПЕРЕВОДЫ СТРОК ПРУТ !!!!ц -->
												<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
											</xsl:apply-templates>
										</xsl:element>
									</xsl:for-each>
								</xsl:element>
						</xsl:for-each> 
					</TBODY>
					<xsl:if test="TFOOT/TR">
						<!-- Формируем низ таблицы -->
						<TFOOT class="REPFOOT">
							<xsl:for-each select="TFOOT/TR">
								<TR>
									<!-- Формируем для элементов TR аттрибут ID вида AutoReportRow_xxx, 
										где ххх - номер строки. В дальнейшем ID строки будет использоваться при импорте
										в Excel для вычисления высоты строки.
									 -->								
									<xsl:attribute name="ID">AutoReportRow_<xsl:eval>GetRowNum()</xsl:eval></xsl:attribute>
									<xsl:for-each select="./TD">
										<xsl:element name="TD">
											<xsl:if test='@ROWSPAN'>
												<xsl:attribute name="ROWSPAN"><xsl:value-of select="@ROWSPAN" /></xsl:attribute>
											</xsl:if>
											<xsl:if test='@COLSPAN'>
												<xsl:attribute name="COLSPAN">	<xsl:value-of select="@COLSPAN" /></xsl:attribute>
											</xsl:if>
											
											<!-- определяем стиль, наклыдываемый на подвал таблицы -->
											<xsl:choose>
												<xsl:when test = '@CLASS'>
													<!-- в случае, если стиль указан явно -->
													<xsl:attribute name="class">
														<xsl:value-of select="@CLASS" />							
													</xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<!-- 
														В случае, если стиль НЕ указан явно,
														пытаемся наложить стиль DEFAULT_FOOTER_STYLE.
														В случае если такой стиль не был определен,
														использоваться буде стиль REPFOOT...
													-->												
													<xsl:attribute name="class">DEFAULT_FOOTER_STYLE</xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>											
											<xsl:if test='@ALIGN'>
												<xsl:attribute name="align"><xsl:value-of select="@ALIGN" /></xsl:attribute>
											</xsl:if>
											<xsl:if test='@VALIGN'>
												<xsl:attribute name="valign"><xsl:value-of select="@VALIGN" /></xsl:attribute>
											</xsl:if>
											<!-- Копирование элементов TD целиком -->
											<xsl:apply-templates match="*">
												<!-- recursively apply this template to them -->
												<!-- НЕ ПЕРЕФОРМАТИРОВЫВАТЬ, А ТО ЛИШНИЕ ПЕРЕВОДЫ СТРОК ПРУТ !!!!ц -->
												<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
											</xsl:apply-templates>
										</xsl:element>
									</xsl:for-each>
								</TR>
							</xsl:for-each>
						</TFOOT>
					</xsl:if>	
				</TABLE>
				<!-- Пустая таблица - разделитель между отчетом и подвалом -->
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
					<TR><TD WIDTH="100%"></TD></TR>
				</TABLE>
			</xsl:for-each>
			</div>

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
			<object
			classid="clsid:31A948DA-9A04-4A95-8138-3B62E9AB92FC"
			type="application/x-oleobject"
			STYLE="display:none"
			name = "XService">
			</object>
			<OBJECT 
			classid="CLSID:5D303927-4DED-454B-828B-389A87DE4B7E"
			type="application/x-oleobject"
			style="DISPLAY: none; LEFT: 0px; TOP: 0px"
			name="PopUp">
			</OBJECT>
		</BODY>
	</HTML>
</xsl:template>

</xsl:stylesheet>
