Option Explicit

' Общие функции/процедуры для операций с объектами, связанными каким-либо образом с Инцидентом (Incident)
' Используется в редакторах Инцидента (s-Incident-editor), Задания (s-Task-editor*)


'==============================================================================
' Возврщает количество минут затраченных исполнителем в переданном задании
'	[in] oPool As XObjectPool
'	[in] oTask - xml-объекта Задания (Task)
Function getTaskTimeSpent(oPool, oTask)
	Dim oTimeSpentList	' xml-свойство "Списания времени" ("TimeSpentList") объекта "Задание" (Task)
	Dim oTimeSpent		' xml-объект "Списание времени по заданию" (TimeSpent)
	Dim nTimeSpent		' возвращаемый результат
	
	Set oTimeSpentList = g_oPool.LoadXmlProperty(oTask,"TimeSpentList")
	nTimeSpent = 0
	For Each oTimeSpent In oTimeSpentList.SelectNodes("*")
		nTimeSpent = nTimeSpent + oPool.GetPropertyValue(oTimeSpent, "Spent")
	Next
	getTaskTimeSpent = nTimeSpent
End Function


'==============================================================================
' Функция для i:to-string объекта TimeSpent (Списание времение)
Function getTimeSpentPresentation(oPool, oTimeSpent)
	Dim oEmployee
	Set oEmployee = oPool.GetXmlObjectByOPath(oTimeSpent, "Task.Worker")
	getTimeSpentPresentation = "Списание времени сотрудника " & oEmployee.selectSingleNode("LastName").text & " " & oEmployee.selectSingleNode("FirstName").text
End Function
