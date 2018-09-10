Option Explicit

Class XListPageClass
	Public MetaName						' As String	- ��� ������ � ����������
	Public ObjectType					' As String	- ������������ ���� �������� � ������
	Private m_nMode						' As Byte - ����� ������ ������ (LM_LIST, LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE)
	Private m_oListView					' As CROC.IXListView - ������� ������
	Private m_sViewStateCacheFileName	' - ������������ ����� ��� ���������� �������� ������� � ���������� ����
	Private m_oListMD					' As IXMLDOMElement - ���������� ������ (i:objects-list-xml)
	Private m_oObjectEditor				' As ObjectEditor - ������ �� ��������, ���������� ��� �������������, ������������ ��� ���������� ��������� �������
	Private m_bMayBeInterrupted			' As Boolean - ������� ����������� ����������� �������� ��������
	
	'==========================================================================
	' "�����������"
	Private Sub Class_Initialize
		m_bMayBeInterrupted = true
		If IsObject(g_oXListPage) Then _
			If Not g_oXListPage Is Nothing Then _
				Err.Raise -1, "XListPageClass::Class_Initialize", "��������� ������������� ������ ������ ���������� XListPageClass"
		ObjectType = X_PAGE_OBJECT_TYPE
		MetaName = X_PAGE_METANAME
		m_nMode = LIST_MODE
		m_sViewStateCacheFileName = GetCacheFileName("columns")
    End Sub	


	'==========================================================================
	' ������������� ��������
	'   [in] oSelectFromXmlListDialogParams As SelectFromXmlListDialogParamsClass
	Sub Internal_Init(oSelectFromXmlListDialogParams)
	    Dim vListMD 
	    
		Set m_oListView = document.all( "List")

		' ���� ����� ������ ���������� ��������, ������� ����� �������
		If LM_MULTIPLE = Mode OR LM_MULTIPLE_OR_NONE = Mode Then
			m_oListView.CheckBoxes = True
		End If
		m_oListView.LineNumbers = Not LIST_MD_OFF_ROWNUMBERS
		m_oListView.GridLines = Not LIST_MD_OFF_GRIDLINES

        ' ������� ���������� ��������
	    Set vListMD = document.all("oListMD",0)
	    If Not vListMD Is Nothing Then 
		    vListMD = vListMD.value
		Else
		    Alert "�� ������� ���������� ��������"
		    Exit Sub
		End If
		Set m_oListMD = XService.XMLFromString(vListMD)
		
		Set m_oObjectEditor = oSelectFromXmlListDialogParams.ObjectEditor
		
		' �������������� ������������ ������ (�������)
		InitXListViewInterface m_oListView, m_oListMD, m_sViewStateCacheFileName, True

		' �������� ������ ������
		FillXListViewEx3 m_oListView, m_oObjectEditor, oSelectFromXmlListDialogParams.Objects, m_oListMD, Null, False
		
		' ��������� ��������� �� ������ ������ (����������� ������� ��������� �����)
		SetListFocus
		If m_oListView.Rows.Count > 0 Then 
			m_oListView.Rows.SelectedPosition = 0
		End If
		
		EnableControls True
		g_bFullLoad = True
	End Sub


	'==========================================================================
	' ���������� ����� ������ ��������: LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE
	Public Property Get Mode
		Mode = m_nMode
	End Property


	'==========================================================================
	' ������� ����, ��� �� �������� ����� ���� �������� ���������� ����
	' ������������ � window_OnBeforeUnload
	Public Property Get MayBeInterrupted
	    MayBeInterrupted = m_bMayBeInterrupted
	End Property 


	'==============================================================================
	' ���������� ��� ����� ��� ���������� ���������������� ������
	'	[in] sSuffix - ������ �����
	'	[retval] ������������ �����
	Private Function GetCacheFileName(sSuffix)
		GetCacheFileName = "XL.XML." & ObjectType & "." & MetaName & "." & sSuffix
	End Function


	'==========================================================================
	' ������������� ����� �� ������
	Public Sub SetListFocus()
		window.Focus()
		' ��������� ������ ����������� ��� ��������� ������ - �.�. ��� ������
		' � ���� ������� ������ (���������� ����, ���������� ���������� ������������ 
		' � �.�.) ����� ���� ���������� ��� �����
		on error resume next
		m_oListView.Focus()
		on error goto 0
	End Sub	


	'==========================================================================
	' ����������/���������� ����������� ��������� ��������
	Sub EnableControls( bEnable)
		enableControl "XList_cmdOpenHelp", bEnable
		enableControl "XList_cmdOk", bEnable
		enableControl "XList_cmdCancel", bEnable
		enableControl "XList_cmdSelectAll", bEnable
		enableControl "XList_cmdInvertSelection", bEnable
		enableControl "XList_cmdDeselect", bEnable
		XService.DoEvents
	End Sub


	'==========================================================================
	' ����������/��������� ������������ �������� �� ����� ������������ ��������
	' � ���������, ��� ������� ���� �� ��������
	Private Sub enableControl( sCtlName, bEnable)
		Dim oCtl
		Set oCtl = document.all( sCtlName)
		
		if not oCtl is nothing then
			oCtl.disabled = not bEnable
		end if
	End Sub


	'==============================================================================
	' ���������� ������ "OK"
	'	[in] oEventArg As ListSelectEventArgsClass
	Sub OnOk()
	    With New ListSelectEventArgsClass
		    If LM_SINGLE = Mode Then
			    ' � ������ ������ ������ ������� �������� ������������� ����������
			    .Selection = getSelectedObjectID()
		    Else
			    ' � ������ ������ ���������� �������� ��������� ������ ���������������
			    .Selection= getCheckedObjectIDs()		
		    End If
		    Select Case Mode
			    Case LM_SINGLE
				    If 0<>Len(.Selection) Then
					    X_SetDialogWindowReturnValue .Selection
					    window.close
				    Else
					    Alert "����� ������� ������"
				    End if
			    Case LM_MULTIPLE
				    If UBound(.Selection)>=0 Then
					    X_SetDialogWindowReturnValue .Selection
					    window.close
				    Else
					    Alert "����� �������� ���� �� ���� ������"
				    End If
			    Case LM_MULTIPLE_OR_NONE
					X_SetDialogWindowReturnValue .Selection
				    window.close
		    End Select 
	    End With	
	End Sub


	'==========================================================================
	' ���������� ������������� ���������� ������� ��� ������ ������
	Private Function getSelectedObjectID()
		getSelectedObjectID = m_oListView.Rows.SelectedID
	End Function


	'==========================================================================
	' ���������� ������ ��������������� ���������� �����
	Private Function getCheckedObjectIDs
		Dim vSel
		Dim nIdx
		Dim i
		
		ReDim vSel(m_oListView.Rows.Count - 1)	' ������������ ������ �� ���������� ����� � ������
		nIdx = 0
		With m_oListView.Rows
			For i=0 To .count -1
				With .GetRow(i)
					If .Checked Then
						vSel( nIdx) = .ID	' ������� �������������� ���������� ����� � ������
						nIdx = nIdx + 1
					End If
				End With
			Next
		End With
		ReDim Preserve vSel(nIdx - 1)	' ��������� � ������� ������ ��������������
		getCheckedObjectIDs = vSel
	End Function
	
	
	'==============================================================================
	' � ������ �������������� ������ �������� ��� ������
	Public Sub SelectAll
		Dim i
		If Mode <> LM_MULTIPLE And Mode <> LM_MULTIPLE_OR_NONE Then Exit Sub
		For i=0 to m_oListView.Rows.Count -1
			m_oListView.Rows.GetRow(i).Checked = True
		Next
	End Sub


	'==============================================================================
	' � ������ �������������� ������ ������� ������� �� ���� ��������� �����
	Public Sub DeselectAll
		Dim i
		If Mode <> LM_MULTIPLE And Mode <> LM_MULTIPLE_OR_NONE Then Exit Sub
		For i=0 to m_oListView.Rows.count -1
			m_oListView.Rows.GetRow(i).Checked = false
		Next
	End Sub


	'==============================================================================
	' � ������ �������������� ������ 
	Public Sub InvertSelection
		Dim i
		If Mode <> LM_MULTIPLE And Mode <> LM_MULTIPLE_OR_NONE Then Exit Sub
		For i=0 To m_oListView.Rows.count -1
			With m_oListView.Rows.GetRow(i)
				.Checked = NOT .Checked
			End With
		Next
	End Sub
	
	'==============================================================================
	' ��������� ��������� ������
	Public Sub ChangeSelectedRowState
		Dim nRow	' ������ ��������� ������
		
		If Mode <> LM_MULTIPLE And Mode <> LM_MULTIPLE_OR_NONE Then Exit Sub
		nRow = m_oListView.Rows.Selected
		If nRow>=0 Then
			m_oListView.Rows.GetRow(nRow).Checked = Not m_oListView.Rows.GetRow(nRow).Checked 
		End If
	End Sub

	
	'==============================================================================
	' ���������� �������� ��������
	Public Sub Internal_OnUnLoad
		X_SaveViewStateCache m_sViewStateCacheFileName, m_oListView.Columns.Xml
	End Sub
