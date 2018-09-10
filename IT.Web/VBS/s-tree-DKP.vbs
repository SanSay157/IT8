Option Explicit
Dim g_bIsSearchingInProgress		' признак активной операции поиска инцидента

'==============================================================================
' Обработчик события "Load" - загрузка страницы
' Обрабатывает параметры LocateIncidentByID и LocateFolderByID, содержащие идентификаторы инцидента и папки соответственно, 
' которые требуется открыть в дереве.
Sub usrXTree_OnLoad(oSender, oEventArgs)
    Dim oTreeView
   	Dim sIncidentID			' As Guid - идентификатор инцидента
	Dim sFolderID			' As Guid - идентификатор папки
	Dim oResponse			' As XResonse - ответ серверной операции
	Dim oDragDropMenuMetadata
    

	If oSender.QueryString.IsExists("LocateIncidentByID") Then
		sIncidentID = oSender.QueryString.GetValue("LocateIncidentByID", Null)
		If hasValue(sIncidentID) Then
			On Error Resume Next
			With New IncidentLocatorInTreeRequest
		        .m_sName = "IncidentLocatorInTree"
		        .m_sIncidentOID = sIncidentID
		        .m_nIncidentNumber = Null
		    Set oResponse = X_ExecuteCommand( .Self )
	        End With
			
			If Err Then
				If Not X_HandleError Then MsgBox Err.Description
			Else
				On Error Goto 0
				If Len("" & oResponse.m_sPath) > 0 Then
					oSender.m_sTreeInitPath = oResponse.m_sPath
				End If
			End If
		End If
	ElseIf oSender.QueryString.IsExists("LocateFolderByID") Then
		sFolderID = oSender.QueryString.GetValue("LocateFolderByID", Null)
		If hasValue(sFolderID) Then
			On Error Resume Next
			With New FolderLocatorInTreeRequest
		        .m_sName = "FolderLocatorInTree"
		        .m_sFolderOID = sFolderID
		    Set oResponse = X_ExecuteCommand( .Self )
	        End With
			If Err Then
				If Not X_HandleError Then MsgBox Err.Description
			Else
			 	On Error Goto 0
				If Len("" & oResponse.m_sPath) > 0 Then
					oSender.m_sTreeInitPath = oResponse.m_sPath
				End If
			End If
		End If
	End If
End Sub


'==============================================================================
' Обработчик события "SetInitPath" - установка пути дерева при открытии страницы на основании параметра INITPATH
Sub usrXTree_OnSetInitPath(oSender, oEventArgs)
	Dim sPath
	
	' если задан путь на который надо встать, то
	If Len("" & oSender.m_sTreeInitPath) > 0 Then
		LocateNodeInDKPTree oSender.m_sTreeInitPath, Null, Null
	Else
		' иначе восстановим путь из кэша
		If X_GetViewStateCache( "XT.TreeMain.Path", sPath) Then
			oSender.TreeView.SetNearestPath sPath, false, true
		End If
	End If
End Sub


'==============================================================================
' Сохраняет путь до выбранного узла в кэш
Sub usrXTree_OnUnLoad(oSender, oEventArgs)
	Dim oNode
	Set oNode = oSender.TreeView.ActiveNode 
	If Not oNode Is Nothing Then
		X_SaveViewStateCache "XT.TreeMain.Path", oNode.Path
	End If
End Sub


'==============================================================================
' ExecutionHandler меню узлов типа Organization (Организация)
Sub DKP_OrganizationMenu_ExecutionHandler(oSender, oEventArg)
	Dim oActiveNode

	Set oActiveNode = oSender.TreeView.ActiveNode
	Select Case oEventArg.Action
		Case "DoRunReport"
			X_RunReport oEventArg.Menu.Macros.Item("ReportName"), oEventArg.Menu.Macros.Item("UrlParams")
	End Select
End Sub

'==============================================================================
' ExecutionHandler меню узлов типа Organization (Организация)
Sub DKP_ContractMenu_ExecutionHandler(oSender, oEventArg)
	Dim oActiveNode
	
    Set oActiveNode = oSender.TreeView.ActiveNode
	Select Case oEventArg.Action
		Case "DoRunReport"
			X_RunReport oEventArg.Menu.Macros.Item("ReportName"), oEventArg.Menu.Macros.Item("UrlParams")
	End Select
End Sub

Sub DKP_ContractLevel_ExecutionHandler(oSender, oEventArg)
    'Alert "ContractLevel execution handler!!"
