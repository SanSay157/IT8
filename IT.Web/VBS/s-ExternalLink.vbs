'*******************************************************************************
' Incident Tracker 6
' Реализации обслуживания списка внешних ссылок (External Link) в редакторе
'*******************************************************************************
Option Explicit

Const DEF_DataSourceName = "AllExternalLinkTypes"
Const DEF_GetDataSourceError = "Ошибка получения данных типов систем обслуживания внешних ссылок: "

' Словарь "типов систем" для внешних ссылок
Dim g_oExternalLinkTypeDictionary	

'-------------------------------------------------------------------------------
':Назначение:	Загружает словарт описаний "типов систем" внешних ссылок
':Результат:	Загруженный словарь; ключ в словаре - "f_тип_системы",
'				значение - идентификатор описания типа системы обслуживания.
'				Если в процессе загрузки случилась ошибка, функция вернет Nothing
Function GetExternalLinkTypeDictionary
	Dim oResponse				' Результат вызова операции сервера приложения
	Dim oDoc					' XML-документ с данными результата вызова "источника данных"
	Dim oXmlColumns				' XML-данные колонок
	Dim oRow					' XML-данные строки
	Dim nObjectIdColumnIndex	' Индекс колонки ObjectId
	Dim nServiceTypeColumnIndex	' Индекс колонки ServiceType
	Dim sObjectId				' Идентификатор описания "типа системы обслуживания"
	Dim i						' Итератор цикла
	
	Set GetExternalLinkTypeDictionary = Nothing
	
	If IsEmpty(g_oExternalLinkTypeDictionary) Then
		' Получить перечень всех типов систем обслуживания внешних ссылок: 
		' вызов операции запуска источника данных:
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
		
		' Анализ результата операции: перевод XML-данных в словарь:
		Set oDoc = oResponse.m_oDataWrapped.m_oXmlDataTable
		XService.XmlSetSelectionNamespaces oDoc.ownerDocument
		Set oXmlColumns = oDoc.selectNodes("//CS/C")
		' ...узнаем индексы колонок ObjectId и ServiceType
		For i = 0 To oXmlColumns.length - 1
			If oXmlColumns.item(i).getAttribute("name") = "ObjectID" Then
				nObjectIdColumnIndex = i
			End If
			If oXmlColumns.item(i).getAttribute("name") = "ServiceType" Then
				nServiceTypeColumnIndex = i
			End If
		Next
		If IsEmpty(nObjectIdColumnIndex) Or IsEmpty(nServiceTypeColumnIndex) Then 
			MsgBox DEF_GetDataSourceError & "некорректный формат данных (нет колонок ObjectID, ServiceType)", vbCritical
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
':Назначение:	Проверяет наличие указанного типа системы обслуживания (по 
'				словарю, загружаемому по необходимости)
':Параметр:		serviceType - тип системы, строка вида "f_тип_системы";
':Результат:	Логический признак наличия указанного типа системы обслуживания
Function ExternalLinkTypeExists( serviceType )
	ExternalLinkTypeExists = Not IsEmpty(GetExternalLinkType(serviceType))
End Function


'-------------------------------------------------------------------------------
':Назначение:	Возвращает идентификатор описания типа внешней ссылки
':Параметры:	serviceType - тип системы обслуживания
':Примечание:	Если описания типа внешней ссылки для заданного типом системы 
'				обслуживания не существует, возвращает Nothing.
Function GetExternalLinkType(serviceType)
	GetExternalLinkType = GetExternalLinkTypeDictionary().Item( "f" & CLng(serviceType) )
End Function


