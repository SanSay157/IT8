'===============================================================================
'@@!!FILE_x-editor
'<GROUP !!SYMREF_VBS>
'<TITLE x-editor - Базовое обслуживание редактора>
':Назначение:	Базовое обслуживание редактора.
':См. также:	<LINK oe_1, Архитектура редактора />
'===============================================================================
'@@!!CONSTANTS_x-editor
'<GROUP !!FILE_x-editor><TITLE Константы>
'@@!!FUNCTIONS_x-editor
'<GROUP !!FILE_x-editor><TITLE Функции и процедуры>
'@@!!CLASSES_x-editor
'<GROUP !!FILE_x-editor><TITLE Классы>

Option Explicit

'==============================================================================
'@@AFTERERROR_nnnn
'<GROUP !!CONSTANTS_x-editor><TITLE AFTERERROR_nnnn>
':Назначение:	Константы, задающие необходимые действия в случае возникновения ошибки.
':См. также:	SaveObjectErrorEventArgsClass.

'@@AFTERERROR_DISPLAYMSG
'<GROUP AFTERERROR_nnnn>
':Назначение:	Вывести сообщение об ошибке и прервать операцию.
const AFTERERROR_DISPLAYMSG = 0

'@@AFTERERROR_ABORT
'<GROUP AFTERERROR_nnnn>
':Назначение:	Прервать операцию; сообщение об ошибке не выводится.
const AFTERERROR_ABORT = 1

'@@AFTERERROR_RETRY
'<GROUP AFTERERROR_nnnn>
':Назначение:	Повторить операцию.
const AFTERERROR_RETRY = 2	


'==============================================================================
'@@REASON_nnnn
'<GROUP !!CONSTANTS_x-editor><TITLE REASON_nnnn>
':Назначение:	
'	Константы, передаваемые в пользовательские обработчики событий PageEnd, 
'	UnLoad, UnLoading и событий, генерируемых при переключении страниц редактора.
':См. также:	
'	EditorStateChangedEventArgsClass.Reason, GetDataArgsClass.Reason,
'	ObjectEditorClass.WizardGoToNextPage, ObjectEditorClass.WizardGoToPrevPage,
'	ObjectEditorClass.CanSwitchPage, ObjectEditorClass.FetchXmlObject,
'	ObjectEditorClass.OnClose, ObjectEditorClass.OnClosing

'@@REASON_WIZARD_NEXT_PAGE
'<GROUP REASON_nnnn>
':Назначение:	Переход на следущую страницу мастера.
const REASON_WIZARD_NEXT_PAGE = 0

'@@REASON_WIZARD_PREV_PAGE
'<GROUP REASON_nnnn>
':Назначение:	Переход на предыдущую страницу мастера.
const REASON_WIZARD_PREV_PAGE = 1

'@@REASON_OK
'<GROUP REASON_nnnn>
':Назначение:	Нажата кнопка "OK" ("Готово").
const REASON_OK	= 2

'@@REASON_PAGE_SWITCH
'<GROUP REASON_nnnn>
':Назначение:	Произошло переключение страницы (закладки) редактора.
const REASON_PAGE_SWITCH = 3

'@@REASON_CLOSE
'<GROUP REASON_nnnn>
':Назначение:	Закрытие контейнера, в котором располагается редактор.
const REASON_CLOSE = 4


'==============================================================================
'@@XEB_nnnn
'<GROUP !!CONSTANTS_x-editor><TITLE XEB_nnnn>
':Назначение:	
'	Константы, используемые для определения действий над данными, выполняемых
'	редактором при нажатии кнопки "Назад" в режиме мастера.
':См. также:	
'	GetNextPageInfoEventArgsClass.BackMode,
'	ObjectEditorClass.WizardGoToNextPage, ObjectEditorClass.WizardGoToPrevPage

'@@XEB_UNDOCHANGES
'<GROUP XEB_nnnn>
':Назначение:	"Откатить" все изменения данных к предыдущему состоянию.
const XEB_UNDOCHANGES = 0

'@@XEB_DO_NOTHING
'<GROUP XEB_nnnn>
':Назначение:	Ничего не делать (все изменения в данных остаются).
const XEB_DO_NOTHING = 1 

'@@XEB_TRY_GET_DATA
'<GROUP XEB_nnnn>
':Назначение:	Выполнение сбора данных; ошибки, возникающие в процессе сбора 
'				данных, не отображаются (гасятся).
const XEB_TRY_GET_DATA = 2


'==============================================================================
' Классы взаимодействия с IObjectContainerEventsClass
'==============================================================================

' Параметры при вызове метода установки заголовка
Class SetCaptionArgsForIObjectContainerClass
	Public Caption ' Заголовок
End Class

'-------------------------------------------------------------------------------
' Параметры при блокировании/разблокировании управляющих элементов
Class EnableControlsArgsForIObjectContainerClass
	Public Enable ' Признак доступности
End Class

'-------------------------------------------------------------------------------
' Добавление страницы в редакторе
Class AddEditorPageArgsForIObjectContainerClass
	Public PageTitle	' Заголовок
	Public PageID	' Идентификатор
	Public PageHint	' ToolTip
End Class

'-------------------------------------------------------------------------------
' Параметры метода IObjectContainerEventsClass::OnSetWizardOperations
Class SetWizardOperationsArgsClass
	Public bIsLastPage 
	Public bIsFirstPage
	Public EditorPage	' As EditorPageClass - экземпляр текущей страницы
	
	Public Function Self()
		Set  Self = Me
	End Function
End Class

'-------------------------------------------------------------------------------
' Параметры метода IObjectContainerEventsClass::OnSetEditorOperations
Class SetEditorOperationsArgsClass
	Public EditorPage	' As EditorPageClass - экземпляр текущей страницы
	
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@ObjectEditorInitializationParametersClass
'<GROUP !!CLASSES_x-editor><TITLE ObjectEditorInitializationParametersClass>
':Назначение:	
'	Класс представляет собой структуру, используемую для передачи параметров
'	инициализации экземпляра редактора ObjectEditorClass.
':См. также:	
'	ObjectEditorClass, IObjectContainerEventsClass
'
'@@!!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass
'<GROUP ObjectEditorInitializationParametersClass><TITLE Свойства>
Class ObjectEditorInitializationParametersClass
	
	'@@ObjectEditorInitializationParametersClass.ObjectType
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE ObjectType>
	':Назначение:	Наименование типа объекта, подлежащего редактированию / созданию.
	':Примечание:	Значение по умолчанию - vbNullString.
	':Сигнатура:	Public ObjectType [As String]
	Public ObjectType
	
	'@@ObjectEditorInitializationParametersClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE ObjectID>
	':Назначение:	Идентификатор объекта, подлежащего редактированию.
	':Примечание:	Значение по умолчанию - vbNullString.
	':Сигнатура:	Public ObjectID [As String]
	Public ObjectID
	
	'@@ObjectEditorInitializationParametersClass.XmlObject
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE XmlObject>
	':Назначение:	Данные редактируемого объекта
	':Примечание:	Значение по умолчанию - Nothing.
	':Сигнатура:	Public XmlObject [As IXMLDOMElement]
	Public XmlObject
	
	'@@ObjectEditorInitializationParametersClass.MetaName
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE MetaName>
	':Назначение:	Метанаименование редактора.
	':Примечание:	Значение атрибута n элемента i:editor. При указании метаимени
	'				редактора экземпляр ObjectEditorClass будет использовать 
	'				указанное т.о. метаописание редактора.<P/>
	'				Значение по умолчанию - vbNullString.
	':Сигнатура:	Public MetaName [As String]
	Public MetaName
	
	'@@ObjectEditorInitializationParametersClass.CreateNewObject
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE CreateNewObject>
	':Назначение:	Флаг режима создания нового объекта.
	':Примечание:	Значение по умолчанию - False.
	':Сигнатура:	Public CreateNewObject [As Boolean]
	Public CreateNewObject
	
	'@@ObjectEditorInitializationParametersClass.IsAggregation
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE IsAggregation>
	':Назначение:	Флаг режима записи данных (вызова операции сохранения) 
	'				при закрытии редактора (см "Замечания"). 
	':Примечание:	Если флаг установлен в значение True, то при "успешном" 
	'				закрытии редактора (кнопкой "Ок" или "Готово") реализация 
	'				ObjectEditorClass вызывает серверную операцию сохранения 
	'				данных.<P/>
	'				Если флаг установлен в значение False, то серверная операция 
	'				не вызывается; все изменения данных отражаются только в пуле 
	'				данных. Такой режим используется при вызове "вложенного" 
	'				редактора, а так же в случае реализации фильтров и диалогов
	'				задания параметров.<P/>
	'				Значение по умолчанию - False.
	':Сигнатура:	Public IsAggregation [As Boolean]
	Public IsAggregation
	
	'@@ObjectEditorInitializationParametersClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE QueryString>
	':Назначение:	Параметры, передаваемые в редактор, как экземпляр QueryStringClass.
	':Примечание:	Значение по умолчанию - Nothing.
	':Сигнатура:	Public QueryString [As QueryStringClass]
	Public QueryString
	
	'@@ObjectEditorInitializationParametersClass.ParentObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE ParentObjectEditor>
	':Назначение:	Родительский редактор. Задается при вызове "вложенного" 
	'				редактора, иначе - Nothing.
	':Примечание:	Значение по умолчанию - Nothing.
	':Сигнатура:	Public ParentObjectEditor [As ObjectEditorClass]
	Public ParentObjectEditor
	
	'@@ObjectEditorInitializationParametersClass.InterfaceMD
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE InterfaceMD>
	':Назначение:	Метаданные редактора.
	':Примечание:	Значение по умолчанию - Nothing.
	':Сигнатура:	Public InterfaceMD [As IXMLDOMElement]
	Public InterfaceMD
	
	'@@ObjectEditorInitializationParametersClass.ParentObjectID
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE ParentObjectID>
	':Назначение:	Идентификатор "родительского" объекта. Задается при вызове 
	'				"вложенного" редактора, иначе - vbNullString.
	':Примечание:	Значение по умолчанию - vbNullString.
	':Сигнатура:	Public ParentObjectID [As String]
	Public ParentObjectID
	
	'@@ObjectEditorInitializationParametersClass.ParentObjectType
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE ParentObjectType>
	':Назначение:	Наименование типа "родительского" объекта. Задается при 
	'				вызове "вложенного" редактора, иначе - vbNullString.
	':Примечание:	Значение по умолчанию - vbNullString.
	':Сигнатура:	Public ParentObjectType [As String]
	Public ParentObjectType
	
	'@@ObjectEditorInitializationParametersClass.ParentPropertyName
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE ParentPropertyName>
	':Назначение:	Наименование объектного свойства "родительского" редактора, для
	'				редактирования (создания) объекта которого вызывается новый
	'				редактор. Задается при вызове "вложенного" редактора.
	':Примечание:	Значение по умолчанию - vbNullString.
	':Сигнатура:	Public ParentPropertyName [As String]
	Public ParentPropertyName
	
	'@@ObjectEditorInitializationParametersClass.EnlistInCurrentTransaction
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE EnlistInCurrentTransaction>
	':Назначение:	Флаг, определяющий режим работы редактора в текущей транзакции 
	'				пула. Если задан в True, то новый редактор не начинает/отменяет 
	'				новой транзакции.
	':Примечание:	Значение по умолчанию - False.
	':Сигнатура:	Public EnlistInCurrentTransaction [As Boolean]
	Public EnlistInCurrentTransaction
	
	'@@ObjectEditorInitializationParametersClass.InitialObjectSet
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE InitialObjectSet>
	':Назначение:	Узел, содержащий XML-объекты, которые необходимо добавить в пул 
	'				при инициализации редактора.
	':Примечание:	Значение по умолчанию - Nothing.
	':Сигнатура:	Public InitialObjectSet [As IXMLDOMElement]
	Public InitialObjectSet
	
	'@@ObjectEditorInitializationParametersClass.Pool
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE Pool>
	':Назначение:	Пул (в случае создания / инициализации пула "снаружи" корневого редактора.
	':Примечание:	Значение по умолчанию - Nothing.
	':Сигнатура:	Public Pool [As XObjectPool]
	Public Pool
	
	'@@ObjectEditorInitializationParametersClass.SkipInitErrorAlerts
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE SkipInitErrorAlerts>
	':Назначение:	Указывает редактору и всем его компонентам о том, 
	'				что в случае невозможности установить значения UI контролов для текущего объекта, 
	'				не следует выдавать никаких предупреждений пользователю.
	':Сигнатура:	Public SkipInitErrorAlerts [As Boolean]
	Public SkipInitErrorAlerts
	
	'------------------------------------------------------------------------------
	':Назначение:	"Конструктор", инциализация нового экземпляра класса
	Private Sub Class_Initialize
		ObjectType	= vbNullString
		ObjectID	= vbNullString
		MetaName	= vbNullString
		ParentObjectID		= vbNullString
		ParentObjectType	= vbNullString
		ParentPropertyName	= vbNullString
		CreateNewObject = False
		IsAggregation	= False
		EnlistInCurrentTransaction = False
		Set QueryString = Nothing
		Set XmlObject	= Nothing
		Set ParentObjectEditor = Nothing
		Set InterfaceMD = Nothing		
		Set InitialObjectSet = Nothing	
		Set Pool = Nothing
	End Sub
End Class	


'===============================================================================
'@@GetNextPageInfoEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE GetNextPageInfoEventArgsClass>
':Назначение:	
'	Параметры события "GetNextPageInfo" - получение информации о следующей 
'	странице нелинейного мастера.
':См. также:
'	HasNextPageEventArgsClass, EditorStateChangedEventArgsClass
'
'@@!!MEMBERTYPE_Methods_GetNextPageInfoEventArgsClass
'<GROUP GetNextPageInfoEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_GetNextPageInfoEventArgsClass
'<GROUP GetNextPageInfoEventArgsClass><TITLE Свойства>
Class GetNextPageInfoEventArgsClass

	'@@GetNextPageInfoEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_GetNextPageInfoEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@GetNextPageInfoEventArgsClass.PageBuilder
	'<GROUP !!MEMBERTYPE_Properties_GetNextPageInfoEventArgsClass><TITLE PageBuilder>
	':Назначение:	Ссылка на экземпляр EditorPageBuilder-а, используемого 
	'				для построения представления страницы.
	':Сигнатура:	Public PageBuilder [As IEditorPageBuilder]
	Public PageBuilder
	
	'@@GetNextPageInfoEventArgsClass.PageTitle
	'<GROUP !!MEMBERTYPE_Properties_GetNextPageInfoEventArgsClass><TITLE PageTitle>
	':Назначение:	Заголовок страницы.
	':Сигнатура:	Public PageTitle [As String]
	Public PageTitle
	
	'@@GetNextPageInfoEventArgsClass.CanBeCached
	'<GROUP !!MEMBERTYPE_Properties_GetNextPageInfoEventArgsClass><TITLE CanBeCached>
	':Назначение:	Признак, задающий режим кеширования страницы:
	'				* Ture - представление страницы может быть закешировано;
	'				* False - кеширование представления страницы запрещено.
	':Сигнатура:	Public CanBeCached [As Boolean]
	Public CanBeCached
	
	'@@GetNextPageInfoEventArgsClass.BackMode
	'<GROUP !!MEMBERTYPE_Properties_GetNextPageInfoEventArgsClass><TITLE BackMode>
	':Назначение:	Режим поведения мастера при возвращении на предыдущую страницу
	'				многошагового мастера.
	':Примечание:	Значение свойства есть константа вида XEB_nnnn.
	'				Если свойство задано (отлично от Empty), то заданное значение
	'				переопределяет режим, задаваемый свойством BackMode редактора.
	':Сигнатура:	Public BackMode [As Int]
	Public BackMode
	
	' Внутренний метод инициализации объекта.
	Private Sub Class_Initialize
		Cancel = False
		CanBeCached = False
	End Sub
	
	'@@GetNextPageInfoEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_GetNextPageInfoEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As GetNextPageInfoEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@HasNextPageEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE HasNextPageEventArgsClass>
':Назначение:	
'	Параметры события "HasNextPage" - получения признака наличия следующей 
'	страницы нелинейного мастера.
':См. также:
'	GetNextPageInfoEventArgsClass, EditorStateChangedEventArgsClass
'
'@@!!MEMBERTYPE_Methods_HasNextPageEventArgsClass
'<GROUP HasNextPageEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_HasNextPageEventArgsClass
'<GROUP HasNextPageEventArgsClass><TITLE Свойства>
Class HasNextPageEventArgsClass

	'@@HasNextPageEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_HasNextPageEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@HasNextPageEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_HasNextPageEventArgsClass><TITLE ReturnValue>
	':Назначение:	
	'	Результат, возвращаемый обработчиком события. Возможные значения:
	'	* True - следующая страница (мастера) существует;
	'	* False - следующей страницы (у мастера) нет.
	':Сигнатура:	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	' Внутренний метод инициализации экземпляра
	Private Sub Class_Initialize
		Cancel = False
		ReturnValue = False
	End Sub
	
	'@@HasNextPageEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_HasNextPageEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As HasNextPageEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@EditorStateChangedEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE EditorStateChangedEventArgsClass>
':Назначение:	
'	Параметры, описывающие изменения состояния редактора; параметры событий 
'	Validate, BeforePageStart, PageStart, BeforePageEnd, PageEnd, UnLoading
':См. также:
'	GetNextPageInfoEventArgsClass, HasNextPageEventArgsClass
'
'@@!!MEMBERTYPE_Methods_EditorStateChangedEventArgsClass
'<GROUP EditorStateChangedEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_EditorStateChangedEventArgsClass
'<GROUP EditorStateChangedEventArgsClass><TITLE Свойства>
Class EditorStateChangedEventArgsClass

	'@@EditorStateChangedEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_EditorStateChangedEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@EditorStateChangedEventArgsClass.Reason
	'<GROUP !!MEMBERTYPE_Properties_EditorStateChangedEventArgsClass><TITLE Reason>
	':Назначение:	Причина изменения состояния.
	':Примечание:	Значение свойства есть константа вида REASON_nnnn.
	':Сигнатура:	Public Reason [As Int]
	Public Reason
	
	'@@EditorStateChangedEventArgsClass.ErrorMessage 
	'<GROUP !!MEMBERTYPE_Properties_EditorStateChangedEventArgsClass><TITLE ErrorMessage>
	':Назначение:	
	'	Текст сообщения об ошибке, возникшей в процессе выполнения обработчка 
	'	события (см. замечания).
	':Примечание:			
	'	Значение свойства анализируется логикой редактора только в том случае,
	'	когда свойство EditorStateChangedEventArgsClass.ReturnValue установлено в 
	'	значение False. В этом случае редактор показывает заданный текст в виде 
	'	сообщения об ошибке.
	'	Для события UnLoading свойство игнорируется.
	':См. также:
	'	EditorStateChangedEventArgsClass.ReturnValue,
	'	EditorStateChangedEventArgsClass.SilentMode
	':Сигнатура:	Public ErrorMessage [As String]
	Public ErrorMessage
	
	'@@EditorStateChangedEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_EditorStateChangedEventArgsClass><TITLE ReturnValue>
	':Назначение:	
	'	Результат, возвращаемый обработчиком события. Здесь:
	'	* Для событий вида <B>Before<I>NNNN</I></B>:
	'		- False - то дальнейшие действия блокируются;
	'		- True - выполняется дальнейшая обработка.
	'	* Для события UnLoading здесь текст устанавливаемый в window.event.returnValue в Window_onBeforeUnload
	'	* Для всех остальных событий - игнорируется
	':См. также:
	'	EditorStateChangedEventArgsClass.ErrorMessage,
	'	EditorStateChangedEventArgsClass.SilentMode
	':Сигнатура:	Public ReturnValue [As Variant]
	Public ReturnValue
	
	'@@EditorStateChangedEventArgsClass.SilentMode
	'<GROUP !!MEMBERTYPE_Properties_EditorStateChangedEventArgsClass><TITLE SilentMode>
	':Назначение:	Признак "тихого" режима сбора данных (см. замечания).
	':Примечания:
	'	Если в процессе обработки события возникает ошибка, то в общем случае 
	'	обработчик отражает факт ошибки установкой свойства EditorStateChangedEventArgsClass.ReturnValue
	'	в значение False. Описание ошибки при этом записывается в ErrorMessage.
	'	Однако возможны такие случаи реализации, когда ошибка отображается 
	'	самим обработчиком (например, при реализации диалога подтверждения 
	'	какого-либо действия от пользователя).<P/>
	'	При этом существуют сценарии, когда какое-либо отображение не требуется.<P/>
	'	Свойство SilentMode указывает обработчику на случай такого сценария: 
	'	если свойство установлено в True, то логика обработчика должна 
	'	блокировать вывод каких-либо сообщений. При этом вся информация об ошибке 
	'	может быть передана через свойства ReturnValue и ErrorMessage.
	':См. также:	
	'	EditorStateChangedEventArgsClass.ReturnValue, 
	'	EditorStateChangedEventArgsClass.ErrorMessage
	':Сигнатура:	Public SilentMode [As Boolean]
	Public SilentMode

	' Внутренний метод инициализации экземпляра
	Private Sub Class_Initialize
		ReturnValue = True
		Cancel = False
	End Sub
	
	'@@EditorStateChangedEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_EditorStateChangedEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As EditorStateChangedEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function	
