'----------------------------------------------------------
'	��������/������ IncidentState
Option Explicit
'��������� �������� ��������� ���������� ��������� � ���������
Sub usr_IncidentState_IsStartState_OnChanged (oSender, oEventArgs)
  
  Dim Pool              '������� ��� ��������          
  Dim oXmlNewStartState '���� ������� ���� IncidentState,������� ������������ �������������� ��������� ���-��(��� ��������� ����� ������� ���������)
  Dim oXmlOldStartState '���� ������� ���� IncidentState, ������� ������������ ���������� ��������� ���-��(������� ����������� �� ������ ������)
  Dim oXmlTemp
  Dim sOldStartStateName '�������� ������� ���������� ��������� ���-��
  Dim sIncidentTypeName  '�������� ���� ���������
  Dim sNewStartStateName '�������� ������ ���������� ��������� ���-��
  Dim sMessage
  
  Set Pool  = oSender.ObjectEditor.Pool
  Set oXmlOldStartState = Nothing
  Set oXmlNewStartState = oSender.ObjectEditor.XmlObject
  sNewStartStateName = oXmlNewStartState.SelectSingleNode("Name").Text
  sIncidentTypeName = Pool.GetPropertyValue(oXmlNewStartState, "IncidentType.Name")
  
  '���� ������� ������� ���������� ��������� ���-��, �� ������� �� ���������
  If oEventArgs.NewValue = False Then Exit Sub
  
  '������ xml-����,������� ������������ ���������� ��������� ���-�� 
   For Each oXmlTemp In Pool.GetXmlObjectsByOPath(oXmlNewStartState, "IncidentType.States")
   If oXmlTemp.getAttribute("oid") <> oXmlNewStartState.getAttribute("oid") Then
		If oXmlTemp.selectSingleNode("IsStartState").text = 1 Then
		    Set  oXmlOldStartState = oXmlTemp
			Exit For
		End If	
   End If		
 Next	
 
 '���� �� ����� ������� ���������� ��������� ���-��, �� �������
 If  oXmlOldStartState Is Nothing Then Exit Sub
 sOldStartStateName = oXmlOldStartState.SelectSingleNode("Name").Text
 
  sMessage = "��� ���� ��������� """ & sIncidentTypeName & """ ������ ��������� ��������� """ & sOldStartStateName & """ ." & vbNewLine & _
  "���������� ����� ��������� ��c������ """ & sNewStartStateName & """ ?"
  
  If Not confirm(sMessage) Then 
    '��������� ������ ��������� ��������� ���-�� 
    oSender.HtmlElement.Checked = False
    Pool.SetPropertyValue Pool.GetXmlProperty(oXmlNewStartState, "IsStartState"), False
    Pool.GetXmlProperty(oXmlNewStartState, "IsStartState").RemoveAttribute "dirty"
  Else
    '������� ������� IsStartState � ������� ���������� ���������
    Pool.SetPropertyValue Pool.GetXmlProperty(oXmlOldStartState, "IsStartState"), False 
  End If
    
End Sub



