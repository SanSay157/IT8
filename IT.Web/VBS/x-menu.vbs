'===============================================================================
'@@!!FILE_x-menu
'<GROUP !!SYMREF_VBS>
'<TITLE x-menu - Обслуживание меню на стороне клиента>
':Назначение:	Обслуживание меню на стороне клиента.
'===============================================================================
'@@!!FUNCTIONS_x-menu
'<GROUP !!FILE_x-menu><TITLE Функции и процедуры>
'@@!!CLASSES_x-menu
'<GROUP !!FILE_x-menu><TITLE Классы>
Option Explicit

' Атрибут xml-узла пункта меню для отметки того, что пункт срабатывает на заданую
' клавиатурную комбинацию ("горячая клавиша", hotkey). 
' Используется в MenuClass::ExecuteHotkey
const X_CATCHED_ATTR = "_catched_"

'===============================================================================
'@@New_MenuClass
'<GROUP !!FUNCTIONS_x-menu><TITLE New_MenuClass>
':Назначение:	Возвращает новый экземпляр класса MenuClass.
':Сигнатура:	Function New_MenuClass() [As MenuClass]
Function New_MenuClass()
	Set New_MenuClass = New MenuClass
End Function

'===============================================================================
'@@MenuClass
'<GROUP !!CLASSES_x-menu><TITLE MenuClass>
':Назначение:	
':Примечание:	
'	Класс реализует меню, не делая каких-либо предположений о контексте, в котором
'	используется данное меню; сценарий инициализации и отображения, соответствующих
'	контексту, остается за прикладным программистом.<P/>
'	Сценарий использования:
'	1. Создать экземпляр - new MenuClass;
'	2. (Опциональный шаг) Добавить обработчики, используя SetMacrosResolver, 
'		SetVisibilityHandler, SetExecutionHandler (или их варианты);
'	3. Вызвать Init и передать метаданные меню - узел i:menu;
'	4. (Опциональный шаг) Заменить обработчики, используя SetMacrosResolver, 
'		SetVisibilityHandler, SetExecutionHandler (или их варианты);
'	5. Вызвать:
'		* ShowPopupMenu - для отображения всплывающего меню
':См. также:	
'	New_MenuClass,<P/>
'	<LINK common2, Обслуживание меню - класс MenuClass/>
'
'@@!!MEMBERTYPE_Methods_MenuClass
'<GROUP MenuClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_MenuClass
'<GROUP MenuClass><TITLE Свойства>
Class MenuClass
	Private m_oPopup					' Объект CROC.Popup
	Private m_oXmlMenu					' Текущий XML меню; при вызове ShowPopup cюда помещается копия m_oXmlMenuMD
	Private m_oXmlMenuMD				' Метаданные меню
	Private m_oValues					' Хеш-таблица макросов, экземпляр Scripting.Dictionary
	Private m_sXslFilename				' Имя стильшита для HTML-меню
	Private m_oRegExp					' Объект RegExp
	Private m_bInitialized				' Признак инициализированности меню
	Private m_oEventEngine				' Экземпляр EventEngineClass
	Private m_bMenuProcessing			' Признак того, что меню в данный момент отрисовывается (борьба с racing conditions)
	
	'------------------------------------------------------------------------------
	' "Конструктор"	
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
	':Назначение:	Возвращает экземпляр EventEngine, используемый для управления 
	'				и вызова обработчиков событий меню.
	':Примечание:	Свойство только для чтения.
	':Сигнатура:	Public Property Get EventEngine [As EventEngineClass]
	Public Property Get EventEngine
		Set EventEngine = m_oEventEngine
	End Property


	'------------------------------------------------------------------------------
	'@@MenuClass.Init
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE Init>
	':Назначение:	Инициализация меню.
	':Параметры:
	'	oXmlMenuMD - [in] корневой элемент метаданных меню (i:menu), экземпляр IXMLDOMElement 
	':Примечание:
	'	<B>Внимание!</B> XML с метаданными меню не клонируется, новый XMLDOMDocument 
	'	не создается.
	':См. также:
	'	<LINK mc-2, Инициализация меню/>
	':Сигнатура:	
	'	Public Sub Init( oXmlMenuMD [As IXMLDOMElement] )
	Public Sub Init(oXmlMenuMD)
		Dim oNode		' IXMLDOMElement
		Dim oMatch		' RegExp.Match
		
		m_bInitialized = False
		If IsNothing(oXmlMenuMD) Then
			Err.Raise -1, "Class Menu::Init", "Не корректные метаданные меню"
		End If
		Set m_oXmlMenuMD = oXmlMenuMD
		Set m_oXmlMenu = Nothing
		m_oValues.RemoveAll
		If oXmlMenuMD.baseName <> "menu" Then Exit Sub
		' найдем в тексте меню все макросы (текст, начинающийся с @@) и сформируем хеш из них
		m_oRegExp.Pattern = "@@([A-Za-z][\w]*)"
		For Each oMatch In m_oRegExp.Execute( m_oXmlMenuMD.Xml )
			m_oValues.Item(oMatch.SubMatches(0)) = vbNullString
		Next
		' получим и установим имя стильшита текущего меню (используется только для Html меню)
		m_sXslFilename = m_oXmlMenuMD.getAttribute("xslt-template")
		If IsNull(m_sXslFilename) Then m_sXslFilename = vbNullString
		
		' Инициализируем обработчики событий, заданные в метаданных меню
		' прочитаем и установим резолверы макросов, обработчики доступности и видимости, обработчики выбора пункта меню
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

		' добавим собственный обработчик выполнения для перехвата action'a DoExecuteVbs
		AddExecutionHandler X_CreateDelegate(Me, "OnExecuteVbs")
		m_bInitialized = True
	End Sub


	'------------------------------------------------------------------------------
	'@@MenuClass.OnExecuteVbs
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE OnExecuteVbs>
	':Назначение:	Обработчик события "ExecuteVbs"
	':Параметры:
	'	oSender - [in] "источник" события - экземпляр MenuClass, "сгенерировавший" 
	'			событие "ExecuteVbs"
	'	oEventArgs - [in] Параметры события, экземпляр MenuExecuteEventArgsClass
	':Сигнатура:
	'	Public Sub OnExecuteVbs( oSender [As MenuClass], oEventArgs [As MenuExecuteEventArgsClass] )
	Public Sub OnExecuteVbs(oSender, oEventArgs)
		If oEventArgs.Action = "DoExecuteVbs" Then
			If Macros.Exists("Script") Then
				ExecuteGlobal Macros.Item("Script")
			End If
		End If
	End Sub


	'------------------------------------------------------------------------------
	':Назначение:	Инициализирует в m_oXmlMenu копию метаданных меню.
	Private Sub createMenuTemplate
		Dim nIdx		' индекс, используемый в качестве наименования (атрибут n) пункта меню
		Dim oNode		' IXMLDOMElement - xml-узел элемента меню
		Dim vValue		' As Vatiant - значение атрибута n
		
		Set m_oXmlMenu  = m_oXmlMenuMD.cloneNode(true)
		Set m_oXmlMenu = XService.XMLGetDocument.appendChild( m_oXmlMenu )
		'TODO: разобраться с XService.XmlSetSelectionNamespaces m_oXmlMenu.ownerDocument,
		' т.к. она не работает: m_oXmlMenu.selectNodes("descendant::*/namespace::*") находит только "xml" !!!
		m_oXmlMenu.ownerDocument.SetProperty "SelectionLanguage", "XPath"	
		m_oXmlMenu.ownerDocument.SetProperty "SelectionNamespaces", m_oXmlMenuMD.ownerDocument.GetProperty("SelectionNamespaces")
		
		' для каждого menu-item'a сформируем уникальное наименование, чтобы отличать пункты с одним action'ом друг от друга
		' Примечание: необходимо учесть, что пункты уже могут иметь наименования, в том числе в виде индексов, 
		' поэтому необходима проверка на уникальность наименования.
		nIdx = 0
		' Пройдем по всем узлам с атрибутом n и найдем максимальное значение среди числовых значений
		For Each oNode In m_oXmlMenu.selectNodes(".//*[@n and local-name()!='macros-resolver' and local-name()!='visibility-handler' and local-name()!='execution-handler']")
			vValue = oNode.GetAttribute("n")
			If Not IsNull(vValue ) Then
				If IsNumeric(vValue) Then
					vValue = CLng(vValue)
					If nIdx < vValue Then nIdx = vValue
				End If
			End If
		Next
		' по всем узлам меню, кроме служебных. 
		For Each oNode In m_oXmlMenu.selectNodes(".//*[local-name()!='macros-resolver' and local-name()!='visibility-handler' and local-name()!='execution-handler']")
			If IsNull(oNode.GetAttribute("n")) Then
				nIdx = nIdx + 1
				oNode.setAttribute "n", nIdx
			End If
		Next
		
		' Инициализируем параметры меню
		For Each oNode In m_oXmlMenu.selectNodes("*[local-name()='params']/*[local-name()='param']")
			m_oValues.Item( oNode.getAttribute("n") ) = oNode.text
		Next
	End Sub


	'------------------------------------------------------------------------------
	'@@MenuClass.ExecuteHotkey
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE ExecuteHotkey>
	':Назначение:
	'	Ищет и выполняет пункт меню, для которого задана комбинация "горячих" клавиш, 
	'	соответствующих комбинации нажатых клавиш (описание которых представлено
	'	экземпляром класса AccelerationEventArgsClass, передаваемого параметром).
	':Параметры:
	'	oSender - [in] экземпляр объекта-"инициатора" обработки (которому "принадлежит"
	'		и в контексте которого существует экземпляр MenuClass, чей метод вызывается)
	'	oAccelerationArgs - [in] экземпляр класса AccelerationEventArgsClass
	':Результат:
	'	Логический признак, отражающий факт нахождения пункта меню с соответствующим
	'	описанием "горячих" клавиш:
	'	* True - соответствующий пункт меню найден, вызван обработчик этого пункта;
	'	* False - в противном случае.
	':См. также:
	'	AccelerationEventArgsClass,<P/>
	'	<LINK mc-4, Обслуживание комбинаций горячих клавиш/>
	':Сигнатура:
	'	Public Function ExecuteHotkey( 
	'		oSender [As Object], 
	'		oAccelerationArgs [As AccelerationEventArgsClass] 
	'	) [As Boolean]
	Public Function ExecuteHotkey( oSender, oAccelerationArgs )
		Dim oNode			' As IXMLDOMElement - i:menu-item
		Dim bCatched		' As Boolean - Признак, что для текущей конбинации найден пункт меню
		Dim sCmd			' As String - наименование пункта меню (атрибут n)
		Dim sHotkeys		' As String - атрибут hotkey menu-item'a - список хоткеев пункта меню
		Dim aHotkeys		' As Array - массив хоткеев
		Dim sHotkey			' As String - один хоткей из списка
		Dim aKeys			' As Array - массив элементов хоткея
		Dim sKey			' As String - элемент хоткея (код клавиши или буква)
		Dim i, j
		Dim oActiveItems				' Коллекция отображаемых пунктов меню, если один, то сразу выполняетя
		Dim bCatchedOneAtLeast			' признак: найден по крайней мере один пункт, удовлетворяющий нажатой комбинации
		Dim bHotkeyContainsAlt			' признак: опредение хоткея содержит ALT
		Dim bHotkeyContainsShift		' признак: опредение хоткея содержит SHIFT
		Dim bHotkeyContainsControl		' признак: опредение хоткея содержит CTRL
		
		ExecuteHotkey = False
		If Not m_bInitialized Then Exit Function
		createMenuTemplate
		bCatchedOneAtLeast = False
		For Each oNode In m_oXmlMenu.selectNodes("//*[local-name()='menu-item' and @action and @hotkey]")
			'клавиша/комбинация клавиш акселераторов для пункта меню 
			'Клавиша описывается одной из констант VK_*, либо явным заданием символа, 
			'	кроме символа "+" (Он используется для задания комбинаций клавиш)
			'	и символа "," (Он используется для разделения вариантов).
			'Комбинации клавиш могут быть заданы с помошью модификаторов спец-клавиш: ALT, CTRL, SHIFT. 
			'Например: ALT+VK_F1, ALT+CTRL+C. Список констант VK_* см. в x-const.aspx
			'Поддерживается задание нескольких модификаторов (ALT,CTRL,SHIFT) в произвольной последовательности и 
			'одного символа/функциональной клавиши. При этом регистр символа игнорируется. Т.е. CTRL+D и CTRL+d сработают одновременно.
			sHotkeys = oNode.getAttribute("hotkey")
			aHotkeys = Split(UCase(sHotkeys), ",")
			For i=0 To UBound(aHotkeys)
				sHotkey = Trim(aHotkeys(i))
				If 0<>Len(sHotkey) Then
					' проверим
					bCatched = True
					bHotkeyContainsAlt = false
					bHotkeyContainsShift = false
					bHotkeyContainsControl = false
					aKeys = Split(sHotkey, "+")
					For j=0 To UBound(aKeys)
						sKey = Trim(aKeys(j))
						Select Case sKey
							Case  vbNullString
								' Ничего не делаем
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
									' функциональная клавиша. Эта константа (VK_*) должна быть определена в контексте (x-const.aspx)
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
						' если текущий пункт меню срабатывает на заданый хоткей, то пометим его хитро и перейдем к следующему
						oNode.setAttribute X_CATCHED_ATTR, "1"
						bCatchedOneAtLeast = True
						Exit For
					End If 
				End If 
			Next
		Next
		If bCatchedOneAtLeast Then
			Set oActiveItems = m_oXmlMenu.selectNodes("//*[local-name()='menu-item' and @" & X_CATCHED_ATTR & "]")
			' нашли пункт меню с заданой комбинации клавиш, выполним подготовительные дейстивия меню
			' запустим все макрос-резолверы (вычисление значений макросов)
			runMacrosResolvers oSender
			' подставим вычисленные значения макросов в меню
			substituteMacros
			' запустим обработчики установки видимости/доступности
			runVisibilityResolversEx oSender, oActiveItems
			Set oActiveItems = m_oXmlMenu.selectNodes("//*[local-name()='menu-item' and @" & X_CATCHED_ATTR & " and not(@hidden) and not(@disabled)]")
			m_oXmlMenu.selectNodes("@" & X_CATCHED_ATTR).removeAll
			If oActiveItems.length = 0 Then
				Exit Function
			ElseIf oActiveItems.length = 1 Then
				Set oNode = oActiveItems.item(0)
				sCmd = oNode.getAttribute("n")
			ElseIf oActiveItems.length > 1 Then
				' сконструируем popup-меню
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
				If IsNull(sCmd) Then Exit Function	' ничего не выбрали
			End If
			runExecutionHandlers oSender, sCmd
			ExecuteHotkey = True
			oAccelerationArgs.Processed = True
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@MenuClass.ShowPopupMenuSectionWithPos
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE ShowPopupMenuSectionWithPos>
	':Назначение:
	'	Открывает PopUp меню заданной секции, с указанием позиции для отображения.
	':Параметры:
	'	oSender - [in] ссылка на объект, передаваемая в execution-handler
	'	sSectionName - [in] наименование секции (атрибут n для i:menu-section)
	'	nPosX - [in] экранные координаты, позиция по горизонтали
	'	nPosY - [in] экранные координаты, позиция по вертикали
	':См. также:
	'	MenuClass.ShowPopupMenu, MenuClass.ShowPopupMenuEx, 
	'	MenuClass.ShowPopupMenuWithPos, MenuClass.ShowPopupMenuWithPosEx
	':Сигнатура:
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
	':Назначение:
	'	Открывает PopUp меню, с указанием позиции для отображения.
	':Параметры:
	'	oSender - [in] ссылка на объект, передаваемая в execution-handler
	'	nPosX - [in] экранные координаты, позиция по горизонтали
	'	nPosY - [in] экранные координаты, позиция по вертикали
	':См. также:
	'	MenuClass.ShowPopupMenu, MenuClass.ShowPopupMenuEx, 
	'	MenuClass.ShowPopupMenuWithPosEx, 
	'	MenuClass.ShowPopupMenuSectionWithPos
	':Сигнатура:
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
	':Назначение:
	'	Открывает pop-up меню, с указанием позиции отображения. Задает режим 
	'	принудительного "выполнения" обработчика пункта меню "по умолчанию" 
	'	(см. "Замечания").
	':Параметры:
	'	oSender - [in] ссылка на объект, передаваемая в execution-handler
	'	nPosX - [in] экранные координаты, позиция по горизонтали
	'	nPosY - [in] экранные координаты, позиция по вертикали
	'	bRunDefault - [in] логический признак, определяющий поведение меню при 
	'			налчичии пункта меню "по умолчанию" (см. "замечания")
	':Примечание:
	'	Параметр bRunDefault определяет поведение меню в случае наличия в меню 
	'	пунктов "по умолчанию". Перед отображением меню проверяется наличие и 
	'	доступность таких пунктов (по результатм выполнения обработчиков видимости /
	'	доступности). Если такой пункт будет представлен и он будет один, и при этом
	'	параметр bRunDefault задан в значение True, то метод сразу вызовет обработчик 
	'	выполнения для этого пункта, без отображения меню.<P/>
	'	Если параметр bRunDefault задан в значение False, то меню отображается всегда,
	'	вне зависимости от наличия пунктов меню "по умолчанию".
	':См. также:
	'	MenuClass.ShowPopupMenu, MenuClass.ShowPopupMenuEx, 
	'	MenuClass.ShowPopupMenuWithPos, 
	'	MenuClass.ShowPopupMenuSectionWithPos,<P/>
	'	<LINK mc-111, Пункт меню по умолчанию />
	':Сигнатура:
	'	Public Sub ShowPopupMenuWithPosEx(
	'		oSender [As Object], 
	'		nPosX [As Long], 
	'		nPosY [As Long], 
	'		bRunDefault [As Boolean] )
	Public Sub ShowPopupMenuWithPosEx(oSender, nPosX, nPosY, bRunDefault)
		Internal_ShowPopupMenuFragmentWithPosEx oSender, Null, nPosX, nPosY, bRunDefault
	End Sub

	'------------------------------------------------------------------------------
	':Назначение:	Подготавливает объект m_oPopUp к использованию
	Private Sub preparePopupObject
		If IsEmpty(m_oPopup) Then
			Set m_oPopUp = XService.CreateObject("CROC.XPopUpMenu")
		Else
			m_oPopUp.Clear
		End If
	End Sub
	
	'------------------------------------------------------------------------------
	':Назначение:	Внутренний метод отображения pop-up-представления
	Private Sub Internal_ShowPopupMenuFragmentWithPosEx(oSender, sSectionName, nPosX, nPosY, bRunDefault)
		Dim sCmd		' action выбранного menu-item'a
		Dim oNodes		' As IXMLDOMNodeList
		Dim oXmlMenu	' As IXMLDOMElement
		
		' предотвратим повторный вход
		If m_bMenuProcessing Then Exit Sub
		m_bMenuProcessing = True
		If IsNothing(m_oXmlMenuMD) Then
			Err.Raise -1, "Class Menu::ShowPopupMenu", "Не заданы метаданные меню"
		End If
		preparePopupObject
		
		createMenuTemplate
		' запустим все макрос-резолверы (вычисление значений макросов)
		runMacrosResolvers oSender
		' подставим вычисленные значения макросов в меню
		substituteMacros
		' получим отображаемую секцию или меню целиком
		If hasValue(sSectionName) Then
			Set oXmlMenu = m_oXmlMenu.selectSingleNode("*[local-name()='menu-section' and @n='" & sSectionName & "']")
			If oXmlMenu Is Nothing Then Alert "Секция с наименованием '" & sSectionName & "' не найдена в описании меню." : Exit Sub
		Else
			Set oXmlMenu = m_oXmlMenu
		End If
		' запустим обработчики установки видимости/доступности
		runVisibilityResolversForSection oSender, oXmlMenu
		
		' сконструируем popup-меню
		createPopup m_oPopUp, oXmlMenu
		m_bMenuProcessing = False
		
		If m_oPopup.Count=0 Then Exit Sub
		If bRunDefault Then
			' если получилось, что доступен один пункт и у него есть атрибут 'may-be-default', то выполним его сразу
			Set oNodes = oXmlMenu.selectNodes("//*[local-name()='menu-item' and not(@hidden) and not(@disabled)]")
			If oNodes.length = 1 Then
				If Not IsNull(oNodes.item(0).getAttribute("may-be-default")) Then
					runExecutionHandlers oSender, oNodes.item(0).getAttribute("n")
					Exit Sub
				End If
			End If
		End If
		' получим выбранную команду
		if IsNumeric(nPosX) And IsNumeric(nPosY) Then
			sCmd = m_oPopup.Show( nPosX, nPosY )
		Else
			sCmd = m_oPopup.Show
		End If
		If IsNull(sCmd) Then Exit Sub	' ничего не выбрали
		' запустим обработчики выбора пункта меню
		runExecutionHandlers oSender, sCmd
	End Sub


	'------------------------------------------------------------------------------
	'@@MenuClass.ShowPopupMenu
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE ShowPopupMenu>
	':Назначение:
	'	Открывает pop-up меню.
	':Параметры:
	'	oSender - [in] ссылка на объект, передаваемая в execution-handler
	':См. также:
	'	MenuClass.ShowPopupMenuEx, 
	'	MenuClass.ShowPopupMenuWithPos, MenuClass.ShowPopupMenuWithPosEx
	':Сигнатура:
	'	Public Sub ShowPopupMenu( oSender [As Object] )
	Public Sub ShowPopupMenu(oSender)
		ShowPopupMenuWithPosEx oSender, Null, Null, False
	End Sub


	'------------------------------------------------------------------------------
	'@@MenuClass.ShowPopupMenuEx
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE ShowPopupMenuEx>
	':Назначение:
	'	Открывает pop-up меню. Задает режим принудительного "выполнения" обработчика 
	'	пункта меню "по умолчанию" (см. "Замечания").
	':Параметры:
	'	oSender - [in] ссылка на объект, передаваемая в execution-handler
	'	bRunDefault - [in] логический признак, определяющий поведение меню при 
	'			налчичии пункта меню "по умолчанию" (см. "замечания")
	':Примечание:
	'	Параметр bRunDefault определяет поведение меню в случае наличия в меню 
	'	пунктов "по умолчанию". Перед отображением меню проверяется наличие и 
	'	доступность таких пунктов (по результатм выполнения обработчиков видимости /
	'	доступности). Если такой пункт будет представлен и он будет один, и при этом
	'	параметр bRunDefault задан в значение True, то метод сразу вызовет обработчик 
	'	выполнения для этого пункта, без отображения меню.<P/>
	'	Если параметр bRunDefault задан в значение False, то меню отображается всегда,
	'	вне зависимости от наличия пунктов меню "по умолчанию".
	':См. также:
	'	MenuClass.ShowPopupMenu, 
	'	MenuClass.ShowPopupMenuWithPos, MenuClass.ShowPopupMenuWithPosEx,<P/>
	'	<LINK mc-111, Пункт меню по умолчанию />
	':Сигнатура:
	'	Public Sub ShowPopupMenuEx( oSender [As Object], bRunDefault [As Boolean] )
	Public Sub ShowPopupMenuEx(oSender, bRunDefault)
		ShowPopupMenuWithPosEx oSender, Null, Null, bRunDefault 
	End Sub


	'------------------------------------------------------------------------------
	':Назначение:	Внутренний метод рекурсивного создания popup-меню
	'	[in] oPopup As CROC.XPopupMenu
	'	[in] oXmlCurMenu As IXMLDOMElement - узел меню или секции (menu/menu-section)
	Private Sub createPopup(oPopup, oXmlCurMenu)
		Dim oSubMenu		' Popup-подменю
		Dim oNodes			' As IXMLDOMSelection - коллекция отображаемых узлов
		Dim oNode			' узел menu-item
		Dim bAddSeparator	' признак необходимости добавить разделитель
		Dim bIsFirst		' признак что пункт меню первый
		Dim bIsLast			' признак что пункт меню последний
		Dim bWasSeparator	' признак что предыдущий пункт меню был разделителем
		Dim nCounter		' счетчик итераций
		Dim nCount			' количество пунктов
		bIsFirst = True
		bAddSeparator = False
		bWasSeparator = False

		' исполняемые пункты меню + секции		
		Set oNodes = oXmlCurMenu.selectNodes("*[local-name()='menu-item' and not(@hidden)] | *[local-name()='menu-item-separ' and not(@hidden)] | *[local-name()='menu-section' and not(@hidden)]")
		nCount = oNodes.length
		nCounter = 0
		For Each oNode In oNodes
			bIsLast = CBool(nCounter = nCount - 1)
			' если осталась необходимость добавить разделитель от предыдущего пункта меню (separator-after)
			If bAddSeparator And oNode.baseName <> "menu-item-separ" And Not bWasSeparator  Then
				oPopup.AddSeparator
				bWasSeparator = True
			End If
			If oNode.baseName = "menu-item-separ" Then
				If Not bIsFirst And Not bIsLast And Not bWasSeparator Then 
					' убедимся, что после текущего разделителя есть пункт меню-не разделитель
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
					' текущий пункт - секция. Если она содержит неинформационные подпункты - то добавим подменю
					If Not oNode.selectSingleNode(".//*[local-name()='menu-item' and not(@hidden)]") Is Nothing Then
						Set oSubMenu = oPopup.AddSubMenu( oNode.getAttribute("t") )
						createPopup oSubMenu, oNode
						bWasSeparator = False
					End If
				Else
					' обычный пункт меню
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
	':Назначение:
	'	"Фабричный" метод создания XML-описания пункта меню (menu-item).
	':Параметры:
	'	sAction - [in] наименования действия (action)
	'	sTitle - [in] текст пункта меню
	':Результат:
	'	XML-описание нового пункта меню, как экземпляр IXMLDOMElement.
	':См. также:
	'	MenuClass.CreateXmlMenuSection
	':Сигнатура:
	'	Public Function CreateXmlMenuItem( 
	'		sAction [As String], sTitle [As String] 
	'	) [As IXMLDOMElement]
	Public Function CreateXmlMenuItem(sAction, sTitle)
		Dim oItem		' узел menu-item
		
		Set oItem = createXmlMenuItemTemplate("menu-item")
		oItem.setAttribute "action", sAction
		oItem.setAttribute "t", sTitle
		' уникальное наимеонвание узла
		oItem.setAttribute "n", CreateGuid()
		Set CreateXmlMenuItem = oItem
	End Function

		
	'------------------------------------------------------------------------------
	'@@MenuClass.CreateXmlMenuSection
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE CreateXmlMenuSection>
	':Назначение:
	'	"Фабричный" метод создания XML-описания секции меню (menu-section).
	':Параметры:
	'	sTitle - [in] текст с заголовком секции
	':Результат:
	'	XML-описание новой секции меню, как экземпляр IXMLDOMElement.
	':См. также:
	'	MenuClass.CreateXmlMenuItem
	':Сигнатура:
	'	Public Function CreateXmlMenuSection( sTitle [As String] ) [As IXMLDOMElement]
	Public Function CreateXmlMenuSection(sTitle)
		Dim oItem		' узел menu-item
		
		Set oItem = createXmlMenuItemTemplate("menu-section")
		oItem.setAttribute "t", sTitle
		Set CreateXmlMenuSection = oItem
	End Function
	

	'------------------------------------------------------------------------------
	':Назначение:	Создает заготовку XML-описания пункта меню (произвольного).
	':Параметры:	sTagName - [in] наименвоание элемента метаописания
	Private Function createXmlMenuItemTemplate(sTagName)
		Dim oXmlDoc		' IXMLDOMDocument - фабрика xml-узла menu-item
		Dim sPrefix		' приефикс элемента меню
		
		sPrefix = ""
		If m_oXmlMenuMD Is Nothing Then
			Set oXmlDoc = XService.XMLGetDocument
		Else
			Set oXmlDoc = m_oXmlMenuMD.ownerDocument
			' в качестве префикса используем префикс корневого узла метаданных меню
			sPrefix = m_oXmlMenuMD.prefix
			If hasValue(sPrefix) Then sPrefix = sPrefix & ":"
		End If
		Set createXmlMenuItemTemplate = oXmlDoc.createElement(sPrefix & sTagName)
	End Function


	'------------------------------------------------------------------------------
	':Назначение:	
	'	Выполняет подготовку меню: 
	'	- создание меню из метаописания, 
	'	- вызов macro-resolver'ов и visibility-handler'ов
	Public Sub PrepareMenu(oSender)
		PrepareMenuEx oSender, False	
	End Sub


	'------------------------------------------------------------------------------
	':Назначение:	
	'	Выполняет подготовку меню: 
	'	- создание меню из метаописания, 
	'	- вызов macro-resolver'ов и visibility-handler'ов
	':Параметры:
	'	[in] bOnlyRootLevel - если True, то visibility-handler'ы вызываются только 
	'		для корневых пунктов меню, иначе - для всех
	Public Sub PrepareMenuEx(oSender, bOnlyRootLevel)
		createMenuTemplate
		' запустим все макрос-резолверы (вычисление значений макросов)
		runMacrosResolvers oSender
		' подставим вычисленные значения макросов в меню
		substituteMacros
		' запустим обработчики установки видимости/доступности
		If bOnlyRootLevel Then
			runVisibilityResolversEx oSender, m_oXmlMenu.selectNodes("*")
		Else
			runVisibilityResolvers oSender
		End If
	End Sub


	'------------------------------------------------------------------------------
	':Назначение:	Подставляет значения макросов из коллекции m_oValues в XML-меню
	Private Sub substituteMacros
		Dim sKey		' ключ хеш-таблицы
		Dim oNode		' As IXMLDOMNode
		
		' по всем макросам в коллекции
		For Each sKey In m_oValues.Keys
			' по всем узлам, содержащим подстроку '@@'
			For Each oNode In m_oXmlMenu.selectNodes("//text()[contains(.,'@@" & sKey & "')]") '  | //@*[contains(text(),'@@" & sKey & "')
				' подставим значение макроса в меню, если оно не NULL
				If IsNull(m_oValues.item(sKey)) Then
					oNode.text = Replace( oNode.text, "@@" & sKey, "[не определено]" )
				Else
					oNode.text = Replace( oNode.text, "@@" & sKey, m_oValues.Item(sKey) )
				End If
			Next
		Next
	End Sub
	
	
	'------------------------------------------------------------------------------
	':Назначение:	Запускает все резолверы макросов (алиасов).
	Private Sub runMacrosResolvers(oSender)
		If m_oEventEngine.IsHandlerExists("ResolveMacros") Then
			With New MenuEventArgsClass
				Set .Menu	= Me
				XEventEngine_FireEvent m_oEventEngine, "ResolveMacros", oSender, .Self()
			End With
		End If
	End Sub
	
	
	'------------------------------------------------------------------------------
	':Назначение:	
	'	Запускает все резолверы проставления доступности / видимости для ВСЕХ 
	'	элементов меню.
	Private Sub runVisibilityResolvers(oSender)
		runVisibilityResolversForSection oSender, m_oXmlMenu
	End Sub


	'------------------------------------------------------------------------------
	':Назначение:	
	'	Запускает все резолверы проставления доступности/видимости элементов меню 
	'	заданной секции ( в том числе самого меню).
	':Параметры:
	'	oXmlMenu - [in] узел i:menu или i:menu-section, экземпляр IXMLDOMElement
	Private Sub runVisibilityResolversForSection(oSender, oXmlMenu)
		runVisibilityResolversEx oSender, oXmlMenu.selectNodes("//*[(local-name()='menu-item' and @action) or (local-name()='menu-section')]")
	End Sub


	'------------------------------------------------------------------------------
	':Назначение:	
	'	Запускает все резолверы проставления доступности / видимости заданных 
	'	элементов меню.
	':Параметры:
	'	oActiveMenuItems - [in] коллекция пунктов меню (menu-item и menu-section),
	'						экземпляр IXMLDOMNodeList.
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
	':Назначение:
	'	Запускает все обработчики пункта меню, выбранного пользователем.
	':Параметры:
	'	oSender - [in] ссылка на объект, передаваемая в execution-handler
	'	sCmd - [in] уникальное наименование выбранного пункта меню (значение атрибута "n")
	':Исключения:
	'	В следующих случаях вызов метода приводит к возникновению ошибки времени 
	'	выполнения: 
	'	* В метаописании меню нет пункта меню с уникальным наименованием, заданным 
	'		параметром sCmd.
	':См. также:
	'	<LINK mc-53, Обработчики выполнения />
	':Сигнатура:
	'	Public Sub RunExecutionHandlers( oSender [As Object], sCmd [As String] )
	Public Sub RunExecutionHandlers( oSender, sCmd )
		Dim oMenuItem		' As IXMLDOMElement - выбранный menu-item
		Dim oParam			' As IXMLDOMElement - узел param в метаданных меню 
		Dim sMacro			' As String			- наименование макроса
		Dim oParams			' As IXMLDOMNodeList - коллекция параметров пункта меню
		Dim oValuesBackup	' As Scriptng.Dictionary - бекап текущей коллекции параметров
		Dim sKey			' As String - ключ словаря
		
		If m_oEventEngine.IsHandlerExists("Execute") Then
			Set oMenuItem = m_oXmlMenu.selectSingleNode("//*[local-name()='menu-item' and @n='" & sCmd & "']") 
			If oMenuItem Is Nothing Then
				Err.Raise -1, "MenuClass::RunExecutionHandlers", "Не найден menu-item с заданным наименованием (n) '" & sCmd & "'"
			End If
			' из метаданных меню получим дополнительные параметры выбранного пункта и добавим их в коллекцию
			Set oParams = oMenuItem.selectNodes("*[local-name()='params']/*[local-name()='param']")
			If oParams.length > 0 Then
				' если для пункта меню заданы дополнительные параметры, то сделаем бекап текущей коллекции параметров
				Set oValuesBackup = CreateObject("Scripting.Dictionary")
				For Each sKey In m_oValues.Keys()
					oValuesBackup.Add sKey, m_oValues.Item(sKey)
				Next
			End If
			' добавим параметры выбранного пункта меню в коллекцию макросов меню
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
				' если мы делали бекап параметров, то вернем их обратно
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
	':Назначение:
	'	Замещает все уже добавленные обработчики резрешения макросов заданным.
	':Параметры:
	'	oDlg - [in] "делегат" обработчика разрешения макросов, экземпляр DelegateClass
	':См. также:
	'	MenuClass.Macros, MenuClass.AddMacrosResolver, <P/>
	'	<LINK mc-51, Резолверы макросов />
	':Сигнатура:
	'	Public Sub SetMacrosResolver( oDlg [As DelegateClass] )
	Public Sub SetMacrosResolver( oDlg )
		m_oEventEngine.ReplaceDelegateForEvent "ResolveMacros", oDlg
	End Sub
	

	'------------------------------------------------------------------------------
	'@@MenuClass.AddMacrosResolver
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE AddMacrosResolver>
	':Назначение:
	'	Добавляет обработчик разрешения макросов.
	':Параметры:
	'	oDlg - [in] "делегат" обработчика разрешения макросов, экземпляр DelegateClass
	':См. также:
	'	MenuClass.Macros, MenuClass.SetMacrosResolver, <P/>
	'	<LINK mc-51, Резолверы макросов />
	':Сигнатура:
	'	Public Sub AddMacrosResolver( oDlg [As DelegateClass] )
	Public Sub AddMacrosResolver(oDlg)
		m_oEventEngine.AddDelegateForEvent "ResolveMacros", oDlg
	End Sub

	
	'------------------------------------------------------------------------------
	'@@MenuClass.SetVisibilityHandler
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE SetVisibilityHandler>
	':Назначение:
	'	Замещает все уже добавленные обработчики установки доступности / видимости 
	'	пунктов меню заданным.
	':Параметры:
	'	oDlg - [in] "делегат" обработчика доступности / видимости, экземпляр DelegateClass
	':См. также:
	'	MenuClass.AddVisibilityHandler, <P/>
	'	<LINK mc-52, Обработчики видимости / доступности />
	':Сигнатура:
	'	Public Sub SetVisibilityHandler( oDlg [As DelegateClass] )
	Public Sub SetVisibilityHandler(oDlg)
		m_oEventEngine.ReplaceDelegateForEvent "SetVisibility", oDlg
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@MenuClass.AddVisibilityHandler
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE AddVisibilityHandler>
	':Назначение:
	'	Добавляет обработчик установки доступности / видимости пунктов меню.
	':Параметры:
	'	oDlg - [in] "делегат" обработчика доступности / видимости, экземпляр DelegateClass
	':См. также:
	'	MenuClass.SetVisibilityHandler, <P/>
	'	<LINK mc-52, Обработчики видимости / доступности />
	':Сигнатура:
	'	Public Sub AddVisibilityHandler( oDlg [As DelegateClass] )
	Public Sub AddVisibilityHandler(oDlg)
		m_oEventEngine.AddDelegateForEvent "SetVisibility", oDlg
	End Sub

	
	'------------------------------------------------------------------------------
	'@@MenuClass.SetExecutionHandler
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE SetExecutionHandler>
	':Назначение:
	'	Замещает все уже добавленные обработчики выбора пункта меню заданным.
	':Параметры:
	'	oDlg - [in] "делегат" обработчика выполнения, экземпляр DelegateClass
	':См. также:
	'	MenuClass.AddExecutionHandler, <P/>
	'	<LINK mc-53, Обработчики выполнения />
	':Сигнатура:
	'	Public Sub SetExecutionHandler( oDlg [As DelegateClass] )
	Public Sub SetExecutionHandler(oDlg)
		m_oEventEngine.ReplaceDelegateForEvent "Execute", oDlg
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@MenuClass.AddExecutionHandler
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE AddExecutionHandler>
	':Назначение:
	'	Добавляет обработчик выбора пункта меню.
	':Параметры:
	'	oDlg - [in] "делегат" обработчика выполнения, экземпляр DelegateClass
	':См. также:
	'	MenuClass.SetExecutionHandler, <P/>
	'	<LINK mc-53, Обработчики выполнения />
	':Сигнатура:
	'	Public Sub AddExecutionHandler( oDlg [As DelegateClass] )
	Public Sub AddExecutionHandler(oDlg)
		m_oEventEngine.AddDelegateForEvent "Execute", oDlg
	End Sub

	
	'------------------------------------------------------------------------------
	'@@MenuClass.CheckRightsOnStdOperations
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE CheckRightsOnStdOperations>
	':Назначение:
	'	Устанавливает доступность пунктов меню стандартных операций на основании 
	'	запроса соответствующих прав на заданный объект.
	':Параметры:
	'	sType - [in] наименование типа объекта
	'	sObjectID - [in] идентификатор объекта (строковое представление идентификатора)
	':См. также:
	'	MenuClass.SetMenuItemsAccessRights, MenuClass.SetMenuItemsAccessRightsEx, <P/>
	'	<LINK mc-61, Проверка прав на стандартные операции />
	':Сигнатура:
	'	Public Sub CheckRightsOnStdOperations( sType [As String], sObjectID [As String] )
	Public Sub CheckRightsOnStdOperations(sType, sObjectID)
		Dim oList			' As ObjectArrayListClass - массив объектов XObjectPermission
		Dim oNode			' As IXMLDOMNode - текущий menu-item
		
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
	':Назначение:
	'	Устанавливает доступность пунктов меню на основании анализа наличия заданных прав.
	':Параметры:
	'	aObjectPermission - массив описаний прав на объект (экземпляров XObjectPermission)
	':См. также:
	'	MenuClass.CheckRightsOnStdOperations, MenuClass.SetMenuItemsAccessRightsEx, <P/>
	'	<LINK mc-61, Проверка прав на стандартные операции />
	':Сигнатура:
	'	Public Sub SetMenuItemsAccessRights( aObjectPermission [As XObjectPermission(...)] )
	Public Sub SetMenuItemsAccessRights(aObjectPermission)
		SetMenuItemsAccessRightsEx aObjectPermission, True
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@MenuClass.SetMenuItemsAccessRightsEx
	'<GROUP !!MEMBERTYPE_Methods_MenuClass><TITLE SetMenuItemsAccessRightsEx>
	':Назначение:
	'	Устанавливает доступность пунктов меню на основании анализа наличия заданных 
	'	прав. Позволяет управлять отображением запрещенных пунктов меню (не отображать 
	'	или отображать как заблокированные).
	':Параметры:
	'	aObjectPermission - массив описаний прав на объект (экземпляров XObjectPermission)
	'	bShowDeniedAsDisabled - признак "отображать запрещенные операции как заблокированные" 
	'				(True); если False - то запрещенные операции не отображаются
	':См. также:
	'	MenuClass.CheckRightsOnStdOperations, MenuClass.SetMenuItemsAccessRights, <P/>
	'	<LINK mc-61, Проверка прав на стандартные операции />
	':Сигнатура:
	'	Public Sub SetMenuItemsAccessRightsEx( 
	'		aObjectPermission [As XObjectPermission(...)], 
	'		bShowDeniedAsDisabled [As Boolean] 
	'	)
	Public Sub SetMenuItemsAccessRightsEx(aObjectPermission, bShowDeniedAsDisabled)
		Dim aCheckList		' As Boolean() - результат проверки прав
		Dim oNode			' As IXMLDOMNode - текущий menu-item
		Dim sAttrName		' As String - наименование атрибута
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
	':Назначение:	
	'	Возвращает имя файла XSLT-шаблона, используемого для формирования 
	'	HTML-представления меню.
	':Примечание:	
	'	Свойство только для чтения. <P/>
	'	Исходное наименование файла задается в метаописании меню.
	':Сигнатура:	
	'	Public Property Get MenuXslTemplate [As String]
	Public Property Get MenuXslTemplate
		MenuXslTemplate = m_sXslFilename
	End Property


	'------------------------------------------------------------------------------
	'@@MenuClass.Macros
	'<GROUP !!MEMBERTYPE_Properties_MenuClass><TITLE Macros>
	':Назначение:	Возвращает хеш-таблицы макросов меню.
	':Примечание:	Свойство только для чтения.
	':См. также:	
	'	MenuClass.SetMacrosResolver, MenuClass.AddMacrosResolver, <P/>
	'	<LINK mc-51, Резолверы макросов />
	':Сигнатура:	
	'	Public Property Get Macros [As Scripting.Dictionary]
	Public Property Get Macros
		Set Macros = m_oValues
	End Property

	
	'------------------------------------------------------------------------------
	'@@MenuClass.XmlMenu
	'<GROUP !!MEMBERTYPE_Properties_MenuClass><TITLE XmlMenu>
	':Назначение:	Возвращает XML-представление текущего меню.
	':Примечание:	Свойство только для чтения.
	':См. также:	MenuClass.XmlMenuMD
	':Сигнатура:	Public Property Get XmlMenu [As IXMLDOMElement]
	Public Property Get XmlMenu
		Set XmlMenu = m_oXmlMenu
	End Property

	
	'------------------------------------------------------------------------------
	'@@MenuClass.XmlMenuMD
	'<GROUP !!MEMBERTYPE_Properties_MenuClass><TITLE XmlMenuMD>
	':Назначение:	Возвращает XML-представление метаданных меню.
	':Примечание:	Свойство только для чтения.
	':См. также:	MenuClass.XmlMenu
	':Сигнатура:	Public Property Get XmlMenuMD [As IXMLDOMElement]
	Public Property Get XmlMenuMD
		Set XmlMenuMD = m_oXmlMenuMD
	End Property

	
	'------------------------------------------------------------------------------
	'@@MenuClass.Initialized
	'<GROUP !!MEMBERTYPE_Properties_MenuClass><TITLE Initialized>
	':Назначение:	Возвращает признак инициализированности меню.
	':Примечание:	Свойство только для чтения.
	':См. также:	MenuClass.Init
	':Сигнатура:	Public Property Get Initialized {As Boolean]
	Public Property Get Initialized
		Initialized = m_bInitialized
	End Property
