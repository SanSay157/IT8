Option Explicit

'==============================================================================
' ��������� � ���������� ����� HTML �������� � �������� ����
'	[in] oXmlMenuMD As IXMLDOMElement - xml-���� ������������ ����
'	[in] sMenuStyle - ����� ����: op-button, vertical-buttons, horizontal-buttons
'	[in] nButtonWidth - ������ ������ ���� � ��������
'	[in] nButtonHeight - ������ ������ ���� � ��������
'	[in] sClassName - ������������ css-������(��) ����� ������ ����
Function XMENUHTC_getMenuButtonsHtml(oXmlMenuMD, sMenuStyle, nButtonWidth, nButtonHeight, sClassName)
	Dim oNode		' As IXMLDOMElement - xml-���� �������� ����
	Dim sHtml		' As String - ����������� ����� HTML
	Dim nIndex		' As Int - ������ ������ ���� 
	Dim sName		' As String - ������������ ������ ����
	
	nIndex = 0
	If sMenuStyle = "op-button" Then
		sHtml = "<BUTTON ID='ButtonOperation' TITLE='��������...' CLASS='" & sClassName & "' style='" & _
				"width:" & nButtonWidth & "px;"
		If nButtonHeight > 0 Then sHtml = sHtml & "height:" & nButtonHeight & "px;"
		sHtml = sHtml & _
					"' DISABLED=1 OnClick='Internal_OnOperationButtonClick Me'>" & _
					"�������� <SPAN STYLE='font-family:Webdings'>&#54;</SPAN>" & _
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
			' ����������� ����� (� ����������� �� ���� ������ ����)
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
' ��������� �������� ���������� ������ ������� ���� ������
'	[in] oHTCRootElement - ������ �� element
'	[in] oButton As IHTMLElement - ������� ������
'	[out] nPosX - X ���������� 
'	[out] nPosY - Y ���������� 
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
' ���������� ������� ��������� �������� ���������� �������� master-element'a
' ���� � �������� ������ �������� ���, ������� ���������� �������� �������� �� ���������.
'	[in] oHTCRootElement - ������ �� element
'	[in] sAttrName		- ������������ ��������
'	[in] sDefaultValue	- �������� �� ���������
Function XMENUHTC_getHostElementAttributeValue( oHTCRootElement, sAttrName, sDefaultValue )
	Dim oAttribute		' html-�������
	
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
' ��������� ��������� ����
'	[in] oMenu As MenuClass - ����
'	[in] oSender As Object - ������ �� ������������ ������, ������������ � ����������� ����
'	[in] oContainer As IHTMLElement - ���������, � ������� ���������� ������ ����
'	[in] bVisualUpdate As Boolean - ������� ������� �� ��������� ��������� ������������� ������
'	[in] bAppDisabled As Boolean - ������� ����������������� ���� ������
Sub XMENUHTC_UpdateMenuState(oMenu, oSender, oContainer, bVisualUpdate, bAppDisabled)
	Dim oButton		' As IHTMLElement - ������ (button)
	Dim sItemName	' ������������ ������ ���� 
	Dim oMenuItem	' As IXMLDOMElement - xml-���� ������ ����
	Dim bDisabled	' As Boolean - ������� ����������������� ������
	Dim bHidden		' As Boolean - ������� ����������� ������

	' 2-�� �������� True �������� ��������� visibility-handler'� ������ ��� ��������� ������ (���� ������ ��� ��� ����������� ������)
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
						' ������������ ������ ������ ���� �� �� ������������
						oButton.disabled = bAppDisabled
						' �� ������� ��������� �������, ��� ��� � ��������� ������� ������ "����������"
						If LCase(oButton.style.display) = "none" Then oButton.style.display = "inline"
						oButton.outerHtml = oButton.outerHtml
					End If
				ElseIf bHidden Or bDisabled Then
					oButton.removeAttribute "X_WAS_ENABLED"
					If bVisualUpdate Then 
						oButton.disabled = True
						If bHidden Then
							oButton.style.display = "none"
						Else	' If bDisabled - ������������ ���������� �������
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
' ������������� �������� ��������, ����� ��������� ��������������� �� ������ ��� ��������������
'	[in] oMenu As MenuClass - ����
'	[in] oContainer As IHTMLElement - ���������, � ������� ���������� ������ ����
'	[in] sItemName - ������������ ������ ���� (������� n)
'	[in] sItemTitle - ��������� ������ ����/������ (������� t)
'	[in] sItemHint - ����� ����������� ���������. ���� Null, �� ������� ���������, ���� Empty, �� �������� ������������.
Sub XMENUHTC_SetMenuItemTitle(oMenu, oContainer, sItemName, sItemTitle, sItemHint)
	Dim oItem			' As IXMLDOMELement - xml-������� ����
	Dim oButton			' As IHTMLElement - ������ ������
	Dim sItemNameCur	' - ������������ ������ ����
	
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
		' ������� ��������� ������, ���� ��� ����
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
' ��������� (��)����������� ������ �������� ����, ��� ����������� ������ ����
'	[in] bEnable - ������� ����������� ������
'	[in] oContainer - ��������� (HTML-�������), � ������� ����� �������� ��� ������ ����� ��������� akk.tags("button")
Sub XMENUHTC_SetButtonsEnableState(bEnabled, oContainer)
	Dim oButton		' As IHTMLElement - ������ ������

	For Each oButton In oContainer.all.tags("button")
		If Not IsNull(oButton.getAttribute("X_MENU_ITEM_NAME")) Then
			If bEnabled = False Then
				' OFF
				If Not oButton.disabled Then
					' ������ �������� ���������� ������ - ��������, �� �������� �� ���������
					oButton.setAttribute "X_WAS_ENABLED", "1"
					oButton.disabled = True
				End If
			Else
				' ON
				If oButton.disabled Then
					' ������ �������� ����������� ������ - �������, ���� �� ���������� ��� ���� ��������
					If Not IsNull(oButton.getAttribute("X_WAS_ENABLED")) Then
						oButton.disabled = False
					End If
				End If
			End If
		End If
	Next
End Sub
