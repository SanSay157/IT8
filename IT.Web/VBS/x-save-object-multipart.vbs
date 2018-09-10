'<SCRIPT LANGUAGE="VBScript">
Option Explicit
const TIMEOUT	= 1			' таймаут ожидания при переходе к следующему пакету
const IGNORED_STRING_SIZE=5 ' Если размер строку меньше заданного числа то и бог с ним
const MAX_STRING_SIZE=4000	' Строки большей длины есть BLOB-ы
const MIN_POST_SIZE = 1024	' Минимальный объём для передачи на сервер
const RETRY_COUNT = 32		' Количестово повторов при подборе размера пересылаемого блока
const RETRY_TIMEOUT = 30	' сколько будем ждать перед тем как автоматически подтвердим следующую попытку

dim g_oObjectEditor         ' As ObjectEditor
dim g_sUploadChunkCommandName
dim g_sChunkPurgeCommandName

dim g_bChunkIsBinary
dim g_sChunkGUID
dim g_nChunkIndex
dim g_nChunkSize
dim g_vChunkData

dim g_nSize					' размер передаваемых данных
dim g_sTicket				' Тикет
dim g_oTotalXml				' Передаваемый на сервер набор данных
dim g_bCanClose				' Признак закрытия окна
dim g_bOK					' Признак успешного завершения закачки
dim g_dtStartTime			' Время начала операции копирования
dim g_oData					' Головной элемент данных

dim g_nUpperLimit			' Динамически подбираемый максимальный объём передаваемого кусочка
dim g_nLowerLimit			' Динамически подбираемый минимальный объём передаваемого кусочка
dim g_dtStart				' Время начала загрузки
dim g_nCurrentSize			' Текущий размер блока для передачи на сервер
dim g_nOldCurrentSize		' Текущий размер блока для передачи на сервер (в прошлый раз)
dim g_nCounter				' Счётчик посланных пакетов для определения стратегии
dim g_rOldDiff				' Прошлое время
dim g_rDiff					' Текущее время
dim g_nSizeDelta			' Сколько было передано данных при текущем объёме блока
dim g_nOldSizeDelta			' Сколько было передано данных при прошлом объёме блока


dim g_nSend					' Текущая позиция

dim g_sRetryProcName		' Имя процедуры выполнение которой надо попробовать повторить
dim g_nInterval				' hanle таймера
dim g_nRetryCounter			' счётчик

' HTML контролы
dim xPaneCaption
dim idMainTable
dim idLabel
dim ProgressObject
dim idChunkSize
dim idETA
dim idBandwith
dim cmdMain
dim idRetryTable
dim idTechInfo
dim cmdRetry
dim cmdCancel

'=========================================================================
' Класс для хранения блока данных
class clsDataHolder
	private m_sGUID				' GUID чанка
	private m_nPos				' Позиция
	
	public IsBinary				' Данные bin.hex?
	public Data					' Сами данные
	public NextChunk			' Следующий блок данных
	
	' Размер блока
	public property get Size
		if IsNull(Data) then
			Size=0
		elseif IsBinary then
			Size = UBound(Data)	
		else
			Size = len(Data)	
		end if	
	end property
	
	' Идентификатор блока
	public property get GUID
		GUID = m_sGUID
	end property
	
	' Конструктор
	Private Sub class_Initialize
		m_sGUID	= LCase( XService.NewGUIDString )
		IsBinary = True
		If IsObject(g_oData) then
			' создание 2-го и последующих элементов - вставляем в начало списка
			Set NextChunk = g_oData
		Else	
			' создание 1-го элемента списка
			Set NextChunk = Nothing
		End If
		Set g_oData = me
		Data = Null
		m_nPos = 0
	End Sub
	
	' Создаёт кусочек для отсылки на сервер
	' [in]  nMaxChunkSize - максимальный размер передаваемого кусочка
	public sub CreateSubChunk(ByRef vChunkData,ByRef  nChunkSize,ByRef  sChunkGUID,ByRef  nChunkIndex,ByRef  bChunkIsBinary,ByVal nMaxChunkSize)
		Dim vBinary
		Dim sText
		vBinary = null
		sText = null
		sChunkGUID = GUID
		bChunkIsBinary = IsBinary
		nChunkIndex = m_nPos
		if IsBinary then
			vChunkData = XService.ByteArrayMid(Data, m_nPos+1, nMaxChunkSize)
			nChunkSize = UBound(vChunkData)+1
		else
			vChunkData = MID(Data, m_nPos+1, nMaxChunkSize)
			nChunkSize = len(vChunkData)
		end if
		m_nPos = m_nPos + nChunkSize
		if (m_nPos-1) >= UBound(Data) then
			' Дошли до конца ;)
			set g_oData = NextChunk
		end if	
	end sub
