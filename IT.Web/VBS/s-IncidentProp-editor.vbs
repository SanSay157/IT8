'----------------------------------------------------------
'	��������/������ IncidentProp
Option Explicit

Sub usrXEditor_OnValidatePage(Sender, EventArgs )
	Dim nType			' ��� ��������
	Dim vMin			' �������
	Dim vMax			' ��������
	Dim vDef			' �� ���������
	Dim oIncidentProp	' �������� ���������
	Dim sPropName		' ������������ ��������
	
	
	' �������� ������������ �����
	If 2>CLng(Sender.CurrentPageNo) Then
		' ������������ ��� �������� ��������� ����� ��������
		With Sender.Pool
			For Each oIncidentProp In .GetXmlProperty(Sender.XmlObject, "IncidentType.Props").SelectNodes("*[@oid!='" & Sender.ObjectID & "']")
				If 0 = StrComp( Sender.XmlObject.SelectSingleNode("Name").nodeTypedValue , .GetPropertyValue(oIncidentProp, "Name"), vbTextCompare) Then
					' ��������� �����
					EventArgs.ReturnValue = False
					EventArgs.ErrorMessage = "� ������� ���� ��������� ��� ���� ���. �������� � ������������� '" & Sender.XmlObject.SelectSingleNode("Name").nodeTypedValue & "'!"
					Exit Sub
				End If
			Next 
		End With	
	ElseIf Sender.IsObjectCreationMode and (2=Sender.CurrentPageNo) Then
		nType = Sender.XmlObject.SelectSingleNode("Type").nodeTypedValue
		Select Case nType
			Case IPROP_TYPE_IPROP_TYPE_LONG, IPROP_TYPE_IPROP_TYPE_DOUBLE :
				vMin = Sender.XmlObject.SelectSingleNode("MinDouble").nodeTypedValue
				vMax = Sender.XmlObject.SelectSingleNode("MaxDouble").nodeTypedValue
				vDef = Sender.XmlObject.SelectSingleNode("DefDouble").nodeTypedValue
			Case IPROP_TYPE_IPROP_TYPE_DATE ,IPROP_TYPE_IPROP_TYPE_TIME, IPROP_TYPE_IPROP_TYPE_DATEANDTIME :
				vMin = Sender.XmlObject.SelectSingleNode("MinDate").nodeTypedValue
				vMax = Sender.XmlObject.SelectSingleNode("MaxDate").nodeTypedValue
				vDef = Sender.XmlObject.SelectSingleNode("DefDate").nodeTypedValue
			Case IPROP_TYPE_IPROP_TYPE_STRING, IPROP_TYPE_IPROP_TYPE_TEXT :
				vMin = Sender.XmlObject.SelectSingleNode("MinDouble").nodeTypedValue
				vMax = Sender.XmlObject.SelectSingleNode("MaxDouble").nodeTypedValue
				vDef = Sender.XmlObject.SelectSingleNode("DefText").nodeTypedValue
				If HasValue(vDef) Then vDef=Len(vDef)
		End Select
		If HasValue(vMin) and HasValue(vMax) Then
			If vMin > vMax Then
				EventArgs.ReturnValue = False
				EventArgs.ErrorMessage = "�������� ����������� �������� ��������� �������� ������������ ��������!"
				Exit Sub
			End If
		End If
		If HasValue(vMin) and HasValue(vDef) Then
			If vMin > vDef Then
				EventArgs.ReturnValue = False
				EventArgs.ErrorMessage = "�������� �������� �� ��������� ������ ��������� ������������ ��������!"
				Exit Sub
			End If
		End If
		If HasValue(vMax) and HasValue(vDef) Then
			If vMax < vDef Then
				EventArgs.ReturnValue = False
				EventArgs.ErrorMessage = "�������� �������� �� ��������� ������ ��������� ������������� ��������!"
				Exit Sub
			End If
		End If
	End if
End Sub

'���������� ������� ��������� ���� �������� (Type) � ���������� ��������� ������� ���� IncidentProp (�������� ���-��)
Sub usr_IncidentProp_Type_SelectorCombo_OnChanged(oSender, oEventArgs)
  Dim oXmlObject 'xml-������������� ������� IncidentProp
    Set oXmlObject = oSender.ObjectEditor.XmlObject
    '������� �������� ����� ������� IncidentProp,������� ����� ���� ����������� �� ���������� ����,
    '��� ��� ������ ������ ��� �������� ���-��,� ������ � ����, ������� ����� ���������,����� ����������.
    '����� ������� ������� dirty � ����� ������� IncidentProp.
     
    oXmlObject.SelectSingleNode("MaxDouble").Text=""
    oXmlObject.SelectSingleNode("MaxDouble").RemoveAttribute "dirty"
    oXmlObject.SelectSingleNode("MinDouble").Text=""
    oXmlObject.SelectSingleNode("MinDouble").RemoveAttribute "dirty"
    oXmlObject.SelectSingleNode("DefDouble").Text=""
    oXmlObject.SelectSingleNode("DefDouble").RemoveAttribute "dirty"

    oXmlObject.SelectSingleNode("MaxDate").Text=""
    oXmlObject.SelectSingleNode("MaxDate").RemoveAttribute "dirty"
    oXmlObject.SelectSingleNode("MinDate").Text=""
    oXmlObject.SelectSingleNode("MinDate").RemoveAttribute "dirty"
    oXmlObject.SelectSingleNode("DefDate").Text=""
    oXmlObject.SelectSingleNode("DefDate").RemoveAttribute "dirty"
    oXmlObject.SelectSingleNode("DefText").Text=""
    oXmlObject.SelectSingleNode("DefText").RemoveAttribute "dirty"
End Sub
