'*******************************************************************************
' ����������:	
' ����������:	��������/������ ����� ������� ���������� ������ "������� 
'				� ������� �����������"
'*******************************************************************************
Option Explicit

' ���������, �����. ��������� ��������� "����������� ����������" (selAnalysisType)
Const AnalysisDirection_ByCustomer = "ByCustomer"	' - "����������� - �����������"
Const AnalysisDirection_ByActivity = "ByActivity"	' -  "���������� - �����������"

Dim g_oEditor	' ����������� ������ �� ObjectEditor; ������������ � usrXEditor_OnPageStart
Dim g_bIsInited	' ������� ���� ������������� (��������������� � True � ������ ����������� 
				' usrXEditor_OnPageStart). ��������� ��� ������������ ������ ������������
				' � ����� ������ ����� �����������, ��������� ���� �������������. � ����
				' ������, ���� ����������� ��� �� ������, ��� ����� �������� ������ ������
				' �����������, ������� ������������ ���� - ��. applySelectedAnalisysType 
				' (������ ����������� ������� �� ����������) � applayCustomersSelection
g_bIsInited = False

'===============================================================================
' ���������� ������� �������� ������ �������� ������� / ���������
'	�������������� �����. ���������� ������ �� ������ ���������; 
'	�������������� UI
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	Dim bWasSetTargetCustomer	' �������, ��� ��� ���������� ������� ��� ����� ���������� ������
	Dim bWasSetTargetActivity	' �������, ��� ��� ���������� ������� ���� ������ ����������

	' ���������� ���������� ������
	Set g_oEditor = oSender
	
	' �������������� "�����������" ������, ���������� � ���������� ���: ��� ����,
	' ��� �� ��������� ������������ ��� ��������� - ��� �� ��� � ������� ���
	'	- ���� �� ������ ���������� ����������?
	bWasSetTargetActivity = hasValue( g_oEditor.CurrentPage.GetPropertyEditor( g_oEditor.GetProp("Folder") ).Value )
	'	- ���� �� ������ ���������� �����������?
	bWasSetTargetCustomer = Not(bWasSetTargetActivity) And hasValue( g_oEditor.CurrentPage.GetPropertyEditor( g_oEditor.GetProp("Organization") ).Value )
	
	' ��������� ������ ����� ���������� ��-���; � ���� ������ "������������" ������
	' ����� ������� ���������. � ������ (� ���� ���������) ������� ��� ��������
	' ������������� "����������� �������", ��������� �������� ������������ �� ����,
	' ������ �� ������������� ����������� ��� ����������. ���� � ���������� ��������
	' ��� ��������, �� ��� ������ �� UI:
	If g_oEditor.QueryString.IsExists(".Organization") Then
		If hasValue( g_oEditor.QueryString.GetValue(".Organization","") ) Then
			bWasSetTargetActivity = False
			bWasSetTargetCustomer = True
		Else
			bWasSetTargetCustomer = False
		End If
	End If
	If g_oEditor.QueryString.IsExists(".Folder") Then
		If hasValue( g_oEditor.QueryString.GetValue(".Folder","") ) Then
			bWasSetTargetActivity = True
			bWasSetTargetCustomer = False
		Else
			bWasSetTargetActivity = False
		End If
	End If
	
	' ������������� PE ������� �������� �������
	InitPeriodSelector(oSender)
	
	' ������������� ��������� �������� UI:
	With g_oEditor.CurrentPage.HtmlDivElement
	
		' ������� ������� �� radio-�������������, ������ ������������ �� 
		' ��������� � ����������� �� "�����������" ������:
		With .all.item("rdCustomersSelectionAll",0)
			.checked = Not(bWasSetTargetCustomer)
			.attachEvent "onclick", GetRef("internal_rdCustomersSelectionAll_OnClick")
		End With
		With .all.item("rdCustomersSelectionTarget",0)
			.checked = bWasSetTargetCustomer
			.attachEvent "onclick", GetRef("internal_rdCustomersSelectionTarget_OnClick")
		End With
		
		With .all.item("selAnalysisType",0)
			' ������������� �������� ��������� � ����������� �� "�����������" ������:
			If bWasSetTargetActivity Then
				.Value = AnalysisDirection_ByActivity
			Else
				.Value = AnalysisDirection_ByCustomer
			End If
			.attachEvent "onchange", GetRef("internal_selAnalysisType_OnChange")
			applySelectedAnalisysType CBool( .value = AnalysisDirection_ByCustomer )
		End With
		
		' �������� �������������� ��������� "�����������" �������� ��������� ShowDetails ������ �������:
		With .all.item("selDetalization",0)
			If CBool( g_oEditor.GetPropertyValue("ShowDetails" ) ) Then
				.Value = "1"
			Else
				.Value = "0"
			End If

			' ���� ������ ������� ���������� - �� ����������� ����������:
			' ������������� ������������ ��������:
			If (bWasSetTargetActivity) Then
				applayDetalizationSelection False
				.Value = "0"
				.disabled = True
			End If
			
			.attachEvent "onchange", GetRef("internal_selDetalization_OnChange")
		End With
		
		' �������� �����������
		.all.item("divPagePane",0).style.visibility = "visible"
	End With
	
	' ������������� ��������� (��. ����������� � ���������� ����������):
	g_bIsInited = True
