Option Explicit

'==============================================================================
' ���������� ������ ��������� - ������������ ��� ���������� �����
Sub usr_ObjectPresentation_OnBeforeSelect(oSender, oEventArgs)
	oEventArgs.UrlArguments = oEventArgs.UrlArguments & "&selectable-types=Incident" 
End Sub

'==============================================================================
Sub usrXEditor_OnSetCaption(oSender, oEventArgs)
	Dim oParentProp
	Dim sOwnerOID
	Dim sCaptionHTML
	
	Set oParentProp = oSender.ParentXmlProperty
	If oParentProp Is Nothing Then
		oEventArgs.EditorCaption = "�������������� ����� ����� �����������"
	Else
		' ���� ������������ �������� � ���� �, ������ ������ �� ����, ����� �� ����
		sOwnerOID = oParentProp.parentNode.getAttribute("oid")
		If Not oSender.XmlObject.selectSingleNode("RoleA/Incident[@oid='" & sOwnerOID & "']") Is Nothing Then
			sCaptionHTML = "������ �� ��������"
		Else
			sCaptionHTML = "������ �� ������� ���������"
		End If
		oEventArgs.EditorCaption = sCaptionHTML
	End If
End Sub
