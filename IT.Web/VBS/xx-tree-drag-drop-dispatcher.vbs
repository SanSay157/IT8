'===============================================================================
'@@!!FILE_xx-tree-drag-drop-dispatcher
'<GROUP !!SYMREF_VBS>
'<TITLE xx-tree-drag-drop-dispatcher - Диспетчер операции переноса узла иерархии>
':Назначение:
'	Предоставляет набор классов и фукнций для организации обработки операции переноса 
'   узлов иерархии на основе описания в метаданных для уровня иерархии или типа объектов.
'===============================================================================
'@@!!FUNCTIONS_xx-tree-drag-drop-dispatcher
'<GROUP !!FILE_xx-tree-drag-drop-dispatcher><TITLE Функции и процедуры>
'@@!!CLASSES_xx-tree-drag-drop-dispatcher
'<GROUP !!FILE_xx-tree-drag-drop-dispatcher><TITLE Классы>

Option Explicit

'===============================================================================
' Функция регистрации диспетчера
' По метаимени иерархии получает менеджер метаданных операции переноса
' Подписывает диспетчер на события контроллера
Sub XX_RegisterXXTreeDragDropDispatcher(sMetaname, oDragDropController)
    Dim oDispatcher
    Set oDispatcher = New XXTreeDragDropDispatcherClass
    oDispatcher.Init XX_GetTreeDragDropMDManager(sMetaName)
    oDragDropController.EventEngine.AddHandlerForEvent "BeforeNodeDrag", oDispatcher, "OnBeforeNodeDrag"
    oDragDropController.EventEngine.AddHandlerForEvent "NodeDrag", oDispatcher, "OnNodeDrag"
    oDragDropController.EventEngine.AddHandlerForEvent "NodeDragOver", oDispatcher, "OnNodeDragOver"
    oDragDropController.EventEngine.AddHandlerForEvent "NodeDragDrop", oDispatcher, "OnNodeDragDrop"
    oDragDropController.EventEngine.AddHandlerForEvent "NodeDragCanceled", oDispatcher, "OnNodeDragCanceled"
End Sub


