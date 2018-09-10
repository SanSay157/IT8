Option Explicit


'==============================================================================
' visibility-handler для списка в замен стандартному. Отличается проверкой прав с помощью команды XGetObjectsRightsEx
Public Sub XList_MenuVisibilityHandler(oSender, oEventArgs)
	Dim sGUID			' As String - идентификатор выбранного объекта
	Dim sType			' As String - наименование типа выбранного объекта
	Dim bDisabled		' As Boolean - признак заблокированности пункта
	Dim bHidden			' As Boolean - признак сокрытия пункта
	Dim oNode			' As XMLDOMElement - текущий menu-item
	Dim oParam			' As IXMLDOMElement - узел param в метаданных меню 
	Dim sAction			' As String - наименования действия(action'a) пункта меню
	Dim bProcess		' As Boolean - признак обработки текущего пункта
	Dim bTrustworthy	' As Boolean - признак "заслуживающего доверия" меню - для его пункто не надо выполнять проверку прав
	Dim oRightsChecker
	Dim sURLParams
	
	sType = oSender.Menu.Macros.item("ObjectType")
	sGUID = oSender.Menu.Macros.item("ObjectID")
	bTrustworthy = Not IsNull(oSender.Menu.XmlMenu.getAttribute("trustworthy"))
	Set oRightsChecker = New SimpleRightsChecker
	' Обработаем только известные нам операции
	For Each oNode In oSender.Menu.XmlMenu.selectNodes("i:menu-item")
		bHidden = Empty
		bDisabled = Empty
		bProcess = False
		' по всем параметрам пункта меню
		For Each oParam In oNode.selectNodes("*[local-name()='params']/*[local-name()='param']")
			' если задан параметры ObjectType и/или ObjectID, то переопределим тип и/или OID (для проверки прав)
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
	' False - значит не отображать запрещенные операции
	oRightsChecker.SetMenuItemsAccessRights oEventArgs.Menu, False
End Sub


'==============================================================================
' Переопределенный обработчик события Create для списка
' Устанавливает на создаваемый объект атрибуты ограничения доступа, 
' на основании закэшированного объекта ObjectRightsDescr в кэше XRightsCache()
Sub usrXList_OnCreate(oSender, oEventArgs)
	DoCreateWithAccessCheckInClientCache oEventArgs
End Sub


'==============================================================================
' Переопределенный обработчик события Create для дерева
' В отличии от меню списка в меню дерева права могут быть вычисленны сразу на сервере 
' и придут на клиент в виде параметра пункта меню ObjectRights в формате
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
		' определение прав на создаваемый объект отсутствует - используем реализацию с поиском прав в клиентском кэше
		DoCreateWithAccessCheckInClientCache oEventArgs
	End If
End Sub


