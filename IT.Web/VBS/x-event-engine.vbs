Option Explicit
'===============================================================================
'@@!!FILE_x-event-engine
'<GROUP !!SYMREF_VBS>
'<TITLE x-event-engine - Функционал обработки событий>
':Назначение:	Функционал обработки событий.
'===============================================================================
'@@!!FUNCTIONS_x-event-engine
'<GROUP !!FILE_x-event-engine><TITLE Функции и процедуры>
'@@!!CLASSES_x-event-engine
'<GROUP !!FILE_x-event-engine><TITLE Классы>


'===============================================================================
'@@EventArgsClass
'<GROUP !!CLASSES_x-event-engine><TITLE EventArgsClass>
':Назначение:	"Базовый" класс параметров события. 
':Примечание:	ReturnValue - необязательное поле.
'
'@@!!MEMBERTYPE_Methods_EventArgsClass
'<GROUP EventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_EventArgsClass
'<GROUP EventArgsClass><TITLE Свойства>
Class EventArgsClass
	'@@EventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_EventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel				
	
	'@@EventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_EventArgsClass><TITLE ReturnValue>
	':Назначение:	Данные, возвращаемые обработчиком события.
	':Сигнатура:	Public ReturnValue [As Variant]
	Public ReturnValue
	
	'@@EventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_EventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As EventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@CommonEventArgsClass
'<GROUP !!CLASSES_x-event-engine><TITLE CommonEventArgsClass>
':Назначение:	Общие параметры событий для операции меню.
'
'@@!!MEMBERTYPE_Methods_CommonEventArgsClass
'<GROUP CommonEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_CommonEventArgsClass
'<GROUP CommonEventArgsClass><TITLE Свойства>
Class CommonEventArgsClass
	'@@CommonEventArgsClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE ObjectID>
	':Назначение:	Идентификатор объекта.
	':Сигнатура:	Public ObjectID [As String]	
	Public ObjectID

	'@@CommonEventArgsClass.ObjectType
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE ObjectType>
	':Назначение:	Наименование типа объекта
	':Сигнатура:	Public ObjectType [As String]
	Public ObjectType

	'@@CommonEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE ReturnValue>
	':Назначение:	Возвращаемое значение. Смысл зависит от контекста.
	':Сигнатура:	Public ReturnValue [As Variant]
	Public ReturnValue

	'@@CommonEventArgsClass.Metaname
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE Metaname>
	':Назначение:	Метаимя мастера / редактора / дерева / списка
	':Сигнатура:	Public Metaname [As String]
	Public Metaname

	'@@CommonEventArgsClass.AddEventArgs
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE AddEventArgs>
	':Назначение:	Дополнительные параметры события.
	':Сигнатура:	Public AddEventArgs [As Variant]
	Public AddEventArgs

	'@@CommonEventArgsClass.Values
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE Values>
	':Назначение:	Коллекция параметров пункта меню.
	':Сигнатура:	Public Values [As Scripting.Dictionary]
	Public Values

	'@@CommonEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel

	'@@CommonEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_CommonEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As CommonEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@DeleteObjectEventArgsClass
'<GROUP !!CLASSES_x-event-engine><TITLE DeleteObjectEventArgsClass>
':Назначение:	Параметры событий, связанным с удалением объекта (операция DoDelete).
'
'@@!!MEMBERTYPE_Methods_DeleteObjectEventArgsClass
'<GROUP DeleteObjectEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_DeleteObjectEventArgsClass
'<GROUP DeleteObjectEventArgsClass><TITLE Свойства>
Class DeleteObjectEventArgsClass
	'@@DeleteObjectEventArgsClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE ObjectID>
	':Назначение:	Идентификатор объекта.
	':Сигнатура:	Public ObjectID [As String]
	Public ObjectID

	'@@DeleteObjectEventArgsClass.ObjectType
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE ObjectType>
	':Назначение:	Наименование типа объекта 
	':Сигнатура:	Public ObjectType [As String]
	Public ObjectType

	'@@DeleteObjectEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE ReturnValue>
	':Назначение:	Возвращаемое значение. Смысл зависит от контекста. 
	':Сигнатура:	Public ReturnValue [As Variant]
	Public ReturnValue

	'@@DeleteObjectEventArgsClass.Count
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE Count>
	':Назначение:	Количество удаляемых / удаленных объектов.
	':Сигнатура:	Public Count [As Integer]
	Public Count

	'@@DeleteObjectEventArgsClass.AddEventArgs
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE AddEventArgs>
	':Назначение:	Дополнительные параметры события.
	':Сигнатура:	Public AddEventArgs [As Variant]
	Public AddEventArgs

	'@@DeleteObjectEventArgsClass.Values
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE Values>
	':Назначение:	Коллекция параметров пункта меню.
	':Сигнатура:	Public Values [As Scripting.Dictionary]
	Public Values

	'@@DeleteObjectEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel	[As Boolean]
	Public Cancel

	'@@DeleteObjectEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_DeleteObjectEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As DeleteObjectEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@AccelerationEventArgsClass
