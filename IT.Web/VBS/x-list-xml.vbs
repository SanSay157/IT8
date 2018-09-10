Option Explicit

Class XListPageClass
	Public MetaName						' As String	- Имя списка в метаданных
	Public ObjectType					' As String	- наименование типа объектов в списке
	Private m_nMode						' As Byte - Режим работы списка (LM_LIST, LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE)
	Private m_oListView					' As CROC.IXListView - контрол списка
	Private m_sViewStateCacheFileName	' - наименование ключа для сохранения описания колонок в клиентском кэше
	Private m_oListMD					' As IXMLDOMElement - метаданные списка (i:objects-list-xml)
	Private m_oObjectEditor				' As ObjectEditor - ссылка на редактор, передается при инициализации, используется для вычисления выражений колонок
	Private m_bMayBeInterrupted			' As Boolean - признак возможности безопасного закрытия страницы
	
	'==========================================================================
	' "Конструктор"
	Private Sub Class_Initialize
		m_bMayBeInterrupted = true
		If IsObject(g_oXListPage) Then _
			If Not g_oXListPage Is Nothing Then _
				Err.Raise -1, "XListPageClass::Class_Initialize", "Допустимо существование только одного экземпляра XListPageClass"
		ObjectType = X_PAGE_OBJECT_TYPE
		MetaName = X_PAGE_METANAME
		m_nMode = LIST_MODE
		m_sViewStateCacheFileName = GetCacheFileName("columns")
    End Sub	


	'==========================================================================
	' Инициализация страницы
	'   [in] oSelectFromXmlListDialogParams As SelectFromXmlListDialogParamsClass
	Sub Internal_Init(oSelectFromXmlListDialogParams)
	    Dim vListMD 
	    
		Set m_oListView = document.all( "List")

		' Если режим отбора нескольких объектов, включаю показ флажков
		If LM_MULTIPLE = Mode OR LM_MULTIPLE_OR_NONE = Mode Then
			m_oListView.CheckBoxes = True
		End If
		m_oListView.LineNumbers = Not LIST_MD_OFF_ROWNUMBERS
		m_oListView.GridLines = Not LIST_MD_OFF_GRIDLINES

        ' получим метаданные страницы
	    Set vListMD = document.all("oListMD",0)
	    If Not vListMD Is Nothing Then 
		    vListMD = vListMD.value
		Else
		    Alert "Не найдены метаданные страницы"
		    Exit Sub
		End If
		Set m_oListMD = XService.XMLFromString(vListMD)
		
		Set m_oObjectEditor = oSelectFromXmlListDialogParams.ObjectEditor
		
		' инициализируем преставление списка (колонки)
		InitXListViewInterface m_oListView, m_oListMD, m_sViewStateCacheFileName, True

		' заполним список данным
		FillXListViewEx3 m_oListView, m_oObjectEditor, oSelectFromXmlListDialogParams.Objects, m_oListMD, Null, False
		
		' установим выделение на первую строку (обязательно сначала установим фокус)
		SetListFocus
		If m_oListView.Rows.Count > 0 Then 
			m_oListView.Rows.SelectedPosition = 0
		End If
		
		EnableControls True
		g_bFullLoad = True
	End Sub


	'==========================================================================
	' Возвращает режим работы страницы: LM_SINGLE, LM_MULTIPLE, LM_MULTIPLE_OR_NONE
	Public Property Get Mode
		Mode = m_nMode
	End Property


	'==========================================================================
	' Признак того, что со страницы может быть выполнен безопасный уход
	' Используется в window_OnBeforeUnload
	Public Property Get MayBeInterrupted
	    MayBeInterrupted = m_bMayBeInterrupted
	End Property 


	'==============================================================================
	' Возвращает имя файла для сохранения пользовательских данных
	'	[in] sSuffix - суфикс имени
	'	[retval] наименование файла
	Private Function GetCacheFileName(sSuffix)
		GetCacheFileName = "XL.XML." & ObjectType & "." & MetaName & "." & sSuffix
	End Function


	'==========================================================================
	' Устанавливает фокус на список
	Public Sub SetListFocus()
		window.Focus()
		' установка фокуса выполняется под контролем ошибки - т.к. сам список
		' в силу внешних причин (отсутствие прав, функционал прикладных обработчиков 
		' и т.д.) может быть недоступен или скрыт
		on error resume next
		m_oListView.Focus()
		on error goto 0
	End Sub	


	'==========================================================================
	' Разрешение/отключение управляющих элементов страницы
	Sub EnableControls( bEnable)
		enableControl "XList_cmdOpenHelp", bEnable
		enableControl "XList_cmdOk", bEnable
		enableControl "XList_cmdCancel", bEnable
		enableControl "XList_cmdSelectAll", bEnable
		enableControl "XList_cmdInvertSelection", bEnable
		enableControl "XList_cmdDeselect", bEnable
		XService.DoEvents
	End Sub


	'==========================================================================
	' Разрешение/включение управляющего элемента по имени управляющего элемента
	' с проверкой, что элемент есть на странице
	Private Sub enableControl( sCtlName, bEnable)
		Dim oCtl
		Set oCtl = document.all( sCtlName)
		
		if not oCtl is nothing then
			oCtl.disabled = not bEnable
		end if
	End Sub


	'==============================================================================
	' Обработчик кнопки "OK"
	'	[in] oEventArg As ListSelectEventArgsClass
	Sub OnOk()
	    With New ListSelectEventArgsClass
		    If LM_SINGLE = Mode Then
			    ' В режиме отбора одного объекта получаем идентификатор выбранного
			    .Selection = getSelectedObjectID()
		    Else
			    ' В режиме отбора нескольких объектов формируем массив идентификаторов
			    .Selection= getCheckedObjectIDs()		
		    End If
		    Select Case Mode
			    Case LM_SINGLE
				    If 0<>Len(.Selection) Then
					    X_SetDialogWindowReturnValue .Selection
					    window.close
				    Else
					    Alert "Нужно выбрать объект"
				    End if
			    Case LM_MULTIPLE
				    If UBound(.Selection)>=0 Then
					    X_SetDialogWindowReturnValue .Selection
					    window.close
				    Else
					    Alert "Нужно отметить хотя бы один объект"
				    End If
			    Case LM_MULTIPLE_OR_NONE
					X_SetDialogWindowReturnValue .Selection
				    window.close
		    End Select 
	    End With	
	End Sub


	'==========================================================================
	' Возвращает идентификатор выбранного объекта или пустую строку
	Private Function getSelectedObjectID()
		getSelectedObjectID = m_oListView.Rows.SelectedID
	End Function


	'==========================================================================
	' Возвращает массив идентификаторов отмеченных строк
	Private Function getCheckedObjectIDs
		Dim vSel
		Dim nIdx
		Dim i
		
		ReDim vSel(m_oListView.Rows.Count - 1)	' Распределяем массив по количеству строк в списке
		nIdx = 0
		With m_oListView.Rows
			For i=0 To .count -1
				With .GetRow(i)
					If .Checked Then
						vSel( nIdx) = .ID	' Заносим идентификаторы отобранных строк в массив
						nIdx = nIdx + 1
					End If
				End With
			Next
		End With
		ReDim Preserve vSel(nIdx - 1)	' Оставляем в массиве только идентификаторы
		getCheckedObjectIDs = vSel
	End Function
	
	
	'==============================================================================
	' В режиме множественного выбора отмечает все строки
	Public Sub SelectAll
		Dim i
		If Mode <> LM_MULTIPLE And Mode <> LM_MULTIPLE_OR_NONE Then Exit Sub
		For i=0 to m_oListView.Rows.Count -1
			m_oListView.Rows.GetRow(i).Checked = True
		Next
	End Sub


	'==============================================================================
	' В режиме множественного выбора снимает отметку со всех выбранных строк
	Public Sub DeselectAll
		Dim i
		If Mode <> LM_MULTIPLE And Mode <> LM_MULTIPLE_OR_NONE Then Exit Sub
		For i=0 to m_oListView.Rows.count -1
			m_oListView.Rows.GetRow(i).Checked = false
		Next
	End Sub


	'==============================================================================
	' В режиме множественного выбора 
	Public Sub InvertSelection
		Dim i
		If Mode <> LM_MULTIPLE And Mode <> LM_MULTIPLE_OR_NONE Then Exit Sub
		For i=0 To m_oListView.Rows.count -1
			With m_oListView.Rows.GetRow(i)
				.Checked = NOT .Checked
			End With
		Next
	End Sub
	
	'==============================================================================
	' состояние выбранной строки
	Public Sub ChangeSelectedRowState
		Dim nRow	' индекс выбранной строки
		
		If Mode <> LM_MULTIPLE And Mode <> LM_MULTIPLE_OR_NONE Then Exit Sub
		nRow = m_oListView.Rows.Selected
		If nRow>=0 Then
			m_oListView.Rows.GetRow(nRow).Checked = Not m_oListView.Rows.GetRow(nRow).Checked 
		End If
	End Sub

	
	'==============================================================================
	' Обработчик закрытия страницы
	Public Sub Internal_OnUnLoad
		X_SaveViewStateCache m_sViewStateCacheFileName, m_oListView.Columns.Xml
	End Sub
