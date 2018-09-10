Option Explicit

'==============================================================================
' Формирует и возвращает текст HTML разметки с кнопками меню
'	[in] oXmlMenuMD As IXMLDOMElement - xml-узел метаописания меню
'	[in] sMenuStyle - стиль меню: op-button, vertical-buttons, horizontal-buttons
'	[in] nButtonWidth - ширина кнопки меню в пикселях
'	[in] nButtonHeight - высота кнопки меню в пикселях
'	[in] sClassName - наименование css-класса(ов) стиля кнопок меню
Function XMENUHTC_getMenuButtonsHtml(oXmlMenuMD, sMenuStyle, nButtonWidth, nButtonHeight, sClassName)
	Dim oNode		' As IXMLDOMElement - xml-узел элемента меню
	Dim sHtml		' As String - формируемый текст HTML
	Dim nIndex		' As Int - индекс пункта меню 
	Dim sName		' As String - наименование пункта меню
	
	nIndex = 0
	If sMenuStyle = "op-button" Then
		sHtml = "<BUTTON ID='ButtonOperation' TITLE='Операции...' CLASS='" & sClassName & "' style='" & _
				"width:" & nButtonWidth & "px;"
		If nButtonHeight > 0 Then sHtml = sHtml & "height:" & nButtonHeight & "px;"
		sHtml = sHtml & _
					"' DISABLED=1 OnClick='Internal_OnOperationButtonClick Me'>" & _
					"Операции <SPAN STYLE='font-family:Webdings'>&#54;</SPAN>" & _
				"</BUTTON>"
	Else
		For Each oNode In oXmlMenuMD.selectNodes("*[local-name()='menu-item' or local-name()='menu-section']")
			If IsNull(oNode.getAttribute("n")) Then
				sName = nIndex
				oNode.setAttribute "n", sName
			Else
				sName = oNode.getAttribute("n")
			End If
			
			sHtml = sHtml & "<BUTTON language=VBScript class='" & sClassName & "' style='" & _
						"width:" & nButtonWidth & "px;"
			If nButtonHeight > 0 Then sHtml = sHtml & "height:" & nButtonHeight & "px;"
			If Not IsNull(oNode.getAttribute("hidden")) Then 
				sHtml = sHtml & "display:none;"
			Else
				sHtml = sHtml & "display:inline;"
			End If
			sHtml = sHtml & "'  " & _
				"title='" & oNode.getAttribute("hint") & "' disabled=1 "
			' Обработчики клика (в зависимости от типа пункта меню)
			If oNode.tagName = "i:menu-item"	Then
				sHtml = sHtml & " onclick='Internal_OnMenuButtonClick """ & sName & """'"
			ElseIf oNode.tagName = "i:menu-section" Then
				sHtml = sHtml & " onclick='Internal_OnMenuSectionButtonClick Me, """ & sName & """'"
			End If
			sHtml = sHtml & " X_MENU_ITEM_NAME='" & sName & "' ><CENTER>" & oNode.getAttribute("t") & "</CENTER></BUTTON>"
			If sMenuStyle = "vertical-buttons" Then sHtml = sHtml & "<BR>"

			nIndex = nIndex + 1
		Next
	End If
	XMENUHTC_getMenuButtonsHtml = sHtml
End Function


'==============================================================================
' Вычисляет экранные координаты левого нижнего узла кнопки
'	[in] oHTCRootElement - ссылка на element
'	[in] oButton As IHTMLElement - элемент кнопки
'	[out] nPosX - X координата 
'	[out] nPosY - Y координата 
Sub XMENUHTC_calculateElementScreenCoordinates(oHTCRootElement, oButton, nPosX, nPosY)
	Dim oElement	' As IHTMLElement
	
	X_GetHtmlElementScreenPos oHTCRootElement, nPosX, nPosY		
	Set oElement = oButton
	While hasValue(oElement)
		nPosX = nPosX + oElement.offsetLeft
		nPosY = nPosY + oElement.offsetTop
		Set oElement = oElement.offsetParent
	Wend
	nPosY = nPosY + oButton.offsetHeight
End Sub


'==============================================================================
' Внутренняя функция получения значения указанного атрибута master-element'a
' Если у элемента такого атрибута нет, функция возвращает заданное значение по умолчанию.
'	[in] oHTCRootElement - ссылка на element
'	[in] sAttrName		- наименование атрибута
'	[in] sDefaultValue	- значение по умолчанию
Function XMENUHTC_getHostElementAttributeValue( oHTCRootElement, sAttrName, sDefaultValue )
	Dim oAttribute		' html-атрибут
	
	Set oAttribute = oHTCRootElement.GetAttributeNode(sAttrName)
	If oAttribute Is Nothing Then 
		XMENUHTC_getHostElementAttributeValue = sDefaultValue
	Else
		If Len(oAttribute.nodeValue) > 0 Then
			XMENUHTC_getHostElementAttributeValue = oAttribute.nodeValue
		Else
			XMENUHTC_getHostElementAttributeValue = sDefaultValue
		End If
	End If
End Function


'==============================================================================
' Оьновляет состояние меню
'	[in] oMenu As MenuClass - меню
'	[in] oSender As Object - ссылка на произвольный объект, передаваемая в обработчики меню
'	[in] oContainer As IHTMLElement - контейнер, в котором содержатся кнопки меню
'	[in] bVisualUpdate As Boolean - признак следует ли обновлять визульное представление кнопок
'	[in] bAppDisabled As Boolean - признак заблокированности всех кнопок
Sub XMENUHTC_UpdateMenuState(oMenu, oSender, oContainer, bVisualUpdate, bAppDisabled)
	Dim oButton		' As IHTMLElement - кнопка (button)
	Dim sItemName	' Наименование пункта меню 
	Dim oMenuItem	' As IXMLDOMElement - xml-узел пункта меню
	Dim bDisabled	' As Boolean - признак заблокированности пункта
	Dim bHidden		' As Boolean - признак невидимости пункта

	' 2-ой параметр True означает выполнить visibility-handler'ы только для корневого уровня (ведь только для них отображатся кнопки)
	oMenu.PrepareMenuEx oSender, True

	For Each oButton In oContainer.all.tags("button")
		sItemName = oButton.getAttribute("X_MENU_ITEM_NAME")
		If Len(sItemName) > 0 Then
			Set oMenuItem = oMenu.XmlMenu.selectSingleNode("*[@n='" & sItemName & "']") 
			If Not oMenuItem Is Nothing Then
				bDisabled = Not IsNull(oMenuItem.getAttribute("disabled"))
				bHidden = Not IsNull(oMenuItem.getAttribute("hidden"))
				If Not bDisabled And Not bHidden Then
					oButton.setAttribute "X_WAS_ENABLED", "1"
					If bVisualUpdate Then 
						' расблокируем кнопку только если РЕ не заблокирован
						oButton.disabled = bAppDisabled
						' не удалять следующую строчку, без нее в некоторых случаях кнопка "обрезается"
						If LCase(oButton.style.display) = "none" Then oButton.style.display = "inline"
						oButton.outerHtml = oButton.outerHtml
					End If
				ElseIf bHidden Or bDisabled Then
					oButton.removeAttribute "X_WAS_ENABLED"
					If bVisualUpdate Then 
						oButton.disabled = True
						If bHidden Then
							oButton.style.display = "none"
						Else	' If bDisabled - единственный оставшийся вариант
							If LCase(oButton.style.display) = "none" Then oButton.style.display = "inline"
						End If
						oButton.outerHtml = oButton.outerHtml
					End If
				End If
			End If
		End If
	Next		
End Sub


'==============================================================================
' Устанавливает название операции, меняя заголовок соответствующей ей кнопки при необхордимости
'	[in] oMenu As MenuClass - меню
'	[in] oContainer As IHTMLElement - контейнер, в котором содержатся кнопки меню
'	[in] sItemName - наименование пункта меню (атрибут n)
'	[in] sItemTitle - заголовок пункта меню/кнопки (атрибут t)
'	[in] sItemHint - текст всплывающей подсказки. Если Null, то удалить подсказку, если Empty, то оставить существующую.
Sub XMENUHTC_SetMenuItemTitle(oMenu, oContainer, sItemName, sItemTitle, sItemHint)
	Dim oItem			' As IXMLDOMELement - xml-элемент меню
	Dim oButton			' As IHTMLElement - объект кнопки
	Dim sItemNameCur	' - наименование пункта меню
	
	Set oItem = oMenu.XmlMenu.selectSingleNode("i:menu-item[@n='" & sItemName & "']")
	If Not oItem Is Nothing Then
		oItem.setAttribute "t", sItemTitle
		If Not IsEmpty(sItemHint) Then
			If IsNull(sItemHint) Then
				oItem.removeAttribute "hint"
			Else
				oItem.setAttribute "hint", sItemHint
			End If
		End If
		' обновим состояние кнопки, если она есть
		For Each oButton In oContainer.all.tags("button")
			sItemNameCur = oButton.getAttribute("X_MENU_ITEM_NAME")
			If Len(sItemNameCur) > 0 Then
				If sItemNameCur = sItemName Then
					oButton.innerHtml = "<CENTER>" & sItemTitle & "</CENTER>"
					If Not IsEmpty(sItemHint) Then
						If IsNull(sItemHint) Then
							oButton.removeAttribute "title"
						Else
							oButton.setAttribute "title", sItemHint
						End If
					End If
					Exit For
				End If
			End If
		Next
	End If
End Sub


'==============================================================================
' Установка (не)доступности кнопок операций меню, без перестройки самого меню
'	[in] bEnable - признак доступности кнопок
'	[in] oContainer - контейнер (HTML-элемент), в котором можно получить все кнопки через коллекцию akk.tags("button")
Sub XMENUHTC_SetButtonsEnableState(bEnabled, oContainer)
	Dim oButton		' As IHTMLElement - Объект кнопки

	For Each oButton In oContainer.all.tags("button")
		If Not IsNull(oButton.getAttribute("X_MENU_ITEM_NAME")) Then
			If bEnabled = False Then
				' OFF
				If Not oButton.disabled Then
					' просят выключит включенную кнопку - выключим, но запомним ее состояние
					oButton.setAttribute "X_WAS_ENABLED", "1"
					oButton.disabled = True
				End If
			Else
				' ON
				If oButton.disabled Then
					' просят включить выключенную кнопку - включим, если до выключения она была включена
					If Not IsNull(oButton.getAttribute("X_WAS_ENABLED")) Then
						oButton.disabled = False
					End If
				End If
			End If
		End If
	Next
End Sub
