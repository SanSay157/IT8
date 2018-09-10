'===============================================================================
'@@!!FILE_xx-tree-drag-drop-md-manager
'<GROUP !!SYMREF_VBS>
'<TITLE xx-tree-drag-drop-md-manager - Менеджер метаданных операции переноса узлов иерархии>
':Назначение:
'	Предоставляет набор классов и фукнций для работы с описаниями операции переноса узлов иерархии в метаданных.
'===============================================================================
'@@!!FUNCTIONS_xx-tree-drag-drop-md-manager
'<GROUP !!FILE_xx-tree-drag-drop-md-manager><TITLE Функции и процедуры>
'@@!!CLASSES_xx-tree-drag-drop-md-manager
'<GROUP !!FILE_xx-tree-drag-drop-md-manager><TITLE Классы>

Option Explicit

Dim g_oXXTreeDragDropMDManagerCache ' Глобальный кеш менеджеров для каждой иерархии с метаимененм
Set g_oXXTreeDragDropMDManagerCache = CreateObject("Scripting.Dictionary")

'===============================================================================
' Функция полученияменеджера метаданных операции переноса для иерархии с заданным метаименем
' Менеджер ищется в кеше, если не найдем -создадим новый
Function XX_GetTreeDragDropMDManager(sMetaname)
    Dim oManager
    Set XX_GetTreeDragDropMDManager = Nothing
    
    If g_oXXTreeDragDropMDManagerCache.Exists(sMetaname) Then
        Set oManager = g_oXXTreeDragDropMDManagerCache.Item(sMetaname)
    Else
        Set oManager = New XXTreeDragDropMDManagerClass
        oManager.Init sMetaname
        Set g_oXXTreeDragDropMDManagerCache.Item(sMetaname) = oManager
    End If
    Set XX_GetTreeDragDropMDManager = oManager
End Function

