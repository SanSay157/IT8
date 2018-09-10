'*******************************************************************************
' Incident Tracker 6
' ���������� ������������ ������ ������� ������ (External Link) � ���������
'*******************************************************************************
Option Explicit

Const DEF_DataSourceName = "AllExternalLinkTypes"
Const DEF_GetDataSourceError = "������ ��������� ������ ����� ������ ������������ ������� ������: "

' ������� "����� ������" ��� ������� ������
Dim g_oExternalLinkTypeDictionary	

'-------------------------------------------------------------------------------
':����������:	��������� ������� �������� "����� ������" ������� ������
':���������:	����������� �������; ���� � ������� - "f_���_�������",
'				�������� - ������������� �������� ���� ������� ������������.
'				���� � �������� �������� ��������� ������, ������� ������ Nothing
Function GetExternalLinkTypeDictionary
	Dim oResponse				' ��������� ������ �������� ������� ����������
	Dim oDoc					' XML-�������� � ������� ���������� ������ "��������� ������"
	Dim oXmlColumns				' XML-������ �������
	Dim oRow					' XML-������ ������
	Dim nObjectIdColumnIndex	' ������ ������� ObjectId
	Dim nServiceTypeColumnIndex	' ������ ������� ServiceType
	Dim sObjectId				' ������������� �������� "���� ������� ������������"
	Dim i						' �������� �����
	
	Set GetExternalLinkTypeDictionary = Nothing
	
	If IsEmpty(g_oExternalLinkTypeDictionary) Then
		' �������� �������� ���� ����� ������ ������������ ������� ������: 
		' ����� �������� ������� ��������� ������:
		On Error Resume Next
		With New XExecuteDataSourceRequest
		    .m_SName = "ExecuteDataSource"
		    .m_sDataSourceName = DEF_DataSourceName
		    Set .m_oParams = Nothing
		    Set oResponse = X_ExecuteCommand( .Self )
	    End With
		If Err Then
			If Not X_HandleError Then MsgBox DEF_GetDataSourceError & Err.Description, vbCritical
			Exit Function
		End If
		On Error GoTo 0
		
		' ������ ���������� ��������: ������� XML-������ � �������:
		Set oDoc = oResponse.m_oDataWrapped.m_oXmlDataTable
		XService.XmlSetSelectionNamespaces oDoc.ownerDocument
		Set oXmlColumns = oDoc.selectNodes("//CS/C")
		' ...������ ������� ������� ObjectId � ServiceType
		For i = 0 To oXmlColumns.length - 1
			If oXmlColumns.item(i).getAttribute("name") = "ObjectID" Then
				nObjectIdColumnIndex = i
			End If
			If oXmlColumns.item(i).getAttribute("name") = "ServiceType" Then
				nServiceTypeColumnIndex = i
			End If
		Next
		If IsEmpty(nObjectIdColumnIndex) Or IsEmpty(nServiceTypeColumnIndex) Then 
			MsgBox DEF_GetDataSourceError & "������������ ������ ������ (��� ������� ObjectID, ServiceType)", vbCritical
			Exit Function
		End If
		
		Set g_oExternalLinkTypeDictionary = CreateObject("Scripting.Dictionary")
		For Each oRow in oDoc.SelectNodes("//RS/R")
			With oRow.SelectNodes("F")
				g_oExternalLinkTypeDictionary.Item( "f" & CLng( .Item(nServiceTypeColumnIndex).text) ) = .Item(nObjectIdColumnIndex).text
			End With
		Next
	End If
	
	Set GetExternalLinkTypeDictionary = g_oExternalLinkTypeDictionary
End Function


'-------------------------------------------------------------------------------
':����������:	��������� ������� ���������� ���� ������� ������������ (�� 
'				�������, ������������ �� �������������)
':��������:		serviceType - ��� �������, ������ ���� "f_���_�������";
':���������:	���������� ������� ������� ���������� ���� ������� ������������
Function ExternalLinkTypeExists( serviceType )
	ExternalLinkTypeExists = Not IsEmpty(GetExternalLinkType(serviceType))
