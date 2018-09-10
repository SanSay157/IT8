'===============================================================================
'@@!!FILE_x-menu
'<GROUP !!SYMREF_VBS>
'<TITLE x-menu - ������������ ���� �� ������� �������>
':����������:	������������ ���� �� ������� �������.
'===============================================================================
'@@!!FUNCTIONS_x-menu
'<GROUP !!FILE_x-menu><TITLE ������� � ���������>
'@@!!CLASSES_x-menu
'<GROUP !!FILE_x-menu><TITLE ������>
Option Explicit

' ������� xml-���� ������ ���� ��� ������� ����, ��� ����� ����������� �� �������
' ������������ ���������� ("������� �������", hotkey). 
' ������������ � MenuClass::ExecuteHotkey
const X_CATCHED_ATTR = "_catched_"

'===============================================================================
'@@New_MenuClass
'<GROUP !!FUNCTIONS_x-menu><TITLE New_MenuClass>
':����������:	���������� ����� ��������� ������ MenuClass.
':���������:	Function New_MenuClass() [As MenuClass]
Function New_MenuClass()
	Set New_MenuClass = New MenuClass
End Function

'===============================================================================
'@@MenuClass
'<GROUP !!CLASSES_x-menu><TITLE MenuClass>
':����������:	
':����������:	
'	����� ��������� ����, �� ����� �����-���� ������������� � ���������, � �������
'	������������ ������ ����; �������� ������������� � �����������, ���������������
'	���������, �������� �� ���������� �������������.<P/>
'	�������� �������������:
'	1. ������� ��������� - new MenuClass;
'	2. (������������ ���) �������� �����������, ��������� SetMacrosResolver, 
'		SetVisibilityHandler, SetExecutionHandler (��� �� ��������);
'	3. ������� Init � �������� ���������� ���� - ���� i:menu;
'	4. (������������ ���) �������� �����������, ��������� SetMacrosResolver, 
'		SetVisibilityHandler, SetExecutionHandler (��� �� ��������);
'	5. �������:
'		* ShowPopupMenu - ��� ����������� ������������ ����
':��. �����:	
'	New_MenuClass,<P/>
'	<LINK common2, ������������ ���� - ����� MenuClass/>
'
'@@!!MEMBERTYPE_Methods_MenuClass
'<GROUP MenuClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_MenuClass
'<GROUP MenuClass><TITLE ��������>
Class MenuClass
	Private m_oPopup					' ������ CROC.Popup
	Private m_oXmlMenu					' ������� XML ����; ��� ������ ShowPopup c��� ���������� ����� m_oXmlMenuMD
	Private m_oXmlMenuMD				' ���������� ����
	Private m_oValues					' ���-������� ��������, ��������� Scripting.Dictionary
	Private m_sXslFilename				' ��� ��������� ��� HTML-����
	Private m_oRegExp					' ������ RegExp
	Private m_bInitialized				' ������� �������������������� ����
	Private m_oEventEngine				' ��������� EventEngineClass
	Private m_bMenuProcessing			' ������� ����, ��� ���� � ������ ������ �������������� (������ � racing conditions)
	
	'------------------------------------------------------------------------------
	' "�����������"	
	Private Sub Class_Initialize
		Set m_oValues = CreateObject("Scripting.Dictionary")
		m_oValues.CompareMode = vbTextCompare
		Set m_oRegExp = New RegExp
		m_oRegExp.Global = True
		m_oRegExp.Multiline = True
		m_oRegExp.IgnoreCase = true
		m_bInitialized = False
		Set m_oEventEngine = X_CreateEventEngine
		Set m_oXmlMenuMD = Nothing
		Set m_oXmlMenu = Nothing
	End Sub 


	'------------------------------------------------------------------------------
	'@@MenuClass.EventEngine
	'<GROUP !!MEMBERTYPE_Properties_MenuClass><TITLE EventEngine>
	':����������:	���������� ��������� EventEngine, ������������ ��� ���������� 
	'				� ������ ������������ ������� ����.
	':����������:	�������� ������ ��� ������.
	':���������:	Public Property Get EventEngine [As EventEngineClass]
	Public Property Get EventEngine
		Set EventEngine = m_oEventEngine
	End Property


	'------------------------------------------------------------------------------
	'@@MenuClass.Init
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE Init>
	':����������:	������������� ����.
	':���������:
	'	oXmlMenuMD - [in] �������� ������� ���������� ���� (i:menu), ��������� IXMLDOMElement 
	':����������:
	'	<B>��������!</B> XML � ����������� ���� �� �����������, ����� XMLDOMDocument 
	'	�� ���������.
	':��. �����:
	'	<LINK mc-2, ������������� ����/>
	':���������:	
	'	Public Sub Init( oXmlMenuMD [As IXMLDOMElement] )
	Public Sub Init(oXmlMenuMD)
		Dim oNode		' IXMLDOMElement
		Dim oMatch		' RegExp.Match
		
		m_bInitialized = False
		If IsNothing(oXmlMenuMD) Then
			Err.Raise -1, "Class Menu::Init", "�� ���������� ���������� ����"
		End If
		Set m_oXmlMenuMD = oXmlMenuMD
		Set m_oXmlMenu = Nothing
		m_oValues.RemoveAll
		If oXmlMenuMD.baseName <> "menu" Then Exit Sub
		' ������ � ������ ���� ��� ������� (�����, ������������ � @@) � ���������� ��� �� ���
		m_oRegExp.Pattern = "@@([A-Za-z][\w]*)"
		For Each oMatch In m_oRegExp.Execute( m_oXmlMenuMD.Xml )
			m_oValues.Item(oMatch.SubMatches(0)) = vbNullString
		Next
		' ������� � ��������� ��� ��������� �������� ���� (������������ ������ ��� Html ����)
		m_sXslFilename = m_oXmlMenuMD.getAttribute("xslt-template")
		If IsNull(m_sXslFilename) Then m_sXslFilename = vbNullString
		
		' �������������� ����������� �������, �������� � ���������� ����
		' ��������� � ��������� ��������� ��������, ����������� ����������� � ���������, ����������� ������ ������ ����
		For Each oNode In m_oXmlMenuMD.selectNodes("*[local-name()='macros-resolver' or local-name()='visibility-handler' or local-name()='execution-handler']")
			If oNode.getAttribute("mode") = "replace" Then
				If oNode.baseName = "macros-resolver" Then
					SetMacrosResolver X_CreateDelegate(Null, oNode.text)
				ElseIf oNode.baseName = "visibility-handler" Then
					SetVisibilityHandler X_CreateDelegate(Null, oNode.text)
				ElseIf oNode.baseName = "execution-handler" Then
					SetExecutionHandler X_CreateDelegate(Null, oNode.text)
				End If
			Else
				If oNode.baseName = "macros-resolver" Then
					AddMacrosResolver X_CreateDelegate(Null, oNode.text)
				ElseIf oNode.baseName = "visibility-handler" Then
					AddVisibilityHandler X_CreateDelegate(Null, oNode.text)
				ElseIf oNode.baseName = "execution-handler" Then
					AddExecutionHandler X_CreateDelegate(Null, oNode.text)
				End If
			End If
		Next

		' ������� ����������� ���������� ���������� ��� ��������� action'a DoExecuteVbs
		AddExecutionHandler X_CreateDelegate(Me, "OnExecuteVbs")
		m_bInitialized = True
	End Sub


	'------------------------------------------------------------------------------
	'@@MenuClass.OnExecuteVbs
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE OnExecuteVbs>
	':����������:	���������� ������� "ExecuteVbs"
	':���������:
	'	oSender - [in] "��������" ������� - ��������� MenuClass, "���������������" 
	'			������� "ExecuteVbs"
	'	oEventArgs - [in] ��������� �������, ��������� MenuExecuteEventArgsClass
	':���������:
	'	Public Sub OnExecuteVbs( oSender [As MenuClass], oEventArgs [As MenuExecuteEventArgsClass] )
	Public Sub OnExecuteVbs(oSender, oEventArgs)
		If oEventArgs.Action = "DoExecuteVbs" Then
			If Macros.Exists("Script") Then
				ExecuteGlobal Macros.Item("Script")
			End If
		End If
	End Sub


	'------------------------------------------------------------------------------
	':����������:	�������������� � m_oXmlMenu ����� ���������� ����.
	Private Sub createMenuTemplate
		Dim nIdx		' ������, ������������ � �������� ������������ (������� n) ������ ����
		Dim oNode		' IXMLDOMElement - xml-���� �������� ����
		Dim vValue		' As Vatiant - �������� �������� n
		
		Set m_oXmlMenu  = m_oXmlMenuMD.cloneNode(true)
		Set m_oXmlMenu = XService.XMLGetDocument.appendChild( m_oXmlMenu )
		'TODO: ����������� � XService.XmlSetSelectionNamespaces m_oXmlMenu.ownerDocument,
		' �.�. ��� �� ��������: m_oXmlMenu.selectNodes("descendant::*/namespace::*") ������� ������ "xml" !!!
		m_oXmlMenu.ownerDocument.SetProperty "SelectionLanguage", "XPath"	
		m_oXmlMenu.ownerDocument.SetProperty "SelectionNamespaces", m_oXmlMenuMD.ownerDocument.GetProperty("SelectionNamespaces")
		
		' ��� ������� menu-item'a ���������� ���������� ������������, ����� �������� ������ � ����� action'�� ���� �� �����
		' ����������: ���������� ������, ��� ������ ��� ����� ����� ������������, � ��� ����� � ���� ��������, 
		' ������� ���������� �������� �� ������������ ������������.
		nIdx = 0
		' ������� �� ���� ����� � ��������� n � ������ ������������ �������� ����� �������� ��������
		For Each oNode In m_oXmlMenu.selectNodes(".//*[@n and local-name()!='macros-resolver' and local-name()!='visibility-handler' and local-name()!='execution-handler']")
			vValue = oNode.GetAttribute("n")
			If Not IsNull(vValue ) Then
				If IsNumeric(vValue) Then
					vValue = CLng(vValue)
					If nIdx < vValue Then nIdx = vValue
				End If
			End If
		Next
		' �� ���� ����� ����, ����� ���������. 
		For Each oNode In m_oXmlMenu.selectNodes(".//*[local-name()!='macros-resolver' and local-name()!='visibility-handler' and local-name()!='execution-handler']")
			If IsNull(oNode.GetAttribute("n")) Then
				nIdx = nIdx + 1
				oNode.setAttribute "n", nIdx
			End If
		Next
		
		' �������������� ��������� ����
		For Each oNode In m_oXmlMenu.selectNodes("*[local-name()='params']/*[local-name()='param']")
			m_oValues.Item( oNode.getAttribute("n") ) = oNode.text
		Next
	End Sub


	'------------------------------------------------------------------------------
	'@@MenuClass.ExecuteHotkey
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE ExecuteHotkey>
	':����������:
	'	���� � ��������� ����� ����, ��� �������� ������ ���������� "�������" ������, 
	'	��������������� ���������� ������� ������ (�������� ������� ������������
	'	����������� ������ AccelerationEventArgsClass, ������������� ����������).
	':���������:
	'	oSender - [in] ��������� �������-"����������" ��������� (�������� "�����������"
	'		� � ��������� �������� ���������� ��������� MenuClass, ��� ����� ����������)
	'	oAccelerationArgs - [in] ��������� ������ AccelerationEventArgsClass
	':���������:
	'	���������� �������, ���������� ���� ���������� ������ ���� � ���������������
	'	��������� "�������" ������:
	'	* True - ��������������� ����� ���� ������, ������ ���������� ����� ������;
	'	* False - � ��������� ������.
	':��. �����:
	'	AccelerationEventArgsClass,<P/>
	'	<LINK mc-4, ������������ ���������� ������� ������/>
	':���������:
	'	Public Function ExecuteHotkey( 
	'		oSender [As Object], 
	'		oAccelerationArgs [As AccelerationEventArgsClass] 
	'	) [As Boolean]
	Public Function ExecuteHotkey( oSender, oAccelerationArgs )
		Dim oNode			' As IXMLDOMElement - i:menu-item
		Dim bCatched		' As Boolean - �������, ��� ��� ������� ���������� ������ ����� ����
		Dim sCmd			' As String - ������������ ������ ���� (������� n)
		Dim sHotkeys		' As String - ������� hotkey menu-item'a - ������ ������� ������ ����
		Dim aHotkeys		' As Array - ������ �������
		Dim sHotkey			' As String - ���� ������ �� ������
		Dim aKeys			' As Array - ������ ��������� ������
		Dim sKey			' As String - ������� ������ (��� ������� ��� �����)
		Dim i, j
		Dim oActiveItems				' ��������� ������������ ������� ����, ���� ����, �� ����� ����������
		Dim bCatchedOneAtLeast			' �������: ������ �� ������� ���� ���� �����, ��������������� ������� ����������
		Dim bHotkeyContainsAlt			' �������: ��������� ������ �������� ALT
		Dim bHotkeyContainsShift		' �������: ��������� ������ �������� SHIFT
		Dim bHotkeyContainsControl		' �������: ��������� ������ �������� CTRL
		
		ExecuteHotkey = False
		If Not m_bInitialized Then Exit Function
		createMenuTemplate
		bCatchedOneAtLeast = False
		For Each oNode In m_oXmlMenu.selectNodes("//*[local-name()='menu-item' and @action and @hotkey]")
			'�������/���������� ������ ������������� ��� ������ ���� 
			'������� ����������� ����� �� �������� VK_*, ���� ����� �������� �������, 
			'	����� ������� "+" (�� ������������ ��� ������� ���������� ������)
			'	� ������� "," (�� ������������ ��� ���������� ���������).
			'���������� ������ ����� ���� ������ � ������� ������������� ����-������: ALT, CTRL, SHIFT. 
			'��������: ALT+VK_F1, ALT+CTRL+C. ������ �������� VK_* ��. � x-const.aspx
			'�������������� ������� ���������� ������������� (ALT,CTRL,SHIFT) � ������������ ������������������ � 
			'������ �������/�������������� �������. ��� ���� ������� ������� ������������. �.�. CTRL+D � CTRL+d ��������� ������������.
			sHotkeys = oNode.getAttribute("hotkey")
			aHotkeys = Split(UCase(sHotkeys), ",")
			For i=0 To UBound(aHotkeys)
				sHotkey = Trim(aHotkeys(i))
				If 0<>Len(sHotkey) Then
					' ��������
					bCatched = True
					bHotkeyContainsAlt = false
					bHotkeyContainsShift = false
					bHotkeyContainsControl = false
					aKeys = Split(sHotkey, "+")
					For j=0 To UBound(aKeys)
						sKey = Trim(aKeys(j))
						Select Case sKey
							Case  vbNullString
								' ������ �� ������
							Case "ALT", "VK_ALT"
								bCatched = CBool(bCatched AND oAccelerationArgs.altKey)
								bHotkeyContainsAlt = true
							Case "CTRL", "VK_CONTROL", "VK_CONTROLKEY"
								bCatched = CBool(bCatched AND oAccelerationArgs.ctrlKey)
								bHotkeyContainsControl = true
							Case "SHIFT", "VK_SHIFTKEY", "VK_SHIFT"
								bCatched = CBool(bCatched AND oAccelerationArgs.shiftKey)
								bHotkeyContainsShift = true
							Case Else
								If Left(sKey,3) = "VK_" Then
									' �������������� �������. ��� ��������� (VK_*) ������ ���� ���������� � ��������� (x-const.aspx)
									bCatched = bCatched AND CBool( oAccelerationArgs.keyCode = Eval(sKey))
								Else
									bCatched = bCatched AND  CBool( UCase(Chr(oAccelerationArgs.keyCode)) = sKey)
								End If	
						End Select
						If False = bCatched Then Exit For
					Next
					If bCatched Then
						bCatched = Not bHotkeyContainsAlt XOR oAccelerationArgs.altKey
						bCatched = bCatched AND Not (bHotkeyContainsControl XOR oAccelerationArgs.ctrlKey)
						bCatched = bCatched AND Not (bHotkeyContainsShift XOR oAccelerationArgs.shiftKey)
					End If
					If True = bCatched Then
						' ���� ������� ����� ���� ����������� �� ������� ������, �� ������� ��� ����� � �������� � ����������
						oNode.setAttribute X_CATCHED_ATTR, "1"
						bCatchedOneAtLeast = True
						Exit For
					End If 
				End If 
			Next
		Next
		If bCatchedOneAtLeast Then
			Set oActiveItems = m_oXmlMenu.selectNodes("//*[local-name()='menu-item' and @" & X_CATCHED_ATTR & "]")
			' ����� ����� ���� � ������� ���������� ������, �������� ���������������� ��������� ����
			' �������� ��� ������-��������� (���������� �������� ��������)
			runMacrosResolvers oSender
			' ��������� ����������� �������� �������� � ����
			substituteMacros
			' �������� ����������� ��������� ���������/�����������
			runVisibilityResolversEx oSender, oActiveItems
			Set oActiveItems = m_oXmlMenu.selectNodes("//*[local-name()='menu-item' and @" & X_CATCHED_ATTR & " and not(@hidden) and not(@disabled)]")
			m_oXmlMenu.selectNodes("@" & X_CATCHED_ATTR).removeAll
			If oActiveItems.length = 0 Then
				Exit Function
			ElseIf oActiveItems.length = 1 Then
				Set oNode = oActiveItems.item(0)
				sCmd = oNode.getAttribute("n")
			ElseIf oActiveItems.length > 1 Then
				' ������������� popup-����
				preparePopupObject
				For i=0 To oActiveItems.length - 1
					Set oNode = oActiveItems.item(i)
					m_oPopup.Add _
						Replace( oNode.getAttribute("t"), "\t", Chr(9) ), _
						oNode.getAttribute("n"), true
				Next
				If hasValue(oAccelerationArgs.MenuPosX) And hasValue(oAccelerationArgs.MenuPosY) Then
					sCmd = m_oPopup.Show(oAccelerationArgs.MenuPosX, oAccelerationArgs.MenuPosY)
				Else
					sCmd = m_oPopup.Show
				End If
				If IsNull(sCmd) Then Exit Function	' ������ �� �������
			End If
			runExecutionHandlers oSender, sCmd
			ExecuteHotkey = True
			oAccelerationArgs.Processed = True
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@MenuClass.ShowPopupMenuSectionWithPos
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE ShowPopupMenuSectionWithPos>
	':����������:
	'	��������� PopUp ���� �������� ������, � ��������� ������� ��� �����������.
	':���������:
	'	oSender - [in] ������ �� ������, ������������ � execution-handler
	'	sSectionName - [in] ������������ ������ (������� n ��� i:menu-section)
	'	nPosX - [in] �������� ����������, ������� �� �����������
	'	nPosY - [in] �������� ����������, ������� �� ���������
	':��. �����:
	'	MenuClass.ShowPopupMenu, MenuClass.ShowPopupMenuEx, 
	'	MenuClass.ShowPopupMenuWithPos, MenuClass.ShowPopupMenuWithPosEx
	':���������:
	'	Public Sub ShowPopupMenuSectionWithPos(
	'		oSender [As Object], 
	'		sSectionName [As String], 
	'		nPosX [As Long], 
	'		nPosY [As Long] )
	Public Sub ShowPopupMenuSectionWithPos(oSender, sSectionName, nPosX, nPosY)
		Internal_ShowPopupMenuFragmentWithPosEx oSender, sSectionName, nPosX, nPosY, False
	End Sub


	'------------------------------------------------------------------------------
	'@@MenuClass.ShowPopupMenuWithPos
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE ShowPopupMenuWithPos>
	':����������:
	'	��������� PopUp ����, � ��������� ������� ��� �����������.
	':���������:
	'	oSender - [in] ������ �� ������, ������������ � execution-handler
	'	nPosX - [in] �������� ����������, ������� �� �����������
	'	nPosY - [in] �������� ����������, ������� �� ���������
	':��. �����:
	'	MenuClass.ShowPopupMenu, MenuClass.ShowPopupMenuEx, 
	'	MenuClass.ShowPopupMenuWithPosEx, 
	'	MenuClass.ShowPopupMenuSectionWithPos
	':���������:
	'	Public Sub ShowPopupMenuWithPos( 
	'		oSender [As Object], 
	'		nPosX [As Long], 
	'		nPosY [As Long] )
	Public Sub ShowPopupMenuWithPos(oSender, nPosX, nPosY)
		Internal_ShowPopupMenuFragmentWithPosEx oSender, Null, nPosX, nPosY, False
	End Sub


	'------------------------------------------------------------------------------
	'@@MenuClass.ShowPopupMenuWithPosEx
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE ShowPopupMenuWithPosEx>
	':����������:
	'	��������� pop-up ����, � ��������� ������� �����������. ������ ����� 
	'	��������������� "����������" ����������� ������ ���� "�� ���������" 
	'	(��. "���������").
	':���������:
	'	oSender - [in] ������ �� ������, ������������ � execution-handler
	'	nPosX - [in] �������� ����������, ������� �� �����������
	'	nPosY - [in] �������� ����������, ������� �� ���������
	'	bRunDefault - [in] ���������� �������, ������������ ��������� ���� ��� 
	'			�������� ������ ���� "�� ���������" (��. "���������")
	':����������:
	'	�������� bRunDefault ���������� ��������� ���� � ������ ������� � ���� 
	'	������� "�� ���������". ����� ������������ ���� ����������� ������� � 
	'	����������� ����� ������� (�� ���������� ���������� ������������ ��������� /
	'	�����������). ���� ����� ����� ����� ����������� � �� ����� ����, � ��� ����
	'	�������� bRunDefault ����� � �������� True, �� ����� ����� ������� ���������� 
	'	���������� ��� ����� ������, ��� ����������� ����.<P/>
	'	���� �������� bRunDefault ����� � �������� False, �� ���� ������������ ������,
	'	��� ����������� �� ������� ������� ���� "�� ���������".
	':��. �����:
	'	MenuClass.ShowPopupMenu, MenuClass.ShowPopupMenuEx, 
	'	MenuClass.ShowPopupMenuWithPos, 
	'	MenuClass.ShowPopupMenuSectionWithPos,<P/>
	'	<LINK mc-111, ����� ���� �� ��������� />
	':���������:
	'	Public Sub ShowPopupMenuWithPosEx(
	'		oSender [As Object], 
	'		nPosX [As Long], 
	'		nPosY [As Long], 
	'		bRunDefault [As Boolean] )
	Public Sub ShowPopupMenuWithPosEx(oSender, nPosX, nPosY, bRunDefault)
		Internal_ShowPopupMenuFragmentWithPosEx oSender, Null, nPosX, nPosY, bRunDefault
	End Sub

	'------------------------------------------------------------------------------
	':����������:	�������������� ������ m_oPopUp � �������������
	Private Sub preparePopupObject
		If IsEmpty(m_oPopup) Then
			Set m_oPopUp = XService.CreateObject("CROC.XPopUpMenu")
		Else
			m_oPopUp.Clear
		End If
	End Sub
	
	'------------------------------------------------------------------------------
	':����������:	���������� ����� ����������� pop-up-�������������
	Private Sub Internal_ShowPopupMenuFragmentWithPosEx(oSender, sSectionName, nPosX, nPosY, bRunDefault)
		Dim sCmd		' action ���������� menu-item'a
		Dim oNodes		' As IXMLDOMNodeList
		Dim oXmlMenu	' As IXMLDOMElement
		
		' ������������ ��������� ����
		If m_bMenuProcessing Then Exit Sub
		m_bMenuProcessing = True
		If IsNothing(m_oXmlMenuMD) Then
			Err.Raise -1, "Class Menu::ShowPopupMenu", "�� ������ ���������� ����"
		End If
		preparePopupObject
		
		createMenuTemplate
		' �������� ��� ������-��������� (���������� �������� ��������)
		runMacrosResolvers oSender
		' ��������� ����������� �������� �������� � ����
		substituteMacros
		' ������� ������������ ������ ��� ���� �������
		If hasValue(sSectionName) Then
			Set oXmlMenu = m_oXmlMenu.selectSingleNode("*[local-name()='menu-section' and @n='" & sSectionName & "']")
			If oXmlMenu Is Nothing Then Alert "������ � ������������� '" & sSectionName & "' �� ������� � �������� ����." : Exit Sub
		Else
			Set oXmlMenu = m_oXmlMenu
		End If
		' �������� ����������� ��������� ���������/�����������
		runVisibilityResolversForSection oSender, oXmlMenu
		
		' ������������� popup-����
		createPopup m_oPopUp, oXmlMenu
		m_bMenuProcessing = False
		
		If m_oPopup.Count=0 Then Exit Sub
		If bRunDefault Then
			' ���� ����������, ��� �������� ���� ����� � � ���� ���� ������� 'may-be-default', �� �������� ��� �����
			Set oNodes = oXmlMenu.selectNodes("//*[local-name()='menu-item' and not(@hidden) and not(@disabled)]")
			If oNodes.length = 1 Then
				If Not IsNull(oNodes.item(0).getAttribute("may-be-default")) Then
					runExecutionHandlers oSender, oNodes.item(0).getAttribute("n")
					Exit Sub
				End If
			End If
		End If
		' ������� ��������� �������
		if IsNumeric(nPosX) And IsNumeric(nPosY) Then
			sCmd = m_oPopup.Show( nPosX, nPosY )
		Else
			sCmd = m_oPopup.Show
		End If
		If IsNull(sCmd) Then Exit Sub	' ������ �� �������
		' �������� ����������� ������ ������ ����
		runExecutionHandlers oSender, sCmd
	End Sub


	'------------------------------------------------------------------------------
	'@@MenuClass.ShowPopupMenu
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE ShowPopupMenu>
	':����������:
	'	��������� pop-up ����.
	':���������:
	'	oSender - [in] ������ �� ������, ������������ � execution-handler
	':��. �����:
	'	MenuClass.ShowPopupMenuEx, 
	'	MenuClass.ShowPopupMenuWithPos, MenuClass.ShowPopupMenuWithPosEx
	':���������:
	'	Public Sub ShowPopupMenu( oSender [As Object] )
	Public Sub ShowPopupMenu(oSender)
		ShowPopupMenuWithPosEx oSender, Null, Null, False
	End Sub


	'------------------------------------------------------------------------------
	'@@MenuClass.ShowPopupMenuEx
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE ShowPopupMenuEx>
	':����������:
	'	��������� pop-up ����. ������ ����� ��������������� "����������" ����������� 
	'	������ ���� "�� ���������" (��. "���������").
	':���������:
	'	oSender - [in] ������ �� ������, ������������ � execution-handler
	'	bRunDefault - [in] ���������� �������, ������������ ��������� ���� ��� 
	'			�������� ������ ���� "�� ���������" (��. "���������")
	':����������:
	'	�������� bRunDefault ���������� ��������� ���� � ������ ������� � ���� 
	'	������� "�� ���������". ����� ������������ ���� ����������� ������� � 
	'	����������� ����� ������� (�� ���������� ���������� ������������ ��������� /
	'	�����������). ���� ����� ����� ����� ����������� � �� ����� ����, � ��� ����
	'	�������� bRunDefault ����� � �������� True, �� ����� ����� ������� ���������� 
	'	���������� ��� ����� ������, ��� ����������� ����.<P/>
	'	���� �������� bRunDefault ����� � �������� False, �� ���� ������������ ������,
	'	��� ����������� �� ������� ������� ���� "�� ���������".
	':��. �����:
	'	MenuClass.ShowPopupMenu, 
	'	MenuClass.ShowPopupMenuWithPos, MenuClass.ShowPopupMenuWithPosEx,<P/>
	'	<LINK mc-111, ����� ���� �� ��������� />
	':���������:
	'	Public Sub ShowPopupMenuEx( oSender [As Object], bRunDefault [As Boolean] )
	Public Sub ShowPopupMenuEx(oSender, bRunDefault)
		ShowPopupMenuWithPosEx oSender, Null, Null, bRunDefault 
	End Sub


	'------------------------------------------------------------------------------
	':����������:	���������� ����� ������������ �������� popup-����
	'	[in] oPopup As CROC.XPopupMenu
	'	[in] oXmlCurMenu As IXMLDOMElement - ���� ���� ��� ������ (menu/menu-section)
	Private Sub createPopup(oPopup, oXmlCurMenu)
		Dim oSubMenu		' Popup-�������
		Dim oNodes			' As IXMLDOMSelection - ��������� ������������ �����
		Dim oNode			' ���� menu-item
		Dim bAddSeparator	' ������� ������������� �������� �����������
		Dim bIsFirst		' ������� ��� ����� ���� ������
		Dim bIsLast			' ������� ��� ����� ���� ���������
		Dim bWasSeparator	' ������� ��� ���������� ����� ���� ��� ������������
		Dim nCounter		' ������� ��������
		Dim nCount			' ���������� �������
		bIsFirst = True
		bAddSeparator = False
		bWasSeparator = False

		' ����������� ������ ���� + ������		
		Set oNodes = oXmlCurMenu.selectNodes("*[local-name()='menu-item' and not(@hidden)] | *[local-name()='menu-item-separ' and not(@hidden)] | *[local-name()='menu-section' and not(@hidden)]")
		nCount = oNodes.length
		nCounter = 0
		For Each oNode In oNodes
			bIsLast = CBool(nCounter = nCount - 1)
			' ���� �������� ������������� �������� ����������� �� ����������� ������ ���� (separator-after)
			If bAddSeparator And oNode.baseName <> "menu-item-separ" And Not bWasSeparator  Then
				oPopup.AddSeparator
				bWasSeparator = True
			End If
			If oNode.baseName = "menu-item-separ" Then
				If Not bIsFirst And Not bIsLast And Not bWasSeparator Then 
					' ��������, ��� ����� �������� ����������� ���� ����� ����-�� �����������
					If oNodes.item(nCounter+1).baseName <> "menu-item-separ" Then
						oPopup.AddSeparator
						bWasSeparator = True
					End If
				End If
			Else
				If oNode.getAttribute("separator-before") = 1 And Not bIsFirst And Not bWasSeparator Then
					oPopup.AddSeparator
					bWasSeparator = True
				End If
				bIsFirst = False
				If oNode.baseName = "menu-section" Then
					' ������� ����� - ������. ���� ��� �������� ���������������� ��������� - �� ������� �������
					If Not oNode.selectSingleNode(".//*[local-name()='menu-item' and not(@hidden)]") Is Nothing Then
						Set oSubMenu = oPopup.AddSubMenu( oNode.getAttribute("t") )
						createPopup oSubMenu, oNode
						bWasSeparator = False
					End If
				Else
					' ������� ����� ����
					oPopup.Add _
						Replace( oNode.getAttribute("t"), "\t", Chr(9) ), _
						oNode.getAttribute("n"), _
						IsNull(oNode.getAttribute("disabled"))
					bWasSeparator = False
				End If
				bAddSeparator = Not IsNull(oNode.getAttribute("separator-after"))
			End If
			nCounter = nCounter + 1
		Next
	End Sub


	'------------------------------------------------------------------------------
	'@@MenuClass.CreateXmlMenuItem
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE CreateXmlMenuItem>
	':����������:
	'	"���������" ����� �������� XML-�������� ������ ���� (menu-item).
	':���������:
	'	sAction - [in] ������������ �������� (action)
	'	sTitle - [in] ����� ������ ����
	':���������:
	'	XML-�������� ������ ������ ����, ��� ��������� IXMLDOMElement.
	':��. �����:
	'	MenuClass.CreateXmlMenuSection
	':���������:
	'	Public Function CreateXmlMenuItem( 
	'		sAction [As String], sTitle [As String] 
	'	) [As IXMLDOMElement]
	Public Function CreateXmlMenuItem(sAction, sTitle)
		Dim oItem		' ���� menu-item
		
		Set oItem = createXmlMenuItemTemplate("menu-item")
		oItem.setAttribute "action", sAction
		oItem.setAttribute "t", sTitle
		' ���������� ������������ ����
		oItem.setAttribute "n", CreateGuid()
		Set CreateXmlMenuItem = oItem
	End Function

		
	'------------------------------------------------------------------------------
	'@@MenuClass.CreateXmlMenuSection
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE CreateXmlMenuSection>
	':����������:
	'	"���������" ����� �������� XML-�������� ������ ���� (menu-section).
	':���������:
	'	sTitle - [in] ����� � ���������� ������
	':���������:
	'	XML-�������� ����� ������ ����, ��� ��������� IXMLDOMElement.
	':��. �����:
	'	MenuClass.CreateXmlMenuItem
	':���������:
	'	Public Function CreateXmlMenuSection( sTitle [As String] ) [As IXMLDOMElement]
	Public Function CreateXmlMenuSection(sTitle)
		Dim oItem		' ���� menu-item
		
		Set oItem = createXmlMenuItemTemplate("menu-section")
		oItem.setAttribute "t", sTitle
		Set CreateXmlMenuSection = oItem
	End Function
	

	'------------------------------------------------------------------------------
	':����������:	������� ��������� XML-�������� ������ ���� (�������������).
	':���������:	sTagName - [in] ������������ �������� ������������
	Private Function createXmlMenuItemTemplate(sTagName)
		Dim oXmlDoc		' IXMLDOMDocument - ������� xml-���� menu-item
		Dim sPrefix		' �������� �������� ����
		
		sPrefix = ""
		If m_oXmlMenuMD Is Nothing Then
			Set oXmlDoc = XService.XMLGetDocument
		Else
			Set oXmlDoc = m_oXmlMenuMD.ownerDocument
			' � �������� �������� ���������� ������� ��������� ���� ���������� ����
			sPrefix = m_oXmlMenuMD.prefix
			If hasValue(sPrefix) Then sPrefix = sPrefix & ":"
		End If
		Set createXmlMenuItemTemplate = oXmlDoc.createElement(sPrefix & sTagName)
	End Function


	'------------------------------------------------------------------------------
	':����������:	
	'	��������� ���������� ����: 
	'	- �������� ���� �� ������������, 
	'	- ����� macro-resolver'�� � visibility-handler'��
	Public Sub PrepareMenu(oSender)
		PrepareMenuEx oSender, False	
	End Sub


	'------------------------------------------------------------------------------
	':����������:	
	'	��������� ���������� ����: 
	'	- �������� ���� �� ������������, 
	'	- ����� macro-resolver'�� � visibility-handler'��
	':���������:
	'	[in] bOnlyRootLevel - ���� True, �� visibility-handler'� ���������� ������ 
	'		��� �������� ������� ����, ����� - ��� ����
	Public Sub PrepareMenuEx(oSender, bOnlyRootLevel)
		createMenuTemplate
		' �������� ��� ������-��������� (���������� �������� ��������)
		runMacrosResolvers oSender
		' ��������� ����������� �������� �������� � ����
		substituteMacros
		' �������� ����������� ��������� ���������/�����������
		If bOnlyRootLevel Then
			runVisibilityResolversEx oSender, m_oXmlMenu.selectNodes("*")
		Else
			runVisibilityResolvers oSender
		End If
	End Sub


	'------------------------------------------------------------------------------
	':����������:	����������� �������� �������� �� ��������� m_oValues � XML-����
	Private Sub substituteMacros
		Dim sKey		' ���� ���-�������
		Dim oNode		' As IXMLDOMNode
		
		' �� ���� �������� � ���������
		For Each sKey In m_oValues.Keys
			' �� ���� �����, ���������� ��������� '@@'
			For Each oNode In m_oXmlMenu.selectNodes("//text()[contains(.,'@@" & sKey & "')]") '  | //@*[contains(text(),'@@" & sKey & "')
				' ��������� �������� ������� � ����, ���� ��� �� NULL
				If IsNull(m_oValues.item(sKey)) Then
					oNode.text = Replace( oNode.text, "@@" & sKey, "[�� ����������]" )
				Else
					oNode.text = Replace( oNode.text, "@@" & sKey, m_oValues.Item(sKey) )
				End If
			Next
		Next
	End Sub
	
	
	'------------------------------------------------------------------------------
	':����������:	��������� ��� ��������� �������� (�������).
	Private Sub runMacrosResolvers(oSender)
		If m_oEventEngine.IsHandlerExists("ResolveMacros") Then
			With New MenuEventArgsClass
				Set .Menu	= Me
				XEventEngine_FireEvent m_oEventEngine, "ResolveMacros", oSender, .Self()
			End With
		End If
	End Sub
	
	
	'------------------------------------------------------------------------------
	':����������:	
	'	��������� ��� ��������� ������������ ����������� / ��������� ��� ���� 
	'	��������� ����.
	Private Sub runVisibilityResolvers(oSender)
		runVisibilityResolversForSection oSender, m_oXmlMenu
	End Sub


	'------------------------------------------------------------------------------
	':����������:	
	'	��������� ��� ��������� ������������ �����������/��������� ��������� ���� 
	'	�������� ������ ( � ��� ����� ������ ����).
	':���������:
	'	oXmlMenu - [in] ���� i:menu ��� i:menu-section, ��������� IXMLDOMElement
	Private Sub runVisibilityResolversForSection(oSender, oXmlMenu)
		runVisibilityResolversEx oSender, oXmlMenu.selectNodes("//*[(local-name()='menu-item' and @action) or (local-name()='menu-section')]")
	End Sub


	'------------------------------------------------------------------------------
	':����������:	
	'	��������� ��� ��������� ������������ ����������� / ��������� �������� 
	'	��������� ����.
	':���������:
	'	oActiveMenuItems - [in] ��������� ������� ���� (menu-item � menu-section),
	'						��������� IXMLDOMNodeList.
	Private Sub runVisibilityResolversEx(oSender, oActiveMenuItems)
		If m_oEventEngine.IsHandlerExists("SetVisibility") Then
			With New MenuEventArgsClass
				Set .Menu	= Me
				Set .ActiveMenuItems = oActiveMenuItems
				XEventEngine_FireEvent m_oEventEngine, "SetVisibility", oSender, .Self()
			End With
		End If
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@MenuClass.RunExecutionHandlers
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE RunExecutionHandlers>
	':����������:
	'	��������� ��� ����������� ������ ����, ���������� �������������.
	':���������:
	'	oSender - [in] ������ �� ������, ������������ � execution-handler
	'	sCmd - [in] ���������� ������������ ���������� ������ ���� (�������� �������� "n")
	':����������:
	'	� ��������� ������� ����� ������ �������� � ������������� ������ ������� 
	'	����������: 
	'	* � ������������ ���� ��� ������ ���� � ���������� �������������, �������� 
	'		���������� sCmd.
	':��. �����:
	'	<LINK mc-53, ����������� ���������� />
	':���������:
	'	Public Sub RunExecutionHandlers( oSender [As Object], sCmd [As String] )
	Public Sub RunExecutionHandlers( oSender, sCmd )
		Dim oMenuItem		' As IXMLDOMElement - ��������� menu-item
		Dim oParam			' As IXMLDOMElement - ���� param � ���������� ���� 
		Dim sMacro			' As String			- ������������ �������
		Dim oParams			' As IXMLDOMNodeList - ��������� ���������� ������ ����
		Dim oValuesBackup	' As Scriptng.Dictionary - ����� ������� ��������� ����������
		Dim sKey			' As String - ���� �������
		
		If m_oEventEngine.IsHandlerExists("Execute") Then
			Set oMenuItem = m_oXmlMenu.selectSingleNode("//*[local-name()='menu-item' and @n='" & sCmd & "']") 
			If oMenuItem Is Nothing Then
				Err.Raise -1, "MenuClass::RunExecutionHandlers", "�� ������ menu-item � �������� ������������� (n) '" & sCmd & "'"
			End If
			' �� ���������� ���� ������� �������������� ��������� ���������� ������ � ������� �� � ���������
			Set oParams = oMenuItem.selectNodes("*[local-name()='params']/*[local-name()='param']")
			If oParams.length > 0 Then
				' ���� ��� ������ ���� ������ �������������� ���������, �� ������� ����� ������� ��������� ����������
				Set oValuesBackup = CreateObject("Scripting.Dictionary")
				For Each sKey In m_oValues.Keys()
					oValuesBackup.Add sKey, m_oValues.Item(sKey)
				Next
			End If
			' ������� ��������� ���������� ������ ���� � ��������� �������� ����
			For Each oParam In oParams
				sMacro = oParam.getAttribute("n")
				m_oValues.Item(sMacro) = oParam.text
			Next
			With New MenuExecuteEventArgsClass
				Set .Menu	= Me
				Set .SelectedMenuItem = oMenuItem
				.Action		= oMenuItem.getAttribute("action")
				XEventEngine_FireEvent m_oEventEngine, "Execute", oSender, .Self()
			End With
			If Not IsEmpty(oValuesBackup) Then
				' ���� �� ������ ����� ����������, �� ������ �� �������
				m_oValues.RemoveAll
				For Each sKey In oValuesBackup.Keys()
					m_oValues.Add sKey, oValuesBackup.Item(sKey)
				Next
			End If
		End If
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@MenuClass.SetMacrosResolver
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE SetMacrosResolver>
	':����������:
	'	�������� ��� ��� ����������� ����������� ���������� �������� ��������.
	':���������:
	'	oDlg - [in] "�������" ����������� ���������� ��������, ��������� DelegateClass
	':��. �����:
	'	MenuClass.Macros, MenuClass.AddMacrosResolver, <P/>
	'	<LINK mc-51, ��������� �������� />
	':���������:
	'	Public Sub SetMacrosResolver( oDlg [As DelegateClass] )
	Public Sub SetMacrosResolver( oDlg )
		m_oEventEngine.ReplaceDelegateForEvent "ResolveMacros", oDlg
	End Sub
	

	'------------------------------------------------------------------------------
	'@@MenuClass.AddMacrosResolver
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE AddMacrosResolver>
	':����������:
	'	��������� ���������� ���������� ��������.
	':���������:
	'	oDlg - [in] "�������" ����������� ���������� ��������, ��������� DelegateClass
	':��. �����:
	'	MenuClass.Macros, MenuClass.SetMacrosResolver, <P/>
	'	<LINK mc-51, ��������� �������� />
	':���������:
	'	Public Sub AddMacrosResolver( oDlg [As DelegateClass] )
	Public Sub AddMacrosResolver(oDlg)
		m_oEventEngine.AddDelegateForEvent "ResolveMacros", oDlg
	End Sub

	
	'------------------------------------------------------------------------------
	'@@MenuClass.SetVisibilityHandler
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE SetVisibilityHandler>
	':����������:
	'	�������� ��� ��� ����������� ����������� ��������� ����������� / ��������� 
	'	������� ���� ��������.
	':���������:
	'	oDlg - [in] "�������" ����������� ����������� / ���������, ��������� DelegateClass
	':��. �����:
	'	MenuClass.AddVisibilityHandler, <P/>
	'	<LINK mc-52, ����������� ��������� / ����������� />
	':���������:
	'	Public Sub SetVisibilityHandler( oDlg [As DelegateClass] )
	Public Sub SetVisibilityHandler(oDlg)
		m_oEventEngine.ReplaceDelegateForEvent "SetVisibility", oDlg
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@MenuClass.AddVisibilityHandler
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE AddVisibilityHandler>
	':����������:
	'	��������� ���������� ��������� ����������� / ��������� ������� ����.
	':���������:
	'	oDlg - [in] "�������" ����������� ����������� / ���������, ��������� DelegateClass
	':��. �����:
	'	MenuClass.SetVisibilityHandler, <P/>
	'	<LINK mc-52, ����������� ��������� / ����������� />
	':���������:
	'	Public Sub AddVisibilityHandler( oDlg [As DelegateClass] )
	Public Sub AddVisibilityHandler(oDlg)
		m_oEventEngine.AddDelegateForEvent "SetVisibility", oDlg
	End Sub

	
	'------------------------------------------------------------------------------
	'@@MenuClass.SetExecutionHandler
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE SetExecutionHandler>
	':����������:
	'	�������� ��� ��� ����������� ����������� ������ ������ ���� ��������.
	':���������:
	'	oDlg - [in] "�������" ����������� ����������, ��������� DelegateClass
	':��. �����:
	'	MenuClass.AddExecutionHandler, <P/>
	'	<LINK mc-53, ����������� ���������� />
	':���������:
	'	Public Sub SetExecutionHandler( oDlg [As DelegateClass] )
	Public Sub SetExecutionHandler(oDlg)
		m_oEventEngine.ReplaceDelegateForEvent "Execute", oDlg
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@MenuClass.AddExecutionHandler
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE AddExecutionHandler>
	':����������:
	'	��������� ���������� ������ ������ ����.
	':���������:
	'	oDlg - [in] "�������" ����������� ����������, ��������� DelegateClass
	':��. �����:
	'	MenuClass.SetExecutionHandler, <P/>
	'	<LINK mc-53, ����������� ���������� />
	':���������:
	'	Public Sub AddExecutionHandler( oDlg [As DelegateClass] )
	Public Sub AddExecutionHandler(oDlg)
		m_oEventEngine.AddDelegateForEvent "Execute", oDlg
	End Sub

	
	'------------------------------------------------------------------------------
	'@@MenuClass.CheckRightsOnStdOperations
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE CheckRightsOnStdOperations>
	':����������:
	'	������������� ����������� ������� ���� ����������� �������� �� ��������� 
	'	������� ��������������� ���� �� �������� ������.
	':���������:
	'	sType - [in] ������������ ���� �������
	'	sObjectID - [in] ������������� ������� (��������� ������������� ��������������)
	':��. �����:
	'	MenuClass.SetMenuItemsAccessRights, MenuClass.SetMenuItemsAccessRightsEx, <P/>
	'	<LINK mc-61, �������� ���� �� ����������� �������� />
	':���������:
	'	Public Sub CheckRightsOnStdOperations( sType [As String], sObjectID [As String] )
	Public Sub CheckRightsOnStdOperations(sType, sObjectID)
		Dim oList			' As ObjectArrayListClass - ������ �������� XObjectPermission
		Dim oNode			' As IXMLDOMNode - ������� menu-item
		
		Set oList = New ObjectArrayListClass
		For Each oNode In m_oXmlMenu.selectNodes("//*[local-name()='menu-item' and not(@hidden)]")
			Select Case oNode.getAttribute("action")
				Case "DoCreate"
					oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CREATE, sType, Empty)
					oNode.setAttribute "type", sType
				Case "DoEdit"
					oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_CHANGE, sType, sObjectID)
					oNode.setAttribute "type", sType
					oNode.setAttribute "oid", sObjectID
				Case "DoMarkDelete", "DoDelete"
					oList.Add internal_New_XObjectPermission(ACCESS_RIGHT_DELETE, sType, sObjectID)
					oNode.setAttribute "type", sType
					oNode.setAttribute "oid", sObjectID
			End Select
		Next
		If Not oList.IsEmpty Then
			SetMenuItemsAccessRights oList.GetArray()
		End If
	End Sub


	'------------------------------------------------------------------------------
	'@@MenuClass.SetMenuItemsAccessRights
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE SetMenuItemsAccessRights>
	':����������:
	'	������������� ����������� ������� ���� �� ��������� ������� ������� �������� ����.
	':���������:
	'	aObjectPermission - ������ �������� ���� �� ������ (����������� XObjectPermission)
	':��. �����:
	'	MenuClass.CheckRightsOnStdOperations, MenuClass.SetMenuItemsAccessRightsEx, <P/>
	'	<LINK mc-61, �������� ���� �� ����������� �������� />
	':���������:
	'	Public Sub SetMenuItemsAccessRights( aObjectPermission [As XObjectPermission(...)] )
	Public Sub SetMenuItemsAccessRights(aObjectPermission)
		SetMenuItemsAccessRightsEx aObjectPermission, True
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@MenuClass.SetMenuItemsAccessRightsEx
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE SetMenuItemsAccessRightsEx>
	':����������:
	'	������������� ����������� ������� ���� �� ��������� ������� ������� �������� 
	'	����. ��������� ��������� ������������ ����������� ������� ���� (�� ���������� 
	'	��� ���������� ��� ���������������).
	':���������:
	'	aObjectPermission - ������ �������� ���� �� ������ (����������� XObjectPermission)
	'	bShowDeniedAsDisabled - ������� "���������� ����������� �������� ��� ���������������" 
	'				(True); ���� False - �� ����������� �������� �� ������������
	':��. �����:
	'	MenuClass.CheckRightsOnStdOperations, MenuClass.SetMenuItemsAccessRights, <P/>
	'	<LINK mc-61, �������� ���� �� ����������� �������� />
	':���������:
	'	Public Sub SetMenuItemsAccessRightsEx( 
	'		aObjectPermission [As XObjectPermission(...)], 
	'		bShowDeniedAsDisabled [As Boolean] 
	'	)
	Public Sub SetMenuItemsAccessRightsEx(aObjectPermission, bShowDeniedAsDisabled)
		Dim aCheckList		' As Boolean() - ��������� �������� ����
		Dim oNode			' As IXMLDOMNode - ������� menu-item
		Dim sAttrName		' As String - ������������ ��������
		Dim i
		
		If bShowDeniedAsDisabled Then
			sAttrName = "disabled"
		Else
			sAttrName = "hidden"
		End If
		aCheckList = X_CheckObjectsRights(aObjectPermission)
		For i=0 To UBound(aObjectPermission)
			If aObjectPermission(i).m_sAction = ACCESS_RIGHT_CREATE Then
				For Each oNode In m_oXmlMenu.selectNodes("//*[local-name()='menu-item' and @action='DoCreate' and @type='" & aObjectPermission(i).m_sTypeName & "']")
					oNode.removeAttribute "type"
					If aCheckList(i) = False Then 
						oNode.setAttribute sAttrName, "1"
					Else
						oNode.removeAttribute sAttrName
					End If
				Next
			ElseIf aObjectPermission(i).m_sAction = ACCESS_RIGHT_CHANGE Then
				For Each oNode In m_oXmlMenu.selectNodes("//*[local-name()='menu-item' and @action='DoEdit' and @type='" & aObjectPermission(i).m_sTypeName & "' and @oid='" & aObjectPermission(i).m_sObjectID & "']")
					oNode.removeAttribute "type"
					oNode.removeAttribute "oid"
					If aCheckList(i) = False Then 
						oNode.setAttribute sAttrName, "1"
					Else
						oNode.removeAttribute sAttrName
					End If
				Next
			ElseIf aObjectPermission(i).m_sAction = ACCESS_RIGHT_DELETE Then
				For Each oNode In m_oXmlMenu.selectNodes("//*[local-name()='menu-item' and (@action='DoMarkDelete' or @action='DoDelete') and @type='" & aObjectPermission(i).m_sTypeName & "' and @oid='" & aObjectPermission(i).m_sObjectID & "']")
					oNode.removeAttribute "type"
					oNode.removeAttribute "oid"
					If aCheckList(i) = False Then 
						oNode.setAttribute sAttrName, "1"
					Else
						oNode.removeAttribute sAttrName
					End If
				Next
			End If
		Next
	End Sub


	'------------------------------------------------------------------------------
	'@@MenuClass.MenuXslTemplate
	'<GROUP !!MEMBERTYPE_Properties_MenuClass><TITLE MenuXslTemplate>
	':����������:	
	'	���������� ��� ����� XSLT-�������, ������������� ��� ������������ 
	'	HTML-������������� ����.
	':����������:	
	'	�������� ������ ��� ������. <P/>
	'	�������� ������������ ����� �������� � ������������ ����.
	':���������:	
	'	Public Property Get MenuXslTemplate [As String]
	Public Property Get MenuXslTemplate
		MenuXslTemplate = m_sXslFilename
	End Property


	'------------------------------------------------------------------------------
	'@@MenuClass.Macros
	'<GROUP !!MEMBERTYPE_Properties_MenuClass><TITLE Macros>
	':����������:	���������� ���-������� �������� ����.
	':����������:	�������� ������ ��� ������.
	':��. �����:	
	'	MenuClass.SetMacrosResolver, MenuClass.AddMacrosResolver, <P/>
	'	<LINK mc-51, ��������� �������� />
	':���������:	
	'	Public Property Get Macros [As Scripting.Dictionary]
	Public Property Get Macros
		Set Macros = m_oValues
	End Property

	
	'------------------------------------------------------------------------------
	'@@MenuClass.XmlMenu
	'<GROUP !!MEMBERTYPE_Properties_MenuClass><TITLE XmlMenu>
	':����������:	���������� XML-������������� �������� ����.
	':����������:	�������� ������ ��� ������.
	':��. �����:	MenuClass.XmlMenuMD
	':���������:	Public Property Get XmlMenu [As IXMLDOMElement]
	Public Property Get XmlMenu
		Set XmlMenu = m_oXmlMenu
	End Property

	
	'------------------------------------------------------------------------------
	'@@MenuClass.XmlMenuMD
	'<GROUP !!MEMBERTYPE_Properties_MenuClass><TITLE XmlMenuMD>
	':����������:	���������� XML-������������� ���������� ����.
	':����������:	�������� ������ ��� ������.
	':��. �����:	MenuClass.XmlMenu
	':���������:	Public Property Get XmlMenuMD [As IXMLDOMElement]
	Public Property Get XmlMenuMD
		Set XmlMenuMD = m_oXmlMenuMD
	End Property

	
	'------------------------------------------------------------------------------
	'@@MenuClass.Initialized
	'<GROUP !!MEMBERTYPE_Properties_MenuClass><TITLE Initialized>
	':����������:	���������� ������� �������������������� ����.
	':����������:	�������� ������ ��� ������.
	':��. �����:	MenuClass.Init
	':���������:	Public Property Get Initialized {As Boolean]
	Public Property Get Initialized
		Initialized = m_bInitialized
	End Property
