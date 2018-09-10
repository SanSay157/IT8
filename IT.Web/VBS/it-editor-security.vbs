Option Explicit

'==============================================================================
' Обработчик видимости пунктов меню для x-pe-objects::XPEObjectsElementsListClass
' Отличия от обработчика XPEObjectsElementsListClass::Internal_MenuVisibilityHandler, замещаемого данным:
' 	для операции DoCreate используется проверка прав с помощью прикладной команды (а не GetObjectsRight), 
'	которой посылается датаграмма содержащая болванку создаваемого объекта и все новые объекты, лежащие на путях,
'	указанных в параметре permission-check-preload пункта меню, т.е. объекты которые связывают создаваемый объект и 
'	объекты, от которых завясят права на создаваемый объект.
'	[in] oSender As XPEObjectsElementsListClass - компонент-владелец меню (PE)
'	[in] oEventArgs As MenuEventArgsClass 		- параметры события
Sub XPEObjectsElementsListClass_MenuVisibilityHandler(oSender, oEventArgs)
	Dim oXmlProperty	' xml-свойство
	Dim bDisabled		' признак заблокированности пункта
	Dim bHidden			' признак сокрытия пункта
	Dim oNode			' текущий menu-item
	Dim sType			' тип объекта в свойстве
	Dim sObjectID		' идентификатор выбранного объекта
	Dim oObjectValue	' As IXMLDOMElement - xml-объект значение
	Dim bIsLoaded		' As Boolean - признак того,что объект-значение загружен из БД
	Dim bProcess		' As Boolean - признак обработки текущего пункта
	Dim oRightsChecker	' As RightsChecker
	Dim oParam			' xml-узел i:param
	Dim sURLParams		' значение параметра URLParams пункта меню

	Set oXmlProperty = oSender.XmlProperty		
	' получим тип и идентификатор выбранного объекта, для которого строиться меню
	sType = oEventArgs.Menu.Macros.Item("ObjectType")
	sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
	If 0=Len("" & sObjectID) Then sObjectID = Null
	
	' если в списке выбран объект (меню может строить и без выбранной строки списка), то получим ссылку на него в пуле,
	' а также определим факт был ли он загружен из БД
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
		' Обработаем только известные нам операции
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
					' по всем параметрам пункта меню
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
				' если линк и обратное скалярное массивное свойство (по которому объекты попадают в список)
				' ненулабельное, то операция "разорвать связь" должна быть задизейблена всегда
				If oSender.m_oPropertyEditorBase.PropertyMD.getAttribute("cp") = "link" Then
					If IsNull(oSender.ObjectEditor.Pool.GetReversePropertyMD(oXmlProperty).getAttribute("maybenull")) Then
						bHidden = True
					End If
				End If
				If bHidden = False Then
					bHidden = IsNull(sObjectID) Or HasValue(oSender.HtmlElement.getAttribute("OFF_UNLINK"))
					' TODO: для "разлинковки" тоже надо проверять права
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
	' False - значит не отображать запрещенные операции
	oRightsChecker.SetMenuItemsAccessRights oEventArgs.Menu, True
End Sub


'==============================================================================
' Обработчик видимости пунктов меню для x-pe-object::XPEObjectPresentationClass
' См. комментарий к XPEObjectsElementsListClass_MenuVisibilityHandler
'	[in] oEventArgs As MenuEventArgsClass
Sub XPEObjectPresentationClass_MenuVisibilityHandler(oSender, oEventArgs)
	Dim bDisabled		' признак заблокированности пункта
	Dim bHidden			' признак сокрытия пункта
	Dim oNode			' текущий menu-item
	Dim sType			' тип объекта в свойстве
	Dim sObjectID		' идентификатор объекта-значения
	Dim oXmlProperty	' xml-свойство
	Dim oObjectValue	' As IXMLDOMElement - xml-объект значение
	Dim bIsLoaded		' As Boolean - признак того,что объект-значение загружен из БД
	Dim bProcess		' As Boolean - признак обработки текущего пункта
	Dim oRightsChecker	' As RightsChecker
	Dim oParam			' xml-узел i:param
	Dim sURLParams		' значение параметра URLParams пункта меню

	Set oXmlProperty = oSender.XmlProperty		
	' получим тип и идентификатор объекта-значения
	sType = oEventArgs.Menu.Macros.Item("ObjectType")
	sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
	If 0=Len("" & sObjectID) Then sObjectID = Null
	
	' если в свойстве есть объект-значение , то получим ссылку на него в пуле,
	' а также определим факт был ли он загружен из БД
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
		
		' Обработаем только известные нам операции
		' ВНИМАНИЕ: содержимое select'a copy-paste из x-pe-object.vbs, кроме операции DoCreate
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
					' по всем параметрам пункта меню
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
					' TODO: для "разлинковки" тоже надо проверять права
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
	' False - значит не отображать запрещенные операции
	oRightsChecker.SetMenuItemsAccessRights oEventArgs.Menu, True
End Sub


