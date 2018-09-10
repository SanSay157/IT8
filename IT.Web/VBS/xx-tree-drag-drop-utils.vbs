'===============================================================================
'@@!!FILE_xx-tree-drag-drop-utils
'<GROUP !!SYMREF_VBS>
'<TITLE xx-tree-drag-drop-utils - Утилитарные функции для операции переноса>
':Назначение:
'	Набор функций, которые могут быть полезны при отладке операции переноса,
'   таких как вывод информации о переносе в статусбар.
'   
'===============================================================================
'@@!!FUNCTIONS_xx-tree-drag-drop-utils
'<GROUP !!FILE_xx-tree-drag-drop-utils><TITLE Функции и процедуры>
'@@!!CLASSES_xx-tree-drag-drop-utils
'<GROUP !!FILE_xx-tree-drag-drop-utils><TITLE Классы>

Option Explicit

Dim g_nXXNodeDragStatusTimeout 
g_nXXNodeDragStatusTimeout = Null

'===============================================================================
' Обработчик события BeforeNodeDrag
Sub XXNodeDragStatusOnBeforeNodeDrag(oSender, oEventArgs)
    If Not IsNull(g_nXXNodeDragStatusTimeout) Then 
        window.clearTimeout g_nXXNodeDragStatusTimeout
        g_nXXNodeDragStatusTimeout = Null
    End If
    window.status = oEventArgs.SourceNode.Text
End Sub

'===============================================================================
' Обработчик события NodeDrag
Sub XXNodeDragStatusOnNodeDrag(oSender, oEventArgs)
    If Not IsNull(g_nXXNodeDragStatusTimeout) Then 
        window.clearTimeout g_nXXNodeDragStatusTimeout
        g_nXXNodeDragStatusTimeout = Null
    End If
    window.status = oEventArgs.SourceNode.Text & " - "
End Sub

'===============================================================================
' Обработчик события AfterNodeDragOver
Sub XXNodeDragStatusOnAfterNodeDragOver(oSender, oEventArgs)
    If Not IsNull(g_nXXNodeDragStatusTimeout) Then 
        window.clearTimeout g_nXXNodeDragStatusTimeout
        g_nXXNodeDragStatusTimeout = Null
    End If
    If HasValue(oEventArgs.TargetNode) And oEventArgs.CanDrop Then 
        window.status = oEventArgs.SourceNode.Text & " - " & oEventArgs.TargetNode.Text
    Else
        window.status = oEventArgs.SourceNode.Text & " - "
    End If
End Sub

'===============================================================================
' Обработчик события NodeDragDrop
Sub XXNodeDragStatusOnNodeDragDrop(oSender, oEventArgs)
    If Not IsNull(g_nXXNodeDragStatusTimeout) Then 
        window.clearTimeout g_nXXNodeDragStatusTimeout
        g_nXXNodeDragStatusTimeout = Null
    End If
    window.status = "Перенос выполнен успешно"
    window.setTimeout "window.status = Empty", 3000
End Sub

'===============================================================================
' Обработчик события NodeDragCanceled
Sub XXNodeDragStatusOnNodeDragCanceled(oSender, oEventArgs)
    If Not IsNull(g_nXXNodeDragStatusTimeout) Then 
        window.clearTimeout g_nXXNodeDragStatusTimeout
        g_nXXNodeDragStatusTimeout = Null
    End If
    window.status = "Перенос отменен"
    window.setTimeout "window.status = Empty", 3000
End Sub
