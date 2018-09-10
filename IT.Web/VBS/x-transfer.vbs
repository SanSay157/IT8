'*******************************************************************************
' Подсистема:    Transfer Service
' Назначение:    Клиентские ф-ции, реализующие выгрузку и загрузку данных
' Использование: Запуск трансфера - XTransfer_ExportToFile или XTransfer_ImportFromFile
'*******************************************************************************

Option Explicit

' интервал обновления статуса с сервера в миллисекундах
const REFRESH_TIME_TRANSFER = 100	

' размер одного фрагмента файла импорта при передаче его на сервер в KB
const IMPORT_FILE_CHUNK_READING_KB = 30	

' названия HTML-страницы, отображающей прогресс экспорта и импорта
const TRANSFER_PROGRESS_PAGE = "x-transfer-progress.aspx"

' название HTML-файла, визуализирующего сравнение объектов
const OBJECT_COMPARE_PAGE = "x-transfer-objects-compare.aspx"
' название HTML-файла, визуализирующего дамп объекта
const OBJECT_ERROR_ON_SAVE_PAGE = "x-transfer-object-dump.aspx"	
' название HTML-файла, визуализирующего дамп объекта при нарушении ссылочной целостности
const OBJECT_UNRESOLVED_PAGE = "x-transfer-reference-integrity.aspx"	
' название HTML-файла, визуализирующего окно с ошибкой
const OBJECT_ERROR_PAGE = "x-transfer-error.aspx"

' надпись на кнопке, после того, как процедура выгрузки/загрузки завершена
const OK_BUTTON_VALUE = "Закрыть"

' Первая часть заголовка сообщений, выводимых Transfer Service
const MSGBOX_TITLE_BEGIN = "Transfer Service"

' название картинок, вставляемых при удачном завершении процедуры ...
const EXPORT_COMPLETE_IMAGE = "Images/x-transfer-export-complete.gif"	' ... загрузки
const IMPORT_COMPLETE_IMAGE = "Images/x-transfer-import-complete.gif"	' ... выгрузки

' константные значения, возвращаемые диалоговым окном трансфера
const TRANSFER_RESULT_ERROR_NOT_STARTED = 0 ' операция не была запущена из-за ошибки на клиенте или на сервере
const TRANSFER_RESULT_TERMINATED = 1 ' операция была прервана пользователем
const TRANSFER_RESULT_FATAL_ERROR = 2 ' операция прервалась из-за ошибки на клиенте или на сервере
const TRANSFER_RESULT_SUCCESS_WITH_ERRORS = 3 ' операция завершилась успешно, в процессе возникали ошибки
const TRANSFER_RESULT_SUCCESS = 4 ' операция завершилась успешно

'--------------------------------------------------------------------------------------
' интервал для закрытия окна в случае успеха
const WINDOW_CLOSE_INTERVAL = 2000

'--------------------------------------------------------------------------------------
' константные значения, возвращаемые диалоговыми окноми визуализации
const WINDOW_RESULT_CANCEL		= 0	' нажатие кнопки "отменить" (или при возникновении ошибки)
const WINDOW_RESULT_SKIP			= 1	' в окне сравнения объектов нажата кнопку "Пропустить"
const WINDOW_RESULT_REPLACE		= 2	' в окне сравнения объектов нажата кнопку "Перезаписать"
const WINDOW_RESULT_RETRY			= 3	' в окне ошибки сохранения объекта нажата кнопка "Повторить"
const WINDOW_RESULT_IGNORE		= 4	' в окне нажата кнопка "Игнорировать"
const WINDOW_RESULT_IGNOREALL = 5	' в окне нажата кнопка "Игнорировать все"

'--------------------------------------------------------------------------------------
' константные значения, определяющие тип модального диалога
const DIALOG_TYPE_ERROR = 1             ' ошибка (x-transfer-error.aspx)
const DIALOG_TYPE_OBJECT_DUMP = 2       ' дамп объекта (x-transfer-object-dump.aspx)
const DIALOG_TYPE_REF_INTEGRITY = 3     ' нарушение ссылочной целостности (x-transfer-reference-integrity.aspx)
const DIALOG_TYPE_OBJECTS_COMPARE = 4   ' сравнение объектов (x-transfer-objects-compare.aspx)

'--------------------------------------------------------------------------------------
dim g_TransferServiceClient ' глобальный объект клиента трансфера

'======================================================================
' Назначение:  Возвращает глобальный объект клиента трансфера
' Результат:   объект типа XTransferServiceClient
Function TransferServiceClient
	If IsEmpty(g_TransferServiceClient) Then
		Set g_TransferServiceClient = new XTransferServiceClient
	End If
	Set TransferServiceClient = g_TransferServiceClient
End Function

'======================================================================
' Назначение:  Запускает процесс экспорта
' Результат:   TRANSFER_RESULT_XXX
' Параметры:   [in] sScenarioFileId - Идентификатор файла сценария, заданный элементом 
' 						ts:scenario-file в конфигурационном файле приложения в секции <ts:transfer-service>
'              [in] sScenarioName - Идентификатор сценария, присутствующего в файле сценария
'              [in] sDestinationFile - Абсолютный или относительный путь к файлу обмена 
'              (в который выгружать данные). Относительный путь на сервере задается с учетом 
'              элемента <ts:export-folder> в конфигурационном файле приложения 
'              [in] bFileToClient - пересылать файл обмена клиенту (или сохранять на сервере)
'              true: файл обмена будет пересылаться клиенту
'              false: файл обмена будет сохраняться на сервере
'              [in] oXmlParams - XML документ или его часть с параметрами SQL запросов (data-source) в формате data-source.
'              если параметры не требуются, может быть null или ""
'              Пример: <param n="DepName">Отдел пр</param><param n="PersCount">15</param>
function XTransfer_ExportToFile(sScenarioFileId, sScenarioName, _
	sDestinationFile, bFileToClient, oXmlParams) 

	XTransfer_ExportToFile = TransferServiceClient.ExportToFile(sScenarioFileId, sScenarioName, sDestinationFile, bFileToClient, oXmlParams)
end function 

'======================================================================
' Назначение:  Запускает процесс импорта
' Результат:   TRANSFER_RESULT_XXX
' Параметры:   [in] sScenarioFileId - Идентификатор файла сценария, заданный элементом 
' 						ts:scenario-file в конфигурационном файле приложения в секции <ts:transfer-service>
'              [in] sSourceFile - Путь к файлу обмена (из к-го выгружать данные). Относительный путь на сервере задается с учетом 
'              элемента <ts:import-folder> в конфигурационном файле приложения 
'              [in] bFileFromClient - пересылать файл обмена с клиента (или он уже на сервере)
'              true: файл обмена расположен на клиенте и должен быть передан на сервер
'              false: файл обмена расположен на сервере
'              [in] oXmlParams - XML документ или его часть с параметрами SQL запросов (data-source) в формате data-source.
'              если параметры не требуются, может быть null или ""
'              Пример: <param n="DepName">Отдел пр</param><param n="PersCount">15</param>
function XTransfer_ImportFromFile(sScenarioFileId, sSourceFile, bFileFromClient, oXmlParams) 
	XTransfer_ImportFromFile = TransferServiceClient.ImportFromFile(sScenarioFileId, sSourceFile, bFileFromClient, oXmlParams) 
end function 

'==============================================================================
' Класс параметров события "TSMsgBox"
Class TSMsgBoxEventArgsClass
	Public Cancel				' As Boolean - признак прерывания цепочки обработчиков события
	
	Public prompt ' строка сообщения
	Public buttons ' тип и кол-во кнопок (см. MsgBox)
	Public title ' вторая часть заголовка
	Public ReturnValue ' ответ пользователя
		
	Public Function Self
		Set Self = Me
	End Function

End Class

'==============================================================================
' Класс параметров события открытия окна диалога
Class TSOpenPageEventArgsClass
	Public Cancel				' As Boolean - признак прерывания цепочки обработчиков события
	
	Public QueryStr ' параметры для открытия диалога
	Public ReturnValue ' возвращаемое значение - TRANSFER_RESULT_XXX
		
	Public Function Self
		Set Self = Me
	End Function

End Class
'==============================================================================
' Класс параметров события получения кастомизированного параметра
Class TSGetValueArgsClass
	Public Cancel				' As Boolean - признак прерывания цепочки обработчиков события
	
	Public DefaultValue ' значение по умолчанию
	Public ReturnValue ' возвращаемое значение
		
	Public Function Self
		Set Self = Me
	End Function

End Class
'======================================================================
' Класс клиента Transfer Service
' События:
' TSMsgBox - Выводит сообщение
' OpenExportPage - Открывает главный диалог экспорта
' OpenImportPage - Открывает главный диалог импорта
' OpenErrorPage - Открывает диалог сообщения об ошибке
' OpenErrorOnSavePage - Открывает диалог ошибки при сохранении объекта
' OpenUnresolvedPage - Открывает диалог ошибки "объект с неразрешенными ссылками"
' OpenComparePage - Открывает диалог дубликата в процессе импорта
' GetRefreshTime - Запрашивает интервал обновления статуса с сервера в миллисекундах, по умолчанию 100
' GetImportFileChunkSize - Запрашивает размер одного фрагмента файла импорта при передаче его на сервер в KB, по умолчанию 30
' Префикс пользовательских функций событий: usrXTransfer_On

