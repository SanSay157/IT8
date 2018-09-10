'===============================================================================
'@@!!FILE_x-filter
'<GROUP !!SYMREF_VBS>
'<TITLE x-filter - Фильтрация списков/деревьев>
':Назначение:	Описание общих классов и интерфейсов.
':См. также:	<LINK Filter, Фильтры />
'===============================================================================
'@@!!FUNCTIONS_x-filter
'<GROUP !!FILE_x-filter><TITLE Функции и процедуры>
'@@!!CLASSES_x-filter
'<GROUP !!FILE_x-filter><TITLE Классы>

Option Explicit

'===============================================================================
'@@X_GetFilterObject
'<GROUP !!FUNCTIONS_x-filter><TITLE X_GetFilterObject>
':Назначение:
'	Фабричная функция для класса XFilterObjectClass.
':Параметры:
'	oIFrameObject - [in] объект iframe, в который загружена страница со скриптами,
'                   "реализующими" <LINK Filter-01, интерфейс IFilterObject />.                   
':Сигнатура:
'	Public Function X_GetFilterObject( oIFrameObject [As IHTMLElement] ) [As XFilterObjectClass]

Public Function X_GetFilterObject(oIFrameObject)
	Set X_GetFilterObject = New XFilterObjectClass
	X_GetFilterObject.Internal_AttachFrame oIFrameObject
End Function

'===============================================================================
'@@XFilterObjectClass
'<GROUP !!CLASSES_x-filter><TITLE XFilterObjectClass>
':Назначение:	
'	Класс инкапсулирует доступ к фильтру. 
'
'@@!!MEMBERTYPE_Methods_XFilterObjectClass
'<GROUP XFilterObjectClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_XFilterObjectClass
'<GROUP XFilterObjectClass><TITLE Свойства>


