Option Explicit

'==============================================================================
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	Dim sCustomerName

	sCustomerName = oSender.QueryString.GetValue("CustomerName", Empty)
	oSender.XmlObject.selectSingleNode("CustomerName").nodeTypedValue = sCustomerName
End Sub
