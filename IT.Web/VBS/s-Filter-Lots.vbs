Option Explicit

'==============================================================================
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	Dim uidSelectedTender	' идентификатор выбранного тендера
	Dim oResp				' ответ от сервера
	Dim xmlCompany, xmlOrganization
	
	' получаем выбранный тендер (если таковой есть)
	'uidSelectedTender = GetSelectedTender()

	' получаем данные с сервера
	'With New GetFilterTendersInfoRequest
	'	.m_sName = "GetFilterTendersInfo"
	'	.m_sSelectedTenderID = uidSelectedTender
	'	Set oResp = X_ExecuteCommand( .Self )
	'End With

	' устанавливаем интервал подачи документов
	'If uidSelectedTender = GUID_EMPTY Or IsEmpty(oResp.m_dtDocFeedingDate) Then
	'	oSender.XmlObject.selectSingleNode("DocFeedingBegin").nodeTypedValue = DateAdd("m", -1, Date())
	'	oSender.XmlObject.selectSingleNode("DocFeedingEnd").nodeTypedValue = ""
	'Else
	'	oSender.XmlObject.selectSingleNode("DocFeedingBegin").nodeTypedValue = DateAdd("m", -1, oResp.m_dtDocFeedingDate)
	'	oSender.XmlObject.selectSingleNode("DocFeedingEnd").nodeTypedValue = DateAdd("m", 1, oResp.m_dtDocFeedingDate)
	'End If
End Sub

'==============================================================================
' Обработчик события начала отображения страницы
' oEventArgs - экземпляр EditorStateChangedEventArgsClass
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	With oSender
		If .CurrentPage.PageName <> "PAGE_1" Then Exit Sub
		' Коррекция стиля для подписи к флагу "Учитывать при определении состояния" (IsStrictStateCalc):
		.CurrentPage.GetPropertyEditor( .GetProp("IsStrictStateCalc") ).HtmlElement.parentElement.all.tags("LABEL").item(0).style.fontWeight = "bold"
		' Принудительный вызов кода обработчика
		OnChange_OwnCompany oSender, .CurrentPage.GetPropertyEditor( .GetProp("Company") ).ValueID 
	End With
End Sub

'==============================================================================
' Обработчик события изменения значения поля "Компания"
'	oEventArgs - экземпляр ChangeEventArgsClass
Sub usr_Company_ObjectDropDown_OnChanged( oSender, oEventArgs )
	OnChange_OwnCompany oSender.ObjectEditor, oEventArgs.NewValue
End Sub

Sub OnChange_OwnCompany( oObjectEditor, vValue )
	Dim bStrictOwnCompany	' Признак указания конкретной организации
	bStrictOwnCompany = hasValue(vValue)
	With oObjectEditor
		With .CurrentPage.GetPropertyEditor( .GetProp("IsStrictStateCalc") )
			If Not bStrictOwnCompany Then .Value = False
			.Enabled = bStrictOwnCompany
		End With
	End With
End Sub

'==============================================================================
' Возвращает идентификатор тендера, передаваемый через URL с помощью 
' параметра SelectedTender (или GUID_EMPTY если такого параметра нет)
Function GetSelectedTender()
	Dim sUrlParams			' строка параметров, передаваемых через URL
	Dim oRegExp, aMatches	' объекты для работы с регулярными выражениями

	sUrlParams = window.parent.location.search
	
	Set oRegExp = New RegExp
	oRegExp.Pattern = "SelectedTender=(([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})|([0-9a-fA-F]{32}))"
	oRegExp.IgnoreCase = True
	
	Set aMatches = oRegExp.Execute(sUrlParams)
	
	If aMatches.count = 0 Then
		GetSelectedTender = GUID_EMPTY
	Else
		GetSelectedTender = aMatches(0).SubMatches(0)
	End If
End Function