End Class


'===============================================================================
'@@MenuEventArgsClass
'<GROUP !!CLASSES_x-menu><TITLE MenuEventArgsClass>
':����������:	��������� ������� "ResolveMacros" � "SetVisibility".
'
'@@!!MEMBERTYPE_Methods_MenuEventArgsClass
'<GROUP MenuEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_MenuEventArgsClass
'<GROUP MenuEventArgsClass><TITLE ��������>
Class MenuEventArgsClass
	'@@MenuEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_MenuEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@MenuEventArgsClass.Menu
	'<GROUP !!MEMBERTYPE_Properties_MenuEventArgsClass><TITLE Menu>
	':����������:	������ ����, ��������� MenuClass.
	':���������:	Public Menu [As MenuClass]
	Public Menu
	
	'@@MenuEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_MenuEventArgsClass><TITLE ReturnValue>
	':����������:	����������������.
	':���������:	Public ReturnValue [As Variant]
	Public ReturnValue
	
	'@@MenuEventArgsClass.ActiveMenuItems
	'<GROUP !!MEMBERTYPE_Properties_MenuEventArgsClass><TITLE ActiveMenuItems>
	':����������:	��������� XML-�������� �������� ������� ����.
	':���������:	Public ActiveMenuItems [As IXMLDOMNodeList]
	Public ActiveMenuItems
	
	'@@MenuEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_MenuEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As MenuEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@MenuExecuteEventArgsClass
