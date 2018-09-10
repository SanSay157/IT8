'===============================================================================
'@@!!FILE_x-pool
'<GROUP !!SYMREF_VBS>
'<TITLE x-pool - Обслуживание пула объектов на стороне клиента>
':Назначение:	Обслуживание пула объектов на стороне клиента.
'===============================================================================
'@@!!CLASSES_x-pool
'<GROUP !!FILE_x-pool><TITLE Классы>
Option Explicit
 
Const ATTR_NOTNULL = "notnull"		' атрибут xml-свойства - признак обязательности, перекрывает атрибут meybenull метасвойства


'==============================================================================
' Состояние пула
Class XObjectPoolStateClass
	Public XmlObjectPool		' As IXMLDOMElement - корневой элемент xml-пула объектов
	Public TransactionID		' As String - идентификатор транзакции
End Class


'==============================================================================
' Внутренний класс, служащий для вызова вычисляемого выражения в окне, отличном от того, 
' в котором был создан экземпляр XObjectPoolClass
Class Internal_EvaluatorClass
	Private m_oPool
	
	Public Sub Init(oPool)
		Set m_oPool = oPool
	End Sub
	
	Private Function pool()
		Set pool = m_oPool
	End Function
	
	Public Function Evaluate(sStatement, oXmlObject)
		Evaluate = Eval(sStatement)
	End Function
	
	Public Function GetPropertyValue(oXmlObjectX, sOPath)
		GetPropertyValue = m_oPool.GetPropertyValue(oXmlObjectX, sOPath)
	End Function
End Class


'==============================================================================
Function X_EvaluateInWindow (oPool, sStatement, oXmlObject)
	With New Internal_EvaluatorClass
		.Init oPool
		X_EvaluateInWindow = .Evaluate(sStatement, oXmlObject)
	End With
End Function


