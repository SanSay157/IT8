Option Explicit

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	enableSortOrder oSender
	enableCompetitorType oSender

	' Инициализируем обработку свойств, связанных с периодом времени
	InitPeriodSelector oSender
End Sub

'==============================================================================
Sub usr_ReportTenders_SortType_SelectorCombo_OnChanged(oSender, oEventArgs)
	enableSortOrder oSender.ObjectEditor
End Sub

'==============================================================================
Sub usr_ReportTenders_ParticipantOrganization_OnAfterSelect(oSender, oEventArgs)
	enableCompetitorType oSender.ObjectEditor
End Sub
'==============================================================================
Sub usr_ReportTenders_ParticipantOrganization_OnAfterUnlink(oSender, oEventArgs)
    Dim oCompetitorTypeEditor
    Set oCompetitorTypeEditor = TMS_GetPropertyEditor(oSender.ObjectEditor, Nothing, "CompetitorType")
    oCompetitorTypeEditor.Clear()
	enableCompetitorType oSender.ObjectEditor
End Sub

'==============================================================================


Sub enableSortOrder(oObjectEditor)
	Dim oSortTypeEditor
	Dim oSortOrderEditor

	Set oSortTypeEditor = TMS_GetPropertyEditor(oObjectEditor, Nothing, "SortType")
	Set oSortOrderEditor = TMS_GetPropertyEditor(oObjectEditor, Nothing, "SortOrder")
	
	TMS_EnablePropertyEditor _
		oSortOrderEditor, _
		(oSortTypeEditor.Value <> LOTSANDPARTICIPANTSSORTTYPE_RANDOM)
End Sub

'==============================================================================
Sub enableCompetitorType(oObjectEditor)
	Dim oCompetitorTypeEditor
	Dim oParticipantOrganizationEditor

	Set oCompetitorTypeEditor = TMS_GetPropertyEditor(oObjectEditor, Nothing, "CompetitorType")
	Set oParticipantOrganizationEditor = TMS_GetPropertyEditor(oObjectEditor, Nothing, "ParticipantOrganization")

	TMS_EnablePropertyEditor _
		oCompetitorTypeEditor, _
		(not (oParticipantOrganizationEditor.Value Is Nothing))
End Sub