'<GROUP !!CLASSES_x-event-engine><TITLE AccelerationEventArgsClass>
':Назначение:	Параметры события Accel.
'
'@@!!MEMBERTYPE_Methods_AccelerationEventArgsClass
'<GROUP AccelerationEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_AccelerationEventArgsClass
'<GROUP AccelerationEventArgsClass><TITLE Свойства>
Class AccelerationEventArgsClass
	'@@AccelerationEventArgsClass.keyCode
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE keyCode>
	':Назначение:	Код клавиши / символа.
	':Сигнатура:	Public keyCode [As Byte]
	Public keyCode

	'@@AccelerationEventArgsClass.altKey
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE altKey>
	':Назначение:	Признак нажатия клавиши Alt.
	':Сигнатура:	Public altKey [As Boolean]
	Public altKey

	'@@AccelerationEventArgsClass.ctrlKey
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE ctrlKey>
	':Назначение:	Признак нажатия клавиши Ctrl.
	':Сигнатура:	Public ctrlKey [As Boolean]
	Public ctrlKey

	'@@AccelerationEventArgsClass.shiftKey
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE shiftKey>
	':Назначение:	Признак нажатия клавиши Shift.
	':Сигнатура:	Public shiftKey [As Boolean]
	Public shiftKey

	'@@AccelerationEventArgsClass.DblClick
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE DblClick>
	':Назначение:	Признак двойного клика мыши.
	':Сигнатура:	Public DblClick [As Boolean]
	Public DblClick

	'@@AccelerationEventArgsClass.MenuPosX
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE MenuPosX>
	':Назначение:	Экранная X-координата для отображения выпадающего меню с операциями, 
	'				удовлетворяющими нажатой комбинации
	':Сигнатура:	Public MenuPosX [As Long]
	Public MenuPosX

	'@@AccelerationEventArgsClass.MenuPosY
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE MenuPosY>
	':Назначение:	Экранная Y-координата для отображения выпадающего меню с операциями, 
	'				удовлетворяющими нажатой комбинации
	':Сигнатура:	Public MenuPosY [As Long]
	Public MenuPosY
	
	'@@AccelerationEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel

	'@@AccelerationEventArgsClass.Processed
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE Processed>
	':Назначение:	Признак того, что нажатая комбинация обработана.
	':Сигнатура:	Public Processed [As Boolean]
	Public Processed

	'@@AccelerationEventArgsClass.Source
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE Source>
	':Назначение:	Ссылка на редактор свойства, в котором была нажата комбинация клавиш.
	':Сигнатура:	Public Source [As IXPropertyEditor]
	Public Source

	'@@AccelerationEventArgsClass.HtmlSource
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE HtmlSource>
	':Назначение:	HTML-элемент, вызывавший генерацию события.
	':Сигнатура:	Public HtmlSource [As HTMLDOMElement]
	Public HtmlSource
		
	'@@AccelerationEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_AccelerationEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As AccelerationEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'==============================================================================
' Создает экземпляр AccelerationEventArgsClass на основе текущего html-события (window.event)
Function CreateAccelerationEventArgsForHtmlEvent
	With New AccelerationEventArgsClass
		.keyCode	= window.event.keyCode
		.altKey		= window.event.altKey
		.ctrlKey	= window.event.ctrlKey
		.shiftKey	= window.event.shiftKey
		Set .HtmlSource = window.event.srcElement
		Set CreateAccelerationEventArgsForHtmlEvent = .Self()
	End With	
End Function


