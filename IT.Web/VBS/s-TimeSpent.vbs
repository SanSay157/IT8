Option Explicit

Dim g_nSpentInitial			' Ќачальное значение количества затраченного времени

'==========================================================================
Sub usrXEditor_OnLoad( oSender, oEventArgs )
	g_nSpentInitial = SafeCLng( oSender.XmlObject.selectSingleNode("Spent").nodeTypedValue )
End Sub


'==========================================================================
Sub usrXEditor_OnValidate(oSender, oEventArgs)
	Dim oProp
	Dim nLeftTime
	Dim nSpentDelta

	' если нас запустили как корневой редактор, 
	' то скорректируем самосто€тельно значение свойства TimeLeft объекта «адание (Task), к которому относитс€ данное списание.
	' »наче это выполн€етс€ в редакторе «адани€.
	If Not oSender.IsIncluded Then
		nSpentDelta = oSender.XmlObject.selectSingleNode("Spent").nodeTypedValue - g_nSpentInitial
		Set oProp = oSender.Pool.GetXmlProperty(oSender.XmlObject, "Task.LeftTime")
		nLeftTime = oProp.nodeTypedValue
		If nLeftTime > nSpentDelta Then
			nLeftTime = nLeftTime - nSpentDelta
		Else
			nLeftTime = 0
		End If
		oSender.Pool.SetPropertyValue oProp, nLeftTime
	End If
End Sub