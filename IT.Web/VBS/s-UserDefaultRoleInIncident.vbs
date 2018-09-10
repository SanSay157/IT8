Option Explicit
' �������� ������� "���� ������������ � ��������� �� ���������"
' �������� ����� ����������� �� ����� �� ���� ������: ��� ���������, ���� � ���������, ���� ������������ � �����,
' � � ������ �� ���� ������� ���� �� ������ ����� ������ �������, � ��������������� PE �������������

'==============================================================================
Sub usr_IncidentType_ObjectDropDown_OnChanged(oSender, oEventArgs)
	Dim oPE
	Set oPE = oSender.ParentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("UserRoleInIncident") )
	oPE.ValueID = Null
	oPE.Reload
End Sub


'==============================================================================
' 
Sub usr_UserRoleInIncident_ObjectDropDown_OnGetRestrictions(oSender, oEventArgs)
	Dim sIncidentTypeID
	sIncidentTypeID = getIncidentTypeID(oSender.ObjectEditor)
	If Not IsNull(sIncidentTypeID) Then
		oEventArgs.ReturnValue = "IncidentType=" & sIncidentTypeID
	End If
End Sub


'==============================================================================
' ���������� ������������� �������� ���� ���������
Function getIncidentTypeID(oObjectEditor)
	Dim oPE
	Dim oXmlProp
	getIncidentTypeID = Null
	
	Set oXmlProp = oObjectEditor.XmlObject.selectSingleNode("IncidentType")
	If oXmlProp.hasChildNodes Then
		' ��� ��������� �����
		getIncidentTypeID = oXmlProp.firstChild.getAttribute("oid")
	Else
		Set oPE = oObjectEditor.CurrentPage.GetPropertyEditor( oXmlProp )
		If Not oPE Is Nothing Then
			getIncidentTypeID = oPE.ValueID
		End If
	End If
End Function