'==============================================================================
' Создает экземпляр AccelerationEventArgsClass на основе параметров ActiveX-события onKeyUp
Function CreateAccelerationEventArgsForActiveXEvent(nKeyCode, nFlags)
	With New AccelerationEventArgsClass
		.keyCode	= nKeyCode
		.altKey		= CBool(nFlags and KF_ALTLTMASK)
		.ctrlKey	= CBool(nFlags and KF_CTRLMASK)
		.shiftKey	= CBool(nFlags and KF_SHIFTMASK)
		Set CreateAccelerationEventArgsForActiveXEvent = .Self()
	End With
End Function


'==============================================================================
' Создает экземпляр AccelerationEventArgsClass на основе явно заданных параметров
Function CreateAccelerationEventArgs(keyCode, altKey, ctrlKey, shiftKey)
	With New AccelerationEventArgsClass
		.keyCode	= keyCode
		.altKey		= altKey
		.ctrlKey	= ctrlKey
		.shiftKey	= shiftKey
		Set CreateAccelerationEventArgs = .Self()
	End With	
End Function


'===============================================================================
'@@GetRestrictionsEventArgsClass
'<GROUP !!CLASSES_x-event-engine><TITLE GetRestrictionsEventArgsClass>
':Назначение:	
'	Параметры события "GetRestrictions", генерируемого в различных  контекстах 
'	(список, редактор). Используется для получения коллекции параметров для 
'	источника данных (либо от фильтра, либо заданной прикладным кодом).
'
'@@!!MEMBERTYPE_Methods_GetRestrictionsEventArgsClass
'<GROUP GetRestrictionsEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass
'<GROUP GetRestrictionsEventArgsClass><TITLE Свойства>
Class GetRestrictionsEventArgsClass
	'@@GetRestrictionsEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@GetRestrictionsEventArgsClass.UrlParams
	'<GROUP !!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass><TITLE UrlParams>
	':Назначение:	Параметры страницы.
	':Сигнатура:	Public UrlParams [As String]
	Public UrlParams
	
	'@@GetRestrictionsEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass><TITLE ReturnValue>
	':Назначение:	Параметры загрузчика.
	':Сигнатура:	Public ReturnValue [As String]
	Public ReturnValue
	
	'@@GetRestrictionsEventArgsClass.Description
	'<GROUP !!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass><TITLE Description>
	':Назначение:	Описание ограничений.
	':Сигнатура:	Public Description [As String]
	Public Description
	
	'@@GetRestrictionsEventArgsClass.ExcludeNodes
	'<GROUP !!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass><TITLE ExcludeNodes>
	':Назначение:	Строка со списком исключаемых из иерархии узлов. См. комментарий к [x-utils.vbs]SelectFromTreeDialogClass.ExcludeNodes
	':Сигнатура:	Public ExcludeNodes [As String]
	Public ExcludeNodes
	
	'@@GetRestrictionsEventArgsClass.StayOnCurrentPage
	'<GROUP !!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass><TITLE StayOnCurrentPage>
	':Назначение:	Признак, задающий необходимость остаться на текущей странице (при использовании пейджинга).
	':Сигнатура:	Public StayOnCurrentPage [As Boolean]
	Public StayOnCurrentPage
	
	'@@GetRestrictionsEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_GetRestrictionsEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As GetRestrictionsEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'==============================================================================
' Фабричная функция. Создает экземпляр XDelegate
Function X_CreateDelegate(vObject, sMethodName)
	Dim oDelegate	' As CROC.Delegate
	Set oDelegate = New XDelegate
	oDelegate.Init vObject, sMethodName
	Set X_CreateDelegate = oDelegate 
End Function


'==============================================================================
' Фабричная функция. Создает экземпляр XEventEngine
Function X_CreateEventEngine
	Set X_CreateEventEngine = New XEventEngine
End Function


Dim x_oGlobalStaticHandlers		' As Scripting.Dictionary - словарь глобальных обработчиков

