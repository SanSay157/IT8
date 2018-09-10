'===============================================================================
'@@!!FILE_x-tree-drag-drop-controller
'<GROUP !!SYMREF_VBS>
'<TITLE x-tree-drag-drop-controller - Контроллер операции drag & drop для контрола IXTreeView>
':Назначение:
'	Контроллер предназначен для реализации подписки на события операции переноса узла иерархии 
'   посредством EventEngine. Также контроллер реализует минимальную логику операции переноса:
'   запрет переноса в тот же узел, в подветку, вне дерева
'   Также определяется набор классов событий операции переноса.
'===============================================================================
'@@!!FUNCTIONS_x-tree-drag-drop-controller
'<GROUP !!FILE_x-tree-drag-drop-controller><TITLE Функции и процедуры>
'@@!!CLASSES_x-tree-drag-drop-controller
'<GROUP !!FILE_x-tree-drag-drop-controller><TITLE Классы>

Option Explicit

'===============================================================================
'@@TreeNodeBeforeDragEventArgsClass
'<GROUP !!CLASSES_x-tree-drag-drop-controller><TITLE TreeNodeBeforeDragEventArgsClass>
':Назначение:	Сообщение о начале переноса
'               Можно определить, начинаем перенос текущего узла, или нет. 
'
'@@!!MEMBERTYPE_Methods_TreeNodeBeforeDragEventArgsClass
'<GROUP TreeNodeBeforeDragEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_TreeNodeBeforeDragEventArgsClass
'<GROUP TreeNodeBeforeDragEventArgsClass><TITLE Свойства>
Class TreeNodeBeforeDragEventArgsClass
    '@@TreeNodeBeforeDragEventArgsClass.TreeView
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeBeforeDragEventArgsClass><TITLE TreeView>
	':Назначение:	Ссылка на контрол иерархии.
	':Сигнатура:	Public TreeView [As IXTreeView]
    Public TreeView
    '@@TreeNodeBeforeDragEventArgsClass.SourceNode
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeBeforeDragEventArgsClass><TITLE SourceNode>
	':Назначение:	Текущий узел иерархии.
	':Сигнатура:	Public SourceNode [As ITreeNode]
    Public SourceNode
    '@@TreeNodeBeforeDragEventArgsClass.KeyFlags
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeBeforeDragEventArgsClass><TITLE KeyFlags>
	':Назначение:	Битовый флаг, отражающий состояние удержания функциональных 
	'               клавиш Ctrl, Alt или  Shift, а так же вид нажатой клавиши (правая / левая) 
	'               мышки.
	':Сигнатура:	Public KeyFlags [As Integer]
    Public KeyFlags
    '@@TreeNodeBeforeDragEventArgsClass.CanDrag
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeBeforeDragEventArgsClass><TITLE CanDrag>
	':Назначение:	Признак разрешения операции переноса
	':Сигнатура:	Public CanDrag [As Boolean]
    Public CanDrag
    '@@TreeNodeBeforeDragEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeBeforeDragEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
    Public Cancel

    '@@TreeNodeBeforeDragEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_TreeNodeBeforeDragEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As TreeNodeBeforeDragEventArgsClass]
    Public Function Self
		Set Self = Me
	End Function
End Class

'===============================================================================
'@@TreeNodeDragEventArgsClass
'<GROUP !!CLASSES_x-tree-drag-drop-controller><TITLE TreeNodeDragEventArgsClass>
':Назначение:	Сообщение о начале переноса. 
'
'@@!!MEMBERTYPE_Methods_TreeNodeDragEventArgsClass
'<GROUP TreeNodeDragEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_TreeNodeDragEventArgsClass
'<GROUP TreeNodeDragEventArgsClass><TITLE Свойства>
Class TreeNodeDragEventArgsClass
    '@@TreeNodeDragEventArgsClass.TreeView
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragEventArgsClass><TITLE TreeView>
	':Назначение:	Ссылка на контрол иерархии.
	':Сигнатура:	Public TreeView [As IXTreeView]
    Public TreeView
    '@@TreeNodeDragEventArgsClass.SourceNode
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragEventArgsClass><TITLE SourceNode>
	':Назначение:	Текущий узел иерархии.
	':Сигнатура:	Public SourceNode [As ITreeNode]
    Public SourceNode
    '@@TreeNodeDragEventArgsClass.KeyFlags
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragEventArgsClass><TITLE KeyFlags>
	':Назначение:	Битовый флаг, отражающий состояние удержания функциональных 
	'               клавиш Ctrl, Alt или  Shift, а так же вид нажатой клавиши (правая / левая) 
	'               мышки.
	':Сигнатура:	Public KeyFlags [As Integer]
    Public KeyFlags
    '@@TreeNodeDragEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
    Public Cancel

    '@@TreeNodeDragEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_TreeNodeDragEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As TreeNodeDragEventArgsClass]
    Public Function Self
		Set Self = Me
	End Function
	
	' Вообще было бы неплохо реализовать возможность отмены операции переноса, 
	' но пока непонятно, как
    'Public ReturnValue
