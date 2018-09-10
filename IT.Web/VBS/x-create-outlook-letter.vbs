' MOLE-VBS-SCRIPT - указание компрессору
'<SCRIPT LANGUAGE="VBS"> ' Чтоб синтаксис подсвечивался
'
' Данный файл содержит одну единственную функцию и используется при необходимости создания письма на клиенте
'
'############################################################################################################
' Создает письмо в MS Outlook. В случае проблем возникает exception
' [in] sTo				- адресат
' [in] sCC				- копия
' [in] sBCC				- скрытая копия
' [in] sSubject			- тема
' [in] sMessage			- сообщение
' [in] bMessageInHTML	- признак, что sMessage - уже в формате HTML
' [in] bLeaveSign		- признак необходимости добавить стандартную к письму подпись
' [in] vXService		- XControls.IXClientService, вспомогательный объект для создания 
'							небезопасных для скриптинга компонетов (НЕОБЯЗАТЕЛЕН)
' [retval]				- Outlook.MailItem - созданное письмо
'
Function X_CreateOutlookLetter(sTo, sCC, sBCC, sSubject, ByVal sMessage, bMessageInHTML, bLeaveSign, vXService)
	' Константы, задающие формат письма
	Const OL_FORMAT_RTF = 3     ' Письмо в формате RTF
	Const OL_FORMAT_HTML = 2    ' Письмо в формате HTML

	Dim oLetter				' Outlook.MailItem
	Dim sHTMLBody			' HTML-текст письма
	Dim nPos, nPos2, nPos3	' Позиции в строке для разбора текста (см далее по алгоритму)

	const INTERNAL_NEW_LINE = "[brHere]" ' псевдо-тег для обозначения переноса строки
	
	' Создадим объект Outlook.MailItem
	If IsObject( vXService) then
		If Nothing Is vXService then
			Set oLetter = CreateObject("Outlook.Application").CreateItem(0)
		Else
			Set oLetter = vXService.CreateObject("Outlook.Application").CreateItem(0)
		End If
	Else
		Set oLetter = CreateObject("Outlook.Application").CreateItem(0)
	End If	

	' Ведущие "" добавляются для подавления ошибки если sTo, sCC, sBCC, sSubject - NULL
	oLetter.To = "" & sTo
	oLetter.CC = "" & sCC
	oLetter.BCC = "" & sBCC
	oLetter.Subject = "" & sSubject
	
    On Error Resume Next
    ' Покажем письмо
    oLetter.Display
    If Err Then
        MsgBox "Ошибка создания окна с новым сообщением MS Outlook. " & _
			   "Попробуйте закрыть модальные окна с новыми сообщениями MS Outlook" _
			    & vbNewLine & Err.Description
        Exit Function
    End If
    On Error GoTo 0
    
	' Выкусываем из HTML текста письма (на данный момент там только подпись)
	' т.к. Outlook очень странно преобразует их в RTF формат
	' все теги <A... </A>, текст сссылок (что между тегами) оставляем
    if OL_FORMAT_HTML = oLetter.BodyFormat or OL_FORMAT_RTF = oLetter.BodyFormat then
		sHTMLBody = oLetter.HTMLBody
		
		do while 0 < InStr( UCase(sHTMLBody), "<A" ) 
			' Начало тега
			nPos = InStr( UCase(sHTMLBody), "<A" ) 
			' Конец тега <A... 
			nPos2 = InStr( nPos, sHTMLBody, ">" )
			' Начало тега </A> (его конец не ищем, т.к. длина известна)
			nPos3 = InStr( nPos2, UCase(sHTMLBody), "</A>" ) 
			' Собираем новое тело письма по кусочкам.
			' сначала то, что до открывающего тега
			' потом от конца открывающего то начала закрывающего тегов
			' и все, что осталось после конца закрывающего тега
			
			sHTMLBody = left( sHTMLBody, nPos - 1 ) & _
				Mid( sHTMLBody, nPos2 + 1, nPos3 - nPos2 - 1 ) & _
				Right( sHTMLBody, len( sHTMLBody ) - nPos3 - len("</A>") + 1)
			' и продолжаем пока не останется таких тегов
		loop
		' Делаем это новым телом письма
		' Небольшое лирическое отступление - при формировании письма, даже если 
		' вышеописанные манипуляции по преобразованию текста подписи не делать,
		' то пару присваиваний .HTMLBody -> переменная и переменная -> .HTMLBody
		' надо все равно делать для корректной инициализации текста письма
		' перед его преобразованием в формат RTF - иначе подпись потеряется.
		' Вот такое шаманство и бубен. Но только если изначальный формат 
		' HTML или RTF, при Plain text этим содержимое будет испорчено!
		oLetter.HTMLBody = sHTMLBody
	end if
	
	' Формируем письмо в режиме RTF для избежания лишних преобразований кодовой страницы
	oLetter.BodyFormat = OL_FORMAT_RTF
	
	' Пояснение к приписыванию пробела к телу письма ниже: 
	' Хитрый фокус для корректного создания письма с изначально пустым (совсем) телом:
	' если там совсем ничего нет, то .HTMLBody не возвращает нужных заголовков - 
	' "обвеса", позволяющего outlook'у корректно работать с HTML письмом
	' в кодировке 1251
	If not bLeaveSign or 0 = len(oLetter.Body) Then
		' очищаем исходное письмо или меняем его с совсем пустого на содержащее пробел
		' - останется только HTML обвеска
		oLetter.Body = " " 
	End If
	
	' Получим заготовку с подписью (или уже без нее) в виде HTML
	sHTMLBody = oLetter.HTMLBody

	If Not bMessageInHTML Then
		' Преобразуем сообщение в HTML-формат
		' т.к. аутлук при таком преобразовании проглатывает пустые строки,
		' пометим их символом [brHere], потом добавим переносы строк
		oLetter.Body = Replace( sMessage, vbNewLine, INTERNAL_NEW_LINE ) & " "
		sMessage = Replace( oLetter.HTMLBody, INTERNAL_NEW_LINE, "<BR/>" )
		' Выкусим все, что между <BODY>..</BODY>, в переменную
		nPos = InStr(InStr(1, sMessage, "<Body", vbTextCompare), sMessage, ">", vbBinaryCompare)
		sMessage = Mid(sMessage, nPos + 1, InStr(1, sMessage, "</Body", vbTextCompare) - nPos - 1)
	End If
	    
	' Вставим в исходную заготовку сразу после <BODY> наше сообщение
	nPos = InStr(InStr(1, sHTMLBody, "<Body", vbTextCompare), sHTMLBody, ">", vbBinaryCompare)
	sHTMLBody = Mid(sHTMLBody, 1, nPos + 1) & sMessage & Mid(sHTMLBody, nPos + 1)

	' Трюк имени А.Краснова:
	' удаляем из результата лишние теги и меняем их на правильные 
	' чтобы результат выглядел прилично в Word-редакторе e-mail'a
	sHTMLBody = Replace(sHTMLBody, "<P ALIGN=LEFT>","")
	sHTMLBody = Replace(sHTMLBody, "</P>","<BR/>")
	    
	' Подставим полученный текст
	oLetter.HTMLBody = sHTMLBody

	' Переводим сформированное письмо в режим HTML
	oLetter.BodyFormat = OL_FORMAT_HTML
	
	Set X_CreateOutlookLetter = oLetter
End Function



'</SCRIPT>
