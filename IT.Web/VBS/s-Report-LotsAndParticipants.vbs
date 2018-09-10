Option Explicit

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	enableExcludeOtherParticipants oSender
	enableSortOrder oSender
	
	' Инициализируем обработку свойств, связанных с периодом времени
	InitPeriodSelector oSender
End Sub

'==============================================================================
Sub usr_ReportLotsAndParticipants_ParticipantOrganization_ObjectPresentation_OnAfterSelect(oSender, oEventArgs)
	enableExcludeOtherParticipants oSender.ObjectEditor
End Sub

'==============================================================================
Sub usr_ReportLotsAndParticipants_ParticipantOrganization_ObjectPresentation_OnAfterUnlink(oSender, oEventArgs)
	enableExcludeOtherParticipants oSender.ObjectEditor
End Sub

'==============================================================================
Sub usr_ReportLotsAndParticipants_SortType_SelectorCombo_OnChanged(oSender, oEventArgs)
	enableSortOrder oSender.ObjectEditor
End Sub

'==============================================================================
Sub enableExcludeOtherParticipants(oObjectEditor)
	Dim oParticipantOrganizationEditor
	Dim oExcludeOtherParticipantsEditor
	Dim bParticipantOrganizationSelected
	
	Set oParticipantOrganizationEditor = TMS_GetPropertyEditor(oObjectEditor, Nothing, "ParticipantOrganization")
	Set oExcludeOtherParticipantsEditor = TMS_GetPropertyEditor(oObjectEditor, Nothing, "ExcludeOtherParticipants")
	
	bParticipantOrganizationSelected = (Not oParticipantOrganizationEditor.Value Is Nothing)
	
	TMS_EnablePropertyEditor _
		oExcludeOtherParticipantsEditor, _
		bParticipantOrganizationSelected
		
	If Not bParticipantOrganizationSelected Then
		oExcludeOtherParticipantsEditor.Value = False
	End If
End Sub

'==============================================================================
Sub enableSortOrder(oObjectEditor)
	Dim oSortTypeEditor
	Dim oSortOrderEditor

	Set oSortTypeEditor = TMS_GetPropertyEditor(oObjectEditor, Nothing, "SortType")
	Set oSortOrderEditor = TMS_GetPropertyEditor(oObjectEditor, Nothing, "SortOrder")
	
	TMS_EnablePropertyEditor _
		oSortOrderEditor, _
		(oSortTypeEditor.Value <> TENDERSORTTYPE_RANDOM)
End Sub