'<GROUP !!CLASSES_x-menu><TITLE MenuExecuteEventArgsClass>
':����������:	��������� ������� "Execute"
'
'@@!!MEMBERTYPE_Methods_MenuExecuteEventArgsClass
'<GROUP MenuExecuteEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_MenuExecuteEventArgsClass
'<GROUP MenuExecuteEventArgsClass><TITLE ��������>
Class MenuExecuteEventArgsClass
	'@@MenuExecuteEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_MenuExecuteEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@MenuExecuteEventArgsClass.Menu
	'<GROUP !!MEMBERTYPE_Properties_MenuExecuteEventArgsClass><TITLE Menu>
	':����������:	������ ����, �������� ����������� ��������������� ����� ����.
	':���������:	Public Menu [As MenuClass]
	Public Menu
	
	'@@MenuExecuteEventArgsClass.Action
	'<GROUP !!MEMBERTYPE_Properties_MenuExecuteEventArgsClass><TITLE Action>
	':����������:	������������ ���������� �������� ���� (action).
	':���������:	Public Action [As String]
	Public Action
	
	'@@MenuExecuteEventArgsClass.SelectedMenuItem
	'<GROUP !!MEMBERTYPE_Properties_MenuExecuteEventArgsClass><TITLE SelectedMenuItem>
	':����������:	��������� ���� menu-item.
	':���������:	Public SelectedMenuItem	[As IXMLDOMElement]
	Public SelectedMenuItem
	
	'@@MenuExecuteEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_MenuExecuteEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As MenuExecuteEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@SetMenuItemVisibilityEventArgsClass