End Class

'===============================================================================
'@@TreeNodeDragOverEventArgsClass
'<GROUP !!CLASSES_x-tree-drag-drop-controller><TITLE TreeNodeDragOverEventArgsClass>
':Назначение:	Сообщение о проносе переносимого узла над другим узлом или вне узлов.
'               Можно определить, можно ли "отпустить" переносимый узел. 
'
'@@!!MEMBERTYPE_Methods_TreeNodeDragOverEventArgsClass
'<GROUP TreeNodeDragOverEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_TreeNodeDragOverEventArgsClass
'<GROUP TreeNodeDragOverEventArgsClass><TITLE Свойства>
Class TreeNodeDragOverEventArgsClass
    '@@TreeNodeDragOverEventArgsClass.TreeView
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragOverEventArgsClass><TITLE TreeView>
	':Назначение:	Ссылка на контрол иерархии.
	':Сигнатура:	Public TreeView [As IXTreeView]
    Public TreeView
    '@@TreeNodeDragOverEventArgsClass.SourceNode
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragOverEventArgsClass><TITLE SourceNode>
	':Назначение:	Узел иерархии, который переносим.
	':Сигнатура:	Public SourceNode [As ITreeNode]
    Public SourceNode
    '@@TreeNodeDragOverEventArgsClass.TargetNode
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragOverEventArgsClass><TITLE TargetNode>
	':Назначение:	Текущий узел иерархии, над которым проносим.
	':Примечание:   Значение может быть не задано, это значит, что проносим вне узлов
	':Сигнатура:	Public TargetNode [As ITreeNode]
    Public TargetNode
    '@@TreeNodeDragOverEventArgsClass.KeyFlags
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragOverEventArgsClass><TITLE KeyFlags>
	':Назначение:	Битовый флаг, отражающий состояние удержания функциональных 
	'               клавиш Ctrl, Alt или  Shift, а так же вид нажатой клавиши (правая / левая) 
	'               мышки.
	':Сигнатура:	Public KeyFlags [As Integer]
    Public KeyFlags
    '@@TreeNodeDragOverEventArgsClass.CanDrop
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragOverEventArgsClass><TITLE CanDrop>
	':Назначение:	Признак того, что можно "отпустить" переносимый узел в текущем месте (в узел или вне узлов)
	':Сигнатура:	Public CanDrop [As Boolean]
    Public CanDrop
    '@@TreeNodeDragOverEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragOverEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
    Public Cancel

    '@@TreeNodeDragOverEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_TreeNodeDragOverEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As TreeNodeDragOverEventArgsClass]
    Public Function Self
		Set Self = Me
	End Function
	
	'@@TreeNodeDragOverEventArgsClass.Clone
	'<GROUP !!MEMBERTYPE_Methods_TreeNodeDragOverEventArgsClass><TITLE Clone>
	':Назначение:	Возвращает ссылку на копию текущего экземпляря класса.
	':Сигнатура:	Public Function Clone() [As TreeNodeDragOverEventArgsClass]
	Public Function Clone
	    With New TreeNodeDragOverEventArgsClass
	        Set .TreeView = TreeView
	        Set .SourceNode = SourceNode
	        Set .TargetNode = TargetNode
	        .KeyFlags = KeyFlags
	        .CanDrop = CanDrop
	        .Cancel = Cancel
	        Set Clone = .Self()
	    End With
	End Function
	
	' Вообще было бы неплохо реализовать возможность отмены операции переноса, 
	' но пока непонятно, как
    'Public ReturnValue
End Class