'-------------------------------------------------------------------------------
':Назначение:	Обработчик видимости / доступности нестандартных пунктов меню 
'				списка "Внешние ссылки"
':Параметры:	oSender - [in] инициатор события, XPE списка
'				oEventArgs - [in] Экземпляр MenuEventArgsClass
Sub usr_ExternalLinks_VisibilityHandler(oSender, oEventArgs)
	Dim bDisabled		' Признак заблокированности пункта
	Dim bHidden			' Признак сокрытия пункта
	Dim oNode			' Текущий menu-item
	Dim sObjectID		' Идентификатор выбранного объекта
	Dim bProcess		' признак обработки текущего пункта (Boolean)

	sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
	If 0=Len("" & sObjectID) Then
		sObjectID = Empty
	End If

	' Обработаем только известные нам операции
	For Each oNode In oEventArgs.ActiveMenuItems
		bHidden = Empty
		bDisabled = Not IsNull(oNode.getAttribute("disabled"))

        bDisabled = false

		bProcess = False
		
		Select Case oNode.getAttribute("action")
			Case "DoCreate"
				' Операция создания новой внешней ссылки 
				bDisabled = bDisabled Or ( _
						Not ExternalLinkTypeExists( _
							Eval( oNode.SelectSingleNode("i:params/i:param[@n='ServiceSystemType']").nodeTypedValue ) _
						) )
				bProcess = True
				
			Case "DoOpenLink", "DoCopyURI"
				' Операции открытия внешней ссылки, копирования данных в буфер обмена
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
':Назначение:	Обработчик выбора нестандартных пунктов меню списка "Внешние ссылки"
Sub usr_ExternalLinks_ExecutionHandler(oSender, oEventArgs)
	Select Case oEventArgs.Action
		Case "DoOpenLink" 
			'Выбран пункт меню "Открыть"
			DoOpenLink oSender.ObjectEditor, oEventArgs.Menu.Macros.Item("ObjectID"), oSender.ValueObjectTypeName
		
		Case "DoCopyURI" 
			'Выбран пункт меню "Открыть"
			DoCopyURI oSender.ObjectEditor, oEventArgs.Menu.Macros.Item("ObjectID"), oSender.ValueObjectTypeName
	End Select
End Sub


'-------------------------------------------------------------------------------
':Назначение:	Обработчик события OnBeforeCreate XPE-списка внешних ссылок;
'				Добавляет в перечень аргументов, передваемых в мастер новой 
'				внешней ссылки тип внешней ссылки.
Sub usr_ExternalLinks_ObjectsElementsList_OnBeforeCreate(oSender, oEventArgs)
	oEventArgs.UrlArguments = _
		".LinkType=" & GetExternalLinkType( Eval(oEventArgs.OperationValues.Item("ServiceSystemType")) )
End Sub


'-------------------------------------------------------------------------------
':Назначение:	Обработчик события OnBeforeCreate скалярного объектного 
'				представления; Добавляет в перечень аргументов, передваемых в 
'				мастер новой внешней ссылки тип внешней ссылки.
Sub usr_ExternalLink_ObjectPresentation_OnBeforeCreate(oSender, oEventArgs)
	Call usr_ExternalLinks_ObjectsElementsList_OnBeforeCreate( oSender, oEventArgs )
End Sub


'-------------------------------------------------------------------------------
':Назначение:	Обработчик для заполнения одиночной ссылки на папку.
'				ВСЕГДА вызывает создание внешней ссылки на каталог Documentum
Sub usr_ExternalFolderLink_OnClick
	Dim oXmlLink
	Set oXmlLink = g_oPool.GetXmlObjectByOPath( g_oObjectEditor.XmlObject, "ExternalLink" )
	OpenExternalLinkEditor g_oObjectEditor.GetProp("ExternalLink"), oXmlLink, SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK
	LinkCaption.Value = g_oPool.GetPropertyValue( g_oObjectEditor.XmlObject, "ExternalLink.Name" )
End Sub