End Function


'-------------------------------------------------------------------------------
':����������:	���������� ������������� �������� ���� ������� ������
':���������:	serviceType - ��� ������� ������������
':����������:	���� �������� ���� ������� ������ ��� ��������� ����� ������� 
'				������������ �� ����������, ���������� Nothing.
Function GetExternalLinkType(serviceType)
	GetExternalLinkType = GetExternalLinkTypeDictionary().Item( "f" & CLng(serviceType) )
End Function


'-------------------------------------------------------------------------------
':����������:	���������� ��������� / ����������� ������������� ������� ���� 
'				������ "������� ������"
':���������:	oSender - [in] ��������� �������, XPE ������
'				oEventArgs - [in] ��������� MenuEventArgsClass
Sub usr_ExternalLinks_VisibilityHandler(oSender, oEventArgs)
	Dim bDisabled		' ������� ����������������� ������
	Dim bHidden			' ������� �������� ������
	Dim oNode			' ������� menu-item
	Dim sObjectID		' ������������� ���������� �������
	Dim bProcess		' ������� ��������� �������� ������ (Boolean)

	sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
	If 0=Len("" & sObjectID) Then
		sObjectID = Empty
	End If

	' ���������� ������ ��������� ��� ��������
	For Each oNode In oEventArgs.ActiveMenuItems
		bHidden = Empty
		bDisabled = Not IsNull(oNode.getAttribute("disabled"))

        bDisabled = false

		bProcess = False
		
		Select Case oNode.getAttribute("action")
			Case "DoCreate"
				' �������� �������� ����� ������� ������ 
				bDisabled = bDisabled Or ( _
						Not ExternalLinkTypeExists( _
							Eval( oNode.SelectSingleNode("i:params/i:param[@n='ServiceSystemType']").nodeTypedValue ) _
						) )
				bProcess = True
				
			Case "DoOpenLink", "DoCopyURI"
				' �������� �������� ������� ������, ����������� ������ � ����� ������
				bHidden = IsEmpty(sObjectID)
				bDisabled = bHidden
				bProcess = True
		End Select
		
		If bProcess Then
			If Not IsEmpty(bHidden) Then
				If bHidden Then
					oNode.setAttribute "hidden", "1"
				Else
					oNode.removeAttribute "hidden"
				End If
			End If
			If Not IsEmpty(bDisabled) Then
				If bDisabled Then
					oNode.setAttribute "disabled", "1"
				Else
					oNode.removeAttribute "disabled"
				End If
			End If
		End If
	Next
	For Each oNode In oEventArgs.ActiveMenuItems
	    If oNode.NodeName = "i:menu-section" Then
	        If Not HasValue(oNode.SelectSingleNode("descendant::i:menu-item[@required-rights]")) Then
	            With New MenuEventArgsClass
                    Set .Menu = oEventArgs.Menu
                    Set .ActiveMenuItems = oNode.SelectNodes("descendant::*[(local-name()='menu-item' and @action) or (local-name()='menu-section')]")
                    XEventEngine_FireEvent oEventArgs.Menu.EventEngine, "SetVisibility", oSender, .Self()
                End With
	        End If
	    
	        If Not HasValue(oNode.SelectSingleNode("i:menu-item[not(@disabled=1 or @hidden=1)]")) Then
	            oNode.setAttribute "hidden", "1"
	            oNode.setAttribute "disabled", "1"
	        End If
	    End If
	Next
End Sub


'-------------------------------------------------------------------------------
':����������:	���������� ������ ������������� ������� ���� ������ "������� ������"
Sub usr_ExternalLinks_ExecutionHandler(oSender, oEventArgs)
	Select Case oEventArgs.Action
		Case "DoOpenLink" 
			'������ ����� ���� "�������"
			DoOpenLink oSender.ObjectEditor, oEventArgs.Menu.Macros.Item("ObjectID"), oSender.ValueObjectTypeName
		
		Case "DoCopyURI" 
			'������ ����� ���� "�������"
			DoCopyURI oSender.ObjectEditor, oEventArgs.Menu.Macros.Item("ObjectID"), oSender.ValueObjectTypeName
	End Select