End Sub
'==============================================================================
' ExecutionHandler меню узлов типа Folder (Папка) и Incident (Инцидент)
Sub DKP_FolderMenu_ExecutionHandler(oSender, oEventArg)
	Dim oActiveNode
	Dim sPath
	Dim sFolderPath
	Dim sObjectID
	Dim sTitle
	Dim aNodes
	Dim oNode
	Dim vRet
	
	Set oActiveNode = oSender.TreeView.ActiveNode
	Select Case oEventArg.Action
		Case "DoMoveIncidents"
		    DisableAllControls oSender, True
			DoMoveIncidents oSender, oActiveNode
		    DisableAllControls oSender, False
	    Case "DoCopyFolderStructure"
	        vRet = X_OpenObjectEditor ( _
	            "CopyFolderStructureOperation", _
	            Null, "CopyFolderStructureWizard", ".Source=" & oEventArg.Menu.Macros.Item("ObjectID"))
	        If HasValue(vRet) Then
	            aNodes = oSender.TreeView.FindAnyNode("Folder", vRet)
			    If UBound(aNodes) > -1 Then
				    For Each oNode In aNodes
					    oNode.Reload
				    Next
			    End If
			End If
		Case "DoMoveIncident"
		    DisableAllControls oSender, True
			DoMoveIncident oSender, oActiveNode
		    DisableAllControls oSender, False
		Case "DoMoveFolder"
		    DisableAllControls oSender, True
			DoMoveFolder oSender, oActiveNode
		    DisableAllControls oSender, False
		Case "DoRunReport"
			X_RunReport oEventArg.Menu.Macros.Item("ReportName"), oEventArg.Menu.Macros.Item("UrlParams")
		Case "DoNavigate"
			sPath = oEventArg.Menu.Macros.Item("Path")
			If Not hasValue(sPath) Then
				Alert "Загрузчик меню не сформировал параметр Path - путь до узла"
				Exit Sub
			End If
			LocateNodeInDKPTree sPath, Null, Null
		Case "DoAddFavorite"
			sObjectID = oEventArg.Menu.Macros.Item("ObjectID")
			sFolderPath = GetScalarValueFromDataSource( "GetFolderPath", Array("FolderID"), Array(sObjectID) )
			sTitle = "CROC.IT - Клиенты и Проекты - " & Replace(sFolderPath, "\", "+")
			window.external.AddFavorite XService.BaseURL & "x-tree.aspx?METANAME=Main&LocateFolderByID=" + sObjectID, sTitle
		Case "DoCopyFolderPathToClipboard"
			sObjectID = oEventArg.Menu.Macros.Item("ObjectID")
			sFolderPath = GetScalarValueFromDataSource( "GetFolderPath", Array("FolderID"), Array(sObjectID) )
			window.clipboardData.setData "Text", sFolderPath
		Case "DoCopyFolderLinkToClipboard"
			window.clipboardData.setData "Text", XService.BaseURL & "x-tree.aspx?METANAME=Main&LocateFolderByID=" + oEventArg.Menu.Macros.Item("ObjectID")
		Case "DoCopyIncidentLinkToClipboard"
			window.clipboardData.setData "Text", XService.BaseURL & "x-tree.aspx?METANAME=Main&LocateIncidentByID=" + oEventArg.Menu.Macros.Item("ObjectID")
		Case "DoCopyIncidentViewLinkToClipboard"
			window.clipboardData.setData "Text", XService.BaseURL & "x-get-report.aspx?name=r-Incident.xml&DontCacheXslfo=true&IncidentID=" + oEventArg.Menu.Macros.Item("ObjectID")
		
	End Select
End Sub

'==============================================================================
' Получение "сокращенного" перечня текущих ограничений фильтра - без указания 
'	перечня направлений. Используется для инициализации "простых" фильтров 
'	диалогов выбора папки, при переносе папки / инцидента / инцидентов
Function GetRestrictionsForFolderSelector()
	With new QueryStringClass
		.QueryString = GetRestrictions()
		.Remove "Directions"
		GetRestrictionsForFolderSelector = Replace( .QueryString, "&", "&." )
		If hasValue(GetRestrictionsForFolderSelector) Then
			GetRestrictionsForFolderSelector = "." & GetRestrictionsForFolderSelector
		End If
	End With
End Function


'==============================================================================
'	[in] oXTreePage As XTreePageClass
'	[in] oActiveNode As IXTreeNode - узел папки (Folder)
Sub DoMoveIncidents(oXTreePage, oActiveNode)
	Dim aIncidentIDs 	' As Guid() - массив идентификаторов выбранных инцидентов
	Dim vResult
	Dim bWasExpanded	' As Boolean - признак того, что узел папки был раскрыть до перегрузки
	Dim sFolderID		' As Guid - Идентификатор папки
	Dim oFolder			' As IXTreeNode
	Dim bWasLeaf
	Dim oMoveObjectsRequest
	sFolderID = oActiveNode.ID
	' 1. Откроем диалог выбора инцидентов в выбранном проекте
	aIncidentIDs = X_SelectFromList("IncidentsSelectorForMove", "Incident", LM_MULTIPLE, "Folder=" & sFolderID, Null)
	' 2. Если что-то выбрали, откроем диалог выбора папки назначения
	Set oMoveObjectsRequest = New MoveObjectsRequest
	If Not IsEmpty(aIncidentIDs) Then
		With New SelectFromTreeDialogClass
			.Metaname = "FolderSelector"
			.InitialPath = oActiveNode.Path
			.UrlArguments.QueryString = GetRestrictionsForFolderSelector()
			.SelectionMode = TSM_ANYNODE
			.SelectableTypes = "Folder"
			.ReturnValue = SelectFromTreeDialogClass_Show(.Self())
			If .ReturnValue Then
			    oMoveObjectsRequest.m_sName = "MoveObjects"
			    oMoveObjectsRequest.m_sSessionID =  Null
		        oMoveObjectsRequest.m_sSelectedObjectType = "Incident"
		        oMoveObjectsRequest.m_aSelectedObjectsID = aIncidentIDs
		        oMoveObjectsRequest.m_sNewParent = .Selection.selectSingleNode("n").getAttribute("id")
		        oMoveObjectsRequest.m_sParentPropName = "Folder"
		        oMoveObjectsRequest.m_sSubTreeSelectorPropName = Empty
				Set vResult = X_ExecuteCommandSafe( oMoveObjectsRequest )
				If hasValue(vResult) Then
					' TODO: вообще-то обновлять состояния надо не всех вышестоящих, а только до общего нового родителя (если есть), но это сложно
					If oActiveNode.Expanded Then
						' если узел был раскрыт, перегрузим его детей
						UpdateParentFolders oXTreePage.TreeView, oActiveNode
						oActiveNode.Children.Reload
					Else
						' иначе просто перегрузим узел, т.к. мог измениться признак листового узла
						If Not oActiveNode.Parent Is Nothing Then
							UpdateParentFolders oXTreePage.TreeView, oActiveNode.Parent
						End If
						oActiveNode.Reload True
					End If
					' перейдем в дереве на выбранную папку
					Set oFolder = LocateNodeInDKPTree( .Path, "Folder", Null )
					If Not oFolder Is Nothing Then
						bWasExpanded = oFolder.Expanded
						' Примечание: на самом деле узел oFolder уже мог быть перегружен в результате предыдущего обновления, 
						' поэтому проверять IsLeaf поздно. 
						' Выражается это так: когда переносим инциденты в подчиненный листовой узел, то он не разворачивается.
						' 
						bWasLeaf = oFolder.IsLeaf
						' TODO: вообще-то обновлять состояния надо не всех вышестоящих, а только до общего нового родителя (если есть), но это сложно
						If Not oFolder.Parent Is Nothing Then
							UpdateParentFolders oXTreePage.TreeView, oFolder.Parent
						End If
						' перегрузим ее
						oFolder.Reload
						' и если она была открыта - перегрузим ее детей
						If bWasExpanded Then
							oFolder.Children.Reload
						ElseIf bWasLeaf Then
							' т.к. узел раньше был листовой, то это вызовет загрузку детей
							oFolder.Expanded = True
						End If
					End If
				End If
			End If
		End With
	End If
End Sub


'==============================================================================
' Перенос инцидента
'	[in] oXTreePage As XTreePageClass
'	[in] oActiveNode As IXTreeNode - узел инцидента (Incident)
Sub DoMoveIncident(oXTreePage, oMovingNode)
	Dim oResponse				' As XResonse - ответ серверной операции
	Dim aSelection				' As Variant() - результат отбора из дерева
	Dim sParentObjectType 		' As String - тип узла, выбранного как родительский
	Dim sParentObjectID			' As Guid - идентификатор узла, выбранного как родительский
	Dim sIncidentID				' As Guid - идентификатор перемещаемого инцидента
	Dim oMoveObjectRequest
	
	sIncidentID = oMovingNode.ID
	' Покажем дерево для выбора нового родителя и получим выбранное значение
	With New SelectFromTreeDialogClass
		.Metaname = "FolderSelector"
		.InitialPath = oMovingNode.Path
		.UrlArguments.QueryString = GetRestrictionsForFolderSelector()
		.SelectionMode = TSM_ANYNODE
		.SelectableTypes = "Folder"
		.ReturnValue = SelectFromTreeDialogClass_Show(.Self())
		If .ReturnValue Then
			' получим тип и идентификатор объекта, выбранного как родитель
			aSelection = Split(.Path, "|")
			sParentObjectType = aSelection(0)
			sParentObjectID	= aSelection(1)
			If sParentObjectType <> "Folder" Then X_ErrReportEx "Родительским узлом для инцидента может быть только папка", "DoMoveIncident"
			Set oMoveObjectRequest =  new MoveObjectsRequest 
			oMoveObjectRequest.m_sName = "MoveObjects"
		    oMoveObjectRequest.m_sSessionID = Null
		    oMoveObjectRequest.m_sSelectedObjectType = "Incident"
		    oMoveObjectRequest.m_aSelectedObjectsID = Array(sIncidentID)
		    oMoveObjectRequest.m_sNewParent = sParentObjectID
		    oMoveObjectRequest.m_sParentPropName = "Folder"
		    oMoveObjectRequest.m_sSubTreeSelectorPropName = Empty	
			Set oResponse = X_ExecuteCommandSafe(oMoveObjectRequest)
			If hasValue(oResponse) Then
				' папка успешно перенесена - обновим дерево
				'UpdateTreeStateAfterNodeMove oXTreePage, oMovingNode, .Path
				'LocateNodeInDKPTree "Incident|" & sIncidentID & "|" & .Path, "Incident", sIncidentID
				PostMove oXTreePage.TreeView, oMovingNode.Path, .Path
			End If
		End If
	End With
End Sub


'==============================================================================
' Переносит Папку
Sub DoMoveFolder(oTreePage, oMovingNode)
	Dim sObjectID				' идентификатор
	Dim aSelection				' результат отбора из дерева
	Dim sUrlArguments			' параметры, передаваемые через урл в диагол выбора из дерева
	Dim nFolderType				' тип папки
	Dim sParentObjectType 		' тип узла, выбранного как родительский
	Dim sParentObjectID			' идентификатор узла, выбранного как родительский
	Dim sOrganizationID 		' идентификатор Организации
	Dim sActivityTypeID			' идентификатор типа проектных затрат (ActivityType)
	Dim oResponse				' As XResonse - ответ серверной операции
	Dim i
	Dim oMoveFolderRequest
	Dim sFolderDirectionDiff
	Dim vRet
	nFolderType = CLng(oMovingNode.ApplicationData.selectSingleNode("ud/FolderType").text)
	sObjectID = oMovingNode.ID
	' Покажем дерево для выбора нового родителя и получим выбранное значение
	With New SelectFromTreeDialogClass
		.Metaname = "SelectorForFolderMove"
		.InitialPath = oMovingNode.Path
		.UrlArguments.QueryString = "EXCLUDE=Folder|" & sObjectID & "&" & GetRestrictionsForFolderSelector() 
		.SelectionMode = TSM_ANYNODE
		' Если переносимая папка - каталог, то родителем может быть только папка
		If nFolderType = FOLDERTYPEENUM_DIRECTORY Then
			.SelectableTypes = "Folder"
		' .. тендер и пресейл можно переносить только на корневой уровень
		ElseIf nFolderType = FOLDERTYPEENUM_TENDER OR nFolderType = FOLDERTYPEENUM_PRESALE Then
			.SelectableTypes = "Organization ActivityType ActivityTypeInternal"
		' иначе и папка, и организация, и тип проектных затрат
		Else
			.SelectableTypes = "Folder Organization ActivityType ActivityTypeInternal"
		End If
		.ReturnValue = SelectFromTreeDialogClass_Show(.Self())
		If .ReturnValue Then
			' получим тип и идентификатор объекта, выбранного как родитель
			aSelection = Split(.Path, "|")
			sParentObjectType = aSelection(0)
			sParentObjectID	= aSelection(1)
			' проверяю, не является ли новый парент самим узлом или его чилдом
			If 0<>InStr(1,"|" & .Path & "|" , "|Folder|" & sObjectID & "|") Then
				MsgBox "Папка не может быть перенесена в одну из своих дочерних папок", vbExclamation, "Предупреждение"
				Exit Sub
			End If
			' Проверим, соответствуют ли направления переносимой папки направлениям родительской
			sFolderDirectionDiff = GetScalarValueFromDataSource("GetFirstFolderDirectionDifference-ForChildFolder", _
			                                Array("FolderID","ParentID"), Array(sObjectID,sParentObjectID))
		    If hasValue(sFolderDirectionDiff) Then
			    vRet = MsgBox ("Внимание! Переносимая активность/папка имеет направления, которых нет в указанной активности/папки."& vbCrLf & _
			     "Эти направления будут удалены у переносимой активности/папки." & vbCrLf & _
		        "Продолжить?", vbYesNo+vbExclamation, "Внимание!") 
		        If ( vbNo = vRet ) Then Exit Sub
		    End If
			
			' выполним перенос с помощью серверной команды MoveFolder
			Set oMoveFolderRequest = new MoveFolderRequest
			
			If sParentObjectType = "Folder" Then	
			    oMoveFolderRequest.m_sName = "MoveFolder"
		        oMoveFolderRequest.m_sSessionID = Null
		        oMoveFolderRequest.m_aObjectsID = Array(sObjectID)
		        oMoveFolderRequest.m_sNewParent = sParentObjectID
		        oMoveFolderRequest.m_sNewCustomer = Null
		        oMoveFolderRequest.m_sNewActivityType = Null
				Set oResponse = X_ExecuteCommandSafe(oMoveFolderRequest)                  		
			Else			
				' Если выбрали организацию, то подразумевается, что тип проектных затрат остается прежним, однако
				' такое возможно только при переносе между организациями-клиентами
				If sParentObjectType = "Organization" Then
					' TODO: если выбрали организацию под типом проектных затрат в отношении клиента под Кроком, то надо обыгрывать изменение ActivityType
					sOrganizationID = sParentObjectID
					sActivityTypeID = Null
					For i=0 To UBound(aSelection)-1 Step 2
						If aSelection(i) = "ActivityTypeExternal" Then
							sActivityTypeID = aSelection(i+1)
							Exit For
						End If
					Next
				Else
					' если выбрали тип проектных затрат, то необходимо вычислить ссылку на организацию-клиента. она всегда будет выше по пути
					For i=0 To UBound(aSelection)-1 Step 2
						If aSelection(i) = "Organization" Or aSelection(i) = "HomeOrganization" Then
							sOrganizationID = aSelection(i+1)
							Exit For
						End If
					Next			
					sActivityTypeID = sParentObjectID
				End If
				oMoveFolderRequest.m_sName = "MoveFolder"
		        oMoveFolderRequest.m_sSessionID = Null
		        oMoveFolderRequest.m_aObjectsID = Array(sObjectID)
		        oMoveFolderRequest.m_sNewParent = Null
		        oMoveFolderRequest.m_sNewCustomer = sOrganizationID
		        oMoveFolderRequest.m_sNewActivityType = sActivityTypeID
				Set oResponse = X_ExecuteCommandSafe(oMoveFolderRequest)
			End If
			If hasValue(oResponse) Then
				' папка успешно перенесена - обновим дерево
				'UpdateTreeStateAfterNodeMove oTreePage, oMovingNode, .Path
				PostMove oTreePage.TreeView, oMovingNode.Path, .Path				
			End If
		End If
	End With
End Sub


'==============================================================================
' Находит в дереве узел соответсвующий пути. 
' Если текущий режим дерева не позволяет его найти, то дерево перегружается в режим "Организации со всеми активностями" -
' в этом режиме можно найти все
'	[in] sPath - путь до нужного узла (required)
'	[in] sType - тип искомого узла (optional)
'	[in] sObjectID - идентификатор искомого узла (optional)
'	[retval] Возвращает IXTreeNode найденного узла или Nothing
Function LocateNodeInDKPTree(sPath, sType, sObjectID)
	Dim bNeedRepeatSearch		' As Boolean - признак необходимости повторить поиск
	Dim aPathParts				' As Variant() - массив частей пути дерева sPath
	Dim oTreeView
	Set LocateNodeInDKPTree = Nothing
	If Not hasValue(sPath) Then Exit Function
	If g_bIsSearchingInProgress=True Then
		Alert "Необходимо дождать окончания загрузки дерева"
		Exit Function
	End If
	g_bIsSearchingInProgress = True
	Set oTreeView = document.all("oTreeView")
	oTreeView.SetNearestPath sPath, false, true
	' если тип или идентификатор искомого узла не заданы, то получим их из пути (они идут 1-ой парой)
	If Not hasValue(sObjectID) Or Not hasValue(sType) Then
		aPathParts = Split(sPath, "|")
		If UBound(aPathParts) < 1 Then g_bIsSearchingInProgress=False : Exit Function
		sType = aPathParts(0)
		sObjectID = aPathParts(1)
	End If

	bNeedRepeatSearch = Not CheckActiveNode(oTreeView, sType, sObjectID)

	' инцидент в БД есть, но текущий режим дерева не позволяет его отобразить - 
	' надо изменить режим дерева на такой, чтобы искомый инцидент можно было в нем показать - 
	' это режим с выключенным признаком "только мои активности"
	If bNeedRepeatSearch Then
		' ВНИМАНИЕ: HACK :( Напрямую лезем в редактор фильтр, в его xml-объект и меняем ему свойствa
		With FilterObject().ObjectEditor
		    .Pool.BeginTransaction True
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "Mode"), DKPTREEMODES_ORGANIZATIONS
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "OnlyOwnActivity"), False
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "ShowOrgWithoutActivities"), False
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "IncidentViewMode"), INCIDENTVIEWMODES_ALL
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "OrganizationName"), ""
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "FolderName"), ""
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "FolderState"), 0
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "ActivityState"), 0
		    .Pool.SetPropertyValue .Pool.GetXmlProperty(.XmlObject, "ActivityTypes"), 0
		    .Pool.RemoveAllRelations .XmlObject, "Directions"
		    Reload
		    oTreeView.SetNearestPath sPath, false, true
		    .Pool.RollBackTransaction
		End With
		If Not CheckActiveNode(oTreeView, sType, sObjectID) Then
			MsgBox "Не удалось открыть " & iif (sType = "Incident", "инцидент", "папку") & " в дереве из-за нехватки прав", vbInformation + vbOkOnly, "Поиск инцидента"
		Else
			Set LocateNodeInDKPTree = oTreeView.ActiveNode
		End If
	Else
		Set LocateNodeInDKPTree = oTreeView.ActiveNode
	End If
	g_bIsSearchingInProgress = False
