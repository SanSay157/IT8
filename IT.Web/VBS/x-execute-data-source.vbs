'===============================================================================
'@@!!FILE_x-execute-data-source
'<GROUP !!SYMREF_VBS>
'<TITLE x-execute-data-source - Работа с источниками данных>
':Назначение:
'	Набор общих утилитарных функций, облегчающих работу с источниками данных.
'===============================================================================
'@@!!FUNCTIONS_x-execute-data-source
'<GROUP !!FILE_x-execute-data-source><TITLE Функции и процедуры>
Option Explicit


'===============================================================================
'@@X_ExecuteDataSource
'<GROUP !!FUNCTIONS_x-execute-data-source><TITLE X_ExecuteDataSource>
':Назначение:	Выполняет источник данных с заданным наименованием (используя команду 
'               <b>ExecuteDataSource</b>) c переданными параметрами.
':Параметры:	sDataSourceName - [in] наименование источника данных.
'               aParamNames - [in] массив наименований параметров.
'               aParamValues - [in] массив значений параметров.
':Результат:	Экземпляр <LINK Croc.XmlFramework.Commands.XExecuteDataSourceResponse, XExecuteDataSourceResponse />.
':Сигнатура:	
'   Function X_ExecuteDataSource( 
'       sDataSourceName [As String], 
'       aParamNames [As String], 
'       aParamValues [As Variant] 
'   ) [As XExecuteDataSourceResponse]
Function X_ExecuteDataSource(sDataSourceName, aParamNames, aParamValues)
	Dim oParamsBuilder, i
	Set X_ExecuteDataSource = Nothing
	Set oParamsBuilder = New XmlParamCollectionBuilderClass
	If IsArray(aParamNames) Then
		If UBound(aParamNames) <> UBound(aParamValues) Then
			Err.Raise -1, "X_ExecuteDataSource", "Размерности массива с наименованием параметров и массива со значениями параметров должны совпадать"
		End If
		' сформируем коллекцию параметров для выполнения источника данных	
		For i=0 To UBound(aParamNames)
			oParamsBuilder.AppendParameter aParamNames(i), aParamValues(i)
		Next
	End If
	With New XExecuteDataSourceRequest
	    .m_sName = "ExecuteDataSource"
	    .m_sDataSourceName = sDataSourceName
	    Set .m_oParams = New XParamsCollection
	    Set .m_oParams.m_oXmlParams = oParamsBuilder.XmlParametersRoot
	    Set X_ExecuteDataSource = X_ExecuteCommand(.Self)
	End With
End Function

'===============================================================================
'@@X_GetScalarValueFromDataSource
'<GROUP !!FUNCTIONS_x-execute-data-source><TITLE X_GetScalarValueFromDataSource>
':Назначение:	Выполняет источник данных с заданным наименованием (используя команду 
'               <b>ExecuteDataSource</b>) с переданными параметрами и возвращает 
'               значение первой колонки первой строки результата.
':Параметры:	sDataSourceName - [in] наименование источника данных.
'               aParamNames - [in] массив наименований параметров.
'               aParamValues - [in] массив значений параметров.
':Замечание:	В случае пустого результата возвращается пустая строка.
':Сигнатура:	
'   Function X_GetScalarValueFromDataSource( 
'       sDataSourceName [As String], 
'       aParamNames [As String], 
'       aParamValues[As Variant] 
'   ) [As String]
Function X_GetScalarValueFromDataSource(sDataSourceName, aParamNames, aParamValues)
	Dim aValues			' массив значений
	X_GetScalarValueFromDataSource = vbNullString
	aValues = X_GetFirstRowValuesFromDataSource(sDataSourceName, aParamNames, aParamValues)
	If UBound(aValues) >= 0 Then
		X_GetScalarValueFromDataSource = aValues(0)
	End If
End Function