End Class

Dim g_oXListPage		' As XListPageClass
Dim g_nThisPageID		' Уникальный идентификатор текущей страницы
Dim g_bFullLoad			' Признак полной загрузки страницы

'==============================================================================
' Инициализация скрипта (ПРОИСХОДИТ ДО инициализации страницы)
'...загрузка только начата...
g_bFullLoad = False
'...сформируем уникальный ID...
g_nThisPageID = CLng( CDbl( Time()) * 1000000000 )


'==============================================================================
' Инициализация страницы.
' Вызывается по готовности страницы, в том числе фильтра.
Sub Init()
    Dim oSelectFromXmlListDialogParams
    X_GetDialogArguments oSelectFromXmlListDialogParams
    If TypeName(oSelectFromXmlListDialogParams) <> "SelectFromXmlListDialogParamsClass" Then
        Alert "Ошибка: в страницу x-select-from-xml в dialogArguments должен быть передан экземпляр класса SelectFromXmlListDialogParamsClass"
        window.close
    End If
	Set g_oXListPage = New XListPageClass
	g_oXListPage.Internal_Init oSelectFromXmlListDialogParams
End Sub


'<ОБРАБОТЧИКИ window и document>
'==============================================================================
' Инициализация страницы
Sub Window_OnLoad()	
	X_WaitForTrue "Init()" , "X_IsDocumentReady(null)"
