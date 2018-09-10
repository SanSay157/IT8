Option Explicit

'==============================================================================
' Вспомогательный класс для управления отображением совокупности свойств,
' связанных с периодом времени
Class PeriodSelectorHandlerClass
	Dim m_oObjectEditor
	Dim m_oPeriodTypeEditor
	Dim m_oIntervalBeginEditor
	Dim m_oIntervalEndEditor
	Dim m_oQuarterEditor
	Dim m_oIntervalHtmlElement
	Dim m_oQuarterHtmlElement
	
	'==========================================================================
	Public Sub Init(oObjectEditor)
		Set m_oObjectEditor = oObjectEditor
		
		Set m_oPeriodTypeEditor = getEditor("PeriodType")
		Set m_oIntervalBeginEditor = getEditor("IntervalBegin")
		Set m_oIntervalEndEditor = getEditor("IntervalEnd")
		Set m_oQuarterEditor = getEditor("Quarter")
		
		Set m_oIntervalHtmlElement = document.all("divInterval")
		Set m_oQuarterHtmlElement = document.all("divQuarter")

		m_oPeriodTypeEditor.EventEngine.AddHandlerForEvent "Changed", Me, "OnPeriodTypeChanged"
		m_oQuarterEditor.EventEngine.AddHandlerForEvent "Changed", Me, "OnQuarterChanged"
		
		displayHtmlElements()
		setDates()
	End Sub
	
	'==========================================================================
	Private Function getEditor(sPropName)
		Set getEditor = m_oObjectEditor.CurrentPage.GetPropertyEditor( _
			m_oObjectEditor.Pool.GetXmlProperty( m_oObjectEditor.XmlObject, sPropName) )
	End Function
	
	'==========================================================================
	Public Sub OnPeriodTypeChanged(oSender, oEventArgs)
		displayHtmlElements()
		setDates()
	End Sub

	'==========================================================================
	Public Sub OnQuarterChanged(oSender, oEventArgs)
		setDates()
	End Sub

	'==========================================================================
	' Показывает/прячет дополнительные Html-элементы в зависимости от
	' выбранного типа периода
	Private Sub displayHtmlElements()
		Dim nPeriodType
		
		nPeriodType = m_oPeriodTypeEditor.Value
		
		If nPeriodType = PERIODTYPE_DATEINTERVAL Then
			m_oIntervalHtmlElement.style.display = "inline"
		Else
			m_oIntervalHtmlElement.style.display = "none"
		End If

		If nPeriodType = PERIODTYPE_SELECTEDQUARTER Then
			m_oQuarterHtmlElement.style.display = "inline"
		Else
			m_oQuarterHtmlElement.style.display = "none"
		End If
	End Sub
	
	'==========================================================================
	' Устанавливает значения начала и конца периода в зависимости от 
	' выбранного типа периода
	Private Sub setDates()
		Dim dtBegin, dtEnd
		Dim nQuarter
		Dim dtPrevMonth, dtNextMonth
		
		Select Case m_oPeriodTypeEditor.Value
			Case PERIODTYPE_CURRENTWEEK
				dtBegin = DateAdd("d", 1-Weekday(Date(), vbMonday), Date() )	
				dtEnd = DateAdd("d", 7-Weekday(Date(), vbMonday), Date() )	
			Case PERIODTYPE_CURRENTMONTH
				dtBegin = DateAdd("d", 1-Day(Date()), Date())
				dtNextMonth = DateAdd("m", 1, Date())
				dtEnd = DateAdd("d", -Day(dtNextMonth), dtNextMonth)
			Case PERIODTYPE_PREVIOUSMONTH
				dtPrevMonth = DateAdd("m", -1, Date())
				dtBegin = DateAdd("d", 1-Day(dtPrevMonth), dtPrevMonth)
				dtEnd = DateAdd("d", -Day(Date()), Date())
			Case PERIODTYPE_SELECTEDQUARTER
				nQuarter = m_oQuarterEditor.Value
				dtBegin = DateAdd("q", nQuarter-1, DateSerial(Year(Date()),1,1) )
				dtEnd = DateAdd("q", nQuarter, DateSerial(Year(Date())-1,12,31) )
		End Select
		
		If hasValue(dtBegin) Or hasValue(dtEnd) Then
			m_oIntervalBeginEditor.Value = dtBegin
			m_oIntervalEndEditor.Value = dtEnd
		End If
	End Sub

End Class

'==============================================================================
' Инициализирует обработку свойств, связанных с периодом времени
' [in] oObjectEditor - редактор объекта
'
' ВНИМАНИЕ!!! Вызывать данную процедуру из события PageStart редактора объекта
'  (usrXEditor_OnPageStart)
Sub InitPeriodSelector(oObjectEditor)
	With New PeriodSelectorHandlerClass
		.Init oObjectEditor
	End With
End Sub