End Function


Dim g_oXmlBackUpFilterDKPState		' временное состояние фильтра

'==============================================================================
' Делает бекап состояния фильтра
' Использует g_oXmlBackUpFilterDKPState
Sub backUpFilterDKPState(oXmlObject)
	Set	g_oXmlBackUpFilterDKPState = oXmlObject.cloneNode(true)
End Sub

'==============================================================================
' Восстанавливает состояние фильтра из бекапа
' Использует g_oXmlBackUpFilterDKPState
Sub restoreFilterDKPState(oXmlObject)
	oXmlObject.selectSingleNode("Mode").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("Mode").nodeTypedValue
	oXmlObject.selectSingleNode("ActivityTypes").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("ActivityTypes").nodeTypedValue
	'oXmlObject.selectSingleNode("OnlyOpenActivity").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("OnlyOpenActivity").nodeTypedValue
	oXmlObject.selectSingleNode("OnlyOwnActivity").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("OnlyOwnActivity").nodeTypedValue
	oXmlObject.selectSingleNode("ShowOrgWithoutActivities").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("ShowOrgWithoutActivities").nodeTypedValue
	oXmlObject.selectSingleNode("IncidentViewMode").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("IncidentViewMode").nodeTypedValue
	oXmlObject.selectSingleNode("IncidentSortOrder").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("IncidentSortOrder").nodeTypedValue
	oXmlObject.selectSingleNode("IncidentSortMode").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("IncidentSortMode").nodeTypedValue
	oXmlObject.selectSingleNode("OrganizationName").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("OrganizationName").nodeTypedValue
	oXmlObject.selectSingleNode("FolderName").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("FolderName").nodeTypedValue
	oXmlObject.selectSingleNode("ShowTasks").nodeTypedValue = g_oXmlBackUpFilterDKPState.selectSingleNode("ShowTasks").nodeTypedValue