end class


'=========================================================================
'Обработчик загрузки окна
sub window_OnLoad()
	Dim aDA ' dialogArguments
	InitHtmlContols()
	g_nCurrentSize = (MIN_POST_SIZE+MAX_POST_SIZE)\2 
	g_bCanClose = false
	g_bOK = false
	X_GetDialogArguments aDA
	Set g_oTotalXml = aDA(0)
	Set g_oObjectEditor = aDA(1)
	g_sUploadChunkCommandName = aDA(2)
	g_sChunkPurgeCommandName = aDA(3)
	
	cmdMain.focus 
	' Дождемся прогрузки и инициализации документа
	X_WaitForTrue "Init()" , "X_IsDocumentReadyEx( null, ""XProgressBar"")"
end sub


'=========================================================================
' Инициализация ссылок на Html-контролы
Sub InitHtmlContols()
	Set idMainTable = document.all("idMainTable")
	Set idLabel = document.all("idLabel")
	Set xPaneCaption = document.all("XMultipart_xPaneCaption")
	Set ProgressObject = document.all("ProgressObject")
	Set idChunkSize = document.all("idChunkSize")
	Set idETA = document.all("idETA")
	Set idBandwith = document.all("idBandwith")
	Set cmdMain = document.all("cmdMain")
	Set idRetryTable = document.all("idRetryTable")
	Set idTechInfo = document.all("idTechInfo")
	Set cmdRetry = document.all("cmdRetry")
	Set cmdCancel = document.all("cmdCancel")
End Sub


'=========================================================================
' Инициализация
Sub Init()
	dim oNodes	' Узлы с большими свойствами
	dim oNode	' Узел
	dim oChunk	' Блок
	dim nCount	' Кол-во блоков
	dim nSize	' Общий размер
	nCount = 0
	nSize = 0
	' Вырежем все двоичные свойства
	set oNodes = g_oTotalXml.selectNodes("//*[(@dt:dt='bin.base64')and (''!=.)]")
	for each oNode in oNodes
		set oChunk = new clsDataHolder
		nCount = nCount + 1
		oChunk.Data = oNode.nodeTypedValue
		nSize = nSize + UBound(oChunk.Data)
		oNode.text = vbNullString
		oNode.setAttribute "chunked-chain-id", oChunk.GUID
	next
	set oNode = nothing
	set oNodes = nothing
	
	' Если уложились то бог с ним ;)
	if X_GetApproximateXmlSize(g_oTotalXml) > MAX_POST_SIZE then
		' Вырежем текстовые свойства
		set oNodes = g_oTotalXml.selectNodes("//*[(@dt:dt='string')and (string-length(.)>" & IGNORED_STRING_SIZE & ")]")	' Если строка короткая то и фиг с ней ;)
		for each oNode in oNodes
			if not nothing is X_GetTypeMD(oNode.parentNode.tagName).selectSingleNode("ds:prop[@n='" & oNode.tagName & "' and number(ds:max)>" & MAX_STRING_SIZE & "]") then
				' Наш клиент - к ногтю
				set oChunk = new clsDataHolder
				oChunk.IsBinary = false
				nCount = nCount + 1
				oChunk.Data = oNode.nodeTypedValue
				nSize = nSize + len(oChunk.Data)
				oNode.text = vbNullString
				oNode.setAttribute "chunked-chain-id", oChunk.GUID
			end if
		next
	end if
	if nCount > 0 then 
		g_sTicket = LCase(XService.NewGUIDString)
		g_oTotalXml.documentElement.setAttribute "transaction-id", g_sTicket
	end if	
	
	'??? Мож имеет смысл XML тоже резать если слишком большой остался
	g_nSize = nSize + len(g_oTotalXml.xml)
	g_nSend = 0

	' Инициализируем ProgressBar (от 0 до 100%, сейчас - 0)
	ProgressObject.SetState 0, g_nSize, 0
	idLabel.innerText = "Загрузка данных на сервер..."
	XService.DoEvents()
	g_dtStartTime = Now
	
	if nCount > 0 then
		setTimeout 	"UploadStep", 0, "VBScript"
	else
		setTimeout 	"SaveStep", 0, "VBScript"
	end if		