'===============================================================================
'@@TreeNodeDragDropEventArgsClass
'<GROUP !!CLASSES_x-tree-drag-drop-controller><TITLE TreeNodeDragDropEventArgsClass>
':Назначение:	Сообщение о завершении переносе узла.
'
'@@!!MEMBERTYPE_Methods_TreeNodeDragDropEventArgsClass
'<GROUP TreeNodeDragDropEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_TreeNodeDragDropEventArgsClass
'<GROUP TreeNodeDragDropEventArgsClass><TITLE Свойства>
Class TreeNodeDragDropEventArgsClass
    '@@TreeNodeDragDropEventArgsClass.TreeView
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragDropEventArgsClass><TITLE TreeView>
	':Назначение:	Ссылка на контрол иерархии.
	':Сигнатура:	Public TreeView [As IXTreeView]
    Public TreeView
    '@@TreeNodeDragDropEventArgsClass.SourceNode
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragDropEventArgsClass><TITLE SourceNode>
	':Назначение:	Узел иерархии, который переносим.
	':Сигнатура:	Public SourceNode [As ITreeNode]
    Public SourceNode
    '@@TreeNodeDragDropEventArgsClass.TargetNode
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragDropEventArgsClass><TITLE TargetNode>
	':Назначение:	Текущий узел иерархии, над которым проносим.
	':Примечание:   Значение может быть не задано, это значит, что проносим вне узлов
	':Сигнатура:	Public TargetNode [As ITreeNode]
    Public TargetNode
    '@@TreeNodeDragDropEventArgsClass.KeyFlags
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragDropEventArgsClass><TITLE KeyFlags>
	':Назначение:	Битовый флаг, отражающий состояние удержания функциональных 
	'               клавиш Ctrl, Alt или  Shift, а так же вид нажатой клавиши (правая / левая) 
	'               мышки.
	':Сигнатура:	Public KeyFlags [As Integer]
    Public KeyFlags
    '@@TreeNodeDragDropEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragDropEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
    Public Cancel

    '@@TreeNodeDragDropEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_TreeNodeDragDropEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As TreeNodeDragDropEventArgsClass]
    Public Function Self
		Set Self = Me
	End Function
End Class

'===============================================================================
'@@TreeNodeDragCanceledEventArgsClass
'<GROUP !!CLASSES_x-tree-drag-drop-controller><TITLE TreeNodeDragCanceledEventArgsClass>
':Назначение:	Сообщение об отмене переноса. 
'
'@@!!MEMBERTYPE_Methods_TreeNodeDragCanceledEventArgsClass
'<GROUP TreeNodeDragCanceledEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_TreeNodeDragCanceledEventArgsClass
'<GROUP TreeNodeDragCanceledEventArgsClass><TITLE Свойства>
Class TreeNodeDragCanceledEventArgsClass
    '@@TreeNodeDragCanceledEventArgsClass.TreeView
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragCanceledEventArgsClass><TITLE TreeView>
	':Назначение:	Ссылка на контрол иерархии.
	':Сигнатура:	Public TreeView [As IXTreeView]
    Public TreeView
    '@@TreeNodeDragCanceledEventArgsClass.SourceNode
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragCanceledEventArgsClass><TITLE SourceNode>
	':Назначение:	Узел иерархии, который переносим.
	':Сигнатура:	Public SourceNode [As ITreeNode]
    Public SourceNode
    '@@TreeNodeDragCanceledEventArgsClass.KeyFlags
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragCanceledEventArgsClass><TITLE KeyFlags>
	':Назначение:	Битовый флаг, отражающий состояние удержания функциональных 
	'               клавиш Ctrl, Alt или  Shift, а так же вид нажатой клавиши (правая / левая) 
	'               мышки.
	':Сигнатура:	Public KeyFlags [As Integer]
    Public KeyFlags
    '@@TreeNodeDragCanceledEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragCanceledEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
    Public Cancel

    '@@TreeNodeDragCanceledEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_TreeNodeDragCanceledEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As TreeNodeDragCanceledEventArgsClass]
    Public Function Self
		Set Self = Me
	End Function
End Class

' Список событий контроллера, на которые можно подписаться
const XTREENODEDRAGDROPCONTROLLER_EVENTS = "BeforeNodeDrag,NodeDrag,NodeDragOver,AfterNodeDragOver,NodeDragDrop,NodeDragCanceled"

