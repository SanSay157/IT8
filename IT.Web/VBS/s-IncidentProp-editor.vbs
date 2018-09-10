'----------------------------------------------------------
'	Редактор/Мастер IncidentProp
Option Explicit

Sub usrXEditor_OnValidatePage(Sender, EventArgs )
	Dim nType			' Тип свойства
	Dim vMin			' Минимум
	Dim vMax			' Максимум
	Dim vDef			' По умолчанию
	Dim oIncidentProp	' Свойство инцидента
	Dim sPropName		' Наименование свойства
	
	
	' Проверим уникальность имени
	If 2>CLng(Sender.CurrentPageNo) Then
		' Проитерируем все свойства инцидента кроме текущего
		With Sender.Pool
			For Each oIncidentProp In .GetXmlProperty(Sender.XmlObject, "IncidentType.Props").SelectNodes("*[@oid!='" & Sender.ObjectID & "']")
				If 0 = StrComp( Sender.XmlObject.SelectSingleNode("Name").nodeTypedValue , .GetPropertyValue(oIncidentProp, "Name"), vbTextCompare) Then
					' Встретили дубль
					EventArgs.ReturnValue = False
					EventArgs.ErrorMessage = "У данного типа инцидента уже есть доп. свойство с наименованием '" & Sender.XmlObject.SelectSingleNode("Name").nodeTypedValue & "'!"
					Exit Sub
				End If
			Next 
		End With	
	ElseIf Sender.IsObjectCreationMode and (2=Sender.CurrentPageNo) Then
		nType = Sender.XmlObject.SelectSingleNode("Type").nodeTypedValue
		Select Case nType
			Case IPROP_TYPE_IPROP_TYPE_LONG, IPROP_TYPE_IPROP_TYPE_DOUBLE :
				vMin = Sender.XmlObject.SelectSingleNode("MinDouble").nodeTypedValue
				vMax = Sender.XmlObject.SelectSingleNode("MaxDouble").nodeTypedValue
				vDef = Sender.XmlObject.SelectSingleNode("DefDouble").nodeTypedValue
			Case IPROP_TYPE_IPROP_TYPE_DATE ,IPROP_TYPE_IPROP_TYPE_TIME, IPROP_TYPE_IPROP_TYPE_DATEANDTIME :
				vMin = Sender.XmlObject.SelectSingleNode("MinDate").nodeTypedValue
				vMax = Sender.XmlObject.SelectSingleNode("MaxDate").nodeTypedValue
				vDef = Sender.XmlObject.SelectSingleNode("DefDate").nodeTypedValue
			Case IPROP_TYPE_IPROP_TYPE_STRING, IPROP_TYPE_IPROP_TYPE_TEXT :
				vMin = Sender.XmlObject.SelectSingleNode("MinDouble").nodeTypedValue
				vMax = Sender.XmlObject.SelectSingleNode("MaxDouble").nodeTypedValue
				vDef = Sender.XmlObject.SelectSingleNode("DefText").nodeTypedValue
				If HasValue(vDef) Then vDef=Len(vDef)
		End Select
		If HasValue(vMin) and HasValue(vMax) Then
			If vMin > vMax Then
				EventArgs.ReturnValue = False
				EventArgs.ErrorMessage = "Заданное минимальное значение превышает заданное максимальное значение!"
				Exit Sub
			End If
		End If
		If HasValue(vMin) and HasValue(vDef) Then
			If vMin > vDef Then
				EventArgs.ReturnValue = False
				EventArgs.ErrorMessage = "Заданное значение по умолчанию меньше заданного минимального значения!"
				Exit Sub
			End If
		End If
		If HasValue(vMax) and HasValue(vDef) Then
			If vMax < vDef Then
				EventArgs.ReturnValue = False
				EventArgs.ErrorMessage = "Заданное значение по умолчанию больше заданного максимального значения!"
				Exit Sub
			End If
		End If
	End if
End Sub

'Обработчик события изменения типа свойства (Type) в комбобоксе редактора объекта типа IncidentProp (свойство инц-та)
Sub usr_IncidentProp_Type_SelectorCombo_OnChanged(oSender, oEventArgs)
  Dim oXmlObject 'xml-представление объекта IncidentProp
    Set oXmlObject = oSender.ObjectEditor.XmlObject
    'Очищаем значения полей объекта IncidentProp,которые могли быть установлены на предыдущем шаге,
    'так как выбран другой тип свойства инц-та,а значит и поля, которые можно заполнять,могли измениться.
    'Также снимаем атрибут dirty у полей объекта IncidentProp.
     
    oXmlObject.SelectSingleNode("MaxDouble").Text=""
    oXmlObject.SelectSingleNode("MaxDouble").RemoveAttribute "dirty"
    oXmlObject.SelectSingleNode("MinDouble").Text=""
    oXmlObject.SelectSingleNode("MinDouble").RemoveAttribute "dirty"
    oXmlObject.SelectSingleNode("DefDouble").Text=""
    oXmlObject.SelectSingleNode("DefDouble").RemoveAttribute "dirty"

    oXmlObject.SelectSingleNode("MaxDate").Text=""
    oXmlObject.SelectSingleNode("MaxDate").RemoveAttribute "dirty"
    oXmlObject.SelectSingleNode("MinDate").Text=""
    oXmlObject.SelectSingleNode("MinDate").RemoveAttribute "dirty"
    oXmlObject.SelectSingleNode("DefDate").Text=""
    oXmlObject.SelectSingleNode("DefDate").RemoveAttribute "dirty"
    oXmlObject.SelectSingleNode("DefText").Text=""
    oXmlObject.SelectSingleNode("DefText").RemoveAttribute "dirty"
End Sub