End Sub



'=========================================================================
' Функция анализа трафика и подбора оптимального размера пересылаемого блока
' [in] nSize - переданный кусочек данных
' [in] bBefore = true если вызвана ПЕРЕД отправкой пакета
Sub UpdateStatisticsAndMakeDesign(nSize, bBefore)
	if bBefore then
		if 0=nSize then
			if CLng(g_nCounter) = RETRY_COUNT then
				if IsEmpty(g_rOldDiff) then
					g_nUpperLimit = MAX_POST_SIZE
					g_nLowerLimit = MIN_POST_SIZE
					
					g_nCounter = 0
					g_nOldSizeDelta = g_nSizeDelta
					g_rOldDiff = g_rDiff
					g_nOldCurrentSize = g_nCurrentSize
					g_nCurrentSize = Clng( g_nLowerLimit +  3*(g_nUpperLimit - g_nLowerLimit)/8 )
				else
					if 0=g_rDiff then g_rDiff = 1
					if 0=g_rOldDiff then g_rOldDiff = 1
					if (g_nOldSizeDelta/g_rOldDiff) < (g_nSizeDelta/g_rDiff ) then
						if g_nOldCurrentSize > g_nCurrentSize  then
							' Скорость возросла с уменьшением - поставим планку на максимальный размер 
							g_nUpperLimit = g_nCurrentSize
						else
							' Скорость возросла с увеличением - поставим планку на минимальный размер 
							g_nLowerLimit = g_nCurrentSize
						end if
					else
						if g_nOldCurrentSize > g_nCurrentSize  then
							' Скорость упала с уменьшением - поставим планку на минимальный размер 
							g_nLowerLimit = g_nCurrentSize
						else
							' Скорость упала с увеличением - поставим планку на максимальный размер 
							g_nUpperLimit = g_nCurrentSize
						end if
					end if
					g_nCounter = 0
					g_nOldSizeDelta = g_nSizeDelta
					g_rOldDiff = g_rDiff
					g_nOldCurrentSize = g_nCurrentSize
				
					g_nCurrentSize = Clng((g_nUpperLimit + g_nLowerLimit) / 2)
				end if
			end if	
		else
			g_dtStart=now
		end if
	else
		g_rDiff = CDbl(g_rDiff) + CDbl(datediff("s",g_dtStart,now))
		g_nCounter = CLng(g_nCounter) + 1
		g_nSizeDelta = CLng(g_nSizeDelta) + nSize
	end if
End Sub


'=========================================================================
' Загрузка очередной порции документа на сервер
Sub UploadStep
	Err.Clear
	if true=g_bCanClose then exit sub
	' Порция данных
	if not IsObject(g_oData) then exit sub
	if nothing is g_oData then exit sub
	UpdateStatisticsAndMakeDesign 0, true
	idChunkSize.innerText = g_nCurrentSize 
	XService.DoEvents 
	
	g_oData.CreateSubChunk g_vChunkData,g_nChunkSize,g_sChunkGUID,g_nChunkIndex,g_bChunkIsBinary,g_nCurrentSize
	
	UploadStep2
	