'===============================================================================
'@@X_RegisterStaticHandler
'<GROUP !!FUNCTIONS_x-event-engine><TITLE X_RegisterStaticHandler>
':Назначение:	
'	Регистрирует указанную процедуру в качестве глобального обработчика события.
':Параметры:
'	sHandlerStrongName - [in] наименование глобальной процедуры, под которой 
'			регистрируется процедура, заданная параметром sProcName
'	sProcName - [in] наименование процедуры, регистрируемой в качестве обработчика
':Примечание:
'	Позволяет статически регистрировать несколько обработчиков событий из разных 
'	подгружаемых скриптов.
':См. также:
'	X_GetRegisteredStaticHandlers, <P/>
'	<LINK cee-6, Статическое связывание с помощью алиасов />
':Сигнатура:
'	Sub X_RegisterStaticHandler( sHandlerStrongName [As String], sProcName [As String] )
Sub X_RegisterStaticHandler(sHandlerStrongName, sProcName)
	Dim aProcNames	' As Array
	If IsEmpty(x_oGlobalStaticHandlers) Then
		Set x_oGlobalStaticHandlers = CreateObject("Scripting.Dictionary")
	End If
	aProcNames = x_oGlobalStaticHandlers.Item(sHandlerStrongName)
	If IsEmpty(aProcNames) Then
		aProcNames = Array()
	End If
	' добавим наименовнаие процедуры в конец массива
	arrayAddition sProcName, aProcNames
	x_oGlobalStaticHandlers.Item(sHandlerStrongName) = aProcNames
End Sub


'===============================================================================
'@@X_GetRegisteredStaticHandlers
'<GROUP !!FUNCTIONS_x-event-engine><TITLE X_GetRegisteredStaticHandlers>
':Назначение:	
'	Возвращает массив наименований процедур, зарегистрированных под "алиасом" 
'	обработчика, заданым параметром sHandlerStrongName.
':Параметры:
'	sHandlerStrongName - [in] наименование "алиаса" обработчика
':Результат:
'	Массив наименований процедур, зарегистрированных под указанным наименованием-
'	"алиасом". Если таких процедур нет, функция возвращает пустой массив.
':См. также:
'	X_RegisterStaticHandler, <P/>
'	<LINK cee-6, Статическое связывание с помощью алиасов />
':Сигнатура:
'	Function X_GetRegisteredStaticHandlers( sHandlerStrongName [As String] ) [As Array]
Function X_GetRegisteredStaticHandlers(sHandlerStrongName)
	If IsEmpty(x_oGlobalStaticHandlers) Then
		X_GetRegisteredStaticHandlers = Array()
	ElseIf  x_oGlobalStaticHandlers.Exists(sHandlerStrongName) Then
		X_GetRegisteredStaticHandlers = x_oGlobalStaticHandlers.Item(sHandlerStrongName)
		If IsEmpty(X_GetRegisteredStaticHandlers) Then
			X_GetRegisteredStaticHandlers = Array()
		End If
	Else
		X_GetRegisteredStaticHandlers = Array()
	End If
End Function


'==============================================================================
' Вызывает все обработчики для заданного события
' Процедура вынесена из класса XEventEngine для того, чтобы не увеличивать глубину стэка объектных вызовов (через ".")
'	[in] oEventEngine As XEventEngine - 
'	[in] sEventName As String - наименование события
'	[in] oSender As Object - экземпляр какого объекта, который будет передан в обработчики события
'	[in] oEventArgs As Object - аргументы события
Sub XEventEngine_FireEvent(oEventEngine, sEventName, oSender, oEventArgs)
	Dim aDelegates		' As XDelegate()
	Dim i

	If Not IsNothing(oEventArgs) Then
		oEventArgs.Cancel = False
	End If
	If Not oEventEngine.Internal_Subscribers.Exists(sEventName) Then Exit Sub
	aDelegates = oEventEngine.Internal_Subscribers.Item(sEventName)
	For i=0 to UBound(aDelegates)
		XDelegate_Execute aDelegates(i), oSender, oEventArgs
		If Not IsNothing(oEventArgs) Then
			If oEventArgs.Cancel Then
				Exit For
			End If
		End If
	Next
End Sub


'==============================================================================
' Выполнение делегата (код, представленный экземпляром XDelegate).
' Процедура вынесена из класса XDelegate для того, чтобы не увеличивать глубину стэка объектных вызовов (через ".")
'	[in] oDelegate As XDelegate - делегат
'	[in] oSender As Object - экземпляр какого объекта, который будет передан в обработчики события
'	[in] oEventArgs As Object - аргументы события
Sub XDelegate_Execute(oDelegate, oSender, oEventArgs)
	Dim oObjectRef
	With oDelegate
		If .IsObjectRef Then
			' вызов метода объекта
			Set oObjectRef = .ObjectRef
			Execute "oObjectRef." & .MethodName & " oSender, oEventArgs"
		ElseIf .IsMethodRef Then
			' вызов глобальной процедуры через ссылку, полученную от GetRef
			Set oObjectRef = .MethodRef
			oObjectRef oSender, oEventArgs
		Else
			' вызов глобальной процедуры по наименованию
			Execute .MethodName & " oSender, oEventArgs"
		End If
	End With