'==============================================================================
' Создает объект в пуле со ссылкой из свойства. 
' Использует специальный атрибут, заданный на свойстве, с ключем в кэше прав XRightsCache
Public Function CreateXmlObjectInProp(oPool, sType, oXmlProperty)
	Dim oNewObject
	Dim sKey
	Dim oObjectRightsDescr
	' создадим объект в пуле
	Set oNewObject = oPool.CreateXmlObjectInPool(sType)
	Set CreateXmlObjectInProp = oNewObject 
	' добавим на созданный объект ссылку в свойстве
	oPool.AddRelation Nothing, oXmlProperty , oNewObject
	sKey = oXmlProperty.getAttribute("create-right-cache-key")
	If Not IsNull(sKey) Then
		If X_RightsCache().FindEx(sKey, oObjectRightsDescr) Then
			' нашли закэшированные права на создание объекта в данном свойстве
			' (см. it-security.vbs)
			ApplyObjectRightsDescrOnXmlObject oObjectRightsDescr, oNewObject
		End If
	End If
End Function


'==============================================================================
' Переопределенный обработчик операции "Создать" в elements-list (x-pe-objects)
' Написан ради того, чтобы на создаваемый объект навесить атрибуты ограничения доступа,
' которые получаются из закэшированных прав. Права - это объект ObjectRightsDescr,
' получаемый из кэша прав XRightsCache() по ключу, значение которого хранится в атрибуте "create-right-cache-key" xml-свойства.
' Атрибут создается в RightsChecker::AddCheckForCreateObjectInPropEx
Sub usr_ObjectsElementsList_OnCreate(oSender, oEventArgs)
	Dim oXmlProperty		' xml-свойство
	Dim oNewObject			' Новый объект-значение
	Dim oNewObjectInProp	' заглушка объекта-значения в свойстве
	Dim bAggregated         ' признак аггрегациии

	With oEventArgs
		' начнем агрегированную транзакцию
		oSender.ObjectEditor.Pool.BeginTransaction True
		' ВАЖНО: ссылка oXmlProperty полечена после вызова BeginTransaction, поэтому ей можно пользоваться и после CommitTransaction
		Set oXmlProperty = oSender.XmlProperty
		' создаим новый объект, поместим его в пул, добавим на него ссылку из свойства и главное, установим атрибуты ограничения доступа
		Set oNewObject = CreateXmlObjectInProp(oSender.ObjectEditor.Pool, oSender.ValueObjectTypeName, oXmlProperty)
		' откроем вложенный редактор с признаком EnlistInCurrentTransaction=True, т.о. этот редактор не будет создавать новой транзакции
		.ReturnValue  = oSender.ObjectEditor.OpenEditor(oNewObject, Null, Null, .Metaname, True, oXmlProperty, Not .IsSeparateTransaction, True, .UrlArguments)
		If IsEmpty( .ReturnValue  ) Then
			' нажали отмену - откатим транзакцию
			oSender.ObjectEditor.Pool.RollbackTransaction
		Else
		    ' получим ссылку на созданный объект в свойстве
			' нажали Ок - закомитим
			If oSender.IsOrdered Then
				' если свойство сортируемое - вставим расположим в свойстве с учетом сортировки
				' т.к. не известно сколько транзакций могло начинаться во вложенном редакторе, 
                ' необходимо переполучить ссылку на заглушку в свойстве
				Set oXmlProperty = oSender.XmlProperty
				Set oNewObjectInProp = oXmlProperty.selectSingleNode(oNewObject.tagName & "[@oid='" & oNewObject.getAttribute("oid") & "']")
				oSender.OrderObjectInProp oNewObjectInProp
			End If
			oSender.ObjectEditor.Pool.CommitTransaction
	    	' обновим представление PE
			oSender.SetData
		End If		
	End With
End Sub


const CHECKRIGHTS_ALLOW		= 1
const CHECKRIGHTS_DENY		= 0
const CHECKRIGHTS_UNKNOWN	= -1


