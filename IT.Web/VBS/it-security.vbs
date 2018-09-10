Option Explicit


'==============================================================================
' visibility-handler ��� ������ � ����� ������������. ���������� ��������� ���� � ������� ������� XGetObjectsRightsEx
Public Sub XList_MenuVisibilityHandler(oSender, oEventArgs)
	Dim sGUID			' As String - ������������� ���������� �������
	Dim sType			' As String - ������������ ���� ���������� �������
	Dim bDisabled		' As Boolean - ������� ����������������� ������
	Dim bHidden			' As Boolean - ������� �������� ������
	Dim oNode			' As XMLDOMElement - ������� menu-item
	Dim oParam			' As IXMLDOMElement - ���� param � ���������� ���� 
	Dim sAction			' As String - ������������ ��������(action'a) ������ ����
	Dim bProcess		' As Boolean - ������� ��������� �������� ������
	Dim bTrustworthy	' As Boolean - ������� "�������������� �������" ���� - ��� ��� ������ �� ���� ��������� �������� ����
	Dim oRightsChecker
	Dim sURLParams
	
	sType = oSender.Menu.Macros.item("ObjectType")
	sGUID = oSender.Menu.Macros.item("ObjectID")
	bTrustworthy = Not IsNull(oSender.Menu.XmlMenu.getAttribute("trustworthy"))
	Set oRightsChecker = New SimpleRightsChecker
	' ���������� ������ ��������� ��� ��������
	For Each oNode In oSender.Menu.XmlMenu.selectNodes("i:menu-item")
		bHidden = Empty
		bDisabled = Empty
		bProcess = False
		' �� ���� ���������� ������ ����
		For Each oParam In oNode.selectNodes("*[local-name()='params']/*[local-name()='param']")
			' ���� ����� ��������� ObjectType �/��� ObjectID, �� ������������� ��� �/��� OID (��� �������� ����)
			If StrComp(oParam.getAttribute("n"), "ObjectType", vbTextCompare)=0 Then
				sType = oParam.text
			ElseIf StrComp(oParam.getAttribute("n"), "ObjectID", vbTextCompare)=0 Then
				sGUID = oParam.text
			End If
			If StrComp(oParam.getAttribute("n"), "URLParams", vbTextCompare)=0 Then
				sURLParams = oParam.text
			End If
		Next

		sAction = oNode.getAttribute("action")
		Select Case sAction
			Case CMD_ADD
				bHidden = oSender.OffCreate
				If Not bHidden And Not bTrustworthy Then _
					oRightsChecker.AddCheckForCreateObject oNode, sType, sURLParams
				bProcess = True
			Case CMD_VIEW
				bHidden = IsNull(sGUID)
				bProcess = True
			Case CMD_EDIT
				bHidden = IsNull(sGUID) Or oSender.OffEdit
				If Not bHidden And Not bTrustworthy Then _
					oRightsChecker.AddCheckForChangeObject oNode, sType, sGUID
				bProcess = True
			Case CMD_DELETE
				bHidden = IsNull(sGUID) Or oSender.OffClear
				If Not bHidden And Not bTrustworthy Then _
					oRightsChecker.AddCheckForDeleteObject oNode, sType, sGUID
				bProcess = True
			Case Else
				With New SetMenuItemVisibilityEventArgsClass
					Set .Menu = oSender.Menu
					Set .MenuItemNode = oNode
					.Action = sAction
					XEventEngine_FireEvent oSender.EventEngine, "SetMenuItemVisibility",Me, .Self
					'oSender.EventEngine.FireEvent "SetMenuItemVisibility", oSender, oEventArgs
					bHidden		= .Hidden
					bDisabled	= .Disabled
				End With
				bProcess = True
		End Select
		If bProcess Then
			If IsEmpty(bHidden) Then bHidden = False
			If IsEmpty(bDisabled) Then bDisabled = False
		End If
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
	Next
	' False - ������ �� ���������� ����������� ��������
	oRightsChecker.SetMenuItemsAccessRights oEventArgs.Menu, False
End Sub


