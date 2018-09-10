'Обработчик редактора для объекта "Folder"
Option Explicit

'==============================================================================
' Финальные проверки при сохранении
Sub usrXEditor_OnValidate(oSender, oEventArgs)
    If oSender.XmlObject.selectSingleNode("DateBegin").nodeTypedValue > oSender.XmlObject.selectSingleNode("DateEnd").nodeTypedValue Then
        oEventArgs.ReturnValue = False
	    oEventArgs.ErrorMessage ="Дата начала периода должна быть меньше либо равна дате окончания периода"
    End If

    Dim oEmployment : Set oEmployment = oSender.XmlObject
    Dim oProjectParticipant : Set oProjectParticipant = oSender.Pool.GetXmlObjectByOPath(oEmployment, "ProjectParticipant")
    Dim oEmployments: Set oEmployments = oSender.Pool.GetXmlObjectsByOPath(oProjectParticipant, "Employment")

    Dim sFolderID
    Dim dtDateBegin
    Dim dtDateEnd
    Dim sEmployeeID
    Dim nEmployment : nEmployment = 0

    dtDateBegin = oEmployment.SelectSingleNode("DateBegin").nodeTypedValue
    dtDateEnd = oEmployment.SelectSingleNode("DateEnd").nodeTypedValue
    sFolderID = oProjectParticipant.SelectSingleNode("Folder/Folder").getAttribute("oid")
    sEmployeeID = oProjectParticipant.SelectSingleNode("Employee/Employee").getAttribute("oid")
    If CheckEmploymentDates(oEmployments, dtDateBegin, dtDateEnd, oEmployment.getAttribute("oid")) Then
        oEventArgs.Cancel = True
        oEventArgs.ReturnValue = False
        oEventArgs.ErrorMessage = "Указанный период совпадает либо пересекается с периодом, созданным ранее."
        Exit Sub
    End If
    Dim sOutMsg : sOutMsg = Empty
    nEmployment = GetEmploymentSum(dtDateBegin,dtDateEnd,sFolderID,sEmployeeID, sOutMsg) + oEmployment.SelectSingleNode("Percent").nodeTypedValue
    If nEmployment > 100 Then
    Dim vbRet	' Результат выбора пользователя, в сообщениях подтверждения
        vbRet = MsgBox ( _
	        "Занятость сотрудника на проектах в планируемый период превышает 100 %: " & vbNewLine & sOutMsg & vbNewLine & "Продолжить?", _
	        vbYesNo + vbQuestion, "Внимание!" )	
        If ( vbNo = vbRet ) Then
	        oEventArgs.ErrorMessage = "Пожалуйста, задайте корректные данные."
	        oEventArgs.Cancel = True
            oEventArgs.ReturnValue = False
            Exit Sub
        End If
    End If 
    
End Sub 

' Функция проверки пересечения временных отрезков занятости сотрудника на проекте
Function CheckEmploymentDates(oEmployments, dtBeginDate, dtEndDate, sObjectID )
    CheckEmploymentDates = False
    Dim oEmployment
    For Each oEmployment In oEmployments
        If oEmployment.getAttribute("oid") <> sObjectID Then
            If (dtBeginDate >= oEmployment.SelectSingleNode("DateBegin").nodeTypedValue  And dtBeginDate <= oEmployment.SelectSingleNode("DateEnd").nodeTypedValue ) Or (dtEndDate >= oEmployment.SelectSingleNode("DateBegin").nodeTypedValue  And dtEndDate <= oEmployment.SelectSingleNode("DateEnd").nodeTypedValue ) Then
                CheckEmploymentDates = True
                Exit Function
            End If    
        End If        
    Next
End Function

' Функция возвращает суммарную занятость сотрудника на других (!) проектах в заданный период времени
' Изпользуется в дальнейшем для проверки того, что недобросовестные менеджеры заставляют сотрудника работать более чем на 100% 
 Function GetEmploymentSum(dtBeginDate, dtEndDate, sFolderID, sEmpID, sOutMessage)
    Dim aResult
    GetEmploymentSum = 0 
    aResult = GetFirstRowValuesFromDataSource("GetEmployeeEmployment", Array("EmployeeID","FolderID","DateBegin", "DateEnd"), Array(sEmpID, sFolderID, X_DateToXmlType(dtBeginDate,true), X_DateToXmlType(dtEndDate,true)))
    If hasValue(aResult(0)) Then
        GetEmploymentSum = CLng(aResult(0))
        Dim oXml: Set oXml = XService.XmlFromString(aResult(1))
        Dim i
        For Each i In oXml.SelectNodes("*")
            sOutMessage = sOutMessage & i.nodeTypedValue & vbNewLine
        Next
    End If
End Function