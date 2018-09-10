<?xml version="1.0" encoding="windows-1251"?>
<!-- 
	���� ����� ��� ����������� ������ �� XML-�����, ������������ ReportGenerator'��.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">
<xsl:script language="VBScript"><![CDATA[ 
	''>
	dim g_nCurrentRow	' ���������� ���������� - ����� ������� ������ ������� ������...
	' ������� ���������� ����� ������ ������� ������� ������... >
    Function GetRowNum()
		if IsEmpty(g_nCurrentRow) then
			g_nCurrentRow = 0
		else
			g_nCurrentRow = g_nCurrentRow+1	
		end if	
		GetRowNum = g_nCurrentRow 
    End Function
    
    ' ����������� �������� CSS,������������ � ������� � ����������� ������� ������������ ��������� � ���� �������...
    const CSS_FIX_SELECTOR = "croc-duplicate-header"
    
    dim g_nTableFixDist	' ���������� ���������� - ����� �����, ����� ������� ���� ����������� ��������� �������...
    dim g_nTableBodyRow ' ���������� ���������� - ����� ������� ������ ���� ������� ������� ������
    
    ' ������������� ���������� ��� ������ ��������� �������
    ' oTable [in] - ������ �������
    Function OnStartTable(oTable)
		dim vClass	' ����� �������
		dim oStyle	' ����� ������� (������)
		dim sStyle	' ����� ������� (������)
		dim nOffset ' �������� � �����
		dim aTmp	' ��������� ������, ���������� ��������� Split ��� ������� �� ������
		
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
    
    ' �������� �� ������������� ������� ��������� ��������� �������
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
			<!-- ������� ��������� ���� -->
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
			<!-- ������ �� CSS -->
			<LINK href="x-report.css" rel="STYLESHEET" type="text/css"/>
			<!-- XML data island - ����� ������ ������ -->
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

' ���������� ������� "������� � Excel"
' �������������� ��������� ������������ CSS:
' background-color & color
'  ������: color:rgb(nRed,nGreen,nBlue) & background-color:rgb(nRed,nGreen,nBlue)
'     - nRed	- ������������ �������� ����� 0<= nRed <=255
'     - nGreen  - ������������ ������� ����� 0<= nGreen <=255
'     - nBlue	- ������������ ������   ����� 0<= nBlue <=255
'  ������:
'     color:rgb(0,0,0)  - ������������� ������ ���� ������
'  ! ������ ������ ������� ����� �� �������������� � ����� �������� � ������
' font-size
'  ������: font-size:nFontSize
'     - nFontSize	- ������ ������ � �������
'  ������:
'     font-size:12  - ������������� ������ ������ = 12 �������
'  ! ������ ������ ������� ������� ������ �� ��������������
'
' text-align			\
' font-weight			 \
' text-decoration         \   ��. ������������ CSS
' font-style              /
' font-family            /
' vertical-align		/
'
'	��� ��������� ��������� CSS ������������

sub DoExportToExcel
	' ����������� ��������� ������ ������� 
	const  WIDTH_RATIO	= 7.5
	' ����������� ��������� ������ ������
	const  HEIGHT_RATIO = 1.1
	' ������ ������ � ��������/�������
	const  HEAD_FONT_SIZE = 10
	' ������ ������ � APPNAME
	const  APPNAME_FONT_SIZE = 16
	' ������ ������ � ���� ���������
	const  BODY_FONT_SIZE = 8
	' ��� ������
	const  FONT_NAME = "Arial" '"Microsoft Sans Serif"
	' ������������� ������� ������ ��������
	const  PERCENT_SIZE = 500
	
	' ����������� ���������� ����� ������� � Excel
	const  xlMaxColCount = 254

	' ������ ��������� Excel-�
	const  xlWBATWorksheet = -4167
	const  xlNormal = -4143
	const  xlMinimized = -4140

	' �������������� � ������������ ������������
	const  xlHAlignCenter = -4108
	const  xlHAlignLeft = -4131
	const  xlHAlignRight = -4152
	const  xlVAlignBottom = -4107
	const  xlVAlignCenter = -4108
	const  xlVAlignJustify = -4130
	const  xlVAlignTop = -4160

	' ������� �����
	const  xlInsideHorizontal = 12
	const  xlInsideVertical = 11
	const  xlEdgeBottom = 9
	const  xlEdgeLeft = 7
	const  xlEdgeRight = 10
	const  xlEdgeTop = 8

	' ������� �����
	const  xlThin = 2

	' ����� �����
	const  xlContinuous = 1
	
	' ������������� ������
	const xlUnderlineStyleSingle = 2
	const xlUnderlineStyleNone = -4142

	dim oXmlData				' ������ � ��������� ������� ������
	dim oExelApp				' ���������� Excel.Application
	dim oSheet					' ������� Excel.Sheet
	dim oBook					' ����� Excel.Workbook
	dim aCols				    ' ������ ����� �������� ������
	dim aRows					' ������ ������������ n*5, ��� n - ����� �������� � �������������� �������
								' aRows(i,0) - ������� �������� RowSpan � ��������� i-�� ������� ������ ������
								' aRows(i,1) - ������� �������� ColSpan � ��������� i-�� ������� ������ ������
								' aRows(i,2) - ����� ������� ������� � ��������� �������� ������� Excel, ������������� �� i-� �������
								' aRows(i,3) - ����� ���������� ������� � ��������� �������� ������� Excel, ������������� �� i-� �������
								' aRows(i,4) - ������� ����, ��� ������� ������� ������ �������� ��������� �������� ������� Excel
	dim nTotalCols				' ����� ���������� �������� � ������� Excel
	dim oTable					' �������������� ������� ������	(IXMLDomElement)
	dim oCol					' �������������� ������� COL � COLGROUP � oTable
	dim nMaxWidth				' ����������� - ��������� ������ ��� ������� (� ��������)
	dim sWidth					' �������� ��������� WIDTH � oCol
	dim nWidth					' ������ �������� ������� ������� ������� ������ � %
	dim nCurrentWidth			' ������� ������
	dim nRow					' ������� ������ ������� Excel
	dim nCol					' ������� ������� ������� Excel
	dim oTR						' �������������� ������ ������� ������	(IXMLDomElement)
	dim oTD						' �������������� ������� ������ ������� ������	(IXMLDomElement)
	dim nOffset					' �������� ������ �������� ������� ������� ������� ������ � ������� ����� �������� ������� Excel
	dim nColSpan				' �������� ��������� COLSPAN � ������� ������� ������� ������
	dim nRowSpan				' �������� ��������� ROWSPAN � ������� ������� ������� ������
	dim oCell					' ������ ������� Excel
	dim nTableStartRow			' ����� ������ ������ ������� ������� ������ � ������� Excel
	dim aStyle					' ������, ���������� ���� ���� ��������_CSS : ��������_���������_CSS 
	dim aOneStyle				' ������ �� 2-� ���������, �������� �������� � ��������
								' aOneStyle(0) - ��������_CSS
								' aOneStyle(1) - ��������_���������_CSS 
	dim sOneStyleSelector		' ��������_CSS
	dim vStyleValue				' ��������_���������_CSS
	dim sStyle					' ��� ������, ���� ������ ��� ����  ��������_CSS : ��������_���������_CSS, ���������� ;
	dim oStyle					' ������� STYLE ������ (IXMLDomElement)
	dim sCell					' ���������� ������ ������� Excel
	dim nTotalTDCount			' ����� ���������� ����� �� ���� �������� �������
	dim nCurrentTD				' ������� ����� ��� ����������
	dim nTableTD				' ����� ����� � ������� - 1
	dim oRowGroup				' ��������� ����� ������� (THEAD ��� TBODY ��� TFOOT) (IXMLDomElement)
	dim nRowGroupLen			' ����� ����� � oRowGroup
	dim vColor					' ���� ������
	dim vBGColor				' ���� ����
	dim vFontName				' ��� ������
	dim vFontSize				' ������ ������
	dim vAlign					' �������������� ������������
	dim vVAlign					' ������������ ������������
	dim vUnderline				' ������� �������������
	dim vItalic					' ������� �����������
	dim vBold					' ������� �������� ������
	dim nTableRowCount			' ����� ����� � ������� ������
	dim nTableRow				' ������� ������ ������� ������
	dim nMaxRowHeight			' �����������-���������� ������ ������...
	dim i,j						
	
	on error resume next
	'������� ������ �������...
	idStatus.style.display = "block"
	' ��������� ������ � ������������� ������ ����� ������� � ���������� ������ �������...
	ReportStatus  "��������� �������� ������..."
	set oXmlData = CreateObject("MSXML2.FreeThreadedDOMDocument.3.0")
	oXmlData.loadXML "<?xml version='1.0' encoding='windows-1251' ?>" & xmlReportData.XmlDocument.xml
	set oXmlData = oXmlData.documentElement 
	' ������� ������� Excel...
	ReportStatus "������������ ����� � Microsoft Excel..."
	set oExelApp = XService.CreateObject("Excel.Application")
	if Err then
	    Alert "���������� ���������� ����� � Microsoft Excel. �������� �� �� ����������, ���� ��������� ������������ ������������ �������������� � ���..." & _
			 vbNewLine & Err.Description
	    ReportStatus "��� ������� ���������� ����� � Microsoft Excel ��������� ������."
		exit sub
	end if
	' ��������������� ��������� ������
	ReportStatus "������� ������..."
	' ������� ������...
	for each oStyle in oXmlData.selectNodes("STYLES/STYLE[@NAME]")
		' ������� ��������� ������� ����� � ������ �������������� ��������� � ����������
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
					alert "������ ��� ��������� �����: [" & aStyle(i) & "]" & vbNewLine & "�������� ������ �������� �������� ���������, ���� ������ ������ ������� ���������� �� �������������� ���������� �������� � Excel..." & _
						 vbNewLine & Err.Description
					ReportStatus "��� ��������� �����: [" & aStyle(i) & "]  ��������� ������."
					exit sub
				end if
			end if
		next
		' ����� �������� ��� ����� �������...
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
	' ������ ��������� �������� ������������� �����
	for each oTD in oXmlData.selectNodes("TABLE/*/TR/TD[@ALIGN or @VALIGN or @CLASS]")
		oTD.setAttribute "X-USE-STYLE", 1
	next
	
	' ��� ����������� � ��������� ������� ������������� ������ �������
	ReportStatus "���������� ����� ��������..."
	ReDim aCols(PERCENT_SIZE)
	for i=0 to PERCENT_SIZE-1
		aCols(i) = 0
	next
	aCols(PERCENT_SIZE) = 1
	
	' ������� �����������-��������� ������ �������
	nMaxWidth = window.screen.availWidth 
	' �� ���� ��������
	for each oTable in oXmlData.selectNodes("TABLE/COLGROUP")
		nCurrentWidth = 0
		' �� ���� �������� � ������������� ������� - ����������� � % � ��������� �� �����
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
		' ������ ������� ���������� ������ ��� ������������� ����� ���������
		nCurrentWidth =  PERCENT_SIZE - nCurrentWidth
		' ������ ��������, ��� ����� �� ������ ��������� 100%, IE ��� ���������, � �� ������� �� ����� !!!
		if nCurrentWidth < 0 then
			oExelApp.Quit
			set oExelApp = Nothing
			alert "� �������� ������ ����������� ����������� ������ ��������" & vbNewLine & "���������� ������ ����������!"
			ReportStatus "��� ��������� ����� �������� ��������� ������."
			exit sub
		end if
		' ������ �������� ������ ������� � ������������� �������...
		with  oTable.selectNodes("COL[not(@WIDTH)]")
			if .length > 0 then
				nWidth = Int(nCurrentWidth / .length)
				' ��, ��������, �� �� ������ ��������� ���������� ������ (����� �� ������)!!!
				if nWidth = 0 then
					oExelApp.Quit
					set oExelApp = Nothing
					alert "���������� ������������� ������������ ������ �������� (����� �� ������)" & vbNewLine & "���������� ������ ����������!"
					ReportStatus "��� ���������� ����� �������� ��������� ������."
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
		' ������ ����������� ������ ��������� ��� - �������� �������� �����
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
		' ������ ��������� � ������� ������� �������
		for each oCol in oTable.selectNodes("COL")
			nWidth = nWidth + CLng(oCol.getAttribute("WIDTH"))
			if nWidth <= PERCENT_SIZE then
				aCols(nWidth) = 1
			else
				oExelApp.Quit
				set oExelApp = Nothing
				alert "���������� ������������� ������������ ������ �������� (����� �� ������)" & vbNewLine & "�������� ��� ����� �������� ������� ����� �������" & vbNewLine & "���������� ������ ����������!"
				ReportStatus "��� ���������� ����� �������� ��������� ������."
				exit sub
			end if	
		next
	next
	
	' ������������ ����� ���������� ������� � �������������� �������
	nTotalCols = 0
	for i=0 to PERCENT_SIZE
		nTotalCols = nTotalCols + aCols(i)
	next
	
	if nTotalCols > xlMaxColCount  then
		oExelApp.Quit
		set oExelApp = Nothing
		Alert "����� ������� � ������ ������ ������ ����������� ����������� � Excel"
	    ReportStatus "������� � Excel ���������� ����� ����������� �� ���������� ����� �������� � ������."
		exit sub
	end if	
	
	' ������� � Excel...
	ReportStatus "������������� ������� ����� Excel..."
	set oBook =  oExelApp.WorkBooks.Add( xlWBATWorksheet)
	if Err then
		oExelApp.Quit
		set oExelApp = Nothing
		alert "���������� ������� ������� ����� Excel " & vbNewLine & "���������� ������ ����������!" & _
			 vbNewLine & Err.Description
		ReportStatus "��� �������� ������� ����� Excel ��������� ������."
		exit sub
	end if
	ReportStatus "������������� �������� ������� ����� Excel..."
	set oSheet = oBook.Worksheets.Item( 1)
	if Err then
		set oBook = Nothing
		oExelApp.Quit
		set oExelApp = Nothing
		alert "���������� ������� �������� ������� ����� Excel " & vbNewLine & "���������� ������ ����������!" & _
			 vbNewLine & Err.Description
		ReportStatus "��� �������� �������� ������� ����� Excel ��������� ������."
		exit sub
	end if
	oSheet.Name = "�����"
	oSheet.Activate	
	nCol = 1
	nWidth = 0
	'��������� �����������-��������� ������ ������
	ReportStatus "����������� ������������ ������ ������"
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

	ReportStatus "������� ����� �������..."
	
	'��������� ������ ������� � Excel
	for i=0 to PERCENT_SIZE
		if aCols(i) then
			oSheet.Columns(nCol).ColumnWidth = (i - nWidth)*nMaxWidth/( PERCENT_SIZE*WIDTH_RATIO) 
			if Err then
				alert "���������� ���������� ������ ������� Excel "  &  nCol  & " -> " & (i - nWidth)*nMaxWidth/( PERCENT_SIZE*WIDTH_RATIO) & vbNewLine & Err.Description 
				Err.Clear 
			end if
			nWidth = i
			nCol = nCol +1
		end if
	next
	
	' ����� ��������� �������� �������� �����...
	nRow = 1
	
	' ��������� ��������� �������
	ReportStatus "������������ ��������� ������..."
	' ��������� ����� ����������
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

	' ��������� ���������
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
	
	' ������� ������� � ������� ���������
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
		alert "������ ��� ������������ ����� �������" & vbNewLine & Err.Description
		Err.Clear 
	end if

	' ������ ������ ��� �������...
	oSheet.Range(oSheet.Cells(nRow ,1),oSheet.Cells(nRow ,nTotalCols)).RowHeight = 3
	nRow = nRow + 1

	ReportStatus "������������ ���� ������..."

	' ����� ��������� EMPTYBODY
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
			' ���� ��� �����, �� ���������� � ������ '="�����"', ��� ����, ����� �� ��������� ������� �����.
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

	' ������ ����� ���������� ����� ��� ���������...
	nTotalTDCount = oXmlData.selectNodes("TABLE/*/TR/TD").length
	nCurrentTD = 0 
	nTableRow  = 0

	for each oTable in oXmlData.selectNodes("TABLE[*/TR]")
		nTableStartRow = nRow 
		nTableRowCount = nRow
		' ��������� ������� ����� �� ��
		for each oRowGroup in oTable.selectNodes("*[TR]")
			' ������� ���-�� ����� � �������
			nRowGroupLen = oRowGroup.selectNodes("TR").length
			' �������� ���� ����
			with oSheet.Range(oSheet.Cells(nTableRowCount,1),oSheet.Cells(nTableRowCount + nRowGroupLen -1 ,nTotalCols)).Interior
				select case UCase(oRowGroup.TagName)
					case "THEAD" : .Color = RGB(220,220,220)
					case "TBODY" : .Color = RGB(255,255,255)
					case "TFOOT" : .Color = RGB(255,204,153)
				end select
			end with
			nTableRowCount = nTableRowCount + nRowGroupLen 
		next
		' ������ ������� ����� � ��������� �������� �������� �� ���������...
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

		' �������� ���-�� ����� ������ �������
		with oTable.selectNodes("COLGROUP/COL")
			' �������� ������ ��� �������� ��������� "������ �����" (COLSPAN & ROWSPAN) � ������� ����� � ������� Excel
			nTableTD = .length-1
			ReDim aRows( 4, nTableTD) 
			' � �������������� ������
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
				' ����� ��������� �������� �������� ��������
				nCol = 0
				for i=0 to .length-1
					' �������� ������� ������ � �������� �������
					while (aRows(0,nCol) > 0) and (nCol <= nTableTD)
						nCol = nCol + aRows(1,nCol)
					wend
					
					set oTD = .item(i)
					
					with oTD
						' ������ �������������� � ������ COLSPAN � ROWSAPN 
						nColSpan = .getAttribute("COLSPAN")
						if IsNull(nColSpan) then 
							nColSpan = 1
						else
							nColSpan = CLng(nColSpan)
						end if
						nRowSpan = 	nTableTD - nCol + 1
						' �������� ��������� ������������ ColSpan-�
						if nColSpan > nRowSpan  then
							nColSpan = nRowSpan 
						end if
					
						nRowSpan = .getAttribute("ROWSPAN")
						if IsNull(nRowSpan) then 
							nRowSpan = 1
						else
							nRowSpan = CLng(nRowSpan)
						end if
					
						' � ������ � ������
						if nRowSpan > 1 then
							 aRows(0,nCol) = nRowSpan 
							 aRows(1,nCol) = nColSpan 
						end if
					end with	
					' ������� �������� ������
					if oTD.hasChildNodes then
						sCell = GetCellText(oTD)
					else
						sCell = oTD.text
					end if
					' ������ ������� "������" ������� Excel
					set oCell = oSheet.Range( aRows(2,nCol) & nRow & ":" & aRows(3,nCol + nColSpan -1) & (nRow + nRowSpan - 1) ) 
					' ���� ��� ������� �� ���������� ����� - ���������
					if aRows(4,nCol)  or (nColSpan >1) or (nRowSpan > 1) then oCell.Merge
					if not IsNull(oTD.getAttribute("X-USE-STYLE")) then
						' ������� �����
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
						' � ������� ��...
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
					' � ������ � �� ��������

					' ���� ��� �����, �� ���������� � ������ '="�����"', ��� ����, ����� �� ��������� ������� �����.
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
			' ���������� �������� ������ ������ �� HTML, ������������� IE
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
			ReportStatus "������������ ���� ������... ( " & FormatPercent(nCurrentTD/nTotalTDCount , 0) & ")"
		next
	next

	if Err then
		alert "������ ��� ������������ ���� ������"  & vbNewLine & Err.Description
		Err.Clear 
	end if

	' ������ ������ ��� �������...
	oSheet.Range(oSheet.Cells(nRow ,1),oSheet.Cells(nRow ,nTotalCols)).RowHeight = 3
	nRow = nRow + 1

	' ��������� �������
	ReportStatus "������������ ������� ������..."
	with oSheet.Range(oSheet.Cells(nRow ,1),oSheet.Cells(nRow ,nTotalCols))
		.Merge
		.WrapText = true
		.NumberFormat = "@"			
		.Value = "����� ��������� " & FormatDateTime (Now(), vbLongDate) & " � " & FormatDateTime (Now(), vbShortTime)
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
		alert "������ ��� ������������ ������� �������"  & vbNewLine & Err.Description
		Err.Clear 
	end if
	ReportStatus "���������..."
	' ���������� Excel
	oExelApp.Visible = true
	oExelApp.WindowState = xlMinimized
	oExelApp.WindowState = xlNormal
	idStatus.style.display="none"	
end sub

' ����������� ������� ���������� ������ ������ ��� ������������� �������� � Excel
' [in] oXmlElement - �������������� �������
const XML_NODE_TEXT		= 3		' ��������� ����
const XML_NODE_ELEMENT	= 1		' ���� - �������
function GetCellText(oXmlElement)
	dim sText		' ������������ ��������
	dim oElement	' ������� �������
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

' ����� ������ � ���������� �������� ��������������...
' [in] sStatus - ������ ��������������
sub ReportStatus( sStatus)
	idStatus.innerText = sStatus
	XService.DoEvents()
end sub

' ���������� ��� ������� ��� Excel
' [in] nColumn - ����� �������
const COL_LETTERS		= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const COL_LETTERS_COUNT	= 26
function GetColName(nColumn)
	dim nC2 ' ����� "��������"
	dim nC1 ' ����� "������"
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

			<!-- ����������� ����� -->
			<STYLE>
				<!-- �������������� ����� ������������ �������������-->
				<xsl:for-each select="/REPORT/STYLES/STYLE">
					.<xsl:value-of select="@NAME"/> {<xsl:value-of select="." />}
				</xsl:for-each>
				
				<!--
					������ ����������� �������������� ������ ������������ �������������:
					DEFAULT_HEADER_STYLE - � ������ ��� �����������, ������������� �� ���������� ������
					DEFAULT_TABLE_STYLE - � ������ ��� �����������, ������������� �� ���� ������
					DEFAULT_FOOTER_STYLE - � ������ ��� �����������, ������������� �� ������� ������
				-->
								
			</STYLE>
			<!-- 
				���������� ���������������� ��������
				================================================
					������ ��� ��������� ������ ������ ����� �������� ��������� ��������:
					� ������, ����� �������� ����� TStart �������� ����� �����:
					oRepGen.RawOutput "<VBScript>" & XTools.HtmlEncodeLite("����_�������") & "</VBScript>"

					��� ������������ � ���� ������ ������� ����� ��������� � HEAD ������������ HTML-�			
			-->
			<xsl:for-each select="REPORT/VBScript">
				<script language="VBScript" type="text/vbscript">
					<xsl:comment>
						'��� ������ ����� ����� ����������� ���������� ������ ��������� � ����� ������ ����� HTML-�����������(!!! �������� !!!)
						<xsl:value-of select="."/>
						'��� ������ ����� ����� ��������� HTML-����������� �� ��������� (�� ������ ����� �����) ������������ ����������� �������
					'</xsl:comment>
				</script>
			</xsl:for-each>
			
		</HEAD>
		<BODY leftMargin="2" topMargin="5" scroll="auto" CLASS="REPBODY">
			<div id="idStatus" class="noprint" style="margin-bottom:5px; display:none;font-weight:bold;font-family:MS Sans Serif;font-size:14px;text-align:left;text-indent:1cm; "></div>
			
			<!-- ������������ ������� -->
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%"><TR><TD>
			<!-- ������� ��������� ������ -->
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
								alt="������� � Excel..."
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
			
			<!-- ������ ������� - ����������� ����� ���������� � ������� -->
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
				<TR><TD WIDTH="100%"></TD></TR>
			</TABLE>
			
			<xsl:for-each select="REPORT/EMPTYBODY">
				<!-- ������� EmptyBody -->
				<TABLE border="0" cellPadding="5" cellSpacing="1" CLASS="HTABLE"  width="100%">
					<COL ALIGN="MIDDLE"></COL>
					<TR>
						<TD CLASS="EMPTYBODY">
							<xsl:value-of select="."/>
						</TD>
					</TR>
				</TABLE>

				<!-- ������ ������� - ����������� ����� ���������� � ������� -->
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
					<TR><TD WIDTH="100%"></TD></TR>
				</TABLE>
			</xsl:for-each>
			
			<!-- ��� ��� ���������� -->
			<div id="scroll_div">
			<!-- ���������� ������� ������ -->
			<xsl:for-each select="REPORT/TABLE">
				<xsl:eval language="VBScript">OnStartTable(me)</xsl:eval>
				<TABLE border="1" BorderColor="black" cellSpacing="0" style="border-collapse:collapse;" width="100%">
					<!-- ������ ����� ������� -->

					 <xsl:if test = '@CLASS'>
						<xsl:attribute name="class"><xsl:value-of select="@CLASS" /></xsl:attribute>
					</xsl:if>
					<!-- �������� ������� -->
					<COLGROUP>
						<xsl:for-each select="COLGROUP/COL">
							<xsl:element name="COL">
								<!-- ������ �������������� �������� ������� -->
								 <xsl:if test = '@ALIGN'>
									<xsl:attribute name="align"><xsl:value-of select="@ALIGN" /></xsl:attribute>
								</xsl:if>
								<!-- ������ ������������ �������� ������� -->
								<xsl:if test = '@VALIGN'>
									<xsl:attribute name="valign"><xsl:value-of select="@VALIGN" /></xsl:attribute>
								</xsl:if>
								<!-- ������ ������ ������� -->
								<xsl:if test = '@WIDTH'>
									<xsl:attribute name="width"><xsl:value-of select="@WIDTH" /></xsl:attribute>
								</xsl:if>
								<!-- ������ ����� ������� -->
								<xsl:if test = '@CLASS'>
									<xsl:attribute name="class"><xsl:value-of select="@CLASS" /></xsl:attribute>
								</xsl:if>
							</xsl:element>
						</xsl:for-each>
					</COLGROUP>
					<!-- ��������� ��������� ������� -->
					<xsl:if test="THEAD/TR">
						<THEAD class="REPHEAD">
							<xsl:for-each select="THEAD/TR">
								<TR>
									<!-- ��������� ��� ��������� TR �������� ID ���� AutoReportRow_xxx, 
										��� ��� - ����� ������. � ���������� ID ������ ����� �������������� ��� �������
										� Excel ��� ���������� ������ ������.
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

											<!-- ���������� �����, ������������� �� ��������� -->
											<xsl:choose>
												<xsl:when test = '@CLASS'>
													<!-- � ������, ���� ����� ������ ���� -->
													<xsl:attribute name="class">
														<xsl:value-of select="@CLASS" />							
													</xsl:attribute>
												</xsl:when>
												<xsl:otherwise>												
													<!-- 
														� ������, ���� ����� �� ������ ����,
														�������� �������� ����� DEFAULT_HEADER_STYLE.
														� ������ ���� ����� ����� �� ��� ���������,
														�������������� ���� ����� REPHEAD...
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
											<!-- ����������� ��������� TD ������� -->
											<xsl:apply-templates match="*">
												<!-- recursively apply this template to them -->
												<!-- �� �������������������, � �� ������ �������� ����� ���� !!!! -->
												<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
											</xsl:apply-templates>
										</xsl:element>

									</xsl:for-each>
								</TR>
							</xsl:for-each>
						</THEAD>
					</xsl:if>	
					<!-- ��������� ���� ������ -->
					<TBODY class="REPBODY">
						<xsl:for-each select="TBODY/TR">
								<xsl:if language="VBScript" expr="OnCheckDuplicateHeader()">
									<!-- ��������� ��������� ������� (�����) REPHEAD -->
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

														<!-- ���������� �����, ������������� �� ��������� -->
														<xsl:choose>
															<xsl:when test = '@CLASS'>
																<!-- � ������, ���� ����� ������ ���� -->
																<xsl:attribute name="class">
																	<xsl:value-of select="@CLASS" />							
																</xsl:attribute>
															</xsl:when>
															<xsl:otherwise>
																<!-- 
																	� ������, ���� ����� �� ������ ����,
																	�������� �������� ����� DEFAULT_HEADER_STYLE.
																	� ������ ���� ����� ����� �� ��� ���������,
																	�������������� ���� ����� REPHEAD...
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
														<!-- ����������� ��������� TD ������� -->
														<xsl:apply-templates match="*">
															<!-- recursively apply this template to them -->
															<!-- �� �������������������, � �� ������ �������� ����� ���� !!!!� -->
															<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
														</xsl:apply-templates>
													</xsl:element>
												</xsl:for-each>
											</TR>
										</xsl:for-each>
									</THEAD>
								</xsl:if>
								
								<xsl:element name="TR">
									<!-- ��������� ��� ��������� TR �������� ID ���� AutoReportRow_xxx, 
										��� ��� - ����� ������. � ���������� ID ������ ����� �������������� ��� �������
										� Excel ��� ���������� ������ ������.
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

											<!-- ���������� �����, ������������� �� ���� ������� -->
											<xsl:choose>
												<xsl:when test = '@CLASS'>
													<!-- � ������, ���� ����� ������ ���� -->
													<xsl:attribute name="class">
														<xsl:value-of select="@CLASS" />							
													</xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<!-- 
														� ������, ���� ����� �� ������ ����,
														�������� �������� ����� DEFAULT_TABLE_STYLE.
														� ������ ���� ����� ����� �� ��� ���������,
														�������������� ���� ����� REPBODY...
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
											<!-- ����������� ��������� TD ������� -->
											<xsl:apply-templates match="*">
												<!-- recursively apply this template to them -->
												<!-- �� �������������������, � �� ������ �������� ����� ���� !!!!� -->
												<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
											</xsl:apply-templates>
										</xsl:element>
									</xsl:for-each>
								</xsl:element>
						</xsl:for-each> 
					</TBODY>
					<xsl:if test="TFOOT/TR">
						<!-- ��������� ��� ������� -->
						<TFOOT class="REPFOOT">
							<xsl:for-each select="TFOOT/TR">
								<TR>
									<!-- ��������� ��� ��������� TR �������� ID ���� AutoReportRow_xxx, 
										��� ��� - ����� ������. � ���������� ID ������ ����� �������������� ��� �������
										� Excel ��� ���������� ������ ������.
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
											
											<!-- ���������� �����, ������������� �� ������ ������� -->
											<xsl:choose>
												<xsl:when test = '@CLASS'>
													<!-- � ������, ���� ����� ������ ���� -->
													<xsl:attribute name="class">
														<xsl:value-of select="@CLASS" />							
													</xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<!-- 
														� ������, ���� ����� �� ������ ����,
														�������� �������� ����� DEFAULT_FOOTER_STYLE.
														� ������ ���� ����� ����� �� ��� ���������,
														�������������� ���� ����� REPFOOT...
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
											<!-- ����������� ��������� TD ������� -->
											<xsl:apply-templates match="*">
												<!-- recursively apply this template to them -->
												<!-- �� �������������������, � �� ������ �������� ����� ���� !!!!� -->
												<xsl:template><xsl:copy><xsl:apply-templates select="@* | * | comment() | pi() | text()"/></xsl:copy></xsl:template>
											</xsl:apply-templates>
										</xsl:element>
									</xsl:for-each>
								</TR>
							</xsl:for-each>
						</TFOOT>
					</xsl:if>	
				</TABLE>
				<!-- ������ ������� - ����������� ����� ������� � �������� -->
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
					<TR><TD WIDTH="100%"></TD></TR>
				</TABLE>
			</xsl:for-each>
			</div>

			<!-- ������ ������ -->
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
				<TR>
					<TD>
						<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="1" WIDTH="100%" BGCOLOR="BLACK" STYLE="font:10pt;font-family:Arial">
							<TR>
								<TD CLASS="FOOTER" ALIGN="RIGHT">
									<FONT COLOR="BLACK">
										����� ��������� <xsl:eval>FormatDateTime( Now(), 1)</xsl:eval> � <xsl:eval>FormatDateTime( Now(), 4)</xsl:eval>
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