End Sub


'-------------------------------------------------------------------------------
':����������:	���������� ������� OnBeforeCreate XPE-������ ������� ������;
'				��������� � �������� ����������, ����������� � ������ ����� 
'				������� ������ ��� ������� ������.
Sub usr_ExternalLinks_ObjectsElementsList_OnBeforeCreate(oSender, oEventArgs)
	oEventArgs.UrlArguments = _
		".LinkType=" & GetExternalLinkType( Eval(oEventArgs.OperationValues.Item("ServiceSystemType")) )
End Sub


'-------------------------------------------------------------------------------
':����������:	���������� ������� OnBeforeCreate ���������� ���������� 
'				�������������; ��������� � �������� ����������, ����������� � 
'				������ ����� ������� ������ ��� ������� ������.
Sub usr_ExternalLink_ObjectPresentation_OnBeforeCreate(oSender, oEventArgs)
	Call usr_ExternalLinks_ObjectsElementsList_OnBeforeCreate( oSender, oEventArgs )
End Sub


'-------------------------------------------------------------------------------
':����������:	���������� ��� ���������� ��������� ������ �� �����.
'				������ �������� �������� ������� ������ �� ������� Documentum
Sub usr_ExternalFolderLink_OnClick
	Dim oXmlLink
	Set oXmlLink = g_oPool.GetXmlObjectByOPath( g_oObjectEditor.XmlObject, "ExternalLink" )
	OpenExternalLinkEditor g_oObjectEditor.GetProp("ExternalLink"), oXmlLink, SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK
	LinkCaption.Value = g_oPool.GetPropertyValue( g_oObjectEditor.XmlObject, "ExternalLink.Name" )
End Sub


