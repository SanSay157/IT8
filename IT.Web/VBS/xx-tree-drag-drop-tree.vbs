'===============================================================================
'@@!!FILE_xx-tree-drag-drop-tree
'<GROUP !!SYMREF_VBS>
'<TITLE xx-tree-drag-drop-tree - Скрипт для подключения диспетчера операции переноса узлов иерархии на страницу x-tree.aspx>
':Назначение:
'	Подключает диспетчер операции переноса узлов иерархии на страницу x-tree.aspx.
'===============================================================================
'@@!!FUNCTIONS_xx-tree-drag-drop-tree
'<GROUP !!FILE_xx-tree-drag-drop-tree><TITLE Функции и процедуры>
'@@!!CLASSES_xx-tree-drag-drop-tree
'<GROUP !!FILE_xx-tree-drag-drop-tree><TITLE Классы>

Option Explicit

X_RegisterStaticHandler "usrXTree_OnLoad", "RegisterXXTreeDragDropDispatcher"

'===============================================================================
' При загрузке иерархии подключим диспетчер к ее контроллеру
Sub RegisterXXTreeDragDropDispatcher(oSender, oEventArgs)
    XX_RegisterXXTreeDragDropDispatcher oSender.MetaName, oSender.DragDropController
End Sub