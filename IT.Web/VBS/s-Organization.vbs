Option Explicit

'==============================================================================
Sub usr_Director_OnGetRestrictions(oSender, oEventArgs)
	oEventArgs.ReturnValue = _
		"Department=" & _
		oSender.ObjectEditor.GetPropertyValue( oSender.ObjectEditor.XmlObject, "Department.ObjectID" )
End Sub
