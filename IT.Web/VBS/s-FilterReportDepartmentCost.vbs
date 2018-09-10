Sub usrXEditor_OnPageStart(oSender, oEventArgs)
    SetControlsVisibility oSender
End Sub

Sub usr_FilterReportDepartmentCost_PeriodType_OnChanged(oSender, oEventArgs)
    SetControlsVisibility oSender.ObjectEditor
End Sub

Sub SetControlsVisibility(oObjectEditor)
    Dim nPeriodType
    Dim bShowIntervals
    Dim bShowQuarter
    
    With oObjectEditor
        nPeriodType = .Pool.GetPropertyValue(.XmlObject, "PeriodType")
        bShowIntervals = (PERIODTYPE_DATEINTERVAL = nPeriodType)
        bShowQuarter = (PERIODTYPE_SELECTEDQUARTER = nPeriodType)
        With .CurrentPage.GetPropertyEditor(.Pool.GetXmlProperty(.XmlObject, "IntervalBegin")).HtmlElement
            .style.visibility = iif(bShowIntervals, "visible", "hidden")
            .parentElement.parentElement.style.display = iif(bShowIntervals, "", "none")
        End With
        With .CurrentPage.GetPropertyEditor(.Pool.GetXmlProperty(.XmlObject, "IntervalEnd")).HtmlElement
            .style.visibility = iif(bShowIntervals, "visible", "hidden")
            .parentElement.parentElement.style.display = iif(bShowIntervals, "", "none")
        End With
        With .CurrentPage.GetPropertyEditor(.Pool.GetXmlProperty(.XmlObject, "Quarter")).HtmlElement
            .parentElement.parentElement.style.display = iif(bShowQuarter, "", "none")
        End With
    End With
End Sub