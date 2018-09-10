Option Explicit

' ����� �������/��������� ��� �������� � ���������, ���������� �����-���� ������� � ���������� (Incident)
' ������������ � ���������� ��������� (s-Incident-editor), ������� (s-Task-editor*)


'==============================================================================
' ��������� ���������� ����� ����������� ������������ � ���������� �������
'	[in] oPool As XObjectPool
'	[in] oTask - xml-������� ������� (Task)
Function getTaskTimeSpent(oPool, oTask)
	Dim oTimeSpentList	' xml-�������� "�������� �������" ("TimeSpentList") ������� "�������" (Task)
	Dim oTimeSpent		' xml-������ "�������� ������� �� �������" (TimeSpent)
	Dim nTimeSpent		' ������������ ���������
	
	Set oTimeSpentList = g_oPool.LoadXmlProperty(oTask,"TimeSpentList")
	nTimeSpent = 0
	For Each oTimeSpent In oTimeSpentList.SelectNodes("*")
		nTimeSpent = nTimeSpent + oPool.GetPropertyValue(oTimeSpent, "Spent")
	Next
	getTaskTimeSpent = nTimeSpent
End Function


'==============================================================================
' ������� ��� i:to-string ������� TimeSpent (�������� ��������)
Function getTimeSpentPresentation(oPool, oTimeSpent)
	Dim oEmployee
	Set oEmployee = oPool.GetXmlObjectByOPath(oTimeSpent, "Task.Worker")
	getTimeSpentPresentation = "�������� ������� ���������� " & oEmployee.selectSingleNode("LastName").text & " " & oEmployee.selectSingleNode("FirstName").text
End Function