'==============================================================================
' ���������������� ���������� ������� Create ��� ������
' ������������� �� ����������� ������ �������� ����������� �������, 
' �� ��������� ��������������� ������� ObjectRightsDescr � ���� XRightsCache()
Sub usrXList_OnCreate(oSender, oEventArgs)
	DoCreateWithAccessCheckInClientCache oEventArgs
End Sub


'==============================================================================
' ���������������� ���������� ������� Create ��� ������
' � ������� �� ���� ������ � ���� ������ ����� ����� ���� ���������� ����� �� ������� 
' � ������ �� ������ � ���� ��������� ������ ���� ObjectRights � �������
'	.deny-delete:1
'	.deny-change:1
'	.read-only-props
Sub usrXTree_OnCreate(oSender, oEventArgs)
	Dim sObjectRightsExpr 
	Dim aObjectRightsExprParts 
	Dim sExpr 
	Dim aExprParts 
	Dim aReadOnlyProps
	Dim bDenyDelete
	Dim bDenyChange
	Dim bDenyCreate
	Dim oObjectRightsDescr
	sObjectRightsExpr = oEventArgs.Values.Item("ObjectRights")
	If Len("" & sObjectRightsExpr) > 0 Then
		aObjectRightsExprParts = Split(sObjectRightsExpr, ";")
		For Each sExpr In aObjectRightsExprParts 
			If Len(sExpr) > 0 Then
				aExprParts = Split(sExpr, ":")
				If UBound(aExprParts) = 1 Then
					Select Case aExprParts(0)
						Case ".deny-delete"
							bDenyDelete = CBool(aExprParts(1) = "1")
						Case ".deny-change"
							bDenyChange = CBool(aExprParts(1) = "1")
						Case ".deny-create"
							bDenyCreate = CBool(aExprParts(1) = "1")
						Case ".read-only-props"
							aReadOnlyProps = Split(aExprParts(1), ",")
					End Select
				End If
			End If
		Next
		With New XObjectRightsDescr
		    .m_aReadOnlyProps = aReadOnlyProps
		    .m_bDenyDelete = bDenyDelete
		    .m_bDenyChange = bDenyChange
		    .m_bDenyCreate = bDenyCreate
		Set oObjectRightsDescr = .Self
	    End With
		oEventArgs.ReturnValue = OpenEditorWithApplyObjectRights(oEventArgs.ObjectType, Null, oEventArgs.Metaname, oEventArgs.Values.Item("URLParams"), oObjectRightsDescr)
	Else
		' ����������� ���� �� ����������� ������ ����������� - ���������� ���������� � ������� ���� � ���������� ����
		DoCreateWithAccessCheckInClientCache oEventArgs
	End If
End Sub


'==============================================================================
' ��������� �������� �������� ������� � �������� ���������� �������� DoCreate ������ ����.
' ���� � ���������� ���� ���� �������������� ����� �� ����������� ������, 
' ���� ������� ������������� �� xml-������ �������� ����������� �������, ����� ���������� x-utils::X_OpenObjectEditor
'	[in] oEventArgs As CommonEventArgsClass - ��������� ������� Create ������ � ������
Sub DoCreateWithAccessCheckInClientCache(oEventArgs)
	Dim sKey
	Dim oObjectRightsDescr
	Dim sUrlParams 
	
	sUrlParams = oEventArgs.Values.Item("URLParams")
	sKey = oEventArgs.ObjectType & ":" & sUrlParams
	If X_RightsCache().FindEx(sKey, oObjectRightsDescr) Then
		oEventArgs.ReturnValue = OpenEditorWithApplyObjectRights(oEventArgs.ObjectType, Null, oEventArgs.Metaname, sUrlParams, oObjectRightsDescr)
	Else
		oEventArgs.ReturnValue = X_OpenObjectEditor(oEventArgs.ObjectType, Null, oEventArgs.Metaname, sUrlParams)
	End If
End Sub


