option explicit

dim g_oObjectEditor

dim g_oAnalysDirection
dim g_oPeriodType
dim g_oIntervalBegin
dim g_oIntervalEnd
dim g_oQuarter
dim g_oExpenceDetalization
dim g_oExpenseType

'==============================================================================
Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	set g_oObjectEditor = oSender
	set g_oAnalysDirection = oSender.CurrentPage.GetPropertyEditor(oSender.GetProp("AnalysDirection"))
	set g_oPeriodType = oSender.CurrentPage.GetPropertyEditor(oSender.GetProp("PeriodType"))
	set g_oIntervalBegin = oSender.CurrentPage.GetPropertyEditor(oSender.GetProp("IntervalBegin"))
	set g_oIntervalEnd = oSender.CurrentPage.GetPropertyEditor(oSender.GetProp("IntervalEnd"))
	set g_oQuarter = oSender.CurrentPage.GetPropertyEditor(oSender.GetProp("Quarter"))
	set g_oExpenceDetalization = oSender.CurrentPage.GetPropertyEditor(oSender.GetProp("ExepenseDetalization"))
	set g_oExpenseType = oSender.CurrentPage.GetPropertyEditor(oSender.GetProp("ExpenseType"))
	
	if g_oAnalysDirection.Value = 1 then
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oPeriodType, False
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oIntervalBegin, False
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oIntervalEnd, False
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oQuarter, False
		g_oExpenceDetalization.Value = 2
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oExpenceDetalization, False
		g_oExpenseType.Value = 0
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oExpenseType, False
	else
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oPeriodType, True
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oIntervalBegin, True
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oIntervalEnd, True
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oQuarter, True
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oExpenceDetalization, True
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oExpenseType, True
	end if
	
	InitPeriodSelector(oSender)
	
end sub

'==============================================================================
sub usr_FilterEmployeeExpensesList_AnalysDirection_OnChanged(oSender, oEventArgs)
	if g_oAnalysDirection.Value = 1 then
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oPeriodType, False
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oIntervalBegin, False
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oIntervalEnd, False
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oQuarter, False
		g_oExpenceDetalization.Value = 2
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oExpenceDetalization, False
		g_oExpenseType.Value = 0
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oExpenseType, False
	else
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oPeriodType, True
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oIntervalBegin, True
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oIntervalEnd, True
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oQuarter, True
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oExpenceDetalization, True
		g_oObjectEditor.CurrentPage.EnablePropertyEditor g_oExpenseType, True
	end if
end sub

'==============================================================================
Sub usrXReportFilter_OnOpenReport(oSender, oEventArgs)
	oEventArgs.ReportName = "EmployeeExpensesList"
End Sub


