dim g_oDKP_ClientPE
dim g_oDKP_ProjectPE

Sub usrXEditor_OnPageStart(oSender, oEventArgs)
	set g_oDKP_ClientPE = oSender.CurrentPage.GetPropertyEditor( oSender.GetProp("DKP_Client") )
	set g_oDKP_ProjectPE = oSender.CurrentPage.GetPropertyEditor( oSender.GetProp("DKP_Project") )
	InitPeriodSelector(oSender)
end sub

sub DKPSelectButton_OnClick
	dim guidClient
	dim guidProject
	dim oSelection
	set oSelection = X_SelectFromTree("FolderSelector", "", "", "", Nothing)
	
	if oSelection.ReturnValue then
	
		if oSelection.Selection.SelectSingleNode("n").getAttribute("ot") = "Organization" then
			guidClient = oSelection.Selection.SelectSingleNode("n").NodeTypedValue
			guidProject = ""
		else guidProject = ""
			guidProject = oSelection.Selection.SelectSingleNode("n").NodeTypedValue
		end if
		
		DKP.Value = oSelection.Selection.SelectSingleNode("n").GetAttribute("t")
		g_oDKP_ClientPE.ValueID = guidClient
		g_oDKP_ProjectPE.ValueID = guidProject
		
	end if
	
end sub