Class XTransferServiceClient

	Private m_CmdGuid ' гуид операции
	Private m_nTimer	' таймер обновления статуса
	Private m_dtBegin	' время начала процедуры
	Private m_bProcessFinished ' завершился ли уже процесс
	Private m_bImport ' это импорт (или экспорт)

	Private m_FilePath ' путь к файлу на клиенте
	Private m_oFSO		' FileScriptingObject
	Private m_oFileStream	' файл

	Private m_oEventEngine	' As EventEngineClass - event engine

	'--------------------------------------------------------------------------------------
	' гуид операции
	Public Property Get CmdGuid
		Set CmdGuid = m_CmdGuid
	End Property

	' это импорт (или экспорт)
	Public Property Get bImport
		Set bImport = m_bImport
	End Property

	' таймер обновления статуса
	Public Property Get Timer
		Set Timer = m_nTimer
	End Property

	' завершился ли уже процесс
	Public Property Get bProcessFinished
		Set bProcessFinished = m_bProcessFinished
	End Property

	' путь к файлу на клиенте
	Public Property Get FilePath
		Set FilePath = m_FilePath
	End Property

	'--------------------------------------------------------------------------------------
	' "Конструктор" объекта
	Private Sub Class_Initialize
		Set m_oEventEngine = X_CreateEventEngine
	End Sub
	'--------------------------------------------------------------------------------------
	' Возбуждает заданное событие с переданными параметрами
	Public Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub
	
	'******************************************************************************	
	'
	' Функции запуска операций
	'
	'******************************************************************************	
	' Назначение:  Создает документ XML параметров
	' Результат:   документ XML параметров
	' Параметры:   [in] sParams - строка вида [<param n="ParamNameN">ParamValueN</param>]
	'              может быть ""
	' Пример sParams: <param n="DepName">Отдел пр</param><param n="PersCount">15</param>
	Private function CreateXmlParams(sParams)
		dim oXmlDoc				' пустой XML-документ для передачи параметров запроса
		Set oXmlDoc = XService.XmlGetDocument
		oXmlDoc.async = False
		oXmlDoc.loadXML "<?xml version=""1.0"" encoding=""windows-1251""?><params>" & _
			sParams & "</params>"
		Set CreateXmlParams = oXmlDoc.selectSingleNode("params")
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  инициализирует коллекцию обработчиков событий статическим биндингом (по маске имени процедуры)
	Private Sub InitEventEngineHandlers()
		m_oEventEngine.Clear
		
			m_oEventEngine.InitHandlers _
			"TSMsgBox,OpenExportPage,OpenImportPage," & _
			"OpenErrorPage,OpenErrorOnSavePage,OpenUnresolvedPage,OpenComparePage," & _
			"GetRefreshTime,GetImportFileChunkSize,CommandComplete,GetHeaderString" _
			, "usrXTransfer_On"
	end Sub
		'--------------------------------------------------------------------------------------
	' Назначение:  Запускает процесс экспорта
	' Результат:   TRANSFER_RESULT_XXX
	' Параметры:   [in] sScenarioFileId - идентификатор файла сценария (ts:scenario-file)
	'              [in] sScenarioName - Название сценария (из файла сценария)
	'              [in] sDestinationFile - Путь к файлу обмена (в к-й выгружать данные)
	'										Путь на сервере задается с учетом ts:export-folder
	'              [in] bFileToClient - пересылать файл обмена клиенту (или сохранять на сервере)
	'              [in] oXmlParams - XML документ или его часть с параметрами SQL запросов (data-source)
	'              если параметры не нужны, может быть null или ""
	'              Пример: <param n="DepName">Отдел пр</param><param n="PersCount">15</param>
	Public function ExportToFile(sScenarioFileId, sScenarioName, _
		sDestinationFile, bFileToClient, oXmlParams) 
		dim oQueryStr   ' объект QueryString
		dim CmdGuid  ' гуид операци
		dim sFilePathClient  ' путь к файлу на клиенте
		dim sFilePathServer  ' путь к файлу на сервере
		dim oFSO		' FileScriptingObject
		dim sHeaderString	' дополнительские пользовательские данные, передаваемые в заголовке

		on error resume next
		ExportToFile = TRANSFER_RESULT_ERROR_NOT_STARTED

		' инициализируем коллекцию обработчиков событий статическим биндингом (по маске имени процедуры)
		InitEventEngineHandlers

		' проверяем, передали ли параметры
		if Not hasValue(sScenarioFileId) then
			Error_MsgBox "Не задан идентификатор файла сценария!"
			exit function
		end if

		if Not hasValue(sScenarioName) then
			Error_MsgBox "Не задано имя сценария!"
			exit function
		end if

		if Not hasValue(sDestinationFile) then
			Error_MsgBox "Не задано имя файла обмена!"
			exit function
		end if

		If Not IsObject(oXmlParams) Then
			Set oXmlParams = CreateXmlParams(toString(oXmlParams))
		end if

		' задаем пути
		if bFileToClient then
			sFilePathClient = sDestinationFile
			sFilePathServer = ""
		else
			sFilePathClient = ""
			sFilePathServer = sDestinationFile
		end if

		' проверим, существует ли файл
		if bFileToClient And Len(sFilePathClient)>0 then
			set oFSO = XService.CreateObject("Scripting.FileSystemObject")
			if oFSO.FileExists(sFilePathClient) then
				' если существует, спросим у пользователя, что делать?
				if vbNo = TSMsgBox("Файл """ & sFilePathClient & """ уже существует. Перезаписать?", vbYesNo + vbExclamation, "Предупреждение") then
					' возвращаемся
					exit function
				end if
				' удаляем существующий файл, если собираемся писать в файл на клиенте, чтобы в случае ошибки при инициализации не остался старый файл в месте назначения
				oFSO.DeleteFile sFilePathClient
				if Err then
					Error_MsgBox "Не удалось удалить файл " & sFilePathClient & vbNewLine & Err.Description 
					exit function		
				end if
			end if
			Err.Clear
		end if


		' получаем доп. строку для заголовка
		If m_oEventEngine.IsHandlerExists("GetHeaderString") Then
			' вызовем обработчик
			With New TSGetValueArgsClass
				FireEvent "GetHeaderString", .Self()
				sHeaderString = .ReturnValue
			End With
		end if
		
		' запускаем операцию
		With New ExportRequest
			.m_sScenarioName = sScenarioName
			.m_sDestinationFile = sFilePathServer
			.m_sClientFilePath = sFilePathClient
			.m_sHeaderString = sHeaderString
			.m_sScenarioFileId = sScenarioFileId
			Set .m_oXmlParams = oXmlParams
			.m_sName = "TransferServiceExportData"
			CmdGuid = X_ExecuteCommandAsync( .Self )
		End With
		
		if Err then
			Error_MsgBox "Не удалось запустить экспорт" & vbNewLine & Err.Description 
			exit function		
		end if

		' если удалось запустить операцию, открываем диалог прогресса
		set oQueryStr = X_GetEmptyQueryString
		' заполняем параметры QueryString, передаваемые в диалоговое окно
		with oQueryStr
			.SetValue "CMDGUID",   CmdGuid
			.SetValue "FILEPATH",   sFilePathClient
		end with	

		' открываем диалог и получаем результат операции
		ExportToFile = OpenExportPage(oQueryStr)

		if Err then
			Error_MsgBox "Не удалось открыть окно" & vbNewLine & Err.Description 
		end if

		if IsEmpty(ExportToFile) then
			' ошибка диалога
			ExportToFile = TRANSFER_RESULT_ERROR_NOT_STARTED
		end if

	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Открывает главный диалог экспорта,
	' если установлен обработчик usrXTransfer_OnOpenExportPage, вызывает его
	' Параметры:   [in] QueryStr - параметры QueryString, передаваемые в диалоговое окно
	' Результат:   TRANSFER_RESULT_XXX
	Public function OpenExportPage(QueryStr)
		If m_oEventEngine.IsHandlerExists("OpenExportPage") Then
			' вызовем обработчик
			With New TSOpenPageEventArgsClass
				set .QueryStr = QueryStr
				FireEvent "OpenExportPage", .Self()
				OpenExportPage = .ReturnValue
			End With
		else
			' покажем сами
			OpenExportPage = DefaultOpenExportPage(QueryStr)
		end if
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Открывает главный диалог экспорта,
	' Параметры:   [in] QueryStr - параметры QueryString, передаваемые в диалоговое окно
	' Результат:   TRANSFER_RESULT_XXX
	Public function DefaultOpenExportPage(QueryStr)
		DefaultOpenExportPage = X_ShowModalDialogEx(TRANSFER_PROGRESS_PAGE & "?ACTION=EXPORT&TM=" & CDbl(Now), _
			QueryStr, "dialogWidth:500px;dialogHeight:280px;status:no;center:yes;scroll:no")
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Запускает процесс импорта
	' Результат:   TRANSFER_RESULT_XXX
	' Параметры:   [in] sScenarioFileId - идентификатор файла сценария (ts:scenario-file)
	'              [in] sSourceFile - Путь к файлу обмена (из к-го выгружать данные)
	'										Путь на сервере задается с учетом ts:import-folder
	'              [in] bFileFromClient - пересылать файл обмена с клиента (или он уже на сервере)
	'              [in] oXmlParams - XML документ или его часть с параметрами SQL запросов (data-source)
	'              если параметры не нужны, может быть null или ""
	'              Пример: <param n="DepName">Отдел пр</param><param n="PersCount">15</param>
	Public function ImportFromFile(sScenarioFileId, sSourceFile, bFileFromClient, oXmlParams) 
		dim oQueryStr   ' объект QueryString
		dim CmdGuid  ' гуид операци
		dim sFilePathClient  ' путь к файлу на клиенте
		dim sFilePathServer  ' путь к файлу на сервере

		on error resume next
		ImportFromFile = TRANSFER_RESULT_ERROR_NOT_STARTED

		' инициализируем коллекцию обработчиков событий статическим биндингом (по маске имени процедуры)
		InitEventEngineHandlers

		' проверяем, передали ли параметры
		if Not hasValue(sScenarioFileId) then
			Error_MsgBox "Не задан идентификатор файла сценария!"
			exit function
		end if

		if Not hasValue(sSourceFile) then
			Error_MsgBox "Не задано имя файла обмена!"
			exit function
		end if

		If Not IsObject(oXmlParams) Then
			Set oXmlParams = CreateXmlParams(toString(oXmlParams))
		end if

	' задаем пути
		if bFileFromClient then
			sFilePathClient = sSourceFile
			sFilePathServer = ""
		else
			sFilePathClient = ""
			sFilePathServer = sSourceFile
		end if

		' запускаем операцию
		With New ImportRequest
			.m_sSourceFile = sFilePathServer
			.m_sClientFilePath = sFilePathClient
			.m_sScenarioFileId = sScenarioFileId
			Set .m_oXmlParams = oXmlParams
			.m_sName = "TransferServiceImportData"
			CmdGuid = X_ExecuteCommandAsync( .Self )
		End With
		
		if Err then
			Error_MsgBox "Не удалось запустить импорт" & vbNewLine & Err.Description 
			exit function		
		end if
		
		' если удалось запустить операцию, открываем диалог прогресса
		set oQueryStr = X_GetEmptyQueryString
		' заполняем параметры QueryString, передаваемые в диалоговое окошко
		with oQueryStr
			.SetValue "CMDGUID",   CmdGuid
			.SetValue "FILEPATH",   sFilePathClient
		end with	

		' открываем диалог и получаем результат операции
		ImportFromFile = OpenImportPage(oQueryStr)

		if Err then
			Error_MsgBox "Не удалось открыть окно" & vbNewLine & Err.Description 
		end if

		if IsEmpty(ImportFromFile) then
			' ошибка диалога
			ImportFromFile = TRANSFER_RESULT_ERROR_NOT_STARTED
		end if

	'	Error_MsgBox FinalCodeToText(ImportFromFile)
	end function
		'--------------------------------------------------------------------------------------
	' Назначение:  Открывает главный диалог импорта
	' если установлен обработчик usrXTransfer_OnOpenImportPage, вызывает его
	' Параметры:   [in] QueryStr - параметры QueryString, передаваемые в диалоговое окно
	' Результат:   TRANSFER_RESULT_XXX
	Public function OpenImportPage(QueryStr)
		If m_oEventEngine.IsHandlerExists("OpenImportPage") Then
			' вызовем обработчик
			With New TSOpenPageEventArgsClass
				set .QueryStr = QueryStr
				FireEvent "OpenImportPage", .Self()
				OpenimportPage = .ReturnValue
			End With
		else
			' покажем сами
			OpenimportPage = DefaultOpenImportPage(QueryStr)
		end if
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Открывает главный диалог импорта
	' Параметры:   [in] QueryStr - параметры QueryString, передаваемые в диалоговое окно
	' Результат:   TRANSFER_RESULT_XXX
	Public function DefaultOpenImportPage(QueryStr)
		DefaultOpenImportPage = X_ShowModalDialogEx(TRANSFER_PROGRESS_PAGE & "?ACTION=IMPORT&TM=" & CDbl(Now), _
			QueryStr, "dialogWidth:500px;dialogHeight:280px;status:no;center:yes;scroll:no")
	end function
'--------------------------------------------------------------------------------------
	' Назначение:  преобразует финальный результат операции в текст
	' Результат:   текст строка
	' Параметры:   результат операции 
	Private function FinalCodeToText(nCode)
		dim sText
		Select Case nCode
			Case TRANSFER_RESULT_ERROR_NOT_STARTED sText = "ERROR_NOT_STARTED"
			Case TRANSFER_RESULT_TERMINATED sText = "TERMINATED"
			Case TRANSFER_RESULT_FATAL_ERROR sText = "FATAL_ERROR"
			Case TRANSFER_RESULT_SUCCESS_WITH_ERRORS sText = "SUCCESS_WITH_ERRORS"
			Case TRANSFER_RESULT_SUCCESS sText = "SUCCESS"
			Case Else
				Error_MsgBox "Неизвестный код!"
		End Select
		FinalCodeToText = "Отладочная информация: код возврата = " & sText
	end function
	'******************************************************************************	
	'
	' Функции-обертки вокруг текстовых enum'ов прокси операций
	'
	'******************************************************************************	
	' Назначение:	определяет, находится ли операция в состоянии "SUSPENDED"
	' Результат:  boolean
	' Параметры:	ответ операции
	Private function IsSuspended(response)
		IsSuspended = false

		if response.m_sStatus = "SUSPENDED" Then
			IsSuspended = true
		end if
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:	Определяет, является ли тип ошибки - "игнорируемая"
	' Результат:  boolean
	' Параметры:	ответ операции TransferServiceErrorResponse
	Private function CanErrorBeIgnored(response)
		CanErrorBeIgnored = false
		if response.m_sErrorStatus = "ERROR_CAN_BE_IGNORED" then
			CanErrorBeIgnored = true
		end if
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:   Определяет, является ли тип ошибки - "фатальная"
	' Результат:    boolean
	' Параметры:    ответ операции TransferServiceErrorResponse
	Private Function IsFatalError(response)
	    IsFatalError = False
	    If response.m_sErrorStatus = "ERROR_FATAL" Then
			IsFatalError = True
		End If
	End Function
	'--------------------------------------------------------------------------------------
	' Назначение:	Формирует ответ пользователя из константы в строку, понимаемую трансфером
	' Результат: строка
	' Параметры: ответ пользователя
	Private function FormatUserAnswer(nResult)
		Select Case nResult
			Case WINDOW_RESULT_IGNORE
				FormatUserAnswer = "WINDOW_RESULT_IGNORE"
			Case WINDOW_RESULT_IGNOREALL
				FormatUserAnswer = "WINDOW_RESULT_IGNOREALL"
			Case WINDOW_RESULT_CANCEL
				FormatUserAnswer = "WINDOW_RESULT_CANCEL"
			Case WINDOW_RESULT_SKIP
				FormatUserAnswer = "WINDOW_RESULT_SKIP"
			Case WINDOW_RESULT_REPLACE
				FormatUserAnswer = "WINDOW_RESULT_REPLACE"
			Case WINDOW_RESULT_RETRY
				FormatUserAnswer = "WINDOW_RESULT_RETRY"
			Case Else
				Error_MsgBox "Неизвестный ответ пользователя!"
		End Select
	End Function
	
	'--------------------------------------------------------------------------------------
	' Назначение:  Строит объект ответа пользователя
	' Результат:   объект ответа пользователя TransferServiceUserAnswerRequest
	' Параметры:   ответ пользователя
	Private function BuildUserAnswerRequest(nResult)
		With New TransferServiceUserAnswerRequest
			.m_sUserAnswer = FormatUserAnswer(nResult)
			.m_sName = "TransferServiceUserAnswerRequest"
			Set BuildUserAnswerRequest = .Self
		End With
	End Function
	
	'******************************************************************************	
	'
	' Утилитные и вспомогательные функции (не использующие глобальные переменные)
	'
	'******************************************************************************	
	' Назначение:  Получает длину временного интервала между двумя событиями
	' Результат:   строка hhh:mm:ss
	' Параметры:   [in] time1 - время первого события (начало)
	'              [in] time2 - время второго события (конец)
	' Примечание:  если время больше суток, возвращает соотв. кол-во часов
	Private function FormatTimeDiff(time1, time2)
		Dim sec
		Dim h, m, s
		sec = DateDiff("s", time1, time2)
		h = Int(sec / 3600)
		m = Int((sec Mod 3600) / 60)
		s = sec Mod 60
		FormatTimeDiff = FormatInteger(h, 2) & ":" & FormatInteger(m, 2) & ":" & FormatInteger(s, 2)
	End Function
	'--------------------------------------------------------------------------------------
	' Назначение:  Форматирует целое число, подставляя нужное число нулей впереди
	' Результат:   строка 000[число]
	' Параметры:   [in] n - число
	'              [in] nNumberOfChars - минимальное число полученных символов
	Private function FormatInteger(n, nNumberOfChars)
		Dim sRes
		sRes = n
		While (Len(sRes) < nNumberOfChars)
			sRes = "0" & sRes
		Wend
		FormatInteger = sRes
	End Function
	'--------------------------------------------------------------------------------------
	' Назначение:  Проверяет, является ли результат работы операции успешным
	' Результат:  boolean
	' Параметры:   [in] nCode - результат работы операции
	Private function IsFinalCodeSuccesfull(nCode)
		if nCode=TRANSFER_RESULT_SUCCESS or nCode=TRANSFER_RESULT_SUCCESS_WITH_ERRORS then
			IsFinalCodeSuccesfull = true
		else
			IsFinalCodeSuccesfull = false
		end if
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  В зависимости от параметров в финальном ответе операции с сервера
	'              формирует VBS-результат операции
	' Результат:   VBS-результат операции TRANSFER_RESULT_ХХХ
	' Параметры:   [in] response - ответ операции TransferServiceFinishedResponse
	Private function FormatFinalCode(response)
		Dim nCode
		if response.m_bWasTerminated then
			nCode = TRANSFER_RESULT_TERMINATED
		elseif Not response.m_bSuccess then
			nCode = TRANSFER_RESULT_FATAL_ERROR
		elseif response.m_bWereIgnorableErrors then
			nCode = TRANSFER_RESULT_SUCCESS_WITH_ERRORS
		else
			nCode = TRANSFER_RESULT_SUCCESS
		end if
		FormatFinalCode = nCode
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Выводит сообщение с добавлением в заголовок "Transfer Service - "
	Public function DefaultTSMsgBox(prompt, buttons, title)
		Dim sSeparatorTitle ' полный заголовок
		if Len(title) > 0 then
			sSeparatorTitle = " - "
		else
			sSeparatorTitle = ""
		end if
		DefaultTSMsgBox = MsgBox(prompt, buttons, MSGBOX_TITLE_BEGIN & sSeparatorTitle & title)
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Выводит сообщение с добавлением в заголовок "Transfer Service - "
	' если установлен обработчик usrXTransfer_OnTSMsgBox, вызывает его
	' Параметры:   [in] prompt - строка сообщения
	'              [in] buttons - тип и кол-во кнопок (см. MsgBox)
	'              [in] title - вторая часть заголовка
	' Результат:   ответ пользователя на сообщение
	Public function TSMsgBox(prompt, buttons, title)
		if not window.closed then
			If m_oEventEngine.IsHandlerExists("TSMsgBox") Then
				' вызовем обработчик
				With New TSMsgBoxEventArgsClass
					.prompt = prompt
					.buttons = buttons
					.title = title
					FireEvent "TSMsgBox", .Self()
					TSMsgBox = .ReturnValue
				End With
			else
				' покажем сами
				TSMsgBox = DefaultTSMsgBox(prompt, buttons, title)
			end if
		end if
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Выводит сообщение об ошибке с нужным заголовком и иконкой
	' Параметры:   [in] sMessage - строка сообщения
	Public Sub Error_MsgBox(sMessage)
		TSMsgBox sMessage, vbCritical, "Ошибка!"
	end Sub
	
	'--------------------------------------------------------------------------------------
	' Назначение:  Выводит вопрос с подтверждением о прерывании операции (с нужным заголовком и иконкой)
	' Результат:   ответ пользователя на сообщение (см. MsgBox)
	Public function AreYouSure_MsgBox()
		Dim sMsg ' сообщение

		sMsg = "Вы уверены, что хотите прервать процедуру "
		if iif(IsEmpty(m_bImport), true, m_bImport) then
			sMsg = sMsg & "загрузки"
		else
			sMsg = sMsg & "выгрузки"
		end if
		sMsg = sMsg & "?"

		AreYouSure_MsgBox = TSMsgBox(sMsg, vbYesNo + vbQuestion, "Подтверждение")
	end function
	'******************************************************************************	
	'
	' Общие функции экспорта и импорта
	'
	'******************************************************************************	
	' Назначение:  Вызывается по полному окончанию загрузки главного диалога экспорта или импорта
	' Параметры:   
	'	[in] bImport - True - импорт, False - экспорт
	Public Sub OnMainPageLoad(bImport)
		dim oQueryStr			' объект QueryString

		InitEventEngineHandlers
		m_bImport = bImport
		m_bProcessFinished = false

		' установим таймер на UpdateStatus
		m_nTimer = window.setInterval("g_TransferServiceClient.UpdateStatus()", GetRefreshTime())

		set m_oFileStream = nothing
		set m_oFSO = nothing

		on error resume next
		set oQueryStr = X_GetQueryString
		if Err then
			Error_MsgBox "Не удалось получить объект QueryString" & vbNewLine & Err.Description 
			exit Sub
		end if

		' получим данные, переданные вызывающим скриптом
		m_FilePath = oQueryStr.GetValue("FILEPATH", 0)
		m_CmdGuid = oQueryStr.GetValue("CMDGUID", 0)

		m_dtBegin = Now
	end Sub
	
	'--------------------------------------------------------------------------------------
	' Назначение:  возвращает интервал обновления статуса с сервера в миллисекундах
	' если установлен обработчик usrXTransfer_OnGetRefreshTime, вызывает его
	' Результат:   integer
	Public function GetRefreshTime()
		If m_oEventEngine.IsHandlerExists("GetRefreshTime") Then
			' вызовем обработчик
			With New TSGetValueArgsClass
				.DefaultValue = REFRESH_TIME_TRANSFER
				FireEvent "GetRefreshTime", .Self()
				GetRefreshTime = .ReturnValue
			End With
		else
			' значение по умолчанию
			GetRefreshTime = REFRESH_TIME_TRANSFER
		end if
	end function
	
	'--------------------------------------------------------------------------------------
	' Назначение:  Обработчик загрузки страницы сообщения
	Public Sub OnSpecialPageLoad()
		' Дожидаемся загрузки всех частей страницы
		X_WaitForTrue "Init2", "X_IsDocumentReady(null)"
		' устанавливаем пользовательские обраобтчики событий
		InitEventEngineHandlers
	end Sub
	
	'--------------------------------------------------------------------------------------
	' Назначение:  Вызывается по таймеру. Проверяет состояние операции и обновляет статус.
	' Примечание:  Диспетчер сообщений, передаваемых серверными операциями.
	Public Sub UpdateStatus
		dim response ' ответ операции
		dim sResponseType ' тип ответа операции

		' если завершились, то не должны сюда попадать
		if m_bProcessFinished then
			Error_MsgBox "Неожиданный код ProcessFinished!"
		end if

		On Error Resume Next
		' получим ответ операции
		set response = X_QueryCommandResult(m_CmdGuid)
		if Err then
			onErrorOnClient "Не удалось получить статус операции", true, Err.Description, true
		elseif isempty(response) then
			onErrorOnClient "Пустой ответ операции", true, "", false
		end if

		if m_bProcessFinished then
		' операция была завершена - выходим
			Exit Sub
		End If
		' теперь не должно быть никаких ошибок
		On Error Goto 0

		' получим имя типа
		sResponseType = typename(response) 
		' выведем в GUI текущий статус операции
		SetDataToGui response

		if IsSuspended(response) Then
		' Операция прервана. Надо понять, почему; сделать то, что нужно, и отрезюмить.
			Select Case sResponseType
				Case "TransferServiceErrorResponse"
					ErrorResponse response
				Case "ExportDataResponse"
					ExportDataResponse response
				Case "ImportGetFileResponse"
					ImportGetFileResponse response
				Case "ImportErrorOnSaveResponse"
					ImportErrorOnSaveResponse response
				Case "ImportUnresolvedResponse"
					ImportUnresolvedResponse response
				Case "ImportCompareObjectsResponse"
					ImportCompareObjectsResponse response
				Case Else
					Error_MsgBox "Неизвестный ответ операции! " & sResponseType
			End Select
		else
		' Операция не прервана.
			Select Case sResponseType
				Case "TransferServiceFinishedResponse"
					FinishedResponse response
				Case "TransferServiceResponse"
				Case "TransferServiceErrorResponse"
				Case "ExportDataResponse"
				Case "ImportGetFileResponse"
				Case "ImportErrorOnSaveResponse"
				Case "ImportUnresolvedResponse"
				Case "ImportCompareObjectsResponse"
				Case "XResponse"
				Case Else
					Error_MsgBox "Неизвестный ответ операции. " & sResponseType
			End Select
		end if
	end Sub
	'--------------------------------------------------------------------------------------
	' Назначение:  Обрабатывает фатальную ошибку, обнаруженную на клиенте.
	' Параметры:   [in] sDescription - описание ошибки
	'              [in] bServerError - где произошла ошибка
	'                   true - на сервере (не удалось получить ответ операции, возможно сервер остановлен)
	'                   false - на клиенте - какие-то проблемы с файлом обмена
	'              [in] sErrorDescription - описание ошибки
	'              [in] bShowMsgBox - показывать ли сообщение об ошибке
	Private Sub onErrorOnClient(sDescription, bServerError, sErrorDescription, bShowMsgBox)
		SetProcessFinished TRANSFER_RESULT_FATAL_ERROR

		if bShowMsgBox then
			Error_MsgBox sDescription & vbNewLine & sErrorDescription & vbNewLine & "Операция будет прервана"
		end if

		' сформируем строку с описанием ошибки
		Line1.innerText = "Операция прервана из-за ошибки на "
		if bServerError then
			Line1.innerText = Line1.innerText + "сервере"
		else
			Line1.innerText = Line1.innerText + "клиенте"
		end if
		
		Line2.innerText = sDescription
		Line3.innerText = ""
		Line4.innerText = ""

		TerminateTransfer false
	end Sub
	'--------------------------------------------------------------------------------------
	' Назначение:  Прерывает операцию из-за ошибки на стороне клиента или 
	'              по требованию пользователя в главном окне
	' Параметры:   [in] bUserTerminated - 
	'                   true - прервано пользователем
	'                   false - завершено автоматически из-за ошибки
	Public Sub TerminateTransfer(bUserTerminated)
		if bUserTerminated then
			' дизаблим кнопку
			document.all("XTransfer_cmdCancel").disabled = true
		end if

		' остановим таймер
		window.clearInterval m_nTimer

		if (not m_bProcessFinished) or (not bUserTerminated) then
		' если операция еще не остановлена, или остановлена и сейчас произошла ошибка
			if bUserTerminated then
			' операция еще не остановлена, пользователь прерывает - установим код
				SetFinishedCode TRANSFER_RESULT_TERMINATED
			end if

			' закрываем файл
			CloseFile true

			' прерываем операцию на сервере
			' операция может уже завершиться к этому моменту, игнорируем эту ошибку
			on error resume next
			X_TerminateCommand m_CmdGuid
		end if
	end Sub
	'--------------------------------------------------------------------------------------
	' Назначение:  Устанавливает код завершения операции
	' Параметры:   [in] nCode - код завершения операции
	Private Sub SetFinishedCode(nCode)
		m_bProcessFinished = true
		X_SetDialogWindowReturnValue nCode
	end Sub
	'--------------------------------------------------------------------------------------
	' Назначение:  Устанавливает статус для завершеной операции
	' Параметры:   [in] nCode - код завершения операции
	Private Sub SetProcessFinished(nCode)
		' остановим таймер
		window.clearInterval m_nTimer

		' Устанавливим код завершения операции
		SetFinishedCode nCode

		' выравниваем значение прогрес-бара
		ProgressBar.CurrentVal = ProgressBar.MaxVal

		' меняем надпись на кнопке
		document.all("XTransfer_cmdCancel").value = OK_BUTTON_VALUE

		' установим картинку
		SetPicture IsFinalCodeSuccesfull(nCode)
	end Sub
	'--------------------------------------------------------------------------------------
	' Назначение:  Устанавливает картинку при завершении операции
	' Параметры:   [in] bSuccess - успешно ли завершилась операция
	Private Sub SetPicture(bSuccess)
		if bSuccess then
			' вставляем картинку об удачной загрузке
			if m_bImport then
				document.all("XTransfer_ProgressPicture").src = IMPORT_COMPLETE_IMAGE
			else
				document.all("XTransfer_ProgressPicture").src = EXPORT_COMPLETE_IMAGE
			end if
		else
			' при неудачной загрузке убираем картинку (поскольку нет картинки с сообщением об ошибке)
			document.all("XTransfer_ProgressPicture").width = 0
		end if
	end Sub
	'--------------------------------------------------------------------------------------
	' Назначение:  Устанавливает текущия статус операции в диалог прогресса
	' Параметры:   [in] response - ответ операции 
	' Примечание:  response - ответ производный от TransferServiceResponse, но может быть любым
	Private Sub SetDataToGui(response)
		on error resume next

		ProgressBar.CurrentVal = response.m_nPercentCompleted
		ScenarioName.innerText = iif(len(response.m_sScenarioName) = 0, " ", response.m_sScenarioName)
		Line1.innerText = response.m_sLine1
		Line2.innerText = response.m_sLine2
		Line3.innerText = response.m_sLine3
		Line4.innerText = response.m_sLine4

		TransferTime.innerText = "Затрачено времени: " & FormatTimeDiff(m_dtBegin, Now)
	end Sub
	'--------------------------------------------------------------------------------------		
	' Назначение:  Резюмит операцию указанным реквестом
	' Параметры:   [in] Response - реквест клиента
	Private Sub ResumeCommand(Response)
		on error resume next

		' если уже завершились, то ничего не делаем
		if not m_bProcessFinished then
			X_ResumeCommand m_CmdGuid, Response
			if Err then
			    If m_bProcessFinished Then
			        Err.Clear
			    Else
				    Error_MsgBox "ResumeCommand вернул ошибку" & vbNewLine & Err.Description 
				End If
			end if
		end if
	end Sub
	'--------------------------------------------------------------------------------------
	' Назначение:  Строит объект ответа пользователя TransferServiceUserAnswerRequest
	'              и резюмит опрацию.
	' Параметры:   [in] nResult - ответ пользователя
	Private Sub ResumeWithUserAnswer(nResult)
		ResumeCommand BuildUserAnswerRequest(nResult)
	end Sub
	'--------------------------------------------------------------------------------------
	' Назначение:  Обработчик сообщения об ошибке. 
	'              Открывает диалог OBJECT_ERROR_PAGE или завершает операцию.
	' Параметры:   [in] response - ответ операции типа TransferServiceErrorResponse
	Private Sub ErrorResponse(response)
		dim oQueryStr         ' объект QueryString
		dim sMessage   ' сообщение для пользователя

		sMessage = response.m_sErrorDescription & vbNewLine & response.m_sExceptionString

		if CanErrorBeIgnored(response) then
			' эту ошибку можно проигнорировать
			' формируем параметры для вывода окна с ошибкой
			set oQueryStr = X_GetEmptyQueryString

			' заполняем параметры QueryString, передаваемые в диалоговое окошко
			with oQueryStr
				.SetValue "ERRDESCRIPTION", sMessage
			end with

			' показываем диалог и резюмим операцию ответом пользователя
			ResumeWithUserAnswer OpenErrorPage(oQueryStr)
		elseif IsFatalError(response) then
			' это фатальная ошибка. закрываем файл и показываем мессаджбокс
			CloseFile true
			TSMsgBox sMessage & vbNewLine & "Операция прервана", vbCritical, "Фатальная ошибка"
			ResumeCommand new XRequest
		else
		    ' это "неигнорируемая" ошибка, показываем в таком же стиле, как и игнорируемую,
		    ' но отключаем все кнопки кроме "Прервать"
		    set oQueryStr = X_GetEmptyQueryString
            ' Задаем параметры
            with oQueryStr
				.SetValue "ERRDESCRIPTION", sMessage & vbNewLine & vbNewLine _
				    & "Операция не может быть продолжена." & vbNewLine _ 
				    & "Подробную информацию см. в лог-файле: " & vbNewLine _
				    & response.m_sLogFileName
				.SetValue "ALLOWEDACTIONS", "cmdCancel"
			end with
			
			OpenErrorPage(oQueryStr)
			ResumeCommand new XRequest
		end if
	end Sub
	'--------------------------------------------------------------------------------------
	' Назначение:  Открывает диалог сообщения об ошибке
	' если установлен обработчик usrXTransfer_OnOpenErrorPage, вызывает его
	' Параметры:   [in] QueryStr - параметры QueryString, передаваемые в диалоговое окно
	' Результат:   TRANSFER_RESULT_XXX
	Public function OpenErrorPage(QueryStr)
		If m_oEventEngine.IsHandlerExists("OpenErrorPage") Then
			' вызовем обработчик
			With New TSOpenPageEventArgsClass
				set .QueryStr = QueryStr
				FireEvent "OpenErrorPage", .Self()
				OpenErrorPage = .ReturnValue
			End With
		else
			' покажем сами
			OpenErrorPage = DefaultOpenErrorPage(QueryStr)
		end if
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Открывает диалог сообщения об ошибке
	' Параметры:   [in] QueryStr - параметры QueryString, передаваемые в диалоговое окно
	' Результат:   TRANSFER_RESULT_XXX
	Public function DefaultOpenErrorPage(QueryStr)
		DefaultOpenErrorPage = X_ShowModalDialogEx(OBJECT_ERROR_PAGE & "?TM=" & CDbl(Now), _
			QueryStr, "dialogWidth:600px;dialogHeight:320px;status:no")
	end function
'--------------------------------------------------------------------------------------
	' Назначение:  Обработчик финального ответа операции.
	' Параметры:   [in] response - ответ операции типа TransferServiceFinishedResponse
	Private Sub FinishedResponse(response)
		dim oEventArgs	' параметры события
	
		' закрываем файл
		CloseFile not response.m_bSuccess
		
		' Устанавливаем статус для завершеной операции
		SetProcessFinished FormatFinalCode(response)

		' если определен обработчик окончания операции
		If m_oEventEngine.IsHandlerExists("CommandComplete") Then
			' вызовем обработчик
			set oEventArgs = new TSGetValueArgsClass
			oEventArgs.DefaultValue = response.m_sLogFileName
			FireEvent "CommandComplete", oEventArgs
		else
			if response.m_bCloseWindow then
				' надо закрыть окно
				if response.m_bWasTerminated then
					' был прерван и надо закрыть окно, значит, был прерван пользователем - сразу закрываем
					window.close
				else
					' принудительно закрываем окно через 2 секунды 
					' чтобы полюбоваться на надпись об удачном завершении :)
					window.setInterval "window.close", WINDOW_CLOSE_INTERVAL
				end if
			end if
		end if
	end Sub
	
	'=========================================================================
	' работа с файлом
	'=========================================================================
	' Назначение:  Открывает локальный файл обмена m_FilePath в m_oFileStream
	' Результат:   bool - удалось ли открыть файл
	Private function OpenFile()
		on error resume next
		Const ForReading = 1 ' открываем на чтение
		OpenFile = false
		Err.Clear 
		
		' создаем объект FileSystemObject
		set m_oFSO = XService.CreateObject("Scripting.FileSystemObject")
		if Err then
			Error_MsgBox "Не удалоcь создать объект Scripting.FileSystemObject" & vbNewLine & Err.Description 
		else
			if m_bImport then
				' при импорте будем отправлять файл на сервер - открываем на чтение
				set m_oFileStream = m_oFSO.OpenTextFile(m_FilePath, ForReading)
			else
				' при экспорте будем писать файл локально на сервер - создаем на запись
				set m_oFileStream = m_oFSO.CreateTextFile(m_FilePath, true)
			end if

			if Err then
				Error_MsgBox "Не удалоcь открыть файл [" & m_FilePath & "]" & vbNewLine & Err.Description 
			else
				OpenFile = true
			end if
		end if
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Закрывает файл и при необходимости удаляет файл экспорта
	' Параметры:   [in] bDelete - надо ли удалять файл (при экспорте)
	Private Sub CloseFile(bDelete)
		on error resume next

		if not m_oFileStream is nothing then
			' если файл открыт
			' закрываем
			m_oFileStream.Close 
			set m_oFileStream = nothing

			if bDelete and not m_bImport then
				' удаляем
				m_oFSO.DeleteFile m_FilePath
			end if

			' очищаем
			set m_oFSO = nothing
		end if
	end Sub
	'=========================================================================
	' обработчики событий главного окна - диалога прогресса
	'=========================================================================
	' Назначение:  Обработчик нажатия кнопки "Отменить". Прерывает операцию и закрывает окно. 
	Public Sub OnCancelClick()

		if m_bProcessFinished then
			' все завершилось - просто закрываем
			window.close
		end if

		' операция продолжается - спросим подтверждение
		if AreYouSure_MsgBox() = vbYes then
			' завершим
			TerminateTransfer true
			' закроем окно
			window.close
		end if

	end Sub
	'--------------------------------------------------------------------------------------
	' Назначение:  Обработчик закрытия главного окна. Если операция не была завершена, 
	'              завершает ее на сервере и показывает пользователю мессаджбокс.
	Public Sub OnBeforeUnload()
		Dim sMessage ' строка сообщения

		if not m_bProcessFinished then 
			' сначала завершим, а потом уже покажем мессаджбокс
			TerminateTransfer true

			if m_bImport then
				sMessage = "Операция загрузки прервана пользователем!"
			else
				sMessage = "Операция выгрузки прервана пользователем!"
			end if
			TSMsgBox sMessage, vbCritical, ""

		end if	
	end Sub
	'******************************************************************************	
	'
	' функции экспорта
	'
	'******************************************************************************	
	' Назначение:  Обработчик сообщения о новом фрагменте файла при экспорте.
	' Параметры:   [in] response - ответ операции типа ExportDataResponse
	Private Sub ExportDataResponse(response)
		if m_oFileStream is nothing then
			' если файл еще не открыт, открываем
			if Not OpenFile then
				' если не удалось открыть (например, неправильно задали путь или файл залочен),
				' прерываем операцию. 
				' (В принципе можно проверять это также перед стартом операции, чтобы даже не 
				' стартовать, если неправильно задан файл экспорта)
				onErrorOnClient "Произошла ошибка при открытии файла", false, "", false
			end if
		end if

		on error resume next
		if Not m_oFileStream is nothing then
			' если файл открыт, то пишем туда
			m_oFileStream.Write response.m_sData
			if Err then
				' если не удалось записать, прерываем операцию
				onErrorOnClient "Произошла ошибка при записи в файл экспорта", false, Err.Description, true
			end if
		end if

		' резюмим операцию с пустым ответом
		ResumeCommand new XRequest
	end Sub
	'******************************************************************************	
	'
	' функции импорта
	'
	'******************************************************************************	
	' Назначение:  Получает размер файла обмена, передаваемого на сервер m_FilePath
	' Результат:   размер файла обмена
	' Примечание:  Используется только для оценки процента выполнения и вывода статуса (4 GB problem)
	Private function GetFileSize()
		on error resume next
		Dim f
		GetFileSize = 0
		Set f = m_oFSO.GetFile(m_FilePath)
		GetFileSize = f.Size
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Обработчик запроса очередного фрагмента файла обмена при импорте
	' Параметры:   [in] response - запрос операции типа ImportGetFileResponse
	Private Sub ImportGetFileResponse(response)
		dim sData
		dim bLastChunk
		dim nFileSize

		if m_oFileStream is nothing then
			if Not OpenFile then
				onErrorOnClient "Произошла ошибка при открытии файла", false, "", false
			end if
		end if

		if Not m_oFileStream is nothing then
			on error resume next
			sData = m_oFileStream.Read(GetImportFileChunkSize() * 1024)
			if Err then
				onErrorOnClient "Произошла ошибка при чтении из файла импорта", false, Err.Description, true
			else
				on error goto 0
				nFileSize = GetFileSize
				bLastChunk = m_oFileStream.AtEndOfStream
				if bLastChunk then
					CloseFile false
				end if
			end if
		end if

		With New ImportFileDataRequest
			.m_sData = sData
			.m_bLastChunk = bLastChunk
			.m_nFileSize = nFileSize
			.m_sName = "ImportFileDataRequest"
			ResumeCommand .Self
		End With
		
		if err then						
			SetProcessFinished TRANSFER_RESULT_FATAL_ERROR
			TerminateTransfer true
			document.all("XTransfer_cmdCancel").disabled = false
		end if
	end Sub
	'--------------------------------------------------------------------------------------
	' Назначение:  размер одного фрагмента файла импорта при передаче его на сервер в KB, по умолчанию 30
	' если установлен обработчик usrXTransfer_OnGetImportFileChunkSize, вызывает его
	' Результат:   integer
	Public function GetImportFileChunkSize()
		If m_oEventEngine.IsHandlerExists("GetImportFileChunkSize") Then
			' вызовем обработчик
			With New TSGetValueArgsClass
				.DefaultValue = IMPORT_FILE_CHUNK_READING_KB
				FireEvent "GetImportFileChunkSize", .Self()
				GetImportFileChunkSize = .ReturnValue
			End With
		else
			' значение по умолчанию
			GetImportFileChunkSize = IMPORT_FILE_CHUNK_READING_KB
		end if
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Обработчик ошибки при сохранении объекта
	'              Открывает окно OBJECT_ERROR_ON_SAVE_PAGE
	' Параметры:   [in] response - ответ операции типа ImportErrorOnSaveResponse
	Private Sub ImportErrorOnSaveResponse(response)
		dim oQueryStr                       ' объект QueryString

		' формируем параметры для вывода окна с дампом объекта	
		set oQueryStr = X_GetEmptyQueryString

		' заполняем параметры QueryString, передаваемые в диалоговое окошко
		with oQueryStr
			.SetValue "OBJECTXML", response.m_oXmlObject
			.SetValue "ERRDESCRIPTION", response.m_sErrDescription
		end with

	' показываем диалог и резюмим операцию ответом пользователя
		ResumeWithUserAnswer OpenErrorOnSavePage(oQueryStr)
	end Sub
	'--------------------------------------------------------------------------------------
	' Назначение:  Открывает диалог ошибки при сохранении объекта
	' если установлен обработчик usrXTransfer_OnOpenErrorOnSavePage, вызывает его
	' Параметры:   [in] QueryStr - параметры QueryString, передаваемые в диалоговое окно
	' Результат:   TRANSFER_RESULT_XXX
	Public function OpenErrorOnSavePage(QueryStr)
		If m_oEventEngine.IsHandlerExists("OpenErrorOnSavePage") Then
			' вызовем обработчик
			With New TSOpenPageEventArgsClass
				set .QueryStr = QueryStr
				FireEvent "OpenErrorOnSavePage", .Self()
				OpenErrorOnSavePage = .ReturnValue
			End With
		else
			' покажем сами
			OpenErrorOnSavePage = DefaultOpenErrorOnSavePage(QueryStr)
		end if
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Открывает диалог ошибки при сохранении объекта
	' Параметры:   [in] QueryStr - параметры QueryString, передаваемые в диалоговое окно
	' Результат:   TRANSFER_RESULT_XXX
	Public function DefaultOpenErrorOnSavePage(QueryStr)
		DefaultOpenErrorOnSavePage = X_ShowModalDialogEx(OBJECT_ERROR_ON_SAVE_PAGE & "?TM=" & CDbl(Now), _
			QueryStr, "dialogWidth:600px;dialogHeight:400px;status:no")
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Обработчик ошибки "объект с неразрешенными ссылками"
	'              Открывает окно OBJECT_UNRESOLVED_PAGE
	' Параметры:   [in] response - ответ операции типа ImportUnresolvedResponse
	Private Sub ImportUnresolvedResponse(response)
		dim oQueryStr                       ' объект QueryString

		' формируем параметры для вывода окна с дампом объекта	
		set oQueryStr = X_GetEmptyQueryString

		' заполняем параметры QueryString, передаваемые в диалоговое окошко
		with oQueryStr
			.SetValue "OBJECTXML", response.m_oXmlObject
			.SetValue "PROPS", response.m_sUnreferencedProps
		end with
		
		' показываем диалог и резюмим операцию ответом пользователя
		ResumeWithUserAnswer OpenUnresolvedPage(oQueryStr)
	end Sub
	'--------------------------------------------------------------------------------------
	' Назначение:  Открывает диалог ошибки "объект с неразрешенными ссылками"
	' если установлен обработчик usrXTransfer_OnOpenUnresolvedPage, вызывает его
	' Параметры:   [in] QueryStr - параметры QueryString, передаваемые в диалоговое окно
	' Результат:   TRANSFER_RESULT_XXX
	Public function OpenUnresolvedPage(QueryStr)
		If m_oEventEngine.IsHandlerExists("OpenUnresolvedPage") Then
			' вызовем обработчик
			With New TSOpenPageEventArgsClass
				set .QueryStr = QueryStr
				FireEvent "OpenUnresolvedPage", .Self()
				OpenUnresolvedPage = .ReturnValue
			End With
		else
			' покажем сами
			OpenUnresolvedPage = DefaultOpenUnresolvedPage(QueryStr)
		end if
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Открывает диалог ошибки "объект с неразрешенными ссылками"
	' Параметры:   [in] QueryStr - параметры QueryString, передаваемые в диалоговое окно
	' Результат:   TRANSFER_RESULT_XXX
	Public function DefaultOpenUnresolvedPage(QueryStr)
		DefaultOpenUnresolvedPage = X_ShowModalDialogEx(OBJECT_UNRESOLVED_PAGE & "?TM=" & CDbl(Now), _
			QueryStr, "dialogWidth:600px;dialogHeight:400px;status:no")
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Обработчик дубликата в процессе импорта для объекта с action="ask"
	'              Открывает окно OBJECT_COMPARE_PAGE
	' Параметры:   [in] response - ответ операции типа ImportCompareObjectsResponse
	Private Sub ImportCompareObjectsResponse(response)
		dim oQueryStr                       ' объект QueryString

		' формируем параметры для вывода окна с дампом объекта	
		set oQueryStr = X_GetEmptyQueryString

		' заполняем параметры QueryString, передаваемые в диалоговое окошко
		with oQueryStr
			.SetValue "NEWOBJECTXML", response.m_oXmlNewObject
			.SetValue "STOREDOBJECTXML", response.m_oXmlStoredObject
		end with

	' показываем диалог и резюмим операцию ответом пользователя
		ResumeWithUserAnswer OpenComparePage(oQueryStr)
	end Sub
		'--------------------------------------------------------------------------------------
	' Назначение:  Открывает диалог дубликата в процессе импорта
	' если установлен обработчик usrXTransfer_OnOpenComparePage, вызывает его
	' Параметры:   [in] QueryStr - параметры QueryString, передаваемые в диалоговое окно
	' Результат:   TRANSFER_RESULT_XXX
	Public function OpenComparePage(QueryStr)
		If m_oEventEngine.IsHandlerExists("OpenComparePage") Then
			' вызовем обработчик
			With New TSOpenPageEventArgsClass
				set .QueryStr = QueryStr
				FireEvent "OpenComparePage", .Self()
				OpenComparePage = .ReturnValue
			End With
		else
			' покажем сами
			OpenComparePage = DefaultOpenComparePage(QueryStr)
		end if
	end function
	'--------------------------------------------------------------------------------------
	' Назначение:  Открывает диалог дубликата в процессе импорта
	' Назначение:  Открывает диалог дубликата в процессе импорта
	' Параметры:   [in] QueryStr - параметры QueryString, передаваемые в диалоговое окно
	' Результат:   TRANSFER_RESULT_XXX
	Public function DefaultOpenComparePage(QueryStr)
		DefaultOpenComparePage = X_ShowModalDialogEx(OBJECT_COMPARE_PAGE & "?TM=" & CDbl(Now), _
			QueryStr, "dialogWidth:600px;dialogHeight:400px;status:no")
	end function
'******************************************************************************	
	'
	' Функции вывода данных в дополнительные окна
	'
	'******************************************************************************	
	' выводит реквизиты объекта в модальном окне дампа
	' [in] oTBodyObject - HTML-элемент <TBODY> для вывода таблицы с описанием объекта
	' [in] oTBodyProps - HTML-элемент <TBODY> для вывода таблицы свойств объекта
	' [out/retval] возвращает TRUE в случае успеха и FALSE в случае возникновения ошибки
	Private function FormatUnresolvedObject(oTBodyObject, oTBodyProps)
		on error resume next

		dim oQueryStr			' объект QueryString
		dim oXmlObject			' загружаемый объект
		dim oMetadata			' метаданные для типа объекта
		dim oProp				' свойство объекта 
		dim oTR					' HTML-элемент <TR>
		dim oTD					' HTML-элемент <TD>
		dim oDIV				' HTML-элемент <DIV>
		dim sProps				' названия свойств объекта

		FormatUnresolvedObject = false

		' получаем объект QueryString
		set oQueryStr = X_GetQueryString
		if Err then
			Error_MsgBox "Не удалось получить объект QueryString" & vbNewLine & Err.Description 
			exit function
		end if

		' получаем параметры страницы
		set oXmlObject = oQueryStr.GetValue("OBJECTXML", nothing)
		sProps = oQueryStr.GetValue("PROPS", "")

		' получим метаданные
		Set oMetadata = X_GetTypeMD(oXmlObject.tagName)

		' заполняем описание объекта
        document.all("ObjectName").innerText = oMetadata.getAttribute("d")
        document.all("ObjectID").value = oXmlObject.getAttribute("oid")
	
				
		' прoходим по всем скалярным свойствам (в метаданных)
		for each oProp in oMetadata.selectNodes("ds:prop[@cp='scalar']")
			
		
			' создаем новую строчку в таблице
			set oTR = document.createElement("TR")

			' создаем первую ячейку в строчке (название свойства)
			set oTD = document.createElement("TD")
			oTD.innerText = oProp.getAttribute("d")
			oTR.appendChild oTD
			
			' создаем вторую ячейку в строчке (значение свойства в загружаемом объекте)
			set oTD = document.createElement("TD")
			
			if not (oXmlObject.selectSingleNode(oProp.getAttribute("n")) is nothing) then
			    if not oProp.selectSingleNode("i:const-value-selection") is nothing then
				    ' если свойство - константное значение
				    if not oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]") is nothing then
					    oTD.innerText = oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]").getAttribute("n")
					    
				    end if
			    elseif not oProp.selectSingleNode("i:bits") is nothing then
				    ' если свойство - набор битовых флагов
				    for i = 1 to oProp.selectNodes("i:bits/i:bit").length
					    ' проходим по всем возможным значениям
					    if 0 < Clng(CLng(oProp.selectSingleNode("i:bits/i:bit[" & i & "]").text) and CLng(oXmlObject.selectSingleNode(oProp.getAttribute("n")).text)) then
						    ' добавляем элемент <DIV> что бы каждое значение было с новой строчки
						    set oDIV = document.createElement("DIV")
						    oDIV.innerText = oProp.selectSingleNode("i:bits/i:bit[" & i & "]").getAttribute("n")
						    oTD.appendChild oDIV
					    end if
				    next
				    if oTD.firstChild is nothing then
					    ' если ни одного значения нет, делуем следующее (для красоты)
					    set oDIV = document.createElement("DIV")
					    oDIV.innerText = "-"
					    oTD.appendChild oDIV
				    end if	
				    
			    elseif "bin" = oProp.getAttribute("vt") then
				    ' если свойство - неизвестно что (картинка, звучок и т.п.)
				    ' выводим только кол-во байт
				    oTD.innerText = "Размер: " & _
					    oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size") & _
					    " байт"
				    if 0 < Clng(oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size")) then 
					    
				    end if

			    else
			    
			        if oXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*") is nothing then
			            oTD.innerText = oXmlObject.selectSingleNode(oProp.getAttribute("n")).text
			        else
			            oTD.innerText = oXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*").getAttribute("oid")
			        end if			    

				    if 0 <> InStr(1, sProps, ";" & oProp.getAttribute("ot") & ";") then
					    oTR.setAttribute "bgColor", "#F69694"					
				    end if
			    end if	
			end if		
			oTR.appendChild oTD			
			

			oTBodyProps.appendChild oTR

			err.Clear 
		next
		
		FormatUnresolvedObject = true
	End function
	
	'==============================================================================================
	' вызывается при формировании таблиц (и др. контролов) в модальных диалогах
	' определяет тип диалога и вызвает соответствующую private-функцию
	'
	' [in] nDialogType - тип диалога в соответствии с константами DIALOG_TYPE_...
	public sub FillTableInModalDialog(nDialogType)
		select case nDialogType
			case DIALOG_TYPE_ERROR :
                if false = ShowErrorInHtml(document.all("XTransfer_ContentPlaceHolderForErrorBody_ErrDescription")) then
		            Error_MsgBox "Ошибка при выводе описания ошибки"
	            end if
                			
			case DIALOG_TYPE_OBJECT_DUMP :
		        if false = ErrorOnSaveObject(document.all("XTransfer_ContentPlaceHolderForErrorBody_ErrDescription"), document.all("objTbodyObject"), document.all("objTbodyProps")) then
		            Error_MsgBox "Ошибка при построении таблицы свойств объекта"
	            end if
			
			case DIALOG_TYPE_OBJECTS_COMPARE :
	            if false = CompareObjects(document.all("objTbodyProps")) then
		            Error_MsgBox "Ошибка при построении таблицы сравнения объектов"
	            end if

            case DIALOG_TYPE_REF_INTEGRITY : 
	            if false = FormatUnresolvedObject(document.all("objTbodyObject"), document.all("objTbodyProps")) then
		            Error_MsgBox "Ошибка при построении таблицы свойств объекта"
	            end if
	    end select
	end sub
	
	'==============================================================================================
	' выводит описание ошибки в модальном окне 
	' [in] oErrDescription - HTML-элемент <DIV> для вывода описания ошибки
	' [out/retval] возвращает TRUE в случае успеха и FALSE в случае возникновения ошибки
	Private function ShowErrorInHtml(oErrDescription)
		on error resume next

		dim oQueryStr			' объект QueryString
		const MAX_ROWS = 16

		ShowErrorInHtml = false
		
		' получаем объект QueryString
		set oQueryStr = X_GetQueryString
		if Err then
			Error_MsgBox "Не удалось получить объект QueryString" & vbNewLine & Err.Description 
			exit function
		end if

		' получаем параметры страницы
		oErrDescription.innerText = oQueryStr.GetValue("ERRDESCRIPTION", "")
		oErrDescription.rows = MAX_ROWS

		ShowErrorInHtml = true
	End function
	'==============================================================================================
	' выводит реквизиты объекта и описание ошибки в модальном окне 
	' [in] oErrDescription - HTML-элемент <DIV> для вывода описания ошибки
	' [in] oTBodyObject - HTML-элемент <TBODY> для вывода таблицы с описанием объекта
	' [in] oTBodyProps - HTML-элемент <TBODY> для вывода таблицы свойств объекта
	' [out/retval] возвращает TRUE в случае успеха и FALSE в случае возникновения ошибки
	Private function ErrorOnSaveObject(oErrDescription, oTBodyObject, oTBodyProps)
		on error resume next

		dim oQueryStr			' объект QueryString
		dim oXmlObject			' загружаемый объект
		dim oMetadata			' метаданные для типа объекта
		dim oProp				' свойство объекта 
		dim oTR					' HTML-элемент <TR>
		dim oTD					' HTML-элемент <TD>
		dim oDIV				' HTML-элемент <DIV>
		dim i

		const MAX_ROWS = 11
		ErrorOnSaveObject = false
		
		' получаем объект QueryString
		set oQueryStr = X_GetQueryString
		if Err then
			Error_MsgBox "Не удалось получить объект QueryString" & vbNewLine & Err.Description 
			exit function
		end if

		' получаем параметры страницы
		set oXmlObject = oQueryStr.GetValue("OBJECTXML", nothing)
		oErrDescription.innerText = oQueryStr.GetValue("ERRDESCRIPTION", "")
		oErrDescription.rows = MAX_ROWS

		' получим метаданные
		Set oMetadata = X_GetTypeMD(oXmlObject.tagName)

		' заполняем описание объекта

		' название
        document.all("ObjectName").innerText = oMetadata.getAttribute("d")
        document.all("ObjectID").value = oXmlObject.getAttribute("oid")
				
		' прoходим по всем скалярным свойствам (в метаданных)
		for each oProp in oMetadata.selectNodes("ds:prop[@cp='scalar']")
			
		
			' создаем новую строчку в таблице
			set oTR = document.createElement("TR")

			' создаем первую ячейку в строчке (название свойства)
			set oTD = document.createElement("TD")
			oTD.innerText = oProp.getAttribute("d")
			oTR.appendChild oTD
			
			' создаем вторую ячейку в строчке (значение свойства в загружаемом объекте)
			set oTD = document.createElement("TD")

			if not (oXmlObject.selectSingleNode(oProp.getAttribute("n")) is nothing) then
    			
			    if not oProp.selectSingleNode("i:const-value-selection") is nothing then
				    ' если свойство - константное значение
				    if not oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]") is nothing then
					    oTD.innerText = oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]").getAttribute("n")
					    
				    end if
			    elseif not oProp.selectSingleNode("i:bits") is nothing then
				    ' если свойство - набор битовых флагов
				    for i = 1 to oProp.selectNodes("i:bits/i:bit").length
					    ' проходим по всем возможным значениям
					    if 0 < Clng(CLng(oProp.selectSingleNode("i:bits/i:bit[" & i & "]").text) and CLng(oXmlObject.selectSingleNode(oProp.getAttribute("n")).text)) then
						    ' добавляем элемент <DIV> что бы каждое значение было с новой строчки
						    set oDIV = document.createElement("DIV")
						    oDIV.innerText = oProp.selectSingleNode("i:bits/i:bit[" & i & "]").getAttribute("n")
						    oTD.appendChild oDIV
					    end if
				    next
				    if oTD.firstChild is nothing then
					    ' если ни одного значения нет, делуем следующее (для красоты)
					    set oDIV = document.createElement("DIV")
					    oDIV.innerText = "-"
					    oTD.appendChild oDIV
				    end if	
				    
			    elseif "bin.hex" = oProp.getAttribute("vt") then
				    ' если свойство - неизвестно что (картинка, звучок и т.п.)
				    ' выводим только кол-во байт
				    oTD.innerText = "Размер: " & _
					    oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size") & _
					    " байт"
				    if 0 < Clng(oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size")) then 
					    
				    end if
			    else
			        if oXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*") is nothing then
			            oTD.innerText = oXmlObject.selectSingleNode(oProp.getAttribute("n")).text
			        else
			            oTD.innerText = oXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*").getAttribute("oid")
			        end if
			        
				    
			    end if		
			end if	
			oTR.appendChild oTD			
			
            oTBodyProps.appendChild oTR			
			err.Clear 
		next
		
		ErrorOnSaveObject = true
	End function

		'==============================================================================================
	' выводит сравительные реквизиты объектов в модальном окне сравнения
	' [in] oTBody - HTML-элемент <TBODY> для вывода таблицы сравнения
	' [out/retval] возвращает TRUE в случае успеха и FALSE в случае возникновения ошибки
	Private function CompareObjects(oTBody)
		on error resume next

		dim oQueryStr			' объект QueryString
		dim oXmlObject			' загружаемый объект
		dim oStoredXmlObject    ' объект в БД
		dim oXmlDiffersAttr     ' атрибут, показывающий, совпадает ли свойство
		dim oMetadata			' метаданные для типа объекта
		dim oProp				' свойство объекта 
		dim oTR					' HTML-элемент <TR>
		dim oTD					' HTML-элемент <TD>
		dim oDIV				' HTML-элемент <DIV>
		dim i
		
		' индексы элементов <TD> в качестве "детей" элемента <TR>
		const TD_INDEX_FIRST = 1	' для загружаемого объекта
		const TD_INDEX_SECOND = 2	' для объекта из БД
		
		' имя атрибута узла свойства, который показывает,
		' что это свойство не совпадает
		const DIFFERS_ATTR_NAME = "differs"
		
		' цвет, которым подсветятся несовпадающие свойства
		const COLOR_EQUAL_PROP = "#F69694"	
		
		CompareObjects = false
		
		' получаем объект QueryString
		set oQueryStr = X_GetQueryString
		if Err then
			Error_MsgBox "Не удалось получить объект QueryString" & vbNewLine & Err.Description 
			exit function
		end if

		' получаем параметры страницы
		set oXmlObject = oQueryStr.GetValue("NEWOBJECTXML", nothing)
		set oStoredXmlObject = oQueryStr.GetValue("STOREDOBJECTXML", nothing)

		' получим метаданные
		Set oMetadata = X_GetTypeMD(oXmlObject.tagName)

		' заполняем описание объекта
        document.all("ObjectName").innerText = oMetadata.getAttribute("d")
        document.all("ObjectID").value = oXmlObject.getAttribute("oid")
        
		' прoходим по всем скалярным свойствам (в метаданных)
		for each oProp in oMetadata.selectNodes("ds:prop[@cp='scalar']")

			' создаем новую строчку в таблице
			set oTR = document.createElement("TR")

			' создаем первую ячейку в строчке (название свойства)
			set oTD = document.createElement("TD")
			oTD.innerText = oProp.getAttribute("d")
			oTR.appendChild oTD

			' создаем вторую ячейку в строчке (значение свойства в загружаемом объекте)
			set oTD = document.createElement("TD")
			
			if not oProp.selectSingleNode("i:const-value-selection") is nothing then
				' если свойство - константное значение
				if not oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]") is nothing then
					oTD.innerText = oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]").getAttribute("n")
					
				end if
			elseif not oProp.selectSingleNode("i:bits") is nothing then
				' если свойство - набор битовых флагов
				for i = 1 to oProp.selectNodes("i:bits/i:bit").length
					' проходим по всем возможным значениям
					if 0 < Clng(CLng(oProp.selectSingleNode("i:bits/i:bit[" & i & "]").text) and CLng(oXmlObject.selectSingleNode(oProp.getAttribute("n")).text)) then
						' добавляем элемент <DIV> что бы каждое значение было с новой строчки
						set oDIV = document.createElement("DIV")
						oDIV.innerText = oProp.selectSingleNode("i:bits/i:bit[" & i & "]").getAttribute("n")
						oTD.appendChild oDIV
					end if
				next
				if oTD.firstChild is nothing then
					' если ни одного значения нет, делуем следующее (для красоты)
					set oDIV = document.createElement("DIV")
					oDIV.innerText = "-"
					oTD.appendChild oDIV
				end if	
				
			elseif "bin.hex" = oProp.getAttribute("vt") then
				' если свойство - неизвестно что (картинка, звучок и т.п.)
				' выводим только кол-во байт
				oTD.innerText = "Размер: " & _
					oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size") & _
					" байт"
				if 0 < Clng(oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size")) then 
					
				end if
			else
                ' проверяем, является ли текущее свойство скалярным объектным свойством
                ' (содержит ли дочерние XML-элементы)
		        if oXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*") is nothing then
		            ' содержит только текст - его и получаем
		            oTD.innerText = oXmlObject.selectSingleNode(oProp.getAttribute("n")).text
		        else
		            ' содержит дочерние XML-элементы - получаем их все как текст
		            oTD.innerText = oXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*").xml
		        end if				
			end if			
			oTR.appendChild oTD

			' создаем третью ячейку в строчке (значение свойства объекта в БД)
			set oTD = document.createElement("TD")
		
			if not oProp.selectSingleNode("i:const-value-selection") is nothing then
				' если свойство - константное значение
				if not oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oStoredXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]") is nothing then
					oTD.innerText = oProp.selectSingleNode("i:const-value-selection/i:const-value[.=""" & oStoredXmlObject.selectSingleNode(oProp.getAttribute("n")).text & """]").getAttribute("n")
					
				end if
			elseif not oProp.selectSingleNode("i:bits") is nothing then
				' если свойство - набор битовых флагов
				for i = 1 to oProp.selectNodes("i:bits/i:bit").length
					' проходим по всем возможным значениям
					if 0 < Clng(CLng(oProp.selectSingleNode("i:bits/i:bit[" & i & "]").text) and CLng(oStoredXmlObject.selectSingleNode(oProp.getAttribute("n")).text)) then
						' добавляем элемент <DIV> что бы каждое значение было с новой строчки
						set oDIV = document.createElement("DIV")
						oDIV.innerText = oProp.selectSingleNode("i:bits/i:bit[" & i & "]").getAttribute("n")
						oTD.appendChild oDIV
					end if
				next
				if oTD.firstChild is nothing then
					' если ни одного значения нет, делуем следующее (для красоты)
					set oDIV = document.createElement("DIV")
					oDIV.innerText = "-"
					oTD.appendChild oDIV
				end if	
				

			elseif "bin.hex" = oProp.getAttribute("vt") then
				' если свойство - неизвестно что (картинка, звучок и т.п.)
				' выводим только кол-во байт
				oTD.innerText = "Размер: " & _
					oStoredXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size") & _
					" байт"
				if 0 < CLng(oStoredXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttribute("data-size")) then 
					
				end if
						
			else
			    ' проверяем, является ли текущее свойство скалярным объектным свойством
                ' (содержит ли дочерние XML-элементы)
                if oStoredXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*") is nothing then
                    ' содержит только текст - его и получаем
		            oTD.innerText = oStoredXmlObject.selectSingleNode(oProp.getAttribute("n")).text
		        else
		            ' содержит дочерние XML-элементы - получаем их все как текст
		            oTD.innerText = oStoredXmlObject.selectSingleNode(oProp.getAttribute("n") & "/*").xml
		        end if	
			end if
			oTR.appendChild oTD
				
		    ' смотрим наличие атрибута, указывающего на несовпадение
		    ' текущего свойства у импортируемого объекта
			Set oXmlDiffersAttr = oXmlObject.selectSingleNode(oProp.getAttribute("n")).getAttributeNode(DIFFERS_ATTR_NAME)
			if not oXmlDiffersAttr is nothing then
			    ' атрибут задан - проверяем значение
			    if oXmlDiffersAttr.value = "true" then
			        oTR.setAttribute "bgColor", COLOR_EQUAL_PROP
			    end if
			else
			    ' если атрибут не задан, напрямую сравниваем текст в ячейках
			    if oTR.children(TD_INDEX_FIRST).innerText <> oTR.children(TD_INDEX_SECOND).innerText then
				    oTR.setAttribute "bgColor", COLOR_EQUAL_PROP
			    end if
			end if
			
			oTBody.appendChild oTR
			err.Clear
		next
		CompareObjects = true
	end function

End Class