'==============================================================================
' ��������� �������� �������� xml-�������, �� ������� ��������������� �������� ����������� �������
'	[in] sObjectType - ��� �������
'	[in] sObjectID - ������������� ������� (���� Null �� ������ ��������)
'	[in] sEditorMetaname - ��� ��������� � ����������
'	[in] sUrlParams - ������ �������������� ���������� (���������� � URL)
'	[in] oObjectRightsDescr As XObjectRightsDescr
' 	[retval] - Empty ���� ������ �� ��������������� ����� ������������� �������
Function OpenEditorWithApplyObjectRights(sObjectType, sObjectID, sEditorMetaname, sUrlParams, oObjectRightsDescr)
    Dim oIncidentEditor
    Set oIncidentEditor = New ObjectEditorDialogClass
	With oIncidentEditor
		.IsNewObject = Not HasValue(sObjectID)
		.QueryString.QueryString = sUrlParams
		.IsAggregation = False
		.MetaName = sEditorMetaname
		Set .XmlObject = X_GetObjectFromServer(sObjectType, sObjectID, Null)
		ApplyObjectRightsDescrOnXmlObject oObjectRightsDescr, .XmlObject
	End With
	OpenEditorWithApplyObjectRights = ObjectEditorDialogClass_Show (oIncidentEditor)
End Function


'==============================================================================
' ������������� �������� ����������� ������� �� xml-������
'	[in] oRightDesc - �������� ���� �� ������
'	[in] oXmlObject - xml-������ � ����
Public Sub ApplyObjectRightsDescrOnXmlObject(oRightDescr, oXmlObject)
	Dim sPropName 
	If oRightDescr.m_bDenyChange Then
		oXmlObject.setAttribute "change-right", "0"
	Else
		oXmlObject.setAttribute "change-right", "1"
	End If
	If oRightDescr.m_bDenyDelete Then
		oXmlObject.setAttribute "delete-right", "0"
	Else
		oXmlObject.setAttribute "delete-right", "1"
	End If
	If Not IsNull(oRightDescr.m_aReadOnlyProps) Then
		For Each sPropName In oRightDescr.m_aReadOnlyProps
			oXmlObject.SelectSingleNode(sPropName).setAttribute "read-only", "1"
		Next
	End If
End Sub


'--------------------------------------------------------------------------
' ����������� ������� ������� ����������� �� URL
Sub ApplyURLParamsOnXmlObject(sURLParams, oXmlObject)
	Dim oTypeMD		' ���������� ����
	Dim oPropMD		' ���������� ��������
	Dim sPropName	' ������ ���� �� ��������
	Dim oXmlProp	' ��������
	Dim sObjectID	' ������������� �������
	Dim sOT			' ��� �������
	Dim aIDS		' ������ ���������������
	Dim oQS         ' As QueryString

	Set oQS = X_GetEmptyQueryString()
	oQS.QueryString = sURLParams
	Set oTypeMD = X_GetTypeMD(oXmlObject.tagName)
	' �������� ������������������� �������� ��������������� ������� ����������� �� URL
	For Each sPropName In oQS.Names
		If MID(sPropName,1,1) = "." Then
			' �������� �������� ���������� � "."
			sPropName = MID( sPropName , 2)

			Set oXmlProp =  oXmlObject.selectSingleNode(sPropName)
			' ���� �������� ���� � �������
			If Not oXmlProp Is Nothing Then
				' ������� ���������� ��������
				Set oPropMD = oTypeMD.selectSingleNode( "ds:prop[@n='" & sPropName & "']")
				Select Case oPropMD.getAttribute("vt")
					Case "i2",  "i4", "ui1"
						oXmlProp.nodeTypedValue = oQS.GetValueInt( "." & sPropName , 0)
					Case "r4", "r8", "fixed"
						oXmlProp.nodeTypedValue =  CDBl(oQS.GetValue( "." & sPropName , "0"))
					Case "date", "dateTime", "time"
						oXmlProp.nodeTypedValue = CDate(oSQ.GetValue( "." & sPropName , Now ) )
						oXmlProp.text = oXmlProp.text ' ���. 69105
					Case "string", "text"
						oXmlProp.nodeTypedValue =  oQS.GetValue( "." & sPropName , "")
					Case "object"
						If oPropMD.getAttribute("cp") = "scalar" Then
							' ��������� ��������� ��������
							sObjectID = oQS.GetValue( "." & sPropName, "")
							If Len(sObjectID) > 0 Then
								sOT = oPropMD.getAttribute("ot")
								oXmlProp.selectNodes("*").removeAll
								oXmlProp.appendChild X_CreateObjectStub(sOT, sObjectID)
								
							End If
						Else
							' ��������� ��������� ��������
	
							aIDS = Split( oQS.GetValue( "." & sPropName , ""), ";")
							sOT = oPropMD.getAttribute("ot")
							For Each sObjectID In aIDS
								If Len(sObjectID) > 0 Then
									oXmlProp.appendChild X_CreateObjectStub(sOT, sObjectID)
								End If
							Next
						End If		
					Case Else
						oXmlProp.text = oQS.GetValue( "." & sPropName , "")
				End Select
			End If
		End If
	Next