End Sub


'==============================================================================
' обработчик события OnBeforeEdit
'	[in] oEventArg As DeleteObjectArgsClass
Sub usrXTree_OnBeforeEdit( oXTreePage, oEventArg )
	' запомним текущий узел
	Set oEventArg.AddEventArgs = oXTreePage.TreeView.ActiveNode
End Sub


'==============================================================================
' обработчик события OnAfterEdit
'	[in] oEventArg As CommonEventArgsClass
Sub usrXTree_OnAfterEdit(oXTreePage, oEventArg)
	Dim oDict 	' As Scripting.Dictionary
	Dim aValues
	Dim aFields
	
	' ReturnValue говорит об успехе
	' ObjectID - идентификатор объекта
	If oEventArg.ReturnValue Then
		If oEventArg.ObjectType = "Incident" Then
			' после редактирования инцидента обновим его и вышестоящие папки
			UpdateParentFolders oXTreePage.TreeView, oEventArg.AddEventArgs
		ElseIf oEventArg.ObjectType = "Folder" Then
			' после редактирования папки обновим ее и все видимые нижестоящие папки
			Set oDict = CreateObject("Scripting.Dictionary")
			CollectChildFoldersID oEventArg.AddEventArgs, oDict
			aValues = GetValuesFromDataSource("GetFoldersInfo", Array("FolderID", "ShowWorkProgress"), Array(oDict.Keys(), 1))
			' 0 - ObjectID папки
			' 1 - наименование узла
			' 2 - селектор икoнки
			For Each aFields In aValues
				oDict.item(aFields(0)) = Array(aFields(1), aFields(2))
			Next
			ApplyChildFoldersState oXTreePage.TreeView, oEventArg.AddEventArgs, oDict
		Else
			oXTreePage.RefreshCurrentNode Eval(oEventArg.Values.Item("RefreshFlags"))
		End If
		oXTreePage.ShowMenu()			
	End If