End Class


'===============================================================================
'@@MenuEventArgsClass
'<GROUP !!CLASSES_x-menu><TITLE MenuEventArgsClass>
':Назначение:	Параметры событий "ResolveMacros" и "SetVisibility".
'
'@@!!MEMBERTYPE_Methods_MenuEventArgsClass
'<GROUP MenuEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_MenuEventArgsClass
'<GROUP MenuEventArgsClass><TITLE Свойства>
Class MenuEventArgsClass
	'@@MenuEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_MenuEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@MenuEventArgsClass.Menu
	'<GROUP !!MEMBERTYPE_Properties_MenuEventArgsClass><TITLE Menu>
	':Назначение:	Объект меню, экземпляр MenuClass.
	':Сигнатура:	Public Menu [As MenuClass]
	Public Menu
	
	'@@MenuEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_MenuEventArgsClass><TITLE ReturnValue>
	':Назначение:	Зарезервированно.
	':Сигнатура:	Public ReturnValue [As Variant]
	Public ReturnValue
	
	'@@MenuEventArgsClass.ActiveMenuItems
	'<GROUP !!MEMBERTYPE_Properties_MenuEventArgsClass><TITLE ActiveMenuItems>
	':Назначение:	Коллекция XML-описаний активных пунктов меню.
	':Сигнатура:	Public ActiveMenuItems [As IXMLDOMNodeList]
	Public ActiveMenuItems
	
	'@@MenuEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_MenuEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As MenuEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@MenuExecuteEventArgsClass
