Option Explicit

'==============================================================================
' Возвращает XML-элемент, соответствующий объекту "Тендер"
Function XmlTender()
	Set XmlTender = ObjectEditor.XmlObject
	
End Function

'==============================================================================
' Возвращает XML-элемент, соответствующий единственному лоту тендера
Function XmlLot()
	Set XmlLot = Pool.GetXmlObjectByOPath(XmlTender, "Lots")
End Function

'==============================================================================
' Возвращает XML-элемент, соответствующий участнику лота от нас
Function XmlLotParticipantOwn()
	Set XmlLotParticipantOwn = GetLotParticipantOwn(XmlLot)
End Function

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Dim oXmlTenderLotsProp	' XML-элемент, соответствующий свойству "Лоты"
	Dim oXmlTender			' XML-элемент тендера
	Dim oXmlLot				' XML-элемент лота

	' инициализируем глобальные переменные
	InitGlobals oSender

	Set oXmlTender = XmlTender()
	
	' привязываем лот
	Set oXmlTenderLotsProp = Pool.GetXmlProperty(oXmlTender, "Lots")
	If oXmlTenderLotsProp.firstChild Is Nothing Then
		Set oXmlLot = Pool.CreateXmlObjectInPool("Lot")
		Pool.AddRelation oXmlTender, oXmlTenderLotsProp, oXmlLot
	End If
	
	' инициализируем участники лота от нас
	CreateLotParticipantOwn XmlLot

	' добавляем кнопку "Калькулятор дат"
	TMS_CreateDataCalcButton()
	
	' устанавливаем признаки инициализации страниц
	bLotMainPageInited = False
	bTenderMainPageInited = False
End Sub

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	Select Case oSender.CurrentPage.PageTitle
		Case "Основные реквизиты"
			LotEditor_InitMainPage XmlLot
			TenderEditor_InitMainPage XmlTender

		Case "Результаты"
			LotEditor_InitResultsPage XmlLot
	End Select
End Sub

'==============================================================================
Sub usrXEditor_OnPageEnd(oSender, oEventArgs)
	' XML-элемент, соответствующий объекту "Сумма"
	Dim oXmlSum1, oXmlSum2
	' XML-элемент, соответствующий свойству "Сумма предложения конкурента"
	Dim oXmlTenderParticipantPriceProp
	Dim oXmlTemp
	Dim oXmlTender				' XML-элемент тендера
	Dim oXmlLot					' XML-элемент лота
	Dim oXmlLotParticipantOwn	' XML-элемент участника лота от нас

	' кэшируем объекты
	Set oXmlTender = XmlTender()
	Set oXmlLot = XmlLot()
	Set oXmlLotParticipantOwn = XmlLotParticipantOwn()
	
	If oSender.CurrentPage.PageTitle = "Основные реквизиты" Then
		' прописываем свойство "Название" для лота
		Pool.SetPropertyValue _
			Pool.GetXmlProperty(oXmlLot, "Name"), _
			Pool.GetPropertyValue(oXmlTender, "Name")
		
		' прописываем свойство "Номер" для лота
		Pool.SetPropertyValue _
			Pool.GetXmlProperty(oXmlLot, "Number"), _
			Pool.GetPropertyValue(oXmlTender, "Number")
	End If
End Sub

'==============================================================================
Sub usr_Lot_LotParticipants_ObjectsElementsList_OnBeforeEdit( oSender, oEventArgs )
	' сообщаем, что редактор вызывается из однолотового тендера
	oEventArgs.UrlArguments = "SingleLot=1"
End Sub

'==============================================================================
Sub usr_Lot_LotParticipants_ObjectsElementsList_OnBeforeCreate( oSender, oEventArgs )
	' сообщаем, что редактор вызывается из однолотового тендера
	oEventArgs.UrlArguments = "SingleLot=1"
End Sub

'==============================================================================
' Обработчик изменения селектора "Победитель"
Sub OnWinnerSelectorChanged()
	LotEditor_OnWinnerSelectorChanged XmlLot
End Sub