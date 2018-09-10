Option Explicit

'==============================================================================
Dim bTenderMainPageInited	' Страница "Основные реквизиты"	проинициализирована

'==============================================================================
' Инициализирует редакторы свойств на главной странице
' [in] oXmlTender - XML-элемент тендера
Sub TenderEditor_InitMainPage( oXmlTender )
	Dim oCustomerEditor
	Dim oOrganizerEditor
	
	' если страница еще не проинициализирована
	If Not bTenderMainPageInited Then

		' Инициалиазируем обработку операции "Замена временного описания организации постоянным"
		Set oCustomerEditor = TMS_GetPropertyEditor( ObjectEditor, oXmlTender, "TenderCustomer" )
		Set oOrganizerEditor = TMS_GetPropertyEditor( ObjectEditor, oXmlTender, "Organizer" )
		oCustomerEditor.EventEngine.AddHandlerForEvent "BeforeChangeTempOrgOnConst", Nothing, "OnBeforeChangeTempOrgOnConst"
		oCustomerEditor.EventEngine.AddHandlerForEvent "AfterChangeTempOrgOnConst", Nothing, "TenderCustomer_OnAfterChangeTempOrgOnConst"
		oOrganizerEditor.EventEngine.AddHandlerForEvent "BeforeChangeTempOrgOnConst", Nothing, "OnBeforeChangeTempOrgOnConst"
		oOrganizerEditor.EventEngine.AddHandlerForEvent "AfterChangeTempOrgOnConst", Nothing, "Organizer_OnAfterChangeTempOrgOnConst"
		
		bTenderMainPageInited = True
	End If
End Sub

'==============================================================================
Sub OnBeforeChangeTempOrgOnConst(oSender, oMenuEventArgs)
	oMenuEventArgs.Menu.Macros.Item("TenderID") = oSender.ObjectEditor.XmlObject.getAttribute("oid")
End Sub

'==============================================================================
Sub TenderCustomer_OnAfterChangeTempOrgOnConst(oSender, oMenuEventArgs)
	OnAfterChangeTempOrgOnConst oSender, oMenuEventArgs, "Organizer"
End Sub

'==============================================================================
Sub Organizer_OnAfterChangeTempOrgOnConst(oSender, oMenuEventArgs)
	OnAfterChangeTempOrgOnConst oSender, oMenuEventArgs, "TenderCustomer"
End Sub

'==============================================================================
Sub OnAfterChangeTempOrgOnConst(oSender, oMenuEventArgs, sPropName)
	Dim oChangingObject
	Dim oPropEditor
	
	Set oPropEditor = TMS_GetPropertyEditor(ObjectEditor, Nothing, sPropName)
	If oPropEditor.Value Is Nothing Then _
		Exit Sub

	Set oChangingObject = Pool.GetXmlObject( _
		oMenuEventArgs.Menu.Macros.Item("ObjectType"), _
		oMenuEventArgs.Menu.Macros.Item("ObjectID"), _	
		Null)
	
	' если у редактора было такое же значение, измением его
	If oPropEditor.Value.getAttribute("oid") = oChangingObject.getAttribute("oid") Then
		Set oPropEditor.Value = oSender.Value
	End If
End Sub

'==============================================================================
Sub usr_Tender_TenderCustomer_ObjectPresentation_OnAfterSelect(oSender, oEventArgs)
	setDirectorByCustomer
End Sub

'==============================================================================
Sub usr_Tender_TenderCustomer_ObjectPresentation_OnAfterCreate(oSender, oEventArgs)
	setDirectorByCustomer
End Sub

'==============================================================================
Sub usr_Tender_TenderCustomer_ObjectPresentation_OnAfterEdit(oSender, oEventArgs)
	setDirectorByCustomer
End Sub

'==============================================================================
' Выставляет сотрудника, являющегося директором организации-заказчика,
' в качестве директора клиента данного тендера
Sub setDirectorByCustomer()
	Dim xmlCustomerDirector
	Dim oDirectorEditor
	
	Set xmlCustomerDirector = Pool.GetXmlObjectByOPath(ObjectEditor.XmlObject, "TenderCustomer.Director")
	If Not xmlCustomerDirector Is Nothing Then
		Set oDirectorEditor = TMS_GetPropertyEditor(ObjectEditor, Nothing, "Director")
		If oDirectorEditor.Value Is Nothing Then
			Set oDirectorEditor.Value = xmlCustomerDirector
		End If
	End If
End Sub