Class XFilterObjectClass
	Private m_oIFrameObject			' Объект iframe
	
	'---------------------------------------------------------------------------
	':Параметры:
	'	oIFrameObject - [in] объект iframe, в который загружена страница со скриптами, "реализующими" "интерфейс" IFilterObject
	Public Sub Internal_AttachFrame(oIFrameObject)
		Set m_oIFrameObject = oIFrameObject
	End Sub
	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.Enabled
	'<GROUP !!MEMBERTYPE_Properties_XFilterObjectClass><TITLE Enabled>
	':Назначение:	
	'	Свойство, управляющее доступностью элементов фильтра для 
	'	пользовательского ввода.
	':Примечание:	
	'	Свойство доступно как для чтения, так и для изменения.
	':Сигнатура:	
	'	Public Property Get Enabled() [As Boolean]
	'	Public Property Let Enabled( bEnabled [As Boolean] ) [As Boolean]
	Public Property Get Enabled()
		Enabled = m_oIFrameObject.contentWindow.public_get_Enabled()
	End Property
	Public Property Let Enabled( bEnabled )
		m_oIFrameObject.contentWindow.public_put_Enabled( CBool(bEnabled) )
	End Property

	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.IsComponentReady
	'<GROUP !!MEMBERTYPE_Properties_XFilterObjectClass><TITLE IsComponentReady>
	':Назначение:	
	'	Признак загрузки всего содержимого компоненты (в нашем случае фрейма с 
	'   фильтром).
	':Примечание:	
	'	Свойство принимает значение True, когда страница фильтра загружена и, 
	'   следовательно, можно вызывать функцию <LINK XFilterObjectClass.Init, Init />, 
	'   и False - в противном случае.<P/>
	'   Свойство только для чтения.<P/>
	'   Имеет смысл проверять (через X_WaitForTrue) после создания до вызова функции
	'   <LINK XFilterObjectClass.Init, Init />.
	':Сигнатура:	
	'	Public Property Get IsComponentReady() [As Boolean]
	Public Property Get IsComponentReady()
		IsComponentReady = m_oIFrameObject.contentWindow.public_get_IsComponentReady()
	End Property


	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.IsReady
	'<GROUP !!MEMBERTYPE_Properties_XFilterObjectClass><TITLE IsReady>
	':Назначение:	
	'	Признак готовности фильтра после завершения инициализации 
	'   (XFilterObjectClass.IsComponentReady AND Not XFilterObjectClass.IsBusy).
	':Примечание:	
	'	Свойство принимает значение True, если содержимое фильтра отрисовано, 
	'   и False - в противном случае.<P/>
	'   Свойство только для чтения.<P/>
	'   Имеет смысл проверять (через X_WaitForTrue) после вызова функции 
	'   <LINK XFilterObjectClass.Init, Init />.
	':Сигнатура:	
	'	Public Property Get IsReady() [As Boolean]
	Public Property Get IsReady()
		IsReady = m_oIFrameObject.contentWindow.public_get_IsReady()
	End Property

	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.ObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_XFilterObjectClass><TITLE ObjectEditor>
	':Назначение:	
	'	Работающий в фильтре редактор объектов.
	':Примечание:	
	'   Свойство только для чтения.
	':Сигнатура:	
	'	Public Property Get ObjectEditor [As ObjectEditor]
	Public Property Get ObjectEditor
		' Фильтр не обязан реализовывать это "свойство" public_get_ObjectEditor
		On Error Resume Next
		Set ObjectEditor = m_oIFrameObject.contentWindow.public_get_ObjectEditor()
		Err.Clear
	End Property 
	
	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.IsBusy
	'<GROUP !!MEMBERTYPE_Properties_XFilterObjectClass><TITLE IsBusy>
	':Назначение:	
	'	Признак незанятости.<P/>
	'	Так как фильтр может быть сложным объектом, выполняющим асинхронные 
	'	операции, то это свойство сигнализирует о нахождении фильтра в процессе 
	'	выполнения асинхронной операции.
	':Примечание:	
	'	Свойство принимает значение True, если фильтр находится в процессе  
	'   выполнения асинхронной операции, и False - в противном случае.<P/>
	'   Свойство только для чтения.
	':Сигнатура:	
	'	Public Property Get IsBusy() [As Boolean]
	Public Property Get IsBusy()
		IsBusy = m_oIFrameObject.contentWindow.public_get_IsBusy()
	End Property 

	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.Init
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE Init>
	':Назначение:	
	'	Функция выполняет инициализацию фильтра.
	':Параметры:
	'	oEventEngine - 
	'       [in] EventEngine для передачи событий от фильтра в контейнер.
	'	oFilterObjectInitializationParamsObject - 
	'       [in] экземпляр класса FilterObjectInitializationParamsClass.
	':Результат:
	'	Возвращает True при успешном завершении инициализации и False
	'   в противном случае (ошибки могут передаваться через Err).
	':Сигнатура:
	'	Function Init ( 
	'		oEventEngine [As XEventEngine], 
	'		oFilterObjectInitializationParamsObject [As FilterObjectInitializationParamsClass] 
	'	) [As Boolean]
	Function Init(oEventEngine, oFilterObjectInitializationParamsObject) 
		Init = m_oIFrameObject.contentWindow.public_Init( oEventEngine, oFilterObjectInitializationParamsObject )
	End Function


	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.GetRestrictions
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE GetRestrictions>
	':Назначение:	
	'	Процедура выполняет сбор ограничений фильтра.
	':Параметры:
	'	oFilterObjectGetRestrictionsParamsObject - 
	'       [in] экземпляр класса FilterObjectGetRestrictionsParamsClass.
	':Сигнатура:
	'	Sub GetRestrictions ( 
	'		oFilterObjectGetRestrictionsParamsObject [As FilterObjectGetRestrictionsParamsClass] 
	'	)
	Sub GetRestrictions( oFilterObjectGetRestrictionsParamsObject )
		m_oIFrameObject.contentWindow.public_GetRestrictions( oFilterObjectGetRestrictionsParamsObject )
	End Sub


	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.ClearRestrictions
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE ClearRestrictions>
	':Назначение:	
	'	Процедура выполняет сброс ограничений фильтра в значения по умолчанию.
	':Сигнатура:
	'	Sub ClearRestrictions () 
	Sub ClearRestrictions()
		m_oIFrameObject.contentWindow.public_ClearRestrictions()
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.GetXmlState
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE GetXmlState>
	':Назначение:	
	'	Функция возвращает XML-датаграмму измененных объектов/свойств в фильтре.
	':Сигнатура:
	'	Function GetXmlState () [As IXMLDOMElement]
	Function GetXmlState()
		Set GetXmlState = m_oIFrameObject.contentWindow.public_GetXmlState()
	End Function

	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.SetVisibility
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE SetVisibility>
	':Назначение:	
	'	Процедура устанавливает видимость компоненты.
	':Параметры:
	'	bShow - 
	'       [in] True - показать фильтр, False - спрятать фильтр.
	':Примечание:	
	'	Существует проблема - после вызова SetVisibility(True) фокус остается 
	'   на активном элементе и принимает ввод!<P/>
	'   Побороть пока не удалось.
	':Сигнатура:
    '	Sub SetVisibility ( bShow [As Boolean] )
	Sub SetVisibility(bShow)
		If bShow Then
			m_oIFrameObject.style.display = "block"
		Else
			m_oIFrameObject.style.display = "none"
		End If
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.OnKeyUp
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE OnKeyUp>
	':Назначение:	
	'	Процедура-обработчик комбинации клавиш, нажатых в контейнере.
	':Параметры:
	'	oEventArgs - 
	'       [in] параметры события, экземпляр класса AccelerationEventArgsClass.
	':Сигнатура:
    '	Sub OnKeyUp ( oEventArgs [As AccelerationEventArgsClass] )
	Sub OnKeyUp(oEventArgs)
		m_oIFrameObject.contentWindow.public_OnKeyUp oEventArgs
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.ShowDebugMenu
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE ShowDebugMenu>
	':Назначение:	
	'	Процедура предназначена для отображения отладочного меню фильтра.
	':Сигнатура:
    '	Sub ShowDebugMenu ()
	Sub ShowDebugMenu()
		m_oIFrameObject.contentWindow.public_ShowDebugMenu()
	End Sub
	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.SetFocus
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE SetFocus>
	':Назначение:	
	'	Процедура предназначена для установки в фильтре фокуса по умолчанию.
	':Сигнатура:
    '	Sub SetFocus ()
	Sub SetFocus()
		m_oIFrameObject.contentWindow.public_SetFocus()
	End Sub
