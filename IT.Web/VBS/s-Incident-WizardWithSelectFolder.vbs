Option Explicit

Dim g_oFilterXmlObject
Dim g_sViewStateCacheFileName
Dim g_bFilterDKPInitialized

X_RegisterStaticHandler "usrXEditor_OnLoad", "usrXEditor_OnLoad_WizardWithSelectFolder"
X_RegisterStaticHandler "usrXEditor_OnPageStart", "usrXEditor_OnPageStart_WizardWithSelectFolder"

'==============================================================================
' ���������� ������� Load ������ ��� ������� 
Sub usrXEditor_OnLoad_WizardWithSelectFolder(oSender, oEventArgs)
	Dim oFilterXmlObjectCached
	Dim oProp
	Dim oPropCached
	
	g_bFilterDKPInitialized = False
	g_sViewStateCacheFileName = oSender.Signature() & "FilterDKP"
	' �������� � ���� ��������� ������ ��� ��������� ������� ��� ������ ������ �����
	Set g_oFilterXmlObject = oSender.Pool.CreateXmlObjectInPool( "FilterDKP" )
	' ����������� �������� ������� ��������� �������
	If X_GetDataCache( g_sViewStateCacheFileName, oFilterXmlObjectCached ) Then
		For Each oProp In g_oFilterXmlObject.childNodes
			If Not IsNull(oProp.dataType) Then
				Set oPropCached = oFilterXmlObjectCached.selectSingleNode(oProp.tagName)
				If Not oPropCached Is Nothing Then
					If oProp.dataType = oPropCached.dataType Then
						oProp.nodeTypedValue = oPropCached.nodeTypedValue
					End If
				End If
			End If
		Next
	End If
	' ������� ������ ������� � ����������� �������� ���������
	oSender.XmlObject.appendChild( oSender.XmlObject.ownerDocument.createElement("virtual-prop-filter") ).appendChild X_CreateStubFromXmlObject(g_oFilterXmlObject)
End Sub


'==============================================================================
'	[in] oEventArgs As EditorStateChangedEventArgs
Sub usrXEditor_OnPageStart_WizardWithSelectFolder(oSender, oEventArgs)
	If oSender.CurrentPage.PageName = "FolderSelection" Then
		g_bFilterDKPInitialized = True
	End If
End Sub


'==============================================================================
' [in] oSender As XPEObjectTreeSelectorClass
' [in] oEventArgs As GetRestrictionsEventArgsClass
Sub usr_Folder_ObjectTreeSelector_OnGetRestrictions(oSender, oEventArgs)
	Dim oBuilder
	Dim oProp
	
	' True - ������ "���������� �����"
	' ����������: ��� �� ���������� ��������� GetData, �.�. ��� ���� �������� ������ ���������� ������� ��� ����������
	If g_bFilterDKPInitialized Then
		' ���� �������� � �������� ���� ����������������, �� �������� ���� ������, �����,
		' ���� ����������� ���������� ��� 1-jv ���������� PE, �� �������� ������ � ����� �� ����, ��� ��� ��� �� ���� ����������������!
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


Sub usrXEditor_OnSaved(oSender, oEventArgs)
	' � ������ ��������� ���������� (������� ��������� ������� Saved) �������� ������ ���������� �������
	X_SaveDataCache g_sViewStateCacheFileName, g_oFilterXmlObject
End Sub
