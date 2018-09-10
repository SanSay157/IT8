Option Explicit

Dim g_oFilterXmlObject '��������� ������ - ������ ��� ������ ������ �����  

'==============================================================================
' ������������� ������� ������ ��� ������ �����
Sub setUpXmlObjectOfFoldersTreeFilter(oObjectEditor)
	Dim oProp ' ���������� ��-�� ���������
	
	Set oProp = oObjectEditor.XmlObject.selectSingleNode("virtual-prop-filter")
	If oProp Is Nothing Then
		Set oProp = oObjectEditor.XmlObject.appendChild( oObjectEditor.XmlObject.ownerDocument.createElement("virtual-prop-filter") )
	End If
	Set g_oFilterXmlObject = oProp.firstChild
	If g_oFilterXmlObject Is Nothing Then
		' �������� � ���� ��������� ������ ��� ��������� ������� ��� ������ ������ �����
		Set g_oFilterXmlObject = oObjectEditor.Pool.CreateXmlObjectInPool( "FilterDKP" )
		' ������� ������ ������� � ����������� �������� ���������
		 oProp.appendChild X_CreateStubFromXmlObject(g_oFilterXmlObject)
	Else
		Set g_oFilterXmlObject = oObjectEditor.Pool.GetXmlObjectByXmlElement(g_oFilterXmlObject, Null)
	End If
End Sub

'==============================================================================
' ���������� ������� OnGetRestrictions
Sub usr_Folders_ObjectsTreeSelector_OnGetRestrictions(oSender, oEventArgs)
	Dim oBuilder
	Dim oProp
	
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
' ���������� ������ "���������" (�������� Folders)
Sub btnOpenFilterOfFoldersTree_onClick
	Dim oFilterDialog	' ��������� ������� ��������� (���������� �������)
	Dim vResult			' ��������� ������ ��������� 
	Dim nOldTS			' ts �� ������ ��������� � ������
	Dim oPE
	
	' ������� ��������� ������, �������� ��������� ������� ���������:
	Set oFilterDialog = new ObjectEditorDialogClass
	' ...� ���������� ������� ���������� ������ ������� ��������� (����� ���� 
	' �������������� ������ ������ �������������� ���������� ������� � ����� ���):
	Set oFilterDialog.ParentObjectEditor = g_oObjectEditor
	' ...��������� ��� ���� ��� � ������������� �������������� ������� - ��� 
	' ��� �� ������, ��� ������������ ������ ����������:
	Set oFilterDialog.XmlObject = g_oFilterXmlObject
	' ...��������� ���������������� �������� ���������, ������������� ��� 
	' ���������� ���������� ������� (��. ����������� � ����������):
	oFilterDialog.MetaName = "EditorInDialog"
	
	nOldTS = SafeCLng(g_oFilterXmlObject.getAttribute("ts"))
	
	' �������� ����������� ������� ���������:
	vResult = ObjectEditorDialogClass_Show(oFilterDialog)
	
	Set g_oFilterXmlObject = g_oObjectEditor.Pool.Xml.selectSingleNode("FilterDKP")

	If ( nOldTS = SafeCLng(g_oFilterXmlObject.getAttribute("ts")) ) Then
		' ���� �������� � ���������� Empty, ��� ��������, ��� �������� ��� ������
		' ��� �������� ��������� (�� ������ "��������" ��� ����); � ���� ������, 
		' ������ �� �������, ������ ������� �� �����������
		If Not hasValue(vResult) Then Exit Sub

		' �������� ���������� �����, ���������� � ���������� ������, ���������� 
		' �� �������:
		Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Folders"))
		oPE.Load
	End If
End Sub

'==============================================================================
' ���������� ������ "��������" (�������� Folders)
Sub btnClearFilterOfFoldersTree_onClick
	Dim oPE
	
	' ������� �������� "�����"
	g_oObjectEditor.XmlObject.selectNodes("Folders/*").removeAll
	' ������ ������ �������
	With g_oObjectEditor
		.XmlObject.selectSingleNode("virtual-prop-filter").selectNodes("*").removeAll
		g_oFilterXmlObject.parentNode.removeChild g_oFilterXmlObject
		Set g_oFilterXmlObject = Nothing
	End With
	' � ������ ��������
	setUpXmlObjectOfFoldersTreeFilter g_oObjectEditor
	' � ���������� �������� �����
	Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Folders"))
	oPE.Load
End Sub

'==============================================================================
' ���������/��������� ������ � ������ �����
Sub enableFolders()
	Dim oAllFoldersEditor ' ��-�� ������� "AllFolders"
	Dim oFoldersEditor ' ��-�� ������� "Folders"
	Dim oDepthEditor ' ��-�� ������� "ActivityAnalysDepth" (������� �������)
	' �������� �������� �������
	Set oAllFoldersEditor = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("AllFolders"))
	Set oFoldersEditor = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Folders"))
	Set oDepthEditor = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("ActivityAnalysDepth"))
	' ���� ������ ����� "��� ����������", �� ����� ����� � ������ ������ �� ��������.
	oFoldersEditor.Enabled = Not CBool(oAllFoldersEditor.Value)
	oDepthEditor.Enabled = Not CBool(oAllFoldersEditor.Value)
	document.all("btnOpenFilterOfFoldersTree").disabled = CBool(oAllFoldersEditor.Value)
	document.all("btnClearFilterOfFoldersTree").disabled = CBool(oAllFoldersEditor.Value)
End Sub

'==============================================================================
Sub usr_AllFolders_Bool_OnChanged(oSender, oEventArgs)
	enableFolders()	
End Sub