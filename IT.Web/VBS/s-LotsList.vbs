'==============================================================================
Sub usrXList_OnBeforeListReload( oSender, oEventArgs )
	'Dim xmlFilter
	'Dim dtDocFeedingBegin, dtDocFeedingEnd
	'Dim FilterObject
	'Set FilterObject = X_GetFilterObject( document.all( "FilterFrame") )
	'Set xmlFilter = FilterObject.GetXmlState()

	'dtDocFeedingBegin = xmlFilter.selectSingleNode("FilterLotsList/DocFeedingBegin").nodeTypedValue

	'dtDocFeedingEnd = xmlFilter.selectSingleNode("FilterLotsList/DocFeedingEnd").nodeTypedValue

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