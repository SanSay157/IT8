Option Explicit

Dim g_oObjectEditor		' Объект-редактор объекта (ObjectEditorClass)
Dim g_aFoundObjects		' Массив найденных объектов для исключения их при поиске "следующего"
Dim g_sIgnoreEmployeeIDs
Dim g_bShowNext			' Признак доступности операции "искать следующего" (кнопка "Следующий")
g_bShowNext = False

'==========================================================================
' Обработчик кнопки "Поиск"
Sub Internal_OnbtnRunSearchClick
	If Len("" & document.all("EmployeeSearch").Value) = 0 Then
		Alert "Необходимо задать строку для поиска"
		Exit Sub
	End If
	If 0=Len(g_sIgnoreEmployeeIDs) Then
		g_aFoundObjects = Empty
	Else
		g_aFoundObjects = Split(g_sIgnoreEmployeeIDs,";")
	End If
	Internal_OnbtnSearchNext
End Sub

	
'==========================================================================
' Обработчик кнопки "Следующий"
Sub Internal_OnbtnSearchNext
	findEmployee Trim(document.all("EmployeeSearch").Value), g_aFoundObjects
End Sub

	
'==========================================================================
' Обработчик нажатия кнопки в inputbox'е для задания фамилии сотрудника
' При нажатии Enter'a запускает поиск
Sub Internal_EmployeeSearch_onKeyUp
   	If window.event.keyCode	= VK_ENTER Then
		window.event.cancelBubble = True
		If g_bShowNext Then
	        Internal_OnbtnSearchNext	    
        Else
            Internal_OnbtnRunSearchClick
        End If
   	End If
End Sub

'==========================================================================
' Выполняет поиск сотрудника
'	[in] sSearchString	- условие поиска (фамилия)
'	[in] aIgnoredObject	- массив идентификаторов игнорируемых объектов или Empty
Private Sub findEmployee(sSearchString, aIgnoredObject)
	Dim oResponse		' VBS-proxy Response'a команды
	Dim nIndex			' Индекс в массиве найденных объектов
	Dim bShowArchive	' Признак отображения/поиска архивных сотрудников
	Dim oTreeView		' As CROC.IXTreeView
	
	bShowArchive = g_oObjectEditor.XmlObject.selectSingleNode("ShowArchive").nodeTypedValue
	If IsNull(aIgnoredObject) Then aIgnoredObject = Empty
	On Error Resume Next
	With New EmployeeLocatorInCompanyTreeRequest
		.m_sName = "EmployeeLocatorInCompanyTree"
		.m_sLastName = sSearchString
		.m_aIgnoredObjects = aIgnoredObject
		.m_bAllowArchive = bShowArchive
		Set oResponse = X_ExecuteCommandSafe( .Self )
	End With
	'Exec_EmployeeLocatorInCompanyTreeRequest("EmployeeLocatorInCompanyTree", sSearchString, aIgnoredObject, bShowArchive )
	If X_HandleError Then Exit Sub
	On Error GoTo 0
	If Len(oResponse.m_sTreePath) > 0 Then
		If IsEmpty(g_aFoundObjects) Then
			nIndex = 0
			ReDim g_aFoundObjects(nIndex)
		Else
			nIndex = UBound(g_aFoundObjects) + 1
			ReDim Preserve g_aFoundObjects(nIndex)
		End If
		g_aFoundObjects(nIndex) = oResponse.m_sObjectID
		SetEnable False
		Set oTreeView = g_oObjectEditor.ObjectContainerEventsImp.OuterContainerPage.TreeView
		oTreeView.SetNearestPath oResponse.m_sTreePath, false, true
		' установим доступность кнопки "Искать дальше"
		g_bShowNext = oResponse.m_bMore
		SetEnable True
	Else
		MsgBox "Ничего не найдено", vbInformation 
	End If
End Sub


'==========================================================================
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	' Сохраним ссылку на экземпляр класса редактора объекта ObjectEditorClass
	Set g_oObjectEditor = oSender
	g_sIgnoreEmployeeIDs = oSender.QueryString.GetValue("IgnoreEmployeeIDs", vbNullString) '
	oSender.Pages.Items()(0).EventEngine.AddHandlerForEvent "AfterEnableControls", Nothing, "OnAfterEnableControls"
End Sub


'==========================================================================
' Обработчик события "AfterEnableControls" страницы редактора
'	[in] oEventArgs As EnableControlsEventArgs
Public Sub OnAfterEnableControls(oSender, oEventArgs)
	SetEnable oEventArgs.Enable
End Sub


'==========================================================================
' Устанавливает (не)доступность 
' Примечание: Кнопка "Следующие" становится доступной только, если установлен флаг g_bShowNext
Public Sub SetEnable(bEnabled)
     document.all("EmployeeSearch").disabled = Not bEnabled
     document.all("EmployeeSearch_btnRunSearch").disabled = Not bEnabled
	If g_bShowNext And bEnabled Then
		document.all("EmployeeSearch_btnSearchNext").disabled = False
	ElseIf Not bEnabled Then
		document.all("EmployeeSearch_btnSearchNext").disabled = True
	End If
End Sub