End Class


'===============================================================================
'@@EditorLoadEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE EditorLoadEventArgsClass>
':Назначение:	Параметры события "Load" редактора.
'
'@@!!MEMBERTYPE_Methods_EditorLoadEventArgsClass
'<GROUP EditorLoadEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_EditorLoadEventArgsClass
'<GROUP EditorLoadEventArgsClass><TITLE Свойства>
Class EditorLoadEventArgsClass

	'@@EditorLoadEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_EditorLoadEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel

	'@@EditorLoadEventArgsClass.StartPageIndex
	'<GROUP !!MEMBERTYPE_Properties_EditorLoadEventArgsClass><TITLE StartPageIndex>
	':Назначение:	Задает индекс страницы многостраничного редактора, которая 
	'				будет открыта после завершения инициализации.
	':Сигнатура:	Public StartPageIndex [As Integer]
	Public StartPageIndex

	'@@EditorLoadEventArgsClass.ErrorDescription
	'<GROUP !!MEMBERTYPE_Properties_EditorLoadEventArgsClass><TITLE ErrorDescription>
	':Назначение:	Если обработчик установит это свойство, то процесс инициализации
	'				редактора будет прерван, сообщение будет выведено в информационном 
	'				поле редактора.
	':Сигнатура:	Public ErrorDescription [As String]
	Public ErrorDescription	
	
	' Внутренний метод инициализации экземпляра
	Private Sub Class_Initialize
		Cancel = False
		StartPageIndex = 0
	End Sub
	
	'@@EditorLoadEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_EditorLoadEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As EditorLoadEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function	
End Class


'===============================================================================
'@@SaveObjectErrorEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE SaveObjectErrorEventArgsClass>
':Назначение:	Параметры события "SaveObjectError" редактора.
'
'@@!!MEMBERTYPE_Methods_SaveObjectErrorEventArgsClass
'<GROUP SaveObjectErrorEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_SaveObjectErrorEventArgsClass
'<GROUP SaveObjectErrorEventArgsClass><TITLE Свойства>
Class SaveObjectErrorEventArgsClass

	'@@SaveObjectErrorEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_SaveObjectErrorEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel

	'@@SaveObjectErrorEventArgsClass.Action
	'<GROUP !!MEMBERTYPE_Properties_SaveObjectErrorEventArgsClass><TITLE Action>
	':Назначение:	Действия, выполняемые в случае ошибки; одна из констант 
	'				AFTERERROR_nnnn.
	':Сигнатура:	Public Action [As Int]
	Public Action

	'@@SaveObjectErrorEventArgsClass.ErrNumber
	'<GROUP !!MEMBERTYPE_Properties_SaveObjectErrorEventArgsClass><TITLE ErrNumber>
	':Назначение:	Номер / код ошибки.
	':Сигнатура:	Public ErrNumber [As Interger]
	Public ErrNumber

	'@@SaveObjectErrorEventArgsClass.ErrSource
	'<GROUP !!MEMBERTYPE_Properties_SaveObjectErrorEventArgsClass><TITLE ErrSource>
	':Назначение:	Описание источника ошибки.
	':Сигнатура:	Public ErrSource [As String]
	Public ErrSource

	'@@SaveObjectErrorEventArgsClass.ErrDescription
	'<GROUP !!MEMBERTYPE_Properties_SaveObjectErrorEventArgsClass><TITLE ErrDescription>
	':Назначение:	Описание ошибки.
	':Сигнатура:	Public ErrDescription [As String]
	Public ErrDescription
	
	'@@SaveObjectErrorEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SaveObjectErrorEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As SaveObjectErrorEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function	
End Class


'===============================================================================
':Назначение: Служебный класс, используется из XmlObjectNavigatorClass
Class XmlObjectNavigatorInternalClass
	Private  m_vResult
	Public Function SetResult(vResult)
		SetResult = 0
		If IsObject(vResult) Then
			Set m_vResult = vResult
		Else
			m_vResult = vResult
		End If		
	End Function
	Public Sub GetResult(vResult)
		If IsObject(m_vResult) Then
			Set vResult = m_vResult
		Else
			vResult = m_vResult
		End If		
	End Sub
End Class


'===============================================================================
'@@XmlObjectNavigatorClass
'<GROUP !!CLASSES_x-editor><TITLE XmlObjectNavigatorClass>
':Назначение:	
'	Класс служит для развертывания цепочек из пула объектов и выполнения по ним 
'	XPath-запросов. Используется в процессе построения HTML-представления страниц
'	редактора, для представления данных ds-объектов в виде "дерева".
':Примечание:	
'	Экземпляр класса конструировать "вручную" нельзя (т.к. экземпляр должен быть
'	корректно инициализирован). Для получения экземпляров используются:
'	- ObjectEditorClass.CreateXmlObjectNavigatorFor
'	- ObjectEditorClass.CreateXmlObjectNavigator
':См. также:
'	ObjectEditorClass, <P/>
'	<LINK oe_1, Архитектура редактора />
'
'@@!!MEMBERTYPE_Methods_XmlObjectNavigatorClass
'<GROUP XmlObjectNavigatorClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_XmlObjectNavigatorClass
'<GROUP XmlObjectNavigatorClass><TITLE Свойства>
Class XmlObjectNavigatorClass
	Private m_oXmlObject		' Объект - корень
	Private m_oObjectEditor		' Экзампляр ObjectEditor из которого получили
	Private m_oSelectorXsl		' XSLT - для выполнения "заковыристых" XPath-запросов


	'------------------------------------------------------------------------------
	':Назначение:	Выполнение "заковыристого" XPath-запроса
	Private Sub executeXPathQuery( sXPathQuery, vResult)
		Dim sXsltString
		Dim oTemplate	' XslTemplate
		Dim oProcessor	' XslProcessor
		Dim oResultSet
		If IsEmpty(m_oSelectorXsl) Then
			sXsltString = _ 				
				"<?xml version=""1.0""?><xsl:stylesheet version=""1.0"" " & vbNewLine & _ 
				"	xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""" & vbNewLine & _ 
				"	xmlns:result=""urn:x-result""" & vbNewLine & _ 
				"	xmlns:x=""urn:x-client-service""" & vbNewLine & _ 
				"	xmlns:w=""urn:editor-window-access"">" & vbNewLine & _ 
				"<xsl:output method=""text""/>" & vbNewLine & _ 
				"<xsl:template match=""*"">" & vbNewLine & _ 
				"	<xsl:value-of result:result=""result""  select=""result:SetResult(.)""/>" & vbNewLine & _ 
				"</xsl:template>	" & vbNewLine & _ 
				"</xsl:stylesheet>	"
			Set m_oSelectorXsl=XService.XmlFromString( sXsltString) 
		End If
		With m_oSelectorXsl.selectSingleNode("//*[@result:result]/@select")
			.DataType = "string"
			.NodeTypedValue = "result:SetResult(" & sXPathQuery & ")"
		End With
		Set oTemplate = CreateObject( "MSXml2.XslTemplate.3.0")
		' Указываем используемый шаблон
		oTemplate.stylesheet = m_oSelectorXsl.ownerDocument
		' Создаем процессор
		Set oProcessor = oTemplate.createProcessor
		' Передаем процессору трансформируемый документ - данные
		oProcessor.input = m_oXmlObject
		' Передаем процессору объект доступа к данным редактора/мастера
		Set oResultSet = New XmlObjectNavigatorInternalClass
		oProcessor.addObject oResultSet, "urn:x-result"
		' Передаем процессору объект доступа к окну редактора/мастера
		oProcessor.addObject window, "urn:editor-window-access"
		' Передаем процессору объект доступа к IXClientService
		oProcessor.addObject XService, "urn:x-client-service"
		' Трансформируем
		oProcessor.transform
		oResultSet.GetResult vResult
	End Sub
	
	
	'-------------------------------------------------------------------------------
	':Назначение:	
	'	Инициализация экземпляра, через "присоединение" к объекту редактора.
	':Параметры:	
	'	oObjectEditor - [in] объект редактора, к которому выполняется "присоединение"
	'	oXmlObject	- [in] данные ds-объекта, "разворачиваемые" в "дерево"
	':Примечание:	
	'	ВНИМАНИЕ! Вызывается из ObjectEditorClass, руками НЕ ВЫЗЫВАТЬ!
	Public Sub Attach(oObjectEditor, oXmlObject)
		' Инициализировать можно только один раз!
		If IsObject(m_oObjectEditor) Then Exit Sub
		Set m_oObjectEditor = oObjectEditor
		' склонируем переданный xml-объект и переместим его в новый XMLDocument
		Set oXmlObject = oXmlObject.cloneNode( True)
		XService.XmlGetDocument.appendChild oXmlObject
		XService.XmlSetSelectionNamespaces oXmlObject.ownerDocument
		Set m_oXmlObject = oXmlObject
	End Sub
	
	
	'---------------------------------------------------------------------------
	':Назначение:	Развёртывание цепочки свойства
	':Параметры:	[in] sPropertyPath - путь до свойства через точку.
	':Примеры: 		doExpand "Worker.Department"
	'				doExpand "Prop1.SubProp2.SubSubProp3"
	Private Sub doExpand(sPropertyPath)
		Dim aPropertyPath
		Dim oXmlNode
		Dim sXPath
		Dim i
		aPropertyPath = Split(sPropertyPath,".")
		For i=0 To UBound(aPropertyPath)
			If 0=i Then
				sXPath = aPropertyPath(i)
			Else
				sXPath = sXPath & "/*/" & aPropertyPath(i)
			End If		
			' по всем свойствам с заглушками и всем незагруженным LOB-свойствам (@loaded='0')
			For Each oXmlNode In m_oXmlObject.selectNodes(sXPath & "[@loaded='0' or (*[@oid and not (*)])]")
				LoadXmlProperty oXmlNode 
			Next
		Next
	End Sub


	'---------------------------------------------------------------------------
	':Назначение:
	'	Разворачивает свойство в дереве. В свойство помещаются объекты из пула 
	'	(при необходимости они загружаются), соответствующие заглушкам.
	':Параметры:
	'	oXmlProperty - [in] XML-свойство в строющемся read-only дереве, которое 
	'					требуется развернуть (экземпляр IXMLDOMElement)
	Private Sub LoadXmlProperty( oXmlProperty )
		Dim oXmlPropertyInPool			' As IXMLDOMElement - свойство в пуле, соответствующее переданному свойству
		Dim oNode						' As IXMLDOMElement - объект-значение свойства
		
		' получим текущее свойство в пуле, при этом оно гарантировано прогрузиться
		Set oXmlPropertyInPool = m_oObjectEditor.Pool.GetXmlProperty(oXmlProperty.parentNode, oXmlProperty.nodeName)
		' очистим свойство
		oXmlProperty.selectNodes("*|@loaded").removeAll
		' пойдем по всем заглушкам в свойстве из пула
		For Each oNode In oXmlPropertyInPool.selectNodes("*")
			' и для каждого объекта-значения свойства получим полный объект в пуле, и поместим его копию в переданное свойство
			oXmlProperty.appendChild m_oObjectEditor.Pool.GetXmlObjectByXmlElement(oNode, Null).cloneNode(true)
		Next
	End Sub


	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.ExpandProperty
	'<GROUP !!MEMBERTYPE_Methods_XmlObjectNavigatorClass><TITLE ExpandProperty>
	':Назначение:	Выполняет развертывание заданных цепочек свойств.
	':Результат:    Текущий экземпляр класса XmlObjectNavigatorClass.
	':Параметры:	
	'	sPropertyPaths - [in] набор путей до свойства; пути разделяются запятой (см. "Замечания")
	':Примечание:	
	'	"Путь" есть указание цепочки объектных свойств; свойства в "пути" 
	'	разделяются точкой: "Свойство1.Свойство2.СвойствоN" (см. примеры далее).
	'	Параметр sPropertyPaths может задавать несколько "путей", разделяемых 
	'	символом запятой. Метод "разворачивает" все цепочки свойств, заданные 
	'	путями, в порядке их указания в параметре sPropertyPaths.
	':Примеры:
	'	ExpandProperty "Worker.Department"
	'	ExpandProperty "Prop1.SubProp2.SubSubProp3"
	'	ExpandProperty "Worker.Department,Prop1.SubProp2.SubSubProp3,SomeProp"
	':См. также:
	'	XmlObjectNavigatorClass.MoveContextTo, 
	'	XmlObjectNavigatorClass.XmlObject
	':Сигнатура:
	'	Public Function ExpandProperty( 
	'		sPropertyPaths [As String] 
	'	) [As XmlObjectNavigatorClass]
	Public Function ExpandProperty(sPropertyPaths)
		Dim sPropertyPath
		Dim aPropertyPath
		Dim i
		
		sPropertyPath = Replace(sPropertyPaths, " ", vbNullString)
		sPropertyPath = Replace(sPropertyPath, vbCr, vbNullString)
		sPropertyPath = Replace(sPropertyPath, vbLf, vbNullString )
		sPropertyPath = Replace(sPropertyPath, vbTab, vbNullString)
		
		aPropertyPath = Split(sPropertyPath,",")
		For i=0 To UBound(aPropertyPath)
			doExpand aPropertyPath(i)
		Next
		Set ExpandProperty = Me
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.MoveContextTo
	'<GROUP !!MEMBERTYPE_Methods_XmlObjectNavigatorClass><TITLE MoveContextTo>
	':Назначение:	Перемещение контекста навигатора.
	':Результат:    Текущий экземпляр класса XmlObjectNavigatorClass.
	':Параметры:	oXmlObject - [in] новый контекст
	':Примечание:	
	'	Контекст - это ds-объект, относительно которого осуществляется 
	'	"развертывание" всех свойств в XML-"дерево". Изначально контекст 
	'	задается при создании экземляра XmlObjectNavigatorClass, при вызове
	'	методов ObjectEditorClass.CreateXmlObjectNavigatorFor или 
	'	ObjectEditorClass.CreateXmlObjectNavigator.<P/>
	'	Контекст, задаваемый праметром oXmlObject, должен быть из того же XML-
	'	документа, что и текущий контекст, а так же должен представлять данные 
	'	ds-объекта (иметь аттрибут "oid").
	':См. также:
	'	XmlObjectNavigatorClass.ExpandProperty,
	'	XmlObjectNavigatorClass.XmlObject
	':Сигнатура:
	'	Public Function MoveContextTo( 
	'		oXmlObject [As IXMLDOMElement] 
	'	) [As XmlObjectNavigatorClass]
	Public Function MoveContextTo(oXmlObject)
		If Not (oXmlObject.ownerDocument Is m_oXmlObject.ownerDocument) Then
			err.Raise -1, "XmlObjectNavigatorClass::MoveContextTo",  "oXmlObject must be from same Document"
		End If
		If IsNull(oXmlObject.getAttribute("oid")) Then
			err.Raise -1, "XmlObjectNavigatorClass::MoveContextTo",  "oXmlObject must be XmlObject, Not XmlProperty"
		End If	
		Set m_oXmlObject = oXmlObject
		Set MoveContextTo = Me
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.SelectObjectInPool
	'<GROUP !!MEMBERTYPE_Methods_XmlObjectNavigatorClass><TITLE SelectObjectInPool>
	':Назначение:	
	'	Получение данных ds-объекта из пула объектов по XPath-запросу, выполняемому 
	'	в "развернутом дереве" (см. "Замечания").
	':Результат:    
	'	XML-данные выбранного объекта (как IXMLDOMElement) или Nothing.
	':Параметры:	
	'	sXPathQuery - [in] XPath-запрос, определяющий нахождение данных в "дереве"
	':Примечание:	
	'	XPath-запрос выполняется по текущему "дереву" данных, "развернутому" 
	'	и представленному в навигаторе (в текущем экземпляре XmlObjectNavigatorClass). 
	'	Если результат выполения запроса есть ds-объект, то метод возвращает ссылка 
	'	на этот объект в пуле.
	':Пример:		
	'	Set oExecutor = nav.SelectObjectInPool( "Tasks/Task[position()=last()]/Worker/SystemUser" )
	':См. также:
	'	XmlObjectNavigatorClass.SelectNode, XmlObjectNavigatorClass.SelectNodes, 
	'	XmlObjectNavigatorClass.SelectScalar
	':Сигнатура:
	'	Public Function SelectObjectInPool( 
	'		sXPathQuery [As String] 
	'	) [As IXMLDOMElement]
	Public Function SelectObjectInPool(sXPathQuery)
		Dim oLocalObject
		Dim sObjectID
		Set SelectObjectInPool = Nothing
		Set oLocalObject = SelectNode(sXPathQuery)
		If oLocalObject Is Nothing Then Exit Function
		sObjectID = oLocalObject.GetAttribute("oid")
		If Not IsNull(sObjectID) Then
			Set SelectObjectInPool = m_oObjectEditor.Pool.GetXmlObjectByXmlElement( oLocalObject, Null) 	
		End If	
	End Function
	

	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.SelectNode
	'<GROUP !!MEMBERTYPE_Methods_XmlObjectNavigatorClass><TITLE SelectNode>
	':Назначение:	
	'	Получение данных путем выполнения "функционального" XPath-запроса.
	':Результат:    
	'	Результат запроса (как экземпляр IXMLDOMElement), или Nothing.
	':Параметры:	
	'	sXPathQuery - [in] текст "функционального" XPath-запроса
	':Примечание:	
	'	"Функциональный" XPath-запрос - это запрос, допускающий включение 
	'	стандартных XSLT-функций, а также <B>прикладных</B> функций (см.
	'	примеры далее).<P/>
	'	XPath-запрос выполняется по текущему "дереву" данных, "развернутому" 
	'	и представленному в навигаторе (в текущем экземпляре XmlObjectNavigatorClass).
	':Примеры:		
	'	' "Функциональный запрос" включает вызов прикладной функции SomeFunction:
	'	Set oExecutor = nav.SelectNode( "Tasks/Task/Worker/SystemUser[0!=w:SomeFunction(.)]" )
	'	' "Функциональный запрос" включает вызов стандартной XSLT-функции last:
	'	Set oExecutor = nav.SelectNode( "Tasks/Task[position()=last()]/Worker/SystemUser" )
	':См. также:
	'	XmlObjectNavigatorClass.SelectObjectInPool, 
	'	XmlObjectNavigatorClass.SelectScalar, XmlObjectNavigatorClass.SelectNodes
	':Сигнатура:
	'	Public Function SelectNode( sXPathQuery [As String] ) [As IXMLDOMElement]
	Public Function SelectNode(sXPathQuery)
		Dim oNodes
		Set oNodes = SelectNodes(sXPathQuery)
		If 0 < oNodes.Length Then
			Set SelectNode = oNodes.Item(0)
		Else
			Set SelectNode = Nothing
		End If
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.SelectScalar
	'<GROUP !!MEMBERTYPE_Methods_XmlObjectNavigatorClass><TITLE SelectScalar>
	':Назначение:
	'	Получение скалярных данных путем выполнения "функционального" XPath-запроса.
	':Результат:    
	'	Скалярные данные.
	':Параметры:	
	'	sXPathQuery - [in] текст "функционального" XPath-запроса
	':Примечание:	
	'	"Функциональный" XPath-запрос - это запрос, допускающий включение 
	'	стандартных XSLT-функций, а также <B>прикладных</B> функций (см.
	'	примеры далее).<P/>
	'	XPath-запрос выполняется по текущему "дереву" данных, "развернутому" 
	'	и представленному в навигаторе (в текущем экземпляре XmlObjectNavigatorClass).
	':Примеры:		
	'	nSum = nav.SelectScalar( "sum(Order/Position/Price)" )
	'	nCount	= nav.SelectScalar( "Order/Position" )
	':См. также:
	'	XmlObjectNavigatorClass.SelectObjectInPool, 
	'	XmlObjectNavigatorClass.SelectNode, XmlObjectNavigatorClass.SelectNodes
	':Сигнатура:
	'	Public Function SelectScalar( sXPathQuery [As String] ) [As Variant]
	Public Function SelectScalar(sXPathQuery)
		Dim vResult
		executeXPathQuery sXPathQuery, vResult
		If IsObject(vResult) Then 
			If 0=StrComp("IXMLDOMNodeList", TypeName( vResult), vbTextCompare) Then
				SelectScalar = vResult.Length
			Else
				SelectScalar = TypeName( vResult)
			End If
		Else
			SelectScalar = vResult
		End If	
	End Function
	

	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.SelectNodes
	'<GROUP !!MEMBERTYPE_Methods_XmlObjectNavigatorClass><TITLE SelectNodes>
	':Назначение:	
	'	Получение набора данных путем выполнения "функционального" XPath-запроса.
	':Результат:    
	'	Набор данных (как экземпляр IXMLDOMSelection), или Nothing.
	':Параметры:	
	'	sXPathQuery - [in] текст "функционального" XPath-запроса
	':Примечание:	
	'	"Функциональный" XPath-запрос - это запрос, допускающий включение 
	'	стандартных XSLT-функций, а также <B>прикладных</B> функций (см.
	'	примеры далее).<P/>
	'	XPath-запрос выполняется по текущему "дереву" данных, "развернутому" 
	'	и представленному в навигаторе (в текущем экземпляре XmlObjectNavigatorClass).
	':Примеры:
	'	Set oExecutors = nav.SelectNodes( "Tasks/Task/Worker/SystemUser[0!=w:SomeFunction(.)]" )
	':См. также:
	'	XmlObjectNavigatorClass.SelectObjectInPool, 
	'	XmlObjectNavigatorClass.SelectNode, XmlObjectNavigatorClass.SelectScalar
	':Сигнатура:
	'	Public Function SelectNodes( sXPathQuery [As String] ) [IXMLDOMSelection]
	Public Function SelectNodes(sXPathQuery)
		Dim vResult
		executeXPathQuery sXPathQuery, vResult
		If 0=StrComp("IXMLDOMNodeList", TypeName( vResult), vbTextCompare) Then
			Set SelectNodes = vResult
		Else
			Set SelectNodes = m_oXmlObject.SelectNodes("*['1'='2']")
		End If
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.XmlObject
	'<GROUP !!MEMBERTYPE_Properties_XmlObjectNavigatorClass><TITLE XmlObject>
	':Назначение:	Возвращает текущий контекст навигатора.
	':Примечание:	
	'	Контекст - это ds-объект, относительно которого осуществляется 
	'	"развертывание" всех свойств в XML-"дерево". Изначально контекст 
	'	задается при создании экземляра XmlObjectNavigatorClass, при вызове
	'	методов ObjectEditorClass.CreateXmlObjectNavigatorFor или 
	'	ObjectEditorClass.CreateXmlObjectNavigator.<P/>
	'	Свойство только для чтения.
	':См. также:
	'	XmlObjectNavigatorClass.MoveContextTo, 
	'	XmlObjectNavigatorClass.ExpandProperty
	':Сигнатура:
	'	Public Property Get XmlObject [As IXMLDOMElement]
	Public Property Get XmlObject
		Set XmlObject = m_oXmlObject
	End Property