End Sub

'==============================================================================
' Финализация страницы
Sub Window_OnUnLoad()
	g_nThisPageID = Empty	' Сбрасываем идентификатор
	
	' Если список был недогружен делать ничего не будем!
	If True <> g_bFullLoad Then Exit Sub
	
	g_oXListPage.Internal_OnUnLoad
End Sub


'==============================================================================
' Попытка выгрузки страницы
Sub Window_onbeforeunload
	If Not IsObject(g_oXListPage) Then Exit Sub
	If Nothing Is g_oXListPage Then Exit Sub
	If g_oXListPage.MayBeInterrupted Then Exit Sub
	window.event.returnValue="Внимание!" & vbNewLine & "Закрытие окна в данный момент может привести к возникновению ошибки!"
End Sub

'==============================================================================
' Нажатие клавиши
Sub Document_onkeyUp
	' Клавиша моежт быть нажата еще до того, как будет 
	' проинициализирован экземпляр g_oXListPage: если это так,
	' то ничего не делаем:
	If Not hasValue(g_oXListPage) Then Exit Sub

	If window.event.keyCode = VK_ESC Then
		' нажали Escape в режиме выбора
		XList_cmdCancel_OnClick
	End If
End Sub
 

'==============================================================================
' Обработчик вызова справки
Sub Document_OnHelp
	If True <> g_bFullLoad Then Exit Sub
	If X_MD_HELP_AVAILABLE Then
		window.event.returnValue = False
		X_OpenHelp X_MD_HELP_PAGE_URL
	End If
End Sub
'<ОБРАБОТЧИКИ window и document>


'<ОБРАБОТЧИКИ КНОПОК>
'==============================================================================
' Закрытие окна в режиме отбора по кнопке "OK"
Sub XList_cmdOk_OnClick()
	If document.all( "XList_cmdOk").disabled Then Exit Sub	' Если кнопка заблокирована - ничего не бум делать!
	g_oXListPage.OnOk 
End Sub


'==============================================================================
' Закрытие окна в режиме отбора по кнопке "Отменить"
Sub XList_cmdCancel_OnClick()
	window.close
End Sub


'==============================================================================
' Выбор всех объектов в списке
Sub XList_cmdSelectAll_OnClick
	g_oXListPage.SelectAll
End Sub


'==============================================================================
' Снятие выделения
Sub XList_cmdDeselect_OnClick
	g_oXListPage.DeselectAll
End Sub


'==============================================================================
' Инверсия выделения
Sub XList_cmdInvertSelection_OnClick
	g_oXListPage.InvertSelection
End Sub


'==============================================================================
' Обработчик нажатия на кнопку "справка"
Sub XList_cmdOpenHelp_OnClick
	Document_OnHelp
End Sub
'</ОБРАБОТЧИКИ КНОПОК>


'==============================================================================
' Обработчик события "OnDblClick" ActiveX-компонента CROC.IXListView - Двойное нажатие в строке списка
Sub XListPage_OnDblClick(ByVal oSender, ByVal nIndex , ByVal nColumn, ByVal sID)
    If LM_SINGLE = g_oXListPage.Mode Then
		' Для режимов отбора одного элемента эмулируем нажатие ОК	
		XList_cmdOk_OnClick
	Else
		' Для режимов отбора множества элементов (LM_MULTIPLE, LM_MULTIPLE_OR_NONE) эмулируем клик на чекбоксе строки
		g_oXListPage.ChangeSelectedRowState
	End If	
End Sub


'==============================================================================
' Нажатие клавиши в списке
Sub XListPage_OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)
	If nKeyCode = VK_ENTER Then
		' нажали Enter в режиме выбора
		XList_cmdOk_OnClick()
	End If
End Sub
