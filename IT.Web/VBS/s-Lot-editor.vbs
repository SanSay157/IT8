Option Explicit

'==============================================================================
' ¬озвращает XML-элемент, соответствующий объекту "Ћот"
Function XmlLot()
	Set XmlLot = ObjectEditor.XmlObject
End Function

'==============================================================================
' ¬озвращает XML-элемент, соответствующий тендеру лота
Function XmlTender()
	Set XmlTender = Pool.GetXmlObjectByOPath(XmlLot, "Tender")
End Function

'==============================================================================
' ¬озвращает XML-элемент, соответствующий участнику лота от нас
Function XmlLotParticipantOwn()
	Set XmlLotParticipantOwn = GetLotParticipantOwn(XmlLot)
End Function

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	' инициализируем глобальные переменные
	InitGlobals oSender

	' инициализируем участники лота от нас
	CreateLotParticipantOwn(XmlLot)
	
	' прив€зываем организацию от нас
	If Pool.GetXmlProperty(XmlLotParticipantOwn, "ParticipantOrganization").firstChild Is Nothing Then
		SetCompany()
	End If
	
	' добавл€ем кнопку " алькул€тор дат"
	TMS_CreateDataCalcButton()
	
	' устанавливаем признаки инициализации страниц
	bLotMainPageInited = False
End Sub

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	Select Case oSender.CurrentPage.PageTitle
		Case "ќсновные характеристики"
			LotEditor_InitMainPage XmlLot
		Case "–езультаты"
			LotEditor_InitResultsPage XmlLot
	End Select
End Sub

'==============================================================================
' ѕроставл€ет организацию дл€ участника лота от нас
Sub SetCompany()
	Dim oXmlCompany				' организаци€ от нас
	Dim bSingleCompany			' дл€ всех лотов задан одна организаци€ от нас
	Dim sTenderCompanyID		' идентификатор компании, передаваемый из редактора тендера
	
	bSingleCompany = TMS_IsTenderParticipantOrganizationSingle(Pool, XmlTender, oXmlCompany) 
	' если дл€ лотов задана одна и та же организаци€ от нас, то
	' проставим ее и дл€ участника от нас в текущем лоте
	If bSingleCompany Then
		' если организации от нас еще не определена, попробуем получить
		' ее из параметров URL
		If oXmlCompany Is Nothing Then
			sTenderCompanyID = ObjectEditor.QueryString.GetValue("TenderCompanyID", Null)
			' если из редактора тендера передан идентификатор компании,
			' подгрузим XML-объект этой организации из пула
			If hasValue(sTenderCompanyID) Then
				Set oXmlCompany = Pool.GetXmlObject("Organization", sTenderCompanyID, Empty)
			End If			
		End If

		' если в итоге удалось получить организацию от нас, то проставим ее
		If Not oXmlCompany Is Nothing Then
			Pool.AddRelation XmlLotParticipantOwn, "ParticipantOrganization", oXmlCompany
		End If
	End If
End Sub

'==============================================================================
' ќбработчик изменени€ селектора "ѕобедитель"
Sub OnWinnerSelectorChanged()
	LotEditor_OnWinnerSelectorChanged XmlLot
End Sub