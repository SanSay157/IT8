Option Explicit

Dim g_nSpentTimeBeforeOperation

'==============================================================================
' ���������� ��� ������������
Function GetPlannerString()
End Function


'==============================================================================
Sub usr_Task_TimeSpentList_OnBeforeCreate(oSender, oEventArgs)
	g_nSpentTimeBeforeOperation = getTaskTimeSpent(g_oPool, g_oObjectEditor.XmlObject)
End Sub

'==============================================================================
Sub usr_Task_TimeSpentList_OnBeforeEdit(oSender, oEventArgs)
	g_nSpentTimeBeforeOperation = getTaskTimeSpent(g_oPool, g_oObjectEditor.XmlObject)
End Sub

'==============================================================================
Sub usr_Task_TimeSpentList_OnBeforeMarkDelete(oSender, oEventArgs)
	g_nSpentTimeBeforeOperation = getTaskTimeSpent(g_oPool, g_oObjectEditor.XmlObject)
End Sub


'==============================================================================
Sub usr_Task_TimeSpentList_OnAfterCreate(oSender, oEventArgs)
	updateLeftAndSpentTime
End Sub


'==============================================================================
Sub usr_Task_TimeSpentList_OnAfterEdit(oSender, oEventArgs)
	updateLeftAndSpentTime
End Sub


'==============================================================================
Sub usr_Task_TimeSpentList_OnAfterMarkDelete(oSender, oEventArgs)
	updateLeftAndSpentTime
End Sub


'==============================================================================
Sub updateLeftAndSpentTime()
	Dim nLeftTime			' �������� ����������� �������
	Dim nSpentTimeDelta		' ��������� ������������ ��������
	Dim oPE

	nLeftTime = g_oPool.GetPropertyValue(g_oObjectEditor.XmlObject, "LeftTime")
	' ��������� ������������ ��������
	nSpentTimeDelta = getTaskTimeSpent(g_oPool, g_oObjectEditor.XmlObject) - g_nSpentTimeBeforeOperation
	' ���� ��������� ������, ��� ��������, �� 0, ����� ������� ���������� ����� ���������������
	If nSpentTimeDelta > nLeftTime Then
		nLeftTime = 0
	Else
		nLeftTime = nLeftTime - nSpentTimeDelta
	End If
	Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.SelectSingleNode("LeftTime"))
	oPE.Value = nLeftTime
	
	'g_oPool.SetPropertyValue g_oObjectEditor.XmlObject.SelectSingleNode("LeftTime"), nLeftTime	
	'oLeftTime.innerText = FormatTimeString(nLeftTime)
	
	oSpentTime.innerText = GetSpentTimeString()
End Sub

