Option Explicit

Dim g_nServiceType	' ��� "������� ������������" ��� ������������� ������� 
					' ������, �������� ������������ ServiceSystemType

'-------------------------------------------------------------------------------
' ���������� ������� OnLoad ��������� ObjectEditor.
' ���������� ��� ������� ������������, �������������� � ������ �������
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	g_nServiceType = oSender.Pool.GetPropertyValue(oSender.XmlObject,"LinkType.ServiceType" )
End Sub


'-------------------------------------------------------------------------------
' ���������� ������� OnBeforePageStart ��������� ObjectEditor.
' ��������� � ������������� ��������� ���������: � ������������ � ����� �������
' ������������ � ������� ��������� (������ / ��������)
Sub usrXEditor_OnBeforePageStart( oSender, oEventArgs )
	Dim sCaption
	If oSender.IsObjectCreationMode Then 
		sCaption = NameOf_ServiceSystemType(g_nServiceType)
		sCaption = "����� " & LCase( Left(sCaption,1) ) & Mid(sCaption,2)
	Else
		sCaption  = NameOf_ServiceSystemType(g_nServiceType)
	End If
	oSender.SetCaption sCaption, sCaption
End Sub


'-------------------------------------------------------------------------------
' ���������� ������ btnGetDCTMLink (������ ������� �������� ����� ������)
Sub btnGetDCTMLink_OnClick(oObjectEditor)
	Dim oXmlLinkType		' XML-������������� ���� ������
	Dim sLinkValue			' �������� ������� ������ 
	
	sLinkValue = oObjectEditor.GetPropertyValue("URI" )

	Select Case g_nServiceType
		Case SERVICESYSTEMTYPE_URL
			' ����� ����� �� "�����������������" - ������������ ������ URL ����
			
		Case SERVICESYSTEMTYPE_FILELINK
			' ������ �� ����: ����������� ������� ������ �����
			sLinkValue = "" & XService.SelectFile( _
				"������� ����", _
				BFF_PATHMUSTEXIST or BFF_FILEMUSTEXIST or BFF_HIDEREADONLY, _
				"", sLinkValue, "" )
			' ...���� ������ ������ "�������", �� �������� ����� ������ - �������:
			If Not hasValue(sLinkValue) Then Exit Sub
			' ���������� ���������� �������� ������; � �������� ������������ ��-
			' ��������� ������������ ��� �����, ��� ����:
			SetLinkValues oObjectEditor, XService.GetFileTitle(sLinkValue), sLinkValue
		
		Case SERVICESYSTEMTYPE_DIRECTORYLINK
			' ������ �� �������: ����������� ������� ������ ��������
			Dim objFolder	' ������ �����, FSO.Folder
			Dim vFlags		' ����� ������, ���������� ��� ������� ������ �����:
			
			' ������������ ��������� �����:
			'	0x0010	- BIF_EDITBOX
			'	0x0040	- BIF_NEWDIALOGSTYLE
			'	0x0001	- BIF_RETURNONLYFSDIRS
			'	0x0020	- BIF_VALIDATE
			vFlags = CLng( &h0010 + &h0040 + &h0001 + &h0020 )
			vFlags = CStr( CInt(vFlags) )
			
			' ������ ������� ������ �����: NB - ��������� �������� ���������� 
			' "��������" �����, "����" ������� ������������ �� ����� ��������;
			' �������� 0x00 ���� Desktop (��. MSDN, ShellSpecialFolderConstants)
			With XService.CreateObject("Shell.Application")
			    Set objFolder = .BrowseForFolder( 0, "������� �����", vFlags , &h0 )
			End With
			
			If (Not objFolder Is Nothing) Then
			    ' ... ����� �������: �� ������������ ����� �������������� ��� ��������
			    ' ������������ ������� ������; ���������� ������ �������� � FolderItem:
			    sLinkValue = objFolder.Title
			    Set objFolder = objFolder.Self
			    ' ... � ���� ��� ������������� ����� - �� ���������� ������ ������:
			    If objFolder.IsFileSystem And objFolder.IsFolder Then
			    	SetLinkValues oObjectEditor, sLinkValue, objFolder.Path
			    Else
			    	MsgBox "��������� ������ """ & sLinkValue & """ �� �������� ������!", vbCritical, "������ ������� ������"
			    End If
			End If

		Case SERVICESYSTEMTYPE_DOCUMENTUMFILELINK	
			' ���� Documentum - ���������� ����������� ������ WDK:
			OpenWDKContainer "crocintglinkdocument", sLinkValue, GetMainFolder(oObjectEditor)
		
		Case SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK	
			' ����� Documentum - ���������� ����������� ������ WDK:
			OpenWDKContainer "crocintglinkfolder", sLinkValue, GetMainFolder(oObjectEditor)
			
	End Select
End Sub


'-------------------------------------------------------------------------------
':����������:	��������� �����: ���������� �������� ������������ � �������� 
'				������ � ������ ������������� ������� ������.
':���������:	oObjectEditor - �������� �������, ��������� ObjectEditorClass;
'				sName - ������ � ������������� ������;
'				sURI - ������ �� ��������� ������;
Sub SetLinkValues(oObjectEditor, sName, sURI)
	With oObjectEditor.CurrentPage
		.GetPropertyEditor(oObjectEditor.GetProp("URI")).Value = sURI
		If hasValue(sName) Then
			.GetPropertyEditor(oObjectEditor.GetProp("Name")).Value = sName
		End If
	End With
End Sub


'-------------------------------------------------------------------------------
':����������:	��������� �����: ���������� �������, ��� ������������� �������
'				������ ���� URL; ������������ �� XSL-��������, �� ������ 
'				������������ UI ���������
Function IsJustURL()
    If g_nServiceType = SERVICESYSTEMTYPE_URL Then
	    IsJustURL = true
    else
        IsJustURL = false
    End If
End Function


'-------------------------------------------------------------------------------
':����������:	����� ���������� WDK.
':���������:
'	sCommand	- ��� ���������� WDK, ������
'	sObjID		- [in] ������������� ��������� ��� ����� Documentum, ���
'				Null, ���� �������� �� ��� ������ �����; ������
'	sFolderID	- [in] ������������� �������� ����� Documentum ��� ����������,
'				��� Null, ���� �������� ����� ���������� (��������) �� ������
':����������:
'	��������! ����� ������ �������� ������ ��� ������� ������������� WDK!
Sub OpenWDKContainer( sCommand, sObjID, sFolderID )
	Dim sParams		' ������ � �����������
	Dim sDlgResult	' ��������� ������ WDK
	
	' ��������� ������ ����� ������� ������ WDK, � �����������:
	sParams = ""
	' ...���������:
	If hasValue(sObjID) Then 
		sParams = "objectId~" & sObjID
	ElseIf hasValue(sFolderID) Then 
		sParams = "folderId~" & sFolderID
	End If
	If hasValue(sParams) Then sParams = "&Params=" & sParams
	' ...������ �����, � ������������� WDK-�������
	sCommand = "it-integrate-documentum.aspx?Command=" & sCommand & sParams
	
	' ����� WDK:
	sDlgResult = X_ShowModalDialogEx(sCommand, "", "help:no;center:yes;status:no")
	If IsEmpty(sDlgResult) Then Exit Sub
	
	' ��������� ������ (���� ����) - ��� "������������,��������":
	Dim sArray
	sArray = Split(sDlgResult,",", 2)
	SetLinkValues sArray(1), sArray(0)
End Sub

'==============================================================================
' ������� ���������� �������� ����� ������� ITracker ��� Null, ���� ����� ��
' ������
' [return] As String
Function GetMainFolder( oObjectEditor )
	GetMainFolder = Null
	'� ������������ ��������� �������� ��� ������?
	Dim oXmlParentProp
	Set oXmlParentProp = oObjectEditor.ParentXmlProperty
	If oXmlParentProp Is Nothing Then Exit Function
	Dim oXmlParentObj
	Set oXmlParentObj = oXmlParentProp.parentNode
	Dim oXmlExtLink
	If oXmlParentObj.tagName = "Incident" Then
		'� ������������ ��������� ��������. ����� �������� ������, � ������� ������
		'���� ��������.
		Dim oXmlFolder
		Set oXmlFolder = oObjectEditor.Pool.GetXmlObjectByOPath(oXmlParentObj, "Folder")
		If oXmlFolder Is Nothing Then Exit Function
		'������ ����� ������, ������ �� �������� ����� � �������
		Set oXmlExtLink = oObjectEditor.Pool.GetXmlObjectByOPath(oXmlFolder, "ExternalLink")
	Else
		'� ������������ ��������� ������. ����� �������� �������� ����� �������.
		Set oXmlExtLink = oObjectEditor.Pool.GetXmlObjectByOPath(oXmlParentObj, "ExternalLink")
	End If
	If oXmlExtLink Is Nothing Then Exit Function
	GetMainFolder = oObjectEditor.Pool.GetPropertyValue(oXmlExtLink, "URI")
End Function

