'*******************************************************************************
' ����������:	
' ����������:	��������/������ ����� ������� ���������� ������ "���������  
'				������ �������������" (��. ����������� � it-metadata-reports.xml,
'				��� FilterReportDepartmentExpensesStructure)
'*******************************************************************************
Option Explicit

Dim g_oEditor		' ������ �� ObjectEditor; ������������ � usrXEditor_OnLoad

'===============================================================================
' ���������� ������� ���������� �������� ������ ���������
'	�������������� �����. ���������� ������ �� ������ ���������; 
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Set g_oEditor = oSender
End Sub


'===============================================================================
' ���������� ������� �������� �������� ������� / ��������� - ������������� UI
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	Dim nReportForm		' �������� �������� "����� ������"
	Dim nSelValue		' �������� �������������� ��������� "�� 100% �����"
	
	nReportForm	= g_oEditor.GetProp("ReportForm").nodeTypedValue
	
	If ("MainParams" = g_oEditor.CurrentPage.PageName) Then	
		' ������������� ����������� PE ������� �������� �������:
		InitPeriodSelector(oSender)
	Else
		' ��������� �������� �������������� ��������� "�� 100% �����":
		nSelValue = 0
		If CBool(g_oEditor.GetProp("ExpensesSumAsPercentBase").nodeTypedValue) Then nSelValue = 1
		g_oEditor.CurrentPage.HtmlDivElement.all.item("selPercentBase",0).value = nSelValue 
	End If
	
	applySelectedReportForm nReportForm
	applySelectedDataFormat g_oEditor.GetProp("DataFormat").nodeTypedValue
	applyFlagsShownColumns g_oEditor.GetProp("ShownColumns").nodeTypedValue
	applySelectednReportForm_OnColumnsFlags nReportForm

	' �������� ����������� ����������� ���������� ��������:
	g_oEditor.CurrentPage.HtmlDivElement.all.item("divPagePane",0).style.visibility = "visible"
End Sub

' ���������:
'	[in] oSender - ��������� ObjectEditorClass
'	[in] oEventArgs - ��������� EditorStateChangedEventArgs
Sub usrXEditor_OnPageEnd( oSender, oEventArgs )
	' ���� ������� "����������" �������� - ������������ �� ������ ��������, ��
	' ��������� ����������� ����������� ���������� ������ �������� (��� �� �� 
	' "��������" ��� ����. ���������, ��. OnPageStart):
	If ( REASON_PAGE_SWITCH = oEventArgs.Reason ) Then
		g_oEditor.CurrentPage.HtmlDivElement.all.item("divPagePane",0).style.visibility = "hidden"
	End If
End Sub


'===============================================================================
' ��������� �����, ���������� ����������� �������� � ������� ��������� ��������� 
'	����� ������. ���������� �� ����������� ������� ��������� �������� ��������� 
'	"����� ������" (��. �����)
' ���������:
'	[in] nReportForm - �������� ��������� "����� ������" (������������ 
'		������������� RepDepartmentExpensesStructure_ReportForm)
Sub applySelectedReportForm( nReportForm )
	Dim oSpanElement		' ������ �� SPAN-�������, �������� �����
	Dim bIsTaskDetailMode	' ����� ������, ��� ������� ��������� ������ �� 
							' �������� (� �� ��������� ��, ��������� ��������)
	
	bIsTaskDetailMode = CBool(REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEEWITHTASKSDETALI = nReportForm) 
	
	With g_oEditor.CurrentPage
		' �� �������� "������� ���������":
		If ("MainParams" = .PageName) Then
			' ����������� �������� �������� ��������� ����� ������: ������� ��� 
			' �������, ����� ������� ����������� �������:
			For Each oSpanElement In divHlpOpt.all.tags("SPAN")
				oSpanElement.style.display = "none"
			Next
			Set oSpanElement = divHlpOpt.all.item( "sHlpOpt_" & nReportForm, 0 )
			If hasValue(oSpanElement) Then oSpanElement.style.display = "inline"
		End If
		
		' ��������� ��������� ���������: �������� "������������� ������":
		' ...�� �������� "��������� �������������":			
		If ("Format" = .PageName) Then
			With .GetPropertyEditor( g_oEditor.GetProp("DataFormat") )
				If (bIsTaskDetailMode) Then .Value = REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYTIME
				.Enabled = Not bIsTaskDetailMode
				applayLockTextStyleClassFor tdDataFormat, bIsTaskDetailMode
			End With
		' ...�� �������� "�������� ���������":
		Else
			If (bIsTaskDetailMode) Then 
				g_oEditor.SetPropertyValue g_oEditor.GetProp("DataFormat"), REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYTIME
			End If
		End If
		
		' ��������� ��������� ���������: ����� "������������ �������"
		applySelectednReportForm_OnColumnsFlags nReportForm 		
	End With
	