End Sub


'===============================================================================
' ��������� ������ ��������. ����� ������������ ��� �������� ��������� �������
' �, � ������ ������� �������� �������, ����������� �������������� � ���, ��� 
' ����� �� ����� ������ ����� ������������� �����.
'	[in] oEventArgs As oEditorStateChangedArgs
Sub usrXEditor_OnValidatePage(oSender, oEventArgs)
	Dim dtIntervalBegin
	Dim dtIntervalEnd
	Dim sMessage
	Dim vMsgBoxRet
	
	' ��� �������� - ������ ��� ����, ��� �� ������������ ������������, ��� 
	' ����� ����� ������������� �����. ���� � ��� "����� �����" (� ���������,
	' ��� ������ ��� ������� ����� ;) - �� � ��������� ������ �� ����...
	If oEventArgs.SilentMode Then Exit Sub
	
	With oSender ' ObjectEditor
		dtIntervalBegin = .GetPropertyValue("IntervalBegin")
		dtIntervalEnd = .GetPropertyValue("IntervalEnd" )
	End With
	
	' ���� ���� ����� ������� �� ������, �� ������� �� ������� - 
	' ��� ����������� �������� ��� ������ ���������:
	If Not hasValue(dtIntervalEnd) Then dtIntervalEnd = Now()
	
	' #1: ���� ������ ������� �� ������:
	If Not hasValue(dtIntervalBegin) Then
		sMessage = "���� ������ ��������� ������� �� ������."
	' #2: ������� �/� ����� ������ � ����� ������� ����� ���� 
	ElseIf DateDiff( "m", dtIntervalBegin, dtIntervalEnd ) >= 12 Then
		sMessage = "��������� ���� ��������� �������� ������ ������������������ ����� ����."
	End If
	
	' ���� ���� ��� ���������� - ����������. ���� ������������ ������������
	' �� ����������� (vMsgBoxRet != vbYes), �� ��������� ���������� ����������
	' ���������, ����� ReturnValue � False. ������������ �������� � ���������,
	' ����� �� �����������...
	If hasValue(sMessage) Then
 		vMsgBoxRet = MsgBox( _
 			"��������!" & vbCr & sMessage & vbCr & _
 			"������������ ������ ��� ������ ������� ����� ������ ��������������� �����." & vbCr & _
 			vbCr & "���������� ����������?", _
 			vbQuestion + vbYesNo + vbDefaultButton2, "�������������" )
 		oEventArgs.ReturnValue = CBool( vMsgBoxRet = vbYes )
	End If
End Sub