'<GROUP !!CLASSES_x-menu><TITLE MenuExecuteEventArgsClass>
':Назначение:	Параметры события "Execute"
'
'@@!!MEMBERTYPE_Methods_MenuExecuteEventArgsClass
'<GROUP MenuExecuteEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_MenuExecuteEventArgsClass
'<GROUP MenuExecuteEventArgsClass><TITLE Свойства>
Class MenuExecuteEventArgsClass
	'@@MenuExecuteEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_MenuExecuteEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@MenuExecuteEventArgsClass.Menu
	'<GROUP !!MEMBERTYPE_Properties_MenuExecuteEventArgsClass><TITLE Menu>
	':Назначение:	Объект меню, которому принадлежит рассматриваемый пункт меню.
	':Сигнатура:	Public Menu [As MenuClass]
	Public Menu
	
	'@@MenuExecuteEventArgsClass.Action
	'<GROUP !!MEMBERTYPE_Properties_MenuExecuteEventArgsClass><TITLE Action>
	':Назначение:	Наименование выбранного действия меню (action).
	':Сигнатура:	Public Action [As String]
	Public Action
	
	'@@MenuExecuteEventArgsClass.SelectedMenuItem
	'<GROUP !!MEMBERTYPE_Properties_MenuExecuteEventArgsClass><TITLE SelectedMenuItem>
	':Назначение:	Выбранный узел menu-item.
	':Сигнатура:	Public SelectedMenuItem	[As IXMLDOMElement]
	Public SelectedMenuItem
	
	'@@MenuExecuteEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_MenuExecuteEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As MenuExecuteEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@SetMenuItemVisibilityEventArgsClass
