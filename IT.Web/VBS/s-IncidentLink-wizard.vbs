Option Explicit

Dim g_oObjectEditor
Dim g_oFilterXmlObject
Dim g_bFilterDKPInitialized
Dim g_sEditablePropertyName
Dim g_sIncidentID
'X_RegisterStaticHandler "usrXEditor_OnLoad", "usrXEditor_OnLoad_Wizard"
'X_RegisterStaticHandler "usrXEditor_OnPageStart", "usrXEditor_OnPageStart_Wizard"

'==============================================================================
' Обработчик события Load только для мастера 
Sub usrXEditor_OnLoad(oSender, oEventArgs)
		
	Set g_oObjectEditor = oSender
	g_sEditablePropertyName =oSender.QueryString.GetValue("RealPropName","LinksFromRoleA")'Наименование свойства у объекта Incident,куда 
	                                                                                      'будем помещать создаваемые ссылки
	g_sIncidentID=oSender.ParentObjectEditor.XmlObject.getAttribute("oid")'Идентификатор инцидента,для которого создаем ссылки
	
	Set g_oFilterXmlObject = oSender.Pool.Xml.selectSingleNode("FilterDKP[@use-for='MultiChoiceIncident']")
	If g_oFilterXmlObject Is Nothing Then
		' Создадим в пуле временный объект для отрисовки фильтра для дерева выбора папки
		Set g_oFilterXmlObject = oSender.Pool.CreateXmlObjectInPool( "FilterDKP" )
		g_oFilterXmlObject.setAttribute "use-for", "MultiChoiceIncident"
		
		' Положим объект фильтра в виртуальное свойство временного объекта
	    oSender.XmlObject.appendChild( oSender.XmlObject.ownerDocument.createElement("virtual-prop-filter") ).appendChild X_CreateStubFromXmlObject(g_oFilterXmlObject)
	End If
	
		 
	Dim oTD
	'Пока возможность создать новый инцидент отключена
	'Set oTD = xBarControl1.Rows(0).insertCell()
	'oTD.ID = "xCtrlPlace_cmdCreateNew"
	'oTD.ClassName = "x-bar-control-place x-editor-bar-control-place"
	'oTD.innerHTML =_
					'"<BUTTON ID='cmdCreateNew' DISABLED='-1' style='width:150px;' CLASS='x-button-wide'" & _
					'"	TITLE='Создать новый инцидент и установить с ним связь' LANGUAGE='VBScript' ONCLICK='cmdCreateNew_onClick'>" & _
					'"	<CENTER><B>Создать новый</B></CENTER></BUTTON>"
					
	Set oTD = xBarControl1.Rows(0).insertCell(0)
	oTD.ID = "xCtrlPlace_cmdOK"
	oTD.innerHTML =_
					"<BUTTON ID='cmdOK' DISABLED='-1' style='width:100px;' CLASS='x-button-wide'" & _
					"	TITLE='Сохранить изменения и закрыть редактор ' LANGUAGE='VBScript' ONCLICK='cmdOK_onClick'>" & _
					"	<CENTER><B>OK</B></CENTER></BUTTON>"
					
	Set oTD = xBarControl1.Rows(0).insertCell(1)								
	oTD.ID = "xCtrlPlace_cmdUpdate"
	oTD.innerHTML =_
					"<BUTTON ID='cmdUpdate' DISABLED='-1' style='width:100px;' CLASS='x-button-wide'" & _
					"	TITLE='Обновить' LANGUAGE='VBScript' ONCLICK='cmdUpdate_onClick'>" & _
					"	<CENTER><B>Обновить</B></CENTER></BUTTON>"						
End Sub


'==============================================================================
Sub cmdCreateNew_onClick
	Dim sID
	sID = X_OpenObjectEditor( "Incident", Null, "WizardWithSelectFolder", "")
	If hasValue(sID) Then
		g_oObjectEditor.Pool.AddRelation g_oObjectEditor.XmlObject, g_sEditablePropertyName, X_CreateObjectStub("Incident", sID) 
		X_SetDialogWindowReturnValue sID
		' И закроем окно
		window.Close
	End If