End Sub


'==============================================================================
' обработчик события OnBeforeCreate
'	[in] oEventArg As DeleteObjectArgsClass
Sub usrXTree_OnBeforeCreate( oXTreePage, oEventArg )
	' запомним текущий узел
	Set oEventArg.AddEventArgs = oXTreePage.TreeView.ActiveNode
End Sub


'==============================================================================
' обработчик события OnAfterCreate
'	[in] oEventArg As CommonEventArgsClass
Sub usrXTree_OnAfterCreate(oXTreePage, oEventArg)
	Dim oResponse		' ответ серверной операции
	Dim sIncidentID
	Dim oNode
	
	' ReturnValue говорит об успехе
	' ObjectID - идентификатор объекта
	If Not IsEmpty(oEventArg.ReturnValue) Then
		If oEventArg.ObjectType = "Incident" Then
			' Создание инцидента
			sIncidentID = oEventArg.ReturnValue
			If oEventArg.Metaname = "WizardWithSelectFolder" Then
				' Создание инцидента с выбором папки. Найдем инцидент в дереве по идентификатору
				On Error Resume Next
				With New IncidentLocatorInTreeRequest
		            .m_sName = "IncidentLocatorInTree"
		            .m_sIncidentOID = sIncidentID
		            .m_nIncidentNumber = Null
		            Set oResponse = X_ExecuteCommand( .Self )
	            End With
				If Err Then
					If Not X_HandleError Then MsgBox Err.Description
				Else
					On Error Goto 0
					Set oNode = LocateNodeInDKPTree( oResponse.m_sPath, "Incident", sIncidentID)
					If Not oNode Is Nothing Then
						UpdateParentFolders oXTreePage.TreeView, oNode.Parent
					End If
				End If
			Else
				' Создание инцидента относительно текущего узла: папки - под ней, инцидента - рядом, под той же папкой
				If oEventArg.AddEventArgs.Type = "Folder" Then
					' Создание инцидента в текущей папке - в oEventArg.AddEventArgs идентификатор папки
					UpdateParentFolders oXTreePage.TreeView, oEventArg.AddEventArgs
					oEventArg.AddEventArgs.Children.Reload
				ElseIf oEventArg.AddEventArgs.Type = "Incident" Then
					' Создание инцидента в той же папке, что и текущий инцидент - в oEventArg.AddEventArgs идентификатор выбранного инцидента
					UpdateParentFolders oXTreePage.TreeView, oEventArg.AddEventArgs.Parent
					oEventArg.AddEventArgs.Parent.Children.Reload
				End If
			End If
		Else
			oXTreePage.RefreshCurrentNode Eval(oEventArg.Values.Item("RefreshFlags"))
		End If
		oXTreePage.ShowMenu()			
	End If
End Sub


'==============================================================================
' обработчик события OnAfterDelete
' В AddEventArgs IXTreeNode удаляемого узла.
'	[in] oEventArg As DeleteObjectArgsClass
Sub usrXTree_OnAfterDelete( oXTreePage, oEventArg )
    Dim oParentNode		' родитель удаляемого узла
    
    If oEventArg.ObjectType = "Incident" Then
		If oEventArg.ReturnValue And oEventArg.Count > 0 Then
			Set oParentNode = oEventArg.AddEventArgs.Parent
			oEventArg.AddEventArgs.Remove
			If Not oParentNode Is Nothing Then
				UpdateParentFolders oXTreePage.TreeView, oParentNode
			End If
			oXTreePage.ShowMenu
		End If
    Else
		stdXTree_OnAfterDelete oXTreePage, oEventArg
	End If
End Sub


'==============================================================================
' Собирает идентификаторы папок, подчиненных заданному узлы. Рекурсия!
'	[in] oFolderNode As IXTreeNode - узел папки
'	[in] oDict As Scripting.Dictionary - словарь с идентификаторами
Sub CollectChildFoldersID(oFolderNode, oDict)
	Dim oNode
	Dim i
	oDict.Add oFolderNode.ID, Null
	If oFolderNode.Expanded Then
		For i=0 To oFolderNode.Children.Count - 1
			Set oNode = oFolderNode.Children.GetNode(i)
			If oNode.Type = "Folder" Then
				CollectChildFoldersID oNode, oDict
			End If
		Next
	End If
End Sub


