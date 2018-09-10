Option Explicit

'==============================================================================
Dim ObjectEditor			' Редактор объекта
Dim Pool					' Пул объектов

'==============================================================================
Sub InitGlobals(oObjectEditor)
	' запоминаем объект редактора
	Set ObjectEditor = oObjectEditor
	' запоминаем пул
	Set Pool = ObjectEditor.Pool
End Sub

'==============================================================================
' Вспомогательный класс для управления отображением совокупности свойств
' "Сотрудник", "Ознакомился" и "Дата"
Class AcquaintedEmployeeHandlerClass
	Private m_oEmployeeEditor	' As XPEObjectPresentationClass - редактор сотрудника
	Private m_oIsAcquaintEditor	' As XPEBoolClass - редактор признака "Ознакомился"
	Private m_oDateEditor		' As XPEDateTimeClass - редактор даты
	
	'==========================================================================
	' Инициализация членов класса
	' [in] m_oEmployeeEditor	- XPEObjectPresentationClass, редактор сотрудника
	' [in] m_oIsAcquaintEditor	- XPEBoolClass, редактор признака "Ознакомился"
	' [in] m_oDateEditor		- XPEDateTimeClass, редактор даты
	Public Sub Init(oEmployeeEditor, oIsAcquaintEditor, oDateEditor)
		Set m_oEmployeeEditor = oEmployeeEditor
		Set m_oIsAcquaintEditor = oIsAcquaintEditor
		Set m_oDateEditor = oDateEditor
		
		' Подписываемся на события редакторов свойств
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "BeforeSelect", Me, "OnEmployeeChanging"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterSelect", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "BeforeUnlink", Me, "OnEmployeeChanging"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterUnlink", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "BeforeCreate", Me, "OnEmployeeChanging"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterCreate", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "BeforeDelete", Me, "OnEmployeeChanging"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterDelete", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "BeforeMarkDelete", Me, "OnEmployeeChanging"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterMarkDelete", Me, "OnEmployeeChanged"
		m_oIsAcquaintEditor.EventEngine.AddHandlerForEvent "Changed", Me, "OnIsAcquaintChanged"
		
		' Устанавливаем отображение связанных редакторов
		Handle()
	End Sub
	
	'==========================================================================
	' Устанавливает отображение связанных редакторов
	Public Sub Handle()
		' Разрешаем/запрещаем редакторы признака "Ознакомился" и даты
		disableIsAcquaint()
		disableDate()
	End Sub
	
	'==========================================================================
	' Обработчик событий, возникающий перед изменением свойства "Сотрудник"
	Public Sub OnEmployeeChanging(oSender, oEventArgs)
		Dim sMessage
		
		' если признак "Ознакомился" и дата не заданы, то ничего не делаем
		If m_oIsAcquaintEditor.Value = False And _
			Not hasValue(m_oDateEditor.Value) Then Exit Sub

		sMessage = "Значения свойств """ & m_oIsAcquaintEditor.PropertyDescription & """ и """ & m_oDateEditor.PropertyDescription & """ будут сброшены." & vbNewLine & "Вы уверены, что хотите продолжить?"
		If confirm(sMessage) = False Then
			oEventArgs.ReturnValue = False
			m_oEmployeeEditor.SetData()
			Exit Sub
		End If
	End Sub	
	
	'==========================================================================
	' Обработчик событий, возникающий после изменения свойства "Сотрудник"
	Public Sub OnEmployeeChanged(oSender, oEventArgs)
		m_oIsAcquaintEditor.Value = False
		m_oDateEditor.Value = Null

		disableIsAcquaint()
	End Sub	
	
	'==========================================================================
	' Обработчик события OnChanged для признака "Ознакомился"
	Public Sub OnIsAcquaintChanged(oSender, oEventArgs)
		disableDate()
	End Sub	
	
	'==========================================================================
	' Разрешает/запрещает редактор признака "Ознакомился" в зависимости от
	' того, задан сотрудник или нет
	Private Sub disableIsAcquaint()
		If m_oEmployeeEditor.Value Is Nothing Then
			m_oIsAcquaintEditor.Value = False
			TMS_EnablePropertyEditor m_oIsAcquaintEditor, False
		Else
			TMS_EnablePropertyEditor m_oIsAcquaintEditor, True
		End If	
	End Sub

	'==============================================================================
	' Разрешает/запрещает редактор даты в зависимости от того, задан признак
	' "Ознакомился" сотрудник или нет
	Private Sub disableDate()
		If m_oIsAcquaintEditor.Value = False Then
			m_oDateEditor.Value = Null
			TMS_EnablePropertyEditor m_oDateEditor, False
		Else
			TMS_EnablePropertyEditor m_oDateEditor, True
		End If
	End Sub

End Class

'==============================================================================
' Вспомогательный класс для управления отображением совокупности свойств
' "Сотрудник", "Дата"
Class EmployeeDateHandlerClass
	Private m_oEmployeeEditor	' As XPEObjectPresentationClass - редактор сотрудника
	Private m_oDateEditor		' As XPEDateTimeClass - редактор даты
	
	'==========================================================================
	' Инициализация членов класса
	' [in] m_oEmployeeEditor	- XPEObjectPresentationClass, редактор сотрудника
	' [in] m_oDateEditor		- XPEDateTimeClass, редактор даты
	Public Sub Init(oEmployeeEditor, oDateEditor)
		Set m_oEmployeeEditor = oEmployeeEditor
		Set m_oDateEditor = oDateEditor
		
		' Подписываемся на события редакторов свойств
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterSelect", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterUnlink", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterCreate", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterDelete", Me, "OnEmployeeChanged"
		m_oEmployeeEditor.EventEngine.AddHandlerForEvent "AfterMarkDelete", Me, "OnEmployeeChanged"
		
		' Устанавливает обязательность даты в зависимости от задания сотрудника
		setDateMandatory()
	End Sub
	
	'==========================================================================
	' Обработчик событий, возникающий после изменения свойства "Сотрудник"
	Public Sub OnEmployeeChanged(oSender, oEventArgs)
		setDateMandatory()
	End Sub	
	
	'==============================================================================
	' Устанавливает обязательность даты в зависимости от задания сотрудника
	Sub setDateMandatory()
		' если задан сотрудник, то дата также должна быть задана
		If m_oEmployeeEditor.Value Is Nothing Then
			m_oDateEditor.Mandatory = False
		Else
			m_oDateEditor.Mandatory = True
		End If
	End Sub

End Class


'==============================================================================
' Создает и инициализирует экземпляр AcquaintedEmployeeHandlerClass
' [in] m_oEmployeeEditor	- XPEObjectPresentationClass, редактор сотрудника
' [in] m_oDateEditor		- XPEDateTimeClass, редактор даты
' [out] - экземпляр EmployeeDateHandlerClass
Function TMS_InitEmployeeDateHandler(oEmployeeEditor, oDateEditor)
	Dim oEmployeeDateHandler	' As EmployeeDateHandlerClass

	Set oEmployeeDateHandler = New EmployeeDateHandlerClass
	
	oEmployeeDateHandler.Init oEmployeeEditor, oDateEditor

	Set TMS_InitEmployeeDateHandler = oEmployeeDateHandler	
End Function


'==============================================================================
' Создает и инициализирует экземпляр AcquaintedEmployeeHandlerClass
' [in] m_oEmployeeEditor	- XPEObjectPresentationClass, редактор сотрудника
' [in] m_oIsAcquaintEditor	- XPEBoolClass, редактор признака "Ознакомился"
' [in] m_oDateEditor		- XPEDateTimeClass, редактор даты
' [out] - экземпляр AcquaintedEmployeeHandlerClass
Function TMS_InitAcquaintedEmployeeHandler(oEmployeeEditor, oIsAcquaintEditor, oDateEditor)
	Dim oAcquaintedEmployeeHandler	' As AcquaintedEmployeeHandlerClass

	Set oAcquaintedEmployeeHandler = New AcquaintedEmployeeHandlerClass
	
	oAcquaintedEmployeeHandler.Init oEmployeeEditor, oIsAcquaintEditor, oDateEditor

	Set TMS_InitAcquaintedEmployeeHandler = oAcquaintedEmployeeHandler	
End Function


'==============================================================================
' Разрешает/запрещает редактор свойства
' [in] oPropEditor	- As IPropertyEditor, редактор свойства
' [in] bEnable		- As Boolean, признак доступности редактора
Sub TMS_EnablePropertyEditor(oPropEditor, bEnable)
	If bEnable Then
		' Не используем "стек доступности", так как количества разрешений
		' и запрещений могут быть не равны
		oPropEditor.ParentPage.EnablePropertyEditorEx oPropEditor, True, True
	Else
		oPropEditor.ParentPage.EnablePropertyEditor oPropEditor, False
	End If
End Sub
	
'==============================================================================
' Возвращает PropertyEditor для заданного свойства объекта
' [in] oObjectEditor	- ObjectEditorClass, редактор объекта
' [in] oXmlObject		- IDOMXMLElement, объект в пуле
' [in] sPropName		- String, OPath свойтва
' [out] - редактор заданного свойства на текущей странице
Function TMS_GetPropertyEditor(oObjectEditor, oXmlObject, sPropName)
	' если объект не задан, берем объект из редактора
	If oXmlObject Is Nothing Then
		Set oXmlObject = oObjectEditor.XmlObject
	End If
	Set TMS_GetPropertyEditor = oObjectEditor.CurrentPage.GetPropertyEditor( _
		oObjectEditor.Pool.GetXmlProperty( oXmlObject, sPropName) )
End Function


'==============================================================================
' Возвращает строковое представление суммы
' [in] curSumValue		- Currency, сумма
' [in] sCurrencyCode	- String, код валюты
' [in] dExchangeRate	- Double, курс перевода
' [out] - строковое представление суммы
Function TMS_GetSumString(curSumValue, sCurrencyCode, dExchangeRate)
	If Not hasValue(curSumValue) Or Not hasValue(sCurrencyCode) Then
		TMS_GetSumString = ""
	Else
		TMS_GetSumString = Replace(FormatNumber(curSumValue, 2), ",", ".") & " " & sCurrencyCode
		' добавляем курс перевода, если задан
		If hasValue(dExchangeRate) Then
			TMS_GetSumString = TMS_GetSumString & " (" & Replace(CStr(dExchangeRate), ",", ".") & ")"
		End If
	End If
End Function

'==============================================================================
' Возвращает строковое представление сотрудника
' [in] sLastName	- String, фамилия
' [in] sFirstName	- String, имя
' [in] sMiddleName	- String, отчество
' [out] - строковое представление сотрудника
Function TMS_GetEmployeeString(sLastName, sFirstName, sMiddleName)
	If Not hasValue(sLastName) Or Not hasValue(sFirstName) Then
		TMS_GetEmployeeString = ""
	Else
		TMS_GetEmployeeString = sLastName & " " & sFirstName
		' добавляем отчество, если задано
		If hasValue(sMiddleName) Then
			TMS_GetEmployeeString = TMS_GetEmployeeString & " " & sMiddleName
		End If
	End If
End Function

'==============================================================================
' Возвращает строковое представление для пары значений ("Ознакомился", "Дата")
' [in] bIsAcquaint	- Boolean, признак "Ознакомился"
' [in] dtDate		- Date, дата
' [out] - строковое представление значений
Function TMS_GetAcquaintedDateString(bIsAcquaint, dtDate)
	If Not hasValue(bIsAcquaint) Then
		TMS_GetAcquaintedDateString = ""
	Else
		If bIsAcquaint Then
			TMS_GetAcquaintedDateString = "Да"
		Else
			TMS_GetAcquaintedDateString = "Нет"
		End If
		
		' добавляем дату, если задана
		If hasValue(dtDate) Then
			TMS_GetAcquaintedDateString = TMS_GetAcquaintedDateString & ", " & FormatDateTime(dtDate, vbShortDate)
		End If
	End If
End Function

'==============================================================================
' Возвращает строковое представление банковской гарантии
' [in] curSumValue		- Currency, сумма
' [in] sCurrencyCode	- String, код валюты
' [in] nValidityPeriod	- Integer, срок действия
' [in] dtEndingDate		- Date, дата окончания действия
' [in] nPortionValue	- Integer, доля банковской гарантии
' [out] - строковое представление банковской гарантии
Function TMS_GetGuaranteeString(curSumValue, sCurrencyCode, nValidityPeriod, dtEndingDate, nPortionValue)
	If hasValue(curSumValue) And hasValue(sCurrencyCode) Then
		TMS_GetGuaranteeString = TMS_GetSumString(curSumValue, sCurrencyCode, Empty) & ", на " & CStr(nValidityPeriod) & " дней, до " & FormatDateTime(dtEndingDate, vbShortDate)
		' добавляем долю банковской гарантии, если она задана
		If hasValue(nPortionValue) Then
			TMS_GetGuaranteeString = TMS_GetGuaranteeString & " / " & nPortionValue & "%"
		End If
	ElseIf hasValue(nPortionValue) Then
		TMS_GetGuaranteeString = nPortionValue & "%, на " & CStr(nValidityPeriod) & " дней, до " & FormatDateTime(dtEndingDate, vbShortDate)
	Else
		TMS_GetGuaranteeString = ""
	End If
End Function

'==============================================================================
' Возвращает итоговый статус для участника лота
' [in] nLotState - Integer, состояние лота
' [in] bWinner   - Boolean, признак "Победитель"
' [out] - строка, содержащая итоговый статус участника лота
Function TMS_GetWinnerString(nLotState, bWinner)
	If nLotState <> LOTSTATE_WASGAIN And nLotState <> LOTSTATE_WASLOSS Then
		TMS_GetWinnerString = ""
	Else
		If CBool(bWinner) Then 
			TMS_GetWinnerString = "Победитель"
		Else
			TMS_GetWinnerString = "Проигравший"
		End If
	End If
End Function

'==============================================================================
' Возвращает селектор иконки для участника лота
' [in] nParticipationType	- Integer, тип участния
' [in] bWinner				- Boolean, признак "Победитель"
' [out] - селектор иконки для участника лота
Function TMS_GetLotParticipantSelector(nParticipationType, bWinner)
	Dim nSelector	' значение селектора
	
	If Not hasValue(nParticipationType) Or Not hasValue(bWinner) Then
		nSelector = Empty
	Else
		If Not CBool(bWinner) Then
			Select Case nParticipationType
				Case PARTICIPATIONS_PARTICIPANT
					nSelector = "Participant"
				Case PARTICIPATIONS_COMPETITOR
					nSelector = "Competitor"
				Case PARTICIPATIONS_HELPER
					nSelector = "CompetitorHelper"
			End Select
		Else
			Select Case nParticipationType
				Case PARTICIPATIONS_PARTICIPANT
					nSelector = "Participant-Winner"
				Case PARTICIPATIONS_COMPETITOR
					nSelector = "Competitor-Winner"
				Case PARTICIPATIONS_COMPETITORHELPER
					nSelector = "CompetitorHelper-Winner"
			End Select
		End If
	End If		
		
	TMS_GetLotParticipantSelector = nSelector
End Function

'==============================================================================
' Проверяет, что у всех лотов тендера в качестве организации - участника лота
' от нас задана одна и та же организация
' [in] oPool			- объект пула
' [in] oXmlTender		- XML-элемент тендера
' [in/out] oXmlCompany	- XML-элемент организации - участника лота от нас
' [out]	-	True, если у всех лотов тендера в качестве организации - участника
'			лота от нас задана одна и та же организация или участники от нас
'			еще не определены. 
'		-	False в противном случае
' ЗАМЕЧАНИЕ. Если лоты для тендера не определены, то, следовательно, участники
' от нас тоже не определены. В этом случае функция вернет True
Function TMS_IsTenderParticipantOrganizationSingle(oPool, oXmlTender, ByRef oXmlCompany)
	Dim sTenderID				' идентификатор тендера
	Dim sXPath					' строка с XPath-запросом
	Dim oXmlOrganizationList	' список организаций от нас
	Dim oXmlOrganization		' текущая организация от нас
	Dim sCompanyID				' идентификатор организации от нас
	Dim bSingleCompany			' для всех лотов задан одна организация от нас
	
	bSingleCompany = True
	Set oXmlCompany = Nothing		
	
	sTenderID = oXmlTender.getAttribute("oid")
	
	' XPath, возвращающий ссылки на организации для всех участников от нас
	' по всем лотам тендера
	sXPath = "LotParticipant[@oid=//Lot[Tender/Tender/@oid='" & sTenderID & "']/LotParticipants/LotParticipant/@oid and ParticipationType=" & PARTICIPATIONS_PARTICIPANT & "]/ParticipantOrganization/Organization"
	
	Set oXmlOrganizationList = oPool.Xml.selectNodes(sXPath)
	
	If oXmlOrganizationList.length > 0 Then
		Set oXmlCompany = oPool.GetXmlObjectByXmlElement( oXmlOrganizationList.item(0), Empty )
		sCompanyID = oXmlCompany.getAttribute("oid")
		bSingleCompany = True
		For Each oXmlOrganization In oXmlOrganizationList
			If oXmlOrganization.getAttribute("oid") <> sCompanyID Then
				bSingleCompany = False
				Exit For
			End If
		Next
	End If
	
	TMS_IsTenderParticipantOrganizationSingle = bSingleCompany
End Function

'==============================================================================
' Обработчик видимости пунктов меню для объектных ссылок на Тендер в Incident Tracker
Sub TMS_TenderFolderPresentation_MenuVisibilityHandler(oSender, oEventArgs)
 	Dim oNode			' текущий menu-item
	Dim sType			' тип объекта в свойстве
	Dim sObjectID		' идентификатор объекта-значения
    ' получим тип и идентификатор объекта-значения
	sType = oEventArgs.Menu.Macros.Item("ObjectType")
	sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
	If 0=Len("" & sObjectID) Then sObjectID = Null
	For Each oNode In oEventArgs.ActiveMenuItems
		' Обработаем только известные нам операции
		Select Case oNode.getAttribute("action")
		    ' "Найти в дереве"
			Case "DoFindInTree","DoView"
				If IsNull(sObjectID) Then
					oNode.setAttribute "hidden", "1"
				Else
					oNode.removeAttribute "hidden"
				End If
		End Select
	Next
End Sub

'==============================================================================
' Обработчик выполнения пунктов меню для объектных ссылок на Тендер в Incident Tracker
Sub TMS_TenderFolderPresentation_MenuExecutionHandler(oSender, oEventArgs)
    Dim sObjectID
   	Select Case oEventArgs.Action
		' "Найти в дереве"
		Case "DoFindInTree"
			sObjectID = oEventArgs.Menu.Macros.Item("ObjectID")
			' На всякий случай проверку....
			If Len("" & sObjectID) > 0 Then
				window.Open XService.BaseUrl & "x-tree.aspx?METANAME=Main&LocateFolderByID=" & sObjectID
			End If	
		Case "DoView"
		    X_OpenReport oEventArgs.Menu.Macros.item("ReportURL")
	End Select		
End Sub