End Class

'===============================================================================
'@@FilterObjectInitializationParamsClass
'<GROUP !!CLASSES_x-filter><TITLE FilterObjectInitializationParamsClass>
':Назначение:	
'	Структура для инициализации фильтра. Используется при вызове функции
'   <LINK Filter-011, Init /> публичного интерфейса страницы фильтра.
'
'@@!!MEMBERTYPE_Methods_FilterObjectInitializationParamsClass
'<GROUP FilterObjectInitializationParamsClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_FilterObjectInitializationParamsClass
'<GROUP FilterObjectInitializationParamsClass><TITLE Свойства>

Class FilterObjectInitializationParamsClass

	'------------------------------------------------------------------------------
	'@@FilterObjectInitializationParamsClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectInitializationParamsClass><TITLE QueryString>
	':Назначение:	
	'	Строка параметров запроса контейнера. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public QueryString [As QueryStringClass]
	Public QueryString				' As QueryStringClass
	
	'------------------------------------------------------------------------------
	'@@FilterObjectInitializationParamsClass.XmlState
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectInitializationParamsClass><TITLE XmlState>
	':Назначение:	
	'	Сохраненные ранее значения фильтра. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.<P/>
	'   Формат зависит от конкретной реализации фильтра.
	':Сигнатура:	
	'	Public XmlState [As IXMLDOMElement]
	Public XmlState					' As IXMLDOMElement, формат - интимное дело конкретного фильтра

	'------------------------------------------------------------------------------
	'@@FilterObjectInitializationParamsClass.OuterContainerPage
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectInitializationParamsClass><TITLE OuterContainerPage>
	':Назначение:	
	'	Экземпляр класса контейнера хост-страницы, то есть страницы, создающей и 
	'   инициализирующей экземпляр класса XFilterObjectClass:
	'	- для списка - это XListPageClass;
	'	- для иерархии - это XTreePageClass.
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public OuterContainerPage [As Object]
	Public OuterContainerPage		' As Object
	
	
	'------------------------------------------------------------------------------
	'@@FilterObjectInitializationParamsClass.DisableContentScrolling
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectInitializationParamsClass><TITLE DisableContentScrolling>
	':Назначение:	
	'	Признак отключения скроллинга содержимого фильтра. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.<P/>
	'   Используется в списках и иерархиях.
	':Сигнатура:	
	'	Public DisableContentScrolling [As Boolean]
	Public DisableContentScrolling
	
	'------------------------------------------------------------------------------
	'@@FilterObjectInitializationParamsClass.GetRightsCache
	'<GROUP !!MEMBERTYPE_Methods_FilterObjectInitializationParamsClass><TITLE GetRightsCache>
	':Назначение:	
	'	Функция возвращает уникальный глобальный экземпляр кеша прав, 
	'   ObjectRightsCacheClass.
	':Сигнатура:
    '	Public Function GetRightsCache [As ObjectRightsCacheClass]
	Public Function GetRightsCache
		Set GetRightsCache = X_RightsCache()
	End Function
	
	'-------------------------------------------------------------------------------
	' Конструктор
	Private Sub Class_Initialize
		Set QueryString = Nothing
		Set XmlState = Nothing
	End Sub	
