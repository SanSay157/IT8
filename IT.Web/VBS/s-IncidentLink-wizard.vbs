Option Explicit

Dim g_oObjectEditor
Dim g_oFilterXmlObject
Dim g_bFilterDKPInitialized
Dim g_sEditablePropertyName
Dim g_sIncidentID
'X_RegisterStaticHandler "usrXEditor_OnLoad", "usrXEditor_OnLoad_Wizard"
'X_RegisterStaticHandler "usrXEditor_OnPageStart", "usrXEditor_OnPageStart_Wizard"

'==============================================================================
' ���������� ������� Load ������ ��� ������� 
Sub usrXEditor_OnLoad(oSender, oEventArgs)
		
	Set g_oObjectEditor = oSender
	g_sEditablePropertyName =oSender.QueryString.GetValue("RealPropName","LinksFromRoleA")'������������ �������� � ������� Incident,���� 
	                                                                                      '����� �������� ����������� ������
	g_sIncidentID=oSender.ParentObjectEditor.XmlObject.getAttribute("oid")'������������� ���������,��� �������� ������� ������
	
	Set g_oFilterXmlObject = oSender.Pool.Xml.selectSingleNode("FilterDKP[@use-for='MultiChoiceIncident']")
	If g_oFilterXmlObject Is Nothing Then
		' �������� � ���� ��������� ������ ��� ��������� ������� ��� ������ ������ �����
		Set g_oFilterXmlObject = oSender.Pool.CreateXmlObjectInPool( "FilterDKP" )
		g_oFilterXmlObject.setAttribute "use-for", "MultiChoiceIncident"
		
		' ������� ������ ������� � ����������� �������� ���������� �������
	    oSender.XmlObject.appendChild( oSender.XmlObject.ownerDocument.createElement("virtual-prop-filter") ).appendChild X_CreateStubFromXmlObject(g_oFilterXmlObject)
	End If
	
		 
	Dim oTD
	'���� ����������� ������� ����� �������� ���������
	'Set oTD = xBarControl1.Rows(0).insertCell()
	'oTD.ID = "xCtrlPlace_cmdCreateNew"
	'oTD.ClassName = "x-bar-control-place x-editor-bar-control-place"
	'oTD.innerHTML =_
					'"<BUTTON ID='cmdCreateNew' DISABLED='-1' style='width:150px;' CLASS='x-button-wide'" & _
					'"	TITLE='������� ����� �������� � ���������� � ��� �����' LANGUAGE='VBScript' ONCLICK='cmdCreateNew_onClick'>" & _
					'"	<CENTER><B>������� �����</B></CENTER></BUTTON>"
					
	Set oTD = xBarControl1.Rows(0).insertCell(0)
	oTD.ID = "xCtrlPlace_cmdOK"
	oTD.innerHTML =_
					"<BUTTON ID='cmdOK' DISABLED='-1' style='width:100px;' CLASS='x-button-wide'" & _
					"	TITLE='��������� ��������� � ������� �������� ' LANGUAGE='VBScript' ONCLICK='cmdOK_onClick'>" & _
					"	<CENTER><B>OK</B></CENTER></BUTTON>"
					
	Set oTD = xBarControl1.Rows(0).insertCell(1)								
	oTD.ID = "xCtrlPlace_cmdUpdate"
	oTD.innerHTML =_
					"<BUTTON ID='cmdUpdate' DISABLED='-1' style='width:100px;' CLASS='x-button-wide'" & _
					"	TITLE='��������' LANGUAGE='VBScript' ONCLICK='cmdUpdate_onClick'>" & _
					"	<CENTER><B>��������</B></CENTER></BUTTON>"						
End Sub


'==============================================================================
Sub cmdCreateNew_onClick
	Dim sID
	sID = X_OpenObjectEditor( "Incident", Null, "WizardWithSelectFolder", "")
	If hasValue(sID) Then
		g_oObjectEditor.Pool.AddRelation g_oObjectEditor.XmlObject, g_sEditablePropertyName, X_CreateObjectStub("Incident", sID) 
		X_SetDialogWindowReturnValue sID
		' � ������� ����
		window.Close
	End If
End Sub
'==============================================================================
' ���������� ������ "��������"
Sub cmdUpdate_onClick
'�������� �������� Incidents ���������� ������� - ��������� XPEObjectsTreeSelectorClass
Dim oPE
Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Incidents"))
		oPE.Load
End Sub

'==============================================================================
Sub usrXEditor_OnSetCaption(oSender, oEventArgs)
	Dim oIncident
	Dim sCaptionHTML
	Set oIncident = oSender.Pool.GetXmlObject("Incident",g_sIncidentID, Null)
	
	If  g_sEditablePropertyName="LinksFromRoleA"  Then
		sCaptionHTML = "����� ����������, �� ������� ������� �������� �"
	Else
		sCaptionHTML = "����� ����������, ����������� �� �������� �"
	End If
	
	If Len( oIncident.selectSingleNode("Number").text ) > 0 Then
		sCaptionHTML = "<span style='font-size:14pt;'>" & sCaptionHTML & oIncident.selectSingleNode("Number").text & "<BR>" & oIncident.selectSingleNode("Name").text & "</span>"
	Else
		sCaptionHTML = "<span style='font-size:14pt;'>����� ���������</span>"
	End If
	oEventArgs.EditorCaption = sCaptionHTML
End Sub


'==============================================================================
'	[in] oEventArgs As EditorStateChangedEventArgs
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	g_bFilterDKPInitialized = True
End Sub


'==============================================================================
Sub usrXEditorPage_OnAfterEnableControls(oSender, oEventArgs)
	document.all("oIncidentNumber").disabled = Not oEventArgs.Enable
	document.all("btnOnFindIncident").disabled = Not oEventArgs.Enable
	'document.all("cmdCreateNew").disabled = Not oEventArgs.Enable
	document.all("cmdOK").disabled = Not oEventArgs.Enable
	document.all("cmdUpdate").disabled = Not oEventArgs.Enable