End Sub


'==============================================================================
' Класс инкапсулирует работу с обработчиками событий. Позволяет для некоторого 
'	события хранить массив обработчиков.
' ВНИМАНИЕ:
' Из-за ошибки VBScript-runtime класс не содержит метода FireEvent - он вынесен 
'	в глобальную процедуру XEventEngine_FireEvent.
' Сделано это для того, чтобы не увеличивать стэк объектных вызовов, превышение 
'	которым глубины 14 приводит к "stack overflow at line 0"
Class XEventEngine
	Private m_oSubscribers		' As New Scripting.Dictionary - словарь массивов подписчиков на события 
								' (подписчик представлен экземпляром CROC.Delegate)

	'==============================================================================
	' "Конструктор"
	Private Sub Class_Initialize
		Set m_oSubscribers = CreateObject("Scripting.Dictionary")
		m_oSubscribers.CompareMode = vbTextCompare
	End Sub

	'==============================================================================
	' Возвращает словарь подписчиков. Для внутренного использования!
	Public Property Get Internal_Subscribers
		Set Internal_Subscribers = m_oSubscribers
	End Property

	'==============================================================================
	' Освобождает все ссылки на объекты
	Sub Dispose
		Dim oDlg
		Dim o		' временная переменная для предотвращения колец
		Dim i
		On Error Resume Next
		Set o = m_oSubscribers
		Set m_oSubscribers = Nothing
		For Each oDlg In o.Items
			For i= 0 To UBound(oDlg)
				oDlg(i).Dispose
			Next
		Next
	End Sub

	'==============================================================================
	' Добавляет обработчик события
	Sub AddHandlerForEvent(sEventName, vObj, sMethodName)
		InsertHandlerForEvent -1, sEventName, vObj, sMethodName
	End Sub

	'==============================================================================
	' Добавляет обработчик события, если для данного события не заданы обработчики
	'	[retval] True - обработчик добавлен, False - обработчик не добавлен
	Function AddHandlerForEventWeakly(sEventName, vObj, sMethodName )
		AddHandlerForEventWeakly = False
		If IsHandlerExists(sEventName) Then Exit Function
		InsertHandlerForEvent -1, sEventName, vObj, sMethodName
		AddHandlerForEventWeakly = True
	End Function

	'==============================================================================
	' Добавляет обработчик события
	Sub AddDelegateForEvent(sEventName, oDelegate)
		InsertDelegateForEvent -1, sEventName, oDelegate
	End Sub

	'==============================================================================
	' Вставляет обработчик события в массив обработчиков на место с заданным индексом
	Sub InsertHandlerForEvent(ByVal nIndex, sEventName, vObj, sMethodName)
		Dim oSubscriber		' As CROC.Delegate
		Set oSubscriber = X_CreateDelegate(vObj, sMethodName)
		
		InsertDelegateForEvent nIndex, sEventName, oSubscriber		
	End Sub

	'==============================================================================
	' Вставляет обработчик события в массив обработчиков на место с заданным индексом
	Sub InsertDelegateForEvent(ByVal nIndex, sEventName, oDelegate)
		Dim aHandlers		' As Array
		If m_oSubscribers.Exists(sEventName) Then
			aHandlers = m_oSubscribers.Item(sEventName)
		End If
				
		insertRefInfoArray aHandlers, nIndex, oDelegate
		m_oSubscribers.Item(sEventName) = aHandlers
	End Sub

	'==============================================================================
	' Удаляет всех подписчиков для заданного события и добавляет заданный
	Sub ReplaceHandlerForEvent(sEventName, vObj, sMethodName)
		RemoveAllHandlersForEvent sEventName
		AddHandlerForEvent sEventName, vObj, sMethodName
	End Sub

	'==============================================================================
	' Удаляет всех подписчиков для заданного события и добавляет заданный
	Sub ReplaceDelegateForEvent(sEventName, oDelegate)
		RemoveAllHandlersForEvent sEventName
		AddDelegateForEvent sEventName, oDelegate
	End Sub

	'==============================================================================
	' Удаляет заданного подписчика от заданного события
	Sub RemoveHandlerForEvent(sEventName, vObj, sMethodName)
		Dim oSubscriber		' As CROC.Delegate
		Dim aSubscribers	' As Array	- массив обработчиков (экземпляров CROC.Delegate) для события
		Dim i
		If m_oSubscribers.Exists(sEventName) Then
			Set oSubscriber = X_CreateDelegate(vObj, sMethodName)
			aSubscribers = m_oSubscribers.Item(sEventName)
			For i=0 To UBound(aSubscribers )
				If aSubscribers(i).IsEquals(oSubscriber) Then
					removeArrayItemByIndex aSubscribers, i
					Exit Sub
				End If
			Next
		End If
	End Sub

	'==============================================================================
	' Удаляет всех подписчиков для заданного события
	Public Sub RemoveAllHandlersForEvent(sEventName)
		m_oSubscribers.Item(sEventName) = Array()
	End Sub

	'==============================================================================
	' Удаляет всех подписчиков для всех событий
	Public Sub Clear
		m_oSubscribers.RemoveAll
	End Sub

	'==============================================================================
	' Возвращает массив обработчиков для события. Если обработчиков нет, возвращается пустой массив
	Public Function GetHandlersForEvent(sEventName)	' As Array
		GetHandlersForEvent = Array()
		If Not m_oSubscribers.Exists(sEventName) Then Exit Function
		GetHandlersForEvent  = m_oSubscribers.Item(sEventName)
	End Function


	'==============================================================================
	' Инициализирует коллекцию обработчиков событий по маске имени процедуры - т.н. "статический биндинг"
	' Для каждого события из переданного списка ищется глобальная процедура/функция с наименованием {префис}{наименование_события}.
	' Если процедура/функция существует, то она _добавляется_ как обработчик события.
	'	[in] sEventsList - список наименований событий разделенных запятой
	'	[in] sPrefix	 - префикс наименования глобальных процедур/функций. Например, usrXList_On
	Public Sub InitHandlers(ByVal sEventsList, sPrefix)
		InitHandlersEx sEventsList, sPrefix, False, False
	End Sub


	'==============================================================================
	' Инициализирует коллекцию обработчиков событий по маске имени процедуры - т.н. "статический биндинг"
	' Работает так же как InitHandlers, но более гибко.
	'	[in] sEventsList - список наименований событий разделенных запятой
	'	[in] sPrefix	 - префикс наименования глобальных процедур/функций. Например, usrXList_On
	'	[in] bAddIfEmpty As Boolean - если True, то найденный по маске обработчик добавляется в коллекцию обработчиков 
	'			только в случае, если она пустая. Если False, то обработчик добавляется в любом случае.
	'	[in] bRewrite As Boolean	- если True, то найденный обработчик перезаписывает все предыдущие
	Public Sub InitHandlersEx(ByVal sEventsList, sPrefix, bAddIfEmpty, bRewrite)
		Dim sEventName		' наименование события
		Dim sHandlerName	' наименование обработчика
		Dim sPropName		' наименование процедуры, зарегистрированной в качестве обработчика
		
		' Проинициализируем список обработчиков
		For Each sEventName In Split(sEventsList, ",")
			sHandlerName = sPrefix & sEventName
			If X_IsProcPresented( sHandlerName ) Then
				If bRewrite Then
					ReplaceHandlerForEvent sEventName, Null, sHandlerName
				Else
					' Полное условие такое: Not bAddIfEmpty Or (Not IsHandlerExists( sEventName ) And bAddIfEmpty),
					' однако его можно упростить:
					If Not bAddIfEmpty Or Not IsHandlerExists( sEventName ) Then
						AddHandlerForEvent sEventName, Null, sHandlerName
					End If
				End If
			End If
			If Not bRewrite And Not bAddIfEmpty Then
				' а теперь поищем процедуры, зарегистрированные в качестве обработчика с "волшебным" наименованием в глобальной таблице
				For Each sPropName In X_GetRegisteredStaticHandlers(sHandlerName)
					If X_IsProcPresented( sPropName ) Then
						AddHandlerForEvent sEventName, Null, sPropName
					End if 
				Next
			End If
		Next
	End Sub


	'==============================================================================
	' Возвращает true, если на заданное событие есть подписчики
	Public Function IsHandlerExists(sEventName)
		Dim aDelegates
		Dim i		
		IsHandlerExists = False
		If Not m_oSubscribers.Exists(sEventName) Then Exit Function
		aDelegates = m_oSubscribers.Item(sEventName)
		For i=0 To UBound( aDelegates )
			If Not aDelegates(i) Is Nothing Then 
				IsHandlerExists = True
				Exit Function
			End If
		Next		
	End Function
