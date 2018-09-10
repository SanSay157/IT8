Option Explicit

Dim g_bIsHomeOrganization		' As Boolean - признак того, что Отдел принадлежит "родной" организации
Dim g_bEmployeeRateIsZero       ' As Boolean - признак того, что "Норма рабочего дня" была обнулена

g_bEmployeeRateIsZero = False
'==============================================================================
'	[in] oSender As ObjectEditor
'	[in] oEventArgs As Nothing
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Dim oSysUser	' IXMLDOMElement - xml-объект Пользователь (SystemUser)
	
	g_bIsHomeOrganization = CBool( oSender.QueryString.GetValueInt("IsHomeOrg", 0) )
	On Error Resume Next
	If oSender.IsObjectCreationMode Then
		Set oSysUser = oSender.Pool.CreateXmlObjectInPool("SystemUser")
		oSender.Pool.AddRelation oSender.XmlObject, "SystemUser", oSysUser
	End If
End Sub


'==============================================================================
Function IsForeignOrganization
	IsForeignOrganization = Not g_bIsHomeOrganization
End Function


'==============================================================================
Function IsHomeOrganization
	IsHomeOrganization = g_bIsHomeOrganization
End Function


'==============================================================================
' Выбор Oтдела
Sub usr_Employee_Department_OnGetRestrictions(oSender, oEventArgs)
	Dim oPE
	Dim oOrganization
	' накладываем ограничение на выбираемый отдел - он должен относится к текущей Организации
	Set oPE = oSender.ParentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("Organization") )
	Set oOrganization = oPE.Value
	If Not oOrganization Is Nothing Then
		oEventArgs.ReturnValue = "OrganizationID=" & oOrganization.getAttribute("oid")
	End If
End Sub


'==============================================================================
' Перед созданием Oтдела
Sub usr_Employee_Department_OnBeforeCreate(oSender, oEventArgs)
	Dim oPE
	Dim oOrganization
	' накладываем ограничение на выбираемый отдел - он должен относится к текущей Организации
	Set oPE = oSender.ParentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("Organization") )
	Set oOrganization = oPE.Value
	If oOrganization Is Nothing Then Err.Raise -1, "usr_Employee_Department_OnBeforeCreate", "Организация должна быть всегда задана"
	' инициализируем ссылку на Организацию создаваемого отдела и задизейблим ее
	oEventArgs.UrlArguments = ".Organization=" & oOrganization.getAttribute("oid") & "&@Organization=disabled:1"
End Sub


'==============================================================================
'	Перед выбором Организации запомним текущее значение
'	[in] oEventArgs AS SelectEventArgsClass
Sub usr_Employee_Organization_OnBeforeSelect(oSender, oEventArgs)
	' Запомним предыдущее значение
	oEventArgs.OperationValues.item("_OLDVALUE") = "" & oSender.ParentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("Department") ).ValueID
End Sub


'==============================================================================
'	После выбора Организации сбросим значение свойства "Отдел"
'	[in] oEventArgs AS SelectEventArgsClass
Sub usr_Employee_Organization_OnAfterSelect(oSender, oEventArgs)
	Dim oPE
	' если выбранное значение (Selection всегда не пуст) отличается от предыдущего, то очистим свойство Отдел 
	If oEventArgs.OperationValues.item("_OLDVALUE") <> oEventArgs.Selection Then
		Set oPE = oSender.ParentPage.GetPropertyEditor( oSender.ObjectEditor.XmlObject.selectSingleNode("Department") )
		oPE.ValueID = Null
	End If
End Sub
