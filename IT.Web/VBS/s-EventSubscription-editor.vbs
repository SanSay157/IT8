Option Explicit

'==============================================================================
Sub usrXEditor_OnSetCaption(oSender, oEventArgs)
	Dim sCaption  
	Dim oItem
	Set oItem = oSender.XmlObject.SelectSingleNode("EventCreationRule/*")

	sCaption = ""
	sCaption = sCaption & "<DL style='color:#fff;font-size:10pt;'>"
	sCaption = sCaption & "<DT style='font-weight:bold'>Подписка на событие</DT>"
	sCaption = sCaption & "<DD>" & XService.HtmlEncodeLite(NameOf_EventClass(oSender.Pool.GetPropertyValue(oItem, "EventType"))) & "</DD>"
	sCaption = sCaption & "<DT style='font-weight:bold'>Правило генерации/доставки события</DT>"
	sCaption = sCaption & "<DD>" & XService.HtmlEncodeLite(oSender.Pool.GetPropertyValue(oItem, "Name")) & "</DD>"
	sCaption = sCaption & "</DL>"
	
	oEventArgs.EditorCaption = sCaption
End Sub