'===============================================================================
' ��������� �����, �������������� ����������� ��������� ��������� � �����������
'	�� ��������� ����� bIsByCustomer, ����������� ������� ����������� ������� 
'	��� "����������� - �����������". ���������� �� ����������� ������� ���������
'	�������� ��������� "����������� �������" (��. �����)
' ���������:
'	[in] bIsByCustomer - True: ����������� ������� - "����������� - �����������",
'			����� (False) ����������� ������� - "���������� - �����������".
Sub applySelectedAnalisysType( bIsByCustomer )

	If CBool(bIsByCustomer) Then
		' ��������� ����������� ������� - "����������� - �����������";
		' ��������������:
		'	- �������� �������� � ���� ������ ���������� � ��������� ���� ����;
		'	- �������� �������� � ��������� ���� "���������� ������ � ��������� ���������..."
		'	- ������������ ����, �����. ����������, �������� ��������� ��������� ����� 
		'		������� ����������� (��� ��� ���������� ���������)
		'	- ������������ ����, �����. ������ ���� ����������;
		'	- ������������ ����, �����. ����� "�������� ������ ������ �������� �����������"
		'	- ������������� �������� ������ � ���� "�����������"
		With g_oEditor.CurrentPage
			With .GetPropertyEditor( g_oEditor.GetProp("Folder") ) 
				.Mandatory = False
				Set .Value = Nothing
				.Enabled = False
			End With
			With .GetPropertyEditor( g_oEditor.GetProp("ShowHistoryInfo") ) 
				.Value = False
				.Enabled = False
			End With
			
			.GetPropertyEditor( g_oEditor.GetProp("Organization") ).Enabled = True
			.GetPropertyEditor( g_oEditor.GetProp("FolderType") ).Enabled = True
			.GetPropertyEditor( g_oEditor.GetProp("OnlyActiveFolders") ).Enabled = True
			
			.HtmlDivElement.all.item("rdCustomersSelectionAll",0).disabled = False
			With .HtmlDivElement.all.item("rdCustomersSelectionTarget",0)
				.disabled = False
				' � ����������� �� ���������� ������ ������� ����������� - ���� ��� 
				' �����-�� ���������� - �������� ���������� ���� ������ ���� ����� 
				' ���������� �����������. 
				' ���� ����� ��� �� ������ �� ������ ����������� - � ���� ����������
				' ��������� ��� �� �������������� �������� ��������� selDetalizationYes
				applayCustomersSelection .checked
			End With 
			
			' ���� ������ ����������� �� �������� ����������, �� ����������� �����������;
			' ����� �� �������� ����������� ������� �����������:
			.HtmlDivElement.all.item("selDetalization",0).disabled = False
						
			applayLockTextStyleClassFor .HtmlDivElement.all.item("tdAnalysisDirByCustomer",0), False  
			applayLockTextStyleClassFor .HtmlDivElement.all.item("tdAnalysisDirByActivity",0), True
		End With
		
	Else
		' ��������� ����������� ������� - "����������- �����������";
		' ��������������:
		'	- ��������� ����� ������ ������ ������� ����������� (��� ��� ����������)
		'	- �������� ����, �����. ������ ����������, 
		'	- ����������� ����, �����. ������ ���� ����������;
		'	- ����������� ����, �����. ����� "�������� ������ ������ �������� �����������"
		'	- ������������ ���� ������ ����������;
		'	- ������������ ���� "���������� ������ � ��������� ���������..."
		'	- ������������� �������� ������ � ���� "�����������"
		With g_oEditor.CurrentPage
			.HtmlDivElement.all.item("rdCustomersSelectionAll",0).disabled = True
			.HtmlDivElement.all.item("rdCustomersSelectionTarget",0).disabled = True
		
			With .GetPropertyEditor( g_oEditor.GetProp("Organization") )
				.Mandatory = False
				Set .Value = Nothing
				.Enabled = False
			End With
			.GetPropertyEditor( g_oEditor.GetProp("FolderType") ).Enabled = False
			With .GetPropertyEditor( g_oEditor.GetProp("OnlyActiveFolders") )
				.Value = False
				.Enabled = False
			End With

			With .GetPropertyEditor( g_oEditor.GetProp("Folder") )
				.Enabled = True
				.Mandatory = True
			End With
			.GetPropertyEditor( g_oEditor.GetProp("ShowHistoryInfo") ).Enabled = True
			
			' ���� ������ ����������� �� �������� ����������, �� ����������� ����������
			With .HtmlDivElement.all.item("selDetalization",0)
				applayDetalizationSelection False
				.Value = 0
				.disabled = True
			End With
			' ...������ (�� ������ �������� ��������) �������� �������� �������� ������:
			.HtmlDivElement.all.item("selDetalizationYes",0).innerText = "�� �����������"
			
			applayLockTextStyleClassFor .HtmlDivElement.all.item("tdAnalysisDirByActivity",0), False
			applayLockTextStyleClassFor .HtmlDivElement.all.item("tdAnalysisDirByCustomer",0), True  
			
			' �������������� ��������:
			' ���� (�) ��� �� ���� ������������� (g_bIsInited = True), �.�. ���� �������������
			' ���������� ������������, � ���� (�) �������� ��������� "����������" ��� �� ������,
			' �� ����� ����� ����� ������� ������ ������ ���������� - ��������� ������������
			' ���� ���� ������ �� ������ ��������:
			If (True = g_bIsInited) Then
				With .GetPropertyEditor( g_oEditor.GetProp("Folder") )
					If Not hasValue(.Value) Then
						' NB! � ���������, ��� ������ ������� "�������" �������� DoSelectFormDb 
						' �� ���� object-selector-�. �������� ������: �.�. ��������, ��� �������� 
						' ������� ���� �������� "�� ���������", � ��� "�������" PE ����� ��������
						' ������ ���, ��������� ������� �� ������ "��������"; ���� ������ ������
						' ������� ����� HtmlElement - � PE object-selector � ���� �������� 
						' ������������ ������ ������:
						 .HtmlElement.click
					End If
				End With
			End If
			 
		End With
	End If