'==============================================================================
' Обновляет узлы рекурсивно относительно заданного. 
'	[in] oTreeView As IXTreeView
'	[in] oFolderNode As IXTreeNode - текущий узел
'	[in] oDict As Scripting.Dictionary - ключ - идентификатор узла, значение - массив (наименование узла, селектор иконки)
Sub ApplyChildFoldersState(oTreeView, oFolderNode, oDict)
	Dim oNode
	Dim i
	Dim aValues

	If oDict.Exists(oFolderNode.ID) Then
		aValues = oDict.item(oFolderNode.ID)
		If IsArray(aValues) Then
			oFolderNode.Text = aValues(0)
			oFolderNode.IconUrl = oTreeView.XImageList.MakeIconUrl(oFolderNode.Type, "", aValues(1))
		End If
	End If
	If oFolderNode.Expanded Then
		For i=0 To oFolderNode.Children.Count - 1
			Set oNode = oFolderNode.Children.GetNode(i)
			If oNode.Type = "Folder" Then
				ApplyChildFoldersState oTreeView, oNode, oDict
			End If
		Next
	End If
End Sub


'==============================================================================
' Обновляет узлы папок над заданным узлом
'	[in] oTreeView As IXTreeView
' 	[in] oActiveNode - текущий узел, начиная с которого вверх требуется обновить узла (это либо Folder, либо Incident)
Sub UpdateParentFolders(oTreeView, oActiveNode)
	Dim aParamNames 	' массив наименований параметров источника данных
	Dim oCurrentNode	' As IXTreeNode - обновляемый узел
	Dim aValues			' массив с описанием папок в той же последовательности как они располагаются в дереве
						' Значение элемента массива - массив с значениями колонок одной строка источника данных GetParentFoldersInfo:
						' 0 - идентификатор (инцидента, папки)
						' 1 - наименование узла
						' 2 - селектор иконки
	Dim nIndex			' индекс в массиве aValues значения, соответствующего текущему узлу
	Dim oParent			' As IXTreeNode
	
	If oActiveNode Is Nothing Then 
		Exit Sub
	End If
	If oActiveNode.Type = "Incident" Then
		aParamNames = Array("IncidentID", "ShowWorkProgress")
	Else
		aParamNames = Array("FolderID", "ShowWorkProgress")
	End If
	
	Set oCurrentNode = oActiveNode
	aValues = GetValuesFromDataSource("GetParentFoldersInfo", aParamNames, Array(oActiveNode.ID, 1))
	nIndex = 0
	While Not oCurrentNode Is Nothing
		If oCurrentNode.Type <> "Folder" And oCurrentNode.Type <> "Incident" Then Exit Sub
		If oCurrentNode.ID <> aValues(nIndex)(0) Then 
			' идентификатор текущего узла в дереве не совпал с идентификатор папки, которая находится в данном месте иерархии в БД
			' Это возможно из-за того, что структура дерева на клиенте устарела (кто-то куда-то что-то перенес)
			' Обновим вышестоящие узлы папок "дедовским" способом
			While Not oCurrentNode Is Nothing
				Set oParent = oCurrentNode.Parent
				oCurrentNode.Reload
				Set oCurrentNode = oParent
			Wend
			Exit Sub
		End If
		oCurrentNode.Text = aValues(nIndex)(1)
		oCurrentNode.IconUrl = oTreeView.XImageList.MakeIconUrl(oCurrentNode.Type, "", aValues(nIndex)(2))
		Set oCurrentNode = oCurrentNode.Parent
		nIndex = nIndex + 1
	Wend
End Sub

' Обработчик начала операции переноса
Sub FolderCanDragHandler(oSender, oEventArgs)
    If oEventArgs.CanDrag Then
        If Not(HasValue(GetTreeMenuForActiveNode(oSender).SelectSingleNode("i:menu-item[@action='DoMoveFolder']"))) Then
            oEventArgs.CanDrag = False
        End If
    End If
End Sub

' Обработчик начала операции переноса
Sub IncidentCanDragHandler(oSender, oEventArgs)
    If oEventArgs.CanDrag Then
        If Not(HasValue(GetTreeMenuForActiveNode(oSender).SelectSingleNode("i:menu-item[@action='DoMoveIncident']"))) Then
            oEventArgs.CanDrag = False
        End If
    End If
End Sub

' Обработчик проноса выбранного узла над другим узлом
Sub FolderCanDropHandler(oSender, oEventArgs)
    Dim nFolderType
    If oEventArgs.CanDrop Then
        nFolderType = CLng(oEventArgs.SourceNode.ApplicationData.selectSingleNode("ud/FolderType").text)
        ' Если переносимая папка - каталог, то родителем может быть только папка
        If nFolderType = FOLDERTYPEENUM_DIRECTORY Then
	        If oEventArgs.TargetNode.Type = "Folder" Then
                If 0<>InStr(1,"|" & oEventArgs.TargetNode.Path & "|" , "|Folder|" & oEventArgs.SourceNode.ID & "|") Then
                    oEventArgs.CanDrop = False
                    oEventArgs.Cancel = True
                End If
            Else
	            oEventArgs.CanDrop = False
	        End If
        ' .. тендер и пресейл можно переносить только на корневой уровень
        ElseIf nFolderType = FOLDERTYPEENUM_TENDER OR nFolderType = FOLDERTYPEENUM_PRESALE Then
	        If oEventArgs.TargetNode.Type <> "Organization" And oEventArgs.TargetNode.Type <> "ActivityType" And oEventArgs.TargetNode.Type <> "ActivityTypeInternal" Then
	            oEventArgs.CanDrop = False
	        End If
        ' иначе и папка, и организация, и тип проектных затрат
        Else
            If oEventArgs.TargetNode.Type = "Folder" Then
                If 0<>InStr(1,"|" & oEventArgs.TargetNode.Path & "|" , "|Folder|" & oEventArgs.SourceNode.ID & "|") Then
                    oEventArgs.CanDrop = False
                End If
            ElseIf oEventArgs.TargetNode.Type <> "Organization" And oEventArgs.TargetNode.Type <> "ActivityType" And oEventArgs.TargetNode.Type <> "ActivityTypeInternal" Then
	            oEventArgs.CanDrop = False
	        End If
        End If
    End If
End Sub

' Обработчик проноса выбранного узла над другим узлом
Sub IncidentCanDropHandler(oSender, oEventArgs)
    ' Переносить можно только под папку
    If oEventArgs.CanDrop Then
        If oEventArgs.TargetNode.Type <> "Folder" Then 
            oEventArgs.CanDrop = False
        End If
    End If
End Sub

