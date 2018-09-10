'----------------------------------------------------------
'	Редактор/Мастер IncidentType
Option Explicit

'----------------------------------------------------------
' Признак свойства (обязательное / разделитель / статическое / архивное)
' [in] oPool - пул объектов
' [in] oIncidentProp - заглушка описания свойства инцидента
function GetPropertyMeaning(oPool, ByVal oIncidentProp)
	dim s	' Формируемый результат
	
	Set oIncidentProp = oPool.GetXmlObjectByXmlElement(oIncidentProp, Empty)

	If oIncidentProp.SelectSingleNode("IsMandatory").nodeTypedValue Then _
		s="oбязательное"
		
	If oIncidentProp.SelectSingleNode("IsArchive").nodeTypedValue Then _
		s = s & " архивное"
	
	s = replace(trim(s), " ", " / ")
	GetPropertyMeaning = s
end function

'----------------------------------------------------------
' Значение свойства по умолчанию
' [in] oPool - пул объектов
' [in] oIncidentProp - заглушка описания свойства инцидента
function GetPropertyDefaultValue(oPool, ByVal oIncidentProp)
	Dim v			' Значение
	Dim sCastExpr	' Выражение на VBS для приведения значения к строке
	

	Set oIncidentProp = oPool.GetXmlObjectByXmlElement(oIncidentProp, Empty)
	v = Null
	sCastExpr = "v"
	Select Case oIncidentProp.SelectSingleNode("Type").nodeTypedValue
		Case IPROP_TYPE_IPROP_TYPE_LONG :
			v = oIncidentProp.SelectSingleNode("DefDouble").nodeTypedValue
			sCastExpr = "CLng(v)"
		Case IPROP_TYPE_IPROP_TYPE_DOUBLE :
			v = oIncidentProp.SelectSingleNode("DefDouble").nodeTypedValue
		Case IPROP_TYPE_IPROP_TYPE_DATE :
			v = oIncidentProp.SelectSingleNode("DefDate").nodeTypedValue
			sCastExpr = "FormatDateTime(v,vbShortDate)"
		Case IPROP_TYPE_IPROP_TYPE_TIME :
			' Пусто
		Case IPROP_TYPE_IPROP_TYPE_DATEANDTIME :
			v = oIncidentProp.SelectSingleNode("DefDate").nodeTypedValue
			sCastExpr = "FormatDateTime(v,vbShortDate)"
		Case IPROP_TYPE_IPROP_TYPE_BOOLEAN :
			v = oIncidentProp.SelectSingleNode("DefDouble").nodeTypedValue
			sCastExpr = "CStr(CLng(v)<>0)"
		Case IPROP_TYPE_IPROP_TYPE_STRING, IPROP_TYPE_IPROP_TYPE_TEXT :
			v = oIncidentProp.SelectSingleNode("DefText").nodeTypedValue
		Case IPROP_TYPE_IPROP_TYPE_PICTURE :
			' Пусто
		Case IPROP_TYPE_IPROP_TYPE_FILE :
			' Пусто
		Case IPROP_TYPE_IPROP_TYPE_SHORTCUT :
			' Пусто
	End Select
	
	if HasValue(v) Then _
		GetPropertyDefaultValue = Eval(sCastExpr)
end function

'----------------------------------------------------------
' Минимальное/ Максимальное значение свойства
' [in] oPool - пул объектов
' [in] oIncidentProp - заглушка описания свойства инцидента
function GetPropertyMinMaxValue(oPool, oIncidentProp)
	Dim v			' Вспомогательная переменная
	Dim vMin		' Минимум
	Dim vMax		' Максимум
	Dim sCastExpr	' Выражение на VBS для приведения к строке
	

	Set oIncidentProp = oPool.GetXmlObjectByXmlElement(oIncidentProp, Empty)
	v = Null
	vMin = Null
	vMax = Null
	
	sCastExpr = "v"
	
	Select Case oIncidentProp.SelectSingleNode("Type").nodeTypedValue
		Case IPROP_TYPE_IPROP_TYPE_LONG, IPROP_TYPE_IPROP_TYPE_STRING, IPROP_TYPE_IPROP_TYPE_TEXT:
			vMax = oIncidentProp.SelectSingleNode("MaxDouble").nodeTypedValue
			vMin = oIncidentProp.SelectSingleNode("MinDouble").nodeTypedValue
			sCastExpr = "CLng(v)"
		Case IPROP_TYPE_IPROP_TYPE_DOUBLE :
			vMax = oIncidentProp.SelectSingleNode("MaxDouble").nodeTypedValue
			vMin = oIncidentProp.SelectSingleNode("MinDouble").nodeTypedValue
		Case IPROP_TYPE_IPROP_TYPE_DATE :
			vMax = oIncidentProp.SelectSingleNode("MaxDate").nodeTypedValue
			vMin = oIncidentProp.SelectSingleNode("MinDate").nodeTypedValue
			sCastExpr = "FormatDateTime(v,vbShortDate)"
		Case IPROP_TYPE_IPROP_TYPE_TIME :
			' Пусто
		Case IPROP_TYPE_IPROP_TYPE_DATEANDTIME :
			vMax = oIncidentProp.SelectSingleNode("MaxDate").nodeTypedValue
			vMin = oIncidentProp.SelectSingleNode("MinDate").nodeTypedValue
			sCastExpr = "FormatDateTime(v,vbShortDate)"
		Case IPROP_TYPE_IPROP_TYPE_BOOLEAN :
			' Пусто
		Case IPROP_TYPE_IPROP_TYPE_PICTURE :
			' Пусто
		Case IPROP_TYPE_IPROP_TYPE_FILE :
			' Пусто
		Case IPROP_TYPE_IPROP_TYPE_SHORTCUT :
			' Пусто
	End Select
	
	v = vMax
	if HasValue(v) Then
		vMax = Eval(sCastExpr)
	else
		vMax = "-"	
	end if	
	v = vMin
	if HasValue(v) Then
		vMin = Eval(sCastExpr)
	else
		vMin = "-"	
	end if
	
	if vMax="-" and vMin="-" then exit function
	
	GetPropertyMinMaxValue = vMin & " / " & vMax
end function