'===============================================================================
' Менеджер метаданных операции переноса узлов иерархии
' Позволяет для заданного пути в иерархии получить из метадданых описание операции переноса узлов
' Реализует кеширование описаний операции переноса для уровня иерархии или типа объектов
Class XXTreeDragDropMDManagerClass
    
    Private m_sNodeDragLoaderUrl    ' урл загрузчика метаданных
    Private m_sMetaname             ' метанаименование иерархии
    Private m_oNodeDragCache        ' кеш описаний операций переноса
    
    '===============================================================================
    ' "Конструктор"
    Private Sub Class_Initialize
        Set m_oNodeDragCache = Nothing
    End Sub
    
    '===============================================================================
    ' Инициализация    
    Public Sub Init(sMetaname)
        m_sMetaname = sMetaname
        m_sNodeDragLoaderUrl = "xx-tree-node-drag.aspx?METANAME=" & m_sMetaName
        Set m_oNodeDragCache = CreateObject("Scripting.Dictionary")
    End Sub
    
    '==============================================================================
	'	Создает и возвращает Xml-запрос на получение операции переноса (для x-tree-node-drag.aspx)
	Private Function CreateNodeDragRequest(aPath)	' As XMLDOMElement
		Dim oNode			'  XMLDOMNode
		Dim oNodeDragPostData	'  Данные
		Dim i
		' Создадим объект для отсылки данных
		Set oNodeDragPostData = XService.XMLGetDocument
		' Синхронно
		oNodeDragPostData.async = False
		oNodeDragPostData.appendChild oNodeDragPostData.createProcessingInstruction("xml","version=""1.0"" encoding=""windows-1251""") 
		oNodeDragPostData.appendChild oNodeDragPostData.createElement("tree-node-drag-request")
		Set oNode = oNodeDragPostData.documentElement
		For i=0 To UBound(aPath) Step 2
			set oNode = oNode.appendChild(oNodeDragPostData.createElement("n"))
			oNode.setAttribute "ot", aPath(i)
			oNode.setAttribute "id", aPath(i+1)
		Next
		Set oNode = oNodeDragPostData.documentElement.appendChild(oNodeDragPostData.createElement("restrictions"))
		
		Set CreateNodeDragRequest = oNodeDragPostData
	End Function
	
	'==============================================================================
	' Возвращает путь до текущего узла в котором перечисленны только тип узлов. 
	Private Function GetPathOfTypes(aPath)	' As String
		Dim sPath	' формируемый путь
		Dim i
		
		GetPathOfTypes = Null
		
		If Ubound(aPath) < 1 Then Exit Function
		
		For i=0 To Ubound(aPath) Step 2
			If Len(sPath) > 0 Then sPath = sPath & "|"
			sPath = sPath & aPath(i)
		Next
		GetPathOfTypes = sPath
	End Function
    
	'==============================================================================
    ' Функция получения описания операции переноса из метаданных для заданного пути в иерархии
    ' Это "интерфейсный метод", если потребуется альтернативная реализация менеджера метаданных, 
    ' он должен реализовывать такой метод.
    Public Function GetMDByPath(sTreePath)
        Dim sNodeDragLoaderUrl  ' урл страницы получения получения операции переноса (x-tree-node-drag.aspx)
		Dim aPath				' Путь до узла
		Dim oNodeDragCached		' закешированное описание операции переноса
		Dim oNodeDragPostData	' узел tree-node-drag-request для посылки на сервер
		Dim sKeyPath			' ключ в кеше - путь от корня до текущего узла
		Dim sKeyType			' ключ в кеше - тип текущего узла
		Dim oXmlHTTP            ' Msxml2.XMLHTTP
		Dim oNodeDragXml        ' Описение операции переноса
		
		Set GetMDByPath = Nothing
		
		aPath = Split(sTreePath,"|")
		' Не выбран узел, выходим
		If UBound(aPath) < 1 Then
			Exit Function
		End If	

        ' Пощем в кеше
		Set oNodeDragCached = Nothing
		sKeyPath = "path:" & GetPathOfTypes(aPath)
		sKeyType = "type:" & aPath(0)
		If m_oNodeDragCache.Exists(sKeyPath) Then
			Set oNodeDragCached = m_oNodeDragCache.Item(sKeyPath)
		ElseIf m_oNodeDragCache.Exists(sKeyType) Then
			Set oNodeDragCached = m_oNodeDragCache.Item(sKeyType)
		End If
		If Not oNodeDragCached Is Nothing Then
			Set GetMDByPath = oNodeDragCached
			Exit Function
		End If
		' закешированного нет
		' создадим xml-запрос загрузчику меню
		Set oNodeDragPostData = CreateNodeDragRequest(aPath)
		' создадим объект для синхронной загрузки xml
		Set oXmlHTTP = CreateObject( "Msxml2.XMLHTTP")
		' Формируем URL меню
		sNodeDragLoaderUrl = m_sNodeDragLoaderUrl & "&tm=" & CDbl(Now)
		' Пошлем запрос на сервер синхронно (false в 3-м параметре)
		oXmlHTTP.open "POST", sNodeDragLoaderUrl, False
		oXmlHTTP.send oNodeDragPostData 
		' Проверим респонс и выдерним из него описание
		Set oNodeDragXml = CheckNodeDragRequestResponse(oXmlHTTP)
		' Закешируем описание
		CacheNodeDrag oNodeDragXml, aPath
		Set GetMDByPath = oNodeDragXml
    End Function
    
	'==============================================================================
    ' Функция добавления в кеш описания операци переноса
    Private Sub CacheNodeDrag(oNodeDragXml, aPath)
        Dim sKey                ' Ключ кеша
        
        ' Не выбран узел, выходим
		If UBound(aPath) < 1 Then
			Exit Sub
		End If     
                
        ' Проверим, задан ли способ кеширования
		If Not IsNull(oNodeDragXml.getAttribute("cache-for")) Then
			If oNodeDragXml.getAttribute("cache-for") = "type" Then
				sKey = "type:" & aPath(0)
			ElseIf oNodeDragXml.getAttribute("cache-for") = "level" Then
				sKey = "path:" & GetPathOfTypes(aPath)
			End If
			Set m_oNodeDragCache.Item(sKey) = oNodeDragXml
		End If
    End Sub
    
    '==============================================================================
    ' проверяет на корректность ответ от загрузчика описания операции переноса (по умолчанию x-tree-node-drag.aspx)
    '	[in] oXmlHttp - объект XMLHTTP, ответ от которого проверяем
    '	[retval] - если ответ корректный, xml-возвращает содержимое ответ (IXMLDOMElement корневого узла)
    Private Function CheckNodeDragRequestResponse(oXmlHttp)	' As XMLDOMElement
	    Const vbByteArray = &h2011	' Единственный тип массивов, которые обрабатываем
	    Dim oNodeDragXML				' IXMLDOMDocument пришедшего меню
	    DIm sError
    	
	    Set CheckNodeDragRequestResponse = Nothing
	    ' 400 - максимальный НЕОШИБОЧНЫЙ статус отклика
	    If oXmlHttp.status > 400 Then
	        sError = _
	            "Ошибка на сервере" & vbNewline & _
	            oXmlHttp.status & vbNewline & _
	            XService.HTMLEncodeLite(oXmlHttp.statusText) & vbNewline & _
	            "Информация для администратора:" & vbNewline & _
	            XService.HTMLEncodeLite(XService.ByteArrayToText(oXmlHttp.responseBody))
		    Err.Raise vbObjectError, "CheckNodeDragRequestResponse", sError
		    Exit Function 
	    End If
    			
	    ' Могло прийти пустое меню
	    If vbByteArray <> VarType(oXmlHttp.responseBody) Then
		    sError = _
		        "Ошибка на сервере" & vbNewline & _
		        "TypeName(oXmlHttp.responseBody)=" & VarType( oXmlHttp.responseBody) & vbNewline & _
		        "http status:" & oXmlHttp.status
		    On Error Resume Next
		    sError = _
		        sError & vbNewLine & _
		        "Информация для администратора:" & vbNewline & _
		        XService.HTMLEncodeLite(XService.ByteArrayToText(oXmlHttp.responseBody))
		    On Error GoTo 0
		    Err.Raise vbObjectError, "CheckNodeDragRequestResponse", sError
		    Exit Function 
	    End If
    	
	    ' Могло прийти пустое меню
	    If 0 > UBound( oXmlHttp.responseBody) Then
		    sError = _
		        "Ошибка на сервере" & vbNewline & _
		        "UBound=" & UBound(oXmlHttp.responseBody)
		    Err.Raise vbObjectError, "CheckNodeDragRequestResponse", sError
		    Exit Function 
	    End If
    	
	    Set oNodeDragXML = XService.XmlFromString(XService.ByteArrayToText(oXmlHttp.responseBody ))	
	    ' А пришел ли нам корректный XML?
	    If oNodeDragXML Is Nothing Then
		    sError = _
		        "Ошибка на сервере - пришел неверный XML" & vbNewline & _
		        XService.HTMLEncodeLite(XService.ByteArrayToText(oXmlHttp.responseBody))
		    Err.Raise vbObjectError, "CheckNodeDragRequestResponse", sError
		    Exit Function
	    End If
	    If oNodeDragXML.nodeName = "x-res" Then
		    ' xml пришел корректный, но это сообщение об ошибке
		    sError = oNodeDragXML.GetAttribute("usr-msg")
		    Err.Raise vbObjectError, "CheckNodeDragRequestResponse", sError
		    Exit Function
	    End If
	    ' если дошли до сюда, значит все хорошо	
	    Set CheckNodeDragRequestResponse = oNodeDragXML
    End Function

    '==============================================================================
    ' Чистим кеш    
    Public Sub Dispose
        Set m_oNodeDragCache = Nothing
    End Sub
    
End Class