'===============================================================================
'@@XObjectPoolClass
'<GROUP !!CLASSES_x-pool><TITLE XObjectPoolClass>
':Назначение:	Класс, представляющий <B>пул объектов</B>.
':Описание:		<B>Пул объектов</B> - компонент, обеспечивающий возможности 
'				выполнения операций над XML-объектами на стороне клиента.
':См. также:	<LINK oe-2, Пул объектов - общее описание/>
'
'@@!!MEMBERTYPE_Methods_XObjectPoolClass
'<GROUP XObjectPoolClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_XObjectPoolClass
'<GROUP XObjectPoolClass><TITLE Свойства>
Class XObjectPoolClass
	Private m_oXmlObjectPool			' As IXMLDOMElement - xml-пул, элемент "x-o"
	Private m_oPoolTransactionLog		' As StackClass - transaction log, элемент стека - экземпляр XObjectPoolStateClass
	Private m_sTransactionID			' As String - идентификатор текущей транзакции
	Private m_oBackStack				' As StackClass - "параллельный" стек пулов. Элемент стека - IXMLDOMElement, копия m_oXmlObjectPool
	Private m_oActiveEditorStack		' As StackClass, элемент стека наименование глобальной переменной с экземпляром ObjectEditorClass
	Private m_oExecuteStatementRegExp	' As RegExp - регулярное выражение для вычисления
	Private m_oXmlPendingActions		' As IXMLDOMElement - xml-узел x-pending-actions, подчиненные корневому узлу x-o, для хранения записей об отложенных действиях
	Private m_bHasPendingActions		' As Boolean - логический признак для оптимизации наличия отложенных действий
										'	Используется в applyPendingActionsForObject
	
	'---------------------------------------------------------------------------
	' Конструктор - внутренний метод инициализации нового экземпляра класса
	Private Sub Class_Initialize
		Set m_oXmlObjectPool = XService.XmlGetDocument
		Set m_oXmlObjectPool = m_oXmlObjectPool.AppendChild(m_oXmlObjectPool.CreateElement("x-o"))
		Set m_oXmlPendingActions = m_oXmlObjectPool.AppendChild( m_oXmlObjectPool.ownerDocument.CreateElement("x-pending-actions") )
		m_sTransactionID = CreateGuid
		Set m_oActiveEditorStack	= New StackClass
		Set m_oPoolTransactionLog	= New StackClass
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.Xml
	'<GROUP !!MEMBERTYPE_Properties_XObjectPoolClass><TITLE Xml>
	':Назначение:	Представляет XML с данными всего пула объектов.
	':Примечание:	Корневой XML-элемент данных пула - элемент <B>x-o</B>.
	':Сигнатура:	Public Property Get Xml [As IXMLDOMElement]
	Public Property Get Xml
		Set Xml = m_oXmlObjectPool
	End Property


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.RegisterEditor
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE RegisterEditor>
	':Назначение:	Регистрирует активный редактор. Этому редактору будут 
	'				направляться все события пула.
	':Параметры:	oObjectEditor - [in] целевой редактор, экземпляр ObjectEditorClass
	':См. также:	XObjectPoolClass.UnRegisterEditor
	':Сигнатура:	Public Sub RegisterEditor( oObjectEditor [As ObjectEditorClass] )
	Public Sub RegisterEditor(oObjectEditor)
		If Not IsNothing(oObjectEditor) Then
			m_oActiveEditorStack.Push oObjectEditor
		Else
			m_oActiveEditorStack.Push Nothing
		End If
	End Sub
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.UnRegisterEditor
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE UnRegisterEditor>
	':Назначение:	Удаляет регистрацию текущего редактора.
	':См. также:	XObjectPoolClass.RegisterEditor
	':Сигнатура:	Public Sub UnRegisterEditor()
	Public Sub UnRegisterEditor()
		m_oActiveEditorStack.Pop
	End Sub
	
	
	'---------------------------------------------------------------------------
	':Назначение:	Возвращает экземпляр активного редактора, или Nothing, если 
	'				редакторон еще не был зарегистрирован.
	':Примечания:	Свойство только для чтения.
	Private Property Get ObjectEditor
		If IsObject(m_oActiveEditorStack.Top) Then
			Set ObjectEditor = m_oActiveEditorStack.Top
		Else
			Set ObjectEditor = Nothing
		End If
	End Property
	
	
	'---------------------------------------------------------------------------
	':Назначение:	Возвращает объект окна (IHtmlWindow) активного редактора, 
	'				если оно отличается от окна, в котором был создан текущий объект.
	':Результат:	Возвращает объект окна (IHtmlWindow).
	Private Function GetEditorAnotherWindow
		Set GetEditorAnotherWindow = Nothing
		If Not ObjectEditor Is Nothing Then
			If Not ObjectEditor.GetWindow Is window Then
				Set GetEditorAnotherWindow = ObjectEditor.GetWindow 
			End If
		End If
	End Function
	
	
	'---------------------------------------------------------------------------
	':Назначение:	Генерирует заданное событие активному редактору.
	':Параметры:	sEventName - [in] наименование события
	'				oEventArgs - [in] экземпляр класса параметров события (или Nothing)
	Private Sub FireEventInEditor( sEventName, oEventArgs )
		Dim oObjectEditor 
		Set oObjectEditor = ObjectEditor
		If Not oObjectEditor Is Nothing Then
			oObjectEditor.Internal_FireEvent sEventName, oEventArgs
		End If
	End Sub

	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.TransactionID
	'<GROUP !!MEMBERTYPE_Properties_XObjectPoolClass><TITLE TransactionID>
	':Назначение:	Возвращает идентификатор текущей транзакции.
	':Примечание:	Свойство только для чтения.
	':Сигнатура:	Public Property Get TransactionID [As String]
	Public Property Get TransactionID
		TransactionID = m_sTransactionID
	End Property


	'---------------------------------------------------------------------------
	':Назначение:	Возвращает "параллельный" стек пулов.
	Private Property Get BackStack
		If IsEmpty( m_oBackStack) Then
			Set m_oBackStack = new StackClass
		End If
		Set BackStack = m_oBackStack
	End Property


	'---------------------------------------------------------------------------
	':Назначение:	Инициализирует поле m_oXmlPendingActions.
	Private Sub initXmlPendingActionsElement()
		Set m_oXmlPendingActions = m_oXmlObjectPool.selectSingleNode("x-pending-actions")
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.BeginTransaction
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE BeginTransaction>
	':Назначение:	Начинает новую логическую транзакцию.
	':Параметры:	
	'	bAggregation - [in] признак агрегации; здесь:
	'		* True - новая транзакция включается в текущую логическую транзакцию, 
	'		* False - начинается вложенная автономная логическая транзакция.
	':Примечание:
	'	<B>Внимание!</B> Все ссылки, полученные до вызова BeginTransaction, в 
	'	процессе транзации становятся <B>некорректными</B>. При этом, после вызова 
	'	XObjectPoolClass.CommitTransaction ссылки остаются <B>некорректынми</B>, 
	'	а в случае вызова XObjectPoolClass.RollbackTransaction - <B>корректными</B>.
	':См. также:	
	'	XObjectPoolClass.CommitTransaction, XObjectPoolClass.RollbackTransaction,<P/>
	'	<LINK oe-2-3-2, Транзакционная модель/>
	':Сигнатура:	
	'	Public Sub BeginTransaction( bAggregation [As Boolean] )
	Public Sub BeginTransaction(bAggregation)
		Dim oPoolState		' As XObjectPoolStateClass - текущее состояние пула

		' положим текущее состояние пула в стек
		Set oPoolState = New XObjectPoolStateClass
		oPoolState.TransactionID = m_sTransactionID
		Set oPoolState.XmlObjectPool = m_oXmlObjectPool
		m_oPoolTransactionLog.Push oPoolState
		Set m_oXmlObjectPool = m_oXmlObjectPool.cloneNode(true)
		initXmlPendingActionsElement
		If Not bAggregation Then
			m_sTransactionID = CreateGuid
		End If
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.CommitTransaction
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE CommitTransaction>
	':Назначение:	Завершает текущую логическую транзакцию.
	':Примечание:
	'	<B>Внимание!</B> Все ссылки, полученные до вызова XObjectPoolClass.BeginTransaction, 
	'	в процессе транзации и после вызова XObjectPoolClass.CommitTransaction 
	'	становятся <B>некорректынми</B>!
	':См. также:	
	'	XObjectPoolClass.BeginTransaction, XObjectPoolClass.RollbackTransaction,<P/>
	'	<LINK oe-2-3-2, Транзакционная модель/>
	':Сигнатура:	
	'	Public Sub CommitTransaction()
	Public Sub CommitTransaction
		Dim oPoolState		' As XObjectPoolStateClass - текущее состояние пула

		If m_oPoolTransactionLog.Length>0 Then
			' достанем предыдущее состояние пула
			Set oPoolState = m_oPoolTransactionLog.Pop
			If m_sTransactionID = oPoolState.TransactionID Then
			Else
				' TODO:
				' если текущая транзакция - автономная (в том, числе корневая), то
				' все объекты из текущего пуле, включенные в текущую транзакцию, надо удалить из всех пулов в стеке
			End If
		Else
			' Для предотвращения маскирования ошибок из-за несоответствия вызовом BeginTransaction и Commit/Rollback ругаемся
			Err.Raise -1, "XObjectPoolClass::CommitTransaction", "Вызов CommitTransaction без соответствующего BeginTransaction"
		End If
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.RollbackTransaction
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE RollbackTransaction>
	':Назначение:	
	'	Откатывает текущую логическую транзакцию, возвращая данные пула
	'	к состоянию, предшествовавшему началу транзакции.
	':Примечание:
	'	<B>Внимание!</B> Все ссылки, полученные до вызова XObjectPoolClass.BeginTransaction, 
	'	после вызова XObjectPoolClass.RollbackTransaction остаются <B>корректынми</B>!
	':См. также:	
	'	XObjectPoolClass.BeginTransaction, XObjectPoolClass.CommitTransaction,<P/>
	'	<LINK oe-2-3-2, Транзакционная модель/>
	':Сигнатура:	
	'	Public Sub RollbackTransaction()
	Public Sub RollbackTransaction
		Dim oPoolState		' As XObjectPoolStateClass - текущее состояние пула

		If m_oPoolTransactionLog.Length>0 Then
			' достанем и восстановим предыдущее состояние пула
			Set oPoolState = m_oPoolTransactionLog.Pop
			Set m_oXmlObjectPool = oPoolState.XmlObjectPool
			initXmlPendingActionsElement
			m_sTransactionID = oPoolState.TransactionID
		Else
			' Для предотвращения маскирования ошибок из-за несоответствия вызовом BeginTransaction и Commit/Rollback ругаемся
			Err.Raise -1, "XObjectPoolClass::CommitTransaction", "Вызов RollbackTransaction без соответствующего BeginTransaction"
		End If
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetChanges
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetChanges>
	':Назначение:	
	'	Возвращает коллекцию с XML-данными новых, удаленных и измененных объектов.
	':Результат:
	'	Коллекция XML-данных, как экземпляр IXMLDOMNodeList.
	':Примечание:
	'	В коллекцию включаются данные объектов, которые:
	'		* редактировались в текущей транзакции;
	'		* являются новыми (XML-данные объекта помечены атрибутом <B>new</B>);
	'		* являются удаленными (XML-данные объекта помечены атрибутом <B>delete</B>);
	'		* изменялись (атрибут <B>dirty</B> у свойств объекта).
	':Сигнатура:
	'	Public Function GetChanges [As IXMLDOMNodeList]
	Public Function GetChanges
		Set GetChanges = m_oXmlObjectPool.selectNodes("*[@transaction-id='" & m_sTransactionID & "' and (@delete or @new or *[@dirty])]")
	End Function


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.Backup
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE Backup>
	':Назначение:	Сохраняет текущее состояние пула во внутренний стек.
	':См. также:	XObjectPoolClass.Undo, <LINK oe-2-3-2, Транзакционная модель/>
	':Сигнатура:	Public Sub Backup()
	Public Sub Backup
		BackStack.Push m_oXmlObjectPool.cloneNode( True ) 
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.Undo
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE Undo>
	':Назначение:	Восстанавливает состояние пула, сохраненное ранее во внутреннем
	'				стеке методом XObjectPoolClass.Backup.
	':См. также:	XObjectPoolClass.Backup, <LINK oe-2-3-2, Транзакционная модель/>
	':Сигнатура:	Public Sub Undo()
	Public Sub Undo
		Set m_oXmlObjectPool = BackStack.Pop
		initXmlPendingActionsElement
	End Sub
	

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.Clear
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE Clear>
	':Назначение:	Удаляет все объекты из пула.
	':Сигнатура:	Public Sub Clear()
	Public Sub Clear
		m_oXmlObjectPool.selectNodes("*[local-name()!='x-pending-actions']").removeAll
	End Sub


	'===========================================================================
	' ЗАГРУЗКА ОБЪЕКТОВ
		
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.LoadXmlProperty
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE LoadXmlProperty>
	':Назначение:	
	'	Загружает данные непрогруженного свойство XML-объекта с сервера.
	':Параметры:
	'	oXmlObject	- [in] объект (IXMLDOMElement корневого узла объекта); может 
	'					быть Nothing, если vProp - XML-свойство (IXMLDOMElement)
	'	vProp		- [in] свойство объекта (XmlDOMElement), или строка с именем 
	'					свойства
	':Результат:
	'	Загруженные XML-данные свойства, как экземпляр IXMLDOMElement. Если свойство 
	'	не найдено, возвращается Nothing.
	':См. также:
	'	XObjectPoolClass.GetXmlProperty, XObjectPoolClass.GetPropertyValue,<P/>
	'	<LINK oe-2-3-1, Обеспечение унифицированного доступа к XML-объектам/>
	':Сигнатура:	
	'	Public Function LoadXmlProperty( 
	'		ByVal oXmlObject [As IXMLDOMElement], vProp [As Variant] 
	'	) [As IXMLDOMElement]
	Public Function LoadXmlProperty( ByVal oXmlObject, vProp )
		Dim sObjectType				' As String - Тип объекта
		Dim sObjectID				' As String - Идентификатор объекта
		Dim oXmlObjectFromPool		' As IXMLDOMElement - xml-объект из пула
		Dim sPropertyName			' As String - наименование свойства
		Dim oXmlProperty			' As IXMLDOMElement - прогружаемое свойство
		Dim oXmlPropertyFromServer	' As IXMLDOMElement - свойство, пришедшее с сервера
		Dim oXmlNode				' As IXMLDOMNode
		Dim aErr					' As Array - массив полей объекта Err
		
		Set LoadXmlProperty = Nothing
		' Получим имя свойство
		If vbString = VarType( vProp) Then
			sPropertyName = vProp
		ElseIf 0 = StrComp( TypeName(vProp), "IXMLDOMElement", vbTextCompare) Then
			sPropertyName = vProp.nodeName
			Set oXmlObject = vProp.parentNode
		Else
			Err.Raise -1, "XObjectPoolClass::LoadXmlProperty", "Параметр vProp неподдерживаемого типа: " & TypeName(vPropName) & ". Должен быть String или IXMLDOMElement"
		End If
		
		' Получим тип и ID обрабатываемого объекта
		sObjectID	= oXmlObject.getAttribute("oid")
		sObjectType = oXmlObject.tagName
		' укажем в качестве прелоада заданное св-во: 
		' если объект отсутствует в пуле, то с сервера он придет сразу с прогруженным требуемым свойством
		Set oXmlObjectFromPool = GetXmlObject(sObjectType, sObjectID, sPropertyName)
		If oXmlObjectFromPool Is Nothing Then Exit Function
		Set oXmlProperty = oXmlObjectFromPool.selectSingleNode(sPropertyName) 
		If oXmlProperty Is Nothing Then Exit Function
		Set LoadXmlProperty = oXmlProperty
		
		If ("0" = oXmlProperty.getAttribute("loaded")) Then
			' Получим свойство с сервера
			
			If Not GetEditorAnotherWindow Is Nothing Then _
				On Error Resume Next
			Set oXmlPropertyFromServer = X_LoadObjectPropertyFromServer(sObjectType, sObjectID, sPropertyName)
			If Not GetEditorAnotherWindow Is Nothing Then 
				' если текущее окно отличается от окна, в котором был создан активный редактор..
				aErr = Array(Err.number, Err.Source, Err.Description)
				On Error GoTo 0
				If X_WasErrorOccured Then
					' переложим описание серверной ошибки в окно активного редактора
					With X_GetLastError
						GetEditorAnotherWindow.X_SetLastServerError .LastServerError, .ErrNumber, .ErrSource, .ErrDescription
					End With
					' и очистим ошибку в текущем окне
					X_ClearLastServerError
				End If	
				If aErr(0)<>0 Then
					Err.Raise aErr(0), aErr(1), aErr(2)
				End If
			End If
			If oXmlPropertyFromServer Is Nothing Then Exit Function
			
			' на всякий случай очистим свойство..
			oXmlProperty.selectNodes("*|@loaded").removeAll
			' если прогружаемое св-во - объектное, то перенесем все объекты из него в пул, 
			' а в самом свойстве оставим заглушки, иначе, если текстовое или бинарное, то просто перенесем содержимое
			If X_GetPropertyMD(oXmlProperty).getAttribute("vt") = "object" Then
				' По всем объектам в свойстве
				InsertXmlObjectsFromPropIntoPool oXmlPropertyFromServer
				' теперь в oXmlPropertyFromServer остались одни заглушки - перенесем их в прогружаемое свойство
				For Each oXmlNode In oXmlPropertyFromServer.selectNodes("*[@oid]")
					' и перенесем заглушку в прогружаемое свойство объекта в пуле
					oXmlProperty.appendChild oXmlNode
				Next
				applyPendingActions oXmlObjectFromPool.tagName, oXmlObjectFromPool.getAttribute("oid"), oXmlProperty
			Else
				' необъектное св-во, это может быть только текстовое или бинарное 
				' (для других команда прогрузки св-ва вызовет исключение)
				oXmlProperty.text = oXmlPropertyFromServer.text
			End If
		End If		
	End Function
	
		
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetXmlProperty
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetXmlProperty>
	':Назначение:	Получает узел свойства, заданного OPath-путем.
	':Параметры:	
	'	oXmlObject	- [in] объект (IXMLDOMElement корневого узла объекта)
	'	sOPath		- [in] строка с цепочкой свойств, в форме перечня имен объектных 
	'					свойств, разделенными символом "."
	':Результат:
	'	XML-данные свойства, как экземпляр IXMLDOMElement. Если свойства, заданного 
	'	в цепочке, нет, то возвращается Nothing.
	':См. также:
	'	XObjectPoolClass.LoadXmlProperty, XObjectPoolClass.GetPropertyValue, 
	'	XObjectPoolClass.GetXmlObject,<P/>
	'	<LINK oe-2-3-1, Обеспечение унифицированного доступа к XML-объектам/>
	':Сигнатура:
	'	Public Function GetXmlProperty( 
	'		ByVal oXmlObject [As IXMLDOMElement], sOPath [As String] 
	'	) [As IXMLDOMElement]
	Public Function GetXmlProperty(ByVal oXmlObject, sOPath)
		Dim aProps		' As Array - Массив имен свойств в пути
		Dim nUpper		' As Long - Максимальный индекс в массиве имен свойств
		Dim oProp		' As IXMLDOMElement - текущее свойство cвойство 
		Dim sPreload	' As String - целочка свойств для прогрузки при получении объекта с сервера
		Dim i, j
		
		Set GetXmlProperty = Nothing
		aProps = Split( sOPath, ".")
		nUpper = UBound( aProps)
		For i = 0 to nUpper
			' Проверяем на имена системных свойств
			Select Case aProps(i)
				Case "ObjectID"
					Set GetXmlProperty = oXmlObject.selectSingleNode("@oid")
					GetXmlProperty.dataType = "string"
					Exit Function
				Case "ts"
					Set GetXmlProperty = oXmlObject.selectSingleNode("@ts")
					If Not Nothing Is GetXmlProperty Then GetXmlProperty.dataType = "string"
					Exit Function
			End Select
			' удостоверяемся, что объект загружен в пуле
			sPreload = Null
			For j = i To nUpper
				If Not IsNull(sPreload) Then sPreload = sPreload & "."
				sPreload = sPreload & aProps(j)
			Next
			' если объекта нет в пуле, то будет послан запрос команде GetObject с оставшейся частью пути объектных св-в
			Set oXmlObject = GetXmlObjectByXmlElement(oXmlObject, sPreload)
			If oXmlObject Is Nothing Then Exit Function
			' Получаем значение свойства
			Set oProp = LoadXmlProperty( oXmlObject, aProps(i) )
			If i = nUpper Then
				' Дошли до значения
				Set GetXmlProperty = oProp
			Else
				' если свойства нет, вернем Nothing
				If oProp Is Nothing Then Exit Function
				Set oXmlObject = oProp.firstChild
				' Если у нас есть значение, переходим к нему, но не прогружаем (сделаем это при следующей итерации, если потребуется)
				If oXmlObject Is Nothing Then 
					' Разбор закончили на неустановленном свойстве
					Exit Function
				End If
			End If
		Next
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetPropertyValue
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetPropertyValue>
	':Назначение:	
	'	Получает значение скалярного необъектного свойства, заданного OPath-путем.
	':Параметры:	
	'	oXmlObject	- [in] объект (IXMLDOMElement корневого узла объекта)
	'	sOPath		- [in] строка с цепочкой свойств, в форме перечня имен объектных 
	'					свойств, разделенными символом ".", завершающаяся именем 
	'					скалярного необъектного свойства
	':Результат:
	'	Типизированное значение скалярного необъектного свойства или Null, если 
	'	значение свойства не задано (свойство "пустое").<P/>
	'	В том случае, если sOPath заканчивается именем объектного свойства (надо 
	'	понимать, что это некорректное использование), метод возвращает Null для 
	'	неустановленных ("пустых") свойств, и строку "[object]" для установленных.
	':См. также:
	'	XObjectPoolClass.LoadXmlProperty, XObjectPoolClass.GetXmlProperty, 
	'	XObjectPoolClass.GetXmlObject,<P/>
	'	<LINK oe-2-3-1, Обеспечение унифицированного доступа к XML-объектам/>
	':Сигнатура:
	'	Public Function GetPropertyValue( 
	'		oXmlObjectX [As IXMLDOMElement], sOPath [As String]
	'	) [As Variant]
	Public Function GetPropertyValue(oXmlObjectX, sOPath)
		Dim oProp	' Свойство (XMLDOMElement)
		GetPropertyValue = Null
		Set oProp = GetXmlProperty(oXmlObjectX, sOPath)
		If oProp Is Nothing Then Exit Function
		If Not Nothing Is oProp Then
			If IsNull( oProp.dataType) Then
				' От нас попросили объектное свойство
				If Not oProp.firstChild Is Nothing Then
					GetPropertyValue = "[object]"
				Else
					' В случае неустановленного объектного свойства вернем Null
					Exit Function
				End If
			Else
				' От нас попросили значение скалярного свойства
				GetPropertyValue = oProp.nodeTypedValue
			End If
		End If
	End Function
	
	
	'---------------------------------------------------------------------------
	':Назначение:	Возвращает ссылку на свой собственный экземпляр.
	':Примечание:	Служит для адресации к пулу из в ExecuteStatement (см. инц. 149911)
	'				НЕ ПЕРЕИМЕНОВЫВАТЬ ДАННЫЙ МЕТОД!!!
	Private Function pool()
		Set pool = Me
	End Function
	

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.ExecuteStatement
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE ExecuteStatement>
	':Назначение:	
	'	Выполняет выражение VBScript, с предврительной подстановкой в выражение 
	'	ссылки на значения свойств объекта (см. Замечания).
	':Параметры:
	'	oXmlObject - [in] объект (XMLDOMElement корневого узла объекта)
	'	sStmt - [in] строка с вычисляемым выражением (см. Замечания)
	':Результат:
	'	Возвращает вычесленное значение выражения.
	':Примечания:
	'	Строка с выражением VBScript может включать подстановки вида 
	'	<B>item.<I>PropName1</I>{<I>.PropNameN</I>}</B>, где <B>item</B> - указание
	'	на подстановку, а <B>PropName1</B>, <B>PropNameN</B> - цепочка наименований 
	'	свойств объекта.<P/>
	'	Перед выполнением выражения VBScript метод заменяет все подстановки на 
	'	значения соответствующих свойств, полученных по цепочке наименований, заданных
	'	в подстановке.
	':См. также:
	'	XObjectPoolClass.GetPropertyValue,<P/>
	'	<LINK oe-2-3-1, Обеспечение унифицированного доступа к XML-объектам/>
	':Сигнатура:
	'	Public Function ExecuteStatement( 
	'		oXmlObject [As IXMLDOMElement], ByVal sStmt [As String]
	'	) [As Variant]
	Public Function ExecuteStatement( oXmlObject, ByVal sStmt)	' ВНИМАНИЕ! ПАРАМЕТРЫ - НЕ ПЕРЕИМЕНОВЫВАТЬ!
		' Будем заменять подстроки вида [что угодно, кроме букв, цифр и знаков _]item.[произвольная последовательность кроме букв, цифр и знаков _ . ]
		const SEARCH_PATTERN = "(\W|^)item\.(((\.|\w)+))"
		' на подстроки вида [что угодно, кроме букв, цифр и знаков _]X_GetPropValue(oXmlObject,"[произвольная последовательность кроме букв, цифр и знаков _ . ]")
		const REPLACE_PATTERN = "$1GetPropertyValue(oXmlObject, ""$3"")"
		Dim sPrepared	' Выражение, подготовленное к вычислению...
		
		' Причешем входные данные
		ExecuteStatement = Null
		sStmt = Replace( XService.LineUpText( sStmt), "item()", "oXmlObject")
		if 0 = Len( sStmt) then exit function

		' Инициализируем парсер регулярного выражения (по необходимости...)
		if not IsObject(m_oExecuteStatementRegExp) then
			' Создаём объект
			set m_oExecuteStatementRegExp = new RegExp
			' Будем искать все вхождения
			m_oExecuteStatementRegExp.Global = true
			' Вне зависимости от регистра
			m_oExecuteStatementRegExp.IgnoreCase = true
			' И перевода строк
			m_oExecuteStatementRegExp.Multiline=true
			' Искать будем подстроки вида [что угодно, кроме букв, цифр и знаков _]item.[произвольная последовательность кроме букв, цифр и знаков _ . ] 
			m_oExecuteStatementRegExp.Pattern = SEARCH_PATTERN 	
		end if
		
		' Выполняем парсинг и макроподстановку
		sPrepared = m_oExecuteStatementRegExp.Replace( sStmt , REPLACE_PATTERN)
		' Выполняем выражение... 
		If Not GetEditorAnotherWindow Is Nothing Then
			ExecuteStatement = GetEditorAnotherWindow.X_EvaluateInWindow(Me, sPrepared, oXmlObject)
		Else
			ExecuteStatement = Eval( sPrepared)
		End If
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetXmlObjectsByOPath
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetXmlObjectsByOPath>
	':Назначение:	
	'	Возвращает коллекцию объектов-значений объектного свойства, заданного 
	'	OPath-путем.
	':Параметры:	
	'	oXmlObjectX	- [in] объект (IXMLDOMElement корневого узла объекта)
	'	sOPath		- [in] строка с цепочкой свойств, в форме перечня имен объектных 
	'					свойств, разделенными символом ".", завершающаяся именем 
	'					объектного свойства
	':Результат:
	'	Данные объектного свойства, как коллекция IXMLDOMNodeList. Если свойство 
	'	не найдено или пустое, метод возвращает Nothing.
	':См. также:
	'	XObjectPoolClass.GetXmlObjectByOPath, XObjectPoolClass.GetPropertyValue, 
	'	XObjectPoolClass.GetXmlObject,<P/>
	'	<LINK oe-2-3-1, Обеспечение унифицированного доступа к XML-объектам/>
	':Сигнатура: 
	'	Public Function GetXmlObjectsByOPath(
	'		oXmlObjectX [As IXMLDOMElement], sOPath [As String]
	'	) [As IXMLDOMNodeList]
	Public Function GetXmlObjectsByOPath(oXmlObjectX, sOPath)
		Dim oProp	' Свойство (XMLDOMElement)
		
		Set GetXmlObjectsByOPath = Nothing
		Set oProp = GetXmlProperty(oXmlObjectX, sOPath)
		If Not oProp Is Nothing Then
			If oProp.hasChildNodes Then
				Set GetXmlObjectsByOPath = GetXmlObjectsByXmlNodeList( oProp.childNodes, Null )
			End If
		End If
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetXmlObjectByOPath
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetXmlObjectByOPath>
	':Назначение:	
	'	Возвращает объект-значение объектного свойства, заданного OPath-путем.
	':Параметры:	
	'	oXmlObject	- [in] объект (IXMLDOMElement корневого узла объекта)
	'	sOPath		- [in] строка с цепочкой свойств, в форме перечня имен объектных 
	'					свойств, разделенными символом ".", завершающаяся именем 
	'					объектного свойства
	':Результат:
	'	Данные объектного свойства, как экземпляр IXMLDOMElement. Если свойство 
	'	не найдено или пустое, метод возвращает Nothing. Если свойство - массивное, 
	'	то метод возвращает данные первого элемента.
	':См. также:
	'	XObjectPoolClass.GetXmlObjectsByOPath, XObjectPoolClass.GetPropertyValue, 
	'	XObjectPoolClass.GetXmlObject,<P/>
	'	<LINK oe-2-3-1, Обеспечение унифицированного доступа к XML-объектам/>
	':Сигнатура: 
	'	Public Function GetXmlObjectByOPath( 
	'		oXmlObject [As IXMLDOMElement], sOPath [As String] 
	'	) [As IXMLDOMElement]
	Public Function GetXmlObjectByOPath(oXmlObject, sOPath)
		Dim oNodeList		' IXMLDOMNodeList
		
		Set GetXmlObjectByOPath = Nothing
		Set oNodeList = GetXmlObjectsByOPath(oXmlObject, sOPath)
		If Not oNodeList Is Nothing Then
			If oNodeList.length > 0 Then
				Set GetXmlObjectByOPath = oNodeList.item(0)
			End If
		End If
	End Function
	

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.FindXmlObject
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE FindXmlObject>
	':Назначение:	
	'	"Поиск" в пуле данных объекта, заданного типом и идентификатором.
	':Параметры:
	'	sObjectType - [in] тип объекта
	'	sObjectID   - [in] идентификатор объекта
	':Результат:
	'	Возвращает ссылку в пуле на XML-данные объекта с заданными типом и 
	'	идентификатором. Nothing - если объект в пуле отсутствует.
	':См. также:
	'	XObjectPoolClass.FindObjectByXmlElement
	':Сигнатура:
	'	Public Function FindXmlObject( 
	'		sObjectType [As String], sObjectID [As String] 
	'	) [As IXMLDOMElement]
	Public Function FindXmlObject(sObjectType, sObjectID)
		Set FindXmlObject = m_oXmlObjectPool.selectSingleNode(sObjectType & "[@oid='" & sObjectID & "']")
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.FindObjectByXmlElement
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE FindObjectByXmlElement>
	':Назначение:	
	'	"Поиск" в пуле данных объекта, заданного ссылкой на XML-данные объекта.
	':Параметры:
	'	oXmlObjectRef - [in] XML-данные объект или "заглушка" объекта. 
	':Результат:
	'	Возвращает ссылку в пуле на XML-данные объекта. Nothing - если искомый 
	'	объект в пуле отсутствует.
	':См. также:
	'	XObjectPoolClass.FindXmlObject
	':Сигнатура:
	'	Public Function FindObjectByXmlElement( 
	'		oXmlObjectRef [As IXMLDOMElement]
	'	) [As IXMLDOMElement]
	Public Function FindObjectByXmlElement(oXmlObjectRef)
		Set FindObjectByXmlElement = FindXmlObject(oXmlObjectRef.tagName, oXmlObjectRef.getAttribute("oid") )
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@XObjectPoolClass.GetXmlObject
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetXmlObject>
	':Назначение:	
	'	Возвращает объект из пула. Если объект в пуле отсутствует, то метод 
	'	загружает данные объекта в пул, запрашивая их с сервера.
	':Параметры:	
	'	sObjectType - [in] наименвоание типа объекта
	'	sObjectID	- [in] идентификатор объекта
	'	sPreloads	- [in] список прогружаемых свойств объекта, подгружаемых 
	'					на сервере, в случае если данные объекта загружаются
	':Результат:
	'	XML-данные объекта, как экземпляр IXMLDOMElement.
	':См. также:	
	'	XObjectPoolClass.GetXmlProperty,<P/>
	'	<LINK oe-2-3-1, Обеспечение унифицированного доступа к XML-объектам/>
	':Сигнатура:
	'	Public Function GetXmlObject(
	'		sObjectType [As String],
	'		sObjectID [As String],
	'		sPreloads [As String]
	'	) [As IXMLDOMElement]
	Public Function GetXmlObject(sObjectType, sObjectID, sPreloads)
		Dim oXmlObject		' As IXMLDOMElement - Загруженный Xml - объект
		Dim aErr			' As Array - массив полей объекта Err
		
		Set GetXmlObject = Nothing
		' проверим наличие объекта в пуле объектов
		If HasValue(sObjectID) Then
			Set oXmlObject = m_oXmlObjectPool.selectSingleNode(sObjectType & "[@oid='" & sObjectID & "']")
		Else
			Set oXmlObject = Nothing
		End If	
		If oXmlObject is Nothing Then
			' Не нашли - возьмём с сервера...
			' Получаю объект с сервера
			
			If Not GetEditorAnotherWindow Is Nothing Then _
				On Error Resume Next
			Set oXmlObject = X_GetObjectFromServer( sObjectType, sObjectID, sPreloads)
			If Not GetEditorAnotherWindow Is Nothing Then 
				' если текущее окно отличается от окна, в котором был создан активный редактор..
				aErr = Array(Err.number, Err.Source, Err.Description)
				On Error GoTo 0
				If X_WasErrorOccured Then
					' переложим описание серверной ошибки в окно активного редактора
					With X_GetLastError
						GetEditorAnotherWindow.X_SetLastServerError .LastServerError, .ErrNumber, .ErrSource, .ErrDescription
					End With
					' и очистим ошибку в текущем окне
					X_ClearLastServerError
				End If	
				If aErr(0)<>0 Then
					Err.Raise aErr(0), aErr(1), aErr(2)
				End If
			End If
			If oXmlObject Is Nothing Then Exit Function
			Set oXmlObject = Internal_AppendXmlObjectTreeFromServer(oXmlObject)
		End If
		Set GetXmlObject = oXmlObject
	End Function
 
 
	'---------------------------------------------------------------------------
	':Назначение:	
	'	Добавляет в пул дерево объектов, полученное от команды GetObject.
	':Параметры:	
	'	oXmlObject - [in] добавляемый объект, как экземпляр IXMLDOMElement
	':Примечание:	
	'	В простейшем случае oXmlObject представляет данные одного XML-объекта; если 
	'	же в процессе загрузки (при вызове GetObject) были заданы прогружаемые 
	'	свойства, то oXmlObject представляет "дерево" объектов.<P/>
	'	Внимание! Данный метод является внутренним и явно вызываться не должен!
	Public Function Internal_AppendXmlObjectTreeFromServer(oXmlObject)
		Dim oProp			' As IXMLDOMElement - xml-свойство 

		With New GetObjectEventArgsClass
			Set .XmlObject = oXmlObject
			FireEventInEditor "GetObject", .Self() 
		End With
		' вставляю его в пул объектов
		' ВАЖНО: вставляем объект в пул ДО вызова InsertXmlObjectsFromPropIntoPool, 
		' чтобы при переносе объектов из прогруженных свойств не продублировать полученный  объект
		Set oXmlObject = m_oXmlObjectPool.appendChild(oXmlObject)
		' объект с сервера мог прийти с прогруженным свойсвами (если были указаны прелоады),
		' поэтому надо все объекты значения из прогруженных свойств переместить в пул, а в свойствах оставить заглушки.
		For Each oProp In oXmlObject.selectNodes("*[not(@loaded)][*[@oid and *]]")
			InsertXmlObjectsFromPropIntoPool oProp
		Next
		' для всех объектных свойств применим отложенные действия
		applyPendingActionsForObject oXmlObject
		' в пришедшем объекте могут быть скалярные свойства, ссылающиеся на удаленные объекты
		For Each oProp In getScalarObjectPropsOfObject(oXmlObject, True)
			CheckPropForDeletedObjectRef oProp
		Next
		Set Internal_AppendXmlObjectTreeFromServer = oXmlObject
	End Function

	
	'---------------------------------------------------------------------------
	':Назначение:	
	'	Вспомогательный метод: добавляет объекты из прогруженного с сервера 
	'	объектного свойства в пул.
	':Параметры:	oProp - [in] XML-свойство, экземпляр IXMLDOMElement
	Private Sub InsertXmlObjectsFromPropIntoPool(oProp)
		Dim oXmlObject			' As IXMLDOMElement - объект в свойтсве oProp
		
		For Each oXmlObject In oProp.selectNodes("*[*]")
			InsertXmlObjectFromPropIntoPool oXmlObject, oProp
		Next
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.InsertXmlObjectFromPropIntoPool
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE InsertXmlObjectFromPropIntoPool>
	':Назначение:	
	'	Вспомогательный метод. Добавляет объект из прогруженного с сервера 
	'	свойства в пул.
	':Параметры:	
	'	oXmlObject - [in] объект в свойстве oProp, экземпляр IXMLDOMElement
	'	oProp - [in] XML-свойство, экземпляр IXMLDOMElement
	':Примечание:	
	'	В процессе добавления данных метод анализирует соответствие добавляемых и
	'	уже загруженных в пул данных; при возникновении несоответствий метод 
	'	генерирует событие <B>GetObjectConflict</B>.
	':См. также:
	'	XObjectPoolClass.GetObjectConflictEventArgsClass
	':Сигнатура:	
	'	Public Sub InsertXmlObjectFromPropIntoPool( 
	'		oXmlObject [As IXMLDOMElement], 
	'		oProp [As IXMLDOMElement] )
	Public Sub InsertXmlObjectFromPropIntoPool(oXmlObject, oProp)
		Dim oObjectInPool		' As IXMLDOMElement - объект в пуле
		Dim oChildProp			' As IXMLDOMElement - свойство объекта oXmlObject
			
		For Each oChildProp In oXmlObject.selectNodes("*[not(@loaded)][*[@oid and *]]")
			InsertXmlObjectsFromPropIntoPool oChildProp
		Next
		' в пришедшем объекте могут быть скалярные свойства, ссылающиеся на удаленные объекты
		For Each oChildProp In getScalarObjectPropsOfObject(oXmlObject, True)
			CheckPropForDeletedObjectRef oChildProp
		Next
		' поищем текущий объект из загруженного свойства в пуле
		Set oObjectInPool = m_oXmlObjectPool.selectSingleNode(oXmlObject.tagName & "[@oid='" & oXmlObject.getAttribute("oid") & "']")
		If Not oObjectInPool Is Nothing Then
			' объект уже есть в пуле, проверим его ts
			If "" & oObjectInPool.getAttribute("ts") <> "" & oXmlObject.getAttribute("ts") Then
				' ts разные
				With New GetObjectConflictEventArgsClass
					Set .LoadedProperty = oProp
					Set .ObjectInPool = oObjectInPool
					Set .ObjectFromServer = oXmlObject
					FireEventInEditor "GetObjectConflict", .Self()
				End With
			Else
				' ts совпадают, но объект в пуле помечен как удаляемый - удалим на него ссылку из прогруженного свойства
				If Not IsNull(oObjectInPool.getAttribute("delete")) Then
					' Вызывать RemoveRelation(Nothing, oProp, oXmlObject) здесь нет надобности, т.к. патчить обратные свойства в удалененном объекте не надо
					oProp.removeChild oXmlObject
				End If
			End If
		Else
			' объекта нет в пуле - добавим
			m_oXmlObjectPool.appendChild oXmlObject.cloneNode(true)
		End If	
		' заменим объект-значение в свойстве на его заглушку, если ранее не удалили оттуда
		If oXmlObject.parentNode Is oProp Then
			oProp.ReplaceChild X_CreateStubFromXmlObject(oXmlObject), oXmlObject
		End If
	End Sub


	'---------------------------------------------------------------------------
	':Назначение:	
	'	Проверяет содержится ли в заданном свойстве ссылка (ссылки) на удаленный 
	'	объект. Если такие ссылки обнаружены, то свойство очищается, для него 
	'	снимается атрибут loaded.
	':Параметры:
	'	oProp - [in] проверяемое свойство
	':Примечание:
	'	Должен вызываться только для скалярных объектных свойств.
	'	Внутренний метод.
	Private Sub CheckPropForDeletedObjectRef( oProp )
		Dim oObject		' объект-значение свойства
		Set oObject = oProp.firstChild
		If oObject Is Nothing Then Exit Sub
		If Not m_oXmlObjectPool.selectSingleNode(oObject.tagName & "[@delete and @oid='" & oObject.getAttribute("oid") & "']") Is Nothing Then
			oProp.removeChild oObject
			SetXmlPropertyDirty oProp
		End If
	End Sub
	

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetXmlObjectByXmlElement
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetXmlObjectByXmlElement>
	':Назначение:	
	'	Возвращает объект, заданный XML-данными (в т.ч. и заглушкой), из пула.
	':Параметры:
	'	oXmlObjectElement - [in] XML-данные объекта; возможно - заглушка
	'	sPreloads - [in] список прогружаемых свойств объекта, подгружаемых 
	'					на сервере, в случае когда данные объекта загружаются
	':Результат:
	'	XML-данные объекта, как экземпляр IXMLDOMElement.
	':Примечание:
	'	Если объект отсутствует в пуле, то метод загружает данные объекта в пул, 
	'	запрашивая их с сервера.
	':См. также:
	'	XObjectPoolClass.GetXmlObject, XObjectPoolClass.GetXmlObjectsByXmlNodeList<P/>
	'	<LINK oe-2-3-1, Обеспечение унифицированного доступа к XML-объектам/>
	':Сигнатура:
	'	Public Function GetXmlObjectByXmlElement(
	'		oXmlObjectElement [As IXMLDOMElement],
	'		sPreloads [As String]
	'	) [As IXMLDOMElement]
	Public Function GetXmlObjectByXmlElement(oXmlObjectElement, sPreloads)
		Set GetXmlObjectByXmlElement = GetXmlObject(oXmlObjectElement.tagName, oXmlObjectElement.getAttribute("oid"), sPreloads)
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetXmlObjectsByXmlNodeList
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetXmlObjectsByXmlNodeList>
	':Назначение:	Возвращает коллекцию объектов из пула по коллекции заглушек.
	':Параметры:
	'	oXmlNodeList - [in] список XML-объектов или заглушек, как коллекция XMLDOMNodeList
	'	sPreloads - [in] список прогружаемых свойств, подгружаемых на сервере, 
	'				в случае когда данные объектов загружаются
	':Результат:
	'	Коллекция XML-данных объектов в пуле, как экземпляр IXMLDOMNodeList.
	':Примечание:
	'	Каждый объект-значение загружается, если он отсутствует в пуле.
	':См. также:
	'	XObjectPoolClass.GetXmlObject, XObjectPoolClass.GetXmlObjectByXmlElement<P/>
	'	<LINK oe-2-3-1, Обеспечение унифицированного доступа к XML-объектам/>
	':Сигнатура:
	'	Public Function GetXmlObjectsByXmlNodeList(
	'		oXmlNodeList [As XMLDOMNodeList], 
	'		sPreloads [As String]
	'	) [As IXMLDOMNodeList]
	Public Function GetXmlObjectsByXmlNodeList(oXmlNodeList, sPreloads)
		Dim sXPath		' xpath-запрос
		Dim oNode		' As IXMLDOMNode
		
		For Each oNode In oXmlNodeList
			' получим объект в пул по заглушке (если его там еще нет)
			GetXmlObjectByXmlElement oNode, sPreloads
			If Len(sXPath) > 0 Then sXPath = sXPath & " | "
			sXPath = sXPath & oNode.tagName & "[@oid='" & oNode.getAttribute("oid") & "']"
		Next
		If IsEmpty(sXPath) Then
			' xpath-запрос, который заведомо вернет пустой список
			sXPath = "dummy[@oid='-1']"
		End If
		Set GetXmlObjectsByXmlNodeList = m_oXmlObjectPool.selectNodes(sXPath)
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.CreateXmlObjectInPool
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE CreateXmlObjectInPool>
	':Назначение:	
	'	Создает новый объект и помещает его в пул, включая в текущую транзакцию.
	':Параметры:
	'	sObjectType - [in] наименование типа создаваемого объекта
	':Результат:
	'	XML-объект, созданный в пуле, как экземпляр IXMLDOMElement.
	':Сигнатура:
	'	Public Function CreateXmlObjectInPool( sObjectType [As String] ) [As IXMLDOMElement]
	Public Function CreateXmlObjectInPool(sObjectType)
		Set CreateXmlObjectInPool = GetXmlObject(sObjectType, Null, Null)
		CreateXmlObjectInPool.SetAttribute "transaction-id", m_sTransactionID
	End Function


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.AppendXmlObject
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE AppendXmlObject>
	':Назначение:	Добавляет переданный объект в пул. 
	':Параметры:	
	'	oXmlObject - [in] добавляемый  объект, экземпляр IXMLDOMElement
	':Результат:
	'	Объект, добавленный в пул, экземпляр IXMLDOMElement.
	':Примечание:	
	'	Если в пуле данные объекта уже представлены, то добавление не выполняется; 
	'	метод возвращает XML-объект, представленный в пуле.
	':Сигнатура:
	'	Public Function AppendXmlObject( oXmlObject [As IXMLDOMElement] ) [As IXMLDOMElement]
	Public Function AppendXmlObject(oXmlObject)
		Dim sObjectID
		Dim oObjectInPool
		Dim oProp			' As IXMLDOMElement - xml-свойство 
		
		sObjectID = oXmlObject.getAttribute("oid")
		If IsNull(sObjectID) Then Err.Raise -1, "XObjectPoolClass::AppendXmlObject", "Не задан идентификатор объекта"
		Set oObjectInPool = m_oXmlObjectPool.selectSingleNode(oXmlObject.tagName & "[@oid='" & sObjectID & "']")
		If oObjectInPool Is Nothing Then
			Set oObjectInPool = m_oXmlObjectPool.appendChild( oXmlObject)
			' объект могли передать с прогруженным свойсвами,
			' поэтому надо все объекты значения из прогруженных свойств переместить в пул, а в свойствах оставить заглушки.
			For Each oProp In oXmlObject.selectNodes("*[not(@loaded)][*[@oid and *]]")
				InsertXmlObjectsFromPropIntoPool oProp
			Next
			' для всех объектных свойств применим отложенные действия
			applyPendingActionsForObject oXmlObject
			' в переданном объекте могут быть непрогруженные скалярные свойства, ссылающиеся на удаленные объекты
			For Each oProp In getScalarObjectPropsOfObject(oXmlObject, True)
				CheckPropForDeletedObjectRef oProp
			Next
		End If
		Set AppendXmlObject = oObjectInPool
	End Function


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.ReloadObject
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE ReloadObject>
	':Назначение:	Принудительно перезагружает данные объекта с сервера.
	':Параметры:	oXmlObject - [in] XML-объект или заглушка
	':См. также:	XObjectPoolClass.GetXmlObject
	':Сигнатура:	Public Sub ReloadObject( oXmlObject [As IXMLDOMElement] )
	Public Sub ReloadObject( oXmlObject )
		Dim sObjectType
		Dim sObjectID
		
		sObjectType = oXmlObject.nodeName
		sObjectID	= oXmlObject.getAttribute("oid")
		' удалим объект из пула
		m_oXmlObjectPool.selectNodes(sObjectType & "[@oid='" & sObjectID & "']").removeAll
		' загрузим в пул с сервера
		GetXmlObject sObjectType, sObjectID, Null
	End Sub
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetObjectPresentation
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetObjectPresentation>
	':Назначение:	Возвращает строковое представление объекта.
	':Параметры:	oXmlObject - [in] XML-объект в пуле
	':Результат:	Строковое представление объекта.
	':Примечание:
	'	<B><I>Строковое представление</I></B> объекта - это некоторая строка, 
	'	соответствующая конкретному экземпляру объекта.<P/>
	'	Представление объекта <I>вычисляется</I> на основании данных объекта и 
	'	VBScript-выражения определения строкового представления, заданного 
	'	элементом <B>i:to-string</B> в метаописании типа объекта в метаданных. Для
	'	вычисления выражения применяется метод ExecuteStatement (соответственно,
	'	выражение может включать подстановки вида item.PropNameN - см. описание 
	'	метода ExecuteStatement).<P/>
	'	Если элемент <B>i:to-string</B> не задан, то в качестве строкового 
	'	представления метод формирует строку вида <B>тип</B>(<B>идентификатор</B>).
	':Сигнатура:	
	'	Public Function GetObjectPresentation( oXmlObject [As IXMLDOMElement] ) [As String]
	Public Function GetObjectPresentation(oXmlObject)
		Dim oTypeMD			' As IXMLDOMElement - метаданные типа oXmlObject
		Dim oToStringMD		' As IXMLDOMElement - элемент i:to-string в метаописании типа
		Dim sToStringStmt	' As String - выражение для вычисления представления объекта
		
		' TODO! Возможно генерирует событие.
		Set oTypeMD = X_GetTypeMD(oXmlObject.tagName)
		' если тип не будет найден, будет ошибка, поэтому здесь считаем, что oTypeMD всегда не Nothing
		Set oToStringMD = oTypeMD.selectSingleNode("i:to-string")
		If oToStringMD Is Nothing Then
			' если для типа не задано стандартное представление (i:to-string), то определим дефолтное: тип(идентификатор)
			sToStringStmt = "item().nodeName & ""("" & item.ObjectID & "")"""
		Else
			sToStringStmt = oToStringMD.text
		End If
		' вычислим представление объекта
		GetObjectPresentation = ExecuteStatement(oXmlObject, sToStringStmt)
	End Function
	
	'===========================================================================
	' ПОЛУЧЕНИЕ ОБРАТНЫХ ССЫЛКОК

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetReverseXmlProperty
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetReverseXmlProperty>
	':Назначение:	
	'	Возвращает XML-свойство объекта oXmlObject, являющееся обратным заданному
	'	свойству oParentXmlProperty.
	':Параметры:
	'	oXmlObject - [in] объект (IXMLDOMElement корневого узла объекта)
	'	oParentXmlProperty - [in] свойство объекта
	':Результат:
	'	Обратное свойство, как экземпляр IXMLDOMElement. Если обратного свойства
	'	для заданного oParentXmlProperty нет, то метод возвращает Nothing.
	':См. также:
	'	XObjectPoolClass.GetReversePropertyMD,<P/>
	'	<LINK oe-2-3-3-1, Операции с объектными ссылками/>
	':Сигнатура:
	'	Public Function GetReverseXmlProperty(
	'		oXmlObject [As IXMLDOMElement], oParentXmlProperty [As IXMLDOMElement]
	'	) [As IXMLDOMElement]
	Public Function GetReverseXmlProperty(oXmlObject, oParentXmlProperty)
		Dim oReversePropMD		' As IXMLDOMElement - метаданные обратного свойства
		
		Set GetReverseXmlProperty = Nothing
		' получим метаданные свойства, являющегося "обратным" свойству oParentXmlProperty
		Set oReversePropMD =  GetReversePropertyMD(oParentXmlProperty)
		If Not oReversePropMD Is Nothing Then
			' проверим, что переданный объект действительно того типа, который владеет свойством, чьи метаданные мы получили
			If oReversePropMD.parentNode.getAttribute("n") <> oXmlObject.nodeName Then
				Err.Raise -1, "XObjectPoolClass::GetReverseXmlProperty", "Тип объекта oXmlObject не совпадает с типом, который содержит свойство, являющееся обратным свойству oParentXmlProperty"
			End If
			' получим это xml-свойство
			Set GetReverseXmlProperty = oXmlObject.selectSingleNode( oReversePropMD.getAttribute("n") )
		End If
	End Function

	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetReversePropertyMD
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetReversePropertyMD>
	':Назначение:	
	'	Возвращает метаописание свойства объекта, являющегося обратным заданному 
	'	свойству oParentXmlProperty.
	':Параметры:	
	'	oParentXmlProperty - [in] XML-свойство, экземпляр IXMLDOMElement
	':Результат:
	'	Метаописание свойства (узел <B>ds:type/ds:prop</B>) свойства, являющегося 
	'	обратным заданному свойству oParentXmlProperty, как экземпляр IXMLDOMElemet.
	'	Если для свойства обратное не определено, метод возвращает Nothing.
	':См. также:
	'	XObjectPoolClass.GetReverseMDProp, XObjectPoolClass.GetReverseXmlProperty,<P/>
	'	<LINK oe-2-3-3-1, Операции с объектными ссылками/>
	':Сигнатура:
	'	Public Function GetReversePropertyMD( oParentXmlProperty [As IXMLDOMElement] ) [As IXMLDOMElement]
	Public Function GetReversePropertyMD(oParentXmlProperty)
		Set GetReversePropertyMD = GetReverseMDProp( X_GetPropertyMD(oParentXmlProperty) )
	End Function
	

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetReverseMDProp
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetReverseMDProp>
	':Назначение:	
	'	Возвращает метаописание свойства объекта, являющегося обратным заданному 
	'	метаописанию свойства oParentPropMD.
	':Параметры:	
	'	oParentPropMD - [in] метаописание исходного свойства, экземпляр IXMLDOMElement
	':Результат:
	'	Метаописание свойства (узел <B>ds:type/ds:prop</B>) свойства, являющегося 
	'	обратным заданному свойству oParentPropMD, как экземпляр IXMLDOMElemet.
	'	Если для свойства обратное не определено, метод возвращает Nothing.
	':См. также:
	'	XObjectPoolClass.GetReversePropertyMD, XObjectPoolClass.GetReverseXmlProperty,<P/>
	'	<LINK oe-2-3-3-1, Операции с объектными ссылками/>
	':Сигнатура:
	'	Public Function GetReverseMDProp( oParentPropMD [As IXMLDOMElement] ) [As IXMLDOMElement]
	Public Function GetReverseMDProp(oParentPropMD)
		Dim sPropName			' As String - наименование свойства 
		Dim sOwnerTypeName		' As String - наименование объекта-владельца свойства
		Dim sXPath				' As String - XPath
		Dim sReversePropOwnerTypeName	' As String - наименование типа объекта владельца обратного свойства
		
		sPropName = oParentPropMD.getAttribute("n")
		sOwnerTypeName = oParentPropMD.parentNode.getAttribute("n")
		sReversePropOwnerTypeName = oParentPropMD.getAttribute("ot")
		If IsNull(sReversePropOwnerTypeName) Then Err.Raise -1, "GetReverseMDProp", "Метод должен вызываться только для объектных свойств"
		Select Case oParentPropMD.getAttribute("cp")
			Case "collection"
				sXPath = "ds:prop[@cp='collection-membership' and @built-on='" & sPropName & "' and @ot='" & sOwnerTypeName & "']"
			Case "collection-membership"
				sXPath = "ds:prop[@n='" & oParentPropMD.getAttribute("built-on") & "' and @cp='collection' and @ot='" & sOwnerTypeName & "']"
			Case "link", "link-scalar"
				sXPath = "ds:prop[@n='" & oParentPropMD.getAttribute("built-on") & "' and @cp='scalar' and @vt='object' and @ot='" & sOwnerTypeName & "']"
			Case "scalar"
				sXPath = "ds:prop[(@cp='link' or @cp='link-scalar') and @vt='object' and @built-on='" & sPropName & "' and @ot='" & sOwnerTypeName & "']"
			Case "array"
				sXPath = "ds:prop[@cp='array-membership' and @built-on='" & sPropName & "' and @ot='" & sOwnerTypeName & "']"
			Case "array-membership"
				sXPath = "ds:prop[@n='" & oParentPropMD.getAttribute("built-on") & "' and @cp='array' and @ot='" & sOwnerTypeName & "']"
		End Select
		If IsEmpty(sXPath) Then
			Set GetReverseMDProp = Nothing
		Else
			Set GetReverseMDProp = X_GetTypeMD(sReversePropOwnerTypeName).selectSingleNode(sXPath)
		End If
	End Function
	
	
	'===========================================================================
	' ОБРАБОТКА ОБЪЕКТОВ

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.SetXmlPropertyDirty
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE SetXmlPropertyDirty>
	':Назначение:	
	'	Помечает свойство как модифицированное. Объект-владелец свойства 
	'	включается в транзанкцию.
	':Параметры:
	'	oXmlProperty - [in] свойство, помечаемое как модифицированное
	':См. также:
	'	XObjectPoolClass.EnlistXmlObjectIntoTransaction
	':Сигнатура:
	'	Public Sub SetXmlPropertyDirty( oXmlProperty [As IXMLDOMElement] )
	Public Sub SetXmlPropertyDirty(oXmlProperty)
		oXmlProperty.SetAttribute "dirty", 1
		oXmlProperty.removeAttribute "loaded"
		oXmlProperty.ParentNode.SetAttribute "transaction-id", m_sTransactionID
	End Sub

	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.EnlistXmlObjectIntoTransaction
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE EnlistXmlObjectIntoTransaction>
	':Назначение:	Включает заданный XML-объект в текущую транзакцию.
	':Параметры:	oXmlObject - [in] XML-объект, возможно заглушка
	':См. также:	XObjectPoolClass.SetXmlPropertyDirty
	':Сигнатура:
	'	Public Sub EnlistXmlObjectIntoTransaction( oXmlObject [As IXMLDOMElement] )
	Public Sub EnlistXmlObjectIntoTransaction(oXmlObject)
		GetXmlObjectByXmlElement(oXmlObject, Null).SetAttribute "transaction-id", m_sTransactionID
	End Sub
	

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.IsSameProperties
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE IsSameProperties>
	':Назначение:	Сравнивает ссылки на XML-свойства объекта.
	':Параметры:	oProp1 - [in] ссылка на сравниваемое свойство, "левый" параметр
	'				oProp2 - [in] ссылка на сравниваемое свойство, "правый" параметр
	':Результат:	True, если oProp1 и oProp2 есть одни и те же свойства одного 
	'				и того же объекта.
	':См. также:	XObjectPoolClass.CheckReferences, <LINK oe-2-3-3-2, Удаление объекта/>
	':Сигнатура:	
	'	Public Function IsSameProperties( 
	'		oProp1 [As IXMLDOMElement], oProp2 [As IXMLDOMElement] 
	'	) [As Boolean]
	Public Function IsSameProperties(oProp1, oProp2)
		If oProp1 Is Nothing Or oProp2 Is Nothing Then
			IsSameProperties = false
		ElseIf oProp1 Is oProp2 Then
			IsSameProperties = true
		Else
			IsSameProperties = _
				oProp1.tagName & "@" & oProp1.parentNode.tagName & "(" & oProp1.parentNode.getAttribute("oid") & ")" = _
				oProp2.tagName & "@" & oProp2.parentNode.tagName & "(" & oProp2.parentNode.getAttribute("oid") & ")"
		End If		
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.CheckReferences
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE CheckReferences>
	':Назначение: 
	'	Для заданного (удаляемого) объекта находит все ссылки на него, а также 
	'	все ссылки на объекты, ссылающееся на заданный через ссылки с каскадным
	'	удалением.
	':Параметры:
	'	oXmlObject - [in] удаляемый XML-объект (ссылка на объект в пуле, 
	'			экземпляр IXMLDOMElement)
	'	oXmlProperty - [in] если задано, то обязательная ссылка в данном 
	'			свойстве не попадает в список oNotNullReferences.
	'	oAllReferences - [in] список всех ссылок на удаляемые объекты, как
	'			экземпляр класса ObjectArrayListClass
	'	oNotNullReferences - [in] список ссылок на удаляемые объекты из 
	'			обязательных свойств, как экземпляр ObjectArrayListClass
	'	oObjectsToDelete - [in] список ссылок на объекты в пуле, которые 
	'			надо пометить как удаляемые; экземпляр ObjectArrayListClass
	'	oXmlPropCascade - [in] свойство с касдадным удалением; задается только 
	'			для подчиненных объектов, при рекурсивных вызовах. Используется 
	'			для исключения подсчета ссылок со стороны удаляемого объекта на 
	'			текущий (также удаляемый объект), на который текущий объект 
	'			ссылается свойством с каскадным удалением. Если не используется,
	'			задается как Nothing.
	':Примечания:
	'	Все найденные ссылки помещаются в список oAllReferences.<P/>
	'	Если ссылка обязательная, то она помещается в список oNotNullReferences, 
	'	исключение - ссылка заданная параметром oXmlProperty.<P/>
	'	В oObjectsToDelete помещает переданный объект, а также все объекты, 
	'	ссылающееся на него по ссылкам с каскадным удалением.
	':См. также:
	'	XObjectPoolClass.MarkObjectAsDeleted, XObjectPoolClass.IsSameProperties,<P/>
	'	<LINK oe-2-3-3-2, Удаление объекта/>
	':Сигнатура:
	'	Public Sub CheckReferences(
	'		oXmlObject [As IXMLDOMElement], 
	'		oXmlProperty [As IXMLDOMElement], 
	'		oAllReferences [As ObjectArrayListClass], 
	'		oNotNullReferences [As ObjectArrayListClass], 
	'		oObjectsToDelete [As ObjectArrayListClass], 
	'		oXmlPropCascade [As IXMLDOMElement] )
	Public Sub CheckReferences(oXmlObject, oXmlProperty, oAllReferences, oNotNullReferences, oObjectsToDelete, oXmlPropCascade)
		Dim oRef			' As XMLDOMElement - ссылка на удаляемый объект, xml-объект-значение свойства
		Dim oProp			' As XMLDOMElement - свойство содержащее ссылку oRef
		Dim oPropMD			' As XMLDOMElement - метаданные свойства oProp
		Dim bIsNotNull		' As Boolean - признак обязательного свойства
		Dim sCapacity		' As String - емкость свойства
		Dim bIgnore			' As Boolean - признак игнорирования текущей ссылки

		If oObjectsToDelete.IsExists(oXmlObject) Then Exit Sub
		' добавим переданный объект в список удаляемых
		oObjectsToDelete.Add oXmlObject
		' получим все ссылки в пуле на удаляемый объект
		For Each oRef In m_oXmlObjectPool.selectNodes("*/*/" & oXmlObject.nodeName & "[@oid='" & oXmlObject.getAttribute("oid") & "']")
			Set oProp = oRef.parentNode
			Set oPropMD = X_GetPropertyMD(oProp)
			' теоретически ссылка может быть от чего-то, что не является свойством, такие узлы пропустим
			If Not oPropMD Is Nothing Then
				If Not IsNull(oPropMD.GetAttribute("delete-cascade")) Then
					' текущая ссылка из свойства с каскадным удалением - запустим себя рекурсивно для владельца этой ссылки
					CheckReferences oProp.parentNode, Nothing, oAllReferences, oNotNullReferences, oObjectsToDelete, oProp
				Else
					bIgnore = False
					If Not oXmlPropCascade Is Nothing Then
						' если здесь, значит нас запустили рекурсивно для подчиненного объекта.
						' Если текущая ссылка (oRef) является обратным свойство для oXmlPropCascade, то ее считать не надо вообще
						bIgnore = IsSameProperties(GetReverseXmlProperty(oXmlObject, oProp), oXmlPropCascade)
					End If
					If Not bIgnore Then
						If Not IsSameProperties(oXmlProperty, oProp) Then
							' обычная ссылка, проверим на обязательность:
							' если у свойства задан атрибут notnull, считаем ссылку обязательной
							bIsNotNull = Not IsNull(oProp.getAttribute(ATTR_NOTNULL))
							If Not bIsNotNull Then
								' иначе проверяем обязательность по метасвойству
								sCapacity = oPropMD.getAttribute("cp")
								If sCapacity = "scalar" Then
									bIsNotNull = IsNull(oPropMD.getAttribute("maybenull"))
								ElseIf sCapacity = "array" Then
									' членство в массиве всегда препятствует удалению
									bIsNotNull = True
								ElseIf sCapacity = "collection" Then
									' членство в коллекции препятствует удалению только если нет обратного св-ва
									bIsNotNull = GetReverseMDProp(oPropMD) Is Nothing
								End If
							End If
							If bIsNotNull Then
								' ссылка обязательная.
								oNotNullReferences.Add oRef
							End If
						End If
						oAllReferences.Add oRef
					End If
				End If
			End If
		Next
	End Sub
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.MarkObjectAsDeleted
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE MarkObjectAsDeleted>
	':Назначение:	Удаление объекта, заданного типом и идентификатором.
	':Параметры:	
	'	sObjectType - [in] тип удаляемого объекта
	'	sObjectID - [in] идентификатор удаляемого объекта
	'	oXmlProperty - [in] указание свойства, ссылка в котором не препятствует 
	'			удалению; если не используется, задается в Nothing
	'	bSilentMode - [in] признак "тихого режима"; устанавливается в параметрах 
	'			события, генерируемого при обнаружении конфликта удаления
	'	oPropertiesToUpdate - [out] коллекция свойств (помимо oXmlProperty), 
	'			которые необходимо обновить из-за того, что из них были удалены 
	'			ссылки; экземпляр ObjectArrayListClass
	':Результат:
	'	Признак успешного завершения "удаления" (установки атрибутов delete для 
	'	всех объектов в пуле). Метод возвращает False в случае отмены удаления 
	'	при обработке события <B>DeleteObjectConflict</B>.
	':Примечания:
	'	Удаляемый объект помечается атрибутом delete="1". Так же помечаются все 
	'	объекты в пуле, которые ссылаются на заданный по ссылкам с каскадным 
	'	удалением (delete-cascade="1" в метаопределении объктного свойства).<P/>
	'	Если на удаляемые объекты есть обязательные ссылки (свойства помеченные 
	'	как notnull="1" и свойства, для	которых в метаданных не задано maybenull="1"), 
	'	то удаление блокируется; метод генерирует событие <B>DeleteObjectConflict</B>.<P/>
	'	Если обязательных ссылок нет, то удаляются все ссылки на удаляемые объекты 
	'	(с учетом каскадного удаления).
	':См. также:
	'	XObjectPoolClass.CheckReferences, XObjectPoolClass.IsSameProperties, 
	'	DeleteObjectConflictEventArgsClass,<P/>
	'	<LINK oe-2-3-3-2, Удаление объекта/>
	':Сигнатура:
	'	Public Function MarkObjectAsDeleted(
	'		sObjectType [As String], 
	'		sObjectID [As String], 
	'		oXmlProperty [As IXMLDOMElement], 
	'		bSilentMode [As Boolean], 
	'		ByRef oPropertiesToUpdate [As ObjectArrayListClass]
	'	) [As Boolean]
	Public Function MarkObjectAsDeleted(sObjectType, sObjectID, oXmlProperty, bSilentMode, ByRef oPropertiesToUpdate)
		Dim oXmlObject			' As XMLDOMElement - xml-объект
		Dim oAllReferences		' As ObjectArrayListClass - список всех ссылок на удаляемые объекты
		Dim oNotNullReferences	' As ObjectArrayListClass - список ссылок на удаляемые объекты из обязательных свойств
		Dim oObjectsToDelete	' As ObjectArrayListClass - список ссылок на объекты в пуле, которые надо пометить как удаляемые
		
		MarkObjectAsDeleted = False
		' удостоверимся в том, что объект в пуле
		Set oXmlObject = GetXmlObject(sObjectType, sObjectID, Null)
		' oXmlObject Is Nothing быть не может, т.к. при загрузке с сервера несуществующего объекта будет exception

		Set oAllReferences = New ObjectArrayListClass
		Set oNotNullReferences = New ObjectArrayListClass
		Set oObjectsToDelete = New ObjectArrayListClass
		CheckReferences oXmlObject, oXmlProperty, oAllReferences, oNotNullReferences, oObjectsToDelete, Nothing
		' теперь у нас есть список объектов которые надо удалить, а также список ссылок на них, как всех, так и обязательных.
		' Если список обязательных ссылок не пуст, то удалять нельзя
		If oNotNullReferences.Count>0 Or oAllReferences.Count>1 Then
			With New DeleteObjectConflictEventArgsClass
				.SilentMode = bSilentMode
				Set .SourceXmlProperty = oXmlProperty
				Set .ObjectsToDelete = oObjectsToDelete
				Set .NotNullReferences = oNotNullReferences
				Set .AllReferences = oAllReferences
				FireEventInEditor "DeleteObjectConflict", .Self()
				If Not .ReturnValue Then Exit Function
				Set oPropertiesToUpdate = .PropertiesToUpdate
			End With
		End If
		Internal_DoMarkObjectAsDeleted oAllReferences, oObjectsToDelete
		MarkObjectAsDeleted = True
	End Function

	
	'---------------------------------------------------------------------------
	':Назначение:
	'	Выполняет удаление всех объектов из списка oObjectsToDelete и очистку 
	'	всех ссылок из списка oAllReferences.
	':Параметры:
	'	oAllReferences - [in] список всех ссылок на удаляемые объекты, ObjectArrayListClass 
	'	oObjectsToDelete - [in] список ссылок на объекты в пуле, которые надо 
	'			пометить как удаляемые, ObjectArrayListClass
	':Примечание:
	'	XML-элементы в обоих списках должен указывать на объекты/свойства из пула!
	'	Внимание! Метод является внутренним и не должен вызываться явно!
	Public Sub Internal_DoMarkObjectAsDeleted(oAllReferences, oObjectsToDelete)
		Dim oRef				' As IXMLDOMELement - временная
		Dim i
		Dim oXmlObject			' As XMLDOMElement - xml-объект
		Dim oPropMD		' As IXMLDOMELement - метаданные свойства (ds:prop)
		
		' по всем ссылкам на удаляемые объекты
		For i=0 To oAllReferences.Count-1
			' oRef - объект-значение (заглушка) в xml-свойстве ссылающийся на удаляемый объект, oRef.parentNode - xml-свойство
			Set oRef = oAllReferences.GetAt(i)
			' TODO: здесь некоторый overhead связанный с синхронизацией обратных свойств удаляемого объекта в случае, если он новый
			RemoveRelation Nothing, oRef.parentNode, oRef
		Next
		' по всем объектам из списка удаляемых
		For i=0 To oObjectsToDelete.Count-1
			Set oXmlObject = oObjectsToDelete.GetAt(i)
			' если объект из БД, то пометим его атрибутов и включим в транзакцию, иначе просто удалим из пула
			If IsNull(oXmlObject.getAttribute("new")) Then
				oXmlObject.setAttribute "delete", "1"
				oXmlObject.setAttribute "transaction-id", m_sTransactionID
			Else
				' Примечание: oObjectsToDelete содержит ссылки на xml-объекты из пула, поэтому следующая операция корректна
				deleteNewObject oXmlObject
				
				' При полном удалении несохраненного объекта из пула недопустимо оставлять на него никаких ссылок.
				' Если у типа удаленного объекта есть скалярные ссылки с касданым удалением, 
				' то удалим возможные ссылки из обратных свойств 
				' (они могут быть, если удаление нового текущего объекта происходит из-за удаления родительского объекта)
				For Each oPropMD In X_GetTypeMD(oXmlObject.tagName).selectNodes("ds:prop[@delete-cascade='1']")
					Set oPropMD = GetReverseMDProp(oPropMD)
					If Not oPropMD Is Nothing Then
						m_oXmlObjectPool.selectNodes(_
							oPropMD.parentNode.getAttribute("n") & "/" & oPropMD.getAttribute("n") & "/" & _
								oXmlObject.tagName & "[@oid='" & oXmlObject.getAttribute("oid") & "']").removeAll
					End If
				Next
			End If
		Next
	End Sub
	
	
	'---------------------------------------------------------------------------
	':Назначение:	Удаляет новый объект из пула
	':Параметры:	oXmlObject - [in] XML-объект в пуле, IXMLDOMElement
	Private Sub deleteNewObject(oXmlObject)
		Dim sTypeName		' тип удаляемого объекта
		Dim sObjectID		' идентификатор удаляемого объекта
		
		' удалим все pending-actions, связанные с удаляемым объектом
		sTypeName = oXmlObject.tagName
		sObjectID = oXmlObject.getAttribute("oid")
		m_oXmlPendingActions.selectNodes("*[@ot='" & sTypeName & "' and @oid='" & sObjectID & "'] | *[@ref-ot='" & sTypeName & "' and @ref-oid='" & sObjectID & "']").removeAll
		recalculateHasPendingActionsFlag
		
		m_oXmlObjectPool.removeChild oXmlObject
	End Sub
	
	'===========================================================================
	' ОПЕРАЦИИ С ОБЪЕКТНЫМИ ССЫЛКАМИ
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.AddRelation
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE AddRelation>
	':Назначение:	
	'	Добавляет ссылку на объект в объектное свойство. При этом соответствующим 
	'	образом модифицируется обратное свойство у добавляемого объекта (если 
	'	такое определено).
	':Параметры:
	'	oXmlObject	- [in] объект, в свойство которого добавляем ссылку; если 
	'			параметр vPropName задан как IXMLDOMElement, то данный параметр 
	'			может быть задан в Nothing.
	'	vPropName	- [in] свойство, в которое добавляем ссылку; здась задается 
	'			либо наименование свойства, либо ссылка на XML-узел свойства
	'	oRefObject	- [in] добавляемый объект-значение свойства; может быть 
	'			"заглушкой". Экземпляр IXMLDOMElement (см. замечания)
	':Результат:
	'	Добавленная в свойство заглушка объекта-значения, экземпляр IXMLDOMElement.<P/>
	'	Если в процессе добавления ссылки на сервере возникнет исключение 
	'	BusinessLogicException, ObjectNotFoundException или SecurityException,
	'	то метод вернет Nothing без генерации ошибки времени исполнения.
	':Примечания:
	'	Указанное объект-значение может быть не загружено в пул (если задано как 
	'	"заглушка"); так же в пул может быть не прогружено обратное свойство. 
	'	В этом случае метод данные с сервера <B>не загружает</B>, а сохраняет 
	'	запись <B>об отложенном действии</B>. Эта запись определеят операции, 
	'	которые выполнятся при последующей загрузке объекта / свойства (если 
	'	такая последует).<P/>
	'	<B>Внимание!</B> XML-объект, задаваемый параметром oRefObject, не клонируется!
	':См. также:
	'	XObjectPoolClass.AddRelationWithOrder, XObjectPoolClass.RemoveRelation,<P/>
	'	<LINK oe-2-3-3-1, Операции с объектными ссылками />,
	'	<LINK oe-2-3-4, Отложенные действия />
	':Сигнатура:
	'	Public Function AddRelation(
	'		ByVal oXmlObject [As IXMLDOMElement], 
	'		vProp [As Variant], 
	'		ByVal oRefObject [As IXMLDOMElement]
	'	) [As IXMLDOMElement]
	Public Function AddRelation(ByVal oXmlObject, vProp, ByVal oRefObject)
		Set AddRelation = AddRelationWithOrder( oXmlObject, vProp, oRefObject, Nothing )
	End Function


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.AddRelationWithOrder
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE AddRelationWithOrder>
	':Назначение:	
	'	Добавляет ссылку на объект в объектное свойство с учетом порядка. При 
	'	этом соответствующим образом модифицируется обратное свойство у добавляемого 
	'	объекта (если такое определено).
	':Параметры:
	'	oXmlObject	- [in] объект, в свойство которого добавляем ссылку; если 
	'			свойство vPropName задано как IXMLDOMElement, то данный параметр 
	'			может быть задан в Nothing.
	'	vPropName	- [in] свойство, в которое добавляем ссылку; здась задается 
	'			либо наименование свойства, либо ссылка на XML-узел свойства
	'	oRefObject	- [in] добавляемый объект-значение свойства; может быть 
	'			"заглушкой". Экземпляр IXMLDOMElement (см. замечания)
	'	oBeforeObject - [in] объект-значение, перед которым происходит вставка 
	'			объекта-значения, задаваемого oRefObject, экземпляр IXMLDOMElement
	'			(не обязательно - описание объекта-значения свойства, достаточно
	'			указания тип и идентификатора объекта в свойстве, перед которым 
	'			надо произвести вставку)
	':Результат:
	'	Добавленная в свойство заглушка объекта-значения, экземпляр IXMLDOMElement.<P/>
	'	Если в процессе добавления ссылки на сервере возникнет исключение 
	'	BusinessLogicException, ObjectNotFoundException или SecurityException,
	'	то метод вернет Nothing без генерации ошибки времени исполнения.
	':Примечания:
	'	Указанное объект-значение может быть не загружено в пул (если задано как 
	'	"заглушка"); так же в пул может быть не прогружено обратное свойство. 
	'	В этом случае метод данные с сервера <B>не загружает</B>, а сохраняет 
	'	запись <B>об отложенном действии</B>. Эта запись определеят операции, 
	'	которые выполнятся при последующей загрузке объекта / свойства (если 
	'	такая последует).<P/>
	'	Однако, если у типа добавляемого объекта есть обратное метасвойство для 
	'	свойства vProp, то объект загружается в пул (если его там еще не было).<P/> 
	'	<B>Внимание!</B> XML-объект, задаваемый параметром oRefObject, не клонируется!
	':См. также:
	'	XObjectPoolClass.AddRelation, XObjectPoolClass.RemoveRelation,<P/>
	'	<LINK oe-2-3-3-1, Операции с объектными ссылками />,
	'	<LINK oe-2-3-4, Отложенные действия />
	':Сигнатура:
	'	Public Function AddRelationWithOrder(
	'		ByVal oXmlObject [As IXMLDOMElement], 
	'		vProp [As Variant], 
	'		ByVal oRefObject [As IXMLDOMElement]
	'		oBeforeObject [As IXMLDOMElement]
	'	) [As IXMLDOMElement]
	Public Function AddRelationWithOrder(ByVal oXmlObject, vProp, ByVal oRefObject, oBeforeObject)
		Dim oPropMD			' As IXMLDOMElement - метаданные модифицируемого свойства
		Dim oProp			' As IXMLDOMElement - модифицируемое свойство
		Dim oReversePropMD	' As IXMLDOMElement - метаданные обратного свойства
		Dim oBeforeObjectLocal	' As IXMLDOMElement - узел объекта-значения (ссылки) в свойстве, перед которым надо вставить переданную ссылку
		
		Set oProp = LoadXmlProperty( oXmlObject, vProp )
		Set oXmlObject = oProp.parentNode
		If IsNothing(oRefObject) Then
			Err.Raise -1, "XObjectPoolClass::AddRelationWithOrder", "Не задан добавляемый объект-значение"
		End If
		Set oPropMD = X_GetPropertyMD(oProp)
		Select Case oPropMD.getAttribute("cp")
			Case "scalar"
				If Not oProp.firstChild Is Nothing Then
					Err.Raise -1, "XObjectPoolClass::AddRelationWithOrder", "Скалярное объектное свойство должно быть пустым перед вызовом этого метода"
				End If
			Case "array-membership"
				Err.Raise -1, "XObjectPoolClass::AddRelationWithOrder", "Свойство типа 'array-membership' не должно модифицироваться"
			Case Else
				' в массивном свойстве проверим, что добавляемого объекта нет в свойстве
				If Not oProp.selectSingleNode("*[@oid='" & oRefObject.getAttribute("oid") & "']") Is Nothing Then
					Err.Raise -1, "XObjectPoolClass::AddRelationWithOrder", "Добавляемый объект уже есть в свойстве"
				End If
		End Select
		' добавим ссылку в свойство
		If oBeforeObject Is Nothing Then
			Set AddRelationWithOrder = oProp.appendChild( X_CreateStubFromXmlObject(oRefObject) )
		Else
			' получим узел объекта в свойстве (т.е. ссылку), т.к. нам могли передать сам объект
			Set oBeforeObjectLocal = oProp.selectSingleNode(oBeforeObject.tagName & "[@oid='" & oBeforeObject.getAttribute("oid") & "']")
			Set AddRelationWithOrder = oProp.insertBefore( X_CreateStubFromXmlObject(oRefObject), oBeforeObjectLocal)
		End if
		' пометим свойство как модифицированное
		SetXmlPropertyDirty oProp
		Set oReversePropMD = GetReversePropertyMD(oProp)
		If oReversePropMD Is Nothing Then Exit Function
		' если здесь, значит обратное свойство в объекте oRefObject существует.
		
		' модифицируем обратное свойство, либо, в случае, если объект или свойство не загружены, создадим запись об отложенном действии
		addRefInternal oRefObject.tagName, oRefObject.getAttribute("oid"), oReversePropMD, X_CreateStubFromXmlObject(oXmlObject)
	End Function

		
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.RemoveRelation
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE RemoveRelation>
	':Назначение:	
	'	Удаляет ссылку на объект из объектного свойства. При этом соответствующим 
	'	образом модифицируется обратное свойство у объекта-значения (если такое 
	'	определено). Для этого объект-значение (если его тип имеет обратное свойство) 
	'	всегда загружается в пул.
	':Параметры:
	'	oXmlObject	- [in] объект, из свойства которого удаляем ссылку; если 
	'			параметр vPropName задан как IXMLDOMElement, то этот параметр
	'			может быть задан в Nothing.
	'	vPropName	- [in] свойство, из которого удаляем ссылку; здась задается 
	'			либо наименование свойства, либо ссылка на XML-узел свойства
	'	oRefObject	- [in] объект-значение свойства; может быть "заглушкой"
	':См. также:
	'	XObjectPoolClass.RemoveAllRelations, XObjectPoolClass.AddRelation,<P/>
	'	<LINK oe-2-3-3-1, Операции с объектными ссылками />,
	'	<LINK oe-2-3-4, Отложенные действия />
	':Сигнатура:
	'	Public Sub RemoveRelation(
	'		ByVal oXmlObject [As IXMLDOMElement], 
	'		vProp [As Variant], 
	'		ByVal oRefObject [As IXMLDOMElement] )
	Public Sub RemoveRelation(ByVal oXmlObject, vProp, ByVal oRefObject)
		Dim oProp			' As IXMLDOMElement - модифицируемое свойство
		
		If oRefObject Is Nothing Then Exit Sub
		Set oProp = LoadXmlProperty( oXmlObject, vProp )
		removeRelationFromLoadedProp oProp, oRefObject
	End Sub

	
	'---------------------------------------------------------------------------
	':Назначение:	"Грамотно" удаляет ссылку на объект из объектного свойства. 
	':Примечание:
	'	В отличии от RemoveRelation не прогружает свойство, Т.е. предполагается, 
	'	что свойство уже прогружено. При этом соответствующим образом модифицируется 
	'	обратное свойство у объекта-значения(если оно есть). Для этого объект 
	'	значение (если его тип имеет обратное свойство) всегда загружается в пул.
	':Параметры:
	'	oProp - [in] свойство, в которое добавляем ссылку; ссылка на XML-узел свойства
	'	oRefObject - [in] добавляемый объект-значение свойства; может быть "заглушкой"
	Private Sub removeRelationFromLoadedProp(oProp, oRefObject)
		Dim oXmlObject 		' As IXMLDOMElement - объект, из свойства которого удаляем ссылку
		Dim oPropMD			' As IXMLDOMElement - метаданные модифицируемого свойства
		Dim oReversePropMD	' As IXMLDOMElement - метаданные обратного свойства
		
		Set oXmlObject = oProp.parentNode
		' если свойство типа array-membership, то ругаемся
		Set oPropMD = X_GetPropertyMD(oProp)
		If oPropMD.getAttribute("cp") = "array-membership" Then
			Err.Raise -1, "XObjectPoolClass::RemoveRelation", "Свойство типа 'array-membership' не должно модифицироваться"
		End If
		' поищим в свойство объект-значение, ссылку на который просят удалить
		Set oRefObject = oProp.selectSingleNode(oRefObject.nodeName & "[@oid='" & oRefObject.getAttribute("oid") & "']")
		' не нашли? до свидания
		If oRefObject Is Nothing Then Exit Sub
		' удалим ссылку
		oRefObject.parentNode.removeChild oRefObject
		' пометим свойство как модифицированное
		SetXmlPropertyDirty oProp
		' очистим обратное свойство,если оно есть
		Set oReversePropMD = GetReversePropertyMD(oProp)
		If oReversePropMD Is Nothing Then Exit Sub
		
		' модифицируем обратное свойство, либо, в случае, если объект или свойство не загружены, создадим запись об отложенном действии
		removeRefInternal oRefObject.tagName, oRefObject.getAttribute("oid"), oReversePropMD, X_CreateStubFromXmlObject(oXmlObject)
	End Sub
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.RemoveAllRelations
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE RemoveAllRelations>
	':Назначение:	
	'	Удаляет все ссылки из объектного свойства. Вызывает RemoveRelation для 
	'	каждого объекта-значения.
	':Параметры:
	'	oXmlObject	- [in] объект, из свойства которого удаляем ссылки; если 
	'			параметр vPropName задан как IXMLDOMElement, то этот параметр
	'			может быть задан в Nothing.
	'	vPropName	- [in] свойство, из которого удаляем ссылки; здась задается 
	'			либо наименование свойства, либо ссылка на XML-узел свойства
	':См. также:
	'	XObjectPoolClass.RemoveRelation, XObjectPoolClass.AddRelation,<P/>
	'	<LINK oe-2-3-3-1, Операции с объектными ссылками />,
	'	<LINK oe-2-3-4, Отложенные действия />
	':Сигнатура:
	'	Public Sub RemoveAllRelations( 
	'		ByVal oXmlObject [As IXMLDOMElement], 
	'		ByVal vProp [As Variant] )
	Public Sub RemoveAllRelations(ByVal oXmlObject, ByVal vProp )
		Dim oProp			' As IXMLDOMElement - модифицируемое свойство
		Dim oRefObject		' As IXMLDOMElement - xml-объект-значение
		
		Set oProp = LoadXmlProperty( oXmlObject, vProp )
		For Each oRefObject In oProp.childNodes
			removeRelationFromLoadedProp oProp, oRefObject
		Next
	End Sub
	
	
	'---------------------------------------------------------------------------
	':Назначение:	Добавляет ссылку в свойство.
	':Параметры:
	'	sTypeName - [in] тип объекта владельца
	'	sObjectID - [in] идентификатор объекта владельца
	'	oPropMD - [in] метаданные свойства
	'	oXmlObjectValue - [in] болванка объекта-значения
	Private Sub addRefInternal(sTypeName, sObjectID, oPropMD, oXmlObjectValue)
		manageRefInternal sTypeName, sObjectID, oPropMD, "add", oXmlObjectValue
	End Sub

	
	'---------------------------------------------------------------------------
	':Назначение:	Удаляет ссылку из свойства.
	':Параметры:
	'	sTypeName - [in] тип объекта владельца
	'	sObjectID - [in] идентификатор объекта владельца
	'	oPropMD - [in] метаданные свойства
	'	oXmlObjectValue - [in] болванка объекта-значения
	Private Sub removeRefInternal(sTypeName, sObjectID, oPropMD, oXmlObjectValue)
		manageRefInternal sTypeName, sObjectID, oPropMD, "remove", oXmlObjectValue
	End Sub

	
	'---------------------------------------------------------------------------
	':Назначение:	Добавляет или удаляет ссылку в/из свойства.
	':Параметры:
	'	sTypeName - [in] тип объекта владельца
	'	sObjectID - [in] идентификатор объекта владельца
	'	oPropMD - [in] метаданные свойства
	'	sAction - [in] действие: add - добавить, remove - удалить
	'	oXmlObjectValue - [in] болванка объекта-значения
	Private Sub manageRefInternal(sTypeName, sObjectID, oPropMD, sAction, oXmlObjectValue)
		Dim oXmlObject	' As IXMLDOMElemnt - объект владелец в пуле
		Dim oProp		' As IXMLDOMElemnt - свойство объекта владельца
		
		' если свойство скалярное, то действие "добавить" (add) надо трактовать как "заменить" (set)
		If oPropMD.getAttribute("cp") = "scalar" And sAction = "add" Then
			sAction = "set"
		End If
		Set oXmlObject = m_oXmlObjectPool.selectSingleNode(sTypeName & "[@oid='" & sObjectID & "']")
		If oXmlObject Is Nothing Then
			' объекта которому хотим пропатчить свойство нет в пуле - создадим "отложенное действие"
			addPendingAction sTypeName, sObjectID, oPropMD, sAction, oXmlObjectValue
		Else
			' объект есть, получим его свойство
			Set oProp = oXmlObject.selectSingleNode( oPropMD.getAttribute("n") )
			If oProp Is Nothing Then
				' объект есть, но свойства нет - ничего не делаем
			ElseIf Not IsNull( oProp.getAttribute("loaded") ) Then
				' объект есть, свойство есть, но оно не прогруженно (следовательно, это массивное свойство)
				addPendingAction sTypeName, sObjectID, oPropMD, sAction, oXmlObjectValue
			Else
				' иначе, все прогужено и можно модифицировать:
				' если свойство скалярное, то сначала очистить. 
				If sAction = "set" Then
					oProp.selectNodes("*").removeAll
				End If
				If sAction = "add" Or sAction ="set" Then
					oProp.appendChild oXmlObjectValue
				ElseIf sAction = "remove" Then
					oProp.selectNodes(oXmlObjectValue.nodeName & "[@oid='" & oXmlObjectValue.getAttribute("oid") & "']").removeAll
				End If
			End If
		End If
	End Sub

	'===========================================================================
	' ОПЕРАЦИИ С ОТЛОЖЕННЫМИ ДЕЙСТВИЯМИ
	
	'---------------------------------------------------------------------------
	' Вычисляет признак наличия отложенных действий
	Private Sub recalculateHasPendingActionsFlag
		m_bHasPendingActions = m_oXmlPendingActions.ChildNodes.Length > 0
	End Sub


	'---------------------------------------------------------------------------
	':Назначение:	Создает в пуле запись об отложенном действии.
	':Параметры:
	'	sTypeName - [in] тип объекта владельца
	'	sObjectID - [in] идентификатор объекта владельца
	'	oPropMD - [in] метаданные свойства
	'	sAction - [in] действие: add - добавить, remove - удалить
	'	oXmlObjectValue - [in] болванка объекта-значения
	Private Sub addPendingAction(sTypeName, sObjectID, oPropMD, sAction, oXmlObjectValue)
		Dim sPropName			' As String - наименование свойства
		Dim oXmlAction			' As IXMLDOMElement - xml-узел action - запись отложенного действия
		Dim sValueOID			' As String - идентификатор объекта-значения
		Dim sReverseActionXPath ' As String - часть xpath  запроса с условие на действие
		Dim oXmlReverseAction	' As IXMLDOMElement - xml-узел action - записи отложенного действия, обратного текущему
		
		sPropName = oPropMD.getAttribute("n") 
		sValueOID = oXmlObjectValue.getAttribute("oid")
		If oPropMD.getAttribute("cp") = "scalar" Then
			m_oXmlPendingActions.selectNodes("*[@ot='" & sTypeName & "' and @oid='" & sObjectID & "' and @prop='" & sPropName & "']").removeAll
		End If
		' сформируем наименование обратного действия
		If sAction = "remove" Then
			sReverseActionXPath = "@action='add' or @action='set'"
		ElseIf sAction = "add" Or sAction = "set" Then
			sReverseActionXPath = "@action='remove'"
		End If
		Set oXmlReverseAction = m_oXmlPendingActions.selectSingleNode("*[@ot='" & sTypeName & "' and @oid='" & sObjectID & "' and @prop='" & sPropName & "' and " & sReverseActionXPath & " and @ref-oid='" & sValueOID & "']")
		If Not oXmlReverseAction Is Nothing Then
			' текущее удаление (добавление) обратное относительно добавления (удаления), 
			' можно просто убрать предыдущее действие, т.е. как бы ничего не делали
			oXmlReverseAction.parentNode.removeChild oXmlReverseAction
			recalculateHasPendingActionsFlag
			Exit Sub
		End If
		' создадим запись об отложенном действии
		Set oXmlAction = m_oXmlPendingActions.appendChild( m_oXmlPendingActions.ownerDocument.createElement("action") )
		oXmlAction.setAttribute "ot", sTypeName
		oXmlAction.setAttribute "oid", sObjectID
		oXmlAction.setAttribute "prop", sPropName
		oXmlAction.setAttribute "action", sAction
		oXmlAction.setAttribute "ref-ot", oXmlObjectValue.tagName
		oXmlAction.setAttribute "ref-oid", sValueOID
		
		recalculateHasPendingActionsFlag
	End Sub

	'---------------------------------------------------------------------------
	':Назначение:	
	'	Выполняет отложенные действия для заданного заданного объекта. 
	':Параметры:
	'	oXmlObject	- [in] As IXMLDOMElement - объект, для которого выполняются отложенные действия (если есть)
	':Примечание:
	'	Для каждого объектного свойства вызываем applyPendingActions
	Private Sub applyPendingActionsForObject(oXmlObject)
		Dim oProp			' As IXMLDOMElement - xml-свойство 
		If Not m_bHasPendingActions Then Exit Sub
		For Each oProp In getObjectPropsOfObject(oXmlObject, False)
			applyPendingActions oXmlObject.tagName, oXmlObject.getAttribute("oid"), oProp
		Next
	End Sub
	
	'---------------------------------------------------------------------------
	':Назначение:	
	'	Выполняет отложенные действия для заданного свойство заданного объекта. 
	'	После выполнения записи отложенных действия из пула удаляются.
	':Параметры:
	'	sTypeName - [in] тип объекта владельца
	'	sObjectID - [in] идентификатор объекта владельца
	'	oProp - [in] свойство объекта владельца, для которого надо выполнить отложенные действия
	Private Sub applyPendingActions(sTypeName, sObjectID, oProp)
		Dim oXmlActions		' As IXMLDOMNodeList - коллекция записей отложенных действия (узлы action)
		Dim oXmlAction		' As IXMLDOMELement - xml-узел записи отложенного действия (action)
		Dim sAction			' As String - наименование действия (add, remove)
		Dim sValueOID		' As String - идентификатор объекта-значения
		
		Set oXmlActions = m_oXmlPendingActions.selectNodes("*[@ot='" & sTypeName & "' and @oid='" & sObjectID & "' and @prop='" & oProp.tagName & "']")
		If oXmlActions.length > 0 Then
			' применим "отложенные действия"
			For Each oXmlAction In oXmlActions
				sAction = oXmlAction.getAttribute("action")
				sValueOID = oXmlAction.getAttribute("ref-oid")
				If sAction = "remove" Then
					oProp.selectNodes("*[@oid='" & sValueOID & "']").removeAll
				ElseIf sAction = "set" Then
					oProp.selectNodes("*").removeAll
					oProp.appendChild X_CreateObjectStub( oXmlAction.getAttribute("ref-ot"), sValueOID )
				ElseIf sAction = "add" Then
					oProp.appendChild X_CreateObjectStub( oXmlAction.getAttribute("ref-ot"), sValueOID )
				End If
			Next
			oXmlActions.removeAll
			recalculateHasPendingActionsFlag
		End If
	End Sub

	' /ОПЕРАЦИИ С ОТЛОЖЕННЫМИ ДЕЙСТВИЯМИ
	'===========================================================================
	
	'---------------------------------------------------------------------------
	':Назначение:	
	'	Возвращает коллекцию xml-свойств переданного объекта,
	'	удовлетворяющих фильтру, примененного к XPath-запросу получения метаописания свойств
	':Параметры:
	'	oXmlObject		- [in] xml-объект
	'	sXPathFilter	- [in] фильтр xpath-запроса
	'	bOnlyNotEmpty	- [in] As Boolean - признак "выбирать только непустые свойства" (False - все)
	Private Function getPropsOfObjectByMDFilter(oXmlObject, sXPathFilter, bOnlyNotEmpty)
		Dim oPropMD		' As IXMLDOMElement - узел метаописания свойства (ds:prop)
		Dim sXPath		' As String - формируемый фильтр xpath-запроса для получения коллекции свойств
		If Len("" & sXPathFilter) > 0 Then sXPathFilter = "[" & sXPathFilter & "]"
		For Each oPropMD In X_GetTypeMD(oXmlObject.tagName).selectNodes("ds:prop" & sXPathFilter)
			If Not IsEmpty(sXPath) Then sXPath = sXPath & " | "
			sXPath = sXPath & oPropMD.getAttribute("n")
			If bOnlyNotEmpty Then sXPath = sXPath & "[*[@oid]]"
		Next
		' если xpath не сформирован, сформируем такой, чтобы ничего не найти, т.к. пустую строку нельзя передавать
		If IsEmpty(sXPath) Then sXPath = "dontfind[1=0]"
		Set getPropsOfObjectByMDFilter = oXmlObject.selectNodes(sXPath)
	End Function
		
	'---------------------------------------------------------------------------
	':Назначение:	
	'	Возвращает коллекцию объектных xml-свойств переданного объекта
	':Параметры:
	'	oXmlObject		- [in] xml-объект
	'	bOnlyNotEmpty	- [in] As Boolean - признак "выбирать только непустые свойства" (False - все)
	Private Function getObjectPropsOfObject(oXmlObject, bOnlyNotEmpty)
		Set getObjectPropsOfObject = getPropsOfObjectByMDFilter(oXmlObject, "@vt='object'", bOnlyNotEmpty)
	End Function
	
	'---------------------------------------------------------------------------
	':Назначение:	
	'	Возвращает коллекцию скалярных объектных xml-свойств переданного объекта
	':Параметры:
	'	oXmlObject		- [in] As IXMLDOMElement - xml-объект
	'	bOnlyNotEmpty	- [in] As Boolean - признак "выбирать только непустые свойства" (False - все)
	Private Function getScalarObjectPropsOfObject(oXmlObject, bOnlyNotEmpty)
		Set getScalarObjectPropsOfObject = getPropsOfObjectByMDFilter(oXmlObject, "@vt='object' and @cp='scalar'", bOnlyNotEmpty)
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.SetPropertyValue
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE SetPropertyValue>
	':Назначение:	Устанавливает значение необъектного свойства.
	':Параметры:
	'	oXmlProperty - [in] XML-свойство объекта в пуле, IXMLDOMElement
	'	vValue - [in] типизированное значение, задаваемое для свойства
	':Результат:
	'	True - если значение свойства изменилось (и атрибут dirty для свойства 
	'	установлен), иначе - False.
	':Сигнатура:
	'	Public Function SetPropertyValue(
	'		oXmlProperty [As IXMLDOMElement], 
	'		ByVal vValue [As Variant]
	'	) [As Boolean]
	Public Function SetPropertyValue(oXmlProperty, ByVal vValue)
		Dim vValueInXml		' As Variant - значение свойства в XML-данных объекта-владельца
		
		SetPropertyValue = False
		vValueInXml = oXmlProperty.nodeTypedValue
		' т.к. переносы строк MSXML храняться как 0A (chr(10)), а не как 0D0A (chr(13)+chr(10)=vbNewLine),
		' то в переданном значении удалим символы 0D
		If oXmlProperty.dataType = "string" And hasValue(vValue) Then
			vValue = Replace(vValue, vbNewLine, chr(10))
		End If
		' проверим, что свойство модифицировалось
		If IsNull(vValue) Then
			If IsNull(vValueInXml) Then Exit Function
			oXmlProperty.text = ""
		ElseIf Not IsNull(vValueInXml) Then
			If vValueInXml = vValue Then Exit Function
		End If
	
		' Установка значения выполняется под контролем ошибок. 
		' если IsNull(vValue), то значение мы сбросили выше
		If Not IsNull(vValue) Then
			oXmlProperty.nodeTypedValue = vValue
		End If
		SetXmlPropertyDirty oXmlProperty
		SetPropertyValue = True
	End Function
