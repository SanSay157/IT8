Option Explicit

Dim g_nServiceType	' Тип "системы обслуживания" для редактируемой внешней 
					' ссылки, значение перечисления ServiceSystemType

'-------------------------------------------------------------------------------
' Обработчик события OnLoad редактора ObjectEditor.
' Запоминает тип системы обслуживания, представленной в данных объекта
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	g_nServiceType = oSender.Pool.GetPropertyValue(oSender.XmlObject,"LinkType.ServiceType" )
End Sub


'-------------------------------------------------------------------------------
' Обработчик события OnBeforePageStart редактора ObjectEditor.
' Формирует и устанавливает заголовок редактора: в соответствии с типом системы
' обслуживания и режимом редактора (мастер / редактор)
Sub usrXEditor_OnBeforePageStart( oSender, oEventArgs )
	Dim sCaption
	If oSender.IsObjectCreationMode Then 
		sCaption = NameOf_ServiceSystemType(g_nServiceType)
		sCaption = "Новая " & LCase( Left(sCaption,1) ) & Mid(sCaption,2)
	Else
		sCaption  = NameOf_ServiceSystemType(g_nServiceType)
	End If
	oSender.SetCaption sCaption, sCaption
End Sub


'-------------------------------------------------------------------------------
' Обработчик кнопки btnGetDCTMLink (кнопка задания значения самой ссылки)
Sub btnGetDCTMLink_OnClick(oObjectEditor)
	Dim oXmlLinkType		' XML-представление типа ссылки
	Dim sLinkValue			' Значение внешней ссылки 
	
	sLinkValue = oObjectEditor.GetPropertyValue("URI" )

	Select Case g_nServiceType
		Case SERVICESYSTEMTYPE_URL
			' Выбор никак не "инструментируется" - пользователь вводит URL явно
			
		Case SERVICESYSTEMTYPE_FILELINK
			' Ссылка на файл: отображение диалога выбора файла
			sLinkValue = "" & XService.SelectFile( _
				"Укажите файл", _
				BFF_PATHMUSTEXIST or BFF_FILEMUSTEXIST or BFF_HIDEREADONLY, _
				"", sLinkValue, "" )
			' ...если диалог закрыт "Отменой", то значение будет пустым - выходим:
			If Not hasValue(sLinkValue) Then Exit Sub
			' Записываем полученное значение ссылки; в качестве наименования по-
			' умолчанию используется имя файла, без пути:
			SetLinkValues oObjectEditor, XService.GetFileTitle(sLinkValue), sLinkValue
		
		Case SERVICESYSTEMTYPE_DIRECTORYLINK
			' Ссылка на каталог: отображение диалога выбора каталога
			Dim objFolder	' объект папки, FSO.Folder
			Dim vFlags		' набор флагов, задаваемых для диалога выбора папки:
			
			' Используются следующие флаги:
			'	0x0010	- BIF_EDITBOX
			'	0x0040	- BIF_NEWDIALOGSTYLE
			'	0x0001	- BIF_RETURNONLYFSDIRS
			'	0x0020	- BIF_VALIDATE
			vFlags = CLng( &h0010 + &h0040 + &h0001 + &h0020 )
			vFlags = CStr( CInt(vFlags) )
			
			' Запуск диалога выбора папки: NB - последний параметр определяет 
			' "корневую" папку, "выше" которой пользователь не может выбирать;
			' Значение 0x00 есть Desktop (см. MSDN, ShellSpecialFolderConstants)
			With XService.CreateObject("Shell.Application")
			    Set objFolder = .BrowseForFolder( 0, "Укажите папку", vFlags , &h0 )
			End With
			
			If (Not objFolder Is Nothing) Then
			    ' ... папка указана: ее наименование будет использоваться как значение
			    ' наименования внешней ссылки; полученный объект приводим к FolderItem:
			    sLinkValue = objFolder.Title
			    Set objFolder = objFolder.Self
			    ' ... и если это действительно папка - то записываем данные ссылки:
			    If objFolder.IsFileSystem And objFolder.IsFolder Then
			    	SetLinkValues oObjectEditor, sLinkValue, objFolder.Path
			    Else
			    	MsgBox "Указанный объект """ & sLinkValue & """ не является папкой!", vbCritical, "Ошибка задания данных"
			    End If
			End If

		Case SERVICESYSTEMTYPE_DOCUMENTUMFILELINK	
			' Файл Documentum - вызывается специальная логика WDK:
			OpenWDKContainer "crocintglinkdocument", sLinkValue, GetMainFolder(oObjectEditor)
		
		Case SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK	
			' Папка Documentum - вызывается специальная логика WDK:
			OpenWDKContainer "crocintglinkfolder", sLinkValue, GetMainFolder(oObjectEditor)
			
	End Select
End Sub


'-------------------------------------------------------------------------------
':Назначение:	Служебный метод: записывает заданные наименование и значение 
'				ссылки в объект редактируемой внешней ссылки.
':Параметры:	oObjectEditor - редактор объекта, экземпляр ObjectEditorClass;
'				sName - строка с наименованием ссылки;
'				sURI - строка со значением ссылки;
Sub SetLinkValues(oObjectEditor, sName, sURI)
	With oObjectEditor.CurrentPage
		.GetPropertyEditor(oObjectEditor.GetProp("URI")).Value = sURI
		If hasValue(sName) Then
			.GetPropertyEditor(oObjectEditor.GetProp("Name")).Value = sName
		End If
	End With
End Sub


'-------------------------------------------------------------------------------
':Назначение:	Служебный метод: возвращает признак, что редактируемая внешняя
'				ссылка есть URL; используется из XSL-страницы, на момент 
'				формирования UI редактора
Function IsJustURL()
    If g_nServiceType = SERVICESYSTEMTYPE_URL Then
	    IsJustURL = true
    else
        IsJustURL = false
    End If
End Function


'-------------------------------------------------------------------------------
':Назначение:	Вызов компонента WDK.
':Параметры:
'	sCommand	- имя компонента WDK, строка
'	sObjID		- [in] идентификатор документа или папки Documentum, или
'				Null, если документ не был выбран ранее; строка
'	sFolderID	- [in] идентификатор основной папки Documentum для активности,
'				или Null, если основная папка активности (каталога) не задана
':Примечание:
'	ВНИМАНИЕ! ВЫЗОВ МЕТОДА ВОЗМОЖЕН ТОЛЬКО ПРИ УСЛОВИИ ИСПОЛЬЗОВАНИЯ WDK!
Sub OpenWDKContainer( sCommand, sObjID, sFolderID )
	Dim sParams		' Строка с параметрами
	Dim sDlgResult	' Результат вызова WDK
	
	' Формируем полный адрес команды вызова WDK, с параметрами:
	sParams = ""
	' ...параметры:
	If hasValue(sObjID) Then 
		sParams = "objectId~" & sObjID
	ElseIf hasValue(sFolderID) Then 
		sParams = "folderId~" & sFolderID
	End If
	If hasValue(sParams) Then sParams = "&Params=" & sParams
	' ...полный адрес, с наименованием WDK-комадны
	sCommand = "it-integrate-documentum.aspx?Command=" & sCommand & sParams
	
	' Вызов WDK:
	sDlgResult = X_ShowModalDialogEx(sCommand, "", "help:no;center:yes;status:no")
	If IsEmpty(sDlgResult) Then Exit Sub
	
	' Результат вызова (если есть) - это "наименование,значение":
	Dim sArray
	sArray = Split(sDlgResult,",", 2)
	SetLinkValues sArray(1), sArray(0)
End Sub

'==============================================================================
' Функция возвращает основную папку проекта ITracker или Null, если папка не
' задана
' [return] As String
Function GetMainFolder( oObjectEditor )
	GetMainFolder = Null
	'В родительском редакторе инцидент или проект?
	Dim oXmlParentProp
	Set oXmlParentProp = oObjectEditor.ParentXmlProperty
	If oXmlParentProp Is Nothing Then Exit Function
	Dim oXmlParentObj
	Set oXmlParentObj = oXmlParentProp.parentNode
	Dim oXmlExtLink
	If oXmlParentObj.tagName = "Incident" Then
		'В родительском редакторе инцидент. Нужно получить проект, в который входит
		'этот инцидент.
		Dim oXmlFolder
		Set oXmlFolder = oObjectEditor.Pool.GetXmlObjectByOPath(oXmlParentObj, "Folder")
		If oXmlFolder Is Nothing Then Exit Function
		'Теперь можно узнать, задана ли основная папка в проекте
		Set oXmlExtLink = oObjectEditor.Pool.GetXmlObjectByOPath(oXmlFolder, "ExternalLink")
	Else
		'В родительском редакторе проект. Нужно получить основную папку проекта.
		Set oXmlExtLink = oObjectEditor.Pool.GetXmlObjectByOPath(oXmlParentObj, "ExternalLink")
	End If
	If oXmlExtLink Is Nothing Then Exit Function
	GetMainFolder = oObjectEditor.Pool.GetPropertyValue(oXmlExtLink, "URI")
End Function