'-------------------------------------------------------------------------------
':Назначение:	Обработчик выбора пунктов меню "Открыть" списка "Внешние ссылки"
':Параметры:	sObjectID - идентификатор выбранной внешней ссылки
'				sType - имя типа внешней ссылки
Sub DoOpenLink(oObjectEditor, sObjectID, sType)
	Dim oXmlExternalLink	' XML-объект значение (As IXMLDOMElement)
	Dim URI					' Значение внешней ссылки (As String)
	Dim nServiceType		' Тип системы обслуживания внешней ссылки
	Dim sMessage			' Текст сообщения (об ошибке)
	
	' Определяем тип системы обслуживания для "открываемой" внешней ссылки:
	Set oXmlExternalLink = oObjectEditor.Pool.GetXmlObject(sType, sObjectID, Null)
	URI = oXmlExternalLink.SelectSingleNode("URI").NodeTypedValue
	nServiceType = oObjectEditor.Pool.GetPropertyValue(oXmlExternalLink,"LinkType.ServiceType")
	
	Select Case nServiceType
		' Тип системы обслуживания: "просто" URL
		Case SERVICESYSTEMTYPE_URL
			Dim oIE		' Экземпляр Internet Explorer
			
			sMessage = "Ошибка при открытии ссылки """ & URI & """: "
			On Error Resume Next
			Set oIE = XService.CreateObject("InternetExplorer.Application")
			oIE.Visible = True
			oIE.Navigate URI
			If Err Then
				MsgBox sMessage & Err.Description, vbCritical, "Ошибка"
				Exit Sub
			End If
			On Error Goto 0
		
		' Тип системы обслуживания: ссылка на файл
		Case SERVICESYSTEMTYPE_FILELINK
			Dim oFSO	' Объект FileSystemObject
			Dim vRet	' Результат запроса подтверждения у пользователя
			
			sMessage  = "Ошибка при попытке открытия ссылки на файл """ & URI & """: " 
			On Error Resume Next
			Set oFSO = XService.CreateObject("Scripting.FileSystemObject")
			If Err Then
				MsgBox sMessage & Err.Description, vbCritical, "Ошибка"
				Exit Sub
			End If
			If Not oFSO.FileExists(URI) Then 
				vRet = MsgBox( _
					"Указанный файл """ & URI & """ не существует." & vbNewLine & _
					"Возможно, у Вас нет прав на открытие файла или файл был переименован, перемещен или удален." & vbNewLine & _
					"Попытаться открыть файл?", vbYesNo Or vbExclamation, "Файл не существует" ) 
				If vbYes <> vRet Then Exit Sub
			End If
			On Error Resume Next
			XService.ShellExecute URI
			If 0<>Err.Number Then
				MsgBox sMessage & Err.Description, vbCritical, "Ошибка"
			End If
			On Error GoTo 0
		
		' Тип системы обслуживания: ссылка на каталог
		Case SERVICESYSTEMTYPE_DIRECTORYLINK
			Dim oFolder	
			
			sMessage = "Ошибка при попытке открытия ссылки на папку """ & URI & """: " 
			On Error Resume Next
			With XService.CreateObject("Shell.Application")
				Set oFolder = .NameSpace(URI)
				If Not hasValue(oFolder) Then
					MsgBox _
						"Указанная папка """ & URI & """ не существует." & vbNewLine & _
						"Возможно, у Вас нет прав на открытие папки или папка была переименована, перемещена или удалена.", _
						vbCritical, "Ошибка"
					Exit Sub
				End If
				' NB: oFolder.Self возвращает FolderItem, для которого допустимо использование Verb
				oFolder.Self.InvokeVerb("explore")
			End With
			If Err Then MsgBox sMessage & Err.Description, vbCritical, "Ошибка"
			On Error Goto 0
			
		' Тип системы обслуживания: ссылка на файл в Documentum
		Case SERVICESYSTEMTYPE_DOCUMENTUMFILELINK	
			window.open XService.BaseUrl & "webtop.aspx?goto=" & XService.UrlEncode("drl/objectId/" & URI)
		
		' Тип системы обслуживания: ссылка на папку в Documentum 
		Case SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK	'
			window.open XService.BaseUrl & "webtop.aspx?goto=" & XService.UrlEncode("drl/objectId/" & URI)
			' Для нормальной версии WebTop-а будет использоваться cледующий код
			'X_ShowModalDialogEx XService.BaseUrl & "it-integrate-documentum.aspx?Command=crocintgopen&Params=objectId~" & URI & "|launchViewer~true" , "", "help:no;center:yes;status:no"
	
	End Select
End Sub


'-------------------------------------------------------------------------------
':Назначение:	Обработчик выбора пункта меню "Копировать" списка "Внешние ссылки"
':Параметры:	sObjectID - идентификатор выбранной внешней ссылки
'				sType - имя типа внешней ссылки
Sub DoCopyURI( oObjectEditor, sObjectID, sType )
	Dim oXmlExternalLink	' XML-объект значение (As IXMLDOMElement)
	Dim URI					' Значение внешней ссылки (As String)
	Dim nServiceType		' Тип системы обслуживания внешней ссылки

	' Определяем тип системы обслуживания для "открываемой" внешней ссылки:
	Set oXmlExternalLink = oObjectEditor.Pool.GetXmlObject(sType, sObjectID, Null)
	URI = oXmlExternalLink.SelectSingleNode("URI").NodeTypedValue
	nServiceType = oObjectEditor.Pool.GetPropertyValue(oXmlExternalLink,"LinkType.ServiceType")
	
	Select Case nServiceType
		Case SERVICESYSTEMTYPE_URL
		Case SERVICESYSTEMTYPE_FILELINK
		Case SERVICESYSTEMTYPE_DIRECTORYLINK
		
		Case SERVICESYSTEMTYPE_DOCUMENTUMFILELINK	
			' Файл Documentum
			URI = XService.BaseUrl & "webtop.aspx?goto=" & XService.UrlEncode("drl/objectId/" & URI)
		
		Case SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK	
			' Папка Documentum
			URI = XService.BaseUrl & "webtop.aspx?goto=" & XService.UrlEncode("drl/objectId/" & URI)
	End Select
	
	' Записываем данные в буфер обмена:
	window.clipboardData.setData "Text", URI
End Sub