End Sub


'==============================================================================
' "������������" ���� ��� ������ � ������
Class SimpleRightsChecker
	Private m_aObjectsRights	' As XObjectRightsDescr() - ��������� ���������� �������� - ������ ���� �� �������
	Private m_oDG				' As IXMLDOMElement - xml-����������
	Private m_objectsToCheck	' As Scripting.Dictionary
	Private m_newObjectsToCache	' As Scripting.Dictionary
	

	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		With XService.XmlGetDocument
			Set m_oDG = .appendChild( .createElement("x-datagram"))
		End With
		Set m_objectsToCheck = CreateObject("Scripting.Dictionary")
	End Sub
	
	
	'--------------------------------------------------------------------------
	Public Sub AddCheckForCreateObject(oMenuItem, sType, sURLParams)
		Dim oXmlObject
		Dim sObjectID
		Dim sKey
		
		sKey = sType & ":" & sURLParams
		If IsEmpty(checkObjectRightsInCache(oMenuItem, sKey, "create")) Then
			Set oXmlObject = X_GetObjectFromServer( sType, Null, Null)
			Set oXmlObject  = m_oDG.appendChild( oXmlObject )
			ApplyURLParamsOnXmlObject sURLParams, oXmlObject
			sObjectID = oXmlObject.getAttribute("oid")
			menuItem_addObjectRightExpr oMenuItem, sType, sObjectID
			' ������� ������ � ������ �����������
			addCheckObjectRight oMenuItem, sType, sObjectID
			' ������� ������ � ������� ������ ���� ��� ����� �������� 
			' (������������� ����� �� m_objectsToCheck � �����, ��� ������� ����� ����������� ��������� �������� ����� �� �������� �������)
			If IsEmpty(m_newObjectsToCache) Then Set m_newObjectsToCache = CreateObject("Scripting.Dictionary")
			m_newObjectsToCache.Add sType & ":" & sObjectID, sKey
		End If
	End Sub
	
		
	'--------------------------------------------------------------------------
	Public Sub AddCheckForChangeObject(oMenuItem, sType, sObjectID )
		If IsEmpty(checkObjectRightsInCache(oMenuItem, sType & ":" & sObjectID, "change")) Then
			addCheckObjectRight oMenuItem, sType, sObjectID
			menuItem_addObjectRightExpr oMenuItem, sType, sObjectID
		End If
	End Sub
	
	
	'--------------------------------------------------------------------------
	Public Sub AddCheckForDeleteObject(oMenuItem, sType, sObjectID )
		If IsEmpty(checkObjectRightsInCache(oMenuItem, sType & ":" & sObjectID, "delete")) Then
			addCheckObjectRight oMenuItem, sType, sObjectID
			menuItem_addObjectRightExpr oMenuItem, sType, sObjectID
		End If
	End Sub
	
	
	'--------------------------------------------------------------------------
	Private Function checkObjectRightsInCache(oMenuItem, sKey, sAction)
		Dim bAllow
		Dim oObjectRightsDescr
		
		' ������ ����� ���� ���������, ������ � ���� ����
		If X_RightsCache().FindEx(sKey, oObjectRightsDescr) Then
			' ����� �������������� ��������
			If sAction = "create" Then
				bAllow = Not oObjectRightsDescr.m_bDenyCreate
			ElseIf sAction = "change" Then
				bAllow = Not oObjectRightsDescr.m_bDenyChange
			ElseIf sAction = "delete" Then
				bAllow = Not oObjectRightsDescr.m_bDenyDelete
			End If
			oMenuItem.setAttribute "allow", iif(bAllow, "1", "0")
			checkObjectRightsInCache = True
		End If
	End Function

	
	'--------------------------------------------------------------------------
	' ��������� � ������ �� �������� ���� ��� ��������� ��������� ������
	Private Sub addCheckObjectRight(oMenuItem, sType, sObjectID)
		Dim sKey
		sKey = getKey(oMenuItem, sType, sObjectID) 
		If Not m_objectsToCheck.Exists(sKey) Then
		    With New XObjectIdentity
		        .m_sObjectType = sType
	            .m_sObjectID = sObjectID
	            .m_vTS = -1
			m_objectsToCheck.Add sKey, .Self
			End With
		End If
	End Sub
	
	'--------------------------------------------------------------------------
	Private Function getKey(oMenuItem, sType, sObjectID)
		Dim oUrlParamNode	' As IXMLDOMElement - �������� URLParams ��� menu-item
		Dim sKey
		
		sKey = sType & ":" & sObjectID
		' ���� ��� menu-item ����� �������� URLParams, ������� ��� �������� � �����
		Set oUrlParamNode = oMenuItem.selectSingleNode("i:params/i:param[@n='URLParams']")
		If Not oUrlParamNode Is Nothing Then
			sKey = sKey & "?" & oUrlParamNode.text
		End If
		
		getKey = skey
	End Function
	
	
	'--------------------------------------------------------------------------
	Private Sub menuItem_addObjectRightExpr(oMenuItem, sType, sObjectID)
		oMenuItem.setAttribute "type", sType
		oMenuItem.setAttribute "oid", sObjectID
	End Sub
	
	'--------------------------------------------------------------------------
	Public Function ExecuteRightsRequest()
		Dim oResponse		' As GetObjectsRightsExResponse
		Dim ObjectsRights	' As Scripting.Dictionary - ������� ������������ ������������� ������� � ���� �� ������, ���������� � �������
		Dim sKey			' As String - ���� � �������
		Dim i
		Dim aErr			' ������ � �������� ������ (Err.Number, Err.Source, Err.Description)
		Dim oRightDescr		' As XObjectRightsDescr - �������� ���� �� ������
		Dim oObjectID		' As XObjectIdentity - ������������� �������
		Dim oXmlObject		' As IXMLDOMElement - xml-������
		Dim sPropName		' As String - ������������ ��������
		
		' ���� ���� �������, ��� ����� ���� ��������� � ������� (� �.�. ��������� ����� �� �������� �����)
		If m_objectsToCheck.Count = 0 Then 
			Set ExecuteRightsRequest = Nothing
			Exit Function
		End If
		
		On Error Resume Next
		  With New CheckDatagramRequest
		    .m_sName = "GetObjectsRightsEx"
		    Set .m_oXmlDatagram = m_oDG
		    .m_aObjectsToCheck = m_objectsToCheck.Items()
		    Set oResponse = X_ExecuteCommand( .Self )
		  End With
		If Err Then
			If Not X_HandleError Then
				' ������ �� �������
				aErr = Array(Err.Number, Err.Source, Err.Description)
				On Error Goto 0
				Err.Raise aErr(0), aErr(1), aErr(2)
			End If
		End If
		On Error Goto 0
		' �������� ������� � ������� �� ����� �������� ���������� � ������� ������� XObjectRightsDescr 
		' ��� ���� �� �������, ����� ���� � m_objectsToCheck
		Set ObjectsRights = CreateObject("Scripting.Dictionary")
		' �� ������� ������� �� ���, ��� �� �������� �� ������ ��� �������� ���� (� �.�. �����)...
		For i = 0 To m_objectsToCheck.Count-1
			sKey = m_objectsToCheck.Keys()(i)
			Set oRightDescr = oResponse.m_aObjectsRights(i)
			ObjectsRights.Add sKey, oRightDescr 
			' ���� �������� ���������� ��������� �������� �������� ������ ������� (� XRightsCache)
			If Not IsEmpty(m_newObjectsToCache) Then
				' ���� ������� ������ ����� � ��������� �������� ���� ����� ���� �����������..
				If m_newObjectsToCache.Exists(sKey) Then
					' � �������� �������� � ������� m_newObjectsToCache ����� ���� ��� ������� �������� ���������� ������ XObjectRightsDescr
					X_RightsCache().SetValueEx m_newObjectsToCache.Item(sKey), oRightDescr
				End If
			End If
			X_RightsCache().SetValueEx sKey, oRightDescr
		Next
		Set ExecuteRightsRequest = ObjectsRights
	End Function
	
	
	'--------------------------------------------------------------------------
	Public Sub SetMenuItemsAccessRights(oMenu, bShowDeniedAsDisabled)
		Dim ObjectsRights 	' As Scripting.Dictionary  - ������� �������� XObjectRightsDescr ��� ������� ������ �� ��� � m_objectsToCheck
		Dim sAttrName		' As String - ������������ ��������
		Dim oNode			' As IXMLDOMElement - ������� menu-item
		Dim oUrlParamNode	' As IXMLDOMElement - �������� URLParams �������� menu-item
		Dim sAllowAttr		' As String - ������������ ��������, ������������� ��� ������� �������� (hidden ��� disabled)
		Dim oRightDescr
		Dim sKey
		Dim sActionAttr
		Dim sRequiredRights	' As String - �������� �������� required-rights - �������� �������� �������� ������ ����
		Dim sNewObjectID
		Dim sNewObjectType	
		
		Set ObjectsRights = ExecuteRightsRequest()
		' ��������� ����� ��������� �� ����� �������� ����������� ��������
		If bShowDeniedAsDisabled Then
			sAttrName = "disabled"
		Else
			sAttrName = "hidden"
		End If
		' ������ �� ���� ������� ���� � ��������� �� ����������� �� ��������� ���������� ���� �� �������
		' ��� ����, ����� (��� ���) ����� ����� ���� ��� �������. � ���� ������ ����������� ������ ���� ��� ����������� � ������� �������� allow
		For Each oNode In oMenu.XmlMenu.selectNodes("i:menu-item")
			sAllowAttr = oNode.getAttribute("allow")
			If IsNull(sAllowAttr) Then
				' ���������� - ����� �� ������� ����� ���� ����������� �� ��������� ���� �� ������� (������� �� ��� ��������)
				' ������� �� ��������� ������ ���� ����� � ������� m_objectsToCheck, ����������� ������� �� ������� ������� ����� �� ��������
				sKey = getKey(oNode, oNode.getAttribute("type"), oNode.getAttribute("oid")) 
				If Not ObjectsRights Is Nothing Then
					If ObjectsRights.Exists(sKey) Then
						Set oRightDescr = ObjectsRights.item(sKey)
						sActionAttr = oNode.getAttribute("action")
						If sActionAttr = CMD_ADD Then
							sAllowAttr = iif(oRightDescr.m_bDenyCreate, "0", "1")
						ElseIf sActionAttr = CMD_EDIT Then
							sAllowAttr = iif(oRightDescr.m_bDenyChange, "0", "1")
						ElseIf sActionAttr = CMD_DELETE Then
							sAllowAttr = iif(oRightDescr.m_bDenyDelete, "0", "1")
						End If
					End If
				End If
			End If
			If Not IsNull(sAllowAttr) Then
				' ����������� �������� ��� ����������� - �������� �������
				sAllowAttr = CBool(sAllowAttr)
				If sAllowAttr Then
					oNode.removeAttribute sAttrName
				Else
					oNode.setAttribute sAttrName, "1"
				End If
				oNode.removeAttribute "allow"
			End If		
		Next
	End Sub
End Class