End Class


'===============================================================================
'@@GetObjectEventArgsClass
'<GROUP !!CLASSES_x-pool><TITLE GetObjectEventArgsClass>
':Назначение:	Класс параметров события "GetObject".
':Примечание:	Событие "GetObject" генерируется при загрузке объекта с сервера.
'
'@@!!MEMBERTYPE_Methods_GetObjectEventArgsClass
'<GROUP GetObjectEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_GetObjectEventArgsClass
'<GROUP GetObjectEventArgsClass><TITLE Свойства>
Class GetObjectEventArgsClass
	'@@GetObjectEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_GetObjectEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@GetObjectEventArgsClass.XmlObject
	'<GROUP !!MEMBERTYPE_Properties_GetObjectEventArgsClass><TITLE XmlObject>
	':Назначение:	XML c данными загруженного объекта, до помещения в пул.
	':Сигнатура:	Public XmlObject [As IXMLDOMElement]
	Public XmlObject
	
	'@@GetObjectEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_GetObjectEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As GetObjectEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@GetObjectConflictEventArgsClass
'<GROUP !!CLASSES_x-pool><TITLE GetObjectConflictEventArgsClass>
':Назначение:	Класс параметров события "GetObjectConflict".
':Примечание:	
'	Событие "GetObject" генерируется при загрузке данных свойства объекта, 
'	при возникновении конфликта загруженных данных с данными, представленными 
'	в пуле.
'
'@@!!MEMBERTYPE_Methods_GetObjectConflictEventArgsClass
'<GROUP GetObjectConflictEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_GetObjectConflictEventArgsClass
'<GROUP GetObjectConflictEventArgsClass><TITLE Свойства>
Class GetObjectConflictEventArgsClass
	'@@GetObjectConflictEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_GetObjectConflictEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@GetObjectConflictEventArgsClass.LoadedProperty
	'<GROUP !!MEMBERTYPE_Properties_GetObjectConflictEventArgsClass><TITLE LoadedProperty>
	':Назначение:	Свойство, в результате прогрузки которого произошел конфликт.
	':Сигнатура:	Public LoadedProperty [As IXMLDOMElement]
	Public LoadedProperty
	
	'@@GetObjectConflictEventArgsClass.ObjectInPool
	'<GROUP !!MEMBERTYPE_Properties_GetObjectConflictEventArgsClass><TITLE ObjectInPool>
	':Назначение:	Объект, вызвавший конфиликт, в пуле.
	':Сигнатура:	Public ObjectInPool [As IXMLDOMElement]
	Public ObjectInPool
	
	'@@GetObjectConflictEventArgsClass.ObjectFromServer
	'<GROUP !!MEMBERTYPE_Properties_GetObjectConflictEventArgsClass><TITLE ObjectFromServer>
	':Назначение:	Объект, вызвавший конфиликт, пришедший с сервера.
	':Сигнатура:	Public ObjectFromServer [As IXMLDOMElement]
	Public ObjectFromServer

	'@@GetObjectConflictEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_GetObjectConflictEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As GetObjectConflictEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@DeleteObjectConflictEventArgsClass