'==============================================================================
' Открывает редактор создания объекта в качестве результата операции DoCreate пункта меню.
' Ищет в клиентском кэше прав закэшированные права на создаваемый объект, 
' если находит устанавливает на xml-объект атрибуты ограничения доступа, иначе использует x-utils::X_OpenObjectEditor
'	[in] oEventArgs As CommonEventArgsClass - параметры события Create списка и дерева
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
' Открывает корневой редактор xml-объекта, на который устанавливаются атрибуты ограничения доступа
'	[in] sObjectType - тип объекта
'	[in] sObjectID - идентификатор объекта (если Null то объект создаётся)
'	[in] sEditorMetaname - имя редактора в метаданных
'	[in] sUrlParams - строка дополнительных параметров (передается в URL)
'	[in] oObjectRightsDescr As XObjectRightsDescr
' 	[retval] - Empty если ничего не отредактировано иначе идентификатор объекта
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
' Устанавливает атрибуты ограничения доступа на xml-объект
'	[in] oRightDesc - описание прав на объект
'	[in] oXmlObject - xml-объект в пуле
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
' Ициализация свойств объекта параметрами из URL
Sub ApplyURLParamsOnXmlObject(sURLParams, oXmlObject)
	Dim oTypeMD		' метаданные типа
	Dim oPropMD		' метаданные свойства
	Dim sPropName	' Строка пути до свойства
	Dim oXmlProp	' Свойство
	Dim sObjectID	' Идентификатор объекта
	Dim sOT			' Тип объекта
	Dim aIDS		' Список идентификаторов
	Dim oQS         ' As QueryString

	Set oQS = X_GetEmptyQueryString()
	oQS.QueryString = sURLParams
	Set oTypeMD = X_GetTypeMD(oXmlObject.tagName)
	' Пытаемся проинициализировать свойства новосоззданного объекта параметрами из URL
	For Each sPropName In oQS.Names
		If MID(sPropName,1,1) = "." Then
			' описание свойства начинается с "."
			sPropName = MID( sPropName , 2)

			Set oXmlProp =  oXmlObject.selectSingleNode(sPropName)
			' если свойство есть в объекте
			If Not oXmlProp Is Nothing Then
				' получим метаданные свойства
				Set oPropMD = oTypeMD.selectSingleNode( "ds:prop[@n='" & sPropName & "']")
				Select Case oPropMD.getAttribute("vt")
					Case "i2",  "i4", "ui1"
						oXmlProp.nodeTypedValue = oQS.GetValueInt( "." & sPropName , 0)
					Case "r4", "r8", "fixed"
						oXmlProp.nodeTypedValue =  CDBl(oQS.GetValue( "." & sPropName , "0"))
					Case "date", "dateTime", "time"
						oXmlProp.nodeTypedValue = CDate(oSQ.GetValue( "." & sPropName , Now ) )
						oXmlProp.text = oXmlProp.text ' Инц. 69105
					Case "string", "text"
						oXmlProp.nodeTypedValue =  oQS.GetValue( "." & sPropName , "")
					Case "object"
						If oPropMD.getAttribute("cp") = "scalar" Then
							' объектное скаларное свойство
							sObjectID = oQS.GetValue( "." & sPropName, "")
							If Len(sObjectID) > 0 Then
								sOT = oPropMD.getAttribute("ot")
								oXmlProp.selectNodes("*").removeAll
								oXmlProp.appendChild X_CreateObjectStub(sOT, sObjectID)
								
							End If
						Else
							' объектное массивное свойства
	
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
' "Проверяльщик" прав для списка и дерева
Class SimpleRightsChecker
	Private m_aObjectsRights	' As XObjectRightsDescr() - результат выполнения операции - массив прав на объекты
	Private m_oDG				' As IXMLDOMElement - xml-датаграмма
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
			' добавим объект к списку проверяемых
			addCheckObjectRight oMenuItem, sType, sObjectID
			' добавим запись в словарь ключей кэша для новых объектов 
			' (сопоставление ключа из m_objectsToCheck и ключа, под которым будет закэширован результат проверки права на создание объекта)
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
		
		' объект может быть кэширован, поищем в кэше прав
		If X_RightsCache().FindEx(sKey, oObjectRightsDescr) Then
			' нашли закешированное значение
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
	' Добавляет в запрос на проверку прав над объектами указанный объект
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
		Dim oUrlParamNode	' As IXMLDOMElement - параметр URLParams для menu-item
		Dim sKey
		
		sKey = sType & ":" & sObjectID
		' если для menu-item задан параметр URLParams, добавим его значение к ключу
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
		Dim ObjectsRights	' As Scripting.Dictionary - словарь соответствия идентификации объекта и прав на объект, полученных с сервера
		Dim sKey			' As String - ключ в словаре
		Dim i
		Dim aErr			' массив с описание ошибки (Err.Number, Err.Source, Err.Description)
		Dim oRightDescr		' As XObjectRightsDescr - описание прав на объект
		Dim oObjectID		' As XObjectIdentity - идентификация объекта
		Dim oXmlObject		' As IXMLDOMElement - xml-объект
		Dim sPropName		' As String - наименование свойства
		
		' если есть объекты, чьи права надо запросить с сервера (в т.ч. проверить право на создание новых)
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
				' ошибка на клиенте
				aErr = Array(Err.Number, Err.Source, Err.Description)
				On Error Goto 0
				Err.Raise aErr(0), aErr(1), aErr(2)
			End If
		End If
		On Error Goto 0
		' Создадим словарь в который мы будем помещать полученные с сервера объекты XObjectRightsDescr 
		' под теми же ключами, какие были в m_objectsToCheck
		Set ObjectsRights = CreateObject("Scripting.Dictionary")
		' по каждому объекту из тех, что мы посылали на сервер для проверки прав (в т.ч. новых)...
		For i = 0 To m_objectsToCheck.Count-1
			sKey = m_objectsToCheck.Keys()(i)
			Set oRightDescr = oResponse.m_aObjectsRights(i)
			ObjectsRights.Add sKey, oRightDescr 
			' если возможно закэшируем результат проверки создания нового объекта (в XRightsCache)
			If Not IsEmpty(m_newObjectsToCache) Then
				' если текущий объект новый и результат проверки прав может быть закэширован..
				If m_newObjectsToCache.Exists(sKey) Then
					' в качестве значения в словаре m_newObjectsToCache лежит ключ под которым кэшируем полученный объект XObjectRightsDescr
					X_RightsCache().SetValueEx m_newObjectsToCache.Item(sKey), oRightDescr
				End If
			End If
			X_RightsCache().SetValueEx sKey, oRightDescr
		Next
		Set ExecuteRightsRequest = ObjectsRights
	End Function
	
	
	'--------------------------------------------------------------------------
	Public Sub SetMenuItemsAccessRights(oMenu, bShowDeniedAsDisabled)
		Dim ObjectsRights 	' As Scripting.Dictionary  - словарь объектов XObjectRightsDescr под ключами такими же как в m_objectsToCheck
		Dim sAttrName		' As String - наименование атрибута
		Dim oNode			' As IXMLDOMElement - текущий menu-item
		Dim oUrlParamNode	' As IXMLDOMElement - параметр URLParams текущего menu-item
		Dim sAllowAttr		' As String - наименование атрибута, используемого для запрета операции (hidden или disabled)
		Dim oRightDescr
		Dim sKey
		Dim sActionAttr
		Dim sRequiredRights	' As String - значение атрибута required-rights - перечень проверок текущего пункта меню
		Dim sNewObjectID
		Dim sNewObjectType	
		
		Set ObjectsRights = ExecuteRightsRequest()
		' определим каким атрибутом мы будем отмечать недоступные операции
		If bShowDeniedAsDisabled Then
			sAttrName = "disabled"
		Else
			sAttrName = "hidden"
		End If
		' пойдем по всем пунктам меню и установим их доступность на основании полученных прав на объекты
		' При этом, часть (или все) права могли быть уже извстны. В этом случае доступность пункта меню уже установлена с помощью атрибута allow
		For Each oNode In oMenu.XmlMenu.selectNodes("i:menu-item")
			sAllowAttr = oNode.getAttribute("allow")
			If IsNull(sAllowAttr) Then
				' неизвестно - право на текущий пункт меню формируется на основании прав на объекты (которые мы уже получили)
				' получим из атрибутов пункта меню ключи в словаре m_objectsToCheck, указывающие объекты от которых зависят права на операцию
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
				' доступность операции уже установлена - завершим начатое
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