End Class

Dim g_oXListPage		' As XListPageClass
Dim g_nThisPageID		' ���������� ������������� ������� ��������
Dim g_bFullLoad			' ������� ������ �������� ��������

'==============================================================================
' ������������� ������� (���������� �� ������������� ��������)
'...�������� ������ ������...
g_bFullLoad = False
'...���������� ���������� ID...
g_nThisPageID = CLng( CDbl( Time()) * 1000000000 )


'==============================================================================
' ������������� ��������.
' ���������� �� ���������� ��������, � ��� ����� �������.
Sub Init()
    Dim oSelectFromXmlListDialogParams
    X_GetDialogArguments oSelectFromXmlListDialogParams
    If TypeName(oSelectFromXmlListDialogParams) <> "SelectFromXmlListDialogParamsClass" Then
        Alert "������: � �������� x-select-from-xml � dialogArguments ������ ���� ������� ��������� ������ SelectFromXmlListDialogParamsClass"
        window.close
    End If
	Set g_oXListPage = New XListPageClass
	g_oXListPage.Internal_Init oSelectFromXmlListDialogParams
End Sub


'<����������� window � document>
'==============================================================================
' ������������� ��������
Sub Window_OnLoad()	
	X_WaitForTrue "Init()" , "X_IsDocumentReady(null)"
