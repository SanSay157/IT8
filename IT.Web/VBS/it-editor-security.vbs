Option Explicit

'==============================================================================
' ���������� ��������� ������� ���� ��� x-pe-objects::XPEObjectsElementsListClass
' ������� �� ����������� XPEObjectsElementsListClass::Internal_MenuVisibilityHandler, ����������� ������:
' 	��� �������� DoCreate ������������ �������� ���� � ������� ���������� ������� (� �� GetObjectsRight), 
'	������� ���������� ���������� ���������� �������� ������������ ������� � ��� ����� �������, ������� �� �����,
'	��������� � ��������� permission-check-preload ������ ����, �.�. ������� ������� ��������� ����������� ������ � 
'	�������, �� ������� ������� ����� �� ����������� ������.
'	[in] oSender As XPEObjectsElementsListClass - ���������-�������� ���� (PE)
'	[in] oEventArgs As MenuEventArgsClass 		- ��������� �������
Sub XPEObjectsElementsListClass_MenuVisibilityHandler(oSender, oEventArgs)
	Dim oXmlProperty	' xml-��������
	Dim bDisabled		' ������� ����������������� ������
	Dim bHidden			' ������� �������� ������
	Dim oNode			' ������� menu-item
	Dim sType			' ��� ������� � ��������
	Dim sObjectID		' ������������� ���������� �������
	Dim oObjectValue	' As IXMLDOMElement - xml-������ ��������
	Dim bIsLoaded		' As Boolean - ������� ����,��� ������-�������� �������� �� ��
	Dim bProcess		' As Boolean - ������� ��������� �������� ������
	Dim oRightsChecker	' As RightsChecker
	Dim oParam			' xml-���� i:param
	Dim sURLParams		' �������� ��������� URLParams ������ ����

	Set oXmlProperty = oSender.XmlProperty		
	' ������� ��� � ������������� ���������� �������, ��� �������� ��������� ����
	sType = oEventArgs.Menu.Macros.Item("ObjectType")
	sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
	If 0=Len("" & sObjectID) Then sObjectID = Null
	
	' ���� � ������ ������ ������ (���� ����� ������� � ��� ��������� ������ ������), �� ������� ������ �� ���� � ����,
	' � ����� ��������� ���� ��� �� �� �������� �� ��
	If Not IsNull(sObjectID) Then
		Set oObjectValue = oSender.ObjectEditor.Pool.GetXmlObject(sType, sObjectID, Null)
		If Not oObjectValue Is Nothing Then
			bIsLoaded = IsNull(oObjectValue.getAttribute("new"))
		End If
	End If	
	
	Set oRightsChecker = New RightsChecker
	oRightsChecker.Initialize oSender.ObjectEditor
	For Each oNode In oEventArgs.ActiveMenuItems
		bHidden = Empty
		bDisabled = Empty
		bProcess = False
		' ���������� ������ ��������� ��� ��������
		Select Case oNode.getAttribute("action")
			Case "DoSelectFromDb"
				bHidden = HasValue(oSender.HtmlElement.getAttribute("OFF_SELECT"))
				If Not bHidden Then
					oRightsChecker.AddCheckForChangeProp oNode, oXmlProperty
				End If
				bProcess = True
			Case "DoCreate"
				bHidden = HasValue(oSender.HtmlElement.getAttribute("OFF_CREATE"))
				If Not bHidden Then
					' �� ���� ���������� ������ ����
					For Each oParam In oNode.selectNodes("*[local-name()='params']/*[local-name()='param']")
						If StrComp(oParam.getAttribute("n"), "URLParams", vbTextCompare)=0 Then
							sURLParams = oParam.text
						End If
					Next
					oRightsChecker.AddCheckForCreateObjectInPropEx oNode, oXmlProperty, sType, oEventArgs.Menu.Macros.Item("permission-check-preload"), sURLParams
				End If
				bProcess = True
			Case "DoEdit"
				bHidden = IsNull(sObjectID) Or HasValue(oSender.HtmlElement.getAttribute("OFF_EDIT"))
				If Not bHidden And bIsLoaded Then _
					oRightsChecker.AddCheckForChangeObject oNode, sType, sObjectID
				bProcess = True
			Case "DoMarkDelete"
				bHidden = IsNull(sObjectID) Or HasValue(oSender.HtmlElement.getAttribute("OFF_DELETE"))
				If Not bHidden And bIsLoaded Then _
					oRightsChecker.AddCheckForDeleteObjectFromProp oNode, oXmlProperty, sType, sObjectID
				bProcess = True
			Case "DoUnlink"
				' ���� ���� � �������� ��������� ��������� �������� (�� �������� ������� �������� � ������)
				' �������������, �� �������� "��������� �����" ������ ���� ������������ ������
				If oSender.m_oPropertyEditorBase.PropertyMD.getAttribute("cp") = "link" Then
					If IsNull(oSender.ObjectEditor.Pool.GetReversePropertyMD(oXmlProperty).getAttribute("maybenull")) Then
						bHidden = True
					End If
				End If
				If bHidden = False Then
					bHidden = IsNull(sObjectID) Or HasValue(oSender.HtmlElement.getAttribute("OFF_UNLINK"))
					' TODO: ��� "�����������" ���� ���� ��������� �����
				End If
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
	oRightsChecker.SetMenuItemsAccessRights oEventArgs.Menu, True
End Sub


