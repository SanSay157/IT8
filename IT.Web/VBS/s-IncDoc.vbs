Option Explicit

Sub usrXEditor_OnPageEnd(oSender, oEventArgs)
    oSender.Pool.GetXmlProperty(oSender.XmlObject, "Incomes").RemoveAttribute "dirty"
End Sub