End Sub

' ���������� ���������� ������� Changed ��� XPE ��������� "����� ������"
' ���������:
'	[in] oSender - ��������� XPE, XPESelectorComboClass
'	[in] oEventArgs - ��������� ChangeEventArgsClass (��. x-pe-object-dropdown.vbs)
Sub usr_FilterReportDepartmentExpensesStructure_ReportForm_OnChanged( oSender, oEventArgs )
	applySelectedReportForm oEventArgs.NewValue
End Sub


'===============================================================================
' ��������� �����, ������������� ����������� � �������� ���������� "�� 100% 
'	�����" � "������������� �������" (�������� "��������� �������������")
'	� ����������� �� �������� ��������� "������������� ������"
' ���������:
'	[in] nDataFormat - �������� ��������� "������������� �������" (��� ��������
'		���. ������������� RepDepartmentExpensesStructure_DataFormat)
Sub applySelectedDataFormat( nDataFormat )
	Dim bLockFlag		' ������ ����������
	With g_oEditor.CurrentPage
		If ("Format" = .PageName) Then
			' �������� "�� 100% �����" �����������, ���� ��������� ������������� 
			' ������ ����������� ��������� �� ��������:
			bLockFlag = CBool( REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYTIME = nDataFormat )
			document.all("selPercentBase").disabled = bLockFlag
			applayLockTextStyleClassFor tdPercentBase, bLockFlag
			
			' �������� ������ ����� ������������� ������� �����������, ���� 
			' ������������� ������ �������� ������ � ���������:
			bLockFlag = CBool( REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYPERCENT <> nDataFormat )
			.GetPropertyEditor( g_oEditor.GetProp("TimeMeasureUnits") ).Enabled = bLockFlag
			applayLockTextStyleClassFor tdTimeMeasure, Not(bLockFlag)
		End If
	End With
End Sub

' ���������� ���������� ������� Changed ��� XPE ��������� "������������� ������"
' ���������:
'	[in] oSender - ��������� XPE, XPESelectorComboClass
'	[in] oEventArgs - ��������� ChangeEventArgsClass (��. x-pe-object-dropdown.vbs)
Sub usr_FilterReportDepartmentExpensesStructure_DataFormat_OnChanged( oSender, oEventArgs )
	applySelectedDataFormat oEventArgs.NewValue
End Sub

'===============================================================================
' ��������� �����, ������������� ����������� � �������� ������ ��������� ������
'	������������ �������� ������, � ����������� �� ��������� ����� ������.
' ���������:
'	[in] nReportForm - �������� ��������� "����� ������" (������������ 
'		������������� RepDepartmentExpensesStructure_ReportForm)
Sub applySelectednReportForm_OnColumnsFlags( nReportForm )
	Dim bIsTaskDetailMode	' �������: ������� ����� ������ � ������� �� ��������
	Dim oShownColumns		' ������������� ��������
	
	bIsTaskDetailMode = ( REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEEWITHTASKSDETALI = nReportForm )
	Set oShownColumns = g_oEditor.GetProp("ShownColumns")	 
	
	' ���� "����� ������" ������ ��� "������ �� ������� ����������, � ������� 
	' �� ��������", �� (�) ����������� ���� ������������ ������� ����������� 
	' � (�) ����� ������ �����������:
	With g_oEditor.CurrentPage 
		If ("Format" = .PageName) Then
			' ... ��� �������� � PE ��������, ���� �� �� ������ ��������:
			With .GetPropertyEditor(oShownColumns)
				.Enabled = Not(bIsTaskDetailMode)
				If (bIsTaskDetailMode) Then .Value = 0
				applayLockTextStyleClassFor tdShownColumns, bIsTaskDetailMode
			End With
		Else
			' ...����� - ������ ������������ �������� ��������:
			If bIsTaskDetailMode Then
				g_oEditor.SetPropertyValue oShownColumns, 0
				g_oEditor.SetPropertyValue g_oEditor.GetProp("SortingMode"), REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYNAME
				applyFlagsShownColumns 0
			End If
		End If
	End With
End Sub