End Sub


'=========================================================================
' Загрузка очередной порции документа на сервер
Sub UploadStep2
	dim nSec		' Сколько секунд осталось (примерно)
	dim nSend		' Сколько байт было передано
	dim nT0,nS0,nV,nS1,nT1, nBitrate	' Переменные для подсчёта битрейта
	
	Err.Clear
	
	if true=g_bCanClose then exit sub
	
	nSend = g_nChunkSize
	
	UpdateStatisticsAndMakeDesign g_nCurrentSize, true
	

	' Передадим на сервер
	On Error Resume Next
	
	With New XChunkUploadRequest
		.m_sName = g_sUploadChunkCommandName
		.m_sTransactionID = g_sTicket
		.m_sOwnerID = g_sChunkGUID
		.m_sChunkText = iif(Not g_bChunkIsBinary, g_vChunkData,Null) 
		.m_nOrderIndex = g_nChunkIndex
		.m_aChunkData = iif(g_bChunkIsBinary, g_vChunkData,Null) 
		X_ExecuteCommand .Self
	End With
	
	' Проанализируем отклик
	if 0=err.number then
		UpdateStatisticsAndMakeDesign nSend, false
		' Все прошло успешно, кусок передан
		' Проапдейтим текущую позицию
		g_nSend = g_nSend + nSend
			
		'T0=S0/V - сколько необходимо времени всего
		'V=S1/T1 - скорость
		nS0=g_nSize - g_nSend
		nS1=g_nSend
		nT1=DateDiff("s", g_dtStartTime, now)
		if nT1=0 then nT1=1
		nV=nS1/nT1
		nT0=nS0/nV
		nSec = CLng(nT0)
		nBitrate = CLng(8*nV/1024)
			
		idSizeSent.innerText = CStr(g_nSend)
		idETA.innerText = FormatSeconds( nSec )
		idBandwith.innerText = nBitrate
			
		' Подвинем "градусник"
		ProgressObject.SetState 0, g_nSize + 0, g_nSend
		XService.DoEvents
		if nothing is g_oData then
			window.setTimeout "SaveStep", TIMEOUT, "VBScript" 
		else
			window.setTimeout "UploadStep", TIMEOUT, "VBScript" 
		end if
	else
		' При попытке загрузки возникла ошибка!
		DoConfirmRetry err.Description & vbNewLine & err.Source, "UploadStep2" 
	end if
End Sub

Function FormatSeconds(nSeconds)
	Dim nMinutes ' Кол-во минут
	nMinutes = CLng(Round(CDbl(nSeconds)/CDbl(60.0)))
	If nMinutes > 0 Then
		FormatSeconds = "около " & nMinutes & " " & XService.GetUnitForm(nMinutes, Array("минут","минуты","минут"))
	Else
		FormatSeconds = "менее 1 минуты"
	End If
End Function
	

'=========================================================================
' Сохранение всего этого счастья на сервере
Sub SaveStep()
	dim oResultXml	' Результирующий xml
	idLabel.innerText = "Сохранение данных в БД..."
	cmdMain.disabled = true
	XService.DoEvents()
	
	On Error Resume Next
	X_ExecuteCommand g_oObjectEditor.Internal_GetSaveRequest(g_oTotalXml.documentElement)
	
	g_bOK = true
	ProgressObject.SetState 0, g_nSize, g_nSize+1
	XService.DoEvents
	g_oTotalXml.removeChild g_oTotalXml.documentElement
	If X_WasErrorOccured Then
		' на сервере произошла ошибка
		g_oTotalXml.appendChild X_GetLastError.LastServerError.cloneNode(true)
	ElseIf Err Then
		' ошибка произошла на клиенте
		with g_oTotalXml.appendChild(g_oTotalXml.createElement("x-res")) 
			.setAttribute "c", err.number
			' Строки приходится кодировать, т.к. атрибуты в данном контексте нетипизированные
			.setAttribute "sys-msg", err.Source
			.setAttribute "user-msg", err.Description
		end with
	Else
		g_oTotalXml.appendChild g_oTotalXml.createElement("Done")
	End If
	
	err.Clear
	
	g_bCanClose = true
	cmdMain.disabled = True

	window.setTimeout "window.close", 300, "VBScript" ' Чтобы визуально успели увидеть 100%