'===============================================================================
' Диспетчер операции переноса
' Диспетчер предназначен для пересылки сообщений о переносе контроллеру, 
' отвечающему за соответствующий уровень иерархии или тип объектов.
' Непосредственно с контролом иерархи работает контроллер.
' Диспетчер подписывается на события этого контроллера и на основании
' данных текущего узла пересылает сообщения другим контроллерам,
' затветственным за конккретный уровень иерархии или тип объектов.
' Данные для инициализации контроллеров берутся из метаданных иерархии.
' Для работы с метаданными используется менеджер метаданных операции переноса.
' В текущей реализации диспетчер может работать только с именованными иерархиями (i:tree-struct[@n])
' Это вызвано тем, что только с такими иерархиями может работать менеджер метаданных операции переноса.
' Также диспетчер кеширует экземпляры контроллеров для уровней иерархии и типов объектов.
Class XXTreeDragDropDispatcherClass
    
    Private m_oMDManager            ' менеджер метаданных операции переноса
    Private m_oControllersCache     ' кеш контроллеров
    Private m_oCurrentController    ' контроллер для текущей операции переноса
    Private m_sCurrentPath          ' Пусть к текущему переносимому узлу
    
    '===============================================================================
    ' "Конструктор"
    Private Sub Class_Initialize
        Set m_oMDManager = Nothing
        Set m_oCurrentController = Nothing
        m_sCurrentPath = Null
        Set m_oControllersCache = CreateObject("Scripting.Dictionary")
    End Sub
    
    '===============================================================================
    ' Инициализация 
    Public Sub Init(oMDManager)
        Set m_oMDManager = oMDManager
    End Sub
	
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
    ' Функция пытается по переданному пути получить закешированный контроллер.
    ' Если не получается, то используя менеджер метаданных пытаемся получить описание
    ' операции переноса из метаданных и создать контроллер на его основании    
    Private Function GetController(sTreePath)
        Dim oController ' контроллер   
        Dim oNodeDrag   ' описнаие операции переноса из метаданных
        Dim aPath       ' пусть в виде массива
        Dim sKeyPath    ' ключ кеша для уровня иерархии, соответствующего переданному пути 
        Dim sKeyType    ' ключ кеша для типа объекта
        Dim sKey        ' ключ кеша для нового контроллера
        Dim oNode       ' переменная для работы с переменными описания операции переноса
        
        Set GetController = Nothing
        
        aPath = Split(sTreePath,"|")
        ' Узел не выбран - уходим
		If UBound(aPath) < 1 Then
			Exit Function
		End If
        
        ' Пытаемся найти контроллер для переданного пути в кеше
        Set oController = Nothing
		sKeyPath = "path:" & GetPathOfTypes(aPath)
		sKeyType = "type:" & aPath(0)
		If m_oControllersCache.Exists(sKeyPath) Then
			Set oController = m_oControllersCache.Item(sKeyPath)
		ElseIf m_oControllersCache.Exists(sKeyType) Then
			Set oController = m_oControllersCache.Item(sKeyType)
		End If
		' Не нашли - лезем в метаданные, пытаемся на основе их создать новый контроллер
		If oController Is Nothing Then
	        Set oNodeDrag = m_oMDManager.GetMDByPath(sTreePath)
	        ' В метаданнных для переданного пути есть описание операции переноса
            If Not oNodeDrag Is Nothing Then
                If oNodeDrag.HasChildNodes Then
                    ' Создаем новый контроллер и подписываем обработчики событий, указанные в метаданных
                    Set oController = New TreeNodeDragDropController
                    If oNodeDrag.GetAttribute("allow-self-drop") = "1" Then oController.AllowSelfDrop = True
                    If oNodeDrag.GetAttribute("allow-drop-to-parent") = "1" Then oController.AllowDropParent = True
		            If oNodeDrag.GetAttribute("allow-drop-beside") = "1" Then oController.AllowDropBeside = True
		            If oNodeDrag.GetAttribute("allow-drop-to-subtree") = "1" Then oController.AllowDropToSubtree = True
                    For Each oNode In oNodeDrag.SelectNodes("ie:before-node-drag-handler")
                        If oNode.GetAttribute("mode") = "replace" Then
                            oController.EventEngine.ReplaceHandlerForEvent "BeforeNodeDrag", Nothing, oNode.NodeTypedValue                        
                        Else
                            oController.EventEngine.AddHandlerForEvent "BeforeNodeDrag", Nothing, oNode.NodeTypedValue
                        End If
                    Next
                    For Each oNode In oNodeDrag.SelectNodes("ie:node-drag-handler")
                        If oNode.GetAttribute("mode") = "replace" Then
                            oController.EventEngine.ReplaceHandlerForEvent "NodeDrag", Nothing, oNode.NodeTypedValue                        
                        Else
                            oController.EventEngine.AddHandlerForEvent "NodeDrag", Nothing, oNode.NodeTypedValue
                        End If
                    Next
                    For Each oNode In oNodeDrag.SelectNodes("ie:node-drag-over-handler")
                        If oNode.GetAttribute("mode") = "replace" Then
                            oController.EventEngine.ReplaceHandlerForEvent "NodeDragOver", Nothing, oNode.NodeTypedValue                        
                        Else
                            oController.EventEngine.AddHandlerForEvent "NodeDragOver", Nothing, oNode.NodeTypedValue
                        End If
                    Next
                    For Each oNode In oNodeDrag.SelectNodes("ie:after-node-drag-over-handler")
                        If oNode.GetAttribute("mode") = "replace" Then
                            oController.EventEngine.ReplaceHandlerForEvent "AfterNodeDragOver", Nothing, oNode.NodeTypedValue                        
                        Else
                            oController.EventEngine.AddHandlerForEvent "AfterNodeDragOver", Nothing, oNode.NodeTypedValue
                        End If
                    Next
                    For Each oNode In oNodeDrag.SelectNodes("ie:node-drag-drop-handler")
                        If oNode.GetAttribute("mode") = "replace" Then
                            oController.EventEngine.ReplaceHandlerForEvent "NodeDragDrop", Nothing, oNode.NodeTypedValue                        
                        Else
                            oController.EventEngine.AddHandlerForEvent "NodeDragDrop", Nothing, oNode.NodeTypedValue
                        End If
                    Next
                    For Each oNode In oNodeDrag.SelectNodes("ie:node-drag-canceled-handler")
                        If oNode.GetAttribute("mode") = "replace" Then
                            oController.EventEngine.ReplaceHandlerForEvent "NodeDragCanceled", Nothing, oNode.NodeTypedValue                        
                        Else
                            oController.EventEngine.AddHandlerForEvent "NodeDragCanceled", Nothing, oNode.NodeTypedValue
                        End If
                    Next
                    ' Если указан способ кеширования, кешируем
                    If Not IsNull(oNodeDrag.getAttribute("cache-for")) Then
			            If oNodeDrag.getAttribute("cache-for") = "type" Then
				            sKey = "type:" & aPath(0)
			            ElseIf oNodeDrag.getAttribute("cache-for") = "level" Then
				            sKey = "path:" & GetPathOfTypes(aPath)
			            End If
			            Set m_oControllersCache.Item(sKey) = oController
		            End If
		        End If
            End If
		End If
	    Set GetController = oController		
    End Function
    
	'==============================================================================
    ' Обработчик инициализации операции переноса
    ' Определяет контроллер для текущей операции переноса
    ' Далее в рамках этой операции переноса события будут пересылаться этому контроллеру 
    Public Sub OnBeforeNodeDrag(oSender, oEventArgs)
        'If Not IsNull(m_sCurrentPath) Then Err.Raise vbObjectError, "XXTreeDragDropDispatcherClass.OnBeforeNodeDrag", "Неверный путь для текущего узла"
        'If HasValue(m_oCurrentController) Then Err.Raise vbObjectError, "XXTreeDragDropDispatcherClass.OnBeforeNodeDrag", "Определен текущий контроллер"
        
        ' Запоминаем текущий путь
        m_sCurrentPath = oEventArgs.SourceNode.Path      
        ' Пытаемся определить контроллер  
        Set m_oCurrentController = GetController(m_sCurrentPath)
        
        ' Если для текущего узла не удалось определить контроллер операции переноса - запрещаем перенос
        If Not HasValue(m_oCurrentController) Then
            oEventArgs.Cancel = True
            oEventArgs.CanDrag = False
            Exit Sub
        End If
        
        ' Пересылаем сообщение контроллеру
        m_oCurrentController.OnBeforeNodeDragInternal oSender, oEventArgs       
    End Sub
    
    '==============================================================================
    ' Обработчик начала операции переноса
    Public Sub OnNodeDrag(oSender, oEventArgs)
        Dim sPath
        
        ' Проверим путь переносимого узла, он должен быть таким же, как при инициализации операции переноса
        sPath = oEventArgs.SourceNode.Path  
        If sPath <> m_sCurrentPath Then Err.Raise vbObjectError, "XXTreeDragDropDispatcherClass.OnNodeDrag", "Неверный путь для текущего узла"
        If Not HasValue(m_oCurrentController) Then Err.Raise vbObjectError, "XXTreeDragDropDispatcherClass.OnNodeDrag", "Не определен текущий контроллер"
        ' Пересылаем сообщение контроллеру
        m_oCurrentController.OnNodeDragInternal oSender, oEventArgs
    End Sub
    
    '==============================================================================
    ' Обработчик проноса переносимого узла над узлом или вне узлов
    Public Sub OnNodeDragOver(oSender, oEventArgs)
        Dim sPath
        
        ' Проверим путь переносимого узла, он должен быть таким же, как при инициализации операции переноса
        sPath = oEventArgs.SourceNode.Path  
        If sPath <> m_sCurrentPath Then Err.Raise vbObjectError, "XXTreeDragDropDispatcherClass.OnNodeDragOver", "Неверный путь для текущего узла"
        If Not HasValue(m_oCurrentController) Then Err.Raise vbObjectError, "XXTreeDragDropDispatcherClass.OnNodeDragOver", "Не определен текущий контроллер"
        ' Пересылаем сообщение контроллеру
        m_oCurrentController.OnNodeDragOverInternal oSender, oEventArgs
    End Sub
    
    '==============================================================================
    ' Обработчик окончания операции переноса
    Public Sub OnNodeDragDrop(oSender, oEventArgs)
        Dim sPath
        
        ' Проверим путь переносимого узла, он должен быть таким же, как при инициализации операции переноса
        sPath = oEventArgs.SourceNode.Path  
        If sPath <> m_sCurrentPath Then Err.Raise vbObjectError, "XXTreeDragDropDispatcherClass.OnNodeDragDrop", "Неверный путь для текущего узла"
        If Not HasValue(m_oCurrentController) Then Err.Raise vbObjectError, "XXTreeDragDropDispatcherClass.OnNodeDragDrop", "Не определен текущий контроллер"
        ' Пересылаем сообщение контроллеру
        m_oCurrentController.OnNodeDragDropInternal oSender, oEventArgs
        
        'Set m_oCurrentController = Nothing
        'm_sCurrentPath = Null
    End Sub
    
    '==============================================================================
    ' Обработчик отмены операции переноса
    Public Sub OnNodeDragCanceled(oSender, oEventArgs)
        Dim sPath
        
        ' Проверим путь переносимого узла, он должен быть таким же, как при инициализации операции переноса
        sPath = oEventArgs.SourceNode.Path  
        If sPath <> m_sCurrentPath Then Err.Raise vbObjectError, "XXTreeDragDropDispatcherClass.OnNodeDragCancel", "Неверный путь для текущего узла"
        If Not HasValue(m_oCurrentController) Then Err.Raise vbObjectError, "XXTreeDragDropDispatcherClass.OnNodeDragCancel", "Не определен текущий контроллер"
        ' Пересылаем сообщение контроллеру
        m_oCurrentController.OnNodeDragCanceledInternal oSender, oEventArgs
        
        'Set m_oCurrentController = Nothing
        'm_sCurrentPath = Null
    End Sub

    '==============================================================================
    ' Чистим кеш и ссылку на основной контироллер  
    Public Sub Dispose
        m_oMDManager.Dispose
        Set m_oControllersCache = Nothing
        Set m_oCurrentController = Nothing
    End Sub
    
End Class