End Sub


'==============================================================================
' ������������ ����������� ���������� ������.
' ��������: ���������� ���������� ����������: 
'	g_bFilterDKPInitialized
'	g_oFilterXmlObject
' [in] oSender As XPEObjectTreeSelectorClass
' [in] oEventArgs As GetRestrictionsEventArgsClass
Sub usr_ObjectsTreeSelector_OnGetRestrictions(oSender, oEventArgs)
	Dim oBuilder
	Dim oProp
	
	' True - ������ "���������� �����"
	' ����������: ��� �� ���������� ��������� GetData, �.�. ��� ���� �������� ������ ���������� ������� ��� ����������
	If g_bFilterDKPInitialized Then
		' ���� �������� � �������� ���� ����������������, �� �������� ���� ������, �����,
		' ���� ����������� ���������� ��� 1-�� ���������� PE, �� �������� ������ � ����� �� ����, ��� ��� ��� �� ���� ����������������!
		oSender.ObjectEditor.FetchXmlObject True
	End If
	Set oBuilder = New QueryStringParamCollectionBuilderClass
	' �� ���� ��������� ���������� �������-������� 
	For Each oProp In g_oFilterXmlObject.selectNodes("*")
		If Not IsNull(oProp.dataType) Then
			If 0 < Len(oProp.text) Then
				oBuilder.AppendParameter oProp.tagName, oProp.text
			End If	 
		End If	 
	Next
	oEventArgs.ReturnValue = oBuilder.QueryString
End Sub


'==============================================================================
' ��������� ����� ��������� �� ������
Sub OnIncidentFind(vIncidentNumber)
	Dim oResponse				' ����� ��������� ��������
	Dim oPE                     ' �������� �������� (x-pe-objects-tree-selector)
	Dim oFilterObjectBackup		' ������ �� g_oFilterXmlObject
	
	If not hasValue(vIncidentNumber) Then
		Alert "���������� ������ ����� ���������"
		Exit Sub
	End If
		
	g_oObjectEditor.EnableControls False
	On Error Resume Next
	With New IncidentLocatorInTreeRequest
		.m_sName = "IncidentLocatorInTree"
		.m_sIncidentOID = Null
		.m_nIncidentNumber = vIncidentNumber
		Set oResponse = X_ExecuteCommand( .Self )
	End With
	
	g_oObjectEditor.EnableControls True
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
		On Error Goto 0
		If Len("" & oResponse.m_sPath) = 0 Then
			MsgBox "�������� � ������� " & vIncidentNumber & " �� ������", vbInformation
		Else
			g_oObjectEditor.EnableControls False
			Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Incidents"))
			oPE.HtmlElement.SetNearestPath oResponse.m_sPath, false, true
			' ���� �� ������� ������������������ �� �������� � �������� �������, ���������� ������ � ����������� ������ ������ � ��������
			If Not CheckActiveNode(oPE.HtmlElement, "Incident", oResponse.m_sObjectID) Then
				' ���������� ������ � ������, �������� �� ����, ������� ����� �������. 
				' ��� ����� �������� ������ �� ������-�������, ������������ � usr_ObjectTreeSelector_OnGetRestrictions, 
				' �� ������ ������ Load, � ����� ����������� ��� ����
				Set oFilterObjectBackup = g_oFilterXmlObject
				' ��� ������������ ����� ������ � usr_ObjectTreeSelector_OnGetRestrictions (� ������ ������ ���� ������ �� ����� ������)
				g_bFilterDKPInitialized = False
				Set g_oFilterXmlObject = X_GetObjectFromServer("FilterDKP", Null, Null)
				g_oFilterXmlObject.selectSingleNode("Mode").nodeTypedValue = DKPTREEMODES_ORGANIZATIONS
				g_oFilterXmlObject.selectSingleNode("OnlyOwnActivity").nodeTypedValue = False
				oPE.Load
				oPE.HtmlElement.SetNearestPath oResponse.m_sPath, false, true
				Set g_oFilterXmlObject = oFilterObjectBackup
				g_bFilterDKPInitialized = True
				' ���� �� � ����� ����� �� ������� ����� �������� � ������, ������ � ����� ������������ ���� ��� ���������
				If Not CheckActiveNode(oPE.HtmlElement, "Incident", oResponse.m_sObjectID) Then
					
				End If
			End If
			g_oObjectEditor.EnableControls True
		End If
	End If
End Sub

'==============================================================================
' ���������� ������ "OK"
Sub cmdOK_OnClick
    Dim oPE   ' �������� �������� (x-pe-objects-tree-selector)
    Dim oNode ' ������� ������� � ������
     
    Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Incidents"))
        
   '���������, ��� � ������ ������ ���� �� ���� ��������
   If  oPE.TreeView.Selection.ChildNodes.Length = 0 Then
       Alert "��� �������� ������ ������ ���� ������ ���� �� ���� ��������" 
       Exit Sub
   End If
   
   '�������� �� ���������� ����� ������  � ���������� �������������� ���������� � �������� ������ 
   For Each oNode In oPE.TreeView.Selection.ChildNodes
     If oNode.getAttribute("id") = g_sIncidentID Then
       Alert "����� �� ����� ���� ����������� ����� ����� � ��� �� ����������"
       Exit Sub
     End If
   Next

   X_SetDialogWindowReturnValue Array(oPE.TreeView.Selection)
     
   '������� ���������� �������� � ������,��� ����� ������� ������, ������� ������������ � �������� Incidents  ���������� �������
   oPE.Internal_OnClear
   window.Close
End Sub