'<GROUP !!CLASSES_x-menu><TITLE SetMenuItemVisibilityEventArgsClass>
':Назначение:	Параметры события "SetMenuItemVisibility". 
':Примечание:
'	Событие непосредственного отношения к компоненте XMenuClass не имеет.
'	Однако различные компоненты используют это событие (наименование событие 
'	определяется самими компонентами, и для общности оно выбрано одинаковым) в 
'	реализации своих стандартных обработчиков определения доступности пунктов
'	меню, в процессе определения доступности конкретного пункта меню.<P/>
'	Таким образом обеспечивается возможность подключения прикладной логики, 
'	определяющей доступность конкретного пункта меню конкретной компоненты, не
'	требующая переопределения стандартных обработчиков доступности.
':Пример:	XListClass.MenuVisibilityHandler
'
'@@!!MEMBERTYPE_Methods_SetMenuItemVisibilityEventArgsClass
'<GROUP SetMenuItemVisibilityEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass
'<GROUP SetMenuItemVisibilityEventArgsClass><TITLE Свойства>
Class SetMenuItemVisibilityEventArgsClass
	'@@SetMenuItemVisibilityEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@SetMenuItemVisibilityEventArgsClass.Menu
	'<GROUP !!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass><TITLE Menu>
	':Назначение:	Объект меню, которому принадлежит рассматриваемый пункт меню.
	':Сигнатура:	Public Menu [As MenuClass]
	Public Menu
	
	'@@SetMenuItemVisibilityEventArgsClass.Action
	'<GROUP !!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass><TITLE Action>
	':Назначение:	Наименование выбранного действия меню (action).
	':Сигнатура:	Public Action [As String]
	Public Action
	
	'@@SetMenuItemVisibilityEventArgsClass.MenuItemNode
	'<GROUP !!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass><TITLE MenuItemNode>
	':Назначение:	XML-узел с данными элемента <B>i:menu-item</B>.
	':Сигнатура:	Public MenuItemNode [As XMLDOMElement]
	Public MenuItemNode
	
	'@@SetMenuItemVisibilityEventArgsClass.Hidden
	'<GROUP !!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass><TITLE Hidden>
	':Назначение:	Признак, указывающий что пункт меню должен быть скрыт. 
	':Сигнатура:	Public Hidden [As Boolean]
	Public Hidden
	
	'@@SetMenuItemVisibilityEventArgsClass.Disabled
	'<GROUP !!MEMBERTYPE_Properties_SetMenuItemVisibilityEventArgsClass><TITLE Disabled>
	':Назначение:	Признак, задающий блокировку пункта меню. 
	':Сигнатура:	Public Disabled [As Boolean]
	Public Disabled
	
	'@@SetMenuItemVisibilityEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SetMenuItemVisibilityEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As SetMenuItemVisibilityEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class