'==============================================================================
' ���������� ��������� ������� ���� ��� x-pe-object::XPEObjectPresentationClass
' ��. ����������� � XPEObjectsElementsListClass_MenuVisibilityHandler
'	[in] oEventArgs As MenuEventArgsClass
Sub XPEObjectPresentationClass_MenuVisibilityHandler(oSender, oEventArgs)
	Dim bDisabled		' ������� ����������������� ������
	Dim bHidden			' ������� �������� ������
	Dim oNode			' ������� menu-item
	Dim sType			' ��� ������� � ��������
	Dim sObjectID		' ������������� �������-��������
	Dim oXmlProperty	' xml-��������
	Dim oObjectValue	' As IXMLDOMElement - xml-������ ��������
	Dim bIsLoaded		' As Boolean - ������� ����,��� ������-�������� �������� �� ��
	Dim bProcess		' As Boolean - ������� ��������� �������� ������
	Dim oRightsChecker	' As RightsChecker
	Dim oParam			' xml-���� i:param
	Dim sURLParams		' �������� ��������� URLParams ������ ����

	Set oXmlProperty = oSender.XmlProperty		
	' ������� ��� � ������������� �������-��������
	sType = oEventArgs.Menu.Macros.Item("ObjectType")
	sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
	If 0=Len("" & sObjectID) Then sObjectID = Null
	
	' ���� � �������� ���� ������-�������� , �� ������� ������ �� ���� � ����,
	' � ����� ��������� ���� ��� �� �� �������� �� ��
	If Not IsNull(sObjectID) Then
		Set oObjectValue = oSender.ObjectEditor.Pool.GetXmlObject(sType, sObjectID, Null)
		If Not oObjectValue Is Nothing Then
			bIsLoaded = IsNull(oObjectValue.getAttribute("new"))
		End If
	End If	

	Set oRightsChecker = New RightsChecker
	oRightsChecker.Initialize oSender.ObjectEditor
	For Each oNode In oEventArgs.ActiveMenuItems
			
		bHidden = Empty
		bDisabled = Empty
		bProcess = False
		
		' ���������� ������ ��������� ��� ��������
		' ��������: ���������� select'a copy-paste �� x-pe-object.vbs, ����� �������� DoCreate
		Select Case oNode.getAttribute("action")
			Case "DoSelectFromDb"
				bHidden = Len( oSender.HtmlElement.getAttribute("OFF_SELECT") )>0
				If Not bHidden Then
					oRightsChecker.AddCheckForChangeProp oNode, oXmlProperty
				End If
				bProcess = True
			Case "DoCreate"
				bHidden = Len( oSender.HtmlElement.getAttribute("OFF_CREATE") )>0
				If Not bHidden Then
					' �� ���� ���������� ������ ����
					For Each oParam In oNode.selectNodes("*[local-name()='params']/*[local-name()='param']")
						If StrComp(oParam.getAttribute("n"), "URLParams", vbTextCompare)=0 Then
							sURLParams = oParam.text
						End If
					Next
					oRightsChecker.AddCheckForCreateObjectInPropEx oNode, oXmlProperty, sType, oEventArgs.Menu.Macros.Item("permission-check-preload"), sURLParams
				End If
				bProcess = True
			Case "DoEdit"
				bHidden = IsNull(sObjectID) Or Len( oSender.HtmlElement.getAttribute("OFF_EDIT") )>0
				If Not bHidden And bIsLoaded Then _
					oRightsChecker.AddCheckForChangeObject oNode, sType, sObjectID
				bProcess = True
			Case "DoMarkDelete"
				bHidden = IsNull(sObjectID) Or Len( oSender.HtmlElement.getAttribute("OFF_DELETE") )>0
				If Not bHidden And bIsLoaded Then _
					oRightsChecker.AddCheckForDeleteObjectFromProp oNode, oXmlProperty, sType, sObjectID
				bProcess = True
			Case "DoUnlink"
				bHidden = IsNull(sObjectID) Or Len( oSender.HtmlElement.getAttribute("OFF_UNLINK") )>0
				If Not bHidden Then
					bDisabled = oSender.Mandatory
					' TODO: ��� "�����������" ���� ���� ��������� �����
				End If
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
	oRightsChecker.SetMenuItemsAccessRights oEventArgs.Menu, True
End Sub


'==============================================================================
' ������� ������ � ���� �� ������� �� ��������. 
' ���������� ����������� �������, �������� �� ��������, � ������ � ���� ���� XRightsCache
Public Function CreateXmlObjectInProp(oPool, sType, oXmlProperty)
	Dim oNewObject
	Dim sKey
	Dim oObjectRightsDescr
	' �������� ������ � ����
	Set oNewObject = oPool.CreateXmlObjectInPool(sType)
	Set CreateXmlObjectInProp = oNewObject 
	' ������� �� ��������� ������ ������ � ��������
	oPool.AddRelation Nothing, oXmlProperty , oNewObject
	sKey = oXmlProperty.getAttribute("create-right-cache-key")
	If Not IsNull(sKey) Then
		If X_RightsCache().FindEx(sKey, oObjectRightsDescr) Then
			' ����� �������������� ����� �� �������� ������� � ������ ��������
			' (��. it-security.vbs)
			ApplyObjectRightsDescrOnXmlObject oObjectRightsDescr, oNewObject
		End If
	End If
End Function


'==============================================================================
' ���������������� ���������� �������� "�������" � elements-list (x-pe-objects)
' ������� ���� ����, ����� �� ����������� ������ �������� �������� ����������� �������,
' ������� ���������� �� �������������� ����. ����� - ��� ������ ObjectRightsDescr,
' ���������� �� ���� ���� XRightsCache() �� �����, �������� �������� �������� � �������� "create-right-cache-key" xml-��������.
' ������� ��������� � RightsChecker::AddCheckForCreateObjectInPropEx
Sub usr_ObjectsElementsList_OnCreate(oSender, oEventArgs)
	Dim oXmlProperty		' xml-��������
	Dim oNewObject			' ����� ������-��������
	Dim oNewObjectInProp	' �������� �������-�������� � ��������
	Dim bAggregated         ' ������� �����������

	With oEventArgs
		' ������ �������������� ����������
		oSender.ObjectEditor.Pool.BeginTransaction True
		' �����: ������ oXmlProperty �������� ����� ������ BeginTransaction, ������� �� ����� ������������ � ����� CommitTransaction
		Set oXmlProperty = oSender.XmlProperty
		' ������� ����� ������, �������� ��� � ���, ������� �� ���� ������ �� �������� � �������, ��������� �������� ����������� �������
		Set oNewObject = CreateXmlObjectInProp(oSender.ObjectEditor.Pool, oSender.ValueObjectTypeName, oXmlProperty)
		' ������� ��������� �������� � ��������� EnlistInCurrentTransaction=True, �.�. ���� �������� �� ����� ��������� ����� ����������
		.ReturnValue  = oSender.ObjectEditor.OpenEditor(oNewObject, Null, Null, .Metaname, True, oXmlProperty, Not .IsSeparateTransaction, True, .UrlArguments)
		If IsEmpty( .ReturnValue  ) Then
			' ������ ������ - ������� ����������
			oSender.ObjectEditor.Pool.RollbackTransaction
		Else
		    ' ������� ������ �� ��������� ������ � ��������
			' ������ �� - ���������
			If oSender.IsOrdered Then
				' ���� �������� ����������� - ������� ���������� � �������� � ������ ����������
				' �.�. �� �������� ������� ���������� ����� ���������� �� ��������� ���������, 
                ' ���������� ������������ ������ �� �������� � ��������
				Set oXmlProperty = oSender.XmlProperty
				Set oNewObjectInProp = oXmlProperty.selectSingleNode(oNewObject.tagName & "[@oid='" & oNewObject.getAttribute("oid") & "']")
				oSender.OrderObjectInProp oNewObjectInProp
			End If
			oSender.ObjectEditor.Pool.CommitTransaction
	    	' ������� ������������� PE
			oSender.SetData
		End If		
	End With