End class



'==============================================================================
' Класс, хранящий ссылку на какой-то код: процедуру, функцию или метод экземпляра класса
' Для выполнения кода, представленного делегатом, надо использовать XDelegate_Execute
Class XDelegate
	Private m_oObjectRef		' ссылка на объект класса
	Private m_sMethodName		' наименование метода/процедуры/функции
	Private m_oMethodRef		' ссылка на объект, представляющий ссылку на глобальную процедуру, полученную через GetRef

	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		Set m_oObjectRef = Nothing
		Set m_oMethodRef = Nothing
	End Sub
	
	'--------------------------------------------------------------------------
	' Освобождает ссылку на объект
	Public Sub Dispose
		Set m_oObjectRef = Nothing
		Set m_oMethodRef = Nothing
	End Sub


	'--------------------------------------------------------------------------
	' Инициализирует "делегат". Функция/процедура/метод класса должны иметь прототип:
	'	proc(oSender, oEventArg)
	'	[in] vObject - ссылка на объект или наименование глобальной переменной со ссылкой
	'	[in] sMethodName - наименование метода объекта (если он задан), 
	'		либо глобальной функции/процедуры (если объект не задан), 
	'		либо объект, полученный через GetRef(..)
	Sub Init(vObject, vMethodName)
		Set m_oObjectRef = Nothing
		Set m_oMethodRef = Nothing
		If TypeName(vObject)="String" Then
			If Len(vObject)>0 Then
				Execute "Set m_oObjectRef = " & vObject
			End If
			m_sMethodName = vMethodName
		ElseIf IsObject(vMethodName) Then
			' ссылка на глобальную функцию/процедуру
			Set m_oMethodRef = vMethodName
		ElseIf IsObject(vObject) Then
			If Not vObject Is Nothing Then
				Set m_oObjectRef = vObject
			End If
			m_sMethodName = vMethodName
		Else
			' наименование глобальной функции/процедуры
			m_sMethodName = vMethodName
		End If
	End Sub


	'--------------------------------------------------------------------------
	' Возвращает True, если "делегат" представляет ссылку на метод объекта, 
	' иначе False
	Function IsObjectRef()	' As Boolean
		IsObjectRef = Not m_oObjectRef Is Nothing
	End Function


	'--------------------------------------------------------------------------
	' Возвращает ссылку на объект, если "делегат" представляет ссылку на метод объекта, иначе Nothing
	Function ObjectRef		' As Object
		Set ObjectRef = m_oObjectRef
	End Function


	'--------------------------------------------------------------------------
	' Возвращает наименование метода, функции, процедуры
	Function MethodName		' As String
		MethodName = m_sMethodName
	End Function


	'--------------------------------------------------------------------------
	' Возвращает True, если "делегат" представляет ссылку на глобальную процедуру, полученную через GetRef
	Function IsMethodRef
		IsMethodRef = Not m_oMethodRef Is Nothing
	End Function


	'--------------------------------------------------------------------------
	' Возвращает ссылку на функцию, процедуру, полученную через GetRef
	Function MethodRef
		Set MethodRef = m_oMethodRef
	End Function


	'--------------------------------------------------------------------------
	' Сравнивает два объекта XDelegate. Объекты равны, если ссылаются на один и тот же код.
	Function IsEquals(oDelegate)
		IsEquals = False
		If TypeName(oDelegate) <> TypeName(Me) Then Exit Function
		If oDelegate.IsObjectRef Then
			IsEquals = (oDelegate.ObjectRef Is m_oObjectRef And oDelegate.MethodName = m_sMethodName)
		ElseIf oDelegate.IsMethodRef Then
			IsEquals = (oDelegate.MethodRef Is m_oMethodRef)
		ElseIf oDelegate.MethodName = m_sMethodName Then
			IsEquals = True
		End If
	End Function

	'--------------------------------------------------------------------------
	Function Self
		Set Self = Me
	End Function
End Class