Sub FolderDragDropMenuVisibilityHandler(oSender, oEventArgs)
    Dim oMenuItemNode   ' описание пункта меню
    Dim oParam          ' параметр пункта меню
    Dim bHide           ' признак того, что пункт меню надо спрятать
    Dim sParentPropName ' наименование родительского свойства
    Dim sParentPropType ' наименование типа родительского объекта
    
    ' Пройдемся по пунктам меню
    For Each oMenuItemNode In oEventArgs.ActiveMenuItems
        bHide = True
        ' Все кроме DoMove оставим как есть
        If oMenuItemNode.GetAttribute("action") = "DoMove" Then
            ' Для DoMove оставим те, у которых тип значения свойства ParentPropName совпадает с типом узла, куда "отпускаем"
            Set oParam = oMenuItemNode.SelectSingleNode("i:params/i:param[@n='ParentPropName']")
            If HasValue(oParam) Then
                sParentPropName = oParam.NodeTypedValue
                Select Case sParentPropName
                    Case "Parent"
                        If oEventArgs.Menu.Macros.Item("TargetType") = "Folder" Then bHide = False
                    Case "Customer"
                        If oEventArgs.Menu.Macros.Item("TargetType") = "Organization" Then bHide = False
                    Case "ActivityType"
                        If oEventArgs.Menu.Macros.Item("TargetType") = "ActivityType" Then bHide = False
                        If oEventArgs.Menu.Macros.Item("TargetType") = "ActivityTypeInternal" Then bHide = False
                End Select
            End If
        Else
            bHide = False
        End If
        If bHide Then
            oMenuItemNode.SetAttribute "hidden", "1"         
        End If
    Next
End Sub

' Обработчик меню переноса папок
Sub FolderDragDropMenuExecutionHandler(oSender, oEventArgs)
    Dim oResponse
    Dim oSourceParent
    Dim sSourceParentPath
    Dim sSourceID
    Dim sSourcePath
    Dim aSourcePath
    Dim sSourceType
    Dim oTarget
    Dim sTargetID
    Dim sTargetPath
    Dim aTargetPath
    Dim sTargetType
    
    If oEventArgs.Action = "DoMove" Then
    
        DisableAllControls oSender, True
    
        sSourcePath = oEventArgs.Menu.Macros.Item("NodePath")
        aSourcePath = Split(sSourcePath, "|")
        sSourceType = aSourcePath(0)
        sSourceID = aSourcePath(1)
        sSourceParentPath = Right(sSourcePath, Len(sSourcePath) - Len(sSourceType) - Len(sSourceID) - 1)
        If Len(sSourceParentPath) > 0 Then sSourceParentPath = Right(sSourceParentPath, Len(sSourceParentPath) - 1) Else sSourceParentPath = Null
        
        sTargetPath = oEventArgs.Menu.Macros.Item("NewParentPath")
        aTargetPath = Split(sTargetPath, "|")
        sTargetType = aTargetPath(0)
        sTargetID = aTargetPath(1)
        
        Dim oMoveFolderRequest
        Dim sFolderDirectionDiff
        Dim vRet
        Dim sOrganizationID
        Dim sActivityTypeID
        Dim aSelection 
        Dim i
        
        ' Проверим, соответствуют ли направления переносимой папки направлениям родительской
	    sFolderDirectionDiff = _
	        GetScalarValueFromDataSource( _
	            "GetFirstFolderDirectionDifference-ForChildFolder", _
	            Array("FolderID", "ParentID"), _
	            Array(sSourceID, sTargetID))
        If hasValue(sFolderDirectionDiff) Then
	        vRet = MsgBox ("Внимание! Переносимая активность/папка имеет направления, которых нет в указанной активности/папки."& vbCrLf & _
	         "Эти направления будут удалены у переносимой активности/папки." & vbCrLf & _
            "Продолжить?", vbYesNo+vbExclamation, "Внимание!") 
            If ( vbNo = vRet ) Then Exit Sub
        End If
    	
	    ' выполним перенос с помощью серверной команды MoveFolder
	    Set oMoveFolderRequest = new MoveFolderRequest
    	
	    If sTargetType = sSourceType Then	
	        oMoveFolderRequest.m_sName = "MoveFolder"
            oMoveFolderRequest.m_sSessionID = Null
            oMoveFolderRequest.m_aObjectsID = Array(sSourceID)
            oMoveFolderRequest.m_sNewParent = sTargetID
            oMoveFolderRequest.m_sNewCustomer = Null
            oMoveFolderRequest.m_sNewActivityType = Null   
		    Set oResponse = X_ExecuteCommandSafe(oMoveFolderRequest)                  		
	    Else			
		    ' Если выбрали организацию, то подразумевается, что тип проектных затрат остается прежним, однако
		    ' такое возможно только при переносе между организациями-клиентами
		    If sTargetType = "Organization" Then
			    ' TODO: если выбрали организацию под типом проектных затрат в отношении клиента под Кроком, то надо обыгрывать изменение ActivityType
			    sOrganizationID = sTargetID
			    sActivityTypeID = Null
			    For i=0 To UBound(aTargetPath) - 1 Step 2
				    If aTargetPath(i) = "ActivityTypeExternal" Then
					    sActivityTypeID = aTargetPath(i + 1)
					    Exit For
				    End If
			    Next
		    Else
			    ' если выбрали тип проектных затрат, то необходимо вычислить ссылку на организацию-клиента. она всегда будет выше по пути
			    For i=0 To UBound(aTargetPath) - 1 Step 2
				    If aTargetPath(i) = "Organization" Or aTargetPath(i) = "HomeOrganization" Then
					    sOrganizationID = aTargetPath(i + 1)
					    Exit For
				    End If
			    Next			
			    sActivityTypeID = sTargetID
		    End If
		    oMoveFolderRequest.m_sName = "MoveFolder"
            oMoveFolderRequest.m_sSessionID = Null
            oMoveFolderRequest.m_aObjectsID = Array(sSourceID)
            oMoveFolderRequest.m_sNewParent = Null
            oMoveFolderRequest.m_sNewCustomer = sOrganizationID
            oMoveFolderRequest.m_sNewActivityType = sActivityTypeID
            
		    Set oResponse = X_ExecuteCommandSafe(oMoveFolderRequest)
	    End If
	    If hasValue(oResponse) Then
		    ' инцидент успешно перенесен - обновим дерево
		    ' Обновим старую папку и новую папку
		    oSender.TreeView.GetNode(sSourcePath, false).Remove
    		
		    If HasValue(sSourceParentPath) Then
		        Set oSourceParent = oSender.TreeView.GetNode(sSourceParentPath, false)
	        Else 
	            Set oSourceParent = Nothing
	        End If
    	    
		    Set oTarget = oSender.TreeView.GetNode(sTargetPath, false)
    	    
		    ReloadAfterMoveSafe oSourceParent, oTarget, oSender.TreeView
    		
		    If HasValue(sSourceParentPath) Then 
		        oSender.TreeView.Path = sSourceParentPath
		    Else 
		        oSender.TreeView.Path = sSourceType & "|" & sSourceID & "|" & sTargetPath
		    End If
	    End If
	    DisableAllControls oSender, False
	End If
