Option Explicit

'==========================================================================
Public Sub usr_Sum_Currency_OnChanging(oSender, oEventArgs)
	Dim xmlLots
	Dim xmlLot
	Dim xmlCurr
	Dim xmlNewCurr
	Dim xmlGuarantee
	Dim xmlGuaranteeSum
	Dim sLotsNumbers
	Dim sCurrCode
	Dim sMessage
	
	' �������� ��� ���� �������
	Set xmlLots = oSender.ObjectEditor.Pool.GetXmlObjectsByOPath( _
		oSender.ObjectEditor.XmlObject, "Lot.Tender.Lots")
	If xmlLots Is Nothing Then Exit Sub

	' ���������� �� ���� ����� � ������� ������
	sLotsNumbers = ""
	For Each xmlLot In xmlLots
		Set xmlGuarantee = oSender.ObjectEditor.Pool.GetXmlObjectByOPath( _
			xmlLot, "Guarantee" )
		If Not xmlGuarantee Is Nothing Then
			' ��������, ��� ��� �� ������� ������
			If xmlGuarantee.getAttribute("oid") <> oSender.ObjectEditor.ObjectID Then
			
				Set xmlGuaranteeSum = oSender.ObjectEditor.Pool.GetXmlObjectByOPath( _
					xmlGuarantee, "GuaranteeSum" )
				If Not xmlGuaranteeSum Is Nothing Then
					Set xmlCurr = oSender.ObjectEditor.Pool.GetXmlObjectByOPath( _
						xmlGuaranteeSum, "Currency" )
					If xmlCurr.getAttribute("oid") <> oEventArgs.NewValue Then
						If sLotsNumbers <> "" Then _
							sLotsNumbers = sLotsNumbers & ", "
						
						sCurrCode = oSender.ObjectEditor.Pool.GetPropertyValue( xmlCurr, "Code" )
						sLotsNumbers = sLotsNumbers & "'" & oSender.ObjectEditor.Pool.GetPropertyValue( xmlLot, "Number" ) & "'"
					End If
				End If
			End If
		End If
	Next
	
	' ���� � ������� �������� �� ������� - ������ ������ ������
	If sLotsNumbers =  "" Then _
		Exit Sub
	
	sMessage = "��� ����� " & sLotsNumbers & " ������ ���������� �������� � ������ " & sCurrCode & ", �������� �� ���������." & vbNewLine & "�������� ������ ���������� �������� ���� ����� �� ���������?"
	' ������������ ��������� �������� ������ - ������ ������� ��������
	If Not confirm(sMessage) Then
		oEventArgs.ReturnValue = False
		oSender.SetData()
		Exit Sub
	End If
End Sub

'==========================================================================
Public Sub usr_Sum_Currency_OnChanged(oSender, oEventArgs)
	Dim xmlLots
	Dim xmlLot
	Dim xmlCurr
	Dim xmlNewCurr
	Dim xmlGuarantee
	Dim xmlGuaranteeSum
	
	' �������� ��� ���� �������
	Set xmlLots = oSender.ObjectEditor.Pool.GetXmlObjectsByOPath( _
		oSender.ObjectEditor.XmlObject, "Lot.Tender.Lots")
	If xmlLots Is Nothing Then Exit Sub

	' ������� ����� ������
	Set xmlNewCurr = oSender.ObjectEditor.Pool.GetXmlObject("Currency", oEventArgs.NewValue, Null)

	' ���������� �� ���� ����� � �������� ������
	For Each xmlLot In xmlLots
		Set xmlGuarantee = oSender.ObjectEditor.Pool.GetXmlObjectByOPath( _
			xmlLot, "Guarantee" )
		If Not xmlGuarantee Is Nothing Then
			' ��������, ��� ��� �� ������� ������
			If xmlGuarantee.getAttribute("oid") <> oSender.ObjectEditor.ObjectID Then
			
				Set xmlGuaranteeSum = oSender.ObjectEditor.Pool.GetXmlObjectByOPath( _
					xmlGuarantee, "GuaranteeSum" )
				If Not xmlGuaranteeSum Is Nothing Then
					Set xmlCurr = oSender.ObjectEditor.Pool.GetXmlObjectByOPath( _
						xmlGuaranteeSum, "Currency" )
					If xmlCurr.getAttribute("oid") <> oEventArgs.NewValue Then
						oSender.ObjectEditor.Pool.RemoveAllRelations xmlGuaranteeSum, "Currency"
						oSender.ObjectEditor.Pool.AddRelation xmlGuaranteeSum, "Currency", xmlNewCurr
					End If
				End If
			End If
		End If
	Next
End Sub

'==========================================================================
Sub usrXEditor_OnValidatePage(oSender, oEventArgs)
	If oSender.Pool.GetXmlObjectByOPath(oSender.XmlObject, "GuaranteeSum") Is Nothing _
		And IsNull(oSender.Pool.GetPropertyValue(oSender.XmlObject, "PortionValue")) Then
		oEventArgs.ReturnValue = False
		oEventArgs.ErrorMessage = "�� ������ ������� ���� �����, ���� ���� ���������� ��������."
	End If
End Sub