'===============================================================================
'@@X_GetFirstRowValuesFromDataSource
'<GROUP !!FUNCTIONS_x-execute-data-source><TITLE X_GetFirstRowValuesFromDataSource>
':Назначение:	Выполняет источник данных с заданным наименованием (используя команду 
'               <b>ExecuteDataSource</b>) с переданными параметрами и возвращает массив 
'               полей первой строки результата (количество и порядок колонок 
'               определяются источником данных).
':Параметры:	sDataSourceName - [in] наименование источника данных.
'               aParamNames - [in] массив наименований параметров.
'               aParamValues - [in] массив значений параметров.
':Замечание:	В случае пустого результата возвращается пустой массив.
':Сигнатура:	
'   Function X_GetFirstRowValuesFromDataSource( 
'       sDataSourceName [As String], 
'       aParamNames [As String], 
'       aParamValues[As Variant] 
'   ) [As Array]
Function X_GetFirstRowValuesFromDataSource(sDataSourceName, aParamNames, aParamValues)
	Dim oResponse
	Dim oRow
	Dim i
	Dim aValues			' массив значений
	Dim nCount          ' количество значений
	Dim oXmlFields		' As IXMLDOMNodeList
	On Error Resume Next
	Set oResponse = X_ExecuteDataSource(sDataSourceName, aParamNames, aParamValues)
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
		On Error GoTo 0
		Set oRow = oResponse.m_oDataWrapped.m_oXmlDataTable.selectSingleNode("RS/R")
		If Not oRow Is Nothing Then
			Set oXmlFields = oRow.selectNodes("F")
			nCount = oXmlFields.length
			ReDim aValues(nCount-1)
			For i = 0 To nCount-1
				aValues(i) = oXmlFields.item(i).text
			Next
		Else
			aValues = Array()
		End If
	End If
	X_GetFirstRowValuesFromDataSource = aValues
End Function

'===============================================================================
'@@X_GetValuesFromDataSource
'<GROUP !!FUNCTIONS_x-execute-data-source><TITLE X_GetValuesFromDataSource>
':Назначение:	Выполняет источник данных с заданным наименованием (используя команду 
'               <b>ExecuteDataSource</b>) с переданными параметрами и возвращает массив 
'               значений: массив массивов с значениями колонок
'               (количество и порядок колонок определяются источником данных).
':Параметры:	sDataSourceName - [in] наименование источника данных.
'               aParamNames - [in] массив наименований параметров.
'               aParamValues - [in] массив значений параметров.
':Замечание:	В случае пустого результата возвращается пустой массив.
':Сигнатура:	
'   Function X_GetValuesFromDataSource( 
'       sDataSourceName [As String], 
'       aParamNames [As String], 
'       aParamValues[As Variant] 
'   ) [As Array]
Function X_GetValuesFromDataSource(sDataSourceName, aParamNames, aParamValues)
	Dim oResponse
	Dim oRow
	Dim i
	Dim aValues			' массив значений
	Dim oXmlFields		' As IXMLDOMNodeList
	On Error Resume Next
	Set oResponse = X_ExecuteDataSource(sDataSourceName, aParamNames, aParamValues)
	If Err Then
		If Not X_HandleError Then MsgBox Err.Description
	Else
		On Error GoTo 0
		Dim oRows
		Dim nColumnsCount
		Dim aFieldValues
		Dim nRow
		
		Set oRows = oResponse.m_oDataWrapped.m_oXmlDataTable.selectNodes("RS/R")
		ReDim aValues(oRows.length-1)
		If oRows.length > 0 Then
			nColumnsCount = oRows.item(0).selectNodes("F").length
		End If
		nRow = 0
		For Each oRow In oRows
			Set oXmlFields = oRow.selectNodes("F")
			ReDim aFieldValues(nColumnsCount-1)
			For i = 0 To nColumnsCount-1
				aFieldValues(i) = oXmlFields.item(i).text
			Next
			aValues(nRow) = aFieldValues
			nRow = nRow + 1
		Next
	End If
	X_GetValuesFromDataSource = aValues
End Function