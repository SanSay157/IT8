Option Explicit

'==============================================================================
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	'Dim uidSelectedTender	' идентификатор выбранного тендера
	'Dim oResp				' ответ от сервера
	'Dim xmlCompany, xmlOrganization
	
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
