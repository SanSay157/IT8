Option Explicit

'==============================================================================
Dim ObjectEditor			' �������� �������
Dim Pool					' ��� ��������

'==============================================================================
Sub InitGlobals(oObjectEditor)
	' ���������� ������ ���������
	Set ObjectEditor = oObjectEditor
	' ���������� ���
	Set Pool = ObjectEditor.Pool
End Sub

'==============================================================================
' ��������������� ����� ��� ���������� ������������ ������������ �������
' "���������", "�����������" � "����"
Class AcquaintedEmployeeHandlerClass
	Private m_oEmployeeEditor	' As XPEObjectPresentationClass - �������� ����������
	Private m_oIsAcquaintEditor	' As XPEBoolClass - �������� �������� "�����������"
	Private m_oDateEditor		' As XPEDateTimeClass - �������� ����
	
	'==========================================================================
	' ������������� ������ ������
	' [in] m_oEmployeeEditor	- XPEObjectPresentationClass, �������� ����������
	' [in] m_oIsAcquaintEditor	- XPEBoolClass, �������� �������� "�����������"
	' [in] m_oDateEditor		- XPEDateTimeClass, �������� ����
	Public Sub Init(oEmployeeEditor, oIsAcquaintEditor, oDateEditor)
		Set m_oEmployeeEditor = oEmployeeEditor
		Set m_oIsAcquaintEditor = oIsAcquaintEditor
		Set m_oDateEditor = oDateEditor
		
		' ������������� �� ������� ���������� �������
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "BeforeSelect", Me, "OnEmployeeChanging"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterSelect", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "BeforeUnlink", Me, "OnEmployeeChanging"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterUnlink", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "BeforeCreate", Me, "OnEmployeeChanging"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterCreate", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "BeforeDelete", Me, "OnEmployeeChanging"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterDelete", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "BeforeMarkDelete", Me, "OnEmployeeChanging"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterMarkDelete", Me, "OnEmployeeChanged"
		m_oIsAcquaintEditor.EventEngine.AddHandlerForEvent "Changed", Me, "OnIsAcquaintChanged"
		
		' ������������� ����������� ��������� ����������
		Handle()
	End Sub
	
	'==========================================================================
	' ������������� ����������� ��������� ����������
	Public Sub Handle()
		' ���������/��������� ��������� �������� "�����������" � ����
		disableIsAcquaint()
		disableDate()
	End Sub
	
	'==========================================================================
	' ���������� �������, ����������� ����� ���������� �������� "���������"
	Public Sub OnEmployeeChanging(oSender, oEventArgs)
		Dim sMessage
		
		' ���� ������� "�����������" � ���� �� ������, �� ������ �� ������
		If m_oIsAcquaintEditor.Value = False And _
			Not hasValue(m_oDateEditor.Value) Then Exit Sub

		sMessage = "�������� ������� """ & m_oIsAcquaintEditor.PropertyDescription & """ � """ & m_oDateEditor.PropertyDescription & """ ����� ��������." & vbNewLine & "�� �������, ��� ������ ����������?"
		If confirm(sMessage) = False Then
			oEventArgs.ReturnValue = False
			m_oEmployeeEditor.SetData()
			Exit Sub
		End If
	End Sub	
	
	'==========================================================================
	' ���������� �������, ����������� ����� ��������� �������� "���������"
	Public Sub OnEmployeeChanged(oSender, oEventArgs)
		m_oIsAcquaintEditor.Value = False
		m_oDateEditor.Value = Null

		disableIsAcquaint()
	End Sub	
	
	'==========================================================================
	' ���������� ������� OnChanged ��� �������� "�����������"
	Public Sub OnIsAcquaintChanged(oSender, oEventArgs)
		disableDate()
	End Sub	
	
	'==========================================================================
	' ���������/��������� �������� �������� "�����������" � ����������� ��
	' ����, ����� ��������� ��� ���
	Private Sub disableIsAcquaint()
		If m_oEmployeeEditor.Value Is Nothing Then
			m_oIsAcquaintEditor.Value = False
			TMS_EnablePropertyEditor m_oIsAcquaintEditor, False
		Else
			TMS_EnablePropertyEditor m_oIsAcquaintEditor, True
		End If	
	End Sub

	'==============================================================================
	' ���������/��������� �������� ���� � ����������� �� ����, ����� �������
	' "�����������" ��������� ��� ���
	Private Sub disableDate()
		If m_oIsAcquaintEditor.Value = False Then
			m_oDateEditor.Value = Null
			TMS_EnablePropertyEditor m_oDateEditor, False
		Else
			TMS_EnablePropertyEditor m_oDateEditor, True
		End If
	End Sub

End Class

'==============================================================================
' ��������������� ����� ��� ���������� ������������ ������������ �������
' "���������", "����"
Class EmployeeDateHandlerClass
	Private m_oEmployeeEditor	' As XPEObjectPresentationClass - �������� ����������
	Private m_oDateEditor		' As XPEDateTimeClass - �������� ����
	
	'==========================================================================
	' ������������� ������ ������
	' [in] m_oEmployeeEditor	- XPEObjectPresentationClass, �������� ����������
	' [in] m_oDateEditor		- XPEDateTimeClass, �������� ����
	Public Sub Init(oEmployeeEditor, oDateEditor)
		Set m_oEmployeeEditor = oEmployeeEditor
		Set m_oDateEditor = oDateEditor
		
		' ������������� �� ������� ���������� �������
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterSelect", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterUnlink", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterCreate", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterDelete", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterMarkDelete", Me, "OnEmployeeChanged"
		
		' ������������� �������������� ���� � ����������� �� ������� ����������
		setDateMandatory()
	End Sub
	
	'==========================================================================
	' ���������� �������, ����������� ����� ��������� �������� "���������"
	Public Sub OnEmployeeChanged(oSender, oEventArgs)
		setDateMandatory()
	End Sub	
	
	'==============================================================================
	' ������������� �������������� ���� � ����������� �� ������� ����������
	Sub setDateMandatory()
		' ���� ����� ���������, �� ���� ����� ������ ���� ������
		If m_oEmployeeEditor.Value Is Nothing Then
			m_oDateEditor.Mandatory = False
		Else
			m_oDateEditor.Mandatory = True
		End If
	End Sub

End Class


'==============================================================================
' ������� � �������������� ��������� AcquaintedEmployeeHandlerClass
' [in] m_oEmployeeEditor	- XPEObjectPresentationClass, �������� ����������
' [in] m_oDateEditor		- XPEDateTimeClass, �������� ����
' [out] - ��������� EmployeeDateHandlerClass
Function TMS_InitEmployeeDateHandler(oEmployeeEditor, oDateEditor)
	Dim oEmployeeDateHandler	' As EmployeeDateHandlerClass

	Set oEmployeeDateHandler = New EmployeeDateHandlerClass
	
	oEmployeeDateHandler.Init oEmployeeEditor, oDateEditor

	Set TMS_InitEmployeeDateHandler = oEmployeeDateHandler	
End Function


'==============================================================================
' ������� � �������������� ��������� AcquaintedEmployeeHandlerClass
' [in] m_oEmployeeEditor	- XPEObjectPresentationClass, �������� ����������
' [in] m_oIsAcquaintEditor	- XPEBoolClass, �������� �������� "�����������"
' [in] m_oDateEditor		- XPEDateTimeClass, �������� ����
' [out] - ��������� AcquaintedEmployeeHandlerClass
Function TMS_InitAcquaintedEmployeeHandler(oEmployeeEditor, oIsAcquaintEditor, oDateEditor)
	Dim oAcquaintedEmployeeHandler	' As AcquaintedEmployeeHandlerClass

	Set oAcquaintedEmployeeHandler = New AcquaintedEmployeeHandlerClass
	
	oAcquaintedEmployeeHandler.Init oEmployeeEditor, oIsAcquaintEditor, oDateEditor

	Set TMS_InitAcquaintedEmployeeHandler = oAcquaintedEmployeeHandler	
End Function


'==============================================================================
' ���������/��������� �������� ��������
' [in] oPropEditor	- As IPropertyEditor, �������� ��������
' [in] bEnable		- As Boolean, ������� ����������� ���������
Sub TMS_EnablePropertyEditor(oPropEditor, bEnable)
	If bEnable Then
		' �� ���������� "���� �����������", ��� ��� ���������� ����������
		' � ���������� ����� ���� �� �����
		oPropEditor.ParentPage.EnablePropertyEditorEx oPropEditor, True, True
	Else
		oPropEditor.ParentPage.EnablePropertyEditor oPropEditor, False
	End If
End Sub
	
'==============================================================================
' ���������� PropertyEditor ��� ��������� �������� �������
' [in] oObjectEditor	- ObjectEditorClass, �������� �������
' [in] oXmlObject		- IDOMXMLElement, ������ � ����
' [in] sPropName		- String, OPath �������
' [out] - �������� ��������� �������� �� ������� ��������
Function TMS_GetPropertyEditor(oObjectEditor, oXmlObject, sPropName)
	' ���� ������ �� �����, ����� ������ �� ���������
	If oXmlObject Is Nothing Then
		Set oXmlObject = oObjectEditor.XmlObject
	End If
	Set TMS_GetPropertyEditor = oObjectEditor.CurrentPage.GetPropertyEditor( _
		oObjectEditor.Pool.GetXmlProperty( oXmlObject, sPropName) )
End Function


'==============================================================================
' ���������� ��������� ������������� �����
' [in] curSumValue		- Currency, �����
' [in] sCurrencyCode	- String, ��� ������
' [in] dExchangeRate	- Double, ���� ��������
' [out] - ��������� ������������� �����
Function TMS_GetSumString(curSumValue, sCurrencyCode, dExchangeRate)
	If Not hasValue(curSumValue) Or Not hasValue(sCurrencyCode) Then
		TMS_GetSumString = ""
	Else
		TMS_GetSumString = Replace(FormatNumber(curSumValue, 2), ",", ".") & " " & sCurrencyCode
		' ��������� ���� ��������, ���� �����
		If hasValue(dExchangeRate) Then
			TMS_GetSumString = TMS_GetSumString & " (" & Replace(CStr(dExchangeRate), ",", ".") & ")"
		End If
	End If
End Function

'==============================================================================
' ���������� ��������� ������������� ����������
' [in] sLastName	- String, �������
' [in] sFirstName	- String, ���
' [in] sMiddleName	- String, ��������
' [out] - ��������� ������������� ����������
Function TMS_GetEmployeeString(sLastName, sFirstName, sMiddleName)
	If Not hasValue(sLastName) Or Not hasValue(sFirstName) Then
		TMS_GetEmployeeString = ""
	Else
		TMS_GetEmployeeString = sLastName & " " & sFirstName
		' ��������� ��������, ���� ������
		If hasValue(sMiddleName) Then
			TMS_GetEmployeeString = TMS_GetEmployeeString & " " & sMiddleName
		End If
	End If
End Function

'==============================================================================
' ���������� ��������� ������������� ��� ���� �������� ("�����������", "����")
' [in] bIsAcquaint	- Boolean, ������� "�����������"
' [in] dtDate		- Date, ����
' [out] - ��������� ������������� ��������
Function TMS_GetAcquaintedDateString(bIsAcquaint, dtDate)
	If Not hasValue(bIsAcquaint) Then
		TMS_GetAcquaintedDateString = ""
	Else
		If bIsAcquaint Then
			TMS_GetAcquaintedDateString = "��"
		Else
			TMS_GetAcquaintedDateString = "���"
		End If
		
		' ��������� ����, ���� ������
		If hasValue(dtDate) Then
			TMS_GetAcquaintedDateString = TMS_GetAcquaintedDateString & ", " & FormatDateTime(dtDate, vbShortDate)
		End If
	End If
End Function

'==============================================================================
' ���������� ��������� ������������� ���������� ��������
' [in] curSumValue		- Currency, �����
' [in] sCurrencyCode	- String, ��� ������
' [in] nValidityPeriod	- Integer, ���� ��������
' [in] dtEndingDate		- Date, ���� ��������� ��������
' [in] nPortionValue	- Integer, ���� ���������� ��������
' [out] - ��������� ������������� ���������� ��������
Function TMS_GetGuaranteeString(curSumValue, sCurrencyCode, nValidityPeriod, dtEndingDate, nPortionValue)
	If hasValue(curSumValue) And hasValue(sCurrencyCode) Then
		TMS_GetGuaranteeString = TMS_GetSumString(curSumValue, sCurrencyCode, Empty) & ", �� " & CStr(nValidityPeriod) & " ����, �� " & FormatDateTime(dtEndingDate, vbShortDate)
		' ��������� ���� ���������� ��������, ���� ��� ������
		If hasValue(nPortionValue) Then
			TMS_GetGuaranteeString = TMS_GetGuaranteeString & " / " & nPortionValue & "%"
		End If
	ElseIf hasValue(nPortionValue) Then
		TMS_GetGuaranteeString = nPortionValue & "%, �� " & CStr(nValidityPeriod) & " ����, �� " & FormatDateTime(dtEndingDate, vbShortDate)
	Else
		TMS_GetGuaranteeString = ""
	End If
End Function

'==============================================================================
' ���������� �������� ������ ��� ��������� ����
' [in] nLotState - Integer, ��������� ����
' [in] bWinner   - Boolean, ������� "����������"
' [out] - ������, ���������� �������� ������ ��������� ����
Function TMS_GetWinnerString(nLotState, bWinner)
	If nLotState <> LOTSTATE_WASGAIN And nLotState <> LOTSTATE_WASLOSS Then
		TMS_GetWinnerString = ""
	Else
		If CBool(bWinner) Then 
			TMS_GetWinnerString = "����������"
		Else
			TMS_GetWinnerString = "�����������"
		End If
	End If
End Function

'==============================================================================
' ���������� �������� ������ ��� ��������� ����
' [in] nParticipationType	- Integer, ��� ��������
' [in] bWinner				- Boolean, ������� "����������"
' [out] - �������� ������ ��� ��������� ����
Function TMS_GetLotParticipantSelector(nParticipationType, bWinner)
	Dim nSelector	' �������� ���������
	
	If Not hasValue(nParticipationType) Or Not hasValue(bWinner) Then
		nSelector = Empty
	Else
		If Not CBool(bWinner) Then
			Select Case nParticipationType
				Case PARTICIPATIONS_PARTICIPANT
					nSelector = "Participant"
				Case PARTICIPATIONS_COMPETITOR
					nSelector = "Competitor"
				Case PARTICIPATIONS_HELPER
					nSelector = "CompetitorHelper"
			End Select
		Else
			Select Case nParticipationType
				Case PARTICIPATIONS_PARTICIPANT
					nSelector = "Participant-Winner"
				Case PARTICIPATIONS_COMPETITOR
					nSelector = "Competitor-Winner"
				Case PARTICIPATIONS_COMPETITORHELPER
					nSelector = "CompetitorHelper-Winner"
			End Select
		End If
	End If		
		
	TMS_GetLotParticipantSelector = nSelector
End Function

'==============================================================================
' ���������, ��� � ���� ����� ������� � �������� ����������� - ��������� ����
' �� ��� ������ ���� � �� �� �����������
' [in] oPool			- ������ ����
' [in] oXmlTender		- XML-������� �������
' [in/out] oXmlCompany	- XML-������� ����������� - ��������� ���� �� ���
' [out]	-	True, ���� � ���� ����� ������� � �������� ����������� - ���������
'			���� �� ��� ������ ���� � �� �� ����������� ��� ��������� �� ���
'			��� �� ����������. 
'		-	False � ��������� ������
' ���������. ���� ���� ��� ������� �� ����������, ��, �������������, ���������
' �� ��� ���� �� ����������. � ���� ������ ������� ������ True
Function TMS_IsTenderParticipantOrganizationSingle(oPool, oXmlTender, ByRef oXmlCompany)
	Dim sTenderID				' ������������� �������
	Dim sXPath					' ������ � XPath-��������
	Dim oXmlOrganizationList	' ������ ����������� �� ���
	Dim oXmlOrganization		' ������� ����������� �� ���
	Dim sCompanyID				' ������������� ����������� �� ���
	Dim bSingleCompany			' ��� ���� ����� ����� ���� ����������� �� ���
	
	bSingleCompany = True
	Set oXmlCompany = Nothing		
	
	sTenderID = oXmlTender.getAttribute("oid")
	
	' XPath, ������������ ������ �� ����������� ��� ���� ���������� �� ���
	' �� ���� ����� �������
	sXPath = "LotParticipant[@oid=//Lot[Tender/Tender/@oid='" & sTenderID & "']/LotParticipants/LotParticipant/@oid and ParticipationType=" & PARTICIPATIONS_PARTICIPANT & "]/ParticipantOrganization/Organization"
	
	Set oXmlOrganizationList = oPool.Xml.selectNodes(sXPath)
	
	If oXmlOrganizationList.length > 0 Then
		Set oXmlCompany = oPool.GetXmlObjectByXmlElement( oXmlOrganizationList.item(0), Empty )
		sCompanyID = oXmlCompany.getAttribute("oid")
		bSingleCompany = True
		For Each oXmlOrganization In oXmlOrganizationList
			If oXmlOrganization.getAttribute("oid") <> sCompanyID Then
				bSingleCompany = False
				Exit For
			End If
		Next
	End If
	
	TMS_IsTenderParticipantOrganizationSingle = bSingleCompany
End Function

'==============================================================================
' ���������� ��������� ������� ���� ��� ��������� ������ �� ������ � Incident Tracker
Sub TMS_TenderFolderPresentation_MenuVisibilityHandler(oSender, oEventArgs)
 	Dim oNode			' ������� menu-item
	Dim sType			' ��� ������� � ��������
	Dim sObjectID		' ������������� �������-��������
    ' ������� ��� � ������������� �������-��������
	sType = oEventArgs.Menu.Macros.Item("ObjectType")
	sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
	If 0=Len("" & sObjectID) Then sObjectID = Null
	For Each oNode In oEventArgs.ActiveMenuItems
		' ���������� ������ ��������� ��� ��������
		Select Case oNode.getAttribute("action")
		    ' "����� � ������"
			Case "DoFindInTree","DoView"
				If IsNull(sObjectID) Then
					oNode.setAttribute "hidden", "1"
				Else
					oNode.removeAttribute "hidden"
				End If
		End Select
	Next
End Sub

'==============================================================================
' ���������� ���������� ������� ���� ��� ��������� ������ �� ������ � Incident Tracker
Sub TMS_TenderFolderPresentation_MenuExecutionHandler(oSender, oEventArgs)
    Dim sObjectID
   	Select Case oEventArgs.Action
		' "����� � ������"
		Case "DoFindInTree"
			sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
			' �� ������ ������ ��������....
			If Len("" & sObjectID) > 0 Then
				window.Open XService.BaseUrl & "x-tree.aspx?METANAME=Main&LocateFolderByID=" & sObjectID
			End If	
		Case "DoView"
		    X_OpenReport oEventArgs.Menu.Macros.item("ReportURL")
	End Select		
End Sub