End Sub

'==============================================================================
' ����������� ��������
Sub Window_OnUnLoad()
	g_nThisPageID = Empty	' ���������� �������������
	
	' ���� ������ ��� ���������� ������ ������ �� �����!
	If True <> g_bFullLoad Then Exit Sub
	
	g_oXListPage.Internal_OnUnLoad
End Sub


'==============================================================================
' ������� �������� ��������
Sub Window_onbeforeunload
	If Not IsObject(g_oXListPage) Then Exit Sub
	If Nothing Is g_oXListPage Then Exit Sub
	If g_oXListPage.MayBeInterrupted Then Exit Sub
	window.event.returnValue="��������!" & vbNewLine & "�������� ���� � ������ ������ ����� �������� � ������������� ������!"
End Sub

'==============================================================================
' ������� �������
Sub Document_onkeyUp
	' ������� ����� ���� ������ ��� �� ����, ��� ����� 
	' ������������������ ��������� g_oXListPage: ���� ��� ���,
	' �� ������ �� ������:
	If Not hasValue(g_oXListPage) Then Exit Sub

	If window.event.keyCode = VK_ESC Then
		' ������ Escape � ������ ������
		XList_cmdCancel_OnClick
	End If
End Sub
 

'==============================================================================
' ���������� ������ �������
Sub Document_OnHelp
	If True <> g_bFullLoad Then Exit Sub
	If X_MD_HELP_AVAILABLE Then
		window.event.returnValue = False
		X_OpenHelp X_MD_HELP_PAGE_URL
	End If
End Sub
'<����������� window � document>


'<����������� ������>
'==============================================================================
' �������� ���� � ������ ������ �� ������ "OK"
Sub XList_cmdOk_OnClick()
	If document.all( "XList_cmdOk").disabled Then Exit Sub	' ���� ������ ������������� - ������ �� ��� ������!
	g_oXListPage.OnOk 
End Sub


'==============================================================================
' �������� ���� � ������ ������ �� ������ "��������"
Sub XList_cmdCancel_OnClick()
	window.close
End Sub


'==============================================================================
' ����� ���� �������� � ������
Sub XList_cmdSelectAll_OnClick
	g_oXListPage.SelectAll
End Sub


'==============================================================================
' ������ ���������
Sub XList_cmdDeselect_OnClick
	g_oXListPage.DeselectAll
End Sub


'==============================================================================
' �������� ���������
Sub XList_cmdInvertSelection_OnClick
	g_oXListPage.InvertSelection
End Sub


'==============================================================================
' ���������� ������� �� ������ "�������"
Sub XList_cmdOpenHelp_OnClick
	Document_OnHelp
End Sub
'</����������� ������>


'==============================================================================
' ���������� ������� "OnDblClick" ActiveX-���������� CROC.IXListView - ������� ������� � ������ ������
Sub XListPage_OnDblClick(ByVal oSender, ByVal nIndex , ByVal nColumn, ByVal sID)
    If LM_SINGLE = g_oXListPage.Mode Then
		' ��� ������� ������ ������ �������� ��������� ������� ��	
		XList_cmdOk_OnClick
	Else
		' ��� ������� ������ ��������� ��������� (LM_MULTIPLE, LM_MULTIPLE_OR_NONE) ��������� ���� �� �������� ������
		g_oXListPage.ChangeSelectedRowState
	End If	
End Sub


'==============================================================================
' ������� ������� � ������
Sub XListPage_OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)
	If nKeyCode = VK_ENTER Then
		' ������ Enter � ������ ������
		XList_cmdOk_OnClick()
	End If
End Sub
