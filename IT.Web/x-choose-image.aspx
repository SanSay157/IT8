<%@ Page 
	Language="C#" 
	ValidateRequest="false" 
	AutoEventWireup="true" 

	MasterPageFile="~/xu-choose-image.master" 
	
	Inherits="Croc.XmlFramework.Web.XChooseImagePage" 
	
	EnableViewState="false"
	EnableSessionState="True" 
 Codebehind="x-choose-image.aspx.cs" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolderForContent" Runat="Server">
	<SCRIPT LANGUAGE="VBScript" TYPE="text/vbscript" >
	
	Option Explicit
	
	'------------------------------------------------------------------------------
	' Глобальные переменные страницы
	Dim g_sFileName			' текущий выбранный файл
	Dim g_bIsEmpty			' признак отсутствия картинки
	Dim g_bIsModified		' признак модификации 
	Dim g_sInitFileName		' начальное имя файла с картинкой
	Dim g_sFilters			' строка фильтров
	Dim g_nMaxFileSize		' максимальный размер файла (0, если не используется)
	Dim g_nMinHeight		' ограничение на... 
	Dim g_nMaxHeight		'	... геометрические... 
	Dim g_nMinWidth			'		... размеры...
	Dim g_nMaxWidth			'			...  изображения (0, если не используется)	
	' HTML-контролы
	Dim cmdBrowse
	Dim cmdClear
	Dim cmdOk
	Dim cmdCancel
	Dim idImage
	Dim xPaneCaption

	'------------------------------------------------------------------------------
	' Инициализация страницы
	Sub Window_OnLoad()
		Dim sCaption	' заголовок страницы
		
		Internal_InitHtmlControls()
		' Получаем входные параметры страницы
		g_sFileName = ""
		With X_GetDialogArguments(Null) 
			sCaption = .Caption
			g_sInitFileName = "" & .URL
			g_sFilters = "" & .Filters
			g_nMaxFileSize = SafeCLng(.MaxFileSize)
			g_nMinHeight = SafeCLng(.MinHeight)
			g_nMaxHeight = SafeCLng(.MaxHeight)
			g_nMinWidth = SafeCLng(.MinWidth)
			g_nMaxWidth = SafeCLng(.MaxWidth)
			If .OffClear = True Then cmdClear.Style.Display = "NONE"
		End With
		
		If 0<>Len(sCaption) Then xPaneCaption.InnerHtml = sCaption
		g_bIsEmpty = (Len(g_sInitFileName)=0)
		g_bIsModified = False
		If Len(g_sInitFileName) Then
			DoLoadImage g_sInitFileName
		Else
			DoApplyButtons		
		End If
	End Sub


	'------------------------------------------------------------------------------
	' Инициализирует ссылки на Html-контролы
	Sub Internal_InitHtmlControls()
		Set cmdBrowse = document.all("XChooseImage_cmdBrowse")
		Set cmdClear = document.all("XChooseImage_cmdClear")
		Set cmdOk = document.all("XChooseImage_cmdOk")
		Set cmdCancel = document.all("XChooseImage_cmdCancel")
		Set idImage = document.all("idImage")
		Set xPaneCaption = document.all("XChooseImage_xPaneCaption")
	End Sub
	
	
	'------------------------------------------------------------------------------
	' Устанавливает доступность кнопок в соответствии g_bIsModified и g_bIsEmpty
	Sub DoApplyButtons
		cmdBrowse.disabled = False
		cmdClear.disabled = g_bIsEmpty
		cmdOK.disabled = Not(g_bIsModified)
		cmdCancel.disabled = False
	End Sub


	'------------------------------------------------------------------------------
	' Инициирует загрузку изображения с указанного адреса
	' [in] sURL   - URL для загрузки картинки
	Sub DoLoadImage(sURL)
		cmdBrowse.disabled = True
		cmdOK.disabled = True
		idImage.style.display="NONE"
		g_sFileName = sURL
		idImage.src = sURL
	End Sub


	'<ОБРАБОТЧИКИ IMAGE>
	'------------------------------------------------------------------------------
	' Если картинка не прогружена из-за того, что процесс прерван пользователем...
	Sub idImage_OnAbort
		MsgBox "Загрузка прервана: " & vbNewLine & g_sFileName, vbExclamation, "Внимание"
		XChooseImage_cmdClear_OnClick()  
	End Sub

	'------------------------------------------------------------------------------
	' ... или случилась какая ошибка
	Sub idImage_OnError
		MsgBox "Ошибка при загрузке изображения: " & vbNewLine & g_sFileName & vbNewLine & Err.Description, vbCritical, "Ошибка"
		XChooseImage_cmdClear_OnClick()  
	End Sub

	'------------------------------------------------------------------------------
	' Если картинка прогружена нормально
	Sub idImage_OnLoad
		Dim sImgProps	'строка с описанием изображения
		Dim nWidth		'ширина изображения
		Dim nHeight		'высота изображения
		
		'пока изображение скрыто - мы не получим его размеров. Поэтому
		'покажем его на мнгновение, получим размеры, после чего опять скроем
		idImage.style.display="BLOCK"
		nWidth  = CLng( idImage.width)
		nHeight = CLng( idImage.height)
		idImage.style.display="NONE"
		If 0<>Len(g_sFileName) Then
			' Проверим допустимую ширину и высоту изображения
			If g_nMaxHeight > 0 Then
				If g_nMaxHeight < nHeight Then
					Alert "Максимальная допустимая высота изображения в пикселях равна " & g_nMaxHeight & vbNewLine & "Высота выбранного изображения равна " & nHeight 
					XChooseImage_cmdClear_OnClick()  
					Exit Sub
				End If
			End If
			If g_nMaxWidth > 0 Then
				If g_nMaxWidth < nWidth Then
					Alert "Максимальная допустимая ширина изображения в пикселях равна " & g_nMaxWidth & vbNewLine & "Ширина выбранного изображения равна " & nWidth 
					XChooseImage_cmdClear_OnClick()  
					Exit Sub	
				End If
			End If
			If g_nMinHeight > nHeight Then
				Alert "Минимальная допустимая высота изображения в пикселях равна " & g_nMinHeight & vbNewLine & "Высота выбранного изображения равна " & nHeight 
				XChooseImage_cmdClear_OnClick()  
				Exit Sub
			End If
			If g_nMinWidth > nWidth Then
				Alert "Минимальная допустимая ширина изображения в пикселях равна " & g_nMinWidth & vbNewLine & "Ширина выбранного изображения равна " & nWidth 
				XChooseImage_cmdClear_OnClick()  
				Exit Sub
			End If
			' Проверим допустимый размер файла
			If g_nMaxFileSize > 0 Then
				If g_nMaxFileSize < CLng(idImage.fileSize) Then
					Alert "Максимальный допустимый размер файла изображения в байтах равен " & g_nMaxFileSize & vbNewLine & "Размер файла выбранного изображения равен " & idImage.fileSize  
					XChooseImage_cmdClear_OnClick()  
					Exit Sub
				End If
			End If
			idImage.style.display="BLOCK"
		End If
		g_bIsModified = (g_sFileName<>g_sInitFileName)
		g_bIsEmpty = false
		
		sImgProps = ""
		if g_bIsModified then sImgProps = "Выбранный файл изображения: " & vbNewLine & g_sFileName & vbNewLine & vbNewLine
		sImgProps = sImgProps & _
			"Размеры изображения (в пикселях): " & nWidth & " x " & nHeight & vbNewLine & _
			"Объём изображения (в байтах): " & idImage.fileSize 
		
		idImage.alt = sImgProps
		DoApplyButtons
	End Sub
	'</ОБРАБОТЧИКИ IMAGE>
	

	'</ОБРАБОТЧИКИ КНОПОК>
	'------------------------------------------------------------------------------
	' Выводит диалог выбора имени файла и пытается загрузить его
	Sub XChooseImage_cmdBrowse_OnClick
		Dim sCurrentFilter	' Строка с фильтром-перечнем расширений файлов
		Dim sImagePath		' Итоговое имя файла выбранной картинки
		
		If 0 = Len(g_sFilters) Then
			sCurrentFilter = "Изображения|*.gif;*.jpg;*.jpeg;*.bmp;*.png|Все файлы|*.*||"
		Else
			sCurrentFilter = g_sFilters
		End If
		
		sImagePath = XService.SelectFile( _
			"Выберите файл с изображением", _
			BFF_FILEMUSTEXIST or BFF_PATHMUSTEXIST or BFF_HIDEREADONLY, _
			"", "", sCurrentFilter )
			
		If 0<>Len(sImagePath ) Then
			DoLoadImage sImagePath 
		End If
	End Sub
	
	'------------------------------------------------------------------------------
	' Очистка изображения
	Sub XChooseImage_cmdClear_OnClick
		g_bIsEmpty = true
		g_bIsModified = (Len(g_sInitFileName)>0)
		g_sFileName = ""
		idImage.style.display="NONE"
		DoApplyButtons
	End Sub 

	'------------------------------------------------------------------------------
	' При нажатии на кнопку OK - возвращаем результат...
	Sub XChooseImage_cmdOK_OnClick
		If g_bIsEmpty Then
			X_SetDialogWindowReturnValue Null
		Else
			X_SetDialogWindowReturnValue g_sFileName 
		End If	
		window.close
	End Sub

	'------------------------------------------------------------------------------
	' При нажатии на кнопку Отмена - просто закрываем окно (Empty вернётся автоматом)
	Sub XChooseImage_cmdCancel_OnClick
		X_SetDialogWindowReturnValue Empty
		window.close
	End Sub
	'</ОБРАБОТЧИКИ КНОПОК>
	
	'------------------------------------------------------------------------------
	' Обработчик нажатия клавиши в окне
	Sub Document_onKeyPress()
		Select Case window.event.keyCode
			Case VK_ENTER 'Enter
				If Not cmdOK.disabled then XChooseImage_cmdOk_OnClick
			Case VK_ESC 'Esc
				If Not cmdCancel.disabled then XChooseImage_cmdCancel_OnClick
		End Select
	End Sub

	</SCRIPT>

	<DIV STYLE="position:relative; height:100%; width:100%; overflow:auto; padding:0; margin:0; border:#fff groove 2px;">
		<!-- Изображение дополнительно заключено в таблицу - чтобы отцентрировать -->
		<TABLE CELLPADDING="0" CELLSPACING="0" STYLE="height:100%; width:100%; border:none;">
			<TR>
				<TD STYLE="text-align:center; vertical-align:middle;"><IMG ID="idImage" STYLE="border:none;" SRC="Images\x-open-help.gif"></TD>
			</TR>
		</TABLE>
	</DIV>
</asp:Content>