'-------------------------------------------------------------------------------
':����������:	���������� ������ ������� ���� "�������" ������ "������� ������"
':���������:	sObjectID - ������������� ��������� ������� ������
'				sType - ��� ���� ������� ������
Sub DoOpenLink(oObjectEditor, sObjectID, sType)
	Dim oXmlExternalLink	' XML-������ �������� (As IXMLDOMElement)
	Dim URI					' �������� ������� ������ (As String)
	Dim nServiceType		' ��� ������� ������������ ������� ������
	Dim sMessage			' ����� ��������� (�� ������)
	
	' ���������� ��� ������� ������������ ��� "�����������" ������� ������:
	Set oXmlExternalLink = oObjectEditor.Pool.GetXmlObject(sType, sObjectID, Null)
	URI = oXmlExternalLink.SelectSingleNode("URI").NodeTypedValue
	nServiceType = oObjectEditor.Pool.GetPropertyValue(oXmlExternalLink,"LinkType.ServiceType")
	
	Select Case nServiceType
		' ��� ������� ������������: "������" URL
		Case SERVICESYSTEMTYPE_URL
			Dim oIE		' ��������� Internet Explorer
			
			sMessage = "������ ��� �������� ������ """ & URI & """: "
			On Error Resume Next
			Set oIE = XService.CreateObject("InternetExplorer.Application")
			oIE.Visible = True
			oIE.Navigate URI
			If Err Then
				MsgBox sMessage & Err.Description, vbCritical, "������"
				Exit Sub
			End If
			On Error Goto 0
		
		' ��� ������� ������������: ������ �� ����
		Case SERVICESYSTEMTYPE_FILELINK
			Dim oFSO	' ������ FileSystemObject
			Dim vRet	' ��������� ������� ������������� � ������������
			
			sMessage  = "������ ��� ������� �������� ������ �� ���� """ & URI & """: " 
			On Error Resume Next
			Set oFSO = XService.CreateObject("Scripting.FileSystemObject")
			If Err Then
				MsgBox sMessage & Err.Description, vbCritical, "������"
				Exit Sub
			End If
			If Not oFSO.FileExists(URI) Then 
				vRet = MsgBox( _
					"��������� ���� """ & URI & """ �� ����������." & vbNewLine & _
					"��������, � ��� ��� ���� �� �������� ����� ��� ���� ��� ������������, ��������� ��� ������." & vbNewLine & _
					"���������� ������� ����?", vbYesNo Or vbExclamation, "���� �� ����������" ) 
				If vbYes <> vRet Then Exit Sub
			End If
			On Error Resume Next
			XService.ShellExecute URI
			If 0<>Err.Number Then
				MsgBox sMessage & Err.Description, vbCritical, "������"
			End If
			On Error GoTo 0
		
		' ��� ������� ������������: ������ �� �������
		Case SERVICESYSTEMTYPE_DIRECTORYLINK
			Dim oFolder	
			
			sMessage = "������ ��� ������� �������� ������ �� ����� """ & URI & """: " 
			On Error Resume Next
			With XService.CreateObject("Shell.Application")
				Set oFolder = .NameSpace(URI)
				If Not hasValue(oFolder) Then
					MsgBox _
						"��������� ����� """ & URI & """ �� ����������." & vbNewLine & _
						"��������, � ��� ��� ���� �� �������� ����� ��� ����� ���� �������������, ���������� ��� �������.", _
						vbCritical, "������"
					Exit Sub
				End If
				' NB: oFolder.Self ���������� FolderItem, ��� �������� ��������� ������������� Verb
				oFolder.Self.InvokeVerb("explore")
			End With
			If Err Then MsgBox sMessage & Err.Description, vbCritical, "������"
			On Error Goto 0
			
		' ��� ������� ������������: ������ �� ���� � Documentum
		Case SERVICESYSTEMTYPE_DOCUMENTUMFILELINK	
			window.open XService.BaseUrl & "webtop.aspx?goto=" & XService.UrlEncode("drl/objectId/" & URI)
		
		' ��� ������� ������������: ������ �� ����� � Documentum 
		Case SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK	'
			window.open XService.BaseUrl & "webtop.aspx?goto=" & XService.UrlEncode("drl/objectId/" & URI)
			' ��� ���������� ������ WebTop-� ����� �������������� c�������� ���
			'X_ShowModalDialogEx XService.BaseUrl & "it-integrate-documentum.aspx?Command=crocintgopen&Params=objectId~" & URI & "|launchViewer~true" , "", "help:no;center:yes;status:no"
	
	End Select
End Sub


'-------------------------------------------------------------------------------
':����������:	���������� ������ ������ ���� "����������" ������ "������� ������"
':���������:	sObjectID - ������������� ��������� ������� ������
'				sType - ��� ���� ������� ������
Sub DoCopyURI( oObjectEditor, sObjectID, sType )
	Dim oXmlExternalLink	' XML-������ �������� (As IXMLDOMElement)
	Dim URI					' �������� ������� ������ (As String)
	Dim nServiceType		' ��� ������� ������������ ������� ������

	' ���������� ��� ������� ������������ ��� "�����������" ������� ������:
	Set oXmlExternalLink = oObjectEditor.Pool.GetXmlObject(sType, sObjectID, Null)
	URI = oXmlExternalLink.SelectSingleNode("URI").NodeTypedValue
	nServiceType = oObjectEditor.Pool.GetPropertyValue(oXmlExternalLink,"LinkType.ServiceType")
	
	Select Case nServiceType
		Case SERVICESYSTEMTYPE_URL
		Case SERVICESYSTEMTYPE_FILELINK
		Case SERVICESYSTEMTYPE_DIRECTORYLINK
		
		Case SERVICESYSTEMTYPE_DOCUMENTUMFILELINK	
			' ���� Documentum
			URI = XService.BaseUrl & "webtop.aspx?goto=" & XService.UrlEncode("drl/objectId/" & URI)
		
		Case SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK	
			' ����� Documentum
			URI = XService.BaseUrl & "webtop.aspx?goto=" & XService.UrlEncode("drl/objectId/" & URI)
	End Select
	
	' ���������� ������ � ����� ������:
	window.clipboardData.setData "Text", URI
End Sub