End Sub


const CHECKRIGHTS_ALLOW		= 1
const CHECKRIGHTS_DENY		= 0
const CHECKRIGHTS_UNKNOWN	= -1


'==============================================================================
Class RightsChecker
	Private m_bInitialized		' As Boolean - ������� ��������������������
	Private m_aObjectsRights	' As XObjectRightsDescr() - ��������� ���������� �������� - ������ ���� �� �������
	Private m_oDG				' As IXMLDOMElement - xml-����������
	Private m_objectsToCheck	' As Scripting.Dictionary
	Private m_newObjectsToCache	' As Scripting.Dictionary
	Private m_oPool
	

	Private Sub Class_Initialize
		m_bInitialized = False
	End Sub
	
	'--------------------------------------------------------------------------
	Public Sub Initialize(oObjectEditor)
		Set m_oPool = oObjectEditor.Pool
		' �������� ��������� xml-���������� ��� �������� ���� �� �������� �������
		Set m_oDG = oObjectEditor.CreateXmlDatagramRoot
		Set m_objectsToCheck = CreateObject("Scripting.Dictionary")
		m_bInitialized = True
	End Sub
	
	
	'--------------------------------------------------------------------------
	Public Sub Initialize2(oPool)
		Set m_oPool = oPool
		With XService.XmlGetDocument
			Set m_oDG = .appendChild( .createElement("x-datagram"))
		End With
		Set m_objectsToCheck = CreateObject("Scripting.Dictionary")
		m_bInitialized = True
	End Sub
	
	
	'--------------------------------------------------------------------------
	Private Function getKey(oMenuItem, sType, sObjectID)
		Dim oUrlParamNode	' As IXMLDOMElement - �������� URLParams ��� menu-item
		Dim sKey
		
		sKey = sType & ":" & sObjectID
		
		If Not oMenuItem Is Nothing Then
			' ���� ��� menu-item ����� �������� URLParams, ������� ��� �������� � �����
			Set oUrlParamNode = oMenuItem.selectSingleNode("i:params/i:param[@n='URLParams']")
			If Not oUrlParamNode Is Nothing Then
				sKey = sKey & "?" & oUrlParamNode.text
			End If
		End If
		getKey = skey
	End Function
	

	' #region �������� �� �������� �������
	'--------------------------------------------------------------------------
	'	[in] oMenuItem As IXMLDOMElement - ������ i:menu-item ��� Nothing
	'	[in] oXmlProperty As IXMLDOMElement - xml-���� ����
	'	[in] sType - ��� ������������ �������
	'	[in] sCheckPreloads - ������ ������� �������, �� ������� ����������� ��� ������� � ���������� ��� �������� ����
	Public Sub AddCheckForCreateObjectInProp(oMenuItem, oXmlProperty, sType, sCheckPreloads)
		AddCheckForCreateObjectInPropEx oMenuItem, oXmlProperty, sType, sCheckPreloads, ""
	End Sub


	'--------------------------------------------------------------------------
	'	[in] oMenuItem As IXMLDOMElement - ������ i:menu-item ��� Nothing
	'	[in] oXmlProperty As IXMLDOMElement - xml-���� ����
	'	[in] sType - ��� ������������ �������
	'	[in] sCheckPreloads - ������ ������� �������, �� ������� ����������� ��� ������� � ���������� ��� �������� ����
	'	[in] sUrlParams - ���������, ���������������� ������������ ������ (� ������� ".{���_��������}={��������}")
	Public Sub AddCheckForCreateObjectInPropEx(oMenuItem, oXmlProperty, sType, sCheckPreloads, sUrlParams)
		Dim nAllowProp 			' ������� ����������� ��������� �������� (���� �������� � �������� - ��� � �.�. ��������� ���)
		Dim sCheckObjectID		' ������������� ������ �������, �� �������� �������� ����������� �����
		Dim sCacheKey			' ����, ��� ������� ���� ������ ������ � ���������� ����
		Dim bCacheable			' ������� ����, ��� ��������� �������� ���� ����� ���� �����������
		Dim oObjectRightsDescr	' ������-��������� ���� �� ����������� ������
		Dim bTrackMenuItem		' ������� ����, ��� ����� ������� ���� oMenuItem
		Dim oXmlObject			'
		Dim oXObjectIdentity
		bTrackMenuItem = Not oMenuItem Is Nothing
		nAllowProp = CHECKRIGHTS_ALLOW
		If Not oXmlProperty Is Nothing Then
			nAllowProp = checkPropChangeRight( oXmlProperty )
		End If
		If bTrackMenuItem Then
			If nAllowProp = CHECKRIGHTS_DENY Then
				oMenuItem.setAttribute "allow", "0"	
				Exit Sub
			ElseIf nAllowProp = CHECKRIGHTS_UNKNOWN Then
				' ������� ��������� �������� ����� �� �������� �� ��������� ������� ����� �� ��������� ��������� ��������
				menuItem_addChangePropRightExpr oMenuItem, oXmlProperty
			End If
		End If
		sCheckObjectID = CreateGUID()
		' ������� ����� ���� ����������� ��������� - ��������������� ������ �������, 
		' ����� � ���������� ����������� ���������� ����� �� �������� � ����� ����
		If bTrackMenuItem Then
			oMenuItem.setAttribute "create-oid", sCheckObjectID
			oMenuItem.setAttribute "create-type", sType
		End If
		If Not oXmlProperty Is Nothing Then 
			oXmlProperty.setAttribute "create-right-cache-key", sType & ":" & sCheckObjectID
			' ���� ��������, ��� �������� ������� � �������� ���������, �� ����� ���� �� ����� (���� ����� ���� �����, �� �� �� ����� ������)..
			If nAllowProp = CHECKRIGHTS_DENY Then
				' ...�� �������� � ���� ���� ������ ����������� ���������� ���� �� �������� 
				' � �������� ��� ��� ������, �������� �������� ����� ��������� � �������� "create-right-cache-key" ��������
				X_RightsCache().SetValueEx sType & ":" & sCheckObjectID, New_XObjectRightsDescr(Null,True,True,True)
				Exit Sub
			End If
		End If
		' �������� ���������� ������������ ��������� ��� �������� ���� �� ��������. 
		' ������� ����, �� ������� ����� ������������ (� �������� ��� �����������) ��������� �������� ���� (������ XObjectRightsDescr)
		sCacheKey = buildDatagramForCheckCreatePermission( oXmlProperty, sType, sCheckObjectID, sCheckPreloads, sUrlParams, oMenuItem )
		If Len("" & sCacheKey) > 0 Then bCacheable = True
		If bCacheable Then 
			If hasValue(sUrlParams) Then 
				sCacheKey = sCacheKey & ":" & sUrlParams
			End If
			' ������ ����� ���� ���������, ������ � ���� ����
			If X_RightsCache().FindEx(sCacheKey, oObjectRightsDescr) Then
				' ����� �������������� ��������
				If bTrackMenuItem Then
					If oObjectRightsDescr.m_bDenyCreate Then
						oMenuItem.setAttribute "allow", "0"	
					Else
						oMenuItem.setAttribute "allow", "1"	
					End If
				End If
				X_RightsCache().SetValueEx getKey(oMenuItem, sType, sCheckObjectID), oObjectRightsDescr
				Exit Sub
			End If
			' �������������� �������� �� �����, �� ����������� �������� - �������� ������������ oid � ����� ����
			If IsEmpty(m_newObjectsToCache) Then Set m_newObjectsToCache = CreateObject("Scripting.Dictionary")
			m_newObjectsToCache.Add getKey(oMenuItem, sType, sCheckObjectID), sCacheKey
		End If
		' ������� ������ � ������ �����������
		Set oXObjectIdentity = New XObjectIdentity
	        oXObjectIdentity.m_sObjectType = sType
	        oXObjectIdentity.m_sObjectID = sCheckObjectID
	        oXObjectIdentity.m_vTS = -1
		m_objectsToCheck.Add sType & ":" & sCheckObjectID, oXObjectIdentity
		
		If bTrackMenuItem Then
			' ������� ��������� �������� ����� �� �������� �� ��������� ������� ����� �� �������� create ��� ������� ��������
			menuItem_addObjectRightExpr oMenuItem, sType, sCheckObjectID, "create"
		End If
	End Sub
	
	'--------------------------------------------------------------------------
	' ������� ������ � ����������, ���� ��� ���
	Private Function createXmlObjectInDatagram(oMasterObject, bDeepClone)
		Dim oXmlObject
		Set oXmlObject = m_oDG.SelectSingleNode(oMasterObject.tagName & "[@oid='" & oMasterObject.getAttribute("oid") & "']")
		If oXmlObject  Is Nothing Then
			Set oXmlObject  = m_oDG.appendChild( oMasterObject.cloneNode(bDeepClone) )
		End If
		Set createXmlObjectInDatagram = oXmlObject 
	End Function
	
	
	'--------------------------------------------------------------------------
	' ������� �������� ������� � ����������, ���� ��� ���
	Private Function createXmlPropInDatagram(oMasterObjectDG, sProp, sVarType)
		Dim oXmlProp
		Set oXmlProp = oMasterObjectDG.SelectSingleNode(sProp)
		If oXmlProp Is Nothing Then
			Set oXmlProp = oMasterObjectDG.appendChild( m_oDG.ownerDocument.createElement(sProp) )
			If hasValue(sVarType) Then
				If sVarType <> "object" Then
					oXmlProp.dataType =X_ConvertVarTypeToXmlNodeType(sVarType)
				End If
			End If
		End If
		Set createXmlPropInDatagram = oXmlProp
	End Function
	
	
	'--------------------------------------------------------------------------
	' ������� � �������� ������ �� ������ � ��� ������ � ����������
	Private Function createXmlPropObjectValue(oPropDG, sType, sCheckObjectID)
		Dim oObjectValueRef
		Dim oObjectValue
		
		' ������� � �������� �������� ������������ �������-��������
		Set oObjectValueRef = oPropDG.appendChild( X_CreateObjectStub(sType, sCheckObjectID) )
		' � ����������� ���������� ������� ����������� ������, �� ������� ������ ��� ���������� ������ � ��������
		' ��� ����������, �.�. � �������� � ��� ������ �������� � XStorage �� ������ ������, ��� ��� �� ������, � ������, 
		' ������� ������� ��� �� �������� ������ ����������
		Set oObjectValue = m_oDG.selectSingleNode(sType & "[@oid='" & sCheckObjectID & "']")
		If oObjectValue Is Nothing Then
			Set oObjectValue = m_oDG.appendChild( oObjectValueRef.cloneNode(true) )
			'oObjectValue.setAttribute "oid", sCheckObjectID
			oObjectValue.setAttribute "new", "1"
		End If
		Set createXmlPropObjectValue = oObjectValue 
	End Function


	'--------------------------------------------------------------------------
	' ��������� ���������� ��������� ��� �������� ���� �� �������� ������� sType, sCheckObjectID
	'	[in] oXmlProperty
	'	[in] sType
	'	[in] sCheckObjectID
	'	[in] sPreloads
	'	[in] sUrlParams - ���������, ���������������� ������������ ������ (� ������� ".{���_��������}={��������}")
	'	[in] oMenuItem
	'	[retval] sCacheKey - ���� � ���� ����, ���� ����������� ��������
	Private Function buildDatagramForCheckCreatePermission(oXmlProperty, sType, sCheckObjectID, sPreloads, sUrlParams, oMenuItem)
		Dim oPool			' ���
		Dim aPreloads		' ������ ���������
		Dim sPreload		' ���� ������� �������� (��������1.��������2)
		Dim aProperties		' ������ ������� ����� ������� ��������
		Dim oDG				' xml-���� x-datagram - ����������
		Dim oMasterObject	' xml-������, � �������� ��������
		Dim oMasterObjectDG	' ����������� oMasterObject � ����������
		Dim oPropDG			' �������� � ����������
		Dim oObjectValue	' ������ ��������
		Dim oReversePropMD	' ���������� ��������� �������� �������-��������
		Dim nIndex
		Dim vValue
		Dim sCacheKey
		Dim bCacheable		' ������� ����������� �����������
		Dim sCacheKeyTemp	' ��� ������������ ����� ����
				
		Set oPool = m_oPool
		' ������� ������ �� ������-�������� �������� ��������
		Set oMasterObject = oXmlProperty.parentNode
		' ������� � ���������� �������� �������-��������� �������� ��������
		Set oMasterObjectDG = createXmlObjectInDatagram(oMasterObject, not IsNull(oMasterObject.getAttribute("new")) )
		' ������� � �������� ������� ��������� ������� ��������
		Set oPropDG = createXmlPropInDatagram(oMasterObjectDG, oXmlProperty.tagName, "object")
		' ������� ������ �� ������ sType, sCheckObjectID
		Set oObjectValue = createXmlPropObjectValue(oPropDG, sType, sCheckObjectID)

		' �������������� �������� ������ ������������ �������, ���� ��� ������		
		If hasValue(sUrlParams) Then 
			applyURLParams oObjectValue, sUrlParams 
		End If

		bCacheable = True
		sCacheKeyTemp = getKey(oMenuItem, sType, sCheckObjectID)
		aPreloads = Split(sPreloads, ";")
		For Each sPreload In aPreloads
			aProperties = Split(sPreload, ".")
			If UBound(aProperties) >= 0 Then
				' ��������� ��� ����� ����� ������� (� �� ���������� ������ ���������) �� ���� ������� � aProperties
				nIndex = preloadObjectInDatagram( oMasterObject, oMasterObjectDG, oPool, aProperties, 0 )
				If nIndex > UBound(aProperties) Then
					' ����� �� ����� �������a - ����� ������������ ���� ����
					If bCacheable Then
					    '����� 9 ��������� �������� ������ - ������� �������(��������) � ��������� �� ��������� ".ObjectID"
						If Right(sPreload,  9) <> ".ObjectID" Then sPreload = sPreload & ".ObjectID" 
						vValue = oPool.GetPropertyValue(oMasterObject, sPreload)
						If hasValue(vValue) Then 
							sCacheKeyTemp = sCacheKeyTemp & ":" & sPreload & "." & vValue
						End If
					End If
				Else
					' ���� ���� �� ���� ������� �� ����� �� �����, ������ ����������
					bCacheable = False
				End If
			End If
		Next
		If bCacheable Then sCacheKey = sCacheKeyTemp
		
		buildDatagramForCheckCreatePermission = sCacheKey
	End Function


	'--------------------------------------------------------------------------
	' ����������� ������� ������� ����������� �� URL
	Private Sub applyURLParams(oXmlObject, sURLParams)
		Dim oTypeMD		' ���������� ����
		Dim oPropMD		' ���������� ��������
		Dim sPropName	' ������ ���� �� ��������
		Dim oXmlProp	' ��������
		Dim sObjectID	' ������������� �������
		Dim sOT			' ��� �������
		Dim aIDS		' ������ ���������������
		Dim oQS         ' As QueryString
		Dim sVarType	' ��� ��������
		
		Set oQS = X_GetEmptyQueryString()
		oQS.QueryString = sURLParams
		Set oTypeMD = X_GetTypeMD(oXmlObject.tagName)
		' �������� ������������������� �������� ��������������� ������� ����������� �� URL
		For Each sPropName In oQS.Names
			If MID(sPropName,1,1) = "." Then
				' �������� �������� ���������� � ".",������� ��������� ������ �� ������� �������
				sPropName = MID( sPropName , 2)

				' ������� ���������� ��������
				Set oPropMD = oTypeMD.selectSingleNode( "ds:prop[@n='" & sPropName & "']")
				' ���� �������� ���� � �������
				If Not oPropMD Is Nothing Then
					' �������� ��������
					sVarType = oPropMD.getAttribute("vt")
					Set oXmlProp = createXmlPropInDatagram(oXmlObject, sPropName, sVarType)
					Select Case sVarType 
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


	'--------------------------------------------------------------------------
	' ���������� �������� �� ���� ��������� � aProps. ��� ����� ������� � ����� �������, �� ������� ��� ���������, 
	' ����������� � ����������� ���������� (oDG)
	'	[in] oContextObjInPool	- ������� ������ � ������������ ���� (oPool)
	'	[in] oContextObjInDG	- ������� ������ � ����������� ���������� (oDG)
	'	[in] oPool				- ������������ ��� (read-only)
	'	[in] oDG				- ����������� ����������
	'	[in] aProps				- ������ ������� ������ ��������
	'	[in] nIndex				- ������� ������ � ������� aProps
	'	[retval] ���������� ������ � ������� aProps, �� ������� ������������ ��������
	'			���� ��� ����������� ������� �������������� � ����, �� ������ �� 1 ������ ������� ���������� �������� aProps
	Function preloadObjectInDatagram(oContextObjInPool, oContextObjInDG, oPool, aProps, nIndex)
		Dim sProp					' ������������ ��������
		Dim oPropPool				' xml-�������� � ����
		Dim oPropDG					' xml-�������� � ����������
		Dim oObjectInDG				' xml-������ � ����������
		Dim sXPath					' xpath-������
		Dim oObjectValueRefInPool	' ������-�������� - ������ � ��������
		Dim oObjectValueInPool		' ������-�������� - � ���� (�.�. ����������� ������, �� ������� ��������� oObjectValueRefInPool)
		Dim oObjectValueRefInDG		' ������-�������� - ������ � �������� - � ����������
		Dim bAdded					' ������� ����, ��� ������� ������ �������� ��� �������� � ����������
		
		' ������� ������������ �������� ��������
		sProp = aProps(nIndex)
		Set oPropPool = oContextObjInPool.selectSingleNode(sProp)
		If oPropPool Is Nothing Then Err.Raise -1, "preloadObjectInDatagram", "�� ������� �������� �������� " & sProp & " xml-�������: "  & vbCr & oContextObjInPool.xml
		If "0" = oPropPool.getAttribute("loaded") Then
			' �������� ������������� - ��������� ��������� � ������ ������ �� ������� ������������
			preloadObjectInDatagram = nIndex
			Exit Function
		End If
		' ������� �������� � ����
		Set oPropPool = oPool.GetXmlProperty(oContextObjInPool, sProp)
		' �������� ���������� �������� � ����������
		Set oPropDG = createXmlPropInDatagram(oContextObjInDG, sProp, "object")

		' �� ���� ������� � ��������
		For Each oObjectValueRefInPool In oPropPool.childNodes
			' ������� ������-�������� �������� � ����
			Set oObjectValueInPool = oPool.FindObjectByXmlElement(oObjectValueRefInPool)
			bAdded = False
			If Not oObjectValueInPool Is Nothing Then
				If Not IsNull(oObjectValueInPool.getAttribute("new")) Then
					' ����� ������ ������� � ���������� �� ����� ���������� ������ ���������
					Set oObjectInDG = addObjectWithAllDependencies(oObjectValueInPool, oPool)
					bAdded = True
				End If
			End If
			' ������� ������ �� ������-�������� �������� �������� � �������� � ����������,
			' ���� ��� ��� ��� ���
			Set oObjectValueRefInDG = oPropDG.selectSingleNode(oObjectValueRefInPool.tagName & "[@oid='" & oObjectValueRefInPool.getAttribute("oid") & "']")
			If oObjectValueRefInDG Is Nothing Then
				Set oObjectValueRefInDG = oPropDG.appendChild( X_CreateStubFromXmlObject(oObjectValueRefInPool) )
			End If
			If nIndex < UBound(aProps) Then
				' �.�. ������� ���� ������, �� �������� ������ � ����������, �� ������� ��������� ����������� ������, 
				' ���� �� ������� ����� ��-�� ����, ��� �� �����
				If Not bAdded Then
					Set oObjectInDG = createXmlObjectInDatagram(oObjectValueInPool, true)
				End If
				' ���� ������� ���� ������, �� ������ �������� �������� �� ��������, �� ������� ��� �� �����. 
				' ����������� � ������ ������
				If oObjectValueInPool Is Nothing Then
					preloadObjectInDatagram = nIndex
				Else
					preloadObjectInDatagram = preloadObjectInDatagram( oObjectValueInPool, oObjectInDG, oPool, aProps, nIndex + 1)
				End If
			Else
				' ������� ����������, ������ ������ �� 1 ������ ����������, ����� �������, ��� �� ������ �� �����
				preloadObjectInDatagram = nIndex + 1
			End If
		Next
	End Function
	
	
	'--------------------------------------------------------------------------
	' ��������� ����� ������� oObjectInPool (�� ���� oPool) � ����������� ���������� (m_oDG )
	' �� ����� ������ ���������, �� ������� �� ���������, ����������.
	'	[in] oObjectInPool	- ����������� ������
	'	[in] oPool			- ������������ ��� (read-only)
	Function addObjectWithAllDependencies(oObjectInPool, oPool)
		Dim oObjectValue
		
		Set addObjectWithAllDependencies = createXmlObjectInDatagram(oObjectInPool, true)
		' ������ ���� �������� ��� ����� �������, �� ������� ��������� ����������� ������:
		' �� ���� ��������-��������� (�������)
		For Each oObjectValue In oObjectInPool.selectNodes("*/*")
			' �� ������ ������� ������ � ����
			Set oObjectValue = oPool.FindObjectByXmlElement(oObjectValue)
			If Not oObjectValue Is Nothing Then
				' ������-�������� ���� � ����
				If Not IsNull(oObjectValue.getAttribute("new")) Then
					' ������ �� ����� ������ - ���� ��� ����� �������� � ����������� ����������,
					' �� ������ ���� ��� ��� ��� � ����������
					If m_oDG.SelectSingleNode(oObjectValue.tagName & "[@oid='" & oObjectValue.getAttribute("oid") & "']") Is Nothing Then
						addObjectWithAllDependencies oObjectValue, oPool
					End If
				End If
			End If
		Next
	End Function
	' #endregion
	
	
	'--------------------------------------------------------------------------
	' ��������� �������� ������ ���� �� ��������� ������� (sType, sObjectID)
	Public Sub AddCheckForChangeObject(oMenuItem, sType, sObjectID)
		If Not m_bInitialized Then Err.Raise - 1, "AddCheckForChange", "��������� �� ���������������"
		addObjectActionCheck oMenuItem, Nothing, sType, sObjectID, "change-right"
	End Sub
	
	
	'--------------------------------------------------------------------------
	' ��������� �������� ������ ���� �� �������� ������� (sType, sObjectID) �� �������� (oXmlProperty)
	Public Sub AddCheckForDeleteObjectFromProp(oMenuItem, oXmlProperty, sType, sObjectID)
		If Not m_bInitialized Then Err.Raise - 1, "AddCheckForChange", "��������� �� ���������������"
		addObjectActionCheck oMenuItem, oXmlProperty, sType, sObjectID, "delete-right"
	End Sub
	
	
	'--------------------------------------------------------------------------
	' ��������� �������� ������ ���� �� ��������� �������� (oXmlProperty)
	Public Sub AddCheckForChangeProp(oMenuItem, oXmlProperty)
		Dim nAllowProp 
		If Not m_bInitialized Then Err.Raise - 1, "AddCheckForChange", "��������� �� ���������������"
		nAllowProp = checkPropChangeRight( oXmlProperty )
		If nAllowProp = CHECKRIGHTS_DENY Then
			oMenuItem.setAttribute "allow", "0"
		ElseIf nAllowProp = CHECKRIGHTS_ALLOW Then
			oMenuItem.setAttribute "allow", "1"	
		Else
			menuItem_addChangePropRightExpr oMenuItem, oXmlProperty
		End If
	End Sub
	
	
	'--------------------------------------------------------------------------
	' ��������� � ������� required-rights ������ ���� oMenuItem ������ �� �������� ������� ����� ��������� ��������
	Private Sub menuItem_addChangePropRightExpr(oMenuItem, oXmlProperty)
		Dim sAttr
		sAttr = oMenuItem.getAttribute("required-rights")
		If IsNull(sAttr) Then 
			sAttr = ""
		Else
			sAttr = sAttr & ";"
		End If
		Set oXmlObject = oXmlProperty.parentNode
		sAttr = sAttr & oXmlObject.tagName & ":" & oXmlObject.getAttribute("oid") & ":change-prop:" & oXmlProperty.tagName
		oMenuItem.setAttribute "required-rights", sAttr 
	End Sub
	
	
	'--------------------------------------------------------------------------
	' ��������� � ������� required-rights ������ ���� oMenuItem ������ �� �������� ������� ����� sRightAttr ��� �������� sType, sObjectID
	'	[in] oMenuItem	- ����� ���� (menu-item)
	'	[in] sType		- ��� �������
	'	[in] sObejctID	- ������������� �������
	'	[in] sRightAttr - "delete-right" ��� "change-right"
	Private Sub menuItem_addObjectRightExpr(oMenuItem, sType, sObjectID, sRightAttr)
		Dim sAttr
		sAttr = oMenuItem.getAttribute("required-rights")
		If IsNull(sAttr) Then 
			sAttr = ""
		Else
			sAttr = sAttr & ";"
		End If
		sAttr = sAttr & sType & ":" & sObjectID & ":"
		If sRightAttr = "delete-right" Then
			sAttr = sAttr & "delete"
		ElseIf sRightAttr = "change-right" Then
			sAttr = sAttr & "change"
		Else
			sAttr = sAttr & "create"
		End If
		oMenuItem.setAttribute "required-rights", sAttr 
	End Sub
	
	
	'--------------------------------------------------------------------------
	' ��������� �������� ������ ���� �� �������� (��������� ��� ��������) ��� �������� (sType, sObjectID) �� �������� (oXmlProperty)
	' ����� ����� ��� AddCheckForDeleteObjectFromProp � AddCheckForChangeObject
	Private Sub addObjectActionCheck(oMenuItem, oXmlProperty, sType, sObjectID, sRightAttr)
		Dim	oXmlObject 
		Dim nAllowProp		' CHECKRIGHTS_* - ���������� �� ��������� �������� oXmlProperty
		Dim nAllowObject	' CHECKRIGHTS_* - ���������� �� �������� (sRightAttr) ��� �������� (sType, sObjectID)
		Dim bTrackMenuItem
		
		bTrackMenuItem = Not oMenuItem Is Nothing
		' ���� ������ ��������, �� ����� ��� ���������, ��� ����� �������� ���
		nAllowProp = CHECKRIGHTS_ALLOW
		If Not oXmlProperty Is Nothing Then
			nAllowProp = checkPropChangeRight( oXmlProperty )
			' ���� ����� �� ��������� ��-�� ����������, �� ������� ��������� �������� ����� ��������� ������� �������� 
			' � ������� "required-rights" ������ ����
			If nAllowProp = CHECKRIGHTS_UNKNOWN And bTrackMenuItem Then
				menuItem_addChangePropRightExpr oMenuItem, oXmlProperty
			End If
		End If
		
		If nAllowProp <> CHECKRIGHTS_DENY Then
			' �������� �������� "�� ������" (�.�. ���� �����, ���� ����������)
			Set oXmlObject = m_oPool.FindXmlObject(sType, sObjectID)
			If oXmlObject Is Nothing Then
				nAllowObject = CHECKRIGHTS_DENY
			Else
				nAllowObject = checkXmlObjectRight(oXmlObject, sRightAttr)
			End If
		End If
		
		If bTrackMenuItem Then
			' ���� ������ �������� �������� ��� ������ ������� ������, �� �������� ���� ���������
			If nAllowProp = CHECKRIGHTS_DENY Or nAllowObject = CHECKRIGHTS_DENY Then
				oMenuItem.setAttribute "allow", "0"
			ElseIf nAllowProp = CHECKRIGHTS_ALLOW And nAllowObject = CHECKRIGHTS_ALLOW Then
				oMenuItem.setAttribute "allow", "1"	
			Else
				' ����� ��������� �������� ���� �� ������� (���� ��������� ��������, ���� �������� �������, ���� � ��, � ������)
				menuItem_addObjectRightExpr oMenuItem, sType, sObjectID, sRightAttr
			End If
		End If
	End Sub
	
	
	'--------------------------------------------------------------------------
	' ��������� ���������� �� ��������� ��������
	Private Function checkPropChangeRight(oXmlProperty)
		If oXmlProperty.getAttribute("read-only") Then
			' �������� ��������� ��� "������ ��� ������" - ������� ������
			checkPropChangeRight = CHECKRIGHTS_DENY
		Else 
			' �������� �� ��������� ��� "������ ��� ������" - �������� ����� �� ��������� ����� �������-��������� ��������
			checkPropChangeRight = checkXmlObjectRight( oXmlProperty.parentNode, "change-right" )
		End If
	End Function
	
	
	'--------------------------------------------------------------------------
	' ��������� ���������� �� �������� ��� ��������
	Private Function checkXmlObjectRight(oXmlObject, sRightAttr)
		Dim sAttr
		If oXmlObject.getAttribute("new") Then
			' ���� ������ �����, �� �����
			checkXmlObjectRight = CHECKRIGHTS_ALLOW
		Else
			sAttr = oXmlObject.getAttribute(sRightAttr)
			If IsNull(sAttr) Then
				' ����� �� ��������� ������� �� ������ - ���� �� ��������
				addCheckObjectRight oXmlObject.tagName, oXmlObject.getAttribute("oid")
				checkXmlObjectRight = CHECKRIGHTS_UNKNOWN
			Else
				If sAttr = "1" Then
					' �����
					checkXmlObjectRight = CHECKRIGHTS_ALLOW
				Else
					' ������
					checkXmlObjectRight = CHECKRIGHTS_DENY
				End If
			End If
		End If
	End Function
	
	
	'--------------------------------------------------------------------------
	' ��������� � ������ �� �������� ���� ��� ��������� ��������� ������
	Private Sub addCheckObjectRight(sType, sObjectID)
		Dim sKey
		sKey = sType & ":" & sObjectID
		If Not m_objectsToCheck.Exists(sKey) Then
			m_objectsToCheck.Add sKey, internel_New_XObjectIdentity(sType, sObjectID, -1)
		End If
	End Sub
	
	
	'--------------------------------------------------------------------------
	Public Function ExecuteRightsRequest()
		Dim oResponse		' As GetObjectsRightsExResponse
		Dim oObjectsRights	' As Scripting.Dictionary - ������� ������������ ������������� ������� � ���� �� ������, ���������� � �������
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
				MsgBox Err.Description
				Err.Raise aErr(0), aErr(1), aErr(2)
			End If
		End If
		On Error Goto 0
		' �������� ������� � ������� �� ����� �������� ���������� � ������� ������� XObjectRightsDescr 
		' ��� ���� �� �������, ����� ���� � m_objectsToCheck
		Set oObjectsRights = CreateObject("Scripting.Dictionary")
		' �� ������� ������� �� ���, ��� �� �������� �� ������ ��� �������� ���� (� �.�. �����)...
		For i = 0 To m_objectsToCheck.Count-1
			sKey = m_objectsToCheck.Keys()(i)
			Set oRightDescr = oResponse.m_aObjectsRights(i)
			oObjectsRights.Add sKey, oRightDescr 
			' ���� �������� ���������� ��������� �������� �������� ������ ������� (� XRightsCache)
			If Not IsEmpty(m_newObjectsToCache) Then
				' ���� ������� ������ ����� � ��������� �������� ���� ����� ���� �����������..
				If m_newObjectsToCache.Exists(sKey) Then
					' � �������� �������� � ������� m_newObjectsToCache ����� ���� ��� ������� �������� ���������� ������ XObjectRightsDescr
					X_RightsCache().SetValueEx m_newObjectsToCache.Item(sKey), oRightDescr
				End If
			End If
			' ��������� �������� ����������� �� ������������ ������� � ����
			Set oObjectID = m_objectsToCheck.Item(sKey)
			Set oXmlObject = m_oPool.FindXmlObject(oObjectID.m_sObjectType, oObjectID.m_sObjectID)
			If Not oXmlObject Is Nothing Then
				' ������ ��������� � ����, ��������� �������� ����
				ApplyObjectRightsDescrOnXmlObject oRightDescr, oXmlObject
			End If
			X_RightsCache().SetValueEx sKey, oRightDescr
		Next
		Set ExecuteRightsRequest = oObjectsRights
	End Function
	
	
	'--------------------------------------------------------------------------
	Public Sub SetMenuItemsAccessRights(oMenu, bShowDeniedAsDisabled)
		Dim oObjectsRights 
		Dim sAttrName		' As String - ������������ ��������
		Dim oNode			' As IXMLDOMElement - ������� menu-item
		Dim sAllowAttr		' As String - ������������ ��������, ������������� ��� ������� �������� (hidden ��� disabled)
		Dim sRequiredRights	' As String - �������� �������� required-rights - �������� �������� �������� ������ ����
		Dim sNewObjectID
		Dim sNewObjectType	

		Set oObjectsRights = ExecuteRightsRequest()
		' ��������� ����� ��������� �� ����� �������� ����������� ��������
		If bShowDeniedAsDisabled Then
			sAttrName = "disabled"
		Else
			sAttrName = "hidden"
		End If
		' ������ �� ���� ������� ���� � ��������� �� ����������� �� ��������� ���������� ���� �� �������
		' ��� ����, ����� (��� ���) ����� ����� ���� ��� �������. � ���� ������ ����������� ������ ���� ��� ����������� � ������� �������� allow
		For Each oNode In oMenu.XmlMenu.selectNodes("//i:menu-item")
			sAllowAttr = oNode.getAttribute("allow")
			If IsNull(sAllowAttr) Then
				' ���������� - ����� �� ������� ����� ���� ����������� �� ��������� ���� �� ������� (������� �� ��� ��������)
				' ������� �� ��������� ������ ���� ����� � ������� m_objectsToCheck, ����������� ������� �� ������� ������� ����� �� ��������
				sRequiredRights = oNode.getAttribute("required-rights")
				' ����������: sRequiredRights ����� ������� ������ - ��. checkObjectsRights
				If Not IsNull(sRequiredRights) Then _
					sAllowAttr = checkObjectsRights( sRequiredRights, oObjectsRights )
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
			' ����� ���� ������������� �������� �������. ������������� �������� �������, ��� �������� �� ��������� �����, 
			' ��������� � �������� create-oid, � �������� create-type - ��� ������������ �������.
			sNewObjectID	= oNode.getAttribute("create-oid")
			sNewObjectType	= oNode.getAttribute("create-type") 
			If Not IsNull(sNewObjectID) And Not IsNull(sNewObjectType) Then
				' �� ���������� �� ��������� ���� � �������������� ������ ��������� XObjectRightsDescr � oObjectsRights � �������� ��� � ��� ����
				' ����� �� �������� ������� ���� ���� �������� � ������� - ����� ��� ����� � oObjectsRights.Item(sNewObjectType& ":" & sNewObjectID),
				' ���� ���� ������� � ���� XRightsCache - � ���� ������ �������� �� ���� ��� ��� ��� �� ����
				If Not X_RightsCache().Contains(sNewObjectType& ":" & sNewObjectID) Then
					X_RightsCache().SetValueEx sNewObjectType& ":" & sNewObjectID, oObjectsRights.Item(sNewObjectType& ":" & sNewObjectID)
				End If
			End If
		Next
	End Sub

		
	'--------------------------------------------------------------------------
	Private Function checkObjectsRights(sRequiredRights, ObjectsRights)
		Dim aRequiredRights 
		Dim bAllow
		Dim sCheckExpr
		Dim aCheckExprs
		Dim sType
		Dim sObjectID
		Dim sAction
		Dim sPropName
		Dim oRightsDescr 
		Dim sKey
		
		If ObjectsRights Is Nothing Then Err.Raise -1, "checkObjectsRights", "ObjectsRights Is Nothing" 
		aRequiredRights = Split(sRequiredRights, ";")
		For Each sCheckExpr In aRequiredRights
		    '���������� ������ ���������� ��������� ����������� ���� �� ������ � �������:<��� �������>:<�������������>:<�������� ��� ��������>
		    '�������� ������ �� ���� ��������� - aCheckExprs.
			aCheckExprs = Split(sCheckExpr, ":")
			If UBound(aCheckExprs) <2 Then Err.Raise -1, "checkObjectsRights", "������������ ������: " & sCheckExpr
			sType = aCheckExprs(0)
			sObjectID = aCheckExprs(1)
			sAction	= aCheckExprs(2)
			sKey = sType & ":" & sObjectID
			If ObjectsRights.Exists(sKey) Then
				Set oRightsDescr = ObjectsRights.Item(sKey)
				bAllow = False
				If sAction = "change" Then
					bAllow = Not oRightsDescr.m_bDenyChange
				ElseIf sAction = "delete" Then
					bAllow = Not oRightsDescr.m_bDenyDelete
				ElseIf sAction = "create" Then
					bAllow = Not oRightsDescr.m_bDenyCreate
				ElseIf sAction = "change-prop" Then
					' ��� ����� �������� ������ ���� ������ ������������ ��������
					sPropName = aCheckExprs(3)
					If oRightsDescr.m_bDenyChange = False Then
						' ������� �� �������� ����� ������� ���
						If IsNull(oRightsDescr.m_aReadOnlyProps) Then
							bAllow = True
						Else
							' ������ read-only ������� �����
							If getPosInArray(sPropName, oRightsDescr.m_aReadOnlyProps) = -1 Then
								bAllow = True
							End If
						End If
					End If
				End If
			End If
			If Not bAllow Then
				checkObjectsRights = False
				Exit Function
			End If
		Next
		checkObjectsRights = True
	End Function
End Class