'<GROUP !!CLASSES_x-menu><TITLE SetMenuItemVisibilityEventArgsClass>
':����������:	��������� ������� "SetMenuItemVisibility". 
':����������:
'	������� ����������������� ��������� � ���������� XMenuClass �� �����.
'	������ ��������� ���������� ���������� ��� ������� (������������ ������� 
'	������������ ������ ������������, � ��� �������� ��� ������� ����������) � 
'	���������� ����� ����������� ������������ ����������� ����������� �������
'	����, � �������� ����������� ����������� ����������� ������ ����.<P/>
'	����� ������� �������������� ����������� ����������� ���������� ������, 
'	������������ ����������� ����������� ������ ���� ���������� ����������, ��
'	��������� ��������������� ����������� ������������ �����������.
':������:	XListClass.MenuVisibilityHandler
'
'@@!!MEMBERTYPE_Methods_SetMenuItemVisibilityEventArgsClass
'<GROUP SetMenuItemVisibilityEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass
'<GROUP SetMenuItemVisibilityEventArgsClass><TITLE ��������>
Class SetMenuItemVisibilityEventArgsClass
	'@@SetMenuItemVisibilityEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@SetMenuItemVisibilityEventArgsClass.Menu
	'<GROUP !!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass><TITLE Menu>
	':����������:	������ ����, �������� ����������� ��������������� ����� ����.
	':���������:	Public Menu [As MenuClass]
	Public Menu
	
	'@@SetMenuItemVisibilityEventArgsClass.Action
	'<GROUP !!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass><TITLE Action>
	':����������:	������������ ���������� �������� ���� (action).
	':���������:	Public Action [As String]
	Public Action
	
	'@@SetMenuItemVisibilityEventArgsClass.MenuItemNode
	'<GROUP !!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass><TITLE MenuItemNode>
	':����������:	XML-���� � ������� �������� <B>i:menu-item</B>.
	':���������:	Public MenuItemNode [As XMLDOMElement]
	Public MenuItemNode
	
	'@@SetMenuItemVisibilityEventArgsClass.Hidden
	'<GROUP !!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass><TITLE Hidden>
	':����������:	�������, ����������� ��� ����� ���� ������ ���� �����. 
	':���������:	Public Hidden [As Boolean]
	Public Hidden
	
	'@@SetMenuItemVisibilityEventArgsClass.Disabled
	'<GROUP !!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass><TITLE Disabled>
	':����������:	�������, �������� ���������� ������ ����. 
	':���������:	Public Disabled [As Boolean]
	Public Disabled
	
	'@@SetMenuItemVisibilityEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SetMenuItemVisibilityEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As SetMenuItemVisibilityEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class