End Sub
'==============================================================================
' Обработчик кнопки "Обновить"
Sub cmdUpdate_onClick
'Редактор свойства Incidents временного объекта - экземпляр XPEObjectsTreeSelectorClass
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
		sCaptionHTML = "Выбор инцидентов, от которых зависит инцидент №"
	Else
		sCaptionHTML = "Выбор инцидентов, ссылающихся на инцидент №"
	End If
	
	If Len( oIncident.selectSingleNode("Number").text ) > 0 Then
		sCaptionHTML = "<span style='font-size:14pt;'>" & sCaptionHTML & oIncident.selectSingleNode("Number").text & "<BR>" & oIncident.selectSingleNode("Name").text & "</span>"
	Else
		sCaptionHTML = "<span style='font-size:14pt;'>Выбор инцидента</span>"
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
' Формирование ограничений загрузчика списка.
' ВНИМАНИЕ: использует глобальные переменные: 
'	g_bFilterDKPInitialized
'	g_oFilterXmlObject
' [in] oSender As XPEObjectTreeSelectorClass
' [in] oEventArgs As GetRestrictionsEventArgsClass
Sub usr_ObjectsTreeSelector_OnGetRestrictions(oSender, oEventArgs)
	Dim oBuilder
	Dim oProp
	
	' True - значит "молчаливый режим"
	' Примечание: нас не интересует результат GetData, т.к. нам надо получить данные временного объекта для фильтрации
	If g_bFilterDKPInitialized Then
		' если страница с фильтром была инициализирована, то выполним сбор данных, иначе,
		' если ограничения получаются при 1-ом заполнении PE, то собирать данные с формы не надо, ибо она еще не была инициализирована!
		oSender.ObjectEditor.FetchXmlObject True
	End If
	Set oBuilder = New QueryStringParamCollectionBuilderClass
	' по всем свойствам временного объекта-фильтра 
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
' Запускает поиск инцидента по номеру
Sub OnIncidentFind(vIncidentNumber)
	Dim oResponse				' ответ серверной операции
	Dim oPE                     ' редактор свойства (x-pe-objects-tree-selector)
	Dim oFilterObjectBackup		' ссылка на g_oFilterXmlObject
	
	If not hasValue(vIncidentNumber) Then
		Alert "Необходимо задать номер инцидента"
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
			MsgBox "Инцидент с номером " & vIncidentNumber & " не найден", vbInformation
		Else
			g_oObjectEditor.EnableControls False
			Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Incidents"))
			oPE.HtmlElement.SetNearestPath oResponse.m_sPath, false, true
			' если не удалось спозиционироваться на инцидент с заданным номером, перегрузим дерево в максимально полном режиме и повторим
			If Not CheckActiveNode(oPE.HtmlElement, "Incident", oResponse.m_sObjectID) Then
				' перегрузим дерево в режиме, отличном от того, который задан фильтре. 
				' Для этого подменим ссылку на объект-фильтра, используемую в usr_ObjectTreeSelector_OnGetRestrictions, 
				' на момент вызова Load, а потом восстановим как было
				Set oFilterObjectBackup = g_oFilterXmlObject
				' это препятствует сбору данные в usr_ObjectTreeSelector_OnGetRestrictions (в данном случае сбор данные не имеет смысла)
				g_bFilterDKPInitialized = False
				Set g_oFilterXmlObject = X_GetObjectFromServer("FilterDKP", Null, Null)
				g_oFilterXmlObject.selectSingleNode("Mode").nodeTypedValue = DKPTREEMODES_ORGANIZATIONS
				g_oFilterXmlObject.selectSingleNode("OnlyOwnActivity").nodeTypedValue = False
				oPE.Load
				oPE.HtmlElement.SetNearestPath oResponse.m_sPath, false, true
				Set g_oFilterXmlObject = oFilterObjectBackup
				g_bFilterDKPInitialized = True
				' если уж и после этого не удалось найти инцидент в дереве, значит у юзера недостаточно прав для просмотра
				If Not CheckActiveNode(oPE.HtmlElement, "Incident", oResponse.m_sObjectID) Then
					
				End If
			End If
			g_oObjectEditor.EnableControls True
		End If
	End If
End Sub

'==============================================================================
' Обработчик кнопки "OK"
Sub cmdOK_OnClick
    Dim oPE   ' редактор свойства (x-pe-objects-tree-selector)
    Dim oNode ' текущий элемент в дереве
     
    Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(g_oObjectEditor.XmlObject.selectSingleNode("Incidents"))
        
   'Проверяем, что в дереве выбран хотя бы один инцидент
   If  oPE.TreeView.Selection.ChildNodes.Length = 0 Then
       Alert "Для создания ссылки должен быть выбран хотя бы один инцидент" 
       Exit Sub
   End If
   
   'Проходим по отмеченным узлам дерева  и записываем идентификаторы инцидентов в выходной массив 
   For Each oNode In oPE.TreeView.Selection.ChildNodes
     If oNode.getAttribute("id") = g_sIncidentID Then
       Alert "Связь не может быть установлена между одним и тем же инцидентом"
       Exit Sub
     End If
   Next

   X_SetDialogWindowReturnValue Array(oPE.TreeView.Selection)
     
   'Снимаем выделенные элементы в дереве,тем самым очищаем ссылки, которые установились в свойстве Incidents  временного объекта
   oPE.Internal_OnClear
   window.Close
End Sub