End Sub

' Обработчик меню переноса инцидентов
Sub IncidentDragDropMenuExecutionHandler(oSender, oEventArgs)
    Dim oResponse
    Dim oSourceParent
    Dim sSourceParentPath
    Dim sSourceID
    Dim sSourcePath
    Dim aSourcePath
    Dim sSourceType
    Dim oTarget
    Dim sTargetID
    Dim sTargetPath
    Dim aTargetPath
    Dim sTargetType
    
    If oEventArgs.Action = "DoMove" Then
        DisableAllControls oSender, True
        sSourcePath = oEventArgs.Menu.Macros.Item("NodePath")
        aSourcePath = Split(sSourcePath, "|")
        sSourceType = aSourcePath(0)
        sSourceID = aSourcePath(1)
        sSourceParentPath = Right(sSourcePath, Len(sSourcePath) - Len(sSourceType) - Len(sSourceID) - 1)
        If Len(sSourceParentPath) > 0 Then sSourceParentPath = Right(sSourceParentPath, Len(sSourceParentPath) - 1) Else sSourceParentPath = Null
        
        sTargetPath = oEventArgs.Menu.Macros.Item("NewParentPath")
        aTargetPath = Split(sTargetPath, "|")
        sTargetType = aTargetPath(0)
        sTargetID = aTargetPath(1)
        
        Dim oMoveObjectRequest
                
        Set oMoveObjectRequest =  new MoveObjectsRequest 
	    oMoveObjectRequest.m_sName = "MoveObjects"
        oMoveObjectRequest.m_sSessionID = Null
        oMoveObjectRequest.m_sSelectedObjectType = sSourceType
        oMoveObjectRequest.m_aSelectedObjectsID = Array(sSourceID)
        oMoveObjectRequest.m_sNewParent = sTargetID
        oMoveObjectRequest.m_sParentPropName = sTargetType
        oMoveObjectRequest.m_sSubTreeSelectorPropName = Empty	

        Set oResponse = X_ExecuteCommandSafe(oMoveObjectRequest)
	    If hasValue(oResponse) Then
		    ' инцидент успешно перенесен - обновим дерево
		    ' Обновим старую папку и новую папку
		    oSender.TreeView.GetNode(sSourcePath, false).Remove
    		
		    If HasValue(sSourceParentPath) Then
		        Set oSourceParent = oSender.TreeView.GetNode(sSourceParentPath, false)
	        Else 
	            Set oSourceParent = Nothing
	        End If
    	    
		    Set oTarget = oSender.TreeView.GetNode(sTargetPath, false)
    	    
		    ReloadAfterMoveSafe oSourceParent, oTarget, oSender.TreeView
    		
		    If HasValue(sSourceParentPath) Then 
		        oSender.TreeView.Path = sSourceParentPath
		    Else 
		        oSender.TreeView.Path = sSourceType & "|" & sSourceID & "|" & sTargetPath
		    End If
	    End If
        DisableAllControls oSender, False
    End If
    
End Sub

Sub DisableAllControls(oTreePage, bDisabled)
    If bDisabled Then
        oTreePage.EnableControls False
    Else
        oTreePage.EnableControls True
    End If
End Sub 

Function GetTreeMenuForActiveNode(oTree)
    Dim oMenuCached
    Dim sKeyPath
    Dim sKeyType
    Dim oMenuPostData
    Dim oMenuHTTP
    Dim sMenuLoaderUrl
    
    Set oMenuCached = Nothing
	sKeyPath = "path:" & oTree.GetPathOfTypes()
	sKeyType = "type:" & oTree.TreeView.ActiveNode.Type
	If oTree.m_oMenuCache.Exists(sKeyPath) Then
		Set oMenuCached = oTree.m_oMenuCache.Item(sKeyPath)
	ElseIf oTree.m_oMenuCache.Exists(sKeyType) Then
		Set oMenuCached = oTree.m_oMenuCache.Item(sKeyType)
	End If
	If Not oMenuCached Is Nothing Then
	    Set GetTreeMenuForActiveNode = oMenuCached
	    Exit Function 
	End If
	
	' закешированного меню нет
	' создадим xml-запрос загрузчику меню
	Set oMenuPostData = oTree.CreateMenuRequest()		
	' создадим объект для асинхронной загрузки xml
	Set oMenuHTTP = CreateObject( "Msxml2.XMLHTTP")
	' Формируем URL меню
	sMenuLoaderUrl = "x-tree-menu.aspx?METANAME=" & oTree.Metaname & "&tm=" & CDbl(Now)
	' Пошлем запрос на сервер синхронно (false в 3-м параметре)
	oMenuHTTP.open "POST", sMenuLoaderUrl, false
	oMenuHTTP.send oMenuPostData 	
		
    Set GetTreeMenuForActiveNode = CheckMenuRequestResponse(oMenuHTTP)
End Function

' Обработка дерева после переноса узлов
Sub PostMove(oTreeView, sMovingNodePath, sNewParentPath)
    Dim oSourceParent
    Dim sSourceParentPath
    Dim sSourceID
    Dim sSourcePath
    Dim aSourcePath
    Dim sSourceType
    Dim oTarget
    Dim sTargetPath
    
    sSourcePath = sMovingNodePath
    aSourcePath = Split(sSourcePath, "|")
    sSourceType = aSourcePath(0)
    sSourceID = aSourcePath(1)
    sSourceParentPath = Right(sSourcePath, Len(sSourcePath) - Len(sSourceType) - Len(sSourceID) - 1)
    If Len(sSourceParentPath) > 0 Then sSourceParentPath = Right(sSourceParentPath, Len(sSourceParentPath) - 1) Else sSourceParentPath = Null
    
    sTargetPath = sNewParentPath

    oTreeView.GetNode(sSourcePath, false).Remove
		
	If HasValue(sSourceParentPath) Then
	    Set oSourceParent = oTreeView.GetNode(sSourceParentPath, false)
    Else 
        Set oSourceParent = Nothing
    End If
    
	Set oTarget = oTreeView.GetNode(sTargetPath, false)
    
	ReloadAfterMoveSafe oSourceParent, oTarget, oTreeView
	
	If HasValue(sSourceParentPath) Then 
	    oTreeView.Path = sSourceParentPath
	Else 
	    oTreeView.Path = sSourceType & "|" & sSourceID & "|" & sTargetPath
	End If
End Sub