'*******************************************************************************
' Подсистема:	
' Назначение:	Стандартный функционал обслуживания UI-представления скалярного 
'				свойства бинарного потока (vt="bin") файла
'*******************************************************************************
Option Explicit
'==============================================================================
'	BINARY-PRESENTATION (2 х read-only-поля + кнопка с меню операций)
'==============================================================================
' События:
'	Accel (EventArg: AccelerationEventArgsClass)
'		- нажатие комбинации клавиш 
Class XPEBinaryPresentationClass
	Private m_oPropertyEditorBase 	' As XPropertyEditorBaseClass
	Private m_oFileNameHtmlElement	' As IHtmlElement	- Html-элемент с именем файла
	Private m_oFileSizeHtmlElement	' As IHtmlElement	- Html-элемент с размером
	Private m_bIsImage				' As Boolean		- признак использования изображения
	Private IMG_LOCAL_FILE_NAME 	' Аттрибут с именем локального файла в элементе bin.hex, содержащем картинку
	Private m_oPopUpMenu			' CROC.XPopupMenu
	Private m_nMaxFileSize			' Максимальный размер файла, который можно загрузить в свойсвто
	
	Private Sub Class_Initialize
		IMG_LOCAL_FILE_NAME = "local-file-name"
	End Sub

	'--------------------------------------------------------------------------
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Accel", "BinaryPresentation"
		
		Set m_oFileNameHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all(HtmlElement.GetAttribute("FileNameID"), 0) 
		Set m_oFileSizeHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all(HtmlElement.GetAttribute("FileSizeID"), 0) 
		m_bIsImage = SafeCLng(HtmlElement.GetAttribute("IsPicture"))<>0
		m_nMaxFileSize = SafeCLng(HtmlElement.GetAttribute("MaxFileSize"))
		' свойство типа smallBin не может хранить больше 2000 байт
		If m_oPropertyEditorBase.PropertyMD.getAttribute("vt") = "smallBin" Then
			If m_nMaxFileSize > 2000 Or m_nMaxFileSize = 0 Then
				m_nMaxFileSize = 2000
			End If
		End If
		ViewInitialize
	End Sub

	
	'==========================================================================
	' IPropertyEdior: Метод вызывается при построении страницы редактора, после инициализации всех PE на странице
	Public Sub FillData()
		' Nothing to do...
	End Sub

	
	'==========================================================================
	' Возвращает экземпляр ObjectEditorClass - редактора,
	' в рамках которого работает данный редактор свойства
	Public Property Get ObjectEditor
		Set ObjectEditor = m_oPropertyEditorBase.ObjectEditor
	End Property


	'==========================================================================
	' Возвращает экземпляр EditorPageClass - страницы редактора,
	' на которой размещается данный редактор свойства
	Public Property Get ParentPage
		Set ParentPage = m_oPropertyEditorBase.EditorPage
	End Property


	'==========================================================================
	' Возвращает метаданные свойства
	'	[retval] As IXMLDOMElement - узел ds:prop
	Public Property Get PropertyMD
		Set PropertyMD = m_oPropertyEditorBase.PropertyMD
	End Property


	'==========================================================================
	' Возвращает экземпляр EventEngineClass - объекта, поддерживающего
	' событийную модель для данного редактора свойства
	Public Property Get EventEngine
		Set EventEngine = m_oPropertyEditorBase.EventEngine
	End Property

	'--------------------------------------------------------------------------
	' Возвращает Html элемент с именем файла
	Private Property Get FileNameHtmlElement
		Set FileNameHtmlElement = m_oFileNameHtmlElement
	End Property

	'--------------------------------------------------------------------------
	' Возвращает Html элемент с размером
	Private Property Get FileSizeHtmlElement
		Set FileSizeHtmlElement = m_oFileSizeHtmlElement
	End Property
	
	'--------------------------------------------------------------------------
	Public Property Get PropertyNameToStoreFileName
		PropertyNameToStoreFileName = vbNullString & HtmlElement.GetAttribute("PropertyNameToStoreFileName")
	End Property
	
	'--------------------------------------------------------------------------
	Public Property Get DataSize
		Dim vValue
		vValue = XmlProperty.GetAttribute("data-size")
		DataSize = 0
		If IsNull(vValue) Then
			vValue = XmlProperty.nodeTypedValue
			If Not IsNull(vValue) Then
				DataSize = UBound(vValue)
			End If
		Else
			DataSize = SafeCLng(XmlProperty.GetAttribute("data-size"))
		End If
	End Property

	'--------------------------------------------------------------------------
	' Возвращает Xml-свойство
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.GetXmlProperty(False)
	End Property
	
	'--------------------------------------------------------------------------
	Public Property Get Value
		Value = m_oPropertyEditorBase.XmlProperty.NodeTypedValue
	End Property

	'--------------------------------------------------------------------------
	' Устанавливает значение 
	Public Sub SetData
		Dim sFileName	' Наименование файла данные которого представляет свойство
		Dim nFilesize	' Размер файла
		Dim sPropName	' Наименование свойства, в котором хранится наименование файла

		' Получаем наименование файла; оно м.б. (а) определено непосредственно при 
		' выборе файла, тогда наименование рзмещено в IMG_LOCAL_FILE_NAME, (б)
		' задается значением свойства объекта, наименование которого в свою очередь
		' задано атрибутом X_FILE_NAME_IN (то, что задано атрибутом file-name-in для
		' i:binary-presentation в метаданных). 
		sFileName = XmlProperty.GetAttribute(IMG_LOCAL_FILE_NAME) 
		If Not hasValue(sFileName) Then
			sPropName = PropertyNameToStoreFileName
			If HasValue(sPropName) Then
				sFileName = vbNullString & XmlProperty.parentNode.selectSingleNode(sPropName).nodeTypedValue
			End If
		End If
		nFileSize = DataSize
		' Если наименование файла не определено - но сами данные файла представлены,
		If nFilesize>0 Then
			If (Not HasValue(sFileName)) Then _
				sFileName = Iif(IsPicture, "[ изображение ]", "[ файл ]")
		Else
			sFileName = "[ пусто ]"	
		End If
			
		' Отображение наименования файла:
		FileNameHtmlElement.Value = sFileName
		FileSizeHtmlElement.Value = Iif( nFileSize>0, nFileSize, vbNullString )
	End Sub

	'--------------------------------------------------------------------------
	' Сбор и проверка данных
	Public Sub GetData(oGetDataArgs)
		' Проверку проведём только если нет данных
		If 0>=DataSize Then
			ValueCheckOnNullForPropertyEditor Null, Me, oGetDataArgs, Mandatory
		End If	
	End Sub
	
	'--------------------------------------------------------------------------
	' Возвращает признак (не)обязательности свойства
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	
	'--------------------------------------------------------------------------
	' Установка (не)обязательности
	Public Property Let Mandatory(bMandatory)
		If (bMandatory) Then
			HtmlElement.removeAttribute "X_MAYBENULL"
		Else	
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
		End If
		If (bMandatory) Then
			FileSizeHtmlElement.className = "x-editor-control-notnull"
			FileNameHtmlElement.className = "x-editor-control-notnull"
		Else
			FileSizeHtmlElement.className = "x-editor-control"
			FileNameHtmlElement.className = "x-editor-control"
		End If
		ViewInitialize
	End Property
	
	'--------------------------------------------------------------------------
	' Установка (не)доступности
	Public Property Get Enabled
		 Enabled = Not (HtmlElement.disabled)
	End Property
	Public Property Let Enabled(bEnabled)
		' задизейблим/раздизейблим кнопку
		HtmlElement.disabled = Not( bEnabled )
		' задизейблим/раздизейблим read-only-поле
		FileSizeHtmlElement.disabled = Not( bEnabled )
		FileNameHtmlElement.disabled = Not( bEnabled )
	End Property
	
	'--------------------------------------------------------------------------
	' Установка фокуса
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function
	
	'--------------------------------------------------------------------------
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property

	'--------------------------------------------------------------------------
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
		Set m_oPropertyEditorBase = Nothing
	End Sub

	'-------------------------------------------------------------------------------
	' Выполняет выравнивание размеров кнопки операций, 
	' в соответствии с размером поля отображения представления объекта.
	Private Sub ViewInitialize( )
		' Выравнивание размеров кнопки операций выполняется по отношению к размерам
		' поля отображения представления объекта: получаем ссылку на соотв. HTML-элемент
		With HtmlElement
			.style.height = FileNameHtmlElement.offsetHeight
			.style.width = .style.height
			.style.lineHeight = (.offsetHeight \ 2) & "px"
		End With
	End Sub


	'--------------------------------------------------------------------------
	Public Property Get IsSmallBin
		IsSmallBin = ( HtmlElement.GetAttribute("PropertyType")="smallBin")
	End Property


	'--------------------------------------------------------------------------
	Public Property Get IsLoaded
		IsLoaded = IsNull(XmlProperty.getAttribute("loaded"))
	End Property


	'-------------------------------------------------------------------------------
	Public Property Get IsPicture
		IsPicture = m_bIsImage
	End Property


	'==========================================================================
	' Возвращает/устанавливает описание свойства
	Public Property Get PropertyDescription
		PropertyDescription = m_oPropertyEditorBase.PropertyDescription
	End Property	
	Public Property Let PropertyDescription(sValue)
		m_oPropertyEditorBase.PropertyDescription = sValue
	End Property
	
	
	'-------------------------------------------------------------------------------
	' Записывает данные из свойства во временный файл
	' [in] sFileExt - расширение временого файла
	' [retval] полное имя временного файа
	Private Function WriteToTempFileEx(sFileExt)
		Dim sFileName ' Имя файла
		' Определим имя временного файла
		sFileName = XService.GetTempPath & XService.NewGUIDString
		If hasValue(sFileExt) Then sFileName = sFileName & "." & sFileExt

		' Сохраним файл на диск во временный каталог,
		' процесс выполняется под контролем ошибок:
		On Error Resume Next
		XService.SaveFileData sFileName, XmlProperty.nodeTypedValue
		' Если была ошибка - отображаем сообшение 
		If 0<>Err.Number Then
			X_ErrReportEx "Ошибка при попытке записи в файл '" & sFileName & "'" & vbNewLine & Err.Description, err.Source 
			On Error Goto 0
			Exit Function
		End If	
		On Error Goto 0
		WriteToTempFileEx = sFileName
	End Function

	
	'-------------------------------------------------------------------------------
	' Записывает данные из свойства во временный файл
	' [retval] полное имя временного файа
	Private Function WriteToTempFile()
		WriteToTempFile = WriteToTempFileEx(Null)
	End Function

	
	'-------------------------------------------------------------------------------
	Private Sub KillTempFile(sFileName)
		' Попробуем удалить файл
		On Error Resume Next
		XService.CreateObject("Scripting.FileSystemObject").DeleteFile sFileName, True
		' Если была ошибка - отображаем сообшение 
		If 0<>Err.Number Then
			X_ErrReportEx  "Ошибка при попытке удаления временного файла '" & sFileName &  "'" & vbNewLine & err.Description, err.Source 
			On Error Goto 0
			Exit Sub	
		End If
		On Error Goto 0	
	End Sub


	'-------------------------------------------------------------------------------
	' Url для загрузки свойства
	Private Property Get PropertyUrl
		PropertyUrl = _
					XService.BaseURL & "x-get-image.aspx" & _
					"?ID=" & m_oPropertyEditorBase.ObjectID & _
					"&OT=" & m_oPropertyEditorBase.ObjectType & _
					"&PN=" & m_oPropertyEditorBase.PropertyName & _
					"&TM=" & XService.NewGuidString			
	End Property


	'-------------------------------------------------------------------------------
	' Обработчик клика кнопки "..." для изображения
	Private Sub ShowPictureMenu()
		Dim sTempFileName	' Полное имя временного файла
		Dim sTitle			' Заголовок
		Dim sImageLocation	' Размещение картинки
		Dim sNewFileName	' Имя файла с новым значением свойства

		If DataSize>0 Then
			' Есть данные
			If IsLoaded Then
				' Картинка уже загружена и данные находятся в XML
				' Поэтому сохраним её как временный файл
				sTempFileName = WriteToTempFile
				sImageLocation = sTempFileName
			Else
				sImageLocation = PropertyUrl
			End If
		End If
		' Получаем заголовок
		sTitle = toString( HtmlElement.getAttribute("ChooseFileTitle") )
		If Not hasValue(sTitle) Then 
			sTitle = "Выбор изображения """ & PropertyDescription & """"
		End If
		' Выполняем диалог
		sNewFileName = X_SelectImage(	_
				sTitle, _
				sImageLocation, _ 
				Trim(toString(HtmlElement.getAttribute("FileNameFilters"))), _ 
				m_nMaxFileSize, _
				SafeCLng(HtmlElement.getAttribute("MinImageWidth")), _
				SafeCLng(HtmlElement.getAttribute("MaxImageHeight")), _ 
				SafeCLng(HtmlElement.getAttribute("MinImageWidth")), _ 
				SafeCLng(HtmlElement.getAttribute("MaxImageWidth")) _ 
		)
		' Подчистим за собою
		If Not IsEmpty(sTempFileName) Then 
			KillTempFile sTempFileName
		End If	
								
		' Если нажата кнопка "Отмена" - ничего не делаем, выходим из процедуры
		If IsEmpty(sNewFileName) Then 
			Exit Sub
		' Если нажата кнопка "Очистить" - удаляем картинку...
		ElseIf IsNull(sNewFileName) Then
			ClearValue
		' Если файл выбран - загружаем файл на сервер
		Else
			UploadFile sNewFileName
		End If		
	End Sub
	
	
	'-------------------------------------------------------------------------------
	' Очистка значения (свойства и UI-контрола)
	Public Sub ClearValue
		' патчим свойство в XML
		With XmlProperty
			.removeAttribute "loaded"
			.setAttribute "data-size", 0
			.removeAttribute IMG_LOCAL_FILE_NAME
			.text = ""
		End With
		setFileNamePropValue Null
		SetDirty
		SetData	
	End Sub


	'-------------------------------------------------------------------------------
	' Загрузка значения из файла
	Private Sub UploadFile(sFileName)
		Dim nFileSize		' Размер файла
		Dim aFileData		' Данный файла
		
		' Посмотрим размер файла (под контролем ошибок)
		On Error Resume Next
		nFileSize = XService.CreateObject("Scripting.FileSystemObject").GetFile(sFileName).Size
		If Err Then
			X_ErrReportEx _
				"Ошибка при попытке определения размера файла:" & vbNewLine & _
				vbTab & sFileName & vbNewLine & _
				"Возможно он используется другим приложением.", _
				Err.Description & vbNewLine & Err.Source 
			On Error Goto 0
			Exit Sub
		End If

		' Проверим на допустимость
		If 0 = nFileSize Then 
			MsgBox "Файл """ & sFileName & """ имеет нулевой размер!", vbCritical
			On Error Goto 0
			Exit Sub
		End If

		If (m_nMaxFileSize > 0) And (nFileSize > m_nMaxFileSize) Then
			MsgBox _
				"Максимальный допустимый размер файла в байтах равен " & m_nMaxFileSize & vbNewLine & _
				"Размер выбранного файла """ & sFileName & """ равен " & nFileSize
			On Error Goto 0
			Exit Sub
		End If
		
		' Попытаемся прочитать файл с диска
		aFileData = XService.GetFileData(sFileName)
		If Err Then
			X_ErrReportEx "Ошибка при попытке чтения из файла:" & vbNewLine & vbTab & sFileName & vbNewLine & "Возможно он используется другим приложением."  ,err.Description & vbNewLine & err.Source 
			On Error Goto 0
			Exit Sub
		End If
		On Error Goto 0	
		
		' патчим свойство в XML
		With XmlProperty
			.removeAttribute "loaded"
			.setAttribute "data-size", nFileSize
			.setAttribute IMG_LOCAL_FILE_NAME, sFileName
			.nodeTypedValue = aFileData
			
			' если задано свойство для хранения наименования файла, то сохраним его (без пути)
			setFileNamePropValue XService.GetFileTitle(sFileName)
		End With	
		SetDirty
		SetData			
	End Sub
	

	'-------------------------------------------------------------------------------
	' Устанавливает значение свойства с наименованием файла
	'	[in] sFileName - наименование файла или Null - значение свойства
	Private Sub setFileNamePropValue(sFileName)	
		Dim sPropNameWithFileName	' Наименоваине свойство для хранения наименования файлa
		
		sPropNameWithFileName = PropertyNameToStoreFileName
		If HasValue(sPropNameWithFileName) Then
			m_oPropertyEditorBase.ObjectEditor.SetPropertyValue XmlProperty.parentNode.selectSingleNode(sPropNameWithFileName), sFileName
		End If
	End Sub
	
	
	'-------------------------------------------------------------------------------
	' Обработчик клика кнопки "..." для файла. Начинает показ меню операций.
	Private Sub ShowFileMenu
		const FM_DOWNLOAD	= 1002	' Код команды загрузки
		const FM_UPLOAD		= 1003	' Код команды выгрузки
		const FM_CLEAR		= 1004	' Код команды очистки
		const FM_VIEW		= 1005	' Код команды просмотра
		
		Dim sFileName		' имя файла
		Dim nFileSize		' размер файла в байтах
		Dim oFileName		' контрол с именем файла
		Dim sTitle			' заголовок диалога выбора
		Dim nCMD			' код выполняемой команды
		Dim sFilters		' фильтр
		Dim sFileExt		' расширение имени файл
		Dim nPosX			' "экранная" позиция меню, Х-координата
		Dim nPosY			' "экранная" позиция меню, Y-координата
		
		' Получаем элемент с именем локального файла
		Set oFileName = FileNameHtmlElement
		' Получаем идентификатор объекта - контейнера свойства
		' Получаем размер
		nFileSize = DataSize
		' Получаем заголовок
		sTitle = toString( HtmlElement.getAttribute("ChooseFileTitle") )
		' Получаем фильтры
		sFilters = Trim( toString( HtmlElement.getAttribute("FileNameFilters") ) )
		
		' Получаем имя локального файла
		sFileName = XmlProperty.getAttribute( IMG_LOCAL_FILE_NAME )
		If Not hasValue(sFileName) Then sFileName = Trim(ToString(oFileName.Value))
		If hasValue(sFileName) Then
			' Вычленяем расширение файла: если оно есть (в этом случае ToString 
			' вернет непустую строку), то в нем выкусываются все точки:
			sFileExt = Replace( ToString( XService.GetFileExt(sFileName) ), ".", "" )
		End If	
		
		If IsEmpty(m_oPopUpMenu) Then
			Set m_oPopUpMenu = XService.CreateObject("CROC.XPopupMenu")
		End If
		' Строим popup-меню
		m_oPopUpMenu.Clear
		m_oPopUpMenu.Add "Загрузить на сервер..." , FM_UPLOAD, True
		If 0 = SafeCLng(HtmlElement.getAttribute("X_OFF_CLEAR")) Then
			m_oPopUpMenu.Add "Очистить", FM_CLEAR, nFileSize>0
		End If
		' Просмотреть можно только файл, у которого есть расширение
		If 0 = SafeCLng(HtmlElement.getAttribute("X_OFF_VIEW")) Then
			m_oPopUpMenu.Add "Просмотр", FM_VIEW, Len(sFileExt)>0
		End If
		m_oPopUpMenu.AddSeparator
		m_oPopUpMenu.Add "Сохранить на диске...", FM_DOWNLOAD, nFileSize>0
		
		' Определяем экранные координаты кнопки, для точного позиционирования меню
		X_GetHtmlElementScreenPos HtmlElement, nPosX, nPosY
		nPosY = nPosY + HtmlElement.offsetHeight
		' Отображаем меню...
		nCMD = m_oPopUpMenu.Show( nPosX, nPosY )
		
		' Обрабатываем выбранный пункт
		Select Case nCMD
			Case FM_VIEW
				If IsLoaded Then
					' Данные прогружены, т.е. находятся ВНУТРИ xml
					' Запишем содержимое на жесткий диск во временный каталог и просмотрим
					sFileName = WriteToTempFileEx( sFileExt )
					' Об ошибке сообщит вызываемая функция
					If IsEmpty(sFileName) Then Exit Sub
					
					On Error Resume Next
					
					' "Выполним" его...
					XService.ShellExecute sFileName
					' Если была ошибка - отображаем сообшение 
					If 0<>err.number Then
						X_ErrReportEx  "Ошибка при попытке просмотра файла '" & sFileName &  "'" & vbNewLine & err.Description, err.Source 
						On Error Goto 0
						Exit Sub	
					End If	
					On Error Goto 0
					
					' Дождёмся пока пользователь не нажмет OK в данном диаложке сообщения...
					MsgBox "По завершении просмотра нажмите ""OK""", vbInformation, "Просмотр файла"
					
					KillTempFile sFileName
				Else
					' Загрузим с сервера (но НЕ через LoadProp)
					' получим имя временного файла
					sFileName = XService.GetTempPath & sFileName
					nFileSize = DataSize
					' запустим диалог загрузки
					X_ShowModalDialogEx _
						XService.BaseURL & "x-download.aspx", _
						Array( PropertyUrl, sFileName, 0, True), _
						"dialogWidth:400px; dialogHeight:150px; help:no; center:yes; status:no"					
				End If
			Case FM_CLEAR
				' если пользователь не согласен - ничего не делаем
				If Not Confirm( "Вы уверены?") Then Exit Sub
				ClearValue
			Case FM_UPLOAD
				If Not hasValue(sTitle) Then sTitle = "Выберите файл"
				If Not hasValue(sFilters) Then sFilters = "Все файлы (*.*)|*.*||"
				' Выбираем файл
				sFileName = toString( XService.SelectFile( _
					sTitle, _
					BFF_PATHMUSTEXIST or BFF_FILEMUSTEXIST or BFF_HIDEREADONLY, _
					"", _
					sFileName, _
					sFilters ) )
				' Если ничего не выбрали - выходим из процедуры
				If Not hasValue(sFileName) Then Exit Sub
				UploadFile sFileName
			Case FM_DOWNLOAD
				' Инициируем закачку файла
				If Not hasValue(sFilters) Then sFilters = "Все файлы (*.*)|*.*||"
				sFileName = ToString( XService.SelectFile("Укажите файл для сохранения", BFF_SAVEDLG, "", sFileName, sFilters) )
				If hasValue(sFileName) Then
					If IsLoaded Then
						' процесс выполняется под контролем ошибок:
						On Error Resume Next
						XService.SaveFileData sFileName, XmlProperty.nodeTypedValue
						' Если была ошибка - отображаем сообшение 
						If 0<>Err.Number Then
							X_ErrReportEx "Ошибка при попытке записи в файл '" & sFileName & "'" & vbNewLine & Err.Description, err.Source 
						End If	
						On Error Goto 0
					Else
						nFileSize = DataSize
						' запустим диалог загрузки
						X_ShowModalDialogEx _
							XService.BaseURL & "x-download.aspx", _
							Array( PropertyUrl , sFileName, 0, False) , _
							"dialogWidth:400px; dialogHeight:150px; help:no; center:yes; status:no"
					End If
				End If
		End Select		
	end Sub
	
	
	'-------------------------------------------------------------------------------
	' Обработчик клика кнопки "...". Начинает показ меню операций.
	Public Sub ShowMenu
		If IsPicture Then
			ShowPictureMenu
		Else
			ShowFileMenu
		End If	
	End Sub
		
	
	'==========================================================================
	' Помечает свойство как модифицированное
	Private Sub SetDirty
		m_oPropertyEditorBase.ObjectEditor.SetXmlPropertyDirty XmlProperty
	End Sub
	
	
	'==========================================================================
	' Возбуждает событие
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	
	
	
	'==========================================================================
	' Обработчик Html-события OnKeyUp на кнопке. Внимание: для внутренного использования.
	Public Sub Internal_OnKeyUp()
		Dim oEventArgs		' As AccelerationEventArgsClass
		
		If window.event Is Nothing Then Exit Sub
		window.event.cancelBubble = True
		Set oEventArgs = CreateAccelerationEventArgsForHtmlEvent()
		Set oEventArgs.Source = Me
		FireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' если нажатая комбинация не обработана - передадим ее в редактор
			ObjectEditor.OnKeyUp Me, oEventArgs
		End If
	End Sub
End Class
