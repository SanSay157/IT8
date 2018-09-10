'Обработчик редактора для объекта "OutLimit"
Option Explicit

Sub usrXEditor_OnValidate(oSender, oEventArgs)
    Dim oNode       'XMLDOMElement
    Dim oid         'GUID
    With oSender
        oid = .XmlObject.getAttribute("oid")

        'Проверяем отсутствие ранее сохраненного лимита с таким же типом	
        For Each oNode in .XmlObjectPool.selectNodes("OutLimit")          
            
            'Сравниваем oid типов лимита, но пропускаем создаваемый нами лимит, который уже в пуле
            If .XmlObject.selectSingleNode("OutType/OutType").getAttribute("oid") = oNode.selectSingleNode("OutType/OutType").getAttribute("oid") And _
                oid <> oNode.getAttribute("oid")then
                oEventArgs.ErrorMessage = "Лимит с данным типом уже существует!"
                oEventArgs.ReturnValue = False
                Exit Sub
            End If
        Next
    End With
End Sub