'===============================================================================
' ��������� �����, ������������� ����������� � �������� � ������ ������ �����
'	�����������, � ����������� �� ��������� ����������� ������� "�����������
'	����������" (�������� ��������� ShownColumns; ��������� ����������� �������
'	���. ������������� ������ �� RepDepartmentExpensesStructure_OptColsFlags)
' ���������:
'	[in] nShownColumns - �������� �������� "������������ �������" (����� ������
'			�� RepDepartmentExpensesStructure_OptColsFlags)
Sub applyFlagsShownColumns( nShownColumns )
	Dim bShowDisbalance		' ������� ����������� ������� "���������"
	Dim bShowUtilization	' ������� ����������� ������� "����������� ����������"
	Dim bIsRestrictedValue	' ��������� ������� - ��������� ����� ���������� � ������ ������ ����������
	Dim oActivityTypes		' �������� ActivityTypesAsExternal �������������� �������
	Dim oSortingMode		' �������� SotringMode �������������� �������

	bShowDisbalance = CBool( ( nShownColumns And REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODDISBALANCE ) > 0 )
	bShowUtilization = CBool( ( nShownColumns And REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWUTILIZATION ) > 0 )
	Set oActivityTypes = g_oEditor.GetProp("ActivityTypesAsExternal")
	Set oSortingMode = g_oEditor.GetProp("SortingMode")
	
	' ���� � ������ ��� ������ �� ���������� (��), �� ���������� ������ �� "�������" 
	' � "����������" �� ���������, � ������, �������� ����� �����������, �������
	' �� ������� ����� ��������� ��� "�������" - ���� �� �����; � �������� - ����
	' ������ �� ��������� - �� � ����������� ����� ����������� �����. ��� ������
	' ����� "�����" ������������ UI-���������, �������� ���� ������������, � 
	' ����������� �� ����������� ������ ��, � ��� �� ������� ���������������� 
	' ��������:
	 
	' ���� �� �� ������������, �� �������� ������ ����� ����������� � ��������:
	If Not(bShowUtilization) Then g_oEditor.Pool.RemoveAllRelations Nothing, oActivityTypes
		
	With g_oEditor.CurrentPage
		' ... ��� ����������� � ���������� UI ����� ����� �� �������� "���������...":
		If ("Format" = .PageName) Then
		
			' ��� PE �� ������� ����� �����������:	
			With .GetPropertyEditor(oActivityTypes) 
				.SetData						' ...����������� - � �����. � ������� ��������
				.Enabled = bShowUtilization		' ...����������� - ���� �� �����������
				
				' ��������� �������� ��� ������� � PE: (1) ���� �� �� ������������, �� ���� ����
				' ������ �������� �� �����; (2) ���� �� �����������, � � ������ ��� �� ������ 
				' ���������� ����, �� ������������� �������� ������ ����������; (3) ���������
				' ���������� ������ - ���� �� �� ������������, �� ��������� ������� (����� ���
				' �� ����� ������ ��������� ��� ����������), ���� ���������� � ������������� 
				' �������� ������� - �� �� ��� ��������� ���������:
				.HtmlElement.style.backgroundColor = iif( bShowUtilization, "", "#e0dad0" )
				If (bShowUtilization And 0 = oActivityTypes.childNodes.length) Then
					If (.HtmlElement.Rows.Count > 0) Then
						.HtmlElement.Rows.GetRow(0).Checked = True
						.HtmlElement.Rows.SelectedID = .HtmlElement.Rows.GetRow(0).ID
					End If
				ElseIf (Not bShowUtilization) Then
					.HtmlElement.Rows.Selected = -1	
				End If
			
			End With
			
			' �������������� ��������� ������ ����������� ������ ���������, ��������� 
			' �� ������� "����� �����������" - �������� ����, ��� ������, ������: ����
			' �� �� �����, �� ���� ������ ���������� �� "�����":
			applayLockTextStyleClassFor tdActivityTypesAsExternalBlock, Not(bShowUtilization)
			
			' ��������� ���������� ������� "����������": �������� "�� �������� ����������" �
			' "�� �������� ��" �������� ������ �����, ����� �������� ��������������� �������.
			' ���� ��� ����������, ��� � ���. �������� ������ "�����������" �������, ��
			' ������������� ���������� �������� ���������� � ������� "�� ������������":
			With .GetPropertyEditor(oSortingMode) 
				bIsRestrictedValue = _
					( ( REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYDISBALANCE = CLng(.Value) ) And Not(bShowDisbalance) ) Or _
					( ( REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYUTILIZATION = CLng(.Value) ) And Not(bShowUtilization) )
				If (bIsRestrictedValue) Then .Value = REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYNAME
			End With
			
		End If
	End With
End Sub

' ���������� ���������� ������� Changed ��� XPE ������ "������������ �������"
' ���������:
'	[in] oSender - ��������� XPE, XPESelectorComboClass
'	[in] oEventArgs - ��������� ChangeEventArgsClass (��. x-pe-object-dropdown.vbs)
Sub usr_FilterReportDepartmentExpensesStructure_ShownColumns_OnChanged( oSender, oEventArgs )
	applyFlagsShownColumns oEventArgs.NewValue