End Class


'===============================================================================
'@@FilterObjectGetRestrictionsParamsClass
'<GROUP !!CLASSES_x-filter><TITLE FilterObjectGetRestrictionsParamsClass>
':Назначение:	
'	Структура для сбора ограничений фильтра. Используется при вызове функции
'   IFilterObject::GetRestrictions.
'
'@@!!MEMBERTYPE_Properties_FilterObjectGetRestrictionsParamsClass
'<GROUP FilterObjectGetRestrictionsParamsClass><TITLE Свойства>
Class FilterObjectGetRestrictionsParamsClass

	'------------------------------------------------------------------------------
	'@@FilterObjectGetRestrictionsParamsClass.Description
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectGetRestrictionsParamsClass><TITLE Description>
	':Назначение:	
	'	Описание ограничений. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public Description [As String]
	Public Description

	'------------------------------------------------------------------------------
	'@@FilterObjectGetRestrictionsParamsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectGetRestrictionsParamsClass><TITLE ReturnValue>
	':Назначение:	
	'	Признак успешного сбора данных. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	'------------------------------------------------------------------------------
	'@@FilterObjectGetRestrictionsParamsClass.ParamCollectionBuilder
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectGetRestrictionsParamsClass><TITLE ParamCollectionBuilder>
	':Назначение:	
	'	Формирователь коллекции ограничений. 
	':Примечание:	
	'	Свойство доступно как для чтения, так и для записи.
	':Сигнатура:	
	'	Public ParamCollectionBuilder [As IParamCollectionBuilder]
	Public ParamCollectionBuilder
	
	
	'-------------------------------------------------------------------------------
	' Назначение:	Конструктор
	' Результат:    
	' Параметры:	
	' Примечание:	
	' Зависимости:	
	' Пример: 
	Private Sub Class_Initialize
		' По умолчанию все ОК
		ReturnValue = True
		' По умолчанию поднимем "пустой" класс	
		Set ParamCollectionBuilder = New IParamCollectionBuilder
	End Sub
End Class