'<GROUP !!CLASSES_x-pool><TITLE DeleteObjectConflictEventArgsClass>
':Назначение:	Класс параметров события "DeleteObjectConflict".
':Примечание:	
'	Событие "DeleteObjectConflict" генерируется при попытке удаления, 
'	в случае обнаружения "ссылочного конфликта" удаляемых данных.
'	Проверка конфликта (и, соответственно, генерация события) выполняется при 
'	вызове метода XObjectPoolClass.MarkObjectAsDeleted.
'
'@@!!MEMBERTYPE_Methods_DeleteObjectConflictEventArgsClass
'<GROUP DeleteObjectConflictEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass
'<GROUP DeleteObjectConflictEventArgsClass><TITLE Свойства>
Class DeleteObjectConflictEventArgsClass
	'@@DeleteObjectConflictEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel

	'@@DeleteObjectConflictEventArgsClass.SilentMode
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE SilentMode>
	':Назначение:	Признак "тихой работы".
	':Примечание: 
	'	Если свойство устанвлено в значение True, то прикладной обработчик события
	'	должен блокировать вывод каких-либо сообщений для пользователя.
	'	Свойство задается в False, если удаление происходит с помощью операции, 
	'	инициализированной пользователем.
	':Сигнатура:	Public SilentMode [As Boolean]
	Public SilentMode

	'@@DeleteObjectConflictEventArgsClass.AllReferences
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE AllReferences>
	':Назначение:	Список всех ссылок на удаляемые объекты.
	':Сигнатура:	Public AllReferences [As ObjectArrayListClass]
	Public AllReferences

	'@@DeleteObjectConflictEventArgsClass.NotNullReferences
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE NotNullReferences>
	':Назначение:	Список ссылок на удаляемые объекты из обязательных свойств.
	':Сигнатура:	Public NotNullReferences [As ObjectArrayListClass]
	Public NotNullReferences

	'@@DeleteObjectConflictEventArgsClass.ObjectsToDelete
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE ObjectsToDelete>
	':Назначение:	Список ссылок на объекты в пуле, которые надо пометить как удаляемые.
	':Сигнатура:	Public ObjectsToDelete [As ObjectArrayListClass]
	Public ObjectsToDelete

	'@@DeleteObjectConflictEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE ReturnValue>
	':Назначение:	Результат, возвращаемый обработчиком события. 
	':Примечание:	Здесь - признак продолжения / прерывания процедуры удаления: 
	'				True - продолжить, False - прервать.
	':Сигнатура:	Public ReturnValue [As Boolean]
	Public ReturnValue

	'@@DeleteObjectConflictEventArgsClass.SourceXmlProperty
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE SourceXmlProperty>
	':Назначение:	XML-свойство, из которого было запущено удаление.
	':Сигнатура:	Public SourceXmlProperty [As IXMLDOMElement]
	Public SourceXmlProperty

	'@@DeleteObjectConflictEventArgsClass.PropertiesToUpdate
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE PropertiesToUpdate>
	':Назначение:	Коллекция свойств, из которых происходит удаление ссылок.
	':Примечание:	Используется для последующего обновления представлений этих свойств.
	':Сигнатура:	Public PropertiesToUpdate [As ObjectArrayListClass]
	Public PropertiesToUpdate
	
	' Внутренний метод инициализации экземпляра, "конструктор".
	Private Sub Class_Initialize
		ReturnValue = True
		Set PropertiesToUpdate = Nothing
	End Sub

	'@@DeleteObjectConflictEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_DeleteObjectConflictEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As DeleteObjectConflictEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class
