'----------------------------------------------------------
'	Редактор/Мастер IncidentState
Option Explicit
'Обработка признака изменения начального состояния у инцидента
Sub usr_IncidentState_IsStartState_OnChanged (oSender, oEventArgs)
  
  Dim Pool              'Текущий пул объектов          
  Dim oXmlNewStartState 'Узел объекта типа IncidentState,который соответсвует редактируемому состоянию инц-та(это состояние хотим сделать начальным)
  Dim oXmlOldStartState 'Узел объекта типа IncidentState, который соответсвует начальному состоянию инц-та(которое установлено на данный момент)
  Dim oXmlTemp
  Dim sOldStartStateName 'Название старого начального состояния инц-та
  Dim sIncidentTypeName  'Название типа инцидента
  Dim sNewStartStateName 'Название нового начального состояния инц-та
  Dim sMessage
  
  Set Pool  = oSender.ObjectEditor.Pool
  Set oXmlOldStartState = Nothing
  Set oXmlNewStartState = oSender.ObjectEditor.XmlObject
  sNewStartStateName = oXmlNewStartState.SelectSingleNode("Name").Text
  sIncidentTypeName = Pool.GetPropertyValue(oXmlNewStartState, "IncidentType.Name")
  
  'Если снимаем признак начального состояния инц-та, то выходим из процедуры
  If oEventArgs.NewValue = False Then Exit Sub
  
  'Найдем xml-узел,который соответсвует начальному состоянию инц-та 
   For Each oXmlTemp In Pool.GetXmlObjectsByOPath(oXmlNewStartState, "IncidentType.States")
   If oXmlTemp.getAttribute("oid") <> oXmlNewStartState.getAttribute("oid") Then
		If oXmlTemp.selectSingleNode("IsStartState").text = 1 Then
		    Set  oXmlOldStartState = oXmlTemp
			Exit For
		End If	
   End If		
 Next	
 
 'Если не нашли старого начального состояния инц-та, то выходим
 If  oXmlOldStartState Is Nothing Then Exit Sub
 sOldStartStateName = oXmlOldStartState.SelectSingleNode("Name").Text
 
  sMessage = "Для типа инцидента """ & sIncidentTypeName & """ задано начальное состояние """ & sOldStartStateName & """ ." & vbNewLine & _
  "Установить новое начальное соcтояние """ & sNewStartStateName & """ ?"
  
  If Not confirm(sMessage) Then 
    'Оставляем старое начальное состояние инц-та 
    oSender.HtmlElement.Checked = False
    Pool.SetPropertyValue Pool.GetXmlProperty(oXmlNewStartState, "IsStartState"), False
    Pool.GetXmlProperty(oXmlNewStartState, "IsStartState").RemoveAttribute "dirty"
  Else
    'Снимаем признак IsStartState у старого начального состояния
    Pool.SetPropertyValue Pool.GetXmlProperty(oXmlOldStartState, "IsStartState"), False 
  End If
    
End Sub