'==============================================================================
'@@TreeNodeDragDropController
'<GROUP !!CLASSES_x-tree-drag-drop-controller><TITLE TreeNodeDragDropController>
':Назначение:	
'   Контроллер операции переноса узла иерархии.<P/>
'   Обрабатывает сообщения от управляющего элемента IXTreeView.<P/>
'   Вызывает пользовательские обработчики событий.<P/>
'   Генерирует события BeforeNodeDrag, NodeDrag, NodeDragOver, NodeDragDrop, NodeDragCanceled.<P/>
'   Содержит предварительную обработку события NodeDragOver: учитывает атрибуты AllowSelfDrop, 
'   AllowDropToParent, AllowDropBeside, AllowDropToSubTree.
'@@!!MEMBERTYPE_Properties_TreeNodeDragDropController
'<GROUP TreeNodeDragDropController><TITLE Свойства>
Class TreeNodeDragDropController

	'@@TreeNodeDragDropController.AllowSelfDrop
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragDropController><TITLE AllowSelfDrop>
	':Назначение:	Признак разрешения переноса узла на себя
	':Примечание:	Значение по умолчанию - False
	':Сигнатура:	Public AllowSelfDrop [As Boolean]
    Private AllowSelfDrop

	'@@TreeNodeDragDropController.AllowDropToParent
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragDropController><TITLE AllowDropToParent>
	':Назначение:	Признак разрешения переноса в текущего родителя
	':Примечание:	Значение по умолчанию - False
	':Сигнатура:	Public AllowDropToParent [As Boolean]
    Private AllowDropToParent

	'@@TreeNodeDragDropController.AllowDropBeside
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragDropController><TITLE AllowDropBeside>
	':Назначение:	Признак разрешения переноса вне узлов
	':Примечание:	Значение по умолчанию - False
	':Сигнатура:	Public AllowDropBeside [As Boolean]
    Private AllowDropBeside

	'@@TreeNodeDragDropController.AllowDropToSubTree
	'<GROUP !!MEMBERTYPE_Properties_TreeNodeDragDropController><TITLE AllowDropToSubTree>
	':Назначение:	Признак разрешения переноса в поддерево
	':Примечание:	Значение по умолчанию - False
	':Сигнатура:	Public AllowDropToSubTree [As Boolean]
    Private AllowDropToSubTree

    ' экземпляр EventEngineClass
    Private m_oEventEngine
    
    '==============================================================================
	' "Конструктор"
    Private Sub Class_Initialize
        Set m_oEventEngine = X_CreateEventEngine   
        AllowSelfDrop = False
        AllowDropToParent = False
        AllowDropBeside = False
        AllowDropToSubTree = False
    End Sub
    
    '==============================================================================
	' Возвращает экземпляр EventEngineClass - объекта, поддерживающего
	' событийную модель для данного данного контроллера
	Public Property Get EventEngine
		Set EventEngine = m_oEventEngine
	End Property
    
    '==============================================================================
    ' Выбрасывание события контроллера    
    Private Sub FireEvent(sEventName, oSender, oEventArgsClass)
		XEventEngine_FireEvent m_oEventEngine, sEventName, oSender, oEventArgsClass
	End Sub	
    
    '==============================================================================
    ' Обработка события инициализации операции переноса
    ' Примечание: в bCanDrag возвращаем признак, разрешена ли операция переноса для текущего узла 
    Public Sub OnBeforeNodeDrag(oSender, oTreeView, oSourceNode, nKeyFlags, bCanDrag)
        With New TreeNodeBeforeDragEventArgsClass
            Set .TreeView = oTreeView
            Set .SourceNode = oSourceNode
            .KeyFlags = nKeyFlags
            .CanDrag = bCanDrag
            .Cancel = False
            OnBeforeNodeDragInternal oSender, .Self()
            bCanDrag = .CanDrag
        End With
    End Sub
    
    '==============================================================================
    ' Обработка события инициализации операции переноса
    ' Просто пересылаем подписчикам событие
    Public Sub OnBeforeNodeDragInternal(oSender, oEventArgsClass)
        FireEvent "BeforeNodeDrag", oSender, oEventArgsClass
    End Sub
    
    '==============================================================================
    ' Обработка события начала операции переноса
    Public Sub OnNodeDrag(oSender, oTreeView, oSourceNode, nKeyFlags)
        With New TreeNodeDragEventArgsClass
            Set .TreeView = oTreeView
            Set .SourceNode = oSourceNode
            .KeyFlags = nKeyFlags
            .Cancel = False
            OnNodeDragInternal oSender, .Self()
        End With
    End Sub
    
    '==============================================================================
    ' Обработка события начала операции переноса
    ' Просто пересылаем подписчикам событие
    Public Sub OnNodeDragInternal(oSender, oEventArgsClass)
        FireEvent "NodeDrag", oSender, oEventArgsClass
    End Sub
    
    '==============================================================================
    ' Обработка события проноса переносимого узла над узлом или вне узлов
    ' Примечание: в bCanDrop возвращаем признак, разрешено ли "отпустить" переносимый узел в текущем месте 
    ' (на узел или ввне узлов иерархии) 
    Public Sub OnNodeDragOver(oSender, oTreeView, oSourceNode, oTargetNode, nKeyFlags, bCanDrop)
        With New TreeNodeDragOverEventArgsClass
            Set .TreeView = oTreeView
            Set .SourceNode = oSourceNode
            Set .TargetNode = oTargetNode
            .KeyFlags = nKeyFlags
            .CanDrop = bCanDrop
            .Cancel = False
            OnNodeDragOverInternal oSender, .Self()
            bCanDrop = .CanDrop
        End With
    End Sub
    
    '==============================================================================
    ' Обработка события проноса переносимого узла над узлом или вне узлов
    ' Просто пересылаем подписчикам событие
    Public Sub OnNodeDragOverInternal(oSender, oEventArgsClass)
        If oEventArgsClass.TargetNode Is Nothing Then
            If Not AllowDropBeside Then 
                oEventArgsClass.CanDrop = False 
                oEventArgsClass.Cancel = True
            End If
        Else
            If Not AllowSelfDrop Then
                If oEventArgsClass.SourceNode.Path = oEventArgsClass.TargetNode.Path Then
                    oEventArgsClass.CanDrop = False 
                    oEventArgsClass.Cancel = True
                End If
            End If
            If Not AllowDropToParent Then
                If HasValue(oEventArgsClass.SourceNode.Parent) Then
                    If oEventArgsClass.SourceNode.Parent.Path = oEventArgsClass.TargetNode.Path Then
                        oEventArgsClass.CanDrop = False 
                        oEventArgsClass.Cancel = True
                    End If
                End If
            End If
            If Not AllowDropToSubTree Then
                If InStr(oEventArgsClass.TargetNode.Path, oEventArgsClass.SourceNode.Path) > 0 Then
                    oEventArgsClass.CanDrop = False 
                    oEventArgsClass.Cancel = True
                End If
            End If
        End If
        ' если уже определили, что дроп для текущего узла недоступен, не будем посылать сообщение
        If Not oEventArgsClass.Cancel Then FireEvent "NodeDragOver", oSender, oEventArgsClass
        ' пошлем копию сообщения с результатом
        ' с помошью сообщения AfterNodeDragOver можно отслеживать, можно ли вылолнить дроп на текущем узле
        ' например, можно выводить соответствующее сообщение в статусбаре или еще как-то логгировать при отладке
        ' использовать для этих целей событие NodeDragOver неудобно, потому что в некоторых случаях
        ' контроллер запрещает дроп и вообще не посылает NodeDragOver
        With oEventArgsClass.Clone()
            .Cancel = False
            FireEvent "AfterNodeDragOver", oSender, .Self() 
        End With
    End Sub
    
    '==============================================================================
    ' Обработка события переноса
    Public Sub OnNodeDragDrop(oSender, oTreeView, oSourceNode, oTargetNode, nKeyFlags)
        With New TreeNodeDragDropEventArgsClass
            Set .TreeView = oTreeView
            Set .SourceNode = oSourceNode
            Set .TargetNode = oTargetNode
            .KeyFlags = nKeyFlags
            .Cancel = False
            OnNodeDragDropInternal oSender, .Self()
        End With
    End Sub
    
    '==============================================================================
    ' Обработка события переноса
    ' Просто пересылаем подписчикам событие
    Public Sub OnNodeDragDropInternal(oSender, oEventArgsClass)
        FireEvent "NodeDragDrop", oSender, oEventArgsClass
    End Sub
    
    '==============================================================================
    ' Обработка события отмены переноса
    Public Sub OnNodeDragCanceled(oSender, oTreeView, oSourceNode, nKeyFlags)
        With New TreeNodeDragCanceledEventArgsClass
            Set .TreeView = oTreeView
            Set .SourceNode = oSourceNode
            .KeyFlags = nKeyFlags
            .Cancel = False
            OnNodeDragCanceledInternal oSender, .Self()
        End With
    End Sub
    
    '==============================================================================
    ' Обработка события отмены переноса
    ' Просто пересылаем подписчикам событие    
    Public Sub OnNodeDragCanceledInternal(oSender, oEventArgsClass)
        FireEvent "NodeDragCanceled", oSender, oEventArgsClass
    End Sub
    
    '==============================================================================
    ' Чистим EventEngine
    Public Sub Dispose
        m_oEventEngine.Dispose
    End Sub

End Class