'==============================================================================
Class RightsChecker
	Private m_bInitialized		' As Boolean - Признак инициализированности
	Private m_aObjectsRights	' As XObjectRightsDescr() - результат выполнения операции - массив прав на объекты
	Private m_oDG				' As IXMLDOMElement - xml-датаграмма
	Private m_objectsToCheck	' As Scripting.Dictionary
	Private m_newObjectsToCache	' As Scripting.Dictionary
	Private m_oPool
	

	Private Sub Class_Initialize
		m_bInitialized = False
	End Sub
	
	'--------------------------------------------------------------------------
	Public Sub Initialize(oObjectEditor)
		Set m_oPool = oObjectEditor.Pool
		' Создадим заготовку xml-датаграммы для проверки прав на создание объекта
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
		Dim oUrlParamNode	' As IXMLDOMElement - параметр URLParams для menu-item
		Dim sKey
		
		sKey = sType & ":" & sObjectID
		
		If Not oMenuItem Is Nothing Then
			' если для menu-item задан параметр URLParams, добавим его значение к ключу
			Set oUrlParamNode = oMenuItem.selectSingleNode("i:params/i:param[@n='URLParams']")
			If Not oUrlParamNode Is Nothing Then
				sKey = sKey & "?" & oUrlParamNode.text
			End If
		End If
		getKey = skey
	End Function
	

	' #region Проверки на создание объекта
	'--------------------------------------------------------------------------
	'	[in] oMenuItem As IXMLDOMElement - элемет i:menu-item или Nothing
	'	[in] oXmlProperty As IXMLDOMElement - xml-узел меню
	'	[in] sType - тип создаваемого объекта
	'	[in] sCheckPreloads - список цепочек свойств, по которым добавляются все объекты в датаграмму для проверки прав
	Public Sub AddCheckForCreateObjectInProp(oMenuItem, oXmlProperty, sType, sCheckPreloads)
		AddCheckForCreateObjectInPropEx oMenuItem, oXmlProperty, sType, sCheckPreloads, ""
	End Sub


	'--------------------------------------------------------------------------
	'	[in] oMenuItem As IXMLDOMElement - элемет i:menu-item или Nothing
	'	[in] oXmlProperty As IXMLDOMElement - xml-узел меню
	'	[in] sType - тип создаваемого объекта
	'	[in] sCheckPreloads - список цепочек свойств, по которым добавляются все объекты в датаграмму для проверки прав
	'	[in] sUrlParams - параметры, инициализирующие создавааемый объект (в формате ".{имя_свойства}={значение}")
	Public Sub AddCheckForCreateObjectInPropEx(oMenuItem, oXmlProperty, sType, sCheckPreloads, sUrlParams)
		Dim nAllowProp 			' признак возможности изменения свойства (ведь создание в свойстве - это в т.ч. изменение его)
		Dim sCheckObjectID		' идентификатор нового объекта, на создание которого проверяются права
		Dim sCacheKey			' ключ, под которым надо искать объект в клиентском кэше
		Dim bCacheable			' признак того, что результат проверки прав может быть закэширован
		Dim oObjectRightsDescr	' объект-описатель прав на создаваемый объект
		Dim bTrackMenuItem		' признак того, что задан элемент меню oMenuItem
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
				' добавим выражение проверки права на операцию на основании наличия права на изменение заданного свойства
				menuItem_addChangePropRightExpr oMenuItem, oXmlProperty
			End If
		End If
		sCheckObjectID = CreateGUID()
		' пометим пункт меню специальным атрибутом - идентификатором нового объекта, 
		' чтобы в дальнейшем сопоставить полученные права на создание и пункт меню
		If bTrackMenuItem Then
			oMenuItem.setAttribute "create-oid", sCheckObjectID
			oMenuItem.setAttribute "create-type", sType
		End If
		If Not oXmlProperty Is Nothing Then 
			oXmlProperty.setAttribute "create-right-cache-key", sType & ":" & sCheckObjectID
			' Если известно, что создание объекта в свойстве запрещено, но пункт меню не задан (если пункт меню задан, то мы бы вышли раньше)..
			If nAllowProp = CHECKRIGHTS_DENY Then
				' ...то создадим в кэше прав объект описывающий отсутствие прав на создание 
				' и поместим его под ключем, значение которого будет храниться в атрибуте "create-right-cache-key" свойства
				X_RightsCache().SetValueEx sType & ":" & sCheckObjectID, New_XObjectRightsDescr(Null,True,True,True)
				Exit Sub
			End If
		End If
		' наполним датаграмму необходимыми объектами для проверки прав на создание. 
		' Получим ключ, по которым можно закэшировать (и возможно уже закэширован) результат проверки прав (объект XObjectRightsDescr)
		sCacheKey = buildDatagramForCheckCreatePermission( oXmlProperty, sType, sCheckObjectID, sCheckPreloads, sUrlParams, oMenuItem )
		If Len("" & sCacheKey) > 0 Then bCacheable = True
		If bCacheable Then 
			If hasValue(sUrlParams) Then 
				sCacheKey = sCacheKey & ":" & sUrlParams
			End If
			' объект может быть кэширован, поищем в кэше прав
			If X_RightsCache().FindEx(sCacheKey, oObjectRightsDescr) Then
				' нашли закешированное значение
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
			' закэшированное значение не нашли, но кэширование возможно - запомним соответствие oid и ключа кэша
			If IsEmpty(m_newObjectsToCache) Then Set m_newObjectsToCache = CreateObject("Scripting.Dictionary")
			m_newObjectsToCache.Add getKey(oMenuItem, sType, sCheckObjectID), sCacheKey
		End If
		' добавим объект к списку проверяемых
		Set oXObjectIdentity = New XObjectIdentity
	        oXObjectIdentity.m_sObjectType = sType
	        oXObjectIdentity.m_sObjectID = sCheckObjectID
	        oXObjectIdentity.m_vTS = -1
		m_objectsToCheck.Add sType & ":" & sCheckObjectID, oXObjectIdentity
		
		If bTrackMenuItem Then
			' добавим выражение проверки права на операцию на основании наличия права на действие create над текущим объектом
			menuItem_addObjectRightExpr oMenuItem, sType, sCheckObjectID, "create"
		End If
	End Sub
	
	'--------------------------------------------------------------------------
	' Создает объект в датаграмме, если его нет
	Private Function createXmlObjectInDatagram(oMasterObject, bDeepClone)
		Dim oXmlObject
		Set oXmlObject = m_oDG.SelectSingleNode(oMasterObject.tagName & "[@oid='" & oMasterObject.getAttribute("oid") & "']")
		If oXmlObject  Is Nothing Then
			Set oXmlObject  = m_oDG.appendChild( oMasterObject.cloneNode(bDeepClone) )
		End If
		Set createXmlObjectInDatagram = oXmlObject 
	End Function
	
	
	'--------------------------------------------------------------------------
	' Создает свойство объекта в датаграмме, если его нет
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
	' Создает в свойстве ссылку на объект и сам объект в датаграмме
	Private Function createXmlPropObjectValue(oPropDG, sType, sCheckObjectID)
		Dim oObjectValueRef
		Dim oObjectValue
		
		' добавим в свойство заглушку создаваемого объекта-значения
		Set oObjectValueRef = oPropDG.appendChild( X_CreateObjectStub(sType, sCheckObjectID) )
		' в создаваемую датаграмму добавим создаваемый объект, на который только что установили ссылку в свойстве
		' это необходимо, т.к. в свойстве у нас только заглушка и XStorage не сможет понять, что это не ссылка, а объект, 
		' поэтому добавим его на корневом уровне датаграммы
		Set oObjectValue = m_oDG.selectSingleNode(sType & "[@oid='" & sCheckObjectID & "']")
		If oObjectValue Is Nothing Then
			Set oObjectValue = m_oDG.appendChild( oObjectValueRef.cloneNode(true) )
			'oObjectValue.setAttribute "oid", sCheckObjectID
			oObjectValue.setAttribute "new", "1"
		End If
		Set createXmlPropObjectValue = oObjectValue 
	End Function


	'--------------------------------------------------------------------------
	' Наполняет датаграмму объектами для проверки прав на создания объекта sType, sCheckObjectID
	'	[in] oXmlProperty
	'	[in] sType
	'	[in] sCheckObjectID
	'	[in] sPreloads
	'	[in] sUrlParams - параметры, инициализирующие создавааемый объект (в формате ".{имя_свойства}={значение}")
	'	[in] oMenuItem
	'	[retval] sCacheKey - ключ в кэше прав, если кеширование возможно
	Private Function buildDatagramForCheckCreatePermission(oXmlProperty, sType, sCheckObjectID, sPreloads, sUrlParams, oMenuItem)
		Dim oPool			' пул
		Dim aPreloads		' массив прелоадов
		Dim sPreload		' одна цепочка прелоада (Свойство1.Свойство2)
		Dim aProperties		' массив свойств одной цепочки прелоада
		Dim oDG				' xml-узел x-datagram - датаграмма
		Dim oMasterObject	' xml-объект, в свойстве которого
		Dim oMasterObjectDG	' отображение oMasterObject в датаграмме
		Dim oPropDG			' свойство в датаграмме
		Dim oObjectValue	' объект значение
		Dim oReversePropMD	' метаданные обратного свойства объекта-значения
		Dim nIndex
		Dim vValue
		Dim sCacheKey
		Dim bCacheable		' признак возможности кэширования
		Dim sCacheKeyTemp	' для формирвоания ключа хэша
				
		Set oPool = m_oPool
		' получим ссылку на объект-владелец текущего свойства
		Set oMasterObject = oXmlProperty.parentNode
		' Добавим в датаграмму болванку объекта-владельца текущего свойства
		Set oMasterObjectDG = createXmlObjectInDatagram(oMasterObject, not IsNull(oMasterObject.getAttribute("new")) )
		' Добавим в болванку объекта владельца текущее свойство
		Set oPropDG = createXmlPropInDatagram(oMasterObjectDG, oXmlProperty.tagName, "object")
		' Добавим ссылку на объект sType, sCheckObjectID
		Set oObjectValue = createXmlPropObjectValue(oPropDG, sType, sCheckObjectID)

		' инициализируем свойства нового проверяемого объекта, если они заданы		
		If hasValue(sUrlParams) Then 
			applyURLParams oObjectValue, sUrlParams 
		End If

		bCacheable = True
		sCacheKeyTemp = getKey(oMenuItem, sType, sCheckObjectID)
		aPreloads = Split(sPreloads, ";")
		For Each sPreload In aPreloads
			aProperties = Split(sPreload, ".")
			If UBound(aProperties) >= 0 Then
				' прогрузим все новые новые объекты (с их зависимыми новыми объектами) на пути свойств в aProperties
				nIndex = preloadObjectInDatagram( oMasterObject, oMasterObjectDG, oPool, aProperties, 0 )
				If nIndex > UBound(aProperties) Then
					' дошли до конца прелоадa - можно сформировать ключ кэша
					If bCacheable Then
					    'Берем 9 последних символов строки - цепочки свойств(прелоада) и проверяем на равенство ".ObjectID"
						If Right(sPreload,  9) <> ".ObjectID" Then sPreload = sPreload & ".ObjectID" 
						vValue = oPool.GetPropertyValue(oMasterObject, sPreload)
						If hasValue(vValue) Then 
							sCacheKeyTemp = sCacheKeyTemp & ":" & sPreload & "." & vValue
						End If
					End If
				Else
					' если хотя бы один прелоад не дошел до конца, нельзя кэшировать
					bCacheable = False
				End If
			End If
		Next
		If bCacheable Then sCacheKey = sCacheKeyTemp
		
		buildDatagramForCheckCreatePermission = sCacheKey
	End Function


	'--------------------------------------------------------------------------
	' Ициализация свойств объекта параметрами из URL
	Private Sub applyURLParams(oXmlObject, sURLParams)
		Dim oTypeMD		' метаданные типа
		Dim oPropMD		' метаданные свойства
		Dim sPropName	' Строка пути до свойства
		Dim oXmlProp	' Свойство
		Dim sObjectID	' Идентификатор объекта
		Dim sOT			' Тип объекта
		Dim aIDS		' Список идентификаторов
		Dim oQS         ' As QueryString
		Dim sVarType	' тип свойства
		
		Set oQS = X_GetEmptyQueryString()
		oQS.QueryString = sURLParams
		Set oTypeMD = X_GetTypeMD(oXmlObject.tagName)
		' Пытаемся проинициализировать свойства новосоззданного объекта параметрами из URL
		For Each sPropName In oQS.Names
			If MID(sPropName,1,1) = "." Then
				' описание свойства начинается с ".",поэтому считываем строку со второго символа
				sPropName = MID( sPropName , 2)

				' получим метаданные свойства
				Set oPropMD = oTypeMD.selectSingleNode( "ds:prop[@n='" & sPropName & "']")
				' если свойство есть в объекте
				If Not oPropMD Is Nothing Then
					' создадим свойство
					sVarType = oPropMD.getAttribute("vt")
					Set oXmlProp = createXmlPropInDatagram(oXmlObject, sPropName, sVarType)
					Select Case sVarType 
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


	'--------------------------------------------------------------------------
	' Рекурсивно проходит по всем свойствам в aProps. Все новые объекты и новый объекты, на которые они ссылаются, 
	' добавляются в формируемую датаграмму (oDG)
	'	[in] oContextObjInPool	- текущий объект в оригинальном пуле (oPool)
	'	[in] oContextObjInDG	- текущий объект в созадавемой датаграмме (oDG)
	'	[in] oPool				- оригинальный пул (read-only)
	'	[in] oDG				- создаваемая датаграмма
	'	[in] aProps				- массив свойств одного прелоада
	'	[in] nIndex				- текущий индекс в массиве aProps
	'	[retval] Возвращает индекс в массиве aProps, на котором остановилась загрузка
	'			Если все необходимые объекты присутствовали в пуле, то вернем на 1 больше индекса последнего элемента aProps
	Function preloadObjectInDatagram(oContextObjInPool, oContextObjInDG, oPool, aProps, nIndex)
		Dim sProp					' наименование свойства
		Dim oPropPool				' xml-свойство в пуле
		Dim oPropDG					' xml-свойство в датаграмме
		Dim oObjectInDG				' xml-объект в датаграмме
		Dim sXPath					' xpath-запрос
		Dim oObjectValueRefInPool	' объект-значение - ссылка в свойстве
		Dim oObjectValueInPool		' объект-значение - в пуле (Т.е. загруженный объект, на который указывает oObjectValueRefInPool)
		Dim oObjectValueRefInDG		' объект-значение - ссылка в свойстве - в датаграмме
		Dim bAdded					' прознак того, что текущий объект значение был добавлен в датаграмму
		
		' получим наименование текущего свойства
		sProp = aProps(nIndex)
		Set oPropPool = oContextObjInPool.selectSingleNode(sProp)
		If oPropPool Is Nothing Then Err.Raise -1, "preloadObjectInDatagram", "Не удалось получить свойство " & sProp & " xml-объекта: "  & vbCr & oContextObjInPool.xml
		If "0" = oPropPool.getAttribute("loaded") Then
			' свойство незагруженное - остановим прогрузку и вернем индекс на котором остановились
			preloadObjectInDatagram = nIndex
			Exit Function
		End If
		' получим свойство в пуле
		Set oPropPool = oPool.GetXmlProperty(oContextObjInPool, sProp)
		' создадим зеркальное свойство в датаграмме
		Set oPropDG = createXmlPropInDatagram(oContextObjInDG, sProp, "object")

		' по всем ссылкам в свойстве
		For Each oObjectValueRefInPool In oPropPool.childNodes
			' получим объект-значение свойства в пуле
			Set oObjectValueInPool = oPool.FindObjectByXmlElement(oObjectValueRefInPool)
			bAdded = False
			If Not oObjectValueInPool Is Nothing Then
				If Not IsNull(oObjectValueInPool.getAttribute("new")) Then
					' новый объект добавим в датаграмму со всеми зависимыми новыми объектами
					Set oObjectInDG = addObjectWithAllDependencies(oObjectValueInPool, oPool)
					bAdded = True
				End If
			End If
			' добавим ссылку на объект-значение текущего свойства в свойство в датаграмме,
			' если его там еще нет
			Set oObjectValueRefInDG = oPropDG.selectSingleNode(oObjectValueRefInPool.tagName & "[@oid='" & oObjectValueRefInPool.getAttribute("oid") & "']")
			If oObjectValueRefInDG Is Nothing Then
				Set oObjectValueRefInDG = oPropDG.appendChild( X_CreateStubFromXmlObject(oObjectValueRefInPool) )
			End If
			If nIndex < UBound(aProps) Then
				' т.к. прелоад идет дальше, то создадим объект в датаграмме, на который указывает добавленная ссылка, 
				' если не создали ранее из-за того, что он новый
				If Not bAdded Then
					Set oObjectInDG = createXmlObjectInDatagram(oObjectValueInPool, true)
				End If
				' если прелоад идет дальше, но объект значение свойства не загружен, то грузить его не будет. 
				' остановимся и вернем индекс
				If oObjectValueInPool Is Nothing Then
					preloadObjectInDatagram = nIndex
				Else
					preloadObjectInDatagram = preloadObjectInDatagram( oObjectValueInPool, oObjectInDG, oPool, aProps, nIndex + 1)
				End If
			Else
				' прелоад закончился, вернем индекс на 1 больше последнего, чтобы сказать, что мы прошли до конца
				preloadObjectInDatagram = nIndex + 1
			End If
		Next
	End Function
	
	
	'--------------------------------------------------------------------------
	' Добавляет копию объекта oObjectInPool (из пула oPool) в формируемую датаграмму (m_oDG )
	' со всеми новыми объектами, на которые он ссылается, рекурсивно.
	'	[in] oObjectInPool	- клонируемый объект
	'	[in] oPool			- оригинальный пул (read-only)
	Function addObjectWithAllDependencies(oObjectInPool, oPool)
		Dim oObjectValue
		
		Set addObjectWithAllDependencies = createXmlObjectInDatagram(oObjectInPool, true)
		' теперь надо добавить все новые объекты, на которые ссылается добавленный объект:
		' по всем объектам-значениям (ссылкам)
		For Each oObjectValue In oObjectInPool.selectNodes("*/*")
			' по ссылке получим объект в пуле
			Set oObjectValue = oPool.FindObjectByXmlElement(oObjectValue)
			If Not oObjectValue Is Nothing Then
				' объект-значение есть в пуле
				If Not IsNull(oObjectValue.getAttribute("new")) Then
					' ссылка на новый объект - надо его также добавить в формируемую датаграмму,
					' но только если его уже нет в датаграмме
					If m_oDG.SelectSingleNode(oObjectValue.tagName & "[@oid='" & oObjectValue.getAttribute("oid") & "']") Is Nothing Then
						addObjectWithAllDependencies oObjectValue, oPool
					End If
				End If
			End If
		Next
	End Function
	' #endregion
	
	
	'--------------------------------------------------------------------------
	' Добавляет проверку пункта меню на изменение объекта (sType, sObjectID)
	Public Sub AddCheckForChangeObject(oMenuItem, sType, sObjectID)
		If Not m_bInitialized Then Err.Raise - 1, "AddCheckForChange", "Экземпляр не инициализирован"
		addObjectActionCheck oMenuItem, Nothing, sType, sObjectID, "change-right"
	End Sub
	
	
	'--------------------------------------------------------------------------
	' Добавляет проверку пункта меню на удаление объекта (sType, sObjectID) из свойства (oXmlProperty)
	Public Sub AddCheckForDeleteObjectFromProp(oMenuItem, oXmlProperty, sType, sObjectID)
		If Not m_bInitialized Then Err.Raise - 1, "AddCheckForChange", "Экземпляр не инициализирован"
		addObjectActionCheck oMenuItem, oXmlProperty, sType, sObjectID, "delete-right"
	End Sub
	
	
	'--------------------------------------------------------------------------
	' Добавляет проверку пункта меню на изменение свойства (oXmlProperty)
	Public Sub AddCheckForChangeProp(oMenuItem, oXmlProperty)
		Dim nAllowProp 
		If Not m_bInitialized Then Err.Raise - 1, "AddCheckForChange", "Экземпляр не инициализирован"
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
	' Добавляет в атрибут required-rights пункта меню oMenuItem запрос на проверку наличия права изменения свойства
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
	' Добавляет в атрибут required-rights пункта меню oMenuItem запрос на проверку наличия права sRightAttr над объектом sType, sObjectID
	'	[in] oMenuItem	- пункт меню (menu-item)
	'	[in] sType		- тип объекта
	'	[in] sObejctID	- идентификатор объекта
	'	[in] sRightAttr - "delete-right" или "change-right"
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
	' Добавляет проверку пункта меню на действие (изменение или удаление) над объектом (sType, sObjectID) из свойства (oXmlProperty)
	' Общий метод для AddCheckForDeleteObjectFromProp и AddCheckForChangeObject
	Private Sub addObjectActionCheck(oMenuItem, oXmlProperty, sType, sObjectID, sRightAttr)
		Dim	oXmlObject 
		Dim nAllowProp		' CHECKRIGHTS_* - разрешение на изменение свойства oXmlProperty
		Dim nAllowObject	' CHECKRIGHTS_* - разрешение на действие (sRightAttr) над объектом (sType, sObjectID)
		Dim bTrackMenuItem
		
		bTrackMenuItem = Not oMenuItem Is Nothing
		' Если задано свойство, то нужно еще проверить, что можно изменять его
		nAllowProp = CHECKRIGHTS_ALLOW
		If Not oXmlProperty Is Nothing Then
			nAllowProp = checkPropChangeRight( oXmlProperty )
			' если права на изменения св-ва неизвестны, то добавим выражение проверки права изменения данного свойства 
			' в атрибут "required-rights" пункта меню
			If nAllowProp = CHECKRIGHTS_UNKNOWN And bTrackMenuItem Then
				menuItem_addChangePropRightExpr oMenuItem, oXmlProperty
			End If
		End If
		
		If nAllowProp <> CHECKRIGHTS_DENY Then
			' изменять свойство "не нельзя" (т.е. либо можно, либо неизвестно)
			Set oXmlObject = m_oPool.FindXmlObject(sType, sObjectID)
			If oXmlObject Is Nothing Then
				nAllowObject = CHECKRIGHTS_DENY
			Else
				nAllowObject = checkXmlObjectRight(oXmlObject, sRightAttr)
			End If
		End If
		
		If bTrackMenuItem Then
			' если нельзя изменять свойство или нельзя удалять объект, то операция меню запрещена
			If nAllowProp = CHECKRIGHTS_DENY Or nAllowObject = CHECKRIGHTS_DENY Then
				oMenuItem.setAttribute "allow", "0"
			ElseIf nAllowProp = CHECKRIGHTS_ALLOW And nAllowObject = CHECKRIGHTS_ALLOW Then
				oMenuItem.setAttribute "allow", "1"	
			Else
				' иначе требуется проверка прав на сервере (либо изменения свойства, либо удаления объекта, либо и то, и другое)
				menuItem_addObjectRightExpr oMenuItem, sType, sObjectID, sRightAttr
			End If
		End If
	End Sub
	
	
	'--------------------------------------------------------------------------
	' Получения разрешения на изменение свойства
	Private Function checkPropChangeRight(oXmlProperty)
		If oXmlProperty.getAttribute("read-only") Then
			' свойство помеченно как "только для чтения" - удалять нельзя
			checkPropChangeRight = CHECKRIGHTS_DENY
		Else 
			' свойство НЕ помеченно как "только для чтения" - проверим права на изменения всего объекта-владельца свойства
			checkPropChangeRight = checkXmlObjectRight( oXmlProperty.parentNode, "change-right" )
		End If
	End Function
	
	
	'--------------------------------------------------------------------------
	' Получения разрешения на действие над объектом
	Private Function checkXmlObjectRight(oXmlObject, sRightAttr)
		Dim sAttr
		If oXmlObject.getAttribute("new") Then
			' если объект новый, то можно
			checkXmlObjectRight = CHECKRIGHTS_ALLOW
		Else
			sAttr = oXmlObject.getAttribute(sRightAttr)
			If IsNull(sAttr) Then
				' права на изменение объекта не заданы - надо из получить
				addCheckObjectRight oXmlObject.tagName, oXmlObject.getAttribute("oid")
				checkXmlObjectRight = CHECKRIGHTS_UNKNOWN
			Else
				If sAttr = "1" Then
					' можно
					checkXmlObjectRight = CHECKRIGHTS_ALLOW
				Else
					' нельзя
					checkXmlObjectRight = CHECKRIGHTS_DENY
				End If
			End If
		End If
	End Function
	
	
	'--------------------------------------------------------------------------
	' Добавляет в запрос на проверку прав над объектами указанный объект
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
		Dim oObjectsRights	' As Scripting.Dictionary - словарь соответствия идентификации объекта и прав на объект, полученных с сервера
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
				MsgBox Err.Description
				Err.Raise aErr(0), aErr(1), aErr(2)
			End If
		End If
		On Error Goto 0
		' Создадим словарь в который мы будем помещать полученные с сервера объекты XObjectRightsDescr 
		' под теми же ключами, какие были в m_objectsToCheck
		Set oObjectsRights = CreateObject("Scripting.Dictionary")
		' по каждому объекту из тех, что мы посылали на сервер для проверки прав (в т.ч. новых)...
		For i = 0 To m_objectsToCheck.Count-1
			sKey = m_objectsToCheck.Keys()(i)
			Set oRightDescr = oResponse.m_aObjectsRights(i)
			oObjectsRights.Add sKey, oRightDescr 
			' если возможно закэшируем результат проверки создания нового объекта (в XRightsCache)
			If Not IsEmpty(m_newObjectsToCache) Then
				' если текущий объект новый и результат проверки прав может быть закэширован..
				If m_newObjectsToCache.Exists(sKey) Then
					' в качестве значения в словаре m_newObjectsToCache лежит ключ под которым кэшируем полученный объект XObjectRightsDescr
					X_RightsCache().SetValueEx m_newObjectsToCache.Item(sKey), oRightDescr
				End If
			End If
			' проставим атрибуты доступности на существующие объекты в пуле
			Set oObjectID = m_objectsToCheck.Item(sKey)
			Set oXmlObject = m_oPool.FindXmlObject(oObjectID.m_sObjectType, oObjectID.m_sObjectID)
			If Not oXmlObject Is Nothing Then
				' объект находится в пуле, установим атрибуты прав
				ApplyObjectRightsDescrOnXmlObject oRightDescr, oXmlObject
			End If
			X_RightsCache().SetValueEx sKey, oRightDescr
		Next
		Set ExecuteRightsRequest = oObjectsRights
	End Function
	
	
	'--------------------------------------------------------------------------
	Public Sub SetMenuItemsAccessRights(oMenu, bShowDeniedAsDisabled)
		Dim oObjectsRights 
		Dim sAttrName		' As String - наименование атрибута
		Dim oNode			' As IXMLDOMElement - текущий menu-item
		Dim sAllowAttr		' As String - наименование атрибута, используемого для запрета операции (hidden или disabled)
		Dim sRequiredRights	' As String - значение атрибута required-rights - перечень проверок текущего пункта меню
		Dim sNewObjectID
		Dim sNewObjectType	

		Set oObjectsRights = ExecuteRightsRequest()
		' определим каким атрибутом мы будем отмечать недоступные операции
		If bShowDeniedAsDisabled Then
			sAttrName = "disabled"
		Else
			sAttrName = "hidden"
		End If
		' пойдем по всем пунктам меню и установим их доступность на основании полученных прав на объекты
		' При этом, часть (или все) права могли быть уже извстны. В этом случае доступность пункта меню уже установлена с помощью атрибута allow
		For Each oNode In oMenu.XmlMenu.selectNodes("//i:menu-item")
			sAllowAttr = oNode.getAttribute("allow")
			If IsNull(sAllowAttr) Then
				' неизвестно - право на текущий пункт меню формируется на основании прав на объекты (которые мы уже получили)
				' получим из атрибутов пункта меню ключи в словаре m_objectsToCheck, указывающие объекты от которых зависят права на операцию
				sRequiredRights = oNode.getAttribute("required-rights")
				' Примечание: sRequiredRights имеет сложный формат - см. checkObjectsRights
				If Not IsNull(sRequiredRights) Then _
					sAllowAttr = checkObjectsRights( sRequiredRights, oObjectsRights )
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
			' пункт меню соответствует созданию объекта. Идентификатор болванки объекта, для которого мы проверяли права, 
			' храниться в атрибуте create-oid, а атрибуте create-type - тип создаваемого объекта.
			sNewObjectID	= oNode.getAttribute("create-oid")
			sNewObjectType	= oNode.getAttribute("create-type") 
			If Not IsNull(sNewObjectID) And Not IsNull(sNewObjectType) Then
				' По полученным из атрибутов типу и идентификатору найдем экземпляр XObjectRightsDescr в oObjectsRights и поместим его в кэш прав
				' Права на создание объекта либо были получены с сервена - тогда они будут в oObjectsRights.Item(sNewObjectType& ":" & sNewObjectID),
				' либо были найдены в кэше XRightsCache - в этом случае помещать их туда еще раз уже не надо
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
		    'Расщепляем строку содержащую выражение необходимых прав на объект в формате:<Тип объекта>:<Идентификатор>:<Действие над объектом>
		    'Получаем массив из трех элементов - aCheckExprs.
			aCheckExprs = Split(sCheckExpr, ":")
			If UBound(aCheckExprs) <2 Then Err.Raise -1, "checkObjectsRights", "Некорректный формат: " & sCheckExpr
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
					' для этого действия должно быть задано наименование свойства
					sPropName = aCheckExprs(3)
					If oRightsDescr.m_bDenyChange = False Then
						' запрета на именение всего объекта нет
						If IsNull(oRightsDescr.m_aReadOnlyProps) Then
							bAllow = True
						Else
							' список read-only свойств задан
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
