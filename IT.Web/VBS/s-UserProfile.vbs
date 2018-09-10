'*******************************************************************************
' ����������:	��������/������ ������� ����������� (������������ ���������)
' ����������:	
'*******************************************************************************
Option Explicit

Dim g_oShowExpensesPanel	' PE �������� ShowExpensesPanel (��������� XPEBoolClass)
Dim g_oAutoUpdateDelay		' PE �������� ExpensesPanelAutoUpdateDelay (XPEStringClass)
Dim g_oStartPage            ' PE �������� StartPage (XPESelectorComboClass) 

'==============================================================================
' ���������� ������� �������� ������ �������� ������� / ���������
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
    Dim resultRight '��������� ��������  ������� � �������� ������������ ��������� ���������� ������� � ������� ��� (true ��� false)
    	' �������� ������ �� ���������� PE, ������������� �������� "���������� 
	' ������" � "������ �������������� ������" - ������ �������� � PE �����
	' ��������� ��� ������
	With oSender
		Set g_oShowExpensesPanel = .CurrentPage.GetPropertyEditor( .GetProp("ShowExpensesPanel") )
		Set g_oAutoUpdateDelay = .CurrentPage.GetPropertyEditor( .GetProp("ExpensesPanelAutoUpdateDelay") )
		Set g_oStartPage = .CurrentPage.GetPropertyEditor( .GetProp("StartPage"))
	End with
	
	'��������� ����� �� ������� ������������ ������� ������ ���� ���(��� ����� ������ ���� ��������� ���������� - ������ � ������� ���)
	resultRight = X_CheckObjectRights ("Lot",Empty,"Create")
	'���� ���, �� ������  �� combobox ��������� �������� ��������,����������� � ������� ��� (��� ���������)
	If Not(resultRight) Then
	   g_oStartPage.HtmlElement.children(4).RemoveNode True
	   g_oStartPage.HtmlElement.children(4).RemoveNode True
	End If
	   
	' ���� ������������� �� HTML-DOM-������� (PE ����� ������� �� �����������,
	' � ��� - ����):
	g_oAutoUpdateDelay.HtmlElement.attachEvent "onchange", GetRef("chechAutoUpdateDelay")
	
	' ������������� �������� ���������� ���������, �������������� �����������
	' ��������� / ����� ����� � ����������� �� ������:
	checkAvailability
	
	
End Sub


'==============================================================================
' ������� ��������� �������� PE, ����������� �������� "ShowExpensesPanel"
Sub usr_ShowExpensesPanel_Bool_OnChanged( oSender, oEventArgs )
	If Not(oSender.Value) Then
		g_oAutoUpdateDelay.Value = 0
		g_oAutoUpdateDelay.SetData
	End If
	checkAvailability
End Sub


'==============================================================================
' ������� ��������� ������ "�������������� ����������" (���������� ���� 
' ��������� � XSL, ��� ����������� �������� INPUT TYPE="checkbox")
Sub AutoUpdateOn_OnChanged()
	If (document.all("inpAutoUpdateOn").checked) Then
		If (0 = g_oAutoUpdateDelay.Value) Then g_oAutoUpdateDelay.Value = 1
		checkAvailability
		g_oAutoUpdateDelay.HtmlElement.Focus
		g_oAutoUpdateDelay.HtmlElement.Select
	Else 
		g_oAutoUpdateDelay.Value = 0
	End If
End Sub


'==============================================================================
' ���������� ���������, �������������� ����������� ��������� ����������. 
' ��������� ��������� �������:
'	- ���� ���� "���������� ������" �������, �� ���� "�������� ��������������"
'		� ���� "������ ��������������" - �������������
'	- ���� ���� "�������� ��������������" ������������, �� � ���� "������ 
'		��������������" ������������� ��� �����
'	- ���� �������� "������ ��������������" ������� �� ����, �� ���� ����������
Sub checkAvailability()
	document.all("inpAutoUpdateOn").disabled = Not CBool( g_oShowExpensesPanel.Value )
	g_oAutoUpdateDelay.Enabled = Not CBool(document.all("inpAutoUpdateOn").disabled )
	document.all("inpAutoUpdateOn").checked = CBool(0<>g_oAutoUpdateDelay.Value)
End sub


'==============================================================================
' ���. ���������� �������� �� ���� ����� "������ ����������" ����-�� ���: 
' ���� � ���� ������ �������� ���� ����������� � 0, �� ������������� �������
' ���� "�������������� ��������" (�.�. 0 == ���������)
Sub chechAutoUpdateDelay()
	If (0 = g_oAutoUpdateDelay.Value) Then 
		' ... ���, � ���� �������, ������� ���������� ������� ��������� 
		' ��������� check-box-�, AutoUpdateOn_OnChanged
		document.all("inpAutoUpdateOn").checked = false
	End If
End Sub