End Sub


'===============================================================================
' ���������� �����, �������� ���������� �������� "ExpensesSumAsPercentBase" 
'	� ������������ �� ��������� �������������� ��������� "�� 100% �����"
' ���������:
'	[in] nPercentBase - 0 - �� 100% ������� ����� ������ �� �������
'						1 - �� 100% ������� ����� ������ �� ������
Sub applyPercentBase( nPercentBase )
	g_oEditor.SetPropertyValue g_oEditor.GetProp("ExpensesSumAsPercentBase"), CBool( 0<>CLng(nPercentBase) )
End Sub

' ���������� ���������� ������� Change ��� ��������� "�� 100% �����"
Sub selPercentBase_OnChanged()
	applyPercentBase window.event.srcElement.value
End Sub


'===============================================================================
' ���������� ���������� ������� Changing ��� ��������� "����������"
' ���������:
'	[in] oEventArgs - ��������� ChangeEventArgsClass
Sub usr_FilterReportDepartmentExpensesStructure_SortingMode_OnChanging( oSender, oEventArgs )
	Dim bShowDisbalance		' ������� ����������� ������� "���������"
	Dim bShowUtilization	' ������� ����������� ������� "����������� ����������"
	Dim bIsRestrictedValue	' ��������� ������� - ��������� ����� � ������ ������ ����������
	
	With g_oEditor.CurrentPage.GetPropertyEditor( g_oEditor.GetProp("ShownColumns") )
		bShowDisbalance = CBool( ( .Value And REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODDISBALANCE ) > 0 )
		bShowUtilization = CBool( ( .Value And REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWUTILIZATION ) > 0 )
	End With
	
	bIsRestrictedValue = _
		( ( REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYDISBALANCE = CLng(oSender.Value) ) And Not(bShowDisbalance) ) Or _
		( ( REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYUTILIZATION = CLng(oSender.Value) ) And Not(bShowUtilization) )

	If (bIsRestrictedValue) Then
		MsgBox _
			"���������� ���������� ������� ���������� ���������� - ��������������� ������� ������ ������.", _
			vbOkOnly + vbExclamation, "��������������"
		oSender.Value = REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYNAME
		oEventArgs.ReturnValue = False
	End If
End Sub


'===============================================================================
' ���������� ����� ��������� ����� ����������� ������� (�����) � HTML-�������,
'	�������� ������� oMainHtmlElement. ������������ ��� ����������� �����������
'	"�������������" ��� ������������� ���������. 
' ���������:
'	[in] oMainHtmlElement - HTML-�������, � ������� ��� ���� DIV �������������� �����
'	[in] bIsLockTextStyle - ���� True, �� ��� ���� ��������� DIV ���� ������ �������� 
'			��� "����-�����"; ���� False, �� ���� ������ ����������
Sub applayLockTextStyleClassFor( oMainHtmlElement, bIsLockTextStyle ) 
	Dim oElement
	For Each oElement In oMainHtmlElement.all.tags("DIV")
		If bIsLockTextStyle Then
			oElement.style.color = "#789"
		Else
			oElement.style.color = ""
		End If
	Next
End Sub


