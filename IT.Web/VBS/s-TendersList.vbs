'==============================================================================
Sub usrXList_OnBeforeListReload( oSender, oEventArgs )
	'������� �������������� �� �������� ��� 
    'Dim xmlFilter
	'Dim dtDocFeedingBegin, dtDocFeedingEnd
	'Dim FilterObject
	'Set FilterObject = X_GetFilterObject( document.all( "FilterFrame") )
	'Set xmlFilter =FilterObject.GetXmlState()
    'dtDocFeedingBegin = xmlFilter.selectSingleNode("FilterTendersList/DocFeedingBegin").nodeTypedValue
	'dtDocFeedingEnd = xmlFilter.selectSingleNode("FilterTendersList/DocFeedingEnd").nodeTypedValue
    ' ������ ��� ����
	'If Not IsNull(dtDocFeedingBegin) And Not IsNull(dtDocFeedingEnd) Then
    '	If DateDiff("m", dtDocFeedingBegin, dtDocFeedingEnd) > 3 Then
	'		DateAlert()
	'	End If
	' ������ ������ ���� ������
	'ElseIf Not IsNull(dtDocFeedingBegin) And IsNull(dtDocFeedingEnd) Then
	'	If DateDiff("m", dtDocFeedingBegin, Now()) > 3 Then
	'		DateAlert()
	'	End If
	' �� ������ ���� ������
	'ElseIf IsNull(dtDocFeedingBegin) Then
	'	DateAlert()
	'End If
End Sub

'==============================================================================
' ������� ��������������� ���������
Sub DateAlert()
	alert "����� ������� �������� ���. �������� ���������� ������ �������!"
End Sub

'==============================================================================
Sub usrXList_OnAccel1(oXList, oAccelerationArgs)
	' ������� ������� ���������� � ���� ������ - ����� ��� ��� ��� ���������� hotkey'�
	'oXList.Menu.ExecuteHotkey oXList, oAccelerationArgs
	alert oXList.Menu.Macros.Item("ObjectID")
	alert oXList.Menu.Macros.Item("IsSingleLot")
End Sub

'==============================================================================
Sub TendersList_MenuVisibilityHandler(oSender, oMenuEventArgs)
	'Dim oMenuItem		' ������� menu-item
	'Dim bIsSingleLot	' ������� ������������ �������
	
	'Set oMenuItem = oMenuEventArgs.Menu.XmlMenu.selectSingleNode("i:menu-item[@n='EditAsSingleLot']")
	'If Not oMenuItem Is Nothing Then
	'	bIsSingleLot = CBool(nvl(oMenuEventArgs.Menu.Macros.Item("IsSingleLot"), False))
		' ���� ������ ������������, �� ������������� ��� ��� ����������� ������.
		' ������� ��������������� ����� ����
	'	If Not bIsSingleLot Then
	'		oMenuItem.setAttribute "hidden", "1"
	'	Else
	'		oMenuItem.removeAttribute "hidden"
	'	End If 
	'End If
End Sub

