Option Explicit

Function it_FormatCurr(fSum)
    it_FormatCurr = iif(isCurrency(fSum), FormatCurrency(fSum, 2, false, false, true), "")
End Function

Function it_FormatBool(bVal)
    it_FormatBool = iif(bVal, "Да", "Нет")
End Function

Function it_FormatName(sLastName, sFirstName, sPhoneExt)
    it_FormatName = sLastName & " " & sFirstName & iif( hasValue(sPhoneExt), " (#" & sPhoneExt & ")", "" )
End Function