End Sub

' ���������� ���������� ������� OnChange ��� ��������� "����������� �������"
Sub internal_selAnalysisType_OnChange()
	applySelectedAnalisysType  CBool( window.event.srcElement.Value = AnalysisDirection_ByCustomer )
End Sub


'===============================================================================
' ���������� ����� ��������� ����� ����������� ������� (�����) � HTML-�������,
'	�������� ������� oMainHtmlElement. ������������ ��� ����������� �����������
'	"�������������" ��� ������������� ���������. 
' ���������:
'	[in] oMainHtmlElement - HTML-�������, � ������� ��� ���� LABEL �������������� �����
'	[in] bIsLockTextStyle - ���� True, �� ��� ���� ��������� LABEL ���� ������ �������� 
'			��� "����-�����"; ���� False, �� ���� ������ ����������
Sub applayLockTextStyleClassFor( oMainHtmlElement, bIsLockTextStyle ) 
	Dim oElement
	For Each oElement In oMainHtmlElement.all.tags("LABEL")
		If bIsLockTextStyle Then
			oElement.style.color = "#789"
		Else
			oElement.style.color = ""
		End If
	Next
End Sub


'===============================================================================
' ��������� �����, �������������� ����������� ��������� ��������� � �����������
'	�� ������ ������� ������ ����������� - ���� ��� ����������, ����������� 
'	radio-�������������� "rdCustomersSelection". ���������� �� ������������ 
'	������� OnClick �������� radio-������������� (��. �����)
Sub applayCustomersSelection( bIsTargetCustomer )
	bIsTargetCustomer = CBool(bIsTargetCustomer)
	
	With g_oEditor.CurrentPage
		' ����������� � ������������ ���� ������ ���������� �����������:
		With .GetPropertyEditor( g_oEditor.GetProp("Organization") )
			.Enabled = bIsTargetCustomer 
			.Mandatory = bIsTargetCustomer 
			
			If Not(bIsTargetCustomer) Then 
				Set .Value = Nothing
			Else
				' ����� ������ ���������� ����������� - �������������� ��������:
				' ���� (�) ��� �� ���� ������������� (g_bIsInited = True), �.�. ���� �������������
				' ���������� ������������, � ���� (�) �������� ��������� "�����������" ��� �� ������,
				' �� ����� ����� ����� ������� ������ ������ ����������� - ��������� ������������
				' ���� ���� ������ �� ������ ��������:
				If (True = g_bIsInited) Then
					If Not hasValue(.Value) Then
						' NB! � ���������, ��� ������ ������� "�������" �������� DoSelectFormDb 
						' �� ���� object-selector-�. �������� ������: �.�. ��������, ��� �������� 
						' ������� ���� �������� "�� ���������", � ��� "�������" PE ����� ��������
						' ������ ���, ��������� ������� �� ������ "��������"; ���� ������ ������
						' ������� ����� HtmlElement - � PE object-selector � ���� �������� 
						' ������������ ������ ������:
						.HtmlElement.click
					End If
				End If
			End If
			
		End With
	
		' "���" ����������� ����� ������� �� ����, ������������� �� ������ ���� 
		' �����������-��������, ��� ������ �����: � ������ ������ ����������� - 
		' �� ������������, �� ������ - �� ����������� ��������� �����������:
		.HtmlDivElement.all.item("selDetalizationYes",0).innerText = _
			iif( bIsTargetCustomer, "�� �����������", "�� ������������" )
	End With
End Sub

' ���������� ���������� ������� OnClick ��� �������� radio-������������� "��� �����������"
Sub internal_rdCustomersSelectionAll_OnClick()
	applayCustomersSelection false
End Sub

' ���������� ���������� ������� OnClick ��� �������� radio-������������� "�����������"
Sub internal_rdCustomersSelectionTarget_OnClick()
	applayCustomersSelection true
End Sub


'===============================================================================
' ���������� �����, �������������� �������� ��������� ShowDetails � �����������
' �� ��������� ����������� ��������
Sub applayDetalizationSelection( bShowDetail )
	g_oEditor.SetPropertyValue g_oEditor.GetProp("ShowDetails"), CBool(bShowDetail)
End Sub

' ���������� ���������� ������� ��������� �������� ��������� "�����������"
'	������������� ��������������� �������� ��� ���� "ShowDetails" ������ �������
Sub internal_selDetalization_OnChange()
	applayDetalizationSelection CBool(window.event.srcElement.value = "1")
End Sub