'===============================================================================
' ��������� ������ ��������. ����� ������������ ��� �������� ������� ��������:
' -- �� ����������� ������� ���������, ��������� �� ���� ������ (�.�. ����� 
'	���� ������ �� ������), ��������� � ������������������ ����� ����. 
' -- � ������ ������� ��������� ������������������ ����� ��� � ������� (��� 
'	������) ��������� �������������� � ���, ��� ����� �� ����� ������ ����� 
'	������������� �����.
' -- ���� ������� ����������� ������� � ������������� ����������, �� �����������
'	������� ���� �� ������ ���� ��������� ����������� - ��� �� ��� �����������
' ���������:
'	[in] oSender - ObjectEditorClass
'	[in] oEventArgs - EditorStateChangedEventArgs
Sub usrXEditor_OnValidatePage(oSender, oEventArgs)
	Dim dtIntervalBegin		' ���� ������ ���. �������
	Dim dtIntervalEnd		' ���� ����� ���. �������
	Dim nFlags				' �����, ���. ����������� ���. �������
	Dim sMessage			' ����� ���������
	Dim vMessageType		' ��� ��������� (��� ���� vbCritical ��� vbQuestion)
	Dim vMsgBoxRet			' ��������� ������ ������������ (��� vbQuestion)
	
	' ��� �������� - ������ ��� ����, ��� �� ������������ ������������, ��� 
	' ����� ����� ������������� �����. ���� � ��� "����� �����" (� ���������,
	' ��� ������ ��� ������� ����� �� Cancel ;) - �� � ��������� ������ �� ����...
	If oEventArgs.SilentMode Then Exit Sub
	' ...� ������ - ��� �������� - ������ ��� �������� ��������� ������� "��":
	If REASON_OK <> oEventArgs.Reason Then Exit Sub
 	
	With oSender ' ObjectEditor
		dtIntervalBegin = .GetPropertyValue("IntervalBegin" )
		dtIntervalEnd = .GetPropertyValue("IntervalEnd" )
	End With
	
	' #1: �������� ������� ��������� �������:
	' ���� ���� ����� ������� �� ������, �� ������� �� ������� - 
	' ��� ����������� �������� ��� ������ ���������:
	If Not hasValue(dtIntervalEnd) Then dtIntervalEnd = Now()
	
	' ���� ������ ������� �� ������:
	If Not hasValue(dtIntervalBegin) Then
		sMessage = "���� ������ ��������� ������� �� ������."
		vMessageType = vbCritical
	' ������� �/� ����� ������ � ����� ������� ����� ���� 
	ElseIf DateDiff( "m", dtIntervalBegin, dtIntervalEnd ) > 12 Then
		sMessage = "��������� ���� ��������� �������� ������ ������������������ ����� ����."
		vMessageType = vbCritical
	End If
	If ( Len(sMessage) > 0 ) Then
		sMessage = sMessage & vbCr & _
			"������������ ������ ��� ������ ������� ����������." & vbCr & _
			vbCr & _
			"��� ��������� ���������� �� ��������� ������ ������������� �� ������ ������� " & vbCr & _
			"������������������ ����� ���� ��������������, ����������, �������������� �������."
	End If
	
	If DateDiff( "m", dtIntervalBegin, dtIntervalEnd ) > 3 Then
	' ������� �/� ����� ������ � ����� ������� ����� �������� (3 ������)
		sMessage = _
			"��������� ���� ��������� �������� ������ ������������������ ����� ��������." & vbCr & _
 			"������������ ������ ��� ������ ������� ����� ������ ��������������� �����." 
		vMessageType = vbQuestion
	End If
	
	' #2: �������� ������� ���� �� ����� ����������� ��� �������������:
	If	( 0 = g_oEditor.GetProp("Organizations").childNodes.length ) And _
		( 0 = g_oEditor.GetProp("Departments").childNodes.length ) _
	Then
		sMessage = "������������� ��� ����������� �� �������!"
		vMessageType = vbCritical
	End If
	
	' #3: �������� ������� ���� ����������� � ������ ����������� ������ ��:
	nFlags = CLng( g_oEditor.GetProp("ShownColumns").nodeTypedValue )
	' ...����������� "����������� ����������" ��������?
	If ( ( nFlags And REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWUTILIZATION ) > 0 ) Then
		' �������� ������� ������� ���� �� ������ ���� ����������:
		If ( 0 = g_oEditor.GetProp("ActivityTypesAsExternal").childNodes.length ) Then
			sMessage = _
				"��� ����������� ������� ������������ ���������� ��������� �������� ���� �� ������ " & vbCr & _
				"���� �����������, ������� �� ������� ����� ��������������� ��� ""�������"" �������."
			vMessageType = vbCritical
		End If
	End If
	
	' #4: ���� ���� ��� ���������� - ����������:
	If hasValue(sMessage) Then
		' ��� ��������� � ����������� ������ (��������������) ������� �� ���� ���������:
		' -- ��� ��������� � _�������������_ ������� ������ ��� ���������� �������: 
		If (vbCritical = vMessageType) Then
 			vMsgBoxRet = MsgBox( "��������!" & vbCr & sMessage, vMessageType + vbOKOnly, "��������������" )
		
		' -- ��� ��������������; ��� ������������ ��������, ��������� �� �����:
		Else
 			vMsgBoxRet = MsgBox( _
 				"��������!" & vbCr & sMessage & vbCr & vbCr & "���������� ����������?", _
 				vMessageType + vbYesNo + vbDefaultButton2, "�������������" )
		End If
		
		' ���� ������������ ������������ �� ����������� ��� ���� ������ ������������
		' ���������� (����� ������� - vMsgBoxRet != vbYes), �� ��������� ���������� 
		' ���������� ���������, ����� ReturnValue � False. ������������ �������� � 
		' ���������, ����� �� �����������...
 		oEventArgs.ReturnValue = CBool( vMsgBoxRet = vbYes )
	End If
End Sub