End Class


'===============================================================================
'@@ObjectEditorClass
'<GROUP !!CLASSES_x-editor><TITLE ObjectEditorClass>
':Назначение:
'	Класс, реализующий доступ к данным редактора / мастера.
':Описание:
'	Класс реализует основу функционала редактирования ds-объекта:
'	– логику загрузки и сохранения ds-объекта, подчиненных (вложенных) объектов;
'	- логику работы с пулом данных ds-объектов;
'	- логику работы с метаданными свойств объектов;
'	- логику работы со страницами редактора.
' События (генерируются посредством EventEngineClass, см. так же 
'	<LINK Client_EventEngine, Обслуживание событий Web-клиента/>):
' <xtable width="100%">
' Событие                 Описание события                                    Класс параметров события
' ---------------------   -------------------------------------------------   ------------------------------------
' Load                    Завершение инициализации редактора. Коллекция       (cобытие не параметризируется)
'                          страниц еще не проинициализирована.
' BeforePageStart         Перед началом построения страницы.                  EditorStateChangedEventArgsClass
' PageStart               Текущая страница построена и проинициализована,     EditorStateChangedEventArgsClass
'                          элементы управления доступны, фокус установлен      
'                          на первый доступный элемент.
' BeforePageEnd           Перед уходом со страницы. Если ReturnValue          EditorStateChangedEventArgsClass
'                          установлено в значение False, переключения 
'                          страницы не происходит.
' ValidatePage            При уходе со страницы, в процессе сбора данных.     EditorStateChangedEventArgsClass
'                          Если ReturnValue установлено в значение False, 
'                          переключения страницы не происходит.
' PageEnd                 При уходе со страницы, после завершения сбора       EditorStateChangedEventArgsClass
'                          данных. Если ReturnValue установлено в значение 
'                          False, переключения не происходит.
' Validate                Проверка данных при закрытии редактора.             EditorStateChangedEventArgsClass
' AcceptChanges           (Планируется к реализации; в текущей реализации     -
'                          не генерируется).
' SaveObjectError         При сохранении данных произошла ошибка.             SaveObjectErrorEventArgsClass
' UnLoading				  При закрытии редактора любым способом.			  EditorStateChangedEventArgsClass
'							Обработчик может воспрепятствовать закрытию		  
' UnLoad                  При закрытии редактора любым способом.              (событие не параметризируется)
' GetNextPageInfo         Получение информации о следующем шаге               GetNextPageInfoEventArgsClass
'                          "нелинейного" мастера.
' HasNextPage             Получение информации о наличия следующего шага      HasNextPageEventArgsClass
'                          "нелинейного" мастера.
' GetObject               При загрузке даннных ds-объекта с сервера в пул.    GetObjectEventArgsClass
' Accel                   При нажатии комбинации клавиш.                      AccelerationEventArgsClass
' PrepareSaveRequest      Формирование экземпляра запроса для операции        PrepareSaveRequestEventArgsClass
'                          сохранения данных пула.
' Saved                   После успешного сохранения данных пула.             (cобытие не параметризируется)
' SetCaption              При установке заголовка мастера / редактора.        SetCaptionEventArgsClass
' </xtable>
'	<P/> 
'	Редактор так же реализует следующие стандартные обработчики событий:
' <xtable width="100%">
' Описание события                                                  Стандартный обработчик
' ---------------------------------------------------------------   -----------------------------------------
' GetObjectConflict - Событие пула (см. XObjectPoolClass)<P/>       ObjectEditorClass.OnGetObjectConflict
'  Генерируется при обнаружении противоречий в данных ds-объекта    
'  уже представленных в пуле, и данных того же объекта,
'  загруженных с сервера.
' DeleteObjectConflict - Событие пула  (см. XObjectPoolClass)<P/>   ObjectEditorClass.OnDeleteObjectConflict
'  При попытке удаления ds-объекта, при обнаружении ссылок на
'  удаляемый объект.
' </xtable>
'
':См. также:
'	XObjectPoolClass, XmlObjectNavigatorClass, <P/>
'	<LINK oe_1, Архитектура редактора />
'
'@@!!MEMBERTYPE_Methods_ObjectEditorClass
'<GROUP ObjectEditorClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_ObjectEditorClass
'<GROUP ObjectEditorClass><TITLE Свойства>
Class ObjectEditorClass
	Private m_sSaveCommandName			' As String - наименование серверной команды, используемой для сохранения
	Private m_bAggregation				' As Boolean - Признак аггрегации
	Private m_bIncluded					' As Boolean - Признак работы в режиме вложенного редактора/мастера
	Private m_sUniqueID					' As String - Имя глобальной переменной, содержащей ссылку на текущий экземпляр класса	
	Private m_bCreateNewObject			' As Boolean - Признак создания нового объекта
	Private m_bIsTabbed					' As Boolean - Режим работы	(true - редактор с закладками, false - пошаговый мастер)
	Private m_sObjectType				' As String - Имя типа редактируемого/создаваемого объекта	
	Private m_sObjectID					' As String - Идентификатор редактируемого объекта	
	Private m_sMetaName					' As String - Наименование описания редактора/мастера в метаданных	
	Private m_oInterfaceMD				' As XMLDOMElement - Метаданные редактора/мастера (XmlDOMElement)	
	Private m_oPageStack				' As StackClass - Стек наименований страниц нелинейного мастера	
	Private m_oQueryString				' As QueryString -Объект QueryStringClass
	Private m_nDefaultBackMode			' As Integer - режим поведения мастера по умолчанию при возврате назад со страницы
	Private m_nCurrentPageNo			' As Integer - номер от 1 шага текущей вкладки/шага линейного мастера
	Private m_oParseHtmlIDRegExp		' As RegExp - Вспомогательное регулярное выражение	
	Private m_oObjectContainerEventsImp	' As IObjectContainerEventsClass - ссылка на контейнер
	Private m_oPages					' As Scripting.Dictionary - словарь описаний страниц: ключ - наименование, значение - экземпляр XEditorPage
	Private m_bIsInterrupted			' As Boolean - ???
	Private m_bMayBeInterrupted			' As Boolean - ???
	Private m_bControlsEnabled			' As Boolean - Признак доступности контролов на странице	
	Private EVENTS						' As String - список событий редактора
	Private m_oEventEngine				' As EventEngineClass - event engine
	Private m_sParentObjectID			' As String - Идентификатор родительского объекта (только для вложенных редакторов)
	Private m_sParentObjectType			' As String - Наименование типа родительского объекта (только для вложенных редакторов)
	Private m_sParentPropertyName		' As String - Наименование родительского свойства (только для вложенных редакторов)
	Private m_oParentObjectEditor		' As ObjectEditorClass - экземпляр родительского редактора (для корневого редактора - Nothing)
	Private m_oActivePage				' As EditorPageClass - Текущая страница редактора
	Private m_oNamesDictionary			' As Scripting.Dictionary - Глобальный хеш-тейбл имен свойств для получения уникального наименования свойства
	Private m_oPool						' As XObjectPoolClass - Пул объектов
	Private m_bManageCurrentTransaction	' As Boolean - признак того, что редактор управляет текущей транзакцией пула (т.е. в Init делает BeginTransaction, а Save/Cance - Commit/Rollback)
	Private m_oPopUpForDebugMenu		' As CROC.XPopUpMenu для отладочного меню
	Private m_bSkipInitErrorAlerts		' As Boolean - Указывает редактору и всем его компонентам о том, 
										'	что в случае невозможности установить значения UI контролов для текущего объекта, 
										'	не следует выдавать никаких предупреждений пользователю.

	'------------------------------------------------------------------------------
	' "Конструктор" объекта
	Private Sub Class_Initialize
		const HTML_ID_PARSING_REGEXP = "^PE\$(\w+)\@(\w+)\(([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\)$"
		Set m_oParseHtmlIDRegExp = New RegExp
		Set m_oEventEngine = X_CreateEventEngine
		EVENTS = "Load,BeforePageStart,PageStart,BeforePageEnd,ValidatePage,PageEnd,Validate,AcceptChanges,SaveObjectError,UnLoad,UnLoading," & _
			"GetNextPageInfo,HasNextPage,DeleteObjectConflict,GetObjectConflict,GetObject,Accel,PrepareSaveRequest,Saved,SetCaption"
		m_oParseHtmlIDRegExp.Pattern = HTML_ID_PARSING_REGEXP
		' создадим словарь для хранения уникальных наименований свойств
		Set m_oNamesDictionary = CreateObject("Scripting.Dictionary")
		m_oNamesDictionary.CompareMode = vbTextCompare
		
		' Создаем уникальную глобальную переменную, в которую помещаем текущий экземпляр
		m_sUniqueID = "g_oXE_" & Replace( XService.NewGuidString, "-", "")
		ExecuteGlobal	"Dim " & m_sUniqueID
		Execute			"Set " & m_sUniqueID & " = Me"
	End Sub
	

	'------------------------------------------------------------------------------
	':Назначение:	Возбуждает заданное событие с переданеыми параметрами
	Private Sub fireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub
	

	'------------------------------------------------------------------------------
	':Назначение:	Возбуждает заданное событие с переданными параметрами. 
	':Примечание:	ТОЛЬКО ДЛЯ ВНУТРЕННЕГО ИСПОЛЬЗОВАНИЯ!
	Public Sub Internal_FireEvent(sEventName, oEventArgs)
		fireEvent sEventName, oEventArgs
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.EventEngine
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE EventEngine>
	':Назначение:	Возвращает экземпляр EventEngineClass, используемый редактором для генерации событий
	':Сигнатура:	Public Property Get EventEngine [As EventEngineClass]
	Public Property Get EventEngine
		Set EventEngine = m_oEventEngine
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ObjectContainerEventsImp
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE ObjectContainerEventsImp>
	':Назначение:	Возвращает ассоциированный с редактором контейнер.
	':Примечание:	Свойство только для чтения.
	':См. также:	IObjectContainerEventsClass, <LINK oe_1, Архитектура редактора />
	':Сигнатура:	Public Property Get ObjectContainerEventsImp [As IObjectContainerEventsClass]
	Public Property Get ObjectContainerEventsImp
		Set ObjectContainerEventsImp = m_oObjectContainerEventsImp
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CurrentPageNo
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE CurrentPageNo>
	':Назначение:	Возвращает номер текущего шага мастера.
	':Примечание:	Свойство только для чтения.
	':Сигнатура:	Public Property Get CurrentPageNo [As Int]
	Public Property Get CurrentPageNo
		CurrentPageNo = m_nCurrentPageNo
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.HelpPage
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE HelpPage>
	':Назначение:	Наименование текущей страницы справки (значение атрибута 
	'				help-page метаописания редактора в метданных).
	':Примечание:	Свойство только для чтения.
	':Сигнатура:	Public Property Get HelpPage [As String]
	Public Property Get HelpPage
		HelpPage = InterfaceMD.getAttribute("help-page")
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.HelpPage
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE HelpPage>
	':Назначение:	Признак наличия определения страницы справки для редактора:
	'				- True - страница справки задана; наименование страницы 
	'					представлено свойством ObjectEditorClass.HelpPage;
	'				- False - страница справки не задана.
	':Примечание:	Свойство только для чтения.
	':Сигнатура:	Public Property Get IsHelpAvailiable [As Boolean]
	Public Property Get IsHelpAvailiable
		If Not IsNull(HelpPage) Then
			IsHelpAvailiable = True
		Else
			IsHelpAvailiable = False
		End If	
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.TransactionID
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE TransactionID>
	':Назначение:	Возвращает идентификатор текущей логической транзакции.
	':Примечание:	Свойство только для чтения.
	':Сигнатура:	Public Property Get TransactionID [As String]
	Public Property Get TransactionID
		TransactionID = m_oPool.TransactionID
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.UniqueID
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE UniqueID>
	':Назначение:	Возвращает имя уникальной глобальной переменной, в которой 
	'				сохранена ссылка на текущий экземпляр класса.
	':Сигнатура:	Public Function UniqueID() [As String]
	Public Function UniqueID()
		UniqueID = m_sUniqueID
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.Signature
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE Signature>
	':Назначение:	Возвращает строку с сигнатурой редактора.
	':Примечание:	Сигнатура используется для формирования наименования файла, 
	'				в котором сохраняются пользовательские данные.
	':Сигнатура:	Public Function Signature() [As String]
	Public Function Signature()
		Signature = Iif(IsEditor,"XE","XW") & "." & ObjectType & "." & MetaName & "."
	End Function

	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.DefaultBackMode
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE DefaultBackMode>
	':Назначение:	Возвращает константу вида XEB_nnnn, соответствующую текущему
	'				виду действий, выполняемых редактором при нажатии кнопки "Назад" 
	'				в режиме мастера.
	':Примечание:	Свойство только для чтения.
	':См. также:	XEB_nnnn
	':Сигнатура:	Public Property Get DefaultBackMode [As XEB_nnnn]
	Public Property Get DefaultBackMode
		DefaultBackMode = m_nDefaultBackMode
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SaveCommandName
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE SaveCommandName>
	':Назначение:	
	'	Возвращает наименование операции сервера приложения, используемой для 
	'	сохранения данных пула.
	':Примечание:	
	'	Наименование операции может быть задано в определении редактора, 
	'	в метаданных приложения, как значение атрибута "save-cmd" элемента i:editor. 
	'	По умолчанию используется наименование операции "SaveObject".<P/>
	'	Свойство доступно как для чтения, так и для изменения.
	':См. также:	
	'	ObjectEditorClass.Save, <P/>
	'	<LINK stdOp_SaveObject, Операция SaveObject - запись данных ds-объектов/>
	':Сигнатура:	
	'	Public Property Get SaveCommandName [As String]
	'	Public Property Let SaveCommandName( sCommandName [As String] )
	Public Property Get SaveCommandName
		SaveCommandName = m_sSaveCommandName
	End Property
	Public Property Let SaveCommandName(sCommandName)
		m_sSaveCommandName = sCommandName
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetHtmlID
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetHtmlID>
	':Назначение:	
	'	Возвращает строку с идентификатором HTML-элемента, соответствующего 
	'	заданному свойству объекта.
	':Примечание:
	'	В UI редактора каждому элементу представления (так называемому редактору 
	'	свойства - property editor, PE) в итоговом HTML-представлении сответствует 
	'	определенный HTML-элемент. Для каждого такого HTML-элемента редактор генерирует 
	'	уникальный идентификатор (атрибут ID для HTML-тега).
	':См. также:	
	'	SplitHtmlID
	':Сигнатура:	
	'	Public Function GetHtmlID( oXmlProperty [As IXMLDOMElement] ) [As String]
	Public Function GetHtmlID(oXmlProperty)
		const HTML_ID_PREFIX = "PE"
		With oXmlProperty.parentNode
			GetHtmlID = HTML_ID_PREFIX & "$" & oXmlProperty.tagName & "@" & .tagName & "(" & .getAttribute("oid") & ")"
		End With	
	End Function

	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SplitHtmlID
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE SplitHtmlID>
	':Назначение:	
	'	Выделяет из заданного идентификатора HTML-элемента, соответствующего 
	'	редактору свойства объекта, идентификатор и наименование типа объекта, 
	'	а так же наименование свойства.
	':Параметры:
	'	sHtmlID			- [in] исходный идентификатор HTML-элемента
	'	sObjectType		- [out] наименование типа ds-объекта
	'	sObjectID		- [out]	идентификатор ds-объекта
	'	sPropertyName	- [out]	наименование свойства
	':Результат:
	'	Логический признак корректного формата исходного идентификатора:
	'	- True - заданный идентификатор имеет корректный формат. Выделение всех
	'			элементов (идентификатор и тип объекта, имя свойства) выполнено
	'			успешно.
	'	- False - заданный идентификатор имеет некорректный формат. Значения
	'			параметров sObjectType, sObjectID и sPropertyName - неопределены.
	':См. также:
	'	GetHtmlID
	':Сигнатура:
	'	Public Function SplitHtmlID ( 
	'		sHtmlID [As String], 
	'		sObjectType [As String], 
	'		sObjectID [As String], 
	'		sPropertyName [As String] 
	'	) [As Boolean]
	Public Function SplitHtmlID( sHtmlID, sObjectType, sObjectID, sPropertyName )
		const IDX_PROPERTY_NAME = 0
		const IDX_OBJECT_TYPE	= 1
		const IDX_OBJECT_ID		= 2
		SplitHtmlID = False
		With m_oParseHtmlIDRegExp.Execute(sHtmlID)
			If 1=.Count Then
				With .Item(0).SubMatches
					If 3=.Count Then
						sObjectType = .Item(IDX_OBJECT_TYPE)
						sObjectID = .Item(IDX_OBJECT_ID)
						sPropertyName = .Item(IDX_PROPERTY_NAME)   
						SplitHtmlID = True
					End If
				End With
			End If
		End With  
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.XmlObjectPool
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE XmlObjectPool>
	':Назначение:	Возвращает XML-данные текущего пула.
	':Примечание:	Внимание! Непосредственное изменение данных в полученом XML 
	'				не рекомендуется! Используйте методы класса XObjectPoolClass.
	':См. также:	ObjectEditorClass.Pool, XObjectPoolClass
	':Сигнатура:	Public Property Get XmlObjectPool [As IXMLDOMElement]
	Public Property Get XmlObjectPool
		Set XmlObjectPool = m_oPool.Xml
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.Pool
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE Pool>
	':Назначение:	Возвращает ссылку на экземпляр пула данных, используемого 
	'				в редакторе в момент вызова.
	':См. также:	ObjectEditorClass.XmlObjectPool, XObjectPoolClass
	':Сигнатура:	Public Property Get Pool [As XObjectPoolClass]
	Public Property Get Pool
		Set Pool = m_oPool
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SetXmlPropertyDirty
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE SetXmlPropertyDirty>
	':Назначение:	Помечает указанное свойство как модифицированное.
	':Параметры:	oXmlProperty - [in] свойство, помечаемое как модифицированное.
	':Примечание:	Признак модифициованного свойства сохраняется в пуле данных.<P/>
	'				Данные всех свойств, помеченных как модифицированные, будут 
	'				переданы на сервер для записи.
	':См. также:	ObjectEditorClass.Save
	':Сигнатура:	Public Sub SetXmlPropertyDirty( oXmlProperty [As IXMLDOMElement] )
	Public Sub SetXmlPropertyDirty(oXmlProperty)
		m_oPool.SetXmlPropertyDirty oXmlProperty
	End Sub
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ExecuteStatement
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE ExecuteStatement>
	':Назначение:	
	'	Выполняет выражение VBScript, с предврительной подстановкой в выражение 
	'	ссылки на значения свойств объекта (см. Замечания).
	':Параметры:
	'	oXmlObject - [in] объект (XMLDOMElement корневого узла объекта)
	'	sStmt - [in] строка с вычисляемым выражением (см. Замечания)
	':Примечания:
	'	Строка с выражением VBScript может включать подстановки вида 
	'	<B>item.<I>PropName1</I>{<I>.PropNameN</I>}</B>, где <B>item</B> - указание
	'	на подстановку, а <B>PropName1</B>, <B>PropNameN</B> - цепочка наименований 
	'	свойств объекта.<P/>
	'	Перед выполнением выражения VBScript метод заменяет все подстановки на 
	'	значения соответствующих свойств, полученных по цепочке наименований, 
	'	заданных в подстановке.
	':Результат:
	'	Вычесленное значение выражения. 
	':См. также:	
	'	XObjectPoolClass.ExecuteStatement
	':Сигнатура:	
	'	Public Function ExecuteStatement( 
	'		oXmlObject [As IXMLDOMElement], ByVal sStmt [As String]
	'	) [As Variant]
	Public Function ExecuteStatement( oXmlObject, ByVal sStmt)
		ExecuteStatement = m_oPool.ExecuteStatement(oXmlObject, sStmt)
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetPropertyValue
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetPropertyValue>
	':Назначение:	
	'	Получает значение скалярного необъектного свойства, заданного OPath-путем.
	':Параметры:	
	'	sOPath - [in] строка с цепочкой свойств, в форме перечня имен объектных 
	'			свойств, разделенными символом ".", завершающаяся именем скалярного 
	'			необъектного свойства
	':Результат:
	'	Типизированное значение скалярного необъектного свойства или Null, если 
	'	значение свойства не задано (свойство "пустое").<P/>
	'	В том случае, если sOPath заканчивается именем объектного свойства (надо 
	'	понимать, что это некорректное использование), метод возвращает Null для 
	'	неустановленных ("пустых") свойств, и строку "[object]" для установленных.<P/>
	'	В случае ошибки загрузки данных свойства с сервера метод генерирует ошибку
	'	времени исполнения.	
	':См. также:	
	'	XObjectPoolClass.GetPropertyValue
	':Сигнатура:	
	'	Public Function GetPropertyValue( sPropertyPath [As String] ) [As Variant]
	Public Function GetPropertyValue(sPropertyPath)
		GetPropertyValue = m_oPool.GetPropertyValue(XmlObject, sPropertyPath)
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CreateXmlObjectNavigator
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE CreateXmlObjectNavigator>
	':Назначение:	
	'	Создает экземпляр XmlObjectNavigatorClass для текущего ("корневого") 
	'	объекта, и разворачивает в нем все цепочки свойств, заданные элементами 
	'	i:preload в описании редактора в метаданных.
	':Результат:
	'	Польностью инициализированный экземпляр "навигатора" XmlObjectNavigatorClass.
	':См. также:
	'	ObjectEditorClass.CreateXmlObjectNavigatorFor, ObjectEditorClass.XmlObject, 
	'	XmlObjectNavigatorClass
	':Сигнатура:
	'	Public Function CreateXmlObjectNavigator [As XmlObjectNavigatorClass]
	Public Function CreateXmlObjectNavigator
		Dim oPreload
		Set CreateXmlObjectNavigator = CreateXmlObjectNavigatorFor(XmlObject)
		For Each oPreload In m_oInterfaceMD.selectNodes("i:preload")
			CreateXmlObjectNavigator.ExpandProperty oPreload.nodeTypedValue
		Next
	End Function

	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CreateXmlObjectNavigatorFor
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE CreateXmlObjectNavigatorFor>
	':Назначение:	
	'	Создает экземпляр XmlObjectNavigatorClass для заданного ds-объекта.
	':Параметры:
	'	oXmlObject - [in] ds-объект, для которого создается "навигатор"
	':Результат:
	'	Польностью инициализированный экземпляр "навигатора" XmlObjectNavigatorClass.
	':См. также:
	'	ObjectEditorClass.CreateXmlObjectNavigator, XmlObjectNavigatorClass
	':Сигнатура:
	'	Public Function CreateXmlObjectNavigatorFor( 
	'		oXmlObject [As IXMLDOMElement]
	'	) [As XmlObjectNavigatorClass]
	Public Function CreateXmlObjectNavigatorFor(oXmlObject)
		Set CreateXmlObjectNavigatorFor = New XmlObjectNavigatorClass
		CreateXmlObjectNavigatorFor.Attach Me, GetXmlObjectFromPoolByXmlElement(oXmlObject, Null)
	End Function

	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetXmlObjectFromPool
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetXmlObjectFromPool>
	':Назначение:	
	'	Возвращает из пула ds-объект, заданный типом и идентификтором.
	':Параметры:
	'	sObjectType - [in] наименвоание типа объекта
	'	sObjectID	- [in] идентификатор объекта
	'	sPreloads	- [in] список прогружаемых свойств объекта, подгружаемых 
	'					на сервере, в случае если данные объекта загружаются
	':Результат:
	'	XML-данные объекта, как экземпляр IXMLDOMElement.
	':Примечание:	
	'	Если запрошенный объект в пуле отсутствует, то метод загружает данные 
	'	объекта в пул, запрашивая их с сервера.
	':См. также:	
	'	ObjectEditorClass.GetXmlObjectFromPoolByXmlElement, 
	'	XObjectPoolClass.GetXmlObject
	':Сигнатура:
	'	Public Function GetXmlObjectFromPool(
	'		sObjectType [As String], 
	'		sObjectID [As String], 
	'		sPreloads [As String] 
	'	) [As IXMLDOMElement]
	Public Function GetXmlObjectFromPool(sObjectType, sObjectID, sPreloads)
		Set GetXmlObjectFromPool = m_oPool.GetXmlObject( sObjectType, sObjectID, sPreloads)
	End Function

	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetXmlObjectFromPoolByXmlElement
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetXmlObjectFromPoolByXmlElement>
	':Назначение:	
	'	Возвращает из пула ds-объект, заданный XML-данными (в том числе - "заглушкой").
	':Параметры:
	'	oXmlObjectElement - [in] XML-данные, в точ числе - "заглушка"
	'	sPreloads - [in] список прогружаемых свойств объекта, подгружаемых на сервере, 
	'				в случае если данные объекта загружаются
	':Примечание:	
	'	Если запрошенный объект в пуле отсутствует, то метод загружает данные 
	'	объекта в пул, запрашивая их с сервера.
	':См. также:	
	'	ObjectEditorClass.GetXmlObjectFromPool, XObjectPoolClass.GetXmlObject
	':Сигнатура:
	'	Public Function GetXmlObjectFromPoolByXmlElement(
	'		oXmlObjectElement [As IXMLDOMElement], sPreloads [As String] 
	'	) [As IXMLDOMElement]
	Public Function GetXmlObjectFromPoolByXmlElement(oXmlObjectElement, sPreloads)
		Set GetXmlObjectFromPoolByXmlElement = GetXmlObjectFromPool(oXmlObjectElement.tagName, oXmlObjectElement.getAttribute("oid"), sPreloads)
	End Function

	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.LoadXmlProperty
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE LoadXmlProperty>
	':Назначение:	
	'	Загружает заданное свойство XML-объекта с сервера.
	':Параметры:
	'	oXmlObject - [in] объект (IXMLDOMElement корневого узла объекта); 
	'			может  быть Nothing, если vProp - XML-свойство (IXMLDOMElement)
	'	vProp - [in] свойство объекта (XmlDOMElement), или строка с именем свойства
	'	bReload - [in] признак перезагрузки, если свойство уже загружено
	':Результат:
	'	Загруженные XML-данные свойства, как экземпляр IXMLDOMElement. Если свойство 
	'	не найдено, возвращается Nothing.
	':См. также:	
	'	ObjectEditorClass.GetXmlObjectFromPool, XObjectPoolClass.LoadXmlProperty
	':Сигнатура:
	'	Public Function LoadXmlProperty( 
	'		oXmlObject [As IXMLDOMElement], vProp [As Variant] 
	'	) [As IXMLDOMElement]
	Public Function LoadXmlProperty( oXmlObject, vProp )
		Set LoadXmlProperty = m_oPool.LoadXmlProperty( oXmlObject, vProp )
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.Init
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE Init>
	':Назначение:	
	'	Инициализация объекта редактора (см. раздел "Замечания").
	':Параметры:	
	'	oObjectContainerEventsImp - [in] экземпляр класса, реализующего "интерфейс" 
	'				контейнера IObjectContainerEventsClass (см. спецификацию)
	'	oParams - [in] исходные данные инициализации редактора, экземляр класса 
	'				ObjectEditorInitializationParametersClass (см. спецификацию)
	':Результат:	
	'	Логический признак успешного завершения инициализации редактора.
	':Примечание:
	'	Процесс инициализации редактора выполняется по следующему сценарию:
	'	- анализ корректности и сохранение заданных параметров инициализации
	'		(см. спецификацию ObjectEditorInitializationParametersClass);
	'	- инициализация обработчиков событий редактора (см. <LINK cee-5, Статическое связывание />);
	'	- анализ метаописания редактора (см. <LINK oe-4, Описание редактора />), 
	'		определение режимов работы (см. <LINK oe-3, Режимы работы редактора />;
	'	- инициализация пула данных (в т.ч. начало логической транзакции, если 
	'		пул был передан в качестве параметра инициализации);
	'	- при необходимости - загрузка данных редактируемого объекта с сервера;
	'	- инициализация пользовательского интерфейса - создание коллекции объектов
	'		EditorPageClass, их инициализация; на этом этапе генерируются события
	'		страницы редактора (см. спецификацию класса EditorPageClass);
	'	- генерация события редактора "Load";
	'	- формирование заголовка редактора; на этом этапе генерируется событие
	'		"SetCaption". Сформированный текст заголовка передается контейнеру - 
	'		вызывается метод IObjectContainerEventsClass.OnSetCaption;
	'	- отображение стартовой страницы редактора.
	':Сигнатура:
	'	Public Function Init(
	'		oObjectContainerEventsImp [As IObjectContainerEventsClass], 
	'		oParams [As ObjectEditorInitializationParametersClass]
	'	) [As Boolean]
	Public Function Init(oObjectContainerEventsImp, oParams)
		' Страница преобразования вкладки по-умолчанию
		Dim oXmlObject			' As IXMLDOMElement - редактируемый xml-объект
		Dim oXmlPage			' As IXMLDOMElement - узел i:page из метаописания редактора
		Dim oPage				' As XEditorPageClass - описание страницы редактора
		Dim j
		Dim oXmlPagesMD			' As IXMLDOMNodeList - коллекция узлов i:page из метаописания редактора
		Dim oEditorPage			' As EditorPageClass - страница редактора
		Dim oPreload			' As IXMLDOMElement - i:preload в метаданных
		Dim sPreload			' Список из i:preload
		Dim oNode				' As IXMLDOMNode
		Dim bEnlistInCurrentTransaction	' As Boolean - признак того, что редактор работает в текущей транзакции пула и не начинает/отменяет новой транзакции
		Dim nEditorStartPageIndex	' As Integer - индекс страницы многозакладочного редактора, которая будет открыта после завершения инициализации
		Dim oLoadedXmlObject		' As IXMLDOMElement - xml-объект, загруженный на сервере
		
		MayBeInterrupted = False
		
		With oParams
			m_sObjectType = .ObjectType
			m_sObjectID = .ObjectID
			m_sMetaName	 = vbNullString & .MetaName
			m_bCreateNewObject = .CreateNewObject
			m_bAggregation = .IsAggregation
			m_sParentObjectID = .ParentObjectID
			m_sParentObjectType = .ParentObjectType
			m_sParentPropertyName = .ParentPropertyName
			bEnlistInCurrentTransaction = .EnlistInCurrentTransaction
			Set m_oQueryString = .QueryString
			Set oXmlObject = .XmlObject
			Set m_oParentObjectEditor = .ParentObjectEditor
			Set m_oInterfaceMD = .InterfaceMD
			m_bSkipInitErrorAlerts = .SkipInitErrorAlerts
		End With
		
		' проверим входные параметры
		If oXmlObject Is Nothing And ( Len("" & m_sObjectType)=0 Or Len("" & m_sObjectID)=0 And Not m_bCreateNewObject) Then
			Err.Raise -1, "ObjectEditor::Init", "Должен быть задан Xml-объект, либо тип и идентификатор (в режиме создания может быть не задан)"
		End If
		Set m_oObjectContainerEventsImp = oObjectContainerEventsImp

		' метаданные редактора всегда должны быть заданы (см. x-editor.aspx.cs::GetPageMD)
		If IsNothing(m_oInterfaceMD) Then
			Err.Raise -1, "ObjectEditor::Init", "Не заданы метаданные редактора"
		End If
		' установим наименование команды сохранения
		m_sSaveCommandName = m_oInterfaceMD.GetAttribute("save-cmd")
		If IsNull(m_sSaveCommandName) Then m_sSaveCommandName = "SaveObject"
		
		' инициализируем коллекцию обработчиков событий редактора статическим биндингом (по маске имени процедуры)
		m_oEventEngine.InitHandlers EVENTS, "usrXEditor_On"
		m_oEventEngine.AddHandlerForEventWeakly "DeleteObjectConflict", Me, "OnDeleteObjectConflict"
		m_oEventEngine.AddHandlerForEventWeakly "GetObjectConflict", Me, "OnGetObjectConflict"
		
		' Если метаимя явно не задали, алгоритм поиска метаописания редактора все равно нашел некоторый узел i:editor.
		' Получим его метаимя. Если метаимя редактора было задано явно, то мы его и получим.
		m_sMetaName = vbNullString & m_oInterfaceMD.GetAttribute("n")
		
		' Получаем признак работы мастера при возврате на предыдущую страницу.
		If IsNull(m_oInterfaceMD.GetAttribute("wizard-mode")) Then
			m_bIsTabbed	=  True
		Else
			m_bIsTabbed	=  False
			m_nDefaultBackMode = ParseWizardBackMode( m_oInterfaceMD.getAttribute("wizard-mode") )
		End If
		
		' Пул
		m_bManageCurrentTransaction = False
		If IsNothing(m_oParentObjectEditor) Then
			' родительский ObjectEditor не задан - нас запустили как корневой редактор 
			m_bIncluded = False
			' Однако, может быть задан пул
			If IsNothing(oParams.Pool) Then
				' пул не задан - создадим новый пул
				Set m_oPool = New XObjectPoolClass
				' т.к. пул создаем мы сами, то вызывающий код никак не сможет его получить, поэтому задание признака агрегации явная ошибка
				If m_bAggregation Then
					Err.Raise -1, "ObjectEditorClass::Init", "Для корневого редактор, в случае, если пул объектов не задан снаружи, задание признака агрегации бессмысленно"
				End If
				' раз мы сами создаем пул, то и признак EnlistInCurrentTransaction тоже бессмыселен, т.к. внешней транзакции не существует
				If bEnlistInCurrentTransaction Then
					Err.Raise -1, "ObjectEditorClass::Init", "Для корневого редактор, в случае, если пул объектов не задан снаружи, признак задание признака EnlistInCurrentTransaction бессмысленно, т.к. внешней транзакции не существует"
				End If
				' хотя пул и не задан, может быть задано множество объектов для его первоначального наполнения
				If Not oParams.InitialObjectSet Is Nothing Then
					For Each oNode In oParams.InitialObjectSet.selectNodes("*[*]")
						m_oPool.AppendXmlObject oNode.CloneNode(true)
					Next
				End If
			Else
				' пул задан
				Set m_oPool = oParams.Pool
				' Т.к. пул задан снаружи, то хотя родительского редактора и нет, но мы уже не совсем корневой редактор, по
				' крайнем мере начинать физическую транзакцию мы не можем (пока что не поддерживается)
				If Not m_bAggregation Then
					Err.Raise -1, "ObjectEditorClass::Init", "Для корневого редактора с заданным снаружи пулом объектов должен быть задан признак агрегации (Aggregation)"
				End If
				' если явно не запретили, то начнем новую транзакцию
				If Not bEnlistInCurrentTransaction Then
					m_bManageCurrentTransaction = True
					m_oPool.BeginTransaction True ' т.к. m_bAggregation = True
				End If
			End If
		Else
			' иначе нас запустили как вложенный редактор, получим пул из родительского редактора и начнем в нем новую транзакцию
			m_bIncluded = True
			Set m_oPool = m_oParentObjectEditor.Pool
			' На текущем этапе физические транзакции пула поддерживаются только на корневом уровне, поэтому проверим, что m_bAggregation=True
			If Not m_bAggregation Then
				Err.Raise -1, "ObjectEditorClass::Init", "Для вложенного редактора должен быть всегда задан признак агрегации (Aggregation), т.к. начинать новую ""физическую"" транзакцию может только корневой редактор"
			End If
			' если явно не запретили, то начнем новую транзакцию
			If Not bEnlistInCurrentTransaction Then
				m_bManageCurrentTransaction = True
				m_oPool.BeginTransaction True ' т.к. m_bAggregation = True
			End If
		End If
		
		' Зарегистрируем текущий редактор в пуле, чтобы получать из него события
		m_oPool.RegisterEditor Me

		' если редактируемого объекта не было на клиенте (проверяли в x-utils.vbs::ObjectEditorDialogClass::Show), 
		' то он сразу будет загружен на сервере в скрытое поле oObjectData - ОПТИМИЗАЦИЯ!
		' (объект будет загружен со всеми прелоадами)

		Set oLoadedXmlObject = document.all("oObjectData",0)
		If Not oLoadedXmlObject Is Nothing Then
			Set oLoadedXmlObject = XService.XmlFromString( oLoadedXmlObject.value )
			' поищем упоминание объектов в локальном кэше на диске. 
			If Not oLoadedXmlObject Is Nothing Then
				m_oPool.Internal_AppendXmlObjectTreeFromServer oLoadedXmlObject
			End If
		End If
		
		
		' удостоверимся, что редактируемый объект содержится в пуле
		If IsNothing(oXmlObject) Then
			' Нам передали тип и идентификатор объекта
			ReportStatus "Загрузка данных с сервера..."
			sPreload = Empty
			For Each oPreload In m_oInterfaceMD.selectNodes("i:preload")
				If IsEmpty(sPreload) Then
					sPreload =  oPreload.nodeTypedValue
				Else
					sPreload = 	sPreload & " " & oPreload.nodeTypedValue
				End If	
			Next
			Set oXmlObject = m_oPool.GetXmlObject( m_sObjectType, m_sObjectID, sPreload)
			If Not oXmlObject Is Nothing Then m_sObjectID = oXmlObject.getAttribute("oid")
		Else
			' Передали xml-объект
			ReportStatus "Инициализация данных для редактирования..."
			m_sObjectID   = oXmlObject.getAttribute("oid")
			m_sObjectType = oXmlObject.tagName
			If Not IsNull(oXmlObject.getAttribute("new")) Then
				' передали xml шаблон нового объекта - занесем его в пул, если его там нет
				m_oPool.AppendXmlObject oXmlObject
			Else
				' передали не новый xml-объект. Таким образом нам сообщают тип и oid редактируемого объекта
				' А у нового объекта i:preload не имеет смысла
				Set oXmlObject = m_oPool.GetXmlObject( m_sObjectType, m_sObjectID, Empty)
			End If
		End If
		If oXmlObject Is Nothing Then
			With X_GetLastError
				If .IsObjectNotFoundException Then
					Init = "Запрошенный объект не найден. Возможно он был удален"
				ElseIf .IsSecurityException Then
					Init = "Доступ к запрошенному объекту запрещен"
				End If
			End With
			MayBeInterrupted = True			
			Exit Function
		End If
		
		' включим редактируемый объект в транзакцию
		m_oPool.EnlistXmlObjectIntoTransaction XmlObject
		
		' пытаемся проинициировать новый объект параметрами из URL
		ReportStatus "Инициализация значений реквизитов..."
		ApplyURLParams
		
		' В зависимости от режима инициализируем
		ReportStatus "Инициализация пользовательского интерфейса..."

		' Получаем коллекцию страниц редактора
		Set m_oPages = CreateObject("Scripting.Dictionary")
		m_oPages.CompareMode = vbTextCompare
		Set oXmlPagesMD = InterfaceMD.selectNodes("i:page")
		j=1
		For Each oXmlPage In oXmlPagesMD
			If IsNull(oXmlPage.GetAttribute("n")) Then
				oXmlPage.SetAttribute "n", "PAGE_" & j
			End If
			j=j+1
			Set oEditorPage = New EditorPageClass
			oEditorPage.Init Me, oXmlPage
			m_oPages.Add oEditorPage.PageName, oEditorPage
		Next

		' выбросим событие Load, стандартный обработчик отсутствует
		nEditorStartPageIndex = 0
		If m_oEventEngine.IsHandlerExists("Load") Then
			With New EditorLoadEventArgsClass
				fireEvent "Load", .Self()
				nEditorStartPageIndex = .StartPageIndex
				If nEditorStartPageIndex >= m_oPages.Count Then
					Alert "Прикладной обработчик события Load редактора установил некорректное значение свойства StartPageIndex параметров события: " & nEditorStartPageIndex
					nEditorStartPageIndex = 0
				End If
				If Len("" & .ErrorDescription) > 0 Then
					Init = .ErrorDescription
					MayBeInterrupted = True			
					Exit Function
				End If
			End With
		End If

		m_oObjectContainerEventsImp.OnInitializeUI Me, Null
		
		If IsEditor Then
			' Устанавливаем заголовок
			setCaptionInternal ""
			If IsMultipageEditor Then
				' Много страниц - инициализируем закладки
				For Each oPage In m_oPages.Items
					m_oObjectContainerEventsImp.OnAddEditorPage Me, oPage, Null
				Next
				' если индекс стартовой страницы не 0, то сделаем активной нужную закладку
				If nEditorStartPageIndex > 0 Then
					m_oObjectContainerEventsImp.OnActivateEditorPage Me, nEditorStartPageIndex, Null
				End If
			End If

			' Формируем стартовую страницу редактора
			ShowEditorPage GetPageByIndex(nEditorStartPageIndex)
		Else
			If IsLinearWizard Then
				' Ага, мастер линейный, покажем первую страницу
				LinearWizardShowPage 1
			ElseIf m_oPages.Count > 0 Then
				' Нелинейный мастер, и задана 1-я страница - отображаем ее
				NonlinearWizardShowPage GetPageByIndex(0)
			Else
				' Нелинейный мастер с незаданной 1-ой страницей - сначала получим информацию об отображаемой странице от прикладного кода
				NonlinearWizardShowPage GetWizardNextPageInfo(0)
			End If
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.WizardGoToNextPage
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE WizardGoToNextPage>
	':Назначение:	Инициирует переход на следующую страницу мастера.
	':Примечания:	В процессе выполнения метода редактор выполняет сбор данных,
	'				а так же генерирует событие HasNextPage (в случае режима 
	'				"нелинейного мастера").<P/>
	'				При переключении страниц генерируются события редактора		
	'				BeforePageEnd, ValidatePage, PageEnd, BeforePageStart и PageStart.
	':См. также:	ObjectEditorClass.WizardGoToPrevPage
	':Сигнатура:	Public Sub WizardGoToNextPage
	Public Sub WizardGoToNextPage
		Dim oPage		' As XEditorPageClass - описание следующей страницы мастера
		
		If Not IsWizard Then Err.Raise -1, "ObjectEditorClass::WizardGoToNextPage", "Method supported only for Wizard"
		EnableControls False
		If GetData( REASON_WIZARD_NEXT_PAGE , False ) Then
			If IsLinearWizard Then
				' Линейный мастер
				' Если следующая страница имеет режим мастера "откат изменений", то до перехода на нее сделаем бекап пула
				' Примечание: CurrentPageNo - номер шага, на 1 больше индекса
				If GetPageByIndex(CurrentPageNo).BackMode = XEB_UNDOCHANGES Then
					m_oPool.BackUp
				End If
				LinearWizardShowPage CurrentPageNo + 1
			Else		
				' Нелинейный мастер - получим описание страницы от пользовательского обработчика события GetNextPageInfo
				Set oPage = GetWizardNextPageInfo(CurrentPageNo)
				If oPage.BackMode = XEB_UNDOCHANGES Then
					m_oPool.BackUp
				End If
				NonlinearWizardShowPage oPage
			End If	
		Else
			' сбор и валидация данных не удалась - остаемся на страницы - раздизейблим контролы
			EnableControls True
		End If
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.WizardGoToPrevPage
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE WizardGoToPrevPage>
	':Назначение:	Переход на предыдущую страницу мастера.
	':Примечания:	В процессе выполнения метода редактор выполняет сбор данных.<P/>
	'				При переключении страниц генерируются события редактора		
	'				BeforePageEnd, ValidatePage, PageEnd, BeforePageStart и PageStart.
	':См. также:	ObjectEditorClass.WizardGoToNextPage
	':Сигнатура:	Public Sub WizardGoToPrevPage
	Public Sub WizardGoToPrevPage
		If Not IsWizard Then Err.Raise -1, "ObjectEditorClass::WizardGoToPrevPage", "Method supported only for Wizard"
		EnableControls False
		If CurrentPage.BackMode = XEB_TRY_GET_DATA Then
			' надо собрать данные при уходе
			If Not GetData( REASON_WIZARD_PREV_PAGE, False  ) Then
				' не удалось собрать. т.к. SilentMode мы задали в False, то в GetData будет показано сообщение. 
				' Здесь же просто раздизейблим контролы и выйдем
				EnableControls True
				Exit Sub
			End If
		ElseIf CurrentPage.BackMode = XEB_UNDOCHANGES Then
			' Откатим состояние пула в то, каким он был до захода на текущую страницу
			m_oPool.Undo
		End If
		' покажем предыдущую страницу
		If IsLinearWizard Then
			LinearWizardShowPage CurrentPageNo - 1
		Else
			' Не удалось. Надо брать имя предыдущей страницы из стека
			With PageStack 
				' Пропускаем текущую страницу в стеке
				.Pop
				' И переходим на предыдущую
				NonlinearWizardShowPage m_oPages.Item(.Pop)
			End With
		End If
	End Sub	


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CanSwitchPage
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE CanSwitchPage>
	':Назначение:	Возвращает признак "разрешения" переключения страницы.
	':Результат:	True, если в редакторе можно переключить страницу, False - иначе.
	':Примечание:	Суть функции - это проверка корректности и наличия данных, 
	'				введенных пользователем на текущей странице. В процессе проверки
	'				редактор осуществляет сбор данных и генерирует события 
	'				BeforePageEnd, ValidatePage, PageEnd.<P/>
	'				Внимание: в случае успешного сбора данных все элементы страницы 
	'				остаются заблокированными (disabled).
	':Сигнатура:	Public Function CanSwitchPage [As Boolean]
	Public Function CanSwitchPage
		If Not IsEditor Then Err.Raise -1, "ObjectEditorClass::CanSwitchPage", "Method supported only for Editor"
		EnableControls False
		CanSwitchPage = GetData( REASON_PAGE_SWITCH, False)
		If Not CanSwitchPage Then
			' если не получилось собрать данные - раздизейблим контролы
			EnableControls True
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SwitchToPageByPageID
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE SwitchToPageByPageID>
	':Назначение:	Переход на страницу с заданным идентификатором.
	':Параметры:	sPageID - [in] идентфикатор целевой страницы
	':Сигнатура:	Public Sub SwitchToPageByPageID( sPageID [As String] )
	Public Sub SwitchToPageByPageID(sPageID)
		If Not IsEditor Then Err.Raise -1, "ObjectEditorClass::SwitchToPageByPageID", "Method supported only for Editor"
		If m_oPages.Exists(sPageID) Then
			ShowEditorPage m_oPages.item(sPageID)
		Else
			Err.Raise -1, "SwitchToPageByPageID", "Неизвестное имя страницы"
		End If
	End Sub


	'------------------------------------------------------------------------------
	':Назначение:	Отображение страницы редактора
	':Параметры:	oEditorPage - [in] объект страницы редактора, EditorPageClass
	Private Sub ShowEditorPage(oEditorPage)
		SetEditorButtons oEditorPage
		' Формируем HTML-вкладку
		MakeHTMLForm oEditorPage 
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.NonlinearWizardShowPage
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE NonlinearWizardShowPage>
	':Назначение:	Отображение страницы нелинейного мастера.
	':Параметры:	oEditorPage - [in] объект страницы мастера, экземпляр EditorPageClass
	':Примечание:	В процессе выполнения метода редактор генерирует событие HasNextPage.
	':Сигнатура:	Public Sub NonlinearWizardShowPage( oEditorPage [As EditorPageClass] )
	Public Sub NonlinearWizardShowPage(oEditorPage)
		Dim nStep		 ' номер шага
		
		With PageStack
			' Заносим переданную страницу в стек
			.Push oEditorPage.PageName
			nStep = .Length
			m_nCurrentPageNo = nStep
			' Устанавливаем заголовок
			setCaptionInternal oEditorPage.PageTitle
			' Покажем нужные кнопки 
			'	-Кнопка "назад" нужна только при наличии предыдущей страницы в стеке
			'	-Кнопка "вперёд" доступна только при наличии следующей ...
			With New HasNextPageEventArgsClass
				fireEvent "HasNextPage", .Self()
				SetWizardButtons nStep=1, Not (.ReturnValue = True), oEditorPage
			End With
			' И отрендерим её
			MakeHTMLForm oEditorPage
		End With	
	End Sub


	'------------------------------------------------------------------------------
	':Назначение:	Отображение страницы линейного мастера
	':Параметры:	nStep - [in] текущий номер шага
	Private Sub LinearWizardShowPage( nStep )
		Dim oPage		' As XEditorPageClass

		m_nCurrentPageNo = nStep
		' индекс от 0, а шаги от 1, поэтому "-1"
		Set oPage = GetPageByIndex(nStep - 1)
		' Выставим заголовок
		setCaptionInternal oPage.PageTitle
		' Покажем нужные кнопки 
		SetWizardButtons nStep = 1, nStep = m_oPages.Count, oPage
		' Покажем страницу
		MakeHTMLForm oPage
	End Sub


	'------------------------------------------------------------------------------
	':Назначение:	Возвращает проинициализированный экземпляр EditorPageClass для 
	'				страницы нелинейного мастера c заданным номером.
	':Параметры:	nCurrentPageNo - [in] номер текущей страницы (от 1), относительно 
	'				которой получается следующая страница
	':Результат:	Экземпляр EditorPageClass
	':Примечание:	Редактор генерирует событие GetNextPageInfo.
	Private Function GetWizardNextPageInfo(nCurrentPageNo)
		Dim oEditorPage			' As EditorPageClass
		Dim sPageName			' As String - наименование страницы
		
		With New GetNextPageInfoEventArgsClass
			.PageTitle = "Шаг №" & (nCurrentPageNo+ 1)
			sPageName = "step" & (nCurrentPageNo + 1)
			fireEvent "GetNextPageInfo", .Self()
			If .PageBuilder Is Nothing Then
				Err.Raise -1, "WizardGoToNextPage", "Некорректный обработчик OnGetNextPageInfo: PageBuilder Is Nothing"
			End If
			If m_oPages.Exists(sPageName) Then
				If m_oPages.Item(sPageName ).PageBuilder.IsEqual(.PageBuilder) Then
					Set oEditorPage = m_oPages.Item(sPageName)
				Else
					m_oPages.Remove(sPageName)
				End If
			End If
			If IsEmpty(oEditorPage) Then
				Set oEditorPage = New EditorPageClass
				oEditorPage.CanBeCached = .CanBeCached
				' режим мастера для страницы 
				oEditorPage.BackMode	= iif( hasValue(.BackMode), .BackMode, DefaultBackMode )
				oEditorPage.InitIndirect Me, .PageBuilder, sPageName, .PageTitle
				m_oPages.Add sPageName, oEditorPage
			End If
		End With
		Set GetWizardNextPageInfo = oEditorPage
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetPageByIndex
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetPageByIndex>
	':Назначение:	Возвращает объект страницы (EditorPageClass) по заданному 
	'				индексу страницы.
	':Параметры:	nIndex - [in] индекс целевой страницы (начало индексации - от 0)
	':Результат:	Объект страницы редактора, экземпляр EditorPageClass.
	':Сигнатура:	
	'	Public Function GetPageByIndex( nIndex [As Int] ) [As EditorPageClass]
	Public Function GetPageByIndex(nIndex)
		Set GetPageByIndex = m_oPages.Items()(nIndex)
	End Function


	'------------------------------------------------------------------------------
	':Назначение:	Запускает процесс отображения заданной страницы.
	':Параметры:	oEditorPage - [in] экземпляр отображаемой страницы, EditorPageClass
	Private Sub MakeHTMLForm( oEditorPage )
		If Not IsNothing(m_oActivePage) Then
			m_oActivePage.Hide
		End If
		Set m_oActivePage = oEditorPage
		If m_oActivePage.NeedBuilding Or Not m_oActivePage.CanBeCached Then
			m_oActivePage.PrepareForRender
		End If
		m_oActivePage.Show
		XService.DoEvents
		' Если есть пользовательский обработчик, вызываем его
		fireEvent "BeforePageStart", Nothing
		CreateAndInitializeHtmlForm false
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.RebuildCurrentPage
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE RebuildCurrentPage>
	':Назначение:	
	'	Перестраивает HTML-представление текущей страницы редактора.
	':Примечание:
	'	В отличие от метода ObjectEditorClass.CreateAndInitializeHtmlForm, этот 
	'	метод перестаривает представление текущей страницы редактора безусловно.
	':См. также:
	'	ObjectEditorClass.CreateAndInitializeHtmlForm
	':Сигнатура:	
	'	Public Sub RebuildCurrentPage
	Public Sub RebuildCurrentPage
		' Может окно уже закрыли...
		If IsInterrupted = True Then Exit Sub
		MayBeInterrupted = False
		ReportStatus "Инициализация страницы..."
		If IsInterrupted = True Then Exit Sub
		If Not CurrentPage.Build Then Exit Sub
		' Может окно уже закрыли...
		If IsInterrupted = True Then Exit Sub
		' И дожидаемся прогрузки и инициализации всех объектов, вставленных через Xsl...
		X_WaitForTrue UniqueID & ".CreateAndInitializeHtmlFormStep2" , UniqueID & ".CurrentPage.IsReady"			
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CreateAndInitializeHtmlForm
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE CreateAndInitializeHtmlForm>
	':Назначение:	
	'	Формирует и инициализирует HTML-представление текущей страницы редактора.
	':Параметры:	
	'	bForceRefreshUI - [in] флаг, указывающий на принудительное перестроение 
	'		HTML-представлений всех отображаемых редакторов свойств: True - все
	'		представления перестраиваются, False - используются существующие 
	'		(если таковые есть; в этом случае выполняется только переустановка 
	'		данных в редакторах свойств)
	':Примечание:
	'	В отличие от метода ObjectEditorClass.RebuildCurrentPage, этот метод 
	'	формирует представление (страницы) редактора если (а) представление 
	'	еще ни разу не формировалось или (б) для страницы указано блокировка 
	'	кеширования ее представления (атрибут off-cache метаописания страницы 
	'	i:page, см. x-net-interface-schema.xsd).
	':См. также:
	'	ObjectEditorClass.RebuildCurrentPage
	':Сигнатура:
	'	Public Sub CreateAndInitializeHtmlForm( bForceRefreshUI [As Boolean] )
	Public Sub CreateAndInitializeHtmlForm(bForceRefreshUI)
		' Может окно уже закрыли...
		If IsInterrupted = True Then Exit Sub
		MayBeInterrupted = False
		If CurrentPage.NeedBuilding Or Not CurrentPage.CanBeCached Then
			ReportStatus "Инициализация страницы..."
			If IsInterrupted = True Then Exit Sub
			' это для того, чтобы последующий EnableControls True действительно раздизейблил контролы
			m_bControlsEnabled = False
			If Not CurrentPage.Build Then Exit Sub
			' Может окно уже закрыли...
			If IsInterrupted = True Then Exit Sub
			CurrentPage.NeedBuilding = False
			If IsInterrupted = True Then Exit Sub
			' И дожидаемся прогрузки и инициализации всех объектов, вставленных через Xsl...
			X_WaitForTrue UniqueID & ".CreateAndInitializeHtmlFormStep2" , UniqueID & ".CurrentPage.IsReady"			
		Else
			EnableControls False
			If bForceRefreshUI Then _
				CurrentPage.InitPropertyEditorsUI
			CreateAndInitializeHtmlFormStep3
		End If
	End Sub	


	'------------------------------------------------------------------------------
	':Назначение:	Строит и инициализирует HTML-форму (шаг 2-й)
	':Примечание:	Метод для внутреннего использования и не должен вызываться явно.
	Public Sub CreateAndInitializeHtmlFormStep2
		' Может окно уже закрыли...
		If IsInterrupted Then Exit Sub	
		ReportStatus ""
		CurrentPage.VisibilityTurnOn
		If IsInterrupted Then Exit Sub	
		CurrentPage.PostBuild
		If IsInterrupted Then Exit Sub
		CreateAndInitializeHtmlFormStep3
	End Sub


	'------------------------------------------------------------------------------
	':Назначение:	Заканчивает построение формы
	':Примечание:	Метод для внутреннего использования и не должен вызываться явно.
	Public Sub CreateAndInitializeHtmlFormStep3
		If IsInterrupted Then Exit Sub
		' Заполняем форму значениями
		CurrentPage.SetData
		' Может окно уже закрыли...
		If IsInterrupted Then Exit Sub
		' Разрешаем управляющие элементы
		EnableControls True
		' Может окно уже закрыли...
		If IsInterrupted Then Exit Sub
		CurrentPage.SetDefaultFocus
		If IsInterrupted Then Exit Sub
		' Если есть пользовательский обработчик, вызываем его
		fireEvent "PageStart", Nothing
		If IsInterrupted Then Exit Sub
		MayBeInterrupted = True 
	End Sub


	'------------------------------------------------------------------------------
	':Назначение:	Рестарт редактора. Используется контейнером редактора в фильтре 
	'				(x-editor-in-filter). Работает только для редактора (не мастера) 
	'				нового (!) объекта.
	':Примечание:	Внимание! 
	'				Метод для внутреннего использования и не должен вызываться явно!
	Public Sub Internal_RestartEditor()
		Dim sObjectID			' Идентификатор редактируемого объекта
		Dim sTypeName			' Тип редактируемого объекта
		Dim nIndex				' As Integer - индекс закладки в x-tab-strip.htc
		Dim oPage				' As EditorPage - текущий объект страницы
		Dim i
		
		sObjectID = ObjectID
		sTypeName = XmlObject.tagName
		' Очистим пул редактора		
		Pool.Clear
		' Создадим в пуле новый объект и восстановим ему идентификатор на прежний
		Pool.CreateXmlObjectInPool(sTypeName).setAttribute "oid", sObjectID
		fireEvent "Load", New EditorLoadEventArgsClass
		For nIndex = 0 To Pages.Count - 1
			Set oPage = GetPageByIndex(nIndex)
			If oPage.IsHidden Then
				If nIndex = Tabs.ActiveTab Then
					For i = 0 To Pages.Count - 1
						If Not Tabs.IsTabHidden(i) Then
							Tabs.ActiveTab = i
							Exit For
						End If
					Next
				End If
				Tabs.HideTab nIndex, True
			End If
		Next
		' Прим: true - значит обновить UI всех редакторов свойств
		CreateAndInitializeHtmlForm true
	End Sub
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SetDefaultFocus
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE SetDefaultFocus>
	':Назначение:	Устанавливает фокус ввода на первый доступный элемент текущей 
	'				страницы редактора.
	':См. также:	EditorPageClass.SetDefaultFocus
	':Сигнатура:	Public Sub SetDefaultFocus
	Public Sub SetDefaultFocus
		If IsInterrupted Then Exit Sub
		CurrentPage.SetDefaultFocus
	End Sub
	

	'------------------------------------------------------------------------------
	':Назначение:
	'	Переносит данные из формы в загруженный Xml-объект и вызывает клиентский
	'	обработчик завершения работы страницы. Вызывает всегда при уходе со страницы:
	'	вперед / назад в мастере, переключение закладки редактора, ОК в редакторе.
	'	Генерирует события: BeforePageEnd, ValidatePage, PageEnd.
	':Параметры:
	'	nReason - [in] параметр, передаваемый в клиентский обработчик
	'	bSilentMode - [in] признак "тихого" ухода со страницы
	':Результат:
	'	Логический признак:
	'	- True - означает "все хорошо" - со страницы можно уходить;
	'	- False - "все плохо", уходить нельзя.
	Private Function GetData( nReason, ByVal bSilentMode )
		Dim oEditorStateChangedArgs		' As EditorStateChangedEventArgsClass
		
		MayBeInterrupted = False
		GetData = False
		' если есть обработчик(и) события "BeforePageEnd", сгенерируем его (стандартных обработчиков нет)
		Set oEditorStateChangedArgs = New EditorStateChangedEventArgsClass
		With oEditorStateChangedArgs
			.Reason = nReason
			fireEvent "BeforePageEnd", .Self()
			If .ReturnValue <> True Then
				If hasValue(.ErrorMessage) Then Alert .ErrorMessage
				MayBeInterrupted = True
				Exit Function
			End If
		End With
		With New GetDataArgsClass
			.Reason = nReason
			' Не будем производить валидацию при обратном шаге мастера (для режима XEB_TRY_GET_DATA)
			bSilentMode = ( REASON_WIZARD_PREV_PAGE = nReason)	OR bSilentMode
			.SilentMode = bSilentMode
			CurrentPage.GetData( .Self )
			If .ReturnValue Then
				oEditorStateChangedArgs.SilentMode = bSilentMode
				oEditorStateChangedArgs.Reason = nReason
				With oEditorStateChangedArgs
					.ErrorMessage = vbNullString
					.ReturnValue = True
					fireEvent "ValidatePage", .Self()
					If .ReturnValue <> True And Not bSilentMode Then
						If HasValue(.ErrorMessage) Then
							Alert .ErrorMessage
						End If
					End If
				End With
			End If
			GetData = .ReturnValue And oEditorStateChangedArgs.ReturnValue
			If GetData <> True Then
				MayBeInterrupted = True
				Exit Function
			End If
		End With
		' для текущей страницы сгенерируем PageEnd (если есть обработчики), если сбор и проверка данных прошли хорошо
		With oEditorStateChangedArgs
			.ReturnValue = True
			.ErrorMessage = vbNullString
			.SilentMode = bSilentMode
			fireEvent "PageEnd", .Self()
			If .ReturnValue <> True And Not bSilentMode Then
				If hasValue(.ErrorMessage) Then Alert .ErrorMessage
				MayBeInterrupted = True
				GetData = False
				Exit Function
			End If
		End With
		MayBeInterrupted = True
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.HtmlPageContainer
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE HtmlPageContainer>
	':Назначение:	Возвращает ссылку на DIV-элемент (контейнера), в котором 
	'				размешаются HTML-представления всех страниц редактора.
	':См. также:	ObjectEditorClass.GetHtmlID
	':Сигнатура:	Public Property Get HtmlPageContainer [As IHTMLDIVElement]
	Public Property Get HtmlPageContainer
		Set HtmlPageContainer = m_oObjectContainerEventsImp.OnGetPageDiv(Me, Null)
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CurrentPage
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE CurrentPage>
	':Назначение:	Возвращает экземпляр EditorPageClass, соответствующий текущей 
	'				(активной) странице.
	':См. также:	ObjectEditorClass.Pages, EditorPageClass
	':Сигнатура:	Public Property Get CurrentPage [As EditorPageClass]
	Public Property Get CurrentPage
		Set CurrentPage = m_oActivePage
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.Pages
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE Pages>
	':Назначение:	Возвращает коллекцию объектов EditorPageClass, соответстующих
	'				страницам редактора.
	':Примечание:	Внимание! Коллекция может модифицироваться только в обработчике 
	'				события Load. Если модификация будет выполнена позднее, то 
	'				визульное представление редактора может отличаться от содержимого
	'				коллекции.<P/>
	'				Последовательность страниц в коллекции (.Items()) соответствует 
	'				последовательности описания страниц редактора (i:editor[i:page])
	'				в метаданных.
	':См. также:	ObjectEditorClass.CurrentPage, EditorPageClass
	':Сигнатура:	Public Property Get Pages [As Scripting.Dictionary]
	Public Property Get Pages
		Set Pages = m_oPages
	End Property
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ApplyURLParams
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE ApplyURLParams>
	':Назначение:	Ициализация свойств объекта параметрами из URL.
	':Сигнатура:	Public Sub ApplyURLParams
	Public Sub ApplyURLParams
		Dim sPropName	' Строка пути до свойства
		Dim oVProp		' Свойство
		Dim oMProp		' Его метаданные
		Dim sObjectID	' Идентификатор объекта
		Dim sOT			' Тип объекта
		Dim aIDS		' Список идентификаторов
		Dim vValue		' Значение параметра
		Dim sVarType	' тип свойства
		Dim oDefValue	' As IXMLDOMElement - узел ds:def
		
		' Пытаемся проинициализировать свойства новосоззданного объекта параметрами из URL
		For Each sPropName In QueryString.Names
			If MID(sPropName,1,1) = "." Then
				' описание свойства начинается с "."
				sPropName = MID( sPropName , 2)

				Set oVProp =  XmlObject.selectSingleNode(sPropName)
				If oVProp Is Nothing Then
					Alert "Свойство """ & sPropName & """ не обнаружено в объекте """ & XmlObject.tagName & """"
				Else
					Set oMProp = PropMD( oVProp)
					sVarType = oMProp.getAttribute("vt")
					Select Case sVarType
						Case "i2", "i4", "ui1", "r4", "r8", "fixed"
							If QueryString.GetValueEx("." & sPropName, vValue) Then
								' если передано непустое значение, то 
								'	приведем значение параметра к числу (в зависимости от типа свойства)
								' иначе
								'	если свойство имеет значение по умолчанию, то установим его, иначе - NULL
								If hasValue(vValue) Then
									On Error Resume Next
									Select Case sVarType
										Case "i2":  vValue = CLng(vValue)	' Все числа все равно обрабатываем как long
										Case "i4":  vValue = CLng(vValue)
										Case "ui1": vValue = CByte(vValue)
										Case "r4":  vValue = CSng(vValue)
										Case "r8":  vValue = CDbl(vValue)
										Case "fixed": vValue = CCur(vValue)
									End Select
									oVProp.nodeTypedValue = vValue
									If Err Then
										On Error GoTo 0
										Err.Raise -1, "ApplyURLParams", "Ошибка при установке значения свойства " & sPropName & " из URL-параметрa: " & vValue
									End If
								Else
									Set oDefValue = oMProp.selectSingleNode("ds:def[@default-type='xml' or @default-type='both']")
									If Not oDefValue Is Nothing Then
										' есть значение по умолчанию (подразумеваем что оно корректно)
										oVProp.nodeTypedValue = oDefValue.text
									Else
										' примечание: oVProp.nodeTypedValue=null писать нельзя, т.к. слетает типизация
										oVProp.text = ""
									End If
								End If
							End If
						Case "date", "dateTime", "time"
							' значение в QueryString может быть либо в формате VBScript, либо в формате xml
							vValue = QueryString.GetValue( "." & sPropName , Now )
							On Error Resume Next
							If IsDate(vValue) Then
								oVProp.nodeTypedValue = CDate(vValue)
							Else
								oVProp.text = vValue
								oVProp.dataType = oVProp.dataType
							End If
							If Err Then
								On Error GoTo 0
								Err.Raise -1, "ApplyURLParams", "Ошибка при установке значения свойства " & sPropName & " из URL-параметрa: " & QueryString.GetValue( "." & sPropName, "0")
							End If
							' обрежем лишнее время для date
							oVProp.text = oVProp.text ' Инц. 69105
						Case "string", "text"
							oVProp.nodeTypedValue =  QueryString.GetValue( "." & sPropName , "")
						Case "object"
							If oMProp.getAttribute("cp") = "scalar" Then
								' объектное скаларное свойство
								sObjectID = QueryString.GetValue( "." & sPropName, "")
								If Len(sObjectID) > 0 Then
									sOT = oMProp.getAttribute("ot")
									m_oPool.RemoveRelation Nothing, oVProp, oVProp.firstChild
									m_oPool.AddRelation Nothing, oVProp, X_CreateObjectStub(sOT, sObjectID)
								End If
							Else
								' Сначала ЗАЧИСТИМ текущее значение свойства (if any)!
								m_oPool.RemoveAllRelations Nothing, oVProp
								' А теперь добавим ссылок
								aIDS = Split( QueryString.GetValue( "." & sPropName , ""), ";")
								sOT = oMProp.getAttribute("ot")
								For Each sObjectID In aIDS
									If Len(sObjectID) > 0 Then
										m_oPool.AddRelation Nothing, oVProp, X_CreateObjectStub(sOT, sObjectID)
									End If
								Next
							End If		
						Case Else
							oVProp.text = QueryString.GetValue( "." & sPropName , "")
					End Select
				End If
			End If
		Next
	End Sub


	'------------------------------------------------------------------------------
	':Назначение:	 Отображение нужных кнопок редактора.
	Private Sub SetEditorButtons(oPage)
		With New SetEditorOperationsArgsClass
			Set .EditorPage = oPage
			m_oObjectContainerEventsImp.OnSetEditorOperations Me, .Self
		End With	
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SetWizardButtons
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE SetWizardButtons>
	':Назначение:	Управление отображением требуемых кнопок мастера.
	':Параметры:	
	'	bPrevious - [in] включить (True) отображение кнопки "Назад"
	'	bNext	- [in] включить (True) отображение кнопки "Далее"
	'	oPage	- [in] страница редактора (EditorPageClass), которую нужно отобразить 
	':Сигнатура:
	'	Public Sub SetWizardButtons( 
	'		bIsFirstPage [As Boolean], 
	'		bIsLastPage [As Boolean], 
	'		oPage [As EditorPageClass]
	'	)
	Public Sub SetWizardButtons( bIsFirstPage, bIsLastPage, oPage )
		With New SetWizardOperationsArgsClass
			.bIsFirstPage = bIsFirstPage
			.bIsLastPage = bIsLastPage
			Set .EditorPage = oPage
			m_oObjectContainerEventsImp.OnSetWizardOperations Me, .Self
		End With
	End Sub


	'------------------------------------------------------------------------------
	':Назначение:	Вывод строки статуса загрузки.
	':Параметры:	sMsg - [in] выводимая строка
	Private Sub ReportStatus( sMsg)
		m_oObjectContainerEventsImp.OnSetStatusMessage Me, sMsg, Null
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OnDeleteObjectConflict
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OnDeleteObjectConflict>
	':Назначение:	
	'	Стандартный обработчик события пула "DeleteObjectConflict", возникающего в 
	'	процессе удаления объекта в пуле, при нахождении на него ссылокок от других 
	'	объектов в пуле.
	':Параметры:
	'	oSender - [in] объект-источник события (в данном случае - пул редактора)
	'	oEventArgs - [in] параметры события, экземпляр DeleteObjectConflictEventArgsClass
	':Примечание:
	'	Стандартный обработчик события реализует следующую реакцию на событие: 
	'	- Если на удаляемый объект ссылаются объкты, для которых ссылка является 
	'		обязательным значением (необнуляемым), то обработчик выводит сообщение 
	'		о невозможности удаления, с указанием перечня объектов, ссылающихся на
	'		удаляемый. Процесс удаления при этом прерывается.
	'	- Если на удаляемый объект ссылаются объкты, для которых ссылка является может 
	'		быть обнулена, то обработчик выводит диалог подтверждения удаления объектов,
	'		с указанием перечня объектов, которые ссылаются на удаляемый. Если 
	'		пользователь подтверждает удаление, то обработчик продолжает операцию 
	'		удаления (все ссылки на удаляемый объект при этом будут очищены). Если же
	'		пользователь отказался от удаления, то операция прерывается.
	':См. также:	
	'	XObjectPoolClass
	':Сигнатура:
	'	Public Sub OnDeleteObjectConflict( 
	'		oSender [As XObjectPoolClass], 
	'		oEventArgs [As DeleteObjectConflictEventArgsClass]
	'	)
	Public Sub OnDeleteObjectConflict(oSender, oEventArgs)
		Dim oXmlRefProp 	    ' As IXMLDOMElement - ссылающееся свойство
		Dim sMsg			    ' As String - сообщение
		Dim nCount			    ' As Integer - количество элементов списка
		Dim bShowMsg		    ' As Boolean - признак показа сообщения с вопросом об очистке ссылок
		Dim sCapacity		    ' емкость свойства
		Dim oPropMD				' As IXMLDOMElement - метаданные свойства
		Dim i
		
		With oEventArgs
			nCount = .NotNullReferences.Count
			If nCount > 0 Then
				If Not .SilentMode Then
					sMsg = "Удаление невозможно. На удаляемый объект ссыла" & iif(nCount=1, "ется", "ются") & " объект" & iif(nCount>1, "ы", "") & ":" & vbNewLine
					For i=0 To nCount-1
						Set oXmlRefProp = .NotNullReferences.GetAt(i).parentNode
						sMsg = sMsg & vbTab & m_oPool.GetObjectPresentation( oXmlRefProp.parentNode ) & vbNewLine
					Next
					MsgBox sMsg, vbOKOnly Or vbExclamation, "Удаление объекта"
				End If
				.ReturnValue = False
				Exit Sub
			End If
			nCount = .AllReferences.Count
			bShowMsg = False
			If nCount > 0 Then
				If Not .SilentMode Then
					Set .PropertiesToUpdate = New ObjectArrayListClass
					
					sMsg = "На удаляемый объект ссыла" & iif(nCount=1, "ется", "ются") & " объект" & iif(nCount>1, "ы", "") & ":" & vbNewLine
					For i=0 To nCount-1
						Set oXmlRefProp = .AllReferences.GetAt(i).parentNode
						' исключим свойство, из которого запущено удаление
						If Not m_oPool.IsSameProperties(.SourceXmlProperty, oXmlRefProp ) Then
							' усключим все линки
							Set oPropMD = X_GetPropertyMD(oXmlRefProp)
							sCapacity = oPropMD.getAttribute("cp") 
							' TOTHINK: почему только линки а не все обратные свойства ?
							If sCapacity <> "link" And sCapacity <> "link-scalar" Then
								sMsg = sMsg & vbTab & m_oPool.GetObjectPresentation( oXmlRefProp.parentNode ) & ", свойство " & oPropMD.getAttribute("d") & vbNewLine
								bShowMsg = True
								' подразумеваем, что из одного и того же свойства ссылки не мог быть (но если и будут, ничего не сломается) - дешевле, чем проверять на исключение дублирования
								.PropertiesToUpdate.Add oXmlRefProp
							End If
						End If
					Next
					If bShowMsg Then
						sMsg = sMsg & "Удалить объект и все ссылки на него?"
						If MsgBox( sMsg, vbYesNo Or vbDefaultButton2 Or vbQuestion, "Удаление объекта" ) = vbNo Then
							.ReturnValue = False
							Exit Sub
						End If
					End If
					.ReturnValue = True
				End If
			End If
		End With
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OnGetObjectConflict
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OnGetObjectConflict>
	':Назначение:	
	'	Стандартный обработчик события "GetObjectConflict", генерируемого пулом 
	'	в случах получения данных объекта, уже присутстующих в пуле.
	':Параметры:
	'	oSender - [in] объект-источник события (в данном случае - пул редактора)
	'	oEventArgs - [in] параметры события, экземпляр GetObjectConflictEventArgsClass
	':Примечание:
	'	Стандартный обработчик события отображает диалог подтверждения, где 
	'	указывается, что измененный (удаленный) были изменены другим пользователем,
	'	и предлагает заменить измененные данные более актуальными (в случае с 
	'	удаленными данными - отменить удаление).
	':См. также:	
	'	XObjectPoolClass
	':Сигнатура:
	'	Public Sub OnGetObjectConflict(
	'		oSender [As XObjectPoolClass], 
	'		oEventArgs [As GetObjectConflictEventArgsClass]
	'	)
	Public Sub OnGetObjectConflict(oSender, oEventArgs)
		Dim vRequestResult

		With oEventArgs
			If Not IsNull(.ObjectInPool.getAttribute("delete")) Then
				vRequestResult = MsgBox( _
					"Данные удаляемого объекта были изменены другим пользователем. " & vbCr & _
					"Продолжить процесс и удалить измененные данные (Да) или прервать удаление (Нет)?" & vbCr & _
					"Внимание! Отмена удаления не гарантирует восстановления ссылок на удаляемый объект!", _
					vbQuestion + vbYesNo + vbDefaultButton2, "Подтверждение" )
					
				If vbYes = vRequestResult Then
					' раз юзер сказал "Удалить", то снесем ts, тогда объект удалиться точно, даже если он еще раз устареет
					.ObjectInPool.removeAttribute "ts"
				Else
					' Выбрали "Отменить удаление" - снимем атрибут delete
					.ObjectInPool.removeAttribute "delete"
				End If
			Else
				' 
				If Not .ObjectInPool.selectSingleNode("*[@dirty]") Is Nothing Then
					' устаревший объект в пуле имеет модифицированные свойства
					vRequestResult = MsgBox( _
						"Редактируемые данные были изменены другим пользователем. " & vbCr & _
						"Отменить ваши изменения и использовать данные, введенными другим " & vbCr & _
						"пользователем (Да), или оставить ваши изменения (Нет)?" & _
						vbQuestion + vbYesNo + vbDefaultButton2, "Подтверждение" )
						
					If vbYes = vRequestResult Then
						' заменим объект в пуле на объект пришедший с сервера
						.ObjectInPool.parentNode.replaceChild .ObjectFromServer, .ObjectInPool
					Else
						' Юзер выбрал "Оставить изменения" - снесем ts
						.ObjectInPool.removeAttribute "ts"
					End If
				End If
			End If
		End With
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.MarkObjectAsDeleted
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE MarkObjectAsDeleted>
	':Назначение:	Помечает заданный объект как удаленный.
	':Параметры:	
	'	sObjectType - [in] тип удаляемого объекта
	'	sObjectID - [in] идентификатор удаляемого объекта
	'	oXmlProperty - [in] указание свойства, ссылка в котором не препятствует 
	'			удалению; если не используется, задается в Nothing
	':Результат:
	'	Признак успешного завершения "удаления" (установки атрибутов delete для 
	'	всех объектов в пуле). Метод возвращает False в случае отмены удаления 
	'	при обработке события <B>DeleteObjectConflict</B>.
	':Примечание:	
	'	Удаляемый объект помечается атрибутом delete="1". Так же помечаются все 
	'	объекты в пуле, которые ссылаются на заданный по ссылкам с каскадным 
	'	удалением (delete-cascade="1" в метаопределении объктного свойства).<P/>
	'	Если на удаляемые объекты есть обязательные ссылки (свойства помеченные 
	'	как notnull="1" и свойства, для	которых в метаданных не задано maybenull="1"), 
	'	то удаление блокируется; метод генерирует событие <B>DeleteObjectConflict</B>.<P/>
	'	Если обязательных ссылок нет, то удаляются все ссылки на удаляемые объекты 
	'	(с учетом каскадного удаления).</P>
	'	Помимо вызова одноименной функции пула метод осуществляет обновление 
	'	редакторов свойств на текущей странице редактора, данные которых были 
	'	затронуты удалением (т.е. тех, что соответствуют свойствам, из которых
	'	были удалены ссылки).
	':См. также:
	'	ObjectEditorClass.MarkXmlObjectAsDeleted, ObjectEditorClass.OnDeleteObjectConflict,<P/>	
	'	XObjectPoolClass.MarkObjectAsDeleted,<P/>
	'	<LINK oe-2-3-3-2, Удаление объекта/>
	':Сигнатура:
	'	Public Function MarkObjectAsDeleted(
	'		sObjectType [As String], 
	'		sObjectID [As String], 
	'		oXmlProperty [As IXMLDOMElement]
	'	) [As Boolean]
	Public Function MarkObjectAsDeleted(sObjectType, sObjectID, oXmlProperty)
		Dim oPropertiesToUpdate	' As ObjectArrayListClass - коллекция свойств, из которых происходит удаление ссылок - используется для последующего обновления представлений этих свойств
		Dim aPropertyEditors    ' массив редакторов свойств
		Dim oXmlProp			' As IXMLDOMElement - xml-свойства
		Dim j
		Dim i
		
		MarkObjectAsDeleted = m_oPool.MarkObjectAsDeleted(sObjectType, sObjectID, oXmlProperty, False, oPropertiesToUpdate)
		
		If hasValue(oPropertiesToUpdate) Then
			' а теперь надо обновить все редакторы свойств на текущей странице, соответствующие свойствам из коллекции AllReferences
			For i=0 To oPropertiesToUpdate.Count-1
				Set oXmlProp = oPropertiesToUpdate.GetAt(i)
				aPropertyEditors = CurrentPage.GetPropertyEditors(oXmlProp)
				If IsArray(aPropertyEditors) Then
					For j=0 To UBound(aPropertyEditors)
						aPropertyEditors(j).SetData
					Next
				End If				            
			Next
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.MarkXmlObjectAsDeleted
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE MarkXmlObjectAsDeleted>
	':Назначение:	Помечает заданный объект как удаленный.
	':Параметры:	
	'	oXmlObject - [in] XML-объект или заглушка удаляемого объекта
	'	oXmlProperty - [in] указание свойства, ссылка в котором не препятствует 
	'					удалению; если не используется, задается в Nothing
	':Результат:
	'	Признак успешного завершения "удаления" (установки атрибутов delete для 
	'	всех объектов в пуле). Метод возвращает False в случае отмены удаления 
	'	при обработке события <B>DeleteObjectConflict</B>.
	':Примечания:
	'	См. замечания к методу ObjectEditorClass.MarkObjectAsDeleted.
	':См. также:	
	'	ObjectEditorClass.MarkObjectAsDeleted
	':Сигнатура:	
	'	Public Function MarkXmlObjectAsDeleted(
	'		oXmlObject [As IXMLDOMElement], 
	'		oXmlProperty [As IXMLDOMElement]
	'	) [As Boolean]
	Public Function MarkXmlObjectAsDeleted(oXmlObject, oXmlProperty) 
		MarkXmlObjectAsDeleted = MarkObjectAsDeleted(oXmlObject.tagName, oXmlObject.getAttribute("oid"), oXmlProperty)
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OpenEditor
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OpenEditor>
	':Назначение:	Открывает вложенный редактор.
	':Параметры:	
	'	oXmlObject	- XML-объект для редактирования
	'	sObjectType	- наименование типа редактируемого объекта 
	'	sObjectID	- идентификатор редактируемого объекта
	'	sMetaName	- метанаименование редактора
	'	bCreate		- флаг создания объекта: True - запуск мастера, False - редактора
	'	oParentXmlProperty - XML-свойство, в котором создается / редактируется объект
	'	bIsAggregation - флаг агрегации (см "Замечания")
	'	bEnlistInCurrentTransaction - признак начала новой логической транзакции:
	'			- True - редактор не должен начинать и завершать (откатывать) транзакцию,
	'				так как ей управляет вызывающий код;
	'			- False - редактор начинает новую логическую транзакцию
	'	sAuxiliaryUrlArguments - дополнительные параметры, передаваемые в редактор
	':Результат:
	'	Результат зависит от того, как был закрыт диалог редактора:
	'	- если редактор был закрыт кнопкой "Ок" ("Готово"), то метод возвращает 
	'		идентификатор отредактированного (созданного) объекта;
	'	- в противном случае метод возвращает Empty.
	':Примечания:
	'	Флаг агрегации, задаваемый параметром bIsAggregation, определяет то, 
	'	<I>как</I> пул создает новую транзакцию, в том случае, когда параметр 
	'	bEnlistInCurrentTransaction задан в значение False (иначе новая транзакция 
	'	не создается; параметр bIsAggregation в этом случае игнорируется):
	'	- True - транзакция создается с новым идентификатором (TransactionID);
	'	- False - транзакция создается как часть текущей, с тем же идентификатором.
	'	<B>ВНИМАНИЕ: случай создания транзации с новым идентификатором на данный 
	'	момент не реализован! Поэтому параметр bIsAggregation всегда должен
	'	задаваться в значение True!</B>
	':Сигнатура:
	'	Public Function OpenEditor(
	'		oXmlObject [As IXMLDOMElement], 
	'		sObjectType [As String], 
	'		sObjectID [As String], 
	'		sMetaName [As String], 
	'		bCreate [As Boolean], 
	'		oParentXmlProperty [As IXMLDOMElement], 
	'		bIsAggregation [As Boolean], 
	'		bEnlistInCurrentTransaction [As Boolean], 
	'		sAuxiliaryUrlArguments [As String]
	'	) [As Variant]
	Public Function OpenEditor(oXmlObject, sObjectType, sObjectID, sMetaName, bCreate, oParentXmlProperty, bIsAggregation, bEnlistInCurrentTransaction, sAuxiliaryUrlArguments)
		Dim oObjectEditorDialog

		Set oObjectEditorDialog = New ObjectEditorDialogClass
		oObjectEditorDialog.QueryString.QueryString = sAuxiliaryUrlArguments
		oObjectEditorDialog.IsNewObject = bCreate
		oObjectEditorDialog.IsAggregation = bIsAggregation
		oObjectEditorDialog.EnlistInCurrentTransaction = bEnlistInCurrentTransaction
		oObjectEditorDialog.MetaName = sMetaName
		If IsObject(oXmlObject)=True Then
			Set oObjectEditorDialog.XmlObject = oXmlObject
		Else
		    oObjectEditorDialog.ObjectType = sObjectType
		    oObjectEditorDialog.ObjectID = sObjectID
		    Set oObjectEditorDialog.XmlObject = Pool.FindXmlObject(sObjectType, sObjectID)
		End If
		Set oObjectEditorDialog.ParentObjectEditor = Me
		oObjectEditorDialog.ParentObjectType = oParentXmlProperty.parentNode.tagName
		oObjectEditorDialog.ParentObjectID = oParentXmlProperty.parentNode.getAttribute("oid")
		oObjectEditorDialog.ParentPropertyName = oParentXmlProperty.tagName
		oObjectEditorDialog.SkipInitErrorAlerts = SkipInitErrorAlerts
		
		OpenEditor = ObjectEditorDialogClass_Show(oObjectEditorDialog)
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.Save
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE Save>
	':Назначение:	Сбор данных и сохранение всех модифицированных данных пула.
	':Результат:	Логический признак успешного завершения сбора и сохранения данных.
	':См. также:	
	'	ObjectEditorClass.FetchXmlObject, <P/>
	'	<LINK stdOp_SaveObject, Операция SaveObject - запись данных ds-объектов />
	':Сигнатура:	Public Function Save [As Boolean]
	Public Function Save
		EnableControls False
		' Попробуем собрать данные :)
		If Not FetchXmlObject(False) Then
			' Если сбор данных не сложился
			EnableControls True
			Exit Function
		End If
		' Попробуем сохранить текущий пул объектов
		Save = SaveCurrentPool()
		EnableControls True
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.FetchXmlObject
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE FetchXmlObject>
	':Назначение:	Сбор данных из представлений редакторов свойств в пул.
	':Параметры:
	'	bSilentMode - [in] флаг выполнения сбора данных в "тихом" режиме; если задан
	'			в значение True, то сообщения об ошибках не оторбажаются, событие 
	'			Validate не генерируется
	':Результат:
	'	Логический признак успешного завершения сбора данных. 
	':Примечание:
	'	В процессе сбора данных генерируются события BeforePageEnd, ValidatePage, 
	'	PageEnd и Validate (последнее - только в том случае, когда значение 
	'	параметра bSilentMode есть False).
	':Сигнатура:
	'	Public Function FetchXmlObject( bSilentMode [As Boolean] ) [As Boolean]
	Public Function FetchXmlObject(bSilentMode)
		On Error GoTo 0
		FetchXmlObject = False
		If False = GetData( REASON_OK, bSilentMode) Then
			Exit Function
		End If
		If Not bSilentMode Then
			' Если есть пользовательский обработчик завершения работы
			With New EditorStateChangedEventArgsClass
				.Reason = REASON_OK
				fireEvent "Validate", .Self()
				If .ReturnValue <> True Then 
					If hasValue(.ErrorMessage) Then Alert .ErrorMessage
					Exit Function
				End If
			End With
		End If
		FetchXmlObject = True
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CreateXmlDatagramRoot
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE CreateXmlDatagramRoot>
	':Назначение:	
	'	Создает корневой узел XML-документа с датаграммой, передаваемой серверной 
	'	операции записи данных.
	':См. также:	
	'	ObjectEditorClass.GetXmlDatagramForSave, ObjectEditorClass.SaveCommandName
	'	<LINK stdOp_SaveObject, Операция SaveObject - запись данных ds-объектов />
	':Сигнатура:	
	'	Public Function CreateXmlDatagramRoot [As IXMLDOMElement]
	Public Function CreateXmlDatagramRoot
		With XService.XmlGetDocument
			Set CreateXmlDatagramRoot = .appendChild( .createElement("x-datagram"))
		End With
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetXmlDatagramForSave
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetXmlDatagramForSave>
	':Назначение:	
	'	Формирует и возвращает датаграмму, передаваемую серверной операции 
	'	записи данных.
	':См. также:	
	'	ObjectEditorClass.CreateXmlDatagramRoot, ObjectEditorClass.SaveCommandName
	'	<LINK stdOp_SaveObject, Операция SaveObject - запись данных ds-объектов />
	':Сигнатура:	
	'	Public Function GetXmlDatagramForSave [As IXMLDOMElement]
	Public Function GetXmlDatagramForSave
		Dim oBatchSave					' xml с объектами для сохранения (поле XmlSaveData реквеста)
		Dim oNode						' для цикла
		
		Set oBatchSave = CreateXmlDatagramRoot()
		oBatchSave.setAttribute "transaction-id", TransactionID
		' Скопируем в сохраняемый пакет из пула те объекты, которые:
		'	1) Редактировались в текущей транзакции
		'	2) Помеченны как удаляемые (атрибутом delete) или являются новыми (атрибут new), либо измененными (атрибут dirty у свойств)
		' Примечание: "сохранению" подлежат и временные объекты, т.к. серверная команда может использовать данные из них, 
		' и вообще, "сохранение" временных объектов является способом посылки дополнительных данных на сервер
		For Each oNode In m_oPool.GetChanges()
			oBatchSave.appendChild oNode.cloneNode(True)
		Next
		' Оптимизируем пакет. Для этого удалим:
		' 1) Все незаглушки ( превратим их в заглушки)
		' 2) Все "чистые" свойства у неновых объектов
		' 3) Все "чистые" пустые(чтобы не лохануться с defaultvalue) свойства для новых объектов
		' 4) Все аттрибуты dirty
		oBatchSave.SelectNodes("*/*/*/*|*[not(@new)]/*[not(@dirty)]|*[@new]/*[not(@dirty) and not(text()) and not(*)]|//@dirty").removeAll
		
		Set GetXmlDatagramForSave = oBatchSave
	End Function
	

	'------------------------------------------------------------------------------
	':Назначение:
	'	Сохранение объекта, его синхронизация и вызов пользовательских обработчиков.
	Private Function SaveCurrentPool
		const MAX_SAVE_ITERATION_COUNT	= 50	' максимальное количество итераций цикла сохранения (для защиты от бесконечного цикла)
		Dim oBatchSave					' xml с объектами для сохранения (поле XmlSaveData реквеста)
		Dim nErrNumber					' Код ошибки
		Dim sErrSource					' Источник ошибки
		Dim sErrDescription				' Описание ошибки
		Dim nErrorAction				' Выполняемое в случае ошибки действие(AFTERERROR_nnnn)
		Dim nIterCount					' количество итераций цикла сохранения
		Dim bMultiSave
		Dim bComplete
		
		
		SaveCurrentPool = Empty
		With X_CreateControlsDisabler(Me)
			' TODO: fireEvent "AcceptChanges"
			
			' Если текущий редактор участвует во внешней транзакции, то просто выйдем
			' Признак IsAggregated, переданный нам при запуске текущего редактор, сообщая о том, что мы функционируем как часть внешней транзации,
			' т.е. не должны сохранять изменения в БД
			If IsAggregated Then
				' Если мы управляем текущей транзакцией - завершим ее
				If m_bManageCurrentTransaction Then
					m_oPool.CommitTransaction
				End If
				SaveCurrentPool = ObjectID
				Exit Function
			End If	
			nIterCount = 0
			Do
				nErrNumber = 0
				' Получим Дифграмму
				Set oBatchSave = GetXmlDatagramForSave()
				If Nothing Is oBatchSave.FirstChild  Then Exit Do ' Ничего не сохраним так как ничего не изменилось...
				
				' Кусочное сохранение
				bMultiSave = False
				If Not IsNull(InterfaceMD.GetAttribute("use-multipart-save")) Then
					If X_GetApproximateXmlSize( oBatchSave) > MAX_POST_SIZE Then
						bMultiSave = True
						Set oBatchSave = oBatchSave.ownerDocument
						' запустим диалог
						bComplete = (0<>CLng( X_ShowModalDialogEx(XService.BaseURL & "x-save-object-multipart.aspx", Array(oBatchSave, Me, "ChunkUpload", "ChunkPurge"), "dialogWidth:400px;dialogHeight:280px;help:no;center:yes;status:no")))
						If False = bComplete Then
							' Ага, было прервано пользователем, сформируем эксепшн чтобы проэшелонировать его через все обработчики
							On Error Resume Next
							err.Raise -1, "", "Операция сохранения была прервана пользователем!"
						Else
							Set oBatchSave = oBatchSave.documentElement
							' Возможно в "Обновленном" XML-е нас поджидает подлая ошибка
							On Error Resume Next
							XService.XMLTestErrorInfo oBatchSave
							If Err Then
								X_SetLastServerError XService.LastServerError, Err.number, Err.Source, Err.Description
							Else
								X_ClearLastServerError
							End If							
						end if						
					End If
				End If
				
				If False=bMultiSave Then
					On Error Resume Next
				    X_ExecuteCommand Internal_GetSaveRequest(oBatchSave)
				End If	
					
				nErrNumber = Err.number
				sErrSource = Err.Source
				sErrDescription = Err.Description
				On Error GoTo 0
				
				If 0 = nErrNumber Then Exit Do
				With New SaveObjectErrorEventArgsClass
					.ErrNumber		= nErrNumber
					.ErrSource		= sErrSource
					.ErrDescription	= sErrDescription
					.Action			= AFTERERROR_DISPLAYMSG
					fireEvent "SaveObjectError", .Self()
					nErrorAction	= .Action
				End With
				nIterCount = nIterCount + 1
				If nIterCount > MAX_SAVE_ITERATION_COUNT Then
					X_ErrReportEx "Количество итераций цикла сохранения превысило максимально возможное", "SaveCurrentPool"
					Exit Function
				End If
			Loop  While AFTERERROR_RETRY=nErrorAction
			
			If 0=nErrNumber Then
				' Не было ошибки - продолжим
				SaveCurrentPool = ObjectID
				' Если мы управляем текущей транзакцией - завершим ее
				If m_bManageCurrentTransaction Then
					m_oPool.CommitTransaction
				End If
				fireEvent "Saved", Nothing
			ElseIf  AFTERERROR_DISPLAYMSG=nErrorAction Then
				' Есть ошибка и о ней надо сообщить (X_HandleError обрабатывает серверные ошибки)
				If Not X_HandleError Then
					Alert "Клиентская ошибка при вызове операции сохранения:" & vbCr & sErrDescription & vbCr & sErrSource
				End If
				Exit Function
			End If
		End With
	End Function


	'------------------------------------------------------------------------------
	':Назначение:	Возвращает экземпляр реквеста команды сохранения.
	':Параметры:	oBatchSave - [in] XML-датаграмма (IXMLDOMElement)
	':Результат:	Экземпляр запроса на выполнение операции записи
	' Примечание:	Генерирует событие PrepareSaveRequest.
	'				ВНИММАНИЕ! Только для внутреннего использования!
    Public Function Internal_GetSaveRequest(oBatchSave)
		If m_oEventEngine.IsHandlerExists("PrepareSaveRequest") Then 
			With New PrepareSaveRequestEventArgsClass
				.CommandName = m_sSaveCommandName
				.Context = Metaname
				Set .XmlBatch = oBatchSave
				fireEvent "PrepareSaveRequest", .Self()
				Set Internal_GetSaveRequest = .Request
			End With
		Else
			With New XSaveObjectRequest
				Set .m_oXmlSaveData = oBatchSave
				.m_sName = m_sSaveCommandName
				.m_sContext = Metaname
				Set .m_oRootObjectId = internal_New_XObjectIdentity(ObjectType, ObjectID)
				Set Internal_GetSaveRequest = .Self
			End With
		End If
    End Function
	

	'------------------------------------------------------------------------------
	':Назначение:	Вызывается контейнером, по отмене редактирования.
	'				Для внутреннего использования! 
	Public Sub OnCancel
		' Если мы управляем текущей транзакцией - завершим ее
		If m_bManageCurrentTransaction Then
			m_oPool.RollbackTransaction
		End If
	End Sub
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OnClose
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OnClose>
	':Назначение:	Метод, вызываемый "контейнером" редактора при закрытии окна 
	'				(диалога) "контейнера".
	':Примечание:	Метод генерирует собтыие UnLoad.
	':См. также:	IObjectContainerEventsClass
	':Сигнатура:	Public Sub OnClose
	Public Sub OnClose
		IsInterrupted = True
		With New EditorStateChangedEventArgsClass
			.Reason = REASON_CLOSE
			fireEvent "UnLoad", .Self()
		End With
		m_oPool.UnRegisterEditor
		Dispose
	End Sub
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OnClosing
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OnClosing>
	':Назначение:	Метод, вызываемый "контейнером" редактора при начале закрытия окна 
	'				(диалога) "контейнера". Позволяет воспрепятствовать закрытию редактора.
	':Параметры:	bOkPressed - [in] признак того, что закрытие редактора вызвано нажатием ОК/Готово
	':Примечание:	Метод генерирует собтыие UnLoading.
	':См. также:	IObjectContainerEventsClass
	':Сигнатура:	Public Function OnClosing As String
	Public Function OnClosing(bOkPressed)
		If m_oEventEngine.IsHandlerExists("UnLoading") Then 
			With New EditorStateChangedEventArgsClass
				.ReturnValue = Empty
				If bOkPressed Then
					.Reason = REASON_OK
				Else
					.Reason = REASON_CLOSE
				End If
				fireEvent "UnLoading", .Self()
				OnClosing = .ReturnValue
			End With
		End If
	End Function
	
	
	'------------------------------------------------------------------------------
	':Назначение:	Интерфейс IDisposable: освобождение ссылок.
	'				Для внутреннего использования! 
	Public Sub Dispose
		Dim oPage		' As EditorPageClass
		m_oEventEngine.Dispose
		Set m_oEventEngine = Nothing
		Set m_oPool = Nothing
		Set m_oEventEngine = Nothing
		For Each oPage In m_oPages.Items
			oPage.Dispose
		Next
		Set m_oPages = Nothing
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsControlsEnabled
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsControlsEnabled>
	':Назначение:	
	'	Возвращает признак блокировки элементов UI редактора: True - элементы 
	'	управления доступны для ввода, False - элементы управления заблокированы.
	':Примечание:	
	'	Внимание! Данное свойство используется подгружаемыми клиентскими cкриптами!<P/>
	'	Свойство доступно только для чтения. Для управления блокировкой элементов
	'	управления редактора используется метод EnableControls.
	':См. также:
	'	ObjectEditorClass.EnableControls
	':Сигнатура:
	'	Public Property Get IsControlsEnabled [As Boolean]
	Public Property Get IsControlsEnabled
		IsControlsEnabled = (True=m_bControlsEnabled)
	End Property
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.EnableControls
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE EnableControls>
	':Назначение:	Явное задание блокировки всех элементов управления редактора.
	':Параметры:	bEnable - [in] признак доступности элементов:
	'					- True - сделать элементы управления доступными для ввода;
	'					- False - заблокировать элементы управления
	':Примечание:	Внимание: метод передает управление контейнеру, вызывая метод
	'				IObjectContainerEventsClass.OnEnableControls.
	':См. также:	ObjectEditorClass.IsControlsEnabled, IObjectContainerEventsClass
	':Сигнатура:	Public Sub EnableControls( ByVal bEnable [As Boolean] )
	Public Sub EnableControls( ByVal bEnable )
		EnableControlsInternal bEnable, True
	End Sub
	

	'------------------------------------------------------------------------------
	':Назначение:	Разрешает/запрещает элементы управления. 
	':Параметры:
	'	[in] bEnable	- признак доступности элементов
	'	[in] bBubbleUp	- True - передает управление контейнеру, иначе - нет.
	':Примечание:
	'	ВНИМАНИЕ! ДЛЯ ВНУТРЕННЕГО ИСПОЛЬЗОВАНИЯ!
	'	Предназначен для вызова из контейнеров редактора. Если параметр bBubbleUp
	'	задан в False, то метод НЕ передает управление контейнеру
	Public Sub EnableControlsInternal(bEnable, bBubbleUp)
		bEnable = (True=bEnable)
		' Предотвращение повторного вызова...
		If bEnable = IsControlsEnabled Then Exit Sub
		m_bControlsEnabled = bEnable
		CurrentPage.SetEnable bEnable		
		If bBubbleUp Then
			m_oObjectContainerEventsImp.OnEnableControls Me, bEnable, Null
		End If
	End Sub
	

	'------------------------------------------------------------------------------
	':Назначение:	Установка заголовка редактора. Для внутреннего использования!
	':Параметры:
	' 	sEditorCaption	- [in] полный заголовок
	'	sPageCaption	- [in] (под)заголовок страницы
	Private Sub setCaptionInternal(ByVal sPageCaption)
		Dim sEditorCaption
		sEditorCaption = InterfaceMD.getAttribute("t")
		If m_oEventEngine.IsHandlerExists("SetCaption") Then 
			With New SetCaptionEventArgsClass
				.EditorCaption = sEditorCaption
				.PageTitle = sPageCaption
				fireEvent "SetCaption", .Self()
				sEditorCaption = .EditorCaption
				sPageCaption = .PageTitle
			End With
		Else
			If Len(sPageCaption) > 0 Then
				sEditorCaption = sEditorCaption & " - " & sPageCaption
			End If
		End If
		SetCaption sEditorCaption, sPageCaption
	End Sub
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SetCaption
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE SetCaption>
	':Назначение:	Установка заголовка редактора.
	':Параметры:
	'	sEditorCaption - [in] строка с текстом общего заголовка редактора
	'	sPageCaption - [in] строка с текстом (под)заголовка страницы редактора
	':Примечание:
	'	Внимание: метод передает управление "контейнеру", вызывая метод
	'	IObjectContainerEventsClass.OnSetCaption.
	':См. также:	
	'	IObjectContainerEventsClass
	':Сигнатура:	
	'	Public Sub SetCaption(
	'		ByVal sEditorCaption [As String], 
	'		ByVal sPageCaption [As String]
	'	)
	Public Sub SetCaption(ByVal sEditorCaption, ByVal  sPageCaption)
		m_oObjectContainerEventsImp.OnSetCaption Me, sEditorCaption, sPageCaption
	End Sub
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.PropMD
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE PropMD>
	':Назначение:	
	'	Возвращает данные метаописания заданного свойства объекта.
	':Параметры:	
	'	vProp - [in] указание свойства объекта, метаданные которого требуются; 
	'			здесь может быть задано:
	'			- строка с наименованием свойства;
	'			- XML-данные свойства, как экземпляр IXMLDOMElement
	':Результат:	
	'	XML с метаописанием свойства объекта (элемент ds:prop, подчиненный 
	'	соответствующему элементу ds:type, см. x-net-data-schema.xsd), как 
	'	экземпляр IXMLDOMElement.
	':Сигнатура:
	'	Public Function PropMD( vProp [As Variant] ) [As IXMLDOMElement]
	Public Function PropMD( vProp )
		If vbString = vartype( vProp ) Then
			Set PropMD = X_GetTypeMD( ObjectType ).selectSingleNode( "ds:prop[@n='" & vProp & "']" )
		ElseIf 0=StrComp( TypeName(vProp), "IXMLDOMElement", vbTextCompare ) Then
			' Передано xml-свойство
			Set PropMD = X_GetTypeMD( vProp.parentNode.nodeName).selectSingleNode( "ds:prop[@n='" & vProp.nodeName & "']" )
		Else
			Err.Raise -1, "ObjectEditor::PropMD", "Параметр vProp неподдерживаемого типа: " & TypeName(vProp) & " (не String и не IXMLDOMElement)"
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetPropByHtmlID
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetPropByHtmlID>
	':Назначение:	
	'	Возвращает XML-данные свойства объекта по уникальному идентификатору 
	'	HTML-элемента редактора свойства.
	':Параметры:
	'	sHtmlID - [in] уникальный идентификатор HTML-элемента редактора свойства
	':Результат:
	'	Данные свойства объекта, как экземпляр IXMLDOMElement.<P/>
	'	Если идентификатор, заданный параметром sHtmlID, имеет некорректный формат,
	'	или если свойство / объект, соответствующие заданному идентификатору, не 
	'	представлены в пуле редактора, метод возвращает Nothing.
	':См. также:
	'	ObjectEditorClass.GetHtmlID, ObjectEditorClass.SplitHtmlID, 
	'	ObjectEditorClass.GetProp
	':Сигнатура:
	'	Public Function GetPropByHtmlID( ByRef sHtmlID [As String] ) [As IXMLDOMElement]
	Public Function GetPropByHtmlID( ByRef sHtmlID )
		Dim sObjectType, sObjectID, sPropertyName
		If SplitHtmlID(sHtmlID, sObjectType, sObjectID, sPropertyName) Then   
			Set GetPropByHtmlID = GetXmlObjectFromPool(sObjectType, sObjectID, Null).selectSingleNode(sPropertyName)
		Else
			Set GetPropByHtmlID = Nothing
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetProp
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetProp>
	':Назначение:	
	'	Возвращает свойство редактируемого (создаваемого) объекта по его наименованию.
	':Параметры:
	'	sName - [in] наименование свойства
	':Результат:
	'	Данные свойства объекта, как экземпляр IXMLDOMElement.
	':См. также:
	'	ObjectEditorClass.GetPropByHtmlID
	':Сигнатура:
	'	Public Function GetProp( sName [As String] ) [As IXMLDOMElement]
	Public Function GetProp(sName)
		Set GetProp = XmlObject.selectSingleNode(sName)
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsIncluded
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsIncluded>
	':Назначение:	
	'	Признак вложенного редактора: True - текущий редактор является вложенным,
	'	False - редактор является "корневым".
	':Сигнатура:
	'	Public Property Get IsIncluded [As Boolean]
	Public Property Get IsIncluded
		IsIncluded = m_bIncluded
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsMultipageEditor
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsMultipageEditor>
	':Назначение:	
	'	Признак многостраничного редактора: True - представление редактора содержит
	'	несколько (более одной) страниц; False - содержит только одну стораницу.
	':Сигнатура:
	'	Public Property Get IsMultipageEditor [As Boolean]
	Public Property Get IsMultipageEditor
		IsMultipageEditor = IsEditor And m_oPages.Count>1
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsLinearWizard
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsLinearWizard>
	':Назначение:	Возвращает признак режима "линейного" мастера.
	':См. также:	ObjectEditorClass.IsEditor, ObjectEditorClass.IsWizard
	':Сигнатура:	Public Property Get IsLinearWizard [As Boolean]
	Public Property Get IsLinearWizard
		IsLinearWizard = False
		If Not IsWizard Then Exit Property
		If m_oEventEngine.IsHandlerExists("GetNextPageInfo") Then Exit Property
		IsLinearWizard = True
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsObjectCreationMode
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsObjectCreationMode>
	':Назначение:	
	'	Возвращает признак режима создания создания нового объекта: True - в 
	'	редакторе вводятся данные нового объекта; False - в редакторе редактируются
	'	данные существующего (на момент вызова редактора) объекта.
	':См. также:
	'	ObjectEditorClass.IsEditor, ObjectEditorClass.IsWizard,
	'	ObjectEditorClass.IsLinearWizard
	':Сигнатура:
	'	Public Property Get IsObjectCreationMode [As Boolean]
	Public Property Get IsObjectCreationMode
		IsObjectCreationMode = m_bCreateNewObject
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsEditor
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsEditor>
	':Назначение:	
	'	Возвращает признак режима "редактора" (атрибут wizard-mode для элемента 
	'	i:editor описания редактора не задан, см. x-net-interface-schema.xsd).
	':См. также:
	'	ObjectEditorClass.IsWizard, ObjectEditorClass.IsObjectCreationMode
	':Сигнатура:
	'	Public Property Get IsEditor [As Boolean]
	Public Property Get IsEditor
		IsEditor = m_bIsTabbed
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsWizard
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsWizard>
	':Назначение:	
	'	Возвращает признак режима "мастера" (для элемента i:editor описания редактора
	'	задан атрибут wizard-mode, см. x-net-interface-schema.xsd).
	':См. также:
	'	ObjectEditorClass.IsEditor, ObjectEditorClass.IsObjectCreationMode,
	'	ObjectEditorClass.IsLinearWizard
	':Сигнатура:
	'	Public Property Get IsWizard [As Boolean]
	Public Property Get IsWizard
		IsWizard = Not m_bIsTabbed
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsAggregated
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsAggregated>
	':Назначение:	
	'	Показывает, что текущий редактор есть вложенный редактор, вызванный из 
	'	мастера нового объекта.
	':См. также:
	'	ObjectEditorClass.IsEditor, ObjectEditorClass.IsWizard, 
	'	ObjectEditorClass.IsObjectCreationMode
	':Сигнатура:
	'	Public Property Get IsAggregated [As Boolean]
	Public Property Get IsAggregated
		IsAggregated = m_bAggregation
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ObjectType
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE ObjectType>
	':Назначение:	Возвращает наименовение типа редактируемого (создаваемого) объекта.
	':См. также:	ObjectEditorClass.ObjectID, ObjectEditorClass.MetaName
	':Сигнатура:	Public Property Get ObjectType [As String]
	Public Property Get ObjectType
		ObjectType = m_sObjectType
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE ObjectID>
	':Назначение:	Возвращает идентификатор редактируемого объекта.
	':См. также:	ObjectEditorClass.ObjectType, ObjectEditorClass.MetaName
	':Сигнатура:	Public Property Get ObjectID [As String]
	Public Property Get ObjectID
		ObjectID = m_sObjectID
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.MetaName
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE MetaName>
	':Назначение:	Возвращает наименование описания редактора в метаданных.
	':См. также:	ObjectEditorClass.ObjectID, ObjectEditorClass.ObjectType,
	'				ObjectEditorClass.InterfaceMD
	':Сигнатура:	Public Property Get MetaName [As String]
	Public Property Get MetaName
		MetaName = m_sMetaName
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.InterfaceMD
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE InterfaceMD>
	':Назначение:	Возвращает XML с метаописанием редактора.
	':См. также:	ObjectEditorClass.MetaName
	':Сигнатура:	Public Property Get InterfaceMD [As IXMLDOMElement]
	Public Property Get InterfaceMD
		Set InterfaceMD = m_oInterfaceMD
	End Property


	'------------------------------------------------------------------------------
	':Назначение:	Возвращает стек страниц мастера. Для внутреннего использования!
	Private Property Get PageStack
		If IsEmpty(m_oPageStack) Then
			Set m_oPageStack = new StackClass
		End If
		Set PageStack = m_oPageStack
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE QueryString>
	':Назначение:	Возвращает экземпляр QueryStringClass, описывающий параметры 
	'				запроса страницы редактора / мастера.
	':См. также:	QueryStringClass
	':Сигнатура:	Public Property Get QueryString [As QueryStringClass]
	Public Property Get QueryString
		Set QueryString = m_oQueryString
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.XmlObject
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE XmlObject>
	':Назначение:	Возвращает XML-данные редактируемого объекта.
	':Примечание:	Внимание! Непосредственное изменение XML-данных объекта 
	'				<B>строго не рекомендуется</B>! Используйте соответствующие 
	'				методы объекта редактора (ObjectEditorClass) и пула данных
	'				объектов (XObjectPoolClass).
	':См. также:	ObjectEditorClass.ObjectType, ObjectEditorClass.ObjectID, <P/>
	'				XObjectPoolClass
	':Сигнатура:	Public Property Get XmlObject [As IXMLDOMElement]
	Public Property Get XmlObject
		Set XmlObject = m_oPool.GetXmlObject(ObjectType, ObjectID, Null)  
	End Property


	'@@ObjectEditorClass.SkipInitErrorAlerts
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE SkipInitErrorAlerts>
	':Назначение:	Указывает редактору и всем его компонентам о том, 
	'				что в случае невозможности установить значения UI контролов для текущего объекта, 
	'				не следует выдавать никаких предупреждений пользователю.
	':Сигнатура:	Public Property Get SkipInitErrorAlerts [As Boolean]
	Public Property Get SkipInitErrorAlerts
		SkipInitErrorAlerts = m_bSkipInitErrorAlerts
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ParentXmlProperty
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE ParentXmlProperty>
	':Назначение:	Возвращает XML-данные "родительского" свойства - объектного 
	'				свойства, объект которого представлен в текущем редакторе.
	'				Для "корневого" редактора значение свойства есть Nothing.
	':Примечание:	Внимание! Непосредственное изменение данных свойства
	'				<B>строго запрещается</B>! 
	':См. также:	ObjectEditorClass.IsIncluded, ObjectEditorClass.IsAggregated, 
	'				ObjectEditorClass.XmlObject
	':Сигнатура:	Public Property Get ParentXmlProperty [As IXMLDOMElement]
	Public Property Get ParentXmlProperty
		Set ParentXmlProperty = Nothing
		If Not IsIncluded Then Exit Property
		If Len("" & m_sParentObjectType) > 0 And Len("" & m_sParentObjectID) > 0 Then
			Set ParentXmlProperty = GetXmlObjectFromPool(m_sParentObjectType, m_sParentObjectID, Null).SelectSingleNode(m_sParentPropertyName)
		End If
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ParentObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE ParentObjectEditor>
	':Назначение:	Возвращает ссылку на родительский редактора, из которого был запущен текущий 
	'				или Nothing для корневого
	':Сигнатура:	Public Property Get ParentObjectEditor [As ObjectEditorClass]
	Public Property Get ParentObjectEditor
		Set ParentObjectEditor = m_oParentObjectEditor
	End Property
		
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetRootEditor
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetRootEditor>
	':Назначение:	Возвращает экземпляр корневого редактора в цепочке редакторов
	':Результат:	Экземпляр ObjectEditorClass, для корневого редактора метод вернет экземпляр текущего объекта
	':Сигнатура:
	'	Public Function GetRootEditor() [As ObjectEditorClass]
	Public Function GetRootEditor()
		Dim oEditor		' As ObjectEditorClass
		Set oEditor = Me
		While Not oEditor.ParentObjectEditor Is Nothing
			Set oEditor = oEditor.ParentObjectEditor
		Wend
		Set GetRootEditor = oEditor
	End Function
	
	'------------------------------------------------------------------------------
	':Назначение:	Признак нахождения мастера/редактора в фазе асинхронной 
	'				инициализации страницы. Для внутреннего использования!
	Public Property Get MayBeInterrupted
		MayBeInterrupted = CBool(m_bMayBeInterrupted)
	End Property  
	Private Property Let MayBeInterrupted(bTrue)
		m_bMayBeInterrupted =  bTrue
	End Property  


	'------------------------------------------------------------------------------
	':Назначение:	Признак прерывания работы редактора.
	'				Для внутреннего использования!
	Public Property Get IsInterrupted
		IsInterrupted = (true=m_bIsInterrupted)
	End Property
	Public Property Let IsInterrupted(bIsInterrupted)
		m_bIsInterrupted = (true=bIsInterrupted)
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetUniqueNameFor
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetUniqueNameFor>
	':Назначение:	Генерирует уникальное наименование для свойства.
	':Параметры:	oProperty - [in] XML-данные свойства, как экземпляр IXMLDOMElement
	':Результат:	Строка с уникальным наименованием.
	':Примечание:	Используется для получения уникальных идентификаторов редакторов
	'				свойств - обеспечивают уникальность идентификаторов даже в случае
	'				многократного отображения одного и того же свойства на странице 
	'				редактора.
	':Сигнатура:
	'	Public Function GetUniqueNameFor( oProperty [As IXMLDOMElement] ) [As String]
	Public Function GetUniqueNameFor(oProperty)
		Const MAX_NAME_LEN = 20
		Const NAME_PREFIX = "un_"
		Dim sRawName
		Dim sName
		Dim i

		sRawName = Mid(oProperty.nodeName, 1, MAX_NAME_LEN)
		sName = NAME_PREFIX & sRawName
		i=0
		While m_oNamesDictionary.Exists(sName)
			sName = NAME_PREFIX & sRawName & "_" & i
			i=i+1
		Wend
		m_oNamesDictionary.Add sName, True
		GetUniqueNameFor = sName
	End Function


	'------------------------------------------------------------------------------
	' Устанавливает значение необъектного свойства
	'	[in] oXmlProperty As IXMLDOMElement - xml-свойство объекта в пуле
	'	[in] vValue As Variant - значение свойства
	Function SetPropertyValue(oXmlProperty, vValue)
		SetPropertyValue = Pool.SetPropertyValue( oXmlProperty, vValue )
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ShowDebugMenu
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE ShowDebugMenu>
	':Назначение:	Отображение всплывающего отладочного меню редактора.
	':Сигнатура: 	Public Sub ShowDebugMenu
	Public Sub ShowDebugMenu
		If IsEmpty(m_oPopUpForDebugMenu) Then
			Set m_oPopUpForDebugMenu = XService.CreateObject("CROC.XPopUpMenu")
		End If
		m_oPopUpForDebugMenu.Clear
		m_oPopUpForDebugMenu.Add "Метаданные " & Iif(IsEditor,"редактора", "мастера") & " '" & MetaName & "'" , "X_DebugShowXml InterfaceMD"
		m_oPopUpForDebugMenu.Add "Метаданные типа '" & ObjectType & "'", "X_DebugShowXml X_GetTypeMD(ObjectType)"
		m_oPopUpForDebugMenu.Add "Текущий объект", "X_DebugShowXml XmlObject"
		m_oPopUpForDebugMenu.Add "Текущий пул объектов", "X_DebugShowXml XmlObjectPool"
		m_oPopUpForDebugMenu.Add "Эффективная датаграмма для сохранения", "X_DebugShowXml GetXmlDatagramForSave()"
		m_oPopUpForDebugMenu.Add "Html-дерево содержимого", "X_DebugShowHtml HtmlPageContainer"
		m_oPopUpForDebugMenu.Add "Html-дерево всего редактора", "X_DebugShowHtml document.body.parentNode.outerHTML"
		m_oPopUpForDebugMenu.Add "Строка параметров", "alert QueryString.QueryString"
		Execute m_oPopUpForDebugMenu.Show & " ' Фиктивный комментарий на случай пустого выбора"
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetWindow
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetWindow>
	':Назначение:	Возвращает объект HTML-окна (IHTMLWindow2), в котором создан редактор.
	':Сигнатура:	Public Function GetWindow [As IHTMLWindow2]
	Public Function GetWindow
		Set GetWindow = window
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OnKeyUp
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OnKeyUp>
	':Назначение:	
	'	Обработчик нажатия комбинации клавиш.
	':Параметры:
	'	oSender - [in] объект, сгенерировавший событие
	'	oEventArgs - [in] параметры события, экземпляр AccelerationEventArgsClass
	':Примечание:	
	'	Метод генерирует событие Accel, передавая в обработчик события исходные 
	'	параметры, представленные параметром oEventArgs. Если обработчик не 
	'	обрабатывает событие (свойство AccelerationEventArgsClass.Processed остается
	'	установленным в значение False), метод передает управление в "контейнер",
	'	вызывая метод IObjectContainerEventsClass.OnKeyUp.
	':См. также:	
	'	IObjectContainerEventsClass
	':Сигнатура:	
	'	Public Sub OnKeyUp( 
	'		oSender [As Object], 
	'		oEventArgs [As AccelerationEventArgsClass] )
	Public Sub OnKeyUp(oSender, oEventArgs)
		fireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' ' если нажатая комбинация не обработана - передадим ее в контейнер
			m_oObjectContainerEventsImp.OnKeyUp Me, oEventArgs
		End If
	End Sub
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OnKeyDown
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OnKeyDown>
	':Назначение:	
	'	Обработчик нажатия комбинации клавиш.
	':Параметры:
	'	oSender - [in] объект, сгенерировавший событие
	'	oEventArgs - [in] параметры события, экземпляр AccelerationEventArgsClass
	':Примечание:	
	'	Метод передает управление в "контейнер",
	'	вызывая метод IObjectContainerEventsClass.OnKeyDown.
	':См. также:	
	'	IObjectContainerEventsClass
	':Сигнатура:	
	'	Public Sub OnKeyDown( 
	'		oSender [As Object], 
	'		oEventArgs [As AccelerationEventArgsClass] )
	Public Sub OnKeyDown(oSender, oEventArgs)
		m_oObjectContainerEventsImp.OnKeyDown Me, oEventArgs
	End Sub
	
End Class


'===============================================================================
'@@SetCaptionEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE SetCaptionEventArgsClass>
':Назначение:	Параметры события "SetCaption".
'
'@@!!MEMBERTYPE_Methods_SetCaptionEventArgsClass
'<GROUP SetCaptionEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_SetCaptionEventArgsClass
'<GROUP SetCaptionEventArgsClass><TITLE Свойства>
Class SetCaptionEventArgsClass
	'@@SetCaptionEventArgsClass.PageTitle
	'<GROUP !!MEMBERTYPE_Properties_SetCaptionEventArgsClass><TITLE PageTitle>
	':Назначение:	Заголовок страницы / шага мастера.
	':Сигнатура:	Public PageTitle [As String]
	Public PageTitle
	
	'@@SetCaptionEventArgsClass.EditorCaption
	'<GROUP !!MEMBERTYPE_Properties_SetCaptionEventArgsClass><TITLE EditorCaption>
	':Назначение:	Полный заголовок редактора / мастера.
	':Сигнатура:	Public EditorCaption [As String]
	Public EditorCaption
	
	'@@SetCaptionEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_SetCaptionEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@SetCaptionEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SetCaptionEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As SetCaptionEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@PrepareSaveRequestEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE PrepareSaveRequestEventArgsClass>
':Назначение:	Параметры события "PrepareSaveRequest".
'
'@@!!MEMBERTYPE_Methods_PrepareSaveRequestEventArgsClass
'<GROUP PrepareSaveRequestEventArgsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_PrepareSaveRequestEventArgsClass
'<GROUP PrepareSaveRequestEventArgsClass><TITLE Свойства>
Class PrepareSaveRequestEventArgsClass
	'@@PrepareSaveRequestEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_PrepareSaveRequestEventArgsClass><TITLE Cancel>
	':Назначение:	Признак, задающий прерывание цепочки обработки событий.
	':Сигнатура:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@PrepareSaveRequestEventArgsClass.CommandName
	'<GROUP !!MEMBERTYPE_Properties_PrepareSaveRequestEventArgsClass><TITLE CommandName>
	':Назначение:	Наименование операции сервера приложения, вызываемой 
	'				для сохранения редактируемых данных.
	':Сигнатура:	Public CommandName [As String]
	':См. также:	XRequest.Name
	Public CommandName
	
	'@@PrepareSaveRequestEventArgsClass.Context
	'<GROUP !!MEMBERTYPE_Properties_PrepareSaveRequestEventArgsClass><TITLE Context>
	':Назначение:	
	':Сигнатура:	Public Context [As String]
	Public Context
	
	'@@PrepareSaveRequestEventArgsClass.XmlBatch
	'<GROUP !!MEMBERTYPE_Properties_PrepareSaveRequestEventArgsClass><TITLE XmlBatch>
	':Назначение:	
	':Сигнатура:	Public XmlBatch [As IXMLDOMElement]	
	Public XmlBatch
	
	'@@PrepareSaveRequestEventArgsClass.Request
	'<GROUP !!MEMBERTYPE_Properties_PrepareSaveRequestEventArgsClass><TITLE Request>
	':Назначение:	Объект запроса для операции сохранения.
	':Сигнатура:	Public Request [As Object]
	':См. также:	
	'	PrepareSaveRequestEventArgsClass.CommandName, 
	'	Croc.XmlFramework.Public.XRequest
	Public Request
	
	'@@PrepareSaveRequestEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_PrepareSaveRequestEventArgsClass><TITLE Self>
	':Назначение:	Возвращает ссылку на текущий экземпляр класса.
	':Сигнатура:	Public Function Self() [As PrepareSaveRequestEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@ParseWizardBackMode
'<GROUP !!FUNCTIONS_x-editor><TITLE ParseWizardBackMode>
':Назначение:
'	Преобразует значение атрибута wizard-mode, определяющего работу редактора
'	в режиме мастера, в соответсвующую константу вида XEB_nnnn.
':Параметры:
'	sWizardMode - [in] строкое значение атрибута wizard-mode
':Результат:
'	Константа вида XEB_nnnn.
':Примечание:
'	Если значение параметра sWizardMode не может быть сопоставлено ни с одним 
'	из возможных значений атрибута wizard-mode, то функция возвращает константу 
'	XEB_UNDOCHANGES.<P/>
'	Перечень допустимых значений атрибута wizard-mode приведен в схеме 
'	x-net-interface-schema.xsd.
':Сигнатура:
'	Public Function ParseWizardBackMode( sWizardMode [As String] ) [As XEB_nnnn]
Public Function ParseWizardBackMode(sWizardMode)
	Dim nBackMode
	Select Case sWizardMode
		Case "do-nothing" 
			nBackMode = XEB_DO_NOTHING
		Case "get-data"   
			nBackMode = XEB_TRY_GET_DATA
		Case Else 
			nBackMode = XEB_UNDOCHANGES 
	End Select
	ParseWizardBackMode = nBackMode
End Function