End Sub


'=========================================================================
' При нажатии на ESC закроем окно
sub Document_OnKeyPress
	if VK_ESC = window.event.keyCode then DoCloseWindow()
end sub

'=========================================================================
' Выгрузка страницы
Sub window_OnUnload
	set g_oData=Nothing
	On Error Resume Next	' Все ошибки давим
	clearInterval g_nInterval
	g_bCanClose = true
	X_SetDialogWindowReturnValue g_bOK
	if true = g_bOK then exit sub
	if IsEmpty(g_sTicket) then exit sub
	idLabel.innerText = "Удаление загруженных данных..."
	
	With New XChunkPurgeRequest
		.m_sName = g_sChunkPurgeCommandName
		.m_sTransactionID = g_sTicket
		X_ExecuteCommand .Self 
	End With
	err.Clear ' Значит не шмогла
End Sub

'=========================================================================
' Предотвращение случайного выхода из режима закачки
Sub Window_OnBeforeUnload
	if true=g_bCanClose then exit sub
	window.event.returnValue = "Прервать загрузку данных на сервер?"
End Sub

'=========================================================================
' Закрытие окна
Sub DoCloseWindow
    If Not g_bCanClose Then
	    g_bCanClose = (true=confirm("Прервать загрузку данных на сервер?"))
	End If
	If g_bCanClose Then
		cmdMain.disabled = True
		window.close
	End If
End Sub

'=========================================================================
'Процедура таймера
Sub TimerProc
	g_nRetryCounter = g_nRetryCounter - 1
	UpdateButtons
	if g_nRetryCounter = 0 then
		DoSetRetryResult true
	end if
End Sub

'=========================================================================
'Обновление кнопок
Sub UpdateButtons
	if g_nRetryCounter > 0 then
		cmdRetry.innerHTML = "<b>Повторить попытку (" & g_nRetryCounter & ")</b>"
	else
		cmdRetry.innerText = "Повторить попытку"
	end if
End Sub


'=========================================================================
'Вывод сообщения об ошибке с предложением поворить попытку
' [in] sTechInfo		- техническая информация
' [in] sRetryProcName	- имя процедуры которую надо попробовать повторить
Sub DoConfirmRetry( sTechInfo, sRetryProcName)
	err.Clear
	g_sRetryProcName = sRetryProcName
	idTechInfo.value = sTechInfo 
	g_nRetryCounter = RETRY_TIMEOUT
	UpdateButtons
	idMainTable.style.display = "none"
	idRetryTable.style.display = "block"
	cmdRetry.focus
	g_bCanClose = true
	g_nInterval = setInterval( "TimerProc",1000,"VBScript" )
End Sub

'=========================================================================
'Установка признака повтора
' [in] bResult	= true если подверждён повтор, иначе false
Sub DoSetRetryResult(bResult)
	clearInterval g_nInterval
	if bResult then
		g_bCanClose = false
		idRetryTable.style.display = "none"		
		idMainTable.style.display = "block"
		cmdMain.focus
		setTimeout g_sRetryProcName, TIMEOUT, "VBScript" 
	else
		window.close
	end if
End Sub

'=========================================================================
'Обработка шелчка по документу
sub Document_OnClick
	clearInterval g_nInterval
	g_nRetryCounter=0
	UpdateButtons
end sub
'</SCRIPT>
