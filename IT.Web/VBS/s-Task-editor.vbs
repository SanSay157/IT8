Option Explicit

Dim g_oPool					' XObjectPool (инициализируется в OnLoad и более не изменяется)
Dim g_oObjectEditor			' ObjectEditor (инициализируется в OnLoad и более не изменяется)
Dim g_IncidentTypeID		' идентификатор типа инцидента, по которому создается/создано данное задание (инициализируется в OnLoad и более не изменяется)
Dim g_FolderID				' идентификатор папки, в которой находится инцидент (инициализируется в OnLoad и более не изменяется)

'==============================================================================
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	With oSender
		Set g_oPool = .Pool
		Set g_oObjectEditor = oSender
		g_IncidentTypeID = .Pool.GetXmlProperty(.XmlObject, "Incident.Type").firstChild.GetAttribute("oid")
		g_FolderID = .Pool.GetPropertyValue(.XmlObject, "Incident.Folder.ObjectID")
	End With
End Sub


'==============================================================================
' Выбор роли участника
Sub usr_Task_Role_OnGetRestrictions(oSender, oEventArgs)
	oEventArgs.ReturnValue = "IncidentType=" & g_IncidentTypeID
End Sub


'==============================================================================
' Обработчик изменения роли пользователя
' При создании Задания автоматически подставляем запланированное время
Sub usr_Task_Role_OnChanged(oSender, oEventArgs)
	Dim oXmlProp	' xml-свойство
	Dim oPE			' Редактор свойства "Запланированное время"
	Dim vValue		' значение длительности задания по умолчанию для роли
	
	If g_oObjectEditor.IsObjectCreationMode Then
		' при изменении роли, изменим запланированное время
		' Считаем, что если есть права на изменение роли, значит и есть права на изменение запл. времени - привилегия "Управление участниками инцидента"
		vValue = g_oObjectEditor.Pool.GetPropertyValue( g_oObjectEditor.XmlObject, "Role.DefDuration" )
		If hasValue(vValue) Then
			Set oXmlProp = g_oObjectEditor.XmlObject.selectSingleNode("PlannedTime")
			Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor( oXmlProp )
			oPE.Value = vValue
		End If
	End If
End Sub


'==============================================================================
' Возвращает признак необходимости отображения и обработки врeменных параметров Задания:
' Запланированное время, Оставшееся время. 
' Вычисляется на основании признака подотчетности папки, в которой находится инцидент заднного задания, и
' признак подотчетности отдела, в котором числиться текущий исполнитель
Function IsTimeReporting()
	' Учтем, что при создании Задания, исполнитель может быть еще не задан
	
	' TODO
	IsTimeReporting = True
End Function


'==============================================================================
' Возвращает запланированное время
Function GetPlannedTimeString()
	GetPlannedTimeString = FormatTimeString ( g_oPool.GetPropertyValue(g_oObjectEditor.XmlObject, "PlannedTime") )
End Function 

'==============================================================================
' Возвращает оставшееся время
Function GetTimeLeftString()
	GetTimeLeftString = FormatTimeString( g_oPool.GetPropertyValue(g_oObjectEditor.XmlObject, "LeftTime") )
End Function 

'==============================================================================
' Возвращает затраченное время
Function GetSpentTimeString()
	GetSpentTimeString = FormatTimeString ( getTaskTimeSpent(g_oPool, g_oObjectEditor.XmlObject) )
End Function 


'==============================================================================
' Обработчик изменения запланированного времени
Sub usr_Task_PlannedTime_TimeEditButton_OnChanged(oSender, oEventArgs)
	Dim oXmlPropLeftTime
	Dim nSpentTime
	Dim nLeftTime
	Dim oPE

	' при изменении запланированного времени изменим и оставшееся время
	Set oXmlPropLeftTime = g_oObjectEditor.XmlObject.selectSingleNode("LeftTime")
	' оставшееся время установим как разница запланированного и затраченного
	nSpentTime = getTaskTimeSpent(g_oPool, g_oObjectEditor.XmlObject)
	nLeftTime  = CLng(oEventArgs.NewValue) - nSpentTime
	If nLeftTime < 0 Then
		nLeftTime = 0
	End If
	g_oObjectEditor.Pool.SetPropertyValue oXmlPropLeftTime, nLeftTime
	' При создании Задания редактор свойства "Оставшееся время" не отображается, поэтому просто установим свойство
	If Not g_oObjectEditor.IsObjectCreationMode Then
		Set oPE = g_oObjectEditor.CurrentPage.GetPropertyEditor(oXmlPropLeftTime)
		oPE.SetData
	End If
End Sub

